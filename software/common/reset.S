[bits 16]

%include "../common/debug.S"

global _main

section .text
_main:
; Signal that reset has happened
	mov al, 0x33
	out IOPORT_DBG, al
; Set DS to the start of ROM
	mov ax, 0xe000
	mov ds, ax
; Set CS to the start of ROM and jump there
	jmp 0xe000:0000
