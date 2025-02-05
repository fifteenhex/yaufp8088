all: buzzer.o

buzzer.o: buzzer.S
	nasm -wall -g -i ../time/inc -felf -o $@ $<
