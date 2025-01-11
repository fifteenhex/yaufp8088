[bits 16]

%include "../common/debug.S"

global _main

section .text
_main:
	mov al, 0x33
	out IOPORT_DBG, al
	mov ax, 0xe000
	mov ds, ax
	jmp 0xe000:0000
