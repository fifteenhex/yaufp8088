; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/templates.h"

%define TEXT_COLS	22
%define TEXT_ROWS	12
%define TEXT_TOTAL	(TEXT_COLS * TEXT_ROWS)

section .text
GLOBAL_FUNC textrender_init
	push es

	mov cx, TEXT_TOTAL
_loop:
	mov [es:textrender_charmap], BYTE 'a'
	loop _loop

	pop cx
	ret

STATIC_FUNC textrender_draw_char
	ret

GLOBAL_FUNC textrender_redraw
	mov cx, TEXT_ROWS
_row:
	push cx
	mov cx, TEXT_COLS
_col:
	call func_textrender_draw_char
	loop _col
	pop cx
	loop _row

	ret

section .data
font:
	incbin "XGA_8x16.bin"
	
section .bss
textrender_charmap:
	resb TEXT_TOTAL

