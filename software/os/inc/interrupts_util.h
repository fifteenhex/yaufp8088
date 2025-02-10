; kate: syntax Intel x86 (NASM)

%macro print_pic_reg 1
	mov bx, %1
	usart_puts
	pop ax
	call printhex
	mov bx, str_newline
	usart_puts
%endmacro

%macro interrupts_dumppic 0
	; print the PIC IMR
	print_pic_reg str_badint_imr
	; print the PIC IRR
	print_pic_reg str_badint_irr
	; print the PIC ISR
	print_pic_reg str_badint_isr
	mov bx, str_newline
	usart_puts
%endmacro
