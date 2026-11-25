"""Plants one deliberate bug at a time in lib/ and reports which tests notice.

A test suite that passes proves little until it has been seen to fail. This
script changes one line of the engine (above and below swapped, a wall that
no longer stops the view, a tick given too early...), runs the tests, puts
the line back, and goes on to the next. A bug the tests miss is a gap to
close with a new test. See docs/testing/Exploratory.md.

  py -3 tool/plant_bugs.py                 against test/explore (about 6 minutes)
  py -3 tool/plant_bugs.py test            against the whole suite

Not a commit gate: it is slow, and it edits lib/ while it runs. Run it on a
clean working tree; every file is restored even if the run is stopped, but
check `git status` afterwards. Exit code 1 when a bug is missed or a bug
could not be planted (the line it changes has moved: update the list).
"""
import pathlib
import subprocess
import sys

REPO = pathlib.Path(__file__).resolve().parent.parent
SUITES = sys.argv[1:] or ["test/explore"]

M = [
    ("beside ignores the area", "lib/engine/clue.dart",
     "          c.cells[o].area == c.cells[cell].area &&\n", ""),
    ("above and below swapped", "lib/engine/clue.dart",
     "return same && (a == 0 || dr.sign == a) && (b == 0 || dc.sign == b);",
     "return same && (a == 0 || dr.sign == -a!) && (b == 0 || dc.sign == b);"),
    ("left and right swapped in the meaning", "lib/engine/clue.dart",
     "return same && (a == 0 || dr.sign == a) && (b == 0 || dc.sign == b);",
     "return same && (a == 0 || dr.sign == a) && (b == 0 || dc.sign == -b!);"),
    ("offset ignores direction", "lib/engine/clue.dart",
     "return same && (a == null || dr == a) && (b == null || dc == b);",
     "return same && (a == null || dr.abs() == a!.abs()) && (b == null || dc == b);"),
    ("distance is the larger axis", "lib/engine/clue.dart",
     "return same && dr.abs() + dc.abs() == a;",
     "return same && (dr.abs() > dc.abs() ? dr.abs() : dc.abs()) == a;"),
    ("direction works across grids", "lib/engine/clue.dart",
     "return same && (a == 0 || dr.sign == a) && (b == 0 || dc.sign == b);",
     "return (a == 0 || dr.sign == a) && (b == 0 || dc.sign == b);"),
    ("grid corner needs all sides", "lib/engine/clue.dart",
     "    return (out(Side.north) || out(Side.south)) &&\n        (out(Side.west) || out(Side.east));",
     "    return (out(Side.north) && out(Side.south)) &&\n        (out(Side.west) || out(Side.east));"),
    ("area corner counts outline only", "lib/engine/clue.dart",
     "    bool wall(Side s) => c.isWall(cell, s);",
     "    bool wall(Side s) => c.neighbor(cell, s) < 0;"),
    ("seeing goes through walls", "lib/engine/clue.dart",
     "        if (c.isWall(at, s) && c.openingAt(at, s) == null) break;\n", ""),
    ("seeing goes through objects", "lib/engine/clue.dart",
     "        if (k >= 0) break;\n", ""),
    ("an object in my row may be my own square", "lib/engine/clue.dart",
     "if (o.grid != me.grid || o.kind != kind || o.index == cell) continue;",
     "if (o.grid != me.grid || o.kind != kind) continue;"),
    ("alone forgets the victim", "lib/engine/clue.dart",
     "      if (p != subject && c.cells[pos[p]].area == area) return false;",
     "      if (p != subject && p != c.victim && c.cells[pos[p]].area == area) return false;"),
    ("same row is allowed", "lib/engine/model.dart",
     "    return x.grid == y.grid && (x.row == y.row || x.col == y.col);",
     "    return x.grid == y.grid && (x.col == y.col);"),
    ("the victim may have two companions", "lib/engine/model.dart",
     "      if (found >= 0) return -1;\n", ""),
    ("a door counts from one side only", "lib/engine/model.dart",
     "      if (n >= 0 && o.cell == n && o.side == back) return o;\n", ""),
    ("touching ignores diagonals", "lib/engine/model.dart",
     "        (x.row - y.row).abs() <= 1 &&\n        (x.col - y.col).abs() <= 1;",
     "        (x.row - y.row).abs() + (x.col - y.col).abs() <= 1;"),
    ("column letters start at B", "lib/engine/model.dart",
     "String colLabel(int col) => String.fromCharCode(65 + col);",
     "String colLabel(int col) => String.fromCharCode(66 + col);"),
    ("sentence says left for right", "lib/engine/wording.dart",
     "final h = b == -1 ? '**left**' : '**right**';",
     "final h = b == -1 ? '**right**' : '**left**';"),
    ("sentence says above for below", "lib/engine/wording.dart",
     "final v = a == -1 ? '**above**' : '**below**';",
     "final v = a == 1 ? '**above**' : '**below**';"),
    ("more-than sentence swaps the areas", "lib/engine/wording.dart",
     "      return '**More** people were in the **${c.areas[more].name}** '\n          'than in the **${c.areas[fewer].name}**.';",
     "      return '**More** people were in the **${c.areas[fewer].name}** '\n          'than in the **${c.areas[more].name}**.';"),
    ("offset sentence swaps above and below", "lib/engine/wording.dart",
     "${a < 0 ? 'above' : 'below'}", "${a > 0 ? 'above' : 'below'}"),
    ("a tick before everyone it depends on is placed", "lib/engine/session.dart",
     "    return waiting || counted ? ClueMark.open : ClueMark.met;",
     "    return counted ? ClueMark.open : ClueMark.met;"),
    ("counting statements ticked early", "lib/engine/session.dart",
     "    return waiting || counted ? ClueMark.open : ClueMark.met;",
     "    return waiting ? ClueMark.open : ClueMark.met;"),
    ("crosses on blocked squares", "lib/engine/session.dart",
     "        if (c.canOccupy(x) &&\n            !placed.contains(x) &&",
     "        if (!placed.contains(x) &&"),
    ("a tap may replace a person", "lib/engine/session.dart",
     "    if (there >= 0 && there != person) return false;\n", ""),
    ("taps still move people after solving", "lib/engine/session.dart",
     "    if (complete && solved) return TapOutcome.ignored;\n", ""),
    ("the victim is hinted early", "lib/engine/logic_solver.dart",
     "    if (p != c.victim || victimGiven) return false;",
     "    if (p == c.victim || victimGiven) return false;"),
    ("last in line on a grid that is not full", "lib/engine/logic_solver.dart",
     "    if (!c.isFull) return;\n", ""),
    ("alone checks one other person only", "lib/engine/atoms.dart",
     "        for (final q in _allBut(subject)) {\n          binary.add(BinaryAtom(subject, q, _differentArea, i));",
     "        for (final q in _allBut(subject).take(1)) {\n          binary.add(BinaryAtom(subject, q, _differentArea, i));"),
    ("everyone-else forgets the speaker", "lib/engine/atoms.dart",
     "unary.add(UnaryAtom(p, p == subject ? Not(test) : test, i));",
     "if (p != subject) unary.add(UnaryAtom(p, test, i));"),
    ("the only person: the others are not checked", "lib/engine/atoms.dart",
     "unary.add(UnaryAtom(p, p == subject ? test : Not(test), i));",
     "if (p == subject) unary.add(UnaryAtom(p, test, i));"),
    ("the parser reads columns off by one", "lib/engine/case_text.dart",
     "    if (n < 1 || n > most) fail('no ${rows ? 'row' : 'column'} $n');\n    return n - 1;",
     "    if (n < 1 || n > most) fail('no ${rows ? 'row' : 'column'} $n');\n    return rows ? n - 1 : (n == most ? n - 1 : n);"),
]


def run(suite):
    r = subprocess.run(
        ["flutter", "test", suite, "--reporter=failures-only"],
        cwd=REPO, capture_output=True, text=True, shell=True, encoding="utf-8", errors="replace",
    )
    out = r.stdout + r.stderr
    if "Compilation failed" in out or "Error: " in out and "loading" in out:
        return "does not compile"
    return "caught" if r.returncode != 0 else "MISSED"


results = []
for name, file, old, new in M:
    path = REPO / file
    original = path.read_bytes()
    text = original.decode("utf-8").replace("\r\n", "\n")
    if text.count(old) != 1:
        results.append((name, ["not applied (%d matches)" % text.count(old)]))
        continue
    try:
        path.write_text(text.replace(old, new), encoding="utf-8", newline="\n")
        results.append((name, [run(s) for s in SUITES]))
    finally:
        path.write_bytes(original)
    print(name, results[-1][1], flush=True)

print()
print("%-52s %s" % ("planted bug", "  ".join(SUITES)))
for name, r in results:
    print("%-52s %s" % (name, "  ".join(r)))
caught = sum(1 for _, r in results if r[0] == "caught")
print("\n%d of %d caught by %s" % (caught, len(results), SUITES[0]))
bad = [n for n, r in results if r[0] != "caught"]
sys.exit(1 if bad else 0)
