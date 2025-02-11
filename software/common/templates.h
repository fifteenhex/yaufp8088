; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off


%macro GLOBAL_FUNC_LOCALS 2
global func_%1
func_%1:
%if %2 > 0
	push bp
	mov bp, sp
	sub sp, (2 * %2)
%endif
%endmacro

%macro GLOBAL_FUNC 1
GLOBAL_FUNC_LOCALS %1,0
%endmacro

%macro GLOBAL_FUNC_END 0
%endmacro

%macro STATIC_FUNC 1
func_%1:
%endmacro

%macro EXPORT_FUNC 1
extern func_%1
%endmacro

%macro LOCAL_STORE 2
	mov [bp - (2 + (%1 * 2))], %2
%endmacro

%macro LOCAL_LOAD 2
	mov %1, [bp - (2 + (%2 * 2))]
%endmacro
