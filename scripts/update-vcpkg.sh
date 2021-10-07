#!/bin/bash

### Use this to update vcpkg
### This script will force an update of vcpkg everytime it is run and update the azure pipeline to ensure the app is
### built with the correct version of vcpkg

version=1.0.1-for-${PROJECT_NAME}
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
  -r | --remove-after-install )
    shift; rmAfterInstall=$1
    ;;
  -t | --triplet )
    shift; tripletOverride=$1
    ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi


# git fetch in extern/vcpkg
cd extern/vcpkg
git fetch && git pull --ff

# delete existing ./vcpkg file
rm -rf ./vcpkg

# call bootstrap-vcpkg.sh
cd ../..
if [ -z "$tripletOverride" ]; then
./scripts/bootstrap-vcpkg.sh
else
./scripts/bootstrap-vcpkg.sh --triplet $tripletOverride
fi

# run vcpkg update --no-dry-run
./extern/vcpkg/vcpkg upgrade --no-dry-run

./extern/vcpkg/vcpkg remove --outdated

if [[ -f "./azure-pipelines.yml" ]]; then
  # update the azure-pipelines.yml file, which includes the commit id of the vcpkg submodule
  vcpkgCommitId=`git ls-tree --full-tree -r HEAD extern/vcpkg | awk '{print $3}'`
  sed -i "s/VCPKG_COMMIT_ID: [a-f0-9]\{40\}/VCPKG_COMMIT_ID: $vcpkgCommitId/g" azure-pipelines.yml
fi
