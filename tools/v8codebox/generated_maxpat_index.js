/* Max 9 v8.codebox: map an integer onto a generated .maxpat file path.
 *
 * 1. Paste this entire script into a v8.codebox in a Max patch that sits in
 *    this repository's root (the folder that holds generated_maxpat/).
 * 2. Send an integer to the box's single inlet. Outlet 0 then emits the full,
 *    absolute path of the corresponding .maxpat file.
 *
 * Indexing is 0-based by default: 0 -> the first name in a case-insensitive
 * sort of generated_maxpat/*.maxpat, 1 -> the second, and so on. Order does not
 * matter: any integer works because out-of-range values wrap modulo the file
 * count, so every integer still selects a real file. Set FIRST_INDEX to 1
 * below for one-based numbering.
 *
 * The directory is re-scanned on every input, so files added or removed while
 * Max is open are picked up without re-pasting the script. Subfolders and
 * non-.maxpat files are ignored.
 *
 * Extra inputs: `bang` re-emits the last path, `count` emits how many .maxpat
 * files were found.
 *
 * Uses Max's File/Folder/Patcher APIs, not Node's fs or npm packages.
 */

var DIRECTORY = "generated_maxpat"; // Relative to this patch, or an absolute Max path.
var FIRST_INDEX = 0;                // 0 for zero-based indices, 1 for one-based.
var EXTENSION = ".maxpat";          // Case-insensitive extension filter.

var boxContext = this;              // jsthis: gives access to this.patcher.
var lastIndex = FIRST_INDEX;        // Index remembered by `bang`.

// An integer in the inlet (or the `int` message) -> emit one file path.
function msg_int(value) {
    var index = asInteger(value);
    if (index === null) {
        error("maxpat index: not an integer: " + value + "\n");
        return;
    }
    var found = collectPatchers();
    if (!found.files.length) {
        error("maxpat index: no " + EXTENSION + " files found (looked in " +
            found.directory + ").\n");
        return;
    }
    lastIndex = index;
    outlet(0, found.files[wrap(index - FIRST_INDEX, found.files.length)]);
}

// A float in the inlet rounds to the nearest integer, so either input works.
function msg_float(value) {
    msg_int(Math.round(value));
}

// Re-emit the path chosen by the most recent integer input.
function bang() {
    msg_int(lastIndex);
}

// Emit how many .maxpat files were found.
function count() {
    outlet(0, collectPatchers().files.length);
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// Scan the first candidate directory that actually contains matching files.
function collectPatchers() {
    var candidates = directoryCandidates();
    for (var i = 0; i < candidates.length; i++) {
        var found = scanDirectory(candidates[i]);
        if (found.files.length) return found;
    }
    return { directory: candidates[0], files: [] };
}

// Candidate directories, most specific first: an absolute DIRECTORY, then this
// patch's own folder joined with DIRECTORY, then DIRECTORY as written so Max
// can resolve it through the search path.
function directoryCandidates() {
    if (isAbsolute(DIRECTORY)) return unique([DIRECTORY]);
    var candidates = [];
    var folder = patchFolder();
    if (folder) candidates.push(joinPath(folder, DIRECTORY));
    candidates.push(DIRECTORY);
    return unique(candidates);
}

// List generator_maxpat/*.maxpat as absolute paths, sorted by name.
function scanDirectory(directory) {
    var files = [];
    var resolved = directory;
    var folder = null;
    try {
        folder = new Folder(directory);
        // pathname is the full resolved path Max found for the folder.
        resolved = folder.pathname || directory;
        while (!folder.end) {
            if (folder.filetype !== "fold" && hasExtension(folder.filename, EXTENSION)) {
                files.push(joinPath(resolved, folder.filename));
            }
            folder.next();
        }
    } catch (ignored) {
        files = [];
    } finally {
        if (folder) {
            try { folder.close(); } catch (ignored) {}
        }
    }
    files.sort(compareNames);
    return { directory: resolved, files: files };
}

// The folder containing this patch, derived from this.patcher.filepath.
function patchFolder() {
    try {
        var patcher = boxContext && boxContext.patcher;
        var filepath = patcher && patcher.filepath;
        if (typeof filepath === "string" && filepath.length) {
            return splitPath(filepath).directory;
        }
    } catch (ignored) {}
    return null;
}

function splitPath(path) {
    var normalized = String(path).replace(/[\\]/g, "/");
    var slash = normalized.lastIndexOf("/");
    if (slash < 0) return { directory: normalized, name: "" };
    return {
        directory: slash === 0 ? "/" : normalized.slice(0, slash),
        name: normalized.slice(slash + 1)
    };
}

function isAbsolute(path) {
    var p = String(path);
    return p.charAt(0) === "/" || /^[A-Za-z]:[\/\\]/.test(p);
}

function joinPath(directory, name) {
    var base = String(directory).replace(/[\/\\]+$/, "");
    if (!base) return name;
    return base + "/" + name;
}

function hasExtension(name, extension) {
    var lower = String(name).toLowerCase();
    var suffix = String(extension).toLowerCase();
    return lower.length >= suffix.length &&
        lower.slice(lower.length - suffix.length) === suffix;
}

// Case-insensitive, with a case-sensitive tiebreak so the order is stable.
function compareNames(a, b) {
    var x = a.toLowerCase();
    var y = b.toLowerCase();
    if (x < y) return -1;
    if (x > y) return 1;
    return a < b ? -1 : (a > b ? 1 : 0);
}

function wrap(value, modulus) {
    return ((value % modulus) + modulus) % modulus;
}

function asInteger(value) {
    var n = typeof value === "number" ? value : Number(String(value).trim());
    if (typeof n !== "number" || !isFinite(n) || Math.floor(n) !== n) return null;
    return n;
}

function unique(values) {
    var out = [];
    for (var i = 0; i < values.length; i++) {
        if (values[i] && out.indexOf(values[i]) < 0) out.push(values[i]);
    }
    return out;
}
