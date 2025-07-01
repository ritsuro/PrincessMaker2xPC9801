; "COMMAND.ASM" PS55Z/S14 make by R.Hashimoto 1991/09/12
;
;
;	DOS command handle.
;
;
; public subroutine.

INCLUDE	TSTSET.INC

STRING_LEN	EQU	255		; string length.
FLNAME_LEN	EQU	14		; file name length.

MEMORY_LOC_SIZE	EQU	1000H		; memory locate size.


BIGBUF_LOC_SIZE	EQU	0F01H		; big buffer locate size.

TBLEXEC	MACRO	XPATH,CMMDTBL,XPARA
	MOV	WORD PTR XPARA[00H],0
	MOV	AX,CMMDTBL
	MOV	WORD PTR XPARA[02H],AX
	MOV	WORD PTR XPARA[04H],CS
	MOV	WORD PTR XPARA[06H],5CH
	MOV	WORD PTR XPARA[08H],ES
	MOV	WORD PTR XPARA[0AH],6CH
	MOV	WORD PTR XPARA[0CH],ES
	MOV	DX,OFFSET XPATH
	MOV	BX,OFFSET XPARA
	MOV	AL,0
	MOV	AH,4BH
	INT	21H
	ENDM

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	CMMD_SRT	; DOS command handle startup.
PUBLIC	CMMD_END	; DOS command handle end.
PUBLIC	CMMD_CD		; DOS command chenge directory.
PUBLIC	CMMD_MD		; DOS command making directory.
PUBLIC	CMMD_COPYX	; DOS command COPY (file i/o).
PUBLIC	CMMD_DFREE	; DOS command disk free.

EXTRN	MSG_FILE_NOW_COPY:NEAR	; message now copy file.

EXTRN	XCPX:NEAR	; full file copy.

;EXTRN	DISKXLD:NEAR	; disk full load.
;EXTRN	DISKXSV:NEAR	; disk full save.

EXTRN	STRSET:NEAR	; 文字列バッファセット
EXTRN	STRSETZ:NEAR	; 文字列バッファセット
EXTRN	STRFILL:NEAR	; 文字列バッファＦＩＬＬ
EXTRN	STRCLEAR:NEAR	; 文字列バッファクリア
EXTRN	STRZEROC:NEAR	; 文字列バッファ０クリア
EXTRN	STRSETADD:NEAR	; 文字列の連結
EXTRN	STRLENGTH:NEAR	; 文字列長さ
EXTRN	STRLENSPZ:NEAR	; 文字列長さスペースまで


; ****************************************************
;	DOS command handle startup.
;	-O- AX : 0=normal,1=error.
; ****************************************************

CMMD_SRT	PROC	NEAR
	MOVX	ES,DS				; segment address.
	MOV	BX,MEMORY_LOC_SIZE		; memory locate size.
	MOV	AH,4AH				; memory block relocate.
	INT	21H				; DOS call.
	JC	CMMD_SRT_ERROR			;

	CALL	BIG_BUFF_ALLOC			; big buffer allocation.
	CMP	AX,0				; 0=normal,1=error.
	JNE	CMMD_SRT_ERROR2			;

CMMD_SRT_NORMAL:
	MOV	AX,0				; 0=normal.
	RET
CMMD_SRT_ERROR:
	PRVH	"memory locate error=",AX
	MOV	AX,1				; 1=error.
	RET
CMMD_SRT_ERROR2:
	PRF	"memory empty."
	MOV	AX,1				; 1=error.
	RET
CMMD_SRT	ENDP


; ****************************************************
;	DOS command handle end.
; ****************************************************

CMMD_END	PROC	NEAR
	CALL	BIG_BUFF_FREE			; big buffer free.
	CMP	AX,0				; 0=normal,1=error.
	JNE	CMMD_END_ERROR			;
	RET
CMMD_END_ERROR:
	PRF	"memory free error."
	RET
CMMD_END	ENDP


; ****************************************************
;	DOS command chenge directory.
;	-I- SI : directory path.
;	-O- AX : 0=normal,1=error.
; ****************************************************

CMMD_CD	PROC	NEAR
	DEC	SI
CMMD_CD_1:
	INC	SI
	MOV	AL,DS:[SI]
	CMP	AL,' '
	JE	CMMD_CD_1

	CMP	BYTE PTR DS:[SI],' '
	JBE	CMMD_CD_EXIT

	CMP	BYTE PTR DS:[SI][1],':'
	JNE	CMMD_CD_2

	CMP	BYTE PTR DS:[SI][2],' '
	JBE	CMMD_CD_EXIT

CMMD_CD_2:

	MOV	DX,SI				; directory path.
	MOV	AH,3BH				; chenge current directory.
	INT	21H				; DOS call.
	JC	CMMD_CD_ERROR			;
CMMD_CD_EXIT:
	MOV	AX,0				; 0=normal.
	RET
CMMD_CD_ERROR:
	MOV	AX,1				; 1=error.
	RET
CMMD_CD	ENDP


; ****************************************************
;	DOS command making directory.
;	-I- SI : directory path.
;	-O- AX : 0=normal,1=error.
; ****************************************************

CMMD_MD	PROC	NEAR
	DEC	SI
CMMD_MD_1:
	INC	SI
	MOV	AL,DS:[SI]
	CMP	AL,' '
	JE	CMMD_MD_1

	CMP	BYTE PTR DS:[SI],' '
	JBE	CMMD_MD_EXIT

	CMP	BYTE PTR DS:[SI][1],':'
	JNE	CMMD_MD_2

	CMP	BYTE PTR DS:[SI][2],' '
	JBE	CMMD_MD_EXIT

	CMP	BYTE PTR DS:[SI][2],'\'
	JNE	CMMD_MD_2

	CMP	BYTE PTR DS:[SI][3],' '
	JBE	CMMD_MD_EXIT

CMMD_MD_2:
	MOV	DX,SI				; directory path.
	MOV	AH,39H				; making current directory.
	INT	21H				; DOS call.
	JC	CMMD_MD_ERROR			;
CMMD_MD_EXIT:
	MOV	AX,0				; 0=normal.
	RET
CMMD_MD_ERROR:
	MOV	AX,1				; 1=error.
	RET
CMMD_MD	ENDP


; ****************************************************
;	DOS command COPY (file i/o).
;	-I- SI : source directory path.
;	    DI : destination directory path.
;	-O- AX : 0=normal,1=read error,2=write error.
; ****************************************************

CMMD_COPYX	PROC	NEAR
	MOV	PATH_NAME_SOUR,SI	; source directory path.
	MOV	PATH_NAME_DEST,DI	; destination directory path.

	; (1) source path name.		"A:\*.*"

	MOV	SI,PATH_NAME_SOUR	; source directory path.
	MOV	DI,OFFSET ST_ASTR	; "*.* ",0
	MOV	BX,OFFSET STRINGX	; full path string address.
	CALL	DIR_FL_PATH		; dir + filename -> full path.

	; (2) directory file name search. "AUTOEXEC.EXE"

	MOV	DX,OFFSET STRINGX	; path name.
	CALL	FILE_FIRST_SREACH	; file first sreach.
	CMP	AX,0			; 0=normal,1=error.
	JNE	CMMD_COPYX_ERRORREAD	;

CMMD_COPYX_LOOP:

	; (3) source path name.		"A:\AUTOEXEC.EXE"

	MOV	SI,PATH_NAME_SOUR	; source directory path.
	MOV	DI,OFFSET FLNAME	; file path name.
	MOV	BX,OFFSET STRINGX	; full path string address.
	CALL	DIR_FL_PATH		; dir + filename -> full path.

	CALL	SKIP_FILE_CHK		; skip check file.
	CMP	AX,1			; 1=skip file,0=normal.
	JE	CMMD_COPYX_NEXT		;

	; (4) destination path name.	"C:\PM\AUTOEXEC.EXE"

	MOV	SI,PATH_NAME_DEST	; destination directory path.
	MOV	DI,OFFSET FLNAME	; file path name.
	MOV	BX,OFFSET STRINGX2	; full path string address.
	CALL	DIR_FL_PATH		; dir + filename -> full path.

	; (5) file copy.

	CALL	FILE_COPY		; file copy.
	CMP	AX,1			; 1=read error.
	JE	CMMD_COPYX_ERRORREAD	;
	CMP	AX,2			; 2=write error.
	JE	CMMD_COPYX_ERRORWRITE	;

CMMD_COPYX_NEXT:

	; (6) directory file name search next..."MUSYA.COM"

	CALL	FILE_NEXT_SREACH	; file next sreach.
	CMP	AX,0			; 0=normal,1=end.
	JNE	CMMD_COPYX_LOOP_E	;

	JMP	CMMD_COPYX_LOOP		;

CMMD_COPYX_LOOP_E:
	MOV	AX,0			; 0=normal.
	RET
CMMD_COPYX_ERRORREAD:
	MOV	AX,1			; 1=read error.
	RET
CMMD_COPYX_ERRORWRITE:
	MOV	AX,2			; 2=write error.
	RET
CMMD_COPYX	ENDP


; ****************************************************
;	DOS command disk free.
;	-I- SI : directory path.
;	-O- AX : セクタ数／１クラスタ,ドライブが無効のときはFFFFh
;	    BX : 空きクラスタ数
;	    CX : バイト数／１セクタ
;	    DX : クラスタ数／１ドライブ
; ****************************************************

CMMD_DFREE	PROC	NEAR
	MOV	AL,DS:[SI]		; directory path.
	CMP	AL,' '			;
	JBE	CMMD_DFREE_CURRENT	;

	MOV	BL,DS:[SI][1]		; directory path.
	CMP	BL,':'			;
	JNE	CMMD_DFREE_CURRENT	;

	SUB	AL,'A'			;
	INC	AL			;
	MOV	DL,AL			; 1=A:,2=B:...
	JMP	CMMD_DFREE_CHK		;
CMMD_DFREE_CURRENT:
	MOV	DL,0			; 0=カレントドライブ
CMMD_DFREE_CHK:
	MOV	AH,36H			; ディスクの空き容量
	INT	21H			; DOS call.
	RET
CMMD_DFREE	ENDP


; ****************************************************
;	file copy.
;	-I- STRINGX  : source path name.
;	    STRINGX2 : destination path name.
;	-O- AX       : 0=normal,1=read error,2=write error.
; ****************************************************

FILE_COPY	PROC	NEAR
	MOV	SI,OFFSET FLNAME	; file path name.
	CALL	MSG_FILE_NOW_COPY	; message now copy file.

	MOV	SI,OFFSET STRINGX	; source path name.
	MOV	DI,OFFSET STRINGX2	; destination path name.
	MOV	DX,ALLOC_MEM_SEG	; memory alloc segment.

	CALL	XCPX			; full file copy.
	CMP	AX,0			; 0=normal,1=error.
	JNE	FILE_COPY_ERRORREAD	;

FILE_COPY_EXIT:
	MOV	AX,0			; 0=normal.
	RET
FILE_COPY_ERRORREAD:
	MOV	AX,1			; 1=read error.
	RET
FILE_COPY_ERRORWRITE:
	MOV	AX,2			; 2=write error.
	RET
FILE_COPY	ENDP


; ****************************************************
;	dir + filename -> full path.
;	-I- SI      : path.
;	    DI      : filename.
;	    BX      : full path string address.
;	-O- DS:[BX] : path name.
; ****************************************************

DIR_FL_PATH	PROC	NEAR
	MOV	STRINGADRS,BX		; string address.

	PUSH	DI			; filename.

	MOVX	ES,DS			;
	MOV	DI,STRINGADRS		; string address.
	MOV	CX,STRING_LEN		; string length.
	CALL	STRSETZ			; 文字列バッファセット

	MOVX	ES,DS			;
	MOV	DI,STRINGADRS		; string address.
	CALL	STRLENGTH		; 文字列長さ
	MOV	BX,CX			; 表示単語長さ
	DEC	BX			; -1
	ADD	BX,STRINGADRS		; string address.
	CMP	DS:[BX],BYTE PTR '\'	;
	JE	DIR_FL_PATH_2		;
	CMP	DS:[BX],BYTE PTR ':'	;
	JE	DIR_FL_PATH_2		;
	MOV	DS:[BX][1],BYTE PTR '\'	;
	MOV	DS:[BX][2],BYTE PTR 0	;
DIR_FL_PATH_2:				;

	POP	SI			; filename.

	MOV	DI,STRINGADRS		; string address.
	CALL	STRSETADD		; 文字列の連結

	MOVX	ES,DS			;
	MOV	DI,STRINGADRS		; string address.
	CALL	STRLENGTH		; 文字列長さ
	MOV	STRINGCMD,CL		;
	MOV	BX,CX			; 表示単語長さ
	ADD	BX,STRINGADRS		; string address.
	MOV	DS:[BX],BYTE PTR 0	;

	RET
DIR_FL_PATH	ENDP


; ****************************************************
;	file first sreach.
;	-I- DS:DX : file path name.
;	-O- AX    : 0=normal,1=error.
;	    FLNAME: file path name.
; ****************************************************

FILE_FIRST_SREACH	PROC	NEAR
	MOV	CX,0				; search file attribute.
	MOV	AH,4EH				; first path search.
	INT	21H				; dos call.
	JC	FILE_FIRST_SREACH_ERROR		;

	MOVX	ES,DS				;
	MOV	SI,NOW_DTA_ADRS			; now DTA.
	ADD	SI,1EH				; path name offset.
	MOV	DI,OFFSET FLNAME		; file path name.
	MOV	CX,FLNAME_LEN			; file name length.
	CALL	STRSETZ				; 文字列バッファセット

FILE_FIRST_SREACH_EXIT:
	MOV	AX,0				; 0=normal.
	RET
FILE_FIRST_SREACH_ERROR:
	MOV	AX,1				; 1=error.
	RET
FILE_FIRST_SREACH	ENDP


; ****************************************************
;	file next sreach.
;	-O- AX    : 0=normal,1=end.
;	    FLNAME: file path name.
; ****************************************************

FILE_NEXT_SREACH	PROC	NEAR
	MOV	CX,0				; search file attribute.
	MOV	AH,4FH				; next path search.
	INT	21H				; dos call.
	JC	FILE_NEXT_SREACH_END		;

	MOVX	ES,DS				;
	MOV	SI,NOW_DTA_ADRS			; now DTA.
	ADD	SI,1EH				; path name offset.
	MOV	DI,OFFSET FLNAME		; file path name.
	MOV	CX,FLNAME_LEN			; file name length.
	CALL	STRSETZ				; 文字列バッファセット

FILE_NEXT_SREACH_EXIT:
	MOV	AX,0				; 0=normal.
	RET
FILE_NEXT_SREACH_END:
	MOV	AX,1				; 1=end.
	RET
FILE_NEXT_SREACH	ENDP


; ****************************************************
;	big buffer allocation.
;	-O- AX            : 0=normal,1=error.
;	    ALLOC_MEM_SEG : memory alloc segment.
; ****************************************************

BIG_BUFF_ALLOC	PROC	NEAR
	MOV	ALLOC_MEM_SEG,0A000H		; memory alloc segment.

	MOV	BX,BIGBUF_LOC_SIZE		; big buffer locate size.
	MOV	AH,48H				; memory alloc.
	INT	21H				; dos call.
	JC	BIG_BUFF_ALLOC_ERROR		;

	MOV	ALLOC_MEM_SEG,AX		; memory alloc segment.

BIG_BUFF_ALLOC_EXIT:
	MOV	AX,0				; 0=normal.
	RET
BIG_BUFF_ALLOC_ERROR:
	MOV	AX,1				; 1=error.
	RET
BIG_BUFF_ALLOC	ENDP


; ****************************************************
;	big buffer free.
;	-I- ALLOC_MEM_SEG : memory alloc segment.
;	-O- AX            : 0=normal,1=error.
; ****************************************************

BIG_BUFF_FREE	PROC	NEAR
	MOV	ES,ALLOC_MEM_SEG		; memory alloc segment.
	MOV	AH,49H				; memory free.
	INT	21H				; dos call.
	JC	BIG_BUFF_FREE_ERROR		;

BIG_BUFF_FREE_EXIT:
	MOV	AX,0				; 0=normal.
	RET
BIG_BUFF_FREE_ERROR:
	MOV	AX,1				; 1=error.
	RET
BIG_BUFF_FREE	ENDP


; ****************************************************
;	skip check file.
;	-I- FLNAME : file path name.
;	-O- AX     : 1=skip file,0=normal.
; ****************************************************

SKIP_FILE_CHK	PROC	NEAR
	MOVX	ES,DS

	MOV	BX,0				; word pointer.
	MOV	CX,TBL_SKIP_FLMAX		; copy skip file name max.
SKIP_FILE_CHK_LOOP:				;
	MOV	SI,OFFSET FLNAME		; file path name.
	MOV	DI,TBL_SKIP_FLNAME[BX]		; copy skip file name table.
	CALL	STRCMPW				; string compare.(wildcard)
	JC	SKIP_FILE_CHK_SKIPFILE		; cf : on=yes,off=no.
	INC	BX				;
	INC	BX				;
	LOOP	SKIP_FILE_CHK_LOOP		;

SKIP_FILE_CHK_NORMAL:
	MOV	AX,0				; 0=normal.
	RET
SKIP_FILE_CHK_SKIPFILE:
	MOV	AX,1				; 1=skip file.
	RET
SKIP_FILE_CHK	ENDP


; ****************************************************
;	DATA.
; ****************************************************

EXTRN	STRINGX:BYTE			; path name.
EXTRN	STRINGX2:BYTE			; path name.
EXTRN	FLNAME:BYTE			; file path name.

EXTRN	NOW_DTA_ADRS:WORD		; now DTA.

PSP_ADRS	DW	0		; PSP segment address.
ALLOC_MEM_SEG	DW	0		; memory alloc segment.

PATH_NAME_SOUR	DW	0		; source directory path.
PATH_NAME_DEST	DW	0		; destination directory path.

FILE_SIZE_LOW	DW	0		; file size low.
FILE_SIZE_HI	DW	0		; file size hi.

ST_ASTR		DB	"*.* ",0
		EVEN
STRINGADRS	DW	0			; string address.

STRINGCMD	DB	0			; command line length.

TBL_SKIP_FLMAX	DW	4			; copy skip file name max.
TBL_SKIP_FLNAME	DW	SKPFL00,SKPFL01,SKPFL02,SKPFL03
						; copy skip file name table.
SKPFL00	DB	"EXELOAD.SYS",0
SKPFL01	DB	"11110006.?",0
SKPFL02	DB	"PSHELL.EXE",0
SKPFL03	DB	"INSTALL.COM",0

;*;STRINGX	DB	STRING_LEN DUP (0),0,0	; path name.
;*;STRINGX2	DB	STRING_LEN DUP (0),0,0	; path name.
;*;FLNAME	DB	FLNAME_LEN DUP (0),0,0	; file path name.

CODE	ENDS

	END
;
;	end of "COMMAND.ASM"
;
