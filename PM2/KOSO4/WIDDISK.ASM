; "WIDDISK.ASM" PC-9801UV11 make by R.H 1992/05/20
;
;
;	ＷＩＮＤＯＷＳ／ＤＩＳＫウインドウ
;
;
;	WIDDISK		: WINDOWS/ディスクウインドウ(DSKWID.ASM用)
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC
INCLUDE	MACHINEX.INC

BACKSAVE_BANK	EQU	24		; 背景退避用パーツバンク番号
					; #24	("WIDDISK.ASM"用)

WIDSYSX_INI	EQU	17		; ウインドウＰＵＴ初期Ｘ座標
WIDSYSY_INI	EQU	200-25		; ウインドウＰＵＴ初期Ｙ座標
WIDSYS_SIZEX	EQU	46		; ウインドウサイズＸ
WIDSYS_SIZEY	EQU	50+8		; ウインドウサイズＹ

LAMP_X		EQU	1		; LED lamp x.
LAMP_Y		EQU	404		; LED lamp y.

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA

; ****************************************************
;	WINDOWS/ディスクウインドウ(DSKWID.ASM用)
;	-I- BX : 1=ウインドウ・オープン
;	       : 2=ウインドウ・クローズ
;	       : 3=ウインドウ・メッセージ／上段
;	       : 4=ウインドウ・メッセージ／中段
;	       : 10=ウインドウＷＡＩＴ
;	       : 11=ウインドウ・パス名表示
;	       : 12=アクセスランプ
;	 DS:SI : メッセージ・アドレス
;	 DX    : 0=OFF,1=ON(アクセスランプ)
; ****************************************************

FUNC	WIDDISK
	PUSH	ES
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	BP

	PUSH	VRX			; ＶＲＡＭ　Ｘ座標
	PUSH	VRY			; ＶＲＡＭ　Ｙ座標
	PUSH	VRLENX			; x length.
	PUSH	VRLENY			; y length.
	PUSH	PRSBNK			; バンク番号
	PUSH	PRSSEG			; バンクセグメント
	PUSH	PRSTOP			; バンクトップオフセット
	PUSH	PRSEND			; バンクエンドオフセット
	PUSH	PRSOFS			; パーツバッファのカレントポインタ
	PUSH	PRSSIZ			; パーツバッファの使用サイズ
	PUSH	PLSMDE			; 圧縮モード(0:通常,1:縦方向)

	PUSH	SSGR0			; visual data segment plean 0
	PUSH	SSGR1			; visual data segment plean 1
	PUSH	SSGR2			; visual data segment plean 2
	PUSH	SSGR3			; visual data segment plean 3
	PUSH	SSGRW			; visual data plean width.

	PUSH	SSEFC0			; visual data segment plean 0
	PUSH	SSEFC1			; visual data segment plean 1
	PUSH	SSEFC2			; visual data segment plean 2
	PUSH	SSEFC3			; visual data segment plean 3
	PUSH	SSEFCW			; visual data plean width.

	PUSH	SSDES0			; visual data segment plean 0
	PUSH	SSDES1			; visual data segment plean 1
	PUSH	SSDES2			; visual data segment plean 2
	PUSH	SSDES3			; visual data segment plean 3
	PUSH	SSDESW			; visual data plean width.

	PUSH	WDX1			; 表示位置Ｘ
	PUSH	WDY1			; 表示位置Ｙ
	PUSH	WDX2			; 大きさＸ
	PUSH	WDY2			; 大きさＹ

	PUSH	VX1 			; start point.
	PUSH	VY1 			; start point.
	PUSH	VX2 			; end point.
	PUSH	VY2 			; end point.

	PUSH	DX
	PUSH	BX
	PUSH	SI
	MOV_ID2	SSGR0,ARAVRM
	MOV_ID2	SSDES0,ARAVRM
	POP	SI
	POP	BX
	POP	DX

	CMP	BL,1			;
	JE	WIDDISK_OPEN		;
	CMP	BL,2			;
	JE	WIDDISK_CLOSE		;
	CMP	BL,3			;
	JE	WIDDISK_1PRINT		;
	CMP	BL,4			;
	JE	WIDDISK_2PRINT		;
	CMP	BL,10			;
	JE	WIDDISK_WAT		;
	CMP	BL,11			;
	JE	WIDDISK_PTH		;
	CMP	BL,12			;
	JE	WIDDISK_LMP		;

	JMP	WIDDISK_EXIT		;
WIDDISK_OPEN:
	CALL	WIDOPEN			; ウインドウ・オープン
	JMP	WIDDISK_EXIT		;
WIDDISK_CLOSE:
	CALL	WIDCLOSE		; ウインドウ・クローズ
	JMP	WIDDISK_EXIT		;
WIDDISK_1PRINT:
	CALL	WID1PRINT		; ウインドウ・メッセージ／上段
	JMP	WIDDISK_EXIT		;
WIDDISK_2PRINT:
	CALL	WID2PRINT		; ウインドウ・メッセージ／中段
	JMP	WIDDISK_EXIT		;
WIDDISK_WAT:
	CALL	WIDDISK_WAIT		; ディスクウインドウＷＡＩＴ
	JMP	WIDDISK_EXIT		;
WIDDISK_PTH:
	CALL	WIDDISK_PATH		; ディスクウインドウ・パス名表示
	JMP	WIDDISK_EXIT		;
WIDDISK_LMP:
	CALL	WIDDISK_LAMP		; アクセスランプ
	JMP	WIDDISK_EXIT		;

WIDDISK_EXIT:

	POP	VY2 			; end point.
	POP	VX2 			; end point.
	POP	VY1 			; start point.
	POP	VX1 			; start point.

	POP	WDY2			; 大きさＹ
	POP	WDX2			; 大きさＸ
	POP	WDY1			; 表示位置Ｙ
	POP	WDX1			; 表示位置Ｘ

	POP	SSDESW			; visual data plean width.
	POP	SSDES3			; visual data segment plean 3
	POP	SSDES2			; visual data segment plean 2
	POP	SSDES1			; visual data segment plean 1
	POP	SSDES0			; visual data segment plean 0

	POP	SSEFCW			; visual data plean width.
	POP	SSEFC3			; visual data segment plean 3
	POP	SSEFC2			; visual data segment plean 2
	POP	SSEFC1			; visual data segment plean 1
	POP	SSEFC0			; visual data segment plean 0

	POP	SSGRW			; visual data plean width.
	POP	SSGR3			; visual data segment plean 3
	POP	SSGR2			; visual data segment plean 2
	POP	SSGR1			; visual data segment plean 1
	POP	SSGR0			; visual data segment plean 0

	POP	PLSMDE			; 圧縮モード(0:通常,1:縦方向)
	POP	PRSSIZ			; パーツバッファの使用サイズ
	POP	PRSOFS			; パーツバッファのカレントポインタ
	POP	PRSEND			; バンクエンドオフセット
	POP	PRSTOP			; バンクトップオフセット
	POP	PRSSEG			; バンクセグメント
	POP	PRSBNK			; バンク番号
	POP	VRLENY			; y length.
	POP	VRLENX			; x length.
	POP	VRY			; ＶＲＡＭ　Ｙ座標
	POP	VRX			; ＶＲＡＭ　Ｘ座標

	POP	BP
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POP	ES
	RET
FEND	WIDDISK


; ****************************************************
;	ウインドウ・オープン
; ****************************************************

WIDOPEN	PROC	NEAR
	CALL	BACKSAVE		; 背景をセーブ

	MOVX	WDX1,WIDPNTXX		; ウインドウ エリア左上座標Ｘ
	MOVX	WDY1,WIDPNTYY		; ウインドウ エリア左上座標Ｙ
	MOVX	WDX2,WIDSIZEX		; ウインドウ エリアサイズＸ
	MOVX	WDY2,WIDSIZEY		; ウインドウ エリアサイズＹ
	CALL_w	WID_FLAME_DISK		; WINDOWS/フレーム・ディスクウインドウ

	RET
WIDOPEN	ENDP


; ****************************************************
;	ウインドウ・クローズ
; ****************************************************

WIDCLOSE	PROC	NEAR
	CALL	BACKLOAD		; 背景をロード
	RET
WIDCLOSE	ENDP


; ****************************************************
;	ウインドウ・メッセージ／上段
;	-I- DS:SI : メッセージ・アドレス
; ****************************************************

WID1PRINT	PROC	NEAR
	MOV	STR_ADRS,SI		; 文字列アドレス

	MOV	AX,WDTXTSIZ		; text size.0=16x16,1=32x32,2=16x24...
	CALL_w	VTXSIZ			; character size set.
	MOV	AX,WDTXTCOL		; character color. 0-15
	CALL_w	VTXCOL			; character color set.

	MOV	AX,WIDPNTXX		; ウインドウエリア左上座標Ｘ
	MOV	BX,WIDPNTYY		; ウインドウエリア左上座標Ｙ
	ADD	AX,WIDTXTX1		; テキスト１座標Ｘ
	ADD	BX,WIDTXTY1		; テキスト１座標Ｙ
	MOV	CLRLEN,40		; clear length.
	CALL	LINCLR			; 行クリア

	MOV	SI,STR_ADRS		; 文字列アドレス
	CALL_w	VTXPOR			; vram text print OR.
	RET
WID1PRINT	ENDP


; ****************************************************
;	ウインドウ・メッセージ／中段
;	-I- DS:SI : メッセージ・アドレス
; ****************************************************

WID2PRINT	PROC	NEAR
	MOV	STR_ADRS,SI		; 文字列アドレス

	MOV	AX,WDTXTSIZ		; text size.0=16x16,1=32x32,2=16x24...
	CALL_w	VTXSIZ			; character size set.
	MOV	AX,WDTXTCOL		; character color. 0-15
	CALL_w	VTXCOL			; character color set.

	MOV	AX,WIDPNTXX		; ウインドウエリア左上座標Ｘ
	MOV	BX,WIDPNTYY		; ウインドウエリア左上座標Ｙ
	ADD	AX,WIDTXTX2		; テキスト２座標Ｘ
	ADD	BX,WIDTXTY2		; テキスト２座標Ｙ
	MOV	CLRLEN,40		; clear length.
	CALL	LINCLR			; 行クリア

	MOV	SI,STR_ADRS		; 文字列アドレス
	CALL_w	VTXPOR			; vram text print OR.
	RET
WID2PRINT	ENDP


; ****************************************************
;	ディスクウインドウＷＡＩＴ
; ****************************************************

WIDDISK_WAIT	PROC	NEAR
	MOV	AX,WIDSIZEX		; ウインドウ エリアサイズＸ
	MOV	BX,WIDSIZEY		; ウインドウ エリアサイズＹ
	SHR	AX,1			; / 2
	SUB	AX,2			; - 2
	SUB	BX,8			; - 8
	ADD	AX,WIDPNTXX		; ウインドウ エリア左上座標Ｘ
	ADD	BX,WIDPNTYY		; ウインドウ エリア左上座標Ｙ
	CALL_w	MSWWAT			; カーソルボタン待ち
	RET
WIDDISK_WAIT	ENDP


; ****************************************************
;	ディスクウインドウ・パス名表示
;	-I- DS:SI : パス名・アドレス
; ****************************************************

WIDDISK_PATH	PROC	NEAR
	MOV	STR_ADRS,SI		; 文字列アドレス

	MOV	AX,15			; ヘッダー文字表示色
	CALL_w	MITCOL			; mini string color.

	MOV	AX,WIDPNTXX		; ウインドウエリア左上座標Ｘ
	MOV	BX,WIDPNTYY		; ウインドウエリア左上座標Ｙ
	ADD	AX,WIDTXTX3		; テキスト３座標Ｘ
	ADD	BX,WIDTXTY3		; テキスト３座標Ｙ
	MOV	SI,STR_ADRS		; 文字列アドレス
	CALL_w	MITPRN			; mini string. (null=end of string)

	RET
WIDDISK_PATH	ENDP


; ****************************************************
;	アクセスランプ
;	-I- DX : 0=OFF,1=ON,2=ON2.
; ****************************************************

WIDDISK_LAMP	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	WIDDISK_LAMP_START	;
	RET
WIDDISK_LAMP_START:
	CMP	DL,1			; 1=ON.
	JE	WIDDISK_LAMP_ON		;
	CMP	DL,2			; 2=ON2.
	JE	WIDDISK_LAMP_2ON	;
WIDDISK_LAMP_OFF:
	MOV	SI,OFFSET LAMP_OFF_PTN	; lamp OFF pattern.
	JMP	WIDDISK_LAMP_PUT	;
WIDDISK_LAMP_ON:
	MOV	SI,OFFSET LAMP_ON1_PTN	; lamp ON1 pattern.
	JMP	WIDDISK_LAMP_PUT	;
WIDDISK_LAMP_2ON:
	MOV	SI,OFFSET LAMP_ON2_PTN	; lamp ON2 pattern.
WIDDISK_LAMP_PUT:
	PUSH	SI			;
	MOV_ID2	SSEFC0,ARAVRM		; efect data segment.
	POP	SI
	MOV	VX1,LAMP_X		; LED lamp x.
	MOV	VY1,LAMP_Y		; LED lamp y.
	CALL_w	BOXLEDLAMP		; LED like lamp.
	RET
WIDDISK_LAMP	ENDP


; ****************************************************
;	背景をロード
; ****************************************************

BACKLOAD	PROC	NEAR
	MOV	DX,BACKSAVE_BANK	; 背景退避用パーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	MOV	DX,0			; 圧縮モード(0:通常,1:縦方向)
	CALL_w	C1PLSMOD		; 圧縮モード切り替え

	MOV	CX,0			; 背景退避用パーツ番号
	CALL_w	C1PATPUT		; パーツＰＵＴ

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
	MOV	DX,BACKSAVE_BANK	; 背景退避用パーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	CALL_w	C1PATCLR		; パーツセットクリア

	MOVX	VRX,WIDBAKXP		; 背景退避エリア左上座標Ｘ
	MOVX	VRY,WIDBAKYP		; 背景退避エリア左上座標Ｙ
	MOVX	VRLENX,WIDBAKXL		; 背景退避エリアサイズＸ
	MOVX	VRLENY,WIDBAKYL		; 背景退避エリアサイズＹ

	CALL_w	C1PATGTA		; パーツＧＥＴ圧縮無し

	RET
BACKSAVE	ENDP


; ****************************************************
;	行クリア
;	-I- AX : 行表示座標Ｘ
;	    BX : 行表示座標Ｙ
; ****************************************************

LINCLR	PROC	NEAR
	PUSH	AX
	PUSH	BX

	PUSH	BX
	PUSH	AX
	MOV_ID2	SSEFC0,ARAVRM		; efect data segment.
	POP	AX
	POP	BX
	MOV	WDX1,AX			; 表示位置Ｘ
	MOV	WDY1,BX			; 表示位置Ｙ
	MOV	AX,CLRLEN		; clear length.
	INC	AX			;
	MOV	WDX2,AX			;
	MOV	WDY2,16			; +16
	CALL_w	WID_FLAME_DISK_BOX	; WINDOWS/フレーム・ﾃﾞｨｽｸｳｲﾝﾄﾞｳ BOX

	POP	BX
	POP	AX
	RET
LINCLR	ENDP


; ****************************************************
;	テキスト地色
;	-I- VX1,VY1  : start point.
;	    VX2,VY2  : end point.
; ****************************************************

JI_TEXT	PROC	NEAR
	MOV	CX,W_COL6		; WINDOWS/カラー・テキスト地色１
	MOV	BX,W_COL7		; WINDOWS/カラー・テキスト地色１
	CALL_w	BOXMCH			; ＢＯＸチェック模様
	RET
JI_TEXT	ENDP

WINDOW	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	PLSMDE:WORD			; 圧縮モード(0:通常,1:縦方向)

EXTRN	PRSBNK:WORD			; バンク番号
EXTRN	PRSSEG:WORD			; バンクセグメント
EXTRN	PRSTOP:WORD			; バンクトップオフセット
EXTRN	PRSEND:WORD			; バンクエンドオフセット

EXTRN	PRSOFS:WORD			; パーツバッファのカレントポインタ
EXTRN	PRSSIZ:WORD			; パーツバッファの使用サイズ

W_COL6		DW	4	; WINDOWS/カラー・テキスト地色１
W_COL7		DW	0	; WINDOWS/カラー・テキスト地色１

WIDBAKXP	DW	WIDSYSX_INI	; 背景退避エリア左上座標Ｘ
WIDBAKYP	DW	WIDSYSY_INI	; 背景退避エリア左上座標Ｙ
WIDBAKXL	DW	WIDSYS_SIZEX	; 背景退避エリアサイズＸ
WIDBAKYL	DW	WIDSYS_SIZEY	; 背景退避エリアサイズＹ
WIDPNTXX	DW	WIDSYSX_INI	; ウインドウ エリア左上座標Ｘ
WIDPNTYY	DW	WIDSYSY_INI	; ウインドウ エリア左上座標Ｙ
WIDSIZEX	DW	WIDSYS_SIZEX	; ウインドウ エリアサイズＸ
WIDSIZEY	DW	WIDSYS_SIZEY	; ウインドウ エリアサイズＹ
WIDTXTX1	DW	2		; テキスト１座標Ｘ
WIDTXTY1	DW	6		; テキスト１座標Ｙ
WIDTXTX2	DW	2		; テキスト２座標Ｘ
WIDTXTY2	DW	26		; テキスト２座標Ｙ
WIDTXTX3	DW	2		; テキスト３座標Ｘ
WIDTXTY3	DW	46		; テキスト３座標Ｙ
WDTXTSIZ	DW	0		; text size.0=16x16,1=32x32,2=16x24...
WDTXTCOL	DW	15		; character color. 0-15

CLRLEN		DW	0		; clear length.
STR_ADRS	DW	0		; 文字列アドレス
LAMP_ON1_PTN	DB	000H,0FFH,000H,0FFH	; lamp ON1 pattern.
LAMP_ON2_PTN	DB	000H,000H,0FFH,0FFH	; lamp ON2 pattern.
LAMP_OFF_PTN	DB	000H,000H,000H,000H	; lamp OFF pattern.

DATA	ENDS

	END
;
;	end of "WIDDISK.ASM"
;
