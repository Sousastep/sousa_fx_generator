# Audition harness — implementation plan

**Status:** proposed; no harness code written yet.
**Date:** 2026-10-24
**Location:** repo root (`AUDITION_HARNESS_PLAN.md`). `docs/*` is gitignored
except `docs/rnbo_codebox/`, and this plan is meant to be tracked.
**Scope:** a repeatable way for the agent to *measure* what an RNBO `codebox~`
effect does inside Max, so `verify_codebox.js` passing is not the last automated
check. Taste, clicks, level and musical range remain the human's call.

---

## 0. Decision summary

1. **Build a dedicated Max rig**, not a modified `main_test_patcher.maxpat`.
   The human's rig stays the ear; the audition rig is a clean, reproducible
   chain that loads the same `generated_maxpat/<key>.maxpat` files.
2. **Use one virtual cable in one direction:** Max output → `VB-Cable` →
   harness input. The stimulus is played *inside* Max (`sfplay~`/`playlist~`),
   not injected by the harness. This avoids a feedback loop through a single
   full-duplex virtual device.
3. **Capture in Python via ffmpeg as float32**, with a marker-based alignment
   step. A Max-side `sfrecord~` backend is a later optional mode for
   sample-exact capture, but only after its file format and start/stop
   behaviour are verified.
4. **Control over OSC** on `localhost:7400` (harness → Max) and
   `localhost:7401` (Max → harness), with ids, acks and timeouts. Messages
   carry safe **keys** (`category/name`), never paths with spaces.
5. **Scope v1 to stereo audio effects** (`in1/in2` audio, `out1/out2` audio).
   Control-signal effects (pitch trackers, analyzers, the 9-out/10-in
   resynthesizer) get integrity checks only, or a dedicated "control" mode
   later.
6. **"Listening" = numbers + images + flagged anomalies**, not a claim about
   taste. The report contains metrics, PNG plots (which the agent can inspect
   visually), raw WAVs (for the human), and a machine-readable JSON file.
7. `file_list.js` gets one small, backwards-compatible addition
   (`select_key`) so the harness can drive the human's browser/rig as an
   optional mode. The dedicated rig does its own loading and does not depend
   on it.

---

## 1. What "listen" means here

The agent cannot hear. The harness therefore produces three kinds of evidence:

| Evidence | Consumer | Example |
| --- | --- | --- |
| **Numbers** | agent, gates | peak `-0.2 dBFS`, DC `0.013`, THD `1.8 %`, latency `3.02 ms` |
| **Images** | agent (vision), human | waveform, spectrogram, long-term spectrum, envelope, stereo correlation |
| **Audio** | human | dry/wet WAV pair for the ear |

"Listening" in this plan means: run the effect under known stimulus, capture
its output, measure objective properties, compare against the dry signal and
previous runs, and flag things that are almost certainly broken (silence,
non-finite samples, clipping, DC, self-oscillation, dropped channels, huge
latency, alias energy). It does **not** mean "this sounds good".

### Use cases

- **Post-generation smoke test:** after `verify_codebox.js`, run four
  stimuli at default parameters and flag safety/integrity problems.
- **Parameter sweep:** move one parameter at a time to min/default/max and
  report which extremes clip, go silent, or lose the dry signal.
- **Regression:** compare metrics and spectra against a stored baseline after
  a code change.
- **Live-take diagnosis:** record 10 s of the human playing through the rig
  and report dropouts, clipping, DC, channel problems.
- **Batch triage:** run the whole corpus overnight and rank the effects that
  need a human ear first.

### Non-goals (v1)

- Replacing the human's listening verdict or writing to `ratings.json`.
- Automating "musicality", "feel", or "this is useful in a drop".
- A fully headless Max (Max is a GUI application; see §14).
- Offline RNBO C++ rendering (possible later; it would not exercise the Max
  patch wiring and would duplicate the host).
- Testing the live tuba/MADIface path except as a manual capture mode.

---

## 2. Environment facts verified on this machine

These are measured, not assumed (2026-10-24):

| Fact | Value |
| --- | --- |
| Max | 9.2.0 (`/Applications/Max.app`) |
| RNBO package | present under `Max.app/Contents/Resources/C74/packages/RNBO` |
| Virtual cable | `VB-Cable`, 2 in / 2 out, 48 kHz, CoreAudio |
| Capture probe | `ffmpeg -f avfoundation -i ":2" -c:a pcm_f32le` recorded 48 kHz stereo float from VB-Cable successfully |
| Default audio I/O | `MADIface Pro` (70 ch); do not disturb the human's live config |
| Project venv | `.venv` exists (Python 3.12); `numpy`/`scipy`/`soundfile`/`matplotlib` are **not** installed |
| Tooling | `uv 0.13.1`, `ffmpeg` on PATH, `python3` 3.15 system |
| Stimulus material | `sousa_mic.aif`, mono 48 kHz, 22.29 s (gitignored) |
| Effect corpus | 170 sources / 170 generated `.maxpat` |
| IO shapes | 153 effects with 2 outs; 10 with 1 in; 80 with 4 ins; 6 with 5 ins; 1 with 10 ins; 4 with 3 outs; 5 with 4 outs; 1 with 9 outs |
| Generated patcher form | `receive~ inN` / `send~ outN` around `rnbo~ @autobuild 0`, with a nested `rnbo` patcher |
| Nested params | `param <name> <default> @min @max` (varname `<name>`) + `setparam <name>` (varname `set_<name>`) inside the `rnbo~` subpatcher |
| Main rig form | `playlist~` → `selector~` → `s~ in1..in5`; tracker → `s~ in3`/`s~ in5`; `phasor~ 0.5` → `s~ in4`; `r~ out1/out2` → `live.gain~` → `dac~` (+ `audiounit~ "Pro-Q 3"`); `jweb` + `v8 file_list.js`; `bpatcher replaceme` |
| Main rig ownership | human-owned; **do not edit** (`AGENTS.md`) |

The two consequences that shape the design:

- `generated_maxpats` already have a stable signal contract (`receive~ inN`,
  `send~ outN`), so a rig can drive them without touching the effect patchers.
- Parameters live *inside* the `rnbo~` subpatcher as `setparam` objects, so
  automation must either use a documented `rnbo~` message (verify in M0) or
  script those objects through Max v8.

---

## 3. Architecture

```
  ┌──────────────────────────────┐         OSC (localhost)        ┌─────────────────────────────┐
  │ Python harness                │  ────── 7400 ──────────────▶  │ Max audition rig             │
  │  - run plan / cases           │                               │  udpreceive 7400             │
  │  - OSC client + acks          │  ◀───── 7401 ───────────────  │  audition_bridge.js          │
  │  - record VB-Cable (ffmpeg)   │                               │  bpatcher replaceme          │
  │  - analysis / metrics / gates │                               │  fixed tracker pre-stage     │
  │  - report + plots             │                               │  phasor~ 0.5 → in4           │
  └──────────────┬───────────────┘                                │  dac~ → VB-Cable             │
                 │                                                └──────────────┬──────────────┘
                 │  CoreAudio: record "VB-Cable" input                            │  CoreAudio: output "VB-Cable"
                 └────────────────────────────────────────────────────────────────┘
                                   one direction only (Max → harness)
```

### Components

| Component | Language | Responsibility |
| --- | --- | --- |
| `tools/audition/audition.py` | Python | CLI: `doctor`, `calibrate`, `smoke`, `batch`, `analyze`, `capture`, `monitor` |
| `tools/audition/osc.py` | Python | Minimal OSC encode/decode over UDP (no third-party OSC dependency) |
| `tools/audition/rig.py` | Python | Session: load key, set params, record, ack matching, timeouts, retries |
| `tools/audition/capture.py` | Python | Resolve VB-Cable index, spawn ffmpeg, stream float32, peak watchdog, write WAV |
| `tools/audition/stimuli.py` | Python | Generate/normalize stimulus WAVs and the manifest |
| `tools/audition/analysis.py` | Python | Metrics, alignment, gates |
| `tools/audition/report.py` | Python | `metrics.json`, `REPORT.md`, PNG plots, summary line |
| `tools/audition/cases.py` | Python | Per-effect overrides / case plans |
| `tools/audition/bridge/audition_bridge.js` | Max v8 | OSC ↔ patcher: load, param, stimulus, record, status |
| `tools/audition/audition_rig.maxpat` | generated | The dedicated rig (tell the human how to make it and they will make it themselves) |
| `tools/audition/thresholds.json` | JSON | Gates and tolerances, versioned |
| `tools/audition/calibration.json` | JSON | Per-machine latency/drift/level (gitignored) |
| `runs/` | directory | Outputs (gitignored): WAVs, metrics, plots, reports |

Add `runs/` and `tools/audition/calibration.json` to `.gitignore`.

---

## 4. Audio path and signal contract

### 4.1 One cable, one direction

Max's **output** device is `VB-Cable`. The harness records `VB-Cable`'s
**input** with ffmpeg. Nothing writes to VB-Cable except Max during an
automated run, so the harness cannot record its own playback.

The stimulus is played from inside Max:

```
stimuli/<key>.wav ──▶ [sfplay~ / playlist~] ──▶ in1/in2 of the effect
                                      │
                                      └──▶ fixed pitch-tracker pre-stage ──▶ in3 (Hz), in5 (phasor)
[phasor~ 0.5] ──▶ in4 (one-bar phasor)
in6..in10 = 0.0 (documented; see §4.3)
```

This mirrors `main_test_patcher`'s contract: audio on 1/2, tracked pitch on 3,
bar phasor on 4, tracker phasor on 5. It also means the harness only needs
*record* access to the cable, not playback.

If the user later wants the harness to inject audio (e.g. a DAW-style
stimulus), that requires a **second** virtual device (VB-Cable A+B, BlackHole,
or an aggregate). Do not try to use one full-duplex cable for both directions;
the harness would record its own stimulus mixed with Max's output.

### 4.2 Sample format and rate

- Default 48 kHz, buffer 128 or 256. Configurable with `--sample-rate`; store
  calibration per rate.
- Capture float32 (`pcm_f32le`) so low-level artifacts and the noise floor are
  not masked by 16-bit quantization.
- Stimulus files are float32 WAV at the same rate, peak-normalized to
  **-18 dBFS** (a tuba phrase may be normalized to -18 dBFS peak; tests use
  -18 dBFS RMS for sines, which is -21 dBFS peak).
- The rig's monitor path, if enabled, has a limiter. The **capture path is
  pre-limiter**; never measure a limited signal.

### 4.3 Channel contract and scope

The corpus is not uniform: 10 effects have 1 inlet, 6 have 5 inlets, one has
10, and a few have 3/4/9 outlets. v1 therefore classifies each effect:

| Class | Test | v1 treatment |
| --- | --- | --- |
| **audio** | `in >= 2`, `out == 2`, header says stereo/left-right | full metric suite |
| **mono audio** | `in >= 1`, `out == 1` | full suite on one channel |
| **control** | outlets are Hz, confidence, phasor, envelope, etc. | integrity + range only; dedicated control metrics later |
| **multi-IO** | `out > 2` or `in > 5` | load/reset/integrity; no spectral verdict; manual review |

The class is inferred from `_paraminfo.txt` / the header (`in1: Left`,
`out1: ... Hz`) and can be overridden in `tools/audition/cases.json`.
`parse_effect()` from `tools/generate_maxpats.py` supplies `n_in`, `n_out`,
parameter names, ranges and defaults, so the harness does not re-parse
`@param` syntax.

For `in6..in10`, the rig supplies 0.0 by default and logs that it did so. The
10-in resynthesizer expects the 9 outputs of the analyzer; that is a chain
test for a later milestone, not v1.

---

## 5. OSC protocol

All traffic is localhost. Max listens on 7400 and replies to 7401.
**Every command carries an id**; every reply echoes it. Argument rules:

- no spaces in any argument (Max messages split on whitespace);
- effect keys are `category/name` (`.` omitted, `/` allowed); URL-encode `%20`
  for legacy category names with spaces, and decode in the bridge;
- parameter names come from `@param` and are identifier-safe;
- numbers are decimal, no units;
- no absolute paths in OSC. The bridge resolves keys against the repo root.

### 5.1 Messages

| Harness → Max | Reply (Max → harness) | Meaning |
| --- | --- | --- |
| `/audition/ping <id>` | `/audition/pong <id> <rigver> <sr> <buf>` | liveness + rig info |
| `/audition/load <id> <key>` | `/audition/loaded <id> <key> <ok|error>` | replace the effect; reset all state |
| `/audition/param <id> <name> <value>` | `/audition/param_ok <id> <name> <value>` | set one parameter |
| `/audition/params <id> <name=value,...>` | `/audition/params_ok <id> <count>` | optional bulk set; comma-separated, no spaces |
| `/audition/reset <id>` | `/audition/loaded <id> <key> ok` | reload current effect (fresh state) |
| `/audition/stimulus <id> <key>` | `/audition/stimulus_ok <id> <key> <seconds>` | load a stimulus into the play buffer |
| `/audition/record <id> <case> <seconds>` | `/audition/recorded <id> <case> <peak_dbfs>` | play stimulus + record; `case` is safe (`[a-z0-9_]+`) |
| `/audition/stop <id>` | `/audition/stopped <id>` | stop playback and recording |
| `/audition/monitor <id> <0|1>` | `/audition/monitor_ok <id> <0|1>` | limiter-protected speaker monitor (off in batch) |
| `/audition/status <id>` | `/audition/status_report <id> <key> <recording> <peak_dbfs> <sr>` | state snapshot |
| `/audition/note <id> <midi> <vel>` | `/audition/note_ok <id> <midi>` | optional: set in3 from a MIDI note (tuba simulation) |
| `/audition/pitch <id> <hz>` | `/audition/pitch_ok <id> <hz>` | optional: hold in3 at a known frequency |

Errors use a separate message, never a reply that would be mistaken for a
success:

```
/audition/error <id> <code> <detail-token>
```

Codes: `bad_key`, `no_such_effect`, `no_such_stimulus`, `bad_param`,
`param_range`, `not_loaded`, `busy`, `record_failed`, `unsupported_io`.

### 5.2 Timing and robustness

- `load`: 5 s timeout, one retry.
- `param` / `stimulus` / `status`: 1 s, one retry.
- `record`: `seconds + 10 s`; the reply is the authoritative completion.
- The bridge is idempotent: `load` of the current key still reloads (state
  reset), `stop` when stopped is a no-op success.
- The harness ignores unknown reply addresses and logs them.
- OSC is unauthenticated. Keep 7400 off any external interface; if Max's
  `udpreceive` cannot be bound to loopback on the installed version, use the
  macOS firewall or a local-only network policy. Do not expose these ports.

The user's `/track/value 60 23` example fits the same pattern; `note`/`pitch`
are deliberately named under `/audition/` so they cannot collide with a
future tracker namespace.

---

## 6. Max side

### 6.1 Dedicated audition rig

Generated by `tools/generate_audition_rig.py` into
`tools/audition/audition_rig.maxpat`. Object graph (conceptual):

```
[udpreceive 7400] → [route /audition/load /audition/param /audition/record ...]
                         │
                         ▼
                 [v audition_bridge.js] ──▶ [udpsend localhost 7401]
                         │
                         ├─▶ [bpatcher replaceme]        (loads generated_maxpat/<key>.maxpat)
                         ├─▶ [s~ in1] ... [s~ in10]
                         ├─▶ [r~ out1] ... [r~ out9]
                         ├─▶ [sfplay~] / [buffer~]       (stimulus)
                         └─▶ [sfrecord~] (optional) / [dac~ 1 2] → VB-Cable
```

Pre-stage, fixed in the rig (not reloaded with the effect):

- a `tuba_freq_tracker_v2` (or `00_tuba_freq_tracker`) loaded in a second
  bpatcher, fed by the stimulus, supplying `in3` (Hz) and `in5` (phasor);
- `[phasor~ 0.5]` → `in4`;
- `in6..in10` → 0.0;
- output `out1`/`out2` → `dac~` (and optionally `sfrecord~`);
- a `peakamp~`/meter tap for `/audition/status`.

The effect bpatcher must be the same `replaceme` mechanism as
`main_test_patcher`, so the generated maxpats load unchanged.

A generated rig is preferable to a hand-made one because the patcher JSON is
large and error-prone; reuse `Effect`, `Param`, `IdGen` and the box-building
helpers from `tools/generate_maxpats.py`. The generated file is a build
artifact; add it to the same ignore policy as `generated_maxpat/` if it grows
unwieldy, or commit it if the team prefers a stable artifact (decide in M0).

### 6.2 `audition_bridge.js` (Max v8)

Responsibilities:

1. **Handshake:** on `loadbang`, send `/audition/pong` with a rig version,
   sample rate and buffer size.
2. **Load:** resolve `generated_maxpat/<key>.maxpat` from the patcher's
   directory (or a `base` message), replace the `replaceme` bpatcher, clear
   any stale reference to the old `rnbo~`.
3. **Set parameter:** after load, locate the `rnbo~` inside `replaceme`.
   The generated maxpat gives every control object a varname:
   `setparam <name>` is `set_<name>` and `param <name>` is `<name>`
   (verified in `hard_sync_5limit.maxpat`). So the direct route is
   `rnbo.subpatcher().getnamed("set_" + name).message(value)`.
   Try, in order:
   - `getnamed("set_" + name)` and send the value;
   - the documented `rnbo~` parameter message (e.g. `set <name> <value>`),
     if M0 confirms it on this RNBO version;
   - iterate the subpatcher for a box whose `text` starts with
     `setparam <name>` (do not compare `maxclass`; `setparam` boxes are
     `newobj` in the patcher JSON).
   Read the companion `param <name>` object (`getnamed(name)`) if an echo of
   the applied value is wanted. Clamp to the min/max parsed from its
   `@min/@max` before sending.
4. **Stimulus:** read `stimuli/<key>.wav` into the play buffer; report its
   duration.
5. **Record:** start playback and capture, schedule stop after `seconds`,
   reply with the peak level. In the cable backend the *harness* records; the
   rig only plays and reports completion. With the `sfrecord~` backend the rig
   writes a WAV to `runs/inbox/<case>.wav`.
6. **Status/stop/reset/monitor** as in §5.
7. **Defensive behaviour:** unknown messages are ignored; exceptions are
   caught and reported as `/audition/error`; never spam the Max console.

`this.patcher.getnamed("replaceme")` and `getnamed`/iteration over the
subpatcher are standard Max v8 scripting. The bridge is a message processor,
not a network client; UDP stays in `udpreceive`/`udpsend`.

### 6.3 `file_list.js` change (for `--rig main`)

The dedicated rig does its own loading, so this is optional. It is still worth
adding because it lets the harness drive the human's existing browser/rig and
keeps the jweb list in sync.

Add one function (no changes to existing behaviour):

```js
// Load by safe key ("category/name"), used by the OSC bridge.
function select_key(key) {
    if (!key) return;
    key = String(key).replace(/%20/g, " ");
    var path = dirPath + "/" + key + ".maxpat";
    var exists = false;
    try {
        var f = new File(path, "read");
        exists = f.isopen;
        if (exists) f.close();
    } catch (e) {}
    if (!exists) {
        post("file_list: no such effect: " + key + "\n");
        return;
    }
    outlet(0, path);
    outlet(1, "loaded", path);   // jweb already binds "loaded" and rebuilds the highlight
}
```

`file_list.html` already has a `loaded` inlet that sets the current highlight,
so no HTML change is required for basic sync. A later polish can add a
"reveal/scroll to selected row" message if the list is long.

The OSC route in `main_test_patcher` becomes:

```
[udpreceive 7400] → [route /audition/load] → [prepend select_key] → [v file_list.js]
```

### 6.4 Bridge kit for `main_test_patcher` (human applies)

Because `AGENTS.md` forbids the agent editing `main_test_patcher.maxpat`, the
human adds this small kit (or ignores it and uses the dedicated rig):

```
[udpreceive 7400]
[route /audition/load /audition/param /audition/record /audition/stop /audition/ping /audition/status]
[udpsend localhost 7401]
[v tools/audition/bridge/audition_bridge.js]
```

Required varnames (so the bridge can find them without fragile searches):

- `audition_playlist` → the existing `playlist~` (or the buffer/play pair);
- `audition_out_gain` → the `live.gain~` feeding `dac~`;
- optional `audition_record` if the human wants Max-side capture.

The bridge then uses `file_list.js`'s `select_key` for loading and walks the
loaded `replaceme` bpatcher for parameters. The exact object list and
varnames will be documented in `tools/audition/README.md` and verified in M3.

### 6.5 Optional capture backend: `sfrecord~`

`sfrecord~` starts and stops on messages from the same bridge, so it removes
cable latency and clock drift. Do not adopt it until M0 answers:

- what bit depth/format it writes (16-bit would mask low-level artifacts);
- whether `open`/`start`/`stop`/`close` are sample-aligned with playback;
- how it handles paths/names with spaces.

If it writes float32 and aligns, make it the default for `batch`, keep the
cable backend for the `main` rig and for a reality check on the actual device
path.

---

## 7. Harness side (Python)

### 7.1 Dependencies

Install into the existing venv with uv:

```bash
uv pip install --python .venv/bin/python numpy scipy soundfile matplotlib
```

- `numpy`/`scipy`: analysis (FFT, filters, correlation, resampling).
- `soundfile`: read/write WAV/AIFF; it can write multichannel float WAVs.
- `matplotlib`: PNG plots (headless `Agg` backend).
- `ffmpeg` (already installed): capture and stimulus decoding.
- No `python-osc`: `osc.py` is ~100 lines and keeps the tool dependency-free.
- No `sounddevice` in v1; ffmpeg streaming is enough. Optional later for
  lower-latency metering.

### 7.2 Modules

| Module | Key functions |
| --- | --- |
| `osc.py` | `encode(address, args)`, `decode(packet)`, `Client.send`, `Server.serve` |
| `rig.py` | `AuditionRig.ping/load/set_param/play/record/stop`, ack registry, retry, `RigError` |
| `capture.py` | `find_vb_cable()` (parse `ffmpeg -list_devices`), `record_f32(seconds)`, peak watchdog, WAV writer |
| `stimuli.py` | `build_all()`, `normalize()`, `ensure_manifest()` |
| `analysis.py` | `align()`, `metrics()`, `gates()`, `compare()` |
| `report.py` | `write_json()`, `write_markdown()`, `plots()` |
| `cases.py` | `load_cases(effect)`, `default_case()`, `sweep_cases()` |
| `audition.py` | CLI and orchestration |

Reuse `tools/generate_maxpats.py` (`discover_effects`, `parse_effect`) rather
than duplicating the `@param` parser.

### 7.3 CLI

```bash
# environment: Max rig reachable? VB-Cable present? ffmpeg? permissions? venv?
python3 tools/audition/audition.py doctor

# measure cable latency, drift, level; write calibration.json
python3 tools/audition/audition.py calibrate

# one effect, default params, four stimuli (~30 s), writes runs/<ts>/<effect>/
python3 tools/audition/audition.py smoke hard_sync_5limit

# one category, all effects, smoke cases
python3 tools/audition/audition.py batch --category ai_tuba_synth --cases smoke

# parameter sweeps: one parameter at a time, min/default/max
python3 tools/audition/audition.py batch --category ai_tuba_synth --cases sweep

# analyze an existing file (no Max): useful for live takes and debugging
python3 tools/audition/audition.py analyze take.wav --dry stimulus.wav --out runs/take

# record the live rig (human plays; harness only listens)
python3 tools/audition/audition.py capture --seconds 10 --out runs/live/take.wav
```

`smoke` auto-generates the missing/stale `.maxpat` with
`generate_maxpats.py --only <name>` before loading, so the existing loop
(`verify` → generate → audition → human ear) stays one command shorter.

### 7.4 Exit codes

Match the repository's tool style:

| Code | Meaning |
| --- | --- |
| 0 | all cases passed the gates |
| 1 | warnings only (no failure) |
| 2 | at least one failure |
| 3 | environment/rig error (Max unreachable, no cable, no permission, capture failed) |

### 7.5 Concurrency and timeouts

- One run at a time: `runs/.audition.lock` (PID + timestamp); `doctor` and
  every command acquire it. A stale lock (dead PID) is cleared with a warning.
- Every subprocess (ffmpeg, Max-side recording) has a timeout.
- On Ctrl-C or timeout: send `/audition/stop`, kill ffmpeg, close files, keep
  the partial WAV and a failure record.

---

## 8. Stimuli and control signals

### 8.1 Files

Generated by `stimuli.py` into `tools/audition/stimuli/` (gitignored; the
manifest and generator are tracked). All at 48 kHz float32, peak-normalized.

| Key | Length | What | Primary purpose |
| --- | --- | --- | --- |
| `tuba_phrase` | 6 s | excerpt of `sousa_mic.aif`, trimmed, -18 dBFS peak | realistic harmonic/transient content |
| `tuba_sustain` | 4 s | looped steady note from the same source | modulation, tremolo, filter sweeps |
| `sine_110` | 5 s | 110 Hz sine, -18 dBFS RMS | THD/THD+N, DC, level |
| `sine_1k` | 5 s | 1 kHz sine, -18 dBFS RMS | level, latency, channel identity |
| `sweep_20_20k` | 10 s | log sweep | impulse response, alias energy, spectral tilt |
| `dual_tone_19_20k` | 5 s | 19 kHz + 20 kHz, each -24 dBFS | IMD |
| `impulse` | 1 s | single sample at -6 dBFS, 0.5 s lead-in | click response, latency, IR |
| `click_train` | 4 s | 2 Hz clicks | transient smearing, retrigger |
| `silence` | 3 s | digital silence | self-oscillation, noise floor, DC |
| `dc_step` | 2 s | +0.05 step then silence | DC rejection |
| `stereo_identity` | 2 s | 1 kHz left, 2 kHz right | channel routing/swaps |

`tuba_phrase` and `tuba_sustain` are skipped with a warning if
`sousa_mic.aif` is absent (it is gitignored). The synthetic files are
reproducible from the generator, so they do not need to be committed.

Every stimulus starts with:

```
0.00–0.50 s  silence (pre-roll)
0.50–0.55 s  1 kHz marker burst at -20 dBFS
0.55–0.75 s  silence
0.75 s …     content
tail         2 s of silence (or the effect's declared tail)
```

The marker is how the harness aligns the recording to the stimulus.

### 8.2 In-rig control signals

- `in3` (pitch, Hz) and `in5` (phasor) come from the fixed tracker pre-stage,
  matching `main_test_patcher`.
- `in4` is `phasor~ 0.5` (one bar at 120 BPM / 0.5 Hz), matching the main
  rig's `phasor~ 0.5`.
- `in6..in10` are 0.0 in v1; the report records that they were tied off.
- An optional `--hold-pitch <hz>` bypasses the tracker and holds `in3`
  constant, which is useful for synthetic tones and for isolating an effect
  from tracker behaviour.

This is deliberately the same contract as the human's rig. If the harness
used different control signals, the measurements would not describe the
effect the human actually auditions.

---

## 9. Metrics and gates

### 9.1 Metrics

All metrics are computed on the aligned wet signal; `dry` is the known
stimulus (or a bypass recording) after the same alignment.

**Integrity**

- `finite`: all samples finite (NaN/Inf → hard failure).
- `peak_dbfs`, `true_peak_dbfs` (4× oversampled).
- `clipped_samples`, `clip_pct` (|x| ≥ 0.999).
- `dc_offset` (mean), `dc_dbfs`.
- `max_step` (max |x[n] − x[n−1]|), `click_count` (steps above a threshold).
- `zero_run_max`, `dropout_count` (runs of exact zeros longer than 1 ms in a
  non-silent region).
- `silent_channels` (RMS < -80 dBFS when the input is loud).

**Level**

- `rms_dbfs`, `lufs_i` (optional, BS.1770-lite), `crest_db`.
- `gain_db` vs dry RMS.
- `stereo_corr`, `mid_rms_dbfs`, `side_rms_dbfs`, `width`.

**Spectral**

- `centroid_hz`, `rolloff85_hz`, `tilt_db_per_oct`.
- Band energies: sub 20–60, bass 60–250, low-mid 250–800, mid 800–2k,
  high 2k–8k, air 8k–20k (dB relative to total).
- `thd_pct`, `thd_n_pct` on `sine_110` (first 6 harmonics; THD+N over the
  full band excluding the fundamental).
- `imd_pct` on `dual_tone_19_20k`.
- `alias_db`: energy in non-harmonic bins / energy below 20 kHz on the sweep,
  plus energy above 20 kHz.
- `noise_floor_dbfs`: RMS in the silence region after the tail settles.

**Temporal**

- `latency_ms` / `latency_samples`: cross-correlation of the marker or the
  dry/wet pair.
- `attack_ms` (10–90 % envelope rise on a click or tuba attack).
- `tail_ms` (time to -60 dBFS after the stimulus ends).
- `mod_rate_hz`, `mod_depth_db`: peak of the envelope spectrum and its
  dynamic range (for tremolo/AM effects).
- `drift_ppm`: measured over a 30–60 s steady tone.

**Reference / regression**

- `null_rms_db`: wet − dry for effects documented as linear/dry-only (valid
  only when the mix is 0 or the effect is a bypass; otherwise diagnostic, not
  a gate).
- `spectral_distance_db`, `corr_with_dry`.
- `baseline_delta`: per-metric change vs a stored `metrics.json`.

### 9.2 Gate table (provisional — calibrate against human ratings)

| Gate | FAIL | WARN |
| --- | --- | --- |
| non-finite samples | any | — |
| peak | > -0.1 dBFS | > -1.0 dBFS |
| clipping | > 0.01 % samples | > 0 % |
| DC offset | > 0.01 (≈ -40 dBFS) | > 0.002 |
| dead output | RMS < -80 dBFS with loud input | < -60 dBFS |
| silent channel | one channel < -80 dBFS | < -60 dBFS |
| self-oscillation | > -60 dBFS after 2 s of silence | > -70 dBFS |
| latency | > 250 ms | > 50 ms |
| dropout | any run > 5 ms | any run > 1 ms |
| click | > 3 steps > 0.5 in non-transient region | any step > 0.5 |
| alias | > -30 dB | > -40 dB |
| noise floor | > -40 dBFS | > -50 dBFS |
| mono compatibility | correlation < -0.5 | < 0 |
| loudness change | abs(gain) > 24 dB | > 12 dB |

These are starting points. They are stored in `thresholds.json` with a
`schema` and a comment per gate, and they are **not** a substitute for the
human's rating. After ~20 human-rated effects, compare metric distributions
by star rating and adjust the gates; do not tighten them just to make the
batch green.

Per-effect overrides live in `cases.json`:

```json
{
  "ai_tuba_synth/hard_sync_5limit": {
    "class": "audio",
    "tail_s": 1.0,
    "linear": false,
    "stochastic": false,
    "gates": { "dc_offset": { "fail": 0.02 } }
  }
}
```

Effects with free-running LFOs/noise are marked `stochastic`; run 2–3 takes
and report the spread instead of pretending the output is repeatable. Effects
with deliberate DC or asymmetry can override the gate with a comment; that is
a human decision recorded in the file.

### 9.3 Report

Per run directory:

```
runs/2026-10-24T18-02-11_hard_sync_5limit/
  REPORT.md
  summary.json                 # one line per case for batch ranking
  calibration.json             # copy of the calibration used
  tuba_phrase_default/
    input.wav                  # exact stimulus (or dry)
    output.wav
    metrics.json
    waveform.png
    spectrogram.png
    spectrum.png
    envelope.png
  sine_110_default/
  sweep_default/
  silence_default/
```

`REPORT.md` starts with the machine summary the agent can quote:

```markdown
# hard_sync_5limit — automated audition

Source: generated_fx/ai_tuba_synth/hard_sync_5limit.txt (sha256 1a2b…)
Rig: audition v1, 48 kHz, 128 samples, cable capture, latency 3.02 ms
Cases: 4 | FAIL 0 | WARN 2

| case | peak dBFS | RMS dBFS | crest dB | DC | THD % | latency ms | flags |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| tuba_phrase/default | -3.1 | -18.4 | 15.3 | 0.001 | — | 3.02 | |
| sine_110/default | -0.2 | -18.1 | 3.0 | 0.001 | 1.8 | 3.00 | clip warn |
| sweep/default | -6.0 | -20.1 | 14.0 | 0.001 | — | 3.02 | |
| silence/default | -72.0 | -75.0 | — | 0.004 | — | — | tail warn |

## Warnings
- `sine_110`: peak -0.2 dBFS, 0.03 % clipped samples at default `drive`.
- `silence`: output -72 dBFS after 2 s (possible slow tail / self-oscillation).

## Plots
![spectrogram](sine_110_default/spectrogram.png)
...
```

The agent reads `metrics.json` for gates and the PNGs for a visual sanity
check (spectral shape, obvious combing, missing low end, DC drift). The human
reads the same report and listens to `output.wav`.

---

## 10. Calibration and alignment

`audition.py calibrate` runs once per machine/device/sample-rate/buffer:

1. **Latency:** play `impulse`, record, cross-correlate with the known
   marker; repeat 5 times; store median and spread.
2. **Drift:** play a 60 s 1 kHz tone; estimate the recorded frequency;
   store `drift_ppm`. If |drift| > 10 ppm, resample the capture before
   analysis or use the `sfrecord~` backend.
3. **Level:** play `sine_1k` at -18 dBFS RMS through a bypass effect;
   store `gain_db` and the capture noise floor.
4. **Channel map:** play `stereo_identity`; verify L/R are not swapped and
   neither channel is dead.

The result is `tools/audition/calibration.json`, keyed by
`"<device>|<sr>|<buffer>"`. It is gitignored because it is machine-specific.
Every run copies the calibration it used into the run directory, so numbers
are reproducible later.

Per-take alignment:

- record 1 s of pre-roll and 2 s of post-roll;
- find the marker with normalized cross-correlation (band-passed around
  1 kHz if the effect colors it);
- trim to the marker onset; shift the dry reference by the measured latency;
- if the marker is missing or attenuated by more than 40 dB, mark the case
  `unaligned` and skip latency/dry-comparison gates rather than guessing.

---

## 11. Safety

Generated effects can be loud (the README says so). Automated runs must not
reach the speakers by accident.

- **Output device is VB-Cable**, not the interface/speakers, for every
  automated run.
- **Monitor is opt-in** (`--monitor`); the monitor path has a limiter at
  -6 dBFS ceiling. The captured signal is pre-limiter.
- **Watchdog:** the capture reader computes a running peak. If it exceeds
  0 dBFS for 50 ms, stop recording, send `/audition/stop`, keep the partial
  file, and mark the case `runaway`. This catches self-oscillation and
  parameter mistakes.
- **Pre-flight:** stimulus peak ≤ -6 dBFS; parameter values clamped to parsed
  `@min/@max`; no `--stress` run without an explicit flag.
- **Exclusive lock:** no batch while a live take or another batch is running.
- **Never write to `ratings.json`**; it is the human's data.

A `--monitor` run on the human's live rig is allowed only when they ask for
it; the harness prints a warning and uses the limiter.

---

## 12. Workflow integration

The loop becomes:

```text
write .txt + _paraminfo.txt
  → node tools/verify_codebox.js <file>              (must pass)
  → python3 tools/generate_maxpats.py --only <name>
  → python3 tools/audition/audition.py smoke <name>   (new: objective checks)
  → human listens in main_test_patcher and rates
```

The automated step is **not** a replacement for step 4. It is a triage tool:
it catches silence, DC, clipping, dropouts, runaway feedback and gross
spectral damage before the human spends time on a broken effect.

Do not add the harness to `AGENTS.md` as a mandatory step until the false
positive rate is understood. After M3, add a short section to `AGENTS.md`
and `PROMPTING.md` describing `doctor`, `smoke`, and the fact that a green
audition report is not a listening verdict.

---

## 13. Milestones

### M0 — protocol spike (no committed code)

Build a throwaway patcher + Python script that proves, on this machine:

1. `/audition/ping` reaches `[udpreceive 7400]` and a reply reaches 7401.
2. A generated `.maxpat` loads into a `bpatcher`.
3. A parameter can be set (documented `rnbo~` message *or* `setparam`
   scripting) and the change is measurable in the output.
4. The fixed tracker + `phasor~` supply `in3/in4/in5`.
5. VB-Cable capture works while Max outputs to VB-Cable.
6. Latency repeatability and 60 s drift are measured.

**Acceptance:** a 1 kHz -18 dBFS tone through a bypass effect records at
-18.0 ± 0.2 dBFS, THD+N < 0.05 %, no dropouts over 30 s; parameter change is
measurable; latency is repeatable within ±1 sample; drift is documented.

**Decision from M0:** cable capture is the default; `sfrecord~` is adopted
only if it writes float32 and aligns.

### M1 — analysis core (no Max required)

Implement `osc.py`, `analysis.py`, `stimuli.py`, `report.py`, and the
`analyze` command. Add `tools/audition/tests/` with synthetic fixtures:

- DC 0.01 → DC gate;
- 1 % clipped samples → clip gate;
- digital silence with loud input → dead-output gate;
- NaN → integrity fail;
- 110 Hz with known 1 % THD → THD within 5 % relative;
- sweep with injected alias → alias metric catches it;
- L/R swap → channel test;
- known latency → alignment within 1 sample.

**Acceptance:** `python3 -m unittest discover tools/audition/tests` passes;
analyzing the same file twice yields identical `metrics.json`; plots render
with the `Agg` backend.

### M2 — OSC + dedicated rig end-to-end

Implement `rig.py`, `capture.py`, `audition.py doctor/smoke`, the bridge, and
`generate_audition_rig.py`. Run one effect end-to-end.

**Acceptance:** `doctor` reports Max reachable, VB-Cable present, capture
working, calibration present. `smoke hard_sync_5limit` produces a report and
exit 0/1/2 as appropriate. A deliberately broken probe effect (DC / clip /
silence / NaN) produces the expected flags; a clean gain effect passes.

### M3 — batch + sweeps + main-rig bridge

Add `batch`, `cases.py`, the sweep generator, the lock, and the
`--rig main` path. Add `select_key` to `file_list.js` and document the bridge
kit for `main_test_patcher`.

**Acceptance:** a 10-effect batch runs unattended with no orphan ffmpeg/Max
processes; a parameter sweep identifies at least one known bad extreme; the
human's browser highlight follows an external `load`; a live capture records
and analyzes.

### M4 — regression + threshold calibration

Store baselines per effect, add `--baseline`, compare metrics/spectra, and
calibrate gates against `ratings.json` (read-only). Add `--include-control`
for pitch/analyzer effects with control-specific metrics (tracking error,
octave errors, step response).

**Acceptance:** rerunning a known-good effect after a no-op edit reports no
regression; a real regression (e.g. gain ×2, one channel muted) is caught;
control effects get a meaningful pass/fail without audio spectral gates.

### M5 (optional) — sample-exact / offline modes

- `sfrecord~` backend if M0 supports it.
- A Max-side "record while the human plays" mode with a countdown.
- An offline RNBO C++ runner for CI, clearly labelled "indicative" (it does
  not exercise the Max host).

---

## 14. Risks and mitigations

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Max is a GUI app; no supported headless CLI | batch cannot start Max by itself | `doctor` checks a running rig; the human launches it once; document `open -a Max tools/audition/audition_rig.maxpat` |
| macOS microphone permission for ffmpeg/Terminal | capture returns silence | `doctor` detects a zero-signal capture and prints the System Settings path |
| One full-duplex cable loops the stimulus back | bogus recordings | stimulus plays inside Max; harness only records; §4.1 |
| Clock drift / latency on VB-Cable | misaligned dry/wet, wrong latency | marker alignment, calibration, resample if drift > 10 ppm; optional `sfrecord~` |
| `setparam` scripting breaks on an RNBO update | cannot set params | M0 verifies the documented `rnbo~` message; fallback is a generated rig with top-level param controls |
| Effects explode / self-oscillate | dangerous level, damaged ears | cable output, limiter on monitor only, peak watchdog, pre-flight clamps |
| Batch runs while the human is playing | device conflict, confusing results | exclusive lock; `doctor` refuses if a live take is active; ask before batch |
| Paths/categories with spaces | OSC/message parsing breaks | safe keys, `%20` decode, no absolute paths in OSC |
| Stochastic effects | false regressions | `stochastic` flag, multiple takes, report spread |
| Tracker pre-stage colors in3/in5 | effects behave differently than expected | same tracker and phasor as `main_test_patcher`; `--hold-pitch` for isolation; document it |
| Effects with 9/10 IO | wrong metrics | class filter; integrity only; control mode in M4 |
| 16-bit `sfrecord~` | masks -90 dB artifacts | do not adopt until format is verified; cable capture is float32 |
| No DSP "truth" from a translated harness | numbers may mislead | label capture/rig in every report; Max's meter remains the CPU ground truth |

---

## 15. Open decisions

Recommended defaults are marked **→**.

1. **Which rig is the default?**
   → dedicated `audition_rig.maxpat`; `main_test_patcher` is the ear, with an
   optional bridge kit.
2. **How is the stimulus played?**
   → inside Max (one cable, one direction). If the user wants harness-driven
   input, add a second virtual cable; do not share one.
3. **Capture backend?**
   → ffmpeg float32 from VB-Cable for v1; adopt `sfrecord~` only if it writes
   float32 and aligns.
4. **Scope?**
   → v1 audio effects (153 with 2 outs); control/multi-IO effects get
   integrity checks, then a control mode in M4.
5. **Dependencies?**
   → add `numpy`, `scipy`, `soundfile`, `matplotlib` to `.venv` via `uv`;
   no new native packages.
6. **Stimulus files?**
   → generate on demand; commit the generator + manifest, not the WAVs.
7. **Where do reports live?**
   → `runs/` (gitignored); optional curated summaries under
   `docs/audition_reports/` if the team wants tracked history.

If these are accepted, M0 is the next action. M0 needs only a scratch patcher
and script outside the tracked tree; the first committed change would be the
analysis core (M1).

---

## 16. What this harness will and will not claim

Will claim:

- "`verify_codebox.js` → N/N passed, exit 0."
- "Audition: 0 FAIL, 2 WARN; peak -0.2 dBFS, 0.03 % clipped, DC 0.001,
  latency 3.02 ms on 4 stimuli."
- "The sweep shows alias energy at -38 dB; the effect is not alias-free at
  the tested settings."
- "The output is silent for 3 s after the stimulus; possible gate/tail bug."
- "Metric X changed by Y dB versus the stored baseline."

Will not claim:

- "It sounds good/broken."
- "It is musical at these settings."
- "It is CPU-efficient" without a Max meter or a measured harness.
- "Fixed" when only the compile or the automated gates passed.

The human's ear remains the final gate, and `ratings.json` remains theirs.

---

## Appendix A — OSC examples

```text
/audition/ping 17
/audition/load 18 ai_tuba_synth/hard_sync_5limit
/audition/param 19 drive 0.7
/audition/stimulus 20 tuba_phrase
/audition/record 21 tuba_phrase_default 6
/audition/stop 22
/audition/status 23
```

Raw UDP (for debugging):

```python
from tools.audition.osc import encode
sock.sendto(encode("/audition/param", [24, "drive", 0.7]), ("127.0.0.1", 7400))
```

Max side:

```
[udpreceive 7400] → [route /audition/ping /audition/load /audition/param ...]
```

## Appendix B — `file_list.js` diff sketch

```diff
+// Load by safe key ("category/name"), used by the OSC bridge.
+function select_key(key) {
+    if (!key) return;
+    key = String(key).replace(/%20/g, " ");
+    var path = dirPath + "/" + key + ".maxpat";
+    var f = new File(path, "read");
+    if (!f.isopen) { post("file_list: no such effect: " + key + "\n"); return; }
+    f.close();
+    outlet(0, path);
+    outlet(1, "loaded", path);
+}
```

## Appendix C — parameter automation fallback

`generate_maxpats.py` emits one `setparam <name>` per parameter inside the
nested patcher, with the predictable varname `set_<name>` (verified in
`hard_sync_5limit.maxpat`). The bridge therefore prefers:

```js
var sub = rnbo.subpatcher();
var setter = sub.getnamed("set_" + name);   // e.g. getnamed("set_drive")
if (!setter) {
    // fallback: scan the subpatcher; setparam boxes are maxclass "newobj"
    for (var b = sub.firstobject; b; b = b.nextobject) {
        if (b.maxclass === "newobj" && b.text === "setparam " + name) {
            setter = b;
            break;
        }
    }
}
if (setter) setter.message(value);
else outlet(0, "/audition/error", id, "bad_param", name);
```

Readback uses `sub.getnamed(name)` (the `param` box) and its `value`
attribute. Verify the exact message method (`message`, `float`, or `set`) on
Max 9.2 in M0; the varnames themselves are stable because the generator
assigns them.
