; "BBCOMPIL.ASM" PC-9801UV11 make by R.H 1991/10/28
;
;
;	princess  B A S I C    inline compile.
;
;
; (1)	instraction.
;
;	TAG_BINSPACE	[0BH]
;	TAG_DIM		[0CH]
;	TAG_NOTCOM	[0EH]
;	TAG_COMPILE	[0FH]
;	TAG_ASMCALL	[10H][offset low][offset hi]
;	TAG_ASMCL01	[11H][offset low][offset hi]
;	TAG_EXTEND	[12H]
;	TAG_TEXTCALL	[13H][text low][text hi]
;	TAG_TEXTJUMP	[14H][text low][text hi]
;	TAG_RET		[15H]
;	TAG_IMMADD	[16H][value low][value hi]
;	TAG_MEM		[17H][offset low][offset hi]
;	TAG_IMMSUB	[18H][value low][value hi]
;	TAG_STIMM	[19H][value low][value hi]
;	TAG_STMEM	[1AH][offset low][offset hi]
;	TAG_STBYTE	[1BH][byte]
;	TAG_IFIO	[1CH]
;	TAG_IMMMUL	[1DH][value low][value hi]
;	TAG_IMMDIV	[1EH][value low][value hi]
;	TAG_IMMEQU	[1FH][value low][value hi]
;	TAG_MEMEQU	[01H][offset low][offset hi]
;	TAG_MEMADD	[02H][offset low][offset hi]
;	TAG_MEMSUB	[03H][offset low][offset hi]
;	TAG_MEMMUL	[04H][offset low][offset hi]
;	TAG_MEMDIV	[05H][offset low][offset hi]
;	TAG_MEMINC	[06H][offset low][offset hi]
;	TAG_MEMDEC	[07H][offset low][offset hi]
;	TAG_EQUSTR	[08H][offset low][offset hi][length][strings]
;	TAG_DIRECTCOM	[40H]
;	TAG_PRINT	[22H]
;
; (2)	dimension extend.
;
;	TAG_DIM		[0CH][..]
;
;		TAG_MEMEQU	[01H][offset low][offset hi][dim low][dim hi]
;		TAG_MEMADD	[02H][offset low][offset hi][dim low][dim hi]
;		TAG_MEMSUB	[03H][offset low][offset hi][dim low][dim hi]
;		TAG_MEMMUL	[04H][offset low][offset hi][dim low][dim hi]
;		TAG_MEMDIV	[05H][offset low][offset hi][dim low][dim hi]
;		TAG_MEMINC	[06H][offset low][offset hi][dim low][dim hi]
;		TAG_MEMDEC	[07H][offset low][offset hi][dim low][dim hi]
;
; (3)	instraction extend.
;
;	TAG_EXTEND	[12H][..]
;
;	stack string.
;
;		TAG_EQUSTR	[08H][offset low][offset hi][length][strings]
;
;	dimension + stack string.
;
;		TAG_DIM+TAG_EQUSTR  [OCH][08H][offset low][offset hi]
;					[dim low][dim hi][length][strings]
;
;	loops.
;
;		TAG_EXT_LOOP	[4CH][offset low][offset hi][text low][text hi]
;		TAG_EXT_LOOP_D	[6CH][offset low][offset hi]
;					[dim low][dim hi][text low][text hi]
;
; (4)	if condition code.
;
;	TAG_IFIO	[1CH][..]
;
;		TAG_IF_IMM_EQU	[01H]
;		TAG_IF_IMM_LT	[02H]
;		TAG_IF_IMM_GT	[03H]
;		TAG_IF_IMM_LE	[04H]
;		TAG_IF_IMM_GE	[05H]
;		TAG_IF_IMM_NOT	[06H]
;
;		TAG_IF_MEM_EQU	[11H]
;		TAG_IF_MEM_LT	[12H]
;		TAG_IF_MEM_GT	[13H]
;		TAG_IF_MEM_LE	[14H]
;		TAG_IF_MEM_GE	[15H]
;		TAG_IF_MEM_NOT	[16H]
;		TAG_IF_LOGICAL	[17H]
;		TAG_IF_OR	[1AH]
;
;
; command routine.

INCLUDE	TSTSETC.INC
INCLUDE	BBEXTRN.INC
INCLUDE	DEBUGX.INC
DEBUG1	EQU	1	; compile code.
DEBUG2	EQU	0	; nest table.
DEBUG3	EQU	0	; compile only.
DEBUG4	EQU	0	; condition.

TAG_BINSPACE	EQU	0BH	; binary space.
TAG_DIM		EQU	0CH	; dimension.
TAG_NOTCOM	EQU	0EH	; not compile.
TAG_COMPILE	EQU	0FH	; compiled.
TAG_ASMCALL	EQU	10H	; asm call(CODE)
TAG_ASMCL01	EQU	11H	; asm call(CODE01)
TAG_EXTEND	EQU	12H	; extend.
TAG_TEXTCALL	EQU	13H	; text call.
TAG_TEXTJUMP	EQU	14H	; text jump.
TAG_RET		EQU	15H	; ret
TAG_IMMADD	EQU	16H	; immidiate +
TAG_MEM		EQU	17H	; memory.
TAG_IMMSUB	EQU	18H	; immidiate -
TAG_STIMM	EQU	19H	; stack immidiate.
TAG_STMEM	EQU	1AH	; stack memory.
TAG_STBYTE	EQU	1BH	; stack byte.
TAG_IFIO	EQU	1CH	; if i/o.
TAG_IMMMUL	EQU	1DH	; immidiate *
TAG_IMMDIV	EQU	1EH	; immidiate /
TAG_IMMEQU	EQU	1FH	; immidiate =
TAG_MEMEQU	EQU	01H	; memory =
TAG_MEMADD	EQU	02H	; memory +
TAG_MEMSUB	EQU	03H	; memory -
TAG_MEMMUL	EQU	04H	; memory *
TAG_MEMDIV	EQU	05H	; memory /
TAG_MEMINC	EQU	06H	; memory ++
TAG_MEMDEC	EQU	07H	; memory --
TAG_EQUSTR	EQU	08H	; ="string"
TAG_DIRECTCOM	EQU	40H	; direct command "@"
TAG_PRINT	EQU	22H	; print string."""

TAG_EXT_LOOP	EQU	4CH	; 'L' loop.
TAG_EXT_LOOP_D	EQU	6CH	; 'l' loop dimension.

TAG_IF_IMM_EQU	EQU	01H	; IF immidiate =.
TAG_IF_IMM_LT	EQU	02H	; IF immidiate <.
TAG_IF_IMM_GT	EQU	03H	; IF immidiate >.
TAG_IF_IMM_LE	EQU	04H	; IF immidiate =<.
TAG_IF_IMM_GE	EQU	05H	; IF immidiate >=.
TAG_IF_IMM_NOT	EQU	06H	; IF immidiate !.

TAG_IF_MEM_EQU	EQU	11H	; IF memory =.
TAG_IF_MEM_LT	EQU	12H	; IF memory <.
TAG_IF_MEM_GT	EQU	13H	; IF memory >.
TAG_IF_MEM_LE	EQU	14H	; IF memory =<.
TAG_IF_MEM_GE	EQU	15H	; IF memory >=.
TAG_IF_MEM_NOT	EQU	16H	; IF memory !.
TAG_IF_LOGICAL	EQU	17H	; IF logical.

TAG_IF_OR	EQU	1AH	; IF or.

MAX_STRING_LEN	EQU	254;128	; max string length.

SKIP_SPACE	MACRO		; skip space.
	LOCAL	L1
L1:
	LODSB
	CMP	AL,CHR_SPACE
	JE	L1
	CMP	AL,CHR_TAB
	JE	L1
	DEC	SI
	ENDM

SKIP_SPACE_CMMA	MACRO		; skip space & comma.
	LOCAL	L1,L2,L3
L1:
	LODSB
	CMP	AL,CHR_SPACE
	JE	L1
	CMP	AL,CHR_TAB
	JE	L1

	CMP	AL,CHR_COMMA	; , comma.
	JNE	L3
L2:
	LODSB
	CMP	AL,CHR_SPACE
	JE	L2
	CMP	AL,CHR_TAB
	JE	L2
L3:
	DEC	SI
	ENDM

SKIP_NOTSPACE	MACRO		; skip not space.
	LOCAL	L1,L2
L1:
	LODSB
	CMP	AL,CHR_SPACE
	JE	L2
	CMP	AL,CHR_TAB
	JE	L2
	CMP	AL,EOS
	JE	L2
	JMP	L1
L2:
	DEC	SI
	ENDM

STRCOMP	MACRO	STR1
	MOV	DI,STRSYMBOL
	MOV	SI,OFFSET STR1
	CALL	c_STRCMP		; string compare.
	ENDM

SKIP_BINSPACE	MACRO		; skip binary space.
	LOCAL	L1
L1:
	MOV	AL,ES:[DI]
	INC	DI
	CMP	AL,TAG_BINSPACE	; binary space.
	JE	L1
	DEC	DI
	ENDM

SKIP_BIN2SPACE	MACRO		; skip binary space.
	LOCAL	L1
L1:
	MOV	AL,ES:[DI]
	INC	DI
	CMP	AL,TAG_BINSPACE	; binary space.
	JE	L1
	CMP	AL,CHR_SPACE
	JE	L1
	CMP	AL,CHR_TAB
	JE	L1
	DEC	DI
	ENDM

CODE01	SEGMENT	PUBLIC	'CODE01'
CODE01	ENDS

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:DATA

PUBLIC	BBCOMPFULL		; full compile.
PUBLIC	BBCOMPLIN		; line compile.
PUBLIC	BBCOMPNEST		; nest check.

EXTRN	BBDEFINE:NEAR		; define.

EXTRN	BBSTRSYMBGET:NEAR	; 文字列からシンボル取得

EXTRN	BBMES_KANJI:NEAR	; text message kanji.
EXTRN	BBMES_ALPHA:NEAR	; text message alphabet.

EXTRN	BBJP_TABLESCH:NEAR	; jump table search.
EXTRN	BBSYMBOL_SCH:NEAR	; symbol table search.

EXTRN	BBSJISCHK:NEAR		; シフトＪＩＳチェック
EXTRN	BBNUMBER:NEAR		; 文字列－＞数字チェック
EXTRN	BBLFSKIP:NEAR		; 次の行までスキップ
EXTRN	BBSTRDIM_GET:NEAR	; 文字列から配列添字取出

EXTRN	TEXTPUSH:NEAR		; text stack push.
EXTRN	TEXTPOP:NEAR		; text stack pop.

EXTRN	BBDEBUGHEX:NEAR		; hex line dump.
EXTRN	BBDEBUGCHR:NEAR		; char line dump.

EXTRN	BBLKSKP:NEAR		; ブランクスキップ

EXTRN	c_STRFILL:NEAR		; 文字列バッファＦＩＬＬ
EXTRN	c_STRZEROC:NEAR		; 文字列バッファ０クリア
EXTRN	c_STRCAPS:NEAR		; 文字列大文字化

EXTRN	c_WID_TEXT_STRIME:NEAR	; WINDOWS/テキストウインドウ選択
EXTRN	c_WID_TEXT_PAUSE:NEAR	; WINDOWS/テキストウインドウＰＡＵＳＥ
EXTRN	c_WID_TEXT_CLR:NEAR	; WINDOWS/テキストウインドウクリア
EXTRN	c_WID_TEXT_LF:NEAR	; WINDOWS/テキストウインドウ改行

EXTRN	BBDEBUGMISSCOMPILE:NEAR	; miss compile.
EXTRN	BBDEBUGTEXTPOINTER:NEAR	; text pointer.


; *********************************************************
;	full compile.
;	-I/O- TEXTPSEG : text segment pointer.
;	      TEXTPOFS : text offset pointer.
; *********************************************************

BBCOMPFULL	PROC	NEAR
	MOVX	TEXTPOFS,TEXTPSTARTOFS	; text start offset.
	MOV	LINCOUNT,1		; line counter.
BBCOMPFULL_LOOP:
	CALL	BBLKSKP			; ブランクスキップ
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text start offset.
	MOV	AL,ES:[DI]		;
	CMP	AL,EOT			; EOT
	JMPEQ	BBCOMPFULL_EXIT		;
	CMP	AL,CHR_CR		; CR
	JNE	BBCOMPFULL_1		;
	ADD	TEXTPOFS,2		; text start offset.
	INC	LINCOUNT		; line counter.
	JMP	BBCOMPFULL_LOOP		;
BBCOMPFULL_1:

	CALL	LINEGET			; line get.
	CMP	CLINELEN,0		; line length.
	JE	BBCOMPFULL_LOOP		;

	MOV	DX,TAG_BINSPACE		; binary space.
	MOV	DI,COMPLINEBIN		; comp line buffer binary.
	MOV	CX,COMPLINESIZE		; comp line buffer size.
	CALL	c_STRFILL		; 文字列バッファＦＩＬＬ

	CALL	LINEALZE		; line analyze.
	CMP	AX,1			; 0=complete,1=not compiled,2=error.
	JE	BBCOMPFULL_81		;
	CMP	AX,2			; 0=complete,1=not compiled,2=error.
	JE	BBCOMPFULL_82		;
	JMP	BBCOMPFULL_NEXT		;
BBCOMPFULL_81:
	MOV	SI,FLTEXTNOW		; now text file path.
	CALL	c_PRINT			;
	MOV	AL," "			;
	CALL	c_CHPUT			;
	MOV	DX,LINCOUNT		; line counter.
	CALL	c_DECSTR		;
	CALL	c_PRINT			;
	PRSA	" not compile : ",COMPLINESOU
	JMP	BBCOMPFULL_NEXT
BBCOMPFULL_82:
	MOV	SI,FLTEXTNOW		; now text file path.
	CALL	c_PRINT			;
	MOV	AL," "			;
	CALL	c_CHPUT			;
	MOV	DX,LINCOUNT		; line counter.
	CALL	c_DECSTR		;
	CALL	c_PRINT			;
	PRSA	" compile error : ",COMPLINESOU
BBCOMPFULL_NEXT:
	CALL	c_KESCAP		; ESC key & break check & pause.
	CMP	AX,2			; 0=normal, 1=ESC on, 2=ctrl-C,3=enter.
	JE	BBCOMPFULL_EXIT		;
	JMP	BBCOMPFULL_LOOP		;
BBCOMPFULL_EXIT:
	MOVX	TEXTPOFS,TEXTPSTARTOFS	; text start offset.
	RET
BBCOMPFULL	ENDP


; *********************************************************
;	line compile.
;	-I/O- TEXTPSEG : text segment pointer.
;	      TEXTPOFS : text offset pointer.
;	-O-   AX       : 0=complete,1=not compile line
; *********************************************************

BBCOMPLIN	PROC	NEAR
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; now text pointer.
	DEC	DI			;
	MOV	AL,ES:[DI]		;

	CMP	AL,TAG_COMPILE		; compiled.
	JMPEQ	BBCOMPLIN_RUN		;

	CMP	AL,TAG_NOTCOM		; not compile.
	JMPEQ	BBCOMPLIN_NOTC		;

	MOVX	NOWTEXTPOINT,TEXTPOFS	; now text pointer.
	CALL	LINEGET			; line get.

	MOV	DX,TAG_BINSPACE		; binary space.
	MOV	DI,COMPLINEBIN		; comp line buffer binary.
	MOV	CX,COMPLINESIZE		; comp line buffer size.
	CALL	c_STRFILL		; 文字列バッファＦＩＬＬ

	CALL	LINEALZE		; line analyze.

IF DEBUG3 ; compile only.
	JMP	BBCOMPLIN_55
ENDIF
	CMP	AX,0			; 0=complete,1=not compiled,2=error.
	JMPNE	BBCOMPLIN_NOTCMP	;

	CMPX	CBINALEN,CLINELEN	; line length.
	JMPNBE	BBCOMPLIN_SHORT		;

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,NOWTEXTPOINT		; now text pointer.
	MOV	SI,COMPLINEBIN		; comp line buffer binary.
	MOV	CX,CLINELEN		; line length.
	REP	MOVSB			;

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,NOWTEXTPOINT		; now text pointer.
	DEC	DI			;
	MOV	AL,TAG_COMPILE		; compiled.
	STOSB				;
	MOVX	TEXTPOFS,NOWTEXTPOINT	; now text pointer.

BBCOMPLIN_55:

IF DEBUG1 ; compile code.
	CMP	INLINECOMPDBG,1		; inline compile debug.
	JNE	BBCOMPLIN_DBGOUT	;

	LF
	MOV	SI,COMPLINESOU		; comp line buffer source.
	CALL	c_PRINT
	LF

	MOVX	ES,DS			;
	MOV	DI,COMPLINESOU		; comp line buffer source.
	MOV	CX,PNTSOU		; comp line buffer source.
	SUB	CX,COMPLINESOU		; comp line buffer source.
	CALL	BBDEBUGCHR		; char line dump.
	CALL	BBDEBUGHEX		; hex line dump.

	MOVX	ES,DS			;
	MOV	DI,COMPLINEBIN		; comp line buffer binary.
	MOV	CX,PNTBIN		; comp line buffer binary.
	SUB	CX,COMPLINEBIN		; comp line buffer binary.
	CALL	BBDEBUGCHR		; char line dump.(0end)
	CALL	BBDEBUGHEX		; hex line dump.(0end)
BBCOMPLIN_DBGOUT:
ENDIF

BBCOMPLIN_RUN:
	CALL	BBCLRUN			; compile line run.
	CMP	FLAGEXIT,0		; exit flag.
	JNE	BBCOMPLIN_EXIT		;
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset pointer.
	SKIP_BINSPACE			; skip binary space.
	MOV	TEXTPOFS,DI		; text offset pointer.
	JMP	BBCOMPLIN_EXIT		;

BBCOMPLIN_SHORT:
	BBERROR	124			; error message.
BBCOMPLIN_NOTCMP:
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,NOWTEXTPOINT		; now text pointer.
	DEC	DI			;
	MOV	AL,TAG_NOTCOM		; not compile.
	STOSB				;
	MOVX	TEXTPOFS,NOWTEXTPOINT	; now text pointer.
	CALL	BBDEBUGMISSCOMPILE	; miss compile.
	JMP	BBCOMPLIN_NOTC		;

BBCOMPLIN_EXIT:
	MOV	AX,0			; 0=complete.
	RET
BBCOMPLIN_NOTC:
	MOV	AX,1			; 1=not compile line
	RET
BBCOMPLIN	ENDP



; *********************************************************
;	compile line run.
;	-I/O- TEXTPSEG : text segment pointer.
;	      TEXTPOFS : text offset pointer.
; *********************************************************

BBCLRUN	PROC	NEAR
	MOV	VALUE,0			; value.
	MOV	STACKLEVEL,0		; stack level.
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset pointer.
BBCLRUN_01:
	MOV	AL,ES:[DI]		;
	INC	DI			;
	CMP	AL,CHR_TAB		; TAB.
	JE	BBCLRUN_01		;
	DEC	DI			;

	JMP	BBCLRUN_LOOP		;

BBCLRUN_START:				;
	MOV	VALUE,0			; value.
	MOV	STACKLEVEL,0		; stack level.
	MOV	FLAG_PREPROS,0		; preprosion flag.
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset pointer.
BBCLRUN_LOOP:
	CALL	BBDEBUGTEXTPOINTER	; text pointer.

	CMP	KEYBORD_FLAGALLSKIP,1	; all skip flag.
	JMPEQ	BBCLRUN_SKIP		;

	MOV	FLAG_PREPROS,0		; preprosion flag.
BBCLRUN_LOOPS:
	MOV	AL,ES:[DI]		;
	INC	DI			;
	PUSH	ES			;
	PUSH	DI			;
	MOV	DX,DS			;
	MOV	ES,DX			;
	MOV	DI,OFFSET IF_INSTRACTION_TBL
	MOV	CX,IF_INSTRACTION_MAX	; instraction max.
	REPNE	SCASB			;
	MOV	BP,DI			; BP=offset
	POP	DI			;
	POP	ES			;
	JNE	BBCLRUN_NONE		;

	DEC	BP			; -1
	SUB	BP,OFFSET IF_INSTRACTION_TBL
	SHL	BP,1			; word pointer.
	CMP	FLAG_PREPROS,1		; preprosion flag.
	JMP	WORD PTR DS:IF_INSTRACTION_JMP[BP]

BBCLRUN_NONE:				;
	DEC	DI			;
	MOV	TEXTPOFS,DI		; text offset pointer.
	CALL	BBMES_KANJI		; text message kanji.
	MOV	DI,TEXTPOFS		; text offset pointer.
	CMP	AX,1			; 0=message char,1=message none.
	JMPEQ	BBCLRUN_EXIT		;

BBCLRUN_NEXT:				;
	CMP	FLAGEXIT,0		; exit flag.
	JMPNE	BBCLRUN_BREAK		;
	JMP	BBCLRUN_LOOP		;

BBCLRUN_TAG_DIM:			; dimension.
	MOV	FLAG_PREPROS,1		; preprosion flag.
	JMP	BBCLRUN_LOOPS		;

BBCLRUN_TAG_MEM:			;
	JE	BBCLRUN_TAG_MEM_DIM	;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	MOVX	DS:[BX],VALUE		; value.
	MOV	VALUE,0			; value.
	JMP	BBCLRUN_NEXT		;
BBCLRUN_TAG_MEM_DIM:			;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	MOV	SI,ES:[DI]		; value address.
	MOV	AX,DS:[SI]		;
	SHL	AX,1			; word pointer.
	ADD	BX,AX			; +dimension.
	INC	DI			;
	INC	DI			;
	MOVX	DS:[BX],VALUE		; value.
	MOV	VALUE,0			; value.
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_MEMINC:			;
	JE	BBCLRUN_TAG_MEMINC_DIM	;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	INC	WORD PTR DS:[BX]	; ++
	JMP	BBCLRUN_NEXT		;
BBCLRUN_TAG_MEMINC_DIM:			;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	MOV	SI,ES:[DI]		; value address.
	MOV	AX,DS:[SI]		;
	SHL	AX,1			; word pointer.
	ADD	BX,AX			; +dimension.
	INC	DI			;
	INC	DI			;
	INC	WORD PTR DS:[BX]	; ++
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_MEMDEC:			;
	JE	BBCLRUN_TAG_MEMDEC_DIM	;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	DEC	WORD PTR DS:[BX]	; --
	JMP	BBCLRUN_NEXT		;
BBCLRUN_TAG_MEMDEC_DIM:			;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	MOV	SI,ES:[DI]		; value address.
	MOV	AX,DS:[SI]		;
	SHL	AX,1			; word pointer.
	ADD	BX,AX			; +dimension.
	INC	DI			;
	INC	DI			;
	DEC	WORD PTR DS:[BX]	; --
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_IMMEQU:			;
	MOVX	VALUE,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_IMMADD:			;
	ADDX	VALUE,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_IMMSUB:			;
	SUBX	VALUE,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_IMMMUL:			;
	MOV	BX,ES:[DI]		; value address.
	MOV	AX,VALUE		;
	IMUL	BX			;
	INC	DI			;
	INC	DI			;
	MOV	VALUE,AX		; value address.
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_IMMDIV:			;
	MOV	CX,ES:[DI]		; value address.
	JCXZ	BBCLRUN_TAG_IMMDIV2	;
	MOV	AX,VALUE		;
	CWD				;
	IDIV	CX			;
	INC	DI			;
	INC	DI			;
	MOV	VALUE,AX		; value address.
BBCLRUN_TAG_IMMDIV2:			;
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_MEMEQU:			;
	JE	BBCLRUN_TAG_MEMEQU_DIM	;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	MOVX	VALUE,DS:[BX]		; value address.
	JMP	BBCLRUN_NEXT		;
BBCLRUN_TAG_MEMEQU_DIM:			;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	MOV	SI,ES:[DI]		; value address.
	MOV	AX,DS:[SI]		;
	SHL	AX,1			; word pointer.
	ADD	BX,AX			; +dimension.
	INC	DI			;
	INC	DI			;
	MOVX	VALUE,DS:[BX]		; value address.
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_MEMADD:			;
	JE	BBCLRUN_TAG_MEMADD_DIM	;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	ADDX	VALUE,DS:[BX]		; value address.
	JMP	BBCLRUN_NEXT		;
BBCLRUN_TAG_MEMADD_DIM:			;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	MOV	SI,ES:[DI]		; value address.
	MOV	AX,DS:[SI]		;
	SHL	AX,1			; word pointer.
	ADD	BX,AX			; +dimension.
	INC	DI			;
	INC	DI			;
	ADDX	VALUE,DS:[BX]		; value address.
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_MEMSUB:			;
	JE	BBCLRUN_TAG_MEMSUB_DIM	;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	SUBX	VALUE,DS:[BX]		; value address.
	JMP	BBCLRUN_NEXT		;
BBCLRUN_TAG_MEMSUB_DIM:			;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	MOV	SI,ES:[DI]		; value address.
	MOV	AX,DS:[SI]		;
	SHL	AX,1			; word pointer.
	ADD	BX,AX			; +dimension.
	INC	DI			;
	INC	DI			;
	SUBX	VALUE,DS:[BX]		; value address.
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_MEMMUL:			;
	JE	BBCLRUN_TAG_MEMMUL_DIM	;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	MOV	CX,DS:[BX]		;
	MOV	AX,VALUE		;
	IMUL	CX			;
	MOV	VALUE,AX		; value address.
	JMP	BBCLRUN_NEXT		;
BBCLRUN_TAG_MEMMUL_DIM:			;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	MOV	SI,ES:[DI]		; value address.
	MOV	AX,DS:[SI]		;
	SHL	AX,1			; word pointer.
	ADD	BX,AX			; +dimension.
	INC	DI			;
	INC	DI			;
	MOV	CX,DS:[BX]		;
	MOV	AX,VALUE		;
	IMUL	CX			;
	MOV	VALUE,AX		; value address.
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_MEMDIV:			;
	JE	BBCLRUN_TAG_MEMDIV_DIM	;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	MOV	CX,DS:[BX]		;
	JCXZ	BBCLRUN_TAG_MEMDIV2	;
	MOV	AX,VALUE		;
	CWD				;
	IDIV	CX			;
	MOV	VALUE,AX		; value address.
BBCLRUN_TAG_MEMDIV2:			;
	JMP	BBCLRUN_NEXT		;
BBCLRUN_TAG_MEMDIV_DIM:			;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	MOV	SI,ES:[DI]		; value address.
	MOV	AX,DS:[SI]		;
	SHL	AX,1			; word pointer.
	ADD	BX,AX			; +dimension.
	INC	DI			;
	INC	DI			;
	MOV	CX,DS:[BX]		;
	JCXZ	BBCLRUN_TAG_MEMDIV2_DIM	;
	MOV	AX,VALUE		;
	CWD				;
	IDIV	CX			;
	MOV	VALUE,AX		; value address.
BBCLRUN_TAG_MEMDIV2_DIM:		;
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_EXTEND:			;
	MOV	AL,ES:[DI]		;
	INC	DI			;
	CMP	AL,TAG_EQUSTR		; ="string"
	JE	BBCLRUN_TAG_EXT_STRING	;
	CMP	AL,TAG_DIM		; dimension.
	JE	BBCLRUN_TAG_EXT_DIM	;
	CMP	AL,TAG_EXT_LOOP		; 'L' loop.
	JE	BBCLRUN_TAG_EXT_LOOP	;
	CMP	AL,TAG_EXT_LOOP_D	; 'l' loop dimension.
	JE	BBCLRUN_TAG_EXT_LOOP_D	;
	JMP	BBCLRUN_NEXT		;
BBCLRUN_TAG_EXT_STRING:
	MOV	BX,ES:[DI]		; value adrs.
	INC	DI			;
	INC	DI			;
	CALL	EXT_STRINGSET		; extended string set.
	JMP	BBCLRUN_NEXT		;
BBCLRUN_TAG_EXT_DIM:			;
	MOV	AL,ES:[DI]		;
	INC	DI			;
	CMP	AL,TAG_EQUSTR		; ="string"
	JE	BBCLRUN_TAG_EXT_DIM_STRING
	JMP	BBCLRUN_NEXT		;
BBCLRUN_TAG_EXT_DIM_STRING:
	MOV	BX,ES:[DI]		; value adrs.
	INC	DI			;
	INC	DI			;
	MOV	BP,ES:[DI]		; dimension value.
	MOV	AX,DS:[BP]		;
	SHL	AX,1			; word counter.
	ADD	BX,AX			; dimension address.
	INC	DI			;
	INC	DI			;
	CALL	EXT_STRINGSET		; extended string set.
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_EXT_LOOP:			;
	MOV	BX,ES:[DI]		;[offset low][offset hi]
	INC	DI			;
	INC	DI			;
	MOV	DX,ES:[DI]		;[text low][text hi]
	INC	DI			;
	INC	DI			;
	MOV	CX,DS:[BX]		;
	JCXZ	BBCLRUN_TAG_EXT_LOOP2	;
	DEC	CX			;
	MOV	DS:[BX],CX		;
	JCXZ	BBCLRUN_TAG_EXT_LOOP2	;
	MOV	TEXTPOFS,DX		; text offset pointer.
	JMP	BBCLRUN_JMPEXIT		;
BBCLRUN_TAG_EXT_LOOP_D:			;
	MOV	BX,ES:[DI]		;[offset low][offset hi]
	INC	DI			;
	INC	DI			;
	MOV	BP,ES:[DI]		;[dim low][dim hi]
	MOV	AX,DS:[BP]		;
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	INC	DI			;
	INC	DI			;
	MOV	DX,ES:[DI]		;[text low][text hi]
	INC	DI			;
	INC	DI			;
	MOV	CX,DS:[BX]		;
	JCXZ	BBCLRUN_TAG_EXT_LOOP2	;
	DEC	CX			;
	MOV	DS:[BX],CX		;
	JCXZ	BBCLRUN_TAG_EXT_LOOP2	;
	MOV	TEXTPOFS,DX		; text offset pointer.
	JMP	BBCLRUN_JMPEXIT		;

BBCLRUN_TAG_EXT_LOOP2:			;
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_ASMCALL:			; asm call(CODE)
	MOV	STACKLEVEL,0		; stack level.
	MOV	AX,ES:[DI]		;
	INC	DI			;
	INC	DI			;
	MOV	JUMP_OFFSET,AX		; jump offset.
	MOV	TEXTPOFS,DI		; text offset pointer.
	CALL	WORD PTR JUMP_OFFSET	; jump address.
	MOV	DI,TEXTPOFS		; text offset pointer.
	MOV	ES,TEXTPSEG		; text segment pointer.
	JMP	BBCLRUN_NEXT

BBCLRUN_TAG_ASMCL01:			;
	MOV	STACKLEVEL,0		; stack level.
	MOV	AX,ES:[DI]		;
	INC	DI			;
	INC	DI			;
	MOV	JUMP_OFFSET,AX		; jump offset.
	MOV	TEXTPOFS,DI		; text offset pointer.
	CALL	FAR PTR BBFUNCTION_CODE01_JP
	MOV	DI,TEXTPOFS		; text offset pointer.
	MOV	ES,TEXTPSEG		; text segment pointer.
	JMP	BBCLRUN_NEXT

BBCLRUN_TAG_TEXTCALL:			;
	MOV	STACKLEVEL,0		; stack level.
	MOV	DX,ES:[DI]		;
	MOV	TEXTPOFS,DX		; text offset pointer.
	INC	DI			;
	INC	DI			;
	SKIP_BINSPACE			; skip binary space.
	PUSH	DX			; DX : jump address.
	MOV	DX,DI			; text offset pointer.
	CALL	TEXTPUSH		; text stack push.
	POP	TEXTPOFS		; text offset pointer.
	JMP	BBCLRUN_JMPEXIT		;

BBCLRUN_TAG_TEXTJUMP:			;
	MOV	DX,ES:[DI]		;
	MOV	TEXTPOFS,DX		; text offset pointer.
	JMP	BBCLRUN_JMPEXIT		;

BBCLRUN_TAG_RET:			;
	CALL	TEXTPOP			; text stack pop.
	MOV	TEXTPOFS,DX		; text offset pointer.
	CMP	DX,0			;
	JNE	BBCLRUN_TAG_RET2	;
	MOVX	TEXTPOFS,TEXTPSTARTOFS	; text start offset.
BBCLRUN_TAG_RET2:			;
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset pointer.
	JMP	BBCLRUN_NEXT		;
;*;	JMP	BBCLRUN_JMPEXIT		;

BBCLRUN_TAG_IF:				;
	CALL	IF_CONDITION		; if condition.
IF 0
	PRV	"IF_CONDITION AX=",AX
	MOV	DX,DS
	PRVH	"DS=",DX
	PRVH	"ES=",ES
	PRVH	"DI=",DI
	PRVH	"TEXTPOFS=",TEXTPOFS
	PUSH	AX
	MOV	AH,ES:[DI]
	CALL	PRNAH
	POP	AX
	CMP	COND,0
	JMPNE	BBCLRUN_BREAK
ENDIF
	CMP	AX,1			; 0=normal,1=jump,2=error.
	JMPEQ	BBCLRUN_JMPEXIT		;
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_EQUSTR:			;
	MOV	BX,ES:[DI]		; value adrs.
	INC	DI			;
	INC	DI			;
	XOR	CH,CH			; CH=0
	MOV	CL,ES:[DI]		; length.
	INC	DI			;
	MOVX	DS:[BX],USERSTRING	; user string.
	JCXZ	BBCLRUN_TAG_EQUSTR2	; if length=0 then skip.
	MOV	SI,DI			;
	MOV	DI,USERSTRING		; user string.
	MOV	DX,DS			;
	MOV	AX,ES			; XCHG DS,ES
	MOV	DS,AX			;
	MOV	ES,DX			;
	REP	MOVSB			;
	MOV	BYTE PTR ES:[DI],0	; eos.
	MOV	DI,SI
	MOV	DX,DS			;
	MOV	AX,ES			; XCHG DS,ES
	MOV	DS,AX			;
	MOV	ES,DX			;
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_EQUSTR2:			;
	MOV	SI,USERSTRING		; user string.
	MOV	BYTE PTR DS:[SI],0	; eos.
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_STIMM:			; stack immidiate.
	MOV	AX,ES:[DI]		; value address.
	MOV	SI,STACKLEVEL		; stack level.
	SHL	SI,1			; word pointer.
	MOV	DS:REG_TABLE[SI],AX	; registar value table.
	INC	DI			;
	INC	DI			;
	INC	STACKLEVEL		; stack level.
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_STMEM:			; stack memory.
	JE	BBCLRUN_TAG_STMEM_DIM	;

	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	MOV	AX,DS:[BX]		; value address.
	MOV	SI,STACKLEVEL		; stack level.
	SHL	SI,1			; word pointer.
	MOV	DS:REG_TABLE[SI],AX	; registar value table.
	INC	STACKLEVEL		; stack level.
	JMP	BBCLRUN_NEXT		;
BBCLRUN_TAG_STMEM_DIM:			;
	MOV	BX,ES:[DI]		; value address.
	INC	DI			;
	INC	DI			;
	MOV	SI,ES:[DI]		; value address.
	MOV	AX,DS:[SI]		;
	SHL	AX,1			; word pointer.
	ADD	BX,AX			; +dimension.
	INC	DI			;
	INC	DI			;
	MOV	AX,DS:[BX]		; value address.
	MOV	SI,STACKLEVEL		; stack level.
	SHL	SI,1			; word pointer.
	MOV	DS:REG_TABLE[SI],AX	; registar value table.
	INC	STACKLEVEL		; stack level.
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_STBYTE:			; stack byte.
	MOV	AL,ES:[DI]		; value address.
	CBW				;
	;*;XOR	AH,AH			; AH=0
	MOV	SI,STACKLEVEL		; stack level.
	SHL	SI,1			; word pointer.
	MOV	DS:REG_TABLE[SI],AX	; registar value table.
	INC	DI			;
	INC	STACKLEVEL		; stack level.
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_DIRECT:			;
	CALL	DIRECT_CMND		; direct command.
	JMP	BBCLRUN_NEXT		;

BBCLRUN_TAG_PRINT:			; print string."""
	CALL	PRINT_STRING		; print string.
	JMP	BBCLRUN_NEXT		;

BBCLRUN_JMPEXIT:
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset pointer.
	DEC	DI			;
	MOV	AL,ES:[DI]		;
	INC	DI			;
	CMP	AL,TAG_COMPILE		; compiled.
	JMPEQ	BBCLRUN			;
	RET

BBCLRUN_EXIT:
	SKIP_BINSPACE			; skip binary space.
	MOV	TEXTPOFS,DI		; text offset pointer.
	CMP	BYTE PTR ES:[DI],CHR_CR
	JNE	BBCLRUN_EXIT2		;
	INC	DI			;
	INC	DI			;
	MOV	TEXTPOFS,DI		; text offset pointer.
BBCLRUN_EXIT2:
	MOV	AL,ES:[DI]		;
	CMP	AL,CHR_TAB		;
	JE	BBCLRUN_999		;
	CMP	AL,20H			; compile code?
	JMPB	BBCLRUN_START		;
BBCLRUN_999:
	DEC	DI			;
	MOV	AL,ES:[DI]		;
	INC	DI			;
	CMP	AL,TAG_COMPILE		; compiled.
	JMPEQ	BBCLRUN			;
BBCLRUN_SKIP:
	RET
BBCLRUN_BREAK:
	MOV	FLAGEXIT,1		; exit flag.
	RET
BBCLRUN	ENDP


; *********************************************************
;	extended string set.
;
;	stack string.
;
;	  TAG_EQUSTR	[08H][offset low][offset hi][length][strings]
;						    |now
;	dimension + stack string.
;
;	  TAG_DIM+TAG_EQUSTR  [OCH][08H][offset low][offset hi]
;				[dim low][dim hi][length][strings]
;						 |now
;	-I-   BX    : value address.
;	-I/O- ES:DI : current pointer.
;	-O-   AX    : 0=normal,1=error.
; *********************************************************

EXT_STRINGSET	PROC	NEAR
	MOV	CH,0			; CH=0
	MOV	CL,ES:[DI]		; length.
	INC	DI			;

	MOV	AX,STRINGSTACKMAX	; string stack max.
	SUB	AX,STRINGSTACKPNT	; string stack pointer.
	CMP	CX,AX			; 表示単語長さ:バッファ最大長さ
	JNB	EXT_STRINGSET_ERROR	; オーバー？

	JCXZ	EXT_STRINGSET_ZERO	; 文字列長が０のとき

	MOV	SI,DI			; SI <- DI
	MOV	DI,STRINGSTACKPNT	; string stack pointer.
	ADD	DI,STRINGSTACKBUF	; string stack buffer.
	MOVX	DS:[BX],DI		; user string.

	ADD	STRINGSTACKPNT,CX	; string stack pointer.
	INC	STRINGSTACKPNT		; + e.o.s

	MOV	DX,DS			;
	MOV	AX,ES			; XCHG DS,ES
	MOV	DS,AX			;
	MOV	ES,DX			;
	REP	MOVSB			;
	MOV	BYTE PTR ES:[DI],0	; eos.
	MOV	DI,SI
	MOV	DX,DS			;
	MOV	AX,ES			; XCHG DS,ES
	MOV	DS,AX			;
	MOV	ES,DX			;

EXT_STRINGSET_EXIT:
	MOV	AX,0			; 0=normal,1=error.
	RET
EXT_STRINGSET_ZERO:
	MOVX	DS:[BX],NULSTRING	; null string buffer.
	MOV	AX,0			; 0=normal,1=error.
	RET
EXT_STRINGSET_ERROR:
	ADD	DI,CX			; skip string data.
	MOVX	DS:[BX],NULSTRING	; null string buffer.

	BBERROR	126			; error message.
	MOV	AX,1			; 0=normal,1=error.
	RET
EXT_STRINGSET	ENDP


; *********************************************************
;	if condition.
;	-I-   ES:DI    : current pointer.
;	-I/O- TEXTPOFS : text offset pointer.(flash jump only)
;	-O-   AX       : 0=normal,1=jump,2=error.
; *********************************************************

IF_CONDITION	PROC	NEAR
	MOV	COND,1			; condition.
	MOVX	JMPADRS,ES:[DI]		; jump address.
	INC	DI			;
	INC	DI			;
	JMP	IF_CONDITION_LOOP	;

IF_CONDITION_OFF:			;
	AND	COND,BYTE PTR 11111110B	; condition.
IF_CONDITION_LOOP:
	MOV	AH,0			; dimension flag.
IF_CONDITION_INTER:			;
	MOV	AL,ES:[DI]		;
	INC	DI			;
	PUSH	ES			;
	PUSH	DI			;
	MOV	DX,DS			;
	MOV	ES,DX			;
	MOV	DI,OFFSET IF_CONDITION_TBL
	MOV	CX,IF_CONDITION_MAX	; condition max.
	REPNE	SCASB			;
	MOV	BP,DI			; BX=offset
	POP	DI			;
	POP	ES			;
	JMPNE	IF_CONDITION_ERROR	;

	DEC	BP			; -1
	SUB	BP,OFFSET IF_CONDITION_TBL
	SHL	BP,1			; word pointer.

	MOV	BX,ES:[DI]		; BX=dest.
	INC	DI			;
	INC	DI			;
	MOV	SI,ES:[DI]		; SI=source.
	INC	DI			;
	INC	DI			;
	CMP	AH,0			; dimension flag.
	JNE	IF_COND_JMPD		;
	JMP	WORD PTR DS:IF_CONDITION_JMP[BP]
IF_COND_JMPD:				;
	CMP	AH,1			; dimension flag.
	JNE	IF_COND_JMPD2		;
	JMP	WORD PTR DS:IF_CONDITION_JMP_DIM[BP]
IF_COND_JMPD2:				;
	JMP	WORD PTR DS:IF_CONDITION_JMP_DIM2[BP]
IF_COND_DIM:				; dimension.
	DEC	DI			;
	DEC	DI			;
	DEC	DI			;
	DEC	DI			;
	INC	AH			;
	JMP	IF_CONDITION_INTER	;

IF_COND_IMM_EQU:			; 1  IF immidiate =.
	CMP	DS:[BX],SI		;
	JE	IF_CONDITION_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_IMM_LT:				; 2  IF immidiate <.
	CMP	DS:[BX],SI		;
	JL	IF_CONDITION_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_IMM_GT:				; 3  IF immidiate >.
	CMP	DS:[BX],SI		;
	JG	IF_CONDITION_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_IMM_LE:				; 4  IF immidiate =<.
	CMP	DS:[BX],SI		;
	JLE	IF_CONDITION_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_IMM_GE:				; 5  IF immidiate >=.
	CMP	DS:[BX],SI		;
	JGE	IF_CONDITION_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_IMM_NOT:			; 6  IF immidiate !.
	CMP	DS:[BX],SI		;
	JNE	IF_CONDITION_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_MEM_EQU:			; 7  IF memory =.
	CMPX	DS:[BX],DS:[SI]		;
	JE	IF_CONDITION_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_MEM_LT:				; 8  IF memory <.
	CMPX	DS:[BX],DS:[SI]		;
	JL	IF_CONDITION_GOTO_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_MEM_GT:				; 9  IF memory >.
	CMPX	DS:[BX],DS:[SI]		;
	JG	IF_CONDITION_GOTO_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_MEM_LE:				; 10 IF memory =<.
	CMPX	DS:[BX],DS:[SI]		;
	JLE	IF_CONDITION_GOTO_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_MEM_GE:				; 11 IF memory >=.
	CMPX	DS:[BX],DS:[SI]		;
	JGE	IF_CONDITION_GOTO_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_MEM_NOT:			; 12 IF memory !.
	CMPX	DS:[BX],DS:[SI]		;
	JNE	IF_CONDITION_GOTO_LOOP	;
	JMP	IF_CONDITION_OFF	;
IF_COND_LOGICAL:			; 13 IF logical.
	DEC	DI			;
	DEC	DI			;
	CMP	WORD PTR DS:[BX],0	;
	JNE	IF_CONDITION_GOTO_LOOP	;
	JMP	IF_CONDITION_OFF	;

IF_CONDITION_GOTO_LOOP:			;
	JMP	IF_CONDITION_LOOP	;

IF_COND_D_IMM_EQU:			; 1  IF immidiate =.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	AX,ES:[DI]		; AX=source.
	INC	DI			;
	INC	DI			;
	CMP	DS:[BX],AX		;
	JE	IF_CONDITION_GOTO_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D_IMM_LT:			; 2  IF immidiate <.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	AX,ES:[DI]		; AX=source.
	INC	DI			;
	INC	DI			;
	CMP	DS:[BX],AX		;
	JL	IF_CONDITION_GOTO_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D_IMM_GT:			; 3  IF immidiate >.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	AX,ES:[DI]		; AX=source.
	INC	DI			;
	INC	DI			;
	CMP	DS:[BX],AX		;
	JG	IF_CONDITION_GOTO_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D_IMM_LE:			; 4  IF immidiate =<.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	AX,ES:[DI]		; AX=source.
	INC	DI			;
	INC	DI			;
	CMP	DS:[BX],AX		;
	JLE	IF_CONDITION_GOTO_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D_IMM_GE:			; 5  IF immidiate >=.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	AX,ES:[DI]		; AX=source.
	INC	DI			;
	INC	DI			;
	CMP	DS:[BX],AX		;
	JGE	IF_CONDITION_GOTO_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D_IMM_NOT:			; 6  IF immidiate !.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	AX,ES:[DI]		; AX=source.
	INC	DI			;
	INC	DI			;
	CMP	DS:[BX],AX		;
	JNE	IF_CONDITION_GOTO_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D_MEM_EQU:			; 7  IF memory =.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	SI,ES:[DI]		; SI=source.
	INC	DI			;
	INC	DI			;
	CMPX	DS:[BX],DS:[SI]		;
	JE	IF_CONDITION_GOTO_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D_MEM_LT:			; 8  IF memory <.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	SI,ES:[DI]		; SI=source.
	INC	DI			;
	INC	DI			;
	CMPX	DS:[BX],DS:[SI]		;
	JL	IF_CONDITION_GOTO2_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D_MEM_GT:			; 9  IF memory >.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	SI,ES:[DI]		; SI=source.
	INC	DI			;
	INC	DI			;
	CMPX	DS:[BX],DS:[SI]		;
	JG	IF_CONDITION_GOTO2_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D_MEM_LE:			; 10 IF memory =<.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	SI,ES:[DI]		; SI=source.
	INC	DI			;
	INC	DI			;
	CMPX	DS:[BX],DS:[SI]		;
	JLE	IF_CONDITION_GOTO2_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D_MEM_GE:			; 11 IF memory >=.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	SI,ES:[DI]		; SI=source.
	INC	DI			;
	INC	DI			;
	CMPX	DS:[BX],DS:[SI]		;
	JGE	IF_CONDITION_GOTO2_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D_MEM_NOT:			; 12 IF memory !.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	SI,ES:[DI]		; SI=source.
	INC	DI			;
	INC	DI			;
	CMPX	DS:[BX],DS:[SI]		;
	JNE	IF_CONDITION_GOTO2_LOOP	;
	JMP	IF_CONDITION_OFF	;
IF_COND_D_LOGICAL:			; 13 IF logical.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	CMP	WORD PTR DS:[BX],0	;
	JNE	IF_CONDITION_GOTO2_LOOP	;
	JMP	IF_CONDITION_OFF	;

IF_CONDITION_GOTO2_LOOP:		;
	JMP	IF_CONDITION_LOOP	;

IF_COND_D2_MEM_EQU:			; 7  IF memory =.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	SI,ES:[DI]		; SI=source.
	INC	DI			;
	INC	DI			;
	MOV	BP,ES:[DI]		; SI=source.
	MOV	AX,DS:[BP]		;
	INC	DI			;
	INC	DI			;
	SHL	AX,1			; word pointer.
	ADD	SI,AX			;
	CMPX	DS:[BX],DS:[SI]		;
	JE	IF_CONDITION_GOTO2_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D2_MEM_LT:			; 8  IF memory <.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	SI,ES:[DI]		; SI=source.
	INC	DI			;
	INC	DI			;
	MOV	BP,ES:[DI]		; SI=source.
	MOV	AX,DS:[BP]		;
	INC	DI			;
	INC	DI			;
	SHL	AX,1			; word pointer.
	ADD	SI,AX			;
	CMPX	DS:[BX],DS:[SI]		;
	JL	IF_CONDITION_GOTO2_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D2_MEM_GT:			; 9  IF memory >.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	SI,ES:[DI]		; SI=source.
	INC	DI			;
	INC	DI			;
	MOV	BP,ES:[DI]		; SI=source.
	MOV	AX,DS:[BP]		;
	INC	DI			;
	INC	DI			;
	SHL	AX,1			; word pointer.
	ADD	SI,AX			;
	CMPX	DS:[BX],DS:[SI]		;
	JG	IF_CONDITION_GOTO2_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D2_MEM_LE:			; 10 IF memory =<.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	SI,ES:[DI]		; SI=source.
	INC	DI			;
	INC	DI			;
	MOV	BP,ES:[DI]		; SI=source.
	MOV	AX,DS:[BP]		;
	INC	DI			;
	INC	DI			;
	SHL	AX,1			; word pointer.
	ADD	SI,AX			;
	CMPX	DS:[BX],DS:[SI]		;
	JLE	IF_CONDITION_GOTO3_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D2_MEM_GE:			; 11 IF memory >=.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	SI,ES:[DI]		; SI=source.
	INC	DI			;
	INC	DI			;
	MOV	BP,ES:[DI]		; SI=source.
	MOV	AX,DS:[BP]		;
	INC	DI			;
	INC	DI			;
	SHL	AX,1			; word pointer.
	ADD	SI,AX			;
	CMPX	DS:[BX],DS:[SI]		;
	JGE	IF_CONDITION_GOTO3_LOOP	;
	JMP	IF_CONDITION_OFF
IF_COND_D2_MEM_NOT:			; 12 IF memory !.
	MOV	AX,DS:[SI]		; dimension offset.
	SHL	AX,1			; word pointer.
	ADD	BX,AX			;
	MOV	SI,ES:[DI]		; SI=source.
	INC	DI			;
	INC	DI			;
	MOV	BP,ES:[DI]		; SI=source.
	MOV	AX,DS:[BP]		;
	INC	DI			;
	INC	DI			;
	SHL	AX,1			; word pointer.
	ADD	SI,AX			;
	CMPX	DS:[BX],DS:[SI]		;
	JNE	IF_CONDITION_GOTO3_LOOP	;
	JMP	IF_CONDITION_OFF	;

IF_CONDITION_GOTO3_LOOP:		;
	JMP	IF_CONDITION_LOOP	;

IF_COND_IF_OR:				; 14 IF or.
	DEC	DI			;
	DEC	DI			;
	DEC	DI			;
	DEC	DI			;
	STC				; next flag.
	RCL	COND,1			; condition.
	JMP	IF_CONDITION_LOOP	;
IF_COND_IFIO:				; 15 if i/o.
	DEC	DI			;
	DEC	DI			;
	DEC	DI			;
	DEC	DI			;
IF DEBUG4 ; condition.
	PRVB	"COND=",<WORD PTR COND>
ENDIF
	CMP	COND,0			; condition.
	JE	IF_CONDITION_JUMP	;
	JMP	IF_CONDITION_EXIT	;

IF_CONDITION_EXIT:
	MOV	AX,0			; 0=normal.
	RET
IF_CONDITION_JUMP:
IF DEBUG4 ; condition.
	PRVH	"JMPADRS=",JMPADRS
ENDIF
	MOV	AX,JMPADRS		; jump address.
	MOV	TEXTPOFS,AX		; text offset pointer.
	MOV	AX,1			; 1=jump.
	RET
IF_CONDITION_ERROR:
	BBERROR	108			; error message.
	MOV	AX,2			; 2=error.
	RET
IF_CONDITION	ENDP


; *********************************************************
;	direct command.
;	-I/O- ES:DI    : current pointer.
; *********************************************************

DIRECT_CMND	PROC	NEAR

	MOV	AL,ES:[DI]		; value address.
	INC	DI			;

	CMP	AL,'P'			;
	JE	DIRECT_CMND_PAUSE	;
	CMP	AL,'C'			;
	JE	DIRECT_CMND_CLS		;
	CMP	AL,'L'			;
	JE	DIRECT_CMND_LF		;
	CMP	AL,'G'			;
	JE	DIRECT_CMND_EDTX	;
	CMP	AL,'T'			;
	JE	DIRECT_CMND_TIMER	;
	CMP	AL,'@'			;
	JE	DIRECT_CMND_EXIT	;

DIRECT_CMND_TXSLCT:
	SUB	AL,'0'
	JZ	DIRECT_CMND_EXIT	;
	CMP	AL,9			;
	JNBE	DIRECT_CMND_EXIT	;
	MOV	DL,AL			;
	MOV	DH,0			;
	PUSH	ES
	PUSH	DI
	CALL	c_WID_TEXT_STRIME	; WINDOWS/テキストウインドウ選択
	POP	DI
	POP	ES
	JMP	DIRECT_CMND_EXIT
DIRECT_CMND_PAUSE:
	PUSH	ES
	PUSH	DI
	CALL	c_WID_TEXT_PAUSE	; WINDOWS/テキストウインドウＰＡＵＳＥ
	POP	DI
	POP	ES
	JMP	DIRECT_CMND_EXIT
DIRECT_CMND_CLS:
	PUSH	ES
	PUSH	DI
	CALL	c_WID_TEXT_CLR		; WINDOWS/テキストウインドウクリア
	POP	DI
	POP	ES
	JMP	DIRECT_CMND_EXIT
DIRECT_CMND_LF:
	PUSH	ES
	PUSH	DI
	CALL	c_WID_TEXT_LF		; WINDOWS/テキストウインドウ改行
	POP	DI
	POP	ES
	JMP	DIRECT_CMND_EXIT
DIRECT_CMND_EDTX:
	MOV	TEXTPOFS,DI		; text offset pointer.
	CALLE	BBTX2BUF		; ﾃｷｽﾄ編集ﾊﾞｯﾌｧへの取込開始
	MOV	DI,TEXTPOFS		; text offset pointer.
	MOV	ES,TEXTPSEG		; text segment pointer.
	JMP	DIRECT_CMND_EXIT
DIRECT_CMND_TIMER:
	CALLE	c_WID_TEXT_TIMER	; WINDOWS/テキストウインドウタイマ
	JMP	DIRECT_CMND_EXIT
DIRECT_CMND_EXIT:
	RET
DIRECT_CMND	ENDP


; *********************************************************
;	line analyze.
;	-I- COMPLINESOU : comp line buffer source.
;	-O- COMPLINEBIN : comp line buffer binary.
;	    AX          : 0=complete,1=not compiled,2=error.
;	    PNTSOU      : comp line buffer source.
;	    PNTBIN      : comp line buffer binary.
;	    CBINALEN    : binary line length.
; *********************************************************

LINEALZE	PROC	NEAR
	MOVX	PNTSOU,COMPLINESOU	; comp line buffer source.
	MOVX	PNTBIN,COMPLINEBIN	; comp line buffer binary.

	MOV	NOWNEST,0		; now nesting.
	MOVX	ES,DS
	MOV	SI,PNTSOU		; comp line buffer source.
	MOV	DI,PNTBIN		; comp line buffer binary.
LINEALZE_LP1:
	LODSB				; get.
	CMP	AL,CHR_TAB		; TAB.
	JNE	LINEALZE_LP_E1		;
	STOSB				; put.
	INC	NOWNEST			; now nesting.
	JMP	LINEALZE_LP1		;
LINEALZE_LP_E1:
	DEC	SI
	MOV	PNTSOU,SI		; comp line buffer source.
	MOV	PNTBIN,DI		; comp line buffer binary.

LINEALZE_LOOP:
	CALL	CHK_PRINT_STRING	; check print string.

LINEALZE_CHK:
	CMP	AL,EOS			; end of string.
	JMPEQ	LINEALZE_EXIT		;
	CMP	AL,"."			; '.' define.
	JMPEQ	LINEALZE_DEF		;
	CMP	AX," L"			; "L XXXX" load command.
	JMPEQ	LINEALZE_NOT		;
	CMP	AL,MARKCOMMENT		; ';' comment mark.
	JMPEQ	LINEALZE_EXIT		;
	CMP	AL,MARKCOMMENT2		; ':' comment mark.
	JMPEQ	LINEALZE_EXIT		;
	CMP	AL,MARKLABEL		; '*' label mark.
	JE	LINEALZE_2		;
	JMP	LINEALZE_22		;
LINEALZE_2:
	SKIP_NOTSPACE			; skip not space.
LINEALZE_22:
	MOV	PNTSOU,SI		; comp line buffer source.

	MOV	AL,DS:[SI]		;
	CMP	AL,MARKIF		; ? if mark.
	JMPEQ	LINEALZE_CMD_QUES	;

	CMP	AL,TAG_DIRECTCOM	; direct command "@"
	JMPEQ	LINEALZE_CMD_DIRECT	;

	CALL	SYMBOLGET		; symbol get.
	CMP	STRSYMLEN,0		; symbol length.
	JMPEQ	LINEALZE_ERROR_CHK	;

;*;	CALL	BBJP2_JCHKONRY		; jump2 check "J999"
;*;	CMP	AX,0			; 0=search,1=none.
;*;	JE	LINEALZE_CMD_J1000	;

	STRCOMP	CMD_IF			; command "IF"
	JMPC	LINEALZE_CMD_IF		;

	STRCOMP	CMD_GOTO		; command "GOTO"
	JMPC	LINEALZE_CMD_JUMP	;

	STRCOMP	CMD_RET			; command "RET"
	JMPC	LINEALZE_CMD_RET	;

	STRCOMP	CMD_LOOP		; command "LOOP"
	JMPC	LINEALZE_CMD_LOOP	;

	MOV	DI,STRSYMBOL		; symbol string.
	MOV	CX,STRSYMLEN		; text offset pointer.
	CALL	BBJP_TABLESCH		; jump table search.
	CMP	AX,0			; 0=search,1=none.
	JMPEQ	LINEALZE_TEXT_CALL	;

	CALL	SYMBOLE_SCH		; symbol search.
	CMP	AX,0			; 0=search,1=none.
	JMPNE	LINEALZE_ERROR2		;

	CMP	SYMSEGM,SEG DATA	; segment of symbol.
	JE	LINEALZE_CMD_CALC	;

	JMP	LINEALZE_ASM_CALL	;

LINEALZE_CMD_CALC:			;
	CALL	CALC_CONVERT		; calc convert.
	CMP	AX,0			; 0=normal,1=error.
	JNE	LINEALZE_ERROR		;
	JMP	LINEALZE_NEXT		;

;*;LINEALZE_CMD_J1000:			;
;*;	CALL	BBJP2_TABLESCH		; jump2 table search.
;*;	CMP	AX,0			; 0=search,1=none.
;*;	JMPNE	LINEALZE_ERROR		;
;*;
;*;	MOVX	ES,DS			;
;*;	MOV	DI,PNTBIN		; comp line buffer binary.
;*;	MOV	AL,TAG_TEXTJUMP		; text jump.
;*;	STOSB				;
;*;	MOV	AL,DL			; jump address.
;*;	STOSB				;
;*;	MOV	AL,DH			; jump address.
;*;	STOSB				;
;*;	MOV	PNTBIN,DI		; comp line buffer binary.
;*;	JMP	LINEALZE_NEXT		;

LINEALZE_CMD_IF:			;
	CALL	IF_JUMP_SCH		; IF jump search.
	CALL	CONVERT_IF		; if set.
	CMP	AX,0			; 0=normal,1=error.
	JMPNE	LINEALZE_ERROR_IF	;
	JMP	LINEALZE_NEXT		;

LINEALZE_CMD_QUES:			;
	INC	PNTSOU			; comp line buffer source.
	CALL	QES_JUMP_SCH		; ?(question) jump search.
	CALL	QUESTION_IF		; question set.
	CMP	AX,0			; 0=normal,1=error.
	JMPNE	LINEALZE_ERROR_IF	;
	JMP	LINEALZE_NEXT		;

LINEALZE_CMD_DIRECT:			;
	ADD	PNTSOU,2		; comp line buffer source.
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOVSW				; 2byte move.
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	LINEALZE_NEXT		;

LINEALZE_CMD_JUMP:			;
	CALL	SYMBOLGET		; symbol get.
	CMP	STRSYMLEN,0		; symbol length.
	JMPEQ	LINEALZE_ERROR		;

	MOV	DI,STRSYMBOL		; symbol string.
	MOV	CX,STRSYMLEN		; text offset pointer.
	CALL	BBJP_TABLESCH		; jump table search.
	CMP	AX,0			; 0=search,1=none.
	JMPNE	LINEALZE_ERROR		;

	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_TEXTJUMP		; text jump.
	STOSB				;
	MOV	AL,DL			; jump address.
	STOSB				;
	MOV	AL,DH			; jump address.
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	LINEALZE_NEXT		;

LINEALZE_ASM_CALL:
	CMP	SYMSEGM,SEG CODE	; segment of symbol.
	JE	LINEALZE_ASM_00CALL	;
	CMP	SYMSEGM,SEG CODE01	; segment of symbol.
	JE	LINEALZE_ASM_01CALL	;
	JMP	LINEALZE_ERROR		;

LINEALZE_ASM_00CALL:
	MOVX	STK_CALL_ADRS,SYMOFST		; stack call address.
	MOV	STK_CALL_CMND,TAG_ASMCALL	; asm call(CODE)
	CALL	STK_CALL_SET			; stack call set.
	CMP	AX,1				; 0=normal,1=error.
	JMPEQ	LINEALZE_ERROR			;
	JMP	LINEALZE_NEXT

LINEALZE_ASM_01CALL:
	MOVX	STK_CALL_ADRS,SYMOFST		; stack call address.
	MOV	STK_CALL_CMND,TAG_ASMCL01	; asm call(CODE01)
	CALL	STK_CALL_SET			; stack call set.
	CMP	AX,1				; 0=normal,1=error.
	JMPEQ	LINEALZE_ERROR			;
	JMP	LINEALZE_NEXT

LINEALZE_TEXT_CALL:
	MOV	STK_CALL_ADRS,DX		; stack call address.
	MOV	STK_CALL_CMND,TAG_TEXTCALL	; text call.
	CALL	STK_CALL_SET			; stack call set.
	CMP	AX,1				; 0=normal,1=error.
	JMPEQ	LINEALZE_ERROR			;
	JMP	LINEALZE_NEXT			;

LINEALZE_CMD_RET:			;
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_RET		; ret
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	LINEALZE_NEXT		;

LINEALZE_CMD_LOOP:			;
	CALL	SYMBOLGET		; symbol get.
	CMP	STRSYMLEN,0		; symbol length.
	JMPEQ	LINEALZE_ERROR		;

	CALL	SYMBOLE_SCH		; symbol search.
	CMP	AX,0			; 0=search,1=none.
	JMPNE	LINEALZE_ERROR		;

	CMP	SYMSEGM,SEG DATA	; segment of symbol.
	JMPNE	LINEALZE_ERROR		;

	CALL	LOOP_JUMP_SCH		; LOOP jump search.

	CALL	DIMENSION_GET		; dimension get.
	CMP	AX,1			; 0=none,1=memory,2=immidiate,3=error.
	JE	LINEALZE_LOOP_DIM	;
	CMP	AX,3			;
	JE	LINEALZE_ERROR		;

	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_EXTEND		; extend.
	STOSB				;
	MOV	AL,TAG_EXT_LOOP		; loop.
	STOSB				;
	MOV	AX,SYMOFST		; offset of symbol.
	ADD	AX,DIM_OFST		; dimension offset.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	AX,JUMPPNT_LOOP		; LOOP jump point.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	LINEALZE_NEXT
LINEALZE_LOOP_DIM:
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_EXTEND		; extend.
	STOSB				;
	MOV	AL,TAG_EXT_LOOP_D	; 'l' loop dimension.
	STOSB				;
	MOV	AX,SYMOFST		; offset of symbol.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	AX,SOUSYMOFST		; offset of source symbol.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	AX,JUMPPNT_LOOP		; LOOP jump point.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	LINEALZE_NEXT

LINEALZE_DEF:
	MOV	PNTSOU,SI		; comp line buffer source.
	CALL	COMPDEF			; compile define.
LINEALZE_NEXT:
	JMP	LINEALZE_LOOP

LINEALZE_ERROR_CHK:
	MOV	SI,PNTSOU		; comp line buffer source.
	LODSB				; get.
	CMP	AL,' '			; space
	JBE	LINEALZE_EXIT		;
	JMP	LINEALZE_ERROR		;

LINEALZE_EXIT:
	MOV	BX,PNTBIN		; comp line buffer binary.
	SUB	BX,COMPLINEBIN		; comp line buffer binary.
	MOV	CBINALEN,BX		; binary line length.
	MOV	AX,0			; 0=complete.
	RET
LINEALZE_NOT:
	MOV	AX,1			; 1=not compiled.
	RET
LINEALZE_ERROR_IF:
	BBERROR	108			; error message.
	MOV	AX,2			; 2=error.
	RET
LINEALZE_ERROR:
	BBERROR	107			; error message."inline compile error"
	MOV	AX,2			; 2=error.
	RET
LINEALZE_ERROR2:
	BBERROR	116			; error message."compile symbol undefined."
	MOV	AX,2			; 2=error.
	RET
LINEALZE	ENDP


; *********************************************************
;	check print string.
;	-I/O- PNTSOU : comp line buffer source.
;	      PNTBIN : comp line buffer binary.
; *********************************************************

CHK_PRINT_STRING	PROC	NEAR
	MOVX	ES,DS			;
	MOV	PR_IO,0			; print i/o.
CHK_PRINT_STRING_LOOP:
	MOV	SI,PNTSOU		; comp line buffer source.

	CMP	PR_IO,0			; print i/o.
	JNE	CHK_PRINT_STRING_2	;
	SKIP_SPACE			; skip space.
CHK_PRINT_STRING_2:			;

	MOV	DX,DS:[SI]		; get.
	PUSH	ES			;
	PUSH	SI			;
	CALL	BBSJISCHK		; シフトＪＩＳチェック
	POP	SI			;
	POP	ES			;
	CMP	AX,0			; 0=normal,1=shift jis code.
	JE	CHK_PRINT_STRING_CHK	;

	MOV	DI,PNTBIN		; comp line buffer binary.
	MOVSW				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	MOV	PNTSOU,SI		; comp line buffer source.
	JMP	CHK_PRINT_STRING_LOOP	;

CHK_PRINT_STRING_CHK:			;
	MOV	AL,DS:[SI]		; get.
	CMP	AL,TAG_PRINT		; print string."""
	JNE	CHK_PRINT_STRING_CHK2	;

	MOV	DI,PNTBIN		; comp line buffer binary.
	MOVSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	MOV	PNTSOU,SI		; comp line buffer source.
	NOT	PR_IO			; print i/o.
	JMP	CHK_PRINT_STRING_LOOP	;

CHK_PRINT_STRING_CHK2:			;
	CMP	PR_IO,0			; print i/o.
	JE	CHK_PRINT_STRING_EXIT	;
	CMP	AL,CHR_SPACE		; space.
	JB	CHK_PRINT_STRING_EXIT	;

	MOV	DI,PNTBIN		; comp line buffer binary.
	MOVSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	MOV	PNTSOU,SI		; comp line buffer source.
	JMP	CHK_PRINT_STRING_LOOP	;

CHK_PRINT_STRING_EXIT:			;
	RET
CHK_PRINT_STRING	ENDP


; *********************************************************
;	print string.
;	-I/O- ES:DI    : current pointer.
; *********************************************************

PRINT_STRING	PROC	NEAR
	DEC	DI			;
	MOV	TEXTPOFS,DI		; text offset pointer.
	CALL	BBMES_ALPHA		; text message alphabet.
	MOV	DI,TEXTPOFS		; text offset pointer.
	RET
PRINT_STRING	ENDP


; *********************************************************
;	compile define.
;	-I/O- PNTSOU : comp line buffer source.
; *********************************************************

COMPDEF	PROC	NEAR
	PUSH	TEXTPSEG		; text segment pointer.
	PUSH	TEXTPOFS		; text offset pointer.

	MOV	TEXTPSEG,DS		; text segment pointer.
	MOVX	TEXTPOFS,PNTSOU		; comp line buffer source.

	CALL	BBDEFINE		; define.
	MOVX	PNTSOU,TEXTPOFS		; comp line buffer source.

	POP	TEXTPOFS		; text offset pointer.
	POP	TEXTPSEG		; text segment pointer.
	RET
COMPDEF	ENDP


; *********************************************************
;	calc convert.
;	-I-   SYMSEGM  : segment of symbol.
;	      SYMOFST  : offset of symbol.
;	-I/O- PNTSOU   : comp line buffer source.
;	      PNTBIN   : comp line buffer binary.
;	-O-   AX       : 0=normal,1=error.
; *********************************************************

CALC_CONVERT	PROC	NEAR
	MOV	SI,PNTSOU		; comp line buffer source.
	SKIP_SPACE			; skip space.
	MOV	PNTSOU,SI		; comp line buffer source.

	CALL	DIMENSION_GET		; dimension get.
	MOV	DESTDIMTYPE,AX		; dest dimension type.
	MOVX	DESTDIMAD,SOUSYMOFST	; offset of source symbol.
	MOVX	DESTDIMIMM,DIM_OFST	; dimension offset.
	MOVX	DESTADRS,SYMOFST	; destination adrs.

	CMP	AX,3			;
	JMPEQ	CALC_CONVERT_ERROR	;

	MOV	SI,PNTSOU		; comp line buffer source.
	LODSW				;
	CMP	AX,'++'			; ++ inc.
	JMPEQ	CALC_CONVERT_INC	;
	CMP	AX,'--'			; -- dec.
	JMPEQ	CALC_CONVERT_DEC	;
	CMP	AX,'=+'			; += source set & add.
	JE	CALC_CONVERT_S_ADD	;
	CMP	AX,'=-'			; -= source set & sub.
	JE	CALC_CONVERT_S_SUB	;
	CMP	AX,'=*'			; *= source set & mul.
	JE	CALC_CONVERT_S_MUL	;
	CMP	AX,'=/'			; /= source set & div.
	JE	CALC_CONVERT_S_DIV	;

	CMP	AL,'='			; memory.
	JMPNE	CALC_CONVERT_LOOP_START	;

	DEC	SI			;
	SKIP_SPACE			; skip space.
	LODSB				;
	CMP	AL,'"'			;
	JMPEQ	CALC_CONVERT_STRING	;
	CMP	AL,"'"			;
	JMPEQ	CALC_CONVERT_STRING	;
	JMP	CALC_CONVERT_LOOP_START	;

CALC_CONVERT_S_ADD:			;
	MOV	COPRA,1			; 1 + calc operation.
	JMP	CALC_CONVERT_S_MEMORY	;

CALC_CONVERT_S_SUB:			;
	MOV	COPRA,2			; 2 - calc operation.
	JMP	CALC_CONVERT_S_MEMORY	;

CALC_CONVERT_S_MUL:			;
	MOV	COPRA,3			; 3 * calc operation.
	JMP	CALC_CONVERT_S_MEMORY	;

CALC_CONVERT_S_DIV:			;
	MOV	COPRA,4			; 4 / calc operation.
	JMP	CALC_CONVERT_S_MEMORY	;

CALC_CONVERT_S_MEMORY:			;
	SKIP_SPACE			; skip space.

	CMP	DESTDIMTYPE,1		; dest dimension type.
	JNE	CALC_CONVERT_SOU_SET	; 0=none,1=memory,2=immidiate,3=error
CALC_CONVERT_SOU_DIM:			;
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_DIM		; dimension.
	STOSB				;
	MOV	AL,TAG_MEMEQU		; memory =
	STOSB				;
	MOV	AX,SYMOFST		; offset of symbol.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	AX,SOUSYMOFST		; offset of source symbol.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	CALC_CONVERT_5		;

CALC_CONVERT_SOU_SET:			;
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_MEMEQU		; memory =
	STOSB				;
	MOV	AX,SYMOFST		; offset of symbol.
	ADD	AX,DIM_OFST		; dimension offset.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	CALC_CONVERT_5		;

CALC_CONVERT_LOOP_START:		;

CALC_CONVERT_LOOP:
	MOV	SI,PNTSOU		; comp line buffer source.
	SKIP_SPACE			; skip space.
	MOV	PNTSOU,SI		; comp line buffer source.
	LODSB				;
	MOV	COPRA,0			; 0 = calc operation.
	CMP	AL,'='			;
	JE	CALC_CONVERT_5		;
	INC	COPRA			; 1 + calc operation.
	CMP	AL,'+'			;
	JE	CALC_CONVERT_5		;
	INC	COPRA			; 2 - calc operation.
	CMP	AL,'-'			;
	JE	CALC_CONVERT_5		;
	INC	COPRA			; 3 * calc operation.
	CMP	AL,'*'			;
	JE	CALC_CONVERT_5		;
	INC	COPRA			; 4 / calc operation.
	CMP	AL,'/'			;
	JE	CALC_CONVERT_5		;

	JMP	CALC_CONVERT_DEST	;
CALC_CONVERT_5:
	MOV	PNTSOU,SI		; comp line buffer source.

	CALL	SYMBOLGET		; symbol get.
	CMP	STRSYMLEN,0		; symbol length.
	JMPEQ	CALC_CONVERT_ERROR	;

	MOV	SI,STRSYMBOL		; symbol string.
	MOV	CX,STRSYMLEN		; symbol length.
	CALL	BBNUMBER		; 文字列－＞数字チェック
	CMP	AX,1			; 0=正常,1=数字列ではない
	JE	CALC_CONVERT_6		;

	MOV	BX,WORD PTR COPRA	; calc operation.
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,DS:TBL_TAG_IMM[BX]	; immidiate tag table.
	STOSB				;
	MOV	AL,DL			; loop.
	STOSB				;
	MOV	AL,DH			; value address.
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	CALC_CONVERT_7		;

CALC_CONVERT_6:				;
	CALL	SYMBOLE_SCH		; symbol search.
	CMP	AX,0			; 0=search,1=none.
	JMPNE	CALC_CONVERT_ERROR	;

	CMP	SYMSEGM,SEG DATA	; segment of symbol.
	JMPNE	CALC_CONVERT_ERROR	;

	CALL	DIMENSION_GET		; dimension get.
	CMP	AX,0			; 0=none,1=memory,2=immidiate,3=error.
	JE	CALC_CONVERT_SET	;
	CMP	AX,2			;
	JE	CALC_CONVERT_SET	;
	CMP	AX,3			;
	JMPEQ	CALC_CONVERT_ERROR	;

CALC_CONVERT_DIM:			;
	MOV	BX,WORD PTR COPRA	; calc operation.
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_DIM		; dimension.
	STOSB				;
	MOV	AL,DS:TBL_TAG_MEM[BX]	; memory tag table.
	STOSB				;
	MOV	AX,SYMOFST		; offset of symbol.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	AX,SOUSYMOFST		; offset of source symbol.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	CALC_CONVERT_7		;

CALC_CONVERT_SET:			;
	MOV	BX,WORD PTR COPRA	; calc operation.
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,DS:TBL_TAG_MEM[BX]	; memory tag table.
	STOSB				;
	MOV	AX,SYMOFST		; offset of symbol.
	ADD	AX,DIM_OFST		; dimension offset.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	CALC_CONVERT_7		;

CALC_CONVERT_7:				;
	JMP	CALC_CONVERT_LOOP	;

CALC_CONVERT_INC:
	MOV	PNTSOU,SI		; comp line buffer source.
	CMP	DESTDIMTYPE,1		; 0=none,1=memory,2=immidiate,3=error.
	JE	CALC_CONVERT_INC_DIM	;
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_MEMINC		; memory ++
	STOSB				;
	MOV	AX,SYMOFST		; offset of symbol.
	ADD	AX,DESTDIMIMM		; dimension offset.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	CALC_CONVERT_EXIT	;

CALC_CONVERT_INC_DIM:			;
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_DIM		; dimension.
	STOSB				;
	MOV	AL,TAG_MEMINC		; memory ++
	STOSB				;
	MOV	AX,SYMOFST		; offset of symbol.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	AX,DESTDIMAD		; offset of source symbol.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	CALC_CONVERT_EXIT	;

CALC_CONVERT_DEC:
	MOV	PNTSOU,SI		; comp line buffer source.
	CMP	DESTDIMTYPE,1		; 0=none,1=memory,2=immidiate,3=error.
	JE	CALC_CONVERT_DEC_DIM	;
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_MEMDEC		; memory --
	STOSB				;
	MOV	AX,SYMOFST		; offset of symbol.
	ADD	AX,DESTDIMIMM		; dimension offset.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	CALC_CONVERT_EXIT	;

CALC_CONVERT_DEC_DIM:			;
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_DIM		; dimension.
	STOSB				;
	MOV	AL,TAG_MEMDEC		; memory --
	STOSB				;
	MOV	AX,SYMOFST		; offset of symbol.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	AX,DESTDIMAD		; offset of source symbol.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	CALC_CONVERT_EXIT	;

CALC_CONVERT_STRING:			;
	MOV	CL,AL			; delimiter.
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	CMP	DESTDIMTYPE,1		; 0=none,1=memory,2=immidiate,3=error.
	JE	CALC_CONVERT_STRDIM	;

	MOV	AL,TAG_EXTEND		; extend.
	STOSB				;
	MOV	AL,TAG_EQUSTR		; ="string"
	STOSB				;
	MOV	AX,SYMOFST		; offset of symbol.
	ADD	AX,DESTDIMIMM		; dimension offset.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	CALC_CONVERT_STRSET	;

CALC_CONVERT_STRDIM:			;
	MOV	AL,TAG_EXTEND		; extend.
	STOSB				;
	MOV	AL,TAG_DIM		; dimension.
	STOSB				;
	MOV	AL,TAG_EQUSTR		; ="string"
	STOSB				;
	MOV	AX,SYMOFST		; offset of symbol.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	AX,DESTDIMAD		; offset of source symbol.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	CALC_CONVERT_STRSET	;

CALC_CONVERT_STRSET:			;
	MOV	AL,0			;
	STOSB				; counter area.
	MOV	DX,0			; counter.
CALC_CONVERT_LOOP5:			;
	CMP	DX,MAX_STRING_LEN	; max string length.
	JNBE	CALC_CONVERT_LOOP_E5	;

	PUSH	DX			;
	MOV	DX,DS:[SI]		;
	CALL	BBSJISCHK		; シフトＪＩＳチェック
	POP	DX			;
	CMP	AX,1			; 0=normal,1=shift jis code.
	JE	CALC_CONVERT_STR55	;

	LODSB				;
	CMP	AL,CL			; delimiter.
	JE	CALC_CONVERT_LOOP_E5	;
	CMP	AL,0			; end of string.
	JE	CALC_CONVERT_LOOP_E5	;
	STOSB				;
	INC	DX			; counter.
	JMP	CALC_CONVERT_LOOP5	;
CALC_CONVERT_STR55:			;
	MOVSW				;
	INC	DX			; counter.
	INC	DX			;
	JMP	CALC_CONVERT_LOOP5	;

CALC_CONVERT_LOOP_E5:			;
	MOV	PNTSOU,SI		; comp line buffer source.
	MOV	BX,PNTBIN		; comp line buffer binary.
	MOV	ES:[BX],DL		; counter
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	CALC_CONVERT_EXIT	;

CALC_CONVERT_DEST:
	CMP	DESTDIMTYPE,1		; 0=none,1=memory,2=immidiate,3=error.
	JE	CALC_CONVERT_DEST_DIM	;
CALC_CONVERT_DESTSET:
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_MEM		; memory.
	STOSB				;
	MOV	AX,DESTADRS		; destination adrs.
	ADD	AX,DESTDIMIMM		; dimension offset.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	CALC_CONVERT_EXIT	;

CALC_CONVERT_DEST_DIM:
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_DIM		; dimension.
	STOSB				;
	MOV	AL,TAG_MEM		; memory.
	STOSB				;
	MOV	AX,DESTADRS		; destination adrs.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	AX,DESTDIMAD		; offset of source symbol.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	CALC_CONVERT_EXIT	;

CALC_CONVERT_EXIT:
	MOV	AX,0			; 0=normal.
	RET
CALC_CONVERT_ERROR:
	MOV	AX,1			; 1=error.
	RET
CALC_CONVERT	ENDP


; *********************************************************
;	symbol search.
;	-I- STRSYMBOL : symbol string.
;	    STRSYMLEN : symbol length.
;	-O- AX        : 0=search,1=none.
;	    SYMSEGM   : segment of symbol.
;	    SYMOFST   : offset of symbol.
; *********************************************************

SYMBOLE_SCH	PROC	NEAR
	CALL	BBSYMBOL_SCH		; symbol table search.
	CMP	AX,0			; 0=search,1=none.
	JNE	SYMBOLE_SCH_NO		;
SYMBOLE_SCH_YES:
	MOV	AX,0			; 0=search.
	RET
SYMBOLE_SCH_NO:
	MOV	AX,1			; 1=none.
	RET
SYMBOLE_SCH	ENDP


; *********************************************************
;	dimension get.
;	-I/O- PNTSOU    : comp line buffer source.
;	-O-   AX        : 0=none,1=memory,2=immidiate,3=error.
;	      SOUSYMSEGM: segment of source symbol.
;	      SOUSYMOFST: offset of source symbol.
;	      DIM_OFST  : dimension offset.
; *********************************************************

DIMENSION_GET	PROC	NEAR
	PUSH	SI
	MOVX	ES,DS			;
	MOV	SI,PNTSOU		; comp line buffer source.
	SKIP_SPACE			; skip space.
	CALL	BBSTRDIM_GET		; 文字列から配列添字取出
	MOV	PNTSOU,SI		; comp line buffer source.
	CMP	AX,0			; 0=none,1=memory,2=immidiate,3=error.
	JE	DIMENSION_GET_9		;
	CMP	AX,3			;
	JE	DIMENSION_GET_9		;
	PUSH	AX			;
	MOV	SI,PNTSOU		; comp line buffer source.
	SKIP_SPACE			; skip space.
	MOV	PNTSOU,SI		; comp line buffer source.
	POP	AX			;
DIMENSION_GET_9:
	POP	SI
	RET
DIMENSION_GET	ENDP


; *********************************************************
;	question set.
;	-I-   JUMPPNT_QUES  : ?(question) jump point.
;	-I/O- PNTSOU        : comp line buffer source.
;	      PNTBIN        : comp line buffer binary.
;	-O-   AX            : 0=normal,1=error.
; *********************************************************

QUESTION_IF	PROC	NEAR
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_IFIO		; if i/o.
	STOSB				;
	MOV	AX,JUMPPNT_QUES		; ?(question) jump point.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.

	CALL	SET_IF			; if set.
	RET
QUESTION_IF	ENDP


; *********************************************************
;	if set.
;	-I-   JUMPPNT_IF    : IF jump point.
;	-I/O- PNTSOU        : comp line buffer source.
;	      PNTBIN        : comp line buffer binary.
;	-O-   AX            : 0=normal,1=error.
; *********************************************************

CONVERT_IF	PROC	NEAR
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_IFIO		; if i/o.
	STOSB				;
	MOV	AX,JUMPPNT_IF		; IF jump point.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.

	CALL	SET_IF			; if set.
	RET
CONVERT_IF	ENDP


; *********************************************************
;	if set.
;	-I-   JUMPPNT_IF    : IF jump point.
;	-I/O- PNTSOU        : comp line buffer source.
;	      PNTBIN        : comp line buffer binary.
;	-O-   AX            : 0=normal,1=error.
; *********************************************************

SET_IF	PROC	NEAR
	MOV	SI,PNTSOU		; comp line buffer source.
	SKIP_SPACE			; skip space.
	MOV	PNTSOU,SI		; comp line buffer source.

	CMP	BYTE PTR DS:[SI],MARKBEGIN ; ( begin mark.
	JNE	SET_IF_CMDSET		;

	INC	PNTSOU			; comp line buffer source.

SET_IF_LOOP:				;
	MOV	SI,PNTSOU		; comp line buffer source.
	SKIP_SPACE			; skip space.
	MOV	PNTSOU,SI		; comp line buffer source.

	MOV	SI,PNTSOU		; comp line buffer source.
	CMP	BYTE PTR DS:[SI],MARKEND ; ) end mark.
	JE	SET_IF_LOOP_E		;

	CALL	COND_CONV		; condition convert.
	CMP	AX,0			; 0=normal,1=error.
	JNE	SET_IF_ERROR		;

	JMP	SET_IF_LOOP		;
SET_IF_LOOP_E:				;
	INC	PNTSOU			; comp line buffer source.

	MOV	SI,PNTSOU		; comp line buffer source.
	SKIP_SPACE			; skip space.
	MOV	PNTSOU,SI		; comp line buffer source.

	MOV	SI,PNTSOU		; comp line buffer source.
	CMP	BYTE PTR DS:[SI],MARKBEGIN ; ( begin mark.
	JNE	SET_IF_SET		;

	INC	PNTSOU			; comp line buffer source.

	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_IF_OR		; IF or.
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.

	JMP	SET_IF_LOOP		;

SET_IF_CMDSET:
	CALL	COND_CONV		; condition convert.
	CMP	AX,0			; 0=normal,1=error.
	JNE	SET_IF_ERROR		;
SET_IF_SET:
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_IFIO		; if i/o.
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
SET_IF_EXIT:
	MOV	AX,0			; 0=normal.
	RET
SET_IF_ERROR:
	MOV	AX,1			; 1=error.
	RET
SET_IF	ENDP


; *********************************************************
;	condition convert.
;	-I/O- PNTSOU        : comp line buffer source.
;	      PNTBIN        : comp line buffer binary.
;	-O-   AX            : 0=normal,1=error.
; *********************************************************

COND_CONV	PROC	NEAR
	MOV	DESTDIMTYPE,0		; dest dimension type.
	MOV	DESTDIMTYPE2,0		; dest dimension type2.
	MOV	DESTDIMIMM,0		; dimension offset.
	MOV	DESTDIMIMM2,0		; dimension offset2.

	CALL	SYMBOLGET		; symbol get.
	CMP	STRSYMLEN,0		; symbol length.
	JMPEQ	COND_CONV_ERROR		;

	MOV	SI,STRSYMBOL		; symbol string.
	MOV	CX,STRSYMLEN		; symbol length.
	CALL	BBNUMBER		; 文字列－＞数字チェック
	CMP	AX,0			; 0=正常,1=数字列ではない
	JMPEQ	COND_CONV_ERROR		;

	CALL	SYMBOLE_SCH		; symbol search.
	CMP	AX,1			; 0=search,1=none.
	JMPEQ	COND_CONV_ERROR		;

	CMP	SYMSEGM,SEG DATA	; segment of symbol.
	JMPNE	COND_CONV_ERROR		;

	MOVX	VALDES,SYMOFST		; offset of symbol.

	MOV	SI,PNTSOU		; comp line buffer source.
	SKIP_SPACE			; skip space.
	MOV	PNTSOU,SI		; comp line buffer source.

	CALL	DIMENSION_GET		; dimension get.
	MOV	DESTDIMTYPE,AX		; dest dimension type.
	MOVX	DESTDIMAD,SOUSYMOFST	; offset of source symbol.
	MOVX	DESTDIMIMM,DIM_OFST	; dimension offset.

	CMP	DESTDIMTYPE,3		; 3=error.
	JMPEQ	COND_CONV_ERROR		;

	MOV	SI,PNTSOU		; comp line buffer source.
	SKIP_SPACE			; skip space.
	MOV	PNTSOU,SI		; comp line buffer source.

	LODSW				;

	CMP	AX,'<='			;
	JE	COND_CONV_LE		;
	CMP	AX,'=<'			;
	JE	COND_CONV_LE		;
	CMP	AX,'>='			;
	JE	COND_CONV_GE		;
	CMP	AX,'=>'			;
	JE	COND_CONV_GE		;
	CMP	AL,'='			;
	JE	COND_CONV_EQU		;
	CMP	AL,'<'			;
	JE	COND_CONV_LT		;
	CMP	AL,'>'			;
	JE	COND_CONV_GT		;
	CMP	AL,'!'			;
	JE	COND_CONV_NOT		;

	JMP	COND_CONV_LOGICAL	;

COND_CONV_EQU:
	MOV	OPERA,TAG_IF_IMM_EQU	; IF immidiate =.
	DEC	SI
	JMP	SHORT COND_CONV_3
COND_CONV_LT:
	MOV	OPERA,TAG_IF_IMM_LT	; IF immidiate <.
	DEC	SI
	JMP	SHORT COND_CONV_3
COND_CONV_GT:
	MOV	OPERA,TAG_IF_IMM_GT	; IF immidiate >.
	DEC	SI
	JMP	SHORT COND_CONV_3
COND_CONV_LE:
	MOV	OPERA,TAG_IF_IMM_LE	; IF immidiate =<.
	JMP	SHORT COND_CONV_3
COND_CONV_GE:
	MOV	OPERA,TAG_IF_IMM_GE	; IF immidiate >=.
	JMP	SHORT COND_CONV_3
COND_CONV_NOT:
	MOV	OPERA,TAG_IF_IMM_NOT	; IF immidiate !.
	DEC	SI
COND_CONV_3:
	SKIP_SPACE			; skip space.
	MOV	PNTSOU,SI		; comp line buffer source.

	CALL	SYMBOLGET		; symbol get.
	CMP	STRSYMLEN,0		; symbol length.
	JMPEQ	COND_CONV_ERROR		;

	MOV	SI,STRSYMBOL		; symbol string.
	MOV	CX,STRSYMLEN		; symbol length.
	CALL	BBNUMBER		; 文字列－＞数字チェック
	MOV	VALSOU,DX		; source value.
	CMP	AX,0			; 0=正常,1=数字列ではない
	JMPEQ	COND_CONV_IMM		;

	CALL	SYMBOLE_SCH		; symbol search.
	CMP	AX,1			; 0=search,1=none.
	JMPEQ	COND_CONV_ERROR		;

	CMP	SYMSEGM,SEG DATA	; segment of symbol.
	JMPNE	COND_CONV_ERROR		;

	MOVX	VALSOU,SYMOFST		; offset of symbol.

	MOV	SI,PNTSOU		; comp line buffer source.
	SKIP_SPACE			; skip space.
	MOV	PNTSOU,SI		; comp line buffer source.

	CALL	DIMENSION_GET		; dimension get.
	MOV	DESTDIMTYPE2,AX		; dest dimension type2.
	MOVX	DESTDIMAD2,SOUSYMOFST	; offset of source symbol2.
	MOVX	DESTDIMIMM2,DIM_OFST	; dimension offset2.

	CMP	DESTDIMTYPE2,3		; 3=error.
	JMPEQ	COND_CONV_ERROR		;

	CMP	DESTDIMTYPE2,1		; 0=none,1=memory,2=immidiate,3=error.
	JNE	COND_CONV_MEM		;
	CMP	DESTDIMTYPE,1		; 0=none,1=memory,2=immidiate,3=error.
	JMPNE	COND_CONV_ERROR		;

COND_CONV_MEM:
	CMP	DESTDIMTYPE,1		; 0=none,1=memory,2=immidiate,3=error.
	JMPEQ	COND_CONV_MEM_DIM	;

	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,OPERA		; operation. =<
	ADD	AL,10H			; tag memory.
	STOSB				;
	MOV	AX,VALDES		; offset of symbol.
	ADD	AX,DESTDIMIMM		; dimension offset.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	AX,VALSOU		; source value.
	ADD	AX,DESTDIMIMM2		; dimension offset2.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	COND_CONV_NORMAL	;

COND_CONV_MEM_DIM:
	CMP	DESTDIMTYPE2,1		; 0=none,1=memory,2=immidiate,3=error.
	JE	COND_CONV_MEM_DIMDIM	;

	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_DIM		; dimension.
	STOSB				;
	MOV	AL,OPERA		; operation. =<
	ADD	AL,10H			; tag memory.
	STOSB				;
	MOV	AX,VALDES		; offset of symbol.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	AX,DESTDIMAD		; offset of source symbol.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	AX,VALSOU		; source value.
	ADD	AX,DESTDIMIMM2		; dimension offset2.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	COND_CONV_NORMAL	;

COND_CONV_MEM_DIMDIM:			;
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_DIM		; dimension.
	STOSB				;
	STOSB				; *2
	MOV	AL,OPERA		; operation. =<
	ADD	AL,10H			; tag memory.
	STOSB				;
	MOV	AX,VALDES		; offset of symbol.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	AX,DESTDIMAD		; offset of source symbol.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	AX,VALSOU		; source value.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	AX,DESTDIMAD2		; offset of source symbol2.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	COND_CONV_NORMAL	;

COND_CONV_IMM:
	CMP	DESTDIMTYPE,1		; 0=none,1=memory,2=immidiate,3=error.
	JE	COND_CONV_IMM_DIM	;

	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,OPERA		; operation. =<
	STOSB				;
	MOV	AX,VALDES		; offset of symbol.
	ADD	AX,DESTDIMIMM		; dimension offset.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	AX,VALSOU		; source value.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	COND_CONV_NORMAL	;
COND_CONV_IMM_DIM:
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_DIM		; dimension.
	STOSB				;
	MOV	AL,OPERA		; operation. =<
	STOSB				;
	MOV	AX,VALDES		; offset of symbol.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	AX,DESTDIMAD		; offset of source symbol.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	AX,VALSOU		; source value.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	COND_CONV_NORMAL	;

COND_CONV_LOGICAL:
	CMP	DESTDIMTYPE,1		; 0=none,1=memory,2=immidiate,3=error.
	JE	COND_CONV_LOGICAL_DIM	;
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_IF_LOGICAL	; IF logical.
	STOSB				;
	MOV	AX,VALDES		; offset of symbol.
	ADD	AX,DESTDIMIMM		; dimension offset.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	COND_CONV_NORMAL	;
COND_CONV_LOGICAL_DIM:
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_DIM		; dimension.
	STOSB				;
	MOV	AL,TAG_IF_LOGICAL	; IF logical.
	STOSB				;
	MOV	AX,VALDES		; offset of symbol.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	AX,DESTDIMAD		; offset of source symbol.
	STOSB				;
	MOV	AL,AH			; memory address.
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.

COND_CONV_NORMAL:
	MOV	AX,0			; 0=normal.
	RET
COND_CONV_ERROR:
	MOV	AX,1			; 1=error.
	RET
COND_CONV	ENDP


; *********************************************************
;	stack call set.
;	-I-   STK_CALL_CMND : stack call command.
;	      STK_CALL_ADRS : stack call address.
;	-I/O- PNTSOU        : comp line buffer source.
;	      PNTBIN        : comp line buffer binary.
;	-O-   AX            : 0=normal,1=error.
; *********************************************************

STK_CALL_SET	PROC	NEAR
	MOVX	ES,DS			;
	MOV	SI,PNTSOU		; comp line buffer source.
	SKIP_SPACE			; skip space.
	MOV	PNTSOU,SI		; comp line buffer source.

	CMP	BYTE PTR DS:[SI],MARKBEGIN ; ( begin mark.
	JMPNE	STK_CALL_SET_CMDSET	;

	INC	PNTSOU			; comp line buffer source.
STK_CALL_SET_LOOP:			;
	MOV	SI,PNTSOU		; comp line buffer source.
	SKIP_SPACE_CMMA			; skip space & comma.
	MOV	PNTSOU,SI		; comp line buffer source.

	MOV	AX,PNTSOU		;
	SUB	AX,COMPLINESOU		; comp line buffer source.
	CMP	AX,COMPLINESIZE		; comp line buffer size.
	JMPNB	STK_CALL_SET_ERROR	;

	MOV	AL,DS:[SI]		;
	CMP	AL,MARKEND		; ) end mark.
	JMPEQ	STK_CALL_SET_CMDSET2	;
	CMP	AL,'"'			;
	JMPEQ	STK_CALL_SET_STR	;
	CMP	AL,"'"			;
	JMPEQ	STK_CALL_SET_STR	;

	CALL	SYMBOLGET		; symbol get.
	CMP	STRSYMLEN,0		; symbol length.
	JMPEQ	STK_CALL_SET_ERROR	;

	MOV	SI,STRSYMBOL		; symbol string.
	MOV	CX,STRSYMLEN		; symbol length.
	CALL	BBNUMBER		; 文字列－＞数字チェック
	CMP	AX,1			; 0=正常,1=数字列ではない
	JE	STK_CALL_SET_MEM	;
	CMP	DX,127			; 数値
	JG	STK_CALL_SET_IMM	;
	CMP	DX,-128			; 数値
	JL	STK_CALL_SET_IMM	;
	JMP	STK_CALL_SET_BYTE	;

STK_CALL_SET_MEM:
	CALL	SYMBOLE_SCH		; symbol search.
	CMP	AX,1			; 0=search,1=none.
	JMPEQ	STK_CALL_SET_ERROR	;

	CMP	SYMSEGM,SEG DATA	; segment of symbol.
	JMPNE	STK_CALL_SET_ERROR	;
	MOV	SI,PNTSOU		; comp line buffer source.
	SKIP_SPACE			; skip space.
	MOV	PNTSOU,SI		; comp line buffer source.

	CALL	DIMENSION_GET		; dimension get.
	CMP	AX,1			; 0=none,1=memory,2=immidiate,3=error.
	JE	STK_CALL_SET_MEM_DIM	;
	CMP	AX,3			; 3=error.
	JE	STK_CALL_SET_ERROR	;

	MOVX	ES,DS			;
	MOV	DX,SYMOFST		; offset of symbol.
	ADD	DX,DIM_OFST		; dimension offset.
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_STMEM		; stack memory.
	STOSB				;
	MOV	AL,DL			; address.
	STOSB				;
	MOV	AL,DH			; address.
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	STK_CALL_SET_LOOP	;
STK_CALL_SET_MEM_DIM:
	MOVX	ES,DS			;
	MOV	DX,SYMOFST		; offset of symbol.
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_DIM		; dimension.
	STOSB				;
	MOV	AL,TAG_STMEM		; stack memory.
	STOSB				;
	MOV	AL,DL			; address.
	STOSB				;
	MOV	AL,DH			; address.
	STOSB				;
	MOV	AX,SOUSYMOFST		; offset of source symbol.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	STK_CALL_SET_LOOP	;

STK_CALL_SET_IMM:
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_STIMM		; stack immidiate.
	STOSB				;
	MOV	AL,DL			; data low.
	STOSB				;
	MOV	AL,DH			; data hi.
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	STK_CALL_SET_LOOP	;

STK_CALL_SET_BYTE:
	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_STBYTE		; stack byte.
	STOSB				;
	MOV	AL,DL			; data.
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	STK_CALL_SET_LOOP	;

STK_CALL_SET_STR:			;
	MOV	CL,AL			; delimiter.

	INC	SI			;

	MOVX	ES,DS			;
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,TAG_EQUSTR		; ="string"
	STOSB				;
	MOV	AX,OFFSET REG_SI	; registar value SI.
	STOSB				;
	MOV	AL,AH			;
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.

	MOV	AL,0			;
	STOSB				; counter area.

	MOV	DX,0			; counter.
STK_CALL_SET_STR5:			;
	CMP	DX,MAX_STRING_LEN	; max string length.
	JNBE	STK_CALL_SET_STR6	;

	PUSH	DX			;
	MOV	DX,DS:[SI]		;
	CALL	BBSJISCHK		; シフトＪＩＳチェック
	POP	DX			;
	CMP	AX,1			; 0=normal,1=shift jis code.
	JE	STK_CALL_SET_STR55	;

	LODSB				;
	CMP	AL,CL			; delimiter.
	JE	STK_CALL_SET_STR6	;
	CMP	AL,CHR_CR		; CR.
	JE	STK_CALL_SET_STR6	;
	CMP	AL,0			; end of string.
	JE	STK_CALL_SET_STR6	;
	STOSB				;
	INC	DX			; counter.
	JMP	STK_CALL_SET_STR5	;
STK_CALL_SET_STR55:			;
	MOVSW				;
	INC	DX			; counter.
	INC	DX			;
	JMP	STK_CALL_SET_STR5	;

STK_CALL_SET_STR6:			;
	MOV	PNTSOU,SI		; comp line buffer source.
	MOV	BX,PNTBIN		; comp line buffer binary.
	MOV	ES:[BX],DL		; counter
	MOV	PNTBIN,DI		; comp line buffer binary.
	JMP	STK_CALL_SET_LOOP	;

STK_CALL_SET_CMDSET2:
	INC	PNTSOU			; comp line buffer source.
STK_CALL_SET_CMDSET:
	MOVX	ES,DS			;
	MOV	DX,STK_CALL_ADRS	; stack call address.
	MOV	DI,PNTBIN		; comp line buffer binary.
	MOV	AL,STK_CALL_CMND	; stack call command.
	STOSB				;
	MOV	AL,DL			; stack call address.
	STOSB				;
	MOV	AL,DH			; stack call address.
	STOSB				;
	MOV	PNTBIN,DI		; comp line buffer binary.

STK_CALL_SET_EXIT:
	MOV	AX,0			; 0=normal.
	RET
STK_CALL_SET_ERROR:
	MOV	AX,1			; 1=error.
	RET
STK_CALL_SET	ENDP


; *********************************************************
;	LOOP jump search.
;	-I- NOWNEST      : now nesting.
;	    NOWTEXTPOINT : now text pointer.
;	-O- JUMPPNT_LOOP : LOOP jump point.
; *********************************************************

LOOP_JUMP_SCH	PROC	NEAR
	PUSH	TEXTPSEG		; text segment pointer.
	PUSH	TEXTPOFS		; text offset pointer.
	PUSH	NESTINGLVL		; nesting level.

	MOVX	NESTINGLVL,NOWNEST	; now nesting.

	MOVX	TEXTPOFS,NOWTEXTPOINT	; now text pointer.
	MOV	DX,NOWNEST		; now nesting.
	CALL	BBCOMPBSKP		; nest back skip.
	MOVX	JUMPPNT_LOOP,TEXTPOFS	; text offset pointer.

	POP	NESTINGLVL		; nesting level.
	POP	TEXTPOFS		; text offset pointer.
	POP	TEXTPSEG		; text segment pointer.
	RET
LOOP_JUMP_SCH	ENDP


; *********************************************************
;	IF jump search.
;	-I- NOWNEST      : now nesting.
;	    NOWTEXTPOINT : now text pointer.
;	-O- JUMPPNT_IF   : IF jump point.
; *********************************************************


IF_JUMP_SCH	PROC	NEAR
	PUSH	TEXTPSEG		; text segment pointer.
	PUSH	TEXTPOFS		; text offset pointer.
	PUSH	NESTINGLVL		; nesting level.

	MOVX	NESTINGLVL,NOWNEST	; now nesting.

	MOVX	TEXTPOFS,NOWTEXTPOINT	; now text pointer.
	MOV	DX,NOWNEST		; now nesting.
	CALL	BBCOMPFSKP		; nest front skip.
	MOVX	JUMPPNT_IF,TEXTPOFS	; text offset pointer.

	POP	NESTINGLVL		; nesting level.
	POP	TEXTPOFS		; text offset pointer.
	POP	TEXTPSEG		; text segment pointer.
	RET
IF_JUMP_SCH	ENDP


; *********************************************************
;	?(question) jump search.
;	-I- NOWTEXTPOINT : now text pointer.
;	-O- JUMPPNT_QUES : ?(question) jump point.
; *********************************************************


QES_JUMP_SCH	PROC	NEAR
	PUSH	TEXTPSEG		; text segment pointer.
	PUSH	TEXTPOFS		; text offset pointer.
	PUSH	NESTINGLVL		; nesting level.

	MOVX	TEXTPOFS,NOWTEXTPOINT	; now text pointer.
	CALL	BBLFSKIP		; 次の行までスキップ
	MOVX	JUMPPNT_QUES,TEXTPOFS	; text offset pointer.

	POP	NESTINGLVL		; nesting level.
	POP	TEXTPOFS		; text offset pointer.
	POP	TEXTPSEG		; text segment pointer.
	RET
QES_JUMP_SCH	ENDP


; *********************************************************
;	symbol get.
;	-I/O- PNTSOU    : comp line buffer source.
;	-O-   STRSYMBOL : symbol string.
;	      STRSYMLEN : symbol length.
; *********************************************************

SYMBOLGET	PROC	NEAR
	MOV	SI,PNTSOU		; comp line buffer source.
	SKIP_SPACE			; skip space.
	MOV	PNTSOU,SI		; comp line buffer source.

	MOVX	ES,DS			;
	MOV	SI,PNTSOU		; comp line buffer source.
	MOV	DI,STRSYMBOL		; symbol string.
	MOV	CX,STRSYMMAX		; symbol max length.
	CALL	BBSTRSYMBGET		; 文字列からシンボル取得
	MOV	STRSYMLEN,BP		; text offset pointer.
	ADD	PNTSOU,BP		; comp line buffer source.

	MOVX	ES,DS			;
	MOV	DI,STRSYMBOL		; symbol string.
	CALL	c_STRCAPS		; 文字列大文字化

	RET
SYMBOLGET	ENDP


; *********************************************************
;	line get.
;	-I/O- TEXTPSEG : text segment pointer.
;	      TEXTPOFS : text offset pointer.
;	-O-   COMPLINESOU : comp line buffer source.
;	      CLINELEN    : line length.
; *********************************************************

LINEGET	PROC	NEAR
	MOV	DI,COMPLINESOU		; comp line buffer source.
	MOV	CX,COMPLINESIZE		; comp line buffer size.
	CALL	c_STRZEROC		; 文字列バッファ０クリア

	MOV	CLINELEN,0		; line length.

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	SI,TEXTPOFS		; text offset pointer.
	MOV	DI,COMPLINESOU		; comp line buffer source.
	MOV	CX,COMPLINESIZE		; comp line buffer size.
LINEGET_LOOP:
	MOV	AL,ES:[SI]		; get 1 char.
	CMP	AL,CHR_CR		; CR
	JE	LINEGET_LOOP_E		;

	INC	CLINELEN		; line length.
	INC	SI			;

	MOV	DS:[DI],AL		; put 1 char.
	INC	DI			;
	LOOP	LINEGET_LOOP
LINEGET_LOOP_E:
	MOV	TEXTPOFS,SI		; text offset pointer.
	RET
LINEGET	ENDP


; *********************************************************
;	nest check.
;	-I- TEXTPSEG        : text segment pointer.
;	    TEXTPSTARTOFS   : text start offset.
;	-O- NEST_TBL_CNT    : nest count.
;	    NEST_TBL_ADRS[] : nest table.
; *********************************************************

BBCOMPNEST	PROC	NEAR
	MOV	NEST_TBL_CNT,0		; nest count.

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPSTARTOFS	; text start offset.

	MOV	NOWPNT,DI		; now point.
	MOV	NXTNST,-1		; next nesting.
BBCOMPNEST_1:				;
	INC	NXTNST			; next nesting.
	MOV	AL,ES:[DI]		;
	INC	DI			;
	CMP	AL,EOS			;
	JE	BBCOMPNEST_SET		;
	CMP	AL,CHR_TAB		; TAB
	JE	BBCOMPNEST_1		;

BBCOMPNEST_TBLSET:
	CMPX	NEST_TBL_CNT,NEST_TBL_CMAX	; nest count.
	JNB	BBCOMPNEST_OVER			;

	MOV	AL,NXTNST			; next nesting.
	MOV	NOWNST,AL			; now nesting.
	MOV	AX,NEST_TBL_CNT			; nest count.
	MOV	BX,AX				;
	ADD	BX,AX				;
	ADD	BX,AX				; *3
	MOVX	DS:NEST_TBL_ADRS[BX],NOWPNT	; now point.
	MOV	AL,NOWNST			; now nesting.
	MOV	BYTE PTR DS:NEST_TBL_ADRS[BX][2],AL ; nesting table.
	INC	NEST_TBL_CNT			; nest count.

BBCOMPNEST_2:				;
	MOV	AL,ES:[DI]		;
	INC	DI			;
	CMP	AL,EOS			;
	JE	BBCOMPNEST_SET		;
	CMP	AL,CHR_LF		; LF search.
	JNE	BBCOMPNEST_2		;

	MOV	NOWPNT,DI		; now point.
	MOV	NXTNST,-1		; next nesting.
BBCOMPNEST_3:				;
	INC	NXTNST			; next nesting.
	MOV	AL,ES:[DI]		;
	INC	DI			;
	CMP	AL,EOS			;
	JE	BBCOMPNEST_SET		;
	CMP	AL,CHR_TAB		; TAB
	JE	BBCOMPNEST_3		;

	MOV	AL,ES:[DI]		;
	CMP	AL,CHR_LF		; LF search.
	JE	BBCOMPNEST_2		;

	MOV	AL,NOWNST		; now nesting.
	CMP	AL,NXTNST		; next nesting.
	JNE	BBCOMPNEST_TBLSET	;

	JMP	BBCOMPNEST_2		;

BBCOMPNEST_SET:
IF DEBUG2 ; nest table.
	CALL	DEBUG_DMP		; debug dump.
ENDIF
	RET
BBCOMPNEST_OVER:
	BBERROR	109			; error message.
	RET
BBCOMPNEST	ENDP

; *********************************************************
;	nest front skip.
;	-I-   DX         : 指定ネストレベル
;	-I/O- TEXTPSEG   : text segment pointer.
;	      TEXTPOFS   : text offset pointer.
;	-O-   AX         : 0=normal,1=end of text.
; *********************************************************

BBCOMPFSKP	PROC	NEAR
	MOV	USR_NESTING,DX		; 指定ネストレベル

	CALL	BBLFSKIP		; 次の行までスキップ
	CMP	AX,1			; 0=normal,1=end of text.
	JE	BBCOMPFSKP_EOT		;
	CMPX	NESTINGLVL,USR_NESTING	; nesting level.
	JBE	BBCOMPFSKP_NORMAL	;

	MOV	BX,0			;
	MOV	CX,NEST_TBL_CNT		; nest count.
BBCOMPFSKP_LOOP1:			;
	MOV	AX,DS:NEST_TBL_ADRS[BX]	; nest table.
	CMP	AX,TEXTPOFS		; text offset pointer.
	JNBE	BBCOMPFSKP_LOOP_E1	;
	ADD	BX,3			; +3
	LOOP	BBCOMPFSKP_LOOP1	;
	JE	BBCOMPFSKP_EOT		;
BBCOMPFSKP_LOOP_E1:			;

BBCOMPFSKP_LOOP2:			;
	MOV	AL,BYTE PTR DS:NEST_TBL_ADRS[BX][2] ; nest table.
	CMP	AL,BYTE PTR USR_NESTING	; 指定ネストレベル
	JBE	BBCOMPFSKP_LOOP_E2	;
	ADD	BX,3			; +3
	LOOP	BBCOMPFSKP_LOOP2	;
	JE	BBCOMPFSKP_EOT		;
BBCOMPFSKP_LOOP_E2:			;

	MOVX	TEXTPOFS,DS:NEST_TBL_ADRS[BX]	; nest table.
	MOV	AL,BYTE PTR DS:NEST_TBL_ADRS[BX][2]; nest table.
	MOV	AH,0			;
	MOV	NESTINGLVL,AX		; nesting level.

BBCOMPFSKP_NORMAL:
	MOV	AX,0			; 0=normal.
	RET
BBCOMPFSKP_EOT:
	MOV	AX,1			; 1=end of text.
	RET
BBCOMPFSKP	ENDP


; *********************************************************
;	nest back skip.
;	-I-   DX         : 指定ネストレベル
;	-I/O- TEXTPSEG   : text segment pointer.
;	      TEXTPOFS   : text offset pointer.
; *********************************************************

BBCOMPBSKP	PROC	NEAR
	MOV	USR_NESTING,DX		; 指定ネストレベル

	MOV	BX,2			;=2
	MOV	CX,NEST_TBL_CNT		; nest count.
BBCOMPBSKP_LOOP1:			;
	MOV	AX,DS:NEST_TBL_ADRS[BX][1]	; nest table.
	CMP	AX,TEXTPOFS		; text offset pointer.
	JE	BBCOMPBSKP_LOOP_E11	;
	JNB	BBCOMPBSKP_LOOP_E1	;
	ADD	BX,3			; +3
	LOOP	BBCOMPBSKP_LOOP1	;
BBCOMPBSKP_LOOP_E1:			;
	SUB	BX,3			; -3
BBCOMPBSKP_LOOP_E11:			;

BBCOMPBSKP_LOOP2:			;
	MOV	AL,BYTE PTR DS:NEST_TBL_ADRS[BX] ; nest table.
	CMP	AL,BYTE PTR USR_NESTING	; 指定ネストレベル
	JBE	BBCOMPBSKP_LOOP_E2	;
	SUB	BX,3			; +3
	JNB	BBCOMPBSKP_LOOP2	;
BBCOMPBSKP_LOOP_E2:			;
	MOVX	TEXTPOFS,DS:NEST_TBL_ADRS[BX][1]	; nest table.
	MOV	AL,BYTE PTR DS:NEST_TBL_ADRS[BX]	; nest table.
	MOV	AH,0			;
	MOV	NESTINGLVL,AX		; nesting level.

BBCOMPBSKP_EXIT:			;
	RET
BBCOMPBSKP	ENDP


IF DEBUG2 ; nest table.
; *********************************************************
;	debug dump.
; *********************************************************

DEBUG_DMP	PROC	NEAR
	PRV	"NEST_TBL_CNT=",NEST_TBL_CNT	; nest count.

	MOV	CX,NEST_TBL_CNT			; nest count.
	MOV	BX,0				;
DEBUG_DMP_LOOP:
	MOV	DX,DS:NEST_TBL_ADRS[BX]		; nest table.
	CALL	c_DECSTR
	CALL	c_PRINT
	MOV	AL,':'
	CALL	c_CHPUT
	XOR	DH,DH				; DH=0
	MOV	DL,BYTE PTR DS:NEST_TBL_ADRS[BX][2]	; nest table.
	CALL	c_DECSTR
	INC	SI
	INC	SI
	INC	SI
	CALL	c_PRINT
	LF
	ADD	BX,3
	LOOP	DEBUG_DMP_LOOP
	RET
DEBUG_DMP	ENDP
ENDIF

CODE	ENDS


CODE01	SEGMENT	PUBLIC	'CODE01'
	ASSUME	CS:CODE01,DS:DATA
;	CODE01 far jump.
BBFUNCTION_CODE01_JP	PROC	FAR
	CALL	WORD PTR JUMP_OFFSET	; jump address.
	RET
BBFUNCTION_CODE01_JP	ENDP
CODE01	ENDS

; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	DBGFLAG_CONSOLE:WORD	; debug flag console.
EXTRN	KEYBORD_FLAGALLSKIP:WORD ; all skip flag.

LINCOUNT	DW	0		; line counter.

PNTSOU		DW	0		; comp line buffer source.
PNTBIN		DW	0		; comp line buffer binary.
NOWTEXTPOINT	DW	0		; now text pointer.
NOWNEST		DW	0		; now nesting.

JUMPPNT_LOOP	DW	0		; LOOP jump point.
JUMPPNT_IF	DW	0		; IF jump point.
JUMPPNT_QUES	DW	0		; ?(question) jump point.

STK_CALL_CMND	DB	0,0		; stack call command.
STK_CALL_ADRS	DW	0		; stack call address.

OPERA		DB	0,0		; operation.
VALDES		DW	0		; destination value.
VALSOU		DW	0		; source value.
DESTADRS	DW	0		; destination adrs.
DESTDIMAD	DW	0		; dest dimension adrs.
DESTDIMTYPE	DW	0		; dest dimension type.
DESTDIMIMM	DW	0		; dest dimension immidiate.
DESTDIMTYPE2	DW	0		; dest dimension type2.
DESTDIMAD2	DW	0		; offset of source symbol2.
DESTDIMIMM2	DW	0		; dimension offset2.

COPRA		DB	0,0		; calc operation.

CLINELEN	DW	0		; line length.
CBINALEN	DW	0		; binary line length.

IFIIFO		DW	0		; if in/out.
STACKLEVEL	DW	0		; stack level.
VALUE		DW	0		; value.

COND		DB	0,0		; condition.

PR_IO		DB	0,0		; print i/o.

JUMP_ADDRESS	LABEL	DWORD		; jump address.
JUMP_OFFSET	DW	0		; jump offset.
JUMP_SEGMENT	DW	SEG CODE01	; jump segment.

;*;NEST_TBL_CNT	DW	0		; nest count.
;*;NEST_TBL_CMAX DW	1200/3		; nest count max.
;*;NEST_TBL_ADRS DW	1200 DUP (0)	; nest table.

JMPADRS		DW	0		; jump address.

NOWPNT		DW	0		; now point.
NOWNST		DB	0,0		; now nesting.
NXTNST		DB	0,0		; next nesting.
USR_NESTING	DW	0		; 指定ネストレベル

TBL_TAG_IMM	LABEL	BYTE			; immidiate tag table.
		DB	TAG_IMMEQU		; immidiate =
		DB	TAG_IMMADD		; immidiate +
		DB	TAG_IMMSUB		; immidiate -
		DB	TAG_IMMMUL		; immidiate *
		DB	TAG_IMMDIV		; immidiate /
TBL_TAG_MEM	LABEL	BYTE			; memory tag table.
		DB	TAG_MEMEQU		; memory =
		DB	TAG_MEMADD		; memory +
		DB	TAG_MEMSUB		; memory -
		DB	TAG_MEMMUL		; memory *
		DB	TAG_MEMDIV		; memory /

CMD_IF		DB	"IF",0		; command "IF"
CMD_GOTO	DB	"GOTO",0	; command "GOTO"
CMD_RET		DB	"RET",0		; command "RET"
CMD_LOOP	DB	"LOOP",0	; command "LOOP"

		EVEN
FLAG_PREPROS	DB	0,0		; preprosion flag.

IF_INSTRACTION_MAX	DW	27	; instraction max.
IF_INSTRACTION_TBL	LABEL	BYTE
	DB	TAG_MEM			; 1  memory.
	DB	TAG_MEMINC		; 2  memory ++
	DB	TAG_MEMDEC		; 3  memory --
	DB	TAG_IMMADD		; 4  immidiate +
	DB	TAG_IMMSUB		; 5  immidiate -
	DB	TAG_IMMMUL		; 6  immidiate *
	DB	TAG_IMMDIV		; 7  immidiate /
	DB	TAG_IMMEQU		; 8  immidiate =
	DB	TAG_MEMEQU		; 9  memory =
	DB	TAG_MEMADD		; 10 memory +
	DB	TAG_MEMSUB		; 11 memory -
	DB	TAG_MEMMUL		; 12 memory *
	DB	TAG_MEMDIV		; 13 memory /
	DB	TAG_EXTEND		; 14 extend.
	DB	TAG_DIM			; 15 dimension.
	DB	TAG_ASMCALL		; 16 asm call(CODE)
	DB	TAG_ASMCL01		; 17 asm call(CODE01)
	DB	TAG_TEXTCALL		; 18 text call.
	DB	TAG_TEXTJUMP		; 19 text jump.
	DB	TAG_RET			; 20 ret
	DB	TAG_IFIO		; 21 if i/o.
	DB	TAG_EQUSTR		; 22 ="string"
	DB	TAG_STIMM		; 23 stack immidiate.
	DB	TAG_STMEM		; 24 stack memory.
	DB	TAG_STBYTE		; 25 stack byte.
	DB	TAG_DIRECTCOM		; 26 direct command "@"
	DB	TAG_PRINT		; 27 print string."""
			EVEN
IF_INSTRACTION_JMP	LABEL	WORD
	DW	BBCLRUN_TAG_MEM		; 1  memory.
	DW	BBCLRUN_TAG_MEMINC	; 2  memory ++
	DW	BBCLRUN_TAG_MEMDEC	; 3  memory --
	DW	BBCLRUN_TAG_IMMADD	; 4  immidiate +
	DW	BBCLRUN_TAG_IMMSUB	; 5  immidiate -
	DW	BBCLRUN_TAG_IMMMUL	; 6  immidiate *
	DW	BBCLRUN_TAG_IMMDIV	; 7  immidiate /
	DW	BBCLRUN_TAG_IMMEQU	; 8  immidiate =
	DW	BBCLRUN_TAG_MEMEQU	; 9  memory =
	DW	BBCLRUN_TAG_MEMADD	; 10 memory +
	DW	BBCLRUN_TAG_MEMSUB	; 11 memory -
	DW	BBCLRUN_TAG_MEMMUL	; 12 memory *
	DW	BBCLRUN_TAG_MEMDIV	; 13 memory /
	DW	BBCLRUN_TAG_EXTEND	; 14 extend.
	DW	BBCLRUN_TAG_DIM		; 15 dimension.
	DW	BBCLRUN_TAG_ASMCALL	; 16 asm call(CODE)
	DW	BBCLRUN_TAG_ASMCL01	; 17 asm call(CODE01)
	DW	BBCLRUN_TAG_TEXTCALL	; 18 text call.
	DW	BBCLRUN_TAG_TEXTJUMP	; 19 text jump.
	DW	BBCLRUN_TAG_RET		; 20 ret
	DW	BBCLRUN_TAG_IF		; 21 if i/o.
	DW	BBCLRUN_TAG_EQUSTR	; 22 ="string"
	DW	BBCLRUN_TAG_STIMM	; 23 stack immidiate.
	DW	BBCLRUN_TAG_STMEM	; 24 stack memory.
	DW	BBCLRUN_TAG_STBYTE	; 25 stack byte.
	DW	BBCLRUN_TAG_DIRECT	; 26 direct command.
	DW	BBCLRUN_TAG_PRINT	; 27 print string."""

IF_CONDITION_MAX	DW	16	; condition max.
IF_CONDITION_TBL	LABEL	BYTE
	DB	TAG_IF_IMM_EQU		; 1  IF immidiate =.
	DB	TAG_IF_IMM_LT		; 2  IF immidiate <.
	DB	TAG_IF_IMM_GT		; 3  IF immidiate >.
	DB	TAG_IF_IMM_LE		; 4  IF immidiate =<.
	DB	TAG_IF_IMM_GE		; 5  IF immidiate >=.
	DB	TAG_IF_IMM_NOT		; 6  IF immidiate !.
	DB	TAG_IF_MEM_EQU		; 7  IF memory =.
	DB	TAG_IF_MEM_LT		; 8  IF memory <.
	DB	TAG_IF_MEM_GT		; 9  IF memory >.
	DB	TAG_IF_MEM_LE		; 10 IF memory =<.
	DB	TAG_IF_MEM_GE		; 11 IF memory >=.
	DB	TAG_IF_MEM_NOT		; 12 IF memory !.
	DB	TAG_IF_LOGICAL		; 13 IF logical.
	DB	TAG_IF_OR		; 14 IF or.
	DB	TAG_IFIO		; 15 if i/o.
	DB	TAG_DIM			; 16 dimension.
			EVEN
IF_CONDITION_JMP	LABEL	WORD
	DW	IF_COND_IMM_EQU		; 1  IF immidiate =.
	DW	IF_COND_IMM_LT		; 2  IF immidiate <.
	DW	IF_COND_IMM_GT		; 3  IF immidiate >.
	DW	IF_COND_IMM_LE		; 4  IF immidiate =<.
	DW	IF_COND_IMM_GE		; 5  IF immidiate >=.
	DW	IF_COND_IMM_NOT		; 6  IF immidiate !.
	DW	IF_COND_MEM_EQU		; 7  IF memory =.
	DW	IF_COND_MEM_LT		; 8  IF memory <.
	DW	IF_COND_MEM_GT		; 9  IF memory >.
	DW	IF_COND_MEM_LE		; 10 IF memory =<.
	DW	IF_COND_MEM_GE		; 11 IF memory >=.
	DW	IF_COND_MEM_NOT		; 12 IF memory !.
	DW	IF_COND_LOGICAL		; 13 IF logical.
	DW	IF_COND_IF_OR		; 14 IF or.
	DW	IF_COND_IFIO		; 15 if i/o.
	DW	IF_COND_DIM		; 16 dimension.

IF_CONDITION_JMP_DIM	LABEL	WORD
	DW	IF_COND_D_IMM_EQU	; 1  IF immidiate =.
	DW	IF_COND_D_IMM_LT	; 2  IF immidiate <.
	DW	IF_COND_D_IMM_GT	; 3  IF immidiate >.
	DW	IF_COND_D_IMM_LE	; 4  IF immidiate =<.
	DW	IF_COND_D_IMM_GE	; 5  IF immidiate >=.
	DW	IF_COND_D_IMM_NOT	; 6  IF immidiate !.
	DW	IF_COND_D_MEM_EQU	; 7  IF memory =.
	DW	IF_COND_D_MEM_LT	; 8  IF memory <.
	DW	IF_COND_D_MEM_GT	; 9  IF memory >.
	DW	IF_COND_D_MEM_LE	; 10 IF memory =<.
	DW	IF_COND_D_MEM_GE	; 11 IF memory >=.
	DW	IF_COND_D_MEM_NOT	; 12 IF memory !.
	DW	IF_COND_D_LOGICAL	; 13 IF logical.
	DW	IF_COND_IF_OR		; 14 IF or.
	DW	IF_COND_IFIO		; 15 if i/o.
	DW	IF_COND_DIM		; 16 dimension.

IF_CONDITION_JMP_DIM2	LABEL	WORD
	DW	IF_COND_D_IMM_EQU	; 1  IF immidiate =.
	DW	IF_COND_D_IMM_LT	; 2  IF immidiate <.
	DW	IF_COND_D_IMM_GT	; 3  IF immidiate >.
	DW	IF_COND_D_IMM_LE	; 4  IF immidiate =<.
	DW	IF_COND_D_IMM_GE	; 5  IF immidiate >=.
	DW	IF_COND_D_IMM_NOT	; 6  IF immidiate !.
	DW	IF_COND_D2_MEM_EQU	; 7  IF memory =.
	DW	IF_COND_D2_MEM_LT	; 8  IF memory <.
	DW	IF_COND_D2_MEM_GT	; 9  IF memory >.
	DW	IF_COND_D2_MEM_LE	; 10 IF memory =<.
	DW	IF_COND_D2_MEM_GE	; 11 IF memory >=.
	DW	IF_COND_D2_MEM_NOT	; 12 IF memory !.
	DW	IF_COND_D_LOGICAL	; 13 IF logical.
	DW	IF_COND_IF_OR		; 14 IF or.
	DW	IF_COND_IFIO		; 15 if i/o.
	DW	IF_COND_DIM		; 16 dimension.

DATA	ENDS

	END
;
;	end of "BBCOMPIL.ASM"
;
