#!/bin/bash

# Check if guetzli is installed
if ! command -v guetzli &> /dev/null; then
	echo "guetzli is not installed. Please install it first."
	exit 1
fi

QUALITY=90
INPUT_DIR=""

# Add options for quality setting and directory
while getopts ":q:d:" opt; do
	case $opt in
		q)
			if [[ $OPTARG -ge 60 && $OPTARG -le 100 ]]; then
				QUALITY=$OPTARG
			else
				echo "Please specify a quality between 60 and 100."
				exit 1
			fi
			;;
		d)
			INPUT_DIR=$OPTARG
			;;
		\?)
			echo "Invalid option: -$OPTARG"
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument."
			exit 1
			;;
	esac
done

# If directory was not passed as parameter, ask the user
if [[ -z "$INPUT_DIR" ]]; then
	read -e -p "Please enter the input directory: " INPUT_DIR
fi

# Check if INPUT_DIR exists
if [[ ! -d "$INPUT_DIR" ]]; then
	echo "The specified directory '$INPUT_DIR' does not exist."
	exit 1
fi

# Measure folder size of INPUT_DIR
INPUT_DIR="${INPUT_DIR%/}" 
input_size=$(du -sh "$INPUT_DIR" | cut -f1)

# Set the output directory: A subfolder of $HOME/output with current date and time
OUTPUT_DIR="$HOME/output/$(date '+%Y-%m-%d_%H-%M-%S')_guetzli"

# Create the output directory
mkdir -p "$OUTPUT_DIR"

# Get a list of all files to process
files=($INPUT_DIR/*.jpg $INPUT_DIR/*.jpeg $INPUT_DIR/*.JPG $INPUT_DIR/*.JPEG)
total_files=${#files[@]}
current_file=0

# Go through all JPEG files in the input directory
for file in "${files[@]}"; do
	# Check if the file exists
	if [[ -f "$file" ]]; then
		current_file=$((current_file + 1))
		filename=$(basename "$file")
		echo "Processing image $current_file of $total_files: $filename ..."

		# Use guetzli to compress the image and save in the output directory
		if guetzli --quality $QUALITY "$file" "$OUTPUT_DIR/$filename"; then
			echo "Compression of $filename successful."
			rm "$file"
		else
			echo "Error compressing $filename."
			mv "$file" "$OUTPUT_DIR/$filename"
		fi
	fi
done

echo "All images have been processed."

# Measure folder size of OUTPUT_DIR
output_size=$(du -sh "$OUTPUT_DIR" | cut -f1)

echo "Total size before conversion: $input_size"
echo "Total size after conversion: $output_size"