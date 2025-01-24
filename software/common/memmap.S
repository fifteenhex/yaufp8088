; kate: syntax Intel x86 (NASM)
%define MEMMAP_SEG_FLASH	0xe000
%define MEMMAP_SEG_STACK	(0xf000 >> 4)
%define MEMMAP_SEG_IVT      0x0

; BSS can be right after the vector table
%define MEMMAP_SEG_BSS      (0x400 >> 4)

