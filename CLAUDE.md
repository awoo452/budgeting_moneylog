# CLAUDE.md — budgeting_moneylog

## Read the Rails Playbook first

The general rules for every Rails app here live in the **Rails Playbook**,
<https://github.com/awoo452/rails-agent>. Read it from a local clone if
there is one (the folder may be named `rails-agent` or `rails-playbook`);
otherwise read it on GitHub. Start with `CHECKLIST.md`. The rules in `rules/`
are settled — follow them instead of re-deriving them.

The ones that get broken most often:

- **Work on a branch, and commit there.** Never push, open a PR or merge unless
  the owner's latest message asks for that specific push — an earlier approval
  never carries over. (Rule 9)
- **Log every change in `CHANGELOG.md`, in the same batch.** Bump MAJOR, MINOR
  or PATCH by what the change is. The commit message is the bare version, with
  no AI attribution. (Rule 2)
- **Ship the UI with the backend, and a test with new behavior.** (Rules 3, 10)

This file and the playbook must never disagree silently. Where this app needs
something different, **Overrides** below says so and names the rule it
overrides. Anything not listed there follows the playbook.

## Overrides

None — this app follows the playbook as written.

## Hosting

This app is not on Heroku — there is no `Procfile`, and its deploy config
is Kamal's (`.kamal/`). Ignore `hosting/heroku.md` and
`hosting/uploads-and-cdn.md`. Whether a CDN in front of it strips query
strings hasn't been confirmed: until the owner says otherwise, keep
functional values in the URL path (`hosting/query-strings.md`).

## App-specific notes

None recorded yet. Add them here as they come up — the playbook's
`templates/CLAUDE.md.template` lists what belongs in this section.
