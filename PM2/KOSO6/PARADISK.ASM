; "PARADISK.ASM" 486/50 make by R.H 1992/06/30
;
;
;	パラメータ編集.
;
;
;
;
;	ワークバッファSEGPARAMWORK:[OFSPARAMWORK]を使用します
;	このバッファはKSTBL.ASMでPLESS:[PLESS_SRT+32780]をさしています
;
;
; public subroutine.

INCLUDE	TSTSET.INC

STRING_LEN 		EQU	255	; string length.

LOAD_DATA_LENGTH	EQU	7000	; load data length.

HEADER_DATA_OFS		EQU	0
HEADER_DATA_LEN		EQU	12

HEADER_SIZE_OFS		EQU	12
HEADER_SIZE_LEN		EQU	2

HEADER_FIRST_NAME_OFS	EQU	12+2
HEADER_FIRST_NAME_LEN	EQU	18

HEADER_FAMILY_NAME_OFS	EQU	12+2+18
HEADER_FAMILY_NAME_LEN	EQU	18

HEADER_CLND_YEAR_OFS	EQU	12+2+18+18
HEADER_CLND_YEAR_LEN	EQU	2

HEADER_CLND_MONTH_OFS	EQU	12+2+18+18+2
HEADER_CLND_MONTH_LEN	EQU	2

HEADER_CLND_WEEK_OFS	EQU	12+2+18+18+2+2
HEADER_CLND_WEEK_LEN	EQU	2

HEADER_CLND_DAY_OFS	EQU	12+2+18+18+2+2+2
HEADER_CLND_DAY_LEN	EQU	2

HEADER_PROFILE_LEN	EQU	     18+18+2+2+2+2
HEADER_ALL_LEN		EQU	12+2+18+18+2+2+2+2


STRS	MACRO	RRR,STRING
	LOCAL	L1
DATA	SEGMENT	PUBLIC	'DATA'
	EVEN
L1	DB	STRING,0
	EVEN
DATA	ENDS
	MOV	RRR,OFFSET L1
	ENDM

BBERROR_FAR	MACRO	NUM
CODE	SEGMENT	PUBLIC	'CODE'
ASSUME	CS:CODE
EXTRN	FAR_BBERRORPR:FAR	; error message.
CODE	ENDS
DATA	SEGMENT	PUBLIC	'DATA'
EXTRN	FLAGERROR:WORD		; error flag.
DATA	ENDS
ASSUME	CS:CODE01
	MOV	FLAGERROR,NUM		; error flag.
	CALL	FAR_BBERRORPR		; error message.
	ENDM

BBERROR	MACRO	NUM
	MOV	FLAGERROR,NUM	; error flag.
	EXTRN	BBERRORPR:NEAR	; error message.
	CALL	BBERRORPR	; error message.
	ENDM

SET_WORD	MACRO	PARAM
	MOV	AX,PARAM
	STOSW
	ENDM

SET_TABLE	MACRO	PARAM,WLENG
	MOV	AX,WLENG
	STOSW
	MOV	SI,PARAM
	MOV	CX,AX
	REP	MOVSW
	ENDM

SET_STRING	MACRO	PARAM,LENG
	MOV	AX,LENG
	STOSW
	MOV	SI,PARAM
	MOV	CX,AX
	REP	MOVSB
	ENDM

LOD_WORD	MACRO	PARAM
	LODSW
	MOV	ES:PARAM,AX
	ENDM

LOD_TABLE	MACRO	PARAM
	LODSW
	MOV	DI,ES:PARAM
	MOV	CX,AX
	REP	MOVSW
	ENDM

LOD_STRING	MACRO	PARAM
	LODSW
	MOV	DI,ES:PARAM
	MOV	CX,AX
	REP	MOVSB
	ENDM

LOD_STRING_CK	MACRO	PARAM
	LOCAL	L1,L2
	LODSW
	CMP	AX,1000
	JNB	L1
	MOV	DI,ES:PARAM
	MOV	CX,AX
	REP	MOVSB
	JMP	L2
L1:
	DEC	SI
	DEC	SI
L2:
	ENDM

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	PDISK_SAVE		; データセーブ
PUBLIC	PDISK_LOAD		; データロード
PUBLIC	PDISK_CHECK		; データチェック

; ****************************************************
;	データセーブ
;	-I- BX : データファイル番号
;	-O- AX : 0=normal,1=error.
; ****************************************************

PDISK_SAVE	PROC	NEAR
	MOV	DAT_NUMBER,BX		; data number.
	CALL	MAKE_FLNAME		; ファイル名

	CALL	AREA_CLEAR		; area clear.

	CALL	PARA_AREA_SAVE		; parameter area save.

	MOV	SI,DAT_FILENM		; data file name.
	MOV	DX,SEGPARAMWORK		; parameter work segment.
	MOV	DI,OFSPARAMWORK		; parameter work offset.
	MOV	CX,SAVE_DATA_LENGTH	; save data length.
	CALLE	DISKSV			; disk save.
	CMP	AX,0			; 0=normal,1=error.
	JNE	PDISK_SAVE_ERROR	;

	MOV	AX,0			; 0=normal.
	RET
PDISK_SAVE_ERROR:
	BBERROR_FAR	101		; error flag.
	MOV	AX,1			; 1=error.
	RET
PDISK_SAVE	ENDP


; ****************************************************
;	データロード
;	-I- BX : データファイル番号
;	-O- AX : 0=normal,1=error,101=file not found.
; ****************************************************

PDISK_LOAD	PROC	NEAR
	MOV	DAT_NUMBER,BX		; data number.
	CALL	MAKE_FLNAME		; ファイル名

	MOV	SI,DAT_FILENM		; data file name.
	CALLE	DISKCK			; disk check.
	CMP	AX,0			; 0=none,1=ok.
	JE	PDISK_LOAD_FILE_NOT_FOUND

	CALL	AREA_CLEAR		; area clear.

	MOV	SI,DAT_FILENM		; data file name.
	MOV	DX,SEGPARAMWORK		; parameter work segment.
	MOV	DI,OFSPARAMWORK		; parameter work offset.
	MOV	CX,LOAD_DATA_LENGTH	; load data length.
	CALLE	DISKLD			; disk load.
	CMP	AX,0			; 0=normal,1=error.
	JNE	PDISK_LOAD_ERROR	;

	CALL	PARA_AREA_LOAD		; parameter area load.

	MOV	AX,0			; 0=normal.
	RET
PDISK_LOAD_FILE_NOT_FOUND:
	MOV	AX,101			; 101=file not found.
	RET
PDISK_LOAD_ERROR:
	BBERROR_FAR	101		; error flag.
	MOV	AX,1			; 1=error.
	RET
PDISK_LOAD	ENDP


; ****************************************************
;	データチェック
;	-I- BX : データファイル番号
;	-O- AX : 0=normal,1=error,101=file not found.
;	    BX : 年
;	    CX : 月
;	    DX : 曜日
;	    SI : 日
;	    DI : 娘の名前 18byte(名前)+2byte+18byte(名字)+2byte.
; ****************************************************

PDISK_CHECK	PROC	NEAR
	MOV	DAT_NUMBER,BX		; data number.
	CALL	MAKE_FLNAME		; ファイル名

	MOV	SI,DAT_FILENM		; data file name.
	CALLE	DISKCK			; disk check.
	CMP	AX,0			; 0=none,1=ok.
	JE	PDISK_CHECK_FILE_NOT_FOUND

	CALL	AREA_CLEAR		; area clear.

	MOV	SI,DAT_FILENM		; data file name.
	MOV	DX,SEGPARAMWORK		; parameter work segment.
	MOV	DI,OFSPARAMWORK		; parameter work offset.
	MOV	CX,LOAD_DATA_LENGTH	; load data length.
	CALLE	DISKLD			; disk load.
	CMP	AX,0			; 0=normal,1=error.
	JNE	PDISK_CHECK_ERROR	;

	MOV	DX,SEGPARAMWORK		; parameter work segment.
	MOV	SI,OFSPARAMWORK		; parameter work offset.
	CALL	HEADER_GET		; header get.

	MOV	BX,HD_YEAR		; 年
	MOV	CX,HD_MONTH		; 月
	MOV	DX,HD_WEEK		; 曜日
	MOV	SI,HD_DAY		; 日
	MOV	DI,OFFSET STR_BUFF	; 文字列バッファ 名前

	MOV	AX,0			; 0=normal.
	RET
PDISK_CHECK_FILE_NOT_FOUND:
	MOV	AX,101			; 101=file not found.
	RET
PDISK_CHECK_ERROR:
	BBERROR_FAR	101		; error flag.
	MOV	AX,1			; 1=error.
	RET
PDISK_CHECK	ENDP


; ****************************************************
;	area clear.
; ****************************************************

AREA_CLEAR	PROC	NEAR
	MOV	ES,SEGPARAMWORK		; parameter work segment.
	MOV	DI,OFSPARAMWORK		; parameter work offset.
	MOV	CX,LOAD_DATA_LENGTH	; load data length.
	MOV	AL,0			;
	REP	STOSB			;
	RET
AREA_CLEAR	ENDP


; ****************************************************
;	ファイル名
;	-I- DAT_NUMBER : data number.
;	-O- DAT_FILENM : data file name.
; ****************************************************

MAKE_FLNAME	PROC	NEAR

	STRS	DI,"F1xx.GNX"

	MOV	DX,DAT_NUMBER		; data number.
	CALL	DECSTR			;
	MOVX	DS:[DI][2],DS:[SI][3]	;"00005"

	MOV	DAT_FILENM,DI		; data file name.
	RET
MAKE_FLNAME	ENDP


; ****************************************************
;	parameter area save.
;	-O- SAVE_DATA_LENGTH : save data length.
; ****************************************************

PARA_AREA_SAVE	PROC	NEAR
	MOV	ES,SEGPARAMWORK		; parameter work segment.
	MOV	DI,OFSPARAMWORK		; parameter work offset.

;	header copy.

	CALL	HEADER_SET		; header set.


;	value parameter block.

	SET_WORD	PARAMTBL_WCOUNT			; table word count.

	MOV	BX,0					; word pointer.
	MOV	CX,PARAMTBL_WCOUNT			; table word count.
PARA_AREA_SAVE_LOOP:					;
	PUSH	CX					;

	SET_TABLE	PARAMTBL_AREA_TOP[BX],PARAMTBL_AREA_WLEN[BX]

	INC	BX					;
	INC	BX					;

	POP	CX					;
	LOOP	PARA_AREA_SAVE_LOOP			;

;	name string parameter block.

	SET_STRING	NAME_FIRST,	NAME_FIRST_LEN	; 名前
	SET_STRING	NAME_FIRST[2],	NAME_FIRST_LEN	;

	SET_STRING	NAME_FAMILY,	NAME_FAMILY_LEN	; 名前(family)
	SET_STRING	NAME_FAMILY[2],	NAME_FAMILY_LEN	;

;	item parameter block.

	SET_WORD	ROOM_PIC			; 部屋の絵

	SET_WORD	DRESS_NUM			; 着衣絵番号

	SET_WORD	DRESS_ICON			; 着衣　ＩＣＯＮ番号
	SET_WORD	DRESS_GOLD			; 着衣　値段
	SET_STRING	DRESS_NAME,ITEM_NAME_LEN	; 着衣　名前 string
	SET_STRING	DRESS_PROG,ITEM_PROG_LEN	; 着衣　効果 string
	SET_STRING	DRESS_HELP,ITEM_HELP_LEN	; 着衣　説明 string

	SET_WORD	EQUIP_ICON			; 装備　ＩＣＯＮ番号
	SET_WORD	EQUIP_GOLD			; 装備　値段
	SET_STRING	EQUIP_NAME,ITEM_NAME_LEN	; 装備　名前 string
	SET_STRING	EQUIP_PROG,ITEM_PROG_LEN	; 装備　効果 string
	SET_STRING	EQUIP_HELP,ITEM_HELP_LEN	; 装備　説明 string

	SET_WORD	ARMS_ICON			; 武器　ＩＣＯＮ番号
	SET_WORD	ARMS_GOLD			; 武器　値段
	SET_STRING	ARMS_NAME,ITEM_NAME_LEN		; 武器　名前 string
	SET_STRING	ARMS_PROG,ITEM_PROG_LEN		; 武器　効果 string
	SET_STRING	ARMS_HELP,ITEM_HELP_LEN		; 武器　説明 string

;	item table parameter block.

	SET_WORD	ITEM_MAX			; 所有アイテム数

	SET_WORD	ITEM_DIM			; 所有最大アイテム数
	MOV	BX,0					; word pointer.
	MOV	CX,ITEM_DIM				; 所有最大アイテム数
PARA_AREA_SAVE_LOOP2:					;
	PUSH	CX					;

	SET_WORD	ITEM_ICON[BX]			; 所有アイテムＩＣＯＮ番号
	SET_WORD	ITEM_GOLD[BX]			; 所有アイテム値段
	SET_WORD	ITEM_ATTR[BX]			; 所有アイテム種別
	SET_STRING	ITEM_NAME[BX],ITEM_NAME_LEN	; 所有アイテム名前 string
	SET_STRING	ITEM_PROG[BX],ITEM_PROG_LEN	; 所有アイテム効果 string
	SET_STRING	ITEM_HELP[BX],ITEM_HELP_LEN	; 所有アイテム説明 string

	INC	BX					;
	INC	BX					;

	POP	CX					;
	LOOP	PARA_AREA_SAVE_LOOP2			;

;	append data.

	SET_STRING	S_HEALTH_CARE,S_HEALTH_CARE_LEN	; 健康管理 string

	SUB	DI,OFSPARAMWORK				; parameter work offset.
	MOV	SAVE_DATA_LENGTH,DI			; save data length.

	RET
PARA_AREA_SAVE	ENDP


; ****************************************************
;	header set.
;	-I- ES:DI : header area.
; ****************************************************

HEADER_SET	PROC	NEAR
	MOV	SI,OFFSET HEADER_DATA	;"PM2/verX.XX",0
	MOV	CX,HEADER_DATA_LEN	; data header length.
	REP	MOVSB			;

	MOV	AX,HEADER_PROFILE_LEN	;
	STOSW				;

	MOV	SI,NAME_FIRST		; 名前
	MOV	CX,HEADER_FIRST_NAME_LEN
	REP	MOVSB			;

	MOV	SI,NAME_FAMILY		; 名前(family)
	MOV	CX,HEADER_FAMILY_NAME_LEN
	REP	MOVSB			;

	MOV	AX,VAL_YEAR		; 年
	STOSW				;
	MOV	AX,VAL_MONTH		; 月
	STOSW				;
	MOV	AX,VAL_WEEK		; 曜日
	STOSW				;
	MOV	AX,VAL_DAY		; 日
	STOSW				;

	RET
HEADER_SET	ENDP


; ****************************************************
;	header get.
;	-I- DX:SI : header area.
; ****************************************************

HEADER_GET	PROC	NEAR
	PUSH	DS

	MOVX	ES,DS
	MOV	DS,DX

	ADD	SI,HEADER_DATA_LEN	; data header length.

	LODSW				; size.

	; 娘の名前 18byte(名前)+2byte+18byte(名字)+2byte.

	MOV	DI,OFFSET STR_BUFF	; 文字列バッファ 名前
	MOV	CX,HEADER_FIRST_NAME_LEN
	REP	MOVSB			;
	MOV	AX,0			; end of string.
	STOSW				;

	MOV	CX,HEADER_FAMILY_NAME_LEN
	REP	MOVSB			;
	MOV	AX,0			; end of string.
	STOSW				;

	LODSW				;
	MOV	ES:HD_YEAR,AX		; 年
	LODSW				;
	MOV	ES:HD_MONTH,AX		; 月
	LODSW				;
	MOV	ES:HD_WEEK,AX		; 曜日
	LODSW				;
	MOV	ES:HD_DAY,AX		; 日

	POP	DS
	RET
HEADER_GET	ENDP


; ****************************************************
;	parameter area load.
; ****************************************************

PARA_AREA_LOAD	PROC	NEAR
	PUSH	DS

	MOV	DX,SEGPARAMWORK		; parameter work segment.
	MOV	SI,OFSPARAMWORK		; parameter work offset.

;*;	MOV	ES,DX
;*;	PRVH	"#",ES:[SI][7]
;*;	PRVH	"#",ES:[SI][9]

	MOVX	ES,DS
	MOV	DS,DX

	MOV	AX,DS:[SI][7]		;
	MOV	BX,DS:[SI][9]		;

	CMP	AX,2E31H		; 01234567890
	JNE	PARA_AREA_LOAD_NEW	;"PM2/ver1.01",0,0  data header.

	CMP	BX,3030H		;
	JE	PARA_AREA_LOAD_101V	;
	CMP	BX,3130H		;
	JE	PARA_AREA_LOAD_101V	;

	JMP	PARA_AREA_LOAD_NEW	;

PARA_AREA_LOAD_101V:
	ADD	SI,12			; ver1.00,ver1.01 data header length.
	JMP	PARA_AREA_LOAD_BLOCK	;

;	header.

PARA_AREA_LOAD_NEW:
	ADD	SI,HEADER_DATA_LEN	; data header length.
	LODSW				;
	ADD	SI,AX			; header length.

;	value parameter block.

PARA_AREA_LOAD_BLOCK:
	LODSW						; table word count.
	MOV	BX,0					; word pointer.
	MOV	CX,AX					; table word count.
PARA_AREA_LOAD_LOOP:					;
	PUSH	CX					;

	LOD_TABLE	PARAMTBL_AREA_TOP[BX]		;

	INC	BX					;
	INC	BX					;

	POP	CX					;
	LOOP	PARA_AREA_LOAD_LOOP			;

;	name string parameter block.

	LOD_STRING	NAME_FIRST			; 名前
	LOD_STRING	NAME_FIRST[2]			;

	LOD_STRING	NAME_FAMILY			; 名前(family)
	LOD_STRING	NAME_FAMILY[2]			;

;	item parameter block.

	LOD_WORD	ROOM_PIC			; 部屋の絵

	LOD_WORD	DRESS_NUM			; 着衣絵番号

	LOD_WORD	DRESS_ICON			; 着衣　ＩＣＯＮ番号
	LOD_WORD	DRESS_GOLD			; 着衣　値段
	LOD_STRING	DRESS_NAME			; 着衣　名前 string
	LOD_STRING	DRESS_PROG			; 着衣　効果 string
	LOD_STRING	DRESS_HELP			; 着衣　説明 string

	LOD_WORD	EQUIP_ICON			; 装備　ＩＣＯＮ番号
	LOD_WORD	EQUIP_GOLD			; 装備　値段
	LOD_STRING	EQUIP_NAME			; 装備　名前 string
	LOD_STRING	EQUIP_PROG			; 装備　効果 string
	LOD_STRING	EQUIP_HELP			; 装備　説明 string

	LOD_WORD	ARMS_ICON			; 武器　ＩＣＯＮ番号
	LOD_WORD	ARMS_GOLD			; 武器　値段
	LOD_STRING	ARMS_NAME			; 武器　名前 string
	LOD_STRING	ARMS_PROG			; 武器　効果 string
	LOD_STRING	ARMS_HELP			; 武器　説明 string

;	item table parameter block.

	LOD_WORD	ITEM_MAX			; 所有アイテム数

	LODSW						; 所有最大アイテム数
	MOV	BX,0					; word pointer.
	MOV	CX,AX					; 所有最大アイテム数
PARA_AREA_LOAD_LOOP2:					;
	PUSH	CX					;

	LOD_WORD	ITEM_ICON[BX]			; 所有アイテムＩＣＯＮ番号
	LOD_WORD	ITEM_GOLD[BX]			; 所有アイテム値段
	LOD_WORD	ITEM_ATTR[BX]			; 所有アイテム種別
	LOD_STRING	ITEM_NAME[BX]			; 所有アイテム名前 string
	LOD_STRING	ITEM_PROG[BX]			; 所有アイテム効果 string
	LOD_STRING	ITEM_HELP[BX]			; 所有アイテム説明 string

	INC	BX					;
	INC	BX					;

	POP	CX					;
	LOOP	PARA_AREA_LOAD_LOOP2			;

;	append data.

	LOD_STRING_CK	S_HEALTH_CARE			; 健康管理 string

PARA_AREA_LOAD_EXIT:
	POP	DS
	RET
PARA_AREA_LOAD	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	SEGPARAMWORK:WORD		; parameter work segment.
EXTRN	OFSPARAMWORK:WORD		; parameter work offset.

EXTRN	VAL_YEAR:WORD			; 年
EXTRN	VAL_MONTH:WORD			; 月
EXTRN	VAL_WEEK:WORD			; 曜日
EXTRN	VAL_DAY:WORD			; 日

EXTRN	PARAMTBL_AREA_TOP:WORD		; table area top.
EXTRN	PARAMTBL_AREA_WLEN:WORD		; table area word len.
EXTRN	PARAMTBL_WCOUNT:WORD		; table word count.

EXTRN	NAME_FIRST_LEN:WORD		; 名前長さ
EXTRN	NAME_FAMILY_LEN:WORD		; 名前長さ(family)

EXTRN	NAME_FIRST:WORD			; 名前
EXTRN	NAME_FAMILY:WORD		; 名前(family)

EXTRN	ITEM_NAME_LEN:WORD		; アイテム名前長さ
EXTRN	ITEM_PROG_LEN:WORD		; アイテム効果長さ
EXTRN	ITEM_HELP_LEN:WORD		; アイテム説明長さ

EXTRN	ROOM_PIC:WORD			; 部屋の絵

EXTRN	DRESS_NUM:WORD			; 着衣絵番号

EXTRN	DRESS_ICON:WORD			; 着衣　ＩＣＯＮ番号
EXTRN	DRESS_GOLD:WORD			; 着衣　値段
EXTRN	DRESS_NAME:WORD			; 着衣　名前 string
EXTRN	DRESS_PROG:WORD			; 着衣　効果 string
EXTRN	DRESS_HELP:WORD			; 着衣　説明 string

EXTRN	EQUIP_ICON:WORD			; 装備　ＩＣＯＮ番号
EXTRN	EQUIP_GOLD:WORD			; 装備　値段
EXTRN	EQUIP_NAME:WORD			; 装備　名前 string
EXTRN	EQUIP_PROG:WORD			; 装備　効果 string
EXTRN	EQUIP_HELP:WORD			; 装備　説明 string

EXTRN	ARMS_ICON:WORD			; 武器　ＩＣＯＮ番号
EXTRN	ARMS_GOLD:WORD			; 武器　値段
EXTRN	ARMS_NAME:WORD			; 武器　名前 string
EXTRN	ARMS_PROG:WORD			; 武器　効果 string
EXTRN	ARMS_HELP:WORD			; 武器　説明 string

EXTRN	ITEM_MAX:WORD			; 所有アイテム数
EXTRN	ITEM_DIM:WORD			; 所有最大アイテム数
EXTRN	ITEM_ICON:WORD			; 所有アイテムＩＣＯＮ番号
EXTRN	ITEM_GOLD:WORD			; 所有アイテム値段
EXTRN	ITEM_ATTR:WORD			; 所有アイテム種別
EXTRN	ITEM_NAME:WORD			; 所有アイテム名前 string
EXTRN	ITEM_PROG:WORD			; 所有アイテム効果 string
EXTRN	ITEM_HELP:WORD			; 所有アイテム説明 string

EXTRN	S_HEALTH_CARE_LEN:WORD		; 健康管理長さ
EXTRN	S_HEALTH_CARE:WORD		; 健康管理 string

EXTRN	STR_BUFF:WORD			; 文字列バッファ
EXTRN	STR_VAL_BUFF:WORD		; 表示値文字列バッファ

SAVE_DATA_LENGTH	DW	0	; save data length.

DAT_NUMBER		DW	0	; data number.
DAT_FILENM		DW	0	; data file name.

HD_YEAR			DW	0	; 年
HD_MONTH		DW	0	; 月
HD_WEEK			DW	0	; 曜日
HD_DAY			DW	0	; 日

		;	 12345678901
HEADER_DATA	DB	"PM2/ver1.02",0,0	; data header.1993/03/02


DATA	ENDS

	END
;
;	end of "PARADISK.ASM"
;
