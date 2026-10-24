// ---------------------------------------------------------------------------
// example22 - Hilbert allpass: y = c*(x + y1) - x1, not c*(x + y1) + x1
//
// Two different one-pole allpasses are easy to confuse. For the cR/cI
// coefficient set used throughout generated_fx (also named cRe/cIm in the
// older files), the quadrature section is
//
//     A. y[n] = c * (x[n] + y[n-1]) - x[n-1]
//        H_A(z) = (c - z^-1) / (1 - c z^-1),  |H_A| = 1,  DC gain -1
//
// The pole is at z = c and the zero at z = 1/c, so it is a true allpass. Four
// sections per branch give a 90 degree phase difference between the branches,
// which is the quadrature pair behind z[n] = x[n] + j*x_hat[n].
//
// Orientation matters too. With this cR/cI order the raw imaginary branch is
// the *negative* Hilbert: at a positive peak of re, im is falling through zero.
// Negate it (imH = -im) so z = re + j*imH rotates at +f; otherwise atan2(im, re)
// runs backwards and an instantaneous-frequency or PLL estimate comes out as -f.
// The magnitude sqrt(re^2 + imH^2) is unchanged by the negation.
//
// The other allpass is
//
//     B. y[n] = c * (x[n] - y[n-1]) + x[n-1]
//        H_B(z) = (c + z^-1) / (1 + c z^-1),  |H_B| = 1,  DC gain +1
//
// It is also allpass, but its pole is at z = -c, and with these cR/cI
// coefficients it is NOT in quadrature: measured phase difference is ~0.4 deg
// at 100 Hz, versus ~89 deg for A. Using B makes sqrt(re^2 + im^2) follow |x|
// rather than an envelope.
//
// The actual sub-bass resonator bug is a third form, one sign away from A:
//
//     C. y[n] = c * (x[n] + y[n-1]) + x[n-1]
//        H_C(z) = (c + z^-1) / (1 - c z^-1)
//
// C is not an allpass: the pole at z = c and the zero at z = -1/c are not
// mirror images. Its DC gain is (1+c)/(1-c): 2.85x at c = 0.48 and 799x at
// c = 0.9975. Eight of those in series do not shift phase 90 degrees; they add
// a huge sub-bass/DC swell, and the derived instantaneous frequency is garbage
// because the branch magnitudes are no longer equal.
//
// Measured cI-vs-cR phase angle at 48 kHz (atan2 of a cos/sin fit, so a
// negative value means the imaginary branch *leads*):
//     30 Hz   A: -82.9 deg   B: 0.1 deg
//    100 Hz   A: -89.2 deg   B: 0.4 deg
//   1000 Hz   A: -86.2 deg   B: 3.6 deg
// At a positive peak of re, im is therefore falling through zero: the raw
// imaginary branch is the negative Hilbert. Negate it as above.
//
// Practical checks:
//   * allpass sanity: |H| = 1 at DC, mid and Nyquist for A and B. C grows at
//     DC and shrinks at Nyquist, so a DC-heavy input is the giveaway.
//   * quadrature sanity: sweep a sine through the pair and check that
//     sqrt(re^2 + im^2) stays flat. If the magnitude rises toward DC, the
//     recursion is C, not A.
//   * these coefficients are the ones used in the effects (cR = real branch,
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

// --- Real branch: y = c*(x + y1) - x1, four sections in series ---
let re = in1;
let t = cR0 * (re + reY[0]) - reX[0]; reX[0] = re; reY[0] = t; re = t;
t = cR1 * (re + reY[1]) - reX[1]; reX[1] = re; reY[1] = t; re = t;
t = cR2 * (re + reY[2]) - reX[2]; reX[2] = re; reY[2] = t; re = t;
t = cR3 * (re + reY[3]) - reX[3]; reX[3] = re; reY[3] = t; re = t;

// --- Imaginary branch: same difference equation, different coefficients ---
let im = in1;
t = cI0 * (im + imY[0]) - imX[0]; imX[0] = im; imY[0] = t; im = t;
t = cI1 * (im + imY[1]) - imX[1]; imX[1] = im; imY[1] = t; im = t;
t = cI2 * (im + imY[2]) - imX[2]; imX[2] = im; imY[2] = t; im = t;
t = cI3 * (im + imY[3]) - imX[3]; imX[3] = im; imY[3] = t; im = t;

// This coefficient order puts the imaginary branch on the negative Hilbert;
// negate it so the analytic signal has positive frequency.
let imH = 0.0 - im;

// Analytic signal: the two branches are ~90 degrees apart, so this envelope
// is flat instead of rising at DC (the tell-tale of the C resonator form)
let ia = sqrt(re * re + imH * imH);

// Instantaneous frequency from the phase difference, wrapped to +/- pi. The
// cross-product form is used here because it stays well conditioned when the
// envelope is small (see example23).
let cross = re * prevIm - imH * prevRe;
let dot = re * prevRe + imH * prevIm;
prevRe = re;
prevIm = imH;
let instHz = (0.0 - atan2(cross, dot + 0.00000001)) * sampleRate / (2.0 * pi);

// Keep a sanity ceiling so a silent input cannot emit absurd frequencies
let safeHz = clamp(instHz, 15.0, sampleRate * 0.45);
let w = clamp(mix, 0.0, 1.0);

out1 = linearinterp(w, in1, re);
out2 = imH;
out3 = ia;
out4 = safeHz;
