all: rom.img rom_512k.img code.bin.dbg

.PHONY: common
common:
	$(MAKE) -C ../common

start.o: start.S ../common/reset.S ../common/pic_8259.S ../common/usart_8251.S
	nasm -wall -fas86 -o $@ $<

code.bin.dbg: start.o
	ld86 -M -0 -m -o $@ $^

code.bin: start.o
	ld86 -d -0 -o $@ $^

rom.img: rom.cfg common code.bin
	genimage --config $< --inputpath ./ --outputpath ./

rom_512k.img: rom_512k.cfg rom.img
	genimage --config $< --inputpath ./ --outputpath ./


.PHONY: burn
burn: rom_512k.img
	minipro -p SST39SF040 -w $<
