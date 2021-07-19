#!/usr/bin/env zsh
#==============================================================================
#title   :gen_devtools_readme.zsh
#version :0.0.0
#desc    :Generates the README for the devtools brew tap repo
#usage   :Set $ROOT_PROJECT_PATH to the root path of the devtools repo
#exit    :0=success, 1=input error 2=execution error
#auth    :Tate Hanawalt(tate@tatehanawalt.com)
#date    :1621396284
#==============================================================================
# This script needs a loooooooot of work.....
#==============================================================================

# Check if this script was called in a git repository
ROOT_PROJECT_PATH=$(git rev-parse --show-toplevel)
if [ -z "$ROOT_PROJECT_PATH" ]; then
  printf "ERROR - devtools gen_tap_readme.zsh got nothing from git rev-parse --show-toplevel\n"
  return 1
fi

# Get the name of the repository if the above step succeeded
REPO_NAME=$(basename "$ROOT_PROJECT_PATH")
printf "REPO_NAME=%s\n" "$REPO_NAME"
if [[ "$REPO_NAME" != "homebrew-devtools" ]]; then
  printf "ERROR - devtools gen_tap_readme.zsh repo name is not the homebrew-devtools repo\n"
  return 1
fi

# Check that the brew formulas are where we expect them (<repo>/Formulas/*)
FORMULA_DIR="$ROOT_PROJECT_PATH/Formula"
if [ ! -d "$FORMULA_DIR" ]; then
  printf "ERROR - \$FORMULA_DIR path is not a directory at $FORMULA_DIR\n"
  exit 1
fi






exit 0

# The full set of formulas
FORMULAS=( ${(@f)"$(find $FORMULA_DIR -type f -maxdepth 1 | grep '.*\.rb$')"} )

# The path of the repositor README.md file
README_FILE="$ROOT_PROJECT_PATH/README.md"

#==============================================================================
# DOCUMENTATION GENERATION FOLLOWS:
#==============================================================================

# printf "README_FILE: ${README_FILE}\n\n"

exit 0

# printf "<br>\n\n" > "$README_FILE"
# printf "" > $README_FILE # Initialize the blank readme doc

#==============================================================================
# Tools available in the project
#==============================================================================

# printf "## <div align=\"center\">Tools</div><br><br>\n" >> "$README_FILE"
# printf "\n\n" >> "$README_FILE"
# for formula in $FORMULAS; do
#   FORMULA_NAME=${formula:t:r}
#   CLASS_NAME=${(C)FORMULA_NAME}
#   LANG=${"${FORMULA_NAME#"demo"}":l}
#   FILE_CLASS_NAME=$(cat $formula | grep "^class.*" | awk -F ' ' '{print $2}')
#   if [[ "$FILE_CLASS_NAME" != "$CLASS_NAME" ]]; then
#     printf "x file class $FILE_CLASS_NAME != $CLASS_NAME\n"
#     return 2
#   fi
#   printf "##### $CLASS_NAME:\n\n" >> "$README_FILE"
#   printf "Description: %s" "Tool details on the way...<br>" >> "$README_FILE"
#   printf "Usage: %s" "Usage cominig soon...<br>" >> "$README_FILE"
#   printf "Install Stable: \`brew intstall %s\`<br>" "$FORMULA_NAME" >> "$README_FILE"
#   printf "Written In: \`%s\`<br>" "$LANG" >> "$README_FILE"
#   printf "\n" >> "$README_FILE"
# done

#==============================================================================
# CONTRIBUTING
#==============================================================================

# printf "<br>\n\n" >> "$README_FILE"
# printf "## <div align=\"center\">Contributing</div><br><br>\n" >> "$README_FILE"
# printf "<br>\n\n" >> "$README_FILE"

#==============================================================================
# CONTRIBUTORS
#==============================================================================

# contributors=()
# contributors+=(contributor1)
# contributors+=(contributor2)
# contributors+=('this is coming soooon....')
# contributors+=('hopefully...')
# printf "<br>\n\n" >> "$README_FILE"
# printf "## <div align=\"center\">Contributors</div><br>\n\n" >> "$README_FILE"
# printf "- %s\n" $contributors >> "$README_FILE"
# printf "\nThis readme is genarted by the zsh shell script in this taps `bin` directory"
