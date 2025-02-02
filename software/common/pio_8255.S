; kate: syntax Intel x86 (NASM)

%define IOPORT_PIO		0x00
%define IOPORT_PIO_PORTA	IOPORT_PIO + 0
%define IOPORT_PIO_PORTB	IOPORT_PIO + 1
%define IOPORT_PIO_PORTC	IOPORT_PIO + 2
%define IOPORT_PIO_CTRL		IOPORT_PIO + 3

%define PIO_BIT_SET     (1)
%define PIO_BIT_CLR     (0)
%define PIO_BIT_SHIFT   1
