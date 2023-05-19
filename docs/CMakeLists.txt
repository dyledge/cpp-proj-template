find_package(Doxygen REQUIRED)

# Pulling all headers from the src folder... this is not a general solution and should be tailored
# for each project specifically.
file(
  GLOB_RECURSE DYL_PROJECT_PUBLIC_HEADERS
  ${CMAKE_SOURCE_DIR}/src/*.hpp
  ${CMAKE_SOURCE_DIR)/*.md
  # and any other glob filters
)

set(DOXYGEN_INPUT_DIR ${CMAKE_SOURCE_DIR}/src)
set(DOXYGEN_README_MAIN_PAGE ${CMAKE_SOURCE_DIR}/README.md) # used as main page
set(DOXYGEN_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/doxygen)
set(DOXYGEN_INDEX_FILE ${DOXYGEN_OUTPUT_DIR}/html/index.html)
set(DOXYFILE_IN ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in)
set(DOXYFILE_OUT ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)

# create the doxyfile
configure_file(${DOXYFILE_IN} ${DOXYFILE_OUT} @ONLY)

# force the doxygen output directory to be created
file(MAKE_DIRECTORY ${DOXYGEN_OUTPUT_DIR})

# add a custom command with dependencies on this project's public header files
add_custom_command(
  OUTPUT ${DOXYGEN_INDEX_FILE}
  DEPENDS ${DYL_PROJECT_PUBLIC_HEADERS}
  COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYFILE_OUT}
  MAIN_DEPENDENCY ${DOXYFILE_OUT}
  ${DOXYFILE_IN}
  COMMENT "Generating docs"
  VERBATIM
)

# custom doxygen target
add_custom_target(Doxygen_Editor ALL DEPENDS ${DOXYGEN_INDEX_FILE})


find_package(Sphinx REQUIRED)

set(SPHINX_SOURCE ${CMAKE_CURRENT_SOURCE_DIR})
set(SPHINX_BUILD ${CMAKE_CURRENT_BINARY_DIR}/sphinx)
set(SPHINX_INDEX_FILE ${SPHINX_BUILD}/index.html)

file(GLOB_RECURSE DYL_PROJECT_RST_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.rst)

add_custom_command(
  OUTPUT ${SPHINX_INDEX_FILE}
  COMMAND ${SPHINX_EXECUTABLE} -b html -Dbreathe_projects.libutf=${DOXYGEN_OUTPUT_DIR}/xml ${SPHINX_SOURCE}
  ${SPHINX_BUILD}
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS ${SPHINX_SOURCE}/index.rst
    ${SPHINX_SOURCE}/example.rst
    ${SPHINX_SOURCE}/readme.rst
    ${DOXYGEN_INDEX_FILE}
    ${DYL_PROJECT_RST_FILES}
    ${DOXYGEN_INDEX_FILE}
    ${DYL_PROJECT_RST_FILES}
    # add additional dependencies, if needed
  MAIN_DEPENDENCY ${SPHINX_SOURCE}/conf.py
  COMMENT "Generating documentation with Sphinx"
)

# custom sphinx target
add_custom_target(Sphinx_Editor ALL DEPENDS ${SPHINX_INDEX_FILE})

# ------------------------------------------
# Install target for the sphinx build output
# ------------------------------------------

include(GNUInstallDirs)
install(DIRECTORY ${SPHINX_BUILD} DESTINATION ${CMAKE_INSTALL_DOCDIR})

message("CMAKE_INSTALL_DOCDIR=${CMAKE_INSTALL_DOCDIR}")
