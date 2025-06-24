; "DSOUND.ASM" PC-9801UV11 make by R.H 1992/01/23
;
;
;	効果音セット
;
;	Professional Music Driver [P.M.D.] version 4.0 専用
;
;	ＦＭ効果音版 1993/03/10
;
;	ＰＭＤ用の割り込みベクトルは、４０Ｈとしています。
;
;	SNDINI		; 効果音初期処理(DMUSIC.ASMから呼び出し)
;	SNDON		; 効果音発生 ( AX : 効果音番号 )
;	[停止]SNDRENON	; 連続効果音発生 (AX:効果音番号(0=OFF),BX:間隔時間)
;	[停止]SNDOFF	; 効果音停止
;
; GAME subroutine.

INCLUDE	NEFF.INC
INCLUDE	MACHINEX.INC
INCLUDE	TSTSET.INC

CHECK_MACHINE_SKIP	MACRO		; マシン別の処理スキップ
	LOCAL	L2			;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	L2			;
	RET
L2:
	ENDM

;	ＰＭＤ関連

GET_EFCDAT_ADR	EQU	0BH	;DS:DX=EDAT_ADR	FM効果音データの場所
FM_EFFECT_ON	EQU	0CH	;AL=efcnum	FM効果音発音
FM_EFFECT_OFF	EQU	0DH	;		FM効果音消音

PMDVECTOR	=	40h		;PMD用の割り込みベクトル
MMDVECTOR	=	41h		;MMD用の割り込みベクトル

PMD	MACRO	QQQQ
	PUSH	DS
	MOV	AH,QQQQ
	INT	40H
	POP	DS
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
	MOV	FLAGERROR,NUM	; error flag.
	CALL	FAR_BBERRORPR	; error message.
	ENDM

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	SNDINI		; 効果音初期処理(DMUSIC.ASMから呼び出し)
PUBLIC	SNDON		; 効果音発生
;*;PUBLIC SNDONX	; 連続効果音用フック(TIMER.ASM)
;*;PUBLIC SNDRENON	; 連続効果音発生
;*;PUBLIC SNDOFF	; 効果音停止
;*;EXTRN V98TMVSND:NEAR	; V-SYNC timer sound program call.

EXTRN	DISKLD:NEAR	; disk load.


;	効果音初期処理
;	DMUSIC.ASMから呼び出し
;	-O- AX : 0=normal,1=SE file not found.

SNDINI	PROC	NEAR
	CHECK_MACHINE_SKIP		; マシン別の処理スキップ

	PUSH	DS
	MOV	AH,GET_EFCDAT_ADR	;DS:DX=EDAT_ADR	FM効果音データの場所
	INT	PMDVECTOR		;
	MOV	AX,DS			; ＰＭＤの常駐しているセグメント
	POP	DS

	MOV	SEG_FMEFC,AX		; ＦＭ効果音ﾃﾞｰﾀｾｸﾞﾒﾝﾄ
	MOV	ADRS_FMEFC,DX		; ＦＭ効果音ﾃﾞｰﾀｱﾄﾞﾚｽ

	MOV	SI,OFFSET FLNAME_EFC	; 効果音ﾌｧｲﾙ名
	MOV	DX,SEG_FMEFC		; ＦＭ効果音ﾃﾞｰﾀｾｸﾞﾒﾝﾄ
	MOV	DI,ADRS_FMEFC		; ＦＭ効果音ﾃﾞｰﾀｱﾄﾞﾚｽ
	MOV	CX,LOAD_LENGTH		; データ読み込み長さ
	CALL	DISKLD			; disk load.
	CMP	AX,0			; 0=normal,1=error.
	JNE	SNDINI_ERROR		;

	MOV	AX,0
	RET
SNDINI_ERROR:
	MOV	SI,OFFSET FLNAME_EFC	; 効果音ﾌｧｲﾙ名
	BBERROR_FAR	120		; error flag.
	MOV	AX,1
	RET
SNDINI	ENDP


;	効果音発生
;	-I- AX : 効果音番号

SNDON	PROC	NEAR
	CHECK_MACHINE_SKIP	; マシン別の処理スキップ
	PMD	FM_EFFECT_ON	; FM効果音発音
	RET
SNDON	ENDP


;*;;	効果音発生
;*;;	-I- AX : 効果音番号
;*;
;*;SNDON	PROC	NEAR
;*;	CHECK_MACHINE_SKIP		; マシン別の処理スキップ
;*;
;*;	CMP	SOUND_ONOFF,0	; 効果音機能のＯＮ／ＯＦＦ
;*;	JNE	SNDON_START	;
;*;	RET
;*;SNDON_START:
;*;	CALL	SNDRENOFF	; 連続効果音停止
;*;
;*;	PMD	FM_EFFECT_ON	; FM効果音発音
;*;	RET
;*;SNDON	ENDP
;*;
;*;
;*;;	連続効果音用フック(V98TIMER.ASM)
;*;;	-I- AX : 効果音番号
;*;
;*;SNDONX	PROC	NEAR
;*;	CHECK_MACHINE_SKIP		; マシン別の処理スキップ
;*;
;*;	CMP	SOUND_ONOFF,0	; 効果音機能のＯＮ／ＯＦＦ
;*;	JNE	SNDONX_START	;
;*;	RET
;*;SNDONX_START:
;*;	PMD	FM_EFFECT_ON	; FM効果音発音
;*;	RET
;*;SNDONX	ENDP
;*;
;*;
;*;;	連続効果音発生
;*;;	-I- AX : 効果音番号(0=OFF)
;*;;	    BX : 間隔時間（Ｖ－ＳＹＮＣ）
;*;
;*;SNDRENON	PROC	NEAR
;*;	CHECK_MACHINE_SKIP		; マシン別の処理スキップ
;*;
;*;	CMP	SOUND_ONOFF,0	; 効果音機能のＯＮ／ＯＦＦ
;*;	JNE	SNDRENON_START	;
;*;	RET
;*;SNDRENON_START:
;*;	CALL	V98TMVSND	; V-SYNC timer sound program call.
;*;	RET
;*;SNDRENON	ENDP
;*;
;*;
;*;;	効果音停止
;*;
;*;SNDOFF	PROC	NEAR
;*;	CHECK_MACHINE_SKIP		; マシン別の処理スキップ
;*;
;*;	CMP	SOUND_ONOFF,0	; 効果音機能のＯＮ／ＯＦＦ
;*;	JNE	SNDOFF_START	;
;*;	RET
;*;SNDOFF_START:
;*;	CALL	SNDRENOFF	; 連続効果音停止
;*;	PMD	FM_EFFECT_OFF	; FM効果音消音
;*;	RET
;*;SNDOFF	ENDP
;*;
;*;
;*;;	連続効果音停止
;*;
;*;SNDRENOFF	PROC	NEAR
;*;	PUSH	AX
;*;	MOV	AX,0		; 効果音番号(0=OFF)
;*;	MOV	BX,0		; 間隔時間（Ｖ－ＳＹＮＣ）
;*;	CALL	V98TMVSND	; V-SYNC timer sound program call.
;*;	POP	AX
;*;	RET
;*;SNDRENOFF	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	SOUND_ONOFF			; 効果音機能のＯＮ／ＯＦＦ
SOUND_ONOFF	DW	1		; 効果音機能のＯＮ／ＯＦＦ

SEG_FMEFC	DW	0		; ＦＭ効果音ﾃﾞｰﾀｾｸﾞﾒﾝﾄ
ADRS_FMEFC	DW	0		; ＦＭ効果音ﾃﾞｰﾀｱﾄﾞﾚｽ
LOAD_LENGTH	DW	1248		; データ読み込み長さ

FLNAME_EFC	DB	"PM2EFC.EFC",0	; 効果音ﾌｧｲﾙ名

DATA	ENDS

	END
;
;	end of "DSOUND.ASM"
;
