# Options:
#
# ENABLE_IPO default OFF

option(ENABLE_IPO "Enable Interprocedural Optimization, aka Link Time Optimization (LTO)" OFF)

if (ENABLE_IPO)
  include(CheckIPOSupported)
  check_ipo_supported(RESULT result OUTPUT output)
  if (result)
    set(CMAKE_INTERPROCEDURAL_OPTIMIZATION TRUE)
  else ()
      message(WARNING "Requested to enalbe IPO, but is not supported by this compiler: ${output}")
  endif ()
endif ()
