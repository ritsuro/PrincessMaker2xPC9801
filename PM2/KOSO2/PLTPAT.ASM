; "PLTPAT.ASM" PC-9801UV11 make by R.H 1990/05/11
;	modify 1991/06/22 PS55Z/J14 (code01 gate call)
;
;	パーツバッファからパレットデータを取り出す
;
;	パレットのサイズ (PALET_LEN) に注意すること
;	(DSKPLT.ASMと同様)

;*;INCLUDE	TSTSET.INC

PALET	SEGMENT	PUBLIC	'PALET'

EXTRN	PLTNUM:WORD		; ハードパレットテーブル
EXTRN	PLTOFS:WORD		; パレットアドレステーブル（色相）
EXTRN	PCNOFS:WORD		; パレットアドレステーブル（彩度）
EXTRN	PBROFS:WORD		; パレットアドレステーブル（明度）

PALET	ENDS


CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	C1PLTPAT		; パーツバッファからパレットを取り出す
;*;PUBLIC C1PLTGAT		; パレットをパーツバッファへセットする

EXTRN	PATBPT:NEAR		; バイナリデータ読み出し
;*;EXTRN PATBGT:NEAR		; バイナリデータ書き込み

PALET_LEN	EQU	8*2*6	; パレットのバイト数

; *******************************************
;	パーツバッファからパレットを取り出す
;	-I- CX : パーツ番号
;	    BX : パレットテーブル番号
;	-O- AX : 0=normal, 1=error.
; *******************************************

C1PLTPAT	PROC	NEAR
	PUSH	CX
	PUSH	BX

	MOV	AX,SEG PALET		; パレット用セグメント
	MOV	ES,AX			;
	SHL	BX,1			; dobule word pointer.
	SHL	BX,1			;
	MOV	AX,ES:PLTOFS[BX]	; パレットアドレステーブル（色相）

	MOV	DX,ES			; パレット用セグメント
	MOV	SI,AX			; パレットテーブル先頭
	CALL	PATBPT			; バイナリデータ読み出し

	POP	BX
	POP	CX
	RET
C1PLTPAT	ENDP


;*;; *******************************************
;*;;	パレットをパーツバッファへセットする
;*;;	-I- CX : パーツ番号
;*;;	    BX : パレットテーブル番号
;*;;	-O- AX : 0=normal, 1=error.
;*;; *******************************************
;*;
;*;C1PLTGAT	PROC	NEAR
;*;	PUSH	CX
;*;	PUSH	BX
;*;
;*;	MOV	AX,SEG PALET		; パレット用セグメント
;*;	MOV	ES,AX			;
;*;	SHL	BX,1			; dobule word pointer.
;*;	SHL	BX,1			;
;*;	MOV	AX,ES:PLTOFS[BX]	; パレットアドレステーブル（色相）
;*;
;*;	MOV	DX,ES			; パレット用セグメント
;*;	MOV	SI,AX			; パレットテーブル先頭
;*;	MOV	CX,PALET_LEN		; パレットのバイト数
;*;	CALL	PATBGT			; バイナリデータ書き込み
;*;
;*;	POP	BX
;*;	POP	CX
;*;	RET
;*;C1PLTGAT	ENDP


CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'
DATA	ENDS

	END
;
;	end of "PLTPAT.ASM"
;
