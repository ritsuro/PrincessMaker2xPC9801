; "MAINLOOP.ASM" 486/50 make by R.H 1992/07/18
;
;
;	武者修行・東
;	メインループ
;
;
; public subroutine.

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	MAINLOOP		; main loop.

MAINLOOP	PROC	NEAR
	RET
MAINLOOP	ENDP

; ****************************************************
;	DATA
; ****************************************************

CODE	ENDS

	END
;
;	end of "MAINLOOP.ASM"
;
