; "WIDIVENT.ASM" 486/50 make by R.H 1992/05/21
;
;
;	ＷＩＮＤＯＷＳ／イベント・ウインドウ
;
;
;	WIDIVENT		 ; WINDOWS/イベント・ウインドウ
;
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC

NORMAL_BANK	EQU	0		; 通常のパーツバンク番号
IVENTPAT_BANK	EQU	4		; イベントバンク番号
					; #4 通常パターンバッファ前半
BACKSAVE_BANK	EQU	6		; 背景退避用パーツ番号
					; #6 text buffer.後半

MAX_WIDTYPE	EQU	2		; max window type.

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA

; ****************************************************
;	WINDOWS/イベント・ウインドウ
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

	MOV	AX,TBLXP[BX]		; table 左上座標Ｘ
	MOV	WIDIVEXP,AX		; ウインドウエリア左上座標Ｘ
	SUB	AX,2			;
	MOV	WIDBAKXP,AX		; 背景退避エリア左上座標Ｘ
	MOV	WIDFRMXP,AX		; フレーム左上座標Ｘ

	MOV	AX,TBLYP[BX]		; table 左上座標Ｙ
	MOV	WIDIVEYP,AX		; ウインドウエリア左上座標Ｙ
	SUB	AX,8			;
	MOV	WIDBAKYP,AX		; 背景退避エリア左上座標Ｙ
	MOV	WIDFRMYP,AX		; フレーム左上座標Ｙ

	MOV	AX,TBLXL[BX]		; table サイズＸ
	MOV	WIDIVEXL,AX		; ウインドウエリアサイズＸ
	ADD	AX,4	;2		;
	MOV	WIDBAKXL,AX		; 背景退避エリアサイズＸ

	MOV	AX,TBLYL[BX]		; table サイズＹ
	MOV	WIDIVEYL,AX		; ウインドウエリアサイズＹ
	ADD	AX,8*2			;
	MOV	WIDBAKYL,AX		; 背景退避エリアサイズＹ
	RET
WID_LOCATION	ENDP


; ****************************************************
;	ivent window open.
;	-I- FLNM    : file name.
;	    WIDTYPE : window type.
; ****************************************************

IVENT_WID_OPEN	PROC	NEAR
	CALL	WID_LOCATION		; ivent draw init.

	CALL	BACKSAVE		; 背景をセーブ
	MOVX	WDX1,WIDFRMXP		; フレーム左上座標Ｘ
	MOVX	WDY1,WIDFRMYP		; フレーム左上座標Ｙ

	CMP	WIDTYPE,1		; window type. 0=small,1=large.
	JE	IVENT_WID_OPEN_LARGE	;

	MOV	BX,NOWLOAD_BANK		; イベントバンク番号
	CALL_w	WID_FRAME_IVENT_SMALL	; WINDOWS/フレーム・小イベント

	JMP	IVENT_WID_OPEN_PUT

IVENT_WID_OPEN_LARGE:
	MOV	BX,NOWLOAD_BANK		; イベントバンク番号
	CALL_w	WID_FRAME_IVENT_LARGE	; WINDOWS/フレーム・大イベント

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
	CALL	BACKLOAD		; 背景をロード
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
	MOV	NOWLOAD_BANK,IVENTPAT_BANK	; イベントバンク番号
	MOV	NOWSAVE_BANK,BACKSAVE_BANK	; 背景退避用パーツ番号
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
	CALL	BACKLOAD			; 背景をロード
	MOV	NOWSAVE_BANK,BACKSAVE_BANK	; 背景退避用パーツ番号
	RET
IVENT_WID_CLOSE_BK	ENDP


; ****************************************************
;	ivent window open(no save)
;	-I- FLNM    : file name.
;	    WIDTYPE : window type.
; ****************************************************

IVENT_WID_OPN_NOSAV	PROC	NEAR
	CALL	WID_LOCATION		; ivent draw init.

	MOVX	WDX1,WIDFRMXP		; フレーム左上座標Ｘ
	MOVX	WDY1,WIDFRMYP		; フレーム左上座標Ｙ

	CMP	WIDTYPE,1		; window type. 0=small,1=large.
	JE	IVENT_WID_OPN_NOSAV_LARGE

	MOV	BX,NOWLOAD_BANK		; イベントバンク番号
	CALL_w	WID_FRAME_IVENT_SMALL	; WINDOWS/フレーム・小イベント

	JMP	IVENT_WID_OPN_NOSAV_PUT	;

IVENT_WID_OPN_NOSAV_LARGE:
	MOV	BX,NOWLOAD_BANK		; イベントバンク番号
	CALL_w	WID_FRAME_IVENT_LARGE	; WINDOWS/フレーム・大イベント

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
	MOV	TBLXP[BX],AX		; table 左上座標Ｘ
	MOV	TBLYP[BX],DX		; table 左上座標Ｙ
	RET
IVENT_WID_LOC	ENDP


; ****************************************************
;	pictuer load vram.
;	-I- SI : file name.
; ****************************************************

PICLOAD	PROC	NEAR
	MOV	DX,NOWLOAD_BANK		; イベントバンク番号
	CALL_w	PT_PATTERN_LD		; pattern load.

	MOV_ID2	SSGR0,ARAVRM		;

	MOV	AX,WIDIVEXP		; ウインドウエリア左上座標Ｘ
	MOV	BX,WIDIVEYP		; ウインドウエリア左上座標Ｙ
	MOV	DX,0			; pattern number.
	CALL_w	PT_PATTERN_PUT		; pattern put.
	RET
PICLOAD	ENDP

; ****************************************************
;	背景をロード
; ****************************************************

BACKLOAD	PROC	NEAR
	MOV_ID2	SSGR0,ARAVRM		;

	MOV	DX,NOWSAVE_BANK		; 背景退避用パーツ番号
	CALL_w	C1PATBNK		; バンクチェンジ

	MOV	CX,BACKPAT		; 背景退避用パーツ番号
	CALL_w	C1PATPUT		; パーツＰＵＴ

	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ
	RET
BACKLOAD	ENDP


; ****************************************************
;	背景をセーブ
;	-I- WIDBAKXP : 背景退避エリア左上座標Ｘ
;	    WIDBAKYP : 背景退避エリア左上座標Ｙ
;	    WIDBAKXL : 背景退避エリアサイズＸ
;	    WIDBAKYL : 背景退避エリアサイズＹ
; ****************************************************

BACKSAVE	PROC	NEAR
	MOV_ID2	SSGR0,ARAVRM	;

	MOV	DX,NOWSAVE_BANK	; 背景退避用パーツ番号
	CALL_w	C1PATBNK	; バンクチェンジ

	CALL_w	C1PATCLR	; パーツセットクリア

	MOV	AX,WIDBAKXP	; 背景退避エリア左上座標Ｘ
	MOV	VRX,AX		; ＶＲＡＭ　Ｘ座標
	MOV	AX,WIDBAKYP	; 背景退避エリア左上座標Ｙ
	MOV	VRY,AX		; ＶＲＡＭ　Ｙ座標
	MOV	AX,WIDBAKXL	; 背景退避エリアサイズＸ
	MOV	VRLENX,AX	; Ｘ方向長さ
	MOV	AX,WIDBAKYL	; 背景退避エリアサイズＹ
	MOV	VRLENY,AX	; Ｙ方向長さ
	CALL_w	C1PATGTA	; パーツＧＥＴ圧縮無し

	MOV	DX,NORMAL_BANK	; 通常のパーツバンク番号
	CALL_w	C1PATBNK	; バンクチェンジ

	RET
BACKSAVE	ENDP

WINDOW	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

WIDTYPE		DW	0		; window type. 0=small,1=large.

WIDIVEXP	DW	0		; ウインドウエリア左上座標Ｘ
WIDIVEYP	DW	0		; ウインドウエリア左上座標Ｙ
WIDIVEXL	DW	0		; ウインドウエリアサイズＸ
WIDIVEYL	DW	0		; ウインドウエリアサイズＹ

WIDFRMXP	DW	0		; フレーム左上座標Ｘ
WIDFRMYP	DW	0		; フレーム左上座標Ｙ

WIDBAKXP	DW	0		; 背景退避エリア左上座標Ｘ
WIDBAKYP	DW	0		; 背景退避エリア左上座標Ｙ
WIDBAKXL	DW	0		; 背景退避エリアサイズＸ
WIDBAKYL	DW	0		; 背景退避エリアサイズＹ

USER_DL_BANK	DW	0		; diskload bank number.
USER_S_BANK	DW	0		; save bank number.

NOWLOAD_BANK	DW	IVENTPAT_BANK	; イベントバンク番号
NOWSAVE_BANK	DW	BACKSAVE_BANK	; 背景退避用パーツ番号
BACKPAT		DW	0		; 背景退避用パーツ番号

TBLXP		DW	10,	10	; table 左上座標Ｘ
TBLYP		DW	200,	200	; table 左上座標Ｙ
TBLXL		DW	25,	35	; table サイズX
TBLYL		DW	128,	180	; table サイズY

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