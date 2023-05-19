# set the linker to use for this directory and all subdirectories

if (UNIX AND NOT APPLE)
  if (CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
    # try to find a matching lld- version
    string(REPLACE "." ";" VERSION_LIST ${CMAKE_CXX_COMPILER_VERSION})
    list(GET VERSION_LIST 0 CLANG_VERSION_MAJOR)

    find_program(LLD_PROGRAM lld-${CLANG_VERSION_MAJOR})
    if (LLD_PROGRAM)
      message(STATUS "using ${LLD_PROGRAM}")
      add_link_options("-fuse-ld=lld")  
    endif ()
  
  elseif (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    # try to use gold
    find_program(GNU_GOLD_PROGRAM gold)
    if (GNU_GOLD_PROGRAM)
      include(ProcessorCount)
      ProcessorCount(HOST_PROC_COUNT)
      message(STATUS "using ${GNU_GOLD_PROGRAM} with threads: ${HOST_PROC_COUNT}")
      add_link_options(-fuse-ld=gold;LINKER:--threads,--thread-count=${HOST_PROC_COUNT})
    endif ()

  endif ()
endif ()
