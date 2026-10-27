#!/usr/bin/env python3
"""
Generate Max demo patchers (``.maxpat``) from RNBO ``codebox~`` effect sources.

Each effect lives as two files in ``generated_fx/<category>/``::

    <name>.txt           the RNBO codebox~ source (verbatim)
    <name>_paraminfo.txt human readable parameter documentation

Output mirrors that layout, so ``generated_fx/<category>/<name>.txt`` becomes
``generated_maxpat/<category>/<name>.maxpat``.

The nested ``rnbo`` patcher is also written on its own as an RNBO abstraction,
``generated_rnbopat/<category>/ai.<name>.rnbopat``, so the effect can be used
inside other RNBO patchers.

The generated ``.maxpat`` mirrors the structure of the hand-made examples in
``generated_maxpat/``: a top level demo patcher that wires ``receive~ inN`` /
``send~ outN`` pairs into a single embedded ``rnbo~`` object, whose nested
``rnbo`` patcher holds the ``codebox~`` plus per-parameter
``comment`` / ``param`` / ``number`` / ``setparam`` controls.

Usage::

    python3 tools/generate_maxpats.py                # all effects -> generated_maxpat/
    python3 tools/generate_maxpats.py --outdir build # custom destination
    python3 tools/generate_maxpats.py --rnbopat-outdir build_rnbo  # custom .rnbopat destination
    python3 tools/generate_maxpats.py --only 01_harmonic_isolator 12_adaa_chebyshev_wavefolder
    python3 tools/generate_maxpats.py --list         # dry run, list discovered effects
"""

from __future__ import annotations

import argparse
import glob
import json
import math
import os
import re
import sys
import uuid
from dataclasses import dataclass, field
from typing import Any

# --------------------------------------------------------------------------- #
# Constants transcribed from the reference patchers
# --------------------------------------------------------------------------- #

APP_VERSION = {
    "major": 9,
    "minor": 1,
    "revision": 5,
    "architecture": "x64",
    "modernui": 1,
}
RNBO_VERSION = "1.4.5"
DEFAULT_FONT = "Lato"
CODEBOX_VERSION_ID = 527839773
PARAM_VERSION_ID = -1093178486
SETPARAM_VERSION_ID = 1197449671
IN_VERSION_ID = -1654556303
OUT_VERSION_ID = 1989326771

# Geometry (matches the reference layouts).
CODEBOX_RECT = [30.0, 110.0, 620.0, 360.0]
IO_ROW_TOP = 70.0
IO_ROW_BOTTOM = 520.0
IO_BOX_W = 70.0
IO_BOX_H = 23.0
IO_X_MIN = 30.0
IO_X_MAX = 605.0
PARAM_X0 = 700.0
PARAM_COL_GAP = 24.0
PARAM_ROW_STEP = 115.0
PARAM_Y0 = 65.0
PARAM_BOX_W = 175.0
NUMBOX_W = 100.0
PARAMINFO_RECT_X = 30.0
PARAMINFO_RECT_Y = 553.0
PARAMINFO_RECT_W = 577.0
LINE_HEIGHT = 14.87

TOP_RECEIVE_Y = 66.0
TOP_SEND_Y = 158.0
TOP_RECEIVE_W = 74.0
TOP_SEND_W = 68.0
TOP_IO_H = 22.0
TOP_RNBO_Y = 109.0
TOP_MESSAGES_RECT = [23.0, 18.0, 71.0, 22.0]

# ``@autobuild`` flag used on the generated rnbo~ object (0 == "built", matching
# the user's own working test patcher and two of the three examples).
RNBO_AUTOBUILD = 0

# --------------------------------------------------------------------------- #
# Canned ``rnboinfo`` metadata blocks (RNBO's per-object cache)
# --------------------------------------------------------------------------- #

RESET_ARGNAME = {
    "attrOrProp": 1,
    "digest": "Reset all state and params to initial values",
    "isalias": 0,
    "aliases": [],
    "attachable": 1,
    "isparam": 0,
    "deprecated": 0,
    "touched": 0,
    "type": "bang",
}
EXPR_ARGNAME = {
    "attrOrProp": 2,
    "digest": "expr",
    "defaultarg": 1,
    "isalias": 0,
    "aliases": [],
    "settable": 1,
    "attachable": 0,
    "isparam": 0,
    "deprecated": 0,
    "touched": 0,
    "type": "symbol",
}
SAFEMATH_ARGNAME = {
    "attrOrProp": 2,
    "digest": "Use safe math expressions (e.g.: division by 0 will not crash).",
    "isalias": 0,
    "aliases": [],
    "settable": 1,
    "attachable": 0,
    "isparam": 0,
    "deprecated": 0,
    "touched": 0,
    "type": "bool",
    "defaultValue": "true",
}
NOCACHE_ARGNAME = {
    "attrOrProp": 2,
    "digest": (
        "Do not use parsing cache. This is only useful with very very big code "
        "sizes. Code generation will then take a looooong time."
    ),
    "isalias": 0,
    "aliases": [],
    "settable": 1,
    "attachable": 0,
    "isparam": 0,
    "deprecated": 0,
    "touched": 0,
    "type": "bool",
    "defaultValue": "false",
}

def param_rnboinfo(default_str: str, min_str: str, max_str: str) -> dict[str, Any]:
    return {
        "needsInstanceInfo": 1,
        "argnames": {
            "value": {
                "attrOrProp": 2,
                "digest": "Set initial value",
                "defaultarg": 2,
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "number",
                "defaultValue": default_str,
                "label": "Initial Value",
                "displayorder": 3,
            },
            "normalizedvalue": {
                "attrOrProp": 1,
                "digest": "Set value normalized. ",
                "isalias": 0,
                "aliases": [],
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "inlet": 1,
                "type": "number",
            },
            "reset": {
                "attrOrProp": 1,
                "digest": "Reset param to initial value",
                "isalias": 0,
                "aliases": [],
                "attachable": 1,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "bang",
            },
            "normalized": {
                "attrOrProp": 1,
                "digest": "Normalized parameter value.",
                "isalias": 0,
                "aliases": [],
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "outlet": 1,
                "type": "number",
            },
            "name": {
                "attrOrProp": 2,
                "digest": "Name of the parameter",
                "defaultarg": 1,
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "symbol",
                "label": "Parameter Name",
                "mandatory": 1,
            },
            "enum": {
                "attrOrProp": 2,
                "digest": "Use an enumerated output",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "list",
                "label": "Enum Values",
                "displayorder": 6,
            },
            "minimum": {
                "attrOrProp": 2,
                "digest": "Minimum value",
                "isalias": 0,
                "aliases": ["min"],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "number",
                "defaultValue": min_str,
                "label": "Minimum",
                "displayorder": 1,
            },
            "min": {
                "attrOrProp": 2,
                "digest": "Minimum value",
                "isalias": 1,
                "aliasOf": "minimum",
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "number",
                "defaultValue": min_str,
                "label": "Minimum",
                "displayorder": 1,
            },
            "maximum": {
                "attrOrProp": 2,
                "digest": "Maximum value",
                "isalias": 0,
                "aliases": ["max"],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "number",
                "defaultValue": max_str,
                "label": "Maximum",
                "displayorder": 2,
            },
            "max": {
                "attrOrProp": 2,
                "digest": "Maximum value",
                "isalias": 1,
                "aliasOf": "maximum",
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "number",
                "defaultValue": max_str,
                "label": "Maximum",
                "displayorder": 2,
            },
            "exponent": {
                "attrOrProp": 2,
                "digest": "Scale values exponentially",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "number",
                "defaultValue": "1",
                "label": "Exponent",
                "displayorder": 7,
            },
            "steps": {
                "attrOrProp": 2,
                "digest": "Divide the output into a number of discrete steps",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "number",
                "defaultValue": "0",
                "label": "Steps",
                "displayorder": 8,
            },
            "displayName": {
                "attrOrProp": 2,
                "digest": "DEPRECATED: Use the lower case 'displayname' instead",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 1,
                "touched": 0,
                "type": "symbol",
                "label": "Display Name",
            },
            "displayname": {
                "attrOrProp": 2,
                "digest": "A more readable name for the parameter in an external RNBO target",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "symbol",
                "defaultValue": "",
                "label": "Display Name",
                "displayorder": 14,
            },
            "unit": {
                "attrOrProp": 2,
                "digest": "A symbol to describe the unit of the parameter in an external RNBO target",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "symbol",
                "defaultValue": "",
                "label": "Unit",
                "displayorder": 15,
            },
            "tonormalized": {
                "attrOrProp": 2,
                "digest": "Converts a real parameter value to its normalized form",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "symbol",
                "label": "To Normalized Expression",
                "displayorder": 10,
            },
            "fromnormalized": {
                "attrOrProp": 2,
                "digest": "Converts a normalized parameter into its actual parameter value",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "symbol",
                "label": "From Normalized Expression",
                "displayorder": 9,
            },
            "order": {
                "attrOrProp": 2,
                "digest": "Order in which initial parameter values will be sent out on patcher load. The order can be numeric or symbolic ('first' and 'last')",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "symbol",
                "defaultValue": "0",
                "label": "Restore Order",
                "displayorder": 12,
            },
            "displayorder": {
                "attrOrProp": 2,
                "digest": "Order in which parameters will show up in a list of all parameters. The order can be numeric or symbolic ('first' and 'last')",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "symbol",
                "defaultValue": "-",
                "label": "Display Order",
                "displayorder": 13,
            },
            "sendinit": {
                "attrOrProp": 2,
                "digest": "Send initial value",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "bool",
                "defaultValue": "true",
                "label": "Send Init",
                "displayorder": 4,
            },
            "ctlin": {
                "attrOrProp": 2,
                "digest": "MIDI controller number to control this parameter.",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "number",
                "defaultValue": "-1",
                "label": "MIDI Controller Number.",
                "displayorder": 16,
            },
            "meta": {
                "attrOrProp": 2,
                "digest": "A JSON formatted string containing metadata for use by the exported code",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "symbol",
                "defaultValue": "",
                "label": "Metadata",
                "displayorder": 17,
            },
            "nopreset": {
                "attrOrProp": 2,
                "digest": "Do not add this value to the preset [DEPRECATED - USE @preset 0 instead].",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 1,
                "touched": 0,
                "type": "bool",
                "defaultValue": "false",
            },
            "preset": {
                "attrOrProp": 2,
                "digest": "Add this value to the preset.",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "bool",
                "defaultValue": "true",
                "label": "Include In Preset",
                "displayorder": 11,
            },
        },
        "inputs": [
            {
                "name": "value",
                "type": "number",
                "digest": "Parameter value",
                "defaultarg": 2,
                "hot": 1,
                "docked": 0,
            },
            {
                "name": "normalizedvalue",
                "type": "number",
                "digest": "Set value normalized. ",
                "docked": 0,
            },
        ],
        "outputs": [
            {
                "name": "value",
                "type": "number",
                "digest": "Parameter value",
                "defaultarg": 2,
                "hot": 1,
                "docked": 0,
            },
            {
                "name": "normalized",
                "type": "number",
                "digest": "Normalized parameter value.",
                "docked": 0,
            },
        ],
        "helpname": "param",
        "aliasOf": "param",
        "classname": "param",
        "operator": 0,
        "versionId": PARAM_VERSION_ID,
        "changesPatcherIO": 0,
    }

SETPARAM_RNBOINFO = {
    "needsInstanceInfo": 1,
    "argnames": {
        "name": {
            "attrOrProp": 2,
            "digest": "attribute/param to control",
            "defaultarg": 1,
            "isalias": 0,
            "aliases": [],
            "settable": 1,
            "attachable": 0,
            "isparam": 0,
            "deprecated": 0,
            "touched": 0,
            "type": "symbol",
            "mandatory": 1,
        }
    },
    "inputs": [
        {
            "name": "input",
            "type": ["bang", "number", "list", "signal"],
            "digest": "attribute or parameter value (bang, number, list)",
            "hot": 1,
            "docked": 0,
        }
    ],
    "outputs": [
        {
            "name": "output",
            "type": ["bang", "number", "list", "signal"],
            "digest": "connect to first inlet of gen or subpatcher",
            "docked": 0,
        }
    ],
    "helpname": "set",
    "aliasOf": "set",
    "classname": "setparam",
    "operator": 0,
    "versionId": SETPARAM_VERSION_ID,
    "changesPatcherIO": 0,
}


def in_rnboinfo(index: int) -> dict[str, Any]:
    digest = f"signal from inlet with index {index}"
    return {
        "needsInstanceInfo": 1,
        "argnames": {
            "out1": {
                "attrOrProp": 1,
                "digest": digest,
                "isalias": 0,
                "aliases": [],
                "settable": 0,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "outlet": 1,
                "type": "signal",
            },
            "index": {
                "attrOrProp": 2,
                "digest": "inlet number",
                "defaultarg": 1,
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "number",
                "mandatory": 1,
            },
            "comment": {
                "attrOrProp": 2,
                "digest": "mouse over comment",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "symbol",
            },
            "meta": {
                "attrOrProp": 2,
                "digest": (
                    "A JSON formatted string containing metadata for use by the "
                    "exported code"
                ),
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "symbol",
                "defaultValue": "",
                "label": "Metadata",
                "displayorder": 3,
            },
        },
        "inputs": [],
        "outputs": [
            {
                "name": "out1",
                "type": "signal",
                "digest": digest,
                "displayName": "",
                "docked": 0,
            }
        ],
        "helpname": "in~",
        "aliasOf": "in~",
        "classname": "in~",
        "operator": 0,
        "versionId": IN_VERSION_ID,
        "changesPatcherIO": 1,
    }


def out_rnboinfo(index: int) -> dict[str, Any]:
    digest = f"signal sent to outlet with index {index}"
    return {
        "needsInstanceInfo": 1,
        "argnames": {
            "in1": {
                "attrOrProp": 1,
                "digest": digest,
                "isalias": 0,
                "aliases": [],
                "settable": 0,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "inlet": 1,
                "type": "signal",
            },
            "index": {
                "attrOrProp": 2,
                "digest": "outlet number",
                "defaultarg": 1,
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "number",
                "mandatory": 1,
            },
            "comment": {
                "attrOrProp": 2,
                "digest": "mouse over comment",
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "symbol",
            },
            "meta": {
                "attrOrProp": 2,
                "digest": (
                    "A JSON formatted string containing metadata for use by the "
                    "exported code"
                ),
                "isalias": 0,
                "aliases": [],
                "settable": 1,
                "attachable": 0,
                "isparam": 0,
                "deprecated": 0,
                "touched": 0,
                "type": "symbol",
                "defaultValue": "",
                "label": "Metadata",
                "displayorder": 3,
            },
        },
        "inputs": [
            {
                "name": "in1",
                "type": "signal",
                "digest": digest,
                "displayName": "",
                "hot": 1,
                "docked": 0,
            }
        ],
        "outputs": [],
        "helpname": "out~",
        "aliasOf": "out~",
        "classname": "out~",
        "operator": 0,
        "versionId": OUT_VERSION_ID,
        "changesPatcherIO": 1,
    }


# --------------------------------------------------------------------------- #
# Parsing the effect source
# --------------------------------------------------------------------------- #

PARAM_RE = re.compile(
    r"@param\(\s*\{(?P<opts>[^}]*)\}\s*\)\s*(?P<name>[A-Za-z_]\w*)\s*=\s*(?P<default>[^;]+);"
)
NUM_RE = r"(-?(?:\d+\.\d*|\.\d+|\d+))"


@dataclass
class Param:
    name: str
    minimum: float
    maximum: float
    default: float
    steps: float | None = None
    enum_values: list[str] | None = None
    exponent: float = 1.0

    @property
    def default_str(self) -> str:
        return fmt_num(self.default)

    @property
    def min_str(self) -> str:
        return fmt_num(self.minimum)

    @property
    def max_str(self) -> str:
        return fmt_num(self.maximum)


@dataclass
class Effect:
    name: str
    source: str
    code: str
    n_in: int
    n_out: int
    params: list[Param] = field(default_factory=list)
    paraminfo: str = ""


def strip_comments(code: str) -> str:
    """Remove ``// ...`` line comments so identifier scans ignore prose."""
    kept = []
    for line in code.splitlines():
        idx = line.find("//")
        kept.append(line if idx < 0 else line[:idx])
    return "\n".join(kept)


def fmt_num(value: float) -> str:
    """Format a number the way Max/RNBO writes literals (``24.0`` -> ``24``)."""
    if float(value).is_integer():
        return str(int(value))
    return repr(float(value))


def _find_float(pattern: str, text: str) -> float | None:
    m = re.search(pattern, text)
    return float(m.group(1)) if m else None


def _find_enum(text: str) -> list[str] | None:
    m = re.search(r"enum\s*:\s*\[([^\]]*)\]", text)
    if not m:
        return None
    items = re.findall(r'"([^"]*)"|\'([^\']*)\'', m.group(1))
    return [a or b for a, b in items] if items else None


def parse_effect(txt_path: str, paraminfo_path: str | None) -> Effect:
    code = open(txt_path, encoding="utf-8").read()
    name = os.path.splitext(os.path.basename(txt_path))[0]

    code_nc = strip_comments(code)
    in_indices = [int(m) for m in re.findall(r"\bin(\d+)\b", code_nc)]
    out_indices = [int(m) for m in re.findall(r"\bout(\d+)\b", code_nc)]
    n_in = max(in_indices, default=0)
    n_out = max(out_indices, default=0)

    params: list[Param] = []
    for m in PARAM_RE.finditer(code):
        opts = m.group("opts")
        default = float(m.group("default").strip())
        enum_vals = _find_enum(opts)
        minimum = _find_float(r"min\s*:\s*" + NUM_RE, opts)
        maximum = _find_float(r"max\s*:\s*" + NUM_RE, opts)
        if minimum is None:
            minimum = 0.0
        if maximum is None:
            maximum = float(len(enum_vals) - 1) if enum_vals and len(enum_vals) > 1 else 1.0
        params.append(
            Param(
                name=m.group("name"),
                minimum=minimum,
                maximum=maximum,
                default=default,
                steps=_find_float(r"steps\s*:\s*" + NUM_RE, opts),
                enum_values=enum_vals,
                exponent=_find_float(r"exponent\s*:\s*" + NUM_RE, opts) or 1.0,
            )
        )

    paraminfo = ""
    if paraminfo_path and os.path.exists(paraminfo_path):
        paraminfo = open(paraminfo_path, encoding="utf-8").read()

    return Effect(
        name=name,
        source=txt_path,
        code=code,
        n_in=n_in,
        n_out=n_out,
        params=params,
        paraminfo=paraminfo,
    )


# --------------------------------------------------------------------------- #
# Building the patcher JSON
# --------------------------------------------------------------------------- #


class IdGen:
    """Deterministic ``obj-N`` id generator (ids only need to be unique)."""

    def __init__(self, start: int = 2) -> None:
        self._n = start

    def next(self) -> str:
        val = f"obj-{self._n}"
        self._n += 1
        return val


def _spread(i: int, count: int, lo: float, hi: float) -> float:
    """Evenly space index ``i`` (0-based) of ``count`` items across [lo, hi]."""
    if count <= 1:
        return lo
    return lo + (hi - lo) * i / (count - 1)


def build_codebox_rnboinfo(n_in: int, n_out: int, params: list[Param]) -> dict[str, Any]:
    argnames: dict[str, Any] = {"reset": dict(RESET_ARGNAME)}
    for i in range(1, n_in + 1):
        argnames[f"in{i}"] = {
            "attrOrProp": 1,
            "digest": f"in{i}",
            "isalias": 0,
            "aliases": [],
            "settable": 1,
            "attachable": 0,
            "isparam": 0,
            "deprecated": 0,
            "touched": 0,
            "inlet": 1,
            "type": "number",
        }
    for j in range(1, n_out + 1):
        argnames[f"out{j}"] = {
            "attrOrProp": 1,
            "digest": f"out{j}",
            "isalias": 0,
            "aliases": [],
            "attachable": 0,
            "isparam": 0,
            "deprecated": 0,
            "touched": 0,
            "outlet": 1,
            "type": "signal",
        }
    for p in params:
        argnames[p.name] = {
            "attrOrProp": 1,
            "digest": p.name,
            "isalias": 0,
            "aliases": [],
            "settable": 1,
            "attachable": 1,
            "isparam": 0,
            "deprecated": 0,
            "touched": 0,
            "type": "number",
            "defaultValue": p.default_str,
        }
    argnames["expr"] = dict(EXPR_ARGNAME)
    argnames["safemath"] = dict(SAFEMATH_ARGNAME)
    argnames["nocache"] = dict(NOCACHE_ARGNAME)

    inputs = []
    for i in range(1, n_in + 1):
        entry = {"name": f"in{i}", "type": "auto", "digest": f"in{i}"}
        if i == 1:
            entry["hot"] = 1
        entry["docked"] = 0
        inputs.append(entry)
    outputs = [
        {"name": f"out{j}", "type": "signal", "digest": f"out{j}", "docked": 0}
        for j in range(1, n_out + 1)
    ]

    return {
        "needsInstanceInfo": 1,
        "argnames": argnames,
        "inputs": inputs,
        "outputs": outputs,
        "helpname": "codebox~",
        "aliasOf": "expr~",
        "classname": "codebox~",
        "operator": 0,
        "versionId": CODEBOX_VERSION_ID,
        "changesPatcherIO": 0,
    }


def build_nested_patcher(effect: Effect) -> dict[str, Any]:
    ids = IdGen(2)
    boxes: list[dict[str, Any]] = []
    lines: list[dict[str, Any]] = []

    paraminfo_lines = len(effect.paraminfo.splitlines()) if effect.paraminfo else 0

    def link(source: str, src_out: int, dest: str, dst_in: int) -> None:
        lines.append(
            {
                "patchline": {
                    "destination": [dest, dst_in],
                    "source": [source, src_out],
                }
            }
        )

    # --- codebox~ -----------------------------------------------------------
    codebox_id = ids.next()
    boxes.append(
        {
            "box": {
                "code": effect.code,
                "fontface": 0,
                "fontname": "<Monospaced>",
                "fontsize": 12.0,
                "id": codebox_id,
                "maxclass": "codebox~",
                "numinlets": effect.n_in,
                "numoutlets": effect.n_out,
                "outlettype": ["signal"] * effect.n_out,
                "patching_rect": list(CODEBOX_RECT),
                "rnbo_classname": "codebox~",
                "rnbo_extra_attributes": {
                    "expr": "",
                    "nocache": 0,
                    "safemath": 1,
                    "code": effect.code,
                },
                "rnbo_serial": 1,
                "rnbo_uniqueid": "effect_code",
                "rnboinfo": build_codebox_rnboinfo(
                    effect.n_in, effect.n_out, effect.params
                ),
                "varname": "effect_code",
            }
        }
    )

    # --- in~ objects --------------------------------------------------------
    in_ids: list[str] = []
    for i in range(1, effect.n_in + 1):
        box_id = ids.next()
        in_ids.append(box_id)
        boxes.append(
            {
                "box": {
                    "id": box_id,
                    "maxclass": "newobj",
                    "numinlets": 0,
                    "numoutlets": 1,
                    "outlettype": ["signal"],
                    "patching_rect": [
                        _spread(i - 1, effect.n_in, IO_X_MIN, IO_X_MAX),
                        IO_ROW_TOP,
                        IO_BOX_W,
                        IO_BOX_H,
                    ],
                    "rnbo_classname": "in~",
                    "rnbo_extra_attributes": {"comment": "", "meta": ""},
                    "rnbo_serial": i,
                    "rnbo_uniqueid": f"audio_in_{i}",
                    "rnboinfo": in_rnboinfo(i),
                    "text": f"in~ {i}",
                    "varname": f"audio_in_{i}",
                }
            }
        )

    # --- out~ objects -------------------------------------------------------
    out_ids: list[str] = []
    for j in range(1, effect.n_out + 1):
        box_id = ids.next()
        out_ids.append(box_id)
        boxes.append(
            {
                "box": {
                    "id": box_id,
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        _spread(j - 1, effect.n_out, IO_X_MIN, IO_X_MAX),
                        IO_ROW_BOTTOM,
                        IO_BOX_W,
                        IO_BOX_H,
                    ],
                    "rnbo_classname": "out~",
                    "rnbo_extra_attributes": {"comment": "", "meta": ""},
                    "rnbo_serial": j,
                    "rnbo_uniqueid": f"audio_out_{j}",
                    "rnboinfo": out_rnboinfo(j),
                    "text": f"out~ {j}",
                    "varname": f"audio_out_{j}",
                }
            }
        )

    # --- parameter controls (comment / param / number / setparam) -----------
    num_cols = 4
    param_texts: list[str] = []
    param_widths: list[float] = []
    col_widths = [PARAM_BOX_W] * num_cols

    for k, p in enumerate(effect.params):
        col = k % num_cols
        p_text = f"param {p.name} {p.default_str} @min {p.min_str} @max {p.max_str}"
        if p.exponent != 1.0:
            p_text += f" @exponent {fmt_num(p.exponent)}"
        p_w = float(max(PARAM_BOX_W, round(len(p_text) * 6.5) + 18.0))
        s_text = f"setparam {p.name}"
        s_w = float(max(PARAM_BOX_W, round(len(s_text) * 6.5) + 18.0))
        c_w = float(max(PARAM_BOX_W, round(len(p.name) * 6.5) + 14.0))
        param_texts.append(p_text)
        param_widths.append(p_w)
        col_widths[col] = max(col_widths[col], p_w, s_w, c_w)

    col_x: list[float] = []
    cur_x = PARAM_X0
    for col in range(num_cols):
        col_x.append(cur_x)
        cur_x += col_widths[col] + PARAM_COL_GAP

    for k, p in enumerate(effect.params):
        col = k % num_cols
        row = k // num_cols
        x = col_x[col]
        y = PARAM_Y0 + PARAM_ROW_STEP * row
        param_box_w = param_widths[k]
        param_text = param_texts[k]

        comment_id = ids.next()
        number_id = ids.next()
        setparam_id = ids.next()
        param_id = ids.next()

        boxes.append(
            {
                "box": {
                    "id": comment_id,
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [x, y, PARAM_BOX_W, 21.0],
                    "text": p.name,
                }
            }
        )
        boxes.append(
            {
                "box": {
                    "id": number_id,
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": ["", "bang"],
                    "parameter_enable": 0,
                    "patching_rect": [x, y + 50.0, NUMBOX_W, 23.0],
                    "rnbo_classname": "number",
                    "rnbo_extra_attributes": {
                        "initialFormat": "float",
                        "maximum": "<none>",
                        "minimum": "<none>",
                        "order": "",
                        "preset": 0,
                    },
                    "rnbo_serial": k + 1,
                    "rnbo_uniqueid": f"value_{p.name}",
                    "varname": f"value_{p.name}",
                }
            }
        )
        boxes.append(
            {
                "box": {
                    "id": setparam_id,
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [""],
                    "patching_rect": [x, y + 78.0, PARAM_BOX_W, 23.0],
                    "rnbo_classname": "setparam",
                    "rnbo_serial": k + 1,
                    "rnbo_uniqueid": f"set_{p.name}",
                    "rnboinfo": SETPARAM_RNBOINFO,
                    "text": f"setparam {p.name}",
                    "varname": f"set_{p.name}",
                }
            }
        )
        boxes.append(
            {
                "box": {
                    "id": param_id,
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 2,
                    "outlettype": ["", ""],
                    "patching_rect": [x, y + 27.0, param_box_w, 23.0],
                    "rnbo_classname": "param",
                    "rnbo_extra_attributes": {
                        "ctlin": 0.0,
                        "displayname": "",
                        "displayorder": "-",
                        "enum": "",
                        "exponent": p.exponent,
                        "fromnormalized": "",
                        "meta": "",
                        "order": "0",
                        "preset": 1,
                        "sendinit": 1,
                        "steps": 0.0,
                        "tonormalized": "",
                        "unit": "",
                    },
                    "rnbo_serial": k + 1,
                    "rnbo_uniqueid": p.name,
                    "rnboinfo": param_rnboinfo(p.default_str, p.min_str, p.max_str),
                    "text": param_text,
                    "varname": p.name,
                }
            }
        )

        link(param_id, 0, number_id, 0)
        link(number_id, 0, setparam_id, 0)
        link(setparam_id, 0, codebox_id, 0)

    # --- codebox outputs -> out~ -------------------------------------------
    for j, out_id in enumerate(out_ids):
        link(codebox_id, j, out_id, 0)

    # --- in~ -> codebox inlets ---------------------------------------------
    for i, in_id in enumerate(in_ids):
        link(in_id, 0, codebox_id, i)

    # --- paraminfo documentation comment -----------------------------------
    if effect.paraminfo:
        paraminfo_id = ids.next()
        boxes.append(
            {
                "box": {
                    "id": paraminfo_id,
                    "linecount": max(paraminfo_lines, 1),
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        PARAMINFO_RECT_X,
                        PARAMINFO_RECT_Y,
                        PARAMINFO_RECT_W,
                        round(max(paraminfo_lines, 1) * LINE_HEIGHT * 1.3) + 18,
                    ],
                    "text": effect.paraminfo,
                    "varname": "paraminfo_comment",
                }
            }
        )

    used_cols = min(len(effect.params), num_cols)
    max_param_x = (
        col_x[used_cols - 1] + col_widths[used_cols - 1] + 40.0
        if used_cols > 0
        else PARAM_X0
    )
    return {
        "fileversion": 1,
        "appversion": dict(APP_VERSION),
        "classnamespace": "rnbo",
        "rect": [100.0, 100.0, max(1000.0, max_param_x), 780.0],
        "default_fontname": DEFAULT_FONT,
        "title": "untitled",
        "boxes": boxes,
        "lines": lines,
    }


def build_top_patcher(effect: Effect) -> dict[str, Any]:
    ids = IdGen(2)
    boxes: list[dict[str, Any]] = []
    lines: list[dict[str, Any]] = []

    def link(source: str, src_out: int, dest: str, dst_in: int) -> None:
        lines.append(
            {
                "patchline": {
                    "destination": [dest, dst_in],
                    "source": [source, src_out],
                }
            }
        )

    # "r messages" helper
    messages_id = ids.next()
    boxes.append(
        {
            "box": {
                "id": messages_id,
                "maxclass": "newobj",
                "numinlets": 0,
                "numoutlets": 1,
                "outlettype": [""],
                "patching_rect": list(TOP_MESSAGES_RECT),
                "text": "r messages",
            }
        }
    )

    # receive~ in1..inN
    receive_ids: list[str] = []
    for i in range(1, effect.n_in + 1):
        box_id = ids.next()
        receive_ids.append(box_id)
        boxes.append(
            {
                "box": {
                    "id": box_id,
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": ["signal"],
                    "patching_rect": [
                        _spread(i - 1, effect.n_in, 65.0, 65.0 + 80.0 * (effect.n_in - 1)),
                        TOP_RECEIVE_Y,
                        TOP_RECEIVE_W,
                        TOP_IO_H,
                    ],
                    "text": f"receive~ in{i}",
                }
            }
        )

    # send~ out1..outM
    send_ids: list[str] = []
    for j in range(1, effect.n_out + 1):
        box_id = ids.next()
        send_ids.append(box_id)
        boxes.append(
            {
                "box": {
                    "id": box_id,
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [
                        _spread(j - 1, effect.n_out, 65.0, 65.0 + 80.0 * (effect.n_out - 1)),
                        TOP_SEND_Y,
                        TOP_SEND_W,
                        TOP_IO_H,
                    ],
                    "text": f"send~ out{j}",
                }
            }
        )

    # embedded rnbo~ object
    rnbo_id = ids.next()
    rnbo_text = f"rnbo~ @autobuild {RNBO_AUTOBUILD} @annotation_name {effect.name}"
    rnbo_rect_w = round(len(rnbo_text) * 6.1) + 20
    rnbo_box = {
        "autosave": 1,
        "id": rnbo_id,
        "inletInfo": {
            "IOInfo": [
                {"type": "signal", "index": i, "tag": f"in{i}", "comment": ""}
                for i in range(1, effect.n_in + 1)
            ]
        },
        "maxclass": "newobj",
        "numinlets": effect.n_in,
        "numoutlets": effect.n_out + 1,
        "outletInfo": {
            "IOInfo": [
                {"type": "signal", "index": j, "tag": f"out{j}", "comment": ""}
                for j in range(1, effect.n_out + 1)
            ]
        },
        "outlettype": ["signal"] * effect.n_out + ["list"],
        "patcher": build_nested_patcher(effect),
        "patching_rect": [65.0, TOP_RNBO_Y, float(rnbo_rect_w), TOP_IO_H],
        "rnboattrcache": {},
        "rnboversion": RNBO_VERSION,
        "saved_attribute_attributes": {
            "valueof": {
                "parameter_invisible": 1,
                "parameter_longname": "rnbo~",
                "parameter_modmode": 0,
                "parameter_shortname": "rnbo~",
                "parameter_type": 3,
            }
        },
        "saved_object_attributes": {
            "annotation_name": effect.name,
            "optimization": "O1",
            "parameter_enable": 1,
            "uuid": str(uuid.uuid1()),
        },
        "snapshot": {
            "filetype": "C74Snapshot",
            "version": 2,
            "minorversion": 0,
            "name": "snapshotlist",
            "origin": "rnbo~",
            "type": "list",
            "subtype": "Undefined",
            "embed": 1,
            "snapshot": {},
            "snapshotlist": {"current_snapshot": 0, "entries": []},
        },
        "text": rnbo_text,
        "varname": f"rnbo_test_{effect.name}",
    }
    boxes.append({"box": rnbo_box})

    # wiring
    for i, recv_id in enumerate(receive_ids):
        link(recv_id, 0, rnbo_id, i)
    link(messages_id, 0, rnbo_id, 0)
    for j, send_id in enumerate(send_ids):
        link(rnbo_id, j, send_id, 0)

    width = max(65.0 + rnbo_rect_w, 65.0 + 80.0 * max(effect.n_in, effect.n_out)) + 60.0
    return {
        "fileversion": 1,
        "appversion": dict(APP_VERSION),
        "classnamespace": "box",
        "rect": [100.0, 100.0, float(width), 260.0],
        "boxes": boxes,
        "lines": lines,
        "parameters": {
            rnbo_id: ["rnbo~", "rnbo~", 0],
            "parameterbanks": {
                "0": {
                    "index": 0,
                    "name": "",
                    "parameters": ["-"] * 8,
                    "buttons": ["-"] * 8,
                }
            },
            "inherited_shortname": 1,
        },
        "autosave": 0,
        "toolbaradditions": ["packagemanager"],
        "toolbarexclusions": ["mixerslider", "quickrecord", "showmappings"],
    }


def build_maxpat(effect: Effect) -> dict[str, Any]:
    return {"patcher": build_top_patcher(effect)}


def build_rnbopat(effect: Effect) -> dict[str, Any]:
    return {"patcher": build_nested_patcher(effect)}


# --------------------------------------------------------------------------- #
# Discovery / CLI
# --------------------------------------------------------------------------- #


def discover_effects(root: str) -> list[tuple[str, str, str]]:
    """Return ``(txt_path, paraminfo_path, rel_dir)`` for every effect under root.

    ``rel_dir`` is the effect's directory relative to ``root`` (``""`` when the
    effect sits directly in the root), so the caller can mirror the tree.
    """
    pattern = os.path.join(root, "**", "*.txt")
    effects: list[tuple[str, str, str]] = []
    for txt in sorted(glob.glob(pattern, recursive=True)):
        base = os.path.basename(txt)
        if base.endswith("_paraminfo.txt"):
            continue
        paraminfo = os.path.splitext(txt)[0] + "_paraminfo.txt"
        rel_dir = os.path.relpath(os.path.dirname(txt), root)
        if rel_dir == os.curdir:
            rel_dir = ""
        effects.append((txt, paraminfo, rel_dir))
    return effects


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--src", default="generated_fx", help="root of the effect .txt files")
    parser.add_argument("--outdir", default="generated_maxpat", help="destination directory")
    parser.add_argument(
        "--rnbopat-outdir", default="generated_rnbopat", help="destination directory for the .rnbopat abstractions"
    )
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
    os.makedirs(args.rnbopat_outdir, exist_ok=True)

    count = 0
    for txt, paraminfo, rel_dir in found:
        effect = parse_effect(txt, paraminfo)
        if effect.n_in < 1 or effect.n_out < 1:
            print(
                f"  ! {effect.name}: detected {effect.n_in} inlets / {effect.n_out} outlets, skipping",
                file=sys.stderr,
            )
            continue
        patcher = build_maxpat(effect)
        out_dir = os.path.join(args.outdir, rel_dir)
        os.makedirs(out_dir, exist_ok=True)
        out_path = os.path.join(out_dir, f"{effect.name}.maxpat")
        with open(out_path, "w", encoding="utf-8") as fh:
            json.dump(patcher, fh, indent=2)
            fh.write("\n")
        rnbopat_dir = os.path.join(args.rnbopat_outdir, rel_dir)
        os.makedirs(rnbopat_dir, exist_ok=True)
        rnbopat_path = os.path.join(rnbopat_dir, f"ai.{effect.name}.rnbopat")
        with open(rnbopat_path, "w", encoding="utf-8") as fh:
            json.dump(build_rnbopat(effect), fh, indent=4)
            fh.write("\n")
        count += 1
        print(
            f"  {effect.name}: {effect.n_in} in / {effect.n_out} out / "
            f"{len(effect.params)} params -> {out_path}, {rnbopat_path}"
        )

    print(f"\nWrote {count} patcher(s) to {args.outdir} and {count} abstraction(s) to {args.rnbopat_outdir}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
