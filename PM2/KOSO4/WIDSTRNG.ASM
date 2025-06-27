; "WIDSTRNG.ASM" 486/50 make by R.H 1992/05/20
;
;
;	ＷＩＮＤＯＷＳ／文字処理
;
;
;	WID_STR_GOLD		; WINDOWS/文字列化・通貨
;	WID_STR_POINT		; WINDOWS/文字列化・パラメータ値
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA


; ****************************************************
;	WINDOWS/文字列化・通貨
;	-I- DX           : お金
;	-O- STR_VAL_BUFF : 表示値文字列バッファ
; ****************************************************

FUNC	WID_STR_GOLD
	CALL_w	DECSTR			; dec -> string.
	CALL_w	STRZTS			; zero to space. "00123" - > "  123"
	CALL_w	STRSPL			; space pless. "  123" - > "123  "

	MOVX	ES,DS			;
	MOV	DI,OFFSET STR_VAL_BUFF	; 表示値文字列バッファ
	MOV	CX,STRING_LEN		; string length.
	CALL_w	STRSETZ			; 文字列バッファセット

	MOV	BX,1			; 1=GOLD
	CALL_w	UNITSTR			; 単位表記

	MOV	DI,OFFSET STR_VAL_BUFF	; 表示値文字列バッファ
	MOV	CX,STR_VAL_LEN2		; string length.（数値表示拡張）
	CALL_w	STRSETADD		; 文字列の連結

	RET
FEND	WID_STR_GOLD


;*;; ****************************************************
;*;;	WINDOWS/ﾊﾟﾗﾒｰﾀ名前１文字化
;*;;	-I- SI       : パラメータ名前アドレス
;*;;	-O- STR_BUFF : １文字化文字列
;*;; ****************************************************
;*;
;*;WID_STR_P_1MOJI	PROC	NEAR
;*;	MOV	AX,DS:[SI]			; パラメータ名前アドレス
;*;	MOV	WORD PTR STR_BUFF,AX		; 名前短縮化文字列
;*;	MOV	STR_BUFF[2],0			; 名前短縮化文字列
;*;	RET
;*;WID_STR_P_1MOJI	ENDP


; ****************************************************
;	WINDOWS/文字列化・パラメータ値
;	-I- DX           : パラメータ値
;	-O- STR_VAL_BUFF : 表示値文字列バッファ
; ****************************************************

FUNC	WID_STR_POINT
;*;	CALL_w	DECSTR			; dec -> string.
	CALL_w	SIGSTR			; signed val DX to dec string.
	CALL_w	STRZTS			; zero to space. "00123" - > "  123"
	CALL_w	STRSPL			; space pless. "  123" - > "123  "

	MOVX	ES,DS			;
	MOV	DI,OFFSET STR_VAL_BUFF	; 表示値文字列バッファ
	MOV	CX,STRING_LEN		; string length.
	CALL_w	STRSETZ			; 文字列バッファセット
	RET
FEND	WID_STR_POINT

WINDOW	ENDS

DATA	SEGMENT	PUBLIC	'DATA'
DATA	ENDS

	END
;
;	end of "WIDSTRNG.ASM"
;
