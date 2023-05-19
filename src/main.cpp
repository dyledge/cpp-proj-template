#ifdef HEADER_ONLY_LIBRARY
// this isn't needed for header only libraries
#else
#include <cstdlib>
#include <exception>

// This is a sample entry point that is used for validating the template. It
// will need to be replaced.

int main([[maybe_unused]] int argc, [[maybe_unused]] char *argv[]) try {
  return EXIT_SUCCESS;
} catch (std::exception &) {
  return EXIT_FAILURE;
} catch (...) {
  return EXIT_FAILURE;
}

#endif
