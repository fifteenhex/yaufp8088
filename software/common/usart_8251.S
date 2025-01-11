%define IOPORT_USART		0x20
%define IOPORT_USART_DATA	(IOPORT_USART + 0)
%define IOPORT_USART_CMD	(IOPORT_USART + 1)

%define USART_STATUS_TXRDY	(1)

%macro usart_putch 0
        out IOPORT_USART_DATA, al
%%busy:
        in al, IOPORT_USART_CMD
        and al, USART_STATUS_TXRDY
        jz %%busy
%endmacro

%macro usart_puts 0
%%nextch:
        mov al, [bx]
        cmp al, 0
        je %%exit
        usart_putch
        add bx, 1
        jmp %%nextch
%%exit:
%endmacro
