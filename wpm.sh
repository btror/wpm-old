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
end_time=$(( start_time + 5 ))
random_word=$(generate_random_word)
user_input=""
correct_words=0

display_state

while [ $(date +%s) -lt $end_time ]; do
  remaining_time=$(( end_time - $(date +%s) ))
  read -t $remaining_time -k 1 char || break

  if [[ "$char" == $'\177' ]]; then  # Check for backspace
    user_input=${user_input%?}  # Remove last character
    display_state
  elif [[ "$char" == " " ]]; then
    echo
    if [[ "$user_input" == "$random_word" ]]; then
      correct_words=$((correct_words + 1))
      random_word=$(generate_random_word)
      user_input=""
      display_state
    fi
  else
    user_input+=$char
    display_state
  fi
done

clear
echo "------------------------------------------"
echo "Time's up!"
echo "You correctly typed $correct_words words!"
echo "------------------------------------------"