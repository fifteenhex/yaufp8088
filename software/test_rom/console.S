; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/usart_8251.S"
%include "../common/pic_8259.S"
%include "../common/memmap.S"
%include "../common/interrupts.S"

section .text

global func_console_init
func_console_init:
	push es
	push bx
	
	mov [es:console_rxhead], WORD 0
	mov [es:console_rxtail], WORD 0
	mov [es:console_txhead], WORD 0
	mov [es:console_txtail], WORD 0

	; Point ES at the IVT
	mov bx, MEMMAP_SEG_IVT
	mov es, bx
	; insert uart rx handler
	mov bx, INTERRUPTS_PIC_IVT_IR2
	mov [es:bx], WORD console_uart_rx_inthandler

	; insert uart tx handler
	mov bx, INTERRUPTS_PIC_IVT_IR5
	mov [es:bx], WORD console_uart_tx_inthandler
	
	pop es
	pop bx
	ret

global func_console_availablechars
func_console_availablechars:
	push bx
	push cx
	xor ax, ax

	mov bl, [es:console_rxhead]
	mov cl, [es:console_rxtail]

	cmp bl, cl
	je func_console_availablechars_out
	mov al, 1

func_console_availablechars_out:
	pop cx
	pop bx
	ret

global func_console_getch
func_console_getch:
	push bx
	xor bx, bx

	mov bl, [es:console_rxtail]
	mov al, [es:bx + console_rxbuff]
	add bl, 1
	mov [es:console_rxtail], bl

	pop bx
	ret

console_uart_rx_inthandler:
	push ax
	push bx

	; get the char, stick it in the rx buf
	_usart_getch
	xor bx, bx
	mov bl, [es:console_rxhead]
	mov [es:bx + console_rxbuff], BYTE al

	; push rxhead forward
	add bl, 1
	mov [es:console_rxhead], bl

	; end the interrupt and go home
	pic_eoi
	pop bx
	pop ax
	iret

console_uart_tx_inthandler:
	push ax
	pic_eoi
	pop ax
	iret

section .bss
console_rxhead:
	resb 1
console_rxtail:
	resb 1
console_rxbuff:
	resb 256
console_txhead:
	resb 1
console_txtail:
	resb 1
console_txbuff:
	resb 256
