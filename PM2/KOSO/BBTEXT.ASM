; "BBTEXT.ASM" PC-9801UV11 make by R.H 1991/10/16
;
;
;	princess  B A S I C    text handle.
;
;
;
;
;	テキスト編集バッファ
;
;	BBTX2INIでﾃｷｽﾄ編集ﾊﾞｯﾌｧの初期化をして
;	BBTX2BUFでﾃｷｽﾄ編集ﾊﾞｯﾌｧへの取込開始
;	BBTX2LNCでﾃｷｽﾄ編集ﾊﾞｯﾌｧの行数がわかる
;
;	シナリオ本編では"@G"で取り込み開始"@@"で取り込み終了となっている
;	また"@R"で娘の名前を"@F"で娘の名字を書き込む
;
;	必要に応じて BBTX2STR(ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの文字列取込)
;	BBTX2VAL(ﾃｷｽﾄ編集ﾊﾞｯﾌｧへのﾊﾟﾗﾒｰﾀ取込)
;	BBTX2PNT(ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの小数２桁取込)
;	でパラメータなどを書き込む
;
;
; public routine.

INCLUDE	TSTSETC.INC
INCLUDE	BBEXTRN.INC

PATH_STRING_LEN	EQU	32	; path string length.
TAG_PRINT	EQU	22H	; print string."""
TAG_BINSPACE	EQU	0BH	; binary space.

EOS		EQU	0	; end of string.
CHR_DELIM	EQU	','	; 単語の区切り

CODE01	SEGMENT	PUBLIC	'CODE01'

EXTRN	DISKLD_FAR:FAR		; disk load.(far)
EXTRN	BBCTOOL3_LOADINIT:FAR	; テキストロード時の初期処理(far)

CODE01	ENDS

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:DATA

PUBLIC	BBLOAD			; text load.
PUBLIC	BBMES_KANJI		; text message kanji.
PUBLIC	BBMES_ALPHA		; text message alphabet.
PUBLIC	BBTX2INI		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧの初期化
PUBLIC	BBTX2BUF		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの取込開始
PUBLIC	BBTX2STR		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの文字列取込
PUBLIC	BBTX2VAL		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへのﾊﾟﾗﾒｰﾀ取込
PUBLIC	BBTX2PNT		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの小数２桁取込
PUBLIC	BBTX2VFIX		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへのﾊﾟﾗﾒｰﾀ取込(固定長)
PUBLIC	BBTX2VSTR		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへのﾊﾟﾗﾒｰﾀ取込(可変長)
;*;PUBLIC BBTX2V5F		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへのﾊﾟﾗﾒｰﾀ取込(5桁)
PUBLIC	BBTX2LNC		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧの行数ｶｳﾝﾀ

EXTRN	BBUNLOCK:NEAR		; テキストデータ復元
EXTRN	BBDEFCLEAR:NEAR		; define clear.
EXTRN	BBLKSKP:NEAR		; ブランクスキップ
EXTRN	BBSJISCHK:NEAR		; シフトＪＩＳチェック
EXTRN	BBNOWNEST:NEAR		; 現在行のネストレベル
EXTRN	BBJPGET:NEAR		; jump label get.
EXTRN	BBCOMPNEST:NEAR		; nest check.

EXTRN	BBDEBUGTXFILE:NEAR	; text filename dump.

EXTRN	TEXTSTACKCLR:NEAR	; text stack clear.

EXTRN	BBCTOOL_LOADINIT:NEAR	; テキストロード時の初期処理


; *********************************************************
;	text load.
;	-I- SI      : file name.
;	-O- AX      : 0=normal,1=error.
; *********************************************************

BBLOAD	PROC	NEAR
	CALL	SLCKANI			; 簡易指定の取り出し

	CMP	NAMEMAX,2		; 単語の数
	JE	BBLOAD_2FL		;

	MOV	SI,NAMETBL[0]		; 単語アドレス
	MOV	AX,1			; mode 1=1file load
	CALL	BBLD02N			; text 2 load.
	RET
BBLOAD_2FL:
	MOV	SI,NAMETBL[0]		; 単語アドレス
	MOV	BX,NAMETBL[2]		; 単語アドレス
	MOV	AX,2			; mode 2=2file load.
	CALL	BBLD02N			; text 2 load.
	RET
BBLOAD	ENDP


; *********************************************************
;	text 2 load.
;	-I- SI : file name1.
;	    BX : file name2.
;	    AX : mode 1=1file load, 2=2file load.
;	-O- AX : 0=normal,1=error.
; *********************************************************

BBLD02N	PROC	NEAR
	MOV	FLNAME1,SI		; ファイル名１
	MOV	FLNAME2,BX		; ファイル名２
	MOV	TEXTLOADMODE,AX		; text load mode.

	MOV	SI,FLNAME1		; ファイル名１
	CALL	TXT_FLNSET		; テキストファイル名セット
	CALL	BBDEBUGTXFILE		; text filename dump.

	; text 1 load.

	MOV	DX,SEGPLS		; pless/unpless segment.
	MOV	DI,OFSPLS		; pless/unpless offset.
	MOV	CX,TEXTPSIZ		; text buffer size.
	CALL	DISKLD_FAR		; disk load.(far)
	CMP	AX,0			; 0=normal,1=error.
	JMPNE	BBLD02N_ERROR		;

	; text 1 unlock.
	MOV	BX,CX			; data length.(元データ)
	MOV	DX,SEGPLS		; 元データ
	MOV	SI,OFSPLS		;
	MOV	ES,TEXTPSEG		; 復元データ
	MOV	DI,TEXTPSTARTOFS	;
	MOV	CX,TEXTPSIZ		; text buffer size.
	CALL	BBUNLOCK		; テキストデータ復元

	; text header set.

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPTAG		; text tag offset.
	MOV	AL,CHR_LF		; LF
	STOSB				;
	STOSB				;
	STOSB				;
	STOSB				;

	; file name set.

	MOVX	ES,DS			;
	MOV	SI,OFFSET FLTXTNAM	; テキストファイル名セット
	MOV	DI,FLTEXTNOW		; now text file name.
	MOV	CX,FLTEXTNOWLEN		; now text file name length.
	CALLE	c_STRSETZ		; 文字列バッファセット

	; text length.

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPSTARTOFS	; text start offset.
	CALL	TEXTLENGTH		; テキスト長さ
	MOV	TEXTPLEN,CX		; text length.

	; text 2 load.

	CMP	TEXTLOADMODE,2		;  2=2file load.
	JNE	BBLD02N_ANALIZE		;

	MOV	SI,FLNAME2		; ファイル名２
	CALL	TXT_FLNSET		; テキストファイル名セット
	CALL	BBDEBUGTXFILE		; text filename dump.

	MOV	DX,SEGPLS		; pless/unpless segment.
	MOV	DI,OFSPLS		; pless/unpless offset.
	MOV	CX,TEXTPSIZ		; text buffer size.
	CALL	DISKLD_FAR		; disk load.(far)
	CMP	AX,0			; 0=normal,1=error.
	JMPNE	BBLD02N_ERROR		;

	; text 2 unlock.

	MOV	BX,CX			; data length.(元データ)
	MOV	DX,SEGPLS		; 元データ
	MOV	SI,OFSPLS		;
	MOV	ES,TEXTPSEG		; 復元データ
	MOV	DI,TEXTPSTARTOFS	; start.
	ADD	DI,TEXTPLEN		; + text length.
	MOV	CX,TEXTPSIZ		; text buffer size.
	SUB	CX,TEXTPLEN		; - text length.
	CALL	BBUNLOCK		; テキストデータ復元

	MOV	ES,TEXTPSEG		; 復元データ
	MOV	DI,TEXTPSTARTOFS	; start.
	ADD	DI,TEXTPLEN		; + text length.
	SUB	DI,2

	; text length.

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPSTARTOFS	; text start offset.
	CALL	TEXTLENGTH		; テキスト長さ
	MOV	TEXTPLEN,CX		; text length.

BBLD02N_ANALIZE:

	MOVX	TEXTPOFS,TEXTPSTARTOFS	; text start offset.
	CALL	BBNOWNEST		; 現在行のネストレベル
	CALL	BBJPGET			; jump label get.
	CALL	BBCOMPNEST		; nest check.

	CALL	BBDEFCLEAR		; define clear.
	CALL	TEXTSTACKCLR		; text stack push.

	CALL	BBCTOOL_LOADINIT	; テキストロード時の初期処理
	CALL	BBCTOOL3_LOADINIT	; テキストロード時の初期処理(far)

	MOVX	TEXTPOFS,TEXTPSTARTOFS	; text start offset.

BBLD02N_EXIT:
	MOV	AX,0			; 0=normal.
	RET
BBLD02N_ERROR:
	MOV	AX,1			; 1=error.
	RET
BBLD02N	ENDP


; ****************************************************
;	text message box.
;	-I/O- TEXTPSEG : text segment pointer.
;	      TEXTPOFS : text offset.
;	-O-   AX       : 0=message char,1=message none.
; ****************************************************

BBMES_KANJI	PROC	NEAR
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset.
	MOV	DX,ES:[DI]		; character code.
	CALL	BBSJISCHK		; シフトＪＩＳチェック
	CMP	AX,0			; 0=normal,1=shift jis code.
	JE	BBMESBOX_NONE		;

BBMESBOX_LOOP:
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset.
	MOV	DX,ES:[DI]		; character code.
	CALL	BBSJISCHK		; シフトＪＩＳチェック
	CMP	AX,0			; 0=normal,1=shift jis code.
	JE	BBMESBOX_TEXTLF		;

	MOV	AX,DX			;
	XCHG	AH,AL			;
	CALLE	c_WID_TEXT_KNJ		; WINDOWS/テキストウインドウ漢字表示

;*;	MOV	AX,MESSAGE_WAIT		; message wait.
;*;	CALL	c_TMVWAT		; V-SYNC timer wait.

	ADD	TEXTPOFS,2		; text offset.
	JMP	BBMESBOX_LOOP		;

BBMESBOX_TEXTLF:			;
	CALL	BBLKSKP			; ブランクスキップ
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset.
	MOV	AL,ES:[DI]		; character code.
	CMP	AL,TAG_BINSPACE		; binary space.
	JE	BBMESBOX_LFONLY		;
	CMP	AL,CHR_CR		; CR
	JNE	BBMESBOX_EXIT		;
BBMESBOX_LF:				;
	CALLE	c_WID_TEXT_LF		; WINDOWS/テキストウインドウ改行
	ADD	TEXTPOFS,2		; text offset.
	JMP	BBMESBOX_EXIT		;
BBMESBOX_LFONLY:			;
	CALLE	c_WID_TEXT_LF		; WINDOWS/テキストウインドウ改行
BBMESBOX_EXIT:
;*;	MOV	AX,0			; ＯＦＦ
;*;	CALLC	KUCHI			; 口ぱくモードの設定

	MOV	AX,0			; 0=message char.
	RET
BBMESBOX_NONE:
	MOV	AX,1			; 1=message none.
	RET
BBMES_KANJI	ENDP


; ****************************************************
;	text message alphabet.
;	-I/O- TEXTPSEG : text segment pointer.
;	      TEXTPOFS : text offset.
; ****************************************************

BBMES_ALPHA	PROC	NEAR
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset.
	MOV	AL,ES:[DI]		; 表示文字列
	CMP	AL,TAG_PRINT		; print string."""
	JNE	BBMES_ALPHA_EXIT	;

	INC	TEXTPOFS		; text offset.
BBMES_ALPHA_LOOP:			;
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset.
	MOV	AL,ES:[DI]		; 表示文字列
	CMP	AL,CHR_SPACE		; space.
	JB	BBMES_ALPHA_LF		;

	INC	TEXTPOFS		; text offset.

	CMP	AL,TAG_PRINT		; print string."""
	JE	BBMES_ALPHA_LF		;

	CALLE	c_WID_TEXT_ANK		; WINDOWS/テキストウインドウＡＮＫ表示
	JMP	BBMES_ALPHA_LOOP	;

BBMES_ALPHA_LF:
	CALLE	c_WID_TEXT_LF		; WINDOWS/テキストウインドウ改行
BBMES_ALPHA_EXIT:
	RET
BBMES_ALPHA	ENDP


; ****************************************************
;	ﾃｷｽﾄ編集ﾊﾞｯﾌｧの初期化
; ****************************************************

BBTX2INI	PROC	NEAR
	MOV	DI,VISUALTXTSTARTOFS		; visual text buffer offset.
	MOV	VISUALTXTOFS,DI			; visual text buffer offset.
	MOV	ES,VISUALTXTSEG			; visual text buffer segment.
	MOV	WORD PTR ES:[DI],0		;
	RET
BBTX2INI	ENDP


; ****************************************************
;	ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの取込開始
; ****************************************************

BBTX2BUF	PROC	NEAR
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset.
	MOV	AL,ES:[DI]		; character code.
	CMP	AL,CHR_CR		;
	JNE	BBTX2BUF_LOOP		; CR/LF ?
	ADD	TEXTPOFS,2		; text offset.
BBTX2BUF_LOOP:
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset.
	MOV	DX,ES:[DI]		; character code.

	CALL	BBSJISCHK		; シフトＪＩＳチェック
	CMP	AX,1			; 0=normal,1=shift jis code.
	JE	BBTX2BUF_KANJI		;

	CMP	DL,CHR_CR		; CR
	JE	BBTX2BUF_LF		;

	CMP	DX,4040H		;"@@"
	JE	BBTX2BUF_END		;

	CMP	DL,"@"			;
	JE	BBTX2BUF_NAME		;

	CMP	DL,0			;
	JE	BBTX2BUF_EXIT		;

	CMP	DL,CHR_TAB		; tab.
	JE	BBTX2BUF_TAB		;

BBTX2BUF_ANK:
	MOV	ES,VISUALTXTSEG		; visual text buffer segment.
	MOV	DI,VISUALTXTOFS		; visual text buffer offset.
	MOV	ES:[DI],DL		;

	ADD	TEXTPOFS,1		; text offset.
	ADD	VISUALTXTOFS,1		; visual text buffer offset.

	JMP	BBTX2BUF_NEXT

BBTX2BUF_KANJI:
	MOV	ES,VISUALTXTSEG		; visual text buffer segment.
	MOV	DI,VISUALTXTOFS		; visual text buffer offset.
	MOV	ES:[DI],DX		;

	ADD	TEXTPOFS,2		; text offset.
	ADD	VISUALTXTOFS,2		; visual text buffer offset.

	JMP	BBTX2BUF_NEXT

BBTX2BUF_LF:
	CMP	DH,CHR_LF		; LF
	JNE	BBTX2BUF_EXIT		;

	MOV	ES,VISUALTXTSEG		; visual text buffer segment.
	MOV	DI,VISUALTXTOFS		; visual text buffer offset.
	MOV	ES:[DI],DX		;

	ADD	TEXTPOFS,2		; text offset.
	ADD	VISUALTXTOFS,2		; visual text buffer offset.

	JMP	BBTX2BUF_NEXT

BBTX2BUF_NAME:
	ADD	TEXTPOFS,2		; text offset.
	CALL	NAME_PUTS		; 名前PUT
	JMP	BBTX2BUF_NEXT

BBTX2BUF_TAB:
	INC	TEXTPOFS		; text offset.
	JMP	BBTX2BUF_NEXT

BBTX2BUF_NEXT:
	JMP	BBTX2BUF_LOOP
BBTX2BUF_END:
	MOV	ES,VISUALTXTSEG		; visual text buffer segment.
	MOV	DI,VISUALTXTOFS		; visual text buffer offset.
	MOV	WORD PTR ES:[DI],0	;
	ADD	TEXTPOFS,2		; text offset.
BBTX2BUF_EXIT:
	RET
BBTX2BUF	ENDP


; ****************************************************
;	名前PUT
;	-I- DH : command. "R":girl name,"F":father name.
; ****************************************************

NAME_PUTS	PROC	NEAR
	CMP	DH,"R"			; "G":girl name.
	JE	NAME_PUTS_GIRL		;
	CMP	DH,"F"			; "F":father name.
	JE	NAME_PUTS_FAMILY	;
	RET
NAME_PUTS_GIRL:
	MOV	SI,NAME_FIRST		; 名前
	CALL	BBTX2STR		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの文字列取込
	RET
NAME_PUTS_FAMILY:
	MOV	SI,NAME_FAMILY		; 名前(family)
	CALL	BBTX2STR		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの文字列取込
	RET
NAME_PUTS	ENDP


; ****************************************************
;	ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの文字列取込
;	-I- DS:SI : string.
; ****************************************************

BBTX2STR	PROC	NEAR
	MOV	ES,VISUALTXTSEG		; visual text buffer segment.
	MOV	DI,VISUALTXTOFS		; visual text buffer offset.
BBTX2STR_LOOP:				;
	LODSB				;
	CMP	AL,0			;
	JE	BBTX2STR_EXIT		;
	STOSB				;
	JMP	BBTX2STR_LOOP		;
BBTX2STR_EXIT:
	MOV	WORD PTR ES:[DI],0	;
	MOV	VISUALTXTOFS,DI		; visual text buffer offset.
	RET
BBTX2STR	ENDP


; ****************************************************
;	ﾃｷｽﾄ編集ﾊﾞｯﾌｧへのﾊﾟﾗﾒｰﾀ取込
;	-I- DX : value.
; ****************************************************

BBTX2VAL	PROC	NEAR
	CALLE	c_UNIT_S_POINT		; ポイント文字列
	MOV	SI,OFFSET STR_BUFF	; 文字列
	CALL	BBTX2STR		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの文字列取込
	RET
BBTX2VAL	ENDP


; ****************************************************
;	ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの小数２桁取込
;	-I- DX : value.
; ****************************************************

BBTX2PNT	PROC	NEAR
	CALLE	c_UNIT_S_S2KETA		; 小数２桁文字列
	MOV	SI,OFFSET STR_BUFF	; 文字列
	CALL	BBTX2STR		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの文字列取込
	RET
BBTX2PNT	ENDP


; ****************************************************
;	ﾃｷｽﾄ編集ﾊﾞｯﾌｧへのﾊﾟﾗﾒｰﾀ取込(固定長)
;	-I- DX : value.
; ****************************************************

BBTX2VFIX	PROC	NEAR
	PUSH	DX
	CALLE	c_DECSTR		; val DX to dec string.
	CALLE	c_STRZTS		; zero to space. "00123" - > "  123"
	POP	DX

	INC	SI

;*;	CMP	DX,1000
;*;	JNB	BBTX2VFIX_5
;*;	INC	SI
;*;BBTX2VFIX_5:
;*;	INC	SI
;*;
;*;	CMP	DX,10
;*;	JNB	BBTX2VFIX_6
;*;	INC	SI			;
;*;	INC	SI			;
;*;	MOV	DI,OFFSET STR_BUFF	; 文字列バッファ
;*;	CALLE	c_WORDTL_N_HNZN		; 文字列半角を全角
;*;	MOV	SI,OFFSET STR_BUFF	; 文字列バッファ
;*;BBTX2VFIX_6:

	CALL	BBTX2STR		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの文字列取込
	RET
BBTX2VFIX	ENDP


; ****************************************************
;	ﾃｷｽﾄ編集ﾊﾞｯﾌｧへのﾊﾟﾗﾒｰﾀ取込
;	-I- DX : value.
; ****************************************************

BBTX2VSTR	PROC	NEAR
	PUSH	DX
;;;	CALLE	c_DECSTR		; val DX to dec string.

	CALLE	c_SIGSTR		; signed val DX to dec string.
	CALLE	c_STRZTS		; zero to space. "00123" - > "  123"
	CALLE	c_STRSPL		; space pless. "  123" - > "123  "
	POP	DX
	CMP	DX,10
	JNB	BBTX2VSTR_SET

	MOV	DI,OFFSET STR_BUFF	; 文字列バッファ
	CALLE	c_WORDTL_N_HNZN		; 文字列半角を全角
	MOV	SI,OFFSET STR_BUFF	; 文字列バッファ
BBTX2VSTR_SET:
	CALL	BBTX2STR		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの文字列取込
	RET
BBTX2VSTR	ENDP


;*;; ****************************************************
;*;;	ﾃｷｽﾄ編集ﾊﾞｯﾌｧへのﾊﾟﾗﾒｰﾀ取込(5桁)
;*;;	-I- DX : value.
;*;; ****************************************************
;*;
;*;BBTX2V5F	PROC	NEAR
;*;	RET
;*;BBTX2V5F	ENDP


; ****************************************************
;	ﾃｷｽﾄ編集ﾊﾞｯﾌｧの行数ｶｳﾝﾀ
;	-O- DX : 行数
; ****************************************************

BBTX2LNC	PROC	NEAR
	PUSH	DS
	MOV	DX,VISUALTXTSEG		; visual text buffer segment.
	MOV	SI,VISUALTXTSTARTOFS	; visual text buffer offset.

	MOV	DS,DX			;
	MOV	DX,0			; 行数ｶｳﾝﾀ
	MOV	CX,0			; char counter.
BBTX2LNC_LOOP:
	LODSB
	CMP	AL,0
	JE	BBTX2LNC_LOOP_E
	INC	CX			; char counter.
	CMP	AL,CHR_CR
	JNE	BBTX2LNC_LOOP
	INC	DX			; 行数ｶｳﾝﾀ
	MOV	CX,0			; char counter.
	INC	SI			;
	JMP	BBTX2LNC_LOOP

BBTX2LNC_LOOP_E:
	CMP	CX,0			; char counter.
	JE	BBTX2LNC_EXIT		;
	INC	DX			; 行数ｶｳﾝﾀ
BBTX2LNC_EXIT:
	POP	DS
	RET
BBTX2LNC	ENDP


; ****************************************************
;	テキスト長さ
;	-I- ES:DI : 文字列アドレス
;	-O- CX    : 表示単語長さ
; ****************************************************

TEXTLENGTH	PROC	NEAR
	MOV	BX,DI
	MOV	CX,TEXTPSIZ		; text buffer size.
	MOV	AL,1AH			; test end.
	REPNE	SCASB
	SUB	DI,BX
	DEC	DI

	MOV	CX,DI
	RET
TEXTLENGTH	ENDP


; ****************************************************
;	テキストファイル名セット
;	-I- DS:SI    : ファイル名
;	-O- SI       : テキストファイル名セット
;	    FLTXTNAM : テキストファイル名セット
; ****************************************************

TXT_FLNSET	PROC	NEAR
	MOV	AX,DS
	MOV	ES,AX

	MOV	DI,OFFSET FLTXTNAM	; ファイル名クリア
	MOV	CX,PATH_STRING_LEN	; path string length.
	MOV	AL,' '
	REP	STOSB

	MOV	DX,0			; dot flag.
	MOV	DI,OFFSET FLTXTNAM	; ファイル名
	MOV	CX,PATH_STRING_LEN	; path string length.
TXT_FLNSET2:
	LODSB
	CMP	AL,' '			; end of string.
	JB	TXT_FLNSET3		;
	CMP	AL,CHR_DELIM		; 単語の区切り
	JE	TXT_FLNSET3		;
	CMP	AL,'.'			; dot.
	JNE	TXT_FLNSET25		;
	MOV	DX,1			; dot flag.
TXT_FLNSET25:
	STOSB
	LOOP	TXT_FLNSET2
TXT_FLNSET3:
	CMP	DX,1			; dot flag.
	JE	TXT_FLNSET_7		;

	MOV	AL,'.'			; add ".TXT"
	STOSB
	MOV	AL,'T'
	STOSB
	MOV	AL,'X'
	STOSB
	MOV	AL,'T'
	STOSB
TXT_FLNSET_7:
	MOV	AL,0
	STOSB

	MOV	SI,OFFSET FLTXTNAM	; テキストファイル名セット
	RET
TXT_FLNSET	ENDP


; *********************************************************
;	簡易指定の取り出し
;	-I- DS:[SI]  : 指定文字列
;	-O- NAMEMAX  : 単語の数
;	    NAMETBL[]: 単語アドレス
;
;	DB	"mainloop,running",0
; *********************************************************

SLCKANI	PROC	NEAR
	MOV	NAMEMAX,0		; 単語の数

	MOV	DI,0			; word pointer.
	MOV	CX,NAMEDIM		; 単語のテーブルサイズ
SLCKANI_LOOP:
	MOV	DS:NAMETBL[DI],SI	; 単語アドレス
	INC	DI			;
	INC	DI			; word pointer.
	INC	NAMEMAX			; 単語の数

	MOV	DX,160			;
SLCKANI_LOOP_2:				;
	LODSB				;
	CMP	AL,CHR_DELIM		; 単語の区切り
	JE	SLCKANI_NEXT		;
	CMP	AL,EOS			; end of string.
	JE	SLCKANI_LOOP_END	;
	DEC	DX			;
	JNZ	SLCKANI_LOOP_2		;
	JMP	SLCKANI_LOOP_END	;
SLCKANI_NEXT:				;
	LOOP	SLCKANI_LOOP		;
SLCKANI_LOOP_END:
	RET
SLCKANI	ENDP

CODE	ENDS


; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	VISUALTXTSEG:WORD		; visual text buffer segment.
EXTRN	VISUALTXTOFS:WORD		; visual text buffer offset.
EXTRN	VISUALTXTSTARTOFS:WORD		; visual text buffer start offset.
EXTRN	VISUALTXTSIZ:WORD		; visual text buffer size.

EXTRN	SEGPLS:WORD				; pless/unpless segment.
EXTRN	OFSPLS:WORD				; pless/unpless offset.

EXTRN	NAME_FIRST:WORD				; 名前
EXTRN	NAME_FAMILY:WORD			; 名前(family)

FLAG_MSG_IO	DW	0			; メッセージＩ／Ｏフラグ

FLNAME1		DW	0			; ファイル名１
FLNAME2		DW	0			; ファイル名２
TEXTLOADMODE	DW	0			; text load mode.

NAMEDIM		DW	2			; 単語のテーブルサイズ
NAMEMAX		DW	0			; 単語の数
NAMETBL		DW	2 DUP (0)		; 単語アドレス

FLTXTNAM	DB PATH_STRING_LEN DUP (0),0,0	; ファイル名

DATA	ENDS

	END
;
;	end of "BBTEXT.ASM"
;
