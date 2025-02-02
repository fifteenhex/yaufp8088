; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/pic_8259.S"
%include "../common/memmap.S"
%include "../common/interrupts.S"

%define IOPORT_RTC_BASE			0x50
%define IOPORT_RTC_S1			IOPORT_RTC_BASE
%define IOPORT_RTC_S10			(IOPORT_RTC_BASE + 0x1)
%define IOPORT_RTC_M1			(IOPORT_RTC_BASE + 0x2)
%define IOPORT_RTC_M10			(IOPORT_RTC_BASE + 0x3)
%define IOPORT_RTC_H1			(IOPORT_RTC_BASE + 0x4)
%define IOPORT_RTC_H10			(IOPORT_RTC_BASE + 0x5)
%define IOPORT_RTC_D1			(IOPORT_RTC_BASE + 0x6)
%define IOPORT_RTC_D10			(IOPORT_RTC_BASE + 0x7)
%define IOPORT_RTC_MO1			(IOPORT_RTC_BASE + 0x8)
%define IOPORT_RTC_MO10			(IOPORT_RTC_BASE + 0x9)
%define IOPORT_RTC_Y1			(IOPORT_RTC_BASE + 0xa)
%define IOPORT_RTC_Y10			(IOPORT_RTC_BASE + 0xb)
%define IOPORT_RTC_W			(IOPORT_RTC_BASE + 0xc)
%define IOPORT_RTC_CONTROL_D	(IOPORT_RTC_BASE + 0xd)
%define CONTROL_D_HOLD			(1)
%define CONTROL_D_BUSY			(1 << 1)
%define CONTROL_D_IRQFLAG		(1 << 2)
%define CONTROL_D_BUSY			(1 << 1)
%define IOPORT_RTC_CONTROL_E	(IOPORT_RTC_BASE + 0xe)
%define CONTROL_E_MASK			(1)
%define CONTROL_E_INRPTSTND		(1 << 1)
%define CONTROL_E_FIXEDPERIOD_1S (0x1 << 2)
%define IOPORT_RTC_CONTROL_F	(IOPORT_RTC_BASE + 0xf)


%macro rtc_wait_busy 0
%%wait:
	in al, IOPORT_RTC_CONTROL_D
	and al, CONTROL_D_BUSY
	jnz %%wait
%endmacro

global func_rtc_init
func_rtc_init:
	pushf

	cli

	push ax
	push es

	mov al, 0
	out IOPORT_RTC_CONTROL_F, al
	mov al, (CONTROL_E_INRPTSTND | CONTROL_E_FIXEDPERIOD_1S)
	out IOPORT_RTC_CONTROL_E, al
	mov al, 0
	out IOPORT_RTC_CONTROL_D, al
	
	;rtc_wait_busy
	
	
	; Point ES at the IVT
	mov bx, MEMMAP_SEG_IVT
	mov es, bx
	; insert rtc handler
	mov bx, INTERRUPTS_PIC_IVT_IR7
	mov [es:bx], WORD rtc_inthandler
	
	pop es
	pop ax
	popf
	ret

%macro rtc_get_bcd_pair 2
	in al, %2
	and al, 0xf
	mov ah, al
	mov cl, 4
	shl ax, cl
	in al, %1
	and al, 0xf
	or al, ah
	and ax, 0xff
%endmacro

global func_rtc_readsec
func_rtc_readsec:
	pushf
	cli
	push cx
	xor ax, ax
	
	;rtc_wait_busy
	
	;;in al, IOPORT_RTC_S10
	;mov ah, al
	;in al, IOPORT_RTC_CONTROL_F
	
	rtc_get_bcd_pair IOPORT_RTC_S1, IOPORT_RTC_S10

	pop cx
	popf
	ret

global func_rtc_readmin
func_rtc_readmin:
	pushf
	cli
	push cx
	xor ax, ax

	rtc_get_bcd_pair IOPORT_RTC_M1, IOPORT_RTC_M10
	
	pop cx
	popf
	ret

global func_rtc_wait
func_rtc_wait:
	push ax

	; load the current ints value
	mov ax, WORD [es:rtc_ints]

_rtc_wait:
	; Wait for an int, hopefully the rtc int
	hlt
	; Has the int count changed?
	cmp ax, WORD [es:rtc_ints]
	; Nope, must have been something else
	je _rtc_wait

	pop ax
	ret	

global func_rtc_enableint
func_rtc_enableint:
	pic_unmask 7
	ret

rtc_inthandler:
	push ax

	; increment the int count
	add [es:rtc_ints], WORD 1

	mov al, 0
	out IOPORT_RTC_CONTROL_D, al

	pic_seoi 7

	pop ax
	iret

section .bss
rtc_ints:
	resw 1
