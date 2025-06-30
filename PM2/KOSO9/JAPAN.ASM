; "JAPAN.ASM" 486/50 make by R.H 1993/02/02
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

PUBLIC	KNJ_SPC				; 漢字スペース
PUBLIC	BTN_TOP_TABLE			; ﾎﾞﾀﾝﾃｰﾌﾞﾙ
PUBLIC	KNJ_DAKU			; 濁点
PUBLIC	KNJ_HANDAKU			; 半濁点
PUBLIC	DAKUTEN_TBL			; 濁点ﾃｰﾌﾞﾙ1
PUBLIC	DAKUTEN_TBLX			; 濁点ﾃｰﾌﾞﾙ2
PUBLIC	HANDAKU_TBL			; 半濁点ﾃｰﾌﾞﾙ1
PUBLIC	HANDAKU_TBLX			; 半濁点ﾃｰﾌﾞﾙ1
PUBLIC	FUNC_TOP_TABLE			; ﾌｧﾝｸｼｮﾝﾃｰﾌﾞﾙ
PUBLIC	KINSOKU_TABLE			; 禁則の名前一覧
PUBLIC	SCRN_MSG_TABLE			; ｽｸﾘｰﾝﾒｯｾｰｼﾞﾃｰﾌﾞﾙ
PUBLIC	BLOOD_DSP_STR_TBL		; 血液型の表示文字
PUBLIC	AGE_DSP_STR_TBL			; 数字の表示文字
PUBLIC	FUNC_KETTEI			; 決定

KINSOKU_TABLE	LABEL	BYTE		; 禁則の名前一覧
	INCLUDE	KINSOKU.INC

KNJ_SPC		DB	"　",0,0	; 漢字スペース

BTN_TOP_TABLE	LABEL	BYTE		; botton table.
	DB	"アイウエオ"		; 1-5
	DB	"カキクケコ"		;6-10
	DB	"サシスセソ"		;11-15
	DB	"タチツテト"		;16-20
	DB	"ナニヌネノ"		;21-25
	DB	"ハヒフヘホ"		;26-30
	DB	"マミムメモ"		;31-35
	DB	"ヤャユュヨ"		;36-40
	DB	"ラリルレロ"		;41-45
	DB	"ワンョ゜゛"		;46-50
	DB	"ッ○ー☆！"		;51-55
	DB	"ァィゥェォ"		;56-60

KNJ_DAKU	DB	"゛"		; 濁点
KNJ_HANDAKU	DB	"゜"		; 半濁点

			;1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 < 21 <===
DAKUTEN_TBL	DB	"カキクケコサシスセソタチツテトハヒフヘホウ",0
DAKUTEN_TBLX	DB	"ガギグゲゴザジズゼゾダヂヅデドバビブベボヴ",0

			;1 2 3 4 5 < 5
HANDAKU_TBL	DB	"ハヒフヘホ",0
HANDAKU_TBLX	DB	"パピプペポ",0

FUNC_TOP_TABLE	LABEL	WORD			; ファンクション
		DW	FUNC_TABLE0
		DW	FUNC_TABLE1
FUNC_TABLE0	DB	"おわり",0
FUNC_TABLE1	DB	"もどる",0

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
SCRN_MSG_TBL1	DB	"あなたの名字を教えて下さい（８文字以内）",0
SCRN_MSG_TBL2	DB	"　娘に名前を付けて下さい（８文字以内）",0
SCRN_MSG_TBL3	DB	"　　　　娘の血液型を教えて下さい",0
SCRN_MSG_TBL4	DB	"　　　　　　なまえがほしいの",0
SCRN_MSG_TBL5	DB	"　　　　　　　・・・・・・",0
SCRN_MSG_TBL6	DB	"　　　あなたの年齢を教えて下さい",0
SCRN_MSG_TBL7	DB	"あなたの誕生日はいつですか？",0
SCRN_MSG_TBL8	DB	"娘の誕生日はいつですか？",0

BLOOD_DSP_STR_TBL	LABEL	WORD		; 血液型の表示文字
		DW	STR_TYPE_A		; "Ａ",0,0
		DW	STR_TYPE_B		; "Ｂ",0,0
		DW	STR_TYPE_O		; "Ｏ",0,0
		DW	STR_TYPE_AB		; "ＡＢ",0,0
STR_TYPE_A	DB	"Ａ",0,0
STR_TYPE_B	DB	"Ｂ",0,0
STR_TYPE_O	DB	"Ｏ",0,0
STR_TYPE_AB	DB	"ＡＢ",0,0

AGE_DSP_STR_TBL		LABEL	WORD		; 数字の表示文字
		DW	AGE_DSP_00
		DW	AGE_DSP_01
		DW	AGE_DSP_02
		DW	AGE_DSP_03
		DW	AGE_DSP_04
		DW	AGE_DSP_05
		DW	AGE_DSP_06
		DW	AGE_DSP_07
		DW	AGE_DSP_08
		DW	AGE_DSP_09
AGE_DSP_00	DB	"０",0
AGE_DSP_01	DB	"１",0
AGE_DSP_02	DB	"２",0
AGE_DSP_03	DB	"３",0
AGE_DSP_04	DB	"４",0
AGE_DSP_05	DB	"５",0
AGE_DSP_06	DB	"６",0
AGE_DSP_07	DB	"７",0
AGE_DSP_08	DB	"８",0
AGE_DSP_09	DB	"９",0

;;;FUNC_KETTEI	DB	"決定",0		; 決定
FUNC_KETTEI	DB	"おわり",0

CODE	ENDS
	END
;
;	end of "JAPAN.ASM"
;
