[bits 16]

global _main
extern _c_entry

section .text
_main:
	jmp $

; Checking if this'll get linked
_dummy:
	call _c_entry

