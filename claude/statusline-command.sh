#!/usr/bin/env bash
# Claude Code status line — Git Bash / Windows (uses node, no jq dependency)

input=$(cat)

# Parse all fields in one node call (tab-separated)
parsed=$(
  node -e '
    let s=""; process.stdin.on("data",d=>s+=d).on("end",()=>{
      try {
        const j = JSON.parse(s);
        const out = [
          j.workspace?.current_dir || j.cwd || "",
          j.model?.display_name || "",
          j.context_window?.used_percentage ?? "",
          j.vim?.mode || "",
          j.rate_limits?.five_hour?.used_percentage ?? "",
          j.rate_limits?.seven_day?.used_percentage ?? "",
          j.session_id || "",
        ];
        process.stdout.write(out.join("|"));
      } catch(e) { process.stdout.write("||||||"); }
    });
  ' <<< "$input"
)
IFS=$'|' read -r cwd model used vim_mode five_pct week_pct session_id <<< "$parsed"

# --- Directory: shorten home to ~ ---
home_dir=$(cygpath -u "$USERPROFILE" 2>/dev/null || echo "$HOME")
# Normalize cwd to unix-style if it's a Windows path
if [[ "$cwd" =~ ^[A-Za-z]: ]]; then
  cwd=$(cygpath -u "$cwd" 2>/dev/null || echo "$cwd")
fi
short_dir="${cwd/#$home_dir/\~}"
# Trim to last 3 path components if deep
short_dir=$(echo "$short_dir" | awk -F'/' '{
  n=NF; if(n>3){ printf "…"; for(i=n-2;i<=n;i++) printf "/"$i } else print $0 }')

# --- Git branch (skip optional locks) ---
git_branch=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  git_branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null \
               || GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
fi

# --- ANSI helpers ---
esc=$'\033'
reset="${esc}[0m"
bold="${esc}[1m"
dim="${esc}[2m"

fg_cyan="${esc}[36m"
fg_blue="${esc}[34m"
fg_yellow="${esc}[33m"
fg_green="${esc}[32m"
fg_red="${esc}[31m"
fg_magenta="${esc}[35m"
fg_white="${esc}[37m"

# --- Assemble segments ---
out=""

# Directory
out="${bold}${fg_cyan}${short_dir}${reset}"

# Git branch
if [ -n "$git_branch" ]; then
  out="${out}  ${fg_yellow} ${git_branch}${reset}"
fi

# Model
if [ -n "$model" ]; then
  out="${out}  ${dim}${fg_white}${model}${reset}"
fi

# Context usage bar (only after first API call)
if [ -n "$used" ] && [ "$used" != "null" ]; then
  used_int=$(printf "%.0f" "$used" 2>/dev/null || echo 0)
  if   [ "$used_int" -ge 85 ]; then bar_color="$fg_red"
  elif [ "$used_int" -ge 60 ]; then bar_color="$fg_yellow"
  else                               bar_color="$fg_green"
  fi
  filled=$(( used_int / 10 ))
  [ "$filled" -gt 10 ] && filled=10
  empty=$(( 10 - filled ))
  bar=""
  for ((i=0;i<filled;i++)); do bar="${bar}█"; done
  for ((i=0;i<empty;i++));  do bar="${bar}░"; done
  out="${out}  ${bar_color}${bar}${reset} ${dim}${used_int}%${reset}"
fi

# Rate limits
if [ -n "$five_pct" ] && [ "$five_pct" != "null" ]; then
  limits="5h:$(printf '%.0f' "$five_pct")%"
  if [ -n "$week_pct" ] && [ "$week_pct" != "null" ]; then
    limits="${limits} 7d:$(printf '%.0f' "$week_pct")%"
  fi
  out="${out}  ${dim}${fg_magenta}${limits}${reset}"
fi

# Vim mode
if [ -n "$vim_mode" ]; then
  case "$vim_mode" in
    NORMAL)  vm_color="$fg_blue"   ;;
    INSERT)  vm_color="$fg_green"  ;;
    *)       vm_color="$fg_white"  ;;
  esac
  out="${out}  ${bold}${vm_color}${vim_mode}${reset}"
fi

# Fork-session command line (second line, copy-pasteable)
if [ -n "$session_id" ]; then
  out="${out}\n${dim}fork:${reset} c --resume ${session_id} --fork-session"
fi

printf "%b" "$out"
