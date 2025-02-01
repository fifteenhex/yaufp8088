; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/pio_8255.S"
%include "tick.h"

%define IOPORT_DISPLAY_INDEX	0x40
%define IOPORT_DISPLAY_DATA		0x42
%define DISPLAY_RESET		0
%define DISPLAY_BACKLIGHT	1

%define ILI9225_REG_DRIVEROPTCTRL	0x01
%define ILI9225_REG_ENTRYMODE		0x03
%define ILI9225_REG_DISPCTRL_1		0x07
%define ILI9225_REG_POWERCTRL_1		0x10
%define ILI9225_REG_POWERCTRL_2		0x11
%define ILI9225_REG_POWERCTRL_3		0x12
%define ILI9225_REG_POWERCTRL_4		0x13
%define ILI9225_REG_POWERCTRL_5		0x14
%define ILI9225_REG_RAMADDRESSSET_1	0x20
%define ILI9225_REG_RAMADDRESSSET_2	0x21
%define ILI9225_REG_GRAM			0x22
%define ILI9225_REG_VSCROLLCTRL_1	0x31
%define ILI9225_REG_VSCROLLCTRL_2	0x32
%define ILI9225_REG_GAMMACTRL_1		0x50
%define ILI9225_REG_GAMMACTRL_2		0x51
%define ILI9225_REG_GAMMACTRL_3		0x52
%define ILI9225_REG_GAMMACTRL_4		0x53
%define ILI9225_REG_GAMMACTRL_5		0x54
%define ILI9225_REG_GAMMACTRL_6		0x55
%define ILI9225_REG_GAMMACTRL_7		0x56
%define ILI9225_REG_GAMMACTRL_8		0x57
%define ILI9225_REG_GAMMACTRL_9		0x58
%define ILI9225_REG_GAMMACTRL_10	0x59

%define WIDTH 176
%define HEIGHT 220
%define FBSZ (WIDTH * HEIGHT)

section .text

global func_display_init

%macro display_set_index 1
	mov al, %1
	out IOPORT_DISPLAY_INDEX, al
%endmacro

%macro display_write_data 1
	mov ax, ((%1 << 8) & 0xff00) | ((%1 >> 8) & 0xff)
	out IOPORT_DISPLAY_DATA, ax
%endmacro

%macro display_write_reg 2
	display_set_index %1
	display_write_data %2
%endmacro

%macro display_clear 0
	display_set_index ILI9225_REG_GRAM
	mov cx, FBSZ
%%zzz0:
	display_write_data 0
	loop %%zzz0
%endmacro

func_display_init:
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
	display_write_reg ILI9225_REG_DRIVEROPTCTRL,0x011C
	
	display_write_reg 0x02,0x0100
	display_write_reg ILI9225_REG_ENTRYMODE,0x1010; 0x1030
	display_write_reg 0x07,0x0000
	display_write_reg 0x08,0x0808
	display_write_reg 0x0b,0x1100
	display_write_reg 0x0c,0x0000
	display_write_reg 0x0f,0x0D01
	display_write_reg 0x15,0x0020
	display_write_reg ILI9225_REG_RAMADDRESSSET_1,0x0000
	display_write_reg ILI9225_REG_RAMADDRESSSET_2,0x0000

	display_write_reg 0x30,0x0000
	display_write_reg ILI9225_REG_VSCROLLCTRL_1,0x00DB
	display_write_reg ILI9225_REG_VSCROLLCTRL_2,0x0000
	display_write_reg 0x33,0x0000

	display_write_reg 0x34,0x00DB
	display_write_reg 0x35,0x0000
	display_write_reg 0x36,0x00AF
	display_write_reg 0x37,0x0000
	display_write_reg 0x38,0x00DB
	display_write_reg 0x39,0x0000

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

	display_clear

	display_write_reg ILI9225_REG_RAMADDRESSSET_1,0x0000
	display_write_reg ILI9225_REG_RAMADDRESSSET_2,0x0000
	display_set_index ILI9225_REG_GRAM
	mov cx, 0x3020
zzz0:
	display_write_data 0xf800
	sub cx, 1
	jne zzz0

	; turn backlight on
	mov al, 0xff
	out IOPORT_PIO_PORTC, al

	pop cx
	pop ax
	ret
