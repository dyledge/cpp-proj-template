#!/bin/bash

### Use this script to remove all dependencies indicated in vcpkg-dependencies
### from the vcpkg submodule

version=1.0.1-for-${CPP_PROJ_PROJECT_NAME}
tripletOverride=

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  -V | --version )
    echo $version
    exit
    ;;
  -h | --help )
    echo "$0:"
    echo "-h [--help]         display this message"
    echo "-V [--version]      display version information"
    echo "-t [--triplet] ARG  overrides the triplet default [default: $tripletOverride]"
    exit
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

# remove all vcpkg dependencies
if [[ -e "$vcpkg_exe" ]]; then
  # create the parameter line passed to vcpkg remove
  for i in "${vcpkg_dependencies[@]}"; do
    vcpkg_install_line="$vcpkg_install_line $i"
  done
  echo "$vcpkg_exe remove$vcpkg_install_line"
  $vcpkg_exe --overlay-triplets=scripts/triplets remove$vcpkg_install_line
else
  echo "nothing to do: $vcpkg_exe does not exist"
fi
