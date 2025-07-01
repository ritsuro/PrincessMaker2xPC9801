; "PM2.ASM" PC-9801UV11 make by R.H 1992/08/21
;
;	
;	P R I N C E S S   M A K E R   2.
;
;
;
;	run AUTOEXEC.EXE
;
;	FD80:0000h  xxh,xxh,27h,2Ah,xxh		EPSON PC
;	FD80:0000h  EBh,02h,EBH,30h,FAh,33h	NEC PC98
;	F000:FFFEh  xxh				PC/AT
;
; progrram.

MFLAG_PCAT	EQU	1		; PC/AT
MFLAG_PC98	EQU	2		; PC9801

MOVX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	MOV	DEST,AX
	ENDM

PRF	MACRO	MSG
	LOCAL	L1,L2
	JMP	L2
L1	DB	MSG,0
L2:
	MOV	SI,OFFSET L1
	CALL	PRINT
	ENDM

CODE	SEGMENT

	ASSUME	CS:CODE,DS:CODE

	ORG	80H
ARGLINE	LABEL	BYTE		; argument line.
	ORG	100H

START:
	CLI
	MOV	SP,OFFSET STACK_TOP
	STI

	MOV	BX,OFFSET STACK_TOP
	SHR	BX,1
	SHR	BX,1
	SHR	BX,1
	SHR	BX,1
	INC	BX

	PUSH	DS
	POP	ES

	MOV	AH,4AH			; memory block set.
	INT	21H			;


	CALL	MACHINE_CHK		; machine check.


	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	SET_PCAT		;
SET_PC98:
	MOV	PARAMETER[1],'9'
	MOV	PARAMETER[2],'8'
	MOV	PARAMETER[3],'0'
	MOV	PARAMETER[4],'1'
	JMP	SHORT RUN_EXEC
SET_PCAT:
	MOV	PARAMETER[1],'P'
	MOV	PARAMETER[2],'C'
	MOV	PARAMETER[3],'A'
	MOV	PARAMETER[4],'T'
RUN_EXEC:
	PUSH	DS
	POP	ES

	MOV	WORD PTR PARAMETER_BLOCK[0],00H
	MOV	WORD PTR PARAMETER_BLOCK[2],OFFSET PARAMETER
	MOV	WORD PTR PARAMETER_BLOCK[4],DS
	MOV	WORD PTR PARAMETER_BLOCK[6],5CH
	MOV	WORD PTR PARAMETER_BLOCK[8],ES
	MOV	WORD PTR PARAMETER_BLOCK[10],6CH
	MOV	WORD PTR PARAMETER_BLOCK[12],ES

	MOV	DX,OFFSET PATHNAME
	MOV	BX,OFFSET PARAMETER_BLOCK
	MOV	AH,4BH		; exec.
	MOV	AL,00H		;
	INT	21H		;
	JNC	FINALE		;

	CMP	AX,02H
	JE	ERR_NOFILE
	CMP	AX,08H
	JE	ERR_NOMEMORY
	CMP	AX,0AH
	JE	ERR_UP32K
	CMP	AX,0BH
	JE	ERR_MSG_UNKNOWN
ERR_NOFILE:
	MOV	SI,OFFSET MSG_NOFILE
	JMP	PRINTERR
ERR_NOMEMORY:
	MOV	SI,OFFSET MSG_NOMEMORY
	JMP	PRINTERR
ERR_UP32K:
	MOV	SI,OFFSET MSG_UP32K
	JMP	PRINTERR
ERR_MSG_UNKNOWN:
	MOV	SI,OFFSET MSG_UNKNOWN
PRINTERR:
	CALL	PRINT

FINALE:
	MOV	AH,4CH
	MOV	AL,MFLAG_MY		; machine flag.
	INT	21H
	JMP	$

; *********************************************************
;	machine check.
; *********************************************************

MACHINE_CHK	PROC	NEAR
	MOVX	ES,<0FD80H>		; FD80:0000h
	CMP	BYTE PTR ES:[2],27H	; xxh,xxh,27h,2Ah,xxh EPSON PC
	JNE	MACHINE_CHK_2		;
	CMP	BYTE PTR ES:[3],2AH	;
	JNE	MACHINE_CHK_2		;
	JMP	MACHINE_CHK_EPSON	;

MACHINE_CHK_2:
	MOVX	ES,<0FD80H>		; FD80:0000h
					; xxh,xxh,EBH,30h,xxh,xxh NEC PC98
					;(EBh,02h,EBH,30h,FAh,33h)
	CMP	BYTE PTR ES:[2],0EBH	;
	JNE	MACHINE_CHK_3		;
	CMP	BYTE PTR ES:[3],030H	;
	JNE	MACHINE_CHK_3		;
	JMP	MACHINE_CHK_PC98	;

MACHINE_CHK_3:
	MOVX	ES,<0F000H>			; PC/AT
	CMP	BYTE PTR ES:[0FFFEH],0		; machine ID.
	JE	MACHINE_CHK_UNKNOWN		;

MACHINE_CHK_PCAT:
	MOV	MFLAG_MY,MFLAG_PCAT		; PC/AT
	PRF	"machine ID  PC/AT"
	RET
MACHINE_CHK_PC98:
	MOV	MFLAG_MY,MFLAG_PC98		; PC9801
	PRF	"machine PC98"
	RET
MACHINE_CHK_EPSON:
	MOV	MFLAG_MY,MFLAG_PC98		; PC9801
	PRF	"machine EPSON PC"
	RET
MACHINE_CHK_UNKNOWN:
	MOV	MFLAG_MY,MFLAG_PC98		; PC9801
	PRF	"machine NEW98"
	RET
MACHINE_CHK	ENDP


; *********************************************************
;	print.
;	-i- SI : string.
; *********************************************************

PRINT	PROC	NEAR
PRINT_LOOP:				;
	LODSB				;
	CMP	AL,0			;
	JE	PRINT_EXIT		;
	MOV	DL,AL			;
	MOV	AH,06H			; 
	INT	21H			; DOS call.
	JMP	PRINT_LOOP		;
PRINT_EXIT:
	MOV	DL,0DH			;
	MOV	AH,06H			; 
	INT	21H			; DOS call.
	MOV	DL,0AH			;
	MOV	AH,06H			; 
	INT	21H			; DOS call.
	RET
PRINT	ENDP


; *********************************************************
;	data.
; *********************************************************
		EVEN
MFLAG_MY	DB	0,0		; machine flag.

PATHNAME	DB	"AUTOEXEC.EXE",0
PARAMETER	DB	4,"    ",0DH
		EVEN
PARAMETER_BLOCK	DB	14 DUP (0)

MSG_NOFILE	DB "ÉtÉ@ÉCÉã AUTOEXEC.EXE Ç™Ç†ÇËÇ‹ÇπÇÒ",0
MSG_NOMEMORY	DB "ÉÅÉÇÉäÅ[Ç™ë´ÇËÇ‹ÇπÇÒÅAÉhÉâÉCÉoìôÇÇÕÇ∏ÇµÇƒÇ≠ÇæÇ≥Ç¢ÅB",0
MSG_UP32K	DB "Åué¿çsä¬ã´Ç™ÇRÇQÇjÉoÉCÉgà»è„ÅvÇ∆"
		DB "ÇlÇrÅ|ÇcÇnÇrÇ…Ç¢Ç∂ÇﬂÇÁÇÍÇΩ",0
MSG_UNKNOWN	DB "ÅuÇdÇwÇdÇÃÉwÉbÉ_Å[Ç…ïsê≥Ç»èÓïÒÇ†ÇËÅvÇ∆"
		DB "ÇlÇrÅ|ÇcÇnÇrÇ…Ç¢Ç∂ÇﬂÇÁÇÍÇΩ",0

		EVEN
		DW	2000 DUP (?)
STACK_TOP	LABEL	WORD
CODE	ENDS
	END	START
;
;	end of "PM2.ASM"
;
