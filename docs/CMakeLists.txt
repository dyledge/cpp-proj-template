# ------------
# Doxygen docs
# ------------

find_package(Doxygen REQUIRED)

# pulling all headers from the src folder... this is not a general solution, but works for this project a much more
# robust approach is to ask cmake for the target's include directories - unfortunately, this will not result in actual
# paths b/c generator expressions...
file(GLOB_RECURSE DYLUTF_PUBLIC_HEADERS ${CMAKE_SOURCE_DIR}/src/include/*.hpp)

# doxygen input directory
set(DOXYGEN_INPUT_DIR ${CMAKE_SOURCE_DIR}/src)
# doxygen output directory (must be in the binary output folder)
set(DOXYGEN_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/doxygen)
# the html index file in the binary output folder (this is part of what doxygen generates)
set(DOXYGEN_INDEX_FILE ${DOXYGEN_OUTPUT_DIR}/html/index.html)
# the doxyfile template file
set(DOXYFILE_IN ${CMAKE_CURRENT_SOURCE_DIR}/Doxyfile.in)
# the resulting doxyfile after configure_file is called
set(DOXYFILE_OUT ${CMAKE_CURRENT_BINARY_DIR}/Doxyfile)

# create the doxyfile
configure_file(${DOXYFILE_IN} ${DOXYFILE_OUT} @ONLY)

# force the doxygen output directory to be created
file(MAKE_DIRECTORY ${DOXYGEN_OUTPUT_DIR})

# add a custom command with dependencies on this project's public header files
add_custom_command(
  OUTPUT ${DOXYGEN_INDEX_FILE}
  DEPENDS ${DYLUTF_PUBLIC_HEADERS}
  COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYFILE_OUT}
  MAIN_DEPENDENCY ${DOXYFILE_OUT}
  ${DOXYFILE_IN}
  COMMENT "Generating docs"
  VERBATIM
)

# custom doxygen target
add_custom_target(Doxygen_Editor ALL DEPENDS ${DOXYGEN_INDEX_FILE})

# -----------
# Sphinx docs
# -----------

find_package(Sphinx REQUIRED)

# the folder containing all of the rst files
set(SPHINX_SOURCE ${CMAKE_CURRENT_SOURCE_DIR})
# sphinx output directory (must be in the binary output folder)
set(SPHINX_BUILD ${CMAKE_CURRENT_BINARY_DIR}/sphinx)
# the html index file in the binary output folder (this is part of what sphinx-build generates)
set(SPHINX_INDEX_FILE ${SPHINX_BUILD}/index.html)

file(GLOB_RECURSE DYLUTF_RST_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.rst)

add_custom_command(
  OUTPUT ${SPHINX_INDEX_FILE}
  COMMAND ${SPHINX_EXECUTABLE} -b html -Dbreathe_projects.libutf=${DOXYGEN_OUTPUT_DIR}/xml ${SPHINX_SOURCE}
  ${SPHINX_BUILD}
  WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS ${SPHINX_SOURCE}/index.rst
  ${SPHINX_SOURCE}/example.rst
  ${SPHINX_SOURCE}/readme.rst
  ${SPHINX_SOURCE}/../README.rst
  ${DOXYGEN_INDEX_FILE}
  ${DYLUTF_RST_FILES}
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
