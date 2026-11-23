# sprites/prompts

The prompt that produced each accepted art sheet, one `<name>.txt` per
`sprites/<name>.png`. Both are tracked: an accepted sheet costs money and
attempts to make and no prompt reproduces it exactly, and the prompt beside it
records what was asked for, so a redo starts from what worked instead of from
memory. `py -3 tool/write_sprite_prompts.py` writes a prompt here only once its
sheet exists in `sprites/`; until then the prompt is a draft in
`output/prompts/`, which is not tracked. No sheet has been accepted yet
(2026-11-24), so this folder holds only this file. The full pipeline is in
[docs/Art.md](../../docs/Art.md).
