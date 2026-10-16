#!/usr/bin/env node
/*
 * Offline verifier for the rnbo codebox~ sources in generated_fx/.
 *
 * codebox~ sources only fail when you paste them into Max, which makes a bad
 * generation batch expensive to triage. This script runs the very same compiler
 * chain Max runs, but from the command line, over every effect at once:
 *
 *   1. @rnbo/xam expression parse   grammar + type checking (the "Unexpected
 *                                   Token ':'" / "Invalid negative Number."
 *                                   style errors, reported with line and column)
 *   2. codegen + audiocodegen       graph and DSP code generation
 *   3. cppcodegen                   C++ for the generated patcher
 *   4. clang++ -fsyntax-only        the generated C++ has to actually compile
 *
 * Stage 1 catches everything codebox itself reports. Stages 2-4 catch the
 * quieter failures, for example a helper declared as `function f(buf, i)` that
 * is handed a FixedSampleArray: codebox types `buf` as a number and the C++
 * then fails with "subscripted value is not an array".
 *
 * Each file is compiled on its own, wired to matching `in~` / `out~` objects so
 * that the DSP code for the codebox is actually emitted (an unwired codebox is
 * pruned from the generated C++, which would hide stage 2-4 problems).
 *
 * Requires a Max installation that ships the RNBO package (it provides the
 * @rnbo/xam compiler and the RNBO C++ headers) plus clang++. Point the script at
 * a different install with RNBO_PACKAGE_DIR=/path/to/RNBO or an argument in the
 * same spirit if yours is not in one of the auto-detected locations.
 *
 * Usage:
 *
 *   ./tools/verify_codebox.js                        verify generated_fx/
 *   ./tools/verify_codebox.js --docs                 ... plus the doc examples
 *   ./tools/verify_codebox.js generated_fx/FM:PD     verify specific files/dirs
 *   ./tools/verify_codebox.js --no-cxx               skip the clang++ stage
 *   ./tools/verify_codebox.js --keep /tmp/cbox-cpp   keep the generated C++
 *   ./tools/verify_codebox.js --quiet                print failures + summary
 *
 * A doc example that deliberately shows broken code can opt out with a
 * "verify: skip" marker anywhere in the file.
 *
 * Exit status: 0 = every checked file passed, 1 = at least one failure,
 * 2 = the toolchain could not be located.
 */

"use strict";

const fs = require("fs");
const os = require("os");
const path = require("path");
const { execFileSync } = require("child_process");

const ROOT = path.resolve(__dirname, "..");

// --------------------------------------------------------------------------- //
// Toolchain discovery
// --------------------------------------------------------------------------- //

const RNBO_PACKAGE_CANDIDATES = [
	process.env.RNBO_PACKAGE_DIR,
	process.env.RNBO_DIR,
	"/Applications/Max.app/Contents/Resources/C74/packages/RNBO",
	path.join(os.homedir(), "Documents/Max 9/Packages/RNBO"),
	path.join(os.homedir(), "Documents/Max 8/Packages/RNBO"),
	path.join(os.homedir(), "Documents/Max 9/Packages/RNBO/RNBO"),
].filter(Boolean);

function findRnboPackage() {
	for (const candidate of RNBO_PACKAGE_CANDIDATES) {
		if (fs.existsSync(path.join(candidate, "server/node_modules/@rnbo/xam"))) {
			return candidate;
		}
	}
	return undefined;
}

// The bundled @rnbo/xam resolves its operator tables from $RNBO_DIR/source when
// the build is a release build, which is how the copy inside Max is shipped.
function loadCompiler(packageDir) {
	process.env.RNBO_DIR = packageDir;
	return require(path.join(packageDir, "server/node_modules/@rnbo/xam"));
}

function hasClang() {
	try {
		execFileSync("clang++", ["--version"], { stdio: "pipe" });
		return true;
	}
	catch {
		return false;
	}
}

// --------------------------------------------------------------------------- //
// Input collection
// --------------------------------------------------------------------------- //

const SKIP_MARKER = "verify: skip";

function isEffectSource(name) {
	return name.endsWith(".txt") && !name.includes("paraminfo");
}

function collect(dir, out) {
	for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
		const full = path.join(dir, entry.name);
		if (entry.isDirectory()) {
			collect(full, out);
		}
		else if (isEffectSource(entry.name)) {
			out.push(full);
		}
	}
	return out;
}

function collectDocs(out) {
	const dir = path.join(ROOT, "docs/rnbo_codebox");
	if (!fs.existsSync(dir)) return out;
	for (const name of fs.readdirSync(dir).sort()) {
		if (/^example\d+\.md$/.test(name)) out.push(path.join(dir, name));
	}
	return out;
}

// --------------------------------------------------------------------------- //
// Checks
// --------------------------------------------------------------------------- //

// Strip line comments before counting in/out references so that prose in the
// header comments cannot invent inlets. Good enough for IO counting: codebox
// sources in this project do not use "//" inside string literals.
function stripLineComments(source) {
	return source
		.split("\n")
		.map((line) => {
			const comment = line.indexOf("//");
			return comment === -1 ? line : line.slice(0, comment);
		})
		.join("\n");
}

function highestReference(source, pattern) {
	let highest = 0;
	for (const match of source.matchAll(pattern)) {
		highest = Math.max(highest, Number(match[1]));
	}
	return highest;
}

function buildObjects(xam, source) {
	const code = stripLineComments(source);
	const cb = xam.createObject("codebox~", { code: source });
	const objects = [cb];
	for (let i = 1; i <= highestReference(code, /\bout(\d+)\b/g); i++) {
		const out = xam.createObject("out~", { index: i });
		objects.push(out);
		cb.connect("out" + i, out, "in1");
	}
	for (let i = 1; i <= highestReference(code, /\bin(\d+)\b/g); i++) {
		const input = xam.createObject("in~", { index: i });
		objects.push(input);
		input.connect("out1", cb, "in" + i);
	}
	return objects;
}

// Every block of generated C++ carries a trailing "//#map:_###_obj_###_:<line>"
// marker naming the codebox source line it came from, so a compiler error can be
// reported against the source the user actually pastes into Max.
function sourceLineFor(cpp, cppLine) {
	const lines = cpp.split("\n");
	for (let i = Math.min(cppLine, lines.length) - 1; i >= 0; i--) {
		const match = lines[i].match(/#map:_###_obj_###_:(\d+)/);
		if (match) return Number(match[1]);
	}
	return undefined;
}

function formatCppErrors(cpp, stderr) {
	const reported = [];
	for (const line of stderr.split("\n")) {
		const match = line.match(/^([^:\s]+):(\d+):(\d+): error: (.*)$/);
		if (!match) continue;
		const cppBase = path.basename(match[1]);
		const sourceLine = sourceLineFor(cpp, Number(match[2]));
		reported.push(
			"    " + cppBase + ":" + match[2] + ": " + match[4] +
			(sourceLine !== undefined ? "  (codebox line " + sourceLine + ")" : "")
		);
		if (reported.length === 4) break;
	}
	return reported.length ? reported.join("\n") : "    " + stderr.trim().split("\n").slice(0, 4).join("\n");
}

// The compiler logs its own stack traces to the console while it parses; the
// failure is reported through the thrown error instead, so keep the CLI output
// readable by muting the console for the duration of the compile.
function withMutedConsole(fun) {
	const log = console.log;
	const error = console.error;
	console.log = () => {};
	console.error = () => {};
	try {
		return fun();
	}
	finally {
		console.log = log;
		console.error = error;
	}
}

function checkFile(file, { xam, includeDirs, keepDir, tmpDir, runCxx }) {
	const source = fs.readFileSync(file, "utf8");
	const cpp = withMutedConsole(() => {
		const patch = xam.codegen.compile(buildObjects(xam, source), {
			classname: "verify",
			midi: false,
			patcherserial: 1,
			audiocodegen: true,
		});
		return xam.cppcodegen.generate(patch, { classname: "verify" });
	});

	const cppPath = path.join(keepDir || tmpDir, path.basename(file).replace(/\.[^.]+$/, "") + ".cpp");
	fs.writeFileSync(cppPath, cpp);

	if (!runCxx) return;

	try {
		execFileSync("clang++", ["-std=c++17", "-fsyntax-only", "-Wno-everything", ...includeDirs, cppPath], {
			stdio: "pipe",
		});
	}
	catch (error) {
		const stderr = error.stderr ? error.stderr.toString() : String(error.message);
		throw new Error("generated C++ does not compile:\n" + formatCppErrors(cpp, stderr));
	}
}

// --------------------------------------------------------------------------- //
// CLI
// --------------------------------------------------------------------------- //

function usage() {
	const header = fs.readFileSync(__filename, "utf8").split("*/")[0];
	const text = header
		.replace(/^#!.*\n/, "")
		.replace(/^\/\*+\n/, "")
		.split("\n")
		.map((line) => line.replace(/^ \* ?/, ""))
		.join("\n")
		.trimEnd();
	console.log(text);
}

function parseArgs(argv) {
	const options = { paths: [], docs: false, runCxx: true, keepDir: undefined, quiet: false };
	for (let i = 0; i < argv.length; i++) {
		const arg = argv[i];
		if (arg === "--docs") options.docs = true;
		else if (arg === "--no-cxx") options.runCxx = false;
		else if (arg === "--quiet") options.quiet = true;
		else if (arg === "--keep") options.keepDir = argv[++i];
		else if (arg === "--help" || arg === "-h") options.help = true;
		else if (arg.startsWith("-")) throw new Error("unknown option: " + arg);
		else options.paths.push(path.resolve(ROOT, arg));
	}
	return options;
}

function main(argv) {
	const options = parseArgs(argv);
	if (options.help) {
		usage();
		return 0;
	}

	const packageDir = findRnboPackage();
	if (!packageDir) {
		console.error("RNBO package not found. Tried:\n  " + RNBO_PACKAGE_CANDIDATES.join("\n  "));
		console.error("Set RNBO_PACKAGE_DIR to your RNBO package folder and re-run.");
		return 2;
	}

	if (options.runCxx && !hasClang()) {
		console.error("clang++ not found: install the Xcode command line tools, or re-run with --no-cxx.");
		return 2;
	}

	const xam = loadCompiler(packageDir);
	const rnboSource = path.join(packageDir, "source/rnbo");
	const includeDirs = [
		"-I" + path.join(rnboSource, "common"),
		"-I" + path.join(rnboSource, "src"),
		"-I" + rnboSource,
	];

	const display = (file) => {
		const relative = path.relative(ROOT, file);
		return relative.startsWith("..") ? file : relative;
	};

	const roots = options.paths.length ? options.paths : [path.join(ROOT, "generated_fx")];
	const missing = roots.filter((entry) => !fs.existsSync(entry));
	if (missing.length) {
		console.error("No such file or directory: " + missing.join(", "));
		return 2;
	}

	const files = [];
	for (const entry of roots) {
		if (fs.statSync(entry).isDirectory()) collect(entry, files);
		else files.push(entry);
	}
	if (options.docs) collectDocs(files);
	files.sort();

	if (!files.length) {
		console.error("No codebox sources found for: " + roots.join(", "));
		return 2;
	}

	if (!options.quiet) {
		console.log("RNBO package: " + packageDir);
		console.log("C++ check:    " + (options.runCxx ? "clang++ -fsyntax-only" : "skipped (--no-cxx)"));
		console.log("Checking " + files.length + " codebox source(s)\n");
	}

	const tmpDir = options.keepDir || fs.mkdtempSync(path.join(os.tmpdir(), "codebox-verify-"));
	if (options.keepDir) fs.mkdirSync(options.keepDir, { recursive: true });

	let failed = 0;
	let skipped = 0;
	for (const file of files) {
		if (fs.readFileSync(file, "utf8").includes(SKIP_MARKER)) {
			skipped++;
			if (!options.quiet) console.log("SKIP " + display(file));
			continue;
		}
		try {
			checkFile(file, { xam, includeDirs, keepDir: options.keepDir, tmpDir, runCxx: options.runCxx });
			if (!options.quiet) console.log("PASS " + display(file));
		}
		catch (error) {
			failed++;
			const location = error.loc ? " [line " + error.loc.line + " col " + error.loc.column + "]" : "";
			console.log("FAIL " + display(file) + " -> " + String(error.message).split("\n")[0] + location);
			const detail = String(error.message).split("\n").slice(1);
			if (detail.length) console.log(detail.join("\n"));
		}
	}

	if (!options.keepDir) fs.rmSync(tmpDir, { recursive: true, force: true });
	else if (!options.quiet) console.log("\nGenerated C++ written to " + display(options.keepDir));

	const checked = files.length - skipped;
	console.log("\n" + (checked - failed) + "/" + checked + " passed" + (skipped ? " (" + skipped + " skipped)" : ""));
	return failed ? 1 : 0;
}

try {
	process.exit(main(process.argv.slice(2)));
}
catch (error) {
	console.error("error: " + error.message);
	process.exit(2);
}
