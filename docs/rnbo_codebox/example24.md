// ---------------------------------------------------------------------------
// example24 - Keep phase monotonic: track the fundamental, hold what you latch
//
// Two different ways a generated effect produced clicks and "phase tearing",
// both of which come down to a phase signal that is not monotonic:
//
// 1) Taking the phase from atan2() of the audio and using it as the oscillator
//    phase. For a single sine this is fine, but tuba/brass waveforms have
//    strong harmonics, so the analytic signal's angle reverses inside every
//    period (the harmonics momentarily dominate the vector), i.e. the
//    "instantaneous phase" goes backwards several times per cycle. Feeding
//    that to cos() truncates the carrier and the FM sidebands tear.
//    Fix: estimate the fundamental, then integrate it as a phase ramp
//
//        pllPhase = wrap(pllPhase + f0 / sampleRate, 0.0, 1.0);
//
//    Harmonics are then built as cos(2*pi*k*pllPhase) from the *same* ramp, so
//    they can never disagree with each other.
//
// 2) Latching a control that can legitimately be zero. A bar-synced phasor
//    (in4) is 0.0 for a couple of samples at every bar line, and a detector
//    written as
//
//        let barActive = (barIn > 0.0) ? 1.0 : 0.0;
//        let phase = (barActive > 0.5) ? barIn * 2.0 : freeRunning;
//
//    switches to the free-running LFO for exactly those samples and back,
//    which is a step discontinuity in phase - a click, no matter how smooth
//    the rest of the patch is. Fix: sample-and-hold the last valid value and
//    only fall back after the input has really gone quiet:
//
//        if (abs(barIn - prevBarIn) > 1.0e-7) { barLast = barIn; barHold = 0.1 * sampleRate; }
//        else if (barHold > 0.0) { barHold -= 1.0; }
//        let phase = (barHold > 0.0) ? barLast * 2.0 : freeRunning;
//
// The 100 ms hold is longer than any wrap-around dropout and shorter than a
// musical bar, so a real transport stop still hands control back to the LFO.
// ---------------------------------------------------------------------------

@param({ min: 0.0, max: 1.0 }) tracking = 0.8;
@param({ min: 0.0, max: 8.0 }) harmonic = 3.0;
@param({ min: 0.0, max: 1.0 }) mix = 0.6;

@state lpTrack = new onepole();
@state prevSig = 0.0;
@state zcCount = 0.0;
@state zcHz = 58.27;
@state smoothF0 = 58.27;
@state pllPhase = 0.0;

@state freeLfo = new phasor();
@state prevBarIn = 0.0;
@state barLast = 0.0;
@state barHold = 0.0;

let sampleRate = maximum(samplerate(), 1.0);
let gain = clamp(in1, 0.0, 1.0);
let unused_in2 = in2;

// --- 1. Fundamental estimate from lowpassed zero crossings ---
// The 190 Hz lowpass removes the harmonics that would otherwise add extra
// zero crossings and double the measured pitch.
let monoLow = lpTrack.next(in1, 190.0);
zcCount += 1.0;
if (prevSig <= 0.0 && monoLow > 0.0) {
	if (zcCount > sampleRate / 500.0 && zcCount < sampleRate / 22.0) {
		zcHz = sampleRate / zcCount;
	}
	zcCount = 0.0;
}
prevSig = monoLow;

// in3 overrides the tracker when a real pitch is patched in
let in3Hz = (in3 > 20.0 && in3 < 1200.0) ? in3 : zcHz;
let slew = 1.0 - exp(-1.0 / (0.006 * sampleRate));
smoothF0 += (in3Hz - smoothF0) * slew;
let f0 = clamp(smoothF0, 24.0, 1000.0);

// Monotonic phase ramp: this is the only phase the oscillators may use
let phaseInc = f0 / sampleRate;
pllPhase = wrap(pllPhase + phaseInc, 0.0, 1.0);

// --- 2. Held bar phasor: latch the last valid value, do not react to zeros ---
let barIn = in4;
if (abs(barIn - prevBarIn) > 0.0000001) {
	barLast = barIn;
	barHold = 0.1 * sampleRate;
} else if (barHold > 0.0) {
	barHold -= 1.0;
}
prevBarIn = barIn;

let lfoPh = freeLfo.next(0.35);
let ctrlPhase = (barHold > 0.0) ? wrap(barLast * 2.0, 0.0, 1.0) : lfoPh;

// --- 3. Harmonics from the same ramp, so they stay phase-locked ---
let hNum = clamp(harmonic, 1.0, 8.0);
let blip = 0.35 + 0.65 * sin(2.0 * pi * ctrlPhase);
let amp = clamp(tracking, 0.0, 1.0) * blip * gain;

let fundamental = cos(2.0 * pi * pllPhase);
let overtone = cos(2.0 * pi * hNum * pllPhase);

let wet = (fundamental + 0.4 * overtone) * amp;
out1 = linearinterp(clamp(mix, 0.0, 1.0), gain, wet);
out2 = pllPhase;
out3 = f0;
out4 = ctrlPhase;
