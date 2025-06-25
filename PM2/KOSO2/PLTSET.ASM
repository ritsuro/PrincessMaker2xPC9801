; "PLTSET.ASM" PC-9801UV11 make by R.H 1989/12/08
;
;
;	パレット操作
;
;
; public table.


;*DBG*;INCLUDE	TSTSET.INC


DMP	MACRO
;*DBG*;	PUSH	AX
;*DBG*;	PUSH	BX
;*DBG*;	PUSH	CX
;*DBG*;	PUSH	DX
;*DBG*;	PUSH	BP
;*DBG*;	PUSH	SI
;*DBG*;	PUSH	DI
;*DBG*;	PUSH	ES
;*DBG*;
;*DBG*;	PR	"C	"
;*DBG*;	MOV	DX,CLRCDE
;*DBG*;	CALL	DECSTR
;*DBG*;	CALL	PRINT
;*DBG*;	PR	"V	"
;*DBG*;	MOV	DX,CLRVEW
;*DBG*;	CALL	DECSTR
;*DBG*;	CALL	PRINT
;*DBG*;	PR	"N	"
;*DBG*;	MOV	DX,CLRCNS
;*DBG*;	CALL	DECSTR
;*DBG*;	CALL	PRINT
;*DBG*;	PR	"B	"
;*DBG*;	MOV	DX,CLRBRI
;*DBG*;	CALL	DECSTR
;*DBG*;	CALL	PRINT
;*DBG*;	LF
;*DBG*;	POP	ES
;*DBG*;	POP	DI
;*DBG*;	POP	SI
;*DBG*;	POP	BP
;*DBG*;	POP	DX
;*DBG*;	POP	CX
;*DBG*;	POP	BX
;*DBG*;	POP	AX
ENDM


CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	C1PLSET		; パレットセット
PUBLIC	C1PLGET		; パレットＧＥＴ
PUBLIC	C1PLPUT		; パレットＰＵＴ
PUBLIC	C1PLPSET	; パレット編集セット
PUBLIC	C1PL1PUT	; パレット単色ＰＵＴ

EXTRN	C1SETCLR:NEAR		; color table set.
EXTRN	C1CLRVSET:NEAR		; color palet table disply.

;	メッセージ突入モード
;	-I- DX : 0=ノーマル,1=真っ黒,2=真っ白

FAR_DKCMMD	PROC	FAR
;*;	CALL	DKCMMD		; メッセージ突入モード
	RET
FAR_DKCMMD	ENDP


;	パレットセット
;	-I- BX     : パレットテーブル番号
;
;	    CRTSKP : パレット編集処理のスキップ(1=ｽｷｯﾌﾟ)（普段は使わないよ）

C1PLSET	PROC	NEAR
	PUSH	BX

	MOV	AX,SEG PALET	; パレットテーブル
	MOV	ES,AX		;

	MOV	DI,BX		; アドレステーブルオフセット
	SHL	DI,1		;
	SHL	DI,1		;*4

	MOV	SI,0		; color table pointer.
	CALL	PLSET8COL	; 最初の８色

	INC	DI		; アドレステーブルオフセット
	INC	DI		;+2

	MOV	SI,0		; color table pointer.
	CALL	PLSET8COL	; 残りの８色

	MOV	DX,0			; 0=ノーマル,1=真っ黒,2=真っ白
	CALL	FAR_DKCMMD		; メッセージ突入モード

	POP	BX
	RET

PLSET8COL:		; -I- DI : アドレステーブルオフセット
	MOV	CX,8
PLSET2:
	MOV	BX,ES:PLTNUM[DI] ; ハードパレットテーブル
	MOV	AX,ES:[SI][BX]	;
	MOV	CLRCDE,AX	; color code.

	MOV	BX,AX		; ソフトカラーコード
	SHL	BX,1		; word pointer.
	CMP	CRTSKP[BX],1	; パレット編集処理のスキップ(1=ｽｷｯﾌﾟ)
	JE	PLSET7		;

	MOV	BX,ES:PLTOFS[DI] ; パレットアドレステーブル（色相）
	MOV	AX,ES:[SI][BX]	;
	MOV	CLRVEW,AX	; color.

	MOV	BX,ES:PCNOFS[DI] ; パレットアドレステーブル（彩度）
	MOV	AX,ES:[SI][BX]	;
	MOV	CLRCNS,AX	; contrast.

	MOV	BX,ES:PBROFS[DI] ; パレットアドレステーブル（明度）
	MOV	AX,ES:[SI][BX]	;
	MOV	CLRBRI,AX	; brightness.


	DMP	; デバック


	PUSH	SI
	PUSH	DI
	PUSH	CX
	CALL	C1SETCLR	; color table set.
	POP	CX
	POP	DI
	POP	SI

PLSET7:				;
	INC	SI		; カラーテーブルオフセット
	INC	SI		;

	DEC	CX
	JZ	PLSET_LOOP_END
	JMP	PLSET2
PLSET_LOOP_END:

	PUSH	ES			;
	PUSH	DI			;
	CALL	C1CLRVSET		; color palet table disply.
	POP	DI			;
	POP	ES			;

	RET
C1PLSET	ENDP



;	パレットＧＥＴ
;	-I- BX : パレットテーブル番号
;	-O- CRTVEW[0-15]:word : 色相回転（０ー３６０）
;	    CRTCNS[0-15]:word : 彩度倍率（０ー１００）
;	    CRTBRI[0-15]:word : 明度倍率（０ー１００）
;	    CRTCDE[0-15]:word : ハードパレットテーブル

C1PLGET	PROC	NEAR
	PUSH	BX

	MOV	AX,SEG PALET	; パレットテーブル
	MOV	ES,AX		;

	MOV	BP,0		; テーブルポインタ

	MOV	DI,BX		; アドレステーブルオフセット
	SHL	DI,1		;
	SHL	DI,1		;*4

	MOV	SI,0		; color table pointer.
	CALL	PLGET8COL	; 最初の８色

	INC	DI		; アドレステーブルオフセット
	INC	DI		;+2

	MOV	SI,0		; color table pointer.
	CALL	PLGET8COL	; 残りの８色

	POP	BX
	RET

PLGET8COL:		; -I- DI : アドレステーブルオフセット
			;     BP : テーブルポインタ
	MOV	CX,8
PLGET2:
	MOV	BX,ES:PLTNUM[DI] ; ハードパレットテーブル
	MOV	AX,ES:[SI][BX]	;
	MOV	CLRCDE,AX	; color code.

	MOV	BX,ES:PLTOFS[DI] ; パレットアドレステーブル（色相）
	MOV	AX,ES:[SI][BX]	;
	MOV	CLRVEW,AX	; color.

	MOV	BX,ES:PCNOFS[DI] ; パレットアドレステーブル（彩度）
	MOV	AX,ES:[SI][BX]	;
	MOV	CLRCNS,AX	; contrast.

	MOV	BX,ES:PBROFS[DI] ; パレットアドレステーブル（明度）
	MOV	AX,ES:[SI][BX]	;
	MOV	CLRBRI,AX	; brightness.


	DMP	; デバック


	MOV	BX,BP		; テーブルポインタ
	INC	BP		;
	INC	BP		;
	MOV	AX,CLRVEW	 ; color.
	MOV	DS:CRTVEW[BX],AX ; 色相回転（０ー３６０）
	MOV	AX,CLRCNS	 ; contrast.
	MOV	DS:CRTCNS[BX],AX ; 彩度倍率（０ー１００）
	MOV	AX,CLRBRI	 ; brightness.
	MOV	DS:CRTBRI[BX],AX ; 明度倍率（０ー１００）
	MOV	AX,CLRCDE	 ; ハードパレットテーブル
	MOV	DS:CRTCDE[BX],AX ; color code.

	INC	SI		; カラーテーブルオフセット
	INC	SI		;

	DEC	CX
	JZ	PLGET2_LOOP_END
	JMP	PLGET2
PLGET2_LOOP_END:
	RET
C1PLGET	ENDP



;	パレットＰＵＴ
;	-I- BX : パレットテーブル番号
;	    CRTVEW[0-15]:word : 色相回転（０ー３６０）
;	    CRTCNS[0-15]:word : 彩度倍率（０ー１００）
;	    CRTBRI[0-15]:word : 明度倍率（０ー１００）
;	    CRTCDE[0-15]:word : ハードパレットテーブル

C1PLPUT	PROC	NEAR
	PUSH	BX

	MOV	AX,SEG PALET	; パレットテーブル
	MOV	ES,AX		;

	MOV	BP,0		; テーブルポインタ

	MOV	DI,BX		; アドレステーブルオフセット
	SHL	DI,1		;
	SHL	DI,1		;*4

	MOV	SI,0		; color table pointer.
	CALL	PLPUT8COL	; 最初の８色

	INC	DI		; アドレステーブルオフセット
	INC	DI		;+2

	MOV	SI,0		; color table pointer.
	CALL	PLPUT8COL	; 残りの８色

	POP	BX
	RET

PLPUT8COL:		; -I- DI : アドレステーブルオフセット
			;     BP : テーブルポインタ
	MOV	CX,8
PLPUT2:
	MOV	BX,BP		; テーブルポインタ
	INC	BP		;
	INC	BP		;
	MOV	AX,DS:CRTVEW[BX] ; 色相回転（０ー３６０）
	MOV	CLRVEW,AX	 ; color.
	MOV	AX,DS:CRTCNS[BX] ; 彩度倍率（０ー１００）
	MOV	CLRCNS,AX	 ; contrast.
	MOV	AX,DS:CRTBRI[BX] ; 明度倍率（０ー１００）
	MOV	CLRBRI,AX	 ; brightness.
	MOV	AX,DS:CRTCDE[BX] ; ハードパレットテーブル
	MOV	CLRCDE,AX	 ; color code.


	DMP	; デバック


	MOV	BX,ES:PLTNUM[DI] ; ハードパレットテーブル
	MOV	AX,CLRCDE	; color code.
	MOV	ES:[SI][BX],AX	;

	MOV	BX,ES:PLTOFS[DI] ; パレットアドレステーブル（色相）
	MOV	AX,CLRVEW	; color.
	MOV	ES:[SI][BX],AX	;

	MOV	BX,ES:PCNOFS[DI] ; パレットアドレステーブル（彩度）
	MOV	AX,CLRCNS	; contrast.
	MOV	ES:[SI][BX],AX	;

	MOV	BX,ES:PBROFS[DI] ; パレットアドレステーブル（明度）
	MOV	AX,CLRBRI	; brightness.
	MOV	ES:[SI][BX],AX	;

	INC	SI		; カラーテーブルオフセット
	INC	SI		;

	DEC	CX
	JZ	PLPUT_LOOP_END
	JMP	PLPUT2
PLPUT_LOOP_END:
	RET
C1PLPUT	ENDP



;	パレット編集セット
;	-I- BX     : パレットテーブル番号
;	    CRXVEW : 色相回転（０ー３６０）
;	    CRXCNS : 彩度倍率（０ー１００）
;	    CRXBRI : 明度倍率（０ー１００）
;	    CRXWHI : ホワイトレベル（０ー１００）
;	    CRTSKP : パレット編集処理のスキップ(1=ｽｷｯﾌﾟ)

C1PLPSET	PROC	NEAR
	PUSH	BX

	MOV	AX,SEG PALET	; パレットテーブル
	MOV	ES,AX		;

	MOV	DI,BX		; アドレステーブルオフセット
	SHL	DI,1		;
	SHL	DI,1		;*4

	MOV	SI,0		; color table pointer.
	CALL	PLPSET8COL	; 最初の８色

	INC	DI		; アドレステーブルオフセット
	INC	DI		;+2

	MOV	SI,0		; color table pointer.
	CALL	PLPSET8COL	; 残りの８色

	POP	BX
	RET

PLPSET8COL:		; -I- DI : アドレステーブルオフセット
			;     SI : カラーテーブルポインタ
	MOV	CX,8
PLPSET2:

	MOV	BX,ES:PLTNUM[DI] ; ハードパレットテーブル
	MOV	AX,ES:[SI][BX]	;
	MOV	CLRCDE,AX	; color code.

	MOV	BX,AX		; ソフトカラーコード
	SHL	BX,1		; word pointer.
	CMP	CRTSKP[BX],1	; パレット編集処理のスキップ(1=ｽｷｯﾌﾟ)
	JE	PLPSET7		;

	MOV	BX,ES:PLTOFS[DI] ; パレットアドレステーブル（色相）
	MOV	AX,ES:[SI][BX]	;
	CALL	ROTVEW		; 色相回転
	MOV	CLRVEW,AX	; color.

	MOV	BX,ES:PCNOFS[DI] ; パレットアドレステーブル（彩度）
	MOV	AX,ES:[SI][BX]	;
	CALL	MLTCNS		; 彩度倍率
	CALL	MLTWHC		; 彩度ホワイトレベル
	MOV	CLRCNS,AX	; contrast.

	MOV	BX,ES:PBROFS[DI] ; パレットアドレステーブル（明度）
	MOV	AX,ES:[SI][BX]	;
	CALL	MLTBRI		; 明度倍率
	CALL	MLTWHI		; 明度ホワイトレベル
	MOV	CLRBRI,AX	; brightness.

	PUSH	SI
	PUSH	DI
	PUSH	CX
	CALL	C1SETCLR	; color table set.
	POP	CX
	POP	DI
	POP	SI

PLPSET7:			;
	INC	SI		; カラーテーブルオフセット
	INC	SI		;

	LOOP	PLPSET2

	PUSH	ES			;
	PUSH	DI			;
	CALL	C1CLRVSET		; color palet table disply.
	POP	DI			;
	POP	ES			;

	RET
C1PLPSET	ENDP


;	パレット単色ＰＵＴ
;	-I- BX     : パレットテーブル番号
;	    CX     : パレット番号
;	    CLRVEW : color.
;	    CLRCNS : contrast.
;	    CLRBRI : brightness.

C1PL1PUT	PROC	NEAR
	MOV	AX,SEG PALET		; パレットテーブル
	MOV	ES,AX			;

	MOV	DI,BX			; アドレステーブルオフセット
	SHL	DI,1			;
	SHL	DI,1			; * 4

	MOV	SI,CX			; パレット番号

	CMP	CX,8			; if cx >= 8 then di=di+2 si=si-8
	JB	C1PL1PUT_5		;
	INC	DI			; アドレステーブルオフセット
	INC	DI			; + 2
	SUB	SI,8			; - 8
C1PL1PUT_5:				;

	SHL	SI,1			; word pointer.

	MOV	BX,ES:PLTOFS[DI]	; パレットアドレステーブル（色相）
	MOV	AX,CLRVEW		; color.
	MOV	ES:[SI][BX],AX		;

	MOV	BX,ES:PCNOFS[DI]	; パレットアドレステーブル（彩度）
	MOV	AX,CLRCNS		; contrast.
	MOV	ES:[SI][BX],AX		;

	MOV	BX,ES:PBROFS[DI]	; パレットアドレステーブル（明度）
	MOV	AX,CLRBRI		; brightness.
	MOV	ES:[SI][BX],AX		;

	RET
C1PL1PUT	ENDP


;	色相回転
;	-I/O- AX : 色相（０ー３６０）

ROTVEW	PROC	NEAR
	ADD	AX,CRXVEW	; 色相回転（０ー３６０）
	CMP	AX,360
	JLE	ROTVEW3

	SUB	AX,360
ROTVEW3:
	RET
ROTVEW	ENDP


;	彩度倍率
;	-I/O- AX : 彩度（０ー１００）

MLTCNS	PROC	NEAR
	PUSH	BX
	PUSH	DX

	MOV	BX,CRXCNS	; 彩度倍率（０ー１００）
	IMUL	BX		; AX = AX * CRXCNS

	CWD
	MOV	BX,100		; １００で割る
	IDIV	BX		; AX = AX / 100

	POP	DX
	POP	BX
	RET
MLTCNS	ENDP


;	明度倍率
;	-I/O- AX : 明度（０ー１００）

MLTBRI	PROC	NEAR
	PUSH	BX
	PUSH	DX

	MOV	BX,CRXBRI	; 明度倍率（０ー１００）
	IMUL	BX		; AX = AX * CRXBRI

	CWD
	MOV	BX,100		; １００で割る
	IDIV	BX		; AX = AX / 100

	POP	DX
	POP	BX
	RET
MLTBRI	ENDP



;	彩度ホワイトレベル
;	-I/O- AX : 彩度（０ー１００）

MLTWHC	PROC	NEAR
	PUSH	BX
	PUSH	DX

	MOV	BX,100		;
	SUB	BX,CRXWHI	; ホワイトレベル（０ー１００）
	IMUL	BX		; AX = AX * CRXBRI

	CWD
	MOV	BX,100		; １００で割る
	IDIV	BX		; AX = AX / 100

	POP	DX
	POP	BX
	RET
MLTWHC	ENDP


;	明度ホワイトレベル
;	-I/O- AX : 明度（０ー１００）

MLTWHI	PROC	NEAR
	PUSH	BX
	PUSH	DX

	MOV	BX,100		;
	SUB	BX,CRXWHI	; ホワイトレベル（０ー１００）
	IMUL	BX		; AX = AX * CRXBRI

	CWD
	MOV	BX,100		; １００で割る
	IDIV	BX		; AX = AX / 100
	ADD	AX,CRXWHI	; ホワイトレベル（０ー１００）

	POP	DX
	POP	BX
	RET
MLTWHI	ENDP



CODE01	ENDS



PALET	SEGMENT	PUBLIC	'PALET'

EXTRN	PLTNUM:WORD		; ハードパレットテーブル
EXTRN	PLTOFS:WORD		; パレットアドレステーブル（色相）
EXTRN	PCNOFS:WORD		; パレットアドレステーブル（彩度）
EXTRN	PBROFS:WORD		; パレットアドレステーブル（明度）

PALET	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	CRXVEW		; 色相回転（０ー３６０）
PUBLIC	CRXCNS		; 彩度倍率（０ー１００）
PUBLIC	CRXBRI		; 明度倍率（０ー１００）
PUBLIC	CRXWHI		; ホワイトレベル（０ー１００）

PUBLIC	CRTVEW		; 色相回転（０ー３６０）
PUBLIC	CRTCNS		; 彩度倍率（０ー１００）
PUBLIC	CRTBRI		; 明度倍率（０ー１００）
PUBLIC	CRTCDE		; ハードパレットテーブル
PUBLIC	CRTSKP		; パレット編集処理のスキップ(1=ｽｷｯﾌﾟ)

EXTRN	CLRCDE:WORD	; color code.カラーコード
EXTRN	CLRVEW:WORD	; color view.色相
EXTRN	CLRCNS:WORD	; contrast.  彩度
EXTRN	CLRBRI:WORD	; brightness.明度

CRXVEW	DW	0	; 色相回転（０ー３６０）
CRXCNS	DW	100	; 彩度倍率（０ー１００）
CRXBRI	DW	100	; 明度倍率（０ー１００）
CRXWHI	DW	0	; ホワイトレベル（０ー１００）

CRTVEW	DW	16 DUP (0) ; 色相回転（０ー３６０）
CRTCNS	DW	16 DUP (0) ; 彩度倍率（０ー１００）
CRTBRI	DW	16 DUP (0) ; 明度倍率（０ー１００）
CRTCDE	DW	16 DUP (0) ; color code.
CRTSKP	DW	16 DUP (0) ; パレット編集処理のスキップ(1=ｽｷｯﾌﾟ)

DATA	ENDS

	END
;
;	end of "PLTSET.ASM"
;
