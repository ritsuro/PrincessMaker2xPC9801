; "WIDIVENT.ASM" 486/50 make by R.H 1992/05/21
;
;
;	vhmcnvr^CxgEEChE
;
;
;	WIDIVENT		 ; WINDOWS/CxgEEChE
;
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC

NORMAL_BANK	EQU	0		; ÊíÌp[coNÔ
IVENTPAT_BANK	EQU	4		; CxgoNÔ
					; #4 Êíp^[obt@O¼
BACKSAVE_BANK	EQU	6		; wiŞğpp[cÔ
					; #6 text buffer.ã¼

MAX_WIDTYPE	EQU	2		; max window type.

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA

; ****************************************************
;	WINDOWS/CxgEEChE
;	-I- AX : function.
;		=1 : ivent window open.
;		=2 : ivent window close.
;		=3 : ivent window open(no save)
;		=4 : ivent window close(diskload)
;		=5 : ivent window locate.
;			-I- CX : x.
;			    DX : y.
;		=6 : ivent window open.(select bank)
;			-I- CX : save bank number.
;			    DX : diskload bank number.
;		=7 : ivent window close.(select bank)
;			-I- CX : save bank number.
;	    BX : ivent window type. 0=small,1=large
;	    SI : file name.(AX=1)
; ****************************************************

FUNC	WIDIVENT
	CMP	BX,MAX_WIDTYPE		; max window type.
	JNB	WIDIVENT_JMP_EXIT	;

	MOV	WIDTYPE,BX		; window type.
	MOV	USER_S_BANK,CX		; save bank number.
	MOV	USER_DL_BANK,DX		; diskload bank number.

	MOV	LOCX,CX			; locate x.
	MOV	LOCY,DX			; locate y.
	MOV	FLNM,SI			; file name.

	MOV	BX,AX			; function.
	DEC	BX			;
	CMP	BX,(WIDIVENT_JMP_END-WIDIVENT_JMP)/2
	JNB	WIDIVENT_JMP_EXIT	;
	SHL	BX,1			;
	MOVX	ES,<SEG WINDOW>		;
	CALL	WORD PTR ES:WIDIVENT_JMP[BX]

	JMP	WIDIVENT_JMP_EXIT

WIDIVENT_JMP	LABEL	WORD
	DW	IVENT_WID_OPEN		; ivent window open.
	DW	IVENT_WID_CLOSE		; ivent window close.
	DW	IVENT_WID_OPN_NOSAV	; ivent window open(no save)
	DW	IVENT_WID_CLOS_DLD	; ivent window close(diskload)
	DW	IVENT_WID_LOC		; ivent window locate.
	DW	IVENT_WID_OPEN_BK	; ivent window open.(select bank)
	DW	IVENT_WID_CLOSE_BK	; ivent window close.(select bank)
WIDIVENT_JMP_END	LABEL	WORD

WIDIVENT_JMP_EXIT:
	RET
FEND	WIDIVENT


; ****************************************************
;	ivent draw init.
;	-I- WIDTYPE : window type.
; ****************************************************

WID_LOCATION	PROC	NEAR
	CALL_w	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.

	MOV	BX,WIDTYPE		; window type.
	SHL	BX,1			; word pointer.

	MOV	AX,TBLXP[BX]		; table ¶ãÀWw
	MOV	WIDIVEXP,AX		; EChEGA¶ãÀWw
	SUB	AX,2			;
	MOV	WIDBAKXP,AX		; wiŞğGA¶ãÀWw
	MOV	WIDFRMXP,AX		; t[¶ãÀWw

	MOV	AX,TBLYP[BX]		; table ¶ãÀWx
	MOV	WIDIVEYP,AX		; EChEGA¶ãÀWx
	SUB	AX,8			;
	MOV	WIDBAKYP,AX		; wiŞğGA¶ãÀWx
	MOV	WIDFRMYP,AX		; t[¶ãÀWx

	MOV	AX,TBLXL[BX]		; table TCYw
	MOV	WIDIVEXL,AX		; EChEGATCYw
	ADD	AX,4	;2		;
	MOV	WIDBAKXL,AX		; wiŞğGATCYw

	MOV	AX,TBLYL[BX]		; table TCYx
	MOV	WIDIVEYL,AX		; EChEGATCYx
	ADD	AX,8*2			;
	MOV	WIDBAKYL,AX		; wiŞğGATCYx
	RET
WID_LOCATION	ENDP


; ****************************************************
;	ivent window open.
;	-I- FLNM    : file name.
;	    WIDTYPE : window type.
; ****************************************************

IVENT_WID_OPEN	PROC	NEAR
	CALL	WID_LOCATION		; ivent draw init.

	CALL	BACKSAVE		; wiğZ[u
	MOVX	WDX1,WIDFRMXP		; t[¶ãÀWw
	MOVX	WDY1,WIDFRMYP		; t[¶ãÀWx

	CMP	WIDTYPE,1		; window type. 0=small,1=large.
	JE	IVENT_WID_OPEN_LARGE	;

	MOV	BX,NOWLOAD_BANK		; CxgoNÔ
	CALL_w	WID_FRAME_IVENT_SMALL	; WINDOWS/t[E¬Cxg

	JMP	IVENT_WID_OPEN_PUT

IVENT_WID_OPEN_LARGE:
	MOV	BX,NOWLOAD_BANK		; CxgoNÔ
	CALL_w	WID_FRAME_IVENT_LARGE	; WINDOWS/t[EåCxg

IVENT_WID_OPEN_PUT:
	MOV	SI,FLNM			; file name.
	CALL	PICLOAD			; pictuer load vram.
	RET
IVENT_WID_OPEN	ENDP


; ****************************************************
;	ivent window close.
;	-I- WIDTYPE : window type.
; ****************************************************

IVENT_WID_CLOSE	PROC	NEAR
	CALL	WID_LOCATION		; ivent draw init.
	CALL	BACKLOAD		; wiğ[h
	RET
IVENT_WID_CLOSE	ENDP


; ****************************************************
;	ivent window open.(select bank)
;	-I- USER_S_BANK : save bank number.
;	    USER_DL_BANK: diskload bank number.
; ****************************************************

IVENT_WID_OPEN_BK	PROC	NEAR
	MOVX	NOWLOAD_BANK,USER_DL_BANK	; diskload bank number.
	MOVX	NOWSAVE_BANK,USER_S_BANK	; save bank number.
	CALL	IVENT_WID_OPEN			; ivent window open.
	MOV	NOWLOAD_BANK,IVENTPAT_BANK	; CxgoNÔ
	MOV	NOWSAVE_BANK,BACKSAVE_BANK	; wiŞğpp[cÔ
	RET
IVENT_WID_OPEN_BK	ENDP


; ****************************************************
;	ivent window close.(select bank)
;	-I- USER_S_BANK : save bank number.
;	    USER_DL_BANK: diskload bank number.
; ****************************************************

IVENT_WID_CLOSE_BK	PROC	NEAR
	MOVX	NOWSAVE_BANK,USER_S_BANK	; save bank number.
	CALL	WID_LOCATION			; ivent draw init.
	CALL	BACKLOAD			; wiğ[h
	MOV	NOWSAVE_BANK,BACKSAVE_BANK	; wiŞğpp[cÔ
	RET
IVENT_WID_CLOSE_BK	ENDP


; ****************************************************
;	ivent window open(no save)
;	-I- FLNM    : file name.
;	    WIDTYPE : window type.
; ****************************************************

IVENT_WID_OPN_NOSAV	PROC	NEAR
	CALL	WID_LOCATION		; ivent draw init.

	MOVX	WDX1,WIDFRMXP		; t[¶ãÀWw
	MOVX	WDY1,WIDFRMYP		; t[¶ãÀWx

	CMP	WIDTYPE,1		; window type. 0=small,1=large.
	JE	IVENT_WID_OPN_NOSAV_LARGE

	MOV	BX,NOWLOAD_BANK		; CxgoNÔ
	CALL_w	WID_FRAME_IVENT_SMALL	; WINDOWS/t[E¬Cxg

	JMP	IVENT_WID_OPN_NOSAV_PUT	;

IVENT_WID_OPN_NOSAV_LARGE:
	MOV	BX,NOWLOAD_BANK		; CxgoNÔ
	CALL_w	WID_FRAME_IVENT_LARGE	; WINDOWS/t[EåCxg

IVENT_WID_OPN_NOSAV_PUT:
	MOV	SI,FLNM			; file name.
	CALL	PICLOAD			; pictuer load vram.
	RET
IVENT_WID_OPN_NOSAV	ENDP


; ****************************************************
;	ivent window close(diskload)
;	-I- WIDTYPE : window type.
; ****************************************************

IVENT_WID_CLOS_DLD	PROC	NEAR
;;;;	CALL	WID_LOCATION		; ivent draw init.
	RET
IVENT_WID_CLOS_DLD	ENDP


; ****************************************************
;	ivent window locate.
;	-I- WIDTYPE : window type.
;	    LOCX    : locate x.
;	    LOCY    : locate y.
; ****************************************************

IVENT_WID_LOC	PROC	NEAR
	MOV	BX,WIDTYPE		; window type.
	SHL	BX,1			; word pointer.
	MOV	AX,LOCX			; locate x.
	MOV	DX,LOCY			; locate y.
	MOV	TBLXP[BX],AX		; table ¶ãÀWw
	MOV	TBLYP[BX],DX		; table ¶ãÀWx
	RET
IVENT_WID_LOC	ENDP


; ****************************************************
;	pictuer load vram.
;	-I- SI : file name.
; ****************************************************

PICLOAD	PROC	NEAR
	MOV	DX,NOWLOAD_BANK		; CxgoNÔ
	CALL_w	PT_PATTERN_LD		; pattern load.

	MOV_ID2	SSGR0,ARAVRM		;

	MOV	AX,WIDIVEXP		; EChEGA¶ãÀWw
	MOV	BX,WIDIVEYP		; EChEGA¶ãÀWx
	MOV	DX,0			; pattern number.
	CALL_w	PT_PATTERN_PUT		; pattern put.
	RET
PICLOAD	ENDP

; ****************************************************
;	wiğ[h
; ****************************************************

BACKLOAD	PROC	NEAR
	MOV_ID2	SSGR0,ARAVRM		;

	MOV	DX,NOWSAVE_BANK		; wiŞğpp[cÔ
	CALL_w	C1PATBNK		; oN`FW

	MOV	CX,BACKPAT		; wiŞğpp[cÔ
	CALL_w	C1PATPUT		; p[cots

	MOV	DX,NORMAL_BANK		; ÊíÌp[coNÔ
	CALL_w	C1PATBNK		; oN`FW
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
	MOV_ID2	SSGR0,ARAVRM	;

	MOV	DX,NOWSAVE_BANK	; wiŞğpp[cÔ
	CALL_w	C1PATBNK	; oN`FW

	CALL_w	C1PATCLR	; p[cZbgNA

	MOV	AX,WIDBAKXP	; wiŞğGA¶ãÀWw
	MOV	VRX,AX		; uq`l@wÀW
	MOV	AX,WIDBAKYP	; wiŞğGA¶ãÀWx
	MOV	VRY,AX		; uq`l@xÀW
	MOV	AX,WIDBAKXL	; wiŞğGATCYw
	MOV	VRLENX,AX	; wûü·³
	MOV	AX,WIDBAKYL	; wiŞğGATCYx
	MOV	VRLENY,AX	; xûü·³
	CALL_w	C1PATGTA	; p[cfds³k³µ

	MOV	DX,NORMAL_BANK	; ÊíÌp[coNÔ
	CALL_w	C1PATBNK	; oN`FW

	RET
BACKSAVE	ENDP

WINDOW	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

WIDTYPE		DW	0		; window type. 0=small,1=large.

WIDIVEXP	DW	0		; EChEGA¶ãÀWw
WIDIVEYP	DW	0		; EChEGA¶ãÀWx
WIDIVEXL	DW	0		; EChEGATCYw
WIDIVEYL	DW	0		; EChEGATCYx

WIDFRMXP	DW	0		; t[¶ãÀWw
WIDFRMYP	DW	0		; t[¶ãÀWx

WIDBAKXP	DW	0		; wiŞğGA¶ãÀWw
WIDBAKYP	DW	0		; wiŞğGA¶ãÀWx
WIDBAKXL	DW	0		; wiŞğGATCYw
WIDBAKYL	DW	0		; wiŞğGATCYx

USER_DL_BANK	DW	0		; diskload bank number.
USER_S_BANK	DW	0		; save bank number.

NOWLOAD_BANK	DW	IVENTPAT_BANK	; CxgoNÔ
NOWSAVE_BANK	DW	BACKSAVE_BANK	; wiŞğpp[cÔ
BACKPAT		DW	0		; wiŞğpp[cÔ

TBLXP		DW	10,	10	; table ¶ãÀWw
TBLYP		DW	200,	200	; table ¶ãÀWx
TBLXL		DW	25,	35	; table TCYX
TBLYL		DW	128,	180	; table TCYY

FLNM		DW	0	; file name.
LOCX		DW	0	; locate x.
LOCY		DW	0	; locate y.
XX1		DW	0	; x1.
YY1		DW	0	; y1.
NNUM		DW	0	; number.

DATA	ENDS

	END
;
;	end of "WIDIVENT.ASM"
;
