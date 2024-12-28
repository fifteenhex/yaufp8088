all: reset_4k.img

reset.o: reset.S
	nasm -fas86 -o $@ $<

reset.bin: reset.o
	ld86 -d -0 -o $@ $^

reset_4k.img: reset_4k.cfg reset.bin
	genimage --config $< --inputpath ./ --outputpath ./
