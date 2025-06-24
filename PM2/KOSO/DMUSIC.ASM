; "DMUSIC.ASM" PC-9801UV11 make by R.H 1990/06/04
;
;
;	音楽セット
;
;	Professional Music Driver [P.M.D.] version 4.0 専用
;	.mmd player ver.1.5 専用
;
;	ＰＭＤ用の割り込みベクトルは、４０Ｈとしています。
;	ＭＭＤ用の割り込みベクトルは、４１Ｈとしています。
;
;	M_SETUP_PMD	; 音楽システムPMD起動
;	M_SETUP_MMD	; 音楽システムMMD起動
;	M_SETUP_OFF	; 音楽システム起動ドライバの終了
;	M_SETUP_MIDI	; 音楽システムMIDI設定
;	M_INIT		; 音楽システム初期処理
;	M_EXIT		; 音楽システム終了処理
;	M_PLAY		; 音楽演奏
;	M_PLAY_NM	; 音楽演奏(番号指定)
;	M_STOP		; 音楽停止
;	M_FDOT		; 音楽フェードアウト
;	M_SOUNDBORD_CHECK	; 音源の有無
;
; GAME subroutine.

INCLUDE	TSTSET.INC
INCLUDE	MACHINEX.INC

PCAT_CHECK	EQU	0
;;PCAT_CHECK	EQU	1

;	ＰＣ／ＡＴでＭＩＤＩテスト用のフラグ
;	強制的にＭＩＤＩのセットアップを行う。
;	使用時は"MMD.ASM"の
;	pc98	equ	1
;	を０にすること。


CHECK_MACHINE_SKIP	MACRO		; マシン別の処理スキップ
	LOCAL	L2			;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	L2			;
	RET
L2:
	ENDM

IN_FMBORD	MACRO	AA,NUM
;same;	IN	AL,NUM
	PUSH	DX
	MOV	DX,NUM			;
	CALL	IN_FMBORD_PORT		; in  prot FM sound bord.
	POP	DX
	ENDM

IN_MIDIBORD	MACRO	AA,NUM
;same;	IN	AL,NUM
	PUSH	DX
	MOV	DX,NUM			;
	CALL	IN_MIDIBORD_PORT	; in  prot MIDI bord.
	POP	DX
	ENDM

;	ＰＭＤ関連

MUSIC_START	EQU	00H	;		演奏の開始
MUSIC_STOP	EQU	01H	;		演奏の停止
FADEOUT		EQU	02H	;AL=speed	フェードアウトspped=1で最低速
EFFECT_ON	EQU	03H	;AL=efcnum	効果音の発音
EFFECT_OFF	EQU	04H	;		効果音の消音
GET_SYOUSETU	EQU	05H	;AL=syousetu	演奏開始して何小節目か
GET_MUSDAT_ADR	EQU	06H	;DS:DX=MDAT_ADR	曲データを読み込む場所
GET_TONDAT_ADR	EQU	07H	;DS:DX=TDAT_ADR	音色データの場所
GET_FOUT_VOL	EQU	08H	;AL=FOUT_VOL	255でFADEOUT終了
BOARD_CHECK	EQU	09H	;AL=BOARD_CHK	0であり/255でなし

PMDVECTOR	=	40h		;PMD用の割り込みベクトル
MMDVECTOR	=	41h		;MMD用の割り込みベクトル

PMD	MACRO	QQQQ
	PUSH	DS
	MOV	AH,QQQQ
	INT	40H
	POP	DS
	ENDM

MMD	MACRO	QQQQ
	PUSH	DS
	MOV	AH,QQQQ
	INT	41H
	POP	DS
	ENDM

FO_SPEED	EQU	3	; フェードアウトスピード　（1で最低速）
FO_SPEED_MIDI	EQU	3	; フェードアウトスピード　（1で最低速）

PATH_STRING_LEN	EQU	20	; path string length.

@code	segment	public	"@code"
	assume	cs:@code,ds:@code
EXTRN	pmdsrt:FAR		; ＰＭＤ初期化
EXTRN	mmdsrt:FAR		; ＭＭＤ初期化
EXTRN	pmdopn_reset:FAR
EXTRN	pmd_data_top:BYTE	; PMD data area top.
EXTRN	pmd_data_mdata_end:BYTE	; PMD music area end.
EXTRN	pmd_data_end:BYTE	; PMD data area end.
@code	ends

EXTRN	FAR_BBERRORPR:FAR	; (far)error message.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	M_SETUP_PMD		; 音楽システムPMD起動
PUBLIC	M_SETUP_MMD		; 音楽システムMMD起動
PUBLIC	M_SETUP_OFF		; 音楽システム起動ドライバの終了
PUBLIC	M_SETUP_MIDI		; 音楽システムMIDI設定
PUBLIC	M_INIT			; 音楽システム初期処理
PUBLIC	M_EXIT			; 音楽システム終了処理
PUBLIC	M_PLAY			; 音楽演奏
PUBLIC	M_PLAY_NM		; 音楽演奏(番号指定)
PUBLIC	M_STOP			; 音楽停止
PUBLIC	M_FDOT			; 音楽フェードアウト
PUBLIC	M_SOUNDBORD_CHECK	; 音源の有無
PUBLIC	M_TIMER			; 音楽用ﾀｲﾏｰｾｯﾄ
PUBLIC	M_TIMER2		; ｴﾝﾃﾞｨﾝｸﾞ音楽用ﾀｲﾏｰｾｯﾄ2
PUBLIC	M_TIMER2WAIT		; ｴﾝﾃﾞｨﾝｸﾞ音楽用ﾀｲﾏｰWAIT


PUBLIC	INTMUS			; 音楽効果処理割込み(V-SYNC)

EXTRN	IN_FMBORD_PORT:NEAR	; in  prot FM sound bord.
EXTRN	IN_MIDIBORD_PORT:NEAR	; in  prot MIDI bord.

EXTRN	DISKLD:NEAR		; disk load.

EXTRN	TMVST2:NEAR		; V-SYNC timer2 set.
EXTRN	TMVST7:NEAR		; V-SYNC timer7 set.(wwanime.asm/ending)
EXTRN	TMVCK7:NEAR		; V-SYNC timer7 check.



;	音楽システムPMD起動

M_SETUP_PMD	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JNE	M_SETUP_PMD_EXIT	;

	MOV	FLAG_FM_ENABLE,0	; flag FM sound enable.

	CALL	pmdsrt			; ＰＭＤ初期化

	MOV	FLAG_FM_ENABLE,1	; flag FM sound enable.

	CALLE	SNDINI		; 効果音初期処理(DMUSIC.ASMから呼び出し)

M_SETUP_PMD_EXIT:
	RET
M_SETUP_PMD	ENDP


;	音楽システムMMD起動

M_SETUP_MMD	PROC	NEAR
if	PCAT_CHECK
else
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JNE	M_SETUP_MMD_EXIT	;
endif
	MOV	FLAG_MIDI_ENABLE,0	; flag midi enable.

	CALL	mmdsrt			; ＭＭＤ初期化
	JC	M_SETUP_MMD_EXIT	; if cf=on then error.

	MOV	FLAG_MIDI_ENABLE,1	; flag midi enable.

M_SETUP_MMD_EXIT:
	RET
M_SETUP_MMD	ENDP


;	音楽システム起動ドライバの終了

M_SETUP_OFF	PROC	NEAR
	CMP	FLAG_FM_ENABLE,0	; flag FM sound enable.
	JE	M_SETUP_OFF_EXIT	;
	CALL	pmdopn_reset
	MOV	FLAG_FM_ENABLE,0	; flag FM sound enable.
M_SETUP_OFF_EXIT:
	RET
M_SETUP_OFF	ENDP


;	音楽システムMIDI設定
;	-I- AX : 0=MT,1=GM

M_SETUP_MIDI	PROC	NEAR
	MOV	MIDI_SOUND_UNIT,AX	; MIDIに接続されているｻｳﾝﾄﾞﾕﾆｯﾄ種別
	RET
M_SETUP_MIDI	ENDP


;	音楽システム初期処理

M_INIT	PROC	NEAR
	MOV	FOUT_TIMER,0		; フェードアウト時間
	MOV	NOW_MUSIC_NUM,0		; 演奏中の音楽番号

	CMP	FLAG_FM_ENABLE,1	; flag FM sound enable.
	JNE	M_INIT_2		;
	MOV	MUSIC_ONOFF,1		; 音楽機能のＯＮ／ＯＦＦ

	PMD	MUSIC_STOP		; 演奏の停止
M_INIT_2:

	CMP	FLAG_MIDI_ENABLE,1	; flag midi enable.
	JNE	M_INIT_5		;
	MOV	MUSIC_ONOFF,1		; 音楽機能のＯＮ／ＯＦＦ

	MMD	MUSIC_STOP		; 演奏の停止
M_INIT_5:

	CALL	GET_ADRS		; ＰＭＤアドレスを取得する

	MOV	AX,OFFSET pmd_data_mdata_end	; PMD music area end.
	SUB	AX,OFFSET pmd_data_top	; PMD data area top.
	MOV	LOAD_LENGTH,AX		; データ読み込み長さ

	RET
M_INIT	ENDP


;	音楽システム終了処理

M_EXIT	PROC	NEAR
	CMP	MUSIC_ONOFF,0		; 音楽機能のＯＮ／ＯＦＦ
	JE	M_EXIT_EXIT		;

	MOV	MUSIC_ONOFF,0		; 音楽機能のＯＮ／ＯＦＦ
	MOV	FOUT_TIMER,0		; フェードアウト時間

	CMP	FLAG_MIDI_ENABLE,1	; flag midi enable.
	JE	M_EXIT_5		;

	CMP	FLAG_FM_ENABLE,1	; flag FM sound enable.
	JNE	M_EXIT_EXIT		;

	PMD	MUSIC_STOP		; 演奏の停止
	JMP	M_EXIT_EXIT		;
M_EXIT_5:
	MMD	MUSIC_STOP		; 演奏の停止
M_EXIT_EXIT:
	RET
M_EXIT	ENDP


;	音楽演奏
;	-I- DS:SI : 曲データファイル名

M_PLAY	PROC	NEAR
	CMP	MUSIC_ONOFF,0		; 音楽機能のＯＮ／ＯＦＦ
	JNE	M_PLAY_START		;
	RET
M_PLAY_START:
	MOV	FOUT_TIMER,0		; フェードアウト時間

	CALL	PAT_FLNSET		; 音楽ファイル名セット

	CMP	FLAG_MIDI_ENABLE,1	; flag midi enable.
	JE	L11			;

	CMP	FLAG_FM_ENABLE,1	; flag FM sound enable.
	JNE	M_PLAY_EXIT		;

	PMD	MUSIC_STOP		; 演奏の停止
	JMP	L12			;
L11:
	MMD	MUSIC_STOP		; 演奏の停止
L12:
	MOV	SI,OFFSET FLPNAM	; ファイル名
	MOV	DX,SEG_KYOKU		; 曲データセグメント
	MOV	DI,ADRS_KYOKU		; 曲データアドレス
	MOV	CX,LOAD_LENGTH		; データ読み込み長さ
	CALL	DISKLD			; disk load.
	CMP	AX,0			; 0=normal,1=error.
	JNE	M_PLAY_ERROR		;

	CMP	FLAG_MIDI_ENABLE,1	; flag midi enable.
	JE	L13			;

	CMP	FLAG_FM_ENABLE,1	; flag FM sound enable.
	JNE	M_PLAY_EXIT		;

	PMD	MUSIC_START		; 演奏の開始
	JMP	M_PLAY_EXIT		;
L13:
	MMD	MUSIC_START		; 演奏の開始
M_PLAY_EXIT:
	RET
M_PLAY_ERROR:
	MOV	SI,OFFSET FLPNAM	; ファイル名
	MOV	FLAGERROR,123		; error flag.
	CALL	FAR_BBERRORPR		; (far)error message.
	RET
M_PLAY	ENDP


;	音楽演奏(番号指定)
;	-I- DX : 音楽番号(1000以上はﾌﾞﾘｯｼﾞ)

M_PLAY_NM	PROC	NEAR
	CMP	NOW_MUSIC_NUM,DX	; 演奏中の音楽番号
	JE	M_PLAY_NM_SKIP		;

	MOV	MUSIC_NUM,DX		; 音楽番号(1000以上はﾌﾞﾘｯｼﾞ)
	MOV	NOW_MUSIC_NUM,DX	; 演奏中の音楽番号

	CALL	MUSIC_FLNSET		; 音楽ファイル名セット

	MOV	SI,OFFSET FLNAME	; 音楽ファイル名
	CALL	M_PLAY			; 音楽演奏
M_PLAY_NM_SKIP:
	RET
M_PLAY_NM	ENDP


;	音楽停止

M_STOP	PROC	NEAR
	CMP	MUSIC_ONOFF,0		; 音楽機能のＯＮ／ＯＦＦ
	JNE	M_STOP_START		;
	RET
M_STOP_START:
	MOV	NOW_MUSIC_NUM,0		; 演奏中の音楽番号

	CMP	FLAG_MIDI_ENABLE,1	; flag midi enable.
	JE	L21			;

	CMP	FLAG_FM_ENABLE,1	; flag FM sound enable.
	JNE	L22			;

	PMD	MUSIC_STOP		; 演奏の停止
	JMP	L22			;
L21:
	MMD	MUSIC_STOP		; 演奏の停止
L22:
	MOV	FOUT_TIMER,0		; フェードアウト時間
	RET
M_STOP	ENDP


;	音楽フェードアウト

M_FDOT	PROC	NEAR
	CMP	MUSIC_ONOFF,0		; 音楽機能のＯＮ／ＯＦＦ
	JNE	M_FDOT_START		;
	RET
M_FDOT_START:
	MOV	NOW_MUSIC_NUM,0		; 演奏中の音楽番号

	CMP	FLAG_MIDI_ENABLE,1	; flag midi enable.
	JE	M_FDOT_START31		;

	CMP	FLAG_FM_ENABLE,1	; flag FM sound enable.
	JNE	M_FDOT_EXIT		;

	MOV	AL,FO_SPEED		; フェードアウトスピード
	PMD	FADEOUT			; フェードアウト
	JMP	M_FDOT_START32		;
M_FDOT_START31:
	MOV	AL,FO_SPEED_MIDI	; フェードアウトスピード(1で最低速)
	MMD	FADEOUT			; フェードアウト
M_FDOT_START32:
	MOV	AX,FOUT_LENGTH		; フェードアウト時間長
	MOV	FOUT_TIMER,AX		; フェードアウト時間
M_FDOT_EXIT:
	RET
M_FDOT	ENDP


;	音源の有無
;	-O- FLAG_FM_BORD   : FM音源ﾎﾞｰﾄﾞの有無
;	    FLAG_MIDI_BORD : MIDIｲﾝﾀｰﾌｪｰｽﾎﾞｰﾄﾞの有無

	DB	"MIDI BORD CHECK.",0
M_SOUNDBORD_CHECK	PROC	NEAR
if	PCAT_CHECK
	MOV	FLAG_MIDI_BORD,1	; MIDIｲﾝﾀｰﾌｪｰｽﾎﾞｰﾄﾞの有無
	RET
endif
	CHECK_MACHINE_SKIP		; マシン別の処理スキップ

	MOV	FLAG_FM_BORD,0		; FM音源ﾎﾞｰﾄﾞの有無
	MOV	FLAG_MIDI_BORD,0	; MIDIｲﾝﾀｰﾌｪｰｽﾎﾞｰﾄﾞの有無

	IN_FMBORD	AL,188H
	CMP	AL,0FFH
	JNE	SOUNDBORD_CHECK_4
	IN_FMBORD	AL,88H
	CMP	AL,0FFH
	JE	SOUNDBORD_CHECK_5
SOUNDBORD_CHECK_4:
	MOV	FLAG_FM_BORD,1		; FM音源ﾎﾞｰﾄﾞの有無
SOUNDBORD_CHECK_5:

					; ｹﾞﾝｻﾞｲ (MIDIｶﾞ ﾅｲ ﾊﾞｱｲ)
					; PC-386Mﾊ
	IN_MIDIBORD	AL,0E0D0H	; (0e0d0h)	0e8h
	CMP	AL,0E8H			;
	JNE	SOUNDBORD_CHECK_55	;

	IN_MIDIBORD	AL,0E0D2H	; (0e0d2h)	000h
	CMP	AL,000H			;
	JNE	SOUNDBORD_CHECK_55	;
	JMP	SOUNDBORD_CHECK_7	;
SOUNDBORD_CHECK_55:

	IN_MIDIBORD	AL,0E0D0H
	CMP	AL,0FFH
	JNE	SOUNDBORD_CHECK_6

	IN_MIDIBORD	AL,0E0D2H
	CMP	AL,0FFH
	JE	SOUNDBORD_CHECK_7
SOUNDBORD_CHECK_6:
	MOV	FLAG_MIDI_BORD,1	; MIDIｲﾝﾀｰﾌｪｰｽﾎﾞｰﾄﾞの有無
SOUNDBORD_CHECK_7:
	RET
M_SOUNDBORD_CHECK	ENDP


;	音楽用ﾀｲﾏｰｾｯﾄ
;	音楽無い時は
;	-I- AX : 1/60秒タイマー

M_TIMER	PROC	NEAR
	CMP	MUSIC_ONOFF,0		; 音楽機能のＯＮ／ＯＦＦ
	JNE	M_TIMER_2
	MOV	AX,0
M_TIMER_2:
	CALL	TMVST2			; V-SYNC timer2 set.
	RET
M_TIMER	ENDP


;	ｴﾝﾃﾞｨﾝｸﾞ音楽用ﾀｲﾏｰｾｯﾄ
;	音楽無い時は無し
;	-I- AX : 1/60秒タイマー

M_TIMER2	PROC	NEAR
	CMP	MUSIC_ONOFF,0		; 音楽機能のＯＮ／ＯＦＦ
	JNE	M_TIMER2_2
	MOV	AX,0
M_TIMER2_2:
	CALL	TMVST7			; V-SYNC timer7 set.(wwanime.asm/ending)
	RET
M_TIMER2	ENDP


;	ｴﾝﾃﾞｨﾝｸﾞ音楽用ﾀｲﾏｰWAIT

M_TIMER2WAIT	PROC	NEAR

M_TIMER2WAIT_LOOP:
	CALL	TMVCK7			; V-SYNC timer7 check.
	CMP	AX,0			; 0=timer now, 1=timer end.
	JE	M_TIMER2WAIT_LOOP
	RET
M_TIMER2WAIT	ENDP


;	ＰＭＤアドレスを取得する
;	-O- SEG_KYOKU  : 曲データセグメント
;	    ADRS_KYOKU : 曲データアドレス

GET_ADRS	PROC	NEAR
	CMP	FLAG_MIDI_ENABLE,1	; flag midi enable.
	JE	GET_ADRS_MIDI		;

	CMP	FLAG_FM_ENABLE,1	; flag FM sound enable.
	JNE	GET_ADRS_EXIT		;

	PUSH	DS
	MOV	AH,GET_MUSDAT_ADR	;DS:DX=MDAT_ADR	曲データを読み込む場所
	INT	PMDVECTOR		;
	MOV	AX,DS			; ＰＭＤの常駐しているセグメント
	POP	DS

	MOV	SEG_KYOKU,AX		; 曲データセグメント
	MOV	ADRS_KYOKU,DX		; 曲データアドレス
	RET

GET_ADRS_MIDI:
	PUSH	DS
	MOV	AH,GET_MUSDAT_ADR	;DS:DX=MDAT_ADR	曲データを読み込む場所
	INT	MMDVECTOR		;
	MOV	AX,DS			; ＭＭＤの常駐しているセグメント
	POP	DS

	MOV	SEG_KYOKU,AX		; 曲データセグメント
	MOV	ADRS_KYOKU,DX		; 曲データアドレス
	RET
GET_ADRS_EXIT:
	RET
GET_ADRS	ENDP


;	音楽効果処理割込み(V-SYNC)

INTMUS	PROC	NEAR
	CMP	FOUT_TIMER,0		; フェードアウト時間
	JNE	INTMUS_START		;
	RET				;
INTMUS_START:				;
	DEC	FOUT_TIMER		; フェードアウト時間
	JNZ	INTMUS_EXIT		;

	CMP	FLAG_MIDI_ENABLE,1	; flag midi enable.
	JE	L41			;

	CMP	FLAG_FM_ENABLE,1	; flag FM sound enable.
	JNE	INTMUS_EXIT		;

	PMD	MUSIC_STOP		; 演奏の停止
	JMP	L42			;
L41:
	MMD	MUSIC_STOP		; 演奏の停止
L42:

INTMUS_EXIT:
	RET
INTMUS	ENDP


;	音楽ファイル名セット
;	-I- MUSIC_NUM : 音楽番号(1000以上はﾌﾞﾘｯｼﾞ)
;	-O- FLNAME    : 音楽ファイル名

MUSIC_FLNSET	PROC	NEAR
	CMP	FLAG_MIDI_ENABLE,0	; flag MIDI enable.
	JE	MUSIC_FLNSET_FM		;

	CMP	MIDI_SOUND_UNIT,1	; MIDIに接続されているｻｳﾝﾄﾞﾕﾆｯﾄ種別
	JE	MUSIC_FLNSET_MIDI_GM	; 0=MT,1=GM

MUSIC_FLNSET_FM:			;
MUSIC_FLNSET_MIDI_MT:
	CMP	MUSIC_NUM,1000		; 音楽番号
	JNB	MUSIC_FLNSET_BRIGE	;

	MOV	DX,MUSIC_NUM		; 音楽番号
	MOV	AL,"P"			; header.
	CALL	NUM_TO_NAME		; number to name.
	RET

MUSIC_FLNSET_BRIGE:
	MOV	DX,MUSIC_NUM		; 音楽番号(1000以上はﾌﾞﾘｯｼﾞ)
	SUB	DX,1000			;
	MOV	AL,"B"			; header.
	CALL	NUM_TO_NAME		; number to name.
	RET

MUSIC_FLNSET_MIDI_GM:
	CMP	MUSIC_NUM,1000		; 音楽番号
	JNB	MUSIC_FLNSET_GM_BRIGE	;

	MOV	DX,MUSIC_NUM		; 音楽番号(1000以上はﾌﾞﾘｯｼﾞ)
	MOV	AL,"G"			; header.
	CALL	NUM_TO_NAME		; number to name.
	RET

MUSIC_FLNSET_GM_BRIGE:
	MOV	DX,MUSIC_NUM		; 音楽番号(1000以上はﾌﾞﾘｯｼﾞ)
	SUB	DX,1000			;
	MOV	AL,"B"			; header.
	CALL	NUM_TO_NAME		; number to name.

	MOVX	ES,DS			;
	MOV	DI,OFFSET FLNAME	; 音楽ファイル名
	CALLE	STRLENGTH		; 文字列長さ

	MOV	DI,OFFSET FLNAME	; 音楽ファイル名
	ADD	DI,CX			; 表示単語長さ
	MOV	WORD PTR DS:[DI],"G"	;

	RET
MUSIC_FLNSET	ENDP


;	number to name.
;	-I- DX : number.
;	    AL : header.
;	-O- FLNAME : 音楽ファイル名

NUM_TO_NAME	PROC	NEAR
	PUSH	AX
	CALL	DECSTR			;
	CALL	STRZTS			; zero to space. "00123" - > "  123"
	CALL	STRSPL			; space pless. "  123" - > "123  "
	POP	AX
	MOV	FLNAME,AL		; 音楽ファイル名
	MOV	DI,OFFSET FLNAME	;
	INC	DI			;
	MOV	CX,4			;
	MOVX	ES,DS			;
	CALLE	STRSETZ			; 文字列バッファセット
	RET
NUM_TO_NAME	ENDP



;	音楽ファイル名セット
;	-I- DS:SI  : ファイル名
;	-O- FLPNAM : ファイル名

PAT_FLNSET	PROC	NEAR
	MOV	AX,DS
	MOV	ES,AX

	MOV	DI,OFFSET FLPNAM	; ファイル名
	MOV	CX,PATH_STRING_LEN	; path string length.
L51:
	LODSB				;
	CMP	AL,' '			; end of string.
	JBE	L52			;
	STOSB				;
	LOOP	L51			;
L52:

	CMP	FLAG_MIDI_ENABLE,1	; flag midi enable.
	JE	PAT_FLNSET_MIDI		;

	MOV	AL,'.'			; add ".MMD"
	STOSB
	MOV	AL,'M'
	STOSB
	MOV	AL,0
	STOSB
	RET
PAT_FLNSET_MIDI:
	MOV	AL,'.'			; add ".MMD"
	STOSB
	MOV	AL,'M'
	STOSB
	MOV	AL,'M'
	STOSB
	MOV	AL,'D'
	STOSB
	MOV	AL,0
	STOSB
	RET
PAT_FLNSET	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	FLAG_FM_BORD			; FM音源ﾎﾞｰﾄﾞの有無
PUBLIC	FLAG_MIDI_BORD			; MIDIｲﾝﾀｰﾌｪｰｽﾎﾞｰﾄﾞの有無

EXTRN	FLAG_FM_ENABLE:WORD		; flag FM sound enable.
EXTRN	FLAG_MIDI_ENABLE:WORD		; flag MIDI enable.
EXTRN	FLAGERROR:WORD			; error flag.

MUSIC_NUM	DW	0		; 音楽番号
NOW_MUSIC_NUM	DW	0		; 演奏中の音楽番号

FLPNAM		DB	PATH_STRING_LEN DUP (0),0,0 ; ファイル名
FLNAME		DB	6 DUP (0),0,0	; 音楽ファイル名

		EVEN
MUSIC_ONOFF	DW	0		; 音楽機能のＯＮ／ＯＦＦ

SEG_KYOKU	DW	0		; 曲データセグメント
ADRS_KYOKU	DW	0		; 曲データアドレス
LOAD_LENGTH	DW	1024*6		; データ読み込み長さ

FOUT_LENGTH	DW	60*6		; フェードアウト時間長
FOUT_TIMER	DW	0		; フェードアウト時間

MIDI_SOUND_UNIT	DW	0		; MIDIに接続されているｻｳﾝﾄﾞﾕﾆｯﾄ種別
					; 0=MT,1=GM

FLAG_FM_BORD	DW	0		; FM音源ﾎﾞｰﾄﾞの有無
FLAG_MIDI_BORD	DW	0		; MIDIｲﾝﾀｰﾌｪｰｽﾎﾞｰﾄﾞの有無

DATA	ENDS

	END
;
;	end of "DMUSIC.ASM"
;
