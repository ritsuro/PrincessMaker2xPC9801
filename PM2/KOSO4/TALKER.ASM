; "TALKER.ASM" PC-9801UV11 make by R.H 1991/11/15
;
;	台詞表示処理
;
;
;	TKTSTL			; 文字列表示スタイル設定
;	TKTSCT			; 文字列表示スクロールタイプ
;	TKTCLR			; 文字列表示クリア
;	TKTPRN			; 文字列表示
;	TKTANK			; ＡＮＫ表示
;	TKTKANJI		; 漢字表示
;	TKTLF			; 改行
;	TKTCOUNT		; 表示文字数
;	TKTWAIT			; ウエイトON/OFF
;	TKTWTIME		; ウエイト間隔
;
;
;	指定文字列を指定領域にスクロールさせながら
;	表示する。
;
; GAME subroutine.

INCLUDE	TSTSET.INC
INCLUDE	WINDOWS.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

EXTRN	VTXPRN:NEAR		; vram text print.
EXTRN	VTXPOR:NEAR		; vram text print OR.
EXTRN	VTXPFC:NEAR		; vram text print fuchi.
EXTRN	VTXSIZ:NEAR		; character size set.
EXTRN	VTXCOL:NEAR		; character color set.

EXTRN	SCRLUP:NEAR		; vram scroll UP.(x=even length)
EXTRN	MOVEVR:NEAR		; vram to vram move.

EXTRN	BOXPAL:NEAR		; ＢＯＸペイント

;*;EXTRN	TMVWAT:NEAR		; V-SYNC timer wait.

; ****************************************************
;	文字列表示スタイル設定
;	-I- SI : スタイルテーブル
;		SI+0	1	; now handle number.
;		SI+2	10	; now locate x.
;		SI+4	300	; now locate y.
;		SI+6	40	; max colum.
;		SI+8	3	; max line.
;		SI+10	1	; step x.
;		SI+12	1	; step 2byte x.
;		SI+14	18	; step y.
;		SI+16	10	; scroll base x.
;		SI+18	300	; scroll base y.
;		SI+20	40	; scroll size x.
;		SI+22	3*20	; scroll size y.
;		SI+24	18	; scroll length.
;		SI+26	0	; char size.0=16x16 1=32x32 2=16x24 3=16x32
;		SI+28	0	; character color 0-15
;		SI+30	0	; back color 0=brawn,1=black,2=cream.
; ****************************************************

FUNC_w	TKTSTL
	MOVX	NEW_HANDLE_NUMBER,DS:[SI]	; new handle number.
	CALL	CHG_HANDLE			; 文字列表示ハンドル変更

	MOVX	ES,DS				;
	MOV	DI,OFFSET STYLE_TABLE_TOP	; style table top.
	MOV	CX,STYLE_LENGTH			; style area length.
	SHR	CX,1				; word pointer.
	REP	MOVSW				;
	CALL	CHAR_STYLE_SET			; character style set.

	MOV	CHR_SHOW_CNT,0		; char show count.
	RET
FEND_w	TKTSTL


; ****************************************************
;	文字列表示ハンドル変更
;	-I- NEW_HANDLE_NUMBER : new handle number.
; ****************************************************

CHG_HANDLE	PROC	NEAR
	PUSH	SI

	; now handle save.

	MOVX	ES,DS				;
	MOV	BX,NOW_HANDLE_NUM		; now locate x.
	SHL	BX,1				; word pointer.
	MOV	DI,HANDLE_AREA_ADRS[BX]		; handle area address table.
	MOV	SI,OFFSET NOW_HANDLE_TOP	; now handle top.
	MOV	CX,HANDLE_LENGTH		; handle area length.
	SHR	CX,1				; word counter.
	REP	MOVSW				;

	; new handle load.

	MOVX	ES,DS				;
	MOV	BX,NEW_HANDLE_NUMBER		; new handle number.
	SHL	BX,1				; word pointer.
	MOV	SI,HANDLE_AREA_ADRS[BX]		; handle area address table.
	MOV	DI,OFFSET NOW_HANDLE_TOP	; now handle top.
	MOV	CX,HANDLE_LENGTH		; handle area length.
	SHR	CX,1				; word counter.
	REP	MOVSW				;

	MOVX	NOW_HANDLE_NUM,NEW_HANDLE_NUMBER ; new handle number.

	POP	SI
	RET
CHG_HANDLE	ENDP


; ****************************************************
;	文字列表示スクロールタイプ
;	-I- AX : scroll type 0=smoth,1=quick.
; ****************************************************

FUNC_w	TKTSCT
	MOV	SCROLL_TYPE,AX		; scroll type 0=smoth,1=quick.
	RET
FEND_w	TKTSCT


; ****************************************************
;	文字列表示クリア
; ****************************************************

FUNC_w	TKTCLR
	MOV	NOW_CLM,0		; now colum.
	MOV	NOW_LIN,0		; now line.
	CALL	TEXT_CLEAR		; text clear.

	MOV	CHR_SHOW_CNT,0		; char show count.
	RET
FEND_w	TKTCLR


; ****************************************************
;	文字列表示
;	-I- ES:[SI] : 表示文字列
; ****************************************************

FUNC_w	TKTPRN
	CALL	CHAR_STYLE_SET			; character style set.
TKTPRN_LOOP:
	MOV	AX,ES:[SI]		; 表示文字列
	XCHG	AH,AL			;
	CALL	TKTCHR			; １文字表示
	CMP	AX,0			; 0=end of string.
	JE	TKTPRN_EXIT		;
	ADD	SI,AX			; 1=1byte,2=2byte.
	JMP	TKTPRN_LOOP		;
TKTPRN_EXIT:
	RET
FEND_w	TKTPRN


; ****************************************************
;	ＡＮＫ表示
;	-I- AL : 表示文字列
; ****************************************************

FUNC_w	TKTANK
	CALL	CHAR_STYLE_SET		; character style set.

	MOV	CHR_STR,AL		; character string buffer.
	MOV	CHR_STR[1],0		;
	CALL	TK1CHR			; character put.
	RET
FEND_w	TKTANK


; ****************************************************
;	漢字表示
;	-I- AX : 表示文字列
; ****************************************************

FUNC_w	TKTKANJI
	CALL	CHAR_STYLE_SET			; character style set.

	MOV	CHR_STR,AH		; character string buffer.
	MOV	CHR_STR[1],AL		;
	CALL	TK2WDCHR		; 2byte character put.
	RET
FEND_w	TKTKANJI


; ****************************************************
;	改行
; ****************************************************

FUNC_w	TKTLF
	MOV	AX,NOW_LIN		; now line.
	CMP	AX,MAX_LIN		; max line.
	JB	TKTLF_LF		;

	MOV	AX,MAX_LIN		; max line.
	DEC	AX			; -1
	MOV	NOW_LIN,AX		; now line.

	CALL	TEXT_SCROLL		; text scroll.
	MOV	NOW_CLM,0		; now colum.
	JMP	TKTLF_EXIT		;
TKTLF_LF:
	MOV	NOW_CLM,0		; now colum.
	INC	NOW_LIN			; now line.
TKTLF_EXIT:
	RET
FEND_w	TKTLF


; ****************************************************
;	表示文字数
;	-O- AX : 表示文字数
; ****************************************************

FUNC_w	TKTCOUNT
	MOV	AX,CHR_SHOW_CNT		; char show count.
	RET
FEND_w	TKTCOUNT


; ****************************************************
;	ウエイトON/OFF
;	-I- AX : 1=on,0=off
; ****************************************************

FUNC_w	TKTWAIT
	MOV	FLAG_TIMER1,AX		; flag wait timer on.
	RET
FEND_w	TKTWAIT


; ****************************************************
;	ウエイト間隔
;	-I- AX : timer.
; ****************************************************

FUNC_w	TKTWTIME
	MOV	WAIT_TIMER1,AX		; wait timer value.
	RET
FEND_w	TKTWTIME


; ****************************************************
;	１文字表示
;	-I- AX : 表示文字
;	-O- AX : 0=end of string,1=1byte,2=2byte.
; ****************************************************

TKTCHR	PROC	NEAR
	CMP	AH,0			;
	JE	TKTCHR_EOS		;
	PUSH	ES
	PUSH	SI
	PUSH	DI

	MOV	CHR_STR,AH		; character string buffer.
	MOV	CHR_STR[1],AL		;

	MOV	DX,AX			; character code.
	XCHG	DH,DL			;
	CALL	BBSJISCHK		; シフトＪＩＳチェック
	CMP	AX,1			; 0=normal,1=shift jis code.
	JE	TKTCHR_2WDCHR		;

TKTCHR_1CHR:
	MOV	CHR_STR[1],0		;
	CALL	TK1CHR			; character put.
	MOV	AX,1			; 1=1byte.
	POP	DI
	POP	SI
	POP	ES
	RET
TKTCHR_2WDCHR:
	CALL	TK2WDCHR		; 2byte character put.
	MOV	AX,2			; 2=2byte.
	POP	DI
	POP	SI
	POP	ES
	RET
TKTCHR_EOS:
	MOV	AX,0			; 0=end of string.
	RET
TKTCHR	ENDP


; *********************************************************
;	シフトＪＩＳチェック
;	-I- DX : character code.
;	-O- AX : 0=normal,1=shift jis code.
; *********************************************************

BBSJISCHK	PROC	NEAR
	MOV	AX,0
	CMP	DL,081H
	JB	BBSJISCHK_3
	CMP	DL,09FH
	JNBE	BBSJISCHK_3
	MOV	AX,1		; shift jis code.
	RET
BBSJISCHK_3:
	CMP	DL,0E0H
	JB	BBSJISCHK_8
	CMP	DL,0FCH
	JNBE	BBSJISCHK_8
	MOV	AX,1		; shift jis code.
BBSJISCHK_8:
	RET
BBSJISCHK	ENDP


; ****************************************************
;	character put.
;	-I- CHR_STR : character string buffer.
; ****************************************************

TK1CHR	PROC	NEAR
	MOV	FLAG_KUTOHTEN,0		; flag kutohten.

	CMPX	NOW_LIN,MAX_LIN		; max line.
	JNB	TK1CHR_SCR		;

	MOV	AX,NOW_CLM		; now colum.
	CMP	AX,MAX_CLM		; max colum.
	JB	TK1CHR_2		;

	MOV	AX,NOW_LIN		; now line.
	INC	AX			; +1
	CMP	AX,MAX_LIN		; max line.
	JB	TK1CHR_1		;

TK1CHR_SCR:
	CALL	TEXT_SCROLL		; text scroll.
	MOV	AX,MAX_LIN		; max line.
	DEC	AX			; -1
	MOV	NOW_LIN,AX		; now line.
	MOV	NOW_CLM,0		; now colum.

	JMP	TK1CHR_2		;
TK1CHR_1:
	MOV	NOW_CLM,0		; now colum.
	INC	NOW_LIN			; now line.
TK1CHR_2:
	MOV	AX,NOW_CLM		; now colum.
	MOV	BX,STEP_X		; step x.
	MUL	BX			;
	ADD	AX,LOC_BASE_X		; now locate x.
	MOV	CHR_X,AX		; char x.

	MOV	AX,NOW_LIN		; now line.
	MOV	BX,STEP_Y		; step y.
	MUL	BX			;
	ADD	AX,LOC_BASE_Y		; now locate y.
	MOV	CHR_Y,AX		; char y.
	CALL	CHARPUT			; 1 character put.

	INC	CHR_SHOW_CNT		; char show count.

;*;	MOV	AX,WAIT_ANK		; ank char wait.
;*;	CALL	TMVWAT			; V-SYNC timer wait.

	ADDX	NOW_CLM,STEP_X		; step x.
	RET
TK1CHR	ENDP


; ****************************************************
;	2byte character put.
;	-I- CHR_STR : character string buffer.
; ****************************************************

TK2WDCHR	PROC	NEAR
	MOV	FLAG_KUTOHTEN,0		; flag kutohten.

	CMP	WORD PTR CHR_STR,4281H	; 8142h "。"
	JNE	TK2WDCHR_01		;
	MOV	WORD PTR CHR_STR,4481H	; 8144h "．"
	JMP	TK2WDCHR_09		;
TK2WDCHR_01:
	CMP	WORD PTR CHR_STR,4181H	; 8141h "、"
	JNE	TK2WDCHR_02		;
	MOV	WORD PTR CHR_STR,4381H	; 8143h "，"
	JMP	TK2WDCHR_09		;
TK2WDCHR_02:				;
TK2WDCHR_09:


	CMP	WORD PTR CHR_STR,4481H	; 8144h "．"
	JE	TK2WDCHR_0955		;
	CMP	WORD PTR CHR_STR,4381H	; 8143h "，"
	JE	TK2WDCHR_0955		;
	CMP	WORD PTR CHR_STR,7681H	; 8176h "」"
	JE	TK2WDCHR_0955		;
	CMP	WORD PTR CHR_STR,4881H	; 8148h "？"
	JE	TK2WDCHR_0955		;
	JMP	TK2WDCHR_0988		;
TK2WDCHR_0955:				;
	MOV	FLAG_KUTOHTEN,1		; flag kutohten.
TK2WDCHR_0988:				;

	CMPX	NOW_LIN,MAX_LIN		; max line.
	JNB	TK2WDCHR_SCR		;

	MOV	AX,NOW_CLM		; now colum.
	INC	AX			; +1
	CMP	AX,MAX_CLM		; max colum.
	JB	TK2WDCHR_2		;

	MOV	AX,NOW_CLM		; now colum.
	CMP	AX,MAX_CLM		; max colum.
	JNBE	TK2WDCHR_21		;

	CMP	WORD PTR CHR_STR,7681H	; 8176h "」"
	JNE	TK2WDCHR_2K		;
	SUB	NOW_CLM,1		; step 2byte x.
	JMP	TK2WDCHR_2		;
TK2WDCHR_2K:
	;、。，．

	CMP	WORD PTR CHR_STR,4481H	; 8144h "．"
	JE	TK2WDCHR_2		;
	CMP	WORD PTR CHR_STR,4381H	; 8143h "，"
	JE	TK2WDCHR_2		;

TK2WDCHR_21:
	MOV	AX,NOW_LIN		; now line.
	INC	AX			; +1
	CMP	AX,MAX_LIN		; max line.
	JB	TK2WDCHR_1		;

TK2WDCHR_SCR:
	CALL	TEXT_SCROLL		; text scroll.
	MOV	AX,MAX_LIN		; max line.
	DEC	AX			; -1
	MOV	NOW_LIN,AX		; now line.
	MOV	NOW_CLM,0		; now colum.

	JMP	TK2WDCHR_2		;
TK2WDCHR_1:
	MOV	NOW_CLM,0		; now colum.
	INC	NOW_LIN			; now line.
TK2WDCHR_2:
	MOV	AX,NOW_CLM		; now colum.
	MOV	BX,STEP_X		; step x.
	MUL	BX			;
	ADD	AX,LOC_BASE_X		; now locate x.
	MOV	CHR_X,AX		; char x.

	MOV	AX,NOW_LIN		; now line.
	MOV	BX,STEP_Y		; step y.
	MUL	BX			;
	ADD	AX,LOC_BASE_Y		; now locate y.
	MOV	CHR_Y,AX		; char y.
	CALL	CHARPUT			; 1 character put.

	ADD	CHR_SHOW_CNT,2		; char show count.

;*;	MOV	AX,WAIT_KANJI		; kanji char wait.
;*;	CALL	TMVWAT			; V-SYNC timer wait.

	ADDX	NOW_CLM,STEP_2BX	; step 2byte x.
	RET
TK2WDCHR	ENDP


; ****************************************************
;	text scroll.
;	-I- SCRL_BASE_X	: scroll base x.
;	    SCRL_BASE_Y	: scroll base y.
;	    SCRL_SIZE_X	: scroll size x.
;	    SCRL_SIZE_Y	: scroll size y.
;	    SCRL_LENG	: scroll length.
; ****************************************************

TEXT_SCROLL	PROC	NEAR
	CMP	SCROLL_TYPE,1		; scroll type 0=smoth,1=quick.
	JE	TEXT_SCROLL_QUICK	;

	MOVX	VX1,SCRL_BASE_X		; scroll base x.
	MOVX	VY1,SCRL_BASE_Y		; scroll base y.
	MOVX	VX2,SCRL_SIZE_X		; scroll size x.
	MOVX	VY2,SCRL_SIZE_Y		; scroll size y.
	MOVX	VY3,SCRL_LENG		; scroll length.
	MOV_ID2	SSDES0,ARAVRM		; visual data segment plean.
	CALL	SCRLUP			; vram scroll UP.(x=even length)
	RET
TEXT_SCROLL_QUICK:

	MOV	AX,SCRL_BASE_X		; scroll base x.
	MOV	BX,SCRL_BASE_Y		; scroll base y.
	MOV	VX3,AX			; source x.
	MOV	VY3,BX			; source y.
	ADD	BX,SCRL_LENG		; scroll length.
	MOV	VX1,AX			; dest x.
	MOV	VY1,BX			; dest y.
	MOV	AX,SCRL_SIZE_X		; scroll size x.
	MOV	BX,SCRL_SIZE_Y		; scroll size y.
	SUB	BX,SCRL_LENG		; scroll length.

	MOV	VX2,AX			; scroll size x.
	MOV	VY2,BX			; scroll size y.
	MOV_ID2	SSSOU0,ARAVRM		; visual data segment plean 0
	MOV_ID2	SSDES0,ARAVRM		; visual data segment plean.
	CALL	MOVEVR			; vram to vram move.

	MOV	AX,SCRL_BASE_X		; scroll base x.
	MOV	BX,SCRL_BASE_Y		; scroll base y.
	ADD	BX,SCRL_SIZE_Y		; scroll size y.
	SUB	BX,SCRL_LENG		; scroll length.
	MOV	WDX1,AX			; 表示位置Ｘ
	MOV	WDY1,BX			; 表示位置Ｙ
	MOVX	WDX2,SCRL_SIZE_X	; scroll size x.
	MOVX	WDY2,SCRL_LENG		; scroll length.
	MOV_ID2	SSEFC0,ARAVRM		; visual data segment plean 0

	CMP	BACK_COLOR,1		;16 back color 1=black.
	JE	TEXT_SCROLL_BL		;
	CMP	BACK_COLOR,2		;16 back color 2=cream.
	JE	TEXT_SCROLL_CRM		;

	CALLE	WID_FLAME_TEXT_BOX	; WINDOWS/フレーム・ﾃｷｽﾄｳｲﾝﾄﾞｳ BOX
	JMP	TEXT_SCROLL_82		;
TEXT_SCROLL_BL:
	MOV	CX,0			; 0=黒
	CALLE	WID_FLAME_TEXT_COL_BOX	; WINDOWS/フレーム・ﾃｷｽﾄｳｲﾝﾄﾞｳ color BOX
	JMP	TEXT_SCROLL_82		;
TEXT_SCROLL_CRM:
	MOV	CX,1			; 1=クリーム
	CALLE	WID_FLAME_TEXT_COL_BOX	; WINDOWS/フレーム・ﾃｷｽﾄｳｲﾝﾄﾞｳ color BOX
TEXT_SCROLL_82:
	RET
TEXT_SCROLL	ENDP


; ****************************************************
;	text clear.
; ****************************************************

TEXT_CLEAR	PROC	NEAR
	MOVX	WDX1,SCRL_BASE_X	; scroll base x.
	MOVX	WDY1,SCRL_BASE_Y	; scroll base y.
	MOVX	WDX2,SCRL_SIZE_X	; scroll size x.
	MOVX	WDY2,SCRL_SIZE_Y	; scroll size y.
	MOV_ID2	SSEFC0,ARAVRM		; visual data segment plean 0

	CMP	BACK_COLOR,1		;16 back color 0=brawn,1=black.
	JE	TEXT_CLEAR_BL		;
	CMP	BACK_COLOR,2		;16 back color 2=cream.
	JE	TEXT_CLEAR_CRM		;

	CALLE	WID_FLAME_TEXT_BOX	; WINDOWS/フレーム・ﾃｷｽﾄｳｲﾝﾄﾞｳ BOX
	JMP	TEXT_CLEAR_82		;
TEXT_CLEAR_BL:
	MOV	CX,0			; 0=黒
	CALLE	WID_FLAME_TEXT_COL_BOX	; WINDOWS/フレーム・ﾃｷｽﾄｳｲﾝﾄﾞｳ color BOX
	JMP	TEXT_CLEAR_82		;
TEXT_CLEAR_CRM:
	MOV	CX,1			; 1=クリーム
	CALLE	WID_FLAME_TEXT_COL_BOX	; WINDOWS/フレーム・ﾃｷｽﾄｳｲﾝﾄﾞｳ color BOX
TEXT_CLEAR_82:
	RET
TEXT_CLEAR	ENDP


; ****************************************************
;	character style set.
;	-I- CHR_SIZE : char size.
;			0=16x16  1=32x32  2=16x24  3=16x32
;	    CHR_COLOR: character color 0-15
; ****************************************************

CHAR_STYLE_SET	PROC	NEAR
	PUSH	ES
	PUSH	DI
	PUSH	SI
	PUSH	AX
	MOV	AX,CHR_SIZE		; char size.
	CALL	VTXSIZ			; character size set.
	MOV	AX,CHR_COLOR		; character color 0-15
	CALL	VTXCOL			; character color set.
	POP	AX
	POP	SI
	POP	DI
	POP	ES
	RET
CHAR_STYLE_SET	ENDP


; ****************************************************
;	1 character put.
;	-I- CHR_X   : char x.
;	    CHR_Y   : char y.
;	    CHR_STR : character string buffer.
; ****************************************************

CHARPUT	PROC	NEAR
	CMP	FLAG_TIMER1,0		; flag wait timer on.
	JE	CHARPUT_2		;

	CMP	TALKDEMO,55		; (TALKER.ASM)デモフラグ
	JE	CHARPUT_2		;
				; 0=通常,55=ランダムセレクト

	CALLE	WID_TEXT_CURRENT
	CMP	DX,4			; テキスト・タイプ
	JE	CHARPUT_2		;

	MOV	AX,WAIT_TIMER1		; wait timer value.
	CMP	AX,0			;
	JE	CHARPUT_1		;
	CMP	FLAG_KUTOHTEN,0		; flag kutohten.
	JE	CHARPUT_1		;
	SHL	AX,1			;
	SHL	AX,1			;
CHARPUT_1:				;
	CALLE	TMVSET			; V-SYNC timer set.
CHARPUT_2:

	MOV	AX,CHR_X		; char x.
	MOV	BX,CHR_Y		; char y.
	MOV	SI,OFFSET CHR_STR	; character string buffer.
	CALL	VTXPOR			; vram text print OR.
;*;	CALL	VTXPRN			; vram text print.

	CMP	FLAG_TIMER1,0		; flag wait timer on.
	JE	CHARPUT_7		;

	CMP	TALKDEMO,55		; (TALKER.ASM)デモフラグ
	JE	CHARPUT_7		;

	CALLE	TMVEWT			; V-SYNC timer end wait.
CHARPUT_7:
	RET
CHARPUT	ENDP

CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	TALKDEMO		; (TALKER.ASM)デモフラグ
				; 0=通常,55=ランダムセレクト

TALKDEMO	DW	0	; (TALKER.ASM)デモフラグ

NEW_HANDLE_NUMBER	DW	0	; new handle number.

STYLE_TABLE_TOP	LABEL	WORD		; style table top.
NOW_HANDLE_NUM	DW	1		;1 now handle number.
LOC_BASE_X	DW	10		;2 now locate x.
LOC_BASE_Y	DW	300		;3 now locate y.
MAX_CLM		DW	40		;4 max colum.
MAX_LIN		DW	3		;5 max line.
STEP_X		DW	1		;6 step x.
STEP_2BX	DW	2		;7 step 2byte x.
STEP_Y		DW	18		;8 step y.
SCRL_BASE_X	DW	10		;9 scroll base x.
SCRL_BASE_Y	DW	300		;10 scroll base y.
SCRL_SIZE_X	DW	40		;11 scroll size x.
SCRL_SIZE_Y	DW	3*20		;12 scroll size y.
SCRL_LENG	DW	18		;13 scroll length.
CHR_SIZE	DW	0		;14 char size.16x16,32x32,16x24,16x32
CHR_COLOR	DW	0		;15 character color 0-15
BACK_COLOR	DW	0		;16 back color 0=brawn,1=black,2=cream.
STYLE_TABLE_END	LABEL	WORD		; style table.

STYLE_LENGTH	DW	(STYLE_TABLE_END-STYLE_TABLE_TOP) ; style area length.

NOW_HANDLE_TOP	LABEL	BYTE		; now handle top.
SCROLL_TYPE	DW	1		; scroll type 0=smoth,1=quick.
NOW_CLM		DW	0		; now colum.
NOW_LIN		DW	0		; now line.
CHR_X		DW	0		; char x.
CHR_Y		DW	0		; char y.
CHR_SHOW_CNT	DW	0		; char show count.
CHR_STR		DB	0,0,0,0		; character string buffer.
NOW_HANDLE_END	LABEL	BYTE		; now handle end.

HANDLE_LENGTH	DW	(NOW_HANDLE_END-NOW_HANDLE_TOP) ; handle area length.

HANDLE_AREA_ADRS	LABEL	WORD	; handle area address table.
		DW	HANDLE01,HANDLE01,HANDLE02,HANDLE03,HANDLE04,HANDLE05
		DW	HANDLE06
HANDLE01	DB	1,(NOW_HANDLE_END-NOW_HANDLE_TOP) DUP (0)
HANDLE02	DB	1,(NOW_HANDLE_END-NOW_HANDLE_TOP) DUP (0)
HANDLE03	DB	1,(NOW_HANDLE_END-NOW_HANDLE_TOP) DUP (0)
HANDLE04	DB	1,(NOW_HANDLE_END-NOW_HANDLE_TOP) DUP (0)
HANDLE05	DB	1,(NOW_HANDLE_END-NOW_HANDLE_TOP) DUP (0)
HANDLE06	DB	1,(NOW_HANDLE_END-NOW_HANDLE_TOP) DUP (0)

FLAG_TIMER1	DW	0		; flag wait timer on.
WAIT_TIMER1	DW	0		; wait timer value.

FLAG_KUTOHTEN	DW	0		; flag kutohten.

;*;WAIT_KANJI	DW	3		; kanji char wait.
;*;WAIT_ANK	DW	2		; ank char wait.

DATA	ENDS

	END
;
;	end of "TALKER.ASM"
;
