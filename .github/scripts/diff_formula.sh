#!/bin/sh

echo "\nDIFF FORMULA:\n"

DIFF_FILES=$(echo $DIFF_FILES | tr ',' '\n')
echo "$DIFF_FILES\n"

formulas=""
for file in $DIFF_FILES; do
  printf "%s%s\n" "- " "$file"
  # Match formula files:
  # if [[ "$file" =~ ^Formula/.*.rb$ ]]; then
  #   formula=$(echo "$file" | sed 's/^Formula\///' | sed 's/.rb$//')
  #   echo "formula: $formula"
  #   formulas="$formulas$formula\n"
  # fi

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

echo "::set-output name=DIFF_FORMULA::$DIFF_FORMULA"
