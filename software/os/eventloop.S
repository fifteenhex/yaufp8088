; kate: syntax Intel x86 (NASM)
; kate: replace-tabs off
[bits 16]

%include "../common/templates.h"

%include "tick.h"
%include "rtc.h"
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

; Stuff that happens on once-every-1s frequency
%macro eventloop_housekeeping 0
	call func_console_blinketc
%endmacro

; For now this does ~1s of processing
; - Every time there is an interrupt the stuff in eventloop_highpriority runs
; - Every time a full tick passes the stuff in normal runs
; - Once a full second has passed the housekeeping stuff happens and we return

GLOBAL_FUNC_LOCALS eventloop,2
	; get the tick count and stash it
	call func_tick_get
	LOCAL_STORE 0, ax
	; get the current second and stash it
	call func_rtc_readsec
	LOCAL_STORE 1, ax

_loop_until_tick:
	eventloop_highpriority

	; Wait for an int
	hlt

	; Check if the tick has progressed
	call func_tick_get
	LOCAL_LOAD bx, 0
	cmp ax, bx
	; Same tick
	je _loop_until_tick

	; tick changed
	LOCAL_STORE 0, ax

	; One tick has passed, do the normal stuff
	eventloop_normal

	; Check if the second has progressed
	call func_rtc_readsec
	LOCAL_LOAD bx, 1
	cmp ax, bx
	; Same second
	je _loop_until_tick
	
	; We would store the second but we exit at the moment

	eventloop_housekeeping

	; todo: move to template
	mov sp, bp
	pop bp
	ret
GLOBAL_FUNC_END
