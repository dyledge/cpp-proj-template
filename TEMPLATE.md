# Project Layout

+ /ci
    + Continuous integration information
    + Modify vcpkg-dependencies to include additional packages when using the bootstrap and update vcpkg scripts
+ /cmake
    + CMake modules
        + FindSphinx is used to locate sphinx on the local machine
    + [Inline CMake code](#inline-cmake-code) referenced by the project's CMakeLists.txt file
+ /docs
    + Documentation content using restructured text
        + Update CMakeLists.txt to include any files that should trigger a rebuild rst docs
    + Configuration for generating documentation from source using Doxygen
+ /extern
    + External dependencies
        + Vcpkg package source
        + Non-vcpkg managed package source
+ /scripts
    + Bash and python scripts for:
        + Project bootstrapping and udpating
        + Code coverage report creation
    + Overlay triplets for vcpkg in order to override how packages from vcpkg are built for the project
+ /src
    + Project source code
+ /test
    + Project test and fuzzing code

The project is setup as a CMake super project. The project root CMakeLists.txt file drives global
configuration for all subdirectories. Additional details about each subdirectory are found in a
README file in the directory of interest.

The default license is MIT, and needs to be changed based on the needs of the project.

## Inline CMake code

| Name                           | Description                                                                                                                       |
|--------------------------------|-----------------------------------------------------------------------------------------------------------------------------------|
| compiler_specific_options      | Set project wide compiler options that are specific to a compiler vendor                                                          |
| compiler_warnings              | Function for setting warnings on interface projects that are used for linking to targets in the project                           |
| detect_semantic_version        | Detect semantic version from git and ci/version file and set PROJECT_SEMVER_VERSION                                               |
| enable_ccache                  | Enable ccache or sccache, if requested, into CMAKE_CXX_COMPILER_LAUNCHER                                                          |
| enable_code_coverage           | Enable code coverage for gcc and clang                                                                                            |
| in_source_builds_not_supported | Inline CMake for erroring out if attempting to build in-source                                                                    |
| must_be_top_level              | Inline CMake for erroring out if this project is not the top level project                                                        |
| sanitizers                     | Enables address sanitizer, undefined behavior sanitizer and/or thread sanitizer for gcc and clang                                 |
| select_ipo                     | Enable inter-procedural optimization (aka link time code generation) if supported by the compiler                                 |
| select_linker                  | Select a faster, stable linker for gcc and clang, if present on the system                                                        |
| set_time_trace                 | Enable time trace in clang for troubleshooting compile time bottlenecks                                                           |
| static_analyzers               | Sets CMAKE_CXX_CPPCHECK, CMAKE_CXX_CLANG_TIDY and CMAKE_CXX_INCLUDE_WHAT_YOU_USE, if requested and they are available on the host |

## Details

### Project level CMakeLists.txt

> This is not an exhaustive description.

- Minimum CMake version is set to 3.15
- Sets CMAKE_TOOLCHAIN_FILE to vcpkg.cmake from the extern/vcpkg project
- LANGUAGES is set to CXX
- Does not support in-source builds by default
- Uses GNUInstallDirs
- Enables ccache, by default

The rest of project level CMakeLists.txt is populated based on the type of project.

If the project is a header only library:

- Turns off CMAKE_CXX_EXTENSIONS
- Adds project library as an interface library
- Adds project library alias for internal referencing by targets like unit_tests
- Sets project library include directories
- If the header only library is top level:
  - Configures header file installation
  - Creates project_options interface library for other project targets
  - Sets the C++ language version
  - Sets time tracing, if requested
  - Sets up sanitizers, if requested
  - Sets up compiler warnings and "error on warnings", by default
  - Selects a faster linker
  - Selects IPO, if requested
  - Sets CMAKE_MSVC_RUNTIME_LIBRARY to static, by default
  - Enables additional compiler specific options
  - Enables code coverage, if requested
  - Configures version.hpp, if src/version.hpp.in exists
  - Adds test subdirectory by default
  - Adds fuzz test subdirectory, if requested
  - Adds docs subdirectory, if requested

If the project is a normal project (installs one or more binary targets):

- Ensures the project is always top level (can't be added via add_subdirectory())
- Adds cmake/modules to the APPEND_CMAKE_MODULE_PATH list
- Turns off CMAKE_CXX_EXTENSIONS
- Sets the C++ language version
- Sets time tracing, if requested
- Sets up sanitizers, if requested
- Sets up compiler warnings and "error on warnings", by default
- Selects a faster linker
- Selects IPO, if requested
- Sets CMAKE_MSVC_RUNTIME_LIBRARY to static, by default
- Enables additional compiler specific options
- Enables code coverage, if requested
- Configures version.hpp, if src/version.hpp.in exists
- Adds test subdirectory by default
- Adds fuzz test subdirectory, if requested
- Adds docs subdirectory, if requested
