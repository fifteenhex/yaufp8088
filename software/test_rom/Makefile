all: rom_512k.img

.PHONY: common
common:
	$(MAKE) -C ../common

start.o: start.S
	nasm -wall -g -felf -o $@ $<

util.o: util.S
	nasm -wall -g -felf -o $@ $<

interrupts.o: interrupts.S
	nasm -wall -g -felf -o $@ $<

console.o: console.S
	nasm -wall -g -felf -o $@ $<

tick.o: tick.S
	nasm -wall -g -felf -o $@ $<

monitor.o: monitor.S
	nasm -wall -g -felf -o $@ $<

start.elf: start.o \
	   util.o \
	   console.o \
	   interrupts.o \
	   tick.o \
	   monitor.o \
	   rom.ld common
	ld -melf_i386 --no-check-sections -T rom.ld -o $@ \
		start.o \
		interrupts.o \
		util.o \
		console.o \
		tick.o \
		monitor.o \
		../common/reset.o

start.bin: start.elf
	objcopy --gap-fill=0xff -O binary $< $@

#start.o: start.S ../common/reset.S ../common/pic_8259.S ../common/usart_8251.S
#	nasm -wall -fas86 -o $@ $<

rom_512k.img: rom_512k.cfg start.bin
	genimage --config $< --inputpath ./ --outputpath ./


.PHONY: burn
burn: rom_512k.img
	minipro -p SST39SF040 -w $<

.PHONY: disasm

disasm: start.elf
	objdump -mi386 -Maddr16,data16 -d start.elf

.PHONY:	clean
clean:
	- rm *.o
