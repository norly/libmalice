NASMFLAGS = -f elf
CINCLUDE=
CWARNS=-Wall -Wpointer-arith -Wnested-externs
CFLAGS=$(CINCLUDE) $(CWARNS) -O2
LDFLAGS=

SRCDIR=src
BINDIR=build

all: libmalice.o demo-printing

libmalice.o: libmalice.asm
	nasm $(NASMFLAGS) -o $@ $<

.c.o:
	cc $(CFLAGS) -c -o $@ $<

demo-printing: demo-printing.o libmalice.o
	ld $(LDFLAGS) -nostdlib -e _lmStart -o demo-printing demo-printing.o libmalice.o

demos: demo-printing

.PHONY : clean
clean:
	rm -f *.o
	rm -f demo-printing
