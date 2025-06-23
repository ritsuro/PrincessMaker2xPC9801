; "BBLOOP.ASM" PC-9801UV11 make by R.H 1991/10/08
;
;
;	princess  B A S I C    l o o p.
;
;
; basic shell.

INCLUDE	TSTSETC.INC
INCLUDE	BBEXTRN.INC
INCLUDE	DEBUGX.INC

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:DATA

PUBLIC	BBLOOP			; main loop.

; *********************************************************
;	main loop.
; *********************************************************

BBLOOP	PROC	NEAR
	MOV	SI,STARTUP_FILE		; startup text file name.
	CALLE	BBLOAD			; text load.
	CMP	AX,0			; 0=normal,1=error.
	JNE	BBLOOP_ERROR_LOAD	;

;;	CALLE	BBCOMPFULL		; full compile.
;;	CALLE	BBMESBOX		; text message box.

BBLOOP_LOOP:
	CALLE	BBCOMPLIN		; line compile.
	CMP	FLAGEXIT,0		; exit flag.
	JNE	BBLOOP_ERROR_EXIT	;
	CMP	AX,1			; 0=complete,1=not compile line
	JNE	BBLOOP_NEXT		;

	CALLE	c_USERWAIT		; user wait.

	STRS	SI,"MAINLOOP"
	CALLE	BBLOAD			; text load.
BBLOOP_NEXT:				;
	JMP	BBLOOP_LOOP		;

BBLOOP_ERROR_EXIT:
	RET
BBLOOP_ERROR_LOAD:
	BBERROR	119			; error message.
	RET
BBLOOP	ENDP

CODE	ENDS


; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	STARTUP_FILE:WORD		; startup text file name.

DATA	ENDS
	END
;
;	end of "KS2MAIN.ASM"
;
