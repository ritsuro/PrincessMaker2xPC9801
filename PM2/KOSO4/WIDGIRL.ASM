; "WIDGIRL.ASM" 486/50 make by R.H 1992/08/06
;
;
;	ＷＩＮＤＯＷＳ／娘
;
;
;	WID_GIRL_DIRECT		; WINDOWS/娘 direct put.
;	WID_GIRL_DRAW		; WINDOWS/娘 girl put.
;	WID_GIRL_DRAW_FCONLY	; WINDOWS/娘 girl face put.
;	WID_GIRL_SMOOTH		; WINDOWS/娘 girl noral<->dameg smooth put.
;	WID_GIRL_WALL		; WINDOWS/娘 girl back wall.
;	WID_GIRL_PMODE		; WINDOWS/娘 girl put mode.
;
;
; (C) 1991 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA


; ****************************************************
;	WINDOWS/娘 direct put.
;	-I- AX : 年齢
;	    BX : 体形　1=細,2=太
;	    CX : 表情　1=基本,2=非行,3=病気,4=元気,5=色気
;	    DX : 胸大　0=無,1=有
;	    SI : 服  0=裸
;		1=服・普段着,2=服・夏物の服,3=服・冬物の服
;		4=服・木綿のドレス,5=服・シルクのドレス
;		6=服・レーザーのドレス,7=服・トゲトゲの服
;		8=服・傾国のローブ,9=服・見えないドレス
;		10=服・悪魔のドレス,11=服・龍のレオタード
;	    DI : 重病　0=normal,1=重病
; ****************************************************

FUNC	WID_GIRL_DIRECT
	MOV	WD_GIRL_AGE,AX		; girl age.
	MOV	WD_GIRL_BODY,BX		; girl body.1=細,2=太
	MOV	WD_GIRL_FACE,CX		; girl face.1=基本,2=非行,3=病気,4=元気,5=色気
	MOV	WD_GIRL_BREAST,DX	; girl breast.0=無,1=有
	MOV	WD_GIRL_DRESS,SI	; girl dress.
	MOV	WD_GIRL_DRESS_BODY,BX	; girl dress body.1=細,2=太
	MOV	WD_GIRL_DRESS_BREAST,DX	; girl dress breast.0=無,1=有
	MOV	WD_GIRL_DAMEG,DI	; girl dameg.0=normal,1=重病

	CALL	CHECK_BODY		; check body.
	CALL	CHECK_DRESS		; check dress.

	CALL	GIRL_PUT		; 娘 put.
	RET
FEND	WID_GIRL_DIRECT


; ****************************************************
;	WINDOWS/娘 girl put.
; ****************************************************

FUNC	WID_GIRL_DRAW
	CALL	GIRL_CHECK		; 娘 check.
	CALL	GIRL_PUT		; 娘 put.
	RET
FEND	WID_GIRL_DRAW


; ****************************************************
;	WINDOWS/娘 girl face only put.
; ****************************************************

FUNC	WID_GIRL_DRAW_FCONLY
	CALL	GIRL_PUT_FACEONLY	; 娘 put face only.
	RET
FEND	WID_GIRL_DRAW_FCONLY


; ****************************************************
;	WINDOWS/娘 girl noral<->dameg smooth put.
; ****************************************************

FUNC	WID_GIRL_SMOOTH
	CALL	GIRL_CHECK		; 娘 check.
	MOV	AX,1			; 0=normal,1=smooth.
	CALL_w	PT_GIRL_SMODE		; put girl draw smooth mode.
	CALL	GIRL_PUT		; 娘 put.
	MOV	AX,0			; 0=normal,1=smooth.
	CALL_w	PT_GIRL_SMODE		; put girl draw smooth mode.
	RET
FEND	WID_GIRL_SMOOTH


; ****************************************************
;	WINDOWS/娘 girl back wall.
; ****************************************************

FUNC	WID_GIRL_WALL
	CMP	GIRL_DAMEG,0		; 重病 0=normal,1=重病
	JNE	WID_GIRL_WALL_BED	;
	CALL_w	PT_GIRL_WALLX		; put girl back wall.
	RET
WID_GIRL_WALL_BED:
	CALL_w	PT_GIRL_BEDX		; put girl back bed.
	RET
FEND	WID_GIRL_WALL


; ****************************************************
;	WINDOWS/娘 girl put mode.
;	-I- AX : girl put mode.0=normal,1=o.l.
; ****************************************************

FUNC	WID_GIRL_PMODE
	CALL_w	PT_GIRL_PMODE		; put girl put mode.
	RET
FEND	WID_GIRL_PMODE


; ****************************************************
;	娘 put.
; ****************************************************

GIRL_PUT	PROC	NEAR
	CMP	WD_GIRL_DAMEG,1		; girl dameg.0=normal,1=重病
	JE	GIRL_PUT_DAMEG		;

	MINMAX	WD_GIRL_AGE,	10,17	; 年齢
	MINMAX	WD_GIRL_BODY,	1,2	; girl body.1=細,2=太
	MINMAX	WD_GIRL_FACE,	1,5	; girl face.1=基本,2=非行,3=病気...
	MINMAX	WD_GIRL_BREAST,	0,1	; girl breast.0=無,1=有

	MINMAX	WD_GIRL_DRESS,		0,11	; girl dress.
	MINMAX	WD_GIRL_DRESS_BODY,	1,2	; girl dress body.1=細,2=太
	MINMAX	WD_GIRL_DRESS_BREAST	0,1	; girl dress breast.0=無,1=有

	CALL_w	PT_GIRL_FULL		; put girl full.
	RET
GIRL_PUT_DAMEG:
	CALL_w	PT_GIRL_DAMEG		; put girl dameg.
	RET
GIRL_PUT	ENDP


; ****************************************************
;	娘 put face only.
; ****************************************************

GIRL_PUT_FACEONLY	PROC	NEAR
	MOVX	WD_GIRL_AGE,	P_NENREI	; 年齢
	MOVX	WD_GIRL_FACE,	GIRL_FACE	; 表情 1=基本,2=非行,3病気...

	MINMAX	WD_GIRL_AGE,	10,17	; 年齢
	MINMAX	WD_GIRL_FACE,	1,5	; girl face.1=基本,2=非行,3=病気...

	CALL_w	PT_GIRL_FACEONLY	; put girl face only.
	RET
GIRL_PUT_FACEONLY	ENDP


; ****************************************************
;	娘 check.
; ****************************************************

GIRL_CHECK	PROC	NEAR
	MOVX	WD_GIRL_AGE,	P_NENREI	; 年齢
	MOVX	WD_GIRL_BODY,	GIRL_BODY	; 体形 1=細,2=太
	MOVX	WD_GIRL_FACE,	GIRL_FACE	; 表情 1=基本,2=非行,3病気...
	MOVX	WD_GIRL_BREAST,	GIRL_BREAST	; 胸大 0=無,1=有
	MOVX	WD_GIRL_DAMEG,	GIRL_DAMEG	; girl dameg.0=normal,1=重病

	MOVX	WD_GIRL_DRESS,		DRESS_NUM	; 着衣絵番号
	MOVX	WD_GIRL_DRESS_BODY,	GIRL_BODY	; 体形 1=細,2=太
	MOVX	WD_GIRL_DRESS_BREAST,	GIRL_BREAST	; 胸大 0=無,1=有

	CALL	CHECK_BODY			; check body.
	CALL	CHECK_DRESS			; check dress.

	RET
GIRL_CHECK	ENDP


; ****************************************************
;	check body.
; ****************************************************

CHECK_BODY	PROC	NEAR
	CMP	WD_GIRL_AGE,10			; １０才以下は色気無い
	JNBE	CHECK_BODY_1			;

	CMP	WD_GIRL_FACE,5			; 5=色気
	JNE	CHECK_BODY_1			;

	MOV	WD_GIRL_FACE,1			; 1=基本

CHECK_BODY_1:					;
	CMP	WD_GIRL_AGE,14			; １４才以下は胸無い
	JNBE	CHECK_BODY_2			;

	MOV	WD_GIRL_BREAST,0		; 胸大 0=無,1=有
	MOV	WD_GIRL_DRESS_BREAST,0		; 胸大 0=無,1=有
CHECK_BODY_2:
	RET
CHECK_BODY	ENDP


; ****************************************************
;	check dress.
; ****************************************************

CHECK_DRESS	PROC	NEAR
	CMP	WD_GIRL_DRESS,11		; 着衣絵番号
	JNBE	CHECK_DRESS_1			;
	CMP	WD_GIRL_DRESS,0			; 着衣絵番号
	JE	CHECK_DRESS_1			;
	JMP	CHECK_DRESS_2			;
CHECK_DRESS_1:					;
	MOV	WD_GIRL_DRESS,1			; 1=服・普段着
CHECK_DRESS_2:

	MOV	BX,WD_GIRL_DRESS		; 着衣絵番号
	DEC	BX
	SHL	BX,1
	MOVX	ES,<SEG WINDOW>
	JMP	ES:CHECK_DRESS_JMP[BX]
CHECK_DRESS_JMP	LABEL	WORD
	DW	CHECK_DRESS_1D,CHECK_DRESS_2D,CHECK_DRESS_3D,CHECK_DRESS_4D
	DW	CHECK_DRESS_5D,CHECK_DRESS_6D,CHECK_DRESS_7D,CHECK_DRESS_8D
	DW	CHECK_DRESS_9D,CHECK_DRESS_10D,CHECK_DRESS_11D

CHECK_DRESS_1D:
	MOV	WD_GIRL_DRESS_BODY,1		; 体形 細太兼用
	RET

CHECK_DRESS_2D:
	CMP	WD_GIRL_AGE,12			; １２才以下は
	JNBE	CHECK_DRESS_2D2			;
	MOV	WD_GIRL_DRESS_BODY,1		; 体形 細太兼用
CHECK_DRESS_2D2:
	RET

CHECK_DRESS_3D:
	MOV	WD_GIRL_DRESS_BODY,1		; 体形 細太兼用
	MOV	WD_GIRL_DRESS_BREAST,0		; 胸大 無
	RET

CHECK_DRESS_4D:
	MOV	WD_GIRL_DRESS_BREAST,0		; 胸大 無
	RET

CHECK_DRESS_5D:
	MOV	WD_GIRL_DRESS_BODY,1		; 体形 細太兼用
	CMP	WD_GIRL_AGE,12			; １２才以下は
	JNBE	CHECK_DRESS_5D2			;
	MOV	WD_GIRL_DRESS,0			; 着衣絵番号
CHECK_DRESS_5D2:
	RET

CHECK_DRESS_6D:
	MOV	WD_GIRL_DRESS_BODY,1		; 体形 細太兼用
	CMP	WD_GIRL_AGE,13			; １３才以下は
	JNBE	CHECK_DRESS_6D2			;
	MOV	WD_GIRL_DRESS,0			; 着衣絵番号
CHECK_DRESS_6D2:
	RET

CHECK_DRESS_7D:
	MOV	WD_GIRL_DRESS_BODY,1		; 体形 細太兼用
	CMP	WD_GIRL_AGE,12			; １２才以下は
	JNBE	CHECK_DRESS_7D2			;
	MOV	WD_GIRL_DRESS,0			; 着衣絵番号
CHECK_DRESS_7D2:
	RET

CHECK_DRESS_8D:
	MOV	WD_GIRL_DRESS_BREAST,0		; 胸大 無
	CMP	WD_GIRL_AGE,14			; １４才以下は
	JNBE	CHECK_DRESS_8D2			;
	MOV	WD_GIRL_DRESS,0			; 着衣絵番号
CHECK_DRESS_8D2:
	RET

CHECK_DRESS_9D:
	MOV	WD_GIRL_DRESS_BODY,1		; 体形 細太兼用
	MOV	WD_GIRL_DRESS_BREAST,0		; 胸大 無
	RET

CHECK_DRESS_10D:
	MOV	WD_GIRL_DRESS_BODY,1		; 体形 細太兼用
	MOV	WD_GIRL_DRESS_BREAST,0		; 胸大 無
	CMP	WD_GIRL_AGE,13			; １３才以下は
	JNBE	CHECK_DRESS_10D2		;
	MOV	WD_GIRL_DRESS,0			; 着衣絵番号
CHECK_DRESS_10D2:
	RET

CHECK_DRESS_11D:
	MOV	WD_GIRL_DRESS_BODY,1		; 体形 細太兼用
	CMP	WD_GIRL_AGE,14			; １４才以下は
	JNBE	CHECK_DRESS_11D2		;
	MOV	WD_GIRL_DRESS,0			; 着衣絵番号
CHECK_DRESS_11D2:
	RET
CHECK_DRESS	ENDP

WINDOW	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	WD_GIRL_AGE		; girl age.
PUBLIC	WD_GIRL_BODY		; girl body.1=細,2=太
PUBLIC	WD_GIRL_FACE		; girl face.1=基本,2=非行,3=病気,4=元気,5=色気
PUBLIC	WD_GIRL_BREAST		; girl breast.0=無,1=有
PUBLIC	WD_GIRL_DAMEG		; girl dameg.0=normal,1=重病

PUBLIC	WD_GIRL_DRESS		; girl dress.
PUBLIC	WD_GIRL_DRESS_BODY	; girl dress body.1=細,2=太
PUBLIC	WD_GIRL_DRESS_BREAST	; girl dress breast.0=無,1=有

EXTRN	P_NENREI:WORD		; 年齢

EXTRN	GIRL_BODY:WORD		; 体形 1=細,2=太
EXTRN	GIRL_FACE:WORD		; 表情 1=基本,2=非行,3病気,4元気,5色気
EXTRN	GIRL_BREAST:WORD	; 胸大 0=無,1=有
EXTRN	GIRL_DAMEG:WORD		; 重病 0=normal,1=重病

EXTRN	DRESS_NUM:WORD		; 着衣絵番号

EXTRN	FLAG_BYOUKI:WORD	; 状態・病気

WD_GIRL_AGE		DW 10	; girl age.
WD_GIRL_BODY		DW 1	; girl body.1=細,2=太
WD_GIRL_FACE		DW 1	; girl face.1=基本,2=非行,3=病気,4=元気,5=色気
WD_GIRL_BREAST		DW 0	; girl breast.0=無,1=有
WD_GIRL_DAMEG		DW 0	; girl dameg.0=normal,1=重病

WD_GIRL_DRESS		DW 0	; girl dress.
				; 0=裸
				; 1=服・普段着,2=服・夏物の服,3=服・冬物の服
				; 4=服・木綿のドレス,5=服・シルクのドレス
				; 6=服・レーザーのドレス,7=服・トゲトゲの服
				; 8=服・傾国のローブ,9=服・見えないドレス
				; 10=服・悪魔のドレス,11=服・龍のレオタード
WD_GIRL_DRESS_BODY	DW 0	; girl dress body.1=細,2=太
WD_GIRL_DRESS_BREAST	DW 0	; girl dress breast.0=無,1=有

DATA	ENDS

	END
;
;	end of "WIDGIRL.ASM"
;
