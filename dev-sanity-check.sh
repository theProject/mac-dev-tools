#!/bin/zsh

set -u

# ---------- Colors ----------
if [[ -t 1 ]]; then
  BOLD=$'\033[1m'
  RESET=$'\033[0m'
  RED=$'\033[31m'
  GREEN=$'\033[32m'
  YELLOW=$'\033[33m'
  BLUE=$'\033[34m'
  MAGENTA=$'\033[35m'
  CYAN=$'\033[36m'
  WHITE=$'\033[37m'
else
  BOLD=""
  RESET=""
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  MAGENTA=""
  CYAN=""
  WHITE=""
fi

# ---------- Helpers ----------
section() {
  printf "\n%s%s============================================================%s\n" "$BOLD" "$CYAN" "$RESET"
  printf "%s%s%s%s\n" "$BOLD" "$CYAN" "$1" "$RESET"
  printf "%s%s============================================================%s\n" "$BOLD" "$CYAN" "$RESET"
}

ok() {
  printf "%s[OK]%s %s\n" "$GREEN" "$RESET" "$1"
}

warn() {
  printf "%s[WARN]%s %s\n" "$YELLOW" "$RESET" "$1"
}

fail() {
  printf "%s[FAIL]%s %s\n" "$RED" "$RESET" "$1"
}

info() {
  printf "%s[INFO]%s %s\n" "$BLUE" "$RESET" "$1"
}

subhead() {
  printf "\n%s[%s]%s\n" "$BOLD$WHITE" "$1" "$RESET"
}

run_cmd() {
  local name="$1"
  shift
  subhead "$name"
  "$@" 2>&1 || true
}

run_shell() {
  local name="$1"
  local cmd="$2"
  subhead "$name"
  eval "$cmd" 2>&1 || true
}

check_cmd_exists() {
  local label="$1"
  local cmd="$2"

  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$label -> $(command -v "$cmd")"
    return 0
  else
    fail "$label -> not found"
    return 1
  fi
}

check_path_entry() {
  local label="$1"
  local path_to_check="$2"

  if [[ ":$PATH:" == *":$path_to_check:"* ]]; then
    ok "$label -> $path_to_check"
  else
    warn "$label -> missing from PATH: $path_to_check"
  fi
}

check_dir_exists() {
  local label="$1"
  local dir="$2"

  if [[ -d "$dir" ]]; then
    ok "$label -> $dir"
  else
    fail "$label -> missing: $dir"
  fi
}

clear
printf "%s%sMac Dev Sanity Check%s\n" "$BOLD" "$MAGENTA" "$RESET"
printf "%sHost:%s %s\n" "$WHITE" "$RESET" "$(scutil --get ComputerName 2>/dev/null || hostname)"
printf "%sUser:%s %s\n" "$WHITE" "$RESET" "$(whoami)"
printf "%sDate:%s %s\n\n" "$WHITE" "$RESET" "$(date)"

section "SYSTEM"
run_shell "Shell" 'echo "$SHELL"'
run_cmd "Zsh Version" zsh --version
run_cmd "Architecture" uname -m
run_cmd "macOS Version" sw_vers
run_shell "Current Directory" 'pwd'

section "PATH"
subhead "PATH Entries"
echo "$PATH" | tr ':' '\n'

subhead "PATH Checks"
check_path_entry "Homebrew bin" "/opt/homebrew/bin"
check_path_entry "Homebrew sbin" "/opt/homebrew/sbin"
check_path_entry "User local bin" "$HOME/.local/bin"
check_path_entry "PNPM_HOME" "$HOME/Library/pnpm"
check_path_entry "Android platform-tools" "$HOME/Library/Android/sdk/platform-tools"
check_path_entry "Android emulator" "$HOME/Library/Android/sdk/emulator"
check_path_entry "Android cmdline-tools" "$HOME/Library/Android/sdk/cmdline-tools/latest/bin"
if [[ -n "${JAVA_HOME:-}" ]]; then
  check_path_entry "JAVA_HOME/bin" "$JAVA_HOME/bin"
else
  warn "JAVA_HOME is not set"
fi

section "HOMEBREW"
if check_cmd_exists "brew" "brew"; then
  run_cmd "brew --version" brew --version
else
  fail "Homebrew is required for most of this setup"
fi

section "GIT"
if check_cmd_exists "git" "git"; then
  run_cmd "git --version" git --version
fi

section "NODE TOOLCHAIN"
if check_cmd_exists "node" "node"; then
  run_cmd "node -v" node -v
fi
if check_cmd_exists "npm" "npm"; then
  run_cmd "npm -v" npm -v
fi
if check_cmd_exists "pnpm" "pnpm"; then
  run_cmd "pnpm -v" pnpm -v
  run_shell "which -a pnpm" "which -a pnpm"
fi

section "CLI TOOLS"
if check_cmd_exists "codex" "codex"; then
  run_cmd "codex --version" codex --version
fi
if check_cmd_exists "vercel" "vercel"; then
  run_cmd "vercel --version" vercel --version
fi

section "JAVA"
subhead "JAVA_HOME"
if [[ -n "${JAVA_HOME:-}" ]]; then
  ok "JAVA_HOME -> $JAVA_HOME"
else
  fail "JAVA_HOME is not set"
fi

if check_cmd_exists "java" "java"; then
  run_cmd "java -version" java -version
fi
if check_cmd_exists "javac" "javac"; then
  run_cmd "javac -version" javac -version
fi

subhead "java_home listing"
(/usr/libexec/java_home -V) 2>&1 || true
run_shell "active java.home" "java -XshowSettings:properties -version 2>&1 | grep 'java.home'"

section "XCODE / APPLE TOOLING"
run_cmd "xcode-select -p" xcode-select -p
if check_cmd_exists "xcodebuild" "xcodebuild"; then
  run_cmd "xcodebuild -version" xcodebuild -version
else
  fail "xcodebuild not available"
fi

if check_cmd_exists "swift" "swift"; then
  run_cmd "swift --version" swift --version
fi

if check_cmd_exists "clang" "clang"; then
  run_shell "clang version" "clang --version | head -n 1"
fi

if check_cmd_exists "xcrun" "xcrun"; then
  run_shell "simctl devices (first 20 lines)" "xcrun simctl list devices | head -n 20"
fi

section "ANDROID"
subhead "ANDROID_HOME"
if [[ -n "${ANDROID_HOME:-}" ]]; then
  ok "ANDROID_HOME -> $ANDROID_HOME"
else
  warn "ANDROID_HOME is not set"
fi

if check_cmd_exists "adb" "adb"; then
  run_cmd "adb version" adb version
  run_cmd "adb devices" adb devices
fi

if check_cmd_exists "emulator" "emulator"; then
  run_cmd "emulator -version" emulator -version
  run_cmd "emulator -list-avds" emulator -list-avds
fi

if check_cmd_exists "sdkmanager" "sdkmanager"; then
  run_cmd "sdkmanager --version" sdkmanager --version
fi

section "IMPORTANT DIRECTORIES"
check_dir_exists "Homebrew bin" "/opt/homebrew/bin"
check_dir_exists "PNPM_HOME" "$HOME/Library/pnpm"
check_dir_exists "Android SDK" "$HOME/Library/Android/sdk"
check_dir_exists "Android platform-tools" "$HOME/Library/Android/sdk/platform-tools"
check_dir_exists "Android emulator" "$HOME/Library/Android/sdk/emulator"
check_dir_exists "Android cmdline-tools" "$HOME/Library/Android/sdk/cmdline-tools/latest/bin"
check_dir_exists "Xcode.app" "/Applications/Xcode.app"

section "SUMMARY HINTS"
info "If node/npm/pnpm are missing, check Homebrew PATH and shell config."
info "If codex/vercel are missing, check global install and PATH."
info "If xcodebuild fails, ensure xcode-select points to /Applications/Xcode.app/Contents/Developer."
info "If sdkmanager fails, check JAVA_HOME and Android cmdline-tools path."
info "If adb/emulator fail, check ANDROID_HOME and Android SDK path entries."
info "If Terminal and editor terminals disagree, compare PATH and SHELL in both."

printf "\n%s%sDone.%s\n" "$BOLD" "$GREEN" "$RESET"
