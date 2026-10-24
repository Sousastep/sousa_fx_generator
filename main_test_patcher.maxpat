{
    "patcher": {
        "fileversion": 1,
        "appversion": {
            "major": 9,
            "minor": 2,
            "revision": 0,
            "architecture": "x64",
            "modernui": 1
        },
        "classnamespace": "box",
        "rect": [ 613.0, 266.0, 1436.0, 889.0 ],
        "openinpresentation": 1,
        "isolateaudio": 1,
        "boxes": [
            {
                "box": {
                    "autosave": 1,
                    "id": "obj-16",
                    "inletInfo": {
                        "IOInfo": [
                            {
                                "type": "signal",
                                "index": 1,
                                "tag": "in1",
                                "comment": ""
                            },
                            {
                                "type": "signal",
                                "index": 2,
                                "tag": "in2",
                                "comment": ""
                            },
                            {
                                "type": "signal",
                                "index": 3,
                                "tag": "in3",
                                "comment": ""
                            },
                            {
                                "type": "midi",
                                "index": -1,
                                "tag": "",
                                "comment": ""
                            }
                        ]
                    },
                    "maxclass": "newobj",
                    "numinlets": 4,
                    "numoutlets": 5,
                    "outletInfo": {
                        "IOInfo": [
                            {
                                "type": "signal",
                                "index": 1,
                                "tag": "out1",
                                "comment": ""
                            },
                            {
                                "type": "signal",
                                "index": 2,
                                "tag": "out2",
                                "comment": ""
                            },
                            {
                                "type": "signal",
                                "index": 3,
                                "tag": "out3",
                                "comment": ""
                            },
                            {
                                "type": "signal",
                                "index": 4,
                                "tag": "out4",
                                "comment": ""
                            }
                        ]
                    },
                    "outlettype": [ "signal", "signal", "signal", "signal", "list" ],
                    "patcher": {
                        "fileversion": 1,
                        "appversion": {
                            "major": 9,
                            "minor": 2,
                            "revision": 0,
                            "architecture": "x64",
                            "modernui": 1
                        },
                        "classnamespace": "rnbo",
                        "rect": [ 100.0, 100.0, 1879.0, 780.0 ],
                        "default_fontname": "Lato",
                        "title": "untitled",
                        "boxes": [
                            {
                                "box": {
                                    "id": "obj-30",
                                    "linecount": 112,
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 30.0, 556.0, 577.0, 1634.0 ],
                                    "text": "================================================================================\n00_tuba_freq_tracker — Parameter Information\n================================================================================\n\nOVERVIEW\nA custom tuba-specialized hybrid pitch & phasor tracker for live low-brass\ndubstep, built to avoid the frame latency of generic FFT-based YinFFT\n(fluid.pitch~), which needs a 2048/4096-sample window (~46 to 93 ms at 44.1/48 kHz)\nand only updates once per hop. It unites three complementary DSP stages inside\na single RNBO codebox~:\n\n1. 4x-Decimated Recursive Sliding YIN (CMNDF): Computes the Cumulative Mean\n   Normalized Difference Function in the time domain. The difference function\n   is updated recursively over a sliding window (add the newest sample's term,\n   subtract the term leaving the window), so nothing is recomputed from scratch.\n   The cost is O(maxLag) per decimated sample (up to ~430 lags), not O(1), which\n   is still light on CPU. The CMNDF search runs every 32 audio samples (~0.7 ms at\n   48 kHz) with parabolic sub-sample interpolation, a first-dip search to reduce\n   octave errors, and a 3-point median filter to reject valve/tongue transients.\n\n2. Instantaneous Frequency Tracking (IFT): Isolates the tuba's fundamental with\n   a dual-stage adaptive SVF bandpass centered on the fused pitch, builds the\n   analytic signal s_a(t) = A(t)*e^(j*theta(t)) with a 4-stage quadrature IIR\n   Hilbert pair (z^-2 allpass sections, ~90 degrees +/- 1 degree across 28 to 420 Hz),\n   and differentiates the unwrapped phase d(theta)/dt on EVERY sample. There is no\n   frame or hop latency, but the narrow bandpass filters still add group delay,\n   which grows as pitch gets lower.\n\n3. Confidence-Weighted Fusion + Phase-Locked Loop (PLL): YIN supplies a coarse\n   octave anchor, and IFT follows fast lip bends, vibrato, and glissandi within\n   +/- 18% of that anchor (it falls back to the anchor otherwise). The two are\n   mixed with a fixed crossfade (IFT_speed), and YIN confidence scales how quickly\n   the fused pitch adapts. This is a complementary blend, not a Kalman filter: there\n   is no covariance or motion model. The last valid pitch is held on note\n   releases. A PLL phasor locks to the analytic phase of the fundamental.\n\n   Note: the anchor reduces octave errors but cannot eliminate them. If YIN\n   locks to the wrong octave, IFT will follow it.\n\nINLETS & OUTLETS\n- in1 / in2: Stereo (or mono on in1) tuba audio input\n- in3: Optional external pitch hint in Hz (if fluid.pitch~ is patched here, it is\n  averaged 50/50 with the internal YIN anchor; only values between 20 and 1000 Hz\n  are used)\n- out1: Tracked fundamental pitch f0 in Hz (patch directly into in3 of effects 01–18!)\n- out2: Pitch confidence / periodicity [0.0 to 1.0]\n- out3: Phase-locked tuba phasor [0.0 to 1.0) (phase-locked sawtooth ramp at f0)\n- out4: Phase-locked fundamental sine wave [-1.0 to 1.0] (scaled by confidence)\n\nPARAMETERS (5)\n\n1. min_freq_hz\n   - Range: 24.0 to 120.0 Hz (Default: 28.0 Hz, covering down to Pedal Bb0 = 29.14 Hz)\n   - Taper: Direct frequency in Hz.\n   - Function: Sets the longest lag boundary of the YIN search. Raising this to ~38 Hz\n     when not playing pedal notes shortens the lag loop and lowers CPU. It does not\n     reduce latency, since the integration window is set separately by yin_window_ms.\n   - Note: At sample rates above 48 kHz the lag range is capped at 430 lags, so the\n     lowest trackable pitch rises (roughly 55 Hz at 96 kHz) regardless of this setting.\n\n2. max_freq_hz\n   - Range: 150.0 to 700.0 Hz (Default: 420.0 Hz, covering up to high G4/Ab4)\n   - Taper: Direct frequency in Hz.\n   - Function: Sets the shortest lag boundary of the YIN search and the upper clamp\n     of the tracker, preventing high brass lip buzz or valve clicks from triggering\n     false high-frequency jumps.\n\n3. IFT_speed\n   - Range: 0.0 to 1.0\n     (0.0 = median-filtered YIN only, 1.0 = full per-sample IFT instantaneous frequency,\n     still gated to within +/- 18% of the YIN anchor)\n   - Taper: Linear crossfade coupled with tracking time-constant reduction\n     (from 10 ms down to 1.5 ms).\n   - Function: Controls how strongly the Hilbert phase differentiator (IFT) is\n     weighted against the YIN lag estimator during fast lip slurs, pitch bends,\n     and vibrato, and how quickly the fused pitch follows the target. The adaptation\n     rate is further scaled by YIN confidence (full speed at confidence >= 0.75,\n     fading to a hold at confidence <= 0.35).\n\n4. gate_thresh_db\n   - Range: -60.0 to -18.0 dB (Default: -42.0 dB)\n   - Taper: dB converted to a linear amplitude (dbtoa) and compared against an\n     8 ms RMS envelope.\n   - Function: Holds the tracked pitch f0 at its last valid frequency whenever the\n     tuba's RMS level drops below this threshold, which prevents pitch-drop glitches\n     at the end of notes. YIN evaluation is also paused below the threshold. The\n     gate has no hysteresis, so keep it clear of your noise floor.\n\n5. yin_window_ms\n   - Range: 10.0 to 60.0 ms (Default: 28.0 ms)\n   - Taper: Direct time in milliseconds.\n   - Function: Length of the YIN integration window. Longer windows give more\n     reliable low notes but add latency and smooth the response; shorter windows\n     react faster but are less stable. At the default 28 ms, the window is shorter\n     than one period of a 28 Hz pedal tone (~36 ms), so the lowest notes are partly\n     a guess at onset. Try 36 to 40 ms if pedal tones feel unreliable.\n   - Notes: The window is capped so that window + maxLag fits the 1024-sample\n     buffer (about 49 ms at 48 kHz with min_freq_hz = 28). Changing this\n     parameter while audio runs resets the running sums, so expect a brief\n     (about one window) dip in confidence while they refill. Treat it as\n     set-and-forget rather than a performance control.\n\nREVISION NOTES\n- The Hilbert quadrature pair was corrected (z^-2 allpass sections with the proper\n  sign, plus a sign fix on the imaginary part). Before this fix the two paths were\n  not in quadrature, so IFT readings were rejected by the anchor gate and the output\n  was effectively smoothed YIN. IFT_speed and the PLL phasor/sine outputs now\n  respond to the true analytic phase, so expect different behavior from earlier\n  patches.\n- Added the yin_window_ms parameter and made the YIN confidence weighting a soft ramp\n  instead of a hard gate at 0.35.\n================================================================================\n",
                                    "varname": "paraminfo_comment"
                                }
                            },
                            {
                                "box": {
                                    "code": "// ============================================================================\n// 00_tuba_freq_tracker.txt\n// Hybrid IFT (Instantaneous Frequency Tracking) + Recursive YIN (CMNDF)\n// + Phase-Locked Loop (PLL) Pitch & Analytic Phasor Tracker for Live Tuba\n// ============================================================================\n// Design rationale (vs. a standalone YinFFT such as fluid.pitch~):\n//   1. YinFFT needs a 2048-to-4096 sample FFT window (~46 to 93 ms at 44.1/48k)\n//      to resolve a 29 Hz pedal Bb0, and only updates once per hop.\n//   2. This tracker combines TWO complementary real-time engines:\n//      (A) YIN (de Cheveigne & Kawahara 2002) whose difference function is\n//          updated recursively over a sliding window (add the newest sample's\n//          term, subtract the term leaving the window) instead of being\n//          recomputed from scratch. Cost per decimated sample is O(maxLag)\n//          (up to ~430 lags), NOT O(1). The CMNDF search is evaluated every\n//          32 audio samples (~0.7 ms hop) with parabolic sub-sample\n//          interpolation and a first-dip search that reduces octave errors.\n//      (B) IFT: an adaptive narrowband SVF pair isolates the fundamental, a\n//          4-stage quadrature IIR Hilbert pair makes the analytic signal, and\n//          d(theta)/dt is taken EVERY SAMPLE, so there is no frame/hop latency\n//          for fast lip bends and vibrato. NOTE: \"no frame latency\" is not\n//          \"zero latency\": the narrow isolating bandpass filters still add\n//          group delay, which grows as the tracked pitch gets lower.\n//   3. A confidence-weighted complementary fusion blends the unambiguous YIN\n//      coarse fundamental with the fast IFT instantaneous frequency, and a\n//      Type-II-style PLL phasor locks to the analytic phase. Outputs are Hz,\n//      confidence, a locked [0..1) phasor, and a fundamental sine wave.\n//\n// What this is NOT:\n//   - It is not a Kalman filter or HMM. There is no covariance, no motion\n//     model and no uncertainty propagation. It is a state-carrying cascade of\n//     smoothers and gates. Confidence scales how fast the fused pitch adapts\n//     (soft ramp), but nothing is propagated as a variance.\n//   - It has no valve or breath priors. The only external prior is the\n//     optional in3 hint, which is averaged 50/50 with YIN. in3 (or a\n//     constraint on the candidate lags) is the natural place to add a\n//     fingering-derived harmonic-series prior later.\n//\n// Known limitations:\n//   - Onset latency at the low end: the default 28 ms YIN window is shorter\n//     than one period of a 28 Hz pedal tone (~36 ms), so the lowest notes are\n//     partly a guess at onset. yin_window_ms can be raised to ~36-40 ms for\n//     more reliable pedal tones, at the cost of extra latency/smoothing. The\n//     window is capped so that window + maxLag fits the 1024-sample buffer\n//     (about 49 ms at 48 kHz with min_freq_hz = 28).\n//   - Sample rates above 48 kHz: decimation is fixed at 4x and maxLag is\n//     capped at 430, so at 96 kHz the lowest trackable pitch rises to roughly\n//     55 Hz. Use 44.1/48 kHz, or raise the buffer sizes and the maxLag cap.\n//   - Changing yin_window_ms while audio runs resets the running sums, so\n//     expect a brief (~one window) dropout in confidence while they refill.\n// ============================================================================\n// Inlets:\n//   in1: Left Audio Input (Tuba)\n//   in2: Right Audio Input (Tuba; if unpatched, mono in1 is used automatically)\n//   in3: Optional External Pitch Hint in Hz (e.g. fluid.pitch~; if 20..1000 Hz,\n//        averaged 50/50 with YIN)\n// Outlets:\n//   out1: Tracked Fundamental Frequency f0 in Hz (audio-rate)\n//   out2: Pitch Confidence / Periodicity [0.0 .. 1.0]\n//   out3: Phase-Locked Tuba Phasor [0.0 .. 1.0) (drop-in replacement for phasor~)\n//   out4: Phase-Locked Fundamental Sine Wave [-1.0 .. 1.0], scaled by confidence\n\n@param({ min: 24.0, max: 120.0 }) min_freq_hz = 28.0;\n@param({ min: 150.0, max: 700.0 }) max_freq_hz = 420.0;\n@param({ min: 0.0, max: 1.0 }) IFT_speed = 0.65;\n@param({ min: -60.0, max: -18.0 }) gate_thresh_db = -42.0;\n@param({ min: 10.0, max: 60.0 }) yin_window_ms = 28.0;\n\n// --- Pre-Conditioning Filters (Isolate 25..450 Hz brass fundamental region) ---\n@state preHp = new svf();\n@state preLp1 = new onepole();\n@state preLp2 = new onepole();\n\n// --- Recursive Sliding YIN (CMNDF) State ---\n// Downsampled by 4x (e.g. 12 kHz at 48 kHz SR) so lags up to 430 cover 28 Hz\n// and up. yinBuf is a 1024-sample circular buffer (window + maxLag must fit).\n@state yinBuf = new FixedSampleArray(1024);\n@state runDiff = new FixedSampleArray(440);\n@state yinWrite: Int = 0;\n@state decCount: Int = 0;\n@state hopCount: Int = 0;\n@state lastWinSize: Int = 0;\n@state yinFreq = 58.27; // Default Bb1\n@state yinConf = 0.0;\n\n// 3-point Median filter history on YIN pitch to reject transient tongue clicks\n@state med0 = 58.27;\n@state med1 = 58.27;\n@state med2 = 58.27;\n\n// --- IFT (Instantaneous Frequency Tracking) State ---\n// Adaptive narrowband SVF tracks the fundamental, followed by a 4-stage Hilbert pair.\n// Each allpass stage is second order in z^-2, so it keeps two past inputs and\n// two past outputs: indices [2k] = value at n-1, [2k+1] = value at n-2.\n@state IFTSvf1 = new svf();\n@state IFTSvf2 = new svf();\n@state hReX = new FixedSampleArray(8);\n@state hReY = new FixedSampleArray(8);\n@state hImX = new FixedSampleArray(8);\n@state hImY = new FixedSampleArray(8);\n@state hDelRe = 0.0;\n@state prevTheta = 0.0;\n@state IFTInstHz = 58.27;\n\n// --- Fusion & Phase-Locked Loop (PLL) State ---\n@state fusedF0 = 58.27;\n@state smoothConf = 0.0;\n@state envRms = 0.0;\n@state pllPhase = 0.0;\n\nlet sr = maximum(samplerate(), 1.0);\nlet xL = in1;\nlet xR = in2;\nlet extHint = in3;\n\n// Sum stereo (or mono if in2 is silent)\nlet rawMono = (abs(xR) > 0.0000001) ? (0.5 * (xL + xR)) : xL;\n\n// ============================================================================\n// 1. RMS ENVELOPE & SILENCE GATE\n// ============================================================================\nlet envCoeff = 1.0 - exp(-1.0 / (0.008 * sr));\nenvRms += (rawMono * rawMono - envRms) * envCoeff;\nlet rmsAmp = sqrt(maximum(envRms, 0.0));\nlet threshLin = dbtoa(clamp(gate_thresh_db, -60.0, -18.0));\nlet isPlaying = (rmsAmp > threshLin) ? 1.0 : 0.0;\n\n// ============================================================================\n// 2. PRE-CONDITIONING FOR RECURSIVE YIN\n// Highpass at 22 Hz (remove breath thumps/DC) + 2-stage lowpass at 260 Hz\n// ============================================================================\nlet hpSig = preHp.next(rawMono, 22.0, 0.707)[1];\nlet condSig = preLp2.next(preLp1.next(hpSig, 260.0), 260.0);\n\n// ============================================================================\n// 3. 4x DECIMATED RECURSIVE YIN (CMNDF) ENGINE\n// ============================================================================\ndecCount = (decCount + 1) % 4;\nif (decCount == 0) {\n\tlet dSr = sr * 0.25;\n\tlet minLag: Int = floor(clamp(dSr / clamp(max_freq_hz, 150.0, 700.0), 12.0, 120.0));\n\tlet maxLag: Int = floor(clamp(dSr / clamp(min_freq_hz, 24.0, 120.0), 130.0, 430.0));\n\n\t// Integration window (yin_window_ms). Capped so winSize + maxLag stays\n\t// inside the 1024-sample circular buffer. Cost is O(maxLag) per decimated\n\t// sample regardless of window length.\n\tlet winSize: Int = floor(clamp(dSr * 0.001 * clamp(yin_window_ms, 10.0, 60.0), 128.0, 1020.0 - maxLag));\n\n\t// The recursive sums are only valid for a fixed window length, so reset\n\t// them if the window length changes (parameter edit or sample-rate change).\n\tif (winSize != lastWinSize) {\n\t\tfor (let i: Int = 0; i < 440; i++) {\n\t\t\trunDiff[i] = 0.0;\n\t\t}\n\t\tlastWinSize = winSize;\n\t}\n\n\tyinBuf[yinWrite] = condSig;\n\tlet oldIdx: Int = (yinWrite - winSize + 1024) % 1024;\n\tlet xNew = condSig;\n\tlet xOld = yinBuf[oldIdx];\n\n\t// Update running squared difference d_t(tau) recursively (O(maxLag) loop)\n\tfor (let tau: Int = 1; tau <= maxLag; tau++) {\n\t\tlet idxNewTau: Int = (yinWrite - tau + 1024) % 1024;\n\t\tlet idxOldTau: Int = (oldIdx - tau + 1024) % 1024;\n\t\tlet diffNew = xNew - yinBuf[idxNewTau];\n\t\tlet diffOld = xOld - yinBuf[idxOldTau];\n\t\tlet updated = runDiff[tau] + diffNew * diffNew - diffOld * diffOld;\n\t\trunDiff[tau] = maximum(updated, 0.0);\n\t}\n\n\t// Evaluate Cumulative Mean Normalized Difference Function d'(tau) every 8 decimated samples (32 audio samples = ~0.7 ms)\n\thopCount = (hopCount + 1) % 8;\n\tif (hopCount == 0 && isPlaying > 0.5) {\n\t\tlet cumSum = 0.0;\n\t\tlet bestTau: Int = minLag;\n\t\tlet bestVal = 10.0;\n\t\tlet thresh = 0.14; // YIN absolute threshold for first subharmonic dip\n\t\tlet foundDip: Int = 0;\n\n\t\tfor (let tau: Int = 1; tau <= maxLag; tau++) {\n\t\t\tcumSum += runDiff[tau];\n\t\t\tlet cmndf = (cumSum > 0.0000001) ? (runDiff[tau] * tau / cumSum) : 1.0;\n\n\t\t\tif (tau >= minLag) {\n\t\t\t\tif (foundDip == 0) {\n\t\t\t\t\tif (cmndf < bestVal) {\n\t\t\t\t\t\tbestVal = cmndf;\n\t\t\t\t\t\tbestTau = tau;\n\t\t\t\t\t}\n\t\t\t\t\t// Once we enter a dip below threshold and start rising, lock to this fundamental!\n\t\t\t\t\t// This favors the first dip over the 2*tau sub-octave while rejecting the 0.5*tau 2nd harmonic\n\t\t\t\t\tif (bestVal < thresh && cmndf > bestVal + 0.02) {\n\t\t\t\t\t\tfoundDip = 1;\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t}\n\t\t}\n\n\t\t// Parabolic interpolation around bestTau for sub-sample accuracy\n\t\tlet tauM1: Int = maximum(bestTau - 1, 1);\n\t\tlet tauP1: Int = minimum(bestTau + 1, maxLag);\n\t\tlet y1 = runDiff[tauM1];\n\t\tlet y2 = runDiff[bestTau];\n\t\tlet y3 = runDiff[tauP1];\n\t\tlet denom = 2.0 * (2.0 * y2 - y1 - y3);\n\t\tlet delta = (abs(denom) > 0.0000001) ? clamp((y1 - y3) / denom, -0.5, 0.5) : 0.0;\n\n\t\tlet refinedLag = bestTau + delta;\n\t\tlet rawYinHz = clamp(dSr / refinedLag, min_freq_hz, max_freq_hz);\n\t\tlet rawConf = clamp(1.0 - bestVal, 0.0, 1.0);\n\n\t\t// 3-point median filter to strip brass valve/tongue transient spikes\n\t\tif (rawConf > 0.45) {\n\t\t\tmed2 = med1;\n\t\t\tmed1 = med0;\n\t\t\tmed0 = rawYinHz;\n\t\t\tlet a = med0; let b = med1; let c = med2;\n\t\t\tlet medianHz = maximum(minimum(a, b), minimum(maximum(a, b), c));\n\t\t\tyinFreq = medianHz;\n\t\t}\n\t\tyinConf = rawConf;\n\t}\n\tyinWrite = (yinWrite + 1) % 1024;\n}\n\n// Optional blend with external fluid.pitch~ hint on in3 if user patches it.\n// (Currently a fixed 50/50 average; a fingering-derived prior could replace this.)\nlet anchorHz = (extHint > 20.0 && extHint < 1000.0) ? linearinterp(0.5, yinFreq, extHint) : yinFreq;\n\n// ============================================================================\n// 4. IFT (Instantaneous FREQUENCY TRACKING) ENGINE\n// Isolates the fundamental partial using a dual-stage SVF centered at fusedF0,\n// extracts the analytic signal via a 4-stage quadrature Hilbert transform,\n// and differentiates instantaneous phase d(theta)/dt every single sample.\n// (Per-sample update = no hop latency, but the isolating filters add group delay.)\n// ============================================================================\nlet trackCenter = clamp(fusedF0, min_freq_hz, max_freq_hz);\nlet bp1 = IFTSvf1.next(hpSig, trackCenter, 0.86)[2];\nlet isoFund = IFTSvf2.next(bp1, trackCenter, 0.86)[2];\n\n// 4-Stage Quadrature IIR Hilbert Allpass Pair (polyphase design).\n// Coefficients are the squared values of a standard 4+4 polyphase IIR Hilbert\n// set. They MUST be used in a z^-2 allpass, H(z) = (c - z^-2) / (1 - c*z^-2),\n// i.e. y[n] = c*(x[n] + y[n-2]) - x[n-2], with the real path delayed by one\n// sample. (A z^-1 section, or the opposite sign, gives ~0 degrees of phase\n// difference between the two paths at 28..420 Hz, i.e. no quadrature at all.)\n// Verified numerically at 44.1/48 kHz: phase difference is -90 deg +/- ~1 deg\n// across 28..420 Hz, and recovered frequency matches the input sine.\nlet cRe0 = 0.4794008656; let cRe1 = 0.8762184935; let cRe2 = 0.9765975895; let cRe3 = 0.9974992559;\nlet cIm0 = 0.1617584983; let cIm1 = 0.7330289323; let cIm2 = 0.9453497003; let cIm3 = 0.9905991567;\n\n// Real path (delayed one sample at the end)\nlet sRe = isoFund;\nlet yRe0 = cRe0 * (sRe + hReY[1]) - hReX[1];\nhReX[1] = hReX[0]; hReX[0] = sRe; hReY[1] = hReY[0]; hReY[0] = yRe0; sRe = yRe0;\nlet yRe1 = cRe1 * (sRe + hReY[3]) - hReX[3];\nhReX[3] = hReX[2]; hReX[2] = sRe; hReY[3] = hReY[2]; hReY[2] = yRe1; sRe = yRe1;\nlet yRe2 = cRe2 * (sRe + hReY[5]) - hReX[5];\nhReX[5] = hReX[4]; hReX[4] = sRe; hReY[5] = hReY[4]; hReY[4] = yRe2; sRe = yRe2;\nlet yRe3 = cRe3 * (sRe + hReY[7]) - hReX[7];\nhReX[7] = hReX[6]; hReX[6] = sRe; hReY[7] = hReY[6]; hReY[6] = yRe3;\nlet outRe = hDelRe; hDelRe = yRe3;\n\n// Imaginary path\nlet sIm = isoFund;\nlet yIm0 = cIm0 * (sIm + hImY[1]) - hImX[1];\nhImX[1] = hImX[0]; hImX[0] = sIm; hImY[1] = hImY[0]; hImY[0] = yIm0; sIm = yIm0;\nlet yIm1 = cIm1 * (sIm + hImY[3]) - hImX[3];\nhImX[3] = hImX[2]; hImX[2] = sIm; hImY[3] = hImY[2]; hImY[2] = yIm1; sIm = yIm1;\nlet yIm2 = cIm2 * (sIm + hImY[5]) - hImX[5];\nhImX[5] = hImX[4]; hImX[4] = sIm; hImY[5] = hImY[4]; hImY[4] = yIm2; sIm = yIm2;\nlet yIm3 = cIm3 * (sIm + hImY[7]) - hImX[7];\nhImX[7] = hImX[6]; hImX[6] = sIm; hImY[7] = hImY[6]; hImY[6] = yIm3;\nlet outIm = yIm3;\n\n// With the one-sample delay on the real path, the pair rotates clockwise\n// (theta decreases for positive frequencies), so the imaginary part is negated\n// to make theta increase with time and the frequency estimate positive.\nlet pol = cartopol(outRe, -outIm);\nlet instAmp = pol[0];\nlet theta = pol[1];\n\n// Unwrap single-sample phase difference dTheta in [-pi, pi]\nlet dTheta = theta - prevTheta;\nif (dTheta < -pi) { dTheta += 2.0 * pi; }\nelse if (dTheta > pi) { dTheta -= 2.0 * pi; }\nprevTheta = theta;\n\n// Instantaneous frequency f_inst(t) = (dTheta / (2*pi)) * sr\nlet rawInstHz = (dTheta / (2.0 * pi)) * sr;\n\n// Gate IFT instantaneous frequency: only trust when within +/- 18% of the YIN octave anchor.\n// This follows vibrato/glissandi at the sample rate while making octave errors impossible.\nlet devRatio = abs(rawInstHz - anchorHz) / maximum(anchorHz, 20.0);\nif (devRatio < 0.18 && instAmp > 0.0002) {\n\tlet IFTSlew = 1.0 - exp(-1.0 / (0.0018 * sr));\n\tIFTInstHz += (rawInstHz - IFTInstHz) * IFTSlew;\n} else {\n\tlet anchorSlew = 1.0 - exp(-1.0 / (0.006 * sr));\n\tIFTInstHz += (anchorHz - IFTInstHz) * anchorSlew;\n}\n\n// ============================================================================\n// 5. YIN + IFT CONFIDENCE-WEIGHTED FUSION & PHASE-LOCKED LOOP (PLL) OSCILLATOR\n// (Complementary blend, not a Kalman filter: fixed IFT_speed mix, with YIN\n// confidence scaling how quickly the fused pitch adapts.)\n// ============================================================================\nlet speed = clamp(IFT_speed, 0.0, 1.0);\nlet targetF0 = linearinterp(speed, anchorHz, IFTInstHz);\n\n// Soft confidence weight: 0 at yinConf <= 0.35, ramping to 1 at yinConf >= 0.75.\n// Replaces the old hard yinConf > 0.35 gate so adaptation fades in smoothly.\nlet confW = clamp((yinConf - 0.35) / 0.4, 0.0, 1.0);\n\n// Hold last valid pitch when player stops blowing or confidence is low\n// (no pitch drop on note release).\nif (isPlaying > 0.5 && confW > 0.0) {\n\tlet trackSlew = (1.0 - exp(-1.0 / ((0.010 - 0.0085 * speed) * sr))) * confW;\n\tfusedF0 += (targetF0 - fusedF0) * trackSlew;\n}\nfusedF0 = clamp(fusedF0, min_freq_hz, max_freq_hz);\n\n// Smooth confidence output [0..1]\nlet targetConf = isPlaying * yinConf;\nsmoothConf += (targetConf - smoothConf) * (1.0 - exp(-1.0 / (0.010 * sr)));\n\n// Advance PLL Phasor & gently phase-lock to the analytic phase of the tuba fundamental\nlet targetPh = wrap((theta + pi) / (2.0 * pi), 0.0, 1.0);\nlet phErr = targetPh - pllPhase;\nif (phErr > 0.5) { phErr -= 1.0; }\nelse if (phErr < -0.5) { phErr += 1.0; }\n\nlet pllLockStrength = 0.015 * smoothConf;\npllPhase = wrap(pllPhase + (fusedF0 / sr) + pllLockStrength * phErr, 0.0, 1.0);\n\nout1 = fusedF0;\nout2 = smoothConf;\nout3 = pllPhase;\nout4 = sin(2.0 * pi * pllPhase) * smoothConf;",
                                    "fontface": 0,
                                    "fontname": "<Monospaced>",
                                    "fontsize": 12.0,
                                    "id": "obj-2",
                                    "maxclass": "codebox~",
                                    "numinlets": 3,
                                    "numoutlets": 4,
                                    "outlettype": [ "signal", "signal", "signal", "signal" ],
                                    "patching_rect": [ 30.0, 110.0, 620.0, 360.0 ],
                                    "rnbo_classname": "codebox~",
                                    "rnbo_extra_attributes": {
                                        "nocache": 0,
                                        "expr": "",
                                        "safemath": 1,
                                        "code": "// ============================================================================\n// 00_tuba_freq_tracker.txt\n// Hybrid IFT (Instantaneous Frequency Tracking) + Recursive YIN (CMNDF)\n// + Phase-Locked Loop (PLL) Pitch & Analytic Phasor Tracker for Live Tuba\n// ============================================================================\n// Design rationale (vs. a standalone YinFFT such as fluid.pitch~):\n//   1. YinFFT needs a 2048-to-4096 sample FFT window (~46 to 93 ms at 44.1/48k)\n//      to resolve a 29 Hz pedal Bb0, and only updates once per hop.\n//   2. This tracker combines TWO complementary real-time engines:\n//      (A) YIN (de Cheveigne & Kawahara 2002) whose difference function is\n//          updated recursively over a sliding window (add the newest sample's\n//          term, subtract the term leaving the window) instead of being\n//          recomputed from scratch. Cost per decimated sample is O(maxLag)\n//          (up to ~430 lags), NOT O(1). The CMNDF search is evaluated every\n//          32 audio samples (~0.7 ms hop) with parabolic sub-sample\n//          interpolation and a first-dip search that reduces octave errors.\n//      (B) IFT: an adaptive narrowband SVF pair isolates the fundamental, a\n//          4-stage quadrature IIR Hilbert pair makes the analytic signal, and\n//          d(theta)/dt is taken EVERY SAMPLE, so there is no frame/hop latency\n//          for fast lip bends and vibrato. NOTE: \"no frame latency\" is not\n//          \"zero latency\": the narrow isolating bandpass filters still add\n//          group delay, which grows as the tracked pitch gets lower.\n//   3. A confidence-weighted complementary fusion blends the unambiguous YIN\n//      coarse fundamental with the fast IFT instantaneous frequency, and a\n//      Type-II-style PLL phasor locks to the analytic phase. Outputs are Hz,\n//      confidence, a locked [0..1) phasor, and a fundamental sine wave.\n//\n// What this is NOT:\n//   - It is not a Kalman filter or HMM. There is no covariance, no motion\n//     model and no uncertainty propagation. It is a state-carrying cascade of\n//     smoothers and gates. Confidence scales how fast the fused pitch adapts\n//     (soft ramp), but nothing is propagated as a variance.\n//   - It has no valve or breath priors. The only external prior is the\n//     optional in3 hint, which is averaged 50/50 with YIN. in3 (or a\n//     constraint on the candidate lags) is the natural place to add a\n//     fingering-derived harmonic-series prior later.\n//\n// Known limitations:\n//   - Onset latency at the low end: the default 28 ms YIN window is shorter\n//     than one period of a 28 Hz pedal tone (~36 ms), so the lowest notes are\n//     partly a guess at onset. yin_window_ms can be raised to ~36-40 ms for\n//     more reliable pedal tones, at the cost of extra latency/smoothing. The\n//     window is capped so that window + maxLag fits the 1024-sample buffer\n//     (about 49 ms at 48 kHz with min_freq_hz = 28).\n//   - Sample rates above 48 kHz: decimation is fixed at 4x and maxLag is\n//     capped at 430, so at 96 kHz the lowest trackable pitch rises to roughly\n//     55 Hz. Use 44.1/48 kHz, or raise the buffer sizes and the maxLag cap.\n//   - Changing yin_window_ms while audio runs resets the running sums, so\n//     expect a brief (~one window) dropout in confidence while they refill.\n// ============================================================================\n// Inlets:\n//   in1: Left Audio Input (Tuba)\n//   in2: Right Audio Input (Tuba; if unpatched, mono in1 is used automatically)\n//   in3: Optional External Pitch Hint in Hz (e.g. fluid.pitch~; if 20..1000 Hz,\n//        averaged 50/50 with YIN)\n// Outlets:\n//   out1: Tracked Fundamental Frequency f0 in Hz (audio-rate)\n//   out2: Pitch Confidence / Periodicity [0.0 .. 1.0]\n//   out3: Phase-Locked Tuba Phasor [0.0 .. 1.0) (drop-in replacement for phasor~)\n//   out4: Phase-Locked Fundamental Sine Wave [-1.0 .. 1.0], scaled by confidence\n\n@param({ min: 24.0, max: 120.0 }) min_freq_hz = 28.0;\n@param({ min: 150.0, max: 700.0 }) max_freq_hz = 420.0;\n@param({ min: 0.0, max: 1.0 }) IFT_speed = 0.65;\n@param({ min: -60.0, max: -18.0 }) gate_thresh_db = -42.0;\n@param({ min: 10.0, max: 60.0 }) yin_window_ms = 28.0;\n\n// --- Pre-Conditioning Filters (Isolate 25..450 Hz brass fundamental region) ---\n@state preHp = new svf();\n@state preLp1 = new onepole();\n@state preLp2 = new onepole();\n\n// --- Recursive Sliding YIN (CMNDF) State ---\n// Downsampled by 4x (e.g. 12 kHz at 48 kHz SR) so lags up to 430 cover 28 Hz\n// and up. yinBuf is a 1024-sample circular buffer (window + maxLag must fit).\n@state yinBuf = new FixedSampleArray(1024);\n@state runDiff = new FixedSampleArray(440);\n@state yinWrite: Int = 0;\n@state decCount: Int = 0;\n@state hopCount: Int = 0;\n@state lastWinSize: Int = 0;\n@state yinFreq = 58.27; // Default Bb1\n@state yinConf = 0.0;\n\n// 3-point Median filter history on YIN pitch to reject transient tongue clicks\n@state med0 = 58.27;\n@state med1 = 58.27;\n@state med2 = 58.27;\n\n// --- IFT (Instantaneous Frequency Tracking) State ---\n// Adaptive narrowband SVF tracks the fundamental, followed by a 4-stage Hilbert pair.\n// Each allpass stage is second order in z^-2, so it keeps two past inputs and\n// two past outputs: indices [2k] = value at n-1, [2k+1] = value at n-2.\n@state IFTSvf1 = new svf();\n@state IFTSvf2 = new svf();\n@state hReX = new FixedSampleArray(8);\n@state hReY = new FixedSampleArray(8);\n@state hImX = new FixedSampleArray(8);\n@state hImY = new FixedSampleArray(8);\n@state hDelRe = 0.0;\n@state prevTheta = 0.0;\n@state IFTInstHz = 58.27;\n\n// --- Fusion & Phase-Locked Loop (PLL) State ---\n@state fusedF0 = 58.27;\n@state smoothConf = 0.0;\n@state envRms = 0.0;\n@state pllPhase = 0.0;\n\nlet sr = maximum(samplerate(), 1.0);\nlet xL = in1;\nlet xR = in2;\nlet extHint = in3;\n\n// Sum stereo (or mono if in2 is silent)\nlet rawMono = (abs(xR) > 0.0000001) ? (0.5 * (xL + xR)) : xL;\n\n// ============================================================================\n// 1. RMS ENVELOPE & SILENCE GATE\n// ============================================================================\nlet envCoeff = 1.0 - exp(-1.0 / (0.008 * sr));\nenvRms += (rawMono * rawMono - envRms) * envCoeff;\nlet rmsAmp = sqrt(maximum(envRms, 0.0));\nlet threshLin = dbtoa(clamp(gate_thresh_db, -60.0, -18.0));\nlet isPlaying = (rmsAmp > threshLin) ? 1.0 : 0.0;\n\n// ============================================================================\n// 2. PRE-CONDITIONING FOR RECURSIVE YIN\n// Highpass at 22 Hz (remove breath thumps/DC) + 2-stage lowpass at 260 Hz\n// ============================================================================\nlet hpSig = preHp.next(rawMono, 22.0, 0.707)[1];\nlet condSig = preLp2.next(preLp1.next(hpSig, 260.0), 260.0);\n\n// ============================================================================\n// 3. 4x DECIMATED RECURSIVE YIN (CMNDF) ENGINE\n// ============================================================================\ndecCount = (decCount + 1) % 4;\nif (decCount == 0) {\n\tlet dSr = sr * 0.25;\n\tlet minLag: Int = floor(clamp(dSr / clamp(max_freq_hz, 150.0, 700.0), 12.0, 120.0));\n\tlet maxLag: Int = floor(clamp(dSr / clamp(min_freq_hz, 24.0, 120.0), 130.0, 430.0));\n\n\t// Integration window (yin_window_ms). Capped so winSize + maxLag stays\n\t// inside the 1024-sample circular buffer. Cost is O(maxLag) per decimated\n\t// sample regardless of window length.\n\tlet winSize: Int = floor(clamp(dSr * 0.001 * clamp(yin_window_ms, 10.0, 60.0), 128.0, 1020.0 - maxLag));\n\n\t// The recursive sums are only valid for a fixed window length, so reset\n\t// them if the window length changes (parameter edit or sample-rate change).\n\tif (winSize != lastWinSize) {\n\t\tfor (let i: Int = 0; i < 440; i++) {\n\t\t\trunDiff[i] = 0.0;\n\t\t}\n\t\tlastWinSize = winSize;\n\t}\n\n\tyinBuf[yinWrite] = condSig;\n\tlet oldIdx: Int = (yinWrite - winSize + 1024) % 1024;\n\tlet xNew = condSig;\n\tlet xOld = yinBuf[oldIdx];\n\n\t// Update running squared difference d_t(tau) recursively (O(maxLag) loop)\n\tfor (let tau: Int = 1; tau <= maxLag; tau++) {\n\t\tlet idxNewTau: Int = (yinWrite - tau + 1024) % 1024;\n\t\tlet idxOldTau: Int = (oldIdx - tau + 1024) % 1024;\n\t\tlet diffNew = xNew - yinBuf[idxNewTau];\n\t\tlet diffOld = xOld - yinBuf[idxOldTau];\n\t\tlet updated = runDiff[tau] + diffNew * diffNew - diffOld * diffOld;\n\t\trunDiff[tau] = maximum(updated, 0.0);\n\t}\n\n\t// Evaluate Cumulative Mean Normalized Difference Function d'(tau) every 8 decimated samples (32 audio samples = ~0.7 ms)\n\thopCount = (hopCount + 1) % 8;\n\tif (hopCount == 0 && isPlaying > 0.5) {\n\t\tlet cumSum = 0.0;\n\t\tlet bestTau: Int = minLag;\n\t\tlet bestVal = 10.0;\n\t\tlet thresh = 0.14; // YIN absolute threshold for first subharmonic dip\n\t\tlet foundDip: Int = 0;\n\n\t\tfor (let tau: Int = 1; tau <= maxLag; tau++) {\n\t\t\tcumSum += runDiff[tau];\n\t\t\tlet cmndf = (cumSum > 0.0000001) ? (runDiff[tau] * tau / cumSum) : 1.0;\n\n\t\t\tif (tau >= minLag) {\n\t\t\t\tif (foundDip == 0) {\n\t\t\t\t\tif (cmndf < bestVal) {\n\t\t\t\t\t\tbestVal = cmndf;\n\t\t\t\t\t\tbestTau = tau;\n\t\t\t\t\t}\n\t\t\t\t\t// Once we enter a dip below threshold and start rising, lock to this fundamental!\n\t\t\t\t\t// This favors the first dip over the 2*tau sub-octave while rejecting the 0.5*tau 2nd harmonic\n\t\t\t\t\tif (bestVal < thresh && cmndf > bestVal + 0.02) {\n\t\t\t\t\t\tfoundDip = 1;\n\t\t\t\t\t}\n\t\t\t\t}\n\t\t\t}\n\t\t}\n\n\t\t// Parabolic interpolation around bestTau for sub-sample accuracy\n\t\tlet tauM1: Int = maximum(bestTau - 1, 1);\n\t\tlet tauP1: Int = minimum(bestTau + 1, maxLag);\n\t\tlet y1 = runDiff[tauM1];\n\t\tlet y2 = runDiff[bestTau];\n\t\tlet y3 = runDiff[tauP1];\n\t\tlet denom = 2.0 * (2.0 * y2 - y1 - y3);\n\t\tlet delta = (abs(denom) > 0.0000001) ? clamp((y1 - y3) / denom, -0.5, 0.5) : 0.0;\n\n\t\tlet refinedLag = bestTau + delta;\n\t\tlet rawYinHz = clamp(dSr / refinedLag, min_freq_hz, max_freq_hz);\n\t\tlet rawConf = clamp(1.0 - bestVal, 0.0, 1.0);\n\n\t\t// 3-point median filter to strip brass valve/tongue transient spikes\n\t\tif (rawConf > 0.45) {\n\t\t\tmed2 = med1;\n\t\t\tmed1 = med0;\n\t\t\tmed0 = rawYinHz;\n\t\t\tlet a = med0; let b = med1; let c = med2;\n\t\t\tlet medianHz = maximum(minimum(a, b), minimum(maximum(a, b), c));\n\t\t\tyinFreq = medianHz;\n\t\t}\n\t\tyinConf = rawConf;\n\t}\n\tyinWrite = (yinWrite + 1) % 1024;\n}\n\n// Optional blend with external fluid.pitch~ hint on in3 if user patches it.\n// (Currently a fixed 50/50 average; a fingering-derived prior could replace this.)\nlet anchorHz = (extHint > 20.0 && extHint < 1000.0) ? linearinterp(0.5, yinFreq, extHint) : yinFreq;\n\n// ============================================================================\n// 4. IFT (Instantaneous FREQUENCY TRACKING) ENGINE\n// Isolates the fundamental partial using a dual-stage SVF centered at fusedF0,\n// extracts the analytic signal via a 4-stage quadrature Hilbert transform,\n// and differentiates instantaneous phase d(theta)/dt every single sample.\n// (Per-sample update = no hop latency, but the isolating filters add group delay.)\n// ============================================================================\nlet trackCenter = clamp(fusedF0, min_freq_hz, max_freq_hz);\nlet bp1 = IFTSvf1.next(hpSig, trackCenter, 0.86)[2];\nlet isoFund = IFTSvf2.next(bp1, trackCenter, 0.86)[2];\n\n// 4-Stage Quadrature IIR Hilbert Allpass Pair (polyphase design).\n// Coefficients are the squared values of a standard 4+4 polyphase IIR Hilbert\n// set. They MUST be used in a z^-2 allpass, H(z) = (c - z^-2) / (1 - c*z^-2),\n// i.e. y[n] = c*(x[n] + y[n-2]) - x[n-2], with the real path delayed by one\n// sample. (A z^-1 section, or the opposite sign, gives ~0 degrees of phase\n// difference between the two paths at 28..420 Hz, i.e. no quadrature at all.)\n// Verified numerically at 44.1/48 kHz: phase difference is -90 deg +/- ~1 deg\n// across 28..420 Hz, and recovered frequency matches the input sine.\nlet cRe0 = 0.4794008656; let cRe1 = 0.8762184935; let cRe2 = 0.9765975895; let cRe3 = 0.9974992559;\nlet cIm0 = 0.1617584983; let cIm1 = 0.7330289323; let cIm2 = 0.9453497003; let cIm3 = 0.9905991567;\n\n// Real path (delayed one sample at the end)\nlet sRe = isoFund;\nlet yRe0 = cRe0 * (sRe + hReY[1]) - hReX[1];\nhReX[1] = hReX[0]; hReX[0] = sRe; hReY[1] = hReY[0]; hReY[0] = yRe0; sRe = yRe0;\nlet yRe1 = cRe1 * (sRe + hReY[3]) - hReX[3];\nhReX[3] = hReX[2]; hReX[2] = sRe; hReY[3] = hReY[2]; hReY[2] = yRe1; sRe = yRe1;\nlet yRe2 = cRe2 * (sRe + hReY[5]) - hReX[5];\nhReX[5] = hReX[4]; hReX[4] = sRe; hReY[5] = hReY[4]; hReY[4] = yRe2; sRe = yRe2;\nlet yRe3 = cRe3 * (sRe + hReY[7]) - hReX[7];\nhReX[7] = hReX[6]; hReX[6] = sRe; hReY[7] = hReY[6]; hReY[6] = yRe3;\nlet outRe = hDelRe; hDelRe = yRe3;\n\n// Imaginary path\nlet sIm = isoFund;\nlet yIm0 = cIm0 * (sIm + hImY[1]) - hImX[1];\nhImX[1] = hImX[0]; hImX[0] = sIm; hImY[1] = hImY[0]; hImY[0] = yIm0; sIm = yIm0;\nlet yIm1 = cIm1 * (sIm + hImY[3]) - hImX[3];\nhImX[3] = hImX[2]; hImX[2] = sIm; hImY[3] = hImY[2]; hImY[2] = yIm1; sIm = yIm1;\nlet yIm2 = cIm2 * (sIm + hImY[5]) - hImX[5];\nhImX[5] = hImX[4]; hImX[4] = sIm; hImY[5] = hImY[4]; hImY[4] = yIm2; sIm = yIm2;\nlet yIm3 = cIm3 * (sIm + hImY[7]) - hImX[7];\nhImX[7] = hImX[6]; hImX[6] = sIm; hImY[7] = hImY[6]; hImY[6] = yIm3;\nlet outIm = yIm3;\n\n// With the one-sample delay on the real path, the pair rotates clockwise\n// (theta decreases for positive frequencies), so the imaginary part is negated\n// to make theta increase with time and the frequency estimate positive.\nlet pol = cartopol(outRe, -outIm);\nlet instAmp = pol[0];\nlet theta = pol[1];\n\n// Unwrap single-sample phase difference dTheta in [-pi, pi]\nlet dTheta = theta - prevTheta;\nif (dTheta < -pi) { dTheta += 2.0 * pi; }\nelse if (dTheta > pi) { dTheta -= 2.0 * pi; }\nprevTheta = theta;\n\n// Instantaneous frequency f_inst(t) = (dTheta / (2*pi)) * sr\nlet rawInstHz = (dTheta / (2.0 * pi)) * sr;\n\n// Gate IFT instantaneous frequency: only trust when within +/- 18% of the YIN octave anchor.\n// This follows vibrato/glissandi at the sample rate while making octave errors impossible.\nlet devRatio = abs(rawInstHz - anchorHz) / maximum(anchorHz, 20.0);\nif (devRatio < 0.18 && instAmp > 0.0002) {\n\tlet IFTSlew = 1.0 - exp(-1.0 / (0.0018 * sr));\n\tIFTInstHz += (rawInstHz - IFTInstHz) * IFTSlew;\n} else {\n\tlet anchorSlew = 1.0 - exp(-1.0 / (0.006 * sr));\n\tIFTInstHz += (anchorHz - IFTInstHz) * anchorSlew;\n}\n\n// ============================================================================\n// 5. YIN + IFT CONFIDENCE-WEIGHTED FUSION & PHASE-LOCKED LOOP (PLL) OSCILLATOR\n// (Complementary blend, not a Kalman filter: fixed IFT_speed mix, with YIN\n// confidence scaling how quickly the fused pitch adapts.)\n// ============================================================================\nlet speed = clamp(IFT_speed, 0.0, 1.0);\nlet targetF0 = linearinterp(speed, anchorHz, IFTInstHz);\n\n// Soft confidence weight: 0 at yinConf <= 0.35, ramping to 1 at yinConf >= 0.75.\n// Replaces the old hard yinConf > 0.35 gate so adaptation fades in smoothly.\nlet confW = clamp((yinConf - 0.35) / 0.4, 0.0, 1.0);\n\n// Hold last valid pitch when player stops blowing or confidence is low\n// (no pitch drop on note release).\nif (isPlaying > 0.5 && confW > 0.0) {\n\tlet trackSlew = (1.0 - exp(-1.0 / ((0.010 - 0.0085 * speed) * sr))) * confW;\n\tfusedF0 += (targetF0 - fusedF0) * trackSlew;\n}\nfusedF0 = clamp(fusedF0, min_freq_hz, max_freq_hz);\n\n// Smooth confidence output [0..1]\nlet targetConf = isPlaying * yinConf;\nsmoothConf += (targetConf - smoothConf) * (1.0 - exp(-1.0 / (0.010 * sr)));\n\n// Advance PLL Phasor & gently phase-lock to the analytic phase of the tuba fundamental\nlet targetPh = wrap((theta + pi) / (2.0 * pi), 0.0, 1.0);\nlet phErr = targetPh - pllPhase;\nif (phErr > 0.5) { phErr -= 1.0; }\nelse if (phErr < -0.5) { phErr += 1.0; }\n\nlet pllLockStrength = 0.015 * smoothConf;\npllPhase = wrap(pllPhase + (fusedF0 / sr) + pllLockStrength * phErr, 0.0, 1.0);\n\nout1 = fusedF0;\nout2 = smoothConf;\nout3 = pllPhase;\nout4 = sin(2.0 * pi * pllPhase) * smoothConf;"
                                    },
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "effect_code",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "reset": {
                                                "attrOrProp": 1,
                                                "digest": "Reset all state and params to initial values",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            },
                                            "in1": {
                                                "attrOrProp": 1,
                                                "digest": "in1",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "number"
                                            },
                                            "in2": {
                                                "attrOrProp": 1,
                                                "digest": "in2",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "number"
                                            },
                                            "in3": {
                                                "attrOrProp": 1,
                                                "digest": "in3",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "number"
                                            },
                                            "out1": {
                                                "attrOrProp": 1,
                                                "digest": "out1",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
                                            },
                                            "out2": {
                                                "attrOrProp": 1,
                                                "digest": "out2",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
                                            },
                                            "out3": {
                                                "attrOrProp": 1,
                                                "digest": "out3",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
                                            },
                                            "out4": {
                                                "attrOrProp": 1,
                                                "digest": "out4",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
                                            },
                                            "min_freq_hz": {
                                                "attrOrProp": 1,
                                                "digest": "min_freq_hz",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "28"
                                            },
                                            "max_freq_hz": {
                                                "attrOrProp": 1,
                                                "digest": "max_freq_hz",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "420"
                                            },
                                            "IFT_speed": {
                                                "attrOrProp": 1,
                                                "digest": "IFT_speed",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "0.65"
                                            },
                                            "gate_thresh_db": {
                                                "attrOrProp": 1,
                                                "digest": "gate_thresh_db",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "-42"
                                            },
                                            "yin_window_ms": {
                                                "attrOrProp": 1,
                                                "digest": "yin_window_ms",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "28"
                                            },
                                            "expr": {
                                                "attrOrProp": 2,
                                                "digest": "expr",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol"
                                            },
                                            "safemath": {
                                                "attrOrProp": 2,
                                                "digest": "Use safe math expressions (e.g.: division by 0 will not crash).",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "true"
                                            },
                                            "nocache": {
                                                "attrOrProp": 2,
                                                "digest": "Do not use parsing cache. This is only useful with very very big code sizes. Code generation will then take a looooong time.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "false"
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "in1",
                                                "type": "auto",
                                                "digest": "in1",
                                                "hot": 1,
                                                "docked": 0
                                            },
                                            {
                                                "name": "in2",
                                                "type": "auto",
                                                "digest": "in2",
                                                "docked": 0
                                            },
                                            {
                                                "name": "in3",
                                                "type": "auto",
                                                "digest": "in3",
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "out1",
                                                "type": "signal",
                                                "digest": "out1",
                                                "docked": 0
                                            },
                                            {
                                                "name": "out2",
                                                "type": "signal",
                                                "digest": "out2",
                                                "docked": 0
                                            },
                                            {
                                                "name": "out3",
                                                "type": "signal",
                                                "digest": "out3",
                                                "docked": 0
                                            },
                                            {
                                                "name": "out4",
                                                "type": "signal",
                                                "digest": "out4",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "codebox~",
                                        "aliasOf": "expr~",
                                        "classname": "codebox~",
                                        "operator": 0,
                                        "versionId": 527839773,
                                        "changesPatcherIO": 0
                                    },
                                    "varname": "effect_code"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-3",
                                    "maxclass": "newobj",
                                    "numinlets": 0,
                                    "numoutlets": 1,
                                    "outlettype": [ "signal" ],
                                    "patching_rect": [ 30.0, 70.0, 70.0, 23.0 ],
                                    "rnbo_classname": "in~",
                                    "rnbo_extra_attributes": {
                                        "comment": "",
                                        "meta": ""
                                    },
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "audio_in_1",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "out1": {
                                                "attrOrProp": 1,
                                                "digest": "signal from inlet with index 1",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
                                            },
                                            "index": {
                                                "attrOrProp": 2,
                                                "digest": "inlet number",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "mandatory": 1
                                            },
                                            "comment": {
                                                "attrOrProp": 2,
                                                "digest": "mouse over comment",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol"
                                            },
                                            "meta": {
                                                "attrOrProp": 2,
                                                "digest": "A JSON formatted string containing metadata for use by the exported code",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Metadata",
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [],
                                        "outputs": [
                                            {
                                                "name": "out1",
                                                "type": "signal",
                                                "digest": "signal from inlet with index 1",
                                                "displayName": "",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "in~",
                                        "aliasOf": "in~",
                                        "classname": "in~",
                                        "operator": 0,
                                        "versionId": -1654556303,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "in~ 1",
                                    "varname": "audio_in_1"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-4",
                                    "maxclass": "newobj",
                                    "numinlets": 0,
                                    "numoutlets": 1,
                                    "outlettype": [ "signal" ],
                                    "patching_rect": [ 317.5, 70.0, 70.0, 23.0 ],
                                    "rnbo_classname": "in~",
                                    "rnbo_extra_attributes": {
                                        "comment": "",
                                        "meta": ""
                                    },
                                    "rnbo_serial": 2,
                                    "rnbo_uniqueid": "audio_in_2",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "out1": {
                                                "attrOrProp": 1,
                                                "digest": "signal from inlet with index 2",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
                                            },
                                            "index": {
                                                "attrOrProp": 2,
                                                "digest": "inlet number",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "mandatory": 1
                                            },
                                            "comment": {
                                                "attrOrProp": 2,
                                                "digest": "mouse over comment",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol"
                                            },
                                            "meta": {
                                                "attrOrProp": 2,
                                                "digest": "A JSON formatted string containing metadata for use by the exported code",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Metadata",
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [],
                                        "outputs": [
                                            {
                                                "name": "out1",
                                                "type": "signal",
                                                "digest": "signal from inlet with index 2",
                                                "displayName": "",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "in~",
                                        "aliasOf": "in~",
                                        "classname": "in~",
                                        "operator": 0,
                                        "versionId": -1654556303,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "in~ 2",
                                    "varname": "audio_in_2"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-5",
                                    "maxclass": "newobj",
                                    "numinlets": 0,
                                    "numoutlets": 1,
                                    "outlettype": [ "signal" ],
                                    "patching_rect": [ 605.0, 70.0, 70.0, 23.0 ],
                                    "rnbo_classname": "in~",
                                    "rnbo_extra_attributes": {
                                        "comment": "",
                                        "meta": ""
                                    },
                                    "rnbo_serial": 3,
                                    "rnbo_uniqueid": "audio_in_3",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "out1": {
                                                "attrOrProp": 1,
                                                "digest": "signal from inlet with index 3",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "signal"
                                            },
                                            "index": {
                                                "attrOrProp": 2,
                                                "digest": "inlet number",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "mandatory": 1
                                            },
                                            "comment": {
                                                "attrOrProp": 2,
                                                "digest": "mouse over comment",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol"
                                            },
                                            "meta": {
                                                "attrOrProp": 2,
                                                "digest": "A JSON formatted string containing metadata for use by the exported code",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Metadata",
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [],
                                        "outputs": [
                                            {
                                                "name": "out1",
                                                "type": "signal",
                                                "digest": "signal from inlet with index 3",
                                                "displayName": "",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "in~",
                                        "aliasOf": "in~",
                                        "classname": "in~",
                                        "operator": 0,
                                        "versionId": -1654556303,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "in~ 3",
                                    "varname": "audio_in_3"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-6",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 30.0, 520.0, 70.0, 23.0 ],
                                    "rnbo_classname": "out~",
                                    "rnbo_extra_attributes": {
                                        "comment": "",
                                        "meta": ""
                                    },
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "audio_out_1",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "in1": {
                                                "attrOrProp": 1,
                                                "digest": "signal sent to outlet with index 1",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "signal"
                                            },
                                            "index": {
                                                "attrOrProp": 2,
                                                "digest": "outlet number",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "mandatory": 1
                                            },
                                            "comment": {
                                                "attrOrProp": 2,
                                                "digest": "mouse over comment",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol"
                                            },
                                            "meta": {
                                                "attrOrProp": 2,
                                                "digest": "A JSON formatted string containing metadata for use by the exported code",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Metadata",
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "in1",
                                                "type": "signal",
                                                "digest": "signal sent to outlet with index 1",
                                                "displayName": "",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [],
                                        "helpname": "out~",
                                        "aliasOf": "out~",
                                        "classname": "out~",
                                        "operator": 0,
                                        "versionId": 1989326771,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "out~ 1",
                                    "varname": "audio_out_1"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-7",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 221.66666666666666, 520.0, 70.0, 23.0 ],
                                    "rnbo_classname": "out~",
                                    "rnbo_extra_attributes": {
                                        "comment": "",
                                        "meta": ""
                                    },
                                    "rnbo_serial": 2,
                                    "rnbo_uniqueid": "audio_out_2",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "in1": {
                                                "attrOrProp": 1,
                                                "digest": "signal sent to outlet with index 2",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "signal"
                                            },
                                            "index": {
                                                "attrOrProp": 2,
                                                "digest": "outlet number",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "mandatory": 1
                                            },
                                            "comment": {
                                                "attrOrProp": 2,
                                                "digest": "mouse over comment",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol"
                                            },
                                            "meta": {
                                                "attrOrProp": 2,
                                                "digest": "A JSON formatted string containing metadata for use by the exported code",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Metadata",
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "in1",
                                                "type": "signal",
                                                "digest": "signal sent to outlet with index 2",
                                                "displayName": "",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [],
                                        "helpname": "out~",
                                        "aliasOf": "out~",
                                        "classname": "out~",
                                        "operator": 0,
                                        "versionId": 1989326771,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "out~ 2",
                                    "varname": "audio_out_2"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-8",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 413.3333333333333, 520.0, 70.0, 23.0 ],
                                    "rnbo_classname": "out~",
                                    "rnbo_extra_attributes": {
                                        "comment": "",
                                        "meta": ""
                                    },
                                    "rnbo_serial": 3,
                                    "rnbo_uniqueid": "audio_out_3",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "in1": {
                                                "attrOrProp": 1,
                                                "digest": "signal sent to outlet with index 3",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "signal"
                                            },
                                            "index": {
                                                "attrOrProp": 2,
                                                "digest": "outlet number",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "mandatory": 1
                                            },
                                            "comment": {
                                                "attrOrProp": 2,
                                                "digest": "mouse over comment",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol"
                                            },
                                            "meta": {
                                                "attrOrProp": 2,
                                                "digest": "A JSON formatted string containing metadata for use by the exported code",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Metadata",
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "in1",
                                                "type": "signal",
                                                "digest": "signal sent to outlet with index 3",
                                                "displayName": "",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [],
                                        "helpname": "out~",
                                        "aliasOf": "out~",
                                        "classname": "out~",
                                        "operator": 0,
                                        "versionId": 1989326771,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "out~ 3",
                                    "varname": "audio_out_3"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-9",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 605.0, 520.0, 70.0, 23.0 ],
                                    "rnbo_classname": "out~",
                                    "rnbo_extra_attributes": {
                                        "comment": "",
                                        "meta": ""
                                    },
                                    "rnbo_serial": 4,
                                    "rnbo_uniqueid": "audio_out_4",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "in1": {
                                                "attrOrProp": 1,
                                                "digest": "signal sent to outlet with index 4",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 0,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "signal"
                                            },
                                            "index": {
                                                "attrOrProp": 2,
                                                "digest": "outlet number",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "mandatory": 1
                                            },
                                            "comment": {
                                                "attrOrProp": 2,
                                                "digest": "mouse over comment",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol"
                                            },
                                            "meta": {
                                                "attrOrProp": 2,
                                                "digest": "A JSON formatted string containing metadata for use by the exported code",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Metadata",
                                                "displayorder": 3
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "in1",
                                                "type": "signal",
                                                "digest": "signal sent to outlet with index 4",
                                                "displayName": "",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [],
                                        "helpname": "out~",
                                        "aliasOf": "out~",
                                        "classname": "out~",
                                        "operator": 0,
                                        "versionId": 1989326771,
                                        "changesPatcherIO": 1
                                    },
                                    "text": "out~ 4",
                                    "varname": "audio_out_4"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-10",
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 700.0, 65.0, 175.0, 21.0 ],
                                    "text": "min_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-11",
                                    "maxclass": "flonum",
                                    "numinlets": 1,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "bang" ],
                                    "parameter_enable": 0,
                                    "patching_rect": [ 700.0, 115.0, 100.0, 23.0 ],
                                    "rnbo_classname": "number",
                                    "rnbo_extra_attributes": {
                                        "order": "",
                                        "maximum": "<none>",
                                        "minimum": "<none>",
                                        "preset": 0,
                                        "initialFormat": "float"
                                    },
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "value_min_freq_hz",
                                    "varname": "value_min_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-12",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 700.0, 143.0, 175.0, 23.0 ],
                                    "rnbo_classname": "setparam",
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "set_min_freq_hz",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "name": {
                                                "attrOrProp": 2,
                                                "digest": "attribute/param to control",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "mandatory": 1
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "attribute or parameter value (bang, number, list)",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "output",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "connect to first inlet of gen or subpatcher",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "set",
                                        "aliasOf": "set",
                                        "classname": "setparam",
                                        "operator": 0,
                                        "versionId": 1197449671,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "setparam min_freq_hz",
                                    "varname": "set_min_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-13",
                                    "maxclass": "newobj",
                                    "numinlets": 2,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "" ],
                                    "patching_rect": [ 700.0, 92.0, 258.0, 23.0 ],
                                    "rnbo_classname": "param",
                                    "rnbo_extra_attributes": {
                                        "sendinit": 1,
                                        "order": "0",
                                        "tonormalized": "",
                                        "displayorder": "-",
                                        "exponent": 1.0,
                                        "preset": 1,
                                        "meta": "",
                                        "fromnormalized": "",
                                        "enum": "",
                                        "displayname": "",
                                        "steps": 0.0,
                                        "ctlin": 0.0,
                                        "unit": ""
                                    },
                                    "rnbo_serial": 1,
                                    "rnbo_uniqueid": "min_freq_hz",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "value": {
                                                "attrOrProp": 2,
                                                "digest": "Set initial value",
                                                "defaultarg": 2,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "28",
                                                "label": "Initial Value",
                                                "displayorder": 3
                                            },
                                            "normalizedvalue": {
                                                "attrOrProp": 1,
                                                "digest": "Set value normalized. ",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "number"
                                            },
                                            "reset": {
                                                "attrOrProp": 1,
                                                "digest": "Reset param to initial value",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            },
                                            "normalized": {
                                                "attrOrProp": 1,
                                                "digest": "Normalized parameter value.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "number"
                                            },
                                            "name": {
                                                "attrOrProp": 2,
                                                "digest": "Name of the parameter",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "Parameter Name",
                                                "mandatory": 1
                                            },
                                            "enum": {
                                                "attrOrProp": 2,
                                                "digest": "Use an enumerated output",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "list",
                                                "label": "Enum Values",
                                                "displayorder": 6
                                            },
                                            "minimum": {
                                                "attrOrProp": 2,
                                                "digest": "Minimum value",
                                                "isalias": 0,
                                                "aliases": [ "min" ],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "24",
                                                "label": "Minimum",
                                                "displayorder": 1
                                            },
                                            "min": {
                                                "attrOrProp": 2,
                                                "digest": "Minimum value",
                                                "isalias": 1,
                                                "aliasOf": "minimum",
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "24",
                                                "label": "Minimum",
                                                "displayorder": 1
                                            },
                                            "maximum": {
                                                "attrOrProp": 2,
                                                "digest": "Maximum value",
                                                "isalias": 0,
                                                "aliases": [ "max" ],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "120",
                                                "label": "Maximum",
                                                "displayorder": 2
                                            },
                                            "max": {
                                                "attrOrProp": 2,
                                                "digest": "Maximum value",
                                                "isalias": 1,
                                                "aliasOf": "maximum",
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "120",
                                                "label": "Maximum",
                                                "displayorder": 2
                                            },
                                            "exponent": {
                                                "attrOrProp": 2,
                                                "digest": "Scale values exponentially",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "1",
                                                "label": "Exponent",
                                                "displayorder": 7
                                            },
                                            "steps": {
                                                "attrOrProp": 2,
                                                "digest": "Divide the output into a number of discrete steps",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "0",
                                                "label": "Steps",
                                                "displayorder": 8
                                            },
                                            "displayName": {
                                                "attrOrProp": 2,
                                                "digest": "DEPRECATED: Use the lower case 'displayname' instead",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 1,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "Display Name"
                                            },
                                            "displayname": {
                                                "attrOrProp": 2,
                                                "digest": "A more readable name for the parameter in an external RNBO target",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Display Name",
                                                "displayorder": 14
                                            },
                                            "unit": {
                                                "attrOrProp": 2,
                                                "digest": "A symbol to describe the unit of the parameter in an external RNBO target",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Unit",
                                                "displayorder": 15
                                            },
                                            "tonormalized": {
                                                "attrOrProp": 2,
                                                "digest": "Converts a real parameter value to its normalized form",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "To Normalized Expression",
                                                "displayorder": 10
                                            },
                                            "fromnormalized": {
                                                "attrOrProp": 2,
                                                "digest": "Converts a normalized parameter into its actual parameter value",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "From Normalized Expression",
                                                "displayorder": 9
                                            },
                                            "order": {
                                                "attrOrProp": 2,
                                                "digest": "Order in which initial parameter values will be sent out on patcher load. The order can be numeric or symbolic ('first' and 'last')",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "0",
                                                "label": "Restore Order",
                                                "displayorder": 12
                                            },
                                            "displayorder": {
                                                "attrOrProp": 2,
                                                "digest": "Order in which parameters will show up in a list of all parameters. The order can be numeric or symbolic ('first' and 'last')",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "-",
                                                "label": "Display Order",
                                                "displayorder": 13
                                            },
                                            "sendinit": {
                                                "attrOrProp": 2,
                                                "digest": "Send initial value",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "true",
                                                "label": "Send Init",
                                                "displayorder": 4
                                            },
                                            "ctlin": {
                                                "attrOrProp": 2,
                                                "digest": "MIDI controller number to control this parameter.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "-1",
                                                "label": "MIDI Controller Number.",
                                                "displayorder": 16
                                            },
                                            "meta": {
                                                "attrOrProp": 2,
                                                "digest": "A JSON formatted string containing metadata for use by the exported code",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Metadata",
                                                "displayorder": 17
                                            },
                                            "nopreset": {
                                                "attrOrProp": 2,
                                                "digest": "Do not add this value to the preset [DEPRECATED - USE @preset 0 instead].",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 1,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "false"
                                            },
                                            "preset": {
                                                "attrOrProp": 2,
                                                "digest": "Add this value to the preset.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "true",
                                                "label": "Include In Preset",
                                                "displayorder": 11
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "value",
                                                "type": "number",
                                                "digest": "Parameter value",
                                                "defaultarg": 2,
                                                "hot": 1,
                                                "docked": 0
                                            },
                                            {
                                                "name": "normalizedvalue",
                                                "type": "number",
                                                "digest": "Set value normalized. ",
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "value",
                                                "type": "number",
                                                "digest": "Parameter value",
                                                "defaultarg": 2,
                                                "hot": 1,
                                                "docked": 0
                                            },
                                            {
                                                "name": "normalized",
                                                "type": "number",
                                                "digest": "Normalized parameter value.",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "param",
                                        "aliasOf": "param",
                                        "classname": "param",
                                        "operator": 0,
                                        "versionId": -1093178486,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "param min_freq_hz 28 @min 24 @max 120",
                                    "varname": "min_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-14",
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 989.0, 65.0, 175.0, 21.0 ],
                                    "text": "max_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-15",
                                    "maxclass": "flonum",
                                    "numinlets": 1,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "bang" ],
                                    "parameter_enable": 0,
                                    "patching_rect": [ 989.0, 115.0, 100.0, 23.0 ],
                                    "rnbo_classname": "number",
                                    "rnbo_extra_attributes": {
                                        "order": "",
                                        "maximum": "<none>",
                                        "minimum": "<none>",
                                        "preset": 0,
                                        "initialFormat": "float"
                                    },
                                    "rnbo_serial": 2,
                                    "rnbo_uniqueid": "value_max_freq_hz",
                                    "varname": "value_max_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-16",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 989.0, 143.0, 175.0, 23.0 ],
                                    "rnbo_classname": "setparam",
                                    "rnbo_serial": 2,
                                    "rnbo_uniqueid": "set_max_freq_hz",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "name": {
                                                "attrOrProp": 2,
                                                "digest": "attribute/param to control",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "mandatory": 1
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "attribute or parameter value (bang, number, list)",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "output",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "connect to first inlet of gen or subpatcher",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "set",
                                        "aliasOf": "set",
                                        "classname": "setparam",
                                        "operator": 0,
                                        "versionId": 1197449671,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "setparam max_freq_hz",
                                    "varname": "set_max_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-17",
                                    "maxclass": "newobj",
                                    "numinlets": 2,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "" ],
                                    "patching_rect": [ 989.0, 92.0, 272.0, 23.0 ],
                                    "rnbo_classname": "param",
                                    "rnbo_extra_attributes": {
                                        "sendinit": 1,
                                        "order": "0",
                                        "tonormalized": "",
                                        "displayorder": "-",
                                        "exponent": 1.0,
                                        "preset": 1,
                                        "meta": "",
                                        "fromnormalized": "",
                                        "enum": "",
                                        "displayname": "",
                                        "steps": 0.0,
                                        "ctlin": 0.0,
                                        "unit": ""
                                    },
                                    "rnbo_serial": 2,
                                    "rnbo_uniqueid": "max_freq_hz",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "value": {
                                                "attrOrProp": 2,
                                                "digest": "Set initial value",
                                                "defaultarg": 2,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "420",
                                                "label": "Initial Value",
                                                "displayorder": 3
                                            },
                                            "normalizedvalue": {
                                                "attrOrProp": 1,
                                                "digest": "Set value normalized. ",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "number"
                                            },
                                            "reset": {
                                                "attrOrProp": 1,
                                                "digest": "Reset param to initial value",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            },
                                            "normalized": {
                                                "attrOrProp": 1,
                                                "digest": "Normalized parameter value.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "number"
                                            },
                                            "name": {
                                                "attrOrProp": 2,
                                                "digest": "Name of the parameter",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "Parameter Name",
                                                "mandatory": 1
                                            },
                                            "enum": {
                                                "attrOrProp": 2,
                                                "digest": "Use an enumerated output",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "list",
                                                "label": "Enum Values",
                                                "displayorder": 6
                                            },
                                            "minimum": {
                                                "attrOrProp": 2,
                                                "digest": "Minimum value",
                                                "isalias": 0,
                                                "aliases": [ "min" ],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "150",
                                                "label": "Minimum",
                                                "displayorder": 1
                                            },
                                            "min": {
                                                "attrOrProp": 2,
                                                "digest": "Minimum value",
                                                "isalias": 1,
                                                "aliasOf": "minimum",
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "150",
                                                "label": "Minimum",
                                                "displayorder": 1
                                            },
                                            "maximum": {
                                                "attrOrProp": 2,
                                                "digest": "Maximum value",
                                                "isalias": 0,
                                                "aliases": [ "max" ],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "700",
                                                "label": "Maximum",
                                                "displayorder": 2
                                            },
                                            "max": {
                                                "attrOrProp": 2,
                                                "digest": "Maximum value",
                                                "isalias": 1,
                                                "aliasOf": "maximum",
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "700",
                                                "label": "Maximum",
                                                "displayorder": 2
                                            },
                                            "exponent": {
                                                "attrOrProp": 2,
                                                "digest": "Scale values exponentially",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "1",
                                                "label": "Exponent",
                                                "displayorder": 7
                                            },
                                            "steps": {
                                                "attrOrProp": 2,
                                                "digest": "Divide the output into a number of discrete steps",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "0",
                                                "label": "Steps",
                                                "displayorder": 8
                                            },
                                            "displayName": {
                                                "attrOrProp": 2,
                                                "digest": "DEPRECATED: Use the lower case 'displayname' instead",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 1,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "Display Name"
                                            },
                                            "displayname": {
                                                "attrOrProp": 2,
                                                "digest": "A more readable name for the parameter in an external RNBO target",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Display Name",
                                                "displayorder": 14
                                            },
                                            "unit": {
                                                "attrOrProp": 2,
                                                "digest": "A symbol to describe the unit of the parameter in an external RNBO target",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Unit",
                                                "displayorder": 15
                                            },
                                            "tonormalized": {
                                                "attrOrProp": 2,
                                                "digest": "Converts a real parameter value to its normalized form",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "To Normalized Expression",
                                                "displayorder": 10
                                            },
                                            "fromnormalized": {
                                                "attrOrProp": 2,
                                                "digest": "Converts a normalized parameter into its actual parameter value",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "From Normalized Expression",
                                                "displayorder": 9
                                            },
                                            "order": {
                                                "attrOrProp": 2,
                                                "digest": "Order in which initial parameter values will be sent out on patcher load. The order can be numeric or symbolic ('first' and 'last')",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "0",
                                                "label": "Restore Order",
                                                "displayorder": 12
                                            },
                                            "displayorder": {
                                                "attrOrProp": 2,
                                                "digest": "Order in which parameters will show up in a list of all parameters. The order can be numeric or symbolic ('first' and 'last')",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "-",
                                                "label": "Display Order",
                                                "displayorder": 13
                                            },
                                            "sendinit": {
                                                "attrOrProp": 2,
                                                "digest": "Send initial value",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "true",
                                                "label": "Send Init",
                                                "displayorder": 4
                                            },
                                            "ctlin": {
                                                "attrOrProp": 2,
                                                "digest": "MIDI controller number to control this parameter.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "-1",
                                                "label": "MIDI Controller Number.",
                                                "displayorder": 16
                                            },
                                            "meta": {
                                                "attrOrProp": 2,
                                                "digest": "A JSON formatted string containing metadata for use by the exported code",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Metadata",
                                                "displayorder": 17
                                            },
                                            "nopreset": {
                                                "attrOrProp": 2,
                                                "digest": "Do not add this value to the preset [DEPRECATED - USE @preset 0 instead].",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 1,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "false"
                                            },
                                            "preset": {
                                                "attrOrProp": 2,
                                                "digest": "Add this value to the preset.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "true",
                                                "label": "Include In Preset",
                                                "displayorder": 11
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "value",
                                                "type": "number",
                                                "digest": "Parameter value",
                                                "defaultarg": 2,
                                                "hot": 1,
                                                "docked": 0
                                            },
                                            {
                                                "name": "normalizedvalue",
                                                "type": "number",
                                                "digest": "Set value normalized. ",
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "value",
                                                "type": "number",
                                                "digest": "Parameter value",
                                                "defaultarg": 2,
                                                "hot": 1,
                                                "docked": 0
                                            },
                                            {
                                                "name": "normalized",
                                                "type": "number",
                                                "digest": "Normalized parameter value.",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "param",
                                        "aliasOf": "param",
                                        "classname": "param",
                                        "operator": 0,
                                        "versionId": -1093178486,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "param max_freq_hz 420 @min 150 @max 700",
                                    "varname": "max_freq_hz"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-18",
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 1285.0, 65.0, 175.0, 21.0 ],
                                    "text": "IFT_speed"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-19",
                                    "maxclass": "flonum",
                                    "numinlets": 1,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "bang" ],
                                    "parameter_enable": 0,
                                    "patching_rect": [ 1285.0, 115.0, 100.0, 23.0 ],
                                    "rnbo_classname": "number",
                                    "rnbo_extra_attributes": {
                                        "order": "",
                                        "maximum": "<none>",
                                        "minimum": "<none>",
                                        "preset": 0,
                                        "initialFormat": "float"
                                    },
                                    "rnbo_serial": 3,
                                    "rnbo_uniqueid": "value_IFT_speed",
                                    "varname": "value_IFT_speed"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-20",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 1285.0, 143.0, 175.0, 23.0 ],
                                    "rnbo_classname": "setparam",
                                    "rnbo_serial": 3,
                                    "rnbo_uniqueid": "set_IFT_speed",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "name": {
                                                "attrOrProp": 2,
                                                "digest": "attribute/param to control",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "mandatory": 1
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "attribute or parameter value (bang, number, list)",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "output",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "connect to first inlet of gen or subpatcher",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "set",
                                        "aliasOf": "set",
                                        "classname": "setparam",
                                        "operator": 0,
                                        "versionId": 1197449671,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "setparam IFT_speed",
                                    "varname": "set_IFT_speed"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-21",
                                    "maxclass": "newobj",
                                    "numinlets": 2,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "" ],
                                    "patching_rect": [ 1285.0, 92.0, 239.0, 23.0 ],
                                    "rnbo_classname": "param",
                                    "rnbo_extra_attributes": {
                                        "sendinit": 1,
                                        "order": "0",
                                        "tonormalized": "",
                                        "displayorder": "-",
                                        "exponent": 1.0,
                                        "preset": 1,
                                        "meta": "",
                                        "fromnormalized": "",
                                        "enum": "",
                                        "displayname": "",
                                        "steps": 0.0,
                                        "ctlin": 0.0,
                                        "unit": ""
                                    },
                                    "rnbo_serial": 3,
                                    "rnbo_uniqueid": "IFT_speed",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "value": {
                                                "attrOrProp": 2,
                                                "digest": "Set initial value",
                                                "defaultarg": 2,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "0.65",
                                                "label": "Initial Value",
                                                "displayorder": 3
                                            },
                                            "normalizedvalue": {
                                                "attrOrProp": 1,
                                                "digest": "Set value normalized. ",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "number"
                                            },
                                            "reset": {
                                                "attrOrProp": 1,
                                                "digest": "Reset param to initial value",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            },
                                            "normalized": {
                                                "attrOrProp": 1,
                                                "digest": "Normalized parameter value.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "number"
                                            },
                                            "name": {
                                                "attrOrProp": 2,
                                                "digest": "Name of the parameter",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "Parameter Name",
                                                "mandatory": 1
                                            },
                                            "enum": {
                                                "attrOrProp": 2,
                                                "digest": "Use an enumerated output",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "list",
                                                "label": "Enum Values",
                                                "displayorder": 6
                                            },
                                            "minimum": {
                                                "attrOrProp": 2,
                                                "digest": "Minimum value",
                                                "isalias": 0,
                                                "aliases": [ "min" ],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "0",
                                                "label": "Minimum",
                                                "displayorder": 1
                                            },
                                            "min": {
                                                "attrOrProp": 2,
                                                "digest": "Minimum value",
                                                "isalias": 1,
                                                "aliasOf": "minimum",
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "0",
                                                "label": "Minimum",
                                                "displayorder": 1
                                            },
                                            "maximum": {
                                                "attrOrProp": 2,
                                                "digest": "Maximum value",
                                                "isalias": 0,
                                                "aliases": [ "max" ],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "1",
                                                "label": "Maximum",
                                                "displayorder": 2
                                            },
                                            "max": {
                                                "attrOrProp": 2,
                                                "digest": "Maximum value",
                                                "isalias": 1,
                                                "aliasOf": "maximum",
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "1",
                                                "label": "Maximum",
                                                "displayorder": 2
                                            },
                                            "exponent": {
                                                "attrOrProp": 2,
                                                "digest": "Scale values exponentially",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "1",
                                                "label": "Exponent",
                                                "displayorder": 7
                                            },
                                            "steps": {
                                                "attrOrProp": 2,
                                                "digest": "Divide the output into a number of discrete steps",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "0",
                                                "label": "Steps",
                                                "displayorder": 8
                                            },
                                            "displayName": {
                                                "attrOrProp": 2,
                                                "digest": "DEPRECATED: Use the lower case 'displayname' instead",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 1,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "Display Name"
                                            },
                                            "displayname": {
                                                "attrOrProp": 2,
                                                "digest": "A more readable name for the parameter in an external RNBO target",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Display Name",
                                                "displayorder": 14
                                            },
                                            "unit": {
                                                "attrOrProp": 2,
                                                "digest": "A symbol to describe the unit of the parameter in an external RNBO target",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Unit",
                                                "displayorder": 15
                                            },
                                            "tonormalized": {
                                                "attrOrProp": 2,
                                                "digest": "Converts a real parameter value to its normalized form",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "To Normalized Expression",
                                                "displayorder": 10
                                            },
                                            "fromnormalized": {
                                                "attrOrProp": 2,
                                                "digest": "Converts a normalized parameter into its actual parameter value",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "From Normalized Expression",
                                                "displayorder": 9
                                            },
                                            "order": {
                                                "attrOrProp": 2,
                                                "digest": "Order in which initial parameter values will be sent out on patcher load. The order can be numeric or symbolic ('first' and 'last')",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "0",
                                                "label": "Restore Order",
                                                "displayorder": 12
                                            },
                                            "displayorder": {
                                                "attrOrProp": 2,
                                                "digest": "Order in which parameters will show up in a list of all parameters. The order can be numeric or symbolic ('first' and 'last')",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "-",
                                                "label": "Display Order",
                                                "displayorder": 13
                                            },
                                            "sendinit": {
                                                "attrOrProp": 2,
                                                "digest": "Send initial value",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "true",
                                                "label": "Send Init",
                                                "displayorder": 4
                                            },
                                            "ctlin": {
                                                "attrOrProp": 2,
                                                "digest": "MIDI controller number to control this parameter.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "-1",
                                                "label": "MIDI Controller Number.",
                                                "displayorder": 16
                                            },
                                            "meta": {
                                                "attrOrProp": 2,
                                                "digest": "A JSON formatted string containing metadata for use by the exported code",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Metadata",
                                                "displayorder": 17
                                            },
                                            "nopreset": {
                                                "attrOrProp": 2,
                                                "digest": "Do not add this value to the preset [DEPRECATED - USE @preset 0 instead].",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 1,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "false"
                                            },
                                            "preset": {
                                                "attrOrProp": 2,
                                                "digest": "Add this value to the preset.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "true",
                                                "label": "Include In Preset",
                                                "displayorder": 11
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "value",
                                                "type": "number",
                                                "digest": "Parameter value",
                                                "defaultarg": 2,
                                                "hot": 1,
                                                "docked": 0
                                            },
                                            {
                                                "name": "normalizedvalue",
                                                "type": "number",
                                                "digest": "Set value normalized. ",
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "value",
                                                "type": "number",
                                                "digest": "Parameter value",
                                                "defaultarg": 2,
                                                "hot": 1,
                                                "docked": 0
                                            },
                                            {
                                                "name": "normalized",
                                                "type": "number",
                                                "digest": "Normalized parameter value.",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "param",
                                        "aliasOf": "param",
                                        "classname": "param",
                                        "operator": 0,
                                        "versionId": -1093178486,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "param IFT_speed 0.65 @min 0 @max 1",
                                    "varname": "IFT_speed"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-22",
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 1548.0, 65.0, 175.0, 21.0 ],
                                    "text": "gate_thresh_db"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-23",
                                    "maxclass": "flonum",
                                    "numinlets": 1,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "bang" ],
                                    "parameter_enable": 0,
                                    "patching_rect": [ 1548.0, 115.0, 100.0, 23.0 ],
                                    "rnbo_classname": "number",
                                    "rnbo_extra_attributes": {
                                        "order": "",
                                        "maximum": "<none>",
                                        "minimum": "<none>",
                                        "preset": 0,
                                        "initialFormat": "float"
                                    },
                                    "rnbo_serial": 4,
                                    "rnbo_uniqueid": "value_gate_thresh_db",
                                    "varname": "value_gate_thresh_db"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-24",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 1548.0, 143.0, 175.0, 23.0 ],
                                    "rnbo_classname": "setparam",
                                    "rnbo_serial": 4,
                                    "rnbo_uniqueid": "set_gate_thresh_db",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "name": {
                                                "attrOrProp": 2,
                                                "digest": "attribute/param to control",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "mandatory": 1
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "attribute or parameter value (bang, number, list)",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "output",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "connect to first inlet of gen or subpatcher",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "set",
                                        "aliasOf": "set",
                                        "classname": "setparam",
                                        "operator": 0,
                                        "versionId": 1197449671,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "setparam gate_thresh_db",
                                    "varname": "set_gate_thresh_db"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-25",
                                    "maxclass": "newobj",
                                    "numinlets": 2,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "" ],
                                    "patching_rect": [ 1548.0, 92.0, 291.0, 23.0 ],
                                    "rnbo_classname": "param",
                                    "rnbo_extra_attributes": {
                                        "sendinit": 1,
                                        "order": "0",
                                        "tonormalized": "",
                                        "displayorder": "-",
                                        "exponent": 1.0,
                                        "preset": 1,
                                        "meta": "",
                                        "fromnormalized": "",
                                        "enum": "",
                                        "displayname": "",
                                        "steps": 0.0,
                                        "ctlin": 0.0,
                                        "unit": ""
                                    },
                                    "rnbo_serial": 4,
                                    "rnbo_uniqueid": "gate_thresh_db",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "value": {
                                                "attrOrProp": 2,
                                                "digest": "Set initial value",
                                                "defaultarg": 2,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "-42",
                                                "label": "Initial Value",
                                                "displayorder": 3
                                            },
                                            "normalizedvalue": {
                                                "attrOrProp": 1,
                                                "digest": "Set value normalized. ",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "number"
                                            },
                                            "reset": {
                                                "attrOrProp": 1,
                                                "digest": "Reset param to initial value",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            },
                                            "normalized": {
                                                "attrOrProp": 1,
                                                "digest": "Normalized parameter value.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "number"
                                            },
                                            "name": {
                                                "attrOrProp": 2,
                                                "digest": "Name of the parameter",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "Parameter Name",
                                                "mandatory": 1
                                            },
                                            "enum": {
                                                "attrOrProp": 2,
                                                "digest": "Use an enumerated output",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "list",
                                                "label": "Enum Values",
                                                "displayorder": 6
                                            },
                                            "minimum": {
                                                "attrOrProp": 2,
                                                "digest": "Minimum value",
                                                "isalias": 0,
                                                "aliases": [ "min" ],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "-60",
                                                "label": "Minimum",
                                                "displayorder": 1
                                            },
                                            "min": {
                                                "attrOrProp": 2,
                                                "digest": "Minimum value",
                                                "isalias": 1,
                                                "aliasOf": "minimum",
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "-60",
                                                "label": "Minimum",
                                                "displayorder": 1
                                            },
                                            "maximum": {
                                                "attrOrProp": 2,
                                                "digest": "Maximum value",
                                                "isalias": 0,
                                                "aliases": [ "max" ],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "-18",
                                                "label": "Maximum",
                                                "displayorder": 2
                                            },
                                            "max": {
                                                "attrOrProp": 2,
                                                "digest": "Maximum value",
                                                "isalias": 1,
                                                "aliasOf": "maximum",
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "-18",
                                                "label": "Maximum",
                                                "displayorder": 2
                                            },
                                            "exponent": {
                                                "attrOrProp": 2,
                                                "digest": "Scale values exponentially",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "1",
                                                "label": "Exponent",
                                                "displayorder": 7
                                            },
                                            "steps": {
                                                "attrOrProp": 2,
                                                "digest": "Divide the output into a number of discrete steps",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "0",
                                                "label": "Steps",
                                                "displayorder": 8
                                            },
                                            "displayName": {
                                                "attrOrProp": 2,
                                                "digest": "DEPRECATED: Use the lower case 'displayname' instead",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 1,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "Display Name"
                                            },
                                            "displayname": {
                                                "attrOrProp": 2,
                                                "digest": "A more readable name for the parameter in an external RNBO target",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Display Name",
                                                "displayorder": 14
                                            },
                                            "unit": {
                                                "attrOrProp": 2,
                                                "digest": "A symbol to describe the unit of the parameter in an external RNBO target",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Unit",
                                                "displayorder": 15
                                            },
                                            "tonormalized": {
                                                "attrOrProp": 2,
                                                "digest": "Converts a real parameter value to its normalized form",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "To Normalized Expression",
                                                "displayorder": 10
                                            },
                                            "fromnormalized": {
                                                "attrOrProp": 2,
                                                "digest": "Converts a normalized parameter into its actual parameter value",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "From Normalized Expression",
                                                "displayorder": 9
                                            },
                                            "order": {
                                                "attrOrProp": 2,
                                                "digest": "Order in which initial parameter values will be sent out on patcher load. The order can be numeric or symbolic ('first' and 'last')",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "0",
                                                "label": "Restore Order",
                                                "displayorder": 12
                                            },
                                            "displayorder": {
                                                "attrOrProp": 2,
                                                "digest": "Order in which parameters will show up in a list of all parameters. The order can be numeric or symbolic ('first' and 'last')",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "-",
                                                "label": "Display Order",
                                                "displayorder": 13
                                            },
                                            "sendinit": {
                                                "attrOrProp": 2,
                                                "digest": "Send initial value",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "true",
                                                "label": "Send Init",
                                                "displayorder": 4
                                            },
                                            "ctlin": {
                                                "attrOrProp": 2,
                                                "digest": "MIDI controller number to control this parameter.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "-1",
                                                "label": "MIDI Controller Number.",
                                                "displayorder": 16
                                            },
                                            "meta": {
                                                "attrOrProp": 2,
                                                "digest": "A JSON formatted string containing metadata for use by the exported code",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Metadata",
                                                "displayorder": 17
                                            },
                                            "nopreset": {
                                                "attrOrProp": 2,
                                                "digest": "Do not add this value to the preset [DEPRECATED - USE @preset 0 instead].",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 1,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "false"
                                            },
                                            "preset": {
                                                "attrOrProp": 2,
                                                "digest": "Add this value to the preset.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "true",
                                                "label": "Include In Preset",
                                                "displayorder": 11
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "value",
                                                "type": "number",
                                                "digest": "Parameter value",
                                                "defaultarg": 2,
                                                "hot": 1,
                                                "docked": 0
                                            },
                                            {
                                                "name": "normalizedvalue",
                                                "type": "number",
                                                "digest": "Set value normalized. ",
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "value",
                                                "type": "number",
                                                "digest": "Parameter value",
                                                "defaultarg": 2,
                                                "hot": 1,
                                                "docked": 0
                                            },
                                            {
                                                "name": "normalized",
                                                "type": "number",
                                                "digest": "Normalized parameter value.",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "param",
                                        "aliasOf": "param",
                                        "classname": "param",
                                        "operator": 0,
                                        "versionId": -1093178486,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "param gate_thresh_db -42 @min -60 @max -18",
                                    "varname": "gate_thresh_db"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-26",
                                    "maxclass": "comment",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 700.0, 180.0, 175.0, 21.0 ],
                                    "text": "yin_window_ms"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-27",
                                    "maxclass": "flonum",
                                    "numinlets": 1,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "bang" ],
                                    "parameter_enable": 0,
                                    "patching_rect": [ 700.0, 230.0, 100.0, 23.0 ],
                                    "rnbo_classname": "number",
                                    "rnbo_extra_attributes": {
                                        "order": "",
                                        "maximum": "<none>",
                                        "minimum": "<none>",
                                        "preset": 0,
                                        "initialFormat": "float"
                                    },
                                    "rnbo_serial": 5,
                                    "rnbo_uniqueid": "value_yin_window_ms",
                                    "varname": "value_yin_window_ms"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-28",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 700.0, 258.0, 175.0, 23.0 ],
                                    "rnbo_classname": "setparam",
                                    "rnbo_serial": 5,
                                    "rnbo_uniqueid": "set_yin_window_ms",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "name": {
                                                "attrOrProp": 2,
                                                "digest": "attribute/param to control",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "mandatory": 1
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "input",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "attribute or parameter value (bang, number, list)",
                                                "hot": 1,
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "output",
                                                "type": [ "bang", "number", "list", "signal" ],
                                                "digest": "connect to first inlet of gen or subpatcher",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "set",
                                        "aliasOf": "set",
                                        "classname": "setparam",
                                        "operator": 0,
                                        "versionId": 1197449671,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "setparam yin_window_ms",
                                    "varname": "set_yin_window_ms"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-29",
                                    "maxclass": "newobj",
                                    "numinlets": 2,
                                    "numoutlets": 2,
                                    "outlettype": [ "", "" ],
                                    "patching_rect": [ 700.0, 207.0, 265.0, 23.0 ],
                                    "rnbo_classname": "param",
                                    "rnbo_extra_attributes": {
                                        "sendinit": 1,
                                        "order": "0",
                                        "tonormalized": "",
                                        "displayorder": "-",
                                        "exponent": 1.0,
                                        "preset": 1,
                                        "meta": "",
                                        "fromnormalized": "",
                                        "enum": "",
                                        "displayname": "",
                                        "steps": 0.0,
                                        "ctlin": 0.0,
                                        "unit": ""
                                    },
                                    "rnbo_serial": 5,
                                    "rnbo_uniqueid": "yin_window_ms",
                                    "rnboinfo": {
                                        "needsInstanceInfo": 1,
                                        "argnames": {
                                            "value": {
                                                "attrOrProp": 2,
                                                "digest": "Set initial value",
                                                "defaultarg": 2,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "28",
                                                "label": "Initial Value",
                                                "displayorder": 3
                                            },
                                            "normalizedvalue": {
                                                "attrOrProp": 1,
                                                "digest": "Set value normalized. ",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "inlet": 1,
                                                "type": "number"
                                            },
                                            "reset": {
                                                "attrOrProp": 1,
                                                "digest": "Reset param to initial value",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 1,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bang"
                                            },
                                            "normalized": {
                                                "attrOrProp": 1,
                                                "digest": "Normalized parameter value.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "outlet": 1,
                                                "type": "number"
                                            },
                                            "name": {
                                                "attrOrProp": 2,
                                                "digest": "Name of the parameter",
                                                "defaultarg": 1,
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "Parameter Name",
                                                "mandatory": 1
                                            },
                                            "enum": {
                                                "attrOrProp": 2,
                                                "digest": "Use an enumerated output",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "list",
                                                "label": "Enum Values",
                                                "displayorder": 6
                                            },
                                            "minimum": {
                                                "attrOrProp": 2,
                                                "digest": "Minimum value",
                                                "isalias": 0,
                                                "aliases": [ "min" ],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "10",
                                                "label": "Minimum",
                                                "displayorder": 1
                                            },
                                            "min": {
                                                "attrOrProp": 2,
                                                "digest": "Minimum value",
                                                "isalias": 1,
                                                "aliasOf": "minimum",
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "10",
                                                "label": "Minimum",
                                                "displayorder": 1
                                            },
                                            "maximum": {
                                                "attrOrProp": 2,
                                                "digest": "Maximum value",
                                                "isalias": 0,
                                                "aliases": [ "max" ],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "60",
                                                "label": "Maximum",
                                                "displayorder": 2
                                            },
                                            "max": {
                                                "attrOrProp": 2,
                                                "digest": "Maximum value",
                                                "isalias": 1,
                                                "aliasOf": "maximum",
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "60",
                                                "label": "Maximum",
                                                "displayorder": 2
                                            },
                                            "exponent": {
                                                "attrOrProp": 2,
                                                "digest": "Scale values exponentially",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "1",
                                                "label": "Exponent",
                                                "displayorder": 7
                                            },
                                            "steps": {
                                                "attrOrProp": 2,
                                                "digest": "Divide the output into a number of discrete steps",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "0",
                                                "label": "Steps",
                                                "displayorder": 8
                                            },
                                            "displayName": {
                                                "attrOrProp": 2,
                                                "digest": "DEPRECATED: Use the lower case 'displayname' instead",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 1,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "Display Name"
                                            },
                                            "displayname": {
                                                "attrOrProp": 2,
                                                "digest": "A more readable name for the parameter in an external RNBO target",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Display Name",
                                                "displayorder": 14
                                            },
                                            "unit": {
                                                "attrOrProp": 2,
                                                "digest": "A symbol to describe the unit of the parameter in an external RNBO target",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Unit",
                                                "displayorder": 15
                                            },
                                            "tonormalized": {
                                                "attrOrProp": 2,
                                                "digest": "Converts a real parameter value to its normalized form",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "To Normalized Expression",
                                                "displayorder": 10
                                            },
                                            "fromnormalized": {
                                                "attrOrProp": 2,
                                                "digest": "Converts a normalized parameter into its actual parameter value",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "label": "From Normalized Expression",
                                                "displayorder": 9
                                            },
                                            "order": {
                                                "attrOrProp": 2,
                                                "digest": "Order in which initial parameter values will be sent out on patcher load. The order can be numeric or symbolic ('first' and 'last')",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "0",
                                                "label": "Restore Order",
                                                "displayorder": 12
                                            },
                                            "displayorder": {
                                                "attrOrProp": 2,
                                                "digest": "Order in which parameters will show up in a list of all parameters. The order can be numeric or symbolic ('first' and 'last')",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "-",
                                                "label": "Display Order",
                                                "displayorder": 13
                                            },
                                            "sendinit": {
                                                "attrOrProp": 2,
                                                "digest": "Send initial value",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "true",
                                                "label": "Send Init",
                                                "displayorder": 4
                                            },
                                            "ctlin": {
                                                "attrOrProp": 2,
                                                "digest": "MIDI controller number to control this parameter.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "number",
                                                "defaultValue": "-1",
                                                "label": "MIDI Controller Number.",
                                                "displayorder": 16
                                            },
                                            "meta": {
                                                "attrOrProp": 2,
                                                "digest": "A JSON formatted string containing metadata for use by the exported code",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "symbol",
                                                "defaultValue": "",
                                                "label": "Metadata",
                                                "displayorder": 17
                                            },
                                            "nopreset": {
                                                "attrOrProp": 2,
                                                "digest": "Do not add this value to the preset [DEPRECATED - USE @preset 0 instead].",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 1,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "false"
                                            },
                                            "preset": {
                                                "attrOrProp": 2,
                                                "digest": "Add this value to the preset.",
                                                "isalias": 0,
                                                "aliases": [],
                                                "settable": 1,
                                                "attachable": 0,
                                                "isparam": 0,
                                                "deprecated": 0,
                                                "touched": 0,
                                                "type": "bool",
                                                "defaultValue": "true",
                                                "label": "Include In Preset",
                                                "displayorder": 11
                                            }
                                        },
                                        "inputs": [
                                            {
                                                "name": "value",
                                                "type": "number",
                                                "digest": "Parameter value",
                                                "defaultarg": 2,
                                                "hot": 1,
                                                "docked": 0
                                            },
                                            {
                                                "name": "normalizedvalue",
                                                "type": "number",
                                                "digest": "Set value normalized. ",
                                                "docked": 0
                                            }
                                        ],
                                        "outputs": [
                                            {
                                                "name": "value",
                                                "type": "number",
                                                "digest": "Parameter value",
                                                "defaultarg": 2,
                                                "hot": 1,
                                                "docked": 0
                                            },
                                            {
                                                "name": "normalized",
                                                "type": "number",
                                                "digest": "Normalized parameter value.",
                                                "docked": 0
                                            }
                                        ],
                                        "helpname": "param",
                                        "aliasOf": "param",
                                        "classname": "param",
                                        "operator": 0,
                                        "versionId": -1093178486,
                                        "changesPatcherIO": 0
                                    },
                                    "text": "param yin_window_ms 28 @min 10 @max 60",
                                    "varname": "yin_window_ms"
                                }
                            }
                        ],
                        "lines": [
                            {
                                "patchline": {
                                    "destination": [ "obj-12", 0 ],
                                    "source": [ "obj-11", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-12", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-11", 0 ],
                                    "source": [ "obj-13", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-16", 0 ],
                                    "source": [ "obj-15", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-16", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-15", 0 ],
                                    "source": [ "obj-17", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-20", 0 ],
                                    "source": [ "obj-19", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-6", 0 ],
                                    "source": [ "obj-2", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-7", 0 ],
                                    "source": [ "obj-2", 1 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-8", 0 ],
                                    "source": [ "obj-2", 2 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-9", 0 ],
                                    "source": [ "obj-2", 3 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-20", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-19", 0 ],
                                    "source": [ "obj-21", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-24", 0 ],
                                    "source": [ "obj-23", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-24", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-23", 0 ],
                                    "source": [ "obj-25", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-28", 0 ],
                                    "source": [ "obj-27", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-28", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-27", 0 ],
                                    "source": [ "obj-29", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 0 ],
                                    "source": [ "obj-3", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 1 ],
                                    "source": [ "obj-4", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-2", 2 ],
                                    "source": [ "obj-5", 0 ]
                                }
                            }
                        ]
                    },
                    "patching_rect": [ 877.25, 147.0, 339.0, 22.0 ],
                    "rnboattrcache": {
                        "min_freq_hz": {
                            "label": "min_freq_hz",
                            "isEnum": 0,
                            "parsestring": ""
                        },
                        "gate_thresh_db": {
                            "label": "gate_thresh_db",
                            "isEnum": 0,
                            "parsestring": ""
                        },
                        "max_freq_hz": {
                            "label": "max_freq_hz",
                            "isEnum": 0,
                            "parsestring": ""
                        },
                        "yin_window_ms": {
                            "label": "yin_window_ms",
                            "isEnum": 0,
                            "parsestring": ""
                        },
                        "IFT_speed": {
                            "label": "IFT_speed",
                            "isEnum": 0,
                            "parsestring": ""
                        }
                    },
                    "rnboversion": "1.4.5",
                    "saved_attribute_attributes": {
                        "valueof": {
                            "parameter_invisible": 1,
                            "parameter_longname": "rnbo~[2]",
                            "parameter_modmode": 0,
                            "parameter_shortname": "rnbo~",
                            "parameter_type": 3
                        }
                    },
                    "saved_object_attributes": {
                        "annotation_name": "tuba_freq_tracker_v2",
                        "optimization": "O1",
                        "parameter_enable": 1,
                        "uuid": "83de41de-cf01-11f1-a912-a2f417e70589"
                    },
                    "snapshot": {
                        "filetype": "C74Snapshot",
                        "version": 2,
                        "minorversion": 0,
                        "name": "snapshotlist",
                        "origin": "rnbo~",
                        "type": "list",
                        "subtype": "Undefined",
                        "embed": 1,
                        "snapshot": {
                            "gate_thresh_db": {
                                "value": -42.0
                            },
                            "min_freq_hz": {
                                "value": 28.0
                            },
                            "max_freq_hz": {
                                "value": 420.0
                            },
                            "IFT_speed": {
                                "value": 0.65
                            },
                            "yin_window_ms": {
                                "value": 28.0
                            },
                            "__presetid": "83de41de-cf01-11f1-a912-a2f417e70589"
                        },
                        "snapshotlist": {
                            "current_snapshot": 0,
                            "entries": [
                                {
                                    "filetype": "C74Snapshot",
                                    "version": 2,
                                    "minorversion": 0,
                                    "name": "untitled",
                                    "origin": "83de41de-cf01-11f1-a912-a2f417e70589",
                                    "type": "rnbo",
                                    "subtype": "",
                                    "embed": 1,
                                    "snapshot": {
                                        "gate_thresh_db": {
                                            "value": -42.0
                                        },
                                        "min_freq_hz": {
                                            "value": 28.0
                                        },
                                        "max_freq_hz": {
                                            "value": 420.0
                                        },
                                        "IFT_speed": {
                                            "value": 0.65
                                        },
                                        "yin_window_ms": {
                                            "value": 28.0
                                        },
                                        "__presetid": "83de41de-cf01-11f1-a912-a2f417e70589"
                                    },
                                    "fileref": {
                                        "name": "untitled",
                                        "filename": "untitled_20261023_1.maxsnap",
                                        "filepath": "~/Documents/Max 9/Snapshots",
                                        "filepos": -1,
                                        "snapshotfileid": "3f90bbd4fd0d4228f3c3557d73ec21a3"
                                    }
                                }
                            ]
                        }
                    },
                    "text": "rnbo~ @autobuild 1 @annotation_name tuba_freq_tracker_v2",
                    "varname": "rnbo_test_tuba_freq_tracker_v2"
                }
            },
            {
                "box": {
                    "id": "obj-9",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 525.0, 618.0, 72.0, 22.0 ],
                    "text": "phasor~ 0.5"
                }
            },
            {
                "box": {
                    "format": 6,
                    "id": "obj-77",
                    "maxclass": "flonum",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "", "bang" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 298.0, 142.0, 50.0, 22.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-75",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 395.0, 98.0, 77.0, 22.0 ],
                    "text": "loadmess 24"
                }
            },
            {
                "box": {
                    "id": "obj-74",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 298.0, 98.0, 87.0, 22.0 ],
                    "text": "loadmess 0.42"
                }
            },
            {
                "box": {
                    "id": "obj-73",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "float" ],
                    "patching_rect": [ 408.0, 247.0, 31.0, 22.0 ],
                    "text": "* -1."
                }
            },
            {
                "box": {
                    "id": "obj-69",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 408.0, 281.0, 52.0, 22.0 ],
                    "text": "dbtoa 0."
                }
            },
            {
                "box": {
                    "id": "obj-60",
                    "maxclass": "number",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "", "bang" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 395.0, 142.0, 50.0, 22.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-48",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 272.0, 329.0, 29.5, 22.0 ],
                    "text": "*~"
                }
            },
            {
                "box": {
                    "id": "obj-5",
                    "maxclass": "newobj",
                    "numinlets": 4,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patcher": {
                        "fileversion": 1,
                        "appversion": {
                            "major": 9,
                            "minor": 2,
                            "revision": 0,
                            "architecture": "x64",
                            "modernui": 1
                        },
                        "classnamespace": "dsp.gen",
                        "rect": [ 59.0, 106.0, 882.0, 831.0 ],
                        "boxes": [
                            {
                                "box": {
                                    "id": "obj-35",
                                    "maxclass": "newobj",
                                    "numinlets": 0,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 566.0, 15.0, 153.0, 22.0 ],
                                    "text": "in 4 @comment \"gain (dB)\""
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-21",
                                    "maxclass": "newobj",
                                    "numinlets": 0,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 382.3333333333333, 15.0, 103.0, 22.0 ],
                                    "text": "in 3 @comment q"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-9",
                                    "maxclass": "newobj",
                                    "numinlets": 1,
                                    "numoutlets": 0,
                                    "patching_rect": [ 15.0, 720.0, 117.0, 22.0 ],
                                    "text": "out 1 @comment eq"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-7",
                                    "maxclass": "newobj",
                                    "numinlets": 0,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 198.66666666666666, 15.0, 149.0, 22.0 ],
                                    "text": "in 2 @comment frequency"
                                }
                            },
                            {
                                "box": {
                                    "id": "obj-6",
                                    "maxclass": "newobj",
                                    "numinlets": 0,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 15.0, 15.0, 122.0, 22.0 ],
                                    "text": "in 1 @comment input"
                                }
                            },
                            {
                                "box": {
                                    "code": "/* SVF structure by Andrew Simper\r\n * Low, band, high, notch and peak with bounded terms\n * https://cytomic.com/files/dsp/SvfLinearTrapOptimised2.pdf\n *\r\n * stable cf between 0 .. sr/2\r\n *\r\n * q scale improved via https://claude.ai/share/deb2954d-503b-48d8-8d93-8d16d0de2fde\r\n *\r\n */\n\n// Bell EQ\n\neq_bell(xin, cf, q, gain) {\n    History y0(0), y1(0), a1(0), a2(0), a3(0);\n\n    A = pow(10, gain / 40);\n\n    g = tan(cf * pi / samplerate);\n    r = 1 / (q * A);\n\n    a1 = 1 / (1 + g * (g + r));\n    a2 = g * a1;\n    a3 = g * a2;\n\n    m0 = 1;\n    m1 = r * (A * A - 1);\n    m2 = 0;\n\n    v3 = xin - y1;\n    v1 = a1 * y0 + a2 * v3;\n    v2 = y1 + a2 * y0 + a3 * v3;\n\n    y0 = 2 * v1 - y0;\n    y1 = 2 * v2 - y1;\n\n    return xin + m1 * v1;\n}\r\n\r\nlimit = samplerate / 2;\r\n\r\ncf = clip(in2, 0, limit);\r\nq = pow(10, clip(in3, 0, 1) * 2) * 0.1;\r\ngain = clip(in4, -60, 60);\r\n\r\nout1 = eq_bell(in1, cf, q, gain);",
                                    "fontface": 0,
                                    "fontname": "<Monospaced>",
                                    "fontsize": 12.0,
                                    "id": "obj-5",
                                    "maxclass": "codebox",
                                    "numinlets": 4,
                                    "numoutlets": 1,
                                    "outlettype": [ "" ],
                                    "patching_rect": [ 15.0, 53.0, 570.0, 652.0 ]
                                }
                            }
                        ],
                        "lines": [
                            {
                                "patchline": {
                                    "destination": [ "obj-5", 2 ],
                                    "source": [ "obj-21", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-5", 3 ],
                                    "source": [ "obj-35", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-9", 0 ],
                                    "source": [ "obj-5", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-5", 0 ],
                                    "source": [ "obj-6", 0 ]
                                }
                            },
                            {
                                "patchline": {
                                    "destination": [ "obj-5", 1 ],
                                    "source": [ "obj-7", 0 ]
                                }
                            }
                        ]
                    },
                    "patching_rect": [ 272.0, 281.0, 100.0, 22.0 ],
                    "text": "gen~"
                }
            },
            {
                "box": {
                    "id": "obj-104",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "int" ],
                    "patching_rect": [ 1294.0, 394.0, 22.0, 22.0 ],
                    "text": "48"
                }
            },
            {
                "box": {
                    "id": "obj-103",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "float" ],
                    "patching_rect": [ 1247.0, 394.0, 32.0, 22.0 ],
                    "text": "0.42"
                }
            },
            {
                "box": {
                    "id": "obj-100",
                    "maxclass": "newobj",
                    "numinlets": 4,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 1153.0, 440.0, 160.0, 22.0 ],
                    "text": "gen~ @file jb.bell-as.gendsp"
                }
            },
            {
                "box": {
                    "id": "obj-68",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 75.0, 228.0, 70.0, 22.0 ],
                    "text": "loadmess 0"
                }
            },
            {
                "box": {
                    "id": "obj-67",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 501.0, 378.0, 70.0, 22.0 ],
                    "text": "loadmess 1"
                }
            },
            {
                "box": {
                    "id": "obj-64",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 867.5, 1570.0, 73.0, 22.0 ],
                    "text": "s messages"
                }
            },
            {
                "box": {
                    "id": "obj-62",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 867.5, 1079.0, 57.0, 22.0 ],
                    "text": "tosymbol"
                }
            },
            {
                "box": {
                    "id": "obj-59",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 5,
                    "outlettype": [ "", "", "", "", "" ],
                    "patching_rect": [ 867.5, 1042.0, 180.0, 22.0 ],
                    "saved_object_attributes": {
                        "legacyoutputorder": 0
                    },
                    "text": "regexp \\\\.maxpat @substitute .js"
                }
            },
            {
                "box": {
                    "id": "obj-56",
                    "linecount": 2,
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 5,
                    "outlettype": [ "", "", "", "", "" ],
                    "patching_rect": [ 867.5, 991.0, 160.0, 35.0 ],
                    "saved_object_attributes": {
                        "legacyoutputorder": 0
                    },
                    "text": "regexp generated_maxpat @substitute generated_v8ui"
                }
            },
            {
                "box": {
                    "embed": 0,
                    "filename": "rev_gated_comb.js",
                    "id": "obj-31",
                    "maxclass": "v8ui",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 867.5, 1229.0, 414.0, 327.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 10.0, 184.0, 239.0, 671.0 ],
                    "textfile": {
                        "filename": "rev_gated_comb.js",
                        "flags": 0,
                        "embed": 0,
                        "autowatch": 1
                    }
                }
            },
            {
                "box": {
                    "id": "obj-14",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 867.5, 1117.0, 107.0, 22.0 ],
                    "text": "prepend filename"
                }
            },
            {
                "box": {
                    "id": "obj-18",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 1034.0, 221.0, 150.0, 20.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 1144.0, 67.0, 69.0, 20.0 ],
                    "text": "confidence"
                }
            },
            {
                "box": {
                    "id": "obj-15",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 1035.0, 192.0, 150.0, 20.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 1144.0, 43.0, 69.0, 20.0 ],
                    "text": "pitch"
                }
            },
            {
                "box": {
                    "id": "obj-11",
                    "linecount": 3,
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 422.0, 402.0, 89.0, 47.0 ],
                    "presentation": 1,
                    "presentation_linecount": 3,
                    "presentation_rect": [ 1144.0, 96.0, 89.0, 47.0 ],
                    "text": "1. pitch Hz\n2. env vol\n3. PLL sine "
                }
            },
            {
                "box": {
                    "id": "obj-7",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 100.0, 264.0, 150.0, 20.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 1112.0, 145.0, 106.0, 20.0 ],
                    "text": "harmonic isolator"
                }
            },
            {
                "box": {
                    "id": "obj-12",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "bang" ],
                    "patching_rect": [ 1101.0, 598.0, 58.0, 22.0 ],
                    "text": "loadbang"
                }
            },
            {
                "box": {
                    "id": "obj-6",
                    "maxclass": "message",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 1101.0, 635.0, 121.0, 22.0 ],
                    "text": "readfile ./file_list.html"
                }
            },
            {
                "box": {
                    "id": "obj-57",
                    "maxclass": "button",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "bang" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 894.0, 675.0, 24.0, 24.0 ]
                }
            },
            {
                "box": {
                    "disablefind": 0,
                    "id": "obj-91",
                    "maxclass": "jweb",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 1101.0, 674.0, 1148.0, 523.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 254.0, 184.0, 1127.0, 671.0 ],
                    "rendermode": 0,
                    "url": "file://file_list.html"
                }
            },
            {
                "box": {
                    "filename": "file_list.js",
                    "id": "obj-55",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "", "" ],
                    "patching_rect": [ 935.0, 715.0, 95.0, 22.0 ],
                    "saved_object_attributes": {
                        "embed": 0,
                        "parameter_enable": 0
                    },
                    "text": "v8 file_list.js",
                    "textfile": {
                        "filename": "file_list.js",
                        "flags": 0,
                        "embed": 0,
                        "autowatch": 1
                    }
                }
            },
            {
                "box": {
                    "id": "obj-88",
                    "maxclass": "newobj",
                    "numinlets": 0,
                    "numoutlets": 4,
                    "outlettype": [ "int", "int", "int", "int" ],
                    "patching_rect": [ 935.0, 648.0, 32.0, 22.0 ],
                    "text": "key"
                }
            },
            {
                "box": {
                    "id": "obj-89",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 935.0, 676.0, 76.0, 22.0 ],
                    "text": "prepend kbd"
                }
            },
            {
                "box": {
                    "id": "obj-90",
                    "maxclass": "comment",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 933.0, 621.0, 114.0, 20.0 ],
                    "text": "arrow-key fallback"
                }
            },
            {
                "box": {
                    "fontface": 0,
                    "fontname": "Arial",
                    "fontsize": 12.0,
                    "id": "obj-10",
                    "maxclass": "number~",
                    "mode": 2,
                    "numinlets": 2,
                    "numoutlets": 2,
                    "outlettype": [ "signal", "float" ],
                    "patching_rect": [ 434.0, 611.0, 56.0, 22.0 ],
                    "sig": 0.0
                }
            },
            {
                "box": {
                    "id": "obj-8",
                    "maxclass": "number",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "", "bang" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 422.0, 451.0, 50.0, 22.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 1086.0, 109.0, 50.0, 22.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-3",
                    "maxclass": "newobj",
                    "numinlets": 4,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 408.0, 535.0, 78.0, 22.0 ],
                    "text": "selector~ 3 1"
                }
            },
            {
                "box": {
                    "id": "obj-52",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 547.0, 440.0, 35.0, 22.0 ],
                    "text": "abs~"
                }
            },
            {
                "box": {
                    "id": "obj-49",
                    "maxclass": "live.scope~",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "bang" ],
                    "patching_rect": [ 547.0, 548.0, 184.0, 68.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-46",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 547.0, 480.0, 37.0, 22.0 ],
                    "text": "*~ 16"
                }
            },
            {
                "box": {
                    "id": "obj-45",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 547.0, 514.0, 94.0, 22.0 ],
                    "text": "slide~ 960 4800"
                }
            },
            {
                "box": {
                    "id": "obj-42",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 919.0, 299.0, 46.0, 22.0 ],
                    "text": "r~ out2"
                }
            },
            {
                "box": {
                    "id": "obj-41",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 854.0, 299.0, 46.0, 22.0 ],
                    "text": "r~ out1"
                }
            },
            {
                "box": {
                    "id": "obj-35",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 895.0, 894.75, 54.0, 22.0 ],
                    "text": "deferlow"
                }
            },
            {
                "box": {
                    "id": "obj-37",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 895.0, 828.25, 48.0, 22.0 ],
                    "text": "pipe 50"
                }
            },
            {
                "box": {
                    "id": "obj-30",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 895.0, 861.5, 105.0, 22.0 ],
                    "text": "prepend autobuild"
                }
            },
            {
                "box": {
                    "id": "obj-28",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "int" ],
                    "patching_rect": [ 895.0, 795.0, 22.0, 22.0 ],
                    "text": "t 1"
                }
            },
            {
                "box": {
                    "id": "obj-27",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 895.0, 928.0, 73.0, 22.0 ],
                    "text": "s messages"
                }
            },
            {
                "box": {
                    "id": "obj-26",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 455.5, 573.0, 41.0, 22.0 ],
                    "text": "s~ in4"
                }
            },
            {
                "box": {
                    "id": "obj-25",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 383.5, 571.0, 41.0, 22.0 ],
                    "text": "s~ in3"
                }
            },
            {
                "box": {
                    "id": "obj-23",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 238.5, 565.0, 41.0, 22.0 ],
                    "text": "s~ in1"
                }
            },
            {
                "box": {
                    "id": "obj-24",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 0,
                    "patching_rect": [ 310.5, 568.0, 41.0, 22.0 ],
                    "text": "s~ in2"
                }
            },
            {
                "box": {
                    "id": "obj-19",
                    "linecount": 2,
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "" ],
                    "patching_rect": [ 935.0, 751.0, 137.0, 35.0 ],
                    "text": "prepend script sendbox replaceme replace"
                }
            },
            {
                "box": {
                    "id": "obj-13",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "int" ],
                    "patching_rect": [ 75.0, 373.0, 29.5, 22.0 ],
                    "text": "+ 1"
                }
            },
            {
                "box": {
                    "id": "obj-17",
                    "maxclass": "toggle",
                    "numinlets": 1,
                    "numoutlets": 1,
                    "outlettype": [ "int" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 75.0, 262.0, 24.0, 24.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 1086.0, 149.0, 24.0, 24.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-1",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 225.0, 475.0, 78.0, 22.0 ],
                    "text": "selector~ 2 1"
                }
            },
            {
                "box": {
                    "id": "obj-29",
                    "maxclass": "newobj",
                    "numinlets": 1,
                    "numoutlets": 2,
                    "outlettype": [ "", "" ],
                    "patching_rect": [ 935.0, 795.0, 67.0, 22.0 ],
                    "save": [ "#N", "thispatcher", ";", "#Q", "end", ";" ],
                    "text": "thispatcher"
                }
            },
            {
                "box": {
                    "id": "obj-2",
                    "maxclass": "newobj",
                    "numinlets": 3,
                    "numoutlets": 1,
                    "outlettype": [ "signal" ],
                    "patching_rect": [ 319.0, 475.0, 78.0, 22.0 ],
                    "text": "selector~ 2 1"
                }
            },
            {
                "box": {
                    "autosave": 1,
                    "bgmode": 0,
                    "border": 0,
                    "clickthrough": 0,
                    "id": "obj-54",
                    "maxclass": "newobj",
                    "numinlets": 2,
                    "numoutlets": 8,
                    "offset": [ 0.0, 0.0 ],
                    "outlettype": [ "signal", "signal", "", "list", "int", "", "", "" ],
                    "patching_rect": [ 935.0, 555.0, 138.0, 22.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 1067.0, 10.0, 138.0, 22.0 ],
                    "save": [ "#N", "vst~", "loaduniqueid", 0, 2, 2, "Pro-Q 3", ";" ],
                    "saved_attribute_attributes": {
                        "valueof": {
                            "parameter_invisible": 1,
                            "parameter_longname": "vst~",
                            "parameter_modmode": 0,
                            "parameter_shortname": "vst~",
                            "parameter_type": 3
                        }
                    },
                    "saved_object_attributes": {
                        "parameter_enable": 1,
                        "parameter_mappable": 0,
                        "prefer": "AudioUnit"
                    },
                    "snapshot": {
                        "filetype": "C74Snapshot",
                        "version": 2,
                        "minorversion": 0,
                        "name": "snapshotlist",
                        "origin": "vst~",
                        "type": "list",
                        "subtype": "Undefined",
                        "embed": 1,
                        "snapshot": {
                            "pluginname": "Pro-Q 3.auinfo",
                            "plugindisplayname": "Pro-Q 3",
                            "pluginsavedname": "",
                            "pluginsaveduniqueid": 1631927376,
                            "version": 1,
                            "isbank": 0,
                            "isbase64": 1,
                            "blob": "1684.hAGaoMGcv.i0AHv.DTfAGfPBJr.CWMWchQWdvUFWsEla0YVXiQWcxUlbeAAEFElXFkFazUlbPwVcmklaSQWXzUFUtEVakQEc4AWYWYWYxMWZu4lDFE0LvIgQgIlQOEQAfajQBMU.....lE............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3O...f+....................................9C...3O...f+B....D...DP...f.A....D........f+....9C....P..........................................................................................................................................fQQMCbC....7.....QkYVX0wFcfLUYzQWZtcF.....A....T.....Tx8VKQE....vP0MkUA.........vWP7.QkYVX0wFcfLUYzQWZtclDgUWalAA..f..U.PG.nB.AAfQ.rD.SA.V.zkAAYvTFfE.......f.A.........PC..................fAZA"
                        },
                        "snapshotlist": {
                            "current_snapshot": 0,
                            "entries": [
                                {
                                    "filetype": "C74Snapshot",
                                    "version": 2,
                                    "minorversion": 0,
                                    "name": "Pro-Q 3",
                                    "origin": "Pro-Q 3.auinfo",
                                    "type": "AudioUnit",
                                    "subtype": "MidiEffect",
                                    "embed": 0,
                                    "snapshot": {
                                        "pluginname": "Pro-Q 3.auinfo",
                                        "plugindisplayname": "Pro-Q 3",
                                        "pluginsavedname": "",
                                        "pluginsaveduniqueid": 1631927376,
                                        "version": 1,
                                        "isbank": 0,
                                        "isbase64": 1,
                                        "blob": "1684.hAGaoMGcv.i0AHv.DTfAGfPBJr.CWMWchQWdvUFWsEla0YVXiQWcxUlbeAAEFElXFkFazUlbPwVcmklaSQWXzUFUtEVakQEc4AWYWYWYxMWZu4lDFE0LvIgQgIlQOEQAfajQBMU.....lE............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3OZO2GAA.............f+....9C...vO.........9C....P...f+..............f+n8beDD..............9C...3O....+.........3O.....A...9C..............9i1y8QP..............3O...f+....7C........f+.....D...3O..............3O...f+....................................9C...3O...f+B....D...DP...f.A....D........f+....9C....P..........................................................................................................................................fQQMCbC....7.....QkYVX0wFcfLUYzQWZtcF.....A....T.....Tx8VKQE....vP0MkUA.........vWP7.QkYVX0wFcfLUYzQWZtclDgUWalAA..f..U.PG.nB.AAfQ.rD.SA.V.zkAAYvTFfE.......f.A.........PC..................fAZA"
                                    },
                                    "fileref": {
                                        "name": "Pro-Q 3",
                                        "filename": "Pro-Q 3_20261014.maxsnap",
                                        "filepath": "~/Documents/Max 9/Snapshots",
                                        "filepos": -1,
                                        "snapshotfileid": "573b51492813a845adb4712650dce0ac"
                                    }
                                }
                            ]
                        }
                    },
                    "text": "audiounit~ 2 2 \"Pro-Q 3\"",
                    "varname": "vst~",
                    "viewvisibility": 0
                }
            },
            {
                "box": {
                    "id": "obj-53",
                    "lastchannelcount": 0,
                    "maxclass": "live.gain~",
                    "numinlets": 2,
                    "numoutlets": 5,
                    "outlettype": [ "signal", "signal", "", "float", "list" ],
                    "parameter_enable": 1,
                    "patching_rect": [ 872.0, 349.0, 48.0, 136.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 1023.0, 37.0, 48.0, 136.0 ],
                    "saved_attribute_attributes": {
                        "valueof": {
                            "parameter_initial": [ -24 ],
                            "parameter_initial_enable": 1,
                            "parameter_longname": "live.gain~[2]",
                            "parameter_mmax": 6.0,
                            "parameter_mmin": -70.0,
                            "parameter_modmode": 3,
                            "parameter_shortname": "fx",
                            "parameter_type": 0,
                            "parameter_unitstyle": 4
                        }
                    },
                    "varname": "live.gain~[2]"
                }
            },
            {
                "box": {
                    "id": "obj-51",
                    "lastchannelcount": 0,
                    "maxclass": "live.gain~",
                    "numinlets": 2,
                    "numoutlets": 5,
                    "outlettype": [ "signal", "signal", "", "float", "list" ],
                    "parameter_enable": 1,
                    "patching_rect": [ 786.0, 349.0, 48.0, 136.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 980.0, 37.0, 48.0, 136.0 ],
                    "saved_attribute_attributes": {
                        "valueof": {
                            "parameter_initial": [ -24 ],
                            "parameter_initial_enable": 1,
                            "parameter_longname": "live.gain~",
                            "parameter_mmax": 6.0,
                            "parameter_mmin": -70.0,
                            "parameter_modmode": 3,
                            "parameter_shortname": "dry",
                            "parameter_type": 0,
                            "parameter_unitstyle": 4
                        }
                    },
                    "varname": "live.gain~"
                }
            },
            {
                "box": {
                    "id": "obj-50",
                    "maxclass": "newobj",
                    "numinlets": 4,
                    "numoutlets": 0,
                    "patching_rect": [ 808.0, 565.0, 75.0, 22.0 ],
                    "text": "dac~ 1 2 3 4"
                }
            },
            {
                "box": {
                    "id": "obj-44",
                    "maxclass": "live.scope~",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "bang" ],
                    "patching_rect": [ 1001.0, 272.0, 184.0, 68.0 ]
                }
            },
            {
                "box": {
                    "id": "obj-43",
                    "maxclass": "live.scope~",
                    "numinlets": 2,
                    "numoutlets": 1,
                    "outlettype": [ "bang" ],
                    "patching_rect": [ 1205.0, 272.0, 184.0, 68.0 ]
                }
            },
            {
                "box": {
                    "fontface": 0,
                    "fontname": "Arial",
                    "fontsize": 12.0,
                    "id": "obj-39",
                    "maxclass": "number~",
                    "mode": 2,
                    "numinlets": 2,
                    "numoutlets": 2,
                    "outlettype": [ "signal", "float" ],
                    "patching_rect": [ 963.0, 191.0, 56.0, 22.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 1086.0, 66.0, 56.0, 22.0 ],
                    "sig": 0.0
                }
            },
            {
                "box": {
                    "fontface": 0,
                    "fontname": "Arial",
                    "fontsize": 12.0,
                    "id": "obj-38",
                    "maxclass": "number~",
                    "mode": 2,
                    "numinlets": 2,
                    "numoutlets": 2,
                    "outlettype": [ "signal", "float" ],
                    "patching_rect": [ 900.0, 191.0, 56.0, 22.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 1086.0, 42.0, 56.0, 22.0 ],
                    "sig": 0.0
                }
            },
            {
                "box": {
                    "clipheight": 83.0,
                    "data": {
                        "clips": [
                            {
                                "absolutepath": "sousa_mic.aif",
                                "filename": "sousa_mic.aif",
                                "filekind": "audiofile",
                                "id": "u026004737",
                                "loop": 1,
                                "content_state": {
                                    "loop": 1
                                }
                            }
                        ]
                    },
                    "id": "obj-36",
                    "maxclass": "playlist~",
                    "mode": "basic",
                    "numinlets": 1,
                    "numoutlets": 5,
                    "outlettype": [ "signal", "signal", "signal", "", "dictionary" ],
                    "parameter_enable": 0,
                    "patching_rect": [ 803.0, 29.0, 515.0, 84.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 10.0, 10.0, 974.0, 83.0 ],
                    "quality": "basic",
                    "saved_attribute_attributes": {
                        "candicane2": {
                            "expression": ""
                        },
                        "candicane3": {
                            "expression": ""
                        },
                        "candicane4": {
                            "expression": ""
                        },
                        "candicane5": {
                            "expression": ""
                        },
                        "candicane6": {
                            "expression": ""
                        },
                        "candicane7": {
                            "expression": ""
                        },
                        "candicane8": {
                            "expression": ""
                        }
                    }
                }
            },
            {
                "box": {
                    "args": [ "#1" ],
                    "bgmode": 0,
                    "border": 0,
                    "clickthrough": 0,
                    "enablehscroll": 0,
                    "enablevscroll": 0,
                    "id": "obj-21",
                    "lockeddragscroll": 0,
                    "lockedsize": 0,
                    "maxclass": "bpatcher",
                    "name": "rev_gated_comb.maxpat",
                    "numinlets": 0,
                    "numoutlets": 0,
                    "offset": [ 0.0, 0.0 ],
                    "patching_rect": [ 276.0, 676.0, 528.0, 208.0 ],
                    "presentation": 1,
                    "presentation_rect": [ 10.0, 16.0, 939.0, 219.0 ],
                    "varname": "replaceme",
                    "viewvisibility": 1
                }
            }
        ],
        "lines": [
            {
                "patchline": {
                    "destination": [ "obj-23", 0 ],
                    "source": [ "obj-1", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-100", 2 ],
                    "source": [ "obj-103", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-100", 3 ],
                    "source": [ "obj-104", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-6", 0 ],
                    "source": [ "obj-12", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-1", 0 ],
                    "order": 1,
                    "source": [ "obj-13", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-2", 0 ],
                    "order": 0,
                    "source": [ "obj-13", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-31", 0 ],
                    "source": [ "obj-14", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-3", 3 ],
                    "order": 1,
                    "source": [ "obj-16", 3 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-3", 1 ],
                    "order": 1,
                    "source": [ "obj-16", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-38", 0 ],
                    "order": 0,
                    "source": [ "obj-16", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-39", 0 ],
                    "source": [ "obj-16", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-43", 0 ],
                    "order": 0,
                    "source": [ "obj-16", 3 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-44", 0 ],
                    "source": [ "obj-16", 2 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-5", 1 ],
                    "order": 2,
                    "source": [ "obj-16", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-13", 0 ],
                    "source": [ "obj-17", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-29", 0 ],
                    "source": [ "obj-19", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-24", 0 ],
                    "source": [ "obj-2", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-37", 0 ],
                    "source": [ "obj-28", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-10", 0 ],
                    "source": [ "obj-3", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-35", 0 ],
                    "source": [ "obj-30", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-64", 0 ],
                    "source": [ "obj-31", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-27", 0 ],
                    "source": [ "obj-35", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-1", 1 ],
                    "order": 6,
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-16", 0 ],
                    "order": 0,
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-2", 1 ],
                    "order": 4,
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-5", 0 ],
                    "order": 5,
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-51", 1 ],
                    "order": 1,
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-51", 0 ],
                    "order": 2,
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-52", 0 ],
                    "order": 3,
                    "source": [ "obj-36", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-30", 0 ],
                    "source": [ "obj-37", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-53", 0 ],
                    "source": [ "obj-41", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-53", 1 ],
                    "source": [ "obj-42", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-3", 2 ],
                    "order": 1,
                    "source": [ "obj-45", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-49", 0 ],
                    "order": 0,
                    "source": [ "obj-45", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-45", 0 ],
                    "source": [ "obj-46", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-1", 2 ],
                    "order": 1,
                    "source": [ "obj-48", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-2", 2 ],
                    "order": 0,
                    "source": [ "obj-48", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-48", 0 ],
                    "source": [ "obj-5", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-50", 1 ],
                    "order": 1,
                    "source": [ "obj-51", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-50", 0 ],
                    "order": 1,
                    "source": [ "obj-51", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-54", 1 ],
                    "order": 0,
                    "source": [ "obj-51", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-54", 0 ],
                    "order": 0,
                    "source": [ "obj-51", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-46", 0 ],
                    "source": [ "obj-52", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-50", 1 ],
                    "order": 1,
                    "source": [ "obj-53", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-50", 0 ],
                    "order": 1,
                    "source": [ "obj-53", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-54", 1 ],
                    "order": 0,
                    "source": [ "obj-53", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-54", 0 ],
                    "order": 0,
                    "source": [ "obj-53", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-19", 0 ],
                    "order": 0,
                    "source": [ "obj-55", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-28", 0 ],
                    "order": 1,
                    "source": [ "obj-55", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-56", 0 ],
                    "midpoints": [ 944.5, 743.0, 877.0, 743.0 ],
                    "order": 2,
                    "source": [ "obj-55", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-91", 0 ],
                    "source": [ "obj-55", 1 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-59", 0 ],
                    "source": [ "obj-56", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-55", 0 ],
                    "source": [ "obj-57", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-62", 0 ],
                    "source": [ "obj-59", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-91", 0 ],
                    "source": [ "obj-6", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-5", 3 ],
                    "order": 1,
                    "source": [ "obj-60", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-73", 0 ],
                    "order": 0,
                    "source": [ "obj-60", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-14", 0 ],
                    "source": [ "obj-62", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-8", 0 ],
                    "source": [ "obj-67", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-17", 0 ],
                    "source": [ "obj-68", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-48", 1 ],
                    "source": [ "obj-69", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-69", 0 ],
                    "source": [ "obj-73", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-77", 0 ],
                    "source": [ "obj-74", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-60", 0 ],
                    "source": [ "obj-75", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-5", 2 ],
                    "source": [ "obj-77", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-3", 0 ],
                    "source": [ "obj-8", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-89", 0 ],
                    "source": [ "obj-88", 3 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-55", 0 ],
                    "source": [ "obj-89", 0 ]
                }
            },
            {
                "patchline": {
                    "destination": [ "obj-55", 0 ],
                    "midpoints": [ 1110.5, 1223.0, 1078.0, 1223.0, 1078.0, 706.0, 944.5, 706.0 ],
                    "source": [ "obj-91", 0 ]
                }
            }
        ],
        "parameters": {
            "obj-16": [ "rnbo~[2]", "rnbo~", 0 ],
            "obj-21::obj-9": [ "rnbo~[1]", "rnbo~", 0 ],
            "obj-51": [ "live.gain~", "dry", 0 ],
            "obj-53": [ "live.gain~[2]", "fx", 0 ],
            "obj-54": [ "vst~", "vst~", 0 ],
            "parameterbanks": {
                "0": {
                    "index": 0,
                    "name": "",
                    "parameters": [ "-", "-", "-", "-", "-", "-", "-", "-" ],
                    "buttons": [ "-", "-", "-", "-", "-", "-", "-", "-" ]
                }
            },
            "inherited_shortname": 1
        },
        "autosave": 0,
        "toolbaradditions": [ "packagemanager" ],
        "toolbarexclusions": [ "mixerslider", "quickrecord", "showmappings" ],
        "bgcolor": [ 0.1294117647, 0.1294117647, 0.1411764706, 1.0 ]
    }
}