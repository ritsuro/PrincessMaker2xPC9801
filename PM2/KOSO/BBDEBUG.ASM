; "BBDEBUG.ASM" PC-9801UV11 make by R.H 1991/10/24
;
;
;	princess  B A S I C    d e b u g .
;
;
;	DBGFLAG_FILE=1		; テキストファイルのロード状況
;	DBGFLAG_FILE=2		; 全ファイルのロード状況
;
; basic shell.

INCLUDE	TSTSETC.INC
INCLUDE	BBEXTRN.INC
INCLUDE	MACHINEX.INC
INCLUDE	MESSAGE.INC

TEXT_VRAM_SEG	EQU	0A000H	; text vram address.
ATTR_VRAM_SEG	EQU	0A200H	; attribute vram address.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	BBDEBUG_WINDOW_CLEARC01	; デバッグ WINDOW クリア
				; "VPCMOUSE.ASM"

PUBLIC	C1BBDEBUGFILE		; filename dump.

CODE01	ENDS

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:DATA

PUBLIC	BBERRORPR		; error message.
PUBLIC	FAR_BBERRORPR		; (far)error message.
PUBLIC	BBDEBUGTXFILE		; text filename dump.
PUBLIC	BBDEBUGHEX		; hex line dump.
PUBLIC	BBDEBUGCHR		; char line dump.
PUBLIC	BBDEBUGMISSCOMPILE	; miss compile.
PUBLIC	BBDEBUGTEXTPOINTER	; text pointer.

; *********************************************************
;	error message.
;	-I- FLAGERROR : error flag.
; *********************************************************

BBERRORPR	PROC	NEAR
	PUSH	ES
	PUSH	BP
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	CALL	BBERRORPR_PR
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POP	BP
	POP	ES
	RET
BBERRORPR	ENDP

BBERRORPR_PR	PROC	NEAR
	CMP	DBGFLAG_ERROR,0		; debug flag error.
	JNE	BBERROR_START		;
	RET
BBERROR_START:
	LC	22,22
	CALL	PRHEAD			; header print.

	MOV	AX,FLAGERROR		; error flag.

	CMP	AL,101
	JMPEQ	BBERROR_101
	CMP	AL,102
	JMPEQ	BBERROR_102
	CMP	AL,103
	JMPEQ	BBERROR_103
	CMP	AL,104
	JMPEQ	BBERROR_104
	CMP	AL,105
	JMPEQ	BBERROR_105
	CMP	AL,106
	JMPEQ	BBERROR_106
	CMP	AL,107
	JMPEQ	BBERROR_107
	CMP	AL,108
	JMPEQ	BBERROR_108
	CMP	AL,109
	JMPEQ	BBERROR_109
	CMP	AL,110
	JMPEQ	BBERROR_110
	CMP	AL,111
	JMPEQ	BBERROR_111
	CMP	AL,112
	JMPEQ	BBERROR_112
	CMP	AL,113
	JMPEQ	BBERROR_113
	CMP	AL,114
	JMPEQ	BBERROR_114
	CMP	AL,115
	JMPEQ	BBERROR_115
	CMP	AL,116
	JMPEQ	BBERROR_116
	CMP	AL,117
	JMPEQ	BBERROR_117
	CMP	AL,118
	JMPEQ	BBERROR_118
	CMP	AL,119
	JMPEQ	BBERROR_119
	CMP	AL,120
	JMPEQ	BBERROR_120
	CMP	AL,121
	JMPEQ	BBERROR_121
	CMP	AL,122
	JMPEQ	BBERROR_122
	CMP	AL,123
	JMPEQ	BBERROR_123
	CMP	AL,124
	JMPEQ	BBERROR_124
	CMP	AL,125
	JMPEQ	BBERROR_125
	CMP	AL,126
	JMPEQ	BBERROR_126
	CMP	AL,127
	JMPEQ	BBERROR_127

	JMP	BBERROR_ANOTHER

BBERROR_101:
	PRSA	"file not found :",LAST_FILENAME ; last access file name.
	JMP	BBERROR_ENDSPACE
BBERROR_102:
	PRSA	"symbol undefined :",STRSYMBOL
;*;EXTRN BBTYPE:NEAR		; text type.
;*;CALL BBTYPE			; text type.
	JMP	BBERROR_ENDSPACE
BBERROR_103:
	PRSA	"value undefined :",STRSYMBOL
	JMP	BBERROR_ENDSPACE
BBERROR_104:
	PRF	"select table over :"
	RET
BBERROR_105:
	PRF	"(BBTBL.ASM/JMPADTBLDIM) data table over."
	RET
BBERROR_106:
	PRF	"write error."
	RET
BBERROR_107:
	PRSA	"inline compile error :",COMPLINESOU
	JMP	BBERROR_ENDSPACE
BBERROR_108:
	PRSA	"inline compile IF condition err :",COMPLINESOU
	JMP	BBERROR_ENDSPACE
BBERROR_109:
	PRF	"nesting table over.(BBTBL.ASM/NEST_TBL_ADRS)"
	RET
BBERROR_110:
	PRF	"dimension error."
	RET
BBERROR_111:
	PRF	"LOOP parameter error."
	RET
BBERROR_112:
	PRSA	"'.'define error.:",DEFSYMBOL
	JMP	BBERROR_ENDSPACE
BBERROR_113:
	PRSA "'.'define (BBSYMBL.ASM/USER_AREA_WSIZE)size over.",DEFSYMBOL
	JMP	BBERROR_ENDSPACE
BBERROR_114:
	PRSA "'.'define (BBSYMBL.ASM/TCHRSEG_FREE_SIZE)table over.",DEFSYMBOL
	JMP	BBERROR_ENDSPACE
BBERROR_115:
	PRSA "'.'define (BBSYMBL.ASM/TCHRADR_REC_MAX)table over.",DEFSYMBOL
	JMP	BBERROR_ENDSPACE
BBERROR_116:
	PRSA "compile symbol undefined.",STRSYMBOL
	JMP	BBERROR_ENDSPACE
BBERROR_117:
	PRF	"text stack over."
	RET
BBERROR_118:
	PRSA "'.'define string set(BBSYMBL.ASM/USER_AREA_WSIZE)ov.",DEFSYMBOL
	JMP	BBERROR_ENDSPACE
BBERROR_119:
	PRF "user file not found."
	CALL	c_PRINT
	LF
	RET
BBERROR_120:
	PRSA	"parts file undef.",SI
	JMP	BBERROR_ENDSPACE
BBERROR_121:
	PRV	"bank change error.",DX
	RET
BBERROR_122:
	PRF	"bank full."
	RET
BBERROR_123:
	PRSA	"music data none.",SI
	JMP	BBERROR_ENDSPACE
BBERROR_124:
	PRF	"don't compile. (line length empty!)  ex. 'C1=1' -> 'C1 = 1'"
	RET
BBERROR_125:
	PRSA	"undefined label.",SI
	JMP	BBERROR_ENDSPACE
BBERROR_126:
	PRF	'string buffer full.( run command "STRSCLEAR" )'
	RET
BBERROR_127:
	PRSA	"table 'ITEM_PROG' error :",SI
	JMP	BBERROR_ENDSPACE
BBERROR_ENDSPACE:
	PR	"  "
	RET
BBERROR_ANOTHER:
	PRV	"system error code :",FLAGERROR
BBERROR_EXIT:
	RET
BBERRORPR_PR	ENDP


; *********************************************************
;	(far)error message.
; *********************************************************

FAR_BBERRORPR	PROC	FAR
	CALL	BBERRORPR		; error message.
	RET
FAR_BBERRORPR	ENDP


; *********************************************************
;	header print.
; *********************************************************

PRHEAD	PROC	NEAR
	PUSH	SI
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JNE	PRHEAD_4		;
	CALLE	c_DWN50P		; 明度５０％ダウン（瞬間）
	MOV	DBGFLAG_CONSOLE,1	; console output.
	MESSAGE	10	;"エラーが発生しました: "
	CALL	c_PRINT
	LF
PRHEAD_4:
	POP	SI
	RET
PRHEAD	ENDP


; *********************************************************
;	filename dump.
;	-I- SI : file name.
; *********************************************************

FAR_BBDEBUGFILE	PROC	FAR
	CMP	DBGFLAG_FILE,2		; 全ファイルのロード状況
	JE	BBDEBUGFILE_START	;
	RET
BBDEBUGFILE_START:
;*;	LC	50,24
	PUSH	SI
	PR	" load : "
	CALL	c_PRINT
	PR	" "
;*;	LF
	POP	SI
	RET
FAR_BBDEBUGFILE	ENDP


; *********************************************************
;	text filename dump.
;	-I- SI : file name.
; *********************************************************

BBDEBUGTXFILE	PROC	NEAR
	CMP	DBGFLAG_FILE,1		; テキストファイルのロード状況
	JE	BBDEBUGTXFILE_START	;
	RET
BBDEBUGTXFILE_START:
;*;	LC	50,24
	PUSH	SI
	PR	" load : "
	CALL	c_PRINT
	PR	" "
;*;	LF
	POP	SI
	RET
BBDEBUGTXFILE	ENDP


; *********************************************************
;	hex line dump.
;	-I- ES:[DI] : address.
;	    CX      : length.
; *********************************************************

BBDEBUGHEX	PROC	NEAR
	PUSH	DI
	PUSH	CX
	JCXZ	BBDEBUGHEX_EXIT
BBDEBUGHEX_LOOP:
	MOV	AL,ES:[DI]		; 1 char get.
	INC	DI			; ++
	MOV	AH,AL			;
	CALL	c_PRNAH			; print ah reg.
	MOV	AL," "			;
	CALL	c_CHPUT			; print of ascii character.
	LOOP	BBDEBUGHEX_LOOP
BBDEBUGHEX_EXIT:
	LF
	POP	CX
	POP	DI
	RET
BBDEBUGHEX	ENDP


; *********************************************************
;	char line dump.
;	-I- ES:[DI] : address.
;	    CX      : length.
; *********************************************************

BBDEBUGCHR	PROC	NEAR
	PUSH	DI
	PUSH	CX
	JCXZ	BBDEBUGCHR_EXIT
BBDEBUGCHR_LOOP:
	MOV	AL,ES:[DI]		; 1 char get.
	INC	DI			; ++
	CMP	AL,' '			;
	JNB	BBDEBUGCHR_5		;
	MOV	AL,'.'
BBDEBUGCHR_5:
	CALL	c_CHPUT			; print of ascii character.
	MOV	AL," "			;
	CALL	c_CHPUT			; print of ascii character.
	CALL	c_CHPUT			; print of ascii character.
	LOOP	BBDEBUGCHR_LOOP
BBDEBUGCHR_EXIT:
	LF
	POP	CX
	POP	DI
	RET
BBDEBUGCHR	ENDP


; *********************************************************
;	miss compile.
; *********************************************************

BBDEBUGMISSCOMPILE	PROC	NEAR
	PRSA	"inline compile error :",COMPLINESOU
	PR	"miss compile count:"
	INC	MISSCOMPILE		; miss compile color.
	MOV	DX,MISSCOMPILE		;
	CALL	c_DECSTR		; val DX to dec string.
	CALL	c_STRZTS		; zero to space. "00123" - > "  123"
	CALL	c_PRINT			;
	LF
	RET
BBDEBUGMISSCOMPILE	ENDP


; *********************************************************
;	text pointer.
;	-I- DI : text pointer.
; *********************************************************

BBDEBUGTEXTPOINTER	PROC	NEAR
;	PUSH	ES
;	PUSH	DI
;	PUSH	SI
;	PUSH	DX
;
;	MOV	DX,DI			;
;	CALL	c_DECSTR		; val DX to dec string.
;	CALL	c_PRINT			;
;	LF
;
;	MOVX	ES,DS			;
;	MOV	DI,OFFSET TEXT_STR+1	;
;	MOVSW
;	MOVSW
;	MOVSB
;	MOV	SI,OFFSET TEXT_STR	;
;	MOV	MARK_OFST,32		;
;	CALL	BBDEBUGMARK		; debug mark.
;	MOV	MARK_OFST,0		;
;
;	POP	DX
;	POP	SI
;	POP	DI
;	POP	ES
	RET
BBDEBUGTEXTPOINTER	ENDP


;; *********************************************************
;;	debug mark.
;;	-I- SI : attr + string.
;; *********************************************************
;
;BBDEBUGMARK	PROC	NEAR
;	CMP	DBGFLAG_MARK_OFF,0	; debug flag mark off.
;	JNE	BBDEBUGMARK_EXIT	;
;
;	LODSB				;
;	MOV	BL,AL			; BL=attribute.
;
;	MOV	DI,80*24*2		;
;	ADD	DI,MARK_OFST		;
;	MOV	AH,0			;
;BBDEBUGMARK_LOOP:			;
;	LODSB				;
;	CMP	AL,0			;
;	JE	BBDEBUGMARK_EXIT	;
;
;	MOV	DX,TEXT_VRAM_SEG	; text vram address.
;	MOV	ES,DX			;
;	STOSB				;
;	DEC	DI			;
;	MOV	DX,ATTR_VRAM_SEG	; attribute vram address.
;	MOV	ES,DX			;
;	MOV	AL,BL			; BL=attribute.
;	STOSW				;
;
;	JMP	BBDEBUGMARK_LOOP	;
;BBDEBUGMARK_EXIT:
;	RET
;BBDEBUGMARK	ENDP

CODE	ENDS

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

; *********************************************************
;	デバッグ WINDOW クリア
; *********************************************************

BBDEBUG_WINDOW_CLEARC01	PROC	NEAR
	TEST	BYTE PTR DS:KYTBLS[12],1000B ; [F2] key on?
	JNZ	BBDEBUG_WINDOW_CLEAR
	RET
BBDEBUG_WINDOW_CLEAR:
	CALLE	BOXVRAM400TO480	; ＢＯＸVRAM400から479ﾗｲﾝｸﾘｱ
	RET
BBDEBUG_WINDOW_CLEARC01	ENDP


; *********************************************************
;	filename dump.
;	-I- SI : file name.
; *********************************************************

C1BBDEBUGFILE	PROC	NEAR
	CALL	FAR PTR FAR_BBDEBUGFILE		; filename dump.
	RET
C1BBDEBUGFILE	ENDP

CODE01	ENDS


; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	DBGFLAG_CONSOLE:WORD			; debug flag console.

PUBLIC	DBGFLAG_ERROR				; debug flag error.
PUBLIC	DBGFLAG_FILE				; debug flag file.
;PUBLIC	DBGFLAG_MARK_OFF			; debug flag mark off.

EXTRN	LAST_FILENAME:WORD			; last access file name.

EXTRN	KYTBLS:BYTE				; key code table top.

MISSCOMPILE		DW	0		; miss compile color.

DBGFLAG_ERROR		DW	1		; debug flag error.
DBGFLAG_FILE		DW	0		; debug flag file.
;DBGFLAG_MARK_OFF	DW	1		; debug flag mark off.

MARK_OFST		DW	0		;

;;TEXT_STR		DB	0A5H,"xxxxx",0

DATA	ENDS

	END
;
;	end of "BBDEBUG.ASM"
;
