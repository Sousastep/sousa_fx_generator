// file_list.js — v8ui
// Lists the directories in ./generated_maxpat/ (relative to the host patcher)
// as an expandable / collapsible tree, scrolls, and outputs the full path of
// the clicked file.
//
// A Folder entry is a directory when its filetype is "fold"; extensionless
// entries are also treated as directories (some platforms report no filetype).
//
// Ratings: every file row carries five clickable stars on its right edge.
// Clicking star N rates the file N/5; clicking the star it already has clears
// the rating. Ratings are stored in "<DIR_NAME>/.file_list_ratings.json",
// keyed by the path relative to DIR_NAME, and reloaded on loadbang.
//
// Header: the fixed bar at the top shows the title, a sort chip, an
// "unrated only" chip and a rating filter. The sort chip cycles
// A-Z -> rating high-to-low -> rating low-to-high; rating sorts rank the files
// inside each directory and order directories by their best-rated file,
// expanding everything once so the ranking is visible. The hollow-star chip
// shows only files with no rating; "All" clears the filter; clicking filter
// star N shows only files rated N or more (click again to clear). The title
// names the active filter, e.g. "Rated 4+ (3)" or "Unrated (2)".
//
// Workspace: expanded directories, scroll offset, selection, the effect in the
// RNBO slot, sort mode and filter are stored in
// "<DIR_NAME>/.file_list_state.json" (debounced ~250 ms) and restored on load.
// The loaded effect is marked with a gold bar on the left edge of its row; the
// host can report it with the "loaded <path>" message.
//
// Keyboard (click the list once to focus it):
//   up/down        move the selection
//   left/right     collapse a directory / expand it or enter it
//   home/end       first / last row
//   page up/down   move by one screen
//   return/space   load the selected file (or toggle a directory)
//   1..5           rate the selected file, 0 clears the rating
//   a..z           jump to the next effect starting with that letter
//   escape         clear the filter (or the selection)
// Send "keydebug 1" to the object to print raw key codes if a key is not
// recognized (v8ui's non-printable key codes have varied between builds).
// main_test_patcher also wires a Max "key" object's fourth outlet to
// "kbd <code>", because v8ui on some builds reports printable keys but no
// arrows. The fallback only acts while the list is hovered or focused.

mgraphics.init();
mgraphics.relative_coords = 0;
mgraphics.autofill = 0;

inlets = 1;
outlets = 1;

// ---------- settings ----------
var DIR_NAME   = "generated_maxpat";
var ROW_H      = 20;
var PAD        = 8;
var INDENT     = 14;   // extra pixels per nesting level
var BAR_W      = 10;
var FONT       = "Arial";
var FONT_SIZE  = 12;
var WHEEL_SPEED = 1;   // multiply; use a negative number to flip scroll direction

var HEADER_H    = 30;  // fixed header: title + sort + filter
var STAR_W      = 16;  // clickable width of one rating star
var STAR_R      = 6;   // star outer radius in pixels
var ALL_W       = 30;  // width of the "All" filter chip
var UNR_W       = 26;  // width of the "unrated only" chip
var SORT_W      = 36;  // width of the sort chip
var RATING_FILE = ".file_list_ratings.json";  // lives inside DIR_NAME
var STATE_FILE  = ".file_list_state.json";    // lives inside DIR_NAME
var TITLE       = "Effects";
var SAVE_DELAY  = 250; // ms of quiet before the workspace state is written

// ---------- state ----------
var thisPatcher = this.patcher;
var entries = [];        // top level model: dirs and loose files
var rows = [];           // flattened display list derived from entries
var openDirs = {};       // dir name -> expanded
var dirPath = "";
var statusMsg = "";
var scrollY = 0;
var selPath = null;      // selected row path or null
var hovPath = null;
var hovStar = 0;         // 1..5 star under the mouse in a file row (preview)
var w = 300, h = 200;
var draggingBar = false;
var dragOffset = 0;
var hasFocus = false;

var ratings = {};        // "Category/name.maxpat" -> 1..5
var ratingsPath = "";
var sortMode = 0;        // 0 = name, 1 = rating high->low, 2 = rating low->high
var filterMode = 0;      // 0 = all, -1 = unrated only, 1..5 = rated >= N
var matchCount = 0;      // files matching the current filter (whole tree)

var statePath = "";
var loadedPath = null;   // relative key of the effect in the RNBO slot
var stateTask = null;
var keyDebug = false;    // "keydebug 1" posts raw key codes to the Max window
var mouseOver = false;   // pointer over the list (gates the key-object fallback)
var lastAction = "";
var lastActionAt = 0;
var KEY_DEDUPE_MS = 25;  // native onkeydown + key object can report the same press

try {
    var r = box.rect;
    w = r[2] - r[0];
    h = r[3] - r[1];
} catch (e) {}

// ---------- file scanning ----------
function getPatcherDir() {
    var p = thisPatcher;
    while (p && !p.filepath && p.parentpatcher) p = p.parentpatcher;
    var fp = p ? p.filepath : "";
    if (!fp) return null;
    return fp.substring(0, fp.lastIndexOf("/"));
}

function byName(a, b) {
    return a.toLowerCase() < b.toLowerCase() ? -1 : 1;
}

function isDotName(name) {
    return !name || name.charAt(0) === ".";
}

function isFolder(f) {
    return f.filetype === "fold" || (f.filetype === null && f.extension === null);
}

// Fills entry.files with the (non-directory) contents of a directory.
function loadDirFiles(entry) {
    if (entry.files !== null) return;
    var list = [];
    var f = new Folder(entry.path);
    while (!f.end) {
        var name = f.filename;
        if (!isDotName(name) && !isFolder(f)) list.push(name);
        f.next();
    }
    f.close();
    list.sort(byName);
    entry.files = list;
}

function refresh(fromLoad) {
    entries = [];
    rows = [];
    hovPath = null;
    hovStar = 0;

    var base = getPatcherDir();
    if (base === null) {
        statusMsg = "Save the patcher first";
        dirPath = "";
        if (fromLoad) {
            ratings = {};
            ratingsPath = "";
            statePath = "";
            loadedPath = null;
            selPath = null;
            scrollY = 0;
            sortMode = 0;
            filterMode = 0;
            openDirs = {};
        }
        rebuildRows();
        return;
    }

    dirPath = base + "/" + DIR_NAME;
    loadRatings();          // ratings are cheap to re-read; bang picks up edits
    if (fromLoad) loadState();

    var folders = [];
    var loose = [];

    var f = new Folder(dirPath);
    while (!f.end) {
        var name = f.filename;
        if (!isDotName(name)) {
            if (isFolder(f)) folders.push(name);
            else loose.push(name);
        }
        f.next();
    }
    f.close();

    folders.sort(byName);
    loose.sort(byName);

    for (var i = 0; i < folders.length; i++) {
        var folderEntry = {
            type: "dir",
            name: folders[i],
            path: dirPath + "/" + folders[i],
            open: !!openDirs[folders[i]],
            files: null
        };
        // Load every directory once: counts, rating sort and filtering all
        // need the full picture, and there are only a handful of categories.
        loadDirFiles(folderEntry);
        entries.push(folderEntry);
    }
    for (var j = 0; j < loose.length; j++) {
        entries.push({
            type: "file",
            name: loose[j],
            path: dirPath + "/" + loose[j]
        });
    }

    rebuildRows();
}

function bang() { refresh(false); }

function loadbang() {
    refresh(true);
    post("file_list: up/down select, return load, 1-5 rate, 0 clear, esc filter\n");
}

// ---------- persistence helpers ----------
function relKey(path) {
    return path.substring(dirPath.length + 1);
}

function fileExistsIn(dir, name) {
    var found = false;
    try {
        var f = new Folder(dir);
        while (!f.end) {
            if (f.filename === name) { found = true; break; }
            f.next();
        }
        f.close();
    } catch (e) {}
    return found;
}

function readTextFile(path) {
    var txt = "";
    try {
        var f = new File(path, "read");
        if (!f.isopen) return "";
        // one call reads to EOF: a chunked read could split a UTF-8 character
        txt = f.readstring(f.eof + 1) || "";
        f.close();
    } catch (e) {
        return "";
    }
    return txt;
}

function writeTextFile(path, txt) {
    try {
        var f = new File(path, "write");
        if (!f.isopen) {
            post("file_list: could not open " + path + " for writing\n");
            return false;
        }
        // "write" access normally truncates; make it explicit so a shorter
        // file can never leave a stale tail behind.
        f.position = 0;
        f.eof = 0;
        f.writestring(txt);
        f.close();
        return true;
    } catch (e) {
        post("file_list: could not write " + path + ": " + e + "\n");
        return false;
    }
}

// ---------- ratings ----------
function ratingOf(path) {
    if (!path || !dirPath) return 0;
    return ratings[relKey(path)] || 0;
}

function loadRatings() {
    ratings = {};
    ratingsPath = dirPath ? dirPath + "/" + RATING_FILE : "";
    if (!ratingsPath) return;
    // Avoid a console error from the File constructor on first run.
    if (!fileExistsIn(dirPath, RATING_FILE)) return;

    var txt = readTextFile(ratingsPath);
    if (!txt) return;
    try {
        var obj = JSON.parse(txt);
        for (var k in obj) {
            var v = parseInt(obj[k], 10);
            if (v >= 1 && v <= 5) ratings[k] = v;
        }
    } catch (e) {
        post("file_list: ignoring unreadable " + RATING_FILE + "\n");
    }
}

function saveRatings() {
    if (!ratingsPath) return;
    var keys = [];
    for (var k in ratings) {
        if (ratings[k] > 0) keys.push(k);
    }
    keys.sort();

    var txt = "";
    if (keys.length === 0) {
        txt = "{}\n";
    } else {
        var body = "";
        for (var i = 0; i < keys.length; i++) {
            if (i > 0) body += ",\n  ";
            body += JSON.stringify(keys[i]) + ": " + ratings[keys[i]];
        }
        txt = "{\n  " + body + "\n}\n";
    }

    if (!writeTextFile(ratingsPath, txt)) {
        statusMsg = "Cannot save ratings";
    } else {
        statusMsg = "";
    }
}

function setRating(row, n) {
    if (!row || !row.path) return;
    var key = relKey(row.path);
    var next = (ratingOf(row.path) === n) ? 0 : n;  // same star again clears
    if (next > 0) ratings[key] = next;
    else delete ratings[key];
    hovStar = 0;
    saveRatings();
    rebuildRows();
}

// ---------- workspace state ----------
function loadState() {
    openDirs = {};
    scrollY = 0;
    selPath = null;
    loadedPath = null;
    sortMode = 0;
    filterMode = 0;

    statePath = dirPath ? dirPath + "/" + STATE_FILE : "";
    if (!statePath) return;
    if (!fileExistsIn(dirPath, STATE_FILE)) return;

    var txt = readTextFile(statePath);
    if (!txt) return;
    try {
        var o = JSON.parse(txt);
        if (o.open && o.open.length) {
            for (var i = 0; i < o.open.length; i++) openDirs[String(o.open[i])] = true;
        }
        if (typeof o.scroll === "number" && o.scroll >= 0) scrollY = o.scroll;
        if (o.sel) selPath = dirPath + "/" + String(o.sel);
        if (o.loaded) loadedPath = String(o.loaded);
        if (o.sort >= 0 && o.sort <= 2) sortMode = Math.round(o.sort);
        if (o.filter >= -1 && o.filter <= 5) filterMode = Math.round(o.filter);
    } catch (e) {
        post("file_list: ignoring unreadable " + STATE_FILE + "\n");
    }
}

function saveState() {
    if (!statePath) return;
    var open = [];
    for (var k in openDirs) {
        if (openDirs[k]) open.push(k);
    }
    open.sort();
    var o = {
        open: open,
        scroll: Math.round(scrollY),
        sel: selPath ? relKey(selPath) : "",
        loaded: loadedPath || "",
        sort: sortMode,
        filter: filterMode
    };
    writeTextFile(statePath, JSON.stringify(o, null, 2) + "\n");
}

// Coalesces the rapid-fire saves from scrolling and key repeats into one
// write; falls back to writing immediately if Task is unavailable.
function scheduleStateSave() {
    if (!statePath) return;
    try {
        if (!stateTask) {
            stateTask = new Task(function () {
                saveState();
            }, this);
        }
        stateTask.schedule(SAVE_DELAY);
    } catch (e) {
        saveState();
    }
}

function setSort(mode) {
    var next = ((Math.round(mode) % 3) + 3) % 3;
    var enteringRating = sortMode === 0 && next !== 0;
    sortMode = next;
    if (enteringRating) {
        setAllDirs(true);   // expand once so the ranking is visible
        return;
    }
    rebuildRows();
    scheduleStateSave();
}

function cycleSort() { setSort(sortMode + 1); }

function setFilter(n) {
    var v = Math.round(n);
    filterMode = Math.min(Math.max(v, -1), 5);
    rebuildRows();
    scheduleStateSave();
}

// ---------- filters ----------
function matchesFilter(path) {
    if (filterMode === 0) return true;
    var r = ratingOf(path);
    if (filterMode === -1) return r === 0;
    return r >= filterMode;
}

// ---------- sorting ----------
// Name order is the tree's native order. Rating sorts rank files inside each
// directory and order directories by their best-rated file; ties stay
// alphabetical so the layout does not shuffle for no reason.
function compareRanked(na, nb, ra, rb) {
    if (ra !== rb) return sortMode === 1 ? rb - ra : ra - rb;
    return byName(na, nb);
}

function dirRank(entry) {
    var files = entry.files || [];
    var best = 0;
    for (var i = 0; i < files.length; i++) {
        var r = ratings[entry.name + "/" + files[i]] || 0;
        if (r > best) best = r;
    }
    return best;
}

function sortedFiles(entry) {
    var list = (entry.files || []).slice();
    if (sortMode === 0) return list;
    list.sort(function (a, b) {
        return compareRanked(a, b,
            ratings[entry.name + "/" + a] || 0,
            ratings[entry.name + "/" + b] || 0);
    });
    return list;
}

// Directories keep the leading position they have in the model, loose files
// stay below them, matching the default layout.
function orderedEntries() {
    var dirs = [];
    var files = [];
    for (var i = 0; i < entries.length; i++) {
        if (entries[i].type === "dir") dirs.push(entries[i]);
        else files.push(entries[i]);
    }
    if (sortMode !== 0) {
        dirs.sort(function (a, b) {
            return compareRanked(a.name, b.name, dirRank(a), dirRank(b));
        });
        files.sort(function (a, b) {
            return compareRanked(a.name, b.name, ratingOf(a.path), ratingOf(b.path));
        });
    }
    return dirs.concat(files);
}

// Flattens the model into the visible rows: a dir row, then its files when open.
// With a filter active every directory is shown expanded, but only when it
// contains at least one file that passes the filter.
function rebuildRows() {
    rows = [];
    matchCount = 0;
    var filtering = filterMode !== 0;
    var ordered = orderedEntries();

    for (var i = 0; i < ordered.length; i++) {
        var e = ordered[i];
        if (e.type === "dir") {
            var files = sortedFiles(e);
            if (filtering) {
                var hits = [];
                for (var j = 0; j < files.length; j++) {
                    if (matchesFilter(e.path + "/" + files[j])) hits.push(files[j]);
                }
                matchCount += hits.length;
                if (hits.length === 0) continue;
                rows.push({ type: "dir", label: e.name, path: e.path, depth: 0, open: true, entry: e });
                for (var k = 0; k < hits.length; k++) {
                    rows.push({ type: "file", label: hits[k], path: e.path + "/" + hits[k], depth: 1 });
                }
            } else {
                matchCount += files.length;
                rows.push({ type: "dir", label: e.name, path: e.path, depth: 0, open: e.open, entry: e });
                if (e.open) {
                    for (var m = 0; m < files.length; m++) {
                        rows.push({ type: "file", label: files[m], path: e.path + "/" + files[m], depth: 1 });
                    }
                    if (files.length === 0) {
                        rows.push({ type: "empty", label: "(empty)", path: null, depth: 1 });
                    }
                }
            }
        } else {
            if (filtering && !matchesFilter(e.path)) continue;
            matchCount += 1;
            rows.push({ type: "file", label: e.name, path: e.path, depth: 0 });
        }
    }

    if (!dirPath) {
        statusMsg = "Save the patcher first";
    } else if (filtering && rows.length === 0) {
        statusMsg = (filterMode === -1)
            ? "No unrated effects"
            : "No effects rated " + filterMode + "+";
    } else if (!filtering && entries.length === 0) {
        statusMsg = "No files in " + DIR_NAME;
    } else {
        statusMsg = "";
    }

    clampScroll();
    mgraphics.redraw();
}

function toggleDir(entry) {
    entry.open = !entry.open;
    if (entry.open) {
        loadDirFiles(entry);
        openDirs[entry.name] = true;
    } else {
        delete openDirs[entry.name];
    }
    rebuildRows();
    scheduleStateSave();
}

function setAllDirs(open) {
    for (var i = 0; i < entries.length; i++) {
        var e = entries[i];
        if (e.type !== "dir") continue;
        e.open = open;
        if (open) {
            loadDirFiles(e);
            openDirs[e.name] = true;
        } else {
            delete openDirs[e.name];
        }
    }
    rebuildRows();
    scheduleStateSave();
}

// ---------- geometry helpers ----------
function listH()      { return Math.max(0, h - HEADER_H); }
function contentH()   { return rows.length * ROW_H; }
function maxScroll()  { return Math.max(0, contentH() - listH()); }
function needsBar()   { return contentH() > listH(); }
function listRight()  { return w - (needsBar() ? BAR_W : 0); }

function clampScroll() {
    scrollY = Math.min(Math.max(scrollY, 0), maxScroll());
}

function thumbRect() {
    var lh = listH();
    var ch = contentH();
    var th = Math.max(20, lh * lh / Math.max(ch, 1));
    var ms = maxScroll();
    var ty = ms > 0 ? HEADER_H + (scrollY / ms) * (lh - th) : HEADER_H;
    return { y: ty, h: th };
}

function setScrollFromThumb(thumbTop) {
    var t = thumbRect();
    var track = listH() - t.h;
    var frac = track > 0 ? Math.min(Math.max((thumbTop - HEADER_H) / track, 0), 1) : 0;
    scrollY = frac * maxScroll();
    scheduleStateSave();
    mgraphics.redraw();
}

function rowAt(y) {
    if (y < HEADER_H) return -1;
    var i = Math.floor((y - HEADER_H + scrollY) / ROW_H);
    return (i >= 0 && i < rows.length) ? i : -1;
}

// Star geometry: star N (1..5) sits STAR_W further left than star N+1, all
// right-aligned inside the list area.
function starLeft(n) { return listRight() - PAD - (6 - n) * STAR_W; }
function allChipLeft() { return starLeft(1) - ALL_W; }
function unratedChipLeft() { return allChipLeft() - UNR_W; }
function sortChipLeft() { return unratedChipLeft() - SORT_W; }

function starIndexAtX(x) {
    for (var s = 1; s <= 5; s++) {
        var sx = starLeft(s);
        if (x >= sx && x < sx + STAR_W) return s;
    }
    return 0;
}

function starHit(x, y) {
    if (y < HEADER_H) return 0;
    var i = rowAt(y);
    if (i < 0) return 0;
    var row = rows[i];
    if (!row || row.type !== "file" || !row.path) return 0;
    return starIndexAtX(x);
}

// ---------- selection ----------
function rowIndexForPath(path) {
    if (!path) return -1;
    for (var i = 0; i < rows.length; i++) {
        if (rows[i].path === path) return i;
    }
    return -1;
}

function ensureVisible(i) {
    var top = i * ROW_H;
    var bottom = top + ROW_H;
    if (top < scrollY) scrollY = top;
    else if (bottom > scrollY + listH()) scrollY = bottom - listH();
    clampScroll();
}

function selectIndex(i, reveal) {
    if (i < 0 || i >= rows.length || !rows[i].path) return;
    selPath = rows[i].path;
    if (reveal) ensureVisible(i);
    mgraphics.redraw();
}

function moveSelection(dir) {
    if (!rows.length) return;
    var i = rowIndexForPath(selPath);
    if (i < 0) i = dir > 0 ? -1 : rows.length;
    var j = i + dir;
    while (j >= 0 && j < rows.length && !rows[j].path) j += dir;
    if (j < 0 || j >= rows.length) return;
    selectIndex(j, true);
    scheduleStateSave();
}

function moveByPage(dir) {
    if (!rows.length) return;
    var perPage = Math.max(1, Math.floor(listH() / ROW_H) - 1);
    var i = rowIndexForPath(selPath);
    if (i < 0) i = dir > 0 ? -1 : rows.length;
    var j = i + dir * perPage;
    if (j < 0) j = 0;
    if (j >= rows.length) j = rows.length - 1;
    while (j >= 0 && j < rows.length && !rows[j].path) j += dir;
    if (j < 0 || j >= rows.length) return;
    selectIndex(j, true);
    scheduleStateSave();
}

function selectEdge(dir) {
    if (!rows.length) return;
    var i, step;
    if (dir < 0) { i = 0; step = 1; }        // home: first selectable row
    else { i = rows.length - 1; step = -1; } // end: last selectable row
    while (i >= 0 && i < rows.length && !rows[i].path) i += step;
    if (i < 0 || i >= rows.length) return;
    selectIndex(i, true);
    scheduleStateSave();
}

function jumpToLetter(ch) {
    var n = rows.length;
    if (!n) return;
    var start = rowIndexForPath(selPath);
    var lower = ch.toLowerCase();
    for (var step = 1; step <= n; step++) {
        var i = ((start + step) % n + n) % n;
        var row = rows[i];
        if (row.type !== "file") continue;
        if (row.label.toLowerCase().charAt(0) === lower) {
            selectIndex(i, true);
            scheduleStateSave();
            return;
        }
    }
}

function collapseOrParent() {
    var i = rowIndexForPath(selPath);
    if (i < 0) return;
    var row = rows[i];
    if (row.type === "dir") {
        if (row.open && filterMode === 0) toggleDir(row.entry);
        return;
    }
    if (row.depth > 0) {
        for (var j = i; j >= 0; j--) {
            if (rows[j].type === "dir") {
                selectIndex(j, true);
                scheduleStateSave();
                return;
            }
        }
    }
}

function expandOrChild() {
    var i = rowIndexForPath(selPath);
    if (i < 0) return;
    var row = rows[i];
    if (row.type !== "dir") return;
    if (!row.open && filterMode === 0) {
        toggleDir(row.entry);
        return;
    }
    if (i + 1 < rows.length && rows[i + 1].path) {
        selectIndex(i + 1, true);
        scheduleStateSave();
    }
}

// Sends the path out and marks the effect as the one in the RNBO slot.
function openRow(row) {
    if (!row) return;
    if (row.type === "dir") {
        selPath = row.path;
        if (filterMode === 0) toggleDir(row.entry);
        else scheduleStateSave();
        mgraphics.redraw();
        return;
    }
    if (!row.path) return;
    selPath = row.path;
    loadedPath = relKey(row.path);
    outlet(0, row.path);
    scheduleStateSave();
    mgraphics.redraw();
}

function activateSelected() {
    var i = rowIndexForPath(selPath);
    if (i < 0) {
        moveSelection(1);
        return;
    }
    openRow(rows[i]);
}

function rateSelected(n) {
    var i = rowIndexForPath(selPath);
    if (i < 0 || rows[i].type !== "file") return;
    setRating(rows[i], n);
}

// ---------- drawing ----------
function drawTriangle(g, x, y, open) {
    var cy = y + ROW_H / 2;
    g.set_source_rgba(0.75, 0.78, 0.85, 1);
    if (open) {
        g.move_to(x + 1, cy - 4);
        g.line_to(x + 9, cy - 4);
        g.line_to(x + 5, cy + 3);
    } else {
        g.move_to(x + 1, cy - 4);
        g.line_to(x + 1, cy + 4);
        g.line_to(x + 6, cy);
    }
    g.close_path();
    g.fill();
}

function starPath(g, cx, cy, radius) {
    var inner = radius * 0.45;
    g.move_to(cx, cy - radius);
    for (var i = 1; i < 10; i++) {
        var ang = -Math.PI / 2 + i * Math.PI / 5;
        var rad = (i % 2 === 0) ? radius : inner;
        g.line_to(cx + Math.cos(ang) * rad, cy + Math.sin(ang) * rad);
    }
    g.close_path();
}

function drawStar(g, cx, cy, radius, filled) {
    starPath(g, cx, cy, radius);
    if (filled) {
        g.set_source_rgba(0.98, 0.76, 0.28, 1);
        g.fill();
    } else {
        g.set_source_rgba(0.85, 0.87, 0.95, 0.28);
        g.set_line_width(1);
        g.stroke();
    }
}

function drawStarChip(g, x, cy, active) {
    if (active) {
        g.set_source_rgba(0.25, 0.45, 0.8, 1);
        g.rectangle_rounded(x, cy - 9, UNR_W - 6, 18, 5, 5);
        g.fill();
    }
    starPath(g, x + (UNR_W - 6) / 2, cy, 5);
    g.set_source_rgba(1, 1, 1, active ? 1 : 0.42);
    g.set_line_width(1);
    g.stroke();
}

// Shortens text with an ellipsis so it stops before maxW pixels.
function fitText(g, text, maxW) {
    if (maxW <= 10) return "";
    if (g.text_measure(text)[0] <= maxW) return text;
    var ell = "\u2026";
    var lo = 0, hi = text.length;
    while (lo < hi) {
        var mid = Math.ceil((lo + hi) / 2);
        if (g.text_measure(text.substring(0, mid) + ell)[0] <= maxW) lo = mid;
        else hi = mid - 1;
    }
    return lo > 0 ? text.substring(0, lo) + ell : ell;
}

function headerTitle() {
    if (filterMode === -1) return "Unrated (" + matchCount + ")";
    if (filterMode > 0) return "Rated " + filterMode + "+ (" + matchCount + ")";
    return TITLE + " (" + matchCount + ")";
}

function paintHeader(g) {
    // background + hairline (blue while the list has keyboard focus)
    g.set_source_rgba(0.17, 0.17, 0.19, 1);
    g.rectangle(0, 0, w, HEADER_H);
    g.fill();
    if (hasFocus) g.set_source_rgba(0.35, 0.55, 0.9, 0.9);
    else g.set_source_rgba(1, 1, 1, 0.10);
    g.rectangle(0, HEADER_H - 1, w, 1);
    g.fill();

    var baseline = HEADER_H / 2 + FONT_SIZE * 0.35;

    g.set_source_rgba(0.85, 0.88, 0.95, 1);
    g.move_to(PAD, baseline);
    g.show_text(fitText(g, headerTitle(), sortChipLeft() - 6 - PAD));

    // sort chip: A-Z, rating high->low, rating low->high
    var zx = sortChipLeft();
    g.set_source_rgba(0.25, 0.45, 0.8, 1);
    g.rectangle_rounded(zx, HEADER_H / 2 - 9, SORT_W - 6, 18, 5, 5);
    g.fill();
    if (sortMode === 0) {
        g.set_source_rgba(1, 1, 1, 1);
        var tw = g.text_measure("A-Z")[0];
        g.move_to(zx + (SORT_W - 6 - tw) / 2, baseline);
        g.show_text("A-Z");
    } else {
        drawStar(g, zx + 9, HEADER_H / 2, 4, true);
        g.set_source_rgba(1, 1, 1, 1);
        var acx = zx + 22;
        var acy = HEADER_H / 2;
        if (sortMode === 1) {
            g.move_to(acx - 4, acy - 2);
            g.line_to(acx + 4, acy - 2);
            g.line_to(acx, acy + 3);
        } else {
            g.move_to(acx - 4, acy + 3);
            g.line_to(acx + 4, acy + 3);
            g.line_to(acx, acy - 2);
        }
        g.close_path();
        g.fill();
    }

    // unrated-only chip: a hollow star
    drawStarChip(g, unratedChipLeft(), HEADER_H / 2, filterMode === -1);

    // "All" filter chip
    var ax = allChipLeft();
    if (filterMode === 0) {
        g.set_source_rgba(0.25, 0.45, 0.8, 1);
        g.rectangle_rounded(ax, HEADER_H / 2 - 9, ALL_W - 6, 18, 5, 5);
        g.fill();
        g.set_source_rgba(1, 1, 1, 1);
    } else {
        g.set_source_rgba(0.62, 0.65, 0.72, 1);
    }
    g.move_to(ax + 5, baseline);
    g.show_text("All");

    // filter stars: filled up to the active minimum
    var minShown = filterMode > 0 ? filterMode : 0;
    for (var s = 1; s <= 5; s++) {
        drawStar(g, starLeft(s) + STAR_W / 2, HEADER_H / 2, STAR_R, s <= minShown);
    }
}

function paint() {
    var g = mgraphics;

    // background
    g.set_source_rgba(0.13, 0.13, 0.14, 1);
    g.rectangle(0, 0, w, h);
    g.fill();

    g.select_font_face(FONT);
    g.set_font_size(FONT_SIZE);

    // rows first: the opaque header painted afterwards covers any row that
    // scrolled up underneath it
    var first = Math.max(0, Math.floor(scrollY / ROW_H));
    var last  = Math.min(rows.length - 1, Math.ceil((scrollY + h) / ROW_H));

    for (var i = first; i <= last; i++) {
        var row = rows[i];
        var y = HEADER_H + i * ROW_H - scrollY;
        var isLoaded = row.type === "file" && row.path && loadedPath
            && relKey(row.path) === loadedPath;

        if (row.path && row.path === selPath) {
            g.set_source_rgba(0.25, 0.45, 0.8, 1);
            g.rectangle(0, y, w, ROW_H);
            g.fill();
        } else if (row.path && row.path === hovPath) {
            g.set_source_rgba(1, 1, 1, 0.08);
            g.rectangle(0, y, w, ROW_H);
            g.fill();
        } else if (isLoaded) {
            g.set_source_rgba(0.98, 0.76, 0.28, 0.07);
            g.rectangle(0, y, w, ROW_H);
            g.fill();
        }

        // gold bar marks the effect currently in the RNBO slot
        if (isLoaded) {
            g.set_source_rgba(0.98, 0.76, 0.28, 0.95);
            g.rectangle(0, y + 2, 3, ROW_H - 4);
            g.fill();
        }

        var x = PAD + row.depth * INDENT;
        if (row.type === "dir") {
            drawTriangle(g, x, y, row.open);
            x += 13;
            g.set_source_rgba(0.85, 0.88, 0.95, 1);
        } else if (row.type === "empty") {
            g.set_source_rgba(0.5, 0.5, 0.55, 1);
        } else {
            g.set_source_rgba(0.92, 0.92, 0.92, 1);
        }

        var limit = (row.type === "file")
            ? starLeft(1) - 6 - x
            : listRight() - PAD - x;
        g.move_to(x, y + ROW_H / 2 + FONT_SIZE * 0.35);
        g.show_text(fitText(g, row.label, limit));

        // star rating, right-aligned in the row
        if (row.type === "file" && row.path) {
            var rating = ratingOf(row.path);
            var preview = (row.path === hovPath) ? hovStar : 0;
            var shown = preview > 0 ? preview : rating;
            for (var s = 1; s <= 5; s++) {
                drawStar(g, starLeft(s) + STAR_W / 2, y + ROW_H / 2, STAR_R - 0.5, s <= shown);
            }
        }
    }

    if (rows.length === 0) {
        g.set_source_rgba(0.6, 0.6, 0.6, 1);
        g.move_to(PAD, HEADER_H + 20);
        g.show_text(statusMsg || "Empty");
    }

    // header last so rows can never bleed into it
    paintHeader(g);

    // scrollbar (below the header only)
    if (needsBar()) {
        g.set_source_rgba(0.13, 0.13, 0.14, 1);
        g.rectangle(w - BAR_W, HEADER_H, BAR_W, listH());
        g.fill();

        var t = thumbRect();
        g.set_source_rgba(0.55, 0.55, 0.58, draggingBar ? 1 : 0.8);
        g.rectangle(w - BAR_W + 2, t.y + 1, BAR_W - 4, t.h - 2);
        g.fill();
    }
}

function onresize(nw, nh) {
    w = nw;
    h = nh;
    clampScroll();
    mgraphics.redraw();
}

// ---------- mouse ----------
function headerClick(x) {
    if (x >= sortChipLeft() && x < unratedChipLeft()) {
        cycleSort();
        return;
    }
    if (x >= unratedChipLeft() && x < allChipLeft()) {
        setFilter(filterMode === -1 ? 0 : -1);
        return;
    }
    if (x >= allChipLeft() && x < starLeft(1)) {
        setFilter(0);
        return;
    }
    var s = starIndexAtX(x);
    if (s > 0) setFilter(filterMode === s ? 0 : s);
}

function onclick(x, y) {
    mouseOver = true;   // the key-object fallback stays live without onidle
    if (y < HEADER_H) {
        headerClick(x);
        return;
    }

    if (needsBar() && x >= w - BAR_W) {
        draggingBar = true;
        var t = thumbRect();
        if (y >= t.y && y <= t.y + t.h) {
            dragOffset = y - t.y;
        } else {
            dragOffset = t.h / 2;
            setScrollFromThumb(y - dragOffset);
        }
        return;
    }

    var s = starHit(x, y);
    if (s > 0) {
        setRating(rows[rowAt(y)], s);
        return;
    }

    var i = rowAt(y);
    if (i < 0) {
        selPath = null;
        scheduleStateSave();
        mgraphics.redraw();
        return;
    }
    openRow(rows[i]);
}

function ondrag(x, y, but) {
    if (!but) { draggingBar = false; mgraphics.redraw(); return; }
    if (draggingBar) setScrollFromThumb(y - dragOffset);
}

function onidle(x, y) {
    draggingBar = false;
    mouseOver = true;
    var overBar = needsBar() && x >= w - BAR_W && y >= HEADER_H;
    var s = overBar ? 0 : starHit(x, y);
    var i = overBar ? -1 : rowAt(y);
    var p = (i >= 0 && rows[i].path) ? rows[i].path : null;
    if (p !== hovPath || s !== hovStar) {
        hovPath = p;
        hovStar = s;
        mgraphics.redraw();
    }
}

function onidleout() {
    mouseOver = false;
    hovPath = null;
    hovStar = 0;
    mgraphics.redraw();
}

function onwheel(x, y, dx, dy) {
    scrollY -= dy * ROW_H * WHEEL_SPEED;
    clampScroll();
    scheduleStateSave();
    mgraphics.redraw();
}

function onfocus() {
    hasFocus = true;
    mgraphics.redraw();
}

function onblur() {
    hasFocus = false;
    mgraphics.redraw();
}

// ---------- keyboard ----------
// The key code v8ui reports for non-printable keys is not documented and has
// differed between builds, so accept every encoding Max has used:
//   Carbon/Apple:       arrows 123..126, home 115, end 119, page 116/121, return 36, escape 53, space 49
//   Unicode function:   arrows 63232..63235, home 63273, end 63275, page 63276/63277
//   platform-independent (key object outlet 4): arrows -9..-12, home -15, end -16, page -13/-14,
//                       return -4, space -2, escape -3
//   web keyCode:        arrows 37..40
// Printable characters are matched first through textcharacter, so an ASCII
// 115 ('s') is never mistaken for Home.
function specialKeyAction(code) {
    switch (code) {
        case 126: case 63232: case -9: case 38: return "up";
        case 125: case 63233: case -10: case 40: return "down";
        case 123: case 63234: case -11: case 37: return "left";
        case 124: case 63235: case -12: case 39: return "right";
        case 115: case 63273: case -15: return "home";
        case 119: case 63275: case -16: return "end";
        case 116: case 63276: case -13: case 33: return "pageup";
        case 121: case 63277: case -14: case 34: return "pagedown";
        case 13: case 36: case 76: case 10: case -4: return "activate";
        case 32: case 49: case -2: return "activate";
        case 27: case 53: case -3: return "escape";
        default: return "";
    }
}

function keyAction(keycode, textcharacter) {
    var tc = (typeof textcharacter === "number") ? textcharacter : 0;
    var ch = tc > 0 ? String.fromCharCode(tc) : "";

    if (ch >= "1" && ch <= "5") return "rate:" + ch;
    if (ch === "0") return "rate:0";
    var low = ch.toLowerCase();
    if (low >= "a" && low <= "z") return "letter:" + low;
    if (ch === " " || ch === "\r" || ch === "\n") return "activate";
    if (ch === "\u001b") return "escape";

    // Arrows and other specials may arrive as textcharacter (Unicode
    // function-key code points) or, usually, as keycode with no character.
    if (tc >= 63232 || (tc > 0 && tc < 32) || tc === 127) {
        var a = specialKeyAction(tc);
        if (a) return a;
    }
    if (tc === 0) return specialKeyAction(keycode);
    // Unknown non-printable text character: the keycode may still identify it.
    if (tc > 127) return specialKeyAction(keycode);
    return "";   // printable punctuation does nothing
}

function performAction(action) {
    if (!action) return;
    // The Max key-object fallback and native onkeydown can both report the
    // same press; keep one action per physical key event.
    var now = Date.now();
    if (action === lastAction && now - lastActionAt < KEY_DEDUPE_MS) return;
    lastAction = action;
    lastActionAt = now;

    if (action === "up") { moveSelection(-1); return; }
    if (action === "down") { moveSelection(1); return; }
    if (action === "left") { collapseOrParent(); return; }
    if (action === "right") { expandOrChild(); return; }
    if (action === "home") { selectEdge(-1); return; }
    if (action === "end") { selectEdge(1); return; }
    if (action === "pageup") { moveByPage(-1); return; }
    if (action === "pagedown") { moveByPage(1); return; }
    if (action === "activate") { activateSelected(); return; }
    if (action === "escape") {
        if (filterMode !== 0) setFilter(0);
        else {
            selPath = null;
            scheduleStateSave();
            mgraphics.redraw();
        }
        return;
    }
    if (action.indexOf("rate:") === 0) { rateSelected(Number(action.substring(5))); return; }
    if (action.indexOf("letter:") === 0) { jumpToLetter(action.substring(7)); return; }
}

function onkeydown(keycode, textcharacter, updown, mod1, shift, caps, opt, mod2) {
    if (mod1) return 0;   // leave command/ctrl shortcuts alone
    var action = keyAction(keycode, textcharacter);
    if (keyDebug) {
        post("file_list key: keycode=" + keycode + " char=" + textcharacter +
             " -> " + (action || "none") + "\n");
    }
    if (!action) return 0;
    performAction(action);
    return 1;
}

// ---------- messages ----------
// "scroll <pixels>" scrolls to an absolute pixel offset
function scroll(v) {
    scrollY = v;
    clampScroll();
    scheduleStateSave();
    mgraphics.redraw();
}

// "expandall" / "collapseall" open or close every directory
function expandall() { setAllDirs(true); }
function collapseall() { setAllDirs(false); }

// "toggle <name>" flips one top level directory by name
function toggle(name) {
    for (var i = 0; i < entries.length; i++) {
        if (entries[i].type === "dir" && entries[i].name === String(name)) {
            toggleDir(entries[i]);
            return;
        }
    }
}

// "filter <0|1..5|-1>" 0 = all, 1..5 = rated >= N, -1 = unrated only
function filter(v) { setFilter(v); }

// "sort <0|1|2>" 0 = A-Z, 1 = rating high->low, 2 = rating low->high
function sort(v) { setSort(v); }

// "rating <relative path> <0..5>" sets or clears one rating by hand
function rating(path, n) {
    if (!dirPath) return;
    var key = String(path);
    var v = Math.round(Number(n));
    if (v >= 1 && v <= 5) ratings[key] = Math.min(v, 5);
    else delete ratings[key];
    saveRatings();
    rebuildRows();
}

// "loaded <path>" marks the effect currently in the RNBO slot; no argument
// clears the mark. Accepts the path emitted by this object or a relative key.
function loaded(path) {
    var key = (path === undefined || path === null) ? "" : String(path);
    if (!key || key === "none") {
        loadedPath = null;
    } else {
        if (dirPath && key.indexOf(dirPath + "/") === 0) {
            key = key.substring(dirPath.length + 1);
        }
        loadedPath = key;
    }
    scheduleStateSave();
    mgraphics.redraw();
}

// "savestate" writes the workspace state now instead of waiting for the timer
function savestate() { saveState(); }

// "keydebug <0|1>" posts the raw keycode/textcharacter of each key to the Max
// window, for diagnosing keys the mapping does not recognize yet.
function keydebug(v) { keyDebug = Number(v) ? true : false; }

// "kbd <code>" receives key codes from a Max key object wired into the inlet.
// v8ui does not report arrow keys on some builds, so main_test_patcher sends
// the key object's fourth (platform-independent) outlet here: ASCII for
// printable keys, negative codes for arrows/Enter/Escape/Home/End/Page.
// Acting only while the list is hovered or focused keeps typing elsewhere safe.
function kbd(v) {
    if (keyDebug) {
        post("file_list kbd: " + v + (mouseOver || hasFocus ? "" : " (ignored)") + "\n");
    }
    if (!mouseOver && !hasFocus) return;

    var n = Math.round(Number(v));
    if (!isFinite(n) || n === 0) return;

    var action = "";
    if (n < 0 || n >= 63232) {
        action = specialKeyAction(n);
    } else if (n === 13 || n === 10 || n === 27 || n === 32) {
        action = specialKeyAction(n);   // Return / Enter / Escape / Space as ASCII
    } else {
        var ch = String.fromCharCode(n);
        if (ch >= "1" && ch <= "5") action = "rate:" + ch;
        else if (ch === "0") action = "rate:0";
        var low = ch.toLowerCase();
        if (low >= "a" && low <= "z") action = "letter:" + low;
    }
    if (action) performAction(action);
}
