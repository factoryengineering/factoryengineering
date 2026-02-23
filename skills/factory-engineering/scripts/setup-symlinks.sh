#!/usr/bin/env bash
# Set up symlinks so .claude/commands and .claude/skills are available in each IDE.
# Run from repository root. See SKILL.md (factory-engineering skill) for full workflow.
#
# Usage:
#   setup-symlinks.sh --detect
#   setup-symlinks.sh --ide cursor [--ide windsurf] [--ide kilocode] [--ide antigravity]
#   setup-symlinks.sh --type all --ide cursor
#   setup-symlinks.sh --ide cursor,windsurf --copy-existing
#   setup-symlinks.sh --repo-root /path/to/repo --ide cursor

set -e

REPO_ROOT=
DETECT=
IDES=
COPY_EXISTING=
TYPE="all"

# Commands/workflows: canonical .claude/commands -> IDE-specific paths
cursor_commands=".cursor/commands"
windsurf_commands=".windsurf/workflows"
kilocode_commands=".kilocode/workflows"
antigravity_commands=".agent/workflows"
canonical_commands=".claude/commands"

# Skills: canonical .claude/skills -> IDE-specific paths (Cursor reads .claude/skills directly; no symlink)
windsurf_skills=".windsurf/skills"
kilocode_skills=".kilocode/skills"
antigravity_skills=".agent/skills"
canonical_skills=".claude/skills"

usage() {
  echo "Usage: $0 [--repo-root PATH] [--type TYPE] [--detect | --ide IDE[,IDE...] [--copy-existing]]"
  echo "  --detect          Print detected IDEs (no changes)."
  echo "  --type TYPE       One of: commands, skills, all (default: all)."
  echo "  --ide cursor,...  Create symlinks for cursor, windsurf, kilocode, antigravity."
  echo "  --copy-existing   If target exists, copy its contents to canonical dir then replace with symlink."
  echo "  --repo-root PATH  Repository root (default: current directory)."
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo-root)
      REPO_ROOT="$2"
      shift 2
      ;;
    --type)
      TYPE="$2"
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

case "$TYPE" in
  commands|skills|all) ;;
  *)
    echo "Error: --type must be commands, skills, or all." >&2
    usage
    ;;
esac

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

create_symlink() {
  local target_path="$1"
  local canonical_dir="$2"
  local parent_dir="${target_path%/*}"
  local existing_msg="Target $target_path already exists. Use --copy-existing to copy its contents to $canonical_dir and then create the symlink."

  if [[ -L "$target_path" ]]; then
    local dest
    dest="$(readlink "$target_path")"
    if [[ "$dest" == "../$canonical_dir" || "$dest" == "$canonical_dir" ]]; then
      echo "Already a symlink: $target_path"
      return 0
    fi
    echo "Error: $target_path is a symlink but not to $canonical_dir." >&2
    return 1
  fi

  if [[ -d "$target_path" ]]; then
    if [[ -n "$COPY_EXISTING" ]]; then
      echo "Copying existing $target_path into $canonical_dir ..."
      mkdir -p "$canonical_dir"
      cp -Rn "$target_path"/. "$canonical_dir/" 2>/dev/null || true
      rm -rf "$target_path"
    else
      echo "$existing_msg" >&2
      return 2
    fi
  fi

  mkdir -p "$canonical_dir"
  mkdir -p "$parent_dir"
  ln -s "../$canonical_dir" "$target_path"
  echo "Created: $target_path -> ../$canonical_dir"
}

run_for_ide() {
  local ide="$1"
  local ec=0
  if [[ "$TYPE" == "commands" || "$TYPE" == "all" ]]; then
    case "$ide" in
      cursor)     create_symlink "$cursor_commands"     "$canonical_commands" || ec=$? ;;
      windsurf)   create_symlink "$windsurf_commands"   "$canonical_commands" || ec=$? ;;
      kilocode)   create_symlink "$kilocode_commands"   "$canonical_commands" || ec=$? ;;
      antigravity) create_symlink "$antigravity_commands" "$canonical_commands" || ec=$? ;;
    esac
    [[ $ec -eq 2 ]] && return 2
  fi
  if [[ "$TYPE" == "skills" || "$TYPE" == "all" ]]; then
    case "$ide" in
      cursor)     ;;  # Cursor reads .claude/skills directly; no symlink
      windsurf)   create_symlink "$windsurf_skills"   "$canonical_skills" || ec=$? ;;
      kilocode)   create_symlink "$kilocode_skills"   "$canonical_skills" || ec=$? ;;
      antigravity) create_symlink "$antigravity_skills" "$canonical_skills" || ec=$? ;;
    esac
    [[ $ec -eq 2 ]] && return 2
  fi
  return $ec
}

exit_code=0
for ide in "${IDE_LIST[@]}"; do
  ide="$(echo "$ide" | tr '[:upper:]' '[:lower:]' | xargs)"
  [[ -z "$ide" ]] && continue
  run_for_ide "$ide" || exit_code=$?
  [[ $exit_code -eq 2 ]] && break
done
exit $exit_code
