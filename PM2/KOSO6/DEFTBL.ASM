; "DEFTBL.ASM" 486/50 make by R.H 1992/06/23
;
;
;	ϊ»p[^.
;
;
; public subroutine.

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	DEF_STR_BROOD		; t^EΆρ
PUBLIC	DEF_STR_SIKYU		; q{ΌEΆρ
PUBLIC	DEF_STR_STAR		; ημ―EΆρ
PUBLIC	DEF_STR_LEVEL		; xEΆρ
PUBLIC	DEF_MSG_CANCEL		; cancel message.
PUBLIC	DEF_MSG_EXPAND		; expand message.
PUBLIC	DEF_MSG_EXPFNC		; exp function message.

;	t^
;	0=A,1=B,2=O,3=AB

		EVEN
DEF_STR_BROOD	DW	SBRD0,SBRD1,SBRD2,SBRD3
SBRD0	DB	"`",0
SBRD1	DB	"a",0
SBRD2	DB	"n",0
SBRD3	DB	"`a",0

;         r@ΰ@o@I@q@@V@VεΆ@ln@γΉ@σr@o
;         Ξ―@ΰ―@―@  @Ύz@―@ΰ―@»€@Ψ―@y―@V€@C€

;	q{Ό
		EVEN
DEF_STR_SIKYU	DW	SKYU0,SKYU1,SKYU2,SKYU3,SKYU4,SKYU5
		DW	SKYU6,SKYU7,SKYU8,SKYU9,SKYU10,SKYU11
SKYU0	DB	"r{",0
SKYU1	DB	"ΰ{",0
SKYU2	DB	"o{",0
SKYU3	DB	"I{",0
SKYU4	DB	"q{",0
SKYU5	DB	"{",0
SKYU6	DB	"V{",0
SKYU7	DB	"VεΆ{",0
SKYU8	DB	"ln{",0
SKYU9	DB	"γΉ{",0
SKYU10	DB	"σr{",0
SKYU11	DB	"o{",0

;	ημ―
		EVEN
DEF_STR_STAR	DW	STAR0,STAR1,STAR2,STAR3,STAR4,STAR5
		DW	STAR6,STAR7,STAR8,STAR9
STAR0	DB	"Ύz_\",0
STAR1	DB	"_UE[",0
STAR2	DB	"Ξ―_}[Y",0
STAR3	DB	"―_}[L[",0
STAR4	DB	"Ψ―_Ws^[",0
STAR5	DB	"ΰ―_r[iX",0
STAR6	DB	"y―_T^[",0
STAR7	DB	"V€―_EkX",0
STAR8	DB	"C€―_lv`[",0
STAR9	DB	"»€―_n[fX",0

;	xEΆρ
		EVEN
DEF_STR_LEVEL	DW	LVL0,LVL1,LVL2,LVL3
LVL0	DB	"",0
LVL1	DB	"",0
LVL2	DB	"γ",0
LVL3	DB	"Ο½ΐ°",0

		EVEN
DEF_MSG_CANCEL	DW	MSG_CANCEL	; cancel message.
MSG_CANCEL	DB	"βίι",0,0	; cancel message.

		EVEN
DEF_MSG_EXPAND	DW	MSG_EXP00,MSG_EXP01
MSG_EXP00	DB	"OΙίι",0,0
MSG_EXP01	DB	"Ω©Μ¨",0,0

		EVEN
DEF_MSG_EXPFNC	DW	MSG_EXF00,MSG_EXF01
MSG_EXF00	DB	"νO·",0,0
MSG_EXF01	DB	"hοO·",0,0

DATA	ENDS

	END
;
;	end of "DEFTBL.ASM"
;
