#ifdef HEADER_ONLY_LIBRARY
# this file is not needed for header only libraries
#else
option(INTERNAL_BUILD "Use internal build" ON)

find_package(fmt CONFIG REQUIRED)

add_executable(
  ${PROJECT_NAME}

  main.cpp
)

target_include_directories(
  ${PROJECT_NAME}
  PRIVATE
  
  ${CMAKE_CURRENT_SOURCE_DIR}
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}>
)

target_include_directories(
  ${PROJECT_NAME}
  SYSTEM PRIVATE

  # list any directories for external libraries
)

target_link_libraries(
  ${PROJECT_NAME}
  PRIVATE project_options

  fmt::fmt
)

if (INTERNAL_BUILD)
  target_compile_definitions(${PROJECT_NAME} PRIVATE DYL_INTERNAL_BUILD DYL_CHECKED_ALLOCATORS)
endif()

#endif
