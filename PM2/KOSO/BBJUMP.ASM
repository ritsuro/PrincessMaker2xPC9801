; "BBJUMP.ASM" PC-9801UV11 make by R.H 1991/10/08
;
;
;	princess  B A S I C    j u m p.
;
;
; basic shell.

INCLUDE	TSTSETC.INC
INCLUDE	BBEXTRN.INC

DEBUG	EQU	0

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:DATA

PUBLIC	BBJPGET			; jump label get.
PUBLIC	BBJP_TABLESCH		; jump table search.

PUBLIC	TEXTSTACKCLR		; text stack clear.
PUBLIC	TEXTPUSH		; text stack push.
PUBLIC	TEXTPOP			; text stack pop.

EXTRN	BBSYMBGET:NEAR		; シンボル取得


; *********************************************************
;	jump label get.
;	-I- TEXTPSEG      : text segment pointer.
;	    TEXTPSTARTOFS : text start offset.
;	    TEXTPLEN      : text length.
;	    JMPTBLSEG     : jump label table segment.
;	    JMPTBLOFS     : jump label table offset.
;	    JMPADTBLSEG   : jump adrs table segment.
;	    JMPADTBLOFS   : jump adrs table offset.
;	-O- JMPTBLSEG:[JMPTBLOFS] : jump label table.
;	    JMPTBLDLEN    : jump table data length.
;	    JMPADTBLSEG:[JMPADTBLOFS] : jump adrs table offset.
;	    TEXTPOFS      : text offset pointer.
;
;	jump table.		JMPTBLSEG:[JMPTBLOFS]
;				+0 [ symbol length = 5 ]
;				+1 [	S	]1
;				+2 [	U	]2
;				+3 [	B	]3
;				+4 [	0	]4
;				+5 [	1	]5
;				+6 [ symbol length = 4 ]
;				+7 [	A	]1
;				+8 [	B	]2
;				+9 [	S	]3
;				+10[	2	]4
;					...
;
;	jump address table.	JMPADTBLSEG:[JMPADTBLOFS]
;				+0 [ (label address "SUB01" ) ]
;				+2 [ (label address "ABS2"  ) ]
;					...
;
; *********************************************************

BBJPGET	PROC	NEAR
;*;	PRV	"TEXTPLEN=",TEXTPLEN	; text length.

	MOV	JMPTBLDLEN,0		; jump table data length.
	MOV	JMPADTBLCNT,0		; jump adrs table count.

	MOVX	TEXTPOFS,TEXTPSTARTOFS	; text start offset.
	MOVX	SCH_LEN,TEXTPLEN	; text length.

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset pointer.
	INC	TEXTPOFS		; text offset pointer.+1
	DEC	SCH_LEN			; text length.-1

	MOV	AL,ES:[DI]		; get 1 char.
	CMP	AL,MARKLABEL		; label mark.
	JE	BBJPGET_SET		;

BBJPGET_LOOP:				;
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset pointer.
	MOV	AL,MARKLABEL		; label mark.
	MOV	CX,SCH_LEN		; text length.
BBJPGET_LOOP2:				;
	CMP	CX,0			;
	JMPEQ	BBJPGET_EXIT		;
	REPNE	SCASB			;
	JMPNE	BBJPGET_EXIT		;
	CMP	CX,0			;
	JMPEQ	BBJPGET_EXIT		;
;;	CMP	BYTE PTR ES:[DI][-2],CHR_LF	; <CR><LF>*(label)
;;	JNE	BBJPGET_LOOP2		;
	MOV	BX,DI			;
	DEC	BX			;
BBJPGET_5:				;
	DEC	BX			;
	MOV	AH,ES:[BX]		;
	CMP	AH,CHR_TAB		; TAB.
	JE	BBJPGET_5		;
	CMP	AH,CHR_SPACE		; space.
	JE	BBJPGET_5		;
	CMP	AH,CHR_LF		; <CR><LF>*(label)
	JNE	BBJPGET_LOOP2		;

	MOV	TEXTPOFS,DI		; text offset pointer.
	MOV	SCH_LEN,CX		; text length.

BBJPGET_SET:				;
	MOV	DI,TEXTPOFS		; text offset pointer.
	MOV	LABEL_PNT,DI		; search length.
	PUSH	DI			;
	CALL	BBSYMBGET		; シンボル取得
	POP	DI			;
	DEC	DI			;
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	CX,STRSYMLEN		; symbol length.
	INC	CX			;
	MOV	AL,CHR_SPACE		;
	REP	STOSB			;

	MOV	AX,JMPTBLSIZE		; jump table size.
	SUB	AX,JMPTBLDLEN		; - jump table data length.
	SUB	AX,2			; - 2 = free area.	(2=count+EOT)
	CMP	AX,STRSYMLEN		; if free area < symbol length then
	JB	BBJPGET_EXITOV		; データテーブル・オーバか？

	MOV	AX,JMPADTBLDIM		; jump adrs table dimension.
	CMP	AX,JMPADTBLCNT		; jump adrs table count.
	JBE	BBJPGET_EXITOV		; データテーブル・オーバか？

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,LABEL_PNT		; search length.
BBJPGET_LFSCH:				;
	DEC	DI			;
	MOV	AL,ES:[DI]		;
	CMP	AL,CHR_LF		;
	JNE	BBJPGET_LFSCH		;
	INC	DI			;
	MOV	LABEL_PNT,DI		; search length.

	MOV	ES,JMPADTBLSEG		; jump adrs table segment.
	MOV	DI,JMPADTBLOFS		; jump adrs table offset.
	MOV	BX,JMPADTBLCNT		; jump adrs table count.
	SHL	BX,1			; word pointer.
	MOV	AX,LABEL_PNT		; search length.
	MOV	ES:[DI][BX],AX		; text offset pointer.
	INC	JMPADTBLCNT		; jump adrs table count.

	MOV	ES,JMPTBLSEG		; jump label table segment.
	MOV	DI,JMPTBLOFS		; jump label table offset.
	ADD	DI,JMPTBLDLEN		; jump table data length.
	MOV	CX,STRSYMLEN		; symbol length.
	MOV	ES:[DI],CL		;
	INC	DI			; ++
	MOV	SI,STRSYMBOL		; symbol string.
	REP	MOVSB			;

	ADDX	JMPTBLDLEN,STRSYMLEN	; jump table data length.
	INC	JMPTBLDLEN		; +1
	SUBX	SCH_LEN,STRSYMLEN	; search text length.

	JMP	BBJPGET_LOOP		;

BBJPGET_EXITOV:
	BBERROR	105			; error message.
BBJPGET_EXIT:
	MOV	ES,JMPTBLSEG		; jump label table segment.
	MOV	DI,JMPTBLOFS		; jump label table offset.
	ADD	DI,JMPTBLDLEN		; jump table data length.
	MOV	BYTE PTR ES:[DI],0	; end of table.

	MOVX	TEXTPOFS,TEXTPSTARTOFS	; text start offset.

IF	DEBUG
	CALL	TABLE_DUMP		; table dump.
ENDIF
	RET
BBJPGET	ENDP


; *********************************************************
;	jump table search.
;	-I- DI : symbol string.
;	    CX : symbol length.
;	-O- AX : 0=search,1=none.
;	    BP : symbol number.
;	    DX : jump address.
; *********************************************************

BBJP_TABLESCH	PROC	NEAR
	CALL	JUMPTBL_SCH			; jump table search.
	RET
BBJP_TABLESCH	ENDP


; *********************************************************
;	jump table search.
;	-I- DI : symbol string.
;	    CX : symbol length.
;	-O- AX : 0=search,1=none.
;	    BP : symbol number.
;	    DX : jump address.
; *********************************************************

JUMPTBL_SCH	PROC	NEAR
	MOVX	ES,DS

	PUSH	DS
	MOV	SI,JMPTBLOFS			; jump label table offset.
	MOVX	DS,JMPTBLSEG			; jump label table segment.
	MOV	DH,0				; DH=0
	MOV	BP,0				; number.
JUMPTBL_SCH_LOOP:
	MOV	BX,SI				;
	LODSB					; get 1 char.
	CMP	AL,0				; end of table?
	JE	JUMPTBL_SCH_NONE		;

	MOV	DL,AL				; symbol length.
	CMP	AL,CL				; symbol length.
	JNE	JUMPTBL_SCH_NEXT		;

	MOV	AX,DI				;
	MOV	DH,CL				;
	REPE	CMPSB				; string comper.
	MOV	CL,DH				;
	MOV	DI,AX				;
	JE	JUMPTBL_SCH_OK			;

	XOR	DH,DH				; DH=0
JUMPTBL_SCH_NEXT:				;
	MOV	SI,BX				;
	ADD	SI,DX				; current + length.
	INC	SI				; + 1 (counter)
	INC	BP				; number.
	JMP	JUMPTBL_SCH_LOOP

JUMPTBL_SCH_OK:					;
	POP	DS				;

	MOV	ES,JMPADTBLSEG			; jump adrs table segment.
	MOV	DI,JMPADTBLOFS			; jump adrs table offset.
	MOV	BX,BP				; number.
	SHL	BX,1				; word pointer.
	MOV	DX,ES:[DI][BX]			; jump address.

	MOV	AX,0				; 0=search.
	RET
JUMPTBL_SCH_NONE:				;
	POP	DS
	MOV	DX,0				;
	MOV	AX,1				; 1=none.
	RET
JUMPTBL_SCH	ENDP


; *********************************************************
;	text stack clear.
; *********************************************************

TEXTSTACKCLR	PROC	NEAR
	MOV	TEXTSTACKPNT,0		; text stack max point.
	RET
TEXTSTACKCLR	ENDP


; *********************************************************
;	text stack push.
;	-I- DX : push data.
; *********************************************************

TEXTPUSH	PROC	NEAR
	CMPX	TEXTSTACKPNT,TEXTSTACK_MXP	; text stack max point.
	JB	TEXTPUSH_2			;

	BBERROR	117			; error message.
	JMP	TEXTPUSH_EXIT		;
TEXTPUSH_2:
	MOV	BX,TEXTSTACKPNT		; text stack pointer.
	MOV	DS:TEXTSTACK[BX],DX	; text stack.
	ADD	TEXTSTACKPNT,2		; text stack pointer.
TEXTPUSH_EXIT:
	RET
TEXTPUSH	ENDP


; *********************************************************
;	text stack pop.
;	-O- DX : push data.
; *********************************************************

TEXTPOP	PROC	NEAR
	SUB	TEXTSTACKPNT,2		; text stack pointer.
	JNB	TEXTPOP_5		;

	BBERROR	117			; error message.
	MOV	TEXTSTACKPNT,0		; text stack pointer.
	MOV	DX,0
	RET
TEXTPOP_5:
	MOV	BX,TEXTSTACKPNT		; text stack pointer.
	MOV	DX,DS:TEXTSTACK[BX]	; text stack.
	RET
TEXTPOP	ENDP


IF	DEBUG

; *********************************************************
;	table dump.
; *********************************************************

TABLE_DUMP	PROC	NEAR
	PRV	"JMPTBLDLEN :",JMPTBLDLEN
	PRV	"JMPADTBLCNT:",JMPADTBLCNT

	MOV	SCH_LEN,0		; text length.
	MOV	CNT,0			;

	MOV	ES,JMPTBLSEG		; jump label table segment.
	MOV	DI,JMPTBLOFS		; jump label table offset.
TABLE_DUMP_LOOP:
	CMPX	SCH_LEN,JMPTBLDLEN	; jump table data length.
	JNB	TABLE_DUMP_EXIT		;

	MOV	DL,ES:[DI]		;
	MOV	DH,0			;
	CALL	DECSTR			;
	ADD	SI,3			;
	CALL	PRINT			;
	PR	":"			;

	MOV	CL,ES:[DI]		;
	MOV	CH,0			;
	INC	DI			;
	INC	SCH_LEN			; text length.
TABLE_DUMP_LOOP2:
	MOV	AL,ES:[DI]		; ascii code
	INC	DI			;
	INC	SCH_LEN			; text length.
	CALL	CHPUT			; print of ascii character.
	LOOP	TABLE_DUMP_LOOP2	;
	PUSH	ES
	MOV	ES,JMPADTBLSEG		; jump adrs table segment.
	MOV	BX,JMPADTBLOFS		; jump adrs table offset.
	MOV	SI,CNT			;
	INC	CNT			;
	INC	CNT			;
	PRVH	":",ES:[BX][SI]		;
	POP	ES
	JMP	TABLE_DUMP_LOOP
TABLE_DUMP_EXIT:
	RET
TABLE_DUMP	ENDP

ENDIF

CODE	ENDS


; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

LABEL_PNT	DW	0	; search length.
SCH_LEN		DW	0	; search length.
CNT		DW	0	; record count.

DATA	ENDS

	END
;
;	end of "BBJUMP.ASM"
;
