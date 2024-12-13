all: rom.out

start.o: start.S
	nasm -fas86 -o $@ $<

main.o: main.c
	bcc -0 -ansi -c -o $@ $<

rom.out.dbg: start.o main.o
	ld86 -M -0 -m -o $@ start.o main.o

rom.out: start.o main.o
	ld86 -d -0 -o $@ start.o main.o
