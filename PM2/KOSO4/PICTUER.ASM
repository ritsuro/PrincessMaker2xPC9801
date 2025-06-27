; "PICTUER.ASM" PC-9801UV11 make by R.H 1992/05/06
;
;
;	P R I N C E S S   M A K E R   2.
;
;	p i c t u e r.
;
;
;	PICTUER_INIT		; picture init.
;
;	PICTUR			; picture function.(BBCTOOL3.ASM)
;	PT_USER_VTXPRN		; user style print str.
;	PT_FRMFULL		; put full fream.
;	PT_GIRL_FULL		; put girl full.
;	PT_NOW_GIRL_BODY	; now girl body.
;	PT_GIRL_FACEONLY	; put girl face only.
;	PT_GIRL_DAMEG		; put girl dameg.
;	PT_GIRL_WALLX		; put girl back wall.
;	PT_GIRL_BEDX		; put girl back bed.
;	PT_GIRL_PMODE		; put girl put mode.
;	PT_GIRL_SMODE		; put girl draw smooth mode.
;	PT_FACE_GIRL		; put girl face.
;	PT_FACE_SYUGO		; put syugo face.
;	PT_FACE			; put face.
;	PT_YAJI_LD		; put yaji load.
;	PT_YAJI_PT		; put yaji put.
;	PT_PALET_SET		; パレットセット
;
;	PT_CLEND_LD		; calendar load.
;	PT_CLEND_LOC		; calendar locate.
;	PT_CLEND_FRM		; calendar fream.
;	PT_CLEND_YEAR		; calendar year.
;	PT_CLEND_MONTH		; calendar month.
;	PT_CLEND_WEEK		; calendar week.
;	PT_CLEND_DAY		; calendar day.
;
;	PT_SCHED_LD		; schedule load.
;	PT_SCHED_LOC		; schedule locate.
;	PT_SCHED_FRM		; schedule fream.
;	PT_SCHED_YEAR		; schedule year.
;	PT_SCHED_MONTH		; schedule month.
;	PT_SCHED_DAY		; schedule day.
;	PT_SCHED_ICON_CLEAR	; schedule clear.
;
;	PT_PROFILE_LD		; profile load.
;	PT_PROFILE_LOC		; profile locate.
;	PT_PROFILE_FRM		; profile fream.
;	PT_PROFILE_NAME		; profile name.
;	PT_PROFILE_STAR		; profile star.
;	PT_PROFILE_HEALTH	; profile health care.
;	PT_PROFILE_AGE		; profile age.
;	PT_PROFILE_GOLD		; profile gold.
;	PT_PROFILE_ARMS_ICON	; profile arms icon.
;	PT_PROFILE_STATUS_ICON	; profile status icon.
;	PT_PROFILE_BODYSIZE	; profile body size.
;
;	PT_RPGPROF_GOLD		; RPG profile gold.
;	PT_RPGPROF_HP		; RPG profile HP.
;	PT_RPGPROF_MP		; RPG profile MP.
;	PT_RPGPROF_ARMS_ICON	; RPG profile arms icon.
;
;	PT_MINI_FRAME		;各種小さいフレーム
;
;	PT_GRP_GOLD		; graph gold.
;	PT_FRM_KAZARI		;汎用フレームの飾り
;
;	PT_PALET_SETONLY	; パレットテーブルセットのみ
;	PT_PATTERN_LD		; pattern load.
;	PT_PATTERN_LDA		; pattern add load.
;	PT_PATTERN_PUT		; pattern put.
;	PT_MASK_PAT_PUT		; pattern mask put.
;	PT_MASK_PTF_PUT		; pattern mask offset put.
;	PT_MASK_PTX		;マスクパターンＰＵＴ座標指定(BBCTOOL3.ASM)
;	PT_MASK_PTF		;マスクパターンＰＵＴオフセット(BBCTOOL3.ASM)
;	PT_PATTERN_BANK		; pattern bank set.
;	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.
;	PT_PATTERN_CLEAR	; parts buffer clear.
;	PT_PATTERN_GET		; parts get.
;	PT_PATTERN_MODE		; parts put mode.
;
;	パレット	(data:"PATTAN.ASM","PALET.PT1")
;
;		 0=PM2_1.ALG	通常
;		 1=PM2_E.ALG	ＲＰＧ・東
;		 2=PM2_W.ALG	ＲＰＧ・西
;		 3=PM2_S.ALG	ＲＰＧ・南
;		 4=PM2_N.ALG	ＲＰＧ・北
;		 5=PM2_E2.ALG	ＲＰＧ・東・夜
;		 6=PM2_W2.ALG	ＲＰＧ・西・夜
;		 7=PM2_S2.ALG	ＲＰＧ・南・夜
;		 8=PM2_N2.ALG	ＲＰＧ・北・夜
;		 9=PM2-V1.ALG	バカンス山・春夏秋
;		10=PM2-V2.ALG	バカンス山・冬
;		11=PM2-V3.ALG	バカンス海・夏
;		12=PM2-V4.ALG	バカンス海・秋
;		13=PM2-V5.ALG	バカンス海・冬
;		14=NAMEFATH.ALG	名前入力・父
;		15=NAMEGIRL.ALG	名前入力・娘
;
;	娘
;
;	　　内　容		ファイル名	データ形式
;
;	girl body.1=細		GIRL10A1	mask data.
;	girl body.2=太		GIRL10A2	mask data.
;
;	girl face.1=基本	GIRL10F1	mask data.
;	girl face.2=非行	GIRL10F2	mask data.
;	girl face.3=病気	GIRL10F3	mask data.
;	girl face.4=元気	GIRL10F4	mask data.
;	girl face.5=色気	GIRL10F5	mask data.
;
;	girl breast.1=細	GIRL10B1	mask data.
;	girl breast.2=太	GIRL10B2	mask data.
;
;	girl dameg.1=重病	GIRL10X1	mask data.
;
;
;	服・普段着
;
;	　　内　容		ファイル名	データ形式
;
;	girl dress base1.1=細	DR1X10A1	mask data.
;	girl dress base1.2=太	DR1X10A2	mask data.
;	girl dress bast1.1=細	DR1X10B1	mask data.
;	girl dress bast1.2=太	DR1X10B2	mask data.
;
;
;	服・夏物の服
;
;	　　内　容		ファイル名	データ形式
;
;	girl dress base1.1=細	DR2X10A1	mask data.
;	girl dress base1.2=太	DR2X10A2	mask data.
;	girl dress bast1.1=細	DR2X10B1	mask data.
;	girl dress bast1.2=太	DR2X10B2	mask data.
;
;
;	服・冬物の服
;
;	　　内　容		ファイル名	データ形式
;
;	girl dress base1.1=細	DR3X10A1	mask data.
;	girl dress base1.2=太	DR3X10A2	mask data.
;	girl dress bast1.1=細	DR3X10B1	mask data.
;	girl dress bast1.2=太	DR3X10B2	mask data.
;
;
;	服・木綿のドレス
;
;	　　内　容		ファイル名	データ形式
;
;	girl dress base1.1=細	DR4X10A1	mask data.
;	girl dress base1.2=太	DR4X10A2	mask data.
;	girl dress bast1.1=細	DR4X10B1	mask data.
;	girl dress bast1.2=太	DR4X10B2	mask data.
;
;
;	服・シルクのドレス
;
;	　　内　容		ファイル名	データ形式
;
;	girl dress base1.1=細	DR5X10A1	mask data.
;	girl dress base1.2=太	DR5X10A2	mask data.
;	girl dress bast1.1=細	DR5X10B1	mask data.
;	girl dress bast1.2=太	DR5X10B2	mask data.
;
;
;	服・レーザーのドレス
;
;	　　内　容		ファイル名	データ形式
;
;	girl dress base1.1=細	DR6X10A1	mask data.
;	girl dress base1.2=太	DR6X10A2	mask data.
;	girl dress bast1.1=細	DR6X10B1	mask data.
;	girl dress bast1.2=太	DR6X10B2	mask data.
;
;
;	服・トゲトゲの服
;
;	　　内　容		ファイル名	データ形式
;
;	girl dress base1.1=細	DR7X10A1	mask data.
;	girl dress base1.2=太	DR7X10A2	mask data.
;	girl dress bast1.1=細	DR7X10B1	mask data.
;	girl dress bast1.2=太	DR7X10B2	mask data.
;
;
;	服・傾国のローブ
;
;	　　内　容		ファイル名	データ形式
;
;	girl dress base1.1=細	DR8X10A1	mask data.
;	girl dress base1.2=太	DR8X10A2	mask data.
;	girl dress bast1.1=細	DR8X10B1	mask data.
;	girl dress bast1.2=太	DR8X10B2	mask data.
;
;
;	服・見えないドレス
;
;	　　内　容		ファイル名	データ形式
;
;	girl dress base1.1=細	DR9X10A1	mask data.
;	girl dress base1.2=太	DR9X10A2	mask data.
;	girl dress bast1.1=細	DR9X10B1	mask data.
;	girl dress bast1.2=太	DR9X10B2	mask data.
;
;
;	服・悪魔のドレス
;
;	　　内　容		ファイル名	データ形式
;
;	girl dress base1.1=細	DRAX10A1	mask data.
;	girl dress base1.2=太	DRAX10A2	mask data.
;	girl dress bast1.1=細	DRAX10B1	mask data.
;	girl dress bast1.2=太	DRAX10B2	mask data.
;
;
;	服・龍のレオタード
;
;	　　内　容		ファイル名	データ形式
;
;	girl dress base1.1=細	DRBX10A1	mask data.
;	girl dress base1.2=太	DRBX10A2	mask data.
;	girl dress bast1.1=細	DRBX10B1	mask data.
;	girl dress bast1.2=太	DRBX10B2	mask data.
;
;
;	娘フェイスウインドウ
;
;	　　内　容		ファイル名	データ形式
;
;	10-13歳 普通		FACE10A		pattern data.
;	10-13歳 嬉しい		FACE10B		pattern data.
;	10-13歳 怒り		FACE10C		pattern data.
;	10-13歳 悲しい		FACE10D		pattern data.
;	10-13歳 暑い		FACE10E		pattern data.
;	10-13歳 寒い		FACE10F		pattern data.
;	10-13歳 大怪我		FACE10G		pattern data.
;	10-13歳 苦しい		FACE10H		pattern data.
;	10-13歳 すねる		FACE10I		pattern data.
;	10-13歳 不思議		FACE10J		pattern data.
;	10-13歳 恥らう		FACE10K		pattern data.
;	10-13歳 不安		FACE10L		pattern data.
;	10-13歳 不愉快		FACE10M		pattern data.
;	10-13歳 妖しい		FACE10N		pattern data.
;	10-13歳 りりしい	FACE10O		pattern data.
;	10-13歳 驚き		FACE10P		pattern data.
;	10-13歳 ガーン		FACE10Q		pattern data.
;	10-13歳 真剣		FACE10R		pattern data.
;	10-13歳 困り		FACE10S		pattern data.
;
;	14-17歳 普通		FACE14A		pattern data.
;	14-17歳 嬉しい		FACE14B		pattern data.
;	14-17歳 怒り		FACE14C		pattern data.
;	14-17歳 悲しい		FACE14D		pattern data.
;	14-17歳 暑い		FACE14E		pattern data.
;	14-17歳 寒い		FACE14F		pattern data.
;	14-17歳 大怪我		FACE14G		pattern data.
;	14-17歳 苦しい		FACE14H		pattern data.
;	14-17歳 すねる		FACE14I		pattern data.
;	14-17歳 不思議		FACE14J		pattern data.
;	14-17歳 恥らう		FACE14K		pattern data.
;	14-17歳 不安		FACE14L		pattern data.
;	14-17歳 不愉快		FACE14M		pattern data.
;	14-17歳 妖しい		FACE14N		pattern data.
;	14-17歳 りりしい	FACE14O		pattern data.
;	14-17歳 驚き		FACE14P		pattern data.
;	14-17歳 ガーン		FACE14Q		pattern data.
;	14-17歳 真剣		FACE14R		pattern data.
;	14-17歳 困り		FACE14S		pattern data.
;
;
; public subroutine.

INCLUDE	TSTSET.INC
INCLUDE	WINDOWS.INC

BNK_NORMAL	EQU	0		; normal bank.
BNK_HARF	EQU	5		; harf buffer 32,764byte
BNK_FACE	EQU	5;4		; face bank.
BNK_YAJI	EQU	13		; RPG direction botton bank.
BNK_CLEND	EQU	15		; calendar bank.
BNK_SCHED	EQU	3		; schedule bank.
BNK_PROFILE	EQU	3		; profile bank.

P_BANK_ICON	EQU	100		; icon.
P_BANK_PALET	EQU	101		; palet.

P_NUM_FXCLND	EQU 0			; pattn number calendar.
P_NUM_FXBIGN	EQU 1			; pattn number big number.
P_NUM_FXMONTH	EQU 1+10		; pattn number month.
P_NUM_FXWEEK	EQU 1+10+12		; pattn number week.
P_NUM_FXNUM	EQU 1+10+12+7		; pattn number number.
P_NUM_FXCOVER	EQU 1+10+12+7+10	; pattn number profile cover.
P_NUM_FXBLOOD	EQU 1+10+12+7+10+2	; pattn number profile blood.
P_NUM_FXMIDN	EQU 1+10+12+7+10+2+8	; pattn number mid number.
P_NUM_FXUNIT	EQU 1+10+12+7+10+2+8+10	; pattn number unit mark.
P_NUM_FXKAZA	EQU 1+10+12+7+10+2+8+10+1	; pattn number kazari.

P_NUM_FXSCHD	EQU	0		; pattn number schedule.
P_NUM_FXSCMSK	EQU	1		; pattn number days mask.
P_NUM_FXSCDAY	EQU	1+2		; pattn number days cover.

P_NUM_FXPROF	EQU	0		; pattn number profile.

CLEND_YEAR_X	EQU	7		; locate calendar year.
CLEND_YEAR_Y	EQU	8		; locate calendar year.

CLEND_MONTH_X	EQU	1		; locate calendar month.
CLEND_MONTH_Y	EQU	32		; locate calendar month.

CLEND_WEEK_X	EQU	1		; locate calendar week.
CLEND_WEEK_Y	EQU	56		; locate calendar week.

CLEND_DAY_X	EQU	9		; locate calendar day.
CLEND_DAY_Y	EQU	32		; locate calendar day.

SCHED_YEAR_X	EQU	9		; locate schedule year.
SCHED_YEAR_Y	EQU	8		; locate schedule year.

SCHED_MONTH_X	EQU	15		; locate schedule month.
SCHED_MONTH_Y	EQU	8		; locate schedule month.

SCHED_DAY_X	EQU	9		; locate schedule day.
SCHED_DAY_Y	EQU	32		; locate schedule day.

PROF_FS_NAME_X	EQU	2		; locate profile first name.
PROF_FS_NAME_Y	EQU	9		; locate profile first name.

PROF_FM_NAME_X	EQU	2		; locate profile family name.
PROF_FM_NAME_Y	EQU	26		; locate profile family name.

PROF_STAR_X	EQU	5		; locate profile star.
PROF_STAR_Y	EQU	54		; locate profile star.

PROF_HEALTH_X	EQU	2		; locate profile health.
PROF_HEALTH_Y	EQU	132		; locate profile health.

PROF_AGE_X	EQU	1		; locate profile age.
PROF_AGE_Y	EQU	64		; locate profile age.

PROF_GOLD_X	EQU	10		; locate profile gold.
PROF_GOLD_Y	EQU	70		; locate profile gold.

PROF_G_UNIT_X	EQU	10+7		; locate profile gold.
PROF_G_UNIT_Y	EQU	70		; locate profile gold.

PROF_ICON_X	EQU	0		; locate profile icon.
PROF_ICON_Y	EQU	93;34		; locate profile icon.

PROF_BODYSIZE_X	EQU	2		; locate profile bodysize.
PROF_BODYSIZE_Y	EQU	150		; locate profile bodysize.

MOVXB	MACRO	DEST,SOU
	MOV	AL,SOU
	MOV	DEST,AL
	ENDM

; ***********************************************
;	define string -> offset.
; ***********************************************

STRS	MACRO	RRR,STRING
	LOCAL	L1
DATA	SEGMENT	PUBLIC	'DATA'
	EVEN
L1	DB	STRING,0
	EVEN
DATA	ENDS
	MOV	RRR,OFFSET L1
	ENDM

; ***********************************************
;	P_BANK	<bank_number>
;	parts bank chenge.
; ***********************************************

P_BANK	MACRO	NNN
	PUSH	DX
	MOV	DX,NNN			; バンク番号（０ー１）
	EXTRN	C1PATBNK:NEAR		; バンクチェンジ
	CALL	C1PATBNK		; バンクチェンジ
	POP	DX
	ENDM

; ***********************************************
;	FILE_CALL	<file_name>
;	file name call -> load.
; ***********************************************

FILE_CALL	MACRO	FNAME
	LOCAL	L1
DATA	SEGMENT	PUBLIC	'DATA'
L1	DB	"&FNAME",0
DATA	ENDS
FNAME	PROC	NEAR
	MOV	SI,OFFSET L1
	EXTRN	C1PATLDA:NEAR
	CALL	C1PATLDA		; パーツ追加ロード
	RET
FNAME	ENDP
	ENDM

; ***********************************************
;	P I C T U E R S   F I L E .
; ***********************************************

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

CODE01	ENDS

; ***********************************************
;	P U T   L O G I C .
; ***********************************************

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

; ***********************************************
;	picture init.
; ***********************************************

FUNC_w	PICTUER_INIT
	CALL	PT_CLEND_LD		; calendar load.
	RET
FEND_w	PICTUER_INIT


; ***********************************************
;	picture function.(BBCTOOL3.ASM)
;	-I- AX : function.
;		AX=1 : 部屋の絵PUT
;			BX:絵画の番号
;		AX=2 : 正常->病気
;		AX=3 : 病気->正常
;		AX=4 : direct病気
;		AX=5 : direct正常
;		AX=6 : 水平点線
;			BX : start dot point x1.
;			CX : end dot point x2.
;			DX : line hight y1.
;			SI : line width.
;			DI : color.
;			BP : line bit pattern.
;		AX=7 : 水平ライン
;			BX : start dot point x1.
;			CX : end dot point x2.
;			DX : line hight y1.
;			SI : line width.
;			DI : color.
;		AX=8 : VRAMを仮想VRAM(40*400)へ転送
;			BX : vram x.
;			CX : vram y.
;			DX : vvram x.
;			SI : vvram y.
;			DI : size x.
;			BP : size y.
;		AX=9 : 仮想VRAM(40*400)をVRAMへ転送
;			BX : vvram x.
;			CX : vvram y.
;			DX : vram x.
;			SI : vram y.
;			DI : size x.
;			BP : size y.
;		AX=10 : 仮想VRAM(40*400)間転送
;			BX : vvram x.
;			CX : vvram y.
;			DX : vvram x.
;			SI : vvram y.
;			DI : size x.
;			BP : size y.
;		AX=11 : ﾊﾟﾀｰﾝPUTを仮想VRAM(40*400)へアサイン
;		AX=12 : ﾊﾟﾀｰﾝPUTをVRAMへアサイン
;		AX=13 : 仮想VRAM(40*400)をVRAMへオーバラップ転送
;			BX : vram x.
;			CX : vram y.
;			DX : vvram x.
;			SI : vvram y.
;			DI : size x.
;			BP : size y.
;		AX=14 : 娘の顔ファイル名
;			BX : girl age.
;			CX : girl face.
;		    -O- SI : file name.
;		AX=15 : 標準文字描画
;			BX : x.
;			CX : y.
;			SI : file name.
;		AX=16 : 標準文字設定
;			BX : color 0-15
;			CX : size.0=16x16  1=32x32  2=16x24  3=16x32
;			DX : type.0=pset,1=OR,2=fuchi.
;		AX=17 : フレーム・ﾕｰｻﾞｰﾌﾚｰﾑ
;			BX : frame type.
;			CX : 表示位置Ｘ
;			DX : 表示位置Ｙ
;			SI : 大きさＸ
;			DI : 大きさＹ
;		AX=18 : BOX
;			BX : x1.
;			CX : y1.
;			DX : x2.
;			SI : y2.
;			DI : color.
;		AX=19 : パレットセット
;			BX : color code.
;			CX : color.
;			DX : contrast.
;			SI : brightness.
;		AX=20 : パレット単色ＰＵＴ
;			BX : パレットテーブル番号
;			CX : パレット番号
;			DX : color.
;			SI : contrast.
;			DI : brightness.
;
;		ARA001 : 仮想ＶＲＡＭプレーン 40*400
;
; ***********************************************

FUNC_w	PICTUR
	CMP	AL,1			;
	JE	PICTUR_01N		;
	CMP	AL,2			;
	JE	PICTUR_02N		;
	CMP	AL,3			;
	JE	PICTUR_03N		;
	CMP	AL,4			;
	JE	PICTUR_04N		;
	CMP	AL,5			;
	JE	PICTUR_05N		;
	CMP	AL,6			;
	JE	PICTUR_06N		;
	CMP	AL,7			;
	JE	PICTUR_07N		;

	CMP	AL,8			;
	JE	PICTUR_08N		;
	CMP	AL,9			;
	JE	PICTUR_09N		;
	CMP	AL,10			;
	JE	PICTUR_10N		;
	CMP	AL,11			;
	JE	PICTUR_11N		;
	CMP	AL,12			;
	JE	PICTUR_12N		;
	CMP	AL,13			;
	JE	PICTUR_13N		;
	CMP	AL,14			;
	JE	PICTUR_14N		;
	CMP	AL,15			;
	JE	PICTUR_15N		;
	CMP	AL,16			;
	JE	PICTUR_16N		;

	CMP	AL,17			;
	JE	PICTUR_17N		;
	CMP	AL,18			;
	JE	PICTUR_18N		;
	CMP	AL,19			;
	JE	PICTUR_19N		;
	CMP	AL,20			;
	JE	PICTUR_20N		;

	RET				;
PICTUR_01N:				;
	CMP	BX,PICMAX		; 絵画の数
	JNB	PICTUR_EXIT		;

	MOV	PICNUM,BX		; 絵画の番号

	CALL	FILE_INIT		; ロード初期化
	CALL	MYROOM_PIC_LDA		; my room picture apend load.

	MOV	AX,1			; 1=パターンＰＵＴオーバラップ
	CALLE	C1PATEFC		; パーツＰＵＴエフェクト

	MOV	NUM,0			; パターン番号
	CALL	MYROOM_PIC_PUT		; my room picture put.

	MOV	AX,0			; 0=通常
	CALLE	C1PATEFC		; パーツＰＵＴエフェクト
	RET
PICTUR_02N:				;
	MOV	GIRL_LL_MODE,1		; girl normal<->dameg smooth put mode.
	CALL	PT_GIRL_DAMEG		; put girl dameg.
	MOV	GIRL_LL_MODE,0		; girl normal<->dameg smooth put mode.
	RET
PICTUR_03N:				;
	MOV	GIRL_LL_MODE,1		; girl normal<->dameg smooth put mode.
	CALL	PT_GIRL_FULL		; put girl full.
	MOV	GIRL_LL_MODE,0		; girl normal<->dameg smooth put mode.
	RET
PICTUR_04N:				; direct病気
	CALL	PT_GIRL_DAMEG		; put girl dameg.
	RET
PICTUR_05N:				; direct正常
	CALL	PT_GIRL_FULL		; put girl full.
	RET
PICTUR_06N:				; direct正常
	MOV	VX1,BX			; start dot point x1.
	MOV	VX2,CX			; end dot point x2.
	MOV	VY1,DX			; line hight y1.
	MOV	CX,SI			; line width.
	MOV	VCOL,DI			; color.
	MOV	AX,BP			; line bit pattern.
	CALLE	DLINEHBT		; 水平ライン描画点線
	RET
PICTUR_07N:
	MOV	VX1,BX			; start dot point x1.
	MOV	VX2,CX			; end dot point x2.
	MOV	VY1,DX			; line hight y1.
	MOV	CX,SI			; line width.
	MOV	VCOL,DI			; color.
	CALLE	DLINEH			; 水平ライン描画
	RET

PICTUR_08N:				; AX=8 : VRAMを仮想VRAM(40*400)へ転送
	CALL	XY_SET			; x,y set.
	CALL	ID_S_SET_VRM		; SSSOU0 <- ARAVRM
	CALL	ID_D_SET_V001		; SSDES0 <- ARA001
	CALLE	MOVEVR			; vram to vram move.
	RET

PICTUR_09N:				; AX=9 : 仮想VRAM(40*400)をVRAMへ転送
	CALL	XY_SET			; x,y set.
	CALL	ID_S_SET_V001		; SSSOU0 <- ARA001
	CALL	ID_D_SET_VRM		; SSDES0 <- ARAVRM
	CALLE	MOVEVR			; vram to vram move.
	RET

PICTUR_10N:				; AX=10 : 仮想VRAM(40*400)間転送
	CALL	XY_SET			; x,y set.
	CALL	ID_S_SET_V001		; SSSOU0 <- ARA001
	CALL	ID_D_SET_V001		; SSDES0 <- ARA001
	CALLE	MOVEVR			; vram to vram move.
	RET

PICTUR_11N:
	CALL	ID_GR_SET_V001		; SGR0 <- ARA001
	RET
PICTUR_12N:
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	RET
PICTUR_13N:
	CALL	XY_SET			; x,y set.
	CALL	ID_S_SET_V001		; SSSOU0 <- ARA001
	CALL	ID_D_SET_VRM		; SSDES0 <- ARAVRM
	CALLE	OVLAP			; オーバラップ
	RET
PICTUR_14N:
	MOV	WD_GIRL_AGE,BX		; girl age.
	MOV	WD_FACE_GIRL,CX		; girl face.
	CALL	PT_FACE_GIRL_FLNM	; girl face file name.
	RET
PICTUR_15N:
	CALL	PT_USER_VTXPRN		; user style print str.
	RET
PICTUR_16N:
	MOV	USER_CHR_COLOR,BX	; character color 0-15
	MOV	USER_CHR_SIZE,CX	; char size.
	MOV	USER_CHR_TYPE,DX	; char type.0=pset,1=OR,2=fuchi.
	RET
PICTUR_17N:
	MOV	AX,BX			; frame type.
	MOV	WDX1,CX			; 表示位置Ｘ
	MOV	WDY1,DX			; 表示位置Ｙ
	MOV	WDX2,SI			; 大きさＸ
	MOV	WDY2,DI			; 大きさＹ
	CALLE	WID_FLAME_USER		; フレーム・ﾕｰｻﾞｰﾌﾚｰﾑ
	RET
PICTUR_18N:
	MOV	VX1,BX			; start point.
	MOV	VY1,CX			; start point.
	MOV	VX2,DX			; end point.
	MOV	VY2,SI			; end point.
	MOV	CX,DI			; color palet number.
	CALL	ID_EFC_SET_VRM		; SSEFC0 <- ARAVRM
	CALLE	BOXPAL			; ＢＯＸペイント
	RET
PICTUR_19N:
	MOV	CLRCDE,BX		; color code.
	MOV	CLRVEW,CX		; color view.
	MOV	CLRCNS,DX		; contrast.
	MOV	CLRBRI,SI		; brightness.
	CALLE	C1SETCLR		; color table set.
	CALLE	C1CLRVSET		; color palet table disply.
	RET
PICTUR_20N:
					; BX: パレットテーブル番号
					; CX: パレット番号
	MOV	CLRVEW,DX		; color.
	MOV	CLRCNS,SI		; contrast.
	MOV	CLRBRI,DI		; brightness.
	CALLE	C1PL1PUT		; パレット単色ＰＵＴ
	RET
PICTUR_EXIT:
	RET
FEND_w	PICTUR


; ***********************************************
;	user style print str.
;	-I- BX : x.
;	    CX : y.
;	    SI : string.
; ***********************************************

FUNC_w	PT_USER_VTXPRN
	PUSH	BX			; x.
	PUSH	CX			; y.
	PUSH	SI			; string.
	MOV	AX,USER_CHR_SIZE	; char size.
	CALL	VTXSIZ			; character size set.
	MOV	AX,USER_CHR_COLOR	; character color 0-15
	CALL	VTXCOL			; character color set.
	POP	SI			; string.
	POP	BX			; y.
	POP	AX			; x.
	CMP	USER_CHR_TYPE,0		; char type.0=pset.
	JE	PT_USER_VTXPRN_1	;
	CMP	USER_CHR_TYPE,1		; char type.1=OR.
	JE	PT_USER_VTXPRN_2	;
	CMP	USER_CHR_TYPE,2		; char type.2=fuchi.
	JE	PT_USER_VTXPRN_3	;
PT_USER_VTXPRN_1:
	CALLE	VTXPRN			; vram text print.
	RET
PT_USER_VTXPRN_2:
	CALLE	VTXPOR			; vram text print OR.
	RET
PT_USER_VTXPRN_3:
	CALLE	VTXPFC			; vram text print fuchi.
	RET
FEND_w	PT_USER_VTXPRN


; ***********************************************
;	x,y set.
; ***********************************************

XY_SET	PROC	NEAR
	MOV	VX1,BX			; source point x1.
	MOV	VY1,CX			; source point y1.
	MOV	VX3,DX			; dest point x2.
	MOV	VY3,SI			; dest point y2.
	MOV	VX2,DI			; size x.
	MOV	VY2,BP			; size y.
	RET
XY_SET	ENDP


; ***********************************************
;	put full fream.
;	-I- BX : 1=娘の部屋
;	         2=武者修行
;		50=RPG用HPMP
; ***********************************************

FUNC_w	PT_FRMFULL
	CMP	BX,50
	JE	PT_FRMFULL_RPG_HPMP

	CMP	BX,2
	JNBE	PT_FRMFULL_EXIT

	PUSH	BX
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_NORMAL		; normal bank.
	CALL	FILE_INIT		; ロード初期化
	POP	BX

	PUSH	BX

	DEC	BX			; -1
	SHL	BX,1			; word pointer.

	MOV	SI,FRMNAMEL[BX]		; fream L file.
	PUSH	FRMNAMER[BX]		; fream R file.
	CALLE	C1PATLDA		; パーツ追加ロード
	POP	SI			;
	CALLE	C1PATLDA		; パーツ追加ロード

	POP	BX

	CMP	BX,1			; 1=娘の部屋
	JNE	PT_FRMFULL_5		;

	MOV	SI,OFFSET FRM1M		; fream : 娘の部屋mid
	CALLE	C1PATLDA		; パーツ追加ロード
	MOV	NUM,0			; パターン番号
	CALL	PATTAN_PUT		; パターンＰＵＴ
	MOV	NUM,1			; パターン番号
	CALL	PATTAN_PUT		; パターンＰＵＴ
	MOV	NUM,2			; パターン番号
	CALL	PATTAN_PUT		; パターンＰＵＴ

	CALL	FILE_INIT		; ロード初期化
	MOVX	PICNUM,ROOM_PIC		; 部屋の絵
	CALL	MYROOM_PIC_LDA		; my room picture apend load.
	MOV	NUM,0			; パターン番号
	CALL	MYROOM_PIC_PUT		; my room picture put.
	RET

PT_FRMFULL_5:				;
	STRS	SI,"FXHPMP"		;
	CALLE	C1PATLDA		; パーツ追加ロード
	MOV	NUM,0			; パターン番号
	CALL	PATTAN_PUT		; パターンＰＵＴ
	MOV	NUM,1			; パターン番号
	CALL	PATTAN_PUT		; パターンＰＵＴ
	MOV	NUM,2			; パターン番号
	CALL	PATTAN_PUT		; パターンＰＵＴ

	MOV	XX1,77			; ＰＵＴＸ座標
	MOV	YY1,107			; ＰＵＴＹ座標
	MOV	NUM1,0			; unit.0=GOLD
	CALL	PT_P_UNIT		; parameter unit.
	JMP	PT_FRMFULL_EXIT
PT_FRMFULL_RPG_HPMP:
	PUSH	BX
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_NORMAL		; normal bank.
	CALL	FILE_INIT		; ロード初期化
	POP	BX

	STRS	SI,"FXHPMP"		;
	CALLE	C1PATLDA		; パーツ追加ロード
	MOV	NUM,0			; パターン番号
	CALL	PATTAN_PUT		; パターンＰＵＴ
	MOV	XX1,77			; ＰＵＴＸ座標
	MOV	YY1,107			; ＰＵＴＹ座標
	MOV	NUM1,0			; unit.0=GOLD
	CALL	PT_P_UNIT		; parameter unit.
	JMP	PT_FRMFULL_EXIT
PT_FRMFULL_EXIT:
	RET
FEND_w	PT_FRMFULL


; ***********************************************
;	put girl full.
;	-I- WD_GIRL_AGE   : girl age.
;	    WD_GIRL_BODY  : girl body.1=細,2=太
;	    WD_GIRL_FACE  : girl face.1=基本,2=非行,3=病気,4=元気,5=色気
;	    WD_GIRL_BREAST: girl breast.0=無,1=有
;	    WD_GIRL_DRESS : girl dress.
;	    WD_GIRL_DRESS_BODY  : girl dress body.1=細,2=太
;	    WD_GIRL_DRESS_BREAST: girl dress breast.0=無,1=有
; ***********************************************

FUNC_w	PT_GIRL_FULL
	MOVX	PIC_NOW_GIRL_BODY_AGE,WD_GIRL_AGE	; girl show body age.

	MOV	GIRL_PUT_ADJAST_X,-20	; girl put adjast x.
	MOV	GIRL_PUT_ADJAST_Y,0	; girl put adjast y.

	CALL	ID_GR_SET_V001		; SGR0 <- ARA001
	CALL	PT_GIRL_WALL		; put girl wall.
	CALL	PT_GIRL_BODY		; put girl body.
	CALL	PT_GIRL_BREAST		; put girl breast.
	CALL	PT_GIRL_FACE		; put girl face.

	CMP	WD_GIRL_DRESS,2		; 2=服・夏物の服
	JNE	PT_GIRL_FULL_5		;
	CMP	WD_GIRL_DRESS_BREAST,1	; girl dress breast.0=無,1=有
	JNE	PT_GIRL_FULL_5		;
	CALL	PT_GIRL_DRESS_BREAST	; put girl dress breast.
	JMP	PT_GIRL_FULL_6		;
PT_GIRL_FULL_5:
	CALL	PT_GIRL_DRESS		; put girl dress.
	CALL	PT_GIRL_DRESS_BREAST	; put girl dress breast.
PT_GIRL_FULL_6:

	CMP	GIRL_LL_MODE,0		; girl normal<->dameg smooth put mode.
	JNE	PT_GIRL_FULL_SMS	;

	CMP	GIRL_PUT_MODE,1		; girl put mode.0=normal,1=o.l.
	JE	PT_GIRL_FULL_OL		;

	CALL	PT_GIRL_FULL_COPY_AS	; copy assign.
	CALLE	MOVEVR			; vram to vram move.
	JMP	PT_GIRL_FULL_EXIT	;

PT_GIRL_FULL_OL:
	CALL	PT_GIRL_FULL_COPY_AS	; copy assign.
	CALLE	OVLAP			; オーバラップ
	JMP	PT_GIRL_FULL_EXIT	;

PT_GIRL_FULL_SMS:
	CALL	GIRL_DAMEG_CLR		; 病気娘のクリア

PT_GIRL_FULL_EXIT:
	RET
FEND_w	PT_GIRL_FULL


; ***********************************************
;	now girl body.
;	-O- DX : girl show body age.
; ***********************************************

FUNC_w	PT_NOW_GIRL_BODY
	MOV	DX,PIC_NOW_GIRL_BODY_AGE	; girl show body age.
	RET
FEND_w	PT_NOW_GIRL_BODY


; ***********************************************
;	put girl face only.
;	-I- WD_GIRL_AGE   : girl age.
;	    WD_GIRL_BODY  : girl body.1=細,2=太
;	    WD_GIRL_FACE  : girl face.1=基本,2=非行,3=病気,4=元気,5=色気
;	    WD_GIRL_BREAST: girl breast.0=無,1=有
;	    WD_GIRL_DRESS : girl dress.
;	    WD_GIRL_DRESS_BODY  : girl dress body.1=細,2=太
;	    WD_GIRL_DRESS_BREAST: girl dress breast.0=無,1=有
; ***********************************************

FUNC_w	PT_GIRL_FACEONLY
	MOV	GIRL_PUT_ADJAST_X,-29	; girl put adjast x.
	MOV	GIRL_PUT_ADJAST_Y,0	; girl put adjast y.

	CALL	ID_S_SET_VRM		; SSSOU0 <- ARAVRM
	CALL	ID_D_SET_V001		; SSDES0 <- ARA001
	MOV	VX1,29			; source point.
	MOV	VY1,0	;29		; source point.
	MOV	VX2,17			; data size.
	MOV	VY2,147	+29		; data size.
	MOV	VX3,0			; dest point.
	MOV	VY3,0			; dest point.
	CALLE	MOVEVR			; vram to vram move.

	CALL	ID_GR_SET_V001		; SGR0 <- ARA001
	CALL	PT_GIRL_FACE		; put girl face.

	CALL	ID_S_SET_V001		; SSSOU0 <- ARA001
	CALL	ID_D_SET_VRM		; SSDES0 <- ARAVRM
	MOV	VX1,0			; source point.
	MOV	VY1,0			; source point.
	MOV	VX2,17			; data size.
	MOV	VY2,147	+29		; data size.
	MOV	VX3,29			; dest point.
	MOV	VY3,0			; dest point.

	CMP	GIRL_PUT_MODE,1		; girl put mode.0=normal,1=o.l.
	JE	PT_GIRL_FACEONLY_OL	;
	CALLE	MOVEVR			; vram to vram move.
	RET
PT_GIRL_FACEONLY_OL:
	CALLE	OVLAP			; オーバラップ
	RET
FEND_w	PT_GIRL_FACEONLY


; ***********************************************
;	copy assign.
; ***********************************************

PT_GIRL_FULL_COPY_AS	PROC	NEAR
	CALL	ID_S_SET_V001		; SSSOU0 <- ARA001
	CALL	ID_D_SET_VRM		; SSDES0 <- ARAVRM
	MOV	VX1,0			; source point.
	MOV	VY1,0			; source point.
	MOV	VX2,38			; data size.
	MOV	VY2,400			; data size.
	MOV	VX3,20			; dest point.
	MOV	VY3,0			; dest point.
	RET
PT_GIRL_FULL_COPY_AS	ENDP


; ***********************************************
;	病気娘のクリア
; ***********************************************

GIRL_DAMEG_CLR	PROC	NEAR
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_NORMAL		; normal bank.

	CALL	FILE_INIT		; ロード初期化
 	MOV	SI,FRMNAMER[0]		; fream R file.
	CALLE	C1PATLDA		; パーツ追加ロード

	CALLE	FEDOUT			; Ｆ・Ｏ（フェードアウト）

	MOV	VRPX,0			; ＧＥＴ Ｘ座標
	MOV	VRPY,200			; ＧＥＴ Ｙ座標
	MOV	VRLENPX,22		; ＧＥＴ Ｘサイズ
	MOV	VRLENPY,200		; ＧＥＴ Ｙサイズ
	CALL	C1PLSVIW		; ＰＵＴＶＩＥＷの設定

	MOV	NUM,0			; パターン番号
	MOV	XX1,58			; x.
	MOV	YY1,200			; y.
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定

	CALL 	C1PLSVWS		; ＰＵＴＶＩＥＷの解除

	CALL	PT_GIRL_FULL_COPY_AS	; copy assign.
	CALLE	MOVEVR			; vram to vram move.

	CALLE	FEDIN			; Ｆ・Ｉ（フェードイン）
	RET
GIRL_DAMEG_CLR	ENDP


; ***********************************************
;	put girl dameg.
;	-I- WD_GIRL_AGE : girl age.
; ***********************************************

FUNC_w	PT_GIRL_DAMEG
	MOV_ID2	SSGR0,ARA003		; 仮想ＶＲＡＭプレーン(width60)
	CALL	PT_GIRL_WALL60X		; put girl wall width60.
	CALL	PT_GIRL_SLEEP_BED	; put girl sleep bed.

	CMP	GIRL_LL_MODE,0		; girl normal<->dameg smooth put mode.
	JNE	PT_GIRL_DAMEG_SMS	;

	CMP	GIRL_PUT_MODE,1		; girl put mode.0=normal,1=o.l.
	JE	PT_GIRL_DAMEG_OL	;

	CALL	PT_GIRL_DAMEG_COPY_AS	; copy assign.
	CALLE	MOVEVR			; vram to vram move.
	JMP	PT_GIRL_DAMEG_EXIT	;

PT_GIRL_DAMEG_OL:
	CALL	PT_GIRL_DAMEG_COPY_AS	; copy assign.
	CALLE	OVLAP			; オーバラップ
	JMP	PT_GIRL_DAMEG_EXIT	;

PT_GIRL_DAMEG_SMS:
	CALL	GIRL_NORMAL_CLR		; 正常・娘のクリア

PT_GIRL_DAMEG_EXIT:
	RET
FEND_w	PT_GIRL_DAMEG


; ***********************************************
;	copy assign.
; ***********************************************

PT_GIRL_DAMEG_COPY_AS	PROC	NEAR
	MOV_ID2	SSSOU0,ARA003		; source data segment.
	CALL	ID_D_SET_VRM		; SSDES0 <- ARAVRM
	MOV	VX1,0			; source point.
	MOV	VY1,0			; source point.
	MOV	VX2,60			; data size.
	MOV	VY2,200			; data size.
	MOV	VX3,20			; dest point.
	MOV	VY3,200			; dest point.
	RET
PT_GIRL_DAMEG_COPY_AS	ENDP


; ***********************************************
;	正常・娘のクリア
; ***********************************************

GIRL_NORMAL_CLR	PROC	NEAR
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM

	P_BANK	BNK_HARF		; harf buffer 32,764byte
	CALL	FILE_INIT		; ロード初期化
	MOVX	PICNUM,ROOM_PIC		; 部屋の絵
	CALL	MYROOM_PIC_LDA		; my room picture apend load.

	CALLE	FEDOUT			; Ｆ・Ｏ（フェードアウト）

	P_BANK	BNK_NORMAL		; normal bank.
	MOV	NUM,0			; パターン番号
	CALL	PATTAN_PUT		; パターンＰＵＴ

	P_BANK	BNK_HARF		; harf buffer 32,764byte
	MOV	NUM,0			; パターン番号
	CALL	MYROOM_PIC_PUT		; my room picture put.

	CALL	PT_GIRL_DAMEG_COPY_AS	; copy assign.
	CALLE	MOVEVR			; vram to vram move.

	CALLE	FEDIN			; Ｆ・Ｉ（フェードイン）
	RET
GIRL_NORMAL_CLR	ENDP


; ***********************************************
;	put girl back wall.
; ***********************************************

FUNC_w	PT_GIRL_WALLX
	MOV	GIRL_PUT_ADJAST_X,-20	; girl put adjast x.
	MOV	GIRL_PUT_ADJAST_Y,0	; girl put adjast y.

	CALL	ID_GR_SET_V001		; SGR0 <- ARA001
	CALL	PT_GIRL_WALL		; put girl wall.

	CMP	GIRL_PUT_MODE,1		; girl put mode.0=normal,1=o.l.
	JE	PT_GIRL_WALLX_OL	;

	CALL	PT_GIRL_FULL_COPY_AS	; copy assign.
	CALLE	MOVEVR			; vram to vram move.
	JMP	PT_GIRL_WALLX_OL_EXIT	;

PT_GIRL_WALLX_OL:
	CALL	PT_GIRL_FULL_COPY_AS	; copy assign.
	CALLE	OVLAP			; オーバラップ
PT_GIRL_WALLX_OL_EXIT:
	RET
FEND_w	PT_GIRL_WALLX


; ***********************************************
;	put girl back bed.
; ***********************************************

FUNC_w	PT_GIRL_BEDX
	MOV_ID2	SSGR0,ARA003		; 仮想ＶＲＡＭプレーン(width60)
	CALL	PT_GIRL_WALL60X		; put girl wall width60.

	CMP	GIRL_PUT_MODE,1		; girl put mode.0=normal,1=o.l.
	JE	PT_GIRL_BEDX_OL		;

	CALL	PT_GIRL_DAMEG_COPY_AS	; copy assign.
	CALLE	MOVEVR			; vram to vram move.

	JMP	PT_GIRL_BEDX_EXIT	;

PT_GIRL_BEDX_OL:
	CALL	PT_GIRL_DAMEG_COPY_AS	; copy assign.
	CALLE	OVLAP			; オーバラップ

PT_GIRL_BEDX_EXIT:
	RET
FEND_w	PT_GIRL_BEDX


; ***********************************************
;	put girl put mode.
;	-I- AX : girl put mode.0=normal,1=o.l.
; ***********************************************

FUNC_w	PT_GIRL_PMODE
	MOV	GIRL_PUT_MODE,AX	; girl put mode.0=normal,1=o.l.
	RET
FEND_w	PT_GIRL_PMODE


; ***********************************************
;	put girl draw smooth mode.
;	-I- AX : girl normal<->dameg smooth put mode.0=normal,1=smooth.
; ***********************************************

FUNC_w	PT_GIRL_SMODE
	MOV	GIRL_LL_MODE,AX		; girl normal<->dameg smooth put mode.
	RET
FEND_w	PT_GIRL_SMODE


; ***********************************************
;	put girl face.
;	-I- WD_GIRL_AGE  : girl age.
;	    WD_FACE_GIRL : girl face.
;	    AX           : put x
;	    BX           : put y
; ***********************************************

FUNC_w	PT_FACE_GIRL
	MOV	XX1,AX			; X.
	MOV	YY1,BX			; Y.

	CALL	PT_FACE_GIRL_FLNM	; 娘の顔ファイル名

	MOV	AX,XX1			; X.
	MOV	BX,YY1			; Y.
	CALL	PT_FACE			; put face.
	RET
FEND_w	PT_FACE_GIRL


; ***********************************************
;	娘の顔ファイル名
;	-I- WD_GIRL_AGE  : girl age.
;	    WD_FACE_GIRL : girl face.
;	-O- SI : file name.
; ***********************************************

PT_FACE_GIRL_FLNM	PROC	NEAR
	CMP	WD_GIRL_AGE,13		; girl age.
	JNBE	PT_FACE_GIRL_14_17	;
PT_FACE_GIRL_10_13:
	STRS	SI,"FACE10A"
	JMP	PT_FACE_GIRL_PUT
PT_FACE_GIRL_14_17:
	STRS	SI,"FACE14A"
PT_FACE_GIRL_PUT:
	MOV	AX,WD_FACE_GIRL		; girl face.
	ADD	AL,'A'			;
	MOV	BYTE PTR DS:[SI][6],AL	;
	RET
PT_FACE_GIRL_FLNM	ENDP


; ***********************************************
;	put syugo face.
;	-I- WD_FACE_SYUGO: syugosei face.
;	    AX           : put x
;	    BX           : put y
; ***********************************************

FUNC_w	PT_FACE_SYUGO
	MOV	XX1,AX			; X.
	MOV	YY1,BX			; Y.

	STRS	DI,"F1xx"

	MOV	DX,WD_FACE_SYUGO	; syugosei face.
	ADD	DX,87			;
	CALL	DECSTR			;
	MOVX	DS:[DI][2],DS:[SI][3]	;"00087"

	MOV	SI,DI			;
	MOV	AX,XX1			; X.
	MOV	BX,YY1			; Y.
	CALL	PT_FACE			; put face.
	RET
FEND_w	PT_FACE_SYUGO


; ***********************************************
;	put face.
;	-I- AX : put x
;	    BX : put y
;	    SI : file name.
; ***********************************************

FUNC_w	PT_FACE
	MOV	XX1,AX			; X.
	MOV	YY1,BX			; Y.
	MOV	FLNAME_ADRS,SI		; file name.

	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM

	P_BANK	BNK_FACE		; face bank.

	CALL	FILE_INIT		; ロード初期化

	MOV	SI,FLNAME_ADRS		; file name.
	CALL	C1PATLDA		; パーツ追加ロード

	MOV	NUM,0			; パターン番号
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定

	RET
FEND_w	PT_FACE


; ***********************************************
;	put yaji load.
; ***********************************************

FUNC_w	PT_YAJI_LD
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_YAJI		; RPG direction botton bank.
	CALL	FILE_INIT		; ロード初期化
	STRS	SI,"FXYAJI"		;
	CALL	C1PATLDA		; パーツ追加ロード
	RET
FEND_w	PT_YAJI_LD


; ***********************************************
;	put yaji put.
;	-I- CX : 1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ
;	    DX : 0=OFF,1=ON.
; ***********************************************

FUNC_w	PT_YAJI_PT
	DEC	CX			;
	MOV	NUM,CX			; パターン番号
	CMP	DX,0			; 0=OFF,1=ON.
	JE	PT_YAJI_PT_2		;
	ADD	NUM,5			; パターン番号
PT_YAJI_PT_2:				;
	P_BANK	BNK_YAJI		; RPG direction botton bank.
	CALL	PATTAN_PUT		; パターンＰＵＴ
	RET
FEND_w	PT_YAJI_PT


; ***********************************************
;	パレットセット
;	-I- AX : パーツ番号
; ***********************************************

FUNC_w	PT_PALET_SET
	MOV	NUM,AX

	P_BANK	P_BANK_PALET		; palet.

	MOV	CX,NUM			; パーツ番号
	MOV	BX,0			; パレットテーブル番号
	CALLE	C1PLTPAT		; パーツバッファからパレットを取り出す

	CALLE	NORMIN		; ノーマルカラー

;*;	MOV	BX,0			; パレットテーブル番号
;*;	CALLE	C1PLSET			; パレットセット
	RET
FEND_w	PT_PALET_SET


; ***********************************************
;	calendar load.
; ***********************************************

FUNC_w	PT_CLEND_LD
	P_BANK	BNK_CLEND		; calendar bank.
	CALL	FILE_INIT		; ロード初期化

;	カレンダーデータ
;calendar frame		FXCLND   PT1      2506 93-03-05   23:51
;big number 0-9		FXBIGN   PT1      1576 92-12-11   17:37
;month string 1-12	FXMONTH  PT1      2962 92-12-11   17:41
;week string sun - sat	FXWEEK   PT1      1546 92-12-11   17:39
;small number 0-9	FXNUM    PT1       634 92-12-11   17:29
;					  9224 byte
;
;profile cover		FXCOVER  PT1       926 93-03-06    0:09
;blood type symbole	FXBLOOD  PT1       836 92-12-15   19:00
;mid size number 0-9	FXMIDN   PT1       934 92-12-16   15:49
;unit mark		FXUNIT   PT1       118 92-12-18   13:49 (2882 byte)
;kazari			FXKAZA   PT1      1698 93-03-06   19:08
;					  4512 byte
;
;				total	 13736 byte
;
;	サイズが増えたら"KS2TBL.ASM"のDATBIN2を変更すること
;
;	DATBIN2	SEGMENT	PUBLIC	'DATBIN2'
;	DATBIN2_TOP	LABEL	BYTE
;		DB	12800 DUP (?)
;	DATBIN2_END	LABEL	BYTE
;	DATBIN2	ENDS
;

	STRS	SI,"FXCLND"		;
	CALLE	C1PATLDA		; パーツ追加ロード
	STRS	SI,"FXBIGN"		;
	CALLE	C1PATLDA		; パーツ追加ロード
	STRS	SI,"FXMONTH"		;
	CALLE	C1PATLDA		; パーツ追加ロード
	STRS	SI,"FXWEEK"		;
	CALLE	C1PATLDA		; パーツ追加ロード
	STRS	SI,"FXNUM"		;
	CALLE	C1PATLDA		; パーツ追加ロード
	STRS	SI,"FXCOVER"		;
	CALLE	C1PATLDA		; パーツ追加ロード
	STRS	SI,"FXBLOOD"		;
	CALLE	C1PATLDA		; パーツ追加ロード
	STRS	SI,"FXMIDN"		;
	CALLE	C1PATLDA		; パーツ追加ロード
	STRS	SI,"FXUNIT"		;
	CALLE	C1PATLDA		; パーツ追加ロード
	STRS	SI,"FXKAZA"		;
	CALLE	C1PATLDA		; パーツ追加ロード
	RET
FEND_w	PT_CLEND_LD


; ***********************************************
;	calendar locate.
;	-I- AX : locate calendar base.
;	    BX : locate calendar base.
; ***********************************************

FUNC_w	PT_CLEND_LOC
	MOV	CLEND_BASE_X,AX		; locate calendar base.
	MOV	CLEND_BASE_Y,BX		; locate calendar base.
	RET
FEND_w	PT_CLEND_LOC


; ***********************************************
;	calendar fream.
; ***********************************************

FUNC_w	PT_CLEND_FRM
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_CLEND		; calendar bank.

	MOV	AX,CLEND_BASE_X		; locate calendar base.
	MOV	BX,CLEND_BASE_Y		; locate calendar base.
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標
	MOV	NUM,P_NUM_FXCLND	; pattn number calendar.
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定
	RET
FEND_w	PT_CLEND_FRM


; ***********************************************
;	calendar year.
;	-I- DX : year.
; ***********************************************

FUNC_w	PT_CLEND_YEAR
	MOV	NUM_YEAR,DX		; year.

	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_CLEND		; calendar bank.

	MOV	AX,CLEND_BASE_X		; locate calendar base.
	MOV	BX,CLEND_BASE_Y		; locate calendar base.
	ADD	AX,CLEND_YEAR_X		; locate calendar year.
	ADD	BX,CLEND_YEAR_Y		; locate calendar year.
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標

	MOV	AX,NUM_YEAR		; year.
	MOV	DX,0			;
	MOV	NUM1,4			; character length.
	CALL	PUT_NUMBER		; number.
	RET
FEND_w	PT_CLEND_YEAR


; ***********************************************
;	calendar month.
;	-I- DX : month.
; ***********************************************

FUNC_w	PT_CLEND_MONTH
	MOV	NUM_MONTH,DX		; month.

	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_CLEND		; calendar bank.

	MOV	AX,CLEND_BASE_X		; locate calendar base.
	MOV	BX,CLEND_BASE_Y		; locate calendar base.
	ADD	AX,CLEND_MONTH_X	; locate calendar month.
	ADD	BX,CLEND_MONTH_Y	; locate calendar month.
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標

	CALL	MONTH_PUT		; month put.
	RET
FEND_w	PT_CLEND_MONTH


; ***********************************************
;	calendar week.
;	-I- DX : week.
; ***********************************************

FUNC_w	PT_CLEND_WEEK
	MOV	NUM_WEEK,DX		; week.

	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_CLEND		; calendar bank.

	MOV	AX,CLEND_BASE_X		; locate calendar base.
	MOV	BX,CLEND_BASE_Y		; locate calendar base.
	ADD	AX,CLEND_WEEK_X		; locate calendar week.
	ADD	BX,CLEND_WEEK_Y		; locate calendar week.
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標

	MOV	AX,NUM_WEEK		; week.
	ADD	AX,P_NUM_FXWEEK		; pattn number week.
	MOV	NUM,AX			;
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定
	RET
FEND_w	PT_CLEND_WEEK


; ***********************************************
;	calendar day.
;	-I- DX : day.
; ***********************************************

FUNC_w	PT_CLEND_DAY
	CMP	DX,100
	JNB	PT_CLEND_DAY_EXIT
	MOV	NUM_DAY,DX		; day.

	MOV	AX,NUM_DAY		; day.
	MOV	BL,10			;
	DIV	BL			; / 10

	PUSH	AX			;

	MOV	BYTE PTR NUM1,AL	; number.

	MOV	AX,CLEND_BASE_X		; locate calendar base.
	MOV	BX,CLEND_BASE_Y		; locate calendar base.
	ADD	AX,CLEND_DAY_X		; locate calendar day.
	ADD	BX,CLEND_DAY_Y		; locate calendar day.
	MOV	XX1,AX			;
	MOV	YY1,BX			;

	CMP	NUM1,0			;
	JE	PT_CLEND_DAY_4		;

	CALL	PT_BIG_NUMBER		; big number.

	ADD	XX1,4			; + 4

	JMP	PT_CLEND_DAY_5		;
PT_CLEND_DAY_4:
	CALL	ID_EFC_SET_VRM		; SSEFC0 <- ARAVRM

	MOV	AX,XX1			;
	MOV	BX,YY1			;
	MOV	VX1,AX			;
	MOV	VY1,BX			;
	ADD	AX,7			;
	ADD	BX,39			;
	MOV	VX2,AX			;
	MOV	VY2,BX			;
	MOV	CX,0			; color palet number.
	CALLE	BOXPAL			; ＢＯＸペイント

	ADD	XX1,2			; + 2
PT_CLEND_DAY_5:

	POP	AX

	MOV	BYTE PTR NUM1,AH	; number.

	CALL	PT_BIG_NUMBER		; big number.

PT_CLEND_DAY_EXIT:
	RET
FEND_w	PT_CLEND_DAY


; ***********************************************
;	schedule load.
; ***********************************************

FUNC_w	PT_SCHED_LD
	P_BANK	BNK_SCHED		; schedule bank.
	CALL	FILE_INIT		; ロード初期化

;schedule frame		FXSCHD   PT1      1612 92-12-12   17:40
;schedule frame		FXSCMSK  PT1       168 92-12-12   17:43
;schedule clear pattern	FXSCDAY  PT1       164 92-12-15   15:13
;					  1944 byte

	STRS	SI,"FXSCHD"		;
	CALLE	C1PATLDA		; パーツ追加ロード
	STRS	SI,"FXSCMSK"		;
	CALLE	C1PATLDA		; パーツ追加ロード
	STRS	SI,"FXSCDAY"		;
	CALLE	C1PATLDA		; パーツ追加ロード

	RET
FEND_w	PT_SCHED_LD


; ***********************************************
;	schedule locate.
;	-I- AX : locate schedule base.
;	    BX : locate schedule base.
; ***********************************************

FUNC_w	PT_SCHED_LOC
	MOV	SCHED_BASE_X,AX		; locate schedule base.
	MOV	SCHED_BASE_Y,BX		; locate schedule base.
	RET
FEND_w	PT_SCHED_LOC


; ***********************************************
;	schedule fream.
; ***********************************************

FUNC_w	PT_SCHED_FRM
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_SCHED		; schedule bank.

	MOV	AX,SCHED_BASE_X		; locate schedule base.
	MOV	BX,SCHED_BASE_Y		; locate schedule base.
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標
	MOV	NUM,P_NUM_FXSCHD	; pattn number schedule.
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定
	RET
FEND_w	PT_SCHED_FRM


; ***********************************************
;	schedule year.
;	-I- DX : year.
; ***********************************************

FUNC_w	PT_SCHED_YEAR
	MOV	NUM_YEAR,DX		; year.

	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_CLEND		; calendar bank.

	MOV	AX,SCHED_BASE_X		; locate schedule base.
	MOV	BX,SCHED_BASE_Y		; locate schedule base.
	ADD	AX,SCHED_YEAR_X		; locate schedule year.
	ADD	BX,SCHED_YEAR_Y		; locate schedule year.
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標

	MOV	AX,NUM_YEAR		; year.
	MOV	DX,0			;
	MOV	NUM1,4			; character length.
	CALL	PUT_NUMBER		; number.
	RET
FEND_w	PT_SCHED_YEAR


; ***********************************************
;	schedule month.
;	-I- DX : month.
; ***********************************************

FUNC_w	PT_SCHED_MONTH
	MOV	NUM_MONTH,DX		; month.

	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_CLEND		; calendar bank.

	MOV	AX,SCHED_BASE_X		; locate schedule base.
	MOV	BX,SCHED_BASE_Y		; locate schedule base.
	ADD	AX,SCHED_MONTH_X	; locate schedule month.
	ADD	BX,SCHED_MONTH_Y	; locate schedule month.
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標
	CALL	MONTH_PUT		; month put.

	RET
FEND_w	PT_SCHED_MONTH


; ***********************************************
;	month put.
;	-I- NUM_MONTH : month.
;	    XX1       : ＰＵＴＸ座標
;	    YY1       : ＰＵＴＹ座標
; ***********************************************

MONTH_PUT	PROC	NEAR
	MOV	AX,NUM_MONTH		; month.
	ADD	AX,P_NUM_FXMONTH	; pattn number month.
	DEC	AX			; -1
	MOV	NUM,AX			;
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定
	RET
MONTH_PUT	ENDP


; ***********************************************
;	schedule day.
;	-I- DX : day.
;	    AX : put x
;	    BX : put y
; ***********************************************

FUNC_w	PT_SCHED_DAY
	MOV	XX1,AX			; X.
	MOV	YY1,BX			; Y.
	MOV	NUM_DAY,DX		; day.

	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_SCHED		; schedule bank.
	MOV	NUM,P_NUM_FXSCMSK	; pattn number days mask.
	CALL	MASK_PTX		; マスクパターンＰＵＴ座標指定

	ADD	XX1,2			;
	ADD	YY1,14			;

	CMP	NUM_DAY,10		; day.
	JNB	PT_SCHED_DAY_5		;

	MOVX	NUM1,NUM_DAY		; day.
	CALL	PT_S_MID_NUMBER		; mid number.(schedule load)

	JMP	PT_SCHED_DAY_9		;

PT_SCHED_DAY_5:
	MOV	AX,NUM_DAY		; day.
	MOV	DX,0			;
	MOV	NUM1,2			; character length.
	CALL	PUT_NUMBER		; number.
PT_SCHED_DAY_9:
	RET
FEND_w	PT_SCHED_DAY


; ***********************************************
;	schedule clear.
;	-I- AX : put x
;	    BX : put y
; ***********************************************

FUNC_w	PT_SCHED_ICON_CLEAR
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標

	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_SCHED		; schedule bank.

	MOV	NUM,P_NUM_FXSCDAY	; pattn number days cover.
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定
	RET
FEND_w	PT_SCHED_ICON_CLEAR


; ***********************************************
;	profile load.
; ***********************************************

FUNC_w	PT_PROFILE_LD
	P_BANK	BNK_PROFILE		; profile bank.
	CALL	FILE_INIT		; ロード初期化

	STRS	SI,"FXPROF"		;
	CALLE	C1PATLDA		; パーツ追加ロード
	RET
FEND_w	PT_PROFILE_LD


; ***********************************************
;	profile locate.
;	-I- AX : locate profile base.
;	    BX : locate profile base.
; ***********************************************

FUNC_w	PT_PROFILE_LOC
	MOV	PROFILE_BASE_X,AX	; locate profile base.
	MOV	PROFILE_BASE_Y,BX	; locate profile base.
	RET
FEND_w	PT_PROFILE_LOC


; ***********************************************
;	profile fream.
; ***********************************************

FUNC_w	PT_PROFILE_FRM
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_PROFILE		; profile bank.

	MOV	AX,PROFILE_BASE_X	; locate profile base.
	MOV	BX,PROFILE_BASE_Y	; locate profile base.
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標
	MOV	NUM,P_NUM_FXPROF	; pattn number profile.
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定

	MOV	AX,PROFILE_BASE_X	; locate profile base.
	MOV	BX,PROFILE_BASE_Y	; locate profile base.
	ADD	AX,PROF_G_UNIT_X	; locate profile gold.
	ADD	BX,PROF_G_UNIT_Y	; locate profile gold.
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標
	MOV	NUM1,0			; unit.0=GOLD
	CALL	PT_P_UNIT		; parameter unit.
	RET
FEND_w	PT_PROFILE_FRM


; ***********************************************
;	profile name.
;	-I- SI : string first name.
;	    BX : string family name.
; ***********************************************

FUNC_w	PT_PROFILE_NAME
	MOV	STR_FIRST_NAME,SI	; string first name.
	MOV	STR_FAMILY_NAME,BX	; string family name.

	MOV	AX,0			; グラフ文字表示サイズ
	CALLE	VTXSIZ			; character size set.

	MOV	AX,1			; グラフ文字表示色
	CALLE	VTXCOL			; character color set.

	MOVX	ES,DS			;
	MOV	DI,STR_FIRST_NAME	; string first name.
	CALLE	STRLENSPZ		; 文字列長さスペースまで
	MOV	AX,8*2
	SUB	AX,CX			; 表示単語長さ
	SHR	AX,1			; /2
	ADD	AX,PROFILE_BASE_X	; locate profile base.
	MOV	BX,PROFILE_BASE_Y	; locate profile base.
	ADD	AX,PROF_FS_NAME_X	; locate profile first name.
	ADD	BX,PROF_FS_NAME_Y	; locate profile first name.
	MOV	SI,STR_FIRST_NAME	; string first name.
	CALLE	VTXPOR			; vram text print OR.

	MOVX	ES,DS			;
	MOV	DI,STR_FAMILY_NAME	; string family name.
	CALLE	STRLENSPZ		; 文字列長さスペースまで
	MOV	AX,8*2
	SUB	AX,CX			; 表示単語長さ
	SHR	AX,1			; /2
	ADD	AX,PROFILE_BASE_X	; locate profile base.
	MOV	BX,PROFILE_BASE_Y	; locate profile base.
	ADD	AX,PROF_FM_NAME_X	; locate profile family name.
	ADD	BX,PROF_FM_NAME_Y	; locate profile family name.
	MOV	SI,STR_FAMILY_NAME	; string family name.
	CALLE	VTXPOR			; vram text print OR.

	RET
FEND_w	PT_PROFILE_NAME


; ***********************************************
;	profile star.
;	-I- AX : 血液型
;	    BX : 守護星
; ***********************************************

FUNC_w	PT_PROFILE_STAR
	MOV	PROF_BLOOD,AX		; 血液型
	MOV	PROF_STAR,BX		; 守護星

	MOV	AX,PROFILE_BASE_X	; locate profile base.
	MOV	BX,PROFILE_BASE_Y	; locate profile base.
	ADD	AX,PROF_STAR_X		; locate profile star.
	ADD	BX,PROF_STAR_Y		; locate profile star.
	MOV	XX1,AX			; ＰＵＴ　Ｘ座標
	MOV	YY1,BX			; ＰＵＴ　Ｙ座標

	MOV	DX,PROF_STAR		; 守護星
	ADD	DX,88			; 88=太陽,89=月,90=火星...
	CALLE	ICON_PUT		; ICON put.

	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_CLEND		; calendar bank.

	MOV	AX,PROF_BLOOD		; 血液型
	SHL	AX,1			; word pointer.
	ADD	AX,P_NUM_FXBLOOD	; pattn number profile blood.
	MOV	NUM,AX			; パターン番号
	CALL	MASK_PTX		; マスクパターンＰＵＴ座標指定

	RET
FEND_w	PT_PROFILE_STAR


; ***********************************************
;	profile health care.
;	-I- SI : string.
; ***********************************************

FUNC_w	PT_PROFILE_HEALTH
	MOV	STRADRS,SI		; string.

	CALL	ID_EFC_SET_VRM		; SSEFC0 <- ARAVRM

	MOV	AX,0			; グラフ文字表示サイズ
	CALLE	VTXSIZ			; character size set.

	MOV	AX,1			; グラフ文字表示色
	CALLE	VTXCOL			; character color set.

	MOV	AX,PROFILE_BASE_X	; locate profile base.
	MOV	BX,PROFILE_BASE_Y	; locate profile base.
	ADD	AX,PROF_HEALTH_X	; locate profile health.
	ADD	BX,PROF_HEALTH_Y	; locate profile health.
	PUSH	AX			;
	PUSH	BX			;
	MOV	VX1,AX			;
	MOV	VY1,BX			;
	ADD	AX,15			;
	ADD	BX,15			;
	MOV	VX2,AX			;
	MOV	VY2,BX			;
	MOV	CX,0			; color palet number.
	CALLE	BOXPAL			; ＢＯＸペイント
	POP	BX			;
	POP	AX			;
	MOV	SI,STRADRS		; string.
	CALLE	VTXPOR			; vram text print OR.

	RET
FEND_w	PT_PROFILE_HEALTH


; ***********************************************
;	profile age.
;	-I- AX : age.
; ***********************************************

FUNC_w	PT_PROFILE_AGE
	MOV	NUM1,AX			;

	MOV	AX,PROFILE_BASE_X	; locate profile base.
	MOV	BX,PROFILE_BASE_Y	; locate profile base.
	ADD	AX,PROF_AGE_X		; locate profile age.
	ADD	BX,PROF_AGE_Y		; locate profile age.
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標

	MOV	DX,0			;
	MOV	AX,NUM1			;
	MOV	BX,10			;
	DIV	BX			;
	MOV	NUM1,AX			; number.
	PUSH	DX			;
	CALL	PT_S_MID_NUMBER		; mid number.(schedule load)
	POP	DX			;
	ADD	XX1,2			;+2
	MOV	NUM1,DX			; number.
	CALL	PT_S_MID_NUMBER		; mid number.(schedule load)

	RET
FEND_w	PT_PROFILE_AGE


; ***********************************************
;	profile gold.
;	-I- DX:AX : gold.
; ***********************************************

FUNC_w	PT_PROFILE_GOLD
	MOV	NUM1,DX			;
	MOV	NUM2,AX			;

	MOV	AX,PROFILE_BASE_X	; locate profile base.
	MOV	BX,PROFILE_BASE_Y	; locate profile base.
	ADD	AX,PROF_GOLD_X		; locate profile gold.
	ADD	BX,PROF_GOLD_Y		; locate profile gold.
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標
	MOV	DX,NUM1			;
	MOV	AX,NUM2			;
	MOV	NUM1,7			; character length.
	CALL	PUT_NUMBER		; number.

	RET
FEND_w	PT_PROFILE_GOLD


; ***********************************************
;	profile arms icon.
;	-I- AX : 装備　ＩＣＯＮ番号
;	    BX : 武器　ＩＣＯＮ番号
; ***********************************************

FUNC_w	PT_PROFILE_ARMS_ICON
	MOV	NUM1,AX			; 装備　ＩＣＯＮ番号
	MOV	NUM2,BX			; 武器　ＩＣＯＮ番号

	MOV	AX,PROFILE_BASE_X	; locate profile base.
	MOV	BX,PROFILE_BASE_Y	; locate profile base.
	ADD	AX,PROF_ICON_X		; locate profile icon.
	ADD	BX,PROF_ICON_Y		; locate profile icon.
	MOV	XX1,AX			; ＰＵＴ　Ｘ座標
	MOV	YY1,BX			; ＰＵＴ　Ｙ座標

	MOV	DX,NUM1			; 装備　ＩＣＯＮ番号
	MOV	BX,0			; カバー番号
	CALL	PROFILE_ICON_PUT	; profile icon put.

	ADD	XX1,4			; ＰＵＴ　Ｘ座標

	MOV	DX,NUM2			; 武器　ＩＣＯＮ番号
	MOV	BX,0			; カバー番号
	CALL	PROFILE_ICON_PUT	; profile icon put.

	RET
FEND_w	PT_PROFILE_ARMS_ICON


; ***********************************************
;	profile status icon.
;	-I- AX : 状態・病気
;	    BX : 状態・非行化
;	    CX : 状態・恋愛
; ***********************************************

FUNC_w	PT_PROFILE_STATUS_ICON
	MOV	NUM1,0
	MOV	NUM2,0
	MOV	NUM3,0

	CMP	AX,0			; 状態・病気
	JE	PT_PROFILE_STATUS_ICON_1
	MOV	NUM1,102		; 102=病気化
PT_PROFILE_STATUS_ICON_1:

	CMP	BX,0			; 状態・非行化
	JE	PT_PROFILE_STATUS_ICON_2
	MOV	NUM2,101		; 101=非行化
PT_PROFILE_STATUS_ICON_2:

	CMP	CX,0			; 状態・恋愛
	JE	PT_PROFILE_STATUS_ICON_3
	MOV	NUM3,103		; 103=恋愛化
PT_PROFILE_STATUS_ICON_3:

	MOV	AX,PROFILE_BASE_X	; locate profile base.
	MOV	BX,PROFILE_BASE_Y	; locate profile base.
	ADD	AX,PROF_ICON_X		; locate profile icon.
	ADD	BX,PROF_ICON_Y		; locate profile icon.
	ADD	AX,4*2			;
	MOV	XX1,AX			; ＰＵＴ　Ｘ座標
	MOV	YY1,BX			; ＰＵＴ　Ｙ座標

	MOV	DX,NUM1			;
	MOV	BX,1			; カバー番号
	CALL	PROFILE_ICON_PUT	; profile icon put.

	ADD	XX1,4			; ＰＵＴ　Ｘ座標

	MOV	DX,NUM2			;
	MOV	BX,1			; カバー番号
	CALL	PROFILE_ICON_PUT	; profile icon put.

	ADD	XX1,4			; ＰＵＴ　Ｘ座標

	MOV	DX,NUM3			;
	MOV	BX,1			; カバー番号
	CALL	PROFILE_ICON_PUT	; profile icon put.

	RET
FEND_w	PT_PROFILE_STATUS_ICON


; ***********************************************
;	profile body size.
;	-I- AX : 身長
;	    BX : 体重
;	    CX : バスト
;	    DX : ウエスト
;	    SI : ヒップ
; ***********************************************

FUNC_w	PT_PROFILE_BODYSIZE
	MOV	PARA_SHINCHO,AX			; 身長
	MOV	PARA_TAIJYU,BX			; 体重
	MOV	PARA_BUST,CX			; バスト
	MOV	PARA_WAIST,DX			; ウエスト
	MOV	PARA_HIP,SI			; ヒップ

	MOV	AX,PROFILE_BASE_X	; locate profile base.
	MOV	BX,PROFILE_BASE_Y	; locate profile base.
	ADD	AX,PROF_BODYSIZE_X	; locate profile bodysize.
	ADD	BX,PROF_BODYSIZE_Y	; locate profile bodysize.
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標

	MOV	NUM1,3			; character length.

	MOV	AX,PARA_SHINCHO		; 身長
	CALL	PUT_NUMBER_100DIV	; number.

	ADD	XX1,4			; ＰＵＴＸ座標
	MOV	AX,PARA_TAIJYU		; 体重
	CALL	PUT_NUMBER_100DIV	; number.

	MOV	NUM1,2			; character length.

	ADD	XX1,5			; ＰＵＴＸ座標
	MOV	AX,PARA_BUST		; バスト
	CALL	PUT_NUMBER_100DIV	; number.

	ADD	XX1,3			; ＰＵＴＸ座標
	MOV	AX,PARA_WAIST		; ウエスト
	CALL	PUT_NUMBER_100DIV	; number.

	ADD	XX1,3			; ＰＵＴＸ座標
	MOV	AX,PARA_HIP		; ヒップ
	CALL	PUT_NUMBER_100DIV	; number.

	RET
FEND_w	PT_PROFILE_BODYSIZE


; ***********************************************
;	RPG profile gold.
;	-I- DX:AX : gold.
; ***********************************************

FUNC_w	PT_RPGPROF_GOLD
	MOV	XX1,70			; ＰＵＴＸ座標
	MOV	YY1,107			; ＰＵＴＹ座標
	MOV	NUM1,7			; character length.
	CALL	PUT_NUMBER		; number.
	RET
FEND_w	PT_RPGPROF_GOLD


; ***********************************************
;	RPG profile HP.
;	-I- DX : value.
; ***********************************************

FUNC_w	PT_RPGPROF_HP
	MOV	NUM1,3			; character length.
	MOV	XX1,65			; ＰＵＴＸ座標
	MOV	YY1,87			; ＰＵＴＹ座標
	CALL	PUT_MIDNUM		; mid number.
	RET
FEND_w	PT_RPGPROF_HP


; ***********************************************
;	RPG profile MP.
;	-I- DX : value.
; ***********************************************

FUNC_w	PT_RPGPROF_MP
	MOV	NUM1,3			; character length.
	MOV	XX1,73			; ＰＵＴＸ座標
	MOV	YY1,87			; ＰＵＴＹ座標
	CALL	PUT_MIDNUM		; mid number.
	RET
FEND_w	PT_RPGPROF_MP


; ***********************************************
;	RPG profile arms icon.
;	-I- AX : 装備　ＩＣＯＮ番号
;	    BX : 武器　ＩＣＯＮ番号
; ***********************************************

FUNC_w	PT_RPGPROF_ARMS_ICON
	MOV	NUM1,AX			; 装備　ＩＣＯＮ番号
	MOV	NUM2,BX			; 武器　ＩＣＯＮ番号

	MOV	XX1,68			; ＰＵＴ　Ｘ座標
	MOV	YY1,136			; ＰＵＴ　Ｙ座標

	MOV	DX,NUM1			; 装備　ＩＣＯＮ番号
	MOV	BX,0			; カバー番号
	CALL	PROFILE_ICON_PUT	; profile icon put.

	ADD	XX1,4			; ＰＵＴ　Ｘ座標

	MOV	DX,NUM2			; 武器　ＩＣＯＮ番号
	MOV	BX,0			; カバー番号
	CALL	PROFILE_ICON_PUT	; profile icon put.
	RET
FEND_w	PT_RPGPROF_ARMS_ICON


; ***********************************************
;	各種小さいフレーム
;	-I- AX : frame number.
;	    BX : use load bank.
;	    CX : x.
;	    DX : y.
;
;	frame number.
;		1=ﾌﾚｰﾑ･ﾌｪｲｽ
;		2=ﾌﾚｰﾑ･守護星ﾌｪｲｽ
;		3=ﾌﾚｰﾑ･大ｲﾍﾞﾝﾄ
;		4=ﾌﾚｰﾑ･小ｲﾍﾞﾝﾄ
;		5=ﾌﾚｰﾑ･収穫祭ﾌｪｲｽ
;		6=ﾌﾚｰﾑ･収穫祭ﾃｷｽﾄ
; ***********************************************

FUNC_w	PT_MINI_FRAME
	MOV	NUM1,AX
	MOV	NUM2,BX
	MOV	XX1,CX
	MOV	YY1,DX

	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM

	P_BANK	NUM2

	CALL	FILE_INIT		; ロード初期化

	CMP	NUM1,5			; 5=ﾌﾚｰﾑ･収穫祭ﾌｪｲｽ
	JE	PT_MINI_FRAME_SYU	;
	CMP	NUM1,6			; 6=ﾌﾚｰﾑ･収穫祭ﾃｷｽﾄ
	JE	PT_MINI_FRAME_SYU_TXT	;

	STRS	DI,"FRMxx"		;
	MOV	DX,NUM1			;
	CALL	DECSTR			;
	MOVX	DS:[DI][3],DS:[SI][3]	;"ooo01"
	MOV	SI,DI			;
	CALL	C1PATLDA		; パーツ追加ロード

	MOV	NUM,0			; パターン番号
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定
	RET

PT_MINI_FRAME_SYU:
	STRS	SI,"SSFACE"		;
	CALL	C1PATLDA		; パーツ追加ロード
	MOV	NUM,0			; パターン番号
	CALL	MASK_PTX		; マスクパターンＰＵＴ座標指定
	RET
PT_MINI_FRAME_SYU_TXT:
	STRS	SI,"SSTEXT2"		;
	CALL	C1PATLDA		; パーツ追加ロード
	MOV	NUM,0			; パターン番号
	CALL	MASK_PTX		; マスクパターンＰＵＴ座標指定
	RET
FEND_w	PT_MINI_FRAME


; ***********************************************
;	graph gold.
;	-I- DX:AX : gold.
;	    BX : put x
;	    CX : put y
; ***********************************************

FUNC_w	PT_GRP_GOLD
	MOV	XX1,BX			; ＰＵＴＸ座標
	MOV	YY1,CX			; ＰＵＴＹ座標
	MOV	NUM1,5			; character length.
	CALL	PUT_NUMBER		; number.

	ADD	XX1,5			; ＰＵＴＸ座標
	MOV	NUM1,0			; unit.0=GOLD
	CALL	PT_P_UNIT		; parameter unit.
	RET
FEND_w	PT_GRP_GOLD


; ***********************************************
;	汎用フレームの飾り
;	-I- AX : pattern number.
;	    BX : put x
;	    CX : put y
;	pattern number.
;	0,1,2,3=SLCTのｺｰﾅ
; ***********************************************

FUNC_w	PT_FRM_KAZARI
	MOV	NUM1,AX			; character length.
	MOV	XX1,BX			; ＰＵＴＸ座標
	MOV	YY1,CX			; ＰＵＴＹ座標
	CALL	PT_P_KAZARI		; parameter kazari.
	RET
FEND_w	PT_FRM_KAZARI


; ***********************************************
;	profile icon put.
;	-I- DX : 装備　ＩＣＯＮ番号
;	    XX1: ＰＵＴ　Ｘ座標
;	    YY1: ＰＵＴ　Ｙ座標
;	    BX : カバー番号
; ***********************************************

PROFILE_ICON_PUT	PROC	NEAR
	CMP	DX,0
	JE	PROFILE_ICON_PUT_FUTA

	MOV	AX,XX1			; ＰＵＴ　Ｘ座標
	MOV	BX,YY1			; ＰＵＴ　Ｙ座標
	CALLE	ICON_PUT		; ICON put.
	RET
PROFILE_ICON_PUT_FUTA:
	PUSH	BX			;
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_CLEND		; calendar bank.
	POP	BX			;

	MOV	AX,P_NUM_FXCOVER	; pattn number profile cover.
	ADD	AX,BX			; カバー番号
	MOV	NUM,AX			;
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定
	RET
PROFILE_ICON_PUT	ENDP


; ***********************************************
;	big number.
;	-I- NUM1 : number.
;	    XX1  : ＰＵＴＸ座標
;	    YY1  : ＰＵＴＹ座標
; ***********************************************

PT_BIG_NUMBER	PROC	NEAR
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_CLEND		; calendar bank.

	MOV	DX,NUM1			; number.
	ADD	DX,P_NUM_FXBIGN		; pattn number big number.
	MOV	NUM,DX			; パターン番号
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定
	RET
PT_BIG_NUMBER	ENDP


; ***********************************************
;	mid number.(schedule load)
;	-I- NUM1 : number.
;	    XX1  : ＰＵＴＸ座標
;	    YY1  : ＰＵＴＹ座標
; ***********************************************

PT_S_MID_NUMBER	PROC	NEAR
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_CLEND		; calendar bank.

	MOV	DX,NUM1			; number.
	ADD	DX,P_NUM_FXMIDN		; pattn number mid number.
	MOV	NUM,DX			; パターン番号
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定
	RET
PT_S_MID_NUMBER	ENDP


; ***********************************************
;	parameter unit.
;	-I- NUM1 : unit.0=GOLD
;	    XX1  : ＰＵＴＸ座標
;	    YY1  : ＰＵＴＹ座標
; ***********************************************

PT_P_UNIT	PROC	NEAR
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_CLEND		; calendar bank.

	MOV	DX,NUM1			; number.
	ADD	DX,P_NUM_FXUNIT		; pattn number unit mark.
	MOV	NUM,DX			; パターン番号
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定
	RET
PT_P_UNIT	ENDP


; ***********************************************
;	parameter kazari.
;	-I- NUM1 : pattern number. 0,1,2,3=SLCTのｺｰﾅ
;	    XX1  : ＰＵＴＸ座標
;	    YY1  : ＰＵＴＹ座標
; ***********************************************

PT_P_KAZARI	PROC	NEAR
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_CLEND		; calendar bank.

	MOV	DX,NUM1			; number.
	ADD	DX,P_NUM_FXKAZA		; pattn number kazari.
	MOV	NUM,DX			; パターン番号
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定
	RET
PT_P_KAZARI	ENDP


; ***********************************************
;	number.
;	-I- AX    : value
;	    NUM1  : character length.
;	    XX1   : ＰＵＴＸ座標
;	    YY1   : ＰＵＴＹ座標
; ***********************************************

PUT_NUMBER_100DIV	PROC	NEAR
	MOV	DX,0			;
	MOV	CX,100			;
	DIV	CX			; / 100
	MOV	DX,0			;
	CALL	PUT_NUMBER		; number.
	RET
PUT_NUMBER_100DIV	ENDP


; ***********************************************
;	number.
;	-I- DX:AX : i*4 value
;	    NUM1  : character length.
;	    XX1   : ＰＵＴＸ座標
;	    YY1   : ＰＵＴＹ座標
; ***********************************************

PUT_NUMBER	PROC	NEAR
	PUSH	XX1
	PUSH	YY1
	PUSH	NUM1

	PUSH	DX
	PUSH	AX

	MOV	AX,XX1			;
	MOV	BX,YY1			;
	MOV	VX1,AX			;
	MOV	VY1,BX			;
	ADD	AX,NUM1			; character length.
	DEC	AX			; -1
	ADD	BX,15			;
	MOV	VX2,AX			;
	MOV	VY2,BX			;
	MOV	CX,0			; color palet number.
	CALLE	BOXPAL			; ＢＯＸペイント

	POP	AX
	POP	DX

	CMP	DX,0
	JGE	PUT_NUMBER_2

	MOV	DX,AX
	CALLE	SIGSTR			; signed val DX to dec string.
	MOV	NUM_STRING,SI		; string.
	MOVX	ES,DS			;
	MOV	DI,NUM_STRING		; string.
	CALLE	STRLENGTH		; 文字列長さ
					;-O- CX    : 表示単語長さ
	CMP	NUM1,CX			;
	JBE	PUT_NUMBER_1		;
	MOV	AX,NUM1			;
	SUB	AX,CX			;
	ADD	XX1,AX			;
	MOV	NUM1,CX			;
PUT_NUMBER_1:				;
	MOV	SI,CX			;
	SUB	SI,NUM1			; character length.
	ADD	SI,NUM_STRING		; string.
	JMP	PUT_NUMBER_3

PUT_NUMBER_2:
	CALLE	D10STR			; i*4 value -> decimal string.
	CALLE	STRZTS			; zero to space. "00123" - > "  123"
	MOV	NUM_STRING,SI		; string.
					;  1234567890
					; "2147483648"

	MOV	SI,10			;
	SUB	SI,NUM1			; character length.
	ADD	SI,NUM_STRING		; string.
PUT_NUMBER_3:

	PUSH	SI
	P_BANK	BNK_CLEND		; calendar bank.
	CALL	ID_EFC_SET_VRM		; SSEFC0 <- ARAVRM
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	CALL	ID_D_SET_VRM		; SSDES0 <- ARAVRM
	POP	SI

	MOV	CX,NUM1			; character length.
PUT_NUMBER_LOOP:
	PUSH	CX
	LODSB

	CMP	AL,'-'
	JE	PUT_NUMBER_MINUS

	CMP	AL,' '
	JBE	PUT_NUMBER_BLANK

	SUB	AL,'0'			;
	JB	PUT_NUMBER_BLANK	;
	CMP	AL,9
	JNBE	PUT_NUMBER_BLANK	;
	PUSH	SI
	MOV	AH,0			;
	MOV	DX,P_NUM_FXNUM		; pattn number number.
	ADD	DX,AX			;
	MOV	NUM,DX			; パターン番号
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定
	POP	SI
	JMP	PUT_NUMBER_NEXT

PUT_NUMBER_MINUS:
	PUSH	SI
	MOV	BX,YY1			;
	ADD	BX,6
	MOV	VY1,BX			;
	MOV	AX,XX1			;
	SHL	AX,1			;
	SHL	AX,1			; * 8
	SHL	AX,1			;
	MOV	VX1,AX			;
	ADD	AX,6			;
	MOV	VX2,AX			;
	MOV	VCOL,3			; color.
	MOV	CX,2			; line width.
	CALLE	DLINEH			; 水平ライン描画
	POP	SI
	JMP	PUT_NUMBER_NEXT

PUT_NUMBER_BLANK:
PUT_NUMBER_NEXT:
	INC	XX1			; ＰＵＴＸ座標
	POP	CX
	LOOP	PUT_NUMBER_LOOP

	POP	NUM1
	POP	YY1
	POP	XX1
	RET
PUT_NUMBER	ENDP


; ***********************************************
;	mid number.
;	-I- DX    : value.
;	    NUM1  : character length.
;	    XX1   : ＰＵＴＸ座標
;	    YY1   : ＰＵＴＹ座標
; ***********************************************

PUT_MIDNUM	PROC	NEAR
	PUSH	XX1
	PUSH	YY1
	CALLE	DECSTR			;
	CALLE	STRZTS			; zero to space. "00123" - > "  123"
	MOV	NUM_STRING,SI		; string.
					;  1234567890
					; "2147483648"

	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	P_BANK	BNK_CLEND		; calendar bank.

	MOV	SI,5			;
	SUB	SI,NUM1			; character length.
	ADD	SI,NUM_STRING		; string.
	MOV	CX,NUM1			; character length.
PUT_MIDNUM_LOOP:
	PUSH	CX
	LODSB
	CMP	AL,' '
	JBE	PUT_MIDNUM_BLANK

	PUSH	SI
	SUB	AL,'0'			;
	MOV	AH,0			;
	MOV	DX,P_NUM_FXMIDN		; pattn number mid number.
	ADD	DX,AX			;
	MOV	NUM,DX			; パターン番号
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定
	POP	SI
	JMP	PUT_MIDNUM_NEXT

PUT_MIDNUM_BLANK:
	PUSH	SI
	MOV	AX,XX1			;
	MOV	BX,YY1			;
	MOV	VX1,AX			;
	MOV	VY1,BX			;
	ADD	AX,2			;
	ADD	BX,15			;
	MOV	VX2,AX			;
	MOV	VY2,BX			;
	MOV	CX,0			; color palet number.
	CALLE	BOXPAL			; ＢＯＸペイント
	POP	SI

PUT_MIDNUM_NEXT:
	ADD	XX1,2			; ＰＵＴＸ座標
	POP	CX
	LOOP	PUT_MIDNUM_LOOP

	POP	YY1
	POP	XX1
	RET
PUT_MIDNUM	ENDP


; ***********************************************
;	パレットテーブルセットのみ
;	-I- AX : パーツ番号
;	    BX : テーブル番号
; ***********************************************

FUNC_w	PT_PALET_SETONLY
	MOV	NUM1,AX
	MOV	NUM2,BX

	P_BANK	P_BANK_PALET		; palet.

	MOV	CX,NUM1			; パーツ番号
	MOV	BX,NUM2			; パレットテーブル番号
	CALLE	C1PLTPAT		; パーツバッファからパレットを取り出す
	RET
FEND_w	PT_PALET_SETONLY


; ***********************************************
;	pattern load.
;	-I- SI : file name.
;	    DX : bank number.
; ***********************************************

FUNC_w	PT_PATTERN_LD
	MOV	FLNAME_ADRS,SI		; file name.
	MOV	LOADPAT_BANKNUM,DX	; ロードパターンバンク番号
	P_BANK	LOADPAT_BANKNUM		; normal bank.
	CALL	FILE_INIT		; ロード初期化
	MOV	SI,FLNAME_ADRS		; file name.
	CALL	C1PATLDA		; パーツ追加ロード
	RET
FEND_w	PT_PATTERN_LD


; ***********************************************
;	pattern add load.
;	-I- SI : file name.
; ***********************************************

FUNC_w	PT_PATTERN_LDA
	MOV	FLNAME_ADRS,SI		; file name.
	P_BANK	LOADPAT_BANKNUM		; normal bank.
	MOV	SI,FLNAME_ADRS		; file name.
	CALL	C1PATLDA		; パーツ追加ロード
	RET
FEND_w	PT_PATTERN_LDA


; ***********************************************
;	pattern put.
;	-I- AX    : put x.
;	    BX    : put y.
;	    DX    : pattern number.
;	    SSGR0-SSGR3,SSGRW : put vram.
; ***********************************************

FUNC_w	PT_PATTERN_PUT
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標
	MOV	NUM,DX			; パターン番号
	P_BANK	LOADPAT_BANKNUM		; normal bank.
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定
	RET
FEND_w	PT_PATTERN_PUT


; ***********************************************
;	pattern mask put.
;	-I- AX    : put x.
;	    BX    : put y.
;	    DX    : pattern number.
;	    SSGR0-SSGR3,SSGRW : put vram.
; ***********************************************

FUNC_w	PT_MASK_PAT_PUT
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標
	MOV	NUM,DX			; パターン番号
	P_BANK	LOADPAT_BANKNUM		; normal bank.
	CALL	MASK_PTX		; マスクパターンＰＵＴ座標指定
	RET
FEND_w	PT_MASK_PAT_PUT


; ***********************************************
;	pattern mask offset put.
;	-I- AX    : put x.
;	    BX    : put y.
;	    DX    : pattern number.
;	    SSGR0-SSGR3,SSGRW : put vram.
; ***********************************************

FUNC_w	PT_MASK_PTF_PUT
	MOV	XX1,AX			; ＰＵＴＸ座標
	MOV	YY1,BX			; ＰＵＴＹ座標
	MOV	NUM,DX			; パターン番号
	P_BANK	LOADPAT_BANKNUM		; normal bank.
	CALL	MASK_PTF		; マスクパターンＰＵＴオフセット
	RET
FEND_w	PT_MASK_PTF_PUT


; ***********************************************
;	put girl wall.
; ***********************************************

PT_GIRL_WALL	PROC	NEAR
	P_BANK	BNK_NORMAL		; normal bank.
	CALL	FILE_INIT		; ロード初期化
	MOV	SI,OFFSET FRM1M		; fream : 娘の部屋mid
	CALLE	C1PATLDA		; パーツ追加ロード

	MOVX	PICNUM,ROOM_PIC		; 部屋の絵
	CALL	MYROOM_PIC_LDA		; my room picture apend load.
	MOV	NUM,0			; パターン番号
	MOVX	XX1,GIRL_PUT_ADJAST_X	; girl put adjast x.
	MOVX	YY1,GIRL_PUT_ADJAST_Y	; girl put adjast y.
	CALL	PATTAN_PTF		; パターンＰＵＴオフセット

	ADDX	PICMYROOMXX,GIRL_PUT_ADJAST_X	; 絵画 x.
	ADDX	PICMYROOMYY,GIRL_PUT_ADJAST_Y	; 絵画 y.
	MOV	NUM,1			; パターン番号
	CALL	MYROOM_PIC_PUT		; my room picture put.
	SUBX	PICMYROOMXX,GIRL_PUT_ADJAST_X	; 絵画 x.
	SUBX	PICMYROOMYY,GIRL_PUT_ADJAST_Y	; 絵画 y.

	RET
PT_GIRL_WALL	ENDP


; ***********************************************
;	put girl wall width60.
;
;	バンク　BNK_NORMAL　に壁中央(FRMMAINM.PT1)のデータを残す
; ***********************************************

PT_GIRL_WALL60X	PROC	NEAR
	P_BANK	BNK_NORMAL		; normal bank.
	CALL	FILE_INIT		; ロード初期化
	MOV	SI,OFFSET FRM1M		; fream : 娘の部屋mid
	CALLE	C1PATLDA		; パーツ追加ロード
	MOV	SI,FRMNAMER[0]		; fream R file.
	CALLE	C1PATLDA		; パーツ追加ロード

	MOV	VRPX,0			; ＧＥＴ Ｘ座標
	MOV	VRPY,200		; ＧＥＴ Ｙ座標
	MOV	VRLENPX,38		; ＧＥＴ Ｘサイズ
	MOV	VRLENPY,200		; ＧＥＴ Ｙサイズ
	CALLE	C1PLSVIW		;ＰＵＴＶＩＥＷの設定

	MOV	NUM,0			; パターン番号
	MOV	XX1,0			; girl put adjast x.
	MOV	YY1,0			; girl put adjast y.
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定

	MOV	VRPX,0			; ＧＥＴ Ｘ座標
	MOV	VRPY,200		; ＧＥＴ Ｙ座標
	MOV	VRLENPX,22		; ＧＥＴ Ｘサイズ
	MOV	VRLENPY,200		; ＧＥＴ Ｙサイズ
	CALLE	C1PLSVIW		;ＰＵＴＶＩＥＷの設定

	MOV	NUM,1			; パターン番号
	MOV	XX1,38			; girl put adjast x.
	MOV	YY1,0			; girl put adjast y.
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定

	CALLE	C1PLSVWS		; ＰＵＴＶＩＥＷの解除
	RET
PT_GIRL_WALL60X	ENDP


; ***********************************************
;	put girl sleep bed.
; ***********************************************

PT_GIRL_SLEEP_BED	PROC	NEAR
	P_BANK	BNK_HARF		; harf buffer 32,764byte
	CALL	FILE_INIT		; ロード初期化

	STRS	SI,"GIRL10X1"		;
	CALLE	C1PATLDA		; パーツ追加ロード

	MOV	XX1,-20			; girl put adjast x.
	MOV	YY1,-200		; girl put adjast y.
	MOV	NUM,0			; パターン番号
	CALL	MASK_PTF		; マスクパターンＰＵＴオフセット
	RET
PT_GIRL_SLEEP_BED	ENDP


; ***********************************************
;	put girl body.
;	-I- WD_GIRL_AGE  : girl age.
;	    WD_GIRL_BODY : girl body.1=細,2=太
; ***********************************************

PT_GIRL_BODY	PROC	NEAR
	P_BANK	BNK_NORMAL		; normal bank.

	STRS	DI,"GIRLxxAx"

	MOV	DX,WD_GIRL_AGE		; girl age.
	CALL	DECSTR			;
	MOVX	DS:[DI][4],DS:[SI][3]	;"00010"

	MOV	DX,WD_GIRL_BODY		; girl body.1=細,2=太
	CALL	DECSTR			;
	MOVXB	DS:[DI][7],DS:[SI][4]	;"00001"

	MOV	SI,DI			; file name.
	CALL	GIRL_PUT		; girl put.
	RET
PT_GIRL_BODY	ENDP


; ***********************************************
;	put girl breast.
;	-I- WD_GIRL_AGE    : girl age.
;	    WD_GIRL_BODY   : girl body.1=細,2=太
;	    WD_GIRL_BREAST : girl breast.0=無,1=有
; ***********************************************

PT_GIRL_BREAST	PROC	NEAR
	CMP	WD_GIRL_BREAST,0	; girl breast.0=無,1=有
	JNE	PT_GIRL_BREAST_START	;
	RET
PT_GIRL_BREAST_START:
	P_BANK	BNK_NORMAL		; normal bank.

	STRS	DI,"GIRLxxBx"

	MOV	DX,WD_GIRL_AGE		; girl age.
	CALL	DECSTR			;
	MOVX	DS:[DI][4],DS:[SI][3]	;"00010"

	MOV	DX,WD_GIRL_BODY		; girl body.1=細,2=太
	CALL	DECSTR			;
	MOVXB	DS:[DI][7],DS:[SI][4]	;"00001"

	MOV	SI,DI			; file name.
	CALL	GIRL_PUT		; girl put.
	RET
PT_GIRL_BREAST	ENDP


; ***********************************************
;	put girl face.
;	-I- WD_GIRL_AGE  : girl age.
;	    WD_GIRL_FACE : girl face.1=基本,2=非行,3=病気,4=元気,5=色気
; ***********************************************

PT_GIRL_FACE	PROC	NEAR
	P_BANK	BNK_NORMAL		; normal bank.

	STRS	DI,"GIRLxxFx"

	MOV	DX,WD_GIRL_AGE		; girl age.
	CALL	DECSTR			;
	MOVX	DS:[DI][4],DS:[SI][3]	;"00010"

	MOV	DX,WD_GIRL_FACE		; girl face.1=基本,2=非行,3=病気...
	CALL	DECSTR			;
	MOVXB	DS:[DI][7],DS:[SI][4]	;"00001"

	MOV	SI,DI			; file name.
	CALL	GIRL_PUT		; girl put.
	RET
PT_GIRL_FACE	ENDP


; ***********************************************
;	put girl dress.
;	-I- WD_GIRL_DRESS        : girl dress.
;	    WD_GIRL_AGE          : girl age.
;	    WD_GIRL_DRESS_BODY   : girl dress body.1=細,2=太
; ***********************************************

PT_GIRL_DRESS	PROC	NEAR
	CMP	WD_GIRL_DRESS,0		; girl dress.
	JNE	PT_GIRL_DRESS_START	;
	RET
PT_GIRL_DRESS_START:
	P_BANK	BNK_NORMAL		; normal bank.

	STRS	DI,"DRxXxxAx"

	MOV	DX,WD_GIRL_DRESS	; girl dress.
	CALL	HEXSTR			;
	MOVXB	DS:[DI][2],DS:[SI][3]	;"000A"

	MOV	DX,WD_GIRL_AGE		; girl age.
	CALL	DECSTR			;
	MOVX	DS:[DI][4],DS:[SI][3]	;"00010"

	MOV	DX,WD_GIRL_DRESS_BODY	; girl body.1=細,2=太
	CALL	DECSTR			;
	MOVXB	DS:[DI][7],DS:[SI][4]	;"00001"

	MOV	SI,DI			; file name.
	CALL	GIRL_PUT		; girl put.
	RET
PT_GIRL_DRESS	ENDP


; ***********************************************
;	put girl dress breast.
;	-I- WD_GIRL_DRESS        : girl dress.
;	    WD_GIRL_AGE          : girl age.
;	    WD_GIRL_DRESS_BODY   : girl dress body.1=細,2=太
;	    WD_GIRL_DRESS_BREAST : girl dress breast.0=無,1=有
; ***********************************************

PT_GIRL_DRESS_BREAST	PROC	NEAR
	CMP	WD_GIRL_DRESS,0		; girl dress.
	JE	PT_GIRL_DRESS_BREAST_EXIT

	CMP	WD_GIRL_DRESS_BREAST,0	; girl dress breast.0=無,1=有
	JE	PT_GIRL_DRESS_BREAST_EXIT

	P_BANK	BNK_NORMAL		; normal bank.

	STRS	DI,"DRxXxxBx"

	MOV	DX,WD_GIRL_DRESS	; girl dress.
	CALL	HEXSTR			;
	MOVXB	DS:[DI][2],DS:[SI][3]	;"000A"

	MOV	DX,WD_GIRL_AGE		; girl age.
	CALL	DECSTR			;
	MOVX	DS:[DI][4],DS:[SI][3]	;"00010"

	MOV	DX,WD_GIRL_DRESS_BODY	; girl body.1=細,2=太
	CALL	DECSTR			;
	MOVXB	DS:[DI][7],DS:[SI][4]	;"00001"

	MOV	SI,DI			; file name.
	CALL	GIRL_PUT		; girl put.

PT_GIRL_DRESS_BREAST_EXIT:
	RET
PT_GIRL_DRESS_BREAST	ENDP


; ***********************************************
;	girl put.
;	-I- SI : file name.
; ***********************************************

GIRL_PUT	PROC	NEAR
	CALL	FILE_INIT		; ロード初期化

	CALLE	C1PATLDA		; パーツ追加ロード

	MOVX	XX1,GIRL_PUT_ADJAST_X	; girl put adjast x.
	MOVX	YY1,GIRL_PUT_ADJAST_Y	; girl put adjast y.

	MOV	NUM,0			; パターン番号
	CALL	MASK_PTF		; マスクパターンＰＵＴオフセット
	RET
GIRL_PUT	ENDP


; ***********************************************
;	my room picture apend load.
;	-I- PICNUM : 絵画の番号
; ***********************************************

MYROOM_PIC_LDA	PROC	NEAR
	MOV	BX,PICNUM		; 絵画の番号
	CMP	BX,PICMAX		; 絵画の数
	JNB	MYROOM_PIC_LDA_EXIT	;
	SHL	BX,1			;
	MOV	SI,DS:PICMYROOM[BX]	; 娘の部屋の絵画
	CALLE	C1PATLDA		; パーツ追加ロード
MYROOM_PIC_LDA_EXIT:
	RET
MYROOM_PIC_LDA	ENDP


; ***********************************************
;	my room picture put.
;	-I- NUM : パターン番号
; ***********************************************

MYROOM_PIC_PUT	PROC	NEAR
	MOVX	XX1,PICMYROOMXX		; 絵画 x.
	MOVX	YY1,PICMYROOMYY		; 絵画 y.
	CALL	PATTAN_PTX		; パターンＰＵＴ座標指定
	RET
MYROOM_PIC_PUT	ENDP


; ***********************************************
;	マスクパターンＰＵＴ座標指定(BBCTOOL3.ASM)
;	-I- AX : ＰＵＴ　Ｘ座標
;	    BX : ＰＵＴ　Ｙ座標
;	    CX : パターン番号
; ***********************************************

FUNC_w	PT_MASK_PTX
	MOV	XX1,AX			; ＰＵＴ　Ｘ座標
	MOV	YY1,BX			; ＰＵＴ　Ｙ座標
	MOV	NUM,CX			; パターン番号
	CALL	MASK_PTX		; マスクパターンＰＵＴ座標指定
	RET
FEND_w	PT_MASK_PTX


; ***********************************************
;	マスクパターンＰＵＴオフセット(BBCTOOL3.ASM)
;	-I- AX : ＰＵＴオフセット　Ｘ座標
;	    BX : ＰＵＴオフセット　Ｙ座標
;	    CX : パターン番号
; ***********************************************

FUNC_w	PT_MASK_PTF
	MOV	XX1,AX			; ＰＵＴオフセット　Ｘ座標
	MOV	YY1,BX			; ＰＵＴオフセット　Ｙ座標
	MOV	NUM,CX			; パターン番号
	CALL	MASK_PTF		; マスクパターンＰＵＴオフセット
	RET
FEND_w	PT_MASK_PTF

; ***********************************************
;	pattern bank set.
;	-I- DX : bank number.
; ***********************************************

FUNC_w	PT_PATTERN_BANK
	MOV	LOADPAT_BANKNUM,DX	; ロードパターンバンク番号
	RET
FEND_w	PT_PATTERN_BANK


; ***********************************************
;	vram ID all asigned.
; ***********************************************

FUNC_w	PT_VRAM_ID_ALL_ASSIGN
	PUSH	ES
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	BP
	CALL	ID_D_SET_VRM		; SSDES0 <- ARAVRM
	CALL	ID_GR_SET_VRM		; SSGR0 <- ARAVRM
	CALL	ID_EFC_SET_VRM		; SSEFC0 <- ARAVRM
	MOV_ID2	SEGVT0,ARAVRM		; text put vram segment plean 0.
	MOV_ID2	SSCUR0,ARAVRM		; visual data segment plean 0
	POP	BP
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POP	ES
	RET
FEND_w	PT_VRAM_ID_ALL_ASSIGN


; *********************************************************
;	parts buffer clear.
; *********************************************************

FUNC_w	PT_PATTERN_CLEAR
	P_BANK	LOADPAT_BANKNUM		; normal bank.
	CALLE	C1PATCLR		; パーツセットクリア
	RET
FEND_w	PT_PATTERN_CLEAR


; *********************************************************
;	parts get.
;	-I- AX : 左上Ｘ
;	    BX : 左上Ｙ
;	    CX : サイズＸ
;	    DX : サイズＹ
;	-O- AX : 0=normal end, 1=error.
;	    SSGR0-SSGR3,SSGRW : put vram.
; *********************************************************

FUNC_w	PT_PATTERN_GET
	MOV	VRX,AX			; window 左上Ｘ
	MOV	VRY,BX			; window 左上Ｙ
	MOV	VRLENX,CX		; window サイズＸ
	MOV	VRLENY,DX		; window サイズＹ
	P_BANK	LOADPAT_BANKNUM		; normal bank.
	CALLE	C1PATGTA		; パーツＧＥＴ圧縮無し
	RET
FEND_w	PT_PATTERN_GET


; *********************************************************
;	parts put mode.
;	-I- DX : 圧縮モード(0:通常,1:縦方向)
; *********************************************************

FUNC_w	PT_PATTERN_MODE
	CALLE	C1PLSMOD		; 圧縮モード切り替え
	RET
FEND_w	PT_PATTERN_MODE


; ***********************************************
;	ロード初期化
; ***********************************************

FILE_INIT	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	DI
	PUSH	SI
	CALLE	C1PATCLR		; パーツセットクリア
	POP	SI
	POP	DI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET
FILE_INIT	ENDP


; ***********************************************
;	パターンＰＵＴ
;	-I- NUM : パターン番号
; ***********************************************

PATTAN_PUT	PROC	NEAR
	MOV	CX,NUM			; パーツ番号
	CALLE	C1PATPUT		; パーツＰＵＴ
	RET
PATTAN_PUT	ENDP


; ***********************************************
;	パターンＰＵＴ座標指定
;	-I- XX1 : ＰＵＴＸ座標
;	    YY1 : ＰＵＴＹ座標
;	    NUM : パターン番号
; ***********************************************

PATTAN_PTX	PROC	NEAR
	MOVX	VRX,XX1			; ＰＵＴＸ
	MOVX	VRY,YY1			; ＰＵＴＹ
	MOV	CX,NUM			; パーツ番号
	CALLE	C1PATPTX		; パーツＰＵＴ座標指定
	RET
PATTAN_PTX	ENDP


; ***********************************************
;	パターンＰＵＴオフセット
;	-I- XX1 : ＰＵＴオフセット　Ｘ座標
;	    YY1 : ＰＵＴオフセット　Ｙ座標
;	    NUM : パターン番号
; ***********************************************

PATTAN_PTF	PROC	NEAR
	MOVX	VRX,XX1		; ＰＵＴＸ
	MOVX	VRY,YY1		; ＰＵＴＹ
	MOV	CX,NUM		; パーツ番号
	CALLE	C1PATPTF	; パーツＰＵＴオフセット指定
	RET
PATTAN_PTF	ENDP


; ***********************************************
;	マスクパターンＰＵＴ
;	-I- NUM : パターン番号
; ***********************************************

MASK_PUT	PROC	NEAR
	MOV	DX,1		;
	CALLE	C1PATOPE	; オペレーションセット(ｵﾍﾟﾚｰｼｮﾝ 0=normal,1=OR )

	MOV	CX,NUM		; マスク
	CALLE	C1PATPTM	; マスクパーツＰＵＴ

	MOV	CX,NUM		; 本体
	INC	CX		;
	CALLE	C1PATPUT	; パーツＰＵＴ

	MOV	DX,0		;
	CALLE	C1PATOPE	; オペレーションセット(ｵﾍﾟﾚｰｼｮﾝ 0=normal,1=OR )

	RET
MASK_PUT	ENDP


; ***********************************************
;	マスクパターンＰＵＴ座標指定
;	-I- XX1 : ＰＵＴ　Ｘ座標
;	    YY1 : ＰＵＴ　Ｙ座標
;	    NUM : パターン番号
; ***********************************************

MASK_PTX	PROC	NEAR
	MOV	DX,1		;
	CALLE	C1PATOPE	; オペレーションセット

	MOVX	VRX,XX1		; Ｘ座標
	MOVX	VRY,YY1		; Ｙ座標
	MOV	CX,NUM		; マスク
	CALLE	C1PATPXM	; マスクパーツＰＵＴ座標指定

	MOVX	VRX,XX1		; Ｘ座標
	MOVX	VRY,YY1		; Ｙ座標
	MOV	CX,NUM		; 本体
	INC	CX		;
	CALLE	C1PATPTX	; パーツＰＵＴ座標指定

	MOV	DX,0		;
	CALLE	C1PATOPE	; オペレーションセット

	RET
MASK_PTX	ENDP


; ***********************************************
;	マスクパターンＰＵＴオフセット
;	-I- XX1 : ＰＵＴオフセット　Ｘ座標
;	    YY1 : ＰＵＴオフセット　Ｙ座標
;	    NUM : パターン番号
; ***********************************************

MASK_PTF	PROC	NEAR
	MOV	DX,1		;
	CALLE	C1PATOPE	; オペレーションセット(ｵﾍﾟﾚｰｼｮﾝ 0=normal,1=OR )

	MOVX	VRX,XX1		; Ｘ座標
	MOVX	VRY,YY1		; Ｙ座標
	MOV	CX,NUM		; マスク
	CALLE	C1PATPFM	; マスクパーツＰＵＴオフセット指定

	MOVX	VRX,XX1		; Ｘ座標
	MOVX	VRY,YY1		; Ｙ座標
	MOV	CX,NUM		; 本体
	INC	CX		;
	CALLE	C1PATPTF	; パーツＰＵＴオフセット指定

	MOV	DX,0		;
	CALLE	C1PATOPE	; オペレーションセット

	RET
MASK_PTF	ENDP


; ***********************************************
;	マスクＯＮＬＹ座標指定
;	-I- XX1 : ＰＵＴ　Ｘ座標
;	    YY1 : ＰＵＴ　Ｙ座標
;	    NUM : パターン番号
; ***********************************************

MASK_PTX_ONLY	PROC	NEAR
	MOVX	VRX,XX1			; Ｘ座標
	MOVX	VRY,YY1			; Ｙ座標
	MOV	CX,NUM			; マスク
	CALLE	C1PATPXM		; マスクパーツＰＵＴ座標指定
	RET
MASK_PTX_ONLY	ENDP


; ***********************************************
;	SSEFC0 <- ARAVRM
; ***********************************************

ID_EFC_SET_VRM	PROC	NEAR
	MOV_ID2	SSEFC0,ARAVRM		; visual data segment plean 0
	RET
ID_EFC_SET_VRM	ENDP


; ***********************************************
;	SSGR0 <- ARAVRM
; ***********************************************

ID_GR_SET_VRM	PROC	NEAR
	MOV_ID2	SSGR0,ARAVRM		; visual data segment plean 0
	RET
ID_GR_SET_VRM	ENDP


; ***********************************************
;	SSGR0 <- ARA001
; ***********************************************

ID_GR_SET_V001	PROC	NEAR
	MOV_ID2	SSGR0,ARA001		; 仮想ＶＲＡＭプレーン
	RET
ID_GR_SET_V001	ENDP


; ***********************************************
;	SSSOU0 <- ARAVRM
; ***********************************************

ID_S_SET_VRM	PROC	NEAR
	MOV_ID2	SSSOU0,ARAVRM		; visual data segment plean 0
	RET
ID_S_SET_VRM	ENDP


; ***********************************************
;	SSDES0 <- ARAVRM
; ***********************************************

ID_D_SET_VRM	PROC	NEAR
	MOV_ID2	SSDES0,ARAVRM		; visual data segment plean 0
	RET
ID_D_SET_VRM	ENDP


; ***********************************************
;	SSSOU0 <- ARA001
; ***********************************************

ID_S_SET_V001	PROC	NEAR
	MOV_ID2	SSSOU0,ARA001		; 仮想ＶＲＡＭプレーン
	RET
ID_S_SET_V001	ENDP


; ***********************************************
;	SSDES0 <- ARA001
; ***********************************************

ID_D_SET_V001	PROC	NEAR
	MOV_ID2	SSDES0,ARA001		; 仮想ＶＲＡＭプレーン
	RET
ID_D_SET_V001	ENDP

CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	ROOM_PIC:WORD		; 部屋の絵

EXTRN	WD_GIRL_AGE:WORD	; girl age.
EXTRN	WD_GIRL_BODY:WORD	; girl body.1=細,2=太
EXTRN	WD_GIRL_FACE:WORD	; girl face.1=基本,2=非行,3=病気,4=元気,5=色気
EXTRN	WD_GIRL_BREAST:WORD	; girl breast.0=無,1=有

EXTRN	WD_GIRL_DRESS:WORD	; girl dress.
EXTRN	WD_GIRL_DRESS_BODY:WORD	; girl dress body.1=細,2=太
EXTRN	WD_GIRL_DRESS_BREAST:WORD ; girl dress breast.0=無,1=有

EXTRN	WD_FACE_GIRL:WORD	; girl face.
EXTRN	WD_FACE_SYUGO:WORD	; syugosei face.

EXTRN	CLRCDE:WORD		; color code.
EXTRN	CLRVEW:WORD		; color view.
EXTRN	CLRCNS:WORD		; contrast.
EXTRN	CLRBRI:WORD		; brightness.

GIRL_PUT_ADJAST_X	DW	0	; girl put adjast x.
GIRL_PUT_ADJAST_Y	DW	0	; girl put adjast y.

GIRL_PUT_MODE	DW	0		; girl put mode.0=normal,1=o.l.
GIRL_LL_MODE	DW	0		; girl normal<->dameg smooth put mode.

FRMNAMEL	DW	FRM1L,FRM2L	; fream L file.
FRMNAMER	DW	FRM1R,FRM2R	; fream R file.

FRM1L		DB	"FRMMAINL",0	; fream : 娘の部屋left
FRM2L		DB	"FRMMSYAL",0	; fream : 武者修行left

FRM1R		DB	"FRMMAINR",0	; fream : 娘の部屋right
FRM2R		DB	"FRMMSYAR",0	; fream : 武者修行right

FRM1M		DB	"FRMMAINM",0	; fream : 娘の部屋mid

		EVEN
PICNUM		DW	0		; 絵画の番号
PICMAX		DW	6		; 絵画の数
PICMYROOMXX	DW	46		; 絵画 x.
PICMYROOMYY	DW	34		; 絵画 y.
PICMYROOM	DW	PI1,PI2,PI3,PI4,PI5,PI6	; 娘の部屋の絵画
PI1		DB	"P001",0
PI2		DB	"P002",0
PI3		DB	"P003",0
PI4		DB	"P004",0
PI5		DB	"P005",0
PI6		DB	"P006",0

		EVEN
PIC_NOW_GIRL_BODY_AGE	DW	0	; girl show body age.

CLEND_BASE_X	DW	0		; locate calendar base.
CLEND_BASE_Y	DW	0		; locate calendar base.

SCHED_BASE_X	DW	0		; locate schedule base.
SCHED_BASE_Y	DW	0		; locate schedule base.

PROFILE_BASE_X	DW	60		; locate profile base.
PROFILE_BASE_Y	DW	0		; locate profile base.

STR_FIRST_NAME	DW	0		; string first name.
STR_FAMILY_NAME	DW	0		; string family name.

PROF_BLOOD	DW	0		; 血液型
PROF_STAR	DW	0		; 守護星

NUM_YEAR	DW	0		; year.
NUM_MONTH	DW	0		; month.
NUM_WEEK	DW	0		; week.
NUM_DAY		DW	0		; day.

NUM_STRING	DW	0		; string.

LOADPAT_BANKNUM	DW	0		; ロードパターンバンク番号

USER_CHR_COLOR	DW	0		; character color 0-15
USER_CHR_SIZE	DW	0		; char size. 0=16x16  1=32x32...
USER_CHR_TYPE	DW	0		; char type.0=pset,1=OR,2=fuchi.

STRADRS		DW	0		; string.

FLNAME_ADRS	DW	0		; ファイル名
XX1		DW	0		; ＰＵＴＸ座標
YY1		DW	0		; ＰＵＴＹ座標
NUM1		DW	0		;
NUM2		DW	0		;
NUM3		DW	0		;

PARA_SHINCHO	DW	0		; 身長
PARA_TAIJYU	DW	0		; 体重
PARA_BUST	DW	0		; バスト
PARA_WAIST	DW	0		; ウエスト
PARA_HIP	DW	0		; ヒップ

DATA	ENDS

	END
;
;	end of "PICTUER.ASM"
;
