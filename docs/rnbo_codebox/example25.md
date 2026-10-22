// ---------------------------------------------------------------------------
// example25 - Contiguous inlet and outlet references (in1..inN, out1..outM)
//
// RULE: every inlet below the highest referenced inlet (and every outlet below
// the highest referenced outlet) must appear at least once in executable code.
//
// Why: `generate_maxpats.py` (and `verify_codebox.js`) wires `in~ 1..N` and
// `out~ 1..M` up to the highest `inN` / `outM` index found in the script.
// However, RNBO `codebox~` only creates inlet/outlet ports for the indices
// actually referenced in executable code (comments do not count).
//
// BROKEN: uses in1, in2, and in4 (bar phasor), but skips in3 (pitch):
//
//     let xL = in1;
//     let xR = in2;
//     let barIn = in4;   // Max console warning: codebox~ has no inlet in3!
//
// CORRECT: bind any unused lower inlet to a dummy local so RNBO creates the
// port and the patcher's `in~ 3` -> `codebox~` connection is valid:
//
//     let xL = in1;
//     let xR = in2;
//     let unused_in3 = in3;
//     let barIn = in4;
// ---------------------------------------------------------------------------

@param({ min: 0.1, max: 5.0 }) rate_hz = 0.5;
@param({ min: 0.0, max: 1.0 }) mix = 0.5;

@state freeLfo = new phasor();
@state prevBarIn = 0.0;

let xL = in1;
let xR = in2;
let unused_in3 = in3; // keep in3 port present when in4 is used
let barIn = in4;

let barActive = (abs(barIn - prevBarIn) > 0.000001 || (barIn > 0.001 && barIn < 0.999)) ? 1.0 : 0.0;
prevBarIn = barIn;

let phase = barActive ? wrap(barIn, 0.0, 1.0) : freeLfo.next(clamp(rate_hz, 0.1, 5.0));
let mod = 0.5 + 0.5 * sin(2.0 * pi * phase);

let w = clamp(mix, 0.0, 1.0);
out1 = linearinterp(w, xL, xL * mod);
out2 = linearinterp(w, xR, xR * mod);
