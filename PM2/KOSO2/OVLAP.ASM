; "OVLAP.ASM" PC-9801UV11 make by R.H 1990/05/19
;			modify 1992/08/07 R.H
;
;	オーバラップ
;
;	ＴＩＭＥＲ（ＴＩＭＥＲ．ＡＳＭ）の０を、使用します。
;
;	オーバラップ中に断続的に処理を入れる為のフックを用意しました。
;
;	OVLP_TIME:WORD = オーバラップタイム(標準６)
;
; public subroutine.

;
;	SSDES0			; visual data segment plean 0
;	SSDES1			; visual data segment plean 1
;	SSDES2			; visual data segment plean 2
;	SSDES3			; visual data segment plean 3
;	SSDESW			; visual data plean width.
;
;	SSSOU0			; visual data segment plean 0
;	SSSOU1			; visual data segment plean 1
;	SSSOU2			; visual data segment plean 2
;	SSSOU3			; visual data segment plean 3
;	SSSOUW			; visual data plean width.
;
;	VX1:WORD		; source point x1.
;	VY1:WORD		; source point y1.
;	VX2:WORD		; length x2.
;	VY2:WORD		; length y2.
;	VX3:WORD		; destination point x3.
;	VY3:WORD		; destination point y3.
;
TIME_OL		EQU	6	; オーバラップタイム

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	OVLAP			; オーバラップ

EXTRN	C1VV_BANK_XCG_ES:NEAR	; vram bank check & chenge.(READ/WRITE) ES
EXTRN	C1VV_BANK_PLN_DS:NEAR	; vram bank check & chenge.(READ) DS

EXTRN	TMVSET:NEAR		; V-SYNC timer set.
EXTRN	TMVCHK:NEAR		; V-SYNC timer check.


;	オーバラップ
;	-i- SSSOU0-3,W: source data segment.
;	    SSDES0-3,W: destination data segment.
;	    VX1,VY1   : source point.
;	    VX2,VY2   : data size.
;	    VX3,VY3   : dest point.

OVLAP	PROC	NEAR
	CMP	WORD PTR VX2,0	;
	JZ	OVLAP99		; if vx2=0 or vy2=0 then exit.
	CMP	WORD PTR VY2,0	;
	JZ	OVLAP99		;
	JMP	OVLAP00		;
OVLAP99:			;
	RET			;
OVLAP00:

	MOV	AX,0		; オーバラップタイム初期
	CALL	TMVSET		; V-SYNC timer set.

	MOV	AX,WORD PTR MORG	; mask pattan0.
	MOV	DX,WORD PTR MORG[2]	; mask pattan0.
	MOV	WORD PTR MPAT,AX	; mask pattan0.
	MOV	WORD PTR MPAT[2],DX	; mask pattan0.
	MOV	WORD PTR MPAT2,AX	; mask pattan0.
	MOV	WORD PTR MPAT2[2],DX	; mask pattan0.

	MOV	AX,VY1		;
	MUL	SSSOUW		; visual data plean width.
	MOV	BX,AX		;
	ADD	BX,VX1		;

	MOV	AX,VY3		;
	MUL	SSDESW		; visual data plean width.
	MOV	DX,AX		;
	ADD	DX,VX3		;

	PUSH	DS

	MOV	AX,SSDES0	;
	MOV	SSD0,AX		; visual data segment plean 0
	MOV	AX,SSDES1	;
	MOV	SSD1,AX		; visual data segment plean 1
	MOV	AX,SSDES2	;
	MOV	SSD2,AX		; visual data segment plean 2
	MOV	AX,SSDES3	;
	MOV	SSD3,AX		; visual data segment plean 3

	MOV	AX,SSSOU0	;
	MOV	SSS0,AX		; visual data segment plean 0
	MOV	AX,SSSOU1	;
	MOV	SSS1,AX		; visual data segment plean 1
	MOV	AX,SSSOU2	;
	MOV	SSS2,AX		; visual data segment plean 2
	MOV	AX,SSSOU3	;
	MOV	SSS3,AX		; visual data segment plean 3

	MOV	CX,4		;
OVLAP_LOOP:			;
	PUSH	CX		;

	MOV	CX,4		;
OVLAP_LOOP2:			;
	PUSH	CX		;

	CALL	OVLAP_WAIT	; オーバラップＷＡＩＴ

	MOV	AX,VX2		; x counter.
	MOV	BP,VY2		; y counter.

	PUSH	DS
	PUSH	DX
	PUSH	BX
OVLAP1:
	CMP	BYTE PTR MPAT,0
	JNE	OVLAP11		;
	JMP	OVLAP_SKIP	;
OVLAP11:

	MOV	CX,SEG DATA	; dest.
	MOV	ES,CX		;
	MOV	CX,ES:SSS0	; source.
	MOV	DS,CX		;
	CALL	C1VV_BANK_PLN_DS	; vram bank check & chenge.(READ) DS

	MOV	SI,BX		; source.
	MOV	DI,OFFSET BUFF	; buffer.
	MOV	CX,AX		; x counter.
	PUSH	AX		;
OVLAP_01:			;
	LODSB			;
	AND	AL,ES:MPAT	; mask pattan.
	STOSB			;
	LOOP	OVLAP_01	;
	POP	AX		;

	MOV	CX,SEG DATA	; buffer.
	MOV	DS,CX		;
	MOV	CX,SSD0		; dest.
	MOV	ES,CX		;
	CALL	C1VV_BANK_XCG_ES	; vram bank chk&chng(R/W) ES

	MOV	SI,OFFSET BUFF	; buffer.
	MOV	DI,DX		; dest.
	MOV	CX,AX		; x counter.
	PUSH	AX		;
	MOV	AH,MPAT		; mask pattan.
	NOT	AH		;
OVLAP_02:			;
	MOV	AL,ES:[DI]	;
	AND	AL,AH		; mask.
	OR	AL,DS:[SI]	; put.
	STOSB			;
	INC	SI		;
	LOOP	OVLAP_02	;
	POP	AX		;


	MOV	CX,SEG DATA	; dest.
	MOV	ES,CX		;
	MOV	CX,ES:SSS1	; source.
	MOV	DS,CX		;
	CALL	C1VV_BANK_PLN_DS	; vram bank check & chenge.(READ) DS

	MOV	SI,BX		; source.
	MOV	DI,OFFSET BUFF	; buffer.
	MOV	CX,AX		; x counter.
	PUSH	AX		;
OVLAP_11:			;
	LODSB			;
	AND	AL,ES:MPAT	; mask pattan.
	STOSB			;
	LOOP	OVLAP_11	;
	POP	AX		;

	MOV	CX,SEG DATA	; buffer.
	MOV	DS,CX		;
	MOV	CX,SSD1		; dest.
	MOV	ES,CX		;
	CALL	C1VV_BANK_XCG_ES	; vram bank chk&chng(R/W) ES

	MOV	SI,OFFSET BUFF	; buffer.
	MOV	DI,DX		; dest.
	MOV	CX,AX		; x counter.
	PUSH	AX		;
	MOV	AH,MPAT		; mask pattan.
	NOT	AH		;
OVLAP_12:			;
	MOV	AL,ES:[DI]	;
	AND	AL,AH		; mask.
	OR	AL,DS:[SI]	; put.
	STOSB			;
	INC	SI		;
	LOOP	OVLAP_12	;
	POP	AX		;


	MOV	CX,SEG DATA	; dest.
	MOV	ES,CX		;
	MOV	CX,ES:SSS2	; source.
	MOV	DS,CX		;
	CALL	C1VV_BANK_PLN_DS	; vram bank check & chenge.(READ) DS

	MOV	SI,BX		; source.
	MOV	DI,OFFSET BUFF	; buffer.
	MOV	CX,AX		; x counter.
	PUSH	AX		;
OVLAP_21:			;
	LODSB			;
	AND	AL,ES:MPAT	; mask pattan.
	STOSB			;
	LOOP	OVLAP_21	;
	POP	AX		;

	MOV	CX,SEG DATA	; buffer.
	MOV	DS,CX		;
	MOV	CX,SSD2		; dest.
	MOV	ES,CX		;
	CALL	C1VV_BANK_XCG_ES	; vram bank chk&chng(R/W) ES

	MOV	SI,OFFSET BUFF	; buffer.
	MOV	DI,DX		; dest.
	MOV	CX,AX		; x counter.
	PUSH	AX		;
	MOV	AH,MPAT		; mask pattan.
	NOT	AH		;
OVLAP_22:			;
	MOV	AL,ES:[DI]	;
	AND	AL,AH		; mask.
	OR	AL,DS:[SI]	; put.
	STOSB			;
	INC	SI		;
	LOOP	OVLAP_22	;
	POP	AX		;


	MOV	CX,SEG DATA	; dest.
	MOV	ES,CX		;
	MOV	CX,ES:SSS3	; source.
	MOV	DS,CX		;
	CALL	C1VV_BANK_PLN_DS	; vram bank check & chenge.(READ) DS

	MOV	SI,BX		; source.
	MOV	DI,OFFSET BUFF	; buffer.
	MOV	CX,AX		; x counter.
	PUSH	AX		;
OVLAP_31:			;
	LODSB			;
	AND	AL,ES:MPAT	; mask pattan.
	STOSB			;
	LOOP	OVLAP_31	;
	POP	AX		;

	MOV	CX,SEG DATA	; buffer.
	MOV	DS,CX		;
	MOV	CX,SSD3		; dest.
	MOV	ES,CX		;
	CALL	C1VV_BANK_XCG_ES	; vram bank chk&chng(R/W) ES

	MOV	SI,OFFSET BUFF	; buffer.
	MOV	DI,DX		; dest.
	MOV	CX,AX		; x counter.
	PUSH	AX		;
	MOV	AH,MPAT		; mask pattan.
	NOT	AH		;
OVLAP_32:			;
	MOV	AL,ES:[DI]	;
	AND	AL,AH		; mask.
	OR	AL,DS:[SI]	; put.
	STOSB			;
	INC	SI		;
	LOOP	OVLAP_32	;
	POP	AX		;

OVLAP_SKIP:
	ADD	BX,SSSOUW		; next source.
	ADD	DX,SSDESW		; next dest.

	MOV	CX,SEG DATA		; buffer.
	MOV	DS,CX			;

	MOV	CH,MPAT[0]		;
	MOV	CL,MPAT[1]		; 0 <- 1
	MOV	MPAT[0],CL		;
	MOV	CL,MPAT[2]		; 1 <- 2
	MOV	MPAT[1],CL		;
	MOV	CL,MPAT[3]		; 2 <- 3
	MOV	MPAT[2],CL		;
	MOV	MPAT[3],CH		; 3 <- 0

	ROR	MPAT[0],1		;
	ROR	MPAT[1],1		;
	ROR	MPAT[2],1		;
	ROR	MPAT[3],1		;

	DEC	BP			;
	JZ	OVLAP70			;
	JMP	OVLAP1			; loop next.
OVLAP70:
	POP	BX
	POP	DX
	POP	DS

	MOV	CH,MPAT2[0]		;
	MOV	CL,MPAT2[1]		; 0 <- 1
	MOV	MPAT2[0],CL		;
	MOV	CL,MPAT2[2]		; 1 <- 2
	MOV	MPAT2[1],CL		;
	MOV	CL,MPAT2[3]		; 2 <- 3
	MOV	MPAT2[2],CL		;
	MOV	MPAT2[3],CH		; 3 <- 0

	MOV	CX,WORD PTR MPAT2[0]	;
	MOV	WORD PTR MPAT[0],CX	;
	MOV	CX,WORD PTR MPAT2[2]	;
	MOV	WORD PTR MPAT[2],CX	;

	POP	CX			;
	DEC	CX			;
	JZ	OVLAP71			;
	JMP	OVLAP_LOOP2		;
OVLAP71:

	ROR	MPAT2,1			;


	MOV	CX,WORD PTR MPAT2[0]	;
	MOV	WORD PTR MPAT[0],CX	;
	MOV	CX,WORD PTR MPAT2[2]	;
	MOV	WORD PTR MPAT[2],CX	;

	POP	CX			;
	DEC	CX			;
	JZ	OVLAP72			;
	JMP	OVLAP_LOOP		;
OVLAP72:

OVLAP_EXIT:

	POP	DS
	RET
OVLAP	ENDP



;	オーバラップＷＡＩＴ

OVLAP_WAIT	PROC	NEAR
	PUSH	AX		;
	PUSH	BX		;
	PUSH	DX		;

;*;	CALL	OVLAP_FOCK	; フック
OVLAP_WAIT2:			;
	CALL	TMVCHK		; V-SYNC timer check.
	CMP	AX,1		; 0=timer now, 1=timer end.
	JNE	OVLAP_WAIT2	;
	MOV	AX,OVLP_TIME	; オーバラップタイム
	CALL	TMVSET		; V-SYNC timer set.
	POP	DX
	POP	BX
	POP	AX
	RET
OVLAP_WAIT	ENDP


;*;;	フック
;*;
;*;OVLAP_FOCK	PROC	NEAR
;*;	PUSH	AX
;*;	PUSH	BX
;*;	PUSH	CX
;*;	PUSH	DX
;*;	PUSH	DI
;*;	PUSH	SI
;*;	PUSH	BP
;*;	PUSH	ES
;*;	PUSH	DS
;*;	EXTRN	OVLAP_CALL:NEAR
;*;	CALL	OVLAP_CALL	; オーバラップ断続的処理フック
;*;	POP	DS
;*;	POP	ES
;*;	POP	BP
;*;	POP	SI
;*;	POP	DI
;*;	POP	DX
;*;	POP	CX
;*;	POP	BX
;*;	POP	AX
;*;	RET
;*;OVLAP_FOCK	ENDP

CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	OVLP_TIME		; オーバラップタイム

EXTRN	SSDES0:WORD		; visual data segment plean 0
EXTRN	SSDES1:WORD		; visual data segment plean 1
EXTRN	SSDES2:WORD		; visual data segment plean 2
EXTRN	SSDES3:WORD		; visual data segment plean 3
EXTRN	SSDESW:WORD		; visual data plean width.

EXTRN	SSSOU0:WORD		; visual data segment plean 0
EXTRN	SSSOU1:WORD		; visual data segment plean 1
EXTRN	SSSOU2:WORD		; visual data segment plean 2
EXTRN	SSSOU3:WORD		; visual data segment plean 3
EXTRN	SSSOUW:WORD		; visual data plean width.

EXTRN	VX1:WORD		; source point x1.
EXTRN	VY1:WORD		; source point y1.
EXTRN	VX2:WORD		; length x2.
EXTRN	VY2:WORD		; length y2.
EXTRN	VX3:WORD		; destination point x3.
EXTRN	VY3:WORD		; destination point y3.

	EVEN
SSD0	DW	0		; visual data segment plean 0
SSD1	DW	0		; visual data segment plean 1
SSD2	DW	0		; visual data segment plean 2
SSD3	DW	0		; visual data segment plean 3

SSS0	DW	0		; visual data segment plean 0
SSS1	DW	0		; visual data segment plean 1
SSS2	DW	0		; visual data segment plean 2
SSS3	DW	0		; visual data segment plean 3

OVLP_TIME	DW	TIME_OL	; オーバラップタイム

MORG	DB	10001000B	; mask pattan0.
	DB	00000000B	; mask pattan1.
	DB	00000000B	; mask pattan2.
	DB	00000000B	; mask pattan3.

MPAT	DB	10001000B	; mask pattan0.
	DB	00000000B	; mask pattan1.
	DB	00000000B	; mask pattan2.
	DB	00000000B	; mask pattan3.

MPAT2	DB	10001000B	; mask pattan0.
	DB	00000000B	; mask pattan1.
	DB	00000000B	; mask pattan2.
	DB	00000000B	; mask pattan3.

BUFF	DB	80 DUP (0)	; buffer.

DATA	ENDS

	END
;
;	end of "OVLAP.ASM"
;
