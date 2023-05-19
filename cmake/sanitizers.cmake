# Enables coverage instrumentation and sanitizers if supported by the toolchain, for an interface
# target.

# Checks for valid combinations of asan, leak, memory, ub, thread, memory sanitizers. Currently only
# works if the detected compiler is either a Clang or GCC compiler.

# Options:
#
# ENABLE_COVERAGE default FALSE
# ENABLE_SANITIZER_ADDRESS FALSE
# ENABLE_SANITIZER_LEAK FALSE
# ENABLE_SANITIZER_UNDEFINED_BEHAVIOR FALSE
# ENABLE_SANITIZER_THREAD FALSE
# ENABLE_SANITIZER_MEMORY FALSE

function(enable_sanitizers project_name)

  if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    option(ENABLE_COVERAGE "Enable coverage reporting for gcc/clang" FALSE)

    if (ENABLE_COVERAGE)
      if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
        message("using llvm-cov")
        target_compile_options(${project_name} INTERFACE -fprofile-instr-generate -fcoverage-mapping)
        target_link_options(${project_name} INTERFACE -fprofile-instr-generate)
      else ()
        message("using gcov")
        target_compile_options(${project_name} INTERFACE --coverage -O0 -g)
        target_link_libraries(${project_name} INTERFACE --coverage)
      endif ()
    endif ()

    set(SANITIZERS "")

    option(ENABLE_SANITIZER_ADDRESS "Enable address sanitizer" FALSE)
    if (ENABLE_SANITIZER_ADDRESS)
      list(APPEND SANITIZERS "address")
    endif ()

    option(ENABLE_SANITIZER_LEAK "Enable leak sanitizer" FALSE)
    if (ENABLE_SANITIZER_LEAK)
      if (NOT CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
        message(WARNING "Leak sanitizer is supported only for LLVM Clang")
      else ()
        list(APPEND SANITIZERS "leak")
      endif ()
    endif ()

    option(ENABLE_SANITIZER_UNDEFINED_BEHAVIOR "Enable undefined behavior sanitizer" FALSE)
    if (ENABLE_SANITIZER_UNDEFINED_BEHAVIOR)
      list(APPEND SANITIZERS "undefined")
    endif ()

    option(ENABLE_SANITIZER_THREAD "Enable thread sanitizer" FALSE)
    if (ENABLE_SANITIZER_THREAD)
      if ("address" IN_LIST SANITIZERS OR "leak" IN_LIST SANITIZERS)
        message(WARNING "Thread sanitizer does not work with Address and Leak sanitizer enabled")
      else ()
        list(APPEND SANITIZERS "thread")
      endif ()
    endif ()

    option(ENABLE_SANITIZER_MEMORY "Enable memory sanitizer" FALSE)
    if (ENABLE_SANITIZER_MEMORY AND CMAKE_CXX_COMPILER_ID MATCHES "Clang")
      if ("address" IN_LIST SANITIZERS
        OR "thread" IN_LIST SANITIZERS
        OR "leak" IN_LIST SANITIZERS
        )
        message(WARNING "Memory sanitizer does not work with Address, Thread and Leak sanitizer enabled")
      else ()
        list(APPEND SANITIZERS "memory")
      endif ()
    endif ()

    list(JOIN SANITIZERS "," LIST_OF_SANITIZERS)

  endif ()

  if (LIST_OF_SANITIZERS)
    if (NOT "${LIST_OF_SANITIZERS}" STREQUAL "")
      message("using sanitizers: ${LIST_OF_SANITIZERS}")
      target_compile_options(${project_name} INTERFACE -fsanitize=${LIST_OF_SANITIZERS})
      target_link_libraries(${project_name} INTERFACE -fsanitize=${LIST_OF_SANITIZERS})
    endif ()
  endif ()

endfunction()
