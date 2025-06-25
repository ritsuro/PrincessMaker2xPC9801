; "PLSLD7.ASM"  PS55Z/S14 PC-9801UV11 make by R.Hashimoto 1991/12/02
;
INCLUDE	TSTSET.INC
;
;	範囲指定ＰＵＴ
;
; 旧 PLSLD2.ASM より
;
;	オーバラップ処理用に VCXRTW_OL （オーバラップＰＵＴ）
;	を作成しました。タイミング用タイマはタイマー１を使用。
;	オーバラップ単位時間の変更はBBOVTM（オーバラップタイム）を変更。
;	1991/07/10  PLSLD5.ASM ヘ移動しました。
;
;	VRMMOV.ASM も同様の処理をしている。
;
;
;	プレーン毎のスキップを行えるようにしました。これは縦／横圧縮モード
;	(PLSMDE=0:通常,1:縦方向) オーバラップ時(BBOVLP)のいずれでも使えます。
;	CALL	C1PLSSKP		; パーツＰＵＴのプレーンスキップ
;		スキッププレーン (DX=bit3:plean3,bit2:plean2,bit1:1,bit0:0)
;
;
;	ＶＲＡＭの横幅を自由に設定出来るようになりました。
;	これで狭い仮想ＶＲＡＭにも対応できます。
;	(PLSLD2.ASM,PLSLD3.ASM,PLSLD4.ASM共通)
;
;		EXTRN	SSGRW:WORD	; visual data plean width.
;
;
;	ＰＵＴＶＩＥＷの設定が設定出来るようになりました。
;	（現在はノーマルＰＵＴ時のみ）
;	CALL	C1PLSVIW		; ＰＵＴＶＩＥＷの設定
;	-I- VRPX   : ＧＥＴ Ｘ座標
;	    VRPY   : ＧＥＴ Ｙ座標
;	    VRLENPX: ＧＥＴ Ｘサイズ
;	    VRLENPY: ＧＥＴ Ｙサイズ
;
;
; public subroutine.

MOVX	MACRO	DEST,SOU
	MOV	AX,SOU
	MOV	DEST,AX
	ENDM

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	C1PLSVIW		; ＰＵＴＶＩＥＷの設定
PUBLIC	C1PLSVWS		; ＰＵＴＶＩＥＷの解除
PUBLIC	C1PLSMOD		; 圧縮モード切り替え
PUBLIC	C1PLSSKP		; パーツＰＵＴのプレーンスキップ

PUBLIC	OFSUNPLS		; データ復元(範囲指定)
PUBLIC	OFSUNPOR		; データ復元ＯＲ処理
PUBLIC	OFSUNPORS		; データ復元ＯＲ処理単プレーンパターン
PUBLIC	OFSUNPLSM		; マスク化

EXTRN	VCXRTW_OL:NEAR		; オーバラップＰＵＴ

EXTRN	C1BUNPLE:NEAR		; 圧縮フォーマットデータ復元

EXTRN	C1VV_BANK_CHG_ES:NEAR	; vram bank check & chenge.(WRITE) ES
EXTRN	C1VV_PLEAN_SLCT:NEAR	; plean select.
EXTRN	C1VV_MODE_PSET:NEAR	; vram put mode PSET.
EXTRN	C1VV_MODE_OR:NEAR	; vram put mode OR.
EXTRN	C1VV_MODE_AND:NEAR	; vram put mode AND.
EXTRN	C1VV_BANK_CHK:NEAR	; vram bank check. DX


;	ＰＵＴＶＩＥＷの設定
;	-I- VRPX   : ＧＥＴ Ｘ座標
;	    VRPY   : ＧＥＴ Ｙ座標
;	    VRLENPX: ＧＥＴ Ｘサイズ
;	    VRLENPY: ＧＥＴ Ｙサイズ

C1PLSVIW	PROC	NEAR
	MOV	FLAGPUTVIEW,1		; ＰＵＴＶＩＥＷフラグ
	RET
C1PLSVIW	ENDP


;	ＰＵＴＶＩＥＷの解除

C1PLSVWS	PROC	NEAR
	MOV	FLAGPUTVIEW,0		; ＰＵＴＶＩＥＷフラグ
	RET
C1PLSVWS	ENDP


;	圧縮モード切り替え
;	-I- DX : 圧縮モード(0:通常,1:縦方向)

C1PLSMOD	PROC	NEAR
	MOV	PLSMDE,DX	; 圧縮モード(0:通常,1:縦方向)
	RET
C1PLSMOD	ENDP



;	パーツＰＵＴのプレーンスキップ
;	-I- DX : スキッププレーン (bit3:plean3,bit2:plean2,bit1:1,bit0:0)

C1PLSSKP	PROC	NEAR
	MOV	PRSSKP,DX		; パーツＰＵＴのスキッププレーン
	RET
C1PLSSKP	ENDP


;	データ復元(範囲指定)
;	-I- VRX    : ＰＵＴ Ｘ座標
;	    VRY    : ＰＵＴ Ｙ座標
;	    VRLENX : Ｘ方向長さ
;	    VRLENY : Ｙ方向長さ
;	    BPNTOF : データバッファポインタ
;	    BPNTSG : データバッファセグメント
;	    BCNTMX : データ最大長さ

OFSUNPLS	PROC	NEAR
	CMP	FLAGPUTVIEW,1		; ＰＵＴＶＩＥＷフラグ
	JE	OFSUNPLS_1		;
	MOV	VRPX,0			; x point.
	MOV	VRPY,0			; y point.
	MOVX	VRLENPX,VRLENX		; x length.
	MOVX	VRLENPY,VRLENY		; y length.
OFSUNPLS_1:

	CALL	LDPLSD			; 圧縮フォーマットデータ復元
	CALL	CALCTOPPARA		; 各パラメータ計算
	CMP	PLSMDE,1		; 圧縮モード(0:通常,1:縦方向)
	JE	OFSUNPLS_PUT		;
	CALL	VRMPUT			; 高速ＶＲＡＭ－ＰＵＴ
	RET				;
OFSUNPLS_PUT:
	CMP	BBOVLP,0		; パターンＰＵＴオーバラップフラグ
	JNE	OFSUNPLS_PUT_OL		;
	CALL	VCXRTW			; ＶＲＡＭ－ＰＵＴ
	RET
OFSUNPLS_PUT_OL:
	MOV	SI,OFSPLS		; pless/unpless offset.
	MOV	AX,SEGPLS		; pless/unpless segment.
	PUSH	DS			;
	MOV	DS,AX			;
	CALL	VCXRTW_OL		; オーバラップＰＵＴ
	POP	DS			;
	RET
OFSUNPLS	ENDP


;	データ復元ＯＲ処理
;	-I- VRX    : ＰＵＴ Ｘ座標
;	    VRY    : ＰＵＴ Ｙ座標
;	    VRLENX : Ｘ方向長さ
;	    VRLENY : Ｙ方向長さ
;	    BPNTOF : データバッファポインタ
;	    BPNTSG : データバッファセグメント
;	    BCNTMX : データ最大長さ

OFSUNPOR	PROC	NEAR
	CMP	FLAGPUTVIEW,1		; ＰＵＴＶＩＥＷフラグ
	JE	OFSUNPOR_1		;
	MOV	VRPX,0			; x point.
	MOV	VRPY,0			; y point.
	MOVX	VRLENPX,VRLENX		; x length.
	MOVX	VRLENPY,VRLENY		; y length.
OFSUNPOR_1:
	CALL	LDPLSD			; 圧縮フォーマットデータ復元
	CALL	CALCTOPPARA		; 各パラメータ計算
	CALL	VCXRTW_OR		; ＶＲＡＭ－ＯＲ
	RET
OFSUNPOR	ENDP


;	データ復元ＯＲ処理単プレーンパターン
;	-I- VRX    : ＰＵＴ Ｘ座標
;	    VRY    : ＰＵＴ Ｙ座標
;	    VRLENX : Ｘ方向長さ
;	    VRLENY : Ｙ方向長さ
;	    BPNTOF : データバッファポインタ
;	    BPNTSG : データバッファセグメント
;	    BCNTMX : データ最大長さ

OFSUNPORS	PROC	NEAR
	CMP	FLAGPUTVIEW,1		; ＰＵＴＶＩＥＷフラグ
	JE	OFSUNPORS_1		;
	MOV	VRPX,0			; x point.
	MOV	VRPY,0			; y point.
	MOVX	VRLENPX,VRLENX		; x length.
	MOVX	VRLENPY,VRLENY		; y length.
OFSUNPORS_1:
	CALL	LDPLSD			; 圧縮フォーマットデータ復元
	CALL	CALCTOPPARA		; 各パラメータ計算
	CALL	VCXRTW_ORS		; ＶＲＡＭ－ＯＲ 単プレーンパターン
	RET
OFSUNPORS	ENDP


;	マスク化
;	-I- VRX    : ＰＵＴ Ｘ座標
;	    VRY    : ＰＵＴ Ｙ座標
;	    VRLENX : Ｘ方向長さ
;	    VRLENY : Ｙ方向長さ
;	    BPNTOF : データバッファポインタ
;	    BPNTSG : データバッファセグメント
;	    BCNTMX : データ最大長さ

OFSUNPLSM	PROC	NEAR
	CMP	FLAGPUTVIEW,1		; ＰＵＴＶＩＥＷフラグ
	JE	OFSUNPLSM_1		;
	MOV	VRPX,0			; x point.
	MOV	VRPY,0			; y point.
	MOVX	VRLENPX,VRLENX		; x length.
	MOVX	VRLENPY,VRLENY		; y length.
OFSUNPLSM_1:
	CALL	LDPLSD			; 圧縮フォーマットデータ復元
	CALL	CALCTOPPARA		; 各パラメータ計算
	CALL	VCXRTW_MASK		; ＶＲＡＭ－ＭＡＳＫ
	RET
OFSUNPLSM	ENDP


;	各パラメータ計算（縦圧縮）
;	-I- VRPX   : ＧＥＴ Ｘ座標
;	    VRPY   : ＧＥＴ Ｙ座標
;	    VRLENPY: ＧＥＴ Ｙサイズ
;	    VRLENX : Ｘ方向長さ
;	    VRLENY : Ｙ方向長さ
;	    VRX    : ＰＵＴ Ｘ座標
;	    VRY    : ＰＵＴ Ｙ座標
;	    SSGRW  : vram width.
;	-O- BUFFSRTOFS : buffer start offset.
;	    VRAMSRTOFS : vram start offset.
;	    NEXTPLNOFS : next plean offset.
;	    NXTLINOFS  : next line offset.

CALCTOPPARA	PROC	NEAR
	MOV	AX,VRPX			; ＧＥＴ Ｘ座標
	MOV	BX,VRLENY		; ×Ｙ方向長さ
	MUL	BX			;
	ADD	AX,VRPY			; ＧＥＴ Ｙ座標
	MOV	BUFFSRTOFS,AX		; buffer start offset.

	MOV	AX,VRY			; ＰＵＴ Ｙ座標
	MOV	BX,SSGRW		; × vram width.
	MUL	BX			;
	ADD	AX,VRX			; ＋ＰＵＴ Ｘ座標
	MOV	VRAMSRTOFS,AX		; vram start offset.

	MOV	AX,VRLENX		; Ｘ方向長さ
	MOV	BX,VRLENY		; ×Ｙ方向長さ
	MUL	BX			;
	MOV	NEXTPLNOFS,AX		; next plean offset.

	MOV	AX,VRLENY		; Ｙ方向長さ
	SUB	AX,VRLENPY		; －ＧＥＴ Ｙサイズ
	MOV	NXTLINOFS,AX		; next line offset.
	RET
CALCTOPPARA	ENDP


;	高速ＶＲＡＭ－ＰＵＴ
;	-I- VRAMSRTOFS: vram start offset.
;	    NEXTPLNOFS: next plean offset.
;	    VRLENX    : Ｘ方向長さ
;	    VRLENY    : Ｙ方向長さ
;	    SSGRW     : vram width.
;	    SEGPLS    : pless/unpless segment.
;	    OFSPLS    : pless/unpless offset.

VRMPUT	PROC	NEAR
	MOV	DX,SEGPLS	; pless/unpless segment.
	MOV	SI,OFSPLS	; pless/unpless offset.

	TEST	PRSSKP,0001B	; パーツＰＵＴのスキッププレーン
	JNZ	VRMPUT_1	;
	MOV	ES,SSGR0	; visual data segment plean 0
	CALL	PLNSET		; 高速１プレーンＰＵＴ
VRMPUT_1:

	ADD	SI,NEXTPLNOFS	; next plean offset.

	TEST	PRSSKP,0010B	; パーツＰＵＴのスキッププレーン
	JNZ	VRMPUT_2	;
	MOV	ES,SSGR1	; visual data segment plean 1
	CALL	PLNSET		; 高速１プレーンＰＵＴ
VRMPUT_2:

	ADD	SI,NEXTPLNOFS	; next plean offset.

	TEST	PRSSKP,0100B	; パーツＰＵＴのスキッププレーン
	JNZ	VRMPUT_3	;
	MOV	ES,SSGR2	; visual data segment plean 2
	CALL	PLNSET		; 高速１プレーンＰＵＴ
VRMPUT_3:

	ADD	SI,NEXTPLNOFS	; next plean offset.

	TEST	PRSSKP,1000B	; パーツＰＵＴのスキッププレーン
	JNZ	VRMPUT_4	;
	MOV	ES,SSGR3	; visual data segment plean 3
	CALL	PLNSET		; 高速１プレーンＰＵＴ
VRMPUT_4:

	RET
VRMPUT	ENDP



;	ＶＲＡＭ－ＰＵＴ
;	-I- BUFFSRTOFS: buffer start offset.
;	    VRAMSRTOFS: vram start offset.
;	    NEXTPLNOFS: next plean offset.
;	    VRLENPX   : ＧＥＴ Ｘサイズ
;	    VRLENPY   : ＧＥＴ Ｙサイズ
;	    SSGRW     : vram width.
;	    SEGPLS    : pless/unpless segment.
;	    OFSPLS    : pless/unpless offset.
;	    NXTLINOFS : next line offset.

VCXRTW	PROC	NEAR
	MOV	DX,SEGPLS	; pless/unpless segment.
	MOV	SI,OFSPLS	; pless/unpless offset.

	TEST	PRSSKP,0001B	; パーツＰＵＴのスキッププレーン
	JNZ	VCXRTW_1	;
	MOV	ES,SSGR0	; visual data segment plean 0
	CALL	MTXVRF		; 範囲指定１プレーン
VCXRTW_1:

	ADD	SI,NEXTPLNOFS	; next plean offset.

	TEST	PRSSKP,0010B	; パーツＰＵＴのスキッププレーン
	JNZ	VCXRTW_2	;
	MOV	ES,SSGR1	; visual data segment plean 1
	CALL	MTXVRF		; 範囲指定１プレーン
VCXRTW_2:

	ADD	SI,NEXTPLNOFS	; next plean offset.

	TEST	PRSSKP,0100B	; パーツＰＵＴのスキッププレーン
	JNZ	VCXRTW_3	;
	MOV	ES,SSGR2	; visual data segment plean 2
	CALL	MTXVRF		; 範囲指定１プレーン
VCXRTW_3:

	ADD	SI,NEXTPLNOFS	; next plean offset.

	TEST	PRSSKP,1000B	; パーツＰＵＴのスキッププレーン
	JNZ	VCXRTW_4	;
	MOV	ES,SSGR3	; visual data segment plean 3
	CALL	MTXVRF		; 範囲指定１プレーン
VCXRTW_4:

	RET
VCXRTW	ENDP


;	ＶＲＡＭ－ＯＲ
;	-I- BUFFSRTOFS: buffer start offset.
;	    VRAMSRTOFS: vram start offset.
;	    NEXTPLNOFS: next plean offset.
;	    VRLENPX   : ＧＥＴ Ｘサイズ
;	    VRLENPY   : ＧＥＴ Ｙサイズ
;	    SSGRW     : vram width.
;	    SEGPLS    : pless/unpless segment.
;	    OFSPLS    : pless/unpless offset.
;	    NXTLINOFS : next line offset.

VCXRTW_OR	PROC	NEAR
	MOV	DX,SSGR0	; visual data segment plean 0
	CALL	C1VV_BANK_CHK	; vram bank check. DX
	CMP	AX,1		; 0=normal,1=video memory.
	JE	VCXRTW_OR_GR	;

	MOV	DX,SEGPLS	; pless/unpless segment.
	MOV	SI,OFSPLS	; pless/unpless offset.

	TEST	BORRCL,0001B	; ＯＲカラー
	JZ	VCXRTW_OR_1	;
	MOV	ES,SSGR0	; visual data segment plean 0
	CALL	MTXVRF_OR	; 範囲指定１プレーンＯＲ
VCXRTW_OR_1:

	ADD	SI,NEXTPLNOFS	; next plean offset.

	TEST	BORRCL,0010B	; ＯＲカラー
	JZ	VCXRTW_OR_2	;
	MOV	ES,SSGR1	; visual data segment plean 1
	CALL	MTXVRF_OR	; 範囲指定１プレーンＯＲ
VCXRTW_OR_2:

	ADD	SI,NEXTPLNOFS	; next plean offset.

	TEST	BORRCL,0100B	; ＯＲカラー
	JZ	VCXRTW_OR_3	;
	MOV	ES,SSGR2	; visual data segment plean 2
	CALL	MTXVRF_OR	; 範囲指定１プレーンＯＲ
VCXRTW_OR_3:

	ADD	SI,NEXTPLNOFS	; next plean offset.

	TEST	BORRCL,1000B	; ＯＲカラー
	JZ	VCXRTW_OR_4	;
	MOV	ES,SSGR3	; visual data segment plean 3
	CALL	MTXVRF_OR	; 範囲指定１プレーンＯＲ
VCXRTW_OR_4:
	JMP	VCXRTW_OR_EXIT

VCXRTW_OR_GR:
	MOV	DX,SEGPLS	; pless/unpless segment.
	MOV	SI,OFSPLS	; pless/unpless offset.

	TEST	BORRCL,0001B	; ＯＲカラー
	JZ	VCXRTW_OR_G1	;
	MOV	ES,SSGR0	; visual data segment plean 0
	CALL	MTXVRF_OR_1GR	; 範囲指定ビデオメモリー用１プレーンＯＲ
VCXRTW_OR_G1:

	ADD	SI,NEXTPLNOFS	; next plean offset.

	TEST	BORRCL,0010B	; ＯＲカラー
	JZ	VCXRTW_OR_G2	;
	MOV	ES,SSGR1	; visual data segment plean 1
	CALL	MTXVRF_OR_1GR	; 範囲指定ビデオメモリー用１プレーンＯＲ
VCXRTW_OR_G2:

	ADD	SI,NEXTPLNOFS	; next plean offset.

	TEST	BORRCL,0100B	; ＯＲカラー
	JZ	VCXRTW_OR_G3	;
	MOV	ES,SSGR2	; visual data segment plean 2
	CALL	MTXVRF_OR_1GR	; 範囲指定ビデオメモリー用１プレーンＯＲ
VCXRTW_OR_G3:

	ADD	SI,NEXTPLNOFS	; next plean offset.

	TEST	BORRCL,1000B	; ＯＲカラー
	JZ	VCXRTW_OR_G4	;
	MOV	ES,SSGR3	; visual data segment plean 3
	CALL	MTXVRF_OR_1GR	; 範囲指定ビデオメモリー用１プレーンＯＲ
VCXRTW_OR_G4:

	JMP	VCXRTW_OR_EXIT

VCXRTW_OR_EXIT:
	RET
VCXRTW_OR	ENDP


;	ＶＲＡＭ－ＯＲ 単プレーンパターン
;	-I- BUFFSRTOFS: buffer start offset.
;	    VRAMSRTOFS: vram start offset.
;	    VRLENPX   : ＧＥＴ Ｘサイズ
;	    VRLENPY   : ＧＥＴ Ｙサイズ
;	    SSGRW     : vram width.
;	    SEGPLS    : pless/unpless segment.
;	    OFSPLS    : pless/unpless offset.
;	    NXTLINOFS : next line offset.

VCXRTW_ORS	PROC	NEAR
	MOV	DX,SSGR0	; visual data segment plean 0
	CALL	C1VV_BANK_CHK	; vram bank check. DX
	CMP	AX,0		; 0=normal,1=video memory.
	JE	VRMPUT_ORS_RAM	;
	MOV	ES,DX		; visual data segment plean 0

	MOV	DX,SEGPLS	; pless/unpless segment.
	MOV	SI,OFSPLS	; pless/unpless offset.
	CALL	MTXVRF_OR_GR	; 範囲指定ビデオメモリー用多プレーン同時ＯＲ
	JMP	VCXRTW_ORS_EXIT

VRMPUT_ORS_RAM:
	MOV	DX,SEGPLS	; pless/unpless segment.
	MOV	SI,OFSPLS	; pless/unpless offset.

	TEST	BORRCL,0001B	; ＯＲカラー
	JZ	VCXRTW_ORS_1	;
	MOV	ES,SSGR0	; visual data segment plean 0
	CALL	MTXVRF_OR	; 範囲指定１プレーンＯＲ
VCXRTW_ORS_1:

	TEST	BORRCL,0010B	; ＯＲカラー
	JZ	VCXRTW_ORS_2	;
	MOV	ES,SSGR1	; visual data segment plean 1
	CALL	MTXVRF_OR	; 範囲指定１プレーンＯＲ
VCXRTW_ORS_2:

	TEST	BORRCL,0100B	; ＯＲカラー
	JZ	VCXRTW_ORS_3	;
	MOV	ES,SSGR2	; visual data segment plean 2
	CALL	MTXVRF_OR	; 範囲指定１プレーンＯＲ
VCXRTW_ORS_3:

	TEST	BORRCL,1000B	; ＯＲカラー
	JZ	VCXRTW_ORS_4	;
	MOV	ES,SSGR3	; visual data segment plean 3
	CALL	MTXVRF_OR	; 範囲指定１プレーンＯＲ
VCXRTW_ORS_4:

VCXRTW_ORS_EXIT:
	RET
VCXRTW_ORS	ENDP


;	ＶＲＡＭ－ＭＡＳＫ
;	-I- BUFFSRTOFS: buffer start offset.
;	    VRAMSRTOFS: vram start offset.
;	    NEXTPLNOFS: next plean offset.
;	    VRLENPX   : ＧＥＴ Ｘサイズ
;	    VRLENPY   : ＧＥＴ Ｙサイズ
;	    SSGRW     : vram width.
;	    SEGPLS    : pless/unpless segment.
;	    OFSPLS    : pless/unpless offset.
;	    NXTLINOFS : next line offset.

VCXRTW_MASK	PROC	NEAR
	MOV	DX,SSGR0	; visual data segment plean 0
	CALL	C1VV_BANK_CHK	; vram bank check. DX
	CMP	AX,0		; 0=normal,1=video memory.
	JE	VRMPUT_MASK_RAM	;
	MOV	ES,DX		; visual data segment plean 0

	MOV	DX,SEGPLS	; pless/unpless segment.
	MOV	SI,OFSPLS	; pless/unpless offset.
	CALL	MTXVRF_AND_GR	; 範囲指定ビデオメモリー用多プレーン同時ＡＮＤ
	JMP	VCXRTW_MASK_EXIT

VRMPUT_MASK_RAM:
	MOV	DX,SEGPLS	; pless/unpless segment.
	MOV	SI,OFSPLS	; pless/unpless offset.
VRMPUT_MASK_01:
	TEST	BMSKCL,0001B	; マスキングカラー
	JZ	VCXRTW_MASK_1	;
	MOV	ES,SSGR0	; visual data segment plean 0
	CALL	MTXVRF_AND	; 範囲指定１プレーンＡＮＤ
VCXRTW_MASK_1:

	TEST	BMSKCL,0010B	; マスキングカラー
	JZ	VCXRTW_MASK_2	;
	MOV	ES,SSGR1	; visual data segment plean 1
	CALL	MTXVRF_AND	; 範囲指定１プレーンＡＮＤ
VCXRTW_MASK_2:

	TEST	BMSKCL,0100B	; マスキングカラー
	JZ	VCXRTW_MASK_3	;
	MOV	ES,SSGR2	; visual data segment plean 2
	CALL	MTXVRF_AND	; 範囲指定１プレーンＡＮＤ
VCXRTW_MASK_3:

	TEST	BMSKCL,1000B	; マスキングカラー
	JZ	VCXRTW_MASK_4	;
	MOV	ES,SSGR3	; visual data segment plean 3
	CALL	MTXVRF_AND	; 範囲指定１プレーンＡＮＤ
VCXRTW_MASK_4:

VCXRTW_MASK_EXIT:
	RET
VCXRTW_MASK	ENDP


;	高速１プレーンＰＵＴ
;	-I- ES        : ＶＲＡＭプレーンセグメント
;	    VRAMSRTOFS: vram start offset.
;	    VRLENX    : Ｘ方向長さ
;	    VRLENY    : Ｙ方向長さ
;	    SSGRW     : vram width.
;	    DX        : データバッファセグメント
;	    SI        : データバッファポインタ

PLNSET	PROC	NEAR
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES
	PUSH	DS
	PUSH	DX
	PUSH	SI

	MOV	DI,VRAMSRTOFS		; vram start offset.
	MOV	AX,VRLENX		; Ｘ方向長さ
	MOV	BX,VRLENY		; Ｙ方向長さ
	MOV	BP,SSGRW		; vram width.

	MOV	DS,DX			; データバッファセグメント

	MOV	DX,DI			; ＶＲＡＭプレーンオフセット
PLNSET_2:
	MOV	CX,AX			; Ｙ長さ
	REP	MOVSB			;

	ADD	DX,BP			;
	MOV	DI,DX			; ＶＲＡＭ転送の先頭オフセット

	DEC	BX			; X length.=AX
	JNZ	PLNSET_2		;

	POP	SI
	POP	DX
	POP	DS
	RET
PLNSET	ENDP


;	範囲指定１プレーン
;	-I- ES        : ＶＲＡＭプレーンセグメント
;	    BUFFSRTOFS: buffer start offset.
;	    VRAMSRTOFS: vram start offset.
;	    VRLENPX   : ＧＥＴ Ｘサイズ
;	    VRLENPY   : ＧＥＴ Ｙサイズ
;	    SSGRW     : vram width.
;	    NXTLINOFS : next line offset.
;	    DX        : データバッファセグメント
;	    SI        : データバッファポインタ

MTXVRF	PROC	NEAR
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES
	PUSH	DS
	PUSH	DX
	PUSH	SI

	ADD	SI,BUFFSRTOFS		; buffer start offset.
	MOV	DI,VRAMSRTOFS		; vram start offset.
	MOV	AX,VRLENPX		; ＧＥＴ Ｘサイズ
	MOV	BX,VRLENPY		; ＧＥＴ Ｙサイズ
	MOV	BP,SSGRW		; vram width.
	DEC	BP			; -1

	PUSH	NXTLINOFS		; next line offset.

	MOV	DS,DX			; データバッファセグメント

	MOV	DX,DI			; ＶＲＡＭプレーンオフセット
MTXVRF2:
	MOV	CX,BX			; Ｙ長さ
MTXVRF3:
	MOVSB				;
	ADD	DI,BP			; ＶＲＡＭライン計算用
	LOOP	MTXVRF3			;

	POP	CX			;
	ADD	SI,CX			; + next line offset.
	PUSH	CX			;

	INC	DX			;
	MOV	DI,DX			; ＶＲＡＭ転送の先頭オフセット

	DEC	AX			; X length.=AX
	JNZ	MTXVRF2			;

	POP	SI
	POP	SI
	POP	DX
	POP	DS
	RET
MTXVRF	ENDP


;	範囲指定１プレーンＯＲ
;	-I- ES        : ＶＲＡＭプレーンセグメント
;	    BUFFSRTOFS: buffer start offset.
;	    VRAMSRTOFS: vram start offset.
;	    VRLENPX   : ＧＥＴ Ｘサイズ
;	    VRLENPY   : ＧＥＴ Ｙサイズ
;	    SSGRW     : vram width.
;	    NXTLINOFS : next line offset.
;	    DX        : データバッファセグメント
;	    SI        : データバッファポインタ

MTXVRF_OR	PROC	NEAR
	PUSH	DS
	PUSH	DX
	PUSH	SI

	ADD	SI,BUFFSRTOFS		; buffer start offset.
	MOV	DI,VRAMSRTOFS		; vram start offset.
	MOV	AX,VRLENPX		; ＧＥＴ Ｘサイズ
	MOV	BX,VRLENPY		; ＧＥＴ Ｙサイズ
	MOV	BP,SSGRW		; vram width.

	PUSH	NXTLINOFS		; next line offset.

	MOV	DS,DX			; データバッファセグメント

	MOV	DX,DI			; ＶＲＡＭプレーンオフセット
MTXVRF_OR_2:
	MOV	CX,BX			; Ｙ長さ
	PUSH	AX			;
MTXVRF_OR_3:				;
	LODSB				;
	OR	ES:[DI],AL		; OR.
	ADD	DI,BP			; ＶＲＡＭライン計算用
	LOOP	MTXVRF_OR_3		;
	POP	AX			;

	POP	CX			;
	ADD	SI,CX			; + next line offset.
	PUSH	CX			;

	INC	DX			;
	MOV	DI,DX			; ＶＲＡＭ転送の先頭オフセット

	DEC	AX			; X length.=AX
	JNZ	MTXVRF_OR_2		;

	POP	SI
	POP	SI
	POP	DX
	POP	DS
	RET
MTXVRF_OR	ENDP


;	範囲指定ビデオメモリー用１プレーンＯＲ
;	-I- ES        : ＶＲＡＭプレーンセグメント
;	    BUFFSRTOFS: buffer start offset.
;	    VRAMSRTOFS: vram start offset.
;	    VRLENPX   : ＧＥＴ Ｘサイズ
;	    VRLENPY   : ＧＥＴ Ｙサイズ
;	    SSGRW     : vram width.
;	    NXTLINOFS : next line offset.
;	    BMSKCL    :マスキングカラー(bit3:plean3,bit2:2,bit1:1,bit0:0)
;	    DX        : データバッファセグメント
;	    SI        : データバッファポインタ

MTXVRF_OR_1GR	PROC	NEAR
	CALL	C1VV_BANK_CHG_ES	; vram bank check & chenge.(WRITE) ES
	CALL	C1VV_MODE_OR		; vram put mode OR.
	PUSH	DS
	PUSH	DX
	PUSH	SI

	ADD	SI,BUFFSRTOFS		; buffer start offset.
	MOV	DI,VRAMSRTOFS		; vram start offset.
	MOV	AX,VRLENPX		; ＧＥＴ Ｘサイズ
	MOV	BX,VRLENPY		; ＧＥＴ Ｙサイズ
	MOV	BP,SSGRW		; vram width.
	DEC	BP			; -1

	PUSH	NXTLINOFS		; next line offset.

	MOV	DS,DX			; データバッファセグメント

	MOV	DX,DI			; ＶＲＡＭプレーンオフセット
MTXVRF_OR_1GR_2:
	MOV	CX,BX			; Ｙ長さ
	PUSH	AX			;
MTXVRF_OR_1GR_3:			;
	MOV	AL,ES:[DI]		; rach.
	MOVSB				; OR.
	ADD	DI,BP			; ＶＲＡＭライン計算用
	LOOP	MTXVRF_OR_1GR_3		;
	POP	AX			;

	POP	CX			;
	ADD	SI,CX			; + next line offset.
	PUSH	CX			;

	INC	DX			;
	MOV	DI,DX			; ＶＲＡＭ転送の先頭オフセット

	DEC	AX			; X length.=AX
	JNZ	MTXVRF_OR_1GR_2		;

	POP	SI
	POP	SI
	POP	DX
	POP	DS
	CALL	C1VV_MODE_PSET		; vram put mode PSET.
	RET
MTXVRF_OR_1GR	ENDP


;	範囲指定ビデオメモリー用多プレーン同時ＯＲ
;	-I- ES        : ＶＲＡＭプレーンセグメント
;	    BUFFSRTOFS: buffer start offset.
;	    VRAMSRTOFS: vram start offset.
;	    VRLENPX   : ＧＥＴ Ｘサイズ
;	    VRLENPY   : ＧＥＴ Ｙサイズ
;	    SSGRW     : vram width.
;	    NXTLINOFS : next line offset.
;	    BMSKCL    :マスキングカラー(bit3:plean3,bit2:2,bit1:1,bit0:0)
;	    DX        : データバッファセグメント
;	    SI        : データバッファポインタ

MTXVRF_OR_GR	PROC	NEAR
	CALL	C1VV_MODE_OR		; vram put mode OR.
	PUSH	DX
	MOV	DX,BMSKCL		; マスキングカラー
	CALL	C1VV_PLEAN_SLCT		; plean select.
	POP	DX

	PUSH	DS
	PUSH	DX
	PUSH	SI

	ADD	SI,BUFFSRTOFS		; buffer start offset.
	MOV	DI,VRAMSRTOFS		; vram start offset.
	MOV	AX,VRLENPX		; ＧＥＴ Ｘサイズ
	MOV	BX,VRLENPY		; ＧＥＴ Ｙサイズ
	MOV	BP,SSGRW		; vram width.
	DEC	BP			; -1

	PUSH	NXTLINOFS		; next line offset.

	MOV	DS,DX			; データバッファセグメント

	MOV	DX,DI			; ＶＲＡＭプレーンオフセット
MTXVRF_OR_GR_2:
	MOV	CX,BX			; Ｙ長さ
	PUSH	AX			;
MTXVRF_OR_GR_3:				;
	MOV	AL,ES:[DI]		; rach.
	MOVSB				; OR.
	ADD	DI,BP			; ＶＲＡＭライン計算用
	LOOP	MTXVRF_OR_GR_3		;
	POP	AX			;

	POP	CX			;
	ADD	SI,CX			; + next line offset.
	PUSH	CX			;

	INC	DX			;
	MOV	DI,DX			; ＶＲＡＭ転送の先頭オフセット

	DEC	AX			; X length.=AX
	JNZ	MTXVRF_OR_GR_2		;

	POP	SI
	POP	SI
	POP	DX
	POP	DS
	CALL	C1VV_MODE_PSET		; vram put mode PSET.
	RET
MTXVRF_OR_GR	ENDP


;	範囲指定１プレーンＡＮＤ
;	-I- ES        : ＶＲＡＭプレーンセグメント
;	    BUFFSRTOFS: buffer start offset.
;	    VRAMSRTOFS: vram start offset.
;	    VRLENPX   : ＧＥＴ Ｘサイズ
;	    VRLENPY   : ＧＥＴ Ｙサイズ
;	    SSGRW     : vram width.
;	    NXTLINOFS : next line offset.
;	    DX        : データバッファセグメント
;	    SI        : データバッファポインタ

MTXVRF_AND	PROC	NEAR
	PUSH	DS
	PUSH	DX
	PUSH	SI

	ADD	SI,BUFFSRTOFS		; buffer start offset.
	MOV	DI,VRAMSRTOFS		; vram start offset.
	MOV	AX,VRLENPX		; ＧＥＴ Ｘサイズ
	MOV	BX,VRLENPY		; ＧＥＴ Ｙサイズ
	MOV	BP,SSGRW		; vram width.

	PUSH	NXTLINOFS		; next line offset.

	MOV	DS,DX			; データバッファセグメント

	MOV	DX,DI			; ＶＲＡＭプレーンオフセット
MTXVRF_AND_2:
	MOV	CX,BX			; Ｙ長さ
	PUSH	AX			;
MTXVRF_AND_3:				;
	LODSB				;
	AND	ES:[DI],AL		; AND.
	ADD	DI,BP			; ＶＲＡＭライン計算用
	LOOP	MTXVRF_AND_3		;
	POP	AX			;

	POP	CX			;
	ADD	SI,CX			; + next line offset.
	PUSH	CX			;

	INC	DX			;
	MOV	DI,DX			; ＶＲＡＭ転送の先頭オフセット

	DEC	AX			; X length.=AX
	JNZ	MTXVRF_AND_2		;

	POP	SI
	POP	SI
	POP	DX
	POP	DS
	RET
MTXVRF_AND	ENDP


;	範囲指定ビデオメモリー用多プレーン同時ＡＮＤ
;	-I- ES        : ＶＲＡＭプレーンセグメント
;	    BUFFSRTOFS: buffer start offset.
;	    VRAMSRTOFS: vram start offset.
;	    VRLENPX   : ＧＥＴ Ｘサイズ
;	    VRLENPY   : ＧＥＴ Ｙサイズ
;	    SSGRW     : vram width.
;	    NXTLINOFS : next line offset.
;	    BMSKCL    :マスキングカラー(bit3:plean3,bit2:2,bit1:1,bit0:0)
;	    DX        : データバッファセグメント
;	    SI        : データバッファポインタ

MTXVRF_AND_GR	PROC	NEAR
	CALL	C1VV_MODE_AND		; vram put mode AND.
	PUSH	DX
	MOV	DX,BMSKCL		; マスキングカラー
	CALL	C1VV_PLEAN_SLCT		; plean select.
	POP	DX

	PUSH	DS
	PUSH	DX
	PUSH	SI

	ADD	SI,BUFFSRTOFS		; buffer start offset.
	MOV	DI,VRAMSRTOFS		; vram start offset.
	MOV	AX,VRLENPX		; ＧＥＴ Ｘサイズ
	MOV	BX,VRLENPY		; ＧＥＴ Ｙサイズ
	MOV	BP,SSGRW		; vram width.
	DEC	BP			; -1

	PUSH	NXTLINOFS		; next line offset.

	MOV	DS,DX			; データバッファセグメント

	MOV	DX,DI			; ＶＲＡＭプレーンオフセット
MTXVRF_AND_GR_2:
	MOV	CX,BX			; Ｙ長さ
	PUSH	AX			;
MTXVRF_AND_GR_3:			;
	MOV	AL,ES:[DI]		; rach.
	MOVSB				; AND.
	ADD	DI,BP			; ＶＲＡＭライン計算用
	LOOP	MTXVRF_AND_GR_3		;
	POP	AX			;

	POP	CX			;
	ADD	SI,CX			; + next line offset.
	PUSH	CX			;

	INC	DX			;
	MOV	DI,DX			; ＶＲＡＭ転送の先頭オフセット

	DEC	AX			; X length.=AX
	JNZ	MTXVRF_AND_GR_2		;

	POP	SI
	POP	SI
	POP	DX
	POP	DS
	CALL	C1VV_MODE_PSET		; vram put mode PSET.
	RET
MTXVRF_AND_GR	ENDP


;	圧縮フォーマットデータ復元
;	-I- BPNTOF     : データバッファポインタ
;	    BPNTSG     : データバッファセグメント
;	-O- SEGPLS:OFSPLS : pless/unpless segment.

LDPLSD	PROC	NEAR
	PUSH	DS

	MOV	DI,OFSPLS	; pless/unpless offset.
	MOV	AX,SEGPLS	; pless/unpless segment.
	MOV	ES,AX		;

	CALL	C1BUNPLE	; 圧縮フォーマットデータ復元

	POP	DS
	RET
LDPLSD	ENDP


CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	SEGPLS:WORD			; pless/unpless segment.
EXTRN	OFSPLS:WORD			; pless/unpless offset.

EXTRN	SSGR0:WORD			; visual data segment plean 0
EXTRN	SSGR1:WORD			; visual data segment plean 1
EXTRN	SSGR2:WORD			; visual data segment plean 2
EXTRN	SSGR3:WORD			; visual data segment plean 3
EXTRN	SSGRW:WORD			; visual data plean width.

EXTRN	PLSMDE:WORD			; 圧縮モード(0:通常,1:縦方向)

EXTRN	BBOVTM:WORD			; パターンＰＵＴオーバラップタイム
EXTRN	BBOVLP:WORD			; パターンＰＵＴオーバラップフラグ

EXTRN	PRSSKP:WORD			; パーツＰＵＴのスキッププレーン
				; (bit3:plean3,bit2:plean2,bit1:1,bit0:0)
EXTRN	BORRCL:WORD			; ＯＲカラー
				; (bit3:plean3,bit2:plean2,bit1:1,bit0:0)
EXTRN	BMSKCL:WORD			; マスキングカラー
				; (bit3:plean3,bit2:plean2,bit1:1,bit0:0)

EXTRN	BUFFSRTOFS:WORD			; buffer start offset.
EXTRN	VRAMSRTOFS:WORD			; vram start offset.
EXTRN	NEXTPLNOFS:WORD			; next plean offset.
EXTRN	NXTLINOFS:WORD			; next line offset.

EXTRN	VRX:WORD			; x point.
EXTRN	VRY:WORD			; y point.
EXTRN	VRLENX:WORD			; x length.
EXTRN	VRLENY:WORD			; y length.

EXTRN	VRPX:WORD			; ＧＥＴ Ｘ座標
EXTRN	VRPY:WORD			; ＧＥＴ Ｙ座標
EXTRN	VRLENPX:WORD			; ＧＥＴ Ｘサイズ
EXTRN	VRLENPY:WORD			; ＧＥＴ Ｙサイズ

FLAGPUTVIEW	DW	0		; ＰＵＴＶＩＥＷフラグ

DATA	ENDS

	END
;
;	end of "PLSLD7.ASM"
;
