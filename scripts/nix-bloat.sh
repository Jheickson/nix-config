#!/usr/bin/env bash
# nix-bloat.sh — inspect nix store / system closure bloat
#
# Usage:
#   ./scripts/nix-bloat.sh                # default: top 30 by own size in current-system
#   ./scripts/nix-bloat.sh -n 50          # top 50
#   ./scripts/nix-bloat.sh -m closure     # sort by closure size instead of own (narSize)
#   ./scripts/nix-bloat.sh -t home        # target home-manager profile
#   ./scripts/nix-bloat.sh -t /nix/store/...-foo   # arbitrary store path
#   ./scripts/nix-bloat.sh -w cef-binary  # why-depends: trace what pulls it
#   ./scripts/nix-bloat.sh -g             # show generations + profile sizes
#   ./scripts/nix-bloat.sh -a             # all-in-one report

set -euo pipefail

NUM=30
MODE="own"          # own | closure
TARGET="/run/current-system"
WHY=""
SHOW_GENS=0
ALL=0

usage() {
  sed -n '2,12p' "$0"
  exit "${1:-0}"
}

while getopts ":n:m:t:w:gah" opt; do
  case "$opt" in
    n) NUM="$OPTARG" ;;
    m) MODE="$OPTARG" ;;
    t) TARGET="$OPTARG" ;;
    w) WHY="$OPTARG" ;;
    g) SHOW_GENS=1 ;;
    a) ALL=1 ;;
    h) usage 0 ;;
    *) usage 1 ;;
  esac
done

resolve_target() {
  case "$1" in
    system|sys|"") echo "/run/current-system" ;;
    home|hm) echo "$HOME/.local/state/nix/profiles/home-manager" ;;
    user) echo "$HOME/.local/state/nix/profiles/profile" ;;
    *) echo "$1" ;;
  esac
}

human_mib() {
  awk '{ if ($1+0 >= 1073741824) printf "%.2f GiB\t", $1/1024/1024/1024;
         else                    printf "%6.1f MiB\t", $1/1024/1024;
         for (i=2; i<=NF; i++) printf "%s%s", $i, (i==NF ? "\n" : " ") }'
}

print_header() {
  printf "\n=== %s ===\n" "$1"
}

show_top() {
  local target="$1"
  local field
  case "$MODE" in
    own|nar)     field="narSize" ;;
    closure|tot) field="closureSize" ;;
    *) echo "unknown mode: $MODE (use 'own' or 'closure')"; exit 2 ;;
  esac

  print_header "Top $NUM by $field — $target"
  nix path-info -rS --json --json-format 1 "$target" \
    | jq -r --arg f "$field" \
        'to_entries
         | map({path: .key, size: .value[$f]})
         | sort_by(-.size)
         | .[0:'"$NUM"'][]
         | "\(.size)\t\(.path)"' \
    | human_mib
}

show_summary() {
  print_header "Summary sizes"
  local sys hm cfg store
  sys=$(nix path-info -Sh /run/current-system 2>/dev/null | awk '{print $2, $3}')
  hm=$(nix path-info -Sh "$HOME/.local/state/nix/profiles/home-manager" 2>/dev/null | awk '{print $2, $3}' || echo "n/a")
  cfg=$(du -sh "$(dirname "$(realpath "$0")")/.." 2>/dev/null | awk '{print $1}')
  store=$(du -sh /nix/store 2>/dev/null | awk '{print $1}' || echo "n/a")
  printf "  current-system closure : %s\n" "$sys"
  printf "  home-manager closure   : %s\n" "$hm"
  printf "  /nix/store on disk     : %s\n" "$store"
  printf "  config repo on disk    : %s\n" "$cfg"
}

show_gens() {
  print_header "System generations"
  if [ -r /nix/var/nix/profiles/system ]; then
    nix-env --list-generations --profile /nix/var/nix/profiles/system 2>/dev/null \
      || sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
  else
    echo "(need sudo to read system profile)"
  fi
  print_header "Home-manager generations"
  nix-env --list-generations --profile "$HOME/.local/state/nix/profiles/home-manager" 2>/dev/null || echo "n/a"
}

why_depends() {
  local needle="$1"
  local target="$2"
  print_header "why-depends: $needle in $target"
  local hit
  hit=$(nix path-info -r "$target" | grep -- "$needle" | head -1 || true)
  if [ -z "$hit" ]; then
    echo "no store path matching '$needle' in $target"
    return
  fi
  echo "matched: $hit"
  nix why-depends "$target" "$hit"
}

TARGET="$(resolve_target "$TARGET")"

if [ -n "$WHY" ]; then
  why_depends "$WHY" "$TARGET"
  exit 0
fi

if [ "$ALL" = "1" ]; then
  show_summary
  show_gens
  show_top "/run/current-system"
  TARGET="$(resolve_target home)"
  show_top "$TARGET"
  exit 0
fi

if [ "$SHOW_GENS" = "1" ]; then
  show_gens
  exit 0
fi

show_summary
show_top "$TARGET"
