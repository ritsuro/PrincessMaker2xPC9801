; "VGADSPST.ASM" 486/33 make by R.H 1992/04/09
;
;
;	VGA  disply  handler.
;
;
; subroutine.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	VGAGRPMDE		; VGA vram graphic mode.
PUBLIC	VGARETMDE		; VGA vram graphic mode ret.
PUBLIC	VGACLR			; VGA vram clear.

EXTRN	C1VV_SETUP_VGA:NEAR	; setup VGA mode.
EXTRN	C1VV_SETUP_RET:NEAR	; video mode return.
EXTRN	C1VV_PUT_MODE_SET:NEAR	; put mode standerd.
EXTRN	C1VV_PAL_TO_REG_SET:NEAR; palet nunber to color registar set.
EXTRN	C1VV_BANK_FULL_DX:NEAR	; vram bank check & full. DX


;	vram graphic mode.

VGAGRPMDE	PROC	NEAR
	CALL	C1VV_SETUP_VGA		; setup VGA mode.
	CALL	C1VV_PUT_MODE_SET	; put mode standerd.
	CALL	C1VV_PAL_TO_REG_SET	; palet nunber to color registar set.
	RET
VGAGRPMDE	ENDP


;	vram graphic mode ret.

VGARETMDE	PROC	NEAR
	CALL	C1VV_SETUP_RET		; video mode return.
	RET
VGARETMDE	ENDP


;	vram clear.

VGACLR	PROC	NEAR
	MOV	DX,WORD PTR ARAVRM[0]	; vram plean 0.(1,2,3all)
	CALL	C1VV_BANK_FULL_DX	; vram bank check & full. DX
	MOV	ES,DX
	MOV	DI,0
	MOV	CX,40*400
	MOV	AX,0
	REP	STOSW
	RET
VGACLR	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	ARAVRM:WORD			; vram plean.

DATA	ENDS

	END
;
;	end of "VGADSPST.ASM"
;
