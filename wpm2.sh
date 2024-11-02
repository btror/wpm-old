#!/bin/zsh

countdown() {
    local label=$1
    local seconds=$(($2+1))

    trap exit SIGUSR1

    printf "$label" "$(printf "%02d:%02d:%02d" "$((seconds / 3600))" "$(( (seconds / 60) % 60))" "$((seconds % 60))")"
    
    while ((seconds--)); do
        sleep 1 &
        printf "\e[s\r$label\e[u" "$(printf "%02d:%02d:%02d" "$((seconds / 3600))" "$(( (seconds / 60) % 60))" "$((seconds % 60))")"
        wait
    done
}

countdown_end() {
    pkill -SIGUSR1 -P "$1"
    wait "$1"
}

words=("apple" "cheese" "cherry" "grape" "water" "melon")

get_random_word() {
    echo ${words[$RANDOM % ${#words[@]}]}
}

echo "TEST 1"

current_word=$(get_random_word)

timeout=10

# calls countdown function
# runs the function in the background and allows future lines to continue, child=$! is the process ID of the last background command
countdown "Countdown %s: $current_word: " "$timeout" & child=$!

echo "TEST 2"

if ! read -r -t "$timeout" readUserInput; then
    echo "TEST 3"
    echo "readUserInput=$readUserInput"

    countdown_end "$child"
    echo # the line echoed after the entire thing ends
    exit
fi

countdown_end = "$child"
echo "You inputted: $readUserInput"
