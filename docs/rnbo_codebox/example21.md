// ---------------------------------------------------------------------------
// example21 - A delay only moves if you call step() (or use next())
//
// `write()` stores a sample, `read()` looks backwards from the *current* read
// pointer, and only `step()` advances that pointer. Forgetting step() is
// silent: the generated C++ still contains the write and the read, the object
// compiles, and the patch just never delays anything.
//
// Generated C++ for the broken pattern
//
//     @state d = new delay(1.0);
//     d.write(in1);
//     out1 = d.read(10);
//
// is
//
//     this->d_write(in1[(Index)i]);
//     out1[(Index)i] = this->d_read(10, 0);
//     // ... and no d_step() anywhere in the process loop
//
// `d_read()` computes `size + reader - N` with `reader == 0` forever, so the
// same slot is read every sample: silence if that slot was never written, or
// whatever the last lap of the circular buffer left there. There is no error
// and no warning. A limiter built this way delays its detector input by 0
// samples, so its lookahead never engages and the output clips exactly as
// hard as the input.
//
// Two correct forms, both verified with tools/verify_codebox.js:
//
//   // (a) bundle it - read, write, step in one call
//   let y = d.next(x, delaySamples);
//
//       number d_next(number v, Int size) {
//           number val = this->d_read(effectiveSize, 0);
//           this->d_write(v);
//           this->d_step();          // <- the pointer advances here
//           return val;
//       }
//
//   // (b) explicit - order matters, exactly one step per sample
//   let y = d.read(delaySamples);
//   d.write(x);
//   d.step();
//
// The delay size passed to read()/next() is in *samples* (fractional values
// are interpolated), so convert seconds with `seconds * sampleRate`, and clamp
// it below the constructor size: `new delay(1.0)` allocates one second, and
// read() clamps larger requests to that maximum instead of erroring.
// ---------------------------------------------------------------------------

@param({ min: 0.0005, max: 0.030 }) delay_s = 0.008;
@param({ min: 0.0, max: 0.9 }) feedback = 0.55;
@param({ min: 0.0, max: 1.0 }) depth = 0.5;
@param({ min: 0.0, max: 1.0 }) mix = 0.5;

@state dl = new delay(1.0);
@state dr = new delay(1.0);
@state lfoA = new phasor();
@state fbL = 0.0;
@state fbR = 0.0;

let sampleRate = maximum(samplerate(), 1.0);
let baseSamples = clamp(delay_s, 0.00005, 0.05) * sampleRate;
let depthSamples = clamp(depth, 0.0, 1.0) * 0.004 * sampleRate;

// in2 sets the modulation rate so the comb movement is audible
let modHz = 0.1 + 1.4 * clamp(in2, 0.0, 1.0);
let modPhase = lfoA.next(modHz);
let modOffset = sin(2.0 * pi * modPhase) * depthSamples;

// One `next()` per channel per sample: read the delayed sample, write the
// input plus feedback, advance the pointer.
let tapL = dl.next(in1 + fbL * clamp(feedback, 0.0, 0.9), baseSamples + modOffset);
let tapR = dr.next(in2 + fbR * clamp(feedback, 0.0, 0.9), baseSamples - modOffset);
fbL = tapL;
fbR = tapR;

let w = clamp(mix, 0.0, 1.0);
out1 = linearinterp(w, in1, 0.5 * (in1 + tapL));
out2 = linearinterp(w, in2, 0.5 * (in2 + tapR));
