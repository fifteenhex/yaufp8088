; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/pit_8253.S"
%include "tick.h"

%define BUZZER_PIT_CHAN	2

section .text

%macro stop_bip 0
	pit_go_low BUZZER_PIT_CHAN
%endmacro

%macro do_bip 0
	mov al, ((BUZZER_PIT_CHAN << PIT_CTRL_COUNTER_SHIFT) | PIT_CTRL_READLOAD_LSBMSB | (0x3 << PIT_CTRL_MODE_SHIFT))
	out IOPORT_PIT_CTRL, al
	mov al, 0xc9
	out IOPORT_PIT_CNT2, al
	mov al, 0x01
	out IOPORT_PIT_CNT2, al
	call func_pit_wait
	stop_bip
%endmacro

global func_beep_boop
func_beep_boop:
	do_bip

	call func_pit_wait

	do_bip

	ret
