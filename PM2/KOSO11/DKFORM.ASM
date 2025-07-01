; "DKFROM.ASM" PC-9801UV11 make by R.H 1990/10/01
;
;	ＦＤのフォーマット
;
;
;
;
;	ディスクＩＤの内容
;	byte
;	0-1	システムＩＤ
;	2-3	プログラムＩＤ
;	4-5	ディスク番号
;	6-23	システム予約
;	22-23	フォーマット済みトラック数
;	24-1023	ユーザ解放データ
;
;
;
;
;
;
; public subroutine.

INCLUDE	TSTSET.INC
INCLUDE	DSKCH2.INC

MY_DISKNUM_USR	EQU	13		; ユーザーディスクＩＤ

DEBUG		EQU	0		; デバックアセンブルフラグ

RECORD_IPL	EQU	0		; ＩＰＬの論理レコード
RECORD_FAT	EQU	1		; ＦＡＴの論理レコード
RECORD_DISKID	EQU	10		; ディスクＩＤの論理レコード

CLAST_OFFSET	EQU	9		; クラスタ開始位置のセクタオフセット

FAT_FREE_CLAST	EQU	0		; 空きクラスタ(FAT)
FAT_EOF_CLAST	EQU	0FFFH		; ファイルの最後のクラスタ(FAT)
FAT_END_CLAST	EQU	0FF8H		; ファイル本体クラスタの最小値(FAT)
FAT_ERR_CLAST	EQU	0FF7H		; 破壊クラスタ(FAT)

MIN_CLAST	EQU	2		; 最小クラスタ番号
MAX_CLAST	EQU	8*2*77-9-1	; 最大クラスタ番号

FAT_CLAST_H 	EQU	2		; ＦＡＴテーブルクラスタ数半分

TRACK_CLAST	EQU	8		; トラック当りのクラスタ数
TRACK_SECTOR	EQU	8		; トラック当りのセクタ数
CLST_BYTE	EQU	1024		; クラスタバイト数
SEC_BYTE	EQU	1024		; セクタバイト数


CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	DKFDNO			; フォーマットのドライブ番号の設定（０ー３）
;*;PUBLIC DKFREE		; ディスクの空きクラスタ
PUBLIC	DKFORM			; ディスクのフォーマット
PUBLIC	DKF2ND			; ディスクのセカンドフォーマット
;*;PUBLIC DKFPSI		; ディスクの物理フォーマット

EXTRN	DKRESET:NEAR		; disk reset.

EXTRN	SCWSET:NEAR		; 論理レコード設定
EXTRN	SCWSEQ:NEAR		; セクター順次書き込み
EXTRN	SCWRED:NEAR		; セクター順次読み込み
EXTRN	SCWDRV:NEAR		; ドライブ番号の設定（０ー３）



;	フォーマットのドライブ番号の設定（０ー３）
;	-I- AX : １ＭＦＤドライブ番号

DKFDNO	PROC	NEAR
	PUSH	AX
	CALL	DNOSET			; ドライブ番号の設定
	POP	AX
	RET
DKFDNO	ENDP


;*;;	ディスクの空きクラスタ
;*;;	-O- DX : 空きクラスタ数
;*;;	    AX : 0=正常,1=エラー
;*;
;*;DKFREE	PROC	NEAR
;*;	CALL	DKRESET		; disk reset.
;*;
;*;	CALL	DNOGET			; ドライブ番号の取得
;*;	CALL	SCWDRV			; ドライブ番号の設定（０ー３）
;*;
;*;	CALL	LODFAT			; ＦＡＴロード
;*;	CMP	DERROR,0		; 0=正常,1=エラー
;*;	JNE	DKFREE_ERROR		;
;*;
;*;	CALL	CNTFRE			; 空きクラスタ数を調べる
;*;	MOV	DX,FRE_CLAST		; 空きクラスタ数
;*;
;*;DKFREE_EXIT:
;*;	CALL	DKRESET		; disk reset.
;*;	MOV	AX,0			; 0=正常,1=エラー
;*;	RET
;*;DKFREE_ERROR:
;*;	CALL	DKRESET		; disk reset.
;*;	MOV	AX,1			; 1=エラー
;*;	RET
;*;DKFREE	ENDP


;	ディスクのフォーマット
;	-O- AX : 0=正常, 2=ディスクエラー
;	         3=デバイスがノットレディ, 4=ライトプロテクト

DKFORM	PROC	NEAR
	CALL	DKRESET		; disk reset.

	CALL	DNOGET			; ドライブ番号の取得
	CALL	SCWDRV			; ドライブ番号の設定（０ー３）

	MOV	TRACK_NUMBER,0		; 先頭トラック番号
	MOV	TRACK_COUNTER,2		; フォーマットするトラック数
	CALL	PYSICAL_FORMAT		; 物理フォーマット
	CMP	AX,0			;
	JNE	DKFORM_EXIT		;
IF DEBUG
	PRVH "FAT_TABLE_SEG=",FAT_TABLE_SEG
	PRVH "FAT_TABLE_OFS=",FAT_TABLE_OFS
ENDIF
	CALL	LOGICAL_FORMAT		; 論理フォーマット
	CMP	AX,0			; 0=正常, 2=ディスクエラー
	JNE	DKFORM_EXIT		;

;*;	CALL	FATDUMP			; FAT dump.

	MOV	AX,0			; 0=正常
DKFORM_EXIT:
	CALL	DKRESET		; disk reset.
	RET
DKFORM	ENDP


;	ディスクのセカンドフォーマット
;	-I- DX : 使用したいクラスタ数
;	-O- AX : 0=正常, 2=ディスクエラー
;	         3=デバイスがノットレディ, 4=ライトプロテクト
;	         1=エラー,10=ユーザディスクじゃない

DKF2ND	PROC	NEAR
	MOV	USE_CLST_CNT,DX		; 使用クラスタ数

	CALL	DKRESET			; disk reset.

	CALL	DNOGET			; ドライブ番号の取得
	CALL	SCWDRV			; ドライブ番号の設定（０ー３）

	CALL	FORM_STYLE		; フォーマット状態の判定
IF DEBUG
	PRV	"フォーマット済みトラック数        =",STYLE_FORMAT_TRK
	PRV	"未フォーマットトラック数          =",STYLE_UNFORMAT_TRK
	PRV	"次にフォーマットしたいトラック開始=",STYLE_NEWFORMAT_SRT
	PRV	"次にフォーマットしたいトラック数  =",STYLE_NEWFORMAT_TRK
ENDIF
	CMP	AX,0			; 0=正常
	JNE	DKF2ND_EXIT		; 1=エラー,10=ユーザディスクじゃない

	MOV	AX,STYLE_NEWFORMAT_SRT	; 次にフォーマットしたいトラック開始
	MOV	BX,STYLE_NEWFORMAT_TRK	; 次にフォーマットしたいトラック数
	MOV	TRACK_NUMBER,AX		; 先頭トラック番号
	MOV	TRACK_COUNTER,BX	; フォーマットするトラック数
	CALL	PYSICAL_FORMAT		; 物理フォーマット
	CMP	AX,0			;
	JNE	DKF2ND_EXIT		;

	CALL	LOGICAL_2NDFORM		; 論理セカンドフォーマット
	CMP	AX,0			; 0=正常, 2=ディスクエラー
	JNE	DKF2ND_EXIT		;

;*;	CALL	FATDUMP			; FAT dump.

	MOV	AX,0			; 0=正常
DKF2ND_EXIT:				;
	CALL	DKRESET		; disk reset.
	RET
DKF2ND	ENDP


;*;;	ディスクの物理フォーマット
;*;;	-I- AX : 先頭トラック番号
;*;;	    CX : フォーマットするトラック数
;*;;	-O- AX : 0=正常, 2=ディスクエラー
;*;;	         3=デバイスがノットレディ, 4=ライトプロテクト
;*;
;*;DKFPSI	PROC	NEAR
;*;	CALL	DKRESET		; disk reset.
;*;	MOV	TRACK_NUMBER,AX		; 先頭トラック番号
;*;	MOV	TRACK_COUNTER,CX	; フォーマットするトラック数
;*;	CALL	PYSICAL_FORMAT		; 物理フォーマット
;*;	PRV	"status=",AX
;*;	CALL	DKRESET		; disk reset.
;*;	RET
;*;DKFPSI	ENDP


;	フォーマット状態の判定
;	-I- USE_CLST_CNT        : 使用クラスタ数
;	-O- STYLE_FORMAT_TRK    : フォーマット済みトラック数
;	    STYLE_UNFORMAT_TRK  : 未フォーマットトラック数
;	    STYLE_NEWFORMAT_SRT : 次にフォーマットしたいトラック開始
;	    STYLE_NEWFORMAT_TRK : 次にフォーマットしたいトラック数
;				Ｏならばフォーマットの必要なし
;	    AX                  : 0=正常,1=エラー,10=ユーザディスクじゃない

FORM_STYLE	PROC	NEAR
	CALL	ID_GET			; ディスクＩＤの内容を汎用変数へ
	CMP	DERROR,0		; 0=正常,1=エラー
	JNE	FORM_STYLE_ERROR	;

	CMP	ID_DISKSYSNAME,MY_DISKSYSNAME	; このシステムＩＤ
	JNE	FORM_STYLE_USER_NONE		;
	CMP	ID_DISKPROG,MY_DISKPROG		; このプログラムＩＤ
	JNE	FORM_STYLE_USER_NONE		;
	CMP	ID_DISKNUMBER,MY_DISKNUM_USR	; このユーザディスクの番号
	JNE	FORM_STYLE_USER_NONE		;

	MOV	AX,ID_FORMATCNT		; フォーマット済みトラック数
	MOV	STYLE_FORMAT_TRK,AX	; フォーマット済みトラック数

	MOV	AX,MAX_TRACK		; 最大トラック数
	SUB	AX,ID_FORMATCNT		; フォーマット済みトラック数
	MOV	STYLE_UNFORMAT_TRK,AX	; 未フォーマットトラック数

	MOV	AX,ID_FORMATCNT		; フォーマット済みトラック数
	MOV	STYLE_NEWFORMAT_SRT,AX	; 次にフォーマットしたいトラック開始

	CALL	LODFAT			; ＦＡＴロード
	CMP	DERROR,0		; 0=正常,1=エラー
	JNE	FORM_STYLE_ERROR	;

	MOV	STYLE_NEWFORMAT_TRK,0	; 次にフォーマットしたいトラック数

	CALL	CNTFRE			; 空きクラスタ数を調べる

	CMPX	FRE_CLAST,USE_CLST_CNT	; 使用クラスタ数
	JNB	FORM_STYLE_EXIT		;

	MOV	DX,0			;
	MOV	AX,USE_CLST_CNT		; 使用クラスタ数
	SUB	AX,FRE_CLAST		; －空きクラスタ数
	MOV	BX,TRACK_CLAST		; ÷トラック当りのクラスタ数
	DIV	BX			;
	CMP	DX,0			; DX=余り
	JE	FORM_STYLE_5		;
	INC	AX			;
FORM_STYLE_5:				;
	MOV	STYLE_NEWFORMAT_TRK,AX	; 次にフォーマットしたいトラック数
	TEST	STYLE_NEWFORMAT_TRK,1B	; 奇数か？
	JZ	FORM_STYLE_EXIT		;
	INC	STYLE_NEWFORMAT_TRK	; ＋１
FORM_STYLE_EXIT:
	MOV	AX,0			; 0=正常
	RET
FORM_STYLE_ERROR:
	MOV	AX,1			; 1=エラー
	RET
FORM_STYLE_USER_NONE:
	MOV	AX,10			; 10=ユーザディスクじゃない
	RET
FORM_STYLE	ENDP


;	論理フォーマット
;	-O- AX : 0=正常, 2=ディスクエラー

LOGICAL_FORMAT	PROC	NEAR
	MOV	AX,RECORD_IPL		; ＩＰＬの論理レコード
	CALL	SCWSET			; 論理レコード設定

	MOV	DX,DS			; バッファセグメント
	MOV	BX,OFFSET IPL_CODE_TOP	; ＩＰＬの先頭
	CALL	SCWSEQ			; セクター順次書き込み
IF DEBUG
	PRV	"SCWSEQ -O- AX=",AX
ENDIF
	CMP	AX,1			; 0=正常,1=エラー,2=最後のセクタ
	JE	LOGICAL_FORMAT_ERROR	;

	MOV	ID_DISKSYSNAME,MY_DISKSYSNAME	; このシステムＩＤ
	MOV	ID_DISKPROG,MY_DISKPROG		; このプログラムＩＤ
	MOV	ID_DISKNUMBER,MY_DISKNUM_USR	; このユーザディスクの番号
	MOV	ID_FORMATCNT,2			; フォーマット済みトラック数
	CALL	ID_PUT			; 汎用変数の内容をディスクＩＤへ
	CMP	DERROR,0		; 0=正常,1=エラー
	JNE	LOGICAL_FORMAT_ERROR	;

	CALL	FAT_FILL_INIT		; ＦＡＴの初期化

	MOV	TRACK_NUMBER,1		; 先頭トラック番号
	CALL	TRACK_FAT_SET		; トラック毎のＦＡＴクリア

	CALL	SAVFAT			; ＦＡＴセーブ
	CMP	DERROR,1		; 0=正常,1=エラー
	JE	LOGICAL_FORMAT_ERROR	;

LOGICAL_FORMAT_EXIT:
	MOV	AX,0			; 0=正常
	RET
LOGICAL_FORMAT_ERROR:
	MOV	AX,2			; 2=ディスクエラー
	RET
LOGICAL_FORMAT	ENDP


;	論理セカンドフォーマット
;	-I- ID_DISKSYSNAME : システムＩＤ
;	    ID_DISKPROG    : プログラムＩＤ
;	    ID_DISKNUMBER  : ディスク番号
;	    ID_FORMATCNT   : フォーマット済みトラック数
;	    STYLE_NEWFORMAT_SRT : 次にフォーマットしたいトラック開始
;	    STYLE_NEWFORMAT_TRK	: 次にフォーマットしたいトラック数
;	-O- AX : 0=正常, 2=ディスクエラー

LOGICAL_2NDFORM	PROC	NEAR
	MOV	AX,STYLE_NEWFORMAT_TRK	; 次にフォーマットしたいトラック数
	ADD	ID_FORMATCNT,AX		; フォーマット済みトラック数
	CALL	ID_PUT			; 汎用変数の内容をディスクＩＤへ
	CMP	DERROR,0		; 0=正常,1=エラー
	JNE	LOGICAL_2NDFORM_ERROR	;

	MOV	AX,STYLE_NEWFORMAT_SRT	; 次にフォーマットしたいトラック開始
	MOV	BX,STYLE_NEWFORMAT_TRK	; 次にフォーマットしたいトラック数
	MOV	TRACK_NUMBER,AX		; 先頭トラック番号
	MOV	TRACK_COUNTER,BX	; フォーマットするトラック数

	CALL	TRACK_FAT_MUL		; ＦＡＴクリア

	CALL	SAVFAT			; ＦＡＴセーブ
	CMP	DERROR,0		; 0=正常,1=エラー
	JNE	LOGICAL_2NDFORM_ERROR	;

LOGICAL_2NDFORM_EXIT:
	MOV	AX,0			; 0=正常
	RET
LOGICAL_2NDFORM_ERROR:
	MOV	AX,2			; 2=ディスクエラー
	RET
LOGICAL_2NDFORM	ENDP



;	ＦＡＴの初期化

FAT_FILL_INIT	PROC	NEAR
	MOV	AX,MIN_CLAST		; 最小クラスタ番号
	MOV	PNTNOW,AX		; AX=書き込むＦＡＴのクラスタ位置
FAT_FILL_INIT_LOOP:
	MOV	DX,FAT_ERR_CLAST	; 破壊クラスタ(FAT)
	CALL	FATSET			; ＦＡＴへクラスタ番号を書き込む
	INC	PNTNOW			; 書き込むＦＡＴのクラスタ位置
	CMP	PNTNOW,MAX_CLAST	; 最大クラスタ番号
	JBE	FAT_FILL_INIT_LOOP	;

	MOV	ES,FAT_TABLE_SEG	; FAT table segment.
	MOV	DI,FAT_TABLE_OFS	; FAT table offset.
	MOV	AL,FAT_ID_1		; ＦＡＴＩＤ
	STOSB				;
	MOV	AL,FAT_ID_2		;
	STOSB				;
	MOV	AL,FAT_ID_3		;
	STOSB				;

	RET
FAT_FILL_INIT	ENDP


;	ＦＡＴクリア
;	-I/O- TRACK_NUMBER  : 先頭トラック番号
;	      TRACK_COUNTER : フォーマットするトラック数

TRACK_FAT_MUL	PROC	NEAR

TRACK_FAT_MUL_LOOP:
	CMP	TRACK_COUNTER,0		; フォーマットするトラック数
	JLE	TRACK_FAT_MUL_EXIT	;

	MOV	AX,TRACK_NUMBER		;
	CMP	AX,MAX_TRACK		; 最大トラック数
	JNB	TRACK_FAT_MUL_EXIT	;

	CALL	TRACK_FAT_SET		; トラック毎のＦＡＴクリア

	INC	TRACK_NUMBER		; 先頭トラック番号

	DEC	TRACK_COUNTER		; フォーマットするトラック数

	JMP	TRACK_FAT_MUL_LOOP
TRACK_FAT_MUL_EXIT:
	RET
TRACK_FAT_MUL	ENDP


;	トラック毎のＦＡＴクリア
;	-I- TRACK_NUMBER  : 先頭トラック番号

TRACK_FAT_SET	PROC	NEAR
	CMP	TRACK_NUMBER,0		; 先頭トラック番号
	JE	TRACK_FAT_SET_EXIT	;

	MOV	AX,TRACK_NUMBER		; トラック番号
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			; * 8
					; AX=論理レコード番号
	SUB	AX,CLAST_OFFSET		; －クラスタ開始位置のセクタオフセット
	MOV	PNTNOW,AX		; AX=書き込むＦＡＴのクラスタ位置

	MOV	CX,8			; トラック当りのクラスタ数
TRACK_FAT_SET_LOOP:			;
	PUSH	CX			;
	MOV	DX,FAT_FREE_CLAST	; 空きクラスタ(FAT)
	CALL	FATSET			; ＦＡＴへクラスタ番号を書き込む
	INC	PNTNOW			; 書き込むＦＡＴのクラスタ位置
	POP	CX			;
	LOOP	TRACK_FAT_SET_LOOP	;

TRACK_FAT_SET_EXIT:
	RET
TRACK_FAT_SET	ENDP



;	ディスクＩＤの内容を汎用変数へ
;	0-1	システムＩＤ
;	2-3	プログラムＩＤ
;	4-5	ディスク番号
;	6-23	システム予約
;	22-23	フォーマット済みトラック数
;	-O- ID_DISKSYSNAME : システムＩＤ
;	    ID_DISKPROG    : プログラムＩＤ
;	    ID_DISKNUMBER  : ディスク番号
;	    ID_FORMATCNT   : フォーマット済みトラック数
;	    DERROR 	: 0=正常,1=エラー

ID_GET	PROC	NEAR
	CALL	LOD_ID			; ＩＤロード

	MOV	SI,OFFSET IDBUFFER	; ディスクＩＤの内容
	MOV	AX,DS:[SI][0]		;
	MOV	ID_DISKSYSNAME,AX	; システムＩＤ
	MOV	AX,DS:[SI][2]		;
	MOV	ID_DISKPROG,AX		; プログラムＩＤ
	MOV	AX,DS:[SI][4]		;
	MOV	ID_DISKNUMBER,AX	; ディスク番号
	MOV	AX,DS:[SI][22]		;
	MOV	ID_FORMATCNT,AX		; フォーマット済みトラック数
	RET
ID_GET	ENDP


;	汎用変数の内容をディスクＩＤへ
;	0-1	システムＩＤ
;	2-3	プログラムＩＤ
;	4-5	ディスク番号
;	6-23	システム予約
;	22-23	フォーマット済みトラック数
;	-I- ID_DISKSYSNAME : システムＩＤ
;	    ID_DISKPROG    : プログラムＩＤ
;	    ID_DISKNUMBER  : ディスク番号
;	    ID_FORMATCNT   : フォーマット済みトラック数
;	-O- DERROR 	: 0=正常,1=エラー

ID_PUT	PROC	NEAR
	MOV	SI,OFFSET IDBUFFER	; ディスクＩＤの内容
	MOV	AX,ID_DISKSYSNAME	; システムＩＤ
	MOV	DS:[SI][0],AX		;
	MOV	AX,ID_DISKPROG		; プログラムＩＤ
	MOV	DS:[SI][2],AX		;
	MOV	AX,ID_DISKNUMBER	; ディスク番号
	MOV	DS:[SI][4],AX		;
	MOV	AX,ID_FORMATCNT		; フォーマット済みトラック数
	MOV	DS:[SI][22],AX		;

	CALL	SAV_ID			; ＩＤセーブ
	RET
ID_PUT	ENDP


;	ＩＤロード
;	-O- DERROR 	: 0=正常,1=エラー

LOD_ID	PROC	NEAR
	MOV	DERROR,0		; 0=正常

	MOV	AX,RECORD_DISKID	; ディスクＩＤの論理レコード
	CALL	SCWSET			; 論理レコード設定

	MOV	DX,DS			; バッファセグメント
	MOV	BX,OFFSET IDBUFFER	; ディスクＩＤの内容
	CALL	SCWRED			; セクター順次読み込み
	CMP	AX,1			; 0=正常,1=エラー,2=最後のセクタ
	JE	LOD_ID_ERROR		; エラー

	MOV	DERROR,0		; 0=正常
	RET
LOD_ID_ERROR:				; エラー
	MOV	DERROR,1		; 1=エラー
	RET
LOD_ID	ENDP


;	ＩＤセーブ
;	-O- DERROR 	: 0=正常,1=エラー

SAV_ID	PROC	NEAR
IF DEBUG
	PRF	"-I- SAV_ID"
ENDIF
	MOV	DERROR,0		; 0=正常

	MOV	AX,RECORD_DISKID	; ディスクＩＤの論理レコード
	CALL	SCWSET			; 論理レコード設定

	MOV	DX,DS			; バッファセグメント
	MOV	BX,OFFSET IDBUFFER	; ディスクＩＤの内容
	CALL	SCWSEQ			; セクター順次書き込み
	CMP	AX,1			; 0=正常,1=エラー,2=最後のセクタ
	JE	SAV_ID_ERROR		; エラー

	MOV	DERROR,0		; 0=正常
	RET
SAV_ID_ERROR:				; エラー
	MOV	DERROR,1		; 1=エラー
	RET
SAV_ID	ENDP


;	空きクラスタ数を調べる
;	-O- FRE_CLAST : 空きクラスタ数

CNTFRE	PROC	NEAR
	PUSH	PNTNOW			; 現在のクラスタ番号
	PUSH	PNTNXT			; 続きのクラスタ番号

	MOV	FRE_CLAST,0		; 空きクラスタ数

	MOV	AX,MIN_CLAST		; 最小クラスタ番号
	MOV	PNTNOW,AX		; 現在のクラスタ番号

CNTFRE_LOOP:
	MOV	AX,PNTNOW		; 現在のクラスタ番号
	CMP	AX,MAX_CLAST		; 最大クラスタ番号を越えたら終り
	JNBE	CNTFRE_EXIT		;

	CALL	NXTNUM			; 次のクラスタ番号を取り出す

	CMP	PNTNXT,FAT_FREE_CLAST	; 空きクラスタ(FAT)か？
	JNE	CNTFRE_SKIP		;
	INC	FRE_CLAST		; 空きクラスタ数インクリメント
CNTFRE_SKIP:				;
	INC	PNTNOW			; 現在のクラスタ番号

	JMP	CNTFRE_LOOP		;

CNTFRE_EXIT:
	POP	PNTNXT			;
	POP	PNTNOW			;
	RET
CNTFRE	ENDP


;	次のクラスタ番号を取り出す
;	-I- PNTNOW : 現在のクラスタ番号
;	-O- PNTNXT : 続きのクラスタ番号

NXTNUM	PROC	NEAR
	MOV	AX,PNTNOW		; 現在のクラスタ番号
	SHR	AX,1			; / 2
	MOV	SI,AX			; ＦＡＴテーブルのアドレスポインタ
	ADD	SI,AX			;
	ADD	SI,AX			; ( * 3 )

	MOV	ES,FAT_TABLE_SEG	; FAT table segment.
	ADD	SI,FAT_TABLE_OFS	; FAT table offset.

	MOV	AX,PNTNOW		; 現在のクラスタ番号
	SHR	AX,1			; 奇数か偶数かの判定
	JB	NXTNUM2			;

					; 偶数の場合
	MOV	AX,ES:[SI]		;
	AND	AX,0FFFH		; 3 nible.
	MOV	PNTNXT,AX		; 続きのクラスタ番号
	RET				;

NXTNUM2:				; 奇数の場合
	MOV	AX,ES:[SI+1]		;
	SHR	AX,1			;
	SHR	AX,1			; 1 nible shift.
	SHR	AX,1			;
	SHR	AX,1			;
	MOV	PNTNXT,AX		; 続きのクラスタ番号
	RET
NXTNUM	ENDP


;	ＦＡＴへクラスタ番号を書き込む
;	-I- PNTNOW : 書き込むＦＡＴのクラスタ位置
;	    DX     : 書き込むクラスタ番号

FATSET	PROC	NEAR
	CMP	PNTNOW,MIN_CLAST	; 最小クラスタ番号
	JL	FATSET_EXIT		;

	AND	DX,0FFFH		; 3 nible mask.

	MOV	AX,PNTNOW		; 現在のクラスタ番号
	SHR	AX,1			; / 2
	MOV	SI,AX			; ＦＡＴテーブルのアドレスポインタ
	ADD	SI,AX			;
	ADD	SI,AX			; ( * 3 )

	MOV	ES,FAT_TABLE_SEG	; FAT table segment.
	ADD	SI,FAT_TABLE_OFS	; FAT table offset.

	MOV	AX,PNTNOW		; 現在のクラスタ番号
	SHR	AX,1			; 奇数か偶数かの判定
	JB	FATSET2			;

					; 偶数の場合
	AND	WORD PTR ES:[SI],0F000H	; 1 nible mask.
	OR	WORD PTR ES:[SI],DX	;
	JMP	FATSET3			;
FATSET2:				; 奇数の場合
	AND	WORD PTR ES:[SI+1],0FH	; 1 nible mask.
	SHL	DX,1			;
	SHL	DX,1			; 1 nible shift.
	SHL	DX,1			;
	SHL	DX,1			;
	OR	WORD PTR ES:[SI+1],DX	;
FATSET3:				;
FATSET_EXIT:				;
	RET				;
FATSET	ENDP


;	ＦＡＴロード
;	-O- DERROR 	: 0=正常,1=エラー

LODFAT	PROC	NEAR
	MOV	DERROR,0		; 0=正常

	MOV	AX,RECORD_FAT		; ＦＡＴの論理レコード
	CALL	SCWSET			; 論理レコード設定

	MOV	AX,FAT_TABLE_OFS	; FAT table offset.
	MOV	NOW_ADRS,AX		; アドレス
	MOV	CX,FAT_CLAST_H		; ＦＡＴクラスタ数半分
LODFAT_LOOP:				;
	PUSH	CX			;
	MOV	DX,FAT_TABLE_SEG	; FAT table segment.
	MOV	BX,NOW_ADRS		; アドレス
	CALL	SCWRED			; セクター順次読み込み
	CMP	AX,1			; 0=正常,1=エラー,2=最後のセクタ
	JE	LODFAT_ERROR		; エラー

	ADD	NOW_ADRS,SEC_BYTE	; セクタバイト数
	POP	CX			;
	LOOP	LODFAT_LOOP		;

	MOV	DERROR,0		; 0=正常
	RET
LODFAT_ERROR:				; エラー
	MOV	DERROR,1		; 1=エラー
	RET
LODFAT	ENDP


;	ＦＡＴセーブ
;	-O- DERROR 	: 0=正常,1=エラー

SAVFAT	PROC	NEAR
	MOV	DERROR,0		; 0=正常

	MOV	AX,RECORD_FAT		; ＦＡＴの論理レコード
	CALL	SCWSET			; 論理レコード設定

	MOV	CX,2			;
SAVFAT_LOOP0:				;
	PUSH	CX			;
	MOV	AX,FAT_TABLE_OFS	; FAT table offset.
	MOV	NOW_ADRS,AX		; アドレス
	MOV	CX,FAT_CLAST_H		; ＦＡＴクラスタ数半分
SAVFAT_LOOP:				;
	PUSH	CX			;
	MOV	DX,FAT_TABLE_SEG	; FAT table segment.
	MOV	BX,NOW_ADRS		; アドレス
	CALL	SCWSEQ			; セクター順次書き込み
	CMP	AX,1			; 0=正常,1=エラー,2=最後のセクタ
	JE	SAVFAT_ERROR		; エラー

	ADD	NOW_ADRS,SEC_BYTE	; セクタバイト数
	POP	CX			;
	LOOP	SAVFAT_LOOP		;
	POP	CX			;
	LOOP	SAVFAT_LOOP0		;

	MOV	DERROR,0		; 0=正常
	RET
SAVFAT_ERROR:				; エラー
	MOV	DERROR,1		; 1=エラー
	RET
SAVFAT	ENDP



;	物理フォーマット
;	-I/O- TRACK_NUMBER  : 先頭トラック番号
;	      TRACK_COUNTER : フォーマットするトラック数
;	-O-    AX : 0=正常, 2=ディスクエラー
;	            3=デバイスがノットレディ, 4=ライトプロテクト

PYSICAL_FORMAT	PROC	NEAR

PYSICAL_FORMAT_LOOP:
	CMP	TRACK_COUNTER,0		; フォーマットするトラック数
	JLE	PYSICAL_FORMAT_EXIT	;

	MOV	AX,TRACK_NUMBER		;
	CMP	AX,MAX_TRACK		; 最大トラック数
	JNB	PYSICAL_FORMAT_EXIT	;
IF DEBUG
	PRVU	"track:",TRACK_NUMBER
ENDIF
	CALL	TRACK_TO_CYLINDER	; トラック番号からシリンダ番号とヘッド
	CALL	FORMATTR		; トラックのフォーマット
IF DEBUG
	PRV	"DERROR=",DERROR
	PRV	"DSTAT=",DSTAT
ENDIF
	CMP	DERROR,0		; 0=正常,1=エラー
	JNE	PYSICAL_FORMAT_ERROR	;

	INC	TRACK_NUMBER		; 先頭トラック番号

	DEC	TRACK_COUNTER		; フォーマットするトラック数

	JMP	PYSICAL_FORMAT_LOOP	;

PYSICAL_FORMAT_EXIT:
	MOV	AX,0			; 0=正常
	RET				;
PYSICAL_FORMAT_ERROR:
	CMP	DSTAT,60H		; ＮＲ／デバイスがノットレディ
	JE	PYSICAL_FORMAT_NOTRDY	;
	CMP	DSTAT,70H		; ＮＷ／ライトプロテクト
	JE	PYSICAL_FORMAT_W_PROTECT
PYSICAL_FORMAT_DISK_ER:
	MOV	AX,2			; 2=ディスクエラー
	RET				;
PYSICAL_FORMAT_NOTRDY:
	MOV	AX,3			; 3=デバイスがノットレディ
	RET				;
PYSICAL_FORMAT_W_PROTECT:
	MOV	AX,4			; 4=ライトプロテクト
	RET				;
PYSICAL_FORMAT	ENDP


;	トラック番号からシリンダ番号とヘッド
;	-I- TRACK_NUMBER : トラック番号
;	-O- DCYL         : シリンダ番号（Ｃ）０ー７６
;	    DHEAD        : ヘッド番号（Ｈ）０ー１

TRACK_TO_CYLINDER	PROC	NEAR
	MOV	DHEAD,0				; ヘッド番号（Ｈ）０ー１
	MOV	AX,TRACK_NUMBER			; トラック番号
	SHR	AX,1
	RCL	DHEAD,1				; ヘッド番号（Ｈ）０ー１
	MOV	DCYL,AX				; シリンダ番号（Ｃ）０ー７６
	RET
TRACK_TO_CYLINDER	ENDP


;	トラックのフォーマット
;	-I-   DCYL   : シリンダ番号（Ｃ）０ー７６
;	      DHEAD  : ヘッド番号（Ｈ）０ー１
;	-I/O- SEC_ID_BUF_ADRS   : セクタＩＤバッファのアドレス
;	      DERROR : 0=正常,1=エラー
;	      DSTAT  : ステータス情報

FORMATTR	PROC	NEAR
	MOV	DERROR,0		; 0=正常

	CALL	ID_BUFF_SET		; ＩＤデータバッファセット

	MOV	AX,FORMAT_RETCNT	; ＦＯＲＭＡＴ・リトライ回数
	MOV	FORMAT_RETRY,AX		; ＦＯＲＭＡＴ・リトライカウンタ
FORMATTR_RETRY:
	MOV	AX,DS			;
	MOV	ES,AX			;
	MOV	BP,SEC_ID_BUF_ADRS	; セクタＩＤバッファのアドレス
	MOV	AL,BYTE PTR DUNIT	; デバイス識別・ユニット番号(DA/UA)
	MOV	BX,WORD PTR DLEN 	; データ長（ＤＴＬ）（バイト単位）
	MOV	CL,BYTE PTR DCYL 	; シリンダ番号（Ｃ）０ー７６
	MOV	DH,BYTE PTR DHEAD	; ヘッド番号（Ｈ）０ー１
	MOV	DL,BYTE PTR DDATPT	; データ部への書き込みﾃﾞｰﾀﾊﾟﾀｰﾝ（Ｄ）
	MOV	CH,BYTE PTR DSECN	; セクタ長（Ｎ）

	MOV	AH,BYTE PTR DFORMAT	; ＦＯＲＭＡＴ　ＴＲＡＣＫ
	INT	1BH			; ディスクＢＩＯＳ
	JB	FORMATTR_ERROR		;
FORMATTR9:
	MOV	DERROR,0		; 0=正常
	RET				;

FORMATTR_ERROR:				;
	CMP	AH,20H			; ＤＭＡ　Ｂｏｕｎｄａｒｙ
	JNE	FORMATTR_ERROR2		;
IF DEBUG
	PRVH	"boundary.",SEC_ID_BUF_ADRS
ENDIF
	MOV	AX,OFFSET SEC_ID_TBL2	; セクタＩＤバッファ
	CMP	AX,SEC_ID_BUF_ADRS	; セクタＩＤバッファのアドレス
	JNE	FORMATTR_BNK_SET	; バッファ１、２？
	MOV	AX,OFFSET SEC_ID_TBL1	; セクタＩＤバッファ
FORMATTR_BNK_SET:			;
	MOV	SEC_ID_BUF_ADRS,AX	; セクタＩＤバッファのアドレス
	CALL	ID_BUFF_SET		; ＩＤデータバッファセット
	DEC	FORMAT_RETRY		; ＦＯＲＭＡＴ・リトライカウンタ
	JZ	FORMATTR_ER_END		;
	JMP	FORMATTR_RETRY		;

FORMATTR_ERROR2:
	CMP	AH,60H			; Not Ready. ユニットがノットレディ状態
	JE	FORMATTR_ER_END		;

	DEC	FORMAT_RETRY		; ＦＯＲＭＡＴ・リトライカウンタ
	JZ	FORMATTR_ER_END		;

	MOV	AH,BYTE PTR DRECAL	; ＲＥＣＡＬＩＢＲＡＴＥ
	INT	1BH			; ディスクＢＩＯＳ
	MOV	BYTE PTR DSTAT,AH	; ステータス情報
	JMP	FORMATTR_RETRY		;

FORMATTR_ER_END:
	MOV	BYTE PTR DSTAT,AH	; ステータス情報
	MOV	DERROR,1		; 1=エラー
	RET
FORMATTR	ENDP


;	ＩＤデータバッファセット
;	-I- DCYL   : シリンダ番号（Ｃ）０ー７６
;	    DHEAD  : ヘッド番号（Ｈ）０ー１
;	    SEC_ID_BUF_ADRS : セクタＩＤバッファのアドレス

ID_BUFF_SET	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	CX

	MOV	AL,BYTE PTR DCYL		; シリンダ番号（Ｃ）０ー７６
	MOV	AH,BYTE PTR DHEAD		; ヘッド番号（Ｈ）０ー１

	MOV	BX,SEC_ID_BUF_ADRS		; セクタＩＤバッファのアドレス
	MOV	CX,TRK_SEC_CNT			; トラック当りのセクタ数
ID_BUFF_SET_LOOP:
	MOV	DS:[BX],AL			; シリンダ番号
	MOV	DS:[BX][1],AH			; ヘッド番号
	ADD	BX,4				; 4 byte pointer.
	LOOP	ID_BUFF_SET_LOOP		;

	POP	CX
	POP	BX
	POP	AX
	RET
ID_BUFF_SET	ENDP


;	ドライブ番号の設定
;	-I- AX : １ＭＦＤドライブ番号

DNOSET	PROC	NEAR
	AND	BYTE PTR DUNIT,11111100B	;
	OR	BYTE PTR DUNIT,AL		;
	RET
DNOSET	ENDP


;	ドライブ番号の取得
;	-O- AX : １ＭＦＤドライブ番号

DNOGET	PROC	NEAR
	MOV	AX,DUNIT		;
	AND	AX,011B			;
	RET
DNOGET	ENDP


;*;;	FAT dump.
;*;
;*;FATDUMP	PROC	NEAR
;*;	PRF	"--------"
;*;	MOV	BX,0			;
;*;	MOV	CX,2048/2		; 2048 byte.
;*;FATDUMP_LOOP:
;*;	MOV	DX,WORD PTR DS:FATDATA_TOP[BX]
;*;	XCHG	DH,DL
;*;	CALL	HEXSTR
;*;	CALL	PRINT
;*;	INC	BX
;*;	INC	BX
;*;	LOOP	FATDUMP_LOOP
;*;	LF
;*;	RET
;*;FATDUMP	ENDP


; ****************************************************
;	ＩＰＬソースコード（１０２４バイト以内）
; ****************************************************

IPL_CODE_TOP:
	STACK_HI_TOP	EQU	0FFFFH		; stack top.
	TEXT_TOP	EQU	(80*12+24)*2	; text vram top offset.
	TEXT_ADDRESS	EQU	0A000H		; text vram top segment.
	CHR_LF		EQU	0AH		; line feed.

	MOV	AX,CS				; segment register setup.
	MOV	DS,AX				;
	MOV	ES,AX				;
	MOV	SS,AX				; stack pointer set.
	MOV	SP,STACK_HI_TOP			;

	CALL	TEXT_INIT			; text init.

	MOV	SI,OFFSET MESSAGE_TOP		;
	SUB	SI,OFFSET IPL_CODE_TOP		;
	CALL	MESSAGE				; message print.

BLACK_HOLE:
	JMP	BLACK_HOLE


;	text init.

TEXT_INIT	PROC	NEAR
	MOV	AH,0AH		; CRT mode set.
	MOV	AL,00000000B	; 80*25.
	INT	18H		; CRT bios.

	MOV	AH,0CH		; TEXT on ( GDC )
	INT	18H		; CRT bios.
	RET
TEXT_INIT	ENDP


;	message print.
;	-I- SI : message string address.

MESSAGE	PROC	NEAR
	MOV	AX,TEXT_ADDRESS		;
	MOV	ES,AX			;
	MOV	DI,TEXT_TOP		;
	MOV	DX,DI			; pointer save.
MESS_LOOP:
	LODSB				;
	CMP	AL,0			; end of string.
	JE	MESS_END		;
	CMP	AL,CHR_LF		;
	JNE	MESS_SKIP		;
	MOV	DI,DX			;
	ADD	DI,160			; next line.
	MOV	DX,DI			; pointer save.
	JMP	MESS_LOOP		;
MESS_SKIP:				;
	STOSB				;
	INC	DI			; text vram.
	JMP	MESS_LOOP		;
MESS_END:
	RET
MESSAGE	ENDP

MESSAGE_TOP	LABEL	BYTE
	DB	"princess maker2 data disk.(1993)",0

IPL_CODE_END	LABEL	WORD


; ****************************************************
;	データ
; ****************************************************

EXTRN	FAT_TABLE_SEG:WORD	; FAT table segment.
EXTRN	FAT_TABLE_OFS:WORD	; FAT table offset.

		EVEN
EXTRN	SEC_ID_TBL1:BYTE		; セクタＩＤバッファ
;SEC_ID_TBL1	LABEL	BYTE		; セクタＩＤバッファ
;		;	C  H  R  N
;		DB	00,00,01,03	; 1
;		DB	00,00,02,03	; 2
;		DB	00,00,03,03	; 3
;		DB	00,00,04,03	; 4
;		DB	00,00,05,03	; 5
;		DB	00,00,06,03	; 6
;		DB	00,00,07,03	; 7
;		DB	00,00,08,03	; 8

SEC_ID_TBL2	LABEL	BYTE		; セクタＩＤバッファ
		;	C  H  R  N
		DB	00,00,01,03	; 1
		DB	00,00,02,03	; 2
		DB	00,00,03,03	; 3
		DB	00,00,04,03	; 4
		DB	00,00,05,03	; 5
		DB	00,00,06,03	; 6
		DB	00,00,07,03	; 7
		DB	00,00,08,03	; 8

IDBUFFER	LABEL	BYTE
		DB	1024 DUP (0)

;*;		DB	0,0		;例の余計な３ニブル
;*;FAT		LABEL	BYTE
;*;FATDATA_TOP	LABEL	BYTE
;*;		DB	1024 DUP (0FFH)
;*;		DB	1024 DUP (0FFH)


; ****************************************************
;	ＷＯＲＫ
; ****************************************************

		EVEN

;		ＢＩＯＳコマンド識別コード

;			MM-S....	;
;			TFrK0110	;
DREAD		DW	11110110B	; ＲＥＡＤ　ＤＡＴＡ
DWRITE		DW	11110101B	; ＷＲＩＴＥ　ＤＡＴＡ
DRECAL		DW	00100111B	; ＲＥＣＡＬＩＢＲＡＴＥ
DSENSE		DW	04H		; ＳＥＮＳＥ
DFORMAT		DW	01111101B	; ＦＯＲＭＡＴ　ＴＲＡＣＫ
;			100100dd	;
DUNIT		DW	10010001B	; デバイス識別・ユニット番号（DA/UA）

;		ＩＤＲ（ＩＤ情報）

DLEN		DW	SECTOR_ID_LEN	; データ長（ＤＴＬ）（バイト単位）
DCYL		DW	0		; シリンダ番号（Ｃ）０ー７６
DHEAD		DW	0		; ヘッド番号（Ｈ）０ー１
DSECR		DW	1		; セクタ番号（Ｒ）１ー８（２６）
DSECN		DW	03		; セクタ長（Ｎ）
					; 00/128, 01/256, 02/512, 03/1024
DDATPT		DW	0		; データ部への書き込みﾃﾞｰﾀﾊﾟﾀｰﾝ（Ｄ）
DSTAT		DW	0		; ステータス情報
DERROR		DW	0		; 0=正常,1=エラー

FORMAT_RETCNT	DW	10		; ＦＯＲＭＡＴ・リトライ回数
FORMAT_RETRY	DW	0		; ＦＯＲＭＡＴ・リトライカウンタ

MAX_CYLINDER	DW	77		; 最大シリンダ数
MAX_TRACK	DW	77*2		; 最大トラック数

LEN_CLAST	DW	1024		; クラスタバイト数
LEN_SECTOR	DW	1024		; セクタバイト数

FAT_ID_1	DB	0FEH		; ＦＡＴＩＤ
FAT_ID_2	DB	0FFH		;
FAT_ID_3	DB	0FFH		;

		EVEN
SECTOR_ID_LEN	DW	32		; セクターＩＤデータバッファ長
TRK_SEC_CNT	DW	8		; トラック当りのセクタ数
SEC_ID_BUF_ADRS	DW OFFSET SEC_ID_TBL2	; セクタＩＤバッファのアドレス

TRACK_NUMBER	DW	0		; トラック番号
TRACK_COUNTER	DW	0		; トラックカウンタ

PNTNOW		DW	0		; 現在のクラスタ番号
PNTNXT		DW	0		; 続きのクラスタ番号
PNTFRE		DW	0		; 次の空きクラスタ番号
FRE_CLAST	DW	0		; 空きクラスタ数

ID_DISKSYSNAME	DW	0		; システムＩＤ
ID_DISKPROG	DW	0		; プログラムＩＤ
ID_DISKNUMBER	DW	0		; ディスク番号
ID_FORMATCNT	DW	0		; フォーマット済みトラック数

STYLE_FORMAT_TRK	DW	0	; フォーマット済みトラック数
STYLE_UNFORMAT_TRK	DW	0	; 未フォーマットトラック数
STYLE_NEWFORMAT_SRT	DW	0	; 次にフォーマットしたいトラック開始
STYLE_NEWFORMAT_TRK	DW	0	; 次にフォーマットしたいトラック数

SAVE_DNO	DW	0		; １ＭＦＤドライブ番号退避

USE_CLST_CNT	DW	0		; 使用クラスタ数

NOW_ADRS	DW	0		; アドレス
NUM		DW	0		; レコード番号

CODE	ENDS

	END
;
;	end of "DKFROM.ASM"
;
