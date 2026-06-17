# Getting Started with Claude Code
**[Your Organization] | Information Technology**

This guide walks you through setting up Claude Code on your Linux Mint computer for the first time. The process takes about 15-20 minutes and requires an internet connection. Your IT administrator will provide the setup script before you begin.

**NOTE:** This guide is for Linux Mint only. Contact your IT Help Desk if you need help on a Mac or Windows computer.

---

## Before You Begin

Make sure you have the following ready before you start:

- Your Linux Mint computer, powered on and connected to the internet
- The setup script your IT administrator sent you -- saved to your home folder or Desktop
- Your Anthropic account credentials (you will create a free account or log in to Claude.ai after setup -- not during the script)

**NOTE:** Do not run the script with `sudo`. The script uses `sudo` internally where needed and will prompt you for your password. If you are ever asked to run the entire script as root, stop and contact your IT administrator.

---

## What Is Claude Code?

Claude Code is an AI assistant that works directly on your Linux Mint computer. Instead of opening a browser or switching to a separate app, you open Claude Code in Terminal and have a conversation with it -- asking questions, writing documents, building scripts, and solving problems -- right from the command line.

Claude reads your files, understands the context of your work, and can take action on your behalf: writing, editing, and organizing, all with your review and approval before anything is saved.

---

## What the Script Does

When you run the setup script, it will install the following in order. Each step checks whether the software is already installed -- if it is, the step is skipped automatically.

**Step 1 -- Build Essentials, curl, git, and Python**
A set of developer tools and utilities that other software depends on. This is the Linux equivalent of Xcode Command Line Tools on Mac. Includes the C compiler toolchain, curl (for downloading files), git (for version control), Python 3, pip (Python package installer), and the desktop notification library used in Step 10.

**Step 2 -- apt Package Index Update**
Refreshes the list of available software so all subsequent installs pick up the most current versions. This runs automatically and requires no input from you.

**Step 3 -- Node.js**
A software runtime that Claude Code and many AI tools are built on. Installed via the NodeSource distribution channel, which provides a current version. The default Ubuntu/Mint package repository often ships a very old version of Node.js that Claude Code does not support.

**Step 4 -- Claude Code**
The AI assistant application itself. Installed using the official Anthropic installer to `~/.local/bin/claude`.

**Step 5 -- Claude Desktop (not available on Linux)**
Claude Desktop is a GUI application available on Mac and Windows. There is no official Linux release. This step prints an advisory note and is skipped. On Linux, you will use Claude Code in the terminal and claude.ai in a browser.

**Step 6 -- Pandoc and Typst**
Document conversion tools. Pandoc converts files between formats (for example, from Markdown to PDF or Word). Typst is a lightweight PDF engine that Pandoc uses to create PDFs. Together they let Claude Code produce finished PDF documents without any additional software.

**Step 7 -- Developer Tools**
Code quality linters and general CLI utilities used alongside Claude Code. The script installs:

- **shellcheck** -- analyzes Bash scripts for common errors and style issues
- **gh** -- GitHub CLI for managing repositories, branches, and pull requests from the terminal
- **jq** -- command-line JSON processor, useful for reading and filtering API output
- **flake8, black, isort, mypy, and pytest** -- Python linting, formatting, and testing tools
- **PSScriptAnalyzer** -- PowerShell linting (installed automatically if PowerShell Core is already present)

Note: swiftlint is macOS-specific and is not installed on Linux.

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
- **Stop notification** -- sends a Linux desktop notification when Claude finishes a task that took more than 20 seconds, so you can step away during long jobs without polling the terminal

These hooks are safety nets. They do not replace good security judgment, but they catch the most common mistakes automatically.

---

## Running the Setup Script

### Step 1 -- Open Terminal

Open a Terminal window on your Linux Mint computer. You can do this by:

- Pressing **Ctrl + Alt + T** (the default keyboard shortcut on most Linux Mint installations)
- Right-clicking on the Desktop and selecting **Open Terminal Here**
- Or opening the application menu and searching for **Terminal**

### Step 2 -- Run the Script

In Terminal, type the following command exactly as shown and press Enter:

```
bash ~/Desktop/setup-claude-code-generic.sh
```

**NOTE:** If you saved the script somewhere other than your Desktop, replace `Desktop` with the name of that folder. For example: `bash ~/Downloads/setup-claude-code-generic.sh`

### Step 3 -- Follow the Prompts

Press Enter when the script asks you to begin. The script will walk through each step and tell you what it is doing.

You will be prompted for your password when the script runs `sudo` commands (Steps 1 and 2 install system packages). Type your password and press Enter -- the password will not be displayed as you type. This is normal Linux behavior.

The script will print a check mark next to each step that succeeds and an error message for anything that fails. If you see an error, note the step number and contact your IT administrator.

---

## After the Script Finishes

The script will print a summary and tell you exactly what was installed. Follow these steps when it is done.

### Step 1 -- Open a New Terminal Window

Close your current Terminal window and open a new one. This ensures all the changes the script made to your PATH take effect in your session.

### Step 2 -- Verify Claude Code Is Working

In the new Terminal window, type:

```
claude --version
```

You should see a version number printed on the screen. If you see `command not found`, close Terminal and open another new window, then try again.

### Step 3 -- Fill In Your Personal Context

Open your personal Claude configuration file in a text editor:

```
nano ~/.claude/CLAUDE.md
```

Replace each `[bracketed item]` with your actual information -- your name, your role, the tools you use, and how you prefer to work. The more detail you add, the more useful Claude will be. You can come back and update this file any time.

When you are done, save with **Ctrl + O**, press Enter to confirm, then exit with **Ctrl + X**.

**TIP:** If you prefer a graphical text editor, you can open the file with:
```
gedit ~/.claude/CLAUDE.md
```

### Step 4 -- Fill In Your Organization Context

Open the shared organization context file:

```
nano ~/Workspaces/_Global/CLAUDE.md
```

Add your name, role, tools, and any organization-specific standards (brand, compliance requirements, ticketing system). Save and close when done.

### Step 5 -- Start Claude Code

In Terminal, type:

```
claude
```

This opens Claude Code. You will be prompted to log in to your Anthropic account the first time. After that, Claude Code opens directly each time you run it.

Type your first question or task and press Enter to send it.

**TIP:** Inside Claude Code, type `/help` to see a list of available commands.

---

## Generating PDFs from Markdown

Pandoc and Typst (installed in Step 6) let you convert any Markdown file to a finished PDF from the command line. This is how Claude Code produces polished documents from `.md` source files.

**Basic command:**

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

Claude Code can read and write files on your computer. Keep these rules in mind at all times:

- **Never paste real passwords or API tokens** into the Claude Code chat
- **Never ask Claude** to include credentials in any file it creates
- **Student records, HR data, and health information** must never be shared with Claude or any AI tool -- if your organization has compliance requirements (FERPA, HIPAA, etc.), they apply here too
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
