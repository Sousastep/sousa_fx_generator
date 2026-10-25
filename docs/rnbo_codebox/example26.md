// ---------------------------------------------------------------------------
// example26 - The built-in `svf` saturates: its bandpass is not a linear filter
//
// RULE: when a bandpass is used to MEASURE something (an isolated harmonic's
// level, a phase for a PLL, an envelope that drives synthesis), use a linear
// filter with known gain - not the built-in `svf`.
//
// Why: RNBO's `svf` is Chamberlin's filter (see
// RNBO/source/operators/svf.js). Its q argument maps to a damping of
// ((1 - q) * 1.2)^2, so q = 0.8 is Q ~ 17 and q = 0.95 is Q ~ 280, and the
// band output peaks at 1 / damping (17x .. 280x). The band state also carries a
// cubic limiter, band -= 0.0001 * band^3, scaled for +/-1 audio. On a 58 Hz
// tuba partial it engages from an input of about 0.1, so the "bandpass" output
// is pinned near a constant level and grows odd harmonics. Measured in
// ai_freq_mod_phase_dist before the fix:
//   - 00c analyzer: A1..A4 read 12..20 for a 0.3-peak tone, with the tilt
//     inverted (spectral centroid 2.65 instead of 1.92)
//   - 01 harmonic isolator: out1 at +10.7 dBFS peak whatever the input level
//   - 13 instrument: the envelope it derived never followed the playing
// Fed a control signal in Hz (an instantaneous-frequency track), the limiter
// can even diverge to NaN (amfm_hilbert_transcolorifer at 1 kHz / max res).
//
// BROKEN: level and phase taken from the svf band output
//
//     @state iso = new svf();
//     let band = iso.next(x, f0, 0.85)[2];      // gain ~ 31, saturates
//     let level = abs(band);                    // not the partial's level
//
// CORRECT: a linear, unity-peak TPT (Zavalishin / Simper) bandpass with the
// same Q law. Keep the state in @state arrays and read them inside the helper
// (arrays never travel as function arguments, see example17).
// ---------------------------------------------------------------------------

@param({ min: 20.0, max: 2000.0 }) f0_hz = 58.27;
@param({ min: 0.5, max: 0.95 }) resonance = 0.85;

@state ic1 = new FixedSampleArray(2);
@state ic2 = new FixedSampleArray(2);

// Unity-peak TPT state-variable bandpass, one stage (idx selects the state slot)
function svfBp(idx: Int, x, g, kd) {
	let a1 = 1.0 / (1.0 + g * (g + kd));
	let a2 = g * a1;
	let a3 = g * a2;
	let v3 = x - ic2[idx];
	let v1 = a1 * ic1[idx] + a2 * v3;
	let v2 = ic2[idx] + a2 * ic1[idx] + a3 * v3;
	ic1[idx] = 2.0 * v1 - ic1[idx];
	ic2[idx] = 2.0 * v2 - ic2[idx];
	return kd * v1;
}

let sr = maximum(samplerate(), 1.0);
let q = clamp(resonance, 0.5, 0.95);
// same damping law as the svf object, so a port keeps its selectivity
let kd = clamp(((1.0 - q) * 1.2) * ((1.0 - q) * 1.2), 0.001, 2.0);
let g = tan(pi * clamp(f0_hz, 20.0, sr * 0.45) / sr);

out1 = svfBp(0, in1, g, kd);
out2 = svfBp(1, in2, g, kd);
