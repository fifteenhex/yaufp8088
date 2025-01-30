; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/debug.S"
%include "../common/pio_8255.S"
%include "../common/pit_8253.S"
%include "../common/usart_8251.S"
%include "../common/pic_8259.S"
%include "../common/memmap.S"
%include "../common/interrupts.S"
%include "../common/string.S"
%include "console.h"
%include "tick.h"
%include "monitor.h"
%include "buzzer.h"
%include "display.h"

global _main
extern divzerointhandler
extern str_newline
extern printhex
extern badint_0
extern func_interrupts_init

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

; setup BSS
	mov ax, MEMMAP_SEG_BSS
	mov es, ax


	mov bx, str_intssetup
	usart_puts
	call func_interrupts_init
	call func_monitor_init

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

	call func_console_init
	call func_tick_init
	call func_tick_start

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

; needs interrupts,... fixme
	call func_display_init
	
	mov bx, str_testloop
	usart_puts

;;
	mov al, 0x55
	mov dl, 0
shout:
	call func_beep_boop

; banner
	mov bx, str_testloopinner
	usart_puts

; dbg port
	mov al, dl
	out IOPORT_DBG, al

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
	call func_tick_get
	call printhex

	call func_console_availablechars
	call printhex
	cmp ax, 0
	je noch
	call func_console_getch
	usart_putch
noch:

	jmp shout

test_sub:
	mov bx, str_sub
	usart_puts
	ret

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
	resb 1
