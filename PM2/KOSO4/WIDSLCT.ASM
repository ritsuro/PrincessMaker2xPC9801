; "WIDSLCT.ASM" 486/50 make by R.H 1992/05/21
;
;
;	ＷＩＮＤＯＷＳ／セレクト・ウインドウ
;
;
;	WIDSLC_INIT		; WINDOWS/セレクト・ウインドウ初期処理
;	WIDSLC			; WINDOWS/セレクト・ウインドウ
;	WIDSLC2			; WINDOWS/セレクト・ウインドウ（簡易指定）
;	WIDSLC_RPGOPEN		; WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG OPEN.
;	WIDSLC_RPGCLOSE		; WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG CLOSE.
;	WIDSLC_RPGREAD		; WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG READ.
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	MACHINEX.INC
INCLUDE	WINDOWS.INC

JMPC	MACRO	LBL
	LOCAL	L1
	JNB	L1
	JMP	LBL
L1:
	ENDM

MOV_ID2	MACRO	DESTID,SOUID
	MOV	AX,DS
	MOV	ES,AX
	MOV	SI,OFFSET SOUID
	MOV	DI,OFFSET DESTID
	MOVSW
	MOVSW
	MOVSW
	MOVSW
	MOVSW
	ENDM

MOVX	MACRO	DEST,SOU
	MOV	AX,SOU
	MOV	DEST,AX
	ENDM

STRING_LEN 	EQU	255	; string length.
STR_VAL_LEN 	EQU	6	; string length.（数値表示用）

CNTL_CR		EQU	0DH	; CR code.
CNTL_LF		EQU	0AH	; LF code.
CNTL_UP		EQU	1FH	; control upper.
END_OF_STR	EQU	0	; end of string.

FACE_COLOR	EQU	8	; ウインドウ表面カラー

MOJI_COL	EQU	0	; 文字縁character color 0-15
MOJI_SZ		EQU	0	; 0=16x16  1=32x32  2=16x24  3=16x32
MOJI_COL2	EQU	15	; 文字面character color 0-15
MOJI_SZ2	EQU	0	; 0=16x16  1=32x32  2=16x24  3=16x32

NAMEB_COL	EQU	8	; ウインドウ名バックカラー


;	パーツバッファのバンクの詳細については
;	ＰＡＲＴＳＴ．ＡＳＭを参照して下さい。

WID1X_INIT	EQU	35	; ウインドウ発生位置座標Ｘ初期値
WID1Y_INIT	EQU	160	; ウインドウ発生位置座標Ｙ初期値

VIEW_MIN_X	EQU	0;1	; ディスプレイのＸ方向最小
VIEW_MIN_Y	EQU	0;1	; ディスプレイのＹ方向最小
VIEW_MAX_X	EQU	79	; ディスプレイのＸ方向最大
VIEW_MAX_Y	EQU	399	; ディスプレイのＹ方向最大
VIEW_SID_X	EQU	80	; ディスプレイのＸ長さ
VIEW_SID_Y	EQU	400	; ディスプレイのＹ長さ

NORMAL_BANK	EQU	0	; 通常のパーツバンク番号
BACKSAVE_BANK	EQU	0	; 背景退避用バンク番号

WIDMOFSX	EQU	1	; ウインドウ文字オフセット位置Ｘ
WIDMOFSY	EQU	20-4	; ウインドウ文字オフセット位置Ｙ
WIDMMGEX	EQU	1	; ウインドウ右端マージンＸ
WIDMMGEY	EQU	5+16-4	; ウインドウ下端マージンＹ

WIDFROMX	EQU	2	; フレーム厚Ｘ方向
WIDFROMY	EQU	40-7	; フレーム厚Ｙ方向

WORD_MINI_LEN	EQU	4*2	; １単語表示長さの最小限度

SELECT_MAX	EQU	20	; セレクト単語数上限

OFFF		EQU	0FFFFH	; とりあえずＯＦＦという意味

CHR_DELIM	EQU	','	; 単語の区切り
EOS		EQU	0	; end of string.


;	ＢＯＸ１プレーンヌキ

BOXPBK	MACRO	X1,Y1,X2,Y2
	LOCAL	L1,L2
	MOV	AX,X1
	MOV	VX1,AX
	MOV	AX,Y1
	MOV	VY1,AX
	MOV	AX,X2
	MOV	VX2,AX
	MOV	AX,Y2
	MOV	VY2,AX
	MOV	CX,1111B		; color palet number.
	EXTRN	w_BOXNOT:NEAR
	CALL	w_BOXNOT		; ＢＯＸ反転
	ENDM


;	ＢＯＸ１プレーンペイント

BOXPPA	MACRO	X1,Y1,X2,Y2
	LOCAL	L1,L2
	MOV	AX,X1
	MOV	VX1,AX
	MOV	AX,Y1
	MOV	VY1,AX
	MOV	AX,X2
	MOV	VX2,AX
	MOV	AX,Y2
	MOV	VY2,AX
	MOV	CX,1111B	; color palet number.
	EXTRN	w_BOXNOT:NEAR
	CALL	w_BOXNOT	; ＢＯＸ反転
	ENDM


WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA

; ****************************************************
;	WINDOWS/セレクト・ウインドウ初期処理
; ****************************************************

FUNC	WIDSLC_INIT
	MOV	AX,WID1X_INIT		; ウインドウ発生位置座標Ｘ初期値
	MOV	BX,WID1Y_INIT		; ウインドウ発生位置座標Ｙ初期値
	MOV	WID1X,AX		; ウインドウ発生位置左上座標Ｘ
	MOV	WID1Y,BX		; ウインドウ発生位置左上座標Ｙ
	RET
FEND	WIDSLC_INIT



; ****************************************************
;	WINDOWS/セレクト・ウインドウ
;	-I-   ATMSEG   : テキストバッファセグメント
;	      ATMMAX   : 表示単語の数
;	      ATMTBL[] : 表示単語アドレス
;	-I/O- WIDSBANK : 一時退避バッファ番号
;	-O-   WIDSNM   : ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／ユーザ選択番号
;	               : =FFFFH : 指定なし
; ****************************************************

FUNC	WIDSLC
	CALL_w	WIDDIRSL_NOW_CLOSE	; WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳCLOSE
	CMP	ATMMAX,0		; 表示単語の数
	JG	WIDSLC_START		;
	MOV	WIDSNM,OFFF		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／ユーザ選択番号
	RET
WIDSLC_START:
	MOV	PLEAN_MODE,0		; プレーンモード 0=片面,1=両面
	CALL_w	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.

	MOV	AX,WIDSBANK		;  現在退避用バッファ番号
	MOV	BACK_NOW_BANK,AX	;  現在退避用バッファ番号
	MOV	WIDSBANK,BACKSAVE_BANK	; default set.

	CALL	LENGTH_ATM		; 単語テーブル内の単語長さ

	MOV	WIDCOL,FACE_COLOR	; ウインドウ表面カラー

	CALL	WINDOW_ALOC		; ウインドウの位置ぎめ

	CALL	WINDOW_OPEN		; ウインドウオープン

	CMP	WIDSDEMO,55		; デモフラグ0=通常,55=ランダムセレクト
	JE	WIDSLC_START_DEMO	;

	CALL_w	MSCSRT			; カーソルスタート
	CALL	WINDOW_SELECT		; ウインドウセレクト
	CALL_w	MSCSTP			; カーソルストップ

	JMP	WIDSLC_START_6		;
WIDSLC_START_DEMO:
	MOV	AX,WIDSDEMOWAIT		; デモ 待ち時間
	CALL_w	TMVWAT			; V-SYNC timer wait.

	MOV	AX,WIDDMAX		; セレクト単語数
	CMP	FLAG_LEFT_BOTTON_DISABLE,0 ; ﾌﾗｸﾞ右ﾎﾞﾀﾝ無効
	JNE	WIDSLC_START_55		;
	INC	AX			; ＋１（指定なしも加える）
WIDSLC_START_55:
	CALL_w	RANDAM			; 乱数範囲指定
	DEC	AX			;
	MOV	WIDSNM,AX		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ/ユーザ選択番号
	CMP	AX,WIDDMAX		; セレクト単語数
	JB	WIDSLC_START_6		;
	MOV	WIDSNM,OFFF		; 指定なし
WIDSLC_START_6:

	CALL	WINDOW_CLOSE		; ウインドウクローズ
	CALL	WINDOW_DEALOC		; ウインドウの位置戻し

	RET
FEND	WIDSLC


; ****************************************************
;	WINDOWS/セレクト・ウインドウ（簡易指定）
;	-I-   ES:[BX]  : 指定文字列
;	-I/O- WIDSBANK : 一時退避バッファ番号
;	-O-   WIDSNM   : ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／ユーザ選択番号
;	             : =FFFFH : 指定なし
;
;	［話す］	L1	DB	"話す,渡す,行く",0
;	［渡す］
;	［行く］
; ****************************************************

FUNC	WIDSLC2
	CALL	WIDSLCKANI		; 簡易指定の取り出し
	CALL	w_WIDSLC		; WINDOWS/セレクト・ウインドウ
	RET
FEND	WIDSLC2


; ****************************************************
;	WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG OPEN.
;	-I-   ES:[SI]  : 指定文字列
; ****************************************************

FUNC	WIDSLC_RPGOPEN
	CALL_w	WIDDIRSL_NOW_CLOSE	; WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳCLOSE

	MOVX	BAK_WID1X,WID1X		; ｳｲﾝﾄﾞｳ発生位置左上座標Ｘ退避
	MOVX	BAK_WID1Y,WID1Y		; ｳｲﾝﾄﾞｳ発生位置左上座標Ｙ退避
	MOVX	WID1X,RPG_WID1X		; RPG用ｳｲﾝﾄﾞｳ発生位置左上座標Ｘ
	MOVX	WID1Y,RPG_WID1Y		; RPG用ｳｲﾝﾄﾞｳ発生位置左上座標Ｙ

	MOV	BX,SI			;
	CALL	WIDSLCKANI		; 簡易指定の取り出し
	CMP	ATMMAX,0		; 表示単語の数
	JG	WIDSLC_RPGOPEN_START	;
	RET
WIDSLC_RPGOPEN_START:
	MOV	PLEAN_MODE,1		; プレーンモード 0=片面,1=両面
	CALL_w	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.
	MOV	AX,WIDSBANK		;  現在退避用バッファ番号
	MOV	BACK_NOW_BANK,AX	;  現在退避用バッファ番号
	MOV	WIDSBANK,BACKSAVE_BANK	; default set.
	CALL	LENGTH_ATM		; 単語テーブル内の単語長さ
	MOV	WIDCOL,FACE_COLOR	; ウインドウ表面カラー
	CALL	WINDOW_ALOC		; ウインドウの位置ぎめ
	CALL	WINDOW_OPEN		; ウインドウオープン

	CALL	PC98OPEN		; PC98 vram bank1 open.

	CALL_w	MSCSRT			; カーソルスタート
	MOV	WIDWORD_NOW,OFFF	; 現在の選択された表示単語の番号
	RET
FEND	WIDSLC_RPGOPEN


; ****************************************************
;	WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG CLOSE.
; ****************************************************

FUNC	WIDSLC_RPGCLOSE
	CALL_w	MSCSTP			; カーソルストップ
	CALL	WINDOW_CLOSE		; ウインドウクローズ
	CALL	WINDOW_DEALOC		; ウインドウの位置戻し
	MOVX	WID1X,BAK_WID1X		; ｳｲﾝﾄﾞｳ発生位置左上座標Ｘ退避
	MOVX	WID1Y,BAK_WID1Y		; ｳｲﾝﾄﾞｳ発生位置左上座標Ｙ退避
	CALL	PC98CLOSE		; PC98 vram bank1 close.
	RET
FEND	WIDSLC_RPGCLOSE


; ****************************************************
;	WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG READ.
;	-O-   WIDSNM   : ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／ユーザ選択番号
;	               : =FFFFH : 指定なし
;	               : = -2   : 何も入力無し
; ****************************************************

FUNC	WIDSLC_RPGREAD
	CMP	WIDSDEMO,55		; デモフラグ0=通常,55=ランダムセレクト
	JE	WIDSLC_RPGREAD_DEMO	;

	CALL	WIDRPGSLCT		; ＲＰＧウインドウセレクト
	RET

WIDSLC_RPGREAD_DEMO:
	MOV	AX,WIDSDEMOWAIT		; デモ 待ち時間
	CALL_w	TMVWAT			; V-SYNC timer wait.

	MOV	AX,WIDDMAX		; セレクト単語数
	CMP	FLAG_LEFT_BOTTON_DISABLE,0 ; ﾌﾗｸﾞ右ﾎﾞﾀﾝ無効
	JNE	WIDSLC_RPGREAD_55	;
	INC	AX			; ＋１（指定なしも加える）
WIDSLC_RPGREAD_55:
	CALL_w	RANDAM			; 乱数範囲指定
	DEC	AX			;
	MOV	WIDSNM,AX		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ/ユーザ選択番号
	CMP	AX,WIDDMAX		; セレクト単語数
	JB	WIDSLC_RPGREAD_6	;
	MOV	WIDSNM,OFFF		; 指定なし
WIDSLC_RPGREAD_6:
	RET
FEND	WIDSLC_RPGREAD


;	ＲＰＧウインドウセレクト
;	-I- WIDDIMX[]: セレクト単語座標Ｘ
;	    WIDDIMY[]: セレクト単語座標Ｙ
;	    WIDDMAX  : セレクト単語数
;	    WIDMSIZX : 表示単語Ｘサイズ
;	    WIDMSIZY : 表示単語Ｙサイズ
;	-O- WIDSNM   : ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ/ユーザ選択番号
;	             : =FFFFH : 指定なし
;	             : = -2   : 何も入力無し

WIDRPGSLCT	PROC	NEAR
	MOV	WIDSNM,OFFF		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ/ユーザ選択番号

	CALL_w	MSCMOV			; カーソル移動
	MOV	MOUSEX,AX		; マウスＸ
	MOV	MOUSEY,BX		; マウスＹ
	MOV	MS_BTNL,DH		; マウスボタン左
	MOV	MS_BTNR,DL		; マウスボタン右

	CMP	FLAG_LEFT_BOTTON_DISABLE,0 ; ﾌﾗｸﾞ右ﾎﾞﾀﾝ無効
	JNE	WIDRPGSLCT_1		;
	CMP	DL,1			; 右ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	WIDRPGSLCT_1		;
	MOV	WIDSNM,OFFF		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ/ユーザ選択番号
	JMP	WIDRPGSLCT_EXIT
WIDRPGSLCT_1:				;

	MOV	SI,0			; word pointer.
	MOV	CX,WIDDMAX		; セレクト単語数
WIDRPGSLCT_CHK_LOOP:			;
	MOV	BP,CX			;
	MOV	AX,DS:WIDDIMX[SI]	; AX=セレクト単語座標Ｘ左上
	MOV	BX,DS:WIDDIMY[SI]	; BX=セレクト単語座標Ｙ左上
	MOV	CX,AX			;
	MOV	DX,BX			;
	ADD	CX,WIDMSIZX		; CX=セレクト単語座標Ｘ右下
	ADD	DX,WIDMSIZY		; DX=セレクト単語座標Ｙ右下

	CMP	MOUSEX,AX		; セレクト単語座標Ｘ
	JB	WIDRPGSLCT_NEXT		;
	CMP	MOUSEY,BX		; セレクト単語座標Ｙ
	JB	WIDRPGSLCT_NEXT		;
	CMP	MOUSEX,CX		; セレクト単語座標Ｘ
	JNB	WIDRPGSLCT_NEXT		;
	CMP	MOUSEY,DX		; セレクト単語座標Ｙ
	JNB	WIDRPGSLCT_NEXT		;

	SHR	SI,1			;
	MOV	WIDSNM,SI		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ/ユーザ選択番号

	CALL	WINDOW_SELECT_ON	; 選択単語の反転

	JMP	WIDRPGSLCT_NEXT2	;

WIDRPGSLCT_NEXT:			;
	INC	SI			; word pointer.
	INC	SI			;
	MOV	CX,BP			;
	LOOP	WIDRPGSLCT_CHK_LOOP	;

	CALL	WINDOW_SELECT_OFF	; 選択単語の反転を戻す

	MOV	WIDSNM,-2		;-2: 何も入力無し

WIDRPGSLCT_NEXT2:
	CMP	MS_BTNL,0		; マウスボタン左
	JE	WIDRPGSLCT_EXIT		;
	MOV	WIDSNM,-2		;-2: 何も入力無し
WIDRPGSLCT_EXIT:
	RET
WIDRPGSLCT	ENDP


; ****************************************************
;	背景をロード
;	-I- BACKPAT : 背景退避用パーツ番号
; ****************************************************

BACKLOAD	PROC	NEAR
	MOV	DX,BACK_NOW_BANK	; 現在退避用バッファ番号
	CALL_w	C1PATBNK		; バンクチェンジ

	MOV	CX,BACKPAT		; 背景退避用パーツ番号
	CALL_w	C1PATPUT		; パーツＰＵＴ

	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ
	RET
BACKLOAD	ENDP

; ****************************************************
;	背景をセーブ
;	-I- WIDBAKXP : 背景退避エリア左上座標Ｘ
;	    WIDBAKYP : 背景退避エリア左上座標Ｙ
;	    WIDBAKXL : 背景退避エリアサイズＸ
;	    WIDBAKYL : 背景退避エリアサイズＹ
;	-O- BACKPAT  : 背景退避用パーツ番号
; ****************************************************

BACKSAVE	PROC	NEAR
	MOV	DX,BACK_NOW_BANK	; 現在退避用バッファ番号
	CALL_w	C1PATBNK		; バンクチェンジ

	CALL_w	C1PATCLR	; パーツセットクリア

	MOV	AX,WIDBAKXP	; 背景退避エリア左上座標Ｘ
	MOV	VRX,AX		; ＶＲＡＭ　Ｘ座標
	MOV	AX,WIDBAKYP	; 背景退避エリア左上座標Ｙ
	MOV	VRY,AX		; ＶＲＡＭ　Ｙ座標
	MOV	AX,WIDBAKXL	; 背景退避エリアサイズＸ
	MOV	VRLENX,AX	; Ｘ方向長さ
	MOV	AX,WIDBAKYL	; 背景退避エリアサイズＹ
	MOV	VRLENY,AX	; Ｙ方向長さ

	CALL_w	C1PATGTA	; パーツＧＥＴ圧縮無し

	MOV	DX,NORMAL_BANK	; 通常のパーツバンク番号
	CALL_w	C1PATBNK	; バンクチェンジ

	MOV	BACKPAT,0	; 背景退避用パーツ番号
	RET
BACKSAVE	ENDP



;	簡易指定の取り出し
;	-I- ES:[BX]  : 指定文字列
;	-O- ATMMAX   : 表示単語の数
;	    ATMTBL[] : 表示単語アドレス
;	    ATMSEG   : テキストバッファセグメント
;	DB	"話す,渡す,行く",0

WIDSLCKANI	PROC	NEAR
	PUSH	ES
	PUSH	BX

	MOV	ATMSEG,ES		; テキストバッファセグメント
	MOV	ATMMAX,0		; 表示単語の数

	CMP	BYTE PTR ES:[BX],EOS
	JE	WIDSLCKANI_LOOP_END

	MOV	SI,0			; word pointer.
	MOV	CX,ATMDIM	 	; WINDOWS/表示単語のﾃｰﾌﾞﾙｻｲｽﾞ
WIDSLCKANI_LOOP:
	MOV	DS:ATMTBL[SI],BX	; 表示単語アドレス
	INC	SI			;
	INC	SI			; word pointer.
	INC	ATMMAX			; 表示単語の数

	MOV	DX,80*2			; ８０＊２文字以上はカット
WIDSLCKANI_LOOP_2:
	MOV	AL,ES:[BX]		; 指定文字列
	INC	BX			;
	CMP	AL,EOS			; end of string.
	JE	WIDSLCKANI_LOOP_END	;
	CMP	AL,CHR_DELIM		; 単語の区切り
	JE	WIDSLCKANI_NEXT		;
	DEC	DX			;
	JNZ	WIDSLCKANI_LOOP_2	;

WIDSLCKANI_NEXT:
	LOOP	WIDSLCKANI_LOOP		;
WIDSLCKANI_LOOP_END:
	POP	BX
	POP	ES
	RET
WIDSLCKANI	ENDP



;*;;	マウス・ロケーション復帰
;*;;	-I- MUS_BACK_X : マウスＸ退避
;*;;	    MUS_BACK_Y : マウスＹ退避
;*;;	-O- MUS_NOW_X  : マウスＸセレクト位置
;*;;	    MUS_NOW_Y  : マウスＹセレクト位置
;*;
;*;WID_MUS_ALC_BACK	PROC	NEAR
;*;	CALL_w	MUSRED			; マウス読み込み
;*;	MOV	MUS_NOW_X,AX		; マウスＸセレクト位置
;*;	MOV	MUS_NOW_Y,BX		; マウスＹセレクト位置
;*;
;*;	MOV	AX,MUS_BACK_X		; マウスＸ退避
;*;	MOV	BX,MUS_BACK_Y		; マウスＹ退避
;*;	CALL_w	MUSSET			; マウス座標セット
;*;WID_MUS_ALC_BACK_EXIT:
;*;	RET
;*;WID_MUS_ALC_BACK	ENDP



;	ウインドウの位置ぎめ

WINDOW_ALOC	PROC	NEAR
	CALL	TANGO_LEN		; 単語の最大長を調べる
	MOV	AX,TANGO_MAXLEN		; 単語の最大長
	MOV	WORD_LENGTH,AX		; １単語表示長さ

	MOV	AX,WID1X		; ウインドウ発生位置左上座標Ｘ
	MOV	BX,WID1Y		; ウインドウ発生位置左上座標Ｙ
	MOV	WID1X_BAK,AX		; ウインドウ発生位置左上座標Ｘ退避
	MOV	WID1Y_BAK,BX		; ウインドウ発生位置左上座標Ｙ退避

	MOV	WIDSIFLG,0		; ウインドウの一時的な移動フラグ

;*;	CMP	ATMMAX,3		; 表示単語の数が３以上は
;*;	JGE	WINDOW_ALOC_EXIT	;一時的な移動は、行わない
;*;
;*;	CALL	WIDLOCATE		; ウインドウロケーション計算
;*;
;*;	CALL_w	MUSRED			; マウス読み込み
;*;	SUB	BX,WIDSLCYP		; ウインドウエリア左上座標Ｙ
;*;	JB	WINDOW_ALOC_5		;
;*;	CMP	BX,WIDSLCYL		; ウインドウエリアサイズＹ
;*;	JL	WINDOW_ALOC_EXIT
;*;WINDOW_ALOC_5:
;*;	ADD	BX,WIDSLCYP		; ウインドウエリア左上座標Ｙ
;*;
;*;	MOV	WIDSIFLG,1		; ウインドウの一時的な移動フラグ
;*;
;*;	MOV	AX,WIDSLCYL		; ウインドウエリアサイズＹ
;*;	SHR	AX,1			; / 2
;*;	CMP	ATMMAX,1		; 表示単語の数
;*;	JE	WINDOW_ALOC_7		;
;*;	SHR	AX,1			; / 2
;*;WINDOW_ALOC_7:
;*;	SUB	BX,AX			;
;*;	MOV	WID1Y,BX		; ウインドウ発生位置左上座標Ｙ
;*;	CMP	WID1Y,0			;
;*;	JG	WINDOW_ALOC_EXIT	;
;*;	MOV	WID1Y,0			;
WINDOW_ALOC_EXIT:
	RET
WINDOW_ALOC	ENDP



;	ウインドウの位置戻し

WINDOW_DEALOC	PROC	NEAR
	CMP	WIDSIFLG,1		; ウインドウの一時的な移動フラグ
	JNE	WINDOW_DEALOC9		;
	MOV	AX,WID1X_BAK		; ウインドウ発生位置左上座標Ｘ退避
	MOV	BX,WID1Y_BAK		; ウインドウ発生位置左上座標Ｙ退避
	MOV	WID1X,AX		; ウインドウ発生位置左上座標Ｘ
	MOV	WID1Y,BX		; ウインドウ発生位置左上座標Ｙ
WINDOW_DEALOC9:
	RET
WINDOW_DEALOC	ENDP



;	ウインドウオープン

WINDOW_OPEN	PROC	NEAR
	CALL	WIDLOCATE		; ウインドウロケーション計算
	CALL	BACKSAVE		; 背景をセーブ
	CALL	WIDFRAME		; フレーム配置
	CALL	WIDMNUINI		; メニューバー初期化
	CALL	WIDWORD_WRITE		; 単語を表示
	RET
WINDOW_OPEN	ENDP



;	ウインドウクローズ

WINDOW_CLOSE	PROC	NEAR
	CALL	BACKLOAD	; 背景をロード
	RET
WINDOW_CLOSE	ENDP


; ****************************************************
;	PC98 vram bank1 open.
; ****************************************************

PC98OPEN	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PC98		; PC9801
	JNE	PC98OPEN_EXIT			;
	CMP	PLEAN_MODE,1			;プレーンモード 0=片面,1=両面
	JNE	PC98OPEN_EXIT			;

	CALL_w	VRM98NOW			; PC98 vram bank now.
	MOV	AX,BX				;0=VRAM0 write,1=VRAM1 write.
	PUSH	AX				;
	XOR	AX,1				;
	CALL_w	VRM98WT				; PC98 vram write bank.

	CALL	WIDFRAME			; フレーム配置
	CALL	WIDMNUINI			; メニューバー初期化
	CALL	WIDWORD_WRITE			; 単語を表示

	POP	AX				;
	CALL_w	VRM98WT				; PC98 vram write bank.
PC98OPEN_EXIT:
	RET
PC98OPEN	ENDP


; ****************************************************
;	PC98 vram bank1 close.
; ****************************************************

PC98CLOSE	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PC98		; PC9801
	JNE	PC98CLOSE_EXIT			;
	CMP	PLEAN_MODE,1			;プレーンモード 0=片面,1=両面
	JNE	PC98CLOSE_EXIT			;

	CALL_w	VRM98NOW			; PC98 vram bank now.
	MOV	AX,BX				;0=VRAM0 write,1=VRAM1 write.
	PUSH	AX				;
	XOR	AX,1				;
	CALL_w	VRM98WT				; PC98 vram write bank.

	CALL	BACKLOAD			; 背景をロード

	POP	AX				;
	CALL_w	VRM98WT				; PC98 vram write bank.
PC98CLOSE_EXIT:
	RET
PC98CLOSE	ENDP


;	ウインドウセレクト
;	-I- WIDDIMX[]: セレクト単語座標Ｘ
;	    WIDDIMY[]: セレクト単語座標Ｙ
;	    WIDDMAX  : セレクト単語数
;	    WIDMSIZX : 表示単語Ｘサイズ
;	    WIDMSIZY : 表示単語Ｙサイズ
;	-O- WIDSNM   : ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ/ユーザ選択番号
;	             : =FFFFH : 指定なし

WINDOW_SELECT	PROC	NEAR
;*;	CALL_w	MSCWAT		; カーソルボタンＯＦＦ待ち
;*;	CALL_w	MSCWATTM	; カーソルボタンＯＦＦ待ち（待ちタイマ付き）

	MOV	WIDWORD_NOW,OFFF	; 現在の選択された表示単語の番号

	MOV	WIDSNM,OFFF		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ/ユーザ選択番号

WINDOW_SELECT_LOOP:
	CALL_w	MSCMOV			; カーソル移動
	MOV	MOUSEX,AX		; マウスＸ
	MOV	MOUSEY,BX		; マウスＹ

	CMP	FLAG_LEFT_BOTTON_DISABLE,0 ; ﾌﾗｸﾞ右ﾎﾞﾀﾝ無効
	JNE	WINDOW_SELECT_1		;
	CMP	DL,1			; 右ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	WINDOW_SELECT_1		;
	MOV	WIDSNM,OFFF		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ/ユーザ選択番号
	JMP	WINDOW_SELECT_EXIT
WINDOW_SELECT_1:			;
	CMP	DH,1			; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	WINDOW_SELECT_2		;


	CALL	WINDOW_MENUBAR		; ウインドウメニューバー
	CMP	AX,1			; メニュー処理があった
	JE	WINDOW_SELECT_LOOP

	CMP	WIDSNM,OFFF		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／ユーザ選択番号
	JE	WINDOW_SELECT_2		;

	JMP	WINDOW_SELECT_EXIT	;
WINDOW_SELECT_2:			;

	CALL	WINDOW_M_BTN		; ウインドウメニューバー・ボタン

	MOV	SI,0			; word pointer.
	MOV	CX,WIDDMAX		; セレクト単語数
WINDOW_SELECT_CHK_LOOP:			;
	MOV	BP,CX			;
	MOV	AX,DS:WIDDIMX[SI]	; AX=セレクト単語座標Ｘ左上
	MOV	BX,DS:WIDDIMY[SI]	; BX=セレクト単語座標Ｙ左上
	MOV	CX,AX			;
	MOV	DX,BX			;
	ADD	CX,WIDMSIZX		; CX=セレクト単語座標Ｘ右下
	ADD	DX,WIDMSIZY		; DX=セレクト単語座標Ｙ右下

	CMP	MOUSEX,AX		; セレクト単語座標Ｘ
	JB	WINDOW_SELECT_NEXT	;
	CMP	MOUSEY,BX		; セレクト単語座標Ｙ
	JB	WINDOW_SELECT_NEXT	;
	CMP	MOUSEX,CX		; セレクト単語座標Ｘ
	JNB	WINDOW_SELECT_NEXT	;
	CMP	MOUSEY,DX		; セレクト単語座標Ｙ
	JNB	WINDOW_SELECT_NEXT	;

	SHR	SI,1			;
	MOV	WIDSNM,SI		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ/ユーザ選択番号

	CALL	WINDOW_SELECT_ON	; 選択単語の反転

	JMP	WINDOW_SELECT_NEXT2	;

WINDOW_SELECT_NEXT:			;
	INC	SI			; word pointer.
	INC	SI			;
	MOV	CX,BP			;
	LOOP	WINDOW_SELECT_CHK_LOOP	;

	CALL	WINDOW_SELECT_OFF	; 選択単語の反転を戻す

	MOV	WIDSNM,OFFF		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ/ユーザ選択番号

WINDOW_SELECT_NEXT2:
	JMP	WINDOW_SELECT_LOOP

WINDOW_SELECT_EXIT:
;*;	CALL_w	MSCWAT		; カーソルボタンＯＦＦ待ち
;*;	CALL_w	MSCWATTM	; カーソルボタンＯＦＦ待ち（待ちタイマ付き）
WINDOW_SELECT_EXIT2:
	RET
WINDOW_SELECT	ENDP


;	選択単語の反転
;	-I-   WIDSNM : ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ/ユーザ選択番号
;	-I/O- AX : X1
;	      BX : Y1
;	      CX : X2
;	      DX : Y2
;	      WIDWORD_NOW : 現在の選択された表示単語の番号
;	      WIDHNX1 : ウインドウ反転Ｘ１
;	      WIDHNY1 : ウインドウ反転Ｙ１
;	      WIDHNX2 : ウインドウ反転Ｘ２
;	      WIDHNY2 : ウインドウ反転Ｙ２

WINDOW_SELECT_ON	PROC	NEAR
	SUB	CX,1			; 表示単語Ｘスタイル微調整
	SUB	DX,2			; 表示単語Ｙスタイル微調整

	MOV	DI,WIDSNM		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ/ユーザ選択番号
	CMP	DI,WIDWORD_NOW		; 現在の選択された表示単語の番号
	JNE	WINDOW_SELECT_ON4	; 表示反転中か？
	JMP	WINDOW_SELECT_ONEXIT
WINDOW_SELECT_ON4:
	PUSH	AX			; X1
	PUSH	BX			; Y1
	PUSH	CX			; X2
	PUSH	DX			; Y2

	CALL_w	MSCSTP			; カーソルストップ

	CMP	WIDWORD_NOW,OFFF	; 現在の選択された表示単語の番号
	JE	WINDOW_SELECT_ON5	; 表示反転ＯＦＦ？
	CALL	XBOXOFF			; box off.
WINDOW_SELECT_ON5:			; 表示反転もとにもどして

	MOV	CX,WIDSNM		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ/ユーザ選択番号
	MOV	WIDWORD_NOW,CX		; 現在の選択された表示単語の番号

	POP	WIDHNY2			; ウインドウ反転Ｙ２
	POP	WIDHNX2			; ウインドウ反転Ｘ２
	POP	WIDHNY1			; ウインドウ反転Ｙ１
	POP	WIDHNX1			; ウインドウ反転Ｘ１
	CALL	XBOXON			; box on.
					; 新たに指定された単語
	CALL_w	MSCSRT			; カーソルスタート
WINDOW_SELECT_ONEXIT:
	RET
WINDOW_SELECT_ON	ENDP



;	選択単語の反転を戻す
;	-I-   WIDHNX1 : ウインドウ反転Ｘ１
;	      WIDHNY1 : ウインドウ反転Ｙ１
;	      WIDHNX2 : ウインドウ反転Ｘ２
;	      WIDHNY2 : ウインドウ反転Ｙ２
;	-I/O- WIDWORD_NOW : 現在の選択された表示単語の番号

WINDOW_SELECT_OFF	PROC	NEAR
	CMP	WIDWORD_NOW,OFFF	; 表示反転ＯＦＦ？
	JE	WINDOW_SELECT_OFF3	;
	CALL_w	MSCSTP			; カーソルストップ

	CALL	XBOXOFF			; box off.

	CALL_w	MSCSRT			; カーソルスタート
	MOV	WIDWORD_NOW,OFFF	; とりあえずＯＦＦ
WINDOW_SELECT_OFF3:
	RET
WINDOW_SELECT_OFF	ENDP


;	box off.

XBOXOFF	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JNE	XBOXOFF_ONE_SIDE	;
	CMP	PLEAN_MODE,1		;プレーンモード 0=片面,1=両面
	JE	XBOXOFF_TWO_SIDE	;
XBOXOFF_ONE_SIDE:
	CALL	XBOXPBK			; box off.
	RET
XBOXOFF_TWO_SIDE:
	CALL_w	VRM98NOW		; PC98 vram bank now.
	MOV	AX,BX			;
	PUSH	AX			; 0=VRAM0 write,1=VRAM1 write.
	XOR	AX,1			;
	CALL_w	VRM98WT			; PC98 vram write bank.
	CALL	XBOXPBK			; box off.
	POP	AX			;
	CALL_w	VRM98WT			; PC98 vram write bank.
	CALL	XBOXPBK			; box off.
	RET
XBOXOFF	ENDP


;	box on.

XBOXON	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JNE	XBOXON_ONE_SIDE		;
	CMP	PLEAN_MODE,1		;プレーンモード 0=片面,1=両面
	JE	XBOXON_TWO_SIDE		;
XBOXON_ONE_SIDE:
	CALL	XBOXPPA			; box on.
	RET
XBOXON_TWO_SIDE:
	CALL_w	VRM98NOW		; PC98 vram bank now.
	MOV	AX,BX			;
	PUSH	AX			; 0=VRAM0 write,1=VRAM1 write.
	XOR	AX,1			;
	CALL_w	VRM98WT			; PC98 vram write bank.
	CALL	XBOXPPA			; box on.
	POP	AX			;
	CALL_w	VRM98WT			; PC98 vram write bank.
	CALL	XBOXPPA			; box on.
	RET
XBOXON	ENDP


;	box off.

XBOXPBK	PROC	NEAR
	BOXPBK WIDHNX1,WIDHNY1,WIDHNX2,WIDHNY2	;,SSDES0 ;ＢＯＸ１プレーンヌキ
	RET
XBOXPBK	ENDP


;	box on.

XBOXPPA	PROC	NEAR
	BOXPPA WIDHNX1,WIDHNY1,WIDHNX2,WIDHNY2 ;ＢＯＸ１プレーンペイント
	RET
XBOXPPA	ENDP

;	ウインドウメニューバー・ボタン
;	-I/O- MOUSEX  : マウスＸ
;	      MOUSEY  : マウスＹ
;	      WIDBARX1: メニューバー左上Ｘ座標
;	      WIDBARY1: メニューバー左上Ｙ座標
;	      WIDBARX2: メニューバー左上Ｘ座標
;	      WIDBARY2: メニューバー左上Ｙ座標

WINDOW_M_BTN	PROC	NEAR
	MOV	AX,MOUSEX		; マウスＸ
	MOV	BX,MOUSEY		; マウスＹ
	CMP	AX,WIDBARX1		; メニューバー左上Ｘ座標
	JB	WINDOW_M_BTN_1		;
	CMP	BX,WIDBARY1		; メニューバー左上Ｙ座標
	JB	WINDOW_M_BTN_1		;
	CMP	AX,WIDBARX2		; メニューバー左上Ｘ座標
	JNBE	WINDOW_M_BTN_1		;
	CMP	BX,WIDBARY2		; メニューバー左上Ｙ座標
	JNBE	WINDOW_M_BTN_1		;
	MOV	AX,1			; 1=ＯＮ
	JMP	WINDOW_M_BTN_12		;
WINDOW_M_BTN_1:
	MOV	AX,0			; 0=ＯＦＦ
WINDOW_M_BTN_12:
	PUSH	DX
	CALL	WIDBAR_BTN		; メニューバー・ボタン
	POP	DX
	RET
WINDOW_M_BTN	ENDP


;	ウインドウメニューバー
;	今のところ、移動処理のみ
;	処理があった場合はウインドウ関係は全て変更する
;	-I/O- MOUSEX  : マウスＸ
;	      MOUSEY  : マウスＹ
;	      DH      : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;	      DL      : 右ボタン（1：ＯＦＦ／0：ＯＮ）
;	      WIDBARX1: メニューバー左上Ｘ座標
;	      WIDBARY1: メニューバー左上Ｙ座標
;	      WIDBARX2: メニューバー左上Ｘ座標
;	      WIDBARY2: メニューバー左上Ｙ座標
;	      WIDSIFLG: ウインドウの一時的な移動フラグ
;	-O- AX        : 0=通常,1=メニュー処理があった

WINDOW_MENUBAR	PROC	NEAR
	CALL	WINDOW_SELECT_OFF	; 選択単語の反転を戻す

WINDOW_MENUBAR_LOOP:
	CMP	DH,0			; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	WINDOW_MENUBAR_ON	;
	CMP	DL,0			; 右ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	WINDOW_MENUBAR_ON	;
	JMP	WINDOW_MENUBAR_EXIT_OFF	;
WINDOW_MENUBAR_ON:
	MOV	AX,MOUSEX		; マウスＸ
	MOV	BX,MOUSEY		; マウスＹ
	MOV	WIDMN_BASEX_MUS,AX	; ウインドウ移動相対基準位置Ｘマウス
	MOV	WIDMN_BASEY_MUS,BX	; ウインドウ移動相対基準位置Ｙマウス

	CMP	AX,WIDBARX1		; メニューバー左上Ｘ座標
	JMPC	WINDOW_MENUBAR_EXIT_OFF	;
	CMP	BX,WIDBARY1		; メニューバー左上Ｙ座標
	JMPC	WINDOW_MENUBAR_EXIT_OFF	;
	CMP	AX,WIDBARX2		; メニューバー左上Ｘ座標
	JNBE	WINDOW_MENUBAR_EXIT_OFF	;
	CMP	BX,WIDBARY2		; メニューバー左上Ｙ座標
	JNBE	WINDOW_MENUBAR_EXIT_OFF	;

WINDOW_MENUBAR_MUS_LOP:
	CALL_w	MUSRED			; マウス読み込み
	CMP	DL,0			; 右ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	WINDOW_MENUBAR_2	;
	CMP	DH,0			; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	WINDOW_MENUBAR_2	;
	JMP	WINDOW_MENUBAR_EXIT	; メニューバー終了
WINDOW_MENUBAR_2:			;
	CALL_w	MSCMOV			; カーソル移動
	MOV	MOUSEX,AX		; マウスＸ
	MOV	MOUSEY,BX		; マウスＹ

	CMP	AX,WIDMN_BASEX_MUS	; ウインドウ移動相対基準位置Ｘマウス
	JNE	WINDOW_MENUBAR_MOVE	;
	CMP	BX,WIDMN_BASEY_MUS	; ウインドウ移動相対基準位置Ｙマウス
	JNE	WINDOW_MENUBAR_MOVE	;
	JMP	WINDOW_MENUBAR_MUS_LOP	; next try.

WINDOW_MENUBAR_MOVE:			;
	MOV	AX,MOUSEX		; マウスＸ
	MOV	BX,MOUSEY		; マウスＹ
	SUB	AX,WIDMN_BASEX_MUS	; 移動相対量計算Ｘ
	SUB	BX,WIDMN_BASEY_MUS	; 移動相対量計算Ｙ
	ADD	AX,WID1X		; ウインドウ発生位置左上座標Ｘ
	ADD	BX,WID1Y		; ウインドウ発生位置左上座標Ｙ

	MOV	WID1X,AX		; ウインドウ発生位置左上座標Ｘ
	MOV	WID1Y,BX		; ウインドウ発生位置左上座標Ｙ

	MOV	AX,MOUSEX		; マウスＸ
	MOV	BX,MOUSEY		; マウスＹ
	MOV	WIDMN_BASEX_MUS,AX	; 移動相対量計算Ｘ
	MOV	WIDMN_BASEY_MUS,BX	; 移動相対量計算Ｙ

	CALL_w	MSCSTP			; カーソルストップ
	CALL	WINDOW_CLOSE		; ウインドウクローズ
	CALL	WINDOW_OPEN		; ウインドウオープン
	CALL_w	MSCSRT			; カーソルスタート

	MOV	WIDSIFLG,0		; ウインドウの一時的な移動フラグ
WINDOW_MENUBAR_NEXT:
	JMP	WINDOW_MENUBAR_MUS_LOP	; next try.

WINDOW_MENUBAR_EXIT:			;
	MOV	AX,1			; 1=メニュー処理があった
	RET
WINDOW_MENUBAR_EXIT_OFF:		;
	MOV	AX,0			; 0=通常
	RET
WINDOW_MENUBAR	ENDP



;	ウインドウロケーション計算
;	-I-   ATMMAX  : 表示単語の数
;	-I/O- WID1X   : ウインドウ発生位置左上座標Ｘ
;	      WID1Y   : ウインドウ発生位置左上座標Ｙ
;	-O-   WIDSLCXP: ウインドウエリア左上座標Ｘ
;	      WIDSLCYP: ウインドウエリア左上座標Ｙ
;	      WIDSLCXL: ウインドウエリアサイズＸ
;	      WIDSLCYL: ウインドウエリアサイズＹ
;	      WIDSLCXM: ウインドウ表示単語左上座標Ｘ
;	      WIDSLCYM: ウインドウ表示単語左上座標Ｙ
;	      WIDBAKXP: 背景退避エリア左上座標Ｘ
;	      WIDBAKYP: 背景退避エリア左上座標Ｙ
;	      WIDBAKXL: 背景退避エリアサイズＸ
;	      WIDBAKYL: 背景退避エリアサイズＹ
;	      WIDBARX1: メニューバー左上Ｘ座標
;	      WIDBARY1: メニューバー左上Ｙ座標
;	      WIDBARX2: メニューバー左上Ｘ座標
;	      WIDBARY2: メニューバー左上Ｙ座標
;	      WIDMSIZX: 表示単語Ｘサイズ
;	      WIDMSIZY: 表示単語Ｙサイズ
;	      WIDDMAX : セレクト単語数

WIDLOCATE	PROC	NEAR
	MOV	AX,ATMMAX		; 表示単語の数
	CMP	AX,SELECT_MAX		; セレクト単語数上限
	JBE	WIDLOCATE1		;
	MOV	AX,SELECT_MAX		;
WIDLOCATE1:				;
	MOV	WIDDMAX,AX		; セレクト単語数

	CMP	WID1X,VIEW_MIN_X	; ディスプレイのＸ方向最小
	JGE	WIDLOCATE11		;
	MOV	WID1X,VIEW_MIN_X	; ディスプレイのＸ方向最小
WIDLOCATE11:				;
	CMP	WID1Y,VIEW_MIN_Y	; ディスプレイのＹ方向最小
	JGE	WIDLOCATE12		;
	MOV	WID1Y,VIEW_MIN_Y	; ディスプレイのＹ方向最小
WIDLOCATE12:				;

WIDLOCATE2:
	MOV	AX,WID1X		; ウインドウ発生位置左上座標Ｘ
	MOV	BX,WID1Y		; ウインドウ発生位置左上座標Ｙ

	MOV	WIDSLCXP,AX		; ウインドウエリア左上座標Ｘ
	MOV	WIDSLCYP,BX		; ウインドウエリア左上座標Ｙ

	MOV	WIDBAKXP,AX		; 背景退避エリア左上座標Ｘ
	MOV	WIDBAKYP,BX		; 背景退避エリア左上座標Ｙ

	MOV	WIDBARX1,AX		; メニューバー左上Ｘ座標
	MOV	WIDBARY1,BX		; メニューバー左上Ｙ座標

	ADD	AX,WIDMOFSX		; ウインドウ文字オフセット位置Ｘ
	ADD	BX,WIDMOFSY		; ウインドウ文字オフセット位置Ｙ
	MOV	WIDSLCXM,AX		; ウインドウ表示単語左上座標Ｘ
	MOV	WIDSLCYM,BX		; ウインドウ表示単語左上座標Ｙ

	MOV	AX,WORD_LENGTH		; １単語表示長さ
	ADD	AX,WIDMOFSX		; ウインドウ文字オフセット位置Ｘ
	ADD	AX,WIDMMGEX		; ウインドウ右端マージンＸ
	MOV	WIDSLCXL,AX		; ウインドウエリアサイズＸ

	MOV	AX,WORD_LENGTH		; １単語表示長さ
	ADD	AX,WIDFROMX		; フレーム厚Ｘ方向
	MOV	WIDBAKXL,AX		; 背景退避エリアサイズＸ

	MOV	BX,WIDBARY1		; メニューバー左上Ｙ座標
	ADD	BX,WIDMOFSY		; ウインドウ文字オフセット位置Ｙ
	DEC	BX			;
	MOV	WIDBARY2,BX		; メニューバー左上Ｙ座標

	MOV	AX,WIDBARX1		; メニューバー左上Ｘ座標
	ADD	AX,WORD_LENGTH		; １単語表示長さ
	MOV	WIDBARX2,AX		; メニューバー左上Ｘ座標


	MOV	BX,WIDDMAX		; セレクト単語数
	MOV	AX,WORD_HIGHT		; ×１単語表示高さ
	CWD				;
	IMUL	BX			;

	MOV	BX,AX			; BX = AX

	ADD	AX,WIDMOFSY		; ウインドウ文字オフセット位置Ｙ
	ADD	AX,WIDMMGEY		; ウインドウ下端マージンＹ
	MOV	WIDSLCYL,AX		; ウインドウエリアサイズＹ

	ADD	BX,WIDFROMY		; フレーム厚Ｙ方向
	MOV	WIDBAKYL,BX		; 背景退避エリアサイズＹ

	MOV	AX,WORD_LENGTH		; １単語表示長さ
	MOV	BX,WORD_HIGHT		; １単語表示高さ
	MOV	WIDMSIZX,AX		; 表示単語Ｘサイズ
	MOV	WIDMSIZY,BX		; 表示単語Ｙサイズ

	MOV	AX,WID1X		; ウインドウ発生位置左上座標Ｘ
	MOV	BX,WID1Y		; ウインドウ発生位置左上座標Ｙ
	CALL	WID_MOVECHK		; ウインドウ移動先チェック
	CMP	DX,0			; 0=移動してよい
	JE	WIDLOCATE_EXIT		;

	TEST	WIDMOVSTA,1B		; Ｘ方向のＶＩＥＷオーバ
	JZ	WIDLOCATE7		;
	MOV	AX,VIEW_SID_X		; ディスプレイのＸ長さ
	SUB	AX,WIDBAKXL		; 背景退避エリアサイズＹ
	MOV	WID1X,AX		; ウインドウ発生位置左上座標Ｘ
WIDLOCATE7:

	TEST	WIDMOVSTA,10B		; Ｙ方向のＶＩＥＷオーバ
	JZ	WIDLOCATE8		;
	MOV	BX,VIEW_SID_Y		; ディスプレイのＹ長さ
	SUB	BX,WIDBAKYL		; 背景退避エリアサイズＸ
	MOV	WID1Y,BX		; ウインドウ発生位置左上座標Ｙ
WIDLOCATE8:
	JMP	WIDLOCATE2		; next try.

WIDLOCATE_EXIT:
	RET
WIDLOCATE	ENDP


;	ウインドウ移動先チェック
;	-I- AX       :(WID1X)ウインドウ発生位置左上座標Ｘ
;	    BX       :(WID1Y)ウインドウ発生位置左上座標Ｙ
;	    WIDBAKXL : 背景退避エリアサイズＸ
;	    WIDBAKYL : 背景退避エリアサイズＹ
;	-O- DX       : 0=移動してよい,1=その移動先は危ない
;	    WIDMOVSTA: ウインドウ移動の詳細情報
;	             : xxxxxxx1B Ｘ方向のＶＩＥＷオーバ
;	             : xxxxxx1xB Ｙ方向のＶＩＥＷオーバ

WID_MOVECHK	PROC	NEAR
	PUSH	AX
	PUSH	BX
	AND	WIDMOVSTA,0FFFCH ; ウインドウ移動の詳細情報

	ADD	AX,WIDBAKXL	; 右下座標Ｘを計算
	DEC	AX		;
	CMP	AX,VIEW_MAX_X	; ディスプレイのＸ方向最大
	JBE	WID_MOVECHK2	;

	OR	WIDMOVSTA,1B	; Ｘ方向のＶＩＥＷオーバ
WID_MOVECHK2:

	ADD	BX,WIDBAKYL	; 右下座標Ｙを計算
	DEC	BX		;
	CMP	BX,VIEW_MAX_Y	; ディスプレイのＹ方向最大
	JBE	WID_MOVECHK3	;
	
	OR	WIDMOVSTA,10B	; Ｙ方向のＶＩＥＷオーバ
WID_MOVECHK3:
	TEST	WIDMOVSTA,11B	; ウインドウ移動の詳細情報
	JNZ	WID_MOVECHK_ERR	;

	MOV	DX,0		; 0=移動してよい
	JMP	WID_MOVECHK_EXIT
WID_MOVECHK_ERR:
	MOV	DX,1		; 1=その移動先は危ない
WID_MOVECHK_EXIT:
	POP	BX
	POP	AX
	RET
WID_MOVECHK	ENDP




;	メニューバー初期化
;	-O- WIDMNUBER_FLAG : 0=ＯＦＦ,1=ＯＮ

WIDMNUINI	PROC	NEAR
	CALL_w	MSCSRT			; カーソルスタート
	MOV	WIDMNUBER_FLAG,0	; 0=ＯＦＦ,1=ＯＮ
	MOV	AX,1			; 0=ＯＦＦ,1=ＯＮ
	CALL	WIDBAR_BTN		; メニューバー・ボタン
	CALL_w	MSCSTP			; カーソルストップ
	RET
WIDMNUINI	ENDP





;	フレーム配置
;	-I- WIDSLCXP : ウインドウエリア左上座標Ｘ
;	    WIDSLCYP : ウインドウエリア左上座標Ｙ
;	    WIDSLCXL : ウインドウエリアサイズＸ
;	    WIDSLCYL : ウインドウエリアサイズＹ

WIDFRAME	PROC	NEAR
	MOV	AX,WIDSLCXP	; ウインドウエリア左上座標Ｘ
	MOV	BX,WIDSLCYP	; ウインドウエリア左上座標Ｙ
	MOV	CX,WIDSLCXL	; ウインドウエリアサイズＸ
	MOV	DX,WIDSLCYL	; ウインドウエリアサイズＹ

	ADD	CX,AX		; X2point = Xlength + X1point - 1
	DEC	CX		;
	ADD	DX,BX		; Y2point = Ylength + Y1point - 1
	DEC	DX		;

	MOV	WXX1,AX		; ウインドウ座標Ｘ１
	MOV	WYY1,BX		; ウインドウ座標Ｙ１
	MOV	WXX2,CX		; ウインドウ座標Ｘ２
	MOV	WYY2,DX		; ウインドウ座標Ｙ２
	CALL	WIDFRM		; ウインドウフレーム
	RET
WIDFRAME	ENDP


;	メニューバー・ボタン
;	-I- AX       : 0=ＯＦＦ,1=ＯＮ
;	    WIDSLCXP : ウインドウエリア左上座標Ｘ
;	    WIDSLCYP : ウインドウエリア左上座標Ｙ
;	    WIDSLCXL : ウインドウエリアサイズＸ
;	    WIDSLCYL : ウインドウエリアサイズＹ
;	-I/O- WIDMNUBER_FLAG : メニューバー・ボタン 0=ＯＦＦ,1=ＯＮ

WIDBAR_BTN	PROC	NEAR
	CMP	AX,WIDMNUBER_FLAG	; 0=ＯＦＦ,1=ＯＮ
	JE	WIDBAR_BTN_EXIT		;

	MOV	WIDMNUBER_FLAG,AX	; 0=ＯＦＦ,1=ＯＮ

	CMP	AX,1			; 0=ＯＦＦ,1=ＯＮ
	JE	WIDBAR_BTN_ON		;
WIDBAR_BTN_OFF:
	CALL_w	MSCSTP			; カーソルストップ
	MOV	AX,WIDSLCXP		; ウインドウエリア左上座標Ｘ
	MOV	BX,WIDSLCYP		; ウインドウエリア左上座標Ｙ
	ADD	AX,2			;
	ADD	BX,1			;
	CALL_w	WID_FLAME_SLCT_OFF	; WINDOWS/ｾﾚｸﾄｳｲﾝﾄﾞｳ ドラッグ OFF
	CALL_w	MSCSRT			; カーソルスタート
	JMP	WIDBAR_BTN_EXIT		;
WIDBAR_BTN_ON:
	CALL_w	MSCSTP			; カーソルストップ
	MOV	AX,WIDSLCXP		; ウインドウエリア左上座標Ｘ
	MOV	BX,WIDSLCYP		; ウインドウエリア左上座標Ｙ
	ADD	AX,2			;
	ADD	BX,1			;
	CALL_w	WID_FLAME_SLCT_ON	; WINDOWS/ｾﾚｸﾄｳｲﾝﾄﾞｳ ドラッグ ON
	CALL_w	MSCSRT			; カーソルスタート
WIDBAR_BTN_EXIT:
	RET
WIDBAR_BTN	ENDP



;	単語を表示
;	-I- WIDSLCXM : ウインドウ表示単語左上座標Ｘ
;	    WIDSLCYM : ウインドウ表示単語左上座標Ｙ
;	    ATMSEG   : テキストバッファセグメント
;	    ATMMAX   : 表示単語の数
;	    ATMTBL[] : 表示単語アドレス
;	    ATMTLN[] : 表示単語長さ
;	    WIDDMAX  : セレクト単語数
;	-O- WIDDIMX[]: セレクト単語座標Ｘ
;	    WIDDIMY[]: セレクト単語座標Ｙ

WIDWORD_WRITE	PROC	NEAR
	MOV	AX,WIDSLCXM		; ウインドウ表示単語左上座標Ｘ
	MOV	BX,WIDSLCYM		; ウインドウ表示単語左上座標Ｙ
	MOV	WLOCX,AX		; 表示単語Ｘ座標
	MOV	WLOCY,BX		; 表示単語Ｙ座標

	MOV	BX,0			; word pointer.
	MOV	CX,WIDDMAX		; セレクト単語数
WIDWORD_WRITE_LOOP:			;
	PUSH	CX			;
	PUSH	BX			;

	MOV	CX,WLOCX		; 表示単語Ｘ座標
	MOV	DX,WLOCY		; 表示単語Ｙ座標
	MOV	DS:WIDDIMX[BX],CX	; セレクト単語座標Ｘ
	MOV	DS:WIDDIMY[BX],DX	; セレクト単語座標Ｙ

	MOV	SI,DS:ATMTBL[BX]	; 表示単語アドレス
	MOV	CX,DS:ATMTLN[BX]	; 表示単語長さ
	MOV	AX,ATMSEG		; テキストバッファセグメント
	MOV	ES,AX			;

	CALL	TXTWDG			; 単語の取り出し

	MOV	SI,OFFSET STR_BUFF	; 台詞バッファの先頭
	MOV	AX,DS			;
	MOV	ES,AX			;
	MOV	AX,WLOCX		; 表示単語Ｘ座標
	MOV	BX,WLOCY		; 表示単語Ｙ座標
	MOV	MOJIAD,SI		; 表示文字アドレス
	MOV	MOJIX,AX		; 表示文字Ｘ
	MOV	MOJIY,BX		; 表示文字Ｙ
	CALL	MOJI_DSP		; 文字表示

	MOV	AX,WORD_HIGHT		; １単語表示高さ
	ADD	WLOCY,AX		; 表示単語Ｙ座標

	POP	BX			;
	INC	BX			; word pointer.
	INC	BX			;
	POP	CX			;
	LOOP	WIDWORD_WRITE_LOOP	;

	RET
WIDWORD_WRITE	ENDP



;	単語の最大長を調べる
;	-I- ATMTLN[]     : 表示単語長さ
;	    ATMMAX       : 表示単語の数
;	-O- TANGO_MAXLEN : 単語の最大長

TANGO_LEN	PROC	NEAR
	MOV	TANGO_MAXLEN,WORD_MINI_LEN ; １単語表示長さの最小限度

	MOV	BX,0			; word pointer.
	MOV	CX,ATMMAX		; 表示単語の数
TANGO_LEN_LOOP:
	MOV	AX,DS:ATMTLN[BX]	; 表示単語長さ
	CMP	AX,TANGO_MAXLEN		; 単語の最大長
	JBE	TANGO_LEN_5		;
	MOV	TANGO_MAXLEN,AX		; 単語の最大長
TANGO_LEN_5:				;
	INC	BX			; word pointer.
	INC	BX			;
	LOOP	TANGO_LEN_LOOP		;

	RET
TANGO_LEN	ENDP


;	単語テーブル内の単語長さ
;	-I- ATMSEG   : テキストバッファセグメント
;	    ATMMAX   : 表示単語の数
;	    ATMTBL[] : 表示単語アドレス
;	-O- ATMTLN[] : 表示単語長さ

LENGTH_ATM	PROC	NEAR
	MOV	BX,0			; word pointer.
	MOV	CX,ATMMAX		; 表示単語の数
LENGTH_ATM_LOOP:
	PUSH	CX
	PUSH	BX

	MOV	ES,ATMSEG		; テキストバッファセグメント
	MOV	DI,DS:ATMTBL[BX]	; 表示単語アドレス

	CALL	STRLENGTH		; 文字列長さ

	MOV	DS:ATMTLN[BX],CX	; 表示単語長さ

	POP	BX
	POP	CX
	INC	BX			; word pointer.
	INC	BX			;
	LOOP	LENGTH_ATM_LOOP

	RET
LENGTH_ATM	ENDP


;	文字表示
;	-I- MOJIAD : 表示文字アドレス
;	    MOJIX  : 表示文字Ｘ
;	    MOJIY  : 表示文字Ｙ
;	    WORD_LENGTH : １単語表示長さ

MOJI_DSP	PROC	NEAR
	MOV	AX,MOJI_COL	; character color 0-15
	CALL_w	VTXCOL		; character color set.
	MOV	AX,MOJI_SZ	; 0=16x16  1=32x32  2=16x24  3=16x32
	CALL_w	VTXSIZ		; character size set.

	MOV	SI,MOJIAD	; 表示文字アドレス
	MOV	AX,MOJIX	; 表示文字Ｘ
	MOV	BX,MOJIY	; 表示文字Ｙ
	INC	BX		;
	INC	BX		;
	CALL_w	VTXPOR		; vram text print OR.

	MOV	AX,MOJI_COL2	; character color 0-15
	CALL_w	VTXCOL		; character color set.
	MOV	AX,MOJI_SZ2	; 0=16x16  1=32x32  2=16x24  3=16x32
	CALL_w	VTXSIZ		; character size set.

	MOV	SI,MOJIAD	; 表示文字アドレス
	MOV	AX,MOJIX	; 表示文字Ｘ
	MOV	BX,MOJIY	; 表示文字Ｙ
	CALL_w	VTXPOR		; vram text print OR.
	RET
MOJI_DSP	ENDP


;	単語の取り出し
;	-I- ES:SI : 単語の先頭アドレス
;	    CX    : 単語の長さ
;	-O- STR_BUFF: 台詞バッファの先頭

TXTWDG	PROC	NEAR
	CMP	CX,TLKLEN		; 台詞バッファ長さを越えていたら
	JB	TXTWDG2			;
	MOV	CX,TLKLEN		; 台詞バッファ長さを使う
TXTWDG2:				;

	MOV	DI,OFFSET STR_BUFF	; 台詞バッファの先頭
TXTWDG_LOOP:				;
	MOV	AL,ES:[SI]		;
	MOV	DS:[DI],AL		;
	INC	DI			;
	INC	SI			;
TXTWDG_NEXT:				;
	LOOP	TXTWDG_LOOP		; マイナスカウンタは停止する

	MOV	BYTE PTR DS:[DI],END_OF_STR	; end of string.台詞の終わり
TXTWDG_EXIT:
	RET
TXTWDG	ENDP


;	ウインドウフレーム
;	-I- WXX1 : ウインドウ座標Ｘ１
;	    WYY1 : ウインドウ座標Ｙ１
;	    WXX2 : ウインドウ座標Ｘ２
;	    WYY2 : ウインドウ座標Ｙ２

WIDFRM	PROC	NEAR
	MOV	AX,WXX1			; ウインドウ座標Ｘ１
	MOV	BX,WYY1			; ウインドウ座標Ｙ１
	MOV	WDX1,AX			; ウインドウ座標Ｘ１
	MOV	WDY1,BX			; ウインドウ座標Ｙ１

	MOV	AX,WXX2			; ウインドウ座標Ｘ２
	MOV	BX,WYY2			; ウインドウ座標Ｙ２
	SUB	AX,WXX1			; ウインドウ座標Ｘ１
	SUB	BX,WYY1			; ウインドウ座標Ｙ１
	INC	AX			;
	INC	BX			;
	MOV	WDX2,AX			; ウインドウ座標Ｘ２
	MOV	WDY2,BX			; ウインドウ座標Ｙ２

	CALL_w	WID_FLAME_SLCT		; WINDOWS/フレーム・セレクトウインドウ

	RET
WIDFRM	ENDP


;	文字列長さ
;	-I- ES:DI : 文字列アドレス
;	-O- CX    : 表示単語長さ

STRLENGTH	PROC	NEAR
	PUSH	DI

	MOV	CX,256
	MOV	AL,EOS
	REPNE	SCASB

	NEG	CX
	ADD	CX,256

	DEC	CX

	POP	DI

	MOV	DX,CX		; DX=ＥＯＳまでの長さ

	PUSH	DI

	MOV	CX,256
	MOV	AL,CHR_DELIM	; 単語の区切り
	REPNE	SCASB

	NEG	CX
	ADD	CX,256

	DEC	CX

	POP	DI

	CMP	CX,DX
	JL	STRLENGTH_8
	MOV	CX,DX
STRLENGTH_8:
	RET
STRLENGTH	ENDP

WINDOW	ENDS



DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	WIDSNM			; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／ユーザ選択番号
PUBLIC	WIDSBANK		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／一時退避バッファ番号

PUBLIC	WIDSDEMO		; (WIDSLCT.ASM)デモフラグ
				; 0=通常,55=ランダムセレクト
PUBLIC	WIDSDEMOWAIT		; (WIDSLCT.ASM)デモ 待ち時間

PUBLIC	WID1X			; ウインドウ発生位置左上座標Ｘ
PUBLIC	WID1Y			; ウインドウ発生位置左上座標Ｙ
PUBLIC	FLAG_LEFT_BOTTON_DISABLE ; ﾌﾗｸﾞ右ﾎﾞﾀﾝ無効(WIDSLCT.ASM)
;*;PUBLIC MUS_BACK_FLAG		; マウス退避フラグ 1=カーソル位置保存状態

PUBLIC	RPG_WID1X		; RPG用ｳｲﾝﾄﾞｳ発生位置左上座標Ｘ
PUBLIC	RPG_WID1Y		; RPG用ｳｲﾝﾄﾞｳ発生位置左上座標Ｙ

EXTRN	ARAVRM:WORD		; ＶＲＡＭプレーン

EXTRN	SSDES0:WORD		; visual data segment plean 0
EXTRN	SSGR0:WORD		; visual data segment plean 0
EXTRN	SSEFC0:WORD		; visual data segment plean 0
EXTRN	SEGVT0:WORD		; text put vram segment plean 0.
EXTRN	SSCUR0:WORD		; visual data segment plean 0

EXTRN	WDX1:WORD		; WINDOWS/ point x1.
EXTRN	WDY1:WORD		; WINDOWS/ point y1.
EXTRN	WDX2:WORD		; WINDOWS/ point x2.
EXTRN	WDY2:WORD		; WINDOWS/ point y2.

EXTRN 	ATMSEG:WORD		; WINDOWS/テキストバッファセグメント
EXTRN	ATMTBL:WORD		; WINDOWS/表示単語アドレス
EXTRN	ATMTLN:WORD		; WINDOWS/表示単語長さ
EXTRN	ATMVAL:WORD		; WINDOWS/表示単語の数値
EXTRN	ATMMAX:WORD		; WINDOWS/表示単語の数
EXTRN	ATMDIM:WORD	 	; WINDOWS/表示単語のテーブルサイズ

EXTRN	VRX:WORD		; x point.
EXTRN	VRY:WORD		; y point.

EXTRN	VRLENX:WORD		; x length.
EXTRN	VRLENY:WORD		; y length.

EXTRN	VX1:WORD		; source point x1.
EXTRN	VY1:WORD		; source point y1.
EXTRN	VX2:WORD		; length x2.
EXTRN	VY2:WORD		; length y2.
EXTRN	VX3:WORD		; destination point x3.
EXTRN	VY3:WORD		; destination point y3.

EXTRN	STR_BUFF:BYTE		; 文字列バッファ

WIDSNM		DW	0		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／ユーザ選択番号
WIDSBANK	DW	BACKSAVE_BANK	; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／ 一時退避バッファ番号

WIDSDEMO	DW	0	; デモフラグ0=通常,55=ランダムセレクト
WIDSDEMOWAIT	DW	60+30	; デモ 待ち時間

WXX1		DW	0	; ウインドウ座標Ｘ１
WYY1		DW	0	; ウインドウ座標Ｙ１
WXX2		DW	0	; ウインドウ座標Ｘ２
WYY2		DW	0	; ウインドウ座標Ｙ２

WIDCOL		DW	0	; ウインドウ表面カラー
TXCOL2		DW	15	; セレクトコマンドカラー

BACK_NOW_BANK	DW	0	; 現在退避用バッファ番号
BACKPAT		DW	0	; 背景退避用パーツ番号

RPG_WID1X	DW	68	; RPG用ｳｲﾝﾄﾞｳ発生位置左上座標Ｘ
RPG_WID1Y	DW	220	; RPG用ｳｲﾝﾄﾞｳ発生位置左上座標Ｙ
BAK_WID1X	DW	0	; ｳｲﾝﾄﾞｳ発生位置左上座標Ｘ退避
BAK_WID1Y	DW	0	; ｳｲﾝﾄﾞｳ発生位置左上座標Ｙ退避

WID1X		DW	55	; ウインドウ発生位置左上座標Ｘ
WID1Y		DW	220	; ウインドウ発生位置左上座標Ｙ
				; （初期値がはいっています）

WIDSLCXP	DW	0	; ウインドウエリア左上座標Ｘ
WIDSLCYP	DW	0	; ウインドウエリア左上座標Ｙ
WIDSLCXL	DW	0	; ウインドウエリアサイズＸ
WIDSLCYL	DW	0	; ウインドウエリアサイズＹ

WIDBAKXP	DW	0	; 背景退避エリア左上座標Ｘ
WIDBAKYP	DW	0	; 背景退避エリア左上座標Ｙ
WIDBAKXL	DW	0	; 背景退避エリアサイズＸ
WIDBAKYL	DW	0	; 背景退避エリアサイズＹ

WIDBARX1	DW	0	; メニューバー左上Ｘ座標
WIDBARY1	DW	0	; メニューバー左上Ｙ座標
WIDBARX2	DW	0	; メニューバー左上Ｘ座標
WIDBARY2	DW	0	; メニューバー左上Ｙ座標

WIDSLCXM	DW	0	; ウインドウ表示単語左上座標Ｘ
WIDSLCYM	DW	0	; ウインドウ表示単語左上座標Ｙ

WLOCX		DW	0	; 表示単語Ｘ座標
WLOCY		DW	0	; 表示単語Ｙ座標

WIDMSIZX	DW	0	; 表示単語Ｘサイズ
WIDMSIZY	DW	0	; 表示単語Ｙサイズ

WIDDMAX		DW	0	; セレクト単語数

WIDDIMX		DW	SELECT_MAX DUP (0)	; セレクト単語座標Ｘ
WIDDIMY		DW	SELECT_MAX DUP (0)	; セレクト単語座標Ｙ

WIDHNX1		DW	0	; ウインドウ反転Ｘ１
WIDHNY1		DW	0	; ウインドウ反転Ｙ１
WIDHNX2		DW	0	; ウインドウ反転Ｘ２
WIDHNY2		DW	0	; ウインドウ反転Ｙ２

WIDWORD_NOW	DW	0	; 現在の選択された表示単語の番号

WIDMN_BASEX_MUS	DW	0	; ウインドウ移動相対基準位置Ｘマウス
WIDMN_BASEY_MUS	DW	0	; ウインドウ移動相対基準位置Ｙマウス

WIDMOVSTA	DW	0	; ウインドウ移動の詳細情報

WIDSIFLG	DW	0	; ウインドウの一時的な移動フラグ

WID1X_BAK	DW	0	; ウインドウ発生位置左上座標Ｘ退避
WID1Y_BAK	DW	0	; ウインドウ発生位置左上座標Ｙ退避

WORD_LENGTH	DW	6*2	; １単語表示長さ
WORD_HIGHT	DW	20;18	; １単語表示高さ

WIDMNUBER_FLAG	DW	0	; メニューバー・ボタン 0=ＯＦＦ,1=ＯＮ

MOUSEX		DW	0	; マウスＸ
MOUSEY		DW	0	; マウスＹ
MS_BTNL		DB	0,0	; マウスボタン左
MS_BTNR		DB	0,0	; マウスボタン右

;*;MUS_NOW_X	DW	0	; マウスＸセレクト位置
;*;MUS_NOW_Y	DW	0	; マウスＹセレクト位置
;*;MUS_BACK_X	DW	0	; マウスＸ退避
;*;MUS_BACK_Y	DW	0	; マウスＹ退避
;*;MUS_BACK_FLAG DW	0	; マウス退避フラグ

TANGO_MAXLEN	DW	0	; 単語の最大長

MOJIAD		DW	0	; 表示文字アドレス
MOJIX		DW	0	; 表示文字Ｘ
MOJIY		DW	0	; 表示文字Ｙ

TLKLEN		DW	STRING_LEN	; 台詞バッファ長さ

FLAG_LEFT_BOTTON_DISABLE DW	0	; ﾌﾗｸﾞ右ﾎﾞﾀﾝ無効

PLEAN_MODE	DW	1		; プレーンモード 0=片面,1=両面

DATA	ENDS

	END
;
;	end of "WIDSLCT.ASM"
;
