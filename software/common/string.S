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
