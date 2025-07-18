; "WIDANIME.ASM" 486/50 make by R.H 1992/05/21
;
;
;	vhmcnvr^AjEEChE
;
;
;	WIDANIME		 ; WINDOWS/AjEEChE
;
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC

NORMAL_BANK	EQU	0		; ÊíÌp[coNÔ
ANIMEPAT_BANK	EQU	0;10;5		; AjoNÔ
					; #5 Êíp^[obt@ã¼

BACK_2_BANK6	EQU	6		; êŞğGA
					; #6 text buffer.ã¼

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA

; ****************************************************
;	WINDOWS/AjEEChE
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
;		=10 : anime window size set.¬»Ì×ÌTCYÏX
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
	MOV	DX,ANIMEPAT_BANK	; AjoNÔ
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

	MOV	DX,ANIMEPAT_BANK	; AjoNÔ
	CALL_w	PT_PATTERN_BANK		; pattern bank set.
	RET
BK_PICLOAD	ENDP


; ****************************************************
;	put BG.
; ****************************************************

PUTBG	PROC	NEAR
	MOV	AX,W_TIME_BG		; wait time BG put.
	CALL_w	TMVST7			; V-SYNC timer7 set.(wwanime.asm)

	CALL	ASSIGN_SSGR_VIRTUAL	; SSGR0 <=== ¼zuq`lv[

	MOV	AX,MOVOFSX		; ]ItZbgw
	MOV	BX,MOVOFSY		; ]ItZbgx
	MOV	CX,MOVSIZX		; ]TCYw
	MOV	DX,MOVSIZY		; ]TCYx
	MOV	VRPX,AX			; fds wÀW
	MOV	VRPY,BX			; fds xÀW
	MOV	VRLENPX,CX		; fds wTCY
	MOV	VRLENPY,DX		; fds xTCY
	CALL_w	C1PLSVIW		; otsuhdvÌİè

	MOV	AX,BASE_XX1		; pictuer base 1 x.
	MOV	BX,BASE_YY1		; pictuer base 1 y.
	ADD	AX,MOVOFSX		; ]ItZbgw
	ADD	BX,MOVOFSY		; ]ItZbgx
	MOV	DX,0			; pattern number.
	CALL_w	PT_PATTERN_PUT		; pattern put.

	CALL_w 	C1PLSVWS		; otsuhdvÌğ

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

	CALL	ASSIGN_SSSOU_VIRTUAL	; SSSOU0 <=== ¼zuq`lv[
	CALL	ASSIGN_SSDES_VRAM	; SSDES0 <=== VRAM

	MOV	AX,BASE_XX1		; pictuer base 1 x.
	MOV	BX,BASE_YY1		; pictuer base 1 y.
	ADD	AX,MOVOFSX		; ]ItZbgw
	ADD	BX,MOVOFSY		; ]ItZbgx
	MOV	VX1,AX			;
	MOV	VY1,BX			;

	MOVX	VX2,MOVSIZX		; ]TCYw
	MOVX	VY2,MOVSIZY		; ]TCYx

	MOV	AX,WIDIVEXP		; EChEGA¶ãÀWw
	MOV	BX,WIDIVEYP		; EChEGA¶ãÀWx
	ADD	AX,MOVOFSX		; ]ItZbgw
	ADD	BX,MOVOFSY		; ]ItZbgx
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

	MOV	DX,ANIMEPAT_BANK	; AjoNÔ
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

	CALL	ASSIGN_SSGR_VIRTUAL	; SSGR0 <=== ¼zuq`lv[

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

	CALL	ASSIGN_SSGR_VIRTUAL	; SSGR0 <=== ¼zuq`lv[

	MOV	AX,XX1			; x1.
	MOV	BX,YY1			; y1.
	MOV	DX,NNUM			; pattern number.
	CALL_w	PT_MASK_PAT_PUT		; pattern mask put.

	MOV	DX,ANIMEPAT_BANK	; AjoNÔ
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

	CALL	ASSIGN_SSGR_VIRTUAL	; SSGR0 <=== ¼zuq`lv[

	MOV	AX,XX1			; x1.
	MOV	BX,YY1			; y1.
	MOV	DX,NNUM			; pattern number.
	CALL_w	PT_MASK_PTF_PUT		; pattern mask offset put.

	MOV	DX,ANIMEPAT_BANK	; AjoNÔ
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
	MOV	CPYOFSX1,CX		; ]³ItZbgw
	MOV	CPYOFSY1,DX		; ]³ItZbgx
	MOV	CPYOFSX2,SI		; ]æItZbgw
	MOV	CPYOFSY2,DI		; ]æItZbgx
	MOV	CPYSIZEX,BP		; ]TCYw
	MOVX	CPYSIZEY,REG_ES		; ]TCYx

	CALL	ASSIGN_SSSOU_VIRTUAL	; SSSOU0 <=== ¼zuq`lv[
	CALL	ASSIGN_SSDES_VIRTUAL	; SSDES0 <=== ¼zuq`lv[

	MOV	AX,BASE_XX1		; pictuer base 1 x.
	MOV	BX,BASE_YY1		; pictuer base 1 y.
	ADD	AX,CPYOFSX1		; ]³ItZbgw
	ADD	BX,CPYOFSY1		; ]³ItZbgx
	MOV	VX1,AX			;
	MOV	VY1,BX			;

	MOVX	VX2,CPYSIZEX		; ]TCYw
	MOVX	VY2,CPYSIZEY		; ]TCYx

	MOV	AX,BASE_XX1		; pictuer base 1 x.
	MOV	BX,BASE_YY1		; pictuer base 1 y.
	ADD	AX,CPYOFSX2		; ]æItZbgw
	ADD	BX,CPYOFSY2		; ]æItZbgx
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

	CALL	BACKSAVE		; wiğZ[u
	CALL	ASSIGN_SSDES_VRAM	; SSDES0 <=== VRAM
	MOVX	WDX1,WIDFRMXP		; t[¶ãÀWw
	MOVX	WDY1,WIDFRMYP		; t[¶ãÀWx
	CALL_w	WID_FRAME_ANIME_SMALL	; WINDOWS/t[E¬Aj
	RET
ANIME_WID_OPEN_LARGE:
	CALL	ASSIGN_SSDES_VRAM	; SSDES0 <=== VRAM
	MOVX	WDX1,WIDFRMXP		; t[¶ãÀWw
	MOVX	WDY1,WIDFRMYP		; t[¶ãÀWx
	CALL_w	WID_FRAME_ANIME_LARGE	; WINDOWS/t[EåAj
	RET
ANIME_WID_OPEN	ENDP


; ****************************************************
;	anime window open.(no frame open)
; ****************************************************

ANIME_WID_OPEN_NO_FRM	PROC	NEAR
	MOV	BX,WIDTYPE		; window type.
	SHL	BX,1			; word pointer.

	MOV	AX,TBLXP[BX]		; table ¶ãÀWw
	MOV	WIDIVEXP,AX		; EChEGA¶ãÀWw
	DEC	AX			;
	MOV	WIDBAKXP,AX		; wiŞğGA¶ãÀWw
	MOV	WIDFRMXP,AX		; t[¶ãÀWw

	MOV	AX,TBLYP[BX]		; table ¶ãÀWx
	MOV	WIDIVEYP,AX		; EChEGA¶ãÀWx
	SUB	AX,8			;
	MOV	WIDBAKYP,AX		; wiŞğGA¶ãÀWx
	MOV	WIDFRMYP,AX		; t[¶ãÀWx

	MOV	AX,TBLXL[BX]		; table TCYw
	MOV	WIDIVEXL,AX		; EChEGATCYw
	MOV	MOVSIZX,AX		; ]TCYw
	ADD	AX,2			;
	MOV	WIDBAKXL,AX		; wiŞğGATCYw

	MOV	AX,TBLYL[BX]		; table TCYx
	MOV	WIDIVEYL,AX		; EChEGATCYx
	MOV	MOVSIZY,AX		; ]TCYx
	ADD	AX,8*2			;
	MOV	WIDBAKYL,AX		; wiŞğGATCYx

	MOVX	BASE_XX1,TBL_BSXX1[BX]	; pictuer base 1 x.
	MOVX	BASE_YY1,TBL_BSYY1[BX]	; pictuer base 1 y.
	MOVX	BASE_XX2,TBL_BSXX2[BX]	; pictuer base 2 x.
	MOVX	BASE_YY2,TBL_BSYY2[BX]	; pictuer base 2 y.

	MOVX	W_TIME_BG,TBL_W_TIME_BG[BX]	; wait time BG put.
	MOVX	W_TIME_CRT,TBL_W_TIME_CPY[BX]	; wait time copy CRT.

	MOV	MOVOFSX,0		; ]ItZbgw
	MOV	MOVOFSY,0		; ]ItZbgx

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

	MOV	WIDIVEXP,CX		; EChEGA¶ãÀWw
	DEC	CX			;
	MOV	WIDBAKXP,CX		; wiŞğGA¶ãÀWw
	MOV	WIDFRMXP,CX		; t[¶ãÀWw

	MOV	WIDIVEYP,DX		; EChEGA¶ãÀWx
	SUB	DX,8			;
	MOV	WIDBAKYP,DX		; wiŞğGA¶ãÀWx
	MOV	WIDFRMYP,DX		; t[¶ãÀWx

	CMP	WIDTYPE,1		; window type. 0=small,1=large.
	JE	ANIME_WID_OPEN_LOC_LARGE
	CMP	WIDTYPE,2		; 2=large2
	JE	ANIME_WID_OPEN_LOC_LARGE

	CALL	ASSIGN_SSDES_VRAM	; SSDES0 <=== VRAM
	MOVX	WDX1,WIDFRMXP		; t[¶ãÀWw
	MOVX	WDY1,WIDFRMYP		; t[¶ãÀWx
	CALL_w	WID_FRAME_ANIME_SMALL	; WINDOWS/t[E¬Aj
	RET
ANIME_WID_OPEN_LOC_LARGE:
	CALL	ASSIGN_SSDES_VRAM	; SSDES0 <=== VRAM
	MOVX	WDX1,WIDFRMXP		; t[¶ãÀWw
	MOVX	WDY1,WIDFRMYP		; t[¶ãÀWx
	CALL_w	WID_FRAME_ANIME_LARGE	; WINDOWS/t[EåAj
	RET
ANIME_WID_OPEN_LOC	ENDP


; ****************************************************
;	anime window close.
; ****************************************************

ANIME_WID_CLOSE	PROC	NEAR
	CALL	BACKLOAD		; wiğ[h
	RET
ANIME_WID_CLOSE	ENDP


; ****************************************************
;	restore vram ARA002 -> bank#6 move.
; ****************************************************

BACK_ARA002_TO_BANK6	PROC	NEAR
	CALL	ASSIGN_SSGR_VIRTUAL	; SSGR0 <=== ¼zuq`lv[

	MOV	DX,BACK_2_BANK6		; êŞğGA
	CALL_w	C1PATBNK		; oN`FW

	CALL_w	C1PATCLR		; p[cZbgNA

	MOVX	VRX,BASE_XX2		; window ¶ãw
	MOVX	VRY,BASE_YY2		; window ¶ãx
	MOVX	VRLENX,WIDBAKXL		; window TCYw
	MOVX	VRLENY,WIDBAKYL		; window TCYx
	CALL_w	C1PATGTA		; p[cfds³k³µ

	RET
BACK_ARA002_TO_BANK6	ENDP


; ****************************************************
;	anime window close.(to bank#6)
; ****************************************************

ANIME_WID_CLOSE_BANK6	PROC	NEAR
	CALL_w	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.

	MOV	DX,BACK_2_BANK6		; êŞğGA
	CALL_w	C1PATBNK		; oN`FW

	MOVX	VRX,WIDBAKXP		; wiŞğGA¶ãÀWw
	MOVX	VRY,WIDBAKYP		; wiŞğGA¶ãÀWx
	MOV	CX,NUM			; p[cÔ
	CALL_w	C1PATPTX		; p[cotsÀWwè

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
	MOV	MOVOFSX,CX		; ]ItZbgw
	MOV	MOVOFSY,DX		; ]ItZbgx
	MOV	MOVSIZX,SI		; ]TCYw
	MOV	MOVSIZY,DI		; ]TCYx
	RET
ANIME_WID_SIZE_SET	ENDP


; ****************************************************
;	wiğ[h
;	-I- WIDBAKXP : wiŞğGA¶ãÀWw
;	    WIDBAKYP : wiŞğGA¶ãÀWx
;	    WIDBAKXL : wiŞğGATCYw
;	    WIDBAKYL : wiŞğGATCYx
; ****************************************************

BACKLOAD	PROC	NEAR
	CALL	ASSIGN_SSSOU_VIRTUAL	; SSSOU0 <=== ¼zuq`lv[
	CALL	ASSIGN_SSDES_VRAM	; SSDES0 <=== VRAM

	MOVX	VX1,BASE_XX2		; pictuer base 2 x.
	MOVX	VY1,BASE_YY2		; pictuer base 2 y.
	MOVX	VX2,WIDBAKXL		; wiŞğGATCYw
	MOVX	VY2,WIDBAKYL		; wiŞğGATCYx
	MOVX	VX3,WIDBAKXP		; wiŞğGA¶ãÀWw
	MOVX	VY3,WIDBAKYP		; wiŞğGA¶ãÀWx
	CALL_w	MOVEVR			; vram to vram move.
	RET
BACKLOAD	ENDP


; ****************************************************
;	wiğZ[u
;	-I- WIDBAKXP : wiŞğGA¶ãÀWw
;	    WIDBAKYP : wiŞğGA¶ãÀWx
;	    WIDBAKXL : wiŞğGATCYw
;	    WIDBAKYL : wiŞğGATCYx
; ****************************************************

BACKSAVE	PROC	NEAR
	CALL	ASSIGN_SSSOU_VRAM	; SSSOU <=== VRAM
	CALL	ASSIGN_SSDES_VIRTUAL	; SSDES0 <=== ¼zuq`lv[

	MOVX	VX1,WIDBAKXP		; wiŞğGA¶ãÀWw
	MOVX	VY1,WIDBAKYP		; wiŞğGA¶ãÀWx
	MOVX	VX2,WIDBAKXL		; wiŞğGATCYw
	MOVX	VY2,WIDBAKYL		; wiŞğGATCYx
	MOVX	VX3,BASE_XX2		; pictuer base 2 x.
	MOVX	VY3,BASE_YY2		; pictuer base 2 y.
	CALL_w	MOVEVR			; vram to vram move.
	RET
BACKSAVE	ENDP


; ****************************************************
;	SSGR0 <=== ¼zuq`lv[
; ****************************************************

ASSIGN_SSGR_VIRTUAL	PROC	NEAR
	CMP	WIDTYPE,1		; 1=large
	JE	ASSIGN_SSGR_VIRTUAL_2	;
	CMP	WIDTYPE,2		; 2=large2
	JE	ASSIGN_SSGR_VIRTUAL_2	;
	MOV_ID2	SSGR0,ARA002		; ¼zuq`lv[(width42)
	RET
ASSIGN_SSGR_VIRTUAL_2:
	MOV_ID2	SSGR0,ARA003		; ¼zuq`lv[(width60)
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
;	SSSOU0 <=== ¼zuq`lv[
; ****************************************************

ASSIGN_SSSOU_VIRTUAL	PROC	NEAR
	CMP	WIDTYPE,1		; 1=large
	JE	ASSIGN_SSSOU_VIRTUAL_2	;
	CMP	WIDTYPE,2		; 2=large2
	JE	ASSIGN_SSSOU_VIRTUAL_2	;
	MOV_ID2	SSSOU0,ARA002		; ¼zuq`lv[(width42)
	RET
ASSIGN_SSSOU_VIRTUAL_2:
	MOV_ID2	SSSOU0,ARA003		; ¼zuq`lv[(width60)
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
;	SSDES0 <=== ¼zuq`lv[
; ****************************************************

ASSIGN_SSDES_VIRTUAL	PROC	NEAR
	CMP	WIDTYPE,1		; 1=large
	JE	ASSIGN_SSDES_VIRTUAL_2	;
	CMP	WIDTYPE,2		; 2=large2
	JE	ASSIGN_SSDES_VIRTUAL_2	;
	MOV_ID2	SSDES0,ARA002		; ¼zuq`lv[(width42)
	RET
ASSIGN_SSDES_VIRTUAL_2:
	MOV_ID2	SSDES0,ARA003		; ¼zuq`lv[(width60)
	RET
ASSIGN_SSDES_VIRTUAL	ENDP

WINDOW	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	VRPX:WORD		; fds wÀW
EXTRN	VRPY:WORD		; fds xÀW
EXTRN	VRLENPX:WORD		; fds wTCY
EXTRN	VRLENPY:WORD		; fds xTCY

WIDTYPE		DW	0	; window type. 0=small,1=large,2=large2

WIDIVEXP	DW	0	; EChEGA¶ãÀWw
WIDIVEYP	DW	0	; EChEGA¶ãÀWx
WIDIVEXL	DW	0	; EChEGATCYw
WIDIVEYL	DW	0	; EChEGATCYx

WIDFRMXP	DW	0	; t[¶ãÀWw
WIDFRMYP	DW	0	; t[¶ãÀWx

WIDBAKXP	DW	0	; wiŞğGA¶ãÀWw
WIDBAKYP	DW	0	; wiŞğGA¶ãÀWx
WIDBAKXL	DW	0	; wiŞğGATCYw
WIDBAKYL	DW	0	; wiŞğGATCYx

MOVOFSX		DW	0	; ]ItZbgw
MOVOFSY		DW	0	; ]ItZbgx
MOVSIZX		DW	0	; ]TCYw
MOVSIZY		DW	0	; ]TCYx

CPYOFSX1	DW	0	; ]³ItZbgw
CPYOFSY1	DW	0	; ]³ItZbgx
CPYOFSX2	DW	0	; ]æItZbgw
CPYOFSY2	DW	0	; ]æItZbgx
CPYSIZEX	DW	0	; ]TCYw
CPYSIZEY	DW	0	; ]TCYx

BASE_XX1	DW	0	; pictuer base 1 x.
BASE_YY1	DW	0	; pictuer base 1 y.
BASE_XX2	DW	0	; pictuer base 2 x.
BASE_YY2	DW	200	; pictuer base 2 y.

TBLXP		DW	4,	13,	13	; table ¶ãÀWw
TBLYP		DW	200,	64,	64	; table ¶ãÀWx
TBLXL		DW	40,	54,	54	; table TCYX
TBLYL		DW	128,	180,	180	; table TCYY

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