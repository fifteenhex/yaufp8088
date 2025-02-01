; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/memmap.S"
%include "../common/usart_8251.S"
%include "../common/pic_8259.S"
%include "util.h"
%include "interrupts.h"
%include "interrupts_util.h"

section .text

extern divzerointhandler

global func_monitor_init
func_monitor_init:
	push es
	push bx

	; Point ES at the IVT
	mov bx, MEMMAP_SEG_IVT
	mov es, bx

	; insert divide by zero handler
	mov bx, 0
	mov [es:bx], WORD divzerointhandler

	; insert NMI handler
	mov bx, (2 * 4)
	mov [es:bx], WORD nmihandler

	pop bx
	pop es
    ret

nmihandler:
	pic_stack_regs

	mov bx, str_nmi
	usart_puts

	interrupts_dumppic

	jmp $
;    iret
    
section .data
str_nmi: db `\n\r-- NMI --\n\r`, 0

