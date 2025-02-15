; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/pit_8253.S"
%include "../common/pic_8259.S"
%include "../common/memmap.S"
%include "../common/interrupts.S"
%include "../common/templates.h"

%include "tick_defs.h"

%define TICK_PIT_CHAN	1
%define TICK_PIC_IRQ	1
%define TICK_DIVIDER	((TICK_INPUT_HZ/1000) * TICK_PERIOD_MS)

section .text

%macro pit_arm 0
	; counter1, mode0, counter, period ~TICK_PERIOD_MS
	mov al, ((TICK_PIT_CHAN << PIT_CTRL_COUNTER_SHIFT) | PIT_CTRL_READLOAD_LSBMSB)
	out IOPORT_PIT_CTRL, al
	mov al, (TICK_DIVIDER & 0xff)
	out IOPORT_PIT_CNT1, al
	mov al, ((TICK_DIVIDER >> 8) & 0xff)
	out IOPORT_PIT_CNT1, al
%endmacro

GLOBAL_FUNC tick_init
	pushf
	cli

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
	popf
	ret
GLOBAL_FUNC_END

GLOBAL_FUNC tick_get
	mov ax, [es:ticks]
	ret
GLOBAL_FUNC_END

GLOBAL_FUNC tick_once
	pit_arm
	ret
GLOBAL_FUNC_END

GLOBAL_FUNC tick_start
	push ax

	mov [es:tick_enabled], BYTE 1

	pic_unmask TICK_PIC_IRQ

	pit_arm

	pop ax
	ret
GLOBAL_FUNC_END

GLOBAL_FUNC pit_wait
	push ax
	; load the current ticks value
	mov ax, WORD [es:ticks]

_pit_wait:
	; Wait for an int, hopefully the tick int
	hlt
	; Has the ticks count changed?
	cmp ax, WORD [es:ticks]
	; Nope, must have been something else
	je _pit_wait

	pop ax
	ret
GLOBAL_FUNC_END

global func_tick_stop
func_tick_stop:
	push ax

	pit_go_low TICK_PIT_CHAN
	
	pic_mask TICK_PIC_IRQ

	mov [es:tick_enabled], BYTE 0

	pop ax
	ret

tickinthandler:
	push ax
	
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
	pic_seoi 1
	pop ax
	iret

section .bss
global tick_enabled
tick_enabled:
	resb 1
global ticks
ticks:
	resw 1
