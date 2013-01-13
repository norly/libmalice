#include "libmalice.h"

int lmMain(void)
{
  lmPrintString("This demo exits mid-program via lmExit() with code 23.\n");

  lmExit(23);

  lmPrintString("This line is never printed.\n");

  return 42;
}
