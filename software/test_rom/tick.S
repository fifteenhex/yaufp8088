; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/pit_8253.S"
%include "../common/pic_8259.S"
%include "../common/memmap.S"
%include "../common/interrupts.S"

%define TICK_PIT_CHAN	1
%define TICK_PIC_IRQ	1

section .text

global func_pit_wait
global tickinthandler
global func_tick_init
global func_tick_start
global func_tick_get
global func_tick_stop

%macro pit_arm 0
	; counter1, mode0, counter ~100ms
	mov al, ((TICK_PIT_CHAN << PIT_CTRL_COUNTER_SHIFT) | PIT_CTRL_READLOAD_LSBMSB)
	out IOPORT_PIT_CTRL, al
	mov al, 0x24
	out IOPORT_PIT_CNT1, al
	mov al, 0xf4
	out IOPORT_PIT_CNT1, al
%endmacro

func_tick_init:
	push es
	push bx

	; Put the output into a known state
	pit_go_low TICK_PIT_CHAN

	mov [es:tick_enabled], BYTE 0
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

global func_tick_once
func_tick_once:
	pit_arm
	ret

func_tick_start:
	push ax

	pic_unmask TICK_PIC_IRQ

	pit_arm
	mov [es:tick_enabled], BYTE 1
	pop ax
	ret

func_tick_stop:
	pic_mask TICK_PIC_IRQ

	mov [es:tick_enabled], BYTE 0
	ret

func_pit_wait:
	; Wait for the int
	hlt

	ret

tickinthandler:
	push ax

;	pic_seoi 1
	pic_eoi
	
	; increment the tick count
	add [es:ticks], WORD 1
	cmp [es:tick_enabled], BYTE 0
	je tickinthandler_clear

	; re-arm the PIT
	pit_arm
	jmp tickinthandler_out

tickinthandler_clear:
	; Make the PIT output go low
	pit_go_low TICK_PIT_CHAN

tickinthandler_out:
	pop ax
	iret

section .bss
tick_enabled:
	resb 1
ticks:
	resw 1
