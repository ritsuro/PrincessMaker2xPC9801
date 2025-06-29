; "UNITSTR.ASM" 486/50 make by R.H 1992/05/22
;
;
;	単位表記.
;
;
; public subroutine.

INCLUDE	TSTSET.INC

STRING_LEN 	EQU	255	; string length.
STR_VAL_LEN2	EQU	24	; string length.（数値表示拡張）

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	UNITSTR			; 単位表記
PUBLIC	UNIT_DATE_VAL_TO_STR	; 数値から日付文字列へ
PUBLIC	UNIT_S_GOLD		; お金文字列
PUBLIC	UNIT_S_POINT		; ポイント文字列
PUBLIC	UNIT_S_S2KETA		; 小数２桁文字列
PUBLIC	UNIT_S_S2KETA_G		; 小数２桁文字列(ｸﾞﾗﾌ)


;	単位表記
;	-I- BX : unit attribute.
;		1=GOLD
;		2=GOLD(text)
;	-O- SI : word address.

UNITSTR	PROC	NEAR
	SHL	BX,1		; word pointer.
	MOV	SI,DS:TBL_UNITSTR[BX]
	RET
UNITSTR	ENDP


;	数値から日付文字列へ
;	-I- AX : 年
;	    BX : 月
;	    CX : 日
;	-O- STR_BUFF : 時間 DB "1880/10/16"

UNIT_DATE_VAL_TO_STR		PROC	NEAR
	MOV	VV_YEAR,AX			; 年
	MOV	VV_MONTH,BX			; 月
	MOV	VV_DATE,CX			; 日

	MOV	STR_BUFF[4], BYTE PTR '/'	;
	MOV	STR_BUFF[7], BYTE PTR '/'	;

	MOV	DX,VV_YEAR			; 年
	CALL	DECSTR				; dec -> string
	MOVX	<WORD PTR STR_BUFF[0]>,DS:[SI][1] ; 01880
	MOVX	<WORD PTR STR_BUFF[2]>,DS:[SI][3] ;

	MOV	DX,VV_MONTH			; 月
	CALL	DECSTR				; dec -> string
	MOVX	<WORD PTR STR_BUFF[5]>,DS:[SI][3] ; 10

	MOV	DX,VV_DATE			; 日
	CALL	DECSTR				; dec -> string
	MOVX	<WORD PTR STR_BUFF[8]>,DS:[SI][3] ; 10

	MOV	STR_BUFF[10],0			; end of string.
	RET
UNIT_DATE_VAL_TO_STR		ENDP


;	お金文字列
;	-I- DX       : お金
;	-O- STR_BUFF : お金文字列

UNIT_S_GOLD	PROC	NEAR
	CALL	DECSTR			; val DX to dec string.
	CALL	STRZTS			; zero to space. "00123" - > "  123"
	CALL	STRSPL			; space pless. "  123" - > "123  "

	MOVX	ES,DS			;
	MOV	DI,OFFSET STR_VAL_BUFF	; 表示値文字列バッファ
	MOV	CX,STR_VAL_LEN2		; string length.（数値表示拡張）
	CALLE	STRSETZ			; 文字列バッファセット

	MOV	BX,2			; 2=GOLD(text)
	CALL	UNITSTR			; 単位表記

	MOV	DI,OFFSET STR_VAL_BUFF	; 表示値文字列バッファ
	MOV	CX,STR_VAL_LEN2		; string length.（数値表示拡張）
	CALLE	STRSETADD		; 文字列の連結

	MOV	SI,OFFSET STR_VAL_BUFF	; 表示値文字列バッファ
	MOV	DI,OFFSET STR_BUFF	; お金文字列
	CALLE	WORDTL_N_HNZN		; 文字列半角を全角
	RET
UNIT_S_GOLD	ENDP


;	ポイント文字列
;	-I- DX       : ポイント
;	-O- STR_BUFF : ポイント文字列

UNIT_S_POINT	PROC	NEAR
	CALL	DECSTR			; val DX to dec string.
	CALL	STRZTS			; zero to space. "00123" - > "  123"
	CALL	STRSPL			; space pless. "  123" - > "123  "

	MOV	DI,OFFSET STR_BUFF	; お金文字列
	CALLE	WORDTL_N_HNZN		; 文字列半角を全角
	RET
UNIT_S_POINT	ENDP


;	小数２桁文字列
;	-I- DX       : ポイント
;	-O- STR_BUFF : ポイント文字列

UNIT_S_S2KETA	PROC	NEAR
	CALL	UNIT_S_S2KETA_G		; 小数２桁文字列(ｸﾞﾗﾌ)
	MOVX	ES,DS			;
	MOV	CX,STR_VAL_LEN2		; string length.（数値表示拡張）
	MOV	SI,OFFSET STR_VAL_BUFF	; 表示値文字列バッファ
	MOV	DI,OFFSET STR_BUFF	;
	CALLE	STRSETZ			; 文字列バッファセット
;;;	CALLE	WORDTL_N_HNZN		; 文字列半角を全角
	RET
UNIT_S_S2KETA	ENDP


;	小数２桁文字列(ｸﾞﾗﾌ)
;	-I- DX       : ポイント
;	-O- STR_VAL_BUFF : 表示値文字列バッファ

UNIT_S_S2KETA_G	PROC	NEAR
	CALL	DECSTR			; val DX to dec string.
	MOVX	ES,DS			;
	MOV	CX,STR_VAL_LEN2		; string length.（数値表示拡張）
	MOV	DI,OFFSET STR_VAL_BUFF	; 表示値文字列バッファ
	CALL	STRSETZ			; 文字列バッファセット
	MOV	AX,WORD PTR STR_VAL_BUFF[3]
	MOV	STR_VAL_BUFF[3],0
	MOV	WORD PTR STR_VAL_BUFF[4],AX
	MOV	STR_VAL_BUFF[6],0

	MOV	SI,OFFSET STR_VAL_BUFF	;
	CALL	STRZTS			; zero to space. "00123" - > "  123"
	MOV	STR_VAL_BUFF[3],'.'	;
;*;	CALL	STRSPL			; space pless. "  123" - > "123  "
	RET
UNIT_S_S2KETA_G	ENDP


CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	STR_BUFF:BYTE		; 文字列バッファ
EXTRN	STR_VAL_BUFF:BYTE	; 表示値文字列バッファ

VV_YEAR		DW	0		; 年
VV_MONTH	DW	0		; 月
VV_DATE		DW	0		; 日

TBL_UNITSTR	DW	UNS00,UNS01,UNS02
UNS00	DB	0
UNS01	DB	"G",0
UNS02	DB	"Ｇ",0
UNS03	LABEL	BYTE

DATA	ENDS

	END
;
;	end of "UNITSTR.ASM"
;
