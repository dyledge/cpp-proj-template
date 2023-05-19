cmake_minimum_required(VERSION 3.15)

if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/extern/vcpkg/scripts/buildsystems/vcpkg.cmake)
  set(CMAKE_TOOLCHAIN_FILE
    ${CMAKE_CURRENT_SOURCE_DIR}/extern/vcpkg/scripts/buildsystems/vcpkg.cmake
    CACHE STRING "vcpkg toolchain file"
  )
endif ()

project(
  ${CPP_PROJ_PROJECT_NAME}
  DESCRIPTION "${CPP_PROJ_PROJECT_BRIEF}"
  VERSION ${CPP_PROJ_PROJECT_VERSION}
  LANGUAGES CXX
)

include(cmake/in_source_builds_not_supported.cmake)
include(GNUInstallDirs)
include(cmake/enable_ccache.cmake)

#ifdef HEADER_ONLY_LIBRARY
if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
  set(IS_TOP_LEVEL TRUE)
else ()
  set(IS_TOP_LEVEL FALSE)
endif ()
set(CMAKE_CXX_EXTENSIONS OFF)
set(PROJECT_COPYRIGHT_LINE "${CPP_PROJ_PROJECT_COPYRIGHT}")
add_library(${PROJECT_NAME} INTERFACE)
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
target_include_directories(${PROJECT_NAME} INTERFACE $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src> $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)
if (IS_TOP_LEVEL)
  install(TARGETS ${PROJECT_NAME} EXPORT ${PROJECT_NAME}-targets)
  if (NOT EXISTS "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake.in")
    file(WRITE ${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake.in [[
      @PACKAGE_INIT@
      include("${CMAKE_CURRENT_LIST_DIR}/@PROJECT_NAME@-targets.cmake
    ]])
  endif ()
  include(CMakePackageConfigHelpers)
  write_basic_package_version_file(${PROJECT_NAME}-config-version.cmake VERSION ${PROJECT_VERSION} COMPATIBILTY SameMajorVersion)
  configure_package_config_file(
    "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake.in"
    "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
    INSTALL_DESTINATION "${CMAKE_INSTALL_DATADIR}/cmake/${PROJECT_NAME}"
    NO_SET_AND_CHECK_MACRO
    NO_CHECK_REQUIRED_COMPONENTS_MACRO
  )
  install(EXPORT ${PROJECT_NAME}-targets DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/${PROJECT_NAME)
  install(
    FILES
      "${PROJECT_BINARY_DIR}/${PROJECT_NAME}/-config-version.cmake"
      "${PROJECT_BINARY_DIR}/${PROJECT_NAME}-config.cmake"
    DESTINATION ${CMAKE_INSTALL_DATADIR}/cmake/${PROJECT_NAME}
  )
  install(DIRECTORY src/ DESTINATION include FILES_MATCHING PATTERN *.hpp)

  add_library(project_options INTERFACE)
  target_compile_features(project_options INTERFACE ${CPP_PROJ_CPP_LANGUAGE_VERSION})
  include(cmake/set_time_trace.cmake)
  set_time_trace(project_options)
  include(cmake/sanitizers.cmake)
  enable_sanitizers(project_options)
  include(cmake/compiler_warnings.cmake)
  set_project_warnings(project_options)
  include(cmake/select_linker.cmake)
  include(cmake/select_ipo.cmake)
  set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded<$<CONFIG:Debug>:Debug>") # remove this line if using the dynamic version
  include(cmake/compiler_specific_options.cmake)
  include(cmake/enable_code_coverage.cmake)

  option(ENABLE_TESTING "Generate test binaries" ON)
  option(ENABLE_FUZZING "Generate fuzz test binaries" OFF)
  option(ENABLE_DOCUMENTATION "Generate documentation" ON)

  if (ENABLE_TESTING)
    enable_testing()
    add_subdirectory(test)
  endif()
  if (ENABLE_FUZZING)
    add_subdirectory(test/fuzz)
  endif()
  if (ENABLE_DOCUMENTATION)
    set(CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules" ${CMAKE_MODULE_PATH})
    add_subdirectory(docs)
  endif ()
endif ()
#else
include(cmake/must_be_top_level.cmake)
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake/modules")
set(CMAKE_CXX_EXTENSIONS OFF)
set(PROJECT_COPYRIGHT_LINE "${CPP_PROJ_PROJECT_COPYRIGHT}")
include(cmake/detect_semantic_version.cmake)
#todo: install steps
#todo: packaging steps

add_library(project_options INTERFACE)
target_compile_features(project_options INTERFACE ${CPP_PROJ_CPP_LANGUAGE_VERSION})
include(cmake/set_time_trace.cmake)
set_time_trace(project_options)
include(cmake/sanitizers.cmake)
enable_sanitizers(project_options)
include(cmake/compiler_warnings.cmake)
set_project_warnings(project_options)
include(cmake/select_linker.cmake)
include(cmake/select_ipo.cmake)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded<$<CONFIG:Debug>:Debug>") # remove this line if using the dynamic version
include(cmake/compiler_specific_options.cmake)
include(cmake/enable_code_coverage.cmake)
if (EXISTS ${PROJECT_SOURCE_DIR}/src/version.hpp.in)
  configure_file("${PROJECT_SOURCE_DIR}/src/version.hpp.in" "${PROJECT_BINARY_DIR}/src/version.hpp" @ONLY)
endif ()

option(BUILD_SHARED_LIBS "Build using shared libraries" OFF)
#set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
option(ENABLE_TESTING "Generate test binaries" ON)
option(ENABLE_FUZZING "Generate fuzz test binaries" OFF)
option(ENABLE_DOCUMENTATION "Generate documentation" OFF)

if (ENABLE_TESTING)
  enable_testing()
  add_subdirectory(test)
endif ()
if (ENABLE_FUZZING)
  add_subdirectory(test/fuzz)
endif ()
if (ENABLE_DOCUMENTATION)
  add_subdirectory(docs)
endif()
#endif
