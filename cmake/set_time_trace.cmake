# For Clang, use -ftime-trace to produce a trace file for the build for compilation analysis, if
# requested.

# Options:
# ENABLE_BUILD_WITH_TIME_TRACE default OFF

function(enable_time_traced_builds project_name)

  if (CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    option(ENABLE_BUILD_WITH_TIME_TRACE "Enable -ftime-trace to generate trace files when using Clang" OFF)
    if (ENABLE_BUILD_WITH_TIME_TRACE)
        add_compile_definitions(${project_name} INTERFACE -ftime-trace)
    endif ()
  endif ()

endfunction()
