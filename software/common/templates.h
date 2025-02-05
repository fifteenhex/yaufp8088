; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off

%macro GLOBAL_FUNC 1
global func_%1
func_%1:
%endmacro

%macro STATIC_FUNC 1
func_%1:
%endmacro

%macro EXPORT_FUNC 1
extern func_%1
%endmacro
