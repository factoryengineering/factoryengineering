#!/usr/bin/env bash
# Set up symlinks so .claude/commands is available as commands/workflows in each IDE.
# Run from repository root. See SKILL.md for full workflow.
#
# Usage:
#   setup-symlinks.sh --detect
#   setup-symlinks.sh --ide cursor [--ide windsurf] [--ide kilocode] [--ide antigravity]
#   setup-symlinks.sh --ide cursor,windsurf --copy-existing
#   setup-symlinks.sh --repo-root /path/to/repo --ide cursor

set -e

REPO_ROOT=
DETECT=
IDES=
COPY_EXISTING=

# Map IDE -> (parent_dir, link_name)
# link at REPO_ROOT/parent_dir/link_name -> ../.claude/commands
cursor_target=".cursor/commands"
windsurf_target=".windsurf/workflows"
kilocode_target=".kilocode/workflows"
antigravity_target=".agent/workflows"

canonical_dir=".claude/commands"

usage() {
  echo "Usage: $0 [--repo-root PATH] [--detect | --ide IDE[,IDE...] [--copy-existing]]"
  echo "  --detect          Print detected IDEs (no changes)."
  echo "  --ide cursor,...  Create symlinks for cursor, windsurf, kilocode, antigravity."
  echo "  --copy-existing   If target dir exists, copy its contents to .claude/commands then replace with symlink."
  echo "  --repo-root PATH  Repository root (default: current directory)."
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-root)
      REPO_ROOT="$2"
      shift 2
      ;;
    --detect)
      DETECT=1
      shift
      ;;
    --ide)
      IDES="$2"
      shift 2
      ;;
    --copy-existing)
      COPY_EXISTING=1
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      ;;
  esac
done

if [[ -z "$REPO_ROOT" ]]; then
  REPO_ROOT="$(pwd)"
fi
REPO_ROOT="$(cd "$REPO_ROOT" && pwd)"
cd "$REPO_ROOT"

if [[ -n "$DETECT" ]]; then
  detected=()
  [[ -d ".cursor" ]] && detected+=(cursor)
  [[ -d ".windsurf" ]] && detected+=(windsurf)
  [[ -d ".kilocode" ]] && detected+=(kilocode)
  [[ -d ".agent" ]] && detected+=(antigravity)
  if [[ ${#detected[@]} -eq 0 ]]; then
    echo "No IDE directories (.cursor, .windsurf, .kilocode, .agent) found in $REPO_ROOT"
  else
    printf '%s\n' "${detected[@]}"
  fi
  exit 0
fi

if [[ -z "$IDES" ]]; then
  echo "Error: specify --ide cursor[,windsurf,kilocode,antigravity] or run with --detect first." >&2
  usage
fi

# Normalize IDEs to list
IFS=',' read -ra IDE_LIST <<< "$IDES"
for ide in "${IDE_LIST[@]}"; do
  ide="$(echo "$ide" | tr '[:upper:]' '[:lower:]' | xargs)"
  [[ -z "$ide" ]] && continue
  case "$ide" in
    cursor|windsurf|kilocode|antigravity) ;;
    *)
      echo "Error: unknown IDE '$ide'. Use cursor, windsurf, kilocode, antigravity." >&2
      exit 1
      ;;
  esac
done

mkdir -p "$canonical_dir"

create_symlink() {
  local target_path="$1"
  local parent_dir="${target_path%/*}"
  local link_name="${target_path##*/}"
  local existing_msg="Target $target_path already exists. Use --copy-existing to copy its contents to $canonical_dir and then create the symlink."

  if [[ -L "$target_path" ]]; then
    local dest
    dest="$(readlink "$target_path")"
    if [[ "$dest" == "../.claude/commands" || "$dest" == ".claude/commands" ]]; then
      echo "Already a symlink: $target_path"
      return 0
    fi
    echo "Error: $target_path is a symlink but not to $canonical_dir." >&2
    return 1
  fi

  if [[ -d "$target_path" ]]; then
    if [[ -n "$COPY_EXISTING" ]]; then
      echo "Copying existing $target_path into $canonical_dir ..."
      cp -Rn "$target_path"/. "$canonical_dir/" 2>/dev/null || true
      rm -rf "$target_path"
    else
      echo "$existing_msg" >&2
      return 2
    fi
  fi

  mkdir -p "$parent_dir"
  ln -s "../.claude/commands" "$target_path"
  echo "Created: $target_path -> ../.claude/commands"
}

exit_code=0
for ide in "${IDE_LIST[@]}"; do
  ide="$(echo "$ide" | tr '[:upper:]' '[:lower:]' | xargs)"
  [[ -z "$ide" ]] && continue
  case "$ide" in
    cursor)     create_symlink "$cursor_target"     || exit_code=$? ;;
    windsurf)   create_symlink "$windsurf_target"   || exit_code=$? ;;
    kilocode)   create_symlink "$kilocode_target"   || exit_code=$? ;;
    antigravity) create_symlink "$antigravity_target" || exit_code=$? ;;
  esac
  [[ $exit_code -eq 2 ]] && break
done
exit $exit_code
