add_executable(
  ${PROJECT_NAME}
  main.cpp
)

target_include_directories(
  cpp-proj
  PRIVATE ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/include $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
)

find_package(fmt CONFIG REQUIRED)

# set target properties
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_17)

target_link_libraries(
  ${PROJECT_NAME}
  PRIVATE project_options project_warnings

  fmt::fmt
)
