; "DSKCH2.ASM" 486/50 make by R.H 1993/03/16
;
;
;	disk chenger.
;
;
;
;
;
;		"LIBINDEX.DIR"
;
;		###########	<- '#'is comment statment.
;		#FLIBindex#
;		#1993(C)R.#
;		#HASHIMOTO#
;		###########
;		$FS FDskip 	<- '$FS' FD chenge skip.
;		$LS lbskip 	<- '$LS' lib read skip.
;		$UA FD#0=A:	<- '$UA' FD unit#0 -> DOSpath'A:'
;		$UB FD#0=B:	<- '$UB' FD unit#0 -> DOSpath'B:'
;		$UC FD#0=C:	<- '$UC' FD unit#0 -> DOSpath'C:'
;		$UD FD#0=D:	<- '$UD' FD unit#0 -> DOSpath'D:'
;		DSKT* ROOTa
;		ENDI* ROOTa	<- file ENDI* = lib"ROOT.LBX" FDnumber1
;		MUSY* ROOTa
;		P?.M    MPh	<- file P?.M  = lib"MP.LBX"   FDnumber8
;		P??.M   MPh
;		P*.MMD  MMh	<- file P*.MMD = lib"MM.LBX"  FDnumber8
;		G*.M*   MGh	<- file G*.M*  = lib"MG.LBX"  FDnumber8
;		Z07*    Z4j
;		###########
;
;
;
;
; i/o subroutine.

INCLUDE	TSTSET.INC
INCLUDE	MESSAGE.INC

DEBUG		EQU	0	; デバックアセンブルフラグ

EOS		EQU	0

WORKREADLEN	EQU	16000	; word buffer read length.

LEN_ONE_INDEX	EQU	8	; lib file index length.
LEN_ONE_LIBNAME	EQU	10	; lib file name length.
LEN_ONE_RECORD	EQU	11	; lib file record length.
LEN_OFS_DSKNUM	EQU	10	; lib file offset disk number.

RECORD_MAX	EQU	300	; index table record max.

MAX_LIBNAME_LN	EQU	4	; lib file name length.

USERFLNM_LN	EQU	12	; user file name max length.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	DKCINI			; ディスクチェンジ初期処理
PUBLIC	DKCCHK			; ディスクチェンジチェック
PUBLIC	DKCDSKCK		; ディスクチェンジディスク指定
PUBLIC	DKCQFD			; ﾌﾛｯﾋﾟｰﾃﾞｨｽｸを使用するか

; *********************************************************
;	ディスクチェンジ初期処理
;	-O- AX : 0=normal,1=error.
; *********************************************************

DKCINI	PROC	NEAR
	MOV	FLAG_LIBSKIP,0		; flag liblary skip.
	MOV	FLAG_FDSKIP,0		; flag FD skip.

	MOV	FLAG_DKCINI_NOW,1	; flag DKCINI running.

	MOV	SI,OFFSET FL_LIBINDEX	; lib index list file name.
	MOV	DX,SEGDSKCHWORK		; disk chenger work segment.
	MOV	DI,OFSDSKCHWORK		; disk chenger work offset.
	MOV	CX,WORKREADLEN-2	; word buffer read length.
	CALLE	DISKLD			; disk load.
	CMP	AX,0			; 0=normal,1=error.
	JNE	DKCINI_ERROR

	MOV	ES,SEGDSKCHWORK		; disk chenger work segment.
	MOV	DI,OFSDSKCHWORK		; disk chenger work offset.
	ADD	DI,CX			;
	MOV	WORD PTR ES:[DI],0	; end of data.

	MOV	DX,SEGDSKCHWORK		; disk chenger work segment.
	MOV	SI,OFSDSKCHWORK		; disk chenger work offset.
	MOV	DI,OFFSET LIBFILE	; lib file index table.
	MOVX	ES,DS
	PUSH	DS
	MOV	DS,DX
DKCINI_LOOP:				; skip 0Dh,0Ah
	LODSB
	CMP	AL,0
	JE	DKCINI_LOOP_E
	CMP	AL,' '
	JB	DKCINI_NEXT
	CMP	AL,'#'
	JE	DKCINI_SKIP_1REC
	CMP	AL,'$'
	JE	DKCINI_SKIP_FLAG
	STOSB
	CMP	DI,OFFSET LIBFILE_END	; lib file index table end.
	JNB	DKCINI_LOOP_E
	JMP	DKCINI_NEXT
DKCINI_SKIP_FLAG:
	MOV	AX,DS:[SI]
	XCHG	AH,AL
	CMP	AX,"LS"
	JE	DKCINI_SKIP_FLAG_LS
	CMP	AX,"FS"
	JE	DKCINI_SKIP_FLAG_FS
	CMP	AH,"U"
	JE	DKCINI_SKIP_FLAG_UA
	JMP	DKCINI_SKIP_1REC
DKCINI_SKIP_FLAG_LS:
	MOV	ES:FLAG_LIBSKIP,1	; flag liblary skip.
	JMP	DKCINI_SKIP_1REC
DKCINI_SKIP_FLAG_FS:
	MOV	ES:FLAG_FDSKIP,1	; flag FD skip.
	JMP	DKCINI_SKIP_1REC
DKCINI_SKIP_FLAG_UA:
	SUB	AL,'A'
	MOV	ES:UNIT0_SHIFT,AL	; FD unit#0 is DOSdrivename"A:"
	JMP	DKCINI_SKIP_1REC
DKCINI_SKIP_1REC:
	ADD	SI,LEN_ONE_RECORD-1	; lib file record length.
DKCINI_NEXT:
	JMP	DKCINI_LOOP
DKCINI_LOOP_E:
	POP	DS
DKCINI_EXIT:
IF DEBUG
	PRV	"UNIT0_SHIFT =",<WORD PTR UNIT0_SHIFT>
	PRV	"FLAG_LIBSKIP=",FLAG_LIBSKIP
	PRV	"FLAG_FDSKIP =",FLAG_FDSKIP
ENDIF
	MOV	FLAG_DKCINI_NOW,0	; flag DKCINI running.
	MOV	AX,0			; 0=normal.
	RET
DKCINI_ERROR:
	MOV	FLAG_DKCINI_NOW,0	; flag DKCINI running.
	MOV	FLAG_LIBSKIP,1		; flag liblary skip.
	MOV	FLAG_FDSKIP,1		; flag FD skip.
	MOV	AX,1			; 1=error.
	RET
DKCINI	ENDP


; *********************************************************
;	ディスクチェンジチェック
;	-I- DS:SI : ファイル名
;	-O- DS:SI : 対象ファイル名
;	    DS:BX : ライブラリィ名
;	    AX    : 0=文字列見つかった, 1=見つからない
; *********************************************************

DKCCHK	PROC	NEAR
	PUSH	ES
	MOV	USER_FLNAME,SI		; user file name.
IF DEBUG
	PRSA	"DKCCHK -I- :",USER_FLNAME
ENDIF
	CMP	FLAG_DKCINI_NOW,0	; flag DKCINI running.
	JNE	DKCCHK_SKIP		;

	CMP	FLAG_LIBSKIP,0		; flag liblary skip.
	JNE	DKCCHK_SKIP		;

	CALL	SET_USER_FLNAME		; set user file name.

	CMP	FLAG_FDSKIP,0		; flag FD skip.
	JNE	DKCCHK_3		;

	MOV	DI,USER_FLNAME		; user file name.
	CALL	NFD_LIB_NAME_GET	; now FD lib name get.
IF DEBUG
	PRV	"NFD_LIB_NAME_GET -O- AX:",AX
	PRS	"LIBNAME=",LIBNAME
	PRV	"LIBDSKNUM=",LIBDSKNUM
ENDIF
	CMP	AX,1			; 1=search,0=none.
	JE	DKCCHK_4		;

DKCCHK_3:
	MOV	DI,USER_FLNAME		; user file name.
	CALL	LIB_NAME_GET		; lib name get.

IF DEBUG
	PRV	"LIB_NAME_GET -O- AX:",AX
	PRS	"LIBNAME=",LIBNAME
	PRV	"LIBDSKNUM=",LIBDSKNUM
ENDIF

	CMP	AX,0			; 1=search,0=none.
	JE	DKCCHK_ERROR		;
DKCCHK_4:
	MOV	FLUSPATHADRS,OFFSET FLUSNAME ; user file path address.
	MOV	LIBPATHADRS,OFFSET LIBNAME   ; lib name path address.

	CMP	FLAG_FDSKIP,0		; flag FD skip.
	JNE	DKCCHK_7		;

	CALL	CHECK_DRIVE		; check drive.

	CMP	LIBNAME,EOS		;lib file name.
	JE	DKCCHK_5		;

	CALL	MAKE_LIB_PATH		; make lib path.
	MOV	LIBPATHADRS,OFFSET LIBPATH ; lib name path address.
	JMP	DKCCHK_7
DKCCHK_5:
	CALL	MAKE_UFL_PATH		; make user file path.
	MOV	FLUSPATHADRS,OFFSET FLUSPATH	; user file path address.

DKCCHK_7:
IF DEBUG
	PRSA	"FLUSPATHADRS=",FLUSPATHADRS
	PRSA	"LIBPATHADRS=",LIBPATHADRS
ENDIF
	MOV	SI,FLUSPATHADRS		; user file path address.
	MOV	BX,LIBPATHADRS		; lib file name.
	MOV	AX,0			;
	POP	ES
	RET
DKCCHK_ERROR:
	MOV	SI,USER_FLNAME		; user file name.
	MOV	BX,OFFSET LIBNONE	; ライブラリィ名なし
	MOV	AX,1			;
	POP	ES
	RET
DKCCHK_SKIP:
	MOV	SI,USER_FLNAME		; user file name.
	MOV	BX,OFFSET LIBNONE	; ライブラリィ名なし
	MOV	AX,0			;
	POP	ES
	RET
DKCCHK	ENDP


; *********************************************************
;	ディスクチェンジディスク指定
;	-I- BX : 指定ディスク番号
;	-O- AX : 対象ディスクのドライブ番号
; *********************************************************

DKCDSKCK	PROC	NEAR
	MOV	LIBDSKNUM,BX		; lib file disk number.

	MOV	LIBNAME,EOS		; lib file name.(*.LBX)
	CALL	CHECK_DRIVE		; check drive.
	MOV	AX,SETDSKDRV		; 対象ディスクのドライブ番号
	RET
DKCDSKCK	ENDP


; *********************************************************
;	ﾌﾛｯﾋﾟｰﾃﾞｨｽｸを使用するか
;	-O- AX : 1=使用しない,0=使用する
; *********************************************************

DKCQFD	PROC	NEAR
	MOV	AX,FLAG_FDSKIP		; flag FD skip.
	RET
DKCQFD	ENDP


; *********************************************************
;	check drive.
;	-I- LIBDSKNUM : lib file disk number.
;	-O- SETDSKDRV : 対象ディスクのドライブ番号
; *********************************************************

CHECK_DRIVE	PROC	NEAR
	CALLE	DSKWID_OPEN		; ディスク・ウインドウＯＰＥＮ

	MOV	DX,LIBDSKNUM		; lib file disk number.
	CALLE	DKCDRVCHK		; 対象ディスクのドライブ検索
	CMP	AX,0			; 0=対象ディスクはセットされています
	JE	CHECK_DRIVE_PATH_SET	;

	MOV	SI,OFFSET LIBNAME	;lib file name.
	CALLE	DSKWID_PATH_NM_SET	; ディスク・パス名セット

	MOV	DX,LIBDSKNUM		; lib file disk number.
	CALLE	DKCDRVINSWAIT		; ドライブにセットされるのを待つ

CHECK_DRIVE_PATH_SET:
	MOV	SETDSKDRV,DX		; 対象ディスクのドライブ番号
	CALLE	DSKWID_CLOSE		; ディスク・ウインドウＣＬＯＳＥ
	RET
CHECK_DRIVE	ENDP


; *********************************************************
;	set user file name.
;	-I- USER_FLNAME : user file name.
;	-O- FLUSNAME    : user file name.
; *********************************************************

SET_USER_FLNAME	PROC	NEAR
	MOVX	ES,DS
	MOV	SI,USER_FLNAME		; user file name.
	MOV	DI,OFFSET FLUSNAME	; user file name.
	MOV	CX,USERFLNM_LN		; user file name max length.
SET_USER_FLNAME_LOOP:
	LODSB
	CMP	AL,' '
	JBE	SET_USER_FLNAME_LOOP_E
	STOSB
	LOOP	SET_USER_FLNAME_LOOP
SET_USER_FLNAME_LOOP_E:
	MOV	AL,EOS
	STOSB
	RET
SET_USER_FLNAME	ENDP


; *********************************************************
;	make user file path.
;	-I- SETDSKDRV : 対象ディスクのドライブ番号
;	-O- FLUSPATH  : user file path.
; *********************************************************

MAKE_UFL_PATH	PROC	NEAR
	MOV	DX,SETDSKDRV		; 対象ディスクのドライブ番号
	MOV	AL,'A'			;'A'
	ADD	AL,DL			; 対象ディスクのドライブ番号
	ADD	AL,UNIT0_SHIFT		; FD unit#0 is DOSdrivename"A:"
	MOV	FLUSPATH,AL		;"A:" user file path.
	RET
MAKE_UFL_PATH	ENDP


; *********************************************************
;	make lib path.
;	-I- SETDSKDRV : 対象ディスクのドライブ番号
;	-O- LIBPATH   : lib path.
; *********************************************************

MAKE_LIB_PATH	PROC	NEAR
	MOV	DX,SETDSKDRV		; 対象ディスクのドライブ番号
	MOV	AL,'A'			;'A'
	ADD	AL,DL			; 対象ディスクのドライブ番号
	ADD	AL,UNIT0_SHIFT		; FD unit#0 is DOSdrivename"A:"
	MOV	LIBPATH,AL		;"A:" lib path.
	RET
MAKE_LIB_PATH	ENDP


; *********************************************************
;	lib name get.
;	-I- DS:DI : user file name.
;	-O- AX    :   1=search,0=none.
;	    LIBNAME : lib file name.(*.LBX)
;	    LIBDSKNUM : lib file disk number.(1-26)
; *********************************************************

LIB_NAME_GET	PROC	NEAR
	MOV	LIBNAME,EOS		; lib file name.(*.LBX)
	MOV	LIBDSKNUM,0		; lib file disk number.(1-26)

	MOV	SI,OFFSET LIBFILE	; lib file index table.
LIB_NAME_GET_LOOP:
	MOV	BX,SI			; SI=index.
	MOV	DX,DI			; DI=user file name.

	MOV	AL,DS:[SI]		;
	CMP	AL,0			; index end.
	JE	LIB_NAME_GET_NONE	;
	CMP	DS:[DI],AL		; top 1char check.
	JNE	LIB_NAME_GET_NEXT	; skip index.

	MOV	CX,LEN_ONE_INDEX	; lib file index length.
LIB_NAME_GET_LOOP2:			;
	LODSB				; AL=get index 1char.
	MOV	AH,DS:[DI]		; AH=get user 1char.
	INC	DI			;
	CMP	AL,' '			;
	JNBE	LIB_NAME_GET_3		;
	CMP	AH,' '			; if ( AL<=' ' && AH<=' ' )
	JBE	LIB_NAME_GET_OK		;   same length. -> OK
LIB_NAME_GET_3:
	CMP	AL,'*'			; if ( AL=='*' )
	JE	LIB_NAME_GET_WILD_CK	;   wild card.
	CMP	AL,'?'			; if ( AL=='?' )
	JE	LIB_NAME_GET_NEXT2	;   skip 1char.
	CMP	AL,AH			; if ( AL != AH )
	JNE	LIB_NAME_GET_NEXT	;   skip index.
	JMP	LIB_NAME_GET_NEXT2	;
LIB_NAME_GET_WILD_CK:
	MOV	AL,DS:[SI]		;
	CMP	AL,'.'			; if extention check none?
	JNE	LIB_NAME_GET_OK		;   -> OK

	DEC	DI			;
LIB_NAME_GET_LOOP3:
	MOV	AH,DS:[DI]		; AH=get user 1char.
	INC	DI			;
	CMP	AH,' '			;
	JBE	LIB_NAME_GET_NEXT	;   skip index.
	CMP	AH,'.'			;
	JNE	LIB_NAME_GET_LOOP3	;

	DEC	DI			;
LIB_NAME_GET_NEXT2:
	LOOP	LIB_NAME_GET_LOOP2	;
	JMP	LIB_NAME_GET_OK		; same length. -> OK

LIB_NAME_GET_NEXT:
	MOV	DI,DX			;
	MOV	SI,BX			;
	ADD	SI,LEN_ONE_RECORD	; lib file record length.
	JMP	LIB_NAME_GET_LOOP

LIB_NAME_GET_OK:
	MOV	AX,SI			; SI=index pointer now.
	SUB	AX,BX			; BX=index record offset.
	MOV	CX,LEN_ONE_LIBNAME	; lib file name length.
	SUB	CX,AX			;
	PUSH	BX			;
	CALL	LIB_NAME_MAKE		; lib name make.
	POP	BX			;
	CALL	LIBFILE_DSKNUM		; lib file disk number.
LIB_NAME_GET_SCH:
	MOV	AX,1			; 1=search.
	RET
LIB_NAME_GET_NONE:
	MOV	AX,0			; 0=none.
	RET
LIB_NAME_GET	ENDP


; *********************************************************
;	now FD lib name get.
;	-I- DS:DI : user file name.
;	-O- AX    :   1=search,0=none.
;	    LIBNAME : lib file name.(*.LBX)
;	    LIBDSKNUM : lib file disk number.(1-26)
; *********************************************************

NFD_LIB_NAME_GET	PROC	NEAR
	MOV	LIBNAME,EOS		; lib file name.(*.LBX)
	MOV	LIBDSKNUM,0		; lib file disk number.(1-26)

	CALLE	DKCDRVNOWFD		; 現在セットされているディスク

	MOV	DRV_SET_DISK[0],AL	; ﾄﾞﾗｲﾌﾞ0のﾃﾞｨｽｸ番号
	MOV	DRV_SET_DISK[1],BL	; ﾄﾞﾗｲﾌﾞ1のﾃﾞｨｽｸ番号
	MOV	DRV_SET_DISK[2],CL	; ﾄﾞﾗｲﾌﾞ2のﾃﾞｨｽｸ番号
	MOV	DRV_SET_DISK[3],DL	; ﾄﾞﾗｲﾌﾞ3のﾃﾞｨｽｸ番号

	MOV	SI,OFFSET LIBFILE	; lib file index table.
NFD_LIB_NAME_GET_LOOP:
	MOV	BX,SI			; SI=index.
	MOV	DX,DI			; DI=user file name.

	MOV	AL,DS:[SI]		;
	CMP	AL,0			; index end.
	JE	NFD_LIB_NAME_GET_NONE	;
	CMP	DS:[DI],AL		; top 1char check.
	JNE	NFD_LIB_NAME_GET_NEXT	; skip index.

	MOV	AL,DS:[SI][LEN_OFS_DSKNUM] ; lib file offset disk number.
	SUB	AL,60H			; 'a'-1
	CMP	AL,DRV_SET_DISK[0]	; ﾄﾞﾗｲﾌﾞ0のﾃﾞｨｽｸ番号
	JE	NFD_LIB_NAME_GET_DRV_OK	;
	CMP	AL,DRV_SET_DISK[1]	; ﾄﾞﾗｲﾌﾞ1のﾃﾞｨｽｸ番号
	JE	NFD_LIB_NAME_GET_DRV_OK	;
	CMP	AL,DRV_SET_DISK[2]	; ﾄﾞﾗｲﾌﾞ2のﾃﾞｨｽｸ番号
	JE	NFD_LIB_NAME_GET_DRV_OK	;
	CMP	AL,DRV_SET_DISK[3]	; ﾄﾞﾗｲﾌﾞ3のﾃﾞｨｽｸ番号
	JE	NFD_LIB_NAME_GET_DRV_OK	;
	JMP	NFD_LIB_NAME_GET_NEXT	; skip index.
NFD_LIB_NAME_GET_DRV_OK:		;

	MOV	CX,LEN_ONE_INDEX	; lib file index length.
NFD_LIB_NAME_GET_LOOP2:			;
	LODSB				; AL=get index 1char.
	MOV	AH,DS:[DI]		; AH=get user 1char.
	INC	DI			;
	CMP	AL,' '			;
	JNBE	NFD_LIB_NAME_GET_3	;
	CMP	AH,' '			; if ( AL<=' ' && AH<=' ' )
	JBE	NFD_LIB_NAME_GET_OK	;   same length. -> OK
NFD_LIB_NAME_GET_3:
	CMP	AL,'*'			; if ( AL=='*' )
	JE	NFD_LIB_NAME_GET_WILD_CK ;   wild card.
	CMP	AL,'?'			; if ( AL=='?' )
	JE	NFD_LIB_NAME_GET_NEXT2	;   skip 1char.
	CMP	AL,AH			; if ( AL != AH )
	JNE	NFD_LIB_NAME_GET_NEXT	;   skip index.
	JMP	NFD_LIB_NAME_GET_NEXT2	;
NFD_LIB_NAME_GET_WILD_CK:
	MOV	AL,DS:[SI]		;
	CMP	AL,'.'			; if extention check none?
	JNE	NFD_LIB_NAME_GET_OK	;   -> OK

	DEC	DI			;
NFD_LIB_NAME_GET_LOOP3:
	MOV	AH,DS:[DI]		; AH=get user 1char.
	INC	DI			;
	CMP	AH,' '			;
	JBE	NFD_LIB_NAME_GET_NEXT	;   skip index.
	CMP	AH,'.'			;
	JNE	NFD_LIB_NAME_GET_LOOP3	;

	DEC	DI			;
NFD_LIB_NAME_GET_NEXT2:
	LOOP	NFD_LIB_NAME_GET_LOOP2	;
	JMP	NFD_LIB_NAME_GET_OK	; same length. -> OK

NFD_LIB_NAME_GET_NEXT:
	MOV	DI,DX			;
	MOV	SI,BX			;
	ADD	SI,LEN_ONE_RECORD	; lib file record length.
	JMP	NFD_LIB_NAME_GET_LOOP

NFD_LIB_NAME_GET_OK:
	MOV	AX,SI			; SI=index pointer now.
	SUB	AX,BX			; BX=index record offset.
	MOV	CX,LEN_ONE_LIBNAME	; lib file name length.
	SUB	CX,AX			;
	PUSH	BX			;
	CALL	LIB_NAME_MAKE		; lib name make.
	POP	BX			;
	CALL	LIBFILE_DSKNUM		; lib file disk number.
NFD_LIB_NAME_GET_SCH:
	MOV	AX,1			; 1=search.
	RET
NFD_LIB_NAME_GET_NONE:
	MOV	AX,0			; 0=none.
	RET
NFD_LIB_NAME_GET	ENDP


; *********************************************************
;	lib name make.
;	-I- SI : now index pointer.
;	    CX : now index record length.
;	-O- LIBNAME	; lib file name.
; *********************************************************

LIB_NAME_MAKE	PROC	NEAR
	MOVX	ES,DS

LIB_NAME_MAKE_LOOP:			;
	MOV	AL,DS:[SI]		; brank skip.
	CMP	AL,' '			;
	JNE	LIB_NAME_MAKE_55	;
	INC	SI			;
	DEC	CX			;
	JMP	LIB_NAME_MAKE_LOOP	;

LIB_NAME_MAKE_55:
	CMP	CX,MAX_LIBNAME_LN	; lib file name.
	JBE	LIB_NAME_MAKE_6		;
	MOV	CX,MAX_LIBNAME_LN	; lib file name.
LIB_NAME_MAKE_6:

	MOV	DI,OFFSET LIBNAME	; lib file name.
	MOV	WORD PTR DS:[DI],0	;
	JCXZ	LIB_NAME_MAKE_EXIT	;
LIB_NAME_MAKE_LOOP4:
	LODSB
	CMP	AL,' '
	JBE	LIB_NAME_MAKE_7
	STOSB
	LOOP	LIB_NAME_MAKE_LOOP4
LIB_NAME_MAKE_7:
	MOV	SI,OFFSET LIBEXP	; ".LBX",0,0
	MOV	CX,5			;
	REP	MOVSB			;
LIB_NAME_MAKE_EXIT:
	RET
LIB_NAME_MAKE	ENDP


; *********************************************************
;	lib file disk number.
;	-I- BX        : index record offset.
;	-O- LIBDSKNUM : lib file disk number.
; *********************************************************

LIBFILE_DSKNUM	PROC	NEAR
	MOV	AH,0				;
	MOV	AL,DS:[BX][LEN_OFS_DSKNUM]	; disk number.
	SUB	AL,60H				; 'a'-1
	MOV	LIBDSKNUM,AX			; lib file disk number.
	RET
LIBFILE_DSKNUM	ENDP


CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	SEGDSKCHWORK:WORD	; disk chenger work segment.
EXTRN	OFSDSKCHWORK:WORD	; disk chenger work offset.

FLAG_DKCINI_NOW	DW	0		; flag DKCINI running.
FLAG_LIBSKIP	DW	1		; flag liblary skip.
FLAG_FDSKIP	DW	1		; flag FD skip.

USER_FLNAME	DW	0		; user file name.
LIBDSKNUM	DW	0		; lib file disk number.

SETDSKDRV	DW	0		; 対象ディスクのドライブ番号

UNIT0_SHIFT	DB	0,0		; FD unit#0 is DOSdrivename"A:"

DRV_SET_DISK	DB	0,0,0,0			; ﾄﾞﾗｲﾌﾞのﾃﾞｨｽｸ番号

FLUSPATHADRS	DW	FLUSNAME		; user file path address.
FLUSPATH	DB	"A:"			; user file path.
FLUSNAME	DB	USERFLNM_LN DUP (0),0,0	; user file name.

LIBPATHADRS	DW	LIBNAME			; lib name path address.
LIBPATH		DB	"A:"				     ;lib path.
LIBNAME		DB	MAX_LIBNAME_LN DUP (0),4 DUP (0),0,0 ;lib file name.

LIBEXP		DB	".LBX",0,0
LIBNONE		DB	0,0		; ライブラリィ名なし

FL_LIBINDEX	DB	"LIBINDEX.DIR",0	; lib index list file name.

LIBFILE		LABEL	BYTE		; lib file index table.
	DB	"LIBINDEX   "
	DB	LEN_ONE_RECORD*RECORD_MAX DUP (0)
LIBFILE_END	LABEL	BYTE		; lib file index table end.
	DB	0,0

DATA	ENDS

	END
;
;	end of "DSKCH2.ASM"
;
