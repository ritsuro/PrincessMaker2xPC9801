; "ZBEXTRN.INC" 486/33 make by R.H 1992/05/07
;
;
;	Z B I O S   exturn symboles.
;
;
; exturn symboles.

; *********************************************************
;	code.
; *********************************************************
; *********************************************************
;	const.
; *********************************************************
; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	ARAVRM:WORD		; vram plean.

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

;
;	end of "ZBEXTRN.INC"
;
