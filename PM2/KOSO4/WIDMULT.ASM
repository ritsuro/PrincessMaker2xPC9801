; "WIDMULT.ASM" 486/50 make by R.H 1992/05/21
;
;
;	ＷＩＮＤＯＷＳ／マルチアイテム・ウインドウ
;
;
;	WIDMULT			; WINDOWS/マルチアイテム
;	WIDMULT2N		; WINDOWS/マルチアイテム２
;	WIDMULT2NCLEAR		; WINDOWS/マルチアイテム２CLAER
;	WIDMULT3OPEN		; WINDOWS/マルチアイテム表示
;	WIDMULT3CLOSE		; WINDOWS/マルチアイテム復帰
;	WIDMULTTP5XY		; WINDOWS/マルチアイテム TYPE 5 位置
;	WIDMULTCANONOFF		; WINDOWS/マルチアイテムｷｬﾝｾﾙON/OFF
;	WIDMULTFNCONOFF		; WINDOWS/マルチアイテムﾌｧﾝｸｼｮﾝON/OFF
;	WIDMULTCURONOFF		; WINDOWS/マルチアイテムｶﾚﾝﾄﾍﾟｰｼﾞON/OFF
;
;
;	TYPE 1	道具、武器
;
;		[    ] [　名前　]
;		[    ] [ＧＯＬＤ]
;		[攻]9999 [技]9999
;
;		ITEMID_TBL1[] : 名前
;		ITEMID_TBL2[] : ＩＣＯＮ
;		ITEMID_TBL3[] : 金
;		ITEMID_TBL4[] : 文字１
;		ITEMID_TBL5[] : パラメータ値１
;		ITEMID_TBL6[] : 文字２
;		ITEMID_TBL7[] : パラメータ値２
;
;	TYPE 2	鍛える
;
;		[    ] [　名前　]
;		[    ] [初級][Ｇ]
;
;		ITEMID_TBL1[] : 名前
;		ITEMID_TBL2[] : ＩＣＯＮ
;		ITEMID_TBL3[] : 金
;		ITEMID_TBL4[] : 文字１
;
;	TYPE 3	アルバイト
;
;		[    ] [　名前　]
;		[    ] [ＧＯＬＤ]
;
;		ITEMID_TBL1[] : 名前
;		ITEMID_TBL2[] : ＩＣＯＮ
;		ITEMID_TBL3[] : 金
;
;	TYPE 4	休息・武者修行など
;
;		[    ] [　名前　]
;		[    ] [ＧＯＬＤ]
;
;		ITEMID_TBL1[] : 名前
;		ITEMID_TBL2[] : ＩＣＯＮ
;		ITEMID_TBL3[] : （金／表示無し）
;		ITEMID_TBL4[] : 文字１
;
;	TYPE 5	道具、武器（任意の位置へ）
;
;		[    ] [　名前　]
;		[    ] [ＧＯＬＤ]
;		[攻]9999 [技]9999
;
;		ITEMID_TBL1[] : 名前
;		ITEMID_TBL2[] : ＩＣＯＮ
;		ITEMID_TBL3[] : 金
;		ITEMID_TBL4[] : 文字１
;		ITEMID_TBL5[] : パラメータ値１
;		ITEMID_TBL6[] : 文字２
;		ITEMID_TBL7[] : パラメータ値２
;
;
;
;	max=13
;
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC

TYPE_MAX	EQU	5	; window type max.
PAGE_MAX	EQU	5	; window page max.

STRING_LEN 	EQU	255	; string length.
STR_VAL_LEN 	EQU	6	; string length.（数値表示用）

NORMAL_BANK	EQU	0	; 通常のパーツバンク番号
BACKSAVE_BANK	EQU	0	; 背景退避用パーツバンク番号

OFFF		EQU	0FFFFH	; とりあえずＯＦＦという意味

WDT1_SIZ_X	EQU	19;16	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 サイズＸ
WDT1_SIZ_Y	EQU	62	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 サイズＹ
WDT2_SIZ_X	EQU	16	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 サイズＸ
WDT2_SIZ_Y	EQU	42	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 サイズＹ
WDT3_SIZ_X	EQU	16	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 サイズＸ
WDT3_SIZ_Y	EQU	42	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 サイズＹ
WDT4_SIZ_X	EQU	16	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 サイズＸ
WDT4_SIZ_Y	EQU	42	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 サイズＹ
WDT5_SIZ_X	EQU	19	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 5 サイズＸ
WDT5_SIZ_Y	EQU	62	; フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 5 サイズＹ

WDCN_SIZ_X	EQU	11	; フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel サイズＸ
WDCN_SIZ_Y	EQU	32	; フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel サイズＹ
WDEX_SIZ_X	EQU	11	; フレーム・ﾏﾙﾁｱｲﾃﾑ・拡張ｺﾏﾝﾄﾞ ｻｲｽﾞX
WDEX_SIZ_Y	EQU	32	; フレーム・ﾏﾙﾁｱｲﾃﾑ・拡張ｺﾏﾝﾄﾞ ｻｲｽﾞY
WDFC_SIZ_X	EQU	11	; フレーム・ﾏﾙﾁｱｲﾃﾑ・拡張function ｻｲｽﾞX
WDFC_SIZ_Y	EQU	32	; フレーム・ﾏﾙﾁｱｲﾃﾑ・拡張function ｻｲｽﾞY

WD_EXP_SIZ_X	EQU	13	; 拡張ｺﾏﾝﾄﾞ 待避ｻｲｽﾞX
WD_EXP_SIZ_Y	EQU	38	; 拡張ｺﾏﾝﾄﾞ 待避ｻｲｽﾞY
WD_CANC_SIZE_X	EQU	13	; cancel 待避サイズＸ
WD_CANC_SIZE_Y	EQU	38	; cancel 待避サイズＹ
WD_FUNC_SIZE_X	EQU	13	; function 待避サイズＸ
WD_FUNC_SIZE_Y	EQU	38	; function 待避サイズＹ

WD_FUNC_LOC_X	EQU	2	; function位置Ｘ
WD_FUNC_LOC_Y	EQU	160	; function位置Ｙ

;;WD_EXP_X	DW	0,0		; window expand x.
;;WD_EXP_Y	DW	0,0		; window expand y.

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA

; ****************************************************
;	WINDOWS/マルチアイテム
;	-I- ITEMID_TBL1[] : アイテムＩＤテーブル／名前
;	    ITEMID_TBL2[] : アイテムＩＤテーブル／ＩＣＯＮ
;	    ITEMID_TBL3[] : アイテムＩＤテーブル／金
;	    ITEMID_TBL4[] : アイテムＩＤテーブル／文字１
;	    ITEMID_TBL5[] : アイテムＩＤテーブル／パラメータ値１
;	    ITEMID_TBL6[] : アイテムＩＤテーブル／文字２
;	    ITEMID_TBL7[] : アイテムＩＤテーブル／パラメータ値２
;	    ITEMID_CNT    : アイテムＩＤ数
;	    DX            : ウインドウＯＰＥＮタイプ
;			   1=道具、武器
;			   2=鍛える
;			   3=アルバイト
;			   4=休息
;	-O- WIDINM        : アイテム選択番号
;			  : =FFFFH : 指定なし
;			  : =-2    : 武器外す
;			  : =-3    : 防具外す
; ****************************************************

FUNC	WIDMULT
	MOV	WIDTYPE,DX		; window type.

	CALL_w	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.

	CALL	WIDOPEN			; ウインドウＯＰＥＮ

	CALL	WIDMAIN			; ウインドウＭＡＩＮ

	CALL	WIDCLOSE		; ウインドウＣＬＯＳＥ

	MOVX	WIDINM,SLCT_NUMBER	; 選択番号
	RET
FEND	WIDMULT


; ****************************************************
;	WINDOWS/マルチアイテム２
;	選択アイテム残して背景復帰
;
;	-I- ITEMID_TBL1[] : アイテムＩＤテーブル／名前
;	    ITEMID_TBL2[] : アイテムＩＤテーブル／ＩＣＯＮ
;	    ITEMID_TBL3[] : アイテムＩＤテーブル／金
;	    ITEMID_TBL4[] : アイテムＩＤテーブル／文字１
;	    ITEMID_TBL5[] : アイテムＩＤテーブル／パラメータ値１
;	    ITEMID_TBL6[] : アイテムＩＤテーブル／文字２
;	    ITEMID_TBL7[] : アイテムＩＤテーブル／パラメータ値２
;	    ITEMID_CNT    : アイテムＩＤ数
;	    DX            : ウインドウＯＰＥＮタイプ
;			   1=道具、武器
;			   2=鍛える
;			   3=アルバイト
;			   4=休息
;	-O- WIDINM        : アイテム選択番号
;			  : =FFFFH : 指定なし
;			  : =-2    : 武器外す
;			  : =-3    : 防具外す
; ****************************************************

FUNC	WIDMULT2N
	MOV	WIDTYPE,DX		; window type.

	CALL_w	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.

	CALL	WIDOPEN			; ウインドウＯＰＥＮ

	CALL	WIDMAIN			; ウインドウＭＡＩＮ

	CALL	BACK_S_LOAD		; 選択アイテム残して背景復帰

	MOVX	WIDINM,SLCT_NUMBER	; 選択番号
	RET
FEND	WIDMULT2N


; ****************************************************
;	WINDOWS/マルチアイテム２CLAER
; ****************************************************

FUNC	WIDMULT2NCLEAR
	CALL_w	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.
	CALL	BACK_SLCT_LOAD		; 選択アイテム背景復帰
	RET
FEND	WIDMULT2NCLEAR


; ****************************************************
;	WINDOWS/マルチアイテム表示
;	-I- ITEMID_TBL1[] : アイテムＩＤテーブル／名前
;	    ITEMID_TBL2[] : アイテムＩＤテーブル／ＩＣＯＮ
;	    ITEMID_TBL3[] : アイテムＩＤテーブル／金
;	    ITEMID_TBL4[] : アイテムＩＤテーブル／文字１
;	    ITEMID_TBL5[] : アイテムＩＤテーブル／パラメータ値１
;	    ITEMID_TBL6[] : アイテムＩＤテーブル／文字２
;	    ITEMID_TBL7[] : アイテムＩＤテーブル／パラメータ値２
;	    ITEMID_CNT    : アイテムＩＤ数
;	    DX            : ウインドウＯＰＥＮタイプ
;			   1=道具、武器
;			   2=鍛える
;			   3=アルバイト
;			   4=休息
;			   5=道具、武器（任意の位置へ）
; ****************************************************

FUNC	WIDMULT3OPEN
	PUSH	FLAG_CANCEL_EN
	MOV	FLAG_CANCEL_EN,0	; flag キャンセルウインドウ
	MOV	WIDTYPE,DX		; window type.
	CALL_w	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.
	CALL	WIDOPEN			; ウインドウＯＰＥＮ
	POP	FLAG_CANCEL_EN
	RET
FEND	WIDMULT3OPEN


; ****************************************************
;	WINDOWS/マルチアイテム復帰
; ****************************************************

FUNC	WIDMULT3CLOSE
	CALL	WIDCLOSE		; ウインドウＣＬＯＳＥ
	RET
FEND	WIDMULT3CLOSE


; ****************************************************
;	WINDOWS/マルチアイテム TYPE 5 位置
;	-I- AX : Ｘ座標
;	    BX : Ｙ座標
; ****************************************************

FUNC	WIDMULTTP5XY
	MOV	WID5LOCX,AX		; window start point x.
	MOV	WID5LOCY,BX		; window start point y.
	RET
FEND	WIDMULTTP5XY


; ****************************************************
;	WINDOWS/マルチアイテムｷｬﾝｾﾙON/OFF
;	-I- AX : flag キャンセルウインドウ
; ****************************************************

FUNC	WIDMULTCANONOFF
	MOV	FLAG_CANCEL_EN,AX	; flag キャンセルウインドウ
	RET
FEND	WIDMULTCANONOFF


; ****************************************************
;	WINDOWS/マルチアイテムﾌｧﾝｸｼｮﾝON/OFF
;	-I- AX : flag 拡張ｺﾏﾝﾄﾞウインドウ
; ****************************************************

FUNC	WIDMULTFNCONOFF
	MOV	FLAG_EXPFNC_EN,AX	; flag 拡張functionウインドウ
	RET
FEND	WIDMULTFNCONOFF


; ****************************************************
;	WINDOWS/マルチアイテムｶﾚﾝﾄﾍﾟｰｼﾞON/OFF
;	-I- AX : flag page current.
; ****************************************************

FUNC	WIDMULTCURONOFF
	MOV	FLAG_PAGECUR_EN,AX	; flag page current.
	MOV	PAGE_CURRENT,0		; page current.
	RET
FEND	WIDMULTCURONOFF


; ****************************************************
;	ウインドウＯＰＥＮ
;	-I- ITEMID_TBL1[] : アイテムＩＤテーブル／名前
;	    ITEMID_TBL2[] : アイテムＩＤテーブル／ＩＣＯＮ
;	    ITEMID_TBL3[] : アイテムＩＤテーブル／金
;	    ITEMID_TBL4[] : アイテムＩＤテーブル／文字１
;	    ITEMID_TBL5[] : アイテムＩＤテーブル／パラメータ値１
;	    ITEMID_TBL6[] : アイテムＩＤテーブル／文字２
;	    ITEMID_TBL7[] : アイテムＩＤテーブル／パラメータ値２
;	    ITEMID_CNT    : アイテムＩＤ数
;	    WIDTYPE       : window type.
; ****************************************************

WIDOPEN	PROC	NEAR
	CMP	ITEMID_CNT,0		; アイテムＩＤ数
	JMPEQ	WIDOPEN_EXIT		;

	CMP	WIDTYPE,2		; window type.
	JE	WIDOPEN_1		;
	CMP	WIDTYPE,3		; window type.
	JE	WIDOPEN_1		;
	CMP	WIDTYPE,4		; window type.
	JE	WIDOPEN_1		;
	JMP	WIDOPEN_2		;
WIDOPEN_1:				;
	CALL	TYPE2LOCCALC		; window type 2,3,4 location.
WIDOPEN_2:				;

	CALL	PAGE_SET		; page set.

	MOV	WIDLOCTBLMAX,0		; window locate table max.

	MOV	BX,WIDTYPE		; window type.
	DEC	BX			;
	SHL	BX,1			; word pointer.
	MOVX	WIDLOCADRS_X,WIDLOCTBLX_AD[BX]	; window locx table adrs.
	MOVX	WIDLOCADRS_Y,WIDLOCTBLY_AD[BX]	; window locy table adrs.
	MOVX	WIDAREAXX,WIDAREA_TBLXX[BX]	; window area length x.
	MOVX	WIDAREAYY,WIDAREA_TBLYY[BX]	; window area length y.

	CALL	ALL_AREA_BACK		; 全エリア退避

	CALL	WIDSHOW			; window show.


	MOVX	LOCCOUNT,PAGE_RECMAX[0]	; window show count.

;	flag キャンセルウインドウ

	CMP	FLAG_CANCEL_EN,0	; flag キャンセルウインドウ
	JE	WIDOPEN_777		;
	CALL	LOC_XY			; location xy.
	ADD	AX,5			; +5
	ADD	BX,6			; +6
	MOV	WDX1,AX			; window cancel x.
	MOV	WDY1,BX			; window cancel y.
	CALL	CANCEL_OPEN		; cancel window open.
	INC	COUNTER			; counter.
	INC	LOCCOUNT		; location counter.
WIDOPEN_777:				;

;	flag 拡張ｺﾏﾝﾄﾞウインドウ

	CMP	FLAG_EXPCMD_EN,0	; flag 拡張ｺﾏﾝﾄﾞウインドウ
	JE	WIDOPEN_8		;
	CALL	LOC_XY			; location xy.
	ADD	AX,5			; +5
	SUB	BX,6			; -6
	MOV	WIDEXP_X[0],AX		; window expand x.
	MOV	WIDEXP_Y[0],BX		; window expand y.
	ADD	BX,34			; +34
	MOV	WIDEXP_X[2],AX		; window expand x.
	MOV	WIDEXP_Y[2],BX		; window expand y.
	CALL	EXPEND_OPEN		; expend window open.
	INC	COUNTER			; counter.
	INC	LOCCOUNT		; location counter.
WIDOPEN_8:				;

;	flag 拡張functionウインドウ

	CMP	FLAG_EXPFNC_EN,0	; flag 拡張functionウインドウ
	JE	WIDOPEN_85		;

	MOV	AX,WD_FUNC_LOC_X	; function位置Ｘ
	MOV	BX,WD_FUNC_LOC_Y	; function位置Ｙ
	MOV	WIDEXFC_X[0],AX		; window expand function x.
	MOV	WIDEXFC_Y[0],BX		; window expand function y.
	ADD	BX,34			; +34
	MOV	WIDEXFC_X[2],AX		; window expand function x.
	MOV	WIDEXFC_Y[2],BX		; window expand function y.
	CALL	EXPFNC_OPEN		; exp function window open.
WIDOPEN_85:				;

WIDOPEN_EXIT:
	RET
WIDOPEN	ENDP


; ****************************************************
;	window show.
;	-I- WIDSHOWCNT : window show count.
;	    WIDSHOWBASE: window show base.
; ****************************************************

WIDSHOW	PROC	NEAR
	MOVX	COUNTER,WIDSHOWBASE	; window show base.
	MOV	LOCCOUNT,0		; location counter.

	MOV	WIDLOCTBLMAX,0		; window locate table max.

	MOV	BX,WIDTYPE		; window type.
	DEC	BX			;
	SHL	BX,1			; word pointer.
	MOV	CX,WIDSHOWCNT		; window show count.
	CMP	CX,WIDAREA_TBLMAX[BX]	; window area table max.
	JBE	WIDSHOW_LOOP		;
	MOV	CX,WIDAREA_TBLMAX[BX]	; window area table max.
WIDSHOW_LOOP:
	PUSH	CX

	CALL	LOC_XY			; location xy.

	MOV	BX,COUNTER		; counter.
	SHL	BX,1			; word pointer.
	MOVX	IPARATBL[2],ITEMID_TBL1[BX]  ; ＩＤテーブル／名前
	MOVX	IPARATBL[0],ITEMID_TBL2[BX]  ; ＩＤテーブル／ＩＣＯＮ
	MOVX	IPARATBL[4],ITEMID_TBL3[BX]  ; ＩＤテーブル／金
	MOVX	IPARATBL[8],ITEMID_TBL4[BX]  ; ＩＤテーブル／文字１
	MOVX	IPARATBL[10],ITEMID_TBL5[BX] ; ＩＤテーブル／パラメータ値１
	MOVX	IPARATBL[12],ITEMID_TBL6[BX] ; ＩＤテーブル／文字２
	MOVX	IPARATBL[14],ITEMID_TBL7[BX] ; ＩＤテーブル／パラメータ値２

	MOV	IPARATBL[6],1		; ﾊﾟﾗﾒｰﾀ数 1or2
	CMP	IPARATBL[14],0		; ＩＤテーブル／パラメータ値２
	JE	WIDSHOW_6		;
	MOV	IPARATBL[6],2		; ﾊﾟﾗﾒｰﾀ数 1or2
WIDSHOW_6:
	MOVX	WDX1,LOCX		; x.
	MOVX	WDY1,LOCY		; y.
	CALL	ITEMOPEN		; １アイテム・ウインドウＯＰＥＮ

	CMPX	WIDLOCTBLMAX,WIDLOCTBLDIM ; window locate table max.
	JNB	WIDSHOW_7		;

	MOV	BX,WIDLOCTBLMAX		; window locate table max.
	SHL	BX,1			; word pointer.
	MOVX	WIDLOCTBLXX[BX],LOCX	; window locate x table.
	MOVX	WIDLOCTBLYY[BX],LOCY	; window locate y table.

	INC	WIDLOCTBLMAX		; window locate table max.
WIDSHOW_7:				;
	INC	COUNTER			; counter.
	INC	LOCCOUNT		; location counter.

	POP	CX
	LOOPX	WIDSHOW_LOOP

	RET
WIDSHOW	ENDP


; ****************************************************
;	window type 2,3,4 location.
;	-I- ITEMID_CNT    : アイテムＩＤ数
; ****************************************************

TYPE2LOCCALC	PROC	NEAR
	MOV	AX,ITEMID_CNT		; アイテムＩＤ数
	CMP	AX,6
	JLE	TYPE2LOCCALC_6UND
	CMP	AX,8
	JLE	TYPE2LOCCALC_8UND
	CMP	AX,10
	JLE	TYPE2LOCCALC_10UND
	CMP	AX,12
	JLE	TYPE2LOCCALC_12UND
	JMP	TYPE2LOCCALC_14UND
TYPE2LOCCALC_6UND:
	MOV	DX,60+48*3
	JMP	TYPE2LOCCALC_SET
TYPE2LOCCALC_8UND:
	MOV	DX,60+48*2
	JMP	TYPE2LOCCALC_SET
TYPE2LOCCALC_10UND:
	MOV	DX,60+48
	JMP	TYPE2LOCCALC_SET
TYPE2LOCCALC_12UND:
	MOV	DX,60
	JMP	TYPE2LOCCALC_SET
TYPE2LOCCALC_14UND:
	MOV	DX,60-48
TYPE2LOCCALC_SET:			;
	MOV	BX,0			; word pointer.
	MOV	CX,16/2			;
TYPE2LOCCALC_LOOP:			;
	MOV	WID2LOCY[BX],DX		; window start point y.
	INC	BX			;
	INC	BX			;
	MOV	WID2LOCY[BX],DX		; window start point y.
	INC	BX			;
	INC	BX			;
	ADD	DX,48			;
	LOOP	TYPE2LOCCALC_LOOP	;
	RET
TYPE2LOCCALC	ENDP


;;TYPE2LOCCALC	PROC	NEAR
;;	MOV	AX,ITEMID_CNT		; アイテムＩＤ数
;;	INC	AX			; + 1
;;	SHR	AX,1			; / 2   ( AX=段数 )
;;
;;	MOV	BX,18			;
;;	MUL	BX			; AX = AX * 18
;;
;;	MOV	DX,156			; DX = 156 - AX
;;	SUB	DX,AX			;
;;
;;	MOV	BX,0			; word pointer.
;;	MOV	CX,16/2			;
;;TYPE2LOCCALC_LOOP:			;
;;	MOV	WID2LOCY[BX],DX		; window start point y.
;;	INC	BX			;
;;	INC	BX			;
;;	MOV	WID2LOCY[BX],DX		; window start point y.
;;	INC	BX			;
;;	INC	BX			;
;;	ADD	DX,48			;
;;	LOOP	TYPE2LOCCALC_LOOP	;
;;	RET
;;TYPE2LOCCALC	ENDP


; ****************************************************
;	page set.
; ****************************************************

PAGE_SET	PROC	NEAR
	MOV	FLAG_EXPCMD_EN,0	; flag 拡張ｺﾏﾝﾄﾞウインドウ

	CMP	ITEMID_CNT,0		;
	JE	PAGE_SET_NONE		;

	MOV	BX,WIDTYPE		; window type.
	DEC	BX			;
	SHL	BX,1			; word pointer.
	MOV	CX,WIDAREA_MAX[BX]	; window area window max.
	JCXZ	PAGE_SET_NONE		;
	MOV	WIDSHOWITM,CX		; window max.

	MOV	DX,0			;
	MOV	AX,ITEMID_CNT		; dx = item count MOD window max
	DIV	CX			; ax = item count / window max

	MOV	PAGE_COUNT,AX		; page count.
	MOV	CX,AX			;
	MOV	SI,0			; word pointer.
	MOV	BX,0			; record number.
	JCXZ	PAGE_SET_6		;
PAGE_SET_LOOP:
	MOV	PAGE_RECTBL[SI],BX	; page top record table.
	MOVX	PAGE_RECMAX[SI],WIDSHOWITM	; window max.
	ADD	BX,WIDSHOWITM		; record number + window max.
	INC	SI			;
	INC	SI			;
	LOOP	PAGE_SET_LOOP		;
PAGE_SET_6:
	CMP	DX,0			;
	JE	PAGE_SET_7		;
	INC	PAGE_COUNT		; page count.
	MOV	PAGE_RECTBL[SI],BX	; page top record table.
	MOV	PAGE_RECMAX[SI],DX	; window max.
PAGE_SET_7:


	CMP	FLAG_PAGECUR_EN,0	; flag page current.
	JE	PAGE_SET_73		;
	CMPX	PAGE_CURRENT,PAGE_COUNT	; page count.
	JB	PAGE_SET_74		;
PAGE_SET_73:
	MOV	PAGE_CURRENT,0		; page current.
PAGE_SET_74:


	MOV	BX,PAGE_CURRENT			; page current.
	SHL	BX,1				; word pointer.
	MOVX	WIDSHOWCNT,PAGE_RECMAX[BX]	; window show count.
	MOVX	WIDSHOWBASE,PAGE_RECTBL[BX]	; window show base.

	CMP	PAGE_COUNT,1		; page count.
	JBE	PAGE_SET_8		;
	MOV	FLAG_EXPCMD_EN,1	; flag 拡張ｺﾏﾝﾄﾞウインドウ
PAGE_SET_8:
	RET
PAGE_SET_NONE:
	RET
PAGE_SET	ENDP


; ****************************************************
;	page up.
; ****************************************************

PAGE_UP	PROC	NEAR
	MOV	AX,PAGE_CURRENT		; page count.
	INC	AX			;
	CMP	AX,PAGE_COUNT		; page count.
	JE	PAGE_UP_EXIT		;
	INC	PAGE_CURRENT		; page current.
	CALL	PAGE_REDRAW		; page redraw.
PAGE_UP_EXIT:
	RET
PAGE_UP	ENDP


; ****************************************************
;	page down.
; ****************************************************

PAGE_DOWN	PROC	NEAR
	CMP	PAGE_CURRENT,0		; page count.
	JE	PAGE_DOWN_EXIT		;
	DEC	PAGE_CURRENT		; page current.
	CALL	PAGE_REDRAW		; page redraw.
PAGE_DOWN_EXIT:
	RET
PAGE_DOWN	ENDP


; ****************************************************
;	page redraw.
; ****************************************************

PAGE_REDRAW	PROC	NEAR
	CALL	BACK_LOAD_EXP			; 拡張コマンド残して背景復帰
	MOV	BX,PAGE_CURRENT			; page current.
	SHL	BX,1				; word pointer.
	MOVX	WIDSHOWBASE,PAGE_RECTBL[BX]	; page top record table.
	MOVX	WIDSHOWCNT,PAGE_RECMAX[BX]	; page record max table.
	CALL	WIDSHOW				; window show.
	RET
PAGE_REDRAW	ENDP
        

; ****************************************************
;	location xy.
;	-I- LOCCOUNT: location counter.
;	-O- LOCX    : 表示位置Ｘ
;	    LOCY    : 表示位置Ｙ
;	    AX      : 表示位置Ｘ
;	    BX      : 表示位置Ｙ
; ****************************************************

LOC_XY	PROC	NEAR
	MOV	BX,LOCCOUNT		; location counter.
	SHL	BX,1			; word pointer.
	MOV	SI,WIDLOCADRS_X		; window locx table adrs.
	MOV	DI,WIDLOCADRS_Y		; window locy table adrs.
	MOVX	LOCX,DS:[SI][BX]	; 表示位置Ｘ
	MOVX	LOCY,DS:[DI][BX]	; 表示位置Ｙ

	MOV	AX,LOCX			; 表示位置Ｘ
	MOV	BX,LOCY			; 表示位置Ｙ
	RET
LOC_XY	ENDP


; ****************************************************
;	ウインドウＣＬＯＳＥ
; ****************************************************

WIDCLOSE	PROC	NEAR
	CALL	BACK_LOAD		; 背景復帰
	RET
WIDCLOSE	ENDP


; ****************************************************
;	ウインドウＭＡＩＮ
;	-O- SLCT_NUMBER	: 選択番号
;			: =FFFFH : 指定なし
;			: =-2    : 武器外す
;			: =-3    : 防具外す
; ****************************************************

WIDMAIN	PROC	NEAR
	MOV	SLCT_NUMBER,OFFF	; 選択番号
	MOV	NOWLOC_NUMBER,OFFF	; 選択表示中番号

	MOV	NOWNUM_EXPCMD,OFFF	; 表示中拡張ｺﾏﾝﾄﾞ番号
	MOV	NOWNUM_EXPFNC,OFFF	; 表示中拡張function番号

	MOV	NUM_EXPCMD,OFFF		; 拡張ｺﾏﾝﾄﾞ番号
	MOV	NUM_EXPFNC,OFFF		; 拡張function番号

	CALL_w	MSCSRT			; カーソルスタート

	CMP	WIDMDEMO,55		; デモフラグ0=通常,55=ランダムセレクト
	JE	WIDMAIN_DEMO		;
WIDMAIN_LOOP:
	CALL_w	MSCMOV			; カーソル移動
	MOV	MOUSEX,AX		; マウスＸ座標
	MOV	MOUSEY,BX		; マウスＹ座標
	MOV	MOUSEBTN_L,DH		; マウス左ボタン（1：ＯＦＦ／0：ＯＮ）
	MOV	MOUSEBTN_R,DL		; マウス右ボタン（1：ＯＦＦ／0：ＯＮ）

	CALL	LOC_CHECK		; ロケーション・チェック
	CALL	LOC_CURSOLE		; ロケーションカーソル

	CMP	FLAG_EXPCMD_EN,0	; flag 拡張ｺﾏﾝﾄﾞウインドウ
	JE	WIDMAIN_2		;
	CALL	LOC_EXPCK		; ロケーション・チェック(拡張ｺﾏﾝﾄﾞ)
	CALL	LOC_EXPSOLE		; ロケーションカーソル(拡張ｺﾏﾝﾄﾞ)
	CALL	CHK_EXPCMD		; チェック拡張コマンド
WIDMAIN_2:

	CMP	FLAG_EXPFNC_EN,0	; flag 拡張functionウインドウ
	JE	WIDMAIN_24		;
	CALL	LOC_FNC			; ロケーション・チェック(拡張function)
	CALL	LOC_FNCSOLE		; ロケーションカーソル(拡張function)
	CMP	NOWNUM_EXPFNC,OFFF	; 表示中拡張function番号
	JE	WIDMAIN_24		;
	CMP	MOUSEBTN_L,0		; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	JNE	WIDMAIN_24		;

	MOV	AX,NOWNUM_EXPFNC	; 表示中拡張function番号
	ADD	AX,2			;
	NEG	AX			;
	MOV	SLCT_NUMBER,AX		; 選択番号
	CALL_w	MSCSTP			; カーソルストップ
	JMP	WIDMAIN_EXIT2		;
WIDMAIN_24:

	CALL	LOC_CANCEL		; キャンセルチェック
	CMP	AX,1			; 0=normal,1=cancel.
	JE	WIDMAIN_ESCAPE		;

	CMP	SLCT_NUMBER,OFFF	; 選択番号
	JE	WIDMAIN_3		;
	CMP	MOUSEBTN_L,0		; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	WIDMAIN_EXIT		;
WIDMAIN_3:				;
	CMP	MOUSEBTN_R,0		; 右ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	WIDMAIN_ESCAPE		;

	JMP	WIDMAIN_LOOP

WIDMAIN_DEMO:
	MOV	AX,WIDMDEMOWAIT		; デモ 待ち時間
	CALL_w	TMVWAT			; V-SYNC timer wait.

	MOV	AX,WIDLOCTBLMAX		; window locate table max.
	INC	AX			; + 1 (escape)
	CALL_w	RANDAM			; 乱数範囲指定
	DEC	AX			; -1
	CMP	AX,WIDLOCTBLMAX		; window locate table max.
	JE	WIDMAIN_DEMO5		;
	MOV	SLCT_NUMBER,AX		; 選択番号
	MOV	NOWLOC_NUMBER,AX	; 選択表示中番号
	JMP	WIDMAIN_EXIT		;
WIDMAIN_DEMO5:				;
	MOV	SLCT_NUMBER,OFFF	; 選択番号
	JMP	WIDMAIN_ESCAPE		;

WIDMAIN_EXIT:
	MOV	AX,PAGE_CURRENT		; page current.
	MUL	WIDSHOWITM		; window show item.
	ADD	SLCT_NUMBER,AX		; 選択番号
	CALL_w	MSCSTP			; カーソルストップ
	CALL	LOC_05BRINK		; ロケーション数秒強調
WIDMAIN_EXIT2:
	RET
WIDMAIN_ESCAPE:
	MOV	SLCT_NUMBER,OFFF	; 選択番号
	CALL	LOC_CURSOLE		; ロケーションカーソル
	CALL_w	MSCSTP			; カーソルストップ
	RET
WIDMAIN	ENDP


; ****************************************************
;	ロケーション・チェック
;	-I- MOUSEX      : マウスＸ座標
;	    MOUSEY      : マウスＹ座標
;	-O- SLCT_NUMBER : 選択番号
; ****************************************************

LOC_CHECK	PROC	NEAR
	MOV	BX,PAGE_CURRENT			; page current.
	SHL	BX,1				; word pointer.
	MOVX	WIDLOCTBLMAX,PAGE_RECMAX[BX]	; page record max table.

	MOV	SLCT_NUMBER,0			; 選択番号
	MOV	CX,WIDLOCTBLMAX			; window locate table max.
LOC_CHECK_LOOP:
	MOV	AX,MOUSEX			; マウスＸ座標
	MOV	DX,MOUSEY			; マウスＹ座標

	MOV	BX,SLCT_NUMBER			; 選択番号
	SHL	BX,1				; word pointer.
	SUB	AX,WIDLOCTBLXX[BX]		; window locate x table.
	JB	LOC_CHECK_NEXT			;
	SUB	DX,WIDLOCTBLYY[BX]		; window locate y table.
	JB	LOC_CHECK_NEXT			;
	CMP	AX,WIDAREAXX			; window area length x.
	JNBE	LOC_CHECK_NEXT			;
	CMP	DX,WIDAREAYY			; window area length y.
	JNBE	LOC_CHECK_NEXT			;

	JMP	LOC_CHECK_HIT

LOC_CHECK_NEXT:
	INC	SLCT_NUMBER			; 選択番号
	LOOP	LOC_CHECK_LOOP
LOC_CHECK_NONE:
	MOV	SLCT_NUMBER,OFFF		; 選択番号
	RET
LOC_CHECK_HIT:
	RET
LOC_CHECK	ENDP


; ****************************************************
;	ロケーションカーソル
;	-I- SLCT_NUMBER   : 選択番号
;	    NOWLOC_NUMBER : 選択表示中番号
; ****************************************************

LOC_CURSOLE	PROC	NEAR
	CMPX	NOWLOC_NUMBER,SLCT_NUMBER	; 選択番号
	JE	LOC_CURSOLE_EXIT		;

	CALL_w	MSCSTP				; カーソルストップ

	CMP	NOWLOC_NUMBER,OFFF		; 選択表示中番号
	JE	LOC_CURSOLE_ON			;

	MOV	BX,NOWLOC_NUMBER		; 選択表示中番号
	SHL	BX,1				; word pointer.
	MOVX	WDX1,WIDLOCTBLXX[BX]		; window locate x table.
	MOVX	WDY1,WIDLOCTBLYY[BX]		; window locate y table.
	CALL	BRINK_OFF			; ブリンクＯＦＦ

LOC_CURSOLE_ON:
	CMP	SLCT_NUMBER,OFFF		; 選択番号
	JE	LOC_CURSOLE_88			;

	MOV	BX,SLCT_NUMBER			; 選択番号
	SHL	BX,1				; word pointer.
	MOVX	WDX1,WIDLOCTBLXX[BX]		; window locate x table.
	MOVX	WDY1,WIDLOCTBLYY[BX]		; window locate y table.
	CALL	BRINK_ON			; ブリンクＯＮ

LOC_CURSOLE_88:
	CALL_w	MSCSRT				; カーソルスタート

LOC_CURSOLE_EXIT:
	MOVX	NOWLOC_NUMBER,SLCT_NUMBER	; 選択番号
	RET
LOC_CURSOLE	ENDP


; ****************************************************
;	ロケーション・チェック(拡張ｺﾏﾝﾄﾞ)
;	-I- MOUSEX      : マウスＸ座標
;	    MOUSEY      : マウスＹ座標
;	-O- NUM_EXPCMD  : 拡張ｺﾏﾝﾄﾞ番号
; ****************************************************

LOC_EXPCK	PROC	NEAR
	MOV	NUM_EXPCMD,0			; 拡張ｺﾏﾝﾄﾞ番号

	MOV	CX,CMDEXP_CNT			; 拡張ｺﾏﾝﾄﾞ数
LOC_EXPCK_LOOP:
	MOV	AX,MOUSEX			; マウスＸ座標
	MOV	DX,MOUSEY			; マウスＹ座標

	MOV	BX,NUM_EXPCMD			; 拡張ｺﾏﾝﾄﾞ番号
	SHL	BX,1				; word pointer.

	CMP	WIDEXP_FLAG[BX],0		; window expand disable flag.
	JNE	LOC_EXPCK_NEXT			;

	SUB	AX,WIDEXP_X[BX]		; window expand x.
	JB	LOC_EXPCK_NEXT		;
	SUB	DX,WIDEXP_Y[BX]		; window expand y.
	JB	LOC_EXPCK_NEXT		;
	CMP	AX,WDEX_SIZ_X		; フレーム・ﾏﾙﾁｱｲﾃﾑ・拡張ｺﾏﾝﾄﾞ ｻｲｽﾞX
	JNBE	LOC_EXPCK_NEXT		;
	CMP	DX,WDEX_SIZ_Y		; フレーム・ﾏﾙﾁｱｲﾃﾑ・拡張ｺﾏﾝﾄﾞ ｻｲｽﾞY
	JNBE	LOC_EXPCK_NEXT		;

	JMP	LOC_EXPCK_HIT

LOC_EXPCK_NEXT:
	INC	NUM_EXPCMD			; 拡張ｺﾏﾝﾄﾞ番号
	LOOP	LOC_EXPCK_LOOP
LOC_EXPCK_NONE:
	MOV	NUM_EXPCMD,OFFF			; 拡張ｺﾏﾝﾄﾞ番号
	RET
LOC_EXPCK_HIT:
	RET
LOC_EXPCK	ENDP


; ****************************************************
;	ロケーションカーソル(拡張ｺﾏﾝﾄﾞ)
;	-I- NUM_EXPCMD    : 拡張ｺﾏﾝﾄﾞ番号
;	    NOWNUM_EXPCMD : 表示中拡張ｺﾏﾝﾄﾞ番号
; ****************************************************

LOC_EXPSOLE	PROC	NEAR
	CMPX	NUM_EXPCMD,NOWNUM_EXPCMD	; 表示中拡張ｺﾏﾝﾄﾞ番号
	JE	LOC_EXPSOLE_EXIT		;

	CALL_w	MSCSTP				; カーソルストップ

	CMP	NOWNUM_EXPCMD,OFFF		; 表示中拡張ｺﾏﾝﾄﾞ番号
	JE	LOC_EXPSOLE_ON			;

	MOV	BX,NOWNUM_EXPCMD		; 表示中拡張ｺﾏﾝﾄﾞ番号
	SHL	BX,1				; word pointer.
	MOVX	WDX1,WIDEXP_X[BX]		; window expand x.
	MOVX	WDY1,WIDEXP_Y[BX]		; window expand y.
	CALL_w	WID_FLAME_MULT_CANCEL_OFF	; cancel OFF

LOC_EXPSOLE_ON:
	CMP	NUM_EXPCMD,OFFF			; 拡張ｺﾏﾝﾄﾞ番号
	JE	LOC_EXPSOLE_88			;

	MOV	BX,NUM_EXPCMD			; 拡張ｺﾏﾝﾄﾞ番号
	SHL	BX,1				; word pointer.
	MOVX	WDX1,WIDEXP_X[BX]		; window expand x.
	MOVX	WDY1,WIDEXP_Y[BX]		; window expand y.
	CALL_w	WID_FLAME_MULT_CANCEL_ON  	; cancel ON

LOC_EXPSOLE_88:
	CALL_w	MSCSRT				; カーソルスタート

LOC_EXPSOLE_EXIT:
	MOVX	NOWNUM_EXPCMD,NUM_EXPCMD	; 表示中拡張ｺﾏﾝﾄﾞ番号
	RET
LOC_EXPSOLE	ENDP


; ****************************************************
;	ロケーション・チェック(拡張function)
;	-I- MOUSEX      : マウスＸ座標
;	    MOUSEY      : マウスＹ座標
;	-O- NUM_EXPFNC  : 拡張function番号
; ****************************************************

LOC_FNC	PROC	NEAR
	MOV	NUM_EXPFNC,0			; 拡張function番号

	MOV	CX,EXPFNC_CNT			; 拡張function数
LOC_FNC_LOOP:
	MOV	AX,MOUSEX			; マウスＸ座標
	MOV	DX,MOUSEY			; マウスＹ座標

	MOV	BX,NUM_EXPFNC		; 拡張function番号
	SHL	BX,1			; word pointer.
	SUB	AX,WIDEXFC_X[BX]	; window expand function x.
	JB	LOC_FNC_NEXT		;
	SUB	DX,WIDEXFC_Y[BX]	; window expand function y.
	JB	LOC_FNC_NEXT		;
	CMP	AX,WDFC_SIZ_X		; フレーム・ﾏﾙﾁｱｲﾃﾑ・拡張function ｻｲｽﾞX
	JNBE	LOC_FNC_NEXT		;
	CMP	DX,WDFC_SIZ_Y		; フレーム・ﾏﾙﾁｱｲﾃﾑ・拡張function ｻｲｽﾞY
	JNBE	LOC_FNC_NEXT		;

	JMP	LOC_FNC_HIT
LOC_FNC_NEXT:
	INC	NUM_EXPFNC			; 拡張function番号
	LOOP	LOC_FNC_LOOP
LOC_FNC_NONE:
	MOV	NUM_EXPFNC,OFFF			; 拡張function番号
	RET
LOC_FNC_HIT:
	RET
LOC_FNC	ENDP


; ****************************************************
;	ロケーションカーソル(拡張function)
;	-I- NUM_EXPFNC    : 拡張function番号
;	    NOWNUM_EXPFNC : 表示中拡張function番号
; ****************************************************

LOC_FNCSOLE	PROC	NEAR
	CMPX	NUM_EXPFNC,NOWNUM_EXPFNC	; 表示中拡張function番号
	JE	LOC_FNCSOLE_EXIT		;

	CALL_w	MSCSTP				; カーソルストップ

	CMP	NOWNUM_EXPFNC,OFFF		; 表示中拡張function番号
	JE	LOC_FNCSOLE_ON			;

	MOV	BX,NOWNUM_EXPFNC		; 表示中拡張function番号
	SHL	BX,1				; word pointer.
	MOVX	WDX1,WIDEXFC_X[BX]		; window expand function x.
	MOVX	WDY1,WIDEXFC_Y[BX]		; window expand function y.
	CALL_w	WID_FLAME_MULT_CANCEL_OFF	; cancel OFF

LOC_FNCSOLE_ON:
	CMP	NUM_EXPFNC,OFFF			; 拡張function番号
	JE	LOC_FNCSOLE_88			;

	MOV	BX,NUM_EXPFNC			; 拡張function番号
	SHL	BX,1				; word pointer.
	MOVX	WDX1,WIDEXFC_X[BX]		; window expand function x.
	MOVX	WDY1,WIDEXFC_Y[BX]		; window expand function y.
	CALL_w	WID_FLAME_MULT_CANCEL_ON  	; cancel ON

LOC_FNCSOLE_88:
	CALL_w	MSCSRT				; カーソルスタート

LOC_FNCSOLE_EXIT:
	MOVX	NOWNUM_EXPFNC,NUM_EXPFNC	; 表示中拡張function番号
	RET
LOC_FNCSOLE	ENDP


; ****************************************************
;	チェック拡張コマンド
; ****************************************************

CHK_EXPCMD	PROC	NEAR
	CMP	MOUSEBTN_L,1		; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	CHK_EXPCMD_SKIP		;

	CALL_w	MSCSTP			; カーソルストップ

	CMP	NUM_EXPCMD,0		; 拡張ｺﾏﾝﾄﾞ番号
	JE	CHK_EXPCMD_DOWN		;
	CMP	NUM_EXPCMD,1		; 拡張ｺﾏﾝﾄﾞ番号
	JE	CHK_EXPCMD_UP		;
	JMP	CHK_EXPCMD_SKIP		;
	RET
CHK_EXPCMD_UP:
	CALL	PAGE_UP			; page up.
	JMP	CHK_EXPCMD_FINALE	;
CHK_EXPCMD_DOWN:
	CALL	PAGE_DOWN		; page down.
	JMP	CHK_EXPCMD_FINALE	;
CHK_EXPCMD_FINALE:

	CALL_w	MSCSRT			; カーソルスタート

	CALL_w	MUSWAT			; マウスボタンＯＦＦ待ち

CHK_EXPCMD_SKIP:
	RET
CHK_EXPCMD	ENDP


; ****************************************************
;	キャンセルチェック
;	-I- SLCT_NUMBER : 選択番号
;	    MOUSEX      : マウスＸ座標
;	    MOUSEY      : マウスＹ座標
;	    MOUSEBTN_L  : マウス左ボタン（1：ＯＦＦ／0：ＯＮ）
;	    MOUSEBTN_R  : マウス右ボタン（1：ＯＦＦ／0：ＯＮ）
;	-O- AX : 0=normal,1=cancel.
; ****************************************************

LOC_CANCEL	PROC	NEAR
	CMP	FLAG_CANCEL_EN,0		; flag キャンセルウインドウ
	JE	LOC_CANCEL_NORMAL		;
	CMP	SLCT_NUMBER,OFFF		; 選択番号
	JNE	LOC_CANCEL_ERASE		;

	MOV	AX,MOUSEX			; マウスＸ座標
	MOV	DX,MOUSEY			; マウスＹ座標

	SUB	AX,WIDCAN_X			; window cancel x.
	JB	LOC_CANCEL_ERASE		;
	SUB	DX,WIDCAN_Y			; window cancel y.
	JB	LOC_CANCEL_ERASE		;
	CMP	AX,WIDCAN_XL			; window cancel size x.
	JNBE	LOC_CANCEL_ERASE		;
	CMP	DX,WIDCAN_YL			; window cancel size y.
	JNBE	LOC_CANCEL_ERASE		;

	CMP	FLAG_NOW_CANCEL,0		; キャンセル状態
	JNE	LOC_CANCEL_CHK			;

	MOV	FLAG_NOW_CANCEL,1		; キャンセル状態

	MOVX	WDX1,WIDCAN_X			; window cancel x.
	MOVX	WDY1,WIDCAN_Y			; window cancel y.
	CALL_w	MSCSTP				; カーソルストップ
	CALL_w	WID_FLAME_MULT_CANCEL_ON  	; cancel ON
	CALL_w	MSCSRT				; カーソルスタート

LOC_CANCEL_CHK:
	CMP	MOUSEBTN_L,0			; マウス左ボタン(1:OFF/0:ON)
	JE	LOC_CANCEL_CANCEL		;
	CMP	MOUSEBTN_R,0			; マウス右ボタン(1:OFF/0:ON)
	JE	LOC_CANCEL_CANCEL		;
	JMP	LOC_CANCEL_NORMAL		;

LOC_CANCEL_ERASE:				;
	CMP	FLAG_NOW_CANCEL,0		; キャンセル状態
	JE	LOC_CANCEL_NORMAL		;
	MOV	FLAG_NOW_CANCEL,0		; キャンセル状態
	MOVX	WDX1,WIDCAN_X			; window cancel x.
	MOVX	WDY1,WIDCAN_Y			; window cancel y.
	CALL_w	MSCSTP				; カーソルストップ
	CALL_w	WID_FLAME_MULT_CANCEL_OFF	; cancel OFF
	CALL_w	MSCSRT				; カーソルスタート
LOC_CANCEL_NORMAL:				;
	MOV	AX,0				; 0=normal.
	RET
LOC_CANCEL_CANCEL:
	MOV	AX,1				; 1=cancel.
	RET
LOC_CANCEL	ENDP


; ****************************************************
;	ロケーション数秒強調
;	-I- SLCT_NUMBER   : 選択番号
;	    NOWLOC_NUMBER : 選択表示中番号
; ****************************************************

LOC_05BRINK	PROC	NEAR
	CMP	SLCT_NUMBER,OFFF		; 選択番号
	JE	LOC_05BRINK_EXIT		;

	MOV	BX,NOWLOC_NUMBER		; 選択表示中番号
	SHL	BX,1				; word pointer.
	MOVX	WDX1,WIDLOCTBLXX[BX]		; window locate x table.
	MOVX	WDY1,WIDLOCTBLYY[BX]		; window locate y table.

	MOV	CX,2;4				;
LOC_05BRINK_LOOP:				;
	PUSH	CX				;

	MOV	AX,6;10				; wait timer count.
	CALL_w	TMVSET				; V-SYNC timer set.
	CALL	BRINK_OFF			; ブリンクＯＦＦ
	CALL_w	TMVEWT				; V-SYNC timer end wait.

	MOV	AX,6;10				; wait timer count.
	CALL_w	TMVSET				; V-SYNC timer set.
	CALL	BRINK_ON			; ブリンクＯＮ
	CALL_w	TMVEWT				; V-SYNC timer end wait.

	POP	CX				;
	LOOP	LOC_05BRINK_LOOP		;

	CALL	BRINK_OFF			; ブリンクＯＦＦ

LOC_05BRINK_EXIT:
	RET
LOC_05BRINK	ENDP


; ****************************************************
;	ブリンクＯＮ
; ****************************************************

BRINK_ON	PROC	NEAR
	CMP	WIDTYPE,1		; window type.
	JE	BRINK_ON_TYP1		;
	CMP	WIDTYPE,2		; window type.
	JE	BRINK_ON_TYP2		;
	CMP	WIDTYPE,3		; window type.
	JE	BRINK_ON_TYP3		;
	CMP	WIDTYPE,4		; window type.
	JE	BRINK_ON_TYP4		;
	CMP	WIDTYPE,5		; window type.
	JE	BRINK_ON_TYP1		;
	RET
BRINK_ON_TYP1:
	CALL_w	WID_FLAME_MULT_TYP1_ON	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 ON
	RET
BRINK_ON_TYP2:
	CALL_w	WID_FLAME_MULT_TYP2_ON	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 ON
	RET
BRINK_ON_TYP3:
	CALL_w	WID_FLAME_MULT_TYP3_ON	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 ON
	RET
BRINK_ON_TYP4:
	CALL_w	WID_FLAME_MULT_TYP4_ON	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 ON
	RET
BRINK_ON	ENDP


; ****************************************************
;	ブリンクＯＦＦ
; ****************************************************

BRINK_OFF	PROC	NEAR
	CMP	WIDTYPE,1		; window type.
	JE	BRINK_OFF_TYP1		;
	CMP	WIDTYPE,2		; window type.
	JE	BRINK_OFF_TYP2		;
	CMP	WIDTYPE,3		; window type.
	JE	BRINK_OFF_TYP3		;
	CMP	WIDTYPE,4		; window type.
	JE	BRINK_OFF_TYP4		;
	CMP	WIDTYPE,5		; window type.
	JE	BRINK_OFF_TYP1		;
	RET
BRINK_OFF_TYP1:
	CALL_w	WID_FLAME_MULT_TYP1_OFF	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1 OFF
	RET
BRINK_OFF_TYP2:
	CALL_w	WID_FLAME_MULT_TYP2_OFF	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2 OFF
	RET
BRINK_OFF_TYP3:
	CALL_w	WID_FLAME_MULT_TYP3_OFF	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3 OFF
	RET
BRINK_OFF_TYP4:
	CALL_w	WID_FLAME_MULT_TYP4_OFF	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4 OFF
	RET
BRINK_OFF	ENDP


; ****************************************************
;	全エリア退避
; ****************************************************

ALL_AREA_BACK	PROC	NEAR
	MOV	DX,BACKSAVE_BANK	; 背景退避用パーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	CALL_w	C1PATCLR		; パーツセットクリア

	MOV	BACK_COUNT,0		; back save count.

	MOV	BX,WIDTYPE		; window type.
	DEC	BX			;
	SHL	BX,1			; word pointer.
	MOV	CX,PAGE_RECMAX[0]	; page record max table.
	CMP	CX,WIDAREA_TBLMAX[BX]	; window area table max.
	JBE	ALL_AREA_BACK_LOOP00	;
	MOV	CX,WIDAREA_TBLMAX[BX]	; window area table max.
ALL_AREA_BACK_LOOP00:			;
	PUSH	CX			;

	MOVX	LOCCOUNT,BACK_COUNT	; back save count.
	CALL	LOC_XY			; location xy.
	MOVX	WDX1,AX			; 表示位置Ｘ
	MOVX	WDY1,BX			; 表示位置Ｙ
	CALL	BACK_SAVE		; 背景退避

	POP	CX			;
	LOOP	ALL_AREA_BACK_LOOP00	;

	MOVX	LOCCOUNT,PAGE_RECMAX[0]	; window show count.

;	flag キャンセルウインドウ

	CMP	FLAG_CANCEL_EN,0	; flag キャンセルウインドウ
	JE	ALL_AREA_BACK_6		;

	CALL	LOC_XY			; location xy.
	ADD	AX,5			; +5
	ADD	BX,6			; +6
	MOVX	WDX1,AX			; 表示位置Ｘ
	MOVX	WDY1,BX			; 表示位置Ｙ
	MOV	WDX2,WD_CANC_SIZE_X	; cancel 待避サイズＸ
	MOV	WDY2,WD_CANC_SIZE_Y	; cancel 待避サイズＹ
	CALL	BACK_SAVE_SZ		; 背景退避(ｻｲｽﾞ指定)
	INC	LOCCOUNT		; location counter.
ALL_AREA_BACK_6:

	CMP	FLAG_EXPCMD_EN,0	; flag 拡張ｺﾏﾝﾄﾞウインドウ
	JE	ALL_AREA_BACK_7		;

	MOVX	WDX2,WD_EXP_SIZ_X	; 拡張ｺﾏﾝﾄﾞ 待避ｻｲｽﾞX
	MOVX	WDY2,WD_EXP_SIZ_Y	; 拡張ｺﾏﾝﾄﾞ 待避ｻｲｽﾞY

	CALL	LOC_XY			; location xy.
	ADD	AX,5			; +5
	SUB	BX,6			; -6
	MOVX	WDX1,AX			; 表示位置Ｘ
	MOVX	WDY1,BX			; 表示位置Ｙ
	CALL	BACK_SAVE_SZ		; 背景退避(ｻｲｽﾞ指定)
	ADD	WDY1,34			; 表示位置Ｙ
	CALL	BACK_SAVE_SZ		; 背景退避(ｻｲｽﾞ指定)
	INC	LOCCOUNT		; location counter.
ALL_AREA_BACK_7:

	CMP	FLAG_EXPFNC_EN,0	; flag 拡張functionウインドウ
	JE	ALL_AREA_BACK_8		;

	MOVX	WDX2,WD_FUNC_SIZE_X	; function 待避サイズＸ
	MOVX	WDY2,WD_FUNC_SIZE_Y	; function 待避サイズＹ

	MOV	AX,WD_FUNC_LOC_X	; function位置Ｘ
	MOV	BX,WD_FUNC_LOC_Y	; function位置Ｙ
	MOVX	WDX1,AX			; 表示位置Ｘ
	MOVX	WDY1,BX			; 表示位置Ｙ
	CALL	BACK_SAVE_SZ		; 背景退避(ｻｲｽﾞ指定)
	ADD	WDY1,34			; 表示位置Ｙ
	CALL	BACK_SAVE_SZ		; 背景退避(ｻｲｽﾞ指定)
	INC	LOCCOUNT		; location counter.
ALL_AREA_BACK_8:

ALL_AREA_BACK_EXIT:
	RET
ALL_AREA_BACK	ENDP


; ****************************************************
;	１アイテム・ウインドウＯＰＥＮ
;	    IPARATBL[0]  : ＩＣＯＮ番号
;	    IPARATBL[2]  : 名前
;	    IPARATBL[4]  : ＧＯＬＤ
;	    IPARATBL[6]  : ﾊﾟﾗﾒｰﾀ数 1or2
;	    IPARATBL[8]  : ﾊﾟﾗﾒｰﾀ名前 1
;	    IPARATBL[10] : ﾊﾟﾗﾒｰﾀ値 1
;	    IPARATBL[12] : ﾊﾟﾗﾒｰﾀ名前 2
;	    IPARATBL[14] : ﾊﾟﾗﾒｰﾀ値 2
;	    WIDTYPE      : window type.
;	    WDX1         : window locate x table.
;	    WDY1         : window locate y table.
; ****************************************************

ITEMOPEN	PROC	NEAR
	CMP	WIDTYPE,1		; window type.
	JE	ITEMOPEN_1T		;
	CMP	WIDTYPE,2		; window type.
	JE	ITEMOPEN_2T		;
	CMP	WIDTYPE,3		; window type.
	JE	ITEMOPEN_3T		;
	CMP	WIDTYPE,4		; window type.
	JE	ITEMOPEN_4T		;
	CMP	WIDTYPE,5		; window type.
	JE	ITEMOPEN_1T		;
	RET
ITEMOPEN_1T:
	CALL_w	WID_FLAME_MULT_TYPE1	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 1
	RET
ITEMOPEN_2T:
	CALL_w	WID_FLAME_MULT_TYPE2	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 2
	RET
ITEMOPEN_3T:
	CALL_w	WID_FLAME_MULT_TYPE3	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 3
	RET
ITEMOPEN_4T:
	CALL_w	WID_FLAME_MULT_TYPE4	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・TYPE 4
	RET
ITEMOPEN	ENDP


; ****************************************************
;	cancel window open.
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
; ****************************************************

CANCEL_OPEN	PROC	NEAR
	MOVX	WIDCAN_X,WDX1		; window cancel x.
	MOVX	WIDCAN_Y,WDY1		; window cancel y.
	MOV	SI,DEF_MSG_CANCEL	; cancel message.
	CALL_w	WID_FLAME_MULT_CANCEL	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel
	RET
CANCEL_OPEN	ENDP


; ****************************************************
;	expend window open.
; ****************************************************

EXPEND_OPEN	PROC	NEAR
	MOV	BX,0			; word pointer.
	MOV	CX,CMDEXP_CNT		; 拡張ｺﾏﾝﾄﾞ数
EXPEND_OPEN_LOOP:			;
	PUSH	CX			;
	PUSH	BX			;
	CMP	WIDEXP_FLAG[BX],0	; window expand disable flag.
	JNE	EXPEND_OPEN_NEXT	;

	MOVX	WDX1,WIDEXP_X[BX]	; window expand x.
	MOVX	WDY1,WIDEXP_Y[BX]	; window expand y.
	MOV	SI,DEF_MSG_EXPAND[BX]	; expand message.
	CALL_w	WID_FLAME_MULT_CANCEL	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel

EXPEND_OPEN_NEXT:
	POP	BX
	INC	BX
	INC	BX
	POP	CX
	LOOP	EXPEND_OPEN_LOOP

	RET
EXPEND_OPEN	ENDP


; ****************************************************
;	exp function window open.
; ****************************************************

EXPFNC_OPEN	PROC	NEAR
	MOV	BX,0			; word pointer.
	MOV	CX,EXPFNC_CNT		; 拡張function数
EXPFNC_OPEN_LOOP:			;
	PUSH	CX			;
	PUSH	BX			;

	MOVX	WDX1,WIDEXFC_X[BX]	; window expand function x.
	MOVX	WDY1,WIDEXFC_Y[BX]	; window expand function y.
	MOV	SI,DEF_MSG_EXPFNC[BX]	; exp function message.
	CALL_w	WID_FLAME_MULT_CANCEL	; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel

EXPFNC_OPEN_NEXT:
	POP	BX
	INC	BX
	INC	BX
	POP	CX
	LOOP	EXPFNC_OPEN_LOOP

	RET
EXPFNC_OPEN	ENDP


;	WID_FLAME_MULT_CANCEL_ON  ; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel ON
;	WID_FLAME_MULT_CANCEL_OFF ; WINDOWS/フレーム・ﾏﾙﾁｱｲﾃﾑ・cancel OFF

; ****************************************************
;	背景退避
;	-I- WDX1    : window locate x table.
;	    WDY1    : window locate y table.
;	    WIDTYPE : window type.
; ****************************************************

BACK_SAVE	PROC	NEAR
	MOV	DX,BACKSAVE_BANK	; 背景退避用パーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	MOVX	VRX,WDX1		; window locate x table.
	MOVX	VRY,WDY1		; window locate y table.

	MOV	BX,WIDTYPE		; window type.
	DEC	BX			;
	SHL	BX,1			; word pointer.
	MOVX	VRLENX,WIDBAK_TBL_XL[BX] ; window back 1size tbl x.
	MOVX	VRLENY,WIDBAK_TBL_YL[BX] ; window back 1size tbl y.

	CALL_w	C1PATGTA		; パーツＧＥＴ圧縮無し

	INC	BACK_COUNT		; back save count.

	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	RET
BACK_SAVE	ENDP


; ****************************************************
;	背景退避(ｻｲｽﾞ指定)
;	-I- WDX1 : locate x.
;	    WDY1 : locate y.
;	    WDX2 : size x.
;	    WDY2 : size y.
; ****************************************************

BACK_SAVE_SZ	PROC	NEAR
	MOV	DX,BACKSAVE_BANK	; 背景退避用パーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	MOVX	VRX,WDX1		; window locate x table.
	MOVX	VRY,WDY1		; window locate y table.
	MOVX	VRLENX,WDX2		; size x.
	MOVX	VRLENY,WDY2		; size y.
	CALL_w	C1PATGTA		; パーツＧＥＴ圧縮無し

	INC	BACK_COUNT		; back save count.

	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	RET
BACK_SAVE_SZ	ENDP


; ****************************************************
;	背景復帰
; ****************************************************

BACK_LOAD	PROC	NEAR
	MOV	DX,BACKSAVE_BANK	; 背景退避用パーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	MOV	DX,0			;
	MOV	CX,BACK_COUNT		; back save count.
BACK_LOAD_LOOP:				;
	PUSH	CX			;
	PUSH	DX			;
	MOV	CX,DX			; パーツ番号
	CALL_w	C1PATPUT		; パーツＰＵＴ
	POP	DX			;
	INC	DX			;
	POP	CX			;
	LOOP	BACK_LOAD_LOOP		;

	RET
BACK_LOAD	ENDP


; ****************************************************
;	拡張コマンド残して背景復帰
; ****************************************************

BACK_LOAD_EXP	PROC	NEAR
	MOV	DX,BACKSAVE_BANK	; 背景退避用パーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	MOV	DX,0			;
	MOV	CX,WIDSHOWITM		; window show item.
BACK_LOAD_EXP_LOOP:			;
	PUSH	CX			;
	PUSH	DX			;
	MOV	CX,DX			; パーツ番号
	CALL_w	C1PATPUT		; パーツＰＵＴ
	POP	DX			;
	INC	DX			;
	POP	CX			;
	LOOP	BACK_LOAD_EXP_LOOP	;

	RET
BACK_LOAD_EXP	ENDP


; ****************************************************
;	選択アイテム残して背景復帰
; ****************************************************

BACK_S_LOAD	PROC	NEAR
	MOV	DX,BACKSAVE_BANK	; 背景退避用パーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	MOV	SI,PAGE_CURRENT		; page current.
	SHL	SI,1			; word pointer.
	MOV	BX,SLCT_NUMBER		; 選択番号
	SUB	BX,PAGE_RECTBL[SI]	; page top record table.

	MOV	DX,0			;
	MOV	CX,BACK_COUNT		; back save count.
BACK_S_LOAD_LOOP:			;
	PUSH	BX			;
	PUSH	CX			;
	PUSH	DX			;
	CMP	DX,BX			; 選択番号
	JE	BACK_S_LOAD_NEXT	;
	MOV	CX,DX			; パーツ番号
	CALL_w	C1PATPUT		; パーツＰＵＴ
BACK_S_LOAD_NEXT:
	POP	DX			;
	INC	DX			;
	POP	CX			;
	POP	BX			;
	LOOP	BACK_S_LOAD_LOOP	;

	MOV	CX,BX			; 残す先頭のパーツ番号
	CALL_w	C1PATTPD		; 先頭パターンデータの削除

	RET
BACK_S_LOAD	ENDP


; ****************************************************
;	選択アイテム背景復帰
; ****************************************************

BACK_SLCT_LOAD	PROC	NEAR
	MOV	DX,BACKSAVE_BANK	; 背景退避用パーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ
	MOV	CX,0			;
	CALL_w	C1PATPUT		; パーツＰＵＴ
	RET
BACK_SLCT_LOAD	ENDP



WINDOW	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	WIDINM				;アイテム選択番号

PUBLIC	WIDMDEMO			; (WIDMULT.ASM)デモフラグ
					; 0=通常,55=ランダムセレクト
PUBLIC	WIDMDEMOWAIT			; (WIDMULT.ASM)デモ 待ち時間

EXTRN	DEF_MSG_CANCEL:WORD		; cancel message.
EXTRN	DEF_MSG_EXPAND:WORD		; expand message.
EXTRN	DEF_MSG_EXPFNC:WORD		; exp function message.

EXTRN	PRSOFS:WORD			; パーツバッファのカレントポインタ
EXTRN	PRSSIZ:WORD			; パーツバッファの使用サイズ

EXTRN	SSDES0:WORD			; visual data segment plean 0
EXTRN	SSGR0:WORD			; visual data segment plean 0
EXTRN	SSEFC0:WORD			; visual data segment plean 0
EXTRN	SEGVT0:WORD			; text put vram segment plean 0.
EXTRN	SSCUR0:WORD			; visual data segment plean 0

EXTRN	ITEMID_TBL1:WORD		; アイテムIDﾃｰﾌﾞﾙ／名前
EXTRN	ITEMID_TBL2:WORD		; アイテムIDﾃｰﾌﾞﾙ／ＩＣＯＮ
EXTRN	ITEMID_TBL3:WORD		; アイテムIDﾃｰﾌﾞﾙ／金
EXTRN	ITEMID_TBL4:WORD		; アイテムIDﾃｰﾌﾞﾙ／文字１
EXTRN	ITEMID_TBL5:WORD		; アイテムIDﾃｰﾌﾞﾙ／ﾊﾟﾗﾒｰﾀ値１
EXTRN	ITEMID_TBL6:WORD		; アイテムIDﾃｰﾌﾞﾙ／文字２
EXTRN	ITEMID_TBL7:WORD		; アイテムIDﾃｰﾌﾞﾙ／ﾊﾟﾗﾒｰﾀ値２
EXTRN	ITEMID_CNT:WORD			; アイテムID数
EXTRN	ITEMID_DIM:WORD			; アイテムIDﾃｰﾌﾞﾙｻｲｽﾞ

EXTRN	IPARATBL:WORD			; アイテムパラメータ・ﾃｰﾌﾞﾙ
EXTRN	IPARACNT:WORD			; アイテムパラメータ・数
EXTRN	IPARADIM:WORD			; アイテムパラメータ・ﾃｰﾌﾞﾙｻｲｽﾞ

WIDINM		DW	0		;アイテム選択番号

WIDMDEMO	DW	0		; デモフラグ0=通常,55=ランダムセレクト
WIDMDEMOWAIT	DW	60		; デモ 待ち時間

WIDTYPE		DW	0		; window type.
WIDTYPEMAX	DW	TYPE_MAX	; window type max.

WIDLOCADRS_X	DW	0		; window locx table adrs.
WIDLOCADRS_Y	DW	0		; window locy table adrs.

WIDSHOWCNT	DW	0		; window show count.
WIDSHOWBASE	DW	0		; window show base.

FLAG_CANCEL_EN	DW	1		; flag キャンセルウインドウ
FLAG_NOW_CANCEL	DW	0		; キャンセル状態
WIDCAN_X	DW	0		; window cancel x.
WIDCAN_Y	DW	0		; window cancel y.
WIDCAN_XL	DW	WDCN_SIZ_X	; window cancel size x.
WIDCAN_YL	DW	WDCN_SIZ_Y	; window cancel size y.

FLAG_EXPCMD_EN	DW	0		; flag 拡張ｺﾏﾝﾄﾞウインドウ
NUM_EXPCMD	DW	OFFF		; 拡張ｺﾏﾝﾄﾞ番号
NOWNUM_EXPCMD	DW	OFFF		; 表示中拡張ｺﾏﾝﾄﾞ番号

FLAG_EXPFNC_EN	DW	0		; flag 拡張functionウインドウ
NUM_EXPFNC	DW	OFFF		; 拡張function番号
NOWNUM_EXPFNC	DW	OFFF		; 表示中拡張function番号

CMDEXP_CNT	DW	2		; 拡張ｺﾏﾝﾄﾞ数

WIDSHOWITM	DW	0		; window show item.

WIDEXP_FLAG	DW	0,0		; window expand disable flag.
WIDEXP_X	DW	0,0		; window expand x.
WIDEXP_Y	DW	0,0		; window expand y.

WIDBAK_TBL_XL	DW WDT1_SIZ_X,WDT2_SIZ_X,WDT3_SIZ_X ; window back 1size tbl x.
		DW WDT4_SIZ_X,WDT5_SIZ_X
WIDBAK_TBL_YL	DW WDT1_SIZ_Y,WDT2_SIZ_Y,WDT3_SIZ_Y ; window back 1size tbl y.
		DW WDT4_SIZ_Y,WDT5_SIZ_Y

EXPFNC_CNT	DW	2			; 拡張function数
WIDEXFC_X	DW	0,0			; window expand function x.
WIDEXFC_Y	DW	0,0			; window expand function y.

FLAG_PAGECUR_EN	DW	0			; flag page current.
PAGE_COUNT	DW	0			; page count.
PAGE_CURRENT	DW	0			; page current.
PAGE_RECTBL	DW	PAGE_MAX DUP (0)	; page top record table.
PAGE_RECMAX	DW	PAGE_MAX DUP (0)	; page record max table.

WIDAREA_MAX	DW	12,	16,	16,10,1	; window area window max.

WIDAREA_TBLMAX	DW	16,	16,	16,10,1	; window area table max.
WIDAREA_TBLXX	DW WDT1_SIZ_X,WDT2_SIZ_X,WDT3_SIZ_X ; window area length x.
		DW WDT4_SIZ_X,WDT5_SIZ_X
WIDAREA_TBLYY	DW WDT1_SIZ_Y,WDT2_SIZ_Y,WDT3_SIZ_Y ; window area length y.
		DW WDT4_SIZ_Y,WDT5_SIZ_Y

WIDLOCTBLX_AD	DW WID1LOCX,WID2LOCX,WID3LOCX ; window x tables adrs.
		DW WID4LOCX,WID5LOCX
WIDLOCTBLY_AD	DW WID1LOCY,WID2LOCY,WID3LOCY ; window y tables adrs.
		DW WID4LOCY,WID5LOCY

WID1LOCX	LABEL	WORD		; window start point x.
		DW	 2,21,40,59
		DW	 2,21,40,59
		DW	59,59,59,59
		DW	40,40,40,40
WID1LOCY	LABEL	WORD		; window start point y.
		DW	270,270,270,270
		DW	332,332,332,332
		DW	208,146, 84, 22
		DW	208,146, 84, 22

WID2LOCX	LABEL	WORD		; window start point x.
WID3LOCX	LABEL	WORD		; window start point x.
WID4LOCX	LABEL	WORD		; window start point x.
		DW	46,63
		DW	46,63
		DW	46,63
		DW	46,63
		DW	46,63
		DW	46,63
		DW	46,63
		DW	46,63

WID2LOCY	LABEL	WORD		; window start point y.
WID3LOCY	LABEL	WORD		; window start point y.
WID4LOCY	LABEL	WORD		; window start point y.
		DW	60+48*3,	60+48*3
		DW	60+48*4,	60+48*4
		DW	60+48*5,	60+48*5
		DW	60+48*2,	60+48*2
		DW	60+48,		60+48
		DW	60,		60
		DW	60-48,		60-48
		DW	60+48*6,	60+48*6

;;WID4LOCX	LABEL	WORD		; window start point x.
;;		DW	46,63
;;		DW	46,63
;;		DW	46,63
;;		DW	46,63
;;		DW	46,63
;;WID4LOCY	LABEL	WORD		; window start point y.
;;		DW	80+48*2,	80+48*2
;;		DW	80+48*3,	80+48*3
;;		DW	80+48*4,	80+48*4
;;		DW	80+48*5,	80+48*5
;;		DW	80+48,		80+48

WID5LOCX	LABEL	WORD		; window start point x.
		DW	54
WID5LOCY	LABEL	WORD		; window start point y.
		DW	120

;*;WID3LOCX	LABEL	WORD		; window start point x.
;*;		DW	8,25,42,59
;*;		DW	8,25,42,59
;*;		DW	8,25,42,59
;*;
;*;WID3LOCY	LABEL	WORD		; window start point y.
;*;		DW	180,	192,	200,	195
;*;		DW	180+48,	192+48,	200+48,	195+48
;*;		DW	180+48*2,192+48*2,200+48*2,195+48*2


NOWLOCXX	DW	0		; now locate x.
NOWLOCYY	DW	0		; now locate y.

WIDLOCTBLDIM	DW	16		; window locate table dim.
WIDLOCTBLMAX	DW	0		; window locate table max.
WIDLOCTBLXX	DW	16 DUP (0)	; window locate x table.
WIDLOCTBLYY	DW	16 DUP (0)	; window locate y table.
WIDAREAXX	DW	0		; window area length x.
WIDAREAYY	DW	0		; window area length y.

MOUSEX		DW	0		; マウスＸ座標
MOUSEY		DW	0		; マウスＹ座標
MOUSEBTN_L	DB	0,0		; マウス左ボタン（1：ＯＦＦ／0：ＯＮ）
MOUSEBTN_R	DB	0,0		; マウス右ボタン（1：ＯＦＦ／0：ＯＮ）

SLCT_NUMBER	DW	OFFF		; 選択番号
NOWLOC_NUMBER	DW	OFFF		; 選択表示中番号

BACK_COUNT	DW	0		; back save count.
COUNTER		DW	0		; counter.
LOCCOUNT	DW	0		; location counter.

LOCX		DW	0		; x.
LOCY		DW	0		; y.

DATA	ENDS

	END
;
;	end of "WIDMULT.ASM"
;
