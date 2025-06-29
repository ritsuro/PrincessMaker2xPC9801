; "MUSYAE.ASM" 486/50 make by R.H 1992/07/18
;
;
;	プリンセスメーカー２
;	武者修行
;
;
; 注意　バンク数が増えたら次の定数を変更すること。
;
;		BANK_MAX		; バンク確保数
;
; マップタイプ
;
;	MAP_TYPE	; map type.
;		1=East,2=West,3=South,4=North1,5=North2,6=North3
;
; ロードするバンクの指定
;
;	LOAD_BANK_B_SW	DW	01111111B	;(+12eh) load bank bit switch.
;				||||||||
;				76543210 <- bank number.
;
; ファンクション
;
;	-I- FUNCTION_NUM : function number.
;		1=マップロード
;		2=歩く
;		    -O- CH : orginal dir x.
;			CL : orginal dir y.
;			DX : 娘の向き 0=front,1=back,2=left,3=right.
;			SI : grand level.
;			EXIT_STATUS  : exit status.
;			0=normal.
;			1=place ivent.
;			2=timeout.
;			3=camp.
;			4=event50.
;		3=効果
;			SUB_FUNCTION :
;			1=穴へ,2=穴から,3=沼へ,4=沼から
;			5=キャンプ,6=キャンプたたむ,7=滝
;			8=上へ,9=下へ,10=上から,11=下から,12=落下
;			13=左へ,14=右へ,15=武神から逃げる
;		    -O- DX : 娘の向き 0=front,1=back,2=left,3=right.
;			SI : grand level.
;		4=再表示
;			SUB_FUNCTION :
;			1=全部,2=背景のみ
;		5=RPG mode.
;		6=normal mode.
;		7=buffer reload.
;		8=マップ再ロード
;		9=バンクロードの指定
;			SUB_FUNCTION : load bank bit switch.
;			bit0:bank0, bit1:bank1, bit2:bank2....
;		10=娘の向き設定
;			SUB_FUNCTION :
;			0=front.1=back,2=left,3=right.
;		11=マップシフト
;			PARAM01 : map shift x.
;			PARAM02 : map shift y.
;			PARAM03 : girl shift x.
;			PARAM04 : girl shift y.
;			PARAM05 : shift count.
;		12=キャンプ
;			SUB_FUNCTION :
;			1=キャンプ張る,2=キャンプをたたむ
;		13=セレクト "str1,str2,str3"
;			PARAM01 : セレクト単語列(segment)
;			PARAM02 : セレクト単語列(offset)
;			PARAM03 : セレクトアニメON/OFF
;		    -O- DX : select number.
;		14=娘の向き取得
;		　　-O- DX : 0=front.1=back,2=left,3=right.
;		15=マップの修正
;			SUB_FUNCTION :
;			1=西の泉が枯れた
;			2=北の守護星現れる
;			3=北の守護星への階段が消える
;			4=北の武神への階段が消える
;			5=宝箱OPEN.1
;			6=宝箱OPEN.2
;			7=宝箱OPEN.3
;			8=宝箱OPEN.4
;			9=宝箱OPEN.5
;			10=宝箱CLOSE.1
;			11=宝箱CLOSE.2
;			12=宝箱CLOSE.3
;			13=宝箱CLOSE.4
;			14=宝箱CLOSE.5
;		16=守護星のセット
;			SUB_FUNCTION :
;			0=太陽神ソル
;			1=月神ザ・ムーン
;			2=火星神マーズ
;			3=水星神マーキュリー
;			4=木星神ジュピター
;			5=金星神ビーナス
;			6=土星神サターン
;			7=天王星神ウラヌス
;			8=海王星神ネプチューン
;			9=冥王星神ハーデス
;
;		17=マップデータのみ再ロード
;
;		18=感受性等のセット(EVENTに影響)
;			PARAM01 : 感受性
;
;
; 外部ファンクション参照
;
;	main function inter.
;	call MAIN_FUNCTION_INTER
;
;	main functions.
;
;	BX=1 : file load.
;		-I- ES:SI : file name.
;		    DX : memory segment address.
;		    DI : memory offset address.
;		    CX : memory size.
;		-O- BX : 0=normal,1=error.
;		    CX : data length.
;
;	BX=2 : disk save.
;		-I- ES:SI : file name.
;		    DX : memory segment address.
;		    DI : memory offset address.
;		    CX : memory size.
;		-O- BX : 0=normal,1=error.
;
;	BX=3 : disk check.
;		-I- ES:SI : file name.
;		-O- BX : 0=none,1=ok.
;
;	BX=4 : disk kill.
;		-I- ES:SI : file name.
;		-O- BX : 0=normal,1=error.
;
;	BX=5 : get vram address.
;		-O- ES:SI : vram table address.
;		    BX : machine ID.
;
;	BX=6 : get buffer address.
;		-I- SI :0=通常パターンバッファ・後半
;			1=pless/unpless segment・後半
;			2=text buffer.・後半
;			3=通常パターンバッファ・後半
;			4=pless/unpless segment・後半
;			5=text buffer・後半
;			6=varturl vram・後半
;			7=varturl vram・中間
;			8=process work buffer 52k.
;		-O- ES:DI : buffer address.
;
;	BX=7 : マウス読み込み
;		-O- CX : Ｘ座標
;		    BX : Ｙ座標
;		    DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;		    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）
;		    SI : mouse locate direction x(+-)
;		    DI : mouse locate direction y(+-)
;
;	BX=8 : マウス方向
;		-O- CX : mouse locate direction x(+-)
;		    DX : mouse locate direction y(+-)
;
;	BX=9 : キーボード機能のＯＮ／ＯＦＦ
;		-I- CX : 1=ＯＮ,0=ＯＦＦ
;
;	BX=10 : timer.
;		-I- CX : wait timer count.
;
;	BX=11 : timer end wait.
;
;	BX=12 : process time out check.
;		-O- BX : 1=timer end.
;		    DX : now counter.
;
;	BX=13 : 98 vram switch.
;		-I- CX : 0=VRAM0 show, 1=VRAM1 show.
;		    DX : 0=VRAM0 write,1=VRAM1 write.
;
;	BX=14 : ＲＰＧ方向選択・ｳｲﾝﾄﾞｳOPEN
;
;	BX=15 : ＲＰＧ方向選択・ｳｲﾝﾄﾞｳCLOSE
;
;	BX=16 : ＲＰＧ方向選択・ｳｲﾝﾄﾞｳREAD
;		-O- BX : ボタン選択番号 0:none,1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ
;		    CX : x direction step.
;		    DX : y direction step.
;
;	BX=17 : WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG OPEN.
;		-I- ES:[SI]  : 指定文字列
;
;	BX=18 : WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG CLOSE.
;
;	BX=19 : WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG READ.
;		-O- BX : ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／ユーザ選択番号
;		       : =FFFFH : 指定なし
;		       : = -2   : 何も入力無し
;
;	BX=20 : timer check.
;		-O- BX : 0=timer now, 1=timer end.
;		    CX : now counter.
;
;	BX=21 : randam.
;		-I- CX : 最大値(1-200)
;		-O- BX : 乱数
;
;	work buffer.
;			      reload.
;SEG PARTBUF	32700			; #0 通常パターンバッファ
;SEG PLESS	32700		*	; #1 pless/unpless segment.
;SEG TEXTBUF	32700			; #2 text buffer.
;SEG PARTBUF	32700+16390		; #3 通常パターンバッファ
;SEG PLESS	32700+16390		; #4 pless/unpless segment.
;SEG TEXTBUF	32700+16390		; #5 text buffer.
;SEG VVVRAM	32700 - 16390		; #6 varturl vram.
;SEG VVVRAM	32700		*	; #7 varturl vram.
;SEG PROCWRK	51200			; #8 process work buffer 52k.
;
;
;
; 50 拾い物
;【 概　要 】武者修行の道中に，落し物を拾う．
;【 いつ？ 】武者修行実行中．全マップで発生．
;【発生条件】１０歩移動ごとに判定．感受性値が高いほど拾いやすい．
;【 効　果 】拾う確率は下記の通り．
;		感受性		拾う確率
;		０～４９	０％
;		５０～１４９	４％
;		１５０～２４９	６％
;		２５０～３４９	１０％
;		４００以上	２０％
;
;
; public subroutine.

INCLUDE	TSTSET.INC

MFLAG_PCAT	EQU	1		; PC/AT
MFLAG_PC98	EQU	2		; PC9801

RETFAR	MACRO			; ＦＡＲリターン
	DB	11001011B	; RETF
	ENDM

VGAVRAM_SEG_G0	EQU	0A000H+1H	; ＶＲＡＭプレーン０
VGAVRAM_SEG_G1	EQU	0A000H+2H	; ＶＲＡＭプレーン１
VGAVRAM_SEG_G2	EQU	0A000H+3H	; ＶＲＡＭプレーン２
VGAVRAM_SEG_G3	EQU	0A000H+4H	; ＶＲＡＭプレーン３
VGAVRMWIDTH	EQU	80		; ＶＲＡＭ幅

BANK_MAX	EQU	7		; バンク確保数

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	MAIN_FUNCTION_INTER		; main function inter.
PUBLIC	CHK_EVENT50N			; event.50 拾い物
;*;PUBLIC KEYHLT			; キーボード機能のＯＮ／ＯＦＦ
PUBLIC	TIMER_SET			; タイマーセット
PUBLIC	TIMER_WAIT			; タイマー待ち
PUBLIC	TIMER_CHECK			; タイマーチェック
PUBLIC	TIME_OUT_CHECK			; process time out check.
PUBLIC	VRAM98CHANGE			; 98 vram change.
PUBLIC	XRANDAM				; randam.

EXTRN	MAP_LOAD:NEAR			; map load.
EXTRN	MAP_RELOAD:NEAR			; map reload load.
EXTRN	MAP_MAP_RELOAD:NEAR		; map map reload.
EXTRN	MAP_STRAT:NEAR			; map start.
EXTRN	MAP_MOVE:NEAR			; map move.
EXTRN	MAP_IN_SLCT:NEAR		; map in select.
EXTRN	MAP_SHIFT:NEAR			; map shift.
EXTRN	MAP_EFC_SET:NEAR		; map effect set.
EXTRN	MAP_REDRAW:NEAR			; map redraw.
EXTRN	MAP_RPG_MODE:NEAR		; map RPG mode.
EXTRN	MAP_NORMAL_MODE:NEAR		; map normal mode.
EXTRN	MAP_SETING:NEAR			; map setting.
EXTRN	MAP_SET_GIRL_DIR:NEAR		; map set girl direction.
EXTRN	MAP_GET_GIRL_DIR:NEAR		; map get girl direction.
EXTRN	MAP_CAMP:NEAR			; map camp.
EXTRN	MAP_EDITION:NEAR		; map edition.
EXTRN	MAP_SYUGO_SET:NEAR		; map syugo set.

EXTRN	MAINLOOP:NEAR			; main loop.


; ****************************************************
;	PROGRAM CODE
; ****************************************************

	ORG	100H
START:
	JMP	SHORT FINALE

	ORG	102H			;
		DW	FUNCTION_ENTRY	;(+102h) function entry.
MAIN_F_JMP_OFS	DW	0		;(+104h) main function inter offset.
MAIN_F_JMP_SEG	DW	0		;(+106h) main function inter segment.
EXIT_STATUS	DW	0		;(+108h) exit status.
FUNCTION_NUM	DW	0		;(+10ah) function number.
MAP_TYPE	DW	1		;(+10ch) map type.1=E,2=W,S,N1,N2,N3
MAP_SIZE_X	DW	200		;(+10eh) map size x.
MAP_SIZE_Y	DW	100		;(+110h) map size y.
MAP_LOC_X	DW	0		;(+112h) map location x.
MAP_LOC_Y	DW	27		;(+114h) map location y.
GIRL_LOC_X	DW	12		;(+116h) girl location x.
GIRL_LOC_Y	DW	10		;(+118h) girl location y.
ANIME_XCHG_CHP1	DW	00H+180H	;(+11ah) anime exchange chip1.
ANIME_XCHG_END1	DW	01H+180H	;(+11ch) anime exchange end1.
ANIME_XCHG_CHP2	DW	40H+180H	;(+11eh) anime exchange chip2.
ANIME_XCHG_END2	DW	41H+180H	;(+120h) anime exchange end2.
ANIME_XCHG_CHP3	DW	00H+180H	;(+122h) anime exchange chip3.
ANIME_XCHG_END3	DW	01H+180H	;(+124h) anime exchange end3.
ANIME_XCHG_CHP4	DW	40H+180H	;(+126h) anime exchange chip4.
ANIME_XCHG_END4	DW	41H+180H	;(+128h) anime exchange end4.
ANIME_MODE	DW	1		;(+12ah) anime mode.
SUB_FUNCTION	DW	0		;(+12ch) sub function number.
LOAD_BANK_B_SW	DW	01111111B	;(+12eh) load bank bit switch.
EFC_FALLS_LEN	DW	1		;(+130h) effect falls length.
PARAM01		DW	0		;(+132h) parameter 1.
PARAM02		DW	0		;(+134h) parameter 2.
PARAM03		DW	0		;(+136h) parameter 3.
PARAM04		DW	0		;(+138h) parameter 4.
PARAM05		DW	0		;(+13ah) parameter 5.
PARAM06		DW	0		;(+13ch) parameter 6.
DEBUGXX		DW	0		;(+13eh) debug mode.

FINALE:
	MOV	DX,OFFSET MY_MESSAGE	;
	MOV	AH,09H			; print string.
	INT	21H			;
	MOV	AH,4CH			; return to DOS.
	MOV	AL,0			;
	INT	21H			; end.
	JMP	$			;


; ****************************************************
;	function entry.
;	-I- FUNCTION_NUM : function number.
;		1=マップロード
;		2=歩く
;		3=効果
;		4=再表示
;		5=RPG mode.
;		6=normal mode.
;		7=buffer reload.
;		8=マップ再ロード
;		9=バンクロードの指定
;		10=娘の向き設定
;		11=マップシフト
;		12=キャンプ
;		13=セレクト
;		14=娘の向き取得
;		15=マップの修正
;		16=守護星のセット
;		17=マップデータのみ再ロード
;		18=感受性等のセット(EVENTに影響)
; ****************************************************

FUNCTION_ENTRY	PROC	NEAR
	MOV	EXIT_STATUS,0			; exit status.
	MOV	AX,FUNCTION_NUM			; function number.

	CMP	AL,1				; 1=マップロード
	JE	FUNCTION_ENTRY_LOAD		;
	CMP	AL,2				; 2=歩く
	JE	FUNCTION_ENTRY_WALK		;
	CMP	AL,3				; 3=効果
	JE	FUNCTION_ENTRY_EFFECT		;
	CMP	AL,4				; 4=再表示
	JE	FUNCTION_ENTRY_REDRAW		;
	CMP	AL,5				; 5=RPG mode.
	JE	FUNCTION_ENTRY_RPG_MODE		;
	CMP	AL,6				; 6=normal mode.
	JE	FUNCTION_ENTRY_NORMAL		;
	CMP	AL,7				; 7=buffer reload.
	JE	FUNCTION_ENTRY_RELOAD		;
	CMP	AL,8				; 8=マップ再ロード
	JE	FUNCTION_ENTRY_MAPSET		;
	CMP	AL,9				; 9=バンクロードの指定
	JE	FUNCTION_ENTRY_BANKLOAD		;
	CMP	AL,10				; 10=娘の向き設定
	JE	FUNCTION_ENTRY_GIRL_DIR		;
	CMP	AL,11				; 11=マップシフト
	JE	FUNCTION_ENTRY_MAP_SHIFT	;
	CMP	AL,12				; 12=キャンプ
	JE	FUNCTION_ENTRY_CAMP		;
	CMP	AL,13				; 13=セレクト
	JE	FUNCTION_ENTRY_SLCT		;
	CMP	AL,14				; 14=娘の向き取得
	JE	FUNCTION_ENTRY_GET_DIR		;
	CMP	AL,15				; 15=マップの修正
	JE	FUNCTION_ENTRY_EDIT		;
	CMP	AL,16				; 16=守護星のセット
	JE	FUNCTION_ENTRY_MAP_SYUGO_SET	;
	CMP	AL,17				; 17=マップデータのみ再ロード
	JE	FUNCTION_ENTRY_MAPONLY_LOAD	;
	CMP	AL,18				; 18=感受性等のセット(EVENTに影響)
	JE	FUNCTION_ENTRY_PARASET		;
	JMP	FUNCTION_ENTRY_EXIT		;

FUNCTION_ENTRY_LOAD:
	MOV	AX,MAP_TYPE			; map type.
	MOV	BX,LOAD_BANK_B_SW		; load bank bit switch.
	CALL	MAP_SETING			; map setting.
	CALL	ALL_LOAD			; all load.
	CALL	MAP_STRAT			; map start.
	MOV	AX,1				; 1=全部,2=背景のみ
	CALL	MAP_REDRAW			; map redraw.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_WALK:
	CALL	MAP_MOVE			; map move.
	MOV	DX,AX				; 0=front,1=back...
	MOV	SI,BX				; grand level.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_EFFECT:
	MOV	AX,SUB_FUNCTION			; sub function number.
	CALL	MAP_EFC_SET			; map effect set.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_REDRAW:				;
	CALL	MAP_STRAT			; map start.
	MOV	AX,SUB_FUNCTION			; 1=全部,2=背景のみ
	CALL	MAP_REDRAW			; map redraw.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_RPG_MODE:
	CALL	MAP_RPG_MODE			; map RPG mode.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_NORMAL:
	CALL	MAP_NORMAL_MODE			; map normal mode.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_RELOAD:
	CALL	MAP_RELOAD			; map reload load.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_MAPSET:
	MOV	AX,MAP_TYPE			; map type.
	MOV	BX,LOAD_BANK_B_SW		; load bank bit switch.
	CALL	MAP_SETING			; map setting.
	CALL	ALL_LOAD			; all load.
	CALL	MAP_STRAT			; map start.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_BANKLOAD:
	MOV	AX,SUB_FUNCTION			; sub function number.
	MOV	LOAD_BANK_B_SW,AX		; load bank bit switch.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_GIRL_DIR:
	MOV	AX,SUB_FUNCTION			; sub function number.
	CALL	MAP_SET_GIRL_DIR		; map set girl direction.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_MAP_SHIFT:
	CALL	MAP_SHIFT			; map shift.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_CAMP:
	MOV	DX,SUB_FUNCTION			; sub function number.
	CALL	MAP_CAMP			; map camp.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_SLCT:
	MOV	DX,PARAM01			; セレクト単語列(segment)
	MOV	SI,PARAM02			; セレクト単語列(offset)
	CALL	GET_STRING			; get string.
	MOV	SI,OFFSET STR_BUFFER		; string buffer.
	MOV	AX,PARAM03			; セレクトアニメON/OFF
	CALL	MAP_IN_SLCT			; map in select.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_GET_DIR:
	CALL	MAP_GET_GIRL_DIR		; map get girl direction.
	MOV	DX,AX				; 0=front,1=back...
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_EDIT:
	MOV	AX,SUB_FUNCTION			;
	CALL	MAP_EDITION			; map edition.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_MAP_SYUGO_SET:
	MOV	AX,SUB_FUNCTION			;
	CALL	MAP_SYUGO_SET			; map syugo set.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_MAPONLY_LOAD:
	CALL	MAP_MAP_RELOAD			; map map reload.
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_PARASET:				;感受性等のセット(EVENTに影響)
	MOVX	B_KANJUSEI,PARAM01		;感受性等
	JMP	FUNCTION_ENTRY_EXIT

FUNCTION_ENTRY_EXIT:

	RETFAR
FUNCTION_ENTRY	ENDP


; ****************************************************
;	all load.
; ****************************************************

ALL_LOAD	PROC	NEAR

	; get vram address.

	MOV	BX,5			; get vram address.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	MOV	MFLAG_MY,BX		; machine flag.

	MOV	AX,DS
	MOV	DX,ES
	MOV	DI,OFFSET ARAVRM	; ＶＲＡＭプレーン
	MOV	CX,5			;
	PUSH	DS			;
	MOV	ES,AX			;
	MOV	DS,DX			;
	REP	MOVSW			; copy.
	POP	DS			;

	; get buffer address.

	MOV	SI,0			; 0=通常パターンバッファ・後半
	MOV	CX,BANK_MAX		; バンク確保数
ALL_LOAD_LOOP:				;
	PUSH	CX			;
	PUSH	SI			;
	MOV	BX,6			; get buffer address.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	POP	SI			;
	SHL	SI,1			; word pointer.
	MOV	BUF_BANK_OFS[SI],DI	; bank buffer offset.
	MOV	BUF_BANK_SEG[SI],ES	; bank buffer segment.
	SHR	SI,1			;
	INC	SI			;
	POP	CX			;
	LOOP	ALL_LOAD_LOOP		;

	MOV	BX,6			; get buffer address.
	MOV	SI,7			; 7=varturl vram.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	MOV	BUF_ATTR_OFS,DI		; attribute buffer offset.
	MOV	BUF_ATTR_SEG,ES		; attribute buffer segment.

	MOV	BX,6			; get buffer address.
	MOV	SI,8			; 8=process work buffer 52k.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	MOV	BUF_MAP_OFS,DI		; my program byte size.
	MOV	BUF_MAP_SEG,ES		; map buffer segment.

	CALL	MAP_LOAD		; map load.
	RET
ALL_LOAD	ENDP


; ****************************************************
;	get string.
;	-I- DX:SI      : source string.
;	-O- STR_BUFFER : string buffer.
; ****************************************************

GET_STRING	PROC	NEAR
	MOVX	ES,DS			;
	MOV	DI,OFFSET STR_BUFFER	; string buffer.
	MOV	CX,STR_LENMAX		; string length.
	PUSH	DS			;
	MOV	DS,DX			;
	REP	MOVSB			;
	POP	DS			;
	RET
GET_STRING	ENDP


; ****************************************************
;	main function inter.
;	-I/O- BX,CX,DX,SI,DI,ES : user parameter.
; ****************************************************

MAIN_FUNCTION_INTER	PROC	NEAR
	PUSH	DS
	MOV	AX,CS
	PUSH	AX
	MOV	AX,OFFSET MAIN_FUNCTION_INTER_RET
	PUSH	AX
	PUSH	MAIN_F_JMP_SEG		; main function inter segment.
	PUSH	MAIN_F_JMP_OFS		; main function inter offset.
	RETFAR

MAIN_FUNCTION_INTER_RET:
	POP	DS
	RET
MAIN_FUNCTION_INTER	ENDP


; ****************************************************
;	event.50 拾い物
;	【 概　要 】武者修行の道中に，落し物を拾う．
;	【 いつ？ 】武者修行実行中．全マップで発生．
;	【発生条件】１０歩移動ごとに判定．感受性値が高いほど拾いやすい．
;	【 効　果 】拾う確率は下記の通り．
;		感受性		拾う確率
;		０～１４９	０％
;		１５０～３９９	６％
;		４００以上	１０％
;	-O- AX : 0=無し,1=あり
; ****************************************************

CHK_EVENT50N	PROC	NEAR
	MOV	AX,B_KANJUSEI		; 感受性
	CMP	AX,150
	JB	CHK_EVENT50N_NONE

	MOV	DX,6

	CMP	AX,400
	JB	CHK_EVENT50N_CHK

	MOV	DX,10			;

CHK_EVENT50N_CHK:			;
	PUSH	DX			;
	MOV	CX,100			; 最大値(1-200)
	CALL	XRANDAM			; randam.
	POP	DX			;
	CMP	BX,DX			; %
	JB	CHK_EVENT50N_OK		;

CHK_EVENT50N_NONE:
	MOV	AX,0			; 0=無し
	RET
CHK_EVENT50N_OK:
	MOV	AX,1			; 1=あり
	RET
CHK_EVENT50N	ENDP


;*;; ****************************************************
;*;;	キーボード機能のＯＮ／ＯＦＦ
;*;;	-I- AX : 1=ＯＮ,0=ＯＦＦ
;*;; ****************************************************
;*;
;*;KEYHLT	PROC	NEAR
;*;	MOV	CX,AX			;
;*;	MOV	BX,9			; キーボード機能のＯＮ／ＯＦＦ
;*;	CALL	MAIN_FUNCTION_INTER	; main function inter.
;*;	RET
;*;KEYHLT	ENDP


; ****************************************************
;	タイマーセット
;	-I- AX : wait timer count.
; ****************************************************

TIMER_SET	PROC	NEAR
	MOV	CX,AX			; wait timer count.
	MOV	BX,10			; timer.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	RET
TIMER_SET	ENDP


; ****************************************************
;	タイマー待ち
; ****************************************************

TIMER_WAIT	PROC	NEAR
	MOV	BX,11			; timer end wait.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	RET
TIMER_WAIT	ENDP


; ****************************************************
;	タイマーチェック
;	-O- BX : 0=timer now, 1=timer end.
;	    CX : now counter.
; ****************************************************

TIMER_CHECK	PROC	NEAR
	MOV	BX,20			; timer check.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	RET
TIMER_CHECK	ENDP


; ****************************************************
;	process time out check.
;	-O- BX : 1=timer end.
;	    DX : now counter.
; ****************************************************

TIME_OUT_CHECK	PROC	NEAR
	MOV	BX,12			; process time out check.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	RET
TIME_OUT_CHECK	ENDP


; ****************************************************
;	98 vram change.
;	-I- CX : 0=VRAM0 show, 1=VRAM1 show.
;	    DX : 0=VRAM0 write,1=VRAM1 write.
; ****************************************************

VRAM98CHANGE	PROC	NEAR
	MOV	BX,13			; 98 vram switch.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	RET
VRAM98CHANGE	ENDP


; ****************************************************
;	randam.
;	-I- CX : 最大値(1-200)
;	-O- BX : 乱数
; ****************************************************

XRANDAM	PROC	NEAR
	MOV	BX,21			; randam.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	RET
XRANDAM	ENDP


; ****************************************************
;	DATA
; ****************************************************

PUBLIC	EXIT_STATUS			; exit status.
PUBLIC	MAP_SIZE_X			; map size x.
PUBLIC	MAP_SIZE_Y			; map size y.
PUBLIC	MAP_LOC_X			; map location x.
PUBLIC	MAP_LOC_Y			; map location y.
PUBLIC	GIRL_LOC_X			; girl location x.
PUBLIC	GIRL_LOC_Y			; girl location y.
PUBLIC	ANIME_XCHG_CHP1			; anime exchange chip1.
PUBLIC	ANIME_XCHG_END1			; anime exchange end1.
PUBLIC	ANIME_XCHG_CHP2			; anime exchange chip2.
PUBLIC	ANIME_XCHG_END2			; anime exchange end2.
PUBLIC	ANIME_XCHG_CHP3			; anime exchange chip3.
PUBLIC	ANIME_XCHG_END3			; anime exchange end3.
PUBLIC	ANIME_XCHG_CHP4			; anime exchange chip4.
PUBLIC	ANIME_XCHG_END4			; anime exchange end4.
PUBLIC	MAP_TYPE			; map type.
PUBLIC	EFC_FALLS_LEN			; effect falls length.
PUBLIC	PARAM01				; parameter 1.
PUBLIC	PARAM02				; parameter 2.
PUBLIC	PARAM03				; parameter 3.
PUBLIC	PARAM04				; parameter 4.
PUBLIC	PARAM05				; parameter 5.
PUBLIC	PARAM06				; parameter 6.

PUBLIC	MFLAG_MY			; machine flag.
PUBLIC	ARAVRM				; ＶＲＡＭプレーン
PUBLIC	BUF_MAP_OFS			; map buffer offset.
PUBLIC	BUF_MAP_SEG			; map buffer segment.
PUBLIC	BUF_ATTR_OFS			; attribute buffer offset.
PUBLIC	BUF_ATTR_SEG			; attribute buffer segment.
PUBLIC	BUF_BANK_OFS			; bank buffer offset.
PUBLIC	BUF_BANK_SEG			; bank buffer segment.

MFLAG_MY	DW	1		; machine flag.

ARAVRM		LABEL	WORD		; ＶＲＡＭプレーン
		DW	VGAVRAM_SEG_G0	; ＶＲＡＭプレーン０
		DW	VGAVRAM_SEG_G1	; ＶＲＡＭプレーン１
		DW	VGAVRAM_SEG_G2	; ＶＲＡＭプレーン２
		DW	VGAVRAM_SEG_G3	; ＶＲＡＭプレーン３
		DW	VGAVRMWIDTH	; ＶＲＡＭ幅

BUF_MAP_OFS	DW	0		; map buffer offset.
BUF_MAP_SEG	DW	0		; map buffer segment.

BUF_ATTR_OFS	DW	0		; attribute buffer offset.
BUF_ATTR_SEG	DW	0		; attribute buffer segment.

BUF_BANK_OFS	DW	BANK_MAX DUP (0)	; bank buffer offset.
BUF_BANK_SEG	DW	BANK_MAX DUP (0)	; bank buffer segment.

B_KANJUSEI	DW	0		; 感受性

STR_BUFFER	DB	128 DUP (0),0,0	; string buffer.
STR_LENMAX	DW	128		; string length.

MY_MESSAGE	DB "「プリンセスメーカー２」$",0

CODE	ENDS

	END	START
;
;	end of "MUSYAE.ASM"
;
