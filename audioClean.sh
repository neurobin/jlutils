#!/bin/bash

in="$1"
out="$2"
volume="${3:-1.10}"
if [ -z "$in" ] || [ -z "$out" ]; then
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
# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    echo "ffmpeg could not be found. Please install it first."
    exit 1
fi

echo "Processing file: $in"
echo "Output file: $out"
echo "Volume: $volume"

ffmpeg -i "$in" -af "highpass=f=300,asendcmd=0.0 afftdn sn start,asendcmd=1.5 afftdn sn stop,afftdn=nf=-20,dialoguenhance,lowpass=f=3000,volume=$volume" "$out"
