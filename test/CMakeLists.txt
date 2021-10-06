find_package(Catch2 CONFIG REQUIRED)
include(Catch)

# library containing implementation of main()
add_library(catch_main STATIC catch_main.cpp)
target_link_libraries(catch_main PUBLIC Catch2::Catch2)
target_link_libraries(catch_main PRIVATE project_options)

# add an executable for unit tests
add_executable(
  unit_tests
  example_tests.cpp
)

target_include_directories(
  unit_tests
  PRIVATE
  ../src/include
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/../src/include>
)

target_link_libraries(
  unit_tests
  PRIVATE project_warnings project_options catch_main
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
