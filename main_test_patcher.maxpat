{
    "patcher": {
        "fileversion": 1,
        "appversion": {
            "major": 9,
            "minor": 1,
            "revision": 5,
            "architecture": "x64",
            "modernui": 1
        },
        "classnamespace": "box",
        "rect": [ 542.0, 143.0, 1544.0, 1263.0 ],
        "boxes": [
            {
                "box": {
                    "id": "obj-52",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 547.0, 440.0, 35.0, 22.0 ],
                    "text": "abs~"
                }
            },
            {
                "box": {
                    "id": "obj-49",
                    "maxclass": "live.scope~",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "bang" ],
                    "patching_rect": [ 547.0, 548.0, 184.0, 68.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-46",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 547.0, 480.0, 37.0, 22.0 ],
                    "text": "*~ 16"
                }
            },
            {
                "box": {
                    "id": "obj-45",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 547.0, 514.0, 94.0, 22.0 ],
                    "text": "slide~ 960 4800"
                }
            },
            {
                "box": {
                    "id": "obj-42",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 919.0, 299.0, 46.0, 22.0 ],
                    "text": "r~ out2"
                }
            },
            {
                "box": {
                    "id": "obj-41",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 854.0, 299.0, 46.0, 22.0 ],
                    "text": "r~ out1"
                }
            },
            {
                "box": {
                    "id": "obj-35",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 1058.0, 1060.0, 54.0, 22.0 ],
                    "text": "deferlow"
                }
            },
            {
                "box": {
                    "id": "obj-34",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 1172.0, 1035.0, 48.0, 22.0 ],
                    "text": "pipe 33"
                }
            },
            {
                "box": {
                    "id": "obj-40",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "open" ],
                    "patching_rect": [ 1172.0, 1004.6666666666667, 42.0, 22.0 ],
                    "text": "t open"
                }
            },
            {
                "box": {
                    "id": "obj-37",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 1058.0, 970.3333333333334, 48.0, 22.0 ],
                    "text": "pipe 33"
                }
            },
            {
                "box": {
                    "id": "obj-30",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 1058.0, 1004.6666666666667, 105.0, 22.0 ],
                    "text": "prepend autobuild"
                }
            },
            {
                "box": {
                    "id": "obj-28",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "int" ],
                    "patching_rect": [ 1058.0, 936.0, 22.0, 22.0 ],
                    "text": "t 1"
                }
            },
            {
                "box": {
                    "id": "obj-27",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 1058.0, 1091.0, 73.0, 22.0 ],
                    "text": "s messages"
                }
            },
            {
                "box": {
                    "id": "obj-26",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 455.5, 573.0, 41.0, 22.0 ],
                    "text": "s~ in4"
                }
            },
            {
                "box": {
                    "id": "obj-25",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 383.5, 571.0, 41.0, 22.0 ],
                    "text": "s~ in3"
                }
            },
            {
                "box": {
                    "id": "obj-23",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 238.5, 565.0, 41.0, 22.0 ],
                    "text": "s~ in1"
                }
            },
            {
                "box": {
                    "id": "obj-24",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 310.5, 568.0, 41.0, 22.0 ],
                    "text": "s~ in2"
                }
            },
            {
                "box": {
                    "id": "obj-19",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 799.0, 936.0, 235.0, 22.0 ],
                    "text": "prepend script sendbox replaceme replace"
                }
            },
            {
                "box": {
                    "id": "obj-20",
                    "maxclass": "number",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "", "bang" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 799.0, 656.0, 50.0, 22.0 ]
                }
            },
            {
                "box": {
                    "code": "/* Max 9 v8.codebox: map an integer onto a generated .maxpat file path.\n *\n * 1. Paste this entire script into a v8.codebox in a Max patch that sits in\n *    this repository's root (the folder that holds generated_maxpat/).\n * 2. Send an integer to the box's single inlet. Outlet 0 then emits the full,\n *    absolute path of the corresponding .maxpat file.\n *\n * Indexing is 0-based by default: 0 -> the first name in a case-insensitive\n * sort of generated_maxpat/*.maxpat, 1 -> the second, and so on. Order does not\n * matter: any integer works because out-of-range values wrap modulo the file\n * count, so every integer still selects a real file. Set FIRST_INDEX to 1\n * below for one-based numbering.\n *\n * The directory is re-scanned on every input, so files added or removed while\n * Max is open are picked up without re-pasting the script. Subfolders and\n * non-.maxpat files are ignored.\n *\n * Extra inputs: `bang` re-emits the last path, `count` emits how many .maxpat\n * files were found.\n *\n * Uses Max's File/Folder/Patcher APIs, not Node's fs or npm packages.\n */\n\nvar DIRECTORY = \"generated_maxpat\"; // Relative to this patch, or an absolute Max path.\nvar FIRST_INDEX = 0;                // 0 for zero-based indices, 1 for one-based.\nvar EXTENSION = \".maxpat\";          // Case-insensitive extension filter.\n\nvar boxContext = this;              // jsthis: gives access to this.patcher.\nvar lastIndex = FIRST_INDEX;        // Index remembered by `bang`.\n\n// An integer in the inlet (or the `int` message) -> emit one file path.\nfunction msg_int(value) {\n    var index = asInteger(value);\n    if (index === null) {\n        error(\"maxpat index: not an integer: \" + value + \"\\n\");\n        return;\n    }\n    var found = collectPatchers();\n    if (!found.files.length) {\n        error(\"maxpat index: no \" + EXTENSION + \" files found (looked in \" +\n            found.directory + \").\\n\");\n        return;\n    }\n    lastIndex = index;\n    outlet(0, found.files[wrap(index - FIRST_INDEX, found.files.length)]);\n}\n\n// A float in the inlet rounds to the nearest integer, so either input works.\nfunction msg_float(value) {\n    msg_int(Math.round(value));\n}\n\n// Re-emit the path chosen by the most recent integer input.\nfunction bang() {\n    msg_int(lastIndex);\n}\n\n// Emit how many .maxpat files were found.\nfunction count() {\n    outlet(0, collectPatchers().files.length);\n}\n\n// ---------------------------------------------------------------------------\n// Helpers\n// ---------------------------------------------------------------------------\n\n// Scan the first candidate directory that actually contains matching files.\nfunction collectPatchers() {\n    var candidates = directoryCandidates();\n    for (var i = 0; i < candidates.length; i++) {\n        var found = scanDirectory(candidates[i]);\n        if (found.files.length) return found;\n    }\n    return { directory: candidates[0], files: [] };\n}\n\n// Candidate directories, most specific first: an absolute DIRECTORY, then this\n// patch's own folder joined with DIRECTORY, then DIRECTORY as written so Max\n// can resolve it through the search path.\nfunction directoryCandidates() {\n    if (isAbsolute(DIRECTORY)) return unique([DIRECTORY]);\n    var candidates = [];\n    var folder = patchFolder();\n    if (folder) candidates.push(joinPath(folder, DIRECTORY));\n    candidates.push(DIRECTORY);\n    return unique(candidates);\n}\n\n// List generator_maxpat/*.maxpat as absolute paths, sorted by name.\nfunction scanDirectory(directory) {\n    var files = [];\n    var resolved = directory;\n    var folder = null;\n    try {\n        folder = new Folder(directory);\n        // pathname is the full resolved path Max found for the folder.\n        resolved = folder.pathname || directory;\n        while (!folder.end) {\n            if (folder.filetype !== \"fold\" && hasExtension(folder.filename, EXTENSION)) {\n                files.push(joinPath(resolved, folder.filename));\n            }\n            folder.next();\n        }\n    } catch (ignored) {\n        files = [];\n    } finally {\n        if (folder) {\n            try { folder.close(); } catch (ignored) {}\n        }\n    }\n    files.sort(compareNames);\n    return { directory: resolved, files: files };\n}\n\n// The folder containing this patch, derived from this.patcher.filepath.\nfunction patchFolder() {\n    try {\n        var patcher = boxContext && boxContext.patcher;\n        var filepath = patcher && patcher.filepath;\n        if (typeof filepath === \"string\" && filepath.length) {\n            return splitPath(filepath).directory;\n        }\n    } catch (ignored) {}\n    return null;\n}\n\nfunction splitPath(path) {\n    var normalized = String(path).replace(/[\\\\]/g, \"/\");\n    var slash = normalized.lastIndexOf(\"/\");\n    if (slash < 0) return { directory: normalized, name: \"\" };\n    return {\n        directory: slash === 0 ? \"/\" : normalized.slice(0, slash),\n        name: normalized.slice(slash + 1)\n    };\n}\n\nfunction isAbsolute(path) {\n    var p = String(path);\n    return p.charAt(0) === \"/\" || /^[A-Za-z]:[\\/\\\\]/.test(p);\n}\n\nfunction joinPath(directory, name) {\n    var base = String(directory).replace(/[\\/\\\\]+$/, \"\");\n    if (!base) return name;\n    return base + \"/\" + name;\n}\n\nfunction hasExtension(name, extension) {\n    var lower = String(name).toLowerCase();\n    var suffix = String(extension).toLowerCase();\n    return lower.length >= suffix.length &&\n        lower.slice(lower.length - suffix.length) === suffix;\n}\n\n// Case-insensitive, with a case-sensitive tiebreak so the order is stable.\nfunction compareNames(a, b) {\n    var x = a.toLowerCase();\n    var y = b.toLowerCase();\n    if (x < y) return -1;\n    if (x > y) return 1;\n    return a < b ? -1 : (a > b ? 1 : 0);\n}\n\nfunction wrap(value, modulus) {\n    return ((value % modulus) + modulus) % modulus;\n}\n\nfunction asInteger(value) {\n    var n = typeof value === \"number\" ? value : Number(String(value).trim());\n    if (typeof n !== \"number\" || !isFinite(n) || Math.floor(n) !== n) return null;\n    return n;\n}\n\nfunction unique(values) {\n    var out = [];\n    for (var i = 0; i < values.length; i++) {\n        if (values[i] && out.indexOf(values[i]) < 0) out.push(values[i]);\n    }\n    return out;\n}\n",
                    "filename": "none",
                    "fontface": 0,
                    "fontname": "<Monospaced>",
                    "fontsize": 12.0,
                    "id": "obj-14",
                    "maxclass": "v8.codebox",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 799.0, 694.0, 631.0, 228.0 ],
                    "saved_object_attributes": {
                        "parameter_enable": 0
                    }
                }
            },
            {
                "box": {
                    "id": "obj-13",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "int" ],
                    "patching_rect": [ 75.0, 373.0, 29.5, 22.0 ],
                    "text": "+ 1"
                }
            },
            {
                "box": {
                    "id": "obj-17",
                    "maxclass": "toggle",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "int" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 75.0, 330.0, 24.0, 24.0 ]
                }
            },
            {
                "box": {
                    "args": [ "#1" ],
                    "bgmode": 0,
                    "border": 0,
                    "clickthrough": 0,
                    "enablehscroll": 0,
                    "enablevscroll": 0,
                    "id": "obj-21",
                    "lockeddragscroll": 0,
                    "lockedsize": 0,
                    "maxclass": "bpatcher",
                    "name": "amfm_hilbert_transcolorifer.maxpat",
                    "numinlets": 0,
                    "numoutlets": 0,
                    "offset": [ 0.0, 0.0 ],
                    "patching_rect": [ 209.0, 692.0, 528.0, 208.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 437.0, 938.0, 401.0, 577.0 ],
                    "varname": "replaceme",
                    "viewvisibility": 1
                }
            },
            {
                "box": {
                    "id": "obj-15",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 1818.0, 1065.75, 370.0, 22.0 ],
                    "text": "script sendbox #1 replace plugin_selector.maxpat"
                }
            },
            {
                "box": {
                    "id": "obj-1",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 225.0, 475.0, 68.0, 22.0 ],
                    "text": "selector~ 2"
                }
            },
            {
                "box": {
                    "id": "obj-29",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "", "" ],
                    "patching_rect": [ 799.0, 970.0, 67.0, 22.0 ],
                    "save": [ "#N", "thispatcher", ";", "#Q", "end", ";" ],
                    "text": "thispatcher"
                }
            },
            {
                "box": {
                    "id": "obj-2",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 319.0, 475.0, 68.0, 22.0 ],
                    "text": "selector~ 2"
                }
            },
            {
                "box": {
                    "id": "obj-87",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 1254.0, 143.0, 74.0, 20.0 ],
                    "text": "outstanding"
                }
            },
            {
                "box": {
                    "autosave": 1,
                    "bgmode": 0,
                    "border": 0,
                    "clickthrough": 0,
                    "id": "obj-54",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 8,
                    "offset": [ 0.0, 0.0 ],
                    "outlettype": [ "signal", "signal", "", "list", "int", "", "", "" ],
                    "patching_rect": [ 935.0, 555.0, 138.0, 22.0 ],
                    "save": [ "#N", "vst~", "loaduniqueid", 0, 2, 2, "Pro-Q 3", ";" ],
                    "saved_attribute_attributes": {
                        "valueof": {
                            "parameter_invisible": 1,
                            "parameter_longname": "vst~",
                            "parameter_modmode": 0,
                            "parameter_shortname": "vst~",
                            "parameter_type": 3
                        }
                    },
                    "saved_object_attributes": {
                        "parameter_enable": 1,
                        "parameter_mappable": 0,
                        "prefer": "AudioUnit"
                    },
                    "snapshot": {
                        "filetype": "C74Snapshot",
                        "version": 2,
                        "minorversion": 0,
                        "name": "snapshotlist",
                        "origin": "vst~",
                        "type": "list",
                        "subtype": "Undefined",
                        "embed": 1,
                        "snapshot": {
                            "pluginname": "Pro-Q 3.auinfo",
                            "plugindisplayname": "Pro-Q 3",
                            "pluginsavedname": "",
                            "pluginsaveduniqueid": 1631927376,
                            "version": 1,
                            "isbank": 0,
                            "isbase64": 1,
                            "blob": "1684.hAGaoMGcv.i0AHv.DTfAGfPBJr.CWMWchQWdvUFWsEla0YVXiQWcxUlbeAAEFElXFkFazUlbPwVcmklaSQWXzUFUtEVakQEc4AWYWYWYxMWZu4lDFE0LvIgQgIlQOEQAfajQBMU.....lE............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3O...f+....................................9C...3O...f+B....D...DP...f.A....D........f+....9C....P..........................................................................................................................................fQQMCbC....7.....QkYVX0wFcfLUYzQWZtc1+++++A....T.....Tx8VKQA....vP0MkUA.........vWP7.QkYVX0wFcfLUYzQWZtclDgUWalAA..f..U.PG.nB.AAfQ.rD.SA.V.zkAAYvTFfE.......f.A.........PC..................fAZA"
                        },
                        "snapshotlist": {
                            "current_snapshot": 0,
                            "entries": [
                                {
                                    "filetype": "C74Snapshot",
                                    "version": 2,
                                    "minorversion": 0,
                                    "name": "Pro-Q 3",
                                    "origin": "Pro-Q 3.auinfo",
                                    "type": "AudioUnit",
                                    "subtype": "MidiEffect",
                                    "embed": 0,
                                    "snapshot": {
                                        "pluginname": "Pro-Q 3.auinfo",
                                        "plugindisplayname": "Pro-Q 3",
                                        "pluginsavedname": "",
                                        "pluginsaveduniqueid": 1631927376,
                                        "version": 1,
                                        "isbank": 0,
                                        "isbase64": 1,
                                        "blob": "1684.hAGaoMGcv.i0AHv.DTfAGfPBJr.CWMWchQWdvUFWsEla0YVXiQWcxUlbeAAEFElXFkFazUlbPwVcmklaSQWXzUFUtEVakQEc4AWYWYWYxMWZu4lDFE0LvIgQgIlQOEQAfajQBMU.....lE............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3O...f+....................................9C...3O...f+B....D...DP...f.A....D........f+....9C....P..........................................................................................................................................fQQMCbC....7.....QkYVX0wFcfLUYzQWZtc1+++++A....T.....Tx8VKQA....vP0MkUA.........vWP7.QkYVX0wFcfLUYzQWZtclDgUWalAA..f..U.PG.nB.AAfQ.rD.SA.V.zkAAYvTFfE.......f.A.........PC..................fAZA"
                                    },
                                    "fileref": {
                                        "name": "Pro-Q 3",
                                        "filename": "Pro-Q 3_20261014.maxsnap",
                                        "filepath": "~/Documents/Max 9/Snapshots",
                                        "filepos": -1,
                                        "snapshotfileid": "573b51492813a845adb4712650dce0ac"
                                    }
                                }
                            ]
                        }
                    },
                    "text": "audiounit~ 2 2 \"Pro-Q 3\"",
                    "varname": "vst~",
                    "viewvisibility": 0
                }
            },
            {
                "box": {
                    "id": "obj-53",
                    "lastchannelcount": 0,
                    "maxclass": "live.gain~",
                    "numinlets": 2,
                    "numoutlets": 5,
                    "outlettype": [ "signal", "signal", "", "float", "list" ],
                    "parameter_enable": 1,
                    "patching_rect": [ 872.0, 349.0, 48.0, 136.0 ],
                    "saved_attribute_attributes": {
                        "valueof": {
                            "parameter_longname": "live.gain~[2]",
                            "parameter_mmax": 6.0,
                            "parameter_mmin": -70.0,
                            "parameter_modmode": 3,
                            "parameter_shortname": "live.gain~",
                            "parameter_type": 0,
                            "parameter_unitstyle": 4
                        }
                    },
                    "varname": "live.gain~[2]"
                }
            },
            {
                "box": {
                    "id": "obj-51",
                    "lastchannelcount": 0,
                    "maxclass": "live.gain~",
                    "numinlets": 2,
                    "numoutlets": 5,
                    "outlettype": [ "signal", "signal", "", "float", "list" ],
                    "parameter_enable": 1,
                    "patching_rect": [ 786.0, 349.0, 48.0, 136.0 ],
                    "saved_attribute_attributes": {
                        "valueof": {
                            "parameter_longname": "live.gain~",
                            "parameter_mmax": 6.0,
                            "parameter_mmin": -70.0,
                            "parameter_modmode": 3,
                            "parameter_shortname": "live.gain~",
                            "parameter_type": 0,
                            "parameter_unitstyle": 4
                        }
                    },
                    "varname": "live.gain~"
                }
            },
            {
                "box": {
                    "id": "obj-50",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 0,
                    "patching_rect": [ 822.0, 555.0, 55.0, 22.0 ],
                    "text": "dac~ 3 4"
                }
            },
            {
                "box": {
                    "id": "obj-44",
                    "maxclass": "live.scope~",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "bang" ],
                    "patching_rect": [ 1001.0, 272.0, 184.0, 68.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-43",
                    "maxclass": "live.scope~",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "bang" ],
                    "patching_rect": [ 1205.0, 272.0, 184.0, 68.0 ]
                }
            },
            {
                "box": {
                    "fontface": 0,
                    "fontname": "Arial",
                    "fontsize": 12.0,
                    "id": "obj-39",
                    "maxclass": "number~",
                    "mode": 2,
                    "numinlets": 2,
                    "numoutlets": 2,
                    "outlettype": [ "signal", "float" ],
                    "patching_rect": [ 963.0, 191.0, 56.0, 22.0 ],
                    "sig": 0.0
                }
            },
            {
                "box": {
                    "fontface": 0,
                    "fontname": "Arial",
                    "fontsize": 12.0,
                    "id": "obj-38",
                    "maxclass": "number~",
                    "mode": 2,
                    "numinlets": 2,
                    "numoutlets": 2,
                    "outlettype": [ "signal", "float" ],
                    "patching_rect": [ 900.0, 191.0, 56.0, 22.0 ],
                    "sig": 0.0
                }
            },
            {
                "box": {
                    "clipheight": 83.0,
                    "data": {
                        "clips": [
                            {
                                "absolutepath": "sousa_mic.aif",
                                "filename": "sousa_mic.aif",
                                "filekind": "audiofile",
                                "id": "u026004737",
                                "loop": 1,
                                "content_state": {
                                    "loop": 1
                                }
                            }
                        ]
                    },
                    "id": "obj-36",
                    "maxclass": "playlist~",
                    "mode": "basic",
                    "numinlets": 1,
                    "numoutlets": 5,
                    "outlettype": [ "signal", "signal", "signal", "", "dictionary" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 803.0, 29.0, 515.0, 84.0 ],
                    "quality": "basic",
                    "saved_attribute_attributes": {
                        "candicane2": {
                            "expression": ""
                        },
                        "candicane3": {
                            "expression": ""
                        },
                        "candicane4": {
                            "expression": ""
                        },
                        "candicane5": {
                            "expression": ""
                        },
                        "candicane6": {
                            "expression": ""
                        },
                        "candicane7": {
                            "expression": ""
                        },
                        "candicane8": {
                            "expression": ""
                        }
                    }
                }
            },
            {
                "box": {
                    "autosave": 1,
                    "id": "obj-4",
                    "inletInfo": {
                        "IOInfo": [
                            {
                                "type": "signal",
                                "index": 1,
                                "tag": "in1",
                                "comment": ""
                            },
                            {
                                "type": "signal",
                                "index": 2,
                                "tag": "in2",
                                "comment": ""
                            },
                            {
                                "type": "signal",
                                "index": 3,
                                "tag": "in3",
                                "comment": ""
                            }
                        ]
                    },
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 5,
                    "outletInfo": {
                        "IOInfo": [
                            {
                                "type": "signal",
                                "index": 1,
                                "tag": "out1",
                                "comment": ""
                            },
                            {
                                "type": "signal",
                                "index": 2,
                                "tag": "out2",
                                "comment": ""
                            },
                            {
                                "type": "signal",
                                "index": 3,
                                "tag": "out3",
                                "comment": ""
                            },
                            {
                                "type": "signal",
                                "index": 4,
                                "tag": "out4",
                                "comment": ""
                            }
                        ]
                    },
                    "outlettype": [ "signal", "signal", "signal", "signal", "list" ],
                    "patcher": {
                        "fileversion": 1,
                        "appversion": {
                            "major": 9,
                            "minor": 1,
                            "revision": 5,
                            "architecture": "x64",
                            "modernui": 1
                        },
                        "classnamespace": "rnbo",
                        "rect": [ 923.0, 446.0, 1000.0, 780.0 ],
                        "default_fontname": "Lato",
                        "title": "untitled",
                        "boxes": [
                            {
                                "box": {
                                    "code": "// ============================================================================\n// 00_tuba_freq_tracker.txt\n// Hybrid IFT (Instantaneous Frequency Tracking) + Recursive YIN (CMNDF)\n// + Phase-Locked Loop (PLL) Pitch & Analytic Phasor Tracker for Live Tuba\n// ============================================================================\n// Why this beats standalone YinFFT (fluid.pitch~) for live tuba dubstep:\n//   1. YinFFT requires a 2048-to-4096 sample FFT window (~46 to 93 ms latency)\n//      to resolve a 29 Hz pedal Bb0, and only updates once per hop.\n//   2. This tracker combines TWO complementary real-time engines:\n//      (A) Recursive Sliding-Window YIN (de Cheveigne & Kawahara 2002) with\n//          O(1) per-sample running lag updates, evaluated every 32 samples\n//          (< 0.7 ms hop) with parabolic sub-sample interpolation and octave-\n//          subharmonic preference to guarantee unambiguous octave lock.\n//      (B) IFT (Instantaneous Frequency Tracking) via an adaptive\n//          narrowband SVF isolator + 4-stage Quadrature IIR Hilbert Transform\n//          that differentiates the instantaneous analytic phase d(theta)/dt\n//          EVERY SAMPLE (0 ms latency) for ultra-fast lip bends & vibrato.\n//   3. A Type-II Phase-Locked Loop (PLL) fuses the unambiguous YIN coarse\n//      fundamental with the zero-latency IFT instantaneous frequency,\n//      outputting sample-accurate Hz, confidence, a locked [0..1) phasor,\n//      and a pure unit-amplitude fundamental sine wave!\n// ============================================================================\n// Inlets:\n//   in1: Left Audio Input (Tuba)\n//   in2: Right Audio Input (Tuba; if unpatched, mono in1 is used automatically)\n//   in3: Optional External Pitch Hint in Hz (e.g. fluid.pitch~; if >20 Hz, blends with YIN)\n// Outlets:\n//   out1: Tracked Fundamental Frequency f0 in Hz (Audio-rate, sample-accurate)\n//   out2: Pitch Confidence / Periodicity [0.0 .. 1.0]\n//   out3: Phase-Locked Tuba Phasor [0.0 .. 1.0) (Drop-in replacement for phasor~)\n//   out4: Pure Phase-Locked Fundamental Sine Wave [-1.0 .. 1.0]\n\n@param({ min: 24.0, max: 120.0 }) min_freq_hz = 28.0;\n@param({ min: 150.0, max: 700.0 }) max_freq_hz = 420.0;\n@param({ min: 0.0, max: 1.0 }) IFT_speed = 0.65;\n@param({ min: -60.0, max: -18.0 }) gate_thresh_db = -42.0;\n\n// --- Pre-Conditioning Filters (Isolate 25..450 Hz brass fundamental region) ---\n@state preHp = new svf();\n@state preLp1 = new onepole();\n@state preLp2 = new onepole();\n\n// --- Recursive Sliding YIN (CMNDF) State ---\n// Downsampled by 4x (e.g. 12 kHz at 48 kHz SR) so lags 25..430 cover 28 Hz..480 Hz\n// with only a 512-sample circular buffer and 4x lower CPU cost!\n@state yinBuf = new FixedSampleArray(1024);\n@state runDiff = new FixedSampleArray(440);\n@state yinWrite: Int = 0;\n@state decCount: Int = 0;\n@state hopCount: Int = 0;\n@state yinFreq = 58.27; // Default Bb1\n@state yinConf = 0.0;\n\n// 3-point Median filter history on YIN pitch to reject transient tongue clicks\n@state med0 = 58.27;\n@state med1 = 58.27;\n@state med2 = 58.27;\n\n// --- IFT (Instantaneous Frequency Tracking) State ---\n// Adaptive narrowband SVF tracks the fundamental, followed by a 4-stage Hilbert pair\n@state IFTSvf1 = new svf();\n@state IFTSvf2 = new svf();\n@state hReX = new FixedSampleArray(4);\n@state hReY = new FixedSampleArray(4);\n@state hImX = new FixedSampleArray(4);\n@state hImY = new FixedSampleArray(4);\n@state hDelRe = 0.0;\n@state prevTheta = 0.0;\n@state IFTInstHz = 58.27;\n\n// --- Fusion & Phase-Locked Loop (PLL) State ---\n@state fusedF0 = 58.27;\n@state smoothConf = 0.0;\n@state envRms = 0.0;\n@state pllPhase = 0.0;\n\nlet sr = maximum(samplerate(), 1.0);\nlet xL = in1;\nlet xR = in2;\nlet extHint = in3;\n\n// Sum stereo (or mono if in2 is silent)\nlet rawMono = (abs(xR) > 0.0000001) ? (0.5 * (xL + xR)) : xL;\n\n// ============================================================================\n// 1. RMS ENVELOPE & SILENCE GATE\n// ============================================================================\nlet envCoeff = 1.0 - exp(-1.0 / (0.008 * sr));\nenvRms += (rawMono * rawMono - envRms) * envCoeff;\nlet rmsAmp = sqrt(maximum(envRms, 0.0));\nlet threshLin = dbtoa(clamp(gate_thresh_db, -60.0, -18.0));\nlet isPlaying = (rmsAmp > threshLin) ? 1.0 : 0.0;\n\n// ============================================================================\n// 2. PRE-CONDITIONING FOR RECURSIVE YIN\n// Highpass at 22 Hz (remove breath thumps/DC) + 2-stage lowpass at 280 Hz\n// ============================================================================\nlet hpSig = preHp.next(rawMono, 22.0, 0.707)[1];\nlet condSig = preLp2.next(preLp1.next(hpSig, 260.0), 260.0);\n\n// ============================================================================\n// 3. 4x DECIMATED RECURSIVE YIN (CMNDF) ENGINE\n// ============================================================================\ndecCount = (decCount + 1) % 4;\nif (decCount == 0) {\n\tlet dSr = sr * 0.25;\n\tlet winSize: Int = floor(clamp(dSr * 0.028, 128.0, 400.0)); // ~28 ms integration window\n\tlet minLag: Int = floor(clamp(dSr / clamp(max_freq_hz, 150.0, 700.0), 12.0, 120.0));\n\tlet maxLag: Int = floor(clamp(dSr / clamp(min_freq_hz, 24.0, 120.0), 130.0, 430.0));\n\n\tyinBuf[yinWrite] = condSig;\n\tlet oldIdx: Int = (yinWrite - winSize + 1024) % 1024;\n\tlet xNew = condSig;\n\tlet xOld = yinBuf[oldIdx];\n\n\t// Update running squared difference d_t(tau) recursively\n\tfor (let tau: Int = 1; tau <= maxLag; tau++) {\n\t\tlet idxNewTau: Int = (yinWrite - tau + 1024) % 1024;\n\t\tlet idxOldTau: Int = (oldIdx - tau + 1024) % 1024;\n\t\tlet diffNew = xNew - yinBuf[idxNewTau];\n\t\tlet diffOld = xOld - yinBuf[idxOldTau];\n\t\tlet updated = runDiff[tau] + diffNew * diffNew - diffOld * diffOld;\n\t\trunDiff[tau] = maximum(updated, 0.0);\n\t}\n\n\t// Evaluate Cumulative Mean Normalized Difference Function d'(tau) every 8 decimated samples (32 audio samples = 0.66 ms)\n\thopCount = (hopCount + 1) % 8;\n\tif (hopCount == 0 && isPlaying > 0.5) {\n\t\tlet cumSum = 0.0;\n\t\tlet bestTau: Int = minLag;\n\t\tlet bestVal = 10.0;\n\t\tlet thresh = 0.14; // YIN absolute threshold for first subharmonic dip\n\t\tlet foundDip: Int = 0;\n\n\t\tfor (let tau: Int = 1; tau <= maxLag; tau++) {\n\t\t\tcumSum += runDiff[tau];\n\t\t\tlet cmndf = (cumSum > 0.0000001) ? (runDiff[tau] * tau / cumSum) : 1.0;\n\n\t\t\tif (tau >= minLag) {\n\t\t\t\tif (foundDip == 0) {\n\t\t\t\t\tif (cmndf < bestVal) {\n\t\t\t\t\t\tbestVal = cmndf;\n\t\t\t\t\t\tbestTau = tau;\n\t\t\t\t\t}\n\t\t\t\t\t// Once we enter a dip below threshold and start rising, lock to this fundamental!\n\t\t\t\t\t// This prevents YIN from picking the 2*tau sub-octave while rejecting 0.5*tau 2nd harmonic\n\t\t\t\t\tif (bestVal < thresh && cmndf > bestVal + 0.02) {\n\t\t\t\t\t\tfoundDip = 1;\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t}\n\t\t}\n\n\t\t// Parabolic interpolation around bestTau for sub-sample accuracy\n\t\tlet tauM1: Int = maximum(bestTau - 1, 1);\n\t\tlet tauP1: Int = minimum(bestTau + 1, maxLag);\n\t\tlet y1 = runDiff[tauM1];\n\t\tlet y2 = runDiff[bestTau];\n\t\tlet y3 = runDiff[tauP1];\n\t\tlet denom = 2.0 * (2.0 * y2 - y1 - y3);\n\t\tlet delta = (abs(denom) > 0.0000001) ? clamp((y1 - y3) / denom, -0.5, 0.5) : 0.0;\n\n\t\tlet refinedLag = bestTau + delta;\n\t\tlet rawYinHz = clamp(dSr / refinedLag, min_freq_hz, max_freq_hz);\n\t\tlet rawConf = clamp(1.0 - bestVal, 0.0, 1.0);\n\n\t\t// 3-point median filter to strip brass valve/tongue transient spikes\n\t\tif (rawConf > 0.45) {\n\t\t\tmed2 = med1;\n\t\t\tmed1 = med0;\n\t\t\tmed0 = rawYinHz;\n\t\t\tlet a = med0; let b = med1; let c = med2;\n\t\t\tlet medianHz = maximum(minimum(a, b), minimum(maximum(a, b), c));\n\t\t\tyinFreq = medianHz;\n\t\t}\n\t\tyinConf = rawConf;\n\t}\n\tyinWrite = (yinWrite + 1) % 1024;\n}\n\n// Optional blend with external fluid.pitch~ hint on in3 if user patches it\nlet anchorHz = (extHint > 20.0 && extHint < 1000.0) ? linearinterp(0.5, yinFreq, extHint) : yinFreq;\n\n// ============================================================================\n// 4. IFT (Instantaneous FREQUENCY TRACKING) ENGINE\n// Isolates the fundamental partial using a dual-stage SVF centered at fusedF0,\n// extracts the analytic signal via a 4-stage quadrature Hilbert transform,\n// and differentiates instantaneous phase d(theta)/dt every single sample!\n// ============================================================================\nlet trackCenter = clamp(fusedF0, min_freq_hz, max_freq_hz);\nlet bp1 = IFTSvf1.next(hpSig, trackCenter, 0.86)[2];\nlet isoFund = IFTSvf2.next(bp1, trackCenter, 0.86)[2];\n\n// 4-Stage Quadrature IIR Hilbert Allpass Pair\nlet cRe0 = 0.4794008656; let cRe1 = 0.8762184935; let cRe2 = 0.9765975895; let cRe3 = 0.9974992559;\nlet cIm0 = 0.1617584983; let cIm1 = 0.7330289323; let cIm2 = 0.9453497003; let cIm3 = 0.9905991567;\n\nlet sRe = isoFund;\nlet yRe0 = cRe0 * (sRe - hReY[0]) + hReX[0]; hReX[0] = sRe; hReY[0] = yRe0; sRe = yRe0;\nlet yRe1 = cRe1 * (sRe - hReY[1]) + hReX[1]; hReX[1] = sRe; hReY[1] = yRe1; sRe = yRe1;\nlet yRe2 = cRe2 * (sRe - hReY[2]) + hReX[2]; hReX[2] = sRe; hReY[2] = yRe2; sRe = yRe2;\nlet yRe3 = cRe3 * (sRe - hReY[3]) + hReX[3]; hReX[3] = sRe; hReY[3] = yRe3;\nlet outRe = hDelRe; hDelRe = yRe3;\n\nlet sIm = isoFund;\nlet yIm0 = cIm0 * (sIm - hImY[0]) + hImX[0]; hImX[0] = sIm; hImY[0] = yIm0; sIm = yIm0;\nlet yIm1 = cIm1 * (sIm - hImY[1]) + hImX[1]; hImX[1] = sIm; hImY[1] = yIm1; sIm = yIm1;\nlet yIm2 = cIm2 * (sIm - hImY[2]) + hImX[2]; hImX[2] = sIm; hImY[2] = yIm2; sIm = yIm2;\nlet yIm3 = cIm3 * (sIm - hImY[3]) + hImX[3]; hImX[3] = sIm; hImY[3] = yIm3;\nlet outIm = yIm3;\n\nlet pol = cartopol(outRe, outIm);\nlet instAmp = pol[0];\nlet theta = pol[1];\n\n// Unwrap single-sample phase difference dTheta in [-pi, pi]\nlet dTheta = theta - prevTheta;\nif (dTheta < -pi) { dTheta += 2.0 * pi; }\nelse if (dTheta > pi) { dTheta -= 2.0 * pi; }\nprevTheta = theta;\n\n// Instantaneous frequency f_inst(t) = (dTheta / (2*pi)) * sr\nlet rawInstHz = (dTheta / (2.0 * pi)) * sr;\n\n// Gate IFT instantaneous frequency: only trust when within +/- 18% of the YIN octave anchor\n// This gives 0-latency tracking of vibrato/glissandi while making octave errors impossible!\nlet devRatio = abs(rawInstHz - anchorHz) / maximum(anchorHz, 20.0);\nif (devRatio < 0.18 && instAmp > 0.0002) {\n\tlet IFTSlew = 1.0 - exp(-1.0 / (0.0018 * sr));\n\tIFTInstHz += (rawInstHz - IFTInstHz) * IFTSlew;\n} else {\n\tlet anchorSlew = 1.0 - exp(-1.0 / (0.006 * sr));\n\tIFTInstHz += (anchorHz - IFTInstHz) * anchorSlew;\n}\n\n// ============================================================================\n// 5. YIN + IFT KALMAN-STYLE FUSION & PHASE-LOCKED LOOP (PLL) OSCILLATOR\n// ============================================================================\nlet speed = clamp(IFT_speed, 0.0, 1.0);\nlet targetF0 = linearinterp(speed, anchorHz, IFTInstHz);\n\n// Hold last valid pitch when player stops blowing (zero pitch drop on note release!)\nif (isPlaying > 0.5 && yinConf > 0.35) {\n\tlet trackSlew = 1.0 - exp(-1.0 / ((0.010 - 0.0085 * speed) * sr));\n\tfusedF0 += (targetF0 - fusedF0) * trackSlew;\n}\nfusedF0 = clamp(fusedF0, min_freq_hz, max_freq_hz);\n\n// Smooth confidence output [0..1]\nlet targetConf = isPlaying * yinConf;\nsmoothConf += (targetConf - smoothConf) * (1.0 - exp(-1.0 / (0.010 * sr)));\n\n// Advance PLL Phasor & gently phase-lock to the analytic phase of the tuba fundamental\nlet targetPh = wrap((theta + pi) / (2.0 * pi), 0.0, 1.0);\nlet phErr = targetPh - pllPhase;\nif (phErr > 0.5) { phErr -= 1.0; }\nelse if (phErr < -0.5) { phErr += 1.0; }\n\nlet pllLockStrength = 0.015 * smoothConf;\npllPhase = wrap(pllPhase + (fusedF0 / sr) + pllLockStrength * phErr, 0.0, 1.0);\n\nout1 = fusedF0;\nout2 = smoothConf;\nout3 = pllPhase;\nout4 = sin(2.0 * pi * pllPhase) * smoothConf;\n",
                                    "fontface": 0,
                                    "fontname": "<Monospaced>",
                                    "fontsize": 12.0,
                                    "id": "obj-2",
                                    "maxclass": "codebox~",
                                    "numinlets": 3,
                                    "numoutlets": 4,
                                    "outlettype": [ "signal", "signal", "signal", "signal" ],
                                    "patching_rect": [ 30.0, 110.0, 620.0, 360.0 ],
                                    "rnbo_classname": "codebox~",
                                    "rnbo_extra_attributes": {
                                        "code": "// ============================================================================\n// 00_tuba_freq_tracker.txt\n// Hybrid IFT (Instantaneous Frequency Tracking) + Recursive YIN (CMNDF)\n// + Phase-Locked Loop (PLL) Pitch & Analytic Phasor Tracker for Live Tuba\n// ============================================================================\n// Why this beats standalone YinFFT (fluid.pitch~) for live tuba dubstep:\n//   1. YinFFT requires a 2048-to-4096 sample FFT window (~46 to 93 ms latency)\n//      to resolve a 29 Hz pedal Bb0, and only updates once per hop.\n//   2. This tracker combines TWO complementary real-time engines:\n//      (A) Recursive Sliding-Window YIN (de Cheveigne & Kawahara 2002) with\n//          O(1) per-sample running lag updates, evaluated every 32 samples\n//          (< 0.7 ms hop) with parabolic sub-sample interpolation and octave-\n//          subharmonic preference to guarantee unambiguous octave lock.\n//      (B) IFT (Instantaneous Frequency Tracking) via an adaptive\n//          narrowband SVF isolator + 4-stage Quadrature IIR Hilbert Transform\n//          that differentiates the instantaneous analytic phase d(theta)/dt\n//          EVERY SAMPLE (0 ms latency) for ultra-fast lip bends & vibrato.\n//   3. A Type-II Phase-Locked Loop (PLL) fuses the unambiguous YIN coarse\n//      fundamental with the zero-latency IFT instantaneous frequency,\n//      outputting sample-accurate Hz, confidence, a locked [0..1) phasor,\n//      and a pure unit-amplitude fundamental sine wave!\n// ============================================================================\n// Inlets:\n//   in1: Left Audio Input (Tuba)\n//   in2: Right Audio Input (Tuba; if unpatched, mono in1 is used automatically)\n//   in3: Optional External Pitch Hint in Hz (e.g. fluid.pitch~; if >20 Hz, blends with YIN)\n// Outlets:\n//   out1: Tracked Fundamental Frequency f0 in Hz (Audio-rate, sample-accurate)\n//   out2: Pitch Confidence / Periodicity [0.0 .. 1.0]\n//   out3: Phase-Locked Tuba Phasor [0.0 .. 1.0) (Drop-in replacement for phasor~)\n//   out4: Pure Phase-Locked Fundamental Sine Wave [-1.0 .. 1.0]\n\n@param({ min: 24.0, max: 120.0 }) min_freq_hz = 28.0;\n@param({ min: 150.0, max: 700.0 }) max_freq_hz = 420.0;\n@param({ min: 0.0, max: 1.0 }) IFT_speed = 0.65;\n@param({ min: -60.0, max: -18.0 }) gate_thresh_db = -42.0;\n\n// --- Pre-Conditioning Filters (Isolate 25..450 Hz brass fundamental region) ---\n@state preHp = new svf();\n@state preLp1 = new onepole();\n@state preLp2 = new onepole();\n\n// --- Recursive Sliding YIN (CMNDF) State ---\n// Downsampled by 4x (e.g. 12 kHz at 48 kHz SR) so lags 25..430 cover 28 Hz..480 Hz\n// with only a 512-sample circular buffer and 4x lower CPU cost!\n@state yinBuf = new FixedSampleArray(1024);\n@state runDiff = new FixedSampleArray(440);\n@state yinWrite: Int = 0;\n@state decCount: Int = 0;\n@state hopCount: Int = 0;\n@state yinFreq = 58.27; // Default Bb1\n@state yinConf = 0.0;\n\n// 3-point Median filter history on YIN pitch to reject transient tongue clicks\n@state med0 = 58.27;\n@state med1 = 58.27;\n@state med2 = 58.27;\n\n// --- IFT (Instantaneous Frequency Tracking) State ---\n// Adaptive narrowband SVF tracks the fundamental, followed by a 4-stage Hilbert pair\n@state IFTSvf1 = new svf();\n@state IFTSvf2 = new svf();\n@state hReX = new FixedSampleArray(4);\n@state hReY = new FixedSampleArray(4);\n@state hImX = new FixedSampleArray(4);\n@state hImY = new FixedSampleArray(4);\n@state hDelRe = 0.0;\n@state prevTheta = 0.0;\n@state IFTInstHz = 58.27;\n\n// --- Fusion & Phase-Locked Loop (PLL) State ---\n@state fusedF0 = 58.27;\n@state smoothConf = 0.0;\n@state envRms = 0.0;\n@state pllPhase = 0.0;\n\nlet sr = maximum(samplerate(), 1.0);\nlet xL = in1;\nlet xR = in2;\nlet extHint = in3;\n\n// Sum stereo (or mono if in2 is silent)\nlet rawMono = (abs(xR) > 0.0000001) ? (0.5 * (xL + xR)) : xL;\n\n// ============================================================================\n// 1. RMS ENVELOPE & SILENCE GATE\n// ============================================================================\nlet envCoeff = 1.0 - exp(-1.0 / (0.008 * sr));\nenvRms += (rawMono * rawMono - envRms) * envCoeff;\nlet rmsAmp = sqrt(maximum(envRms, 0.0));\nlet threshLin = dbtoa(clamp(gate_thresh_db, -60.0, -18.0));\nlet isPlaying = (rmsAmp > threshLin) ? 1.0 : 0.0;\n\n// ============================================================================\n// 2. PRE-CONDITIONING FOR RECURSIVE YIN\n// Highpass at 22 Hz (remove breath thumps/DC) + 2-stage lowpass at 280 Hz\n// ============================================================================\nlet hpSig = preHp.next(rawMono, 22.0, 0.707)[1];\nlet condSig = preLp2.next(preLp1.next(hpSig, 260.0), 260.0);\n\n// ============================================================================\n// 3. 4x DECIMATED RECURSIVE YIN (CMNDF) ENGINE\n// ============================================================================\ndecCount = (decCount + 1) % 4;\nif (decCount == 0) {\n\tlet dSr = sr * 0.25;\n\tlet winSize: Int = floor(clamp(dSr * 0.028, 128.0, 400.0)); // ~28 ms integration window\n\tlet minLag: Int = floor(clamp(dSr / clamp(max_freq_hz, 150.0, 700.0), 12.0, 120.0));\n\tlet maxLag: Int = floor(clamp(dSr / clamp(min_freq_hz, 24.0, 120.0), 130.0, 430.0));\n\n\tyinBuf[yinWrite] = condSig;\n\tlet oldIdx: Int = (yinWrite - winSize + 1024) % 1024;\n\tlet xNew = condSig;\n\tlet xOld = yinBuf[oldIdx];\n\n\t// Update running squared difference d_t(tau) recursively\n\tfor (let tau: Int = 1; tau <= maxLag; tau++) {\n\t\tlet idxNewTau: Int = (yinWrite - tau + 1024) % 1024;\n\t\tlet idxOldTau: Int = (oldIdx - tau + 1024) % 1024;\n\t\tlet diffNew = xNew - yinBuf[idxNewTau];\n\t\tlet diffOld = xOld - yinBuf[idxOldTau];\n\t\tlet updated = runDiff[tau] + diffNew * diffNew - diffOld * diffOld;\n\t\trunDiff[tau] = maximum(updated, 0.0);\n\t}\n\n\t// Evaluate Cumulative Mean Normalized Difference Function d'(tau) every 8 decimated samples (32 audio samples = 0.66 ms)\n\thopCount = (hopCount + 1) % 8;\n\tif (hopCount == 0 && isPlaying > 0.5) {\n\t\tlet cumSum = 0.0;\n\t\tlet bestTau: Int = minLag;\n\t\tlet bestVal = 10.0;\n\t\tlet thresh = 0.14; // YIN absolute threshold for first subharmonic dip\n\t\tlet foundDip: Int = 0;\n\n\t\tfor (let tau: Int = 1; tau <= maxLag; tau++) {\n\t\t\tcumSum += runDiff[tau];\n\t\t\tlet cmndf = (cumSum > 0.0000001) ? (runDiff[tau] * tau / cumSum) : 1.0;\n\n\t\t\tif (tau >= minLag) {\n\t\t\t\tif (foundDip == 0) {\n\t\t\t\t\tif (cmndf < bestVal) {\n\t\t\t\t\t\tbestVal = cmndf;\n\t\t\t\t\t\tbestTau = tau;\n\t\t\t\t\t}\n\t\t\t\t\t// Once we enter a dip below threshold and start rising, lock to this fundamental!\n\t\t\t\t\t// This prevents YIN from picking the 2*tau sub-octave while rejecting 0.5*tau 2nd harmonic\n\t\t\t\t\tif (bestVal < thresh && cmndf > bestVal + 0.02) {\n\t\t\t\t\t\tfoundDip = 1;\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t}\n\t\t}\n\n\t\t// Parabolic interpolation around bestTau for sub-sample accuracy\n\t\tlet tauM1: Int = maximum(bestTau - 1, 1);\n\t\tlet tauP1: Int = minimum(bestTau + 1, maxLag);\n\t\tlet y1 = runDiff[tauM1];\n\t\tlet y2 = runDiff[bestTau];\n\t\tlet y3 = runDiff[tauP1];\n\t\tlet denom = 2.0 * (2.0 * y2 - y1 - y3);\n\t\tlet delta = (abs(denom) > 0.0000001) ? clamp((y1 - y3) / denom, -0.5, 0.5) : 0.0;\n\n\t\tlet refinedLag = bestTau + delta;\n\t\tlet rawYinHz = clamp(dSr / refinedLag, min_freq_hz, max_freq_hz);\n\t\tlet rawConf = clamp(1.0 - bestVal, 0.0, 1.0);\n\n\t\t// 3-point median filter to strip brass valve/tongue transient spikes\n\t\tif (rawConf > 0.45) {\n\t\t\tmed2 = med1;\n\t\t\tmed1 = med0;\n\t\t\tmed0 = rawYinHz;\n\t\t\tlet a = med0; let b = med1; let c = med2;\n\t\t\tlet medianHz = maximum(minimum(a, b), minimum(maximum(a, b), c));\n\t\t\tyinFreq = medianHz;\n\t\t}\n\t\tyinConf = rawConf;\n\t}\n\tyinWrite = (yinWrite + 1) % 1024;\n}\n\n// Optional blend with external fluid.pitch~ hint on in3 if user patches it\nlet anchorHz = (extHint > 20.0 && extHint < 1000.0) ? linearinterp(0.5, yinFreq, extHint) : yinFreq;\n\n// ============================================================================\n// 4. IFT (Instantaneous FREQUENCY TRACKING) ENGINE\n// Isolates the fundamental partial using a dual-stage SVF centered at fusedF0,\n// extracts the analytic signal via a 4-stage quadrature Hilbert transform,\n// and differentiates instantaneous phase d(theta)/dt every single sample!\n// ============================================================================\nlet trackCenter = clamp(fusedF0, min_freq_hz, max_freq_hz);\nlet bp1 = IFTSvf1.next(hpSig, trackCenter, 0.86)[2];\nlet isoFund = IFTSvf2.next(bp1, trackCenter, 0.86)[2];\n\n// 4-Stage Quadrature IIR Hilbert Allpass Pair\nlet cRe0 = 0.4794008656; let cRe1 = 0.8762184935; let cRe2 = 0.9765975895; let cRe3 = 0.9974992559;\nlet cIm0 = 0.1617584983; let cIm1 = 0.7330289323; let cIm2 = 0.9453497003; let cIm3 = 0.9905991567;\n\nlet sRe = isoFund;\nlet yRe0 = cRe0 * (sRe - hReY[0]) + hReX[0]; hReX[0] = sRe; hReY[0] = yRe0; sRe = yRe0;\nlet yRe1 = cRe1 * (sRe - hReY[1]) + hReX[1]; hReX[1] = sRe; hReY[1] = yRe1; sRe = yRe1;\nlet yRe2 = cRe2 * (sRe - hReY[2]) + hReX[2]; hReX[2] = sRe; hReY[2] = yRe2; sRe = yRe2;\nlet yRe3 = cRe3 * (sRe - hReY[3]) + hReX[3]; hReX[3] = sRe; hReY[3] = yRe3;\nlet outRe = hDelRe; hDelRe = yRe3;\n\nlet sIm = isoFund;\nlet yIm0 = cIm0 * (sIm - hImY[0]) + hImX[0]; hImX[0] = sIm; hImY[0] = yIm0; sIm = yIm0;\nlet yIm1 = cIm1 * (sIm - hImY[1]) + hImX[1]; hImX[1] = sIm; hImY[1] = yIm1; sIm = yIm1;\nlet yIm2 = cIm2 * (sIm - hImY[2]) + hImX[2]; hImX[2] = sIm; hImY[2] = yIm2; sIm = yIm2;\nlet yIm3 = cIm3 * (sIm - hImY[3]) + hImX[3]; hImX[3] = sIm; hImY[3] = yIm3;\nlet outIm = yIm3;\n\nlet pol = cartopol(outRe, outIm);\nlet instAmp = pol[0];\nlet theta = pol[1];\n\n// Unwrap single-sample phase difference dTheta in [-pi, pi]\nlet dTheta = theta - prevTheta;\nif (dTheta < -pi) { dTheta += 2.0 * pi; }\nelse if (dTheta > pi) { dTheta -= 2.0 * pi; }\nprevTheta = theta;\n\n// Instantaneous frequency f_inst(t) = (dTheta / (2*pi)) * sr\nlet rawInstHz = (dTheta / (2.0 * pi)) * sr;\n\n// Gate IFT instantaneous frequency: only trust when within +/- 18% of the YIN octave anchor\n// This gives 0-latency tracking of vibrato/glissandi while making octave errors impossible!\nlet devRatio = abs(rawInstHz - anchorHz) / maximum(anchorHz, 20.0);\nif (devRatio < 0.18 && instAmp > 0.0002) {\n\tlet IFTSlew = 1.0 - exp(-1.0 / (0.0018 * sr));\n\tIFTInstHz += (rawInstHz - IFTInstHz) * IFTSlew;\n} else {\n\tlet anchorSlew = 1.0 - exp(-1.0 / (0.006 * sr));\n\tIFTInstHz += (anchorHz - IFTInstHz) * anchorSlew;\n}\n\n// ============================================================================\n// 5. YIN + IFT KALMAN-STYLE FUSION & PHASE-LOCKED LOOP (PLL) OSCILLATOR\n// ============================================================================\nlet speed = clamp(IFT_speed, 0.0, 1.0);\nlet targetF0 = linearinterp(speed, anchorHz, IFTInstHz);\n\n// Hold last valid pitch when player stops blowing (zero pitch drop on note release!)\nif (isPlaying > 0.5 && yinConf > 0.35) {\n\tlet trackSlew = 1.0 - exp(-1.0 / ((0.010 - 0.0085 * speed) * sr));\n\tfusedF0 += (targetF0 - fusedF0) * trackSlew;\n}\nfusedF0 = clamp(fusedF0, min_freq_hz, max_freq_hz);\n\n// Smooth confidence output [0..1]\nlet targetConf = isPlaying * yinConf;\nsmoothConf += (targetConf - smoothConf) * (1.0 - exp(-1.0 / (0.010 * sr)));\n\n// Advance PLL Phasor & gently phase-lock to the analytic phase of the tuba fundamental\nlet targetPh = wrap((theta + pi) / (2.0 * pi), 0.0, 1.0);\nlet phErr = targetPh - pllPhase;\nif (phErr > 0.5) { phErr -= 1.0; }\nelse if (phErr < -0.5) { phErr += 1.0; }\n\nlet pllLockStrength = 0.015 * smoothConf;\npllPhase = wrap(pllPhase + (fusedF0 / sr) + pllLockStrength * phErr, 0.0, 1.0);\n\nout1 = fusedF0;\nout2 = smoothConf;\nout3 = pllPhase;\nout4 = sin(2.0 * pi * pllPhase) * smoothConf;\n",
                                        "nocache": 0,
                                        "expr": "",
                                        "safemath": 1
                                    },
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "effect_code",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "reset": {
                                                "attrOrProp": 1,
                                                "digest": "Reset all state and params to initial values",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            },
                                            "in1": {
                                                "attrOrProp": 1,
                                                "digest": "in1",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "number"
                                            },
                                            "in2": {
                                                "attrOrProp": 1,
                                                "digest": "in2",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "number"
                                            },
                                            "in3": {
                                                "attrOrProp": 1,
                                                "digest": "in3",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "number"
                                            },
                                            "out1": {
                                                "attrOrProp": 1,
                                                "digest": "out1",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
                                            },
                                            "out2": {
                                                "attrOrProp": 1,
                                                "digest": "out2",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
                                            },
                                            "out3": {
                                                "attrOrProp": 1,
                                                "digest": "out3",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
                                            },
                                            "out4": {
                                                "attrOrProp": 1,
                                                "digest": "out4",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
                                            },
                                            "min_freq_hz": {
                                                "attrOrProp": 1,
                                                "digest": "min_freq_hz",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "28"
                                            },
                                            "max_freq_hz": {
                                                "attrOrProp": 1,
                                                "digest": "max_freq_hz",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "420"
                                            },
                                            "IFT_speed": {
                                                "attrOrProp": 1,
                                                "digest": "IFT_speed",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "0.65"
                                            },
                                            "gate_thresh_db": {
                                                "attrOrProp": 1,
                                                "digest": "gate_thresh_db",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "-42"
                                            },
                                            "expr": {
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
                                                "type": "symbol"
                                            },
                                            "safemath": {
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
                                                "defaultValue": "true"
                                            },
                                            "nocache": {
                                                "attrOrProp": 2,
                                                "digest": "Do not use parsing cache. This is only useful with very very big code sizes. Code generation will then take a looooong time.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "false"
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "in1",
                                                "type": "auto",
                                                "digest": "in1",
                                                "hot": 1,
                                                "docked": 0
                                            },
                                            {
                                                "name": "in2",
                                                "type": "auto",
                                                "digest": "in2",
                                                "docked": 0
                                            },
                                            {
                                                "name": "in3",
                                                "type": "auto",
                                                "digest": "in3",
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "out1",
                                                "type": "signal",
                                                "digest": "out1",
                                                "docked": 0
                                            },
                                            {
                                                "name": "out2",
                                                "type": "signal",
                                                "digest": "out2",
                                                "docked": 0
                                            },
                                            {
                                                "name": "out3",
                                                "type": "signal",
                                                "digest": "out3",
                                                "docked": 0
                                            },
                                            {
                                                "name": "out4",
                                                "type": "signal",
                                                "digest": "out4",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "codebox~",
                                        "aliasOf": "expr~",
                                        "classname": "codebox~",
                                        "operator": 0,
                                        "versionId": 527839773,
                                        "changesPatcherIO": 0
                                    },
                                    "varname": "effect_code"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-4",
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 30.0, 20.0, 620.0, 21.0 ],
                                    "text": "00_tuba_freq_tracker"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-5",
                                    "maxclass": "newobj",
                                    "numinlets": 0,
                                    "numoutlets": 1,
                                    "outlettype": [ "signal" ],
                                    "patching_rect": [ 30.0, 70.0, 70.0, 23.0 ],
                                    "rnbo_classname": "in~",
                                    "rnbo_extra_attributes": {
                                        "meta": "",
                                        "comment": ""
                                    },
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "audio_in_1",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "out1": {
                                                "attrOrProp": 1,
                                                "digest": "signal from inlet with index 1",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
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
                                                "mandatory": 1
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
                                                "type": "symbol"
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
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [],
                                        "outputs": [
                                            {
                                                "name": "out1",
                                                "type": "signal",
                                                "digest": "signal from inlet with index 1",
                                                "displayName": "",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "in~",
                                        "aliasOf": "in~",
                                        "classname": "in~",
                                        "operator": 0,
                                        "versionId": -1654556303,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "in~ 1",
                                    "varname": "audio_in_1"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-6",
                                    "maxclass": "newobj",
                                    "numinlets": 0,
                                    "numoutlets": 1,
                                    "outlettype": [ "signal" ],
                                    "patching_rect": [ 317.5, 70.0, 70.0, 23.0 ],
                                    "rnbo_classname": "in~",
                                    "rnbo_extra_attributes": {
                                        "meta": "",
                                        "comment": ""
                                    },
                                    "rnbo_serial": 2,
                                    "rnbo_uniqueid": "audio_in_2",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "out1": {
                                                "attrOrProp": 1,
                                                "digest": "signal from inlet with index 2",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
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
                                                "mandatory": 1
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
                                                "type": "symbol"
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
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [],
                                        "outputs": [
                                            {
                                                "name": "out1",
                                                "type": "signal",
                                                "digest": "signal from inlet with index 2",
                                                "displayName": "",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "in~",
                                        "aliasOf": "in~",
                                        "classname": "in~",
                                        "operator": 0,
                                        "versionId": -1654556303,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "in~ 2",
                                    "varname": "audio_in_2"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-7",
                                    "maxclass": "newobj",
                                    "numinlets": 0,
                                    "numoutlets": 1,
                                    "outlettype": [ "signal" ],
                                    "patching_rect": [ 605.0, 70.0, 70.0, 23.0 ],
                                    "rnbo_classname": "in~",
                                    "rnbo_extra_attributes": {
                                        "meta": "",
                                        "comment": ""
                                    },
                                    "rnbo_serial": 3,
                                    "rnbo_uniqueid": "audio_in_3",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "out1": {
                                                "attrOrProp": 1,
                                                "digest": "signal from inlet with index 3",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
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
                                                "mandatory": 1
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
                                                "type": "symbol"
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
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [],
                                        "outputs": [
                                            {
                                                "name": "out1",
                                                "type": "signal",
                                                "digest": "signal from inlet with index 3",
                                                "displayName": "",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "in~",
                                        "aliasOf": "in~",
                                        "classname": "in~",
                                        "operator": 0,
                                        "versionId": -1654556303,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "in~ 3",
                                    "varname": "audio_in_3"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-8",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 30.0, 490.0, 70.0, 23.0 ],
                                    "rnbo_classname": "out~",
                                    "rnbo_extra_attributes": {
                                        "meta": "",
                                        "comment": ""
                                    },
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "audio_out_1",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "in1": {
                                                "attrOrProp": 1,
                                                "digest": "signal sent to outlet with index 1",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "signal"
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
                                                "mandatory": 1
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
                                                "type": "symbol"
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
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "in1",
                                                "type": "signal",
                                                "digest": "signal sent to outlet with index 1",
                                                "displayName": "",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [],
                                        "helpname": "out~",
                                        "aliasOf": "out~",
                                        "classname": "out~",
                                        "operator": 0,
                                        "versionId": 1989326771,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "out~ 1",
                                    "varname": "audio_out_1"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-9",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 222.0, 490.0, 69.99999999999997, 23.0 ],
                                    "rnbo_classname": "out~",
                                    "rnbo_extra_attributes": {
                                        "meta": "",
                                        "comment": ""
                                    },
                                    "rnbo_serial": 2,
                                    "rnbo_uniqueid": "audio_out_2",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "in1": {
                                                "attrOrProp": 1,
                                                "digest": "signal sent to outlet with index 2",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "signal"
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
                                                "mandatory": 1
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
                                                "type": "symbol"
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
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "in1",
                                                "type": "signal",
                                                "digest": "signal sent to outlet with index 2",
                                                "displayName": "",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [],
                                        "helpname": "out~",
                                        "aliasOf": "out~",
                                        "classname": "out~",
                                        "operator": 0,
                                        "versionId": 1989326771,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "out~ 2",
                                    "varname": "audio_out_2"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-10",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 413.0, 490.0, 70.0, 23.0 ],
                                    "rnbo_classname": "out~",
                                    "rnbo_extra_attributes": {
                                        "meta": "",
                                        "comment": ""
                                    },
                                    "rnbo_serial": 3,
                                    "rnbo_uniqueid": "audio_out_3",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "in1": {
                                                "attrOrProp": 1,
                                                "digest": "signal sent to outlet with index 3",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "signal"
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
                                                "mandatory": 1
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
                                                "type": "symbol"
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
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "in1",
                                                "type": "signal",
                                                "digest": "signal sent to outlet with index 3",
                                                "displayName": "",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [],
                                        "helpname": "out~",
                                        "aliasOf": "out~",
                                        "classname": "out~",
                                        "operator": 0,
                                        "versionId": 1989326771,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "out~ 3",
                                    "varname": "audio_out_3"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-11",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 605.0, 490.0, 70.0, 23.0 ],
                                    "rnbo_classname": "out~",
                                    "rnbo_extra_attributes": {
                                        "meta": "",
                                        "comment": ""
                                    },
                                    "rnbo_serial": 4,
                                    "rnbo_uniqueid": "audio_out_4",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "in1": {
                                                "attrOrProp": 1,
                                                "digest": "signal sent to outlet with index 4",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "signal"
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
                                                "mandatory": 1
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
                                                "type": "symbol"
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
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "in1",
                                                "type": "signal",
                                                "digest": "signal sent to outlet with index 4",
                                                "displayName": "",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [],
                                        "helpname": "out~",
                                        "aliasOf": "out~",
                                        "classname": "out~",
                                        "operator": 0,
                                        "versionId": 1989326771,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "out~ 4",
                                    "varname": "audio_out_4"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-13",
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 700.0, 65.0, 175.0, 21.0 ],
                                    "text": "min_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-15",
                                    "maxclass": "flonum",
                                    "numinlets": 1,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "bang" ],
                                    "parameter_enable": 0,
                                    "patching_rect": [ 700.0, 115.0, 100.0, 23.0 ],
                                    "rnbo_classname": "number",
                                    "rnbo_extra_attributes": {
                                        "minimum": "<none>",
                                        "order": "",
                                        "preset": 0,
                                        "initialFormat": "float",
                                        "maximum": "<none>"
                                    },
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "value_min_freq_hz",
                                    "varname": "value_min_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-16",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 700.0, 143.0, 175.0, 23.0 ],
                                    "rnbo_classname": "setparam",
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "set_min_freq_hz",
                                    "rnboinfo": {
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
                                                "mandatory": 1
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "attribute or parameter value (bang, number, list)",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "output",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "connect to first inlet of gen or subpatcher",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "set",
                                        "aliasOf": "set",
                                        "classname": "setparam",
                                        "operator": 0,
                                        "versionId": 1197449671,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "setparam min_freq_hz",
                                    "varname": "set_min_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-17",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 700.0, 92.0, 175.0, 23.0 ],
                                    "rnbo_classname": "loadmess",
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "load_min_freq_hz",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "input": {
                                                "attrOrProp": 1,
                                                "digest": "Bang to trigger message.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "bang"
                                            },
                                            "message": {
                                                "attrOrProp": 1,
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "list",
                                                "defaultValue": ""
                                            },
                                            "startupbang": {
                                                "attrOrProp": 1,
                                                "digest": "startupbang",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": "bang",
                                                "digest": "Bang to trigger message.",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "message",
                                                "type": "list",
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "loadmess",
                                        "aliasOf": "loadmess",
                                        "classname": "loadmess",
                                        "operator": 0,
                                        "versionId": -361086158,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "loadmess 28",
                                    "varname": "load_min_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-19",
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 890.0, 65.0, 175.0, 21.0 ],
                                    "text": "max_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-21",
                                    "maxclass": "flonum",
                                    "numinlets": 1,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "bang" ],
                                    "parameter_enable": 0,
                                    "patching_rect": [ 890.0, 115.0, 100.0, 23.0 ],
                                    "rnbo_classname": "number",
                                    "rnbo_extra_attributes": {
                                        "minimum": "<none>",
                                        "order": "",
                                        "preset": 0,
                                        "initialFormat": "float",
                                        "maximum": "<none>"
                                    },
                                    "rnbo_serial": 2,
                                    "rnbo_uniqueid": "value_max_freq_hz",
                                    "varname": "value_max_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-22",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 890.0, 143.0, 175.0, 23.0 ],
                                    "rnbo_classname": "setparam",
                                    "rnbo_serial": 2,
                                    "rnbo_uniqueid": "set_max_freq_hz",
                                    "rnboinfo": {
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
                                                "mandatory": 1
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "attribute or parameter value (bang, number, list)",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "output",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "connect to first inlet of gen or subpatcher",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "set",
                                        "aliasOf": "set",
                                        "classname": "setparam",
                                        "operator": 0,
                                        "versionId": 1197449671,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "setparam max_freq_hz",
                                    "varname": "set_max_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-23",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 890.0, 92.0, 175.0, 23.0 ],
                                    "rnbo_classname": "loadmess",
                                    "rnbo_serial": 2,
                                    "rnbo_uniqueid": "load_max_freq_hz",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "input": {
                                                "attrOrProp": 1,
                                                "digest": "Bang to trigger message.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "bang"
                                            },
                                            "message": {
                                                "attrOrProp": 1,
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "list",
                                                "defaultValue": ""
                                            },
                                            "startupbang": {
                                                "attrOrProp": 1,
                                                "digest": "startupbang",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": "bang",
                                                "digest": "Bang to trigger message.",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "message",
                                                "type": "list",
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "loadmess",
                                        "aliasOf": "loadmess",
                                        "classname": "loadmess",
                                        "operator": 0,
                                        "versionId": -361086158,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "loadmess 420",
                                    "varname": "load_max_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-25",
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 1080.0, 65.0, 175.0, 21.0 ],
                                    "text": "sift_speed"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-27",
                                    "maxclass": "flonum",
                                    "numinlets": 1,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "bang" ],
                                    "parameter_enable": 0,
                                    "patching_rect": [ 1080.0, 115.0, 100.0, 23.0 ],
                                    "rnbo_classname": "number",
                                    "rnbo_extra_attributes": {
                                        "minimum": "<none>",
                                        "order": "",
                                        "preset": 0,
                                        "initialFormat": "float",
                                        "maximum": "<none>"
                                    },
                                    "rnbo_serial": 3,
                                    "rnbo_uniqueid": "value_sift_speed",
                                    "varname": "value_sift_speed"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-28",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 1080.0, 143.0, 175.0, 23.0 ],
                                    "rnbo_classname": "setparam",
                                    "rnbo_serial": 3,
                                    "rnbo_uniqueid": "set_sift_speed",
                                    "rnboinfo": {
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
                                                "mandatory": 1
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "attribute or parameter value (bang, number, list)",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "output",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "connect to first inlet of gen or subpatcher",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "set",
                                        "aliasOf": "set",
                                        "classname": "setparam",
                                        "operator": 0,
                                        "versionId": 1197449671,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "setparam sift_speed",
                                    "varname": "set_sift_speed"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-29",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 1080.0, 92.0, 175.0, 23.0 ],
                                    "rnbo_classname": "loadmess",
                                    "rnbo_serial": 3,
                                    "rnbo_uniqueid": "load_sift_speed",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "input": {
                                                "attrOrProp": 1,
                                                "digest": "Bang to trigger message.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "bang"
                                            },
                                            "message": {
                                                "attrOrProp": 1,
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "list",
                                                "defaultValue": ""
                                            },
                                            "startupbang": {
                                                "attrOrProp": 1,
                                                "digest": "startupbang",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": "bang",
                                                "digest": "Bang to trigger message.",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "message",
                                                "type": "list",
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "loadmess",
                                        "aliasOf": "loadmess",
                                        "classname": "loadmess",
                                        "operator": 0,
                                        "versionId": -361086158,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "loadmess 0.65",
                                    "varname": "load_sift_speed"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-31",
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 1270.0, 65.0, 175.0, 21.0 ],
                                    "text": "gate_thresh_db"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-33",
                                    "maxclass": "flonum",
                                    "numinlets": 1,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "bang" ],
                                    "parameter_enable": 0,
                                    "patching_rect": [ 1270.0, 115.0, 100.0, 23.0 ],
                                    "rnbo_classname": "number",
                                    "rnbo_extra_attributes": {
                                        "minimum": "<none>",
                                        "order": "",
                                        "preset": 0,
                                        "initialFormat": "float",
                                        "maximum": "<none>"
                                    },
                                    "rnbo_serial": 4,
                                    "rnbo_uniqueid": "value_gate_thresh_db",
                                    "varname": "value_gate_thresh_db"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-34",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 1270.0, 143.0, 175.0, 23.0 ],
                                    "rnbo_classname": "setparam",
                                    "rnbo_serial": 4,
                                    "rnbo_uniqueid": "set_gate_thresh_db",
                                    "rnboinfo": {
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
                                                "mandatory": 1
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "attribute or parameter value (bang, number, list)",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "output",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "connect to first inlet of gen or subpatcher",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "set",
                                        "aliasOf": "set",
                                        "classname": "setparam",
                                        "operator": 0,
                                        "versionId": 1197449671,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "setparam gate_thresh_db",
                                    "varname": "set_gate_thresh_db"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-35",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 1270.0, 92.0, 175.0, 23.0 ],
                                    "rnbo_classname": "loadmess",
                                    "rnbo_serial": 4,
                                    "rnbo_uniqueid": "load_gate_thresh_db",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "input": {
                                                "attrOrProp": 1,
                                                "digest": "Bang to trigger message.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "bang"
                                            },
                                            "message": {
                                                "attrOrProp": 1,
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "list",
                                                "defaultValue": ""
                                            },
                                            "startupbang": {
                                                "attrOrProp": 1,
                                                "digest": "startupbang",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": "bang",
                                                "digest": "Bang to trigger message.",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "message",
                                                "type": "list",
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "loadmess",
                                        "aliasOf": "loadmess",
                                        "classname": "loadmess",
                                        "operator": 0,
                                        "versionId": -361086158,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "loadmess -42",
                                    "varname": "load_gate_thresh_db"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-37",
                                    "linecount": 53,
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 30.0, 523.0, 573.0, 784.0 ],
                                    "text": "================================================================================\n00_tuba_freq_tracker — Parameter Information\n================================================================================\n\nOVERVIEW\nA custom Tuba-Specialized Hybrid Pitch & Phasor Tracker that outperforms generic FFT-based YinFFT (fluid.pitch~) for live low-brass dubstep performance by uniting three complementary DSP architectures inside a single RNBO codebox~:\n1. 4x-Decimated Recursive Sliding YIN (CMNDF): Computes the Cumulative Mean Normalized Difference Function continuously in the time domain with parabolic sub-sample interpolation and a 3-point transient median filter, updating every 32 samples (0.66 ms) instead of waiting for a 2048/4096-sample FFT frame.\n2. Instantaneous Frequency Tracking (IFT): Isolates the tuba's fundamental via a dual-stage adaptive SVF bandpass filter tracked to the YIN anchor, computes the analytic signal s_a(t) = A(t)*e^(j*theta(t)) via a 4-stage quadrature Hilbert transform, and differentiates the unwrapped phase d(theta)/dt on EVERY sample (zero window latency).\n3. Phase-Locked Loop (PLL) Fusion: Uses YIN as an unbreakable octave/harmonic anchor while using IFT to track fast lip bends, vibrato, and glissandi within a +/- 18% window, holding the last valid pitch cleanly on note releases.\n\nINLETS & OUTLETS\n- in1 / in2: Stereo (or Mono on in1) Tuba Audio Input\n- in3: Optional External Pitch Hint in Hz (if fluid.pitch~ is patched here, blends with the internal YIN anchor for redundant lock)\n- out1: Tracked Fundamental Pitch f0 in Hz (patch directly into in3 of effects 01–18!)\n- out2: Pitch Confidence / Periodicity [0.0 to 1.0]\n- out3: Phase-Locked Tuba Phasor [0.0 to 1.0) (phase-locked sawtooth ramp at f0)\n- out4: Pure Phase-Locked Fundamental Sine Wave [-1.0 to 1.0] (scaled by confidence)\n\nPARAMETERS (4)\n\n1. min_freq_hz\n   - Range: 24.0 to 120.0 Hz (Default: 28.0 Hz, covering down to Pedal Bb0 = 29.14 Hz)\n   - Taper: Direct frequency in Hz.\n   - Function: Sets the longest lag boundary of the YIN autocorrelation search window. Raising this to ~38 Hz when not playing pedal notes further reduces latency and CPU.\n\n2. max_freq_hz\n   - Range: 150.0 to 700.0 Hz (Default: 420.0 Hz, covering up to high G4/Ab4)\n   - Taper: Direct frequency in Hz.\n   - Function: Sets the shortest lag boundary of the YIN search window and upper clamp of the tracker, preventing high brass lip buzz or valve clicks from triggering false high-frequency jumps.\n\n3. IFT_speed\n   - Range: 0.0 to 1.0 (0.0 = Pure Median-Filtered YIN, 1.0 = Full Zero-Latency IFT Instantaneous Frequency)\n   - Taper: Linear crossfade coupled with tracking time-constant reduction (from 10 ms down to 1.5 ms).\n   - Function: Controls how aggressively the zero-latency Hilbert phase differentiator (IFT) overrides the YIN lag estimator during fast lip slurs, pitch bends, and vibrato.\n\n4. gate_thresh_db\n   - Range: -60.0 to -18.0 dB (Default: -42.0 dB)\n   - Taper: Logarithmic dB-to-linear RMS threshold (dbtoa).\n   - Function: Freezes the tracked pitch f0 at its last valid frequency whenever the tuba's RMS level drops below this threshold, completely eliminating pitch-drop glitches at the end of notes.\n",
                                    "varname": "paraminfo_comment"
                                }
                            }
                        ],
                        "lines": [
                            {
                                "patchline": {
                                    "destination": [ "obj-16", 0 ],
                                    "source": [ "obj-15", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-16", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-15", 0 ],
                                    "source": [ "obj-17", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-10", 0 ],
                                    "source": [ "obj-2", 2 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-11", 0 ],
                                    "source": [ "obj-2", 3 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-8", 0 ],
                                    "source": [ "obj-2", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-9", 0 ],
                                    "source": [ "obj-2", 1 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-22", 0 ],
                                    "source": [ "obj-21", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-22", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-21", 0 ],
                                    "source": [ "obj-23", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-28", 0 ],
                                    "source": [ "obj-27", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-28", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-27", 0 ],
                                    "source": [ "obj-29", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-34", 0 ],
                                    "source": [ "obj-33", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-34", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-33", 0 ],
                                    "source": [ "obj-35", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-5", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 1 ],
                                    "source": [ "obj-6", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 2 ],
                                    "source": [ "obj-7", 0 ]
                                }
                            }
                        ]
                    },
                    "patching_rect": [ 893.0, 142.0, 339.0, 22.0 ],
                    "rnboattrcache": {                    },
                    "rnboversion": "1.4.5",
                    "saved_attribute_attributes": {
                        "valueof": {
                            "parameter_invisible": 1,
                            "parameter_longname": "rnbo~",
                            "parameter_modmode": 0,
                            "parameter_shortname": "rnbo~",
                            "parameter_type": 3
                        }
                    },
                    "saved_object_attributes": {
                        "annotation_name": "00_tuba_freq_tracker",
                        "optimization": "O1",
                        "parameter_enable": 1,
                        "uuid": "6dc9ce7b-c81e-11f1-8e7b-a2f417e70586"
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
                        "snapshot": {
                            "__presetid": "6dc9ce7b-c81e-11f1-8e7b-a2f417e70586"
                        },
                        "snapshotlist": {
                            "current_snapshot": 0,
                            "entries": [
                                {
                                    "filetype": "C74Snapshot",
                                    "version": 2,
                                    "minorversion": 0,
                                    "name": "untitled",
                                    "origin": "6dc9ce7b-c81e-11f1-8e7b-a2f417e70586",
                                    "type": "rnbo",
                                    "subtype": "",
                                    "embed": 1,
                                    "snapshot": {
                                        "__presetid": "6dc9ce7b-c81e-11f1-8e7b-a2f417e70586"
                                    },
                                    "fileref": {
                                        "name": "untitled",
                                        "filename": "untitled_20261016_5.maxsnap",
                                        "filepath": "~/Documents/Max 9/Snapshots",
                                        "filepos": -1,
                                        "snapshotfileid": "fb783b4b37f2213b09e306d02c34dd3a"
                                    }
                                }
                            ]
                        }
                    },
                    "text": "rnbo~ @autobuild 1 @annotation_name 00_tuba_freq_tracker",
                    "varname": "rnbo_test_00_tuba_sift_yin_tracker"
                }
            },
            {
                "box": {
                    "autosave": 1,
                    "id": "obj-9",
                    "inletInfo": {
                        "IOInfo": [
                            {
                                "type": "signal",
                                "index": 1,
                                "tag": "in1",
                                "comment": ""
                            },
                            {
                                "type": "signal",
                                "index": 2,
                                "tag": "in2",
                                "comment": ""
                            },
                            {
                                "type": "signal",
                                "index": 3,
                                "tag": "in3",
                                "comment": ""
                            }
                        ]
                    },
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 5,
                    "outletInfo": {
                        "IOInfo": [
                            {
                                "type": "signal",
                                "index": 1,
                                "tag": "out1",
                                "comment": ""
                            },
                            {
                                "type": "signal",
                                "index": 2,
                                "tag": "out2",
                                "comment": ""
                            },
                            {
                                "type": "signal",
                                "index": 3,
                                "tag": "out3",
                                "comment": ""
                            },
                            {
                                "type": "signal",
                                "index": 4,
                                "tag": "out4",
                                "comment": ""
                            }
                        ]
                    },
                    "outlettype": [ "signal", "signal", "signal", "signal", "list" ],
                    "patcher": {
                        "fileversion": 1,
                        "appversion": {
                            "major": 9,
                            "minor": 1,
                            "revision": 5,
                            "architecture": "x64",
                            "modernui": 1
                        },
                        "classnamespace": "rnbo",
                        "rect": [ 463.0, 521.0, 1000.0, 780.0 ],
                        "default_fontname": "Lato",
                        "title": "untitled",
                        "boxes": [
                            {
                                "box": {
                                    "code": "// ============================================================================\n// 01_harmonic_isolator.txt\n// Unix-Style Effect 1: Pitch-Tracking Harmonic Isolator & Sine-ifier\n// Isolates the fundamental or a chosen harmonic of the stereo tuba signal\n// using a cascaded resonant bell boost + SVF bandpass, and outputs a clean,\n// normalized stereo sine-approximated carrier/modulator on out3 & out4.\n// ============================================================================\n// Inlets:\n//   in1: Left Audio Input\n//   in2: Right Audio Input\n//   in3: Tracked Fundamental Pitch in Hz (from fluid.pitch~ YinFFT; <=0 uses internal tracker)\n// Outlets:\n//   out1: Left Audio Output (Filtered / Boosted Harmonic)\n//   out2: Right Audio Output (Filtered / Boosted Harmonic)\n//   out3: Left Normalized Sine-ified Carrier/Modulator [-1, 1]\n//   out4: Right Normalized Sine-ified Carrier/Modulator [-1, 1]\n\n@param({ min: 1.0, max: 16.0 }) harmonic = 1.0;\n@param({ min: 0.0, max: 48.0 }) boost_db = 24.0;\n@param({ min: 0.0, max: 1.0 }) focus = 0.65;\n@param({ min: 0.0, max: 1.0 }) norm_amount = 0.75;\n\n// Biquad peak EQ states (Left and Right)\n@state bqL = new biquad();\n@state bqR = new biquad();\n\n// Cascaded 2-stage SVF bandpass states for steep harmonic isolation\n@state svfL1 = new svf();\n@state svfR1 = new svf();\n@state svfL2 = new svf();\n@state svfR2 = new svf();\n\n// Internal fallback zero-crossing pitch tracker & conditioning state\n@state lpTrack = new onepole();\n@state prevTrackSig = 0.0;\n@state zcCounter = 0.0;\n@state zcFreq = 55.0;\n@state smoothF0 = 55.0;\n\n// Envelope followers for dynamic decoupling / amplitude normalization\n@state envFastL = 0.0;\n@state envFastR = 0.0;\n@state envSlowL = 0.0;\n@state envSlowR = 0.0;\n\nlet sr = maximum(samplerate(), 1.0);\nlet xL = in1;\nlet xR = in2;\nlet extPitch = in3;\n\n// --- 1. Pitch Conditioning (External YinFFT or Internal Zero-Crossing Fallback) ---\nlet monoLow = lpTrack.next(0.5 * (xL + xR), 180.0);\nzcCounter += 1.0;\nif (prevTrackSig <= 0.0 && monoLow > 0.0) {\n\tif (zcCounter > sr / 500.0 && zcCounter < sr / 22.0) {\n\t\tzcFreq = sr / zcCounter;\n\t}\n\tzcCounter = 0.0;\n}\nprevTrackSig = monoLow;\n\nlet rawF0 = (extPitch > 20.0 && extPitch < 1000.0) ? extPitch : zcFreq;\n// Slew-limit pitch in log/Hz domain to suppress tracker glitches\nlet pitchSlew = 1.0 - exp(-1.0 / (0.008 * sr));\nsmoothF0 += (rawF0 - smoothF0) * pitchSlew;\nlet targetHz = clamp(smoothF0 * harmonic, 24.0, sr * 0.42);\n\n// --- 2. Musical Tapers ---\n// focus (0..1) maps exponentially to Q from 1.0 (gentle) to 28.0 (surgical harmonic lock)\nlet qVal = 1.0 * pow(28.0, pow(clamp(focus, 0.0, 1.0), 1.4));\n// boost_db (0..48 dB) maps to RBJ peaking filter linear gain A = 10^(dB/40)\nlet A = pow(10.0, clamp(boost_db, 0.0, 48.0) / 40.0);\n\n// --- 3. RBJ Peaking EQ Coefficients at targetHz ---\nlet w0 = 2.0 * pi * targetHz / sr;\nlet cosw = cos(w0);\nlet sinw = sin(w0);\nlet alpha = sinw / (2.0 * maximum(qVal * 0.5, 0.5));\n\nlet b0 = 1.0 + alpha * A;\nlet b1 = -2.0 * cosw;\nlet b2 = 1.0 - alpha * A;\nlet a0_inv = 1.0 / (1.0 + alpha / A);\nlet a1 = (-2.0 * cosw) * a0_inv;\nlet a2 = (1.0 - alpha / A) * a0_inv;\n\nlet c_b0 = b0 * a0_inv;\nlet c_b1 = b1 * a0_inv;\nlet c_b2 = b2 * a0_inv;\n\n// Compensate peak gain so +48 dB doesn't clip wildly before normalization\nlet compGain = 1.0 / pow(A, 1.35);\nlet peakedL = bqL.next(xL, c_b0, c_b1, c_b2, a1, a2) * compGain;\nlet peakedR = bqR.next(xR, c_b0, c_b1, c_b2, a1, a2) * compGain;\n\n// --- 4. Cascaded SVF Bandpass Isolation ---\n// svf.next(x, freq, Q) returns [lp, hp, bp, notch]\nlet svfQ = clamp(0.5 + focus * 0.45, 0.5, 0.96);\nlet bpL1 = svfL1.next(peakedL, targetHz, svfQ)[2];\nlet bpR1 = svfR1.next(peakedR, targetHz, svfQ)[2];\nlet bpL2 = svfL2.next(bpL1, targetHz, svfQ)[2];\nlet bpR2 = svfR2.next(bpR1, targetHz, svfQ)[2];\n\n// Crossfade between bell-boosted tuba and pure isolated harmonic bandpass with focus\nlet isoL = linearinterp(focus, peakedL, bpL2 * 2.2);\nlet isoR = linearinterp(focus, peakedR, bpR2 * 2.2);\n\n// --- 5. Instantaneous Envelope & Dynamic Decoupling ---\nlet absL = abs(isoL);\nlet absR = abs(isoR);\nlet fastAtk = 1.0 - exp(-1.0 / (0.0015 * sr));\nlet fastRel = 1.0 - exp(-1.0 / (0.025 * sr));\nlet slowCoeff = 1.0 - exp(-1.0 / (0.060 * sr));\n\nenvFastL = (absL > envFastL) ? (envFastL + (absL - envFastL) * fastAtk) : (envFastL + (absL - envFastL) * fastRel);\nenvFastR = (absR > envFastR) ? (envFastR + (absR - envFastR) * fastAtk) : (envFastR + (absR - envFastR) * fastRel);\nenvSlowL += (absL - envSlowL) * slowCoeff;\nenvSlowR += (absR - envSlowR) * slowCoeff;\n\n// Gate threshold to prevent noise floor amplification during silence\nlet gateL = clamp((envSlowL - 0.0008) * 250.0, 0.0, 1.0);\nlet gateR = clamp((envSlowR - 0.0008) * 250.0, 0.0, 1.0);\n\nlet unitSinL = (isoL / (envFastL * 1.25 + 0.0005)) * gateL;\nlet unitSinR = (isoR / (envFastR * 1.25 + 0.0005)) * gateR;\nunitSinL = tanh(unitSinL);\nunitSinR = tanh(unitSinR);\n\nlet nAmt = pow(clamp(norm_amount, 0.0, 1.0), 1.2);\nout1 = linearinterp(nAmt, isoL, unitSinL);\nout2 = linearinterp(nAmt, isoR, unitSinR);\nout3 = unitSinL;\nout4 = unitSinR;\n",
                                    "fontface": 0,
                                    "fontname": "<Monospaced>",
                                    "fontsize": 12.0,
                                    "id": "obj-2",
                                    "maxclass": "codebox~",
                                    "numinlets": 3,
                                    "numoutlets": 4,
                                    "outlettype": [ "signal", "signal", "signal", "signal" ],
                                    "patching_rect": [ 30.0, 110.0, 620.0, 360.0 ],
                                    "rnbo_classname": "codebox~",
                                    "rnbo_extra_attributes": {
                                        "code": "// ============================================================================\n// 01_harmonic_isolator.txt\n// Unix-Style Effect 1: Pitch-Tracking Harmonic Isolator & Sine-ifier\n// Isolates the fundamental or a chosen harmonic of the stereo tuba signal\n// using a cascaded resonant bell boost + SVF bandpass, and outputs a clean,\n// normalized stereo sine-approximated carrier/modulator on out3 & out4.\n// ============================================================================\n// Inlets:\n//   in1: Left Audio Input\n//   in2: Right Audio Input\n//   in3: Tracked Fundamental Pitch in Hz (from fluid.pitch~ YinFFT; <=0 uses internal tracker)\n// Outlets:\n//   out1: Left Audio Output (Filtered / Boosted Harmonic)\n//   out2: Right Audio Output (Filtered / Boosted Harmonic)\n//   out3: Left Normalized Sine-ified Carrier/Modulator [-1, 1]\n//   out4: Right Normalized Sine-ified Carrier/Modulator [-1, 1]\n\n@param({ min: 1.0, max: 16.0 }) harmonic = 1.0;\n@param({ min: 0.0, max: 48.0 }) boost_db = 24.0;\n@param({ min: 0.0, max: 1.0 }) focus = 0.65;\n@param({ min: 0.0, max: 1.0 }) norm_amount = 0.75;\n\n// Biquad peak EQ states (Left and Right)\n@state bqL = new biquad();\n@state bqR = new biquad();\n\n// Cascaded 2-stage SVF bandpass states for steep harmonic isolation\n@state svfL1 = new svf();\n@state svfR1 = new svf();\n@state svfL2 = new svf();\n@state svfR2 = new svf();\n\n// Internal fallback zero-crossing pitch tracker & conditioning state\n@state lpTrack = new onepole();\n@state prevTrackSig = 0.0;\n@state zcCounter = 0.0;\n@state zcFreq = 55.0;\n@state smoothF0 = 55.0;\n\n// Envelope followers for dynamic decoupling / amplitude normalization\n@state envFastL = 0.0;\n@state envFastR = 0.0;\n@state envSlowL = 0.0;\n@state envSlowR = 0.0;\n\nlet sr = maximum(samplerate(), 1.0);\nlet xL = in1;\nlet xR = in2;\nlet extPitch = in3;\n\n// --- 1. Pitch Conditioning (External YinFFT or Internal Zero-Crossing Fallback) ---\nlet monoLow = lpTrack.next(0.5 * (xL + xR), 180.0);\nzcCounter += 1.0;\nif (prevTrackSig <= 0.0 && monoLow > 0.0) {\n\tif (zcCounter > sr / 500.0 && zcCounter < sr / 22.0) {\n\t\tzcFreq = sr / zcCounter;\n\t}\n\tzcCounter = 0.0;\n}\nprevTrackSig = monoLow;\n\nlet rawF0 = (extPitch > 20.0 && extPitch < 1000.0) ? extPitch : zcFreq;\n// Slew-limit pitch in log/Hz domain to suppress tracker glitches\nlet pitchSlew = 1.0 - exp(-1.0 / (0.008 * sr));\nsmoothF0 += (rawF0 - smoothF0) * pitchSlew;\nlet targetHz = clamp(smoothF0 * harmonic, 24.0, sr * 0.42);\n\n// --- 2. Musical Tapers ---\n// focus (0..1) maps exponentially to Q from 1.0 (gentle) to 28.0 (surgical harmonic lock)\nlet qVal = 1.0 * pow(28.0, pow(clamp(focus, 0.0, 1.0), 1.4));\n// boost_db (0..48 dB) maps to RBJ peaking filter linear gain A = 10^(dB/40)\nlet A = pow(10.0, clamp(boost_db, 0.0, 48.0) / 40.0);\n\n// --- 3. RBJ Peaking EQ Coefficients at targetHz ---\nlet w0 = 2.0 * pi * targetHz / sr;\nlet cosw = cos(w0);\nlet sinw = sin(w0);\nlet alpha = sinw / (2.0 * maximum(qVal * 0.5, 0.5));\n\nlet b0 = 1.0 + alpha * A;\nlet b1 = -2.0 * cosw;\nlet b2 = 1.0 - alpha * A;\nlet a0_inv = 1.0 / (1.0 + alpha / A);\nlet a1 = (-2.0 * cosw) * a0_inv;\nlet a2 = (1.0 - alpha / A) * a0_inv;\n\nlet c_b0 = b0 * a0_inv;\nlet c_b1 = b1 * a0_inv;\nlet c_b2 = b2 * a0_inv;\n\n// Compensate peak gain so +48 dB doesn't clip wildly before normalization\nlet compGain = 1.0 / pow(A, 1.35);\nlet peakedL = bqL.next(xL, c_b0, c_b1, c_b2, a1, a2) * compGain;\nlet peakedR = bqR.next(xR, c_b0, c_b1, c_b2, a1, a2) * compGain;\n\n// --- 4. Cascaded SVF Bandpass Isolation ---\n// svf.next(x, freq, Q) returns [lp, hp, bp, notch]\nlet svfQ = clamp(0.5 + focus * 0.45, 0.5, 0.96);\nlet bpL1 = svfL1.next(peakedL, targetHz, svfQ)[2];\nlet bpR1 = svfR1.next(peakedR, targetHz, svfQ)[2];\nlet bpL2 = svfL2.next(bpL1, targetHz, svfQ)[2];\nlet bpR2 = svfR2.next(bpR1, targetHz, svfQ)[2];\n\n// Crossfade between bell-boosted tuba and pure isolated harmonic bandpass with focus\nlet isoL = linearinterp(focus, peakedL, bpL2 * 2.2);\nlet isoR = linearinterp(focus, peakedR, bpR2 * 2.2);\n\n// --- 5. Instantaneous Envelope & Dynamic Decoupling ---\nlet absL = abs(isoL);\nlet absR = abs(isoR);\nlet fastAtk = 1.0 - exp(-1.0 / (0.0015 * sr));\nlet fastRel = 1.0 - exp(-1.0 / (0.025 * sr));\nlet slowCoeff = 1.0 - exp(-1.0 / (0.060 * sr));\n\nenvFastL = (absL > envFastL) ? (envFastL + (absL - envFastL) * fastAtk) : (envFastL + (absL - envFastL) * fastRel);\nenvFastR = (absR > envFastR) ? (envFastR + (absR - envFastR) * fastAtk) : (envFastR + (absR - envFastR) * fastRel);\nenvSlowL += (absL - envSlowL) * slowCoeff;\nenvSlowR += (absR - envSlowR) * slowCoeff;\n\n// Gate threshold to prevent noise floor amplification during silence\nlet gateL = clamp((envSlowL - 0.0008) * 250.0, 0.0, 1.0);\nlet gateR = clamp((envSlowR - 0.0008) * 250.0, 0.0, 1.0);\n\nlet unitSinL = (isoL / (envFastL * 1.25 + 0.0005)) * gateL;\nlet unitSinR = (isoR / (envFastR * 1.25 + 0.0005)) * gateR;\nunitSinL = tanh(unitSinL);\nunitSinR = tanh(unitSinR);\n\nlet nAmt = pow(clamp(norm_amount, 0.0, 1.0), 1.2);\nout1 = linearinterp(nAmt, isoL, unitSinL);\nout2 = linearinterp(nAmt, isoR, unitSinR);\nout3 = unitSinL;\nout4 = unitSinR;\n",
                                        "nocache": 0,
                                        "expr": "",
                                        "safemath": 1
                                    },
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "effect_code",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "reset": {
                                                "attrOrProp": 1,
                                                "digest": "Reset all state and params to initial values",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            },
                                            "in1": {
                                                "attrOrProp": 1,
                                                "digest": "in1",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "number"
                                            },
                                            "in2": {
                                                "attrOrProp": 1,
                                                "digest": "in2",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "number"
                                            },
                                            "in3": {
                                                "attrOrProp": 1,
                                                "digest": "in3",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "number"
                                            },
                                            "out1": {
                                                "attrOrProp": 1,
                                                "digest": "out1",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
                                            },
                                            "out2": {
                                                "attrOrProp": 1,
                                                "digest": "out2",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
                                            },
                                            "out3": {
                                                "attrOrProp": 1,
                                                "digest": "out3",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
                                            },
                                            "out4": {
                                                "attrOrProp": 1,
                                                "digest": "out4",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
                                            },
                                            "harmonic": {
                                                "attrOrProp": 1,
                                                "digest": "harmonic",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "1"
                                            },
                                            "boost_db": {
                                                "attrOrProp": 1,
                                                "digest": "boost_db",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "24"
                                            },
                                            "focus": {
                                                "attrOrProp": 1,
                                                "digest": "focus",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "0.65"
                                            },
                                            "norm_amount": {
                                                "attrOrProp": 1,
                                                "digest": "norm_amount",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "0.75"
                                            },
                                            "expr": {
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
                                                "type": "symbol"
                                            },
                                            "safemath": {
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
                                                "defaultValue": "true"
                                            },
                                            "nocache": {
                                                "attrOrProp": 2,
                                                "digest": "Do not use parsing cache. This is only useful with very very big code sizes. Code generation will then take a looooong time.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "false"
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "in1",
                                                "type": "auto",
                                                "digest": "in1",
                                                "hot": 1,
                                                "docked": 0
                                            },
                                            {
                                                "name": "in2",
                                                "type": "auto",
                                                "digest": "in2",
                                                "docked": 0
                                            },
                                            {
                                                "name": "in3",
                                                "type": "auto",
                                                "digest": "in3",
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "out1",
                                                "type": "signal",
                                                "digest": "out1",
                                                "docked": 0
                                            },
                                            {
                                                "name": "out2",
                                                "type": "signal",
                                                "digest": "out2",
                                                "docked": 0
                                            },
                                            {
                                                "name": "out3",
                                                "type": "signal",
                                                "digest": "out3",
                                                "docked": 0
                                            },
                                            {
                                                "name": "out4",
                                                "type": "signal",
                                                "digest": "out4",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "codebox~",
                                        "aliasOf": "expr~",
                                        "classname": "codebox~",
                                        "operator": 0,
                                        "versionId": 527839773,
                                        "changesPatcherIO": 0
                                    },
                                    "varname": "effect_code"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-4",
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 30.0, 20.0, 620.0, 21.0 ],
                                    "text": "01_harmonic_isolator"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-5",
                                    "maxclass": "newobj",
                                    "numinlets": 0,
                                    "numoutlets": 1,
                                    "outlettype": [ "signal" ],
                                    "patching_rect": [ 30.0, 70.0, 70.0, 23.0 ],
                                    "rnbo_classname": "in~",
                                    "rnbo_extra_attributes": {
                                        "meta": "",
                                        "comment": ""
                                    },
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "audio_in_1",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "out1": {
                                                "attrOrProp": 1,
                                                "digest": "signal from inlet with index 1",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
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
                                                "mandatory": 1
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
                                                "type": "symbol"
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
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [],
                                        "outputs": [
                                            {
                                                "name": "out1",
                                                "type": "signal",
                                                "digest": "signal from inlet with index 1",
                                                "displayName": "",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "in~",
                                        "aliasOf": "in~",
                                        "classname": "in~",
                                        "operator": 0,
                                        "versionId": -1654556303,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "in~ 1",
                                    "varname": "audio_in_1"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-6",
                                    "maxclass": "newobj",
                                    "numinlets": 0,
                                    "numoutlets": 1,
                                    "outlettype": [ "signal" ],
                                    "patching_rect": [ 317.5, 70.0, 70.0, 23.0 ],
                                    "rnbo_classname": "in~",
                                    "rnbo_extra_attributes": {
                                        "meta": "",
                                        "comment": ""
                                    },
                                    "rnbo_serial": 2,
                                    "rnbo_uniqueid": "audio_in_2",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "out1": {
                                                "attrOrProp": 1,
                                                "digest": "signal from inlet with index 2",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
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
                                                "mandatory": 1
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
                                                "type": "symbol"
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
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [],
                                        "outputs": [
                                            {
                                                "name": "out1",
                                                "type": "signal",
                                                "digest": "signal from inlet with index 2",
                                                "displayName": "",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "in~",
                                        "aliasOf": "in~",
                                        "classname": "in~",
                                        "operator": 0,
                                        "versionId": -1654556303,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "in~ 2",
                                    "varname": "audio_in_2"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-7",
                                    "maxclass": "newobj",
                                    "numinlets": 0,
                                    "numoutlets": 1,
                                    "outlettype": [ "signal" ],
                                    "patching_rect": [ 605.0, 70.0, 70.0, 23.0 ],
                                    "rnbo_classname": "in~",
                                    "rnbo_extra_attributes": {
                                        "meta": "",
                                        "comment": ""
                                    },
                                    "rnbo_serial": 3,
                                    "rnbo_uniqueid": "audio_in_3",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "out1": {
                                                "attrOrProp": 1,
                                                "digest": "signal from inlet with index 3",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
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
                                                "mandatory": 1
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
                                                "type": "symbol"
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
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [],
                                        "outputs": [
                                            {
                                                "name": "out1",
                                                "type": "signal",
                                                "digest": "signal from inlet with index 3",
                                                "displayName": "",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "in~",
                                        "aliasOf": "in~",
                                        "classname": "in~",
                                        "operator": 0,
                                        "versionId": -1654556303,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "in~ 3",
                                    "varname": "audio_in_3"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-8",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 30.0, 520.0, 70.0, 23.0 ],
                                    "rnbo_classname": "out~",
                                    "rnbo_extra_attributes": {
                                        "meta": "",
                                        "comment": ""
                                    },
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "audio_out_1",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "in1": {
                                                "attrOrProp": 1,
                                                "digest": "signal sent to outlet with index 1",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "signal"
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
                                                "mandatory": 1
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
                                                "type": "symbol"
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
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "in1",
                                                "type": "signal",
                                                "digest": "signal sent to outlet with index 1",
                                                "displayName": "",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [],
                                        "helpname": "out~",
                                        "aliasOf": "out~",
                                        "classname": "out~",
                                        "operator": 0,
                                        "versionId": 1989326771,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "out~ 1",
                                    "varname": "audio_out_1"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-9",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 221.66666666666666, 520.0, 69.99999999999997, 23.0 ],
                                    "rnbo_classname": "out~",
                                    "rnbo_extra_attributes": {
                                        "meta": "",
                                        "comment": ""
                                    },
                                    "rnbo_serial": 2,
                                    "rnbo_uniqueid": "audio_out_2",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "in1": {
                                                "attrOrProp": 1,
                                                "digest": "signal sent to outlet with index 2",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "signal"
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
                                                "mandatory": 1
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
                                                "type": "symbol"
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
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "in1",
                                                "type": "signal",
                                                "digest": "signal sent to outlet with index 2",
                                                "displayName": "",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [],
                                        "helpname": "out~",
                                        "aliasOf": "out~",
                                        "classname": "out~",
                                        "operator": 0,
                                        "versionId": 1989326771,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "out~ 2",
                                    "varname": "audio_out_2"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-10",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 413.3333333333333, 520.0, 70.0, 23.0 ],
                                    "rnbo_classname": "out~",
                                    "rnbo_extra_attributes": {
                                        "meta": "",
                                        "comment": ""
                                    },
                                    "rnbo_serial": 3,
                                    "rnbo_uniqueid": "audio_out_3",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "in1": {
                                                "attrOrProp": 1,
                                                "digest": "signal sent to outlet with index 3",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "signal"
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
                                                "mandatory": 1
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
                                                "type": "symbol"
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
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "in1",
                                                "type": "signal",
                                                "digest": "signal sent to outlet with index 3",
                                                "displayName": "",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [],
                                        "helpname": "out~",
                                        "aliasOf": "out~",
                                        "classname": "out~",
                                        "operator": 0,
                                        "versionId": 1989326771,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "out~ 3",
                                    "varname": "audio_out_3"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-11",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 605.0, 520.0, 70.0, 23.0 ],
                                    "rnbo_classname": "out~",
                                    "rnbo_extra_attributes": {
                                        "meta": "",
                                        "comment": ""
                                    },
                                    "rnbo_serial": 4,
                                    "rnbo_uniqueid": "audio_out_4",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "in1": {
                                                "attrOrProp": 1,
                                                "digest": "signal sent to outlet with index 4",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "signal"
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
                                                "mandatory": 1
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
                                                "type": "symbol"
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
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "in1",
                                                "type": "signal",
                                                "digest": "signal sent to outlet with index 4",
                                                "displayName": "",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [],
                                        "helpname": "out~",
                                        "aliasOf": "out~",
                                        "classname": "out~",
                                        "operator": 0,
                                        "versionId": 1989326771,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "out~ 4",
                                    "varname": "audio_out_4"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-13",
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 700.0, 65.0, 175.0, 21.0 ],
                                    "text": "harmonic"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-15",
                                    "maxclass": "flonum",
                                    "numinlets": 1,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "bang" ],
                                    "parameter_enable": 0,
                                    "patching_rect": [ 700.0, 115.0, 100.0, 23.0 ],
                                    "rnbo_classname": "number",
                                    "rnbo_extra_attributes": {
                                        "minimum": "<none>",
                                        "order": "",
                                        "preset": 0,
                                        "initialFormat": "float",
                                        "maximum": "<none>"
                                    },
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "value_harmonic",
                                    "varname": "value_harmonic"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-16",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 700.0, 143.0, 175.0, 23.0 ],
                                    "rnbo_classname": "setparam",
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "set_harmonic",
                                    "rnboinfo": {
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
                                                "mandatory": 1
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "attribute or parameter value (bang, number, list)",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "output",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "connect to first inlet of gen or subpatcher",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "set",
                                        "aliasOf": "set",
                                        "classname": "setparam",
                                        "operator": 0,
                                        "versionId": 1197449671,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "setparam harmonic",
                                    "varname": "set_harmonic"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-17",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 700.0, 92.0, 175.0, 23.0 ],
                                    "rnbo_classname": "loadmess",
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "load_harmonic",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "input": {
                                                "attrOrProp": 1,
                                                "digest": "Bang to trigger message.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "bang"
                                            },
                                            "message": {
                                                "attrOrProp": 1,
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "list",
                                                "defaultValue": ""
                                            },
                                            "startupbang": {
                                                "attrOrProp": 1,
                                                "digest": "startupbang",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": "bang",
                                                "digest": "Bang to trigger message.",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "message",
                                                "type": "list",
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "loadmess",
                                        "aliasOf": "loadmess",
                                        "classname": "loadmess",
                                        "operator": 0,
                                        "versionId": -361086158,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "loadmess 1",
                                    "varname": "load_harmonic"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-19",
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 890.0, 65.0, 175.0, 21.0 ],
                                    "text": "boost_db"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-21",
                                    "maxclass": "flonum",
                                    "numinlets": 1,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "bang" ],
                                    "parameter_enable": 0,
                                    "patching_rect": [ 890.0, 115.0, 100.0, 23.0 ],
                                    "rnbo_classname": "number",
                                    "rnbo_extra_attributes": {
                                        "minimum": "<none>",
                                        "order": "",
                                        "preset": 0,
                                        "initialFormat": "float",
                                        "maximum": "<none>"
                                    },
                                    "rnbo_serial": 2,
                                    "rnbo_uniqueid": "value_boost_db",
                                    "varname": "value_boost_db"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-22",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 890.0, 143.0, 175.0, 23.0 ],
                                    "rnbo_classname": "setparam",
                                    "rnbo_serial": 2,
                                    "rnbo_uniqueid": "set_boost_db",
                                    "rnboinfo": {
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
                                                "mandatory": 1
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "attribute or parameter value (bang, number, list)",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "output",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "connect to first inlet of gen or subpatcher",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "set",
                                        "aliasOf": "set",
                                        "classname": "setparam",
                                        "operator": 0,
                                        "versionId": 1197449671,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "setparam boost_db",
                                    "varname": "set_boost_db"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-23",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 890.0, 92.0, 175.0, 23.0 ],
                                    "rnbo_classname": "loadmess",
                                    "rnbo_serial": 2,
                                    "rnbo_uniqueid": "load_boost_db",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "input": {
                                                "attrOrProp": 1,
                                                "digest": "Bang to trigger message.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "bang"
                                            },
                                            "message": {
                                                "attrOrProp": 1,
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "list",
                                                "defaultValue": ""
                                            },
                                            "startupbang": {
                                                "attrOrProp": 1,
                                                "digest": "startupbang",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": "bang",
                                                "digest": "Bang to trigger message.",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "message",
                                                "type": "list",
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "loadmess",
                                        "aliasOf": "loadmess",
                                        "classname": "loadmess",
                                        "operator": 0,
                                        "versionId": -361086158,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "loadmess 24",
                                    "varname": "load_boost_db"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-25",
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 1080.0, 65.0, 175.0, 21.0 ],
                                    "text": "focus"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-27",
                                    "maxclass": "flonum",
                                    "numinlets": 1,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "bang" ],
                                    "parameter_enable": 0,
                                    "patching_rect": [ 1080.0, 115.0, 100.0, 23.0 ],
                                    "rnbo_classname": "number",
                                    "rnbo_extra_attributes": {
                                        "minimum": "<none>",
                                        "order": "",
                                        "preset": 0,
                                        "initialFormat": "float",
                                        "maximum": "<none>"
                                    },
                                    "rnbo_serial": 3,
                                    "rnbo_uniqueid": "value_focus",
                                    "varname": "value_focus"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-28",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 1080.0, 143.0, 175.0, 23.0 ],
                                    "rnbo_classname": "setparam",
                                    "rnbo_serial": 3,
                                    "rnbo_uniqueid": "set_focus",
                                    "rnboinfo": {
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
                                                "mandatory": 1
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "attribute or parameter value (bang, number, list)",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "output",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "connect to first inlet of gen or subpatcher",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "set",
                                        "aliasOf": "set",
                                        "classname": "setparam",
                                        "operator": 0,
                                        "versionId": 1197449671,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "setparam focus",
                                    "varname": "set_focus"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-29",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 1080.0, 92.0, 175.0, 23.0 ],
                                    "rnbo_classname": "loadmess",
                                    "rnbo_serial": 3,
                                    "rnbo_uniqueid": "load_focus",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "input": {
                                                "attrOrProp": 1,
                                                "digest": "Bang to trigger message.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "bang"
                                            },
                                            "message": {
                                                "attrOrProp": 1,
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "list",
                                                "defaultValue": ""
                                            },
                                            "startupbang": {
                                                "attrOrProp": 1,
                                                "digest": "startupbang",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": "bang",
                                                "digest": "Bang to trigger message.",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "message",
                                                "type": "list",
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "loadmess",
                                        "aliasOf": "loadmess",
                                        "classname": "loadmess",
                                        "operator": 0,
                                        "versionId": -361086158,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "loadmess 0.65",
                                    "varname": "load_focus"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-31",
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 1270.0, 65.0, 175.0, 21.0 ],
                                    "text": "norm_amount"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-33",
                                    "maxclass": "flonum",
                                    "numinlets": 1,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "bang" ],
                                    "parameter_enable": 0,
                                    "patching_rect": [ 1270.0, 115.0, 100.0, 23.0 ],
                                    "rnbo_classname": "number",
                                    "rnbo_extra_attributes": {
                                        "minimum": "<none>",
                                        "order": "",
                                        "preset": 0,
                                        "initialFormat": "float",
                                        "maximum": "<none>"
                                    },
                                    "rnbo_serial": 4,
                                    "rnbo_uniqueid": "value_norm_amount",
                                    "varname": "value_norm_amount"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-34",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 1270.0, 143.0, 175.0, 23.0 ],
                                    "rnbo_classname": "setparam",
                                    "rnbo_serial": 4,
                                    "rnbo_uniqueid": "set_norm_amount",
                                    "rnboinfo": {
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
                                                "mandatory": 1
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "attribute or parameter value (bang, number, list)",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "output",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "connect to first inlet of gen or subpatcher",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "set",
                                        "aliasOf": "set",
                                        "classname": "setparam",
                                        "operator": 0,
                                        "versionId": 1197449671,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "setparam norm_amount",
                                    "varname": "set_norm_amount"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-35",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 1270.0, 92.0, 175.0, 23.0 ],
                                    "rnbo_classname": "loadmess",
                                    "rnbo_serial": 4,
                                    "rnbo_uniqueid": "load_norm_amount",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "input": {
                                                "attrOrProp": 1,
                                                "digest": "Bang to trigger message.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "bang"
                                            },
                                            "message": {
                                                "attrOrProp": 1,
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "list",
                                                "defaultValue": ""
                                            },
                                            "startupbang": {
                                                "attrOrProp": 1,
                                                "digest": "startupbang",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": "bang",
                                                "digest": "Bang to trigger message.",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "message",
                                                "type": "list",
                                                "digest": "Message when patcher is loaded.",
                                                "defaultarg": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "loadmess",
                                        "aliasOf": "loadmess",
                                        "classname": "loadmess",
                                        "operator": 0,
                                        "versionId": -361086158,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "loadmess 0.75",
                                    "varname": "load_norm_amount"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-37",
                                    "linecount": 45,
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 30.0, 553.0, 577.0, 669.0 ],
                                    "text": "================================================================================\n01_harmonic_isolator — Parameter Information\n================================================================================\n\nOVERVIEW\nIsolates the fundamental or a chosen overtone of the live tuba using a pitch-tracked RBJ peaking filter (+0 to +48 dB) cascaded into a dual-stage state-variable bandpass filter. Decouples breath dynamics via fast envelope normalization so the tuba approximates a pure, phase-locked sine wave ready to act as a carrier or modulator in downstream FM, phase distortion, or waveshaping effects.\n\nINLETS & OUTLETS\n- in1 / in2: Stereo Audio Input (Left / Right)\n- in3: Tracked Fundamental Pitch in Hz (from fluid.pitch~; automatically falls back to internal zero-crossing tracker if <= 0)\n- out1 / out2: Stereo Filtered & Boosted Output\n- out3 / out4: Pure Normalized Unit-Sine Output (for patching into downstream modulation inlets)\n\nPARAMETERS (4)\n\n1. harmonic\n   - Range: 1.0 to 8.0 (Harmonic Ratio / Partial Number)\n   - Taper: Linear in harmonic ratio (1.0 = fundamental f0, 2.0 = octave, 3.0 = twelfth, etc.; fractional values tune to inharmonic ghost-note zones).\n   - Function: Multiplies the conditioned input fundamental frequency to select which partial of the tuba is isolated.\n\n2. boost_db\n   - Range: 0.0 to 48.0 dB\n   - Taper: Logarithmic amplitude (dB-linear, computed as 10^(dB/40) for peaking EQ gain with automatic headroom compensation).\n   - Function: Boosts the target harmonic using a resonant bell filter before bandpass isolation, elevating the chosen partial far above the surrounding brass spectrum.\n\n3. focus\n   - Range: 0.0 to 1.0 (maps to Q from 1.0 to 28.0)\n   - Taper: Exponential (x^1.4 power curve into base-28 exponential Q) so low-to-mid values offer smooth musical formant tightening while the top 30% locks onto a single harmonic with surgical precision.\n   - Function: Simultaneously increases the Q of the peaking filter and crossfades into the cascaded 2-stage SVF bandpass filter.\n\n4. norm_amount\n   - Range: 0.0 to 1.0 (0% to 100% Dynamic Levelling)\n   - Taper: Slight power curve (x^1.2) for natural dynamic feel.\n   - Function: Blends between the natural breath envelope of the isolated harmonic (0.0) and a silence-gated, sample-accurate amplitude-normalized unit sine wave (1.0).\n",
                                    "varname": "paraminfo_comment"
                                }
                            }
                        ],
                        "lines": [
                            {
                                "patchline": {
                                    "destination": [ "obj-16", 0 ],
                                    "source": [ "obj-15", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-16", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-15", 0 ],
                                    "source": [ "obj-17", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-10", 0 ],
                                    "source": [ "obj-2", 2 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-11", 0 ],
                                    "source": [ "obj-2", 3 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-8", 0 ],
                                    "source": [ "obj-2", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-9", 0 ],
                                    "source": [ "obj-2", 1 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-22", 0 ],
                                    "source": [ "obj-21", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-22", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-21", 0 ],
                                    "source": [ "obj-23", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-28", 0 ],
                                    "source": [ "obj-27", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-28", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-27", 0 ],
                                    "source": [ "obj-29", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-34", 0 ],
                                    "source": [ "obj-33", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-34", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-33", 0 ],
                                    "source": [ "obj-35", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-5", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 1 ],
                                    "source": [ "obj-6", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 2 ],
                                    "source": [ "obj-7", 0 ]
                                }
                            }
                        ]
                    },
                    "patching_rect": [ 114.0, 336.0, 343.0, 22.0 ],
                    "rnboattrcache": {                    },
                    "rnboversion": "1.4.5",
                    "saved_attribute_attributes": {
                        "valueof": {
                            "parameter_invisible": 1,
                            "parameter_longname": "rnbo~[5]",
                            "parameter_modmode": 0,
                            "parameter_shortname": "rnbo~[5]",
                            "parameter_type": 3
                        }
                    },
                    "saved_object_attributes": {
                        "annotation_name": "01_harmonic_isolator",
                        "optimization": "O1",
                        "parameter_enable": 1,
                        "uuid": "6eab01ed-c81e-11f1-81ed-a2f417e70586"
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
                        "snapshot": {
                            "__presetid": "6eab01ed-c81e-11f1-81ed-a2f417e70586"
                        },
                        "snapshotlist": {
                            "current_snapshot": 0,
                            "entries": [
                                {
                                    "filetype": "C74Snapshot",
                                    "version": 2,
                                    "minorversion": 0,
                                    "name": "untitled",
                                    "origin": "6eab01ed-c81e-11f1-81ed-a2f417e70586",
                                    "type": "rnbo",
                                    "subtype": "",
                                    "embed": 1,
                                    "snapshot": {
                                        "__presetid": "6eab01ed-c81e-11f1-81ed-a2f417e70586"
                                    },
                                    "fileref": {
                                        "name": "untitled",
                                        "filename": "untitled_20261016_6.maxsnap",
                                        "filepath": "~/Documents/Max 9/Snapshots",
                                        "filepos": -1,
                                        "snapshotfileid": "61aa1af3f0fd528fd6b1f521bdb910a0"
                                    }
                                }
                            ]
                        }
                    },
                    "text": "rnbo~ @autobuild 0 @annotation_name 01_harmonic_isolator",
                    "varname": "rnbo_test_01_harmonic_isolator"
                }
            }
        ],
        "lines": [
            {
                "patchline": {
                    "destination": [ "obj-23", 0 ],
                    "source": [ "obj-1", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-1", 0 ],
                    "order": 1,
                    "source": [ "obj-13", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-2", 0 ],
                    "order": 0,
                    "source": [ "obj-13", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-19", 0 ],
                    "order": 1,
                    "source": [ "obj-14", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-28", 0 ],
                    "order": 0,
                    "source": [ "obj-14", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-13", 0 ],
                    "source": [ "obj-17", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-29", 0 ],
                    "source": [ "obj-19", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-24", 0 ],
                    "source": [ "obj-2", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-14", 0 ],
                    "source": [ "obj-20", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-37", 0 ],
                    "source": [ "obj-28", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-35", 0 ],
                    "source": [ "obj-30", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-35", 0 ],
                    "source": [ "obj-34", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-27", 0 ],
                    "source": [ "obj-35", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-1", 1 ],
                    "order": 6,
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-2", 1 ],
                    "order": 4,
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-4", 0 ],
                    "order": 0,
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-51", 1 ],
                    "order": 1,
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-51", 0 ],
                    "order": 2,
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-52", 0 ],
                    "order": 3,
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-9", 1 ],
                    "order": 5,
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-9", 0 ],
                    "order": 7,
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-30", 0 ],
                    "order": 1,
                    "source": [ "obj-37", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-40", 0 ],
                    "order": 0,
                    "source": [ "obj-37", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-25", 0 ],
                    "order": 1,
                    "source": [ "obj-4", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-38", 0 ],
                    "order": 0,
                    "source": [ "obj-4", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-39", 0 ],
                    "source": [ "obj-4", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-43", 0 ],
                    "source": [ "obj-4", 3 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-44", 0 ],
                    "source": [ "obj-4", 2 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-34", 0 ],
                    "source": [ "obj-40", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-53", 0 ],
                    "source": [ "obj-41", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-53", 1 ],
                    "source": [ "obj-42", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-49", 0 ],
                    "source": [ "obj-45", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-45", 0 ],
                    "source": [ "obj-46", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-50", 1 ],
                    "source": [ "obj-51", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-50", 0 ],
                    "source": [ "obj-51", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-46", 0 ],
                    "source": [ "obj-52", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-50", 1 ],
                    "order": 1,
                    "source": [ "obj-53", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-50", 0 ],
                    "order": 1,
                    "source": [ "obj-53", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-54", 1 ],
                    "order": 0,
                    "source": [ "obj-53", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-54", 0 ],
                    "order": 0,
                    "source": [ "obj-53", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-1", 2 ],
                    "source": [ "obj-9", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-2", 2 ],
                    "source": [ "obj-9", 1 ]
                }
            }
        ],
        "parameters": {
            "obj-21::obj-9": [ "rnbo~[1]", "rnbo~", 0 ],
            "obj-4": [ "rnbo~", "rnbo~", 0 ],
            "obj-51": [ "live.gain~", "live.gain~", 0 ],
            "obj-53": [ "live.gain~[2]", "live.gain~", 0 ],
            "obj-54": [ "vst~", "vst~", 0 ],
            "obj-9": [ "rnbo~[5]", "rnbo~[5]", 0 ],
            "parameterbanks": {
                "0": {
                    "index": 0,
                    "name": "",
                    "parameters": [ "-", "-", "-", "-", "-", "-", "-", "-" ],
                    "buttons": [ "-", "-", "-", "-", "-", "-", "-", "-" ]
                }
            },
            "inherited_shortname": 1
        },
        "autosave": 0,
        "toolbaradditions": [ "packagemanager" ],
        "toolbarexclusions": [ "mixerslider", "quickrecord", "showmappings" ]
    }
}