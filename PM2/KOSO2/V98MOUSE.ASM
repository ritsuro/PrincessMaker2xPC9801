; "V98MOUSE.ASM" 1989/12/06 R.H
;		modify 1992/05/07 r.h
;
;
;	マウスドライバー(PC9801)
;
;
; public subroutine.

INCLUDE	TSTSET.INC

IN_8259	MACRO	AA,NUM
;same;	IN	AL,NUM
	PUSH	DX
	MOV	DX,NUM			;
	CALL	IN_8259_PORT		; in  port 8259.
	POP	DX
	ENDM

OUT8259	MACRO	NUM,AA
;same;	OUT	NUM,AL
	PUSH	DX
	MOV	DX,NUM			;
	CALL	OUT_8259_PORT		; out port 8259.
	POP	DX
	ENDM

IN_8255	MACRO	AA,NUM
;same;	IN	AL,NUM
	PUSH	DX
	MOV	DX,NUM			;
	CALL	IN_8255_PORT		; in  prot 8255.
	POP	DX
	ENDM

OUT8255	MACRO	NUM,AA
;same;	OUT	NUM,AL
	PUSH	DX
	MOV	DX,NUM			;
	CALL	OUT_8255_PORT		; out prot 8255.
	POP	DX
	ENDM

DEBUGEYE	MACRO	II
	;MOV	AX,0A000H	; テキストマークの明滅
	;MOV	ES,AX		; text segment
	;MOV	WORD PTR ES:[0],II
	ENDM

MOUSEX_INIT	EQU	400		; マウス座標Ｘ
MOUSEY_INIT	EQU	250		; マウス座標Ｙ

MWRITE_REG	EQU	07FDFH		; WRITE REGISTER
MWRITE_REG2	EQU	07FDDH		; WRITE REGISTER2

MREAD_REG	EQU	07FDDH		; READ REGISTER
MTIMER		EQU	0BFDBH		; TIMER
READ_MOUSE	EQU	07FD9H		; READ MOUSE

RETRY_CHATARING EQU	5		; チャタリング防止カウント


EXTRN	MSCMOV_I:FAR		; カーソル移動／割込み

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	V98MUSINI		; マウスの初期化
PUBLIC	V98MUSRED		; マウス読み込み
PUBLIC	V98MUSWRD		; マウス読み込み・遅延処理付き
PUBLIC	V98MUSSHT		; マウス読み込み・ワンショット
PUBLIC	V98MUSSET		; マウス座標セット
PUBLIC	V98MUSSTB		; マウスボタンセット
PUBLIC	V98MUSSTP		; マウスの終了
PUBLIC	V98MUSWAT		; マウスボタンＯＦＦ待ち
PUBLIC	V98MUSDSP		; マウスＤＩＲのクリア

EXTRN	MOUSE_BTN_DELAY:NEAR	; ボタンタイマ遅延調整

EXTRN	IN_8259_PORT:NEAR	; in  port 8259.
EXTRN	OUT_8259_PORT:NEAR	; out port 8259.
EXTRN	IN_8255_PORT:NEAR	; in  prot 8255.
EXTRN	OUT_8255_PORT:NEAR	; out prot 8255.


;	マウスの初期化

V98MUSINI	PROC	NEAR
	CALL	FAR PTR MS_SET		; マウス割り込みセット
	CALL	VECSET_MOUSE_SAVE	; マウスのベクタ退避
	CALL	VECSET_MOUSE_START	; マウススタート
	CALL	MOUSE_INIT		; マウス状態の設定
	RET
V98MUSINI	ENDP


;	マウス読み込み
;	-O- AX : Ｘ座標
;	    BX : Ｙ座標
;	    DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）

V98MUSRED	PROC	NEAR
	MOV	AX,MOUSEX		; マウス座標Ｘ
	MOV	BX,MOUSEY		; マウス座標Ｙ
	MOV	DH,BYTE PTR MBTNL	; マウスボタン左側
	AND	DH,BYTE PTR MBTNLS	; マウスボタン左側(ﾕｰｻﾞ指定)
	MOV	DL,BYTE PTR MBTNR	; マウスボタン右側
	AND	DL,BYTE PTR MBTNRS	; マウスボタン右側(ﾕｰｻﾞ指定)
	RET
V98MUSRED	ENDP


;	マウス読み込み・遅延処理付き
;	-O- AX : Ｘ座標
;	    BX : Ｙ座標
;	    DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）

V98MUSWRD	PROC	NEAR
	CALL	V98MUSRED		; マウス読み込み
	CALL	MOUSE_BTN_DELAY		; ボタンタイマ遅延調整
	RET
V98MUSWRD	ENDP


;	マウス読み込み・ワンショット
;	-O- AX : Ｘ座標
;	    BX : Ｙ座標
;	    DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）

V98MUSSHT	PROC	NEAR
	PUSH	CX
	MOV	AX,MOUSEX		;マウス座標Ｘ
	MOV	BX,MOUSEY		;マウス座標Ｙ
	MOV	DH,BYTE PTR MSHTL	;マウスボタンワンショット左側
	AND	DH,BYTE PTR MSHTLS	;マウスボタンワンショット左側(ﾕｰｻﾞ指定)
	MOV	DL,BYTE PTR MSHTR	;マウスボタンワンショット右側
	AND	DL,BYTE PTR MSHTRS	;マウスボタンワンショット右側(ﾕｰｻﾞ指定)

	MOV	CH,BYTE PTR MBTNL	; マウスボタン左側
	MOV	CL,BYTE PTR MBTNR	; マウスボタン右側
	MOV	BYTE PTR MSHTL,CH	;マウスボタンワンショット左側
	MOV	BYTE PTR MSHTR,CL	;マウスボタンワンショット右側

	MOV	CH,BYTE PTR MBTNLS	; マウスボタン左側(ﾕｰｻﾞ指定)
	MOV	CL,BYTE PTR MBTNRS	; マウスボタン右側(ﾕｰｻﾞ指定)
	MOV	BYTE PTR MSHTLS,CH	;マウスボタンワンショット左側(ﾕｰｻﾞ指定)
	MOV	BYTE PTR MSHTRS,CL	;マウスボタンワンショット右側(ﾕｰｻﾞ指定)

	CALL	MOUSE_BTN_DELAY		; ボタンタイマ遅延調整
	POP	CX
	RET
V98MUSSHT	ENDP


;	マウス座標セット
;	（外部からのセット／キーボード兼用など）
;	-I- AX : Ｘ座標
;	    BX : Ｙ座標

V98MUSSET	PROC	NEAR
	MOV	MOUSEX,AX		; マウス座標Ｘ
	MOV	MOUSEY,BX		; マウス座標Ｙ
	RET
V98MUSSET	ENDP


;	マウスボタンセット
;	（外部からのセット／キーボード兼用など）
;	-I- DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）

V98MUSSTB	PROC	NEAR
	MOV	BYTE PTR MBTNLS,DH	; マウスボタン左側(ﾕｰｻﾞ指定)
	MOV	BYTE PTR MBTNRS,DL	; マウスボタン右側(ﾕｰｻﾞ指定)
	AND	BYTE PTR MSHTLS,DH	;マウスボタンワンショット左側(ﾕｰｻﾞ指定)
	AND	BYTE PTR MSHTRS,DL	;マウスボタンワンショット右側(ﾕｰｻﾞ指定)
	RET
V98MUSSTB	ENDP


;	マウスの終了

V98MUSSTP	PROC	NEAR
	CALL	FAR PTR MS_MASK		; マウス割り込みマスク
	CALL	MOUSE_DISABLE		; マウスの停止
	CALL	VECSET_MOUSE_LOAD	; マウスのベクタ
	RET
V98MUSSTP	ENDP


;	マウスボタンＯＦＦ待ち

V98MUSWAT	PROC	NEAR
MUSWAT0:
	MOV	CX,RETRY_CHATARING	; チャタリング防止カウント
MUSWAT2:				;
	PUSH	CX			;
	CALL	V98MUSRED		; マウス読み込み
	POP	CX			;
	CMP	DH,0			; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	JZ	MUSWAT0			;
	CMP	DL,0			; 右ボタン（1：ＯＦＦ／0：ＯＮ）
	JZ	MUSWAT0			;
	LOOP	MUSWAT2			;
	RET
V98MUSWAT	ENDP


;	マウスＤＩＲのクリア

V98MUSDSP	PROC	NEAR
	MOV	AX,MOUSEX		; マウス座標Ｘ
	MOV	BX,MOUSEY		; マウス座標Ｙ
	MOV	MOUSEOLDX,AX		; 前回マウス座標Ｘ
	MOV	MOUSEOLDY,BX		; 前回マウス座標Ｙ
	MOV	MUSDRX,0		; mouse locate direction x(+-)
	MOV	MUSDRY,0		; mouse locate direction y(+-)
	RET
V98MUSDSP	ENDP


;	マウス状態の初期処理

MOUSE_INIT	PROC	NEAR
	MOV	DX,MWRITE_REG	; WRITE REGISTER
	MOV	AL,10010000B	; ８２５５Ａのモードセット
	OUT8255	DX,AL		;

	MOV	DX,MWRITE_REG	; WRITE REGISTER
	MOV	AL,00001111B	; クリアカウンタ
	OUT8255	DX,AL		;

	MOV	DX,MWRITE_REG	; WRITE REGISTER
	MOV	AL,00001000B	; 割り込みイネーブル
	OUT8255	DX,AL		;

	MOV	DX,MTIMER	; TIMER 割り込み周期
	MOV	AL,00000010B	; (00:120Hz,01:60Hz,10:30Hz,11:15Hz)
	OUT8255	DX,AL		;

	RET
MOUSE_INIT	ENDP


;	マウスの停止

MOUSE_DISABLE	PROC	NEAR
	MOV	DX,MTIMER	; TIMER 割り込み周期
	MOV	AL,00000000B	; (00:120Hz,01:60Hz,10:30Hz,11:15Hz)
	OUT8255	DX,AL		;

	MOV	DX,MWRITE_REG	; WRITE REGISTER
	MOV	AL,00001001B	; 割り込みディセーブル
	OUT8255	DX,AL		;

	RET
MOUSE_DISABLE	ENDP


;	なんとなく心配なので・・・

WAITLOOP	PROC	NEAR
	PUSH	CX
	MOV	CX,100H
WAITLOOP2:
	NOP
	LOOP	WAITLOOP2
	POP	CX
	RET
WAITLOOP	ENDP




VEC_MOUSE_OFST	EQU	54H	; int 14h
VEC_MOUSE_SEG	EQU	56H	;

;	common subroutine.

VECSET_MOUSE_START	PROC	NEAR
	CLI

	MOV	AX,0		; 0 base.
	MOV	ES,AX		;
	MOV	WORD PTR ES:[VEC_MOUSE_OFST],OFFSET MOUSE_INT
	MOV	WORD PTR ES:[VEC_MOUSE_SEG],SEG CODE01

	STI
	RET
VECSET_MOUSE_START	ENDP


VECSET_MOUSE_STOP	PROC	NEAR
	CLI

	MOV	AX,0		; 0 base.
	MOV	ES,AX		;
	MOV	WORD PTR ES:[VEC_MOUSE_OFST],OFFSET MOUSE_STOP
	MOV	WORD PTR ES:[VEC_MOUSE_SEG],SEG CODE01

	STI
	RET
VECSET_MOUSE_STOP	ENDP


VECSET_MOUSE_SAVE	PROC	NEAR
	CLI

	MOV	AX,0		; 0 base.
	MOV	ES,AX		;

	MOV	AX,WORD PTR ES:[VEC_MOUSE_OFST]
	MOV	SAVE_VEC_MOUSE_OFST,AX
	MOV	AX,WORD PTR ES:[VEC_MOUSE_SEG]
	MOV	SAVE_VEC_MOUSE_SEG,AX

	STI
	RET
VECSET_MOUSE_SAVE	ENDP


VECSET_MOUSE_LOAD	PROC	NEAR
	CLI

	MOV	AX,0		; 0 base.
	MOV	ES,AX		;

	MOV	AX,SAVE_VEC_MOUSE_OFST
	MOV	WORD PTR ES:[VEC_MOUSE_OFST],AX

	MOV	AX,SAVE_VEC_MOUSE_SEG
	MOV	WORD PTR ES:[VEC_MOUSE_SEG],AX

	STI
	RET
VECSET_MOUSE_LOAD	ENDP

CODE01	ENDS


CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

;	マウス割り込みセット

MS_SET	PROC	FAR
	CALL	MOUSE_OUT		; マウス割り込みセット
	RET
MS_SET	ENDP


;	マウス割り込みマスク

MS_MASK	PROC	FAR
	CALL	MOUSE_INT_STOP		; マウス割り込みマスク
	RET
MS_MASK	ENDP



;	マウス割り込み処理

MOUSE_INT	PROC	FAR
	PUSHF
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	DS
	CLI

	CALL	MOUSE_INT_STOP	; マウス割り込みマスク

;*DBG*;	MOV	AX,0A000H	; テキストマークの明滅
;*DBG*;	MOV	DS,AX		; text segment
;*DBG*;	MOV	AX,'+'		;
;*DBG*;	CMP	AX,DS:[4]	; text offset
;*DBG*;	JNZ	CS0203		;
;*DBG*;	MOV	AX,' '		;
;*DBG*;CS0203:			;
;*DBG*;	MOV	DS:[4],AX	;

	MOV	AX,SEG DATA
	MOV	DS,AX

	MOV	DX,MWRITE_REG2	; WRITE REGISTER2
	MOV	AL,00000000B	; Ｘ軸方向下位４ｂｉｔデータ指定
	OUT8255	DX,AL		;

	MOV	DX,READ_MOUSE	; READ MOUSE
	IN_8255	AL,DX		; Ｘ軸方向下位４ｂｉｔデータＲＥＡＤ
	MOV	BL,AL		;
	AND	BL,1111B	;

	MOV	DX,MWRITE_REG2	; WRITE REGISTER2
	MOV	AL,00100000B	; Ｘ軸方向上位４ｂｉｔデータ指定
	OUT8255	DX,AL		;

	MOV	DX,READ_MOUSE	; READ MOUSE
	IN_8255	AL,DX		; Ｘ軸方向上位４ｂｉｔデータＲＥＡＤ
	SHL	AL,1		;
	SHL	AL,1		;
	SHL	AL,1		;
	SHL	AL,1		;
	OR	AL,BL		; Ｘ座標

	MOV	BYTE PTR MDX,AL		; マウス状態Ｘ


	MOV	DX,MWRITE_REG2	; WRITE REGISTER2
	MOV	AL,01000000B	; Ｙ軸方向下位４ｂｉｔデータ指定
	OUT8255	DX,AL		;

	MOV	DX,READ_MOUSE	; READ MOUSE
	IN_8255	AL,DX		; Ｙ軸方向下位４ｂｉｔデータＲＥＡＤ
	MOV	BL,AL		;
	AND	BL,1111B	;

	MOV	DX,MWRITE_REG2	; WRITE REGISTER2
	MOV	AL,01100000B	; Ｙ軸方向上位４ｂｉｔデータ指定
	OUT8255	DX,AL		;

	MOV	DX,READ_MOUSE	; READ MOUSE
	IN_8255	AL,DX		; Ｙ軸方向上位４ｂｉｔデータＲＥＡＤ
	MOV	BH,AL		;
	SHL	AL,1		;
	SHL	AL,1		;
	SHL	AL,1		;
	SHL	AL,1		;
	OR	AL,BL		; Ｙ座標

	MOV	BYTE PTR MDY,AL		; マウス状態Ｙ


	MOV	BYTE PTR MBTNR,0 ; マウスボタン右側
	MOV	BYTE PTR MBTNL,0 ; マウスボタン左側

	RCL	BH,1
	RCL	BYTE PTR MBTNL,1 ; マウスボタン左側

	RCL	BH,1
	RCL	BH,1
	RCL	BYTE PTR MBTNR,1 ; マウスボタン右側


	MOV	AL,BYTE PTR MDX		; マウス状態Ｘと
	SUB	AL,BYTE PTR MDOLDX	; 前回のマウス状態Ｘの
	CBW				; 差をとって
	ADD	MOUSEX,AX		; マウス座標Ｘへ加算する
	MOV	AL,BYTE PTR MDX		; マウス状態Ｘ
	MOV	BYTE PTR MDOLDX,AL	; 前回のマウス状態Ｘ

	MOV	AL,BYTE PTR MDY		; マウス状態Ｙと
	SUB	AL,BYTE PTR MDOLDY	; 前回のマウス状態Ｙの
	CBW				; 差をとって
	ADD	MOUSEY,AX		; マウス座標Ｙへ加算する
	MOV	AL,BYTE PTR MDY		; マウス状態Ｙ
	MOV	BYTE PTR MDOLDY,AL	; 前回のマウス状態Ｙ


	; ディレクションはじまり

	MOV	AX,MOUSEOLDX		; 前回マウス座標Ｘ
	SUB	AX,MOUSEX		; マウス座標Ｘ
	JGE	MOUSE_INT61		;
	NEG	AX			; 絶対値
MOUSE_INT61:				;
	CMP	AX,1 ;6 ;4 ;2		;
	JLE	MOUSE_INT65		;

	MOV	AX,MOUSEOLDX		; 前回マウス座標Ｘ
	CMP	AX,MOUSEX		; マウス座標Ｘ
	JL	MOUSE_INT62		;
	DEC	MUSDRX			; mouse locate direction x(+-)
	JMP	MOUSE_INT63		;
MOUSE_INT62:				;
	INC	MUSDRX			; mouse locate direction x(+-)
MOUSE_INT63:				;
MOUSE_INT65:

	CMP	MUSDRX,-1		; mouse locate direction x(+-)
	JGE	MOUSE_INT66		;
	MOV	MUSDRX,-1		; mouse locate direction x(+-)
MOUSE_INT66:
	CMP	MUSDRX,1		; mouse locate direction x(+-)
	JLE	MOUSE_INT67		;
	MOV	MUSDRX,1		; mouse locate direction x(+-)
MOUSE_INT67:


	MOV	AX,MOUSEOLDY		; 前回マウス座標Y
	SUB	AX,MOUSEY		; マウス座標Y
	JGE	MOUSE_INT71		;
	NEG	AX			; 絶対値
MOUSE_INT71:				;
	CMP	AX,1 ;6 ;4 ;2		;
	JLE	MOUSE_INT75		;

	MOV	AX,MOUSEOLDY		; 前回マウス座標Y
	CMP	AX,MOUSEY		; マウス座標Y
	JL	MOUSE_INT72		;
	DEC	MUSDRY			; mouse locate direction y(+-)
	JMP	MOUSE_INT73		;
MOUSE_INT72:				;
	INC	MUSDRY			; mouse locate direction y(+-)
MOUSE_INT73:				;
MOUSE_INT75:

	CMP	MUSDRY,-1		; mouse locate direction y(+-)
	JGE	MOUSE_INT76		;
	MOV	MUSDRY,-1		; mouse locate direction y(+-)
MOUSE_INT76:
	CMP	MUSDRY,1		; mouse locate direction y(+-)
	JLE	MOUSE_INT77		;
	MOV	MUSDRY,1		; mouse locate direction y(+-)
MOUSE_INT77:

	; ディレクションおわり

	MOV	AX,MUSAREAMINX		; mouse locate area minmam x.
	CMP	MOUSEX,AX
	JGE	MOUSE_INT2
	MOV	MOUSEX,AX
MOUSE_INT2:
	MOV	AX,MUSAREAMAXX		; mouse locate area maxmam x.
	CMP	MOUSEX,AX
	JLE	MOUSE_INT3
	MOV	MOUSEX,AX
MOUSE_INT3:

	MOV	AX,MUSAREAMINY		; mouse locate area minmam y.
	CMP	MOUSEY,AX
	JGE	MOUSE_INT4
	MOV	MOUSEY,AX
MOUSE_INT4:
	MOV	AX,MUSAREAMAXY		; mouse locate area maxmam y.
	CMP	MOUSEY,AX
	JLE	MOUSE_INT5
	MOV	MOUSEY,AX
MOUSE_INT5:

	MOV	AL,BYTE PTR MBTNL	; マウスボタン左側
	AND	BYTE PTR MSHTL,AL	; マウスボタンワンショット左側
	MOV	AL,BYTE PTR MBTNR	; マウスボタン右側
	AND	BYTE PTR MSHTR,AL	; マウスボタンワンショット右側

	MOV	AX,MOUSEX		; マウス座標Ｘ
	MOV	MOUSEOLDX,AX		; 前回マウス座標Ｘ
	MOV	AX,MOUSEY		; マウス座標Y
	MOV	MOUSEOLDY,AX		; 前回マウス座標Y

	CALL	MSCMOV_I		; カーソル移動／割込み

	CALL	MOUSE_OUT		; マウス割り込み後処理

	STI
	POP	DS
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POPF
	IRET
MOUSE_INT	ENDP




;	マウスストップ処理

MOUSE_STOP	PROC	FAR
	IRET
MOUSE_STOP	ENDP


INT_MASK	EQU	0DFH	; 割り込みマスク


;	マウス割り込みマスク

MOUSE_INT_STOP	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	DX
	IN_8259	AL,0AH		; 8259 OCW1 でＩＮＴ６をマスクする
	MOV	BL,AL		;
	MOV	AL,INT_MASK	; 割り込みマスク
	NOT	AL		;
	OR	AL,BL		;
	OUT8259	0AH,AL		;
	POP	DX
	POP	BX
	POP	AX
	RET
MOUSE_INT_STOP	ENDP


;	マウス割り込みセット

MOUSE_OUT	PROC	NEAR
	CLI
	PUSH	AX
	PUSH	DX
	MOV	AL,20H		; 8259 OCW2 非特殊ＥＯＩ割り込み終了
	OUT8259	08H,AL		;

	MOV	AL,0BH		; 8259 OCW2 ノーポールコマンド
	OUT8259	08H,AL		; ＩＳＲリード

	JMP	MOUSE_OUT1
MOUSE_OUT1:
	IN_8259	AL,08H		; 8259 ポールモードリード
;*NON*;	TEST	AL,08H		; スレーブに割り込みサービス中の
	TEST	AL,0FFH		; スレーブに割り込みサービス中の
	JNZ	MOUSE_OUT2	; 割り込みレベルがないことを確認する
	MOV	AL,20H		; マスタへＥＯＩを送る
	OUT8259	00H,AL		;
MOUSE_OUT2:			;
	MOV	AL,08H		;
	MOV	DX,7FDFH	;
	OUT8259	DX,AL		;
	JMP	MOUSE_OUT3	;
MOUSE_OUT3:
	IN_8259	AL,0AH		;
	AND	AL,INT_MASK	; 割り込みマスク
	OUT8259	0AH,AL		;
	POP	DX
	POP	AX
	JMP	MOUSE_OUT4
MOUSE_OUT4:
	STI
	RET
MOUSE_OUT	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	MUSAREAMINX:WORD		; mouse locate area minmam x.
EXTRN	MUSAREAMINY:WORD		; mouse locate area minmam y.
EXTRN	MUSAREAMAXX:WORD		; mouse locate area maxmam x.
EXTRN	MUSAREAMAXY:WORD		; mouse locate area maxmam y.

MDX		DW	0	; マウス状態Ｘ
MDY		DW	0	; マウス状態Ｙ

MDOLDX		DW	0	; 前回のマウス状態Ｘ
MDOLDY		DW	0	; 前回のマウス状態Ｙ

MOUSEX		DW	MOUSEX_INIT ; マウス座標Ｘ
MOUSEY		DW	MOUSEY_INIT ; マウス座標Ｙ

MOUSEOLDX 	DW	MOUSEX_INIT ; 前回マウス座標Ｘ
MOUSEOLDY 	DW	MOUSEY_INIT ; 前回マウス座標Ｙ

PUBLIC		MUSDRX		; mouse locate direction x(+-)
PUBLIC		MUSDRY		; mouse locate direction y(+-)
MUSDRX		DW	0	; mouse locate direction x(+-)
MUSDRY		DW	0	; mouse locate direction y(+-)

MBTNL		DW	1	; マウスボタン左側
MBTNR		DW	1	; マウスボタン右側

MBTNLS		DW	1	; マウスボタン左側(ﾕｰｻﾞ指定)
MBTNRS		DW	1	; マウスボタン右側(ﾕｰｻﾞ指定)

MSHTL		DW	1	; マウスボタンワンショット左側
MSHTR		DW	1	; マウスボタンワンショット右側

MSHTLS		DW	1	; マウスボタンワンショット左側(ﾕｰｻﾞ指定)
MSHTRS		DW	1	; マウスボタンワンショット右側(ﾕｰｻﾞ指定)

SAVE_VEC_MOUSE_OFST	DW	0	; mouse vector offset.
SAVE_VEC_MOUSE_SEG	DW	0	; mouse vector segment.


DATA	ENDS

	END
;
;	end of "V98MOUSE.ASM"
;
