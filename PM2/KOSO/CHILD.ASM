; "CHILD.ASM" 486/50 make by R.H 1992/07/18
;
;
;	child process.
;
;
; public subrountine.

INCLUDE	TSTSET.INC
INCLUDE	BBEXTRN.INC
INCLUDE	MACHINEX.INC
INCLUDE	DEBUGX.INC

RETFAR	MACRO			; ＦＡＲリターン
	DB	11001011B	; RETF
	ENDM

PATBANK_ICON		EQU	102	;ICON pattan bank number.
;;FL_CHECK_LEN_ICON	EQU	40000	;ICON.PT1     39532 93-02-02   23:48
;;FL_CHECK_LEN_ICON	EQU	45200	;ICON.PT1     45136 93-03-04   19:54
FL_CHECK_LEN_ICON	EQU	46070	;ICON.PT1     46068 93-04-07    1:38

CHILD_STRING_LEN	EQU	64	; child string length.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	CHILD_PROCESS_LOAD	; (*.com) child process load.
PUBLIC	CHILD_PROCESS_JUMP	; (*.com) child process jump.
PUBLIC	CHILD_PROCESS_HEAD	; (*.com) child process header set.
PUBLIC	CHILD_PROCESS_HEAD_RD	; (*.com) child process header read.
PUBLIC	CHILD_PROCESS_TIMER	; (*.com) child process timer.
PUBLIC	CHILD_PROCESS_TIMER_RD	; (*.com) child process timer read.
PUBLIC	CHILD_PROCESS_ICON	; (*.com) child process ICON set.

; *********************************************************
;	(*.com) child process load.
;	-I- SI : file name.
;	-O- AX : 0=normal,1=error.
;
;	"*.com" entry header.
;	DW	FUNCTION_ENTRY		;(+102h) function entry.
;	DW	0			;(+104h) main function inter offset.
;	DW	0			;(+106h) main function inter segment.
;
; *********************************************************

CHILD_PROCESS_LOAD	PROC	NEAR
	MOV	FLNAME_ADRS,SI			; file name.

	MOV	FLAG_CHILD_PROC_STANBY,0	; flag child process stanby.

	CALL	MODULE_LOAD			; module load.
	CMP	AX,0				;
	JNE	CHILD_PROCESS_LOAD_ERROR	;

	MOV	ES,PROCBUFFSEG			; process buffer segment.

					;(+102h) function entry.
	MOVX	CHILD_PROC_JUMP_OFS,ES:[102H]
	MOV	CHILD_PROC_JUMP_SEG,ES
					; child process jump address.

	MOV	WORD PTR ES:[104H],OFFSET INTER_PROCESS_JUMP
					;(+104h) main function inter offset.

	MOV	WORD PTR ES:[106H],SEG CODE01
					;(+106h) main function inter segment.

	MOVX	<WORD PTR ES:[13EH]>,CHILDDEMO	; (CHILD.ASM)デモフラグ
					;(+13eh) debug mode.

	MOV	AX,0			; 0=normal.
	RET
CHILD_PROCESS_LOAD_ERROR:
	MOV	AX,1			; 1=error.
	RET
CHILD_PROCESS_LOAD	ENDP


; *********************************************************
;	(*.com) child process.
;	-I- AX : child task function.
;	    BX : sub function.
;	    CH_PARAM01 : parameter 1.
;	    CH_PARAM02 : parameter 2.
;	    CH_PARAM03 : parameter 3.
;	    CH_PARAM04 : parameter 4.
;	    CH_PARAM05 : parameter 5.
;	    CH_PARAM06 : parameter 6.
;	-O- AX : child task exit status.
; *********************************************************

CHILD_PROCESS_JUMP	PROC	NEAR

	PUSH	DS

	MOV	ES,CHILD_PROC_JUMP_SEG		;
	MOV	ES:[10AH],AX			;(+10ah) function number.
	MOV	ES:[12CH],BX			;(+12ch) sub function number.

	MOVX	ES:[132H],CH_PARAM01		;(+132h) parameter 1.
	MOVX	ES:[134H],CH_PARAM02		;(+134h) parameter 2.
	MOVX	ES:[136H],CH_PARAM03		;(+136h) parameter 3.
	MOVX	ES:[138H],CH_PARAM04		;(+138h) parameter 4.
	MOVX	ES:[13AH],CH_PARAM05		;(+13ah) parameter 5.
	MOVX	ES:[13CH],CH_PARAM06		;(+13ch) parameter 6.

	MOV	AX,SEG CODE01			; return segment.
	PUSH	AX				;
	MOV	AX,OFFSET CHILD_PROCESS_JUMP_RET ;return offset.
	PUSH	AX				;
	PUSH	CHILD_PROC_JUMP_SEG		; jump segment.
	PUSH	CHILD_PROC_JUMP_OFS		; jump offset.
	MOV	AX,CHILD_PROC_JUMP_SEG		;
	MOV	DS,AX				;
	MOV	ES,AX				;
	RETFAR					; far jump.

CHILD_PROCESS_JUMP_RET:
	POP	DS
	MOV	ES,CHILD_PROC_JUMP_SEG		;
	MOV	AX,ES:[108H]			;(+108h) exit status.

	RET
CHILD_PROCESS_JUMP	ENDP


; *********************************************************
;	(*.com) child process header set.
;	-I- AX : 1=musyae.com
; *********************************************************

CHILD_PROCESS_HEAD	PROC	NEAR
	CMP	AX,1				; 1=musyae.com,
	JE	CHILD_PROCESS_HEAD_MUSYAE	;
	RET
CHILD_PROCESS_HEAD_MUSYAE:
	MOV	ES,PROCBUFFSEG			; process buffer segment.
	MOV	CX,CH_HEAD_LENGTH		; musya header len.
	MOV	DI,108H				;(+108h) map type.
	MOV	SI,OFFSET CH_HEAD_MUSYA		; musya header.
	REP	MOVSB				;
	RET
CHILD_PROCESS_HEAD	ENDP


; *********************************************************
;	(*.com) child process header read.
;	-I- AX : process. 1=musyae.com,
; *********************************************************

CHILD_PROCESS_HEAD_RD	PROC	NEAR
	CMP	AX,1				; 1=musyae.com,
	JE	CHILD_PROCESS_HEAD_RD2		;
	RET
CHILD_PROCESS_HEAD_RD2:
	MOVX	ES,DS				;
	MOV	DX,PROCBUFFSEG			; process buffer segment.
	MOV	CX,CH_HEAD_LENGTH		; musya header len.
	MOV	SI,108H				;(+108h) map type.
	MOV	DI,OFFSET CH_HEAD_MUSYA		; musya header.
	PUSH	DS
	MOV	DS,DX				;
	REP	MOVSB				;
	POP	DS
	RET
CHILD_PROCESS_HEAD_RD	ENDP


; *********************************************************
;	(*.com) child process timer.
;	-I- AX : wait timer count.
; *********************************************************

CHILD_PROCESS_TIMER	PROC	NEAR
	CALLE	TMVST5		; V-SYNC timer5 set.(child.asm)
	RET
CHILD_PROCESS_TIMER	ENDP


; *********************************************************
;	(*.com) child process timer read.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.
; *********************************************************

CHILD_PROCESS_TIMER_RD	PROC	NEAR
	CALLE	TMVCK5		; V-SYNC timer5 check.
	RET
CHILD_PROCESS_TIMER_RD	ENDP


; *********************************************************
;	(*.com) child process ICON set.
; *********************************************************

CHILD_PROCESS_ICON	PROC	NEAR
	MOV	AX,PROCWORKSEG		; process work buffer segment.
	MOV	BX,PROCWORKTOP		; process work buffer top.
	MOV	CX,PROCWORKEND		; process work buffer end.

	MOV	TBLPAT2SEG[2*2],AX	; 組込パターンセグメントテーブル
	MOV	TBLPAT2TOP[2*2],BX	; 組込パターン先頭オフセットテーブル
	MOV	TBLPAT2END[2*2],CX	; 組込パターン終了オフセットテーブル

	MOV	ES,PROCWORKSEG		; process work buffer segment.
	MOV	DI,PROCWORKTOP		; process work buffer top.
	MOV	CX,FL_CHECK_LEN_ICON	; ICON file check length.
	CALL	CHKSAM			; check sam.
	CMP	AX,ICONFILECHKSAM	; ICON file check sam.
	JE	CHILD_PROCESS_ICON_EXIT	;

	MOV	ES,PROCWORKSEG		; process work buffer segment.
	MOV	DI,PROCWORKTOP		; process work buffer top.
	MOV	CX,FL_CHECK_LEN_ICON	; ICON file check length.
	MOV	AL,0			;
	REP	STOSB			; zero clear.

	MOV	DX,PATBANK_ICON		; ICON pattan bank number.
	CALLE	C1PATBNK		; バンクチェンジ

	CALLE	C1PATCLR		; パーツセットクリア
	MOV	SI,OFFSET FILE_NAME_ICON ; ICON file name.
	CALLE	C1PATLDA		; パーツ追加ロード
	CMP	AX,0			; 0:normal,1:error.
	JNE	CHILD_PROCESS_ICON_EXIT	;

	MOV	ES,PROCWORKSEG		; process work buffer segment.
	MOV	DI,PROCWORKTOP		; process work buffer top.
	MOV	CX,FL_CHECK_LEN_ICON	; ICON file check length.
	CALL	CHKSAM			; check sam.
	MOV	ICONFILECHKSAM,AX	; ICON file check sam.

CHILD_PROCESS_ICON_EXIT:
	RET
CHILD_PROCESS_ICON	ENDP


; *********************************************************
;	check sam.
;	-i- ES:DI : check sam address.
;	    CX    : check sam length.
;	-O- AX    : check sam.
; *********************************************************

CHKSAM	PROC	NEAR
	MOV	AX,0			; check sam.
	CMP	CX,1000			; check sam length.
	JNB	CHKSAM_CHEK1000		;
CHKSAM_LOOP:				;
	ADD	AX,ES:[DI]		;
	INC	DI			;
	INC	DI			;
	LOOP	CHKSAM_LOOP		;
	RET
CHKSAM_CHEK1000:
	SHR	CX,1			;
	SHR	CX,1			;
	SHR	CX,1			;
	SHR	CX,1			;
	SHR	CX,1			;
	SHR	CX,1			;
	SHR	CX,1			; / 128
CHKSAM_LOOP2:				;
	ADD	AX,ES:[DI]		;
	ADD	DI,128			; + 128
	LOOP	CHKSAM_LOOP2		;
	RET
CHKSAM	ENDP


; *********************************************************
;	main function inter.
;	-I/O- BX,CX,DX,SI,DI,ES : user parameter.
; *********************************************************

INTER_PROCESS_JUMP	PROC	NEAR
	MOV	AX,SEG DATA
	MOV	DS,AX
	CALL	MAIN_FUNCTION			; main functions.
	RETFAR
INTER_PROCESS_JUMP	ENDP


; *********************************************************
;	main functions.
;
;	BX=1 : file load.
;		-I- ES:SI : file name.
;		    DX : memory segment address.
;		    DI : memory offset address.
;		    CX : memory size.
;		-O- BX : 0=normal,1=error.
;		    CX : data length.
;
;	BX=2 : disk save.
;		-I- ES:SI : file name.
;		    DX : memory segment address.
;		    DI : memory offset address.
;		    CX : memory size.
;		-O- BX : 0=normal,1=error.
;
;	BX=3 : disk check.
;		-I- ES:SI : file name.
;		-O- BX : 0=none,1=ok.
;
;	BX=4 : disk kill.
;		-I- ES:SI : file name.
;		-O- BX : 0=normal,1=error.
;
;	BX=5 : get vram address.
;		-O- ES:SI : vram table address.
;		    BX : machine ID.
;
;	BX=6 : get buffer address.
;		-I- SI :0=通常パターンバッファ・後半
;			1=pless/unpless segment・後半
;			2=text buffer.・後半
;			3=通常パターンバッファ・後半
;			4=pless/unpless segment・後半
;			5=text buffer・後半
;			6=varturl vram・後半
;			7=varturl vram・中間
;			8=process work buffer 52k.
;		-O- ES:DI : buffer address.
;
;	BX=7 : マウス読み込み
;		-O- CX : Ｘ座標
;		    BX : Ｙ座標
;		    DH : 左ボタン（1：ＯＦＦ／0：ＯＮ）
;		    DL : 右ボタン（1：ＯＦＦ／0：ＯＮ）
;		    SI : mouse locate direction x(+-)
;		    DI : mouse locate direction y(+-)
;
;	BX=8 : マウス方向
;		-O- CX : mouse locate direction x(+-)
;		    DX : mouse locate direction y(+-)
;
;	BX=9 : キーボード機能のＯＮ／ＯＦＦ
;		-I- CX : 1=ＯＮ,0=ＯＦＦ
;
;	BX=10 : timer.
;		-I- CX : wait timer count.
;
;	BX=11 : timer end wait.
;
;	BX=12 : process time out check.
;		-O- BX : 1=timer end.
;		    DX : now counter.
;
;	BX=13 : 98 vram switch.
;		-I- CX : 0=VRAM0 show, 1=VRAM1 show.
;		    DX : 0=VRAM0 write,1=VRAM1 write.
;
;	BX=14 : ＲＰＧ方向選択・ｳｲﾝﾄﾞｳOPEN
;
;	BX=15 : ＲＰＧ方向選択・ｳｲﾝﾄﾞｳCLOSE
;
;	BX=16 : ＲＰＧ方向選択・ｳｲﾝﾄﾞｳREAD
;		-O- BX : ボタン選択番号 0:none,1:上,2:下,3:左,4:右,5:ｷｬﾝﾌﾟ
;		    CX : x direction step.
;		    DX : y direction step.
;
;	BX=17 : WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG OPEN.
;		-I- ES:[SI]  : 指定文字列
;
;	BX=18 : WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG CLOSE.
;
;	BX=19 : WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG READ.
;		-O- BX : ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／ユーザ選択番号
;		       : =FFFFH : 指定なし
;		       : = -2   : 何も入力無し
;
;	BX=20 : timer check.
;		-O- BX : 0=timer now, 1=timer end.
;		    CX : now counter.
;
;	BX=21 : randam.
;		-I- CX : 最大値(1-200)
;		-O- BX : 乱数
;
;	BX=22 : ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE)
;		register load.
;		-I- CX : function number.
;		    DX : register table segment.
;		    SI : register table offset.
;		    DI : operation. 0=normal,1=SI string,2=SI string i/o.
;				    3=SI string out.
;		<< register table >>
;
;		DX:[SI][0]	: AX
;		DX:[SI][2]	: BX
;		DX:[SI][4]	: CX
;		DX:[SI][6]	: DX
;		DX:[SI][8]	: SI
;		DX:[SI][10]	: DI
;		DX:[SI][12]	: DS
;		DX:[SI][14]	: main DS
;		DX:[SI][16]	: ES
;
;	BX=23 : ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
;
;	BX=24 : set VX1,VY1,VX2,VY2,VX3,VY3
;		-I- CX : VX1
;		    DX : VY1
;		    SI : VX2
;		    DI : VY2
;		    BP : VX3
;		    ES : VY3
;
;	BX=25 : vram assign.
;		-I- CX : vram ID table.
;			0=ARAVRM : ＶＲＡＭプレーン
;			1=ARA001 : 仮想ＶＲＡＭプレーン(width40)
;			2=ARA002 : 仮想ＶＲＡＭプレーン(width42)
;			3=ARA003 : 仮想ＶＲＡＭプレーン(width60)
;			4=ARA004 : 仮想ＶＲＡＭプレーン(width56)
;			5=ARA005 : 仮想ＶＲＡＭ(単プレーンwidth60)
;			6=ARA006 : 仮想ＶＲＡＭ(単プレーンwidth40)
;			7=ARA007 : 仮想ＶＲＡＭ(単プレーンwidth40)
;			8=ARA008 : 仮想ＶＲＡＭ(単プレーンwidth40)
;			9=ARA009 : 仮想ＶＲＡＭ(単プレーンwidth47)
;		    DX : assign ID table.
;			0=SSGR0  : visual data segment plean.
;			1=SSGRV0 : visual data segment plean.
;			2=SSDES0 : visual data segment plean.
;			3=SSSOU0 : visual data segment plean.
;			4=SSEFC0 : visual data segment plean.
;			5=SSCUR0 : visual data segment plean.
;			6=SEGVT0 : visual data segment plean.
;
;	BX=26 : name in set.
;		-I- ES:SI : 初期設定項目のテーブル
;
;	BX=27 : get vram plean segment.
;		-I- CX : vram ID table.
;			0=ARAVRM : ＶＲＡＭプレーン
;			1=ARA001 : 仮想ＶＲＡＭプレーン(width40)
;			2=ARA002 : 仮想ＶＲＡＭプレーン(width42)
;			3=ARA003 : 仮想ＶＲＡＭプレーン(width60)
;			4=ARA004 : 仮想ＶＲＡＭプレーン(width56)
;			5=ARA005 : 仮想ＶＲＡＭ(単プレーンwidth60)
;			6=ARA006 : 仮想ＶＲＡＭ(単プレーンwidth40)
;			7=ARA007 : 仮想ＶＲＡＭ(単プレーンwidth40)
;			8=ARA008 : 仮想ＶＲＡＭ(単プレーンwidth40)
;			9=ARA009 : 仮想ＶＲＡＭ(単プレーンwidth47)
;		    DX : plean number.
;		-O- DX : segment.
;
;	BX=28 : ﾌﾚｰﾑ･ﾃﾞｰﾀﾛｰﾄﾞｾｰﾌﾞ(DSKTOOL.COM)
;		-I- CX : 表示位置Ｘ
;		    DX : 表示位置Ｙ
;		    SI : 大きさＸ
;		    DI : 大きさＹ
;
;	BX=29 : ﾃﾞｰﾀｾｸﾞﾒﾝﾄ取得
;		-O- DX : ﾃﾞｰﾀｾｸﾞﾒﾝﾄ
;
;	BX=30 : set VCOL
;		-I- CX : color.
;
; *********************************************************

MAIN_FUNCTION	PROC	NEAR
	CMP	BX,( MAIN_FUNCTION_JMPTBL_E - MAIN_FUNCTION_JMPTBL ) / 2
	JNB	MAIN_FUNCTION_SKIP
	SHL	BX,1		; word pointer.
	JMP	WORD PTR DS:MAIN_FUNCTION_JMPTBL[BX]
MAIN_FUNCTION_SKIP:
	RET
MAIN_F_FILELOAD:
	CALL	FLNMSET			; file name set.
	CALLE	DISKLD			; disk load.
	CMP	AX,0			;
	JNE	MAIN_F_FILELOAD_E	;
	MOV	BX,AX			; 0=normal,1=error.
	RET
MAIN_F_FILELOAD_E:
	PUSH	AX			;
	BBERROR_FAR	101		;
	POP	AX			;
	MOV	BX,AX			; 0=normal,1=error.
	RET
MAIN_F_FILESAVE:
	CALL	FLNMSET			; file name set.
	CALLE	DISKSV			; disk save.
	MOV	BX,AX			; 0=normal,1=error.
	RET
MAIN_F_FILECHECK:
	CALL	FLNMSET			; file name set.
	CALLE	DISKCK			; disk check.
	MOV	BX,AX			; 0=normal,1=error.
	RET
MAIN_F_FILEKILL:
	CALL	FLNMSET			; file name set.
	CALLE	DISKKI			; disk kill.
	MOV	BX,AX			; 0=normal,1=error.
	RET
MAIN_F_GET_VRAM_ADRS:
	MOV	SI,OFFSET ARAVRM	; ＶＲＡＭプレーン
	MOVX	ES,DS
	MOV	BX,MFLAG_MY		; machine flag.
	RET
MAIN_F_GET_BUFF_ADRS:
	SHL	SI,1			; word pointer.
	MOV	ES,MUSYA_BUF_SEG_TBL[SI] ; 武者修行バッファセグメント
	MOV	DI,MUSYA_BUF_OFS_TBL[SI] ; 武者修行バッファオフセット
	RET
MAIN_F_MOUSE:
	CALLE	MUSRED			; マウス読み込み
	MOV	CX,AX			; Ｘ座標
	PUSH	AX			;
	PUSH	BX			;
	PUSH	DX			;
	CALLE	KEYMUS_DIRECTION	; キーボード＆マウスの方向
	MOV	SI,AX			; mouse locate direction x(+-)
	MOV	DI,BX			; mouse locate direction y(+-)
	POP	DX
	POP	BX
	POP	AX
	RET
MAIN_F_MOUSE_DIR:
	CALLE	KEYMUS_DIRECTION	; キーボード＆マウスの方向
	MOV	CX,AX			; mouse locate direction x(+-)
	MOV	DX,BX			; mouse locate direction y(+-)
	RET
MAIN_F_MOUSE_KEYHLT:
	MOV	AX,CX			; 1=ＯＮ,0=ＯＦＦ
	CALLE	KEYHLT			; キーボード機能のＯＮ／ＯＦＦ
	CALLE	MUSDSP			; マウスＤＩＲのクリア
	RET
MAIN_F_TIMER:
	MOV	AX,CX			;
	;;CALLE	TMVSET			; V-SYNC timer set.
	CALLE	TMVST8			; V-SYNC timer8 set.(child.asm)
	RET
MAIN_F_TWAIT:
	;;CALLE	TMVEWT			; V-SYNC timer end wait.
	CALLE	TMVCK8			; V-SYNC timer8 check.
	CMP	AX,0			; 0=timer now, 1=timer end.
	JE	MAIN_F_TWAIT		;
	RET
MAIN_F_TIMEOUT_CHECK:
	CALLE	TMVCK5			; V-SYNC timer5 check.
	MOV	BX,AX			; 1=timer end.
	RET
MAIN_F_98VRAMCHG:
	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JNE	MAIN_F_98VRAMCHG_E	;
	PUSH	DX			;
	MOV	AX,CX			; 0=VRAM0 show, 1=VRAM1 show.
	CALLE	VRM98DP			; PC98 vram show bank.
	POP	AX			; 0=VRAM0 write,1=VRAM1 write.
	CALLE	VRM98WT			; PC98 vram write bank.
MAIN_F_98VRAMCHG_E:
	RET
MAIN_F_RPG_DIR_OPEN:
	CALLE	WIDDIRSL_OPEN		; WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳOPEN
	RET
MAIN_F_RPG_DIR_CLOSE:
	CALLE	WIDDIRSL_CLOSE		; WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳCLOSE
	RET
MAIN_F_RPG_DIR_READ:
	CALLE	WIDDIRSL_RD		; WINDOWS/ＲＰＧ方向選択・ｳｲﾝﾄﾞｳREAD
	RET
MAIN_F_RPG_SLC_OPEN:
	CALLE	WIDSLC_RPGOPEN		; WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG OPEN.
	RET
MAIN_F_RPG_SLC_CLOSE:
	CALLE	WIDSLC_RPGCLOSE		; WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG CLOSE.
	RET
MAIN_F_RPG_SLC_READ:
	CALLE	WIDSLC_RPGREAD		; WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG READ.
	MOV	BX,WIDSNM		; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／ユーザ選択番号
	RET
MAIN_F_TIMER_CHK:
	;;CALLE	TMVCHK			; V-SYNC timer check.
	CALLE	TMVCK8			; V-SYNC timer8 check.
	MOV	BX,AX			; 0=timer now, 1=timer end.
	MOV	CX,DX			; now counter.
	RET
MAIN_F_RANDAM:
	MOV	AX,CX			; 最大値(1-200)
	CALLE	RANDAM			; 乱数
	MOV	BX,AX			; 乱数
	RET
MAIN_F_CALL_CODE:
	CALL	REG_LOAD		; register load.
	CALL	FAR PTR CALL_CODE_GATE	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE)
	CALL	REG_SAVE		; register save.
	RET
MAIN_F_CALL_CODE01:
	CALL	REG_LOAD		; register load.
	CALL	CALL_CODE01_GATE	; ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
	CALL	REG_SAVE		; register save.
	RET
MAIN_F_SET_VX1:
	MOV	VX1,CX
	MOV	VY1,DX
	MOV	VX2,SI
	MOV	VY2,DI
	MOV	VX3,BP
	MOV	VY3,ES
	RET
MAIN_F_VRAM_ASSIGN:
	CALL	VRAM_ASSIGN		; vram assign.
	RET
MAIN_F_NAMEIN_SET:
	CALL	NAMEIN_SET		; name in set.
	RET
MAIN_F_GET_VRAM_SEG:
	CALL	GET_VRAM_SEGMENT	; get vram segment.
	RET
MAIN_F_FLAME_LDSV:
	MOV	WDX1,CX			; 表示位置Ｘ
	MOV	WDY1,DX			; 表示位置Ｙ
	MOV	WDX2,SI			; 大きさＸ
	MOV	WDY2,DI			; 大きさＹ   (DSKTOOL.COM)
	CALLE	WID_FLAME_DSKTOOL	; WINDOWS/ﾌﾚｰﾑ･ﾃﾞｰﾀﾛｰﾄﾞｾｰﾌﾞ
	RET
MAIN_F_DS_GET:
	MOV	DX,DS
	RET
MAIN_F_SET_VCOL:
	MOV	VCOL,CX			; color.
	RET
MAIN_FUNCTION	ENDP


; *********************************************************
;	vram assign.
;	-I- CX : vram ID table.
;		0=ARAVRM : ＶＲＡＭプレーン
;		1=ARA001 : 仮想ＶＲＡＭプレーン(width40)
;		2=ARA002 : 仮想ＶＲＡＭプレーン(width42)
;		3=ARA003 : 仮想ＶＲＡＭプレーン(width60)
;		4=ARA004 : 仮想ＶＲＡＭプレーン(width56)
;		5=ARA005 : 仮想ＶＲＡＭ(単プレーンwidth60)
;		6=ARA006 : 仮想ＶＲＡＭ(単プレーンwidth40)
;		7=ARA007 : 仮想ＶＲＡＭ(単プレーンwidth40)
;		8=ARA008 : 仮想ＶＲＡＭ(単プレーンwidth40)
;		9=ARA009 : 仮想ＶＲＡＭ(単プレーンwidth47)
;	    DX : assign ID table.
;		0=SSGR0  : visual data segment plean.
;		1=SSGRV0 : visual data segment plean.
;		2=SSDES0 : visual data segment plean.
;		3=SSSOU0 : visual data segment plean.
;		4=SSEFC0 : visual data segment plean.
;		5=SSCUR0 : visual data segment plean.
;		6=SEGVT0 : visual data segment plean.
; *********************************************************

VRAM_ASSIGN	PROC	NEAR
	CMP	CX,9
	JNBE	VRAM_ASSIGN_EXIT
	CMP	DX,6
	JNBE	VRAM_ASSIGN_EXIT

	MOV	BX,CX
	SHL	BX,1
	MOV	SI,ID_VRAM_TBL[BX]	; vram ID table.
	MOV	BX,DX
	SHL	BX,1
	MOV	DI,ID_PLEAN_TBL[BX]	; assign ID table.
	MOVX	ES,DS
	MOV	CX,5
	REP	MOVSW
VRAM_ASSIGN_EXIT:
	RET
VRAM_ASSIGN	ENDP


; *********************************************************
;	get vram segment.
;	-I- CX : vram ID table.
;		0=ARAVRM : ＶＲＡＭプレーン
;		1=ARA001 : 仮想ＶＲＡＭプレーン(width40)
;		2=ARA002 : 仮想ＶＲＡＭプレーン(width42)
;		3=ARA003 : 仮想ＶＲＡＭプレーン(width60)
;		4=ARA004 : 仮想ＶＲＡＭプレーン(width56)
;		5=ARA005 : 仮想ＶＲＡＭ(単プレーンwidth60)
;		6=ARA006 : 仮想ＶＲＡＭ(単プレーンwidth40)
;		7=ARA007 : 仮想ＶＲＡＭ(単プレーンwidth40)
;		8=ARA008 : 仮想ＶＲＡＭ(単プレーンwidth40)
;		9=ARA009 : 仮想ＶＲＡＭ(単プレーンwidth47)
;	    DX : plean number.
;	-O- DX : segment.
; *********************************************************

GET_VRAM_SEGMENT	PROC	NEAR
	CMP	CX,9
	JNBE	GET_VRAM_SEGMENT_NONE
	CMP	DX,3
	JNBE	GET_VRAM_SEGMENT_NONE

	MOV	BX,CX
	SHL	BX,1
	MOV	SI,ID_VRAM_TBL[BX]	; vram ID table.
	MOV	BX,DX
	SHL	BX,1
	MOV	DX,DS:[SI][BX]
	RET

GET_VRAM_SEGMENT_NONE:
	MOV	DX,0A000H
	RET
GET_VRAM_SEGMENT	ENDP


; *********************************************************
;	name in set.
;	-I- ES:SI : 初期設定項目のテーブル
; *********************************************************

NAMEIN_SET	PROC	NEAR
	MOV	BX,SI
	MOVX	P_BORTHYEAR,	ES:[BX]		;(+00) 娘の誕生年
	MOVX	P_BORTHMONTH,	ES:[BX][2]	;(+02) 娘の誕生月
	MOVX	P_BORTHDAY,	ES:[BX][4]	;(+04) 娘の誕生日
	MOVX	P_NENREI,	ES:[BX][6]	;(+06) 娘の年齢

	MOVX	P_BORTHYEAR[2],	ES:[BX][8]	;(+08) 父の誕生年
	MOVX	P_BORTHMONTH[2],ES:[BX][10]	;(+10) 父の誕生月
	MOVX	P_BORTHDAY[2],	ES:[BX][12]	;(+12) 父の誕生日
	MOVX	P_NENREI[2],	ES:[BX][14]	;(+14) 父の年齢

	MOVX	P_BLOOD,	ES:[BX][16]	;(+16) 娘の血液型

	PUSH	ES
	MOVX	ES,DS
	MOV	DI,NAME_FIRST			; 名前
	MOV	CX,NAME_FIRST_LEN		; 名前長さ
	MOV	AL,0
	REP	STOSB
	POP	ES

	PUSH	ES
	MOVX	ES,DS
	MOV	DI,NAME_FAMILY			; 名前(family)
	MOV	CX,NAME_FAMILY_LEN		; 名前長さ(family)
	MOV	AL,0
	REP	STOSB
	POP	ES

	PUSH	ES
	PUSH	DS
	MOV	AX,ES
	MOV	DX,DS
	MOV	SI,ES:[BX][18]			;(+18) ファーストネーム
	MOV	DI,NAME_FIRST			; 名前
	MOV	CX,ES:[BX][22]			;(+22) ファーストネーム長さ
	MOV	DS,AX
	MOV	ES,DX
	REP	MOVSB
	POP	DS
	POP	ES

	PUSH	ES
	PUSH	DS
	MOV	AX,ES
	MOV	DX,DS
	MOV	SI,ES:[BX][20]			;(+20) ファミリーネーム
	MOV	DI,NAME_FAMILY			; 名前(family)
	MOV	CX,ES:[BX][24]			;(+24) ファミリーネーム長さ
	MOV	DS,AX
	MOV	ES,DX
	REP	MOVSB
	POP	DS
	POP	ES

	RET
NAMEIN_SET	ENDP


; *********************************************************
;	file name set.
;	-I- ES:SI : file name.
;	-O- FLNM  : file name.
;	    SI    : file name.
; *********************************************************

FLNMSET	PROC	NEAR
	PUSH	DI
	PUSH	CX
	MOV	DI,OFFSET FLNM		; file name.
	MOV	CX,12			; file name length.
	CALLE	STRSETZ			; 文字列バッファセット
	MOV	SI,OFFSET FLNM		; file name.
	POP	CX
	POP	DI
	RET
FLNMSET	ENDP


; *********************************************************
;	module load.
;	-I- FLNAME_ADRS : file name.
;	-O- AX          : 0=normal,1=error.
; *********************************************************

MODULE_LOAD	PROC	NEAR
	MOV	DX,PROCBUFFSEG			; process buffer segment.
	MOV	DI,100H				; process buffer top.
	MOV	CX,PROCBUFFEND			; process buffer end.
	SUB	CX,DI				; - top.
	MOV	SI,FLNAME_ADRS			; file name.
	CALLE	DISKLD				; disk load.
	CMP	AX,0				; 0=normal,1=error.
	JNE	MODULE_LOAD_ERROR		;
	MOV	AX,0
	RET
MODULE_LOAD_ERROR:
	BBERROR_FAR	101			;
	MOV	AX,1
	RET
MODULE_LOAD	ENDP


; *********************************************************
;	ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE01)
;	-I- WGATE_FUNCNUM       : function number.
; *********************************************************

CALL_CODE01_GATE	PROC	NEAR
	MOV	BP,WGATE_FUNCNUM		; function number.
	CMP	BP,( TBL_CALL_CODE01_GATE_E - TBL_CALL_CODE01_GATE ) / 2
	JNB	CALL_CODE_GATE_SKIP
	SHL	BP,1				; word pointer.
	CALL	WORD PTR DS:TBL_CALL_CODE01_GATE[BP]
CALL_CODE_GATE_SKIP:
	RET
CALL_CODE01_GATE	ENDP


; *********************************************************
;	register load.
;	-I- CX : function number.
;	    DX : register table segment.
;	    SI : register table offset.
;	    DI : operation. 0=normal,1=SI string,2=SI string i/o.
;			    3=SI string out.
;
;	<< register table >>
;
;	DX:[SI][0]	: AX
;	DX:[SI][2]	: BX
;	DX:[SI][4]	: CX
;	DX:[SI][6]	: DX
;	DX:[SI][8]	: SI
;	DX:[SI][10]	: DI
;	DX:[SI][12]	: DS
;	DX:[SI][14]	: main DS
;	DX:[SI][16]	: ES
;
; *********************************************************

REG_LOAD	PROC	NEAR
	MOV	WGATE_FUNCNUM,CX		; function number.
	MOV	WGATE_REG_TABLE_SEG,DX		; register table segment.
	MOV	WGATE_REG_TABLE_OFS,SI		; register table offset.
	MOV	WGATE_OPERA,DI			; operation.

	CMP	WGATE_OPERA,0			; operation.
	JE	REG_LOAD_2			;
	CMP	WGATE_OPERA,3			; operation.
	JE	REG_LOAD_2			;

	MOV	BP,WGATE_REG_TABLE_OFS		; register table offset.
	MOV	ES,WGATE_REG_TABLE_SEG		; register table segment.
	MOV	SI,ES:[BP][8]			;
	MOV	DX,ES:[BP][12]			;

	PUSH	DS				;
	MOVX	ES,DS				;
	MOV	DS,DX				;
	MOV	DI,OFFSET CHILD_STRING		; child string.
	MOV	CX,CHILD_STRING_LEN		; child string.
	REP	MOVSB				; copy.
	POP	DS				;

REG_LOAD_2:
	MOV	BP,WGATE_REG_TABLE_OFS		; register table offset.
	MOV	ES,WGATE_REG_TABLE_SEG		; register table segment.
	MOV	AX,ES:[BP]
	MOV	BX,ES:[BP][2]
	MOV	CX,ES:[BP][4]
	MOV	DX,ES:[BP][6]
	MOV	SI,ES:[BP][8]
	MOV	DI,ES:[BP][10]
	PUSH	AX
	MOV	AX,ES:[BP][16]
	MOV	ES,AX
	POP	AX

	CMP	WGATE_OPERA,0			; operation.
	JE	REG_LOAD_8			;
	CMP	WGATE_OPERA,3			; operation.
	JE	REG_LOAD_8			;

	MOV	SI,OFFSET CHILD_STRING		; child string.
REG_LOAD_8:
	RET
REG_LOAD	ENDP


; *********************************************************
;	register save.
; *********************************************************

REG_SAVE	PROC	NEAR
	CMP	WGATE_OPERA,2			; 2=SI string i/o.
	JNE	REG_SAVE_2			;

	PUSH	ES
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	MOV	BP,WGATE_REG_TABLE_OFS		; register table offset.
	MOV	ES,WGATE_REG_TABLE_SEG		; register table segment.
	MOV	DI,ES:[BP][8]			;
	MOV	DX,ES:[BP][12]			;

	MOV	ES,DX				;
	MOV	SI,OFFSET CHILD_STRING		; child string.
	MOV	CX,CHILD_STRING_LEN		; child string.
	REP	MOVSB				; copy.
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	ES

;*;	PRS	"*main*",CHILD_STRING		; child string.

REG_SAVE_2:
	PUSH	ES
	MOV	BP,WGATE_REG_TABLE_OFS		; register table offset.
	MOV	ES,WGATE_REG_TABLE_SEG		; register table segment.
	MOV	ES:[BP],AX
	MOV	ES:[BP][2],BX
	MOV	ES:[BP][4],CX
	MOV	ES:[BP][6],DX
	MOV	ES:[BP][10],DI
	MOV	ES:[BP][14],DS

	CMP	WGATE_OPERA,2			; 2=SI string i/o.
	JE	REG_SAVE_8			;
	MOV	ES:[BP][8],SI
REG_SAVE_8:
	POP	AX
	MOV	ES:[BP][16],AX
	RET
REG_SAVE	ENDP

CODE01	ENDS


CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:DATA

; *********************************************************
;	ﾒｲﾝのｻﾌﾞﾙｰﾁﾝcall.(seg CODE)
;	-I- WGATE_FUNCNUM       : function number.
; *********************************************************

CALL_CODE_GATE	PROC	FAR
	RET
CALL_CODE_GATE	ENDP

CODE	ENDS

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

EXTRN	PRINT:NEAR			; 0:print string.
EXTRN	DECSTR:NEAR			; 1:val DX to dec string.
EXTRN	STRDEC:NEAR			; 2:dec string to DX reg.
EXTRN	HEXSTR:NEAR			; 3:val DX to hex string.
EXTRN	STRHEX:NEAR			; 4:hex string to DX reg.
EXTRN	BINSTR:NEAR			; 5:val DX to bin string.
EXTRN	STRBIN:NEAR			; 6:bin string to DX reg.
EXTRN	CHPUT:NEAR			; 7:print of ascii character.
EXTRN	PRNAB:NEAR			; 8:print of a register(BIN).
EXTRN	LFPRN:NEAR			; 9:line feed.
EXTRN	D10STR:NEAR			;10:i*4 value -> decimal string.
EXTRN	STRZTS:NEAR			;11:zero to space. "00123"->"  123"
EXTRN	STRSPL:NEAR			;12:space pless. "  123"->"123  "
EXTRN	MSCSRT:NEAR			;13:カーソルスタート
EXTRN	MSCMOV:NEAR			;14:カーソル移動
EXTRN	MSCMV2:NEAR			;15:カーソル移動（遅延処理無し）
EXTRN	MSCSTP:NEAR			;16:カーソルストップ
EXTRN	MSCSTS:NEAR			;17:マウスカーソルステータス
EXTRN	MSWWAT:NEAR			;18:カーソルボタン待ち
EXTRN	KEYTEN:NEAR			;19:キーボード・読み込み
EXTRN	FEDIN:NEAR			;20:Ｆ・Ｉ（フェードイン）
EXTRN	FEDOUT:NEAR			;21:Ｆ・Ｏ（フェードアウト）
EXTRN	WHTIN:NEAR			;22:ＷＨＩＴＥ・ＩＮ
EXTRN	WHTOUT:NEAR			;23:ＷＨＩＴＥ・ＯＵＴ
EXTRN	BLACK:NEAR			;24:ブラックアウト
EXTRN	WHITE:NEAR			;25:ＷＨＩＴＥ
EXTRN	PLTOL:NEAR			;26:パレット・オーバラップ
EXTRN	PLTMIX:NEAR			;27:パレット・混合
EXTRN	NORMIN:NEAR			;28:ノーマルカラー
EXTRN	PLTFIS:NEAR			;29:Ｆ・Ｉ／時分割初期
EXTRN	PLTFOS:NEAR			;30:Ｆ・Ｏ／時分割初期
EXTRN	PLTCIS:NEAR			;31:カラー・ＩＮ／時分割初期
EXTRN	PLTOLS:NEAR			;32:ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割初期
EXTRN	PLTOLSE:NEAR			;33:ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割初期/編集機能
EXTRN	PLTOLT:NEAR			;34:ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割処理
EXTRN	PLTOLTE:NEAR			;35:ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割処理/編集機能
EXTRN	TMVWAT:NEAR			;36:V-SYNC timer wait.
EXTRN	TMVSET:NEAR			;37:V-SYNC timer set.
EXTRN	TMVCHK:NEAR			;38:V-SYNC timer check.
EXTRN	TMVEWT:NEAR			;39:V-SYNC timer end wait.
EXTRN	TMVST2:NEAR			;40:V-SYNC timer2 set.
EXTRN	TMVCK2:NEAR			;41:V-SYNC timer2 check.
EXTRN	TMVST3:NEAR			;42:V-SYNC timer3 set.
EXTRN	TMVCK3:NEAR			;43:V-SYNC timer3 check.
EXTRN	VTXPRN:NEAR			;44:vram text print.
EXTRN	VTXPOR:NEAR			;45:vram text print OR.
EXTRN	VTXPFC:NEAR			;46:vram text print fuchi.
EXTRN	VTXSIZ:NEAR			;47:character size set.
EXTRN	VTXCOL:NEAR			;48:character color set.
EXTRN	BOXPAL:NEAR			;49:ＢＯＸペイント
EXTRN	BOXMSS:NEAR			;50:ＢＯＸメッシュ
EXTRN	BOXNOT:NEAR			;51:ＢＯＸ反転
EXTRN	BOXMCH:NEAR			;52:ＢＯＸチェック模様
EXTRN	PT_PALET_SETONLY:NEAR		;53:パレットテーブルセットのみ
EXTRN	PT_PATTERN_LD:NEAR		;54:pattern load.
EXTRN	PT_PATTERN_LDA:NEAR		;55:pattern add load.
EXTRN	PT_PATTERN_PUT:NEAR		;56:pattern put.
EXTRN	PT_MASK_PAT_PUT:NEAR		;57:pattern mask put.
EXTRN	PT_MASK_PTF_PUT:NEAR		;58:pattern mask offset put.
EXTRN	PT_PATTERN_BANK:NEAR		;59:pattern bank set.
EXTRN	PT_VRAM_ID_ALL_ASSIGN:NEAR	;60:vram ID all asigned.
EXTRN	WIDCLEN_MONTH:NEAR		;61:WINDOWS/カレンダー・月データ
EXTRN	MITPRN:NEAR			;62:mini string.
EXTRN	MITCOL:NEAR			;63:mini string color.
EXTRN	MDTPRN:NEAR			;64:MID string.
EXTRN	MWTPRN:NEAR			;65:WIDE string.
EXTRN	MBTPRN:NEAR			;66:BIG string.
EXTRN	MGXPRN:NEAR			;67:GAINAX mini string.
EXTRN	MGXPRNP:NEAR			;68:GAINAX mini string.(put)
EXTRN	PT_PATTERN_CLEAR:NEAR		;69:parts buffer clear.
EXTRN	PT_PATTERN_GET:NEAR		;70:parts get.
EXTRN	MOVEVR:NEAR			;71:vram to vram move.
EXTRN	MOV1VR:NEAR			;72:vram to vram move 1 plean.
EXTRN	DLINEH:NEAR			;73:水平ライン描画
EXTRN	DLINEHBT:NEAR			;74:水平ライン描画点線
EXTRN	DLINEV:NEAR			;75:垂直ライン描画
EXTRN	PT_PATTERN_MODE:NEAR		;76:parts put mode.
EXTRN	DKRESET:NEAR			;77:disk reset.
EXTRN	DSKWID_OPEN:NEAR		;78:ディスク・ウインドウＯＰＥＮ
EXTRN	DSKWID_CLOSE:NEAR		;79:ディスク・ウインドウＣＬＯＳＥ
EXTRN	DSKWID_SET_MESSAGE:NEAR		;80:ディスク・セットメッセージ
EXTRN	DSKWID_SRT_PRINT:NEAR		;81:ディスク・メッセージ表示
EXTRN	DSKWID_FNAME_PRINT:NEAR		;82:ディスク・ファイル名表示
EXTRN	DSKWID_PATH_NM_SET:NEAR		;83:ディスク・パス名セット
EXTRN	DSKWID_USERWAIT:NEAR		;84:ディスク・ユーザ待ち
EXTRN	DSKWID_USERSTANBY:NEAR		;85:ディスク・ユーザスタンバイ
EXTRN	DSKWID_LED:NEAR			;86:ディスク・アクセスランプ
EXTRN	DKCDRVRESET:NEAR		;87:ディスクドライブ検索のリセット
EXTRN	DSKWID_USERST_INI:NEAR		;88:ディスク・ユーザスタンバイ初期化

CODE01	ENDS


; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	CHILDDEMO			; (CHILD.ASM)デモフラグ
					; 0=通常,55=ランダムセレクト

EXTRN	PROCBUFFSEG:WORD		; process buffer segment.
EXTRN	PROCBUFFTOP:WORD		; process buffer top.
EXTRN	PROCBUFFEND:WORD		; process buffer end.

EXTRN	PROCWORKSEG:WORD		; process work buffer segment.
EXTRN	PROCWORKTOP:WORD		; process work buffer top.
EXTRN	PROCWORKEND:WORD		; process work buffer end.

EXTRN	TBLPAT2SEG:WORD			; 組込パターンセグメントテーブル
EXTRN	TBLPAT2TOP:WORD			; 組込パターン先頭オフセットテーブル
EXTRN	TBLPAT2END:WORD			; 組込パターン終了オフセットテーブル

EXTRN	MUSYA_BUF_SEG_TBL:WORD		; 武者修行バッファセグメント
EXTRN	MUSYA_BUF_OFS_TBL:WORD		; 武者修行バッファオフセット

EXTRN	MUSDRX:WORD			; mouse locate direction x(+-)
EXTRN	MUSDRY:WORD			; mouse locate direction y(+-)

EXTRN	CH_HEAD_MUSYA:WORD		; musya header.
EXTRN	CH_HEAD_MUSYA_E:WORD		; musya header end.
EXTRN	CH_HEAD_LENGTH:WORD		; musya header len.

EXTRN	CH_PARAM01:WORD			; parameter 1.
EXTRN	CH_PARAM02:WORD			; parameter 2.
EXTRN	CH_PARAM03:WORD			; parameter 3.
EXTRN	CH_PARAM04:WORD			; parameter 4.
EXTRN	CH_PARAM05:WORD			; parameter 5.
EXTRN	CH_PARAM06:WORD			; parameter 6.

EXTRN	WIDSNM:WORD			; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／ユーザ選択番号

EXTRN	VX1:WORD			; point x1.
EXTRN	VY1:WORD			; point y1.
EXTRN	VX2:WORD			; point x2.
EXTRN	VY2:WORD			; point y2.
EXTRN	VX3:WORD			; point x3.
EXTRN	VY3:WORD			; point y3.
EXTRN	VCOL:WORD			; color.

EXTRN	ARAVRM:WORD			; ＶＲＡＭプレーン
EXTRN	ARA001:WORD			; 仮想ＶＲＡＭプレーン(width40)
EXTRN	ARA002:WORD			; 仮想ＶＲＡＭプレーン(width42)
EXTRN	ARA003:WORD			; 仮想ＶＲＡＭプレーン(width60)
EXTRN	ARA004:WORD			; 仮想ＶＲＡＭプレーン(width56)
EXTRN	ARA005:WORD			; 仮想ＶＲＡＭ(単プレーンwidth60)
EXTRN	ARA006:WORD			; 仮想ＶＲＡＭ(単プレーンwidth40)
EXTRN	ARA007:WORD			; 仮想ＶＲＡＭ(単プレーンwidth40)
EXTRN	ARA008:WORD			; 仮想ＶＲＡＭ(単プレーンwidth40)
EXTRN	ARA009:WORD			; 仮想ＶＲＡＭ(単プレーンwidth47)

EXTRN	SSGR0:WORD			; visual data segment plean.
EXTRN	SSGRV0:WORD			; visual data segment plean.
EXTRN	SSDES0:WORD			; visual data segment plean.
EXTRN	SSSOU0:WORD			; visual data segment plean.
EXTRN	SSEFC0:WORD			; visual data segment plean.
EXTRN	SSCUR0:WORD			; visual data segment plean.
EXTRN	SEGVT0:WORD			; visual data segment plean.

EXTRN	NAME_FIRST_LEN:WORD		; 名前長さ
EXTRN	NAME_FAMILY_LEN:WORD		; 名前長さ(family)

EXTRN	NAME_FIRST:WORD			; 名前
EXTRN	NAME_FAMILY:WORD		; 名前(family)

EXTRN	P_BLOOD:WORD			; 血液型
EXTRN	P_NENREI:WORD			; 年齢
EXTRN	P_BORTHDAY:WORD			; 誕生日
EXTRN	P_BORTHMONTH:WORD		; 誕生月
EXTRN	P_BORTHYEAR:WORD		; 誕生年
EXTRN	P_SHIKYU:WORD			; 子宮名
EXTRN	P_SYUGOSEI:WORD			; 守護星

EXTRN	WDX1:WORD			; WINDOWS/point x1.
EXTRN	WDY1:WORD			; WINDOWS/point y1.
EXTRN	WDX2:WORD			; WINDOWS/point x2.
EXTRN	WDY2:WORD			; WINDOWS/point y2.

CHILDDEMO	DW	0		;デモフラグ0=通常,55=ランダムセレクト

FLAG_CHILD_PROC_STANBY	DW	0	; flag child process stanby.

CHILD_PROC_JUMP_ADRS	LABEL	DWORD	; child process jump address.
CHILD_PROC_JUMP_OFS	DW	0	;
CHILD_PROC_JUMP_SEG	DW	0	;

INTER_PROCESS_ADRS	LABEL	DWORD	; main function inter address.
INTER_PROCESS_OFS	DW	0	;
INTER_PROCESS_SEG	DW	0	;

FLNAME_ADRS	DW	0		; file name.

MAIN_FUNCTION_JMPTBL	LABEL	WORD
	DW	MAIN_FUNCTION_SKIP	;0
	DW	MAIN_F_FILELOAD		;1
	DW	MAIN_F_FILESAVE		;2
	DW	MAIN_F_FILECHECK	;3
	DW	MAIN_F_FILEKILL		;4
	DW	MAIN_F_GET_VRAM_ADRS	;5
	DW	MAIN_F_GET_BUFF_ADRS	;6
	DW	MAIN_F_MOUSE		;7
	DW	MAIN_F_MOUSE_DIR	;8
	DW	MAIN_F_MOUSE_KEYHLT	;9
	DW	MAIN_F_TIMER		;10
	DW	MAIN_F_TWAIT		;11
	DW	MAIN_F_TIMEOUT_CHECK	;12
	DW	MAIN_F_98VRAMCHG	;13
	DW	MAIN_F_RPG_DIR_OPEN	;14
	DW	MAIN_F_RPG_DIR_CLOSE	;15
	DW	MAIN_F_RPG_DIR_READ	;16
	DW	MAIN_F_RPG_SLC_OPEN	;17
	DW	MAIN_F_RPG_SLC_CLOSE	;18
	DW	MAIN_F_RPG_SLC_READ	;19
	DW	MAIN_F_TIMER_CHK	;20
	DW	MAIN_F_RANDAM		;21
	DW	MAIN_F_CALL_CODE	;22
	DW	MAIN_F_CALL_CODE01	;23
	DW	MAIN_F_SET_VX1		;24
	DW	MAIN_F_VRAM_ASSIGN	;25
	DW	MAIN_F_NAMEIN_SET	;26
	DW	MAIN_F_GET_VRAM_SEG	;27
	DW	MAIN_F_FLAME_LDSV	;28
	DW	MAIN_F_DS_GET		;29
	DW	MAIN_F_SET_VCOL		;30
MAIN_FUNCTION_JMPTBL_E	LABEL	WORD

WGATE_FUNCNUM		DW	0	; function number.
WGATE_OPERA		DW	0	; operation.
WGATE_REG_TABLE_OFS	DW	0	; register table offset.
WGATE_REG_TABLE_SEG	DW	0	; register table segment.

TBL_CALL_CODE01_GATE	LABEL	WORD
	DW	PRINT			; 0:print string.
	DW	DECSTR			; 1:val DX to dec string.
	DW	STRDEC			; 2:dec string to DX reg.
	DW	HEXSTR			; 3:val DX to hex string.
	DW	STRHEX			; 4:hex string to DX reg.
	DW	BINSTR			; 5:val DX to bin string.
	DW	STRBIN			; 6:bin string to DX reg.
	DW	CHPUT			; 7:print of ascii character.
	DW	PRNAB			; 8:print of a register(BIN).
	DW	LFPRN			; 9:line feed.
	DW	D10STR			;10:i*4 value -> decimal string.
	DW	STRZTS			;11:zero to space. "00123"->"  123"
	DW	STRSPL			;12:space pless. "  123"->"123  "
	DW	MSCSRT			;13:カーソルスタート
	DW	MSCMOV			;14:カーソル移動
	DW	MSCMV2			;15:カーソル移動（遅延処理無し）
	DW	MSCSTP			;16:カーソルストップ
	DW	MSCSTS			;17:マウスカーソルステータス
	DW	MSWWAT			;18:カーソルボタン待ち
	DW	KEYTEN			;19:キーボード・読み込み
	DW	FEDIN			;20:Ｆ・Ｉ（フェードイン）
	DW	FEDOUT			;21:Ｆ・Ｏ（フェードアウト）
	DW	WHTIN			;22:ＷＨＩＴＥ・ＩＮ
	DW	WHTOUT			;23:ＷＨＩＴＥ・ＯＵＴ
	DW	BLACK			;24:ブラックアウト
	DW	WHITE			;25:ＷＨＩＴＥ
	DW	PLTOL			;26:パレット・オーバラップ
	DW	PLTMIX			;27:パレット・混合
	DW	NORMIN			;28:ノーマルカラー
	DW	PLTFIS			;29:Ｆ・Ｉ／時分割初期
	DW	PLTFOS			;30:Ｆ・Ｏ／時分割初期
	DW	PLTCIS			;31:カラー・ＩＮ／時分割初期
	DW	PLTOLS			;32:ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割初期
	DW	PLTOLSE			;33:ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割初期/編集機能
	DW	PLTOLT			;34:ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割処理
	DW	PLTOLTE			;35:ﾊﾟﾚｯﾄ･ｵｰﾊﾞﾗｯﾌﾟ/時分割処理/編集機能
	DW	TMVWAT			;36:V-SYNC timer wait.
	DW	TMVSET			;37:V-SYNC timer set.
	DW	TMVCHK			;38:V-SYNC timer check.
	DW	TMVEWT			;39:V-SYNC timer end wait.
	DW	TMVST2			;40:V-SYNC timer2 set.
	DW	TMVCK2			;41:V-SYNC timer2 check.
	DW	TMVST3			;42:V-SYNC timer3 set.
	DW	TMVCK3			;43:V-SYNC timer3 check.
	DW	VTXPRN			;44:vram text print.
	DW	VTXPOR			;45:vram text print OR.
	DW	VTXPFC			;46:vram text print fuchi.
	DW	VTXSIZ			;47:character size set.
	DW	VTXCOL			;48:character color set.
	DW	BOXPAL			;49:ＢＯＸペイント
	DW	BOXMSS			;50:ＢＯＸメッシュ
	DW	BOXNOT			;51:ＢＯＸ反転
	DW	BOXMCH			;52:ＢＯＸチェック模様
	DW	PT_PALET_SETONLY	;53:パレットテーブルセットのみ
	DW	PT_PATTERN_LD		;54:pattern load.
	DW	PT_PATTERN_LDA		;55:pattern add load.
	DW	PT_PATTERN_PUT		;56:pattern put.
	DW	PT_MASK_PAT_PUT		;57:pattern mask put.
	DW	PT_MASK_PTF_PUT		;58:pattern mask offset put.
	DW	PT_PATTERN_BANK		;59:pattern bank set.
	DW	PT_VRAM_ID_ALL_ASSIGN	;60:vram ID all asigned.
	DW	WIDCLEN_MONTH		;61:WINDOWS/カレンダー・月データ
	DW	MITPRN			;62:mini string.
	DW	MITCOL			;63:mini string color.
	DW	MDTPRN			;64:MID string.
	DW	MWTPRN			;65:WIDE string.
	DW	MBTPRN			;66:BIG string.
	DW	MGXPRN			;67:GAINAX mini string.
	DW	MGXPRNP			;68:GAINAX mini string.(put)
	DW	PT_PATTERN_CLEAR	;69:parts buffer clear.
	DW	PT_PATTERN_GET		;70:parts get.
	DW	MOVEVR			;71:vram to vram move.
	DW	MOV1VR			;72:vram to vram move 1 plean.
	DW	DLINEH			;73:水平ライン描画
	DW	DLINEHBT		;74:水平ライン描画点線
	DW	DLINEV			;75:垂直ライン描画
	DW	PT_PATTERN_MODE		;76:parts put mode.
	DW	DKRESET			;77:disk reset.
	DW	DSKWID_OPEN		;78:ディスク・ウインドウＯＰＥＮ
	DW	DSKWID_CLOSE		;79:ディスク・ウインドウＣＬＯＳＥ
	DW	DSKWID_SET_MESSAGE	;80:ディスク・セットメッセージ
	DW	DSKWID_SRT_PRINT	;81:ディスク・メッセージ表示
	DW	DSKWID_FNAME_PRINT	;82:ディスク・ファイル名表示
	DW	DSKWID_PATH_NM_SET	;83:ディスク・パス名セット
	DW	DSKWID_USERWAIT		;84:ディスク・ユーザ待ち
	DW	DSKWID_USERSTANBY	;85:ディスク・ユーザスタンバイ
	DW	DSKWID_LED		;86:ディスク・アクセスランプ
	DW	DKCDRVRESET		;87:ディスクドライブ検索のリセット
	DW	DSKWID_USERST_INI	;88:ディスク・ユーザスタンバイ初期化
TBL_CALL_CODE01_GATE_E	LABEL	WORD

ID_VRAM_TBL	LABEL	WORD		; vram ID table.
	DW	ARAVRM			; ＶＲＡＭプレーン
	DW	ARA001			; 仮想ＶＲＡＭプレーン(width40)
	DW	ARA002			; 仮想ＶＲＡＭプレーン(width42)
	DW	ARA003			; 仮想ＶＲＡＭプレーン(width60)
	DW	ARA004			; 仮想ＶＲＡＭプレーン(width56)
	DW	ARA005			; 仮想ＶＲＡＭ(単プレーンwidth60)
	DW	ARA006			; 仮想ＶＲＡＭ(単プレーンwidth40)
	DW	ARA007			; 仮想ＶＲＡＭ(単プレーンwidth40)
	DW	ARA008			; 仮想ＶＲＡＭ(単プレーンwidth40)
	DW	ARA009			; 仮想ＶＲＡＭ(単プレーンwidth47)

ID_PLEAN_TBL	LABEL	WORD		; plean ID table.
	DW	SSGR0			; visual data segment plean.
	DW	SSGRV0			; visual data segment plean.
	DW	SSDES0			; visual data segment plean.
	DW	SSSOU0			; visual data segment plean.
	DW	SSEFC0			; visual data segment plean.
	DW	SSCUR0			; visual data segment plean.
	DW	SEGVT0			; visual data segment plean.

ICONFILECHKSAM	DW	1234		; ICON file check sam.
FILE_NAME_ICON	DB	"ICON.PT1",0,0	; ICON file name.

FLNM		DB	12 DUP (0),0,0			; file name.

CHILD_STRING	DB	CHILD_STRING_LEN DUP (0),0,0	; child string.

DATA	ENDS
	END
;
;	end of "CHILD.ASM"
;
