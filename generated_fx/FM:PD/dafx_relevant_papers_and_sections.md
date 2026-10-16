# Relevant DAFx Papers & Sections for Live Tuba Dubstep / Riddim DSP

This document indexes and summarizes the most relevant papers and sections from the **International Conference on Digital Audio Effects (DAFx)** corpus (`DAFx-proceedings/`) covering phase dispersion, phase distortion, frequency modulation, quadrature modulation, angle modulation, Modified FM (ModFM), comb filtering, and non-linear acoustic propagation for live amplified and effected tuba performance in modern dubstep, riddim, and tearout styles.

---

## 1. Phase Distortion (PD), Vector Phaseshaping (VPS) & Hybrid PD-PM

### 1.1 `2009_paper_12` — *Adaptive Phase Distortion Synthesis*
- **Authors:** Victor Lazzarini, Joseph Timoney, Jussi Pekonen, Vesa Välimäki (DAFx-09)
- **Path:** `DAFx-proceedings/papers/DAFx-2009/2009_paper_12/paper.md`
- **Relevant Sections:**
  - **Section 2 (p. 1–2):** *Phase Distortion Synthesis* — Establishes the equivalence between Casio CZ-style piecewise-linear Phase Distortion $x(t) = -\cos(2\pi f(\phi(t)))$ and Phase Modulation $f(x) = x + g(x)$ (Eq. 1–6), where $g(x)$ is an inflected sawtooth wave of amplitude $(0.5 - d)$ and effective modulation index $2\pi(0.5 - d)$.
  - **Section 3.1 (p. 3–4):** *Allpass filter-based phase distortion* — Derives the transient-free first-order coefficient-modulated allpass filter $y(n) = x(n-1) - a[x(n) - y(n-1)]$ (Eq. 8) and the exact phase-to-coefficient mapping $m(t) = \frac{1 - \cos(\phi(\omega, t) + \omega)}{2\sin(\phi(\omega, t)/2 + \omega/2)}$ (Eq. 15–16) to apply PD to arbitrary audio signals.
  - **Section 3.2 & 4.2 (p. 4–7):** *Heterodyne phase distortion* — Uses the trigonometric identity $-\cos(2\pi[\phi(t) + g(\phi(t))]) = \sin(2\pi\phi(t))\sin(2\pi g(\phi(t))) - \cos(2\pi\phi(t))\cos(2\pi g(\phi(t)))$ (Eq. 17, Fig. 9) by placing the arbitrary instrument input in quadrature via a Hilbert Transform and ring-modulating with the cosine/sine of a pitch-tracked PD modulator $g(\phi(t))$, including single-inflection sawtooth and double-inflection square/odd-harmonic functions (Fig. 18–20) and unbounded PM index scaling ($> \pi$).

### 1.2 `2011_55_e` — *Vector Phaseshaping Synthesis*
- **Authors:** Jari Kleimola, Victor Lazzarini, Joseph Timoney, Vesa Välimäki (DAFx-11)
- **Path:** `DAFx-proceedings/papers/DAFx-2011/2011_55_e/paper.md`
- **Relevant Sections:**
  - **Section 3 (p. 1–3):** *Vector Phaseshaping Synthesis* — Generalizes the 1D PD breakpoint $(d, 0.5)$ to a 2D inflection vector $p = (d, v)$ via piecewise mapping $\phi_{\text{vps}}(x)$ (Eq. 5–6, Table 1), enabling smooth morphing between sawtooth ($v = 0.5$), half-sine/odd-harmonic ($v = 1$), and narrow pulse waves ($d \to 0, v = 1$).
  - **Section 3.1 & 3.2 (p. 3):** *Synthesising Formants & Aliasing Suppression* — Shows that for $d = 0.5, v \ge 1.5$, VPS generates strong vocal/resonant formant peaks centered at $f_f / f_0 = 2v - 1$ (Eq. 8), and introduces both dual-carrier harmonic crossfading (Eq. 9–10) and a single-oscillator incomplete-period alias-suppression algorithm (Eq. 11–12).
  - **Section 4.3 & 5.2 (p. 5–7):** *Lissajous Modulation & Two-Dimensional Audio-Rate Waveshape Modulation* — Modulates the 2D inflection vector $(d, v)$ along circular, figure-eight, and multi-ring Lissajous trajectories at LFO (bar-synced) or audio-rate ($f_m = (n/m)f_0$) frequencies (Eq. 20, Fig. 7–12).

### 1.3 `2025_DAFx25_paper_48` — *Wave Pulse Phase Modulation: Hybridising Phase Modulation and Phase Distortion*
- **Authors:** Matthew Smart (DAFx-25)
- **Path:** `DAFx-proceedings/papers/DAFx-2025/2025_DAFx25_paper_48/paper.md`
- **Relevant Sections:**
  - **Section 2.2 (p. 2):** *Modified Phase Modulation* — Introduces phase-synchronous PM windowed by a half-sine envelope $w(\phi) = \sin(\pi\phi)$ (Eq. 5–6) so that non-integer modulation ratios $R \notin \mathbb{Z}$ remain strictly periodic at $f_0$ without boundary phase discontinuities.
  - **Section 3.1 & 3.2 (p. 3–5):** *WPPM Algorithm and Implementation* — Segments each period of $\phi[n]$ at breakpoint $d \in (0, 1)$ into two normalized sub-phases $[0, 1]$ and adds independent windowed PM wave pulses $g_1(\phi/d)$ and $g_2((\phi-d)/(1-d))$ onto the underlying PD ramp (Eq. 8–9, Fig. 4–5), producing aggressive TB-303-like resonant acid and dual-formant bass timbres.
  - **Section 4 (p. 5):** *Antialiasing* — Applies complementary duration-dependent window attenuation $w(d/2)$ and $w(1 - d/2)$ (Eq. 10) to suppress aliasing as $d \to 0$ or $d \to 1$.

---

## 2. Modified FM (ModFM), Adaptive FM (AdFM), Loopback FM (LBFM) & Exponential FM

### 2.1 `2008_dafx08_05` — *A Modified FM Synthesis Approach to Bandlimited Signal Generation*
- **Authors:** Joseph Timoney, Victor Lazzarini, Thomas Lysaght (DAFx-08)
- **Path:** `DAFx-proceedings/papers/DAFx-2008/2008_dafx08_05/paper.md`
- **Relevant Sections:**
  - **Section 2 (p. 1–2):** *Bandlimited Pulse Generation* — Formulates the ModFM bandlimited pulse train $y(t) = e^{k(\cos(\omega t) - 1)}\cos(\omega t)$ (Eq. 1–2), whose harmonic spectrum is governed by scaled Modified Bessel functions $e^{-k}(I_{n-1}(k) + I_{n+1}(k))/2$ that decay monotonically with harmonic order $n$ and open/close smoothly like a lowpass filter as $k$ varies (Fig. 3–4).
  - **Section 3 & 4 (p. 2–4):** *Bandlimited Sawtooth and Other Waveform Generation* — Integrates the zero-mean ModFM pulse train through a leaky integrator / DC blocker (Eq. 3–4, Fig. 5–6) and combines phase-shifted ModFM pulses to synthesize alias-controlled sawtooth, square, and triangle waveforms.

### 2.2 `2007_p021` — *Adaptive FM Synthesis*
- **Authors:** Victor Lazzarini, Joseph Timoney, Thomas Lysaght (DAFx-07)
- **Path:** `DAFx-proceedings/papers/DAFx-2007/2007_p021/paper.md`
- **Relevant Sections:**
  - **Section 2.1–2.4 (p. 1–3):** *Delay line-based phase modulation of arbitrary signals* — Demonstrates how a pitch-tracked variable delay line $D(t) = d_0 + (\beta / \omega_0)\cos(\omega_m t)$ applies multi-carrier FM across every harmonic $k\omega_0$ of an acoustic instrument with modulation index $k\beta$.

### 2.3 `2008_dafx08_42` — *Asymmetric-Spectra Methods for Adaptive FM Synthesis*
- **Authors:** Victor Lazzarini, Joseph Timoney, Thomas Lysaght (DAFx-08)
- **Path:** `DAFx-proceedings/papers/DAFx-2008/2008_dafx08_42/paper.md`
- **Relevant Sections:**
  - **Section 2.1 & 2.2 (p. 1–4):** *Single-Sideband AdFM and Asymmetric AdFM* — Combines delay-line phase modulation with exponential amplitude modulation $\exp(k_{\text{amp}}\cos(\omega_m t))$ normalized by $I_0$ to shift sideband energy above or below the carrier.
  - **Section 3.1 & 3.2 (p. 4–5):** *The Split-Sideband Method (ASpSB)* — Uses Hilbert quadrature pairs on the carrier and on the even/odd Bessel modulator expansions $\cos(I\sin\omega_m t)$ and $\sin(I\sin\omega_m t)$ to isolate Upper-Even, Upper-Odd, Lower-Even, and Lower-Odd sidebands (Eq. 5–20).

### 2.4 `2026_DAFx26_paper_36` — *Loopback Frequency Modulation Using a Time-Varying Delay Line*
- **Authors:** Tamara Smyth (DAFx-26)
- **Path:** `DAFx-proceedings/papers/DAFx-2026/2026_DAFx26_paper_36/paper.md`
- **Relevant Sections:**
  - **Section 2.2 & 2.4 (p. 2–4):** *The Loopback FM (LBFM) Oscillator & Alternate Closed-Form Solution* — Relates the self-modulated LBFM oscillator $\omega_b(t) = \omega_c(1 + B\Re\{z_b(t)\})$ with sounding pitch $\omega_0 = \omega_c\sqrt{1 - B^2}$ (Eq. 10–12) to the exact delay-free allpass-like closed-form representation $z_0(t) = \frac{b_0 + e^{j\omega_0 t}}{1 + b_0 e^{j\omega_0 t}}$ with analytic phase $\angle z_0(t) = \omega_0 t - 2\tan^{-1}\left(\frac{b_0\sin(\omega_0 t)}{1 + b_0\cos(\omega_0 t)}\right)$ where $b_0 = \frac{\sqrt{1 - B^2} - 1}{B}$ (Eq. 18–26).
  - **Section 3.1–3.3 (p. 4–6):** *LBFM using a TVDL with a Wrapped Delay Function* — Derives the time-varying delay line (TVDL) warping function $\hat{D}_b(n) = \hat{n}(1 - \omega_0/\omega_c) + 2\phi(n)\frac{f_s}{\omega_c} + d_0$ with integer-period offset $d_0 = k f_s / f_c$ (Eq. 56–58, Fig. 4–5) so arbitrary instrument inputs can undergo LBFM feedback timbre distortion and pitch-glide warping without phase discontinuities.

### 2.5 `2011_60_e` & `2020_DAFx2020_paper_61` — *Exponential FM Theory, Bandwidth & Zero-Drift Re-Tuning*
- **Authors:** Joseph Timoney & Victor Lazzarini (DAFx-11 `2011_60_e`); Symons / DAFx-20 (`2020_DAFx2020_paper_61`)
- **Paths:**
  - `DAFx-proceedings/papers/DAFx-2011/2011_60_e/paper.md`
  - `DAFx-proceedings/papers/DAFx-2020/2020_DAFx2020_paper_61/paper.md`
- **Relevant Sections:**
  - **`2011_60_e` Sec. 2 (p. 1–3) & `2020_DAFx2020_paper_61` Sec. 4.1–4.3 (p. 3–6):** Shows that analog-style Exponential FM $\omega_{\text{exp}}(t) = \omega_c 2^{\alpha m(t)}$ produces an asymmetric sideband spectrum but drifts sharp in pitch by the average factor $E = I_0(\alpha\ln 2)$ (for sine modulators, Eq. 18–19) or $\frac{\sinh(\alpha\ln 2)}{\alpha\ln 2}$ (for triangle/saw modulators, Eq. 20). Subtracting $(E - 1)\omega_c$ in a Linear-Through-Zero (LTZ) oscillator or dividing the carrier/delay modulation by $I_0(\alpha\ln 2)$ yields **concert-tuned, zero-drift Exponential FM** with massive analog bass asymmetry (Fig. 7).

---

## 3. Allpass Phase Dispersion, Coefficient Modulation & Nonlinear Propagation

### 3.1 `2009_paper_66` — *Sound Synthesis Using an Allpass Filter Chain with Audio-rate Coefficient Modulation*
- **Authors:** Jari Kleimola, Jussi Pekonen, Henri Penttinen, Vesa Välimäki, Jonathan S. Abel (DAFx-09)
- **Path:** `DAFx-proceedings/papers/DAFx-2009/2009_paper_66/paper.md`
- **Relevant Sections:**
  - **Section 2.1 & 2.2 (p. 1–4):** *Single First-Order Stage & Chain of First-Order Stages* — Introduces the spike-free audio-rate Coefficient Modulation (CM) difference equation $y(n) = x(n-1) - x(n)m(n) + y(n-1)m(n)$ (Eq. 3) cascaded across $N$ stages (Eq. 11–17). Shows that stage 1 creates a feedback-AM spectrum while cascading $N$ stages acts as a dispersive variable-length delay line that applies non-sinusoidal complex FM, with $N$ directly controlling spectral bandwidth and upper-frequency resonance regions (Fig. 2–4).
  - **Section 4.1 & 4.3 (p. 6–7):** *Synthesizer Sounds & Effect Processing of Arbitrary Signals* — Demonstrates dual-cascade CM chains and pitch-tracked CM processing on monophonic wind instruments (Fig. 8–10).

### 3.2 `2009_paper_36` — *Spectral Delay Filters with Feedback and Time-Varying Coefficients*
- **Authors:** Jussi Pekonen, Vesa Välimäki, Jonathan S. Abel, Julius O. Smith (DAFx-09)
- **Path:** `DAFx-proceedings/papers/DAFx-2009/2009_paper_36/paper.md`
- **Relevant Sections:**
  - **Section 2.1–2.4 (p. 2–4):** *Group Delay, Allpass Chirp Equalization, and Stretched SDF* — Analyzes cascades of $M$ first-order allpass filters ($a_1 < 0$ for downward frequency chirps, $a_1 > 0$ for upward frequency chirps, Eq. 5–6, Fig. 2–3), derives the amplitude-equalizing inverse-envelope filter $H_{\text{eq}}(z)$ (Eq. 13–16), and introduces the **Stretched Spectral Delay Filter** $A(z^K)$ (replacing $z^{-1}$ with $z^{-K}$, Sec. 2.4, Fig. 6) which multiplies chirp duration by $K$ and creates multiple opposing-direction image chirps across the audio band.
  - **Section 3 & 4 (p. 4–6):** *Spectral Delay Filters with Feedback & Time-Varying SDF* — Adds a global feedback loop with loop filter $B(z)$ around the allpass cascade (Eq. 18–25) to generate regenerating rhythmic chirp trains and derives passivity/stability bounds for time-varying coefficients.

### 3.3 `2008_dafx08_16` — *Coefficient-Modulated First-Order Allpass Filter as Distortion Effect*
- **Authors:** Jussi Pekonen (DAFx-08)
- **Path:** `DAFx-proceedings/papers/DAFx-2008/2008_dafx08_16/paper.md`
- **Relevant Sections:**
  - **Section 3 & 4 (p. 3–5):** Analyzes signal-dependent and low-frequency-band-driven coefficient modulation of a first-order allpass filter, where lowpass-filtered input signal amplitude modulates the allpass pole/zero to distort low-frequency phase while avoiding high-frequency aliasing.

### 3.4 `2008_dafx08_36` — *Dispersion Modulation using Allpass Filters*
- **Authors:** Jari Kleimola (DAFx-08)
- **Path:** `DAFx-proceedings/papers/DAFx-2008/2008_dafx08_36/paper.md`
- **Relevant Sections:**
  - **Section 2 & 4.2 (p. 1–4):** *Tunable Dispersion Filter Design Algorithm* — Uses Rauhala & Välimäki's closed-form tunable Thiran allpass dispersion cascade inside a waveguide delay loop and modulates the dispersion coefficient at control and audio rates to sweep between harmonic and bell/gong-like inharmonic spectra.

### 3.5 `2011_38_e` — *Nonlinear Allpass Ladder Filters in FAUST*
- **Authors:** Julius O. Smith, Romain Michon (DAFx-11)
- **Path:** `DAFx-proceedings/papers/DAFx-2011/2011_38_e/paper.md`
- **Relevant Sections:**
  - **Section 3 & 4.1 (p. 2–3):** *Nonlinear Allpasses of Arbitrary Order & Lossless Nonlinear Spectral Expansion* — Formulates the recursive Normalized Ladder Filter (NLF) allpass with power-conserving rotation coefficients $c = \cos(\theta(n)), s = \sin(\theta(n))$ where $\theta(n) = g \cdot x(n)$ is modulated directly by the signal amplitude (Fig. 2–5). Because the rotation matrix is orthogonal at every sample, signal energy is strictly invariant regardless of modulation speed, enabling guaranteed-stable lossless spectral expansion and gong/cymbal-like modal coupling inside resonators.

### 3.6 `2010_CooperAbel_DAFx10_P77` — *Digital Simulation of "Brassiness" and Amplitude-Dependent Propagation Speed in Wind Instruments*
- **Authors:** Charles M. Cooper, Jonathan S. Abel (DAFx-10)
- **Path:** `DAFx-proceedings/papers/DAFx-2010/2010_CooperAbel_DAFx10_P77/paper.md`
- **Relevant Sections:**
  - **Section 2 & 3 (p. 2–4):** *Acoustic Wave Propagation, Waveform Sharpening & Discretization* — Models nonlinear acoustic propagation speed $v(x,t) = c_0 + \beta \frac{p(x,t)}{P_0}$ in brass instrument bores (Eq. 1–12), where high-pressure peaks travel faster than low-pressure troughs, steepening sinusoidal waves into shock-like sawtooth waves ("cuivré" brassiness).
  - **Section 5.1 & 5.2 (p. 4–5):** *Lumped "Brassification" & Audio Effects Architectures* — Implements the equalized and sidechain "Brassifier" (Fig. 6–8): pre-emphasis filter $c(z)$ isolates the dominant bore pressure wave to modulate an interpolated time-varying delay line (with optional shock-wave overtaking vs. full PM Bessel sideband generation), followed by complementary bell-transmission high-frequency equalization $q(z) = c^{-1}(z)$.

---

## 4. Quadrature Modulation, Angle/AM-FM Decomposition & Heterodyne Resonance

### 4.1 `2012_dafx12_submission_58` — *Synthesis of Resonant Sounds with a Heterodyne Model*
- **Authors:** Victor Lazzarini, Joseph Timoney (DAFx-12)
- **Path:** `DAFx-proceedings/papers/DAFx-2012/2012_dafx12_submission_58/paper.md`
- **Relevant Sections:**
  - **Section 2.1, 2.2 & 3 (p. 2–4):** *Modelling a Source-Resonator Combination & Fine-Grained Centre Frequency Control* — Replaces an IIR resonant filter or FOF grain stream with a phase-synchronous `ephasor` (periodic decaying exponential $M(n) = R^{n \bmod T_0}$, or dual-exponential FOF-like attack-decay $M_a(n) - M_b(n)$) ring-modulating two adjacent harmonic cosine carriers $(1 - a)\cos(k\omega_0 n) + a\cos((k+1)\omega_0 n)$ (Eq. 5–12, Fig. 2–4), plus Casio CZ-style resonant sawtooth/triangle/trapezoid window waves.
  - **Section 4.1–4.6 (p. 4–7):** *Second-Order Musical Filters (Sallen-Key, SVF, 4th-Order Polygon) & Frequency-Modulated Filter Cutoff* — Maps the complex pole trajectories of MS-20 Sallen-Key, Oberheim SVF, and 4-pole ladder filters directly into the heterodyne resonator model and applies audio-rate FM to the resonant formant frequency.

### 4.2 `2015_DAFx-15_submission_30` & `2018_DAFx2018_paper_28` — *AM/FM DAFx & Interpretation and Control in AM/FM-Based Audio Effects*
- **Authors:** Antonio José Homsi Goulart, Victor Lazzarini, Joseph Timoney, Marcelo Queiroz (DAFx-15 & DAFx-18)
- **Paths:**
  - `DAFx-proceedings/papers/DAFx-2015/2015_DAFx-15_submission_30/paper.md`
  - `DAFx-proceedings/papers/DAFx-2018/2018_DAFx2018_paper_28/paper.md`
- **Relevant Sections:**
  - **`2015_DAFx-15_submission_30` Sec. 2 & 3 (p. 2–6):** Decomposes an instrument signal via an allpass IIR Hilbert Transform into Instantaneous Amplitude $a(t) = |z(t)|$ and Instantaneous Frequency $f(t) = \frac{d\theta}{dt}$ (Eq. 4–8), then transforms $f(t)$ prior to phase-integrated resynthesis $x_{\text{FX}}(t) = a(t)\cos(2\pi\int f_{\text{FX}}(\tau)d\tau)$:
    - *OctIFer & TransColorIFer (Sec. 3.1–3.2, Eq. 10):* Scales $f(t)$ by ratio $r$ ($0.5, 2.0, 3/2, 9/5$) while keeping the original amplitude envelope $a(t)$, convolving the transposed FM carrier spectrum with the natural AM envelope so pitch remains anchored while sub-harmonics or metallic slide-like upper colorations emerge.
    - *ChorIFer & WahIFer (Sec. 3.4–3.5, Eq. 12–13):* Detunes/delays multiple IF paths or filters the IF trajectory through a resonant bandpass/lowpass filter to create liquid FM chirps and vowel articulation sweeps.
  - **`2018_DAFx2018_paper_28` Sec. 3.1–3.3 (p. 3–5):** Introduces IF lowpass smoothing (turning rapid brass articulation into liquid chirps), IF hard limiting/clipping, and LFO/audio-rate AM/RM modulation of the instantaneous frequency trajectory.

### 4.3 `2010_TimoneyLazzariniGibneyPekonen_DAFx10_P65` — *Digital Emulation of Distortion Effects by Wave and Phase Shaping Methods*
- **Authors:** Joseph Timoney, Victor Lazzarini, Anthony Gibney, Jussi Pekonen (DAFx-10)
- **Path:** `DAFx-proceedings/papers/DAFx-2010/2010_TimoneyLazzariniGibneyPekonen_DAFx10_P65/paper.md`
- **Relevant Sections:**
  - **Section 2.1 (p. 1–2):** *Phase Quadrature Chebyshev Waveshaping* — Extends classical Chebyshev polynomial waveshaping $T_k(\cos\omega t) = \cos(k\omega t)$ to control both harmonic amplitudes *and* harmonic phases simultaneously by combining Chebyshev polynomials of the first kind ($T_k$, in-phase) and second kind ($U_k$, quadrature weighted by $\sin\omega t$) via generative matrices $P$ and $Q$ (Eq. 11–15).

### 4.4 `2022_DAFx20in22_paper_23` — *Deforming the Oscillator: Iterative Phases Over Parametrizable Closed Paths*
- **Authors:** Georg Essl (DAFx-22)
- **Path:** `DAFx-proceedings/papers/DAFx-2022/2022_DAFx20in22_paper_23/paper.md`
- **Relevant Sections:**
  - **Section 3.3, 4 & 6 (p. 2–6):** *Feedback FM (Sine Circle Map) & Deformed Closed-Path Projections* — Formulates Feedback FM as the iterative Sine Circle Map $x_n = (x_{n-1} + \Omega + \frac{k}{2\pi}\sin(2\pi x_{n-1})) \bmod 1$ (Eq. 5, where $k = 1$ marks the Arnold tongue boundary between mode-locked periodicity and chaos) and projects the phase onto deformed 2D geometric loops (diamond, concave L-shape, tensioned Catmull-Rom splines, Sec. 4.1–4.4).

---

## 5. Comb Filtering, Feedback AM, Barberpole Illusions & Modal Distortion

### 5.1 `2009_paper_31` — *Five Variations on a Feedback Theme*
- **Authors:** Victor Lazzarini, Joseph Timoney, Jari Kleimola, Vesa Välimäki (DAFx-09)
- **Path:** `DAFx-proceedings/papers/DAFx-2009/2009_paper_31/paper.md`
- **Relevant Sections:**
  - **Section 2 & 3.1–3.6 (p. 1–5):** *Feedback AM (FBAM) and Variations I–V* — Analyzes $y(n) = x(n)[1 + \beta y(n-1)]$ as a coefficient-modulated one-pole filter with time-varying phase and magnitude (Eq. 2–6), and develops five variations:
    - *Variation III (Eq. 10):* Secondary heterodyne pitch-ratio carrier $\cos(N\omega n)[x(n)(1 + \beta y(n-1))]$.
    - *Variation IV (Eq. 11):* Nonlinear cosine/waveshaper feedback mapping $y(n) = x(n)[1 + \cos(\beta y(n-1))]$ yielding odd-harmonic partial feedback FM spectra.
    - *Variation V (Eq. 12–14, Fig. 9–10):* Variable-delay Comb Feedback AM $y(n) = x(n)[1 + \beta y(n-D)]$ with a one-pole lowpass damping filter in the feedback loop (Sec. 3.6) for arbitrary instrumental inputs, creating sharp pulse-comb spectra when $D = f_s / f_0$ and "phase difference modulation" when $D$ is swept.

### 5.2 `2021_DAFx20in21_paper_2` — *Harmonic Sound Separation & Sympathetic Comb Filter Banks for Distortion*
- **Authors:** DAFx-21 Paper 2
- **Path:** `DAFx-proceedings/papers/DAFx-2021/2021_DAFx20in21_paper_2/paper.md`
- **Relevant Sections:**
  - **Section 2.3 & 4.1–4.5 (p. 2–4):** *Harmonic Sound Separation & Universal Comb Filter* — Combines feedforward (FIR) and feedback (IIR) comb filters into a unity-gain-normalized Universal Comb Filter $H_{\text{UNI}}(z) = \frac{b_0 + b_M z^{-M}}{1 - a_M z^{-M}}$ with exact $Q$-to-coefficient mapping $\beta = \tan(\pi / (2Q))$, $a_M = \frac{1-\beta}{1+\beta}$, $b_0 = b_M = \frac{\beta}{1+\beta}$ (Eq. 6–18). Shows how parallel combs tuned to $f_2 = 2f_0$ with positive/negative polarity separate **Even Harmonics** vs. **Odd Harmonics** in the time domain so each harmonic group can be distorted independently without intermodulation mud!

### 5.3 `2015_DAFx-15_submission_67` — *Barberpole Phasing and Flanging Illusions*
- **Authors:** Fabián Esqueda, Vesa Välimäki, Julian Parker (DAFx-15)
- **Path:** `DAFx-proceedings/papers/DAFx-2015/2015_DAFx-15_submission_67/paper.md`
- **Relevant Sections:**
  - **Section 2 (p. 2–3):** *Cascaded Time-Varying Notch Filters* — Places $M$ parametric EQ notches spaced 1 octave apart with Shepard raised-cosine attenuation envelopes (Eq. 1–8) for endless upward or downward vowel/notch sweeps.
  - **Section 3 (p. 4–5):** *Synchronized Dual Flanger* — Crossfades two sawtooth-modulated fractional-delay comb filters offset by $90^\circ$ using triangular window gains (Eq. 9, Fig. 7–8) to create seamless, infinitely rising or falling barberpole comb sweeps.
  - **Section 4 & 4.1 (p. 5–6):** *Single-Sideband Modulation Barberpole & Spectral-Delay Warped Notches* — Mixes a Hilbert SSB frequency-shifted signal with a delayed or allpass-dispersed (spectral-delay) dry path plus feedback (Eq. 10–14, Fig. 10) to generate log-warped endlessly moving barberpole comb notches.

### 5.4 `2015_DAFx-15_submission_72` — *Distortion and Pitch Processing Using a Modal Reverberator Architecture*
- **Authors:** Jonathan S. Abel, Kurt James Werner (DAFx-15)
- **Path:** `DAFx-proceedings/papers/DAFx-2015/2015_DAFx-15_submission_72/paper.md`
- **Relevant Sections:**
  - **Section 2 & 3.3–3.4 (p. 2, 4–7):** *Heterodyne-Smooth-Modulate Modal Resonators, Spectral Inversion & Distortion Without Intermodulation* — Implements narrowband resonant modes via complex heterodyning $e^{-j\omega_m t}$, complex exponential envelope smoothing, per-mode waveshaping/distortion $d_m(\cdot)$, and re-modulation $e^{j\nu_m t}$ (Eq. 6–8, 13–14, Fig. 2, 8, 12). Enables intermodulation-free harmonic distortion, per-mode octave/pitch shifting, and spectral inversion ($\nu_m = \omega_c^2 / \omega_m$).

### 5.5 `2017_DAFx17_paper_82` — *Virtual Analog Buchla 259 Wavefolder*
- **Authors:** Fabián Esqueda, Henri Pöntynen, Vesa Välimäki, Julian D. Parker (DAFx-17)
- **Path:** `DAFx-proceedings/papers/DAFx-2017/2017_DAFx17_paper_82/paper.md`
- **Relevant Sections:**
  - **Section 2 & 3 (p. 2–6):** *Parallel Op-Amp Deadband Folding Cells & Antialiased Digital Model* — Derives the exact 5-branch parallel deadband wavefolder transfer function of the Buchla 259 Complex Waveform Generator (Eq. 9–18, Table 1) cascaded with its 1st-order lowpass timbre filter and antiderivative/BLAMP antialiasing.
