# pitch_lab

Offline bench for tuba pitch trackers. It turns labelled recordings into per-note
ground truth, runs both a C++ prototype and the **RNBO-generated C++ of a
codebox~** over them, and scores how fast and how accurately each one lands on
the note. This is how `generated_fx/ai_pitch_tracker/tuba_freq_tracker_v3.txt`
was tuned and checked against v2.

Requirements: `ffmpeg`, `clang++`, `node`, Max with RNBO (found the same way as
`verify_codebox.js`, or set `RNBO_PACKAGE_DIR`), and numpy + scipy. If numpy or
scipy is missing, `lab.py` re-runs itself under
`uv run --with numpy --with scipy`. Everything it writes goes to
`tools/pitch_lab/work/` (git-ignored, about 1.5 GB with every output kept), or to
`PITCH_LAB_WORK`.

## The loop

```bash
L=tools/pitch_lab/lab.py
python3 $L decode                     # tuba_recs/*.aif -> work/wav44100/*.f32
python3 $L truth                      # per-note ground truth + "oracle" track (-v lists notes)
python3 $L build proto                # tools/pitch_lab/proto.cpp
python3 $L build rnbo generated_fx/ai_pitch_tracker/tuba_freq_tracker_v3.txt
python3 $L build rnbo generated_fx/ai_pitch_tracker/tuba_freq_tracker_v2.txt
python3 $L run proto proto            # TAG = output folder under work/out/
python3 $L run tuba_freq_tracker_v3 v3
python3 $L run tuba_freq_tracker_v2 v2
python3 $L score v3                   # add -v for every note, --ref oracle for the other metric
python3 $L compare v3 proto           # port check: cents difference sample by sample
python3 $L sweep '{"window_periods":[2,3,4],"octave_ms":[0,25]}'   # prototype grid search
```

Reference results (6 recordings, 149 notes, 44.1 kHz):

| tag | to note, median | p90 | in-note accuracy | octave errors |
|---|---|---|---|---|
| v2 | 73.3 ms | 136.3 ms | 82.6% | 0.0% |
| v3 (= proto) | 40.4 ms | 88.0 ms | 96.4% | 0.0% |

`compare v3 proto` must print `max 0.0000 c` on every file. This holds for the
defaults and for `--set` variants. The v3 codebox is a line-for-line port of
`proto.cpp`, so keep the two in step whenever you change one of them.

## Recordings and labels

`decode` takes every `.aif/.aiff/.wav/.flac` file in `tuba_recs/` (or
`--recs DIR`). `truth` needs the intended note sequence of each file:

- files whose names contain `Fmaj_2oct` (F1→F3→F1) or `chromatic_Bb-D`
  (Bb2→D1) are labelled automatically;
- anything else needs a sidecar `tuba_recs/<name>.notes` listing the notes in
  order. Note names or MIDI numbers both work, and `#` starts a comment:
  `Bb0 C1 D1 Eb1  # pedal run`.

Labels give the *intended* notes. The truth step aligns the recording to them
(per-file tuning offset, monotone alignment), so flat or sharp playing still
counts as the right note. The reference pitch for each note is what was
actually played, which matters because the trackers output Hz. A warning is
printed if a note sits more than 1.2 semitones from its label, which usually
means a wrong or missing note in the `.notes` file.

## What the scores mean

- **to note**: time from the note's onset until the output stays within
  ±50 cents of the note's steady pitch for 30 ms. The onset is the energy
  onset for attacks, or the middle of the pitch transition for legato. Part of
  this time is the player's own scoop into the note, not tracker delay.
- **in-note acc / oct / med|err|**: over the note's stable part, the share of
  time within ±50 cents, the share an octave off, and the median error.
- **junk**: in the gap before an attacked note, the share of time the output
  matches neither the previous note nor the next one (for example a release
  noise read as a pitch and held).
- `--ref oracle` scores against the centred offline track instead. That track
  looks about 22 ms ahead, so treat it as a floor, not a target.
- "fast runs" and "slow notes" split the files by median note length
  (< 0.5 s).

## Parameters on RNBO builds

`verify_codebox.js` compiles a bare codebox~ whose `@param`s have no inlet, and
RNBO **constant-folds** them, so the generated C++ never reads them. In Max
they are live through `param` → `setparam`. To test other values offline:

```bash
python3 $L build rnbo SRC.txt --name alt --set window_periods=2.0 --set confirm_ms=5.0
python3 $L build rnbo SRC.txt --name dyn --dyn window_periods      # @param now read from in3
python3 $L run dyn dyn --in3 3,1.5@6.0 --only asc_desc_02          # 3 until 6 s, then 1.5
python3 $L score dyn --after 6.1
```

The prototype takes `name=value` directly. It uses the same parameter names as
the codebox, plus the codebox's fixed constants (`k`, `wmin_ms`, `cand_tol`,
`jump_st`, `hop`, `lp_hz`, `hp_hz`). Other sample rates:
`decode --sr 48000`, then `run ... --sr 48000`; scoring maps the output back to
the 44.1 kHz truth timeline.

The harness prints ns/sample. Treat it as indicative only; Max's CPU meter is
the ground truth.

## Files

| file | what |
|---|---|
| `lab.py` | the driver above |
| `proto.cpp` | C++ prototype of tuba_freq_tracker_v3 (codebox-portable style) |
| `rnbo_harness.cpp` | runs `verify_codebox.js --keep` C++ through `RNBO::CoreObject`, block size 64 |
