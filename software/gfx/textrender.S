; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/templates.h"
%include "../common/string.S"

%include "../common/usart_8251.S"

%include "inc/display_util.h"

%define TEXT_COLS			22
%define TEXT_ROWS			13
%define TEXT_TOTAL			(TEXT_COLS * TEXT_ROWS)
%define TEXT_CHARMAP_ENTRY_SZ 2
%define TEXT_TOTAL_BYTES	(TEXT_TOTAL * TEXT_CHARMAP_ENTRY_SZ)

%define TEXT_COLOUR_FG	0xffff
%define TEXT_COLOUR_BG	0x0000

%define TEXT_ROW_HEIGHT 16
%define TEXT_ROW_GAP	1

; toggles on and off each frame
%define TEXT_FLAG_ODDFRAME	(1)

%define TEXT_CHARFLAG_CLEAN (1)

section .text

GLOBAL_FUNC textrender_reset
	push cx
	push si

	mov [es:textrender_flags], BYTE 0
	mov [es:textrender_cursor_col], WORD 0
	mov [es:textrender_cursor_row], WORD 0
	mov [es:textrender_cursor_pos], WORD 0

	; clear the charmap
	mov cx, TEXT_TOTAL
	mov si, textrender_charmap
_textrender_reset_charmap_clear:
	mov [es:si], WORD 0x0020
	add si, 2
	loop _textrender_reset_charmap_clear

	pop si
	pop cx
	ret
GLOBAL_FUNC_END

GLOBAL_FUNC textrender_init
	call func_textrender_reset
	ret
GLOBAL_FUNC_END

%macro textrender_putch_insertchar 0
	mov bx, textrender_charmap
	mov di, WORD [es:textrender_cursor_pos]

	; clear the flags at the top and write the char and flags
	mov ah, 0
	mov [es:bx+di], ax
%endmacro

%macro textrender_putch_updatecursor 0
	; increment the absolute position of the cursor
	mov ax, WORD [es:textrender_cursor_pos]
	add ax, TEXT_CHARMAP_ENTRY_SZ
	cmp ax, TEXT_TOTAL_BYTES
	jne %%set_pos
	mov ax, 0
%%set_pos:
	mov WORD [es:textrender_cursor_pos], ax

	; increment col, see if its at the limit
	mov al, BYTE [es:textrender_cursor_col]
	inc al
	cmp al, TEXT_COLS
	jne %%set_col

	; col has wrapped, check the row
	mov al, BYTE [es:textrender_cursor_row]
	inc al
	cmp al, TEXT_ROWS
	jne %%set_row
	mov al, 0

%%set_row:
	mov BYTE [es:textrender_cursor_row], al
	; if we set the row then col has to be zero
	mov al, 0
%%set_col:
	mov BYTE [es:textrender_cursor_col], al
%endmacro

GLOBAL_FUNC textrender_putch
	textrender_putch_insertchar
	textrender_putch_updatecursor
	ret
GLOBAL_FUNC_END

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
	mov di, WORD [es:textrender_drawing_col]
	shl di, 1
	mov bx, move_col_funcs
	mov ax, [bx+di]
	jmp ax

%assign c 0
%rep TEXT_COLS
display_set_window_h_col_%+c:
	display_set_window_h (8 * c), ((8 * c) + 7)
	display_write_reg ILI9225_REG_RAMADDRESSSET_1,(8 * c)
	ret
%assign c c+1
%endrep

; This is a bit too fat to inline
STATIC_FUNC textrender_move_window_row
	mov di, WORD [es:textrender_drawing_row]
	shl di, 1
	mov bx, move_row_funcs
	mov ax, [bx+di]
	jmp ax

%assign r 0
%rep TEXT_ROWS
display_set_window_v_row_%+r:
%assign row_off ((TEXT_ROW_HEIGHT + TEXT_ROW_GAP) * r)
	display_set_window_v row_off, (row_off + 15)
	display_write_reg ILI9225_REG_RAMADDRESSSET_2, row_off
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

STATIC_FUNC textrender_override_char_for_cursor
	; is this the cursor?
	mov bx, [es:textrender_drawing_col]
	cmp bx, [es:textrender_cursor_col]
	jne _override_out
	mov bx, [es:textrender_drawing_row]
	cmp bx, [es:textrender_cursor_row]
	jne _override_out

	; Ignore the clean flag for the cursor
	and ah , ~TEXT_CHARFLAG_CLEAN

	; is this the odd frame?
	test BYTE [es:textrender_flags], TEXT_FLAG_ODDFRAME
	je _override_odd

	mov al, 0xfe
_override_odd:
_override_out:
	ret

; si - points at the current position in the char map
%macro textrender_redraw_cols 0
	push cx

	; Clear the col
	mov [es:textrender_drawing_col], BYTE 0

	; set the col count
	mov cx, TEXT_COLS

%%next:
	; load the character and flags into ax, flags in ah,
	; character in al
	mov ax, [es:si]

	call func_textrender_override_char_for_cursor

%%draw:
	; Check if this character is already up to date on the screen
	test ah, TEXT_CHARFLAG_CLEAN
	jnz %%skip

	textrender_draw_char

	; Mark the char as clean
	; todo, What state is AH in at this point? :D
	mov ah, TEXT_CHARFLAG_CLEAN
	mov [es:si + 1], ah

%%skip:
	; increment col and charmap pointer
	inc BYTE [es:textrender_drawing_col]
	add si, 2

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
GLOBAL_FUNC_END

GLOBAL_FUNC textrender_blink
	; flag update
	xor BYTE [es:textrender_flags], TEXT_FLAG_ODDFRAME
	ret
GLOBAL_FUNC_END

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

move_col_funcs:
%assign c 0
%rep TEXT_COLS
	dw display_set_window_h_col_%+c
%assign c c+1
%endrep

move_row_funcs:
%assign r 0
%rep TEXT_ROWS
	dw display_set_window_v_row_%+r
%assign r r+1
%endrep

section .bss
textrender_flags:
	resb 1
textrender_charmap:
	resw TEXT_TOTAL

; Where the rendering code is on the screen
textrender_drawing_col:
	resb 1
; dummy - must be zero!
	resb 1
textrender_drawing_row:
	resb 1
; dummy - must be zero!
	resb 1

; Where the cursor is on the screen
textrender_cursor_col:
	resb 1
; dummy - must be zero!
	resb 1
textrender_cursor_row:
	resb 1
; dummy - must be zero!
	resb 1
textrender_cursor_pos:
	resw 1
