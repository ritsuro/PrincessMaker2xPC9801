; "PARTST.ASM" PC-9801UV11 make by R.H 1989/12/08
;	modify 1991/06/22 PS55Z/S14 (code01 gate call)
;
;
;	パーツデータＧＥＴ＆ＰＵＴ
;
;1991/12/04
;		PLSLD2.ASM/UNPLS  -> PLSLD7.ASM/OFSUNPLS
;		PLSLD3.ASM/UNPOR  -> PLSLD7.ASM/OFSUNPOR
;		PLSLD3.ASM/UNPORS -> PLSLD7.ASM/OFSUNPORS
;
;
;		SSGR0 : visual data segment plean 0
;		SSGR1 : visual data segment plean 1
;		SSGR2 : visual data segment plean 2
;		SSGR3 : visual data segment plean 3
;
;1991/02/06	マスクデータおよびＯＲのＰＵＴで縦圧縮が
;		扱えるようになりました。
;
;
;	高度なテクニックを使う場合
;
;
;	・マスクパーツのＰＵＴプレーンの設定
;		CALL C1PATMST(PARTT2.ASM) を呼び出して下さい
;
;	・ＯＲでＰＵＴするプレーンの設定
;		DS:BORRCL:WORD を設定して下さい
;		（詳細はPLSLD7.ASM/OFSUNPORを参照のこと）
;
;	・オーバラップは C1PATEFC（パーツＰＵＴエフェクト）を使用して下さい
;	例）	MOV	AX,1		; 1=パターンＰＵＴオーバラップ
;		CALL	C1PATEFC	; パーツＰＵＴエフェクト
;		（オーバラップは縦圧縮時／横圧縮時両方可能）
;		オーバラップ単位時間の変更はBBOVTM（オーバラップタイム）を変更
;
;	・C1PATOPE（オペレーションセット）の
;		単プレーンパターンのＯＲＰＵＴとはデータ中の先頭の１プレーン分
;		だけのデータを全プレーンへセットする機能です
;
;	・C1PATOPE（オペレーションセット）の
;		展開バッファ仮想ＶＲＡＭ化は
;		展開バッファをＶＲＡＭに再構成する機能です
;		仮想ＶＲＡＭ化されたＶＲＡＭのデータは以下の
;		変数に返されます
;
;		SSGRV0 : visual data segment plean 0
;		SSGRV1 : visual data segment plean 1
;		SSGRV2 : visual data segment plean 2
;		SSGRV3 : visual data segment plean 3
;		SSGRVW : visual data plean width.
;
;	・プレーン毎のスキップを行えるようにしました。これは縦／横圧縮モード
;	　(PLSMDE=0:通常,1:縦方向) オーバラップ時(BBOVLP)のいずれでも使えます。
;	例）	MOV	DX,1000B	; スキッププレーン (bit3:plean3...)
;		CALL	C1PLSSKP	; パーツＰＵＴのプレーンスキップ
;
;	・縦／横圧縮方向の切り替え
;	例）	MOV	DX,0			; 圧縮モード(0:通常,1:縦方向)
;		CALL	C1PLSMOD(PLSLD2.ASM)	; 圧縮モード切り替え
;
;	・ハンドル対応の為、ファイル名をピリオド挿入に変更
;		FLPNAM	DB	"        .PT1",0
;
;1992/04/15
;
;	旧データにバグ発見
;		属性のマスクとバイナリーが３でぶつかっていたので
;		本バージョンからなおすことにした。
;
;	属性
;		0=データ終わり
;		1=無圧縮データ
;		2=圧縮データ
;		3=マスクデータ
;		4=バイナリデータ
;
;1992/10/02
;
;	ＰＵＴＶＩＥＷの設定が設定出来るようになりました。
;	（現在はノーマルＰＵＴ時のみ）
;	CALL	C1PLSVIW	(PLSLD7.ASM); ＰＵＴＶＩＥＷの設定
;	-I- VRPX   : ＧＥＴ Ｘ座標
;	    VRPY   : ＧＥＴ Ｙ座標
;	    VRLENPX: ＧＥＴ Ｘサイズ
;	    VRLENPY: ＧＥＴ Ｙサイズ
;
;	CALL 	C1PLSVWS			; ＰＵＴＶＩＥＷの解除
;
;
; public subroutine.

INCLUDE	TSTSET.INC

MOVX	MACRO	DEST,SOU
	MOV	AX,SOU
	MOV	DEST,AX
	ENDM

BBERROR_FAR	MACRO	NUM
CODE	SEGMENT	PUBLIC	'CODE'
ASSUME	CS:CODE
EXTRN	FAR_BBERRORPR:FAR	; error message.
CODE	ENDS
DATA	SEGMENT	PUBLIC	'DATA'
EXTRN	FLAGERROR:WORD		; error flag.
DATA	ENDS
ASSUME	CS:CODE01
	MOV	FLAGERROR,NUM		; error flag.
	CALL	FAR_BBERRORPR		; error message.
	ENDM

;	パーツバッファのオフセット値

PARTS_OFST_ATR	EQU	0	; 属性(0=データ終わり,
				;      1=無圧縮データ,2=圧縮データ)
PARTS_OFST_X	EQU	2	; Ｘ座標
PARTS_OFST_Y	EQU	4	; Ｙ座標
PARTS_OFST_LNX	EQU	6	; Ｘ長さ
PARTS_OFST_LNY	EQU	8	; Ｙ長さ
PARTS_OFST_LEN	EQU	10	; データ長さ
PARTS_OFST_DAT	EQU	12	; データ開始オフセット

PATH_STRING_LEN	EQU	32	; path string length.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	C1PATINI		; パーツセット初期処理
PUBLIC	C1PATCLR		; パーツセットクリア
;*;PUBLIC C1PATGET		; パーツＧＥＴ
PUBLIC	C1PATGTA		; パーツＧＥＴ圧縮無し
PUBLIC	C1PATPUT		; パーツＰＵＴ
PUBLIC	C1PATPTX		; パーツＰＵＴ座標指定
PUBLIC	C1PATPTF		; パーツＰＵＴオフセット指定
;*;PUBLIC C1PATSAV		; パーツセーブ
PUBLIC	C1PATLOD		; パーツロード
PUBLIC	C1PATLDA		; パーツ追加ロード
PUBLIC	C1PATBNK		; バンクチェンジ
PUBLIC	C1PATOPE		; オペレーションセット(ｵﾍﾟﾚｰｼｮﾝ 0=normal,1=OR )
PUBLIC	C1PATEFC		; パーツＰＵＴエフェクト

;*;EXTRN C1PLESS:NEAR		; データ圧縮

EXTRN	OFSUNPLS:NEAR		; データ復元(範囲指定)
EXTRN	OFSUNPOR:NEAR		; データ復元ＯＲ処理
EXTRN	OFSUNPORS:NEAR		; データ復元ＯＲ処理単プレーンパターン

EXTRN	UNPVVR:NEAR		; データ復元・展開バッファ仮想ＶＲＡＭ化

EXTRN	VRMGT:NEAR		; ＶＲＡＭデータＧＥＴ
EXTRN	VRMPT:NEAR		; ＶＲＡＭデータＰＵＴ

EXTRN DISKLD:NEAR		; disk load.
;*;EXTRN DISKSV:NEAR		; disk save.


;	パーツセット初期処理

C1PATINI	PROC	NEAR
	MOV	DX,0			; バンク番号
	CALL	C1PATBNK		; バンクチェンジ
	CALL	C1PATCLR		; パーツセットクリア
	RET
C1PATINI	ENDP



;	パーツセットクリア

C1PATCLR	PROC	NEAR
	PUSH	ES

		; パーツバッファのカレントポインタ
	MOV	AX,PRSTOP		; バンクトップオフセット
	MOV	PRSOFS,AX		;

		; パーツバッファの使用サイズ
	MOV	PRSSIZ,0

	MOV	AX,PRSSEG		; バンクセグメント
	MOV	ES,AX			;

	;	属性(0=データ終わり,1=無圧縮データ,2=圧縮データ)

	MOV	DI,PRSOFS		;
	MOV	ES:[DI][PARTS_OFST_ATR],WORD PTR 0

	POP	ES
	RET
C1PATCLR	ENDP



;	パーツＧＥＴ圧縮無し
;	-I- VRX		: ＶＲＡＭ　Ｘ座標
;	    VRY		: ＶＲＡＭ　Ｙ座標
;	    VRLENX	: Ｘ方向長さ
;	    VRLENY	: Ｙ方向長さ
;	-O- AX		: 0=normal end, 1=error.
;	    BX    	: 格納データ番号

C1PATGTA	PROC	NEAR
	PUSH	CX

	MOV	CX,0FFFFH		;
	CALL	PARTSCH			; パーツデータの検索
	MOV	PRSOFS,DI		; パーツバッファのカレントポインタ
	SUB	DI,PRSTOP		; バンクトップオフセット
	MOV	PRSSIZ,DI		; パーツバッファの使用サイズ

	MOV	AX,PRSSEG		; バンクセグメント
	MOV	ES,AX			;

	MOV	DI,PRSOFS ; パーツバッファのカレントポインタ

	MOV	AX,VRX				; ＶＲＡＭ　Ｘ座標
	MOV	ES:[DI][PARTS_OFST_X],AX	; Ｘ座標
	MOV	AX,VRY				; ＶＲＡＭ　Ｙ座標
	MOV	ES:[DI][PARTS_OFST_Y],AX	; Ｙ座標
	MOV	AX,VRLENX			; Ｘ方向長さ
	MOV	ES:[DI][PARTS_OFST_LNX],AX	; Ｘ長さ
	MOV	AX,VRLENY			; Ｙ方向長さ
	MOV	ES:[DI][PARTS_OFST_LNY],AX	; Ｙ長さ

	MOV	BPNTOF,DI		; データバッファポインタ
	ADD	BPNTOF,PARTS_OFST_DAT	; データ開始オフセット
	MOV	AX,PRSSEG		; バンクセグメント
	MOV	BPNTSG,AX		;
	MOV	AX,PRSEND		; バンクエンドオフセット
	SUB	AX,BPNTOF		; データ開始オフセット
	MOV	BCNTMX,AX		; データ最大長さ

	PUSH	BX
	PUSH	DI
	PUSH	ES
	CALL	VRMGT			; ＶＲＡＭデータＧＥＴ
	POP	ES
	POP	DI
	POP	BX

	CMP	AH,1	; 0 or 2 : normal end. 1:write error.
	JE	PATGTA_ERROR

	MOV	AX,BCOUNT			; データ長さ
	MOV	ES:[DI][PARTS_OFST_LEN],AX	; データ長さ

	MOV	AX,BCOUNT		; データ長さ
	ADD	AX,PARTS_OFST_DAT	; データ開始オフセット
	ADD	PRSSIZ,AX	; パーツバッファの使用サイズ

	;	属性(0=データ終わり,1=無圧縮データ,2=圧縮データ)
	MOV	ES:[DI][PARTS_OFST_ATR],WORD PTR 1

	MOV	DI,BPOINT 		; データ終わりアドレス＋１
	MOV	ES:[DI][PARTS_OFST_ATR],WORD PTR 0

	MOV	PRSOFS,DI ; パーツバッファのカレントポインタ
PATGTA_EXIT:
	MOV	AX,0	; normal.
	POP	CX
	RET
PATGTA_ERROR:
	MOV	AX,1	; buffer full.
	POP	CX
	RET
C1PATGTA	ENDP


;*;;	パーツＧＥＴ
;*;;	-I- VRX		: ＶＲＡＭ　Ｘ座標
;*;;	    VRY		: ＶＲＡＭ　Ｙ座標
;*;;	    VRLENX	: Ｘ方向長さ
;*;;	    VRLENY	: Ｙ方向長さ
;*;;	-O- AX		: 0=normal end, 1=error.
;*;
;*;C1PATGET	PROC	NEAR
;*;	PUSH	CX
;*;
;*;	MOV	AX,PRSSEG		; バンクセグメント
;*;	MOV	ES,AX			;
;*;
;*;	MOV	DI,PRSOFS ; パーツバッファのカレントポインタ
;*;
;*;	;	データ圧縮
;*;	MOV	AX,VRX				; ＶＲＡＭ　Ｘ座標
;*;	MOV	ES:[DI][PARTS_OFST_X],AX	; Ｘ座標
;*;	MOV	AX,VRY				; ＶＲＡＭ　Ｙ座標
;*;	MOV	ES:[DI][PARTS_OFST_Y],AX	; Ｙ座標
;*;	MOV	AX,VRLENX			; Ｘ方向長さ
;*;	MOV	ES:[DI][PARTS_OFST_LNX],AX	; Ｘ長さ
;*;	MOV	AX,VRLENY			; Ｙ方向長さ
;*;	MOV	ES:[DI][PARTS_OFST_LNY],AX	; Ｙ長さ
;*;
;*;	MOV	BPNTOF,DI		; データバッファポインタ
;*;	ADD	BPNTOF,PARTS_OFST_DAT	; データ開始オフセット
;*;	MOV	AX,PRSSEG		; バンクセグメント
;*;	MOV	BPNTSG,AX		;
;*;	MOV	AX,PRSEND		; バンクエンドオフセット
;*;	SUB	AX,BPNTOF		; データ開始オフセット
;*;	MOV	BCNTMX,AX		; データ最大長さ
;*;
;*;	PUSH	DI
;*;	PUSH	ES
;*;	CALL	C1PLESS			; データ圧縮
;*;	POP	ES
;*;	POP	DI
;*;
;*;	CMP	AH,1	; 0 or 2 : normal end. 1:write error.
;*;	JE	PATGET_ERROR
;*;
;*;	MOV	AX,BCOUNT			; データ長さ
;*;	MOV	ES:[DI][PARTS_OFST_LEN],AX	; データ長さ
;*;
;*;	MOV	AX,BCOUNT		; データ長さ
;*;	ADD	AX,PARTS_OFST_DAT
;*;	ADD	PRSSIZ,AX	; パーツバッファの使用サイズ
;*;
;*;	;	属性(0=データ終わり,1=無圧縮データ,2=圧縮データ)
;*;	MOV	ES:[DI][PARTS_OFST_ATR],WORD PTR 2
;*;
;*;	MOV	DI,BPOINT 		; データ終わりアドレス＋１
;*;	MOV	ES:[DI][PARTS_OFST_ATR],WORD PTR 0
;*;
;*;	MOV	PRSOFS,DI ; パーツバッファのカレントポインタ
;*;PATGET_EXIT:
;*;	MOV	AX,0	; normal.
;*;	POP	CX
;*;	RET
;*;PATGET_ERROR:
;*;	MOV	AX,1	; buffer full.
;*;	POP	CX
;*;	RET
;*;C1PATGET	ENDP


;	パーツＰＵＴ
;	-I- CX : パーツ番号
;	-O- AX : 0=normal end, 1=error.

C1PATPUT	PROC	NEAR
	PUSH	CX

	CALL	PARTSCH				; パーツデータの検索
	CMP	AX,0				;
	JE	PATPUT1				;
	JMP	PATPUT_ERROR			;
PATPUT1:
	;	データ復元
	MOV	AX,ES:[DI][PARTS_OFST_X]	; Ｘ座標
	MOV	VRX,AX				; ＶＲＡＭ　Ｘ座標
	MOV	AX,ES:[DI][PARTS_OFST_Y]	; Ｙ座標
	MOV	VRY,AX				; ＶＲＡＭ　Ｙ座標
	MOV	AX,ES:[DI][PARTS_OFST_LNX]	; Ｘ長さ
	MOV	VRLENX,AX			; Ｘ方向長さ
	MOV	AX,ES:[DI][PARTS_OFST_LNY]	; Ｙ長さ
	MOV	VRLENY,AX			; Ｙ方向長さ

	MOV	BPNTOF,DI			; データバッファポインタ
	ADD	BPNTOF,PARTS_OFST_DAT		; データ開始オフセット

	MOV	AX,PRSSEG			; バンクセグメント
	MOV	BPNTSG,AX			;
	MOV	AX,ES:[DI][PARTS_OFST_LEN]	; データ長さ
	MOV	BCNTMX,AX			; データ最大長さ

	CMP	ES:[DI][PARTS_OFST_ATR],WORD PTR 1 ; 属性(0=データ終わり,
						; 1=無圧縮データ,2=圧縮データ)
	JNE	PATPUT5				;
	CALL	VRMPT				; ＶＲＡＭデータＰＵＴ
	JMP	PATPUT_EXIT			;
PATPUT5:
	CMP	ES:[DI][PARTS_OFST_ATR],WORD PTR 2 ; 属性(0=データ終わり,
						; 1=無圧縮データ,2=圧縮データ)
	JNE	PATPUT6				;

	CMP	PRSOPE,0			; ＰＵＴ時ｵﾍﾟﾚｰｼｮﾝ
	JNE	PATPUT55			; 0=normal

	CALL	OFSUNPLS			; データ復元(範囲指定)
;*;	CALL	UNPLS				; データ復元
	JMP	PATPUT_EXIT			;
PATPUT55:
	CMP	PRSOPE,1			; ＰＵＴ時ｵﾍﾟﾚｰｼｮﾝ
	JNE	PATPUT56			; 1=OR
	CALL	OFSUNPOR			; データ復元ＯＲ処理
	JMP	PATPUT_EXIT			;
PATPUT56:
	CMP	PRSOPE,2			; ＰＵＴ時ｵﾍﾟﾚｰｼｮﾝ
	JNE	PATPUT57			; 2=OR2
	CALL	OFSUNPORS		; データ復元ＯＲ処理単プレーンパターン
						; 単プレーンパターン
	JMP	PATPUT_EXIT			;
PATPUT57:
	CMP	PRSOPE,3			; ＰＵＴ時ｵﾍﾟﾚｰｼｮﾝ
	JNE	PATPUT6				; 3=vvram
	CALL	UNPVVR				; データ復元
						; 展開バッファ仮想ＶＲＡＭ化
	JMP	PATPUT_EXIT			;
PATPUT6:

PATPUT_EXIT:
	MOV	AX,0	; normal.
	POP	CX
	RET
PATPUT_ERROR:
	MOV	AX,1	; not found.
	POP	CX
	RET
C1PATPUT	ENDP



;	パーツＰＵＴ座標指定
;	-I- CX  : パーツ番号
;	    VRX	: ＶＲＡＭ　Ｘ座標
;	    VRY : ＶＲＡＭ　Ｙ座標
;	-O- AX  : 0=normal end, 1=error.

C1PATPTX	PROC	NEAR
	PUSH	CX

	CALL	PARTSCH		; パーツデータの検索
	CMP	AX,0		;
	JE	PATPTX1		;
	JMP	PATPTX_ERROR	;
PATPTX1:
	;	属性(0=データ終わり,1=無圧縮データ,2=圧縮データ)
	MOV	DX,ES:[DI][PARTS_OFST_ATR]
	CMP	DX,0
	JNE	PATPTX44
	JMP	PATPTX_ERROR			; end of data.
PATPTX44:
	;	データ復元
	MOV	AX,ES:[DI][PARTS_OFST_LNX]	; Ｘ長さ
	MOV	VRLENX,AX			; Ｘ方向長さ
	MOV	AX,ES:[DI][PARTS_OFST_LNY]	; Ｙ長さ
	MOV	VRLENY,AX			; Ｙ方向長さ

	MOV	BPNTOF,DI		; データバッファポインタ
	ADD	BPNTOF,PARTS_OFST_DAT	; データ開始オフセット
	MOV	AX,PRSSEG		; バンクセグメント
	MOV	BPNTSG,AX		;

	MOV	AX,ES:[DI][PARTS_OFST_LEN]	; データ長さ
	MOV	BCNTMX,AX			; データ最大長さ

	CMP	ES:[DI][PARTS_OFST_ATR],WORD PTR 1 ; 属性(0=データ終わり,
						; 1=無圧縮データ,2=圧縮データ)
	JNE	PATPTX5				;
	CALL	VRMPT				; ＶＲＡＭデータＰＵＴ
	JMP	PATPTX_EXIT			;
PATPTX5:
	CMP	ES:[DI][PARTS_OFST_ATR],WORD PTR 2 ; 属性(0=データ終わり,
						; 1=無圧縮データ,2=圧縮データ)
	JNE	PATPTX6				;

	CMP	PRSOPE,0			; ＰＵＴ時ｵﾍﾟﾚｰｼｮﾝ
	JNE	PATPTX55			; 0=normal

	CALL	OFSUNPLS			; データ復元(範囲指定)
;*;	CALL	UNPLS				; データ復元
	JMP	PATPTX_EXIT			;
PATPTX55:
	CMP	PRSOPE,1			; ＰＵＴ時ｵﾍﾟﾚｰｼｮﾝ
	JNE	PATPTX56			; 1=OR
	CALL	OFSUNPOR			; データ復元ＯＲ処理
	JMP	PATPTX_EXIT			;
PATPTX56:
	CMP	PRSOPE,2			; ＰＵＴ時ｵﾍﾟﾚｰｼｮﾝ
	JNE	PATPTX57			; 2=OR2
	CALL	OFSUNPORS		; データ復元ＯＲ処理単プレーンパターン
						; 単プレーンパターン
	JMP	PATPTX_EXIT			;
PATPTX57:
	CMP	PRSOPE,3			; ＰＵＴ時ｵﾍﾟﾚｰｼｮﾝ
	JNE	PATPTX6				; 3=vvram
	CALL	UNPVVR				; データ復元
						; 展開バッファ仮想ＶＲＡＭ化
	JMP	PATPUT_EXIT			;
PATPTX6:
PATPTX_EXIT:
	MOV	AX,0	; normal.
	POP	CX
	RET
PATPTX_ERROR:
	MOV	AX,1	; not found.
	POP	CX
	RET
C1PATPTX	ENDP



;	パーツＰＵＴオフセット指定
;	-I-   CX  : パーツ番号
;	-I/O- VRX : ＶＲＡＭ　Ｘ座標
;	      VRY : ＶＲＡＭ　Ｙ座標
;	-O-   AX  : 0=normal end, 1=error.

C1PATPTF	PROC	NEAR
	PUSH	CX

	CALL	PARTSCH		; パーツデータの検索
	CMP	AX,0		;
	JE	PATPTF1		;
	JMP	PATPTF_ERROR	;
PATPTF1:
	;	属性(0=データ終わり,1=無圧縮データ,2=圧縮データ)
	MOV	DX,ES:[DI][PARTS_OFST_ATR]
	CMP	DX,0
	JNE	PATPTF44
	JMP	PATPTF_ERROR			; end of data.
PATPTF44:
	;	データ復元
	MOV	AX,ES:[DI][PARTS_OFST_X]	; Ｘ座標
	ADD	VRX,AX				; ＶＲＡＭ　Ｘ座標
	MOV	AX,ES:[DI][PARTS_OFST_Y]	; Ｙ座標
	ADD	VRY,AX				; ＶＲＡＭ　Ｙ座標

	MOV	AX,ES:[DI][PARTS_OFST_LNX]	; Ｘ長さ
	MOV	VRLENX,AX			; Ｘ方向長さ
	MOV	AX,ES:[DI][PARTS_OFST_LNY]	; Ｙ長さ
	MOV	VRLENY,AX			; Ｙ方向長さ

	MOV	BPNTOF,DI		; データバッファポインタ
	ADD	BPNTOF,PARTS_OFST_DAT	; データ開始オフセット
	MOV	AX,PRSSEG		; バンクセグメント
	MOV	BPNTSG,AX		;

	MOV	AX,ES:[DI][PARTS_OFST_LEN]	; データ長さ
	MOV	BCNTMX,AX			; データ最大長さ

	CMP	ES:[DI][PARTS_OFST_ATR],WORD PTR 1 ; 属性(0=データ終わり,
						; 1=無圧縮データ,2=圧縮データ)
	JNE	PATPTF5				;
	CALL	VRMPT				; ＶＲＡＭデータＰＵＴ
	JMP	PATPTF_EXIT			;
PATPTF5:
	CMP	ES:[DI][PARTS_OFST_ATR],WORD PTR 2 ; 属性(0=データ終わり,
						; 1=無圧縮データ,2=圧縮データ)
	JNE	PATPTF6				;

	CMP	PRSOPE,0			; ＰＵＴ時ｵﾍﾟﾚｰｼｮﾝ
	JNE	PATPTF55			; 0=normal

	CALL	OFSUNPLS			; データ復元(範囲指定)
;*;	CALL	UNPLS				; データ復元
	JMP	PATPUT_EXIT			;
PATPTF55:
	CMP	PRSOPE,1			; ＰＵＴ時ｵﾍﾟﾚｰｼｮﾝ
	JNE	PATPTF56			; 1=OR
	CALL	OFSUNPOR			; データ復元ＯＲ処理
	JMP	PATPTF_EXIT			;
PATPTF56:
	CMP	PRSOPE,2			; ＰＵＴ時ｵﾍﾟﾚｰｼｮﾝ
	JNE	PATPTF57			; 2=OR2
	CALL	OFSUNPORS		; データ復元ＯＲ処理単プレーンパターン
						; 単プレーンパターン
	JMP	PATPTF_EXIT			;
PATPTF57:
	CMP	PRSOPE,3			; ＰＵＴ時ｵﾍﾟﾚｰｼｮﾝ
	JNE	PATPTF6				; 3=vvram
	CALL	UNPVVR				; データ復元
						; 展開バッファ仮想ＶＲＡＭ化
	JMP	PATPUT_EXIT			;
PATPTF6:
PATPTF_EXIT:
	MOV	AX,0	; normal.
	POP	CX
	RET
PATPTF_ERROR:
	MOV	AX,1	; not found.
	POP	CX
	RET
C1PATPTF	ENDP


;*;;	パーツセーブ
;*;;	-I- DS:SI : ファイル名
;*;;	-o- AX    : 0:normal.
;*;;	            1:error.
;*;
;*;C1PATSAV	PROC	NEAR
;*;	CALL	PAT_FLNSET		; パーツファイル名セット
;*;
;*;	MOV	DI,PRSTOP		; バンクトップオフセット
;*;	MOV	DX,PRSSEG		; バンクセグメント
;*;	MOV	CX,PRSSIZ		; パーツバッファの使用サイズ
;*;	MOV	SI,OFFSET FLPNAM	; パーツファイル名
;*;	CALL	DISKSV			; disk save.
;*;
;*;	RET
;*;C1PATSAV	ENDP


;	パーツロード
;	-I- DS:SI : ファイル名
;	-o- AX    : 0:normal.
;	            1:error.

C1PATLOD	PROC	NEAR
	PUSH	SI
	CALL	C1PATCLR		; パーツセットクリア
	POP	SI
	CALL	C1PATLDA		; パーツ追加ロード
	RET
C1PATLOD	ENDP


;	パーツ追加ロード
;	-I- DS:SI : ファイル名
;	-o- AX    : 0:normal.
;	            1:error.

C1PATLDA	PROC	NEAR
	CALL	PAT_FLNSET		; パーツファイル名セット

	MOV	CX,0FFFFH		; データ番号
	CALL	PARTSCH			; パーツデータの検索
	MOV	PRSOFS,DI		; パーツバッファのカレントポインタ

	MOV	CX,PRSEND		; バンクエンドオフセット
	SUB	CX,PRSOFS		; パーツバッファのカレントポインタ

	MOV	DX,PRSSEG		; バンクセグメント

	CALL	HEADMEMCLR		; header memory clear.

	MOV	SI,OFFSET FLPNAM	; パーツファイル名
	CALL	DISKLD			; disk load.
	CMP	AX,0			;
	JNE	C1PATLDA_ERROR		;

	MOV	CX,0FFFFH		; データ番号
	CALL	PARTSCH			; パーツデータの検索
	MOV	PRSOFS,DI		; パーツバッファのカレントポインタ
	SUB	DI,PRSTOP		; バンクトップオフセット
	MOV	PRSSIZ,DI		; パーツバッファの使用サイズ

	MOV	AX,0			; 0=normal.
	RET
C1PATLDA_ERROR:
	MOV	SI,OFFSET FLPNAM	; パーツファイル名
	BBERROR_FAR	120		; error flag.
	MOV	AX,1			; 1=error.
	RET
C1PATLDA	ENDP



;	バンクチェンジ
;	-I- DX : バンク番号（０ー３）

C1PATBNK	PROC	NEAR
;*;CODE_IN
;*;	PRV	"DX : バンク番号（０ー３）",DX
;*;CODE_OUT
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX

	MOV	PRSBNK,DX		; バンク番号

	CALL	BNKNUM			; バンクアドレスＧＥＴ

	MOV	PRSSEG,AX		; バンクセグメント
	MOV	PRSTOP,BX		; バンクトップオフセット
	MOV	PRSEND,CX		; バンクエンドオフセット

	MOV	PRSOFS,BX		;
	MOV	PRSSIZ,0		; パーツバッファの使用サイズ

	POP	DX
	POP	CX
	POP	BX
	POP	AX
	RET
C1PATBNK	ENDP



;	オペレーションセット
;	-I- DX : ＰＵＴ時ｵﾍﾟﾚｰｼｮﾝ
;		0:normal   通常のＰＵＴ
;		1:OR       ＯＲＰＵＴ
;		2:OR2      単プレーンパターンのＯＲＰＵＴ
;		3:VRAM     展開バッファ仮想ＶＲＡＭ化

C1PATOPE	PROC	NEAR
	MOV	PRSOPE,DX		; ＰＵＴ時ｵﾍﾟﾚｰｼｮﾝ
					; 0=normal,1=OR,2=OR2,3=vvram
	RET
C1PATOPE	ENDP


;	パーツＰＵＴエフェクト
;	-I- AX : 0=通常,1=パターンＰＵＴオーバラップ

C1PATEFC	PROC	NEAR
	MOV	BBOVLP,0	; パターンＰＵＴオーバラップフラグ

	CMP	AX,1		; 1=パターンＰＵＴオーバラップフラグ
	JNE	PATEFC2		;
	MOV	BBOVLP,1	; パターンＰＵＴオーバラップフラグ
PATEFC2:			;
	RET
C1PATEFC	ENDP



;	バンクアドレスＧＥＴ
;	-I- DX : バンク番号
;			１００番台は組み込みパターン
;	-O- AX : バンクセグメント
;	    BX : バンクトップオフセット
;	    CX : バンクエンドオフセット
;	    DX : 0=通常,1=バンク番号該当なし

BNKNUM	PROC	NEAR

;*DBG*;	PUSH	DX
;*DBG*;
;*DBG*;	MOV	SI,DX			;
;*DBG*;	INC	DS:DBGTBLACS[SI]	; bank access table.
;*DBG*;
;*DBG*;	MOV	AX,DX			;
;*DBG*;	ADD	AX,DX			;
;*DBG*;	ADD	AX,DX			;
;*DBG*;	ADD	AX,20			; AX = AX * 3 + 20
;*DBG*;
;*DBG*;	MOV	DL,DS:DBGTBLACS[SI]	; bank access table.
;*DBG*;	MOV	DH,0			;
;*DBG*;	LC	AX,25
;*DBG*;	CALL	DECSTR
;*DBG*;	ADD	SI,3
;*DBG*;	CALL	PRINT
;*DBG*;
;*DBG*;	POP	DX

	CMP	DX,100			; １００番台は組み込みパターン
	JNB	BNKNUM_KUMIKOMI		;

	CMP	DX,PATTBLMAX		; パターンテーブルレコード数
	JNB	BNKNUM_OVER		;

	MOV	SI,DX			; パターンテーブルレコード数
	SHL	SI,1			; word pointer.
	MOV	AX,DS:TBLPATSEG[SI]	; パターンセグメントテーブル
	MOV	BX,DS:TBLPATTOP[SI]	; パターン先頭オフセットテーブル
	MOV	CX,DS:TBLPATEND[SI]	; パターン終了オフセットテーブル

	JMP	BNKNUM_EXIT		;

BNKNUM_KUMIKOMI:
	SUB	DX,100			; １００番台は組み込みパターン

	CMP	DX,TBLPAT2MAX		; 組込パターンテーブルレコード数
	JNB	BNKNUM_OVER		;

	MOV	SI,DX			; パターンテーブルレコード数
	SHL	SI,1			; word pointer.
	MOV	AX,DS:TBLPAT2SEG[SI]	; 組込パターンセグメントテーブル
	MOV	BX,DS:TBLPAT2TOP[SI]	; 組込パターン先頭オフセットテーブル
	MOV	CX,DS:TBLPAT2END[SI]	; 組込パターン終了オフセットテーブル

BNKNUM_EXIT:
	MOV	DX,0			; 0=通常
	RET
BNKNUM_OVER:
	BBERROR_FAR	121		; error flag.

	MOV	AX,TBLPATSEG		; パターンセグメントテーブル
	MOV	BX,TBLPATTOP		; パターン先頭オフセットテーブル
	MOV	CX,TBLPATEND		; パターン終了オフセットテーブル

	MOV	DX,1			; 1=バンク番号該当なし
	RET
BNKNUM	ENDP



;	パーツデータの検索
;	-I- CX    : データ番号
;	-O- ES:DI : データ終りポインタ
;	    AX    : 0=normal 1=end of data.
;	    BX    : 検索データ番号

PARTSCH	PROC	NEAR
	PUSH	CX
	MOV	BX,0			; 検索データ番号
	MOV	AX,PRSSEG		; バンクセグメント
	MOV	ES,AX			;
	MOV	DI,PRSTOP		; バンクトップオフセット
	CMP	CX,0			;
	JE	PARTSCH3		;
PARTSCH2:
	;	属性(0=データ終わり,1=無圧縮データ,2=圧縮データ)
	CMP	WORD PTR ES:[DI][PARTS_OFST_ATR],0
	JE	PARTSCH4_NOT			; end of data.
	MOV	DX,ES:[DI][PARTS_OFST_LEN]	; データ長さ
	ADD	DI,DX				;
	ADD	DI,PARTS_OFST_DAT		; データ開始オフセット
	INC	BX			; 検索データ番号
	LOOP	PARTSCH2
PARTSCH3:
	CMP	WORD PTR ES:[DI][PARTS_OFST_ATR],0
	JE	PARTSCH4_NOT			; end of data.
PARTSCH4:
	MOV	AX,0		; 0=normal.
	POP	CX
	RET
PARTSCH4_NOT:
	MOV	AX,1		; 1=not found.
	POP	CX
	RET
PARTSCH	ENDP


;	パーツファイル名セット
;	-I- DS:SI : ファイル名

PAT_FLNSET	PROC	NEAR
	PUSH	SI

	MOV	AX,DS
	MOV	ES,AX

	MOV	DI,OFFSET FLPNAM	; ファイル名クリア
	MOV	CX,PATH_STRING_LEN	; path string length.
	MOV	AL,' '
	REP	STOSB

	MOV	DI,OFFSET FLPNAM	; ファイル名
	MOV	CX,PATH_STRING_LEN	; path string length.
PAT_FLNSET2:
	LODSB
	CMP	AL,' '			; end of string.
	JB	PAT_FLNSET3		;
	CMP	AL,'.'			; end of string.
	JNE	PAT_FLNSET22		;
	STOSB

	DEC	CX
	JZ	PAT_FLNSET_EXIT

	LODSB
	CMP	AL,'.'
	JE	PAT_FLNSET22		;
	CMP	AL,'\'
	JE	PAT_FLNSET22		;
	JMP	PAT_FLNSET5		;

PAT_FLNSET22:
	STOSB
	LOOP	PAT_FLNSET2
PAT_FLNSET3:

	MOV	AL,'.'		; add ".PT1"
	STOSB
	MOV	AL,'P'
	STOSB
	MOV	AL,'T'
	STOSB
	MOV	AL,'1'
	STOSB
	MOV	AL,0
	STOSB
	JMP	PAT_FLNSET_EXIT

PAT_FLNSET4:
	LODSB
	CMP	AL,' '			; end of string.
	JB	PAT_FLNSET6		;
	CMP	AL,'.'			; end of string.
	JE	PAT_FLNSET6		;
PAT_FLNSET5:
	STOSB
	LOOP	PAT_FLNSET4
PAT_FLNSET6:
	MOV	AL,0
	STOSB
PAT_FLNSET_EXIT:
	POP	SI
	RET
PAT_FLNSET	ENDP



;	header memory clear.
;	-I- DX : memory segment address.
;	    DI : memory offset address.
;	    CX : memory size.

HEADMEMCLR	PROC	NEAR
	PUSH	ES
	PUSH	DI
	PUSH	CX
	MOV	ES,DX			; memory segment address.
	MOV	AL,0			;
	MOV	CX,PARTS_OFST_DAT	; データ開始オフセット
	REP	STOSB			; clear.
	POP	CX
	POP	DI
	POP	ES
	RET
HEADMEMCLR	ENDP

CODE01	ENDS



DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	PATTBLMAX:WORD		; パターンテーブルレコード数
EXTRN	TBLPATSEG:WORD		; パターンセグメントテーブル
EXTRN	TBLPATTOP:WORD		; パターン先頭オフセットテーブル
EXTRN	TBLPATEND:WORD		; パターン終了オフセットテーブル

EXTRN	TBLPAT2MAX:WORD		; 組込パターンテーブルレコード数
EXTRN	TBLPAT2SEG:WORD		; 組込パターンセグメントテーブル
EXTRN	TBLPAT2TOP:WORD		; 組込パターン先頭オフセットテーブル
EXTRN	TBLPAT2END:WORD		; 組込パターン終了オフセットテーブル

EXTRN	VRX:WORD		; x point.
EXTRN	VRY:WORD		; y point.
EXTRN	VRLENX:WORD		; x length.
EXTRN	VRLENY:WORD		; y length.

EXTRN	VRPX:WORD		; ＧＥＴ Ｘ座標
EXTRN	VRPY:WORD		; ＧＥＴ Ｙ座標
EXTRN	VRLENPX:WORD		; ＧＥＴ Ｘサイズ
EXTRN	VRLENPY:WORD		; ＧＥＴ Ｙサイズ

EXTRN	BPOINT:WORD		; data buffer point.
EXTRN	BPNTOF:WORD		; データバッファポインタ
EXTRN	BPNTSG:WORD		; データバッファセグメント
EXTRN	BCNTMX:WORD		; データ最大長さ
EXTRN	BCOUNT:WORD		; データ長さ

EXTRN	BBOVTM:WORD		; パターンＰＵＴオーバラップタイム
EXTRN	BBOVLP:WORD		; パターンＰＵＴオーバラップフラグ


PUBLIC	PRSBNK			; バンク番号
PUBLIC	PRSSEG			; バンクセグメント
PUBLIC	PRSTOP			; バンクトップオフセット
PUBLIC	PRSEND			; バンクエンドオフセット

PUBLIC	PRSOFS			; パーツバッファのカレントポインタ
PUBLIC	PRSSIZ			; パーツバッファの使用サイズ

FLPNAM	DB PATH_STRING_LEN DUP (0),0,0 ; ファイル名

		EVEN
PRSOFS		DW	0		; パーツバッファのカレントポインタ
PRSSIZ		DW	0		; パーツバッファの使用サイズ

PRSOPE		DW	0	; ＰＵＴ時ｵﾍﾟﾚｰｼｮﾝ
				;0:normal  通常のＰＵＴ
				;1:OR      ＯＲＰＵＴ
				;2:OR2     単プレーンパターンのＯＲＰＵＴ
				;3:VRAM    展開バッファ仮想ＶＲＡＭ化

PRSBNK		DW	0		; バンク番号

PRSSEG		DW	0		; バンクセグメント
PRSTOP		DW	0		; バンクトップオフセット
PRSEND		DW	0		; バンクエンドオフセット


;*;FLAGERROR	DW	0		; error flag.

;*;DBGTBLACS	DB	20 DUP (0)	; bank access table.

DATA	ENDS

	END
;
;	end of "PARTST.ASM"
;
