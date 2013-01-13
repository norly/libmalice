NASMFLAGS = -f elf
CINCLUDE=
CWARNS=-Wall -Wpointer-arith -Wnested-externs
CFLAGS=$(CINCLUDE) $(CWARNS) -O2
LDFLAGS=

SRCDIR=src
BINDIR=build

all: libmalice.o demo-printing demo-input-char demo-input-int demo-exitcode

libmalice.o: libmalice.asm
	nasm $(NASMFLAGS) -o $@ $<

.c.o:
	cc $(CFLAGS) -c -o $@ $<

demo-printing: demo-printing.o libmalice.o
	ld $(LDFLAGS) -nostdlib -e _lmStart -o $@ $^

demo-input-char: demo-input-char.o libmalice.o
	ld $(LDFLAGS) -nostdlib -e _lmStart -o $@ $^

demo-input-int: demo-input-int.o libmalice.o
	ld $(LDFLAGS) -nostdlib -e _lmStart -o $@ $^

demo-exitcode: demo-exitcode.o libmalice.o
	ld $(LDFLAGS) -nostdlib -e _lmStart -o $@ $^


.PHONY : clean
clean:
	rm -f *.o
	rm -f demo-printing
	rm -f demo-input-char
	rm -f demo-input-int
	rm -f demo-exitcode
