// ---------------------------------------------------------------------------
// Functions, explicit types and fixed-size arrays (codebox~)
//
// Type annotations that codebox accepts after a variable name or a function
// parameter:  number, Int, Index, list, BufferRef, DataRef
// Anything else is a parse error, in particular the fixed-array type names and
// 'auto':
//   function f(x: FixedSampleArray)   // ERROR: Unexpected Token ':'
//   function f(x: FixedFloat32Array)  // ERROR: Unexpected Token ':'
//   function f(x: auto)               // ERROR: Unexpected Token ':'
//
// Fixed-size arrays (@state b = new FixedSampleArray(N)) may be created, read,
// written and indexed from main code and from inside a function, but they may
// not be *passed* as an argument. If a helper has to deal with two buffers,
// write one helper per buffer:
// ---------------------------------------------------------------------------

@state tapBufL = new FixedSampleArray(1024);
@state tapBufR = new FixedSampleArray(1024);
@state writeIdx: Int = 0;

@param({ min: 0.0, max: 1.0 }) tap_mix = 0.5;
@param({ min: 0.0, max: 10.0 }) tap_ms = 4.0;

// Helper reads its own state buffer - the buffer is NOT an argument.
function readTapL(delSamps: number): number {
	let d = clamp(delSamps, 2.0, 1018.0);
	let readPos = writeIdx - d;
	while (readPos < 0.0) { readPos += 1024.0; }
	let idx0: Int = floor(readPos);
	return cubicinterp(readPos - idx0,
		tapBufL[(idx0 - 1 + 1024) & 1023],
		tapBufL[idx0 & 1023],
		tapBufL[(idx0 + 1) & 1023],
		tapBufL[(idx0 + 2) & 1023]);
}

function readTapR(delSamps: number): number {
	let d = clamp(delSamps, 2.0, 1018.0);
	let readPos = writeIdx - d;
	while (readPos < 0.0) { readPos += 1024.0; }
	let idx0: Int = floor(readPos);
	return cubicinterp(readPos - idx0,
		tapBufR[(idx0 - 1 + 1024) & 1023],
		tapBufR[idx0 & 1023],
		tapBufR[(idx0 + 1) & 1023],
		tapBufR[(idx0 + 2) & 1023]);
}

// Scalar parameters and locals may be typed freely; Int is required whenever a
// value is used as an array index. Return types are the exception: only
// 'number' and 'list' may be used as a function return type (': Int' or
// ': Index' is rejected), so type the local that receives it instead.
function wrapTap(start: Int, span: Int): number {
	return (start + span) & 1023;
}

tapBufL[writeIdx] = in1;
tapBufR[writeIdx] = in2;

let idx: Int = wrapTap(writeIdx, 3);
let tapL = readTapL(mstosamps(tap_ms));
let tapR = readTapR(mstosamps(tap_ms * 1.25));

writeIdx = (writeIdx + 1) & 1023;

let w = clamp(tap_mix, 0.0, 1.0);
out1 = linearinterp(w, in1, tapL) + 0.02 * tapBufL[idx];
out2 = linearinterp(w, in2, tapR);
