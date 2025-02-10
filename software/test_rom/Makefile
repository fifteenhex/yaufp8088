all: rom_512k.img

.PHONY: common audio time gfx
common:
	$(MAKE) -C ../common
audio:
	$(MAKE) -C ../audio
time:
	$(MAKE) -C ../time
gfx:
	$(MAKE) -C ../gfx
	
.PHONY: ../os.a
../os.a:
	$(MAKE) -C ../os

../common/includes.stamp:
	$(MAKE) -C ../common includes.stamp

start.o: start.S
	nasm -wall -g -felf -i ../audio/inc -i ../time/inc -i ../gfx/inc -i ../os/inc -o $@ $<

util.o: util.S
	nasm -wall -g -felf -o $@ $<

OBJS=start.o

SHAREDOBJS=../common/reset.o \
	  ../audio/buzzer.o \
	  ../time/tick.o \
	  ../time/rtc.o \
	  ../gfx/display.o \
	  ../gfx/textrender.o \
	  ../os/os.a

start.elf: audio time gfx common ../os.a $(OBJS) rom.ld
	ld -melf_i386 --no-check-sections -T rom.ld -o $@ $(OBJS) $(SHAREDOBJS)

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
