# Combining DAFx Compressors & Limiters: Multi-Stage Topologies, Parallel/Serial Orientations & Hybrid Effect Architectures

Because the 7 DAFx-derived compressors and limiters in this collection are designed as **characterful musical effects in themselves**—encompassing variable-$\mu$ vacuum-tube feedback limiting (`comp_fairchild_6386_varimu`), T4B CdS photocell leveling (`comp_la2a_t4b_opto_leveler`), SSL G384 VCA bus glue (`comp_ssl_g384_bus_vca`), threshold-free relative-level microdynamics shaping (`comp_ldr_microdynamics_shaper`), 3-band OTT relative-level inflation (`comp_multiband_ldr_ott_inflator`), Hämäläinen order-statistic running-max lookahead brickwall limiting (`limiter_hamalainen_orderstat_peak`), and Fontana dispersive all-pass anti-clipping limiting (`limiter_allpass_phase_antiklip`)—combining them in different **numbers, orders, and spatial/spectral orientations** yields classic studio mastering chains as well as radical sound-design processors.

---

## 1. Serial Two-Stage Cascades ("Fast Peak Catcher $\to$ Slow Program Leveler" vs. Reverse)

### 1.1 The Classic "1176 / Vari-Mu $\to$ LA-2A" Vocal & Lead Synth Chain
$$\texttt{comp\_crest\_flux\_autoballistic} \longrightarrow \texttt{comp\_la2a\_t4b\_opto\_leveler}$$
- **How it works**:
  1. `comp_crest_flux_autoballistic` (with `crest_flux_adapt = 0.85`, `fet_slam_sat = 0.45`) uses real-time Crest Factor and Spectral Flux detection (Maddams et al., DAFx-2012) to accelerate attack down to $40\ \mu\text{s}$ only on plosives and sharp pick/synth transients, shaving off $4\text{–}6\text{ dB}$ of peak spikes and recovering immediately without pumping.
  2. `comp_la2a_t4b_opto_leveler` (`peak_reduction = 55`, `cell_memory = 0.70`) then sees a pre-tamed signal and rides the phrase-level body using its two-stage T4B CdS photocell memory ($60\text{ ms}$ fast release + $0.5\text{–}4.5\text{ s}$ luminescent tail) and asymmetric 12AX7/12BH7 tube warmth.
- **Why order matters**: Reversing the order (`comp_la2a_t4b_opto_leveler` $\to$ `comp_crest_flux_autoballistic`) forces the slow $10\text{ ms}$ optical attack of the LA-2A to let the initial transient spike slip through while charging its slow photocell memory on thespike's energy; the downstream FET auto-ballistic compressor then clamps that exaggerated transient burst, creating a hyper-articulate "pop" followed by a deep optical dip.

### 1.2 "Dispersive Phase Peak Eraser $\to$ Order-Statistic Brickwall Maximizer" (+6 dB Extra Headroom Without Pumping)
$$\texttt{limiter\_allpass\_phase\_antiklip} \longrightarrow \texttt{limiter\_hamalainen\_orderstat\_peak}$$
- **How it works**:
  1. `limiter_allpass_phase_antiklip` (Fontana et al., DAFx-2026) sweeps two cascaded first-order all-pass filters across incoming transients while algebraically bounding $\Delta c(n)$ (Algorithm 1). Local phase dispersion smears asymmetrical transient spikes across time, reducing the instantaneous crest factor by $3\text{–}5\text{ dB}$ without applying broadband gain reduction.
  2. `limiter_hamalainen_orderstat_peak` (Hämäläinen, DAFx-2002) then applies its $N$-sample lookahead running-maximum + $M$-sample boxcar envelope (`lookahead_samp = 48`, `boxcar_smooth = 24`) to catch any remaining peaks at `ceiling_db = -0.3`.
- **Musical result**: Because the all-pass stage disperses sharp peak energy into a rounder waveform first, the Hämäläinen brickwall limiter works $4\text{ dB}$ less hard, eliminating gain-pumping holes on heavy kick+sub masters while adding a subtle "laser" phase sheen on snare transients.

---

## 2. Opposing Microdynamics Push-Pull ("Transient Expand $\to$ Vari-Mu Tube Squash")

### 2.1 Level-Independent Punch Expander Driving 6386 Variable-$\mu$ Triode Saturation
$$\texttt{comp\_ldr\_microdynamics\_shaper}\ (m > 1.5) \longrightarrow \texttt{comp\_fairchild\_6386\_varimu}$$
- **How it works**:
  1. Setting `micro_amount = 1.85` on `comp_ldr_microdynamics_shaper` (Nercessian et al., DAFx-2022, Eq. 12: $g[n] = L[n]^{(m-1)/p}$) expands every note attack relative to its local macrodynamic floor—regardless of whether the passage is ppp or fff.
  2. Those heightened transients slam directly into `comp_fairchild_6386_varimu` (`drive_db = 12`, `tc_mode = 6`, `tube_harmonics = 0.70`). In Raffensperger's model (DAFx-2012, Sec. 6, Fig. 13), the push-pull 6386 triode stage generates 3rd-harmonic saturation **proportional to gain reduction**, while the 3-capacitor network ($C_T, C_U, C_V$) absorbs the spike rapidly and releases with a dual-time-constant bloom.
- **Musical result**: Turns flat drum machines, electric pianos, or plucked synths into an explosively barking, breathing analog tape/tube rhythm track: attacks burst into odd-harmonic tube glow, while sustain tails stay clean and clear.

### 2.2 Reverse Push-Pull: "SSL Bus Glue $\to$ 3-Band OTT Upward Inflator"
$$\texttt{comp\_ssl\_g384\_bus\_vca} \longrightarrow \texttt{comp\_multiband\_ldr\_ott\_inflator}$$
- First, `comp_ssl_g384_bus_vca` (`ratio_mode = 4`, `attack_ms = 15`, `auto_release = 0.8`) glues the stereo bus together with unified rhythmic VCA movement and a $15\text{ ms}$ transient punch pocket.
- Second, `comp_multiband_ldr_ott_inflator` (`low_micro_m = 0.25`, `mid_micro_m = 0.35`, `high_micro_m = 0.28`) pulls up the quiet inter-transient room tails, reverb shimmer, and sub-bass sustain independently in 3 bands without undoing the SSL's rhythmic groove.

---

## 3. Parallel ("New York" / Dual-Path) Orientations

### 3.1 Dual-Character Parallel Crush (Left/Right or Blended Parallel Bus)
Split the stereo source into two parallel stereo branches and sum them:
- **Branch A (Transient Snap & Phase Sheen)**: `comp_ldr_microdynamics_shaper` (`micro_amount = 1.6`, `attack_ms = 2.0`, `release_ms = 60.0`) accentuating microdynamic snap with zero threshold dead-zone.
- **Branch B (Hyper-Dense Tube Sustain Pillowing)**: `comp_fairchild_6386_varimu` (`drive_db = 18.0`, `ac_thresh = 0.85`, `dc_knee = 0.10`, `tc_mode = 4`, `tube_harmonics = 0.85`) crushed by $15\text{ dB}$ of continuous variable-$\mu$ limiting so it acts as a Pure Sustain + 3rd-Harmonic Exciter bed underneath Branch A's uncompressed transients.

---

## 4. Spatial Mid-Side (Lateral-Vertical) & Cross-Series Orientations with Chorus / Phase-Distortion Effects

1. **Mid-Channel Optical Vocal/Bass Lock + Side-Channel Vari-Mu Spatial Bloom**:
   - Use `comp_fairchild_6386_varimu` with `lat_vert_mode = 1.0` (full Lateral/Vertical Mid-Side mode as on the original Fairchild 670). When a centered kick or snare hits the Mid (Lateral) channel, the Side (Vertical) channel remains un-attenuated, causing the stereo room/chorus image to **widen dynamically on every drum hit** and contract during sustain.
2. **Interleaving Compressors with Chorus & Phase-Modulation Effects**:
   - **Chorus $\to$ `comp_multiband_ldr_ott_inflator`**: Putting any BBD, Uni-Vibe, or Supersaw chorus *before* `comp_multiband_ldr_ott_inflator` (`low_micro_m = 0.2`, `high_micro_m = 0.2`) forces the 3-band relative-level detectors to continuously ride and upward-inflate the comb-filter notches of the chorus, transforming a gentle modulation effect into a massive, breathing EDM/hyperpop wall of sound.
   - **`comp_crest_flux_autoballistic` $\to$ Wavefolder / Phase Distortion $\to$ `limiter_hamalainen_orderstat_peak`**: Clamping crest factor *before* a nonlinear wavefolder stabilizes harmonic fold depth across velocity variations, while the Hämäläinen order-statistic limiter after the wavefolder guarantees a clip-free ceiling without dulling the folded high frequencies.
