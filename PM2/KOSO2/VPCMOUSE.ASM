; "VPCMOUSE.ASM" 1989/12/06 R.H
;		modify 1992/05/07 r.h
;
;
;	マウスドライバー(PC/AT)
;
;	完成時にはずすこと
;	CALLE	BBDEBUG_WINDOW_CLEARC01	; デバッグ WINDOW クリア
;
; public subroutine.

INCLUDE	TSTSET.INC

EXTRN	MSCMOV_I:FAR			; カーソル移動／割込み

MOUSEX_INIT	EQU	400		; マウス座標Ｘ
MOUSEY_INIT	EQU	250		; マウス座標Ｙ
RETRY_CHATARING	EQU	30		; チャタリング防止カウント

MOVX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	MOV	DEST,AX
	ENDM

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	VPCMUSINI		; マウスの初期化
PUBLIC	VPCMUSRED		; マウス読み込み
PUBLIC	VPCMUSWRD		; マウス読み込み・遅延処理付き
PUBLIC	VPCMUSSHT		; マウス読み込み・ワンショット
PUBLIC	VPCMUSSET		; マウス座標セット
PUBLIC	VPCMUSSTB		; マウスボタンセット
PUBLIC	VPCMUSSTP		; マウスの終了
PUBLIC	VPCMUSWAT		; マウスボタンＯＦＦ待ち
PUBLIC	VPCMUSDSP		; マウスＤＩＲのクリア

EXTRN	MOUSE_BTN_DELAY:NEAR	; ボタンタイマ遅延調整

; *********************************************************
;	マウスの初期化
; *********************************************************

VPCMUSINI	PROC	NEAR
	CMP	MODE_ADVMOUSE,1		; mouse i/o mode 0=normal,1=advance.
	JE	MUSINI_AD		;
	CALL	MUS_BIOS_INIT		; mouse bios init.
	CMP	FLG_BIOS_OK,0		; mouse bios install flag.
	JE	MUSINI_AD		;
	RET
MUSINI_AD:
	CALL	MOUSE_DRIVE_INIT	; mouse driver init.
	CMP	AX,0			; 0=normal.
	JNE	MUSINI_SKIP		;
	MOV	MODE_ADVMOUSE,1		; mouse i/o mode 0=normal,1=advance.
MUSINI_SKIP:
	RET
VPCMUSINI	ENDP


; *********************************************************
;	マウス読み込み
;	-O- AX : Ｘ座標
;	    BX : Ｙ座標
;	    DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）
; *********************************************************

VPCMUSRED	PROC	NEAR
	CMP	MODE_ADVMOUSE,1		; mouse i/o mode 0=normal,1=advance.
	JE	MUSRED_2		;
	CALL	MUS_BIOS_READ		; mouse bios read.
MUSRED_2:
	MOV	AX,MOUSEX		; マウス座標Ｘ
	MOV	BX,MOUSEY		; マウス座標Ｙ
	MOV	DH,BYTE PTR MBTNL	; マウスボタン左側
	AND	DH,BYTE PTR MBTNLS	; マウスボタン左側(ﾕｰｻﾞ指定)
	MOV	DL,BYTE PTR MBTNR	; マウスボタン右側
	AND	DL,BYTE PTR MBTNRS	; マウスボタン右側(ﾕｰｻﾞ指定)
	RET
VPCMUSRED	ENDP


; *********************************************************
;	マウス読み込み・遅延処理付き
;	-O- AX : Ｘ座標
;	    BX : Ｙ座標
;	    DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）
; *********************************************************

VPCMUSWRD	PROC	NEAR
	CALL	VPCMUSRED		; マウス読み込み
	CALL	MOUSE_BTN_DELAY		; ボタンタイマ遅延調整
	CALLE	BBDEBUG_WINDOW_CLEARC01	; デバッグ WINDOW クリア
	RET
VPCMUSWRD	ENDP


; *********************************************************
;	マウス読み込み・ワンショット
;	-O- AX : Ｘ座標
;	    BX : Ｙ座標
;	    DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）
; *********************************************************

VPCMUSSHT	PROC	NEAR
	PUSH	CX
	CMP	MODE_ADVMOUSE,1		; mouse i/o mode 0=normal,1=advance.
	JE	MUSSHT_2		;
	CALL	MUS_BIOS_READ		; mouse bios read.
MUSSHT_2:
	MOV	AX,MOUSEX		; マウス座標Ｘ
	MOV	BX,MOUSEY		; マウス座標Ｙ
	MOV	DH,BYTE PTR MSHTL	; ﾏｳｽﾎﾞﾀﾝﾜﾝｼｮｯﾄ左側
	AND	DH,BYTE PTR MSHTLS	; ﾏｳｽﾎﾞﾀﾝﾜﾝｼｮｯﾄ左側(ﾕｰｻﾞ指定)
	MOV	DL,BYTE PTR MSHTR	; ﾏｳｽﾎﾞﾀﾝﾜﾝｼｮｯﾄ右側
	AND	DL,BYTE PTR MSHTRS	; ﾏｳｽﾎﾞﾀﾝﾜﾝｼｮｯﾄ右側(ﾕｰｻﾞ指定)

	MOV	CH,BYTE PTR MBTNL	; マウスボタン左側
	MOV	CL,BYTE PTR MBTNR	; マウスボタン右側
	MOV	BYTE PTR MSHTL,CH	; ﾏｳｽﾎﾞﾀﾝﾜﾝｼｮｯﾄ左側
	MOV	BYTE PTR MSHTR,CL	; ﾏｳｽﾎﾞﾀﾝﾜﾝｼｮｯﾄ右側

	MOV	CH,BYTE PTR MBTNLS	; マウスボタン左側(ﾕｰｻﾞ指定)
	MOV	CL,BYTE PTR MBTNRS	; マウスボタン右側(ﾕｰｻﾞ指定)
	MOV	BYTE PTR MSHTLS,CH	; ﾏｳｽﾎﾞﾀﾝﾜﾝｼｮｯﾄ左側(ﾕｰｻﾞ指定)
	MOV	BYTE PTR MSHTRS,CL	; ﾏｳｽﾎﾞﾀﾝﾜﾝｼｮｯﾄ右側(ﾕｰｻﾞ指定)

	CALL	MOUSE_BTN_DELAY		; ボタンタイマ遅延調整
	POP	CX
	RET
VPCMUSSHT	ENDP


; *********************************************************
;	マウス座標セット
;	（外部からのセット／キーボード兼用など）
;	-I- AX : Ｘ座標
;	    BX : Ｙ座標
; *********************************************************

VPCMUSSET	PROC	NEAR
	MOV	MOUSEX,AX		; マウス座標Ｘ
	MOV	MOUSEY,BX		; マウス座標Ｙ
	RET
VPCMUSSET	ENDP


; *********************************************************
;	マウスボタンセット
;	（外部からのセット／キーボード兼用など）
;	-I- DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）
; *********************************************************

VPCMUSSTB	PROC	NEAR
	MOV	BYTE PTR MBTNLS,DH	; マウスボタン左側(ﾕｰｻﾞ指定)
	MOV	BYTE PTR MBTNRS,DL	; マウスボタン右側(ﾕｰｻﾞ指定)
	AND	BYTE PTR MSHTLS,DH	; ﾏｳｽﾎﾞﾀﾝﾜﾝｼｮｯﾄ左側(ﾕｰｻﾞ指定)
	AND	BYTE PTR MSHTRS,DL	; ﾏｳｽﾎﾞﾀﾝﾜﾝｼｮｯﾄ右側(ﾕｰｻﾞ指定)
	RET
VPCMUSSTB	ENDP


; *********************************************************
;	マウスの終了
; *********************************************************

VPCMUSSTP	PROC	NEAR
	CMP	MODE_ADVMOUSE,1		; mouse i/o mode 0=normal,1=advance.
	JE	MUSSTP_AD		;
	RET
MUSSTP_AD:
	CALL	MOUSE_DRIVE_END		; mouse drive end.
	RET
VPCMUSSTP	ENDP


; *********************************************************
;	マウスボタンＯＦＦ待ち
; *********************************************************

VPCMUSWAT	PROC	NEAR
MUSWAT0:
	MOV	CX,RETRY_CHATARING	; チャタリング防止カウント
MUSWAT2:				;
	PUSH	CX			;
	CALL	VPCMUSRED		; マウス読み込み
	POP	CX			;
	CMP	DH,0			; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	JZ	MUSWAT0			;
	CMP	DL,0			; 右ボタン（1：ＯＦＦ／0：ＯＮ）
	JZ	MUSWAT0			;
	LOOP	MUSWAT2			;
	RET
VPCMUSWAT	ENDP


; *********************************************************
;	マウスＤＩＲのクリア
; *********************************************************

VPCMUSDSP	PROC	NEAR
	MOV	AX,MOUSEX		; マウス座標Ｘ
	MOV	BX,MOUSEY		; マウス座標Ｙ
	MOV	MOUSEOLDX,AX		; 前回マウス座標Ｘ
	MOV	MOUSEOLDY,BX		; 前回マウス座標Ｙ
	MOV	MUSDRX,0		; mouse locate direction x(+-)
	MOV	MUSDRY,0		; mouse locate direction y(+-)
	RET
VPCMUSDSP	ENDP


; *********************************************************
;	mouse bios init.
;	-O- FLG_BIOS_OK : mouse bios install flag.1=ok,0=none
; *********************************************************

MUS_BIOS_INIT	PROC	NEAR
	MOV	AX,0			; mouse function 0.init
	INT	33H			; mouse bios.
	CMP	AX,0			; 0=none,-1=ok.
	JE	MUS_BIOS_INIT_NONE	;

	MOV	AX,7			; mouse function 7. x area set.
	MOV	CX,0			; x minimam.
	MOV	DX,639			; x maximam
	INT	33H			; mouse bios.

	MOV	AX,8			; mouse function 8. y area set.
	MOV	CX,0			; y minimam.
	MOV	DX,399			; y maximam
	INT	33H			; mouse bios.

	MOV	AX,15			; mouse function 15. move step.
	MOV	CX,8			; x step.
	MOV	DX,8			; y step.
	INT	33H			; mouse bios.

	MOV	FLG_BIOS_OK,1		; mouse bios install flag.
	RET
MUS_BIOS_INIT_NONE:
	MOV	FLG_BIOS_OK,0		; mouse bios install flag.
	RET
MUS_BIOS_INIT	ENDP


; *********************************************************
;	mouse bios read.
; *********************************************************

MUS_BIOS_READ	PROC	NEAR
	CMP	FLG_BIOS_OK,0		; mouse bios install flag.
	JMPEQ	MUS_BIOS_READ_EXIT	;

	MOV	AX,11			; mouse function 11.
	INT	33H			; mouse bios.

	CALL	M_POINT_CALC		; mouse point calc.

	MOV	AX,3			; mouse function 3.
	INT	33H			; mouse bios.

	NOT	BX			; 0=off,1=on -> 1=off,0=on
	RCR	BX,1			;
	RCL	MBTNL,1			; マウスボタン左側
	AND	MBTNL,1			;

	RCR	BX,1			;
	RCL	MBTNR,1			; マウスボタン右側
	AND	MBTNR,1			;

MUS_BIOS_READ_EXIT:			;
	RET
MUS_BIOS_READ	ENDP


; *********************************************************
;	mouse driver init.
;	-O- AX : 0=normal,1=error.
; *********************************************************

MOUSE_DRIVE_INIT	PROC	NEAR
	CLI				;

	MOV	AX,0C201H		; pointing device reset.
	INT	15H			; device bios.
	JC	MOUSE_DRIVE_INIT_ERROR	;

	MOV	AX,0C205H		; data package byte length.
	MOV	BH,3			; 3 byte.
	INT	15H			; device bios.
	JC	MOUSE_DRIVE_INIT_ERROR	;

	MOV	AX,0C203H		; resolution.
	MOV	BH,3			; 3=8count/mm
					; 00=1,01=2,02=4,03=8
	INT	15H			; device bios.

	MOV	AX,0C206H		; extended command.
	MOV	BH,2			; 1=1:1, 2=2:1
	INT	15H			; device bios.

	MOV	AX,0C202H		; sample rate set.
	MOV	BH,2			; 2=40report/sec.
					; 0=10,1=20,2=40,3=60,4=80,5=100,6=200
	INT	15H			; device bios.

	MOVX	ES,CS			;
	MOV	AX,0C207H		; pointing device driver init.
	MOV	BX,OFFSET INT_PNT_DEVICE ; pointing device int.
	INT	15H			; device bios.

	MOV	AX,0C200H		; pointing device enable/disable.
	MOV	BH,1			; 1=enable.
	INT	15H			; device bios.

	STI
	MOV	AX,0			; 0=normal.
	RET
MOUSE_DRIVE_INIT_ERROR:
	STI
	MOV	AX,1			; 1=error.
	RET
MOUSE_DRIVE_INIT	ENDP


; *********************************************************
;	mouse drive end.
; *********************************************************

MOUSE_DRIVE_END	PROC	NEAR
	CLI
	MOV	AX,0C201H		; pointing device reset.
	INT	15H			; device bios.
	MOV	AX,0C200H		; pointing device enable/disable.
	MOV	BH,0			; 0=disable.
	INT	15H			; device bios.
	STI
	RET
MOUSE_DRIVE_END	ENDP


; *********************************************************
;	pointing device int.(intractive)
; *********************************************************

INT_PNT_DEVICE	PROC	FAR
	CLI
	PUSH	BP
	MOV	BP,SP
	PUSHF
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	ES
	PUSH	DS

	MOV	AX,SEG DATA
	MOV	DS,AX

	; [BP+2] = BP
	; [BP+4] = ret offset.
	; [BP+6] = ret segment.
	; [BP+8] = [3packet]
	; [BP+A] = [2packet]
	; [BP+C] = [1packet]

	MOVX	PACKET1,[BP][12]
	MOVX	PACKET2,[BP][10]
	MOVX	PACKET3,[BP][8]

;		D7	D6	D5	D4	D3	D2	D1	D0
;  1packet	Yover	Xover	Ysign	Xsign	Zover	Zsign	RIGHT	LEFT
;  2packet	X7	X6	X5	X4	X3	X2	X1	X0
;  3packet	Y7	Y6	Y5	Y4	Y3	Y2	Y1	Y0

	XOR	CH,CH			; CH=0
	XOR	DH,DH			; DH=0
	MOV	AL,BYTE PTR PACKET1	;
	TEST	AL,00010000B		; Xsign.
	JZ	INT_PNT_DEVICE_6	;
	NOT	CH			; -X
INT_PNT_DEVICE_6:			;
	TEST	AL,00100000B		; Ysign.
	JZ	INT_PNT_DEVICE_7	;
	NOT	DH			; -Y
INT_PNT_DEVICE_7:			;
	MOV	CL,BYTE PTR PACKET2	; mouse move x.
	MOV	DL,BYTE PTR PACKET3	; mouse move y.

	NEG	DX			; y=-y
	CALL	M_POINT_CALC		; mouse point calc.

	MOV	BX,PACKET1		;
	NOT	BX			; 0=off,1=on -> 1=off,0=on

	RCR	BX,1			;
	RCL	MBTNL,1			; マウスボタン左側
	AND	MBTNL,1			;

	RCR	BX,1			;
	RCL	MBTNR,1			; マウスボタン右側
	AND	MBTNR,1			;

	POP	DS
	POP	ES
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POPF
	POP	BP
	STI
	RET
INT_PNT_DEVICE	ENDP


; *********************************************************
;	mouse point calc.
;	-I- CX : mouse move x.
;	    DX : mouse move y.
; *********************************************************

M_POINT_CALC	PROC	NEAR
	ADD	MDX,CX			; マウス状態Ｘ
	ADD	MDY,DX			; マウス状態Ｙ

	MOV	AX,MDX			; マウス状態Ｘと
	SUB	AX,MDOLDX		; 前回のマウス状態Ｘの
	ADD	MOUSEX,AX		; マウス座標Ｘへ加算する
	MOV	AX,MDX			; マウス状態Ｘ
	MOV	MDOLDX,AX		; 前回のマウス状態Ｘ

	MOV	AX,MDY			; マウス状態Ｙと
	SUB	AX,MDOLDY		; 前回のマウス状態Ｙの
	ADD	MOUSEY,AX		; マウス座標Ｙへ加算する
	MOV	AX,MDY			; マウス状態Ｙ
	MOV	MDOLDY,AX		; 前回のマウス状態Ｙ

	; ディレクションはじまり

	MOV	AX,MOUSEOLDX		; 前回マウス座標Ｘ
	SUB	AX,MOUSEX		; マウス座標Ｘ
	JGE	M_POINT_CALC61		;
	NEG	AX			; 絶対値
M_POINT_CALC61:				;
	CMP	AX,1 ;6 ;4 ;2		;
	JLE	M_POINT_CALC65		;

	MOV	AX,MOUSEOLDX		; 前回マウス座標Ｘ
	CMP	AX,MOUSEX		; マウス座標Ｘ
	JL	M_POINT_CALC62		;
	DEC	MUSDRX			; mouse locate direction x(+-)
	JMP	M_POINT_CALC63		;
M_POINT_CALC62:				;
	INC	MUSDRX			; mouse locate direction x(+-)
M_POINT_CALC63:				;
M_POINT_CALC65:

	CMP	MUSDRX,-1		; mouse locate direction x(+-)
	JGE	M_POINT_CALC66		;
	MOV	MUSDRX,-1		; mouse locate direction x(+-)
M_POINT_CALC66:
	CMP	MUSDRX,1		; mouse locate direction x(+-)
	JLE	M_POINT_CALC67		;
	MOV	MUSDRX,1		; mouse locate direction x(+-)
M_POINT_CALC67:

	MOV	AX,MOUSEOLDY		; 前回マウス座標Y
	SUB	AX,MOUSEY		; マウス座標Y
	JGE	M_POINT_CALC71		;
	NEG	AX			; 絶対値
M_POINT_CALC71:				;
	CMP	AX,1 ;6 ;4 ;2		;
	JLE	M_POINT_CALC75		;

	MOV	AX,MOUSEOLDY		; 前回マウス座標Y
	CMP	AX,MOUSEY		; マウス座標Y
	JL	M_POINT_CALC72		;
	DEC	MUSDRY			; mouse locate direction y(+-)
	JMP	M_POINT_CALC73		;
M_POINT_CALC72:				;
	INC	MUSDRY			; mouse locate direction y(+-)
M_POINT_CALC73:				;
M_POINT_CALC75:

	CMP	MUSDRY,-1		; mouse locate direction y(+-)
	JGE	M_POINT_CALC76		;
	MOV	MUSDRY,-1		; mouse locate direction y(+-)
M_POINT_CALC76:
	CMP	MUSDRY,1		; mouse locate direction y(+-)
	JLE	M_POINT_CALC77		;
	MOV	MUSDRY,1		; mouse locate direction y(+-)
M_POINT_CALC77:

	; ディレクションおわり

	MOV	AX,MUSAREAMINX		; mouse locate area minmam x.
	CMP	MOUSEX,AX
	JGE	M_POINT_CALC82
	MOV	MOUSEX,AX
M_POINT_CALC82:
	MOV	AX,MUSAREAMAXX		; mouse locate area maxmam x.
	CMP	MOUSEX,AX
	JLE	M_POINT_CALC83
	MOV	MOUSEX,AX
M_POINT_CALC83:
	MOV	AX,MUSAREAMINY		; mouse locate area minmam y.
	CMP	MOUSEY,AX
	JGE	M_POINT_CALC84
	MOV	MOUSEY,AX
M_POINT_CALC84:
	MOV	AX,MUSAREAMAXY		; mouse locate area maxmam y.
	CMP	MOUSEY,AX
	JLE	M_POINT_CALC85
	MOV	MOUSEY,AX
M_POINT_CALC85:

	MOV	AX,MOUSEX		; マウス座標Ｘ
	MOV	MOUSEOLDX,AX		; 前回マウス座標Ｘ
	MOV	AX,MOUSEY		; マウス座標Y
	MOV	MOUSEOLDY,AX		; 前回マウス座標Y

	RET
M_POINT_CALC	ENDP


CODE01	ENDS



DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	MODE_ADVMOUSE			; mouse i/o mode 0=normal,1=advance.
MODE_ADVMOUSE	DW	0		; mouse i/o mode 0=normal,1=advance.

EXTRN	MUSAREAMINX:WORD		; mouse locate area minmam x.
EXTRN	MUSAREAMINY:WORD		; mouse locate area minmam y.
EXTRN	MUSAREAMAXX:WORD		; mouse locate area maxmam x.
EXTRN	MUSAREAMAXY:WORD		; mouse locate area maxmam y.

MDX		DW	0		; マウス状態Ｘ
MDY		DW	0		; マウス状態Ｙ

MDOLDX		DW	0		; 前回のマウス状態Ｘ
MDOLDY		DW	0		; 前回のマウス状態Ｙ

MOUSEX		DW	MOUSEX_INIT	; マウス座標Ｘ
MOUSEY		DW	MOUSEY_INIT	; マウス座標Ｙ

MOUSEOLDX	DW	MOUSEX_INIT	; 前回マウス座標Ｘ
MOUSEOLDY	DW	MOUSEY_INIT	; 前回マウス座標Ｙ

EXTRN	MUSDRX:WORD			; mouse locate direction x(+-)
EXTRN	MUSDRY:WORD			; mouse locate direction y(+-)
;*;PUBLIC	MUSDRX			; mouse locate direction x(+-)
;*;PUBLIC	MUSDRY			; mouse locate direction y(+-)
;*;MUSDRX	DW	0		; mouse locate direction x(+-)
;*;MUSDRY	DW	0		; mouse locate direction y(+-)

MBTNL		DW	1		; マウスボタン左側
MBTNR		DW	1		; マウスボタン右側

MBTNLS		DW	1		; マウスボタン左側(ﾕｰｻﾞ指定)
MBTNRS		DW	1		; マウスボタン右側(ﾕｰｻﾞ指定)

MSHTL		DW	1		; ﾏｳｽﾎﾞﾀﾝﾜﾝｼｮｯﾄ左側
MSHTR		DW	1		; ﾏｳｽﾎﾞﾀﾝﾜﾝｼｮｯﾄ右側

MSHTLS		DW	1		; ﾏｳｽﾎﾞﾀﾝﾜﾝｼｮｯﾄ左側(ﾕｰｻﾞ指定)
MSHTRS		DW	1		; ﾏｳｽﾎﾞﾀﾝﾜﾝｼｮｯﾄ右側(ﾕｰｻﾞ指定)

FLG_BIOS_OK	DW	0		; mouse bios install flag.

PACKET1		DW	0		; 1packet.
PACKET2		DW	0		; 2packet.
PACKET3		DW	0		; 3packet.

DATA	ENDS

	END
;
;	end of "VPCMOUSE.ASM"
;
