# DAFx Proceedings: Compressors, Limiters, and Character Dynamics Processors — Literature & Section Index

This document indexes the relevant papers and exact sections from the `DAFx-proceedings` corpus covering **dynamic range compressors, peak limiters, variable-$\mu$ vacuum-tube limiters, opto-cell leveling amplifiers, VCA bus compressors, relative-level microdynamics processors, and allpass phase-dispersive / coefficient-bounded limiters**, focusing on designs that act as **musical effects-in-themselves** (pumping, snap, harmonic saturation, upward inflation, transient sculpting, and phase-dispersed peak limiting) rather than mere utility gain stages.

---

## 1. Variable-$\mu$ Vacuum-Tube Feedback Limiters & Gain-Reduction-Dependent Harmonic Saturation

### 1.1 `2012_dafx12_submission_9` (DAFx-2012)
- **Title**: *Toward a Wave Digital Filter Model of the Fairchild 670 Limiter*
- **Author**: Peter Raffensperger
- **Relevant Sections**:
  - **Section 1 (Introduction, p. 1, Fig. 1)**: Feedback limiting architecture where the sidechain amplifier monitors the output voltage to drive the control grid of the variable-$\mu$ signal amplifier; Left-Right vs. Lateral-Vertical (Mid-Side) matrixing.
  - **Section 2 (6386 Remote Cutoff Triode Model, p. 2, Eq. 1, Fig. 2, Table 1)**: Remote-cutoff transfer characteristic where AC amplification $\mu$ varies continuously with DC grid-cathode bias $V_{gk}$:
    $$I_a = \frac{p_1 V_{ak}^{p_2}}{\left(p_3 - p_4 V_{gk}\right)^{p_5} \left[p_6 + \exp(p_7 V_{ak} - p_8 V_{gk})\right]}$$
  - **Section 5 (Sidechain Amplifier & Time-Constant Network, pp. 4–6, Eqs. 10–14, Figs. 7–10, Table 3)**:
    - **AC & DC Threshold Interaction (Eq. 10)**: Class-B sidechain stage with intentional crossover bias controlled by $\phi_{DC}$ and input drive $\phi_{AC}$:
      $$V_{\text{stage1}}(t) = \ln\left[\frac{1 + \exp(V_{\text{pot}}(t) - \phi'_{DC})}{1 + \exp(-V_{\text{pot}}(t) - \phi'_{DC})}\right]$$
      Together, $\phi_{AC}$ and $\phi_{DC}$ simultaneously sculpt the threshold, knee curvature, and effective ratio.
    - **Multi-Capacitor Program-Dependent Release Network (Fig. 8, Table 3)**: Parallel RC + dual series-RC branches ($C_T, R_T$ fast branch coupled to $C_U, R_U$ and $C_V, R_V$ slow memory capacitors). Brief peaks discharge rapidly through $R_T C_T$, whereas sustained limiting charges $C_U$ and $C_V$, lengthening release time dynamically according to program history.
  - **Section 6 (Results — Gain-Reduction-Dependent Odd Harmonic Distortion, pp. 6–8, Figs. 12–13)**: Balanced push-pull triode topology cancels even harmonics while generating rich 3rd-harmonic warmth that **increases proportionally with gain reduction** (rising from $-21\text{ dB}$ at light limiting to $-14\text{ dB}$ under heavy limiting), increasing perceived loudness and density during heavy compression.

---

## 2. Optical Leveling Amplifiers (LA-2A / Tube-Tech CL 1B) & Photocell Memory Ballistics

### 2.1 `2022_DAFx20in22_paper_35` (DAFx-2022)
- **Title**: *Grey-Box Modelling of Dynamic Range Compression*
- **Authors**: Alec Wright and Vesa Välimäki
- **Relevant Sections**:
  - **Section 2.1 (Static Gain Computers, pp. 1–2, Eqs. 1–2, Fig. 1)**: Quadratic soft-knee compression law in decibels:
    $$y_{gc} = \begin{cases} x_{gc}, & 2(x_{gc}-T) < -W \\ x_{gc} + \frac{(1/R - 1)(x_{gc} - T + W/2)^2}{2W}, & 2|x_{gc}-T| \le W \\ T + \frac{x_{gc}-T}{R}, & 2(x_{gc}-T) > W \end{cases}$$
  - **Section 3.2 (Time-Varying Level Detector & Nonlinear Ballistics, p. 3, Eqs. 6, 9)**: Signal-dependent time-constant modulation where effective attack and release rates adapt continuously to the instantaneous gain-reduction state and input envelope history.
  - **Section 3.3 (Nonlinear Make-Up Amplifier Stage, pp. 3–4)**: Post-attenuation vacuum-tube make-up stage adding asymmetric harmonic saturation and high-frequency rolloff after gain reduction.

### 2.2 `2023_DAFx23_paper_10` (DAFx-2023) & `2024_DAFx24_paper_75` (DAFx-2024)
- **Titles**:
  - *Fully Conditioned and Low-Latency Black-Box Modeling of Analog Compression* (Simionato & Fasciani, DAFx-2023)
  - *Differentiable All-Pole Filters for Time-Varying Audio Systems* (Yu, Mitcheltree, Carson, Bilbao, Reiss & Fazekas, DAFx-2024)
- **Relevant Sections**:
  - **`2023_DAFx23_paper_10` Section 2.1 & 2.3 (CL 1B & Teletronix LA-2A T4B Electro-Optical Attenuator, pp. 2–3)**: Electro-luminescent panel + CdS photocell dynamics exhibiting program-dependent attack ($\sim 10\text{ ms}$) and a **two-stage release** ($60\text{ ms}$ initial fast release followed by a $0.5\text{–}5.0\text{ s}$ slow photoconductive cell memory tail whose weight depends on integrated illumination exposure).
  - **`2024_DAFx24_paper_75` Section 4.3 (Modelling the LA-2A Leveling Amplifier, p. 7)**: Time-varying all-pole ballistic filtering capturing electro-optical hysteresis and frequency-dependent sidechain emphasis.

---

## 3. Lookahead Order-Statistic (Running-Max) & Moving-Average Peak Limiters

### 3.1 `2002_DAFX02_Hamalainen_smoothing_peak_limiters` (DAFx-2002)
- **Title**: *Smoothing of the Control Signal without Clipped Output in Digital Peak Limiters*
- **Author**: Perttu Hämäläinen
- **Relevant Sections**:
  - **Section 2 (Basic Limiter Operation, pp. 1–2, Eqs. 1–3, Figs. 1–2)**: Instantaneous peak limiting law $g(n) = \min\left(1, (\text{threshold}/e(n))^{1-r}\right)$ and why simple IIR envelope smoothing causes transient overshoots.
  - **Section 3.1 (Feedforward Lookahead Delay $z^{-N}$, p. 2, Eq. 5, Fig. 3)**: Delaying the audio path by $N$ samples ($y(n) = x(n-N)g(n)$) so gain reduction anticipates peaks, and why a delay alone still clips on pulses shorter than $N$ samples.
  - **Section 3.2 (Clipping Control & Running Max Filter, pp. 2–3, Eqs. 6–16, Fig. 4)**:
    - Pre-compensating the sidechain target via clipping control $c(n)$ so a 1-pole detector reaches $|x(n)|$ within $N$ lookahead samples:
      $$c(n) = \max\left(|x(n)|,\ \frac{|x(n)| - \beta e_{\max}(n-1)}{1 - \beta}\right), \quad \beta = (1-a)^{N+1}$$
    - Order-statistic running-maximum filter over the $N$-sample window:
      $$x_{\max}(n) = \max[c(n-N), \dots, c(n)]$$
      which drapes a smooth "cloth" envelope over signal peaks without ever permitting output clipping.
  - **Section 3.3 & 3.4 (Recursive Boxcar Averaging Filter, pp. 3–4, Eqs. 17–21, Fig. 7)**: Cascading an $M$-sample recursive moving-average filter $e_{\text{ave}}(n) = e_{\text{ave}}(n-1) + \frac{1}{M}[e_{\max}(n) - e_{\max}(n-M)]$ after the running-max detector to yield $C^1$-smooth gain trajectories with zero intermodulation clicks even under extreme brickwall squash.

---

## 4. Direct Microdynamics (LDR Relative-Level) Compressors, Upward Inflators & Transient Expanders

### 4.1 `2022_DAFx20in22_paper_21` (DAFx-2022)
- **Title**: *A Direct Microdynamics Adjusting Processor with Matching Paradigm and Differentiable Implementation*
- **Authors**: Shahan Nercessian, Russell McClellan, and Alexey Lukin (iZotope)
- **Relevant Sections**:
  - **Section 2.1 (Loudness Dynamic Range / Relative Level Metric, p. 2, Eqs. 1–3, Fig. 1)**: Defining microdynamics as the ratio between a fast short-term envelope $a_{\text{short}}[n]$ and a slow macrodynamic envelope $a_{\text{long}}[n]$:
    $$L[n] = \frac{a_{\text{short}}[n]}{a_{\text{long}}[n]}$$
    Because $L[n]$ is normalized by the slow envelope, it is **invariant to overall input level and song-section macrodynamics** (verse vs. chorus) and has **no threshold dead-zone**.
  - **Section 3 (Proposed Direct Microdynamics Processor, pp. 3–4, Eqs. 7–12, Figs. 2–3)**:
    - Asymmetric ballistic short-term detector $a_{\text{short}}[n]$ ($\tau_\uparrow$ attack, $\tau_\downarrow$ release) divided by long-term tracker $a_{\text{long}}[n]$ with $\tau_{\text{long}} = s \cdot \max(\tau_\uparrow, \tau_\downarrow)$.
    - Direct decibel-scale scaling of relative level $\log L'[n] = m \log L[n]$, yielding the closed-form sample-by-sample gain law:
      $$g[n] = \left(L[n]\right)^{(m-1)/p}$$
    - When $0 \le m < 1$, transients are compressed toward the local sustain floor and quiet sustain is pulled upward (**threshold-free microdynamic sustainer / upward inflator**); when $m > 1$, microdynamics are exaggerated (**level-independent punch / transient expander**).
    - **Multiband Extension (p. 4)**: Independent relative-level detectors $L_k[n]$ per crossover band $k$, enabling per-band upward sustain or transient snap without cross-band pumping.

---

## 5. SSL G-Series Bus VCA Compressor & Spectral-Flux Auto-Ballistic Compressors

### 5.1 `2026_DAFx26_paper_30` (DAFx-2026)
- **Title**: *Evaluating Dynamic Range Compressor Models Using Control-Voltage Measurements: An Approach and Dataset*
- **Authors**: Benjamin R. Thompson and Michael C. Heilemann
- **Relevant Sections**:
  - **Section 3 & Section 4.1 (SSL Logic FX G384 / 4000 G-Bus Compressor Architecture, pp. 4–5)**: Peak-sensing stereo-linked sidechain VCA (DBX 2151) driving matched audio-path VCAs (THAT 202), ratio-dependent knee curvature, and the signature **two-pole dual-RC `AUTO` release filter** that blends a fast transient recovery pole with a slow program-averaged recovery pole for "glue" bus pumping.

### 5.2 `2012_dafx12_submission_6` (DAFx-2012) & `2014_dafx14_marcel_hilsamer_a_statistical_approach_to` (DAFx-2014)
- **Titles**:
  - *An Autonomous Method for Multi-Track Dynamic Range Compression* (Maddams, Finn & Reiss, DAFx-2012)
  - *A Statistical Approach to Automated Offline Dynamic Processing in the Audio Mastering Process* (Hilsamer & Herzog, DAFx-2014)
- **Relevant Sections**:
  - **`2012_dafx12_submission_6` Section 4.2 (Compressor Automation & Crest/Flux Auto-Ballistics, pp. 2–3, Fig. 2)**:
    - **"Threshold" Mode (Variable-Knee Limiter, Sec. 4.2.1, Fig. 2A)**: Ratio fixed at $\infty:1$ with knee width dynamically equal to $|T|$, producing an ever-wider hyperbolic/soft-knee saturation curve as compression deepens.
    - **Crest-Factor / Spectral-Flux Driven Ballistics (Sec. 4.2)**: Automatically shortening attack and release times during high-crest / high-flux transient events to prevent pumping and "breathing" drop-outs.
  - **`2014_dafx14` Section 2 & 3 (Windowed RMS Moment Shaping & Auto $\tau_a, \tau_r$, pp. 1–4, Fig. 1)**: Controlling dynamic range distribution moments (variance and skewness of log-level) via coupled RMS ballistics and lookahead peak limiting.

---

## 6. All-Pass Phase-Dispersive Peak Reduction & Time-Varying Coefficient Anti-Clipping Limiters

### 6.1 `2026_DAFx26_paper_45` (DAFx-2026)
- **Title**: *A Clipping Prevention Method for All-Pass Digital Filters with Time-Varying Coefficients*
- **Authors**: Federico Fontana, Alberto Bernardini, Silvia Pasin, and Stefano D'Angelo
- **Relevant Sections**:
  - **Section 1 (All-Pass Phase Dispersion for Peak Attenuation, p. 1)**: Using dispersive all-pass filters to redistribute local phase around high-crest transients, smearing peak energy in time and achieving up to $5\text{ dB}$ of crest-factor reduction before any gain attenuation is even applied.
  - **Section 2 (First- and Second-Order Time-Varying All-Pass Clipping Prevention, pp. 2–3, Eqs. 1–15, Algorithms 1–2)**:
    - Exact algebraic bounding of the coefficient increment $\Delta c(n) = c(n) - c(n-1)$ relative to the static all-pass output $w[n] = c(n-1)(x[n]-y[n-1]) + x[n-1]$ so that $|y[n]| = |w[n] + \Delta c(n)(x[n]-y[n-1])| \le M$ is strictly guaranteed at every sample:
      $$\frac{-M - w[n]}{x[n] - y[n-1]} \le \Delta c(n) \le \frac{M - w[n]}{x[n] - y[n-1]}$$
    - Second-order extension (Eqs. 8–15, Algorithm 2) splitting the clipping prevention budget across $\Delta c_0(n)$ and $\Delta c_1(n)$, creating a **self-slewing dynamic all-pass limiter** thatdisperses transient peaks while algebraically guaranteeing $|y[n]| \le M$.
