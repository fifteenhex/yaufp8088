[bits 16]

%include "../common/debug.S"
%include "../common/pio_8255.S"
%include "../common/pit_8253.S"
%include "../common/usart_8251.S"
%include "../common/pic_8259.S"
%include "../common/memmap.S"
%include "../common/interrupts.S"
%include "../common/string.S"

global _main
extern divzerointhandler
extern str_newline
extern printhex
extern badint_0
extern uartrxinthandler
extern uarttxinthandler
extern func_pit_wait
extern tickinthandler

section .text
_main:
	cli

setup_pio:
	mov al, (1 << 7)
	out IOPORT_PIO_CTRL, al

setup_pit:
; Output (16 * 1200)Hz on counter0 for UART
	mov al, (PIT_CTRL_READLOAD_LSBMSB | (0x3 << PIT_CTRL_MODE_SHIFT))
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
	mov al, (USART_CMD_RTS | USART_CMD_RXEN | USART_CMD_DTR | USART_CMD_TXEN)
	out IOPORT_USART_CMD, al

print_banner:
	mov bx, str_banner
	usart_puts

; Zero the RAM
	mov bx, str_clearing_ram
	usart_puts
	zeroblk 0x0, 0x10000

; setup the stack
_stack_setup:
	mov bx, str_stack
	usart_puts

	mov ax, MEMMAP_SEG_STACK
	mov ss, ax
	mov sp, 0x0fff
	call test_sub

; Interrtupts init
	mov bx, str_intssetup
	usart_puts

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
	je _inittablefill_exit
	mov [es:di], si
	add di, 2
	mov [es:di], bx
	add di, 2

	add si, 8

	jmp _inttablefill_next
_inittablefill_exit:

	; insert divide by zero handler
	mov di, 0
	mov [es:di], WORD divzerointhandler
	; insert NMI handler
	mov di, (2 * 4)
	mov [es:di], WORD nmihandler

	; insert tick handler
	mov di, INTERRUPTS_PIC_IVT_IR1
	mov [es:di], WORD tickinthandler
	; insert uart rx handler
	mov di, INTERRUPTS_PIC_IVT_IR2
	mov [es:di], WORD uartrxinthandler
	; insert uart tx handler
	mov di, INTERRUPTS_PIC_IVT_IR5
	mov [es:di], WORD uarttxinthandler

	mov al, (PIC_ICW1_SINGLE | PIC_ICW1_IC4 | PIC_ICW1)
	out IOPORT_PIC_NA0, al
	mov al, INTERRUPTS_PIC_VECT_BASE
	out IOPORT_PIC_A0, al
	mov al, (PIC_ICW4_UPM)
	out IOPORT_PIC_A0, al

	; Mask all
	pic_mask_all

	mov ax, 0
        pic_read_imr
        call printhex
        mov bx, str_newline
	usart_puts

; Interrtupts test
	mov bx, str_intstest
	usart_puts

        ; Unmask tick
	pic_unmask 1

	mov ax, 0
        pic_read_imr
        call printhex
        mov bx, str_newline
	usart_puts

	; Enable interrupts
	sti

	call func_pit_wait

	; Disable interrupts
	cli


; Test loop
        ; Unmask uart rx/tx
        pic_unmask 2
	pic_unmask 5

	; enable interrupts
	sti

	mov bx, str_testloop
	usart_puts

;;
	mov al, 0x55
	mov dl, 0
shout:
; banner
	mov bx, str_testloopinner
	usart_puts

; dbg port
	mov al, dl
	out IOPORT_DBG, al

; pio
	mov al, bl
	not bl
	out IOPORT_PIO_PORTC, al

	mov ax, 100
waitloop:
	cmp ax, 0
	je out
	;call func_pit_wait
	push ax
	mov ax, '.'
	usart_putch
	pop ax
	call func_pit_wait
	sub ax, 1
	jmp waitloop

out:
	add dl, 1

	jmp shout

test_sub:
	mov bx, str_sub
	usart_puts
	ret

nmihandler:
	iret

section .data

str_banner:
	db `-- Test ROM --\n\r`, 0
str_clearing_ram:
	db `Clearing SRAM\n\r`, 0
str_stack:
	db `Setting up stack and calling subroutine\n\r`, 0
str_sub:
	db `Inside subroutine\n\r`, 0
str_intssetup:
	db `Setting up interrupts\n\r`, 0
str_intstest:
	db `Testing interrupts\n\r`, 0
str_testloop:
	db `Doing test loop...\n\r`, 0
str_testloopinner:
	db `\n\r loop \n\r`, 0
str_alivemsg:
	db `.\n\r`, 0

section .bss
something:
	db
