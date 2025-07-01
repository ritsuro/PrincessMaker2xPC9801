; "MAINLP.ASM" 486/50 make by R.H 1993/03/02
;
;
;	メインループ
;
;
; public subroutine.

INCLUDE	TSTSET.INC

MFLAG_PCAT	EQU	1		; PC/AT
MFLAG_PC98	EQU	2		; PC9801

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	MAINLP			; main loop.

PUBLIC	FRAME_LDSV		; ﾃﾞｰﾀﾛｰﾄﾞｾｰﾌﾞﾌﾚｰﾑ

PUBLIC	DS_GET_TO_MAIN		; ﾃﾞｰﾀｾｸﾞﾒﾝﾄ取得
PUBLIC	VRAMASSIGN		; vram assign.
PUBLIC	GET_VRAM_SEGMENT	; get vram segment.
PUBLIC	XRANDAM			; randam.


; ****************************************************
;	main loop.
;	-I- AX   : function number.
;	AX=1  : 初期処理
;	AX=2  : ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳOPEN
;	AX=3  : ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳCLOSE
;	AX=4  : ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ項目セット
;		-I- BX : データファイル番号
;		    CX : 年
;		    DX : 月
;		    SI : 曜日
;		    DI : 日
;		    BP : 文字列バッファ 名前
;	AX=5  : ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ項目表示
;		-I- BX : データファイル番号
;	AX=6  : ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳﾍｯﾀﾞ表示
;		-I- BX : "日付"
;		    CX : "名前"
;	AX=7  : ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳSLCT
;		-O- EXIT_STATUS : 選択ﾃﾞｰﾀﾌｧｲﾙ番号(-1はｷｬﾝｾﾙ)
;	AX=8  : ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ文字表示
;		-I- BX : データファイル番号(ｻｲﾄﾞﾒﾆｭｰは11から)
;		    CX : 文字列
;	AX=9  : ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ ｻｲﾄﾞﾒﾆｭｰ行数
;		-I- BX : 項目行数
;
;	AX=101 : ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳ
;		-O- EXIT_STATUS : ｺﾏﾝﾄﾞ番号
;
;	AX=102 : ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳﾎﾞﾀﾝ停止
;		-I- BX : ｺﾏﾝﾄﾞ番号
;		    CX : 1=ｺﾏﾝﾄﾞOFF
;
;	AX=201 : WINDOWS/ﾕｰｻﾞｰﾃﾞｨｽｸか新しいﾃﾞｨｽｸｾｯﾄ
;		-O- EXIT_STATUS : 1=ユーザディスク
;				  2=新しいディスク
;				  3=別のソフトが入っている
;				  4=ライトプロテクト
;				  -1=ユーザの強制終了
;
;	AX=202 : WINDOWS/ﾕｰｻﾞｰﾃﾞｨｽｸをセットさせる
;		-O- EXIT_STATUS : 1=ユーザの強制終了
;
;	AX=203 : WINDOWS/ﾕｰｻﾞｰﾃﾞｨｽｸの作成
;		-O- EXIT_STATUS : 0=正常, 2=ディスクエラー
;			3=デバイスがノットレディ, 4=ライトプロテクト
;			1=エラー,10=ユーザディスクじゃない
;
; ****************************************************

MAINLP	PROC	NEAR
	CMP	AL,1
	JE	MAINLP01N
	CMP	AL,2
	JE	MAINLP02N
	CMP	AL,3
	JE	MAINLP03N
	CMP	AL,4
	JE	MAINLP04N
	CMP	AL,5
	JE	MAINLP05N
	CMP	AL,6
	JE	MAINLP06N
	CMP	AL,7
	JE	MAINLP07N
	CMP	AL,8
	JE	MAINLP08N
	CMP	AL,9
	JE	MAINLP09N
	CMP	AL,101
	JE	MAINLP101N
	CMP	AL,102
	JE	MAINLP102N
	CMP	AL,201
	JE	MAINLP201N
	CMP	AL,202
	JE	MAINLP202N
	CMP	AL,203
	JE	MAINLP203N
	RET

MAINLP01N:
	CALL	ALLINIT			; 初期処理
	JMP	MAINLP_SKIP

MAINLP02N:
	CALLE	WIDDTSLC_OPEN		; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳOPEN
	JMP	MAINLP_SKIP

MAINLP03N:
	CALLE	WIDDTSLC_CLOSE		; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳCLOSE
	JMP	MAINLP_SKIP

MAINLP04N:
	CALLE	WIDDTSLC_PARASET	; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ項目セット
	JMP	MAINLP_SKIP

MAINLP05N:
	CALLE	WIDDTSLC_PARASHOW	; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ項目表示
	JMP	MAINLP_SKIP

MAINLP06N:
	CALLE	WIDDTSLC_HEADER		; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳﾍｯﾀﾞ表示
	JMP	MAINLP_SKIP

MAINLP07N:
	CALLE	WIDDTSLC_SLCT		; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳSLCT
	MOV	EXIT_STATUS,AX		; 選択ﾃﾞｰﾀﾌｧｲﾙ番号(-1はｷｬﾝｾﾙ)
	JMP	MAINLP_SKIP

MAINLP08N:
	CALLE	WIDDTSLC_PRINT		; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ文字表示
	JMP	MAINLP_SKIP

MAINLP09N:
	CALLE	WIDDTSLC_SIDEM_LIN	; WINDOWS/ﾃﾞｰﾀ選択ｳｲﾝﾄﾞｳ ｻｲﾄﾞﾒﾆｭｰ行数
	JMP	MAINLP_SKIP

MAINLP101N:
	CALLE	WIDCMND			; WINDOWS/ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳ
	MOV	EXIT_STATUS,AX		; 選択ﾃﾞｰﾀﾌｧｲﾙ番号(-1はｷｬﾝｾﾙ)
	JMP	MAINLP_SKIP

MAINLP102N:
	CALLE	WIDCMND_HLT		; WINDOWS/ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳﾎﾞﾀﾝ停止
	JMP	MAINLP_SKIP

MAINLP201N:
	CALLE	WIDUSERNEWDISK		; WINDOWS/ﾕｰｻﾞｰﾃﾞｨｽｸか新しいﾃﾞｨｽｸｾｯﾄ
	MOV	EXIT_STATUS,CX		; 1=ユーザディスク
					; 2=新しいディスク
					; 3=別のソフトが入っている
					; 4=ライトプロテクト
	CMP	BX,1			;
	JNE	MAINLP201N2		;
	MOV	EXIT_STATUS,-1		; -1=ユーザの強制終了
MAINLP201N2:
	JMP	MAINLP_SKIP

MAINLP202N:
	CALLE	WIDUSERDSET		; WINDOWS/ﾕｰｻﾞｰﾃﾞｨｽｸをセットさせる
	MOV	EXIT_STATUS,BX		; 1=ユーザの強制終了
	JMP	MAINLP_SKIP

MAINLP203N:
	CALLE	WIDUSERMAKE		; WINDOWS/ﾕｰｻﾞｰﾃﾞｨｽｸの作成
	MOV	EXIT_STATUS,AX		;
	JMP	MAINLP_SKIP

MAINLP_SKIP:
	RET
MAINLP	ENDP


; ****************************************************
;	初期処理
; ****************************************************

ALLINIT	PROC	NEAR
	MOV	CX,0			;0=ARAVRM : ＶＲＡＭプレーン
	MOV	DX,0			;0=SSGR0  : visual data segment plean.
	CALL	VRAMASSIGN		; vram assign.
	CALLE	WIDCMND_INI		; WINDOWS/ｺﾏﾝﾄﾞｳｲﾝﾄﾞｳ初期化

	MOV	BX,6			; get buffer address.
	MOV	SI,0			; 0=通常パターンバッファ・後半
	CALLE	MAIN_FUNCTION_INTER	; main function inter.
	MOV	FAT_TABLE_SEG,ES	; FAT table segment.
	MOV	FAT_TABLE_OFS,DI	; FAT table offset.

	RET
ALLINIT	ENDP


; ****************************************************
;	ﾃﾞｰﾀﾛｰﾄﾞｾｰﾌﾞﾌﾚｰﾑ
;	-I- CX : 表示位置Ｘ
;	    DX : 表示位置Ｙ
;	    SI : 大きさＸ
;	    DI : 大きさＹ
; ****************************************************

FRAME_LDSV	PROC	NEAR
	MOV	BX,28			; ﾌﾚｰﾑ･ﾃﾞｰﾀﾛｰﾄﾞｾｰﾌﾞ(DSKTOOL.COM)
	CALLE	MAIN_FUNCTION_INTER	; main function inter.
	RET
FRAME_LDSV	ENDP


; ****************************************************
;	ﾃﾞｰﾀｾｸﾞﾒﾝﾄ取得
;	-O- DX : ﾃﾞｰﾀｾｸﾞﾒﾝﾄ
; ****************************************************

DS_GET_TO_MAIN	PROC	NEAR
	MOV	BX,29			; ﾃﾞｰﾀｾｸﾞﾒﾝﾄ取得
	CALLE	MAIN_FUNCTION_INTER	; main function inter.
	RET
DS_GET_TO_MAIN	ENDP


; ****************************************************
;	vram assign.
;	-I- CX : vram ID table.
;		0=ARAVRM : ＶＲＡＭプレーン
;		1=ARA001 : 仮想ＶＲＡＭプレーン(width40)
;		2=ARA002 : 仮想ＶＲＡＭプレーン(width42)
;		3=ARA003 : 仮想ＶＲＡＭプレーン(width60)
;		4=ARA004 : 仮想ＶＲＡＭプレーン(width56)
;		5=ARA005 : 仮想ＶＲＡＭ(単プレーンwidth60)
;		6=ARA006 : 仮想ＶＲＡＭ(単プレーンwidth40)
;		7=ARA007 : 仮想ＶＲＡＭ(単プレーンwidth40)
;		8=ARA008 : 仮想ＶＲＡＭ(単プレーンwidth40)
;		9=ARA009 : 仮想ＶＲＡＭ(単プレーンwidth47)
;	    DX : assign ID table.
;		0=SSGR0  : visual data segment plean.
;		1=SSGRV0 : visual data segment plean.
;		2=SSDES0 : visual data segment plean.
;		3=SSSOU0 : visual data segment plean.
;		4=SSEFC0 : visual data segment plean.
;		5=SSCUR0 : visual data segment plean.
;		6=SEGVT0 : visual data segment plean.
; ****************************************************

VRAMASSIGN	PROC	NEAR
	MOV	BX,25			; vram assign.
	CALLE	MAIN_FUNCTION_INTER	; main function inter.
	RET
VRAMASSIGN	ENDP


; *********************************************************
;	get vram segment.
;	-I- CX : vram ID table.
;		0=ARAVRM : ＶＲＡＭプレーン
;		1=ARA001 : 仮想ＶＲＡＭプレーン(width40)
;		2=ARA002 : 仮想ＶＲＡＭプレーン(width42)
;		3=ARA003 : 仮想ＶＲＡＭプレーン(width60)
;		4=ARA004 : 仮想ＶＲＡＭプレーン(width56)
;		5=ARA005 : 仮想ＶＲＡＭ(単プレーンwidth60)
;		6=ARA006 : 仮想ＶＲＡＭ(単プレーンwidth40)
;		7=ARA007 : 仮想ＶＲＡＭ(単プレーンwidth40)
;		8=ARA008 : 仮想ＶＲＡＭ(単プレーンwidth40)
;		9=ARA009 : 仮想ＶＲＡＭ(単プレーンwidth47)
;	    DX : plean number.
;	-O- DX : segment.
; *********************************************************

GET_VRAM_SEGMENT	PROC	NEAR
	MOV	BX,27			; get vram plean segment.
	CALLE	MAIN_FUNCTION_INTER	; main function inter.
	RET
GET_VRAM_SEGMENT	ENDP


; ****************************************************
;	randam.
;	-I- CX : 最大値(1-200)
;	-O- BX : 乱数
; ****************************************************

XRANDAM	PROC	NEAR
	MOV	BX,21			; randam.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	RET
XRANDAM	ENDP

; ****************************************************
;	data.
; ****************************************************

PUBLIC	FAT_TABLE_SEG		; FAT table segment.
PUBLIC	FAT_TABLE_OFS		; FAT table offset.

EXTRN	EXIT_STATUS:WORD	; 選択ﾃﾞｰﾀﾌｧｲﾙ番号(-1はｷｬﾝｾﾙ)

EXTRN	VX1:WORD		; point x1.
EXTRN	VY1:WORD		; point y1.
EXTRN	VX2:WORD		; point x2.
EXTRN	VY2:WORD		; point y2.
EXTRN	VX3:WORD		; point x3.
EXTRN	VY3:WORD		; point y3.

	EVEN

FAT_TABLE_SEG	DW	0	; FAT table segment.
FAT_TABLE_OFS	DW	0	; FAT table offset.

CODE	ENDS
	END
;
;	end of "MAINLP.ASM"
;
