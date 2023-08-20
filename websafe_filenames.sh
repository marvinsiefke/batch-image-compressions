#!/bin/bash

dir=""

# Add options for the directory input
while getopts ":d:" opt; do
	case $opt in
		d)
			dir=$OPTARG
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

# Prompt the user for directory input if not passed as a parameter
if [[ -z "$dir" ]]; then
	read -e -p "Please enter the directory: " dir
fi

dir="${dir%/}"  # Removes a trailing slash if present

# Check if the directory exists
if [ ! -d "$dir" ]; then
	echo "Error: '$dir' is not a directory."
	exit 1
fi

echo "Scanning directory: $dir..."

# Loop through all files in the directory
find "$dir" -type f | while IFS= read -r file; do
	# Basename for file path
	base=$(basename -- "$file")

	# Convert filename to web-safe format and turn everything to lowercase
	newname=$(echo "$base" | tr '[:upper:]' '[:lower:]' | tr ' ' '_' | tr -c '[:alnum:]_.' '_')

	# Rename if necessary
	if [ "$base" != "$newname" ]; then
		echo "Renaming '$base' to '$newname'..."
		mv -i -- "$file" "$(dirname -- "$file")/$newname"
	else
		echo "'$base' does not need renaming."
	fi
done

echo "Renaming process completed!"
