// file_list.js — v8 companion script for jweb (file_list.html)
// Scans ./generated_maxpat/ (and ./generated_fx/ as fallback), reads/writes
// ratings in ./ratings.json (plus ./generated_maxpat/.file_list_ratings.json
// for compatibility) and workspace state in ./generated_maxpat/.file_list_state.json,
// serves _paraminfo.txt and .txt DSP code to the jweb UI, and emits the full
// path of the clicked .maxpat from outlet 0.
//
// Outlet 0: selected .maxpat file path (wired to patcher loader)
// Outlet 1: messages to the jweb object

inlets = 1;
outlets = 2;

var DIR_NAME = "generated_maxpat";
var FX_DIR_NAME = "generated_fx";
var TRACKED_RATING_FILE = "ratings.json";
var LEGACY_RATING_FILE = ".file_list_ratings.json";
var STATE_FILE = ".file_list_state.json";
var HTML_FILE = "file_list.html";

var thisPatcher = this.patcher;
var baseDir = null;
var dirPath = "";
var fxDirPath = "";
var trackedRatingsPath = "";
var legacyRatingsPath = "";
var statePath = "";

var ratings = {};
var savedState = null;

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

function parseRatingsText(txt, target) {
    if (!txt) return;
    try {
        var obj = JSON.parse(txt);
        for (var k in obj) {
            var v = parseInt(obj[k], 10);
            if (v >= 1 && v <= 5) target[k] = v;
        }
    } catch (e) {}
}

function formatRatingsJson(obj) {
    var keys = [];
    for (var k in obj) {
        if (obj[k] > 0) keys.push(k);
    }
    keys.sort();
    if (keys.length === 0) return "{}\n";
    var body = "";
    for (var i = 0; i < keys.length; i++) {
        if (i > 0) body += ",\n  ";
        body += JSON.stringify(keys[i]) + ": " + obj[keys[i]];
    }
    return "{\n  " + body + "\n}\n";
}

function loadRatings() {
    ratings = {};
    if (!baseDir) return;
    trackedRatingsPath = baseDir + "/" + TRACKED_RATING_FILE;
    legacyRatingsPath = dirPath ? (dirPath + "/" + LEGACY_RATING_FILE) : "";

    if (dirPath && fileExistsIn(dirPath, LEGACY_RATING_FILE)) {
        parseRatingsText(readTextFile(legacyRatingsPath), ratings);
    }
    if (fileExistsIn(baseDir, TRACKED_RATING_FILE)) {
        parseRatingsText(readTextFile(trackedRatingsPath), ratings);
    }
}

function writeAllRatings() {
    var txt = formatRatingsJson(ratings);
    if (trackedRatingsPath) writeTextFile(trackedRatingsPath, txt);
    if (legacyRatingsPath) writeTextFile(legacyRatingsPath, txt);
}

function loadState() {
    savedState = null;
    if (!dirPath) return;
    statePath = dirPath + "/" + STATE_FILE;
    if (!fileExistsIn(dirPath, STATE_FILE)) return;
    var txt = readTextFile(statePath);
    if (!txt) return;
    try {
        savedState = JSON.parse(txt);
    } catch (e) {
        post("file_list: ignoring unreadable " + STATE_FILE + "\n");
    }
}

function scanDirFiles(folderPath) {
    var list = [];
    try {
        var f = new Folder(folderPath);
        while (!f.end) {
            var name = f.filename;
            if (!isDotName(name) && !isFolder(f)) list.push(name);
            f.next();
        }
        f.close();
    } catch (e) {}
    list.sort(byName);
    return list;
}

function buildEntries() {
    var entries = [];
    if (!dirPath) return entries;

    var folders = [];
    var loose = [];
    try {
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
    } catch (e) {}

    folders.sort(byName);
    loose.sort(byName);

    var openMap = {};
    if (savedState && savedState.open && savedState.open.length) {
        for (var s = 0; s < savedState.open.length; s++) {
            openMap[String(savedState.open[s])] = true;
        }
    }

    for (var i = 0; i < folders.length; i++) {
        var folderPath = dirPath + "/" + folders[i];
        entries.push({
            type: "dir",
            name: folders[i],
            path: folderPath,
            open: !!openMap[folders[i]],
            files: scanDirFiles(folderPath)
        });
    }
    for (var j = 0; j < loose.length; j++) {
        entries.push({
            type: "file",
            name: loose[j],
            path: dirPath + "/" + loose[j]
        });
    }
    return entries;
}

function sendInitData(includeState) {
    baseDir = getPatcherDir();
    if (!baseDir) {
        outlet(1, "init_data", JSON.stringify({
            dirPath: "",
            statusMsg: "Save the patcher first",
            ratings: {},
            entries: [],
            state: null
        }));
        return;
    }

    dirPath = baseDir + "/" + DIR_NAME;
    fxDirPath = baseDir + "/" + FX_DIR_NAME;
    loadRatings();
    if (includeState || !savedState) loadState();

    var entries = buildEntries();
    var payload = {
        dirPath: dirPath,
        statusMsg: entries.length === 0 ? ("No files in " + DIR_NAME) : "",
        ratings: ratings,
        entries: entries,
        state: includeState ? savedState : null
    };
    outlet(1, "init_data", JSON.stringify(payload));
}

// ---------- Messages from Max / jweb ----------

function loadbang() {
    baseDir = getPatcherDir();
    if (baseDir) {
        outlet(1, "readfile", baseDir + "/" + HTML_FILE);
    } else {
        outlet(1, "readfile", HTML_FILE);
    }
    post("file_list (jweb): up/down select, return load, 1-5 rate, 0 clear, esc filter\n");
}

function bang() {
    sendInitData(false);
}

// Sent by jweb when the page finishes loading
function ready() {
    sendInitData(true);
}

function request_refresh(fromLoad) {
    sendInitData(Boolean(Number(fromLoad)));
}

// Emits the chosen .maxpat path out of outlet 0 (to load in the patcher)
function select_file(path) {
    if (!path) return;
    outlet(0, String(path));
}

function save_ratings(jsonStr) {
    if (!baseDir) baseDir = getPatcherDir();
    if (!baseDir) return;
    dirPath = baseDir + "/" + DIR_NAME;
    trackedRatingsPath = baseDir + "/" + TRACKED_RATING_FILE;
    legacyRatingsPath = dirPath + "/" + LEGACY_RATING_FILE;
    ratings = {};
    parseRatingsText(String(jsonStr), ratings);
    writeAllRatings();
}

function save_state(jsonStr) {
    if (!baseDir) baseDir = getPatcherDir();
    if (!baseDir) return;
    dirPath = baseDir + "/" + DIR_NAME;
    statePath = dirPath + "/" + STATE_FILE;
    try {
        var o = JSON.parse(String(jsonStr));
        savedState = o;
        writeTextFile(statePath, JSON.stringify(o, null, 2) + "\n");
    } catch (e) {}
}

function request_effect_docs(baseKey) {
    if (!baseKey) return;
    if (!baseDir) baseDir = getPatcherDir();
    if (!baseDir) return;
    fxDirPath = baseDir + "/" + FX_DIR_NAME;
    var key = String(baseKey);
    var paramPath = fxDirPath + "/" + key + "_paraminfo.txt";
    var codePath = fxDirPath + "/" + key + ".txt";
    var paramTxt = readTextFile(paramPath);
    var codeTxt = readTextFile(codePath);
    outlet(1, "effect_docs", key, paramTxt, codeTxt);
}

// Forward control messages to jweb
function scroll(v) { outlet(1, "scroll", v); }
function expandall() { outlet(1, "expandall"); }
function collapseall() { outlet(1, "collapseall"); }
function toggle(name) { outlet(1, "toggle", String(name)); }
function filter(v) { outlet(1, "filter", v); }
function sort(v) { outlet(1, "sort", v); }
function rating(path, n) { outlet(1, "rating", String(path), n); }
function loaded(path) {
    if (path === undefined || path === null) outlet(1, "loaded", "");
    else outlet(1, "loaded", String(path));
}
function savestate() { outlet(1, "savestate"); }
function keydebug(v) { outlet(1, "keydebug", v); }
function kbd(v) { outlet(1, "kbd", v); }

// Ignore jweb's automatic page-load notifications ("url ...", "title ...", "onloadstart ...", "onloadend ...")
function url() {}
function title() {}
function onloadstart() {}
function onloadend() {}
function anything() {}
