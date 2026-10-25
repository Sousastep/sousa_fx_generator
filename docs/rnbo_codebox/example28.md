// ---------------------------------------------------------------------------
// example28 - Int arithmetic stays integer: `n / (n + 1.0)` is 0
//
// RULE: never divide by an expression built only from `Int` variables and
// numeric literals. Copy the Int into an untyped/number variable first
// (`let nf = n * 1.0;`), or keep the state untyped (`@state n = 0;`).
//
// Why: codebox types `n + 1.0` as Int when `n` is Int (the literal is folded
// to `1`), and Int / Int compiles to a C++ integer division. The code parses,
// compiles and runs; it is just wrong. Found in five airwindows ports
// (Dynamics3, X2Buss, TakeCare, VerbThic, VerbTiny), where
//
//     bezTrim = 1.0 - (bezRez * (stepped / (stepped + 1.0)));
//
// became `stepped / (stepped + 1)` = 0, so every Bezier cycle ran one sample
// long (Dynamics3/X2Buss: up to -27 dB error against the original C++), or
// `bezTrim = bezFraction / (bezFraction + 1.0)` = 0, so the cycle restarted
// on every sample (TakeCare, VerbThic, VerbTiny).
//
// Generated C++ (verify_codebox.js --keep):
//
//     @state k: Int = 3;   let a = k/(k+1.0);       ->  k / (k + 1)    (0)
//     let kn = k * 1.0;    let b = kn/(kn+1.0);     ->  kn / (kn + 1)  (0.75)
//
// `number / Int` (`x /= spacing`, `0.99999999 / stepped`) is fine; only an
// all-Int numerator and denominator truncate.
// ---------------------------------------------------------------------------

@param({ min: 1, max: 1000 }) window_ms = 20;

@state stepped = 0;        // untyped: float, even though it holds a count
@state bezRez = 0;
@state bezTrim = 0;
@state cycle = 0;

let sr = maximum(samplerate(), 1.0);
let steps: Int = maximum(trunc(clamp(window_ms, 1.0, 1000.0) * 0.001 * sr), 1);
stepped = steps;           // Int -> number
bezRez = 0.99999999 / stepped;
bezTrim = 1.0 - (bezRez * (stepped / (stepped + 1.0)));   // float division

cycle += bezRez;
if (cycle > bezTrim) cycle = 0.0;

out1 = in1 * cycle;
out2 = in2 * cycle;
