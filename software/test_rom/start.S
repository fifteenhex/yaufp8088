[bits 16]

%include "../common/debug.S"
%include "../common/pio_8255.S"
%include "../common/pit_8253.S"
%include "../common/usart_8251.S"

global _main

section .text
_main:
setup_pio:
	mov al, (1 << 7)
	out IOPORT_PIO_CTRL, al

; Output (16 * 1200)Hz on counter0 for UART
setup_pit:
	mov al, (0x30 | (0x3 << PIT_CTRL_MODE_SHIFT))
	out IOPORT_PIT_CTRL, al
	mov al, 0x82
	out IOPORT_PIT_CNT0, al
	mov al, 0x00
	out IOPORT_PIT_CNT0, al

setup_usart:
; mode
	mov al, 0x4e
	out IOPORT_USART_CMD, al
; command
	mov al, 0x03
	out IOPORT_USART_CMD, al

print_banner:
	mov bx, str_banner
_print_banner_next:
	mov al, [bx]
	cmp al, 0
	je _print_banner_exit
	out IOPORT_USART_DATA, al
	add bx, 1
_print_banner_wait:
	in al, IOPORT_USART_CMD
	and al, USART_STATUS_TXRDY
	jz _print_banner_wait
	jmp _print_banner_next
_print_banner_exit:

;;
	mov al, 0x55
	mov dl, 0
shout:
; dbg port
	mov al, dl
	out IOPORT_DBG, al

; pio
	mov al, bl
	not bl
	out IOPORT_PIO_PORTC, al

; usart
;	mov al, 'a'
;	out IOPORT_USART_DATA, al

	mov ax, 0xffff
waitloop:
	cmp ax, 0
	je out
	sub ax, 1
	nop
	jmp waitloop

out:
	add dl, 1
	jmp shout

str_banner:
	db `Test ROM\n\r`, 0
