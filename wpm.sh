#!/bin/zsh

# Hide cursor: TODO: figure out a better place to put this (in some terminals without it it will show the cursor on the first line)
tput civis

# Configurable variables
typing_table_width=80
result_table_width=42
prompt_char=">"
header_separator_char="═"
data_separator_char="─"
vertical_border_char="║"
test_duration=25

# Table drawing functions
draw_top_border() {
    local width="$1"
    printf "╔%*s╗\n" "$width" | sed 's/ /═/g'
}

draw_bottom_border() {
    local width="$1"
    printf "╚%*s╝\n" "$width" | sed 's/ /═/g'
}

draw_separator() {
    local width="$1"
    local separator_char="${2:-─}" # default is '─'
    local vertical_border_char="${3:-}" # default is empty

    if [[ "$separator_char" == "═" ]]; then
        printf "╠%*s╣\n" "$width" | sed "s/ /$separator_char/g"
    else
        printf "$vertical_border_char%*s$vertical_border_char\n" "$width" | sed "s/ /$separator_char/g"
    fi
}

draw_new_line() {
    local width="$1"
    local label="${2:-}" # default is empty
    local value="${3:-}" # default is empty
    local align="${4:-}" # center, left, or right
    local border_char="${5:-}" # default is empty

    if [[ "$align" == "center" ]]; then
        center_align "$width" "$label" "$border_char"
    elif [[ "$align" == "right" ]]; then
        right_align "$width" "$label" "$value" "$border_char"
    else
        left_align "$width" "$label" "$value" "$border_char"
    fi
}

center_align() {
    local width="$1"
    local label="$2"
    local border_char="$3"
    local clean_label=$(printf '%b' "$label" | sed 's/\x1b\[[0-9;]*m//g')
    local padding_left=$(( (width - ${#clean_label}) / 2 ))
    local padding_right=$(( width - ${#clean_label} - padding_left ))
    printf "$border_char%${padding_left}s%s%${padding_right}s$border_char\n" "" "$label" ""
}

left_align() {
    local width="$1"
    local label="$2"
    local value="$3"
    local border_char="$4"
    local clean_label=$(printf '%b' "$label" | sed 's/\x1b\[[0-9;]*m//g')
    printf "$border_char  %-10s %-*s  $border_char\n" "$clean_label" $((width - 15)) "$value"
}

right_align() {
    local width="$1"
    local label="$2"
    local value="$3"
    local border_char="$4"
    local clean_label=$(printf '%b' "$label" | sed 's/\x1b\[[0-9;]*m//g')
    printf "$border_char  %-10s %$((width - 15))s  $border_char\n" "$clean_label" "$value"
}

# Typing test functions
generate_random_word() {
  local words=("apple" "banana" "cherry" "date" "elder" "fig" "grape" "honey")
  local random_index=$(( ( $(od -An -N2 -i /dev/urandom) % (${#words[@]}) ) + 1 ))
  printf "%s\n" "${words[$random_index]}"
}

generate_word_list() {
  local count="$1"
  local word_list=()
  for i in {1..$count}; do
    word_list+=("$(generate_random_word)")
  done
  printf "%s\n" "${word_list[@]}"
}

# Function to display current state
display_state() {
  clear
  word_list_top[$current_word_index]=$'\e[32m'"${word_list_top[current_word_index]}"$'\e[0m'

  draw_new_line "$typing_table_width" "$word_list_top" "" "center" "" # Display the top line of words
  draw_new_line "$typing_table_width" "$word_list_bottom" "" "center" "" # Display the bottom line of words
  draw_separator "$typing_table_width" "" ""

  printf "$prompt_char $user_input"
}

# Initialize variables
start_time=$(date +%s)
end_time=$(( start_time + test_duration ))
word_list=($(generate_word_list 20))
word_list_top=("${word_list[@]:0:10}")
word_list_bottom=("${word_list[@]:10}")
current_word_index=1
user_input=""
correct_words=0
incorrect_words=0
total_keystrokes=0

display_state

# Main loop
while [ $(date +%s) -lt $end_time ]; do
  remaining_time=$(( end_time - $(date +%s) ))
  read -t $remaining_time -k 1 char || break

  total_keystrokes=$((total_keystrokes + 1))  # Increment for every keystroke

  if [[ "$char" == $'\177' ]]; then  # backspace keystroke
    user_input=${user_input%?}  # remove last character
    display_state
  elif [[ "$char" == " " ]]; then # space keystroke
    if [[ "$user_input" == "${word_list[$current_word_index]}" ]]; then
      correct_words=$((correct_words + 1))
    else
      incorrect_words=$((incorrect_words + 1))
    fi

    if [[ $current_word_index -ge 10 ]]; then
      word_list=("${word_list[@]:10}" $(generate_word_list 10 | cut -d' ' -f1-10))
      word_list_top=("${word_list[@]:0:10}")
      word_list_bottom=("${word_list[@]:10}")

      current_word_index=0
    fi

    current_word_index=$((current_word_index + 1))
    user_input=""
    display_state
  else
    user_input+=$char
    display_state
  fi
done

# Calculate final statistics
elapsed_time=$(( end_time - start_time ))
total_words=$(( correct_words + incorrect_words ))
wpm=$(( (correct_words * 60) / elapsed_time ))
accuracy=0
if [[ $total_words -gt 0 ]]; then
    accuracy=$(( (correct_words * 100) / total_words ))
fi

# Render Result Table
clear 

draw_top_border "$result_table_width"
draw_new_line "$result_table_width" "Result" "" "center" "$vertical_border_char"
draw_separator "$result_table_width" "$header_separator_char" "$vertical_border_char"
draw_new_line "$result_table_width" "" "" "" "$vertical_border_char"
draw_new_line "$result_table_width" "$wpm WPM" "" "center" "$vertical_border_char"
draw_new_line "$result_table_width" "" "" "" "$vertical_border_char"
draw_separator "$result_table_width" "$data_separator_char" "$vertical_border_char"
draw_new_line "$result_table_width" "Keystrokes" "$total_keystrokes" "right" "$vertical_border_char"
draw_new_line "$result_table_width" "Accuracy" "$accuracy%" "right" "$vertical_border_char"
draw_new_line "$result_table_width" "Correct" "$correct_words" "right" "$vertical_border_char"
draw_new_line "$result_table_width" "Incorrect" "$incorrect_words" "right" "$vertical_border_char"
draw_separator "$result_table_width" "$data_separator_char" "$vertical_border_char"
draw_new_line "$result_table_width" "" "" "" "$vertical_border_char"
draw_bottom_border "$result_table_width"

# Show cursor
tput cnorm
