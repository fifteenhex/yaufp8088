; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/pio_8255.S"
%include "../common/templates.h"
%include "../common/string.S"
%include "tick.h"

%include "display_util.h"

section .text

GLOBAL_FUNC display_init
	push ax
	push cx

	; do reset
	mov al, 0xfd
	out IOPORT_PIO_PORTC, al
	call func_pit_wait
	
	mov al, 0xfc
	out IOPORT_PIO_PORTC, al
	call func_pit_wait
	
	mov al, 0xfd
	out IOPORT_PIO_PORTC, al
	call func_pit_wait
	
	;
	display_write_reg ILI9225_REG_POWERCTRL_1,0x0000
	display_write_reg ILI9225_REG_POWERCTRL_2,0x0000
	display_write_reg ILI9225_REG_POWERCTRL_3,0x0000
	display_write_reg ILI9225_REG_POWERCTRL_4,0x0000
	display_write_reg ILI9225_REG_POWERCTRL_5,0x0000
	call func_pit_wait
	
	display_write_reg ILI9225_REG_POWERCTRL_2,0x0018 
	display_write_reg ILI9225_REG_POWERCTRL_3,0x6121 
	display_write_reg ILI9225_REG_POWERCTRL_4,0x006F 
	display_write_reg ILI9225_REG_POWERCTRL_5,0x495F 
	display_write_reg ILI9225_REG_POWERCTRL_1,0x0800
	call func_pit_wait
	display_write_reg ILI9225_REG_POWERCTRL_2,0x103B 
	call func_pit_wait
	;| ILI9225_DRIVEROPTCTRL_SM 
	display_write_reg ILI9225_REG_DRIVEROPTCTRL,(0x001c | ILI9225_DRIVEROPTCTRL_GS);0x011C
	
	display_write_reg 0x02,0x0100
	display_write_reg ILI9225_REG_ENTRYMODE,(ILI9225_ENTRYMODE_BGR | ILI9225_ENTRYMODE_INDH | ILI9225_ENTRYMODE_INDV)
	display_write_reg 0x07,0x0000
	display_write_reg 0x08,0x0808
	display_write_reg 0x0b,0x1100
	display_write_reg 0x0c,0x0000
	display_write_reg 0x0f,0x0D01
	display_write_reg 0x15,0x0020
	display_write_reg ILI9225_REG_RAMADDRESSSET_1,0x0000
	display_write_reg ILI9225_REG_RAMADDRESSSET_2,0x0000

	display_write_reg ILI9225_REG_GATESCANCTRL,0x0000
	display_write_reg ILI9225_REG_VSCROLLCTRL_1,0x00DB
	display_write_reg ILI9225_REG_VSCROLLCTRL_2,0x0000
	display_write_reg ILI9225_REG_VSCROLLCTRL_3,0x0000

	display_write_reg 0x34,0x00DB
	display_write_reg 0x35,0x0000

	display_set_window_h 0x0000,0x00AF
	display_set_window_v 0x0000,0x00DB

	display_write_reg ILI9225_REG_GAMMACTRL_1,0x0000
	display_write_reg ILI9225_REG_GAMMACTRL_2,0x0808
	display_write_reg ILI9225_REG_GAMMACTRL_3,0x080A
	display_write_reg ILI9225_REG_GAMMACTRL_4,0x000A
	display_write_reg ILI9225_REG_GAMMACTRL_5,0x0A08
	display_write_reg ILI9225_REG_GAMMACTRL_6,0x0808
	display_write_reg ILI9225_REG_GAMMACTRL_7,0x0000
	display_write_reg ILI9225_REG_GAMMACTRL_8,0x0A00
	display_write_reg ILI9225_REG_GAMMACTRL_9,0x0710
	display_write_reg ILI9225_REG_GAMMACTRL_10,0x0710

	display_write_reg ILI9225_REG_DISPCTRL_1,0x0012
	call func_pit_wait
	
	display_write_reg ILI9225_REG_DISPCTRL_1,0x1017

	xor ax, ax
	call func_display_fill_screen

	display_set_index ILI9225_REG_GRAM

	mov cx, 0x3020
rloop:
	display_write_data 0xf800
	loop rloop

	mov cx, 0x3020
gloop:
	display_write_data 0x07e0
	loop gloop

	mov cx, 0x3020
bloop:
	display_write_data 0x001f
	loop bloop

	; turn backlight on
	mov al, 0xff
	out IOPORT_PIO_PORTC, al

	;display_set_partial_drv 10,30

	;display_set_verticalscroll_start_end 0, 32
	;display_set_verticalscroll_amount 31
	
	pop cx
	pop ax
	ret

; ax - fill value
; cx - fill length in blocks of 64
GLOBAL_FUNC display_fill_rect
	push dx
	mov dx, ax
	display_set_index ILI9225_REG_GRAM
	mov ax, dx

	mov dx,IOPORT_DISPLAY_DATA
	outfill_blk_word_64

	pop dx
	ret

; fill value in ax
GLOBAL_FUNC display_fill_screen
	mov cx, ax
	display_write_reg ILI9225_REG_RAMADDRESSSET_1,0x0000
	display_write_reg ILI9225_REG_RAMADDRESSSET_2,0x0000
	mov ax, cx
	mov cx, (FBSZ / 64)
	jmp func_display_fill_rect

