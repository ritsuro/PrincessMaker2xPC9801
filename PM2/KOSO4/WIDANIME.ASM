; "WIDANIME.ASM" 486/50 make by R.H 1992/05/21
;
;
;	ÇvÇhÇmÇcÇnÇvÇrÅ^ÉAÉjÉÅÅEÉEÉCÉìÉhÉE
;
;
;	WIDANIME		 ; WINDOWS/ÉAÉjÉÅÅEÉEÉCÉìÉhÉE
;
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC

NORMAL_BANK	EQU	0		; í èÌÇÃÉpÅ[ÉcÉoÉìÉNî‘çÜ
ANIMEPAT_BANK	EQU	0;10;5		; ÉAÉjÉÅÉoÉìÉNî‘çÜ
					; #5 í èÌÉpÉ^Å[ÉìÉoÉbÉtÉ@å„îº

BACK_2_BANK6	EQU	6		; àÍéûëﬁîÉGÉäÉA
					; #6 text buffer.å„îº

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA

; ****************************************************
;	WINDOWS/ÉAÉjÉÅÅEÉEÉCÉìÉhÉE
;	-I- AX : function.
;		=1 : anime window open.
;		=2 : anime window close.
;		=3 : pictuer load.
;		    SI : file name.
;		=4 : put BG.
;		=5 : pictuer copy vvram -> CRT.
;		=6 : anime pattern add load.
;		    SI : file name.
;		=7 : anime pattern put vvram.
;		    CX : x1.
;		    DX : y1.
;		    SI : pattern number.
;		=8 : restore vram ARA002 -> bank#6 move.
;		=9 : anime window close.(to bank#6)
;		=10 : anime window size set.çÇë¨âªÇÃà◊ÇÃÉTÉCÉYïœçX
;		    CX : x1.
;		    DX : y1.
;		    SI : x2.
;		    DI : y2.
;		=11 : (bank)pictuer load.
;		    CX : bank.
;		    SI : file name.
;		=12 : (bank)anime pattern add load.
;		    CX : bank.
;		    SI : file name.
;		=13 : (bank)anime pattern put vvram.
;		    CX : bank.
;		    DX : x1.
;		    SI : y1.
;		    DI : pattern number.
;		=14 : anime window open.(no frame open)
;		=15 : anime window copy.
;		    CX : x1.
;		    DX : y1.
;		    SI : x2.
;		    DI : y2.
;		    BP : x length.
;		    ES : y length.
;		=16 : anime window open.(location)
;		    CX : x1.
;		    DX : y1.
;		=17 : (bank)anime ptn ofset maskput vvram.
;		    CX : bank.
;		    DX : x1.
;		    SI : y1.
;		    DI : pattern number.
;
;		    BX : anime window type. 0=small,1=large,2=large2
; ****************************************************

FUNC	WIDANIME
	PUSH	AX

	MOV	WIDTYPE,BX		; window type.
	MOV	REG_ES,ES		; user ES reg.

	CALL_w	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.

	POP	BX			; BX : function.
	DEC	BX			;

	CMP	BX,(WIDANIME_JMP_END-WIDANIME_JMP)/2
	JNB	WIDANIME_JMP_EXIT	;

	SHL	BX,1			;
	MOVX	ES,<SEG WINDOW>		;
	CALL	WORD PTR ES:WIDANIME_JMP[BX]

	JMP	WIDANIME_JMP_EXIT

WIDANIME_JMP	LABEL	WORD
	DW	ANIME_WID_OPEN		; anime window open.
	DW	ANIME_WID_CLOSE		; anime window close.
	DW	PICLOAD			; pictuer load.
	DW	PUTBG			; put BG.
	DW	V2TOCRTCOPY		; pictuer copy vvram -> CRT.
	DW	ANIME_PTN_LOAD		; anime pattern add load.
	DW	ANIME_PTN_PUT		; anime pattern put vvram.
	DW	BACK_ARA002_TO_BANK6	; restore vram ARA002 -> bank#6 move.
	DW	ANIME_WID_CLOSE_BANK6	; anime window close.(to bank#6)
	DW	ANIME_WID_SIZE_SET	; anime window size set.
	DW	BK_PICLOAD		; (bank)pictuer load.
	DW	BK_ANIME_PTN_LOAD	; (bank)anime pattern add load.
	DW	BK_ANIME_PTN_PUT	; (bank)anime pattern put vvram.
	DW	ANIME_WID_OPEN_NO_FRM	; anime window open.(no frame open)
	DW	ANIME_WINDOW_COPY	; anime window copy.
	DW	ANIME_WID_OPEN_LOC	; anime window open.(location)
	DW	BK_ANIME_PTN_OFST_M_PUT	; (bank)anime ptn ofset maskput vvram.
WIDANIME_JMP_END	LABEL	WORD

WIDANIME_JMP_EXIT:
	RET
FEND	WIDANIME


; ****************************************************
;	pictuer load.
;	-I- SI : file name.
; ****************************************************

PICLOAD	PROC	NEAR
	MOV	DX,ANIMEPAT_BANK	; ÉAÉjÉÅÉoÉìÉNî‘çÜ
	CALL_w	PT_PATTERN_LD		; pattern load.
	RET
PICLOAD	ENDP


; ****************************************************
;	(bank)pictuer load.
;	-I- SI : file name.
;	    CX : bank.
; ****************************************************

BK_PICLOAD	PROC	NEAR
	MOV	DX,CX			; bank.
	CALL_w	PT_PATTERN_LD		; pattern load.

	MOV	DX,ANIMEPAT_BANK	; ÉAÉjÉÅÉoÉìÉNî‘çÜ
	CALL_w	PT_PATTERN_BANK		; pattern bank set.
	RET
BK_PICLOAD	ENDP


; ****************************************************
;	put BG.
; ****************************************************

PUTBG	PROC	NEAR
	MOV	AX,W_TIME_BG		; wait time BG put.
	CALL_w	TMVST7			; V-SYNC timer7 set.(wwanime.asm)

	CALL	ASSIGN_SSGR_VIRTUAL	; SSGR0 <=== âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì

	MOV	AX,MOVOFSX		; ì]ëóÉIÉtÉZÉbÉgÇw
	MOV	BX,MOVOFSY		; ì]ëóÉIÉtÉZÉbÉgÇx
	MOV	CX,MOVSIZX		; ì]ëóÉTÉCÉYÇw
	MOV	DX,MOVSIZY		; ì]ëóÉTÉCÉYÇx
	MOV	VRPX,AX			; ÇfÇdÇs Çwç¿ïW
	MOV	VRPY,BX			; ÇfÇdÇs Çxç¿ïW
	MOV	VRLENPX,CX		; ÇfÇdÇs ÇwÉTÉCÉY
	MOV	VRLENPY,DX		; ÇfÇdÇs ÇxÉTÉCÉY
	CALL_w	C1PLSVIW		; ÇoÇtÇsÇuÇhÇdÇvÇÃê›íË

	MOV	AX,BASE_XX1		; pictuer base 1 x.
	MOV	BX,BASE_YY1		; pictuer base 1 y.
	ADD	AX,MOVOFSX		; ì]ëóÉIÉtÉZÉbÉgÇw
	ADD	BX,MOVOFSY		; ì]ëóÉIÉtÉZÉbÉgÇx
	MOV	DX,0			; pattern number.
	CALL_w	PT_PATTERN_PUT		; pattern put.

	CALL_w 	C1PLSVWS		; ÇoÇtÇsÇuÇhÇdÇvÇÃâèú

PUTBG_WAIT:
	CALL_w	TMVCK7			; V-SYNC timer7 check.
	CMP	AX,0			; 0=timer now, 1=timer end.
	JE	PUTBG_WAIT		;

	RET
PUTBG	ENDP


; ****************************************************
;	pictuer copy vvram -> CRT.
; ****************************************************

V2TOCRTCOPY	PROC	NEAR
	MOV	AX,W_TIME_CRT		; wait time copy CRT.
	CALL_w	TMVST7			; V-SYNC timer7 set.(wwanime.asm)

	CALL	ASSIGN_SSSOU_VIRTUAL	; SSSOU0 <=== âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì
	CALL	ASSIGN_SSDES_VRAM	; SSDES0 <=== VRAM

	MOV	AX,BASE_XX1		; pictuer base 1 x.
	MOV	BX,BASE_YY1		; pictuer base 1 y.
	ADD	AX,MOVOFSX		; ì]ëóÉIÉtÉZÉbÉgÇw
	ADD	BX,MOVOFSY		; ì]ëóÉIÉtÉZÉbÉgÇx
	MOV	VX1,AX			;
	MOV	VY1,BX			;

	MOVX	VX2,MOVSIZX		; ì]ëóÉTÉCÉYÇw
	MOVX	VY2,MOVSIZY		; ì]ëóÉTÉCÉYÇx

	MOV	AX,WIDIVEXP		; ÉEÉCÉìÉhÉEÉGÉäÉAç∂è„ç¿ïWÇw
	MOV	BX,WIDIVEYP		; ÉEÉCÉìÉhÉEÉGÉäÉAç∂è„ç¿ïWÇx
	ADD	AX,MOVOFSX		; ì]ëóÉIÉtÉZÉbÉgÇw
	ADD	BX,MOVOFSY		; ì]ëóÉIÉtÉZÉbÉgÇx
	MOV	VX3,AX			;
	MOV	VY3,BX			;

	CALL_w	MOVEVR			; vram to vram move.

V2TOCRTCOPY_WAIT:
	CALL_w	TMVCK7			; V-SYNC timer7 check.
	CMP	AX,0			; 0=timer now, 1=timer end.
	JE	V2TOCRTCOPY_WAIT	;
	RET
V2TOCRTCOPY	ENDP


; ****************************************************
;	anime pattern add load.
;	-I- SI : file name.
; ****************************************************

ANIME_PTN_LOAD	PROC	NEAR
	CALL_w	PT_PATTERN_LDA		; pattern add load.
	RET
ANIME_PTN_LOAD	ENDP


; ****************************************************
;	(bank)anime pattern add load.
;	-I- SI : file name.
;	    CX : bank.
; ****************************************************

BK_ANIME_PTN_LOAD	PROC	NEAR
	MOV	DX,CX			; bank.
	PUSH	SI
	CALL_w	PT_PATTERN_BANK		; pattern bank set.
	POP	SI
	CALL_w	PT_PATTERN_LDA		; pattern add load.

	MOV	DX,ANIMEPAT_BANK	; ÉAÉjÉÅÉoÉìÉNî‘çÜ
	CALL_w	PT_PATTERN_BANK		; pattern bank set.
	RET
BK_ANIME_PTN_LOAD	ENDP


; ****************************************************
;	anime pattern put vvram.
;	-I- CX : x1.
;	    DX : y1.
;	    SI : pattern number.
; ****************************************************

ANIME_PTN_PUT	PROC	NEAR
	ADD	CX,BASE_XX1		; pictuer base 1 x.
	ADD	DX,BASE_YY1		; pictuer base 1 y.
	MOV	XX1,CX			; x1.
	MOV	YY1,DX			; y1.
	MOV	NNUM,SI			; number.

	CALL	ASSIGN_SSGR_VIRTUAL	; SSGR0 <=== âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì

	MOV	AX,XX1			; x1.
	MOV	BX,YY1			; y1.
	MOV	DX,NNUM			; pattern number.
	CALL_w	PT_MASK_PAT_PUT		; pattern mask put.
	RET
ANIME_PTN_PUT	ENDP


; ****************************************************
;	(bank)anime pattern put vvram.
;	-I- CX : bank.
;	    DX : x1.
;	    SI : y1.
;	    DI : pattern number.
; ****************************************************

BK_ANIME_PTN_PUT	PROC	NEAR
	ADD	DX,BASE_XX1		; pictuer base 1 x.
	ADD	SI,BASE_YY1		; pictuer base 1 y.
	MOV	XX1,DX			; x1.
	MOV	YY1,SI			; y1.
	MOV	NNUM,DI			; number.

	MOV	DX,CX			; bank.
	CALL_w	PT_PATTERN_BANK		; pattern bank set.

	CALL	ASSIGN_SSGR_VIRTUAL	; SSGR0 <=== âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì

	MOV	AX,XX1			; x1.
	MOV	BX,YY1			; y1.
	MOV	DX,NNUM			; pattern number.
	CALL_w	PT_MASK_PAT_PUT		; pattern mask put.

	MOV	DX,ANIMEPAT_BANK	; ÉAÉjÉÅÉoÉìÉNî‘çÜ
	CALL_w	PT_PATTERN_BANK		; pattern bank set.
	RET
BK_ANIME_PTN_PUT	ENDP


; ****************************************************
;	(bank)anime ptn ofset maskput vvram.
;	-I- CX : bank.
;	    DX : x1.
;	    SI : y1.
;	    DI : pattern number.
; ****************************************************

BK_ANIME_PTN_OFST_M_PUT	PROC	NEAR
	ADD	DX,BASE_XX1		; pictuer base 1 x.
	ADD	SI,BASE_YY1		; pictuer base 1 y.
	MOV	XX1,DX			; x1.
	MOV	YY1,SI			; y1.
	MOV	NNUM,DI			; number.

	MOV	DX,CX			; bank.
	CALL_w	PT_PATTERN_BANK		; pattern bank set.

	CALL	ASSIGN_SSGR_VIRTUAL	; SSGR0 <=== âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì

	MOV	AX,XX1			; x1.
	MOV	BX,YY1			; y1.
	MOV	DX,NNUM			; pattern number.
	CALL_w	PT_MASK_PTF_PUT		; pattern mask offset put.

	MOV	DX,ANIMEPAT_BANK	; ÉAÉjÉÅÉoÉìÉNî‘çÜ
	CALL_w	PT_PATTERN_BANK		; pattern bank set.
	RET
BK_ANIME_PTN_OFST_M_PUT	ENDP


; ****************************************************
;	anime window copy.
;	-I- CX : x1.
;	    DX : y1.
;	    SI : x2.
;	    DI : y2.
;	    BP : size x.
;	    ES : size y.
; ****************************************************

ANIME_WINDOW_COPY	PROC	NEAR
	MOV	CPYOFSX1,CX		; ì]ëóå≥ÉIÉtÉZÉbÉgÇw
	MOV	CPYOFSY1,DX		; ì]ëóå≥ÉIÉtÉZÉbÉgÇx
	MOV	CPYOFSX2,SI		; ì]ëóêÊÉIÉtÉZÉbÉgÇw
	MOV	CPYOFSY2,DI		; ì]ëóêÊÉIÉtÉZÉbÉgÇx
	MOV	CPYSIZEX,BP		; ì]ëóÉTÉCÉYÇw
	MOVX	CPYSIZEY,REG_ES		; ì]ëóÉTÉCÉYÇx

	CALL	ASSIGN_SSSOU_VIRTUAL	; SSSOU0 <=== âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì
	CALL	ASSIGN_SSDES_VIRTUAL	; SSDES0 <=== âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì

	MOV	AX,BASE_XX1		; pictuer base 1 x.
	MOV	BX,BASE_YY1		; pictuer base 1 y.
	ADD	AX,CPYOFSX1		; ì]ëóå≥ÉIÉtÉZÉbÉgÇw
	ADD	BX,CPYOFSY1		; ì]ëóå≥ÉIÉtÉZÉbÉgÇx
	MOV	VX1,AX			;
	MOV	VY1,BX			;

	MOVX	VX2,CPYSIZEX		; ì]ëóÉTÉCÉYÇw
	MOVX	VY2,CPYSIZEY		; ì]ëóÉTÉCÉYÇx

	MOV	AX,BASE_XX1		; pictuer base 1 x.
	MOV	BX,BASE_YY1		; pictuer base 1 y.
	ADD	AX,CPYOFSX2		; ì]ëóêÊÉIÉtÉZÉbÉgÇw
	ADD	BX,CPYOFSY2		; ì]ëóêÊÉIÉtÉZÉbÉgÇx
	MOV	VX3,AX			;
	MOV	VY3,BX			;

	CALL_w	MOVEVR			; vram to vram move.

	RET
ANIME_WINDOW_COPY	ENDP


; ****************************************************
;	anime window open.
; ****************************************************

ANIME_WID_OPEN	PROC	NEAR
	CALL	ANIME_WID_OPEN_NO_FRM	; anime window open.(no frame open)

	CMP	WIDTYPE,1		; window type. 0=small,1=large.
	JE	ANIME_WID_OPEN_LARGE	;
	CMP	WIDTYPE,2		; 2=large2
	JE	ANIME_WID_OPEN_LARGE	;

	CALL	BACKSAVE		; îwåiÇÉZÅ[Éu
	CALL	ASSIGN_SSDES_VRAM	; SSDES0 <=== VRAM
	MOVX	WDX1,WIDFRMXP		; ÉtÉåÅ[ÉÄç∂è„ç¿ïWÇw
	MOVX	WDY1,WIDFRMYP		; ÉtÉåÅ[ÉÄç∂è„ç¿ïWÇx
	CALL_w	WID_FRAME_ANIME_SMALL	; WINDOWS/ÉtÉåÅ[ÉÄÅEè¨ÉAÉjÉÅ
	RET
ANIME_WID_OPEN_LARGE:
	CALL	ASSIGN_SSDES_VRAM	; SSDES0 <=== VRAM
	MOVX	WDX1,WIDFRMXP		; ÉtÉåÅ[ÉÄç∂è„ç¿ïWÇw
	MOVX	WDY1,WIDFRMYP		; ÉtÉåÅ[ÉÄç∂è„ç¿ïWÇx
	CALL_w	WID_FRAME_ANIME_LARGE	; WINDOWS/ÉtÉåÅ[ÉÄÅEëÂÉAÉjÉÅ
	RET
ANIME_WID_OPEN	ENDP


; ****************************************************
;	anime window open.(no frame open)
; ****************************************************

ANIME_WID_OPEN_NO_FRM	PROC	NEAR
	MOV	BX,WIDTYPE		; window type.
	SHL	BX,1			; word pointer.

	MOV	AX,TBLXP[BX]		; table ç∂è„ç¿ïWÇw
	MOV	WIDIVEXP,AX		; ÉEÉCÉìÉhÉEÉGÉäÉAç∂è„ç¿ïWÇw
	DEC	AX			;
	MOV	WIDBAKXP,AX		; îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇw
	MOV	WIDFRMXP,AX		; ÉtÉåÅ[ÉÄç∂è„ç¿ïWÇw

	MOV	AX,TBLYP[BX]		; table ç∂è„ç¿ïWÇx
	MOV	WIDIVEYP,AX		; ÉEÉCÉìÉhÉEÉGÉäÉAç∂è„ç¿ïWÇx
	SUB	AX,8			;
	MOV	WIDBAKYP,AX		; îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇx
	MOV	WIDFRMYP,AX		; ÉtÉåÅ[ÉÄç∂è„ç¿ïWÇx

	MOV	AX,TBLXL[BX]		; table ÉTÉCÉYÇw
	MOV	WIDIVEXL,AX		; ÉEÉCÉìÉhÉEÉGÉäÉAÉTÉCÉYÇw
	MOV	MOVSIZX,AX		; ì]ëóÉTÉCÉYÇw
	ADD	AX,2			;
	MOV	WIDBAKXL,AX		; îwåiëﬁîÉGÉäÉAÉTÉCÉYÇw

	MOV	AX,TBLYL[BX]		; table ÉTÉCÉYÇx
	MOV	WIDIVEYL,AX		; ÉEÉCÉìÉhÉEÉGÉäÉAÉTÉCÉYÇx
	MOV	MOVSIZY,AX		; ì]ëóÉTÉCÉYÇx
	ADD	AX,8*2			;
	MOV	WIDBAKYL,AX		; îwåiëﬁîÉGÉäÉAÉTÉCÉYÇx

	MOVX	BASE_XX1,TBL_BSXX1[BX]	; pictuer base 1 x.
	MOVX	BASE_YY1,TBL_BSYY1[BX]	; pictuer base 1 y.
	MOVX	BASE_XX2,TBL_BSXX2[BX]	; pictuer base 2 x.
	MOVX	BASE_YY2,TBL_BSYY2[BX]	; pictuer base 2 y.

	MOVX	W_TIME_BG,TBL_W_TIME_BG[BX]	; wait time BG put.
	MOVX	W_TIME_CRT,TBL_W_TIME_CPY[BX]	; wait time copy CRT.

	MOV	MOVOFSX,0		; ì]ëóÉIÉtÉZÉbÉgÇw
	MOV	MOVOFSY,0		; ì]ëóÉIÉtÉZÉbÉgÇx

	RET
ANIME_WID_OPEN_NO_FRM	ENDP


; ****************************************************
;	anime window open.(location/no save)
;	-I- CX : x1.
;	    DX : y1.
; ****************************************************

ANIME_WID_OPEN_LOC	PROC	NEAR
	PUSH	CX
	PUSH	DX
	CALL	ANIME_WID_OPEN_NO_FRM	; anime window open.(no frame open)
	POP	DX
	POP	CX

	MOV	WIDIVEXP,CX		; ÉEÉCÉìÉhÉEÉGÉäÉAç∂è„ç¿ïWÇw
	DEC	CX			;
	MOV	WIDBAKXP,CX		; îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇw
	MOV	WIDFRMXP,CX		; ÉtÉåÅ[ÉÄç∂è„ç¿ïWÇw

	MOV	WIDIVEYP,DX		; ÉEÉCÉìÉhÉEÉGÉäÉAç∂è„ç¿ïWÇx
	SUB	DX,8			;
	MOV	WIDBAKYP,DX		; îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇx
	MOV	WIDFRMYP,DX		; ÉtÉåÅ[ÉÄç∂è„ç¿ïWÇx

	CMP	WIDTYPE,1		; window type. 0=small,1=large.
	JE	ANIME_WID_OPEN_LOC_LARGE
	CMP	WIDTYPE,2		; 2=large2
	JE	ANIME_WID_OPEN_LOC_LARGE

	CALL	ASSIGN_SSDES_VRAM	; SSDES0 <=== VRAM
	MOVX	WDX1,WIDFRMXP		; ÉtÉåÅ[ÉÄç∂è„ç¿ïWÇw
	MOVX	WDY1,WIDFRMYP		; ÉtÉåÅ[ÉÄç∂è„ç¿ïWÇx
	CALL_w	WID_FRAME_ANIME_SMALL	; WINDOWS/ÉtÉåÅ[ÉÄÅEè¨ÉAÉjÉÅ
	RET
ANIME_WID_OPEN_LOC_LARGE:
	CALL	ASSIGN_SSDES_VRAM	; SSDES0 <=== VRAM
	MOVX	WDX1,WIDFRMXP		; ÉtÉåÅ[ÉÄç∂è„ç¿ïWÇw
	MOVX	WDY1,WIDFRMYP		; ÉtÉåÅ[ÉÄç∂è„ç¿ïWÇx
	CALL_w	WID_FRAME_ANIME_LARGE	; WINDOWS/ÉtÉåÅ[ÉÄÅEëÂÉAÉjÉÅ
	RET
ANIME_WID_OPEN_LOC	ENDP


; ****************************************************
;	anime window close.
; ****************************************************

ANIME_WID_CLOSE	PROC	NEAR
	CALL	BACKLOAD		; îwåiÇÉçÅ[Éh
	RET
ANIME_WID_CLOSE	ENDP


; ****************************************************
;	restore vram ARA002 -> bank#6 move.
; ****************************************************

BACK_ARA002_TO_BANK6	PROC	NEAR
	CALL	ASSIGN_SSGR_VIRTUAL	; SSGR0 <=== âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì

	MOV	DX,BACK_2_BANK6		; àÍéûëﬁîÉGÉäÉA
	CALL_w	C1PATBNK		; ÉoÉìÉNÉ`ÉFÉìÉW

	CALL_w	C1PATCLR		; ÉpÅ[ÉcÉZÉbÉgÉNÉäÉA

	MOVX	VRX,BASE_XX2		; window ç∂è„Çw
	MOVX	VRY,BASE_YY2		; window ç∂è„Çx
	MOVX	VRLENX,WIDBAKXL		; window ÉTÉCÉYÇw
	MOVX	VRLENY,WIDBAKYL		; window ÉTÉCÉYÇx
	CALL_w	C1PATGTA		; ÉpÅ[ÉcÇfÇdÇsà≥èkñ≥Çµ

	RET
BACK_ARA002_TO_BANK6	ENDP


; ****************************************************
;	anime window close.(to bank#6)
; ****************************************************

ANIME_WID_CLOSE_BANK6	PROC	NEAR
	CALL_w	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.

	MOV	DX,BACK_2_BANK6		; àÍéûëﬁîÉGÉäÉA
	CALL_w	C1PATBNK		; ÉoÉìÉNÉ`ÉFÉìÉW

	MOVX	VRX,WIDBAKXP		; îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇw
	MOVX	VRY,WIDBAKYP		; îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇx
	MOV	CX,NUM			; ÉpÅ[Écî‘çÜ
	CALL_w	C1PATPTX		; ÉpÅ[ÉcÇoÇtÇsç¿ïWéwíË

	RET
ANIME_WID_CLOSE_BANK6	ENDP


; ****************************************************
;	anime window size set.
;	-I- CX : x1.
;	    DX : y1.
;	    SI : x2.
;	    DI : y2.
; ****************************************************

ANIME_WID_SIZE_SET	PROC	NEAR
	MOV	MOVOFSX,CX		; ì]ëóÉIÉtÉZÉbÉgÇw
	MOV	MOVOFSY,DX		; ì]ëóÉIÉtÉZÉbÉgÇx
	MOV	MOVSIZX,SI		; ì]ëóÉTÉCÉYÇw
	MOV	MOVSIZY,DI		; ì]ëóÉTÉCÉYÇx
	RET
ANIME_WID_SIZE_SET	ENDP


; ****************************************************
;	îwåiÇÉçÅ[Éh
;	-I- WIDBAKXP : îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇw
;	    WIDBAKYP : îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇx
;	    WIDBAKXL : îwåiëﬁîÉGÉäÉAÉTÉCÉYÇw
;	    WIDBAKYL : îwåiëﬁîÉGÉäÉAÉTÉCÉYÇx
; ****************************************************

BACKLOAD	PROC	NEAR
	CALL	ASSIGN_SSSOU_VIRTUAL	; SSSOU0 <=== âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì
	CALL	ASSIGN_SSDES_VRAM	; SSDES0 <=== VRAM

	MOVX	VX1,BASE_XX2		; pictuer base 2 x.
	MOVX	VY1,BASE_YY2		; pictuer base 2 y.
	MOVX	VX2,WIDBAKXL		; îwåiëﬁîÉGÉäÉAÉTÉCÉYÇw
	MOVX	VY2,WIDBAKYL		; îwåiëﬁîÉGÉäÉAÉTÉCÉYÇx
	MOVX	VX3,WIDBAKXP		; îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇw
	MOVX	VY3,WIDBAKYP		; îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇx
	CALL_w	MOVEVR			; vram to vram move.
	RET
BACKLOAD	ENDP


; ****************************************************
;	îwåiÇÉZÅ[Éu
;	-I- WIDBAKXP : îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇw
;	    WIDBAKYP : îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇx
;	    WIDBAKXL : îwåiëﬁîÉGÉäÉAÉTÉCÉYÇw
;	    WIDBAKYL : îwåiëﬁîÉGÉäÉAÉTÉCÉYÇx
; ****************************************************

BACKSAVE	PROC	NEAR
	CALL	ASSIGN_SSSOU_VRAM	; SSSOU <=== VRAM
	CALL	ASSIGN_SSDES_VIRTUAL	; SSDES0 <=== âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì

	MOVX	VX1,WIDBAKXP		; îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇw
	MOVX	VY1,WIDBAKYP		; îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇx
	MOVX	VX2,WIDBAKXL		; îwåiëﬁîÉGÉäÉAÉTÉCÉYÇw
	MOVX	VY2,WIDBAKYL		; îwåiëﬁîÉGÉäÉAÉTÉCÉYÇx
	MOVX	VX3,BASE_XX2		; pictuer base 2 x.
	MOVX	VY3,BASE_YY2		; pictuer base 2 y.
	CALL_w	MOVEVR			; vram to vram move.
	RET
BACKSAVE	ENDP


; ****************************************************
;	SSGR0 <=== âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì
; ****************************************************

ASSIGN_SSGR_VIRTUAL	PROC	NEAR
	CMP	WIDTYPE,1		; 1=large
	JE	ASSIGN_SSGR_VIRTUAL_2	;
	CMP	WIDTYPE,2		; 2=large2
	JE	ASSIGN_SSGR_VIRTUAL_2	;
	MOV_ID2	SSGR0,ARA002		; âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì(width42)
	RET
ASSIGN_SSGR_VIRTUAL_2:
	MOV_ID2	SSGR0,ARA003		; âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì(width60)
	RET
ASSIGN_SSGR_VIRTUAL	ENDP


; ****************************************************
;	SSSOU <=== VRAM
; ****************************************************

ASSIGN_SSSOU_VRAM	PROC	NEAR
	MOV_ID2	SSSOU0,ARAVRM		; source data segment.
	RET
ASSIGN_SSSOU_VRAM	ENDP


; ****************************************************
;	SSSOU0 <=== âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì
; ****************************************************

ASSIGN_SSSOU_VIRTUAL	PROC	NEAR
	CMP	WIDTYPE,1		; 1=large
	JE	ASSIGN_SSSOU_VIRTUAL_2	;
	CMP	WIDTYPE,2		; 2=large2
	JE	ASSIGN_SSSOU_VIRTUAL_2	;
	MOV_ID2	SSSOU0,ARA002		; âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì(width42)
	RET
ASSIGN_SSSOU_VIRTUAL_2:
	MOV_ID2	SSSOU0,ARA003		; âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì(width60)
	RET
ASSIGN_SSSOU_VIRTUAL	ENDP


; ****************************************************
;	SSDES0 <=== VRAM
; ****************************************************

ASSIGN_SSDES_VRAM	PROC	NEAR
	MOV_ID2	SSDES0,ARAVRM		; destination data segment.
	RET
ASSIGN_SSDES_VRAM	ENDP


; ****************************************************
;	SSDES0 <=== âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì
; ****************************************************

ASSIGN_SSDES_VIRTUAL	PROC	NEAR
	CMP	WIDTYPE,1		; 1=large
	JE	ASSIGN_SSDES_VIRTUAL_2	;
	CMP	WIDTYPE,2		; 2=large2
	JE	ASSIGN_SSDES_VIRTUAL_2	;
	MOV_ID2	SSDES0,ARA002		; âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì(width42)
	RET
ASSIGN_SSDES_VIRTUAL_2:
	MOV_ID2	SSDES0,ARA003		; âºëzÇuÇqÇ`ÇlÉvÉåÅ[Éì(width60)
	RET
ASSIGN_SSDES_VIRTUAL	ENDP

WINDOW	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	VRPX:WORD		; ÇfÇdÇs Çwç¿ïW
EXTRN	VRPY:WORD		; ÇfÇdÇs Çxç¿ïW
EXTRN	VRLENPX:WORD		; ÇfÇdÇs ÇwÉTÉCÉY
EXTRN	VRLENPY:WORD		; ÇfÇdÇs ÇxÉTÉCÉY

WIDTYPE		DW	0	; window type. 0=small,1=large,2=large2

WIDIVEXP	DW	0	; ÉEÉCÉìÉhÉEÉGÉäÉAç∂è„ç¿ïWÇw
WIDIVEYP	DW	0	; ÉEÉCÉìÉhÉEÉGÉäÉAç∂è„ç¿ïWÇx
WIDIVEXL	DW	0	; ÉEÉCÉìÉhÉEÉGÉäÉAÉTÉCÉYÇw
WIDIVEYL	DW	0	; ÉEÉCÉìÉhÉEÉGÉäÉAÉTÉCÉYÇx

WIDFRMXP	DW	0	; ÉtÉåÅ[ÉÄç∂è„ç¿ïWÇw
WIDFRMYP	DW	0	; ÉtÉåÅ[ÉÄç∂è„ç¿ïWÇx

WIDBAKXP	DW	0	; îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇw
WIDBAKYP	DW	0	; îwåiëﬁîÉGÉäÉAç∂è„ç¿ïWÇx
WIDBAKXL	DW	0	; îwåiëﬁîÉGÉäÉAÉTÉCÉYÇw
WIDBAKYL	DW	0	; îwåiëﬁîÉGÉäÉAÉTÉCÉYÇx

MOVOFSX		DW	0	; ì]ëóÉIÉtÉZÉbÉgÇw
MOVOFSY		DW	0	; ì]ëóÉIÉtÉZÉbÉgÇx
MOVSIZX		DW	0	; ì]ëóÉTÉCÉYÇw
MOVSIZY		DW	0	; ì]ëóÉTÉCÉYÇx

CPYOFSX1	DW	0	; ì]ëóå≥ÉIÉtÉZÉbÉgÇw
CPYOFSY1	DW	0	; ì]ëóå≥ÉIÉtÉZÉbÉgÇx
CPYOFSX2	DW	0	; ì]ëóêÊÉIÉtÉZÉbÉgÇw
CPYOFSY2	DW	0	; ì]ëóêÊÉIÉtÉZÉbÉgÇx
CPYSIZEX	DW	0	; ì]ëóÉTÉCÉYÇw
CPYSIZEY	DW	0	; ì]ëóÉTÉCÉYÇx

BASE_XX1	DW	0	; pictuer base 1 x.
BASE_YY1	DW	0	; pictuer base 1 y.
BASE_XX2	DW	0	; pictuer base 2 x.
BASE_YY2	DW	200	; pictuer base 2 y.

TBLXP		DW	4,	13,	13	; table ç∂è„ç¿ïWÇw
TBLYP		DW	200,	64,	64	; table ç∂è„ç¿ïWÇx
TBLXL		DW	40,	54,	54	; table ÉTÉCÉYX
TBLYL		DW	128,	180,	180	; table ÉTÉCÉYY

TBL_BSXX1	DW	0,	0,	0	; pictuer base 1 x.
TBL_BSYY1	DW	0,	0,	30	; pictuer base 1 y.
TBL_BSXX2	DW	0,	0,	0	; pictuer base 2 x.
TBL_BSYY2	DW	200,	0,	0	; pictuer base 2 y.

TBL_W_TIME_BG	DW	2,	2,	2	; wait time BG put.
TBL_W_TIME_CPY	DW	2,	2,	2	; wait time copy CRT.

W_TIME_BG	DW	5	; wait time BG put.
W_TIME_CRT	DW	5	; wait time copy CRT.

XX1		DW	0	; x1.
YY1		DW	0	; y1.
NNUM		DW	0	; number.
REG_ES		DW	0	; user ES reg.

DATA	ENDS

	END
;
;	end of "WIDANIME.ASM"
;
