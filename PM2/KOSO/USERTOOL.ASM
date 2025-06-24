; "USERTOOL.ASM" PC-9801UV11 make by R.H 1992/05/15
;
;
;	user tool.
;
;
; public subroutine.

INCLUDE	TSTSETC.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	USERWAIT		; user wait.
PUBLIC	KANJITUME		; 漢字文字詰め処理
PUBLIC	KANJISHORT		; 漢字文字列を半角に詰める
PUBLIC	KANJICHOT		; 漢字文字列をちょっとだけ半角に詰める

EXTRN	SJISCHK:NEAR		; シフトＪＩＳチェック

; ****************************************************
;	user wait.
; ****************************************************

USERWAIT	PROC	NEAR
	CMP	USERDEMO,55		; 55=ランダムセレクト
	JE	USERWAIT_DEMO		;

	CALLE	MSCSRT			; カーソルスタート
	CALLE	MUSWAT			; マウスボタンＯＦＦ待ち
USERWAIT_LOOP:
	CALLE	MSCMOV			; カーソル移動
	CMP	DH,1			; 左ボタン（1：ＯＦＦ／0：ＯＮ）
	JNE	USERWAIT_EXIT		;
	CMP	DL,1			; 右ボタン（1：ＯＦＦ／0：ＯＮ）
	JNE	USERWAIT_EXIT		;
	JMP	USERWAIT_LOOP		;
USERWAIT_EXIT:
	CALLE	MSCSTP			; カーソルストップ
	RET
USERWAIT_DEMO:
	RET
USERWAIT	ENDP


; ****************************************************
;	漢字文字詰め処理
;	-I- DS:[SI]  : 文字列
;	    CX       : 詰める長さ
; ****************************************************

KANJITUME	PROC	NEAR
	MOV	KANJI_STR_ADRS,SI	; 文字列アドレス
	MOV	KANJI_LEN_MAX,CX	; 表示文字の最長

	MOV	DI,KANJI_STR_ADRS	; 文字列アドレス
	MOVX	ES,DS			;
	CALLE	STRLENSPZ		; 文字列長さスペースまで
	CMP	CX,KANJI_LEN_MAX	; 表示文字の最長
	JLE	KANJITUME_6		;

	MOV	SI,KANJI_STR_ADRS	; 文字列アドレス
	ADD	SI,2			;
	CALL	KANJICHOT		; 漢字文字列をちょっとだけ半角に詰める

	MOV	DI,KANJI_STR_ADRS	; 文字列アドレス
	MOVX	ES,DS			;
	CALLE	STRLENSPZ		; 文字列長さスペースまで
	CMP	CX,KANJI_LEN_MAX	; 表示文字の最長
	JLE	KANJITUME_6		;

	MOV	SI,KANJI_STR_ADRS	; 文字列アドレス
	ADD	SI,2			;
	CALL	KANJISHORT		; 漢字文字列を半角に詰める
KANJITUME_6:
	RET
KANJITUME	ENDP

; ****************************************************
;	漢字文字列を半角に詰める
;	-I- DS:[SI]  : 文字列
; ****************************************************

KANJISHORT	PROC	NEAR
	MOV	AX,DS
	MOV	ES,AX

	MOV	BX,SI			; BX=書き込みポインタ
KANJISHORT_LOOP:
	LODSW				; AX=漢字文字
	CMP	AL,0			;
	JE	KANJISHORT_EXIT		;

	MOV	DX,AX			; character code.
	CALL	SJISCHK			; シフトＪＩＳチェック
	CMP	AX,0			; 0=normal,1=shift jis code.
	JE	KANJISHORT_MOV_BYTE	;

	MOV	AX,DX			; character code.

	MOV	DI,OFFSET ZENHAN_Z_ST	; 辞書・変換前
	MOV	CX,OFFSET ZENHAN_Z_ED
	SUB	CX,OFFSET ZENHAN_Z_ST
	SHR	CX,1			; word counter.
	REPNE	SCASW			; 該当半角はあるか？
	JNE	KANJISHORT_MOV		;

	DEC	DI
	DEC	DI
	SUB	DI,OFFSET ZENHAN_Z_ST	; 辞書・何番目か？
	SHR	DI,1			; word -> byte.
	MOV	AL,DS:ZENHAN_HAN[DI]	; 辞書・変換後
	MOV	DS:[BX],AL		; BX=書き込みポインタ
	INC	BX
	JMP	KANJISHORT_NEXT		;
KANJISHORT_MOV:
	MOV	DS:[BX],AX		; BX=書き込みポインタ
	INC	BX			;
	INC	BX			;
	JMP	KANJISHORT_NEXT		;
KANJISHORT_MOV_BYTE:
	MOV	DS:[BX],DL		; BX=書き込みポインタ
	DEC	SI
	INC	BX
KANJISHORT_NEXT:
	JMP	KANJISHORT_LOOP

KANJISHORT_EXIT:
	MOV	BYTE PTR DS:[BX],0	; end of string.
	RET
KANJISHORT	ENDP


; ****************************************************
;	漢字文字列をちょっとだけ半角に詰める
;	-I- DS:[SI]  : 文字列
; ****************************************************

KANJICHOT	PROC	NEAR
	MOV	AX,DS
	MOV	ES,AX

	MOV	BX,SI			; BX=書き込みポインタ
KANJICHOT_LOOP:
	LODSW				; AX=漢字文字
	CMP	AL,0			;
	JE	KANJICHOT_EXIT		;

	MOV	DX,AX			; character code.
	CALL	SJISCHK			; シフトＪＩＳチェック
	CMP	AX,0			; 0=normal,1=shift jis code.
	JE	KANJICHOT_MOV_BYTE	;

	MOV	AX,DX			; character code.

	MOV	DI,OFFSET ZENHAN_Z_HF	; 辞書・変換前
	MOV	CX,OFFSET ZENHAN_Z_ED
	SUB	CX,OFFSET ZENHAN_Z_HF
	SHR	CX,1			; word counter.
	REPNE	SCASW			; 該当半角はあるか？
	JNE	KANJICHOT_MOV		;

	DEC	DI
	DEC	DI
	SUB	DI,OFFSET ZENHAN_Z_HF	; 辞書・何番目か？
	SHR	DI,1			; word -> byte.
	MOV	AL,DS:ZENHAN_HAN_HF[DI]	; 辞書・変換後
	MOV	DS:[BX],AL		; BX=書き込みポインタ
	INC	BX
	JMP	KANJICHOT_NEXT		;
KANJICHOT_MOV:
	MOV	DS:[BX],AX		; BX=書き込みポインタ
	INC	BX
	INC	BX
	JMP	KANJICHOT_NEXT		;
KANJICHOT_MOV_BYTE:
	MOV	DS:[BX],DL		; BX=書き込みポインタ
	DEC	SI
	INC	BX
KANJICHOT_NEXT:
	JMP	KANJICHOT_LOOP

KANJICHOT_EXIT:
	MOV	BYTE PTR DS:[BX],0	; end of string.
	RET
KANJICHOT	ENDP

CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	USERDEMO		; (USERTOOL.ASM)デモフラグ
				; 0=通常,55=ランダムセレクト

USERDEMO	DW	0	;デモフラグ0=通常,55=ランダムセレクト

KANJI_LEN_MAX	DW	0	; 表示文字の最長
KANJI_STR_ADRS	DW	0	; 文字列アドレス

ZENHAN_Z_ST	LABEL	WORD
	DB	"アイウエオカキクケコサシスセソタチツテトナニヌネノ"
	DB	"ハヒフヘホマミムメモヤユヨラリルレロワヲン"
ZENHAN_Z_HF	LABEL	BYTE
	DB	"ァィゥェォャュョッー－・"
ZENHAN_Z_ED	LABEL	WORD
ZENHAN_HAN	LABEL	BYTE
	DB	"ｱｲｳｴｵｶｷｸｹｺｻｼｽｾｿﾀﾁﾂﾃﾄﾅﾆﾇﾈﾉﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜｦﾝ"
ZENHAN_HAN_HF	LABEL	BYTE
	DB	"ｧｨｩｪｫｬｭｮｯｰ-･",0

DATA	ENDS

	END
;
;	end of "USERTOOL.ASM"
;
