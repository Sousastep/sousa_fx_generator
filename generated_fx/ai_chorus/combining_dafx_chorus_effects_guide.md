# Combining DAFx Stereo Chorus, BBD, Scanner, Rotary, Unison Animator & Perceptual Decorrelation Effects: A Routing & Orientation Guide for Live Tuba

## 1. Architectural Overview: 11 Standalone Stereo Chorus Effects-in-Themselves

Each of the 11 chorus processors generated from the DAFx literature is a **complete, standalone stereo effect** (`in1`/`in2` $\to$ `out1`/`out2`) with **6 to 7 musical parameters**, requiring no external pitch tracker to function while optionally accepting an **envelope/footswitch modulator on `in3`** and a **1-bar tempo phasor on `in4`**.

To avoid near-duplicates, the 11 effects span **six fundamentally distinct physical and mathematical chorus mechanisms**:

| Chorus Category | Effect File (`.txt`) | DAFx Paper Basis & Core Mechanism |
| :--- | :--- | :--- |
| **1. Analog BBD Chorus & Clock Physics** | `chorus_bbd_compander_juno.txt` | **DAFx-05 P155 / DAFx-10 P42 / DAFx-18 P12:** Push-pull Roland Juno-60 / Dimension-D dual BBD with $1/f_{\text{clock}}$ delay warp, Sallen-Key filters, MOSFET stage THD, and NE570 2:1 compressor / 1:2 expander. |
| | `chorus_bbd_blep_clock_matrix.txt` | **DAFx-25 P29 / DAFx-16 P59:** True 256-bucket discrete-time shift register clocked by Mačák's logarithmic RC astable circuit (`-2*tau*ln(...)`), preserving musical BBD clock-foldback aliasing (BGA) while suppressing digital simulation aliasing (SGA) via **PolyBLEP**. |
| **2. Electromechanical & Optical Chorus** | `chorus_hammond_scanner_lc.txt` | **DAFx-16 P54:** Hammond B-3 18-stage dispersive LC line box (`v1..v19`) with passband ripple + 16-plate motorized capacitive rotor scanning "there-and-back-again" across the exact Table 2 `V1/C1`, `V2/C2`, `V3/C3` tap wiring. |
| | `chorus_univibe_optical_throb.txt` | **DAFx-19 P31:** Shin-ei Uni-Vibe 4-stage optical chorus with staggered capacitors (`0.015uF, 0.22uF, 470pF, 0.0047uF`), collector/emitter imbalance ($\alpha_n \neq \beta_n$), blocking-cap $C_{\text{DC}}$ low-end shelf throb, Darlington emitter bias, and fast-on/slow-off CdS LDR curves. |
| | `chorus_leslie_doppler_sdf.txt` | **DAFx-02 / DAFx-11 P49 / DAFx-99:** 800 Hz crossover feeding dual $180^\circ$ opposing Doppler horns (`~0.55 ms` excursion) + 4-stage Treble / 3-stage Bass time-varying Spectral Delay Filters (SDFs) with decoupled horn/drum motor inertia and tube amp growl. |
| **3. Multiscale & Psychoacoustic Delay Chorus** | `chorus_multiscale_random_env.txt` | **DAFx-98 FER09:** 3-band dyadic octave filterbank chorus (`Low < 250 Hz`, `Mid`, `High > 1250 Hz`) with raised-cosine ($C^\infty$) narrowband random modulation law and per-band envelope-driven wet mix & tonal-center shift. |
| | `chorus_psychoacoustic_hyperbolic_itd.txt` | **DAFx-06 p149:** Couples modulation depth inversely to modulation rate along Martens & Marui's logistic-regression hyperbola (`Depth = Slope / Rate + Intercept`) around a $0.55\text{ ms}$ reference delay so modulated voices **both lead and lag** the dry tuba across the human ITD horizon. |
| **4. Unison "Supersaw" & AM/FM Analytic Choir** | `chorus_supersaw_waveform_animator.txt` | **DAFx-14 Timoney et al.:** 7-voice unison ensemble combining 4 dual-grain raised-cosine pitch shifters at symmetric ratios ($s, s^3, 1/s, 1/s^3$) with Hutchins's triangle-comparator PWM Waveform Animator (peaking at $0.70$ duty-cycle width). |
| | `chorus_amfm_hilbert_chorifer.txt` | **DAFx-15 P30:** Hilbert AM/FM "ChorIFer" + "OctIFer" ($0.5\times, 2\times$) + "TransColorIFer" ($1.5\times$ fifth) that integrates detuned instantaneous-frequency trajectories and multiplies them by the **un-delayed** envelope $a(t)$ for zero transient smearing and zero comb notches. |
| **5. Critical-Band Roughness Chorus** | `chorus_dissonance_roughness_bank.txt` | **DAFx-08 P30:** 4-band filterbank modulated by Kameoka & Kuriyagawa's optimal roughness law $g(f_1) = 2.27 f_1^{0.477}$ mixed with subband lowpass noise (Section 4 dissonance-reduction chorus) and fast/slow AM envelope expansion. |
| **6. Perceptual Decorrelation Chorus** | `chorus_velvet_noise_ensemble.txt` | **DAFx-17 P96:** 16-tap sparse $\{-1, 0, +1\}$ velvet-noise sequences with logarithmic front-loaded tap spacing, 4-segment staircase decay, and quadrature tap shimmer. |
| | `chorus_erb_allpass_reson_deco.txt` | **DAFx-16 P30 / DAFx-25 P80:** 6-stage ERB-spaced biquad allpass cascade with mutually prime sample delays ($P_L = [19,13,11,7,5,3]$, $P_R = [23,17,7,11,3,5]$) shaped to the DAFx-25 Table 1 75th-percentile perceptual ICTD curve. |

---

## 2. Serial Cascades: How Ordering Transforms the Composite Chorus

When two chorus or spatial modulation effects are placed in series, the second stage processes **both the dry reference and the moving sidebands** created by the first stage, multiplying the effective voice count ($N_{\text{total}} = N_1 \times N_2$) while the final stage dominates the spatial/spectral envelope.

### 2.1 Classic Organ Rig vs. Inverted Rig (`chorus_hammond_scanner_lc` $\leftrightarrow$ `chorus_leslie_doppler_sdf`)

* **Orientation A — Physical Vintage Order (`Hammond C3 Scanner` $\to$ `Leslie Rotary Speaker`):**
  ```text
  [Tuba] -> [chorus_hammond_scanner_lc (C3, 6.12 Hz)] -> [chorus_leslie_doppler_sdf (Chorale/Tremolo)] -> [Out]
  ```
  * **Acoustic Behavior:** Just as in a physical Hammond B-3 console connected to a Leslie 122 cabinet, the signal first passes through the 18-stage LC line box and 6.12 Hz capacitive scanner (`scanner_depth_c1_c3 = 3.0`), creating a rapid, phase-dispersive C3 shimmer. That already-chorused signal then hits the Leslie's tube amplifier overdrive (`tube_amp_growl_db = 6 dB`), where the 6.12 Hz C3 beats intermodulate warmly across the soft $\tanh$ saturator before being split at 800 Hz into the slow-accelerating bass drum and fast-accelerating Doppler horns.

* **Orientation B — Inverted Order (`Leslie Rotary Speaker` $\to$ `Hammond C3 Scanner`):**
  ```text
  [Tuba] -> [chorus_leslie_doppler_sdf] -> [chorus_hammond_scanner_lc] -> [Out]
  ```
  * **Acoustic Behavior:** Placing the Hammond LC line box *after* the Leslie subjects the Leslie's wide stereo Doppler horn reflections to the 18-stage inductor-capacitor lowpass rolloff (`lc_cutoff_hz = 4800 Hz`) and bidirectional passband ripple, taming harsh high-frequency horn overdrive into a dark, woody, hyper-dispersive stereo swirl.

### 2.2 Zero-Smear Unison Choir into Analog BBD Warmth (`chorus_amfm_hilbert_chorifer` $\to$ `chorus_bbd_compander_juno`)

```text
[Tuba] -> [chorus_amfm_hilbert_chorifer] -> [chorus_bbd_compander_juno] -> [Stereo Out]
           (detune=0.9%, octifer=0.35,       (juno_mode=0.0 Push-Pull Mode I,
            transcolor_fifth=0.20)            ne570_compand=0.65, bbd_warmth=0.55)
```
* **Why This Order Works:**
  1. Stacking two delay-line choruses in series often ruins fast tuba articulation because their 15–30 ms delays add together ($D_1 + D_2 \approx 40\text{ ms}$), turning staccato sixteenth notes into flamming slapback echoes.
  2. Because `chorus_amfm_hilbert_chorifer` uses **zero delay lines**—resynthesizing detuned unison, sub-octave (`0.5x`), octave-up (`2.0x`), and fifth (`1.5x`) FM carriers under the exact instantaneous Hilbert envelope $a(t)$—it thickens a single tuba note into a 4-part brass choir with **zero millisecond latency and zero transient softening**.
  3. Feeding that transient-locked choir into `chorus_bbd_compander_juno` (set to short $3.4\text{ ms}$ push-pull Mode I with NE570 companding) wraps the entire brass choir in warm Sallen-Key filtered BBD stereo width with only $3.4\text{ ms}$ total delay!

### 2.3 Pre-Decorrelation vs. Post-Decorrelation (`chorus_erb_allpass_reson_deco` $\leftrightarrow$ `chorus_supersaw_waveform_animator`)

* **Orientation A — `chorus_supersaw_waveform_animator` $\to$ `chorus_erb_allpass_reson_deco` (`dry_wet_chorus_mix = 1.0`):**
  * `chorus_supersaw_waveform_animator` generates 7 closely detuned unison voices ($s, s^3, 1/s, 1/s^3$). When all 7 voices share the same phase origin on a sudden note onset, their initial beating crest factor can spike.
  * Passing the 7-voice supersaw output through `chorus_erb_allpass_reson_deco` at `dry_wet_chorus_mix = 1.0` (100% wet allpass) preserves the **exact flat magnitude spectrum** of all 7 unison voices while dispersing their inter-channel group delay by $13\text{--}19\text{ ms}$ in the $100\text{--}800\text{ Hz}$ ERB bands (and $<5\text{ ms}$ above $4\text{ kHz}$), eliminating unison phase-stacking spikes and projecting the 7 horns outside the speaker bounds.

* **Orientation B — `chorus_erb_allpass_reson_deco` (`dry_wet_chorus_mix = 0.5`) $\to$ `chorus_supersaw_waveform_animator`:**
  * At `dry_wet_chorus_mix = 0.5`, the 6 prime-delay biquad allpass stages sum with the dry signal to carve 36 moving phase-cancellation notches across the tuba spectrum. Feeding that notched spectrum into the 7-voice pitch-shifter bank transposes each spectral notch to 7 slightly different frequencies ($s^3, s, 1, 1/s, 1/s^3$), turning sharp phaser notches into a **blurred, shimmering formant cloud**.

---

## 3. Parallel & Mid-Side Orientations

### 3.1 Center-Anchor Sub / Wide-Ensemble Side Parallel Split (`chorus_multiscale_random_env` $\parallel$ `chorus_velvet_noise_ensemble`)

```text
          +--> [chorus_multiscale_random_env (env_mix_duck_noise=0.7, randomness_bw=0.7)] --+
          |     (Organic non-periodic dyadic band chorus with quiet-band noise gating)       |
[Tuba] ---+                                                                                  +--> [Stereo Bus]
          |                                                                                  |
          +--> [chorus_velvet_noise_ensemble (dry_wet_mix=1.0, log_tap_concentration=0.8)] -+
                (16-tap front-loaded orthogonal {-1,0,+1} velvet-noise spatial halo)
```
* **Why It Works:** `chorus_multiscale_random_env` provides smooth, raised-cosine-interpolated random pitch/delay drift across three octave bands, while `chorus_velvet_noise_ensemble` (set 100% wet in parallel) adds 32 mutually orthogonal sparse reflections concentrated in the first $2\text{--}10\text{ ms}$. Together they recreate the acoustic physics of **a brass section standing on a concert stage** (independent player pitch drift + dense early stage reflections) without any periodic LFO cycle or metallic comb filtering.

### 3.2 Dual Opposite-Clock BBD Matrix (`chorus_bbd_compander_juno` $\parallel$ `chorus_bbd_blep_clock_matrix`)

* Run `chorus_bbd_compander_juno` (`center_delay_ms = 3.5 ms`, high clock $\approx 73\text{ kHz}$, clean Sallen-Key warmth) in parallel with `chorus_bbd_blep_clock_matrix` (`bbd_clock_khz = 7.5 kHz`, `matrix_feedback = 0.55`, `astable_curve = 0.8`).
* **Why It Works:** The Juno BBD anchors the silky, high-headroom stereo chorus image, while the low-clocked PolyBLEP BBD injects **authentic BBD sample-and-hold clock-foldback harmonics ($k F_{\text{CLK}} \pm f_0$)** and asymmetric Electro-Harmonix astable comb sweeps underneath—giving you a lo-fi/hi-fi layered dubstep chorus.

---

## 4. Cascading Multiple Identical Chorus Units with Staggered Tuning

### 4.1 Dual `chorus_psychoacoustic_hyperbolic_itd` in Series (Orthogonal Fast/Slow ITD Orbit)
* Because `chorus_psychoacoustic_hyperbolic_itd` automatically locks modulation depth to modulation rate along the DAFx-06 Fig. 2 hyperbola (`Depth_us = Slope / Rate_Hz - Intercept`), you can cascade two instances at **widely separated rates** knowing both have identical perceived pitch-modulation strength:
  * **Unit 1 (Slow Wide Delay Excursion):** `mod_rate_hz = 1.2 Hz`, `perceptual_zone = 0.50`, `itd_center_ms = 1.4 ms` (Hyperbolic depth automatically sets to $\approx 1.8\text{ ms}$ slow ensemble drift).
  * **Unit 2 (Fast Tight ITD Shimmer):** `mod_rate_hz = 6.8 Hz`, `perceptual_zone = 0.50`, `itd_center_ms = 0.45 ms` (Hyperbolic depth automatically sets to $\approx 0.22\text{ ms}$ fast binaural ITD vibrato).
* **Result:** A two-timescale "Slow Ensemble + Fast Vibrato" symphonic brass chorus where neither stage ever goes out of tune.

### 4.2 Dual `chorus_erb_allpass_reson_deco` in Series (12-Stage Mutually Prime Decorrelator)
* Cascading two `chorus_erb_allpass_reson_deco` units with `erb_group_delay_scale = 0.65` on Unit 1 and `erb_group_delay_scale = 0.90` on Unit 2 chains **12 ERB-spaced biquad allpass sections** whose sample delays ($[12, 8, 7, 5, 3, 2]$ followed by $[17, 12, 10, 6, 4, 3]$) share almost no common factors—doubling the group-delay density to the full 30 ms Kermit-Canfield & Abel ceiling while maintaining a strictly flat $0\text{ dB}$ magnitude response.

---

## 5. Combining Today's Chorus Effects with Yesterday's PM/FM/Wavefolder/Comb Modules

Because chorus effects multiply partials and disperse phases, **placing a chorus before vs. after a nonlinear PM/FM/wavefolder module** produces drastically different results:

### 5.1 Chorus *After* PM/Wavefolding (Lush Stereo Widening of Aggressive Bass)
```text
[Tuba] -> [retuned_exp_fm_ltz] -> [buchla259_parallel_wavefolder] -> [chorus_bbd_compander_juno] -> [Out]
```
* **Behavior:** The Exponential FM and Buchla 259 wavefolder operate on a single coherent monophonic tuba waveform (keeping the sub-bass fundamental and folded overtones razor-focused and free of inter-voice beating mud), and `chorus_bbd_compander_juno` (or `chorus_velvet_noise_ensemble`) spreads the finished aggressive synth-brass tone into a massive stereo wall at the end of the chain.

### 5.2 Chorus *Before* Nonlinear Distortion (Intentional Intermodulation "Reese Bass" Churn)
```text
[Tuba] -> [chorus_supersaw_waveform_animator (unison_detune_cents = 18)] -> [buchla259_parallel_wavefolder] -> [Out]
```
* **Behavior:** When the 7 detuned unison voices from `chorus_supersaw_waveform_animator` sum together *before* hitting the 5 parallel folding cells of `buchla259_parallel_wavefolder`, the slowly beating amplitude peaks of the 7 voices continuously cross and un-cross the Buchla voltage thresholds ($\pm 0.6\text{ V} \dots \pm 5.46\text{ V}$). This turns unison beating into a **churning Neurofunk / Dubstep "Reese Bass" timbre** where the harmonic spectrum itself morphs with every beat cycle!

### 5.3 Even/Odd Harmonic Comb Split into Dedicated Bass-Safe & Treble-Rich Choruses
```text
                                      +--> (out3: ODD f0, 3f0, 5f0) ---> [chorus_erb_allpass_reson_deco] ----+
                                      |                                   (100% wet flat-mag allpass width)  |
[Tuba] -> [even_odd_harmonic_comb_splitter]                                                                  +--> [Stereo Out]
             ^ (in3: f0 Hz)           |                                                                      |
                                      +--> (out4: EVEN 2f0, 4f0, 6f0) -> [chorus_univibe_optical_throb] -----+
                                                                          (or chorus_dissonance_roughness_bank)
```
* **Why This Is the Ultimate Live Tuba Split:**
  * The **Odd Harmonic Stem (`out3`)** carries the fundamental $f_0$. By routing `out3` through `chorus_erb_allpass_reson_deco` (`dry_wet_chorus_mix = 1.0`), the fundamental gains binaural group-delay width with **zero pitch detuning and zero amplitude beating**, keeping the sub-bass rock solid in the club PA.
  * The **Even Harmonic Stem (`out4`, starting at $2 f_0$)** is routed through `chorus_univibe_optical_throb` or `chorus_dissonance_roughness_bank`, imparting deep optical throbbing or Kameoka-Kuriyagawa critical-band roughness exclusively to the upper octave harmonics!
