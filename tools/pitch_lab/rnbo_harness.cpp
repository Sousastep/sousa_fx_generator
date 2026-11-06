// rnbo_harness.cpp — run RNBO-generated codebox~ C++ (from verify_codebox.js --keep)
// over a mono float32 file, offline, block size 64.
//
// usage: <bin> in.f32 out.f32
//   in1 = in2 = the file; in3 and up follow IN3 (else 0); output = every outlet,
//   float32 interleaved.
// env:  SR=48000            sample rate (default 44100)
//       IN3="v0,v1@t"       in3 = v0 before t seconds, v1 after
// Params: verify_codebox.js builds a bare codebox~ whose @params have no inlet,
// and RNBO constant-folds them into the generated C++ (the perform() arguments
// are unused). So @param values cannot be set here at run time: lab.py writes a
// source variant instead (--set name=value bakes a default in, --dyn name reads
// that @param from in3, which IN3 then drives).
#include "RNBO.h"
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <string>
#include <vector>

static double in3v(long i, double sr) {
  const char* e = getenv("IN3"); if (!e) return 0;
  double v0 = 0, v1 = 0, t = 0; sscanf(e, "%lf,%lf@%lf", &v0, &v1, &t);
  return (i / sr < t) ? v0 : v1;
}

int main(int argc, char** argv) {
  if (argc != 3) { fprintf(stderr, "usage: %s in.f32 out.f32\n", argv[0]); return 2; }
  FILE* f = fopen(argv[1], "rb"); if (!f) { perror(argv[1]); return 1; }
  fseek(f, 0, SEEK_END); long n = ftell(f) / 4; fseek(f, 0, SEEK_SET);
  std::vector<float> x(n); if (fread(x.data(), 4, n, f) != (size_t)n) return 1; fclose(f);

  RNBO::CoreObject obj;
  const int B = 64;
  double SRATE = getenv("SR") ? atof(getenv("SR")) : 44100;
  obj.prepareToProcess(SRATE, B);
  int nin = obj.getNumInputChannels(), nout = obj.getNumOutputChannels();
  std::vector<std::vector<double>> ib(nin, std::vector<double>(B)), ob(nout, std::vector<double>(B));
  std::vector<double*> ip(nin), op(nout);
  for (int i = 0; i < nin; i++) ip[i] = ib[i].data();
  for (int i = 0; i < nout; i++) op[i] = ob[i].data();
  FILE* o = fopen(argv[2], "wb");
  std::vector<float> fr(nout);
  auto t0 = std::chrono::steady_clock::now();
  for (long s = 0; s + B <= n; s += B) {
    for (int k = 0; k < B; k++) {
      ib[0][k] = x[s + k];
      if (nin > 1) ib[1][k] = x[s + k];
      for (int c = 2; c < nin; c++) ib[c][k] = in3v(s + k, SRATE);
    }
    obj.process(ip.data(), nin, op.data(), nout, B);
    for (int k = 0; k < B; k++) { for (int c = 0; c < nout; c++) fr[c] = ob[c][k]; fwrite(fr.data(), 4, nout, o); }
  }
  fclose(o);
  double ns = std::chrono::duration<double, std::nano>(std::chrono::steady_clock::now() - t0).count();
  fprintf(stderr, "%s: %d in / %d out, %.1f ns/sample (incl. file write; indicative only)\n", argv[0], nin, nout, ns / n);
}
