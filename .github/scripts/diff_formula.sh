#!/bin/sh

echo "\nDIFF FORMULA:\n"

DIFF_FILES=$(echo $DIFF_FILES | tr ',' ' ')
echo "$DIFF_FILES\n"

for file in $DIFF_FILES; do
  printf "%s%s\n" "- " "$file"
done
