# Contributing to Context Catapult (CTX)

**CTX** is a workflow tool designed to be robust, fast, and safe. Improvements, bug fixes, and better documentation are welcome.

## 🛠️ Development Setup

1. **Clone the repo:**

    ```bash
    git clone https://github.com/hexanomicon/context-catapult.git
    cd context-catapult
    ```

2. **Install locally for testing:**
    Use `fisher` to install the plugin from your local directory:

    ```fish
    fisher install .
    ```

    *Now, any changes you make to `functions/ctx.fish` will be live in your shell immediately (or after a shell restart).*

3. **Test your changes:**
    Run the command against the repo itself to ensure logic holds:

    ```fish
    ctx .
    ctx README.md
    ctx -t
    ```

---

## 📐 Coding Guidelines

### 1. Pure Fish Shell

We strive to keep dependencies minimal.

* **Core:** The script must run on standard `fish`.
* **External Tools:** Reliance on `fzf`, `tree`, and `fd`/`find` is acceptable as they are standard unix-like utilities.
* **Avoid:** Do not introduce dependencies on Python, Node.js, or complex binaries unless absolutely necessary (and optional).

### 2. Safety First

This tool interacts with the user's filesystem and clipboard.

* **Read-Only:** The tool should never modify or delete user files.
* **Clipboard:** Always notify the user before or after overwriting the clipboard.
* **Limits:** Respect the file size (1MB) and line count (2000) limits by default to prevent context poisoning.

### 3. Output Style

We use a specific color palette for consistency:

* **Purple (`af5fff`)**: Titles / Headers
* **Cyan (`00e5ff`)**: Info / Lists
* **Green (`00ff9d`)**: Success / Validation
* **Gold (`ffaf00`)**: Warnings
* **Red (`ff0000`)**: Errors

---

## 🚀 Submitting a Pull Request

1. Fork the repo.
2. Create a new branch (`git checkout -b feature/amazing-feature`).
3. Commit your changes (`git commit -m 'Add amazing feature'`).
4. Push to the branch (`git push origin feature/amazing-feature`).
5. Open a Pull Request.

### PR Checklist

* [ ] Logic tested on both **Files** and **Directories**.

* [ ] Works with and without `fd` installed (fallback to `find`).
* [ ] Does not break existing flags (`-s`, `-t`, `-l`).

---

## 📜 License

By contributing, you agree that your contributions will be licensed under its **MIT License**.
