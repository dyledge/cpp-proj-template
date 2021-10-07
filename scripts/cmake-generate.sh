#!/bin/bash

### Use this to clear and generate the cmake cache
### Example for windows:
###   scripts/cmake-generate.sh --use-alt-generator '"Visual Studio 16 2019"' --use-cmake-addtl-args '"-A x64 -T v142"' --sanitizers OFF --static-analysis OFF --export-compile-cmds OFF --use-ccache OFF --coverage OFF

version=1.0.0-for-${PROJECT_NAME}
buildType=RelWithDebInfo
staticAnalysis=ON
sanitizers=ON
memory=OFF
thread=OFF
fuzzing=OFF
coverage=OFF
documentation=OFF
exportCompileCommands=OFF
useCCache=ON
useLTO=OFF
useAltGenerator=
addtlCmakeArgs=

# this may get overridden by the command line param --triplet
triplet="x64-linux"
if [[ "$OSTYPE" == "msys" ]]; then
  triplet="x64-windows-static"
elif [[ "$OSTYPE" =~ ^darwin.* ]]; then
  triplet="x64-osx"
fi

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
  -V | --version )
    echo $version
    exit
    ;;
  -h | --help )
    echo "$0:"
    echo "  -h [--help]                 display this message."
    echo "  -V [--version]              display version information."
    echo "  --build-type ARG            specify the cmake build type [default: $buildType]"
    echo "  --triplet ARG               specify the vcpkg triplet [default: $triplet]"
    echo "  --static-analysis ARG       enable static analysis (clang-tidy, cppcheck, iwyu) [default: $staticAnalysis]"
    echo "  --sanitizers ARG            enable clang sanitizers (address, lead, ub) [default: $sanitizers]"
    echo "  --memory ARG                enable memory sanitizer [default: $memory]"
    echo "  --thread ARG                enable thread sanitizer [default: $thread]"
    echo "  --fuzzing ARG               enable fuzz testing [default: $fuzzing]"
    echo "  --coverage ARG              enable code coverage instrumentation [default: $coverage]"
    echo "  --documentation ARG         create the documentation [default: $documentation]"
    echo "  --export-compile-cmds ARG   have cmake export compile commands [default: $exportCompileCommands]"
    echo "  --use-ccache ARG            enable using ccache [default: $useCCache]"
    echo "  --use-lto ARG               enable link time optimization [default: $useLTO]"
    echo "  --use-alt-generator ARG     use a different cmake generator [default: $useAltGenerator]"
    echo "  --use-cmake-addtl-args ARG  additional arguments to pass to cmake [default: $addtlCmakeArgs]"
    echo "                              ex: --use-cmake-addtl-args '\"-A x64 -T v142\"'"
    exit
    ;;
  --build-type )
    shift; buildType=$1
    ;;
  --triplet )
    shift; triplet=$1
    ;;
  --static-analysis )
    shift; staticAnalysis=$1
    ;;
  --sanitizers )
    shift; sanitizers=$1
    ;;
  --memory )
    shift; memory=$1
    ;;
  --thread )
    shift; thread=$1
    ;;
  --fuzzing )
    shift; fuzzing=$1
    ;;
  --coverage )
    shift; coverage=$1
    ;;
  --documentation )
    shift; documentation=$1
    ;;
  --export-compile-cmds )
    shift; exportCompileCommands=$1
    ;;
  --use-ccache )
    shift; useCCache=$1
    ;;
  --use-lto )
    shift; useLTO=$1
    ;;
  --use-alt-generator )
    shift; useAltGenerator=$1
    ;;
  --use-cmake-addtl-args )
    shift; addtlCmakeArgs=$1
    ;;
esac; shift; done
if [[ "$1" == '--' ]]; then shift; fi

# verify all args are present

if [[ "$memory" == "ON" ]]; then
  # memory mean we can't use the other sanitizers
  sanitizers=OFF
  thread=OFF
fi

if [[ "$thread" == "ON" ]]; then
  # thread mean we can't use the other sanitizers
  sanitizers=OFF
  memory=OFF
fi

if [[ -z "$triplet" ]]; then
    echo "triplet required"
    exit 1
fi

# remove the existing cmake cache
rm -rf ./build

# create the new one

echo "cmake $useAltGenerator $addtlCmakeArgs -S . -B ./build
  -DCMAKE_BUILD_TYPE=$buildType
  -DCMAKE_EXPORT_COMPILE_COMMANDS=$exportCompileCommands
  -DCMAKE_INSTALL_PREFIX=/usr/local
  -DVCPKG_TARGET_TRIPLET=$triplet
  -DENABLE_CACHE=$useCCache
  -DENABLE_IPO=$useLTO
  -DENABLE_BUILD_WITH_TIME_TRACE=OFF
  -DWARNINGS_AS_ERRORS=ON
  -DENABLE_TESTING=ON
  -DENABLE_COVERAGE=$coverage
  -DENABLE_FUZZING=$fuzzing
  -DENABLE_SANITIZER_ADDRESS=$sanitizers
  -DENABLE_SANITIZER_LEAK=$sanitizers
  -DENABLE_SANITIZER_MEMORY=$memory
  -DENABLE_SANITIZER_THREAD=$thread
  -DENABLE_SANITIZER_UNDEFINED_BEHAVIOR=$sanitizers
  -DENABLE_CLANG_TIDY=$staticAnalysis
  -DENABLE_CPPCHECK=OFF
  -DENABLE_INCLUDE_WHAT_YOU_USE=OFF
  -DENABLE_DOCUMENTATION=$documentation
  -DENABLE_SEMVER=ON"

# cmake -GNinja -S . -B ./build \
cmake $useAltGenerator $addtlCmakeArgs -S . -B ./build \
  -DCMAKE_BUILD_TYPE=$buildType \
  -DCMAKE_EXPORT_COMPILE_COMMANDS=$exportCompileCommands \
  -DCMAKE_INSTALL_PREFIX=/usr/local \
  -DVCPKG_TARGET_TRIPLET=$triplet \
  -DENABLE_CACHE=$useCCache \
  -DENABLE_IPO=$useLTO \
  -DENABLE_BUILD_WITH_TIME_TRACE=OFF \
  -DWARNINGS_AS_ERRORS=ON \
  -DENABLE_TESTING=ON \
  -DENABLE_COVERAGE=$coverage \
  -DENABLE_FUZZING=$fuzzing \
  -DENABLE_SANITIZER_ADDRESS=$sanitizers \
  -DENABLE_SANITIZER_LEAK=$sanitizers \
  -DENABLE_SANITIZER_MEMORY=$memory \
  -DENABLE_SANITIZER_THREAD=$thread \
  -DENABLE_SANITIZER_UNDEFINED_BEHAVIOR=$sanitizers \
  -DENABLE_CLANG_TIDY=$staticAnalysis \
  -DENABLE_CPPCHECK=OFF \
  -DENABLE_INCLUDE_WHAT_YOU_USE=OFF \
  -DENABLE_DOCUMENTATION=$documentation \
  -DENABLE_SEMVER=ON

cmakeResult=$?
if [[ $cmakeResult -ne 0 ]]; then
  exit $cmakeResult
fi

# copy compile_commands.json for clangd
if [[ -e "./build/compile_commands.json" && "$exportCompileCommands" == "ON" ]]; then
  cp ./build/compile_commands.json ./compile_commands.json
  echo "compile_commands.json copied"
fi
