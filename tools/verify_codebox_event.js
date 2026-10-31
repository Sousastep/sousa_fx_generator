#!/usr/bin/env node
/*
 * Offline verifier for event-domain rnbo `codebox` sources (no tilde).
 *
 * tools/verify_codebox.js always builds a `codebox~`, so it cannot check the
 * message-domain object: inlet functions, `listout1`, `post()` and the other
 * codebox-only rules differ. This script drives the validator from the
 * tools/rnbo-codebox-extension submodule instead, in two passes:
 *
 *   1. core     the extension's built-in diagnostics (undefined names, type
 *               mismatches, codebox vs codebox~ availability, ...)
 *   2. strict   the extension's Local Strict Mode: Max's own @rnbo/xam parses
 *               the source as a `codebox`, generates C++ and checks it with
 *               clang++ -fsyntax-only
 *
 * Errors it reproduces that Max prints in the console:
 *   - "An inlet function has to have exactly one argument."  (function in2() {})
 *   - "no viable conversion from 'list' ... to 'number'"      (out1 = someList;
 *     a list must go to listout1)
 *
 * Requires a Max installation that ships the RNBO package, clang++, and the
 * extension's compiled validator. Build that once with
 *
 *   git submodule update --init tools/rnbo-codebox-extension
 *   (cd tools/rnbo-codebox-extension && npm install && npm run compile:validation)
 *
 * Point at a different RNBO install with RNBO_PACKAGE_DIR=/path/to/RNBO.
 *
 * Usage:
 *
 *   ./tools/verify_codebox_event.js file.txt [more files...]
 *   ./tools/verify_codebox_event.js --kind codebox~ file.txt   check as codebox~
 *   ./tools/verify_codebox_event.js --no-strict file.txt       core pass only
 *
 * Exit status: 0 = every file passed, 1 = at least one failure,
 * 2 = the toolchain could not be located.
 */

"use strict";

const fs = require("fs");
const os = require("os");
const path = require("path");

const EXT = path.join(__dirname, "rnbo-codebox-extension");

const RNBO_PACKAGE_CANDIDATES = [
	process.env.RNBO_PACKAGE_DIR,
	process.env.RNBO_DIR,
	"/Applications/Max.app/Contents/Resources/C74/packages/RNBO",
	path.join(os.homedir(), "Documents/Max 9/Packages/RNBO"),
	path.join(os.homedir(), "Documents/Max 8/Packages/RNBO"),
].filter(Boolean);

function findXam() {
	for (const candidate of RNBO_PACKAGE_CANDIDATES) {
		const xam = path.join(candidate, "server/node_modules/@rnbo/xam");
		if (fs.existsSync(xam)) return xam;
	}
	return undefined;
}

function loadExtension() {
	try {
		const { TextDocument } = require(path.join(EXT, "node_modules/vscode-languageserver-textdocument"));
		const { validateRnboDocumentCore } = require(path.join(EXT, "server/out/validationCore.js"));
		const strict = require(path.join(EXT, "server/out/strict/localStrictValidation.js"));
		return { TextDocument, validateRnboDocumentCore, strict };
	} catch (error) {
		console.error(`Cannot load the rnbo-codebox-extension validator: ${error.message}`);
		console.error("Build it with: (cd tools/rnbo-codebox-extension && npm install && npm run compile:validation)");
		return undefined;
	}
}

function parseArgs(argv) {
	const options = { kind: "codebox", strict: true, files: [] };
	for (let i = 0; i < argv.length; i++) {
		const arg = argv[i];
		if (arg === "--kind") options.kind = argv[++i];
		else if (arg === "--no-strict") options.strict = false;
		else options.files.push(arg);
	}
	return options;
}

function report(file, tag, diagnostics) {
	for (const d of diagnostics) {
		const level = d.severity === 1 ? "ERROR" : "WARN";
		console.log(`  [${tag}] ${level} ${file}:${d.range.start.line + 1}:${d.range.start.character + 1} ${d.message}`);
	}
}

async function main() {
	const options = parseArgs(process.argv.slice(2));
	if (options.files.length === 0 || !["codebox", "codebox~"].includes(options.kind)) {
		console.error("usage: verify_codebox_event.js [--kind codebox|codebox~] [--no-strict] <file>...");
		return 2;
	}

	const ext = loadExtension();
	if (!ext) return 2;
	const xamPackagePath = options.strict ? findXam() : "";
	if (options.strict && !xamPackagePath) {
		console.error("RNBO package not found. Set RNBO_PACKAGE_DIR to your RNBO package folder and re-run.");
		return 2;
	}
	const strictSettings = ext.strict.normalizeLocalStrictModeSettings({ enabled: options.strict, xamPackagePath });

	let failures = 0;
	for (const file of options.files) {
		const source = fs.readFileSync(file, "utf8");
		const doc = ext.TextDocument.create(`file://${path.resolve(file)}`, "rnbo-codebox", 1, source);
		const core = ext.validateRnboDocumentCore(doc, { enableStrictValidation: true, codeboxKind: options.kind });
		const strict = await ext.strict.runLocalStrictValidation(doc, strictSettings, options.kind);
		const count = core.length + strict.length;
		console.log(`${count ? "FAIL" : "PASS"} ${file} (${options.kind})`);
		report(file, "core", core);
		report(file, "strict", strict);
		if (count) failures++;
	}

	console.log(`${options.files.length - failures}/${options.files.length} passed`);
	return failures ? 1 : 0;
}

main().then((code) => {
	process.exitCode = code;
});
