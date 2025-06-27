; "PATTAN.ASM" PC_9801UV11 make by R.H 1992/05/22
;
;
;	絵のデータ
;
;	bank.	data.
;	100	ICON88.PT1
;	101	PALET.PT1
;	102	ICON.PT1 ("child.asm"/call child_process_icon)
;
;
;	bank 102 は child.asm よりロードする。
;
; (C) 1992 ritsurou hashimoto.

DEF_BIN	MACRO	LBLSRT,LBLEND,INCFILE
LBLSRT	LABEL	BYTE
	INCLUDE	INCFILE
LBLEND	LABEL	BYTE
	ENDM

DATBIN	SEGMENT	PUBLIC	'DATBIN'

DEF_BIN	S_ICON88,	E_ICON88,	ICON88.INC
DEF_BIN	S_PALET,	E_PALET,	PALET.INC

DATBIN	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	TBLPAT2MAX		; 組込パターンテーブルレコード数
PUBLIC	TBLPAT2SEG		; 組込パターンセグメントテーブル
PUBLIC	TBLPAT2TOP		; 組込パターン先頭オフセットテーブル
PUBLIC	TBLPAT2END		; 組込パターン終了オフセットテーブル

TBLPAT2MAX	DW	3	; 組込パターンテーブルレコード数
TBLPAT2SEG	LABEL	WORD	; 組込パターンセグメントテーブル
		DW	SEG DATBIN
		DW	SEG DATBIN
		DW	0	;ICON.PT1
TBLPAT2TOP	LABEL	WORD	; 組込パターン先頭オフセットテーブル
		DW	S_ICON88
		DW	S_PALET
		DW	0	;ICON.PT1
TBLPAT2END	LABEL	WORD	; 組込パターン終了オフセットテーブル
		DW	E_ICON88
		DW	E_PALET
		DW	0	;ICON.PT1
DATA	ENDS

	END
;
;	end of "PATTAN.ASM"
;
