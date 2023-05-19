# ${CPP_PROJ_PROJECT_NAME} cmake

This directory contains support routines for the CMake-based build system used by ${CPP_PROJ_PROJECT_NAME}.

The `modules/` folder contains CMake modules used by ${CPP_PROJ_PROJECT_NAME}. In order to take advantage of
these modules, include the following in the CMake script that needs them:

```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")
```
