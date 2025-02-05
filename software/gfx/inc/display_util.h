; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off

%define IOPORT_DISPLAY_INDEX	0x40
%define IOPORT_DISPLAY_DATA		0x42
%define DISPLAY_RESET		0
%define DISPLAY_BACKLIGHT	1

%define ILI9225_REG_DRIVEROPTCTRL	0x01
%define ILI9225_DRIVEROPTCTRL_SS	(1 << 8)
%define ILI9225_DRIVEROPTCTRL_GS	(1 << 9)
%define ILI9225_DRIVEROPTCTRL_SM	(1 << 10)
%define ILI9225_REG_ENTRYMODE		0x03
%define ILI9225_ENTRYMODE_AM		(1 << 3)
%define ILI9225_ENTRYMODE_BGR		(1 << 12)
%define ILI9225_ENTRYMODE_INDH		(1 << 4)
%define ILI9225_ENTRYMODE_INDV		(1 << 5)
%define ILI9225_REG_DISPCTRL_1		0x07
%define ILI9225_REG_POWERCTRL_1		0x10
%define ILI9225_REG_POWERCTRL_2		0x11
%define ILI9225_REG_POWERCTRL_3		0x12
%define ILI9225_REG_POWERCTRL_4		0x13
%define ILI9225_REG_POWERCTRL_5		0x14
%define ILI9225_REG_RAMADDRESSSET_1	0x20
%define ILI9225_REG_RAMADDRESSSET_2	0x21
%define ILI9225_REG_GRAM			0x22
%define ILI9225_REG_GATESCANCTRL    0x30
%define ILI9225_REG_VSCROLLCTRL_1	0x31
%define ILI9225_REG_VSCROLLCTRL_2	0x32
%define ILI9225_REG_VSCROLLCTRL_3	0x33
%define ILI9225_REG_PARTIALDRVPOS1	0x34
%define ILI9225_REG_PARTIALDRVPOS2	0x35
%define ILI9225_REG_HORWINDOWADDR1	0x36
%define ILI9225_REG_HORWINDOWADDR2	0x37
%define ILI9225_REG_VERWINDOWADDR1	0x38
%define ILI9225_REG_VERWINDOWADDR2	0x39
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

%macro display_set_window_h 2
	display_write_reg ILI9225_REG_HORWINDOWADDR1,%2
	display_write_reg ILI9225_REG_HORWINDOWADDR2,%1
%endmacro

%macro display_set_window_v 2
	display_write_reg ILI9225_REG_VERWINDOWADDR1,%2
	display_write_reg ILI9225_REG_VERWINDOWADDR2,%1
%endmacro

%macro display_set_partial_drv 2
	display_write_reg ILI9225_REG_PARTIALDRVPOS1,%2
	display_write_reg ILI9225_REG_PARTIALDRVPOS2,%1
%endmacro

%macro display_set_verticalscroll_start_end 2
	display_write_reg ILI9225_REG_VSCROLLCTRL_1,%2
	display_write_reg ILI9225_REG_VSCROLLCTRL_2,%1
%endmacro

%macro display_set_verticalscroll_amount 1
	display_write_reg ILI9225_REG_VSCROLLCTRL_3,%1
%endmacro
