; "PARACALC.ASM" 486/50 make by R.H 1992/06/30
;
;
;	パラメータ編集.
;
;
; public subroutine.

INCLUDE	TSTSET.INC

MAXSTOP	MACRO	VVV,UPPER
	MOV	BX,UPPER	; upper.
	MOV	AX,VVV		; value.
	CALL	MAXCUT		; max cutter.
	MOV	VVV,AX		; value.
	ENDM

VALUEUP	MACRO	VDEST,VNOW,VOLD
	MOV	BX,VNOW
	MOV	CX,VOLD
	MOV	DX,VDEST
	CALL	PCALC_SA
	MOV	VNOW,CX
	MOV	VOLD,CX
	MOV	VDEST,DX
	ENDM

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	PCALC_DAYS		; 日次処理
PUBLIC	PCALC_10DAYS		; １旬処理
PUBLIC	PCALC_CHKDAT		; 整合処理
PUBLIC	PCALC_SRTDAT		; 初期状態の整合処理
PUBLIC	PCALC_M_BORN		; 月次成長処理
PUBLIC	PCALC_BORTHDAY		; 誕生日成長処理
PUBLIC	PCALC_GOLDADD		; 所持金へ加算
PUBLIC	PCALC_GOLDSUB		; 所持金から減算
PUBLIC	PCALC_GOLDSUB2		; 所持金から減算2
PUBLIC	PCALC_GOLDCMP		; 所持金と比較
PUBLIC	PCALC_MONTH		; 何ヶ月の計算
PUBLIC	PCALC_CHK_BODY		; 体形のチェック
PUBLIC	PCALC_V_UPER		; 訓練技能値計算
PUBLIC	PCALC_CUTTER		; 基本能力上限カット

; ****************************************************
;	日次処理
;	この処理は"BBCTOOL3.ASM"の CLENDER(3) から呼ばれます
; ****************************************************

PCALC_DAYS	PROC	NEAR
	CALL	CALC_HYOKA		;評価計算
	CALL	PCALC_CUTTER		; 基本能力上限カット
	RET
PCALC_DAYS	ENDP


; ****************************************************
;	１旬処理
; ****************************************************

PCALC_10DAYS	PROC	NEAR
	CALL	PCALC_KOUGEKI		; 攻撃力計算
	RET
PCALC_10DAYS	ENDP


; ****************************************************
;	整合処理
;	この処理は"BBCTOOL3.ASM"の CLENDER(9) から呼ばれます
; ****************************************************

PCALC_CHKDAT	PROC	NEAR
	CALL	CALC_HYOKA		;評価計算
	CALL	PCALC_CUTTER		; 基本能力上限カット
	RET
PCALC_CHKDAT	ENDP


; ****************************************************
;	評価計算
; ****************************************************

CALC_HYOKA	PROC	NEAR
	MOV	AX,V_SENTOH		; 戦闘技術
	ADD	AX,V_KOUGEKI		; 攻撃力
	ADD	AX,V_BOUGYO		; 防御力
	MOV	DX,AX			;
	SUB	AX,H_BK_SENSHI		; 戦闘技術 + 攻撃力 + 防御力
	ADD	H_SENSHI,AX		; 戦士評価
	MOV	H_BK_SENSHI,DX		; 戦闘技術 + 攻撃力 + 防御力

	MOV	AX,V_MAHOGIJUTSU	; 魔法技術
	ADD	AX,V_MARYOKU		; 魔力
	ADD	AX,V_KOHMARYOKU		; 抗魔力
	MOV	DX,AX			;
	SUB	AX,H_BK_MAHO		; 魔法技術 + 魔力 + 抗魔力
	ADD	H_MAHO,AX		; 魔法評価
	MOV	H_BK_MAHO,DX		; 魔法技術 + 魔力 + 抗魔力

	MOV	AX,V_REIGI		; 礼儀作法
	ADD	AX,V_GEIJYUTSU		; 芸術
	ADD	AX,V_WAJYUTU		; 話術
	MOV	DX,AX			;
	SUB	AX,H_BK_SYAKOH		; 礼儀作法 + 芸術 + 話術
	ADD	H_SYAKOH,AX		; 社交評価
	MOV	H_BK_SYAKOH,DX		; 礼儀作法 + 芸術 + 話術

	MOV	AX,V_RYOURI		; 料理
	ADD	AX,V_SOUJISENTAKU	; 掃除洗濯
	ADD	AX,V_KIDATE		; 気だて
	MOV	DX,AX			;
	SUB	AX,H_BK_KAJI		; 料理 + 掃除洗濯 + 気だて
	ADD	H_KAJI,AX		; 家事評価
	MOV	H_BK_KAJI,DX		; 料理 + 掃除洗濯 + 気だて

	MAXSTOP	H_SENSHI,999		; 戦士評価
	MAXSTOP	H_MAHO,999		; 魔法評価
	MAXSTOP	H_SYAKOH,999		; 社交評価
	MAXSTOP	H_KAJI,999		; 家事評価

	RET
CALC_HYOKA	ENDP


; ****************************************************
;	初期状態の整合処理
;	この処理は"BBCTOOL3.ASM"の CLENDER(8) から呼ばれます
; ****************************************************

PCALC_SRTDAT	PROC	NEAR
	CALL	CHK_BREAST		; バストチェック
	CALL	CHK_BODY		; 体形
	CALL	CALC_HYOKA		; 評価計算
	RET
PCALC_SRTDAT	ENDP


; ****************************************************
;	月次成長処理
;	この処理は"BBCTOOL3.ASM"の CLENDER(7) から呼ばれます
;	[DELETE]この処理は"WIDCLEND.ASM"の UPDATE_SET から呼ばれます
;
;	GIRL_BODY	: 体形 1=細,2=太
;	GIRL_FACE	: 表情 1=基本,2=非行,3病気,4元気,5色気
;	GIRL_BREAST	: 胸大 0=無,1=有
;	GIRL_DAMEG	: 重病 0=normal,1=重病
;	FLAG_BYOUKI	: 状態・病気
;	FLAG_HIKOUKA	: 状態・非行化
;	FLAG_RENAI	: 状態・恋愛
;
;	P_BUST		: バスト
;	P_WAIST		: ウエスト
;	P_HIP		: ヒップ
;
;	B_STRESS	: ストレス
;	B_MORALS	: モラル
;	B_STRESS	: ストレス
;	B_KANJUSEI	: 感受性
;
;	URA_PRINCE	: 王子との関係
;	URA_FATHER	: 父との関係
;	URA_STEWARD	: 執事との関係
;
; ****************************************************

PCALC_M_BORN	PROC	NEAR
	;子供の身長、体重の自然増加について・・・
	;毎月，一ヶ月の最初に少しづつ，身長と体重が増減する．
	;初期値は身長148.00，体重33.20
	;通常は10～15歳までは一ヶ月あたり身長が0.14～16，
	;体重が0.19～22づつ増加．
	;16歳以上からは一ヶ月あたり身長が0.03～0.07，
	;体重が0.05～0.08づつ増加．
	;最終月の平均身長160cm　体重48.92kg
	;★メインコマンド「健康管理」による影響
	;体重の増減は，「健康管理」のコマンド選択の影響を受ける．
	;（身長は影響を受けない）

	CALL	CHK_BREAST		; バストチェック

	CALL	PCALC_BORN_TALL		; 身長

	CALL	PCALC_BORN_TAIJU	; 体重

	CALL	PCALC_BORN_BUST		; バスト

	CALL	PCALC_BORN_WAIST	; ウエスト

	CALL	PCALC_BORN_HIP		; ヒップ

	CALL	PCALC_BORN_BLOOD	; 血液型処理

	CALL	PCALC_BORN_SHISU	; 指数処理

	RET
PCALC_M_BORN	ENDP


; ****************************************************
;	誕生日成長処理
; ****************************************************

PCALC_BORTHDAY	PROC	NEAR
	MOV	AX,E_ETC[40*2]		;色気パラメータの自然増加量
	ADD	B_IROKE,AX		;色気

	;色気パラメータの自然増加について
	;基本能力パラメータのうち，色気値のみは自然に増加します．
	;この増加は月ごとではなく，娘の誕生日ごとに行われます．
	;その増加量は，色気の初期値と同じです．

	RET
PCALC_BORTHDAY	ENDP


; ****************************************************
;	身長
; ****************************************************

PCALC_BORN_TALL	PROC	NEAR
	CMP	P_NENREI,16		; 年齢
	JNB	PCALC_BORN_TALL_16AGE	;

	;通常は10～15歳までは一ヶ月あたり身長が0.14～16

	MOV	AX,3			;範囲（２００以内）
	CALLE	RANDAM			;乱数範囲指定
	ADD	AX,13			;+13
	ADD	P_SHINCHO,AX		;身長

	JMP	PCALC_BORN_TALL_3	;
PCALC_BORN_TALL_16AGE:			;

	;16歳以上からは一ヶ月あたり身長が0.03～0.07

	MOV	AX,5			;範囲（２００以内）
	CALLE	RANDAM			;乱数範囲指定
	ADD	AX,2			;+2
	ADD	P_SHINCHO,AX		;身長

PCALC_BORN_TALL_3:
	RET
PCALC_BORN_TALL	ENDP


; ****************************************************
;	体重
; ****************************************************

PCALC_BORN_TAIJU	PROC	NEAR
	CMP	FLAG_KENKO,0		;健康管理 0=「無理はさせない」
	JE	PCALC_BORN_MURINAI	;
	CMP	FLAG_KENKO,1		;健康管理 1=「とにかく丈夫な子に」
	JE	PCALC_BORN_JOUBU	;
	CMP	FLAG_KENKO,2		;健康管理 2=「おしとやかな子に」
	JE	PCALC_BORN_OSHITOYAKA	;
	CMP	FLAG_KENKO,3		;健康管理 3=「ダイエットさせる」
	JE	PCALC_BORN_DIET		;

	JMP	PCALC_BORN_BWH		;

PCALC_BORN_MURINAI:			;「無理はさせない」
	;通常通りの増減の仕方．（平均48.92）

;*;	MOV	AX,30			;食費30G
;*;	CALL	PCALC_GOLDSUB		;所持金から減算

	CMP	P_NENREI,16		; 年齢
	JNB	PCALC_BORN_MURINAI_16AGE
	MOV	AX,4			;体重が0.19～22づつ増加．
	CALLE	RANDAM			;乱数範囲指定
	ADD	AX,18			;
	ADD	P_TAIJYU,AX		;体重
	JMP	PCALC_BORN_BWH		;
PCALC_BORN_MURINAI_16AGE:		;
	MOV	AX,4			;体重が0.05～0.08づつ増加．
	CALLE	RANDAM			;乱数範囲指定
	ADD	AX,4			;
	ADD	P_TAIJYU,AX		;体重
	JMP	PCALC_BORN_BWH		;

PCALC_BORN_JOUBU:			;「とにかく丈夫な子に」
	;一ヶ月ごとの体重増加が0.28～0.35
	;0.15～0.20になる．（平均60.08）

;*;	MOV	AX,80			;食費80G
;*;	CALL	PCALC_GOLDSUB		;所持金から減算

	ADD	B_TAIRYOKU,10		;体力+10

	CMP	P_NENREI,16		; 年齢
	JNB	PCALC_BORN_JOUBU_16AGE	;
	MOV	AX,8			;一ヶ月ごとの体重増加が0.28～0.35
	CALLE	RANDAM			;乱数範囲指定
	ADD	AX,27			;
	ADD	P_TAIJYU,AX		;体重
	JMP	PCALC_BORN_BWH		;
PCALC_BORN_JOUBU_16AGE:			;
	MOV	AX,6			;体重が0.15～0.20になる
	CALLE	RANDAM			;乱数範囲指定
	ADD	AX,14			;
	ADD	P_TAIJYU,AX		;体重
	JMP	PCALC_BORN_BWH		;

PCALC_BORN_OSHITOYAKA:			;「おしとやかな子に」
	;一ヶ月ごとの体重増加が0.10～0.15
	;　　　　　　　　　　　0.01～0.05になる．（平均42.92）

;*;	MOV	AX,10			;食費10G
;*;	CALL	PCALC_GOLDSUB		;所持金から減算

	SUB	B_TAIRYOKU,5		;体力-5
	JNB	PCALC_BORN_OSHITOYAKA2	;
	MOV	B_TAIRYOKU,0		;体力
PCALC_BORN_OSHITOYAKA2:

	CMP	P_NENREI,16		; 年齢
	JNB	PCALC_BORN_OSHITOYAKA_16AGE
	MOV	AX,6			;一ヶ月ごとの体重増加が0.10～0.15
	CALLE	RANDAM			;乱数範囲指定
	ADD	AX,9			;
	ADD	P_TAIJYU,AX		;体重
	JMP	PCALC_BORN_BWH		;
PCALC_BORN_OSHITOYAKA_16AGE:		;
	MOV	AX,5			;体重が0.01～0.05になる
	CALLE	RANDAM			;乱数範囲指定
	ADD	P_TAIJYU,AX		;体重
	JMP	PCALC_BORN_BWH		;

PCALC_BORN_DIET:			;「ダイエットさせる」
	;一ヶ月ごとに体重増加が-0.00～-0.6
	;　　　　　　　　　　　-0.50～-1.0になる．
	;体重が《（身長×0.9）-105》未満では、実行できない．

;*;	MOV	AX,5			;食費5G
;*;	CALL	PCALC_GOLDSUB		;所持金から減算

	SUB	B_TAIRYOKU,20		;体力-20
	JNB	PCALC_BORN_DIET2	;
	MOV	B_TAIRYOKU,0		;体力
PCALC_BORN_DIET2:

	CMP	P_NENREI,16		; 年齢
	JNB	PCALC_BORN_DIET_16AGE	;
	MOV	AX,61			;一ヶ月ごとに体重増加が-0.00～-0.6
	CALLE	RANDAM			;乱数範囲指定
	DEC	AX			; -1
	SUB	P_TAIJYU,AX		;体重
	JMP	PCALC_BORN_BWH		;
PCALC_BORN_DIET_16AGE:			;
	MOV	AX,51			;体重が-0.50～-1.0になる．
	CALLE	RANDAM			;乱数範囲指定
	ADD	AX,49			;
	SUB	P_TAIJYU,AX		;体重
	JMP	PCALC_BORN_BWH		;
PCALC_BORN_BWH:

	;体重制限
	;体重の増減に以下の制限を加えます．
	;体重は25.00～80.00の範囲内まで．

	CMP	P_TAIJYU,2500		;体重
	JGE	PCALC_BORN_TAIJU_6	;
	MOV	P_TAIJYU,2500		;体重
PCALC_BORN_TAIJU_6:
	CMP	P_TAIJYU,8000		;体重
	JLE	PCALC_BORN_TAIJU_7	;
	MOV	P_TAIJYU,8000		;体重
PCALC_BORN_TAIJU_7:

	RET
PCALC_BORN_TAIJU	ENDP


; ****************************************************
;	バスト
; ****************************************************

PCALC_BORN_BUST	PROC	NEAR
	CMP	URA_BREAST_TYPE,1	;バストの大中小分類 1=小,2=中,3=大
	JE	PCALC_BORN_BUST_SMALL	;小→0.04～0.20〃平均0.12(81.52cm)
	CMP	URA_BREAST_TYPE,2	;バストの大中小分類 1=小,2=中,3=大
	JE	PCALC_BORN_BUST_MID	;中→0.10～0.20〃平均0.15(84.40cm)
	CMP	URA_BREAST_TYPE,3	;バストの大中小分類 1=小,2=中,3=大
	JE	PCALC_BORN_BUST_BIG	;大→0.12～0.40乱数平均0.26(94.96cm)
PCALC_BORN_BUST_BIG:			;大→0.12～0.40乱数平均0.26(94.96cm)
	MOV	AX,29			;範囲（２００以内）
	CALLE	RANDAM			;乱数範囲指定
	ADD	AX,11			;+11
	JMP	PCALC_BORN_BUST_CALC	;
PCALC_BORN_BUST_MID:			;中→0.10～0.20〃平均0.15(84.40cm)
	MOV	AX,11			;範囲（２００以内）
	CALLE	RANDAM			;乱数範囲指定
	ADD	AX,9			;+9
	JMP	PCALC_BORN_BUST_CALC	;
PCALC_BORN_BUST_SMALL:			;小→0.04～0.20〃平均0.12(81.52cm)
	MOV	AX,17			;範囲（２００以内）
	CALLE	RANDAM			;乱数範囲指定
	ADD	AX,3			;+3
	JMP	PCALC_BORN_BUST_CALC	;
PCALC_BORN_BUST_CALC:			;
	ADD	P_BUST,AX		;バスト
	RET
PCALC_BORN_BUST	ENDP


; ****************************************************
;	ウエスト
; ****************************************************

PCALC_BORN_WAIST	PROC	NEAR
					;身長，体重により常に変動する．
					;初期値51.30
					;ウエスト値＝《（（身長×0.3）＋25＋体重）÷2》
	MOV	AX,P_SHINCHO		;身長
	MOV	BX,3			;
	MUL	BX			; * 3
	ADD	AX,25000		;2500 * 10
	ADC	DX,0			;
	PUSH	AX			;
	PUSH	DX			;

	MOV	BX,10			;
	MOV	AX,P_TAIJYU		;体重 * 10
	MUL	BX			;

	POP	CX			;
	POP	BX			;
	ADD	AX,BX			;
	ADC	DX,CX			;

	MOV	BX,20			;
	DIV	BX			; / 20

	MOV	P_WAIST,AX		;ウエスト

	RET
PCALC_BORN_WAIST	ENDP


; *********************************************************
;	ヒップ
; *********************************************************

PCALC_BORN_HIP	PROC	NEAR
	CMP	URA_HIP_TYPE,1		;ヒップの大中小分類 1=小,2=中,3=大
	JE	PCALC_BORN_HIP_SMALL	;
	CMP	URA_HIP_TYPE,2		;ヒップの大中小分類 1=小,2=中,3=大
	JE	PCALC_BORN_HIP_MID	;
	CMP	URA_HIP_TYPE,3		;ヒップの大中小分類 1=小,2=中,3=大
	JE	PCALC_BORN_HIP_BIG	;

;	一ヶ月あたり下記の数値分増加する．ヒップ値は減ることはない．

PCALC_BORN_HIP_BIG:			;大→0.20～0.28の乱数 平均0.24(95.04cm)
	MOV	AX,9			;範囲（２００以内）
	CALLE	RANDAM			;乱数範囲指定
	ADD	AX,19			;+19
	JMP	PCALC_BORN_HIP_CALC	;
PCALC_BORN_HIP_MID:			;中→0.09～0.17〃 平均0.13(84.48cm)
	MOV	AX,9			;範囲（２００以内）
	CALLE	RANDAM			;乱数範囲指定
	ADD	AX,8			;+8
	JMP	PCALC_BORN_HIP_CALC	;
PCALC_BORN_HIP_SMALL:			;小→0.06～0.12〃 平均0.09(80.64cm)
	MOV	AX,7			;範囲（２００以内）
	CALLE	RANDAM			;乱数範囲指定
	ADD	AX,5			;+5
	JMP	PCALC_BORN_HIP_CALC	;
PCALC_BORN_HIP_CALC:			;
	ADD	P_HIP,AX		; ヒップ
	RET
PCALC_BORN_HIP	ENDP


; *********************************************************
;	血液型
; *********************************************************

PCALC_BORN_BLOOD	PROC	NEAR
	CMP	P_BLOOD,0		;0=Ａ
	JE	PCALC_BORN_BLOOD_A	;
	CMP	P_BLOOD,1		;1=Ｂ
	JE	PCALC_BORN_BLOOD_B	;
	CMP	P_BLOOD,2		;2=Ｏ
	JE	PCALC_BORN_BLOOD_O	;
	JMP	PCALC_BORN_BLOOD_AB	;3=ＡＢ

PCALC_BORN_BLOOD_A:
	;Ａ型　→モラルが３上がる．ストレスが２上がる．
	ADD	B_MORALS,3		;モラル
	ADD	B_STRESS,2		;ストレス
	JMP	PCALC_BORN_BLOOD_EXIT
PCALC_BORN_BLOOD_B:
	;Ｂ型　→ストレスが２下がる．
	SUB	B_STRESS,2		;ストレス
	CMP	B_STRESS,0		;ストレス
	JGE	PCALC_BORN_BLOOD_EXIT
	MOV	B_STRESS,0		;ストレス
	JMP	PCALC_BORN_BLOOD_EXIT
PCALC_BORN_BLOOD_O:
	;Ｏ型　→変化なし．
	JMP	PCALC_BORN_BLOOD_EXIT
PCALC_BORN_BLOOD_AB:
	;ＡＢ型→感受性が２上昇．
	ADD	B_KANJUSEI,2		; 感受性
PCALC_BORN_BLOOD_EXIT:
	RET
PCALC_BORN_BLOOD	ENDP


; *********************************************************
;	指数処理
; *********************************************************

PCALC_BORN_SHISU	PROC	NEAR
	MOV	FLAG_BYOUKI,0			; 状態・病気
	MOV	FLAG_HIKOUKA,0			; 状態・非行化

	MOV	GIRL_DAMEG,0			; 重病 0=normal,1=重病
	MOV	GIRL_FACE,1			; 表情 1=基本

	;病気指数(%)	《ストレス－体力》
	;		〈例〉体力２００，ストレス２４０なら病気指数４０％．
	;		数値は０～１００（100以上は100，0未満は0）．

	MOV	AX,B_STRESS		; ストレス
	SUB	AX,B_TAIRYOKU		; 体力
	CALL	CHK0T100N		; 0 - 100 check.
	MOV	S_BYOUKI,AX		; 病気指数(%)

	;非行化指数(%)	《ストレス－モラルと信仰の高い方》
	;		数値は０～１００（100以上は100，0未満は0）．

	MOV	AX,B_MORALS		; モラル
	MOV	BX,B_SHINKOH		; 信仰
	CALL	CHKMAX			; max.
	MOV	DX,B_STRESS		; ストレス
	SUB	DX,AX			;
	MOV	AX,DX			;
	CALL	CHK0T100N		; 0 - 100 check.
	MOV	S_HIKOUKA,AX		; 非行化指数(%)

	;娘の状態の種類
	;「病気」と「非行化」は同時には発生しません．
	;「恋愛」は「病気」や「非行化」と同時に発生することがあります．
	;それ以外は「平常」状態です．

	;病気指数・・・・状態・・・
	;０～９		平常
	;１０～２９	風邪気味
	;３０～５９	軽い肺炎
	;６０～８９	悪性肺炎
	;９０～９９	重態
	;１００		死亡

	CMP	S_BYOUKI,10		; 病気指数(%)
	JL	PCALC_BORN_SHISU_2	;
	MOV	FLAG_BYOUKI,1		; 状態・病気
PCALC_BORN_SHISU_2:

	CMP	S_BYOUKI,90		; 病気指数(%)
	JL	PCALC_BORN_SHISU_3	;
	MOV	GIRL_DAMEG,1		; 重病 0=normal,1=重病
PCALC_BORN_SHISU_3:

	CMP	GIRL_DAMEG,1		; 重病 0=normal,1=重病
	JE	PCALC_BORN_SHISU_SKIP_HK

	;非行化は「やや反抗的」「反抗的」「非行化」「愚連隊の仲間」
	;の４段階があります．
	;非行化時は，メインコマンド「娘と話す」の「お説教」を行うと，
	;ストレスを下げることができます（父との関係値分だけ下がる）．

	;非行化指数・・・状態・・・
	;０～９		平常
	;１０～２９	やや反抗的
	;３０～５９	反抗的
	;６０～８９	非行化
	;９０～９９	愚連隊の仲間
	;１００		逮捕

	CMP	S_HIKOUKA,10		; 非行化指数(%)
	JL	PCALC_BORN_SHISU_4	;
	MOV	FLAG_HIKOUKA,1		; 状態・非行化
PCALC_BORN_SHISU_4:

;*;	CMP	FLAG_HIKOUKA,0		; 状態・非行化
;*;	JE	PCALC_BORN_SHISU_45	;
;*;	CMP	FLAG_BYOUKI,0		; 状態・病気
;*;	JE	PCALC_BORN_SHISU_45	;
;*;
;*;	CMPX	S_HIKOUKA,S_BYOUKI	; 非行化指数(%):病気指数(%)
;*;	JB	PCALC_BORN_SHISU_42	;
;*;	MOV	FLAG_BYOUKI,0		; 状態・病気
;*;	JMP	PCALC_BORN_SHISU_45	;
;*;PCALC_BORN_SHISU_42:			;
;*;	MOV	FLAG_HIKOUKA,0		; 状態・非行化
;*;PCALC_BORN_SHISU_45:			;

PCALC_BORN_SHISU_SKIP_HK:

	CMP	FLAG_BYOUKI,0		; 状態・病気
	JE	PCALC_BORN_SHISU_FC12	;

	CMP	FLAG_HIKOUKA,0		; 状態・非行化
	JE	PCALC_BORN_SHISU_FC11	;

	CMPX	S_HIKOUKA,S_BYOUKI	; 非行化指数(%):病気指数(%)
	JNB	PCALC_BORN_SHISU_FC12	;

PCALC_BORN_SHISU_FC11:
	MOV	GIRL_FACE,3		; 表情 3=病気
	JMP	PCALC_BORN_SHISU_FC9	;

PCALC_BORN_SHISU_FC12:
	CMP	FLAG_HIKOUKA,0		; 状態・非行化
	JE	PCALC_BORN_SHISU_FC2	;
	MOV	GIRL_FACE,2		; 表情 2=非行
	JMP	PCALC_BORN_SHISU_FC9	;
PCALC_BORN_SHISU_FC2:

	CALL	CHK_IROKE		;色気チェック
	CMP	AX,1			;1=色気顔,0=通常.
	JNE	PCALC_BORN_SHISU_FC3	;
	MOV	GIRL_FACE,5		; 表情 5=色気
	JMP	PCALC_BORN_SHISU_FC9	;
PCALC_BORN_SHISU_FC3:

	CMP	B_STRESS,0		; ストレス
	JNE	PCALC_BORN_SHISU_FC4	;
	MOV	GIRL_FACE,4		; 表情 4=元気
	JMP	PCALC_BORN_SHISU_FC9	;
PCALC_BORN_SHISU_FC4:

PCALC_BORN_SHISU_FC9:

	CALL	CHK_RENAI		; 恋愛チェック
	CMP	AX,0			; 1=恋愛状態から抜けます,0=通常.
	JE	PCALC_BORN_SHISU_6	;
	MOV	FLAG_RENAI,0		; 状態・恋愛
PCALC_BORN_SHISU_6:

	;恋愛状態時は，毎月の最初に「父との関係」「執事との関係」
	;「王子との関係」が２づつ下がります．

	CMP	FLAG_RENAI,0		; 状態・恋愛
	JE	PCALC_BORN_SHISU_777	;

	SUB	URA_PRINCE,2		; 王子との関係
	JNB	PCALC_BORN_SHISU_71	;
	MOV	URA_PRINCE,0		;
PCALC_BORN_SHISU_71:
	SUB	URA_FATHER,2		; 父との関係
	JNB	PCALC_BORN_SHISU_72	;
	MOV	URA_FATHER,0		;
PCALC_BORN_SHISU_72:
	SUB	URA_STEWARD,2		; 執事との関係
	JNB	PCALC_BORN_SHISU_73	;
	MOV	URA_STEWARD,0		; 執事との関係
PCALC_BORN_SHISU_73:

PCALC_BORN_SHISU_777:

	CALL	CHK_BODY		; 体形

	;恋愛・・・・・・イベントによって恋愛状態になることがあります．
	;恋愛状態になると，２０％の確率でアルバイトや各種訓練でミスをします．
	;この判定は，通常のミス判定より優先されます．

	CMP	GIRL_BODY,2		; 体形 1=細,2=太
	JNE	PCALC_BORN_SHISU_8	;
	SUB	B_IROKE,2		; 色気
	JNB	PCALC_BORN_SHISU_8
	MOV	B_IROKE,0		; 色気
PCALC_BORN_SHISU_8:

	RET
PCALC_BORN_SHISU	ENDP


; *********************************************************
;	攻撃力計算
; *********************************************************

PCALC_KOUGEKI	PROC	NEAR
	SUBX	T_KOUGEKI,V_KOGK_KIN	; 攻撃力－攻撃筋力

	CMP	T_KOUGEKI,0		;
	JGE	PCALC_KOUGEKI_2		;
	MOV	T_KOUGEKI,0		; 攻撃力－攻撃筋力
PCALC_KOUGEKI_2:

	MOV	DX,0			;
	MOV	AX,B_KINRYOKU		; 筋力
	MOV	CX,10			; / 10
	DIV	CX			;
	MOV	V_KOGK_KIN,AX		; 攻撃筋力

	ADDX	T_KOUGEKI,V_KOGK_KIN	; 攻撃力＋攻撃筋力

	CALL	PCALC_V_UPER		; 訓練技能値計算
	RET
PCALC_KOUGEKI	ENDP


; *********************************************************
;	体形
; *********************************************************

CHK_BODY	PROC	NEAR
	;（身長×０．９５）－１０５＋（１８－年齢）＝標準体重
	;標準体重以上なら太グラフィック
	;標準体重未満なら細グラフィック

	MOV	AX,P_SHINCHO		; 身長
	MOV	BX,95			;
	CALL	P1X100			; 百分率
	SUB	AX,10500		;

	MOV	CX,AX			;
	MOV	AX,18			;
	SUB	AX,P_NENREI		; 18-年齢
	MOV	BX,100			;
	IMUL	BX			; *100
	ADD	AX,CX			;

	MOV	GIRL_BODY,1		; 体形 1=細,2=太

	CMP	P_TAIJYU,AX		; 体重
	JL	CHK_BODY_5		;
	MOV	GIRL_BODY,2		; 体形 1=細,2=太
CHK_BODY_5:

	RET
CHK_BODY	ENDP


; *********************************************************
;	バストチェック
; *********************************************************

CHK_BREAST	PROC	NEAR
	MOV	GIRL_BREAST,0		; 胸大 0=無,1=有
	CMP	URA_BREAST_TYPE,2	; バストの大中小分類 1=小,2=中,3=大
	JLE	CHK_BREAST_8		;
	MOV	GIRL_BREAST,1		; 胸大 0=無,1=有
CHK_BREAST_8:
	RET
CHK_BREAST	ENDP


; *********************************************************
;	恋愛チェック
;	恋愛状態は，最低３ヶ月間は続きます．
;	その後は『父との関係が６０以上』または『基本能力中，
;	色気の高さが２番目以下になる』のどちらか
;	満たされれば，恋愛状態から抜けます．
;	-O- AX : 1=恋愛状態から抜けます,0=通常.
; *********************************************************

CHK_RENAI	PROC	NEAR

	CMP	FLAG_RENAI,0		; 状態・恋愛
	JE	CHK_RENAI_NORMAL	;

	MOV	BX,E_ETC[76*2]		;恋愛開始年
	MOV	CX,E_ETC[77*2]		;恋愛開始月
	MOV	SI,VAL_YEAR		;年
	MOV	DI,VAL_MONTH		;月
	CALL	PCALC_MONTH		;何ヶ月の計算
	CMP	AX,3			;３ヶ月
	JB	CHK_RENAI_NORMAL	;

	CALL	CHK_MAXPARA		;基本パラメータ中での最大値
	CMP	AX,5			;5=色気
	JNE	CHK_RENAI_NUKE		;

	CMP	URA_FATHER,60		;父との関係
	JGE	CHK_RENAI_NUKE		;

CHK_RENAI_NORMAL:
	MOV	AX,0			; 0=通常
	RET
CHK_RENAI_NUKE:
	MOV	AX,1			; 1=恋愛状態から抜けます
	RET
CHK_RENAI	ENDP


; *********************************************************
;	色気チェック
;	顔色気は基本パラメータ中色気値が最も高く，かつ１００以上で，
;	病気指数，非行化指数が３０未満の場合使用します．
;	-O- AX : 1=色気顔,0=通常.
; *********************************************************

CHK_IROKE	PROC	NEAR
	CALL	CHK_MAXPARA		; 基本パラメータ中での最大値
	CMP	AX,5			; 5=色気
	JNE	CHK_IROKE_NORMAL	;
	CMP	BX,100			; 最大値
	JL	CHK_IROKE_NORMAL	;

	CMP	S_BYOUKI,30		; 病気指数(%)
	JGE	CHK_IROKE_NORMAL	;
	CMP	S_HIKOUKA,30		; 非行化指数(%)
	JGE	CHK_IROKE_NORMAL	;

CHK_IROKE_IROKE:
	MOV	AX,1			; 1=色気顔
	RET
CHK_IROKE_NORMAL:
	MOV	AX,0			; 0=通常
	RET
CHK_IROKE	ENDP


; *********************************************************
;	基本パラメータ中での最大値
;	-O- AX : 1=体力,2=筋力,3=知能,4=気品,5=色気
;		6=モラル,7=信仰,8=因業,9=感受性
;	    BX : 最大値
; *********************************************************

CHK_MAXPARA	PROC	NEAR
	MOV	AL,1
	MOV	BX,B_TAIRYOKU			; 体力

	CMP	BX,B_KINRYOKU			; 筋力
	JL	CHK_MAXPARA_1			;
	MOV	AL,2				;
	MOV	BX,B_KINRYOKU			; 筋力
CHK_MAXPARA_1:					;

	CMP	BX,B_CHINOH			; 知能
	JL	CHK_MAXPARA_2			;
	MOV	AL,3				;
	MOV	BX,B_CHINOH			; 知能
CHK_MAXPARA_2:

	CMP	BX,B_KIHIN			; 気品
	JL	CHK_MAXPARA_3			;
	MOV	AL,4				;
	MOV	BX,B_KIHIN			; 気品
CHK_MAXPARA_3:

	CMP	BX,B_IROKE			; 色気
	JL	CHK_MAXPARA_4			;
	MOV	AL,5				;
	MOV	BX,B_IROKE			; 色気
CHK_MAXPARA_4:

	CMP	BX,B_MORALS			; モラル
	JL	CHK_MAXPARA_5			;
	MOV	AL,6				;
	MOV	BX,B_MORALS			; モラル
CHK_MAXPARA_5:

	CMP	BX,B_SHINKOH			; 信仰
	JL	CHK_MAXPARA_6			;
	MOV	AL,7				;
	MOV	BX,B_SHINKOH			; 信仰
CHK_MAXPARA_6:

	CMP	BX,B_INGYO			; 因業
	JL	CHK_MAXPARA_7			;
	MOV	AL,8				;
	MOV	BX,B_INGYO			; 因業
CHK_MAXPARA_7:

	CMP	BX,B_KANJUSEI			; 感受性
	JL	CHK_MAXPARA_8			;
	MOV	AL,9				;
	MOV	BX,B_KANJUSEI			; 感受性
CHK_MAXPARA_8:
	RET
CHK_MAXPARA	ENDP


; *********************************************************
;	0 - 100 check.
;	-I/O- AX : value.
; *********************************************************

CHK0T100N	PROC	NEAR
	CMP	AX,0
	JGE	CHK0T100N_1
	MOV	AX,0
CHK0T100N_1:
	CMP	AX,100
	JLE	CHK0T100N_2
	MOV	AX,100
CHK0T100N_2:
	RET
CHK0T100N	ENDP


; *********************************************************
;	max.
;	-I- AX : value 1.
;	    BX : value 2.
;	-O- AX : max value.
; *********************************************************

CHKMAX	PROC	NEAR
	CMP	AX,BX			; value 1  value 2.
	JGE	CHKMAX_2		;
	MOV	AX,BX			; max value.
CHKMAX_2:
	RET
CHKMAX	ENDP


; *********************************************************
;	所持金へ加算
;	-I- AX : add value.
; *********************************************************

PCALC_GOLDADD	PROC	NEAR
	ADD	GOLD_GIRL,AX		; 娘の所持金
	ADC	GOLD_GIRL[2],0		; 娘の所持金

	MOV	AX,GOLD_GIRL[2]		; 娘の所持金
	CMP	AX,GOLD_UPPER[2]	; 所持金上限
	JL	PCALC_GOLDADD_6		;
	JNE	PCALC_GOLDADD_5		;

	MOV	AX,GOLD_GIRL		; 娘の所持金
	CMP	AX,GOLD_UPPER		; 所持金上限
	JBE	PCALC_GOLDADD_6		;

PCALC_GOLDADD_5:
	MOVX	GOLD_GIRL,GOLD_UPPER		; 所持金上限
	MOVX	GOLD_GIRL[2],GOLD_UPPER[2]	; 所持金上限
PCALC_GOLDADD_6:
	RET
PCALC_GOLDADD	ENDP


; *********************************************************
;	所持金から減算
;	-I- AX : sub value.
; *********************************************************

PCALC_GOLDSUB	PROC	NEAR
	SUB	GOLD_GIRL,AX		; 娘の所持金
	SBB	GOLD_GIRL[2],0		; 娘の所持金

	CMP	GOLD_GIRL[2],0		; 娘の所持金
	JGE	PCALC_GOLDSUB_9		;
	MOV	GOLD_GIRL,0		; 娘の所持金
	MOV	GOLD_GIRL[2],0		; 娘の所持金
PCALC_GOLDSUB_9:
	RET
PCALC_GOLDSUB	ENDP


; *********************************************************
;	所持金から減算2
;	-I- AX : sub value.
; *********************************************************

PCALC_GOLDSUB2	PROC	NEAR
	SUB	GOLD_GIRL,AX		; 娘の所持金
	SBB	GOLD_GIRL[2],0		; 娘の所持金
	RET
PCALC_GOLDSUB2	ENDP


; *********************************************************
;	所持金と比較
;	-I- AX  : cmp value.
;	-O- AX  : 1=same,2=upper,3=under.
; *********************************************************

PCALC_GOLDCMP	PROC	NEAR
	CMP	GOLD_GIRL[2],0		; 娘の所持金
	JL	PCALC_GOLDCMP_UPPER	;
	JG	PCALC_GOLDCMP_UNDER	;

	CMP	AX,GOLD_GIRL		; 娘の所持金
	JB	PCALC_GOLDCMP_UNDER	;
	JNBE	PCALC_GOLDCMP_UPPER	;

PCALC_GOLDCMP_SAME:
	MOV	AX,1			; 1=same.
	RET
PCALC_GOLDCMP_UPPER:
	MOV	AX,2			; 2=upper.
	RET
PCALC_GOLDCMP_UNDER:
	MOV	AX,3			; 3=under.
	RET
PCALC_GOLDCMP	ENDP


; *********************************************************
;	何ヶ月の計算
;	-I- BX : 年１
;	    CX : 月１
;	    SI : 年２
;	    DI : 月２
;	-O- AX : 何ヶ月か
; *********************************************************

PCALC_MONTH	PROC	NEAR
;*;	PRV "BX=",BX
;*;	PRV "CX=",CX
;*;	PRV "SI=",SI
;*;	PRV "DI=",DI

	MOV	AX,BX		;年１
	MOV	BX,12		;
	MUL	BX		;
	ADD	AX,CX		;月１
	DEC	AX		;

;*;PRV "...days1=",AX

	PUSH	AX

	MOV	AX,SI		;年２
	MOV	BX,12		;
	MUL	BX		;
	ADD	AX,DI		;月２
	DEC	AX		;

;*;PRV "...days2=",AX

	POP	DX

	SUB	AX,DX
	RET
PCALC_MONTH	ENDP


; *********************************************************
;	体形のチェック
; *********************************************************

PCALC_CHK_BODY	PROC	NEAR
	CALL	CHK_BREAST		; バストチェック
	CALL	CHK_BODY		; 体形
	RET
PCALC_CHK_BODY	ENDP


; *********************************************************
;	訓練技能値計算
; *********************************************************

PCALC_V_UPER	PROC	NEAR

VALUEUP	V_SENTOH,	T_SENTOH,	T_BK_SENTOH	; 戦闘技術
VALUEUP	V_KOUGEKI,	T_KOUGEKI,	T_BK_KOUGEKI	; bk trg攻撃力
VALUEUP	V_BOUGYO,	T_BOUGYO,	T_BK_BOUGYO	; bk trg防御力
VALUEUP	V_MAHOGIJUTSU,	T_MAHOGIJUTSU,	T_BK_MAHOGIJUTSU ; bk trg魔法技術
VALUEUP	V_MARYOKU,	T_MARYOKU,	T_BK_MARYOKU	; bk trg魔力
VALUEUP	V_KOHMARYOKU,	T_KOHMARYOKU,	T_BK_KOHMARYOKU	; bk trg抗魔力
VALUEUP	V_REIGI,	T_REIGI,	T_BK_REIGI	; bk trg礼儀作法
VALUEUP	V_GEIJYUTSU,	T_GEIJYUTSU,	T_BK_GEIJYUTSU	; bk trg芸術
VALUEUP	V_WAJYUTU,	T_WAJYUTU,	T_BK_WAJYUTU	; bk trg話術
VALUEUP	V_RYOURI,	T_RYOURI,	T_BK_RYOURI	; bk trg料理
VALUEUP	V_SOUJISENTAKU,	T_SOUJISENTAKU,	T_BK_SOUJISENTAKU ; bk trg掃除洗濯
VALUEUP	V_KIDATE,	T_KIDATE,	T_BK_KIDATE	; bk trg気だて

	RET
PCALC_V_UPER	ENDP


; *********************************************************
;	基本能力上限カット
; *********************************************************

PCALC_CUTTER	PROC	NEAR
	MAXSTOP		B_TAIRYOKU,999		; 体力
	MAXSTOP		B_KINRYOKU,999		; 筋力
	MAXSTOP		B_CHINOH,999		; 知能
	MAXSTOP		B_KIHIN,999		; 気品
	MAXSTOP		B_IROKE,999		; 色気
	MAXSTOP		B_MORALS,999		; モラル
	MAXSTOP		B_SHINKOH,999		; 信仰
	MAXSTOP		B_INGYO,999		; 因業
	MAXSTOP		B_KANJUSEI,999		; 感受性
	MAXSTOP		B_STRESS,999		; ストレス
	RET
PCALC_CUTTER	ENDP


; *********************************************************
;	max cutter.
;	-I-   BX : upper.
;	-I/O- AX : value.
; *********************************************************

MAXCUT	PROC	NEAR
	CMP	AX,BX
	JLE	MAXCUT_1
	MOV	AX,BX
	JMP	MAXCUT_2
MAXCUT_1:
	CMP	AX,0
	JGE	MAXCUT_2
	MOV	AX,0
MAXCUT_2:
	RET
MAXCUT	ENDP


; *********************************************************
;	差計算
;	-I/O- BX : now value.
;	      CX : old value.
;	      DX : dest value.
; *********************************************************

PCALC_SA	PROC	NEAR
	CMP	BX,100			; now value.
	JLE	PCALC_SA_2		;
	MOV	BX,100			; now value.
PCALC_SA_2:
	CMP	BX,0			; now value.
	JGE	PCALC_SA_3		;
	MOV	BX,0			; now value.
PCALC_SA_3:

	MOV	AX,BX			; now value.
	SUB	AX,CX			; now value - old value.
	ADD	DX,AX			; dest value.

	MOV	CX,BX			; old value = now value.
	RET
PCALC_SA	ENDP


; *********************************************************
;	百分率
;	AX = AX * BX / 100
;	-i- AX  : source value.
;	    BX  : %
;	-o- AX  : value.
; *********************************************************

P1X100	PROC	NEAR
	MUL	BX			; registar value BX.
	MOV	BX,100			;
	DIV	BX			;
	RET
P1X100	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	B_TAIRYOKU:WORD			; 体力
EXTRN	B_KINRYOKU:WORD			; 筋力
EXTRN	B_CHINOH:WORD			; 知能
EXTRN	B_KIHIN:WORD			; 気品
EXTRN	B_IROKE:WORD			; 色気
EXTRN	B_MORALS:WORD			; モラル
EXTRN	B_SHINKOH:WORD			; 信仰
EXTRN	B_INGYO:WORD			; 因業
EXTRN	B_KANJUSEI:WORD			; 感受性
EXTRN	B_STRESS:WORD			; ストレス

EXTRN	H_SENSHI:WORD			; 戦士評価
EXTRN	H_MAHO:WORD			; 魔法評価
EXTRN	H_SYAKOH:WORD			; 社交評価
EXTRN	H_KAJI:WORD			; 家事評価

EXTRN	V_SENTOH:WORD			; 戦闘技術
EXTRN	V_KOUGEKI:WORD			; 攻撃力
EXTRN	V_BOUGYO:WORD			; 防御力

EXTRN	V_MAHOGIJUTSU:WORD		; 魔法技術
EXTRN	V_MARYOKU:WORD			; 魔力
EXTRN	V_KOHMARYOKU:WORD		; 抗魔力

EXTRN	V_REIGI:WORD			; 礼儀作法
EXTRN	V_GEIJYUTSU:WORD		; 芸術
EXTRN	V_WAJYUTU:WORD			; 話術

EXTRN	V_RYOURI:WORD			; 料理
EXTRN	V_SOUJISENTAKU:WORD		; 掃除洗濯
EXTRN	V_KIDATE:WORD			; 気だて

EXTRN	V_KOGK_KIN:WORD			; 攻撃筋力

EXTRN	T_SENTOH:WORD			; trg戦闘技術
EXTRN	T_KOUGEKI:WORD			; trg攻撃力
EXTRN	T_BOUGYO:WORD			; trg防御力
EXTRN	T_MAHOGIJUTSU:WORD		; trg魔法技術
EXTRN	T_MARYOKU:WORD			; trg魔力
EXTRN	T_KOHMARYOKU:WORD		; trg抗魔力
EXTRN	T_REIGI:WORD			; trg礼儀作法
EXTRN	T_GEIJYUTSU:WORD		; trg芸術
EXTRN	T_WAJYUTU:WORD			; trg話術
EXTRN	T_RYOURI:WORD			; trg料理
EXTRN	T_SOUJISENTAKU:WORD		; trg掃除洗濯
EXTRN	T_KIDATE:WORD			; trg気だて

EXTRN	T_BK_SENTOH:WORD		; bk trg戦闘技術
EXTRN	T_BK_KOUGEKI:WORD		; bk trg攻撃力
EXTRN	T_BK_BOUGYO:WORD		; bk trg防御力
EXTRN	T_BK_MAHOGIJUTSU:WORD		; bk trg魔法技術
EXTRN	T_BK_MARYOKU:WORD		; bk trg魔力
EXTRN	T_BK_KOHMARYOKU:WORD		; bk trg抗魔力
EXTRN	T_BK_REIGI:WORD			; bk trg礼儀作法
EXTRN	T_BK_GEIJYUTSU:WORD		; bk trg芸術
EXTRN	T_BK_WAJYUTU:WORD		; bk trg話術
EXTRN	T_BK_RYOURI:WORD		; bk trg料理
EXTRN	T_BK_SOUJISENTAKU:WORD		; bk trg掃除洗濯
EXTRN	T_BK_KIDATE:WORD		; bk trg気だて

EXTRN	H_BK_SENSHI:WORD		; 戦闘技術 + 攻撃力 + 防御力
EXTRN	H_BK_MAHO:WORD			; 魔法技術 + 魔力 + 抗魔力
EXTRN	H_BK_SYAKOH:WORD		; 礼儀作法 + 芸術 + 話術
EXTRN	H_BK_KAJI:WORD			; 料理 + 掃除洗濯 + 気だて

EXTRN	P_BLOOD:WORD			; 血液型
EXTRN	P_NENREI:WORD			; 年齢

EXTRN	GOLD_GIRL:WORD			; 娘の所持金
EXTRN	GOLD_UPPER:WORD			; 所持金上限

EXTRN	S_BYOUKI:WORD			; 病気指数(%)
EXTRN	S_HIKOUKA:WORD			; 非行化指数(%)
EXTRN	S_JINMYAKU:WORD			; 人脈
EXTRN	FLAG_BYOUKI:WORD		; 状態・病気
EXTRN	FLAG_HIKOUKA:WORD		; 状態・非行化
EXTRN	FLAG_RENAI:WORD			; 状態・恋愛
EXTRN	FLAG_KENKO:WORD			; 健康管理

EXTRN	GIRL_BODY:WORD			; 体形 1=細,2=太
EXTRN	GIRL_FACE:WORD			; 表情 1=基本,2=非行,3病気,4元気,5色気
EXTRN	GIRL_BREAST:WORD		; 胸大 0=無,1=有
EXTRN	GIRL_DAMEG:WORD			; 重病 0=normal,1=重病

EXTRN	P_SHINCHO:WORD			; 身長
EXTRN	P_TAIJYU:WORD			; 体重
EXTRN	P_BUST:WORD			; バスト
EXTRN	P_WAIST:WORD			; ウエスト
EXTRN	P_HIP:WORD			; ヒップ

EXTRN	URA_BREAST_TYPE:WORD		; バストの大中小タイプの分類
EXTRN	URA_HIP_TYPE:WORD		; ヒップの大中小タイプの分類
EXTRN	URA_PRINCE:WORD			; 王子との関係
EXTRN	URA_FATHER:WORD			; 父との関係
EXTRN	URA_STEWARD:WORD		; 執事との関係
EXTRN	URA_MOTHER_LOVE:WORD		; 母性
EXTRN	URA_KILL_MONSTR:WORD		; モンスター殺戮数

EXTRN	E_ETC:WORD			;その他ｲﾍﾞﾝﾄ発生条件

EXTRN	VAL_YEAR:WORD			; 年
EXTRN	VAL_MONTH:WORD			; 月
EXTRN	VAL_WEEK:WORD			; 曜日
EXTRN	VAL_DAY:WORD			; 日

DATA	ENDS

	END
;
;	end of "PARACALC.ASM"
;
