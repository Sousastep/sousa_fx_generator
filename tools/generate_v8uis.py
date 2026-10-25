#!/usr/bin/env python3
"""
Generate Max ``v8ui`` JavaScript UI scripts (``.js``) from RNBO ``codebox~``
effect sources.

Each effect in ``generated_fx/<category>/<name>.txt`` becomes
``generated_v8ui/<category>/<name>.js`` mirroring the directory structure.

The generated ``v8ui`` script displays:
  - The effect name centered in a header above the sliders, plus a clickable
    info (``i``) icon in the header that pops up a Max text window displaying
    the effect's ``<name>_paraminfo.txt`` documentation. The title can be
    overridden per instance with the v8ui's ``jsarguments`` attribute.
  - One horizontal slider per row, with the parameter name left-aligned
    inside the slider and the current parameter value right-aligned inside
    the slider.
  - Each parameter change outputs ``scripting_name/parameter_name parameter_value``
    (or ``parameter_name parameter_value`` if ``SCRIPTING_NAME`` is left empty),
    where ``SCRIPTING_NAME`` is a top-level field in the JS file meant to be
    filled in manually by the user.

Usage::

    python3 tools/generate_v8uis.py                 # all effects -> generated_v8ui/
    python3 tools/generate_v8uis.py --outdir build  # custom destination
    python3 tools/generate_v8uis.py --only 01_harmonic_isolator
    python3 tools/generate_v8uis.py --list          # dry run, list discovered effects
"""

from __future__ import annotations

import argparse
import json
import os
import sys

# Ensure sibling imports work when invoked as `python3 tools/generate_v8uis.py`
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from generate_maxpats import Effect, discover_effects, parse_effect  # noqa: E402


V8UI_TEMPLATE = """\
/*
    {effect_name}.js
    v8ui script generated from {source_rel}

    Set the scripting name from the patcher by sending a message to inlet 1:
        scripting_name my_fx
    All parameters share it, and every parameter change then outputs
        my_fx/<param_name> <param_value>
    Until a name is received (or if it is set to an empty symbol) the output is
    just <param_name> <param_value>.

    Click the "i" icon in the top-right of the header to pop up a Max text
    window displaying {paraminfo_filename}.

    The header title defaults to the effect name and can be overridden with the
    v8ui's jsarguments attribute, e.g. in the object box
        v8ui @filename foo.js @jsarguments 1 My Title
    or via Inspector > javascript arguments. The arguments are joined with
    spaces to form the title; a leading object/script name ("v8ui", "foo.js",
    ...) is ignored so both conventions work.
*/

autowatch = 1;
inlets  = 1;
outlets = 1;

// Routing prefix, set at runtime with:  scripting_name my_fx
var SCRIPTING_NAME = "";

// Title shown in the header (and in the paraminfo window title). Overridden by
// the v8ui's jsarguments attribute when arguments are present.
var DEFAULT_EFFECT_NAME = {effect_name_json};
var EFFECT_NAME = resolveEffectName();
var PARAMINFO_PATH = {paraminfo_rel_json};
var PARAMINFO_FILENAME = {paraminfo_filename_json};
var PARAMINFO_TEXT = {paraminfo_text_json};

var PARAMS = {params_json};

var NUM_SLIDERS = PARAMS.length;
var values = [];
var defaults = [];
for (var i = 0; i < NUM_SLIDERS; i++) {{
    values.push(PARAMS[i].def);
    defaults.push(PARAMS[i].def);
}}

var activeSlider = -1;
var infoHighlight = false;
var infoTextObj = null;

// ---------------------------------------------------------------
// Title
// ---------------------------------------------------------------

// jsarguments[0] may hold the object or script name instead of a title
// (the v8 object puts the filename there), so drop a leading token that
// looks like one and join whatever is left with spaces.
function looksLikeObjectName(s) {{
    var t = String(s).toLowerCase();
    return t === "v8ui" || t === "v8" || t === "js" || t === "jsui" || /[.]js$/.test(t);
}}

function resolveEffectName() {{
    var args = (typeof jsarguments !== "undefined" && jsarguments) ? jsarguments : [];
    var parts = [];
    for (var i = 0; i < args.length; i++) {{
        var s = String(args[i]);
        if (!s.length) continue;
        if (parts.length === 0 && looksLikeObjectName(s)) continue;
        parts.push(s);
    }}
    return parts.length > 0 ? parts.join(" ") : DEFAULT_EFFECT_NAME;
}}

// Pick up jsarguments even if the attribute was set after the script loaded.
function loadbang() {{
    EFFECT_NAME = resolveEffectName();
    mgraphics.redraw();
}}

mgraphics.init();
mgraphics.relative_coords = 0;
mgraphics.autofill = 0;

// ---------------------------------------------------------------
// Paraminfo popup window
// ---------------------------------------------------------------

function findParaminfoFilePath() {{
    try {{
        var p = this.patcher;
        while (p && !p.filepath && p.parentpatcher) {{
            p = p.parentpatcher;
        }}
        var fp = p ? p.filepath : "";
        if (fp) {{
            var dir = fp.substring(0, fp.lastIndexOf("/"));
            var candidates = [
                dir + "/" + PARAMINFO_PATH,
                dir + "/../" + PARAMINFO_PATH,
                dir + "/../../" + PARAMINFO_PATH,
                PARAMINFO_PATH,
                PARAMINFO_FILENAME
            ];
            for (var i = 0; i < candidates.length; i++) {{
                var f = new File(candidates[i], "read");
                if (f.isopen) {{
                    var full = (f.foldername ? (f.foldername + "/" + f.filename) : candidates[i]);
                    f.close();
                    return full;
                }}
            }}
        }}
    }} catch (e) {{}}
    return "";
}}

function populateTextObj(textObj) {{
    textObj.message("clear");
    textObj.message("settitle", EFFECT_NAME + " — Parameter Info");
    var filePath = findParaminfoFilePath();
    if (filePath) {{
        textObj.message("read", filePath);
        return;
    }}
    var lines = String(PARAMINFO_TEXT || "").split(/\\r?\\n/);
    for (var i = 0; i < lines.length; i++) {{
        if (lines[i].length > 0) {{
            textObj.message("symbol", lines[i]);
        }}
        textObj.message("cr");
    }}
}}

function showParaminfoWindow() {{
    try {{
        var p = this.patcher;
        if (p) {{
            var vname = "__paraminfo_text_" + EFFECT_NAME.replace(/[^A-Za-z0-9_]/g, "_");
            if (!infoTextObj || !infoTextObj.valid) {{
                var existing = p.getnamed ? p.getnamed(vname) : null;
                if (existing && existing.valid) {{
                    infoTextObj = existing;
                }} else if (p.newdefault) {{
                    var bx = (this.box && this.box.rect) ? this.box.rect[0] : 20;
                    var by = (this.box && this.box.rect) ? this.box.rect[1] : 20;
                    infoTextObj = p.newdefault(bx, by, "text");
                    if (infoTextObj) {{
                        infoTextObj.hidden = 1;
                        infoTextObj.ignoreclick = 1;
                        infoTextObj.varname = vname;
                    }}
                }}
            }}
            if (infoTextObj && infoTextObj.valid) {{
                populateTextObj(infoTextObj);
                infoTextObj.message("open");
                return;
            }}
        }}
    }} catch (e) {{}}
    if (typeof post === "function") {{
        post("=== " + EFFECT_NAME + " Parameter Info ===\\n" + PARAMINFO_TEXT + "\\n");
    }}
}}

// Allow opening paraminfo window via a Max message as well
function info() {{
    showParaminfoWindow();
}}

// ---------------------------------------------------------------
// Value helpers
// ---------------------------------------------------------------

function clampParam(index, v) {{
    var p = PARAMS[index];
    v = Number(v);
    if (isNaN(v)) return p.def;
    if (v < p.min) v = p.min;
    if (v > p.max) v = p.max;
    if (p.steps && p.steps > 1) {{
        var stepSize = (p.max - p.min) / (p.steps - 1);
        if (stepSize > 0) {{
            v = p.min + Math.round((v - p.min) / stepSize) * stepSize;
        }}
    }}
    return v;
}}

function toNorm(index, v) {{
    var p = PARAMS[index];
    var span = p.max - p.min;
    if (span <= 0) return 0;
    var n = Math.min(1, Math.max(0, (v - p.min) / span));
    // RNBO param taper: value = min + span * norm^exponent
    if (p.exponent && p.exponent !== 1) n = Math.pow(n, 1 / p.exponent);
    return n;
}}

function fromNorm(index, n) {{
    var p = PARAMS[index];
    n = Math.min(1, Math.max(0, Number(n) || 0));
    if (p.exponent && p.exponent !== 1) n = Math.pow(n, p.exponent);
    return clampParam(index, p.min + n * (p.max - p.min));
}}

function formatValue(index, v) {{
    var p = PARAMS[index];
    if (p.enumValues && p.enumValues.length > 0) {{
        var idx = Math.round(v);
        if (idx >= 0 && idx < p.enumValues.length) {{
            return idx + " (" + p.enumValues[idx] + ")";
        }}
    }}
    if (p.steps && p.steps > 1 && Math.abs(v - Math.round(v)) < 1e-6) {{
        return String(Math.round(v));
    }}
    var span = Math.abs(p.max - p.min);
    if (span >= 100) return v.toFixed(1);
    if (span >= 10) return v.toFixed(2);
    return v.toFixed(3);
}}

function emitParam(index) {{
    var p = PARAMS[index];
    var addr = SCRIPTING_NAME ? (SCRIPTING_NAME + "/" + p.name) : p.name;
    outlet(0, addr, values[index]);
}}

function outputAll() {{
    for (var i = 0; i < NUM_SLIDERS; i++) {{
        emitParam(i);
    }}
}}

// ---------------------------------------------------------------
// pattr hooks
// ---------------------------------------------------------------

function getvalueof() {{
    return values.slice();
}}

function setvalueof() {{
    var a = arrayfromargs(arguments);
    for (var i = 0; i < NUM_SLIDERS && i < a.length; i++) {{
        values[i] = clampParam(i, a[i]);
    }}
    mgraphics.redraw();
    outputAll();
}}

// ---------------------------------------------------------------
// Messages from Max
// ---------------------------------------------------------------

// "scripting_name my_fx" -> prefix every subsequent parameter output.
// A bare "scripting_name" (or an empty symbol) clears the prefix.
function scripting_name() {{
    var a = arrayfromargs(arguments);
    SCRIPTING_NAME = a.length > 0 ? String(a[0]) : "";
}}

function param(indexOrName, value) {{
    var idx = -1;
    if (typeof indexOrName === "number") {{
        idx = Math.floor(indexOrName);
    }} else {{
        var nameStr = String(indexOrName);
        for (var i = 0; i < NUM_SLIDERS; i++) {{
            if (PARAMS[i].name === nameStr) {{
                idx = i;
                break;
            }}
        }}
    }}
    if (idx < 0 || idx >= NUM_SLIDERS) return;
    values[idx] = clampParam(idx, value);
    mgraphics.redraw();
    emitParam(idx);
    notifyclients();
}}

function reset() {{
    for (var i = 0; i < NUM_SLIDERS; i++) {{
        values[i] = defaults[i];
    }}
    mgraphics.redraw();
    outputAll();
    notifyclients();
}}

function bang() {{
    outputAll();
}}

function anything() {{
    var a = arrayfromargs(arguments);
    if (a.length >= 1) {{
        param(messagename, a[0]);
    }}
}}

// ---------------------------------------------------------------
// Layout & Mouse interaction
// ---------------------------------------------------------------

var PAD_X = 6;
var PAD_Y = 6;
var HEADER_H = 22;
var ROW_GAP = 3;
var MAX_ROW_H = 26;

function computeLayout(w, h) {{
    var headerH = Math.min(HEADER_H, Math.max(16, h * 0.18));
    var availH = Math.max(1, h - headerH - PAD_Y * 2);
    var n = Math.max(1, NUM_SLIDERS);
    var gap = n > 1 ? ROW_GAP : 0;
    var rowH = (availH - gap * (n - 1)) / n;
    if (rowH < 6) {{
        gap = 1;
        rowH = Math.max(4, (availH - gap * (n - 1)) / n);
    }} else if (rowH > MAX_ROW_H) {{
        rowH = MAX_ROW_H;
    }}
    var iconR = Math.max(5.5, Math.min(8, headerH * 0.34));
    var iconCx = Math.max(iconR + 4, w - PAD_X - iconR - 2);
    var iconCy = headerH * 0.5;
    return {{
        headerH: headerH,
        iconCx: iconCx,
        iconCy: iconCy,
        iconR: iconR,
        x: PAD_X,
        w: Math.max(20, w - PAD_X * 2),
        y0: headerH + PAD_Y,
        rowH: rowH,
        stepY: rowH + gap
    }};
}}

function isInfoIconHit(x, y) {{
    var lay = computeLayout(mgraphics.size[0], mgraphics.size[1]);
    if (y < 0 || y > lay.headerH) return false;
    var dx = x - lay.iconCx;
    var dy = y - lay.iconCy;
    var hitR = lay.iconR + 4;
    return (dx * dx + dy * dy) <= (hitR * hitR);
}}

function sliderFromY(y) {{
    if (NUM_SLIDERS <= 0) return -1;
    var lay = computeLayout(mgraphics.size[0], mgraphics.size[1]);
    var relY = y - lay.y0;
    if (relY < 0) return -1;
    var idx = Math.floor(relY / lay.stepY);
    if (idx < 0) return 0;
    if (idx >= NUM_SLIDERS) return NUM_SLIDERS - 1;
    return idx;
}}

function setFromMouse(index, x) {{
    if (index < 0 || index >= NUM_SLIDERS) return;
    var lay = computeLayout(mgraphics.size[0], mgraphics.size[1]);
    var norm = (x - lay.x) / lay.w;
    var newVal = fromNorm(index, norm);
    values[index] = newVal;
    mgraphics.redraw();
    emitParam(index);
    notifyclients();
}}

function onclick(x, y, but, cmd, shift, capslock, option, ctrl) {{
    if (isInfoIconHit(x, y)) {{
        activeSlider = -1;
        infoHighlight = true;
        mgraphics.redraw();
        showParaminfoWindow();
        return;
    }}
    infoHighlight = false;
    var idx = sliderFromY(y);
    if (idx < 0) {{
        activeSlider = -1;
        return;
    }}
    activeSlider = idx;
    if (option) {{
        // Option/Alt-click resets this slider to its default
        values[idx] = defaults[idx];
        mgraphics.redraw();
        emitParam(idx);
        notifyclients();
    }} else {{
        setFromMouse(activeSlider, x);
    }}
}}

function ondrag(x, y, but) {{
    if (!but) {{
        activeSlider = -1;
        infoHighlight = false;
        mgraphics.redraw();
        return;
    }}
    if (activeSlider >= 0) {{
        setFromMouse(activeSlider, x);
    }}
}}

function ondblclick(x, y) {{
    if (isInfoIconHit(x, y)) {{
        showParaminfoWindow();
        return;
    }}
    var idx = sliderFromY(y);
    if (idx >= 0 && idx < NUM_SLIDERS) {{
        values[idx] = defaults[idx];
        mgraphics.redraw();
        emitParam(idx);
        notifyclients();
    }}
}}

// ---------------------------------------------------------------
// Drawing
// ---------------------------------------------------------------

function drawInfoIcon(lay) {{
    var cx = lay.iconCx;
    var cy = lay.iconCy;
    var r = lay.iconR;

    // Button circle
    if (infoHighlight) {{
        mgraphics.set_source_rgba(0.95, 0.60, 0.18, 0.95);
    }} else {{
        mgraphics.set_source_rgba(0.26, 0.56, 0.78, 0.85);
    }}
    mgraphics.arc(cx, cy, r, 0, Math.PI * 2);
    mgraphics.fill();

    // Circle border
    mgraphics.set_line_width(1);
    mgraphics.set_source_rgba(0.75, 0.85, 0.95, 0.9);
    mgraphics.arc(cx, cy, r, 0, Math.PI * 2);
    mgraphics.stroke();

    // "i" glyph centered in circle
    var iFontSize = Math.max(8, Math.round(r * 1.35));
    mgraphics.set_font_size(iFontSize);
    mgraphics.set_source_rgba(1.0, 1.0, 1.0, 0.98);
    var iExt = mgraphics.text_measure("i");
    var iW = iExt && iExt.length ? iExt[0] : (iFontSize * 0.35);
    mgraphics.move_to(cx - iW * 0.5, cy + iFontSize * 0.36);
    mgraphics.show_text("i");
}}

function paint() {{
    var w = mgraphics.size[0];
    var h = mgraphics.size[1];
    var lay = computeLayout(w, h);

    // Background
    mgraphics.set_source_rgba(0.11, 0.11, 0.13, 1.0);
    mgraphics.rectangle(0, 0, w, h);
    mgraphics.fill();

    // Header background
    mgraphics.set_source_rgba(0.16, 0.16, 0.19, 1.0);
    mgraphics.rectangle(0, 0, w, lay.headerH);
    mgraphics.fill();

    // Effect name (centered in header, avoiding the info icon on the right)
    mgraphics.select_font_face("Lato");
    var headerFontSize = Math.min(12, Math.max(9, lay.headerH * 0.55));
    mgraphics.set_font_size(headerFontSize);
    var hdrExt = mgraphics.text_measure(EFFECT_NAME);
    var hdrW = hdrExt && hdrExt.length ? hdrExt[0] : (EFFECT_NAME.length * headerFontSize * 0.55);
    var maxHdrRight = lay.iconCx - lay.iconR - 6;
    var hdrX = (w - hdrW) * 0.5;
    if (hdrX + hdrW > maxHdrRight) {{
        hdrX = Math.max(PAD_X, maxHdrRight - hdrW);
    }} else {{
        hdrX = Math.max(PAD_X, hdrX);
    }}
    var hdrY = lay.headerH * 0.5 + headerFontSize * 0.36;
    mgraphics.set_source_rgba(0.92, 0.94, 0.98, 1.0);
    mgraphics.move_to(hdrX, hdrY);
    mgraphics.show_text(EFFECT_NAME);

    // Info icon in header
    drawInfoIcon(lay);

    if (NUM_SLIDERS === 0) {{
        mgraphics.set_font_size(10);
        mgraphics.set_source_rgba(0.6, 0.6, 0.65, 1.0);
        mgraphics.move_to(PAD_X, lay.y0 + 14);
        mgraphics.show_text("(no parameters)");
        return;
    }}

    var fontSize = Math.min(11, Math.max(8, lay.rowH * 0.58));
    mgraphics.set_font_size(fontSize);

    for (var i = 0; i < NUM_SLIDERS; i++) {{
        var p = PARAMS[i];
        var ry = lay.y0 + i * lay.stepY;
        var norm = toNorm(i, values[i]);
        var fillW = norm * lay.w;

        // Track background
        mgraphics.set_source_rgba(0.19, 0.20, 0.23, 1.0);
        mgraphics.rectangle(lay.x, ry, lay.w, lay.rowH);
        mgraphics.fill();

        // Slider fill bar
        if (i === activeSlider) {{
            mgraphics.set_source_rgba(0.95, 0.60, 0.18, 0.88);
        }} else {{
            mgraphics.set_source_rgba(0.22, 0.56, 0.78, 0.82);
        }}
        if (fillW > 0.5) {{
            mgraphics.rectangle(lay.x, ry, fillW, lay.rowH);
            mgraphics.fill();
        }}

        // Subtle border
        mgraphics.set_line_width(1);
        mgraphics.set_source_rgba(0.28, 0.30, 0.35, 1.0);
        mgraphics.rectangle(lay.x + 0.5, ry + 0.5, lay.w - 1, lay.rowH - 1);
        mgraphics.stroke();

        var textY = ry + lay.rowH * 0.5 + fontSize * 0.36;

        // Parameter name (left-aligned inside slider)
        mgraphics.set_source_rgba(0.96, 0.97, 0.99, 0.95);
        mgraphics.move_to(lay.x + 6, textY);
        mgraphics.show_text(p.name);

        // Parameter value (right-aligned inside slider)
        var valStr = formatValue(i, values[i]);
        var valExt = mgraphics.text_measure(valStr);
        var valW = valExt && valExt.length ? valExt[0] : (valStr.length * fontSize * 0.55);
        mgraphics.move_to(lay.x + lay.w - valW - 6, textY);
        mgraphics.show_text(valStr);
    }}
}}

function onresize() {{
    mgraphics.redraw();
}}
"""


def build_v8ui_script(effect: Effect, paraminfo_rel: str) -> str:
    params_data = []
    for p in effect.params:
        entry: dict[str, object] = {
            "name": p.name,
            "min": p.minimum,
            "max": p.maximum,
            "def": p.default,
        }
        if p.steps is not None:
            entry["steps"] = p.steps
        if p.enum_values:
            entry["enumValues"] = p.enum_values
        if p.exponent != 1.0:
            entry["exponent"] = p.exponent
        params_data.append(entry)

    paraminfo_filename = f"{effect.name}_paraminfo.txt"

    return V8UI_TEMPLATE.format(
        effect_name=effect.name,
        source_rel=effect.source.replace(os.sep, "/"),
        paraminfo_filename=paraminfo_filename,
        effect_name_json=json.dumps(effect.name),
        paraminfo_rel_json=json.dumps(paraminfo_rel.replace(os.sep, "/")),
        paraminfo_filename_json=json.dumps(paraminfo_filename),
        paraminfo_text_json=json.dumps(effect.paraminfo),
        params_json=json.dumps(params_data, indent=4),
    )


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(
        description=__doc__,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument("--src", default="generated_fx", help="root of the effect .txt files")
    parser.add_argument("--outdir", default="generated_v8ui", help="destination directory")
    parser.add_argument("--only", nargs="*", default=None, help="only generate these effect names")
    parser.add_argument("--list", action="store_true", help="list discovered effects and exit")
    args = parser.parse_args(argv)

    if not os.path.isdir(args.src):
        parser.error(f"source directory not found: {args.src}")

    found = discover_effects(args.src)
    if args.only:
        wanted = set(args.only)
        found = [e for e in found if os.path.splitext(os.path.basename(e[0]))[0] in wanted]

    if not found:
        print("No effects found.", file=sys.stderr)
        return 1

    if args.list:
        for txt, _, rel_dir in found:
            name = os.path.splitext(os.path.basename(txt))[0]
            print(os.path.join(rel_dir, name) if rel_dir else name)
        return 0

    os.makedirs(args.outdir, exist_ok=True)

    count = 0
    for txt, paraminfo, rel_dir in found:
        effect = parse_effect(txt, paraminfo)
        if effect.n_in < 1 or effect.n_out < 1:
            print(
                f"  ! {effect.name}: detected {effect.n_in} inlets / {effect.n_out} outlets, skipping",
                file=sys.stderr,
            )
            continue
        script = build_v8ui_script(effect, paraminfo)
        out_dir = os.path.join(args.outdir, rel_dir)
        os.makedirs(out_dir, exist_ok=True)
        out_path = os.path.join(out_dir, f"{effect.name}.js")
        with open(out_path, "w", encoding="utf-8") as fh:
            fh.write(script)
        count += 1
        print(
            f"  {effect.name}: {len(effect.params)} params -> {out_path}"
        )

    print(f"\nWrote {count} v8ui script(s) to {args.outdir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
