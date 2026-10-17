// ---------------------------------------------------------------------------
// Numbers, unary minus and declarations (codebox~)
//
// A declaration whose whole initialiser is a unary minus applied to something
// that is not a plain numeric literal is rejected with
//   "Invalid negative Number."
//     let atten = -grDb;             // ERROR
//     let rawCos = -cos(phase);      // ERROR
//     let x = -(a + b);              // ERROR
// Write the subtraction out instead - it is identical arithmetic and it is what
// every working generated_fx patch does:
//     let atten = 0.0 - grDb;        // OK
//     let rawCos = 0.0 - cos(phase); // OK
//
// Everything else with negative numbers is fine:
//     let x = -1.0;                  // negative literal            OK
//     let x = y * -1.0;              // binary expression           OK
//     let x = 0.0 - y * gain;        // OK
//     y = -in1;                      // assignment (not a declarator) OK
//     out1 = max(-in1, 0.0);         // inside an expression        OK
//     return -x;                     // inside a return             OK
//     @param({ min: -60.0, max: 0.0 }) thresh_db = -18.0;  // OK
// ---------------------------------------------------------------------------

@param({ min: -60.0, max: 0.0 }) thresh_db = -18.0;
@param({ min: 1.0, max: 20.0 }) ratio = 4.0;
@param({ min: 0.0, max: 1.0 }) mix = 1.0;

@state grSmooth = 0.0;

let sr = maximum(samplerate(), 1.0);

// Peak level in dB, with a floor so log() never sees zero
let x_db = atodb(max(abs(in1), 1e-6));

// Static gain computer: amount above threshold, divided by the ratio
let over_db = max(x_db - thresh_db, 0.0);
let gr_db = 0.0 - over_db * (1.0 - 1.0 / clamp(ratio, 1.0, 20.0));

// Attenuation in dB is the negated gain reduction - subtract instead of negating
let atten_db = 0.0 - gr_db;

// One-pole smoothing of that attenuation
let coeff = 1.0 - exp(-1.0 / (0.020 * sr));
grSmooth += (atten_db - grSmooth) * coeff;

// Apply as linear gain: 0.0 - grSmooth is the same as -grSmooth
let makeup = dbtoa(0.0 - grSmooth);
let w = clamp(mix, 0.0, 1.0);

out1 = linearinterp(w, in1, in1 * makeup);
out2 = 0.0 - in1 * makeup;
