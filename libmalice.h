#ifndef _LIBMALICE_H_
#define _LIBMALICE_H_

void _lmStart(void);
int lmMain(void);

void lmExit(int exitstatus);

void lmPrintChar(int chr);
void lmPrintString(char *string);
void lmPrintInt32s(int num);

int lmReadChar(void);
int lmReadInt32s(void);

#endif
