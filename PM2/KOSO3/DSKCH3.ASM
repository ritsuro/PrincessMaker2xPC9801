; "DSKCH3.ASM" PC-9801UV11 make by R.H 1992/05/18
;
;
;	disk chenger  disk ID read.
;
;
; i/o subroutine.

INCLUDE	TSTSET.INC
INCLUDE	DSKCH2.INC
INCLUDE	MESSAGE.INC

DEBUG		EQU	0		; デバックアセンブルフラグ

DCYL_ID		EQU	0		; ディスクＩＤ　シリンダ番号（Ｃ）
DHEAD_ID	EQU	1		; ディスクＩＤ　ヘッド番号（Ｈ）
DSECR_ID	EQU	3		; ディスクＩＤ　セクタ番号（Ｒ）

SEC_BYTE	EQU	1024		; セクタバイト数

ID_LEN		EQU	10		; ディスクＩＤバイト数
DRVNUMMAX_FIX	EQU	4		; １ＭＦＤ固定ドライブ数

DISK_RESULT_TOP	EQU	0564H		; リザルトステータス情報アドレス
DISK_EQUIP	EQU	055CH		; 接続ユニット
RDISK_EQUIP	EQU	0488H		; ＲＡＭドライブ接続状況識別ビット

DISK_STATUS_DB	EQU	20H		; DMA Boundary. メモリアドレスがＤＭＡ
					; に向いていない（バンクにまたがった）
DISK_STATUS_NR	EQU	60H		; Not Ready. ユニットがノットレディ状態

READ_RETCOUNT 	EQU	3		; リード・リトライ回数

INT_FD_BIOS	MACRO			; PC9801 disk/FD bios.
		INT	1BH		; disk bios.
		ENDM

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	DKCDRVCHK		; 対象ディスクのドライブ検索
PUBLIC	DKCDRVINSWAIT		; ドライブにセットされるのを待つ
PUBLIC	DKCDRVNOWFD		; 現在セットされているディスク
PUBLIC	DKCDRVRESET		; ディスクドライブ検索のリセット

EXTRN	DSKWID_SET_MESSAGE:NEAR	; ディスク・セットメッセージ
EXTRN	DSKWID_SRT_PRINT:NEAR	; ディスク・メッセージ表示
EXTRN	DSKWID_USERST_INI:NEAR	; ディスク・ユーザスタンバイ初期化
EXTRN	DSKWID_USERSTANBY:NEAR	; ディスク・ユーザスタンバイ

EXTRN	TMVWT4:NEAR		; V-SYNC timer4 wait.

EXTRN	DKRESET:NEAR		; disk reset.

; *********************************************************
;	対象ディスクのドライブ検索
;	-I- DX : 検索ディスクＩＤ
;	-O- AX : 0=対象ディスクはセットされています
;	         1=対象ディスクが挿入されていません
;	    DX : 対象ディスクのドライブ番号
; *********************************************************

DKCDRVCHK	PROC	NEAR
	MOV	SCH_DISKID,DX		; 検索ディスクＩＤ
IF DEBUG
	PRV	"検索ディスクＩＤ=",SCH_DISKID
ENDIF
	MOV	FLAG_DOS_RESET,0	; ＤＯＳリセット・フラグ

	MOV	FLAG_RELOAD,0		; フラグ・強制ディスクアクセス
	MOVX	DRVNUM,DRVNUMMAX	; １ＭＦＤドライブ数
DKCDRVCHK_LOOP:
	CMP	DRVNUM,0		; １ＭＦＤドライブ番号（０ー３）
	JE	DKCDRVCHK_NONE		; 見つからなかった

	DEC	DRVNUM			;

	CALL	DSKIDCHK		; ディスクＩＤの読みだし
	CMP	AX,0			; 0=通常
	JE	DKCDRVCHK_OK		; このディスクが対象ディスクです
	CMP	AX,1			; 1=ディスクはセットされていない
	JE	DKCDRVCHK_NEXT		;
					; 2=違うディスクみたい
DKCDRVCHK_NEXT:				;
	JMP	DKCDRVCHK_LOOP		;

DKCDRVCHK_OK:
	MOV	DX,DRVNUM		; 対象ディスクのドライブ番号
	MOV	AX,0			; 0=対象ディスクはセットされています
IF DEBUG
	PRF	"セット"
ENDIF
	RET
DKCDRVCHK_NONE:
	MOV	DX,DRVNUM		; 対象ディスクのドライブ番号
	MOV	AX,1			; 1=対象ディスクが挿入されていません
IF DEBUG
	PRF	"ない"
ENDIF
	RET
DKCDRVCHK	ENDP


; *********************************************************
;	ドライブにセットされるのを待つ
;	-I- DX : 検索ディスクＩＤ
;	-O- DX : 対象ディスクのドライブ番号
; *********************************************************

DKCDRVINSWAIT	PROC	NEAR
	MOV	SCH_DISKID,DX			; 検索ディスクＩＤ

	CALL	DSKWID_SET_MESSAGE		; ディスク・セットメッセージ

	CALL	DSKWID_USERST_INI		; ディスク・ユーザスタンバイ初期化

	MOV	FLAG_RELOAD,0			; フラグ・強制ディスクアクセス
	MOVX	DRVNUM,DRVNUMMAX		; １ＭＦＤドライブ数
DKCDRVINSWAIT_LOOP:
	CMP	DRVNUM,0			; if DRVNUM = 0 then
	JNE	DKCDRVINSWAIT4			;
	MOV	FLAG_RELOAD,0			; フラグ・強制ディスクアクセス
	MOVX	DRVNUM,DRVNUMMAX		; １ＭＦＤドライブ数
DKCDRVINSWAIT4:
	CALL	DSKWID_USERSTANBY		; ディスク・ユーザスタンバイ
	CMP	BX,1				; 1=スタンバイ,0=通常
	JNE	DKCDRVINSWAIT5			;
	MOV	FLAG_RELOAD,1			; フラグ・強制ディスクアクセス
	MOVX	DRVNUM,DRVNUMMAX		; １ＭＦＤドライブ数
DKCDRVINSWAIT5:
	DEC	DRVNUM				; ドライブ番号（０ー３）

	CALL	DSKIDCHK			; ディスクＩＤの読みだし
	CMP	AX,0				; 0=通常
	JE	DKCDRVINSWAIT_DISK_OK		;
	CMP	AX,1				; 1=ディスクはセットされてない
	JE	DKCDRVINSWAIT_NEXT		;
						; 2=違うディスクみたい

	MOV	AX,DRVNUM			;
	CALL	RAM_DR_EQUIP			; ＲＡＭドライブ接続チェック
	CMP	FLAG_RAM_DR,1			; RAMドライブ接続 1=接続
	JE	DKCDRVINSWAIT_NEXT		;

	MESSAGE	1 ;"このディスクではないですよ"
	MOV	BX,2				; 1=上段,2=中段
	CALL	DSKWID_SRT_PRINT		; ディスク・メッセージ表示

DKCDRVINSWAIT_NEXT:
	JMP	DKCDRVINSWAIT_LOOP

DKCDRVINSWAIT_DISK_OK:
	CALL	DKRESET				; disk reset.
	MOV	DX,DRVNUM			; ドライブ番号（０ー３）
	RET
DKCDRVINSWAIT	ENDP


; *********************************************************
;	現在セットされているディスク
;	-0- AX : ﾄﾞﾗｲﾌﾞ0のﾃﾞｨｽｸ番号
;	    BX : ﾄﾞﾗｲﾌﾞ1のﾃﾞｨｽｸ番号
;	    CX : ﾄﾞﾗｲﾌﾞ2のﾃﾞｨｽｸ番号
;	    DX : ﾄﾞﾗｲﾌﾞ3のﾃﾞｨｽｸ番号
; *********************************************************

DKCDRVNOWFD	PROC	NEAR
	MOV	AX,WORD PTR DSKID0[4]	; ﾄﾞﾗｲﾌﾞ0のIDﾃｰﾌﾞﾙ ﾃﾞｨｽｸ番号
	MOV	BX,WORD PTR DSKID1[4]	; ﾄﾞﾗｲﾌﾞ1のIDﾃｰﾌﾞﾙ
	MOV	CX,WORD PTR DSKID2[4]	; ﾄﾞﾗｲﾌﾞ2のIDﾃｰﾌﾞﾙ
	MOV	DX,WORD PTR DSKID3[4]	; ﾄﾞﾗｲﾌﾞ3のIDﾃｰﾌﾞﾙ
	RET
DKCDRVNOWFD	ENDP


; *********************************************************
;	ディスクドライブ検索のリセット
; *********************************************************

DKCDRVRESET	PROC	NEAR
	MOV	FLAG_DOS_RESET,0	; ＤＯＳリセット・フラグ
	MOV	DISK_DOOR_INI[0],0FFH	; ディスク開閉初期ﾌﾗｸﾞ
	MOV	DISK_DOOR_INI[1],0FFH	; ディスク開閉初期ﾌﾗｸﾞ
	MOV	DISK_DOOR_INI[2],0FFH	; ディスク開閉初期ﾌﾗｸﾞ
	MOV	DISK_DOOR_INI[3],0FFH	; ディスク開閉初期ﾌﾗｸﾞ
	RET
DKCDRVRESET	ENDP


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
;	    DATA:[+SCADRS] : セクタのデータ
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
	MOVX	ES,<SEG DATA>		; セクタバッファ
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

	PRF	"致命的なエラー( READ SECTOR:error DB )"
	PRF	"DMA Boundary error.によりバッファ切替"

	MOV	AX,TIME_DKCMSG		; メッセージ時間
	CALL	TMVWT4			; V-SYNC timer4 wait.
	CALL	CLS			;

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


CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

;	sector buffer (DMA buffer)
;	DMA Boundary error. reserved SCDATA2

PUBLIC	SCDATA					; sector buffer.
PUBLIC	SCDATA2					; sector buff(reserved DMA err)
SCADRS	DW	OFFSET SCDATA			; sector buffer address.
SCDATA	DB	SEC_BYTE DUP (0)		; sector buffer.

;	PC9801 disk device.
;	bios command.
;
;			MM-S....
;			TFrK0110
DREAD		DW	11110110B	; READ DATA.
DRECAL		DW	00000111B	; RECALIBRATE(old 00100111B)

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

;	DMA Boundary error. reserved SCDATA2
	EVEN
SCDATA2	DB	SEC_BYTE DUP (0)	; sector buff(reserved DMA err)
	DB	0,0

DATA	ENDS

	END
;
;	end of "DSKCH3.ASM"
;
