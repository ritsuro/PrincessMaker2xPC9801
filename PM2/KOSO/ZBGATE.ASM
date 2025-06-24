; "ZBGATE.ASM" 486/50 make by R.H 1992/05/15
;
;
;	Z B I O S   extrn gate.
;
;	seg CODE01 -> seg CODE.
;
;
; public subroutine.

EXT01	MACRO	LBL
CODE	SEGMENT	PUBLIC	'CODE'
	ASSUME	CS:CODE
	PUBLIC	c_&LBL
c_&LBL	PROC	NEAR
	CALL	FAR PTR GT01&LBL
	RET
c_&LBL	ENDP
CODE	ENDS
CODE01	SEGMENT	PUBLIC	'CODE01'
	ASSUME	CS:CODE01
	EXTRN	LBL:NEAR
GT01&LBL	PROC	FAR
	CALL	LBL
	RET
GT01&LBL	ENDP
CODE01	ENDS
	ENDM


EXT02	MACRO	LBL
CODE	SEGMENT	PUBLIC	'CODE'
	ASSUME	CS:CODE
	PUBLIC	c_&LBL
c_&LBL	PROC	NEAR
	CALL	FAR PTR GT01&LBL
	RET
c_&LBL	ENDP
CODE	ENDS
WINDOW	SEGMENT	PUBLIC	'WINDOW'
	ASSUME	CS:WINDOW
	PUBLIC	w_&LBL
w_&LBL	PROC	NEAR
	CALL	FAR PTR GT01&LBL
	RET
w_&LBL	ENDP
WINDOW	ENDS
CODE01	SEGMENT	PUBLIC	'CODE01'
	ASSUME	CS:CODE01
	EXTRN	LBL:NEAR
GT01&LBL	PROC	FAR
	CALL	LBL
	RET
GT01&LBL	ENDP
CODE01	ENDS
	ENDM

;	PICTUER.ASM

EXT01	PICTUER_INIT		; picture init.

;	CHILD.ASM

EXT02	CHILD_PROCESS_LOAD	; (*.com) child process load.
EXT02	CHILD_PROCESS_JUMP	; (*.com) child process jump.
EXT02	CHILD_PROCESS_HEAD	; (*.com) child process header set.
EXT02	CHILD_PROCESS_HEAD_RD	; (*.com) child process header read.
EXT02	CHILD_PROCESS_TIMER	; (*.com) child process timer.
EXT02	CHILD_PROCESS_TIMER_RD	; (*.com) child process timer read.

;	GETARG.ASM

;*;EXT02	GETARG		; get argument.	1993/06/18 メモリ節約のためカット

;	MACHINE.ASM

;*;EXT02	MACHINE_SET	; machine set.	1993/06/18 メモリ節約のためカット

;	MACLIB.ASM

EXT02	PRNAH			; print ah reg.
EXT02	PRINT			; print string.
EXT02	PRINTES			; print of string ES.
EXT02	DECSTR			; val DX to dec string.
EXT02	INPUT			; string input.
EXT02	STRDEC			; dec string to DX reg.
EXT02	HEXSTR			; val DX to hex string.
EXT02	STRHEX			; hex string to DX reg.
EXT02	BINSTR			; val DX to bin string.
EXT02	STRBIN			; bin string to DX reg.
EXT02	STRCMP			; string compare.
EXT02	CLS				; text clear.
EXT02	CSLON			; cursole on.
EXT02	CSLOFF			; cursole off.
EXT02	INPCHR			; 1 char input.
EXT02	CHPUT			; print of ascii character.
EXT02	KESCAP			; ESC key & break check & pause.
EXT02	KEYLOD			; key buffer read.
EXT02	PRNAB			; print of a register(BIN).
EXT02	LOCATE			; locate.
EXT02	LFPRN			; line feed.
EXT02	FFPRN			; colum shift.
EXT02	D10STR			; i*4 value -> decimal string.
EXT02	STRZTS			; zero to space. "00123" - > "  123"
EXT02	STRSPL			; space pless. "  123" - > "123  "
EXT02	SIGSTR			; signed val DX to dec string.
EXT02	STRSPD			; space del" file  .asm" - > "file.asm"
EXT02	MEMCPY			; memory to memory copy.
EXT02	TXCOLR			; text color.

;	GRPACS.ASM

EXT02	GRPSRT			; graphics start.
EXT02	GRPEND			; graphics end.
EXT02	GRPCLS			; graphics clear screen.

;	VKEYBORD.ASM

EXT02	KYBSRT			; keybord start.
EXT02	KYBEND			; keybord end.
EXT02	KYBSTP			; keybord stop.
EXT02	KYBCNT			; keybord cont.
EXT02	KYBONS			; keybord STOP key on.
EXT02	KYBOFS			; keybord STOP key off.

;	VKYLC.ASM

EXT02	KEYTEN			; キーボード・読み込み
EXT02	KEYRET			; キーボード・ＲＥＴキー読み込み
EXT02	KEYANY			; キーボード・何か押した？
EXT02	KEYOFW			; キーボードＯＦＦ待ち
EXT02	KEYTRG			; キーボード・トリガーチェック
EXT02	KEYHLT			; キーボード機能のＯＮ／ＯＦＦ

;	VMOUSE.ASM

EXT02	MUSINI			; マウスの初期化
EXT02	MUSRED			; マウス読み込み
EXT02	MUSSHT			; マウス読み込み・ワンショット
EXT02	MUSSET			; マウス座標セット
EXT02	MUSSTB			; マウスボタンセット
EXT02	MUSSTP			; マウスの終了
EXT02	MUSWAT			; マウスボタンＯＦＦ待ち
EXT02	MUSDSP			; マウスＤＩＲのクリア
EXT02	MUSAREA			; マウスエリアの設定

;	VMUSCOR.ASM

EXT02	MSCSRT			; カーソルスタート
EXT02	MSCMOV			; カーソル移動
EXT02	MSCMV2			; カーソル移動（遅延処理無し）
EXT02	MSCSTP			; カーソルストップ
EXT02	MSCSTS			; マウスカーソルステータス
;;EXT02	MSCPNT			; カーソル表示位置
EXT02	MSCINTSW		; マウス割り込みカーソルON/OFF
EXT02	MSCPLNMDE		; カーソル・プレーンモード

;	VMUSCR2.ASM

EXT02	MSWWAT			; カーソルボタン待ち

;	EFECT2.ASM

EXT02	BOXPAL			; ＢＯＸペイント
EXT02	BOX3CLR			; ＢＯＸ３プレーンクリア
EXT02	BOXMSS			; ＢＯＸメッシュ
EXT02	BOXNOT			; ＢＯＸ反転
EXT02	BOXMCH			; ＢＯＸチェック模様
EXT02	BOXPAI			; ＢＯＸ１プレーンペイント
EXT02	BOXBLK			; ＢＯＸ１プレーンヌキ
EXT02	BOXMSU			; ＢＯＸ１プレーンメッシュ
EXT02	BOXNTS			; ＢＯＸ１プレーン反転
EXT02	BOXMTU			; ＢＯＸ１プレーンチェック模様
EXT02	BOXVRAM400TO480		; ＢＯＸVRAM400から479ﾗｲﾝｸﾘｱ
EXT02	BOXLEDLAMP		; LED like lamp.(WIDDISK.ASM)

;	EFECT2.ASM

EXT02	EF_BAR_LINE		; bar graphic line.

;	PARTST.ASM

EXT02	C1PATINI		; パーツセット初期処理
EXT02	C1PATCLR		; パーツセットクリア
EXT02	C1PATGTA		; パーツＧＥＴ圧縮無し
EXT02	C1PATPUT		; パーツＰＵＴ
EXT02	C1PATPTX		; パーツＰＵＴ座標指定
EXT02	C1PATPTF		; パーツＰＵＴオフセット指定
EXT02	C1PATLOD		; パーツロード
EXT02	C1PATLDA		; パーツ追加ロード
EXT02	C1PATBNK		; バンクチェンジ
EXT02	C1PATOPE		; オペレーションセット
EXT02	C1PATEFC		; パーツＰＵＴエフェクト

;	PARTT2.ASM

EXT02	C1PATSIZ		; パーツサイズのＧＥＴ
EXT02	C1PATMST		; マスクパーツのＰＵＴプレーン設定
EXT02	C1PATPTM		; マスクパーツＰＵＴ
EXT02	C1PATPXM		; マスクパーツＰＵＴ座標指定
EXT02	C1PATPFM		; マスクパーツＰＵＴオフセット指定
EXT02	C1PATTPD		; 先頭パターンデータの削除

;	PLSLD7.ASM

EXT02	C1PLSVIW		; ＰＵＴＶＩＥＷの設定
EXT02	C1PLSVWS		; ＰＵＴＶＩＥＷの解除
EXT02	C1PLSMOD		; 圧縮モード切り替え
EXT02	C1PLSSKP		; パーツＰＵＴのプレーンスキップ

;	PLTPAT.ASM

EXT02	C1PLTPAT		; パーツバッファからパレットを取り出す

;	DATPL3A.ASM

EXT02	C1BUNPLE		; 圧縮フォーマットデータ復元

;	PLTEFC.ASM

EXT02	FEDIN			; Ｆ・Ｉ（フェードイン）
EXT02	FEDOUT			; Ｆ・Ｏ（フェードアウト）
EXT02	WHTFLS			; ＷＨＩＴＥ・ＦＬＡＳＨ
EXT02	WHTIN			; ＷＨＩＴＥ・ＩＮ
EXT02	WHTOUT			; ＷＨＩＴＥ・ＯＵＴ
EXT02	COLFLS			; カラー・ＦＬＡＳＨ
EXT02	COLFUL			; カラー・ＦＵＬＬ
EXT02	BLACK			; ブラックアウト
EXT02	WHITE			; ＷＨＩＴＥ
EXT02	BRIIN			; 明度５０％からノーマルへ
EXT02	BRIOUT			; 明度５０％ダウン
EXT02	COLBCK			; 色相反転
EXT02	COLRET			; 色相戻し
EXT02	FFWHT			; ＷＨＩＴＥ反射感
EXT02	PLTOL			; パレット・オーバラップ
EXT02	PLTMIX			; パレット・混合
EXT02	NORMIN			; ノーマルカラー
EXT02	DWN50P			; 明度５０％ダウン（瞬間）

EXT02	PLTFIS			; Ｆ・Ｉ（フェードイン）／時分割初期
EXT02	PLTFOS			; Ｆ・Ｏ（フェードアウト）／時分割初期
EXT02	PLTCIS			; カラー・ＩＮ／時分割初期
EXT02	PLTOLS			; パレット・オーバラップ／時分割初期
EXT02	PLTOLSE			; パレット・オーバラップ／時分割初期／編集機能
EXT02	PLTOLT			; パレット・オーバラップ／時分割処理
EXT02	PLTOLTE			; パレット・オーバラップ／時分割処理／編集機能

EXT02	PLTINTSW		; パレット・割込み処理スイッチ
EXT02	PLTINTSPD		; パレット・割込み処理スピード
EXT02	PLTINTWT		; パレット・割込み処理終了待ち
EXT02	PLTINTSTP		; パレット・割込み処理中断

EXT02	PLTINT_P10_ON	; palet10変化割込ON
EXT02	PLTINT_P10_OFF	; palet10変化割込OFF

;	PLTSET.ASM

EXT02	C1PLSET			; パレットセット
EXT02	C1PLGET			; パレットＧＥＴ
EXT02	C1PLPUT			; パレットＰＵＴ
EXT02	C1PLPSET		; パレット編集セット
EXT02	C1PL1PUT		; パレット単色ＰＵＴ

;	VHVLINE.ASM

EXT02	DLINEH			; 水平ライン描画
EXT02	DLINEV			; 垂直ライン描画

;	VTIMER.ASM

EXT02	TMVSRT			; V-SYNC timer start.
EXT02	TMVEND			; V-SYNC timer end.
EXT02	TMVWAT			; V-SYNC timer wait.
EXT02	TMVSET			; V-SYNC timer set.
EXT02	TMVCHK			; V-SYNC timer check.
EXT02	TMVEWT			; V-SYNC timer end wait.
EXT02	TMVST2			; V-SYNC timer2 set.
EXT02	TMVCK2			; V-SYNC timer2 check.
EXT02	TMVST3			; V-SYNC timer3 set.
EXT02	TMVCK3			; V-SYNC timer3 check.
EXT02	TMVWT4			; V-SYNC timer4 wait.
EXT02	TMVST5			; V-SYNC timer5 set.
EXT02	TMVCK5			; V-SYNC timer5 check.
EXT02	TMVST6			; V-SYNC timer6 set.
EXT02	TMVCK6			; V-SYNC timer6 check.
EXT02	TMVST7			; V-SYNC timer7 set.
EXT02	TMVCK7			; V-SYNC timer7 check.

;	VRMOVE.ASM

EXT02	MOVEVR			; vram to vram move.
EXT02	MOV1VR			; vram to vram move 1 plean.

;	STRINGS.ASM

EXT02	STRSET			; 文字列バッファセット
EXT02	STRSETZ			; 文字列バッファセット
EXT02	STRFILL			; 文字列バッファＦＩＬＬ
EXT02	STRCLEAR		; 文字列バッファクリア
EXT02	STRZEROC		; 文字列バッファ０クリア
EXT02	STRSETADD		; 文字列の連結
EXT02	STRLENGTH		; 文字列長さ
EXT02	STRLENSPZ		; 文字列長さスペースまで
EXT02	STRCAPS			; 文字列大文字化
EXT02	STRXCHG			; 文字列キャラクタ書き換え


;	MGXTXT.ASM

EXT02	MGXPRN			; GAINAX mini string.
EXT02	MGXPRNP			; GAINAX mini string.(put)

;	MIBTXT.ASM

EXT02	MBTPRN			; BIG string. (null=end of string)

;	MIDTXT.ASM

EXT02	MDTPRN			; MID string. (null=end of string)

;	MINTXT.ASM

EXT02	MITPRN			; mini string. (null=end of string)
EXT02	MITCOL			; mini string color.

;	MIWTXT.ASM

EXT02	MWTPRN			; WIDE string. (null=end of string)

;	VRTEXT.ASM

EXT02	VTXPRN			; vram text print.
EXT02	VTXPOR			; vram text print OR.
EXT02	VTXPFC			; vram text print fuchi.
EXT02	VTXSIZ			; character size set.
EXT02	VTXCOL			; character color set.

;	UNITSTR.ASM

EXT02	UNITSTR			; 単位表記
EXT02	UNIT_DATE_VAL_TO_STR	; 数値から日付文字列へ
EXT02	UNIT_S_GOLD		; お金文字列
EXT02	UNIT_S_POINT		; ポイント文字列
EXT02	UNIT_S_S2KETA		; 小数２桁文字列
EXT02	UNIT_S_S2KETA_G		; 小数２桁文字列(ｸﾞﾗﾌ)

;	RANDAM.ASM

EXT02	RANDAM_STR		; 乱数スタート
EXT02	RANDAM			; 乱数範囲指定

;	ICON.ASM

EXT02	ICON_PUT		; ICON put.

;	WORDTOOL.ASM

EXT02	WORDTL_N_HNZN	 	; 文字列半角を全角

;	WIDTEXT.ASM

EXT01	WID_TEXT_OPEN		; WINDOWS/テキストウインドウＯＰＥＮ
EXT01	WID_TEXT_CLOSE		; WINDOWS/テキストウインドウＣＬＯＳＥ
EXT01	WID_TEXT_STRIME		; WINDOWS/テキストウインドウ選択
EXT01	WID_TEXT_PRINT		; WINDOWS/テキストウインドウ表示
EXT01	WID_TEXT_PAUSE		; WINDOWS/テキストウインドウＰＡＵＳＥ
EXT01	WID_TEXT_LF		; WINDOWS/テキストウインドウ改行
EXT01	WID_TEXT_KNJ		; WINDOWS/テキストウインドウ漢字表示
EXT01	WID_TEXT_ANK		; WINDOWS/テキストウインドウＡＮＫ表示
EXT01	WID_TEXT_CLR		; WINDOWS/テキストウインドウクリア
EXT01	WID_TEXT_CURRENT	; WINDOWS/ﾃｷｽﾄｳｲﾝﾄﾞｳｶﾚﾝﾄの取得
EXT01	WID_TEXT_TIMER		; WINDOWS/テキストウインドウタイマ

;	WIDMULT.ASM

EXT01	WIDMULT			; WINDOWS/マルチアイテム

;	WIDSLCT.ASM

EXT01	WIDSLC			; WINDOWS/セレクト・ウインドウ
EXT01	WIDSLC2			; WINDOWS/セレクト（簡易指定）

;	V98DSPST.ASM

EXT02	VRM98DP			; PC98 vram show bank.
EXT02	VRM98WT			; PC98 vram write bank.
EXT02	VRM98NOW		; PC98 vram bank now.

;	PARACALC.ASM

EXT02	PCALC_DAYS		; 日次処理
;;EXT02	PCALC_M_BORN		; 月次成長処理
EXT02	PCALC_BORTHDAY		; 誕生日成長処理
EXT02	PCALC_GOLDADD		; 所持金へ加算
EXT02	PCALC_GOLDSUB		; 所持金から減算
EXT02	PCALC_GOLDSUB2		; 所持金から減算2
EXT02	PCALC_GOLDCMP		; 所持金と比較

;	USERTOOL.ASM

EXT02	USERWAIT		; user wait.
EXT02	KANJITUME		; 漢字文字詰め処理
EXT02	KANJISHORT		; 漢字文字列を半角に詰める
EXT02	KANJICHOT		; 漢字文字列をちょっとだけ半角に詰める

;	DSKCH2.ASM

EXT01	DKCINI			; ディスクチェンジ初期処理
EXT01	DKCCHK			; ディスクチェンジチェック

	END
;
;	end of "ZBGATE.ASM"
;
