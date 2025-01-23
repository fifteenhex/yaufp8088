[bits 16]

%include "../common/usart_8251.S"

section .text

global printhex
; value to print in ax
printhex:
	push ax
	push bx
	push cx
	push si

	push ax
	; print the 0x bit
	mov bx, hexprefix
	usart_puts
	pop ax

	; copy value into bx
	mov bx, ax
	; cl is the number of bits to shift right
	mov cl, 12

_printhex:
	; get the current nibble
	shr ax, cl
	and ax, 0xf

	; point si at the acsii for the current nibble, load it into al
	mov si, hextbl
	add si, ax
	mov al, [si]

	; al now contains the acsii char, print it
	usart_putch

	; are we done yet?
	cmp cl, 0
	je _printhex_exit

	; restore value
	mov ax, bx
	; adjust the amount of shift
	sub cl, 4
	; do next nibble
	jmp _printhex

_printhex_exit:
	; restore si, cx, bx, ax, return
	pop si
	pop cx
	pop bx
	pop ax
	ret

section .data

hexprefix:
	db "0x",0
hextbl:
	db "0123456789abcdef"
	
global str_newline

str_newline:
	db `\n\r`, 0
	
