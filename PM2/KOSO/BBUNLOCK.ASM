; "BBUNLOCK.ASM" PC-9801UV11 make by R.H 1992/01/23
;
;
;	テキストデータ復元
;
;
;
;	CUT_COMMENT(コメントカット)はデバック用です。
;	外してもよい。
;
;
; public routine.

INCLUDE	TSTSETC.INC

CODE_KANA_IN	EQU	02H	; 半角カナIN
CODE_KANA_OUT	EQU	03H	; 半角カナOUT


CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:DATA

PUBLIC	BBUNLOCK		; テキストデータ復元

; ****************************************************
;	テキストデータ復元
;	-I- DX:SI : 元データ
;	    BX    : 復元データ長
;	    ES:DI : 復元データ
;	    CX    : 復元データバッファ長
; ****************************************************

BBUNLOCK	PROC	NEAR
	MOV	ORGBUFF_SEG,DX		; 元データセグメント
	MOV	ORGBUFF_OFS,SI		; 元データオフセット
	MOV	ORGBUFF_SIZ,BX		; 元データ長

	MOV	WRTBUFF_SEG,ES		; 復元データセグメント
	MOV	WRTBUFF_OFS,DI		; 復元データオフセット
	MOV	WRTBUFF_SIZ,CX		; 復元データバッファ長

;*;	PUSH	DI			;
;*;	XOR	AL,AL			; AL=0
;*;	REP	STOSB			; clear
;*;	POP	DI			;

	MOV	SEG_I_BUFF,DX		; 入力ファイルバッファ
	MOV	OFS_I_BUFF,SI		;
	MOV	SEG_O_BUFF,ES		; 出力ファイルバッファ
	MOV	OFS_O_BUFF,DI		;
	MOV	CNT,BX			; 読み込みファイルバイト数

;voidvoidvoid
;voidvoidvoid
;voidvoidvoid

	MOVX	CNT,CNT2		; 読み込みファイルバイト数

	MOV	AX,ORGBUFF_SEG		; 元データセグメント
	MOV	BX,ORGBUFF_OFS		; 元データオフセット
	MOV	CX,WRTBUFF_SEG		; 復元データセグメント
	MOV	DX,WRTBUFF_OFS		; 復元データオフセット
	MOV	SEG_I_BUFF,CX		; 入力ファイルバッファ
	MOV	OFS_I_BUFF,DX		;
	MOV	SEG_O_BUFF,AX		; 出力ファイルバッファ
	MOV	OFS_O_BUFF,BX		;

	MOV	ES,SEG_I_BUFF		; 入力ファイルバッファ
	MOV	DI,OFS_I_BUFF		;
	ADD	DI,CNT			; 読み込みファイルバイト数
	MOV	WORD PTR ES:[DI],0	;

	CALL	BINUNPLESS		; データ復元
	MOVX	CNT,CNT2		; 読み込みファイルバイト数

	MOV	AX,ORGBUFF_SEG		; 元データセグメント
	MOV	BX,ORGBUFF_OFS		; 元データオフセット
	MOV	CX,WRTBUFF_SEG		; 復元データセグメント
	MOV	DX,WRTBUFF_OFS		; 復元データオフセット
	MOV	SEG_I_BUFF,AX		; 入力ファイルバッファ
	MOV	OFS_I_BUFF,BX		;
	MOV	SEG_O_BUFF,CX		; 出力ファイルバッファ
	MOV	OFS_O_BUFF,DX		;

	CALL	KANFUKU			; 半角化されたひらがなの復元
	MOVX	CNT,CNT2		; 読み込みファイルバイト数

	MOV	AX,ORGBUFF_SEG		; 元データセグメント
	MOV	BX,ORGBUFF_OFS		; 元データオフセット
	MOV	CX,WRTBUFF_SEG		; 復元データセグメント
	MOV	DX,WRTBUFF_OFS		; 復元データオフセット
	MOV	SEG_I_BUFF,CX		; 入力ファイルバッファ
	MOV	OFS_I_BUFF,DX		;
	MOV	SEG_O_BUFF,AX		; 出力ファイルバッファ
	MOV	OFS_O_BUFF,BX		;

	CALL	UNPACHANKA		; 半角カタカナのアンパック化

	MOV	DX,ORGBUFF_SEG		; 元データセグメント
	MOV	SI,ORGBUFF_OFS		; 元データオフセット
	MOV	ES,WRTBUFF_SEG		; 復元データセグメント
	MOV	DI,WRTBUFF_OFS		; 復元データオフセット
	MOV	CX,CNT2			; 書き込みファイルバイト数
	PUSH	DS
	MOV	DS,DX
	REP	MOVSB
	POP	DS

	JMP	BBUNLOCK_EXIT

BBUNLOCK_NONPLES:
	MOVX	CNT,CNT2		; 読み込みファイルバイト数

	MOV	AX,ORGBUFF_SEG		; 元データセグメント
	MOV	BX,ORGBUFF_OFS		; 元データオフセット
	MOV	CX,WRTBUFF_SEG		; 復元データセグメント
	MOV	DX,WRTBUFF_OFS		; 復元データオフセット
	MOV	SEG_I_BUFF,CX		; 入力ファイルバッファ
	MOV	OFS_I_BUFF,DX		;
	MOV	SEG_O_BUFF,AX		; 出力ファイルバッファ
	MOV	OFS_O_BUFF,BX		;
	CALL	CUT_COMMENT		; コメントカット

	MOV	DX,ORGBUFF_SEG		; 元データセグメント
	MOV	SI,ORGBUFF_OFS		; 元データオフセット
	MOV	ES,WRTBUFF_SEG		; 復元データセグメント
	MOV	DI,WRTBUFF_OFS		; 復元データオフセット
	MOV	CX,CNT2			; 書き込みファイルバイト数
	PUSH	DS
	MOV	DS,DX
	REP	MOVSB
	POP	DS

BBUNLOCK_EXIT:
	MOV	ES,WRTBUFF_SEG		; 復元データセグメント
	MOV	DI,WRTBUFF_OFS		; 復元データオフセット
	ADD	DI,CNT2			; 書き込みファイルバイト数
	MOV	WORD PTR ES:[DI],0	;
	RET
BBUNLOCK	ENDP


; ****************************************************
;	データ復元
;	-O- CNT2  : 書き込みファイルバイト数
; ****************************************************

BINUNPLESS	PROC	NEAR
	MOVX	BPNTSG,SEG_I_BUFF	; 入力ファイルバッファ
	MOVX	BPNTOF,OFS_I_BUFF	;

	MOV	ES,SEG_O_BUFF		; 出力ファイルバッファ
	MOV	DI,OFS_O_BUFF		;

	CALLE	c_C1BUNPLE		; 圧縮フォーマットデータ復元

	MOV	CNT2,CX			;

	RET
BINUNPLESS	ENDP


;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid

;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid

;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid

;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid

;voidvoidvoid
;voidvoidvoid
;voidvoidvoid

;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid

;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid


; ****************************************************
;	半角カタカナのアンパック化
;	-I- CNT   : 読み込みファイルバイト数
;	-O- CNT2  : 書き込みファイルバイト数
; ****************************************************

UNPACHANKA	PROC	NEAR
	MOV	FLG_HANKANA_IN,0	; 半角カナINフラグ

	MOV	BP,SEG_I_BUFF		; 入力ファイルバッファ
	MOV	SI,OFS_I_BUFF		;

	MOV	BX,SEG_O_BUFF		; 出力ファイルバッファ
	MOV	DI,OFS_O_BUFF		;

	MOV	CX,CNT			; 読み込みファイルバイト数
	ADD	CX,OFS_I_BUFF		;
UNPACHANKA_LOOP:
	CMP	SI,CX			;
	JNB	UNPACHANKA_EXIT		;

	MOV	ES,BP			;
	MOV	DX,ES:[SI]		; get 1 word
	INC	SI			;

	CMP	DL,1AH			; <EOF>
	JE	UNPACHANKA_EOF		;

	CMP	DL,CODE_KANA_IN		; 半角カナIN
	JE	UNPACHANKA_KA_IN	;
	CMP	DL,CODE_KANA_OUT	; 半角カナOUT
	JE	UNPACHANKA_KA_OUT	;
	JMP	UNPACHANKA_5		;
UNPACHANKA_KA_IN:
	MOV	FLG_HANKANA_IN,1	; 半角カナINフラグ
	JMP	UNPACHANKA_NEXT		;
UNPACHANKA_KA_OUT:
	MOV	FLG_HANKANA_IN,0	; 半角カナINフラグ
	JMP	UNPACHANKA_NEXT		;

UNPACHANKA_5:
	CMP	FLG_HANKANA_IN,1	; 半角カナINフラグ
	JE	UNPACHANKA_SETKANA	;
	JMP	UNPACHANKA_SETB		;

UNPACHANKA_SETKANA:
	ADD	DL,80H			;
	MOV	ES,BX			;
	MOV	ES:[DI],DL		; put 1 byte.
	INC	DI			;
	JMP	UNPACHANKA_NEXT		;

UNPACHANKA_EOF:
	MOV	ES,BX			;
	MOV	BYTE PTR ES:[DI],1AH	; <EOF>
	INC	DI			;
	JMP	UNPACHANKA_EXIT		;

UNPACHANKA_SETB:
	MOV	ES,BX			;
	MOV	ES:[DI],DL		; put 1 byte.
	INC	DI			;

UNPACHANKA_NEXT:
	JMP	UNPACHANKA_LOOP

UNPACHANKA_EXIT:
	SUB	DI,OFS_O_BUFF		;
	MOV	CNT2,DI			; 書き込みファイルバイト数
	RET
UNPACHANKA	ENDP


; ****************************************************
;	半角化されたひらがなの復元
;	-I- CNT   : 読み込みファイルバイト数
;	-O- CNT2  : 書き込みファイルバイト数
; ****************************************************

KANFUKU	PROC	NEAR
	MOV	BP,SEG_I_BUFF		; 入力ファイルバッファ
	MOV	SI,OFS_I_BUFF		;

	MOV	BX,SEG_O_BUFF		; 出力ファイルバッファ
	MOV	DI,OFS_O_BUFF		;

	MOV	CX,CNT			; 読み込みファイルバイト数
	ADD	CX,OFS_I_BUFF		;
KANFUKU_LOOP:
	CMP	SI,CX			;
	JMPNB	KANFUKU_EXIT		;

	MOV	ES,BP			;
	MOV	DX,ES:[SI]		; get 1 word
	INC	SI			;

	CMP	DL,0CH			; CR/LF
	JE	KANFUKU_CRLF		;

	CMP	DL,0BH			; <EOF>
	JE	KANFUKU_EOF		;

	CALL	SJISCK			; shift jis check.
	CMP	AX,1			; 0=normal,1=shift jis code.
	JE	KANFUKU_KANJI		;

	CMP	DL,0A0H			;
	JB	KANFUKU_55		;
	CMP	DL,0DFH			;
	JNBE	KANFUKU_55		;
	JMP	KANFUKU_KANA		;
KANFUKU_55:
	CMP	DL,0DH			;
	JB	KANFUKU_SETB		;
	CMP	DL,01FH			;
	JNBE	KANFUKU_SETB		;
	JMP	KANFUKU_KANA2		;

KANFUKU_KANA:
	MOV	DH,DL			;
	SUB	DH,0A0H			;
	ADD	DH,09FH			; "ぁ"
	MOV	DL,082H			; shift jis top.
	MOV	ES,BX			;
	MOV	ES:[DI],DX		; put 1 byte.
	INC	DI			;
	INC	DI			;
	JMP	KANFUKU_NEXT		;

KANFUKU_KANA2:
	MOV	DH,DL			;
	SUB	DH,0DH			; 0DH-1FH
	ADD	DH,0DFH			; "め"
	MOV	DL,082H			; shift jis top.
	MOV	ES,BX			;
	MOV	ES:[DI],DX		; put 1 byte.
	INC	DI			;
	INC	DI			;
	JMP	KANFUKU_NEXT		;

KANFUKU_CRLF:
	MOV	ES,BX			;
	MOV	ES:[DI],0A0DH		; 0DH/0AH
	INC	DI			;
	INC	DI			;
	JMP	KANFUKU_NEXT		;

KANFUKU_EOF:
	MOV	ES,BX			;
	MOV	BYTE PTR ES:[DI],1AH	; <EOF>
	INC	DI			;
	JMP	KANFUKU_EXIT		;

KANFUKU_KANJI:
	INC	SI			;
	MOV	ES,BX			;
	MOV	ES:[DI],DX		; put 1 word.
	INC	DI			;
	INC	DI			;
	JMP	KANFUKU_NEXT		;

KANFUKU_SETB:
	MOV	ES,BX			;
	MOV	ES:[DI],DL		; put 1 byte.
	INC	DI			;

KANFUKU_NEXT:
	JMP	KANFUKU_LOOP

KANFUKU_EXIT:
	SUB	DI,OFS_O_BUFF		;
	MOV	CNT2,DI			; 書き込みファイルバイト数
	RET
KANFUKU	ENDP


; ****************************************************
;	shift jis check.
;	-I- DX : character code.
;	-O- AX : 0=normal,1=shift jis code.
; ****************************************************

SJISCK	PROC	NEAR
	MOV	AX,0
	CMP	DL,081H
	JB	SJISCK3
	CMP	DL,09FH
	JNBE	SJISCK3
	MOV	AX,1		; shift jis code.
	RET
SJISCK3:
	CMP	DL,0E0H
	JB	SJISCK9
	CMP	DL,0FCH
	JNBE	SJISCK9
	MOV	AX,1		; shift jis code.
SJISCK9:
	RET
SJISCK	ENDP


;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid

;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid


; ****************************************************
;	コメントカット
;	-I- CNT   : 読み込みファイルバイト数
;	-O- CNT2  : 書き込みファイルバイト数
; ****************************************************

CUT_COMMENT	PROC	NEAR
	MOV	CNT2,0			; 書き込みファイルバイト数

	MOV	TABCOUNT,0		; タブカウンタ

	MOV	ES,SEG_I_BUFF		; 入力ファイルバッファ
	MOV	DI,OFS_I_BUFF		; ES:[DI] 入力

	MOV	BX,SEG_O_BUFF		; 出力ファイルバッファ
	MOV	BP,OFS_O_BUFF		; BX:[BP] 出力

CUT_COMMENT_LOOP:
	MOV	AX,ES:[DI]		;
	INC	DI			; input pointer.
	MOV	DX,AX			; character code.
	PUSH	AX			;
	CALL	SJISCK			; shift jis check.
	CMP	AX,1			; 0=normal,1=shift jis code.
	POP	AX			;
	JMPEQ	CUT_COMMENT_KANJI	;

	CMP	AL,1AH			; <EOF>
	JNE	CUT_COMMENT_C_20	;
	JMP	CUT_COMMENT_LOOP_END	;

CUT_COMMENT_C_20:
	CMP	AL,0AH			; <LF>
	JNE	CUT_COMMENT_C_21	;
	MOV	FLG_CMNT,0		; コメントフラグ
	MOV	FLG_STRING,0		; 文字列フラグ
	JMP	CUT_COMMENT_SETB	;

CUT_COMMENT_C_21:
	CMP	AL,0DH			; <CR>
	JNE	CUT_COMMENT_C_22	;
	MOV	FLG_CMNT,0		; コメントフラグ
	MOV	FLG_STRING,0		; 文字列フラグ
	JMP	CUT_COMMENT_SETB	;

CUT_COMMENT_C_22:
	CMP	AL,09H			; <TAB>
	JNE	CUT_COMMENT_C_222	;
	INC	TABCOUNT		; タブカウンタ
	JMP	CUT_COMMENT_SETB_TABSP	;

CUT_COMMENT_C_222:
	CMP	AL,20H			; <space>
	JNE	CUT_COMMENT_C_23	;
	INC	TABCOUNT		; タブカウンタ
	JMP	CUT_COMMENT_SETB_TABSP	;

CUT_COMMENT_C_23:			;
	CMP	AL,";"			; <;>　コメント
	JNE	CUT_COMMENT_C_232	;

	CMP	FLG_STRING,0		; 文字列フラグ
	JNE	CUT_COMMENT_C_231	;

	CMP	FLG_CMNT,0		; コメントフラグ
	JNE	CUT_COMMENT_C_231	;

	MOV	FLG_CMNT,NOT 0		; コメントフラグ

	SUB	BP,TABCOUNT		; タブカウンタ
	MOV	TABCOUNT,0		; タブカウンタ

CUT_COMMENT_C_231:			;
	JMP	CUT_COMMENT_SETB	;

CUT_COMMENT_C_232:			;
	CMP	AL,22H			; <">
	JNE	CUT_COMMENT_C_24	;

	CMP	FLG_STRING,0		; 文字列フラグ
	JE	CUT_COMMENT_C_23_E	;
	CMP	CHR_QOUT,22H		; <"> クォーテーション
	JE	CUT_COMMENT_C_23_E	;
	JMP	CUT_COMMENT_SETB	;
CUT_COMMENT_C_23_E:			;
	NOT	FLG_STRING		; 文字列フラグ
	MOV	CHR_QOUT,22H		; <"> クォーテーション
	JMP	CUT_COMMENT_SETB	;

CUT_COMMENT_C_24:			;
	CMP	AL,27H			; <'>
	JNE	CUT_COMMENT_C_25	;

	CMP	FLG_STRING,0		; 文字列フラグ
	JE	CUT_COMMENT_C_24_E	;
	CMP	CHR_QOUT,27H		; <'> クォーテーション
	JE	CUT_COMMENT_C_24_E	;
	JMP	CUT_COMMENT_SETB	;
CUT_COMMENT_C_24_E:			;
	NOT	FLG_STRING		; 文字列フラグ
	MOV	CHR_QOUT,27H		; <'> クォーテーション
	JMP	CUT_COMMENT_SETB	;

CUT_COMMENT_C_25:			;
	JMP	CUT_COMMENT_SETB	;

CUT_COMMENT_KANJI:
	MOV	TABCOUNT,0		; タブカウンタ
	INC	DI			; input pointer.
	CMP	FLG_CMNT,0		; コメントフラグ
	JNE	CUT_COMMENT_NEXT	;
	MOV	CX,ES			;
	MOV	ES,BX			;
	MOV	ES:[BP],AX		;
	INC	BP			; BX:[BP] 出力
	INC	BP			;
	MOV	ES,CX			;
	JMP	CUT_COMMENT_NEXT	;

CUT_COMMENT_SETB:
	MOV	TABCOUNT,0		; タブカウンタ
CUT_COMMENT_SETB_TABSP:
	CMP	FLG_CMNT,0		; コメントフラグ
	JNE	CUT_COMMENT_NEXT	;
	MOV	CX,ES			;
	MOV	ES,BX			;
	MOV	ES:[BP],AL		;
	INC	BP			; BX:[BP] 出力
	MOV	ES,CX			;

CUT_COMMENT_NEXT:
	JMP	CUT_COMMENT_LOOP

CUT_COMMENT_LOOP_END:
	MOV	ES,BX			;
	MOV	ES:[BP],BYTE PTR 1AH	; <EOF>
	INC	BP			; BX:[BP] 出力
	MOV	CNT2,BP			; 書き込みファイルバイト数
	RET
CUT_COMMENT	ENDP



CODE	ENDS

; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	BPOINT:WORD		; data buffer point.
EXTRN	BPNTOF:WORD		; データバッファポインタ
EXTRN	BPNTSG:WORD		; データバッファセグメント
EXTRN	BCNTMX:WORD		; データ最大長さ
EXTRN	BCOUNT:WORD		; データ長さ

ORGBUFF_SEG	DW	0	; 元データセグメント
ORGBUFF_OFS	DW	0	; 元データオフセット
ORGBUFF_SIZ	DW	0	; 元データ長

WRTBUFF_SEG	DW	0	; 復元データセグメント
WRTBUFF_OFS	DW	0	; 復元データオフセット
WRTBUFF_SIZ	DW	0	; 復元データバッファ長

INBUF_LEN	DW	0	; 入力ファイルサイズ

SEG_I_BUFF	DW	0	; 入力ファイルバッファ
OFS_I_BUFF	DW	0	;

SEG_O_BUFF	DW	0	; 出力ファイルバッファ
OFS_O_BUFF	DW	0	;

CNT		DW	0	; 読み込みファイルバイト数
CNT2		DW	0	; 書き込みファイルバイト数

FLG_HANKANA_IN	DW	0	; 半角カナINフラグ

FLG_CMNT	DW	0		; コメントフラグ
FLG_STRING	DW	0		; 文字列フラグ
CHR_QOUT	DW	0		; クォーテーション
TABCOUNT	DW	0		; タブカウンタ

;voidvoidvoid
;voidvoidvoid

;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid
;voidvoidvoid

DATA	ENDS

	END
;
;	end of "BBUNLOCK.ASM"
;
