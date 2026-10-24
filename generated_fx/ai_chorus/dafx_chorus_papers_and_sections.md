# Relevant DAFx Papers and Sections for Live Tuba Chorus, Ensemble, BBD, Rotary & Spatial Thickening Effects

This document catalogs the papers and sections from the **International Conference on Digital Audio Effects (DAFx)** proceedings (`DAFx-proceedings/index/`) relevant to **Chorus, Analog Bucket-Brigade Device (BBD) Chorus/Ensemble, Electromechanical Scanner & Rotary Chorus, Unison Waveform Animation ("Supersaw"), AM/FM & Psychoacoustic Dissonance Chorus, and Perceptual Stereo Decorrelation Chorus** for an amplified live electronic tuba.

---

## 1. Analog Bucket-Brigade Device (BBD) Chorus & Compander Modeling

### 1.1 `2005_P_155` — *Enhanced Digital Models for Analog Modulation Effects*
- **Author:** Antti Huovilainen (DAFx-2005)
- **Path:** `DAFx-proceedings/papers/DAFx-2005/2005_P_155/paper.md`
- **Relevant Sections:**
  - **Section 3 & 4 (pp. 2–4):** *OTA and JFET Allpass Stages* — Nonlinear `tanh` differential equation for OTA stages (Eq. 1–8).
  - **Section 5 & 5.1 (pp. 4–5):** *Analog Flanger and Chorus & Simulating a BBD Delay Line* — Shows how a fixed-$N$ capacitor BBD driven by a variable clock $f_{\text{clock}}$ warps linear LFO triangle waves into an asymmetric $1/f_{\text{clock}}$ hyperbola (Fig. 9), and derives the efficient moving-average clock-warped delay time approximation $t_d = \text{avg}(N f_s / f_{\text{clock}}, M)$ (Eq. 25).
  - **Section 5.2 (pp. 5–6):** *Compander Model (NE570/NE571)* — Derives the matched 2:1 feedback compressor $y = x / \text{avg}(|y|)$ (Eq. 27) before the BBD and 1:2 feedforward expander $y = \text{avg}(|x|) x$ (Eq. 26) after the BBD using a 1st-order full-wave rectifier lowpass filter (Eq. 28–31, Fig. 11).

### 1.2 `2010_RaffelSmith_DAFx10_P42` — *Practical Modeling of Bucket-Brigade Device Circuits*
- **Authors:** Colin Raffel, Julius O. Smith (DAFx-2010)
- **Path:** `DAFx-proceedings/papers/DAFx-2010/2010_RaffelSmith_DAFx10_P42/paper.md`
- **Relevant Sections:**
  - **Section 1.1–1.3 & 2.1–2.3 (pp. 1–4):** *BBD Topology & Anti-Aliasing/Reconstruction Sallen-Key Filters* — Derives the exact delay law $D = N / (2 f_{cp})$ for MN3007/MN3207 ($N = 1024$) and MN3005 ($N = 4096$) chips, and the 3rd-order pre-BBD anti-aliasing and post-BBD reconstruction lowpass filters whose cutoff tracks $f_{cp}/3$ to $f_{cp}/2$.
  - **Section 3.1–3.4 & 4.2–4.4 (pp. 4–6):** *570/571 Companding, Insertion Loss, and Stage-Accumulated THD* — Models the cumulative charge-transfer harmonic distortion $\text{THD} = 1.01^{N/1024} - 1$ (a level-independent quadratic/cubic asymmetry across stages) and clock-dependent high-frequency insertion loss.

### 1.3 `2018_DAFx2018_paper_12` — *A Combined Model for a Bucket Brigade Device and Its Input and Output Filters (Roland Juno-60 & Dimension-D Chorus)*
- **Authors:** Martin Holters, Julian D. Parker (DAFx-2018)
- **Path:** `DAFx-proceedings/papers/DAFx-2018/2018_DAFx2018_paper_12/paper.md`
- **Relevant Sections:**
  - **Section 1 & 2 (pp. 1–2):** *Working Principle of BBDs in the Roland Juno-60 and Dimension-D* — Explains how complementary anti-phase clocks $\text{CLK}_1, \text{CLK}_2$ transport $N/2$ active charge packets while convolving the output with a zero-order-hold rectangular pulse of width $1/f_{\text{BBD}}$, producing the frequency-dependent $\text{sinc}(f / f_{\text{BBD}})$ aperture rolloff (Eq. 1 & 34).
  - **Section 3 & 4 (pp. 2–6):** *Juno-60 Chorus Input/Output Filter Poles & Aliasing Characteristics* — Provides the exact 5th-order input/output filter pole-residue specifications (Table 1, Fig. 6) and analyzes the dual push-pull stereo BBD topology of the Juno-60 Chorus Modes I, II, and I+II.

### 1.4 `2016_14-DAFx-16_paper_59-PN` — *Simulation of Analog Flanger Effect Using BBD Circuit*
- **Author:** Jaromír Mačák (DAFx-2016)
- **Path:** `DAFx-proceedings/papers/DAFx-2016/2016_14-DAFx-16_paper_59-PN/paper.md`
- **Relevant Sections:**
  - **Section 2.1 & 2.2 (pp. 1–2):** *LFO & Nonlinear RC Astable Clock Generator Circuit* — Derives the logarithmic capacitor charging law $T_{\text{clock}} = -2\tau \ln((U_{\text{Max}} - U_{\text{THD}}) / U_{\text{Max}})$ (Eq. 8–11, Fig. 2–3) that warps a filtered triangle LFO into the characteristic asymmetric BBD sweep of vintage Electro-Harmonix modulation circuits.

### 1.5 `2025_DAFx25_paper_29` — *Antialiasing in BBD Chips Using BLEP*
- **Authors:** Leonardo Gabrielli, Stefano D'Angelo, Stefano Squartini (DAFx-2025)
- **Path:** `DAFx-proceedings/papers/DAFx-2025/2025_DAFx25_paper_29/paper.md`
- **Relevant Sections:**
  - **Section 2.1, 3 & 4.3 (pp. 2–4):** *Distinguishing BBD-Generated Aliasing (BGA) from Simulation-Generated Aliasing (SGA) via PolyBLEP* — Shows how a discrete-time variable-clock BBD accumulator (`t += F_CLK / Fs`) produces authentic BBD sample-and-hold foldback images ($k F_{\text{CLK}} \pm f_0$), while applying a polynomial BLEP correction across each clock step removes harsh digital simulation aliasing by up to 36 dB.

---

## 2. Randomized, Multiscale & Psychoacoustically Mapped Chorus Architectures

### 2.1 `1998_FER09` — *Enhanced Quality and Variety for Chorus/Flange Units*
- **Authors:** P. Fernández-Cid, F. J. Casajús-Quirós (DAFx-1998)
- **Path:** `DAFx-proceedings/papers/DAFx-1998/1998_FER09/paper.md`
- **Relevant Sections:**
  - **Section 5 (pp. 3–4):** *Laws for Delay Modulation (Raised-Cosine Interpolated Narrowband Random LFO)* — Generates a click-free, infinitely differentiable narrowband random LFO at sub-audio rate $f_{sm}$ using raised-cosine (Hann) interpolation multiplied by a carrier cosine to blend smoothly from periodic sinusoidal chorusing to organic, non-repeating random ensemble drift.
  - **Section 6, 7 & 8 (pp. 4–5):** *Multiscale Filterbank Chorus with Per-Band Envelope-Driven Dry/Wet & Randomness* — Splits the input into dyadic octave subbands ("multiscale chorus") where each frequency scale has its own independent modulated delay line and per-band envelope follower that dynamically scales wet mix and modulation randomness (`fsm`), eliminating low-level noise pumping and turning metallic comb coloration into rich, non-tonal ensemble width.

### 2.2 `2006_p_149` — *Categories of Perception for Vibrato, Flange, and Stereo Chorus: Mapping out the Musically Useful Ranges of Modulation Rate and Depth*
- **Authors:** William L. Martens, Atsushi Marui (DAFx-2006)
- **Path:** `DAFx-proceedings/papers/DAFx-2006/2006_p_149/paper.md`
- **Relevant Sections:**
  - **Section 1 & 2.1 (pp. 1–2):** *Doppler Resampling Factor & ITD Stereo Chorus* — Derives the peak pitch-deviation ratio $\alpha(t) = 1 \mp 2\pi \cdot \text{DEPTH} \cdot \text{RATE}$ (Eq. 1–2) and demonstrates an Interaural Time Delay (ITD) stereo chorus where the unmodulated reference channel is delayed by $0.5\text{ ms}$ so the modulated channel continuously leads and lags the dry reference across the median plane.
  - **Section 3 (pp. 3–4):** *Constant Pitch-Excursion Hyperbola (Fig. 2)* — Proves via logistic regression that the musically useful chorus region follows a hyperbola where modulation depth is inversely proportional to modulation rate ($\text{Depth}_{\mu\text{s}} = \text{Slope} / \text{Rate}_{\text{Hz}} + \text{Intercept}$), enabling a **rate-compensated auto-depth chorus** that never goes seasick when speed is increased.

---

## 3. Electromechanical Scanner, Optical & Rotary Doppler Chorus Systems

### 3.1 `2016_38-DAFx-16_paper_54-PN` — *A Computational Model of the Hammond Organ Vibrato/Chorus using Wave Digital Filters*
- **Authors:** Kurt James Werner, W. Ross Dunkel, François G. Germain (DAFx-2016)
- **Path:** `DAFx-proceedings/papers/DAFx-2016/2016_38-DAFx-16_paper_54-PN/paper.md`
- **Relevant Sections:**
  - **Section 2.1, 2.2 & 3 (pp. 1–3):** *18-Stage Dispersive Ladder & 9-Tap Capacitive "There-and-Back-Again" Scanner* — Models the Hammond B-3 vibrato/chorus line box and the 6.12 Hz motorized 16-plate capacitive scanner that crossfades linearly (`v_out = eta*v_a + (1-eta)*v_b`, Fig. 3) from tap $t_1 \to t_9 \to t_1$ using the exact V1/C1, V2/C2, and V3/C3 nonlinear tap tables (Table 2), mixed with the dry signal in Chorus modes (C1–C3).

### 3.2 `2019_DAFx2019_paper_31` — *Digital Grey Box Model of the Uni-Vibe Effects Pedal*
- **Authors:** Champ Darabundit, Russell Wedelich, Pete Bischoff (DAFx-2019)
- **Path:** `DAFx-proceedings/papers/DAFx-2019/2019_DAFx2019_paper_31/paper.md`
- **Relevant Sections:**
  - **Section 3.1, 3.2 & 4.2 (pp. 3–6):** *Imbalanced Emitter/Collector Phase-Splitter Stages with Blocking Capacitor $C_{\text{DC}}$ & Asymmetric CdS LDR Curves* — Derives the exact non-ideal Uni-Vibe phase stage $H_n(z) = H_{cn}(z) + H_{en}(z)$ (Eq. 4–21, Table 1) with staggered capacitors ($0.015\mu\text{F}, 0.22\mu\text{F}, 470\text{pF}, 0.0047\mu\text{F}$), collector/emitter gain imbalance ($\alpha_n \neq \beta_n$), DC-blocking high-shelf throb, asymmetric emitter-follower $\tanh$ bias (Fig. 7), and fast-attack/slow-decay incandescent lamp-LDR trajectories (Fig. 8).

### 3.3 `2002_DAFX02_Smith_Serafin_Abel_Berners_doppler_leslie`, `2011_49_e`, & `1999_disch` — *Rotary Leslie Dual-Horn Doppler & Spectral-Delay Chorus*
- **Authors:** Julius O. Smith et al. (DAFx-2002); Jussi Pekonen et al. (DAFx-2011 Paper 49); Sascha Disch & Udo Zölzer (DAFx-1999)
- **Paths:**
  - `DAFx-proceedings/papers/DAFx-2002/2002_DAFX02_Smith_Serafin_Abel_Berners_doppler_leslie/paper.md`
  - `DAFx-proceedings/papers/DAFx-2011/2011_49_e/paper.md`
  - `DAFx-proceedings/papers/DAFx-1999/1999_disch/paper.md`
- **Relevant Sections:**
  - **DAFx-02 Sec. 3.2 & 4.1 (Eq. 10–20) & DAFx-99 Sec. 4 (Fig. 8–9):** Dual $180^\circ$ opposite-horn Doppler delay lines with synchronous directional AM and cabinet reflection cross-mixing.
  - **DAFx-11 Paper 49 Sec. 3.1 & 3.2 (Eq. 1–5, Fig. 2, Table 1):** Crossover at $800\text{ Hz}$ feeding independent Treble ($N=4, M_b=-0.75, M_s=0.20$) and Bass ($N=3, M_b=-0.92, M_s=0.04$) time-varying Spectral Delay Filter (SDF) chains with decoupled motor inertia (Chorale $\approx 0.8\text{ Hz}$ vs. Tremolo $\approx 6.0\text{ Hz}$ and $0.1\text{ Hz}$ motor mistuning).

---

## 4. Unison Waveform Animation ("Supersaw"), AM/FM ChorIFer & Psychoacoustic Dissonance Chorus

### 4.1 `2014_dafx14_joseph_timoney_examining_the_oscillator` — *Examining the Oscillator Waveform Animation Effect*
- **Authors:** Joseph Timoney, Victor Lazzarini, Jari Kleimola, Vesa Välimäki (DAFx-2014)
- **Path:** `DAFx-proceedings/papers/DAFx-2014/2014_dafx14_joseph_timoney_examining_the_oscillator/paper.md`
- **Relevant Sections:**
  - **Section 3 & 4 (pp. 2–5):** *Hutchins Comparator/PWM Phase-Shifted Waveform Animator* — Proves that subtracting a slow triangle LFO from a waveform and subtracting the resulting leading-edge comparator PWM wave creates a time-varying phase-shifted copy whose FM modulation index grows linearly with harmonic number $k I_1$ (Eq. 17–23), peaking at duty-cycle width $0.70$ ($d \in [0.15, 0.85]$, Fig. 5).
  - **Section 5 (p. 5):** *7-Voice Delay-Line Pitch-Shifter Supersaw Animator (Eq. 24–27, Fig. 6–7)* — Implements a 7-voice Risset/Supersaw unison ensemble on arbitrary live audio inputs using 4 dual-windowed raised-cosine crossfaded ramp delay lines at transposition ratios $s, s^3, 1/s, 1/s^3$ where $s = 1 + \delta f_0 / f_0$.

### 4.2 `2015_DAFx-15_submission_30` & `1999_disch` — *AM/FM Analytic "ChorIFer" & SSB Non-Harmonic Vibrato/Chorus*
- **Authors:** Antonio José Homsi Goulart, Victor Lazzarini, Joseph Timoney (DAFx-2015 Paper 30); Sascha Disch & Udo Zölzer (DAFx-1999)
- **Paths:**
  - `DAFx-proceedings/papers/DAFx-2015/2015_DAFx-15_submission_30/paper.md`
  - `DAFx-proceedings/papers/DAFx-1999/1999_disch/paper.md`
- **Relevant Sections:**
  - **DAFx-15 Paper 30 Sec. 2 & 3.4 (pp. 2–5, Listing 1–2, Fig. 6):** *The ChorIFer* — Decomposes the input via a Hilbert transform into Instantaneous Amplitude $a(t)$ and Instantaneous Frequency $f(t)$, synthesizes multiple detuned/FM-modulated phase integrals $\theta_k(t) = \int 2\pi r_k(t) f(\tau) d\tau$, and recombines them under the exact un-smeared transient envelope $a(t)$!

### 4.3 `2008_dafx08_30` — *Real-Time Dissonancizers: Two Dissonance-Augmenting Audio Effects*
- **Authors:** Matthew Hoffman, Perry Cook (DAFx-2008 Paper 30)
- **Path:** `DAFx-proceedings/papers/DAFx-2008/2008_dafx08_30/paper.md`
- **Relevant Sections:**
  - **Section 2, 2.1 & 4 (pp. 1–4, Eq. 1–2, Fig. 1–3):** *Kameoka-Kuriyagawa Critical-Band Roughness Chorus & Subband Noise-Modulated Dissonance Reduction* — Uses the psychoacoustic roughness curve $g(f_1) = 2.27 f_1^{0.477}$ (Eq. 1) across a subband filterbank to split partials by either a smooth chorusing fraction of $g(f_1)$ or the exact maximum-roughness beat frequency $m_i = 0.5 g(f_i)$.

---

## 5. Perceptual Stereo Decorrelation & Spatial Ensemble Thickening

### 5.1 `2017_DAFx17_paper_96` — *Velvet-Noise Decorrelator*
- **Authors:** Benoit Alary, Archontis Politis, Vesa Välimäki (DAFx-2017 Paper 96)
- **Path:** `DAFx-proceedings/papers/DAFx-2017/2017_DAFx17_paper_96/paper.md`
- **Relevant Sections:**
  - **Section 2 & 3.1–3.3 (pp. 2–3, Eq. 1–12, Fig. 1–4):** *Logarithmically-Spaced Segmented Velvet-Noise Decorrelation* — Uses sparse $\{-1, 0, +1\}$ velvet-noise tap sequences concentrated at the start of a $<30\text{ ms}$ delay buffer with a 4-segment decay envelope (Eq. 10–12) and subtle tap-location modulation to turn a mono tuba into a wide, zero-comb-coloration stereo ensemble without smearing tongue transients.

### 5.2 `2016_32-DAFx-16_paper_30-PN` & `2025_DAFx25_paper_80` — *Perceptually Informed ERB Allpass & Resonator-Bank Stereo Decorrelator*
- **Authors:** Elliot Kermit-Canfield & Jonathan Abel (DAFx-2016 Paper 30); Jon Fagerström et al. (DAFx-2025 Paper 80)
- **Paths:**
  - `DAFx-proceedings/papers/DAFx-2016/2016_32-DAFx-16_paper_30-PN/paper.md`
  - `DAFx-proceedings/papers/DAFx-2025/2025_DAFx25_paper_80/paper.md`
- **Relevant Sections:**
  - **DAFx-16 Sec. 3.1–3.3 (Eq. 1–6) & DAFx-25 Sec. 3 & 4 (Table 1, Eq. 9–14):** Combines ERB-spaced biquad allpass sections with prime-number delay lengths $z^{-n}$ and ERB-tuned group-delay profiles (peaking at $13\text{--}19\text{ ms}$ in the $100\text{--}800\text{ Hz}$ tuba fundamental/warmth band and tapering to $4\text{ ms}$ above $6\text{ kHz}$, DAFx-25 Table 1) to create a flat-magnitude, zero-comb-filtering spatial chorus.
