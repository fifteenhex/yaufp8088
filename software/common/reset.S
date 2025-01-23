; kate: syntax Intel x86 (NASM)
[bits 16]

%include "../common/debug.S"
%include "../common/memmap.S"

global _main

section .reset exec
_reset:
; Signal that reset has happened
	mov al, 0x33
	out IOPORT_DBG, al
; Set DS to the start of ROM + 32K
	mov ax, MEMMAP_SEG_FLASH + (0x8000 >> 4)
	mov ds, ax
; Set CS to the start of ROM and jump there
	jmp MEMMAP_SEG_FLASH:0000
