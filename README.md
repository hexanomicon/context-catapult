<div align="center">
  <img src="context-catapult.jpeg" alt="CTX" width="400">
  <p><strong>CTX</strong> - The Context Catapult</p>
  <p>
    <a href="https://github.com/hexanomicon/context-catapult">
      <img src="https://img.shields.io/badge/Fisher-Install-1a1a20?style=for-the-badge&labelColor=006064&logo=fish&logoColor=white" alt="Fisher">
    </a>
    <a href="https://github.com/hexanomicon">
      <img src="https://img.shields.io/badge/Origin-The_Hexanomicon-1a1a20?style=for-the-badge&labelColor=4a148c" alt="Hexanomicon">
    </a>
    <a href="LICENSE">
      <img src="https://img.shields.io/badge/License-MIT-1a1a20?style=for-the-badge&labelColor=2e7d32" alt="License">
    </a>
  </p>
</div>

**Context Catapult (CTX)** is a robust Fish shell workflow for feeding code context to LLMs. It allows you to Scout, Spy, and Extract codebase knowledge without hitting token limits.

## ⚡ The Problem

You are working with an AI (Claude, ChatGPT, Local LLM). You need to share code.

* **Copy-pasting** file-by-file is slow and breaks flow.
* **`cat ./*`** dumps `node_modules` and binary files, crashing the context window.
* The AI hallucinates files because it doesn't know your directory structure.

## 🔮 The Solution

**CTX** bridges your terminal and your AI using tools you already trust.

* **🛡️ Safety First:** Auto-skips files larger than **1MB** or **2000 lines**.
* **🧠 Context Aware:** Uses `fd` to respect `.gitignore` automatically.
* **👁️ Smart Selection:** Uses `fzf` for interactive filtering.
* **📋 System Protocol:** Generates a project map to "handshake" with the AI.

---

## 📦 Installation

To use this tool, you need 3 layers: The **Binaries**, The **Plugin Manager**, and **The Script**.

### 1. Install System Binaries

CTX orchestrates these engines. You likely have them, but `fd` is critical for Git awareness.

* **Fedora / RHEL:** `sudo dnf install fzf tree fd-find`
* **Ubuntu / Debian:** `sudo apt install fzf tree fd-find`
* **Arch Linux:** `sudo pacman -S fzf tree fd`
* **macOS:** `brew install fzf tree fd`

### 2. Install Fisher (Plugin Manager)

If you don't have [Fisher](https://github.com/jorgebucaran/fisher) installed yet, run this:

```fish
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
```

### 3. Install Context Catapult

```fish
fisher install hexanomicon/context-catapult
```

**Verification:**
Run `ctx -h`. If you see the manual, you are ready.

---

## 🚀 Workflow

### 1. The Handshake (`ctx -l`)

*Start here.* This generates a "System Protocol" and a clean Map of your project. Paste this to the LLM **first** so it understands your architecture.

```fish
ctx -l
# ✅ Copied System Protocol & File Map to clipboard.
```

### 2. The Extraction (`ctx`)

Scan, Select, and Copy.

```fish
# Interactive Mode (Scans current dir, opens empty selection)
ctx .

# Explicit Mode (Auto-confirms specific files)
ctx README.md src/main.py

# Batch Mode (Auto-selects ALL files in a folder)
ctx -a src/components/
```

**Output Example:**

```text
mode: 🚀 Powered by 'fd' (GitIgnore Active)
mode: 🕵️  Manual Selection

📂 Included Files (3):
   - src/app.py
   - src/config.py
   - Dockerfile

✨ Ready! Chars: 4819 | Tokens: ~1205
```

### 3. The Scout (`ctx -t`)

Visualize directory structures without reading file contents.
*Includes console truncation (20 lines) to prevent terminal flooding.*

```fish
ctx -t             # Map current directory
ctx -t -d 2 src/   # Map src/ folder, 2 levels deep
```

### 4. The Spy (`ctx -s`)

Read the top `N` lines of files. Perfect for checking imports/headers.

```fish
ctx -s 50 src/     # Copy top 50 lines of all files in src/
```

---

## 💡 Pro Tips

### ⚡ Speed Navigation with Zoxide

CTX pairs perfectly with **[zoxide (z)](https://github.com/ajeetdsouza/zoxide)**. Use `z` to jump instantly to a repo, then `ctx` to extract what you need.

```fish
# Jump to project -> Extract Context
z lychd; and ctx .

# Jump to project -> Generate Handshake
z my-app; and ctx -l
```

### 🔧 Philosophy

CTX is not a black box. It is a pure Fish script wrapper (~300 lines) that orchestrates tools you already use. Because it relies on standard binaries (`fd`, `fzf`), it is fast, hackable, and transparent.

---

## ⚙️ Configuration & Customization

CTX comes with sensible defaults to prevent context poisoning, but it is built to be hacked.

### 1. Runtime Flags

You can override limits per-command:

| Feature | Default | Override Flag | Description |
| :--- | :--- | :--- | :--- |
| **Max Size** | 1 MB | `-M <bytes>` | Files larger than this are skipped. |
| **Max Lines** | 2000 | `-f` / `--force` | Files longer than this are skipped. |
| **Recursion** | 3 Levels | `-d <N>` | How deep to scan (`-1` = Infinite). |
| **Console** | 20 Lines | `-P <N>` | Max lines to print in terminal summary. |

### 2. modifying Defaults (The Source)

Want to add new file extensions (e.g., `.swift`, `.ex`) or change the "Trash List" of ignored folders?

**Edit the script directly:**

```fish
nano ~/.config/fish/functions/ctx.fish
```
