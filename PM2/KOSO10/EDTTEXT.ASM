; "EDTTEXT.ASM" 486/50 make by R.H 1993/02/16
;
;
;	テキスト編集
;
;
; public subroutine.

INCLUDE	TSTSET.INC

CHR_CR		EQU	0DH		; CR
CHR_LF		EQU	0AH		; LF
CHR_TAB		EQU	09H		; TAB

STRBUFLENGTH	EQU	80		; string buffer length.

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	EDT_CENTER	; ﾃｷｽﾄ編集ｾﾝﾀﾘﾝｸﾞ
PUBLIC	EDT_RIGHTCUT	; ﾃｷｽﾄ編集右端ｶｯﾄ

; ****************************************************
;	ﾃｷｽﾄ編集ｾﾝﾀﾘﾝｸﾞ
;	-I- AX : １行の長さ
; ****************************************************

EDT_CENTER	PROC	NEAR
	CMP	AX,STRBUFLENGTH		; string buffer length.
	JLE	EDT_CENTER_2		;
	MOV	AX,STRBUFLENGTH		;
EDT_CENTER_2:				;
	CMP	AX,2			;
	JGE	EDT_CENTER_3		;
	MOV	AX,2			;
EDT_CENTER_3:				;
	MOV	LINEWIDTH,AX		; get length.

	MOV	AX,EDTEXTSEG		; edit text buffer segment.
	MOV	BX,EDTEXTOFS		; edit text buffer offset.
	MOV	SOUSEG,AX		; source segment.
	MOV	SOUPNT,BX		; source pointer.
	MOV	SOUSRTPNT,BX		; source start pointer.

	MOV	AX,EDWORKSEG		; edit work buffer segment.
	MOV	BX,EDWORKOFS		; edit work buffer offset.
	MOV	DESSEG,AX		; dest segment.
	MOV	DESPNT,BX		; dest pointer.
	MOV	DESSRTPNT,BX		; dest start pointer.

EDT_CENTER_LOOP:
	MOVX	GETLENGTH,LINEWIDTH	; get length.
	CALL	GET_1LINE		; get 1line.
	CALL	GET_KINSOKU		; 禁則チェック

	CMP	STRLENG,0		; string length.
	JE	EDT_CENTER_CTRL		;

	MOV	CX,LINEWIDTH		; line width.
	SUB	CX,STRLENG		; string length.
	JB	EDT_CENTER_PUT1LINE	;
	SHR	CX,1			; / 2
	CMP	CX,0			;
	JLE	EDT_CENTER_PUT1LINE	;

	CALL	PUT_FF			; blank put.

EDT_CENTER_PUT1LINE:
	CALL	PUT_1LINE		; put 1line.

EDT_CENTER_CTRL:
	CALL	GET_CTRL_CODE		; get ctrl code.
	CMP	AX,1			; 1=end of file.
	JE	EDT_CENTER_LOOP_E	;

	CALL	PUT_LF			; line feed.
EDT_CENTER_NEXT:
	JMP	EDT_CENTER_LOOP

EDT_CENTER_LOOP_E:
	CALL	PUT_EOF			; end of file.

	CALL	COPY_WORK2TEXT		; copy work to text buffer.

EDT_CENTER_EXIT:
	RET
EDT_CENTER	ENDP


; ****************************************************
;	ﾃｷｽﾄ編集右端ｶｯﾄ
;	-I- AX : １行の長さ
; ****************************************************

EDT_RIGHTCUT	PROC	NEAR
	CMP	AX,STRBUFLENGTH		; string buffer length.
	JLE	EDT_RIGHTCUT_2		;
	MOV	AX,STRBUFLENGTH		;
EDT_RIGHTCUT_2:				;
	CMP	AX,2			;
	JGE	EDT_RIGHTCUT_3		;
	MOV	AX,2			;
EDT_RIGHTCUT_3:				;
	MOV	GETLENGTH,AX		; get length.

	MOV	AX,EDTEXTSEG		; edit text buffer segment.
	MOV	BX,EDTEXTOFS		; edit text buffer offset.
	MOV	SOUSEG,AX		; source segment.
	MOV	SOUPNT,BX		; source pointer.
	MOV	SOUSRTPNT,BX		; source start pointer.

	MOV	AX,EDWORKSEG		; edit work buffer segment.
	MOV	BX,EDWORKOFS		; edit work buffer offset.
	MOV	DESSEG,AX		; dest segment.
	MOV	DESPNT,BX		; dest pointer.
	MOV	DESSRTPNT,BX		; dest start pointer.

EDT_RIGHTCUT_LOOP:
	CALL	GET_1LINE		; get 1line.
	CALL	GET_KINSOKU		; 禁則チェック

	CMP	STRLENG,0		; string length.
	JE	EDT_RIGHTCUT_CTRL	;

	CALL	PUT_1LINE		; put 1line.

EDT_RIGHTCUT_CTRL:
	CALL	GET_CTRL_CODE		; get ctrl code.
	CMP	AX,1			; 1=end of file,2=line feed.
	JE	EDT_RIGHTCUT_LOOP_E	;

	CALL	PUT_LF			; line feed.
EDT_RIGHTCUT_NEXT:
	JMP	EDT_RIGHTCUT_LOOP

EDT_RIGHTCUT_LOOP_E:
	CALL	PUT_EOF			; end of file.

	CALL	COPY_WORK2TEXT		; copy work to text buffer.
	RET
EDT_RIGHTCUT	ENDP


; ****************************************************
;	copy work to text buffer.
; ****************************************************

COPY_WORK2TEXT	PROC	NEAR
	MOV	CX,DESPNT		; dest pointer.
	SUB	CX,DESSRTPNT		; dest start pointer.
	JCXZ	COPY_WORK2TEXT_EXIT	;

	MOV	DX,DESSEG		; dest segment.
	MOV	SI,DESSRTPNT		; dest start pointer.

	MOV	ES,SOUSEG		; source segment.
	MOV	DI,SOUSRTPNT		; source start pointer.

	PUSH	DS
	MOV	DS,DX			;
	REP	MOVSB			;
	POP	DS

COPY_WORK2TEXT_EXIT:
	RET
COPY_WORK2TEXT	ENDP


; ****************************************************
;	get 1line.
;	-I- GETLENGTH : get length.
;	-O- STRBUFF   : string buffer.
;	    STRLENG   : string length.
; ****************************************************

GET_1LINE	PROC	NEAR
	PUSH	DS
	MOV	DX,SOUSEG		; source segment.
	MOV	SI,SOUPNT		; source pointer.
	MOV	DI,OFFSET STRBUFF	; string buffer.
	MOVX	ES,DS			;
	MOV	CX,GETLENGTH		; get length.
	MOV	DS,DX			;
GET_1LINE_LOOP:				;
	LODSB				;
	CMP	AL,' '			;
	JB	GET_1LINE_EXIT		;
	STOSB				;
	LOOP	GET_1LINE_LOOP		;
	INC	SI			;
GET_1LINE_EXIT:
	DEC	SI			;
	POP	DS			;
	MOV	AX,SI			;
	SUB	AX,SOUPNT		; source pointer.
	MOV	STRLENG,AX		; string length.
	MOV	SOUPNT,SI		; source pointer.
	RET
GET_1LINE	ENDP


; ****************************************************
;	禁則チェック
;	-I/O- STRBUFF   : string buffer.
;	      STRLENG   : string length.
; ****************************************************

GET_KINSOKU	PROC	NEAR
	MOV	ES,SOUSEG		; source segment.
	MOV	BX,SOUPNT		; source pointer.
	MOV	AX,ES:[BX]		;

	CMP	AX,WORD PTR STRKIN1	;"．"	;禁則１
	JE	GET_KINSOKU_SET		;
	CMP	AX,WORD PTR STRKIN2	;"，"	;禁則２
	JE	GET_KINSOKU_SET		;
	CMP	AX,WORD PTR STRKIN3	;"」"	;禁則３
	JE	GET_KINSOKU_SET		;
	CMP	AX,WORD PTR STRKIN4	;"・"	;禁則４
	JE	GET_KINSOKU_SET		;
	JMP	GET_KINSOKU_EXIT	;

GET_KINSOKU_SET:
	MOV	DI,OFFSET STRBUFF	; string buffer.
	ADD	DI,STRLENG		; string length.
	MOV	DS:[DI],AX		;
	MOV	WORD PTR DS:[DI][2],0	;

	ADD	STRLENG,2		; string length.
	ADD	SOUPNT,2		; source pointer.
GET_KINSOKU_EXIT:
	RET
GET_KINSOKU	ENDP


; ****************************************************
;	get ctrl code.
;	-O- AX : 0=normal,1=end of file,2=line feed,3=tab.
; ****************************************************

GET_CTRL_CODE	PROC	NEAR
	MOV	ES,SOUSEG		; source segment.
	MOV	DI,SOUPNT		; source pointer.
	MOV	AL,ES:[DI]		;
	CMP	AL,0			;
	JE	GET_CTRL_CODE_EOF	;
	CMP	AL,CHR_CR		; CR
	JE	GET_CTRL_CODE_LF	;
	CMP	AL,CHR_TAB		; TAB
	JE	GET_CTRL_CODE_TAB	;

	MOV	AX,0			; 0=normal.
	RET
GET_CTRL_CODE_EOF:
	ADD	SOUPNT,1		; source pointer.
	MOV	AX,1			; 1=end of file.
	RET
GET_CTRL_CODE_LF:
	ADD	SOUPNT,2		; source pointer.
	MOV	AX,2			; 2=line feed.
	RET
GET_CTRL_CODE_TAB:
	ADD	SOUPNT,1		; source pointer.
	MOV	AX,3			; 3=tab.
	RET
GET_CTRL_CODE	ENDP


; ****************************************************
;	put 1line.
;	-I- STRBUFF : string buffer.
;	    STRLENG : string length.
; ****************************************************

PUT_1LINE	PROC	NEAR
	MOV	SI,OFFSET STRBUFF	; string buffer.
	MOV	ES,DESSEG		; dest segment.
	MOV	DI,DESPNT		; dest pointer.

	MOV	CX,STRLENG		; string length.
	JCXZ	PUT_1LINE_EXIT		;
PUT_1LINE_LOOP:				;
	LODSB				;
	CMP	AL,' '			;
	JB	PUT_1LINE_EXIT		;
	STOSB				;
	LOOP	PUT_1LINE_LOOP		;
PUT_1LINE_EXIT:
	MOV	DESPNT,DI		; dest pointer.
	RET
PUT_1LINE	ENDP


; ****************************************************
;	blank put.
;	-I- CX : length.
; ****************************************************

PUT_FF	PROC	NEAR
	MOV	ES,DESSEG		; dest segment.
	MOV	DI,DESPNT		; dest pointer.
	MOV	AL,' '			;
	REP	STOSB			;
	MOV	DESPNT,DI		; dest pointer.
	RET
PUT_FF	ENDP


; ****************************************************
;	line feed.
; ****************************************************

PUT_LF	PROC	NEAR
	MOV	ES,DESSEG		; dest segment.
	MOV	DI,DESPNT		; dest pointer.
	MOV	AX,0A0DH		; CR/LF
	STOSW				;
	MOV	DESPNT,DI		; dest pointer.
	RET
PUT_LF	ENDP


; ****************************************************
;	end of file.
; ****************************************************

PUT_EOF	PROC	NEAR
	MOV	ES,DESSEG		; dest segment.
	MOV	DI,DESPNT		; dest pointer.
	MOV	AX,0			;
	STOSW				;
	MOV	DESPNT,DI		; dest pointer.
	RET
PUT_EOF	ENDP


; ****************************************************
;	data.
; ****************************************************

EXTRN	EDTEXTSEG:WORD		; edit text buffer segment.
EXTRN	EDTEXTOFS:WORD		; edit text buffer offset.
EXTRN	EDWORKSEG:WORD		; edit work buffer segment.
EXTRN	EDWORKOFS:WORD		; edit work buffer offset.

		EVEN

SOUSEG		DW	0	; source segment.
SOUPNT		DW	0	; source pointer.
SOUSRTPNT	DW	0	; source start pointer.
DESSEG		DW	0	; dest segment.
DESPNT		DW	0	; dest pointer.
DESSRTPNT	DW	0	; dest start pointer.

LINEWIDTH	DW	80	; line width.

GETLENGTH	DW	80	; get length.

STRLENG		DW	0	; string length.
STRBUFF		DB	STRBUFLENGTH DUP (0),0,0,0,0	; string buffer.

STRKIN1		DB	"．"	;禁則１
STRKIN2		DB	"，"	;禁則２
STRKIN3		DB	"」"	;禁則３
STRKIN4		DB	"・"	;禁則４

CODE	ENDS
		END
;
;	end of "EDTTEXT.ASM"
;
