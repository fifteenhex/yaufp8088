; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/templates.h"

%include "tick.h"
%include "console.h"

; Stuff that has to happen on sub 100ms frequency,
; driven by interrupt activty
%macro eventloop_highpriority 0
	call func_console_process
%endmacro

; Stuff that happens on once-every-100ms frequency
%macro eventloop_normal 0
	call func_console_refresh
%endmacro

%macro eventloop_housekeeping 0
%endmacro

GLOBAL_FUNC_LOCALS eventloop,1
	; get the tick count and stash it
	call func_tick_get
	LOCAL_STORE 1, ax

_loop_until_tick:
	eventloop_highpriority

	; Wait for an int
	hlt

	; Check if the tick has progressed
	call func_tick_get
	LOCAL_LOAD bx, 1
	cmp ax, bx
	; Same tick
	je _loop_until_tick

	; tick changed
	LOCAL_STORE 1, ax

	eventloop_normal
	eventloop_housekeeping

	; todo: move to template

	mov sp, bp
	pop bp
	ret
GLOBAL_FUNC_END
