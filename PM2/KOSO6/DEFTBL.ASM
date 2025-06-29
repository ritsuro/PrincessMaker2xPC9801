; "DEFTBL.ASM" 486/50 make by R.H 1992/06/23
;
;
;	初期化パラメータ.
;
;
; public subroutine.

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	DEF_STR_BROOD		; 血液型・文字列
PUBLIC	DEF_STR_SIKYU		; 子宮名・文字列
PUBLIC	DEF_STR_STAR		; 守護星・文字列
PUBLIC	DEF_STR_LEVEL		; レベル・文字列
PUBLIC	DEF_MSG_CANCEL		; cancel message.
PUBLIC	DEF_MSG_EXPAND		; expand message.
PUBLIC	DEF_MSG_EXPFNC		; exp function message.

;	血液型
;	0=A,1=B,2=O,3=AB

		EVEN
DEF_STR_BROOD	DW	SBRD0,SBRD1,SBRD2,SBRD3
SBRD0	DB	"Ａ",0
SBRD1	DB	"Ｂ",0
SBRD2	DB	"Ｏ",0
SBRD3	DB	"ＡＢ",0

;         白羊　金牛　双児　巨蟹　獅子　処女　天秤　天蠍　人馬　磨羯　宝瓶　双魚
;         火星　金星　水星　 月 　太陽　水星　金星　冥王　木星　土星　天王　海王

;	子宮名
		EVEN
DEF_STR_SIKYU	DW	SKYU0,SKYU1,SKYU2,SKYU3,SKYU4,SKYU5
		DW	SKYU6,SKYU7,SKYU8,SKYU9,SKYU10,SKYU11
SKYU0	DB	"白羊宮",0
SKYU1	DB	"金牛宮",0
SKYU2	DB	"双児宮",0
SKYU3	DB	"巨蟹宮",0
SKYU4	DB	"獅子宮",0
SKYU5	DB	"処女宮",0
SKYU6	DB	"天秤宮",0
SKYU7	DB	"天蠍宮",0
SKYU8	DB	"人馬宮",0
SKYU9	DB	"磨羯宮",0
SKYU10	DB	"宝瓶宮",0
SKYU11	DB	"双魚宮",0

;	守護星
		EVEN
DEF_STR_STAR	DW	STAR0,STAR1,STAR2,STAR3,STAR4,STAR5
		DW	STAR6,STAR7,STAR8,STAR9
STAR0	DB	"太陽神ソル",0
STAR1	DB	"月神ザ・ムーン",0
STAR2	DB	"火星神マーズ",0
STAR3	DB	"水星神マーキュリー",0
STAR4	DB	"木星神ジュピター",0
STAR5	DB	"金星神ビーナス",0
STAR6	DB	"土星神サターン",0
STAR7	DB	"天王星神ウラヌス",0
STAR8	DB	"海王星神ネプチューン",0
STAR9	DB	"冥王星神ハーデス",0

;	レベル・文字列
		EVEN
DEF_STR_LEVEL	DW	LVL0,LVL1,LVL2,LVL3
LVL0	DB	"初級",0
LVL1	DB	"中級",0
LVL2	DB	"上級",0
LVL3	DB	"ﾏｽﾀｰ",0

		EVEN
DEF_MSG_CANCEL	DW	MSG_CANCEL	; cancel message.
MSG_CANCEL	DB	"やめる",0,0	; cancel message.

		EVEN
DEF_MSG_EXPAND	DW	MSG_EXP00,MSG_EXP01
MSG_EXP00	DB	"前に戻る",0,0
MSG_EXP01	DB	"ほかの物",0,0

		EVEN
DEF_MSG_EXPFNC	DW	MSG_EXF00,MSG_EXF01
MSG_EXF00	DB	"武器外す",0,0
MSG_EXF01	DB	"防具外す",0,0

DATA	ENDS

	END
;
;	end of "DEFTBL.ASM"
;
