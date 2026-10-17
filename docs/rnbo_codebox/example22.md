// ---------------------------------------------------------------------------
// example22 - Hilbert allpass sign: y = c*(x - y1) + x1, not c*(x + y1) - x1
//
// An analog-style allpass section with one pole and one zero has to be
//
//     y[n] = c * (x[n] - y[n-1]) + x[n-1]        H(z) = (c - z^-1) / (1 - c z^-1)
//
// The zero sits at z = 1/c, which mirrors the pole at z = c outside/inside the
// unit circle, so |H(e^jw)| = 1 for every frequency. Cascading four of these
// one-pole allpasses (with different c) gives a 90 degree phase difference
// between two branches - that is the quadrature pair used to build the
// analytic signal z[n] = x[n] + j*x_hat[n].
//
// The sign slip that broke seven generated_fx patches was
//
//     y[n] = c * (x[n] + y[n-1]) - x[n-1]        H(z) = (c + z^-1) / (1 - c z^-1)
//
// which is a *different* filter. The numerator zero at z = -1/c removes its
// pole/zero mirror image, and the pole at z = c stays near 1 (c is 0.48 to
// 0.9975 for the quadrature stages), so the section becomes a low-frequency
// resonator: gain at DC is (1 + c)/(1 - c), i.e. 3x for c = 0.48 and over 500x
// for c = 0.9975. Feeding audio through eight of those does not shift phase
// 90 degrees - it adds a huge sub-bass/DC swell, and the derived instantaneous
// frequency is garbage because the branch magnitudes are no longer equal.
//
// Practical checks:
//   * z-domain sanity: a unit-magnitude allpass must have the top coefficient
//     of numerator equal to the *negated* denominator's feedback coefficient.
//     Numerator (c - z^-1), denominator (1 - c z^-1): mirror-image, unity gain.
//   * generated C++ sanity: the whole point of a quadrature pair is that
//     sqrt(re^2 + im^2) stays flat while you sweep a sine through it. If IA
//     rises towards DC or towards Nyquist, the difference equation is wrong.
//   * these coefficients are the ones used in
//     generated_fx/FM:PD/amfm_hilbert_transcolorifer (cR = real branch,
//     cI = imaginary branch); they assume a 44.1-48 kHz sample rate.
// ---------------------------------------------------------------------------

@param({ min: 0.0, max: 1.0 }) mix = 1.0;

// Per-section state: x[n-1] and y[n-1] for each of four allpass stages
@state reX = new FixedSampleArray(4); @state reY = new FixedSampleArray(4);
@state imX = new FixedSampleArray(4); @state imY = new FixedSampleArray(4);
@state prevRe = 0.0;
@state prevIm = 0.0;

let sampleRate = maximum(samplerate(), 1.0);

// Quadrature allpass coefficients (one set per branch)
let cR0 = 0.4794008656; let cR1 = 0.8762184935;
let cR2 = 0.9765975895; let cR3 = 0.9974992559;
let cI0 = 0.1617584983; let cI1 = 0.7330289323;
let cI2 = 0.9453497003; let cI3 = 0.9905991567;

// --- Real branch: y = c*(x - y1) + x1, four sections in series ---
let re = in1;
let t = cR0 * (re - reY[0]) + reX[0]; reX[0] = re; reY[0] = t; re = t;
t = cR1 * (re - reY[1]) + reX[1]; reX[1] = re; reY[1] = t; re = t;
t = cR2 * (re - reY[2]) + reX[2]; reX[2] = re; reY[2] = t; re = t;
t = cR3 * (re - reY[3]) + reX[3]; reX[3] = re; reY[3] = t; re = t;

// --- Imaginary branch: same difference equation, different coefficients ---
let im = in1;
t = cI0 * (im - imY[0]) + imX[0]; imX[0] = im; imY[0] = t; im = t;
t = cI1 * (im - imY[1]) + imX[1]; imX[1] = im; imY[1] = t; im = t;
t = cI2 * (im - imY[2]) + imX[2]; imX[2] = im; imY[2] = t; im = t;
t = cI3 * (im - imY[3]) + imX[3]; imX[3] = im; imY[3] = t; im = t;

// Analytic signal: the two branches are ~90 degrees apart, so this envelope
// is flat instead of rising at DC (the tell-tale of the `x + y1` sign error)
let ia = sqrt(re * re + im * im);

// Instantaneous frequency from the phase difference, wrapped to +/- pi. The
// cross-product form is used here because it stays well conditioned when the
// envelope is small (see example23).
let cross = re * prevIm - im * prevRe;
let dot = re * prevRe + im * prevIm;
prevRe = re;
prevIm = im;
let instHz = (0.0 - atan2(cross, dot + 0.00000001)) * sampleRate / (2.0 * pi);

// Keep a sanity ceiling so a silent input cannot emit absurd frequencies
let safeHz = clamp(instHz, 15.0, sampleRate * 0.45);
let w = clamp(mix, 0.0, 1.0);

out1 = linearinterp(w, in1, re);
out2 = im;
out3 = ia;
out4 = safeHz;
