; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/pic_8259.S"
%include "../common/memmap.S"
%include "../common/interrupts.S"

%define IOPORT_RTC_BASE			0x50
%define IOPORT_RTC_S1			IOPORT_RTC_BASE
%define IOPORT_RTC_S10			(IOPORT_RTC_BASE + 0x1)
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
	ret

global func_rtc_readsec
func_rtc_readsec:
	cli
	push cx
	xor ax, ax
	
	;rtc_wait_busy
	
	;;in al, IOPORT_RTC_S10
	;mov ah, al
	;in al, IOPORT_RTC_CONTROL_F
	
	in al, IOPORT_RTC_S10
	and al, 0xf
	mov ah, al
	mov cl, 4
	shl ax, cl
	in al, IOPORT_RTC_S1
	and al, 0xf
	or al, ah
	and ax, 0xff
	
	pop cx
	sti
	ret

global func_rtc_enableint
func_rtc_enableint:
	pic_unmask 7
	ret

rtc_inthandler:
	push ax
	mov al, 0
	out IOPORT_RTC_CONTROL_D, al
	pic_seoi 7
	pop ax
	iret
