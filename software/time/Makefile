.PHONY: all
all: tick.o rtc.o

tick.o: tick.S ../common/includes.stamp
	nasm -wall -g -felf -o $@ $<
rtc.o: rtc.S
	nasm -wall -g -felf -o $@ $<
