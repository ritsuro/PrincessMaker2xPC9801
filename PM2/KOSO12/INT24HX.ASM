; "INT24HX.ASM" PS55Z/S14 make by R.Hashimoto 1991/07/17
;
;
;	INT 24h handle.
;
;
; public subroutine.

INCLUDE	TSTSET.INC

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	INT24HX_SRT	; int24h handle startup.
PUBLIC	INT24HX_END	; int24h handle end.
PUBLIC	INT24HX_ERRGET	; int24h handle error get.


; ****************************************************
;	int24h handle startup.
; ****************************************************

INT24HX_SRT	PROC	NEAR
	PUSH	DS
	MOV	AX,CS
	MOV	DS,AX
	MOV	DX,OFFSET INT24H		; int24h handle.
	MOV	AL,24H				; int24h.
	MOV	AH,25H				; int vector set.
	INT	21H				; DOS call.
	POP	DS
	RET
INT24HX_SRT	ENDP


; ****************************************************
;	int24h handle end.
; ****************************************************

INT24HX_END	PROC	NEAR
	RET
INT24HX_END	ENDP


; ****************************************************
;	int24h handle error get.
;	-O- AX : intarpt flag.
; ****************************************************

INT24HX_ERRGET	PROC	NEAR
	MOV	AX,INT24H_FLAG			; intarpt flag.
	MOV	INT24H_FLAG,0			; intarpt flag.
	RET
INT24HX_ERRGET	ENDP


; ****************************************************
;	int24h handle.
; ****************************************************

INT24H	PROC	NEAR
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	DS
	PUSH	ES
	PUSH	DI
	PUSH	SI
	PUSH	BP

	PUSH	CS
	POP	DS

	MOV	INT24H_FLAG,1			; intarpt flag.

	MOV	AL,3

	POP	BP
	POP	SI
	POP	DI
	POP	ES
	POP	DS
	POP	DX
	POP	CX
	POP	BX
	IRET
INT24H	ENDP

INT24H_FLAG	DW	0	; intarpt flag.

CODE	ENDS

	END
;
;	end of "INT24HX.ASM"
;
