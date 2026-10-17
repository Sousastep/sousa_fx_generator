// ---------------------------------------------------------------------------
// example20 - Never name a variable, @state or @param after an RNBO constant
//
// The codebox operator table
// (RNBO/source/operators/simpleoperators.json, "RNBO Constant" entries)
// declares these names as constants:
//
//     pi        3.14159265358979323846            (alias PI)
//     e         2.718281828459045                 (alias E)
//     phi       1.618033988749894848204586834     (alias PHI)
//     twopi     6.28318530717958647692            (alias TWOPI)
//     sqrt2     1.4142135623730951                (alias SQRT2)
//     sqrt1_2   0.7071067811865476                (alias SQRT1_2)
//     degtorad  0.017453292519943295              (alias DEGTORAD)
//     halfpi, invpi, log2e, log10e, ln10, ln2,
//     PI_OVER_2, PI_OVER_4, INVPI, LN2
//
// Identifier resolution finds the constant before it finds your declaration.
// The declaration still parses, so nothing errors - but every later read is
// replaced by the literal. This is what silently froze several generated_fx
// patches: `phi` was the phase accumulator, so the oscillator carrier became
// a DC value and only the slow LFO remained audible. Uppercasing does not
// help: the operator table lists `PI` as an alias of `pi`, and `out1 = PI;`
// generates the literal 3.14159 just like lowercase.
//
// Generated C++ (via tools/verify_codebox.js --keep), one case per line:
//
//   let phi = in1 / 2.0;  out1 = phi;
//       -> out1[(Index)i] = 1.618033988749894848204586834;
//   @state phi = 0.25;    out1 = phi / 2.0;
//       -> out1[(Index)i] = this->1.618033988749894848204586834 / 2;
//          (the `this->1.618...` form is not valid C++ either, so this
//           variant fails at the clang++ stage)
//   @param({ min: 0.0, max: 1.0 }) phi = 0.5;  out1 = phi;
//       -> out1[(Index)i] = 0.5;
//          (the parameter is inlined as its initial value: the knob is dead,
//           yet the object compiles and runs)
//   let phiPhase = in1 / 2.0;  out1 = phiPhase;   // fine, no collision
//   let e = in1 / 2.0;        out1 = e;
//       -> out1[(Index)i] = 2.718281828459045;
//   let max = in1 / 2.0;      out1 = max;        // fine - not a constant
//       -> number max = in1[(Index)i] / (number)2;
//
// The collision is limited to the constant table. Names that merely look
// risky are ordinary locals: `let sr = 48000.0;` really does generate
// `number sr = 48000;` inside the sample loop, and a local spelled `max` is
// emitted as written. The rule is about these specific constant spellings,
// not about avoiding every short name.
//
// Naming rules used by every generated_fx patch:
//   phases          phBase, phase01, phaseInc, pllPhase, phA
//   angular rate    write 2.0 * pi * f inline, do not cache it as `twopi`/`tau`
//   pitch/ratio     f0, ratio, modRatio - never `phi`
//   constants       read `pi` directly; never declare a new name that collides
// ---------------------------------------------------------------------------

@param({ min: 20.0, max: 2000.0 }) rate_hz = 110.0;
@param({ min: 0.0, max: 8.0 }) mod_index = 1.5;
@param({ min: 0.0, max: 1.0 }) mix = 0.8;

@state phBase = 0.0;
@state phMod = 0.0;

let sampleRate = maximum(samplerate(), 1.0);
let gain = clamp(in1, 0.0, 1.0);

// Carrier phase: the name says phase, so the constant table cannot claim it
let phaseInc = clamp(rate_hz, 20.0, 2000.0) / sampleRate;
phBase = wrap(phBase + phaseInc, 0.0, 1.0);

// Modulator phase at a slightly inharmonic ratio, driven by in2
let modRatio = 2.0 + 0.02 * clamp(in2, 0.0, 1.0);
phMod = wrap(phMod + phaseInc * modRatio, 0.0, 1.0);

// 2*pi is written out instead of a cached `twopi` identifier
let modWave = sin(2.0 * pi * phMod) * clamp(mod_index, 0.0, 8.0);
let carrier = sin(2.0 * pi * (phBase + 0.1 * modWave));

let wet = carrier * gain;
out1 = linearinterp(clamp(mix, 0.0, 1.0), gain, wet);
