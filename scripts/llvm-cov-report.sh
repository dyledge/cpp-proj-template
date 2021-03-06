#!/bin/bash

# Runs the unit test binary and uses llvm-cov tools to generate html report, lcov data and cobertura data
# Requires llvm, as well as python3 at location /usr/bin/python3

# passing in the llvm version number on the command line invokes that specific version of llvm
# if it is not installed, prepare for messages from the shell about being unable to find it
llvmver=${1:-12}
# pass in the directory name, relative to the project root directory, where the cmake output is located
build_directory=${2:-build}

# specify the directory the unit test executable is located in, as well as the unit test executable name
test_exe_arg=$build_directory/test/unit_tests

directory=`dirname ${test_exe_arg}`
unit_test_exe=`basename ${test_exe_arg}`
python=/usr/bin/python3
llvm_profdata="llvm-profdata-$llvmver"
llvm_cov="llvm-cov-$llvmver"
binary="$directory/$unit_test_exe"
profraw="$directory/$unit_test_exe.profraw"
profdata="$directory/$unit_test_exe.profdata"
html="$directory/$unit_test_exe-coverage.html"
lcovdata="$directory/$unit_test_exe-coverage.lcov"
coberturaxml="$directory/$unit_test_exe-cobertura.xml"

# assume the instrumented application is already built

# run it, create the profraw file in the same folder as the app
LLVM_PROFILE_FILE="$profraw" "$binary"

if [[ -e "$profraw" ]]; then
  # index the profraw file into profdata
  $llvm_profdata merge -sparse "$profraw" -o "$profdata"

  if [[ -e "$profdata" ]]; then
    # show the report on the command line
    $llvm_cov report "$binary" -instr-profile="$profdata" -ignore-filename-regex=.*test/.* -ignore-filename-regex=.*extern/.* -use-color

    # show the details in html format
    $llvm_cov show "$binary" -instr-profile="$profdata" -ignore-filename-regex=.*test/.* -ignore-filename-regex=.*extern/.* -use-color --format html >"$html"

    # export the coverage data as lcov format
    $llvm_cov export "$binary" -instr-profile="$profdata" -ignore-filename-regex=.*test/.* -ignore-filename-regex=.*extern/.* -format=lcov >"$lcovdata"

    if [[ -e "$lcovdata" ]]; then
      # convert lcov format into cobertura xml
      $python scripts/lcov_cobertura.py "$lcovdata" -o "$coberturaxml"
    fi
  elif
    echo "no indexed profile data found: $profdata"
  fi
elif
  echo "no raw profile data found: $profraw"
fi
