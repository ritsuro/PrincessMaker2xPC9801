; "EFECT2.ASM" 1989/10/10 R.H
;              PC-9801UV11 make by R.H 1989
; public subroutine.
;
;
;	SSEFC0			; visual data segment plean 0
;	SSEFC1			; visual data segment plean 1
;	SSEFC2			; visual data segment plean 2
;	SSEFC3			; visual data segment plean 3
;
;	VX1:WORD		; source point x1.
;	VY1:WORD		; source point y1.
;	VX2:WORD		; destination point x3.
;	VY2:WORD		; destination point y3.
;
;
;［削除］ＥＦＥＣＴ０：ＥＣＴＯＰ０はワークに使うので６４２バイトないと
;［削除］困ります
;

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	BOXPAL			; ＢＯＸペイント
PUBLIC	BOX3CLR			; ＢＯＸ３プレーンクリア
PUBLIC	BOXMSS			; ＢＯＸメッシュ
PUBLIC	BOXNOT			; ＢＯＸ反転
PUBLIC	BOXMCH			; ＢＯＸチェック模様
PUBLIC	BOXPAI			; ＢＯＸ１プレーンペイント
PUBLIC	BOXBLK			; ＢＯＸ１プレーンヌキ
PUBLIC	BOXMSU			; ＢＯＸ１プレーンメッシュ
PUBLIC	BOXNTS			; ＢＯＸ１プレーン反転
PUBLIC	BOXMTU			; ＢＯＸ１プレーンチェック模様
PUBLIC	BOXVRAM400TO480		; ＢＯＸVRAM400から479ﾗｲﾝｸﾘｱ
PUBLIC	BOXLEDLAMP		; LED like lamp.(WIDDISK.ASM)

EXTRN	C1VV_BANK_CHG_ES:NEAR	; vram bank check & chenge.(WRITE) ES
EXTRN	C1VV_MODE_PSET:NEAR	; vram put mode PSET.
EXTRN	C1VV_MODE_AND:NEAR	; vram put mode AND.
EXTRN	C1VV_MODE_OR:NEAR	; vram put mode OR.
EXTRN	C1VV_MODE_XOR:NEAR	; vram put mode XOR.
EXTRN	C1VV_BANK_CHK:NEAR	; vram bank check. DX


;	ＢＯＸペイント
;	-i- SSEFC0-3 : efect data segment.
;	    VX1,VY1  : start point.
;	    VX2,VY2  : end point.
;	    CX       : color palet number.

BOXPAL	PROC	NEAR
	TEST	CX,1
	JZ	BOXPAL1
	MOV	DX,SSEFC0	; visual data segment plean 0
	CALL	BOXPAI		; ＢＯＸプレーンペイント
	JMP	BOXPAL11
BOXPAL1:
	MOV	DX,SSEFC0	; visual data segment plean 0
	CALL	BOXBLK		; ＢＯＸ１プレーンヌキ
BOXPAL11:
	TEST	CX,2
	JZ	BOXPAL2
	MOV	DX,SSEFC1	; visual data segment plean 1
	CALL	BOXPAI		; ＢＯＸプレーンペイント
	JMP	BOXPAL22
BOXPAL2:
	MOV	DX,SSEFC1	; visual data segment plean 1
	CALL	BOXBLK		; ＢＯＸ１プレーンヌキ
BOXPAL22:
	TEST	CX,4
	JZ	BOXPAL3
	MOV	DX,SSEFC2	; visual data segment plean 2
	CALL	BOXPAI		; ＢＯＸプレーンペイント
	JMP	BOXPAL33
BOXPAL3:
	MOV	DX,SSEFC2	; visual data segment plean 2
	CALL	BOXBLK		; ＢＯＸ１プレーンヌキ
BOXPAL33:
	TEST	CX,8
	JZ	BOXPAL4
	MOV	DX,SSEFC3	; visual data segment plean 3
	CALL	BOXPAI		; ＢＯＸプレーンペイント
	JMP	BOXPAL44
BOXPAL4:
	MOV	DX,SSEFC3	; visual data segment plean 3
	CALL	BOXBLK		; ＢＯＸ１プレーンヌキ
BOXPAL44:
	RET
BOXPAL	ENDP


;	ＢＯＸ３プレーンクリア
;	-i- SSEFC0-2 : efect data segment.
;	    VX1,VY1  : start point.
;	    VX2,VY2  : end point.

BOX3CLR	PROC	NEAR
	MOV	DX,SSEFC0	; visual data segment plean 0
	CALL	BOXBLK		; ＢＯＸ１プレーンヌキ
	MOV	DX,SSEFC1	; visual data segment plean 1
	CALL	BOXBLK		; ＢＯＸ１プレーンヌキ
	MOV	DX,SSEFC2	; visual data segment plean 2
	CALL	BOXBLK		; ＢＯＸ１プレーンヌキ
	RET
BOX3CLR	ENDP


;	ＢＯＸメッシュ
;	-i- SSEFC0-3 : efect data segment.
;	    VX1,VY1  : start point.
;	    VX2,VY2  : end point.
;	    CX       : color palet number.

BOXMSS	PROC	NEAR
	MOV	BP,0		; 0=AND
	TEST	CX,1		;
	JZ	BOXMSS1		;
	MOV	BP,1		; 1=OR
BOXMSS1:			;
	MOV	DX,SSEFC0	; visual data segment plean 0
	CALL	BOXMSU		; ＢＯＸ１プレーンメッシュ

	MOV	BP,0		; 0=AND
	TEST	CX,2		;
	JZ	BOXMSS2		;
	MOV	BP,1		; 1=OR
BOXMSS2:			;
	MOV	DX,SSEFC1	; visual data segment plean 1
	CALL	BOXMSU		; ＢＯＸ１プレーンメッシュ

	MOV	BP,0		; 0=AND
	TEST	CX,4		;
	JZ	BOXMSS3		;
	MOV	BP,1		; 1=OR
BOXMSS3:			;
	MOV	DX,SSEFC2	; visual data segment plean 2
	CALL	BOXMSU		; ＢＯＸ１プレーンメッシュ

	MOV	BP,0		; 0=AND
	TEST	CX,8		;
	JZ	BOXMSS4		;
	MOV	BP,1		; 1=OR
BOXMSS4:			;
	MOV	DX,SSEFC3	; visual data segment plean 3
	CALL	BOXMSU		; ＢＯＸ１プレーンメッシュ

	RET
BOXMSS	ENDP



;	ＢＯＸ反転
;	-i- SSEFC0-3 : efect data segment.
;	    VX1,VY1  : start point.
;	    VX2,VY2  : end point.
;	    CX       : color palet number.

BOXNOT	PROC	NEAR
	TEST	CX,1
	JZ	BOXNOT1
	MOV	DX,SSEFC0	; visual data segment plean 0
	CALL	BOXNTS		; ＢＯＸ１プレーン反転
;*NON*;	JMP	BOXNOT11
BOXNOT1:
BOXNOT11:
	TEST	CX,2
	JZ	BOXNOT2
	MOV	DX,SSEFC1	; visual data segment plean 1
	CALL	BOXNTS		; ＢＯＸ１プレーン反転
;*NON*;	JMP	BOXNOT22
BOXNOT2:
BOXNOT22:
	TEST	CX,4
	JZ	BOXNOT3
	MOV	DX,SSEFC2	; visual data segment plean 2
	CALL	BOXNTS		; ＢＯＸ１プレーン反転
;*NON*;	JMP	BOXNOT33
BOXNOT3:
BOXNOT33:
	TEST	CX,8
	JZ	BOXNOT4
	MOV	DX,SSEFC3	; visual data segment plean 3
	CALL	BOXNTS		; ＢＯＸ１プレーン反転
;*NON*;	JMP	BOXNOT44
BOXNOT4:
BOXNOT44:
	RET
BOXNOT	ENDP


;	ＢＯＸチェック模様
;	-i- SSEFC0-3 : efect data segment.
;	    VX1,VY1  : start point.
;	    VX2,VY2  : end point.
;	    CX       : color1 palet number.
;	    BX       : color2 palet number.

BOXMCH	PROC	NEAR
	MOV	BP,0		;

	RCR	CX,1		; color1 palet number.
	RCL	BP,1		;
	RCR	BX,1		; color2 palet number.
	RCL	BP,1		;
	MOV	DX,SSEFC0	; visual data segment plean 0
	CALL	BOXMTU		; ＢＯＸ１プレーンチェック模様

	MOV	BP,0		;

	RCR	CX,1		; color1 palet number.
	RCL	BP,1		;
	RCR	BX,1		; color2 palet number.
	RCL	BP,1		;
	MOV	DX,SSEFC1	; visual data segment plean 1
	CALL	BOXMTU		; ＢＯＸ１プレーンチェック模様

	MOV	BP,0		;

	RCR	CX,1		; color1 palet number.
	RCL	BP,1		;
	RCR	BX,1		; color2 palet number.
	RCL	BP,1		;
	MOV	DX,SSEFC2	; visual data segment plean 2
	CALL	BOXMTU		; ＢＯＸ１プレーンチェック模様

	MOV	BP,0		;

	RCR	CX,1		; color1 palet number.
	RCL	BP,1		;
	RCR	BX,1		; color2 palet number.
	RCL	BP,1		;
	MOV	DX,SSEFC3	; visual data segment plean 3
	CALL	BOXMTU		; ＢＯＸ１プレーンチェック模様

	RET
BOXMCH	ENDP


;	ＢＯＸ１プレーンメッシュ
;	-i- VX1,VY1 : start point.
;	    VX2,VY2 : end point.
;	    DX      : SEGMENT
;	    BP      : 0=AND,1=OR

BOXMSU	PROC	NEAR
	PUSH	DX
	CALL	C1VV_BANK_CHK		; vram bank check. DX
	POP	DX
	CMP	AX,1			; 0=normal,1=video memory.
	JNE	BOXMSU_1		;

	CALL	BOXMSU_G		; ＢＯＸビデオ１プレーンメッシュ
	RET

BOXMSU_1:
	PUSH	DX
	PUSH	BP
	PUSH	CX

	MOV	ES,DX

	CMP	BP,1			; 0=AND,1=OR
	JE	BOXMSU_OR		;
BOXMSU_AND:
	CALL	ADRSCALC		; address point calc.

	MOV	AL,10101010B		; bit pattan.
	MOV	SI,CX			; loop counter.
BOXMSU1:
	MOV	DI,DX
	MOV	CX,BX
	ROR	AL,1
BOXMSU2:AND	ES:[DI],AL
	INC	DI
	LOOP	BOXMSU2

	ADD	DX,BP			; vram width.
	DEC	SI
	JNZ	BOXMSU1

	JMP	BOXMSU9

BOXMSU_OR:
	CALL	ADRSCALC		; address point calc.

	MOV	AL,10101010B		; bit pattan.
	MOV	SI,CX			; loop counter.
BOXMSU3:
	MOV	DI,DX
	MOV	CX,BX
BOXMSU4:OR	ES:[DI],AL
	INC	DI
	LOOP	BOXMSU4

	ROR	AL,1
	ADD	DX,BP			; vram width.
	DEC	SI
	JNZ	BOXMSU3

BOXMSU9:
	POP	CX
	POP	BP
	POP	DX
	RET
BOXMSU	ENDP


;	ＢＯＸビデオ１プレーンメッシュ
;	-i- VX1,VY1 : start point.
;	    VX2,VY2 : end point.
;	    DX      : SEGMENT
;	    BP      : 0=AND,1=OR

BOXMSU_G	PROC	NEAR
	PUSH	DX
	PUSH	BP
	PUSH	CX

	MOV	ES,DX
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES

	CMP	BP,1			; 0=AND,1=OR
	JE	BOXMSU_G_OR		;
BOXMSU_G_AND:
	CALL	ADRSCALC		; address point calc.
	CALL	C1VV_MODE_AND		; vram put mode AND.

	MOV	AL,10101010B		; bit pattan.
	MOV	SI,CX			; loop counter.
BOXMSU_G1:
	MOV	DI,DX
	MOV	CX,BX
	ROR	AL,1
BOXMSU_G2:
	MOV	AH,ES:[DI]		; rach.
	STOSB				; AND
	LOOP	BOXMSU_G2

	ADD	DX,BP			; vram width.
	DEC	SI
	JNZ	BOXMSU_G1

	JMP	BOXMSU_G9

BOXMSU_G_OR:
	CALL	ADRSCALC		; address point calc.
	CALL	C1VV_MODE_OR		; vram put mode OR.

	MOV	AL,10101010B		; bit pattan.
	MOV	SI,CX			; loop counter.
BOXMSU_G3:
	MOV	DI,DX
	MOV	CX,BX
BOXMSU_G4:
	MOV	AH,ES:[DI]		; rach.
	STOSB				; OR
	LOOP	BOXMSU_G4

	ROR	AL,1
	ADD	DX,BP			; vram width.
	DEC	SI
	JNZ	BOXMSU_G3

BOXMSU_G9:
	CALL	C1VV_MODE_PSET		; vram put mode PSET.
	POP	CX
	POP	BP
	POP	DX
	RET
BOXMSU_G	ENDP



;	ＢＯＸ１プレーンペイント
;	-i- VX1,VY1 : start point.
;	    VX2,VY2 : end point.
;	    DX      : SEGMENT

BOXPAI	PROC	NEAR
	PUSH	DX
	PUSH	BP
	PUSH	CX

	MOV	ES,DX
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES

	CALL	ADRSCALC		; address point calc.

	MOV	SI,CX			; si : loop counter.
	MOV	AL,0FFH			; pattan.
BOXPAI1:
	MOV	DI,DX			; start point.
	MOV	CX,BX			; x length.
	REP	STOSB			;

	ADD	DX,BP			; vram width.
	DEC	SI			; loop counter.
	JNZ	BOXPAI1

	POP	CX
	POP	BP
	POP	DX
	RET
BOXPAI	ENDP



;	ＢＯＸ１プレーンヌキ
;	-i- VX1,VY1 : start point.
;	    VX2,VY2 : end point.
;	    DX      : SEGMENT

BOXBLK	PROC	NEAR
	PUSH	DX
	PUSH	BP
	PUSH	CX

	MOV	ES,DX

	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES

	CALL	ADRSCALC		; address point calc.

	MOV	SI,CX			; si : loop counter.
	MOV	AL,0			; pattan.
BOXBLK1:
	MOV	DI,DX			; start point.
	MOV	CX,BX			; x length.
	REP	STOSB			;

	ADD	DX,BP			; vram width.
	DEC	SI			; loop counter.
	JNZ	BOXBLK1

	POP	CX
	POP	BP
	POP	DX
	RET
BOXBLK	ENDP


;	ＢＯＸ１プレーン反転
;	-i- VX1,VY1 : start point.
;	    VX2,VY2 : end point.
;	    DX      : SEGMENT

BOXNTS	PROC	NEAR
	PUSH	DX
	CALL	C1VV_BANK_CHK		; vram bank check. DX
	POP	DX
	CMP	AX,1			; 0=normal,1=video memory.
	JNE	BOXNTS_1		;

	CALL	BOXNTS_G		; ＢＯＸビデオ１プレーン反転
	RET

BOXNTS_1:
	PUSH	DX
	PUSH	CX
	MOV	ES,DX

	CALL	ADRSCALC		; address point calc.

	MOV	SI,CX			; si : loop counter.
BOXNTS1:
	MOV	DI,DX
	MOV	CX,BX
BOXNTS2:NOT	BYTE PTR ES:[DI]
	INC	DI
	LOOP	BOXNTS2

	ADD	DX,BP			; vram width.
	DEC	SI
	JNZ	BOXNTS1

BOXNTS9:
	POP	CX
	POP	DX
	RET
BOXNTS	ENDP


;	ＢＯＸビデオ１プレーン反転
;	-i- VX1,VY1 : start point.
;	    VX2,VY2 : end point.
;	    DX      : SEGMENT

BOXNTS_G	PROC	NEAR
	PUSH	DX
	PUSH	CX
	MOV	ES,DX

	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES
	CALL	C1VV_MODE_XOR		; vram put mode XOR.

	CALL	ADRSCALC		; address point calc.

	MOV	SI,CX			; si : loop counter.
BOXNTS_G1:
	MOV	DI,DX
	MOV	CX,BX
	MOV	AL,0FFH			;
BOXNTS_G2:				;
	MOV	AH,ES:[DI]		; rach.
	STOSB				; XOR
	LOOP	BOXNTS_G2

	ADD	DX,BP			; vram width.
	DEC	SI
	JNZ	BOXNTS_G1

BOXNTS_G9:
	CALL	C1VV_MODE_PSET		; vram put mode PSET.
	POP	CX
	POP	DX
	RET
BOXNTS_G	ENDP


;	ＢＯＸ１プレーンチェック模様
;	-i- VX1,VY1 : start point.
;	    VX2,VY2 : end point.
;	    DX      : SEGMENT
;	    BP      : 0=black+black,1=black+white,2=white+black,3=white+white

BOXMTU	PROC	NEAR
	PUSH	DX
	PUSH	CX
	PUSH	BX
	PUSH	BP

	MOV	ES,DX
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES

	AND	BP,11B			;
	MOV	AL,DS:CHECKPAT[BP]	;　チェック模様テーブル

	PUSH	AX			;
	CALL	ADRSCALC		; address point calc.
	POP	AX			;

	MOV	SI,CX			; si : loop counter.
BOXMTU1:
	MOV	DI,DX			; start point.
	MOV	CX,BX			; x length.
	REP	STOSB			;

	ROR	AL,1			; dot roll.

	ADD	DX,BP			; vram width.
	DEC	SI			; loop counter.
	JNZ	BOXMTU1

	POP	BP
	POP	BX
	POP	CX
	POP	DX
	RET
BOXMTU	ENDP


;	address point calc.
;	-i- VX1: start point x1.
;	    VY1: start point y1.
;	    VX2: end x2.
;	    VY2: end y2.
;	-O- DX : start address.
;	    BX : x length.
;	    CX : y length.
;	    BP : vram width.

ADRSCALC	PROC	NEAR
	MOV	AX,VY1			;
	MUL	SSEFCW			; visual data plean width.
	MOV	DX,AX			; dx = Vy1 * 80
	ADD	DX,VX1			; dx = dx + Vx1

	MOV	CX,VY2			;
	SUB	CX,VY1			;
	INC	CX			; cx = Vy2 - Vy1 + 1

	MOV	BX,VX2			;
	SUB	BX,VX1			;
	INC	BX			; bx  = Vx2 - Vx1 + 1

	MOV	BP,SSEFCW		; visual data plean width.
	RET
ADRSCALC	ENDP


;	ＢＯＸVRAM400から479ﾗｲﾝｸﾘｱ

BOXVRAM400TO480	PROC	NEAR
	MOV	ES,ARAVRM[0]		; vram plean.(only:BOXVRAM400TO480)
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES
	MOV	DI,80*400		;
	MOV	CX,80*80/2		;
	MOV	AX,0			;
	REP	STOSW			;

	MOV	ES,ARAVRM[2]		; vram plean.(only:BOXVRAM400TO480)
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES
	MOV	DI,80*400		;
	MOV	CX,80*80/2		;
	MOV	AX,0			;
	REP	STOSW			;

	MOV	ES,ARAVRM[4]		; vram plean.(only:BOXVRAM400TO480)
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES
	MOV	DI,80*400		;
	MOV	CX,80*80/2		;
	MOV	AX,0			;
	REP	STOSW			;

	MOV	ES,ARAVRM[6]		; vram plean.(only:BOXVRAM400TO480)
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES
	MOV	DI,80*400		;
	MOV	CX,80*80/2		;
	MOV	AX,0			;
	REP	STOSW			;

	RET
BOXVRAM400TO480	ENDP


;	LED like lamp.
;	-I- DS:SI : lamp pattern.
;	    VX1   : start point x1.
;	    VY1   : start point y1.

BOXLEDLAMP	PROC	NEAR
	MOV	AX,VY1			;
	MUL	SSEFCW			; visual data plean width.
	MOV	DI,AX			; di = VY1 * 80
	ADD	DI,VX1			; di = di + VX1

	MOV	DX,SSEFCW		; vram width.
	SUB	DX,78			;
	MOV	BX,0			; plean.
	MOV	CX,4			; 4 plean.
BOXLEDLAMP_LOOP1:			;
	PUSH	CX			;
	PUSH	DI			;

	SHL	BX,1			; word pointer.
	MOV	ES,SSEFC0[BX]		;
	SHR	BX,1			;
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE)

	MOV	AL,DS:[SI][BX]		; lamp pattern.
	MOV	CX,3			; y length.
BOXLEDLAMP_LOOP2:			;
	PUSH	CX
	MOV	CX,78
	REP	STOSB			;
	ADD	DI,DX			; next line.
	POP	CX
	LOOP	BOXLEDLAMP_LOOP2	;

	INC	BX			;

	POP	DI			;
	POP	CX			;
	LOOP	BOXLEDLAMP_LOOP1	;
	RET
BOXLEDLAMP	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	SSEFC0:WORD		; visual data segment plean 0
EXTRN	SSEFC1:WORD		; visual data segment plean 1
EXTRN	SSEFC2:WORD		; visual data segment plean 2
EXTRN	SSEFC3:WORD		; visual data segment plean 3
EXTRN	SSEFCW:WORD		; visual data plean width.

EXTRN	ARAVRM:WORD		; vram plean.(only:BOXVRAM400TO480)

EXTRN	VX1:WORD		; source point x1.
EXTRN	VY1:WORD		; source point y1.
EXTRN	VX2:WORD		; length x2.
EXTRN	VY2:WORD		; length y2.

PUBLIC	CLRSOU			; 変更カラーパレット
PUBLIC	CLRDES			; 変更後カラーパレット

CLRSOU	DW	0		; 変更カラーパレット
CLRDES	DW	0		; 変更後カラーパレット

CHECKPAT LABEL	BYTE		;　チェック模様テーブル
	DB	00000000B
	DB	01010101B
	DB	10101010B
	DB	11111111B

DATA	ENDS

	END
;
;	end of "EFECT2.ASM"
;
