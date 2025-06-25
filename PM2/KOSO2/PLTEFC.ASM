; "PLTEFC.ASM" PC-9801UV11 make by R.H 1989/12/12
;
;
;	パレットエフェクト
;
; GAME subroutine.

INCLUDE	TSTSET.INC

INT_V_E_P11VEW	EQU	23		; palet11変化割込.色相回転
INT_V_E_P11CNS	EQU	100		; palet11変化割込.彩度倍率
INT_V_E_P11BRI	EQU	100		; palet11変化割込.明度倍率

INT_V_E2_P11VEW	EQU	240		; palet11夜　変化割込.色相回転
INT_V_E2_P11CNS	EQU	100		; palet11夜　変化割込.彩度倍率
INT_V_E2_P11BRI	EQU	7		; palet11夜　変化割込.明度倍率

;*;INT_V_E_P14VEW EQU	52		; palet14変化割込.色相回転
;*;INT_V_E_P14CNS EQU	100		; palet14変化割込.彩度倍率
;*;INT_V_E_P14BRI EQU	100		; palet14変化割込.明度倍率

INT_V_E_P567VEW	EQU	220		; palet5,6,7変化割込ON(OPENING用)
INT_V_E_P567CNS	EQU	20		; palet5,6,7変化割込ON(OPENING用)

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	FEDIN		; Ｆ・Ｉ（フェードイン）
PUBLIC	FEDOUT		; Ｆ・Ｏ（フェードアウト）
PUBLIC	WHTFLS		; ＷＨＩＴＥ・ＦＬＡＳＨ
PUBLIC	WHTIN		; ＷＨＩＴＥ・ＩＮ
PUBLIC	WHTOUT		; ＷＨＩＴＥ・ＯＵＴ
PUBLIC	COLFLS		; カラー・ＦＬＡＳＨ
PUBLIC	COLFUL		; カラー・ＦＵＬＬ
PUBLIC	BLACK		; ブラックアウト
PUBLIC	WHITE		; ＷＨＩＴＥ
PUBLIC	BRIIN		; 明度５０％からノーマルへ
PUBLIC	BRIOUT		; 明度５０％ダウン
PUBLIC	COLBCK		; 色相反転
PUBLIC	COLRET		; 色相戻し
PUBLIC	FFWHT		; ＷＨＩＴＥ反射感
PUBLIC	PLTOL		; パレット・オーバラップ
PUBLIC	PLTMIX		; パレット・混合
PUBLIC	NORMIN		; ノーマルカラー
PUBLIC	NORMINDISK	; ディスクチェンジ用ノーマルカラー
PUBLIC	DWN50P		; 明度５０％ダウン（瞬間）

PUBLIC	PLTFIS		; Ｆ・Ｉ（フェードイン）／時分割初期
PUBLIC	PLTFOS		; Ｆ・Ｏ（フェードアウト）／時分割初期
PUBLIC	PLTCIS		; カラー・ＩＮ／時分割初期
PUBLIC	PLTOLS		; パレット・オーバラップ／時分割初期
PUBLIC	PLTOLSE		; パレット・オーバラップ／時分割初期／編集機能
PUBLIC	PLTOLT		; パレット・オーバラップ／時分割処理
PUBLIC	PLTOLTE		; パレット・オーバラップ／時分割処理／編集機能

PUBLIC	PLTINTSW	; パレット・割込み処理スイッチ
PUBLIC	PLTINTSPD	; パレット・割込み処理スピード
PUBLIC	PLTINTWT	; パレット・割込み処理終了待ち
PUBLIC	PLTINTSTP	; パレット・割込み処理中断
PUBLIC	INTPLT		; パレット処理割込み(PLTEFC.ASM)

PUBLIC	PLTINT_P10_ON	; palet11変化割込ON
PUBLIC	PLTINT_P10_OFF	; palet11変化割込OFF
PUBLIC	PLTINT_P567_ON	; palet5,6,7変化割込ON(OPENING用)
PUBLIC	PLTINT_P567_OFF	; palet5,6,7変化割込OFF(OPENING用)

PUBLIC	PLTINT_FI	; 割り込みＦ・Ｉ（フェードイン）
PUBLIC	PLTINT_FO	; 割り込みＦ・Ｏ（フェードアウト）
PUBLIC	PLTINT_WI	; 割り込みＷＨＩＴＥ・ＩＮ
PUBLIC	PLTINT_WO	; 割り込みＷＨＩＴＥ・ＯＵＴ

EXTRN	C1PLSET:NEAR	; パレットセット
EXTRN	C1PLGET:NEAR	; パレットＧＥＴ
EXTRN	C1PLPUT:NEAR	; パレットＰＵＴ
EXTRN	C1PLPSET:NEAR	; パレット編集セット

EXTRN	TMVWAT:NEAR	; V-SYNC timer wait.
EXTRN	TMVCLR:NEAR	; V-SYNC timer clear.

EXTRN	TMVPLT:NEAR	; V-SYNC timer pallet program call.

EXTRN	C1SETCLR:NEAR	; color set.

EXTRN	DKCMMD:NEAR	; メッセージ突入モード

WAIT_TIMER	EQU	2	; カラー変化時間間隔初期値
COLOR_STEP	EQU	5	; カラー変化ステップ初期値
COLOR_LOOP_CNT	EQU	100/5	; カラー変化ループカウント初期値
COMN_PLT	EQU	3	; 作業用パレット


;	メッセージ突入モード
;	-I- DX : 0=ノーマル,1=真っ黒,2=真っ白

XXDKCMMD	PROC	NEAR
	CALL	DKCMMD		; メッセージ突入モード
	RET
XXDKCMMD	ENDP



;	Ｆ・Ｉ（フェードイン）

FEDIN	PROC	NEAR
	CALL	IED05EFC	; palet sequnce stop.

	MOV	CRXVEW,0		; 色相回転（０ー３６０）
	MOV	CRXCNS,100		; 彩度倍率（０ー１００）
	MOV	CRXBRI,0		; 明度倍率（０ー１００）
	MOV	CRXWHI,0		; ホワイトレベル（０ー１００）
	MOV	CX,IPLMLP		; カラー変化ループカウント
FEDIN4:					;
	PUSH	CX			;
	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット
	POP	CX			;
	MOV	AX,IPLMDV		; カラー変化ステップ
	ADD	CRXBRI,AX		; 明度倍率（０ー１００）
;*NON*;	ADD	CRXCNS,AX		; 彩度倍率（０ー１００）
	LOOP	FEDIN4

	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット

	MOV	DX,0			; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD		; メッセージ突入モード

	RET
FEDIN	ENDP


;	Ｆ・Ｏ（フェードアウト）

FEDOUT	PROC	NEAR
	CALL	IED05EFC	; palet sequnce stop.

	MOV	CRXVEW,0		; 色相回転（０ー３６０）
	MOV	CRXCNS,100		; 彩度倍率（０ー１００）
	MOV	CRXBRI,100		; 明度倍率（０ー１００）
	MOV	CRXWHI,0		; ホワイトレベル（０ー１００）
	MOV	CX,IPLMLP		; カラー変化ループカウント
FEDOUT4:				;
	PUSH	CX			;
	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット
	POP	CX			;
	MOV	AX,IPLMDV		; カラー変化ステップ
	SUB	CRXBRI,AX		; 明度倍率（０ー１００）
;*NON*;	SUB	CRXCNS,AX		; 彩度倍率（０ー１００）
	LOOP	FEDOUT4

	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット

	MOV	DX,1			; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD		; メッセージ突入モード

	RET
FEDOUT	ENDP


;	ＷＨＩＴＥ・ＦＬＡＳＨ

WHTFLS	PROC	NEAR
	CALL	IED05EFC	; palet sequnce stop.

	MOV	CX,3
WHTFLS2:
	PUSH	CX

	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット

	PUSH	CRXVEW			; 色相回転（０ー３６０）
	PUSH	CRXCNS			; 彩度倍率（０ー１００）
	PUSH	CRXBRI			; 明度倍率（０ー１００）
	PUSH	CRXWHI			; ホワイトレベル（０ー１００）

	CALL	DSPWAIT			;
	MOV	CRXVEW,0		; 色相回転（０ー３６０）
	MOV	CRXCNS,10		; 彩度倍率（０ー１００）
	MOV	CRXBRI,100		; 明度倍率（０ー１００）
	MOV	CRXWHI,60		; ホワイトレベル（０ー１００）
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット

	CALL	DSPWAIT			;
	MOV	CRXVEW,0		; 色相回転（０ー３６０）
	MOV	CRXCNS,100		; 彩度倍率（０ー１００）
	MOV	CRXBRI,30		; 明度倍率（０ー１００）
	MOV	CRXWHI,0		; ホワイトレベル（０ー１００）
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット

	POP	CRXWHI			; ホワイトレベル（０ー１００）
	POP	CRXBRI			; 明度倍率（０ー１００）
	POP	CRXCNS			; 彩度倍率（０ー１００）
	POP	CRXVEW			; 色相回転（０ー３６０）
	POP	CX
	LOOP	WHTFLS2

	MOV	BX,0			;
	CALL	C1PLSET			; パレットセット

	MOV	DX,0			; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD		; メッセージ突入モード

	RET
WHTFLS	ENDP



;	ＷＨＩＴＥ・ＩＮ

WHTIN	PROC	NEAR
	CALL	IED05EFC		; palet sequnce stop.

	MOV	CRXVEW,0		; 色相回転（０ー３６０）
	MOV	CRXCNS,0		; 彩度倍率（０ー１００）
	MOV	CRXBRI,100		; 明度倍率（０ー１００）
	MOV	CRXWHI,100		; ホワイトレベル（０ー１００）
	MOV	CX,IPLMLP		; カラー変化ループカウント
WHTIN4:					;
	PUSH	CX			;
	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット
	POP	CX			;
	MOV	AX,IPLMDV		; カラー変化ステップ
	ADD	CRXCNS,AX		; 彩度倍率（０ー１００）
	SUB	CRXWHI,AX		; ホワイトレベル（０ー１００）
	LOOP	WHTIN4

	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット

	MOV	DX,0			; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD		; メッセージ突入モード

	RET
WHTIN	ENDP


;	ＷＨＩＴＥ・ＯＵＴ

WHTOUT	PROC	NEAR
	CALL	IED05EFC		; palet sequnce stop.

	MOV	CRXVEW,0		; 色相回転（０ー３６０）
	MOV	CRXCNS,100		; 彩度倍率（０ー１００）
	MOV	CRXBRI,100		; 明度倍率（０ー１００）
	MOV	CRXWHI,0		; ホワイトレベル（０ー１００）
	MOV	CX,IPLMLP		; カラー変化ループカウント
WHTOUT4:				;
	PUSH	CX			;
	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット
	POP	CX			;
	MOV	AX,IPLMDV		; カラー変化ステップ
	SUB	CRXCNS,AX		; 彩度倍率（０ー１００）
	ADD	CRXWHI,AX		; ホワイトレベル（０ー１００）
	LOOP	WHTOUT4

	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット

	MOV	DX,2			; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD		; メッセージ突入モード

	RET
WHTOUT	ENDP


;	カラー・ＦＬＡＳＨ
;	-I- CLRVEW : color.
;	    CLRCNS : contrast.
;	    CLRBRI : brightness.

COLFLS	PROC	NEAR
	CALL	IED05EFC		; palet sequnce stop.

	CALL	COLFUL			; カラー・ＦＵＬＬ

	CALL	DSPWAIT			;
	CALL	DSPWAIT			;
	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLSET			; パレットセット

	MOV	DX,0			; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD		; メッセージ突入モード

	RET
COLFLS	ENDP


;	カラー・ＦＵＬＬ
;	-I- CLRVEW : color.
;	    CLRCNS : contrast.
;	    CLRBRI : brightness.

COLFUL	PROC	NEAR
	CALL	IED05EFC		; palet sequnce stop.

	MOV	CLRCDE,0		; color code.
	MOV	CX,16			;
COLFUL_LOOP:
	PUSH	CX			;
	CALL	C1SETCLR		; color set.
	INC	CLRCDE			; color code.
	POP	CX			;
	LOOP	COLFUL_LOOP		;

	MOV	DX,2			; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD		; メッセージ突入モード

	RET
COLFUL	ENDP




;	ブラックアウト

BLACK	PROC	NEAR
	CALL	IED05EFC		; palet sequnce stop.

	MOV	CRXVEW,0		; 色相回転（０ー３６０）
	MOV	CRXCNS,100		; 彩度倍率（０ー１００）
	MOV	CRXBRI,0		; 明度倍率（０ー１００）
	MOV	CRXWHI,0		; ホワイトレベル（０ー１００）
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット

	MOV	DX,1			; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD		; メッセージ突入モード

	RET
BLACK	ENDP


;	ＷＨＩＴＥアウト

WHITE	PROC	NEAR
	CALL	IED05EFC		; palet sequnce stop.

	MOV	CRXVEW,0		; 色相回転（０ー３６０）
	MOV	CRXCNS,100		; 彩度倍率（０ー１００）
	MOV	CRXBRI,100		; 明度倍率（０ー１００）
	MOV	CRXWHI,100		; ホワイトレベル（０ー１００）
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット

	MOV	DX,2			; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD		; メッセージ突入モード

	RET
WHITE	ENDP



;	明度５０％からノーマルへ

BRIIN	PROC	NEAR
	CALL	IED05EFC		; palet sequnce stop.

	MOV	CRXVEW,0		; 色相回転（０ー３６０）
	MOV	CRXCNS,50		; 彩度倍率（０ー１００）
	MOV	CRXBRI,50		; 明度倍率（０ー１００）
	MOV	CRXWHI,0		; ホワイトレベル（０ー１００）
	MOV	CX,IPLMLP		; カラー変化ループカウント
	SHR	CX,1			; 50%
BRIIN4:					;
	PUSH	CX			;
	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット
	POP	CX			;
	MOV	AX,IPLMDV		; カラー変化ステップ
	ADD	CRXBRI,AX		; 明度倍率（０ー１００）
	ADD	CRXCNS,AX		; 彩度倍率（０ー１００）
	LOOP	BRIIN4

;*NON*;	MOV	AX,CRXVEW_B		; 色相回転（０ー３６０）
;*NON*;	MOV	CRXVEW,AX
;*NON*;	MOV	AX,CRXCNS_B		; 彩度倍率（０ー１００）
;*NON*;	MOV	CRXCNS,AX
;*NON*;	MOV	AX,CRXBRI_B		; 明度倍率（０ー１００）
;*NON*;	MOV	CRXBRI,AX
;*NON*;	MOV	AX,CRXWHI_B		; ホワイトレベル（０ー１００）
;*NON*;	MOV	CRXWHI,AX

	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット

	RET
BRIIN	ENDP


;	明度５０％ダウン

BRIOUT	PROC	NEAR
	CALL	IED05EFC		; palet sequnce stop.

;*NON*;	MOV	AX,CRXVEW
;*NON*;	MOV	CRXVEW_B,AX		; 色相回転（０ー３６０）
;*NON*;	MOV	AX,CRXCNS
;*NON*;	MOV	CRXCNS_B,AX		; 彩度倍率（０ー１００）
;*NON*;	MOV	AX,CRXBRI
;*NON*;	MOV	CRXBRI_B,AX		; 明度倍率（０ー１００）
;*NON*;	MOV	AX,CRXWHI
;*NON*;	MOV	CRXWHI_B,AX		; ホワイトレベル（０ー１００）

	MOV	CRXVEW,0		; 色相回転（０ー３６０）
	MOV	CRXCNS,100		; 彩度倍率（０ー１００）
	MOV	CRXBRI,100		; 明度倍率（０ー１００）
	MOV	CRXWHI,0		; ホワイトレベル（０ー１００）
	MOV	CX,IPLMLP		; カラー変化ループカウント
	SHR	CX,1			; 50%
BRIOUT4:				;
	PUSH	CX			;
	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット
	POP	CX			;
	MOV	AX,IPLMDV		; カラー変化ステップ
	SUB	CRXBRI,AX		; 明度倍率（０ー１００）
	SUB	CRXCNS,AX		; 彩度倍率（０ー１００）
	LOOP	BRIOUT4

	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット

	RET
BRIOUT	ENDP


;	色相反転

COLBCK	PROC	NEAR
	CALL	IED05EFC		; palet sequnce stop.

	MOV	CRXVEW,0		; 色相回転（０ー３６０）
	MOV	CRXCNS,100		; 彩度倍率（０ー１００）
	MOV	CRXBRI,100		; 明度倍率（０ー１００）
	MOV	CRXWHI,0		; ホワイトレベル（０ー１００）
	MOV	CX,180/20		;
COLBCK4:				;
	PUSH	CX			;
	ADD	CRXVEW,10*2		; 色相回転（０ー３６０）
	ADD	CRXWHI,2*2		; ホワイトレベル（０ー１００）
	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット
	POP	CX			;
	LOOP	COLBCK4

	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット

	RET
COLBCK	ENDP


;	色相戻し

COLRET	PROC	NEAR
	CALL	IED05EFC		; palet sequnce stop.

	MOV	CRXVEW,180		; 色相回転（０ー３６０）
	MOV	CRXCNS,100		; 彩度倍率（０ー１００）
	MOV	CRXBRI,100		; 明度倍率（０ー１００）
	MOV	CRXWHI,36		; ホワイトレベル（０ー１００）
	MOV	CX,180/20		;
COLRET4:				;
	PUSH	CX			;
	SUB	CRXVEW,10*2		; 色相回転（０ー３６０）
	SUB	CRXWHI,2*2		; ホワイトレベル（０ー１００）
	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット
	POP	CX			;
	LOOP	COLRET4

	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLSET			; パレットセット

	RET
COLRET	ENDP





;	ＷＨＩＴＥ反射感

FFWHT	PROC	NEAR
	CALL	IED05EFC		; palet sequnce stop.

	MOV	CRXVEW,0		; 色相回転（０ー３６０）
	MOV	CRXCNS,100		; 彩度倍率（０ー１００）
	MOV	CRXBRI,100		; 明度倍率（０ー１００）
	MOV	CRXWHI,0		; ホワイトレベル（０ー１００）
	MOV	CX,3			;
FFWHT4:					;
	PUSH	CX			;
	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット
	POP	CX			;
	ADD	CRXWHI,5*4		; ホワイトレベル（０ー１００）
	LOOP	FFWHT4

	MOV	CX,3			;
FFWHT5:					;
	PUSH	CX			;
	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット
	POP	CX			;
	SUB	CRXWHI,5*4		; ホワイトレベル（０ー１００）
	LOOP	FFWHT5

	CALL	DSPWAIT			;
	MOV	BX,0			;
	CALL	C1PLPSET			; パレット編集セット

	MOV	DX,0			; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD		; メッセージ突入モード

	RET
FFWHT	ENDP





;	パレット・オーバラップ
;	-I- AX : オーバラップ開始パレットテーブル番号
;	    BX : オーバラップ終了パレットテーブル番号


PLTOL	PROC	NEAR
	MOV	OLCOLS,AX	; オーバラップ開始パレットテーブル番号
	MOV	OLCOLE,BX	; オーバラップ終了パレットテーブル番号


	MOV	BX,OLCOLS	; オーバラップ開始パレットテーブル番号
	CALL	C1PLSET		; パレットセット

	MOV	BX,OLCOLS	; パレットテーブル番号
	CALL	C1PLGET		; パレットＧＥＴ

	CALL	PLTCPY		; ＧＥＴパレットを内部テーブルへセット
	CALL	PLTCPY_FLOT	; ６４乗の固定小数点テーブルへセット

	MOV	BX,OLCOLE	; オーバラップ終了パレットテーブル番号
	CALL	C1PLGET		; パレットＧＥＴ

	CALL	PLTOL_DEV	; パレットオーバ・ラップのステップ計算

	MOV	CX,STPDEV	; 分割数
PLTOL_LOOP:
	PUSH	CX
	CALL	DSPWAIT

	CALL	PLT_MUL		; パレットステップ計算

	MOV	BX,COMN_PLT	; 作業用パレット
	CALL	C1PLPUT		; パレットＰＵＴ

	MOV	BX,COMN_PLT	; 作業用パレット
	CALL	C1PLSET		; パレットセット

	POP	CX
	DEC	CX
	JZ	PLTOL_LOOP_END
	JMP	PLTOL_LOOP
PLTOL_LOOP_END:

	MOV	BX,OLCOLE	; オーバラップ終了パレットテーブル番号
	CALL	C1PLSET		; パレットセット

	RET
PLTOL	ENDP


;	パレットステップ計算

PLT_MUL	PROC	NEAR

	MOV	SI,0
	MOV	CX,16
PLT_MUL_LOOP_PR:
	MOV	AX,CRTVEW_FLOT[SI]	; 色相回転（０ー３６０）
	ADD	AX,CRVEW_STEP[SI]	; 色相回転（０ー３６０）
	MOV	CRTVEW_FLOT[SI],AX	; 色相回転（０ー３６０）

	MOV	AX,CRTCNS_FLOT[SI]	; 彩度倍率（０ー１００）
	ADD	AX,CRCNS_STEP[SI]	; 彩度倍率（０ー１００）
	MOV	CRTCNS_FLOT[SI],AX	; 彩度倍率（０ー１００）

	MOV	AX,CRTBRI_FLOT[SI]	; 明度倍率（０ー１００）
	ADD	AX,CRBRI_STEP[SI]	; 明度倍率（０ー１００）
	MOV	CRTBRI_FLOT[SI],AX	; 明度倍率（０ー１００）


	MOV	AX,CRTVEW_FLOT[SI]	; 色相回転（０ー３６０）
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			; florting point64 -> int*2
	MOV	CRTVEW[SI],AX		; 色相回転（０ー３６０）

	MOV	AX,CRTCNS_FLOT[SI]	; 彩度倍率（０ー１００）
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			; florting point64 -> int*2
	MOV	CRTCNS[SI],AX	; 彩度倍率（０ー１００）

	MOV	AX,CRTBRI_FLOT[SI]	; 明度倍率（０ー１００）
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			;
	SHR	AX,1			; florting point64 -> int*2
	MOV	CRTBRI[SI],AX	; 明度倍率（０ー１００）

	INC	SI
	INC	SI
	DEC	CX
	JZ	PLT_MUL_LOOP_PR_END
	JMP	PLT_MUL_LOOP_PR
PLT_MUL_LOOP_PR_END:
	RET
PLT_MUL	ENDP


;	Ｆ・Ｉ（フェードイン）／時分割初期

PLTFIS	PROC	NEAR
	MOV	FLAG_PLTF,0		; flag palet edit.0=black,1=white.
	CALL	PLTF_IN_SET		; 分割初期加工
	RET
PLTFIS	ENDP


;	Ｆ・Ｏ（フェードアウト）／時分割初期

PLTFOS	PROC	NEAR
	MOV	FLAG_PLTF,0		; flag palet edit.0=black,1=white.
	CALL	PLTF_OUT_SET		; ＯＵＴ分割初期加工
	RET
PLTFOS	ENDP


;	ＷＨＩＴＥ・ＩＮ／時分割初期

PLTWIS	PROC	NEAR
	MOV	FLAG_PLTF,1		; flag palet edit.0=black,1=white.
	CALL	PLTF_IN_SET		; 分割初期加工
	RET
PLTWIS	ENDP


;	ＷＨＩＴＥ・ＯＵＴ／時分割初期

PLTWOS	PROC	NEAR
	MOV	FLAG_PLTF,1		; flag palet edit.0=black,1=white.
	CALL	PLTF_OUT_SET		; ＯＵＴ分割初期加工
	RET
PLTWOS	ENDP



;	ＩＮ分割初期加工
;	-I- FLAG_PLTF : flag palet edit.0=black,1=white.

PLTF_IN_SET	PROC	NEAR
	MOV	OLCOLS,1	; オーバラップ開始パレットテーブル番号
	MOV	OLCOLE,0	; オーバラップ終了パレットテーブル番号

	MOV	BX,OLCOLE	; パレットテーブル番号
	CALL	C1PLGET		; パレットＧＥＴ

	CMP	FLAG_PLTF,1	; flag palet edit.0=black,1=white
	JE	PLTF_IN_SET_WHITE
PLTF_IN_SET_BLACK:
	CALL	PLT0BR		; 明度を０にする
	JMP	PLTF_IN_SET_3	;
PLTF_IN_SET_WHITE:
	CALL	PLT100BR2CNS	; 明度を１００に彩度を０に
PLTF_IN_SET_3:
	MOV	BX,OLCOLS	; パレットテーブル番号
	CALL	C1PLPUT		; パレットＰＵＴ

	MOV	BX,COMN_PLT	; 作業用パレット
	CALL	C1PLPUT		; パレットＰＵＴ

	CALL	PLTCPY		; ＧＥＴパレットを内部テーブルへセット
	CALL	PLTCPY_FLOT	; ６４乗の固定小数点テーブルへセット

	MOV	BX,OLCOLE	; オーバラップ終了パレットテーブル番号
	CALL	C1PLGET		; パレットＧＥＴ

	CALL	PLTOL_DEV	; パレットオーバ・ラップのステップ計算

	MOV	CX,STPDEV	; 分割数
	MOV	STPTIM,CX	; 時間ポインタ
	MOV	STPOFF,0	; 時間処理終了フラグ

	MOV	INT_V_MD_FL,0	; Ｖ割込み処理後のメッセージ突入モード
	MOV	DX,0		; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD	; メッセージ突入モード
	RET
PLTF_IN_SET	ENDP


;	ＯＵＴ分割初期加工
;	-I- FLAG_PLTF : flag palet edit.0=black,1=white.

PLTF_OUT_SET	PROC	NEAR
	MOV	OLCOLS,0;1	; オーバラップ開始パレットテーブル番号
	MOV	OLCOLE,1;0	; オーバラップ終了パレットテーブル番号

	MOV	BX,OLCOLS	; パレットテーブル番号
	CALL	C1PLGET		; パレットＧＥＴ

	MOV	BX,OLCOLE	; パレットテーブル番号
	CALL	C1PLPUT		; パレットＰＵＴ

	MOV	BX,COMN_PLT	; 作業用パレット
	CALL	C1PLPUT		; パレットＰＵＴ

	CALL	PLTCPY		; ＧＥＴパレットを内部テーブルへセット
	CALL	PLTCPY_FLOT	; ６４乗の固定小数点テーブルへセット

	MOV	BX,OLCOLE	; オーバラップ終了パレットテーブル番号
	CALL	C1PLGET		; パレットＧＥＴ

	CMP	FLAG_PLTF,1	; flag palet edit.0=black,1=white.
	JE	PLTF_OUT_SET_WHITE
PLTF_OUT_SET_BLACK:
	CALL	PLT0BR		; 明度を０にする
	JMP	PLTF_OUT_SET_5	;
PLTF_OUT_SET_WHITE:
	CALL	PLT100BR2CNS	; 明度を１００に彩度を０に
PLTF_OUT_SET_5:
	MOV	BX,OLCOLE	; パレットテーブル番号
	CALL	C1PLPUT		; パレットＰＵＴ

	CALL	PLTOL_DEV	; パレットオーバ・ラップのステップ計算

	MOV	CX,STPDEV	; 分割数
	MOV	STPTIM,CX	; 時間ポインタ
	MOV	STPOFF,0	; 時間処理終了フラグ

	CMP	FLAG_PLTF,1	; flag palet edit.0=black,1=white.
	JE	PLTF_OUT_SET_WHITE9

	MOV	INT_V_MD_FL,1	; Ｖ割込み処理後のメッセージ突入モード
	MOV	DX,1		; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD	; メッセージ突入モード
	RET
PLTF_OUT_SET_WHITE9:
	MOV	INT_V_MD_FL,2	; Ｖ割込み処理後のメッセージ突入モード
	MOV	DX,2		; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD	; メッセージ突入モード
	RET
PLTF_OUT_SET	ENDP


;	カラー・ＩＮ／時分割初期
;	-I- CLRVEW : color.
;	    CLRCNS : contrast.
;	    CLRBRI : brightness.

PLTCIS	PROC	NEAR
	MOV	OLCOLS,1	; オーバラップ開始パレットテーブル番号
	MOV	OLCOLE,0	; オーバラップ終了パレットテーブル番号


	CALL	PLTCLR		; 全パレットを指定カラーにする

	MOV	BX,OLCOLS	; パレットテーブル番号
	CALL	C1PLPUT		; パレットＰＵＴ

	MOV	BX,COMN_PLT	; 作業用パレット
	CALL	C1PLPUT		; パレットＰＵＴ

	MOV	BX,OLCOLS	; オーバラップ開始パレットテーブル番号
	CALL	C1PLSET		; パレットセット

	CALL	PLTCPY		; ＧＥＴパレットを内部テーブルへセット
	CALL	PLTCPY_FLOT	; ６４乗の固定小数点テーブルへセット

	MOV	BX,OLCOLE	; オーバラップ終了パレットテーブル番号
	CALL	C1PLGET		; パレットＧＥＴ

	CALL	PLTOL_DEV	; パレットオーバ・ラップのステップ計算

	MOV	CX,STPDEV	; 分割数
	MOV	STPTIM,CX	; 時間ポインタ
	MOV	STPOFF,0	; 時間処理終了フラグ

	MOV	INT_V_MD_FL,0	; Ｖ割込み処理後のメッセージ突入モード
				; 0=ノーマル,1=真っ黒,2=真っ白

	MOV	DX,0			; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD		; メッセージ突入モード
	RET
PLTCIS	ENDP


;	パレット・オーバラップ／時分割初期
;	-I- AX : オーバラップ開始パレットテーブル番号
;	    BX : オーバラップ終了パレットテーブル番号

PLTOLS	PROC	NEAR
	MOV	OLCOLS,AX	; オーバラップ開始パレットテーブル番号
	MOV	OLCOLE,BX	; オーバラップ終了パレットテーブル番号

	MOV	BX,OLCOLS	; オーバラップ開始パレットテーブル番号
	CALL	C1PLSET		; パレットセット

	CALL	PLTOLS_SUB	; パレット・オーバラップ／時分割初期
	RET
PLTOLS	ENDP


;	パレット・オーバラップ／時分割初期／編集機能
;	-I- AX : オーバラップ開始パレットテーブル番号
;	    BX : オーバラップ終了パレットテーブル番号

PLTOLSE	PROC	NEAR
	MOV	OLCOLS,AX	; オーバラップ開始パレットテーブル番号
	MOV	OLCOLE,BX	; オーバラップ終了パレットテーブル番号

	MOV	BX,OLCOLS	; オーバラップ開始パレットテーブル番号
	CALL	C1PLPSET	; パレット編集セット

	CALL	PLTOLS_SUB	; パレット・オーバラップ／時分割初期
	RET
PLTOLSE	ENDP


;	パレット・オーバラップ／時分割初期
;	-I- OLCOLS : オーバラップ開始パレットテーブル番号
;	    OLCOLE : オーバラップ終了パレットテーブル番号

PLTOLS_SUB	PROC	NEAR
	MOV	BX,OLCOLS	; パレットテーブル番号
	CALL	C1PLGET		; パレットＧＥＴ

	MOV	BX,COMN_PLT	; 作業用パレット
	CALL	C1PLPUT		; パレットＰＵＴ

	CALL	PLTCPY		; ＧＥＴパレットを内部テーブルへセット
	CALL	PLTCPY_FLOT	; ６４乗の固定小数点テーブルへセット

	MOV	BX,OLCOLE	; オーバラップ終了パレットテーブル番号
	CALL	C1PLGET		; パレットＧＥＴ

	CALL	PLTOL_DEV	; パレットオーバ・ラップのステップ計算

	MOV	CX,STPDEV	; 分割数
	MOV	STPTIM,CX	; 時間ポインタ
	MOV	STPOFF,0	; 時間処理終了フラグ

	MOV	INT_V_MD_FL,0	; Ｖ割込み処理後のメッセージ突入モード
				; 0=ノーマル,1=真っ黒,2=真っ白

	MOV	DX,0			; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD		; メッセージ突入モード
	RET
PLTOLS_SUB	ENDP



;	パレット・オーバラップ／時分割処理
;	-I/O- STPTIM : 時間ポインタ
;	      STPOFF : 時間処理終了フラグ

PLTOLT	PROC	NEAR
	CMP	STPOFF,0	; 時間処理終了フラグ
	JE	PLTOLT1
	RET
PLTOLT1:
	CMP	STPTIM,0	; 時間ポインタ
	JNE	PLTOLT_LOOP	;
	MOV	BX,OLCOLE	; オーバラップ終了パレットテーブル番号
	CALL	C1PLSET		; パレットセット
	MOV	STPOFF,1	; 時間処理終了フラグ
	RET

PLTOLT_LOOP:
	MOV	BX,COMN_PLT	; 作業用パレット
	CALL	C1PLSET		; パレットセット

	CALL	PLT_MUL		; パレットステップ計算

	MOV	BX,COMN_PLT	; 作業用パレット
	CALL	C1PLPUT		; パレットＰＵＴ

	DEC	STPTIM		; 時間ポインタ

	RET
PLTOLT	ENDP


;	パレット・オーバラップ／時分割処理／編集機能
;	-I-   CRXVEW : 色相回転（０ー３６０）
;	      CRXCNS : 彩度倍率（０ー１００）
;	      CRXBRI : 明度倍率（０ー１００）
;	      CRXWHI : ホワイトレベル（０ー１００）
;	-I/O- STPTIM : 時間ポインタ
;	      STPOFF : 時間処理終了フラグ

PLTOLTE	PROC	NEAR
	CMP	STPOFF,0	; 時間処理終了フラグ
	JE	PLTOLTE1
	RET
PLTOLTE1:
	CMP	STPTIM,0	; 時間ポインタ
	JNE	PLTOLTE_LOOP	;
	MOV	BX,OLCOLE	; オーバラップ終了パレットテーブル番号
	CALL	C1PLPSET	; パレット編集セット
	MOV	STPOFF,1	; 時間処理終了フラグ
	RET
PLTOLTE_LOOP:
	MOV	BX,COMN_PLT	; 作業用パレット
	CALL	C1PLPSET	; パレット編集セット
	CALL	PLT_MUL		; パレットステップ計算
	MOV	BX,COMN_PLT	; 作業用パレット
	CALL	C1PLPUT		; パレットＰＵＴ
	DEC	STPTIM		; 時間ポインタ
	RET
PLTOLTE	ENDP


;	パレット・混合
;	-I- AX : 混合パレットテーブル番号
;	    BX : 混合パレットテーブル番号
;	    DX : セットパレットテーブル
;	    CX : 比率（０－２０）

PLTMIX	PROC	NEAR
	CALL	IED05EFC		; palet sequnce stop.

	MOV	OLCOLS,AX	; オーバラップ開始パレットテーブル番号
	MOV	OLCOLE,BX	; オーバラップ終了パレットテーブル番号
	MOV	STCOL,DX	; セットパレットテーブル
	MOV	PROPRT,CX	; 比率（０－２０）

	MOV	BX,OLCOLS	; パレットテーブル番号
	CALL	C1PLGET		; パレットＧＥＴ

	CMP	PROPRT,0	; 比率（０－２０）
	JE	PLTMIX_LOOP_END	;

	CALL	PLTCPY		; ＧＥＴパレットを内部テーブルへセット
	CALL	PLTCPY_FLOT	; ６４乗の固定小数点テーブルへセット

	MOV	BX,OLCOLE	; オーバラップ終了パレットテーブル番号
	CALL	C1PLGET		; パレットＧＥＴ

	CALL	PLTOL_DEV	; パレットオーバ・ラップのステップ計算

PLTMIX_LOOP:
	CALL	PLT_MUL		; パレットステップ計算

	DEC	PROPRT		; 比率（０－２０）
	JNZ	PLTMIX_LOOP	;
PLTMIX_LOOP_END:

	MOV	BX,STCOL	; セットパレットテーブル
	CALL	C1PLPUT		; パレットＰＵＴ

	RET
PLTMIX	ENDP


;	ノーマルカラー

NORMIN	PROC	NEAR
	CALL	IED05EFC		; palet sequnce stop.

	MOV	BX,0			; パレット
	CALL	C1PLSET			; パレットセット
	MOV	DX,0			; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD		; メッセージ突入モード
	RET
NORMIN	ENDP


;	ディスクチェンジ用ノーマルカラー

NORMINDISK	PROC	NEAR
	CALL	IED05EFC		; palet sequnce stop.

	MOV	BX,DISKPLTNUM		; ディスクチェンジ用パレット番号
	CALL	C1PLSET			; パレットセット
	RET
NORMINDISK	ENDP


;	明度５０％ダウン（瞬間）

DWN50P	PROC	NEAR
	CALL	IED05EFC	; palet sequnce stop.

	MOV	CRXVEW,0		; 色相回転（０ー３６０）
	MOV	CRXCNS,50		; 彩度倍率（０ー１００）
	MOV	CRXBRI,50		; 明度倍率（０ー１００）
	MOV	CRXWHI,0		; ホワイトレベル（０ー１００）
	MOV	BX,0			;
	CALL	C1PLPSET		; パレット編集セット

	MOV	DX,0			; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	XXDKCMMD		; メッセージ突入モード
	RET
DWN50P	ENDP


;	パレットオーバ・ラップのステップ計算
;	-I- CRTVEW[0-15]:word : 色相回転（０ー３６０）変更後
;	    CRTCNS[0-15]:word : 彩度倍率（０ー１００）
;	    CRTBRI[0-15]:word : 明度倍率（０ー１００）
;	    CRTVEWN[0-15]:word: 色相回転（０ー３６０）変更前
;	    CRTCNSN[0-15]:word: 彩度倍率（０ー１００）
;	    CRTBRIN[0-15]:word: 明度倍率（０ー１００）
;	    STPDEV            : 分割数
;	-O- CRVEW_STEP[0-15]:w: 色相回転（０ー３６０）
;	    CRCNS_STEP[0-15]:w: 彩度倍率（０ー１００）
;	    CRBRI_STEP[0-15]:w: 明度倍率（０ー１００）
;	    ＳＴＥＰは６４乗の固定小数点

PLTOL_DEV	PROC	NEAR
	MOV	SI,0
	MOV	CX,16
PLTOL_DEV_VEW1:
	MOV	AX,DS:CRTVEW[SI]	; 色相回転（０ー３６０）
	SUB	AX,DS:CRTVEWN[SI]	; 色相回転（０ー３６０）
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;*64 floting point
	CWD				;
	MOV	BX,STPDEV		; 分割数
	IDIV	BX			;
	MOV	DS:CRVEW_STEP[SI],AX	; 色相回転（０ー３６０）
	INC	SI
	INC	SI
	LOOP	PLTOL_DEV_VEW1		;

	MOV	SI,0
	MOV	CX,16
PLTOL_DEV_CNS1:
	MOV	AX,DS:CRTCNS[SI]	; 彩度倍率（０ー１００）
	SUB	AX,DS:CRTCNSN[SI]	; 彩度倍率（０ー１００）
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;*64 floting point
	CWD				;
	MOV	BX,STPDEV		; 分割数
	IDIV	BX			;
	MOV	DS:CRCNS_STEP[SI],AX	; 彩度倍率（０ー１００）
	INC	SI
	INC	SI
	LOOP	PLTOL_DEV_CNS1		;

	MOV	SI,0
	MOV	CX,16
PLTOL_DEV_BRI1:
	MOV	AX,DS:CRTBRI[SI]	; 明度倍率（０ー１００）
	SUB	AX,DS:CRTBRIN[SI]	; 明度倍率（０ー１００）
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;*64 floting point
	CWD				;
	MOV	BX,STPDEV		; 分割数
	IDIV	BX			;
	MOV	DS:CRBRI_STEP[SI],AX	; 明度倍率（０ー１００）
	INC	SI
	INC	SI
	LOOP	PLTOL_DEV_BRI1		;

	RET
PLTOL_DEV	ENDP


;	明度を０にする
;	-I/O- CRTVEW[0-15]:word : 色相回転（０ー３６０）
;	      CRTCNS[0-15]:word : 彩度倍率（０ー１００）
;	      CRTBRI[0-15]:word : 明度倍率（０ー１００）
;	      CRTCDE[0-15]:word : ハードパレットテーブル

PLT0BR	PROC	NEAR
	MOV	AX,DS
	MOV	ES,AX

	MOV	DI,OFFSET CRTBRI	; 明度倍率（０ー１００）
	MOV	CX,16
	MOV	AX,0
	REP	STOSW

	RET
PLT0BR	ENDP


;	明度を１００に彩度を０に
;	-I/O- CRTVEW[0-15]:word : 色相回転（０ー３６０）
;	      CRTCNS[0-15]:word : 彩度倍率（０ー１００）
;	      CRTBRI[0-15]:word : 明度倍率（０ー１００）
;	      CRTCDE[0-15]:word : ハードパレットテーブル

PLT100BR2CNS	PROC	NEAR
	MOV	AX,DS
	MOV	ES,AX

	MOV	DI,OFFSET CRTBRI	; 明度倍率（０ー１００）
	MOV	CX,16
	MOV	AX,100
	REP	STOSW

	MOV	DI,OFFSET CRTCNS	; 彩度倍率（０ー１００）
	MOV	CX,16
	MOV	AX,0
	REP	STOSW

	RET
PLT100BR2CNS	ENDP


;	全パレットを指定カラーにする
;	-I- CLRVEW : color.
;	    CLRCNS : contrast.
;	    CLRBRI : brightness.
;	-O- CRTVEW[0-15]:word : 色相回転（０ー３６０）
;	    CRTCNS[0-15]:word : 彩度倍率（０ー１００）
;	    CRTBRI[0-15]:word : 明度倍率（０ー１００）
;	    CRTCDE[0-15]:word : ハードパレットテーブル

PLTCLR	PROC	NEAR

	PUSH	CLRVEW		; color.
	PUSH	CLRCNS		; contrast.
	PUSH	CLRBRI		; brightness.
	MOV	BX,0		;
	CALL	C1PLGET		; パレットＧＥＴ
	POP	CLRBRI		; brightness.
	POP	CLRCNS		; contrast.
	POP	CLRVEW		; color.

	MOV	AX,DS
	MOV	ES,AX

	MOV	DI,OFFSET CRTVEW	; 色相回転（０ー３６０）
	MOV	CX,16
	MOV	AX,CLRVEW		; color.
	REP	STOSW

	MOV	DI,OFFSET CRTCNS	; 彩度倍率（０ー１００）
	MOV	CX,16
	MOV	AX,CLRCNS		; contrast.
	REP	STOSW

	MOV	DI,OFFSET CRTBRI	; 明度倍率（０ー１００）
	MOV	CX,16
	MOV	AX,CLRBRI		; brightness.
	REP	STOSW

	RET
PLTCLR	ENDP



;	ＧＥＴパレットを内部テーブルへセット

PLTCPY	PROC	NEAR
	MOV	AX,DS
	MOV	ES,AX

	MOV	SI,OFFSET CRTVEW	; 色相回転（０ー３６０）
	MOV	DI,OFFSET CRTVEWN	; 色相回転（０ー３６０）
	MOV	CX,16
	REP	MOVSW

	MOV	SI,OFFSET CRTCNS	; 彩度倍率（０ー１００）
	MOV	DI,OFFSET CRTCNSN	; 彩度倍率（０ー１００）
	MOV	CX,16
	REP	MOVSW

	MOV	SI,OFFSET CRTBRI	; 明度倍率（０ー１００）
	MOV	DI,OFFSET CRTBRIN	; 明度倍率（０ー１００）
	MOV	CX,16
	REP	MOVSW

	MOV	SI,OFFSET CRTCDE	; ハードパレットテーブル
	MOV	DI,OFFSET CRTCDEN	; ハードパレットテーブル
	MOV	CX,16
	REP	MOVSW

	RET
PLTCPY	ENDP



;	ＧＥＴパレットを６４乗の固定小数点テーブルへセット

PLTCPY_FLOT	PROC	NEAR
	MOV	AX,DS
	MOV	ES,AX

	MOV	SI,OFFSET CRTVEW	; 色相回転（０ー３６０）
	MOV	DI,OFFSET CRTVEW_FLOT	; 色相回転（０ー３６０）
	MOV	CX,16
PLTCPY_FLOT1:
	LODSW
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;*64 floting point
	STOSW
	LOOP	PLTCPY_FLOT1


	MOV	SI,OFFSET CRTCNS	; 彩度倍率（０ー１００）
	MOV	DI,OFFSET CRTCNS_FLOT	; 彩度倍率（０ー１００）
	MOV	CX,16
PLTCPY_FLOT2:
	LODSW
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;*64 floting point
	STOSW
	LOOP	PLTCPY_FLOT2


	MOV	SI,OFFSET CRTBRI	; 明度倍率（０ー１００）
	MOV	DI,OFFSET CRTBRI_FLOT	; 明度倍率（０ー１００）
	MOV	CX,16
PLTCPY_FLOT3:
	LODSW
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;*64 floting point
	STOSW
	LOOP	PLTCPY_FLOT3

	RET
PLTCPY_FLOT	ENDP



;	表示用ウェイト

DSPWAIT	PROC	NEAR
	MOV	AX,IPLMSW	; パレットエフェクト単位時間(VSYNC)
	CALL	TMVWAT		; V-SYNC timer wait.
	RET
DSPWAIT	ENDP


;	パレット・割込み処理スイッチ

PLTINTSW	PROC	NEAR
	MOV	INT_V_COUNT,0	; Ｖ割込み処理のカウンタ
	MOV	AX,1		; 割込みスイッチ 0=OFF,1=ON
	CALL	TMVPLT		; V-SYNC timer pallet program call.

					; 0=ノーマル,1=真っ黒,2=真っ白
	MOV	DX,INT_V_MD_FL		; Ｖ割込み処理後のメッセージ突入モード
	CALL	XXDKCMMD		; メッセージ突入モード
	RET
PLTINTSW	ENDP


;	パレット・割込み処理スピード
;	-I- AX : Ｖ割込み処理の指定インターバル

PLTINTSPD	PROC	NEAR
	MOV	INT_V_INTERVAL,AX	; Ｖ割込み処理の指定インターバル
	ADD	INT_V_INTERVAL,1
	AND	INT_V_INTERVAL,111B	; Ｖ割込み処理の指定インターバル
	RET
PLTINTSPD	ENDP


;	パレット・割込み処理終了待ち

PLTINTWT	PROC	NEAR
PLTINTWT_LOOP:
	CMP	STPOFF,1		; 時間処理終了フラグ
	JNE	PLTINTWT_LOOP		;

					; 0=ノーマル,1=真っ黒,2=真っ白
	MOV	DX,INT_V_MD_FL		; Ｖ割込み処理後のメッセージ突入モード
	CALL	XXDKCMMD		; メッセージ突入モード

	RET
PLTINTWT	ENDP


;	パレット・割込み処理中断

PLTINTSTP	PROC	NEAR
	CMP	STPOFF,1	; 時間処理終了フラグ
	JE	PLTINTSTP_EXIT	;
	MOV	STPOFF,1	; 時間処理終了フラグ
	MOV	BX,OLCOLE	; オーバラップ終了パレットテーブル番号
	CALL	C1PLSET		; パレットセット
PLTINTSTP_EXIT:
	RET
PLTINTSTP	ENDP


;	パレット処理割込み(PLTEFC.ASM)

INTPLT	PROC	NEAR
	MOV	AX,SEG DATA
	MOV	DS,AX

	CMP	INT_V_EFC_FLAG,0	; palet11変化割り込みフラグ
	JE	INTPLT_SKIP		;

	ADDX	INT_V_EFC_10BRI,INT_V_EFC_STEP	; palet11変化割り込みステップ
;*;	ADDX	INT_V_EFC_14BRI,INT_V_EFC_STEP	; palet11変化割り込みステップ

	INC	INT_V_EFC_CUNT		; palet11変化割り込みカウンタ
	CMP	INT_V_EFC_CUNT,40	; palet11変化割り込みカウンタ
	JB	INTPLT_10		;
	MOV	INT_V_EFC_CUNT,0	; palet11変化割り込みカウンタ

	NEG	INT_V_EFC_STEP		; palet11変化割り込みステップ

INTPLT_10:
	TEST	INT_V_EFC_CUNT,1	; palet11変化割り込みカウンタ
	JNZ	INTPLT_EXIT		;

	MOV	CLRCDE,11		; color code.
	MOV	CLRVEW,INT_V_E_P11VEW	; palet11変化割込.色相回転
	MOV	CLRCNS,INT_V_E_P11CNS	; palet11変化割込.彩度倍率
	MOVX	CLRBRI,INT_V_EFC_10BRI	; palet11変化割り込み明度倍率
	CALLE	C1SETCLR		; color table set.

;*;	MOV	CLRCDE,14		; color code.
;*;	MOV	CLRVEW,INT_V_E_P14VEW	; palet14変化割込.色相回転
;*;	MOV	CLRCNS,INT_V_E_P14CNS	; palet14変化割込.彩度倍率
;*;	MOVX	CLRBRI,INT_V_EFC_14BRI	; palet14変化割り込み明度倍率
;*;	CALLE	C1SETCLR		; color table set.

	CALLE	C1CLRVSET		; color palet table disply.

INTPLT_SKIP:
	CMP	INT_V567_FLAG,0		; palet5,6,7変化割込フラグ
	JE	INTPLT_SKIP2		;

;	INC	INT_V567_INTRVL		; palet5,6,7変化割込ｲﾝﾀｰﾊﾞﾙ
;	CMP	INT_V567_INTRVL,1	; palet5,6,7変化割込ｲﾝﾀｰﾊﾞﾙ
;	JLE	INTPLT_SKIP2		;
;	MOV	INT_V567_INTRVL,0		; palet5,6,7変化割込ｲﾝﾀｰﾊﾞﾙ

	MOV	BX,0
	MOV	CX,3
INTPLT_LOOP:
	ADDX	INT_V567_BRI[BX],INT_V567_STEP[BX]
	DEC	INT_V567_CUNT[BX]	; palet5,6,7変化割込カウンタ
	CMP	INT_V567_CUNT[BX],0	; palet5,6,7変化割込カウンタ
	JG	INTPLT_4		;
	NEG	INT_V567_STEP[BX]	; palet5,6,7変化割込ステップ
	MOV	INT_V567_CUNT[BX],10	; palet5,6,7変化割込カウンタ
INTPLT_4:
	INC	BX
	INC	BX
	LOOP	INTPLT_LOOP

	CALL	PLTINT_P567_PLTSET	; palet5,6,7set.

INTPLT_SKIP2:
	CMP	STPOFF,1		; 時間処理終了フラグ
	JE	INTPLT_EXIT		;

	INC	INT_V_COUNT		; Ｖ割込み処理のカウンタ
	MOV	AX,INT_V_COUNT		; Ｖ割込み処理の指定インターバル
	CMP	AX,INT_V_INTERVAL	; Ｖ割込み処理の指定インターバル
	JB	INTPLT_EXIT

	MOV	INT_V_COUNT,0		; Ｖ割込み処理のカウンタ

	CALL	PLTOLT			; パレット・オーバラップ／時分割処理
	CMP	STPOFF,1		; 時間処理終了フラグ
	JNE	INTPLT_EXIT

	MOV	AX,0			; 割込みスイッチ 0=OFF,1=ON
	CALL	TMVPLT			; V-SYNC timer pallet program call.
INTPLT_EXIT:
	RET
INTPLT	ENDP


;	palet11変化割込ON

PLTINT_P10_ON	PROC	NEAR

;*;	MOV	INT_V_EFC_STEP,-1	; palet11変化割り込みステップ
;*;	MOV	INT_V_EFC_10BRI,INT_V_E_P11BRI	; palet11変化割込.明度倍率
;*;	MOV	INT_V_EFC_14BRI,INT_V_E_P14BRI	; palet14変化割込.明度倍率
;*;	MOV	INT_V_EFC_CUNT,0		; palet11変化割り込みカウンタ

	MOV	INT_V_EFC_FLAG,1	; palet11変化割り込みフラグ

	MOV	AX,1			; 割込みスイッチ 1=ON
	CALL	TMVPLT			; V-SYNC timer pallet program call.
	RET
PLTINT_P10_ON	ENDP


;	palet11変化割込OFF

PLTINT_P10_OFF	PROC	NEAR
	MOV	INT_V_EFC_FLAG,0	; palet11変化割り込みフラグ

	MOV	AX,0			; 割込みスイッチ 0=OFF
	CALL	TMVPLT			; V-SYNC timer pallet program call.

					; 1=昼,2=夜,3=昼->夜,4=夜->昼
	CMP	FLAG_DAYLIGHT,1		; flag pallet efc11 daylight.
	JNE	PLTINT_P10_OFF_NIGHT	;
PLTINT_P10_OFF_DAY:
	MOV	CLRCDE,11		; color code.
	MOV	CLRVEW,INT_V_E_P11VEW	; palet11変化割込.色相回転
	MOV	CLRCNS,INT_V_E_P11CNS	; palet11変化割込.彩度倍率
	MOV	CLRBRI,INT_V_E_P11BRI	; palet11変化割込.明度倍率
	CALLE	C1SETCLR		; color table set.
	CALLE	C1CLRVSET		; color palet table disply.
	JMP	PLTINT_P10_OFF_5
PLTINT_P10_OFF_NIGHT:
	MOV	CLRCDE,11		; color code.
	MOV	CLRVEW,INT_V_E2_P11VEW	; palet11夜　変化割込.色相回転
	MOV	CLRCNS,INT_V_E2_P11CNS	; palet11夜　変化割込.彩度倍率
	MOV	CLRBRI,INT_V_E2_P11BRI	; palet11夜　変化割込.明度倍率

	CALLE	C1SETCLR		; color table set.
	CALLE	C1CLRVSET		; color palet table disply.
PLTINT_P10_OFF_5:

;*;	MOV	CLRCDE,14		; color code.
;*;	MOV	CLRVEW,INT_V_E_P14VEW	; palet14変化割込.色相回転
;*;	MOV	CLRCNS,INT_V_E_P14CNS	; palet14変化割込.彩度倍率
;*;	MOV	CLRBRI,INT_V_E_P14BRI	; palet14変化割込.明度倍率
;*;	CALLE	C1SETCLR		; color table set.

;*;	MOV	BX,COMN_PLT		; 作業用パレット
;*;	CALL	C1PLSET			; パレットセット
	RET
PLTINT_P10_OFF	ENDP


;	palet5,6,7変化割込ON(OPENING用)

PLTINT_P567_ON	PROC	NEAR
	CALL	PLTINT_P567_PLTSET	; palet5,6,7set.

	MOV	INT_V567_FLAG,1		; palet5,6,7変化割込フラグ

	MOV	AX,1			; 割込みスイッチ 1=ON
	CALL	TMVPLT			; V-SYNC timer pallet program call.
	RET
PLTINT_P567_ON	ENDP


;	palet5,6,7変化割込OFF(OPENING用)

PLTINT_P567_OFF	PROC	NEAR
	MOV	AX,0			; 割込みスイッチ 1=ON
	CALL	TMVPLT			; V-SYNC timer pallet program call.

	MOV	INT_V567_FLAG,0		; palet5,6,7変化割込フラグ
	RET
PLTINT_P567_OFF	ENDP


;	palet5,6,7set.

PLTINT_P567_PLTSET	PROC	NEAR
	MOV	CLRCDE,5		; color code.
	MOV	BX,0			;
	MOV	CX,3			;
PLTINT_P567_PLTSET_LOOP:
	PUSH	CX			;
	PUSH	BX			;
	MOV	CLRVEW,INT_V_E_P567VEW	; palet5,6,7変化割込ON(OPENING用)
	MOV	CLRCNS,INT_V_E_P567CNS	; palet5,6,7変化割込ON(OPENING用)
	MOVX	CLRBRI,INT_V567_BRI[BX]	; palet5,6,7変化割込明度倍率
	CALLE	C1SETCLR		; color table set.
	INC	CLRCDE			; color code.
	POP	BX			;
	INC	BX			;
	INC	BX			;
	POP	CX			;
	LOOP	PLTINT_P567_PLTSET_LOOP	;

	CALLE	C1CLRVSET		; color palet table disply.
	RET
PLTINT_P567_PLTSET	ENDP


;	割り込みＦ・Ｉ（フェードイン）

PLTINT_FI	PROC	NEAR
	CALL	PLTFIS		; Ｆ・Ｉ（フェードイン）／時分割初期
	CALL	PLTINTSW	; パレット・割込み処理スイッチ
	RET
PLTINT_FI	ENDP

;	割り込みＦ・Ｏ（フェードアウト）

PLTINT_FO	PROC	NEAR
	CALL	PLTFOS		; Ｆ・Ｏ（フェードアウト）／時分割初期
	CALL	PLTINTSW	; パレット・割込み処理スイッチ
	RET
PLTINT_FO	ENDP


;	割り込みＷＨＩＴＥ・ＩＮ

PLTINT_WI	PROC	NEAR
	CALL	PLTWIS		; ＷＨＩＴＥ・ＩＮ／時分割初期
	CALL	PLTINTSW	; パレット・割込み処理スイッチ
	RET
PLTINT_WI	ENDP


;	割り込みＷＨＩＴＥ・ＯＵＴ

PLTINT_WO	PROC	NEAR
	CALL	PLTWOS		; ＷＨＩＴＥ・ＯＵＴ／時分割初期
	CALL	PLTINTSW	; パレット・割込み処理スイッチ
	RET
PLTINT_WO	ENDP


;	palet sequnce stop.

IED05EFC	PROC	NEAR
	CALL	PLTINTSTP		; パレット・割込み処理中断
	RET
IED05EFC	ENDP


CODE01	ENDS



DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	FLAG_DAYLIGHT		; flag pallet efc11 daylight.

PUBLIC	IPLMSW			; パレットエフェクト単位時間(VSYNC)
PUBLIC	IPLMDV			; カラー変化ステップ
PUBLIC	IPLMLP			; カラー変化ループカウント

EXTRN	CRXVEW:WORD		; 色相回転（０ー３６０）
EXTRN	CRXCNS:WORD		; 彩度倍率（０ー１００）
EXTRN	CRXBRI:WORD		; 明度倍率（０ー１００）
EXTRN	CRXWHI:WORD		; ホワイトレベル（０ー１００）

EXTRN	CRTVEW:WORD		; 色相回転（０ー３６０）
EXTRN	CRTCNS:WORD		; 彩度倍率（０ー１００）
EXTRN	CRTBRI:WORD		; 明度倍率（０ー１００）
EXTRN	CRTCDE:WORD		; ハードパレットテーブル
EXTRN	CRTSKP:WORD		; パレット編集処理のスキップ(1=ｽｷｯﾌﾟ)

EXTRN	CLRCDE:WORD		; color code.
EXTRN	CLRVEW:WORD		; color view.
EXTRN	CLRCNS:WORD		; contrast.
EXTRN	CLRBRI:WORD		; brightness.

FLAG_DAYLIGHT	DW	0	; flag pallet efc11 daylight.

IPLMSW	DW	WAIT_TIMER	; パレットエフェクト単位時間(VSYNC)
IPLMDV	DW	COLOR_STEP	; カラー変化ステップ
IPLMLP	DW	COLOR_LOOP_CNT	; カラー変化ループカウント


CRTVEWN	DW	16 DUP (0)	; 色相回転（０ー３６０）
CRTCNSN	DW	16 DUP (0)	; 彩度倍率（０ー１００）
CRTBRIN	DW	16 DUP (0)	; 明度倍率（０ー１００）
CRTCDEN	DW	16 DUP (0)	; ハードパレットテーブル

CRXVEW_B	DW	0	; 色相回転（０ー３６０）
CRXCNS_B	DW	0	; 彩度倍率（０ー１００）
CRXBRI_B	DW	0	; 明度倍率（０ー１００）
CRXWHI_B	DW	0	; ホワイトレベル（０ー１００）

OLCOLS		DW	0	; オーバラップ開始パレットテーブル番号
OLCOLE		DW	0	; オーバラップ終了パレットテーブル番号
STCOL		DW	0	; セットパレットテーブル

STPDEV		DW	20	; 分割数

STPTIM		DW	0	; 時間ポインタ

STPOFF		DW	1	; 時間処理終了フラグ

PROPRT		DW	0	; 比率（０－２０）

CRVEW_STEP	DW	16 DUP (0)	; 色相回転（０ー３６０）
CRCNS_STEP	DW	16 DUP (0)	; 彩度倍率（０ー１００）
CRBRI_STEP	DW	16 DUP (0)	; 明度倍率（０ー１００）

CRTVEW_FLOT	DW	16 DUP (0)	; 色相回転（０ー３６０）
CRTCNS_FLOT	DW	16 DUP (0)	; 彩度倍率（０ー１００）
CRTBRI_FLOT	DW	16 DUP (0)	; 明度倍率（０ー１００）

INT_V_COUNT	DW	0		; Ｖ割込み処理のカウンタ
INT_V_INTERVAL	DW	2		; Ｖ割込み処理の指定インターバル
INT_V_MD_FL	DW	0		; Ｖ割込み処理後のメッセージ突入モード
					; 0=ノーマル,1=真っ黒,2=真っ白

INT_V_EFC_FLAG	DB	0,0		; palet11変化割り込みフラグ
INT_V_EFC_STEP	DW	-1		; palet11変化割り込みステップ
INT_V_EFC_CUNT	DW	0		; palet11変化割り込みカウンタ
INT_V_EFC_10BRI	DW	INT_V_E_P11BRI	; palet11変化割り込み明度倍率
;*;INT_V_EFC_14BRI DW	INT_V_E_P14BRI	; palet14変化割り込み明度倍率

INT_V567_FLAG	DB	0,0		; palet5,6,7変化割込フラグ
INT_V567_INTRVL	DW	0		; palet5,6,7変化割込ｲﾝﾀｰﾊﾞﾙ
INT_V567_STEP	DW	-3,-3,+3	; palet5,6,7変化割込ステップ
INT_V567_CUNT	DW	10,3,7	; palet5,6,7変化割込カウンタ
INT_V567_BRI	DW	100,79,79	; palet5,6,7変化割込明度倍率

FLAG_PLTF	DW	0		; flag palet edit.0=black,1=white

DISKPLTNUM	DW	0		; ディスクチェンジ用パレット番号

DATA	ENDS


;*DBG*;
;*DBG*;	EXTRN	MSCWAT:NEAR	; カーソルボタンＯＦＦ待ち
;*DBG*;	CALL	MSCWAT
;*DBG*;	EXTRN	MSCMOV:NEAR	; カーソル移動
;*DBG*;L110:
;*DBG*;	CALL	MSCMOV
;*DBG*;	CMP	DH,0
;*DBG*;	JNZ	L110
;*DBG*;


	END
;
;	end of "PLTEFC.ASM"
;
