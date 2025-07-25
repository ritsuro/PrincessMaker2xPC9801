; "VRMMOV.ASM" PC-9801UV11 make by R.H 1989/12/27
;	modify 1991/06/22 PS55Z/J14 (code01 gate call)
;
;	uq`lf[^|obt@]
;
; public subroutine.
;
;	SSGR0			; visual data segment plean 0
;	SSGR1			; visual data segment plean 1
;	SSGR2			; visual data segment plean 2
;	SSGR3			; visual data segment plean 3
;

CODE01	SEGMENT	PUBLIC	'CODE01'
	ASSUME	CS:CODE01,DS:DATA

PUBLIC	VRMGT			; uq`lf[^fds
PUBLIC	VRMPT			; uq`lf[^ots

EXTRN	VCXRTW_OL:NEAR		; I[obvots

EXTRN C1VV_BANK_CHG_ES:NEAR	; vram bank check & chenge. ES
EXTRN C1VV_BANK_PLN_DS:NEAR	; vram bank check & chenge.(READ) DS

;	uq`lf[^ots
;	if[^³kp[Nobt@|uq`lRs[j
;	-I- VRX    : uq`l@wΐW
;	    VRY    : uq`l@xΐW
;	    VRLENX : wϋό·³
;	    VRLENY : xϋό·³
;	    BPNTOF : f[^obt@|C^
;	    BPNTSG : f[^obt@ZOg
;	    BCNTMX : f[^Εε·³

VRMPT	PROC	NEAR
	CMP	BBOVLP,0	; I[obvtO
	JNE	VRMPT_OL	;

	CALL	VRAMPUT		; [Nobt@|uq`l]
	JMP	VRMPT_EXIT	;
VRMPT_OL:
	PUSH	DS		;
	MOV	AX,DS		;
	MOV	ES,AX		;
	MOV	SI,BPNTOF	; f[^obt@|C^
	MOV	AX,BPNTSG	; f[^obt@ZOg
	MOV	DS,AX		;
	CALL	VCXRTW_OL	; I[obvots
	POP	DS		;
	JMP	VRMPT_EXIT	;
VRMPT_EXIT:
	RET
VRMPT	ENDP




;	uq`lf[^fds
;	iuq`l|f[^³kp[Nobt@Rs[j
;	-I- VRX    : uq`l@wΐW
;	    VRY    : uq`l@xΐW
;	    VRLENX : wϋό·³
;	    VRLENY : xϋό·³
;	    BPNTOF : f[^obt@|C^
;	    BPNTSG : f[^obt@ZOg
;	    BCNTMX : f[^Εε·³
;	-O- BCOUNT ; f[^·³
;	    BPOINT ; f[^IνθAhX{P
;	    AH     : 0=normal 1=E.O.F

VRMGT	PROC	NEAR
	CALL	VRAMGET		; uq`l|[Nobt@]
	RET
VRMGT	ENDP


;	uq`l|[Nobt@]
;	-I- VRX    : uq`l@wΐW
;	    VRY    : uq`l@xΐW
;	    VRLENX : wϋό·³
;	    VRLENY : xϋό·³
;	    BPNTOF : f[^obt@|C^
;	    BPNTSG : f[^obt@ZOg
;	    BCNTMX : f[^Εε·³

VRAMPUT	PROC	NEAR
	PUSH	BX
	PUSH	CX
	PUSH	DX

	MOV	AX,VRY			;
	MOV	BX,SSGRW		; vram width.
	MUL	BX			;
	MOV	DI,AX			; point address.
	ADD	DI,VRX			; DI = VRY * SSGRW + VRX

	PUSH	DS

	MOV	DX,VRLENX		; DX=woCg
	MOV	BX,VRLENY		; BX=xC
	MOV	BP,SSGRW		; vram width.

	MOV	AX,DS			;

	MOV	SI,BPNTOF		; f[^obt@|C^
	MOV	CX,BPNTSG		; f[^obt@ZOg
	MOV	DS,CX			;

	MOV	ES,AX			;
	MOV	CX,ES:SSGR0		; visual data segment plean 0
	MOV	ES,CX			;
	CALL	VRAMPUT_PLN		; [Nobt@]|uq`l

	MOV	ES,AX			;
	MOV	CX,ES:SSGR1		; visual data segment plean 1
	MOV	ES,CX			;
	CALL	VRAMPUT_PLN		; [Nobt@]|uq`l

	MOV	ES,AX			;
	MOV	CX,ES:SSGR2		; visual data segment plean 2
	MOV	ES,CX			;
	CALL	VRAMPUT_PLN		; [Nobt@]|uq`l

	MOV	ES,AX			;
	MOV	CX,ES:SSGR3		; visual data segment plean 3
	MOV	ES,CX			;
	CALL	VRAMPUT_PLN		; [Nobt@]|uq`l

	POP	DS
VRAMPUT9:
	POP	DX
	POP	CX
	POP	BX
	RET
VRAMPUT	ENDP


;	[Nobt@]|uq`l
;	-I-   ES:DI : vram address.
;	      DX    : x byte length.
;	      BX    : y byte length.
;	      BP    : vram width.
;	-I/O- DS:SI : work buffer.

VRAMPUT_PLN	PROC	NEAR
	PUSH	BX
	PUSH	DI
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge. ES
VRAMPUT_PLN_3:
	MOV	CX,DX			; DX=woCg
	REP	MOVSB			; ]
	SUB	DI,DX			;
	ADD	DI,BP			; ΜC
	DEC	BX			; y line count.
	JNZ	VRAMPUT_PLN_3		;
	POP	DI
	POP	BX
	RET
VRAMPUT_PLN	ENDP


;	uq`l|[Nobt@]
;	-I- VRX    : uq`l@wΐW
;	    VRY    : uq`l@xΐW
;	    VRLENX : wϋό·³
;	    VRLENY : xϋό·³
;	    BPNTOF : f[^obt@|C^
;	    BPNTSG : f[^obt@ZOg
;	    BCNTMX : f[^Εε·³
;	-O- BCOUNT ; f[^·³
;	    BPOINT ; f[^IνθAhX{P
;	    AH     : 0=normal 1=E.O.F

VRAMGET	PROC	NEAR
	PUSH	BX
	PUSH	CX
	PUSH	DX

	MOV	AX,VRLENX		;
	MOV	BX,VRLENY		; f[^TCYvZ
	IMUL	BX			;
	SHL	AX,1			;
	SHL	AX,1			; * 4 plean
	MOV	BCOUNT,AX		; f[^·³
	CMP	AX,BCNTMX		; f[^Εε·³
	JBE	VRAMGET1		;

	MOV	AH,1			; 1=E.O.F
	POP	DX
	POP	CX
	POP	BX
	RET

VRAMGET1:
	ADD	AX,BPNTOF		; f[^obt@|C^{Γή°ΐ»²½ή
	MOV	BPOINT,AX		; f[^IνθAhX{P

	MOV	AX,VRY			;
	MOV	BX,SSGRW		; vram width.
	MUL	BX			;
	MOV	SI,AX			; point address.
	ADD	SI,VRX			; SI = VRY * SSGRW + VRX

	PUSH	DS

	MOV	AX,BPNTSG		;
	MOV	ES,AX			;
	MOV	DI,BPNTOF		;

	MOV	DX,VRLENX		; DX=woCg
	MOV	BX,VRLENY		; BX=xC
	MOV	BP,SSGRW		; vram width.

	MOV	AX,DS			;

	MOV	CX,SSGR0		; visual data segment plean 0
	MOV	DS,CX			;
	CALL	VRAMGET_PLN		; uq`l|[Nobt@]

	MOV	DS,AX			;
	MOV	CX,SSGR1		; visual data segment plean 1
	MOV	DS,CX			;
	CALL	VRAMGET_PLN		; uq`l|[Nobt@]

	MOV	DS,AX			;
	MOV	CX,SSGR2		; visual data segment plean 2
	MOV	DS,CX			;
	CALL	VRAMGET_PLN		; uq`l|[Nobt@]

	MOV	DS,AX			;
	MOV	CX,SSGR3		; visual data segment plean 3
	MOV	DS,CX			;
	CALL	VRAMGET_PLN		; uq`l|[Nobt@]

	POP	DS
VRAMGET9:
	MOV	AH,0			; 0=normal 1=E.O.F
	POP	DX
	POP	CX
	POP	BX
	RET
VRAMGET	ENDP


;	uq`l|[Nobt@]
;	-I-   DS:SI : vram address.
;	      DX    : x byte length.
;	      BX    : y byte length.
;	      BP    : vram width.
;	-I/O- ES:DI : work buffer.

VRAMGET_PLN	PROC	NEAR
	PUSH	BX
	PUSH	SI
	CALL	C1VV_BANK_PLN_DS	; vram bank check & chenge.(READ) DS
VRAMGET_PLN_3:
	MOV	CX,DX			; DX=woCg
	REP	MOVSB			; ]
	SUB	SI,DX			;
	ADD	SI,BP			; ΜC
	DEC	BX			; y line count.
	JNZ	VRAMGET_PLN_3		;
	POP	SI
	POP	BX
	RET
VRAMGET_PLN	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	BBOVLP:WORD		; p^[otsI[obvtO

EXTRN	VRX:WORD		; x point.
EXTRN	VRY:WORD		; y point.

EXTRN	VRLENX:WORD		; x length.
EXTRN	VRLENY:WORD		; y length.

EXTRN	BPOINT:WORD		; data buffer point.
EXTRN	BPNTOF:WORD		; f[^obt@|C^
EXTRN	BPNTSG:WORD		; f[^obt@ZOg
EXTRN	BCNTMX:WORD		; f[^Εε·³
EXTRN	BCOUNT:WORD		; f[^·³

EXTRN	PRSVMOD:WORD		; vram mode.0=normal,1=video memory

EXTRN	SSGR0:WORD		; visual data segment plean 0
EXTRN	SSGR1:WORD		; visual data segment plean 1
EXTRN	SSGR2:WORD		; visual data segment plean 2
EXTRN	SSGR3:WORD		; visual data segment plean 3
EXTRN	SSGRW:WORD		; visual data plean width.

DATA	ENDS

	END
;
;	end of "VRMMOV.ASM"
;
