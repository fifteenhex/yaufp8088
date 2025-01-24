.PHONY: burn

all: fw.hex

fw.elf: main.c
	avr-gcc -mmcu=attiny85 -Os -o $@ $^

fw.hex: fw.elf
	avr-objcopy -j .data -j .text -O ihex $< $@

burn: fw.hex
	 ./micronucleus fw.hex
