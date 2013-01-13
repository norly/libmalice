#include "libmalice.h"

int lmMain(void)
{
  int i;

  lmPrintString("This demo tests keyboard input for integers.\n");

  lmPrintString("Enter a number and press return: ");
  i = lmReadInt32s();
  lmPrintString("You entered the number ");
  lmPrintInt32s(i);
  lmPrintChar('.');
  lmPrintChar('\n');

  return 0;
}
