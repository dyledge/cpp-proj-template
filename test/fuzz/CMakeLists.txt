## NOTE: This is an example that fuzz tests fmt::format.
##       Projects will have multiple fuzz tests, and can be setup similarly.

find_package(fmt CONFIG REQUIRED)

add_executable(fuzz_libfmt example_fuzz_test.cpp)

target_link_libraries(
  fuzz_libfmt
  PRIVATE project_options

  fmt::fmt

  -coverage
  -fsanitize=fuzzer,undefined,address
)

target_compile_options(fuzz_libfmt PRIVATE -fsanitize=fuzzer,undefined,address)
