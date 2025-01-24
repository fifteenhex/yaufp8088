; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/pit_8253.S"
%include "../common/pic_8259.S"
%include "../common/memmap.S"
%include "../common/interrupts.S"

section .text

global func_pit_wait
global tickinthandler
global func_tick_init
global func_tick_start
global func_tick_get
global func_tick_stop

%macro pit_arm 0
	; counter1, mode0, counter ~100ms
	mov al, ((0x1 << PIT_CTRL_COUNTER_SHIFT) | PIT_CTRL_READLOAD_LSBMSB)
	out IOPORT_PIT_CTRL, al
	mov al, 0x24
	out IOPORT_PIT_CNT1, al
	mov al, 0xf4
	out IOPORT_PIT_CNT1, al
%endmacro

func_tick_init:
	push es
	push bx

	mov [es:ticks], WORD 0

	; Point ES at the IVT
	mov bx, MEMMAP_SEG_IVT
	mov es, bx
	; insert tick handler
	mov bx, INTERRUPTS_PIC_IVT_IR1
	mov [es:bx], WORD tickinthandler

	pop bx
	pop es
	ret

func_tick_get:
	mov ax, [es:ticks]
	ret

func_tick_start:
	push ax
	pit_arm
	mov [es:tick_enabled], BYTE 1
	pop ax
	ret

func_tick_stop:
	mov [es:tick_enabled], BYTE 0
	ret

func_pit_wait:
	; Wait for the int
	hlt

	ret

tickinthandler:
	push ax
	add [es:ticks], WORD 1
	pic_eoi
	cmp [es:tick_enabled], BYTE 0
	je tickinthandler_out
	pit_arm
tickinthandler_out:
	pop ax
	iret

section .bss
tick_enabled:
	resb 1
ticks:
	resw 1
