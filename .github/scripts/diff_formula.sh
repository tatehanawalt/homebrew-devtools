#!/bin/sh

# Takes a list if files (relative paths) of a git repo and returns the list of
# formula names that are found in the set of file paths

DIFF_FILES=$(echo $DIFF_FILES | tr ',' '\n')
echo "$DIFF_FILES\n"
formulas=""
for file in $DIFF_FILES; do
  printf "%s%s\n" "- " "$file"
  # Match formula files:
  if (echo "$file" | grep -Eq ^Formula/.*.rb$); then
    echo "matched"
    formula=$(echo "$file" | sed 's/^Formula\///' | sed 's/.rb$//')
    echo "formula: $formula"
    formulas="$formulas$formula\n"
  fi
done
formulas=$(echo "$formulas")
echo "formulas:"
echo "$formulas"
DIFF_FORMULA="$(printf "$formulas" | tr '\n' ',')"
echo "DIFF_FORMULA=$DIFF_FORMULA"
echo "::set-output name=DIFF_FORMULA::$DIFF_FORMULA"
