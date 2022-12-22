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

files=($(find "$dir_path" -maxdepth 1 -mindepth 1 -type f -name "$mask"))
files_size="${#files[@]}"
pid_array=()
if [ "$files_size" -le "$core_number" ]; then
  for file in $files; do
    $command $file &
    pid_array+=($!)
  done

  for pid in $pid_array; do
    wait $pid
  done
else
  declare -i file_index=0
  while [ "$file_index" -ne "$files_size" ]; do
    if [ "${#pid_array[@]}" -ne "$core_number" ]; then
      pid_array+=($!)
      $command ${files[$file_index]} &
      file_index+=1
      wait -n &
      unset 'pid_array[-1]'
    fi
  done
fi