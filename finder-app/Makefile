.PHONY: clean

all: writer.c
ifeq ($(CROSS_COMPILE), aarch64-none-linux-gnu-)
	/opt/toolchains/bin/aarch64-none-linux-gnu-gcc writer.c -o writer -static
else
	gcc writer.c -o writer
	gcc writer.c
endif
clean:
	rm -f *.o
	rm -f a.out
	rm writer

