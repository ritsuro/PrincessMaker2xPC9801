; "GRPACS.ASM" 486/33 make by R.H 1992/04/08
;
;
;	graphics access subroutines.
;
;
; subroutine.

INCLUDE	MACHINEX.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	GRPSRT			; graphics start.
PUBLIC	GRPEND			; graphics end.
PUBLIC	GRPCLS			; graphics clear screen.

EXTRN	VRMGRPMDE:NEAR		; vram graphic mode.
EXTRN	VRMRETMDE:NEAR		; vram graphic mode ret.
EXTRN	VRMCLR:NEAR		; ‚u‚q‚`‚lƒNƒŠƒA

EXTRN	VGAGRPMDE:NEAR		; VGA vram graphic mode.
EXTRN	VGARETMDE:NEAR		; VGA vram graphic mode ret.
EXTRN	VGACLR:NEAR		; VGA vram clear.


;	graphics start.

GRPSRT	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	GRPSRT_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	GRPSRT_PC98		;
	RET
GRPSRT_PCAT:
	CALL	VGAGRPMDE		; VGA vram graphic mode.
	RET
GRPSRT_PC98:
	CALL	VRMGRPMDE		; vram graphic mode.
	RET
GRPSRT	ENDP


;	graphics end.

GRPEND	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	GRPEND_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	GRPEND_PC98		;
	RET
GRPEND_PCAT:
	CALL	VGARETMDE		; VGA vram graphic mode ret.
	RET
GRPEND_PC98:
	CALL	VRMRETMDE		; vram graphic mode ret.
	RET
GRPEND	ENDP


;	graphics clear screen.

GRPCLS	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	GRPCLS_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	GRPCLS_PC98		;
	RET
GRPCLS_PCAT:
	CALL	VGACLR			; VGA vram clear.
	RET
GRPCLS_PC98:
	CALL	VRMCLR			; ‚u‚q‚`‚lƒNƒŠƒA
	RET
GRPCLS	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'
DATA	ENDS

	END
;
;	end of "GRPACS.ASM"
;
