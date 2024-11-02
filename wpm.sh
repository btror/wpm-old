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

display_state

while [ $(date +%s) -lt $end_time ]; do
  # Calculate remaining time for timeout
  remaining_time=$(( end_time - $(date +%s) ))
  
  # Read with timeout - will return 1 if timeout occurs
  read -t $remaining_time -k 1 char || break

  if [[ "$char" == " " ]]; then
    echo # Print newline after space
    if [[ "$user_input" == "$random_word" ]]; then
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
echo "------------------------------------------"
