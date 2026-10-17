// ---------------------------------------------------------------------------
// Circular delay lines + cubic-interpolated fractional reads (codebox~)
//
// RULE: a fixed-size array NEVER travels through a function argument.
//   function readDelay(buf: FixedSampleArray, ...)   // ERROR: Unexpected Token ':'
//   function readDelay(buf, ...)                     // parses, but codebox types
//                                                    // 'buf' as a number and the
//                                                    // generated C++ does not compile
// Either read the @state array directly inside the helper (see example18), or
// inline the read at each call site exactly as below.
// ---------------------------------------------------------------------------

@state delayBufL = new FixedSampleArray(2048);
@state delayBufR = new FixedSampleArray(2048);
@state writeIdx: Int = 0;

@param({ min: 0.5, max: 30.0 }) delay_ms = 8.0;
@param({ min: 0.0, max: 1.0 }) mix = 0.35;

let xL = in1;
let xR = in2;

// 1. Write the new sample at the write head
delayBufL[writeIdx] = xL;
delayBufR[writeIdx] = xR;

// 2. Fractional read, 4-point cubic interpolation (2 samples of headroom at the
//    top of the buffer keeps the +2 tap in range)
let delSamps = clamp(mstosamps(delay_ms), 2.0, 2042.0);

let readPosL = writeIdx - delSamps;
while (readPosL < 0.0) { readPosL += 2048.0; }
let idx0L: Int = floor(readPosL);
let wetL = cubicinterp(readPosL - idx0L,
	delayBufL[(idx0L - 1 + 2048) & 2047],
	delayBufL[idx0L & 2047],
	delayBufL[(idx0L + 1) & 2047],
	delayBufL[(idx0L + 2) & 2047]);

let readPosR = writeIdx - delSamps;
while (readPosR < 0.0) { readPosR += 2048.0; }
let idx0R: Int = floor(readPosR);
let wetR = cubicinterp(readPosR - idx0R,
	delayBufR[(idx0R - 1 + 2048) & 2047],
	delayBufR[idx0R & 2047],
	delayBufR[(idx0R + 1) & 2047],
	delayBufR[(idx0R + 2) & 2047]);

// 3. Advance the head (buffer size is a power of two, so mask instead of modulo)
writeIdx = (writeIdx + 1) & 2047;

let w = clamp(mix, 0.0, 1.0);
out1 = linearinterp(w, xL, wetL);
out2 = linearinterp(w, xR, wetR);
