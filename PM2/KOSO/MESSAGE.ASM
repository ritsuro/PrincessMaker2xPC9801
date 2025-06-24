; "MESSAGE.ASM" 486/50 make by R.H 1992/05/15
;
;
;	message table.
;
;
; public subroutine.


CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	MESSAGE_ADGET		; message address get.(far)
PUBLIC	MESSAGE_DRVSET		; message drive set.

;	message address get.(far)
;	-I- BX : message number.
;	-O- SI : message address.

MESSAGE_ADGET	PROC	FAR
	SHL	BX,1
	ADD	BX,MSGTABLE_ADRS	; メッセージテーブルアドレス
	MOV	SI,DS:[BX]
	RET
MESSAGE_ADGET	ENDP


;	message drive set.
;	-I- BX : drive number.(1=1,2=2,3=3,4=4)
;	    DI : disk name.(1=A,2=B,3=C...)
;	-O- SI : message address.

MESSAGE_DRVSET	PROC	NEAR
	CMP	DI,13			; disk name.(1=A,2=B,3=C...)
	JE	MESSAGE_DRVSET_USERDISK	;

	MOV	AX,8250H-1			;8250H"１"
	ADD	AX,BX				;
	XCHG	AH,AL				;
	MOV	WORD PTR MSG_DRVINST_DR,AX	;

	MOV	AX,8260H-1			;8260H"Ａ"
	ADD	AX,DI				;
	XCHG	AH,AL				;
	MOV	WORD PTR MSG_DRVINST_DK,AX	;

	MOV	SI,OFFSET MSG_DRVINST
	RET
MESSAGE_DRVSET_USERDISK:
	MOV	SI,OFFSET MSG_USR_DRVINST
	RET
MESSAGE_DRVSET	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

MSGTABLE_ADRS	DW	MESSAGE_TABLE	; メッセージテーブルアドレス

MSG_DRVINST	DB	"ドライブ"
MSG_DRVINST_DR	DB	"１"
		DB	"にディスク"
MSG_DRVINST_DK	DB	"Ａ"
		DB	"を入れて下さい",0

MSG_USR_DRVINST	DB	"ドライブ２にユーザーディスクを入れて下さい",0

MESSAGE_TABLE	LABEL	WORD		; メッセージテーブル
	DW	M00,M01,M02,M03,M04,M05,M06,M07,M08,M09
	DW	M10,M11,M12,M13,M14,M15,M16,M17,M18,M19
M00	DB	0
M01	DB	"このディスクではないですよ",0
M02	DB	"ファイルが見つかりません",0
M03	DB	"SYSTEM ERROR",0
M04	LABEL	BYTE
M05	LABEL	BYTE
M06	LABEL	BYTE
M07	LABEL	BYTE
M08	DB	"void",0
M09	DB	"通常メモリ拡張の為，EMS を使用します frame:",0
M10	DB	"エラーが発生しました: ",0
M11	DB	0 ;;;;;;;;"ＰＭ２とタイプしてリターンキーを押して下さい",0
M12	DB	"メモリーが足りません、ドライバ等をはずして下さい",0
M13	DB	"ファイルが見つかりません",0
M14	DB	"ＥＭＳが異常です",0
M15	DB	"ファイル'LIBINDEX.DIR'が見つかりません",0
M16	DB	"ＥＭＳへデータを読み込んでいます",0
M17	DB	0
M18	DB	0
M19	DB	0

DATA	ENDS

	END
;
;	end of "MESSAGE.ASM"
;
