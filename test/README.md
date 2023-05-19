# ${CPP_PROJ_PROJECT_NAME} test

This directory contains all of the unit and integration tests used by ${CPP_PROJ_PROJECT_NAME}. Most of these
tests are run in an automated manner to validate that the core functionality runs as expected.

Some tests are compile only (have constexpr in the name), while others have their behavior validated
at runtime.

Most of the tests use the [Catch2](https://github.com/catchorg/Catch2) test framework.
