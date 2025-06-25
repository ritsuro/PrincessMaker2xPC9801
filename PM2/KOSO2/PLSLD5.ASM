; "PLSLD5.ASM"  PS55Z/S14 make by R.H/japan 1991/07/10
;
;
;	パーツデータ・オーバラップＰＵＴ
;
;
; public subroutine.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	VCXRTW_OL		; オーバラップＰＵＴ

EXTRN	C1VV_BANK_XCG_DX:NEAR	; vram bank check & chenge.(READ/WRITE) DX
EXTRN	C1VV_BANK_CHK:NEAR	; vram bank check. DX

EXTRN	TMVSET:NEAR		; V-SYNC timer set.
EXTRN	TMVCHK:NEAR		; V-SYNC timer check.


;	オーバラップＰＵＴ
;	-I- ES:VRX    : x point.
;	    ES:VRY    : y point.
;	    ES:VRLENX : x length.
;	    ES:VRLENY : y length.
;	    DS        : データバッファセグメント
;	    SI        : データバッファポインタ
;	    PRSSKP    : パーツＰＵＴのスキッププレーン (bit3:plean3,...)

VCXRTW_OL	PROC	NEAR
	PUSH	DS
	MOV	AX,SEG DATA		;
	MOV	DS,AX			;
	MOV	AX,0			; パターンＰＵＴオーバラップタイム
	CALL	TMVSET		; V-SYNC timer set.
	POP	DS

	MOV	AX,SEG DATA		;
	MOV	ES,AX			;

	MOV	ES:BBMASK,01111111B	; パターンＰＵＴオーバラップマスク

	MOV	CX,8			;
VCXRTW_OL_LOOP:				;
	PUSH	CX			;
	MOV	AX,SEG DATA		;
	MOV	ES,AX			;
	ROR	BYTE PTR ES:BBMASK,1	; パターンＰＵＴオーバラップマスク
	ROR	BYTE PTR ES:BBMASK,1	; パターンＰＵＴオーバラップマスク
	ROR	BYTE PTR ES:BBMASK,1	; パターンＰＵＴオーバラップマスク

	CALL	VCXRTW_OL_MSK		; ドットマスクＰＵＴ

	CALL	VCXRTW_OL_WAIT		; オーバラップＷＡＩＴ
	POP	CX			;
	LOOP	VCXRTW_OL_LOOP

	RET
VCXRTW_OL	ENDP


;	オーバラップＷＡＩＴ

VCXRTW_OL_WAIT	PROC	NEAR
	PUSH	DS			;
	MOV	AX,SEG DATA		;
	MOV	DS,AX			;
	CALL	OVLAP_WAIT		; オーバラップＷＡＩＴ
	POP	DS			;
	RET
VCXRTW_OL_WAIT	ENDP


;	ドットマスクＰＵＴ
;	-I- ES:VRX: x point.
;	    ES:VRY: y point.
;	    ES:VRLENX : x length.
;	    ES:VRLENY : y length.
;	    BBMASK    : パターンＰＵＴオーバラップマスク
;	    DS        : データバッファセグメント
;	    SI        : データバッファポインタ
;	    PRSSKP    : パーツＰＵＴのスキッププレーン (bit3:plean3,...)

VCXRTW_OL_MSK	PROC	NEAR
	PUSH	SI

	MOV	AX,SEG DATA		;
	MOV	ES,AX			;
	TEST	ES:PRSSKP,0001B		; パーツＰＵＴのスキッププレーン
	JNZ	VRMRTW_OL_01		;
	MOV	DX,ES:SSGR0		; visual data segment plean 0
	CALL	MTXVRF_OL		;範囲指定１プレーン・ドットマスクＰＵＴ
	JMP	VRMRTW_OL_02		;
VRMRTW_OL_01:				;
	CALL	VVPLN_FF		; 範囲指定１プレーン空送り
VRMRTW_OL_02:				;

	MOV	AX,SEG DATA		;
	MOV	ES,AX			;
	TEST	ES:PRSSKP,0010B		; パーツＰＵＴのスキッププレーン
	JNZ	VRMRTW_OL_11		;
	MOV	DX,ES:SSGR1		; visual data segment plean 1
	CALL	MTXVRF_OL		;範囲指定１プレーン・ドットマスクＰＵＴ
	JMP	VRMRTW_OL_12		;
VRMRTW_OL_11:				;
	CALL	VVPLN_FF		; 範囲指定１プレーン空送り
VRMRTW_OL_12:				;

	MOV	AX,SEG DATA		;
	MOV	ES,AX			;
	TEST	ES:PRSSKP,0100B		; パーツＰＵＴのスキッププレーン
	JNZ	VRMRTW_OL_21		;
	MOV	DX,ES:SSGR2		; visual data segment plean 2
	CALL	MTXVRF_OL		;範囲指定１プレーン・ドットマスクＰＵＴ
	JMP	VRMRTW_OL_22		;
VRMRTW_OL_21:				;
	CALL	VVPLN_FF		; 範囲指定１プレーン空送り
VRMRTW_OL_22:				;

	MOV	AX,SEG DATA		;
	MOV	ES,AX			;
	TEST	ES:PRSSKP,1000B		; パーツＰＵＴのスキッププレーン
	JNZ	VRMRTW_OL_31		;
	MOV	DX,ES:SSGR3		; visual data segment plean 3
	CALL	MTXVRF_OL		;範囲指定１プレーン・ドットマスクＰＵＴ
	JMP	VRMRTW_OL_32		;
VRMRTW_OL_31:				;
	CALL	VVPLN_FF		; 範囲指定１プレーン空送り
VRMRTW_OL_32:				;

	POP	SI
	RET
VCXRTW_OL_MSK	ENDP


;	範囲指定１プレーン・ドットマスクＰＵＴ
;	ワークバッファ－＞ＶＲＡＭプレーン
;	-I- DX        : ＶＲＡＭプレーンセグメント
;	    ES:VRX    : x point.
;	    ES:VRY    : y point.
;	    ES:VRLENX : x length.
;	    ES:VRLENY : y length.
;	    ES:SSGRW  : vram width.
;	    ES:BBMASK : パターンＰＵＴオーバラップマスク
;	-I/O- DS      : データバッファセグメント
;	      SI      : データバッファポインタ

MTXVRF_OL	PROC	NEAR
	CALL	C1VV_BANK_XCG_DX	; vram bank check & chenge.(R/W) DX
	MOV	BP,DX			; ＶＲＡＭプレーンセグメント

	MOV	AX,ES:VRY		;
	MOV	BX,ES:SSGRW		; vram width.
	MUL	BX			;
	MOV	DI,AX			; point address.
	ADD	DI,ES:VRX		; DI = VRY * SSGRW + VRX

	MOV	DX,ES:VRLENX		; x length.=DX
	MOV	CX,ES:VRLENY		; y length.=CX
	MOV	AH,BYTE PTR ES:BBMASK	; AH=パターンＰＵＴオーバラップマスク
	MOV	BX,ES:SSGRW		; vram width.

	CMP	ES:PLSMDE,1		; 圧縮モード(0:通常,1:縦方向)
	JE	MTXVRF_OL_TATE		;

	MOV	ES,BP			; ＶＲＡＭプレーンセグメント
	MOV	BP,DI			; ＶＲＡＭプレーンオフセット
	CALL	PLNSET_OL_KVM		; ドットマスク・ＶＲＡＭ(横圧縮)
	RET

MTXVRF_OL_TATE:
	MOV	ES,BP			; ＶＲＡＭプレーンセグメント
	MOV	BP,DI			; ＶＲＡＭプレーンオフセット
	CALL	MTXVRF_OL_KVM		; ドットマスク・ＶＲＡＭ(縦圧縮)
	RET
MTXVRF_OL	ENDP


;	ドットマスク・ＶＲＡＭ(横圧縮)
;	-I- DX : x length.
;	    CX : y length.
;	    AH : AH=パターンＰＵＴオーバラップマスク
;	    BX : vram width.
;	    DS:SI : ＰＵＴ ＤＡＴＡ
;	    ES : ＶＲＡＭプレーンセグメント
;	    BP : ＶＲＡＭプレーンオフセット

PLNSET_OL_KVM	PROC	NEAR
PLNSET_OLK2:
	PUSH	CX			; Ｙ長さ
	MOV	DI,BP			; ＶＲＡＭ転送の先頭オフセット
	MOV	CX,DX			; x length.
	PUSH	DX
PLNSET_OLK3:
	MOV	AL,ES:[DI]		; AL <- vram.
	AND	AL,AH			; AL mask.
	MOV	DH,DS:[SI]		; DH <- buffer.
	NOT	AH			;
	AND	DH,AH			; DH not mask.
	NOT	AH			;
	OR	AL,DH			; AL or DH
	STOSB				; AL put. -> vram.
	INC	SI			;
	LOOP	PLNSET_OLK3		;
	POP	DX

	ROL	AH,1			; AH=パターンＰＵＴオーバラップマスク
	ROL	AH,1			; AH=パターンＰＵＴオーバラップマスク

	ADD	BP,BX			; ＶＲＡＭライン計算用
	POP	CX			;
	LOOP	PLNSET_OLK2		;

	RET
PLNSET_OL_KVM	ENDP



;	ドットマスク・ＶＲＡＭ(縦圧縮)
;	-I- DX : x length.
;	    CX : y length.
;	    AH : AH=パターンＰＵＴオーバラップマスク
;	    BX : vram width.
;	    DS:SI : ＰＵＴ ＤＡＴＡ
;	    ES : ＶＲＡＭプレーンセグメント
;	    BP : ＶＲＡＭプレーンオフセット

MTXVRF_OL_KVM	PROC	NEAR
	DEC	BX
MTXVRF_OLK2:
	MOV	DI,BP			; ＶＲＡＭ転送の先頭オフセット

	PUSH	DX			;
	PUSH	CX			; Ｙ長さ
MTXVRF_OLK3:
	MOV	AL,ES:[DI]		; AL <- vram.
	AND	AL,AH			; AL mask.
	MOV	DH,DS:[SI]		; DH <- buffer.
	NOT	AH			;
	AND	DH,AH			; DH not mask.
	NOT	AH			;
	OR	AL,DH			; AL or DH
	STOSB				; AL put. -> vram.
	INC	SI			;

	ROL	AH,1			; AH=パターンＰＵＴオーバラップマスク
	ROL	AH,1			; AH=パターンＰＵＴオーバラップマスク

	ADD	DI,BX			; ＶＲＡＭライン計算用
	LOOP	MTXVRF_OLK3		;
	POP	CX			;
	POP	DX

	INC	BP			;

	DEC	DX			; X length.=DX
	JNZ	MTXVRF_OLK2		;

	RET
MTXVRF_OL_KVM	ENDP


;	オーバラップＷＡＩＴ

OVLAP_WAIT	PROC	NEAR
	PUSH	AX		;
	PUSH	BX		;
	PUSH	DX		;
OVLAP_WAIT2:			;
	CALL	TMVCHK		; V-SYNC timer check.
	CMP	AX,1		; 0=timer now, 1=timer end.
	JNE	OVLAP_WAIT2	;
	MOV	AX,BBOVTM	; パターンＰＵＴオーバラップタイム
	CALL	TMVSET		; V-SYNC timer set.
	POP	DX
	POP	BX
	POP	AX
	RET
OVLAP_WAIT	ENDP


;	範囲指定１プレーン空送り
;	ワークバッファ－＞ＶＲＡＭプレーン
;	-I- ES:VRLENX : x length.
;	    ES:VRLENY : y length.
;	-I/O- DS      : データバッファセグメント
;	      SI      : データバッファポインタ

VVPLN_FF	PROC	NEAR
	MOV	BX,ES:VRLENY	; y length.=BX
	MOV	AX,ES:VRLENX	; x length.=AX
	MOV	DX,0		;
	MUL	BX		;
	ADD	SI,AX		; 空送り
	RET
VVPLN_FF	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	BBOVTM			; パターンＰＵＴオーバラップタイム
PUBLIC	BBOVLP			; パターンＰＵＴオーバラップフラグ

EXTRN	PRSSKP:WORD		; パーツＰＵＴのスキッププレーン
EXTRN	PRSVMOD:WORD		; vram mode.0=normal,1=video memory

EXTRN	SSGR0:WORD		; visual data segment plean 0
EXTRN	SSGR1:WORD		; visual data segment plean 1
EXTRN	SSGR2:WORD		; visual data segment plean 2
EXTRN	SSGR3:WORD		; visual data segment plean 3
EXTRN	SSGRW:WORD		; visual data plean width.

EXTRN	VRX:WORD		; x point.
EXTRN	VRY:WORD		; y point.

EXTRN	VRLENX:WORD		; x length.
EXTRN	VRLENY:WORD		; y length.

EXTRN	BPOINT:WORD		; data buffer point.
EXTRN	BPNTOF:WORD		; データバッファポインタ
EXTRN	BPNTSG:WORD		; データバッファセグメント
EXTRN	BCNTMX:WORD		; データ最大長さ
EXTRN	BCOUNT:WORD		; データ長さ

EXTRN	PLSMDE:WORD		; 圧縮モード(0:通常,1:縦方向)

BBOVLP		DW	0	; パターンＰＵＴオーバラップフラグ
BBOVTM		DW	4	; パターンＰＵＴオーバラップタイム
BBMASK		DW	0	; パターンＰＵＴオーバラップマスク

DATA	ENDS

	END
;
;	end of "PLSLD5.ASM"
;
