#!/bin/bash

usage="Usage: $(basename $0) [--path dirpath] [--mask mask] [--number number] command"
if [ -z "$1" ]; then
   echo "$usage"
   exit 1
fi
dir_path=$(pwd)
mask="*"
core_number=$(grep processor -c /proc/cpuinfo)
command="${!#}"
total_arguments="$#"
declare -i valid_arguments=1

while [ -n "$1" ]
do
    case "$1" in
      --path)
          dir_path="$2"
          valid_arguments+=2
          ;;
      --mask)
          mask="$2"
          valid_arguments+=2
          ;;
      --number)
          core_number="$2"
          valid_arguments+=2
          ;;
      -*|--*)
        echo "$usage"
        exit 1;;
    esac
    shift
done
if [ $valid_arguments -ne $total_arguments ]; then
  echo "$usage"
  exit 1
fi

files=$(find "$dir_path" -maxdepth 1 -mindepth 1 -type f -name "$mask")
files_size="${#files[@]}"
if [ "$files_size" -lt "$number_of_cores" ]; then
  for (( i = 0; i < files_size; i++ )); do
    echo "$command ${files[i]} &" | bash >> /dev/null
  done
else
  command_array=()
  command_iterator=0
  for (( i = 0; i < "$files_size"; i++ )); do
    if [ -z "${command_array[$command_iterator]}" ]; then
      command_array[$command_iterator]="$command ${files[i]} "
    else
      command_array[$command_iterator]="${command_array[$command_iterator]} && $command ${files[i]} "
    fi
    if [ $command_iterator -eq $((number_of_cores - 1)) ]; then
      command_iterator=0
    else
      command_iterator=$((command_iterator+=1))
    fi
  done
  for (( i = 0; i < "${#command_array[@]}"; i++ )); do
    echo "${command_array[$i]} &" | bash >> /dev/null
  done
fi