; "WIDFACE.ASM" 486/50 make by R.H 1992/05/21
;
;
;	ＷＩＮＤＯＷＳ／フェイス・ウインドウ
;
;
;	WIDFACE		 ; WINDOWS/フェイス・ウインドウ
;	WIDFACEGIRL	 ; WINDOWS/フェイス・娘ウインドウ
;	WIDFACESYUGO	 ; WINDOWS/フェイス・守護星ウインドウ
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA

; ****************************************************
;	WINDOWS/フェイス・ウインドウ
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    SI   : フェイスファイル名
; ****************************************************

FUNC	WIDFACE
	MOV	AX,WDX1			; 表示位置Ｘ
	MOV	BX,WDY1			; 表示位置Ｙ
	CALL_w	PT_FACE			; put face.
	RET
FEND	WIDFACE


; ****************************************************
;	WINDOWS/フェイス・娘ウインドウ
;	-I- WDX1         : 表示位置Ｘ
;	    WDY1         : 表示位置Ｙ
;	    WD_FACE_GIRL : girl face.
; ****************************************************

FUNC	WIDFACEGIRL
	MOVX	WD_GIRL_AGE,P_NENREI	; 年齢

	MOV	AX,WDX1			; 表示位置Ｘ
	MOV	BX,WDY1			; 表示位置Ｙ
	CALL_w	PT_FACE_GIRL		; put girl face.
	RET
FEND	WIDFACEGIRL


; ****************************************************
;	WINDOWS/フェイス・守護星ウインドウ
;	-I- WDX1         : 表示位置Ｘ
;	    WDY1         : 表示位置Ｙ
;	    WD_FACE_SYUGO: syugosei face.
; ****************************************************

FUNC	WIDFACESYUGO
	MOV	AX,WDX1			; 表示位置Ｘ
	MOV	BX,WDY1			; 表示位置Ｙ
	CALL_w	PT_FACE_SYUGO		; put syugo face.
	RET
FEND	WIDFACESYUGO

WINDOW	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	WD_FACE_GIRL		; girl face.
PUBLIC	WD_FACE_SYUGO		; syugosei face.

EXTRN	P_NENREI:WORD		; 年齢
EXTRN	WD_GIRL_AGE:WORD	; girl age.

WD_FACE_GIRL	DW	0	; girl face.
				; 0=普通 1=嬉しい 2=怒り 3=悲しい 4=暑い
				; 5=寒い 6=大怪我 7=苦しい 8=すねる
				; 9=不思議 10=恥らう 11=不安 12=不愉快
				; 13=妖しい 14=りりしい 15=驚き 16=ガーン
				; 17=真剣 18=困り

WD_FACE_SYUGO	DW	0	; syugosei face.
				; 0="太陽",1="月",2="火星",3="水星",4="木星"
				; 5="金星",6="土星",7="天王星",8="海王星"
				; 9="冥王星"

DATA	ENDS

	END
;
;	end of "WIDFACE.ASM"
;
