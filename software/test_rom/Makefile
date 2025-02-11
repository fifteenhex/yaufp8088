all: rom_512k.img

.PHONY: common audio
common:
	$(MAKE) -C ../common
audio:
	$(MAKE) -C ../audio

.PHONY: ../time/time.a ../os/os.a ../os/gfx.a
../time/time.a:
	$(MAKE) -C ../time
../os/os.a:
	$(MAKE) -C ../os
../gfx/gfx.a:
	$(MAKE) -C ../gfx

../common/includes.stamp:
	$(MAKE) -C ../common includes.stamp

start.o: start.S
	nasm -wall -g -felf -i ../audio/inc -i ../time/inc -i ../gfx/inc -i ../os/inc -o $@ $<

util.o: util.S
	nasm -wall -g -felf -o $@ $<

OBJS=start.o

SHAREDOBJS=../common/reset.o \
	  ../audio/buzzer.o

STATICLIBS=../time/time.a \
	   ../os/os.a \
	   ../gfx/gfx.a

start.elf: audio common $(STATICLIBS) $(OBJS) rom.ld
	ld -melf_i386 --no-check-sections -T rom.ld -o $@ $(OBJS) $(SHAREDOBJS) $(STATICLIBS)

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
