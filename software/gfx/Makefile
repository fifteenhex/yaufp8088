.PHONY: all
all: gfx.a

display.o: display.S
	nasm -wall -g -i ../time/inc -i ./inc -felf -o $@ $<

textrender.o: textrender.S XGA_8x16.bin
	nasm -wall -g -felf -o $@ $<

XGA_8x16.bin:
	wget "https://github.com/spacerace/romfont/raw/refs/heads/master/font-bin/XGA_8x16.bin"

gfx.a: display.o textrender.o
	ar rs $@ $^
