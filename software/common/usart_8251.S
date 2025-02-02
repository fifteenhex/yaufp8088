; kate: syntax Intel x86 (NASM)

%define IOPORT_USART		0x20
%define IOPORT_USART_DATA	(IOPORT_USART + 0)
%define IOPORT_USART_CMD	(IOPORT_USART + 1)

%define USART_CMD_TXEN		1
%define USART_CMD_DTR		(1 << 1)
%define USART_CMD_RXEN		(1 << 2)
%define USART_CMD_SBRK		(1 << 3)
%define USART_CMD_ER		(1 << 4)
%define USART_CMD_RTS		(1 << 5)
%define USART_CMD_IR		(1 << 6)
%define USART_CMD_EH		(1 << 7)

%define USART_STATUS_TXRDY	(1)
%define USART_STATUS_TXE	(1 << 2)

%macro usart_putch 0
        out IOPORT_USART_DATA, al
%%busy:
        in al, IOPORT_USART_CMD
        and al, USART_STATUS_TXRDY
        jz %%busy
%endmacro

%macro _usart_getch 0
        in al, IOPORT_USART_DATA
%endmacro

%macro usart_puts 0
%%nextch:
        mov al, [bx]
        cmp al, 0
        je %%waitforempty
        usart_putch
        add bx, 1
        jmp %%nextch
%%waitforempty:
        in al, IOPORT_USART_CMD
        and al, USART_STATUS_TXE
        jz %%waitforempty
%endmacro
