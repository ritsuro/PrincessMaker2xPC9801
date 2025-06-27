; "FILEIO.ASM" PC-9801UV11 make by R.H 1991/12/21
;
;
;	file i/o.
;
;
; public routine.

DEBUG	EQU	0		; デバックアセンブルフラグ

INCLUDE	TSTSET.INC

EMMCOD	SEGMENT	PUBLIC	'EMMCOD'
	ASSUME	CS:EMMCOD
EXTRN	EMEMCHECK:FAR		; (far)Expanded memory check.
EXTRN	EMEMAREA64K:FAR		; (far)Expanded memory 64k area allocate.
EXTRN	EMEMALLOC:FAR		; (far)Expanded memory allocate.
EXTRN	EMEMDEALLOC:FAR		; (far)Expanded memory deallocate.
EXTRN	EMEMQUICK:FAR		; (far)Expanded memory data name search.
EXTRN	EMEMLOAD:FAR		; (far)Expanded memory data load.
EMMCOD	ENDS

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	FILEREAD		; file read.
PUBLIC	FILEWRITE		; file write.
PUBLIC	FILECHECK		; file check.
PUBLIC	FILEKILL		; file kill.

EXTRN	DKCCHK:NEAR		; ディスクチェンジチェック

EXTRN	FLIBOPEN:NEAR		; FLIB open.
EXTRN	FLIB2OPN:NEAR		; FLIB secand open.
EXTRN	FLIBREAD:NEAR		; FLIB read.
EXTRN	FLIBCLOSR:NEAR		; FLIB close(read only).

EXTRN	DKLOAD:NEAR		; disk load.
EXTRN	DKSAVE:NEAR		; disk save.
EXTRN	DKCHECK:NEAR		; disk check.
EXTRN	DKKILL:NEAR		; disk kill.


; ****************************************************
;	file read.
;	-I- SI : file name.
;	    DX : memory segment address.
;	    DI : memory offset address.
;	    CX : memory size.
;	-O- AX : 0=normal,1=error.
;	    CX : data length.
; ****************************************************

FILEREAD	PROC	NEAR
IF DEBUG
	PRSA	"FLUSER_ADRS=",SI
ENDIF
	MOV	FLUSER_ADRS,SI		; user file name address.
	MOV	MEMORY_SEG,DX		; memory segment address.
	MOV	MEMORY_OFS,DI		; memory offset address.
	MOV	MEMORY_SIZE,CX		; memory size.

	CALL	EMEMQUICK		; Expanded memory data name search.
	CMP	AX,1			; search flag 1=ok,0=undefined.
	JMPEQ	FILEREAD_EMS_READ	;

	MOV	SI,FLUSER_ADRS		; user file name address.
	CALL	DKCCHK			; ディスクチェンジチェック
	CMP	AX,0			; 0=文字列見つかった, 1=見つからない
	JMPNE	FILEREAD_ERROR		;

	MOV	FLNAMEADRS,SI		; 対象ファイル名アドレス
	MOV	LIBNAMEADRS,BX		; ライブラリィ名アドレス

	CMP	BYTE PTR DS:[BX],0	; end of string.
	JMPEQ	FILEREAD_FILEONLY	;

FILEREAD_LIBRARY:
IF DEBUG
	PRSA	"ライブラリィ:",LIBNAMEADRS
	PRSA	"ファイル    :",FLNAMEADRS
ENDIF
	MOV	SI,LIBNAMEADRS		; ライブラリィ名アドレス
	CALL	FLIB2OPN		; FLIB secand open.
	CMP	AX,0			; 0=normal,1=error.
	JMPNE	FILEREAD_ERROR		;

	MOV	ES,MEMORY_SEG		; memory segment address.
	MOV	DI,MEMORY_OFS		; memory offset address.
	MOV	CX,MEMORY_SIZE		; memory size.
	XOR	AL,AL			; AL=0
	REP	STOSB			;

	MOV	DX,MEMORY_SEG		; memory segment address.
	MOV	DI,MEMORY_OFS		; memory offset address.
	MOV	SI,FLNAMEADRS		; 対象ファイル名アドレス
	CALL	FLIBREAD		; FLIB read.
	CMP	AX,0			; 0=normal,1=entry not found,2=error.
	JNE	FILEREAD_ERROR		;
	MOV	DATALENG,CX		; data length.

	CALL	FLIBCLOSR		; FLIB close(read only).

	JMP	FILEREAD_EXIT		;

FILEREAD_FILEONLY:
IF DEBUG
	PRSA	"ファイルのみ   :",FLNAMEADRS
ENDIF
	MOV	SI,FLNAMEADRS		; 対象ファイル名アドレス
	MOV	DX,MEMORY_SEG		; memory segment address.
	MOV	DI,MEMORY_OFS		; memory offset address.
	MOV	CX,MEMORY_SIZE		; memory size.
	CALL	DKLOAD			; disk load.
	CMP	AX,0			; 0=normal,1=error.
	JNE	FILEREAD_ERROR		;

	MOV	DATALENG,CX		; data length.

	JMP	FILEREAD_EXIT		;

FILEREAD_EMS_READ:
IF DEBUG
	PRF	"ＥＭＳ"
ENDIF
	MOV	ES,MEMORY_SEG		; memory segment address.
	MOV	DI,MEMORY_OFS		; memory offset address.
	MOV	CX,MEMORY_SIZE		; memory size.
	XOR	AL,AL			; AL=0
	REP	STOSB			; clear.

	MOV	ES,MEMORY_SEG		; memory segment address.
	MOV	DI,MEMORY_OFS		; memory offset address.
	CALL	EMEMLOAD		; Expanded memory data load.
	MOV	DATALENG,CX		; data length.
	CMP	AX,0			; 0=normal,1=error.
	JNE	FILEREAD_ERROR		;
FILEREAD_EXIT:
	MOV	CX,DATALENG		; data length.
	MOV	AX,0			; 0=normal.
	RET
FILEREAD_ERROR:
	MOV	SI,FLUSER_ADRS		; user file name address.
	CALLE	DSKWID_ERR_MSG		; ディスク・エラーメッセージ
	MOV	CX,0			; data length.
	MOV	AX,1			; 1=error.
	RET
FILEREAD	ENDP


; ****************************************************
;	file write.
;	-I- SI : file name.
;	    DX : memory segment address.
;	    DI : memory offset address.
;	    CX : memory size.
;	-O- AX : 0=normal,1=error.
; ****************************************************

FILEWRITE	PROC	NEAR
	MOV	FLUSER_ADRS,SI		; user file name address.
	MOV	MEMORY_SEG,DX		; memory segment address.
	MOV	MEMORY_OFS,DI		; memory offset address.
	MOV	MEMORY_SIZE,CX		; memory size.

	MOV	SI,FLUSER_ADRS		; user file name address.
	CALL	DKCCHK			; ディスクチェンジチェック
	CMP	AX,0			; 0=文字列見つかった, 1=見つからない
	JNE	FILEWRITE_ERROR		;

	MOV	FLNAMEADRS,SI		; 対象ファイル名アドレス

	MOV	DX,MEMORY_SEG		; memory segment address.
	MOV	DI,MEMORY_OFS		; memory offset address.
	MOV	CX,MEMORY_SIZE		; memory size.
	CALL	DKSAVE			; disk save.
	CMP	AX,0			; 0=normal,1=error.
	JNE	FILEWRITE_ERROR		;

FILEWRITE_EXIT:
	MOV	AX,0			; 0=normal.
	RET
FILEWRITE_ERROR:
	MOV	DX,5			; "ファイルが書き込めません"
	MOV	SI,FLUSER_ADRS		; user file name address.
;*;	CALLC	WIDSYSMES		;WINDOWS/システムメッセージ・ウインドウ
	MOV	AX,1			; 1=error.
	RET
FILEWRITE	ENDP


; ****************************************************
;	file check.
;	-I- SI : file name.
;	-O- AX : 0=none,1=ok.
; ****************************************************

FILECHECK	PROC	NEAR
	MOV	FLUSER_ADRS,SI		; user file name address.

	MOV	SI,FLUSER_ADRS		; user file name address.
	CALL	DKCCHK			; ディスクチェンジチェック
	CMP	AX,0			; 0=文字列見つかった, 1=見つからない
	JNE	FILECHECK_NONE		;

	MOV	FLNAMEADRS,SI		; 対象ファイル名アドレス
	MOV	LIBNAMEADRS,BX		; ライブラリィ名アドレス

	CMP	BYTE PTR DS:[BX],0	; end of string.
	JE	FILECHECK_FILEONLY	;

	JMP	FILECHECK_NONE		;

FILECHECK_FILEONLY:
	MOV	SI,FLNAMEADRS		; 対象ファイル名アドレス
	CALL	DKCHECK			; disk check.
	CMP	AX,0			; 0=none,1=ok.
	JE	FILECHECK_NONE		;
FILECHECK_OK:
	MOV	AX,1			; 1=ok.
	RET
FILECHECK_NONE:
	MOV	AX,0			; 0=none.
	RET
FILECHECK	ENDP


; ****************************************************
;	file kill.
;	-I- SI : file name.
;	-O- AX : 0=normal,1=error.
; ****************************************************

FILEKILL	PROC	NEAR
	CALL	DKCCHK			; ディスクチェンジチェック
	CMP	AX,0			; 0=文字列見つかった, 1=見つからない
	JNE	FILEKILL_ERROR		;

	CALL	DKKILL			; disk kill.
	CMP	AX,0			; 0=normal,1=error.
	JNE	FILEKILL_ERROR		;
FILEKILL_EXIT:
	MOV	AX,0			; 0=normal.
	RET
FILEKILL_ERROR:
	MOV	AX,1			; 1=error.
	RET
FILEKILL	ENDP

CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

FLIB_NUMBER	DW	0	; FLIB number.

FLNAMEADRS	DW	0	; 対象ファイル名アドレス
LIBNAMEADRS	DW	0	; ライブラリィ名アドレス

FLUSER_ADRS	DW	0	; user file name address.

MEMORY_SEG	DW	0	; memory segment address.
MEMORY_OFS	DW	0	; memory offset address.
MEMORY_SIZE	DW	0	; memory size.

DATALENG	DW	0	; data length.

DATA	ENDS

	END
;
;	end of "FILEIO.ASM"
;
