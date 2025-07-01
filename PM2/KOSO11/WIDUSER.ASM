; "WIDUSER.ASM" 486/50 make by R.H 1993/03/22
;
;
;	ユーザーディスク作成・ウインドウ
;
;
;	WIDUSERNEWDISK	; WINDOWS/ﾕｰｻﾞｰﾃﾞｨｽｸか新しいﾃﾞｨｽｸｾｯﾄ
;	WIDUSERDSET	; WINDOWS/ﾕｰｻﾞｰﾃﾞｨｽｸをセットさせる
;	WIDUSERMAKE	; WINDOWS/ﾕｰｻﾞｰﾃﾞｨｽｸの作成
;
;
; (C)1993 ritsurou hashimoto.

INCLUDE	TSTSET.INC

OFFF			EQU	-1		; off.
EOS			EQU	0		; end of string.

USERDISK_USE_CLAST	EQU	80		; ﾕｰｻﾞｰﾃﾞｨｽｸの使用クラスタ数

FUNC	MACRO	SUB
PUBLIC	SUB
SUB	PROC	NEAR
	ENDM

FEND	MACRO	SUB
SUB	ENDP
	ENDM

STRS	MACRO	RRR,STRING
	LOCAL	L1,L2
	JMP	L2
L1	DB	STRING,0
L2:
	MOV	RRR,OFFSET L1
	ENDM

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

; ****************************************************
;	WINDOWS/ﾕｰｻﾞｰﾃﾞｨｽｸか新しいﾃﾞｨｽｸｾｯﾄ
;	-O- BX : 1=ユーザの強制終了
;	    CX : 1=ユーザディスク
;		 2=新しいディスク
;		 3=別のソフトが入っている
;		 4=ライトプロテクト
;	    DX : 対象ディスクのドライブ番号
; ****************************************************

FUNC	WIDUSERNEWDISK
	CALLE	USRDRVRESET		; ﾕｰｻﾞｰﾃﾞｨｽｸﾄﾞﾗｲﾌﾞ検索のリセット

	CALLE	USRDRVCHK		; ﾕｰｻﾞｰﾃﾞｨｽｸのドライブ検索
	MOV	DRVNO_USER,DX		; 対象ディスクのドライブ番号
	CMP	AX,0			; 0=対象ディスクはセットされています
	JE	WIDUSERNEWDISK_USR_DSK	;

	CALLE	USRDRVNEWDSK		; ﾕｰｻﾞｰﾃﾞｨｽｸか新しいﾃﾞｨｽｸのセット待つ
	MOV	DRVNO_USER,DX		; 対象ディスクのドライブ番号

	MOV	BX,FLAG_US_BREAK	; ユーザの強制終了
	MOV	CX,FLAG_USER_DISK	; ユーザディスクフラグ

	JMP	WIDUSERNEWDISK_EXIT	;

WIDUSERNEWDISK_USR_DSK:
	MOV	BX,0			; ユーザの強制終了
	MOV	CX,1			; 1=ユーザディスク

WIDUSERNEWDISK_EXIT:
	PUSH	BX
	PUSH	CX
	CALLE	DKCDRVRESET		; ディスクドライブ検索のリセット
	POP	CX
	POP	BX
	MOV	DX,DRVNO_USER		; 対象ディスクのドライブ番号
	RET
FEND	WIDUSERNEWDISK


; ****************************************************
;	WINDOWS/ﾕｰｻﾞｰﾃﾞｨｽｸをセットさせる
;	-O- BX : 1=ユーザの強制終了
;	    DX : 対象ディスクのドライブ番号
;	    DRVNO_USER : 対象ディスクのドライブ番号
; ****************************************************

FUNC	WIDUSERDSET
	CALLE	USRDRVRESET		; ﾕｰｻﾞｰﾃﾞｨｽｸﾄﾞﾗｲﾌﾞ検索のリセット

	CALLE	USRDRVCHK		; ﾕｰｻﾞｰﾃﾞｨｽｸのドライブ検索
	MOV	DRVNO_USER,DX		; 対象ディスクのドライブ番号
	CMP	AX,0			; 0=対象ディスクはセットされています
	JE	WIDUSERDSET_USR_DSK	;

	CALLE	USRDRVINSWAIT		; ﾕｰｻﾞｰﾃﾞｨｽｸがﾄﾞﾗｲﾌﾞにセット待つ
	MOV	DRVNO_USER,DX		; 対象ディスクのドライブ番号

	MOV	BX,FLAG_US_BREAK	; ユーザの強制終了

	JMP	WIDUSERDSET_EXIT	;

WIDUSERDSET_USR_DSK:
	MOV	BX,0

WIDUSERDSET_EXIT:
	PUSH	BX
	CALLE	DKCDRVRESET		; ディスクドライブ検索のリセット
	POP	BX
	MOV	DX,DRVNO_USER		; 対象ディスクのドライブ番号
	RET
FEND	WIDUSERDSET


; ****************************************************
;	WINDOWS/ﾕｰｻﾞｰﾃﾞｨｽｸの作成
;	-O- AX : 0=正常, 2=ディスクエラー
;	         3=デバイスがノットレディ, 4=ライトプロテクト
;	         1=エラー,10=ユーザディスクじゃない
; ****************************************************

FUNC	WIDUSERMAKE
	MOV	AX,DRVNO_USER		; 対象ディスクのドライブ番号
	CALLE	DKFDNO			; フォーマットのドライブ番号の設定

	CALLE	DKFORM			; ディスクのフォーマット
	CMP	AX,0			;
	JNE	WIDUSERMAKE_EXIT	;

	MOV	DX,USERDISK_USE_CLAST	; ﾕｰｻﾞｰﾃﾞｨｽｸの使用クラスタ数
	CALLE	DKF2ND			; ディスクのセカンドフォーマット

WIDUSERMAKE_EXIT:
	RET
FEND	WIDUSERMAKE


; ****************************************************
;	data.
; ****************************************************

EXTRN	FLAG_USER_DISK:WORD		; ユーザディスクフラグ
EXTRN	FLAG_US_BREAK:WORD		; ユーザの強制終了

DRVNO_USER	DW	0		; 対象ディスクのドライブ番号

CODE	ENDS

	END
;
;	end of "WIDUSER.ASM"
;
