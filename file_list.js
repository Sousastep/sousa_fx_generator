// file_list.js — v8ui
// Lists the directories in ./generated_maxpat/ (relative to the host patcher)
// as an expandable / collapsible tree, scrolls, and outputs the full path of
// the clicked file.
//
// A Folder entry is a directory when its filetype is "fold"; extensionless
// entries are also treated as directories (some platforms report no filetype).

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

// ---------- state ----------
var thisPatcher = this.patcher;
var entries = [];        // top level model: dirs and loose files
var rows = [];           // flattened display list derived from entries
var openDirs = {};       // dir name -> expanded, kept across refresh()
var dirPath = "";
var statusMsg = "";
var scrollY = 0;
var selPath = null;      // row paths, stable across expand / collapse
var hovPath = null;
var w = 300, h = 200;
var draggingBar = false;
var dragOffset = 0;

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

function refresh() {
    entries = [];
    rows = [];
    selPath = null;
    hovPath = null;
    scrollY = 0;

    var base = getPatcherDir();
    if (base === null) {
        statusMsg = "Save the patcher first";
        dirPath = "";
        mgraphics.redraw();
        return;
    }

    dirPath = base + "/" + DIR_NAME;
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
        if (folderEntry.open) loadDirFiles(folderEntry);
        entries.push(folderEntry);
    }
    for (var j = 0; j < loose.length; j++) {
        entries.push({
            type: "file",
            name: loose[j],
            path: dirPath + "/" + loose[j]
        });
    }

    statusMsg = entries.length ? "" : "No files in " + DIR_NAME;
    rebuildRows();
}

function bang() { refresh(); }

function loadbang() { refresh(); }

// ---------- display model ----------
// Flattens the model into the visible rows: a dir row, then its files when open.
function rebuildRows() {
    rows = [];
    for (var i = 0; i < entries.length; i++) {
        var e = entries[i];
        if (e.type === "dir") {
            rows.push({ type: "dir", label: e.name, path: e.path, depth: 0, open: e.open, entry: e });
            if (e.open) {
                var files = e.files || [];
                for (var j = 0; j < files.length; j++) {
                    rows.push({ type: "file", label: files[j], path: e.path + "/" + files[j], depth: 1 });
                }
                if (files.length === 0) {
                    rows.push({ type: "empty", label: "(empty)", path: null, depth: 1 });
                }
            }
        } else {
            rows.push({ type: "file", label: e.name, path: e.path, depth: 0 });
        }
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
}

// ---------- geometry helpers ----------
function contentH() { return rows.length * ROW_H; }
function maxScroll() { return Math.max(0, contentH() - h); }
function needsBar()  { return contentH() > h; }

function clampScroll() {
    scrollY = Math.min(Math.max(scrollY, 0), maxScroll());
}

function thumbRect() {
    var ch = contentH();
    var th = Math.max(20, h * h / ch);
    var ms = maxScroll();
    var ty = ms > 0 ? (scrollY / ms) * (h - th) : 0;
    return { y: ty, h: th };
}

function setScrollFromThumb(thumbTop) {
    var t = thumbRect();
    var track = h - t.h;
    var frac = track > 0 ? Math.min(Math.max(thumbTop / track, 0), 1) : 0;
    scrollY = frac * maxScroll();
    mgraphics.redraw();
}

function rowAt(y) {
    var i = Math.floor((y + scrollY) / ROW_H);
    return (i >= 0 && i < rows.length) ? i : -1;
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

function paint() {
    var g = mgraphics;

    // background
    g.set_source_rgba(0.13, 0.13, 0.14, 1);
    g.rectangle(0, 0, w, h);
    g.fill();

    g.select_font_face(FONT);
    g.set_font_size(FONT_SIZE);

    if (rows.length === 0) {
        g.set_source_rgba(0.6, 0.6, 0.6, 1);
        g.move_to(PAD, 20);
        g.show_text(statusMsg || "Empty");
        return;
    }

    var first = Math.max(0, Math.floor(scrollY / ROW_H));
    var last  = Math.min(rows.length - 1, Math.ceil((scrollY + h) / ROW_H));

    for (var i = first; i <= last; i++) {
        var row = rows[i];
        var y = i * ROW_H - scrollY;

        if (row.path && row.path === selPath) {
            g.set_source_rgba(0.25, 0.45, 0.8, 1);
            g.rectangle(0, y, w, ROW_H);
            g.fill();
        } else if (row.path && row.path === hovPath) {
            g.set_source_rgba(1, 1, 1, 0.08);
            g.rectangle(0, y, w, ROW_H);
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

        g.move_to(x, y + ROW_H / 2 + FONT_SIZE * 0.35);
        g.show_text(row.label);
    }

    // scrollbar
    if (needsBar()) {
        g.set_source_rgba(0.13, 0.13, 0.14, 1);
        g.rectangle(w - BAR_W, 0, BAR_W, h);
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
function onclick(x, y) {
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

    var i = rowAt(y);
    if (i < 0) {
        selPath = null;
        mgraphics.redraw();
        return;
    }

    var row = rows[i];
    if (row.type === "dir") {
        toggleDir(row.entry);
        return;
    }
    if (!row.path) return;

    selPath = row.path;
    outlet(0, row.path);
    mgraphics.redraw();
}

function ondrag(x, y, but) {
    if (!but) { draggingBar = false; mgraphics.redraw(); return; }
    if (draggingBar) setScrollFromThumb(y - dragOffset);
}

function onidle(x, y) {
    draggingBar = false;
    var i = (needsBar() && x >= w - BAR_W) ? -1 : rowAt(y);
    var p = (i >= 0 && rows[i].path) ? rows[i].path : null;
    if (p !== hovPath) {
        hovPath = p;
        mgraphics.redraw();
    }
}

function onidleout() {
    hovPath = null;
    mgraphics.redraw();
}

function onwheel(x, y, dx, dy) {
    scrollY -= dy * ROW_H * WHEEL_SPEED;
    clampScroll();
    mgraphics.redraw();
}

// ---------- messages ----------
// "scroll <pixels>" scrolls to an absolute pixel offset
function scroll(v) {
    scrollY = v;
    clampScroll();
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
