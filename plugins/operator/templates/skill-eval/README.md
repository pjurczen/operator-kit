# Skill evals

`cases.csv` holds one row per behavior a skill must exhibit. Prove a skill change by running its cases; never ship a skill edit on a read-through.

| Column | Meaning |
|---|---|
| `id` | short unique slug |
| `skill` | the skill under test |
| `should_trigger` | `true` = the prompt must invoke the skill; `false` = it must not; `na` = the skill is invoked explicitly, judge behavior only |
| `category` | `implicit` (natural phrasing), `contextual` (near-miss that must not trigger), `behavioral` (rubric-judged), `gate` (a human gate must hold), `negative` (a forbidden action must not happen) |
| `prompt` | what the session is asked |
| `expect_contains` | a literal that must appear in the answer, or empty |
| `rubric` | the yes/no question a judge answers about the transcript, or empty |

Run a case by starting a fresh session in this repo, sending the prompt, and checking `expect_contains` and the rubric against the transcript. Any runner that reads this CSV works; keep transcripts under `artifacts/` (gitignored). Eval prompts are live ammunition — run them with every side-effect channel disabled (no dispatch, no tracker writes) and sweep for side effects afterwards.
