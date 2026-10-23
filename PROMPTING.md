# Prompting a batch of effects

Notes on the question: *what is the best way, in the prompt, to group, organize
and restrict the effects created in one go?*

This is about the **unit** (what one effect is), the **family** (what makes a
handful of them one batch) and the **stopping rule** (when the batch is done).
Everything below is grounded in this repo: 136 effects in `generated_fx/`, 100
of them rated, 17 rated 5 stars, 23 rated 1 — and a history of batches that went
well and batches that did not.

---

## 0. The short version

A batch prompt needs five sentences that are not about sound:

1. **Unit** — "one effect = one `.txt` file = one job you can state in one line;
   if a new idea does not fit that line, it is a new effect, not a new feature."
2. **Family** — "all N effects in this batch are variations on *one* mechanism /
   one signal path, differing only in how they set it up."
3. **Contract** — "every effect in the batch has the same inlets with the same
   units and the same behaviour when an inlet is unpatched."
4. **Sensing is given, not invented** — "pitch in Hz, a 1-bar phasor, and an
   envelope are available on the control inlets; do not build your own."
5. **Stop** — "stop when the roster is covered; do not add effects to cover
   ideas outside the family."

That is the whole trick. The rest of this file is why each line is shaped that
way, plus a template you can paste.

---

## 1. Why the Unix sentences worked

> "Write programs that do one thing and do it well."
> "Write programs to work together."

These are not style advice to a language model; they are three *enforceable*
properties wearing a slogan:

- **One thing** gives the model a rejection rule. Without it, every new paper
  idea becomes another parameter on whatever file is open. With it, a new idea
  must either fit the file's one-line job or become a separate file. That single
  rule is what keeps a batch from collapsing into two 900-line instruments.
- **Well** gives it a success criterion at the level of the *mechanism*, not the
  vibe: the effect has one place where its character comes from (the feedback
  path, the phase shaper, the detector), and everything else is plumbing.
- **Work together** makes the batch composable, which is a testable property,
  not a compliment: any two effects of the batch can be chained in either order
  with no adapter, no rescaling, no "put a gain before it".

The words also survive translation better than the adjectives that models
usually get. "Make it musical" is unfalsifiable. "Write programs to work
together" tells the model what to do when it is tempted to add a tracker, a
bar counter, or an auto-gain.

**Evidence from this repo.** The batches prompted with the Unix phrasing and a
named family (`Chorus/`, `Compressor Limiter/`, `Vowel Formant Comb Lowpass/`)
landed as families you can patch against each other. The batch prompted with
"create as many effects as necessary to represent all the relevant ideas" over
a whole conference index is the batch that produced 17 files with two distinct
syntax failures, and 10 effects that compiled but sounded broken (repair: about
1h20). Nothing about that prompt was unkind to the model — it just had no unit
and no stopping rule, so the only available objective was coverage.

### The corollary that matters more than the slogan

State the disqualifier, not just the ideal:

> "If an effect would be a near-duplicate of another in this batch, merge them
> or drop the worse one — and say which, in the roster, before writing code."

Merging at roster time is a naming decision. Merging at code time is a rewrite.

---

## 2. Why "these inputs are allowed" worked

Naming pitch, a 1-bar phasor and an envelope as *available* removes the largest
hidden job in every effect: sensing. That job is stateful, expensive, and wrong
in the same way in every file — zero-crossing fallbacks that mistrack a tuba,
windows that smear attacks, octave errors, and a latency that differs per
effect, which quietly breaks "work together".

Look at what happens when it is not stated. `FMPD/09_pitch_tracked_comb_resonator.txt`
documents `in3` as "fallback ZC if <= 0" — a good-intentioned embedded tracker,
in a file whose actual job is a comb filter. `FMPD/17_inst_cyber_tuba_tearout_engine.txt`
does several jobs in one file (pitch-tracked isolator, self-FM feedback delay,
rotating ring modulator, allpass disperser, 1-bar chopper) because each job
also had to bring its own sensing.
`FMPD/00d_tuba_4op_modfm_resynthesizer.txt` ended up with nine inlets.

So the allowed-inputs paragraph is really a **restriction**: it says *this is
the only sensing you may have*. Write it that way, with units, update rates and
— the part everyone forgets — the **absence semantics**.

### The control bus, stated per batch

| Inlet | Unit | If unpatched / zero | Rule |
| --- | --- | --- | --- |
| `in1`, `in2` | audio | — | stereo in, stereo out; never assume mono |
| `in3` | `f0` Hz | 0 = unknown | hold last value, or run fixed-frequency; **never** divide by it, never read 0 as 1 Hz, never fall back to zero-crossing |
| `in4` | *declared by the batch* | 0 = no modulation | see below |

`in4` is the one that needs a per-batch decision, because the same wire carries
two different readings:

- **Hz** — an LFO rate, a tempo, a bar rate (`1/barSeconds` ≈ 0.55 Hz at 110 BPM).
- **0..1 phase** — a 1-bar phasor. Sample-accurate sync without the effect
  knowing anything about tempo, which is exactly why it is worth allowing.

Both are legitimate; mixing them within a batch is not. **The unit of `in4` is a
property of the batch, not of the effect**, and every effect in the batch must
read it identically. Say which one in the prompt, put it in each header, and
make the paraminfo repeat it.

An envelope (0..1 unipolar) is the usual exception. Keep it on its own inlet in
its own batch rather than overloading `in4` — an envelope-driven filter batch
reads `in4` as 0..1 and a modulation batch reads `in4` as Hz, and neither is
confused about the other.

**No `in5` in a unit batch.** If a candidate needs a fifth inlet, it is either
an analysis/resynthesis pair (its own batch) or it belongs to a different family.
Nine inlets is what a batch looks like when nobody said this.

---

## 3. Grouping: what makes N effects *one* batch

Group by the thing that is shared, in this order of usefulness:

**1. One mechanism family (best).** "Comb filtering", "formant/vowel",
"chorus", "compressor detector topologies". Each effect is a different way to
set up the same signal path, so:
- the DSP risks are **correlated** — which is both the danger and the test. Four
  effects once froze their carriers on the same reserved constant `phi`; seven
  Hilbert effects shared one allpass sign slip. In a family you catch it once
  and fix it everywhere. Across unrelated effects you catch it seven times.
- the parameter vocabulary transfers, so your fingers learn the batch.
- the differences are *audible and comparable*, which is what the audition rig
  is for. Ten unrelated effects are ten separate opinions.

**2. One port source (mechanical).** `JSFXClones/`, `mrelwood/`, `airwindows/`.
This is a good batch shape precisely because there is no design decision: the
acceptance test is faithfulness, not invention. Keep port batches separate from
paper batches — the prompts and the definition of "done" are different, and a
port is allowed 60 parameters (`mrelwood_DubStep_Wob-Wob.txt`) where a paper
effect must stay under 8.

**3. One composition (derived, never primary).** `_inst_` effects — a chain of
units materialised as one file because the rig wants one codebox~ on stage.
Useful, but they are *outputs* of the batch, not coverage of it. If the prompt
lets the model invent instruments, it will, and each one hides several units'
worth of paper reading inside a file you cannot recombine. Prompt it as:
"after the roster is complete and verified, optionally combine units A+B+C into
one `_inst_` file; do not count it toward the roster."

**4. A count (worst).** "Create 12 effects about modulation" is twelve unrelated
bets sharing one context window. One bad assumption about, say, how `in3`
behaves invalidates all twelve, and you find out one at a time.

### Size the batch to the audition, not to the context

136 effects exist; 100 are rated. At that rate, a batch of 10 is roughly 7
auditions and — going by the 17 fives in 100 ratings — about 2 keepers. That is
the real economics: **a batch of 8–12 is one sitting at the rig**, a batch of 40
is a backlog. Say the number in the prompt and say it is the number you intend
to audition this week.

### Naming is organizing

The existing names already encode the group (`chorus_bbd_compander_juno`,
`comp_ssl_g384_bus_vca`, `09_pitch_tracked_comb_resonator`). Keep that: a batch
gets a **family prefix**, then mechanism, then character. Numeric prefixes are
for a curated series with an intentional order.

---

## 4. Restricting "in one go": scope with teeth

Four scopes to state explicitly. Each one exists because of a specific way this
repo has been burned.

**Write scope.** "You may create exactly `generated_fx/<Cat>/<prefix>_*.txt` and
their `_paraminfo.txt`. Do not edit other effects, `tools/`, `main_test_patcher.maxpat`,
or `AGENTS.md`. Do not hand-edit `generated_maxpat/` or `generated_v8ui/`."
Mixing tool work into a content batch is where the destructive incident came
from; they deserve separate prompts.

**Read scope.** "Read `docs/rnbo_codebox/Codebox_Reference.md` and the examples;
search the corpus for this family only; cite at most K papers." The
search-and-read step balloons silently — an index sweep plus full-text reads can
consume the budget the writing needed. Cap it and require one line of citation
per effect.

**Roster scope — freeze before writing.** Have the model write the whole batch's
roster first: filename, one-line job, inlets used, parameter names and ranges,
paper citation. Nothing else. Then freeze it and write code one effect at a
time. This is cheap (one message) and it prevents the two most expensive
mid-batch changes: renaming a parameter (which is the RNBO parameter id and the
`setparam` target and the v8ui label) and discovering effect #9 duplicates #3.

**Time / turn scope.** A stated budget changes strategy for the better: the
compressor batch was explicitly given ~17 minutes and told to search briefly,
and it produced a coherent set instead of an index survey. Say "one batch, one
sitting; if the roster will not fit, cut the roster, do not cut the verification."

---

## 5. Forbidden list

Bans are more effective than goals, because a model can satisfy a goal by
adding features and can only satisfy a ban by not adding them. A batch prompt
should carry:

- no internal pitch detection, envelope following, onset detection or bar
  counting — those arrive on `in3`/`in4`/their own inlet;
- no transport, tempo or sample-rate assumptions beyond `samplerate()`;
- no internal safety limiter or auto-gain "just in case" — a unit that changes
  level hides a broken one;
- no GUI, metering, preset or MIDI code (the v8ui and patcher are generated);
- no "modes" enum that makes one effect two effects;
- no renaming of existing files or parameters;
- Ask human before creating new tooling, dependencies or doc files.

And one positive ban that does most of the work:

> "Every effect in this batch must be fully useful with `in3`/`in4` unpatched.
> If it only makes sense with the tracker connected, it is not a unit — say so
> in the roster instead of shipping it."

---

## 6. Acceptance tests to put in the prompt

"Done" must be mechanical, or the batch will be declared done at compile time.

1. `node tools/verify_codebox.js <each file>` → exit 0, and once more for the
   whole category at the end. Nothing is done until the batch verifies together.
2. Inlet/outlet table in each header matches the roster, and every inlet below
   the highest one used is actually referenced (or bound to a dummy).
3. **Unpatched-control test** — with `in3`/`in4` at 0 the effect still passes
   audio, does not go silent, does not scream, and its documented fallback
   behaviour is what actually happens.
4. **Swap test** — two effects of the batch chained in either order, no adapter:
   finite output, no DC step, no gain cliff between orders.
5. **One-line test** — the header's first line states the job, and no parameter
   belongs to a different job.
6. ≤8 parameters, musical units, defaults audible at the rig.
7. Parameter names unique within the effect, consistent across the family.

Then generate and stop: `generate_maxpats.py --only <batch>` and
`generate_v8uis.py --only <batch>`, hand over for the ear. 

---

## 7. Template

```md
Batch: <family> — <N> effects, <Category>/
Goal: <one sentence about the mechanism, not the vibe>.

UNIT
One effect = one .txt in generated_fx/<Category>/ = one job stated in one line
of the header. If a new idea does not fit that line, it is a new effect.
Follow the Unix philosophy: "Write programs that do one thing and do it well"
and "Write programs to work together". If two candidates are near-duplicates,
merge or drop one — in the roster, before writing code.

CONTRACT (all effects in this batch, identically)
in1/in2 audio, out1/out2 audio.
in3: f0 in Hz. 0 means unknown: hold last value (or fixed frequency, say which).
     Never divide by in3, never treat 0 as 1 Hz, no internal zero-crossing fallback.
in4: <Hz modulation | 0..1 one-bar phasor | 0..1 envelope>. 0 means the
     batch-declared neutral (no modulation, or a closed envelope) and the effect
     must still be usable and quiet-safe with it at 0.
No in5. No internal pitch detector, envelope follower, onset detector or bar counter.
No safety limiter, no modes, no GUI/metering/preset code.

ROSTER FIRST (then stop and wait)
One table: filename, one-line job, inlets used, params (name, range, default,
unit), paper citations. Nothing else yet. I will freeze it.

THEN, ONE EFFECT AT A TIME
Header comment citing paper/section and listing inlets/outlets; <= 8 params with
musical units and an audible default; write <name>_paraminfo.txt in the same
brevity as the existing ones. Run:
  node tools/verify_codebox.js generated_fx/<Category>/<name>.txt
before starting the next effect.

SCOPE
Create only generated_fx/<Category>/<prefix>_*.txt and their _paraminfo.txt.
Do not edit other effects, tools/, main_test_patcher.maxpat, or AGENTS.md, and
never hand-edit generated_maxpat/ or generated_v8ui/.
Read scope: docs/rnbo_codebox/ (reference + examples 1-25) and at most <K>
papers from the corpus; cite one line per effect.
Budget: one sitting. If the roster will not fit, cut effects, not verification.

ACCEPTANCE
verify_codebox.js passes for every file and for the whole category; roster table
matches the headers; unpatched-control test and swap test pass as described.
Then run generate_maxpats.py --only <batch> and generate_v8uis.py --only <batch>,
report what you verified, and hand the listening test to me.
```

Filled in, the batch-defining part is two lines, e.g.:

```md
Batch: envelope-driven formant filters — 8 effects, Vowel Formant Comb Lowpass/
in4: 0..1 envelope from the rig's follower (not Hz). in3: f0 Hz.
Family: one formant bank (3-5 bandpasses, shared coefficient set) and eight
different ways of moving it from the envelope.
```

---

## 8. How to tell a batch went wrong

Read the diff before listening. Symptoms, roughly in order of cost:

- two effects in the batch with the same parameter list → the family had no
  invariant, and one of them is redundant;
- an effect that is quiet unless the tracker is patched → sensing crept back in;
- `tools/` modified in the same batch → the two kinds of prompt got mixed;
- the roster changed after code was written → the freeze happened too late.

A batch can pass every check and still be mediocre — that is the ear's call.
But a batch that shows any of these symptoms usually cannot be fixed by
listening harder; the prompt was under-specified, and the fix belongs in the
next batch's first five sentences.

---

## 9. What the prompt cannot do

- It cannot make ten ideas good. Expect ~2 keepers per 10; prompt for
  **coherence within a family**, not for hits.
- It cannot verify sound. `verify_codebox.js` proves RNBO will load the file and
  C++ will compile. Level, DC, clicks and musical range are the ear's verdict in
  `.github/README.md`.
- It cannot replace the roster, the file naming, or the frozen parameter list.
  Those are the human's organizing decisions — the prompt's job is to hand the
  model a small, closed world in which the only remaining decisions are DSP.
