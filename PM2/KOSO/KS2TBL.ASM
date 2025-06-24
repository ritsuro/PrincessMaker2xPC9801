; "KS2TBL.ASM" 486/50 make by R.H 1992/05/15
;
;
;	P R I N C E S S   M A K E R   2.
;
;	table set.
;
;
;	子プロセスは PROCBUF(process buffer) へロードされる。
;
;	子プロセス用ﾜｰｸﾊﾞｯﾌｧ PROCWRK(process work buffer) は
;	MUSYAE.COM によって使われるが、ICON使用時にICON.PT1が
;	ロードされるので充分注意すること。
;	ICON使用後はマップをRELOADすること。
;
;	またPROCWRKはﾊﾟｰﾂﾊﾞﾝｸ#16(子ﾌﾟﾛｾｽ用のﾜｰｸの後10Kbyte)
;	に一部使われる。これはICON使用時にICONﾃﾞｰﾀとぶつかるので
;	注意すること。
;
;	ﾊﾟｰﾂﾊﾞﾝｸ#16は訓練・仕事中のﾊﾟﾗﾒｰﾀ待避に使われる
;	ﾊﾟｰﾂﾊﾞﾝｸ#17は"JOB013.TXT"のﾊﾟﾗﾒｰﾀ待避に使われる
;	ﾊﾟｰﾂﾊﾞﾝｸ#18は"SSCOOK.TXT"のｳｲﾝﾄﾞｳ待避に使われる
;	ﾊﾟｰﾂﾊﾞﾝｸ#19,#20,#21はｴﾝﾃﾞｨﾝｸﾞ用です。
;	#22は"DSKTOOL.COM"用です
;	ﾊﾟｰﾂﾊﾞﾝｸ#23(52,200byte)は"JOB013.TXT","JOB014.TXT"の待避に使われる
;
;	TEXTBUF SEGMENT PUBLIC 'TEXTBUF' はＥＭＳフレームへ移動しました
;
;	ﾃｷｽﾄｳｲﾝﾄﾞｳ２退避バッファ#1と
;	ﾃｷｽﾄｳｲﾝﾄﾞｳ３退避バッファ#2と
;	ﾃｷｽﾄｳｲﾝﾄﾞｳ５退避バッファ#3と
;	ﾃｷｽﾄｳｲﾝﾄﾞｳ7退避バッファ#11と
;	ﾃｷｽﾄｳｲﾝﾄﾞｳ8退避バッファ#12と
;	退避バッファ#9は 
;	VVVRAM(varturl vram/仮想VRAM)と兼用であるので使用するときは
;	注意すること。
;
;	通常パターンバッファ前半#4と
;	通常パターンバッファ後半#5と
;	通常パターンバッファ前中間#8と
;	通常パターンバッファ後半50k#10は 
;	PARTBUF(parts buffer/パーツバッファ)と兼用である。
;
;	text buffer後半#6と
;	text buffer前中間#7は
;	TEXTBUF(text buffer/テキストバッファ)と兼用である。
;
;	#13(5,000byte)をWIDBORTH.ASMで使用
;
;	ARA005,ARA006,ARA007,ARA008 はエンディング用
;	ARA009はオープニング用
;
;	仮想ＶＲＡＭプレーン(ARA001等)の最小ｻｲｽﾞは16896byte、越えないこと。
;
;
;
;
;	<< bank >>
;		DW	PARTBUF_TOP		; #0
;		DW	VVVRAM_TOP		; #1	22,000byte
;		DW	VVVRAM_TOP+22000	; #2	34,530byte
;		DW	VVVRAM_TOP+56530	; #3	 9,000byte
;		DW	PARTBUF_TOP		; #4	32,768byte
;		DW	PARTBUF_TOP+32740 	; #5	32,764byte
;		DW	TEXT_TOP+32800		; #6	32,700byte
;		DW	TEXT_TOP+12800		; #7	19,990byte
;		DW	PARTBUF_TOP+12800	; #8	19,920byte
;		DW	VVVRAM_TOP+22000	; #9	43,532byte
;		DW	PARTBUF_TOP+14000	; #10	51,532byte
;		DW	VVVRAM_TOP		; #11	32,766byte
;		DW	VVVRAM_TOP+32768	; #12	32,766byte
;		DW	VVVRAM_TOP+60000	; #13	 5,000byte
;		DW	PARTBUF_TOP		; #14	12,800byte
;		DW	DATBIN2_TOP		; #15	12,400byte
;		DW	PROCWRK_END-13000	; #16	13,000byte
;		DW	TEXT_END-10000		; #17	10,000byte
;		DW	TEXT_END-16000		; #18	16,000byte
;		DW	VVVRAM_TOP		; #19	21,800byte
;		DW	VVVRAM_TOP+21800	; #20	21,800byte
;		DW	VVVRAM_TOP+21800*2	; #21	21,800byte
;		DW	PROCBUF_TOP+8000	; #22	("DSKTOOL.COM"用)
;		DW	PROCWRK_TOP		; #23	52,200byte
;		DW	PLESS_SRT		; #24	("WIDDISK.ASM"用)
;
;	WIDTEXT.ASM
;		text.1	#1	window エリア退避バンク番号
;		text.2	#1	window エリア退避バンク番号
;		text.3	#2	window エリア退避バンク番号
;		text.5	#3	window エリア退避バンク番号
;		text.6	#6	window エリア退避バンク番号
;		text.7	#11	window エリア退避バンク番号
;		text.8	#12	window エリア退避バンク番号
;		text.9	#7	window エリア退避バンク番号
;		text.10	#8	window エリア退避バンク番号
;		text.11	#2	window エリア退避バンク番号
;
;	WIDMULT.ASM	マルチアイテム・ウインドウ
;		#0	背景退避用パーツバンク番号
;		#100	ICON pattan bank number.
;
;	WIDIVENT.ASM	イベント・ウインドウ
;		#4	イベントバンク番号
;		#6	背景退避用パーツ番号
;
;	WIDGRAP.ASM	パラメータ・ウインドウ
;		#0	背景退避用パーツバンク番号
;
;	WIDSLCT.ASM	セレクト・ウインドウ
;		#0	背景退避用パーツ番号
;
;	WIDANIME.ASM	アニメ・ウインドウ
;		#10	アニメバンク番号
;		ARA002	退避用仮想ＶＲＡＭ
;
;	PICTUER.ASM
;		#5	フェイスロード用
;
; area assign.

INCLUDE	MACHINEX.INC
INCLUDE	TSTSETC.INC
INCLUDE	MESSAGE.INC

VRAM_SEG_G0	EQU	0A000H+1H	; visual data segment plean 0
VRAM_SEG_G1	EQU	0A000H+2H	; visual data segment plean 1
VRAM_SEG_G2	EQU	0A000H+3H	; visual data segment plean 2
VRAM_SEG_G3	EQU	0A000H+4H	; visual data segment plean 3
VRMWIDTH	EQU	80		; visual data plean width.

VGAVRAM_SEG_G0	EQU	0A000H+1H	; ＶＲＡＭプレーン０
VGAVRAM_SEG_G1	EQU	0A000H+2H	; ＶＲＡＭプレーン１
VGAVRAM_SEG_G2	EQU	0A000H+3H	; ＶＲＡＭプレーン２
VGAVRAM_SEG_G3	EQU	0A000H+4H	; ＶＲＡＭプレーン３
VGAVRMWIDTH	EQU	80		; ＶＲＡＭ幅

PC98VRAM_SEG_G0	EQU	0A800H		; ＶＲＡＭプレーン０
PC98VRAM_SEG_G1	EQU	0B000H		; ＶＲＡＭプレーン１
PC98VRAM_SEG_G2	EQU	0B800H		; ＶＲＡＭプレーン２
PC98VRAM_SEG_G3	EQU	0E000H		; ＶＲＡＭプレーン３
PC98VRMWIDTH	EQU	80		; ＶＲＡＭ幅


;	ＥＭＳフレーム

TEXTBUF		EQU	8FF0H		; テキストセグメント
TEXT_TAG	EQU	0		; text tag offset.
TEXT_TOP	EQU	4		; text top offset.
TEXT_END	EQU	4+65500		; text end offset.

MOV_ID2	MACRO	DESTID,SOUID
	MOV	AX,DS
	MOV	ES,AX
	MOV	SI,OFFSET SOUID
	MOV	DI,OFFSET DESTID
	MOVSW
	MOVSW
	MOVSW
	MOVSW
	MOVSW
	ENDM

EMMCOD	SEGMENT	PUBLIC	'EMMCOD'

	ASSUME	CS:EMMCOD,DS:DATA

EXTRN	EMEMCHECK:FAR		; (far)Expanded memory check.
EXTRN	EMEMAREA64K:FAR		; (far)Expanded memory 64k area allocate.
EXTRN	EMEMALLOC:FAR		; (far)Expanded memory allocate.
EXTRN	EMEMDEALLOC:FAR		; (far)Expanded memory deallocate.
EXTRN	EMEMQUICK:FAR		; (far)Expanded memory data name search.
EXTRN	EMEMLOAD:FAR		; (far)Expanded memory data load.

EMMCOD	ENDS


CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:DATA

PUBLIC	ZPTBL_INIT		; ZP table init.
PUBLIC	ZPTBL_FINALE		; ZP table finale.

EXTRN	c_TMVWAT:NEAR		; V-SYNC timer wait.

; *********************************************************
;	ZP table init.
;	-O- AX : 0=ok,1=no memory,2=EMS error.
; *********************************************************

ZPTBL_INIT	PROC	NEAR
;*;	PRVH	"-1-free segment : ",SEGFREE	; フリー領域の先頭セグメント

	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	ZPTBL_INIT_PCAT		;
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	ZPTBL_INIT_PC98		;
ZPTBL_INIT_PCAT:
	MOV	ARAVRM[0],VGAVRAM_SEG_G0	; ＶＲＡＭプレーン０
	MOV	ARAVRM[2],VGAVRAM_SEG_G1	; ＶＲＡＭプレーン１
	MOV	ARAVRM[4],VGAVRAM_SEG_G2	; ＶＲＡＭプレーン２
	MOV	ARAVRM[6],VGAVRAM_SEG_G3	; ＶＲＡＭプレーン３
	MOV	ARAVRM[8],VGAVRMWIDTH		; ＶＲＡＭ幅
	JMP	ZPTBL_INIT_ALLSET		;
ZPTBL_INIT_PC98:
	MOV	ARAVRM[0],PC98VRAM_SEG_G0	; ＶＲＡＭプレーン０
	MOV	ARAVRM[2],PC98VRAM_SEG_G1	; ＶＲＡＭプレーン１
	MOV	ARAVRM[4],PC98VRAM_SEG_G2	; ＶＲＡＭプレーン２
	MOV	ARAVRM[6],PC98VRAM_SEG_G3	; ＶＲＡＭプレーン３
	MOV	ARAVRM[8],PC98VRMWIDTH		; ＶＲＡＭ幅
	JMP	ZPTBL_INIT_ALLSET		;
ZPTBL_INIT_ALLSET:

	MOV_ID2	SSGR0	,ARAVRM			; visual data segment plean.
	MOV_ID2	SSGRV0	,ARAVRM			; visual data segment plean.
	MOV_ID2	SSDES0	,ARAVRM			; visual data segment plean.
	MOV_ID2	SSSOU0	,ARAVRM			; visual data segment plean.
	MOV_ID2	SSEFC0	,ARAVRM			; visual data segment plean.
	MOV_ID2	SSCUR0	,ARAVRM			; visual data segment plean.
	MOV_ID2	SEGVT0	,ARAVRM			; visual data segment plean.

	MOV	AX,SEG VVVRAM			; varturl vram.
	ADD	AX,0FH				; + 255 byte
	AND	AX,0FFF0H			; 

	MOV	ARA005[0],AX			;仮想ＶＲＡＭ(単ﾌﾟﾚｰﾝwidth60)
	MOV	ARA005[2],AX			;
	MOV	ARA005[4],AX			;
	MOV	ARA005[6],AX			;

	MOV	ARA006[0],AX			;仮想ＶＲＡＭ単ﾌﾟﾚｰﾝ(width40)
	MOV	ARA006[2],AX			;
	MOV	ARA006[4],AX			;
	MOV	ARA006[6],AX			;

	MOV	ARA009[0],AX			;仮想ＶＲＡＭ(単プレーンwidth47)
	MOV	ARA009[2],AX			;
	MOV	ARA009[4],AX			;
	MOV	ARA009[6],AX			;

	MOV	ARA001[0],AX			;仮想ＶＲＡＭプレーン
	MOV	ARA002[0],AX			;仮想ＶＲＡＭプレーン(width42)
	MOV	ARA003[0],AX			;仮想ＶＲＡＭプレーン(width60)
	MOV	ARA004[0],AX			;仮想ＶＲＡＭプレーン(width56)
	ADD	AX,03F0H			;40*400 pixel, 42*384 pixel.
	MOV	ARA001[2],AX			;仮想ＶＲＡＭプレーン
	MOV	ARA002[2],AX			;仮想ＶＲＡＭプレーン(width42)
	MOV	ARA003[2],AX			;仮想ＶＲＡＭプレーン(width60)
	MOV	ARA004[2],AX			;仮想ＶＲＡＭプレーン(width56)
	ADD	AX,03F0H			;60*268 pixel, 56*288 pixel.
	MOV	ARA001[4],AX			;仮想ＶＲＡＭプレーン
	MOV	ARA002[4],AX			;仮想ＶＲＡＭプレーン(width42)
	MOV	ARA003[4],AX			;仮想ＶＲＡＭプレーン(width60)
	MOV	ARA004[4],AX			;仮想ＶＲＡＭプレーン(width56)
	ADD	AX,03F0H			;
	MOV	ARA001[6],AX			;仮想ＶＲＡＭプレーン
	MOV	ARA002[6],AX			;仮想ＶＲＡＭプレーン(width42)
	MOV	ARA003[6],AX			;仮想ＶＲＡＭプレーン(width60)
	MOV	ARA004[6],AX			;仮想ＶＲＡＭプレーン(width56)

	MOV	ARA001[8],40			;仮想ＶＲＡＭプレーン幅
	MOV	ARA002[8],42			;仮想ＶＲＡＭプレーン(width42)
	MOV	ARA003[8],60			;仮想ＶＲＡＭプレーン(width60)
	MOV	ARA004[8],56			;仮想ＶＲＡＭプレーン(width56)
	MOV	ARA005[8],60			;仮想ＶＲＡＭ単ﾌﾟﾚｰﾝ(width60)
	MOV	ARA006[8],40			;仮想ＶＲＡＭ単ﾌﾟﾚｰﾝ(width40)
	MOV	ARA009[8],47			;仮想ＶＲＡＭ単ﾌﾟﾚｰﾝ(width47)

	MOV	AX,SEG PROCWRK			; process work buffer.(.map)
	ADD	AX,0FH				; + 255 byte
	AND	AX,0FFF0H			; 
	MOV	ARA007[0],AX			;仮想ＶＲＡＭ単ﾌﾟﾚｰﾝ(width40)
	MOV	ARA007[2],AX			;
	MOV	ARA007[4],AX			;
	MOV	ARA007[6],AX			;
	MOV	ARA007[8],40			;仮想ＶＲＡＭ単ﾌﾟﾚｰﾝ(width40)

	MOV	AX,SEG PARTBUF			; parts buffer.
	ADD	AX,0FH				; + 255 byte
	AND	AX,0FFF0H			; 
	MOV	ARA008[0],AX			;仮想ＶＲＡＭ(単プレーンwidth40)
	MOV	ARA008[2],AX			;
	MOV	ARA008[4],AX			;
	MOV	ARA008[6],AX			;
	MOV	ARA008[8],40			;仮想ＶＲＡＭ(単プレーンwidth40)

	; EMS check.

	MOV	FLAG_EMS_OPEN_OK,0		; flag EMS open ok.

	CALL	EMEMCHECK			; (far)Expanded memory check.
	CMP	AX,1				; 1=ok,0=Expanded memory none.
	JNE	ZPTBL_NO_EMS			;
	MOV	FLAG_EMS_OPEN_OK,1		; flag EMS open ok.
ZPTBL_NO_EMS:

	; memory allocate.

	MOV	AX,SEG PLESS			; pless/unpless segment.
	ADD	AX,0FH				; + 255 byte
	AND	AX,0FFF0H			; 
	MOV	SEG98VRAMWORK,AX		;PC9801vram work.(BBCTOOL.ASM)

	MOV	AX,09FE0H			;
	SUB	AX,SEG ENDSEG			; フリー領域の先頭セグメント
	CMP	AX,1000H			;
	JNB	ZPTBL_INIT_TEXT_SEG_SET		;

	CALL	EMEMAREA64K			; (far)Expanded memory 64k area allocate.
	CMP	AX,1				; 1=ok,2=64k area none,0=memory none.
	JNE	ZPTBL_INIT_NO_MEM		;

	MOV	SEG64KFREAM,DX			; ６４Ｋフレームセグメント

	CALL	EMS_FREAM_CHK			; ＥＭＳフレームチェック
	CMP	AX,0				; 0=ok,1=error.
	JNE	ZPTBL_INIT_EMS_ERROR		;

	MESSAGE	9	;"通常メモリ拡張の為，EMS を使用します frame:"
	CALL	c_PRINT
	MOV	DX,SEG64KFREAM			; ６４Ｋフレームセグメント
	CALL	c_HEXSTR
	CALL	c_PRINT
	LF

	MOV	AX,SEG64KFREAM			; ６４Ｋフレームセグメント
	JMP	ZPTBL_INIT_TEXT_SEG_SET2	;

ZPTBL_INIT_TEXT_SEG_SET:			;
	MOV	AX,SEG ENDSEG			; フリー領域の先頭セグメント
	ADD	AX,10H				;
	MOV	SEGFREE,AX			; フリー領域の先頭セグメント
	ADD	SEGFREE,1000H			; 新しいフリー領域

ZPTBL_INIT_TEXT_SEG_SET2:
	MOV	TEXTPSEG,AX			;text segment pointer.
	MOV	VISUALTXTSEG,AX			; visual text buffer segment.

	; 武者修行バッファセグメント

	MOV	MUSYA_BUF_SEG_TBL[2*2],AX	; #2 text buffer.
	MOV	MUSYA_BUF_SEG_TBL[2*5],AX	; #5 text buffer.

	; パターンセグメントテーブル

	MOV	TBLPATSEG[2*6],AX	; #6 text buffer.後半
	MOV	TBLPATSEG[2*7],AX	; #7 text buffer.前中間
	MOV	TBLPATSEG[2*17],AX	; #17 JOB013.TXT時に残るｴﾘｱ
	MOV	TBLPATSEG[2*18],AX	; #18 SSCOOK.TXT時に残るｴﾘｱ

	PRVH	"textseg      : ",AX
	PRVH	"free segment : ",SEGFREE	; フリー領域の先頭セグメント

	MOV	AX,60				; wait timer count.
	CALL	c_TMVWAT			; V-SYNC timer wait.

	MOV	AX,0			; 0=ok.
	RET
ZPTBL_INIT_NO_MEM:
	MOV	AX,1			; 1=no memory.
	RET
ZPTBL_INIT_EMS_ERROR:
	MOV	AX,2			; 2=EMS error.
	RET
ZPTBL_INIT	ENDP


; *********************************************************
;	ZP table finale.
; *********************************************************

ZPTBL_FINALE	PROC	NEAR
	CALL	EMEMDEALLOC		; (far)Expanded memory deallocate.
	RET
ZPTBL_FINALE	ENDP


; ****************************************************
;	ＥＭＳフレームチェック
;	-O- AX : 0=ok,1=error.
; ****************************************************

EMS_FREAM_CHK	PROC	NEAR
	MOV	AX,SEG64KFREAM		;

	MOV	BX,ARAVRM[0]		;
	AND	BX,0FFF0H		;
	CMP	AX,BX			;
	JB	EMS_FREAM_CHK_1		;
	ADD	BX,7D0H			;
	CMP	AX,BX			;
	JNB	EMS_FREAM_CHK_1		;
	JMP	EMS_FREAM_CHK_ERROR	;
EMS_FREAM_CHK_1:			;

	MOV	BX,ARAVRM[2]		;
	AND	BX,0FFF0H		;
	CMP	AX,BX			;
	JB	EMS_FREAM_CHK_2		;
	ADD	BX,7D0H			;
	CMP	AX,BX			;
	JNB	EMS_FREAM_CHK_2		;
	JMP	EMS_FREAM_CHK_ERROR	;
EMS_FREAM_CHK_2:			;

	MOV	BX,ARAVRM[4]		;
	AND	BX,0FFF0H		;
	CMP	AX,BX			;
	JB	EMS_FREAM_CHK_3		;
	ADD	BX,7D0H			;
	CMP	AX,BX			;
	JNB	EMS_FREAM_CHK_3		;
	JMP	EMS_FREAM_CHK_ERROR	;
EMS_FREAM_CHK_3:			;

	MOV	BX,ARAVRM[6]		;
	AND	BX,0FFF0H		;
	CMP	AX,BX			;
	JB	EMS_FREAM_CHK_4		;
	ADD	BX,7D0H			;
	CMP	AX,BX			;
	JNB	EMS_FREAM_CHK_4		;
	JMP	EMS_FREAM_CHK_ERROR	;
EMS_FREAM_CHK_4:			;

EMS_FREAM_CHK_OK:
	MOV	AX,0			; 0=ok.
	RET
EMS_FREAM_CHK_ERROR:
	MOV	AX,1			; 1=error.
	RET
EMS_FREAM_CHK	ENDP

CODE	ENDS


; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	TOKEN01			; token no.1
PUBLIC	TOKEN02			; token no.2
PUBLIC	TOKEN03			; token no.3
PUBLIC	TOKEN04			; token no.4

PUBLIC	FLAG_EMS_OPEN_OK	; flag EMS open ok.
PUBLIC	FLAG_EMS_ALLLOAD	; flag EMS all load.
PUBLIC	FLAG_FM_ENABLE		; flag FM sound enable.
PUBLIC	FLAG_MIDI_ENABLE	; flag MIDI enable.

TOKEN01	DW	0		; token no.1
TOKEN02	DW	0		; token no.2
TOKEN03	DW	0		; token no.3
TOKEN04	DW	0		; token no.4

FLAG_EMS_OPEN_OK	DW	0	; flag EMS open ok.
FLAG_EMS_ALLLOAD 	DW	0	; flag EMS all load.
FLAG_FM_ENABLE		DW	0	; flag FM sound enable.
FLAG_MIDI_ENABLE 	DW	0	; flag MIDI enable.

DATA	ENDS


; *********************************************************
;	segment.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	SEGFREE			; フリー領域の先頭セグメント

PUBLIC	SEGEMSWORK		; EMS work segment.
PUBLIC	OFSEMSWORK		; EMS work offset.

PUBLIC	SEGPARAMWORK		; parameter work segment.
PUBLIC	OFSPARAMWORK		; parameter work offset.

PUBLIC	SEGDSKCHWORK		; disk chenger work segment.
PUBLIC	OFSDSKCHWORK		; disk chenger work offset.

PUBLIC	SEG98VRAMWORK		; PC9801 vram work.(BBCTOOL.ASM)

SEGFREE		DW	SEG ENDSEG	; フリー領域の先頭セグメント

;;SEGEMSWORK	DW	SEG PLESS	; EMS work segment.
;;OFSEMSWORK	DW	PLESS_SRT+32780	; EMS work offset.(EMEMORY.ASM)
SEGEMSWORK	DW	SEG VVVRAM
OFSEMSWORK	DW	VVVRAM_TOP

SEGPARAMWORK	DW	SEG PLESS	; parameter work segment.
OFSPARAMWORK	DW	PLESS_SRT+32780	; parameter work offset(PARADISK.ASM)

SEGDSKCHWORK	DW	SEG PLESS	; disk chenger work segment.
OFSDSKCHWORK	DW	PLESS_SRT+32780	; disk chenger work offset(DSKCH2.ASM)

SEG98VRAMWORK	DW	SEG PLESS	; PC9801 vram work.(BBCTOOL.ASM)

SEG64KFREAM	DW	0		; ６４Ｋフレームセグメント

DATA	ENDS


; *********************************************************
;	child process.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	CH_HEAD_MUSYA			; musya header.
PUBLIC	CH_EXIT_STATUS			; exit status.
PUBLIC	CH_FUNCTION_NUM			; function number.
PUBLIC	CH_MAP_TYPE			; map type.1=E,2=W,3=S,4=N
PUBLIC	CH_MAP_SIZE_X			; map size x.
PUBLIC	CH_MAP_SIZE_Y			; map size y.
PUBLIC	CH_MAP_LOC_X			; map location x.
PUBLIC	CH_MAP_LOC_Y			; map location y.
PUBLIC	CH_GIRL_LOC_X			; girl location x.
PUBLIC	CH_GIRL_LOC_Y			; girl location y.
PUBLIC	CH_ANIME_XCHG_CHP1		; anime exchange chip1.
PUBLIC	CH_ANIME_XCHG_END1		; anime exchange end1.
PUBLIC	CH_ANIME_XCHG_CHP2		; anime exchange chip2.
PUBLIC	CH_ANIME_XCHG_END2		; anime exchange end2.
PUBLIC	CH_ANIME_XCHG_CHP3		; anime exchange chip3.
PUBLIC	CH_ANIME_XCHG_END3		; anime exchange end3.
PUBLIC	CH_ANIME_XCHG_CHP4		; anime exchange chip4.
PUBLIC	CH_ANIME_XCHG_END4		; anime exchange end4.
PUBLIC	CH_ANIME_MODE			; anime mode.
PUBLIC	CH_SUB_FUNCTION			; sub function number.
PUBLIC	CH_LOAD_BANK_B_SW		; load bank bit switch.
PUBLIC	CH_EFC_FALLS_LEN		; effect falls length.
PUBLIC	CH_PARAM01			; parameter 1.
PUBLIC	CH_PARAM02			; parameter 2.
PUBLIC	CH_PARAM03			; parameter 3.
PUBLIC	CH_PARAM04			; parameter 4.
PUBLIC	CH_PARAM05			; parameter 5.
PUBLIC	CH_PARAM06			; parameter 6.
PUBLIC	CH_HEAD_MUSYA_E			; musya header end.
PUBLIC	CH_HEAD_LENGTH			; musya header len.

CH_HEAD_MUSYA		LABEL	WORD	; musya header.
CH_EXIT_STATUS		DW	0	; exit status.
CH_FUNCTION_NUM		DW	0	; function number.
CH_MAP_TYPE		DW	0	; map type.1=E,2=W,3=S,4=N
CH_MAP_SIZE_X		DW	0	; map size x.
CH_MAP_SIZE_Y		DW	0	; map size y.
CH_MAP_LOC_X		DW	0	; map location x.
CH_MAP_LOC_Y		DW	0	; map location y.
CH_GIRL_LOC_X		DW	0	; girl location x.
CH_GIRL_LOC_Y		DW	0	; girl location y.
CH_ANIME_XCHG_CHP1	DW	0	; anime exchange chip1.
CH_ANIME_XCHG_END1	DW	0	; anime exchange end1.
CH_ANIME_XCHG_CHP2	DW	0	; anime exchange chip2.
CH_ANIME_XCHG_END2	DW	0	; anime exchange end2.
CH_ANIME_XCHG_CHP3	DW	0	; anime exchange chip3.
CH_ANIME_XCHG_END3	DW	0	; anime exchange end3.
CH_ANIME_XCHG_CHP4	DW	0	; anime exchange chip4.
CH_ANIME_XCHG_END4	DW	0	; anime exchange end4.
CH_ANIME_MODE		DW	0	; anime mode.
CH_SUB_FUNCTION		DW	0	; sub function number.
CH_LOAD_BANK_B_SW	DW	0	; load bank bit switch.
CH_EFC_FALLS_LEN	DW	0	; effect falls length.
CH_PARAM01		DW	0	; parameter 1.
CH_PARAM02		DW	0	; parameter 2.
CH_PARAM03		DW	0	; parameter 3.
CH_PARAM04		DW	0	; parameter 4.
CH_PARAM05		DW	0	; parameter 5.
CH_PARAM06		DW	0	; parameter 6.
CH_HEAD_MUSYA_E		LABEL	WORD	; musya header end.
CH_HEAD_LENGTH		DW CH_HEAD_MUSYA_E-CH_HEAD_MUSYA ; musya header len.

DATA	ENDS


; *********************************************************
;	text compiler.
; *********************************************************

STRSYMBOLLEN	EQU	32;16		; symbol length.
COMP_LEN	EQU	256		; comp line buffer length.
NEST_TBL_MAX	EQU	500;1000	; nest count max.
TEXTSTACKMAX	EQU	32		; text stack max.
LBLBUFF_LEN	EQU	2048		; jump table size.
LBLADRS_DIM	EQU	200 ;512	; jump address table dimension.(93/6)
PATH_STRING_LEN	EQU	40		; path string length.
USERSTRINGLEN	EQU	256		; user string length.
STRINGSTACKLEN	EQU	1024*2		; string stack length.

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	PROCBUFFSEG			; process buffer segment.
PUBLIC	PROCBUFFTOP			; process buffer top.
PUBLIC	PROCBUFFEND			; process buffer end.

PUBLIC	PROCWORKSEG			; process work buffer segment.
PUBLIC	PROCWORKTOP			; process work buffer top.
PUBLIC	PROCWORKEND			; process work buffer end.

PUBLIC	TEXTPSIZ			; text buffer size.
PUBLIC	TEXTPLEN			; text length.
PUBLIC	TEXTPSEG			; text segment pointer.
PUBLIC	TEXTPOFS			; text offset pointer.
PUBLIC	TEXTPSTARTOFS			; text start offset.
PUBLIC	TEXTPCMNDOFS			; text command start offset.
PUBLIC	TEXTPTAG			; text tag offset.
PUBLIC	TEXTSIZTBL			; text buffer size table.

PUBLIC	VISUALTXTSEG			; visual text buffer segment.
PUBLIC	VISUALTXTOFS			; visual text buffer offset.
PUBLIC	VISUALTXTSTARTOFS		; visual text buffer start offset.
PUBLIC	VISUALTXTSIZ			; visual text buffer size.

PUBLIC	STRSYMLEN			; symbol length.
PUBLIC	STRSYMMAX			; symbol max length.
PUBLIC	STRSYMBOL			; symbol string.

PUBLIC	DEFSYMLEN			; define symbol length.
PUBLIC	DEFSYMMAX			; define symbol max length.
PUBLIC	DEFSYMBOL			; define symbol string.

PUBLIC	SYMNUMBER			; symbol number.
PUBLIC	SYMFARLABEL			; far label.(SYMOFST+SYMSEGM)(dword)
PUBLIC	SYMOFST				; offset of symbol.
PUBLIC	SYMSEGM				; segment of symbol.

PUBLIC	SOUSYMNUMBER			; source symbol number.
PUBLIC	SOUSYMFARLABEL			; far.(SOUSYMOFST+SOUSYMSEGM)(dword)
PUBLIC	SOUSYMOFST			; offset of source symbol.
PUBLIC	SOUSYMSEGM			; segment of source symbol.

PUBLIC	REG_TABLE			; registar value table.
PUBLIC	REG_AX				; registar value AX.
PUBLIC	REG_BX				; registar value BX.
PUBLIC	REG_CX				; registar value CX.
PUBLIC	REG_DX				; registar value DX.
PUBLIC	REG_SI				; registar value SI.
PUBLIC	REG_DI				; registar value DI.
PUBLIC	REG_BP				; registar value BP.
PUBLIC	REG_ES				; registar value ES.

PUBLIC	USR_CNT1			; user counter.
PUBLIC	USR_CNT2			; user counter.
PUBLIC	USR_CNT3			; user counter.
PUBLIC	USR_CNT4			; user counter.
PUBLIC	USR_CNT5			; user counter.
PUBLIC	USR_CNT6			; user counter.
PUBLIC	USR_CNT7			; user counter.
PUBLIC	USR_CNT8			; user counter.

PUBLIC	ISLCT				; select number.
PUBLIC	ISITM				; select item number.

PUBLIC	COMPLINESIZE			; comp line buffer size.
PUBLIC	COMPLINESOU			; comp line buffer source.
PUBLIC	COMPLINEBIN			; comp line buffer binary.

PUBLIC	NEST_TBL_CNT			; nest count.
PUBLIC	NEST_TBL_CMAX			; nest count max.
PUBLIC	NEST_TBL_ADRS			; nest table.

PUBLIC	TEXTSTACK			; text stack.
PUBLIC	TEXTSTACK_MXP			; text stack max point.
PUBLIC	TEXTSTACKPNT			; text stack pointer.

PUBLIC	NESTINGLVL			; nesting level.

PUBLIC	JMPTBLSIZE			; jump table size.
PUBLIC	JMPTBLDLEN			; jump table data length.
PUBLIC	JMPTBLSEG			; jump label table segment.
PUBLIC	JMPTBLOFS			; jump label table offset.
PUBLIC	JMPADTBLDIM			; jump adrs table dimension.
PUBLIC	JMPADTBLCNT			; jump adrs table count.
PUBLIC	JMPADTBLSEG			; jump adrs table segment.
PUBLIC	JMPADTBLOFS			; jump adrs table offset.

PUBLIC	FLTEXTNOWLEN			; now text file path length.
PUBLIC	FLTEXTNOW			; now text file path.

PUBLIC	DIM_OFST			; dimension offset.
PUBLIC	MESSAGE_SPEED			; message speed.
PUBLIC	MESSAGE_WAIT			; message wait.
PUBLIC	INLINECOMPDBG			; inline compile debug.
PUBLIC	FLAGERROR			; error flag.
PUBLIC	FLAGEXIT			; exit flag.

PUBLIC	KEYBORD_FLAGALLSKIP		; all skip flag.

PUBLIC	USERSTRING			; user string.

PUBLIC	STRINGSTACKPNT			; string stack pointer.
PUBLIC	STRINGSTACKMAX			; string stack max.
PUBLIC	STRINGSTACKBUF			; string stack buffer.

PUBLIC	NULSTRING			; null string buffer.

PUBLIC	STARTUP_FILE			; startup text file name.

PROCBUFFSEG	DW	SEG PROCBUF	; process buffer segment.
PROCBUFFTOP	DW	PROCBUF_TOP	; process buffer top.
PROCBUFFEND	DW	PROCBUF_END	; process buffer end.

PROCWORKSEG	DW	SEG PROCWRK	; process work buffer segment.
PROCWORKTOP	DW	PROCWRK_TOP	; process work buffer top.
PROCWORKEND	DW	PROCWRK_END	; process work buffer end.

TEXTPSIZ	DW	65500		; text buffer size.
TEXTPLEN	DW	0		; text length.
TEXTPSEG	DW	TEXTBUF		; text segment pointer.
TEXTPOFS	DW	TEXT_TOP	; text offset pointer.
TEXTPSTARTOFS	DW	TEXT_TOP	; text start offset.
TEXTPCMNDOFS	DW	TEXT_TOP	; text command start offset.
TEXTPTAG	DW	TEXT_TAG	; text tag offset.
TEXTSIZTBL	DW	65500,32000,16000,8000,4000 ; text buffer size table.

VISUALTXTSEG	DW	TEXTBUF			; visual text buffer segment.
VISUALTXTOFS	DW	TEXT_TOP+32800		; visual text buffer offset.
VISUALTXTSTARTOFS DW	TEXT_TOP+32800		; visual text buffer start offset.
VISUALTXTSIZ	DW	65500 - (TEXT_TOP+32800); visual text buffer size.

STRSYMLEN	DW	0		; symbol length.
STRSYMMAX	DW	STRSYMBOLLEN	; symbol max length.
STRSYMBOL	DW	SSMBL		; symbol string.
SSMBL		DB	STRSYMBOLLEN DUP (0),0,0

DEFSYMLEN	DW	0		; define symbol length.
DEFSYMMAX	DW	STRSYMBOLLEN	; define symbol max length.
DEFSYMBOL	DW	DEFSSS		; define symbol string.
DEFSSS		DB	STRSYMBOLLEN DUP (0),0,0

SYMNUMBER	DW	0		; symbol number.
SYMFARLABEL	LABEL	DWORD		; far label.(SYMOFST+SYMSEGM)(dword)
SYMOFST		DW	0		; offset of symbol.
SYMSEGM		DW	0		; segment of symbol.

SOUSYMNUMBER	DW	0		; source symbol number.
SOUSYMFARLABEL	LABEL	DWORD		; far.(SOUSYMOFST+SOUSYMSEGM)(dword)
SOUSYMOFST	DW	0		; offset of source symbol.
SOUSYMSEGM	DW	0		; segment of source symbol.

REG_TABLE	LABEL	WORD		; registar value table.
REG_AX		DW	0		; registar value AX.
REG_BX		DW	0		; registar value BX.
REG_CX		DW	0		; registar value CX.
REG_DX		DW	0		; registar value DX.
REG_SI		DW	0		; registar value SI.
REG_DI		DW	0		; registar value DI.
REG_BP		DW	0		; registar value BP.
REG_ES		DW	0		; registar value ES.

USR_CNT1	DW	0		; user counter.
USR_CNT2	DW	0		; user counter.
USR_CNT3	DW	0		; user counter.
USR_CNT4	DW	0		; user counter.
USR_CNT5	DW	0		; user counter.
USR_CNT6	DW	0		; user counter.
USR_CNT7	DW	0		; user counter.
USR_CNT8	DW	0		; user counter.

ISLCT		DW	0		; select number.
ISITM		DW	0		; select item number.

COMPLINESIZE	DW	COMP_LEN		; comp line buffer size.
COMPLINESOU	DW	COMS			; comp line buffer source.
COMPLINEBIN	DW	COMB			; comp line buffer binary.
COMS		DB	COMP_LEN DUP (0),0,0
COMB		DB	COMP_LEN DUP (0),0,0

NEST_TBL_CNT	DW	0			; nest count.
NEST_TBL_CMAX	DW	NEST_TBL_MAX		; nest count max.
NEST_TBL_ADRS	DW	NEST_TBL_MAX*3 DUP (0)	; nest table.

TEXTSTACK	DW	TEXTSTACKMAX DUP (0)	; text stack.
TEXTSTACK_MXP	DW	TEXTSTACKMAX		; text stack max point.
TEXTSTACKPNT	DW	0			; text stack pointer.

NESTINGLVL	DW	0			; nesting level.

JMPTBLSIZE	DW	LBLBUFF_LEN		; jump table size.
JMPTBLDLEN	DW	0			; jump table data length.
JMPTBLSEG	DW	SEG LBLBUFF		; jump label table segment.
JMPTBLOFS	DW	OFFSET LABELNAME	; jump label table offset.
JMPADTBLDIM	DW	LBLADRS_DIM		; jump adrs table dimension.
JMPADTBLCNT	DW	0			; jump adrs table count.
JMPADTBLSEG	DW	SEG LBLBUFF		; jump adrs table segment.
JMPADTBLOFS	DW	OFFSET LABELADRS	; jump adrs table offset.

FLTEXTNOWLEN	DW	PATH_STRING_LEN		; now text file path length.
FLTEXTNOW	DW	FLTNM			; now text file path.
FLTNM		DB	PATH_STRING_LEN	DUP (0),0,0

DIM_OFST	DW	0			; dimension offset.
MESSAGE_SPEED	DW	1			; message speed.
MESSAGE_WAIT	DW	2			; message wait.
INLINECOMPDBG	DW	0			; inline compile debug.
FLAGERROR	DW	0			; error flag.
FLAGEXIT	DW	0			; exit flag.

KEYBORD_FLAGALLSKIP	DW	0		; all skip flag.

USERSTRING	DW	SSUSR			; user string.
SSUSR		DB	USERSTRINGLEN DUP (0),0,0

STRINGSTACKPNT	DW	0			; string stack pointer.
STRINGSTACKMAX	DW	STRINGSTACKLEN		; string stack max.
STRINGSTACKBUF	DW	SSTK			; string stack buffer.
SSTK		DB	STRINGSTACKLEN DUP (0),0,0

NULSTRING	DW	NULS			; null string buffer.
NULS		DB	0,0			; null string buffer.

STARTUP_FILE	DW	SRTFL			; startup text file name.
SRTFL		DB	"START",0		;

DATA	ENDS


; *********************************************************
;	windows.
; *********************************************************

ATMTABLE_MAX	EQU	20	; 表示単語の上限
ITEMIDTABLE_MAX	EQU	50	; アイテムIDの上限
IPARATBL_MAX	EQU	10	; アイテムパラメータの上限
IGRPTABLE_MAX	EQU	10	; グラフ本数の上限
STR_VAL_LEN 	EQU	6	; string length.（数値表示用）
STR_VAL_LEN2	EQU	24	; string length.（数値表示拡張）
STRING_LEN 	EQU	255	; string length.

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	ATMSEG			; WINDOWS/テキストバッファセグメント
PUBLIC	ATMTBL			; WINDOWS/表示単語アドレス
PUBLIC	ATMTLN			; WINDOWS/表示単語長さ
PUBLIC	ATMVAL			; WINDOWS/表示単語の数値
PUBLIC	ATMMAX			; WINDOWS/表示単語の数
PUBLIC	ATMDIM	 		; WINDOWS/表示単語のテーブルサイズ

PUBLIC	ITEMID_TBL1		; アイテムIDﾃｰﾌﾞﾙ／名前ＩＤ
PUBLIC	ITEMID_TBL2		; アイテムIDﾃｰﾌﾞﾙ／ＩＣＯＮ
PUBLIC	ITEMID_TBL3		; アイテムIDﾃｰﾌﾞﾙ／金
PUBLIC	ITEMID_TBL4		; アイテムIDﾃｰﾌﾞﾙ／文字ＩＤ１
PUBLIC	ITEMID_TBL5		; アイテムIDﾃｰﾌﾞﾙ／ﾊﾟﾗﾒｰﾀ値１
PUBLIC	ITEMID_TBL6		; アイテムIDﾃｰﾌﾞﾙ／文字ＩＤ２
PUBLIC	ITEMID_TBL7		; アイテムIDﾃｰﾌﾞﾙ／ﾊﾟﾗﾒｰﾀ値２
PUBLIC	ITEMID_CNT		; アイテムID数
PUBLIC	ITEMID_DIM		; アイテムIDﾃｰﾌﾞﾙｻｲｽﾞ

PUBLIC	IPARATBL		; アイテムパラメータ・ﾃｰﾌﾞﾙ
PUBLIC	IPARACNT		; アイテムパラメータ・数
PUBLIC	IPARADIM		; アイテムパラメータ・ﾃｰﾌﾞﾙｻｲｽﾞ

PUBLIC	IGRP_TBL1		; グラフテーブル／名前
PUBLIC	IGRP_TBL2		; グラフテーブル／タイプ
PUBLIC	IGRP_TBL3		; グラフテーブル／パラメータ値
PUBLIC	IGRP_TBL4		; グラフテーブル／項目名
PUBLIC	IGRP_CNT		; グラフテーブル数
PUBLIC	IGRP_DIM		; グラフ本数の上限
PUBLIC	IGRP_X			; グラフＸ
PUBLIC	IGRP_Y			; グラフＹ

PUBLIC	STR_BUFF		; 文字列バッファ
PUBLIC	STR_VAL_BUFF		; 表示値文字列バッファ

ATMSEG		DW	0			; WINDOWS/ﾃｷｽﾄﾊﾞｯﾌｧｾｸﾞﾒﾝﾄ
ATMTBL		DW	ATMTABLE_MAX DUP (0)	; WINDOWS/表示単語アドレス
ATMTLN		DW	ATMTABLE_MAX DUP (0)	; WINDOWS/表示単語長さ
ATMVAL		DW	ATMTABLE_MAX DUP (0)	; WINDOWS/表示単語の数値
ATMMAX  	DW	0			; WINDOWS/表示単語の数
ATMDIM	 	DW	ATMTABLE_MAX		; WINDOWS/表示単語のﾃｰﾌﾞﾙｻｲｽﾞ

ITEMID_TBL1	DW	ITEMIDTABLE_MAX DUP (0)	; アイテムIDﾃｰﾌﾞﾙ／名前ＩＤ
ITEMID_TBL2	DW	ITEMIDTABLE_MAX DUP (0)	; アイテムIDﾃｰﾌﾞﾙ／ＩＣＯＮ
ITEMID_TBL3	DW	ITEMIDTABLE_MAX DUP (0)	; アイテムIDﾃｰﾌﾞﾙ／金
ITEMID_TBL4	DW	ITEMIDTABLE_MAX DUP (0)	; アイテムIDﾃｰﾌﾞﾙ／文字ＩＤ１
ITEMID_TBL5	DW	ITEMIDTABLE_MAX DUP (0)	; アイテムIDﾃｰﾌﾞﾙ／ﾊﾟﾗﾒｰﾀ値１
ITEMID_TBL6	DW	ITEMIDTABLE_MAX DUP (0)	; アイテムIDﾃｰﾌﾞﾙ／文字ＩＤ２
ITEMID_TBL7	DW	ITEMIDTABLE_MAX DUP (0)	; アイテムIDﾃｰﾌﾞﾙ／ﾊﾟﾗﾒｰﾀ値２
ITEMID_CNT	DW	0			; アイテムID数
ITEMID_DIM	DW	ITEMIDTABLE_MAX		; アイテムIDﾃｰﾌﾞﾙｻｲｽﾞ

IPARATBL	DW	IPARATBL_MAX DUP (0)	; アイテムパラメータ・ﾃｰﾌﾞﾙ
IPARACNT	DW	0			; アイテムパラメータ・数
IPARADIM	DW	IPARATBL_MAX		; アイテムパラメータ・ﾃｰﾌﾞﾙｻｲｽﾞ

IGRP_TBL1	DW	IGRPTABLE_MAX DUP (0)	; グラフテーブル／名前
IGRP_TBL2	DW	IGRPTABLE_MAX DUP (0)	; グラフテーブル／タイプ
IGRP_TBL3	DW	IGRPTABLE_MAX DUP (0)	; グラフテーブル／パラメータ値
IGRP_TBL4	DW	IGRPTABLE_MAX DUP (0)	; グラフテーブル／項目名
IGRP_CNT	DW	0			; グラフテーブル数
IGRP_DIM	DW	IGRPTABLE_MAX		; グラフ本数の上限
IGRP_X		DW	0			; グラフＸ
IGRP_Y		DW	0			; グラフＹ

STR_BUFF	DB	STRING_LEN DUP (' ')	; 文字列バッファ
		DB	0,0			;
STR_VAL_BUFF	DB	STR_VAL_LEN2 DUP (' ')	; 表示値文字列バッファ
		DB	0,0			;

DATA	ENDS


; *********************************************************
;	pattan data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	PRSBNK:WORD		; バンク番号
EXTRN	PRSSEG:WORD		; バンクセグメント
EXTRN	PRSTOP:WORD		; バンクトップオフセット
EXTRN	PRSEND:WORD		; バンクエンドオフセット
EXTRN	PRSOFS:WORD		; パーツバッファのカレントポインタ
EXTRN	PRSSIZ:WORD		; パーツバッファの使用サイズ

PUBLIC	ARAVRM			; ＶＲＡＭプレーン
PUBLIC	ARA001			; 仮想ＶＲＡＭプレーン(width40)
PUBLIC	ARA002			; 仮想ＶＲＡＭプレーン(width42)
PUBLIC	ARA003			; 仮想ＶＲＡＭプレーン(width60)
PUBLIC	ARA004			; 仮想ＶＲＡＭプレーン(width56)
PUBLIC	ARA005			; 仮想ＶＲＡＭ(単プレーンwidth60)
PUBLIC	ARA006			; 仮想ＶＲＡＭ(単プレーンwidth40)
PUBLIC	ARA007			; 仮想ＶＲＡＭ(単プレーンwidth40)
PUBLIC	ARA008			; 仮想ＶＲＡＭ(単プレーンwidth40)
PUBLIC	ARA009			; 仮想ＶＲＡＭ(単プレーンwidth47)

PUBLIC	SEGPLS			; pless/unpless segment.
PUBLIC	OFSPLS			; pless/unpless offset.
PUBLIC	SIZPLS			; pless/unpless size.

;	SSGRx	: PARTST etc..

PUBLIC	SSGR0			; visual data segment plean 0
PUBLIC	SSGR1			; visual data segment plean 1
PUBLIC	SSGR2			; visual data segment plean 2
PUBLIC	SSGR3			; visual data segment plean 3
PUBLIC	SSGRW			; visual data plean width.

;	SSGRVx	: PLSLD6 etc..

PUBLIC	SSGRV0			; visual data segment plean 0
PUBLIC	SSGRV1			; visual data segment plean 1
PUBLIC	SSGRV2			; visual data segment plean 2
PUBLIC	SSGRV3			; visual data segment plean 3
PUBLIC	SSGRVW			; visual data plean width.

;	SSDESx	: used = ADVMOV.ASM/HVLINE.ASM/TALKER.ASM
;				/WIDMTRX.ASM/WIDSLCT.ASM

PUBLIC	SSDES0			; visual data segment plean 0
PUBLIC	SSDES1			; visual data segment plean 1
PUBLIC	SSDES2			; visual data segment plean 2
PUBLIC	SSDES3			; visual data segment plean 3
PUBLIC	SSDESW			; visual data plean width.

;	SSSOUx	: used = ADVMOV.ASM/TALKER.ASM

PUBLIC	SSSOU0			; visual data segment plean 0
PUBLIC	SSSOU1			; visual data segment plean 1
PUBLIC	SSSOU2			; visual data segment plean 2
PUBLIC	SSSOU3			; visual data segment plean 3
PUBLIC	SSSOUW			; visual data plean width.

;	SSEFCx	: used = EFECT2.ASM

PUBLIC	SSEFC0			; visual data segment plean 0
PUBLIC	SSEFC1			; visual data segment plean 1
PUBLIC	SSEFC2			; visual data segment plean 2
PUBLIC	SSEFC3			; visual data segment plean 3
PUBLIC	SSEFCW			; visual data plean width.

;	SSCURx	: MUSCOR.ASM  MUSCR2.ASM

PUBLIC	SSCUR0			; visual data segment plean 0
PUBLIC	SSCUR1			; visual data segment plean 1
PUBLIC	SSCUR2			; visual data segment plean 2
PUBLIC	SSCUR3			; visual data segment plean 3
PUBLIC	SSCURW			; visual data plean width.

;	SEGVTx	: VRTEXT.ASM

PUBLIC	SEGVT0			; visual data segment plean 0
PUBLIC	SEGVT1			; visual data segment plean 1
PUBLIC	SEGVT2			; visual data segment plean 2
PUBLIC	SEGVT3			; visual data segment plean 3
PUBLIC	SEGVTW			; visual data plean width.

PUBLIC	WDX1			; WINDOWS/point x1.
PUBLIC	WDY1			; WINDOWS/point y1.
PUBLIC	WDX2			; WINDOWS/point x2.
PUBLIC	WDY2			; WINDOWS/point y2.

PUBLIC	VX1			; point x1.
PUBLIC	VY1			; point y1.
PUBLIC	VX2			; point x2.
PUBLIC	VY2			; point y2.
PUBLIC	VX3			; point x3.
PUBLIC	VY3			; point y3.
PUBLIC	ADRS			; address.
PUBLIC	NUM			; number.
PUBLIC	VCOL			; color.

PUBLIC	VRX			; x point.
PUBLIC	VRY			; y point.
PUBLIC	VRLENX			; x length.
PUBLIC	VRLENY			; y length.

PUBLIC	VRPX			; ＧＥＴ Ｘ座標
PUBLIC	VRPY			; ＧＥＴ Ｙ座標
PUBLIC	VRLENPX			; ＧＥＴ Ｘサイズ
PUBLIC	VRLENPY			; ＧＥＴ Ｙサイズ

PUBLIC	BPOINT			; data buffer point.
PUBLIC	BPNTOF			; データバッファポインタ
PUBLIC	BPNTSG			; データバッファセグメント
PUBLIC	BCNTMX			; データ最大長さ
PUBLIC	BCOUNT			; データ長さ

PUBLIC	PLSMDE			; 圧縮モード(0:通常,1:縦方向)
PUBLIC	BMSKCL			; マスキングカラー
PUBLIC	BORRCL			; ＯＲカラー
PUBLIC	PRSSKP			; パーツＰＵＴのスキッププレーン
PUBLIC	PRSWID			; vram width.
PUBLIC	PRSWIDB			; vram width - byte.
PUBLIC	PRSVMOD			; vram mode.0=normal,1=video memory

PUBLIC	BUFFSRTOFS		; buffer start offset.
PUBLIC	VRAMSRTOFS		; vram start offset.
PUBLIC	NEXTPLNOFS		; next plean offset.
PUBLIC	NXTLINOFS		; next line offset.

PUBLIC	PATTBLMAX		; パターンテーブルレコード数
PUBLIC	TBLPATSEG		; パターンセグメントテーブル
PUBLIC	TBLPATTOP		; パターン先頭オフセットテーブル
PUBLIC	TBLPATEND		; パターン終了オフセットテーブル

PUBLIC	MUSYA_BUF_SEG_TBL	; 武者修行バッファセグメント
PUBLIC	MUSYA_BUF_OFS_TBL	; 武者修行バッファオフセット

PUBLIC	CLRCDE			; color code.
PUBLIC	CLRVEW			; color view.
PUBLIC	CLRCNS			; contrast.
PUBLIC	CLRBRI			; brightness.

PUBLIC	CRNUM			; color code.       
PUBLIC	CBLUE			; blue  value (0-15)
PUBLIC	CRED			; red   value (0-15)
PUBLIC	CGREEN			; green value (0-15)

ARAVRM	LABEL	WORD		; ＶＲＡＭプレーン
	DW	VRAM_SEG_G0	; ＶＲＡＭプレーン０
	DW	VRAM_SEG_G1	; ＶＲＡＭプレーン１
	DW	VRAM_SEG_G2	; ＶＲＡＭプレーン２
	DW	VRAM_SEG_G3	; ＶＲＡＭプレーン３
	DW	VRMWIDTH	; ＶＲＡＭプレーン幅

ARA001	LABEL	WORD		; 仮想ＶＲＡＭプレーン
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン０
	DW	VRAM_SEG_G1	; 仮想ＶＲＡＭプレーン１
	DW	VRAM_SEG_G2	; 仮想ＶＲＡＭプレーン２
	DW	VRAM_SEG_G3	; 仮想ＶＲＡＭプレーン３
	DW	VRMWIDTH	; 仮想ＶＲＡＭプレーン幅

ARA002	LABEL	WORD		; 仮想ＶＲＡＭプレーン
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン０
	DW	VRAM_SEG_G1	; 仮想ＶＲＡＭプレーン１
	DW	VRAM_SEG_G2	; 仮想ＶＲＡＭプレーン２
	DW	VRAM_SEG_G3	; 仮想ＶＲＡＭプレーン３
	DW	VRMWIDTH	; 仮想ＶＲＡＭプレーン幅

ARA003	LABEL	WORD		; 仮想ＶＲＡＭプレーン
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン０
	DW	VRAM_SEG_G1	; 仮想ＶＲＡＭプレーン１
	DW	VRAM_SEG_G2	; 仮想ＶＲＡＭプレーン２
	DW	VRAM_SEG_G3	; 仮想ＶＲＡＭプレーン３
	DW	VRMWIDTH	; 仮想ＶＲＡＭプレーン幅

ARA004	LABEL	WORD		; 仮想ＶＲＡＭプレーン
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン０
	DW	VRAM_SEG_G1	; 仮想ＶＲＡＭプレーン１
	DW	VRAM_SEG_G2	; 仮想ＶＲＡＭプレーン２
	DW	VRAM_SEG_G3	; 仮想ＶＲＡＭプレーン３
	DW	VRMWIDTH	; 仮想ＶＲＡＭプレーン幅

ARA005	LABEL	WORD		; 仮想ＶＲＡＭプレーン(単プレーン)
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン０
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン１
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン２
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン３
	DW	VRMWIDTH	; 仮想ＶＲＡＭプレーン幅

ARA006	LABEL	WORD		; 仮想ＶＲＡＭプレーン(単プレーン)
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン０
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン１
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン２
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン３
	DW	VRMWIDTH	; 仮想ＶＲＡＭプレーン幅

ARA007	LABEL	WORD		; 仮想ＶＲＡＭプレーン(単プレーン)
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン０
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン１
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン２
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン３
	DW	VRMWIDTH	; 仮想ＶＲＡＭプレーン幅

ARA008	LABEL	WORD		; 仮想ＶＲＡＭプレーン(単プレーン)
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン０
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン１
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン２
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン３
	DW	VRMWIDTH	; 仮想ＶＲＡＭプレーン幅

ARA009	LABEL	WORD		; 仮想ＶＲＡＭプレーン(単プレーン)
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン０
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン１
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン２
	DW	VRAM_SEG_G0	; 仮想ＶＲＡＭプレーン３
	DW	VRMWIDTH	; 仮想ＶＲＡＭプレーン幅


SEGPLS	DW	SEG PLESS	; pless/unpless segment.
OFSPLS	DW	PLESS_SRT	; pless/unpless offset.
SIZPLS	DW	65535		; pless/unpless size.

SSGR0	DW	VRAM_SEG_G0	; visual data segment plean 0
SSGR1	DW	VRAM_SEG_G1	; visual data segment plean 1
SSGR2	DW	VRAM_SEG_G2	; visual data segment plean 2
SSGR3	DW	VRAM_SEG_G3	; visual data segment plean 3
SSGRW	DW	VRMWIDTH	; visual data plean width.

SSGRV0	DW	VRAM_SEG_G0	; visual data segment plean 0
SSGRV1	DW	VRAM_SEG_G1	; visual data segment plean 1
SSGRV2	DW	VRAM_SEG_G2	; visual data segment plean 2
SSGRV3	DW	VRAM_SEG_G3	; visual data segment plean 3
SSGRVW	DW	VRMWIDTH	; visual data plean width.

SSDES0	DW	VRAM_SEG_G0	; visual data segment plean 0
SSDES1	DW	VRAM_SEG_G1	; visual data segment plean 1
SSDES2	DW	VRAM_SEG_G2	; visual data segment plean 2
SSDES3	DW	VRAM_SEG_G3	; visual data segment plean 3
SSDESW	DW	VRMWIDTH	; visual data plean width.

SSSOU0	DW	VRAM_SEG_G0	; visual data segment plean 0
SSSOU1	DW	VRAM_SEG_G1	; visual data segment plean 1
SSSOU2	DW	VRAM_SEG_G2	; visual data segment plean 2
SSSOU3	DW	VRAM_SEG_G3	; visual data segment plean 3
SSSOUW	DW	VRMWIDTH	; visual data plean width.

SSEFC0	DW	VRAM_SEG_G0	; visual data segment plean 0
SSEFC1	DW	VRAM_SEG_G1	; visual data segment plean 1
SSEFC2	DW	VRAM_SEG_G2	; visual data segment plean 2
SSEFC3	DW	VRAM_SEG_G3	; visual data segment plean 3
SSEFCW	DW	VRMWIDTH	; visual data plean width.

SSCUR0	DW	VRAM_SEG_G0	; visual data segment plean 0
SSCUR1	DW	VRAM_SEG_G1	; visual data segment plean 1
SSCUR2	DW	VRAM_SEG_G2	; visual data segment plean 2
SSCUR3	DW	VRAM_SEG_G3	; visual data segment plean 3
SSCURW	DW	VRMWIDTH	; visual data plean width.

SEGVT0	DW	VRAM_SEG_G0	; visual data segment plean 0
SEGVT1	DW	VRAM_SEG_G1	; visual data segment plean 1
SEGVT2	DW	VRAM_SEG_G2	; visual data segment plean 2
SEGVT3	DW	VRAM_SEG_G3	; visual data segment plean 3
SEGVTW	DW	VRMWIDTH	; visual data plean width.

WDX1	DW	0		; WINDOWS/point x1.
WDY1	DW	0		; WINDOWS/point y1.
WDX2	DW	0		; WINDOWS/point x2.
WDY2	DW	0		; WINDOWS/point y2.

VX1	DW	0		; point x1.
VY1	DW	0		; point y1.
VX2	DW	0		; point x2.
VY2	DW	0		; point y2.
VX3	DW	0		; point x3.
VY3	DW	0		; point y3.
ADRS	DW	0		; address.
NUM	DW	0		; number.
VCOL	DW	0		; color.

VRX	DW	0		; x point.
VRY	DW	0		; y point.
VRLENX	DW	0		; x length.
VRLENY	DW	0		; y length.

VRPX	DW	0		; ＧＥＴ Ｘ座標
VRPY	DW	0		; ＧＥＴ Ｙ座標
VRLENPX	DW	0		; ＧＥＴ Ｘサイズ
VRLENPY	DW	0		; ＧＥＴ Ｙサイズ

BPOINT	DW	0		; data buffer point.
BPNTOF	DW	0		; データバッファポインタ
BPNTSG	DW	0		; データバッファセグメント
BCNTMX	DW	0		; データ最大長さ
BCOUNT	DW	0		; データ長さ

PLSMDE	DW	1		; 圧縮モード(0:通常,1:縦方向)
BMSKCL	DW	0		; マスキングカラー
BORRCL	DW	1111B		; ＯＲカラー
PRSSKP	DW	0000B		; パーツＰＵＴのスキッププレーン
PRSWID	DW	80		; vram width.
PRSWIDB	DW	79		; vram width - byte.
PRSVMOD	DW	0		; vram mode.0=normal,1=video memory

BUFFSRTOFS	DW	0	; buffer start offset.
VRAMSRTOFS	DW	0	; vram start offset.
NEXTPLNOFS	DW	0	; next plean offset.
NXTLINOFS	DW	0	; next line offset.

PATTBLMAX	DW (TBLPATSEG_END-TBLPATSEG)/2	; パターンテーブルレコード数

TBLPATSEG	LABEL	WORD		; パターンセグメントテーブル
		DW	SEG PARTBUF	; #0 通常パターンバッファ
		DW	SEG VVVRAM	; #1 ﾃｷｽﾄｳｲﾝﾄﾞｳ２退避バッファ
		DW	SEG VVVRAM	; #2 ﾃｷｽﾄｳｲﾝﾄﾞｳ３退避バッファ
		DW	SEG VVVRAM	; #3 ﾃｷｽﾄｳｲﾝﾄﾞｳ５退避バッファ
		DW	SEG PARTBUF	; #4 通常パターンバッファ前半
		DW	SEG PARTBUF	; #5 通常パターンバッファ後半
		DW	TEXTBUF		; #6 text buffer.後半
		DW	TEXTBUF		; #7 text buffer.前中間
		DW	SEG PARTBUF	; #8 通常パターンバッファ前中間
		DW	SEG VVVRAM	; #9 退避バッファ
		DW	SEG PARTBUF	; #10 通常パターンバッファ後半50k
		DW	SEG VVVRAM	; #11 ﾃｷｽﾄｳｲﾝﾄﾞｳ7退避バッファ
		DW	SEG VVVRAM	; #12 ﾃｷｽﾄｳｲﾝﾄﾞｳ8退避バッファ
		DW	SEG VVVRAM	; #13 WIDDIRSL RPG方向選択ｳｲﾝﾄﾞｳ
		DW	SEG PARTBUF	; #14
		DW	SEG DATBIN2	; #15 pictuer data buffer.
		DW	SEG PROCWRK	; #16 子ﾌﾟﾛｾｽ用のﾜｰｸの後10Kbyte
		DW	TEXTBUF		; #17 JOB013.TXT時に残るｴﾘｱ
		DW	TEXTBUF		; #18 SSCOOK.TXT時に残るｴﾘｱ
		DW	SEG VVVRAM	; #19 ﾃｷｽﾄｳｲﾝﾄﾞｳ13退避バッファ
		DW	SEG VVVRAM	; #20 ﾃｷｽﾄｳｲﾝﾄﾞｳ14退避バッファ
		DW	SEG VVVRAM	; #21 ﾃｷｽﾄｳｲﾝﾄﾞｳ15退避バッファ
		DW	SEG PROCBUF	; #22 process buffer.("DSKTOOL.COM"用)
		DW	SEG PROCWRK	; #23 process work buffer.
		DW	SEG PLESS	; #24 pless segment.("WIDDISK.ASM"用)

TBLPATSEG_END	LABEL	WORD		;
		DW	2 DUP (0)

TBLPATTOP	LABEL	WORD	; パターン先頭オフセットテーブル
		DW	PARTBUF_TOP		; #0
		DW	VVVRAM_TOP		; #1	22,000byte
		DW	VVVRAM_TOP+22000	; #2	34,530byte
		DW	VVVRAM_TOP+56530	; #3	 9,000byte
		DW	PARTBUF_TOP		; #4	32,768byte
		DW	PARTBUF_TOP+32740	; #5	32,764byte
		DW	TEXT_TOP+32800		; #6	32,700byte
		DW	TEXT_TOP+12800		; #7	19,990byte
		DW	PARTBUF_TOP+12800	; #8	19,920byte
		DW	VVVRAM_TOP+22000	; #9	43,532byte
		DW	PARTBUF_TOP+14000	; #10	51,532byte
		DW	VVVRAM_TOP		; #11	32,766byte
		DW	VVVRAM_TOP+32768	; #12	32,766byte
		DW	VVVRAM_TOP+60000	; #13	 5,000byte
		DW	PARTBUF_TOP		; #14	12,800byte
		DW	DATBIN2_TOP		; #15	12,400byte
		DW	PROCWRK_END-13000	; #16	13,000byte
		DW	TEXT_END-10000		; #17	10,000byte
		DW	TEXT_END-16000		; #18	16,000byte
		DW	VVVRAM_TOP		; #19	21,800byte
		DW	VVVRAM_TOP+21800	; #20	21,800byte
		DW	VVVRAM_TOP+21800*2	; #21	21,800byte
		DW	PROCBUF_TOP+12500 ;;13000 ; #22	("DSKTOOL.COM"用)
		DW	PROCWRK_TOP		; #23	52,200byte
		DW	PLESS_SRT+1024		; #24	("WIDDISK.ASM"用)
		DW	2 DUP (0)

TBLPATEND	LABEL	WORD	; パターン終了オフセットテーブル
		DW	PARTBUF_END		; #0
		DW	VVVRAM_TOP+22000-2	; #1
		DW	VVVRAM_TOP+56530-2	; #2
		DW	VVVRAM_END		; #3
		DW	PARTBUF_TOP+32738 ;32768; #4
		DW	PARTBUF_END		; #5
		DW	TEXT_END		; #6
		DW	TEXT_TOP+32790		; #7
		DW	PARTBUF_TOP+32720	; #8
		DW	VVVRAM_END		; #9
		DW	PARTBUF_END		; #10
		DW	VVVRAM_TOP+32766	; #11
		DW	VVVRAM_END		; #12
		DW	VVVRAM_END		; #13
		DW	PARTBUF_TOP+12800	; #14
		DW	DATBIN2_END		; #15
		DW	PROCWRK_END		; #16
		DW	TEXT_END		; #17
		DW	TEXT_END		; #18
		DW	VVVRAM_TOP+21800	; #19
		DW	VVVRAM_TOP+21800*2	; #20
		DW	VVVRAM_TOP+21800*3	; #21
		DW	PROCBUF_END		; #22
		DW	PROCWRK_END		; #23
		DW	PLESS_SRT+32000		; #24
		DW	2 DUP (0)

MUSYA_BUF_SEG_TBL	LABEL	WORD	; 武者修行バッファセグメント
		DW	SEG PARTBUF	; #0 通常パターンバッファ
		DW	SEG PLESS	; #1 pless/unpless segment.
		DW	TEXTBUF		; #2 text buffer.
		DW	SEG PARTBUF	; #3 通常パターンバッファ
		DW	SEG PLESS	; #4 pless/unpless segment.
		DW	TEXTBUF		; #5 text buffer.
		DW	SEG VVVRAM	; #6 varturl vram.
		DW	SEG VVVRAM	; #7 varturl vram.
		DW	SEG PROCWRK	; #8 process work buffer 52k.

MUSYA_BUF_OFS_TBL	LABEL	WORD	; 武者修行バッファオフセット
		DW	32740		;#0 後半
		DW	32740		;#1 後半
		DW	32740		;#2 後半
		DW	32740+16390	;#3 後半
		DW	32740+16390	;#4 後半
		DW	32740+16390	;#5 後半
		DW	32740 - 16390	;#6 後半
		DW	32740		;#7 後半
		DW	PROCWRK_TOP	;#8

CLRCDE		DW	0	; color code.
CLRVEW		DW	0	; color view.
CLRCNS		DW	0	; contrast.
CLRBRI		DW	0	; brightness.

CRNUM		DW	0	; color code.       
CBLUE		DW	0	; blue  value (0-15)
CRED		DW	0	; red   value (0-15)
CGREEN		DW	0	; green value (0-15)

DATA	ENDS


; *********************************************************
;	part buffer.
; *********************************************************

;	parts buffer.

PARTBUF	SEGMENT	PUBLIC	'PARTBUF'
PARTBUF_TOP	LABEL	BYTE
	DW	32766 DUP (?)
PARTBUF_END	LABEL	BYTE
	DW	2 DUP (?)
PARTBUF	ENDS

;	pless buffer.

PLESS	SEGMENT	PUBLIC	'PLESS'
PLESS_SRT	LABEL	BYTE
	DW	32766 DUP (?)
	DW	2 DUP (?)
PLESS	ENDS

;	varturl vram.

VVVRAM	SEGMENT	PUBLIC	'VVVRAM'
VVVRAM_TOP	LABEL	BYTE
	DW	32766 DUP (?)
VVVRAM_END	LABEL	BYTE
	DW	2 DUP (?)
VVVRAM	ENDS

;	label tabel.

LBLBUFF	SEGMENT	PUBLIC	'LBLBUFF'
LABELADRS	DW	LBLADRS_DIM DUP (?)
LABELNAME	DB	LBLBUFF_LEN DUP (?)
LBLBUFF	ENDS

;	pictuer data buffer.
;
;	カレンダーデータ
;
;	FXCLND   PT1      2506 93-03-05   23:51
;	FXBIGN   PT1      1576 92-12-11   17:37
;	FXMONTH  PT1      2962 92-12-11   17:41
;	FXWEEK   PT1      1546 92-12-11   17:39
;	FXNUM    PT1       634 92-12-11   17:29
;	FXCOVER  PT1       926 93-03-06    0:09
;	FXBLOOD  PT1       836 92-12-15   19:00
;	FXMIDN   PT1       934 92-12-16   15:49
;	FXUNIT   PT1       118 92-12-18   13:49
;	FXKAZA   PT1      1698 93-03-06   19:08
;
;		total	 13736 byte
;
;	"PICTUER.ASM"のPT_CLEND_LDで読みだしている

DATBIN2	SEGMENT	PUBLIC	'DATBIN2'
DATBIN2_TOP	LABEL	BYTE
	DB	13800 DUP (?)
DATBIN2_END	LABEL	BYTE
DATBIN2	ENDS

;	process buffer.

PROCBUF	SEGMENT	PUBLIC	'PROCBUF'
PUBLIC	PROCBUF_TOP
PUBLIC	PROCBUF_END
PROCBUF_TOP	LABEL	BYTE
	DB	21000 DUP (?)	; <- "MUSYAE.COM" size + 100H
PROCBUF_END	LABEL	BYTE
PROCBUF	ENDS

;	process work buffer.(.map)

PROCWRK	SEGMENT	PUBLIC	'PROCWRK'
PROCWRK_TOP	LABEL	BYTE
	DB	52200 DUP (?)
PROCWRK_END	LABEL	BYTE
PROCWRK	ENDS

;*;ＥＭＳフレームへ移動しました
;*;;	text buffer.
;*;
;*;TEXTBUF	SEGMENT	PUBLIC	'TEXTBUF'
;*;TEXT_TAG	LABEL	BYTE
;*;	DB	4 DUP (?)	; TAG
;*;TEXT_TOP	LABEL	BYTE
;*;	DB	65500 DUP (?)
;*;TEXT_END	LABEL	BYTE
;*;	DB	32 DUP (?)
;*;TEXTBUF	ENDS


;	フリー領域の先頭セグメント
;	KS2MAIN.ASMの先頭を参照のこと

ENDSEG	SEGMENT	PUBLIC	'ENDSEG'
ENDSEG	ENDS

	END
;
;	end of "KS2TBL.ASM"
;
