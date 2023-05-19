# Makes sure the project is built out of source.

function(dont_support_in_source_builds)
  # avoid getting caught by symlinks, as well
  get_filename_component(MY_SRC_DIR "${CMAKE_SOURCE_DIR}" REALPATH)
  get_filename_component(MY_BIN_DIR "${CMAKE_BINARY_DIR}" REALPATH)

  if ("${MY_SRC_DIR}" STREQUAL "${MY_BIN_DIR}")
    message(FATAL_ERROR "In-Source builds are not supported.")
  endif ()
endfunction()

dont_support_in_source_builds()
