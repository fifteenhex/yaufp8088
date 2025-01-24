; kate: syntax Intel x86 (NASM)
[bits 16]

%include "../common/pit_8253.S"
%include "../common/pic_8259.S"

section .text

global func_pit_wait
global tickinthandler
global func_tick_init
global func_tick_get

func_tick_init:
	mov [es:ticks], WORD 0
	ret

func_tick_get:
	mov ax, [es:ticks]
	ret

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
	
	add [es:ticks], WORD 1
	
	pic_eoi
	pop ax
	iret

section .bss
ticks: resw 1
