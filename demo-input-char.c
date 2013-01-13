#include "libmalice.h"

int lmMain(void)
{
  char c;

  lmPrintString("This demo tests keyboard input for single characters.\n");

  lmPrintString("Enter a letter and press return: ");
  c = lmReadChar();
  lmPrintString("You entered the letter ");
  lmPrintChar(c);
  lmPrintChar('.');
  lmPrintChar('\n');

  return 0;
}
