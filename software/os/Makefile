all: os.a

console.o: console.S
	nasm -wall -g -i ../gfx/inc -felf -o $@ $<

interrupts.o: interrupts.S
	nasm -wall -g -i ./inc -felf -o $@ $<

monitor.o: monitor.S ../common/includes.stamp
	nasm -wall -g -i ./inc -i ../time/inc -felf -o $@ $<

util.o: util.S
	nasm -wall -g -felf -o $@ $<

eventloop.o: eventloop.S
	nasm -wall -g -i ./inc -i ../time/inc -i ../gfx/inc -felf -o $@ $<

shell.o: shell.S
	nasm -wall -g -felf -o $@ $<

os.a: console.o interrupts.o monitor.o util.o eventloop.o shell.o
	ar rs $@ $^

