; "VRMMOV.ASM" PC-9801UV11 make by R.H 1989/12/27
;	modify 1991/06/22 PS55Z/J14 (code01 gate call)
;
;	ＶＲＡＭデータ＜－＞バッファ転送
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

PUBLIC	VRMGT			; ＶＲＡＭデータＧＥＴ
PUBLIC	VRMPT			; ＶＲＡＭデータＰＵＴ

EXTRN	VCXRTW_OL:NEAR		; オーバラップＰＵＴ

EXTRN C1VV_BANK_CHG_ES:NEAR	; vram bank check & chenge. ES
EXTRN C1VV_BANK_PLN_DS:NEAR	; vram bank check & chenge.(READ) DS

;	ＶＲＡＭデータＰＵＴ
;	（データ圧縮用ワークバッファ－＞ＶＲＡＭコピー）
;	-I- VRX    : ＶＲＡＭ　Ｘ座標
;	    VRY    : ＶＲＡＭ　Ｙ座標
;	    VRLENX : Ｘ方向長さ
;	    VRLENY : Ｙ方向長さ
;	    BPNTOF : データバッファポインタ
;	    BPNTSG : データバッファセグメント
;	    BCNTMX : データ最大長さ

VRMPT	PROC	NEAR
	CMP	BBOVLP,0	; オーバラップフラグ
	JNE	VRMPT_OL	;

	CALL	VRAMPUT		; ワークバッファ－＞ＶＲＡＭ転送
	JMP	VRMPT_EXIT	;
VRMPT_OL:
	PUSH	DS		;
	MOV	AX,DS		;
	MOV	ES,AX		;
	MOV	SI,BPNTOF	; データバッファポインタ
	MOV	AX,BPNTSG	; データバッファセグメント
	MOV	DS,AX		;
	CALL	VCXRTW_OL	; オーバラップＰＵＴ
	POP	DS		;
	JMP	VRMPT_EXIT	;
VRMPT_EXIT:
	RET
VRMPT	ENDP




;	ＶＲＡＭデータＧＥＴ
;	（ＶＲＡＭ－＞データ圧縮用ワークバッファコピー）
;	-I- VRX    : ＶＲＡＭ　Ｘ座標
;	    VRY    : ＶＲＡＭ　Ｙ座標
;	    VRLENX : Ｘ方向長さ
;	    VRLENY : Ｙ方向長さ
;	    BPNTOF : データバッファポインタ
;	    BPNTSG : データバッファセグメント
;	    BCNTMX : データ最大長さ
;	-O- BCOUNT ; データ長さ
;	    BPOINT ; データ終わりアドレス＋１
;	    AH     : 0=normal 1=E.O.F

VRMGT	PROC	NEAR
	CALL	VRAMGET		; ＶＲＡＭ－＞ワークバッファ転送
	RET
VRMGT	ENDP


;	ＶＲＡＭ－＞ワークバッファ転送
;	-I- VRX    : ＶＲＡＭ　Ｘ座標
;	    VRY    : ＶＲＡＭ　Ｙ座標
;	    VRLENX : Ｘ方向長さ
;	    VRLENY : Ｙ方向長さ
;	    BPNTOF : データバッファポインタ
;	    BPNTSG : データバッファセグメント
;	    BCNTMX : データ最大長さ

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

	MOV	DX,VRLENX		; DX=Ｘバイト数
	MOV	BX,VRLENY		; BX=Ｙライン数
	MOV	BP,SSGRW		; vram width.

	MOV	AX,DS			;

	MOV	SI,BPNTOF		; データバッファポインタ
	MOV	CX,BPNTSG		; データバッファセグメント
	MOV	DS,CX			;

	MOV	ES,AX			;
	MOV	CX,ES:SSGR0		; visual data segment plean 0
	MOV	ES,CX			;
	CALL	VRAMPUT_PLN		; ワークバッファ転送－＞ＶＲＡＭ

	MOV	ES,AX			;
	MOV	CX,ES:SSGR1		; visual data segment plean 1
	MOV	ES,CX			;
	CALL	VRAMPUT_PLN		; ワークバッファ転送－＞ＶＲＡＭ

	MOV	ES,AX			;
	MOV	CX,ES:SSGR2		; visual data segment plean 2
	MOV	ES,CX			;
	CALL	VRAMPUT_PLN		; ワークバッファ転送－＞ＶＲＡＭ

	MOV	ES,AX			;
	MOV	CX,ES:SSGR3		; visual data segment plean 3
	MOV	ES,CX			;
	CALL	VRAMPUT_PLN		; ワークバッファ転送－＞ＶＲＡＭ

	POP	DS
VRAMPUT9:
	POP	DX
	POP	CX
	POP	BX
	RET
VRAMPUT	ENDP


;	ワークバッファ転送－＞ＶＲＡＭ
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
	MOV	CX,DX			; DX=Ｘバイト数
	REP	MOVSB			; 転送
	SUB	DI,DX			;
	ADD	DI,BP			; 次のライン
	DEC	BX			; y line count.
	JNZ	VRAMPUT_PLN_3		;
	POP	DI
	POP	BX
	RET
VRAMPUT_PLN	ENDP


;	ＶＲＡＭ－＞ワークバッファ転送
;	-I- VRX    : ＶＲＡＭ　Ｘ座標
;	    VRY    : ＶＲＡＭ　Ｙ座標
;	    VRLENX : Ｘ方向長さ
;	    VRLENY : Ｙ方向長さ
;	    BPNTOF : データバッファポインタ
;	    BPNTSG : データバッファセグメント
;	    BCNTMX : データ最大長さ
;	-O- BCOUNT ; データ長さ
;	    BPOINT ; データ終わりアドレス＋１
;	    AH     : 0=normal 1=E.O.F

VRAMGET	PROC	NEAR
	PUSH	BX
	PUSH	CX
	PUSH	DX

	MOV	AX,VRLENX		;
	MOV	BX,VRLENY		; データサイズ計算
	IMUL	BX			;
	SHL	AX,1			;
	SHL	AX,1			; * 4 plean
	MOV	BCOUNT,AX		; データ長さ
	CMP	AX,BCNTMX		; データ最大長さ
	JBE	VRAMGET1		;

	MOV	AH,1			; 1=E.O.F
	POP	DX
	POP	CX
	POP	BX
	RET

VRAMGET1:
	ADD	AX,BPNTOF		; データバッファポインタ＋ﾃﾞｰﾀｻｲｽﾞ
	MOV	BPOINT,AX		; データ終わりアドレス＋１

	MOV	AX,VRY			;
	MOV	BX,SSGRW		; vram width.
	MUL	BX			;
	MOV	SI,AX			; point address.
	ADD	SI,VRX			; SI = VRY * SSGRW + VRX

	PUSH	DS

	MOV	AX,BPNTSG		;
	MOV	ES,AX			;
	MOV	DI,BPNTOF		;

	MOV	DX,VRLENX		; DX=Ｘバイト数
	MOV	BX,VRLENY		; BX=Ｙライン数
	MOV	BP,SSGRW		; vram width.

	MOV	AX,DS			;

	MOV	CX,SSGR0		; visual data segment plean 0
	MOV	DS,CX			;
	CALL	VRAMGET_PLN		; ＶＲＡＭ－＞ワークバッファ転送

	MOV	DS,AX			;
	MOV	CX,SSGR1		; visual data segment plean 1
	MOV	DS,CX			;
	CALL	VRAMGET_PLN		; ＶＲＡＭ－＞ワークバッファ転送

	MOV	DS,AX			;
	MOV	CX,SSGR2		; visual data segment plean 2
	MOV	DS,CX			;
	CALL	VRAMGET_PLN		; ＶＲＡＭ－＞ワークバッファ転送

	MOV	DS,AX			;
	MOV	CX,SSGR3		; visual data segment plean 3
	MOV	DS,CX			;
	CALL	VRAMGET_PLN		; ＶＲＡＭ－＞ワークバッファ転送

	POP	DS
VRAMGET9:
	MOV	AH,0			; 0=normal 1=E.O.F
	POP	DX
	POP	CX
	POP	BX
	RET
VRAMGET	ENDP


;	ＶＲＡＭ－＞ワークバッファ転送
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
	MOV	CX,DX			; DX=Ｘバイト数
	REP	MOVSB			; 転送
	SUB	SI,DX			;
	ADD	SI,BP			; 次のライン
	DEC	BX			; y line count.
	JNZ	VRAMGET_PLN_3		;
	POP	SI
	POP	BX
	RET
VRAMGET_PLN	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	BBOVLP:WORD		; パターンＰＵＴオーバラップフラグ

EXTRN	VRX:WORD		; x point.
EXTRN	VRY:WORD		; y point.

EXTRN	VRLENX:WORD		; x length.
EXTRN	VRLENY:WORD		; y length.

EXTRN	BPOINT:WORD		; data buffer point.
EXTRN	BPNTOF:WORD		; データバッファポインタ
EXTRN	BPNTSG:WORD		; データバッファセグメント
EXTRN	BCNTMX:WORD		; データ最大長さ
EXTRN	BCOUNT:WORD		; データ長さ

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