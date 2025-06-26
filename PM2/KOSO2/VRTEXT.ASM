; "VRTEXT.ASM" 1988/12/21 R.H
;
;	text vram put routine.
;
;	PC-9801UV11 make by R.H 1988
;
;		VTXPAC  ｾﾘﾌ 1ﾓｼﾞ ｺﾞﾄﾆ call ｼﾏｽﾉﾃﾞ ｸﾁﾊﾟｸ ｦ ｻｾﾃ ｸﾀﾞｻｲ｡
;		VTXEND  ｾﾘﾌ ﾉ ｵﾜﾘ ﾆ   call ｼﾏｽﾉﾃﾞ ｸﾁﾊﾟｸ ｦ ﾄﾒﾃ ｸﾀﾞｻｲ｡
;
;
;
; public subroutine.

INCLUDE	TSTSET.INC
INCLUDE	MACHINEX.INC

IN_GDC	MACRO	AA,NUM
;same;	IN	AL,NUM
	PUSH	DX
	MOV	DX,NUM			;
	CALL	IN_7220_GDC_PORT	; in  port 7220 GDC.
	POP	DX
	ENDM

OUTGDC	MACRO	NUM,AA
;same;	OUT	NUM,AL
	PUSH	DX
	MOV	DX,NUM			;
	CALL	OUT_7220_GDC_PORT	; out port 7220 GDC.
	POP	DX
	ENDM

CODE01	SEGMENT	PUBLIC	'CODE01'
	ASSUME	CS:CODE01,DS:DATA,ES:DATA

PUBLIC	VTXPRN		; vram text print.
PUBLIC	VTXPOR		; vram text print OR.
PUBLIC	VTXPFC		; vram text print fuchi.
PUBLIC	VTXSIZ		; character size set.
PUBLIC	VTXCOL		; character color set.

;*;EXTRN VTXPAC:NEAR	; ｾﾘﾌ 1ﾓｼﾞ ｺﾞﾄﾆ call ｼﾏｽﾉﾃﾞ ｸﾁﾊﾟｸ ｦ ｻｾﾃ ｸﾀﾞｻｲ｡
;*;EXTRN VTXEND:NEAR	; ｾﾘﾌ ﾉ ｵﾜﾘ ﾆ   call ｼﾏｽﾉﾃﾞ ｸﾁﾊﾟｸ ｦ ﾄﾒﾃ ｸﾀﾞｻｲ｡
;*;VTXPAC:RET		; ｾﾘﾌ 1ﾓｼﾞ ｺﾞﾄﾆ call ｼﾏｽﾉﾃﾞ ｸﾁﾊﾟｸ ｦ ｻｾﾃ ｸﾀﾞｻｲ｡
;*;VTXEND:RET		; ｾﾘﾌ ﾉ ｵﾜﾘ ﾆ   call ｼﾏｽﾉﾃﾞ ｸﾁﾊﾟｸ ｦ ﾄﾒﾃ ｸﾀﾞｻｲ｡

EXTRN	IN_7220_GDC_PORT:NEAR	; in  port 7220 GDC.
EXTRN	OUT_7220_GDC_PORT:NEAR	; out port 7220 GDC.

EXTRN	C1VV_BANK_XCG_DX:NEAR	; vram bank check & chenge.(READ/WRITE) DX
EXTRN	C1VV_BANK_XCG_ES:NEAR	; vram bank check & chenge.(READ/WRITE) ES

EXTRN	C1GETFONT:NEAR		; get text font.
EXTRN	C1GETFONTZ:NEAR		; get zenkaku text font.


; vram text print.
; -i- DS:SI   : string. (null=end of string)
;     AX      : location x point.
;     BX      : location y point.

VTXPRN	PROC	NEAR
	MOV	MODEOR,0	; 0=normal
	CALL	VTXPRA		; vram text print all mode.
	RET
VTXPRN	ENDP


; vram text print OR.
; -i- DS:SI   : string. (null=end of string)
;     AX      : location x point.
;     BX      : location y point.

VTXPOR	PROC	NEAR
	MOV	MODEOR,1	; 1=OR font mode.
	CALL	VTXPRA		; vram text print all mode.
	RET
VTXPOR	ENDP


; vram text print fuchi.
; -i- DS:SI   : string. (null=end of string)
;     AX      : location x point.
;     BX      : location y point.

VTXPFC	PROC	NEAR
	MOV	MODEOR,2	; 2=fuchi font mode.
	CALL	VTXPRA		; vram text print all mode.
	RET
VTXPFC	ENDP


; vram text print all mode.
; -i- DS:SI   : string. (null=end of string)
;     AX      : location x point.
;     BX      : location y point.
;     MODEOR  : 0=normal,1=OR font mode,2=fuchi font mode.

VTXPRA	PROC	NEAR
	MOV	TEXTX,AX
	MOV	PNTX,AX
	MOV	TEXTY,BX
VTXPRA0:
	LODSB
	CMP	AL,020H		; if end_of_string then exit.
	JNB	VTXPRA00	;
	JMP	VTXPRA9		;
VTXPRA00:
	CMP	AL,'@'
	JNZ	VTXPRA01
	MOV	BX,PNTX
	MOV	TEXTX,BX
	MOV	CX,FNTSZJISY	; jis font size y.
	ADD	WORD PTR TEXTY,CX
	JMP	VTXPRA0
VTXPRA01:
	CMP	AL,07FH		;
	JB	VTXPRA1		; if al < 7fh then ank.
	CMP	AL,0A0H		;
	JB	VTXPRA2		; if al < a0h then jis.
	CMP	AL,0E0H		;
	JB	VTXPRA1		; if al < e0h then ank.
	JMP	VTXPRA2		;
VTXPRA1:
	MOV	VTXJCD,0	; <<ank set>>
	MOV	BYTE PTR VTXJCD,AL ; talk jis code.
	MOV	DH,80H		; ank character.
	MOV	DL,AL		;
	JMP	VTXPRA3		;
VTXPRA2:
	MOV	AH,AL		; <<kanji set>>
	LODSB			;
	MOV	VTXJCD,AX	; talk jis code.
	CALL	SHFJIS		; shift jis -> jis code.
VTXPRA3:
;*;	CALL	VTXPACX		; ｸﾁﾊﾟｸ put call.(public routine)

	CALL	SIZFNT		; get size.
	CALL	GETFNT		; get font.
	CALL	PTNNOT		; pattern not.

	CMP	MODEOR,1	; 1=OR font mode.
	JE	VTXPRA_OR	;
	CMP	MODEOR,2	; 2=fuchi font mode.
	JE	VTXPRA_FCH	;
VTXPRA_NORMAL:
	CMP	FONTSW,0	; character size 0=16x16
	JNE	VTXPRA_NOR2	;
	CALL	PTSTHC		; pattern thick small.-------
VTXPRA_NOR2:			;
	CALL	MULFNT		; font nulti.
	CALL	CHRBOX		; white char box.
	CALL	PUTPTN		; put pattern.
	JMP	VTXPRA_NEXT
VTXPRA_OR:
	CMP	FONTSW,0	; character size 0=16x16
	JNE	VTXPRA_OR2	;
	CALL	PTSTHC		; pattern thick small.-------
VTXPRA_OR2:
	CALL	MULFNT		; font nulti.
	CALL	PTRPTN		; OR put pattern.
	JMP	VTXPRA_NEXT
VTXPRA_FCH:
	PUSH	FONTCOL		; font color.
	MOV	FONTCOL,0	; font color.

	INC	FNTSZANKY	; ank font size y.
	INC	FNTSZANKY	; ank font size y.
	INC	FNTSZJISY	; jis font size y.
	INC	FNTSZJISY	; jis font size y.

;;;	CALL	PTSTHC		; pattern thick small.-------
	CALL	PTNTHC		; pattern thick.
	CALL	MULFNT		; font nulti.
	CALL	PTRPTN		; OR put pattern.

	DEC	FNTSZANKY	; ank font size y.
	DEC	FNTSZANKY	; ank font size y.
	DEC	FNTSZJISY	; jis font size y.
	DEC	FNTSZJISY	; jis font size y.

	POP	FONTCOL		; font color.

	CALL	GETFNT		; get font.
	CALL	PTNNOT		; pattern not.
;;;	CALL	PTSTHC		; pattern thick small.
	CALL	MULFNT		; font nulti.
	CALL	PTRPTN		; OR put pattern.
VTXPRA_NEXT:
	MOV	AX,LENX		;
	ADD	TEXTX,AX	;
	JMP	VTXPRA0		;

VTXPRA9:
;*;	CALL	VTXENDX		; ｸﾁﾊﾟｸ ｵﾜﾘ call.(public routine)
	RET
	
VTXPRA	ENDP


;*;;	ｸﾁﾊﾟｸ put call.(public routine)
;*;
;*;VTXPACX	PROC	NEAR
;*;	PUSH	AX
;*;	PUSH	BX
;*;	PUSH	CX
;*;	PUSH	DX
;*;	PUSH	DI
;*;	PUSH	SI
;*;	PUSH	BP
;*;	PUSH	ES
;*;	PUSH	DS
;*;	CALL	VTXPAC		; ｸﾁﾊﾟｸ put call.(public routine)
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
;*;VTXPACX	ENDP
;*;
;*;
;*;;	ｸﾁﾊﾟｸ ｵﾜﾘ call.(public routine)
;*;
;*;VTXENDX	PROC	NEAR
;*;	PUSH	AX
;*;	PUSH	BX
;*;	PUSH	CX
;*;	PUSH	DX
;*;	PUSH	DI
;*;	PUSH	SI
;*;	PUSH	BP
;*;	PUSH	ES
;*;	PUSH	DS
;*;	CALL	VTXEND		; ｸﾁﾊﾟｸ ｵﾜﾘ call.(public routine)
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
;*;VTXENDX	ENDP



; character size set.
; -I- AX : 0=16x16  1=32x32  2=16x24  3=16x32

VTXSIZ	PROC	NEAR
	PUSH	AX

	CMP	AX,0	; 16 x 16
	JE	VTXSIZ_16
	CMP	AX,1	; 32 x 32
	JE	VTXSIZ_32
	CMP	AX,2	; 16 x 24
	JNE	VTXSIZ2
	JMP	VTXSIZ_24H
VTXSIZ2:
	CMP	AX,3	; 16 x 32
	JNE	VTXSIZ3
	JMP	VTXSIZ_32H
VTXSIZ3:
	JMP	VTXSIZ_EXIT
VTXSIZ_16:

; CRT axis.
	MOV	SIZEXANK,1	; ank x size.
	MOV	SIZEYANK,16	; ank y size.
	MOV	SIZEXJIS,2	; jis x size.
	MOV	SIZEYJIS,16	; jis y size.

; BYTE axis.
	MOV	FNTSZANKX,1	; ank font size x.
	MOV	FNTSZANKY,16	; ank font size y.
	MOV	FNTSZJISX,2	; jis font size x.
	MOV	FNTSZJISY,16	; jis font size y.

	MOV	AX,SEGVTW	; visual data plean width.
	DEC	AX		;
	MOV	ADDWIDTHANK,AX	; ank vram address add.
	DEC	AX		;
	MOV	ADDWIDTHJIS,AX	; jis vram address add.

	MOV	FONTSW,0	; character size 0=16x16,1=32x32

	JMP	VTXSIZ_EXIT
VTXSIZ_32:

; DOT axis.
	MOV	SIZEXANK,1*2	; ank x size.
	MOV	SIZEYANK,16*2	; ank y size.
	MOV	SIZEXJIS,2*2	; jis x size.
	MOV	SIZEYJIS,16*2	; jis y size.

; BYTE axis.
	MOV	FNTSZANKX,1*2	; ank font size x.
	MOV	FNTSZANKY,16*2	; ank font size y.
	MOV	FNTSZJISX,2*2	; jis font size x.
	MOV	FNTSZJISY,16*2	; jis font size y.

	MOV	AX,SEGVTW	; visual data plean width.
	SUB	AX,2		;
	MOV	ADDWIDTHANK,AX	; ank vram address add.
	SUB	AX,2		;
	MOV	ADDWIDTHJIS,AX	; jis vram address add.

	MOV	FONTSW,1	; character size 0=16x16,1=32x32

	JMP	VTXSIZ_EXIT

VTXSIZ_24H:

; DOT axis.
	MOV	SIZEXANK,1	; ank x size.
	MOV	SIZEYANK,24	; ank y size.
	MOV	SIZEXJIS,2	; jis x size.
	MOV	SIZEYJIS,24	; jis y size.

; BYTE axis.
	MOV	FNTSZANKX,1	; ank font size x.
	MOV	FNTSZANKY,24	; ank font size y.
	MOV	FNTSZJISX,2	; jis font size x.
	MOV	FNTSZJISY,24	; jis font size y.

	MOV	AX,SEGVTW	; visual data plean width.
	DEC	AX		;
	MOV	ADDWIDTHANK,AX	; ank vram address add.
	DEC	AX		;
	MOV	ADDWIDTHJIS,AX	; jis vram address add.

	MOV	FONTSW,2	; character size 2=16x24

	JMP	VTXSIZ_EXIT

VTXSIZ_32H:

; DOT axis.
	MOV	SIZEXANK,1	; ank x size.
	MOV	SIZEYANK,32	; ank y size.
	MOV	SIZEXJIS,2	; jis x size.
	MOV	SIZEYJIS,32	; jis y size.

; BYTE axis.
	MOV	FNTSZANKX,1	; ank font size x.
	MOV	FNTSZANKY,32	; ank font size y.
	MOV	FNTSZJISX,2	; jis font size x.
	MOV	FNTSZJISY,32	; jis font size y.

	MOV	AX,SEGVTW	; visual data plean width.
	DEC	AX		;
	MOV	ADDWIDTHANK,AX	; ank vram address add.
	DEC	AX		;
	MOV	ADDWIDTHJIS,AX	; jis vram address add.

	MOV	FONTSW,3	; character size 3=16x32

VTXSIZ_EXIT:
	POP	AX
	RET
VTXSIZ	ENDP


; character color set.
; -I- AX : character color 0-15

VTXCOL	PROC	NEAR
	MOV	FONTCOL,AX		; font color.
	RET
VTXCOL	ENDP




; font nulti.
; -I- PUTBUF : pattern buffer.
;     DX     : jis code.
; -O- PUTFNT : vram put buffer.

MULFNT	PROC	NEAR
	PUSH	AX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	ES

	MOV	AX,DS
	MOV	ES,AX

	CMP	FONTSW,0	; character size 0=16x16
	JNE	MULFNT2
	CALL	MULFNT_16
	JMP	MULFNT_EXIT
MULFNT2:
	CMP	FONTSW,1	; character size 1=32x32
	JNE	MULFNT3
	CALL	MULFNT_32
	JMP	MULFNT_EXIT
MULFNT3:
	CMP	FONTSW,2	; character size 2=16x24
	JNE	MULFNT4
	CALL	MULFNT_24H
	JMP	MULFNT_EXIT
MULFNT4:
	CMP	FONTSW,3	; character size 3=16x32
	JNE	MULFNT5
	CALL	MULFNT_32H	; 16x32 charracter.
	JMP	MULFNT_EXIT
MULFNT5:

MULFNT_EXIT:
	POP	ES
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	AX
	RET
MULFNT	ENDP

;	16x16 charracter.

MULFNT_16	PROC	NEAR
	MOV	DI,OFFSET PUTFNT	; vram put buffer.
	MOV	SI,OFFSET PUTBUF	; pattern buffer.
	INC	SI
	INC	SI
	MOV	CX,38		;<====================
	REP	MOVSB
	RET
MULFNT_16	ENDP

;	32x32 charracter.

MULFNT_32	PROC	NEAR
	MOV	DI,OFFSET PUTFNT	; vram put buffer.
	MOV	SI,OFFSET PUTBUF	; pattern buffer.
	INC	SI
	INC	SI

	CMP	DX,08000H	;
	JB	MULFNT_32JIS	; if dx < 8000h then jis.
	JMP	MULFNT_32ANK	;  ank.

MULFNT_32JIS:
	MOV	CX,17	;<====================
MULFNT_32JIS2:
	PUSH	CX

	LODSB		; AL = bit image.
	CALL	BWSET	; byte bit image -> word bit image.
	MOV	ES:[DI][0],DH
	MOV	ES:[DI][1],DL
	MOV	ES:[DI][4],DH
	MOV	ES:[DI][5],DL

	LODSB		; AL = bit image.
	CALL	BWSET	; byte bit image -> word bit image.
	MOV	ES:[DI][2],DH
	MOV	ES:[DI][3],DL
	MOV	ES:[DI][6],DH
	MOV	ES:[DI][7],DL

	ADD	DI,8

	POP	CX
	LOOP	MULFNT_32JIS2

	JMP	MULFNT_32EXIT

MULFNT_32ANK:
	MOV	CX,17	;<====================
MULFNT_32ANK5:
	PUSH	CX

	LODSB		; AL = bit image.
	CALL	BWSET	; byte bit image -> word bit image.
	MOV	ES:[DI][0],DH
	MOV	ES:[DI][1],DL
	MOV	ES:[DI][2],DH
	MOV	ES:[DI][3],DL

	ADD	DI,4

	POP	CX
	LOOP	MULFNT_32ANK5

MULFNT_32EXIT:
	RET
MULFNT_32	ENDP


;	16x24 charracter.

MULFNT_24H	PROC	NEAR
	MOV	DI,OFFSET PUTFNT	; vram put buffer.
	MOV	SI,OFFSET PUTBUF	; pattern buffer.
	INC	SI
	INC	SI
	CMP	DX,08000H	;
	JB	MULFNT_24HJIS	; if dx < 8000h then jis.
	JMP	MULFNT_24HANK	;  ank.

MULFNT_24HJIS:		; jis.
	MOV	CX,8
MULFNT_24HJIS_2:
	LODSW		;
	STOSW		; 2 line -> 3 line expand.
	MOV	ES:[DI],AX
	LODSW		;
	AND	ES:[DI],AX
	INC	DI	;
	INC	DI	;
	STOSW		;
	LOOP	MULFNT_24HJIS_2

	MOV	AX,0FFFFH
	STOSW		;
	MOV	AX,0FFFFH
	STOSW		;
	RET

MULFNT_24HANK:		; ank.
	MOV	CX,8
MULFNT_24HANK_2:
	LODSB		;
	STOSB		; 2 line -> 3 line expand.
	MOV	ES:[DI],AL
	LODSB		;
	AND	ES:[DI],AL
	INC	DI	;
	STOSB		;
	LOOP	MULFNT_24HANK_2

	MOV	AL,0FFH	;
	STOSB		;
	MOV	AL,0FFH	;
	STOSB		;
	RET
MULFNT_24H	ENDP


;	16x32 charracter.

MULFNT_32H	PROC	NEAR
	MOV	DI,OFFSET PUTFNT	; vram put buffer.
	MOV	SI,OFFSET PUTBUF	; pattern buffer.
	INC	SI
	INC	SI
	CMP	DX,08000H	;
	JB	MULFNT_32HJIS	; if dx < 8000h then jis.
	JMP	MULFNT_32HANK	;  ank.

MULFNT_32HJIS:		; jis.
	MOV	CX,17	;<====================
MULFNT_32HJIS_2:
	LODSW	;
	STOSW	;
	STOSW	;
	LOOP	MULFNT_32HJIS_2

	RET

MULFNT_32HANK:		; ank.
	MOV	CX,17	;<====================
MULFNT_32HANK_2:
	LODSB	;
	STOSB	;
	STOSB	;
	LOOP	MULFNT_32HANK_2

	RET
MULFNT_32H	ENDP


; byte bit image -> word bit image.
; -I- AL    : byte bit image.
; -O- DX    : word bit image.

BWSET	PROC	NEAR
	MOV	DX,0
	MOV	BX,1100000000000000B
	MOV	CX,8
BWSET1:
	SHL	AL,1
	JNB	BWSET2
	OR	DX,BX
BWSET2:
	SHR	BX,1
	SHR	BX,1
	LOOP	BWSET1

	RET
BWSET	ENDP



; white char box.
; -I- DX : jis code.
;     TEXTX : location x.
;     TEXTY : location y.

CHRBOX	PROC	NEAR
	CMP	DX,08000H	;
	JB	CHRBOX_JIS	; if dx < 8000h then jis.
	JMP	CHRBOX_ANK	;  ank.
CHRBOX_JIS:
	MOV	AX,TEXTX	;
	MOV	FX1,AX		;
	MOV	AX,TEXTY	;
	MOV	FY1,AX		;

	MOV	AX,SIZEXJIS	; jis X size.
	ADD	AX,FX1		;
	DEC	AX		;
	MOV	FX2,AX		;

	MOV	AX,SIZEYJIS	; jis Y size.
	ADD	AX,FY1		;
	DEC	AX		;
	MOV	FY2,AX		;

	CALL	FUKPAI		;

	RET
CHRBOX_ANK:
	MOV	AX,TEXTX	;
	MOV	FX1,AX		;
	MOV	AX,TEXTY	;
	MOV	FY1,AX		;

	MOV	AX,SIZEXANK	; ank X size.
	ADD	AX,FX1		;
	DEC	AX		;
	MOV	FX2,AX		;

	MOV	AX,SIZEYANK	; ank Y size.
	ADD	AX,FY1		;
	DEC	AX		;
	MOV	FY2,AX		;

	CALL	FUKPAI		;

	RET
CHRBOX	ENDP


; box paint.
; -i- FX1,FY1 : start point.
;     FX2,FY2 : end point.

FUKPAI	PROC	NEAR
	PUSH	DX

	MOV	AX,FY1			;
	MOV	BX,SEGVTW		; visual data plean width.
	MUL	BX			;
	MOV	DI,AX			;

	MOV	AX,FX1			;
;*BYTE*	SHR	AX,1			;
;*BYTE*	SHR	AX,1			;
;*BYTE*	SHR	AX,1			; ax = fx1 / 8

	ADD	DI,AX			; di = di + ax
	MOV	DX,DI			; dx = di

	MOV	CX,FY2			;
	SUB	CX,FY1			;
	INC	CX			; cx = fy2 - fy1 + 1

	MOV	BX,FX2			;
;*BYTE*	SHR	BX,1			;
;*BYTE*	SHR	BX,1			;
;*BYTE*	SHR	BX,1			;
	MOV	AX,FX1			;
;*BYTE*	SHR	AX,1			;
;*BYTE*	SHR	AX,1			;
;*BYTE*	SHR	AX,1			;
	SUB	BX,AX			;
	INC	BX			; bx  = fx2/8 - fx1/8 + 1
FUKPAI1:PUSH	CX
	MOV	DI,DX
	MOV	AX,SEGVT0
	MOV	ES,AX
	CALL	C1VV_BANK_XCG_ES	; vram bank check & chenge.
	MOV	CX,BX
	MOV	AL,0FFH
	REP	STOSB

	MOV	DI,DX
	MOV	AX,SEGVT1
	MOV	ES,AX
	CALL	C1VV_BANK_XCG_ES	; vram bank check & chenge.
	MOV	CX,BX
	MOV	AL,0FFH
	REP	STOSB

	MOV	DI,DX
	MOV	AX,SEGVT2
	MOV	ES,AX
	CALL	C1VV_BANK_XCG_ES	; vram bank check & chenge.
	MOV	CX,BX
	MOV	AL,0FFH
	REP	STOSB

	MOV	DI,DX
	MOV	AX,SEGVT3
	MOV	ES,AX
	CALL	C1VV_BANK_XCG_ES	; vram bank check & chenge.
	MOV	CX,BX
	MOV	AL,0FFH
	REP	STOSB

	ADD	DX,SEGVTW		; visual data plean width.
	POP	CX
	LOOP	FUKPAI1

	POP	DX

	RET
FUKPAI	ENDP



; put pattern.
; -i- TEXTX : location x.
;     TEXTY : location y.
;     PUTFNT: vram put buffer.
;     DX    : jis code.

PUTPTN	PROC	NEAR
	PUSH	DX
	PUSH	SI

	MOV	CX,DX			;
	MOV	AX,TEXTY		;
	MOV	BX,SEGVTW		; visual data plean width.
	MUL	BX			;
	MOV	DI,AX			;
	MOV	DX,CX			;

	MOV	AX,TEXTX		;
;*BYTE*	SHR	AX,1			;
;*BYTE*	SHR	AX,1			;
;*BYTE*	SHR	AX,1			; ax = textx / 8

	ADD	DI,AX			; di = di + ax

	MOV	BX,DI			;

	CMP	DX,020H		; if end_of_string then exit.
	JNB	PUTPTN01	;
	JMP	PUTPTN3		;
PUTPTN01:			;
	CMP	DX,08000H	;
	JNB	PUTPTN2		; if dx < 8000h then jis.

	MOV	BP,FONTCOL		; font color.

	SHR	BP,1			;
	JB	PUTPTN11		;
	MOV	BX,DI			;
	MOV	AX,SEGVT0		;
	MOV	VRMSEG,AX		;
	CALL	PUTPTNSET		;
PUTPTN11:				;
	SHR	BP,1			;
	JB	PUTPTN12		;
	MOV	DI,BX			;
	MOV	AX,SEGVT1		;
	MOV	VRMSEG,AX		;
	CALL	PUTPTNSET		;
PUTPTN12:				;
	SHR	BP,1			;
	JB	PUTPTN13		;
	MOV	DI,BX			;
	MOV	AX,SEGVT2		;
	MOV	VRMSEG,AX		;
	CALL	PUTPTNSET		;
PUTPTN13:				;
	SHR	BP,1			;
	JB	PUTPTN14		;
	MOV	DI,BX			;
	MOV	AX,SEGVT3		;
	MOV	VRMSEG,AX		;
	CALL	PUTPTNSET		;
PUTPTN14:				;
	JMP	PUTPTN3			;

PUTPTN2:
	MOV	BP,FONTCOL		; font color.

	SHR	BP,1			;
	JB	PUTPTN21		;
	MOV	AX,SEGVT0		;
	MOV	VRMSEG,AX		;
	CALL	PUTPTNH			;
PUTPTN21:				;
	SHR	BP,1			;
	JB	PUTPTN22		;
	MOV	DI,BX			;
	MOV	AX,SEGVT1		;
	MOV	VRMSEG,AX		;
	CALL	PUTPTNH			;
PUTPTN22:				;
	SHR	BP,1			;
	JB	PUTPTN23		;
	MOV	DI,BX			;
	MOV	AX,SEGVT2		;
	MOV	VRMSEG,AX		;
	CALL	PUTPTNH			;
PUTPTN23:				;
	SHR	BP,1			;
	JB	PUTPTN24		;
	MOV	DI,BX			;
	MOV	AX,SEGVT3		;
	MOV	VRMSEG,AX		;
	CALL	PUTPTNH			;
PUTPTN24:

PUTPTN3:
	POP	SI
	POP	DX

	RET

PUTPTNSET:
	MOV	SI,OFFSET PUTFNT	; vram put buffer.
	MOV	AX,VRMSEG		;
	MOV	ES,AX			;
	CALL	C1VV_BANK_XCG_ES	; vram bank check & chenge.
	MOV	CX,FNTSZJISY		; jis font size y.
PUTPTNSET2:				;
	PUSH	CX			;
	MOV	CX,FNTSZJISX		; jis font size x.
	REP	MOVSB			;
	POP	CX			;
	ADD	DI,ADDWIDTHJIS		; jis vram address add.
	LOOP	PUTPTNSET2		;
	RET


PUTPTNH:
	MOV	SI,OFFSET PUTFNT	; vram put buffer.
	MOV	AX,VRMSEG		;
	MOV	ES,AX			;
	CALL	C1VV_BANK_XCG_ES	; vram bank check & chenge.
	MOV	CX,FNTSZANKY		; ank font size y.
PUTPTNH2:				;
	PUSH	CX			;
	MOV	CX,FNTSZANKX		; ank font size x.
	REP	MOVSB			;
	POP	CX			;
	ADD	DI,ADDWIDTHANK		; ank vram address add.
	LOOP	PUTPTNH2		;
	RET
PUTPTN	ENDP



; OR put pattern.
; -i- TEXTX : location x.
;     TEXTY : location y.
;     PUTFNT: vram put buffer.
;     DX    : jis code.

PTRPTN	PROC	NEAR
	PUSH	DX
	PUSH	SI

	MOV	CX,DX			;
	MOV	AX,TEXTY		;
	MOV	BX,SEGVTW		; visual data plean width.
	MUL	BX			;
	MOV	DI,AX			;
	MOV	DX,CX			;

	MOV	AX,TEXTX		;
;*BYTE*	SHR	AX,1			;
;*BYTE*	SHR	AX,1			;
;*BYTE*	SHR	AX,1			; ax = textx / 8

	ADD	DI,AX			; di = di + ax

	MOV	BX,DI			;

	CMP	DX,020H		; if end_of_string then exit.
	JNB	PTRPTN01	;
	JMP	PTRPTN3		;
PTRPTN01:			;
	CMP	DX,08000H	;
	JNB	PTRPTN2		; if dx < 8000h then jis.

	MOV	BP,FONTCOL		; font color.

	MOV	BX,DI			;
	MOV	AX,SEGVT0		;
	MOV	VRMSEG,AX		;
	SHR	BP,1			;
	JB	PTRPTN11		;
	CALL	PTRPTNSET		;
	JMP	PTRPTN111		;
PTRPTN11:				;
	CALL	PTRPTNOR		;
PTRPTN111:				;
	MOV	DI,BX			;
	MOV	AX,SEGVT1		;
	MOV	VRMSEG,AX		;
	SHR	BP,1			;
	JB	PTRPTN12		;
	CALL	PTRPTNSET		;
	JMP	PTRPTN121		;
PTRPTN12:				;
	CALL	PTRPTNOR		;
PTRPTN121:				;
	MOV	DI,BX			;
	MOV	AX,SEGVT2		;
	MOV	VRMSEG,AX		;
	SHR	BP,1			;
	JB	PTRPTN13		;
	CALL	PTRPTNSET		;
	JMP	PTRPTN131		;
PTRPTN13:				;
	CALL	PTRPTNOR		;
PTRPTN131:				;
	MOV	DI,BX			;
	MOV	AX,SEGVT3		;
	MOV	VRMSEG,AX		;
	SHR	BP,1			;
	JB	PTRPTN14		;
	CALL	PTRPTNSET		;
	JMP	PTRPTN141		;
PTRPTN14:				;
	CALL	PTRPTNOR		;
PTRPTN141:				;
	JMP	PTRPTN3			;

PTRPTN2:
	MOV	BP,FONTCOL		; font color.

	MOV	DI,BX			;
	MOV	AX,SEGVT0		;
	MOV	VRMSEG,AX		;
	SHR	BP,1			;
	JB	PTRPTN21		;
	CALL	PTRPTNH			;
	JMP	PTRPTN211		;
PTRPTN21:				;
	CALL	PTRPTNHOR		;
PTRPTN211:				;
	MOV	DI,BX			;
	MOV	AX,SEGVT1		;
	MOV	VRMSEG,AX		;
	SHR	BP,1			;
	JB	PTRPTN22		;
	CALL	PTRPTNH			;
	JMP	PTRPTN221		;
PTRPTN22:				;
	CALL	PTRPTNHOR		;
PTRPTN221:				;
	MOV	DI,BX			;
	MOV	AX,SEGVT2		;
	MOV	VRMSEG,AX		;
	SHR	BP,1			;
	JB	PTRPTN23		;
	CALL	PTRPTNH			;
	JMP	PTRPTN231		;
PTRPTN23:				;
	CALL	PTRPTNHOR		;
PTRPTN231:				;
	MOV	DI,BX			;
	MOV	AX,SEGVT3		;
	MOV	VRMSEG,AX		;
	SHR	BP,1			;
	JB	PTRPTN24		;
	CALL	PTRPTNH			;
	JMP	PTRPTN241		;
PTRPTN24:				;
	CALL	PTRPTNHOR		;
PTRPTN241:				;

PTRPTN3:
	POP	SI
	POP	DX

	RET

;	AND set.(ｸﾛﾇｷ)

PTRPTNSET:
	MOV	SI,OFFSET PUTFNT	; vram put buffer.
	MOV	AX,VRMSEG		;
	MOV	ES,AX			;
	CALL	C1VV_BANK_XCG_ES	; vram bank check & chenge.
	MOV	CX,FNTSZJISY		; jis font size y.
PTRPTNSET2:				;
	PUSH	CX			;
	MOV	CX,FNTSZJISX		; jis font size x.
PTRPTNSET3:				;
	LODSB				;
	MOV	DL,ES:[DI]		; for VGA
	AND	AL,DL			; AND VRAM
	STOSB				;
	LOOP	PTRPTNSET3		;

	POP	CX			;
	ADD	DI,ADDWIDTHJIS		; jis vram address add.
	LOOP	PTRPTNSET2		;
	RET

;	OR  set.(pset)

PTRPTNOR:
	MOV	SI,OFFSET PUTFNT	; vram put buffer.
	MOV	AX,VRMSEG		;
	MOV	ES,AX			;
	CALL	C1VV_BANK_XCG_ES	; vram bank check & chenge.
	MOV	CX,FNTSZJISY		; jis font size y.
PTRPTNOR2:				;
	PUSH	CX			;
	MOV	CX,FNTSZJISX		; jis font size x.
PTRPTNOR3:				;
	LODSB				;
	NOT	AL			; revirse
	MOV	DL,ES:[DI]		; for VGA
	OR	AL,DL			; OR VRAM
	STOSB				;
	LOOP	PTRPTNOR3		;

	POP	CX			;
	ADD	DI,ADDWIDTHJIS		; jis vram address add.
	LOOP	PTRPTNOR2		;
	RET

;	AND set.(ｸﾛﾇｷ) harf character.

PTRPTNH:
	MOV	SI,OFFSET PUTFNT	; vram put buffer.
	MOV	AX,VRMSEG		;
	MOV	ES,AX			;
	CALL	C1VV_BANK_XCG_ES	; vram bank check & chenge.
	MOV	CX,FNTSZANKY		; ank font size y.
PTRPTNH2:				;
	PUSH	CX			;
	MOV	CX,FNTSZANKX		; ank font size x.
PTRPTNH3:				;
	LODSB				;
	MOV	DL,ES:[DI]		; for VGA
	AND	AL,DL			; AND VRAM
	STOSB				;
	LOOP	PTRPTNH3		;

	POP	CX			;
	ADD	DI,ADDWIDTHANK		; ank vram address add.
	LOOP	PTRPTNH2		;
	RET

;	OR  set.(pset) harf character.

PTRPTNHOR:
	MOV	SI,OFFSET PUTFNT	; vram put buffer.
	MOV	AX,VRMSEG		;
	MOV	ES,AX			;
	CALL	C1VV_BANK_XCG_ES	; vram bank check & chenge.
	MOV	CX,FNTSZANKY		; ank font size y.
PTRPTNHOR2:				;
	PUSH	CX			;
	MOV	CX,FNTSZANKX		; ank font size x.
PTRPTNHOR3:				;
	LODSB				;
	NOT	AL			; revirse
	MOV	DL,ES:[DI]		; for VGA
	OR	AL,DL			; OR VRAM
	STOSB				;
	LOOP	PTRPTNHOR3		;

	POP	CX			;
	ADD	DI,ADDWIDTHANK		; ank vram address add.
	LOOP	PTRPTNHOR2		;
	RET
PTRPTN	ENDP



; shift jis -> jis code.
; -i-    AX :shift jis code.
; -i/o-  DX :jis code.

SHFJIS	PROC	NEAR
	CMP	AL,09FH		;
	JNB	SHFJIS5		; if al < 9fh then
	CMP	AH,0A0H		;
	JNB	SHFJIS2		;  if ah < a0h then
	MOV	DH,AH		;
	SUB	DH,071H		;
	SHL	DH,1		;
	INC	DH		;    dh = ( ah - 71h ) * 2 + 1
	JMP	SHFJIS3		;
SHFJIS2:			;  else
	MOV	DH,AH		;
	SUB	DH,0B1H		;
	SHL	DH,1		;
	INC	DH		;    dh = ( ah - b1h ) * 2 + 1
SHFJIS3:			;  endif
	MOV	DL,AL		;
	SUB	DL,01FH		;  dl = al - 1fh
	CMP	DL,061H		;  if dl >= 61h then
	JB	SHFJIS4		;
	DEC	DL		;    dl = dl - 1
SHFJIS4:JMP	SHFJIS8		;
SHFJIS5:			; else
	CMP	AH,0A0H		;  if ah < a0h then
	JNB	SHFJIS6		;
	MOV	DH,AH		;
	SUB	DH,070H		;
	SHL	DH,1		;    dh = ( ah - 70h ) * 2
	JMP	SHFJIS7		;
SHFJIS6:			;  else
	MOV	DH,AH		;
	SUB	DH,0B0H		;
	SHL	DH,1		;    dh = ( ah - b0h ) * 2
SHFJIS7:			;  endif
	MOV	DL,AL		;
	SUB	DL,07EH		;  dl = al - 7eh
SHFJIS8:			; endif
	RET

SHFJIS	ENDP


; get font pattern.
; -i- DX : pattern code.
; -O- PUTBUF : pattern buffer.

GETFNT	PROC	NEAR
	PUSH	DX
	PUSH	SI

	CALL	ANKHNK			; ANK code -> hankaku jis code.

	MOV	BX,SEG DATA		; patturn buffer segment.
	MOV	CX,OFFSET PUTBUF	; pattern buffer offset.

	CALL	ORGFONT			; original font get.
	CMP	AX,1			; 1=ok,0=none.
	JE	GETFNT_EXIT		;

	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	GETFNT_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	GETFNT_PC98		;
	JMP	GETFNT_SET		;
GETFNT_PCAT:
	CALL	DOSVCGRED		; DOS/V font get.
	JMP	GETFNT_SET
GETFNT_PC98:
	CALL	KCGRED			; KCG font get.
GETFNT_SET:

;*;	CMP	DX,212AH	; ！(8149h)
;*;	JNE	GETFNT_EXIT	;
;*;	CALL	FNTSFT16L	; width 16dot font left shift.
GETFNT_EXIT:
	POP	SI
	POP	DX
	RET
GETFNT	ENDP


;*;; width 16dot font left shift.
;*;; -i- BX : patturn buffer segment.
;*;;     CX : pattern buffer offset.
;*;
;*;FNTSFT16L	PROC	NEAR
;*;	PUSH	BX
;*;	PUSH	CX
;*;	PUSH	DX
;*;	MOV	ES,BX
;*;	MOV	DI,CX
;*;	MOV	DX,17
;*;	MOV	CL,4
;*;FNTSFT16L_LOOP:
;*;	ROL	WORD PTR ES:[DI],CL
;*;	AND	WORD PTR ES:[DI],000FFH
;*;	INC	DI
;*;	INC	DI
;*;	DEC	DX
;*;	JNZ	FNTSFT16L_LOOP
;*;	POP	DX
;*;	POP	CX
;*;	POP	BX
;*;	RET
;*;FNTSFT16L	ENDP


; KCG font get.
; -i- DX : pattern code.
;     BX : patturn buffer segment.
;     CX : pattern buffer offset.

KCGRED	PROC	NEAR
	PUSH	DX
	PUSH	CX
	PUSH	BX

	MOV	AL,0BH		; ﾋﾞｯﾄ ﾏｯﾌﾟ ﾎｳｼｷ SET
	OUTGDC	68H,AL		;

	MOV	AL,DL
	OUTGDC	0A1H,AL		; kanji code byte low.

	MOV	AL,DH
	SUB	AL,20H
	OUTGDC	0A3H,AL		; kanji code byte hi.

	CMP	DX,2920H	; hankaku?
	JB	KCGRED_KNJ	;
	CMP	DX,2A5FH	;
	JNB	KCGRED_KNJ	;

KCGRED_HNK:
	MOV	ES,BX		; patturn buffer segment.
	MOV	DI,CX		; pattern buffer offset.
	MOV	AL,1		; size x
	STOSB			;
	MOV	AL,2		; size y
	STOSB			;

	MOV	DL,0		; line counter.
	MOV	CX,16		;
KCGRED111:
	MOV	AL,DL		; line counter.
	OR	AL,100000B	; left side.
	OUTGDC	0A5H,AL

	IN_GDC	AL,0A9H
	STOSB

	INC	DL		; line counter.

	LOOP	KCGRED111

	JMP	KCGRED_EXIT

KCGRED_KNJ:			;
	MOV	ES,BX		; patturn buffer segment.
	MOV	DI,CX		; pattern buffer offset.
	MOV	AL,2		; size x
	STOSB			;
	MOV	AL,2		; size y
	STOSB			;

	MOV	DL,0		; line counter.
	MOV	CX,16		;
KCGRED222:			;
	MOV	AL,DL		; line counter.
	OR	AL,100000B	; left side.
	OUTGDC	0A5H,AL		;

	IN_GDC	AL,0A9H		;
	STOSB			;

	MOV	AL,DL		; line counter.
	OUTGDC	0A5H,AL		; right side.

	IN_GDC	AL,0A9H		;
	STOSB			;

	INC	DL		; line counter.
	LOOP	KCGRED222	;

	MOV	AL,0		;
	STOSB			;
	STOSB			;
KCGRED_EXIT:
	MOV	AL,0AH		; ｺｰﾄﾞｱｸｾｽ ﾎｳｼｷ SET
	OUTGDC	68H,AL		;

	POP	BX
	POP	CX
	POP	DX
	RET
KCGRED	ENDP


; DOS/V font get.
; -i- DX : pattern code.
;     BX : patturn buffer segment.
;     CX : pattern buffer offset.
;     VTXJCD : shift jis code.

DOSVCGRED	PROC	NEAR
	PUSH	ES
	PUSH	DI
	PUSH	DX

	MOV	ES,BX			; patturn buffer segment.
	MOV	DI,CX			; pattern buffer offset.

	CMP	DX,2920H		; zenkaku ?
	JB	DOSVCGRED_16WD		;
	CMP	DX,2A5FH		;
	JNB	DOSVCGRED_16WD		;

DOSVCGRED_8WD:
	MOV	AL,1			; size x
	STOSB				;
	MOV	AL,2			; size y
	STOSB				;

	MOV	DX,VTXJCD		; shift jis code.
	MOV	DH,0			;
	CALL	C1GETFONT			; get text font.
	JMP	DOSVCGRED_EXIT		;

DOSVCGRED_16WD:
	MOV	AL,2			; size x
	STOSB				;
	MOV	AL,2			; size y
	STOSB				;

	MOV	DX,VTXJCD		; shift jis code.
	CALL	C1GETFONTZ		; get zenkaku text font.

DOSVCGRED_EXIT:
	POP	DX
	POP	DI
	POP	ES
	RET
DOSVCGRED	ENDP


; original font get.
; -i- VTXJCD : shift jis code.
;     BX : patturn buffer segment.
;     CX : pattern buffer offset.
; -o- AX : 1=ok,0=none.

ORGFONT	PROC	NEAR

	CMP	VTXJCD,8175H		; 8175h "「"
	JE	ORGFONT_J8175H		;
	CMP	VTXJCD,8176H		; 8176h "」"
	JE	ORGFONT_J8176H		;

	JMP	ORGFONT_NONE

ORGFONT_J8175H:
	MOV	AX,OFFSET J8175H
	JMP	ORGFONT_GET
ORGFONT_J8176H:
	MOV	AX,OFFSET J8176H
	JMP	ORGFONT_GET

ORGFONT_GET:
	PUSH	ES
	PUSH	DI
	PUSH	SI
	PUSH	CX

	MOV	SI,AX			;
	MOV	ES,BX			; patturn buffer segment.
	MOV	DI,CX			; pattern buffer offset.
	MOV	CX,17			;
	REP	MOVSW			;
	MOV	AX,0
	STOSW				;
	STOSW				;

	POP	CX
	POP	SI
	POP	DI
	POP	ES

	MOV	AX,1			; 1=ok
	RET
ORGFONT_NONE:
	MOV	AX,0			; 0=none.
	RET
ORGFONT	ENDP


; ANK code -> hankaku jis code.
; -i/o- DX : jis code

ANKHNK	PROC	NEAR
	CMP	DX,8000H	; ank character.
	JNBE	ANKHNK5		;

	CMP	DX,020H		; if end_of_string then exit.
	JB	ANKHNK9		;

	CMP	DX,0FFH		; if dx <= FFh then ank code.
	JNBE	ANKHNK9		;
ANKHNK5:			;
	CMP	DL,80H		;
	JNB	ANKHNK6		; upper ANK character.
	MOV	DH,0		;
	ADD	DX,2900H	; ANK code -> hankaku jis code.
	JMP	ANKHNK9		; exit.
ANKHNK6:
	MOV	DH,0		;
	ADD	DX,2980H	; upper ANK code -> hankaku jis code.
ANKHNK9:
	RET
ANKHNK	ENDP



; font pattern size.
; -i- DX   : pattern code.
; -O- LENX : text x length.
;     LENY : text y length.

SIZFNT	PROC	NEAR
	PUSH	AX

	CMP	DX,020H		; if end_of_string then exit.
	JB	SIZFNT3		;

	CMP	DX,0FFH		; if dx <= FFh then ank code.
	JBE	SIZFNT1		;

	CMP	DX,2920H	; if dx < 2920h then jis code.
	JB	SIZFNT2		;

	CMP	DX,2C00H	; if dx < 2C00h then 'hankaku' jis code.
	JB	SIZFNT1		;

	CMP	DX,08000H	;
	JB	SIZFNT2		; if dx < 8000h then jis.
SIZFNT1:
	MOV	AX,SIZEXANK
	MOV	LENX,AX
	MOV	AX,SIZEYANK
	MOV	LENY,AX
	JMP	SIZFNT9
SIZFNT2:
	MOV	AX,SIZEXJIS
	MOV	LENX,AX
	MOV	AX,SIZEYJIS
	MOV	LENY,AX
	JMP	SIZFNT9
SIZFNT3:
	MOV	LENX,0
	MOV	LENY,0
	JMP	SIZFNT9
SIZFNT9:
	POP	AX
	RET
SIZFNT	ENDP


; pattern not.
; -I/O- PUTBUF : chara font buffer.

PTNNOT	PROC	NEAR
	MOV	BX,OFFSET PUTBUF
	INC	BX
	INC	BX
	MOV	CX,38			; <===============
PTNNOT1:
	NOT	BYTE PTR DS:[BX]
	INC	BX
	LOOP	PTNNOT1
	RET
PTNNOT	ENDP



; pattern thick small.
; -i-   DX     : pattern code.
; -I/O- PUTBUF : chara font buffer.

PTSTHC	PROC	NEAR
	CMP	DX,08000H	;
	JNB	PTSTHC2		; if dx < 8000h then jis.
	CALL	PTS16T		; pattern thick small.16dot
	RET
PTSTHC2:			; harf char.
	CALL	PTS8T		; pattern thick small.8dot
	RET
PTSTHC	ENDP



; pattern thick small.8dot
; -I/O- PUTBUF : chara font buffer.

PTS8T	PROC	NEAR
	PUSH	DX
	PUSH	SI

	MOV	BX,OFFSET PUTBUF
	INC	BX
	INC	BX
	MOV	CX,16
PTS8T1:
	MOV	AH,0FFH		;
	MOV	AL,DS:[BX]	;
	MOV	DI,AX			; left.

	STC				;
	RCL	AX,1			; left shift << AX
	AND	AX,DI			; left.

	MOV	DS:[BX],AL	; left.

	INC	BX
	LOOP	PTS8T1

	POP	SI
	POP	DX
	RET
PTS8T	ENDP


; pattern thick small.16dot
; -I/O- PUTBUF : chara font buffer.

PTS16T	PROC	NEAR
	PUSH	DX
	PUSH	SI

	MOV	BX,OFFSET PUTBUF
	INC	BX
	INC	BX
	MOV	CX,16
PTS16T1:
	MOV	AH,DS:[BX]	; left.
	MOV	AL,DS:[BX][1]	;
	MOV	DI,AX			; left.

	STC				;
	RCL	AX,1			; left shift << BP:AX

	AND	AX,DI			; left.

	MOV	DS:[BX],AH	; left.
	MOV	DS:[BX][1],AL	;

	INC	BX
	INC	BX
	LOOP	PTS16T1

	POP	SI
	POP	DX
	RET
PTS16T	ENDP



; pattern thick.
; -i-   DX     : pattern code.
; -I/O- PUTBUF : chara font buffer.

PTNTHC	PROC	NEAR
	CMP	DX,08000H	;
	JNB	PTNTHC2		; if dx < 8000h then jis.
	CALL	PTN16T		; pattern thick.16dot
	RET
PTNTHC2:			; harf char.
	CALL	PTN8T		; pattern thick.8dot
	RET
PTNTHC	ENDP



; pattern thick.8dot
; -I/O- PUTBUF : chara font buffer.

PTN8T	PROC	NEAR
	PUSH	DX
	PUSH	SI

	MOV	BX,OFFSET PUTBUF
	INC	BX
	INC	BX
	MOV	CX,16
PTN8T1:
	MOV	AH,0FFH		;
	MOV	AL,DS:[BX]	;
	MOV	DI,AX			; left.

	STC				;
	RCL	AX,1			; left shift << AX
	AND	DI,AX			; left.

	RCR	AX,1			; right shift 2  >> AX
	RCR	AX,1			;
	AND	AX,DI			; left.

	MOV	DS:[BX],AL	; left.

	INC	BX
	LOOP	PTN8T1

	MOV	AX,DS			;
	MOV	ES,AX			;
	MOV	DI,OFFSET WRKBUF	; work buffer.
	MOV	CX,40/2			; <==========
	MOV	AX,0FFFFH		;
	REP	STOSW			; bit full set.

	MOV	DI,OFFSET WRKBUF	; work buffer.
	INC	DI			; +1
	MOV	BX,OFFSET PUTBUF
	INC	BX
	INC	BX
	MOV	CX,16
PTN8T5:
	MOV	AL,DS:[BX]	;

	AND	DS:[DI][-1],AL
	AND	DS:[DI],AL
	AND	DS:[DI][1],AL

	INC	DI
	INC	BX
	LOOP	PTN8T5

	MOV	DI,(OFFSET PUTBUF)+2	; chara font buffer.
	MOV	SI,(OFFSET WRKBUF)+1	; work buffer.
	MOV	CX,17+1			; <=========
	REP	MOVSB			; copy

	POP	SI
	POP	DX
	RET
PTN8T	ENDP


; pattern thick.16dot
; -I/O- PUTBUF : chara font buffer.

PTN16T	PROC	NEAR
	PUSH	DX
	PUSH	SI

	MOV	BX,OFFSET PUTBUF
	INC	BX
	INC	BX
	MOV	CX,16
PTN16T1:
	MOV	AH,DS:[BX]	; left.
	MOV	AL,DS:[BX][1]	;
	MOV	DI,AX			; left.

	STC				;
	RCL	AX,1			; left shift << BP:AX
	RCL	BP,1			;
	AND	BP,1B			;

	AND	DI,AX			; left.

	RCR	BP,1			;
	RCR	AX,1			; right shift 2  >> BP:AX
	STC				;
	RCR	AX,1			;

	AND	AX,DI			; left.

	MOV	DS:[BX],AH	; left.
	MOV	DS:[BX][1],AL	;

	INC	BX
	INC	BX
	LOOP	PTN16T1


	MOV	AX,DS			;
	MOV	ES,AX			;
	MOV	DI,OFFSET WRKBUF	; work buffer.
	MOV	CX,40/2			; <==========
	MOV	AX,0FFFFH		;
	REP	STOSW			; bit full set.

	MOV	DI,OFFSET WRKBUF	; work buffer.
	INC	DI			;
	INC	DI			; +2
	MOV	BX,OFFSET PUTBUF
	INC	BX
	INC	BX
	MOV	CX,16
PTN16T5:
	MOV	AX,DS:[BX]		;

	AND	DS:[DI][-2],AX
	AND	DS:[DI],AX
	AND	DS:[DI][2],AX

	INC	DI
	INC	DI
	INC	BX
	INC	BX
	LOOP	PTN16T5

	MOV	DI,(OFFSET PUTBUF)+2	; chara font buffer.
	MOV	SI,(OFFSET WRKBUF)+2	; work buffer.
	MOV	CX,18			; <===========
	REP	MOVSW			; copy.

	POP	SI
	POP	DX
	RET
PTN16T	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	VTXJCD		; talk jis code.

EXTRN	SEGVT0:WORD		; visual data segment plean 0
EXTRN	SEGVT1:WORD		; visual data segment plean 1
EXTRN	SEGVT2:WORD		; visual data segment plean 2
EXTRN	SEGVT3:WORD		; visual data segment plean 3
EXTRN	SEGVTW:WORD		; visual data plean width.

VTXJCD	DW	0		; talk jis code.

MODEOR	DW	0		; 0=normal,1=OR font mode,2=fuchi font mode.

VRMSEG	DW	0		; vram segment.

PNTX	DW	0		; point x.
PNTY	DW	0		; point y.
PNTX2	DW	0		; point x.
PNTY2	DW	0		; point y.

FX1	DW	0		; fukidashi x1.
FY1	DW	0		; fukidashi y1.
FX2	DW	0		; fukidashi x2.
FY2	DW	0		; fukidashi y2.

PUTBUF	DB	40+2 DUP (0)	; pattern buffer.

WRKBUF	DB	40+8 DUP (0)	; work buffer.

PUTFNT	DB	34*4 DUP (0)	; vram put buffer.

TEXTX	DW	0		; text x point.
TEXTY	DW	0		; text y point.

LENX	DW	0		; text x length.
LENY	DW	0		; text y length.

FONTSW	DW	1		; character size 0=16x16,1=32x32
				;                2=16x24,3=16x32

FONTCOL	DW	0		; font color.

; CRT axis.
SIZEXANK	DW	1*2	; ank x size.
SIZEYANK	DW	16*2	; ank y size.
SIZEXJIS	DW	2*2	; jis x size.
SIZEYJIS	DW	16*2	; jis y size.

; BYTE axis.
FNTSZANKX	DW	1*2	; ank font size x.
FNTSZANKY	DW	16*2	; ank font size y.
FNTSZJISX	DW	2*2	; jis font size x.
FNTSZJISY	DW	16*2	; jis font size y.

ADDWIDTHJIS	DW	76	; jis vram address add.
ADDWIDTHANK	DW	78	; ank vram address add.


J8175H	LABEL	BYTE		; 8175h "「"
	DB	0,0
	DB	00000000B,01111111B;0
	DB	00000000B,01100000B;1
	DB	00000000B,01000000B;2
	DB	00000000B,01000000B;3
	DB	00000000B,01000000B;4
	DB	00000000B,01000000B;5
	DB	00000000B,01000000B;6
	DB	00000000B,01000000B;7
	DB	00000000B,00000000B;0
	DB	00000000B,00000000B;1
	DB	00000000B,00000000B;2
	DB	00000000B,00000000B;3
	DB	00000000B,00000000B;4
	DB	00000000B,00000000B;5
	DB	00000000B,00000000B;6
	DB	00000000B,00000000B;7

J8176H	LABEL	BYTE		; 8176h "」"
	DB	0,0
	DB	00000000B,00000000B;0
	DB	00000000B,00000000B;1
	DB	00000000B,00000000B;2
	DB	00000000B,00000000B;3
	DB	00000000B,00000000B;4
	DB	00000000B,00000000B;5
	DB	00000000B,00000000B;6
	DB	00000000B,00000000B;7
	DB	00000000B,00010000B;0
	DB	00000000B,00010000B;1
	DB	00000000B,00010000B;2
	DB	00000000B,00010000B;3
	DB	00000000B,00010000B;4
	DB	00000000B,00010000B;5
	DB	00000000B,00110000B;6
	DB	00001111B,11110000B;7

DATA	ENDS

	END
;
;	end of "VRTEXT0ASM"
;
