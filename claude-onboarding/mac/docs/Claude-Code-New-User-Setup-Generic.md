# Getting Started with Claude Code
**[Your Organization] | Information Technology**

This guide walks you through setting up Claude Code on your Mac for the first time. The process takes about 15-20 minutes and requires an internet connection. Your IT administrator will provide the setup script before you begin.

**NOTE:** This guide is for Macs only. Contact your IT Help Desk if you need help on a Windows computer.

---

## Before You Begin

Make sure you have the following ready before you start:

- Your Mac, powered on and connected to the internet
- The setup script your IT administrator sent you -- saved to your Desktop
- Your Anthropic account credentials (you will create a free account or log in to Claude.ai after setup -- not during the script)

**NOTE:** Do not run the script with `sudo`. If you are ever asked to type `sudo` before a command, stop and contact your IT administrator.

---

## What Is Claude Code?

Claude Code is an AI assistant that works directly on your Mac. Instead of opening a browser or switching to a separate app, you open Claude Code in Terminal and have a conversation with it -- asking questions, writing documents, building scripts, and solving problems -- right from the command line.

Claude reads your files, understands the context of your work, and can take action on your behalf: writing, editing, and organizing, all with your review and approval before anything is saved.

---

## What the Script Does

When you run the setup script, it will install the following in order. Each step checks whether the software is already installed -- if it is, the step is skipped automatically.

**Step 1 -- Xcode Command Line Tools**
A set of developer tools built into macOS that other software depends on. Homebrew (Step 2) will not install without it.

**Step 2 -- Homebrew**
A package manager for Mac -- a tool that installs and manages software from the command line. Required to install Node.js in a way Claude Code can reliably find.

**Step 3 -- Node.js**
A software runtime that Claude Code and many AI tools are built on. Installed via Homebrew to a fixed location on your Mac that Claude Code can always find at startup.

**Step 4 -- Claude Code**
The AI assistant application itself. Installed using the official Anthropic installer to `~/.local/bin/claude`.

**Step 5 -- Claude Desktop**
The standalone GUI application for Claude. Claude Desktop lets you use Claude without a terminal window, and it includes Cowork -- a folder-based AI tool that lets you describe a task and have Claude carry it out across your files without typing commands. Recommended for non-technical users. Installed via Homebrew and placed in `/Applications/Claude.app`.

**Step 6 -- Pandoc and Typst**
Document conversion tools. Pandoc converts files between formats (for example, from Markdown to PDF or Word). Typst is a lightweight PDF engine that Pandoc uses to create PDFs. Together they let Claude Code produce finished PDF documents without any additional software.

**Step 7 -- Developer Tools**
Code quality linters and general CLI utilities used alongside Claude Code. The script installs:

- **shellcheck** -- analyzes Bash and Zsh scripts for common errors and style issues
- **swiftlint** -- checks Swift source files for style and correctness
- **gh** -- GitHub CLI for managing repositories, branches, and pull requests from the terminal
- **jq** -- command-line JSON processor, useful for reading and filtering API output
- **flake8, black, isort, mypy, and pytest** -- Python linting, formatting, and testing tools
- **PSScriptAnalyzer** -- PowerShell linting (installed automatically if PowerShell Core is already present on your Mac)

**Step 8 -- Your Workspaces Folders**
A set of organized folders in your home directory where you will keep all your Claude-assisted work. The script creates the following:

```
~/Workspaces/
+-- _Global/          Your shared organization context -- Claude reads this automatically
+-- Reference/        Vendor docs, guides, and policy documents
+-- IT-Documentation/ Staff how-to guides and technical documentation
+-- Scripting/
    +-- sandbox/      Test scripts here before using them in production
    +-- zsh/          Finished, tested scripts
```

**Step 9 -- Claude Code Configuration**
Starter configuration files that tell Claude Code about you and how you like to work. The script creates three files:

- `~/.claude/CLAUDE.md` -- Your personal instructions to Claude. This is the most important file to fill in after the script finishes.
- `~/Workspaces/_Global/CLAUDE.md` -- Organization context. Fill in your name, role, tools, and standards.
- `~/.claude/settings.json` -- Technical configuration that wires up the credential guard (Step 10). You do not need to edit this file.

**Step 10 -- Security Hooks and Notifications**
Three automation hooks that run quietly in the background during every Claude Code session:

- **Credential guard** -- monitors every shell command Claude runs and warns if it appears to contain an inline password, token, or API key
- **Settings guard** -- scans `settings.json` immediately after any write to catch credentials that were accidentally placed there during MCP server configuration
- **Stop notification** -- sends a macOS desktop notification (with a sound) when Claude finishes a task that took more than 20 seconds, so you can step away during long jobs without polling the terminal

These hooks are safety nets. They do not replace good security judgment, but they catch the most common mistakes automatically.

---

## Running the Setup Script

### Step 1 -- Open Terminal

Open Terminal on your Mac. You can find it by:

- Opening Spotlight (Command + Space) and typing **Terminal**, then pressing Return
- Or going to **Applications -> Utilities -> Terminal**

### Step 2 -- Run the Script

In Terminal, type the following command exactly as shown and press Return:

```
zsh ~/Desktop/setup-claude-code-generic.sh
```

**NOTE:** If you saved the script somewhere other than your Desktop, replace `Desktop` with the name of that folder. For example: `zsh ~/Downloads/setup-claude-code-generic.sh`

### Step 3 -- Follow the Prompts

Press Return when the script asks you to begin. The script will walk through each step and tell you what it is doing.

If Step 1 (Xcode Command Line Tools) is not already installed, a macOS installer window will open. Click **Install**, wait for it to finish (about 2-5 minutes), and then return to Terminal and press Return to continue.

The script will print a check mark next to each step that succeeds and an error message for anything that fails. If you see an error, note the step number and contact your IT administrator.

---

## After the Script Finishes

The script will print a summary and tell you exactly what was installed. Follow these steps when it is done.

### Step 1 -- Open a New Terminal Window

Close your current Terminal window and open a new one. This ensures all the changes the script made take effect in your session.

### Step 2 -- Verify Claude Code Is Working

In the new Terminal window, type:

```
claude --version
```

You should see a version number printed on the screen. If you see `command not found`, close Terminal and open another new window, then try again.

### Step 3 -- Fill In Your Personal Context

Open your personal Claude configuration file:

```
open ~/.claude/CLAUDE.md
```

The file will open in TextEdit. Replace each `[bracketed item]` with your actual information -- your name, your role, the tools you use, and how you prefer to work. The more detail you add, the more useful Claude will be. You can come back and update this file any time.

Save the file when you are done (Command + S), then close TextEdit.

### Step 4 -- Fill In Your Organization Context

Open the shared organization context file:

```
open ~/Workspaces/_Global/CLAUDE.md
```

Add your name, role, tools, and any organization-specific standards (brand, compliance requirements, ticketing system). Save and close when done.

### Step 5 -- Start Claude Code

In Terminal, type:

```
claude
```

This opens Claude Code. You will be prompted to log in to your Anthropic account the first time. After that, Claude Code opens directly each time you run it.

Type your first question or task and press Return to send it.

**TIP:** Inside Claude Code, type `/help` to see a list of available commands.

---

## Generating PDFs from Markdown

Pandoc and Typst (installed in Step 6) let you convert any Markdown file to a finished PDF from the command line. This is how Claude Code produces polished documents from `.md` source files.

**Basic command (Mac and Linux):**

```
pandoc --pdf-engine=typst your-document.md -o your-document.pdf
```

**Example:** To convert a file called `staff-guide.md` in your current folder:

```
pandoc --pdf-engine=typst staff-guide.md -o staff-guide.pdf
```

**TIP:** Claude Code can draft Markdown documents for you. Ask it to write a guide, save the result as a `.md` file, then run the command above to produce the finished PDF.

---

## Your First Week With Claude Code

Here are a few low-stakes tasks to get comfortable:

**Ask Claude to explain something:**
> "Explain how FERPA applies to IT help desk tickets."

**Have Claude draft a document:**
> "Draft a short how-to guide for staff on how to reset their network password."

**Ask Claude for help with something you are already doing:**
> "I need to write an email to staff about an upcoming Microsoft 365 update. Help me draft it in plain language."

You are always in control. Claude will show you its work and ask for your approval before saving or changing any files. If you do not like something, tell it to try again or take a different approach.

---

## A Note on Security

Claude Code can read and write files on your Mac. Keep these rules in mind at all times:

- **Never paste real passwords or API tokens** into the Claude Code chat
- **Never ask Claude** to include credentials in any file it creates
- **Student records, HR data, and health information** must never be shared with Claude or any AI tool -- FERPA and HIPAA apply
- **When in doubt, leave it out** -- if you are not sure whether sharing something is appropriate, check with your IT administrator before proceeding

The security hooks installed in Step 10 provide automatic checks, but they are a safety net, not a substitute for your own judgment.

---

## Need Help?

| Problem | What to do |
|---------|-----------|
| `command not found` after the script finishes | Close Terminal, open a new window, and try again |
| Script fails partway through | Note the step number and error message, then contact your IT administrator |
| Claude Code prompts you to log in | Create a free Anthropic account at claude.ai or sign in with your existing account |
| Not sure what to ask Claude | Start simple -- ask it to explain something you already know |
| Something looks wrong or unexpected | Stop, do not save, and contact your IT administrator |

**[Your IT Help Desk Name]**
Phone: [IT Help Desk Phone]
Email: [IT Help Desk Email]

*This guide is maintained by [Your Name], [Your Organization] IT Department.*
*For questions or suggestions, contact [your-email@example.com].*
