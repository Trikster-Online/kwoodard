# Claude Cowork -- Quick Start Guide
**[Your Organization] | Information Technology**

This guide covers how to use Claude Cowork effectively -- including the
recommended prompt to run at the start of every session to confirm Claude
has loaded the right context before it begins any work.

---

## What Is Claude Cowork?

Claude Cowork is the non-terminal, document-oriented side of Claude Code.
Instead of typing commands back and forth in a terminal, you point Cowork
at a folder, describe an outcome, and it plans and executes multi-step tasks
while keeping you informed at key steps.

**Claude Code (terminal)** -- Interactive. You approve each step. Best for
scripting, API work, and technical tasks where you want fine-grained control.

**Claude Cowork (folder-based)** -- Autonomous. Best for documentation,
research synthesis, file organization, and knowledge work. Less technical
involvement per session.

Both tools use the same AI and the same CLAUDE.md configuration files.

---

## Before You Start a Session

Make sure the folder you are working in has a `CLAUDE.md` file that describes:
- What this folder is for
- Any relevant standards or rules Claude should follow
- What tools or systems are involved

If the folder does not have a `CLAUDE.md`, Cowork will still work, but it will
have less context about your specific environment. The setup script created
starter files at:
- `~/Workspaces/_Global/CLAUDE.md` -- organization-wide context
- `~/.claude/CLAUDE.md` -- your personal instructions

---

## The Session-Start Prompt

**Run this prompt at the beginning of every Cowork session, before describing
any task.** It tells Claude to load and confirm its context, and gives you a
chance to catch anything stale or wrong before work begins.

```
Before we start, please do the following:

1. Read the CLAUDE.md file in this folder (if one exists) and tell me what
   context you loaded from it.
2. Tell me what your active instructions are -- including anything from your
   global CLAUDE.md or personal setup.
3. Confirm you are ready to begin, and summarize in one sentence what kind
   of work this session is set up for.

Do not start any tasks yet. Wait for me to describe what I need.
```

**Why this matters:**
- Claude reads CLAUDE.md files at the start of a session, but it does not
  always confirm it loaded them. This prompt makes the context visible.
- If something is outdated or missing, you find out before work starts --
  not halfway through.
- It takes about 15 seconds and prevents the most common source of
  off-target results.

---

## Starting a Session in Claude Desktop (Cowork Tab)

1. Open Claude Desktop
2. Click the **Cowork** tab
3. Select the folder you want to work in using the folder picker
4. Paste the session-start prompt above and press Enter
5. Review Claude's response -- check that it loaded the right CLAUDE.md
6. Describe your task

---

## Checking What Context Files Are Loaded (Claude Code CLI)

In Claude Code (terminal), you can ask Claude directly:

```
What CLAUDE.md files do you have loaded in this session? List each file
and one-sentence summary of what it contains.
```

You can also view the files yourself:

```bash
# View your personal instructions
cat ~/.claude/CLAUDE.md

# View the global project context
cat ~/Workspaces/_Global/CLAUDE.md

# View context for the current folder (if it exists)
cat CLAUDE.md
```

---

## Security Rules for Cowork Sessions

These apply every time you use Cowork, regardless of the task:

- **Never put real passwords, API tokens, or credentials** into the Cowork
  chat or into any file in a Cowork folder
- **Never drop files containing student records, HR data, or health
  information** into a Cowork folder -- FERPA and HIPAA apply
- **Always check Excel files for hidden sheets** before adding them to a
  Cowork folder (right-click any sheet tab and look for "Unhide")
- **Review Claude's plan before it executes** -- Cowork shows a plan before
  starting multi-step tasks; read it and confirm it looks right
- **When in doubt, leave it out** -- if you are not sure whether a file is
  safe to share with Claude, check with your IT administrator first

---

## Ending a Session Well

Before closing Cowork:

1. **Save any outputs** Claude produced -- copy them to your Workspaces folder
   or export them as needed. Cowork does not automatically persist outputs
   between sessions.
2. **Review what was changed** -- if Cowork edited files, check the changes
   before treating them as final.
3. **Note anything to follow up** -- Cowork sessions do not carry memory
   between sessions unless you write context into a CLAUDE.md file.

---

## Common Issues

| Problem | What to do |
|---------|-----------|
| Claude does not seem to know the context of my work | Run the session-start prompt to confirm CLAUDE.md loaded |
| Claude modified a file in an unexpected way | Check the change, undo if needed, and add a clarification to your CLAUDE.md |
| Cowork started a task before I finished describing it | Use the session-start prompt -- it explicitly tells Claude to wait |
| Claude referenced information that was outdated | Update the relevant CLAUDE.md file and start a new session |
| Something looks wrong or unexpected | Stop, do not save, and contact your IT administrator |

---

*This guide is maintained by [Your Name], [Your Organization] IT Department.*
*For questions or suggestions, contact [your-email@example.com].*
