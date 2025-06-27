; "FLIBREAD.ASM" PC-9801UV11 make by R.H 1991/12/19
;
;
;	FLIB  r e a d.
;
;
; sub program.

FLENTDIM	EQU	101;140	; file entry max.
FLENT1LEN	EQU	20	; file entry 1 length.
FLENT_NAME_LEN	EQU	12	; file entry file name length.
FLENT_OFS_NAME	EQU	0	; file entry file name.
FLENT_OFS_OFST	EQU	12	; file entry file offset.
FLENT_OFS_LENG	EQU	16	; file entry file length.
FLENT_ENDDATA_L	EQU	6	; file entry end data length.

MOVX	MACRO	DEST,SOU
	MOV	AX,SOU
	MOV	DEST,AX
	ENDM

JMPEQ	MACRO	LBL
	LOCAL	L1
	JNE	L1
	JMP	LBL
L1:
	ENDM

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	FLIBOPEN		; FLIB open.
PUBLIC	FLIB2OPN		; FLIB secand open.
PUBLIC	FLIBREAD		; FLIB read.
PUBLIC	FLIBCLOSR		; FLIB close(read only).

EXTRN	DKOPEN:NEAR		; disk file open.
EXTRN	DKCLOSE:NEAR		; disk file close.
EXTRN	DKREAD:NEAR		; disk file read.
EXTRN	DKSEEK:NEAR		; disk file seek.


; *********************************************************
;	FLIB open.
;	-I- DS:SI : file name.
;	-O- AX    : 0=normal,1=error.
; *********************************************************

FLIBOPEN	PROC	NEAR
	MOV	ENTRYMAX,0			; entry max.

	MOV	DI,OFFSET NOW_FILENAME		; now file name.
	MOV	CX,FLENT_NAME_LEN		; file entry file name length.
	CALL	STRCLEAR			; 文字列バッファクリア

	MOVX	ES,DS				;
	MOV	DI,OFFSET NOW_FILENAME		; now file name.
	MOV	CX,FLENT_NAME_LEN		; file entry file name length.
	CALL	STRSET				; 文字列バッファセット

	MOV	SI,OFFSET NOW_FILENAME		; now file name.
	CALL	DKOPEN				; disk file open.
	CMP	AX,0				; 0=normal,1=open error.
	JNE	FLIBOPEN_ERROR			;

	MOVX	B_HANDLE,FILE_HANDLE		; file handle.

	CALL	ENTRY_READ			; entry read.
	CMP	AX,0				; 0=normal,1=error.
	JNE	FLIBOPEN_ERROR			;

	MOV	AX,0				; 0=normal.
	RET
FLIBOPEN_ERROR:
	MOV	AX,1				; 1=error.
	RET
FLIBOPEN	ENDP


; *********************************************************
;	FLIB secand open.
;	(not entry read)
;	-I- DS:SI : file name.
;	-O- AX    : 0=normal,1=error.
; *********************************************************

FLIB2OPN	PROC	NEAR
	MOV	DI,OFFSET NOW_FILENAME		; now file name.
	CALL	SSTRCMP				; string compare.
	JNC	FLIB2OPN_ALLREAD		;

	MOV	SI,OFFSET NOW_FILENAME		; now file name.
	CALL	DKOPEN				; disk file open.
	CMP	AX,0				; 0=normal,1=open error.
	JNE	FLIB2OPN_ERROR			;

	MOVX	B_HANDLE,FILE_HANDLE		; file handle.

	JMP	FLIB2OPN_EXIT			;
FLIB2OPN_ALLREAD:				;
	CALL	FLIBOPEN			; FLIB open.
	CMP	AX,0				; 0=normal,1=error.
	JNE	FLIB2OPN_ERROR			;
FLIB2OPN_EXIT:
	MOV	AX,0				; 0=normal.
	RET
FLIB2OPN_ERROR:
	MOV	AX,1				; 1=error.
	RET
FLIB2OPN	ENDP


; *********************************************************
;	FLIB read.
;	-I- DS:SI   : read file name.
;	    DX      : buffer segment.
;	    DI      : buffer offset.
;	-O- CX      : now length low.
;	    AX      : 0=normal,1=entry not found,2=error.
; *********************************************************

FLIBREAD	PROC	NEAR
	MOV	FLNAMEADRS,SI			; file name address.
	MOV	BUFFSEG,DX			; buffer segment.
	MOV	BUFFOFS,DI			; buffer offset.

	CALL	ENTRY_SEARCH			; entry search.
	CMP	AX,0				; 0=none,1=find.
	JMPEQ	FLIBREAD_NONE			;

	MOVX	FILE_HANDLE,B_HANDLE		; file handle.

	MOV	CX,NOWPNTHI			; now pointer hi.
	MOV	DX,NOWPNTLOW			; now pointer low.
	MOV	AX,0				; seek mode(0=top,1=now,2=end)
	CALL	DKSEEK				; disk file seek.
	CMP	AX,0				; 0=normal,1=error.
	JNE	FLIBREAD_ERROR			;

	MOV	DX,BUFFSEG			; buffer segment.
	MOV	DI,BUFFOFS			; buffer offset.
	MOV	CX,NOWLENLOW			; now length low.
	CALL	DKREAD				; disk file read.
	CMP	AX,0				; 0=normal,1=error.
	JNE	FLIBREAD_ERROR			;

	MOV	CX,NOWLENLOW			; now length low.
	MOV	AX,0				; 0=normal.
	RET
FLIBREAD_NONE:
	MOV	CX,0				;
	MOV	AX,1				; 1=entry not found.
	RET
FLIBREAD_ERROR:
	MOV	CX,0				;
	MOV	AX,2				; 2=error.
	RET
FLIBREAD	ENDP


; *********************************************************
;	FLIB close(read only).
; *********************************************************

FLIBCLOSR	PROC	NEAR
	MOVX	FILE_HANDLE,B_HANDLE		; file handle.
	CALL	DKCLOSE				; disk file close.
	RET
FLIBCLOSR	ENDP


; *********************************************************
;	entry search.
;	-I- FLNAMEADRS: file name address.
;	-O- AX        : 0=none,1=find.
;	    NOWPNTHI  : now pointer hi.
;	    NOWPNTLOW : now pointer low.
;	    NOWLENHI  : now length hi.
;	    NOWLENLOW : now length low.
; *********************************************************

ENTRY_SEARCH	PROC	NEAR
	MOV	DI,OFFSET STR_BUFF		; 文字列バッファ
	MOV	CX,FLENT_NAME_LEN		; file entry file name length.
	CALL	STRCLEAR			; 文字列バッファクリア

	MOVX	ES,DS				;
	MOV	SI,FLNAMEADRS			; file name address.
	MOV	DI,OFFSET STR_BUFF		; 文字列バッファ
	MOV	CX,FLENT_NAME_LEN		; file entry file name length.
	CALL	STRSET				; 文字列バッファセット

	MOV	ENTRYADRS,(OFFSET ENTRYTABLE)+FLENT_OFS_NAME ; entry address.
	MOVX	ES,DS				;
	MOV	CX,ENTRYMAX			; entry max.
ENTRY_SEARCH_LOOP:
	PUSH	CX
	MOV	SI,OFFSET STR_BUFF		; 文字列バッファ
	MOV	DI,ENTRYADRS			; entry address.
	MOV	CX,FLENT_NAME_LEN		; file entry file name length.
	REPE	CMPSB
	POP	CX
	JE	ENTRY_SEARCH_SCH		; search.

	ADD	ENTRYADRS,FLENT1LEN		; + file entry 1 length.

	LOOP	ENTRY_SEARCH_LOOP

	JMP	ENTRY_SEARCH_NONE

ENTRY_SEARCH_SCH:
	MOV	BX,ENTRYADRS			; file entry 1 length.
	SUB	BX,FLENT_OFS_NAME		; file entry file name.

	MOVX	NOWPNTHI,DS:[BX][FLENT_OFS_OFST][2]	; now pointer hi.
	MOVX	NOWPNTLOW,DS:[BX][FLENT_OFS_OFST]	; now pointer low.

	MOVX	NOWLENHI,DS:[BX][FLENT_OFS_LENG][2]	; now length hi.
	MOVX	NOWLENLOW,DS:[BX][FLENT_OFS_LENG]	; now length low.

ENTRY_SEARCH_EXIT:
	MOV	AX,1			; 1=find.
	RET
ENTRY_SEARCH_NONE:
	MOV	AX,0			; 0=none.
	RET
ENTRY_SEARCH	ENDP


; *********************************************************
;	entry read.
;	-O- AX : 0=normal,1=error.
; *********************************************************

ENTRY_READ	PROC	NEAR
	MOVX	FILE_HANDLE,B_HANDLE		; file handle.

	MOV	CX,0FFFFH			; move offset.
	MOV	DX,FLENT_ENDDATA_L * -1		; move offset.
	MOV	AX,2				; seek mode(0=top,1=now,2=end)
	CALL	DKSEEK				; disk file seek.
	CMP	AX,0				; 0=normal,1=error.
	JNE	ENTRY_READ_ERROR		;

	MOV	DX,DS				;
	MOV	DI,OFFSET ENTRYTABLE		;
	MOV	CX,FLENT_ENDDATA_L		; now length low.
	CALL	DKREAD				; disk file read.
	CMP	AX,0				; 0=normal,1=error.
	JNE	ENTRY_READ_ERROR		;

	MOVX	ENTRYMAX,<WORD PTR ENTRYTABLE>	; entry max.

	MOV	AX,FLENT1LEN			; file entry 1 length.
	MUL	ENTRYMAX			; * entry max.
	MOV	ENTRYLENG,AX			; entry length.
	ADD	AX,FLENT_ENDDATA_L		; file entry end data length.

	NEG	AX				; +/-

	MOV	CX,0FFFFH			; move offset.
	MOV	DX,AX				; move offset.
	MOV	AX,2				; seek mode(0=top,1=now,2=end)
	CALL	DKSEEK				; disk file seek.
	CMP	AX,0				; 0=normal,1=error.
	JNE	ENTRY_READ_ERROR		;

	MOV	DX,DS				;
	MOV	DI,OFFSET ENTRYTABLE		; entry table.
	MOV	CX,ENTRYLENG			; entry length.
	CALL	DKREAD				; disk file read.
	CMP	AX,0				; 0=normal,1=error.
	JNE	ENTRY_READ_ERROR		;

	MOV	AX,0				; 0=normal.
	RET
ENTRY_READ_ERROR:
	MOV	AX,1				; 1=error.
	RET
ENTRY_READ	ENDP


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
;	string compare.
;	-I- SI :source string.
;	    DI :immediate string.
;	-O- cf : on=yes,off=no.
; ***********************************************

SSTRCMP	PROC	NEAR
	PUSH	ES
	PUSH	DI
	PUSH	SI

	PUSH	DS
	POP	ES
SSTRCMP_LOOP:				;
	CMPSB				;
	JNE	SSTRCMP_CHK		; if [si]<>[di] then exit.
	CMP	BYTE PTR [SI][-1],' '	; space.
	JNBE	SSTRCMP_LOOP		; if end-of-string then exit.

SSTRCMP_CHK:
	CMP	BYTE PTR [DI][-1],' '	; space.
	JNBE	SSTRCMP_NO		; no.
	CMP	BYTE PTR [SI][-1],' '	; space.
	JNBE	SSTRCMP_NO		; no.

SSTRCMP_YES:
	STC
	JMP	SSTRCMP_9
SSTRCMP_NO:
	CLC
SSTRCMP_9:
	POP	SI
	POP	DI
	POP	ES
	RET
SSTRCMP	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	FILE_HANDLE:WORD			; file handle.

FLNAMEADRS	DW	0			; file name address.

BUFFSEG		DW	0			; buffer segment.
BUFFOFS		DW	0			; buffer offset.

NOWPNTHI	DW	0			; now pointer hi.
NOWPNTLOW	DW	0			; now pointer low.

NOWLENHI	DW	0			; now length hi.
NOWLENLOW	DW	0			; now length low.

B_HANDLE	DW	0			; big file handle.

NOW_FILENAME	DB	FLENT_NAME_LEN DUP (0),0,0	; now file name.

		EVEN
ENTRYMAX	DW	0			; entry max.
ENTRYADRS	DW	0			; entry address.
ENTRYLENG	DW	0			; entry length.
ENTRYTABLE	DB	FLENTDIM * FLENT1LEN DUP (0)	; entry table.

STR_BUFF	DB	FLENT_NAME_LEN DUP (0),0,0	; string buffer.

DATA	ENDS

	END
;
;	end of "FLIBREAD.ASM"
;
