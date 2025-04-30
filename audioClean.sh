#!/bin/bash

in="$1"
out="$2"
volume="${3:-10}"
if [ -z "$in" ]; then
    echo "Usage: $0 <input_file> <output_file> <volume>"
    exit 1
fi
# Check if the input file exists
if [ ! -f "$in" ]; then
    echo "Input file not found!"
    exit 1
fi
# Check if the output file already exists
if [ -f "$out" ]; then
    echo "Output file already exists! Overwrite? (y/n)"
    read -r answer
    if [[ ! "$answer" =~ ^[Yy]$ ]]; then
        echo "Exiting without changes."

        exit 0
    fi
fi

# clean $out by trimming it from space and dots
out=$(echo "$out" | tr -d '[:space:]' | tr -d '.')

# if out is not set it to <in>_out.extension
if [ -z "$out" ]; then
    out="${in%.*}_out.${in##*.}"
fi

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg could not be found. Please install it first."
    exit 1
fi

echo "Processing file: $in"
echo "Output file: $out"
echo "Volume: $volume"
exit

ffmpeg -i "$in" -af "highpass=f=300,asendcmd=0.0 afftdn sn start,asendcmd=1.5 afftdn sn stop,afftdn=nf=-20,dialoguenhance,lowpass=f=3000,volume=$volume" "$out"
