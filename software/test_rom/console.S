[bits 16]

%include "../common/usart_8251.S"
%include "../common/pic_8259.S"

section .text

global uartrxinthandler
uartrxinthandler:
	push ax
	_usart_getch
;	call printhex
	pic_eoi
	pop ax
	iret

global uarttxinthandler
uarttxinthandler:
	push ax
	pic_eoi
	pop ax
	iret
