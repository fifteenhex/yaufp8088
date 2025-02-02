.PHONY: all
all: reset.o

reset.o: reset.S
	nasm -wall -g -felf -o $@ $<


INCLUDES_FILES=pic_8259.S pio_8255.S usart_8251.S
includes.stamp: $(INCLUDES_FILES)
	touch $@

