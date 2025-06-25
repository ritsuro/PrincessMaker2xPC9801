; "PARTT2.ASM" PC-9801UV11 make by R.H 1990/01/04
;	modify 1991/06/22 PS55Z/J14 (code01 gate call)
;
;
;	マスクパーツデータＧＥＴ＆ＰＵＴ
;
;1991/12/04
;		PLSLD4.ASM/UNPLSM -> PLSLD7.ASM/OFSUNPLSM
;
;
;	高度なテクニックを使う場合
;	・マスクパーツのＰＵＴプレーンの設定
;		CALL C1PATMST を呼び出して下さい
;	・ＯＲでＰＵＴするプレーンの設定
;		DS:BORRCL:WORD を設定して下さい
;		（詳細はPLSLD3.ASM/UNPORを参照のこと）
;
; public subroutine.


;	パーツバッファのオフセット値
PARTS_OFST_ATR	EQU	0	; 属性(0=データ終わり,
				;      1=無圧縮データ,2=圧縮データ)
PARTS_OFST_X	EQU	2	; Ｘ座標
PARTS_OFST_Y	EQU	4	; Ｙ座標
PARTS_OFST_LNX	EQU	6	; Ｘ長さ
PARTS_OFST_LNY	EQU	8	; Ｙ長さ
PARTS_OFST_LEN	EQU	10	; データ長さ
PARTS_OFST_DAT	EQU	12	; データ開始オフセット


CODE01	SEGMENT	PUBLIC	'CODE01'
	ASSUME	CS:CODE01,DS:DATA

PUBLIC	C1PATSIZ	; パーツサイズのＧＥＴ
PUBLIC	C1PATMST	; マスクパーツのＰＵＴプレーン設定

;*;PUBLIC C1PATGTM	; マスクパーツＧＥＴ
PUBLIC	C1PATPTM	; マスクパーツＰＵＴ
PUBLIC	C1PATPXM	; マスクパーツＰＵＴ座標指定
PUBLIC	C1PATPFM	; マスクパーツＰＵＴオフセット指定

PUBLIC	C1PATTPD	; 先頭パターンデータの削除
;*;PUBLIC C1PATEDD	; 指定パターンデータ以降の削除

EXTRN	OFSUNPLSM:NEAR	; マスク化

;*;EXTRN UNPLSM:NEAR	; マスク化（マスクデータ復元）
;*;EXTRN C1PLESSM:NEAR	; マスクデータ圧縮


;*;;	マスクパーツＧＥＴ
;*;;	-I- VRX		: ＶＲＡＭ　Ｘ座標
;*;;	    VRY		: ＶＲＡＭ　Ｙ座標
;*;;	    VRLENX	: Ｘ方向長さ
;*;;	    VRLENY	: Ｙ方向長さ
;*;;	-O- AX		: 0=normal end, 1=error.
;*;
;*;C1PATGTM	PROC	NEAR
;*;	PUSH	CX
;*;
;*;	MOV	AX,PRSSEG		; バンクセグメント
;*;	MOV	ES,AX			;
;*;
;*;	MOV	DI,PRSOFS		; パーツバッファのカレントポインタ
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
;*;	CALL	C1PLESSM		; マスクデータ圧縮
;*;	POP	ES
;*;	POP	DI
;*;
;*;	CMP	AH,1	; 0 or 2 : normal end. 1:write error.
;*;	JE	PATGTM_ERROR
;*;
;*;	MOV	AX,BCOUNT			; データ長さ
;*;	MOV	ES:[DI][PARTS_OFST_LEN],AX	; データ長さ
;*;
;*;	MOV	AX,BCOUNT		; データ長さ
;*;	ADD	AX,PARTS_OFST_DAT	;
;*;	ADD	PRSSIZ,AX		; パーツバッファの使用サイズ
;*;
;*;	;	属性(0=データ終わり,1=無圧縮データ,2=圧縮データ
;*;	;	     3=マスクデータ)
;*;	MOV	ES:[DI][PARTS_OFST_ATR],WORD PTR 3
;*;
;*;	MOV	DI,BPOINT 		; データ終わりアドレス＋１
;*;	MOV	ES:[DI][PARTS_OFST_ATR],WORD PTR 0
;*;
;*;	MOV	PRSOFS,DI 		; パーツバッファのカレントポインタ
;*;PATGTM_EXIT:
;*;	MOV	AX,0			; normal.
;*;	POP	CX
;*;	RET
;*;PATGTM_ERROR:
;*;	MOV	AX,1			; buffer full.
;*;	POP	CX
;*;	RET
;*;C1PATGTM	ENDP



;	マスクパーツＰＵＴ
;	-I- CX : パーツ番号
;	-O- AX : 0=normal end, 1=error.

C1PATPTM	PROC	NEAR
	PUSH	CX

	CALL	PARTSCH		; パーツデータの検索
	CMP	AX,0		;
	JE	PATPTM1		;
	JMP	PATPTM_ERROR	;
PATPTM1:
	;	データ復元
	MOV	AX,ES:[DI][PARTS_OFST_X]	; Ｘ座標
	MOV	VRX,AX				; ＶＲＡＭ　Ｘ座標
	MOV	AX,ES:[DI][PARTS_OFST_Y]	; Ｙ座標
	MOV	VRY,AX				; ＶＲＡＭ　Ｙ座標
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

	CMP	ES:[DI][PARTS_OFST_ATR],WORD PTR 3 ; 属性(0=データ終わり,
						; 1=無圧縮データ,2=圧縮データ
						; 3=マスクデータ)
	JNE	PATPTM6				;

	MOV	AX,PMSKPL			; マスクＰＵＴプレーン指定
	MOV	BMSKCL,AX			; マスキングカラー

	CALL	OFSUNPLSM			; マスク化
;*;	CALL	UNPLSM				; マスク化（マスクデータ復元）

	JMP	PATPTM_EXIT			;
PATPTM6:

PATPTM_EXIT:
	MOV	AX,0	; normal.
	POP	CX
	RET
PATPTM_ERROR:
	MOV	AX,1	; not found.
	POP	CX
	RET
C1PATPTM	ENDP



;	マスクパーツＰＵＴ座標指定
;	-I- CX  : パーツ番号
;	    VRX	: ＶＲＡＭ　Ｘ座標
;	    VRY : ＶＲＡＭ　Ｙ座標
;	-O- AX  : 0=normal end, 1=error.

C1PATPXM	PROC	NEAR
	PUSH	CX

	CALL	PARTSCH		; パーツデータの検索
	CMP	AX,0		;
	JE	PATPXM1		;
	JMP	PATPXM_ERROR	;
PATPXM1:
	;	属性(0=データ終わり,1=無圧縮データ,2=圧縮データ)
	MOV	DX,ES:[DI][PARTS_OFST_ATR]
	CMP	DX,0
	JNE	PATPXM44
	JMP	PATPXM_ERROR			; end of data.
PATPXM44:
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

	CMP	ES:[DI][PARTS_OFST_ATR],WORD PTR 3 ; 属性(0=データ終わり,
						; 1=無圧縮データ,2=圧縮データ
						; 3=マスクデータ)
	JNE	PATPXM6				;

	MOV	AX,PMSKPL			; マスクＰＵＴプレーン指定
	MOV	BMSKCL,AX			; マスキングカラー

	CALL	OFSUNPLSM			; マスク化
;*;	CALL	UNPLSM				; マスク化（マスクデータ復元）

	JMP	PATPXM_EXIT			;
PATPXM6:

PATPXM_EXIT:
	MOV	AX,0	; normal.
	POP	CX
	RET
PATPXM_ERROR:
	MOV	AX,1	; not found.
	POP	CX
	RET
C1PATPXM	ENDP



;	マスクパーツＰＵＴオフセット指定
;	-I-   CX  : パーツ番号
;	-I/O- VRX : ＶＲＡＭ　Ｘ座標
;	      VRY : ＶＲＡＭ　Ｙ座標
;	-O-   AX  : 0=normal end, 1=error.

C1PATPFM	PROC	NEAR
	PUSH	CX

	CALL	PARTSCH		; パーツデータの検索
	CMP	AX,0		;
	JE	PATPFM1		;
	JMP	PATPFM_ERROR	;
PATPFM1:
	;	属性(0=データ終わり,1=無圧縮データ,2=圧縮データ)
	MOV	DX,ES:[DI][PARTS_OFST_ATR]
	CMP	DX,0
	JNE	PATPFM44
	JMP	PATPFM_ERROR			; end of data.
PATPFM44:
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

	CMP	ES:[DI][PARTS_OFST_ATR],WORD PTR 3 ; 属性(0=データ終わり,
						; 1=無圧縮データ,2=圧縮データ
						; 3=マスクデータ)
	JNE	PATPFM6				;

	MOV	AX,PMSKPL			; マスクＰＵＴプレーン指定
	MOV	BMSKCL,AX			; マスキングカラー

	CALL	OFSUNPLSM			; マスク化
;*;	CALL	UNPLSM				; マスク化（マスクデータ復元）

	JMP	PATPFM_EXIT			;
PATPFM6:

PATPFM_EXIT:
	MOV	AX,0	; normal.
	POP	CX
	RET
PATPFM_ERROR:
	MOV	AX,1	; not found.
	POP	CX
	RET
C1PATPFM	ENDP



;	パーツサイズのＧＥＴ
;	-I- CX : パーツ番号
;	-O- VRX		: ＶＲＡＭ　Ｘ座標
;	    VRY		: ＶＲＡＭ　Ｙ座標
;	    VRLENX	: Ｘ方向長さ
;	    VRLENY	: Ｙ方向長さ
;	    AX : 0=normal end, 1=error.

C1PATSIZ	PROC	NEAR
	PUSH	CX

	CALL	PARTSCH		; パーツデータの検索
	CMP	AX,0		;
	JE	PATSIZ1		;
	JMP	PATSIZ_ERROR	;
PATSIZ1:
	;	データ復元
	MOV	AX,ES:[DI][PARTS_OFST_X]	; Ｘ座標
	MOV	VRX,AX				; ＶＲＡＭ　Ｘ座標
	MOV	AX,ES:[DI][PARTS_OFST_Y]	; Ｙ座標
	MOV	VRY,AX				; ＶＲＡＭ　Ｙ座標
	MOV	AX,ES:[DI][PARTS_OFST_LNX]	; Ｘ長さ
	MOV	VRLENX,AX			; Ｘ方向長さ
	MOV	AX,ES:[DI][PARTS_OFST_LNY]	; Ｙ長さ
	MOV	VRLENY,AX			; Ｙ方向長さ
PATSIZ_EXIT:
	MOV	AX,0	; normal.
	POP	CX
	RET
PATSIZ_ERROR:
	MOV	AX,1	; not found.
	POP	CX
	RET
C1PATSIZ	ENDP


;	先頭パターンデータの削除
;	-I- CX : 残す先頭のパーツ番号

C1PATTPD	PROC	NEAR
	PUSH	CX

	CALL	PARTSCH			; パーツデータの検索
	CMP	AX,0			; 0=normal 1=end of data.
	JNE	C1PATTPD_EXIT		;

	MOV	SI,DI			; 残すデータの先頭=SI

	MOV	CX,PRSEND		; バンクエンドオフセット
	SUB	CX,SI			; 転送データ量

	MOV	DI,PRSTOP		; バンクトップオフセット

	PUSH	DS
	MOV	AX,PRSSEG		; バンクセグメント
	MOV	ES,AX			;
	MOV	DS,AX			; PRSSEG 内の転送
	REP	MOVSB			; 転送
	POP	DS

	MOV	CX,0FFFFH		;
	CALL	PARTSCH			; パーツデータの検索
	MOV	PRSOFS,DI		; パーツバッファのカレントポインタ

	SUB	DI,PRSTOP		; バンクトップオフセット
	MOV	PRSSIZ,DI		; パーツバッファの使用サイズ

C1PATTPD_EXIT:
	POP	CX
	RET
C1PATTPD	ENDP


;*non*;;	指定パターンデータ以降の削除
;*non*;;	-I- CX : 削除する先頭のパーツ番号
;*non*;
;*non*;C1PATEDD	PROC	NEAR
;*non*;	PUSH	CX
;*non*;
;*non*;	CALL	PARTSCH			; パーツデータの検索
;*non*;
;*non*;	;	属性(0=データ終わり,1=無圧縮データ,2=圧縮データ)
;*non*;	MOV	AX,PRSSEG		; バンクセグメント
;*non*;	MOV	ES,AX			;
;*non*;	MOV	WORD PTR ES:[DI][PARTS_OFST_ATR],0
;*non*;
;*non*;	MOV	PRSOFS,DI		; パーツバッファのカレントポインタ
;*non*;
;*non*;	SUB	DI,PRSTOP		; バンクトップオフセット
;*non*;	MOV	PRSSIZ,DI		; パーツバッファの使用サイズ
;*non*;
;*non*;	POP	CX
;*non*;	RET
;*non*;C1PATEDD	ENDP


;	マスクパーツのＰＵＴプレーン設定
;	-I- DX : ＰＵＴプレーン指定(bit0=ﾌﾟﾚｰﾝ0,bit1=ﾌﾟﾚｰﾝ1,bit2=2,bit3=3)

C1PATMST	PROC	NEAR
	MOV	PMSKPL,DX	; マスクＰＵＴプレーン指定
	RET
C1PATMST	ENDP


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


CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	VRX:WORD		; x point.
EXTRN	VRY:WORD		; y point.

EXTRN	VRLENX:WORD		; x length.
EXTRN	VRLENY:WORD		; y length.

EXTRN	BPOINT:WORD		; data buffer point.
EXTRN	BPNTOF:WORD		; データバッファポインタ
EXTRN	BPNTSG:WORD		; データバッファセグメント
EXTRN	BCNTMX:WORD		; データ最大長さ
EXTRN	BCOUNT:WORD		; データ長さ


EXTRN	PRSBNK:WORD		; バンク番号
EXTRN	PRSSEG:WORD		; バンクセグメント
EXTRN	PRSTOP:WORD		; バンクトップオフセット
EXTRN	PRSEND:WORD		; バンクエンドオフセット

EXTRN	PRSOFS:WORD		; パーツバッファのカレントポインタ
EXTRN	PRSSIZ:WORD		; パーツバッファの使用サイズ

EXTRN	BMSKCL:WORD		; マスキングカラー
EXTRN	BORRCL:WORD		; ＯＲカラー

	EVEN
PMSKPL	DW	1111B		; マスクＰＵＴプレーン指定
				; (bit0=ﾌﾟﾚｰﾝ0,bit1=ﾌﾟﾚｰﾝ1,bit2=2,bit3=3)

DATA	ENDS

	END
;
;	end of "PARTT2.ASM"
;
