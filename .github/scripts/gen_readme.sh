#!/bin/bash

my_path=$0
. "$(dirname $my_path)/helpers.sh"

# repo_root=$(git_repo_root)

printf -v readme_path "%s/README.md" $(git_repo_root)
printf "readme_path: %s\n" ${readme_path}


title="TATE HANAWALT DEVTOOLS"
desc="[Tools](#Tools) and Projects available through [BREW](https://brew.sh/)"

printf -v formulas_readme "
<div align=\"center\">

  # ${title}

  <br>

  ${desc}

</div>

***Everything is currently in development.***

Nothing is actually stable right now. Even if indicated by the following documentation.

[![flush-all-completed-workflow-runs Actions Status](https://github.com/tatehanawalt/homebrew-devtools/workflows/flush-all-completed-workflow-runs/badge.svg)](https://github.com/tatehanawalt/homebrew-devtools/actions)

## Installing ##

#### 1. Tap the repo: ####

\`\`\`shell
brew tap tatehanawalt/devtools
\`\`\`

#### 2. Install any tools using either the **STABLE** or **HEAD** methods outlined below. ####
<details>

  <br>

  <summary>STABLE Install</summary>

  Install stable distribution with the standard brew install command:

  \`\`\`shell
  brew install <package_name>
  \`\`\`

  <br>

</details>

<details>

  <br>

  <summary>HEAD Install</summary>

  Head deploys the latest code directly from the projects source. You will get the latest elements of the tools but the tools may not always work to the standards offered from the stable installatioin method

  Install tools using the **head** method by adding the \`--HEAD\` flag in the install command just before the \`<package_name>\`. For example:

  \`\`\`shell
  brew install --HEAD <package_name>
  \`\`\`

  <br>

</details>

## Tools ##
"



for name in $(formula_names);
do
  desc="$(formula_description $name)"
  tool_desc="<details>
  <br>

  <summary>${name}</summary>

  Description: ${desc}

  Usage: Usage cominig soon...

  Install Stable:
  \`\`\`shell
  brew intstall ${name}
  \`\`\`
  <br>
</details>"

  printf -v formulas_readme "%s\n%s\n\n" "$formulas_readme" "$tool_desc"
done

printf "%s\n" "$formulas_readme" > $readme_path
