#include "libmalice.h"

int lmMain(void)
{
  lmPrintString("This demo intersperses strings, integers and single characters:\n");

  lmPrintString("The integer ");
  lmPrintInt32s(-559038737);
  lmPrintString(" is negative");
  lmPrintChar('.');
  lmPrintChar(' ');
  lmPrintInt32s(3);
  lmPrintString(" is positive.");
  lmPrintChar('\n');

  return 0;
}
