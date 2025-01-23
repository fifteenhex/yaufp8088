; kate: syntax Intel x86 (NASM)
[bits 16]

%include "../common/pit_8253.S"

section .text

global func_pit_wait
global tickinthandler

func_pit_wait:
	push ax

	; counter1, mode0, counter ~100ms
	mov al, ((0x1 << PIT_CTRL_COUNTER_SHIFT) | PIT_CTRL_READLOAD_LSBMSB)
	out IOPORT_PIT_CTRL, al
	mov al, 0x24
	out IOPORT_PIT_CNT1, al
	mov al, 0xf4
	out IOPORT_PIT_CNT1, al

	; Wait for the int
	hlt

	pop ax
	ret

tickinthandler:
	push ax
	pic_eoi
	pop ax
	iret

section .bss
ticks_l: resw 1
ticks_h: resw 1
