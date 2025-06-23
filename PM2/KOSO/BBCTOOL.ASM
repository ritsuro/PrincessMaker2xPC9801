; "BBCTOOL.ASM" 486/50 make by R.H 1992/05/29
;
;
;	princess  B A S I C    command tool.
;
;
;	* * * WARNING * * *
;	* * *  注 意  * * *
;
;	This subroutines i/o list.
;	このサブルーチン類の I/O list は以下のようになっています。
;
;	AX -> public REG_AX
;	BX -> public REG_BX
;	CX -> public REG_CX
;	DX -> public REG_DX
;	SI -> public REG_SI
;	DI -> public REG_DI
;	ES -> public REG_ES
;
;	; syntax : P1X100(value,x100)	-> ; syntax : P1X100
;	; 百分率			-> ; 百分率
;	; -i- value (AX): source value.	-> ; -i- REG_AX : source value.
;	;     x100  (BX): %		-> ;     REG_BX : %
;	; -o- AX        : value.	-> ; -o- REG_AX : value.
;
;
;
; command routine.

INCLUDE	TSTSETC.INC
INCLUDE	BBEXTRN.INC

MOV_SI	MACRO	STRING
	LOCAL	L1
DATA	SEGMENT PUBLIC	'DATA'
L1	DB	STRING,0
DATA	ENDS
	MOV	SI,OFFSET L1
	ENDM

SLCRPG_WID1X	EQU	66	; RPG用ｳｲﾝﾄﾞｳ発生位置左上座標Ｘ
SLCRPG_WID1Y	EQU	160	; RPG用ｳｲﾝﾄﾞｳ発生位置左上座標Ｙ
SLCRPG_WID2X	EQU	66	; RPG戦闘用ｳｲﾝﾄﾞｳ発生位置左上座標Ｘ
SLCRPG_WID2Y	EQU	160	; RPG戦闘用ｳｲﾝﾄﾞｳ発生位置左上座標Ｙ

OFST_MUSCOR_X	EQU	8*7	; オフセットマウス位置Ｘ
OFST_MUSCOR_Y	EQU	16	; オフセットマウス位置Ｙ

SLCMAIN_WID1X	EQU	60	; メインSLCT発生位置左上座標Ｘ
SLCMAIN_WID1Y	EQU	180	; メインSLCT発生位置左上座標Ｙ
SLCMAIN_WID2X	EQU	50	; メインSLCT絵のあたりＸ
SLCMAIN_WID2Y	EQU	100	; メインSLCT絵のあたりＹ

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:DATA

PUBLIC	BBC_PR			; syntax : PR  ("string")
PUBLIC	BBC_PRES		; syntax : PRES(length)
PUBLIC	BBC_PRF			; syntax : PRF ("string")
PUBLIC	BBC_PRV			; syntax : PRV ("string",C1)
PUBLIC	BBC_PRVH		; syntax : PRVH("string",C1)
PUBLIC	BBC_PRVB		; syntax : PRVB("string",C1)
PUBLIC	BBC_PRINT		; syntax : PRINT(string)
PUBLIC	BBC_STR			; syntax : STR(C1)
PUBLIC	BBC_HEX			; syntax : HEX(C1)
PUBLIC	BBC_BIN			; syntax : BIN(C1)
PUBLIC	BBC_LLF			; syntax : LLF
PUBLIC	BBC_CLS			; syntax : CLS
PUBLIC	BBC_ABS			; syntax : ABS (value)
PUBLIC	BBC_MOD			; syntax : MOD (value)
PUBLIC	BBC_P1X100		; syntax : P1X100(value,x100)
PUBLIC	BBC_P100PAR		; syntax : P100PAR(value,base)
PUBLIC	BBC_SLCT		; syntax : SLCT("str1,str2,str3")
PUBLIC	BBC_SLCTX		; syntax : SLCTX("str1,str2,str3")
PUBLIC	BBC_SLCTBAK		; syntax : SLCTBAK(backbank)
PUBLIC	BBC_SLCPOS		; syntax : SLCPOS(function)
PUBLIC	BBC_FREE		; syntax : FREE
PUBLIC	BBC_END			; syntax : END
PUBLIC	BBC_STRSCLEAR		; syntax : STRSCLEAR
PUBLIC	BBC_STRSTACK		; syntax : STRSTACK("strings")
PUBLIC	BBC_PROGADRS		; syntax : PROGADRS("label")
PUBLIC	BBC_PROGCOPY		; syntax : PROGCOPY(string)
PUBLIC	BBC_STRCOPY		; syntax : STRCOPY("string",string)
PUBLIC	BBC_STRLEN		; syntax : STRLEN(string)
PUBLIC	BBC_LOAD		; syntax : LOAD("file_name")
PUBLIC	BBC_CK_LVL		; syntax : CK_LVL(count,lv1,lv2,lv3,lvm)
PUBLIC	BBC_CK_GUARA		; syntax : CK_GUARA(count,base)
;*;PUBLIC BBC_CRTREWRITE	; syntax : CRTREWRITE
PUBLIC	BBC_TXTSZ		; syntax : TXTSZ(mode)
PUBLIC	BBC_GOLDADD		; syntax : GOLDADD(value)
PUBLIC	BBC_GOLDSUB		; syntax : GOLDSUB(value)
PUBLIC	BBC_GOLDSUB2		; syntax : GOLDSUB2(value)
PUBLIC	BBC_GOLDCMP		; syntax : GOLDCMP(value)
PUBLIC	BBC_EDTX		; syntax : EDTX(function)

PUBLIC	BBCTOOL_LOADINIT	; テキストロード時の初期処理

EXTRN	BBSYMBOL_SCH:NEAR	; symbol table search.
EXTRN	BBSOUSYM_SCH:NEAR	; source symbol table search.

; *********************************************************
;	syntax : PR("string")
;	改行無しプリント
; *********************************************************

BBC_PR	PROC	NEAR
	MOV	SI,REG_SI		; registar value SI.
	CALL	TEXT_PR			; text print.
	RET
BBC_PR	ENDP


; *********************************************************
;	syntax : PRES(length)
;	指定セグメントプリント
;	-I- ES         : string segment.
;	    DI         : string address.
;	    length (AX): length.
; *********************************************************

BBC_PRES	PROC	NEAR
	MOV	ES,REG_ES		; registar value ES.
	MOV	SI,REG_DI		; registar value DI.
	MOV	CX,REG_AX		; registar value AX.
	CALL	TEXT_PRES		; text print.
	RET
BBC_PRES	ENDP


; *********************************************************
;	syntax : PRF("string")
;	改行有りプリント
; *********************************************************

BBC_PRF	PROC	NEAR
	MOV	SI,REG_SI		; registar value SI.
	CALL	TEXT_PR			; text print.
	CALL	TEXT_LF			; text LF.
	RET
BBC_PRF	ENDP


; *********************************************************
;	syntax : PRV("string",C1)
;	改行有りワード値プリント１０進
; *********************************************************

BBC_PRV	PROC	NEAR
	MOV	SI,REG_SI		; registar value SI.
	MOV	AX,REG_AX		; registar value AX.

	CALL	TEXT_PR			; text print.
	MOV	DX,AX			;
	CALL	c_SIGSTR		; signed val DX to dec string.
	CALL	c_STRZTS		; zero to space. "00123" - > "  123"
	CALL	c_STRSPL		; space pless. "  123" - > "123  "
	CALL	TEXT_PR			; text print.
;*;	CALL	TEXT_LF			; text LF.
	RET
BBC_PRV	ENDP


; *********************************************************
;	syntax : PRVH("string",C1)
;	改行有りワード値プリント１６進
; *********************************************************

BBC_PRVH	PROC	NEAR
	MOV	SI,REG_SI		; registar value SI.
	MOV	AX,REG_AX		; registar value AX.

	CALL	TEXT_PR			; text print.
	MOV	DX,AX			;
	CALL	c_HEXSTR		;
	CALL	TEXT_PR		; text print.
	MOV	AL,"h"			;
	CALL	TEXT_CHR		; text 1chr.
;*;	CALL	TEXT_LF			; text LF.
	RET
BBC_PRVH	ENDP


; *********************************************************
;	syntax : PRVB("string",C1)
;	改行有りワード値プリント２進
; *********************************************************

BBC_PRVB	PROC	NEAR
	MOV	SI,REG_SI		; registar value SI.
	MOV	AX,REG_AX		; registar value AX.

	CALL	TEXT_PR			; text print.
	MOV	DX,AX			;
	CALL	c_BINSTR		;
	CALL	TEXT_PR			; text print.
	MOV	AL,"b"			;
	CALL	TEXT_CHR		; text 1chr.
;*;	CALL	TEXT_LF			; text LF.
	RET
BBC_PRVB	ENDP


; *********************************************************
;	syntax : PRINT(string)
;	文字列表示
; *********************************************************

BBC_PRINT	PROC	NEAR
	MOV	SI,REG_AX		; registar value AX.
	CALL	TEXT_PR			; text print.
	RET
BBC_PRINT	ENDP


; *********************************************************
;	syntax : STR(C1)
; *********************************************************

BBC_STR	PROC	NEAR
	MOV	AX,REG_AX		; registar value AX.

	MOV	DX,AX
	CALL	c_SIGSTR		; signed val DX to dec string.
	CALL	c_STRZTS		; zero to space. "00123" - > "  123"
	CALL	c_STRSPL		; space pless. "  123" - > "123  "

	MOV	DI,OFFSET STR_BUFF	; 文字列バッファ
	CALLE	c_WORDTL_N_HNZN		; 文字列半角を全角

	MOV	SI,OFFSET STR_BUFF	; 文字列バッファ
	CALL	TEXT_PR			; text print.
	RET
BBC_STR	ENDP


; *********************************************************
;	syntax : HEX(C1)
; *********************************************************

BBC_HEX	PROC	NEAR
	MOV	SI,REG_SI		; registar value SI.
	MOV	AX,REG_AX		; registar value AX.

	MOV	DX,AX			;
	CALL	c_HEXSTR		;
	CALL	TEXT_PR			; text print.
	MOV	AL,"h"			;
	CALL	TEXT_CHR		; text 1chr.
	RET
BBC_HEX	ENDP


; *********************************************************
;	syntax : BIN(C1)
; *********************************************************

BBC_BIN	PROC	NEAR
	MOV	SI,REG_SI		; registar value SI.
	MOV	AX,REG_AX		; registar value AX.

	MOV	DX,AX			;
	CALL	c_BINSTR		;
	CALL	TEXT_PR			; text print.
	MOV	AL,"b"			;
	CALL	TEXT_CHR		; text 1chr.
	RET
BBC_BIN	ENDP


; *********************************************************
;	syntax : LLF
; *********************************************************

BBC_LLF	PROC	NEAR
	CALL	TEXT_LF			; text LF.
	RET
BBC_LLF	ENDP


; *********************************************************
;	syntax : CLS
; *********************************************************

BBC_CLS	PROC	NEAR
	CALL	TEXT_CLS		; text CLS.
	RET
BBC_CLS	ENDP


; *********************************************************
;	syntax : ABS(value)
;	絶対値
;	-O- AX : value.
; *********************************************************

BBC_ABS	PROC	NEAR
	MOV	AX,REG_AX		; registar value AX.

	CMP	AX,0
	JGE	BBC_ABS_5
	NEG	AX
BBC_ABS_5:
	MOV	REG_AX,AX		; registar value AX.
	RET
BBC_ABS	ENDP


; *********************************************************
;	syntax : MOD (dest,sour)
;	余り
;	-O- AX : value.
; *********************************************************

BBC_MOD	PROC	NEAR
	MOV	AX,REG_AX		; registar value AX.
	MOV	BX,REG_BX		; registar value BX.

	CMP	BX,0
	JE	BBC_MOD_9
	CWD
	IDIV	BX
	MOV	AX,DX
	MOV	REG_AX,AX		; registar value AX.
	RET
BBC_MOD_9:
	XOR	AX,AX	; AX=0
	MOV	REG_AX,AX		; registar value AX.
	RET
BBC_MOD	ENDP


; *********************************************************
;	syntax : P1X100(value,x100)
;	百分率
;	AX = value * x100 / 100
;	-i- value (AX): source value.
;	    x100  (BX): %
;	-o- AX        : value.
; *********************************************************

BBC_P1X100	PROC	NEAR
	MOV	AX,REG_AX		; registar value AX.
	MUL	REG_BX			; registar value BX.
	MOV	BX,100			;
	DIV	BX			;
	MOV	REG_AX,AX		; registar value AX.
	RET
BBC_P1X100	ENDP


; *********************************************************
;	syntax : P100PAR(value,base)
;	百分率を求める
;	AX = 100 / base * value
;	-i- value (AX): source value.
;	    base  (BX): 100% value.
;	-o- AX        : parcent.
; *********************************************************

BBC_P100PAR	PROC	NEAR
	CMP	REG_BX,0
	JE	BBC_P100PAR_ERROR
	MOV	DX,0
	MOV	AX,10000
	DIV	REG_BX
	MUL	REG_AX
	MOV	BX,100
	DIV	BX
	MOV	REG_AX,AX
	RET
BBC_P100PAR_ERROR:
	MOV	REG_AX,100
	RET
BBC_P100PAR	ENDP


; *********************************************************
;	syntax : SLCT("str1,str2,str3")
;	単語の選択
;	-o- ISLCT : user select number.
;	    DX    : user select number.
; *********************************************************

BBC_SLCT	PROC	NEAR
	MOV	SI,REG_SI	; registar value SI.

	MOVX	ES,DS
	MOV	BX,SI		; 指定文字列
	CALLE	c_WIDSLC2	; WINDOWS/セレクト・ウインドウ（簡易指定）

	MOVX	ISLCT,WIDSNM	; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／ユーザ選択番号

	MOV	REG_DX,DX	; registar value DX.
	RET
BBC_SLCT	ENDP


; *********************************************************
;	syntax : SLCTX("str1,str2,str3")
;	単語の選択
;	右ﾎﾞﾀﾝのｷｬﾝｾﾙを無効
;	-o- ISLCT : user select number.
;	    DX    : user select number.
; *********************************************************

BBC_SLCTX	PROC	NEAR
	MOV	FLAG_LEFT_BOTTON_DISABLE,1 ; ﾌﾗｸﾞ右ﾎﾞﾀﾝ無効(WIDSLCT.ASM)
	CALL	BBC_SLCT		; syntax : SLCT("str1,str2,str3")
	MOV	FLAG_LEFT_BOTTON_DISABLE,0 ; ﾌﾗｸﾞ右ﾎﾞﾀﾝ無効(WIDSLCT.ASM)
	RET
BBC_SLCTX	ENDP


; *********************************************************
;	syntax : SLCTBAK(backbank)
;	SLCTの一時的な退避バンクの変更
;	SLCT実行後はデフォルトに戻ります。
;	-i- backbank (AX) : 退避バンク番号
; *********************************************************

BBC_SLCTBAK	PROC	NEAR
	MOVX	WIDSBANK,REG_AX	; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／一時退避バッファ番号
	RET
BBC_SLCTBAK	ENDP


; *********************************************************
;	syntax : SLCPOS(function)
;	SLCTの位置を設定します
;	-i- function : ファンクション
;			1=RPG時の通常位置
;			2=RPG戦闘時の位置
;			3=RPG時WWMUSYA(15,..)のマウス位置
;			4=メインSLCT発生位置
;			5=メインSLCT絵のあたりＸ
;			6=SLCTの座標位置指定
;			 SLCPOS(6,x,y)
; *********************************************************

BBC_SLCPOS	PROC	NEAR
	MOV	AX,REG_AX		; registar value AX.

	CMP	AL,1			;
	JE	BBC_SLCPOS_01N		;
	CMP	AL,2			;
	JE	BBC_SLCPOS_02N		;
	CMP	AL,3			;
	JE	BBC_SLCPOS_03N		;
	CMP	AL,4			;
	JE	BBC_SLCPOS_04N		;
	CMP	AL,5			;
	JE	BBC_SLCPOS_05N		;
	CMP	AL,6			;
	JE	BBC_SLCPOS_06N		;
	RET
BBC_SLCPOS_01N:
	MOV	AX,SLCRPG_WID1X		; RPG用ｳｲﾝﾄﾞｳ発生位置左上座標Ｘ
	MOV	BX,SLCRPG_WID1Y		; RPG用ｳｲﾝﾄﾞｳ発生位置左上座標Ｙ
	MOV	WID1X,AX		; ウインドウ発生位置左上座標Ｘ
	MOV	WID1Y,BX		; ウインドウ発生位置左上座標Ｙ
	JMP	BBC_SLCPOS_MUSPOS	;

BBC_SLCPOS_02N:
	MOV	AX,SLCRPG_WID2X		; RPG戦闘用ｳｲﾝﾄﾞｳ発生位置左上座標Ｘ
	MOV	BX,SLCRPG_WID2Y		; RPG戦闘用ｳｲﾝﾄﾞｳ発生位置左上座標Ｙ
	MOV	WID1X,AX		; ウインドウ発生位置左上座標Ｘ
	MOV	WID1Y,BX		; ウインドウ発生位置左上座標Ｙ
	JMP	BBC_SLCPOS_MUSPOS	;

BBC_SLCPOS_03N:
	MOV	AX,RPG_WID1X		; RPG用ｳｲﾝﾄﾞｳ発生位置左上座標Ｘ
	MOV	BX,RPG_WID1Y		; RPG用ｳｲﾝﾄﾞｳ発生位置左上座標Ｙ
	JMP	BBC_SLCPOS_MUSPOS	;

BBC_SLCPOS_04N:
	MOV	AX,SLCMAIN_WID1X	; メインSLCT発生位置左上座標Ｘ
	MOV	BX,SLCMAIN_WID1Y	; メインSLCT発生位置左上座標Ｙ
	MOV	WID1X,AX		; ウインドウ発生位置左上座標Ｘ
	MOV	WID1Y,BX		; ウインドウ発生位置左上座標Ｙ
	RET

BBC_SLCPOS_05N:
	MOV	AX,SLCMAIN_WID2X	; メインSLCT絵のあたりＸ
	MOV	BX,SLCMAIN_WID2Y	; メインSLCT絵のあたりＹ
	MOV	WID1X,AX		; ウインドウ発生位置左上座標Ｘ
	MOV	WID1Y,BX		; ウインドウ発生位置左上座標Ｙ
	JMP	BBC_SLCPOS_MUSPOS	;

BBC_SLCPOS_06N:
	MOV	AX,REG_BX		;
	MOV	BX,REG_CX		;
	MOV	WID1X,AX		; ウインドウ発生位置左上座標Ｘ
	MOV	WID1Y,BX		; ウインドウ発生位置左上座標Ｙ
	RET

BBC_SLCPOS_MUSPOS:
;;	SHL	AX,1			;
;;	SHL	AX,1			; * 8
;;	SHL	AX,1			;
;;	ADD	AX,OFST_MUSCOR_X	; オフセットマウス位置Ｘ
;;	ADD	BX,OFST_MUSCOR_Y	; オフセットマウス位置Ｙ
;;	CALLE	c_MUSSET		; マウス座標セット
	RET
BBC_SLCPOS	ENDP


; *********************************************************
;	syntax : FREE
; *********************************************************

BBC_FREE	PROC	NEAR
	MOV_SI	"endseg:"
	CALL	TEXT_PR			; text print.
	MOV	DX,SEGFREE		; フリー領域の先頭セグメント
	CALL	c_HEXSTR		;
	CALL	TEXT_PR			; text print.

	MOV_SI	"h, nest table:"
	CALL	TEXT_PR			; text print.
	MOV	DX,NEST_TBL_CNT		; nest count.
	MOV	CX,NEST_TBL_CMAX	; nest count max.
	CALL	DIV_PR			; divide print.

	MOV_SI	",symbol area:"
	CALL	TEXT_PR			; text print.
	MOV	DX,TCHR_SYM_SIZ		; user symbol area size.
	SUB	DX,TCHR_SYM_FSIZ	; user symbol free area size.
	MOV	CX,TCHR_SYM_SIZ		; user symbol area size.
	CALL	DIV_PR			; divide print.

	MOV_SI	",adrs record:"
	CALL	TEXT_PR			; text print.
	MOV	DX,TCHR_ADR_MAX		; user symbol address max.
	SUB	DX,TCHR_ADR_FMAX	; user symbol free address max.
	MOV	CX,TCHR_ADR_MAX		; user symbol address max.
	CALL	DIV_PR			; divide print.

	CALL	TEXT_LF			; text LF.

	MOV_SI	"user area:"
	CALL	TEXT_PR			; text print.
	MOV	DX,USER_FREE_WORD	; user area word size.
	SUB	DX,USER_FREE_FWORD	; user area free word size.
	MOV	CX,USER_FREE_WORD	; user area word size.
	CALL	DIV_PR			; divide print.

	MOV_SI	",label symbol area:"
	CALL	TEXT_PR			; text print.
	MOV	DX,JMPTBLDLEN		; jump table data length.
	MOV	CX,JMPTBLSIZE		; jump table size.
	CALL	DIV_PR			; divide print.
	MOV_SI	",adrs record:"
	CALL	TEXT_PR			; text print.
	MOV	DX,JMPADTBLCNT		; jump adrs table count.
	MOV	CX,JMPADTBLDIM		; jump adrs table dimension.
	CALL	DIV_PR			; divide print.

	CALL	TEXT_LF			; text LF.

;*;	MOV_SI	"girlbody:"
;*;	CALL	TEXT_PR			; text print.
;*;	MOV	DX,GIRL_BODY		; 体形 1=細,2=太
;*;	CALL	c_DECSTR		;
;*;	CALL	TEXT_PR			; text print.
;*;	CALL	TEXT_LF			; text LF.

	RET
BBC_FREE	ENDP


; *********************************************************
;	syntax : END
; *********************************************************

BBC_END	PROC	NEAR
	MOV	FLAGEXIT,1		; exit flag.
	RET
BBC_END	ENDP


; *********************************************************
;	syntax : STRSCLEAR
;	文字列スタッククリア
; *********************************************************

BBC_STRSCLEAR	PROC	NEAR
	MOV	STRINGSTACKPNT,0	; string stack pointer.
	RET
BBC_STRSCLEAR	ENDP


; *********************************************************
;	syntax : STRSTACK("strings")
;	文字列スタックセット
;	-i- "string"(SI) : セットする文字列
;	-o- AX           : 0=正常,1=領域が足りない
;	    BX           : 文字列アドレス
; *********************************************************

BBC_STRSTACK	PROC	NEAR
	MOVX	ES,DS			;
	MOV	DI,REG_SI		; registar value SI.

	CALLE	c_STRLENGTH		; 文字列長さ
	INC	CX			; + e.o.s

	MOV	AX,STRINGSTACKMAX	; string stack max.
	SUB	AX,STRINGSTACKPNT	; string stack pointer.
	CMP	CX,AX			; 表示単語長さ:バッファ最大長さ
	JNBE	BBC_STRSTACK_ERROR	;

	MOV	DI,STRINGSTACKPNT	; string stack pointer.
	ADD	DI,STRINGSTACKBUF	; string stack buffer.
	MOV	REG_BX,DI		; 文字列アドレス

	ADD	STRINGSTACKPNT,CX	; string stack pointer.
	MOV	CX,AX			; バッファ最大長さ

	MOVX	ES,DS			;
	MOV	SI,REG_SI		; registar value SI.
	CALLE	c_STRSETZ		; 文字列バッファセット
BBC_STRSTACK_EXIT:
	MOV	REG_AX,0		; 0=正常
	MOV	BX,REG_BX		;
	MOV	AX,REG_AX		;
	RET
BBC_STRSTACK_ERROR:
	MOVX	REG_BX,NULSTRING	; null string buffer.
	MOV	REG_AX,1		; 1=領域が足りない
	MOV	BX,REG_BX		;
	MOV	AX,REG_AX		;
	RET
BBC_STRSTACK	ENDP


; *********************************************************
;	PROGADRS("label")
;	プログラムアドレスを取り出す
;	-i- "label" : ラベル　必ずダブルクォーテーションで囲うこと
;	-o- ES      : セグメント
;	    DI      : アドレス
; *********************************************************

BBC_PROGADRS	PROC	NEAR
	MOVX	ES,DS			;
	MOV	DI,REG_SI		; registar value SI.
	CALLE	c_STRLENSPZ		; 文字列長さスペースまで

	MOV	DI,REG_SI		; registar value SI.
	CALLE	BBJP_TABLESCH		; jump table search.
	CMP	AX,0			; 0=search,1=none.
	JNE	BBC_PROGADRS_ERROR	;
	MOVX	REG_ES,TEXTPSEG		; registar value ES.
	MOV	REG_DI,DX		; registar value DI.
	MOV	DI,DX
	MOV	ES,REG_ES
	RET
BBC_PROGADRS_ERROR:
	MOV	SI,REG_SI		; registar value SI.
	BBERROR	125			; error message.
	RET
BBC_PROGADRS	ENDP


; *********************************************************
;	PROGCOPY(string)
;	文字列をプログラムアドレスへコピーする
;	-i- string (AX) : セットする文字列
;	    ES          : セグメント
;	    DI          : アドレス
; *********************************************************

BBC_PROGCOPY	PROC	NEAR
	MOVX	ES,DS			;
	MOV	DI,REG_AX		;
	CALL	c_STRLENGTH		; 文字列長さ

	MOV	SI,REG_AX		;
	MOV	ES,REG_ES		; セグメント
	MOV	DI,REG_DI		; アドレス
	DEC	DI			;
	MOV	AL,CHR_LF		; LF コンパイルIDを消す
	STOSB				;
	REP	MOVSB			;
	MOV	AL,' '
	STOSB
	MOV	AL,'R'
	STOSB
	MOV	AL,'E'
	STOSB
	MOV	AL,'T'
	STOSB
	MOV	AL,' '
	STOSB
	MOV	AL,0
	STOSB

	RET
BBC_PROGCOPY	ENDP


; *********************************************************
;	syntax : STRCOPY("string",string)
;	文字列を文字列アドレスへコピーする
;	-i- "string" (SI) : セットする文字列
;	    string   (AX) : セットされる文字列アドレス
; *********************************************************

BBC_STRCOPY	PROC	NEAR
	MOVX	ES,DS			;
	MOV	DI,REG_SI		;
	CALL	c_STRLENGTH		; 文字列長さ

	MOV	SI,REG_SI		;
	MOVX	ES,DS			;
	MOV	DI,REG_AX		;
	REP	MOVSB			;
	MOV	BYTE PTR ES:[DI],0	;
	RET
BBC_STRCOPY	ENDP


; *********************************************************
;	syntax : STRLEN(string)
;	文字列長さ
;	-i- string (AX) : 文字列アドレス
;	-o- AX          : 文字長さ
; *********************************************************

BBC_STRLEN	PROC	NEAR
	MOV	DI,REG_AX		; 文字列アドレス
	MOVX	ES,DS			;
	CALL	c_STRLENSPZ		; 文字列長さスペースまで
	MOV	REG_AX,CX		; 表示単語長さ
	RET
BBC_STRLEN	ENDP


; *********************************************************
;	syntax : LOAD("file_name")
;	プログラムをロードする
;	-i- "file_name" (SI) : ファイル名
; *********************************************************

BBC_LOAD	PROC	NEAR
	MOV	SI,REG_SI		;
	CALLE	BBLOAD			; text load.
	CMP	AX,0			; 0=normal,1=error.
	JNE	BBC_LOAD_ERROR		;
	RET
BBC_LOAD_ERROR:
	BBERROR	101
	RET
BBC_LOAD	ENDP


; *********************************************************
;	syntax : CK_LVL(count,lv1,lv2,lv3,lvm)
;	レベルチェック
;	-i- count (AX) : 実行回数
;	    lv1   (BX) : 初級レベル選択値
;	    lv2   (CX) : 中級レベル選択値
;	    lv3   (DX) : 上級レベル選択値
;	    lvm   (SI) : ﾏｽﾀｰレベル選択値
;	-o- AX         : レベル
;		0=初級レベル,1=中級レベル
;		2=上級レベル,3=マスターレベル
;	    DX         : 選択値
; *********************************************************

BBC_CK_LVL	PROC	NEAR
	;初級レベル	１～５
	;中級		６～１０
	;上級		１１～１５
	;マスター	１６～

	CMP	REG_AX,5
	JBE	BBC_CK_LVL_LOW
	CMP	REG_AX,10
	JBE	BBC_CK_LVL_MID
	CMP	REG_AX,15
	JBE	BBC_CK_LVL_HI
	JMP	BBC_CK_LVL_MASTER
BBC_CK_LVL_LOW:
	MOV	AX,0			; レベル
	MOV	DX,REG_BX		; 選択値
	MOV	REG_AX,AX
	MOV	REG_DX,DX
	RET
BBC_CK_LVL_MID:
	MOV	AX,1			; レベル
	MOV	DX,REG_CX		; 選択値
	MOV	REG_AX,AX
	MOV	REG_DX,DX
	RET
BBC_CK_LVL_HI:
	MOV	AX,2			; レベル
	MOV	DX,REG_DX		; 選択値
	MOV	REG_AX,AX
	MOV	REG_DX,DX
	RET
BBC_CK_LVL_MASTER:
	MOV	AX,3			; レベル
	MOV	DX,REG_SI		; 選択値
	MOV	REG_AX,AX
	MOV	REG_DX,DX
	RET
BBC_CK_LVL	ENDP


; *********************************************************
;	syntax : CK_GUARA(count,base)
;	バイト料
;	-i- count (AX) : 実行回数 /-1=待遇1,-2=待遇2,-3=待遇3,-4=待遇4
;	    base  (BX) : 基本給
;	-o- AX         : 待遇アップ回数
;	    DX         : バイト料
; *********************************************************

BBC_CK_GUARA	PROC	NEAR
	;実行回数１０	20% up
	;　〃　　３０	44% up
	;　〃　　６０	73% up
	;　〃　　９０　	108% up
	;上記の回数で，それぞれ２０％アップ．（小数点以下切り上げ）

	CMP	REG_AX,-1
	JE	BBC_CK_GUARA_10CNT
	CMP	REG_AX,-2
	JE	BBC_CK_GUARA_30CNT
	CMP	REG_AX,-3
	JE	BBC_CK_GUARA_60CNT
	CMP	REG_AX,-4
	JE	BBC_CK_GUARA_90CNT

	CMP	REG_AX,10
	JB	BBC_CK_GUARA_BASE
	CMP	REG_AX,30
	JB	BBC_CK_GUARA_10CNT
	CMP	REG_AX,60
	JB	BBC_CK_GUARA_30CNT
	CMP	REG_AX,90
	JB	BBC_CK_GUARA_60CNT
	JMP	BBC_CK_GUARA_90CNT

BBC_CK_GUARA_BASE:
	MOVX	REG_DX,REG_BX			; バイト料
	MOV	REG_AX,0			; 待遇アップ回数
	JMP	BBC_CK_GUARA_EXIT

BBC_CK_GUARA_10CNT:
	MOV	AX,20				; 20% up
	MOV	CX,REG_BX			; 基本給
	CALL	CK_GUARA_PARSENT		; 待遇アップ
	MOV	REG_DX,AX			; バイト料

	MOV	REG_AX,1			; 待遇アップ回数
	JMP	BBC_CK_GUARA_EXIT		;

BBC_CK_GUARA_30CNT:
	MOV	AX,44				; 44% up
	MOV	CX,REG_BX			; 基本給
	CALL	CK_GUARA_PARSENT		; 待遇アップ
	CMP	AX,3				;
	JGE	BBC_CK_GUARA_3			;
	MOV	AX,3				;
BBC_CK_GUARA_3:					;
	MOV	REG_DX,AX			; バイト料

	MOV	REG_AX,2			; 待遇アップ回数
	JMP	BBC_CK_GUARA_EXIT		;

BBC_CK_GUARA_60CNT:
	MOV	AX,73				; 73% up
	MOV	CX,REG_BX			; 基本給
	CALL	CK_GUARA_PARSENT		; 待遇アップ
	CMP	AX,4				;
	JGE	BBC_CK_GUARA_4			;
	MOV	AX,4				;
BBC_CK_GUARA_4:					;
	MOV	REG_DX,AX			; バイト料

	MOV	REG_AX,3			; 待遇アップ回数
	JMP	BBC_CK_GUARA_EXIT		;

BBC_CK_GUARA_90CNT:
	MOV	AX,108				; 108% up
	MOV	CX,REG_BX			; 基本給
	CALL	CK_GUARA_PARSENT		; 待遇アップ
	CMP	AX,5				;
	JGE	BBC_CK_GUARA_5			;
	MOV	AX,5				;
BBC_CK_GUARA_5:					;
	MOV	REG_DX,AX			; バイト料

	MOV	REG_AX,4			; 待遇アップ回数
	JMP	BBC_CK_GUARA_EXIT

BBC_CK_GUARA_EXIT:
	RET
BBC_CK_GUARA	ENDP


; *********************************************************
;	待遇アップ
;	-I- AX : up%
;	    CX : 基本給
;	-O- AX : バイト料
; *********************************************************

CK_GUARA_PARSENT	PROC	NEAR
	MUL	CX				; 基本給
	MOV	BX,100				;
	DIV	BX				;
	CMP	DX,0				;
	JE	CK_GUARA_PARSENT_5		;
	INC	AX				; + 1
CK_GUARA_PARSENT_5:				;
	ADD	AX,CX				; 基本給
	RET
CK_GUARA_PARSENT	ENDP


;*;; *********************************************************
;*;;	syntax : CRTREWRITE
;*;;	画面の書き直し
;*;; *********************************************************
;*;
;*;BBC_CRTREWRITE	PROC	NEAR
;*;	CALLE	KS2LOOP_REWRITE		; main window rewrite.
;*;	RET
;*;BBC_CRTREWRITE	ENDP


; *********************************************************
;	syntax : TXTSZ(mode)
;	テキストバッファサイズの変更
;	-i- mode (AX) : 0=65500,1=32000,2=16000,3=8000,4=4000 ; text buffer size table.
; *********************************************************

BBC_TXTSZ	PROC	NEAR
	MOV	BX,REG_AX		;
	SHL	BX,1			; word pointer.
	MOV	AX,TEXTSIZTBL[BX]	; text buffer size table.
	MOV	TEXTPSIZ,AX		; text buffer size.
	RET
BBC_TXTSZ	ENDP


; *********************************************************
;	syntax : GOLDADD(value)
;	所持金へ加算
;	-I- value (AX) : add value.
; *********************************************************

BBC_GOLDADD	PROC	NEAR
	MOV	AX,REG_AX		;
	CALLE	c_PCALC_GOLDADD		; 所持金へ加算
	RET
BBC_GOLDADD	ENDP


; *********************************************************
;	syntax : GOLDSUB(value)
;	所持金から減算
;	-I- value (AX) : sub value.
; *********************************************************

BBC_GOLDSUB	PROC	NEAR
	MOV	AX,REG_AX		;
	CALLE	c_PCALC_GOLDSUB		; 所持金から減算
	RET
BBC_GOLDSUB	ENDP


; *********************************************************
;	syntax : GOLDSUB2(value)
;	所持金から減算2
;	-I- value (AX) : sub value.
; *********************************************************

BBC_GOLDSUB2	PROC	NEAR
	MOV	AX,REG_AX		;
	CALLE	c_PCALC_GOLDSUB2	; 所持金から減算2
	RET
BBC_GOLDSUB2	ENDP


; *********************************************************
;	syntax : GOLDCMP(value)
;	所持金と比較
;	-I- value (AX) : cmp value.
;	-O- AX   : 1=same,2=upper,3=under.
; *********************************************************

BBC_GOLDCMP	PROC	NEAR
	MOV	AX,REG_AX		;
	CALLE	c_PCALC_GOLDCMP		; 所持金と比較
	MOV	REG_AX,AX		; 3=under.
	RET
BBC_GOLDCMP	ENDP


; *********************************************************
;	syntax : EDTX(function)
;	テキスト編集
;	-i- function (AX) : 機能
;
;	EDTX(1)  : ﾃｷｽﾄ編集ﾊﾞｯﾌｧの初期化
;	EDTX(2)  : ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの取込開始
;	EDTX(3,string) : ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの文字列取込
;	EDTX(4,value)  : ﾃｷｽﾄ編集ﾊﾞｯﾌｧへのﾊﾟﾗﾒｰﾀ取込
;	EDTX(5)  : ﾃｷｽﾄ編集ﾊﾞｯﾌｧの行数ｶｳﾝﾀ
;		-o- DX : 行数
;	EDTX(6,value)  : ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの小数２桁取込
;	EDTX(7,value)  : ﾃｷｽﾄ編集ﾊﾞｯﾌｧへのﾊﾟﾗﾒｰﾀ取込(固定長)
;	EDTX(8,value)  : ﾃｷｽﾄ編集ﾊﾞｯﾌｧへのﾊﾟﾗﾒｰﾀ取込(可変長)
; *********************************************************

BBC_EDTX	PROC	NEAR
	MOV	AX,REG_AX
	CMP	AL,1
	JE	BBC_EDTX_01F
	CMP	AL,2
	JE	BBC_EDTX_02F
	CMP	AL,3
	JE	BBC_EDTX_03F
	CMP	AL,4
	JE	BBC_EDTX_04F
	CMP	AL,5
	JE	BBC_EDTX_05F
	CMP	AL,6
	JE	BBC_EDTX_06F
	CMP	AL,7
	JE	BBC_EDTX_07F
	CMP	AL,8
	JE	BBC_EDTX_08F
	RET
BBC_EDTX_01F:
	CALLE	BBTX2INI		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧの初期化
	RET
BBC_EDTX_02F:
	CALLE	BBTX2BUF		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの取込開始
	RET
BBC_EDTX_03F:
	MOV	SI,REG_BX		; string.
	CALLE	BBTX2STR		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの文字列取込
	RET
BBC_EDTX_04F:
	MOV	DX,REG_BX		; value.
	CALLE	BBTX2VAL		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへのﾊﾟﾗﾒｰﾀ取込
	RET
BBC_EDTX_05F:
	CALLE	BBTX2LNC		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧの行数ｶｳﾝﾀ
	MOV	REG_DX,DX		; string.
	RET
BBC_EDTX_06F:
	MOV	DX,REG_BX		; string.
	CALLE	BBTX2PNT		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの小数２桁取込
	RET
BBC_EDTX_07F:
	MOV	DX,REG_BX		; string.
	CALLE	BBTX2VFIX		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへのﾊﾟﾗﾒｰﾀ取込(固定長)
	RET
BBC_EDTX_08F:
	MOV	DX,REG_BX		; string.
	CALLE	BBTX2VSTR		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへのﾊﾟﾗﾒｰﾀ取込(可変長)
	RET
BBC_EDTX	ENDP


; *********************************************************
;	テキストロード時の初期処理
; *********************************************************

BBCTOOL_LOADINIT	PROC	NEAR
	MOV	STRINGSTACKPNT,0	; string stack pointer.
	RET
BBCTOOL_LOADINIT	ENDP


; *********************************************************
;	divide print.
;	-I- DX : para1
;	    CX : para2
; *********************************************************

DIV_PR	PROC	NEAR
	PUSH	CX			;
	CALL	c_DECSTR		;
	CALL	c_STRZTS		; zero to space. "00123" - > "  123"
	CALL	c_STRSPL		; space pless. "  123" - > "123  "
	CALL	TEXT_PR			; text print.
	MOV	AL,"/"
	CALL	TEXT_CHR		; text 1chr.
	POP	DX
	CALL	c_DECSTR		;
	CALL	c_STRZTS		; zero to space. "00123" - > "  123"
	CALL	c_STRSPL		; space pless. "  123" - > "123  "
	CALL	TEXT_PR			; text print.
	RET
DIV_PR	ENDP

; *********************************************************
;	text print.
;	-I- SI : 表示文字列
; *********************************************************

TEXT_PR	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	CALL	c_PRINT
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET
TEXT_PR	ENDP


; *********************************************************
;	text print.
;	-I- ES:SI : 表示文字列
;	    CX    : string length.
; *********************************************************

TEXT_PRES	PROC	NEAR
	CALL	c_PRINTES
	RET
TEXT_PRES	ENDP


; *********************************************************
;	text LF.
; *********************************************************

TEXT_LF	PROC	NEAR
	LF
	RET
TEXT_LF	ENDP


; *********************************************************
;	text CLS.
; *********************************************************

TEXT_CLS	PROC	NEAR
	CALL	c_CLS			; text clear.
	RET
TEXT_CLS	ENDP


; *********************************************************
;	text 1chr.
;	-I- AL : character.
; *********************************************************

TEXT_CHR	PROC	NEAR
	CALL	c_CHPUT
	RET
TEXT_CHR	ENDP

CODE	ENDS


; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	GOLD_GIRL:WORD		; 娘の所持金
EXTRN	GOLD_UPPER:WORD		; 所持金上限
EXTRN	GIRL_BODY:WORD		; 体形 1=細,2=太

EXTRN	SEGFREE:WORD		; フリー領域の先頭セグメント

EXTRN	WIDSNM:WORD		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／ユーザ選択番号
EXTRN	WIDSBANK:WORD		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／一時退避バッファ番号

EXTRN	ISLCT:WORD		; select number.

EXTRN	TCHR_SYM_SIZ:WORD	; user symbol area size.
EXTRN	TCHR_SYM_FSIZ:WORD	; user symbol free area size.

EXTRN	TCHR_ADR_MAX:WORD	; user symbol address max.
EXTRN	TCHR_ADR_FMAX:WORD	; user symbol free address max.

EXTRN	USER_FREE_WORD:WORD	; user area word size.
EXTRN	USER_FREE_FWORD:WORD	; user area free word size.

EXTRN	TEXTSIZTBL:WORD		; text buffer size table.

EXTRN	FLAG_LEFT_BOTTON_DISABLE:WORD ; ﾌﾗｸﾞ右ﾎﾞﾀﾝ無効(WIDSLCT.ASM)

EXTRN	WID1X:WORD		; ウインドウ発生位置左上座標Ｘ
EXTRN	WID1Y:WORD		; ウインドウ発生位置左上座標Ｙ
EXTRN	RPG_WID1X:WORD		; RPG用ｳｲﾝﾄﾞｳ発生位置左上座標Ｘ
EXTRN	RPG_WID1Y:WORD		; RPG用ｳｲﾝﾄﾞｳ発生位置左上座標Ｙ

DATA	ENDS

	END
;
;	end of "BBCTOOL.ASM"
;
