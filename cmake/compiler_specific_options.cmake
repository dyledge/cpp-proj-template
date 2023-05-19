# Set compiler options for all targets in this directory and all subdirectories

if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
  # LLVM Clang

  if (CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "MSVC")
    # clang-cl front end
  elseif (CMAKE_CXX_COMPILER_FRONTEND_VARIANT STREQUAL "GNU")
    # regular front end

    add_compile_options($<$<CONFIG:Debug>:-fstandalone-debug>)
    add_compile_options($<$<CONFIG:Debug>:-fno-omit-frame-pointer>)
  endif ()

elseif (CMAKE_CXX_COMPILER_ID STREQUAL "AppleClang")
  # Apple Clang

elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
  # GNU Compiler Collection

    add_compile_options($<$<CONFIG:Debug>:-fno-omit-frame-pointer>)
  
elseif (CMAKE_CXX_COMPILER_ID STREQUAL "MSVC")
  # Microsoft Visual Studio

elseif (CMAKE_CXX_COMPILER_ID STREQUAL "NVIDIA")
  # NVIDIA CUDA compiler

else ()
  # see https://cmake.org/cmake/help/latest/variable/CMAKE_LANG_COMPILER_ID.html
endif ()
