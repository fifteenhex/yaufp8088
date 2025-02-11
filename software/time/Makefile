.PHONY: all
all: time.a

.PHONY: common
common:
	$(MAKE) -C ../common

../common/includes.stamp: common
	$(MAKE) -C ../common includes.stamp

tick.o: tick.S ../common/includes.stamp
	nasm -wall -g -felf -o $@ $<

rtc.o: rtc.S
	nasm -wall -g -felf -o $@ $<

time.a: tick.o rtc.o
	ar rs $@ $^
