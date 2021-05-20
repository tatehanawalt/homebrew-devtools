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

# The full set of formulas
FORMULAS=( ${(@f)"$(find $FORMULA_DIR -type f -maxdepth 1 | grep '.*\.rb$')"} )

# The path of the repositor README.md file
README_FILE="$ROOT_PROJECT_PATH/README.md"

#==============================================================================
# DOCUMENTATION GENERATION FOLLOWS:
#==============================================================================

printf "README_FILE: ${README_FILE}\n"

exit 0
# printf "<br>\n\n" > "$README_FILE"
printf "" > $README_FILE # Initialize the blank readme doc

#==============================================================================
# Title
#==============================================================================

printf "# <div align=\"center\">TATE HANAWALT DEVTOOLS</div><br>\n\n" >> "$README_FILE" ""
printf "## <div align=\"center\">Tools and Projects available through [BREW](https://brew.sh/)</div><br>\n\n" >> "$README_FILE"
printf "<br>\n\n" >> "$README_FILE"
printf ":x: Note:\n\n" >> "$README_FILE"
printf "Everything is currently in development. Nothing is actually stable right now. Even if it appears stable from README content below...<br>\n\n<br>\n\n" >> "$README_FILE"

#==============================================================================
# Install Instructions
#==============================================================================

printf "## <div align=\"center\">Installing</div>\n\n" >> "$README_FILE"
printf "#### 1. Tap the repo:\n\`\`\`shell\nbrew tap tatehanawalt/devtools\n\`\`\`\n" >> "$README_FILE"
printf "<br>\n\n" >> "$README_FILE"
printf "#### 2. Install any tools using either the **STABLE** or **HEAD** methods outlined below.\n\n" >> "$README_FILE"

printf "##### STABLE:<br>\n" >> "$README_FILE"
printf "Install stable distribution with the standard brew install command:\n\`\`\`shell\nbrew install <package_name>\n\`\`\`\n" >> "$README_FILE"

printf "##### HEAD:<br>\n" >> "$README_FILE"
printf "Head deploys the latest code directly from the projects source. You will get the latest elements of the tools but the tools may not always work to the standards offered from the stable installatioin method\n\n" >> "$README_FILE"
printf "Install tools using the **head** method by adding the \`--HEAD\` flag in the install command just before the \`<package_name>\`. For example:\n\n\`\`\`shell\nbrew install --HEAD <package_name>\n\`\`\`\n\n<br>\n\n" >> "$README_FILE"

#==============================================================================
# Tools available in the project
#==============================================================================

printf "## <div align=\"center\">Tools</div><br><br>\n" >> "$README_FILE"
printf "\n\n" >> "$README_FILE"
for formula in $FORMULAS; do
  FORMULA_NAME=${formula:t:r}
  CLASS_NAME=${(C)FORMULA_NAME}
  LANG=${"${FORMULA_NAME#"demo"}":l}
  FILE_CLASS_NAME=$(cat $formula | grep "^class.*" | awk -F ' ' '{print $2}')
  if [[ "$FILE_CLASS_NAME" != "$CLASS_NAME" ]]; then
    printf "x file class $FILE_CLASS_NAME != $CLASS_NAME\n"
    return 2
  fi
  printf "##### $CLASS_NAME:\n\n" >> "$README_FILE"
  printf "Description: %s" "Tool details on the way...<br>" >> "$README_FILE"
  printf "Usage: %s" "Usage cominig soon...<br>" >> "$README_FILE"
  printf "Install Stable: \`brew intstall %s\`<br>" "$FORMULA_NAME" >> "$README_FILE"
  printf "Written In: \`%s\`<br>" "$LANG" >> "$README_FILE"
  printf "\n" >> "$README_FILE"
done

#==============================================================================
# CONTRIBUTING
#==============================================================================

printf "<br>\n\n" >> "$README_FILE"
printf "## <div align=\"center\">Contributing</div><br><br>\n" >> "$README_FILE"
printf "<br>\n\n" >> "$README_FILE"

#==============================================================================
# CONTRIBUTORS
#==============================================================================

contributors=()
contributors+=(contributor1)
contributors+=(contributor2)
contributors+=('this is coming soooon....')
contributors+=('hopefully...')

printf "<br>\n\n" >> "$README_FILE"
printf "## <div align=\"center\">Contributors</div><br>\n\n" >> "$README_FILE"
printf "- %s\n" $contributors >> "$README_FILE"
printf "\nThis readme is genarted by the zsh shell script in this taps `bin` directory"
