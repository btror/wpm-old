#!/bin/zsh

# Configurable variables
typing_table_width=80
result_table_width=42
prompt_char=">"
header_separator_char="═"
data_separator_char="─"
vertical_border_char="║"
test_duration=10

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
    local padding_left=$(( (width - ${#label}) / 2 ))
    local padding_right=$(( width - ${#label} - padding_left ))
    printf "$border_char%${padding_left}s%s%${padding_right}s$border_char\n" "" "$label" ""
}

left_align() {
    local width="$1"
    local label="$2"
    local value="$3"
    local border_char="$4"
    printf "$border_char  %-10s %-*s  $border_char\n" "$label" $((width - 15)) "$value"
}

right_align() {
    local width="$1"
    local label="$2"
    local value="$3"
    local border_char="$4"
    printf "$border_char  %-10s %$((width - 15))s  $border_char\n" "$label" "$value"
}

# Typing test functions
generate_random_word() {
  local words=("apple" "banana" "cherry" "date" "elderberry" "fig" "grape" "honeydew")
  local random_index=$(( $(od -An -N2 -i /dev/urandom) % ${#words[@]} + 1 ))
  echo ${words[$random_index]}
}

# Function to display current state
display_state() {
  clear

  draw_new_line "$typing_table_width" "$random_word" "" "center" ""
  draw_separator "$typing_table_width" "" ""
  echo "$prompt_char $user_input"
}

# Initialize variables
start_time=$(date +%s)
end_time=$(( start_time + test_duration ))
random_word=$(generate_random_word)
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
    echo
    if [[ "$user_input" == "$random_word" ]]; then
      correct_words=$((correct_words + 1))
      random_word=$(generate_random_word)
      user_input=""
      display_state
    else
      incorrect_words=$((incorrect_words + 1))
      random_word=$(generate_random_word)
      user_input=""
      display_state
    fi
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
