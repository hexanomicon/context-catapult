<div align="center">
  <img src="context-catapult.jpeg" alt="CTX" width=50%>
  <p><strong>CTX</strong> - The Context Catapult</p>
  <p>
    <a href="https://github.com/hexanomicon/context-catapult">
      <img src="https://img.shields.io/badge/Fisher-Install-1a1a20?style=for-the-badge&labelColor=006064&logo=fish&logoColor=white" alt="Fisher">
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

**CTX** bridges your terminal and your AI.

* **🛡️ Safety First:** Auto-skips files larger than **1MB** or **2000 lines**.
* **🧠 Context Aware:** Uses `fd` to respect `.gitignore` automatically.
* **👁️ Smart Selection:** Uses `fzf` for interactive filtering.
* **📋 System Protocol:** Generates a project map to "handshake" with the AI.

---

## 📦 Installation

### 1. Install Dependencies

CTX orchestrates standard system tools. You likely already have them, but if not:

**macOS (Homebrew):**

```bash
brew install fish fzf tree fd
```

**Ubuntu / Debian:**

```bash
sudo apt install fish fzf tree fd-find
```

**Arch Linux:**

```bash
sudo pacman -S fish fzf tree fd
```

### 2. Install CTX (via Fisher)

```fish
fisher install hexanomicon/context-catapult
```

| Tool | Purpose | Status |
| :--- | :--- | :--- |
| **[fish](https://fishshell.com/)** | The Shell environment. | **Required** |
| **[fzf](https://github.com/junegunn/fzf)** | Interactive fuzzy-finding selector. | **Required** |
| **[tree](https://linux.die.net/man/1/tree)** | Directory mapping/visualization. | **Required** |
| **[fd](https://github.com/sharkdp/fd)** | Fast file finding & `.gitignore` support. | *Recommended* |

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

**Output:**

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

## ⚙️ Configuration

CTX comes with sensible defaults to prevent **Context Poisoning**. You can override them via flags.

| Feature | Default | Override Flag | Description |
| :--- | :--- | :--- | :--- |
| **Max Size** | 1 MB | `-M <bytes>` | Files larger than this are skipped. |
| **Max Lines** | 2000 | `-f` / `--force` | Files longer than this are skipped. |
| **Recursion** | 3 Levels | `-d <N>` | How deep to scan (`-1` = Infinite). |
| **Console** | 20 Lines | `-P <N>` | Max lines to print in terminal summary. |

> Run `ctx -h` to see the full help manual.
