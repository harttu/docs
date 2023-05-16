#!/bin/bash

# Transfer big files with swift 
# Use dd to trasfer them in 1 Gb chunks
# in the server side, use cat $FILE_PART* > output
# to remake the file

#set -x
readonly FILE="/mnt/.../big_file"
readonly FILE_PART=${FILE##*/}

local OS_AUTH_URL="https://url.com:5001/v3"
local OS_AUTH_VERSION=3
local OS_PROJECT_NAME="project_123"
local OS_PROJECT_DOMAIN_NAME="default"
local OS_USERNAME="username"

readonly CONTAINER="CONT"

echo "Enter password on switf-server:"
read -s OS_PASSWORD

echo "File to be transfered is "
echo $FILE
# Function f
function_f() {
  echo "Processing $1"

  # Get directory name
  local dir="${1%/*}"
  #echo "Directory: $dir"

  # Get base file name
  local file="${1##*/}"
  #echo "File: $file"
  
  swift upload $CONTAINER $file
}

# File to split
#file="largefile"

# Size of each chunk in bytes, that is 1G
chunk_size=$((1024*1024*1024))

# Get the size of the file in bytes
file_size=$(stat -c%s "$FILE")

# Calculate the number of chunks, rounding up
num_chunks=$((($file_size+$chunk_size-1)/$chunk_size))
num_chunks_length=${#num_chunks}

# Loop over the chunks
for ((i=0; i<$num_chunks; i++)); do
  # Create the chunk

  padded_i=$(printf "%0${num_chunks_length}d" $i)
  chunk_file="$HOME/${FILE_PART}_part_${padded_i}"

  #echo "dd if=${file} of=$chunk_file bs=${chunk_size} count=1 skip=${i}"
  dd if=$FILE of=$chunk_file bs=$chunk_size count=1 skip=$i

  # Call function f on the chunk
  function_f "$chunk_file"

  # Delete the chunk
  rm "$chunk_file"
done
