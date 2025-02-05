.PHONY: all
all: textrender.o

textrender.o: textrender.S XGA_8x16.bin
	nasm -wall -g -felf -o $@ $<

XGA_8x16.bin:
	wget "https://github.com/spacerace/romfont/raw/refs/heads/master/font-bin/XGA_8x16.bin"
