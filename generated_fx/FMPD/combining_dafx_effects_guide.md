# Combining DAFx Phase-Distortion, Angle-Modulation, Quadrature & Comb Effects: A Unix-Style Patchbay & Routing Guide for Live Dubstep/Riddim Tuba

## 1. Architectural Philosophy: Composable Signal Primitives

Every effect generated in this collection is designed as a **self-contained, stereo Unix audio primitive** with **6 to 7 musical parameters** and a unified **4-inlet / 2-to-4-outlet signal convention**:

| Inlet / Outlet | Standard Role Across Effects |
| :--- | :--- |
| **`in1` / `in2`** | **Left / Right Audio Input** (auto-normalizes mono `in1` to stereo if `in2` is unpatched). |
| **`in3`** | **Pitch / Envelope Bus**: Accepts tracked fundamental frequency $f_0$ in Hz from `tuba_freq_tracker` (`00_tuba_freq_tracker.txt`, `out1`) **or** modulation envelope `[0..1]` from `tuba_transient_valve_detector` (`00b_tuba_transient_valve_detector.txt`, `out2`), with an internal zero-crossing pitch tracker fallback whenever `in3 <= 0`. |
| **`in4`** | **Time / Sidechain Bus**: Accepts a tempo-locked 1-bar `[0..1]` phasor (`phasor~` locked to Max transport), a transient gate (`out3` of `00b_tuba_transient_valve_detector`), or an external audio-rate modulator/sidechain signal. |
| **`out1` / `out2`** | **Left / Right Stereo Audio Output** (with true quadrature $90^\circ$ or counter-phase stereo imaging). |
| **`out3` / `out4`** | *(On `even_odd_harmonic_comb_splitter`)* **Isolated Odd Harmonics Stem (`out3`)** and **Isolated Even Harmonics Stem (`out4`)** for multi-branch Unix routing. |

Because these modules do not bundle redundant multi-FX chains (no kitchen-sink chorus+delay+reverb blocks inside a single file), **the complexity of the sound emerges from how you wire them together**—in series cascades, parallel harmonic splits, cross-coupled quadrature feedback loops, and audio-rate sidechain trees.

---

## 2. Inventory of the 19 Generated Stereo Effects & Their Core Operations

### A. Phase Distortion (PD) & Closed-Loop Phase Geometry
1. **`heterodyne_pd_shaper.txt`** *(DAFx-09 P12, Lazzarini et al.)* — Extracts analytic phase via a 4-stage Hilbert transform and applies Casio CZ-style dual-slope inflection (`inflection_d`), self-oscillating resonance sync (`res_harmonic`), or quantized sawtooth steps (`quant_steps`).
2. **`vector_phaseshaper_lissajous.txt`** *(DAFx-11 P55, Kleimola et al.)* — 2D Vector Phaseshaping $\Phi(x; d, v)$ where horizontal break-point $d$ controls odd/even harmonic symmetry and vertical inflection $v$ synthesizes multi-loop vocal formants, with Lissajous X/Y stereo phase coupling.
3. **`wave_pulse_phase_modulator.txt`** *(DAFx-10 P65 Sec. 2.2, Timoney et al.)* — Adds a pitch-tracked bipolar triangular pulse ($m_1$) and unipolar plateau ($m_2$) directly inside the phase argument before cosine evaluation.
4. **`deformed_circle_map_fbfm.txt`** *(DAFx-22 P23, Essl)* — Iterative Sine Circle Map ($x_n = x_{n-1} + \Omega + \frac{k}{2\pi}\sin(2\pi x_{n-1}) \bmod 1$) coupled to the tuba's analytic phase, projected onto a 2D closed loop morphing from a Circle $\to$ 4-Point Diamond $\to$ Concave L-Loop.

### B. Angle Modulation, Coefficient Modulation, ModFM & Loopback FM
5. **`cm_allpass_chain_synth.txt`** *(DAFx-09 P36, Pekonen et al.)* — Cascade of 8 first-order dispersive allpass filters whose coefficient $g(n)$ is modulated at audio rate by the tuba's harmonic isolator or internal pitch-tracked oscillator, with recursive coefficient feedback.
6. **`loopback_fm_tvdl.txt`** *(DAFx-18 P28, Hsu & Smyth)* — Realizes the exact discrete-time equivalence between Loopback FM ($z_0(n)$) and a Time-Varying Delay Line ($\text{TVDL}[x_c](n)$) applied directly to the live tuba waveform.
7. **`retuned_exp_fm_ltz.txt`** *(DAFx-25 P48, Lazzarini)* — Exponential FM (`f0 * exp(beta * mod)`) with exact analytical Bessel $I_0(\beta)$ pitch drift cancellation (`f0 / I0(beta)`) and Laurent-series zero-order-hold (LTZ) continuous spectral tilt (`ltz_pole_g`).
8. **`modfm_pulse_saw_formant.txt`** *(DAFx-08 P05, Timoney et al.)* — Modified FM (`exp(k*(cos(w0*t)-1))`) bandlimited pulse train, leaky-integrated ModFM sawtooth, and phase-locked formant generator with monotonic Modified Bessel $I_n(k)$ roll-off.
9. **`fbam_delay_comb_operator.txt`** *(DAFx-09 P31, Lazzarini et al.)* — Variable-Delay Feedback AM (`y(n) = x(n) * [1 + beta * LP(y(n-D))]`) morphing across Variations V (Linear Comb FBAM), IV (Cosine Waveshaped FBAM), and III (Heterodyne FBAM).

### C. Quadrature / Hilbert / Heterodyne & Modal Processors
10. **`amfm_hilbert_transcolorifer.txt`** *(DAFx-09 P66, Marchand & Raspaud)* — Separates the tuba into its positive Hilbert envelope $a(t)$ and normalized cosine carrier $\cos(\phi(t))$, multiplies the instantaneous frequency by $K$ via exact Chebyshev recursion, and applies stereo SSB frequency shifting.
11. **`quadrature_chebyshev_shaper.txt`** *(DAFx-10 P65 Sec. 2.1, Timoney et al.)* — Combines Chebyshev polynomials of the 1st kind $T_k(x_I)$ and 2nd kind $x_Q U_{k-1}(x_I)$ on the Hilbert quadrature pair to independently control both harmonic amplitudes and continuous harmonic phase rotation $\phi_k$.
12. **`heterodyne_fof_resonator.txt`** *(DAFx-26 P36,campeanu et al.)* — Dual-formant heterodyne vocal resonator (`F1`, `F2`) that shifts the tuba down by each formant frequency, smooths with the exact 3-pole FOFskirt envelope, and shifts back up.
13. **`modal_heterodyne_inverter_dist.txt`** *(DAFx-15 P72, Abel & Werner)* — 4-mode heterodyne-smooth-modulate processor that isolates harmonics $1..4$, optionally flips the harmonic spectrum upside down (`spectral_invert`), and distorts each mode individually without intermodulation.

### D. Phase Dispersion, Nonlinear Allpass, Physical Wave Steepening & Comb Filtering
14. **`spectral_delay_chirp_filter.txt`** *(DAFx-11 P38, Välimäki et al.)* — 24-stage Thiran-warped dispersive allpass chain turning every tongued tuba note into a sweeping laser chirp, plus comb feedback for inharmonic bell/gong resonances.
15. **`nonlinear_ladder_allpass.txt`** *(DAFx-20 P61, Parker et al.)* — 16-stage state-saturated allpass ladder ($y_k = \tanh(g \cdot x_k + x_{k-1} - g \cdot y_{k-1})$) where loud attacks self-modulate their own group delay trajectory.
16. **`brassifier_shock_propagator.txt`** *(DAFx-10 P77, Cooper & Abel)* — Simulates supersonic nonlinear wave steepening inside a 0.5–12 m brass bore where high-pressure peaks travel faster than troughs, turning soft notes into sawtooth shock fronts.
17. **`barberpole_comb_ssb_flanger.txt`** *(DAFx-15 P67, Esqueda et al.)* — Endless upward or downward comb notch sweeping via either a synchronized dual-sawtooth flanger or an allpass-warped Hilbert SSB phaser.
18. **`even_odd_harmonic_comb_splitter.txt`** *(DAFx-21 P02)* — Unity-gain normalized Universal Comb Filter tuned to $2 f_0$ (`M = fs / (2*f0)`) that splits the tuba into isolated **Odd Harmonics (`out3`)** and **Even Harmonics (`out4`)** while outputting a differentially distorted stereo mix on `out1/out2`.
19. **`buchla259_parallel_wavefolder.txt`** *(DAFx-17 P82, Esqueda et al.)* — ADAA1-antialiased 5-branch parallel op-amp deadband wavefolder (`V1..V5`) with active output integrator filter.

---

## 3. Topology I: Serial Cascades (Order-Dependent Non-Commutative Chains)

Because phase distortion, dispersive allpass filtering, and nonlinear wavefolding are **non-commutative** ($A(B(x)) \neq B(A(x))$), swapping the order of just two modules completely changes the physical behavior of the patch.

### 3.1 Dispersion *Before* vs. *After* Nonlinear Wavefolding (`spectral_delay_chirp_filter` $\leftrightarrow$ `buchla259_parallel_wavefolder`)

* **Orientation A — Pre-Dispersion into Wavefolder (`Chirp` $\to$ `Buchla 259`):**
  ```text
  [Tuba] -> [spectral_delay_chirp_filter] -> [buchla259_parallel_wavefolder] -> [Out]
  ```
  * **Acoustic Behavior:** `spectral_delay_chirp_filter` smears the tuba's harmonic phases in time so high frequencies arrive either before or after the fundamental, reducing the peak crest factor of the attack transient. When this time-smeared chirp enters `buchla259_parallel_wavefolder`, different frequencies cross the five Buchla voltage thresholds ($\pm 0.60\text{ V}, \pm 1.80\text{ V}, \pm 2.99\text{ V}, \pm 4.08\text{ V}, \pm 5.46\text{ V}$) at different instants in time! The result is a **time-swept intermodulation growl** where the wavefolder sweeps from high-frequency fizz down into heavy sub-bass folding over 10–30 ms on every tongue attack.

* **Orientation B — Wavefolder into Post-Dispersion (`Buchla 259` $\to$ `Chirp`):**
  ```text
  [Tuba] -> [buchla259_parallel_wavefolder] -> [spectral_delay_chirp_filter] -> [Out]
  ```
  * **Acoustic Behavior:** `buchla259_parallel_wavefolder` first folds the raw, phase-aligned tuba waveform across all five parallel op-amp cells simultaneously, generating a dense, instantaneous wall of upper harmonics up to 16 kHz. Passing that folded spectrum into `spectral_delay_chirp_filter` (with `chirp_feedback = 0.65`) disperses the newly created upper folds into a **metallic laser-zap transient ("pew" attack)** typical of modern tearout and psy-dubstep bass design.

### 3.2 Acoustic Shock Steepening into Loopback FM (`brassifier_shock_propagator` $\to$ `loopback_fm_tvdl` $\to$ `heterodyne_fof_resonator`)

```text
[Tuba] ---> [brassifier_shock_propagator] ---> [loopback_fm_tvdl] ---> [heterodyne_fof_resonator] ---> [Out]
               ^ (in3: f0 Hz)                     ^ (in3: f0 Hz)          ^ (in3: f0 Hz, in4: 1-Bar)
```
* **Why This Order Works:**
  1. Even when playing *pianissimo* on the tuba (where a real brass bore stays linear and sinusoidal), `brassifier_shock_propagator` advances positive pressure peaks ahead of troughs to synthesize a steep acoustic shock edge (`cuivré` sawtooth).
  2. `loopback_fm_tvdl` then subjects that shock-steepened waveform to a second, pitch-locked Time-Varying Delay Line ($\text{TVDL}[x_c]$) with recursive feedback $B_0$, bending the sawtooth ramp into an exponential feedback-FM metallic snarl.
  3. Finally, `heterodyne_fof_resonator` carves dual moving vocal formants (`F1` and `F2` morphing from `/a/` to `/i/`) out of the dense harmonic spectrum without any resonant SVF self-oscillation whistle.

### 3.3 Fundamental Isolation into Analytic Phase Distortion (`harmonic_isolator` $\to$ `vector_phaseshaper_lissajous` $\to$ `quadrature_chebyshev_shaper`)

```text
[Tuba] -> [01_harmonic_isolator (harm=1)] -> [vector_phaseshaper_lissajous] -> [quadrature_chebyshev_shaper] -> [Out]
```
* **Why This Order Works:**
  * Analytic phase-shapers (`vector_phaseshaper_lissajous` and `heterodyne_pd_shaper`) extract instantaneous phase via $\text{atan2}(\hat{x}, x)$. Feeding them a near-pure fundamental from `01_harmonic_isolator` ensures a monotonically advancing $0 \to 1$ phase ramp with zero harmonic ripple.
  * `vector_phaseshaper_lissajous` warps that clean ramp into a multi-loop 2D formant trajectory ($v > 1.5$), and `quadrature_chebyshev_shaper` then adds 2nd- through 6th-order quadrature harmonics ($T_k, U_{k-1}$) with continuously spinning harmonic phases (`phase_spin = 0.5`).

---

## 4. Topology II: Parallel Harmonic-Split Trees Using `even_odd_harmonic_comb_splitter`

One of the most powerful findings in **DAFx-21 Paper 2** (*Separation of Harmonic Signals*) is that distorting a complex harmonic sound in a single nonlinear stage creates harsh intermodulation products between adjacent partials ($f_2 - f_1$, $f_3 + f_2$, etc.), whereas **separating the Odd and Even harmonics first and processing them in parallel branches eliminates inter-group intermodulation**.

Because `even_odd_harmonic_comb_splitter.txt` exposes the **isolated Odd Harmonics ($f_0, 3f_0, 5f_0 \dots$) on `out3`** and the **isolated Even Harmonics ($2f_0, 4f_0, 6f_0 \dots$) on `out4`**, you can build **2-Way and 3-Way Harmonic Split Trees**:

### 4.1 Dual-Branch Odd/Even Dubstep Growl Tree

```text
                                      +--> (out3: ODD f0, 3f0, 5f0) ---> [deformed_circle_map_fbfm] ----+
                                      |                                    (k=1.15 Arnold Sub-Chaos)    |
[Tuba] -> [even_odd_harmonic_comb_splitter]                                                             +--> [Stereo Bus]
             ^ (in3: f0 Hz)           |                                                                 |
                                      +--> (out4: EVEN 2f0, 4f0, 6f0) -> [cm_allpass_chain_synth] ------+
                                                                           (8-Stage Modulated Allpass)
```
* **Musical Result:**
  * **Odd Branch (`out3`):** Contains the fundamental $f_0$ and hollow clarinet-like odd partials ($3f_0, 5f_0$). Feeding `out3` into `deformed_circle_map_fbfm` with `circle_map_k = 1.15` and `loop_deformation = 0.8` locks the fundamental and odd harmonics into a heavy, subharmonic Concave-L-Loop chest growl.
  * **Even Branch (`out4`):** Contains the octave-doubled harmonics ($2f_0, 4f_0, 6f_0$) with zero fundamental energy. Feeding `out4` into `cm_allpass_chain_synth` (or `wave_pulse_phase_modulator`) creates screaming upper-octave phase-modulated vowel metallic textures that **never muddy or phase-cancel the fundamental in the Odd branch**!

### 4.2 Complementary Spectral-Inversion Parallel Blend (`modal_heterodyne_inverter_dist` + `retuned_exp_fm_ltz`)

```text
          +---> [retuned_exp_fm_ltz (beta=2.8, c_to_m=1.0, ltz_pole_g=-0.4)] ---> (Low/Mid Exp-FM Punch) ---+
          |                                                                                                 |
[Tuba] ---+                                                                                                 +--> [Mix]
          |                                                                                                 |
          +---> [modal_heterodyne_inverter_dist (spectral_invert=1.0, pitch_shift_semi=+12)] ---------------+
                  (Upside-down harmonic series shifted +1 octave in quadrature stereo)
```
* **Musical Result:**
  * `retuned_exp_fm_ltz` anchors the fundamental pitch without Exponential-FM upwards drift (thanks to `f0 / I0(beta)` compensation) and darkens the bass weight using negative Laurent-pole tilt (`ltz_pole_g = -0.4`).
  * In parallel, `modal_heterodyne_inverter_dist` with `spectral_invert = 1.0` flips the tuba's first four harmonics upside down ($1 \leftrightarrow 4$, $2 \leftrightarrow 3$). When you play a soft, dark fundamental note on the tuba, Mode 1 has the highest energy and gets remapped to the **4th harmonic**, while playing a loud, brassy note with strong upper partials pushes energy *down* into the inverted lower modes—creating a dynamic **counter-envelope harmonic seesaw** between the two parallel processors!

---

## 5. Topology III: Multiple Identical Units in Series & Polyrhythmic Orientations

In the Unix tradition, piping **two or three instances of the same tool together** with staggered parameters unlocks higher-order behaviors that a single instance cannot produce without parameter bloat:

### 5.1 Cascading Multiple `nonlinear_ladder_allpass` Units (16 $\to$ 32 $\to$ 48 Stages with Opposite Polarity)
* A single `nonlinear_ladder_allpass` provides 16 state-saturated allpass stages ($y_k = \tanh(g x_k + x_{k-1} - g y_{k-1})$).
* **Dual Opposite-Polarity Cascade:**
  * **Unit 1:** `base_pole_g = -0.65` (low-frequency dispersive chirp), `input_drive_db = 12 dB`, `ladder_feedback = 0.25`.
  * **Unit 2:** `base_pole_g = +0.60` (high-frequency dispersive chirp), `input_drive_db = 6 dB`, `ladder_feedback = 0.45`.
  * **Why It Works:** Because Unit 1 has negative pole coefficient $g < 0$ and Unit 2 has positive pole coefficient $g > 0$, their linear small-signal group delays partially cancel toward a flat allpass delay across the midband—**except during loud transients**, where the $\tanh(\cdot)$ state saturation inside Unit 1 and Unit 2 shifts their poles in opposite directions simultaneously, opening a massive **level-dependent phase-dispersion hole** only on fortissimo tuba blasts!

### 5.2 Dual `barberpole_comb_ssb_flanger` in Series (Shepard-Risset Comb Matrix)
* **Unit 1:** `sweep_rate_hz = +0.35`, `center_delay_ms = 3.5 ms`, `dual_to_ssb_mode = 0.0` (Upward-climbing time-domain dual-comb flanger).
* **Unit 2:** `sweep_rate_hz = -0.50`, `center_delay_ms = 1.4 ms`, `dual_to_ssb_mode = 1.0`, `notch_warp_a1 = -0.6` (Downward-diving allpass-warped SSB spectral-delay phaser).
* **Why It Works:** Piping an infinitely **rising** linear-spaced comb filter into an infinitely **falling** logarithmically-warped SSB phaser creates a cross-hatched **lattice of colliding spectral notches**—the classic "metallic riddim vowel box" where formants appear to simultaneously rise and fall inside the stereo field.

### 5.3 Cascading Two `modfm_pulse_saw_formant` Units as a Dual-Formant Vowel-Saw Synthesizer
* **Unit 1:** `formant_harmonic = 1.0`, `pulse_to_saw = 1.0`, `modfm_index_k = 18.0`, `tuba_carrier_mix = 0.0` (Synthesizes a phase-locked bandlimited ModFM Sawtooth wave at $f_0$).
* **Unit 2:** `formant_harmonic = 4.5`, `pulse_to_saw = 0.0`, `modfm_index_k = 8.0`, `tuba_carrier_mix = 1.0` (Uses Unit 1's ModFM sawtooth as the **live carrier input** `in1/in2` and windows it with a second ModFM exponential pulse envelope `exp(k*(cos(w0*t)-1))`!).
* **Why It Works:** Multiplying two ModFM exponential envelopes in series ($\exp(k_1(\cos\omega_0 t - 1)) \cdot \exp(k_2(\cos\omega_0 t - 1)) = \exp((k_1+k_2)(\cos\omega_0 t - 1))$) preserves exact Modified-Bessel bandlimiting while allowing the first stage's leaky integrator to build a sawtooth body and the second stage to carve a sharp, resonant formant window out of that sawtooth.

---

## 6. Topology IV: Audio-Rate Cross-Modulation & Sidechain Routing Using `in3` & `in4`

Several effects allow their **`in4` inlet** to accept an **audio-rate signal** from another module instead of a 1-bar LFO phasor:

### 6.1 `cm_allpass_chain_synth` Driven at Audio Rate by `even_odd_harmonic_comb_splitter`
```text
[Tuba] ---> [even_odd_harmonic_comb_splitter]
               |                        |
               | (out3: Odd Harmonics)  | (out4: Even Harmonics)
               v                        v
            (in1/in2: Audio Input)   (in4: Audio-Rate Allpass Coefficient Modulator!)
               \                        /
                v                      v
               [cm_allpass_chain_synth (mod_depth = 0.85, cascade_fb = 0.5)] ---> [Stereo Out]
```
* **How It Works:** In `cm_allpass_chain_synth`, whenever `in4` contains a bipolar audio signal (`in4 < -0.001`), it switches automatically from its internal cosine modulator to **external audio-rate allpass coefficient modulation**! Here, the tuba's **Odd Harmonics (`out3`)** pass through the 8-stage dispersive allpass chain while their allpass coefficients $g(n)$ are modulated at audio rate by the tuba's own **Even Harmonics (`out4`)**—creating self-consistent, pitch-locked octave sidebands across every partial.

### 6.2 `brassifier_shock_propagator` Sidechain-Driven by `modfm_pulse_saw_formant`
```text
[Tuba] -------------------> (in1/in2) [brassifier_shock_propagator] ---> [Stereo Out]
   |                                        ^
   +--> [modfm_pulse_saw_formant] ----------+ (in4: External Sidechain Bore Pressure!)
         (formant_harmonic=1, pulse_to_saw=0, modfm_index_k=25)
```
* **How It Works:** `brassifier_shock_propagator` sums `in4` directly into its sidechain bore-pressure delay modulator (`D(n) = d0 - beta * p_bore(n)`). Feeding a sharp, narrow **ModFM pulse train** (`pulse_to_saw = 0.0`, `modfm_index_k = 25`) into `in4` forces the tuba's acoustic propagation delay to snap forward abruptly once per cycle at the exact peak of the ModFM pulse—hybridizing **ModFM pulse windowing** with **Cooper & Abel physical shock-wave propagation**.

### 6.3 Frequency-Multiplied Carrier (`amfm_hilbert_transcolorifer`) Feeding `fbam_delay_comb_operator`
```text
[Tuba] -> [amfm_hilbert_transcolorifer (freq_mult_k = 2, env_comp_gamma = 0.6)] -> [fbam_delay_comb_operator] -> [Out]
                                                                                     ^ (in3: f0 Hz from tracker)
```
* **How It Works:** `amfm_hilbert_transcolorifer` first doubles the tuba's instantaneous phase velocity ($K = 2$, shifting all harmonics up an octave while preserving the compressed breath envelope $a(t)^{0.6}$). When this octave-doubled signal enters `fbam_delay_comb_operator` whose feedback delay $D = f_s / f_0$ is still locked to the **original sub-octave fundamental $f_0$** on `in3`, the multiplicative feedback loop `y(n) = x(n) * [1 + beta * y(n - D)]` generates alternating octave/sub-octave comb sidebands that lock into a menacing **riddim octave-divider roar**.

---

## 7. Quick-Reference Live Tuba Performance Recipes

| Genre / Sound Target | Recommended Unix Chain (`->` Series, `||` Parallel) | Key Parameter Highlights |
| :--- | :--- | :--- |
| **1. Casio CZ / Tearout Laser Bass** | `01_harmonic_isolator` $\to$ `heterodyne_pd_shaper` $\to$ `spectral_delay_chirp_filter` | `inflection_d = 0.12`, `res_harmonic = 4.5`, `warp_lambda = -0.65`, `chirp_feedback = 0.55` |
| **2. Talking Riddim Vowel Yoi** | `tuba` $\to$ `vector_phaseshaper_lissajous` $\to$ `heterodyne_fof_resonator` | `infl_v = 2.6` (multi-loop formant), `vowel_morph` swept by `in4` 1-bar phasor, `fof_bandwidth_hz = 75 Hz` |
| **3. Hyper-Cuivré Shock Sawhorn** | `tuba` $\to$ `brassifier_shock_propagator` $\to$ `quadrature_chebyshev_shaper` | `shock_drive_beta = 0.85`, `bore_length_m = 7.5 m`, `quad_phase_angle = +1.57 rad` ($\pi/2$ shock tilt) |
| **4. Buchla West-Coast Sub-Folder** | `tuba` $\to$ `even_odd_harmonic_comb_splitter` (`out3` Odd) $\to$ `buchla259_parallel_wavefolder` $\to$ `nonlinear_ladder_allpass` | `timbre_drive_v = 6.8 V`, `buchla_lp_hz = 1900 Hz`, `base_pole_g = -0.55` |
| **5. Endless Shepard Comb Siren** | `tuba` $\to$ `modfm_pulse_saw_formant` $\to$ `barberpole_comb_ssb_flanger` | `pulse_to_saw = 0.8`, `modfm_index_k = 20`, `sweep_rate_hz = +0.65`, `stereo_counter_dir = 0.8` |
| **6. Chaotic Arnold-Tongue Sub-Growl** | `tuba` $\to$ `deformed_circle_map_fbfm` $\to$ `fbam_delay_comb_operator` | `circle_map_k = 1.28` (period-doubling), `loop_deformation = 0.9` (Concave L-Loop), `fbam_beta = 1.1` |
| **7. Upside-Down Harmonic Shimmer Bass** | `tuba` $\to$ (`retuned_exp_fm_ltz` $\parallel$ `modal_heterodyne_inverter_dist`) | `retuned_exp_fm_ltz` (`beta = 2.4`) in parallel with `modal_heterodyne_inverter_dist` (`spectral_invert = 1.0`, `mode_decay_ms = 120 ms`) |
