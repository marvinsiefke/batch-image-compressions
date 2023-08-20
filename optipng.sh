#!/bin/bash

# Check if optipng is installed
if ! command -v optipng &> /dev/null; then
	echo "optipng is not installed. Please install it first."
	exit 1
fi

OPTIMIZATION_LEVEL=7
INPUT_DIR=""

# Add options for optimization level and directory
while getopts ":l:d:" opt; do
	case $opt in
		l)
			if [[ $OPTARG -ge 1 && $OPTARG -le 7 ]]; then
				OPTIMIZATION_LEVEL=$OPTARG
			else
				echo "Please specify a level between 1 and 7."
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
OUTPUT_DIR="$HOME/output/$(date '+%Y-%m-%d_%H-%M-%S')_optipng"

# Create the output directory
mkdir -p "$OUTPUT_DIR"

# Get a list of all files to process
files=($INPUT_DIR/*.png $INPUT_DIR/*.PNG)
total_files=${#files[@]}
current_file=0

# Go through all PNG files in the input directory
for file in "${files[@]}"; do
	# Check if the file exists
	if [[ -f "$file" ]]; then
		current_file=$((current_file + 1))
		filename=$(basename "$file")
		echo "Processing image $current_file of $total_files: $filename ..."

		# Use optipng to compress the image and save in the output directory
		if optipng -o $OPTIMIZATION_LEVEL -out "$OUTPUT_DIR/$filename" "$file"; then
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