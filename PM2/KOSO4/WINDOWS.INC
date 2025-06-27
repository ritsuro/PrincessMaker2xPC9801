; "WINDOWS.INC" 486/33 make by R.H 1992/05/07
;
;
;	WINDOWS  exturn symboles.
;
;
; exturn symboles.

MOV_ID2	MACRO	DESTID,SOUID
	MOV	AX,DS
	MOV	ES,AX
	MOV	SI,OFFSET SOUID
	MOV	DI,OFFSET DESTID
	MOVSW
	MOVSW
	MOVSW
	MOVSW
	MOVSW
	ENDM

;	function start.
;	SEG CODE01 -> SUBLL:NEAR
;	SEG WINDOW -> w_SUBLL:NEAR

FUNC	MACRO	SUBLL
CODE01	SEGMENT	PUBLIC	'CODE01'
	ASSUME	CS:CODE01,DS:DATA
	PUBLIC	SUBLL
SUBLL	PROC	NEAR
	CALL	FAR PTR x_&SUBLL
	RET
SUBLL	ENDP
CODE01	ENDS
	ASSUME	CS:WINDOW,DS:DATA
	PUBLIC	w_&SUBLL
w_&SUBLL	PROC	NEAR
	CALL	FAR PTR x_&SUBLL
	RET
w_&SUBLL	ENDP
x_&SUBLL	PROC	FAR
	ENDM

;	function end.

FEND	MACRO	SUBLL
x_&SUBLL	ENDP
	ENDM

;	function start.(local exturn)
;	SEG WINDOW -> w_SUBLL:NEAR

FUNC_L	MACRO	SUBLL
	PUBLIC	w_&SUBLL
x_&SUBLL	PROC	NEAR
w_&SUBLL	LABEL	NEAR
	ENDM

;	function start.(code01->window)
;	SEG CODE01 -> SUBLL:NEAR
;	SEG WINDOW -> w_SUBLL:NEAR

FUNC_w	MACRO	SUBLL
WINDOW	SEGMENT	PUBLIC	'WINDOW'
	ASSUME	CS:WINDOW,DS:DATA
	PUBLIC	w_&SUBLL
w_&SUBLL	PROC	NEAR
	CALL	FAR PTR x_&SUBLL
	RET
w_&SUBLL	ENDP
WINDOW	ENDS
	ASSUME	CS:CODE01,DS:DATA
	PUBLIC	SUBLL
SUBLL	PROC	NEAR
	CALL	FAR PTR x_&SUBLL
	RET
SUBLL	ENDP
x_&SUBLL	PROC	FAR
	ENDM

;	function end.(code01->window)

FEND_w	MACRO	SUBLL
x_&SUBLL	ENDP
	ENDM

;*;;	exturn call.
;*;
;*;CALLE	MACRO	LBL
;*;	EXTRN	LBL:NEAR
;*;	CALL	LBL
;*;	ENDM

;	exturn call.(window segment)

CALL_w	MACRO	LBL
	EXTRN	w_&LBL:NEAR
	CALL	w_&LBL
	ENDM

;	minmax ajast.

MINMAX	MACRO	DEST,MMIN,MMAX
	LOCAL	L1,L2
	CMP	DEST,MMIN
	JNB	L1
	MOV	DEST,MMIN
L1:
	CMP	DEST,MMAX
	JBE	L2
	MOV	DEST,MMAX
L2:
	ENDM

; *********************************************************
;	code.
; *********************************************************
; *********************************************************
;	const.
; *********************************************************

STR_VAL_LEN 	EQU	6	; string length.Åiêîílï\é¶ópÅj
STR_VAL_LEN2	EQU	24	; string length.Åiêîílï\é¶ägí£Åj
STRING_LEN 	EQU	255	; string length.

; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	STR_BUFF:BYTE		; ï∂éöóÒÉoÉbÉtÉ@
EXTRN	STR_VAL_BUFF:BYTE	; ï\é¶ílï∂éöóÒÉoÉbÉtÉ@

EXTRN	ARAVRM:WORD		; vram plean.
EXTRN	ARA001:WORD		; âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì
EXTRN	ARA002:WORD		; âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì(width42)
EXTRN	ARA003:WORD		; âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì(width60)
EXTRN	ARA004:WORD		; âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì(width52)

EXTRN	SSEFC0:WORD		; visual data segment plean 0
EXTRN	SSEFC1:WORD		; visual data segment plean 1
EXTRN	SSEFC2:WORD		; visual data segment plean 2
EXTRN	SSEFC3:WORD		; visual data segment plean 3
EXTRN	SSEFCW:WORD		; visual data plean width.

;	SSGRx	: PARTST etc..

EXTRN	SSGR0:WORD		; visual data segment plean 0
EXTRN	SSGR1:WORD		; visual data segment plean 1
EXTRN	SSGR2:WORD		; visual data segment plean 2
EXTRN	SSGR3:WORD		; visual data segment plean 3
EXTRN	SSGRW:WORD		; visual data plean width.

;	SSGRVx	: PLSLD6 etc..

EXTRN	SSGRV0:WORD		; visual data segment plean 0
EXTRN	SSGRV1:WORD		; visual data segment plean 1
EXTRN	SSGRV2:WORD		; visual data segment plean 2
EXTRN	SSGRV3:WORD		; visual data segment plean 3
EXTRN	SSGRVW:WORD		; visual data plean width.

;	SSDESx	: used = ADVMOV.ASM/HVLINE.ASM/TALKER.ASM
;				/WIDMTRX.ASM/WIDSLCT.ASM

EXTRN	SSDES0:WORD		; visual data segment plean 0
EXTRN	SSDES1:WORD		; visual data segment plean 1
EXTRN	SSDES2:WORD		; visual data segment plean 2
EXTRN	SSDES3:WORD		; visual data segment plean 3
EXTRN	SSDESW:WORD		; visual data plean width.

;	SSSOUx	: used = ADVMOV.ASM/TALKER.ASM

EXTRN	SSSOU0:WORD		; visual data segment plean 0
EXTRN	SSSOU1:WORD		; visual data segment plean 1
EXTRN	SSSOU2:WORD		; visual data segment plean 2
EXTRN	SSSOU3:WORD		; visual data segment plean 3
EXTRN	SSSOUW:WORD		; visual data plean width.

;	SSEFCx	: used = EFECT2.ASM

EXTRN	SSEFC0:WORD		; visual data segment plean 0
EXTRN	SSEFC1:WORD		; visual data segment plean 1
EXTRN	SSEFC2:WORD		; visual data segment plean 2
EXTRN	SSEFC3:WORD		; visual data segment plean 3
EXTRN	SSEFCW:WORD		; visual data plean width.

;	SSCURx	: MUSCOR.ASM  MUSCR2.ASM

EXTRN	SSCUR0:WORD		; visual data segment plean 0
EXTRN	SSCUR1:WORD		; visual data segment plean 1
EXTRN	SSCUR2:WORD		; visual data segment plean 2
EXTRN	SSCUR3:WORD		; visual data segment plean 3
EXTRN	SSCURW:WORD		; visual data plean width.

;	SEGVTx	: MINTXT.ASM

EXTRN	SEGVT0:WORD		; visual data segment plean 0
EXTRN	SEGVT1:WORD		; visual data segment plean 1
EXTRN	SEGVT2:WORD		; visual data segment plean 2
EXTRN	SEGVT3:WORD		; visual data segment plean 3
EXTRN	SEGVTW:WORD		; visual data plean width.

EXTRN	WDX1:WORD		; WINDOWS/point x1.
EXTRN	WDY1:WORD		; WINDOWS/point y1.
EXTRN	WDX2:WORD		; WINDOWS/point x2.
EXTRN	WDY2:WORD		; WINDOWS/point y2.

EXTRN	VX1:WORD		; point x1.
EXTRN	VY1:WORD		; point y1.
EXTRN	VX2:WORD		; point x2.
EXTRN	VY2:WORD		; point y2.
EXTRN	VX3:WORD		; point x3.
EXTRN	VY3:WORD		; point y3.
EXTRN	ADRS:WORD		; address.
EXTRN	NUM:WORD		; number.
EXTRN	VCOL:WORD		; color.

EXTRN	VRX:WORD		; x point.
EXTRN	VRY:WORD		; y point.
EXTRN	VRLENX:WORD		; x length.
EXTRN	VRLENY:WORD		; y length.

EXTRN	VRPX:WORD		; ÇfÇdÇs Çwç¿ïW
EXTRN	VRPY:WORD		; ÇfÇdÇs Çxç¿ïW
EXTRN	VRLENPX:WORD		; ÇfÇdÇs ÇwÉTÉCÉY
EXTRN	VRLENPY:WORD		; ÇfÇdÇs ÇxÉTÉCÉY

DATA	ENDS

;
;	end of "WINDOWS.INC"
;
