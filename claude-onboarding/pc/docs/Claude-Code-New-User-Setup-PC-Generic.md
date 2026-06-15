# Getting Started with Claude Code
**[Your Organization] | Information Technology**

This guide walks you through setting up Claude Code on your Windows PC for the first time. The core setup takes about 20-30 minutes. At the end, the script will offer optional language packs (.NET, Python, Rust) -- each adds 5-15 minutes if you choose to install them. An internet connection is required throughout. Your IT administrator will provide the setup script before you begin.

**NOTE:** This guide is for Windows PCs only. Contact your IT Help Desk if you need help on a Mac.

---

## Before You Begin

Make sure you have the following ready before you start:

- Your Windows PC, powered on and connected to the internet
- The setup script your IT administrator sent you -- saved to your Desktop
- Your Anthropic account credentials (you will create a free account or log in to claude.ai after setup -- not during the script)

**NOTE:** Do not run the script as Administrator. If Windows asks you to approve a User Account Control (UAC) prompt for a specific installer, that is normal -- approve it. But do not right-click the script and choose "Run as Administrator."

---

## What Is Claude Code?

Claude Code is an AI assistant that works directly on your PC. You can access it two ways:

**Inside VS Code (recommended for most work)**
The Claude Code extension appears as a panel in Visual Studio Code. You can open it with **Ctrl+Shift+P**, type "Claude", and select it from the list. From there, you have a conversation with Claude -- asking questions, writing documents, building scripts, and solving problems -- while your code and files are right there in the same window.

**In any terminal (for quick tasks)**
Type `claude` in PowerShell, Windows Terminal, or the VS Code integrated terminal to open a command-line session with Claude.

Both methods give you the same AI assistant. Claude reads your files, understands the context of your work, and can take action on your behalf: writing, editing, and organizing, all with your review and approval before anything is saved.

---

## What the Script Does

When you run the setup script, it will install the following in order. Each step checks whether the software is already installed -- if it is, the step is skipped automatically.

**Step 1 -- winget (Windows Package Manager)**
Verifies that winget is available. winget is built into Windows 11 and is used by this script to install all other software. If it is missing, the script will tell you how to get it from the Microsoft Store.

**Step 2 -- PowerShell 7**
The current, actively maintained version of PowerShell. Windows ships with version 5.1 -- this installs version 7 alongside it. Both remain available. Installing it early ensures all remaining steps run in the best available environment.

**Step 3 -- Git**
A version control tool used for projects and required by several developer tools.

**Step 4 -- Node.js**
A software runtime that Claude Code is built on. Installed to a fixed system path that Claude Code can always find at startup.

**Step 5 -- Claude Code CLI**
The Claude Code command-line tool. This is what you type `claude` to launch, and what the VS Code extension uses under the hood.

**Step 6 -- Visual Studio Code**
The code editor that serves as the primary Claude Code interface on Windows. The Claude Code extension (Step 10) runs inside it.

**Step 7 -- Claude Desktop**
A standalone Claude app. On Windows, this is the best way to use Claude alongside full Visual Studio (the IDE), which does not have a Claude Code extension. It is also useful for quick tasks outside of a coding context.

**Step 8 -- Pandoc and Typst**
Document conversion tools. Pandoc converts files between formats (for example, from Markdown to PDF or Word). Typst is a lightweight PDF engine that Pandoc uses to produce PDFs. Together they let Claude Code produce finished PDF documents without any additional software.

**Step 9 -- Code Quality Tools**
Tools that check the quality and style of scripts:

- **PSScriptAnalyzer** -- analyzes PowerShell scripts for errors, security issues, and style problems
- **flake8, black, isort, mypy, pytest** -- Python linting, formatting, import ordering, type checking, and testing tools. Skipped gracefully if Python is not yet installed (run `setup-python.ps1` first if needed)

**Step 10 -- Core VS Code Extensions**
Two extensions installed into VS Code:

- **Claude Code** -- the AI panel inside VS Code
- **PowerShell** -- syntax highlighting, IntelliSense, and debugging for PowerShell scripts

**Step 11 -- Your Workspaces Folders**
A set of organized folders in your home directory where you will keep all your Claude-assisted work. The script creates the following:

```
C:\Users\[YourName]\Workspaces\
+-- _Global\           Your shared organization context -- Claude reads this automatically
+-- Reference\         Vendor docs, guides, and policy documents
+-- IT-Documentation\  Staff how-to guides and technical documentation
+-- Scripting\
|   +-- sandbox\       Test scripts here before using them in production
|   +-- powershell\    Finished, tested PowerShell scripts
+-- Development\       Code projects and repositories
```

**Step 12 -- Claude Code Configuration**
Starter configuration files that tell Claude Code about you and how you like to work. The script creates three files:

- `$HOME\.claude\CLAUDE.md` -- Your personal instructions to Claude. This is the most important file to fill in after the script finishes.
- `$HOME\Workspaces\_Global\CLAUDE.md` -- Organization context. Fill in your name, role, tools, and standards.
- `$HOME\.claude\settings.json` -- Technical configuration that wires up the credential guard (Step 13). You do not need to edit this file.

**Step 13 -- Credential Guard**
A security hook that automatically monitors every shell command Claude runs and blocks any command that appears to contain an inline password, token, or API key. It is a safety net -- it does not replace good security judgment, but it catches common mistakes before they happen.

---

## Language Packs (Optional -- Offered at the End of the Script)

After the core setup finishes, the script will ask which language packs you want to install. Select only what you use -- they are independent of each other and none are required to use Claude Code.

| Choice | What It Installs | Est. Time |
|--------|-----------------|-----------|
| `1` -- .NET | .NET 10 SDK, C# Dev Kit VS Code extension, dotnet format | ~10 min |
| `2` -- Python | Python 3, flake8, black, isort, mypy, pytest, Python VS Code extension | ~5 min |
| `3` -- Rust | rustup, stable Rust toolchain, cargo, rust-analyzer VS Code extension | ~15 min |
| `A` -- All | All of the above | ~30 min |
| `N` -- Skip | None installed now | -- |

If you skip during setup, the individual scripts (`setup-dotnet.ps1`, `setup-python.ps1`, `setup-rust.ps1`) are available in the same folder and can be run any time.

---

## Running the Setup Script

### Step 1 -- Open PowerShell 7

If PowerShell 7 is already installed on your PC, search for **pwsh** in the Start menu. If it is not yet installed, you can use Windows PowerShell (version 5.1) to run the core script -- it will then install PowerShell 7 for you.

To open PowerShell:
- Press **Windows + S**, type **PowerShell** or **pwsh**, and press Enter
- Or open **Windows Terminal** if it is installed

### Step 2 -- Run the Script

In PowerShell, type the following and press Enter. Replace `Desktop` with the folder where you saved the script if it is somewhere else.

```
pwsh -ExecutionPolicy Bypass -File "$HOME\Desktop\setup-claude-code-generic.ps1"
```

**About the ExecutionPolicy flag:** Windows restricts running PowerShell scripts by default as a security measure. The `-ExecutionPolicy Bypass` flag tells PowerShell to run this specific script without changing your system's overall policy. This is safe for a script you received from IT.

**If you see a User Account Control (UAC) prompt** for one of the installers (for example, Node.js or VS Code), click **Yes** to allow it. This is normal.

### Step 3 -- Follow the Prompts

Press Enter when the script asks you to begin. The script will walk through each step and tell you what it is doing.

The script will print `[+]` next to each step that succeeds, `[!]` for warnings, and `[x] ERROR` for anything that fails. If you see an error, note the step number and contact your IT administrator.

When all 13 core steps are done, the script will show a summary and then ask which language packs you want to install. Enter your choice and the script will handle the rest before closing.

---

## After the Script Finishes

The script will print a summary and tell you exactly what was installed. Follow these steps when it is done.

### Step 1 -- Open a New PowerShell Window

Close your current PowerShell window and open a new one. This ensures all the PATH changes the script made take effect in your session.

### Step 2 -- Verify Claude Code Is Working

In the new PowerShell window, type:

```
claude --version
```

You should see a version number printed on the screen. If you see `command not found` or a similar error, close PowerShell and open another new window, then try again.

### Step 3 -- Fill In Your Personal Context

Open your personal Claude configuration file in VS Code:

```
code "$HOME\.claude\CLAUDE.md"
```

Replace each `[bracketed item]` with your actual information -- your name, your role, the tools you use, and how you prefer to work. The more detail you add, the more useful Claude will be. You can come back and update this file any time.

Save the file when you are done (**Ctrl+S**), then close the tab.

### Step 4 -- Fill In Your Organization Context

Open the shared organization context file:

```
code "$HOME\Workspaces\_Global\CLAUDE.md"
```

Add your name, role, tools, and any organization-specific standards (brand, compliance requirements, ticketing system). Save and close when done.

### Step 5 -- Start Claude Code

**In VS Code (recommended):**
Open VS Code, then press **Ctrl+Shift+P**, type **Claude**, and select **Claude Code: Open**. The Claude panel will appear on the side of your screen. Type your first question or task and press Enter.

**In a terminal:**
In any PowerShell window, type:

```
claude
```

You will be prompted to log in to your Anthropic account the first time. After that, Claude Code opens directly each time you run it.

**TIP:** Inside Claude Code, type `/help` to see a list of available commands.

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

## Using Claude With Full Visual Studio

If you use full Visual Studio (the .NET IDE) for development, there is no Claude Code extension available for it. The best workflow is:

1. Keep **Claude Desktop** open alongside Visual Studio
2. Ask Claude questions, get code suggestions, or have it draft documentation in the Claude Desktop window
3. Copy and paste code between the two applications as needed

For scripting, documentation, and non-.NET work, VS Code with the Claude Code extension is the recommended tool.

---

## A Note on Security

Claude Code can read and write files on your PC. Keep these rules in mind at all times:

- **Never paste real passwords or API tokens** into the Claude Code chat
- **Never ask Claude** to include credentials in any file it creates
- **Student records, HR data, and health information** must never be shared with Claude or any AI tool -- FERPA and HIPAA apply
- **When in doubt, leave it out** -- if you are not sure whether sharing something is appropriate, check with your IT administrator before proceeding

The credential guard installed in Step 13 provides an automatic check, but it is a safety net, not a substitute for your own judgment.

---

## Need Help?

| Problem | What to do |
|---------|-----------|
| `command not found` after the script finishes | Close PowerShell, open a new window, and try again |
| Script fails partway through | Note the step number and error message, then contact your IT administrator |
| UAC prompt appears during install | Click Yes -- this is expected for some installers |
| Claude Code prompts you to log in | Create a free Anthropic account at claude.ai or sign in with your existing account |
| VS Code does not show the Claude panel | Press Ctrl+Shift+P, type Claude, and select Claude Code: Open |
| Not sure what to ask Claude | Start simple -- ask it to explain something you already know |
| Something looks wrong or unexpected | Stop, do not save, and contact your IT administrator |

**[Your IT Help Desk Name]**
Phone: [IT Help Desk Phone]
Email: [IT Help Desk Email]

*This guide is maintained by [Your Name], [Your Organization] IT Department.*
*For questions or suggestions, contact [your-email@example.com].*
