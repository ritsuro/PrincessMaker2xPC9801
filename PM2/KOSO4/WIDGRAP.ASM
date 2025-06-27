; "WIDGRAP.ASM" 486/50 make by R.H 1992/05/21
;
;
;	ＷＩＮＤＯＷＳ／パラメータ・ウインドウ
;
;	1993/06/18  パラメータの０未満カットを付けた
;
;
;	WIDGRAPOPEN		; WINDOWS/ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ OPEN
;	WIDGRAPOPEN2		; WINDOWS/ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ OPEN2
;	WIDGRAPCLOSE		; WINDOWS/ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ CLOSE
;	WIDGRAP			; WINDOWS/パラメータ・ウインドウ
;	WIDGRAP_NOFRM		; WINDOWS/ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ･ﾌﾚｰﾑ無し
;	WIDGRAP_UPD		; WINDOWS/パラメータ・更新
;	WIDGRGOLD		; WINDOWS/ﾊﾟﾗﾒｰﾀ 所持金ｳｲﾝﾄﾞｳ
;	WIDGRGOLD_UPD		; WINDOWS/ﾊﾟﾗﾒｰﾀ 所持金・更新
;	WIDGRPROFILE		; WINDOWS/ﾊﾟﾗﾒｰﾀ・プロフィール
;	WIDGRPROPR		; WINDOWS/ﾊﾟﾗﾒｰﾀ・プロポーション
;	WIDGRPROPR_UPD		; WINDOWS/ﾊﾟﾗﾒｰﾀ・ﾌﾟﾛﾎﾟｰｼｮﾝ・更新
;	WIDGR_STATUS		; WINDOWS/ﾊﾟﾗﾒｰﾀ・通常ステータス
;	WIDGRLONGNAME		; WINDOWS/ﾊﾟﾗﾒｰﾀ・長い名前ﾊﾟﾗﾒｰﾀ
;	WIDGR_ARMS		; WINDOWS/ﾊﾟﾗﾒｰﾀ・武器と防具
;	WIDGR_FACE		; WINDOWS/ﾊﾟﾗﾒｰﾀ・フェイス
;	WIDGR_FGIRL		; WINDOWS/ﾊﾟﾗﾒｰﾀ・娘フェイス
;	WIDGR_NAME		; WINDOWS/ﾊﾟﾗﾒｰﾀ・名前
;	WIDGR_NAME_NOFRM	; WINDOWS/ﾊﾟﾗﾒｰﾀ・名前･ﾌﾚｰﾑ無し
;
;
;	ウインドウハンドル(WIDHANDLE)=1-8
;
;
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC

HANDLE_DIM	EQU	5	; ハンドル数
UPDATE_DIM	EQU	8	; 更新テーブル数

FREAM_XL	EQU	25	; フレームＸ幅
GRP_NAME_HIGHT	EQU	16	; グラフ高さ
GRP_SIDE_YL	EQU	8	; グラフ開始Ｙ位置
GRP_SIDE_YEL	EQU	8	; グラフ終了から下Ｙ長さ

GOLD_FREAM_XL	EQU	20	; フレームＸ幅
GOLD_NAME_HIGHT	EQU	19	; ＧＯＬＤ高さ
GOLD_SIDE_YL	EQU	9	; ＧＯＬＤ開始Ｙ位置
GOLD_SIDE_YEL	EQU	7	; ＧＯＬＤ終了から下Ｙ長さ

PROF_FREAM_XL	EQU	26	; フレームＸ幅
PROF_NAME_HIGHT	EQU	18	; プロフィールグラフ高さ
PROF_SIDE_YL	EQU	10	; プロフィール開始Ｙ位置
PROF_SIDE_YEL	EQU	8	; プロフィール終了から下Ｙ長さ

ICON_SIDE_XL	EQU	26	; ICON左サイドＸ長さ
ICON_NAME_HIGHT	EQU	36	; ICONグラフ高さ
ICON_SIDE_YL	EQU	8	; ICON開始Ｙ位置
ICON_SIDE_YEL	EQU	8	; ICON終了から下Ｙ長さ

FACESIZEX	EQU	14	; フェイスサイズＸ
FACESIZEY	EQU	120	; フェイスサイズＹ

NAME_HIGHT	EQU	16	; 名前高さ

NORMAL_BANK	EQU	0	; 通常のパーツバンク番号
BACKSAVE_BANK	EQU	0	; 背景退避用パーツバンク番号

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ OPEN
; ****************************************************

FUNC	WIDGRAPOPEN
	MOV	DX,BACKSAVE_BANK	; 背景退避用パーツバンク番号
	MOV	NOW_SAVE_BANK,DX	; 現在背景退避用パーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ
	CALL_w	C1PATCLR		; パーツセットクリア
	MOV	BACK_COUNT,0		; back save count.
	MOV	FLAG_BACKUP,1		; flag backup area.
	RET
FEND	WIDGRAPOPEN


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ OPEN2
;	-I- DX : 背景退避用パーツバンク番号
; ****************************************************

FUNC	WIDGRAPOPEN2
	MOV	NOW_SAVE_BANK,DX	; 現在背景退避用パーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ
	CALL_w	C1PATCLR		; パーツセットクリア
	MOV	BACK_COUNT,0		; back save count.
	MOV	FLAG_BACKUP,1		; flag backup area.
	RET
FEND	WIDGRAPOPEN2


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ CLOSE
; ****************************************************

FUNC	WIDGRAPCLOSE
	CALL	BACK_LOAD		; 画面復元
	MOV	FLAG_BACKUP,0		; flag backup area.
	RET
FEND	WIDGRAPCLOSE


; ****************************************************
;	WINDOWS/パラメータ・ウインドウ
;	表示タイプ１から表示タイプ４まで
;	-I- DX          : ウインドウタイプ
;	    CX          : ウインドウハンドル
;	    IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL3[] : グラフテーブル／パラメータ値
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

FUNC	WIDGRAP
	MOV	WIDTYPE,DX		; ウインドウタイプ
	MOV	WIDHANDLE,CX		; ウインドウハンドル

	CALL	HANDLE_ASSIGN		; handle assign.
	CALL	VRAM_ASSIGN		; vram assign.
	CALL	WID_PR_FRAME		; パラメータウインドウFRAME
	CALL	WID_PR_OPEN_VAL		; パラメータウインドウ数値計表示
	RET
FEND	WIDGRAP


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ･ｳｲﾝﾄﾞｳ･ﾌﾚｰﾑ無し
;	表示タイプ１から表示タイプ４まで
;	-I- DX          : ウインドウタイプ
;	    CX          : ウインドウハンドル
;	    IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL3[] : グラフテーブル／パラメータ値
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

FUNC	WIDGRAP_NOFRM
	MOV	WIDTYPE,DX		; ウインドウタイプ
	MOV	WIDHANDLE,CX		; ウインドウハンドル

	CALL	HANDLE_ASSIGN		; handle assign.
	CALL	VRAM_ASSIGN		; vram assign.
	CALL	WID_PR_OPEN_VAL		; パラメータウインドウ数値計表示
	RET
FEND	WIDGRAP_NOFRM


; ****************************************************
;	WINDOWS/パラメータ・更新
;	表示タイプ１から表示タイプ４まで
;	-I- AX : パラメータ通し番号
;	    CX : ウインドウハンドル
;	    DX : パラメータ値
; ****************************************************

FUNC	WIDGRAP_UPD
	MOV	WID_IPNT,AX		; パラメータ通し番号
	MOV	WIDHANDLE,CX		; ウインドウハンドル
	MOV	DP_VALUE,DX		; パラメータ値

	CALL	HANDLE_LOAD		; handle load.

	CALL	VRAM_ASSIGN		; vram assign.
	MOVX	IPNT,WID_IPNT		; 通し番号
	CALL	WIDONEGRP_UPD		; グラフ１本・更新
	RET
FEND	WIDGRAP_UPD


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ 所持金ｳｲﾝﾄﾞｳ
;	表示タイプ５（ＧＯＬＤ）
;	-I- DX          : ウインドウタイプ
;	    CX          : ウインドウハンドル
;	    IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL3[] : グラフテーブル／パラメータ値
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

FUNC	WIDGRGOLD
	MOV	WIDTYPE,DX		; ウインドウタイプ
	MOV	WIDHANDLE,CX		; ウインドウハンドル

	CALL	HANDLE_ASSIGN		; handle assign.
	CALL	VRAM_ASSIGN		; vram assign.
	CALL	WID_GOLD_OPEN		; 所持金ｳｲﾝﾄﾞｳOPEN
	RET
FEND	WIDGRGOLD


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ 所持金・更新
;	-I- AX : パラメータ通し番号
;	    CX : ウインドウハンドル
;	    DX : パラメータ値
; ****************************************************

FUNC	WIDGRGOLD_UPD
	MOV	WID_IPNT,AX		; パラメータ通し番号
	MOV	WIDHANDLE,CX		; ウインドウハンドル
	MOV	DP_VALUE,DX		; パラメータ値

	CALL	HANDLE_LOAD		; handle load.

	CALL	VRAM_ASSIGN		; vram assign.
	MOVX	IPNT,WID_IPNT		; 通し番号
	CALL	WIDONEGOLD_UPD		; ＧＯＬＤ１本･更新
	RET
FEND	WIDGRGOLD_UPD


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ・プロフィール
;	表示タイプ６（プロフィール）
;	-I- IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL3[] : グラフテーブル／表示文字列
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

FUNC	WIDGRPROFILE
	CALL	VRAM_ASSIGN		; vram assign.
	CALL	WID_PROF_OPEN		; プロフィール・ｳｲﾝﾄﾞｳOPEN
	RET
FEND	WIDGRPROFILE


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ・プロポーション
;	表示タイプ７（プロポーション）
;	-I- DX          : ウインドウタイプ
;	    CX          : ウインドウハンドル
;	    IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL3[] : グラフテーブル／パラメータ値
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

FUNC	WIDGRPROPR
	MOV	WIDTYPE,DX		; ウインドウタイプ
	MOV	WIDHANDLE,CX		; ウインドウハンドル

	CALL	HANDLE_ASSIGN		; handle assign.
	CALL	VRAM_ASSIGN		; vram assign.
	CALL	WID_PROPR_OPEN		; プロポーションウインドウOPEN
	RET
FEND	WIDGRPROPR


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ・ﾌﾟﾛﾎﾟｰｼｮﾝ・更新
;	-I- AX : パラメータ通し番号
;	    CX : ウインドウハンドル
;	    DX : パラメータ値
; ****************************************************

FUNC	WIDGRPROPR_UPD
	MOV	WID_IPNT,AX		; パラメータ通し番号
	MOV	WIDHANDLE,CX		; ウインドウハンドル
	MOV	DP_VALUE,DX		; パラメータ値

	CALL	HANDLE_LOAD		; handle load.

	CALL	VRAM_ASSIGN		; vram assign.
	MOVX	IPNT,WID_IPNT		; 通し番号
	CALL	WIDONEPROPR_UPD		; プロポーション１本・更新
	RET
FEND	WIDGRPROPR_UPD


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ・通常ステータス
;	表示タイプ８（通常ステータス）
;	-I- DX          : ウインドウタイプ
;	    CX          : ウインドウハンドル
;	    IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL3[] : パラメータ値
;		IGRP_TBL3[0] : 病気指数(%)
;		IGRP_TBL3[2] : 非行化指数(%)
;		IGRP_TBL3[4] : 人脈
;		IGRP_TBL3[6] : 1=病気
;		IGRP_TBL3[8] : 1=非行化
;		IGRP_TBL3[10]: 1=恋愛
;		IGRP_TBL3[12]: 健康管理
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

FUNC	WIDGR_STATUS
	MOV	WIDTYPE,DX		; ウインドウタイプ
	MOV	WIDHANDLE,CX		; ウインドウハンドル

	CALL	HANDLE_ASSIGN		; handle assign.
	CALL	VRAM_ASSIGN		; vram assign.
	CALL	WID_STATUS_OPEN		; 通常ステータスウインドウOPEN
	RET
FEND	WIDGR_STATUS


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ・長い名前ﾊﾟﾗﾒｰﾀ
;	-I- IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL3[] : グラフテーブル／表示文字列
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

FUNC	WIDGRLONGNAME
	CALL	VRAM_ASSIGN		; vram assign.
	CALL	WID_LONGN_OPEN		; 長い名前ﾊﾟﾗﾒｰﾀ・ｳｲﾝﾄﾞｳOPEN
	RET
FEND	WIDGRLONGNAME


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ・武器と防具
;	-I- IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL2[] : グラフテーブル／ＩＣＯＮ番号
;	    IGRP_TBL3[] : グラフテーブル／内容
;	    IGRP_TBL4[] : グラフテーブル／項目名
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

FUNC	WIDGR_ARMS
	CALL	VRAM_ASSIGN		; vram assign.
	CALL	WID_ICON_OPEN		; ICONｳｲﾝﾄﾞｳOPEN
	RET
FEND	WIDGR_ARMS


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ・フェイス
;	-I- SI     : file name.
;	    IGRP_X : グラフＸ
;	    IGRP_Y : グラフＹ
; ****************************************************

FUNC	WIDGR_FACE
	MOV	FLNAME,SI		; file name.

	CALL	SETING_FACE		; setting face.

	CALL	VRAM_ASSIGN		; vram assign.
	CALL	WID_FACE_OPEN		; フェイスOPEN
	RET
FEND	WIDGR_FACE


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ・娘フェイス
;	-I- DX : girl face.
;	         0=普通 1=嬉しい 2=怒り 3=悲しい 4=暑い
;	         5=寒い 6=大怪我 7=苦しい 8=すねる
;	         9=不思議 10=恥らう 11=不安 12=不愉快
;	        13=妖しい 14=りりしい 15=驚き 16=ガーン
;	        17=真剣 18=困り
;	    IGRP_X : グラフＸ
;	    IGRP_Y : グラフＹ
; ****************************************************

FUNC	WIDGR_FGIRL
	MOV	WD_FACE_GIRL,DX		; girl face.

	CALL	SETING_FACE		; setting face.

	CALL	VRAM_ASSIGN		; vram assign.
	CALL	WID_FACEGIRL_OPEN	; 娘フェイスOPEN
	RET
FEND	WIDGR_FGIRL


; ****************************************************
;	setting face.
; ****************************************************

SETING_FACE	PROC	NEAR
	MOV	AX,IGRP_X		; グラフＸ
	MOV	BX,IGRP_Y		; グラフＹ
	MOV	WID_XFB,AX		; フェイス退避Ｘ
	MOV	WID_YFB,BX		; フェイス退避Ｙ
	INC	AX			;
	ADD	BX,8			;
	MOV	WID_XF,AX		; フェイス左上Ｘ
	MOV	WID_YF,BX		; フェイス左上Ｙ
	MOV	WID_XFL,FACESIZEX	; フェイスサイズＸ
	MOV	WID_YFL,FACESIZEY	; フェイスサイズＹ
	RET
SETING_FACE	ENDP


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ・名前
;	-I- SI     : 名前
;	    IGRP_X : グラフＸ
;	    IGRP_Y : グラフＹ
; ****************************************************

FUNC	WIDGR_NAME
	MOV	DP_NAME,SI		; 名前

	CALL	VRAM_ASSIGN		; vram assign.

	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ
	MOV	WDX2,FREAM_XL-1		; フレームＸ幅
	MOV	AX,NAME_HIGHT		; 名前高さ
	ADD	AX,GRP_SIDE_YL+GRP_SIDE_YEL
	MOV	WDY2,AX			; 大きさＹ
	CALL	BACK_SAVE		; 画面退避
	CALL_w	WID_FLAME_GRAPH		; WINDOWS/フレーム・グラフ

	MOV	DX,0			; 通し番号
	MOV	SI,DP_NAME		; 名前
	CALL_w	WID_FRAME_G_PNAME	; WINDOWS/パラメータ名を書く

	RET
FEND	WIDGR_NAME


; ****************************************************
;	WINDOWS/ﾊﾟﾗﾒｰﾀ・名前･ﾌﾚｰﾑ無し
;	-I- SI     : 名前
;	    IGRP_X : グラフＸ
;	    IGRP_Y : グラフＹ
; ****************************************************

FUNC	WIDGR_NAME_NOFRM
	MOV	DP_NAME,SI		; 名前

	CALL	VRAM_ASSIGN		; vram assign.

	MOV	AX,0			; 0=16x16
	CALL_w	VTXSIZ			; character size set.

	MOV	AX,0			; グラフ文字表示色
	CALL_w	VTXCOL			; character color set.
	MOV	AX,IGRP_X		; グラフＸ
	MOV	BX,IGRP_Y		; グラフＹ
	INC	BX			;
	INC	BX			;
	MOV	SI,DP_NAME		; 名前
	CALL_w	VTXPOR			; vram text print OR.

	MOV	AX,IGRP_X		; グラフＸ
	MOV	BX,IGRP_Y		; グラフＹ
	INC	BX			;
	MOV	SI,DP_NAME		; 名前
	CALL_w	VTXPOR			; vram text print OR.

	MOV	AX,15			; グラフ文字表示色
	CALL_w	VTXCOL			; character color set.
	MOV	AX,IGRP_X		; グラフＸ
	MOV	BX,IGRP_Y		; グラフＹ
	MOV	SI,DP_NAME		; 名前
	CALL_w	VTXPOR			; vram text print OR.

	RET
FEND	WIDGR_NAME_NOFRM


; ****************************************************
;	通常ステータスウインドウOPEN
;	-I- IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL3[] : パラメータ値
;		IGRP_TBL3[0] : 病気指数(%)
;		IGRP_TBL3[2] : 非行化指数(%)
;		IGRP_TBL3[4] : 人脈
;		IGRP_TBL3[6] : 1=病気
;		IGRP_TBL3[8] : 1=非行化
;		IGRP_TBL3[10]: 1=恋愛
;		IGRP_TBL3[12]: 健康管理
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

WID_STATUS_OPEN	PROC	NEAR
	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ
	MOV	WDX2,20			; 大きさＸ
	MOV	WDY2,18*7+20		; 大きさＹ
	CALL	BACK_SAVE		; 画面退避
	CALL_w	WID_FRAME_STATUS	; WINDOWS/フレーム・ｽﾃｰﾀｽｳｲﾝﾄﾞｳ

	MOV	DX,0			; グラフ番号 0=病気指数(%)
	MOV	SI,IGRP_TBL1[0]		; 名前
	MOV	AX,IGRP_TBL3[0]		; パラメータ値
	CALL_w	WID_FRAME_STATUS_PAR	; WINDOWS/フレーム・ｽﾃｰﾀｽ・％表示

	MOV	DX,1			; グラフ番号 1=非行化指数(%)
	MOV	SI,IGRP_TBL1[2]		; 名前
	MOV	AX,IGRP_TBL3[2]		; パラメータ値
	CALL_w	WID_FRAME_STATUS_PAR	; WINDOWS/フレーム・ｽﾃｰﾀｽ・％表示

	MOV	DX,2			; グラフ番号 2=人脈
	MOV	SI,IGRP_TBL1[4]		; 名前
	MOV	AX,IGRP_TBL3[4]		; ポイント値
	CALL_w	WID_FRAME_STATUS_VAL	; WINDOWS/フレーム・ｽﾃｰﾀｽ・ﾎﾟｲﾝﾄ値表示

	MOV	DX,3			; グラフ番号 3=病気
	MOV	SI,IGRP_TBL1[6]		; 名前
	MOV	AX,IGRP_TBL3[6]		; フラグＯＮ／ＯＦＦ
	CALL_w	WID_FRAME_STATUS_FLAG	; WINDOWS/フレーム・ｽﾃｰﾀｽ・ﾌﾗｸﾞON表示

	MOV	DX,4			; グラフ番号 4=非行化
	MOV	SI,IGRP_TBL1[8]		; 名前
	MOV	AX,IGRP_TBL3[8]		; フラグＯＮ／ＯＦＦ
	CALL_w	WID_FRAME_STATUS_FLAG	; WINDOWS/フレーム・ｽﾃｰﾀｽ・ﾌﾗｸﾞON表示

	MOV	DX,5			; グラフ番号 5=恋愛
	MOV	SI,IGRP_TBL1[10]	; 名前
	MOV	AX,IGRP_TBL3[10]	; フラグＯＮ／ＯＦＦ
	CALL_w	WID_FRAME_STATUS_FLAG	; WINDOWS/フレーム・ｽﾃｰﾀｽ・ﾌﾗｸﾞON表示

	MOV	DX,6			; グラフ番号 6=健康管理
	MOV	SI,IGRP_TBL1[12]	; 名前
	MOV	AX,IGRP_TBL3[12]	; フラグＯＮ／ＯＦＦ
	CALL_w	WID_FRAME_STATUS_FLAG	; WINDOWS/フレーム・ｽﾃｰﾀｽ・ﾌﾗｸﾞON表示

	RET
WID_STATUS_OPEN	ENDP


; ****************************************************
;	プロポーションウインドウOPEN
;	-I- WIDTYPE     : ウインドウタイプ
;	    IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL2[] : グラフテーブル／タイプ
;	    IGRP_TBL3[] : グラフテーブル／パラメータ値
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

WID_PROPR_OPEN	PROC	NEAR
	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ
	MOV	WDX2,FREAM_XL-1		; フレームＸ幅
	MOV	AX,GRP_NAME_HIGHT	; グラフ高さ
	MUL	IGRP_CNT		; グラフテーブル数
	ADD	AX,GRP_SIDE_YL+GRP_SIDE_YEL
	MOV	WDY2,AX			; 大きさＹ
	CALL	BACK_SAVE		; 画面退避
	CALL_w	WID_FRAME_PROPR		; WINDOWS/フレーム・プロポーション

	MOV	IPNT,0			; 通し番号

	MOV	CX,IGRP_CNT		; グラフテーブル数
	JCXZ	WID_PROPR_OPEN_EXIT	;
WID_PROPR_OPEN_LOOP:
	PUSH	CX

	MOV	BX,IPNT			; 通し番号
	SHL	BX,1			; word pointer.
	MOVX	DP_NAME,IGRP_TBL1[BX]	; グラフテーブル／名前
	MOVX	DP_TYPE,IGRP_TBL2[BX]	; グラフテーブル／タイプ
	MOVX	DP_VALUE,IGRP_TBL3[BX]	; グラフテーブル／パラメータ値

	CALL	WIDONEPROPR		; プロポーション１本描画

	INC	IPNT			; 通し番号
	POP	CX
	LOOP	WID_PROPR_OPEN_LOOP
WID_PROPR_OPEN_EXIT:
	RET
	RET
WID_PROPR_OPEN	ENDP


; ****************************************************
;	プロフィール・ｳｲﾝﾄﾞｳOPEN
;	-I- IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL3[] : グラフテーブル／表示文字列
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

WID_PROF_OPEN	PROC	NEAR
	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ
	MOV	WDX2,PROF_FREAM_XL	; フレームＸ幅
	MOV	AX,PROF_NAME_HIGHT	; プロフィールグラフ高さ
	MUL	IGRP_CNT		; グラフテーブル数
	ADD	AX,PROF_SIDE_YL+PROF_SIDE_YEL
	MOV	WDY2,AX			; 大きさＹ
	CALL	BACK_SAVE		; 画面退避
	CALL_w	WID_FRAME_PROFILE	; WINDOWS/フレーム・プロフィール

	MOV	IPNT,0			; 通し番号

	MOV	CX,IGRP_CNT		; グラフテーブル数
	JCXZ	WID_PROF_OPEN_EXIT	;
WID_PROF_OPEN_LOOP:			;
	PUSH	CX			;

	MOV	BX,IPNT			; 通し番号
	SHL	BX,1			; word pointer.
	MOV	DX,IPNT			; 通し番号
	MOV	SI,IGRP_TBL1[BX]	; グラフテーブル／名前
	MOV	DI,IGRP_TBL3[BX]	; グラフテーブル／表示文字列
	CALL_w	WID_FRAME_PROFONE	; WINDOWS/プロフィール１行書く

	INC	IPNT			; 通し番号
	POP	CX			;
	LOOP	WID_PROF_OPEN_LOOP	;
WID_PROF_OPEN_EXIT:
	RET
WID_PROF_OPEN	ENDP


; ****************************************************
;	長い名前ﾊﾟﾗﾒｰﾀ・ｳｲﾝﾄﾞｳOPEN
;	フレームはプロフィール兼用
;	-I- IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL3[] : グラフテーブル／パラメータ値
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

WID_LONGN_OPEN	PROC	NEAR
	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ
	MOV	WDX2,PROF_FREAM_XL	; フレームＸ幅
	MOV	AX,PROF_NAME_HIGHT	; プロフィールグラフ高さ
	MUL	IGRP_CNT		; グラフテーブル数
	ADD	AX,PROF_SIDE_YL+PROF_SIDE_YEL
	MOV	WDY2,AX			; 大きさＹ
	CALL	BACK_SAVE		; 画面退避
	CALL_w	WID_FRAME_PROFILE	; WINDOWS/フレーム・プロフィール

	MOV	IPNT,0			; 通し番号

	MOV	CX,IGRP_CNT		; グラフテーブル数
	JCXZ	WID_LONGN_OPEN_EXIT	;
WID_LONGN_OPEN_LOOP:			;
	PUSH	CX			;

	MOV	BX,IPNT			; 通し番号
	SHL	BX,1			; word pointer.
	MOV	DX,IPNT			; 通し番号
	MOV	SI,IGRP_TBL1[BX]	; グラフテーブル／名前
	MOV	AX,IGRP_TBL3[BX]	; グラフテーブル／パラメータ値
	CALL_w	WID_FRAME_LONGN		; WINDOWS/長い名前ﾊﾟﾗﾒｰﾀ・ｳｲﾝﾄﾞｳ１行書く

	INC	IPNT			; 通し番号
	POP	CX			;
	LOOP	WID_LONGN_OPEN_LOOP	;
WID_LONGN_OPEN_EXIT:
	RET
WID_LONGN_OPEN	ENDP


; ****************************************************
;	ICONｳｲﾝﾄﾞｳOPEN
;	-I- IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL2[] : グラフテーブル／ＩＣＯＮ番号
;	    IGRP_TBL3[] : グラフテーブル／内容
;	    IGRP_TBL4[] : グラフテーブル／項目名
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

WID_ICON_OPEN	PROC	NEAR
	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ
	MOV	WDX2,ICON_SIDE_XL	; ICON左サイドＸ長さ
	MOV	AX,ICON_NAME_HIGHT	; ICONグラフ高さ
	MUL	IGRP_CNT		; グラフテーブル数
	ADD	AX,ICON_SIDE_YL+ICON_SIDE_YEL
	MOV	WDY2,AX			; 大きさＹ
	CALL	BACK_SAVE		; 画面退避
	CALL_w	WID_FRAME_PROFILE	; WINDOWS/フレーム・プロフィール

	MOV	IPNT,0			; 通し番号

	MOV	CX,IGRP_CNT		; グラフテーブル数
	JCXZ	WID_ICON_OPEN_EXIT	;
WID_ICON_OPEN_LOOP:			;
	PUSH	CX			;

	MOV	BX,IPNT			; 通し番号
	SHL	BX,1			; word pointer.
	MOV	DX,IGRP_TBL1[BX]	; グラフテーブル／名前
	MOV	AX,IGRP_TBL2[BX]	; グラフテーブル／ＩＣＯＮ番号
	MOV	SI,IGRP_TBL3[BX]	; グラフテーブル／内容
	MOV	CX,IGRP_TBL4[BX]	; グラフテーブル／項目名
	MOV	BX,IPNT			; 通し番号
	CALL_w	WID_FRAME_ICON_PARA	; WINDOWS/フレーム・ICONﾊﾟﾗﾒｰﾀ表示

	INC	IPNT			; 通し番号
	POP	CX			;
	LOOP	WID_ICON_OPEN_LOOP	;
WID_ICON_OPEN_EXIT:
	RET
WID_ICON_OPEN	ENDP


; ****************************************************
;	フェイスOPEN
;	-I- FLNAME  : file name.
;	    WID_XF  : フェイス左上Ｘ
;	    WID_YF  : フェイス左上Ｙ
;	    WID_XFB : フェイス退避Ｘ
;	    WID_YFB : フェイス退避Ｙ
;	    WID_XFL : フェイスサイズＸ
;	    WID_YFL : フェイスサイズＹ
; ****************************************************

WID_FACE_OPEN	PROC	NEAR
	CALL	FACE_FRAME		; フェイスフレーム

	MOVX	WDX1,WID_XF		; フェイス左上Ｘ
	MOVX	WDY1,WID_YF		; フェイス左上Ｙ
	MOV	SI,FLNAME		; file name.
	CALL_w	WIDFACE			; WINDOWS/フェイス・ウインドウ
	RET
WID_FACE_OPEN	ENDP


; ****************************************************
;	娘フェイスOPEN
;	-I- WD_FACE_GIRL : girl face.
;	         0=普通 1=嬉しい 2=怒り 3=悲しい 4=暑い
;	         5=寒い 6=大怪我 7=苦しい 8=すねる
;	         9=不思議 10=恥らう 11=不安 12=不愉快
;	        13=妖しい 14=りりしい 15=驚き 16=ガーン
;	        17=真剣 18=困り
;	    WID_XF  : フェイス左上Ｘ
;	    WID_YF  : フェイス左上Ｙ
;	    WID_XFB : フェイス退避Ｘ
;	    WID_YFB : フェイス退避Ｙ
;	    WID_XFL : フェイスサイズＸ
;	    WID_YFL : フェイスサイズＹ
; ****************************************************

WID_FACEGIRL_OPEN	PROC	NEAR
	CALL	FACE_FRAME		; フェイスフレーム

	MOVX	WDX1,WID_XF		; フェイス左上Ｘ
	MOVX	WDY1,WID_YF		; フェイス左上Ｙ
	CALL_w	WIDFACEGIRL		; WINDOWS/フェイス・娘ウインドウ
	RET
WID_FACEGIRL_OPEN	ENDP


; ****************************************************
;	フェイスフレーム
; ****************************************************

FACE_FRAME	PROC	NEAR
	MOVX	WDX1,WID_XFB		; window フェイス退避Ｘ
	MOVX	WDY1,WID_YFB		; window フェイス退避Ｙ
	MOVX	WDX2,WID_XFL		; window フェイスサイズＸ
	MOVX	WDY2,WID_YFL		; window フェイスサイズＹ
	CALL	BACK_SAVE		; 画面退避

	MOVX	WDX1,WID_XFB		; window フェイス退避Ｘ
	MOVX	WDY1,WID_YFB		; window フェイス退避Ｙ
	CALL_w	WID_FLAME_FACE		; WINDOWS/フレーム・フェイス

	RET
FACE_FRAME	ENDP


; ****************************************************
;	所持金ｳｲﾝﾄﾞｳOPEN
;	-I- IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL3[] : グラフテーブル／パラメータ値
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

WID_GOLD_OPEN	PROC	NEAR
	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ
	MOV	WDX2,GOLD_FREAM_XL	; フレームＸ幅
	MOV	AX,GOLD_NAME_HIGHT	; ＧＯＬＤ高さ
	MUL	IGRP_CNT		; グラフテーブル数
	ADD	AX,GOLD_SIDE_YL+GOLD_SIDE_YEL
	MOV	WDY2,AX			; 大きさＹ
	CALL	BACK_SAVE		; 画面退避
	CALL_w	WID_FLAME_GOLD		; WINDOWS/フレーム・ＧＯＬＤ

	MOV	IPNT,0			; 通し番号

	MOV	CX,IGRP_CNT		; グラフテーブル数
	JCXZ	WID_GOLD_OPEN_EXIT	;
WID_GOLD_OPEN_LOOP:
	PUSH	CX

	MOV	BX,IPNT			; 通し番号
	SHL	BX,1			; word pointer.
	MOVX	DP_NAME,IGRP_TBL1[BX]	; グラフテーブル／名前
	MOVX	DP_VALUE,IGRP_TBL3[BX]	; グラフテーブル／パラメータ値

	CALL	WIDONEGOLD		; ＧＯＬＤ１本描画

	INC	IPNT			; 通し番号
	POP	CX
	LOOP	WID_GOLD_OPEN_LOOP	;
WID_GOLD_OPEN_EXIT:
	RET
WID_GOLD_OPEN	ENDP


; ****************************************************
;	vram assign.
; ****************************************************

VRAM_ASSIGN	PROC	NEAR
	CALL_w	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.
	RET
VRAM_ASSIGN	ENDP


; ****************************************************
;	handle assign.
;	-I-   IGRP_CNT    : グラフテーブル数
;	      IGRP_X      : グラフＸ
;	      IGRP_Y      : グラフＹ
;	-I/O- WIDHANDLE   : ウインドウハンドル
; ****************************************************

HANDLE_ASSIGN	PROC	NEAR
	CMPX	WIDHANDLE,HDL_DIM	; handle dimension.
	JBE	HANDLE_ASSIGN_2		;
	MOVX	WIDHANDLE,HDL_DIM	; handle dimension.
HANDLE_ASSIGN_2:
	CMP	WIDHANDLE,0		; handle dimension.
	JE	HANDLE_ASSIGN_EXIT	;

	MOV	BX,WIDHANDLE		; handle dimension.
	DEC	BX			;
	SHL	BX,1			; word pointer.
	MOVX	HDL_WIDTYPE[BX],WIDTYPE	; handle window type.
	MOVX	HDL_LOC_X[BX],IGRP_X	; handle location x.
	MOVX	HDL_LOC_Y[BX],IGRP_Y	; handle location y.
	MOVX	HDL_TBL_MAX[BX],IGRP_CNT ; handle table max.

	MOV	BX,UPDATE_DIM		; 更新テーブル数
	MOV	AX,WIDHANDLE		; handle dimension.
	MUL	BX			; AX = BX * AX
	SHL	AX,1			; word pointer.
	MOV	DI,OFFSET HDL_UPDATETBL	; handle update table.
	MOV	CX,HDL_UPDATETBL	; word counter.
	CALL	WORD_FILL		; word fill.

	MOV	BX,UPDATE_DIM		; 更新テーブル数
	MOV	AX,WIDHANDLE		; handle dimension.
	MUL	BX			; AX = BX * AX
	SHL	AX,1			; word pointer.
	ADD	AX,OFFSET HDL_UPDATETBL	; handle update table.
	MOV	WIDUPDATEADRS,AX	; ウインドウ更新ﾃｰﾌﾞﾙｱﾄﾞﾚｽ

HANDLE_ASSIGN_EXIT:
	RET
HANDLE_ASSIGN	ENDP


; ****************************************************
;	handle load.
;	-I/O- WIDHANDLE   : ウインドウハンドル
;	-0-   IGRP_CNT    : グラフテーブル数
;	      IGRP_X      : グラフＸ
;	      IGRP_Y      : グラフＹ
; ****************************************************

HANDLE_LOAD	PROC	NEAR
	CMPX	WIDHANDLE,HDL_DIM	; handle dimension.
	JBE	HANDLE_LOAD_2		;
	MOVX	WIDHANDLE,HDL_DIM	; handle dimension.
HANDLE_LOAD_2:
	CMP	WIDHANDLE,0		; handle dimension.
	JE	HANDLE_LOAD_EXIT	;

	MOV	BX,WIDHANDLE		; handle dimension.
	DEC	BX			;
	SHL	BX,1			; word pointer.
	MOVX	WIDTYPE,HDL_WIDTYPE[BX]	; handle window type.
	MOVX	IGRP_X,HDL_LOC_X[BX]	; handle location x.
	MOVX	IGRP_Y,HDL_LOC_Y[BX]	; handle location y.
	MOVX	IGRP_CNT,HDL_TBL_MAX[BX] ; handle table max.

	MOV	BX,UPDATE_DIM		; 更新テーブル数
	MOV	AX,WIDHANDLE		; handle dimension.
	MUL	BX			; AX = BX * AX
	SHL	AX,1			; word pointer.
	ADD	AX,OFFSET HDL_UPDATETBL	; handle update table.
	MOV	WIDUPDATEADRS,AX	; ウインドウ更新ﾃｰﾌﾞﾙｱﾄﾞﾚｽ

HANDLE_LOAD_EXIT:
	RET
HANDLE_LOAD	ENDP


; ****************************************************
;	パラメータウインドウFRAME
;	-I- WIDTYPE     : ウインドウタイプ
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

WID_PR_FRAME	PROC	NEAR
	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ
	MOV	WDX2,FREAM_XL-1		; フレームＸ幅
	MOV	AX,GRP_NAME_HIGHT	; グラフ高さ
	MUL	IGRP_CNT		; グラフテーブル数
	ADD	AX,GRP_SIDE_YL+GRP_SIDE_YEL
	MOV	WDY2,AX			; 大きさＹ
	CALL	BACK_SAVE		; 画面退避
	CALL_w	WID_FLAME_GRAPH		; WINDOWS/フレーム・グラフ
	RET
WID_PR_FRAME	ENDP


; ****************************************************
;	パラメータウインドウ数値計表示
;	-I- WIDTYPE     : ウインドウタイプ
;	    IGRP_TBL1[] : グラフテーブル／名前
;	    IGRP_TBL2[] : グラフテーブル／タイプ
;	    IGRP_TBL3[] : グラフテーブル／パラメータ値
;	    IGRP_CNT    : グラフテーブル数
;	    IGRP_X      : グラフＸ
;	    IGRP_Y      : グラフＹ
; ****************************************************

WID_PR_OPEN_VAL	PROC	NEAR
	MOV	IPNT,0			; 通し番号

	MOV	CX,IGRP_CNT		; グラフテーブル数
	JCXZ	WID_PR_OPEN_VAL_EXIT	;
WID_PR_OPEN_VAL_LOOP:
	PUSH	CX

	MOV	BX,IPNT			; 通し番号
	SHL	BX,1			; word pointer.
	MOVX	DP_NAME,IGRP_TBL1[BX]	; グラフテーブル／名前
	MOVX	DP_TYPE,IGRP_TBL2[BX]	; グラフテーブル／タイプ
	MOVX	DP_VALUE,IGRP_TBL3[BX]	; グラフテーブル／パラメータ値
	CALL	WIDONEGRP		; グラフィック１本描画

	MOV	BX,IPNT			; 通し番号
	MOV	DX,DP_VALUE		; value.
	CALL	PARA_UPDATE_WT		; パラメータ更新テーブルセット

	INC	IPNT			; 通し番号
	POP	CX
	LOOP	WID_PR_OPEN_VAL_LOOP
WID_PR_OPEN_VAL_EXIT:
	RET
WID_PR_OPEN_VAL	ENDP


; ****************************************************
;	ウインドウＣＬＯＳＥ
; ****************************************************

WIDCLOSE	PROC	NEAR
	RET
WIDCLOSE	ENDP


; ****************************************************
;	グラフ１本描画
;	-I- IGRP_X   : グラフＸ
;	    IGRP_Y   : グラフＹ
;	    IPNT     : 通し番号
;	    DP_NAME  : 名前
;	    DP_VALUE : パラメータ値
;	    WIDTYPE  : ウインドウタイプ
; ****************************************************

WIDONEGRP	PROC	NEAR
	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ

	MOV	DX,IPNT			; 通し番号
	MOV	AX,WIDTYPE		; ウインドウタイプ
	CALL_w	WID_FLAME_GRPONE	; WINDOWS/フレーム・グラフ１本

	MOV	DX,IPNT			; 通し番号
	MOV	SI,DP_NAME		; 名前
	CALL_w	WID_FRAME_G_PNAME	; WINDOWS/パラメータ名を書く

	MOV	DX,IPNT			; 通し番号
	MOV	AX,DP_VALUE		; パラメータ値
	CALL	PARA_UP_CUT		; パラメータ上限カット
	CALL_w	WID_FRAME_G_PGRP	; WINDOWS/グラフを描く

	MOV	DX,IPNT			; 通し番号
	MOV	AX,DP_VALUE		; パラメータ値
	CALL	PARA_UP_CUT		; パラメータ上限カット
	CALL_w	WID_FRAME_G_PPARA	; WINDOWS/パラメータ値を書く

	MOV	AX,WIDTYPE		; ウインドウタイプ
	MOV	DX,IPNT			; 通し番号
	CALL_w	WID_FLAME_GRP_OFF	; WINDOWS/フレーム・グラフ OFF

	RET
WIDONEGRP	ENDP


; ****************************************************
;	グラフ１本・更新
;	-I- IGRP_X   : グラフＸ
;	    IGRP_Y   : グラフＹ
;	    IPNT     : 通し番号
;	    DP_VALUE : パラメータ値
; ****************************************************

WIDONEGRP_UPD	PROC	NEAR
	MOV	BX,IPNT			; 通し番号
	CALL	PARA_NOW		; パラメータ更新テーブル参照
	CMP	DP_VALUE,DX		; パラメータ値
	JNE	WIDONEGRP_UPD_1		;

	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ
	MOV	AX,WIDTYPE		; ウインドウタイプ
	MOV	DX,IPNT			; 通し番号
	CALL_w	WID_FLAME_GRP_OFF	; WINDOWS/フレーム・グラフ OFF

	JMP	WIDONEGRP_UPD_EXIT	;

WIDONEGRP_UPD_1:			;
	CMP	DP_VALUE,DX		; パラメータ値
	JL	WIDONEGRP_UPD_12	;
	JG	WIDONEGRP_UPD_11	;
	MOV	UPDOWN,0		; 0=none
	JMP	WIDONEGRP_UPD_19	;
WIDONEGRP_UPD_11:
	MOV	UPDOWN,1		; 1=上昇
	JMP	WIDONEGRP_UPD_19	;
WIDONEGRP_UPD_12:			;
	MOV	UPDOWN,2		; 2=下降
WIDONEGRP_UPD_19:

	MOV	BX,IPNT			; 通し番号
	MOV	DX,DP_VALUE		; value.
	CALL	PARA_UPDATE_WT		; パラメータ更新テーブルセット

	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ

	MOV	DX,IPNT			; 通し番号
	MOV	AX,DP_VALUE		; パラメータ値
	CALL	PARA_UP_CUT		; パラメータ上限カット
	CALL_w	WID_FRAME_G_PGRP	; WINDOWS/グラフを描く

	MOV	DX,IPNT			; 通し番号
	MOV	AX,DP_VALUE		; パラメータ値
	CALL	PARA_UP_CUT		; パラメータ上限カット
	CALL_w	WID_FRAME_G_PPARA	; WINDOWS/パラメータ値を書く

	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ
	MOV	AX,WIDTYPE		; ウインドウタイプ
	MOV	DX,IPNT			; 通し番号
	MOV	BX,UPDOWN		; 上下目安 1=上昇,2=下降
	CALL_w	WID_FLAME_GRP_ON	; WINDOWS/フレーム・グラフ ON

WIDONEGRP_UPD_EXIT:
	RET
WIDONEGRP_UPD	ENDP



; ****************************************************
;	プロポーション１本描画
;	-I- IGRP_X   : グラフＸ
;	    IGRP_Y   : グラフＹ
;	    IPNT     : 通し番号
;	    DP_NAME  : 名前
;	    DP_VALUE : パラメータ値
;	    WIDTYPE  : ウインドウタイプ
; ****************************************************

WIDONEPROPR	PROC	NEAR
	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ

	MOV	DX,IPNT			; 通し番号
	MOV	AX,WIDTYPE		; ウインドウタイプ
	CALL_w	WID_FRAME_PROPRONE	; WINDOWS/フレーム・ﾌﾟﾛﾎﾟｰｼｮﾝ1本

	MOV	DX,IPNT			; 通し番号
	MOV	SI,DP_NAME		; 名前
	CALL_w	WID_FRAME_P_PNAME	; WINDOWS/ﾊﾟﾗﾒｰﾀ名を書く

	MOV	DX,IPNT			; 通し番号
	MOV	AX,DP_VALUE		; パラメータ値
	CALL_w	WID_FRAME_P_PGRP	; WINDOWS/ｸﾞﾗﾌを描く

	MOV	DX,IPNT			; 通し番号
	MOV	AX,DP_VALUE		; パラメータ値
	CALL_w	WID_FRAME_P_PPARA	; WINDOWS/ﾊﾟﾗﾒｰﾀ値を書く

	RET
WIDONEPROPR	ENDP


; ****************************************************
;	プロポーション１本・更新
;	-I- IGRP_X   : グラフＸ
;	    IGRP_Y   : グラフＹ
;	    IPNT     : 通し番号
;	    DP_VALUE : パラメータ値
; ****************************************************

WIDONEPROPR_UPD	PROC	NEAR
	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ

	MOV	DX,IPNT			; 通し番号
	MOV	AX,DP_VALUE		; パラメータ値
	CALL_w	WID_FRAME_P_PGRP	; WINDOWS/ｸﾞﾗﾌを描く

	MOV	DX,IPNT			; 通し番号
	MOV	AX,DP_VALUE		; パラメータ値
	CALL_w	WID_FRAME_P_PPARA	; WINDOWS/ﾊﾟﾗﾒｰﾀ値を書く

	RET
WIDONEPROPR_UPD	ENDP


; ****************************************************
;	ＧＯＬＤ１本描画
;	-I- IGRP_X   : グラフＸ
;	    IGRP_Y   : グラフＹ
;	    IPNT     : 通し番号
;	    DP_NAME  : 名前
;	    DP_VALUE : パラメータ値
; ****************************************************

WIDONEGOLD	PROC	NEAR
	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ

	MOV	DX,IPNT			; 通し番号
	CALL_w	WID_FLAME_GOLDONE	; WINDOWS/フレーム・ＧＯＬＤ１本

	MOV	DX,IPNT			; 通し番号
	MOV	SI,DP_NAME		; 名前
	CALL_w	WID_FRAME_GOLD_NAME	; WINDOWS/フレーム・ＧＯＬＤ 名前を書く

	MOV	DX,IPNT			; 通し番号
	MOV	AX,DP_VALUE		; パラメータ値
	CALL_w	WID_FRAME_GOLD_GOLD	; WINDOWS/フレーム・ＧＯＬＤ 金額を書く

	RET
WIDONEGOLD	ENDP


; ****************************************************
;	ＧＯＬＤ１本･更新
;	-I- IGRP_X   : グラフＸ
;	    IGRP_Y   : グラフＹ
;	    IPNT     : 通し番号
;	    DP_VALUE : パラメータ値
; ****************************************************

WIDONEGOLD_UPD	PROC	NEAR
	MOVX	WDX1,IGRP_X		; グラフＸ
	MOVX	WDY1,IGRP_Y		; グラフＹ

	MOV	DX,IPNT			; 通し番号
	MOV	AX,DP_VALUE		; パラメータ値
	CALL_w	WID_FRAME_GOLD_GOLD	; WINDOWS/フレーム・ＧＯＬＤ 金額を書く
	RET
WIDONEGOLD_UPD	ENDP


; ****************************************************
;	パラメータ更新テーブル参照
;	-I- BX : number.
;	-O- DX : value.
; ****************************************************

PARA_NOW	PROC	NEAR
	SHL	BX,1			; word pointer.
	MOV	SI,WIDUPDATEADRS	; ウインドウ更新ﾃｰﾌﾞﾙｱﾄﾞﾚｽ
	MOV	DX,DS:[SI][BX]		;
	RET
PARA_NOW	ENDP


; ****************************************************
;	パラメータ更新テーブルセット
;	-I- BX : number.
;	    DX : value.
; ****************************************************

PARA_UPDATE_WT	PROC	NEAR
	SHL	BX,1			; word pointer.
	MOV	SI,WIDUPDATEADRS	; ウインドウ更新ﾃｰﾌﾞﾙｱﾄﾞﾚｽ
	MOV	DS:[SI][BX],DX		;
	RET
PARA_UPDATE_WT	ENDP


; ****************************************************
;	画面退避
;	-I- WDX1 : 表示位置Ｘ
;	    WDY1 : 表示位置Ｙ
;	    WDX2 : 大きさＸ
;	    WDY2 : 大きさＹ
; ****************************************************

BACK_SAVE	PROC	NEAR
	CMP	FLAG_BACKUP,1		; flag backup area.
	JE	BACK_SAVE_START		;
	RET
BACK_SAVE_START:
	MOV	DX,NOW_SAVE_BANK	; 現在背景退避用パーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	MOVX	VRX,WDX1		; 表示位置Ｘ
	MOVX	VRY,WDY1		; 表示位置Ｙ
	MOVX	VRLENX,WDX2		; 大きさＸ
	MOVX	VRLENY,WDY2		; 大きさＹ
	CALL_w	C1PATGTA		; パーツＧＥＴ圧縮無し

	INC	BACK_COUNT		; back save count.

	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ
	RET
BACK_SAVE	ENDP


; ****************************************************
;	画面復元
; ****************************************************

BACK_LOAD	PROC	NEAR
	CMP	FLAG_BACKUP,1		; flag backup area.
	JE	BACK_LOAD_START		;
	RET
BACK_LOAD_START:
	MOV	DX,NOW_SAVE_BANK	; 現在背景退避用パーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ

	MOV	DX,BACK_COUNT		;
	MOV	CX,BACK_COUNT		; back save count.
BACK_LOAD_LOOP:				;
	PUSH	CX			;
	DEC	DX			;
	PUSH	DX			;
	MOV	CX,DX			; パーツ番号
	CALL_w	C1PATPUT		; パーツＰＵＴ
	POP	DX			;
	POP	CX			;
	LOOP	BACK_LOAD_LOOP		;

	MOV	DX,NORMAL_BANK		; 通常のパーツバンク番号
	CALL_w	C1PATBNK		; バンクチェンジ
	RET
BACK_LOAD	ENDP


; ****************************************************
;	パラメータ上限カット
;	-I/O- AX : value.
; ****************************************************

PARA_UP_CUT	PROC	NEAR
	CMP	AX,0
	JGE	PARA_UP_CUT_1
	MOV	AX,0
PARA_UP_CUT_1:
	CMP	AX,999
	JLE	PARA_UP_CUT_2
	MOV	AX,999
PARA_UP_CUT_2:
	RET
PARA_UP_CUT	ENDP


; ****************************************************
;	word fill.
;	-I- AX : table.
;	    DI : offset.
;	    CX : word counter.
; ****************************************************

WORD_FILL	PROC	NEAR
	PUSH	DI
	PUSH	CX
	ADD	DI,AX
	MOVX	ES,DS
	MOV	AX,0
	REP	STOSW
	POP	CX
	POP	DI
	RET
WORD_FILL	ENDP


WINDOW	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	WD_FACE_GIRL:WORD		; girl face.

EXTRN	IGRP_TBL1:WORD			; グラフテーブル／名前
EXTRN	IGRP_TBL2:WORD			; グラフテーブル／タイプ
EXTRN	IGRP_TBL3:WORD			; グラフテーブル／パラメータ値
EXTRN	IGRP_TBL4:WORD			; グラフテーブル／項目名
EXTRN	IGRP_CNT:WORD			; グラフテーブル数
EXTRN	IGRP_DIM:WORD			; グラフ本数の上限
EXTRN	IGRP_X:WORD			; グラフＸ
EXTRN	IGRP_Y:WORD			; グラフＹ

HDL_DIM		DW	HANDLE_DIM		; handle dimension.
HDL_WIDTYPE	DW	HANDLE_DIM DUP (0)	; handle window type.
HDL_LOC_X	DW	HANDLE_DIM DUP (0)	; handle location x.
HDL_LOC_Y	DW	HANDLE_DIM DUP (0)	; handle location y.
HDL_TBL_MAX	DW	HANDLE_DIM DUP (0)	; handle table max.
HDL_UPDATETBL	DW	HANDLE_DIM*UPDATE_DIM DUP (0) ; handle update table.

WDXX		DW	0		; window x.
WDYY		DW	0		; window y.
WDHIGHT		DW	0		; window hight.
WIDTYPE		DW	0		; ウインドウタイプ
WIDHANDLE	DW	0		; ウインドウハンドル
WIDUPDATEADRS	DW	0		; ウインドウ更新ﾃｰﾌﾞﾙｱﾄﾞﾚｽ
WID_IPNT	DW	0		; パラメータ通し番号

DP_NAME		DW	0		; 名前
DP_TYPE		DW	0		; タイプ
DP_VALUE	DW	0		; パラメータ値

UPDOWN		DW	0		; 上下目安 1=上昇,2=下降

IPNT		DW	0		; 通し番号
BACK_COUNT	DW	0		; back save count.

NOW_SAVE_BANK	DW	0		; 現在背景退避用パーツバンク番号

FLAG_BACKUP	DW	0		; flag backup area.

FLNAME		DW	0		; file name.

WID_XF		DW	0		; フェイス左上Ｘ
WID_YF		DW	0		; フェイス左上Ｙ
WID_XFB		DW	0		; フェイス退避Ｘ
WID_YFB		DW	0		; フェイス退避Ｙ
WID_XFL		DW	0		; フェイスサイズＸ
WID_YFL		DW	0		; フェイスサイズＹ

DATA	ENDS

	END
;
;	end of "WIDGRAP.ASM"
;
