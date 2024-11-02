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

pad_center() {
    local str="$1"
    local width=$2
    local padding=$(( (width - ${#str}) / 2 ))
    printf "%${padding}s%s%${padding}s" "" "$str" ""
}

pad_right() {
    local str="$1"
    local width=$2
    printf "%-${width}s" "$str"
}

pad_right_align() {
    local label="$1"
    local value="$2"
    local width=$3
    printf "║  %-10s %$((width - 15))s  ║\n" "$label" "$value"
}

# Calculate width based on the longest possible line
total_width=42

clear 
echo "╔══════════════════════════════════════════╗"
echo "║  Result                                  ║"
echo "║══════════════════════════════════════════║"
echo "║                                          ║"
printf "║%s║\n" "$(pad_center "$wpm WPM" $total_width)"
echo "║                                          ║"
echo "║------------------------------------------║"
pad_right_align "Keystrokes" "$total_keystrokes" "$total_width"
pad_right_align "Accuracy" "$accuracy%" "$total_width"
pad_right_align "Correct" "$correct_words" "$total_width"
pad_right_align "Incorrect" "$incorrect_words" "$total_width"
echo "║------------------------------------------║"
echo "║                                          ║"
echo "╚══════════════════════════════════════════╝"