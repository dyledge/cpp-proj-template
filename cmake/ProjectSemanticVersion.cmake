# Set PROJECT_SEMVER_VERSION variable if enabled and detection succeeds.

# Detects semantic version by using ci/version file, as well as git branch information. Can be overridden by setting the
# PROJECT_SEMVER_VERSION as an environment variable.

# Options:
#
# ENABLE_SEMVER default OFF

option(ENABLE_SEMVER "Enable setting a semver2 compatible version number variable" OFF)

set(PROJECT_SEMVER_VERSION "")

if (ENABLE_SEMVER)

  if (DEFINED ENV{PROJECT_SEMVER_VERSION})
    # always use the environment variable, if it exists
    message("using environment variable PROJECT_SEMVER_VERSION")
    set(PROJECT_SEMVER_VERSION $ENV{PROJECT_SEMVER_VERSION})
  else ()
    # otherwise, use the ci/version file and (optionally) git repository info

    # get version from ci/version
    file(READ "ci/version" PROJECT_SEMVER_VERSION)
    set(PROJECT_SEMVER_EXT "")

    # determine if we go down the path using git, or not:
    find_package(Git QUIET)
    if (GIT_FOUND AND EXISTS "${CMAKE_SOURCE_DIR}/.git")

      # we are in a git repo, so get the branch name
      execute_process(
        COMMAND ${GIT_EXECUTABLE} branch --show-current
        OUTPUT_VARIABLE GIT_BRANCH_NAME
        RESULT_VARIABLE GIT_SHOW_BRANCH_RESULT
        OUTPUT_STRIP_TRAILING_WHITESPACE
      )

      if (GIT_SHOW_BRANCH_RESULT EQUAL "0")
        # grab the branch prefix
        string(
          REGEX MATCH
          "([A-Za-z]+)/.*"
          IGNORE_VAR
          "${GIT_BRANCH_NAME}"
        )
        set(GIT_BRANCH_PREFIX ${CMAKE_MATCH_1})

        if (GIT_BRANCH_PREFIX STREQUAL "master")
          # get the commit id and set PROJECT_SEMVER_EXT to dev+$commit_id
          execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
            OUTPUT_VARIABLE GIT_COMMIT_ID
            RESULT_VARIABLE GIT_COMMIT_ID_RESULT
            OUTPUT_STRIP_TRAILING_WHITESPACE
          )
          if (GIT_COMMIT_ID_RESULT STREQUAL "0")
            set(PROJECT_SEMVER_EXT "dev+${GIT_COMMIT_ID}")
          endif ()
        elseif (GIT_BRANCH_PREFIX STREQUAL "rel")
          # see if there is a tag on the HEAD
          execute_process(
            COMMAND ${GIT_EXECUTABLE} describe --tags --abbrev=4 HEAD
            OUTPUT_VARIABLE PROJECT_SEMVER_TAG
            RESULT_VARIABLE GIT_DESCRIBE_RESULT
            OUTPUT_STRIP_TRAILING_WHITESPACE
          )
          if (GIT_DESCRIBE_RESULT EQUAL "0")
            # we have tag, so this is an rc build
            execute_process(
              COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
              OUTPUT_VARIABLE GIT_COMMIT_ID
              RESULT_VARIABLE GIT_COMMIT_ID_RESULT
              OUTPUT_STRIP_TRAILING_WHITESPACE
            )
            if (GIT_COMMIT_ID_RESULT STREQUAL "0")
              set(PROJECT_SEMVER_EXT "rc+${GIT_COMMIT_ID}")
            endif ()
          else ()
            # this is a regular release build, so just use the version from ci/version
          endif ()
        else ()
          # get the commit id and set PROJECT_SEMVER_EXT to alpha+$commit_id
          execute_process(
            COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
            OUTPUT_VARIABLE GIT_COMMIT_ID
            RESULT_VARIABLE GIT_COMMIT_ID_RESULT
            OUTPUT_STRIP_TRAILING_WHITESPACE
          )
          if (GIT_COMMIT_ID_RESULT STREQUAL "0")
            set(PROJECT_SEMVER_EXT "alpha+${GIT_COMMIT_ID}")
          endif ()
        endif ()

        if ("${PROJECT_SEMVER_EXT}" STREQUAL "")
          # just use the base version
          message("unable to determine extra version info using git repository")
        else ()
          string(
            CONCAT PROJECT_SEMVER_VERSION
            ${PROJECT_SEMVER_VERSION}
            "-"
            ${PROJECT_SEMVER_EXT}
          )
        endif ()
      else ()
        # couldn't get the branch name
        message(FATAL_ERROR "running in a git repository, but unable to retrieve current branch name")
      endif ()
    endif ()
  endif ()
  message("PROJECT_SEMVER_VERSION=${PROJECT_SEMVER_VERSION}")
endif ()
