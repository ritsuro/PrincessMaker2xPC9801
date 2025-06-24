; "KS2MAIN.ASM" PC-9801UV11 make by R.H 1992/05/06
;
;
;	P R I N C E S S   M A K E R   2.
;
;
;
;DUMMY    ASM      1821 93-06-18    4:45
;KS2MAIN  ASM      9900 93-06-18    5:12
;KS2TBL   ASM     45705 93-06-18    5:15
;ZBGATE.ASM
;
;MACHINE.ASM
;V98DSPST ASM      3471 93-05-18   12:46	386VRの不具合
;
;WIDGRAP  ASM     37879 93-06-18    2:48	ﾊﾟﾗﾒｰﾀ表示０以下カット
;
;	LINKF98
;
;		GETARG.OBJを削除
;
;	6/18 削ったエリア
;
;		"KS2MAIN.ASM"
;		CALLE	c_GETARG　の周辺
;		;*;	LF
;		;*;	PRF	"run PC-9801/EPSON PC"
;		;*;	PRF	" A> AUTOEXEC 9801"
;		;*;	PRF	"run DOS/V"
;		;*;	PRF	" A> AUTOEXEC PCAT"
;
;		"KS2TBL.ASM"
;		587: LBLADRS_DIM	EQU	200 ;512	; jump address table dimension.
;
;		"DUMMY.ASM"
;		PRF	"**** DUMMY ****"
;
;		"ZBGATE.ASM"
;		GETARGの呼び出しカット
;		MACHINE_SETカット
;
;
;		"MACHINE.ASM"
;		PUBLIC	MACHINE_SET	; machine set. をカット
;
;	PC98      [STOP] key : dos exit	"V98KEYBO.ASM"
;	PCAT      [F1] key   : dos exit	"VPCKEYBO.ASM"
;	PCAT      [F2] key   : debug windows clr "VPCMOUSE.ASM" -> "BBDEBUG.ASM"
;	PCAT&PC98 [F3] key   : timer clear	
;	PC98      [F4] key   : text area clear."V98KEYBO.ASM"
;	PC98      [O][M][Y]  : stop key on & nandemoya.
;
;	MUSYAE.COM のサイズが大きくなったら
;	"KS2TBL.ASM"の PROCBUF を大きくすること。
;
;	;	process buffer.
;	PROCBUF	SEGMENT	PUBLIC	'PROCBUF'
;	PUBLIC	PROCBUF_TOP
;	PUBLIC	PROCBUF_END
;	PROCBUF_TOP	LABEL	BYTE
;		DB	19200 DUP (?)	; <- "MUSYAE.COM" size + 100H
;	PROCBUF_END	LABEL	BYTE
;	PROCBUF	ENDS
;
;
;	武者修行を高速移動したいときは"V98TIMER.ASM","VPCTIMER.ASM"の
;	ルーチンV98TMVCLR(V-SYNC timer clear.)の
;		MOV	VSYNC5,0		; V-SYNC counter5.
;	をコメントにしてＦ．３を押しながら移動するとよい。
;
;
; main program.

TITLEX	MACRO
	DB	"P R I N C E S S   M A K E R  2.  1993(C)GAINAX"
	ENDM

FLAG_KEY_ENABLE		EQU	1	; キーマウス

FLAG_STOP_KEY_ENABLE	EQU	0;1	; ストップキー

WTIME_MESSAGE	EQU	60*2	; message wait time


CODE	SEGMENT	PUBLIC	'CODE'
CODE	ENDS
CODE01	SEGMENT	PUBLIC	'CODE01'
CODE01	ENDS
WINDOW	SEGMENT	PUBLIC	'WINDOW'
WINDOW	ENDS
DATA	SEGMENT	PUBLIC	'DATA'
DB "DATATOP",0
DATA	ENDS
EMMCOD	SEGMENT	PUBLIC	'EMMCOD'
EMMCOD	ENDS
EMMDAT	SEGMENT	PUBLIC	'EMMDAT'
EMMDAT	ENDS
PALET	SEGMENT	PUBLIC	'PALET'
PALET	ENDS
DATBIN	SEGMENT	PUBLIC	'DATBIN'
DATBIN	ENDS
LBLBUFF	SEGMENT	PUBLIC	'LBLBUFF'
LBLBUFF	ENDS
TCHRSEG	SEGMENT	PUBLIC	'TCHRSEG'
TCHRSEG	ENDS
TCHRADR	SEGMENT	PUBLIC	'TCHRADR'
TCHRADR	ENDS
@code	segment	public	"@code"
@code	ends
STACK	SEGMENT	STACK
	DW	1200 DUP (?)
PUBLIC	TOP_OF_STACK
TOP_OF_STACK	LABEL	WORD
STACK	ENDS
PARTBUF	SEGMENT	PUBLIC	'PARTBUF'
PARTBUF	ENDS
PLESS	SEGMENT	PUBLIC	'PLESS'
PLESS	ENDS
VVVRAM	SEGMENT	PUBLIC	'VVVRAM'
VVVRAM	ENDS
;*;TEXTBUF	SEGMENT	PUBLIC	'TEXTBUF'
;*;TEXTBUF	ENDS
DATBIN2	SEGMENT	PUBLIC	'DATBIN2'
DATBIN2	ENDS
PROCBUF	SEGMENT	PUBLIC	'PROCBUF'
PROCBUF	ENDS
PROCWRK	SEGMENT	PUBLIC	'PROCWRK'
PROCWRK	ENDS
ENDSEG	SEGMENT	PUBLIC	'ENDSEG'
ENDSEG	ENDS

INCLUDE	TSTSETC.INC
INCLUDE	MACHINEX.INC
INCLUDE	MESSAGE.INC

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:DATA,SS:STACK,ES:DATA

;*;EXTRN	GETARG:NEAR		; get argument.

EXTRN	KS2LOOP:NEAR		; main loop.

PUBLIC	XSTOPX		; ＳＴＯＰキー終了処理
			; デバック時にＳＴＯＰキーを押すとここに飛び込んでくる


; *********************************************************
;	start.
; *********************************************************

START:
	PUSH	DS			;
	MOVX	DS,<SEG DATA>		;

	MOV	SAVE_SS,SS		; stack segment.
	MOV	SAVE_SP,SP		; stack pointer.

	CLI				; for i8088
	MOVX	SS,<SEG STACK>		; stack segment.
	MOV	SP,OFFSET TOP_OF_STACK	; stack pointer.
	STI				; for i8088

	CALL	MAIN			; main proc.

	CLI				; for i8088
	MOV	SS,SAVE_SS		; stack segment.
	MOV	SP,SAVE_SP		; stack pointer.
	STI				; for i8088

	POP	DS
FINALE:
	MOV	AH,4CH
	MOV	AL,0
	INT	21H

	JMP	$

; *********************************************************
;	main proc.
; *********************************************************

MAIN	PROC	NEAR
	MOV	MAIN_STACK_LEVEL_SS,SS	; ＳＴＯＰキー終了時に戻すスタック
	MOV	MAIN_STACK_LEVEL_SP,SP	; （XSTOPXを見よ）

;*;	CALLE	c_GETARG		; get argument.
;*;	MOV	TOKENCOUNT,CX		; token count.
;*;	MOVX	TOKEN01,DS:[SI]		; token no.1
;*;	MOVX	TOKEN02,DS:[SI][2]	; token no.2
;*;
;*;	CMP	TOKENCOUNT,0		; token count.
;*;	JE	MAIN_9801		;
;*;	;JE	MAIN_HELP		;
;*;
;*;	MOVX	ES,DS			;
;*;	MOV	DI,TOKEN01		;
;*;	CALLE	c_STRCAPS		; 文字列大文字化
;*;
;*;	MOV	DI,TOKEN01		;
;*;	MOV	AX,DS:[DI]		;
;*;	MOV	BX,DS:[DI][2]		;
;*;	XCHG	AH,AL			;
;*;	XCHG	BH,BL			;
;*;
;*;	CMP	AX,"98"			;
;*;	JNE	MAIN_11			;
;*;	CMP	BX,"01"			;
;*;	JE	MAIN_9801		;
;*;MAIN_11:
;*;	CMP	AX,"PC"			;
;*;	JNE	MAIN_12			;
;*;	CMP	BX,"AT"			;
;*;	JE	MAIN_PCAT		;
;*;MAIN_12:
;*;	JMP	MAIN_HELP		;
;*;
;*;MAIN_PCAT:
;*;	MOV	DX,1			; 1=PC/AT
;*;	CALLE	c_MACHINE_SET		; machine set.
;*;	JMP	MAIN_15			;
;*;MAIN_9801:
;*;	MOV	DX,2			; 2=PC9801
;*;	CALLE	c_MACHINE_SET		; machine set.
;*;MAIN_15:

	CALLE	c_CLS			;
	CALLE	c_CSLOFF		; cursole off.

	CALLE	c_TMVSRT		; V-SYNC timer start.
IF FLAG_KEY_ENABLE
	CALLE	c_KYBSRT		; keybord start.
ENDIF
	CALLE	c_MUSINI		; マウスの初期化
	CALLE	c_GRPSRT		; graphics start.
	CALLE	c_GRPCLS		; graphics clear screen.

	CALLE	c_NORMIN		; ノーマルカラー

	CALLE	ZPTBL_INIT		; ZP table init.
	CMP	AX,1			; 1=no memory.
	JE	MAIN_XSTOPX_NO_MEMORY	;
	CMP	AX,2			; 2=EMS error.
	JE	MAIN_XSTOPX_EMS_ERROR	;

	CALLE	c_CLS			;

IF FLAG_STOP_KEY_ENABLE			; ストップキー
	CALLE	c_KYBONS		; keybord STOP key on.
ENDIF
	CALLE	c_DKCINI		; ディスクチェンジ初期処理
	CMP	AX,0			; 0=normal,1=error.
	JNE	MAIN_XSTOPX_DKCINI_ERROR

	CALLE	c_PICTUER_INIT		; picture init.

;*;	CALL	FAR PTR CODE01_STARTUP	; code01 start up.(far)

	CALL	KS2LOOP			; main loop.

	JMP	MAIN_XSTOPX_EXIT	;

MAIN_XSTOPX_NO_MEMORY:			;
	CALL	HELP_NOMEMORY		; help no memory.
	JMP	MAIN_XSTOPX_EXIT	;

MAIN_XSTOPX_EMS_ERROR:			;
	CALL	HELP_EMS_ERROR		; EMS error.
	JMP	MAIN_XSTOPX_EXIT	;

MAIN_XSTOPX_DKCINI_ERROR:		;
	CALL	HELP_DKCINI_ERROR	; disk chenger error.
	JMP	MAIN_XSTOPX_EXIT	;

MAIN_XSTOPX_EXIT:
	CALLE	c_KYBOFS		; keybord STOP key off.

	CALL	FAR PTR CODE01_FINALE	; code01 finale.(far)

	CALLE	ZPTBL_FINALE		; ZP table finale.

	CALLE	c_GRPEND		; graphics end.
	CALLE	c_MUSSTP		; マウスの終了
IF FLAG_KEY_ENABLE
	CALLE	c_KYBEND		; keybord end.
ENDIF
	CALLE	c_TMVEND		; V-SYNC timer end.
	CALLE	c_CSLON			; cursole on.
	RET
MAIN_HELP:
	CALL	KS2HELP			; help.
	RET
MAIN	ENDP


; *********************************************************
;	ＳＴＯＰキー終了処理
; *********************************************************

XSTOPX	PROC	FAR
	CLI
	MOVX	DS,<SEG DATA>
	MOV	SS,MAIN_STACK_LEVEL_SS	; ＳＴＯＰキー終了時に戻すスタック
	MOV	SP,MAIN_STACK_LEVEL_SP	;
	CALLE	c_KYBOFS		; keybord STOP key off.
	STI
	JMP	MAIN_XSTOPX_EXIT
XSTOPX	ENDP


;*;; *********************************************************
;*;;	サブタイトル
;*;; *********************************************************
;*;
;*;DPSUBTITLE	PROC	NEAR
;*;	CMP	MFLAG_MY,MFLAG_PCAT		; PC/AT
;*;	JE	SUBTITLE_PCAT			;
;*;	RET
;*;SUBTITLE_PCAT:
;*;	LC	0,25
;*;	PR	"PC9801."
;*;	RET
;*;DPSUBTITLE	ENDP


; *********************************************************
;	help.
; *********************************************************

KS2HELP	PROC	NEAR
	MOV	DBGFLAG_CONSOLE,1	; 1=console output.
	LF				;
	MOV	SI,OFFSET SYSTEM_NAME	; system name.
	CALLE	c_PRINT			;
	LF				;
	LF				;
;;	MESSAGE	11	;"ＰＭ２とタイプしてリターンキーを押してください。"
;;	CALL	c_PRINT
;*;	LF
;*;	PRF	"run PC-9801/EPSON PC"
;*;	PRF	" A> AUTOEXEC 9801"
;*;	PRF	"run DOS/V"
;*;	PRF	" A> AUTOEXEC PCAT"
	RET
KS2HELP	ENDP


; *********************************************************
;	help no memory.
; *********************************************************

HELP_NOMEMORY	PROC	NEAR
	MOV	DX,12		;"メモリーが足りません、ドライバ等を..."
	CALL	SHOW_MESS	; show message.
	RET
HELP_NOMEMORY	ENDP


; *********************************************************
;	EMS error.
; *********************************************************

HELP_EMS_ERROR	PROC	NEAR
	MOV	DX,14		;"ＥＭＳが異常です"
	CALL	SHOW_MESS	; show message.
	RET
HELP_EMS_ERROR	ENDP


; *********************************************************
;	disk chenger error.
; *********************************************************

HELP_DKCINI_ERROR	PROC	NEAR
	MOV	DX,15		;"ファイル'LIBINDEX.DIR'が..."
	CALL	SHOW_MESS	; show message.
	RET
HELP_DKCINI_ERROR	ENDP


; *********************************************************
;	show message.
;	-I- DX : message number.
; *********************************************************

SHOW_MESS	PROC	NEAR
	MOV	DBGFLAG_CONSOLE,1	; 1=console output.
	LF				;
	MESSAGE	DX
	CALL	c_PRINT
	LF
	MOV	AX,WTIME_MESSAGE	; message wait time
	CALLE	c_TMVWAT		; V-SYNC timer wait.
	RET
SHOW_MESS	ENDP

CODE	ENDS

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA,SS:STACK,ES:DATA

;*;; *********************************************************
;*;;	code01 start up.(far)
;*;; *********************************************************
;*;
;*;CODE01_STARTUP	PROC	FAR
;*;	RET
;*;CODE01_STARTUP	ENDP


; *********************************************************
;	code01 finale.(far)
; *********************************************************

CODE01_FINALE	PROC	FAR
	CALLE	M_EXIT			; 音楽システム終了処理
	CALLE	M_SETUP_OFF		; 音楽システム起動ドライバの終了
	RET
CODE01_FINALE	ENDP

CODE01	ENDS

; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	KYTBLS:BYTE

EXTRN	DBGFLAG_CONSOLE:WORD			; debug flag console.

SAVE_SS			DW	0	; stack segment.
SAVE_SP			DW	0	; stack pointer.

MAIN_STACK_LEVEL_SS	DW	0	; ＳＴＯＰキー終了時に戻すスタック
MAIN_STACK_LEVEL_SP	DW	0	;

TOKENCOUNT		DW	0	; token count.
TOKEN01			DW	0	; token no.1
TOKEN02			DW	0	; token no.2

SYSTEM_NAME	LABEL	BYTE		; system name.
		TITLEX

DATA	ENDS

	END	START
;
;	end of "KS2MAIN.ASM"
;
