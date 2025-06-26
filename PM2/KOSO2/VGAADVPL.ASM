; "VGAADVPL.ASM" 1989/3/21 R.H  PC-9801UV11 make by R.H 1989
;       modify 1989/12/08 R.H
;	modify 1991/06/22 PS55Z/S14 (code01 gate call)
;	modify 1992/04/09 486/33
;
;	palet handle.
;
;
; public subroutine.

INCLUDE	TSTSET.INC

IN_video_DAC	MACRO	NUM
	JMP	$+2
	MOV	DX,NUM
	IN	AL,DX
	JMP	$+2
	ENDM

OUTvideo_DAC	MACRO	NUM
	JMP	$+2
	MOV	DX,NUM
	OUT	DX,AL
	JMP	$+2
	ENDM

MOVX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	MOV	DEST,AX
	ENDM

DIV100N	MACRO
	LOCAL	L1
	DIV	DIV100
	ENDM

DIV100N2	MACRO
	LOCAL	L1
	DIV	DIV100
	CMP	DX,50
	JL	L1
	INC	AX
L1:
	ENDM

DIV6000N	MACRO
	LOCAL	L1
	DIV	DIV6000
	CMP	DX,30
	JL	L1
	INC	AX
L1:
	ENDM

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	VGASETCLR		; color set.
PUBLIC	VGACLRSET		; color register set.
PUBLIC	VGACLRVSET		; color palet table disply.
PUBLIC	VGACLRHOLD		; color palet disply hold.

PUBLIC	INTCLRVSET		; (far) interactive color palet disply.


;	color set.
;	-i- CLRCDE : color code.
;	    CLRVEW : color.
;	    CLRCNS : contrast.
;	    CLRBRI : brightness.

VGASETCLR	PROC	NEAR
	PUSH	ES
	PUSH	DI
	PUSH	CX

;*;	PRV	"CLRCDE=",CLRCDE
;*;	PRV	"CLRVEW=",CLRVEW
;*;	PRV	"CLRCNS=",CLRCNS
;*;	PRV	"CLRBRI=",CLRBRI

	CALL	CHG2BRG			; chenge BRG.

;*;cmp CLRCDE,2
;*;jne ll2
;*;prv "CBLUE=",CBLUE
;*;prv "CRED =",CRED
;*;prv "CGREEN=",CGREEN
;*;ll2:

	CALL	PALET_TBL_SET		; palet table set.

	MOV	FLAG_VIDEO_DAC_INT,1	; DAC palet table set int flag.

	POP	CX
	POP	DI
	POP	ES
	RET
VGASETCLR	ENDP


;	color register set.
;	-i- CRNUM  : color code.
;	    CBLUE  : blue  value (0-15)
;	    CRED   : red   value (0-15)
;	    CGREEN : green value (0-15)

VGACLRSET	PROC	NEAR
;*;	PR	"NO,B,R,G="
;*;	MOV	DX,CRNUM	; color code.
;*;	CALL	DECSTR
;*;	CALL	PRINT
;*;	PR	","
;*;	MOV	DX,CBLUE	; blue  value (0-15)
;*;	CALL	DECSTR
;*;	CALL	PRINT
;*;	PR	","
;*;	MOV	DX,CRED		; red   value (0-15)
;*;	CALL	DECSTR
;*;	CALL	PRINT
;*;	PR	","
;*;	MOV	DX,CGREEN	; green value (0-15)
;*;	CALL	DECSTR
;*;	CALL	PRINT
;*;	LF

	PUSH	CBLUE			; blue  value (0-15)
	PUSH	CRED			; red   value (0-15)
	PUSH	CGREEN			; green value (0-15)

	INC	CBLUE			; blue  value (0-63)
	INC	CRED			; red   value (0-63)
	INC	CGREEN			; green value (0-63)
	MOV	CL,2			; * 4
	SHL	CBLUE,CL		;
	SHL	CRED,CL			;	15 - > 63
	SHL	CGREEN,CL		;
	DEC	CBLUE			;
	DEC	CRED			;
	DEC	CGREEN			;

	CALL	PALET_TBL_SET		; palet table set.

	MOV	FLAG_VIDEO_DAC_INT,1	; DAC palet table set int flag.

	POP	CGREEN			; green value (0-15)
	POP	CRED			; red   value (0-15)
	POP	CBLUE			; blue  value (0-15)

	RET
VGACLRSET	ENDP


;	chenge BRG.
;	-i- CLRCDE : color code.
;	    CLRVEW : color.
;	    CLRCNS : contrast.
;	    CLRBRI : brightness.
;	-o- CRNUM  : color code.
;	    CBLUE  : blue  value (0-63)
;	    CRED   : red   value (0-63)
;	    CGREEN : green value (0-63)

CHG2BRG	PROC	NEAR
	MOV	AX,UPCOLOR
	MOV	UPPER,AX

	MOV	AX,100
	SUB	AX,CLRCNS	; contrast.
	MUL	UPCOLOR
	DIV100N2
	MOV	UNDER,AX

	MOV	AX,CLRVEW	; color.
	CMP	AX,60
	JL	CHG2BRG_C1
	CMP	AX,120
	JL	CHG2BRG_C2
	CMP	AX,180
	JL	CHG2BRG_C3
	CMP	AX,240
	JL	CHG2BRG_C4
	CMP	AX,300
	JL	CHG2BRG_C5
	JMP	CHG2BRG_C6
CHG2BRG_C1:
	MOV	CX,CLRVEW	; color.
	JMP	CHG2BRG_5
CHG2BRG_C2:
	MOV	CX,120
	SUB	CX,CLRVEW	; color.
	JMP	CHG2BRG_5
CHG2BRG_C3:
	MOV	CX,CLRVEW	; color.
	SUB	CX,120
	JMP	CHG2BRG_5
CHG2BRG_C4:
	MOV	CX,240
	SUB	CX,CLRVEW	; color.
	JMP	CHG2BRG_5
CHG2BRG_C5:
	MOV	CX,CLRVEW	; color.
	SUB	CX,240
	JMP	CHG2BRG_5
CHG2BRG_C6:
	MOV	CX,360
	SUB	CX,CLRVEW	; color.
CHG2BRG_5:
	MOV	AX,CLRCNS	; contrast.
	MUL	CX
	MUL	UPCOLOR
	DIV6000N
	ADD	AX,UNDER
	MOV	SLIDE,AX

	MOV	AX,UPPER
	MUL	CLRBRI		; brightness.
	DIV100N
	MOV	UPPER,AX

	MOV	AX,UNDER
	MUL	CLRBRI		; brightness.
	DIV100N
	MOV	UNDER,AX

	MOV	AX,SLIDE
	MUL	CLRBRI		; brightness.
	DIV100N
	MOV	SLIDE,AX

	MOV	BX,UPPER
	MOV	CX,UNDER
	MOV	DX,SLIDE

	MOV	AX,CLRVEW	; color.
	CMP	AX,60
	JL	CHG2BRG_C1S
	CMP	AX,120
	JL	CHG2BRG_C2S
	CMP	AX,180
	JL	CHG2BRG_C3S
	CMP	AX,240
	JL	CHG2BRG_C4S
	CMP	AX,300
	JL	CHG2BRG_C5S
	JMP	CHG2BRG_C6S
CHG2BRG_C1S:
	MOV	CRED,BX
	MOV	CBLUE,CX
	MOV	CGREEN,DX
	JMP	CHG2BRG_SET
CHG2BRG_C2S:
	MOV	CGREEN,BX
	MOV	CBLUE,CX
	MOV	CRED,DX
	JMP	CHG2BRG_SET
CHG2BRG_C3S:
	MOV	CGREEN,BX
	MOV	CRED,CX
	MOV	CBLUE,DX
	JMP	CHG2BRG_SET
CHG2BRG_C4S:
	MOV	CBLUE,BX
	MOV	CRED,CX
	MOV	CGREEN,DX
	JMP	CHG2BRG_SET
CHG2BRG_C5S:
	MOV	CBLUE,BX
	MOV	CGREEN,CX
	MOV	CRED,DX
	JMP	CHG2BRG_SET
CHG2BRG_C6S:
	MOV	CRED,BX
	MOV	CGREEN,CX
	MOV	CBLUE,DX
	JMP	CHG2BRG_SET
CHG2BRG_SET:

	MOV	AX,CLRCDE		;
	MOV	CRNUM,AX		; CRNUM = CLRCDE

	SHR	CBLUE,1
	SHR	CRED,1
	SHR	CGREEN,1

;*;	PRV	"CBLUE =",CBLUE
;*;	PRV	"CRED  =",CRED
;*;	PRV	"CGREEN=",CGREEN
;*;	PR	"("
;*;	MOV	DX,CRNUM	; color code.
;*;	CALL	DECSTR
;*;	CALL	PRINT
;*;	PR	","
;*;	MOV	DX,CBLUE	; blue  value (0-15)
;*;	CALL	DECSTR
;*;	CALL	PRINT
;*;	PR	","
;*;	MOV	DX,CRED		; red   value (0-15)
;*;	CALL	DECSTR
;*;	CALL	PRINT
;*;	PR	","
;*;	MOV	DX,CGREEN	; green value (0-15)
;*;	CALL	DECSTR
;*;	CALL	PRINT
;*;	PR	")"
;*;	LF

CHG2BRG_EXIT:
	RET
CHG2BRG	ENDP



;	palet table set.
;	-o- CRNUM  : color code.
;	    CBLUE  : blue  value (0-63)
;	    CRED   : red   value (0-63)
;	    CGREEN : green value (0-63)

PALET_TBL_SET	PROC	NEAR
	MOV	BX,CRNUM		; color code.
	MOV	CH,BYTE PTR CGREEN	; green.
	MOV	CL,BYTE PTR CBLUE	; blue.
	MOV	DH,BYTE PTR CRED	; red.

	CMP	CH,64			; GREEN
	JB	PALET_TBL_SET1		;
	MOV	CH,63			;
PALET_TBL_SET1:
	CMP	CL,64			; BLUE
	JB	PALET_TBL_SET2		;
	MOV	CL,63			;
PALET_TBL_SET2:
	CMP	DH,64			; RED
	JB	PALET_TBL_SET3		;
	MOV	DH,63			;
PALET_TBL_SET3:

	MOV	DI,BX			; color code.
	ADD	DI,BX			;
	ADD	DI,BX			; * 3

	PUSH	FLAG_VIDEO_DAC_INT	; DAC palet table set int flag.
	MOV	FLAG_VIDEO_DAC_INT,0	; DAC palet table set int flag.

	MOV	DS:DAC_TABLE[DI],DH	;RED   video DAC color registar table.
	MOV	DS:DAC_TABLE[DI][1],CH	;GREEN video DAC color registar table.
	MOV	DS:DAC_TABLE[DI][2],CL	;BLUE  video DAC color registar table.

	POP	FLAG_VIDEO_DAC_INT	; DAC palet table set int flag.
	RET
PALET_TBL_SET	ENDP


;	color palet disply hold.
;	-I- AX : palet set int hold flag.0=normal,1=hold.

VGACLRHOLD	PROC	NEAR
	AND	AX,1			; mask.
	MOV	FLAG_INT_HOLD,AX	; DAC palet set int hold flag.
	RET
VGACLRHOLD	ENDP


;	(far) interactive color palet disply.

INTCLRVSET	PROC	FAR
	CMP	FLAG_INT_HOLD,1		; DAC palet set int hold flag.
	JE	INTCLRVSET_EXIT		;

	CMP	FLAG_VIDEO_DAC_INT,0	; DAC palet table set int flag.
	JE	INTCLRVSET_EXIT		;

	MOV	FLAG_VIDEO_DAC_INT,0	; DAC palet table set int flag.

	CALL	VGACLRVSET		; color palet table disply.

INTCLRVSET_EXIT:
	RET
INTCLRVSET	ENDP


;	color palet table disply.

VGACLRVSET	PROC	NEAR
	CMP	MODE_ADVPLT,1		; palet i/o mode 0=normal,1=advance.
	JE	CLRVSET_ADVNCE		;

	MOV	AX,SEG DATA		;
	MOV	ES,AX			;
	MOV	DX,OFFSET DAC_TABLE	; video DAC color registar table.

	MOV	BX,0			; top registar number.
	MOV	CX,16			; registar count.

	MOV	AL,12H			; DAC color registar block write.
	MOV	AH,10H			; palet set.
	INT	10H			; video bios.

	RET
CLRVSET_ADVNCE:
	CALL	DAC_DATA_SET		; video DAC palet data set.
	RET
VGACLRVSET	ENDP



PALET_ADRS_WRIT	EQU	03C8H		; palette address (write mode)
PALET_ADRS_READ	EQU	03C7H		; palette address (read mode)
DAC_STATE	EQU	03C7H		; DAC state
PALET_DATA	EQU	03C9H		; palette data.
PEL_MASK	EQU	03C6H		; PEL mask.


;	video DAC palet data set.

DAC_DATA_SET	PROC	NEAR
	MOV	AX,DS
	MOV	ES,AX
	MOV	SI,OFFSET DAC_TABLE	; video DAC color registar table.
	MOV	DI,OFFSET DAC_TABLE_BAK	; video DAC color registar backup.

	MOV	BL,0			; palette registar number.
	MOV	CX,16			; 16 count.
DAC_DATA_SET_LOOP:
	MOV	AX,DS:[SI]		;
	CMP	AX,DS:[DI]		;
	JNE	DAC_DATA_SET_SET	;
	MOV	AL,DS:[SI][2]		;
	CMP	AL,DS:[DI][2]		;
	JNE	DAC_DATA_SET_SET	;
	ADD	SI,3
	ADD	DI,3
	JMP	DAC_DATA_SET_NEXT
DAC_DATA_SET_SET:
	MOV	AL,BL			; palette registar number.
	OUTvideo_DAC	PALET_ADRS_WRIT	; palette address (write mode)
	CLI				; int disable.
	LODSB				; palet data.
	STOSB				;
	OUTvideo_DAC	PALET_DATA	; palette data.
	LODSB				; palet data.
	STOSB				;
	OUTvideo_DAC	PALET_DATA	; palette data.
	LODSB				; palet data.
	STOSB				;
	OUTvideo_DAC	PALET_DATA	; palette data.
	STI				; int enable.
DAC_DATA_SET_NEXT:
	INC	BL
	LOOP	DAC_DATA_SET_LOOP

	RET
DAC_DATA_SET	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	MODE_ADVPLT		; palet i/o mode 0=normal,1=advance.
MODE_ADVPLT	DW	1	; palet i/o mode 0=normal,1=advance.

EXTRN	CLRCDE:WORD	; color code.
EXTRN	CLRVEW:WORD	; color view.
EXTRN	CLRCNS:WORD	; contrast.
EXTRN	CLRBRI:WORD	; brightness.

EXTRN	CRNUM:WORD	; color code.       
EXTRN	CBLUE:WORD	; blue  value (0-15)
EXTRN	CRED:WORD	; red   value (0-15)
EXTRN	CGREEN:WORD	; green value (0-15)

UPPER		DW	0	;
UNDER		DW	0	;
SLIDE		DW	0	;

DIV100		DW	100	;
DIV6000		DW	6000	;
UPCOLOR		DW	07FH	;
;;UPCOLOR	DW	03FH	;

FLAG_INT_HOLD		DW	0	; DAC palet set int hold flag.
FLAG_VIDEO_DAC_INT	DW	0	; DAC palet table set int flag.

DAC_TABLE	LABEL	BYTE	; video DAC color registar table.
	DB	0,0,0		; 0
	DB	0,0,0		; 1
	DB	0,0,0		; 2
	DB	0,0,0		; 3
	DB	0,0,0		; 4
	DB	0,0,0		; 5
	DB	0,0,0		; 6
	DB	0,0,0		; 7
	DB	0,0,0		; 8
	DB	0,0,0		; 9
	DB	0,0,0		; 10
	DB	0,0,0		; 11
	DB	0,0,0		; 12
	DB	0,0,0		; 13
	DB	0,0,0		; 14
	DB	0,0,0		; 15

DAC_TABLE_BAK	LABEL	BYTE	; video DAC color registar backup.
	DB	0,0,0		; 0
	DB	0,0,0		; 1
	DB	0,0,0		; 2
	DB	0,0,0		; 3
	DB	0,0,0		; 4
	DB	0,0,0		; 5
	DB	0,0,0		; 6
	DB	0,0,0		; 7
	DB	0,0,0		; 8
	DB	0,0,0		; 9
	DB	0,0,0		; 10
	DB	0,0,0		; 11
	DB	0,0,0		; 12
	DB	0,0,0		; 13
	DB	0,0,0		; 14
	DB	0,0,0		; 15

DATA	ENDS

	END
;
;	end of "VGAADVPL.ASM"
;
