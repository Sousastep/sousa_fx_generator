// file_list.js — v8ui
// Lists files in ./generated_maxpat/ (relative to the host patcher),
// scrolls, and outputs the full path of the clicked file.

mgraphics.init();
mgraphics.relative_coords = 0;
mgraphics.autofill = 0;

inlets = 1;
outlets = 1;

// ---------- settings ----------
var DIR_NAME   = "generated_maxpat";
var ROW_H      = 20;
var PAD        = 8;
var BAR_W      = 10;
var FONT       = "Arial";
var FONT_SIZE  = 12;
var WHEEL_SPEED = 1;   // multiply; use a negative number to flip scroll direction

// ---------- state ----------
var thisPatcher = this.patcher;
var files = [];
var dirPath = "";
var statusMsg = "";
var scrollY = 0;
var hover = -1;
var selected = -1;
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

function refresh() {
    files = [];
    selected = -1;
    hover = -1;
    scrollY = 0;

    var base = getPatcherDir();
    if (base === null) {
        statusMsg = "Save the patcher first";
        dirPath = "";
        mgraphics.redraw();
        return;
    }

    dirPath = base + "/" + DIR_NAME;
    var f = new Folder(dirPath);
    while (!f.end) {
        var name = f.filename;
        if (name && name.charAt(0) !== ".") files.push(name);
        f.next();
    }
    f.close();

    files.sort(function (a, b) {
        return a.toLowerCase() < b.toLowerCase() ? -1 : 1;
    });

    statusMsg = files.length ? "" : "No files in " + DIR_NAME;
    clampScroll();
    mgraphics.redraw();
}

function bang() { refresh(); }

function loadbang() { refresh(); }

// ---------- geometry helpers ----------
function contentH() { return files.length * ROW_H; }
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
    return (i >= 0 && i < files.length) ? i : -1;
}

function fullPath(i) {
    return dirPath + "/" + files[i];
}

// ---------- drawing ----------
function paint() {
    var g = mgraphics;

    // background
    g.set_source_rgba(0.13, 0.13, 0.14, 1);
    g.rectangle(0, 0, w, h);
    g.fill();

    g.select_font_face(FONT);
    g.set_font_size(FONT_SIZE);

    if (files.length === 0) {
        g.set_source_rgba(0.6, 0.6, 0.6, 1);
        g.move_to(PAD, 20);
        g.show_text(statusMsg || "Empty");
        return;
    }

    var first = Math.max(0, Math.floor(scrollY / ROW_H));
    var last  = Math.min(files.length - 1, Math.ceil((scrollY + h) / ROW_H));

    for (var i = first; i <= last; i++) {
        var y = i * ROW_H - scrollY;

        if (i === selected) {
            g.set_source_rgba(0.25, 0.45, 0.8, 1);
            g.rectangle(0, y, w, ROW_H);
            g.fill();
        } else if (i === hover) {
            g.set_source_rgba(1, 1, 1, 0.08);
            g.rectangle(0, y, w, ROW_H);
            g.fill();
        }

        g.set_source_rgba(0.92, 0.92, 0.92, 1);
        g.move_to(PAD, y + ROW_H / 2 + FONT_SIZE * 0.35);
        g.show_text(files[i]);
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
    if (i >= 0) {
        selected = i;
        outlet(0, fullPath(i));
    }
    mgraphics.redraw();
}

function ondrag(x, y, but) {
    if (!but) { draggingBar = false; mgraphics.redraw(); return; }
    if (draggingBar) setScrollFromThumb(y - dragOffset);
}

function onidle(x, y) {
    draggingBar = false;
    var i = (needsBar() && x >= w - BAR_W) ? -1 : rowAt(y);
    if (i !== hover) {
        hover = i;
        mgraphics.redraw();
    }
}

function onidleout() {
    hover = -1;
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