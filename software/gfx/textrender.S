; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/templates.h"
%include "../common/string.S"

%include "../common/usart_8251.S"

%include "inc/display_util.h"

%define TEXT_COLS	22
%define TEXT_ROWS	12
%define TEXT_TOTAL	(TEXT_COLS * TEXT_ROWS)

%define TEXT_COLOUR_FG	0xffff
%define TEXT_COLOUR_BG	0x0000

section .text
GLOBAL_FUNC textrender_init
	push cx
	push si

	mov cx, TEXT_TOTAL
	mov si, textrender_charmap
_loop:
	mov [es:si], BYTE 'C'
	inc si
	loop _loop

	pop si
	pop cx
	ret

%macro textrender_draw_char_bitmap 0
	display_set_index ILI9225_REG_GRAM

	; the font is 16 rows high
	mov cl, 16
%%next:
	; clear the top of ax
	xor ah, ah
	; use si to load the current row bitmap in al
	lodsb

	; retain cx and si for the next loop
	push cx
	push si

	; calculate the bitmap pointer
	mov cl, 4
	shl ax, cl
	add ax, precomp
	mov si, ax

	; draw one row
	mov cx, 1
	mov dx, 0x42
	outblk_word_8

	; restore si and cx
	pop si
	pop cx

	loop %%next
%endmacro

STATIC_FUNC textrender_move_window_col
	xor ax, ax
	mov al, BYTE [es:textrender_drawing_col]
	mov cl, 5
	shl ax, cl
	mov bx, display_set_window_h_col_0
	add bx, ax
	jmp bx

%assign c 0
%rep TEXT_COLS
align 0x20
display_set_window_h_col_%+c:
	display_set_window_h (8 * c), ((8 * c) + 7)
	display_write_reg ILI9225_REG_RAMADDRESSSET_1,(8 * c)
	ret
%assign c c+1
%endrep

; This is a bit too fat to inline
STATIC_FUNC textrender_move_window_row
	push cx
	xor ax, ax
	mov al, BYTE [es:textrender_drawing_row]
	mov cl, 5
	shl ax, cl
	mov bx, display_set_window_v_row_0
	add bx, ax
	jmp bx

%assign r 0
%rep TEXT_ROWS
align 0x20
display_set_window_v_row_%+r:
	display_set_window_v (16 * r), ((16 * r) + 15)
	display_write_reg ILI9225_REG_RAMADDRESSSET_2, (16 * r)
	pop cx
	ret
%assign r r+1
%endrep

; al - ascii code
%macro textrender_draw_char 0
	push cx
	push si

; calculate the font base pointer
	xor ah, ah
	; shift the code over to make an offset into the font
	mov cl, 4
	shl ax, cl
	; add the base address of the font
	add ax, font
	mov si, ax

	call func_textrender_move_window_col
	textrender_draw_char_bitmap

	pop si
	pop cx
%endmacro

; si - points at the current position in the char map
%macro textrender_redraw_cols 0
	push cx

	; Clear the col
	mov [es:textrender_drawing_col], BYTE 0

	; set the col count
	mov cx, TEXT_COLS

%%next:
	; load the character into al
	; and increment pointer
	mov al, [es:si]
	inc si

	textrender_draw_char

	inc BYTE [es:textrender_drawing_col]
	loop %%next

	pop cx
%endmacro
	
GLOBAL_FUNC textrender_redraw
	push cx
	push si

	; clear the row counter
	mov [es:textrender_drawing_row], BYTE 0

	; point si at the char map
	mov si, textrender_charmap
	; set the row count
	mov cx, TEXT_ROWS
_redraw_row:
	call func_textrender_move_window_row
	textrender_redraw_cols
	inc BYTE [es:textrender_drawing_row]
	loop _redraw_row

	pop si
	pop cx
	ret

section .data
font:
; make sure the bottom 2 bits are 0
align 0x4
incbin "XGA_8x16.bin"

; pregenerate pixel data for each possible byte value
align 0x1000
precomp:
%assign i 0
%rep    256

%assign j 7
%rep	8
%if (i & (1 << j))
	dw TEXT_COLOUR_FG
%else
	dw TEXT_COLOUR_BG
%endif
%assign j j-1
%endrep

%assign i i+1
%endrep

section .bss
textrender_charmap:
	resb TEXT_TOTAL
textrender_drawing_col:
	resb 1
textrender_drawing_row:
	resb 1

