#!/bin/bash
# Two-line Claude Code status line.
# Line 1: identity + fixed session info. Line 2: volatile git/session state.
# Always renders exactly two lines; never wraps or ellipsizes.

# --- ANSI colors -------------------------------------------------------------
D=$'\033[2m'    # dim
B=$'\033[1m'    # bold
R=$'\033[0m'    # reset
CY=$'\033[36m'  # cyan
MG=$'\033[35m'  # magenta
GR=$'\033[32m'  # green
YL=$'\033[33m'  # yellow
RD=$'\033[31m'  # red
SEP="${D} | ${R}"

json="$(cat)"

# --- Parse payload (one jq call, newline-delimited so empty fields survive) ---
{
  IFS= read -r project_dir
  IFS= read -r git_worktree
  IFS= read -r cwd
  IFS= read -r session_name
  IFS= read -r display_name
  IFS= read -r effort
  IFS= read -r cost
  IFS= read -r remaining
  IFS= read -r in_tok
  IFS= read -r cr_tok
  IFS= read -r cc_tok
} < <(printf '%s' "$json" | jq -r '
  .workspace.project_dir // "",
  .workspace.git_worktree // "",
  .cwd // "",
  .session_name // "",
  .model.display_name // "",
  .effort.level // "",
  (.cost.total_cost_usd // 0 | tostring),
  (.context_window.remaining_percentage // -1 | tostring),
  (.context_window.current_usage.input_tokens // 0 | tostring),
  (.context_window.current_usage.cache_read_input_tokens // 0 | tostring),
  (.context_window.current_usage.cache_creation_input_tokens // 0 | tostring)
' 2>/dev/null)

[ -z "$cwd" ] && cwd="$PWD"

# ============================================================================
# LINE 1
# ============================================================================
line1=""

# 1. 📁 repo (bold) + /subdir (dim) when cwd is below project root
repo=""
[ -n "$project_dir" ] && repo="$(basename "$project_dir")"
[ -z "$repo" ] && repo="$(basename "$cwd")"
subdir=""
if [ -n "$project_dir" ] && [ "$cwd" != "$project_dir" ]; then
  case "$cwd" in
    "$project_dir"/*) subdir="${cwd#"$project_dir"/}" ;;
  esac
fi
seg="📁 ${B}${repo}${R}"
[ -n "$subdir" ] && seg="${seg}${D}/${subdir}${R}"
line1="$seg"

# 2. 🤖 model (leading "Claude" stripped) + ⚡effort indicator
model="${display_name#Claude }"
model="${model#Claude}"
[ -z "$model" ] && model="$display_name"
case "$effort" in
  low)   eff="${D}⚡low${R}" ;;
  high)  eff="${YL}⚡high${R}" ;;
  xhigh) eff="${RD}⚡xhigh${R}" ;;
  *)     eff="" ;;  # medium / unknown: hidden
esac
line1="${line1}${SEP}🤖 ${model}${eff}"

# 3. 💰 session cost (magenta)
line1="${line1}${SEP}💰 ${MG}\$$(printf '%.2f' "${cost:-0}" 2>/dev/null)${R}"

# 4. 🧠 context: raw active tokens + remaining %, colored by urgency
tokens=$(( ${in_tok:-0} + ${cr_tok:-0} + ${cc_tok:-0} ))
if [ "$tokens" -ge 1000 ]; then
  raw_fmt=$(awk -v n="$tokens" 'BEGIN{printf "%.1fk", n/1000}')
else
  raw_fmt="$tokens"
fi
if [ -n "$remaining" ] && [ "$remaining" != "-1" ]; then
  pct=$(printf '%.0f' "$remaining" 2>/dev/null)
  if   [ "$pct" -ge 40 ]; then cc="$GR"
  elif [ "$pct" -ge 15 ]; then cc="$YL"
  else cc="$RD"
  fi
  line1="${line1}${SEP}🧠 ${cc}${raw_fmt} (${pct}%)${R}"
else
  line1="${line1}${SEP}🧠 ${raw_fmt}"
fi

# ============================================================================
# LINE 2
# ============================================================================
git_grp=""

branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --quiet --short HEAD 2>/dev/null)
if [ -z "$branch" ]; then
  sha=$(git -C "$cwd" --no-optional-locks rev-parse --short HEAD 2>/dev/null)
  [ -n "$sha" ] && branch="detached@${sha}"
fi

if [ -n "$branch" ]; then
  git_grp="🍃 ${CY}${branch}${R}"

  # Ahead/behind vs upstream (append directly, no separator)
  counts=$(git -C "$cwd" --no-optional-locks rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)
  if [ -n "$counts" ]; then
    behind=${counts%%[!0-9]*}
    ahead=${counts##*[!0-9]}
    [ "${ahead:-0}" -gt 0 ] 2>/dev/null && git_grp="${git_grp}${GR}⬆${ahead}${R}"
    [ "${behind:-0}" -gt 0 ] 2>/dev/null && git_grp="${git_grp}${RD}⬇${behind}${R}"
  fi

  # Status counts from a single porcelain call
  porcelain=$(git -C "$cwd" --no-optional-locks status --porcelain 2>/dev/null)
  staged=0; unstaged=0; untracked=0
  if [ -n "$porcelain" ]; then
    while IFS= read -r ln; do
      [ -z "$ln" ] && continue
      x=${ln:0:1}; y=${ln:1:1}
      if [ "$x$y" = "??" ]; then
        untracked=$((untracked+1)); continue
      fi
      [ "$x" != " " ] && staged=$((staged+1))
      [ "$y" != " " ] && unstaged=$((unstaged+1))
    done <<EOF
$porcelain
EOF
  fi
  [ "$staged"    -gt 0 ] && git_grp="${git_grp} ${GR}+${staged}${R}"
  [ "$unstaged"  -gt 0 ] && git_grp="${git_grp} ${YL}*${unstaged}${R}"
  [ "$untracked" -gt 0 ] && git_grp="${git_grp} ${D}?${untracked}${R}"

  # [worktree-name] when in a git worktree
  [ -n "$git_worktree" ] && git_grp="${git_grp} ${D}[$(basename "$git_worktree")]${R}"
fi

# 🎯 session name (cyan), most expendable — rides at the very end
line2="$git_grp"
if [ -n "$session_name" ]; then
  if [ -n "$line2" ]; then
    line2="${line2}${SEP}🎯 ${CY}${session_name}${R}"
  else
    line2="🎯 ${CY}${session_name}${R}"
  fi
fi

# ============================================================================
# Always exactly two lines
# ============================================================================
printf '%s\n%s\n' "$line1" "$line2"
