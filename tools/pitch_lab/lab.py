#!/usr/bin/env python3
"""pitch_lab — build, run and score tuba pitch trackers against labelled recordings.

The loop that produced generated_fx/ai_pitch_tracker/tuba_freq_tracker_v3.txt:
decode the recordings, derive per-note ground truth, run a C++ prototype and the
RNBO-generated C++ of a codebox~ over them, and score latency and accuracy.
See tools/pitch_lab/README.md for the walk-through.

  lab.py decode   [--recs DIR] [--sr 44100]
  lab.py truth    [--recs DIR] [-v]
  lab.py build    proto
  lab.py build    rnbo SRC.txt [--name N] [--set name=value ...] [--dyn name]
  lab.py run      BIN TAG [name=value ...] [--sr 44100] [--in3 v0,v1@t] [--only SUBSTR]
  lab.py score    TAG [--ref steady|oracle] [--after SECONDS] [-v]
  lab.py compare  TAG_A TAG_B
  lab.py sweep    '{"name": [v1, v2], ...}' [name=value ...]

Needs numpy + scipy (re-runs itself under `uv run --with numpy --with scipy` if
they are missing), ffmpeg, clang++, node, and a Max install with RNBO.
Work files go to tools/pitch_lab/work/ (git-ignored; override with PITCH_LAB_WORK).
"""
import os
import sys

try:
    import numpy as np
    from scipy.signal import butter, sosfiltfilt
except ImportError:
    if os.environ.get("PITCH_LAB_REEXEC") or not any(
        os.access(os.path.join(p, "uv"), os.X_OK) for p in os.environ.get("PATH", "").split(os.pathsep)
    ):
        sys.exit("pitch_lab needs numpy and scipy (or `uv` on PATH to fetch them).")
    os.environ["PITCH_LAB_REEXEC"] = "1"
    os.execvp("uv", ["uv", "run", "--quiet", "--with", "numpy", "--with", "scipy",
                     "python3", os.path.abspath(__file__), *sys.argv[1:]])

import argparse
import glob
import hashlib
import itertools
import json
import re
import subprocess

LAB = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(os.path.dirname(LAB))
WORK = os.environ.get("PITCH_LAB_WORK", os.path.join(LAB, "work"))
RECS = os.path.join(REPO, "tuba_recs")
SR = 44100
RNBO_CANDIDATES = [
    os.environ.get("RNBO_PACKAGE_DIR"), os.environ.get("RNBO_DIR"),
    "/Applications/Max.app/Contents/Resources/C74/packages/RNBO",
    os.path.expanduser("~/Documents/Max 9/Packages/RNBO"),
    os.path.expanduser("~/Documents/Max 8/Packages/RNBO"),
]


def w(*parts):
    return os.path.join(WORK, *parts)


def names(sr=SR):
    return sorted(os.path.basename(p)[:-4] for p in glob.glob(w(f"wav{sr}", "*.f32")))


# --------------------------------------------------------------------------- #
# Labels: the intended note sequence of each recording
# --------------------------------------------------------------------------- #
PC = {"C": 0, "D": 2, "E": 4, "F": 5, "G": 7, "A": 9, "B": 11}
FMAJ_UP = [29, 31, 33, 34, 36, 38, 40, 41, 43, 45, 46, 48, 50, 52, 53]   # F1..F3
BUILTIN = [
    (r"Fmaj_2oct", FMAJ_UP + FMAJ_UP[-2::-1]),          # 2-octave F major, up and down
    (r"chromatic_Bb-D", list(range(46, 25, -1))),         # Bb2 down to D1
]


def note_to_midi(tok):
    if re.fullmatch(r"\d+", tok):
        return int(tok)
    m = re.fullmatch(r"([A-Ga-g])([#b]*)(-?\d)", tok)
    if not m:
        raise ValueError(f"bad note '{tok}' (use e.g. Bb1, F#2, D1 or a MIDI number)")
    return 12 * (int(m.group(3)) + 1) + PC[m.group(1).upper()] + m.group(2).count("#") - m.group(2).count("b")


def labels(name, recs):
    side = os.path.join(recs, name + ".notes")
    if os.path.exists(side):
        txt = re.sub(r"#.*", "", open(side).read())
        return [note_to_midi(t) for t in re.split(r"[\s,]+", txt) if t]
    for pat, seq in BUILTIN:
        if re.search(pat, name):
            return seq
    return None


# --------------------------------------------------------------------------- #
# decode
# --------------------------------------------------------------------------- #
def cmd_decode(a):
    os.makedirs(w(f"wav{a.sr}"), exist_ok=True)
    files = sorted(f for ext in ("aif", "aiff", "wav", "flac") for f in glob.glob(os.path.join(a.recs, "*." + ext)))
    if not files:
        sys.exit(f"no recordings in {a.recs}")
    for f in files:
        out = w(f"wav{a.sr}", os.path.splitext(os.path.basename(f))[0] + ".f32")
        subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", f, "-ac", "1", "-ar", str(a.sr), "-f", "f32le", out], check=True)
        print(f"{os.path.basename(f)} -> {os.path.relpath(out, REPO)}")


# --------------------------------------------------------------------------- #
# truth: centered (non-causal) YIN track, aligned to the labelled note sequence
# --------------------------------------------------------------------------- #
def load(name, sr=SR):
    return np.fromfile(w(f"wav{sr}", name + ".f32"), dtype=np.float32).astype(np.float64)


def midi(f):
    return 69 + 12 * np.log2(np.maximum(f, 1e-9) / 440.0)


def centered_yin(x, win, hop, fmin=25, fmax=400, th=0.2):
    """Frame-wise YIN/CMNDF with the frame centred on each time stamp (looks ahead)."""
    minlag, maxlag = int(SR / fmax), int(SR / fmin)
    half = (win + maxlag) // 2
    taus = np.arange(1, maxlag + 1)
    nfft = 1 << int(np.ceil(np.log2(2 * win + maxlag)))
    T, F, A, R = [], [], [], []
    for c in range(half, len(x) - half, hop):
        fr = x[c - half:c - half + win + maxlag]
        x0 = fr[:win]
        e = np.cumsum(fr ** 2)
        rr = np.fft.irfft(np.fft.rfft(fr, nfft) * np.conj(np.fft.rfft(x0, nfft)), nfft)[:maxlag + 1]
        d = np.maximum(e[win - 1] + (e[taus + win - 1] - e[taus - 1]) - 2 * rr[1:], 0)
        cm = d * taus / np.maximum(np.cumsum(d), 1e-20)
        best = None
        i = minlag - 1
        while i < maxlag - 1:
            if cm[i] < th:
                while i + 1 < maxlag - 1 and cm[i + 1] < cm[i]:
                    i += 1
                best = i
                break
            i += 1
        if best is None:
            best = minlag - 1 + int(np.argmin(cm[minlag - 1:maxlag - 1]))
        y1, y2, y3 = cm[best - 1], cm[best], cm[best + 1]
        den = y1 - 2 * y2 + y3
        dl = 0.5 * (y1 - y3) / den if abs(den) > 1e-12 else 0.0
        T.append(c / SR); F.append(SR / (best + 1 + dl)); A.append(cm[best]); R.append(np.sqrt(e[win - 1] / win))
    return np.array(T), np.array(F), np.array(A), np.array(R)


def align(M, voiced, exp, g):
    """Monotone (DTW-like) assignment of frames to the expected notes."""
    N, K, INF = len(M), len(exp), 1e18
    C = np.zeros((N, K))
    for k, e in enumerate(exp):
        C[:, k] = np.where(voiced, np.minimum(np.abs(M - (e + g)), 1.5), 0.0)
    D = np.full((N, K), INF)
    P = np.zeros((N, K), dtype=np.int8)
    D[0, 0] = C[0, 0]
    for t in range(1, N):
        stay, adv = D[t - 1], np.concatenate([[INF], D[t - 1, :-1]])
        P[t] = adv < stay
        D[t] = np.minimum(stay, adv) + C[t]
    lab, k = np.zeros(N, dtype=int), K - 1
    for t in range(N - 1, -1, -1):
        lab[t] = k
        if P[t, k]:
            k -= 1
    return lab


def truth_for(name, exp, verbose):
    os.makedirs(w("truth"), exist_ok=True)
    x = sosfiltfilt(butter(2, [20, 1200], btype="band", fs=SR, output="sos"), load(name))
    cache = w("truth", name + "_track.npz")
    if os.path.exists(cache) and os.path.getmtime(cache) > os.path.getmtime(w(f"wav{SR}", name + ".f32")):
        z = np.load(cache); T, F, A, R = z["T"], z["F"], z["A"], z["R"]
    else:
        T, F, A, R = centered_yin(x, win=int(0.045 * SR), hop=88)
        np.savez(cache, T=T, F=F, A=A, R=R)
    M = midi(F)
    voiced = (A < 0.3) & (R > np.percentile(R, 99) * 10 ** (-30 / 20))
    env = np.sqrt(np.convolve(x ** 2, np.ones(220) / 220, "same"))
    g = -0.25   # global tuning offset in semitones, re-estimated
    for _ in range(3):
        lab = align(M, voiced, exp, g)
        dev = np.array([M[t] - exp[lab[t]] for t in range(len(M)) if voiced[t] and abs(M[t] - exp[lab[t]] - g) < 1.0])
        g = float(np.median(dev))
    notes, prev_last = [], None
    for k, e in enumerate(exp):
        idx = np.where((lab == k) & voiced & (np.abs(M - (e + g)) < 0.9))[0]
        if len(idx) == 0:
            print(f"  {name}: note {k} ({e}) not found, skipped")
            continue
        mid = idx[len(idx) // 4:len(idx) - len(idx) // 4 + 1] if len(idx) > 4 else idx
        med = float(np.median(M[mid]))
        good = idx[np.abs(M[idx] - med) < 0.4]
        runs, st, pv = [], good[0], good[0]           # longest run without a hole > 20 ms
        for gi in good[1:]:
            if gi - pv > 10:
                runs.append((st, pv)); st = gi
            pv = gi
        runs.append((st, pv))
        first, last = max(runs, key=lambda r: r[1] - r[0])
        t0, t1 = T[first], T[last]
        kind = "attack" if prev_last is None or np.any(~voiced[prev_last + 1:first]) else "legato"
        if kind == "attack":      # energy onset: back from t0 to 15 % of the note level
            lvl = np.median(env[int(t0 * SR):int(t1 * SR) + 1])
            lo = int(T[prev_last] * SR) if prev_last is not None else 0
            s = int(t0 * SR)
            while s > lo and env[s] > 0.15 * lvl:
                s -= 1
            on = s / SR
            if prev_last is not None and s <= lo:
                on, kind = 0.5 * (T[prev_last] + t0), "legato"
        else:                     # legato: middle of the gap between the two stable regions
            on = 0.5 * (T[prev_last] + t0)
        prev_last = last
        notes.append(dict(on=on, stable=t0, off=t1, f=440 * 2 ** ((med - 69) / 12), midi=med, exp=e, kind=kind))
        if verbose:
            print(f"  {k:2d} on {on:7.3f} [{kind:6s}] stable {t0:7.3f}-{t1:7.3f} midi {med:6.2f} exp {e} dev {med - e:+.2f}")
    json.dump(notes, open(w("truth", name + ".json"), "w"), indent=0)
    # oracle: the centred track itself as a "tracker" (looks ahead; a floor, not a target)
    os.makedirs(w("out", "oracle"), exist_ok=True)
    t = np.arange(len(x)) / SR
    o = np.zeros((len(x), 4), dtype=np.float32)
    o[:, 0] = np.interp(t, T, np.where(A < 0.3, F, 0))
    o.tofile(w("out", "oracle", name + ".f32"))
    json.dump(dict(nch=4, sr=SR), open(w("out", "oracle", "meta.json"), "w"))
    worst = max(abs(q["midi"] - q["exp"]) for q in notes)
    print(f"{name}: {len(notes)}/{len(exp)} notes, tuning {g:+.2f} st, largest deviation {worst:.2f} st")
    if worst > 1.2:
        print("  WARNING: a note sits > 1.2 st from its label; check the .notes file / alignment (-v)")


def cmd_truth(a):
    todo = [(n, labels(n, a.recs)) for n in names()]
    for n, exp in todo:
        if exp is None:
            print(f"{n}: no labels (add {os.path.relpath(os.path.join(a.recs, n + '.notes'), REPO)}), skipped")
        else:
            truth_for(n, exp, a.verbose)


# --------------------------------------------------------------------------- #
# build
# --------------------------------------------------------------------------- #
def rnbo_dir():
    for c in RNBO_CANDIDATES:
        if c and os.path.isdir(os.path.join(c, "source", "rnbo")):
            return c
    sys.exit("RNBO package not found; set RNBO_PACKAGE_DIR")


def make_variant(src, sets, dyn):
    """Bake @param defaults in (--set) or read one @param from in3 (--dyn)."""
    s = open(src).read()
    for kv in sets:
        k, v = kv.split("=", 1)
        s, n = re.subn(r"(@param\(\{[^}]*\}\) " + re.escape(k) + r" = )[^;]+;", r"\g<1>" + v + ";", s)
        if n != 1:
            sys.exit(f"--set: no @param named {k}")
    if dyn:
        s, n = re.subn(r"// [^\n]*\n@param\(\{[^}]*\}\) " + re.escape(dyn) + r" = [^;]+;\n", "", s)
        if n != 1:
            sys.exit(f"--dyn: no @param named {dyn} (with its // label line)")
        anchor = "let sr = maximum(samplerate(), 1.0);\n"
        if anchor not in s:
            sys.exit(f"--dyn needs the line '{anchor.strip()}' to insert after")
        s = s.replace(anchor, anchor + f"let {dyn} = in3;\n", 1)
    return s


def cmd_build(a):
    os.makedirs(w("bin"), exist_ok=True)
    if a.what == "proto":
        subprocess.run(["clang++", "-std=c++17", "-O2", os.path.join(LAB, "proto.cpp"), "-o", w("bin", "proto")], check=True)
        print("built", os.path.relpath(w("bin", "proto"), REPO))
        return
    if not a.src:
        sys.exit("build rnbo needs SRC.txt")
    src = os.path.abspath(a.src)
    name = a.name or os.path.splitext(os.path.basename(src))[0]
    if a.set or a.dyn:
        os.makedirs(w("src"), exist_ok=True)
        var = w("src", name + ".txt")
        open(var, "w").write(make_variant(src, a.set, a.dyn))
        src = var
    os.makedirs(w("cpp"), exist_ok=True)
    subprocess.run(["node", os.path.join(REPO, "tools", "verify_codebox.js"), "--keep", w("cpp"), src], check=True)
    cpp = w("cpp", os.path.splitext(os.path.basename(src))[0] + ".cpp")
    rsrc = os.path.join(rnbo_dir(), "source", "rnbo")
    inc = ["-I" + rsrc, "-I" + os.path.join(rsrc, "common"), "-I" + os.path.join(rsrc, "src")]
    obj = w("bin", "rnbo.o")
    if not os.path.exists(obj):
        print("compiling RNBO.cpp once ...")
        subprocess.run(["clang++", "-std=c++17", "-O2", "-w", *inc, "-c", os.path.join(rsrc, "RNBO.cpp"), "-o", obj], check=True)
    subprocess.run(["clang++", "-std=c++17", "-O2", "-w", *inc, os.path.join(LAB, "rnbo_harness.cpp"), cpp, obj,
                    "-o", w("bin", name)], check=True)
    print("built", os.path.relpath(w("bin", name), REPO))


# --------------------------------------------------------------------------- #
# run
# --------------------------------------------------------------------------- #
def run_bin(bin_, tag, params, sr=SR, in3=None, only=None, quiet=False):
    exe = bin_ if os.sep in bin_ else w("bin", bin_)
    if not os.path.exists(exe):
        sys.exit(f"no binary {exe} (lab.py build ...)")
    is_proto = os.path.basename(exe) == "proto"
    if params and not is_proto:
        sys.exit("RNBO binaries take no name=value: bake values in with `build rnbo --set` or drive one with --dyn/--in3")
    out = w("out", tag)
    os.makedirs(out, exist_ok=True)
    env = dict(os.environ, SR=str(sr))
    if in3:
        env["IN3"] = in3
    procs = []
    todo = [n for n in names(sr) if not only or only in n]
    if not todo:
        sys.exit(f"nothing decoded at {sr} Hz (lab.py decode --sr {sr})")
    for n in todo:
        procs.append(subprocess.Popen([exe, w(f"wav{sr}", n + ".f32"), os.path.join(out, n + ".f32"), *params], env=env,
                                      stderr=subprocess.DEVNULL if quiet else None))
    for p in procs:
        if p.wait():
            sys.exit(f"{exe} failed")
    n0 = todo[0]
    nsamp = len(np.fromfile(w(f"wav{sr}", n0 + ".f32"), dtype=np.float32))
    nout = os.path.getsize(os.path.join(out, n0 + ".f32")) // 4
    nframes = nsamp if is_proto else (nsamp // 64) * 64
    json.dump(dict(nch=nout // nframes, sr=sr, bin=bin_, params=params, in3=in3), open(os.path.join(out, "meta.json"), "w"))


def cmd_run(a):
    run_bin(a.bin, a.tag, a.params, a.sr, a.in3, a.only)
    print("wrote", os.path.relpath(w("out", a.tag), REPO))


# --------------------------------------------------------------------------- #
# score
# --------------------------------------------------------------------------- #
def read_out(tag, n):
    meta = json.load(open(w("out", tag, "meta.json")))
    y = np.fromfile(w("out", tag, n + ".f32"), dtype=np.float32).reshape(-1, meta["nch"])[:, 0].astype(np.float64)
    if meta["sr"] != SR:   # put the output on the 44.1 kHz truth timeline
        t = np.arange(int(len(y) * SR / meta["sr"])) / SR
        y = np.interp(t, np.arange(len(y)) / meta["sr"], y)
    return y


def score(f, notes, orc=None, tol=50.0, hold=0.03):
    """Per note: lat = time from onset until the output stays within tol cents for
    `hold` s; acc = share of the stable part within tol; octv = share an octave off;
    junk = share of the gap before an attack that matches neither neighbour."""
    res, prevf, prevoff = [], None, 0.0
    H = int(hold * SR)
    for q in notes:
        a, b = int(q["on"] * SR), int(q["off"] * SR)
        seg = f[a:b]
        ref = q["f"] if orc is None else np.where(orc[a:b] > 0, orc[a:b], q["f"])
        err = 1200 * np.log2(np.maximum(seg, 1e-3) / ref)
        ok = np.abs(err) < tol
        bad = np.where(~ok)[0]
        lat = None
        for i in range(0, len(ok), 22):
            if not ok[i]:
                continue
            j = np.searchsorted(bad, i)
            nxt = bad[j] if j < len(bad) else len(ok)
            if nxt - i >= min(H, len(ok) - i):
                lat = i / SR
                break
        body = err[max(int(q["stable"] * SR) - a, 0):]
        junk = 0.0
        if q["kind"] == "attack" and prevf is not None:
            pre = f[max(int((q["on"] - 0.15) * SR), int(prevoff * SR)):a]
            if len(pre):
                c1 = np.abs(1200 * np.log2(np.maximum(pre, 1e-3) / prevf))
                c2 = np.abs(1200 * np.log2(np.maximum(pre, 1e-3) / q["f"]))
                junk = float(np.mean((c1 > 100) & (c2 > 100)))
        prevf, prevoff = q["f"], q["off"]
        res.append(dict(lat=lat, kind=q["kind"], exp=q["exp"], f=q["f"], junk=junk,
                        acc=float(np.mean(np.abs(body) < tol)) if len(body) else 0.0,
                        octv=float(np.mean(np.abs(np.abs(body) - 1200) < 300)) if len(body) else 0.0,
                        med=float(np.median(np.abs(body))) if len(body) else 999.0))
    return res


def stats(rs):
    lats = [r["lat"] for r in rs if r["lat"] is not None]
    pct = lambda v, p: np.percentile(v, p) * 1000 if len(v) else float("nan")
    att = [r["lat"] for r in rs if r["lat"] is not None and r["kind"] == "attack"]
    leg = [r["lat"] for r in rs if r["lat"] is not None and r["kind"] == "legato"]
    attacks = [r["junk"] for r in rs if r["kind"] == "attack"]
    return dict(n=len(rs), fail=sum(r["lat"] is None for r in rs), med=pct(lats, 50), p90=pct(lats, 90),
                att=pct(att, 50), leg=pct(leg, 50), acc=100 * np.mean([r["acc"] for r in rs]),
                oct=100 * np.mean([r["octv"] for r in rs]), err=np.median([r["med"] for r in rs]),
                junk=100 * np.mean(attacks) if attacks else 0.0)


def line(label, s):
    return (f"{label:30s} notes={s['n']:3d} fail={s['fail']:2d} | to note: median {s['med']:5.1f} p90 {s['p90']:5.1f} ms "
            f"(attack {s['att']:5.1f}, legato {s['leg']:5.1f}) | in-note acc {s['acc']:5.1f}% oct {s['oct']:4.1f}% "
            f"med|err| {s['err']:4.1f}c | junk {s['junk']:4.1f}%")


def score_tag(tag, ref="steady", after=None):
    per = {}
    for n in names():
        tp = w("truth", n + ".json")
        if not os.path.exists(tp) or not os.path.exists(w("out", tag, n + ".f32")):
            continue
        notes = json.load(open(tp))
        orc = read_out("oracle", n) if ref == "oracle" else None
        rs = score(read_out(tag, n), notes, orc)
        if after is not None:
            rs = [r for r, q in zip(rs, notes) if q["on"] > after]
        fast = np.median([q["off"] - q["on"] for q in notes]) < 0.5
        per[n] = (rs, fast, notes)
    if not per:
        sys.exit(f"nothing to score for '{tag}' (run `lab.py truth` and `lab.py run`)")
    return per


def cmd_score(a):
    per = score_tag(a.tag, a.ref, a.after)
    if a.verbose:
        for n, (rs, _, notes) in per.items():
            print(line(n, stats(rs)))
            for r in rs:
                lat = "FAIL" if r["lat"] is None else f"{r['lat'] * 1000:5.1f}"
                print(f"    exp {r['exp']:2d} f={r['f']:6.1f} {r['kind']:6s} to-note {lat} ms  acc {r['acc'] * 100:5.1f}%  med|err| {r['med']:5.1f}c")
    print(f"[{a.tag} vs {a.ref}]")
    fast = sum((rs for rs, f, _ in per.values() if f), [])
    slow = sum((rs for rs, f, _ in per.values() if not f), [])
    if fast:
        print(line("fast runs (notes < 0.5 s)", stats(fast)))
    if slow:
        print(line("slow notes", stats(slow)))
    print(line("ALL", stats(fast + slow)))


def cmd_compare(a):
    for n in names():
        if not (os.path.exists(w("out", a.a, n + ".f32")) and os.path.exists(w("out", a.b, n + ".f32"))):
            continue
        x, y = read_out(a.a, n), read_out(a.b, n)
        N = min(len(x), len(y))
        x, y = x[:N], y[:N]
        start = max(np.argmax(x > 0), np.argmax(y > 0))   # after both have produced a pitch
        m = (x > 0) & (y > 0) & (np.arange(N) > start)
        c = np.abs(1200 * np.log2(x[m] / y[m]))
        print(f"{n:32s} max {c.max():9.4f} c  p99.9 {np.percentile(c, 99.9):8.4f} c  >1 c: {np.mean(c > 1) * 100:6.3f}%")


# --------------------------------------------------------------------------- #
# sweep (prototype only)
# --------------------------------------------------------------------------- #
def cmd_sweep(a):
    grid = json.loads(a.grid)
    base = dict(kv.split("=", 1) for kv in a.params)
    keys = list(grid)
    print("cost = median + p90/2 + 300*(1-acc) + 2000*oct + 100*junk   (scored vs the oracle track)")
    for vals in itertools.product(*[grid[k] for k in keys]):
        p = dict(base); p.update({k: str(v) for k, v in zip(keys, vals)})
        args = [f"{k}={v}" for k, v in sorted(p.items())]
        tag = "sweep/" + hashlib.md5(" ".join(args).encode()).hexdigest()[:10]
        run_bin("proto", tag, args, quiet=True)
        rs = sum((r for r, _, _ in score_tag(tag, "oracle").values()), [])
        s = stats(rs)
        cost = s["med"] + 0.5 * s["p90"] + 3 * (100 - s["acc"]) + 20 * s["oct"] + s["junk"]
        print(" ".join(f"{k}={v}" for k, v in zip(keys, vals)),
              f"| median {s['med']:5.1f} p90 {s['p90']:5.1f} acc {s['acc']:5.1f} oct {s['oct']:4.2f} junk {s['junk']:4.1f} | cost {cost:6.1f}",
              flush=True)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("decode"); p.add_argument("--recs", default=RECS); p.add_argument("--sr", type=int, default=SR)
    p.set_defaults(fn=cmd_decode)
    p = sub.add_parser("truth"); p.add_argument("--recs", default=RECS); p.add_argument("-v", "--verbose", action="store_true")
    p.set_defaults(fn=cmd_truth)
    p = sub.add_parser("build"); p.add_argument("what", choices=["proto", "rnbo"]); p.add_argument("src", nargs="?")
    p.add_argument("--name"); p.add_argument("--set", action="append", default=[]); p.add_argument("--dyn")
    p.set_defaults(fn=cmd_build)
    p = sub.add_parser("run"); p.add_argument("bin"); p.add_argument("tag"); p.add_argument("params", nargs="*")
    p.add_argument("--sr", type=int, default=SR); p.add_argument("--in3"); p.add_argument("--only")
    p.set_defaults(fn=cmd_run)
    p = sub.add_parser("score"); p.add_argument("tag"); p.add_argument("--ref", choices=["steady", "oracle"], default="steady")
    p.add_argument("--after", type=float); p.add_argument("-v", "--verbose", action="store_true")
    p.set_defaults(fn=cmd_score)
    p = sub.add_parser("compare"); p.add_argument("a"); p.add_argument("b"); p.set_defaults(fn=cmd_compare)
    p = sub.add_parser("sweep"); p.add_argument("grid"); p.add_argument("params", nargs="*"); p.set_defaults(fn=cmd_sweep)
    a = ap.parse_args()
    a.fn(a)


if __name__ == "__main__":
    main()
