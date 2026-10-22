#!/usr/bin/env bash
# Install, update or remove macOS-style shortcuts on Omarchy.
#
#   curl -fsSL https://raw.githubusercontent.com/PeterSchmiedt/omarchy-macos-shortcuts/main/install.sh | bash
#
# Usage: install.sh [install|uninstall] [--pc-keyboard|--no-pc-keyboard]
#
# Everything stays in your home directory: no sudo, nothing under /usr or /etc.

set -euo pipefail

REPO_URL="${OMARCHY_MACOS_REPO:-https://github.com/PeterSchmiedt/omarchy-macos-shortcuts.git}"
INSTALL_DIR="${OMARCHY_MACOS_DIR:-$HOME/.local/share/omarchy-macos-shortcuts}"
OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
HYPRLAND_LUA="$CONFIG_HOME/hypr/hyprland.lua"
MODULE_LINK="$CONFIG_HOME/hypr/macos"
HOOK_FILE="$CONFIG_HOME/omarchy/hooks/post-update.d/omarchy-macos-shortcuts.hook"
BACKUP_FILE="$HYPRLAND_LUA.macos-backup"
ANCHOR='require("default.hypr.omarchy")'
MARKER="omarchy-macos-shortcuts"

say() { printf '%s\n' "$*"; }
die() { printf 'omarchy-macos-shortcuts: %s\n' "$*" >&2; exit 1; }

command_name=install
pc_keyboard=""
for arg in "$@"; do
  case $arg in
    install | uninstall) command_name=$arg ;;
    --pc-keyboard) pc_keyboard=true ;;
    --no-pc-keyboard) pc_keyboard=false ;;
    -h | --help) sed -n '2,8p' "$0" 2>/dev/null | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) die "unknown argument: $arg (try --help)" ;;
  esac
done

# --- Bootstrap: when piped from curl, fetch the repo and run from the clone ---

script_dir=""
if [[ -n ${BASH_SOURCE[0]:-} && -f ${BASH_SOURCE[0]} ]]; then
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

if [[ -z $script_dir || ! -f $script_dir/hypr/init.lua ]]; then
  command -v git >/dev/null || die "git is required."
  if [[ -d $INSTALL_DIR/.git ]]; then
    say "Updating $INSTALL_DIR"
    git -C "$INSTALL_DIR" pull --ff-only --quiet || die "could not update $INSTALL_DIR (local changes?)."
  elif [[ -e $INSTALL_DIR ]]; then
    die "$INSTALL_DIR exists but is not a git clone of this project. Move it away and try again."
  else
    say "Downloading to $INSTALL_DIR"
    mkdir -p "$(dirname "$INSTALL_DIR")"
    git clone --quiet "$REPO_URL" "$INSTALL_DIR"
  fi
  exec bash "$INSTALL_DIR/install.sh" "$@"
fi

REPO_DIR="$script_dir"

# --- Helpers ---

# Print hyprland.lua without our marked blocks.
strip_blocks() {
  awk -v marker="$MARKER" '
    index($0, "-- >>> " marker) == 1 { skipping = 1; next }
    index($0, "-- <<< " marker) == 1 { skipping = 0; next }
    !skipping { print }
  ' "$1"
}

# Print hyprland.lua (already stripped) with our blocks around the anchor line.
insert_blocks() {
  local file=$1 pc=$2
  awk -v marker="$MARKER" -v anchor="$ANCHOR" -v pc="$pc" '
    $0 == anchor && !done {
      print "-- >>> " marker " (pre)"
      print "if omarchy_preinstalled_bindings == nil then omarchy_preinstalled_bindings = false end"
      if (pc == "true") print "macos_pc_keyboard = true"
      print "-- <<< " marker " (pre)"
      print
      print "-- >>> " marker
      print "require(\"default.hypr.require_optional\").module(\"hypr.macos.init\")"
      print "-- <<< " marker
      done = 1
      next
    }
    { print }
  ' "$file"
}

hyprland_running() {
  command -v hyprctl >/dev/null && hyprctl version >/dev/null 2>&1
}

# Reload Hyprland and print any config errors (empty output means none).
reload_and_check() {
  hyprland_running || return 0
  hyprctl reload >/dev/null 2>&1 || true
  sleep 1
  hyprctl configerrors 2>/dev/null | grep -v '^\s*$' || true
}

preflight() {
  [[ -d $OMARCHY_PATH/default/hypr && -f $OMARCHY_PATH/default/hypr/bootstrap.lua ]] ||
    die "this doesn't look like Omarchy 4 with the Lua Hyprland config ($OMARCHY_PATH/default/hypr/bootstrap.lua not found). Nothing was changed."
  command -v omarchy >/dev/null || die "the omarchy command was not found. Nothing was changed."
  local tool
  for tool in git hyprctl lua jq; do
    command -v "$tool" >/dev/null || die "$tool is required but not installed. Nothing was changed."
  done
  [[ -f $HYPRLAND_LUA ]] || die "$HYPRLAND_LUA not found. Nothing was changed."
  grep -qxF "$ANCHOR" "$HYPRLAND_LUA" ||
    die "couldn't find the line $ANCHOR in $HYPRLAND_LUA, so there's no safe place to load the shortcuts. Nothing was changed."
}

# --- Install / update ---

install() {
  preflight

  # Keep --pc-keyboard from a previous install unless told otherwise.
  if [[ -z $pc_keyboard ]]; then
    if grep -qxF "macos_pc_keyboard = true" "$HYPRLAND_LUA"; then pc_keyboard=true; else pc_keyboard=false; fi
  fi

  [[ -e $MODULE_LINK && ! -L $MODULE_LINK ]] &&
    die "$MODULE_LINK exists and is not a symlink. Move it away and try again. Nothing was changed."

  local before
  before="$(mktemp)"
  cp "$HYPRLAND_LUA" "$before"
  # A pristine copy, taken only before the very first install.
  if [[ ! -f $BACKUP_FILE ]] && ! grep -qF -- "-- >>> $MARKER" "$HYPRLAND_LUA"; then
    cp "$HYPRLAND_LUA" "$BACKUP_FILE"
  fi

  ln -sfn "$REPO_DIR/hypr" "$MODULE_LINK"

  local stripped next
  stripped="$(mktemp)"
  next="$(mktemp)"
  strip_blocks "$HYPRLAND_LUA" >"$stripped"
  insert_blocks "$stripped" "$pc_keyboard" >"$next"
  cat "$next" >"$HYPRLAND_LUA"
  rm -f "$stripped" "$next"

  mkdir -p "$(dirname "$HOOK_FILE")"
  sed "s|@REPO_DIR@|$REPO_DIR|g" "$REPO_DIR/hooks/post-update.hook" >"$HOOK_FILE"
  chmod +x "$HOOK_FILE"

  local errors
  errors="$(reload_and_check)"
  if [[ -n $errors ]]; then
    cat "$before" >"$HYPRLAND_LUA"
    rm -f "$before"
    printf 'omarchy-macos-shortcuts: Hyprland reported config errors, so the change was rolled back:\n%s\n' "$errors" >&2
    # On an update the previous config already loads this module, so restoring
    # it isn't enough if the module itself is broken: unload it entirely.
    if [[ -n $(reload_and_check) ]] && grep -qF -- "-- >>> $MARKER" "$HYPRLAND_LUA"; then
      stripped="$(mktemp)"
      strip_blocks "$HYPRLAND_LUA" >"$stripped"
      cat "$stripped" >"$HYPRLAND_LUA"
      rm -f "$stripped"
      reload_and_check >/dev/null
      printf 'The previous version still failed to load, so the shortcuts were unloaded and Omarchy defaults apply.\n' >&2
    fi
    exit 1
  fi
  rm -f "$before"

  say ""
  say "macOS shortcuts are installed and active."
  say "  - Cmd works like on a Mac: Cmd+C/V/Z/F/T/W/Q, Cmd+Tab, Cmd+Space, Cmd+Shift+3/4/5."
  say "  - Workspaces: Ctrl+Left/Right and Ctrl+1..0. Tiling: Ctrl+Opt+<key>."
  say "  - See every shortcut: Ctrl+Opt+/"
  $pc_keyboard && say "  - PC keyboard: Alt and Win are swapped, so the key next to the space bar is Cmd."
  say "  - Scrolling is now natural (like macOS). To turn it off, put this in ~/.config/hypr/input.lua:"
  say "      hl.config({ input = { natural_scroll = false, touchpad = { natural_scroll = false } } })"
  say "Check for problems: $REPO_DIR/bin/omarchy-macos-check"
  say "Uninstall:          $REPO_DIR/install.sh uninstall"
}

# --- Uninstall ---

uninstall() {
  if [[ -f $HYPRLAND_LUA ]]; then
    local stripped
    stripped="$(mktemp)"
    strip_blocks "$HYPRLAND_LUA" >"$stripped"
    cat "$stripped" >"$HYPRLAND_LUA"
    rm -f "$stripped"
  fi

  # Reload before removing the module, so Hyprland never points at a missing one.
  local errors
  errors="$(reload_and_check)"
  [[ -n $errors ]] && printf 'Note: Hyprland reports config errors (not from this module):\n%s\n' "$errors" >&2

  rm -f "$HOOK_FILE"
  [[ -L $MODULE_LINK ]] && rm -f "$MODULE_LINK"

  say "macOS shortcuts are removed and Omarchy's default bindings are back."
  [[ -f $BACKUP_FILE ]] && say "Your pre-install hyprland.lua is kept at $BACKUP_FILE."

  if [[ $REPO_DIR == "$INSTALL_DIR" ]]; then
    local answer=""
    # /dev/tty can exist without a controlling terminal, so try to open it.
    if (exec </dev/tty) 2>/dev/null; then
      printf 'Also delete the downloaded copy in %s? [y/N] ' "$INSTALL_DIR" >/dev/tty
      read -r answer </dev/tty || answer=""
    fi
    if [[ $answer == [yY]* ]]; then
      rm -rf "$INSTALL_DIR"
      say "Deleted $INSTALL_DIR."
    else
      say "Kept $INSTALL_DIR."
    fi
  fi
}

"$command_name"
