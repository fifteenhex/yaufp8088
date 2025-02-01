; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off

%define IOPORT_PIT				0x10
%define IOPORT_PIT_CNT0			IOPORT_PIT + 0
%define IOPORT_PIT_CNT1			IOPORT_PIT + 1
%define IOPORT_PIT_CNT2			IOPORT_PIT + 2
%define IOPORT_PIT_CTRL			IOPORT_PIT + 3

%define PIT_CTRL_COUNTER_SHIFT	6
%define PIT_CTRL_READLOAD_SHIFT 4
%define PIT_CTRL_READLOAD_LSBMSB (0x3 << PIT_CTRL_READLOAD_SHIFT)
%define PIT_CTRL_MODE_SHIFT		1

%macro pit_go_low 1
	; set mode 0 so the output is low but never write the counter so it stays that way
	mov al, ((%1 << PIT_CTRL_COUNTER_SHIFT) | PIT_CTRL_READLOAD_LSBMSB)
	out IOPORT_PIT_CTRL, al
%endmacro
