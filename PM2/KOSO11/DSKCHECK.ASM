; "DSKCHECK.ASM" PC-9801UV11 make by R.H 1993/03/22
;
;
;	DSKCH3.ASMの改造版
;
;	ＲＡＭドライブはスキップする。
;
;	disk chenger  disk ID read.
;
;
; i/o subroutine.

INCLUDE	TSTSET.INC
INCLUDE	DSKCH2.INC

MY_DISKNUM_USR	EQU	13		; ユーザーディスクＩＤ

DEBUG		EQU	0		; デバックアセンブルフラグ

DCYL_ID		EQU	0		; ディスクＩＤ　シリンダ番号（Ｃ）
DHEAD_ID	EQU	1		; ディスクＩＤ　ヘッド番号（Ｈ）
DSECR_ID	EQU	3		; ディスクＩＤ　セクタ番号（Ｒ）

DCYL_DIR	EQU	0		; ＲＯＯＴ　シリンダ番号（Ｃ）
DHEAD_DIR	EQU	0		; ＲＯＯＴ　ヘッド番号（Ｈ）
DSECR_DIR	EQU	6		; ＲＯＯＴ　セクタ番号（Ｒ）

SEC_BYTE	EQU	1024		; セクタバイト数

ID_LEN		EQU	10		; ディスクＩＤバイト数
DRVNUMMAX_FIX	EQU	4		; １ＭＦＤ固定ドライブ数

DISK_RESULT_TOP	EQU	0564H		; リザルトステータス情報アドレス
DISK_EQUIP	EQU	055CH		; 接続ユニット
RDISK_EQUIP	EQU	0488H		; ＲＡＭドライブ接続状況識別ビット

DISK_STATUS_DB	EQU	20H		; DMA Boundary. メモリアドレスがＤＭＡ
					; に向いていない（バンクにまたがった）
DISK_STATUS_NR	EQU	60H		; Not Ready. ユニットがノットレディ状態
DISK_STATUS_WP	EQU	10H		; Write Protect.ライトプロテクト状態

READ_RETCOUNT 	EQU	3		; リード・リトライ回数

INT_FD_BIOS	MACRO			; PC9801 disk/FD bios.
		INT	1BH		; disk bios.
		ENDM

MESSAGE	MACRO	STRNUMBER
	PUSH	BX
	MOV	BX,STRNUMBER
	SHL	BX,1
	EXTRN	SCRN_MSG_TABLE:WORD
	MOV	SI,SCRN_MSG_TABLE[BX]	; スクリーンメッセージテーブル
	POP	BX
	ENDM

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	USRDRVCHK		; ﾕｰｻﾞｰﾃﾞｨｽｸのドライブ検索
PUBLIC	USRDRVINSWAIT		; ﾕｰｻﾞｰﾃﾞｨｽｸがﾄﾞﾗｲﾌﾞにセットされるのを待つ
PUBLIC	USRDRVNEWDSK		; ﾕｰｻﾞｰﾃﾞｨｽｸか新しいﾃﾞｨｽｸのセット待つ
PUBLIC	USRDRVRESET		; ﾕｰｻﾞｰﾃﾞｨｽｸﾄﾞﾗｲﾌﾞ検索のリセット

EXTRN	DSKWID_OPEN:NEAR	; ディスク・ウインドウＯＰＥＮ
EXTRN	DSKWID_CLOSE:NEAR	; ディスク・ウインドウＣＬＯＳＥ
EXTRN	DSKWID_SRT_PRINT:NEAR	; ディスク・メッセージ表示
EXTRN	DSKWID_USERST_INI:NEAR	; ディスク・ユーザスタンバイ初期化
EXTRN	DSKWID_USERSTANBY:NEAR	; ディスク・ユーザスタンバイ

EXTRN	DKRESET:NEAR		; disk reset.

; *********************************************************
;	ﾕｰｻﾞｰﾃﾞｨｽｸのドライブ検索
;	-O- AX : 0=対象ディスクはセットされています
;	         1=対象ディスクが挿入されていません
;	    DX : 対象ディスクのドライブ番号
; *********************************************************

USRDRVCHK	PROC	NEAR
	MOV	SCH_DISKID,MY_DISKNUM_USR	; ユーザーディスクＩＤ

	MOV	FLAG_RELOAD,0		; フラグ・強制ディスクアクセス
	MOVX	DRVNUM,DRVNUMMAX	; １ＭＦＤドライブ数
USRDRVCHK_LOOP:
	CMP	DRVNUM,0		; １ＭＦＤドライブ番号（０ー３）
	JE	USRDRVCHK_NONE		; 見つからなかった

	DEC	DRVNUM			;

	MOV	AX,DRVNUM		;
	CALL	RAM_DR_EQUIP		; ＲＡＭドライブ接続チェック
	CMP	FLAG_RAM_DR,1		; RAMドライブ接続 1=接続されている
	JE	USRDRVCHK_NEXT		;

	CALL	DSKIDCHK		; ディスクＩＤの読みだし
	CMP	AX,0			; 0=通常
	JE	USRDRVCHK_OK		; このディスクが対象ディスクです
	CMP	AX,1			; 1=ディスクはセットされていない
	JE	USRDRVCHK_NEXT		;
					; 2=違うディスクみたい
USRDRVCHK_NEXT:				;
	JMP	USRDRVCHK_LOOP		;

USRDRVCHK_OK:
	MOV	DX,DRVNUM		; 対象ディスクのドライブ番号
	MOV	AX,0			; 0=対象ディスクはセットされています
IF DEBUG
	PRF	"セット"
ENDIF
	RET
USRDRVCHK_NONE:
	MOV	DX,DRVNUM		; 対象ディスクのドライブ番号
	MOV	AX,1			; 1=対象ディスクが挿入されていません
IF DEBUG
	PRF	"ない"
ENDIF
	RET
USRDRVCHK	ENDP


; *********************************************************
;	ﾕｰｻﾞｰﾃﾞｨｽｸがﾄﾞﾗｲﾌﾞにセットされるのを待つ
;	-O- DX : 対象ディスクのドライブ番号
;	    FLAG_US_BREAK  : ユーザの強制終了
; *********************************************************

USRDRVINSWAIT	PROC	NEAR
	CALL	DSKWID_OPEN			; ディスク・ウインドウＯＰＥＮ

	MOV	FLAG_US_BREAK,0			; ユーザの強制終了

	MOV	SCH_DISKID,MY_DISKNUM_USR	; ユーザーディスクＩＤ

	MESSAGE	2 ;2 "ドライブ２にユーザーディスクをいれて下さい"
	MOV	BX,1				; 1=上段,2=中段
	CALL	DSKWID_SRT_PRINT		; ディスク・メッセージ表示

	CALL	DSKWID_USERST_INI		; ディスク・ユーザスタンバイ初期化

	MOV	FLAG_RELOAD,0			; フラグ・強制ディスクアクセス
	MOVX	DRVNUM,DRVNUMMAX		; １ＭＦＤドライブ数
USRDRVINSWAIT_LOOP:
	CMP	DRVNUM,0			; if DRVNUM = 0 then
	JNE	USRDRVINSWAIT4			;
	MOV	FLAG_RELOAD,0			; フラグ・強制ディスクアクセス
	MOVX	DRVNUM,DRVNUMMAX		; １ＭＦＤドライブ数
USRDRVINSWAIT4:
	CALL	DSKWID_USERSTANBY		; ディスク・ユーザスタンバイ
	CMP	CX,1				; 1=強制終了,0=通常
	JE	USRDRVINSWAIT_US_BREAK		;
	CMP	BX,1				; 1=スタンバイ,0=通常
	JNE	USRDRVINSWAIT5			;

	MOV	FLAG_RELOAD,1			; フラグ・強制ディスクアクセス
	MOVX	DRVNUM,DRVNUMMAX		; １ＭＦＤドライブ数
USRDRVINSWAIT5:
	DEC	DRVNUM				; ドライブ番号（０ー３）

	MOV	AX,DRVNUM			;
	CALL	RAM_DR_EQUIP			; ＲＡＭドライブ接続チェック
	CMP	FLAG_RAM_DR,1			; RAMドライブ接続 1=接続
	JE	USRDRVINSWAIT_NEXT		;

	CALL	DSKIDCHK			; ディスクＩＤの読みだし
	CMP	AX,0				; 0=通常
	JE	USRDRVINSWAIT_DISK_OK		;
	CMP	AX,1				; 1=ディスクはセットされてない
	JE	USRDRVINSWAIT_NEXT		;
						; 2=違うディスクみたい

	MESSAGE	1 ;"このディスクではないですよ"
	MOV	BX,2				; 1=上段,2=中段
	CALL	DSKWID_SRT_PRINT		; ディスク・メッセージ表示

USRDRVINSWAIT_NEXT:
	JMP	USRDRVINSWAIT_LOOP

USRDRVINSWAIT_DISK_OK:
	JMP	USRDRVINSWAIT_EXIT		;

USRDRVINSWAIT_US_BREAK:
	MOV	FLAG_US_BREAK,1			; ユーザの強制終了
USRDRVINSWAIT_EXIT:
	CALL	DSKWID_CLOSE			; ディスク・ウインドウＣＬＯＳＥ
	CALL	DKRESET				; disk reset.
	MOV	DX,DRVNUM			; ドライブ番号（０ー３）
	RET
USRDRVINSWAIT	ENDP


; *********************************************************
;	ﾕｰｻﾞｰﾃﾞｨｽｸか新しいﾃﾞｨｽｸがﾄﾞﾗｲﾌﾞにセットされるのを待つ
;	-O- DX : 対象ディスクのドライブ番号
;	    FLAG_USER_DISK :	1=ユーザディスク
;				2=新しいディスク
;				3=別のソフトが入っている
;				4=ライトプロテクト
;	    FLAG_US_BREAK  : ユーザの強制終了
; *********************************************************

USRDRVNEWDSK	PROC	NEAR
	CALL	DSKWID_OPEN			; ディスク・ウインドウＯＰＥＮ

	MOV	FLAG_US_BREAK,0			; ユーザの強制終了

	MOV	SCH_DISKID,MY_DISKNUM_USR	; ユーザーディスクＩＤ

	MESSAGE	3 ;"ドライブ２にユーザーディスクか"
	MOV	BX,1				; 1=上段,2=中段
	CALL	DSKWID_SRT_PRINT		; ディスク・メッセージ表示

	MESSAGE	4 ;"新しいディスクを入れて下さい",0
	MOV	BX,2				; 1=上段,2=中段
	CALL	DSKWID_SRT_PRINT		; ディスク・メッセージ表示

	CALL	DSKWID_USERST_INI		; ディスク・ユーザスタンバイ初期化

	MOV	FLAG_RELOAD,0			; フラグ・強制ディスクアクセス
	MOVX	DRVNUM,DRVNUMMAX		; １ＭＦＤドライブ数
USRDRVNEWDSK_LOOP:
	CMP	DRVNUM,0			; if DRVNUM = 0 then
	JNE	USRDRVNEWDSK4			;
	MOV	FLAG_RELOAD,0			; フラグ・強制ディスクアクセス
	MOVX	DRVNUM,DRVNUMMAX		; １ＭＦＤドライブ数
USRDRVNEWDSK4:
	CALL	DSKWID_USERSTANBY		; ディスク・ユーザスタンバイ
	CMP	CX,1				; 1=強制終了,0=通常
	JE	USRDRVNEWDSK_US_BREAK		;
	CMP	BX,1				; 1=スタンバイ,0=通常
	JNE	USRDRVNEWDSK5			;

	MOV	FLAG_RELOAD,1			; フラグ・強制ディスクアクセス
	MOVX	DRVNUM,DRVNUMMAX		; １ＭＦＤドライブ数
USRDRVNEWDSK5:
	DEC	DRVNUM				; ドライブ番号（０ー３）

	MOV	AX,DRVNUM			;
	CALL	RAM_DR_EQUIP			; ＲＡＭドライブ接続チェック
	CMP	FLAG_RAM_DR,1			; RAMドライブ接続 1=接続
	JE	USRDRVNEWDSK_NEXT		;

	CALL	DSKIDCHK			; ディスクＩＤの読みだし
	CMP	AX,0				; 0=通常
	JE	USRDRVNEWDSK_DISK_OK		;
	CMP	AX,1				; 1=ディスクはセットされてない
	JE	USRDRVNEWDSK_NEXT		;
						; 2=違うディスクみたい

	CMP	ID_DISKSYSNAME,MY_DISKSYSNAME	; このシステムＩＤ
	JNE	USRDRVNEWDSK_NEW_DISK		;
	CMP	ID_DISKPROG,MY_DISKPROG		; このプログラムＩＤ (6=PRIME2)
	JNE	USRDRVNEWDSK_DISK_ANTHER	;
	CMP	ID_DISKNUMBER,MY_DISKNUM_USR	; ユーザーディスクＩＤ
	JE	USRDRVNEWDSK_DISK_OK		;

	MESSAGE	2 ;2 "ドライブ２にユーザーディスクをいれて下さい"
	MOV	BX,1				; 1=上段,2=中段
	CALL	DSKWID_SRT_PRINT		; ディスク・メッセージ表示
	MESSAGE	1 ;"このディスクではないですよ"
	MOV	BX,2				; 1=上段,2=中段
	CALL	DSKWID_SRT_PRINT		; ディスク・メッセージ表示

USRDRVNEWDSK_NEXT:
	JMP	USRDRVNEWDSK_LOOP

USRDRVNEWDSK_DISK_OK:
	MOV	FLAG_USER_DISK,1		; 1=ユーザディスク
	JMP	USRDRVNEWDSK_EXIT		;

USRDRVNEWDSK_NEW_DISK:
	CALL	DIR_CHECK			; ディレクトリィチェック
	CMP	AX,1				; 0=あたらしい,1=データ有り
	JE	USRDRVNEWDSK_DISK_ANTHER	;
	MOV	FLAG_USER_DISK,2		; 2=新しいディスク
	JMP	USRDRVNEWDSK_EXIT		;

USRDRVNEWDSK_DISK_ANTHER:
	MOV	FLAG_USER_DISK,3		; 3=別のソフトが入っている
	JMP	USRDRVNEWDSK_EXIT		;

USRDRVNEWDSK_US_BREAK:
	MOV	FLAG_US_BREAK,1			; ユーザの強制終了
USRDRVNEWDSK_EXIT:
	CALL	DSKWID_CLOSE			; ディスク・ウインドウＣＬＯＳＥ

	CALL	CHECK_WP			; ライトプロテクトチェック
	CMP	FLAG_W_PROTECT,1		; 1=ﾌﾟﾛﾃｸﾄ
	JNE	USRDRVNEWDSK_EXIT2		;

	MOV	FLAG_USER_DISK,4		; 4=ライトプロテクト

USRDRVNEWDSK_EXIT2:
	CALL	DKRESET				; disk reset.
	MOV	DX,DRVNUM			; ドライブ番号（０ー３）
	RET
USRDRVNEWDSK	ENDP


; *********************************************************
;	ﾕｰｻﾞｰﾃﾞｨｽｸﾄﾞﾗｲﾌﾞ検索のリセット
; *********************************************************

USRDRVRESET	PROC	NEAR
	MOV	FLAG_DOS_RESET,0	; ＤＯＳリセット・フラグ
	MOV	DISK_DOOR_INI[0],0FFH	; ディスク開閉初期ﾌﾗｸﾞ
	MOV	DISK_DOOR_INI[1],0FFH	; ディスク開閉初期ﾌﾗｸﾞ
	MOV	DISK_DOOR_INI[2],0FFH	; ディスク開閉初期ﾌﾗｸﾞ
	MOV	DISK_DOOR_INI[3],0FFH	; ディスク開閉初期ﾌﾗｸﾞ
	RET
USRDRVRESET	ENDP


; *********************************************************
;	ディスクＩＤの読みだし
;	-I- FLAG_RELOAD    : フラグ・強制ディスクアクセス
;	    DRVNUM         : １ＭＦＤドライブ番号（０ー３）
;	    SCH_DISKID     : 検索ディスクＩＤ
;	-O- ID_DISKSYSNAME : システムＩＤ
;	    ID_DISKPROG    : プログラムＩＤ
;	    ID_DISKNUMBER  : ディスク番号
;	    AX             : 0=通常
;	                   : 1=ディスクはセットされていない
;	                   : 2=違うディスクみたい
; *********************************************************

DSKIDCHK	PROC	NEAR
IF DEBUG
	PRV	"ディスクＩＤの読みだし:１ＭＦＤドライブ番号=",DRVNUM
ENDIF
	CALL	IDGET				; ＩＤを汎用変数へセット

	CALL	FDDOOR				; ＦＤドライブドア開閉チェック
	CMP	AX,3				; 3=接続なし
	JE	DSKIDCHK_NOT_RDY		;

	CMP	FLAG_RELOAD,1			; フラグ・強制ディスクアクセス
	JE	DSKIDCHK_READ			;

	CMP	AX,0				; 0=前と変わらず
	JE	DSKIDCHK_OK			;
	CMP	AX,1				; 1=ドアを開閉した
	JE	DSKIDCHK_READ			;
	CMP	AX,2				; 2=ドアが開きっぱなし
	JE	DSKIDCHK_CHK			;
	JMP	DSKIDCHK_NOT_RDY		;

DSKIDCHK_CHK:					;
	CMPX	ID_DISKSYSNAME,MY_DISKSYSNAME	; このシステムＩＤ
	JNE	DSKIDCHK_NOT_RDY		;
	CMPX	ID_DISKPROG,MY_DISKPROG		; このプログラムＩＤ
	JNE	DSKIDCHK_NOT_RDY		;
	CMPX	ID_DISKNUMBER,SCH_DISKID	; 検索ディスクＩＤ
	JNE	DSKIDCHK_NOT_RDY		;

DSKIDCHK_READ:					;
	MOV	AX,DRVNUM			;
	CALL	READIDSEC			; ＩＤセクタの読みだし
	CMP	AX,2				; 2=ノットレディ
	JE	DSKIDCHK_NOT_RDY		;
	CMP	AX,1				; 1=リードエラー
	JE	DSKIDCHK_ERROR			;

	CALL	IDGET				; ＩＤを汎用変数へセット

	CMPX	ID_DISKSYSNAME,MY_DISKSYSNAME	; このシステムＩＤ
	JNE	DSKIDCHK_ERROR			;
	CMPX	ID_DISKPROG,MY_DISKPROG		; このプログラムＩＤ
	JNE	DSKIDCHK_ERROR			;
	CMPX	ID_DISKNUMBER,SCH_DISKID	; 検索ディスクＩＤ
	JNE	DSKIDCHK_ERROR			;

DSKIDCHK_OK:
	CMPX	ID_DISKSYSNAME,MY_DISKSYSNAME	; このシステムＩＤ
	JNE	DSKIDCHK_NOT_RDY		;
	CMPX	ID_DISKPROG,MY_DISKPROG		; このプログラムＩＤ
	JNE	DSKIDCHK_NOT_RDY		;
	CMPX	ID_DISKNUMBER,SCH_DISKID	; 検索ディスクＩＤ
	JNE	DSKIDCHK_NOT_RDY		;

	MOV	AX,0			; 0=通常
	RET
DSKIDCHK_NOT_RDY:
	MOV	AX,1			; 1=ディスクはセットされていない
	RET
DSKIDCHK_ERROR:
	CALL	IDGET			; ＩＤを汎用変数へセット
	MOV	AX,2			; 2=違うディスクみたい
	RET
DSKIDCHK	ENDP


; *********************************************************
;	ＦＤドライブドア開閉チェック
;	-I- DRVNUM : 対象ディスクのドライブ番号
;	-O- AX     : 0=前と変わらず,1=ドアを開閉した,2=ドアが開きっぱなし
;			3=接続なし
; *********************************************************

FDDOOR	PROC	NEAR
IF DEBUG
	PRV	"DRVNUM=",DRVNUM
ENDIF
	PUSH	DX
	PUSH	BX
	PUSH	ES

	MOV	AX,DRVNUM		; ドライブ番号
	CALL	FDEQUIP			; ＦＤ接続チェック
	CMP	AX,0			; 1=接続されている,0=接続無し
	JE	FDDOOR_NO_EQUIP		;

	MOV	AX,DRVNUM		; ドライブ番号
	CALL	FDRSLT			; 開閉チェック(ﾘｻﾞﾙﾄｽﾃｰﾀｽﾁｪｯｸ)
	CMP	AX,2			; 1=ドアを開閉した,2=ドアが開きっぱなし
	JE	FDDOOR_NO_SET		;
	CMP	AX,0			; 0=前と変わらず
	JE	FDDOOR_NORMAL		;

FDDOOR_SET:
	MOV	AX,1			; 1=ドアを開閉した
	JMP	FDDOOR_EXIT		;

FDDOOR_NO_EQUIP:
	MOV	AX,3			; 3=接続なし
	JMP	FDDOOR_EXIT		;

FDDOOR_NO_SET:
	MOV	AX,2			; 2=ドアが開きっぱなし
	JMP	FDDOOR_EXIT		;

FDDOOR_NORMAL:
	MOV	AX,0			; 0=前と変わらず
	JMP	FDDOOR_EXIT		;

FDDOOR_USERSTANBY:
	MOV	AX,1			; 1=ドアを開閉した
	JMP	FDDOOR_EXIT		;

FDDOOR_EXIT:
	POP	ES
	POP	BX
	POP	DX
IF DEBUG
	PRV	"FDDOOR -O- (0n,1oc,2o)=",AX
ENDIF
	RET
FDDOOR	ENDP


; *********************************************************
;	ＦＤドライブドア開閉チェック（リザルトステータスチェック）
;	-I- AX : １ＭＦＤドライブ番号（０ー３）
;	-O- AX : 0=前と変わらず,1=ドアを開閉した,2=ドアが開きっぱなし
; *********************************************************

FDRSLT	PROC	NEAR
	PUSH	DX
	PUSH	BX
	PUSH	ES

	MOV	DX,AX			; DX=ドライブ番号

	MOV	BX,AX
	SHL	BX,1			; *2
	SHL	BX,1			; *4	
	SHL	BX,1			; *8
	ADD	BX,DISK_RESULT_TOP	; リザルトステータス情報アドレス
	MOV	AX,0			;
	MOV	ES,AX			;
	MOV	AL,BYTE PTR ES:[BX]	; disk result status ST0.
	;	  |iiSenHuu|
	;	  |ccEcrDss|
	;	  |10    10|
	AND	AL,11001000B

	CMP	AL,0			;
	JNE	FDRSLT5			;
	MOV	AX,0			; 0=前と変わらず
	JMP	FDRSLT9			;
FDRSLT5:
	CMP	AL,11000000B		;
	JNE	FDRSLT6			;
	MOV	AX,1			; 1=ドアを開閉した
	JMP	FDRSLT9
FDRSLT6:
	CMP	AL,11001000B		;
	JNE	FDRSLT7			;
	MOV	AX,2			; 2=ドアが開きっぱなし
	JMP	FDRSLT9
FDRSLT7:
	MOV	AX,2			; 2=ドアが開きっぱなし

FDRSLT9:				;
	MOV	BX,DX			; DX=ドライブ番号
	CMP	BYTE PTR DS:DISK_DOOR_INI[BX],0	; ディスク開閉初期ﾌﾗｸﾞ
	JZ	FDRSLT_RET		;
	MOV	BYTE PTR DS:DISK_DOOR_INI[BX],0	; ディスク開閉初期ﾌﾗｸﾞ
;*non*;	CMP	AX,0			; 0=前と変わらず
;*non*;	JNE	FDRSLT_RET		;
	MOV	AX,1			; 1=ドアを開閉した
FDRSLT_RET:
	POP	ES
	POP	BX
	POP	DX
IF DEBUG
	PRV	"FDRSLT -O- (0n,1oc,2o)=",AX
ENDIF
	RET
FDRSLT	ENDP


; *********************************************************
;	ＦＤ接続チェック
;	-I- AX : １ＭＦＤドライブ番号（０ー３）
;	-O- AX : 1=接続されている,0=接続無し
; *********************************************************

FDEQUIP	PROC	NEAR
	PUSH	CX
	PUSH	DX

	MOV	DX,0			; 接続チェック
	MOV	ES,DX			;
	MOV	CL,AL			; １ＭＦＤドライブ番号（０ー３）
	MOV	DL,1			;
	SHL	DL,CL			; ビットＯＮならば接続
	TEST	ES:[DISK_EQUIP],DL	; 接続ユニット
	JNZ	FDEQUIP_ON		;
FDEQUIP_OFF:
	MOV	AX,0			; 0=接続無し
	POP	DX
	POP	CX
	RET
FDEQUIP_ON:
	MOV	AX,1			; 1=接続されている
	POP	DX
	POP	CX
	RET
FDEQUIP	ENDP


; *********************************************************
;	ＲＡＭドライブ接続チェック
;	-I- AX          : １ＭＦＤドライブ番号（０ー３）
;	-O- FLAG_RAM_DR : RAMドライブ接続 1=接続されている,0=接続無し
; *********************************************************

RAM_DR_EQUIP	PROC	NEAR
	MOV	DX,0			; 接続チェック
	MOV	ES,DX			;
	MOV	CL,AL			; １ＭＦＤドライブ番号（０ー３）
	MOV	DL,1			;
	SHL	DL,CL			; ビットＯＮならば接続

	TEST	ES:[DISK_EQUIP],DL	; 接続ユニット
	JZ	RAM_DR_EQUIP_OFF	;
	TEST	ES:[RDISK_EQUIP],DL	; ＲＡＭドライブ接続状況識別ビット
	JZ	RAM_DR_EQUIP_OFF	;
	JMP	RAM_DR_EQUIP_ON		;
RAM_DR_EQUIP_OFF:
	MOV	FLAG_RAM_DR,0		; 0=接続無し
	RET
RAM_DR_EQUIP_ON:
	MOV	FLAG_RAM_DR,1		; 1=接続されている
	RET
RAM_DR_EQUIP	ENDP


; *********************************************************
;	ＩＤセクタの読みだし
;	-I- AX : １ＭＦＤドライブ番号（０ー３）
;	-O- DSKID_ADRS[AX*2] : ＩＤテーブルアドレステーブル
;	    AX     : 0=正常,1=リードエラー,2=ノットレディ
; *********************************************************

READIDSEC	PROC	NEAR
	CALL	DRVSET			; set drive number.

	CALL	DRVNO			; drive number get.
	MOV	BX,AX			;
	SHL	BX,1			; word pointer.
	MOV	DI,DS:DSKID_ADRS[BX]	; ディスクＩＤアドレステーブル
	MOVX	ES,DS			;
	MOV	CX,ID_LEN		; ディスクＩＤバイト数
	XOR	AL,AL			; AL=0
	REP	STOSB			; clear.

	MOVX	DCYL,DCYL_ID		; ディスクＩＤ　シリンダ番号
	MOVX	DHEAD,DHEAD_ID		; ディスクＩＤ　ヘッド番号
	MOVX	DSECR,DSECR_ID		; ディスクＩＤ　セクタ番号

	CALL	SCREAD			; セクターリード
	CMP	DERROR,0		; 0=正常,1=エラー
	JNE	READIDSEC_ERROR		;

	CALL	DRVNO			; drive number get.
	MOV	BX,AX			;
	SHL	BX,1			; word pointer.
	MOV	DI,DS:DSKID_ADRS[BX]	; ディスクＩＤアドレステーブル
	MOVX	ES,DS			;
	MOV	SI,SCADRS		; セクタバッファアドレス
	MOV	CX,ID_LEN		; ディスクＩＤバイト数
	REP	MOVSB			;

	MOV	AX,0			; 0=正常
	RET
READIDSEC_ERROR:
IF DEBUG
	PRV	"READIDSEC call-O-scread DERROR=",DERROR
ENDIF
	CMP	DSTAT,DISK_STATUS_NR	; Not Ready. ユニットがノットレディ状態
	JE	READIDSEC_ERROR2	;
	MOV	AX,1			; 1=リードエラー
	RET
READIDSEC_ERROR2:
	MOV	AX,2			; 2=ノットレディ
	RET
READIDSEC	ENDP


; *********************************************************
;	ＩＤテーブルの内容を汎用変数へセット
;	-I- DRVNUM         : １ＭＦＤドライブ番号（０ー３）
;	-O- ID_DISKSYSNAME : システムＩＤ
;	    ID_DISKPROG    : プログラムＩＤ
;	    ID_DISKNUMBER  : ディスク番号
; *********************************************************

IDGET	PROC	NEAR
IF DEBUG
	PRV	"１ＭＦＤドライブ番号=",DRVNUM
ENDIF
	MOV	BX,DRVNUM		; ドライブ番号
	SHL	BX,1			; word pointer.
	MOV	SI,DS:DSKID_ADRS[BX]	; ディスクＩＤアドレステーブル
	MOVX	ID_DISKSYSNAME,DS:[SI][0] ; システムＩＤ
	MOVX	ID_DISKPROG,   DS:[SI][2] ; プログラムＩＤ
	MOVX	ID_DISKNUMBER, DS:[SI][4] ; ディスク番号
IF DEBUG
	PRVH	"システムＩＤ  =",ID_DISKSYSNAME
	PRVH	"プログラムＩＤ=",ID_DISKPROG
	PRV	"ディスク番号  =",ID_DISKNUMBER
ENDIF
	RET
IDGET	ENDP


; *********************************************************
;	セクターリード
;	バウンダリングエラーの為、ＳＣＡＤＲＳが変更される場合がある
;	-I- DCYL  : シリンダ番号（Ｃ）０ー７６
;	    DHEAD : ヘッド番号（Ｈ）０ー１
;	    DSECR : セクタ番号（Ｒ）１ー８（２６）
;	-O- SCADRS : セクタバッファアドレス
;	    DS:[+SCADRS] : セクタのデータ
;	    DERROR : 0=正常,1=エラー
;	    DSTAT  : ステータス情報
; *********************************************************

SCREAD	PROC	NEAR
	CALL	DISK_RESET		; disk reset.
IF DEBUG
	PRVH	"r DUNIT ",DUNIT	; デバイス識別・ユニット番号(DA/UA)
	PRVH	"r DLEN  ",DLEN		; データ長（ＤＴＬ）（バイト単位）
	PRVH	"r DCYL  ",DCYL 	; シリンダ番号（Ｃ）０ー７６
	PRVH	"r DHEAD ",DHEAD	; ヘッド番号（Ｈ）０ー１
	PRVH	"r DSECR ",DSECR	; セクタ番号（Ｒ）１ー８（２６）
	PRVH	"r DSECN ",DSECN	; セクタ長（Ｎ）
ENDIF
	MOV	READ_RETRY,READ_RETCOUNT ; リード・リトライカウンタ
SCREAD5:				;
	MOVX	ES,DS			; セクタバッファ
	MOV	BP,SCADRS		; セクタバッファアドレス

	MOV	AL,BYTE PTR DUNIT	; デバイス識別・ユニット番号(DA/UA)
	MOV	BX,WORD PTR DLEN 	; データ長（ＤＴＬ）（バイト単位）
	MOV	CL,BYTE PTR DCYL 	; シリンダ番号（Ｃ）０ー７６
	MOV	DH,BYTE PTR DHEAD	; ヘッド番号（Ｈ）０ー１
	MOV	DL,BYTE PTR DSECR	; セクタ番号（Ｒ）１ー８（２６）
	MOV	CH,BYTE PTR DSECN	; セクタ長（Ｎ）
	MOV	AH,BYTE PTR DREAD	; READ DATA.
	INT_FD_BIOS		 	; disk/FD bios.
	MOV	BYTE PTR DSTAT,AH	; ステータス情報
	JNC	SCREAD9		  	; 正常終了

	CMP	BYTE PTR DSTAT,DISK_STATUS_DB	; DMA Boundary.
	JNE	SCREAD6

;*;	PRF	"致命的なエラー( READ SECTOR:error DB )"
;*;	PRF	"DMA Boundary error.によりバッファ切替"
;*;	MOV	AX,TIME_DKCMSG		; メッセージ時間
;*;	CALL	TMVWAT			;V-SYNC timer wait.
;*;	CALL	CLS			;

	MOV	SCADRS,OFFSET SCDATA2	; セクタバッファアドレス
	JMP	SCREAD5			; ＤＭＡバッファの変更

SCREAD6:				;
	DEC	READ_RETRY		; リード・リトライカウンタ
	JZ	SCREAD99		;

	MOV	AH,BYTE PTR DRECAL	; RECALIBRATE
	INT_FD_BIOS			; disk/FD bios.
	MOV	BYTE PTR DSTAT,AH	; ステータス情報
IF DEBUG
	PRVH	"R recalibrate DSTAT=",DSTAT
ENDIF
	JMP	SCREAD5
SCREAD9:
	MOV	DERROR,0		; 0=正常
	RET
SCREAD99:
	MOV	DERROR,1		; 1=エラー
	RET
SCREAD	ENDP


; *********************************************************
;	set drive number.
;	-I- AX : 1MFD drive number.
; *********************************************************

DRVSET	PROC	NEAR
	PUSH	AX
	AND	AL,011B
	AND	BYTE PTR DUNIT,11111100B
	OR	BYTE PTR DUNIT,AL
	POP	AX
	RET
DRVSET	ENDP


; *********************************************************
;	drive number get.
;	-O- AX : 1MFD drive number.
; *********************************************************

DRVNO	PROC	NEAR
	MOV	AX,DUNIT	; デバイス識別・ユニット番号（DA/UA）
	AND	AX,00000011B	; DA/UA=100100dd
IF DEBUG
	PRV	"DUNITのドライブ番号=",AX
ENDIF
	RET
DRVNO	ENDP


; *********************************************************
;	ライトプロテクトチェック
;	-I- DRVNUM         : １ＭＦＤドライブ番号（０－３）
;	-O- FLAG_W_PROTECT : フラグ・ライトプロテクト 1=ﾌﾟﾛﾃｸﾄ
; *********************************************************

CHECK_WP	PROC	NEAR
	MOV	FLAG_W_PROTECT,0	; フラグ・ライトプロテクト 1=ﾌﾟﾛﾃｸﾄ

	MOV	AX,DRVNUM		; 対象ディスクのドライブ番号
					; AX=ドライブ番号
					; 90Hは１ＭＦＤであることを示す
	OR	AL,90H			; AL=デバイス識別・ユニット番号(DA/UA)
	MOV	AH,BYTE PTR DSENSE_NEW	; ＳＥＮＳＥ（／ＳＴＡＴＵＳ）
	INT	1BH			; ディスクＢＩＯＳ
	JB	CHECK_WP_8		; CF=1 異常終了

	AND	AH,0F0H			; bit0-7 clear.
	CMP	AH,DISK_STATUS_WP	; Write Protect.ライトプロテクト状態
	JNE	CHECK_WP_5		;
	MOV	FLAG_W_PROTECT,1	; フラグ・ライトプロテクト 1=ﾌﾟﾛﾃｸﾄ
CHECK_WP_5:
CHECK_WP_8:
IF DEBUG
	PRV	"FLAG_W_PROTECT=",FLAG_W_PROTECT
ENDIF
	RET
CHECK_WP	ENDP


; *********************************************************
;	ディレクトリィチェック
;	-I- DRVNUM : 対象ディスクのドライブ番号
;	-O- AX     : 0=あたらしい,1=データ有り
; *********************************************************

DIR_CHECK	PROC	NEAR
	MOV	AX,DRVNUM	;
	CALL	DRVSET		; ドライブ番号の設定（０ー３）

	MOV	AX,DCYL_DIR	; ＲＯＯＴ　シリンダ番号（Ｃ）
	MOV	DCYL,AX		; シリンダ番号（Ｃ）０ー７６
	MOV	AX,DHEAD_DIR	; ＲＯＯＴ　ヘッド番号（Ｈ）
	MOV	DHEAD,AX	; ヘッド番号（Ｈ）０ー１
	MOV	AX,DSECR_DIR	; ＲＯＯＴ　セクタ番号（Ｒ）
	MOV	DSECR,AX	; セクタ番号（Ｒ）１ー８（２６）

	CALL	SCREAD		; セクターリード
IF DEBUG
	PRV	"DIR_CHECK call-O-scread DERROR=",DERROR
ENDIF
	CMP	DERROR,0	; 0=正常,1=エラー
	JNE	DIR_CHECK_NEW	;

	MOV	SI,SCADRS	; セクタバッファアドレス
	CMP	DS:[SI],BYTE PTR 0
	JNE	DIR_CHECK_ARI	;

DIR_CHECK_NEW:
	MOV	AX,0		; 0=あたらしい
	RET
DIR_CHECK_ARI:
	MOV	AX,1		; 1=データ有り
	RET
DIR_CHECK	ENDP


; *********************************************************
;	disk reset.
; *********************************************************

DISK_RESET	PROC	NEAR
	CMP	FLAG_DOS_RESET,1	; ＤＯＳリセット・フラグ
	JE	DISK_RESET_EXIT		;
	MOV	FLAG_DOS_RESET,1	; ＤＯＳリセット・フラグ
	CALL	DKRESET			; disk reset.
DISK_RESET_EXIT:
	RET
DISK_RESET	ENDP


CODE	ENDS



CODE	SEGMENT	PUBLIC	'CODE'

PUBLIC	FLAG_USER_DISK			; ユーザディスクフラグ
PUBLIC	FLAG_US_BREAK			; ユーザの強制終了

;	sector buffer (DMA buffer)
;	DMA Boundary error. reserved SCDATA2

PUBLIC	SCADRS					; sector buffer address.
EXTRN	SCDATA:BYTE				; sector buffer.
EXTRN	SCDATA2:BYTE				; sector buff(reserved DMA err)
SCADRS	DW	OFFSET SCDATA			; sector buffer address.


;	PC9801 disk device.
;	bios command.
;
;			MM-S....
;			TFrK0110
DREAD		DW	11110110B	; READ DATA.
DRECAL		DW	00000111B	; RECALIBRATE(old 00100111B)
DSENSE_NEW	DW	84H		; SENSE(/STATUS)

;			100100dd
DUNIT		DW	10010001B	; device unit(DA/UA)

;	IDR (ID value)

DLEN		DW	SEC_BYTE	; データ長（ＤＴＬ）（バイト単位）
DCYL		DW	0		; シリンダ番号（Ｃ）０ー７６
DHEAD		DW	0		; ヘッド番号（Ｈ）０ー１
DSECR		DW	1		; セクタ番号（Ｒ）１ー８（２６）
DSECN		DW	03		; セクタ長（Ｎ）
					; 00/128, 01/256, 02/512, 03/1024
DSTAT		DW	0		; ステータス情報
DERROR		DW	0		; 0=正常,1=エラー

READ_RETRY	DW	0		; リード・リトライカウンタ

FLAG_RAM_DR	DW	0		; RAMドライブ接続
					; 1=接続されている,0=接続無し

FLAG_USER_DISK	DW	0		; ユーザディスクフラグ
					; 1=ユーザディスク
					; 2=新しいディスク
					; 3=別のソフトが入っている
					; 4=ライトプロテクト

FLAG_US_BREAK	DW	0		; ユーザの強制終了

FLAG_W_PROTECT	DW	0		; フラグ・ライトプロテクト 1=ﾌﾟﾛﾃｸﾄ

SCH_DISKID	DW	0		; 検索ディスクＩＤ

DRVNUMMAX	DW	DRVNUMMAX_FIX	; １ＭＦＤドライブ数
DRVNUM		DW	0		; ドライブ番号（０ー３）

ID_DISKSYSNAME	DW	0		; システムＩＤ
ID_DISKPROG	DW	0		; プログラムＩＤ
ID_DISKNUMBER	DW	0		; ディスク番号

FLAG_RELOAD	DW	0		; フラグ・強制ディスクアクセス
FLAG_DOS_RESET	DW	0		; ＤＯＳリセット・フラグ

DISK_DOOR_INI	DB	0FFH,0FFH,0FFH,0FFH	; ディスク開閉初期ﾌﾗｸﾞ

DSKID_ADRS	LABEL	WORD		; ディスクＩＤアドレステーブル
		DW	DSKID0,DSKID1,DSKID2,DSKID3
DSKID0		DB	ID_LEN DUP (0)	; ドライブ０のＩＤテーブル
DSKID1		DB	ID_LEN DUP (0)	; ドライブ１のＩＤテーブル
DSKID2		DB	ID_LEN DUP (0)	; ドライブ２のＩＤテーブル
DSKID3		DB	ID_LEN DUP (0)	; ドライブ３のＩＤテーブル

STR_NULL	DB	"1111",0,0

CODE	ENDS

	END
;
;	end of "DSKCHECK.ASM"
;
