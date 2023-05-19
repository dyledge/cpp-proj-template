# Makes sure this project is the top level project (i.e. not added by add_subdirectory, or something else)

function(assert_this_is_the_top_level_project)

  if (CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
    set(IS_TOP_LEVEL TRUE)
  else ()
    set(IS_TOP_LEVEL FALSE)
  endif ()
  
  if (NOT IS_TOP_LEVEL)
    message(FATAL_ERROR "This project must be the top level CMake Project.")
  endif ()

endfunction()

assert_this_is_the_top_level_project()
