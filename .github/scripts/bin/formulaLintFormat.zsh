#!/usr/bin/env zsh
#==============================================================================
#title   :formulaLintFormat.zsh
#version :0.0.0
#desc    :Lint and format the Formula ruby files using rubocop
#usage   :See below
#exit    :0=success, 1=input error 2=execution error
#auth    :DH, TH
#date    :1621396284
#==============================================================================
# USAGE / README:
# This script runs ruby linting / formatting using rubocop https://rubocop.org/
#
# This script will check for rubocop on the environment every time.
# If you need to install rubocop:
#
# OSX rubocop Install:
#
# run: `gem install rubocop`
#
# NOTE: If the gem install command failse with  ...'You don't have write permissions*' try
# running `export GEM_HOME="$HOME/.gem"`. If this solves the problem add it to your .zshrc file
#
# If you ran into the issue noted above:
# 1. add the `export GEM_HOME="$HOME/.gem"` to the end of your .zshrc file
# 2. Somewhere in your .zshrc file add `~/.gem/bin` to yor PATH with
#    `export PATH=$GEM_HOME/bin:$PATH`
#==============================================================================

#------------------------------------------------------------------------------
# 1. Verify the script was executed from in the homebrew-devtools repository
#------------------------------------------------------------------------------
ROOT_PROJECT_PATH=$(git rev-parse --show-toplevel)
if [ -z "$ROOT_PROJECT_PATH" ]; then
  printf "ERROR - devtools gen_tap_readme.zsh got nothing from git rev-parse --show-toplevel\n"
  return 1
fi

REPO_NAME=$(basename "$ROOT_PROJECT_PATH")
printf "REPO_NAME=%s\n" "$REPO_NAME"
if [[ "$REPO_NAME" != "homebrew-devtools" ]]; then
  printf "ERROR - devtools gen_tap_readme.zsh repo name is not the homebrew-devtools repo\n"
  return 1
fi

# Expected Formulas directory
FORMULA_DIR="$ROOT_PROJECT_PATH/Formula"
if [ ! -d "$FORMULA_DIR" ]; then
  printf "ERROR - \$FORMULA_DIR path is not a directory at $FORMULA_DIR\n"
  exit 1
fi
FORMUL_PATHS=( ${(@f)"$(find $FORMULA_DIR -type f -maxdepth 1 | grep '.*\.rb$')"} )

#------------------------------------------------------------------------------
# 2. Check that 'rubocop' (the lint/format utility) is installed / executable
#------------------------------------------------------------------------------
RUBOCOP_PATH=$(which rubocop)
[ -z "$RUBOCOP_PATH" ] && printf "ERROR - rubocop not found in \$PATH\n" && exit 1
[ ! -x "$RUBOCOP_PATH" ] && printf "ERROR - rubocop path is not executable\n" && exit 1

#------------------------------------------------------------------------------
# 3. Log the rubocop and formula paths before actually format/linting
#------------------------------------------------------------------------------
printf "RUBOCOP_PATH=%s\n" "$RUBOCOP_PATH"
printf "FORMUL_PATHS:\n"
printf "- %s\n" $FORMUL_PATHS

#------------------------------------------------------------------------------
# 4. Format and lint the formula files
#------------------------------------------------------------------------------
printf "FORMATTING AND LINTING:\n"
for formula_file_path in $FORMUL_PATHS; do
  rubocop -x "$formula_file_path"
done
