; "VPCKEYBO.ASM" PC-9801UV11 make by R.H 1990/01/13
;		modify 1991/06/22 PS55Z/S14 by R.H
;		modify 1992/05/07 r.h
;
;
;
;	KEYBORD I/O.(PC/AT)
;
;
; public subroutine.

IN_8259	MACRO	AA,NUM
;same;	IN	AL,NUM
	PUSH	DX
	MOV	DX,NUM			;
	CALL	IN_8259_PORT		; in  port 8259.
	POP	DX
	ENDM

OUT8259	MACRO	NUM,AA
;same;	OUT	NUM,AL
	PUSH	DX
	MOV	DX,NUM			;
	CALL	OUT_8259_PORT		; out port 8259.
	POP	DX
	ENDM

IN_8255	MACRO	AA,NUM
;same;	IN	AL,NUM
	PUSH	DX
	MOV	DX,NUM			;
	CALL	IN_8255_PORT		; in  prot 8255.
	POP	DX
	ENDM

OUT8255	MACRO	NUM,AA
;same;	OUT	NUM,AL
	PUSH	DX
	MOV	DX,NUM			;
	CALL	OUT_8255_PORT		; out prot 8255.
	POP	DX
	ENDM

CODE	SEGMENT	PUBLIC	'CODE'
	ASSUME	CS:CODE

EXTRN	XSTOPX:FAR	; ÇrÇsÇnÇoÉLÅ[èIóπèàóù
			; ÉfÉoÉbÉNéûÇ…ÇrÇsÇnÇoÉLÅ[ÇâüÇ∑Ç∆Ç±Ç±Ç…îÚÇ—çûÇÒÇ≈Ç≠ÇÈ

CODE	ENDS

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	VPCKYBSRT		; keybord start.
PUBLIC	VPCKYBEND		; keybord end.
PUBLIC	VPCKYBSTP		; keybord stop.
PUBLIC	VPCKYBCNT		; keybord cont.

PUBLIC	VPCKYBONS		; keybord STOP key on.
PUBLIC	VPCKYBOFS		; keybord STOP key off.

EXTRN	IN_8259_PORT:NEAR	; in  port 8259.
EXTRN	OUT_8259_PORT:NEAR	; out port 8259.
EXTRN	IN_8255_PORT:NEAR	; in  prot 8255.
EXTRN	OUT_8255_PORT:NEAR	; out prot 8255.

EXTRN	VPCTMVCLR:NEAR		; V-SYNC timer clear.


;	keybord start.

VPCKYBSRT	PROC	NEAR
	CALL	VECSET_KEYBORD_SAVE	; vector save.

	CALL	VECSET_KEYBORD		; keybord int vector.

	CLI
	IN_8259	AL,21H			; IMR save.
	MOV	SAVE_IMR,AX		;

	AND	AL,11111101B		; unmask.(IR1)
	OUT8259	21H,AL			; IMR set.
	STI

	RET
VPCKYBSRT	ENDP


;	keybord end.

VPCKYBEND	PROC	NEAR

	CALL	VECSET_KEYBORD_STOP	; keybord stop vector.

	CLI
	MOV	AX,SAVE_IMR		;
	OUT8259	21H,AL			; IMR load.
	STI

	CALL	VECSET_KEYBORD_LOAD	; vector load.

	RET
VPCKYBEND	ENDP


;	keybord stop.

VPCKYBSTP	PROC	NEAR

	CALL	VECSET_KEYBORD_STOP	; keybord stop vector.

	JMP	KYBSTP2			; JUMP (cpu cue buffer clear.)
KYBSTP2:				;

	TEST	BYTE PTR SAVE_IMR,00000010B	; return mask. (IR1)
	JZ	KYBSTP1			; set mask ?

	CLI
	IN_8259	AL,21H			; IMR read.
	OR	AL,00000010B		; mask.(IR1)
	OUT8259	21H,AL			; IMR write.
	STI
KYBSTP1:
	CALL	VECSET_KEYBORD_LOAD	; vector load.

	RET
VPCKYBSTP	ENDP


;	keybord cont.

VPCKYBCNT	PROC	NEAR
	CALL	VECSET_KEYBORD		; keybord int vector.

	CLI
	IN_8259	AL,21H			; IMR read.
	AND	AL,11111101B		; unmask.(IR1)
	OUT8259	21H,AL			; IMR write.
	STI

	RET
VPCKYBCNT	ENDP


;	keybord STOP key on.

VPCKYBONS	PROC	NEAR
	MOV	STOPKEY_FLAG,1		; 1=STOP key on.
	RET
VPCKYBONS	ENDP


;	keybord STOP key off.

VPCKYBOFS	PROC	NEAR
	MOV	STOPKEY_FLAG,0		; 0=STOP key off.
	RET
VPCKYBOFS	ENDP



VEC_KEY_OFST	EQU	24H	; int 09h
VEC_KEY_SEG	EQU	26H	;

;	common subroutine.

VECSET_KEYBORD	PROC	NEAR
	CLI

	MOV	AX,0		; 0 base.
	MOV	ES,AX		;

	MOV	WORD PTR ES:[VEC_KEY_OFST],OFFSET KEYINT

	MOV	WORD PTR ES:[VEC_KEY_SEG],SEG CODE01

	STI
	RET
VECSET_KEYBORD	ENDP

VECSET_KEYBORD_STOP	PROC	NEAR
	CLI

	MOV	AX,0		; 0 base.
	MOV	ES,AX		;

	MOV	WORD PTR ES:[VEC_KEY_OFST],OFFSET KEYINT_STOP

	MOV	WORD PTR ES:[VEC_KEY_SEG],SEG CODE01

	STI
	RET
VECSET_KEYBORD_STOP	ENDP

VECSET_KEYBORD_SAVE	PROC	NEAR
	CLI

	MOV	AX,0		; 0 base.
	MOV	ES,AX		;

	MOV	AX,WORD PTR ES:[VEC_KEY_OFST]
	MOV	SAVE_VEC_KEY_OFST,AX

	MOV	AX,WORD PTR ES:[VEC_KEY_SEG]
	MOV	SAVE_VEC_KEY_SEG,AX

	STI
	RET
VECSET_KEYBORD_SAVE	ENDP

VECSET_KEYBORD_LOAD	PROC	NEAR
	CLI

	MOV	AX,0		; 0 base.
	MOV	ES,AX		;

	MOV	AX,SAVE_VEC_KEY_OFST
	MOV	WORD PTR ES:[VEC_KEY_OFST],AX

	MOV	AX,SAVE_VEC_KEY_SEG
	MOV	WORD PTR ES:[VEC_KEY_SEG],AX

	STI
	RET
VECSET_KEYBORD_LOAD	ENDP

CODE01	ENDS



;	keybord interrapt routine.

PORT_A		EQU	60H	; data read/command write.

KYCMDW		EQU	43H	; mode/command write.
KYDATR		EQU	41H	; data read.
KYSTRD		EQU	43H	; status read.

KRETRY_MAX	EQU	3	; keybord retry counter max.


CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

KEYINT	PROC	FAR
	PUSH	DS
	PUSH	AX
	PUSH	BX
	PUSH	CX

	MOV	CX,5		;
KEYINT_WT:			;
	NOP			;
	LOOP	KEYINT_WT	; JUMP (cpu cue buffer clear.)

	MOV	AX,SEG DATA	; DS=data segment.
	MOV	DS,AX		;

	IN_8255	AL,PORT_A	; data read/command write.
KEYINT_SET:
	MOV	KYCODE,AL
	CALL	KEY_CODE_SET	; key code set.

	CALL	KEY_LOCATE	; key locate.
KEYINT_EXIT:
	MOV	AL,20H		; EOI send.
	OUT8259	20H,AL		;

;;;;;;;;;;;;;;;;;;;;;;;;
	TEST	BYTE PTR DS:KYTBLS[13],1000B	; [F3] key on?
	JZ	KEYINT_TIMER_CLR
	CALL	VPCTMVCLR			; V-SYNC timer clear.
KEYINT_TIMER_CLR:
	CMP	KYTBLS[8],10B		; [O] key on?
	JNE	KEYINT_TIMER_DEBUG
	CMP	KYTBLS[2],1000B		; [M] key on?
	JNE	KEYINT_TIMER_DEBUG
	CMP	KYTBLS[5],10B		; [Y] key on?
	JNE	KEYINT_TIMER_DEBUG
	MOV	STOPKEY_FLAG,1		;1=STOP key on / 0=STOP key off.
	MOV	IDBG[5*2],1		;Ç»ÇÒÇ≈Ç‡âÆ
KEYINT_TIMER_DEBUG:
;;;;;;;;;;;;;;;;;;;;;;;;

;*;	CMP	DOSACS,1	; DOS access flag. 0=nomal,1=now access.
;*;	JE	KEYINT_EXIT3	; (DISKRD.ASM)

;*;	CMP	BYTE PTR DS:KYTBLS[14],1	; key codeÅuBSÅv
;*;	JNE	KEYINT_EXIT2			;
;*;	CMP	BYTE PTR DS:KYTBLS[11],1000B	; [F1] key on?
;*;	JE	KEYINT_EXIT_STOP_KEY		;

	CMP	BYTE PTR DS:KYTBLS[11],1000B	; [F1] key on?
	JE	KEYINT_EXIT_STOP_KEY		;

KEYINT_EXIT2:
	CMP	BYTE PTR DS:KYTBLS[13],10B	; key codeÅuCtrlÅv
	JNE	KEYINT_EXIT3			;
	CMP	BYTE PTR DS:KYTBLS[8],1000B	; key codeÅuAltÅv
	JNE	KEYINT_EXIT3			;
;*;	CMP	BYTE PTR DS:KYTBLS[10],100B	; key codeÅuDeleteÅv
;*;	JNE	KEYINT_EXIT3			;
	CMP	BYTE PTR DS:KYTBLS[3],100000B	; key codeÅuDeleteÅv
	JNE	KEYINT_EXIT3			;

	JMP	KEYINT_EXIT_RESET		;

KEYINT_EXIT3:
	POP	CX
	POP	BX
	POP	AX
	POP	DS

	IRET

KEYINT_EXIT_STOP_KEY:
	CMP	STOPKEY_FLAG,0		; 1=STOP key on / 0=STOP key off.
	JE	KEYINT_EXIT2		;
KEYINT_EXIT_RESET:
	POP	CX
	POP	BX
	POP	AX
	POP	DS

	MOV	BP,SP			;
	MOV	AX,OFFSET XSTOPX	; ÇrÇsÇnÇoÉLÅ[èIóπèàóù
	MOV	[BP],AX			; ÇhÇo
	MOV	AX,SEG CODE		;
	MOV	[BP][2],AX		; ÇbÇr
	; SS:SP [  I P  ] +0
	;       [  C S  ] +2
	;       [ flags ] +4
	IRET
KEYINT	ENDP


;	key code set.
;	-I-   AL : read data.
;	-I/O- DS:[KYTBLS] : key code table.

KEY_CODE_SET	PROC	NEAR
	TEST	AL,80H			; break?
	JNZ	KEY_CODE_SET_BREAK	;

KEY_CODE_SET_MAKE:
	MOV	BL,AL			;
	AND	BX,1111B		; key group num.
	
	MOV	CL,AL			;
	AND	CL,7FH			;
	SHR	CL,1			; 1 nibl shift.
	SHR	CL,1			;
	SHR	CL,1			;
	SHR	CL,1			;
	MOV	AH,1			;
	SHL	AH,CL			; bitset
	OR	DS:KYTBLS[BX],AH	;
	RET

KEY_CODE_SET_BREAK:
	MOV	BL,AL			;
	AND	BX,1111B		; key group num.
	
	MOV	CL,AL			;
	AND	CL,7FH			;
	SHR	CL,1			; 1 nibl shift.
	SHR	CL,1			;
	SHR	CL,1			;
	SHR	CL,1			;
	MOV	AH,11111110B		;
	ROL	AH,CL			; bitset
	AND	DS:KYTBLS[BX],AH	;
	RET
KEY_CODE_SET	ENDP



;	key locate.
;	-I- DS:KYTBLS : key code table.
;	-O- DS:KYDRX  : key locate direction x(+-)
;	    DS:KYDRY  : key locate direction y(+-)
;	    DS:KYONL  : key left  bottan.(0=ON)
;	    DS:KYONR  : key right bottan.(0=ON)

KEY_LOCATE	PROC	NEAR
	MOV	BX,0				; key locate direction x(+-)
	MOV	CX,0				; key locate direction y(+-)

	TEST	BYTE PTR DS:KYTBLS[11],10000B	; left.
	JZ	KEY_LOCATE1			;
	DEC	BX				; x--
KEY_LOCATE1:
	TEST	BYTE PTR DS:KYTBLS[13],10000B	; right.
	JZ	KEY_LOCATE11			;
	INC	BX				; x++
KEY_LOCATE11:
	TEST	BYTE PTR DS:KYTBLS[8],10000B	; upper.
	JZ	KEY_LOCATE2			;
	DEC	CX				; y--
KEY_LOCATE2:
	TEST	BYTE PTR DS:KYTBLS[0],100000B	; under.
	JZ	KEY_LOCATE22			;
	INC	CX				; y++
KEY_LOCATE22:
	MOV	DS:KYDRX,BX			; key locate direction x(+-)
	MOV	DS:KYDRY,CX			; key locate direction y(+-)

	MOV	KYONL,1				; key left  bottan.(0=ON)
	TEST	BYTE PTR DS:KYTBLS[12],100B	; 'Z'
	JNZ	KEY_LOCATE52			;
	TEST	BYTE PTR DS:KYTBLS[9],1000B	; [SPACE]
	JNZ	KEY_LOCATE52			;
	TEST	BYTE PTR DS:KYTBLS[12],10B	; extension key [ENTER]
	JNZ	KEY_LOCATE52			;
	TEST	BYTE PTR DS:KYTBLS[10],100B	; extension key.
	JZ	KEY_LOCATE54			;
	TEST	BYTE PTR DS:KYTBLS[3],100000B	; extension key [DEL]
	JNZ	KEY_LOCATE52			;
	JMP	KEY_LOCATE54			;
KEY_LOCATE52:					;
	MOV	KYONL,0				; key left  bottan.(0=ON)
KEY_LOCATE54:					;

	MOV	KYONR,1				; key right bottan.(0=ON)
	TEST	BYTE PTR DS:KYTBLS[13],100B	; 'X'
	JNZ	KEY_LOCATE55			;
	TEST	BYTE PTR DS:KYTBLS[10],100B	; extension key.
	JZ	KEY_LOCATE59			;
	TEST	BYTE PTR DS:KYTBLS[1],100000B	; extension key [PAGE DOWN]
	JNZ	KEY_LOCATE55			;
	JMP	KEY_LOCATE59			;
KEY_LOCATE55:					;
	MOV	KYONR,0				; key right bottan.(0=ON)
KEY_LOCATE59:
	RET
KEY_LOCATE	ENDP



KEYINT_STOP	PROC	FAR
	PUSH	AX
	MOV	AL,20H	; EOI send.
	OUT8259	20H,AL	;
	POP	AX
	IRET
KEYINT_STOP	ENDP

CODE01	ENDS




DATA	SEGMENT	PUBLIC	'DATA'

;*;EXTRN DOSACS:WORD		; DOS access flag. 0=nomal,1=now access.
;*;				; (DISKIO.ASM)

EXTRN	IDBG:WORD			; ÉfÉoÉbÉOÉtÉâÉO

SAVE_IMR		DW	0	; IMR save area.

SAVE_VEC_KEY_OFST	DW	0	; keybord vector offset.
SAVE_VEC_KEY_SEG	DW	0	; keybord vector segment.

KRETRY			DW	0	; keybord retry counter.

;	key direction.

EXTRN		KYDRX:WORD		; key locate direction x(+-)
EXTRN		KYDRY:WORD		; key locate direction y(+-)
EXTRN		KYONL:WORD		; key left  bottan.(0=ON)
EXTRN		KYONR:WORD		; key right bottan.(0=ON)
;*;PUBLIC	KYDRX			; key locate direction x(+-)
;*;PUBLIC	KYDRY			; key locate direction y(+-)
;*;PUBLIC	KYONL			; key left  bottan.(0=ON)
;*;PUBLIC	KYONR			; key right bottan.(0=ON)
;*;KYDRX	DW	0		; key locate direction x(+-)
;*;KYDRY	DW	0		; key locate direction y(+-)
;*;KYONL	DW	1		; key left  bottan.(0=ON)
;*;KYONR	DW	1		; key right bottan.(0=ON)


;	[STOP] key intarapt flag.

STOPKEY_FLAG	DW	0		; 1=STOP key on / 0=STOP key off.

;*;PUBLIC	KYCODE				; key code.
KYCODE	DB	0

EXTRN	KYTBLS:BYTE	;(VKEYBORD.ASM)
;*;PUBLIC	KYTBLS				; key code table.
;*;KYTBLS	 LABEL	BYTE
;*;	DB	0	;0
;*;	DB	0	;1
;*;	DB	0	;2
;*;	DB	0	;3
;*;	DB	0	;4
;*;	DB	0	;5
;*;	DB	0	;6
;*;	DB	0	;7
;*;	DB	0	;8
;*;	DB	0	;9
;*;	DB	0	;A
;*;	DB	0	;B
;*;	DB	0	;C
;*;	DB	0	;D
;*;	DB	0	;E
;*;	DB	0	;F

DATA	ENDS

	END
;
;	end of "VPCKEYBO.ASM"
;
