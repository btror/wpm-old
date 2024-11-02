#!/bin/zsh

# Function to generate a random word
generate_random_word() {
  local words=("apple" "banana" "cherry" "date" "elderberry" "fig" "grape" "honeydew")
  local random_index=$(( $(od -An -N2 -i /dev/urandom) % ${#words[@]} + 1 ))
  echo ${words[$random_index]}
}

# Function to display current state
display_state() {
  clear
  echo "------------------------------------------"
  echo "     $random_word"
  echo ""
  echo "     $user_input"
  echo "------------------------------------------"
}

# Initialize variables
start_time=$(date +%s)
end_time=$(( start_time + 5 )) # + <time in seconds>
random_word=$(generate_random_word)
user_input=""
correct_words=0
incorrect_words=0
total_keystrokes=0

display_state

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

# Functions to render parts of the box dynamically
draw_top_border() {
    local width="$1"
    printf "╔%*s╗\n" "$width" | sed 's/ /═/g'
}

draw_bottom_border() {
    local width="$1"
    printf "╚%*s╝\n" "$width" | sed 's/ /═/g'
}

draw_horizontal_border() {
    local width="$1"
    printf "╠%*s╣\n" "$width" | sed 's/ /═/g'
}

draw_separator() {
    local width="$1"
    printf "║%*s║\n" "$width" | sed 's/ /─/g'
}

draw_empty_line() {
    local width="$1"
    printf "║%*s║\n" "$width" ""
}

center_text_in_box() {
    local label="$1"
    local width="$2"
    local text="$label"
    local padding_left=$(( (width - ${#text}) / 2 ))
    local padding_right=$(( width - ${#text} - padding_left ))
    printf "║%${padding_left}s%s%${padding_right}s║\n" "" "$text" ""
}

right_align_in_box() {
    local label="$1"
    local value="$2"
    local width="$3"
    printf "║  %-10s %$((width - 15))s  ║\n" "$label" "$value"
}

table_width=42

# Render Result Table
clear 
draw_top_border "$table_width"
center_text_in_box "Result" "$table_width"
draw_horizontal_border "$table_width"
draw_empty_line "$table_width"
center_text_in_box "WPM $wpm" "$table_width"
draw_empty_line "$table_width"
draw_separator "$table_width"
right_align_in_box "Keystrokes" "$total_keystrokes" "$table_width"
right_align_in_box "Accuracy" "$accuracy%" "$table_width"
right_align_in_box "Correct" "$correct_words" "$table_width"
right_align_in_box "Incorrect" "$incorrect_words" "$table_width"
draw_separator "$table_width"
draw_empty_line "$table_width"
draw_bottom_border "$table_width"
