; "VMUSCOR.ASM" 1989/03/21 R.H  PC-9801UV11 make by R.H 1989
;		modify 1992/05/20 r.h 486/50
;
;	mouse cursole.
;
; public subroutine.

INCLUDE	TSTSET.INC
INCLUDE	MACHINEX.INC

PUBLIC	MSCMOV_I	; カーソル移動／割込み

RETFAR	MACRO			; far return.
	DB	11001011B	; RETF
	ENDM

CODE	SEGMENT	PUBLIC	'CODE'
EXTRN	XSTOPX:FAR		; ＳＴＯＰキー終了処理
CODE	ENDS

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	MSCSRT		; カーソルスタート
PUBLIC	MSCMOV		; カーソル移動
PUBLIC	MSCMV2		; カーソル移動（遅延処理無し）
PUBLIC	MSCSTP		; カーソルストップ
PUBLIC	MSCSTS		; マウスカーソルステータス
;;PUBLIC MSCPNT		; カーソル表示位置

PUBLIC	MSCCHG		; マウスカーソル選択
PUBLIC	MSCINTSW	; マウス割り込みカーソルON/OFF
PUBLIC	MSCPLNMDE	; カーソル・プレーンモード

EXTRN	MUSINI:NEAR	; マウスの初期化
EXTRN	MUSRED:NEAR	; マウス読み込み
EXTRN	MUSWRD:NEAR	; マウス読み込み・遅延処理付き
EXTRN	MUSSTP:NEAR	; マウスの終了

EXTRN	C1VV_BANK_CHG_ES:NEAR	; vram bank check & chenge.(WRITE) ES
EXTRN	C1VV_BANK_XCG_ES:NEAR	; vram bank check & chenge.(READ/WRITE) ES
EXTRN	C1VV_BANK_PLN_DS:NEAR	; vram bank check & chenge.(READ) DS

;*;					; オートデモの実行を中断させるために
;*;					; マウスボタンを利用する。
;*;	EXTRN	AUTO_DEMO_STOP:NEAR	; オート実行ストップ
	AUTO_DEMO_STOP:RET

CUSLINE		EQU	32		; カーソルライン数
CUSLINE_SV	EQU	32		; エリア退避ライン数
MUSMAX_X	EQU	640-8*4	;80-4	; マウス座標最大Ｘ
MUSMAX_Y	EQU	400-32		; マウス座標最大Ｙ
OFST_X		EQU	0		; マウス座標オフセットＸ
OFST_Y		EQU	0		; マウス座標オフセットＹ
MUSSIZ_X	EQU	4		; マウスサイズＸ
MUSSIZ_Y	EQU	4*8		; マウスサイズＹ


;	カーソルスタート

MSCSRT	PROC	NEAR
	MOV	MUSFLG,2		; 2=マウスカーソル書換中(割込防止)

	CALL	MUSWRD			; マウス読み込み・遅延処理付き
	CALL	ADJMOV			; 移動量調整

	MOV	CURX,AX			;
	MOV	CURY,BX			;

	MOV	AX,SELNUM		; 選択カーソル番号
	CALL	MSCCHG			; マウスカーソル選択

	CALL	XVRAM_SAVE		; ＶＲＡＭ退避

	CALL	XVRAM_PUT		; ＶＲＡＭカーソルＰＵＴ

	MOV	MUSFLG,1		; 1=マウスカーソル表示中
	RET
MSCSRT	ENDP


;	カーソルストップ

MSCSTP	PROC	NEAR
	MOV	MUSFLG,0		; 0=マウスＯＦＦ
	CALL	XVRAM_LOAD		; ＶＲＡＭ戻す
	RET
MSCSTP	ENDP


;	カーソル移動
;	-O- AX : Ｘ座標
;	    BX : Ｙ座標
;	    DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）

MSCMOV	PROC	NEAR
	MOV	MUSFLG,2		; 2=マウスカーソル書換中(割込防止)

	CALL	MUSWRD			; マウス読み込み・遅延処理付き
	CALL	ADJMOV			; 移動量調整

	CMP	AX,CURX			; カーソルＸ
	JNE	MSCMOV5			;

	CMP	BX,CURY			; カーソルＹ
	JNE	MSCMOV5			;

	JMP	MSCMOV9
MSCMOV5:
	PUSH	AX
	PUSH	BX
	PUSH	DX

	CALL	XVRAM_LOAD		; ＶＲＡＭ戻す

	MOV	AX,CURNEWX		; カーソル新しいＸ
	MOV	CURX,AX			;
	MOV	AX,CURNEWY		; カーソル新しいＹ
	MOV	CURY,AX			;

	CALL	XVRAM_SAVE		; ＶＲＡＭ退避
	CALL	XVRAM_PUT		; ＶＲＡＭカーソルＰＵＴ

	POP	DX
	POP	BX
	POP	AX
MSCMOV9:
	ADD	AX,OFST_X
	ADD	BX,OFST_Y

	CALL	ADJUSR			; ユーザ座標調整

;*;	CMP	CURX,0			; X	ここはデバックのための
;*;	JNE	MSCMOV_DBG		;	強制終了処理です。
;*;	CMP	CURY,0			; Y
;*;	JNE	MSCMOV_DBG		;
;*;	CMP	DH,0			;
;*;	JNE	MSCMOV_DBG		;
;*;	MOV	BP,SP			;
;*;	MOV	AX,OFFSET XSTOPX	; ＳＴＯＰキー終了処理
;*;	MOV	[BP],AX			; ＩＰ
;*;	MOV	AX,SEG CODE		;
;*;	MOV	[BP][2],AX		; ＣＳ
;*;	; SS:SP [  I P  ] +0
;*;	;       [  C S  ] +2
;*;	RETFAR				; far return.
;*;MSCMOV_DBG:

	MOV	MUSFLG,1		; 1=マウスカーソル表示中
	RET
MSCMOV	ENDP


;	カーソル移動（遅延処理無し）
;	-O- AX : Ｘ座標
;	    BX : Ｙ座標
;	    DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）

MSCMV2	PROC	NEAR
	MOV	MUSFLG,2		; 2=マウスカーソル書換中(割込防止)

	CALL	MUSRED			; マウス読み込み
	CALL	ADJMOV			; 移動量調整

	CMP	AX,CURX			; カーソルＸ
	JNE	MSCMV25			;

	CMP	BX,CURY			; カーソルＹ
	JNE	MSCMV25			;

	JMP	MSCMV29
MSCMV25:
	PUSH	AX
	PUSH	BX
	PUSH	DX

	CALL	XVRAM_LOAD		; ＶＲＡＭ戻す

	MOV	AX,CURNEWX		; カーソル新しいＸ
	MOV	CURX,AX			;
	MOV	AX,CURNEWY		; カーソル新しいＹ
	MOV	CURY,AX			;

	CALL	XVRAM_SAVE		; ＶＲＡＭ退避
	CALL	XVRAM_PUT		; ＶＲＡＭカーソルＰＵＴ

	POP	DX
	POP	BX
	POP	AX
MSCMV29:
	ADD	AX,OFST_X
	ADD	BX,OFST_Y

	CALL	ADJUSR			; ユーザ座標調整

	MOV	MUSFLG,1		; 1=マウスカーソル表示中
	RET
MSCMV2	ENDP



;	カーソル移動／割込み

MSCMOV_I	PROC	FAR
	PUSH	DS
	PUSH	ES
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	BP
	MOV	AX,SEG DATA		;
	MOV	DS,AX			;

	CMP	FLAG_MSCINTSW,0		; マウス割り込みカーソルON/OFF
	JE	MSCMOV_I_9		;

	CMP	PLEAN_MODE,1		; プレーンモード 0=片面,1=両面
	JE	MSCMOV_I_9		;

	CMP	MUSFLG,1		; 1=マウスカーソル表示中
	JE	MSCMOV_I_START		;

	JMP	MSCMOV_I_9		;

MSCMOV_I_START:
	CALL	MUSRED			; マウス読み込み
	CALL	ADJMOV			; 移動量調整

	CMP	AX,CURX			; カーソルＸ
	JNE	MSCMOV_I_5

	CMP	BX,CURY			; カーソルＹ
	JNE	MSCMOV_I_5

	JMP	MSCMOV_I_9
MSCMOV_I_5:
	MOV	DX,TBLSAVBUF[0]		; table save buffer adrs.
	MOV	VRMSAVEBUF,DX		;
	CALL	VRAM_LOAD		; ＶＲＡＭ戻す

	MOV	AX,CURNEWX		; カーソル新しいＸ
	MOV	CURX,AX
	MOV	AX,CURNEWY		; カーソル新しいＹ
	MOV	CURY,AX

	MOV	DX,TBLSAVBUF[0]		; table save buffer adrs.
	MOV	VRMSAVEBUF,DX		;
	CALL	VRAM_SAVE		; ＶＲＡＭ退避
	CALL	VRAM_PUT		; ＶＲＡＭカーソルＰＵＴ

MSCMOV_I_9:
	POP	BP
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POP	ES
	POP	DS
	RET
MSCMOV_I	ENDP


;	マウスカーソルステータス
;	-O- AX : 0=マウスＯＦＦ,1=マウスカーソル表示中

MSCSTS	PROC	NEAR
	MOV	AX,MUSFLG		; 1=マウスカーソル表示中,0=マウスＯＦＦ
	RET
MSCSTS	ENDP


;*;;	カーソル表示位置
;*;;	-O- AX : 左上Ｘ座標
;*;;	    BX : 左上Ｙ座標
;*;;	    CX : 右下Ｘ座標
;*;;	    DX : 右下Ｙ座標
;*;
;*;MSCPNT	PROC	NEAR
;*;	CALL	MSCMOV			; カーソル移動
;*;	MOV	MUSFLG,2		; 2=マウスカーソル書換中(割込防止)
;*;	MOV	CX,AX			; Ｘ座標
;*;	MOV	DX,BX			; Ｙ座標
;*;	ADD	CX,MUSSIZ_X		; マウスサイズＸ
;*;	ADD	DX,MUSSIZ_Y		; マウスサイズＹ
;*;	RET
;*;MSCPNT	ENDP


;	移動量調整
;	-I/O- AX : Ｘ座標
;	      BX : Ｙ座標
;	-O-   CURNEWX : カーソル新しいＸ
;	      CURNEWY : カーソル新しいＹ

ADJMOV	PROC	NEAR
	TEST	AX,8000H
	JZ	ADJMOV20
	MOV	AX,0
	JMP	ADJMOV2
ADJMOV20:
	CMP	AX,MUSMAX_X		; マウス座標最大Ｘ
	JLE	ADJMOV2			;
	MOV	AX,MUSMAX_X		; マウス座標最大Ｘ
ADJMOV2:
	MOV	CURNEWX,AX		; カーソル新しいＸ

	TEST	BX,8000H
	JZ	ADJMOV30
	MOV	BX,0
	JMP	ADJMOV3
ADJMOV30:
	CMP	BX,MUSMAX_Y		; マウス座標最大Ｙ
	JLE	ADJMOV3			;
	MOV	BX,MUSMAX_Y		; マウス座標最大Ｙ
ADJMOV3:
	MOV	CURNEWY,BX		; カーソル新しいＹ
	RET
ADJMOV	ENDP


;	ユーザ座標調整
;	-I/O- AX : Ｘ座標
;	      BX : Ｙ座標

ADJUSR	PROC	NEAR
	SHR	AX,1			; AX = AX / 8
	SHR	AX,1			;
	SHR	AX,1			;

	CMP	MOVE_MODE,1		; カーソル移動モード
	JE	ADJUSR_1		;
	SHR	BX,1			; BX = BX / 8
	SHR	BX,1			;
	SHR	BX,1			;
ADJUSR_1:
	RET
ADJUSR	ENDP


;	デモモード制御
;	オートデモの実行を中断させるために
;	マウスボタンを利用する。
;	-I- DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）

DEMO_MUS_MODE	PROC	NEAR
	CMP	DH,0			; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	DEMO_MUS_MODE_1		;
	CMP	DL,0			; 右ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	DEMO_MUS_MODE_1		;
	JMP	DEMO_MUS_MODE_2		;
DEMO_MUS_MODE_1:			;
	PUSH	AX
	PUSH	BX
	PUSH	DX
	CALL	AUTO_DEMO_STOP		; オート実行ストップ
	POP	DX
	POP	BX
	POP	AX
DEMO_MUS_MODE_2:
	RET
DEMO_MUS_MODE	ENDP


;	マウスカーソル選択
;	-I- AX : カーソル番号

MSCCHG	PROC	NEAR
	MOV	SELNUM,AX			; 選択カーソル番号
	CMP	AX,0
	JE	MSCCHG_1
	CMP	AX,1
	JE	MSCCHG_2
	RET
MSCCHG_1:
	MOV	AX,OFFSET MUSCURSOLE_1
	MOV	SELDAT0,AX
	MOV	AX,OFFSET MUSCURSOLE_1+4*32	
	MOV	SELDAT1,AX
	MOV	AX,OFFSET MUSCURSOLE_1+4*32*2
	MOV	SELDAT2,AX
	MOV	AX,OFFSET MUSCURSOLE_1+4*32*3
	MOV	SELDAT3,AX
	MOV	AX,OFFSET MUSCURSOLE_1+4*32*4	; カーソルマスク
	MOV	SELMSK,AX

	JMP	MSCCHG_DATSET

MSCCHG_2:
	MOV	AX,OFFSET MUSCURSOLE_3
	MOV	SELDAT0,AX
	MOV	AX,OFFSET MUSCURSOLE_3+4*32	
	MOV	SELDAT1,AX
	MOV	AX,OFFSET MUSCURSOLE_3+4*32*2
	MOV	SELDAT2,AX
	MOV	AX,OFFSET MUSCURSOLE_3+4*32*3
	MOV	SELDAT3,AX
	MOV	AX,OFFSET MUSCURSOLE_3+4*32*4	; カーソルマスク
	MOV	SELMSK,AX

MSCCHG_DATSET:
	MOVX	ES,DS
	MOV	SI,SELDAT0
	MOV	DI,OFFSET VRMBUF0
	MOV	CX,32
	MOV	AL,0
MSCCHG_51:
	MOVSW
	MOVSW
	STOSB
	LOOP	MSCCHG_51

	MOV	SI,SELDAT1
	MOV	DI,OFFSET VRMBUF1
	MOV	CX,32
	MOV	AL,0
MSCCHG_52:
	MOVSW
	MOVSW
	STOSB
	LOOP	MSCCHG_52

	MOV	SI,SELDAT2
	MOV	DI,OFFSET VRMBUF2
	MOV	CX,32
	MOV	AL,0
MSCCHG_53:
	MOVSW
	MOVSW
	STOSB
	LOOP	MSCCHG_53

	MOV	SI,SELDAT3
	MOV	DI,OFFSET VRMBUF3
	MOV	CX,32
	MOV	AL,0
MSCCHG_54:
	MOVSW
	MOVSW
	STOSB
	LOOP	MSCCHG_54


	MOV	SI,SELMSK
	MOV	DI,OFFSET VRMBUFM
	MOV	CX,32
	MOV	AL,0FFH
MSCCHG_55:
	MOVSW
	MOVSW
	STOSB
	LOOP	MSCCHG_55

	MOV	NOWSHIFT,0		; 現在のシフト量
	RET
MSCCHG	ENDP


;	マウス割り込みカーソルON/OFF
;	-I- AX : 1=ON,0=OFF

MSCINTSW	PROC	NEAR
	MOV	FLAG_MSCINTSW,AX	; マウス割り込みカーソルON/OFF
	RET
MSCINTSW	ENDP


;	カーソル・プレーンモード
;	-I- AX : 0=normal put,1=two side put.

MSCPLNMDE	PROC	NEAR
	MOV	PLEAN_MODE,AX		; プレーンモード 0=片面,1=両面
	RET
MSCPLNMDE	ENDP


;	ＶＲＡＭ退避

XVRAM_SAVE	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JNE	XVRAM_SAVE_ONE_SIDE	;
	CMP	PLEAN_MODE,1		; プレーンモード 0=片面,1=両面
	JE	XVRAM_SAVE_TWO_SIDE	;
XVRAM_SAVE_ONE_SIDE:
	MOV	DX,TBLSAVBUF[0]		; table save buffer adrs.
	MOV	VRMSAVEBUF,DX		;
	CALL	VRAM_SAVE		; ＶＲＡＭ退避
	RET
XVRAM_SAVE_TWO_SIDE:
	CALLE	VRM98NOW			; PC98 vram bank now.
	MOV	AX,BX				;
	PUSH	AX				; 0=VRAM0 write,1=VRAM1 write.

	XOR	AX,1				;
	MOV	BX,AX				;
	SHL	BX,1				; word pointer.
	MOV	DX,TBLSAVBUF[BX]		; table save buffer adrs.
	MOV	VRMSAVEBUF,DX			;
	CALLE	VRM98WT				; PC98 vram write bank.
	CALL	VRAM_SAVE			; ＶＲＡＭ退避

	POP	AX				;
	MOV	BX,AX				;
	SHL	BX,1				; word pointer.
	MOV	DX,TBLSAVBUF[BX]		; table save buffer adrs.
	MOV	VRMSAVEBUF,DX			;
	CALLE	VRM98WT				; PC98 vram write bank.
	CALL	VRAM_SAVE			; ＶＲＡＭ退避
	RET
XVRAM_SAVE	ENDP


;	ＶＲＡＭ戻す

XVRAM_LOAD	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JNE	XVRAM_LOAD_ONE_SIDE	;
	CMP	PLEAN_MODE,1		; プレーンモード 0=片面,1=両面
	JE	XVRAM_LOAD_TWO_SIDE	;
XVRAM_LOAD_ONE_SIDE:
	MOV	DX,TBLSAVBUF[0]		; table save buffer adrs.
	MOV	VRMSAVEBUF,DX		;
	CALL	VRAM_LOAD		; ＶＲＡＭ戻す
	RET
XVRAM_LOAD_TWO_SIDE:
	CALLE	VRM98NOW			; PC98 vram bank now.
	MOV	AX,BX				;
	PUSH	AX				; 0=VRAM0 write,1=VRAM1 write.

	XOR	AX,1				;
	MOV	BX,AX				;
	SHL	BX,1				; word pointer.
	MOV	DX,TBLSAVBUF[BX]		; table save buffer adrs.
	MOV	VRMSAVEBUF,DX			;
	CALLE	VRM98WT				; PC98 vram write bank.
	CALL	VRAM_LOAD			; ＶＲＡＭ戻す

	POP	AX				;
	MOV	BX,AX				;
	SHL	BX,1				; word pointer.
	MOV	DX,TBLSAVBUF[BX]		; table save buffer adrs.
	MOV	VRMSAVEBUF,DX			;
	CALLE	VRM98WT				; PC98 vram write bank.
	CALL	VRAM_LOAD			; ＶＲＡＭ戻す
	RET
XVRAM_LOAD	ENDP


;	ＶＲＡＭカーソルＰＵＴ

XVRAM_PUT	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JNE	XVRAM_PUT_ONE_SIDE	;
	CMP	PLEAN_MODE,1		; プレーンモード 0=片面,1=両面
	JE	XVRAM_PUT_TWO_SIDE	;
XVRAM_PUT_ONE_SIDE:
	CALL	VRAM_PUT		; ＶＲＡＭカーソルＰＵＴ
	RET
XVRAM_PUT_TWO_SIDE:
	CALLE	VRM98NOW			; PC98 vram bank now.
	MOV	AX,BX				;
	PUSH	AX				; 0=VRAM0 write,1=VRAM1 write.

	XOR	AX,1				;
	MOV	BX,AX				;
	SHL	BX,1				; word pointer.
	CALLE	VRM98WT				; PC98 vram write bank.
	CALL	VRAM_PUT			; ＶＲＡＭカーソルＰＵＴ

	POP	AX				;
	MOV	BX,AX				;
	SHL	BX,1				; word pointer.
	CALLE	VRM98WT				; PC98 vram write bank.
	CALL	VRAM_PUT			; ＶＲＡＭカーソルＰＵＴ
	RET
XVRAM_PUT	ENDP


;	ＶＲＡＭ退避

VRAM_SAVE	PROC	NEAR
	PUSH	DS

	MOV	AX,CURY			; カーソルＹ
	MUL	SSCURW			; * visual data plean width.
	MOV	DX,CURX			;
	SHR	DX,1			;
	SHR	DX,1			;
	SHR	DX,1			;
	ADD	AX,DX			; + カーソルＸ/8
	MOV	BX,AX			; BX =

	MOV	SI,BX			; 先頭オフセット

	MOV	DI,VRMSAVEBUF		; ＶＲＡＭ退避エリア

	MOV	BP,SSCURW		; BP=visual data plean width.
	SUB	BP,5			; add width.

	MOVX	ES,DS			; データセグメント

	MOV	DX,DS

	MOVX	DS,SSCUR0		; visual data segment plean 0
	CALL	C1VV_BANK_PLN_DS	; vram bank check & chenge.(READ) DS
	MOV	CX,CUSLINE_SV		; エリア退避ライン数
VRAM_SAVE2:
	MOVSW				;
	MOVSW				;
	MOVSB				;
	ADD	SI,BP			; add width.
	LOOP	VRAM_SAVE2

	MOV	SI,BX			; 先頭オフセット

	MOV	DS,DX			;

	MOVX	DS,SSCUR1		; visual data segment plean 1
	CALL	C1VV_BANK_PLN_DS	; vram bank check & chenge.(READ) DS
	MOV	CX,CUSLINE_SV		; エリア退避ライン数
VRAM_SAVE3:
	MOVSW				;
	MOVSW				;
	MOVSB				;
	ADD	SI,BP			; add width.
	LOOP	VRAM_SAVE3

	MOV	SI,BX			; 先頭オフセット

	MOV	DS,DX			;

	MOVX	DS,SSCUR2		; visual data segment plean 2
	CALL	C1VV_BANK_PLN_DS	; vram bank check & chenge.(READ) DS
	MOV	CX,CUSLINE_SV		; エリア退避ライン数
VRAM_SAVE4:
	MOVSW				;
	MOVSW				;
	MOVSB				;
	ADD	SI,BP			; add width.
	LOOP	VRAM_SAVE4

	MOV	SI,BX			; 先頭オフセット

	MOV	DS,DX			;

	MOVX	DS,SSCUR3		; visual data segment plean 3
	CALL	C1VV_BANK_PLN_DS	; vram bank check & chenge.(READ) DS
	MOV	CX,CUSLINE_SV		; エリア退避ライン数
VRAM_SAVE5:
	MOVSW				;
	MOVSW				;
	MOVSB				;
	ADD	SI,BP			; add width.
	LOOP	VRAM_SAVE5

	POP	DS
	RET
VRAM_SAVE	ENDP



;	ＶＲＡＭ戻す

VRAM_LOAD	PROC	NEAR
	MOV	AX,CURY			; カーソルＹ
	MUL	SSCURW			; * visual data plean width.
	MOV	DX,CURX			;
	SHR	DX,1			;
	SHR	DX,1			;
	SHR	DX,1			;
	ADD	AX,DX			; + カーソルＸ/8
	MOV	BX,AX			; BX =

	MOV	SI,VRMSAVEBUF		; ＶＲＡＭ退避エリア

	MOV	DI,BX			; 先頭オフセット

	MOV	BP,SSCURW		; BP=visual data plean width.
	SUB	BP,5			; add width.

	MOV	ES,SSCUR0		; visual data segment plean 0
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES
	MOV	CX,CUSLINE_SV		; エリア退避ライン数
VRAM_LOAD2:
	MOVSW				;
	MOVSW				;
	MOVSB				;
	ADD	DI,BP			; add width.
	LOOP	VRAM_LOAD2

	MOV	DI,BX			; 先頭オフセット

	MOV	ES,SSCUR1		; visual data segment plean 1
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES
	MOV	CX,CUSLINE_SV		; エリア退避ライン数
VRAM_LOAD3:
	MOVSW				;
	MOVSW				;
	MOVSB				;
	ADD	DI,BP			; add width.
	LOOP	VRAM_LOAD3

	MOV	DI,BX			; 先頭オフセット

	MOV	ES,SSCUR2		; visual data segment plean 2
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES
	MOV	CX,CUSLINE_SV		; エリア退避ライン数
VRAM_LOAD4:
	MOVSW				;
	MOVSW				;
	MOVSB				;
	ADD	DI,BP			; add width.
	LOOP	VRAM_LOAD4

	MOV	DI,BX			; 先頭オフセット

	MOV	ES,SSCUR3		; visual data segment plean 3
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES
	MOV	CX,CUSLINE_SV		; エリア退避ライン数
VRAM_LOAD5:
	MOVSW				;
	MOVSW				;
	MOVSB				;
	ADD	DI,BP			; add width.
	LOOP	VRAM_LOAD5

	RET
VRAM_LOAD	ENDP


;	ＶＲＡＭカーソルＰＵＴ

VRAM_PUT	PROC	NEAR
	PUSH	DX
	PUSH	BP
	MOV	AX,CURX			; + カーソルＸ
	MOV	DX,0			;
	MOV	CX,8			;
	DIV	CX			;
	PUSH	AX			;
	CALL	MOUSE_SHIFT		; マウスデータシフト
	POP	BX
	POP	BP
	POP	DX

	MOV	AX,CURY			; カーソルＹ
	MUL	SSCURW			; * visual data plean width.
	ADD	BX,AX			; BX=start address.

	MOV	BP,SSCURW		; BP=visual data plean width.
	SUB	BP,5			; add width.

	MOV	SI,CUSMSK		; カーソルマスク
	MOV	DI,BX			; 先頭オフセット
	MOV	ES,SSCUR0		; visual data segment plean 0
	CALL	C1VV_BANK_XCG_ES	;vram bank check & chenge.(READ/WRITE)
	MOV	CX,CUSLINE		; カーソルライン数
VRAM_PUT2:
	LODSW				;
	AND	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSW				;
	AND	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSB				;
	AND	ES:[DI],AL		;
	INC	DI			;
	ADD	DI,BP			; add width.
	LOOP	VRAM_PUT2

	MOV	SI,CUSDAT0		; カーソル
	MOV	DI,BX			; 先頭オフセット
	MOV	CX,CUSLINE		; カーソルライン数
VRAM_PUT22:
	LODSW				;
	OR	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSW				;
	OR	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSB				;
	OR	ES:[DI],AL		;
	INC	DI			;
	ADD	DI,BP			; add width.
	LOOP	VRAM_PUT22

	MOV	SI,CUSMSK		; カーソルマスク
	MOV	DI,BX			; 先頭オフセット
	MOV	ES,SSCUR1		; visual data segment plean 1
	CALL	C1VV_BANK_XCG_ES	;vram bank check & chenge.(READ/WRITE)
	MOV	CX,CUSLINE		; カーソルライン数
VRAM_PUT3:
	LODSW				;
	AND	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSW				;
	AND	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSB				;
	AND	ES:[DI],AL		;
	INC	DI			;
	ADD	DI,BP			; add width.
	LOOP	VRAM_PUT3


	MOV	SI,CUSDAT1		; カーソル
	MOV	DI,BX			; 先頭オフセット
	MOV	CX,CUSLINE		; カーソルライン数
VRAM_PUT33:
	LODSW				;
	OR	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSW				;
	OR	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSB				;
	OR	ES:[DI],AL		;
	INC	DI			;
	ADD	DI,BP			; add width.
	LOOP	VRAM_PUT33


	MOV	SI,CUSMSK		; カーソルマスク
	MOV	DI,BX			; 先頭オフセット
	MOV	ES,SSCUR2		; visual data segment plean 2
	CALL	C1VV_BANK_XCG_ES	;vram bank check & chenge.(READ/WRITE)
	MOV	CX,CUSLINE		; カーソルライン数
VRAM_PUT4:
	LODSW				;
	AND	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSW				;
	AND	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSB				;
	AND	ES:[DI],AL		;
	INC	DI			;
	ADD	DI,BP			; add width.
	LOOP	VRAM_PUT4


	MOV	SI,CUSDAT2		; カーソル
	MOV	DI,BX			; 先頭オフセット
	MOV	CX,CUSLINE		; カーソルライン数
VRAM_PUT44:
	LODSW				;
	OR	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSW				;
	OR	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSB				;
	OR	ES:[DI],AL		;
	INC	DI			;
	ADD	DI,BP			; add width.
	LOOP	VRAM_PUT44


	MOV	SI,CUSMSK		; カーソルマスク
	MOV	DI,BX			; 先頭オフセット
	MOV	ES,SSCUR3		; visual data segment plean 3
	CALL	C1VV_BANK_XCG_ES	;vram bank check & chenge.(READ/WRITE)
	MOV	CX,CUSLINE		; カーソルライン数
VRAM_PUT5:
	LODSW				;
	AND	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSW				;
	AND	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSB				;
	AND	ES:[DI],AL		;
	INC	DI			;
	ADD	DI,BP			; add width.
	LOOP	VRAM_PUT5


	MOV	SI,CUSDAT3		; カーソル
	MOV	DI,BX			; 先頭オフセット
	MOV	CX,CUSLINE		; カーソルライン数
VRAM_PUT55:
	LODSW				;
	OR	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSW				;
	OR	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LODSB				;
	OR	ES:[DI],AL		;
	INC	DI			;
	ADD	DI,BP			; add width.
	LOOP	VRAM_PUT55

	RET
VRAM_PUT	ENDP


;	マウスデータシフト
;	-I- DX : シフト量

MOUSE_SHIFT	PROC	NEAR
	CMP	DX,NOWSHIFT		; 現在のシフト量
	JL	MOUSE_SHIFT_LT		;
	JG	MOUSE_SHIFT_GT		;
	RET
MOUSE_SHIFT_LT:
	MOV	AX,DX			;
	MOV	BX,NOWSHIFT		; 現在のシフト量
	SUB	BX,DX			; 新しいシフト量
	MOV	DX,BX			;
	MOV	NOWSHIFT,AX		; 現在のシフト量
	MOV	SI,OFFSET VRMBUF0	; ＶＲＡＭエリア
	CALL	MOUSE_SHIFT_LEFT	; mouse shift left.
	MOV	SI,OFFSET VRMBUF1	; ＶＲＡＭエリア
	CALL	MOUSE_SHIFT_LEFT	; mouse shift left.
	MOV	SI,OFFSET VRMBUF2	; ＶＲＡＭエリア
	CALL	MOUSE_SHIFT_LEFT	; mouse shift left.
	MOV	SI,OFFSET VRMBUF3	; ＶＲＡＭエリア
	CALL	MOUSE_SHIFT_LEFT	; mouse shift left.
	MOV	SI,OFFSET VRMBUFM	; ＶＲＡＭエリア
	CALL	MOUSE_SHIFT_LEFT	; mouse shift left.
	RET
MOUSE_SHIFT_GT:
	MOV	AX,DX			;
	SUB	DX,NOWSHIFT		; 現在のシフト量
	MOV	NOWSHIFT,AX		; 現在のシフト量
	MOV	SI,OFFSET VRMBUF0	; ＶＲＡＭエリア
	CALL	MOUSE_SHIFT_RIGHT	; mouse shift right.
	MOV	SI,OFFSET VRMBUF1	; ＶＲＡＭエリア
	CALL	MOUSE_SHIFT_RIGHT	; mouse shift right.
	MOV	SI,OFFSET VRMBUF2	; ＶＲＡＭエリア
	CALL	MOUSE_SHIFT_RIGHT	; mouse shift right.
	MOV	SI,OFFSET VRMBUF3	; ＶＲＡＭエリア
	CALL	MOUSE_SHIFT_RIGHT	; mouse shift right.
	MOV	SI,OFFSET VRMBUFM	; ＶＲＡＭエリア
	CALL	MOUSE_SHIFT_RIGHT	; mouse shift right.
	RET
MOUSE_SHIFT	ENDP


;	mouse shift right.
;	-I- DL : shift.
;	    SI : data address.

MOUSE_SHIFT_RIGHT	PROC	NEAR
	CMP	DL,0
	JNE	MOUSE_SHIFT_RIGHT_START
	RET
MOUSE_SHIFT_RIGHT_START:
	MOV	CX,32
MOUSE_SHIFT_1:
	MOV	BP,CX
	MOV	AX,DS:[SI]
	MOV	BX,DS:[SI][2]
	MOV	DH,DS:[SI][4]
	XCHG	AH,AL
	XCHG	BH,BL
	MOV	CH,0
	MOV	CL,DL
	ROR	DH,1
	ROL	DH,1
MOUSE_SHIFT_12:
	RCR	AX,1
	RCR	BX,1
	RCR	DH,1
	LOOP	MOUSE_SHIFT_12
	XCHG	AH,AL
	XCHG	BH,BL
	MOV	DS:[SI],AX
	MOV	DS:[SI][2],BX
	MOV	DS:[SI][4],DH
	ADD	SI,5
	MOV	CX,BP
	LOOP	MOUSE_SHIFT_1
	RET
MOUSE_SHIFT_RIGHT	ENDP

;	mouse shift right.
;	-I- DL : shift.
;	    SI : data address.

MOUSE_SHIFT_LEFT	PROC	NEAR
	CMP	DL,0
	JNE	MOUSE_SHIFT_LEFT_START
	RET
MOUSE_SHIFT_LEFT_START:
	MOV	CX,32
MOUSE_SHIFT_LEFT_1:
	MOV	BP,CX
	MOV	AX,DS:[SI]
	MOV	BX,DS:[SI][2]
	MOV	DH,DS:[SI][4]
	XCHG	AH,AL
	XCHG	BH,BL
	MOV	CH,0
	MOV	CL,DL
	ROL	AH,1
	ROR	AH,1
MOUSE_SHIFT_LEFT_12:
	RCL	DH,1
	RCL	BX,1
	RCL	AX,1
	LOOP	MOUSE_SHIFT_LEFT_12
	XCHG	AH,AL
	XCHG	BH,BL
	MOV	DS:[SI],AX
	MOV	DS:[SI][2],BX
	MOV	DS:[SI][4],DH
	ADD	SI,5
	MOV	CX,BP
	LOOP	MOUSE_SHIFT_LEFT_1
	RET
MOUSE_SHIFT_LEFT	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	SSCUR0:WORD		; visual data segment plean 0
EXTRN	SSCUR1:WORD		; visual data segment plean 1
EXTRN	SSCUR2:WORD		; visual data segment plean 2
EXTRN	SSCUR3:WORD		; visual data segment plean 3
EXTRN	SSCURW:WORD		; visual data plean width.

SELNUM		DW	0			; 選択カーソル番号
SELDAT0	DW	OFFSET MUSCURSOLE_3
SELDAT1	DW	OFFSET MUSCURSOLE_3+4*32	
SELDAT2	DW	OFFSET MUSCURSOLE_3+4*32*2
SELDAT3	DW	OFFSET MUSCURSOLE_3+4*32*3
SELMSK	DW	OFFSET MUSCURSOLE_3+4*32*4

CUSDAT0	DW	OFFSET VRMBUF0
CUSDAT1	DW	OFFSET VRMBUF1
CUSDAT2	DW	OFFSET VRMBUF2
CUSDAT3	DW	OFFSET VRMBUF3
CUSMSK	DW	OFFSET VRMBUFM

NOWSHIFT	DW	0			; 現在のシフト量
VRMBUF0		DB	32*5 DUP (?)		; ＶＲＡＭエリア
VRMBUF1		DB	32*5 DUP (?)		;
VRMBUF2		DB	32*5 DUP (?)		;
VRMBUF3		DB	32*5 DUP (?)		;
VRMBUFM		DB	32*5 DUP (?)		;

MUSCURSOLE_1	LABEL	BYTE
MUSCURSOLE_2	LABEL	BYTE
MUSCURSOLE_3	LABEL	BYTE
MUSCURSOLE_4	LABEL	BYTE
		DB	000H,000H,000H,000H,010H,000H,000H,000H
		DB	004H,000H,000H,000H,008H,000H,000H,000H
		DB	004H,000H,000H,000H,004H,080H,000H,000H
		DB	003H,040H,000H,000H,001H,000H,00aH,000H
		DB	000H,0c0H,000H,000H,000H,048H,000H,000H
		DB	000H,034H,008H,000H,000H,010H,080H,000H
		DB	000H,008H,040H,000H,000H,004H,000H,000H
		DB	000H,001H,000H,020H,000H,010H,030H,070H
		DB	000H,000H,088H,064H,000H,000H,013H,010H
		DB	000H,008H,000H,006H,000H,081H,044H,017H
		DB	000H,000H,00aH,00cH,000H,080H,004H,014H
		DB	000H,021H,002H,028H,000H,000H,0c0H,0d0H
		DB	000H,002H,0c0H,02eH,000H,014H,0c4H,083H
		DB	000H,00aH,000H,000H,000H,005H,051H,05aH
		DB	000H,000H,0aaH,000H,000H,000H,001H,002H
		DB	000H,000H,021H,002H,000H,000H,031H,080H
		DB	0e0H,000H,000H,000H,0f8H,000H,000H,000H
		DB	07eH,000H,000H,000H,03eH,000H,000H,000H
		DB	03fH,080H,00aH,000H,01dH,0c0H,00aH,000H
		DB	006H,0e0H,000H,000H,007H,060H,000H,000H
		DB	003H,0b8H,000H,000H,001H,0dcH,00fH,080H
		DB	000H,06eH,0c1H,0e0H,000H,070H,030H,070H
		DB	000H,034H,010H,038H,000H,013H,018H,038H
		DB	000H,003H,018H,07cH,000H,010H,089H,01cH
		DB	000H,010H,033H,01cH,000H,008H,060H,07cH
		DB	000H,00fH,0f0H,01dH,006H,023H,0caH,00cH
		DB	000H,020H,00cH,014H,006H,020H,04eH,02cH
		DB	000H,030H,0c1H,0d0H,000H,030H,001H,0ebH
		DB	000H,019H,001H,0f1H,000H,01fH,023H,0d0H
		DB	000H,00fH,0ffH,0e0H,000H,007H,0ffH,0ceH
		DB	000H,001H,0feH,002H,000H,000H,000H,08aH
		DB	000H,000H,010H,0c0H,000H,000H,000H,000H
		DB	0c0H,000H,000H,000H,0f0H,000H,000H,000H
		DB	07cH,000H,000H,000H,034H,000H,000H,000H
		DB	03aH,000H,00aH,000H,01bH,080H,00aH,000H
		DB	00dH,0c0H,00aH,000H,006H,0c0H,00aH,000H
		DB	003H,060H,000H,000H,001H,0b8H,000H,000H
		DB	000H,0dcH,089H,080H,000H,068H,0a0H,060H
		DB	000H,028H,040H,030H,000H,015H,010H,030H
		DB	000H,002H,010H,058H,000H,000H,029H,0e8H
		DB	000H,010H,0b1H,0bcH,000H,008H,043H,068H
		DB	000H,007H,0f0H,03fH,007H,082H,088H,00fH
		DB	000H,000H,004H,014H,007H,0a0H,000H,02cH
		DB	000H,001H,042H,0d0H,000H,020H,0c1H,00bH
		DB	000H,013H,0c1H,017H,000H,00bH,067H,033H
		DB	000H,005H,0ffH,0e0H,000H,002H,0aeH,096H
		DB	000H,001H,054H,00eH,000H,000H,001H,084H
		DB	000H,000H,031H,0c2H,000H,000H,031H,080H
		DB	040H,000H,000H,000H,070H,000H,000H,000H
		DB	03cH,000H,000H,000H,034H,000H,000H,000H
		DB	01aH,000H,00aH,000H,019H,080H,00aH,000H
		DB	005H,0c0H,000H,000H,006H,040H,000H,000H
		DB	003H,060H,000H,000H,001H,098H,000H,000H
		DB	000H,05cH,081H,080H,000H,060H,020H,060H
		DB	000H,020H,000H,030H,000H,011H,010H,030H
		DB	000H,003H,010H,058H,000H,000H,009H,068H
		DB	000H,010H,031H,07cH,000H,008H,060H,068H
		DB	000H,007H,0f0H,01dH,006H,002H,088H,00cH
		DB	000H,000H,004H,014H,006H,020H,000H,02cH
		DB	000H,000H,040H,0d0H,000H,020H,001H,06bH
		DB	000H,011H,0c1H,0b1H,000H,00bH,0e3H,050H
		DB	000H,005H,0ffH,0e0H,000H,002H,0aeH,086H
		DB	000H,001H,054H,006H,000H,000H,000H,080H
		DB	000H,000H,010H,0c0H,000H,000H,000H,000H
		DB	01fH,0ffH,0ffH,0ffH,007H,0ffH,0ffH,0ffH
		DB	081H,0ffH,0ffH,0ffH,081H,0ffH,0ffH,0ffH
		DB	0c0H,07fH,0f5H,0ffH,0c0H,03fH,0f5H,0ffH
		DB	0e0H,01fH,0f5H,0ffH,0f0H,01fH,0f5H,0ffH
		DB	0f8H,007H,0ffH,0ffH,0fcH,003H,0e0H,07fH
		DB	0feH,000H,030H,01fH,0ffH,001H,00eH,00fH
		DB	0ffH,083H,08fH,087H,0ffH,0c8H,0c7H,087H
		DB	0ffH,0e8H,0c7H,083H,0ffH,0ccH,046H,003H
		DB	0ffH,0cfH,044H,003H,0ffH,0e7H,084H,083H
		DB	0ffH,0e0H,007H,080H,0f8H,050H,001H,0c0H
		DB	0ffH,09cH,021H,0c3H,0f8H,01fH,0a1H,0c3H
		DB	0ffH,08eH,030H,003H,0ffH,08fH,03cH,000H
		DB	0ffH,0c4H,03cH,000H,0ffH,0c0H,018H,004H
		DB	0ffH,0e0H,000H,00fH,0ffH,0f0H,000H,001H
		DB	0ffH,0f8H,000H,021H,0ffH,0feH,000H,061H
		DB	0ffH,0ffH,0ceH,031H,0ffH,0ffH,0ceH,07fH

VRMSAVEBUF	DW	SAVEBUF0		; ＶＲＡＭ退避エリア

TBLSAVBUF	DW	SAVEBUF0,SAVEBUF1	; table save buffer adrs.

SAVEBUF0	DB	32*5 DUP (?)		; bank0 save buffer.
		DB	32*5 DUP (?)		;
		DB	32*5 DUP (?)		;
		DB	32*5 DUP (?)		;
SAVEBUF1	DB	32*5 DUP (?)		; bank1 save buffer.
		DB	32*5 DUP (?)		;
		DB	32*5 DUP (?)		;
		DB	32*5 DUP (?)		;

CURX		DW	0			; カーソルＸ
CURY		DW	0			; カーソルＹ

CURNEWX		DW	0			; カーソル新しいＸ
CURNEWY		DW	0			; カーソル新しいＹ

MOVE_MODE	DW	1			; カーソル移動モード
						; 0=横バイト／縦バイト
						; 1=横バイト／縦ドット

PLEAN_MODE	DW	1;0		; プレーンモード 0=片面,1=両面

FLAG_MSCINTSW	DW	1		; マウス割り込みカーソルON/OFF

MUSFLG		DW	0		; 0=マウスＯＦＦ
					; 1=マウスカーソル表示中
					; 2=マウスカーソル書換中(割込防止)
DATA	ENDS

	END
;
;	end of "VMUSCOR.ASM"
;
