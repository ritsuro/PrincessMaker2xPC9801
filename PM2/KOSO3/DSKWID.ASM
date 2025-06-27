; "DSKWID.ASM" PC-9801UV11 make by R.H 1992/05/20
;					1993/03/29
;
;
;	disk chenger  window.
;
;
; i/o subroutine.

INCLUDE	TSTSET.INC
INCLUDE	DSKCH2.INC
INCLUDE	MESSAGE.INC

PRINTM	MACRO
	LOCAL	L1,L2
	MOV	BX,3		; 3=ウインドウ・メッセージ／上段
	EXTRN	WIDDISK:NEAR	; WINDOWS/ディスクウインドウ
	CALL	WIDDISK		; WINDOWS/ディスクウインドウ
	ENDM

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	DSKWID_OPEN		; ディスク・ウインドウＯＰＥＮ
PUBLIC	DSKWID_CLOSE		; ディスク・ウインドウＣＬＯＳＥ
PUBLIC	DSKWID_SET_MESSAGE	; ディスク・セットメッセージ
PUBLIC	DSKWID_SRT_PRINT	; ディスク・メッセージ表示
PUBLIC	DSKWID_FNAME_PRINT	; ディスク・ファイル名表示
PUBLIC	DSKWID_PATH_NM_SET	; ディスク・パス名セット
PUBLIC	DSKWID_USERWAIT		; ディスク・ユーザ待ち
PUBLIC	DSKWID_USERST_INI	; ディスク・ユーザスタンバイ初期化
PUBLIC	DSKWID_USERSTANBY	; ディスク・ユーザスタンバイ
PUBLIC	DSKWID_LED		; ディスク・アクセスランプ
PUBLIC	DSKWID_ERR_MSG		; ディスク・エラーメッセージ

PUBLIC	DKCMMD			; メッセージ突入モード


; *********************************************************
;	ディスク・ウインドウＯＰＥＮ
; *********************************************************

DSKWID_OPEN	PROC	NEAR
	MOV	FLAG_WINDOWOPEN,0		; window open flag.
	MOV	PATH_NAME_ADRS,OFFSET MSG_DMY	; path name address.
	RET
DSKWID_OPEN	ENDP


; *********************************************************
;	ディスク・ウインドウＣＬＯＳＥ
; *********************************************************

DSKWID_CLOSE	PROC	NEAR
	CMP	FLAG_WINDOWOPEN,0	; window open flag.
	JE	DSKWID_CLOSE_EXIT	;
	MOV	FLAG_WINDOWOPEN,0	; window open flag.
	MOV	BX,2			; 2=ウインドウ・クローズ
	CALLE	WIDDISK			; WINDOWS/ディスクウインドウ

	CALL	RETURN_PALET		; return palet.

DSKWID_CLOSE_EXIT:
	RET
DSKWID_CLOSE	ENDP


; *********************************************************
;	ディスク・セットメッセージ
;	-I- DX : 検索ディスクＩＤ
; *********************************************************

DSKWID_SET_MESSAGE	PROC	NEAR
	MOV	SCH_DISKID,DX			; 検索ディスクＩＤ
	CALL	DSKWID_2NDOPEN			; ディスク・ウインドウＯＰＥＮ
	CALL	MSG_DISKSET			; ディスクセットのメッセージ
	RET
DSKWID_SET_MESSAGE	ENDP


; *********************************************************
;	ディスク・メッセージ表示
;	-I- SI : 表示文字列
;	    BX : 1=上段,2=中段
; *********************************************************

DSKWID_SRT_PRINT	PROC	NEAR
	MOV	STRADRS,SI		; string address.
	PUSH	BX			;
	CALL	DSKWID_2NDOPEN		; ディスク・ウインドウＯＰＥＮ
	POP	BX			;

	MOV	SI,STRADRS		; string address.
	ADD	BX,2			; 4=ウインドウ・メッセージ／中段
	CALLE	WIDDISK			; WINDOWS/ディスクウインドウ

	RET
DSKWID_SRT_PRINT	ENDP


; *********************************************************
;	ディスク・ファイル名表示
;	-I- SI : ファイル名
; *********************************************************

DSKWID_FNAME_PRINT	PROC	NEAR
	MOV	STRADRS,SI		; string address.
	CALL	DSKWID_2NDOPEN		; ディスク・ウインドウＯＰＥＮ

	MOV	SI,STRADRS		; string address.
	MOV	BX,4			; 4=ウインドウ・メッセージ／中段
	CALLE	WIDDISK			; WINDOWS/ディスクウインドウ

	RET
DSKWID_FNAME_PRINT	ENDP


; *********************************************************
;	ディスク・パス名セット
;	-I- SI : ファイル名
; *********************************************************

DSKWID_PATH_NM_SET	PROC	NEAR
	MOV	PATH_NAME_ADRS,SI		; path name address.
	RET
DSKWID_PATH_NM_SET	ENDP


; *********************************************************
;	ディスク・ユーザ待ち
; *********************************************************

DSKWID_USERWAIT	PROC	NEAR
	CALL	DSKWID_2NDOPEN		; ディスク・ウインドウＯＰＥＮ
	MOV	BX,10			; 10=ウインドウＷＡＩＴ
	CALLE	WIDDISK			; WINDOWS/ディスクウインドウ
	RET
DSKWID_USERWAIT	ENDP


; *********************************************************
;	ディスク・ユーザスタンバイ初期化
; *********************************************************

DSKWID_USERST_INI	PROC	NEAR
	CALLE	MUSWAT				; マウスボタンＯＦＦ待ち
	CALLE	MUSSHT				; マウス読み込み・ワンショット
	RET
DSKWID_USERST_INI	ENDP


; *********************************************************
;	ディスク・ユーザスタンバイ
;	-O- BX : 1=スタンバイ,0=通常
;	    CX : 1=強制終了,0=通常
; *********************************************************

DSKWID_USERSTANBY	PROC	NEAR
	CALLE	MUSSHT			; マウス読み込み・ワンショット
	CMP	DH,0			; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	DSKWID_USERSTANBY_OK	;
	CMP	DL,0			; 右ボタン（1：ＯＦＦ／0：ＯＮ）
	JE	DSKWID_USERSTANBY_OK_BREAK

	MOV	BX,0			; 0=通常
	MOV	CX,0			; 0=通常
	RET
DSKWID_USERSTANBY_OK:
	MOV	BX,1			; 1=スタンバイ
	MOV	CX,0			; 0=通常
	RET
DSKWID_USERSTANBY_OK_BREAK:
	MOV	BX,1			; 1=スタンバイ
	MOV	CX,1			; 1=強制終了
	RET
DSKWID_USERSTANBY	ENDP


; *********************************************************
;	ディスク・アクセスランプ
;	-I- BX : 0=OFF,1=read,2=write.
; *********************************************************

DSKWID_LED	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	DX
	PUSH	SI

	MOV	DX,BX			; 0=OFF,1=ON(アクセスランプ)
	MOV	BX,12			; 12=アクセスランプ
	CALLE	WIDDISK			; WINDOWS/ディスクウインドウ

	POP	SI
	POP	DX
	POP	BX
	POP	AX
	RET
DSKWID_LED	ENDP


; *********************************************************
;	ディスク・エラーメッセージ
;	-I- SI : file name.
; *********************************************************

DSKWID_ERR_MSG	PROC	NEAR
	MOV	STRADRS,SI		; string address.

	MESSAGE	3			;"SYSTEM ERROR"
	MOV	PATH_NAME_ADRS,SI	; path name address.

	CALL	DSKWID_2NDOPEN		; ディスク・ウインドウＯＰＥＮ

	MESSAGE	2			;"ファイルが見つかりません"
	MOV	BX,3			; 3=ウインドウ・メッセージ／上段
	CALLE	WIDDISK			; WINDOWS/ディスクウインドウ

	MOV	SI,STRADRS		; string address.
	MOV	BX,4			; 4=ウインドウ・メッセージ／中段
	CALLE	WIDDISK			; WINDOWS/ディスクウインドウ

	MOV	BX,10			; 10=ウインドウＷＡＩＴ
	CALLE	WIDDISK			; WINDOWS/ディスクウインドウ

	MOV	BX,2			; 2=ウインドウ・クローズ
	CALLE	WIDDISK			; WINDOWS/ディスクウインドウ

	MOV	FLAG_WINDOWOPEN,0	; window open flag.

	RET
DSKWID_ERR_MSG	ENDP


; *********************************************************
;	メッセージ突入モード
;	-I- DX : 0=ノーマル,1=真っ黒,2=真っ白
; *********************************************************

DKCMMD	PROC	NEAR
	MOV	MODE_INTO_MSG,DX	; メッセージ突入モード
	RET
DKCMMD	ENDP


; *********************************************************
;	show palet.
; *********************************************************

SHOW_PALET	PROC	NEAR
	CMP	MODE_INTO_MSG,0		; メッセージ突入モード
	JE	SHOW_PALET_EXIT		;
	CALLE	NORMINDISK		; ディスクチェンジ用ノーマルカラー
SHOW_PALET_EXIT:
	RET
SHOW_PALET	ENDP


; *********************************************************
;	return palet.
; *********************************************************

RETURN_PALET	PROC	NEAR
	CMP	MODE_INTO_MSG,1		; 0=ノーマル,1=真っ黒,2=真っ白
	JE	RETURN_PALET_BLACK	;
	CMP	MODE_INTO_MSG,2		; 0=ノーマル,1=真っ黒,2=真っ白
	JE	RETURN_PALET_WHITE	;
	JMP	RETURN_PALET_EXIT
RETURN_PALET_BLACK:
	CALLE	BLACK			; ブラックアウト
	JMP	RETURN_PALET_EXIT
RETURN_PALET_WHITE:
	CALLE	WHITE			; ＷＨＩＴＥ
RETURN_PALET_EXIT:
	RET
RETURN_PALET	ENDP


; *********************************************************
;	ディスク・ウインドウＯＰＥＮ
; *********************************************************

DSKWID_2NDOPEN	PROC	NEAR
	CMP	FLAG_WINDOWOPEN,1	; window open flag.
	JE	DSKWID_2NDOPEN_EXIT	;

	MOV	FLAG_WINDOWOPEN,1	; window open flag.

	MOV	BX,1			; 1=ウインドウ・オープン
	CALLE	WIDDISK			; WINDOWS/ディスクウインドウ

	MOV	SI,PATH_NAME_ADRS	; path name address.
	MOV	BX,11			; 11=ウインドウ・パス名表示
	CALLE	WIDDISK			; WINDOWS/ディスクウインドウ

	CALL	SHOW_PALET		; show palet.

DSKWID_2NDOPEN_EXIT:
	RET
DSKWID_2NDOPEN	ENDP


; *********************************************************
;	ディスクセットのメッセージ
;	-I- SCH_DISKID : 検索ディスクＩＤ
; *********************************************************

MSG_DISKSET	PROC	NEAR
	MOV	DX,SCH_DISKID		; 検索ディスクＩＤ

	CMP	DX,1			; このディスク１の番号
	JNE	MSG_DISKSET1

	MOV	BX,1			; drive number.(1=1,2=2,3=3,4=4)
	MOV	DI,DX			; disk name.(1=A,2=B,3=C...)
	CALLE	MESSAGE_DRVSET		; message drive set.
	PRINTM
	JMP	MSG_DISKSET99
MSG_DISKSET1:
	MOV	BX,2			; drive number.(1=1,2=2,3=3,4=4)
	MOV	DI,DX			; disk name.(1=A,2=B,3=C...)
	CALLE	MESSAGE_DRVSET		; message drive set.
	PRINTM
	JMP	MSG_DISKSET99
MSG_DISKSET99:
	RET
MSG_DISKSET	ENDP


CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

SCH_DISKID	DW	0	; 検索ディスクＩＤ
STRADRS		DW	0	; string address.
FLAG_WINDOWOPEN	DW	0	; window open flag.

PATH_NAME_ADRS	DW	0	; path name address.

MODE_INTO_MSG	DW	0	; メッセージ突入モード
				; 0=ノーマル,1=真っ黒,2=真っ白
MSG_DMY		DB	0,0	; path name address.

DATA	ENDS

	END
;
;	end of "DSKWID.ASM"
;
