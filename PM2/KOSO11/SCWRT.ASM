; "SCWRT.ASM" PC-9801UV11 make by R.H 1991/03/10
;
;	h e a d e r   s e c t o r   w r i t e   &   r e a d.
;
;	先頭セクター順次書き込み、読み込み

INCLUDE	TSTSET.INC

DEBUG	EQU	0

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	SCWINI			; 初期設定
PUBLIC	SCWSET			; 論理レコード設定
PUBLIC	SCWSEQ			; セクター順次書き込み
PUBLIC	SCWRED			; セクター順次読み込み
PUBLIC	SCWDRV			; ドライブ番号の設定（０ー３）
;*;PUBLIC SCWRST		; 使用ドライブの初期化

SEC_BYTE	EQU	1024	; セクタバイト数
FDMA_BYTE	EQU	1024	; ディスク用ＤＭＡバッファ長さ

WRITE_RETCOUNT 	EQU	3	; セクタ書き込み・リトライ回数
READ_RETCOUNT 	EQU	1	; リード・リトライ回数

MIN_CYLINDER	EQU	0	; シリンダ番号（Ｃ）０
MIN_HEAD	EQU	0	; ヘッド番号（Ｈ）０
MIN_SECTOR	EQU	1	; セクタ番号（Ｒ）１

MAX_CYLINDER	EQU	76	; シリンダ番号（Ｃ）７６
MAX_HEAD	EQU	1	; ヘッド番号（Ｈ）１
MAX_SECTOR	EQU	8	; セクタ番号（Ｒ）２６

DISK_STATUS_DB	EQU	20H	; DMA Boundary.メモリアドレスがＤＭＡ
				; に向いていない（バンクにまたがった）

;	初期設定
;

SCWINI	PROC	NEAR
	MOV	WRITE_CYLINDER,	MIN_CYLINDER	; シリンダ番号（Ｃ）０
	MOV	WRITE_HEAD,	MIN_HEAD	; ヘッド番号（Ｈ）０
	MOV	WRITE_SECTOR,	MIN_SECTOR	; セクタ番号（Ｒ）１
	RET
SCWINI	ENDP


;	論理レコード設定
;	-I- AX : 論理レコード番号

SCWSET	PROC	NEAR
	MOV	DX,AX		;
	SHR	AX,1		;
	SHR	AX,1		;
	SHR	AX,1		;
	AND	DX,07H		; ８で割る（ＡＸ答え、ＤＸ余り）

	INC	DX		;
	MOV	WRITE_SECTOR,DX	; セクタ番号（Ｒ）１ー８（２６）

	MOV	WRITE_HEAD,AX	; ヘッド番号（Ｈ）０ー１
	AND	WRITE_HEAD,0001H	; 偶数と奇数

	SHR	AX,1		;
	MOV	WRITE_CYLINDER,AX ; シリンダ番号（Ｃ）

	RET
SCWSET	ENDP


;	セクター順次書き込み
;	-I- DX : バッファセグメント
;	    BX : バッファオフセット
;	-O- AX : 0=正常,1=エラー,2=最後のセクタに書き込んだ

SCWSEQ	PROC	NEAR

	MOV	BUFF_SEG,DX	; バッファセグメント
	MOV	BUFF_OFFSET,BX	; バッファオフセット

	MOV	AX,WRITE_CYLINDER	; シリンダ番号（Ｃ）
	MOV	DCYL,AX			;
	MOV	AX,WRITE_HEAD		; ヘッド番号（Ｈ）
	MOV	DHEAD,AX		;
	MOV	AX,WRITE_SECTOR		; セクタ番号（Ｒ）
	MOV	DSECR,AX		;

	CALL	SCWRITE		; セクター書き込み
	CMP	DERROR,0	; 0=正常,1=エラー
	JNE	SCWSEQ_ERROR

	INC	WRITE_SECTOR	; セクタ番号（Ｒ）
	CMP	WRITE_SECTOR,MAX_SECTOR
	JBE	SCWSEQ8

	MOV	WRITE_SECTOR,MIN_SECTOR
	INC	WRITE_HEAD	; ヘッド番号（Ｈ）
	CMP	WRITE_HEAD,MAX_HEAD
	JBE	SCWSEQ8

	MOV	WRITE_HEAD,MIN_HEAD
	INC	WRITE_CYLINDER	; シリンダ番号（Ｃ）
	CMP	WRITE_CYLINDER,MAX_CYLINDER
	JBE	SCWSEQ8

	JMP	SCWSEQ_ENDSEC
SCWSEQ8:
	MOV	AX,0		; 0=正常
	RET
SCWSEQ_ERROR:
	MOV	AX,1		; 1=エラー
	RET
SCWSEQ_ENDSEC:
	MOV	AX,2		; 2=最後のセクタに書き込んだ
	RET
SCWSEQ	ENDP


;	セクター順次読み込み
;	-I- DX : バッファセグメント
;	    BX : バッファオフセット
;	-O- AX : 0=正常,1=エラー,2=最後のセクタに書き込んだ

SCWRED	PROC	NEAR

	MOV	BUFF_SEG,DX	; バッファセグメント
	MOV	BUFF_OFFSET,BX	; バッファオフセット

	MOV	AX,WRITE_CYLINDER	; シリンダ番号（Ｃ）
	MOV	DCYL,AX			;
	MOV	AX,WRITE_HEAD		; ヘッド番号（Ｈ）
	MOV	DHEAD,AX		;
	MOV	AX,WRITE_SECTOR		; セクタ番号（Ｒ）
	MOV	DSECR,AX		;

	CALL	SCREAD			; セクターリード
	CMP	DERROR,0		; 0=正常,1=エラー
	JNE	SCWRED_ERROR

	INC	WRITE_SECTOR		; セクタ番号（Ｒ）
	CMP	WRITE_SECTOR,MAX_SECTOR
	JBE	SCWRED8

	MOV	WRITE_SECTOR,MIN_SECTOR
	INC	WRITE_HEAD		; ヘッド番号（Ｈ）
	CMP	WRITE_HEAD,MAX_HEAD
	JBE	SCWRED8

	MOV	WRITE_HEAD,MIN_HEAD
	INC	WRITE_CYLINDER		; シリンダ番号（Ｃ）
	CMP	WRITE_CYLINDER,MAX_CYLINDER
	JBE	SCWRED8

	JMP	SCWRED_ENDSEC
SCWRED8:
	MOV	AX,0		; 0=正常
	RET
SCWRED_ERROR:
	MOV	AX,1		; 1=エラー
	RET
SCWRED_ENDSEC:
	MOV	AX,2		; 2=最後のセクタに書き込んだ
	RET
SCWRED	ENDP


;	ドライブ番号の設定（０ー３）
;	-I- AX : １ＭＦＤドライブ番号

SCWDRV	PROC	NEAR
	AND	AL,011B
	AND	BYTE PTR DUNIT,11111100B
	OR	BYTE PTR DUNIT,AL
	RET
SCWDRV	ENDP


;*;;	使用ドライブの初期化
;*;
;*;SCWRST	PROC	NEAR
;*;	MOV	AL,BYTE PTR DUNIT	; デバイス識別・ユニット番号(DA/UA)
;*;	MOV	AH,BYTE PTR DCMD_INIT	; ＩＮＩＴＩＡＬＩＺＥ
;*;	INT	1BH			; ＤＩＳＫ　ＢＩＯＳ
;*;	MOV	BYTE PTR DSTAT,AH	; ステータス情報
;*;	RET
;*;SCWRST	ENDP


;	セクター書き込み
;	-I- BUFF_SEG	: バッファセグメント
;	    BUFF_OFFSET	: バッファオフセット
;	    DCYL        : シリンダ番号（Ｃ）０ー７６
;	    DHEAD	: ヘッド番号（Ｈ）０ー１
;	    DSECR	: セクタ番号（Ｒ）１ー２６
;	-O- DERROR	: 0=正常,1=エラー

SCWRITE	PROC	NEAR

IF DEBUG
	PRVH	"r DUNIT ",DUNIT	; デバイス識別・ユニット番号(DA/UA)
	PRVH	"r DLEN  ",DLEN		; データ長（ＤＴＬ）（バイト単位）
	PRVH	"r DCYL  ",DCYL 	; シリンダ番号（Ｃ）０ー７６
	PRVH	"r DHEAD ",DHEAD	; ヘッド番号（Ｈ）０ー１
	PRVH	"r DSECR ",DSECR	; セクタ番号（Ｒ）１ー８（２６）
	PRVH	"r DSECN ",DSECN	; セクタ長（Ｎ）
ENDIF

	MOV	AX,WRITE_RETCOUNT; セクタ書き込み・リトライ回数
	MOV	WRITE_RETRY,AX	 ; セクタ書き込み・リトライカウンタ
SCWRITE1:
	CALL	DMA_BUFSET	; ＤＭＡバッファセット

	MOV	AX,DS		; ＤＭＡバッファセグメント
	MOV	ES,AX		;
	MOV	BP,SCADRS	; ＤＭＡバッファオフセット

	MOV	AL,BYTE PTR DUNIT ; デバイス識別・ユニット番号(DA/UA)
	MOV	BX,WORD PTR DLEN  ; データ長（ＤＴＬ）（バイト単位）
	MOV	CL,BYTE PTR DCYL  ; シリンダ番号（Ｃ）０ー７６
	MOV	DH,BYTE PTR DHEAD ; ヘッド番号（Ｈ）０ー１
	MOV	DL,BYTE PTR DSECR ; セクタ番号（Ｒ）１ー２６
	MOV	CH,BYTE PTR DSECN ; セクタ長（Ｎ）　

	MOV	AH,BYTE PTR DCMD_WRITE ; ＷＲＩＴＥＤＡＴＡ
	INT	1BH		  ; ディスクＢＩＯＳ
	MOV	BYTE PTR DSTAT,AH ; ステータス情報

	JNB	SCWRITE9	; 正常終了

	DEC	WRITE_RETRY	; セクタ書き込み・リトライカウンタ
	JZ	SCWRITE99

	CMP	BYTE PTR DSTAT,DISK_STATUS_DB
				; DMA Boundary.メモリアドレスがＤＭＡ
				; に向いていない（バンクにまたがった）
	JNE	SCWRITE5

	CALL	DMA_ADRS_CHANGE	; ＤＭＡバッファのアドレスを変更する

	JMP	SCWRITE1
SCWRITE5:
	MOV	AH,BYTE PTR DCMD_RECAL ; ＲＥＣＡＬＩＢＲＡＴＥ
	INT	1BH		   ; ディスクＢＩＯＳ
	MOV	BYTE PTR DSTAT,AH  ; ステータス情報

	JMP	SCWRITE1
SCWRITE9:
	MOV	DERROR,0	; 0=正常
	RET
SCWRITE99:
	MOV	DERROR,1	; 1=エラー
	RET
SCWRITE	ENDP

;	セクターリード
;	-I- BUFF_SEG	: バッファセグメント
;	    BUFF_OFFSET	: バッファオフセット
;	    DCYL   : シリンダ番号（Ｃ）０ー７６
;	    DHEAD  : ヘッド番号（Ｈ）０ー１
;	    DSECR  : セクタ番号（Ｒ）１ー８（２６）
;	-O- SCADRS : セクタバッファアドレス
;	    BUFF_SEG:[BUFF_OFFSET] : データ
;	    DERROR : 0=正常,1=エラー

SCREAD	PROC	NEAR
	MOV	AX,READ_RETCOUNT; リード・リトライカウンタ
	MOV	READ_RETRY,AX	;

SCREAD5:
	MOV	AX,DS		; ＤＭＡバッファセグメント
	MOV	ES,AX		;
	MOV	BP,SCADRS	; ＤＭＡバッファオフセット

	MOV	AL,BYTE PTR DUNIT ; デバイス識別・ユニット番号(DA/UA)
	MOV	BX,WORD PTR DLEN  ; データ長（ＤＴＬ）（バイト単位）
	MOV	CL,BYTE PTR DCYL  ; シリンダ番号（Ｃ）０ー７６
	MOV	DH,BYTE PTR DHEAD ; ヘッド番号（Ｈ）０ー１
	MOV	DL,BYTE PTR DSECR ; セクタ番号（Ｒ）１ー８（２６）
	MOV	CH,BYTE PTR DSECN ; セクタ長（Ｎ）
	MOV	AH,BYTE PTR DREAD ; ＲＥＡＤ　ＤＡＴＡ
	INT	1BH		  ; ディスクＢＩＯＳ
	MOV	BYTE PTR DSTAT,AH ; ステータス情報

	JNB	SCREAD9		  ; 正常終了

	DEC	READ_RETRY	  ; リード・リトライカウンタ
	JZ	SCREAD99

	CMP	BYTE PTR DSTAT,DISK_STATUS_DB
				; DMA Boundary.メモリアドレスがＤＭＡ
				; に向いていない（バンクにまたがった）
	JNE	SCREAD6

	CALL	DMA_ADRS_CHANGE	; ＤＭＡバッファのアドレスを変更する

	JMP	SCREAD5			; ＤＭＡバッファの変更
SCREAD6:
	MOV	AH,BYTE PTR DRECAL ; ＲＥＣＡＬＩＢＲＡＴＥ
	INT	1BH		   ; ディスクＢＩＯＳ
	MOV	BYTE PTR DSTAT,AH  ; ステータス情報

	JMP	SCREAD5
SCREAD9:
	CALL	DMA_BUFGET		; ＤＭＡバッファＧＥＴ
	MOV	DERROR,0		; 0=正常
	RET
SCREAD99:
	MOV	DERROR,1		; 1=エラー
	RET
SCREAD	ENDP


;	ＤＭＡバッファＧＥＴ
;	-I- BUFF_SEG	: バッファセグメント
;	    BUFF_OFFSET	: バッファオフセット
;	    DATA:[SCADRS] : ＤＭＡバッファ
;	-O- BUFF_SEG:[BUFF_OFFSET] : データ

DMA_BUFGET	PROC	NEAR
	PUSH	DS
	MOV	CX,FDMA_BYTE		; ディスク用ＤＭＡバッファ長さ

	MOV	AX,BUFF_SEG		;
	MOV	ES,AX			;
	MOV	DI,BUFF_OFFSET		; コピー元バッファ

	MOV	SI,SCADRS		; ＤＭＡバッファ使用アドレス

	REP	MOVSB			;
	POP	DS
	RET
DMA_BUFGET	ENDP


;	ＤＭＡバッファセット
;	-I- BUFF_SEG	: バッファセグメント
;	    BUFF_OFFSET	: バッファオフセット
;	-O- DATA:[SCADRS] : ＤＭＡバッファ

DMA_BUFSET	PROC	NEAR
	PUSH	DS
	MOV	CX,FDMA_BYTE		; ディスク用ＤＭＡバッファ長さ

	MOV	AX,DS			;
	MOV	ES,AX			;
	MOV	DI,SCADRS		; ＤＭＡバッファ使用アドレス

	MOV	SI,BUFF_OFFSET		; コピー元バッファ
	MOV	AX,BUFF_SEG		;
	MOV	DS,AX			;

	REP	MOVSB			;
	POP	DS
	RET
DMA_BUFSET	ENDP


;	ＤＭＡバッファのアドレスを変更する
;	-I/O- DMA_SELECT	; 緊急時ＤＭＡバッファの選択
;				; 0=ＤＭＡﾊﾞｯﾌｧ0, 1=ＤＭＡﾊﾞｯﾌｧ1
;	      SCADRS		; ＤＭＡバッファ使用アドレス

DMA_ADRS_CHANGE	PROC	NEAR
	CMP	DMA_SELECT,0
	JNE	DMA_ADRS_CHANGE2

	MOV	SCADRS,OFFSET SCDATA2
	MOV	DMA_SELECT,1
	RET
DMA_ADRS_CHANGE2:
	MOV	SCADRS,OFFSET SCDATA
	MOV	DMA_SELECT,0
	RET
DMA_ADRS_CHANGE	ENDP


; ****************************************************
;	DATA
; ****************************************************
	EVEN

EXTRN	SCADRS:WORD			; セクタバッファアドレス
EXTRN	SCDATA:WORD			; セクタバッファ
EXTRN	SCDATA2:WORD			; セクタバッファ

DMA_SELECT	DW	0	; 緊急時ＤＭＡバッファの選択
				; 0=ＤＭＡﾊﾞｯﾌｧ0, 1=ＤＭＡﾊﾞｯﾌｧ1


;		ＢＩＯＳコマンド識別コード
;		MM-S....
;		TFrK0110 READ
;		0|||0101 WRITE
DREAD		DW	11110110B	; ＲＥＡＤ　ＤＡＴＡ
DRECAL		DW	00100111B	; ＲＥＣＡＬＩＢＲＡＴＥ
DCMD_WRITE	DW	01010101B	; ＷＲＩＴＥＤＡＴＡ
DCMD_RECAL	DW	00100111B	; ＲＥＣＡＬＩＢＲＡＴＥ
DCMD_INIT	DW	03H	 	; ＩＮＩＴＩＡＬＩＺＥ

;		100100dd
DUNIT	DW	10010010B	; デバイス識別・ユニット番号（DA/UA）

;	ＩＤＲ（ＩＤ情報）
DLEN	DW	SEC_BYTE	; データ長（ＤＴＬ）（バイト単位）
DCYL	DW	0		; シリンダ番号（Ｃ）０ー７６
DHEAD	DW	0		; ヘッド番号（Ｈ）０ー１
DSECR	DW	1		; セクタ番号（Ｒ）１ー２６
DSECN	DW	03		; セクタ長（Ｎ）
				; 00/128, 01/256, 02/512, 03/1024

DSTAT	DW	0		; ステータス情報
DERROR	DW	0		; 0=正常,1=エラー

	EVEN


BUFF_SEG	DW	0	; バッファセグメント
BUFF_OFFSET	DW	0	; バッファオフセット

WRITE_RETRY	DW	0	; セクタ書き込み・リトライカウンタ
READ_RETRY	DW	0		; リード・リトライカウンタ


WRITE_CYLINDER	DW	0	; シリンダ番号（Ｃ）（０ー７６）
WRITE_HEAD	DW	0	; ヘッド番号（Ｈ）（０ー１）
WRITE_SECTOR	DW	0	; セクタ番号（Ｒ）（１ー２６）

NUM		DW	0	; counter.

CODE	ENDS

	END
;
;	end of "SCWRT.ASM"
;
