[bits 16]

global _main

section .text
_main:
	mov al, 0xaa
	out 0xf0, al
	jmp 0xe000:0000
