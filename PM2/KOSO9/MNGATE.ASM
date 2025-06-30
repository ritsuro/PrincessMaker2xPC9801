; "MNGATE.ASM" 486/50 make by R.H 1993/02/03
;
;
;	main function gate.
;
;
; (C) 1993 ritsurou hashimoto.

INCLUDE	MAINF.INC

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	MSCSRT		;カーソルスタート
PUBLIC	MSCMOV		;カーソル移動
PUBLIC	MSCMV2		;カーソル移動（遅延処理無し）
PUBLIC	MSCSTP		;カーソルストップ
PUBLIC	MSCSTS		;マウスカーソルステータス
PUBLIC	MSWWAT		;カーソルボタン待ち
PUBLIC	KEYTEN		;キーボード・読み込み

PUBLIC	FEDIN		;Ｆ・Ｉ（フェードイン）
PUBLIC	FEDOUT		;Ｆ・Ｏ（フェードアウト）
PUBLIC	WHTIN		;ＷＨＩＴＥ・ＩＮ
PUBLIC	WHTOUT		;ＷＨＩＴＥ・ＯＵＴ
PUBLIC	BLACK		;ブラックアウト
PUBLIC	WHITE		;ＷＨＩＴＥアウト
PUBLIC	PLTOL		;パレット・オーバラップ
PUBLIC	PLTMIX		;パレット・混合
PUBLIC	NORMIN		;ノーマルカラー

PUBLIC	PLTFIS		;Ｆ・Ｉ（フェードイン）／時分割初期
PUBLIC	PLTFOS		;Ｆ・Ｏ（フェードアウト）／時分割初期
PUBLIC	PLTCIS		;カラー・ＩＮ／時分割初期
PUBLIC	PLTOLS		;パレット・オーバラップ／時分割初期
PUBLIC	PLTOLSE		;パレット・オーバラップ／時分割初期／編集機能
PUBLIC	PLTOLT		;パレット・オーバラップ／時分割処理
PUBLIC	PLTOLTE		;パレット・オーバラップ／時分割処理／編集機能

PUBLIC	TMVWAT		;V-SYNC timer wait.
PUBLIC	TMVSET		;V-SYNC timer set.
PUBLIC	TMVCHK		;V-SYNC timer check.
PUBLIC	TMVEWT		;V-SYNC timer end wait.
PUBLIC	TMVST2		;V-SYNC timer2 set.
PUBLIC	TMVCK2		;V-SYNC timer2 check.
PUBLIC	TMVST3		;V-SYNC timer3 set.
PUBLIC	TMVCK3		;V-SYNC timer3 check.

PUBLIC	VTXPRN		;vram text print.
PUBLIC	VTXPOR		;vram text print OR.
PUBLIC	VTXPFC		;vram text print fuchi.
PUBLIC	VTXSIZ		;character size set.
PUBLIC	VTXCOL		;character color set.

PUBLIC	BOXPAL		;ＢＯＸペイント
PUBLIC	BOXMSS		;ＢＯＸメッシュ
PUBLIC	BOXNOT		;ＢＯＸ反転
PUBLIC	BOXMCH		;ＢＯＸチェック模様

PUBLIC	PT_PALET_SETONLY	;パレットテーブルセットのみ
PUBLIC	PT_PATTERN_LD		;pattern load.
PUBLIC	PT_PATTERN_LDA		;pattern add load.
PUBLIC	PT_PATTERN_PUT		;pattern put.
PUBLIC	PT_MASK_PAT_PUT		;pattern mask put.
PUBLIC	PT_MASK_PTF_PUT		;pattern mask offset put.
PUBLIC	PT_PATTERN_BANK		;pattern bank set.
PUBLIC	PT_VRAM_ID_ALL_ASSIGN	;vram ID all asigned.
PUBLIC	PT_PATTERN_CLEAR	;parts buffer clear.
PUBLIC	PT_PATTERN_GET		;parts get.

PUBLIC	WIDCLEN_MONTH		;WINDOWS/カレンダー・月データ

PUBLIC	MITPRN			;mini string. (null=end of string)
PUBLIC	MITCOL			;mini string color.
PUBLIC	MDTPRN			;MID string.
PUBLIC	MWTPRN			;WIDE string.
PUBLIC	MBTPRN			;BIG string.
PUBLIC	MGXPRN			;GAINAX mini string.
PUBLIC	MGXPRNP			;GAINAX mini string.(put)

EXTRN	MAIN_FUNCTION_INTER:NEAR	; main function inter.
EXTRN	MAIN_F_INTER_C_CODE:NEAR	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE)
EXTRN	MAIN_F_INTER_C_CODE01:NEAR	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
EXTRN	MAIN_F_REG_SAVE:NEAR		; register save.
EXTRN	MAIN_F_REG_LOAD:NEAR		; register load.

; ****************************************************
;	"VMUSCOR.ASM"
; ****************************************************

;	カーソルスタート

MSCSRT	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_MSCSRT		; カーソルスタート
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
MSCSRT	ENDP

;	カーソル移動
;	-O- AX : Ｘ座標
;	    BX : Ｙ座標
;	    DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）

MSCMOV	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_MSCMOV		; カーソル移動
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
MSCMOV	ENDP

;	カーソル移動（遅延処理無し）
;	-O- AX : Ｘ座標
;	    BX : Ｙ座標
;	    DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）

MSCMV2	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_MSCMV2		; カーソル移動（遅延処理無し）
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
MSCMV2	ENDP

;	カーソルストップ

MSCSTP	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_MSCSTP		; カーソルストップ
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
MSCSTP	ENDP

;	マウスカーソルステータス
;	-O- AX : 0=マウスＯＦＦ,1=マウスカーソル表示中

MSCSTS	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_MSCSTS		; マウスカーソルステータス
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
MSCSTS	ENDP

; ****************************************************
;	"VMUSCR2.ASM"
; ****************************************************

;	カーソルボタン待ち
;	-I- AX : カーソルＸ座標
;	    BX : カーソルＹ座標

MSWWAT	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_MSWWAT		; カーソルボタン待ち
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
MSWWAT	ENDP


; ****************************************************
;	"VKYLC.ASM"
; ****************************************************

;	キーボード・読み込み
;	-O- AX : 番号(-1:押していない)
;	    BX : 1=HELP,2=HOME,3=PLUS,4=ESC (-1:押していない)

KEYTEN	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_KEYTEN		; キーボード・読み込み
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
KEYTEN	ENDP

; ****************************************************
;	"PLTEFC.ASM"
; ****************************************************

;	Ｆ・Ｉ（フェードイン）

FEDIN	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_FEDIN		; Ｆ・Ｉ（フェードイン）
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
FEDIN	ENDP

;	Ｆ・Ｏ（フェードアウト）

FEDOUT	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_FEDOUT		; Ｆ・Ｏ（フェードアウト）
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
FEDOUT	ENDP

;	ＷＨＩＴＥ・ＩＮ

WHTIN	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_WHTIN		; ＷＨＩＴＥ・ＩＮ
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
WHTIN	ENDP

;	ＷＨＩＴＥ・ＯＵＴ

WHTOUT	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_WHTOUT		; ＷＨＩＴＥ・ＯＵＴ
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
WHTOUT	ENDP

;	ブラックアウト

BLACK	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_BLACK		; ブラックアウト
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
BLACK	ENDP

;	ＷＨＩＴＥアウト

WHITE	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_WHITE		; ＷＨＩＴＥ
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
WHITE	ENDP

;	パレット・オーバラップ
;	-I- AX : オーバラップ開始パレットテーブル番号
;	    BX : オーバラップ終了パレットテーブル番号

PLTOL	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PLTOL		; パレット・オーバラップ
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PLTOL	ENDP

;	パレット・混合
;	-I- AX : 混合パレットテーブル番号
;	    BX : 混合パレットテーブル番号
;	    DX : セットパレットテーブル
;	    CX : 比率（０－２０）

PLTMIX	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PLTMIX		; パレット・混合
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PLTMIX	ENDP

;	ノーマルカラー

NORMIN	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_NORMIN		; ノーマルカラー
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
NORMIN	ENDP

;	Ｆ・Ｉ（フェードイン）／時分割初期

PLTFIS	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PLTFIS		; Ｆ・Ｉ／時分割初期
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PLTFIS	ENDP

;	Ｆ・Ｏ（フェードアウト）／時分割初期

PLTFOS	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PLTFOS		; Ｆ・Ｏ／時分割初期
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PLTFOS	ENDP

;	カラー・ＩＮ／時分割初期
;	-I- CLRVEW : color.
;	    CLRCNS : contrast.
;	    CLRBRI : brightness.

PLTCIS	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PLTCIS		; カラー・ＩＮ／時分割初期
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PLTCIS	ENDP

;	パレット・オーバラップ／時分割初期
;	-I- AX : オーバラップ開始パレットテーブル番号
;	    BX : オーバラップ終了パレットテーブル番号

PLTOLS	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PLTOLS		; ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割初期
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PLTOLS	ENDP

;	パレット・オーバラップ／時分割初期／編集機能
;	-I- AX : オーバラップ開始パレットテーブル番号
;	    BX : オーバラップ終了パレットテーブル番号

PLTOLSE	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PLTOLSE		; ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割初期/編集機能
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PLTOLSE	ENDP

;	パレット・オーバラップ／時分割処理

PLTOLT	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PLTOLT		; ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割処理
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PLTOLT	ENDP

;	パレット・オーバラップ／時分割処理／編集機能

PLTOLTE	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PLTOLT		; ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割処理
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PLTOLTE	ENDP


; ****************************************************
;	"VTIMER.ASM"
; ****************************************************

;	V-SYNC timer wait.
;	-I- AX : wait timer count.

TMVWAT	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_TMVWAT		; V-SYNC timer wait.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
TMVWAT	ENDP

;	V-SYNC timer set.
;	-I- AX : wait timer count.

TMVSET	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_TMVSET		; V-SYNC timer set.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
TMVSET	ENDP

;	V-SYNC timer check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

TMVCHK	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_TMVCHK		; V-SYNC timer check.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
TMVCHK	ENDP

;	V-SYNC timer end wait.

TMVEWT	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_TMVEWT		; V-SYNC timer end wait.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
TMVEWT	ENDP

;	V-SYNC timer2 set.
;	-I- AX : wait timer count.

TMVST2	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_TMVST2		; V-SYNC timer2 set.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
TMVST2	ENDP

;	V-SYNC timer2 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

TMVCK2	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_TMVCK2		; V-SYNC timer2 check.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
TMVCK2	ENDP

;	V-SYNC timer3 set.
;	-I- AX : wait timer count.

TMVST3	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_TMVST3		; V-SYNC timer3 set.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
TMVST3	ENDP

;	V-SYNC timer3 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

TMVCK3	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_TMVCK3		; V-SYNC timer3 check.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
TMVCK3	ENDP


; ****************************************************
;	"VRTEXT.ASM"
; ****************************************************

;	vram text print.
;	-I- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.

VTXPRN	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_VTXPRN		; vram text print.
	MOV	DI,1			; 1=SI string.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
VTXPRN	ENDP

;	vram text print OR.
;	-I- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.

VTXPOR	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_VTXPOR		; vram text print OR.
	MOV	DI,1			; 1=SI string.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
VTXPOR	ENDP

;	vram text print fuchi.
;	-I- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.

VTXPFC	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_VTXPFC		; vram text print fuchi.
	MOV	DI,1			; 1=SI string.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
VTXPFC	ENDP

;	character size set.
;	-I- AX : 0=16x16  1=32x32  2=16x24  3=16x32

VTXSIZ	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_VTXSIZ		; character size set.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
VTXSIZ	ENDP

;	character color set.
;	-I- AX : character color 0-15

VTXCOL	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_VTXCOL		; character color set.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
VTXCOL	ENDP


; ****************************************************
;	"EFECT2.ASM"
; ****************************************************

;	ＢＯＸペイント
;	-i- SSEFC0-3 : efect data segment.
;	    VX1,VY1  : start point.
;	    VX2,VY2  : end point.
;	    CX       : color palet number.

BOXPAL	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	CALL	SET_VX1VY1		; set VX1,VY1,VX2,VY2
	MOV	CX,FNO_BOXPAL		; ＢＯＸペイント
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
BOXPAL	ENDP

;	ＢＯＸメッシュ
;	-i- SSEFC0-3 : efect data segment.
;	    VX1,VY1  : start point.
;	    VX2,VY2  : end point.
;	    CX       : color palet number.

BOXMSS	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	CALL	SET_VX1VY1		; set VX1,VY1,VX2,VY2
	MOV	CX,FNO_BOXMSS		; ＢＯＸメッシュ
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
BOXMSS	ENDP

;	ＢＯＸ反転
;	-i- SSEFC0-3 : efect data segment.
;	    VX1,VY1  : start point.
;	    VX2,VY2  : end point.
;	    CX       : color palet number.

BOXNOT	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	CALL	SET_VX1VY1		; set VX1,VY1,VX2,VY2
	MOV	CX,FNO_BOXNOT		; ＢＯＸ反転
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
BOXNOT	ENDP

;	ＢＯＸチェック模様
;	-i- SSEFC0-3 : efect data segment.
;	    VX1,VY1  : start point.
;	    VX2,VY2  : end point.
;	    CX       : color1 palet number.
;	    BX       : color2 palet number.

BOXMCH	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	CALL	SET_VX1VY1		; set VX1,VY1,VX2,VY2
	MOV	CX,FNO_BOXMCH		; ＢＯＸチェック模様
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
BOXMCH	ENDP

; ****************************************************
;	"PICTUER.ASM"
; ****************************************************

;	パレットテーブルセットのみ
;	-I- AX : パーツ番号
;	    BX : テーブル番号

PT_PALET_SETONLY	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PT_PALET_SETONLY	; パレットテーブルセットのみ
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PT_PALET_SETONLY	ENDP

;	pattern load.
;	-I- SI : file name.
;	    DX : bank number.

PT_PATTERN_LD	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PT_PATTERN_LD	; pattern load.
	MOV	DI,1			; 1=SI string.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PT_PATTERN_LD	ENDP

;	pattern add load.
;	-I- SI : file name.

PT_PATTERN_LDA	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PT_PATTERN_LDA	; pattern add load.
	MOV	DI,1			; 1=SI string.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PT_PATTERN_LDA	ENDP

;	pattern put.
;	-I- AX    : put x.
;	    BX    : put y.
;	    DX    : pattern number.
;	    SSGR0-SSGR3,SSGRW : put vram.

PT_PATTERN_PUT	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PT_PATTERN_PUT	; pattern put.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PT_PATTERN_PUT	ENDP

;	pattern mask put.
;	-I- AX    : put x.
;	    BX    : put y.
;	    DX    : pattern number.
;	    SSGR0-SSGR3,SSGRW : put vram.

PT_MASK_PAT_PUT	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PT_MASK_PAT_PUT	; pattern mask put.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PT_MASK_PAT_PUT	ENDP

;	pattern mask offset put.
;	-I- AX    : put x.
;	    BX    : put y.
;	    DX    : pattern number.
;	    SSGR0-SSGR3,SSGRW : put vram.

PT_MASK_PTF_PUT	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PT_MASK_PTF_PUT	; pattern mask offset put.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PT_MASK_PTF_PUT	ENDP

;	pattern bank set.
;	-I- DX : bank number.

PT_PATTERN_BANK	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PT_PATTERN_BANK	; pattern bank set.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PT_PATTERN_BANK	ENDP

;	vram ID all asigned.

PT_VRAM_ID_ALL_ASSIGN	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PT_VRAM_ID_ALL_ASSIGN	ENDP


;	parts buffer clear.

PT_PATTERN_CLEAR	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PT_PATTERN_CLEAR	; parts buffer clear.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PT_PATTERN_CLEAR	ENDP


;	parts get.
;	-I- AX : 左上Ｘ
;	    BX : 左上Ｙ
;	    CX : サイズＸ
;	    DX : サイズＹ
;	-O- AX : 0=normal end, 1=error.
;	    SSGR0-SSGR3,SSGRW : put vram.

PT_PATTERN_GET	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_PT_PATTERN_GET	; parts get.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
PT_PATTERN_GET	ENDP


; ****************************************************
;	"WIDCLEND.ASM"
; ****************************************************

;	WINDOWS/カレンダー・月データ
;	-I- AX : 年
;	    BX : 月
;	-O- CX : 月末の日
;	    DX : 曜日

WIDCLEN_MONTH	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_WIDCLEN_MONTH	; WINDOWS/カレンダー・月データ
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
WIDCLEN_MONTH	ENDP


; ****************************************************
;	"MINTXT.ASM"
; ****************************************************

;	mini string. (null=end of string)
;	-i- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.

MITPRN	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_MITPRN		; mini string.
	MOV	DI,1			; 1=SI string.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
MITPRN	ENDP

;	mini string color.
;	-I- AX : font color.

MITCOL	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_MITCOL		; mini string color.
	MOV	DI,0			; 0=normal.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
MITCOL	ENDP


; ****************************************************
;	"MIDTXT.ASM"
; ****************************************************

;	MID string.
;	-i- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.

MDTPRN	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_MDTPRN		; MID string.
	MOV	DI,1			; 1=SI string.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
MDTPRN	ENDP


; ****************************************************
;	"MIWTXT.ASM"
; ****************************************************

;	WIDE string.
;	-i- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.

MWTPRN	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_MWTPRN		; WIDE string.
	MOV	DI,1			; 1=SI string.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
MWTPRN	ENDP


; ****************************************************
;	"MIBTXT.ASM"
; ****************************************************

;	BIG string.
;	-i- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.

MBTPRN	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_MBTPRN		; BIG string.
	MOV	DI,1			; 1=SI string.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
MBTPRN	ENDP


; ****************************************************
;	"MGXTXT.ASM"
; ****************************************************

;	GAINAX mini string.
;	-i- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.

MGXPRN	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_MGXPRN		; GAINAX mini string.
	MOV	DI,1			; 1=SI string.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
MGXPRN	ENDP

;	GAINAX mini string.(put)
;	-i- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.

MGXPRNP	PROC	NEAR
	CALL	MAIN_F_REG_SAVE		; register save.
	MOV	CX,FNO_MGXPRNP		; GAINAX mini string.(put)
	MOV	DI,1			; 1=SI string.
	CALL	MAIN_F_INTER_C_CODE01	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	RET
MGXPRNP	ENDP

; ****************************************************
;	lib.
; ****************************************************


;	set VX1,VY1,VX2,VY2

SET_VX1VY1	PROC	NEAR
	MOV	CX,VX1			; point x1.
	MOV	DX,VY1			; point y1.
	MOV	SI,VX2			; point x2.
	MOV	DI,VY2			; point y2.
	MOV	BX,24			; set VX1,VY1,VX2,VY2
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	RET
SET_VX1VY1	ENDP


; ****************************************************
;	data.
; ****************************************************

PUBLIC	VX1				; point x1.
PUBLIC	VY1				; point y1.
PUBLIC	VX2				; point x2.
PUBLIC	VY2				; point y2.

VX1		DW	0		; point x1.
VY1		DW	0		; point y1.
VX2		DW	0		; point x2.
VY2		DW	0		; point y2.

CODE	ENDS
	END
;
;	end of "MNGATE.ASM"
;
