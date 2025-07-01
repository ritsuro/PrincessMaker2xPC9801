; "JAPAN.ASM" 486/50 make by R.H 1993/03/22
;
;
;
;	日本語文字
;	double code(JAPAN)
;
;
; public subroutine.

CODE	SEGMENT	PUBLIC	'CODE'

; ****************************************************
;	data.
; ****************************************************

PUBLIC	SCRN_MSG_TABLE			; スクリーンメッセージテーブル

SCRN_MSG_TABLE	LABEL	WORD			; スクリーンメッセージテーブル
		DW	SCRN_MSG_TBL0		;
		DW	SCRN_MSG_TBL1		;
		DW	SCRN_MSG_TBL2		;
		DW	SCRN_MSG_TBL3		;
		DW	SCRN_MSG_TBL4		;
		DW	SCRN_MSG_TBL5		;
		DW	SCRN_MSG_TBL6		;
		DW	SCRN_MSG_TBL7		;
		DW	SCRN_MSG_TBL8		;
SCRN_MSG_TBL0	DB	0			;
			;.1.2.3.4.5.6.7.8.9.0|1.2.3.4.5.6.7.8.9.0
SCRN_MSG_TBL1	DB	"このディスクではないですよ",0
SCRN_MSG_TBL2	DB	"ドライブ２にユーザーディスクを入れて下さい",0
SCRN_MSG_TBL3	DB	"ドライブ２にユーザーディスクか",0
SCRN_MSG_TBL4	DB	"新しいディスクを入れて下さい",0
SCRN_MSG_TBL5	DB	0
SCRN_MSG_TBL6	DB	0
SCRN_MSG_TBL7	DB	0
SCRN_MSG_TBL8	DB	0

CODE	ENDS
	END
;
;	end of "JAPAN.ASM"
;
