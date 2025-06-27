; "DKLDSV.ASM" PC-9801UV11 make by R.H 1991/10/16
;
;
;	full load & save.
;
;
; public subroutine.

INCLUDE	TSTSET.INC

FLAG_DSKCHG		EQU	1	; use disk chenger.

PATH_NAME_MAXLEN	EQU	40	; file path name max length.

MOVX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	MOV	DEST,AX
	ENDM

JMPC	MACRO	LBL
	LOCAL	LL
	JNC	LL
	JMP	LBL
LL:
	ENDM

ACCESS_ON	MACRO
	MOV	BX,1			; 1=read.
	CALLE	DSKWID_LED		; ディスク・アクセスランプ
	ENDM

ACCESS_ON_WR	MACRO
	MOV	BX,2			; 2=write.
	CALLE	DSKWID_LED		; ディスク・アクセスランプ
	ENDM

ACCESS_OFF	MACRO
	MOV	BX,0			; 0=OFF.
	CALLE	DSKWID_LED		; ディスク・アクセスランプ
	ENDM

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	DISKLD		; disk load.
PUBLIC	DISKSV		; disk save.
PUBLIC	DISKCK		; disk check.
PUBLIC	DISKKI		; disk kill.

PUBLIC	DISKLD_FAR	; disk load.(far)
PUBLIC	DISKSV_FAR	; disk save.(far)

EXTRN	FILEREAD:NEAR	; file read.
EXTRN	FILEWRITE:NEAR	; file write.
EXTRN	FILECHECK:NEAR	; file check.
EXTRN	FILEKILL:NEAR	; file kill.

EXTRN	C1BBDEBUGFILE:NEAR		; filename dump.

; ****************************************************
;	disk load.
;	-I- SI : file name.
;	    DX : memory segment address.
;	    DI : memory offset address.
;	    CX : memory size.
;	-O- AX : 0=normal,1=error.
;	    CX : data length.
; ****************************************************

DISKLD	PROC	NEAR
	MOV	AX,0FFFEH		;
	SUB	AX,DI			; memory offset address.
	CMP	CX,AX			; memory size.
	JB	DISKLD_1		;
	MOV	CX,AX			;
DISKLD_1:				;
	CALL	LASTNAMESET		; last name set.

IF FLAG_DSKCHG				; use disk chenger.
	CALL	FILEREAD		; file read.
	RET
ELSE
	ACCESS_ON

	MOV	READFILELENGTH,0	; read file length.

	MOV	FILE_NAME_ADRS,SI	; file name.
	MOV	MEMORY_SEG,DX		; memory segment address.
	MOV	MEMORY_OFS,DI		; memory offset address.
	MOV	MEMORY_SIZE,CX		; memory size.

;*;	PRVH	"MEMORY_SEG=",MEMORY_SEG
;*;	PRVH	"MEMORY_OFS=",MEMORY_OFS
;*;	PRV	"MEMORY_SIZE=",MEMORY_SIZE

	; (1) file open.

	MOV	DX,FILE_NAME_ADRS	; file name.
	MOV	AL,0			; read mode.
	MOV	AH,3DH			; open handle.
	INT	21H			; dos call.
	JMPC	DISKLD_ERROR		;

	MOV	FILE_HANDLE,AX		; file handle.

	MOV	ES,MEMORY_SEG		; memory segment address.
	MOV	DI,MEMORY_OFS		; memory offset address.
	MOV	CX,MEMORY_SIZE		; memory size.
	MOV	AL,0			;
	REP	STOSB			; clear.

	; (2) file read.

	MOV	CX,MEMORY_SIZE		; memory size.
	MOV	BX,FILE_HANDLE		; file handle.
	MOV	DX,MEMORY_OFS		; memory offset address.
	PUSH	DS			;
	MOVX	DS,MEMORY_SEG		; memory segment address.
	MOV	AH,3FH			; read handle.
	INT	21H			; dos call.
	POP	DS			;
	JC	DISKLD_ERRORCLS		;

	MOV	READFILELENGTH,AX	; read file length.

	; (3) file close.

DISKLD_CLOSE:
	MOV	BX,FILE_HANDLE		; file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.

DISKLD_EXIT:
	ACCESS_OFF
	MOV	AX,0			; 0=normal
	MOV	CX,READFILELENGTH	; read file length.
	RET
DISKLD_ERROR:
	MOV	AX,1			; 1=error
	MOV	CX,READFILELENGTH	; read file length.
	RET
DISKLD_ERRORCLS:
	MOV	BX,FILE_HANDLE		; file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.
	MOV	AX,1			; 1=error
	MOV	CX,READFILELENGTH	; read file length.
	RET
ENDIF
DISKLD	ENDP


; ****************************************************
;	disk save.
;	-I- SI : file name.
;	    DX : memory segment address.
;	    DI : memory offset address.
;	    CX : memory size.
;	-O- AX : 0=normal,1=error.
; ****************************************************

DISKSV	PROC	NEAR
	CALL	LASTNAMESET		; last name set.

IF FLAG_DSKCHG				; use disk chenger.
	CALL	FILEWRITE		; file write.
	RET				;
ELSE
	ACCESS_ON_WR

	MOV	FILE_NAME_ADRS,SI	; file name.
	MOV	MEMORY_SEG,DX		; memory segment address.
	MOV	MEMORY_OFS,DI		; memory offset address.
	MOV	MEMORY_SIZE,CX		; memory size.

	; (1) file create.

	MOV	DX,FILE_NAME_ADRS	; file name.
	MOV	CX,0			; file attribute.
	MOV	AH,3CH			; create handle.
	INT	21H			; dos call.
	JMPC	DISKSV_ERROR		;

	MOV	FILE_HANDLE,AX		; file handle.

	; (2) file write.

	MOV	CX,MEMORY_SIZE		; memory size.
	MOV	BX,FILE_HANDLE		; file handle.
	MOV	DX,MEMORY_OFS		; memory offset address.
	PUSH	DS			;
	MOVX	DS,MEMORY_SEG		; memory segment address.
	MOV	AH,40H			; write handle.
	INT	21H			; dos call.
	POP	DS			;
	JC	DISKSV_ERRORCLS		;

DISKSV_CLOSE:				;

	; (3) file close.

	MOV	BX,FILE_HANDLE		; file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.
	JC	DISKSV_ERROR		;

DISKSV_EXIT:
	ACCESS_OFF
	MOV	AX,0			; 0=normal
	RET
DISKSV_ERROR:
	MOV	AX,1			; 1=error
	RET
DISKSV_ERRORCLS:
	MOV	BX,FILE_HANDLE		; file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.
	MOV	AX,1			; 1=error
	RET
ENDIF
DISKSV	ENDP


; ****************************************************
;	disk check.
;	-I- SI : file name.
;	-O- AX : 0=none,1=ok.
; ****************************************************

DISKCK	PROC	NEAR
	CALL	LASTNAMESET		; last name set.

	MOV	FILE_NAME_ADRS,SI	; file name.

IF FLAG_DSKCHG				; use disk chenger.
	CALL	FILECHECK		; file check.
	RET
ELSE
	; (1) file open.

	MOV	DX,FILE_NAME_ADRS	; file name.
	MOV	AL,0			; read mode.
	MOV	AH,3DH			; open handle.
	INT	21H			; dos call.
	MOV	FILE_HANDLE,AX		; file handle.
	JC	DISKCK_NONE		;
DISKCK_OK:
	MOV	AX,1			; 1=ok.
	JMP	DISKCK_EXIT		;
DISKCK_NONE:
	MOV	AX,0			; 0=none.
;*;	RET				;<=========================
DISKCK_EXIT:
	PUSH	AX			;
	MOV	BX,FILE_HANDLE		; file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.
	POP	AX			;
	RET
ENDIF
DISKCK	ENDP


; ****************************************************
;	disk kill.
;	-I- SI : file name.
;	-O- AX : 0=normal,1=error.
; ****************************************************

DISKKI	PROC	NEAR
	CALL	LASTNAMESET		; last name set.

IF FLAG_DSKCHG				; use disk chenger.
	CALL	FILEKILL		; file kill.
	RET
ELSE
	MOV	FILE_NAME_ADRS,SI	; file name.

	MOV	DX,FILE_NAME_ADRS	; file name.
	MOV	AH,41H			; delete.
	INT	21H			; dos call.
	JC	DISKKI_ERROR		;

DISKKI_EXIT:
	MOV	AX,0			; 0=normal
	RET
DISKKI_ERROR:
	MOV	AX,1			; 1=error
	RET
ENDIF
DISKKI	ENDP


; ****************************************************
;	disk load.(far)
;	-I- SI : file name.
;	    DX : memory segment address.
;	    DI : memory offset address.
;	    CX : memory size.
;	-O- AX : 0=normal,1=error.
; ****************************************************

DISKLD_FAR	PROC	FAR
	CALL	DISKLD		; disk load.
	RET
DISKLD_FAR	ENDP


; ****************************************************
;	disk save.(far)
;	-I- SI : file name.
;	    DX : memory segment address.
;	    DI : memory offset address.
;	    CX : memory size.
;	-O- AX : 0=normal,1=error.
; ****************************************************

DISKSV_FAR	PROC	FAR
	CALL	DISKSV		; disk save.
	RET
DISKSV_FAR	ENDP


; ****************************************************
;	last name set.
;	-I- SI : file name.
; ****************************************************

LASTNAMESET	PROC	NEAR
	PUSH	ES
	PUSH	DI
	PUSH	SI
	PUSH	CX

	CALL	C1BBDEBUGFILE		; filename dump.

	MOVX	ES,DS			;
	MOV	DI,LAST_FILENAME	; last access file name.
	MOV	CX,PATH_NAME_MAXLEN	; file path name max length.
	REP	MOVSB			;

	POP	CX
	POP	SI
	POP	DI
	POP	ES
	RET
LASTNAMESET	ENDP


CODE01	ENDS


; ****************************************************
;	DATA.
; ****************************************************

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	LAST_FILENAME			; last access file name.

FILE_NAME_ADRS	DW	0		; file name.
FILE_HANDLE	DW	0		; file handle.
MEMORY_SEG	DW	0		; memory segment address.
MEMORY_OFS	DW	0		; memory offset address.
MEMORY_SIZE	DW	0		; memory size.

READFILELENGTH	DW	0		; read file length.

LAST_FILENAME	DW	FLNM		; last access file name.
FLNM		DB	PATH_NAME_MAXLEN DUP (0),0,0

DATA	ENDS

	END
;
;	end of "DKLDSV.ASM"
;
