#!/bin/zsh

generate_random_word() {
  local words=("apple" "banana" "cherry" "date" "elder" "fig" "grape" "honey")
  local random_index=$(( ( $(od -An -N2 -i /dev/urandom) % (${#words[@]}) ) + 1 ))
  echo "$random_index"
  echo ${words[$random_index]}
}

generate_word_list() {
  local word_list=()
  for i in {1..20}; do
    word_list+=("$(generate_random_word)")
  done
  echo "${word_list[@]}"
}

word_list=($(generate_word_list))

echo "${word_list[@]}"