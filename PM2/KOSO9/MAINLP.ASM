; "MAINLP.ASM" 486/50 make by R.H 1993/02/01
;
;
;	メインループ
;
;
; public subroutine.

INCLUDE	TSTSET.INC

;;GIRL_SRT_YEAR	EQU	1662		; 表示開始・年
GIRL_SRT_YEAR	EQU	1200		; 表示開始・年
GIRL_SRT_MONTH	EQU	1		; 表示開始・月

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	MAINLP			; main loop.
PUBLIC	PT_BORTH_WEEK		; borth week.

; ****************************************************
;	main loop.
; ****************************************************

MAINLP	PROC	NEAR
	MOV	GIRL_AGE,10		;(+06) 父の年齢

	CALLE	PT_VRAM_ID_ALL_ASSIGN	;vram ID all asigned.

	CALL	WID_FRM_LOAD		; window frame load.

	CALLE	BLACK			;ブラックアウト

	CALL	WID_SMALL		; window small.
	MOV	AX,0			; 0=最初
	JMP	MAINLP_NAME_IN		;


MAINLP_RETRY:
	CALL	WID_SMALL		; window small.
	MOV	AX,1			; 1=キャンセルで戻ってきた
MAINLP_NAME_IN:				;
	CALLE	WIDNAME_SET		; WINDOWS/名前ウインドウ全表示
	CMP	AX,1			; 0=通常,1=スキップ
	JE	MAINLP_SKIP		;
	JMP	MAINLP_BORTH_IN_GIRL	;


MAINLP_BORTH_IN_GIRL_RETRY:
	MOV	AX,1			; 1=父->娘,2=娘->父
	CALLE	WIDNAME_COLOR_OL	; WINDOWS/名前ウインドウ・カラーＯＬ
MAINLP_BORTH_IN_GIRL:			;
	CALL	WID_LAUGE		; window lauge.

	MOV	START_YEAR,GIRL_SRT_YEAR	; 表示開始・年
	MOV	START_MONTH,GIRL_SRT_MONTH	; 表示開始・月
	MOV	AX,2				; 2=娘
	CALLE	WIDBORTH_SET			; WINDOWS/誕生日ウインドウ
	CMP	AX,2				; 2=キャンセル
	JE	MAINLP_RETRY			;

	MOVX	GIRL_BORTH_YEAR,SET_YEAR	; 娘の誕生年
	MOVX	GIRL_BORTH_MONTH,SET_MONTH	; girl borth month
	MOVX	GIRL_BORTH_DAY,SET_DAYS		; 娘の誕生日

	MOV	AX,2				; 1=父->娘,2=娘->父
	CALLE	WIDNAME_COLOR_OL		; WINDOWS/名前ｳｲﾝﾄﾞｳ･ｶﾗｰOL
MAINLP_AGE_IN:					;
	CALL	WID_SMALL			; window small.
	CALLE	WIDAGE_SET			; WINDOWS/年齢入力
	CMP	AX,2				; 2=キャンセル
	JE	MAINLP_BORTH_IN_GIRL_RETRY	;
	MOVX	FATHER_AGE,SLCT_AGE		; 父の年齢
	JMP	MAINLP_BORTH_IN_FATHER		;


MAINLP_BORTH_IN_FATHER_RETRY:
	MOV	AX,2				; 1=父->娘,2=娘->父
	CALLE	WIDNAME_COLOR_OL		; WINDOWS/名前ｳｲﾝﾄﾞｳ･ｶﾗｰOL
MAINLP_BORTH_IN_FATHER:
	CALL	WID_LAUGE			; window lauge.

	MOV	AX,GIRL_BORTH_YEAR		; 娘の誕生年
	SUB	AX,FATHER_AGE			; 父の年齢
	ADD	AX,GIRL_AGE			; 娘の年齢
	SUB	AX,1				; - 1
	MOV	START_YEAR,AX			; 誕生年
	MOVX	START_MONTH,GIRL_BORTH_MONTH	; 誕生月
	MOV	AX,1				; 1=父
	CALLE	WIDBORTH_SET			; WINDOWS/誕生日ウインドウ
	CMP	AX,2				; 2=キャンセル
	JE	MAINLP_AGE_IN			;

	MOVX	FATHER_BORTH_YEAR,SET_YEAR	; 父の誕生年
	MOVX	FATHER_BORTH_MONTH,SET_MONTH	; 父の誕生月
	MOVX	FATHER_BORTH_DAY,SET_DAYS	; 父の誕生日

	CALL	FATHER_BORTH_D_CHK		; father borth day check.

	MOV	AX,1				; 1=父->娘,2=娘->父
	CALLE	WIDNAME_COLOR_OL		; WINDOWS/名前ｳｲﾝﾄﾞｳ･ｶﾗｰOL
	CALL	WID_SMALL			; window small.
	CALLE	WIDBLOOD_SET			; WINDOWS/血液型入力
	CMP	AX,2				; 2=キャンセル
	JE	MAINLP_BORTH_IN_FATHER_RETRY

	MOVX	GIRL_BLOOD_TYPE,BLOOD_TYPE	; 娘の血液型
	MOVX	LNG_NAME_FIRST,LEN_NAME_FIRST	; ファーストネーム長さ
	MOVX	LNG_NAME_SECOND,LEN_NAME_SECOND	; ファミリーネーム長さ
MAINLP_EXIT:

	CALL	PARAWRITE			; parameter write.

	CALL	DUMP01N				; dump.

MAINLP_SKIP:
	RET
MAINLP	ENDP


; ****************************************************
;	father borth day check.
;	父の誕生日前が必ず指定の年齢になるようにする
;	-I- GIRL_BORTH_MONTH  : 娘の誕生月
;	    GIRL_BORTH_DAY    : 娘の誕生日
;	    FATHER_BORTH_MONTH: 父の誕生月
;	    FATHER_BORTH_DAY  : 父の誕生日
;	-I/O- FATHER_BORTH_YEAR : 父の誕生年
; ****************************************************

FATHER_BORTH_D_CHK	PROC	NEAR
	CMPX	FATHER_BORTH_MONTH,GIRL_BORTH_MONTH	; 月のチェック
	JNE	FATHER_BORTH_D_CHK_EXIT

	CMPX	FATHER_BORTH_DAY,GIRL_BORTH_DAY	;父の誕生日が娘より後ならばOK
	JNB	FATHER_BORTH_D_CHK_EXIT

	INC	FATHER_BORTH_YEAR		; 父の誕生年+1

FATHER_BORTH_D_CHK_EXIT:
	RET
FATHER_BORTH_D_CHK	ENDP


; ****************************************************
;	window frame load.
; ****************************************************

WID_FRM_LOAD	PROC	NEAR
	STRS	SI,"FRMNAMEL"		;#2 FRMNAMEL.PT1 33540 93-02-02 22:49
	MOV	DX,2			;bank number.
	CALLE	PT_PATTERN_LD		;pattern load.

	STRS	SI,"FRMNAMER"		;#0 FRMNAMER.PT1 34034 93-02-02 22:44
	MOV	DX,0			;bank number.
	CALLE	PT_PATTERN_LD		;pattern load.
	STRS	SI,"FRMBORTL"		;FRMBORTL PT1   6070 93-02-04   16:33
	CALLE	PT_PATTERN_LDA		;pattern add load.
	STRS	SI,"FRMBORTR"		;FRMBORTR PT1   5908 93-02-04   16:34
	CALLE	PT_PATTERN_LDA		;pattern add load.
	STRS	SI,"FRMBWEEK"		;FRMBWEEK PT1    222 93-02-05   15:48
	CALLE	PT_PATTERN_LDA		;pattern add load.
	RET
WID_FRM_LOAD	ENDP


; ****************************************************
;	window small.
; ****************************************************

WID_SMALL	PROC	NEAR
	MOV	DX,2			;bank number.
	CALLE	PT_PATTERN_BANK		;pattern bank set.
	MOV	AX,0			;put x.
	MOV	BX,0			;put y.
	MOV	DX,0			;pattern number.
	CALLE	PT_PATTERN_PUT		;pattern put.
	MOV	DX,0			;bank number.
	CALLE	PT_PATTERN_BANK		;pattern bank set.
	MOV	AX,40			;put x.
	MOV	BX,0			;put y.
	MOV	DX,0			;pattern number.
	CALLE	PT_PATTERN_PUT		;pattern put.
	RET
WID_SMALL	ENDP


; ****************************************************
;	window lauge.
; ****************************************************

WID_LAUGE	PROC	NEAR
	MOV	DX,0			;bank number.
	CALLE	PT_PATTERN_BANK		;pattern bank set.
	MOV	AX,0			;put x.
	MOV	BX,0			;put y.
	MOV	DX,1			;pattern number.
	CALLE	PT_PATTERN_PUT		;pattern put.
	MOV	AX,40			;put x.
	MOV	BX,0			;put y.
	MOV	DX,2			;pattern number.
	CALLE	PT_PATTERN_PUT		;pattern put.
	RET
WID_LAUGE	ENDP


; ****************************************************
;	window borth week.
;	-I- AX : x.
;	    BX : y.
; ****************************************************

PT_BORTH_WEEK	PROC	NEAR
	MOV	XX1,AX
	MOV	YY1,BX

	MOV	DX,0			;bank number.
	CALLE	PT_PATTERN_BANK		;pattern bank set.

	MOV	AX,XX1			;put x.
	MOV	BX,YY1			;put y.
	MOV	DX,3			;pattern number.
	CALLE	PT_PATTERN_PUT		;pattern put.

	RET
PT_BORTH_WEEK	ENDP


; ****************************************************
;	parameter write.
; ****************************************************

PARAWRITE	PROC	NEAR
	MOVX	ES,DS				; 初期設定項目のテーブル
	MOV	SI,OFFSET TABLE_NAME_SET	; name set table.
	MOV	BX,26				; name in set.
	CALLE	MAIN_FUNCTION_INTER		; main function inter.
	RET
PARAWRITE	ENDP


; ****************************************************
;	dump.
; ****************************************************

DUMP01N	PROC	NEAR
IF 0
	PRV "GIRL_BORTH_YEAR=",GIRL_BORTH_YEAR		; 娘の誕生年
	PRV "GIRL_BORTH_MONTH=",GIRL_BORTH_MONTH	; 娘の誕生月
	PRV "GIRL_BORTH_DAY=",GIRL_BORTH_DAY		; 娘の誕生日
	CALLE	MSWWAT
	PRV "FATHER_BORTH_YEAR=",FATHER_BORTH_YEAR	; 父の誕生年
	PRV "FATHER_BORTH_MONTH=",FATHER_BORTH_MONTH	; 父の誕生月
	PRV "FATHER_BORTH_DAY=",FATHER_BORTH_DAY	; 父の誕生日
	CALLE	MSWWAT
	PRV "FATHER_AGE=",FATHER_AGE			; 父の年齢
	CALLE	MSWWAT
ENDIF
	RET
DUMP01N	ENDP


; ****************************************************
;	data.
; ****************************************************

EXTRN	NAME_FIRST:BYTE		; ファーストネーム
EXTRN	NAME_SECOND:BYTE	; ファミリーネーム
EXTRN	LEN_NAME_FIRST:WORD	; ファーストネーム長さ
EXTRN	LEN_NAME_SECOND:WORD	; ファミリーネーム長さ

EXTRN	SET_YEAR:WORD		; 設定・年代
EXTRN	SET_MONTH:WORD		; 設定・月
EXTRN	SET_DAYS:WORD		; 設定・日

EXTRN	START_YEAR:WORD		; 表示開始・年
EXTRN	START_MONTH:WORD	; 表示開始・月

EXTRN	SLCT_AGE:WORD		; 選択された年齢

EXTRN	BLOOD_TYPE:WORD		; 血液型

EXTRN	VX1:WORD		; point x1.
EXTRN	VY1:WORD		; point y1.
EXTRN	VX2:WORD		; point x2.
EXTRN	VY2:WORD		; point y2.

			EVEN
TABLE_NAME_SET		LABEL	BYTE		; name set table.
GIRL_BORTH_YEAR		DW	0		;(+00) 娘の誕生年
GIRL_BORTH_MONTH	DW	0		;(+02) 娘の誕生月
GIRL_BORTH_DAY		DW	0		;(+04) 娘の誕生日
GIRL_AGE		DW	0		;(+06) 娘の年齢
FATHER_BORTH_YEAR	DW	0		;(+08) 父の誕生年
FATHER_BORTH_MONTH	DW	0		;(+10) 父の誕生月
FATHER_BORTH_DAY	DW	0		;(+12) 父の誕生日
FATHER_AGE		DW	0		;(+14) 父の年齢
GIRL_BLOOD_TYPE		DW	0		;(+16) 娘の血液型
			DW	NAME_FIRST	;(+18) ファーストネーム
			DW	NAME_SECOND	;(+20) ファミリーネーム
LNG_NAME_FIRST		DW	0		;(+22) ファーストネーム長さ
LNG_NAME_SECOND		DW	0		;(+24) ファミリーネーム長さ

XX1		DW	0
YY1		DW	0

CODE	ENDS
	END
;
;	end of "MAINLP.ASM"
;
