; "DISKREAD.ASM" PC-9801UV11 make by R.H 1991/12/19
;
;
;	disk I/O seek.
;
;
; public subroutine.

INCLUDE	TSTSET.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	DKOPEN		; disk file open.
PUBLIC	DKCLOSE		; disk file close.
PUBLIC	DKREAD		; disk file read.
PUBLIC	DKSEEK		; disk file seek.
PUBLIC	DKLOAD		; disk load.
PUBLIC	DKSAVE		; disk save.
PUBLIC	DKCHECK		; disk check.
PUBLIC	DKKILL		; disk kill.
PUBLIC	DKRESET		; disk reset.

; *********************************************************
;	disk file open.
;	-I- DS:SI : file name.
;	-O- AX    : 0=normal,1=open error.
;	    FILE_HANDLE : file handle.
; *********************************************************

DKOPEN	PROC	NEAR
	MOV	FILE_NAME_ADRS,SI	; file name.

	MOV	DX,FILE_NAME_ADRS	; file name.
	MOV	AL,0			; read mode.
	MOV	AH,3DH			; open handle.
	INT	21H			; dos call.
	MOV	FILE_HANDLE,AX		; file handle.
	JC	DKOPEN_ERROR		;

	MOV	AX,0			; 0=normal.
	RET
DKOPEN_ERROR:
	MOV	AX,1			; 1=open error.
	RET
DKOPEN	ENDP

; *********************************************************
;	disk file close.
;	-I- FILE_HANDLE : file handle.
;	-O- AX    : 0=normal,1=error.
; *********************************************************

DKCLOSE	PROC	NEAR
	MOV	BX,FILE_HANDLE		; file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.
	JC	DKCLOSE_ERROR		;

	MOV	AX,0			; 0=normal.
	RET
DKCLOSE_ERROR:
	MOV	AX,1			; 1=error.
	RET
DKCLOSE	ENDP


; *********************************************************
;	disk file read.
;	-I- DX : memory segment address.
;	    DI : memory offset address.
;	    CX : memory size.
;	    FILE_HANDLE : file handle.
;	-O- AX : 0=normal,1=error.
;	    CX : data length.
; *********************************************************

DKREAD	PROC	NEAR
	MOV	MEMORY_SEG,DX		; memory segment address.
	MOV	MEMORY_OFS,DI		; memory offset address.
	MOV	MEMORY_SIZE,CX		; memory size.

	MOV	ES,MEMORY_SEG		; memory segment address.
	MOV	DI,MEMORY_OFS		; memory offset address.
	MOV	CX,MEMORY_SIZE		; memory size.
	XOR	AL,AL			; AL=0
	REP	STOSB			; clear.

	; file read.

	MOV	CX,MEMORY_SIZE		; memory size.
	MOV	BX,FILE_HANDLE		; file handle.
	MOV	DX,MEMORY_OFS		; memory offset address.
	PUSH	DS			;
	MOVX	DS,MEMORY_SEG		; memory segment address.
	MOV	AH,3FH			; read handle.
	INT	21H			; dos call.
	POP	DS			;
	JC	DKREAD_ERROR		;

	MOV	CX,AX			; data length.

	MOV	AX,0			; 0=normal.
	RET
DKREAD_ERROR:
	MOV	CX,0			; data length.
	MOV	AX,1			; 1=error.
	RET
DKREAD	ENDP


; *********************************************************
;	disk file seek.
;	-I- CX:DX : move offset.
;	    AX    : seek mode(0=top,1=now,2=end)
;	    FILE_HANDLE : file handle.
;	-O- AX    : 0=normal,1=error.
;	    CX:DX : now offset from top.
; *********************************************************

DKSEEK	PROC	NEAR
	MOV	SEEK_MODE,AL		; seek mode(0=top,1=now,2=end)
	MOV	LENG_HI,CX		; length hi word.
	MOV	LENG_LOW,DX		; length low word.

	; seek.

	MOV	CX,LENG_HI		; length hi word.
	MOV	DX,LENG_LOW		; length low word.
	MOV	BX,FILE_HANDLE		; file handle.
	MOV	AH,42H			; lseek.
	MOV	AL,SEEK_MODE		; seek mode(0=top,1=now,2=end)
	INT	21H			; dos call.
	JC	DKSEEK_ERROR		;

	XCHG	AX,DX			; now offset from top.
	MOV	CX,AX			;

	MOV	AX,0			; 0=normal.
	RET
DKSEEK_ERROR:				;
	MOV	AX,1			; 1=error.
	RET
DKSEEK	ENDP


; ****************************************************
;	disk load.
;	-I- DS:SI : file name.
;	    DX : memory segment address.
;	    DI : memory offset address.
;	    CX : memory size.
;	-O- AX : 0=normal,1=error.
;	    CX : data length.
; ****************************************************

DKLOAD	PROC	NEAR
	MOV	AX,0FFFEH		;
	SUB	AX,DI			; memory offset address.
	CMP	CX,AX			; memory size.
	JB	DKLOAD_1		;
	MOV	CX,AX			;
DKLOAD_1:				;
	MOV	DATALENG,0		; data length.

	MOV	FILE_NAME_ADRS,SI	; file name.
	MOV	MEMORY_SEG,DX		; memory segment address.
	MOV	MEMORY_OFS,DI		; memory offset address.
	MOV	MEMORY_SIZE,CX		; memory size.

	; (1) file open.

	MOV	DX,FILE_NAME_ADRS	; file name.
	MOV	AL,0			; read mode.
	MOV	AH,3DH			; open handle.
	INT	21H			; dos call.
	JC	DKLOAD_ERROR		;

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
	JC	DKLOAD_ERRORCLS		;

	MOV	DATALENG,AX		; data length.

	; (3) file close.

DKLOAD_CLOSE:
	MOV	BX,FILE_HANDLE		; file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.

DKLOAD_EXIT:
	MOV	CX,DATALENG		; data length.
	MOV	AX,0			; 0=normal
	RET
DKLOAD_ERROR:
	MOV	CX,DATALENG		; data length.
	MOV	AX,1			; 1=error
	RET
DKLOAD_ERRORCLS:
	MOV	BX,FILE_HANDLE		; file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.
	MOV	CX,DATALENG		; data length.
	MOV	AX,1			; 1=error
	RET
DKLOAD	ENDP


; ****************************************************
;	disk save.
;	-I- SI : file name.
;	    DX : memory segment address.
;	    DI : memory offset address.
;	    CX : memory size.
;	-O- AX : 0=normal,1=error.
; ****************************************************

DKSAVE	PROC	NEAR
	MOV	FILE_NAME_ADRS,SI	; file name.
	MOV	MEMORY_SEG,DX		; memory segment address.
	MOV	MEMORY_OFS,DI		; memory offset address.
	MOV	MEMORY_SIZE,CX		; memory size.

	; (1) file create.

	MOV	DX,FILE_NAME_ADRS	; file name.
	MOV	CX,0			; file attribute.
	MOV	AH,3CH			; create handle.
	INT	21H			; dos call.
	JMPC	DKSAVE_ERROR		;

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
	JC	DKSAVE_ERRORCLS		;
	CMP	AX,MEMORY_SIZE		; memory size.
	JB	DKSAVE_ERRORKILL	;
DKSAVE_CLOSE:				;

	; (3) file close.

	MOV	BX,FILE_HANDLE		; file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.
	JC	DKSAVE_ERROR		;

DKSAVE_EXIT:
	MOV	AX,0			; 0=normal
	RET
DKSAVE_ERROR:
	MOV	AX,1			; 1=error
	RET
DKSAVE_ERRORCLS:
	MOV	BX,FILE_HANDLE		; file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.
	MOV	AX,1			; 1=error
	RET
DKSAVE_ERRORKILL:
	MOV	BX,FILE_HANDLE		; file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.

	MOV	DX,FILE_NAME_ADRS	; file name.
	MOV	AH,41H			; delete.
	INT	21H			; dos call.

	MOV	AX,1			; 1=error
	RET
DKSAVE	ENDP


; ****************************************************
;	disk check.
;	-I- SI : file name.
;	-O- AX : 0=none,1=ok.
; ****************************************************

DKCHECK	PROC	NEAR
	MOV	FILE_NAME_ADRS,SI	; file name.

	; (1) file open.

	MOV	DX,FILE_NAME_ADRS	; file name.
	MOV	AL,0			; read mode.
	MOV	AH,3DH			; open handle.
	INT	21H			; dos call.
	JC	DKCHECK_NONE		;
	MOV	FILE_HANDLE,AX		; file handle.
DKCHECK_OK:
	MOV	BX,FILE_HANDLE		; file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.
	MOV	AX,1			; 1=ok.
	RET
DKCHECK_NONE:
	MOV	AX,0			; 0=none.
	RET
DKCHECK	ENDP


; ****************************************************
;	disk kill.
;	-I- SI : file name.
;	-O- AX : 0=normal,1=error.
; ****************************************************

DKKILL	PROC	NEAR
	MOV	FILE_NAME_ADRS,SI	; file name.

	MOV	DX,FILE_NAME_ADRS	; file name.
	MOV	AH,41H			; delete.
	INT	21H			; dos call.
	JC	DKKILL_ERROR		;

DKKILL_EXIT:
	MOV	AX,0			; 0=normal
	RET
DKKILL_ERROR:
	MOV	AX,1			; 1=error
	RET
DKKILL	ENDP


; *********************************************************
;	disk reset.
; *********************************************************

DKRESET	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	MOV	AH,0DH		; disk reset.
	INT	21H		; dos function.
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET
DKRESET	ENDP

CODE01	ENDS


; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	FILE_HANDLE			; file handle.

FILE_HANDLE	DW	0		; file handle.
FILE_NAME_ADRS	DW	0		; file name.
MEMORY_SEG	DW	0		; memory segment address.
MEMORY_OFS	DW	0		; memory offset address.
MEMORY_SIZE	DW	0		; memory size.
LENG_HI		DW	0		; length hi word.
LENG_LOW	DW	0		; length low word.
SEEK_MODE	DB	0,0		; seek mode(0=top,1=now,2=end)
DATALENG	DW	0		; data length.

DATA	ENDS

	END
;
;	end of "DISKREAD.ASM"
;
