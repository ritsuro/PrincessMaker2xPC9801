; "MESSAGE.ASM" PS55Z/S14 make by R.H/japan 1991/09/12
;
;	message.
;
; message program.

INCLUDE	TSTSET.INC
INCLUDE	MACHINE.INC

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	DSPMESS			; disply message.
PUBLIC	DSPPRNT			; console message.
PUBLIC	DSPPRTS			; console message string.
PUBLIC	DSPLANGUAGE		; disply language mode.

EXTRN	VW_PRINT:NEAR			; view/print.

; ****************************************************
;	disply message.
;	-I- AX : message number.
; ****************************************************

DSPMESS	PROC	NEAR
	MOV	MESSAGE_NUM,AX			; message number.

	MOV	BX,MESSAGE_NUM			; message number.
	SHL	BX,1				; word pointer.
	MOV	SI,DS:MESSAGE_TABLE[BX]		; message.
	CALL	VW_PRINT			; view/print.
	RET
DSPMESS	ENDP


; ****************************************************
;	console message.
;	-I- AX : message number.
; ****************************************************

DSPPRNT	PROC	NEAR
	MOV	MESSAGE_NUM,AX			; message number.

	MOV	BX,MESSAGE_NUM			; message number.
	SHL	BX,1				; word pointer.
	MOV	SI,DS:MESSAGE_TABLE[BX]		; message.
	CALL	PRINT				; print.
	RET
DSPPRNT	ENDP


; ****************************************************
;	console message string.
;	-I- SI : string.
; ****************************************************

DSPPRTS	PROC	NEAR
	CALL	PRINT				; print.
	RET
DSPPRTS	ENDP


; ****************************************************
;	disply language mode.
;	-I- AX : 0=english mode,1=japan mode.
; ****************************************************

DSPLANGUAGE	PROC	NEAR
;*;	CMP	AX,1			; 0=english mode,1=japan mode.
;*;	JE	DSPLANGUAGE_JAPAN	;
;*;
;*;DSPLANGUAGE_ENGLISH:
;*;	MOVX	ES,DS
;*;	MOV	SI,OFFSET MESSAGE_TABLE_E
;*;	MOV	DI,OFFSET MESSAGE_TABLE
;*;	MOV	CX,MESSAGE_MAX			; message max.
;*;	REP	MOVSW
;*;	RET
;*;DSPLANGUAGE_JAPAN:
;*;	MOVX	ES,DS
;*;	MOV	SI,OFFSET MESSAGE_TABLE_J
;*;	MOV	DI,OFFSET MESSAGE_TABLE
;*;	MOV	CX,MESSAGE_MAX			; message max.
;*;	REP	MOVSW
	RET
DSPLANGUAGE	ENDP


MESSAGE_NUM	DW	0			; message number.
MESSAGE_MAX	DW	47			; message max.
MESSAGE_TABLE	LABEL	WORD
	DW	ME00,ME01,ME02,ME03,ME04,ME05,ME06,ME07,ME08,ME09
	DW	ME10,ME11,ME12,ME13,ME14,ME15,ME16,ME17,ME18,ME19
	DW	ME20,ME21,ME22,ME23,ME24,ME25,ME26,ME27,ME28,ME29
	DW	ME30,ME31,ME32,ME33,ME34,ME35,ME36,ME37,ME38,ME39
	DW	ME40,ME41,ME42,ME43,ME44,ME45,ME46

;*;MESSAGE_TABLE_J	LABEL	WORD
;*;	DW	ME00,ME01,ME02,ME03,ME04,ME05,ME06,ME07,ME08,ME09
;*;	DW	ME10,ME11,ME12,ME13,ME14,ME15,ME16,ME17,ME18,ME19
;*;	DW	ME20,ME21,ME22,ME23,ME24,ME25,ME26,ME27,ME28,ME29
;*;	DW	ME30,ME31,ME32,ME33,ME34,ME35,ME36,ME37,ME38,ME39
;*;	DW	ME40

ME00	DB "ハードディスクへの転送先を入力して下さい。",0
ME01	DB "フロッピーディスクのドライブを入力して下さい。",0
ME02	DB "	この設定で良ければ、リターンキー を押して下さい。",0DH,0AH
	DB "	",0DH,0AH
	DB "	設定を変更したいときは、f･2 を押して下さい。",0DH,0AH
	DB "	",0DH,0AH
	DB "	インストールしないで終了するときは、f･3 を押して下さい。",0DH,0AH
	DB	0

ME03	DB	"プリンセスメーカー２　インストールプログラム",0DH,0AH,0
ME04	DB	"	INSTALL プログラムはゲームディスクの内容をハードディスク上へ",0DH,0AH
DB	"	コピーする為のものです。",0DH,0AH
DB	"	ハードディスクを利用すると、フロッピーディスクの交換の",0DH,0AH
DB	"	必要がなくなり快適にゲームを行うことが出来ます。",0DH,0AH
DB	0DH,0AH
DB	0DH,0AH
DB	"	これからインストールするときは、リターンキー を押して下さい。",0DH,0AH
DB	0DH,0AH
DB	"	インストールしないで終了するときは、f･3 を押して下さい。",0

ME05	DB	"  リターンキー= 続行  f･3= 終了",0
ME06	DB	"	INSTALL を開始します",0
ME07	DB	"フロッピーディスクのドライブ名",0
ME08	DB	"インストール先のパス名",0

ME09	DB	"ディスク",0
ME10	DB	"Ａ",0
ME11	DB	"Ｂ",0
ME12	DB	"Ｃ",0
ME13	DB	"Ｄ",0
ME14	DB	"Ｅ",0
ME15	DB	"Ｆ",0
ME16	DB	"Ｇ",0
ME17	DB	" にセットして リターンキー を押してください。",0DH,0AH
	DB	"　　　　　（中断したいときは f･3 を押して下さい。）",0DH,0AH,0
ME18	DB "ディスクＡ,Ｂ,Ｃ,Ｄ,Ｅ,Ｆ,Ｇ,Ｈ,Ｉ,Ｊ,Ｋ,Ｌの順番でコピーします",0DH,0AH,0
ME19	DB	"が、うまくセットされていません。",0DH,0AH,0
ME20	DB	"ディレクトリィ ",0
ME21	DB	" が作成できません。",0DH,0AH
	DB "別のディレクトリィで再度インストールを試みて下さい。",0DH,0AH,0
ME22	DB	"ドライブ名はＡからＺの英文字１文字です。",0
ME23	DB "	戻るときは、ESC を押して下さい。",0DH,0AH
	DB 0DH,0AH
	DB "	インストールしないで終了するときは、f･3 を押して下さい。",0
ME24	DB	"をドライブ ",0
ME25	DB	0
ME26	DB	"  リターンキー= 続行  f･3= 終了　f･2= 変更",0
IF PC98		; 作者注：↓PC98固有の文字コード（罫線と思われる）を現在(2025年)の横棒に書き換え.  
ME27	DB	"──────────────────────────                     1993 ─",0
ME28	DB	"─────────────────────── automatic installation program.─",0
ENDIF
IF IBMPC
ME27	DB	"──────────────────────────                     1993 ─",0
ME28	DB	"─────────────────────── automatic installation program.─",0
ENDIF
ME29	DB	"  リターンキー= 続行  f･3= 終了　ESC= もどる",0
ME30	DB	"インストールが完了しました。",0
ME31	DB	"インストールを中断します。",0
ME32	DB	"ディスクエラーのため、インストールを中断します。",0
ME33	DB	0
ME34	DB	"ディスク、またはドライブが破壊されているため",0
ME35	DB	"（ディレクトリィ）",0
ME36	DB	"（ファイル）",0
ME37	DB	"インストールが実行出来ません。",0
ME38	DB	"コピー先のハードディスクがいっぱいになり、",0
ME39	DB	"ハードディスクの空き領域を確保して下さい。",0
ME40	DB	"セーブ出来る領域が足りません。",0
ME41	DB	"Ｈ",0
ME42	DB	"Ｉ",0
ME43	DB	"Ｊ",0
ME44	DB	"Ｋ",0
ME45	DB	"Ｌ",0
ME46	DB	"Ｍ",0


; ****************************************************
;	DATA.
; ****************************************************

CODE	ENDS

	END
;
;	end of "MESSAGE.ASM"
;
