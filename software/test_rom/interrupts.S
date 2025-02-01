; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/pic_8259.S"
%include "../common/usart_8251.S"
%include "../common/memmap.S"
%include "../common/interrupts.S"

section .text

extern str_newline
extern printhex

; Interrtupts init
global func_interrupts_init
func_interrupts_init:
	push es

_pic_setup:
	mov al, (PIC_ICW1_SINGLE | PIC_ICW1_IC4 | PIC_ICW1)
	out IOPORT_PIC_NA0, al
	mov al, INTERRUPTS_PIC_VECT_BASE
	out IOPORT_PIC_A0, al
	mov al, (PIC_ICW4_UPM)
	out IOPORT_PIC_A0, al

	; Mask all
	pic_mask_all

_inttablefill:
	; point es at the SRAM
	mov ax, 0
	mov es, ax
	;
	mov ax, 0x400
	mov di, 0
	mov si, WORD badint_0
	; put the segment in bx
	mov bx, MEMMAP_SEG_FLASH
_inttablefill_next:
	cmp ax, di
	je _inttablefill_exit
	mov [es:di], si
	add di, 2
	mov [es:di], bx
	add di, 2

	add si, 8

	jmp _inttablefill_next
_inttablefill_exit:

	pop es
	ret

%macro print_pic_reg 1
	mov bx, %1
	usart_puts
	pop ax
	call printhex
	mov bx, str_newline
	usart_puts
%endmacro

global badint_0

%assign i 0
%rep    256
	align 8
badint_%+i:
	push ax
	mov ax, i
	jmp _badinthandler
%assign i i+1
%endrep
badinthandler:
	mov ax, 0xffff
_badinthandler:
	push bx
	call printhex

	; push the PIC registers onto the stack
	mov ax, 0
	pic_read_isr
	push ax
	pic_read_irr
	push ax
	pic_read_imr
	push ax

	; End the interrupt and mask everything
	pic_eoi
	pic_mask_all

	; Print out registers
	mov bx, str_newline
	usart_puts

	mov bx, str_canihazirq
	usart_puts

	; print the PIC IMR
	print_pic_reg str_badint_imr
	; print the PIC IRR
	print_pic_reg str_badint_irr
	; print the PIC ISR
	print_pic_reg str_badint_isr


	mov bx, str_newline
	usart_puts

	pop bx
	pop ax

	iret

global divzerointhandler
divzerointhandler:
	mov bx, str_divzero
	usart_puts
	iret

section .data

str_badint_imr:
	db `PIC IMR:`, 0
str_badint_irr:
	db `PIC IRR:`, 0
str_badint_isr:
	db `PIC ISR:`, 0
str_divzero:
	db `Divide by zero\n\r`, 0
str_canihazirq:
	db `Wrong IRQ!\n\r`, 0
