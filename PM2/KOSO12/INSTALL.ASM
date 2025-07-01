; "INSTALL.ASM" PS55Z/S14 make by R.H/japan 1991/09/12
;
;	princess maker install.
;
; test program.

INCLUDE	TSTSET.INC

STRING_LEN 	EQU	255	; string length.
CLEAR_LEN	EQU	60	; clear length.
SRT_PATH_LEN	EQU	60	; string path length.
SRT_DRIVE_LEN	EQU	2	; string drive length.

CALL_NM	MACRO	NUM,LBL
	LOCAL	L1
	CMP	DX,NUM
	JNE	L1
	PUSH	DX
	CALL	LBL
	POP	DX
L1:
	ENDM

LCT	MACRO	XXYY
	XOR	AX,AX
	XOR	BX,BX
	MOV	AL,XXYY
	MOV	BL,XXYY[1]
	CALL	VW_LOCATE		; view/locate.
	ENDM

COLOR	MACRO	VAL
	XOR	AX,AX
	MOV	AL,VAL
	CALL	VW_TXCOLR		; view/text color.
	ENDM

SPACE_CLR	MACRO	LENG
	MOV	CX,LENG+1
	CALL	SPCCLR			; space clear.
	ENDM

TOPSPCCLR	MACRO
	LOCAL	L1
	DEC	SI
L1:
	INC	SI
	MOV	AL,DS:[SI]
	CMP	AL,' '
	JE	L1
	ENDM


CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

	ORG	80H

DTA	LABEL	BYTE

	ORG	100H

PUBLIC	MSG_FILE_NOW_COPY		; message now copy file.
PUBLIC	MSG_FILE_COPY_MRK_SRT		; message file copy mark start.
PUBLIC	MSG_FILE_COPY_MARK		; message file copy mark.

EXTRN	INT24HX_SRT:NEAR		; int24h handle startup.
EXTRN	INT24HX_END:NEAR		; int24h handle end.

EXTRN	CMMD_SRT:NEAR			; DOS command handle startup.
EXTRN	CMMD_END:NEAR			; DOS command handle end.
EXTRN	CMMD_CD:NEAR			; DOS command chenge directory.
EXTRN	CMMD_MD:NEAR			; DOS command making directory.
EXTRN	CMMD_COPYX:NEAR			; DOS command COPY (file i/o).
EXTRN	CMMD_DFREE:NEAR			; DOS command disk free.

EXTRN	FDCKDNO:NEAR			; set FD drive number.
EXTRN	FDCKSET:NEAR			; set FD check.

EXTRN	ERRBOX:NEAR			; fatal error box.

EXTRN	DSPMESS:NEAR			; disply message.
EXTRN	DSPPRNT:NEAR			; console message.
EXTRN	DSPPRTS:NEAR			; console message string.
EXTRN	DSPLANGUAGE:NEAR		; disply language mode.

EXTRN	VW_FREAM:NEAR			; view/fream.
EXTRN	VW_INPUT:NEAR			; view/input.
EXTRN	VW_PRINT:NEAR			; view/print.
EXTRN	VW_CHPUT:NEAR			; view/put character.
EXTRN	VW_LOCATE:NEAR			; view/locate.
EXTRN	VW_TXCOLR:NEAR			; view/text color.
EXTRN	VW_CLS:NEAR			; view/cls.
EXTRN	VW_USERKEY:NEAR			; view/user key.
EXTRN	VW_INPUT_LENG:NEAR		; view/input length set.

EXTRN	STRLENSPZ:NEAR			; 文字列長さスペースまで
EXTRN	STRCAPS:NEAR			; 文字列大文字化
EXTRN	STRXCHG:NEAR			; 文字列キャラクタ書き換え


; ****************************************************
;	PROGRAM CODE
; ****************************************************

START:
	CALL	INT24HX_SRT		; int24h handle startup.

	CALL	CMMD_SRT		; DOS command handle startup.

	CALL	MAIN			; main proc.

	CALL	CMMD_END		; DOS command handle end.

	CALL	INT24HX_END		; int24h handle end.

FINALE:
	MOV	AH,4CH			; return to DOS.
	MOV	AL,0			;
	INT	21H			; end.
					;
MUGEN:					;
	JMP	MUGEN			;


; ****************************************************
;	main proc.
; ****************************************************

MAIN	PROC	NEAR
	CALL	INSTALL			; install.
	RET
MAIN	ENDP


; ****************************************************
;	making directory.
; ****************************************************

CM_MAKE_DIR	PROC	NEAR
	CALL	PATH_LINE_INP		; path line input input.
	CALL	CMMD_MD			; DOS command making directory.
	RET
CM_MAKE_DIR	ENDP


; ****************************************************
;	path line input input.
;	-O- PATHNAME : path name.
;	    SI       : path name.
; ****************************************************

PATH_LINE_INP	PROC	NEAR
	INP	"path:"
	SETS	PATHNAME,STRING_LEN		; path name.
	MOV	SI,OFFSET PATHNAME		; path name.
	RET
PATH_LINE_INP	ENDP


; ****************************************************
;	install.
; ****************************************************

INSTALL	PROC	NEAR
	CALL	CSLOFF				; cursole on.
	CALL	VW_CLS				; view/cls.

	; (1) wellcome this system.

	MOV	AX,1				; AX:0=english,1=japan.
	CALL	DSPLANGUAGE			; disply language mode.
INSTALL_WELLCOME:

	CALL	VW_CLS				; view/cls.
	CALL	VW_FREAM			; view/fream.
	CALL	FUNCTION_BAR			; function bar.

	CALL	WELLCOME			; wellcome install program.
	CMP	AX,2				; 1=RUN,2=BREAK
	JMPEQ	INSTALL_BREAK			;

	MOV	SI,OFFSET DEFPATH_FD_DRV	; default FD drive.
	TOPSPCCLR				;
	SETS	PATH_FD_DRV,STRING_LEN		; FD drive.

	MOV	SI,OFFSET DEFPATH_HD_DSK	; default path.
	TOPSPCCLR				;
	SETS	PATH_HD_DSK,STRING_LEN		; HARD disk drive.

	; (2) path name check & input.

INSTALL_OKK:					;
	CALL	VW_CLS				; view/cls.
	CALL	VW_FREAM			; view/fream.

	CALL	PATH_DISPLY			; path disply.
	CMP	AX,1				; 1=RUN,2=BREAK,3=BACK
	JE	INSTALL_INS			;
	CMP	AX,2				;
	JE	INSTALL_BREAK			;

INSTALL_LOOP:
	CALL	PATH_INPUT			; path input.
	CMP	AX,4				; 4=BACK2
	JE	INSTALL_OKK			;
	CMP	AX,3				; 1=RUN,2=BREAK,3=BACK
	JE	INSTALL_LOOP			;
	CMP	AX,2				;
	JE	INSTALL_BREAK			;

	; (3) md c:\pm ; cd c:\pm

INSTALL_INS:
	MOV	SI,OFFSET PATH_FD_DRV		; FD drive.
	TOPSPCCLR				;
	SETS	PATH_FD_DRV,STRING_LEN		; FD drive.

	MOV	SI,OFFSET PATH_HD_DSK		; HARD disk drive.
	TOPSPCCLR				;
	SETS	PATH_HD_DSK,STRING_LEN		; HARD disk drive.

	CALL	TRAGET_MD			; traget make directory.
	CALL	TRAGET_CD			; traget chenge directory.
	CMP	AX,0				; 0=normal,1=error.
	JE	INSTALL_COPY			;

	JMP	INSTALL_NODIRECTRY		;

	; (4) copy a:*.* c:\pm\*.*

INSTALL_COPY:
	CALL	VW_CLS				; view/cls.
	CALL	VW_FREAM			; view/fream.
	CALL	DISPLY_TITLE			; disply title.
	CALL	FUNCTION_BAR			; function bar.

	LCT	DSP_XY[2*16]			; 16:disk set message.
	COLOR	DSP_CLR[16]			; disply color.
	MOV	AX,18				; "ディスクＡ→Ｂ→
	CALL	DSPMESS				; disply message.

	MOV	FD_NUMBER,1			; FD number.
INSTALL_LOOP2:
	CALL	FD_ONE_COPY			; FD copy.
	CMP	AX,2				; 0=normal,2=break.
	JE	INSTALL_BREAK			;
	CMP	AX,0				; 0=normal,2=break.
	JNE	INSTALL_ERROR			;
	INC	FD_NUMBER			; FD number.
	CMP	FD_NUMBER,12			;
	JLE	INSTALL_LOOP2			;

INSTALL_EXIT:
	CALL	VW_CLS				; view/cls.
	CALL	CLS

	CALL	CSLON				; cursole on.
	LF
	MOV	AX,30				;"インストールが完了しました
	CALL	DSPPRNT				; console message.
	LF
	RET

INSTALL_NODIRECTRY:
	CALL	VW_CLS				; view/cls.
	CALL	CLS
	MOV	AX,20				; "ディレクトリィ 
	CALL	DSPPRNT				; console message.
	MOV	SI,OFFSET PATH_HD_DSK		; HARD disk drive.
	CALL	DSPPRTS				; console message string.
	MOV	AX,21				; " が作成できません。
	CALL	DSPPRNT				; console message.
	JMP	INSTALL_BREAK2			;

INSTALL_BREAK:
	CALL	VW_CLS				; view/cls.
	CALL	CLS				;
INSTALL_BREAK2:
	CALL	CSLON				; cursole on.
	LF
	MOV	AX,31				;"インストールを中断します。
	CALL	DSPPRNT				; console message.
	LF
	RET
INSTALL_ERROR:					;
	CALL	CSLON				; cursole on.
	LF
	MOV	AX,32				;"ディスクエラーのため、
	CALL	DSPPRNT				; console message.
	LF
	RET
INSTALL	ENDP


; ****************************************************
;	wellcome install program.
;	-O- AX : 1=RUN,2=BREAK
; ****************************************************

WELLCOME	PROC	NEAR
	CALL	DISPLY_TITLE			; disply title.

	LCT	DSP_XY[2*10]		; disply locate.
	COLOR	DSP_CLR[10]		; disply color.
	MOV	AX,6			; "INSTALL を開始します
	CALL	DSPMESS			; disply message.

	LCT	DSP_XY[2*8]		; disply locate.
	COLOR	DSP_CLR[8]		; disply color.
	MOV	AX,4			; "INSTALL プログラムはプリ
	CALL	DSPMESS			; disply message.

	LCT	DSP_XY[2*13]		; 13:start menu 2.
	COLOR	DSP_CLR[13]		; disply color.
	MOV	AX,25			; "フロッピーディスクの
	CALL	DSPMESS			; disply message.

	CALL	BREAK_WAIT		; break wait.

	RET
WELLCOME	ENDP


; ****************************************************
;	FD copy.
;	-I- FD_NUMBER : FD number.
;	-O- AX        : 0=normal,1=error,2=break.
; ****************************************************

FD_ONE_COPY	PROC	NEAR
	CALL	MSG_FILE_MESS_CLR		; message file message clear.

	CALL	FD_SETING			; FD check.
	CMP	AX,2				; 2=BREAK
	JE	FD_ONE_COPY_BREAK		;

	CALL	MSG_FILE_MESS_CLR		; message file message clear.

	MOV	SI,OFFSET PATH_FD_DRV		; FD drive.
	MOV	DI,OFFSET PATH_HD_DSK		; HARD disk drive.
	CALL	CMMD_COPYX			; DOS command COPY (file i/o).
	CMP	AX,0				; 1=read error,2=write error.
	JNE	FD_ONE_COPY_ERROR		;

FD_ONE_COPY_NORMAL:
	MOV	SI,OFFSET PATH_HD_DSK		; HARD disk drive.
	CALL	CMMD_DFREE			; DOS command disk free.

	CMP	AX,0FFFFH			; セクタ数／１クラスタ,
	JE	FD_ONE_COPY_ERROR		; ドライブが無効のときはFFFFh

	MUL	CX				; バイト数／１セクタ

	MOV	CX,AX				; バイト数／クラスタ
	MOV	AX,1142				; セーブデータサイズ ÷ ﾊﾞｲﾄ数
	XOR	DX,DX				; DX=0
	DIV	CX				;
	CMP	DX,0				;
	JE	FD_ONE_COPY_88			;
	INC	AX				;
FD_ONE_COPY_88:					; AX=データ１／クラスタ
	SHL	AX,1				;
	MOV	DX,AX				;
	ADD	DX,AX				;
	ADD	DX,AX				; * 6

;*;	PRV	"free cluster:",BX
;*;	PRV	"save cluster:",DX

	CMP	BX,DX				; 空きクラスタ数
	JNB	FD_ONE_COPY_OK			;


	MOV	AX,4				; 4=empty data area.
	CALL	ERRBOX				; fatal error box.

	JMP	FD_ONE_COPY_BREAK		;

FD_ONE_COPY_OK:
	MOV	AX,0				; 0=normal.
	RET
FD_ONE_COPY_ERROR:
	MOV	AX,1				; 1=error.
	RET
FD_ONE_COPY_BREAK:
	MOV	AX,2				; 2=break.
	RET
FD_ONE_COPY	ENDP


; ****************************************************
;	path input.
;	-O- AX : 1=RUN,2=BREAK,3=BACK,4=BACK2
; ****************************************************

PATH_INPUT	PROC	NEAR
	CALL	VW_CLS				; view/cls.
	CALL	VW_FREAM			; view/fream.
	CALL	FUNCTION_3BAR			; function bar 3.
;*;	CALL	FUNCTION_BAR			; function bar.

	CALL	DISPLY_TITLE			; disply title.

	LCT	DSP_XY[2*7]			; 7:yoidesuka.
	COLOR	DSP_CLR[7]			; disply color.
	MOV	AX,23				; "戻るときは、ESC を
	CALL	DSPMESS				; disply message.

PATH_INPUT_2:
	CALL	INPUT_USER_PATH			; input user path.
	CMP	EXTFLAG,1			; 1=RUN,2=BREAK,3=BACK
	JNE	PATH_INPUT_SKIP			;

	MOV	STRADRS,OFFSET PATH_HD_DSK	; HARD disk drive.
	CALL	DISPLY_USER_PATH		; disply user path.

	CALL	INPUT_USER_DRV			; input user drive.
	CMP	EXTFLAG,2			; 2=BREAK
	JE	PATH_INPUT_SKIP			;

	MOV	STRADRS,OFFSET PATH_FD_DRV	; FD drive.
	CALL	DISPLY_USER_DRV			; disply user drive.

	CMP	EXTFLAG,3			; 3=BACK
	JE	PATH_INPUT_2			;

	LCT	DSP_XY[2*7]			; 7:yoidesuka.
	COLOR	DSP_CLR[7]			; disply color.
	SPACE_CLR	<80*3>

	CALL	FUNCTION_2BAR			; function bar 2.
	CALL	YOIDESUKA			; yoidesuka?
	PUSH	AX
	CALL	FUNCTION_BAR			; function bar.
	POP	AX
	RET
PATH_INPUT_SKIP:
	MOV	AX,EXTFLAG			; 1=RUN,2=BREAK,3=BACK

	CMP	AX,3				; 3=BACK
	JNE	PATH_INPUT_91			;
	MOV	AX,4				; 4=BACK2
PATH_INPUT_91:
	RET
PATH_INPUT	ENDP


; ****************************************************
;	path disply.
;	-O- AX : 1=RUN,2=BREAK,3=BACK
; ****************************************************

PATH_DISPLY	PROC	NEAR
	CALL	FUNCTION_2BAR			; function bar 2.
	CALL	DISPLY_TITLE			; disply title.

	MOV	STRADRS,OFFSET PATH_HD_DSK	; HARD disk drive.
	CALL	DISPLY_USER_PATH		; disply user path.

	MOV	STRADRS,OFFSET PATH_FD_DRV	; FD drive.
	CALL	DISPLY_USER_DRV			; disply user drive.

	CALL	YOIDESUKA			; yoidesuka?
	PUSH	AX
	CALL	FUNCTION_BAR			; function bar.
	POP	AX
	RET
PATH_DISPLY	ENDP


; ****************************************************
;	function bar.
; ****************************************************

FUNCTION_BAR	PROC	NEAR
	LCT	DSP_XY[2*9]		; disply locate.
	SPACE_CLR	78		; string path length.
	LCT	DSP_XY[2*9]		; disply locate.
	COLOR	DSP_CLR[9]		; disply color.
	MOV	AX,5			; "  ENTER= 続行  F3= 終了
	CALL	DSPMESS			; disply message.
	RET
FUNCTION_BAR	ENDP


; ****************************************************
;	function bar 2.
; ****************************************************

FUNCTION_2BAR	PROC	NEAR
	LCT	DSP_XY[2*9]		; disply locate.
	SPACE_CLR	78		; string path length.
	LCT	DSP_XY[2*9]		; disply locate.
	COLOR	DSP_CLR[9]		; disply color.
	MOV	AX,26			; "リターンキー=続行f･3= 終了f･2= 変更
	CALL	DSPMESS			; disply message.
	RET
FUNCTION_2BAR	ENDP


; ****************************************************
;	function bar 3.
; ****************************************************

FUNCTION_3BAR	PROC	NEAR
	LCT	DSP_XY[2*9]		; disply locate.
	SPACE_CLR	78		; string path length.
	LCT	DSP_XY[2*9]		; disply locate.
	COLOR	DSP_CLR[9]		; disply color.
	MOV	AX,29			; " リターンキー= 続行  ESC= もどる
	CALL	DSPMESS			; disply message.
	RET
FUNCTION_3BAR	ENDP


; ****************************************************
;	path name input.
;	-O- PATHNAME : path name.
;	    SI       : path name.
;	    AX       : 1=RUN,2=BREAK,3=BACK
; ****************************************************

PATHNAME_INP	PROC	NEAR
	MOV	AX,SRT_PATH_LEN			; string path length.
	CALL	VW_INPUT_LENG			; view/input length set.

	CALL	CSLON				; cursole on.
	CALL	VW_INPUT			; view/input.
	PUSH	AX				;
	SETS	PATHNAME,STRING_LEN		; path name.
	CALL	CSLOFF				; cursole on.
	POP	AX				;
	CMP	AX,3				; 0=normal,3=F3,11=ESC
	JE	PATHNAME_INP_BREAK		;
	CMP	AX,11				;
	JE	PATHNAME_INP_BACK		;

	CALL	PATH_NAME_CHECK			; path name check.
	MOV	SI,OFFSET PATHNAME		; path name.
PATHNAME_INP_EXIT:				;
	MOV	AX,1				; 1=RUN
	RET
PATHNAME_INP_BREAK:				;
	MOV	AX,2				; 2=BREAK
	RET
PATHNAME_INP_BACK:				;
	MOV	AX,3				; 3=BACK
	RET
PATHNAME_INP	ENDP


; ****************************************************
;	drive name input.
;	-O- PATHNAME : path name.
;	    SI       : path name.
;	    AX       : 1=RUN,2=BREAK,3=BACK
; ****************************************************

DRIVENAME_INP	PROC	NEAR
	MOV	AX,SRT_DRIVE_LEN		; string drive length.
	CALL	VW_INPUT_LENG			; view/input length set.

	CALL	CSLON				; cursole on.
	CALL	VW_INPUT			; view/input.
	PUSH	AX				;
	SETS	PATHNAME,STRING_LEN		; path name.
	MOV	PATHNAME[1],':'			; path name.
	MOV	PATHNAME[2],0			; path name.
	CALL	CSLOFF				; cursole on.
	POP	AX				;
	CMP	AX,3				; 0=normal,3=F3,11=ESC
	JE	DRIVENAME_INP_BREAK		;
	CMP	AX,11				;
	JE	DRIVENAME_INP_BACK		;

	CALL	DRIVE_NAME_CHECK		; drive name check.
	MOV	SI,OFFSET PATHNAME		; path name.
DRIVENAME_INP_EXIT:				;
	MOV	AX,1				; 1=RUN
	RET
DRIVENAME_INP_BREAK:				;
	MOV	AX,2				; 2=BREAK
	RET
DRIVENAME_INP_BACK:				;
	MOV	AX,3				; 3=BACK
	RET
DRIVENAME_INP	ENDP


; ****************************************************
;	path name check.
;	-I/O- PATHNAME : path name.
; ****************************************************

PATH_NAME_CHECK	PROC	NEAR
	MOVX	ES,DS				;
	MOV	DI,OFFSET PATHNAME		; path name.
	CALL	STRCAPS				; 文字列大文字化
	CALL	STRLENSPZ			; 文字列長さスペースまで
	CMP	CX,0				;
	JE	PATH_NAME_CHECK_EXIT		;

	MOVX	ES,DS				;
	MOV	DI,OFFSET PATHNAME		; path name.
	MOV	DH,';'				; 検索キャラクタ
	MOV	DL,':'				; 置換キャラクタ
	CALL	STRXCHG				; 文字列キャラクタ書き換え

	MOV	BX,CX				; 表示単語長さ
	DEC	BX				;
	CMP	BYTE PTR DS:PATHNAME[BX],"\"	;
	JNE	PATH_NAME_CHECK_EXIT		;
	CMP	CX,3				; =<3   "C:\"
	JLE	PATH_NAME_CHECK_EXIT		;

	MOV	BYTE PTR DS:PATHNAME[BX],0	;
PATH_NAME_CHECK_EXIT:
	RET
PATH_NAME_CHECK	ENDP


; ****************************************************
;	path name check.
;	-I/O- PATHNAME : path name.
;	-O-   AX       : 1=ok,2=syntax error.
; ****************************************************

DRIVE_NAME_CHECK	PROC	NEAR
	MOVX	ES,DS				;
	MOV	DI,OFFSET PATHNAME		; path name.
	CALL	STRCAPS				; 文字列大文字化

	MOV	AL,BYTE PTR ES:[DI]		; drive name.
	CMP	AL,'A'				; drive name.
	JB	DRIVE_NAME_CHECK_ERROR		;
	CMP	AL,'Z'				; drive name.
	JNBE	DRIVE_NAME_CHECK_ERROR		;

	MOV	AL,BYTE PTR ES:[DI][1]		; drive name.

	CMP	AL,' '				;
	JNBE	DRIVE_NAME_CHECK_5		;
	MOV	BYTE PTR DS:PATHNAME[1],':'	;
DRIVE_NAME_CHECK_5:
	CMP	AL,';'				;
	JNE	DRIVE_NAME_CHECK_6		;
	MOV	BYTE PTR DS:PATHNAME[1],':'	;
DRIVE_NAME_CHECK_6:

	CMP	AL,':'				;
	JNE	DRIVE_NAME_CHECK_ERROR		;

	MOV	BYTE PTR DS:PATHNAME[2],0	;
DRIVE_NAME_CHECK_EXIT:
	MOV	AX,1				; 1=ok.
	RET
DRIVE_NAME_CHECK_ERROR:
	MOV	AX,2				; 2=syntax error.
	RET
DRIVE_NAME_CHECK	ENDP


; ****************************************************
;	FD check.
;	-I- FD_NUMBER   : FD number.
;	    PATH_FD_DRV : FD drive.
;	-O- AX          : 1=OK,2=BREAK
; ****************************************************

FD_SETING	PROC	NEAR
	MOV	AL,PATH_FD_DRV			; FD drive.
	SUB	AL,40H				; 'A'-1
	XOR	AH,AH				; AH=0
	CMP	AX,0				;
	JE	FD_SETING_BREAK			;
	CMP	AX,26				;
	JNBE	FD_SETING_BREAK			;

	CALL	FDCKDNO				; set FD drive number.

	MOV	DX,FD_NUMBER			; FD number.
	CALL	FDCKSET				; set FD check.
	CMP	AX,2				; 1=ok,2=none.
	JE	FD_SETING_6			;

	JMP	FD_SETING_EXIT			;

FD_SETING_5:					;
	CALL	MSG_NOTSET_FD			; message not set disk.
FD_SETING_6:					;
	CALL	MSG_SETSHITE			; message disk set.
	CALL	BREAK_WAIT			; break wait.
	CMP	AX,2				; 1=RUN,2=BREAK
	JE	FD_SETING_BREAK			;

	MOV	DX,FD_NUMBER			; FD number.
	CALL	FDCKSET				; set FD check.
	CMP	AX,2				; 1=ok,2=none.
	JE	FD_SETING_5			;

FD_SETING_EXIT:
	MOV	AX,1				; 1=OK
	RET
FD_SETING_BREAK:
	MOV	AX,2				; 2=BREAK
	RET
FD_SETING	ENDP


; ****************************************************
;	message now disk.
;	-I- FD_NUMBER : FD number.
; ****************************************************

MSG_NOW_DISK	PROC	NEAR
	RET
MSG_NOW_DISK	ENDP


; ****************************************************
;	message disk set.
;	-I- FD_NUMBER : FD number.
; ****************************************************

MSG_SETSHITE	PROC	NEAR
	LCT	DSP_XY[2*17]			; 17:disk set message2.
	COLOR	DSP_CLR[17]			; disply color.
	SPACE_CLR	<70+80>

	LCT	DSP_XY[2*17]			; 17:disk set message2.
	COLOR	DSP_CLR[17]			; disply color.

	MOV	AX,9				; "  ディスク"
	CALL	DSPMESS				; disply message.

	MOV	AX,FD_NUMBER			; FD number.
	CMP	AX,8				;
	JGE	MSG_SETSHITE_H_DISK		;
	ADD	AX,9				; "Ａ"から"Ｇ"
	JMP	MSG_SETSHITE_5			;
MSG_SETSHITE_H_DISK:				;
	ADD	AX,41-8				; "Ｈ"
MSG_SETSHITE_5:					;
	CALL	DSPMESS				; disply message.

	MOV	AX,24				; "をドライブ"
	CALL	DSPMESS				; disply message.

	MOV	SI,OFFSET PATH_FD_DRV		; FD drive.
	CALL	VW_PRINT			; view/print.

	MOV	AX,17				; "にセットして リターンキー
	CALL	DSPMESS				; disply message.
	RET
MSG_SETSHITE	ENDP


; ****************************************************
;	message not set disk.
;	-I- FD_NUMBER : FD number.
; ****************************************************

MSG_NOTSET_FD	PROC	NEAR
	LCT	DSP_XY[2*18]			; 18:disk set message3.
	COLOR	DSP_CLR[18]			; disply color.
	SPACE_CLR	60

	LCT	DSP_XY[2*18]			; 18:disk set message3.
	COLOR	DSP_CLR[18]			; disply color.

	MOV	AX,9				; "ディスク"
	CALL	DSPMESS				; disply message.

	MOV	AX,FD_NUMBER			; FD number.
	CMP	AX,8				;
	JGE	MSG_NOTSET_FD_H_DISK		;
	ADD	AX,9				; "Ａ"から"Ｇ"
	JMP	MSG_NOTSET_FD_5			;
MSG_NOTSET_FD_H_DISK:				;
	ADD	AX,41-8				; "Ｈ"
MSG_NOTSET_FD_5:				;
	CALL	DSPMESS				; disply message.

	MOV	AX,19				; "が、うまくセットされ
	CALL	DSPMESS				; disply message.

	RET
MSG_NOTSET_FD	ENDP


; ****************************************************
;	message file message clear.
; ****************************************************

MSG_FILE_MESS_CLR	PROC	NEAR
	LCT	DSP_XY[2*17]			; 17:disk set message2.
	COLOR	DSP_CLR[17]			; disply color.
	SPACE_CLR	<70+80>
	LCT	DSP_XY[2*18]			; 18:disk set message3.
	COLOR	DSP_CLR[18]			; disply color.
	SPACE_CLR	60
	LCT	DSP_XY[2*19]			; 19:file copy mark.
	COLOR	DSP_CLR[19]			; disply color.
	SPACE_CLR	10
	RET
MSG_FILE_MESS_CLR	ENDP


; ****************************************************
;	message now copy file.
;	-I- SI : copy file.
; ****************************************************

MSG_FILE_NOW_COPY	PROC	NEAR
	PUSH	SI
	LCT	DSP_XY[2*18]			; 18:disk set message3.
	COLOR	DSP_CLR[18]			; disply color.
	SPACE_CLR	60
	LCT	DSP_XY[2*18]			; 18:disk set message3.
	COLOR	DSP_CLR[18]			; disply color.
	POP	SI
	CALL	VW_PRINT			; view/print.
	RET
MSG_FILE_NOW_COPY	ENDP


; ****************************************************
;	message file copy mark start.
; ****************************************************

MSG_FILE_COPY_MRK_SRT	PROC	NEAR
	LCT	DSP_XY[2*19]			; 19:file copy mark.
	COLOR	DSP_CLR[19]			; disply color.
	SPACE_CLR	10

	LCT	DSP_XY[2*19]			; 19:file copy mark.
	COLOR	DSP_CLR[19]			; disply color.
	RET
MSG_FILE_COPY_MRK_SRT	ENDP


; ****************************************************
;	message file copy mark.
;	-I- AX : filecopy%
; ****************************************************

MSG_FILE_COPY_MARK	PROC	NEAR
	PUSH	AX

	LCT	DSP_XY[2*19]			; 19:file copy mark.
	COLOR	DSP_CLR[19]			; disply color.
	SPACE_CLR	10

	LCT	DSP_XY[2*19]			; 19:file copy mark.
	COLOR	DSP_CLR[19]			; disply color.
	
	POP	DX

	CALL	DECSTR
	CALL	STRZTS
	ADD	SI,2
	CALL	VW_PRINT			; view/print.
	MOV	SI,OFFSET COPY_MARK		;"*",0
	CALL	VW_PRINT			; view/print.
	RET
MSG_FILE_COPY_MARK	ENDP


; ****************************************************
;	disply title.
; ****************************************************

DISPLY_TITLE	PROC	NEAR
	LCT	DSP_XY[0]		; disply locate.
	COLOR	DSP_CLR[0]		; disply color.
	MOV	AX,3			; "プリンセスメーカー
	CALL	DSPMESS			; disply message.

	LCT	DSP_XY[2*14]		; disply locate.
	COLOR	DSP_CLR[14]		; disply color.
	MOV	AX,27			; "�｢�｢�｢ GAINAX  1992 �｢�｢
	CALL	DSPMESS			; disply message.

	LCT	DSP_XY[2*15]		; disply locate.
	COLOR	DSP_CLR[15]		; disply color.
	MOV	AX,28			; "�｢�｢�｢ automatic
	CALL	DSPMESS			; disply message.
	RET
DISPLY_TITLE	ENDP


; ****************************************************
;	disply default path.
;	-I- STRADRS : string address.
; ****************************************************

DISPLY_DEF_PATH	PROC	NEAR
	LCT	DSP_XY[2*11]			; disply locate.
	COLOR	DSP_CLR[11]			; disply color.
	SPACE_CLR	SRT_PATH_LEN		; string path length.
	LCT	DSP_XY[2*11]			; disply locate.
	COLOR	DSP_CLR[11]			; disply color.
	MOV	SI,STRADRS			; string address.
	CALL	VW_PRINT			; view/print.
	RET
DISPLY_DEF_PATH	ENDP


; ****************************************************
;	disply user path.
;	-I- STRADRS : string address.
; ****************************************************

DISPLY_USER_PATH	PROC	NEAR
	LCT	DSP_XY[2*5]			;
	COLOR	DSP_CLR[5]			; disply color.
	MOV	AX,8				; "インストール先のパス名
	CALL	DSPMESS				; disply message.

	LCT	DSP_XY[2*1]			; disply locate.
	COLOR	DSP_CLR[1]			; disply color.
	SPACE_CLR	SRT_PATH_LEN		; string path length.
	LCT	DSP_XY[2*1]			; disply locate.
	COLOR	DSP_CLR[1]			; disply color.
	MOV	SI,STRADRS			; string address.
	CALL	VW_PRINT			; view/print.
	RET
DISPLY_USER_PATH	ENDP


; ****************************************************
;	input user path.
;	-O- PATH_HD_DSK : HARD disk drive.
;	    EXTFLAG     : 1=RUN,2=BREAK,3=BACK
; ****************************************************

INPUT_USER_PATH	PROC	NEAR
	MOV	EXTFLAG,1			; 1=RUN

	MOV	STRADRS,OFFSET DEFPATH_HD_DSK	; default path.
	CALL	DISPLY_DEF_PATH			; disply default path.

	LCT	DSP_XY[2*5]			;
	COLOR	DSP_CLR[5]			; disply color.
	MOV	AX,0				; "ハードディスクへの転送先
	CALL	DSPMESS				; disply message.

	LCT	DSP_XY[2*2]			; disply locate.
	COLOR	DSP_CLR[2]			; disply color.
	SPACE_CLR	SRT_PATH_LEN		; string path length.

	LCT	DSP_XY[2*2]			; disply locate.
	COLOR	DSP_CLR[2]			; disply color.
	CALL	PATHNAME_INP			; path name input.
	MOV	EXTFLAG,AX			; 1=RUN,2=BREAK,3=BACK

	LCT	DSP_XY[2*2]			; disply locate.
	COLOR	DSP_CLR[5]			; disply color.
	SPACE_CLR	SRT_PATH_LEN		; string path length.

	LCT	DSP_XY[2*5]			; disply locate.
	COLOR	DSP_CLR[5]			; disply color.
	SPACE_CLR	CLEAR_LEN

	CMP	PATHNAME,0			; path name.
	JE	INPUT_USER_PATH_DEF		;

	MOV	SI,OFFSET PATHNAME		; path name.
	SETS	PATH_HD_DSK,STRING_LEN		; HARD disk drive.
	RET
INPUT_USER_PATH_DEF:
	MOV	SI,OFFSET DEFPATH_HD_DSK	; default path.
	SETS	PATH_HD_DSK,STRING_LEN		; HARD disk drive.
	RET
INPUT_USER_PATH	ENDP


; ****************************************************
;	disply default drive.
;	-I- STRADRS : string address.
; ****************************************************

DISPLY_DEF_DRV	PROC	NEAR
	LCT	DSP_XY[2*12]			; disply locate.
	COLOR	DSP_CLR[12]			; disply color.
	SPACE_CLR	SRT_DRIVE_LEN		; string drive length.
	LCT	DSP_XY[2*12]			; disply locate.
	COLOR	DSP_CLR[12]			; disply color.
	MOV	SI,STRADRS			; string address.
	CALL	VW_PRINT			; view/print.
	RET
DISPLY_DEF_DRV	ENDP


; ****************************************************
;	disply user drive.
;	-I- STRADRS : string address.
; ****************************************************

DISPLY_USER_DRV	PROC	NEAR
	LCT	DSP_XY[2*6]			;
	COLOR	DSP_CLR[6]			; disply color.
	MOV	AX,7				; "フロッピーディスクの
	CALL	DSPMESS				; disply message.

	LCT	DSP_XY[2*3]			; disply locate.
	COLOR	DSP_CLR[3]			; disply color.
	SPACE_CLR	SRT_DRIVE_LEN		; string drive length.
	LCT	DSP_XY[2*3]			; disply locate.
	COLOR	DSP_CLR[3]			; disply color.
	MOV	SI,STRADRS			; string address.
	CALL	VW_PRINT			; view/print.
	RET
DISPLY_USER_DRV	ENDP


; ****************************************************
;	traget make directory.
;	-I- PATH_HD_DSK : HARD disk drive.
;	-O- AX          : 0=normal,1=error.
; ****************************************************

TRAGET_MD	PROC	NEAR
	MOV	SI,OFFSET PATH_HD_DSK		; HARD disk drive.
	CALL	CMMD_MD				; DOS command making directory.

	CMP	AX,0				; 0=normal,1=error.
	JNE	TRAGET_MD_ERROR			;

TRAGET_MD_EXIT:
	MOV	AX,0				; 0=normal.
	RET
TRAGET_MD_ERROR:
	MOV	AX,1				; 1=error.
	RET
TRAGET_MD	ENDP


; ****************************************************
;	traget chenge directory.
;	-I- PATH_HD_DSK : HARD disk drive.
;	-O- AX          : 0=normal,1=error.
; ****************************************************

TRAGET_CD	PROC	NEAR
	MOV	SI,OFFSET PATH_HD_DSK		; HARD disk drive.
	CALL	CMMD_CD				; DOS command chenge directory.

	CMP	AX,0				; 0=normal,1=error.
	JNE	TRAGET_CD_ERROR			;

TRAGET_CD_EXIT:
	MOV	AX,0				; 0=normal.
	RET
TRAGET_CD_ERROR:
	MOV	AX,1				; 1=error.
	RET
TRAGET_CD	ENDP


; ****************************************************
;	input user drive.
;	-O- PATH_FD_DRV : FD drive.
;	    EXTFLAG     : 1=RUN,2=BREAK,3=BACK
; ****************************************************

INPUT_USER_DRV	PROC	NEAR
	MOV	EXTFLAG,1			; 1=RUN

	MOV	STRADRS,OFFSET DEFPATH_FD_DRV	; default FD drive.
	CALL	DISPLY_DEF_DRV			; disply default drive.

	LCT	DSP_XY[2*6]			;
	COLOR	DSP_CLR[6]			; disply color.
	MOV	AX,1				; "フロッピーディスクの
	CALL	DSPMESS				; disply message.

	LCT	DSP_XY[2*4]			; disply locate.
	COLOR	DSP_CLR[4]			; disply color.
	SPACE_CLR	SRT_DRIVE_LEN		; string drive length.

	LCT	DSP_XY[2*4]			; disply locate.
	COLOR	DSP_CLR[4]			; disply color.
	CALL	DRIVENAME_INP			; drive name input.
	MOV	EXTFLAG,AX			; 1=RUN,2=BREAK,3=BACK

	LCT	DSP_XY[2*4]			; disply locate.
	COLOR	DSP_CLR[6]			; disply color.
	SPACE_CLR	SRT_DRIVE_LEN		; string drive length.

	LCT	DSP_XY[2*6]			; disply locate.
	COLOR	DSP_CLR[6]			; disply color.
	SPACE_CLR	CLEAR_LEN

	CMP	PATHNAME,0			; path name.
	JE	INPUT_USER_DRV_DEF		;

	MOV	SI,OFFSET PATHNAME		; path name.
	SETS	PATH_FD_DRV,STRING_LEN		; FD drive.
	RET
INPUT_USER_DRV_DEF:
	MOV	SI,OFFSET DEFPATH_FD_DRV	; default FD drive.
	SETS	PATH_FD_DRV,STRING_LEN		; FD drive.
	RET
INPUT_USER_DRV	ENDP


; ****************************************************
;	yoidesuka?
;	-O- AX : 1=RUN,2=BREAK,3=BACK
; ****************************************************

YOIDESUKA	PROC	NEAR
	LCT	DSP_XY[2*7]			; 7:yoidesuka.
	COLOR	DSP_CLR[7]			; disply color.

	MOV	AX,2				;
	CALL	DSPMESS				; disply message.

	CALL	USER_WAIT			; user wait.

	RET
YOIDESUKA	ENDP


; ****************************************************
;	space clear.
;	-I- AX : locate X.
;	    BX : locate Y.
;	    CX : length.
; ****************************************************

SPCCLR	PROC	NEAR
SPCCLR_LOOP:					;
	MOV	AL,' '				; ascii code.
	CALL	VW_CHPUT			; view/put character.
	LOOP	SPCCLR_LOOP			;
	RET
SPCCLR	ENDP


; ****************************************************
;	break wait.
;	-O- AX : 1=RUN,2=BREAK
; ****************************************************

BREAK_WAIT	PROC	NEAR
BREAK_WAIT_LOOP:			;
	CALL	USER_WAIT		; user wait.
	CMP	AX,3			; 1=RUN,2=BREAK,3=BACK
	JE	BREAK_WAIT_LOOP		;
	RET
BREAK_WAIT	ENDP


; ****************************************************
;	user wait.
;	-O- AX : 1=RUN,2=BREAK,3=BACK
; ****************************************************

USER_WAIT	PROC	NEAR

USER_WAIT_LOOP:
	CALL	VW_USERKEY		; view/user key.
	CMP	AX,3			; F.3
	JE	USER_WAIT_BREAK		;
	CMP	AX,2			; F.2
	JE	USER_WAIT_BACK		;
	CMP	AX,12			; ENTER
	JE	USER_WAIT_RUN		;

	JMP	USER_WAIT_LOOP		;

USER_WAIT_RUN:
	MOV	AX,1			; 1=RUN
	RET
USER_WAIT_BREAK:
	MOV	AX,2			; 2=BREAK
	RET
USER_WAIT_BACK:
	MOV	AX,3			; 3=BACK
	RET
USER_WAIT	ENDP


; ****************************************************
;	DATA.
; ****************************************************


PUBLIC	NOW_DTA_ADRS				; now DTA.
NOW_DTA_ADRS	DW	OFFSET DTA		; now DTA.

EXTRN	PATHNAME:BYTE				; path name.
EXTRN	PATH_FD_DRV:BYTE			; FD drive.
EXTRN	PATH_HD_DSK:BYTE			; HARD disk drive.
EXTRN	PATH_USER:BYTE				; user directory path.


;*;PATHNAME	DB	STRING_LEN DUP (0),0,0	; path name.
;*;PATH_FD_DRV	DB	"FD",STRING_LEN DUP (0),0,0	; FD drive.
;*;PATH_HD_DSK	DB	"HD",STRING_LEN DUP (0),0,0	; HARD disk drive.
;*;PATH_USER	DB	"UR",STRING_LEN DUP (0),0,0	; user directory path.

FD_NUMBER	DW	0			; FD number.

DSP_XY		LABEL	BYTE		; disply locate xy.
		DB	0,0		; 0:title.
		DB	10,8		; 1:default path.
		DB	10,9		; 2:user path.
		DB	10,11		; 3:default drive.
		DB	10,12		; 4:user drive.
		DB	10,7		; 5:message 1.
		DB	10,10		; 6:message 2.
		DB	0,14		; 7:yoidesuka.
		DB	0,6		; 8:wellcome.
		DB	0,24		; 9:function bar.
		DB	0,4		; 10:sub title.
		DB	10,8		; 11:default path2.
		DB	10,11		; 12:default drive2.
		DB	0,11		; 13:start menu 2.
		DB	0,1		; 14:title under line.
		DB	0,23		; 15:function upper line.
		DB	10,4		; 16:disk set message.
		DB	10,6		; 17:disk set message2.
		DB	10,12		; 18:disk set message3.
		DB	10,13		; 19:file copy mark.

DSP_CLR		LABEL	BYTE		; disply color.
		DB	7*32+1B		; 0:title.
		DB	7*32+101B	; 1:default path.
		DB	7*32+101B	; 2:user path.
		DB	7*32+101B	; 3:default drive.
		DB	7*32+101B	; 4:user drive.
		DB	6*32+1B		; 5:message 1.
		DB	6*32+1B		; 6:message 2.
		DB	7*32+1B		; 7:yoidesuka.
		DB	7*32+1B		; 8:wellcome.
		DB	7*32+1B		; 9:function bar.
		DB	7*32+1B		; 10:sub title.
		DB	7*32+1B		; 11:default path2.
		DB	7*32+1B		; 12:default drive2
		DB	7*32+1B		; 13:start menu 2.
		DB	5*32+1B		; 14:title under line.
		DB	5*32+1B		; 15:function upper line.
		DB	7*32+1B		; 16:disk set message.
		DB	7*32+1B		; 17:disk set message2.
		DB	7*32+1B		; 18:disk set message3.
		DB	7*32+1B		; 19:file copy mark.

DEFPATH_FD_DRV	DB	"B:",0		; default FD drive.
DEFPATH_HD_DSK	DB	"A:\PM2",0	; default path.

COPY_MARK	DB	"%",0

		EVEN
STRADRS		DW	0		; string address.

EXTFLAG		DW	0		; 1=RUN,2=BREAK,3=BACK

CODE	ENDS

	END	START
;
;	end of "INSTALL.ASM"
;
