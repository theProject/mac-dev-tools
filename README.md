```markdown
# Mac Dev Sanity Check 🩺💻

A lightweight, colorful Zsh diagnostic script to quickly validate your macOS development environment. 

Setting up a new Mac or troubleshooting missing commands can be frustrating. This script runs a comprehensive "sanity check" across your system, verifying that essential tools, environment variables, and directories are correctly installed and accessible in your `$PATH`.

## What It Checks

The script is broken down into several sections to test different parts of your development stack:

* **System Info:** Displays your current Shell, Zsh version, system architecture (e.g., Apple Silicon vs. Intel), macOS version, and working directory.
* **PATH Configuration:** Lists your `$PATH` entries and specifically checks for the presence of Homebrew, local bins, PNPM, Java, and Android SDKs.
* **Homebrew:** Verifies Homebrew is installed and checks its version.
* **Git:** Verifies Git installation and version.
* **Node Toolchain:** Checks for `node`, `npm`, and `pnpm`.
* **CLI Tools:** Checks for specific global packages like `codex` and `vercel`.
* **Java:** Validates `$JAVA_HOME`, checks `java` and `javac` versions, and lists installed Java environments.
* **Xcode & Apple Tooling:** Checks `xcode-select` paths, `xcodebuild`, Swift, Clang, and running simulators via `xcrun`.
* **Android:** Validates `$ANDROID_HOME` and checks for `adb`, the Android emulator, and `sdkmanager`.
* **Important Directories:** Ensures critical folders exist on your machine (e.g., Xcode app, Android SDK directories, Homebrew bin).

## Usage

1. **Create the file:** Save the script to a file, for example, `sanity-check.sh`.
2. **Make it executable:** Give the script execution permissions by running the following command in your terminal:
   ```bash
   chmod +x sanity-check.sh

```
 3. **Run the script:**
   ```bash
   ./sanity-check.sh
   
   ```
## Output
The script uses a color-coded output system so you can easily spot what is working and what needs attention:
 * **[OK]** (Green): The tool, path, or directory was found successfully.
 * **[INFO]** (Blue): Helpful information or summary tips.
 * **[WARN]** (Yellow): A non-critical issue, such as a missing $PATH entry or variable.
 * **[FAIL]** (Red): A critical tool or directory is missing.
At the end of the execution, a **Summary Hints** section provides quick troubleshooting tips for any tools that might have failed the checks (e.g., reminding you to check your shell configuration if Node is missing, or pointing you to the correct Xcode directory).
## Customization
You can easily extend this script to fit your specific workflow. Just open the script and add your custom commands using the built-in helper functions:
 * check_cmd_exists "Label" "command"
 * check_path_entry "Label" "/your/custom/path"
 * check_dir_exists "Label" "/your/custom/dir"
## Requirements
 * **OS:** macOS
 * **Shell:** Zsh (Default on modern macOS)
```

```
