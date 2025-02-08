; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off

; 0 - address
; 1 - length
%macro zeroblk 2
	mov ax, 0
	mov es, ax
	mov di, 0
%%_ram_loop:
	mov [es:di], ax
	add di, 2
	cmp di, 0
	jnz %%_ram_loop
%%_ram_loop_exit:
%endmacro

; copy 8 words to an io port
; dx needs to contain the io port address
; si needs to point at the start of the data
%macro outblk_word_8 0
%rep 8
	lodsw
	out dx, ax
%endrep
%endmacro

; fill (copy a single value repeatedly) in 64
; word blocks to an io port
; ax - fill value
; cx - number of 64 word blocks
; dx - io port address
%macro outfill_blk_word_64 0
%%_next_block:
%rep 64
	out dx, ax
%endrep
	loop %%_next_block
%endmacro
