// ---------------------------------------------------------------------------
// example23 - Instantaneous frequency: wrap the phase, then trust the envelope
//
// Once a quadrature pair gives you z[n] = re + j*im, the IF is the per-sample
// phase advance. Three ways to write it, only the last one behaves:
//
//   // (1) atan2 of the raw signal, differenced without wrapping
//   let theta = atan2(im, re);
//   let hz = (theta - prevTheta) * sampleRate / (2.0 * pi);
//   // whenever the phase crosses +/- pi the difference jumps by 2*pi:
//   // a full-scale spike in the frequency control signal, every half cycle,
//   // which in an FM resynthesis patch is heard as a click.
//
//   // (2) wrap the difference instead
//   let dTheta = phasewrap(theta - prevTheta);   // or wrap(x, -pi, pi)
//   // correct in angle, but dTheta is still noisy: atan2 amplifies the
//   // quadrature pair's noise by 1/a^2 as the envelope a(t) approaches zero,
//   // so fades and decay tails produce multi-kHz IF spikes.
//
//   // (3) cross-product difference, weighted by envelope confidence
//   let cross = re * prevIm - im * prevRe;
//   let dot = re * prevRe + im * prevIm;
//   let dTheta = 0.0 - atan2(cross, dot + 1.0e-8);
//   // dTheta = arg(z[n] * conj(z[n-1])), no branch cut involved, and the
//   // denominator is |a|^2 so the angle is amplitude independent.
//   let envWeight = clamp((rawIA - 0.003) * 80.0, 0.0, 1.0);
//   heldIF = linearinterp(envWeight, anchorF0, clampedHz);
//
// The last line is the part that actually fixed the chorus_amfm_hilbert
// *IFer patches: instead of clamping a spike, blend the whole extraction
// towards a trusted anchor (the tracked fundamental, or a pitch input) when
// the envelope says the measurement is unreliable. Only 0.3 % of full scale
// of envelope is needed to reach full confidence, so normal playing is
// untouched while gaps between notes stop generating FM splatter.
//
// The measured frequency is also clamped to a musical window around the
// anchor. Extraction cannot invent octaves that are not in the signal, so
// anything outside [0.45 * f0, 3.5 * f0] is a measurement artefact.
// ---------------------------------------------------------------------------

@param({ min: 20.0, max: 1000.0 }) pitch_hz = 58.27;
@param({ min: 80.0, max: 3000.0 }) smoother_hz = 450.0;
@param({ min: 0.0, max: 1.0 }) mix = 0.7;

// Analytic pair arrives on in1 (real) / in2 (imaginary) from the Hilbert stage
@state prevRe = 0.0;
@state prevIm = 0.0;
@state heldIF = 58.27;
@state ifLp1 = new onepole();
@state ifLp2 = new onepole();

let sampleRate = maximum(samplerate(), 1.0);
let re = in1;
let im = in2;

// Pitch anchor: in3 wins when it carries a usable frequency, otherwise the
// pitch parameter is the fallback
let in3Hz = (in3 > 20.0 && in3 < 1200.0) ? in3 : pitch_hz;
let anchorF0 = clamp(in3Hz, 24.0, 1000.0);

let rawIA = sqrt(re * re + im * im);

// Cross-product phase difference: dTheta = arg(z[n] * conj(z[n-1]))
let cross = re * prevIm - im * prevRe;
let dot = re * prevRe + im * prevIm;
let dTheta = 0.0 - atan2(cross, dot + 0.00000001);
prevRe = re;
prevIm = im;

let instHz = dTheta * sampleRate / (2.0 * pi);

// Envelope confidence: 1.0 above about 1.5 % of full scale, 0.0 in silence
let envWeight = clamp((rawIA - 0.003) * 80.0, 0.0, 1.0);

// Reject impossible measurements, then cross-fade to the anchor
let boundedHz = clamp(instHz, anchorF0 * 0.45, anchorF0 * 3.5);
heldIF = linearinterp(envWeight, anchorF0, boundedHz);

// Two cascaded one-poles: 80 Hz keeps unison shimmer, 3 kHz keeps brass growl
let smoothHz = ifLp2.next(ifLp1.next(heldIF, clamp(smoother_hz, 80.0, 3000.0)), clamp(smoother_hz, 80.0, 3000.0));

let w = clamp(mix, 0.0, 1.0);
out1 = linearinterp(w, anchorF0, smoothHz);
out2 = rawIA;
out3 = instHz;
out4 = envWeight;
