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

	mov ax, (0xf000 >> 4)
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

divzerointhandler:
	mov bx, str_divzero
	usart_puts
	iret

tickinthandler:
	push ax
	pic_eoi
	pop ax
	iret

nmihandler:
	iret

uartrxinthandler:
	push ax
	_usart_getch
;	call printhex
	pic_eoi
	pop ax
	iret

uarttxinthandler:
	push ax
	pic_eoi
	pop ax
	iret

str_badint_imr:
	db `PIC IMR:`, 0
str_badint_irr:
	db `PIC IRR:`, 0
str_badint_isr:
	db `PIC ISR:`, 0

%macro print_pic_reg 1
	mov bx, %1
	usart_puts
	pop ax
	call printhex
	mov bx, str_newline
	usart_puts
%endmacro

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

func_pit_wait:
	push ax

	; counter1, mode0, counter ~100ms
	mov al, ((0x1 << PIT_CTRL_COUNTER_SHIFT) | PIT_CTRL_READLOAD_LSBMSB)
	out IOPORT_PIT_CTRL, al
	mov al, 0x24
	out IOPORT_PIT_CNT1, al
	mov al, 0xf4
	out IOPORT_PIT_CNT1, al

	; Wait for the int
	hlt

	pop ax
	ret

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
str_divzero:
	db `Divide by zero\n\r`, 0
str_canihazirq:
	db `Wrong IRQ!\n\r`, 0
str_testloop:
	db `Doing test loop...\n\r`, 0
str_testloopinner:
	db `\n\r loop \n\r`, 0
str_alivemsg:
	db `.\n\r`, 0
str_newline:
	db `\n\r`, 0

hexprefix:
	db "0x",0
hextbl:
	db "0123456789abcdef"
