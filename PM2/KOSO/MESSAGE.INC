; "MESSAGE.INC" 486/50 make by R.H 1992/05/15
;
;
;	message table extrn.
;
;
; public subroutine.

EXTRN	MESSAGE_ADGET:FAR		; message address get.(far)

MESSAGE	MACRO	STRNUMBER
	PUSH	BX
	MOV	BX,STRNUMBER
	CALL	MESSAGE_ADGET		; message address get.(far)
	POP	BX
	ENDM

;
;	end of "MESSAGE.INC"
;
