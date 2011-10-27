NASMFLAGS = -f elf

all: libmalice.o

libmalice.o: libmalice.asm
	nasm $(NASMFLAGS) -o $@ $<

.PHONY : clean
clean:
	rm -f *.o

.PHONY : distclean
distclean: clean
	rm -f *~

.PHONY : test
test: all
