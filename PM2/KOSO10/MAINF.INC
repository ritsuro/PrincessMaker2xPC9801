; "MAINF.INC" 486/33 make by R.H 1992/02/02
;
;	main function.
;
; define.

FNO_PRINT		EQU	0	; print string.
FNO_DECSTR		EQU	1	; val DX to dec string.
FNO_STRDEC		EQU	2	; dec string to DX reg.
FNO_HEXSTR		EQU	3	; val DX to hex string.
FNO_STRHEX		EQU	4	; hex string to DX reg.
FNO_BINSTR		EQU	5	; val DX to bin string.
FNO_STRBIN		EQU	6	; bin string to DX reg.
FNO_CHPUT		EQU	7	; print of ascii character.
FNO_PRNAB		EQU	8	; print of a register(BIN).
FNO_LFPRN		EQU	9	; line feed.
FNO_D10STR		EQU	10	; i*4 value -> decimal string.
FNO_STRZTS		EQU	11	; zero to space. "00123"->"  123"
FNO_STRSPL		EQU	12	; space pless. "  123"->"123  "
FNO_MSCSRT		EQU	13	; カーソルスタート
FNO_MSCMOV		EQU	14	; カーソル移動
FNO_MSCMV2		EQU	15	; カーソル移動（遅延処理無し）
FNO_MSCSTP		EQU	16	; カーソルストップ
FNO_MSCSTS		EQU	17	; マウスカーソルステータス
FNO_MSWWAT		EQU	18	; カーソルボタン待ち
FNO_KEYTEN		EQU	19	; キーボード・読み込み
FNO_FEDIN		EQU	20	; Ｆ・Ｉ（フェードイン）
FNO_FEDOUT		EQU	21	; Ｆ・Ｏ（フェードアウト）
FNO_WHTIN		EQU	22	; ＷＨＩＴＥ・ＩＮ
FNO_WHTOUT		EQU	23	; ＷＨＩＴＥ・ＯＵＴ
FNO_BLACK		EQU	24	; ブラックアウト
FNO_WHITE		EQU	25	; ＷＨＩＴＥ
FNO_PLTOL		EQU	26	; パレット・オーバラップ
FNO_PLTMIX		EQU	27	; パレット・混合
FNO_NORMIN		EQU	28	; ノーマルカラー
FNO_PLTFIS		EQU	29	; Ｆ・Ｉ／時分割初期
FNO_PLTFOS		EQU	30	; Ｆ・Ｏ／時分割初期
FNO_PLTCIS		EQU	31	; カラー・ＩＮ／時分割初期
FNO_PLTOLS		EQU	32	; ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割初期
FNO_PLTOLSE		EQU	33	; ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割初期/編集機能
FNO_PLTOLT		EQU	34	; ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割処理
FNO_PLTOLTE		EQU	35	; ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割処理/編集機能
FNO_TMVWAT		EQU	36	; V-SYNC timer wait.
FNO_TMVSET		EQU	37	; V-SYNC timer set.
FNO_TMVCHK		EQU	38	; V-SYNC timer check.
FNO_TMVEWT		EQU	39	; V-SYNC timer end wait.
FNO_TMVST2		EQU	40	; V-SYNC timer2 set.
FNO_TMVCK2		EQU	41	; V-SYNC timer2 check.
FNO_TMVST3		EQU	42	; V-SYNC timer3 set.
FNO_TMVCK3		EQU	43	; V-SYNC timer3 check.
FNO_VTXPRN		EQU	44	; vram text print.
FNO_VTXPOR		EQU	45	; vram text print OR.
FNO_VTXPFC		EQU	46	; vram text print fuchi.
FNO_VTXSIZ		EQU	47	; character size set.
FNO_VTXCOL		EQU	48	; character color set.
FNO_BOXPAL		EQU	49	; ＢＯＸペイント
FNO_BOXMSS		EQU	50	; ＢＯＸメッシュ
FNO_BOXNOT		EQU	51	; ＢＯＸ反転
FNO_BOXMCH		EQU	52	; ＢＯＸチェック模様
FNO_PT_PALET_SETONLY	EQU	53	; パレットテーブルセットのみ
FNO_PT_PATTERN_LD	EQU	54	; pattern load.
FNO_PT_PATTERN_LDA	EQU	55	; pattern add load.
FNO_PT_PATTERN_PUT	EQU	56	; pattern put.
FNO_PT_MASK_PAT_PUT	EQU	57	; pattern mask put.
FNO_PT_MASK_PTF_PUT	EQU	58	; pattern mask offset put.
FNO_PT_PATTERN_BANK	EQU	59	; pattern bank set.
FNO_PT_VRAM_ID_ALL_ASSIGN EQU	60	; vram ID all asigned.
FNO_WIDCLEN_MONTH	EQU	61	; WINDOWS/カレンダー・月データ
FNO_MITPRN		EQU	62	; mini string.
FNO_MITCOL		EQU	63	; mini string color.
FNO_MDTPRN		EQU	64	; MID string.
FNO_MWTPRN		EQU	65	; WIDE string.
FNO_MBTPRN		EQU	66	; BIG string.
FNO_MGXPRN		EQU	67	; GAINAX mini string.
FNO_MGXPRNP		EQU	68	; GAINAX mini string.(put)
FNO_PT_PATTERN_CLEAR	EQU	69	; parts buffer clear.
FNO_PT_PATTERN_GET	EQU	70	; parts get.
FNO_MOVEVR		EQU	71	; vram to vram move.
FNO_MOV1VR		EQU	72	; vram to vram move 1 plean.

;
;	end of "MAINF.INC"
;
