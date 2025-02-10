; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/templates.h"
%include "../common/debug.S"
%include "../common/pio_8255.S"
%include "../common/pit_8253.S"
%include "../common/usart_8251.S"
%include "../common/pic_8259.S"
%include "../common/memmap.S"
%include "../common/string.S"
%include "textrender.h"
%include "console.h"
%include "tick.h"
%include "monitor.h"
%include "buzzer.h"
%include "display.h"
%include "display_util.h"
%include "rtc.h"
%include "interrupts.h"
%include "util.h"

global _main
extern divzerointhandler
extern badint_0

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

; Install the default IVT
	mov bx, str_intssetup
	usart_puts
	call func_interrupts_init

; Install the NMI handler too
	call func_monitor_init

; Use the tick interrupt to test interrupts
	mov bx, str_intstest
	usart_puts

	call func_tick_init

	; Enable interrupts
	sti
	; Unmask tick
	pic_unmask 1
	; Set up the PIT to fire
	mov bx, str_intstest_first
	usart_puts
	call func_tick_once
	call func_pit_wait
	mov bx, str_ok
	usart_puts

	; Do it again to make sure EOI is working.
	mov bx, str_intstest_second
	usart_puts
	call func_tick_once
	call func_pit_wait
	mov bx, str_ok
	usart_puts
	
	; Disable interrupts
	cli
	
	pic_mask 1

; tick test
	mov bx, str_intstest_tick
	usart_puts
	call func_tick_start
	sti

	mov cx, 10
_tick_test_next:
	call func_pit_wait
	mov ax, '.'
	usart_putch
	loop _tick_test_next

	cli
	call func_tick_stop
	mov bx, str_ok
	usart_puts


	mov bx, str_intstest_rtc
	usart_puts
	call func_rtc_init
	call func_rtc_enableint
	sti
	call func_rtc_wait
	cli
	mov bx, str_ok
	usart_puts

; Need tick for following tests
	sti
	call func_tick_start

; buzzer
	mov bx, str_testbuzzer
	usart_puts
	call func_beep_boop
	mov bx, str_ok
	usart_puts

;display
	mov bx, str_testdisplay
	usart_puts
	call func_display_init
	mov bx, str_ok
	usart_puts

; left over inits before looping
	call func_textrender_init
	call func_console_init

; Test loop
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

	mov cx, 30
waitloop:
	mov ax, '.'
	usart_putch
	call func_pit_wait
	call func_textrender_redraw
	call func_console_enableints

	; uart console thing
	call func_console_availablechars
	cmp ax, 0
	je noch
	call func_console_getch
	mov bl, al
	usart_putch
	mov al, bl
	call func_textrender_putch
noch:
;
	
	loop waitloop

out:
	add dl, 1
	call func_tick_get
	call printhex



	call func_rtc_readmin
	call printhex
	call func_rtc_readsec
	call printhex

	;display_set_window_h (8 * 2), (8 * 3)
	;display_set_window_v (8 * 2), (8 * 3)
	;display_write_reg ILI9225_REG_RAMADDRESSSET_1,(8 * 2)
	;display_write_reg ILI9225_REG_RAMADDRESSSET_2,(8 * 2)
	;mov ax, 0xffff
	;mov cx, (8 * 8) * 2
	;call func_display_fill_rect

	jmp shout

test_sub:
	mov bx, str_sub
	usart_puts
	ret

section .data

str_banner:
	db `\n\r-- Test ROM --\n\r`, 0
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
str_intstest_first:
	db `Waiting for first PIT int... `, 0
str_intstest_second:
	db `Waiting for second PIT int... `, 0
str_intstest_tick:
	db `Testing continous tick int `, 0

str_intstest_rtc:
	db `Waiting for RTC int...`, 0

str_testbuzzer:
	db `Testing buzzer... `, 0

str_testdisplay:
	db `Testing display... `, 0

str_testloop:
	db `Doing test loop...\n\r`, 0
str_testloopinner:
	db `\n\r loop \n\r`, 0
str_alivemsg:
	db `.\n\r`, 0
str_ok:
	db ` OK!\n\r`, 0

section .bss
something:
	resb 1
