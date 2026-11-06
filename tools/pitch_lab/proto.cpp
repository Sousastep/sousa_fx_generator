// proto.cpp — C++ prototype of generated_fx/ai_pitch_tracker/tuba_freq_tracker_v3.txt
//
// Lag-adaptive sliding NSDF pitch tracker, written in a codebox~-portable style
// (fixed arrays, no allocation in the loop) so a change here ports line for line.
// The defaults are the tuned values that tuba_freq_tracker_v3.txt ships with,
// and the parameter names match its @params; the lower-case extras are
// constants in the codebox.
//
// usage: proto in.f32 out.f32 [name=value ...]     (env SR=48000 for other rates)
// in:  mono float32 raw.  out: float32 raw, 4 interleaved channels:
//      f0 Hz (0 until the first pitch) | confidence | raw estimate Hz | nsdf peak
#include <cstdio>
#include <cstdlib>
#include <cmath>
#include <vector>
#include <string>
#include <map>
#include <algorithm>

static std::map<std::string, double> P;
static double g(const char* k, double d) { auto it = P.find(k); return it == P.end() ? d : it->second; }

struct Biquad {  // RBJ, transposed direct form II (same as the codebox)
  double b0 = 0, b1 = 0, b2 = 0, a1 = 0, a2 = 0, z1 = 0, z2 = 0;
  void lp(double f, double q, double sr) { double w = 2 * M_PI * f / sr, c = cos(w), al = sin(w) / (2 * q), a0 = 1 + al;
    b0 = (1 - c) / 2 / a0; b1 = (1 - c) / a0; b2 = b0; a1 = -2 * c / a0; a2 = (1 - al) / a0; }
  void hp(double f, double q, double sr) { double w = 2 * M_PI * f / sr, c = cos(w), al = sin(w) / (2 * q), a0 = 1 + al;
    b0 = (1 + c) / 2 / a0; b1 = -(1 + c) / a0; b2 = b0; a1 = -2 * c / a0; a2 = (1 - al) / a0; }
  double next(double x) { double y = b0 * x + z1; z1 = b1 * x - a1 * y + z2; z2 = b2 * x - a2 * y; return y; }
};

const int BUF = 4096, MAXL = 600;

struct Tracker {
  double sr, dsr; int D;
  Biquad hp, lp1, lp2;
  double buf[BUF] = {0}; int w = 0;
  double dd[MAXL] = {0}, mm[MAXL] = {0}, ns[MAXL] = {0};
  int W[MAXL] = {0};
  int dec = 0, hop = 0;
  double env = 0, f0 = 0, outF = 0, conf = 0, rawF = 0, peak = 0;
  int candCount = 0; double candF = 0;
  // parameters
  double fmin, fmax, gateDb, vth, winP, smoothMs, k, wminMs, candTol, jumpSt;
  int hopN, confirmN, octN, minLag, maxLag;

  void init(double s) {
    sr = s; D = std::max(1, (int)floor(sr / 11025.0 + 0.5)); dsr = sr / D;
    // the codebox @params
    fmin = g("min_freq_hz", 27); fmax = g("max_freq_hz", 420); gateDb = g("gate_db", -48);
    vth = g("voicing", 0.4); winP = g("window_periods", 3.0); smoothMs = g("smooth_ms", 1.0);
    hopN = (int)g("hop", 4);
    confirmN = (int)ceil(g("confirm_ms", 10) * 0.001 * dsr / hopN);
    octN = (int)ceil(g("octave_ms", 25) * 0.001 * dsr / hopN);
    // constants in the codebox
    k = g("k", 0.6);              // key-maximum fraction (McLeod)
    wminMs = g("wmin_ms", 5.0);   // shortest window
    candTol = g("cand_tol", 0.35);// a jump candidate must hold within this many semitones
    jumpSt = g("jump_st", 1.5);   // moves below this pass without confirmation
    hp.hp(g("hp_hz", 22), 0.707, sr);
    lp1.lp(g("lp_hz", 900), 0.54, sr); lp2.lp(g("lp_hz", 900), 1.31, sr);
    minLag = std::max(2, (int)floor(dsr / fmax));
    maxLag = std::min(MAXL - 2, (int)ceil(dsr / fmin) + 1);
    int wmin = (int)floor(wminMs * 0.001 * dsr);
    for (int t = 1; t <= maxLag + 1; t++) {
      int ww = (int)floor(winP * t + 0.5);
      if (ww < wmin) ww = wmin;
      if (ww + t + 2 > BUF) ww = BUF - t - 2;
      W[t] = ww;
    }
  }

  void tick(double x) {
    double h = hp.next(x);
    double e = lp2.next(lp1.next(h));
    env += (h * h - env) * (1 - exp(-1 / (0.005 * sr)));
    if (++dec < D) return;
    dec = 0;
    // one decimated sample: slide every lag's sums by one
    w = (w + 1) & (BUF - 1); buf[w] = e;
    double xn = e;
    for (int t = 1; t <= maxLag + 1; t++) {
      double xt = buf[(w - t) & (BUF - 1)];
      int ww = W[t];
      double xo = buf[(w - ww) & (BUF - 1)], xot = buf[(w - ww - t) & (BUF - 1)];
      double a = xn - xt, b = xo - xot;
      dd[t] += a * a - b * b;
      mm[t] += xn * xn + xt * xt - xo * xo - xot * xot;
    }
    if (++hop < hopN) return;
    hop = 0;
    double rms = sqrt(std::max(env, 0.0));
    bool loud = 20 * log10(rms + 1e-12) > gateDb;
    for (int t = 1; t <= maxLag + 1; t++) { double m = mm[t]; ns[t] = m > 1e-12 ? 1 - dd[t] / m : 0; }
    // key maxima: max of each positive region after the first negative-going crossing
    int nk = 0, kT[64]; double kV[64];
    bool seenNeg = false; double curMax = -2; int curT = -1;
    for (int t = 1; t <= maxLag; t++) {
      double v = ns[t];
      if (!seenNeg) { if (v < 0) seenNeg = true; continue; }
      if (v > 0) { if (v > curMax && t >= minLag) { curMax = v; curT = t; } }
      else if (curT > 0) { if (nk < 64) { kT[nk] = curT; kV[nk] = curMax; nk++; } curMax = -2; curT = -1; }
    }
    if (curT > 0 && nk < 64 && curT < maxLag) { kT[nk] = curT; kV[nk] = curMax; nk++; }
    double gmax = -1;
    for (int i = 0; i < nk; i++) gmax = std::max(gmax, kV[i]);
    int bt = -1; double bv = 0;
    for (int i = 0; i < nk; i++) if (kV[i] >= k * gmax) { bt = kT[i]; bv = kV[i]; break; }
    peak = bv;
    if (bt > 1 && loud && bv >= vth) {
      double y1 = ns[bt - 1], y2 = ns[bt], y3 = ns[bt + 1], den = y1 - 2 * y2 + y3;
      double dl = fabs(den) > 1e-12 ? 0.5 * (y1 - y3) / den : 0;
      dl = std::min(0.5, std::max(-0.5, dl));
      double f = dsr / (bt + dl); rawF = f;
      if (f0 <= 0) { f0 = f; candCount = 0; }
      else {
        double st = 12 * log2(f / f0);
        if (fabs(st) < jumpSt) { f0 = f; candCount = 0; }
        else {
          if (candF > 0 && fabs(12 * log2(f / candF)) < candTol) candCount++; else { candCount = 1; candF = f; }
          bool oct = fabs(fabs(st) - 12) < 0.6;
          if (candCount >= (oct ? std::max(confirmN, octN) : confirmN)) { f0 = f; candCount = 0; }
        }
      }
      conf = bv;
    } else { conf = loud ? bv * 0.5 : 0; candCount = 0; }
  }

  double out() {  // per-sample glide in log2 frequency
    if (f0 <= 0) return 0;
    if (outF <= 0) outF = f0;
    double a = smoothMs > 0 ? 1 - exp(-1 / (smoothMs * 0.001 * sr)) : 1.0;
    outF = exp2(log2(outF) + (log2(f0) - log2(outF)) * a);
    return outF;
  }
};

int main(int argc, char** argv) {
  if (argc < 3) { fprintf(stderr, "usage: proto in.f32 out.f32 [name=value ...]\n"); return 2; }
  for (int i = 3; i < argc; i++) { std::string s = argv[i]; auto q = s.find('='); P[s.substr(0, q)] = atof(s.c_str() + q + 1); }
  FILE* f = fopen(argv[1], "rb"); if (!f) { perror(argv[1]); return 1; }
  fseek(f, 0, SEEK_END); long n = ftell(f) / 4; fseek(f, 0, SEEK_SET);
  std::vector<float> x(n); if (fread(x.data(), 4, n, f) != (size_t)n) return 1; fclose(f);
  Tracker* T = new Tracker(); T->init(getenv("SR") ? atof(getenv("SR")) : 44100);
  FILE* o = fopen(argv[2], "wb"); float fr[4];
  for (long i = 0; i < n; i++) {
    T->tick(x[i]);
    fr[0] = T->out(); fr[1] = T->conf; fr[2] = T->rawF; fr[3] = T->peak;
    fwrite(fr, 4, 4, o);
  }
  fclose(o);
}
