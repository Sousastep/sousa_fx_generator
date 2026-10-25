// ---------------------------------------------------------------------------
// example27 - What the audition rig actually sends on in3 / in4
//
// RULE: in main_test_patcher.maxpat, in3 is ALWAYS the tracked pitch in Hz
// (tuba_freq_tracker_v2 out1, typically 30..400, held between notes) and in4 is
// ALWAYS a running 0..1 bar phasor (phasor~ 0.5). Code that reads in3/in4 as
// anything else must tell those signals apart, and a bar input must count as
// "running" only while it MOVES.
//
// Silent failures found in ai_freq_mod_phase_dist:
//   - in3 read as a 0..1 envelope: clamp(in3, 0, 1.5) pins at 1.5 forever, a
//     constant drive offset (buchla259, spectral_delay_chirp_filter)
//   - in4 read as an external modulator "if non-zero": the bar ramp replaced
//     the audio-rate modulator, so the effect lost its pitch lock or did almost
//     nothing (cm_allpass_chain_synth, retuned_exp_fm_ltz)
//   - in4 added to a control at full level: a slow sweep that snaps back with
//     a click at every bar wrap (brassifier, nonlinear_ladder_allpass)
//   - in4 as a freeze gate: a ramp is >= 0.5 half the time, so the analyzer
//     froze for 1 s of every 2 (00c)
//   - bar phasor read from in3 instead of in4 (10_phasor_synced_comb_flanger)
//   - "bar active" tested as (moved || 0.001 < in4 < 0.999): any held value
//     inside (0, 1) counts as a running bar, so the LFO freezes
//
// BROKEN:
//
//     let barActive = (abs(barIn - prevBarIn) > 0.000001 || (barIn > 0.001 && barIn < 0.999));
//     let env = clamp(in3, 0.0, 1.5);            // 58 Hz pitch -> 1.5 forever
//     let modWave = (abs(in4) > 0.0001) ? in4 : cos(2.0 * pi * ph);
//
// CORRECT: a bar is running for 100 ms after it last moved; an envelope on in3
// is only believed when it is in range; an external modulator is opt-in.
// ---------------------------------------------------------------------------

@param({ min: 0.0, max: 1.0 }) ext_mod = 0.0;

@state prevBarIn = 0.0;
@state barHold = 0.0;
@state freeBar = new phasor();
@state modPh = new phasor();

let sr = maximum(samplerate(), 1.0);
let xL = in1;
let xR = in2;
let barIn = in4;

// in4 counts as a running bar for 100 ms after it last moved (a held value is not a bar)
if (abs(barIn - prevBarIn) > 0.0000001) {
	barHold = 0.1 * sr;
} else if (barHold > 0.0) {
	barHold -= 1.0;
}
prevBarIn = barIn;
let fallbackPh = freeBar.next(0.5);
let barPh = (barHold > 0.0) ? wrap(barIn, 0.0, 1.0) : fallbackPh;

// in3: an envelope only when it looks like one; the rig's pitch in Hz is ignored
let env = (in3 >= 0.0 && in3 <= 1.5) ? in3 : 0.0;

// external modulator on in4 is opt-in (default 0 = internal oscillator)
let f0 = (in3 > 20.0 && in3 < 1000.0) ? in3 : 58.27;
let internalMod = cos(2.0 * pi * modPh.next(f0));
let modWave = linearinterp(clamp(ext_mod, 0.0, 1.0), internalMod, clamp(in4, -1.0, 1.0));

let gain = 0.5 + 0.25 * sin(2.0 * pi * barPh) + 0.25 * env;
out1 = xL * gain * (0.75 + 0.25 * modWave);
out2 = xR * gain * (0.75 + 0.25 * modWave);
