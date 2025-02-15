%define INTERRUPTS_PIC_VECT_BASE	0x80
%define INTERRUPTS_PIC_IVT_BASE		(INTERRUPTS_PIC_VECT_BASE * 4)

%define INTERRUPTS_PIC_IVT_IR0		((INTERRUPTS_PIC_VECT_BASE + 0) * 4)
%define INTERRUPTS_PIC_IVT_IR1		((INTERRUPTS_PIC_VECT_BASE + 1) * 4)
%define INTERRUPTS_PIC_IVT_IR2		((INTERRUPTS_PIC_VECT_BASE + 2) * 4)
%define INTERRUPTS_PIC_IVT_IR3		((INTERRUPTS_PIC_VECT_BASE + 3) * 4)
%define INTERRUPTS_PIC_IVT_IR4		((INTERRUPTS_PIC_VECT_BASE + 4) * 4)
%define INTERRUPTS_PIC_IVT_IR5		((INTERRUPTS_PIC_VECT_BASE + 5) * 4)
%define INTERRUPTS_PIC_IVT_IR6		((INTERRUPTS_PIC_VECT_BASE + 6) * 4)
%define INTERRUPTS_PIC_IVT_IR7		((INTERRUPTS_PIC_VECT_BASE + 7) * 4)
