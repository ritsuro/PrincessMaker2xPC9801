; "DATPL4.ASM" PC-9801UV11 make by R.H 1992/04/20
;
;
;	バイナリデータ高速圧縮
;
;
; public subroutine.

INCLUDE	TSTSET.INC

ID_end		EQU	0
ID_image	EQU	1
ID_repart	EQU	2
ID_check	EQU	3

JCXZX	MACRO	LBL
	LOCAL	L1,L2
	JCXZ	L1
	JMP	L2
L1:
	JMP	LBL
L2:
	ENDM
JMPBE	MACRO	LBL
	LOCAL	L1
	JNBE	L1
	JMP	LBL
L1:
	ENDM

MOVX	MACRO	DEST,SOU
	MOV	AX,SOU
	MOV	DEST,AX
	ENDM

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	C1SPEDPLS	; バイナリデータ高速タイプ圧縮
PUBLIC	C1SPEDUNP	; 高速タイプバイナリデータ復元


;	バイナリデータ高速タイプ圧縮
;	-I- DX:SI  : ソースバッファ
;	    ES:DI  : 圧縮バッファ
;	    CX     : 長さ
;	-O- CX     : 圧縮後長さ

C1SPEDPLS	PROC	NEAR
	MOV	BUFFSEG,DX		; ソースバッファセグメント
	MOV	BUFFOFS,SI		; ソースバッファオフセット
	CALL	PLESS			; データ圧縮
	RET
C1SPEDPLS	ENDP

;	高速タイプバイナリデータ復元
;	-I- DX:SI  : 圧縮データバッファ
;	    ES:DI  : 展開バッファ
;	    CX     : 長さ

C1SPEDUNP	PROC	NEAR
	MOV	BUFFSEG,DX		; 圧縮データバッファセグメント
	MOV	BUFFOFS,SI		; 圧縮データバッファオフセット
	CALL	UNPLESS			; データ展開
	RET
C1SPEDUNP	ENDP


;	データ展開
;	-I- BUFFSEG: 圧縮データバッファセグメント
;	    BUFFOFS: 圧縮データバッファオフセット
;	    ES:DI  : バッファ
;	    CX     : 長さ

UNPLESS	PROC	NEAR
	PUSH	DS
	MOV	ERROR_4UNPLS,0			; 高速タイプ圧縮展開エラー

	MOV	SI,BUFFOFS
	MOVX	DS,BUFFSEG
	MOV	BP,CX
UNPLESS_LOOP:
	LODSW
	CMP	AX,ID_end
	JE	UNPLESS_EXIT
	CMP	AX,ID_image
	JE	UNPLESS_IMAGE
	CMP	AX,ID_repart
	JE	UNPLESS_REPART
	CMP	AX,ID_check
	JE	UNPLESS_CHECK

	JMP	UNPLESS_ERROR2

UNPLESS_IMAGE:
	LODSW				; image length.
	MOV	CX,AX
	REP	MOVSB
	JMP	UNPLESS_LOOP

UNPLESS_REPART:
	LODSW				; repart length.
	MOV	CX,AX
	LODSB				; pepart data.
	REP	STOSB
	JMP	UNPLESS_LOOP

UNPLESS_CHECK:
	SUB	DI,4
	MOV	CX,2
	REPE	CMPSW
	JNE	UNPLESS_ERROR
	JMP	UNPLESS_LOOP

UNPLESS_EXIT:
	POP	DS
	RET
UNPLESS_ERROR:
	POP	DS
	MOV	ERROR_4UNPLS,1			; 高速タイプ圧縮展開エラー
	RET
UNPLESS_ERROR2:
	POP	DS
	MOV	ERROR_4UNPLS,2			; 高速タイプ圧縮展開エラー
	RET
UNPLESS	ENDP


;	データ圧縮
;	-I- BUFFSEG: ソースバッファセグメント
;	    BUFFOFS: ソースバッファオフセット
;	    ES:DI  : バッファ
;	    CX     : 長さ
;	-O- CX     : 圧縮後長さ

PLESS	PROC	NEAR
	PUSH	DS
	PUSH	DI
	MOV	SI,BUFFOFS
	MOVX	DS,BUFFSEG
	MOV	BP,CX

	MOV	AX,SI			; チェック用
	ADD	AX,CX			; オフセット
	PUSH	AX			;

LOOP_START:

	PUSH	ES
	PUSH	DI
	PUSH	DS
	PUSH	SI

	MOVX	ES,DS		;
	MOV	DI,SI		; SI=元の比較データ
	INC	DI		; DI=１バイト先の比較データ
	MOV	CX,BP		; BP=元データ長
	DEC	CX		; CX=比較長さ

	JCXZX	BYTE1SET
NEXT_SCH:
	REPNE	CMPSB		; 同じバイトデータが並ぶ所まで探す。
	JCXZX	BYTENSET	;

	INC	CX		; もどす
	DEC	SI		;
	DEC	DI		;

	CMP	CX,6		; 比較が６バイト以下ならば
	JMPBE	BYTENSET	;

	MOV	AX,BP		; 全長－１－残り比較長さ
	DEC	AX		;
	SUB	AX,CX		; AX=イメージデータ長

	MOV	DX,CX		; DX=比較長さ
	REPE	CMPSB		;
	JE	BYTENSAMESET	;

	INC	CX		; もどす
	DEC	SI		;
	DEC	DI		;

	SUB	DX,CX		;
	INC	DX		;
	CMP	DX,6		; 比較が６バイト以下ならば
	JBE	NEXT_SCH	;

BYTESET:
	POP	SI
	POP	DS
	POP	DI
	POP	ES

	CMP	AX,0
	JE	BYTESET2

	MOV	ES:[DI],WORD PTR ID_image
	INC	DI
	INC	DI
	MOV	ES:[DI],AX		; AX=イメージデータ長
	INC	DI
	INC	DI
	MOV	CX,AX			; AX=イメージデータ長
	REP	MOVSB			; 1 byte move.

BYTESET2:
	MOV	ES:[DI],WORD PTR ID_repart
	INC	DI
	INC	DI
	MOV	ES:[DI],DX		; DX=リピートデータ長
	INC	DI
	INC	DI
	MOVSB
	DEC	SI
	ADD	SI,DX

	SUB	BP,AX			; イメージデータ長
	SUB	BP,DX			; リピートデータ長

	JMP	LOOP_START

BYTENSAMESET:
	POP	SI
	POP	DS
	POP	DI
	POP	ES

	CMP	AX,0
	JE	BYTENSAMESET2

	MOV	ES:[DI],WORD PTR ID_image
	INC	DI
	INC	DI
	MOV	ES:[DI],AX		; AX=イメージデータ長
	INC	DI
	INC	DI
	MOV	CX,AX			; AX=イメージデータ長
	REP	MOVSB			; 1 byte move.

BYTENSAMESET2:
	MOV	ES:[DI],WORD PTR ID_repart
	INC	DI
	INC	DI
	INC	DX			; DX+1
	MOV	ES:[DI],DX		; DX=リピートデータ長
	INC	DI
	INC	DI
	MOVSB

	JMP	ENDDATA

BYTENSET:
	POP	SI
	POP	DS
	POP	DI
	POP	ES

	MOV	ES:[DI],WORD PTR ID_image
	INC	DI
	INC	DI
	MOV	ES:[DI],BP
	INC	DI
	INC	DI
	MOV	CX,BP
	REP	MOVSB			; 1 byte move.

	JMP	ENDDATA

BYTE1SET:
	POP	SI
	POP	DS
	POP	DI
	POP	ES

	MOV	ES:[DI],WORD PTR ID_image
	INC	DI
	INC	DI
	MOV	ES:[DI],WORD PTR 1
	INC	DI
	INC	DI
	MOVSB			; 1 byte move.
ENDDATA:
	POP	SI
	SUB	SI,4

	MOV	ES:[DI],WORD PTR ID_check
	INC	DI
	INC	DI
	MOVSW
	MOVSW

	MOV	ES:[DI],WORD PTR ID_end
	INC	DI
	INC	DI

	POP	AX		; バッファ先頭
	SUB	DI,AX		; 現在アドレス－バッファ先頭＝圧縮後全長
	MOV	CX,DI		;

	POP	DS
	RET
PLESS	ENDP

;*;DUMP	PROC	NEAR
;*;	PUSH	DS
;*;	PUSH	AX
;*;	PUSH	AX
;*;	MOVX	DS,<SEG DATA>
;*;	POP	AX
;*;	MOV	DBGFLAG_CONSOLE,0		; debug flag console.
;*;	LC	0,DBGLIN
;*;
;*;	PRV "イメージデータ長 AX=",AX
;*;	PRV "リピートデータ長 CX=",CX
;*;
;*;	CMP	DBGLIN,20
;*;	JNB	DUMP_2
;*;	ADD	DBGLIN,2
;*;DUMP_2:
;*;
;*;	MOV	DBGFLAG_CONSOLE,1		; debug flag console.
;*;	POP	AX
;*;	POP	DS
;*;	RET
;*;DUMP	ENDP
;*;
;*;DUMP2	PROC	NEAR
;*;	PUSH	DS
;*;	PUSH	AX
;*;	MOVX	DS,<SEG DATA>
;*;	MOV	DBGFLAG_CONSOLE,0		; debug flag console.
;*;	LC	0,0
;*;	PRV	"XXXXXXXBP=",BP
;*;	MOV	DBGFLAG_CONSOLE,1		; debug flag console.
;*;	POP	AX
;*;	POP	DS
;*;	RET
;*;DUMP2	ENDP

CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	ERROR_4UNPLS			; 高速タイプ圧縮展開エラー

EXTRN	DBGFLAG_CONSOLE:WORD		; debug flag console.

ERROR_4UNPLS	DW	0		; 高速タイプ圧縮展開エラー

BUFFSEG		DW	0		; バッファセグメント
BUFFOFS		DW	0		; ソースバッファオフセット

DBGLIN	DW	1

DATA	ENDS
	END
;
;	end of "DATPL4.ASM"
;
