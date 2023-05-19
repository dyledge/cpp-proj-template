find_package(Catch2 CONFIG REQUIRED)
include(Catch)

# add an executable for unit tests
add_executable(
  unit_tests

  example_tests.cpp
)

target_include_directories(
  unit_tests
  PRIVATE

  ../src
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/../src>
)

target_link_libraries(
  unit_tests
  PRIVATE project_options

)

catch_discover_tests(
  unit_tests
  TEST_PREFIX
  "unit."
  EXTRA_ARGS
  -s
  --reporter=xml
  --out=tests.xml
)
