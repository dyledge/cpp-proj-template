#ifdef GENERATE_LIBRARY
add_library(
  ${PROJECT_NAME}
  main.cpp
)

add_library(${PROJECT_NAMESPACE}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
#else
add_executable(
  ${PROJECT_NAME}
  main.cpp
)
#endif

target_include_directories(
  ${PROJECT_NAME} PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/include
  $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
)

find_package(fmt CONFIG REQUIRED)

#ifdef GENERATE_LIBRARY
target_compile_features(${PROJECT_NAME} PUBLIC ${CPP_LANGUAGE_VERSION})
target_link_libraries(
  ${PROJECT_NAME} PRIVATE

  fmt::fmt
)
#else
target_link_libraries(
  ${PROJECT_NAME} PRIVATE
  project_options project_warnings

  fmt::fmt
)
#endif
#ifdef GENERATE_LIBRARY
# -- install
include(GNUInstallDirs)
install(
  TARGETS ${PROJECT_NAME}
  EXPORT ${PROJECT_NAME}Targets
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  INCLUDES DESTINATION ${LIBLEGACY_INCLUDE_DIRS}
)
install(DIRECTORY ${CMAKE_SOURCE_DIR}/include DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
install(
  EXPORT ${PROJECT_NAME}Targets
  FILE ${PROJECT_NAME}Targets.cmake
  NAMESPACE ${PROJECT_NAMESPACE}::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)

include(CMakePackageConfigHelpers)
## TODO:
## File contents of cmake/${PROJECT_NAME}Config.cmake.in
##
##@PACKAGE_INIT@
##
### find dependencies
### <none>
##
##if(NOT TARGET ${PROJECT_NAMESPACE}::${PROJECT_NAME})
##    include(${CMAKE_CURRENT_LIST_DIR}/${PROJECT_NAME}Targets.cmake)
##endif()
##
configure_package_config_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/${PROJECT_NAME}Config.cmake.in ${CMAKE_BINARY_DIR}/cmake/${PROJECT_NAME}Config.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
)
write_basic_package_version_file(
  ${CMAKE_BINARY_DIR}/cmake/${PROJECT_NAME}ConfigVersion.cmake
  VERSION ${PROJECT_VERSION} # todo: needs a variable
  COMPATIBILITY AnyNewerVersion
)
install(FILES ${CMAKE_BINARY_DIR}/cmake/${PROJECT_NAME}Config.cmake ${CMAKE_BINARY_DIR}/cmake/${PROJECT_NAME}ConfigVersion.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME})

# -- export
export(
  EXPORT ${PROJECT_NAME}Targets
  FILE ${CMAKE_BINARY_DIR}/cmake/${PROJECT_NAME}Targets.cmake
  NAMESPACE ${PROJECT_NAMESPACE}::
)
#endif
