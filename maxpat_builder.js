// maxpat_builder.js - gh-pages only
//
// Browser-side mirror of tools/generate_maxpats.py: parses an effect's
// codebox~ source and _paraminfo.txt, builds the same rnbo~ demo patcher
// the tool writes to generated_maxpat/, and downloads it as <name>.maxpat.
//
// The rnboinfo templates below are that tool's canned per-object metadata
// (transcribed from the RNBO objects it generates). Keep them in sync if the
// Python tool changes.
var SousaMaxpat = (function () {
  "use strict";

  var MAXPAT_APP_VERSION = { major: 9, minor: 1, revision: 5, architecture: "x64", modernui: 1 };
  var MAXPAT_RNBO_VERSION = "1.4.5";
  var MAXPAT_DEFAULT_FONT = "Lato";
  var MAXPAT_CODEBOX_VERSION_ID = 527839773;
  var MAXPAT_SETPARAM_VERSION_ID = 1197449671;
  var MAXPAT_IN_VERSION_ID = -1654556303;
  var MAXPAT_OUT_VERSION_ID = 1989326771;

  var MAXPAT_CODEBOX_RECT = [30.0, 110.0, 620.0, 360.0];
  var MAXPAT_IO_ROW_TOP = 70.0;
  var MAXPAT_IO_ROW_BOTTOM = 520.0;
  var MAXPAT_IO_BOX_W = 70.0;
  var MAXPAT_IO_BOX_H = 23.0;
  var MAXPAT_IO_X_MIN = 30.0;
  var MAXPAT_IO_X_MAX = 605.0;
  var MAXPAT_PARAM_X0 = 700.0;
  var MAXPAT_PARAM_COL_GAP = 24.0;
  var MAXPAT_PARAM_ROW_STEP = 115.0;
  var MAXPAT_PARAM_Y0 = 65.0;
  var MAXPAT_PARAM_BOX_W = 175.0;
  var MAXPAT_NUMBOX_W = 100.0;
  var MAXPAT_PARAMINFO_RECT_X = 30.0;
  var MAXPAT_PARAMINFO_RECT_Y = 553.0;
  var MAXPAT_PARAMINFO_RECT_W = 577.0;
  var MAXPAT_LINE_HEIGHT = 14.87;
  var MAXPAT_TOP_RECEIVE_Y = 66.0;
  var MAXPAT_TOP_SEND_Y = 158.0;
  var MAXPAT_TOP_RECEIVE_W = 74.0;
  var MAXPAT_TOP_SEND_W = 68.0;
  var MAXPAT_TOP_IO_H = 22.0;
  var MAXPAT_TOP_RNBO_Y = 109.0;
  var MAXPAT_TOP_MESSAGES_RECT = [23.0, 18.0, 71.0, 22.0];
  var MAXPAT_RNBO_AUTOBUILD = 0;

  var MAXPAT_RESET_ARGNAME = {
    attrOrProp: 1,
    digest: "Reset all state and params to initial values",
    isalias: 0,
    aliases: [],
    attachable: 1,
    isparam: 0,
    deprecated: 0,
    touched: 0,
    type: "bang"
  };
  var MAXPAT_EXPR_ARGNAME = {
    attrOrProp: 2,
    digest: "expr",
    defaultarg: 1,
    isalias: 0,
    aliases: [],
    settable: 1,
    attachable: 0,
    isparam: 0,
    deprecated: 0,
    touched: 0,
    type: "symbol"
  };
  var MAXPAT_SAFEMATH_ARGNAME = {
    attrOrProp: 2,
    digest: "Use safe math expressions (e.g.: division by 0 will not crash).",
    isalias: 0,
    aliases: [],
    settable: 1,
    attachable: 0,
    isparam: 0,
    deprecated: 0,
    touched: 0,
    type: "bool",
    defaultValue: "true"
  };
  var MAXPAT_NOCACHE_ARGNAME = {
    attrOrProp: 2,
    digest: "Do not use parsing cache. This is only useful with very very big code sizes. Code generation will then take a looooong time.",
    isalias: 0,
    aliases: [],
    settable: 1,
    attachable: 0,
    isparam: 0,
    deprecated: 0,
    touched: 0,
    type: "bool",
    defaultValue: "false"
  };

  // Canned rnboinfo blocks from tools/generate_maxpats.py. Sentinel strings
  // ("__DEF__", "__MIN__", "__MAX__", "__IDX__") are filled in per object.
  var MAXPAT_PARAM_RNBOINFO = {"needsInstanceInfo":1,"argnames":{"value":{"attrOrProp":2,"digest":"Set initial value","defaultarg":2,"isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"number","defaultValue":"__DEF__","label":"Initial Value","displayorder":3},"normalizedvalue":{"attrOrProp":1,"digest":"Set value normalized. ","isalias":0,"aliases":[],"attachable":0,"isparam":0,"deprecated":0,"touched":0,"inlet":1,"type":"number"},"reset":{"attrOrProp":1,"digest":"Reset param to initial value","isalias":0,"aliases":[],"attachable":1,"isparam":0,"deprecated":0,"touched":0,"type":"bang"},"normalized":{"attrOrProp":1,"digest":"Normalized parameter value.","isalias":0,"aliases":[],"attachable":0,"isparam":0,"deprecated":0,"touched":0,"outlet":1,"type":"number"},"name":{"attrOrProp":2,"digest":"Name of the parameter","defaultarg":1,"isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"symbol","label":"Parameter Name","mandatory":1},"enum":{"attrOrProp":2,"digest":"Use an enumerated output","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"list","label":"Enum Values","displayorder":6},"minimum":{"attrOrProp":2,"digest":"Minimum value","isalias":0,"aliases":["min"],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"number","defaultValue":"__MIN__","label":"Minimum","displayorder":1},"min":{"attrOrProp":2,"digest":"Minimum value","isalias":1,"aliasOf":"minimum","aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"number","defaultValue":"__MIN__","label":"Minimum","displayorder":1},"maximum":{"attrOrProp":2,"digest":"Maximum value","isalias":0,"aliases":["max"],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"number","defaultValue":"__MAX__","label":"Maximum","displayorder":2},"max":{"attrOrProp":2,"digest":"Maximum value","isalias":1,"aliasOf":"maximum","aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"number","defaultValue":"__MAX__","label":"Maximum","displayorder":2},"exponent":{"attrOrProp":2,"digest":"Scale values exponentially","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"number","defaultValue":"1","label":"Exponent","displayorder":7},"steps":{"attrOrProp":2,"digest":"Divide the output into a number of discrete steps","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"number","defaultValue":"0","label":"Steps","displayorder":8},"displayName":{"attrOrProp":2,"digest":"DEPRECATED: Use the lower case 'displayname' instead","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":1,"touched":0,"type":"symbol","label":"Display Name"},"displayname":{"attrOrProp":2,"digest":"A more readable name for the parameter in an external RNBO target","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"symbol","defaultValue":"","label":"Display Name","displayorder":14},"unit":{"attrOrProp":2,"digest":"A symbol to describe the unit of the parameter in an external RNBO target","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"symbol","defaultValue":"","label":"Unit","displayorder":15},"tonormalized":{"attrOrProp":2,"digest":"Converts a real parameter value to its normalized form","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"symbol","label":"To Normalized Expression","displayorder":10},"fromnormalized":{"attrOrProp":2,"digest":"Converts a normalized parameter into its actual parameter value","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"symbol","label":"From Normalized Expression","displayorder":9},"order":{"attrOrProp":2,"digest":"Order in which initial parameter values will be sent out on patcher load. The order can be numeric or symbolic ('first' and 'last')","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"symbol","defaultValue":"0","label":"Restore Order","displayorder":12},"displayorder":{"attrOrProp":2,"digest":"Order in which parameters will show up in a list of all parameters. The order can be numeric or symbolic ('first' and 'last')","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"symbol","defaultValue":"-","label":"Display Order","displayorder":13},"sendinit":{"attrOrProp":2,"digest":"Send initial value","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"bool","defaultValue":"true","label":"Send Init","displayorder":4},"ctlin":{"attrOrProp":2,"digest":"MIDI controller number to control this parameter.","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"number","defaultValue":"-1","label":"MIDI Controller Number.","displayorder":16},"meta":{"attrOrProp":2,"digest":"A JSON formatted string containing metadata for use by the exported code","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"symbol","defaultValue":"","label":"Metadata","displayorder":17},"nopreset":{"attrOrProp":2,"digest":"Do not add this value to the preset [DEPRECATED - USE @preset 0 instead].","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":1,"touched":0,"type":"bool","defaultValue":"false"},"preset":{"attrOrProp":2,"digest":"Add this value to the preset.","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"bool","defaultValue":"true","label":"Include In Preset","displayorder":11}},"inputs":[{"name":"value","type":"number","digest":"Parameter value","defaultarg":2,"hot":1,"docked":0},{"name":"normalizedvalue","type":"number","digest":"Set value normalized. ","docked":0}],"outputs":[{"name":"value","type":"number","digest":"Parameter value","defaultarg":2,"hot":1,"docked":0},{"name":"normalized","type":"number","digest":"Normalized parameter value.","docked":0}],"helpname":"param","aliasOf":"param","classname":"param","operator":0,"versionId":-1093178486,"changesPatcherIO":0};
  var MAXPAT_IN_RNBOINFO = {"needsInstanceInfo":1,"argnames":{"out1":{"attrOrProp":1,"digest":"signal from inlet with index __IDX__","isalias":0,"aliases":[],"settable":0,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"outlet":1,"type":"signal"},"index":{"attrOrProp":2,"digest":"inlet number","defaultarg":1,"isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"number","mandatory":1},"comment":{"attrOrProp":2,"digest":"mouse over comment","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"symbol"},"meta":{"attrOrProp":2,"digest":"A JSON formatted string containing metadata for use by the exported code","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"symbol","defaultValue":"","label":"Metadata","displayorder":3}},"inputs":[],"outputs":[{"name":"out1","type":"signal","digest":"signal from inlet with index __IDX__","displayName":"","docked":0}],"helpname":"in~","aliasOf":"in~","classname":"in~","operator":0,"versionId":-1654556303,"changesPatcherIO":1};
  var MAXPAT_OUT_RNBOINFO = {"needsInstanceInfo":1,"argnames":{"in1":{"attrOrProp":1,"digest":"signal sent to outlet with index __IDX__","isalias":0,"aliases":[],"settable":0,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"inlet":1,"type":"signal"},"index":{"attrOrProp":2,"digest":"outlet number","defaultarg":1,"isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"number","mandatory":1},"comment":{"attrOrProp":2,"digest":"mouse over comment","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"symbol"},"meta":{"attrOrProp":2,"digest":"A JSON formatted string containing metadata for use by the exported code","isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"symbol","defaultValue":"","label":"Metadata","displayorder":3}},"inputs":[{"name":"in1","type":"signal","digest":"signal sent to outlet with index __IDX__","displayName":"","hot":1,"docked":0}],"outputs":[],"helpname":"out~","aliasOf":"out~","classname":"out~","operator":0,"versionId":1989326771,"changesPatcherIO":1};
  var MAXPAT_SETPARAM_RNBOINFO = {"needsInstanceInfo":1,"argnames":{"name":{"attrOrProp":2,"digest":"attribute/param to control","defaultarg":1,"isalias":0,"aliases":[],"settable":1,"attachable":0,"isparam":0,"deprecated":0,"touched":0,"type":"symbol","mandatory":1}},"inputs":[{"name":"input","type":["bang","number","list","signal"],"digest":"attribute or parameter value (bang, number, list)","hot":1,"docked":0}],"outputs":[{"name":"output","type":["bang","number","list","signal"],"digest":"connect to first inlet of gen or subpatcher","docked":0}],"helpname":"set","aliasOf":"set","classname":"setparam","operator":0,"versionId":1197449671,"changesPatcherIO":0};

  function maxpatFill(value, subs) {
    if (typeof value === "string") {
      var outStr = value;
      for (var key in subs) {
        if (Object.prototype.hasOwnProperty.call(subs, key) && outStr.indexOf(key) !== -1) {
          outStr = outStr.split(key).join(String(subs[key]));
        }
      }
      return outStr;
    }
    if (value && typeof value === "object") {
      var out, k;
      if (Object.prototype.toString.call(value) === "[object Array]") {
        out = [];
        for (k = 0; k < value.length; k++) out.push(maxpatFill(value[k], subs));
        return out;
      }
      out = {};
      for (k in value) {
        if (Object.prototype.hasOwnProperty.call(value, k)) out[k] = maxpatFill(value[k], subs);
      }
      return out;
    }
    return value;
  }

  function maxpatParamRnboinfo(defaultStr, minStr, maxStr) {
    return maxpatFill(MAXPAT_PARAM_RNBOINFO, {
      "__DEF__": defaultStr,
      "__MIN__": minStr,
      "__MAX__": maxStr
    });
  }

  function maxpatInRnboinfo(index) {
    return maxpatFill(MAXPAT_IN_RNBOINFO, { "__IDX__": String(index) });
  }

  function maxpatOutRnboinfo(index) {
    return maxpatFill(MAXPAT_OUT_RNBOINFO, { "__IDX__": String(index) });
  }

  // Python's round() (half to even), used for the layout arithmetic.
  function maxpatRound(v) {
    var floor = Math.floor(v);
    var frac = v - floor;
    if (frac > 0.5) return floor + 1;
    if (frac < 0.5) return floor;
    return (floor % 2 === 0) ? floor : floor + 1;
  }

  function maxpatFmtNum(value) {
    if (Math.floor(value) === value) return String(value);
    return String(value);
  }

  function maxpatSpread(i, count, lo, hi) {
    if (count <= 1) return lo;
    return lo + (hi - lo) * i / (count - 1);
  }

  function maxpatUuid() {
    var hex = "0123456789abcdef";
    var s = "";
    for (var i = 0; i < 32; i++) s += hex.charAt(Math.floor(Math.random() * 16));
    return s.slice(0, 8) + "-" + s.slice(8, 12) + "-" + s.slice(12, 16) + "-" +
      s.slice(16, 20) + "-" + s.slice(20);
  }

  function maxpatStripComments(code) {
    var lines = code.split("\n");
    for (var i = 0; i < lines.length; i++) {
      var idx = lines[i].indexOf("//");
      if (idx >= 0) lines[i] = lines[i].slice(0, idx);
    }
    return lines.join("\n");
  }

  var MAXPAT_NUM_SRC = "(-?(?:\\d+\\.\\d*|\\.\\d+|\\d+))";

  function maxpatFindFloat(pattern, text) {
    var m = new RegExp(pattern).exec(text);
    return m ? parseFloat(m[1]) : null;
  }

  function maxpatFindEnum(text) {
    var m = /enum\s*:\s*\[([^\]]*)\]/.exec(text);
    if (!m) return null;
    var re = /["']([^"']*)["']/g;
    var out = [];
    var q;
    while ((q = re.exec(m[1])) !== null) out.push(q[1]);
    return out.length ? out : null;
  }

  function maxpatParseEffect(name, code, paraminfo) {
    var params = [];
    var re = /@param\(\s*\{([^}]*)\}\s*\)\s*([A-Za-z_]\w*)\s*=\s*([^;]+);/g;
    var m;
    while ((m = re.exec(code)) !== null) {
      var opts = m[1];
      var defaultValue = parseFloat(m[3].trim());
      var enumValues = maxpatFindEnum(opts);
      var minimum = maxpatFindFloat("min\\s*:\\s*" + MAXPAT_NUM_SRC, opts);
      var maximum = maxpatFindFloat("max\\s*:\\s*" + MAXPAT_NUM_SRC, opts);
      if (minimum === null) minimum = 0.0;
      if (maximum === null) {
        maximum = (enumValues && enumValues.length > 1) ? enumValues.length - 1 : 1.0;
      }
      params.push({
        name: m[2],
        minimum: minimum,
        maximum: maximum,
        default: defaultValue,
        steps: maxpatFindFloat("steps\\s*:\\s*" + MAXPAT_NUM_SRC, opts),
        enumValues: enumValues,
        defaultStr: maxpatFmtNum(defaultValue),
        minStr: maxpatFmtNum(minimum),
        maxStr: maxpatFmtNum(maximum)
      });
    }

    var codeNoComments = maxpatStripComments(code);
    var inIndices = [];
    var outIndices = [];
    var mm;
    var inRe = /\bin(\d+)\b/g;
    var outRe = /\bout(\d+)\b/g;
    while ((mm = inRe.exec(codeNoComments)) !== null) inIndices.push(parseInt(mm[1], 10));
    while ((mm = outRe.exec(codeNoComments)) !== null) outIndices.push(parseInt(mm[1], 10));

    return {
      name: name,
      code: code,
      paraminfo: paraminfo || "",
      nIn: inIndices.length ? Math.max.apply(null, inIndices) : 0,
      nOut: outIndices.length ? Math.max.apply(null, outIndices) : 0,
      params: params
    };
  }

  function maxpatCodeboxRnboinfo(nIn, nOut, params) {
    var argnames = { reset: maxpatFill(MAXPAT_RESET_ARGNAME, {}) };
    var i, j;
    for (i = 1; i <= nIn; i++) {
      argnames["in" + i] = {
        attrOrProp: 1,
        digest: "in" + i,
        isalias: 0,
        aliases: [],
        settable: 1,
        attachable: 0,
        isparam: 0,
        deprecated: 0,
        touched: 0,
        inlet: 1,
        type: "number"
      };
    }
    for (j = 1; j <= nOut; j++) {
      argnames["out" + j] = {
        attrOrProp: 1,
        digest: "out" + j,
        isalias: 0,
        aliases: [],
        attachable: 0,
        isparam: 0,
        deprecated: 0,
        touched: 0,
        outlet: 1,
        type: "signal"
      };
    }
    for (i = 0; i < params.length; i++) {
      argnames[params[i].name] = {
        attrOrProp: 1,
        digest: params[i].name,
        isalias: 0,
        aliases: [],
        settable: 1,
        attachable: 1,
        isparam: 0,
        deprecated: 0,
        touched: 0,
        type: "number",
        defaultValue: params[i].defaultStr
      };
    }
    argnames.expr = maxpatFill(MAXPAT_EXPR_ARGNAME, {});
    argnames.safemath = maxpatFill(MAXPAT_SAFEMATH_ARGNAME, {});
    argnames.nocache = maxpatFill(MAXPAT_NOCACHE_ARGNAME, {});

    var inputs = [];
    for (i = 1; i <= nIn; i++) {
      var entry = { name: "in" + i, type: "auto", digest: "in" + i };
      if (i === 1) entry.hot = 1;
      entry.docked = 0;
      inputs.push(entry);
    }
    var outputs = [];
    for (j = 1; j <= nOut; j++) {
      outputs.push({ name: "out" + j, type: "signal", digest: "out" + j, docked: 0 });
    }

    return {
      needsInstanceInfo: 1,
      argnames: argnames,
      inputs: inputs,
      outputs: outputs,
      helpname: "codebox~",
      aliasOf: "expr~",
      classname: "codebox~",
      operator: 0,
      versionId: MAXPAT_CODEBOX_VERSION_ID,
      changesPatcherIO: 0
    };
  }

  function maxpatBuildNested(effect) {
    var nextId = 2;
    function id() { return "obj-" + (nextId++); }
    var boxes = [];
    var lines = [];

    function link(source, srcOut, dest, dstIn) {
      lines.push({ patchline: { destination: [dest, dstIn], source: [source, srcOut] } });
    }

    // Python's str.splitlines() does not count the empty tail after a final \n.
    var paraminfoLines = 0;
    if (effect.paraminfo) {
      paraminfoLines = effect.paraminfo.split("\n").length;
      if (effect.paraminfo.charAt(effect.paraminfo.length - 1) === "\n") paraminfoLines--;
    }

    var codeboxId = id();
    var outletTypes = [];
    for (var t = 0; t < effect.nOut; t++) outletTypes.push("signal");
    boxes.push({
      box: {
        code: effect.code,
        fontface: 0,
        fontname: "<Monospaced>",
        fontsize: 12.0,
        id: codeboxId,
        maxclass: "codebox~",
        numinlets: effect.nIn,
        numoutlets: effect.nOut,
        outlettype: outletTypes,
        patching_rect: MAXPAT_CODEBOX_RECT.slice(),
        rnbo_classname: "codebox~",
        rnbo_extra_attributes: {
          expr: "",
          nocache: 0,
          safemath: 1,
          code: effect.code
        },
        rnbo_serial: 1,
        rnbo_uniqueid: "effect_code",
        rnboinfo: maxpatCodeboxRnboinfo(effect.nIn, effect.nOut, effect.params),
        varname: "effect_code"
      }
    });

    var inIds = [];
    for (var i = 1; i <= effect.nIn; i++) {
      var inId = id();
      inIds.push(inId);
      boxes.push({
        box: {
          id: inId,
          maxclass: "newobj",
          numinlets: 0,
          numoutlets: 1,
          outlettype: ["signal"],
          patching_rect: [
            maxpatSpread(i - 1, effect.nIn, MAXPAT_IO_X_MIN, MAXPAT_IO_X_MAX),
            MAXPAT_IO_ROW_TOP,
            MAXPAT_IO_BOX_W,
            MAXPAT_IO_BOX_H
          ],
          rnbo_classname: "in~",
          rnbo_extra_attributes: { comment: "", meta: "" },
          rnbo_serial: i,
          rnbo_uniqueid: "audio_in_" + i,
          rnboinfo: maxpatInRnboinfo(i),
          text: "in~ " + i,
          varname: "audio_in_" + i
        }
      });
    }

    var outIds = [];
    for (var j = 1; j <= effect.nOut; j++) {
      var outId = id();
      outIds.push(outId);
      boxes.push({
        box: {
          id: outId,
          maxclass: "newobj",
          numinlets: 1,
          numoutlets: 0,
          patching_rect: [
            maxpatSpread(j - 1, effect.nOut, MAXPAT_IO_X_MIN, MAXPAT_IO_X_MAX),
            MAXPAT_IO_ROW_BOTTOM,
            MAXPAT_IO_BOX_W,
            MAXPAT_IO_BOX_H
          ],
          rnbo_classname: "out~",
          rnbo_extra_attributes: { comment: "", meta: "" },
          rnbo_serial: j,
          rnbo_uniqueid: "audio_out_" + j,
          rnboinfo: maxpatOutRnboinfo(j),
          text: "out~ " + j,
          varname: "audio_out_" + j
        }
      });
    }

    var numCols = 4;
    var paramTexts = [];
    var paramWidths = [];
    var colWidths = [MAXPAT_PARAM_BOX_W, MAXPAT_PARAM_BOX_W, MAXPAT_PARAM_BOX_W, MAXPAT_PARAM_BOX_W];
    var k, p;

    for (k = 0; k < effect.params.length; k++) {
      p = effect.params[k];
      var col = k % numCols;
      var pText = "param " + p.name + " " + p.defaultStr + " @min " + p.minStr + " @max " + p.maxStr;
      var pW = Math.max(MAXPAT_PARAM_BOX_W, maxpatRound(pText.length * 6.5) + 18.0);
      var sText = "setparam " + p.name;
      var sW = Math.max(MAXPAT_PARAM_BOX_W, maxpatRound(sText.length * 6.5) + 18.0);
      var cW = Math.max(MAXPAT_PARAM_BOX_W, maxpatRound(p.name.length * 6.5) + 14.0);
      paramTexts.push(pText);
      paramWidths.push(pW);
      colWidths[col] = Math.max(colWidths[col], pW, sW, cW);
    }

    var colX = [];
    var curX = MAXPAT_PARAM_X0;
    for (var c = 0; c < numCols; c++) {
      colX.push(curX);
      curX += colWidths[c] + MAXPAT_PARAM_COL_GAP;
    }

    for (k = 0; k < effect.params.length; k++) {
      p = effect.params[k];
      var colIndex = k % numCols;
      var row = Math.floor(k / numCols);
      var x = colX[colIndex];
      var y = MAXPAT_PARAM_Y0 + MAXPAT_PARAM_ROW_STEP * row;
      var paramBoxW = paramWidths[k];
      var paramText = paramTexts[k];

      var commentId = id();
      var numberId = id();
      var setparamId = id();
      var paramId = id();

      boxes.push({
        box: {
          id: commentId,
          maxclass: "comment",
          numinlets: 1,
          numoutlets: 0,
          patching_rect: [x, y, MAXPAT_PARAM_BOX_W, 21.0],
          text: p.name
        }
      });
      boxes.push({
        box: {
          id: numberId,
          maxclass: "flonum",
          numinlets: 1,
          numoutlets: 2,
          outlettype: ["", "bang"],
          parameter_enable: 0,
          patching_rect: [x, y + 50.0, MAXPAT_NUMBOX_W, 23.0],
          rnbo_classname: "number",
          rnbo_extra_attributes: {
            initialFormat: "float",
            maximum: "<none>",
            minimum: "<none>",
            order: "",
            preset: 0
          },
          rnbo_serial: k + 1,
          rnbo_uniqueid: "value_" + p.name,
          varname: "value_" + p.name
        }
      });
      boxes.push({
        box: {
          id: setparamId,
          maxclass: "newobj",
          numinlets: 1,
          numoutlets: 1,
          outlettype: [""],
          patching_rect: [x, y + 78.0, MAXPAT_PARAM_BOX_W, 23.0],
          rnbo_classname: "setparam",
          rnbo_serial: k + 1,
          rnbo_uniqueid: "set_" + p.name,
          rnboinfo: maxpatFill(MAXPAT_SETPARAM_RNBOINFO, {}),
          text: "setparam " + p.name,
          varname: "set_" + p.name
        }
      });
      boxes.push({
        box: {
          id: paramId,
          maxclass: "newobj",
          numinlets: 2,
          numoutlets: 2,
          outlettype: ["", ""],
          patching_rect: [x, y + 27.0, paramBoxW, 23.0],
          rnbo_classname: "param",
          rnbo_extra_attributes: {
            ctlin: 0.0,
            displayname: "",
            displayorder: "-",
            enum: "",
            exponent: 1.0,
            fromnormalized: "",
            meta: "",
            order: "0",
            preset: 1,
            sendinit: 1,
            steps: 0.0,
            tonormalized: "",
            unit: ""
          },
          rnbo_serial: k + 1,
          rnbo_uniqueid: p.name,
          rnboinfo: maxpatParamRnboinfo(p.defaultStr, p.minStr, p.maxStr),
          text: paramText,
          varname: p.name
        }
      });

      link(paramId, 0, numberId, 0);
      link(numberId, 0, setparamId, 0);
      link(setparamId, 0, codeboxId, 0);
    }

    for (j = 0; j < outIds.length; j++) link(codeboxId, j, outIds[j], 0);
    for (i = 0; i < inIds.length; i++) link(inIds[i], 0, codeboxId, i);

    if (effect.paraminfo) {
      var paraminfoId = id();
      boxes.push({
        box: {
          id: paraminfoId,
          linecount: Math.max(paraminfoLines, 1),
          maxclass: "comment",
          numinlets: 1,
          numoutlets: 0,
          patching_rect: [
            MAXPAT_PARAMINFO_RECT_X,
            MAXPAT_PARAMINFO_RECT_Y,
            MAXPAT_PARAMINFO_RECT_W,
            maxpatRound(Math.max(paraminfoLines, 1) * MAXPAT_LINE_HEIGHT * 1.3) + 18
          ],
          text: effect.paraminfo,
          varname: "paraminfo_comment"
        }
      });
    }

    var usedCols = Math.min(effect.params.length, numCols);
    var maxParamX = usedCols > 0
      ? colX[usedCols - 1] + colWidths[usedCols - 1] + 40.0
      : MAXPAT_PARAM_X0;
    return {
      fileversion: 1,
      appversion: MAXPAT_APP_VERSION,
      classnamespace: "rnbo",
      rect: [100.0, 100.0, Math.max(1000.0, maxParamX), 780.0],
      default_fontname: MAXPAT_DEFAULT_FONT,
      title: "untitled",
      boxes: boxes,
      lines: lines
    };
  }

  function maxpatBuildTop(effect) {
    var nextId = 2;
    function id() { return "obj-" + (nextId++); }
    var boxes = [];
    var lines = [];
    var i, j;

    function link(source, srcOut, dest, dstIn) {
      lines.push({ patchline: { destination: [dest, dstIn], source: [source, srcOut] } });
    }

    var messagesId = id();
    boxes.push({
      box: {
        id: messagesId,
        maxclass: "newobj",
        numinlets: 0,
        numoutlets: 1,
        outlettype: [""],
        patching_rect: MAXPAT_TOP_MESSAGES_RECT.slice(),
        text: "r messages"
      }
    });

    var receiveIds = [];
    for (i = 1; i <= effect.nIn; i++) {
      var receiveId = id();
      receiveIds.push(receiveId);
      boxes.push({
        box: {
          id: receiveId,
          maxclass: "newobj",
          numinlets: 1,
          numoutlets: 1,
          outlettype: ["signal"],
          patching_rect: [
            maxpatSpread(i - 1, effect.nIn, 65.0, 65.0 + 80.0 * (effect.nIn - 1)),
            MAXPAT_TOP_RECEIVE_Y,
            MAXPAT_TOP_RECEIVE_W,
            MAXPAT_TOP_IO_H
          ],
          text: "receive~ in" + i
        }
      });
    }

    var sendIds = [];
    for (j = 1; j <= effect.nOut; j++) {
      var sendId = id();
      sendIds.push(sendId);
      boxes.push({
        box: {
          id: sendId,
          maxclass: "newobj",
          numinlets: 1,
          numoutlets: 0,
          patching_rect: [
            maxpatSpread(j - 1, effect.nOut, 65.0, 65.0 + 80.0 * (effect.nOut - 1)),
            MAXPAT_TOP_SEND_Y,
            MAXPAT_TOP_SEND_W,
            MAXPAT_TOP_IO_H
          ],
          text: "send~ out" + j
        }
      });
    }

    var rnboId = id();
    var rnboText = "rnbo~ @autobuild " + MAXPAT_RNBO_AUTOBUILD + " @annotation_name " + effect.name;
    var rnboRectW = maxpatRound(rnboText.length * 6.1) + 20;
    var inletInfo = [];
    for (i = 1; i <= effect.nIn; i++) {
      inletInfo.push({ type: "signal", index: i, tag: "in" + i, comment: "" });
    }
    var outletInfo = [];
    for (j = 1; j <= effect.nOut; j++) {
      outletInfo.push({ type: "signal", index: j, tag: "out" + j, comment: "" });
    }
    var rnboOutletTypes = [];
    for (j = 0; j < effect.nOut; j++) rnboOutletTypes.push("signal");
    rnboOutletTypes.push("list");

    boxes.push({
      box: {
        autosave: 1,
        id: rnboId,
        inletInfo: { IOInfo: inletInfo },
        maxclass: "newobj",
        numinlets: effect.nIn,
        numoutlets: effect.nOut + 1,
        outletInfo: { IOInfo: outletInfo },
        outlettype: rnboOutletTypes,
        patcher: maxpatBuildNested(effect),
        patching_rect: [65.0, MAXPAT_TOP_RNBO_Y, rnboRectW, MAXPAT_TOP_IO_H],
        rnboattrcache: {},
        rnboversion: MAXPAT_RNBO_VERSION,
        saved_attribute_attributes: {
          valueof: {
            parameter_invisible: 1,
            parameter_longname: "rnbo~",
            parameter_modmode: 0,
            parameter_shortname: "rnbo~",
            parameter_type: 3
          }
        },
        saved_object_attributes: {
          annotation_name: effect.name,
          optimization: "O1",
          parameter_enable: 1,
          uuid: maxpatUuid()
        },
        snapshot: {
          filetype: "C74Snapshot",
          version: 2,
          minorversion: 0,
          name: "snapshotlist",
          origin: "rnbo~",
          type: "list",
          subtype: "Undefined",
          embed: 1,
          snapshot: {},
          snapshotlist: { current_snapshot: 0, entries: [] }
        },
        text: rnboText,
        varname: "rnbo_test_" + effect.name
      }
    });

    for (i = 0; i < receiveIds.length; i++) link(receiveIds[i], 0, rnboId, i);
    link(messagesId, 0, rnboId, 0);
    for (j = 0; j < sendIds.length; j++) link(rnboId, j, sendIds[j], 0);

    var width = Math.max(
      65.0 + rnboRectW,
      65.0 + 80.0 * Math.max(effect.nIn, effect.nOut)
    ) + 60.0;
    var params = {};
    params[rnboId] = ["rnbo~", "rnbo~", 0];
    params.parameterbanks = {
      "0": { index: 0, name: "", parameters: ["-", "-", "-", "-", "-", "-", "-", "-"], buttons: ["-", "-", "-", "-", "-", "-", "-", "-"] }
    };
    params.inherited_shortname = 1;

    return {
      fileversion: 1,
      appversion: MAXPAT_APP_VERSION,
      classnamespace: "box",
      rect: [100.0, 100.0, width, 260.0],
      boxes: boxes,
      lines: lines,
      parameters: params,
      autosave: 0,
      toolbaradditions: ["packagemanager"],
      toolbarexclusions: ["mixerslider", "quickrecord", "showmappings"]
    };
  }

  function maxpatBuild(effect) {
    return { patcher: maxpatBuildTop(effect) };
  }

  function maxpatDownload(name, code, paraminfo) {
    var patcher = maxpatBuild(maxpatParseEffect(name, code, paraminfo));
    var json = JSON.stringify(patcher, null, 2) + "\n";
    var blob = new Blob([json], { type: "application/json" });
    var url = URL.createObjectURL(blob);
    var a = document.createElement("a");
    a.href = url;
    a.download = name + ".maxpat";
    a.style.display = "none";
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    setTimeout(function () { URL.revokeObjectURL(url); }, 2000);
  }

  return { parse: maxpatParseEffect, build: maxpatBuild, download: maxpatDownload };
})();
