# Fuzz testing ${CPP_PROJ_PROJECT_NAME}

This document describes fuzz testing ${CPP_PROJ_PROJECT_NAME} for contributors.

${CPP_PROJ_PROJECT_NAME} uses [libFuzzer](https://llvm.org/docs/LibFuzzer.html) for coverage guided fuzz testing.

## Fuzz tests

> Fuzz testing must be run using the LLVM Clang compiler.

All fuzz tests are located in `test/fuzz`. Each cpp file is a separate fuzz test. The CMake script
in this folder adds running the executable to a CTest test. Configure and build the test using CMake
by setting `ENABLE_FUZZING` to `ON`.

Each test is run using an execution timeout that is set by the variable `FUZZ_EXECUTION_TIME` to
limit the length of time the fuzz test runs. If part of an automated test run, it is recommended to
run all tests in parallel for 10 seconds or less to lightly verify that breakages haven't occurred.

Most fuzz tests are setup to run with Address Sanitizer and Undefined Behavior Sanitizer by default.
It is also recommended to undefine `NDEBUG` and use and `INTERNAL_BUILD` to add additional checks
that will halt execution when errors are detected.

> TODO: More guidance needed for isolating corpus files per test
