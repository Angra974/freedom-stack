#!/bin/bash

# =============================================
# CONFIGURATION VARIABLES - Edit these as needed
# =============================================

# Base paths
ROOT_DIR=$(pwd)
DOCS_BASE_PATH="src/content/docs"

# Root folders to process
ADDITIONAL_ROOT_FOLDERS=(
    "$ROOT_DIR/src"
    "$ROOT_DIR/scripts"
    "$ROOT_DIR/db"
)

# Docs subfolders to process (empty array = no docs processing)
DOCS_SUBFOLDERS=("fr")

# Files to exclude
exclude_files=(
    "pnpm-lock.yaml"
    "$output_file"
    "$output_docs_file"
)

# Directories to exclude
exclude_dirs=(
    "node_modules"
    ".git"
    "dist"
    "build"
    "public"
)

# File extensions to exclude
exclude_extensions=(
    ".DS_Store"
    ".png"
    ".jpg"
    ".jpeg"
    ".svg"
    ".gif"
    ".webp"
    ".mp4"
    ".mp3"
    ".avi"
    ".mov"
    ".mkv"
)

# Output files
output_file="astro-chatgpt-ai-template.txt"
output_docs_file="output_docs.txt"

# =============================================
# Script logic below - No need to modify unless changing functionality
# =============================================

# Clean output files at start
rm -f "$output_file"
rm -f "$output_docs_file"

# Global arrays to store subdirectories and files
FOLDER_NAMES=()
FOLDER_SUBDIRS=()
FOLDER_FILES=()

# Function to check if a path should be excluded
should_exclude() {
    local path="$1"
    local base_name=$(basename "$path")
    local ext="${base_name##*.}"

    # Check excluded directories
    for exclude_dir in "${exclude_dirs[@]}"; do
        if [[ "$path" == *"/$exclude_dir"* ]]; then
            return 0
        fi
    done

    # Check excluded files
    for exclude in "${exclude_files[@]}"; do
        if [[ "$base_name" == "$exclude" ]]; then
            return 0
        fi
    done

    # Check excluded extensions
    for exclude in "${exclude_extensions[@]}"; do
        if [[ ".$ext" == "$exclude" ]]; then
            return 0
        fi
    done

    return 1
}

# Function to check if a directory is allowed
is_allowed_directory() {
    local dir="$1"

    # Block src/content/docs path when not in specified DOCS_SUBFOLDERS
    if [[ "$dir" == *"/$DOCS_BASE_PATH/"* ]]; then
        for subdir in "${DOCS_SUBFOLDERS[@]}"; do
            if [[ "$dir" == *"/$DOCS_BASE_PATH/$subdir"* ]]; then
                return 0
            fi
        done
        return 1
    fi

    # Check if directory is in ADDITIONAL_ROOT_FOLDERS
    for allowed_dir in "${ADDITIONAL_ROOT_FOLDERS[@]}"; do
        if [[ "$dir" == "$allowed_dir"* ]]; then
            return 0
        fi
    done

    return 1
}

# Function to recursively list subdirectories and files
recursive_list() {
    local dir="$1"
    local base_dir="${2:-$dir}"

    for item in "$dir"/*; do
        if [ -d "$item" ]; then
            if ! should_exclude "$item" && is_allowed_directory "$item"; then
                FOLDER_SUBDIRS+=("$item")
                recursive_list "$item" "$base_dir"
            fi
        elif [ -f "$item" ]; then
            if ! should_exclude "$item" && is_allowed_directory "$(dirname "$item")"; then
                FOLDER_FILES+=("$item")
            fi
        fi
    done
}

# Function to add the content of a file to the appropriate output file
add_file_content() {
    local file_path="$1"
    local target_file="$output_file"
    local relative_path=".${file_path#$ROOT_DIR}"

    if [[ "$file_path" == *"/$DOCS_BASE_PATH/"* ]]; then
        target_file="$output_docs_file"
    fi

    echo "# Start of $relative_path" >> "$target_file"
    if [[ "$file_path" == *.json ]]; then
        python3 -c "import json; import sys; print(json.dumps(json.load(sys.stdin), indent=4, ensure_ascii=False))" < "$file_path" >> "$target_file"
    else
        cat "$file_path" >> "$target_file"
    fi
    echo "# End of $relative_path" >> "$target_file"
    echo "" >> "$target_file"
}

# Function to add files in the include_dirs while excluding specific file types
add_files_in_dirs() {
    for dir_name in "${ADDITIONAL_ROOT_FOLDERS[@]}"; do
        if [ -d "$dir_name" ]; then
            find "$dir_name" -type f | while read -r file_name; do
                if ! should_exclude "$file_name" && is_allowed_directory "$(dirname "$file_name")"; then
                    add_file_content "$file_name"
                fi
            done
        fi
    done
}

# Main script logic

# List all subdirectories and files in the additional root folders
for folder in "${ADDITIONAL_ROOT_FOLDERS[@]}"; do
    if [ -d "$folder" ]; then
        FOLDER_NAMES+=("$folder")
        recursive_list "$folder" "$folder"
    fi
done

# List files in the root directory (only direct files, not in subdirectories)
for file in "$ROOT_DIR"/*; do
    if [ -f "$file" ] && ! should_exclude "$file"; then
        FOLDER_FILES+=("$file")
        add_file_content "$file"
    fi
done

# Add files in the include_dirs to the output file
add_files_in_dirs

# Process and display results for each folder
for folder in "${FOLDER_NAMES[@]}"; do
    echo "Subdirectories in $folder:"
    for subdir in "${FOLDER_SUBDIRS[@]}"; do
        [[ $subdir == $folder/* ]] && echo "$subdir"
    done

    echo "Files in $folder:"
    for file in "${FOLDER_FILES[@]}"; do
        [[ $file == $folder/* ]] && echo "$file"
    done
done
