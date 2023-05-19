#!/bin/bash

### Use this to initialize vcpkg as a submodule and build/install dependencies from
###  ci/vcpkg-dependencies

### note: this scripts assumes running in linux, mac or windows using git bash
### OSTYPE is expected to be:
###  - linux-gnu
###  - msys
###  - darwin*

version=1.0.1-for-${CPP_PROJ_PROJECT_NAME}
rmAfterInstall="true"
tripletOverride=

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  -V | --version )
    echo $version
    exit
    ;;
  -h | --help )
    echo "$0:"
    echo "-h [--help]                      display this message"
    echo "-V [--version]                   display version information"
    echo "-r [--remove-after-install] ARG  directs the script to cleanup after the vcpkg install [default: true]"
    echo "-t [--triplet] ARG               overrides the triplet default [default: $tripletOverride]"
    exit
    ;;
  -r | --remove-after-install )
    shift; rmAfterInstall=$1
    ;;
  -t | --triplet )
    shift; tripletOverride=$1
    ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi


# make sure $VCPKG_ROOT is set
if [[ -z "$VCPKG_ROOT" ]]; then
  export VCPKG_ROOT=`pwd`/extern/vcpkg
fi
echo $VCPKG_ROOT

# make sure vcpkg is present in the project
# hack: the following line doesn't work if the path from .gitmodules has a space in it
temp=`git config -f .gitmodules --get-regexp path | awk '{ print $2 }'`
if [[ -z "$temp" ]]; then
  # add vcpkg as a submodule
  git submodule add https://github.com/microsoft/vcpkg.git extern/vcpkg
fi

# go ahead and init the submodule if .vcpkg-root doesn't exist
if [[ ! -e "$VCPKG_ROOT/.vcpkg-root" ]]; then
  git submodule update --init --recursive extern/vcpkg
fi

# pick a triplet based on host os
triplet="x64-linux"
vcpkg_exe="$VCPKG_ROOT/vcpkg"
if [[ "$OSTYPE" == "msys" ]]; then
  triplet="x64-windows-static"
  vcpkg_exe="$VCPKG_ROOT/vcpkg.exe"
elif [[ "$OSTYPE" =~ ^darwin.* ]]; then
  triplet="x64-osx"
fi

# honor the triplet override argument
if [[ ! -z "$tripletOverride" ]]; then
  triplet=$tripletOverride
  echo "using triplet=$triplet"
fi

# create the vcpkg install parameters from the vcpkg-dependencies file
vcpkg_dependencies=(`cat "ci/vcpkg-dependencies" | tr -d '\r'`)
# ^ the tr -d '\r' is needed when git is configured to modify
#   line endings on windows to \r\n on checkout
for i in "${!vcpkg_dependencies[@]}"; do
  # line looks like name|platform or name
  # split into name and platform
  # if platform is empty or matches $OSTYPE, include it, otherwise skip it
  IFS='|'
  read -ra vcpkgItemArray <<< "${vcpkg_dependencies[$i]}"
  IFS=' '
  if [[ ${#vcpkgItemArray[@]} -eq 2 ]]; then
    iter=0
    for pkg in "${vcpkgItemArray[@]}"; do
      if [[ iter -eq 0 ]]; then
        pkgName=$pkg
        iter=1
      else
        platformName=$pkg
      fi
    done
    if [[ "$platformName" == "windows" ]] && [[ "$OSTYPE" == "msys" ]]; then
      vcpkg_dependencies[$i]="$pkgName:$triplet"
    elif [[ "$platformName" == "osx" ]] && [[ "$OSTYPE" =~ ^darwin.* ]]; then
      vcpkg_dependencies[$i]="$pkgName:$triplet"
    elif [[ "$platformName" == "linux" ]] && [[ "$OSTYPE" =~ ^linux.* ]]; then
      vcpkg_dependencies[$i]="$pkgName:$triplet"
    else
      vcpkg_dependencies[$i]=""
    fi
  else
    vcpkg_dependencies[$i]="${vcpkg_dependencies[$i]}:$triplet"
  fi
done

# note: apply vcpkg patches, if needed, e.g:
# Ex: avro-c patch from pending pull request https://github.com/microsoft/vcpkg/pull/10514
# echo "cp -a extern/patch/vcpkg/ports/avro-c/. ${VCPKG_ROOT}/ports/avro-c"
# cp -a extern/patch/vcpkg/ports/avro-c/. ${VCPKG_ROOT}/ports/avro-c

# make sure vcpkg is built
if [[ ! -e "$vcpkg_exe" ]]; then
  ${VCPKG_ROOT}/bootstrap-vcpkg.sh -disableMetrics
fi

# install all vcpkg dependencies
if [[ -e "$vcpkg_exe" ]]; then
  # create the parameter line passed to vcpkg install
  for i in "${vcpkg_dependencies[@]}"; do
    vcpkg_install_line="$vcpkg_install_line $i"
  done
  echo "$vcpkg_exe install$vcpkg_install_line"
  $vcpkg_exe --overlay-triplets=scripts/triplets install$vcpkg_install_line

  if [[ -e "azure-pipelines.yml" ]]; then
    # update the azure-pipelines.yml file with the commit id of the vcpkg submodule
    vcpkgCommitId=`git ls-tree --full-tree -r HEAD extern/vcpkg | awk '{print $3}'`
    sed -i "s/VCPKG_COMMIT_ID: [a-f0-9]\{40\}/VCPKG_COMMIT_ID: $vcpkgCommitId/g" azure-pipelines.yml
  fi

  # clean up temporary files
  if [[ "$rmAfterInstall" == "true" ]]; then
    rm -rf ${VCPKG_ROOT}/packages && rm -rf ${VCPKG_ROOT}/buildtrees && rm -rf ${VCPKG_ROOT}/downloads
  else
    # rm -rf ${VCPKG_ROOT}/downloads
    echo "skipping cleanup"
  fi
else
  echo "$vcpkg_exe does not exist"
  exit 1
fi
