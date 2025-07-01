; "XCPX.ASM" PC9801UV11 make by R.H 1992/01/28
;
;
;	full file copy.
;
;
; public subroutine.
INCLUDE	TSTSET.INC
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

JMPB	MACRO	LBL
	LOCAL	LL
	JNB	LL
	JMP	LBL
LL:
	ENDM

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	XCPX		; full file copy.

EXTRN	MSG_FILE_COPY_MRK_SRT:NEAR	; message file copy mark start.
EXTRN	MSG_FILE_COPY_MARK:NEAR		; message file copy mark.

EXTRN	ERRBOX:NEAR	; fatal error box.

; ****************************************************
;	full file copy.
;	-I- SI : input file name.
;	    DI : output file name.
;	    DX : work memory segment address.
;	-O- AX : 0=normal,1=error.
; ****************************************************

XCPX	PROC	NEAR
	MOV	FILE_I_NM_ADRS,SI	; input file name.
	MOV	FILE_O_NM_ADRS,DI	; output file name.
	MOV	MEMORY_SEG,DX		; work memory segment address.

	CALL	CRTMARK_SRT		; CRT mark start.

	; (1) file open.

	MOV	DX,FILE_I_NM_ADRS	; input file name.
	MOV	AL,0			; read mode.
	MOV	AH,3DH			; open handle.
	INT	21H			; dos call.
	JMPC	XCPX_ERROR_DIR		;
	MOV	FILE_I_HANDLE,AX	; input file handle.

	; (2) file create.

	MOV	DX,FILE_O_NM_ADRS	; output file name.
	MOV	CX,0			; file attribute.
	MOV	AH,3CH			; create handle.
	INT	21H			; dos call.
	JMPC	XCPX_ERRORCLS		;
	MOV	FILE_O_HANDLE,AX	; output file handle.

	; (3) file time stamp get.

	MOV	BX,FILE_I_HANDLE	; input file handle.
	MOV	AL,00H			; mode 00h=get,01h=set.
	MOV	AH,57H			; file date set/get.
	INT	21H			; dos call.
	JMPC	XCPX_ERRORCLS2_FILECLASH

	MOV	XFILE_TIME,CX		; file time.
	MOV	XFILE_DATE,DX		; file date.

	; (4) file size get.

	MOV	BX,FILE_I_HANDLE	; input file handle.
	MOV	AL,2			; 0=top,1=current,2=finale.
	MOV	CX,0			; offset hi.
	MOV	DX,0			; offset low.
	MOV	AH,42H			; handle seek.
	INT	21H			; dos call.
	JMPC	XCPX_ERRORCLS2_FILECLASH

	MOV	FILE_SIZE_LOW,AX	; file size low.
	MOV	FILE_SIZE_HI,DX		; file size hi.
	MOV	MOVE_SIZE_LOW,AX	; move size low.
	MOV	MOVE_SIZE_HI,DX		; move size hi.

	MOV	BX,FILE_I_HANDLE	; input file handle.
	MOV	AL,0			; 0=top,1=current,2=finale.
	MOV	CX,0			; offset hi.
	MOV	DX,0			; offset low.
	MOV	AH,42H			; handle seek.
	INT	21H			; dos call.
	JMPC	XCPX_ERRORCLS2_FILECLASH

	; (5) data copy.

XCPX_LOOP:
	CMP	MOVE_SIZE_HI,0		; move size hi.
	JNE	XCPX_5			;
	CMP	MOVE_SIZE_LOW,0F000H	; move size low.
	JB	XCPX_LOOP_E		;
XCPX_5:

	MOV	CX,0F000H		; full/2 load.
	MOV	BX,FILE_I_HANDLE	; input file handle.
	MOV	DX,0			; dest offset address.
	PUSH	DS			;
	MOVX	DS,MEMORY_SEG		; memory segment address.
	MOV	AH,3FH			; read handle.
	INT	21H			; dos call.
	POP	DS			;
	JMPC	XCPX_ERRORCLS2_FILECLASH

	MOV	CX,0F000H		; full/2 load.
	MOV	BX,FILE_O_HANDLE	; output file handle.
	MOV	DX,0			; dest offset address.
	PUSH	DS			;
	MOVX	DS,MEMORY_SEG		; memory segment address.
	MOV	AH,40H			; write handle.
	INT	21H			; dos call.
	POP	DS			;
	JMPC	XCPX_ERRORCLS2		;
	CMP	AX,0F000H		; full/2 load.
	JMPB	XCPX_ERRORCLS_DISKFULL	;

	SUB	MOVE_SIZE_LOW,0F000H	; move size low.
	SBB	MOVE_SIZE_HI,0		; move size hi.

	CALL	CRTMARK			; CRT mark.

	JMP	XCPX_LOOP		;

XCPX_LOOP_E:
	CMP	MOVE_SIZE_LOW,0		; move size low.
	JE	XCPX_CLOSE		;

	MOV	CX,MOVE_SIZE_LOW	; move size low.
	MOV	BX,FILE_I_HANDLE	; input file handle.
	MOV	DX,0			; dest offset address.
	PUSH	DS			;
	MOVX	DS,MEMORY_SEG		; memory segment address.
	MOV	AH,3FH			; read handle.
	INT	21H			; dos call.
	POP	DS			;
	JMPC	XCPX_ERRORCLS2_FILECLASH

	MOV	CX,MOVE_SIZE_LOW	; move size low.
	MOV	BX,FILE_O_HANDLE	; output file handle.
	MOV	DX,0			; dest offset address.
	PUSH	DS			;
	MOVX	DS,MEMORY_SEG		; memory segment address.
	MOV	AH,40H			; write handle.
	INT	21H			; dos call.
	POP	DS			;
	JC	XCPX_ERRORCLS2		;
	CMP	AX,MOVE_SIZE_LOW	; move size low.
	JB	XCPX_ERRORCLS_DISKFULL	;

	; (5) file close.

XCPX_CLOSE:
	MOV	BX,FILE_I_HANDLE	; input file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.

	MOV	CX,XFILE_TIME		; file time.
	MOV	DX,XFILE_DATE		; file date.
	MOV	BX,FILE_O_HANDLE	; input file handle.
	MOV	AL,01H			; mode 00h=get,01h=set.
	MOV	AH,57H			; file date set/get.
	INT	21H			; dos call.

	MOV	BX,FILE_O_HANDLE	; output file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.

XCPX_EXIT:
	CALL	CRTMARK_END		; CRT mark end.
	MOV	AX,0			; 0=normal
	RET
XCPX_ERROR:
	MOV	AX,1			; 1=error
	RET
XCPX_ERRORCLS:
	MOV	BX,FILE_I_HANDLE	; input file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.
	MOV	AX,1			; 1=error
	RET
XCPX_ERROR_DIR:				; directory clash!
	MOV	AX,1			; 1=directory clash!
	CALL	ERRBOX			; fatal error box.
	MOV	AX,1			; 1=error
	RET
XCPX_ERRORCLS2_FILECLASH:		;
	MOV	AX,2			; 2=file clash!
	CALL	ERRBOX			; fatal error box.
	JMP	XCPX_ERRORCLS2		;

XCPX_ERRORCLS_DISKFULL:
	MOV	AX,3			; 3=disk full.
	CALL	ERRBOX			; fatal error box.
	JMP	XCPX_ERRORCLS2		;

XCPX_ERRORCLS2:
	MOV	BX,FILE_I_HANDLE	; input file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.
	MOV	BX,FILE_O_HANDLE	; output file handle.
	MOV	AH,3EH			; close handle.
	INT	21H			; dos call.
	MOV	AX,1			; 1=error
	RET
XCPX	ENDP


; ****************************************************
;	CRT mark start.
; ****************************************************

CRTMARK_SRT	PROC	NEAR
	CALL	MSG_FILE_COPY_MRK_SRT	; message file copy mark start.
	RET
CRTMARK_SRT	ENDP


; ****************************************************
;	CRT mark.
; ****************************************************

CRTMARK	PROC	NEAR
	MOV	DX,FILE_SIZE_HI		; file size hi.
	MOV	AX,FILE_SIZE_LOW	; file size low.
	MOV	BX,100			;
	DIV	BX			;
	MOV	BX,AX			;

	MOV	DX,MOVE_SIZE_HI		; move size hi.
	MOV	AX,MOVE_SIZE_LOW	; move size low.
	DIV	BX			; AX = file%

	MOV	DX,100
	SUB	DX,AX
	MOV	AX,DX
	CALL	MSG_FILE_COPY_MARK	; message file copy mark.
	RET
CRTMARK	ENDP


; ****************************************************
;	CRT mark end.
; ****************************************************

CRTMARK_END	PROC	NEAR
	MOV	AX,100			; 100%
	CALL	MSG_FILE_COPY_MARK	; message file copy mark.
	RET
CRTMARK_END	ENDP


; ****************************************************
;	DATA.
; ****************************************************

PUBLIC	XFILE_DATE			; file date.
PUBLIC	XFILE_TIME			; file time.

XFILE_DATE	DW	0		; file date.
XFILE_TIME	DW	0		; file time.

FILE_I_NM_ADRS	DW	0		; input file name.
FILE_O_NM_ADRS	DW	0		; output file name.
FILE_I_HANDLE	DW	0		; input file handle.
FILE_O_HANDLE	DW	0		; output file handle.
MEMORY_SEG	DW	0		; memory segment address.
FILE_SIZE_LOW	DW	0		; file size low.
FILE_SIZE_HI	DW	0		; file size hi.
MOVE_SIZE_LOW	DW	0		; move size low.
MOVE_SIZE_HI	DW	0		; move size hi.

CODE	ENDS

	END
;
;	end of "XCPX.ASM"
;
