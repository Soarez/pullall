#!/bin/bash

contents=`ls`
module_names=()
module_folders=()
npm_root=$(npm root -g)

do_pull=1
do_npm_install=1
do_npm_link=1

while getopts "il" opt $*; do
  case $opt in
    i) do_pull=0 ;;
    l) do_pull=0 do_npm_install=0 ;;
    \?) echo "Invalid option: -$OPTARG" >&2; exit ;;
  esac
done

# On the first run, detect npm modules under version control, update them,
# and npm install and link them.
for folder in $contents
do
  :

  # skip non directories
  if ! [ -d $folder ]; then
    continue
  fi

  cd $folder

  # skip non git repos
  if ! [ -d .git ]; then
    cd ..
    continue
  fi

  # get the module name for node modules
  hint=""
  if [ -f package.json ]; then
    module_name=`grep name package.json | cut -d '"' -f 4`
    module_names+=($module_name)
    module_folders+=($folder)
    hint=" ($module_name)"
  fi

  branch_name="$(git symbolic-ref HEAD 2>/dev/null)" ||
  branch_name="(unnamed branch)"     # detached HEAD
  branch_name=${branch_name##refs/heads/}

  branch_warning=""
  dirty_warning=""

  if [ ! "$branch_name" =  'master' ]; then
    branch_warning="\x1B[1;33m[$branch_name]\x1B[0m"
  fi

  if [[ `git status --porcelain` ]]; then
    dirty_warning="\x1B[1;31mdirty!\x1B[0m"
  fi

  echo
  echo -e "\x1B[1;36m# $folder$hint $branch_warning $dirty_warning\x1B[0m"

  if (( do_pull )); then
    git fetch

    local_revision="$(git rev-parse HEAD)"
    remote_revision="$(git rev-parse origin/$branch_name)"
    if [ "$local_revision" = "$remote_revision" ]; then
      echo -e "\x1B[1;32mAlready up to date\x1B[0m"
      cd ..
      continue
    fi

    echo -e "\x1B[1;34mUpdating repo\x1B[0m"
    git merge origin/$branch_name
  fi

  if (( do_npm_install )); then
    echo -e "\x1B[1;34mUpdating dependencies\x1B[0m"
    npm install --loglevel error
    npm prune --loglevel error
  fi

  if (( do_npm_link )); then
    echo -e "\x1B[1;34mLinking globally\x1B[0m"
    npm link --loglevel error 1>/dev/null
  fi

  cd ..
done

# On the second run, npm link to dependencies
echo
if (( do_npm_link )); then
  for module_folder in ${module_folders[@]}
  do
    :
    cd $module_folder

    module_name=`grep name package.json | cut -d '"' -f 4`
    dependency_names=`ls node_modules`

    for dependency_name in ${dependency_names[@]}
    do
      :
      if ! [[ " ${module_names[@]} " =~ " ${dependency_name} " ]]; then
        continue;
      fi

      dependency_folder=$(basename $(readlink $npm_root/$dependency_name))
      echo -e "\x1B[1;34mLinking \x1B[1;36m#$module_folder\x1B[0m to \x1B[1;36m#$dependency_folder\x1B[0m \x1B[0m"
      npm link $dependency_name --quiet 1>/dev/null
    done

    cd ..
  done
fi
