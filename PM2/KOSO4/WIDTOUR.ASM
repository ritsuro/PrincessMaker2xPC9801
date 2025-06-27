; "WIDTOUR.ASM" PC-9801UV11 make by R.H 1991/01/18
;
;
;	ＷＩＮＤＯＷＳ／トーナメント表
;
;
;
;	WIDTOUR		:	トーナメント表
;
;
; (C) 1991 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC

MOVXBW	MACRO	DEST,SOUR
	MOV	AH,0
	MOV	AL,SOUR
	MOV	DEST,AX
	ENDM

CHAR_NUMBER_MUSUME	EQU	1	; 甲は自分の娘のキャラ番号？

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA

; ****************************************************
;	トーナメント表
;	-I- AX : function.
;
;	AX=1 : トーナメント表スタート
;	AX=2 : エレメント・テスト
;		-I- BX : 第何試合か？(1-4)
;		    CX : 組み合せ番号(1-8)
;		    DX : 状態 1=甲の勝ち,2=乙の勝ち,3=試合開始
;	AX=3 : エントリィ名前表示
;		-I- BX : エントリィ番号
;		    CX : エントリィ名前
;	AX=4 : トーナメント・エントリィ登録
;		-I- BX : エントリィ番号(表の左上から1,2,3...)
;		    CX : キャラクタ番号
;	AX=5 : トーナメント試合・キックオフ
;		-I- BX : 第何試合か？
;		-O- AX : 組み合せ数
;	AX=6 : トーナメント試合・組み合せ
;		-I- BX : 組み合せ番号(1-n)
;		-O- AX : 試合属性 0=他人の試合,1=甲自分の娘,2=乙自分の娘
;		    CX : 組み合せ・甲チーム
;		    DX : 組み合せ・乙チーム
;		    SI : キャラクタ番号・甲チーム
;		    DI : キャラクタ番号・乙チーム
;	AX=7 : トーナメント試合・衝撃！
;	AX=8 : トーナメント試合・勝敗
;		-I- BX : 1=甲が勝ち,2=乙が勝ち
;		    CX : 第何試合か？
;		    DX : 組み合せ番号
;	AX=9 : トーナメント試合・オフサイド
;		-O- AX : 状態 0=通常,1=全試合終了
;		    SI : 優勝キャラクタ番号
;		    DI : 準優勝キャラクタ番号
;	AX=10 : トーナメント・キャラクタ番号取得
;		-I- BX : エントリィ番号(表の左上から1,2,3...)
;		-O- CX : キャラクタ番号
;	AX=11 : トーナメント表・再描画
;	AX=12 : 対戦相手の検索
;		-I- BX : 対戦の片方
;		-O- AX : 1=見つかった,0=見つからない
;		    BX : 組み合せ番号(1-n)
;		    CX : 検索された対戦相手
;	AX=13 : トーナメント表飾り再描画
; ****************************************************

FUNC	WIDTOUR
	DEC	AX
	CMP	AX,(WIDTOUR_TBL_E-WIDTOUR_TBL)/2
	JB	WIDTOUR_START
	RET
WIDTOUR_START:
	MOV	REG_BP,BP
	MOV	BP,AX
	SHL	BP,1				; word pointer.
	CALL	WORD PTR DS:WIDTOUR_TBL[BP]	; jump label.
	RET
FEND	WIDTOUR


; ****************************************************
;	トーナメント表スタート
; ****************************************************

TOUR_START	PROC	NEAR
	CALL	ELE_CLEAR			; エレメントの設定クリア
	CALL	TOUR_CLEAR			; トーナメントの全クリア
;;;	CALL	ELE_ALL_PLOT			; エレメントの全表示
	RET
TOUR_START	ENDP


; ****************************************************
;	トーナメント表飾り再描画
; ****************************************************

TOUR_KZ_REDRAW	PROC	NEAR
	CALL	ELE_WHT_LINE_PLOT		; エレメントの白線表示
	RET
TOUR_KZ_REDRAW	ENDP


; ****************************************************
;	エレメント・テスト
;	-I- BX : 第何試合か？(1-4)
;	    CX : 組み合せ番号(1-8)
;	    DX : 状態 1=甲の勝ち,2=乙の勝ち,3=試合開始
; ****************************************************

TOUR_SHOW	PROC	NEAR
	MOV	TOUR_LEVEL,BX			; 第何試合か？
	MOV	TOUR_LINK,CX			; 組み合せ番号
	MOV	TOUR_JYOUTAI,DX			; 状態
	CALL	ELE_SET				; エレメントの設定
	CALL	ELE_ALL_PLOT			; エレメントの全表示
	RET
TOUR_SHOW	ENDP


; ****************************************************
;	エントリィ名前表示
;	-I- BX : エントリィ番号(1-16)
;	    CX : エントリィ名前
; ****************************************************

TOUR_NAME	PROC	NEAR
	MOV	ENTRY_NUMBER,BX			; エントリィ番号
	MOV	ENTRY_NAMEADRS,CX		; エントリィ名前
	CALL	ENTRY_NAME_DISP			; エントリィ名
	RET
TOUR_NAME	ENDP


; ****************************************************
;	トーナメント・エントリィ登録
;	-I- BX : エントリィ番号(表の左上から1,2,3...)
;	    CX : キャラクタ番号
; ****************************************************

TOUR_CHAR_SET	PROC	NEAR
	DEC	BX
	CMP	BX,16
	JNB	TOUR_CHAR_SET_EXIT

	ADD	BX,ADRS_ENTRY_TABLE		; エントリィテーブルアドレス
	MOV	DS:[BX],CL
TOUR_CHAR_SET_EXIT:
	RET
TOUR_CHAR_SET	ENDP


; ****************************************************
;	トーナメント・キャラクタ番号取得
;	-I- BX : エントリィ番号(表の左上から1,2,3...)
;	-O- CX : キャラクタ番号
; ****************************************************

TOUR_CHAR_GET	PROC	NEAR
	DEC	BX
	CMP	BX,16
	JNB	TOUR_CHAR_GET_OVER

	ADD	BX,ADRS_ENTRY_TABLE		; エントリィテーブルアドレス
	MOV	CL,DS:[BX]
	MOV	CH,0
	RET
TOUR_CHAR_GET_OVER:
	MOV	CX,0
	RET
TOUR_CHAR_GET	ENDP


; ****************************************************
;	トーナメント表・再描画
; ****************************************************

TOUR_REDRAW	PROC	NEAR
	CALL	ELE_ALL_PLOT			; エレメントの全表示
	RET
TOUR_REDRAW	ENDP


; ****************************************************
;	対戦相手の検索
;	-I- BX : 対戦の片方
;	-O- AX : 1=見つかった,0=見つからない
;	    BX : 組み合せ番号(1-n)
;	    CX : 検索された対戦相手
; ****************************************************

TOUR_SCH_FIGHT	PROC	NEAR
	MOV	DX,BX				; 対戦の片方

	MOV	CH,0				;
	MOV	CL,TOUR_KUMI_KOH_TBL[0]		; 組み合せ表 甲 [0]=組み合せ数
	MOV	DI,ADRS_ENTRY_TABLE		; エントリィテーブルアドレス
	MOV	SI,1				; byte pointer.
TOUR_SCH_FIGHT_LOOP:
	MOV	BH,0				;
	MOV	BL,TOUR_KUMI_KOH_TBL[SI]	; 組み合せ表 甲
	DEC	BX				; -1
	CMP	DL,DS:[DI][BX]			;
	JNE	TOUR_SCH_FIGHT_NEXT		;
	MOV	BH,0				;
	MOV	BL,TOUR_KUMI_OTSU_TBL[SI]	; 組み合せ表 乙
	DEC	BX				; -1
	MOV	CL,DS:[DI][BX]			;
	MOV	CH,0				;
	JMP	TOUR_SCH_FIGHT_OK
TOUR_SCH_FIGHT_NEXT:
	INC	SI
	LOOP	TOUR_SCH_FIGHT_LOOP

	MOV	CH,0				;
	MOV	CL,TOUR_KUMI_OTSU_TBL[0]	; 組み合せ表 乙 [0]=組み合せ数
	MOV	SI,1				; byte pointer.
TOUR_SCH_FIGHT_LOOP2:
	MOV	BH,0				;
	MOV	BL,TOUR_KUMI_OTSU_TBL[SI]	; 組み合せ表 甲
	DEC	BX				; -1
	CMP	DL,DS:[DI][BX]			;
	JNE	TOUR_SCH_FIGHT_NEXT2		;
	MOV	BH,0				;
	MOV	BL,TOUR_KUMI_KOH_TBL[SI]	; 組み合せ表 乙
	DEC	BX				; -1
	MOV	CL,DS:[DI][BX]			;
	MOV	CH,0				;
	JMP	TOUR_SCH_FIGHT_OK
TOUR_SCH_FIGHT_NEXT2:
	INC	SI
	LOOP	TOUR_SCH_FIGHT_LOOP2

TOUR_SCH_FIGHT_NONE:
	MOV	AX,0				; 0=見つからない
	RET
TOUR_SCH_FIGHT_OK:
	MOV	BX,SI				; 組み合せ番号(1-n)
	MOV	AX,1				; 1=見つかった
	RET
TOUR_SCH_FIGHT	ENDP


; ****************************************************
;	トーナメント試合・キックオフ
;	-I- BX : 第何試合か？
;	-O- AX : 組み合せ数
; ****************************************************

TOUR_KICKOFF	PROC	NEAR
	MOV	TOUR_LEVEL,BX			; 第何試合か？
	CALL	KUMIAWASE			; 組み合せ表
	CALL	TOURNAMENT_SETUP		; トーナメント表セットアップ
	MOV	AX,TOUR_KUMI_CNT		; 組み合せ数
	RET
TOUR_KICKOFF	ENDP


; ****************************************************
;	トーナメント試合・組み合せ
;	-I- BX : 組み合せ番号(1-n)
;	-O- AX : 試合属性 0=他人の試合,1=甲自分の娘,2=乙自分の娘
;	    CX : 組み合せ・甲チーム
;	    DX : 組み合せ・乙チーム
;	    SI : キャラクタ番号・甲チーム
;	    DI : キャラクタ番号・乙チーム
; ****************************************************

TOUR_1GET	PROC	NEAR
	MOV	TOUR_LINK,BX			; 組み合せ番号
	CALL	KUMI_TAG			; 組み合せ

	MOV	CX,TOUR_TEAM_KOH		; 組み合せ・甲チーム
	MOV	DX,TOUR_TEAM_OTSU		; 組み合せ・乙チーム
	MOV	SI,ENTRY_CHAR_KOH		; キャラクタ番号・甲チーム
	MOV	DI,ENTRY_CHAR_OTSU		; キャラクタ番号・乙チーム

	CMP	SI,CHAR_NUMBER_MUSUME		; 甲は自分の娘のキャラ番号？
	JE	TOUR_1GET_MY_KOH		;

	CMP	DI,CHAR_NUMBER_MUSUME		; 乙は自分の娘のキャラ番号？
	JE	TOUR_1GET_MY_OTSU		;

	JMP	TOUR_1GET_TANIN			;
TOUR_1GET_MY_KOH:
	MOV	AX,1				; 試合属性 1=甲自分の娘
	RET
TOUR_1GET_MY_OTSU:
	MOV	AX,2				; 試合属性 2=乙自分の娘
	RET
TOUR_1GET_TANIN:
	MOV	AX,0				; 試合属性 0=他人の試合
	RET
TOUR_1GET	ENDP


; ****************************************************
;	トーナメント試合・衝撃！
; ****************************************************

TOUR_1SHOCK	PROC	NEAR
	CALL	TAG_SHOCK			; 対戦同士の激突
	RET
TOUR_1SHOCK	ENDP


; ****************************************************
;	トーナメント試合・勝敗
;	-I- BX : 1=甲が勝ち,2=乙が勝ち
;	    CX : 第何試合か？
;	    DX : 組み合せ番号
; ****************************************************

TOUR_1END	PROC	NEAR
	MOV	TOUR_JYOUTAI,BX		; 状態 1=甲の勝ち,2=乙の勝ち,3=試合開始
	MOV	TOUR_LEVEL,CX		; 第何試合か？
	MOV	TOUR_LINK,DX		; 組み合せ番号

	CALL	KUMI_TAG_VICTORY	; 組み合せ・勝敗
	CALL	ELE_SET			; エレメントの設定
	CALL	ELE_ALL_PLOT		; エレメントの全表示
	RET
TOUR_1END	ENDP


; ****************************************************
;	トーナメント試合・オフサイド
;	-O- AX : 状態 0=通常,1=全試合終了
;	    SI : 優勝キャラクタ番号
;	    DI : 準優勝キャラクタ番号
; ****************************************************

TOUR_OFFSIDE	PROC	NEAR
;;	CMP	TOUR_LEVEL,4			; 決勝か？
;;	JL	TOUR_OFFSIDE_NORMAL		;

	CMP	TOUR_JYOUTAI,2			; 状態 1=甲の勝ち,2=乙の勝ち
	JE	TOUR_OFFSIDE_3			;
TOUR_OFFSIDE_2:
	MOV	SI,ENTRY_CHAR_KOH		; 甲チーム優勝
	MOV	DI,ENTRY_CHAR_OTSU		; 乙チーム準優勝
	JMP	TOUR_OFFSIDE_4			;
TOUR_OFFSIDE_3:
	MOV	SI,ENTRY_CHAR_OTSU		; 乙チーム優勝
	MOV	DI,ENTRY_CHAR_KOH		; 甲チーム準優勝
	JMP	TOUR_OFFSIDE_4			;
TOUR_OFFSIDE_4:

TOUR_OFFSIDE_FINALE:
	MOV	AX,1			; 状態 1=全試合終了
	RET
TOUR_OFFSIDE_NORMAL:
	MOV	SI,0			; 優勝キャラクタ番号
	MOV	DI,0			; 準優勝キャラクタ番号
	MOV	AX,0			; 状態 0=通常
	RET
TOUR_OFFSIDE	ENDP


; ****************************************************
;	組み合せ
;	-I-  TOUR_LINK      : 組み合せ番号
;	-O-  TOUR_TEAM_KOH  : 組み合せ・甲チーム
;	     TOUR_TEAM_OTSU : 組み合せ・乙チーム
;	     ENTRY_CHAR_KOH : キャラクタ番号・甲チーム
;	     ENTRY_CHAR_OTSU: キャラクタ番号・乙チーム
;	     AX             : 0=通常,1=組み合せ番号が範囲外です
; ****************************************************

KUMI_TAG	PROC	NEAR
	CMPX	TOUR_LINK,TOUR_KUMI_CNT		; 組み合せ数
	JNBE	KUMI_TAG_ERROR			;

	MOV	BX,TOUR_LINK			; 組み合せ番号

	MOVXBW	TOUR_TEAM_KOH,DS:TOUR_KUMI_KOH_TBL[BX]   ; 組み合せ表 甲
	MOVXBW	TOUR_TEAM_OTSU,DS:TOUR_KUMI_OTSU_TBL[BX] ; 組み合せ表 乙

	MOV	SI,ADRS_ENTRY_TABLE		; エントリィテーブルアドレス
	MOV	BX,TOUR_TEAM_KOH		; 組み合せ・甲チーム
	DEC	BX				; －１
	MOV	AH,0				;
	MOV	AL,DS:[SI][BX]			; DI=これがメンバ番号(byte)
	MOV	ENTRY_CHAR_KOH,AX		; キャラクタ番号・甲チーム

	MOV	SI,ADRS_ENTRY_TABLE		; エントリィテーブルアドレス
	MOV	BX,TOUR_TEAM_OTSU		; 組み合せ・乙チーム
	DEC	BX				; －１
	MOV	AH,0				;
	MOV	AL,DS:[SI][BX]			; DI=これがメンバ番号(byte)
	MOV	ENTRY_CHAR_OTSU,AX		; キャラクタ番号・乙チーム

KUMI_TAG_SET_END:
	MOV	AX,0				; 0=通常
	RET
KUMI_TAG_ERROR:
	MOV	AX,1				; 1=組み合せ番号が範囲外です
	RET
KUMI_TAG	ENDP


; ****************************************************
;	組み合せ・勝敗
;	-I-   TOUR_JYOUTAI : 状態 1=甲の勝ち,2=乙の勝ち,3=試合開始
;	      TOUR_LEVEL   : 第何試合か？
;	      TOUR_LINK    : 組み合せ番号
;	-I/O- TOUR_KUMI_KACHI_TBL[] : 組み合せ表 勝ったチーム番号
;	      TEAM_KACHIMAKE_TBL[]  : 勝敗表
; ****************************************************

KUMI_TAG_VICTORY	PROC	NEAR
	CMP	TOUR_JYOUTAI,2			; 1=甲の勝ち,2=乙の勝ち
	JE	KUMI_TAG_VICTORY_OTSU		;

KUMI_TAG_VICTORY_KOH:
	MOV	BX,TOUR_LINK			; 組み合せ番号
	MOV	DL,DS:TOUR_KUMI_KOH_TBL[BX]	; 組み合せ表 甲
	MOV	DS:TOUR_KUMI_KACHI_TBL[BX],DL	; 組み合せ表 勝ったチーム番号

	MOVXBW	DI,DS:TOUR_KUMI_KOH_TBL[BX]	; 組み合せ表 甲
	MOV	DS:TEAM_KACHIMAKE_TBL[DI],1	; 勝敗表 1=勝ち
	MOVXBW	DI,DS:TOUR_KUMI_OTSU_TBL[BX]	; 組み合せ表 乙
	MOV	DS:TEAM_KACHIMAKE_TBL[DI],2	; 勝敗表 2=負け

	JMP	KUMI_TAG_VICTORY_55		;

KUMI_TAG_VICTORY_OTSU:
	MOV	BX,TOUR_LINK			; 組み合せ番号
	MOV	DL,DS:TOUR_KUMI_OTSU_TBL[BX]	; 組み合せ表 乙
	MOV	DS:TOUR_KUMI_KACHI_TBL[BX],DL	; 組み合せ表 勝ったチーム番号

	MOVXBW	DI,DS:TOUR_KUMI_KOH_TBL[BX]	; 組み合せ表 甲
	MOV	DS:TEAM_KACHIMAKE_TBL[DI],2	; 勝敗表 2=負け
	MOVXBW	DI,DS:TOUR_KUMI_OTSU_TBL[BX]	; 組み合せ表 乙
	MOV	DS:TEAM_KACHIMAKE_TBL[DI],1	; 勝敗表 1=勝ち

	JMP	KUMI_TAG_VICTORY_55		;

KUMI_TAG_VICTORY_55:
	RET
KUMI_TAG_VICTORY	ENDP


; ****************************************************
;	組み合せ表作成
;	-I-   TOUR_LEVEL : 第何試合か？
;	-I/O- TOUR_KUMI_KACHI_TBL[]: 組み合せ表 勝ったチーム番号
;	-O-   TOUR_KUMI_KOH_TBL[] : 組み合せ表 甲
;	      TOUR_KUMI_OTSU_TBL[]: 組み合せ表 乙
;	      TOUR_KUMI_CNT       : 組み合せ数
;	      AX         : 0=通常,1=試合が範囲外です
; ****************************************************

KUMIAWASE	PROC	NEAR
	MOV	AX,TOUR_LEVEL			; 第何試合か？
	CMP	AX,1				;
	JE	KUMIAWASE_LVL_1_SET		;
	CMP	AX,2				;
	JE	KUMIAWASE_LVL_2_SET		;
	CMP	AX,3				;
	JE	KUMIAWASE_LVL_3_SET		;
	CMP	AX,4				;
	JE	KUMIAWASE_LVL_4_SET		;
	JMP	KUMIAWASE_ERROR			;

KUMIAWASE_LVL_1_SET:
	CALL	DAI_1_KUMI			; 第１試合組み合せ
	JMP	KUMIAWASE_SET_END		;

KUMIAWASE_LVL_2_SET:
	CALL	DAI_2_KUMI			; 第２試合組み合せ
	JMP	KUMIAWASE_SET_END		;

KUMIAWASE_LVL_3_SET:
	CALL	DAI_3_KUMI			; 第３試合組み合せ
	JMP	KUMIAWASE_SET_END		;

KUMIAWASE_LVL_4_SET:
	CALL	DAI_4_KUMI			; 第４試合組み合せ
	JMP	KUMIAWASE_SET_END		;

KUMIAWASE_SET_END:
	MOV	AX,0				; 0=通常
	RET
KUMIAWASE_ERROR:
	MOV	AX,1				; 1=試合が範囲外です
	RET
KUMIAWASE	ENDP


; ****************************************************
;	第１試合組み合せ
;	-O- TOUR_KUMI_KOH_TBL[]  : 組み合せ表 甲
;	    TOUR_KUMI_OTSU_TBL[] : 組み合せ表 乙
;	    TOUR_KUMI_KACHI_TBL[]: 組み合せ表 勝ったチーム番号
;	    TOUR_KUMI_CNT        : 組み合せ数
; ****************************************************

DAI_1_KUMI	PROC	NEAR
	MOV	TOUR_KUMI_CNT,8			; 組み合せ数
	MOV	TOUR_KUMI_KOH_TBL[0],8		; 組み合せ表 甲 [0]=組み合せ数
	MOV	TOUR_KUMI_OTSU_TBL[0],8		; 組み合せ表 乙 [0]=組み合せ数
	MOV	BX,1				; byte pointer.
	MOV	DL,1				; エントリィ番号
	MOV	CX,8				; ８試合ある
DAI_1_KUMI_LOOP:
	MOV	DS:TOUR_KUMI_KOH_TBL[BX],DL	; 甲
	INC	DL				;
	MOV	DS:TOUR_KUMI_OTSU_TBL[BX],DL	; 乙
	INC	DL				;

	INC	BX				; byte pointer.
	LOOP	DAI_1_KUMI_LOOP			;

	MOV	TOUR_KUMI_KACHI_TBL[0],8	; 組み合せ表 勝ったチーム番号
	RET
DAI_1_KUMI	ENDP


; ****************************************************
;	第２試合組み合せ
;	-I/O- TOUR_KUMI_KACHI_TBL[]: 組み合せ表 勝ったチーム番号
;	-O-   TOUR_KUMI_KOH_TBL[]  : 組み合せ表 甲 [0]=組み合せ数
;	      TOUR_KUMI_OTSU_TBL[] : 組み合せ表 乙 [0]=組み合せ数
;	      TOUR_KUMI_CNT        : 組み合せ数
; ****************************************************

DAI_2_KUMI	PROC	NEAR
	MOV	TOUR_KUMI_CNT,4			; 組み合せ数
	MOV	TOUR_KUMI_KOH_TBL[0],4		; 組み合せ表 甲 [0]=組み合せ数
	MOV	TOUR_KUMI_OTSU_TBL[0],4		; 組み合せ表 乙 [0]=組み合せ数
	MOV	BX,1				; BX=組み合せ表 byte pointer.
	MOV	DI,1				; DI=勝敗表 番号
	MOV	CX,4				; ４試合ある
DAI_2_KUMI_LOOP:
	MOV	AL,TOUR_KUMI_KACHI_TBL[DI]	; 組み合せ表 勝ったチーム番号
	MOV	DL,TOUR_KUMI_KACHI_TBL[DI][1]	; 組み合せ表 勝ったチーム番号
	MOV	DS:TOUR_KUMI_KOH_TBL[BX],AL	; 甲
	MOV	DS:TOUR_KUMI_OTSU_TBL[BX],DL	; 乙

	ADD	DI,2				; DI=勝敗表 番号
	INC	BX				; byte pointer.
	LOOP	DAI_2_KUMI_LOOP			;

	MOV	TOUR_KUMI_KACHI_TBL[0],4	; 組み合せ表 勝ったチーム番号
	RET
DAI_2_KUMI	ENDP


; ****************************************************
;	第３試合組み合せ
;	-I/O- TOUR_KUMI_KACHI_TBL[]: 組み合せ表 勝ったチーム番号
;	-O-   TOUR_KUMI_KOH_TBL[]  : 組み合せ表 甲 [0]=組み合せ数
;	      TOUR_KUMI_OTSU_TBL[] : 組み合せ表 乙 [0]=組み合せ数
;	      TOUR_KUMI_CNT        : 組み合せ数
; ****************************************************

DAI_3_KUMI	PROC	NEAR
	MOV	TOUR_KUMI_CNT,2			; 組み合せ数
	MOV	TOUR_KUMI_KOH_TBL[0],2		; 組み合せ表 甲 [0]=組み合せ数
	MOV	TOUR_KUMI_OTSU_TBL[0],2		; 組み合せ表 乙 [0]=組み合せ数

	MOV	AH,TOUR_KUMI_KACHI_TBL[1]	; 組み合せ表 勝ったチーム番号
	MOV	DH,TOUR_KUMI_KACHI_TBL[2]	; 組み合せ表 勝ったチーム番号
	MOV	AL,TOUR_KUMI_KACHI_TBL[3]	; 組み合せ表 勝ったチーム番号
	MOV	DL,TOUR_KUMI_KACHI_TBL[4]	; 組み合せ表 勝ったチーム番号
	MOV	TOUR_KUMI_KOH_TBL[1],AH		; 甲
	MOV	TOUR_KUMI_OTSU_TBL[1],DH	; 乙
	MOV	TOUR_KUMI_KOH_TBL[2],AL		; 甲
	MOV	TOUR_KUMI_OTSU_TBL[2],DL	; 乙

	MOV	TOUR_KUMI_KACHI_TBL[0],2	; 組み合せ表 勝ったチーム番号
	RET
DAI_3_KUMI	ENDP


; ****************************************************
;	第４試合組み合せ
;	-I/O- TOUR_KUMI_KACHI_TBL[]: 組み合せ表 勝ったチーム番号
;	-O-   TOUR_KUMI_KOH_TBL[]  : 組み合せ表 甲 [0]=組み合せ数
;	      TOUR_KUMI_OTSU_TBL[] : 組み合せ表 乙 [0]=組み合せ数
;	      TOUR_KUMI_CNT        : 組み合せ数
; ****************************************************

DAI_4_KUMI	PROC	NEAR
	MOV	TOUR_KUMI_CNT,1			; 組み合せ数
	MOV	TOUR_KUMI_KOH_TBL[0],1		; 組み合せ表 甲 [0]=組み合せ数
	MOV	TOUR_KUMI_OTSU_TBL[0],1		; 組み合せ表 乙 [0]=組み合せ数

	MOV	AL,TOUR_KUMI_KACHI_TBL[1]	; 組み合せ表 勝ったチーム番号
	MOV	DL,TOUR_KUMI_KACHI_TBL[2]	; 組み合せ表 勝ったチーム番号
	MOV	TOUR_KUMI_KOH_TBL[1],AL		; 甲
	MOV	TOUR_KUMI_OTSU_TBL[1],DL	; 乙

	MOV	TOUR_KUMI_KACHI_TBL[0],1	; 組み合せ表 勝ったチーム番号
	RET
DAI_4_KUMI	ENDP


; ****************************************************
;	トーナメント表セットアップ
;	-I-  TOUR_LEVEL    : 第何試合か？
;	     TOUR_KUMI_CNT : 組み合せ数
; ****************************************************

TOURNAMENT_SETUP	PROC	NEAR
	MOV	TOUR_LINK,1			; 組み合せ番号
	MOV	CX,TOUR_KUMI_CNT		; 組み合せ数
TOURNAMENT_SETUP_LOOP:
	PUSH	CX				;
	MOV	TOUR_JYOUTAI,3			; 状態 3=試合開始
	CALL	ELE_SET				; エレメントの設定
	INC	TOUR_LINK			; 組み合せ番号
	POP	CX				;
	LOOP	TOURNAMENT_SETUP_LOOP

	CALL	ELE_ALL_PLOT			; エレメントの全表示
	RET
TOURNAMENT_SETUP	ENDP


; ****************************************************
;	トーナメントの全クリア
; ****************************************************

TOUR_CLEAR	PROC	NEAR
	MOVXBW	CX,TEAM_KACHIMAKE_TBL[0]	; 勝敗表
	MOV	DI,OFFSET TEAM_KACHIMAKE_TBL	; 勝敗表
	INC	DI				;
	MOV	AL,0				;
	REP	STOSB				; zero clear.
	RET
TOUR_CLEAR	ENDP


; ****************************************************
;	エントリィ名
;	-I- ENTRY_NUMBER : エントリィ番号(1-16)
;	    ENTRY_NAMEADRS : エントリィ名前
; ****************************************************

ENTRY_NAME_DISP		PROC	NEAR
	CALL	ENTRY_NAME_BOX		; エントリィ名の箱

;;	MOV	SI,ENTRY_NAMEADRS	; エントリィ名前
;;	MOV	CX,NAME_LEN_MAX		; 表示名前の最長
;;	CALL_w	KANJITUME		; 漢字文字詰め処理

	MOV	BX,ENTRY_NUMBER		; エントリィ番号
	MOV	AL,DS:TEAM_KACHIMAKE_TBL[BX] ; 勝敗表 (1=勝ち,2=負け)

	CMP	AL,2			; 2=負け
	JE	ENTRY_NAME_DISP_MAKE	;
	MOVX	GR_TXTCLR,NAM_TXTCLR_ST	; 文字表示色・通常
	JMP	ENTRY_NAME_DISP_DSP	;
ENTRY_NAME_DISP_MAKE:
	MOVX	GR_TXTCLR,NAM_TXTCLR_MK	; 文字表示色・負け
ENTRY_NAME_DISP_DSP:
	MOVX	GR_TXTCSZ,NAM_TXTSIZ	; 名前文字サイズ

	MOV	BX,ENTRY_NUMBER		; エントリィ番号
	MOVXBW	CX,DS:TR_BOX_X[BX]	; ＢＯＸ　Ｘ座標
	MOVXBW	DX,DS:TR_BOX_Y[BX]	; ＢＯＸ　Ｙ座標
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			; * 8
	ADD	CX,GR_N_XX		; 名前Ｘオフセット
	ADD	DX,GR_N_YY		; 名前Ｙオフセット
	MOV	GR_NAMXX,CX		; 名前表示Ｘ位置
	MOV	GR_NAMYY,DX		; 名前表示Ｙ位置
	CALL	NAME_PRINT		; 名前表示

	RET
ENTRY_NAME_DISP		ENDP


; ****************************************************
;	エントリィ名の箱
;	-I- ENTRY_NUMBER   : エントリィ番号
; ****************************************************

ENTRY_NAME_BOX		PROC	NEAR
	MOV	BX,ENTRY_NUMBER		; エントリィ番号
	MOVXBW	WDX1,DS:TR_BOX_X[BX]	; ＢＯＸ　Ｘ座標
	MOVXBW	WDY1,DS:TR_BOX_Y[BX]	; ＢＯＸ　Ｙ座標
	SHL	WDY1,1			;
	SHL	WDY1,1			;
	SHL	WDY1,1			; * 8
	MOVX	WDX2,TR_BOX_XL		; ＢＯＸ Ｘサイズ
	MOVX	WDY2,TR_BOX_YL		; ＢＯＸ Ｙサイズ
	CALL_w	WID_FLAME_TOUR_NAME	; WINDOWS/フレーム・ﾄｰﾅﾒﾝﾄ名前箱
	RET
ENTRY_NAME_BOX		ENDP


; ****************************************************
;	名前表示
;	-I- ENTRY_NAMEADRS : エントリィ名前
;	    GR_NAMXX  : 名前表示Ｘ位置
;	    GR_NAMYY  : 名前表示Ｙ位置
;	    GR_TXTCLR : 文字表示色
;	    GR_TXTCSZ : 文字表示サイズ
; ****************************************************

NAME_PRINT	PROC	NEAR
	MOV	AX,GR_TXTCSZ		; 文字表示サイズ
	CALL_w	VTXSIZ			; character size set.

	MOV	AX,GR_TXTCLR		; 文字表示色
	CALL_w	VTXCOL			; character color set.

	MOV	AX,GR_NAMXX		; 名前表示Ｘ位置
	MOV	BX,GR_NAMYY		; 名前表示Ｙ位置
	MOV	SI,ENTRY_NAMEADRS	; エントリィ名前
;*;	CALL_w	VTXPFC			; vram text print fuchi.
	CALL_w	VTXPOR			; vram text print OR.

	RET
NAME_PRINT	ENDP


; ****************************************************
;	対戦同士の激突
;	-I- TOUR_TEAM_KOH  : 組み合せ・甲チーム
;	    TOUR_TEAM_OTSU : 組み合せ・乙チーム
; ****************************************************

TAG_SHOCK	PROC	NEAR
	CALL	ENTRY_TAG_BOX_SHOCK	; 対戦同士エントリィ名の箱・衝撃！
	RET
TAG_SHOCK	ENDP


; ****************************************************
;	対戦同士エントリィ名の箱・衝撃！
;	-I-  TOUR_TEAM_KOH  : 組み合せ・甲チーム
;	     TOUR_TEAM_OTSU : 組み合せ・乙チーム
; ****************************************************

ENTRY_TAG_BOX_SHOCK	PROC	NEAR
	MOV	BX,TOUR_TEAM_KOH	; 組み合せ・甲チーム
	MOVXBW	WDX1,DS:TR_BOX_X[BX]	; ＢＯＸ　Ｘ座標
	MOVXBW	WDY1,DS:TR_BOX_Y[BX]	; ＢＯＸ　Ｙ座標
	SHL	WDY1,1			;
	SHL	WDY1,1			;
	SHL	WDY1,1			; * 8

	MOV	BX,TOUR_TEAM_OTSU	; 組み合せ・乙チーム
	MOVXBW	WDXX,DS:TR_BOX_X[BX]	; ＢＯＸ　Ｘ座標
	MOVXBW	WDYY,DS:TR_BOX_Y[BX]	; ＢＯＸ　Ｙ座標
	SHL	WDYY,1			;
	SHL	WDYY,1			;
	SHL	WDYY,1			; * 8

	MOVX	WDX2,TR_BOX_XL		; ＢＯＸ Ｘサイズ
	MOVX	WDY2,TR_BOX_YL		; ＢＯＸ Ｙサイズ

;*;	ADD	WDXX,2
	ADD	WDYY,2
;*;	ADD	WDX1,2
	ADD	WDY1,2
	SUB	WDX2,1
	SUB	WDY2,1

	MOV	CX,2*2			; １回位かな・・・
ENTRY_TAG_BOX_SHOCK_LOOP:		;
	PUSH	CX			;

	MOVX	VX1,WDX1		; start point.
	MOVX	VY1,WDY1		; start point.
	MOVX	VX2,WDX1		; start point.
	MOVX	VY2,WDY1		; start point.
	ADDX	VX2,WDX2		; end point.
	ADDX	VY2,WDY2		; end point.
	MOV	CX,1111B		; color palet number.
	CALL_w	BOXNOT			; ＢＯＸ反転

	MOVX	VX1,WDXX		; start point.
	MOVX	VY1,WDYY		; start point.
	MOVX	VX2,WDXX		; start point.
	MOVX	VY2,WDYY		; start point.
	ADDX	VX2,WDX2		; end point.
	ADDX	VY2,WDY2		; end point.
	MOV	CX,1111B		; color palet number.
	CALL_w	BOXNOT			; ＢＯＸ反転

	MOV	AX,SHOCK_WAIT		; ショック待ち単位時間
	CALL_w	TMVWAT			; V-SYNC timer wait.

	POP	CX			;
	LOOP	ENTRY_TAG_BOX_SHOCK_LOOP

	RET
ENTRY_TAG_BOX_SHOCK	ENDP


; ****************************************************
;	エレメントのルートクリア
;	-I- ELE_NUMBER : エレメント番号／ルートの位置（第２試合以下のあみだ）
; ****************************************************

ELE_CLR_SET	PROC	NEAR
	PUSH	ELE_NUMBER

	MOVX	ELE_ATTR,ELE_ATTR_OFF	; エレメント属性／ＯＦＦ

	MOV	ELE_LEVEL,2		; エレメント何試合目か

	SHL	ELE_NUMBER,1		; エレメント番号＊２
	CALL	ELE_ATR_PUT		; エレメント属性の設定
	DEC	ELE_NUMBER		;
	CALL	ELE_ATR_PUT		; エレメント属性の設定

	MOV	ELE_LEVEL,1		; エレメント何試合目か

	SHL	ELE_NUMBER,1		; エレメント番号＊２
	DEC	ELE_NUMBER		;
	CALL	ELE_ATR_PUT		; エレメント属性の設定
	INC	ELE_NUMBER		;
	CALL	ELE_ATR_PUT		; エレメント属性の設定
	INC	ELE_NUMBER		;
	CALL	ELE_ATR_PUT		; エレメント属性の設定
	INC	ELE_NUMBER		;
	CALL	ELE_ATR_PUT		; エレメント属性の設定

	POP	ELE_NUMBER
	RET
ELE_CLR_SET	ENDP


; ****************************************************
;	エレメントの白線表示
; ****************************************************

ELE_WHT_LINE_PLOT	PROC	NEAR
	MOV	ELE_LEVEL,1		; エレメント何試合目か
	MOV	ELE_NUMBER,1		; エレメント番号
	MOV	ELE_LINEATTR,1		; エレメント線種類

ELE_WHT_LINE_PLOT_LOOP:
	CALL	ELE_ATR_GET		; エレメント属性の取得
	CMP	AX,1			; 0=正常,1=オーバ
	JNE	ELE_WHT_LINE_PLOT_D	;

	INC	ELE_LEVEL		; エレメント何試合目か
	MOV	ELE_NUMBER,1		; エレメント番号
	CALL	ELE_ATR_GET		; エレメント属性の取得
	CMP	AX,1			; 0=正常,1=オーバ
	JE	ELE_WHT_LINE_PLOT_EXIT	;

ELE_WHT_LINE_PLOT_D:
	CALL	ELE_ALL_PLOT_DSP	; エレメントの属性表示

	INC	ELE_NUMBER		; エレメント番号
	JMP	ELE_WHT_LINE_PLOT_LOOP	;

ELE_WHT_LINE_PLOT_EXIT:
	RET
ELE_WHT_LINE_PLOT	ENDP


; ****************************************************
;	エレメントの全表示
; ****************************************************

ELE_ALL_PLOT	PROC	NEAR
	MOV	ELE_LEVEL,1		; エレメント何試合目か
	MOV	ELE_NUMBER,1		; エレメント番号
	MOV	ELE_LINEATTR,0		; エレメント線種類

ELE_ALL_PLOT_LOOP:
	CALL	ELE_ATR_GET		; エレメント属性の取得
	CMP	AX,1			; 0=正常,1=オーバ
	JNE	ELE_ALL_PLOT_D		;
	INC	ELE_LEVEL		; エレメント何試合目か
	MOV	ELE_NUMBER,1		; エレメント番号
	CALL	ELE_ATR_GET		; エレメント属性の取得
	CMP	AX,1			; 0=正常,1=オーバ
	JE	ELE_ALL_PLOT_RED	;
ELE_ALL_PLOT_D:				;
	CMPX	ELE_ATTR,ELE_ATTR_OFF	; エレメント属性／ＯＦＦか？
	JNE	ELE_ALL_PLOT_NEXT	;
	CALL	ELE_ALL_PLOT_DSP	; エレメントの属性表示
ELE_ALL_PLOT_NEXT:
	INC	ELE_NUMBER		; エレメント番号
	JMP	ELE_ALL_PLOT_LOOP

ELE_ALL_PLOT_RED:			;
	MOV	ELE_LEVEL,1		; エレメント何試合目か
	MOV	ELE_NUMBER,1		; エレメント番号

ELE_ALL_PLOT_LOOP2:
	CALL	ELE_ATR_GET		; エレメント属性の取得
	CMP	AX,1			; 0=正常,1=オーバ
	JNE	ELE_ALL_PLOT_D2		;
	INC	ELE_LEVEL		; エレメント何試合目か
	MOV	ELE_NUMBER,1		; エレメント番号
	CALL	ELE_ATR_GET		; エレメント属性の取得
	CMP	AX,1			; 0=正常,1=オーバ
	JE	ELE_ALL_PLOT_EXIT	;
ELE_ALL_PLOT_D2:			;
	CMPX	ELE_ATTR,ELE_ATTR_OFF	; エレメント属性／ＯＦＦか？
	JE	ELE_ALL_PLOT_NEXT2	;
	CALL	ELE_ALL_PLOT_DSP	; エレメントの属性表示
ELE_ALL_PLOT_NEXT2:			;
	INC	ELE_NUMBER		; エレメント番号
	JMP	ELE_ALL_PLOT_LOOP2

ELE_ALL_PLOT_EXIT:
	RET
ELE_ALL_PLOT	ENDP


; ****************************************************
;	エレメントの設定
;	-I-   TOUR_LEVEL   : 第何試合か？
;	      TOUR_LINK    : 組み合せ番号
;	      TOUR_JYOUTAI : 状態 1=甲の勝ち,2=乙の勝ち,3=試合開始
; ****************************************************

ELE_SET		PROC	NEAR
	MOVX	ELE_LEVEL,TOUR_LEVEL	; エレメント何試合目か

	MOV	AX,TOUR_LINK		; 組み合せ番号
	SHL	AX,1			; * 2
	DEC	AX			; - 1
	MOV	ELE_NUMBER,AX		; エレメント番号

	CMP	TOUR_JYOUTAI,1		;状態 1=甲の勝ち
	JE	ELE_SET_KOH_KACHI	;
	CMP	TOUR_JYOUTAI,2		;状態 2=乙の勝ち
	JE	ELE_SET_OTSU_KACHI	;
	CMP	TOUR_JYOUTAI,3		;状態 3=試合開始
	JMPEQ	ELE_SET_KAISHI		;

ELE_SET_KOH_KACHI:			;
	MOVX	ELE_ATTR,ELE_ATTR_ON	; エレメント属性／ＯＮ
	CALL	ELE_ATR_PUT		; エレメント属性の設定
	INC	ELE_NUMBER		; エレメント番号
	MOVX	ELE_ATTR,ELE_ATTR_OFF	; エレメント属性／ＯＦＦ
	CALL	ELE_ATR_PUT		; エレメント属性の設定

	CMP	ELE_LEVEL,1		;
	JE	ELE_SET_KOH_KACHI2	;
	CMP	ELE_LEVEL,2		;
	JE	ELE_SET_KOH_KACHI_LVL2	;
	CMP	ELE_LEVEL,3		;
	JE	ELE_SET_KOH_KACHI_LVL3	;

	JMP	ELE_SET_KOH_KACHI2	;

ELE_SET_KOH_KACHI_LVL2:			;
	MOV	ELE_LEVEL,1		;
	MOVX	ELE_ATTR,ELE_ATTR_OFF	; エレメント属性／ＯＦＦ
	SHL	ELE_NUMBER,1		; エレメント番号
	CALL	ELE_ATR_PUT		; エレメント属性の設定
	DEC	ELE_NUMBER		;
	CALL	ELE_ATR_PUT		; エレメント属性の設定
	JMP	ELE_SET_KOH_KACHI2	;

ELE_SET_KOH_KACHI_LVL3:			;
	CALL	ELE_CLR_SET		; エレメントのルートクリア

ELE_SET_KOH_KACHI2:			;
	JMP	ELE_SET_EXIT		;


ELE_SET_OTSU_KACHI:			;
	MOVX	ELE_ATTR,ELE_ATTR_OFF	; エレメント属性／ＯＦＦ
	CALL	ELE_ATR_PUT		; エレメント属性の設定
	INC	ELE_NUMBER		; エレメント番号
	MOVX	ELE_ATTR,ELE_ATTR_ON	; エレメント属性／ＯＮ
	CALL	ELE_ATR_PUT		; エレメント属性の設定

	CMP	ELE_LEVEL,1		;
	JE	ELE_SET_OTSU_KACHI2	;
	CMP	ELE_LEVEL,2		;
	JE	ELE_SET_OTSU_KACHI_LVL2	;
	CMP	ELE_LEVEL,3		;
	JE	ELE_SET_OTSU_KACHI_LVL3	;

	JMP	ELE_SET_OTSU_KACHI2	;

ELE_SET_OTSU_KACHI_LVL2:		;
	DEC	ELE_NUMBER		;
	MOV	ELE_LEVEL,1		;
	MOVX	ELE_ATTR,ELE_ATTR_OFF	; エレメント属性／ＯＦＦ
	SHL	ELE_NUMBER,1		; エレメント番号
	CALL	ELE_ATR_PUT		; エレメント属性の設定
	DEC	ELE_NUMBER		;
	CALL	ELE_ATR_PUT		; エレメント属性の設定
	JMP	ELE_SET_OTSU_KACHI2	;

ELE_SET_OTSU_KACHI_LVL3:		;
	DEC	ELE_NUMBER		;
	CALL	ELE_CLR_SET		; エレメントのルートクリア

ELE_SET_OTSU_KACHI2:			;
	JMP	ELE_SET_EXIT		;


ELE_SET_KAISHI:				;
	MOVX	ELE_ATTR,ELE_ATTR_ON	; エレメント属性／ＯＮ
	CALL	ELE_ATR_PUT		; エレメント属性の設定
	INC	ELE_NUMBER		; エレメント番号
	CALL	ELE_ATR_PUT		; エレメント属性の設定

	JMP	ELE_SET_EXIT		;

ELE_SET_EXIT:
	RET
ELE_SET		ENDP


; ****************************************************
;	エレメントの属性表示
;	-I- ELE_LEVEL  : エレメント何試合目か
;	    ELE_NUMBER : エレメント番号
;	    ELE_LINEATTR : エレメント線種類
;	    ELE_ATTR : エレメント属性／ＯＦＦか？
; ****************************************************

ELE_ALL_PLOT_DSP	PROC	NEAR
	CMPX	ELE_ATTR,ELE_ATTR_OFF	; エレメント属性／ＯＦＦか？
	JE	ELE_ALL_PLOT_DSP_GREY	;
ELE_ALL_PLOT_DSP_RED:
	MOVX	ELE_COLOR1,ELE_RED_COL1	; エレメント赤カラー
	MOVX	ELE_COLOR2,ELE_RED_COL2	; エレメント赤カラー影
	CALL	ELE_PLOT		; エレメントの表示
	JMP	ELE_ALL_PLOT_DSP_55	;
ELE_ALL_PLOT_DSP_GREY:
	MOVX	ELE_COLOR1,ELE_GREY_COL1 ; エレメント暗カラー
	MOVX	ELE_COLOR2,ELE_GREY_COL2 ; エレメント暗カラー影
	CALL	ELE_PLOT		; エレメントの表示
ELE_ALL_PLOT_DSP_55:
	RET
ELE_ALL_PLOT_DSP	ENDP


; ****************************************************
;	エレメントの設定クリア
; ****************************************************

ELE_CLEAR	PROC	NEAR
	MOV	CX,ELE_ATR_TABLE[0]		; エレメント・属性テーブル
	MOV	BX,2				; word pointer.
ELE_CLEAR_LOOP:
	PUSH	CX				;
	MOV	DI,DS:ELE_ATR_TABLE[BX]		; DI=試合毎のエレメント属性群
	ADD	BX,2				; word pointer.

	MOV	CH,0				;
	MOV	CL,DS:[DI]			; CX=max.
	INC	DI				;
	MOVX	ES,DS				;
	MOV	AL,0				;
	REP	STOSB				; zero clear.

	POP	CX				;
	LOOP	ELE_CLEAR_LOOP			;

	RET
ELE_CLEAR	ENDP


; ****************************************************
;	エレメント属性の設定
;	-I- ELE_LEVEL  : エレメント何試合目か
;	    ELE_NUMBER : エレメント番号
;	    ELE_ATTR   : エレメント属性
;	-O- AX         : 0=正常,1=オーバ
; ****************************************************

ELE_ATR_PUT	PROC	NEAR
	MOV	BX,ELE_LEVEL			; エレメント何試合目か
	CMP	BX,ELE_ATR_TABLE[0]		; エレメント・属性
	JG	ELE_ATR_PUT_OVER		; 範囲オーバ
	CMP	BX,0				;
	JLE	ELE_ATR_PUT_OVER		; 範囲オーバ

	SHL	BX,1				; word pointer.
	MOV	SI,DS:ELE_ATR_TABLE[BX]		; SI=試合毎のエレメント属性群

	MOV	BX,ELE_NUMBER			; エレメント番号
	CMP	BL,DS:[SI][0]			; エレメント属性・テーブル
	JNBE	ELE_ATR_PUT_OVER		; 範囲オーバ

	MOV	AX,ELE_ATTR			; エレメント属性
	MOV	DS:[SI][BX],AL			; エレメント・属性テーブル
ELE_ATR_PUT_EXIT:
	MOV	AX,0				; 0=正常
	RET
ELE_ATR_PUT_OVER:
	MOV	AX,1				; 1=オーバ
	RET
ELE_ATR_PUT	ENDP


; ****************************************************
;	エレメント属性の取得
;	-I- ELE_LEVEL  : エレメント何試合目か
;	    ELE_NUMBER : エレメント番号
;	-O- ELE_ATTR   : エレメント属性
;	    AX         : 0=正常,1=オーバ
; ****************************************************

ELE_ATR_GET	PROC	NEAR
	MOV	BX,ELE_LEVEL			; エレメント何試合目か
	CMP	BX,ELE_ATR_TABLE[0]		; エレメント・属性
	JG	ELE_ATR_GET_OVER		; 範囲オーバ
	CMP	BX,0				;
	JLE	ELE_ATR_GET_OVER		; 範囲オーバ

	SHL	BX,1				; word pointer.
	MOV	SI,DS:ELE_ATR_TABLE[BX]		; SI=試合毎のエレメント属性群

	MOV	BX,ELE_NUMBER			; エレメント番号
	CMP	BL,DS:[SI][0]			; エレメント属性・テーブル
	JNBE	ELE_ATR_GET_OVER		; 範囲オーバ

	MOVXBW	ELE_ATTR,DS:[SI][BX]		; エレメント属性
ELE_ATR_GET_EXIT:
	MOV	AX,0				; 0=正常
	RET
ELE_ATR_GET_OVER:
	MOV	AX,1				; 1=オーバ
	RET
ELE_ATR_GET	ENDP


; ****************************************************
;	エレメントの表示
;	-I- ELE_LEVEL  : エレメント何試合目か
;	    ELE_NUMBER : エレメント番号
;	    ELE_LINEATTR : エレメント線種類
;	    ELE_COLOR1 : エレメントカラー
;	    ELE_COLOR2 : エレメントカラー影
;	-O- AX         : 0=正常,1=オーバ
; ****************************************************

ELE_PLOT	PROC	NEAR
	MOV	BX,ELE_LEVEL			; エレメント何試合目か
	CMP	BX,ELE_TABLE[0]			; エレメント・テーブル
	JG	ELE_PLOT_OVER			; 範囲オーバ

	SHL	BX,1				; word pointer.
	MOV	SI,DS:ELE_TABLE[BX]		; SI=試合毎のエレメント群
	MOV	BX,ELE_NUMBER			; エレメント番号
	CMP	BX,DS:[SI][0]			; エレメント・テーブル
	JG	ELE_PLOT_OVER			; 範囲オーバ

	SHL	BX,1				; word pointer.
	MOV	DI,DS:[SI][BX]			; DI=エレメントアドレス

	MOV	CH,0				;
	MOV	CL,DS:[DI][0]			; CX=エレメント数
	INC	DI				; DI=ＸＹの座標をさすポインタ
ELE_PLOT_LOOP:
	PUSH	CX
	PUSH	DI
	MOVXBW	LIN_X1,DS:[DI][0]		; 線分Ｘ１
	MOVXBW	LIN_Y1,DS:[DI][1]		; 線分Ｙ１
	MOVXBW	LIN_X2,DS:[DI][2]		; 線分Ｘ２
	MOVXBW	LIN_Y2,DS:[DI][3]		; 線分Ｙ２

	CALL	PLOT_LINE			; 線を描く（垂直、水平）
	POP	DI
	POP	CX
	ADD	DI,2				; point 2byte.
	LOOP	ELE_PLOT_LOOP

ELE_PLOT_EXIT:
	MOV	AX,0				; 0=正常
	RET
ELE_PLOT_OVER:
	MOV	AX,1				; 1=オーバ
	RET
ELE_PLOT	ENDP


; ****************************************************
;	線を描く（但し垂直、水平しか引けません）
;	-I- LIN_X1 : 線分Ｘ１
;	    LIN_Y1 : 線分Ｙ１
;	    LIN_X2 : 線分Ｘ２
;	    LIN_Y2 : 線分Ｙ２
;	    ELE_LINEATTR : エレメント線種類
;	    ELE_COLOR1 : エレメントカラー
;	    ELE_COLOR2 : エレメントカラー影
; ****************************************************

PLOT_LINE	PROC	NEAR
	MOV	AX,LIN_X1		; 線分Ｘ１
	MOV	BX,LIN_X2		; 線分Ｘ２
	MOV	CX,LIN_Y1		; 線分Ｙ１
	MOV	DX,LIN_Y2		; 線分Ｙ２
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			; * 8
	SHL	BX,1			;
	SHL	BX,1			;
	SHL	BX,1			; * 8
	SHL	CX,1			;
	SHL	CX,1			;
	SHL	CX,1			; * 8
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			; * 8
	MOV	VX1,AX			; 線分Ｘ１
	MOV	VX2,BX			; 線分Ｘ２
	MOV	VY1,CX			; 線分Ｙ１
	MOV	VY2,DX			; 線分Ｙ２

	CMP	AX,BX			; Ｘ１とＸ２の比較
	JE	PLOT_LINE_V		;

PLOT_LINE_H:
	CMPX	VX1,VX2			;
	JB	PLOT_LINE_H_2		;
	MOV	AX,VX1			;
	MOV	BX,VX2			;
	MOV	VX1,BX			;
	MOV	VX2,AX			;
PLOT_LINE_H_2:
	SUB	VX1,1			;
;;;	ADD	VX2,1			;
;;	ADD	VX1,1			;
;;	SUB	VX2,1			;

	CMP	ELE_LINEATTR,1		; エレメント線種類
	JE	PLOT_LINE_H_FUTO	;

	SUB	VY1,1			;
	MOV	CX,3			; line width.
	MOVX	VCOL,ELE_COLOR1		; エレメントカラー
	CALL_w	DLINEH			; 水平ライン描画
;*;	SUB	VY1,1			;
;*;	MOV	CX,1			; line width.
;*;	MOVX	VCOL,ELE_COLOR2		; エレメントカラー影
;*;	CALL_w	DLINEH			; 水平ライン描画
;*;	ADD	VY1,4			;
;*;	MOV	CX,1			; line width.
;*;	CALL_w	DLINEH			; 水平ライン描画
	RET

PLOT_LINE_H_FUTO:
	SUB	VY1,3			;
	MOV	CX,7			; line width.
	MOVX	VCOL,ELE_COLOR_WHITE	; エレメントカラー白
	CALL_w	DLINEH			; 水平ライン描画
	RET

PLOT_LINE_V:
	CMPX	VY1,VY2			;
	JB	PLOT_LINE_V_2		;
	MOV	AX,VY1			;
	MOV	BX,VY2			;
	MOV	VY1,BX			;
	MOV	VY2,AX			;
PLOT_LINE_V_2:
	SUB	VY1,1			;
	ADD	VY2,1			;

	CMP	ELE_LINEATTR,1		; エレメント線種類
	JE	PLOT_LINE_V_FUTO	;

	SUB	VX1,1			;
	MOV	CX,3			; line width.
	MOVX	VCOL,ELE_COLOR1		; エレメントカラー
	CALL_w	DLINEV			; 垂直ライン描画
;*;	SUB	VX1,1			;
;*;	MOV	CX,1			; line width.
;*;	MOVX	VCOL,ELE_COLOR2		; エレメントカラー影
;*;	CALL_w	DLINEV			; 垂直ライン描画
;*;	ADD	VX1,4			;
;*;	MOV	CX,1			; line width.
;*;	CALL_w	DLINEV			; 垂直ライン描画
	RET
PLOT_LINE_V_FUTO:
	SUB	VY1,2			;
	ADD	VY2,2			;
	SUB	VX1,3			;
	MOV	CX,7			; line width.
	MOVX	VCOL,ELE_COLOR_WHITE	; エレメントカラー白
	CALL_w	DLINEV			; 垂直ライン描画
	RET
PLOT_LINE	ENDP

WINDOW	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	WDX1:WORD			; WINDOWS/point x1.
EXTRN	WDY1:WORD			; WINDOWS/point y1.
EXTRN	WDX2:WORD			; WINDOWS/point x2.
EXTRN	WDY2:WORD			; WINDOWS/point y2.

WIDTOUR_TBL	LABEL	WORD		; jump label.
		DW	TOUR_START	; トーナメント表スタート
		DW	TOUR_SHOW	; エレメント・テスト
		DW	TOUR_NAME	; エントリィ名前表示
		DW	TOUR_CHAR_SET	; トーナメント・エントリィ登録
		DW	TOUR_KICKOFF	; トーナメント試合・キックオフ
		DW	TOUR_1GET	; トーナメント試合・組み合せ
		DW	TOUR_1SHOCK	; トーナメント試合・衝撃！
		DW	TOUR_1END	; トーナメント試合・勝敗
		DW	TOUR_OFFSIDE	; トーナメント試合・オフサイド
		DW	TOUR_CHAR_GET	; トーナメント・キャラクタ番号取得
		DW	TOUR_REDRAW	; トーナメント表・再描画
		DW	TOUR_SCH_FIGHT	; 対戦相手の検索
		DW	TOUR_KZ_REDRAW	; トーナメント表飾り再描画
WIDTOUR_TBL_E	LABEL	WORD		; jump label end.

TOUR_LEVEL	DW	0		; 第何試合か？
TOUR_LINK	DW	0		; 組み合せ番号
TOUR_KUMI_CNT	DW	0		; 組み合せ数
TOUR_KUMI_KOH_TBL	LABEL	BYTE	; 組み合せ表 甲
		DB	0		; max.
		DB	0		; 1
		DB	0		; 2
		DB	0		; 3
		DB	0		; 4
		DB	0		; 5
		DB	0		; 6
		DB	0		; 7
		DB	0		; 8
TOUR_KUMI_OTSU_TBL	LABEL	BYTE	; 組み合せ表 乙
		DB	0		; max.
		DB	0		; 1
		DB	0		; 2
		DB	0		; 3
		DB	0		; 4
		DB	0		; 5
		DB	0		; 6
		DB	0		; 7
		DB	0		; 8
TOUR_KUMI_KACHI_TBL	LABEL	BYTE	; 組み合せ表 勝ったチーム番号
		DB	0		; max.
		DB	0		; 1
		DB	0		; 2
		DB	0		; 3
		DB	0		; 4
		DB	0		; 5
		DB	0		; 6
		DB	0		; 7
		DB	0		; 8

		EVEN
TOUR_TEAM_KOH	DW	0		; 組み合せ・甲チーム
TOUR_TEAM_OTSU	DW	0		; 組み合せ・乙チーム
ENTRY_CHAR_KOH	DW	0		; キャラクタ番号・甲チーム
ENTRY_CHAR_OTSU	DW	0		; キャラクタ番号・乙チーム

TOUR_JYOUTAI	DW	0		; 状態 1=甲の勝ち,2=乙の勝ち,3=試合開始

TEAM_KACHIMAKE_TBL	LABEL	BYTE	; 勝敗表 (0=まだ,1=勝ち,2=負け)
		DB	16		; max.　１６チーム
		DB	16 DUP (0)	;

		EVEN
SHOCK_WAIT	DW	2		; ショック待ち単位時間

ELE_ATTR_ON	DW	1		; エレメント属性／ＯＮ
ELE_ATTR_OFF	DW	0		; エレメント属性／ＯＦＦ

GR_NAMXX	DW	0		; 名前表示Ｘ位置
GR_NAMYY	DW	0		; 名前表示Ｙ位置
GR_TXTCLR	DW	15		; 文字表示色
GR_TXTCSZ	DW	0		; 文字表示サイズ

GR_N_XX		DW	1		; 名前Ｘオフセット
GR_N_YY		DW	4		; 名前Ｙオフセット

;;NAME_LEN_MAX	DW	10*2		; 表示名前の最長

ADRS_ENTRY_TABLE DW	TBL_MENBAR_ENTRY ; エントリィテーブルアドレス
TBL_MENBAR_ENTRY DB	16 DUP (0)	 ; 16人のエントリィテーブル

ENTRY_NUMBER	DW	0		; エントリィ番号
ENTRY_NAMEADRS	DW	0		; エントリィ名前

NAM_TXTCLR_ST	DW	15		; 名前文字表示色・通常
NAM_TXTCLR_MK	DW	9		; 名前文字表示色・負け
NAM_TXTSIZ	DW	0		; 名前文字サイズ

ELE_RED_COL1	DW	10		; エレメント赤カラー
ELE_RED_COL2	DW	0		; エレメント赤カラー影
ELE_GREY_COL1	DW	6		; エレメント暗カラー
ELE_GREY_COL2	DW	0		; エレメント暗カラー影

ELE_LEVEL	DW	1		; エレメント何試合目か
ELE_NUMBER	DW	1		; エレメント番号
ELE_ATTR	DW	0		; エレメント属性

ELE_LINEATTR	DW	0		; エレメント線種類
ELE_COLOR_WHITE	DW	15		; エレメントカラー白
ELE_COLOR1	DW	0		; エレメントカラー
ELE_COLOR2	DW	0		; エレメントカラー影

LIN_X1		DW	0		; 線分Ｘ１
LIN_Y1		DW	0		; 線分Ｙ１
LIN_X2		DW	0		; 線分Ｘ２
LIN_Y2		DW	0		; 線分Ｙ２

WDXX		DW	0		; point x.
WDYY		DW	0		; point y.

REG_BP		DW	0		; register BP.

;	ネームＢＯＸ

		;	max  1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12
TR_BOX_X	DB	 16, 2, 2, 2, 2, 2, 2, 2, 2	;ＢＯＸ Ｘ座標
		DB	    56,56,56,56,56,56,56,56	;
TR_BOX_Y	DB	 16, 2,6, 10,14, 18,22, 26,30	;ＢＯＸ Ｙ座標
		DB	     2,6, 10,14, 18,22, 26,30	;
;;TR_BOX_Y	DB	 16, 2,8, 14,20, 26,32, 38,44	;ＢＯＸ Ｙ座標
;;		DB	     2,8, 14,20, 26,32, 38,44	;
TR_BOX_XL	DW	10*2+2		; ＢＯＸ Ｘサイズ
TR_BOX_YL	DW	24		; ＢＯＸ Ｙサイズ

;	エレメント・属性テーブル

ELE_ATR_TABLE	LABEL	WORD
		DW	4		; max
		DW	ELE_A_1
		DW	ELE_A_2
		DW	ELE_A_3
		DW	ELE_A_4
ELE_A_1		DB	16,16 DUP (0)	; 第１試合
ELE_A_2		DB	 8, 8 DUP (0)	; 第２試合
ELE_A_3		DB	 4, 4 DUP (0)	; 第３試合
ELE_A_4		DB	 1, 1 DUP (0)	; 第４試合

;	エレメント・テーブル

ELE_TABLE	LABEL	WORD
		DW	4		; max
		DW	ELE_1
		DW	ELE_2
		DW	ELE_3
		DW	ELE_4
ELE_1		LABEL	WORD		; 第１試合
		DW	16		; max
		DW	ELE_1_1 ,ELE_1_2 ,ELE_1_3 ,ELE_1_4
		DW	ELE_1_5 ,ELE_1_6 ,ELE_1_7 ,ELE_1_8
		DW	ELE_1_9 ,ELE_1_10,ELE_1_11,ELE_1_12
		DW	ELE_1_13,ELE_1_14,ELE_1_15,ELE_1_16
ELE_2		LABEL	WORD		; 第２試合
		DW	8		; max
		DW	ELE_2_1 ,ELE_2_2 ,ELE_2_3 ,ELE_2_4
		DW	ELE_2_5 ,ELE_2_6 ,ELE_2_7 ,ELE_2_8
ELE_3		LABEL	WORD		; 第３試合
		DW	4		; max
		DW	ELE_3_1 ,ELE_3_2 ,ELE_3_3 ,ELE_3_4
ELE_4		LABEL	WORD		; 第４試合
		DW	1		; max
		DW	ELE_4_1
		;	count   x,y    x,y    x,y
ELE_1_1		DB	  2,   24,3 , 28,3 , 28,5	; 3と7の間だから5
ELE_1_2		DB	  2,   24,7 , 28,7 , 28,5
ELE_1_3		DB	  2,   24,11, 28,11, 28,13
ELE_1_4		DB	  2,   24,15, 28,15, 28,13
ELE_1_5		DB	  2,   24,19, 28,19, 28,21
ELE_1_6		DB	  2,   24,23, 28,23, 28,21
ELE_1_7		DB	  2,   24,27, 28,27, 28,29
ELE_1_8		DB	  2,   24,31, 28,31, 28,29
		;	count   x,y    x,y    x,y
ELE_1_9		DB	  2,   56,3 , 52,3 , 52,5
ELE_1_10	DB	  2,   56,7 , 52,7 , 52,5
ELE_1_11	DB	  2,   56,11, 52,11, 52,13
ELE_1_12	DB	  2,   56,15, 52,15, 52,13
ELE_1_13	DB	  2,   56,19, 52,19, 52,21
ELE_1_14	DB	  2,   56,23, 52,23, 52,21
ELE_1_15	DB	  2,   56,27, 52,27, 52,29
ELE_1_16	DB	  2,   56,31, 52,31, 52,29
		;	count   x,y    x,y    x,y
ELE_2_1		DB	  2,   28,5 , 32,5 , 32,9
ELE_2_2		DB	  2,   28,13, 32,13, 32,9
ELE_2_3		DB	  2,   28,21, 32,21, 32,25
ELE_2_4		DB	  2,   28,29, 32,29, 32,25
ELE_2_5		DB	  2,   52,5 , 48,5 , 48,9
ELE_2_6		DB	  2,   52,13, 48,13, 48,9
ELE_2_7		DB	  2,   52,21, 48,21, 48,25
ELE_2_8		DB	  2,   52,29, 48,29, 48,25
		;	count   x,y    x,y    x,y
ELE_3_1		DB	  2,   32,9 , 36,9 , 36,17
ELE_3_2		DB	  2,   32,25, 36,25, 36,17
ELE_3_3		DB	  2,   48,9 , 44,9 , 44,17
ELE_3_4		DB	  2,   48,25, 44,25, 44,17
		;	count   x,y    x,y
ELE_4_1		DB	  1,   36,17, 44,17

DATA	ENDS

	END
;
;	end of "WIDTOUR.ASM"
;
