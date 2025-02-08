; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/memmap.S"
%include "../common/usart_8251.S"
%include "../common/pic_8259.S"
%include "util.h"
%include "interrupts.h"
%include "interrupts_util.h"

%include "tick.h"

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

%macro print_label_hex_value 2
	mov bx, %1
	usart_puts
	xor ax,ax
	mov al, BYTE [es:%2]
	call printhex
	mov bx, str_newline
	usart_puts
%endmacro

%macro print_label_pop_hex_value 1
	mov bx, %1
	usart_puts
	pop ax
	call printhex
	mov bx, str_newline
	usart_puts
%endmacro

nmihandler:
	pic_stack_regs
	push di
	push si
	push es
	push ss
	push ds
	push cs

	mov bx, str_nmi
	usart_puts

	print_label_pop_hex_value str_reg_cs
	print_label_pop_hex_value str_reg_ds
	print_label_pop_hex_value str_reg_ss
	print_label_pop_hex_value str_reg_es
	print_label_pop_hex_value str_reg_si
	print_label_pop_hex_value str_reg_di
	
	interrupts_dumppic 

	print_label_hex_value str_tick_enabled,tick_enabled
	print_label_hex_value str_tick_ticks,ticks

	jmp $
;    iret
    
section .data
str_nmi: db `\n\r-- NMI --\n\r`, 0
str_reg_cs: db `cs: `, 0
str_reg_ds: db `ds: `, 0
str_reg_ss: db `ss: `, 0
str_reg_es: db `es: `, 0
str_reg_si: db `si: `, 0
str_reg_di: db `di: `, 0
str_tick_enabled: db `tick enabled: `, 0
str_tick_ticks: db `ticks: `, 0

