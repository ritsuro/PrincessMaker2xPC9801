; "STRINGS.ASM" PS55Z/S14 make by R.Hashimoto 1991/09/18
;
;
;	string set.
;
;
; public subroutine.


CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:CODE01

PUBLIC	STRSET			; 文字列バッファセット
PUBLIC	STRSETZ			; 文字列バッファセット
PUBLIC	STRFILL			; 文字列バッファＦＩＬＬ
PUBLIC	STRCLEAR		; 文字列バッファクリア
PUBLIC	STRZEROC		; 文字列バッファ０クリア
PUBLIC	STRSETADD		; 文字列の連結
PUBLIC	STRLENGTH		; 文字列長さ
PUBLIC	STRLENSPZ		; 文字列長さスペースまで
PUBLIC	STRCAPS			; 文字列大文字化
PUBLIC	STRXCHG			; 文字列キャラクタ書き換え

MOVX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	MOV	DEST,AX
	ENDM

; ***********************************************
;	文字列バッファセット
;	０（文字列終り）はセットしない
;	-I- ES:[SI]  : 元文字列
;	    DS:[DI]  : セットするバッファ
;	    CX       : バッファ最大長さ
;	-O- DS:[DI]  : 文字列バッファ
; ***********************************************

STRSET	PROC	NEAR
	PUSH	CX
	PUSH	DI
	PUSH	SI
	PUSH	AX
STRSET_2:				;
	MOV	AL,ES:[SI]		;
	CMP	AL,0			; end of string.
	JE	STRSET_3		;
	MOV	DS:[DI],AL		;
	INC	SI			;
	INC	DI			;
	LOOP	STRSET_2		;
STRSET_3:				;
	POP	AX
	POP	SI
	POP	DI
	POP	CX
	RET
STRSET	ENDP


; ***********************************************
;	文字列バッファセット
;	０（文字列終り）をセットする
;	-I- ES:[SI]  : 元文字列
;	    DS:[DI]  : セットするバッファ
;	    CX       : バッファ最大長さ
;	-O- DS:[DI]  : 文字列バッファ
; ***********************************************

STRSETZ	PROC	NEAR
	PUSH	CX
	PUSH	DI
	PUSH	SI
	PUSH	AX
STRSETZ_2:				;
	MOV	AL,ES:[SI]		;
	MOV	DS:[DI],AL		;
	CMP	AL,0			; end of string.
	JE	STRSETZ_3		;
	INC	SI			;
	INC	DI			;
	LOOP	STRSETZ_2		;
STRSETZ_3:				;
	POP	AX
	POP	SI
	POP	DI
	POP	CX
	RET
STRSETZ	ENDP


; ***********************************************
;	文字列バッファＦＩＬＬ
;	０（文字列終り）はセットしない
;	-I- DX       : 文字	ＡＮＫ（ＤＨ＝０），漢字（ＤＨ＝上位バイト）
;	    DS:[DI]  : セットするバッファ
;	    CX       : バッファ最大長さ
;	-O- DS:[DI]  : 文字列バッファ
; ***********************************************

STRFILL	PROC	NEAR
	PUSH	CX
	PUSH	DI
	PUSH	SI
	PUSH	AX

	CMP	DH,0			; 文字
	JNZ	STRFILL_KANJI		;

	JCXZ	STRFILL_EXIT		; if cx=0 then end

	MOVX	ES,DS
	MOV	AX,DX
	REP	STOSB

	JMP	STRFILL_EXIT
STRFILL_KANJI:
	SHR	CX,1			; word pointer.

	JCXZ	STRFILL_EXIT		; if cx=0 then end

	MOVX	ES,DS
	MOV	AX,DX
	XCHG	AH,AL
	REP	STOSW
STRFILL_EXIT:
	POP	AX
	POP	SI
	POP	DI
	POP	CX
	RET
STRFILL	ENDP


; ***********************************************
;	文字列バッファクリア
;	-I- DS:DI : 文字列バッファ
;	    CX    : 文字列長さ
; ***********************************************

STRCLEAR	PROC	NEAR
	PUSH	ES			;
	PUSH	DI			;
	PUSH	CX			;
	PUSH	AX			;
	MOVX	ES,DS			;
	MOV	AL,' '			; space.
	REP	STOSB			;
	POP	AX			;
	POP	CX			;
	POP	DI			;
	POP	ES			;
	RET
STRCLEAR	ENDP


; ***********************************************
;	文字列バッファ０クリア
;	-I- DS:DI : 文字列バッファ
;	    CX    : 文字列長さ
; ***********************************************

STRZEROC	PROC	NEAR
	PUSH	ES			;
	PUSH	DI			;
	PUSH	CX			;
	PUSH	AX			;
	MOVX	ES,DS			;
	MOV	AL,0			; space.
	REP	STOSB			;
	POP	AX			;
	POP	CX			;
	POP	DI			;
	POP	ES			;
	RET
STRZEROC	ENDP


; ***********************************************
;	文字列の連結
;	０（文字列終り）をセットする
;	-I- DS:[DI]  : 文字列
;	    DS:[SI]  : 連結する文字列
;	    CX       : 最大長さ
; ***********************************************

STRSETADD	PROC	NEAR
	PUSH	ES
	PUSH	DI
	PUSH	SI
	PUSH	DX

	MOV	DX,CX

	MOVX	ES,DS
	CALL	STRLENGTH		; 文字列長さ

	SUB	DX,CX
	JB	STRSETADD_SKIP

	ADD	DI,CX

	MOV	CX,DX			; バッファ最大長さ

	MOVX	ES,DS
	CALL	STRSETZ			; 文字列バッファセット

STRSETADD_SKIP:
	POP	DX
	POP	SI
	POP	DI
	POP	ES
	RET
STRSETADD	ENDP

; ****************************************************
;	文字列長さ
;	-I- ES:DI : 文字列アドレス
;	-O- CX    : 表示単語長さ
; ****************************************************

STRLENGTH	PROC	NEAR
	PUSH	DI

	MOV	CX,256
	MOV	AL,0
	REPNE	SCASB

	NEG	CX
	ADD	CX,256

	DEC	CX

	POP	DI

	RET
STRLENGTH	ENDP


; ****************************************************
;	文字列長さスペースまで
;	-I- ES:DI : 文字列アドレス
;	-O- CX    : 表示単語長さ
; ****************************************************

STRLENSPZ	PROC	NEAR
	PUSH	DI

	MOV	CX,256
STRLENSPZ_LOOP:
	MOV	AL,ES:[DI]
	INC	DI
	CMP	AL,' '
	JBE	STRLENSPZ_LOOP_E
	LOOP	STRLENSPZ_LOOP

	MOV	CX,256
	POP	DI
	RET

STRLENSPZ_LOOP_E:
	NEG	CX
	ADD	CX,256

	POP	DI
	RET
STRLENSPZ	ENDP


; ****************************************************
;	文字列大文字化
;	-I- ES:DI : 文字列アドレス
; ****************************************************

STRCAPS	PROC	NEAR
	PUSH	DS
	PUSH	ES
	PUSH	SI
	PUSH	DI
	PUSH	AX

	MOVX	DS,ES			;
	MOV	SI,DI			;
STRCAPS_LOOP:				;
	LODSB				; get 1 char.
	CMP	AL,0			; end of string.
	JE	STRCAPS_LOOP_E		;

	CMP	AL,'a'			; if  'a' <= al <= 'z' then
	JB	STRCAPS_5		;
	CMP	AL,'z'			;
	JNBE	STRCAPS_5		;
	SUB	AL,32			;   al = al - ('A'-'a')
	STOSB				;   put 1 char.
	JMP	STRCAPS_6		;
STRCAPS_5:				; else
	INC	DI			;   skip 1 char.
STRCAPS_6:				; endif
	JMP	STRCAPS_LOOP		;

STRCAPS_LOOP_E:

	POP	AX
	POP	DI
	POP	SI
	POP	ES
	POP	DS
	RET
STRCAPS	ENDP


; ****************************************************
;	文字列キャラクタ書き換え
;	-I- ES:DI : 文字列アドレス
;	    DH    : 検索キャラクタ
;	    DL    : 置換キャラクタ
; ****************************************************

STRXCHG	PROC	NEAR
	PUSH	DS
	PUSH	ES
	PUSH	SI
	PUSH	DI
	PUSH	AX

	MOVX	DS,ES			;
	MOV	SI,DI			;
STRXCHG_LOOP:				;
	LODSB				; get 1 char.
	CMP	AL,0			; end of string.
	JE	STRXCHG_LOOP_E		;
	CMP	AL,DH			; 検索キャラクタ
	JNE	STRXCHG_NEXT		;

	MOV	ES:[DI],DL		; 置換キャラクタ

STRXCHG_NEXT:				;
	INC	DI			;
	JMP	STRXCHG_LOOP		;

STRXCHG_LOOP_E:
	POP	AX
	POP	DI
	POP	SI
	POP	ES
	POP	DS
	RET
STRXCHG	ENDP

CODE01	ENDS

	END
;
;	end of "STRINGS.ASM"
;
