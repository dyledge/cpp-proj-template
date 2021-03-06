cmake_minimum_required(VERSION 3.15)

# Set CMAKE_TOOLCHAIN_FILE here to avoid having to specify it on the cmake command line
set(CMAKE_TOOLCHAIN_FILE
  ${CMAKE_CURRENT_SOURCE_DIR}/extern/vcpkg/scripts/buildsystems/vcpkg.cmake
  CACHE STRING "vcpkg toolchain file"
)

# set the name of the project and some project properties
project(
  ${PROJECT_NAME}
  DESCRIPTION "${PROJECT_BRIEF}"
  VERSION ${PROJECT_VERSION}
  LANGUAGES C CXX
)

set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules" ${CMAKE_MODULE_PATH})
set(CMAKE_CXX_EXTENSIONS OFF)

set(PROJECT_COPYRIGHT_LINE "${PROJECT_COPYRIGHT}")
include(cmake/ProjectSemanticVersion.cmake)

include(cmake/StandardProjectSettings.cmake)
include(cmake/PreventInSourceBuilds.cmake)
# enable cache system
include(cmake/Cache.cmake)
# standard compiler warnings
include(cmake/CompilerWarnings.cmake)
# sanitizer options if supported by compiler
include(cmake/Sanitizers.cmake)
# allow for static analysis options
include(cmake/StaticAnalyzers.cmake)
# project version based on git branch and revision
include(cmake/ProjectSemanticVersion.cmake)

#ifdef GENERATE_LIBRARY
if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
#endif
  # empty library to set c++ standard and compile time options
  add_library(project_options INTERFACE)
  target_compile_features(project_options INTERFACE ${CPP_LANGUAGE_VERSION})
  if (CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
    option(ENABLE_BUILD_WITH_TIME_TRACE "Enable -ftime-trace to generate time tracing .json files on clang" OFF)
    if (ENABLE_BUILD_WITH_TIME_TRACE)
      add_compile_definitions(project_options INTERFACE -ftime-trace)
    endif ()
  endif()

  # empty library to set warnings
  add_library(project_warnings INTERFACE)

  # standard compiler warnings
  set_project_warnings(project_warnings)

  # sanitizer options if supported by compiler
  enable_sanitizers(project_options)
#ifdef GENERATE_LIBRARY
else()
  # some checking regarding what is provided by the enclosing project
  if (TARGET project_options)
  else ()
    message(FATAL_ERROR project_options target undefined)
  endif ()
  if (TARGET project_warnings)
  else ()
    message(FATAL_ERROR project_warnings target undefined)
  endif ()
endif()
#endif

option(BUILD_SHARED_LIBS "Enable compilation of shared libraries" OFF)
option(ENABLE_TESTING "Enable Test Builds" ON)
option(ENABLE_FUZZING "Enable Fuzzing Builds" OFF)
option(ENABLE_DOCUMENTATION "Enable doxygen sphinx breathe documentation builds out of source" OFF)

add_subdirectory(src)

if (ENABLE_TESTING)
  enable_testing()
  message("building tests")
  add_subdirectory(test)
endif ()

if (ENABLE_FUZZING)
  message("building fuzz tests (https://www.llvm.org/docs/LibFuzzer.html)")
  add_subdirectory(test/fuzz)
endif ()

if (ENABLE_DOCUMENTATION)
  add_subdirectory(docs)
endif ()

configure_file("${PROJECT_SOURCE_DIR}/src/include/version.hpp.in" "${PROJECT_BINARY_DIR}/src/include/version.hpp" @ONLY)
