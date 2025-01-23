all: reset.o

reset.o: reset.S
	nasm -wall -g -felf -o $@ $<
