%define IOPORT_PIC		0x30
%define IOPORT_PIC_NA0		(IOPORT_PIC + 0)
%define IOPORT_PIC_A0		(IOPORT_PIC + 1)

%define PIC_ICW1		(1 << 4)
%define PIC_ICW1_IC4		1
%define PIC_ICW1_SINGLE		(1 << 1)

%define PIC_ICW4_UPM		1

%define PIC_OCW2_SEOI		(1 << 6)
%define PIC_OCW2_EOI		(1 << 5)

%define PIC_OCW3		(1 << 3)
%define PIC_OCW3_RR		(1 << 1)
%define PIC_OCW3_RIS		1

%macro pic_mask_all 0
	mov al, 0xff
	out IOPORT_PIC_A0, al
%endmacro

%macro pic_unmask_all 0
	mov al, 0
	out IOPORT_PIC_A0, al
%endmacro

%macro pic_unmask 1
	mov al, ~(1 << %1)
;	mov al, 0xfd
	out IOPORT_PIC_A0, al
%endmacro

%macro pic_eoi 0
	mov al, PIC_OCW2_EOI
	out IOPORT_PIC_NA0, al
%endmacro

%macro pic_read_imr 0
	in al, IOPORT_PIC_A0
%endmacro

%macro pic_read_irr 0
	mov al,	(PIC_OCW3 | PIC_OCW3_RR)
	out IOPORT_PIC_NA0, al
	in al, IOPORT_PIC_NA0
%endmacro

%macro pic_read_isr 0
	mov al,	(PIC_OCW3 | PIC_OCW3_RR | PIC_OCW3_RIS)
	out IOPORT_PIC_NA0, al
	in al, IOPORT_PIC_NA0
%endmacro
