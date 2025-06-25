; "MACHINE.ASM" 486/33 make by R.H 1991/06/20
;
;
;	machine.
;
;
; subroutine.

INCLUDE	TSTSET.INC

MFLAG_PCAT	EQU	1		; PC/AT
MFLAG_PC98	EQU	2		; PC9801

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

;*;PUBLIC	MACHINE_SET			; machine set.
;*;
;*;; *********************************************************
;*;;	machine check.
;*;;	-I- DX : 1=PC/AT,2=PC9801
;*;; *********************************************************
;*;
;*;MACHINE_SET	PROC	NEAR
;*;	CMP	DX,1
;*;	JE	MACHINE_SET_PCAT
;*;	CMP	DX,2
;*;	JE	MACHINE_SET_PC98
;*;	JMP	MACHINE_SET_PC98
;*;MACHINE_SET_PCAT:
;*;	MOV	MFLAG_MY,MFLAG_PCAT		; PC/AT
;*;	PRF	"machine ID  PC/AT"
;*;	RET
;*;MACHINE_SET_PC98:
;*;	MOV	MFLAG_MY,MFLAG_PC98		; PC9801
;*;	PRF	"machine PC98"
;*;	RET
;*;MACHINE_SET	ENDP

CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	MFLAG_MY			; machine flag.
MFLAG_MY	DW	MFLAG_PC98	; machine flag.

DATA	ENDS

	END
;
;	end of "MACHINE.ASM"
;
