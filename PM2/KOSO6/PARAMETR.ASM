; "PARAMETR.ASM" 486/50 make by R.H 1992/06/04
;
;
;	パラメータ.
;
;	0=白羊宮
;	1=金牛宮
;	2=双児宮
;	3=巨蟹宮
;	4=獅子宮
;	5=処女宮
;	6=天秤宮
;	7=天蠍宮
;	8=人馬宮
;	9=磨羯宮
;	10=宝瓶宮
;	11=双魚宮
;
;	0=太陽
;	1=月
;	2=火星
;	3=水星
;	4=木星
;	5=金星
;	6=土星
;	7=天王星
;	8=海王星
;	9=冥王星
;
;	0=Ａ
;	1=Ｂ
;	2=Ｏ
;	3=ＡＢ
;
;
;	1=小
;	2=中
;	3=大
;
; public subroutine.

SHE_NAME_LEN	EQU	32		; 名前長さ
FAMILY_NAME_LEN	EQU	32		; 名前長さ(family)

ITM_NAME_LEN	EQU	16		; アイテム名前長さ
ITM_PROG_LEN	EQU	64		; アイテム効果長さ
ITM_HELP_LEN	EQU	18		; アイテム説明長さ
ITM_HEALTH_LEN	EQU	16		; 健康管理長さ

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	PARA_CLEAR		; parameter clear.

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	PARAMETER_TOP			; parameter top address.
PUBLIC	PARAMETER_END			; parameter end address.
PUBLIC	PARAMETER_LEN			; parameter length.

PUBLIC	PARAMTBL_AREA_TOP		; table area top.
PUBLIC	PARAMTBL_AREA_WLEN		; table area word len.
PUBLIC	PARAMTBL_WCOUNT			; table word count.

PARAMETER_LEN	DW	PARAMETER_END-PARAMETER_TOP
PARAMTBL_WCOUNT	DW	(PARAMTBL_AREA_TOP_E-PARAMTBL_AREA_TOP)/2

PARAMTBL_AREA_TOP	LABEL	WORD	; table area top.
	DW	PARA_BASEVALUE_TOP	;1 parameter basevalue top.
	DW	PARA_TECHVALUE_TOP	;2 parameter technical value top.
	DW	PARA_MONEY_TOP		;3 parameter money top.
	DW	PARA_PROFILE_TOP	;4 parameter profile top.
	DW	PARA_BATLE_STATUS_TOP	;5 parameter batle status top.
	DW	PARA_STATUS_TOP		;6 parameter status top.
	DW	PARA_COUNTER_TOP	;7 parameter counter top.
	DW	PARA_URA_VALUE_TOP	;8 parameter ura value top.
	DW	PARA_EVENT_TOP		;9 parameter event top.
	DW	PARA_CALENDAR_TOP	;10 parameter calendar top.
PARAMTBL_AREA_TOP_E	LABEL	WORD	; end of table area top.

PARAMTBL_AREA_WLEN	LABEL	WORD		; table area word len.
	DW	(PARA_BASEVALUE_END	- PARA_BASEVALUE_TOP)	/ 2
	DW	(PARA_TECHVALUE_END	- PARA_TECHVALUE_TOP)	/ 2
	DW	(PARA_MONEY_END		- PARA_MONEY_TOP)	/ 2
	DW	(PARA_PROFILE_END	- PARA_PROFILE_TOP)	/ 2
	DW	(PARA_BATLE_STATUS_END	- PARA_BATLE_STATUS_TOP)/ 2
	DW	(PARA_STATUS_END	- PARA_STATUS_TOP)	/ 2
	DW	(PARA_COUNTER_END	- PARA_COUNTER_TOP)	/ 2
	DW	(PARA_URA_VALUE_END	- PARA_URA_VALUE_TOP)	/ 2
	DW	(PARA_EVENT_END		- PARA_EVENT_TOP)	/ 2
	DW	(PARA_CALENDAR_END	- PARA_CALENDAR_TOP)	/ 2

PARAMETER_TOP	LABEL	WORD		; parameter top address.

;	娘のパラメータ
;
;	各パラメータの数値は，基本的には正の整数です．
;	パラメータ増減の計算時に小数点以下になるときは，切り捨てるなり，
;	四捨五入するなりして整数にしてください．
;	また，負の数になるときは，0としてください．
;	ただし，身長・体重・バスト・ウエスト・ヒップは小数点以下２桁までです．

; ****************************************************
;	基本能力
; ****************************************************
;
;	各数値は０～９９９　因業・ストレス以外の初期値は子宮名によって決定．
;
;体力		体の丈夫さ．ＨＰ（ﾋｯﾄﾎﾟｲﾝﾄ）の元となる数値．
;筋力		筋肉の強さ．攻撃力の元となる数値．
;知能		頭の良さ．ＭＰ（ﾏｼﾞｯｸﾎﾟｲﾝﾄ）の元となる数値．
;気品		品性の良さ．社交界で重視される数値．
;色気		女性的な魅力．異性への関心．フェロモン分泌量．
;モラル		道徳心，公徳心．社会に貢献しようとする心．
;信仰		神への信心．信仰の深さ．抗魔力の元となる数値．
;因業		人生の罪深さ．モンスターを殺したり，欲深い行動で増える.初期値０
;感受性		心の豊かさ．芸術的能力に影響．また，超自然に触れる力となる．
;ストレス	疲労度．仕事の失敗，勉強の能率等に影響．初期値０

PARA_BASEVALUE_TOP	LABEL	WORD	; parameter basevalue top.

PUBLIC	B_TAIRYOKU			; 体力
PUBLIC	B_KINRYOKU			; 筋力
PUBLIC	B_CHINOH			; 知能
PUBLIC	B_KIHIN				; 気品
PUBLIC	B_IROKE				; 色気
PUBLIC	B_MORALS			; モラル
PUBLIC	B_SHINKOH			; 信仰
PUBLIC	B_INGYO				; 因業
PUBLIC	B_KANJUSEI			; 感受性
PUBLIC	B_STRESS			; ストレス

B_TAIRYOKU	DW	0		; 体力
B_KINRYOKU	DW	0		; 筋力
B_CHINOH	DW	0		; 知能
B_KIHIN		DW	0		; 気品
B_IROKE		DW	0		; 色気
B_MORALS	DW	0		; モラル
B_SHINKOH	DW	0		; 信仰
B_INGYO		DW	0		; 因業
B_KANJUSEI	DW	0		; 感受性
B_STRESS	DW	0		; ストレス

PARA_BASEVALUE_END	LABEL	WORD	; parameter basevalue end.

; ****************************************************
;	技能別能力
; ****************************************************
;
;	各評価値は０～９９９（そんなに増えないはずだが）
;
;戦士評価	戦闘技術，攻撃力，防御力の和．
;魔法評価	魔法技術，魔力，抗魔力の和．
;社交評価	礼儀作法，芸術，話術の和．
;家事評価	料理，掃除洗濯，気だての和．
;
;	各技能値は１～１００．ただし上限値１００は，武具，アイテムをはずした
;	状態に限って．武具，アイテムで修正された値は，１００を越えてもよい．
;
;戦闘技術	攻撃，回避の成否を決定．訓練で上昇．また戦闘で勝利すれば上昇．
;攻撃力		敵に与えるダメージ．　《筋力の10％の値 + 武器などの修正値》
;防御力		敵の攻撃のダメージを減らす力．《基本値10 + 防具等の修正値》
;
;魔法技術	魔法使いとしての技術で，使える魔法を決定．
;魔力		魔法の効果を決定．
;抗魔力		敵の魔法のダメージを減らす力．
;
;礼儀作法	淑女としての物腰，立居振るまい等．
;芸術		芸術センス．
;話術		会話の作法や技術．これが高いほど，人づきあいがうまい．
;
;料理		お料理の腕前．
;掃除洗濯	掃除や洗濯，家事全般の腕前．
;気だて		家庭での気配り，やさしさ．

PARA_TECHVALUE_TOP	LABEL	WORD	; parameter technical value top.

PUBLIC	H_SENSHI			; 戦士評価
PUBLIC	H_MAHO				; 魔法評価
PUBLIC	H_SYAKOH			; 社交評価
PUBLIC	H_KAJI				; 家事評価

PUBLIC	V_SENTOH			; 戦闘技術
PUBLIC	V_KOUGEKI			; 攻撃力
PUBLIC	V_BOUGYO			; 防御力

PUBLIC	V_MAHOGIJUTSU			; 魔法技術
PUBLIC	V_MARYOKU			; 魔力
PUBLIC	V_KOHMARYOKU			; 抗魔力

PUBLIC	V_REIGI				; 礼儀作法
PUBLIC	V_GEIJYUTSU			; 芸術
PUBLIC	V_WAJYUTU			; 話術

PUBLIC	V_RYOURI			; 料理
PUBLIC	V_SOUJISENTAKU			; 掃除洗濯
PUBLIC	V_KIDATE			; 気だて

PUBLIC	V_KOGK_KIN			; 攻撃筋力

PUBLIC	T_SENTOH			; trg戦闘技術
PUBLIC	T_KOUGEKI			; trg攻撃力
PUBLIC	T_BOUGYO			; trg防御力
PUBLIC	T_MAHOGIJUTSU			; trg魔法技術
PUBLIC	T_MARYOKU			; trg魔力
PUBLIC	T_KOHMARYOKU			; trg抗魔力
PUBLIC	T_REIGI				; trg礼儀作法
PUBLIC	T_GEIJYUTSU			; trg芸術
PUBLIC	T_WAJYUTU			; trg話術
PUBLIC	T_RYOURI			; trg料理
PUBLIC	T_SOUJISENTAKU			; trg掃除洗濯
PUBLIC	T_KIDATE			; trg気だて

PUBLIC	T_BK_SENTOH			; bk trg戦闘技術
PUBLIC	T_BK_KOUGEKI			; bk trg攻撃力
PUBLIC	T_BK_BOUGYO			; bk trg防御力
PUBLIC	T_BK_MAHOGIJUTSU		; bk trg魔法技術
PUBLIC	T_BK_MARYOKU			; bk trg魔力
PUBLIC	T_BK_KOHMARYOKU			; bk trg抗魔力
PUBLIC	T_BK_REIGI			; bk trg礼儀作法
PUBLIC	T_BK_GEIJYUTSU			; bk trg芸術
PUBLIC	T_BK_WAJYUTU			; bk trg話術
PUBLIC	T_BK_RYOURI			; bk trg料理
PUBLIC	T_BK_SOUJISENTAKU		; bk trg掃除洗濯
PUBLIC	T_BK_KIDATE			; bk trg気だて

PUBLIC	H_BK_SENSHI			; 戦闘技術 + 攻撃力 + 防御力
PUBLIC	H_BK_MAHO			; 魔法技術 + 魔力 + 抗魔力
PUBLIC	H_BK_SYAKOH			; 礼儀作法 + 芸術 + 話術
PUBLIC	H_BK_KAJI			; 料理 + 掃除洗濯 + 気だて

H_SENSHI	DW	0		; 戦士評価
H_MAHO		DW	0		; 魔法評価
H_SYAKOH	DW	0		; 社交評価
H_KAJI		DW	0		; 家事評価

V_SENTOH	DW	0		; 戦闘技術
V_KOUGEKI	DW	0		; 攻撃力
V_BOUGYO	DW	0		; 防御力

V_MAHOGIJUTSU	DW	0		; 魔法技術
V_MARYOKU	DW	0		; 魔力
V_KOHMARYOKU	DW	0		; 抗魔力

V_REIGI		DW	0		; 礼儀作法
V_GEIJYUTSU	DW	0		; 芸術
V_WAJYUTU	DW	0		; 話術

V_RYOURI	DW	0		; 料理
V_SOUJISENTAKU	DW	0		; 掃除洗濯
V_KIDATE	DW	0		; 気だて

V_KOGK_KIN	DW	0		; 攻撃筋力

T_SENTOH	DW	0		; trg戦闘技術
T_KOUGEKI	DW	0		; trg攻撃力
T_BOUGYO	DW	0		; trg防御力
T_MAHOGIJUTSU	DW	0		; trg魔法技術
T_MARYOKU	DW	0		; trg魔力
T_KOHMARYOKU	DW	0		; trg抗魔力
T_REIGI		DW	0		; trg礼儀作法
T_GEIJYUTSU	DW	0		; trg芸術
T_WAJYUTU	DW	0		; trg話術
T_RYOURI	DW	0		; trg料理
T_SOUJISENTAKU	DW	0		; trg掃除洗濯
T_KIDATE	DW	0		; trg気だて

T_BK_SENTOH	DW	0		; bk trg戦闘技術
T_BK_KOUGEKI	DW	0		; bk trg攻撃力
T_BK_BOUGYO	DW	0		; bk trg防御力
T_BK_MAHOGIJUTSU DW	0		; bk trg魔法技術
T_BK_MARYOKU	DW	0		; bk trg魔力
T_BK_KOHMARYOKU	DW	0		; bk trg抗魔力
T_BK_REIGI	DW	0		; bk trg礼儀作法
T_BK_GEIJYUTSU	DW	0		; bk trg芸術
T_BK_WAJYUTU	DW	0		; bk trg話術
T_BK_RYOURI	DW	0		; bk trg料理
T_BK_SOUJISENTAKU DW	0		; bk trg掃除洗濯
T_BK_KIDATE	DW	0		; bk trg気だて

H_BK_SENSHI	DW	0		; 戦闘技術 + 攻撃力 + 防御力
H_BK_MAHO	DW	0		; 魔法技術 + 魔力 + 抗魔力
H_BK_SYAKOH	DW	0		; 礼儀作法 + 芸術 + 話術
H_BK_KAJI	DW	0		; 料理 + 掃除洗濯 + 気だて

PARA_TECHVALUE_END	LABEL	WORD	; parameter technical value end.

; ****************************************************
;	所持金
; ****************************************************

PARA_MONEY_TOP	LABEL	WORD		; parameter money top.

PUBLIC	GOLD_GIRL			; 娘の所持金

GOLD_GIRL	DW	0		; 娘の所持金
		DW	0		;

PARA_MONEY_END	LABEL	WORD		; parameter money end.

; ****************************************************
;	プロフィール
; ****************************************************
;
;名前		名
;名前(family)	姓
;血液型		Ａ，Ｂ，Ｏ，ＡＢの４タイプあり．
;年齢		誕生日になると１づつ増える．最初は１０歳．
;誕生日		産まれ日
;誕生月		産まれ月
;誕生年		産まれ年
;子宮名		１２種類ある．各パラメータの初期値に影響．星座と同意．
;守護星		娘の守り神．子宮名によって決定．（別紙の表参照）
;身長		毎月少しずつ増える．「健康管理」によって多少の差あり．
;体重		毎月少しづつ増減．「健康管理」によって多少の差あり．
;バスト		一ヶ月あたり下記の数値分増加する．バスト値は減ることはない．
;ウエスト	身長，体重により常に変動する．
;ヒップ		一ヶ月あたり下記の数値分増加する．ヒップ値は減ることはない．

PUBLIC	NAME_FIRST_LEN			; 名前長さ
PUBLIC	NAME_FAMILY_LEN			; 名前長さ(family)

PUBLIC	NAME_FIRST			; 名前
PUBLIC	NAME_FAMILY			; 名前(family)

PUBLIC	P_BLOOD				; 血液型
PUBLIC	P_NENREI			; 年齢
PUBLIC	P_BORTHDAY			; 誕生日
PUBLIC	P_BORTHMONTH			; 誕生月
PUBLIC	P_BORTHYEAR			; 誕生年
PUBLIC	P_SHIKYU			; 子宮名
PUBLIC	P_SYUGOSEI			; 守護星

PUBLIC	P_SHINCHO			; 身長
PUBLIC	P_TAIJYU			; 体重
PUBLIC	P_BUST				; バスト
PUBLIC	P_WAIST				; ウエスト
PUBLIC	P_HIP				; ヒップ

NAME_FIRST_LEN	DW	SHE_NAME_LEN			; 名前長さ
NAME_FAMILY_LEN	DW	FAMILY_NAME_LEN			; 名前長さ(family)

NAME_FIRST	DW	STR_NM,STR_NM_01		; 名前
NAME_FAMILY	DW	STR_FM,STR_FM_01		; 名前(family)

PARA_PROFILE_TOP	LABEL	WORD	; parameter profile top.

P_BLOOD		DW	0,0		; 血液型
P_NENREI	DW	0,0		; 年齢
P_BORTHDAY	DW	0,0		; 誕生日
P_BORTHMONTH	DW	0,0		; 誕生月
P_BORTHYEAR	DW	0,0		; 誕生年
P_SHIKYU	DW	0,0		; 子宮名
P_SYUGOSEI	DW	0,0		; 守護星

P_SHINCHO	DW	0		; 身長
P_TAIJYU	DW	0		; 体重
P_BUST		DW	0		; バスト
P_WAIST		DW	0		; ウエスト
P_HIP		DW	0		; ヒップ

PARA_PROFILE_END	LABEL	WORD	; parameter profile top.

STR_NM		DB	"オリーブ",SHE_NAME_LEN DUP (0)	; 名前長さ
STR_FM		DB	"オイル",FAMILY_NAME_LEN DUP (0) ; 名前長さ(family)

STR_NM_01	DB	"リノール",SHE_NAME_LEN DUP (0)	; 名前長さ
STR_FM_01	DB	"オイル",FAMILY_NAME_LEN DUP (0) ; 名前長さ(family)

; ****************************************************
;	戦闘ステータス
; ****************************************************
;
;最大ＨＰ	戦闘時の肉体的耐久力．      体力×病気指数．
;最大ＭＰ	戦闘時の魔法のエネルギー源．知能と同じ数値．
;ＨＰ		戦闘時の肉体的耐久力．
;ＭＰ		戦闘時の魔法のエネルギー源．
;戦意		戦闘中の娘の戦意．ダメージを受けると減少．

PARA_BATLE_STATUS_TOP	LABEL	WORD	; parameter batle status top.

PUBLIC	W_HP_MAX			; 最大ＨＰ
PUBLIC	W_MP_MAX			; 最大ＭＰ
PUBLIC	W_HP				; ＨＰ
PUBLIC	W_MP				; ＭＰ
PUBLIC	W_SENI				; 戦意

W_HP_MAX	DW	0		; 最大ＨＰ
W_MP_MAX	DW	0		; 最大ＭＰ
W_HP		DW	0		; ＨＰ
W_MP		DW	0		; ＭＰ
W_SENI		DW	0		; 戦意

PARA_BATLE_STATUS_END	LABEL	WORD	; parameter batle status end.

; ****************************************************
;	通常ステータス
; ****************************************************
;
;病気指数(%)	健康のバロメータ．《体力－ストレス》
;非行化指数(%)	精神状態のバロメータ．《モラルと信仰の高い方－ストレス》
;
;人脈			お城の人々の人脈値の合計．
;S_JINMYAKU[0]	: 人脈・合計値
;S_JINMYAKU[1]	: 人脈・門番
;S_JINMYAKU[2]	: 人脈・近衛騎士
;S_JINMYAKU[3]	: 人脈・将軍
;S_JINMYAKU[4]	: 人脈・大臣
;S_JINMYAKU[5]	: 人脈・司祭
;S_JINMYAKU[6]	: 人脈・寵姫
;S_JINMYAKU[7]	: 人脈・王妃
;S_JINMYAKU[8]	: 人脈・国王
;
;状態・病気
;状態・非行化
;状態・恋愛
;健康管理	0=「無理はさせない」1=「とにかく丈夫な子に」
;		2=「おしとやかな子に」3=「ダイエットさせる」

PARA_STATUS_TOP	LABEL	WORD		; parameter status top.

PUBLIC	S_BYOUKI			; 病気指数(%)
PUBLIC	S_HIKOUKA			; 非行化指数(%)
PUBLIC	S_JINMYAKU			; 人脈
PUBLIC	FLAG_BYOUKI			; 状態・病気
PUBLIC	FLAG_HIKOUKA			; 状態・非行化
PUBLIC	FLAG_RENAI			; 状態・恋愛
PUBLIC	FLAG_KENKO			; 健康管理

PUBLIC	GIRL_BODY			; 体形 1=細,2=太
PUBLIC	GIRL_FACE			; 表情 1=基本,2=非行,3病気,4元気,5色気
PUBLIC	GIRL_BREAST			; 胸大 0=無,1=有
PUBLIC	GIRL_DAMEG			; 重病 0=normal,1=重病

S_BYOUKI	DW	0		; 病気指数(%)
S_HIKOUKA	DW	0		; 非行化指数(%)
S_JINMYAKU	DW	12 DUP (0)	; 人脈
FLAG_BYOUKI	DW	0		; 状態・病気
FLAG_HIKOUKA	DW	0		; 状態・非行化
FLAG_RENAI	DW	0		; 状態・恋愛
FLAG_KENKO	DW	0		; 健康管理

GIRL_BODY	DW	1		; 体形 1=細,2=太
GIRL_FACE	DW	1		; 表情 1=基本,2=非行,3病気,4元気,5色気
GIRL_BREAST	DW	0		; 胸大 0=無,1=有
GIRL_DAMEG	DW	0		; 重病 0=normal,1=重病

PARA_STATUS_END	LABEL	WORD		; parameter status end.

; ****************************************************
;	装備
; ****************************************************
;
;着衣		現在着ている衣服．
;持物		武器，防具，道具，アクセサリー，衣服など．
;部屋の絵	娘の部屋に飾る絵
;
;ＩＣＯＮ番号については KOSO5\ICON.TXT を参照すること
;
;	着衣絵番号
;	0=裸
;	1=服・普段着,2=服・夏物の服,3=服・冬物の服
;	4=服・木綿のドレス,5=服・シルクのドレス
;	6=服・レーザーのドレス,7=服・トゲトゲの服
;	8=服・傾国のローブ,9=服・見えないドレス
;	10=服・悪魔のドレス,11=服・龍のレオタード
;
;	所有アイテム種別 (ITEM_ATTR)
;	0=通常,1000番台=装備,2000番台=武器,3000番台=服,4000番台=効能有
;	5000番台=効能一回
;	1の位 0=通常,1=装備中
;
;	部屋の絵
;
;	ROOM_PIC =0	"陶土の壷に活けられた花束"
;	ROOM_PIC =1	"酒瓶と林檎のある静物"
;	ROOM_PIC =2	"蒼色を帯びた山脈"
;	ROOM_PIC =3	"自画像"
;	ROOM_PIC =4	"降臨する天使"
;	ROOM_PIC =5	既成の絵
;

PUBLIC	ITEM_NAME_LEN			; アイテム名前長さ
PUBLIC	ITEM_PROG_LEN			; アイテム効果長さ
PUBLIC	ITEM_HELP_LEN			; アイテム説明長さ

PUBLIC	ROOM_PIC			; 部屋の絵

PUBLIC	DRESS_NUM			; 着衣絵番号

PUBLIC	DRESS_ICON			; 着衣　ＩＣＯＮ番号
PUBLIC	DRESS_GOLD			; 着衣　値段
PUBLIC	DRESS_NAME			; 着衣　名前 string
PUBLIC	DRESS_PROG			; 着衣　効果 string
PUBLIC	DRESS_HELP			; 着衣　説明 string

PUBLIC	EQUIP_ICON			; 装備　ＩＣＯＮ番号
PUBLIC	EQUIP_GOLD			; 装備　値段
PUBLIC	EQUIP_NAME			; 装備　名前 string
PUBLIC	EQUIP_PROG			; 装備　効果 string
PUBLIC	EQUIP_HELP			; 装備　説明 string

PUBLIC	ARMS_ICON			; 武器　ＩＣＯＮ番号
PUBLIC	ARMS_GOLD			; 武器　値段
PUBLIC	ARMS_NAME			; 武器　名前 string
PUBLIC	ARMS_PROG			; 武器　効果 string
PUBLIC	ARMS_HELP			; 武器　説明 string

PUBLIC	ITEM_MAX			; 所有アイテム数
PUBLIC	ITEM_DIM			; 所有最大アイテム数
PUBLIC	ITEM_ICON			; 所有アイテムＩＣＯＮ番号
PUBLIC	ITEM_GOLD			; 所有アイテム値段
PUBLIC	ITEM_ATTR			; 所有アイテム種別
PUBLIC	ITEM_NAME			; 所有アイテム名前 string
PUBLIC	ITEM_PROG			; 所有アイテム効果 string
PUBLIC	ITEM_HELP			; 所有アイテム説明 string

ITEM_NAME_LEN	DW	ITM_NAME_LEN	; アイテム名前長さ
ITEM_PROG_LEN	DW	ITM_PROG_LEN	; アイテム効果長さ
ITEM_HELP_LEN	DW	ITM_HELP_LEN	; アイテム説明長さ

ROOM_PIC	DW	5;0		; 部屋の絵

DRESS_NUM	DW	0		; 着衣絵番号

DRESS_ICON	DW	0		; 着衣　ＩＣＯＮ番号
DRESS_GOLD	DW	0		; 着衣　値段
DRESS_NAME	DW	DNSTR		; 着衣　名前 string
DRESS_PROG	DW	DPSTR		; 着衣　効果 string
DRESS_HELP	DW	DHSTR		; 着衣　説明 string

EQUIP_ICON	DW	0		; 装備　ＩＣＯＮ番号
EQUIP_GOLD	DW	0		; 装備　値段
EQUIP_NAME	DW	ENMSTR		; 装備　名前 string
EQUIP_PROG	DW	EKKSTR		; 装備　効果 string
EQUIP_HELP	DW	EHPSTR		; 装備　説明 string

ARMS_ICON	DW	0		; 武器　ＩＣＯＮ番号
ARMS_GOLD	DW	0		; 武器　値段
ARMS_NAME	DW	ANMSTR		; 武器　名前 string
ARMS_PROG	DW	AKKSTR		; 武器　効果 string
ARMS_HELP	DW	AHPSTR		; 武器　説明 string

ITEM_MAX	DW	0		; 所有アイテム数
ITEM_DIM	DW	50		; 所有最大アイテム数
ITEM_ICON	DW	50 DUP (0)	; 所有アイテムＩＣＯＮ番号
ITEM_GOLD	DW	50 DUP (0)	; 所有アイテム値段
ITEM_ATTR	DW	50 DUP (0)	; 所有アイテム種別
ITEM_NAME	LABEL	WORD		; 所有アイテム名前 string
 DW INMSTR		 ,INMSTR+ITM_NAME_LEN  ,INMSTR+ITM_NAME_LEN*2
 DW INMSTR+ITM_NAME_LEN*3,INMSTR+ITM_NAME_LEN*4,INMSTR+ITM_NAME_LEN*5
 DW INMSTR+ITM_NAME_LEN*6,INMSTR+ITM_NAME_LEN*7,INMSTR+ITM_NAME_LEN*8
 DW INMSTR+ITM_NAME_LEN*9
 DW INMSTR+ITM_NAME_LEN*10,INMSTR+ITM_NAME_LEN*11,INMSTR+ITM_NAME_LEN*12
 DW INMSTR+ITM_NAME_LEN*13,INMSTR+ITM_NAME_LEN*14,INMSTR+ITM_NAME_LEN*15
 DW INMSTR+ITM_NAME_LEN*16,INMSTR+ITM_NAME_LEN*17,INMSTR+ITM_NAME_LEN*18
 DW INMSTR+ITM_NAME_LEN*19
 DW INMSTR+ITM_NAME_LEN*20,INMSTR+ITM_NAME_LEN*21,INMSTR+ITM_NAME_LEN*22
 DW INMSTR+ITM_NAME_LEN*23,INMSTR+ITM_NAME_LEN*24,INMSTR+ITM_NAME_LEN*25
 DW INMSTR+ITM_NAME_LEN*26,INMSTR+ITM_NAME_LEN*27,INMSTR+ITM_NAME_LEN*28
 DW INMSTR+ITM_NAME_LEN*29
 DW INMSTR+ITM_NAME_LEN*30,INMSTR+ITM_NAME_LEN*31,INMSTR+ITM_NAME_LEN*32
 DW INMSTR+ITM_NAME_LEN*33,INMSTR+ITM_NAME_LEN*34,INMSTR+ITM_NAME_LEN*35
 DW INMSTR+ITM_NAME_LEN*36,INMSTR+ITM_NAME_LEN*37,INMSTR+ITM_NAME_LEN*38
 DW INMSTR+ITM_NAME_LEN*39
 DW INMSTR+ITM_NAME_LEN*40,INMSTR+ITM_NAME_LEN*41,INMSTR+ITM_NAME_LEN*42
 DW INMSTR+ITM_NAME_LEN*43,INMSTR+ITM_NAME_LEN*44,INMSTR+ITM_NAME_LEN*45
 DW INMSTR+ITM_NAME_LEN*46,INMSTR+ITM_NAME_LEN*47,INMSTR+ITM_NAME_LEN*48
 DW INMSTR+ITM_NAME_LEN*49
ITEM_PROG	LABEL	WORD		; 所有アイテム効果  string
 DW IKKSTR		 ,IKKSTR+ITM_PROG_LEN  ,IKKSTR+ITM_PROG_LEN*2
 DW IKKSTR+ITM_PROG_LEN*3,IKKSTR+ITM_PROG_LEN*4,IKKSTR+ITM_PROG_LEN*5
 DW IKKSTR+ITM_PROG_LEN*6,IKKSTR+ITM_PROG_LEN*7,IKKSTR+ITM_PROG_LEN*8
 DW IKKSTR+ITM_PROG_LEN*9
 DW IKKSTR+ITM_PROG_LEN*10,IKKSTR+ITM_PROG_LEN*11,IKKSTR+ITM_PROG_LEN*12
 DW IKKSTR+ITM_PROG_LEN*13,IKKSTR+ITM_PROG_LEN*14,IKKSTR+ITM_PROG_LEN*15
 DW IKKSTR+ITM_PROG_LEN*16,IKKSTR+ITM_PROG_LEN*17,IKKSTR+ITM_PROG_LEN*18
 DW IKKSTR+ITM_PROG_LEN*19
 DW IKKSTR+ITM_PROG_LEN*20,IKKSTR+ITM_PROG_LEN*21,IKKSTR+ITM_PROG_LEN*22
 DW IKKSTR+ITM_PROG_LEN*23,IKKSTR+ITM_PROG_LEN*24,IKKSTR+ITM_PROG_LEN*25
 DW IKKSTR+ITM_PROG_LEN*26,IKKSTR+ITM_PROG_LEN*27,IKKSTR+ITM_PROG_LEN*28
 DW IKKSTR+ITM_PROG_LEN*29
 DW IKKSTR+ITM_PROG_LEN*30,IKKSTR+ITM_PROG_LEN*31,IKKSTR+ITM_PROG_LEN*32
 DW IKKSTR+ITM_PROG_LEN*33,IKKSTR+ITM_PROG_LEN*34,IKKSTR+ITM_PROG_LEN*35
 DW IKKSTR+ITM_PROG_LEN*36,IKKSTR+ITM_PROG_LEN*37,IKKSTR+ITM_PROG_LEN*38
 DW IKKSTR+ITM_PROG_LEN*39
 DW IKKSTR+ITM_PROG_LEN*40,IKKSTR+ITM_PROG_LEN*41,IKKSTR+ITM_PROG_LEN*42
 DW IKKSTR+ITM_PROG_LEN*43,IKKSTR+ITM_PROG_LEN*44,IKKSTR+ITM_PROG_LEN*45
 DW IKKSTR+ITM_PROG_LEN*46,IKKSTR+ITM_PROG_LEN*47,IKKSTR+ITM_PROG_LEN*48
 DW IKKSTR+ITM_PROG_LEN*49
ITEM_HELP	LABEL	WORD		; 所有アイテム説明  string
 DW IHPSTR		 ,IHPSTR+ITM_HELP_LEN  ,IHPSTR+ITM_HELP_LEN*2
 DW IHPSTR+ITM_HELP_LEN*3,IHPSTR+ITM_HELP_LEN*4,IHPSTR+ITM_HELP_LEN*5
 DW IHPSTR+ITM_HELP_LEN*6,IHPSTR+ITM_HELP_LEN*7,IHPSTR+ITM_HELP_LEN*8
 DW IHPSTR+ITM_HELP_LEN*9
 DW IHPSTR+ITM_HELP_LEN*10,IHPSTR+ITM_HELP_LEN*11,IHPSTR+ITM_HELP_LEN*12
 DW IHPSTR+ITM_HELP_LEN*13,IHPSTR+ITM_HELP_LEN*14,IHPSTR+ITM_HELP_LEN*15
 DW IHPSTR+ITM_HELP_LEN*16,IHPSTR+ITM_HELP_LEN*17,IHPSTR+ITM_HELP_LEN*18
 DW IHPSTR+ITM_HELP_LEN*19
 DW IHPSTR+ITM_HELP_LEN*20,IHPSTR+ITM_HELP_LEN*21,IHPSTR+ITM_HELP_LEN*22
 DW IHPSTR+ITM_HELP_LEN*23,IHPSTR+ITM_HELP_LEN*24,IHPSTR+ITM_HELP_LEN*25
 DW IHPSTR+ITM_HELP_LEN*26,IHPSTR+ITM_HELP_LEN*27,IHPSTR+ITM_HELP_LEN*28
 DW IHPSTR+ITM_HELP_LEN*29
 DW IHPSTR+ITM_HELP_LEN*30,IHPSTR+ITM_HELP_LEN*31,IHPSTR+ITM_HELP_LEN*32
 DW IHPSTR+ITM_HELP_LEN*33,IHPSTR+ITM_HELP_LEN*34,IHPSTR+ITM_HELP_LEN*35
 DW IHPSTR+ITM_HELP_LEN*36,IHPSTR+ITM_HELP_LEN*37,IHPSTR+ITM_HELP_LEN*38
 DW IHPSTR+ITM_HELP_LEN*39
 DW IHPSTR+ITM_HELP_LEN*40,IHPSTR+ITM_HELP_LEN*41,IHPSTR+ITM_HELP_LEN*42
 DW IHPSTR+ITM_HELP_LEN*43,IHPSTR+ITM_HELP_LEN*44,IHPSTR+ITM_HELP_LEN*45
 DW IHPSTR+ITM_HELP_LEN*46,IHPSTR+ITM_HELP_LEN*47,IHPSTR+ITM_HELP_LEN*48
 DW IHPSTR+ITM_HELP_LEN*49

DNSTR		DB	ITM_NAME_LEN DUP (0)
DPSTR		DB	ITM_PROG_LEN DUP (0)
DHSTR		DB	ITM_HELP_LEN DUP (0)

INMSTR		DB	ITM_NAME_LEN*50 DUP (0)
IKKSTR		DB	ITM_PROG_LEN*50 DUP (0)
IHPSTR		DB	ITM_HELP_LEN*50 DUP (0)

ENMSTR		DB	ITM_NAME_LEN DUP (0)
EKKSTR		DB	ITM_PROG_LEN DUP (0)
EHPSTR		DB	ITM_HELP_LEN DUP (0)

ANMSTR		DB	ITM_NAME_LEN DUP (0)
AKKSTR		DB	ITM_PROG_LEN DUP (0)
AHPSTR		DB	ITM_HELP_LEN DUP (0)

; ****************************************************
;	隠しパラメータ
; ****************************************************
;
;	ゲーム中，プレイヤーにはわからないパラメータ
;	★☆★エンディングに影響☆★☆
;
; ****************************************************
;	隠しパラメータ・各コマンド実行回数
; ****************************************************
;
;
;RUN_OSHIRO[0]「お城に行く」実行回数
;RUN_OSHIRO[1]「面会・門番」実行回数
;RUN_OSHIRO[2]「面会・近衛騎士」実行回数
;RUN_OSHIRO[3]「面会・将軍」実行回数
;RUN_OSHIRO[4]「面会・大臣」実行回数
;RUN_OSHIRO[5]「面会・司祭」実行回数
;RUN_OSHIRO[6]「面会・寵姫」実行回数
;RUN_OSHIRO[7]「面会・王妃」実行回数
;RUN_OSHIRO[8]「面会・国王」実行回数
;RUN_OSHIRO[9]「面会・道化師」実行回数
;
;
;RUN_MACHI[0]「街に行く」実行回数
;RUN_MACHI[1]「武器屋」実行回数
;RUN_MACHI[2]「仕立屋」実行回数
;RUN_MACHI[3]「料理屋」実行回数
;RUN_MACHI[4]「雑貨屋」実行回数
;RUN_MACHI[5]「教会」実行回数
;
;
;RUN_TALK[0]「娘と話す」実行回数
;RUN_TALK[1]「親子の語らい」実行回数
;RUN_TALK[2]「おこずかい」実行回数
;RUN_TALK[3]「お説教」実行回数
;
;
;RUN_KENKOH[0]「健康管理」実行回数
;RUN_KENKOH[1]「健康第一」実行回数
;RUN_KENKOH[2]「子供は風の子」実行回数
;RUN_KENKOH[3]「無理は禁物」実行回数
;RUN_KENKOH[4]「ダイエット」実行回数
;
;
;RUN_SYUGOSEI[0]「守護星に祈る」実行回数
;RUN_SYUGOSEI[1]「時を刻む（セーブ）」実行回数
;RUN_SYUGOSEI[2]「時を戻す（ロード）」実行回数
;RUN_SYUGOSEI[3]「ひとときの別れ（ゲームの終了）」実行回数
;
;	各訓練，アルバイトの実行回数
;
;
;RUN_KITAERU[0]「娘を鍛える」実行回数
;RUN_KITAERU[1]「自然科学」実行回数
;RUN_KITAERU[2]「詩文」実行回数
;RUN_KITAERU[3]「神学」実行回数
;RUN_KITAERU[4]「軍学」実行回数
;RUN_KITAERU[5]「剣術」実行回数
;RUN_KITAERU[6]「格闘術」実行回数
;RUN_KITAERU[7]「魔法」実行回数
;RUN_KITAERU[8]「礼儀作法」実行回数
;RUN_KITAERU[9]「絵画」実行回数
;RUN_KITAERU[10]「舞踊」実行回数
;
;RUN_ARBEIT[0]「娘を働かせる」実行回数
;RUN_ARBEIT[1]「家の手伝い」実行回数
;RUN_ARBEIT[2]「子守」実行回数
;RUN_ARBEIT[3]「宿屋」実行回数
;RUN_ARBEIT[4]「農場」実行回数
;RUN_ARBEIT[5]「教会」実行回数
;RUN_ARBEIT[6]「料理屋」実行回数
;RUN_ARBEIT[7]「木コリ」実行回数
;RUN_ARBEIT[8]「髪結い」実行回数
;RUN_ARBEIT[9]「左官」実行回数
;RUN_ARBEIT[10]「狩人」実行回数
;RUN_ARBEIT[11]「墓守」実行回数
;RUN_ARBEIT[12]「家庭教師」実行回数
;RUN_ARBEIT[13]「酒場」実行回数
;RUN_ARBEIT[14]「ヤミ酒場」実行回数
;RUN_ARBEIT[15]「夜の殿堂」実行回数
;
;RUN_ARBEIT[16]
;RUN_ARBEIT[17]「家の手伝い」訪問回数
;RUN_ARBEIT[18]「子守」訪問回数
;RUN_ARBEIT[19]「宿屋」訪問回数
;RUN_ARBEIT[20]「農場」訪問回数
;RUN_ARBEIT[21]「教会」訪問回数
;RUN_ARBEIT[22]「料理屋」訪問回数
;RUN_ARBEIT[23]「木コリ」訪問回数
;RUN_ARBEIT[24]「髪結い」訪問回数
;RUN_ARBEIT[25]「左官」訪問回数
;RUN_ARBEIT[26]「狩人」訪問回数
;RUN_ARBEIT[27]「墓守」訪問回数
;RUN_ARBEIT[28]「家庭教師」訪問回数
;RUN_ARBEIT[29]「酒場」訪問回数
;RUN_ARBEIT[30]「ヤミ酒場」訪問回数
;RUN_ARBEIT[31]「夜の殿堂」訪問回数
;
;GRA_ARBEIT[0]「娘を働かせる」待遇
;GRA_ARBEIT[1]「家の手伝い」待遇
;GRA_ARBEIT[2]「子守」待遇
;GRA_ARBEIT[3]「宿屋」待遇
;GRA_ARBEIT[4]「農場」待遇
;GRA_ARBEIT[5]「教会」待遇
;GRA_ARBEIT[6]「料理屋」待遇
;GRA_ARBEIT[7]「木コリ」待遇
;GRA_ARBEIT[8]「髪結い」待遇
;GRA_ARBEIT[9]「左官」待遇
;GRA_ARBEIT[10]「狩人」待遇
;GRA_ARBEIT[11]「墓守」待遇
;GRA_ARBEIT[12]「家庭教師」待遇
;GRA_ARBEIT[13]「酒場」待遇
;GRA_ARBEIT[14]「ヤミ酒場」待遇
;GRA_ARBEIT[15]「夜の殿堂」待遇
;
;RUN_MUSYA[0]「武者修行に出す」実行回数
;RUN_MUSYA[1]「東」実行回数
;RUN_MUSYA[2]「西」実行回数
;RUN_MUSYA[3]「南」実行回数
;RUN_MUSYA[4]「北」実行回数
;
;
;RUN_BACANCE[0]「休みをあげる」実行回数
;RUN_BACANCE[1]「自由行動」実行回数
;RUN_BACANCE[2]「バカンス」実行回数
;RUN_BACANCE[3]「監視」実行回数
;RUN_BACANCE[4]「安静」実行回数
;RUN_BACANCE[5]「サナトリウム」実行回数
;
;
;	各イベント発生回数
;
;
;RUN_SYUKAKUSAI[0]「収穫祭」実行回数
;RUN_SYUKAKUSAI[1]「武闘会」実行回数
;RUN_SYUKAKUSAI[2]「舞踏会」実行回数
;RUN_SYUKAKUSAI[3]「芸術祭」実行回数
;RUN_SYUKAKUSAI[4]「お料理コンクール」実行回数
;
;
;RUN_MONTH[0]「月１イベント」実行回数
;RUN_MONTH[1]「執事のあいさつ」実行回数
;RUN_MONTH[2]「執事の忠告」実行回数
;RUN_MONTH[3]「猛暑」実行回数
;RUN_MONTH[4]「厳寒」実行回数
;RUN_MONTH[5]「占い師の訪問」実行回数
;RUN_MONTH[6]「訪問販売」実行回数
;RUN_MONTH[7]「魔族の訪問」実行回数
;RUN_MONTH[8]「道化師の訪問」実行回数
;RUN_MONTH[9]「家出」実行回数
;RUN_MONTH[10]「魔法使いの訪問」実行回数
;RUN_MONTH[11]「幼精霊の訪問」実行回数
;RUN_MONTH[12]「老人のお礼」実行回数
;RUN_MONTH[13]「プロポーズ」実行回数
;RUN_MONTH[14]「妾のお手当」実行回数
;RUN_MONTH[15]「技能アップの祝福」実行回数
;RUN_MONTH[16]「極楽鳥の卵を食べる」実行回数
;RUN_MONTH[17]「極楽鳥の誕生」実行回数
;RUN_MONTH[18]「ムダ使い」実行回数
;RUN_MONTH[19]「ライバルを意識する」実行回数
;RUN_MONTH[20]「ドラゴンのプロポーズ」実行回数
;RUN_MONTH[21]「妾」実行回数
;RUN_MONTH[22]「武芸者の挑戦」実行回数
;RUN_MONTH[23]「道場破り」実行回数
;RUN_MONTH[24] none
;RUN_MONTH[25]「悪い虫」実行回数
;RUN_MONTH[26]「ライバル登場」実行回数
;RUN_MONTH[27] none
;RUN_MONTH[28]「精霊に出会う」実行回数
;RUN_MONTH[29]「お尋ね者と遭遇」実行回数
;RUN_MONTH[30]「ユニコーンを発見」実行回数
;RUN_MONTH[31]「エルフに出会う」実行回数
;RUN_MONTH[32]「老ドラゴンに会う」実行回数
;RUN_MONTH[33]「悪魔に出会う」実行回数
;RUN_MONTH[34]「生意気なドラゴンに会う」実行回数
;RUN_MONTH[35]「精霊猫に会う」実行回数
;RUN_MONTH[36]「マーメイドに会う」実行回数
;RUN_MONTH[37]「ビーナスの祝福」実行回数
;RUN_MONTH[38] none
;RUN_MONTH[39]「絵を描く」実行回数
;RUN_MONTH[40]「ただ食い」実行回数
;RUN_MONTH[41]「恩賜の剣売却事件」実行回数
;RUN_MONTH[42]「娘の誕生日」実行回数
;RUN_MONTH[43]「父の誕生日」実行回数
;RUN_MONTH[44]「青年武官と面会」実行回数
;RUN_MONTH[45]「逮捕」実行回数
;RUN_MONTH[46]「追い剥ぎの発覚」実行回数
;RUN_MONTH[47]「妖精のお茶会」実行回数
;RUN_MONTH[48]「妖精のダンスパーティー」実行回数
;RUN_MONTH[49]「魔王の酒盛り」実行回数
;RUN_MONTH[50]「拾い物」実行回数
;RUN_MONTH[51]「亡霊騎士出現」実行回数
;RUN_MONTH[52]「表彰」実行回数
;RUN_MONTH[53]「Ｈなお尋ね者」実行回数
;RUN_MONTH[54]「守護星に会う」実行回数
;RUN_MONTH[55]「武神の退場」実行回数
;RUN_MONTH[56]「今年度分の俸給」実行回数

PARA_COUNTER_TOP	LABEL	WORD	; parameter counter top.

PUBLIC	RUN_OSHIRO			;「お城に行く」実行回数
PUBLIC	RUN_MACHI	 		;「街に行く」実行回数
PUBLIC	RUN_TALK	 		;「娘と話す」実行回数
PUBLIC	RUN_KENKOH	 		;「健康管理」実行回数
PUBLIC	RUN_SYUGOSEI	 		;「守護星に祈る」実行回数
PUBLIC	RUN_KITAERU	 		;「娘を鍛える」実行回数
PUBLIC	RUN_ARBEIT	 		;「娘を働かせる」実行回数
PUBLIC	GRA_ARBEIT			;「娘を働かせる」待遇
PUBLIC	RUN_MUSYA	 		;「武者修行に出す」実行回数
PUBLIC	RUN_BACANCE	 		;「休みをあげる」実行回数
PUBLIC	RUN_SYUKAKUSAI	 		;「収穫祭」実行回数
PUBLIC	RUN_MONTH	 		;「月１イベント」実行回数

RUN_OSHIRO	DW	10 DUP (0)	;「お城に行く」実行回数
RUN_MACHI	DW	6 DUP (0)	;「街に行く」実行回数
RUN_TALK	DW	4 DUP (0)	;「娘と話す」実行回数
RUN_KENKOH	DW	5 DUP (0)	;「健康管理」実行回数
RUN_SYUGOSEI	DW	4 DUP (0)	;「守護星に祈る」実行回数
RUN_KITAERU	DW	11 DUP (0)	;「娘を鍛える」実行回数
RUN_ARBEIT	DW	32 DUP (0)	;「娘を働かせる」実行回数
GRA_ARBEIT	DW	16 DUP (0)	;「娘を働かせる」待遇
RUN_MUSYA	DW	5 DUP (0)	;「武者修行に出す」実行回数
RUN_BACANCE	DW	3 DUP (0)	;「休みをあげる」実行回数
RUN_SYUKAKUSAI	DW	5 DUP (0)	;「収穫祭」実行回数
RUN_MONTH	DW	60 DUP (0)	;「月１イベント」実行回数

PARA_COUNTER_END	LABEL	WORD	; parameter counter end.

; ****************************************************
;	隠しパラメータ
; ****************************************************
;
;
;	1=小,2=中,3=大
;
;バストの大中小タイプの分類（ゲームの最初にランダムに決定・バストの成長に影響）
;ヒップの大中小タイプの分類（　　　　　　　〃　　　　　　・ヒップの成長に影響）
;王子との関係		（１～１００）	初期値は０
;父との関係		（１～１００）	初期値は５０
;執事との関係		（１～１００）	初期値は１０
;母性			（１～１００）	初期値は０．誕生日ごとに２上昇．
;モンスター殺戮数	武者修行でモンスターを殺した数．種類は問わず．

PARA_URA_VALUE_TOP	LABEL	WORD	; parameter ura value top.

PUBLIC	URA_BREAST_TYPE			; バストの大中小タイプの分類
PUBLIC	URA_HIP_TYPE			; ヒップの大中小タイプの分類
PUBLIC	URA_PRINCE			; 王子との関係
PUBLIC	URA_FATHER			; 父との関係
PUBLIC	URA_STEWARD			; 執事との関係
PUBLIC	URA_MOTHER_LOVE			; 母性
PUBLIC	URA_KILL_MONSTR			; モンスター殺戮数

URA_BREAST_TYPE	DW	0		; バストの大中小タイプの分類
URA_HIP_TYPE	DW	0		; ヒップの大中小タイプの分類
URA_PRINCE	DW	0		; 王子との関係
URA_FATHER	DW	0		; 父との関係
URA_STEWARD	DW	0		; 執事との関係
URA_MOTHER_LOVE	DW	0		; 母性
URA_KILL_MONSTR	DW	0		; モンスター殺戮数

PARA_URA_VALUE_END	LABEL	WORD	; parameter ura value end.

; ****************************************************
;	条件判定
; ****************************************************
;
;
;	その他イベント発生条件
;
;E_ETC[0]
;E_ETC[1]「幼精霊の訪問」発生条件
;E_ETC[2]「妾」状態
;E_ETC[3]「妾」お金
;E_ETC[4] 技能アップの祝福・戦士評価・回数
;E_ETC[5] 技能アップの祝福・魔法評価・回数
;E_ETC[6] 技能アップの祝福・社交評価・回数
;E_ETC[7] 技能アップの祝福・家事評価・回数
;E_ETC[8]「極楽鳥の誕生」発生条件
;E_ETC[9]「無駄遣い」実行中
;E_ETC[10]ｲﾍﾞﾝﾄ「生意気なドラゴンに会う」で若いドラゴンと戦って勝つ．
;E_ETC[11]「道場破り」で「剣術」の稽古が出来ない
;E_ETC[12]「道場破り」で「格闘術」の稽古が出来ない
;E_ETC[13]ただ食い第１旬に料理屋ただ働き
;E_ETC[14]「父の誕生日」をチェックした年齢
;E_ETC[15]追い剥ぎ回数
;E_ETC[16]前科取り調べ時の追い剥ぎ回数
;E_ETC[17]「亡霊騎士」に勝つ
;E_ETC[18]「娘の誕生日」をチェックした年齢
;E_ETC[19]お尋ね者・捕縛・バナザード(1=逮捕,2=賞金)
;E_ETC[20]お尋ね者・捕縛・バニスター(1=逮捕,2=賞金)
;E_ETC[21]お尋ね者・捕縛・カスティーヨ(1=逮捕,2=賞金)
;E_ETC[22]お尋ね者・賞金額・バナザード
;E_ETC[23]お尋ね者・賞金額・バニスター
;E_ETC[24]お尋ね者・賞金額・カスティーヨ
;E_ETC[25]精霊の泉枯れた
;E_ETC[26]武者修行中に１度エルフに出会った
;E_ETC[27]精霊が消えた月
;E_ETC[28]ＲＰＧの直前のイベント番号
;E_ETC[29]竜の谷に入った
;E_ETC[30]武神の祠閉鎖
;E_ETC[31]武神に勝った
;E_ETC[32]北の武神への階段が消える
;E_ETC[33]武者修行中に１度ｻﾝﾄﾞﾚｲﾀﾞｰｽを倒した
;E_ETC[34]祠閉鎖に山岳警備隊
;E_ETC[35]強制的に「ムダ使い」が発生する
;E_ETC[36]最新の「お城へ行く」月
;E_ETC[37]最新の「お城へ行く」年
;E_ETC[38]最新の「娘と話す」月
;E_ETC[39]最新の「娘と話す」年
;E_ETC[40]色気ﾊﾟﾗﾒｰﾀの自然増加量
;E_ETC[41]ｱﾆｰﾀ最大ＨＰ
;E_ETC[42]ｱﾆｰﾀ最大ＭＰ
;E_ETC[43]ｱﾆｰﾀ戦意
;E_ETC[44]ｱﾆｰﾀ戦闘技術
;E_ETC[45]ｱﾆｰﾀ攻撃力
;E_ETC[46]ｱﾆｰﾀ防御力
;E_ETC[47]ｱﾆｰﾀ魔法技術
;E_ETC[48]ｱﾆｰﾀ魔力
;E_ETC[49]ｱﾆｰﾀ抗魔力
;E_ETC[50]ｳｪﾝﾃﾞｨｰ最大ＨＰ
;E_ETC[51]ｳｪﾝﾃﾞｨｰ最大ＭＰ
;E_ETC[52]ｳｪﾝﾃﾞｨｰ戦意
;E_ETC[53]ｳｪﾝﾃﾞｨｰ戦闘技術
;E_ETC[54]ｳｪﾝﾃﾞｨｰ攻撃力
;E_ETC[55]ｳｪﾝﾃﾞｨｰ防御力
;E_ETC[56]ｳｪﾝﾃﾞｨｰ魔法技術
;E_ETC[57]ｳｪﾝﾃﾞｨｰ魔力
;E_ETC[58]ｳｪﾝﾃﾞｨｰ抗魔力
;E_ETC[59]最近の武闘会勝った回数
;E_ETC[60]娘の絵の点数
;E_ETC[61]ﾊﾟﾄﾚｲｼｱ年齢
;E_ETC[62]ﾊﾟﾄﾚｲｼｱ体力
;E_ETC[63]ﾊﾟﾄﾚｲｼｱ色気
;E_ETC[64]ﾊﾟﾄﾚｲｼｱ芸術
;E_ETC[65]ｼﾞｭﾘｴｯﾀ年齢
;E_ETC[66]ﾌｨｵﾘﾅ年齢
;E_ETC[67]ｱｰﾆｽ年齢
;E_ETC[68]ﾗﾝﾌｧﾝ年齢
;E_ETC[69]ｼﾞｪﾆﾌｧｰ年齢
;E_ETC[70]ﾌﾗﾝｿﾜ年齢
;E_ETC[71]ﾅﾀｰｼｬ年齢
;E_ETC[72]ﾏﾙｼｱ年齢
;E_ETC[73]ﾏﾙｼｱ感受性
;E_ETC[74]ﾏﾙｼｱ料理
;E_ETC[75]ﾄｰﾍﾞ年齢
;E_ETC[76]恋愛開始年
;E_ETC[77]恋愛開始月
;E_ETC[78]恋愛開始日
;E_ETC[79]月次処理済みの最新月
;E_ETC[80]15歳以上で「老ドラゴンに会う」回数
;E_ETC[81]ﾊﾞｶﾝｽの値段
;E_ETC[82]幼精霊卵返却年
;E_ETC[83]幼精霊卵返却月
;E_ETC[84]幼精霊卵返却日
;E_ETC[85]「魔王の酒盛り」魔王に能力ＵＰ回数
;E_ETC[86]ドラゴンユースのプロポーズを承知する
;E_ETC[87]最新俸給年
;E_ETC[88]最新俸給月
;E_ETC[89]最新俸給日
;E_ETC[90]最新の「お城へ行く」日
;E_ETC[91]最新の「娘と話す」日
;E_ETC[92]武者修行中に１度妖精のお茶会
;E_ETC[93]武者修行中に１度妖精のダンスパーティー
;E_ETC[94]武者修行中に１度お尋ね者と遭遇
;E_ETC[95]武者修行中に１度精霊に出会う
;E_ETC[96]武者修行中に１度老ドラゴンに会う
;E_ETC[97]武者修行中に１度精霊猫に会う
;E_ETC[98]武者修行中に１度魔王の酒盛り
;E_ETC[99]
;E_ETC[100]通常攻撃時ﾀﾞﾒｰｼﾞ合計
;E_ETC[101]魔法攻撃時ﾀﾞﾒｰｼﾞ合計
;E_ETC[102]お尋ね者通常攻撃ﾀﾞﾒｰｼﾞ合計
;E_ETC[103]お尋ね者魔法攻撃ﾀﾞﾒｰｼﾞ合計
;E_ETC[104]最新料理食い年
;E_ETC[105]最新料理食い月
;E_ETC[106]最新料理食い日
;E_ETC[107]執事ｱﾙﾊﾞｲﾄ増加の説明年
;E_ETC[108]「瀕死の重態」連続月
;E_ETC[109]RPG帰りは出口から
;E_ETC[110]RPG帰りは出口から回数
;
;宝箱・東
;FLG_TAKARA[1]
;FLG_TAKARA[2]
;FLG_TAKARA[3]
;宝箱・西
;FLG_TAKARA[4]
;FLG_TAKARA[5]
;FLG_TAKARA[6]
;FLG_TAKARA[7]
;宝箱・南
;FLG_TAKARA[8]
;FLG_TAKARA[9]
;FLG_TAKARA[10]
;宝箱・北
;FLG_TAKARA[11]
;FLG_TAKARA[12]
;FLG_TAKARA[13]

PARA_EVENT_TOP		LABEL	WORD	; parameter event top.

PUBLIC	E_RIVAL				;ライバル登場
PUBLIC	E_KAISIN			;会心の一撃発生倍率２倍
PUBLIC	E_KEN				;ｲﾍﾞﾝﾄ｢恩賜の剣売却事件｣発生条件
PUBLIC	E_COOL				;ｲﾍﾞﾝﾄ｢厳寒」
PUBLIC	E_HOT				;ｲﾍﾞﾝﾄ｢猛暑」
PUBLIC	E_COLX				;ｲﾍﾞﾝﾄ｢厳寒｣の被害を防ぐ
PUBLIC	E_HOTX				;ｲﾍﾞﾝﾄ｢猛暑｣の被害を防ぐ
PUBLIC	E_SEIREI			;ｲﾍﾞﾝﾄ｢精霊に出会う｣発生条件
PUBLIC	E_UNICOON			;ｲﾍﾞﾝﾄ｢ユニコーンを発見｣発生条件
PUBLIC	E_DEVIL				;ｲﾍﾞﾝﾄ｢悪魔に出会う｣発生条件
PUBLIC	E_BENUS				;ｲﾍﾞﾝﾄ｢ビーナスの祝福｣発生条件
PUBLIC	E_CAT				;ｲﾍﾞﾝﾄ｢精霊猫に会う｣発生条件
PUBLIC	E_MERMAID			;ｲﾍﾞﾝﾄ｢マーメイドに会う｣発生条件
PUBLIC	E_PROPOSAL			;ｲﾍﾞﾝﾄ｢プロポーズ｣毎月発生
PUBLIC	E_COOK_WIN			;ｲﾍﾞﾝﾄ｢料理コンクール｣優勝出来る
PUBLIC	E_EAT_EGG			;ｲﾍﾞﾝﾄ｢極楽鳥の卵を食べる｣発生条件
PUBLIC	E_MAX_MP			;ＭＰが減らない
PUBLIC	E_RWAY				;ｲﾍﾞﾝﾄ｢家出」
PUBLIC	E_EV_SKIP			;イベントスキップ
PUBLIC	E_ETC				;その他ｲﾍﾞﾝﾄ発生条件
PUBLIC	FLG_TAKARA			; 宝箱フラグ

E_RIVAL		DW	0		;ライバル登場
					;0=いない,1=戦士,2=魔法,3=社交,4=家事
E_KAISIN	DW	0		;会心の一撃発生倍率２倍
E_KEN		DW	0		;ｲﾍﾞﾝﾄ｢恩賜の剣売却事件｣発生条件
E_COOL		DW	0		;ｲﾍﾞﾝﾄ｢厳寒」
E_HOT		DW	0		;ｲﾍﾞﾝﾄ｢猛暑」
E_COLX		DW	0		;ｲﾍﾞﾝﾄ｢厳寒｣の被害を防ぐ
E_HOTX		DW	0		;ｲﾍﾞﾝﾄ｢猛暑｣の被害を防ぐ
E_SEIREI	DW	0		;ｲﾍﾞﾝﾄ｢精霊に出会う｣発生条件
E_UNICOON	DW	0		;ｲﾍﾞﾝﾄ｢ユニコーンを発見｣発生条件
E_DEVIL		DW	0		;ｲﾍﾞﾝﾄ｢悪魔に出会う｣発生条件
E_BENUS		DW	0		;ｲﾍﾞﾝﾄ｢ビーナスの祝福｣発生条件
E_CAT		DW	0		;ｲﾍﾞﾝﾄ｢精霊猫に会う｣発生条件
E_MERMAID	DW	0		;ｲﾍﾞﾝﾄ｢マーメイドに会う｣発生条件
E_PROPOSAL	DW	0		;ｲﾍﾞﾝﾄ｢プロポーズ｣毎月発生
E_COOK_WIN	DW	0		;ｲﾍﾞﾝﾄ｢料理コンクール｣優勝出来る
E_EAT_EGG	DW	0		;ｲﾍﾞﾝﾄ｢極楽鳥の卵を食べる｣発生条件
E_MAX_MP	DW	0		;ＭＰが減らない
E_RWAY		DW	0		;ｲﾍﾞﾝﾄ｢家出」
E_EV_SKIP	DW	0		;イベントスキップ
E_ETC		DW	114 DUP (0)	;その他ｲﾍﾞﾝﾄ発生条件
FLG_TAKARA	DW	14 DUP (0)	; 宝箱フラグ

PARA_EVENT_END		LABEL	WORD	; parameter event end.

; ****************************************************
;	カレンダー
; ****************************************************

PARA_CALENDAR_TOP	LABEL	WORD	; parameter calendar top.

PUBLIC	VAL_YEAR			; 年
PUBLIC	VAL_MONTH			; 月
PUBLIC	VAL_WEEK			; 曜日
PUBLIC	VAL_DAY				; 日
PUBLIC	VAL_A_DAY			; 年内合計日付
PUBLIC	VAL_M_END			; 月末の日
PUBLIC	TM_SEASON			; 季節（1:春,2:夏,3:秋,4:冬）
PUBLIC	FLG_SHOGATSU			; フラグ・正月
PUBLIC	FLG_URUBI			; フラグ・うるう日
PUBLIC	FLG_CHRISTMAS_EVE 		; フラグ・クリスマスイブ
PUBLIC	FLG_G_BORTH			; フラグ・娘の誕生日
PUBLIC	FLG_M_BORTH			; フラグ・私の誕生日
PUBLIC	FLG_HOLIDAY			; フラグ・休日
PUBLIC	FLG_SYUKAKU			; フラグ・収穫祭の準備

VAL_YEAR	DW	1990		; 年
VAL_MONTH	DW	11		; 月
VAL_WEEK	DW	2		; 曜日
VAL_DAY		DW	15		; 日
VAL_A_DAY	DW	0		; 年内合計日付
VAL_M_END	DW	30		; (now)月末の日
TM_SEASON	DW	1		; 季節（1:春,2:夏,3:秋,4:冬）
FLG_SHOGATSU	DW	0		; フラグ・正月
FLG_URUBI	DW	0		; フラグ・うるう日
FLG_CHRISTMAS_EVE DW	0		; フラグ・クリスマスイブ
FLG_G_BORTH	DW	0		; フラグ・娘の誕生日
FLG_M_BORTH	DW	0		; フラグ・私の誕生日
FLG_HOLIDAY	DW	0		; フラグ・休日
FLG_SYUKAKU	DW	0		; フラグ・収穫祭の準備

PARA_CALENDAR_END	LABEL	WORD	; parameter calendar end.

; ****************************************************
;	その他
; ****************************************************

PUBLIC	S_HEALTH_CARE_LEN			; 健康管理長さ
PUBLIC	S_HEALTH_CARE				; 健康管理 string

S_HEALTH_CARE_LEN	DW	ITM_HEALTH_LEN	; 健康管理長さ
S_HEALTH_CARE		DW	HLSTR		; 健康管理 string
HLSTR			DB	"デフォルト",ITM_HEALTH_LEN DUP (0),0,0

PARAMETER_END		LABEL	WORD	; parameter end address.

; *
; ***	ここからセーブデータ範囲外
; *

; ****************************************************
;	スケジュール
; ****************************************************
;
;
; スケジュール項目
;
;	0=娘を鍛える
;	1=娘を働かせる
;	2=武者修行に出す
;	3=休みをあげる
;
; スケジュール内容・娘を鍛える
;
;	0=自然科学
;	1=詩文
;	2=神学
;	3=軍学
;	4=剣術
;	5=格闘術
;	6=魔法
;	7=礼法
;	8=絵画
;	9=舞踊
;
; スケジュール内容・娘を働かせる
;
;	0=家の手伝い
;	1=子守
;	2=宿屋
;	3=農場
;	4=教会
;	5=料理屋
;	6=木コリ
;	7=髪結い
;	8=左官
;	9=狩人
;	10=墓守
;	11=家庭教師
;	12=酒場
;	13=ヤミ酒場
;	14=夜の殿堂
;
; スケジュール内容・武者修行に出す
;
;	0=武者修行に出す
;
; スケジュール内容・休みをあげる
;
;	0=自由行動
;	1=バカンス
;	2=監視
;	3=安静
;	4=サナトリウム
;
; 収穫祭スケジュール
;
;	0=「武闘会」
;	1=「王国芸術祭」
;	2=「ダンスパーティー」
;	3=「お料理コンクール」
;


PUBLIC	SCHED_SECTION			; スケジュール項目
PUBLIC	SCHED_WORKS			; スケジュール内容
PUBLIC	SCH_STARTDAY			; スケジュール開始日
PUBLIC	SCH_ENDDAY			; スケジュール終了日
PUBLIC	SCH_COUNT			; スケジュール数
PUBLIC	SCH_NOW				; スケジュール実行中項目
PUBLIC	SCH_SYUKAKUSAI			; 収穫祭スケジュール

SCHED_SECTION	DW	3 DUP (0)	; スケジュール項目
SCHED_WORKS	DW	3 DUP (0)	; スケジュール内容
SCH_STARTDAY	DW	3 DUP (0)	; スケジュール開始日
SCH_ENDDAY	DW	3 DUP (0)	; スケジュール終了日
SCH_COUNT	DW	0		; スケジュール数
SCH_NOW		DW	0		; スケジュール実行中項目
SCH_SYUKAKUSAI	DW	0		; 収穫祭スケジュール




; ****************************************************
;	エンディング
; ****************************************************
;
;
;ENDNM[0]
;ENDNM[1]	;因業値のランク
;ENDNM[2]	;職業ランク
;ENDNM[3]	;職業分類パターン
;ENDNM[4]	;職業
;ENDNM[5]	;職業　松・竹・梅
;ENDNM[6]	;特殊な結婚勝者
;ENDNM[7]	;敗者の一言
;ENDNM[8]	;結婚パターン
;ENDNM[9]	;結婚のランク
;ENDNM[10]	;一番多く実行した訓練
;ENDNM[11]	;一番多く実行した訓練実行回数
;ENDNM[12]	;一番多く実行した訓練の実行回数のランク
;ENDNM[13]	;一番多く実行したバイト
;ENDNM[14]	;一番多く実行したバイト実行回数
;ENDNM[15]	;一番多く実行したバイトの実行回数のランク
;ENDNM[16]	;基本能力点
;ENDNM[17]	;就職の得点
;ENDNM[18]	;総合点
;ENDNM[19]	;文字送ﾀｲﾏ

PUBLIC	ENDNM			; エンディング

ENDNM	DW	20 DUP (0)	; エンディング


; ****************************************************
;	システム
; ****************************************************
;
;
;IDBG[0]
;IDBG[1]人間ｴﾝｶｳﾝﾄのｽｷｯﾌﾟ
;IDBG[2]ﾓﾝｽﾀｰｴﾝｶｳﾝﾄのｽｷｯﾌﾟ
;IDBG[3]芸術祭の得点一覧
;IDBG[4]娘死なない
;IDBG[5]なんでも屋
;IDBG[6]
;IDBG[7]

PUBLIC	IDBG				; デバッグフラグ

IDBG		DW	10 DUP (0)	; デバッグフラグ

PUBLIC	GOLD_UPPER			; 所持金上限

GOLD_UPPER	LABEL	WORD		; 所持金上限
		DD	100000000	; １億円

DATA	ENDS



STRS_CLEAR	MACRO	SSS,LENG
	PUSH	DS
	POP	ES
	MOV	DI,OFFSET SSS
	MOV	CX,LENG
	MOV	AL,0
	REP	STOSB
	ENDM


CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

; *********************************************************
;	parameter clear.
; *********************************************************

PARA_CLEAR	PROC	NEAR

STRS_CLEAR	PARA_BASEVALUE_TOP,	<PARA_BASEVALUE_END-PARA_BASEVALUE_TOP>

STRS_CLEAR	PARA_TECHVALUE_TOP,	<PARA_TECHVALUE_END-PARA_TECHVALUE_TOP>

STRS_CLEAR	PARA_MONEY_TOP,		<PARA_MONEY_END-PARA_MONEY_TOP>

STRS_CLEAR	PARA_PROFILE_TOP,	<PARA_PROFILE_END-PARA_PROFILE_TOP>

STRS_CLEAR	STR_NM,SHE_NAME_LEN
STRS_CLEAR	STR_FM,FAMILY_NAME_LEN
STRS_CLEAR	STR_NM_01,SHE_NAME_LEN
STRS_CLEAR	STR_FM_01,FAMILY_NAME_LEN

STRS_CLEAR	PARA_BATLE_STATUS_TOP,<PARA_BATLE_STATUS_END-PARA_BATLE_STATUS_TOP>

STRS_CLEAR	PARA_STATUS_TOP,<PARA_STATUS_END-PARA_STATUS_TOP>

MOV	ROOM_PIC,5
MOV	DRESS_NUM,0
MOV	DRESS_ICON,0
MOV	DRESS_GOLD,0
MOV	EQUIP_ICON,0
MOV	EQUIP_GOLD,0
MOV	ARMS_ICON,0
MOV	ARMS_GOLD,0
MOV	ITEM_MAX,0

STRS_CLEAR	ITEM_ICON,50*2
STRS_CLEAR	ITEM_GOLD,50*2
STRS_CLEAR	ITEM_ATTR,50*2

STRS_CLEAR	DNSTR,ITM_NAME_LEN
STRS_CLEAR	DPSTR,ITM_PROG_LEN
STRS_CLEAR	DHSTR,ITM_HELP_LEN
STRS_CLEAR	INMSTR,ITM_NAME_LEN
STRS_CLEAR	IKKSTR,ITM_PROG_LEN
STRS_CLEAR	IHPSTR,ITM_HELP_LEN
STRS_CLEAR	ENMSTR,ITM_NAME_LEN
STRS_CLEAR	EKKSTR,ITM_PROG_LEN
STRS_CLEAR	EHPSTR,ITM_HELP_LEN
STRS_CLEAR	ANMSTR,ITM_NAME_LEN
STRS_CLEAR	AKKSTR,ITM_PROG_LEN
STRS_CLEAR	AHPSTR,ITM_HELP_LEN

STRS_CLEAR	PARA_COUNTER_TOP,<PARA_COUNTER_END-PARA_COUNTER_TOP>

STRS_CLEAR	PARA_URA_VALUE_TOP,<PARA_URA_VALUE_END-PARA_URA_VALUE_TOP>

STRS_CLEAR	PARA_EVENT_TOP,<PARA_EVENT_END-PARA_EVENT_TOP>

STRS_CLEAR	PARA_CALENDAR_TOP,<PARA_CALENDAR_END-PARA_CALENDAR_TOP>

STRS_CLEAR	HLSTR,ITM_HEALTH_LEN

	RET
PARA_CLEAR	ENDP


MEMCLR	PROC	NEAR
	RET
MEMCLR	ENDP

CODE01	ENDS

	END
;
;	end of "PARAMETR.ASM"
;
