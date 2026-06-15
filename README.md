# Claude Code Onboarding Kit

A generic, organization-ready onboarding kit for Claude Code. Fork this repo,
fill in the bracketed placeholders with your organization's details, and
distribute the setup scripts to your team.

---

## What Is This?

This kit gives IT administrators a ready-to-go package for deploying Claude Code
to staff. It includes bootstrap scripts, starter configuration templates, and
plain-language setup guides for both Mac and Windows.

Everything is written generically. No organization-specific content is included.
Search for `[Your Organization]`, `[Your IT Administrator]`, and similar
placeholders to find everything that needs customizing before you share it.

---

## Repository Structure

```
claude-onboarding/
  docs/                                    Shared guides (apply to Mac and PC)
    Claude-Cowork-Quick-Start-Generic.md   How to start a Claude Cowork session

  mac/                                     Mac onboarding kit
    setup-claude-code-generic.sh           Bootstrap script (zsh)
    CLAUDE.md                              Notes for Claude Code in this folder
    docs/
      Claude-Code-New-User-Setup-Generic.md  Plain-language setup guide
    templates/
      global-claude-md-generic.md          Starter global CLAUDE.md template
      personal-claude-md-generic.md        Starter personal CLAUDE.md template

  pc/                                      Windows PC onboarding kit
    setup-claude-code-generic.ps1          Bootstrap script (PowerShell)
    setup-dotnet.ps1                       Optional .NET language pack
    setup-python.ps1                       Optional Python language pack
    setup-rust.ps1                         Optional Rust language pack
    CLAUDE.md                              Notes for Claude Code in this folder
    docs/
      Claude-Code-New-User-Setup-PC-Generic.md  Plain-language setup guide
    templates/
      global-claude-md-generic.md          Starter global CLAUDE.md template
      personal-claude-md-generic.md        Starter personal CLAUDE.md template
```

---

## How to Use This Kit

### 1. Fork or clone this repo

```
git clone git@github.com:Trikster-Online/kwoodard.git
```

### 2. Find and replace all placeholders

Search your editor for `[Your` to find every placeholder. Common ones:

| Placeholder | Replace with |
|---|---|
| `[Your Organization]` | Your organization name |
| `[Your IT Administrator]` | The name of the person users contact for help |
| `[IT Help Desk Phone]` | Your help desk phone number |
| `[IT Help Desk Email]` | Your help desk email address |
| `[Your Ticketing System]` | e.g. ServiceNow, Jira, Zendesk |
| `[Your Brand Colors]` | Your brand hex colors |
| `[Your Brand Fonts]` | Your brand fonts |
| `[your-email@example.com]` | Your contact email |

### 3. Rename files if desired

Script files use `generic` in the name as a convention. You can rename them
(e.g. `setup-claude-code-v1.sh`) -- just update the filename references in the
matching setup guide under `docs/`.

### 4. Distribute to your users

Share the platform-appropriate folder with each user:
- Mac users: send `mac/setup-claude-code-generic.sh` and `mac/docs/Claude-Code-New-User-Setup-Generic.md`
- PC users: send `pc/setup-claude-code-generic.ps1` and `pc/docs/Claude-Code-New-User-Setup-PC-Generic.md`

The setup guide explains how to run the script. Have users read the guide first.

### 5. Generate PDFs (optional)

If you have Pandoc and Typst installed:

```bash
pandoc --pdf-engine=typst mac/docs/Claude-Code-New-User-Setup-Generic.md \
  -o mac/docs/Claude-Code-New-User-Setup-Generic.pdf
```

PDFs are excluded from this repo by default (see `.gitignore`).

---

## What the Scripts Install

**Mac (`setup-claude-code-generic.sh`):**
Xcode CLT, Homebrew, Node.js, Claude Code CLI, Pandoc/Typst/Poppler,
shellcheck, swiftlint, Python linters, Workspaces folder structure,
starter CLAUDE.md templates, credential guard hook.

**PC (`setup-claude-code-generic.ps1`):**
winget, PowerShell 7, Git, Node.js, Claude Code CLI, VS Code, Claude Desktop,
Pandoc/Typst, PSScriptAnalyzer, Python linters, core VS Code extensions,
Workspaces folder structure, starter CLAUDE.md templates, credential guard hook.

Optional language packs (PC): `.NET` / `Python` / `Rust`

---

## Security

All scripts include a credential guard hook that blocks Claude Code from running
shell commands containing inline credentials (passwords, tokens, API keys).
This is a safety net -- it does not replace user judgment or organizational
security policy.

Scripts never store credentials. All credential-shaped values in templates use
`YOUR_VALUE_HERE` as a placeholder convention.

---

## License

MIT -- use freely, adapt for your organization, no attribution required.
