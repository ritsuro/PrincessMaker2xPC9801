; "ERRBOX.ASM" PS55Z/S14 make by R.H/japan 1991/09/12
;
;	fatal error box.
;
; message program.

INCLUDE	TSTSET.INC

DSPLOCX1	EQU	19	; locate x1.
DSPLOCY1	EQU	11	; locate y1.
DSPLOCX2	EQU	19	; locate x2.
DSPLOCY2	EQU	12	; locate y2.
DSPLOCX3	EQU	19	; locate x3.
DSPLOCY3	EQU	13	; locate y3.

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	ERRBOX			; fatal error box.

EXTRN	VW_LOCATE:NEAR		; view/locate.
EXTRN	VW_TXCOLR:NEAR		; view/text color.
EXTRN	VW_ERRBOX:NEAR		; view/error box.

EXTRN	DSPMESS:NEAR		; disply message.

; ****************************************************
;	fatal error box.
;	-I- AX : error code.
;			1=directory clash!
;			2=file clash!
;			3=disk full.
;			4=empty data area.
; ****************************************************

ERRBOX	PROC	NEAR
	MOV	ERRORCODE,AX			; error code.

	CALL	ERRBOX_OPEN			; error box open.

	MOV	AX,11000001B			; text color.
	CALL	VW_TXCOLR			; view/text color.

	CMP	ERRORCODE,1			; 1=directory clash!
	JE	ERRBOX_01N			;
	CMP	ERRORCODE,2			; 2=file clash!
	JE	ERRBOX_02N			;
	CMP	ERRORCODE,3			; 3=disk full.
	JE	ERRBOX_03N			;
	CMP	ERRORCODE,4			; 4=empty data area.
	JE	ERRBOX_04N			;
	RET
ERRBOX_01N:
	MOV	AX,DSPLOCX1			; locate x1.
	MOV	BX,DSPLOCY1			; locate y1.
	CALL	VW_LOCATE			; view/locate.
	MOV	AX,34				;ディスクが破壊されています
	CALL	DSPMESS				; disply message.

	MOV	AX,DSPLOCX2			; locate x2.
	MOV	BX,DSPLOCY2			; locate y2.
	CALL	VW_LOCATE			; view/locate.
	MOV	AX,35				;（ディレクトリィ）
	CALL	DSPMESS				; disply message.

	MOV	AX,DSPLOCX3			; locate x3.
	MOV	BX,DSPLOCY3			; locate y3.
	CALL	VW_LOCATE			; view/locate.
	MOV	AX,37				;インストールが実行出来ません
	CALL	DSPMESS				; disply message.

	RET
ERRBOX_02N:
	MOV	AX,DSPLOCX1			; locate x1.
	MOV	BX,DSPLOCY1			; locate y1.
	CALL	VW_LOCATE			; view/locate.
	MOV	AX,34				;ディスクが破壊されています
	CALL	DSPMESS				; disply message.

	MOV	AX,DSPLOCX2			; locate x2.
	MOV	BX,DSPLOCY2			; locate y2.
	CALL	VW_LOCATE			; view/locate.
	MOV	AX,36				;（ファイル）
	CALL	DSPMESS				; disply message.

	MOV	AX,DSPLOCX3			; locate x3.
	MOV	BX,DSPLOCY3			; locate y3.
	CALL	VW_LOCATE			; view/locate.
	MOV	AX,37				;インストールが実行出来ません
	CALL	DSPMESS				; disply message.

	RET
ERRBOX_03N:
	MOV	AX,DSPLOCX1			; locate x1.
	MOV	BX,DSPLOCY1			; locate y1.
	CALL	VW_LOCATE			; view/locate.
	MOV	AX,38				;コピー先のハードディスクが
	CALL	DSPMESS				; disply message.

	MOV	AX,DSPLOCX2			; locate x2.
	MOV	BX,DSPLOCY2			; locate y2.
	CALL	VW_LOCATE			; view/locate.
	MOV	AX,37				;インストールが実行出来ません
	CALL	DSPMESS				; disply message.

	MOV	AX,DSPLOCX3			; locate x3.
	MOV	BX,DSPLOCY3			; locate y3.
	CALL	VW_LOCATE			; view/locate.
	MOV	AX,39				;ハードディスクの空き領域を
	CALL	DSPMESS				; disply message.

	RET
ERRBOX_04N:
	MOV	AX,DSPLOCX1			; locate x1.
	MOV	BX,DSPLOCY1			; locate y1.
	CALL	VW_LOCATE			; view/locate.
	MOV	AX,40				; セーブ出来る領域が足りません
	CALL	DSPMESS				; disply message.

	MOV	AX,DSPLOCX2			; locate x2.
	MOV	BX,DSPLOCY2			; locate y2.
	CALL	VW_LOCATE			; view/locate.
	MOV	AX,39				;ハードディスクの空き領域を
	CALL	DSPMESS				; disply message.

	RET
ERRBOX	ENDP


; ****************************************************
;	error box open.
; ****************************************************

ERRBOX_OPEN	PROC	NEAR
	MOV	CX,25
ERRBOX_OPEN_LOOP:
	LF
	LOOP	ERRBOX_OPEN_LOOP
	CALL	VW_ERRBOX			; view/error box.
	RET
ERRBOX_OPEN	ENDP


; ****************************************************
;	DATA.
; ****************************************************

ERRORCODE	DW	0		; error code.


CODE	ENDS

	END
;
;	end of "ERRBOX.ASM"
;
