#!/bin/sh
input=$(cat)
printf '%s\n' "$input" > /tmp/cc-statusline-input.json

model=$(echo "$input" | jq -r '.model.display_name // "unknown"')
effort=$(echo "$input" | jq -r '.effort.level // empty')
thinking=$(echo "$input" | jq -r '.thinking.enabled')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
duration_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // empty')
input_tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // empty')
output_tokens=$(echo "$input" | jq -r '.context_window.total_output_tokens // empty')
cache_read_tokens=$(echo "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // empty')
cache_creation_tokens=$(echo "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // empty')
raw_input_tokens=$(echo "$input" | jq -r '.context_window.current_usage.input_tokens // empty')
five_hour_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_resets_at=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
seven_day_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
seven_day_resets_at=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // empty')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // empty')

format_tokens() {
  n="${1:-0}"
  if [ "$n" -ge 1000 ] 2>/dev/null; then
    printf '%.0fk' "$(echo "$n / 1000" | bc -l)"
  else
    printf '%s' "$n"
  fi
}

build_bar() {
  pct="$1"
  segments="${2:-10}"
  filled=$(printf '%.0f' "$(echo "$pct * $segments / 100" | bc -l)")
  [ "$filled" -gt "$segments" ] && filled="$segments"
  [ "$filled" -lt 0 ] && filled=0
  result=""
  i=0
  while [ "$i" -lt "$filled" ]; do result="${result}█"; i=$((i + 1)); done
  while [ "$i" -lt "$segments" ]; do result="${result}░"; i=$((i + 1)); done
  printf '%s' "$result"
}

display_width() {
  printf '%s' "$1" | wc -m | tr -d ' '
}

context_field=""
if [ -n "$used" ]; then
  rounded=$(printf '%.0f' "$used")
  bar=$(build_bar "$used" 10)
  context_field="context: [${bar}] ${rounded}% used"
  if [ -n "$input_tokens" ]; then
    context_field="$context_field ($(format_tokens "$input_tokens") in)"
  fi
fi

output_field=""
if [ -n "$output_tokens" ]; then
  output_field="most recent output: $(format_tokens "$output_tokens")"
fi

duration_field=""
if [ -n "$duration_ms" ]; then
  total_seconds=$(printf '%.0f' "$(echo "$duration_ms / 1000" | bc -l)")
  hours=$((total_seconds / 3600))
  minutes=$(((total_seconds % 3600) / 60))
  if [ "$hours" -gt 0 ]; then
    duration_field="duration: ${hours}h ${minutes}m"
  else
    duration_field="duration: ${minutes}m"
  fi
fi

thinking_field="thinking: off"
[ "$thinking" = "true" ] && thinking_field="thinking: on"

effort_field=""
[ -n "$effort" ] && effort_field="effort: $effort"

cost_field=""
[ -n "$cost_usd" ] && cost_field=$(printf 'cost: $%.2f' "$cost_usd")

lines_field=""
if [ -n "$lines_added" ] || [ -n "$lines_removed" ]; then
  lines_field=$(printf 'lines: +%s / -%s' "${lines_added:-0}" "${lines_removed:-0}")
fi

cache_field=""
if [ -n "$cache_read_tokens" ] || [ -n "$cache_creation_tokens" ]; then
  read_n="${cache_read_tokens:-0}"
  create_n="${cache_creation_tokens:-0}"
  raw_n="${raw_input_tokens:-0}"
  total_n=$(echo "$raw_n + $read_n + $create_n" | bc)
  if [ "$total_n" -gt 0 ]; then
    hit_pct=$(printf '%.0f' "$(echo "$read_n * 100 / $total_n" | bc -l)")
    write_pct=$(printf '%.0f' "$(echo "$create_n * 100 / $total_n" | bc -l)")
    cache_field="cache: ${hit_pct}% hit / ${write_pct}% write"
  fi
fi

format_resets_in() {
  resets_at="$1"
  [ -z "$resets_at" ] && return
  now=$(date +%s)
  diff=$((resets_at - now))
  [ "$diff" -le 0 ] && printf 'resets soon' && return
  days=$((diff / 86400))
  hours=$(((diff % 86400) / 3600))
  minutes=$(((diff % 3600) / 60))
  if [ "$days" -gt 0 ]; then
    printf 'resets in %dd %dh' "$days" "$hours"
  elif [ "$hours" -gt 0 ]; then
    printf 'resets in %dh %dm' "$hours" "$minutes"
  else
    printf 'resets in %dm' "$minutes"
  fi
}

five_hour_field=""
if [ -n "$five_hour_pct" ]; then
  bar=$(build_bar "$five_hour_pct" 10)
  rounded=$(printf '%3.0f' "$five_hour_pct")
  five_hour_field="5h: [${bar}] ${rounded}%"
  if [ -n "$five_hour_resets_at" ]; then
    reset_label=$(format_resets_in "$five_hour_resets_at")
    five_hour_field="${five_hour_field} (${reset_label})"
  fi
fi

seven_day_field=""
if [ -n "$seven_day_pct" ]; then
  bar=$(build_bar "$seven_day_pct" 10)
  rounded=$(printf '%3.0f' "$seven_day_pct")
  seven_day_field="7d: [${bar}] ${rounded}%"
  if [ -n "$seven_day_resets_at" ]; then
    reset_label=$(format_resets_in "$seven_day_resets_at")
    seven_day_field="${seven_day_field} (${reset_label})"
  fi
fi

pad_right() {
  item="$1"
  target_w="$2"
  cur_w=$(display_width "$item")
  pad_chars=$((target_w - cur_w))
  result="$item"
  i=0
  while [ "$i" -lt "$pad_chars" ]; do result="${result} "; i=$((i + 1)); done
  printf '%s' "$result"
}

build_left() {
  items_file="$1"
  fixed_sep="  ·  "
  n=$(wc -l < "$items_file" | tr -d ' ')
  left=""
  i=1
  while [ "$i" -le "$n" ]; do
    item=$(sed -n "${i}p" "$items_file")
    eval "target_w=\${col_w_$i:-0}"
    padded=$(pad_right "$item" "$target_w")
    if [ -z "$left" ]; then
      left="$padded"
    else
      left="${left}${fixed_sep}${padded}"
    fi
    i=$((i + 1))
  done
  printf '%s' "$left"
}

emit_row() {
  left="$1"
  last_item="$2"
  if [ -z "$last_item" ]; then
    echo "$left"
    return
  fi
  sep="  ·  "
  echo "${left}${sep}${last_item}"
}

row1_items=$(mktemp)
{
  printf '%s\n' "$model"
  [ -n "$effort_field" ] && printf '%s\n' "$effort_field"
  printf '%s\n' "$thinking_field"
  [ -n "$duration_field" ] && printf '%s\n' "$duration_field"
} > "$row1_items"

row2_items=$(mktemp)
{
  [ -n "$context_field" ] && printf '%s\n' "$context_field"
  [ -n "$output_field" ] && printf '%s\n' "$output_field"
  [ -n "$cache_field" ] && printf '%s\n' "$cache_field"
  [ -n "$cost_field" ] && printf '%s\n' "$cost_field"
  [ -n "$lines_field" ] && printf '%s\n' "$lines_field"
} > "$row2_items"

n1=$(wc -l < "$row1_items" | tr -d ' ')
n2=$(wc -l < "$row2_items" | tr -d ' ')
if [ "$n1" -ge "$n2" ]; then n_cols=$n1; else n_cols=$n2; fi

i=1
while [ "$i" -le "$n_cols" ]; do
  w1=0
  w2=0
  if [ "$i" -le "$n1" ]; then
    item=$(sed -n "${i}p" "$row1_items")
    w1=$(display_width "$item")
  fi
  if [ "$i" -le "$n2" ]; then
    item=$(sed -n "${i}p" "$row2_items")
    w2=$(display_width "$item")
  fi
  if [ "$w1" -ge "$w2" ]; then max_w=$w1; else max_w=$w2; fi
  eval "col_w_$i=$max_w"
  i=$((i + 1))
done

row1_left=$(build_left "$row1_items")
row2_left=$(build_left "$row2_items")

# Pad the left sections to equal width so neither row drifts.
row1_left_w=$(display_width "$row1_left")
row2_left_w=$(display_width "$row2_left")
if [ "$row1_left_w" -gt "$row2_left_w" ]; then
  row2_left=$(pad_right "$row2_left" "$row1_left_w")
  row2_left_w=$row1_left_w
elif [ "$row2_left_w" -gt "$row1_left_w" ]; then
  row1_left=$(pad_right "$row1_left" "$row2_left_w")
  row1_left_w=$row2_left_w
fi

# Pad the rate-limit fields to equal width so their left edges line up between rows.
five_hour_w=$(display_width "$five_hour_field")
seven_day_w=$(display_width "$seven_day_field")
if [ "$five_hour_w" -gt "$seven_day_w" ]; then
  seven_day_field=$(pad_right "$seven_day_field" "$five_hour_w")
elif [ "$seven_day_w" -gt "$five_hour_w" ]; then
  five_hour_field=$(pad_right "$five_hour_field" "$seven_day_w")
fi

emit_row "$row1_left" "$five_hour_field"
emit_row "$row2_left" "$seven_day_field"

rm -f "$row1_items" "$row2_items"
