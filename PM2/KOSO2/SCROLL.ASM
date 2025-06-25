; "SCROLL.ASM"  1991/11/15 PC-9801UV11 make by R.H 1989
;
;
;	SSDES0			; visual data segment plean 0
;	SSDES1			; visual data segment plean 1
;	SSDES2			; visual data segment plean 2
;	SSDES3			; visual data segment plean 3
;	SSDESW			; visual data plean width.
;
; public subroutine.

INCLUDE	TSTSET.INC

SCROLL_TIME	EQU	2	; スクロールタイム

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	SCRLUP			; vram scroll UP.(x=even length)

EXTRN	C1VV_BANK_XCG_DX:NEAR	; vram bank check & chenge.

EXTRN	TMVSET:NEAR		; V-SYNC timer set.
EXTRN	TMVCHK:NEAR		; V-SYNC timer check.
EXTRN	TMVEWT:NEAR		; V-SYNC timer end wait.

;	vram scroll UP.(x=even length)
;	-I- SSDES0-3,W : destination data segment.
;	    VX1,VY1  : source point.
;	    VX2,VY2  : data size.
;	    VY3      : move line.

SCRLUP	PROC	NEAR
	MOV	AX,SCROLL_TIME		; スクロールタイム
	CALL	TMVSET			; V-SYNC timer set.

	MOV	AX,VY1			;
	MUL	SSDESW			; visual data plean width.
	ADD	AX,VX1			; AX = VY1 * PRSWID + VX1
	MOV	BP,AX			;
	ADD	BP,SSDESW		; visual data plean width.
	ADD	BP,SSDESW		; BP = AX + vram width.

	MOV	BX,VX2			; data size x.

	MOV	CX,VY3			; move line.
	INC	CX			;
	SHR	CX,1			;
	CMP	CX,0			;
	JMPEQ	SCRLUP_EXIT		;
	MOV	CNT2,CX			; counter2.

	MOV	CX,VY2			; data size.
	JCXZ	SCRLUP_EXIT		;
	DEC	CX			;
	JZ	SCRLUP_EXIT		;
	MOV	CNT,CX			;

SCRLUP_LOOP:				;
	PUSH	AX			;
	PUSH	BP			;
	PUSH	CNT			;
	CALL	SCROL_WAIT		; スクロールＷＡＩＴ
SCRLUP_LOOP2:				;
	PUSH	DS			;
	PUSH	SSDES0			; visual data segment plean 0
	PUSH	SSDES1			; visual data segment plean 1
	PUSH	SSDES2			; visual data segment plean 2
	PUSH	SSDES3			; visual data segment plean 3

	POP	DX			;
	CALL	C1VV_BANK_XCG_DX	; vram bank check & chenge.
	MOV	ES,DX			;
	MOV	DS,DX			;
	MOV	DI,AX			;
	MOV	SI,BP			;
	MOV	CX,BX			; data size x.
	REP	MOVSB			;

	POP	DX			;
	CALL	C1VV_BANK_XCG_DX	; vram bank check & chenge.
	MOV	ES,DX			;
	MOV	DS,DX			;
	MOV	DI,AX			;
	MOV	SI,BP			;
	MOV	CX,BX			; data size x.
	REP	MOVSB			;

	POP	DX			;
	CALL	C1VV_BANK_XCG_DX	; vram bank check & chenge.
	MOV	ES,DX			;
	MOV	DS,DX			;
	MOV	DI,AX			;
	MOV	SI,BP			;
	MOV	CX,BX			; data size x.
	REP	MOVSB			;

	POP	DX			;
	CALL	C1VV_BANK_XCG_DX	; vram bank check & chenge.
	MOV	ES,DX			;
	MOV	DS,DX			;
	MOV	DI,AX			;
	MOV	SI,BP			;
	MOV	CX,BX			; data size x.
	REP	MOVSB			;

	POP	DS			;
	ADD	AX,SSDESW		; QX + vram width.
	ADD	BP,SSDESW		; BP + vram width.
	DEC	CNT			;
	JNZ	SCRLUP_LOOP2		;

	POP	CNT			;
	POP	BP			;
	POP	AX			;
	DEC	CNT2			; counter2.
	JNZ	SCRLUP_LOOP		;

	CALL	TMVEWT			; V-SYNC timer end wait.
SCRLUP_EXIT:
	RET
SCRLUP	ENDP


;	スクロールＷＡＩＴ

SCROL_WAIT	PROC	NEAR
	PUSH	AX		;
	PUSH	BX		;
	PUSH	DX		;
	PUSH	BP		;
SCROL_WAIT2:			;
	CALL	TMVCHK		; V-SYNC timer check.
	CMP	AX,1		; 0=timer now, 1=timer end.
	JNE	SCROL_WAIT2	;
	MOV	AX,SCROLL_TIME	; スクロールタイム
	CALL	TMVSET		; V-SYNC timer set.
	POP	BP
	POP	DX
	POP	BX
	POP	AX
	RET
SCROL_WAIT	ENDP

CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	SSDES0:WORD		; visual data segment plean 0
EXTRN	SSDES1:WORD		; visual data segment plean 1
EXTRN	SSDES2:WORD		; visual data segment plean 2
EXTRN	SSDES3:WORD		; visual data segment plean 3
EXTRN	SSDESW:WORD		; visual data plean width.

EXTRN	VX1:WORD		; source point x1.
EXTRN	VY1:WORD		; source point y1.
EXTRN	VX2:WORD		; length x2.
EXTRN	VY2:WORD		; length y2.
EXTRN	VX3:WORD		; destination point x3.
EXTRN	VY3:WORD		; destination point y3.

CNT		DW	0	; counter.
CNT2		DW	0	; counter2.

DATA	ENDS

	END
;
;	end of "SCROLL.ASM"
;
