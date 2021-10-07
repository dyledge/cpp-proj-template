## NOTE: This is an example that fuzz tests fmt::format.
##       The project will have multiple fuzz tests, but will be setup similarly.

find_package(fmt CONFIG REQUIRED)

# Allow short runs during automated testing to see if something new breaks
set(
  FUZZ_RUNTIME 10 # Default of 10 seconds
  CACHE STRING "Number of seconds to run fuzz tests during ctest run"
)

add_executable(fuzz_tester example_fuzz_test.cpp)
target_link_libraries(
  fuzz_tester
  PRIVATE project_options
  project_warnings
  fmt::fmt
  -coverage
  -fsanitize=fuzzer,undefined,address)
target_compile_options(fuzz_tester PRIVATE -fsanitize=fuzzer,undefined,address)

add_test(NAME fuzz_tester_run COMMAND fuzz_tester -max_total_time=${FUZZ_RUNTIME})
