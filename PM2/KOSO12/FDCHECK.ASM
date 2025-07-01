; "FDCHECK.ASM" PS55Z/S14 make by R.H/japan 1991/07/17
;			modifay PC-9801 1992/01/06
;
;	FD check.
;
;
; public subroutine.

INCLUDE	TSTSET.INC

MY_DISKSYSNAME	EQU	1111H	; このシステムＩＤ
MY_DISKPROG	EQU	0006H	; このプログラムＩＤ (6=PRIME2)

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	FDCKDNO				; set FD drive number.
PUBLIC	FDCKSET				; set FD check.

; ****************************************************
;	set FD drive number.
;	-I- AX : drive number.. 1=A:,2=B:,3=C:...
; ****************************************************

FDCKDNO	PROC	NEAR
	MOV	DRIVE_NUM,AX		; drive number.. 1=A:,2=B:,3=C:...
	RET
FDCKDNO	ENDP


; ****************************************************
;	set FD check.
;	-I- DX : disk number.
;	-O- AX : 1=ok,2=none.
; ****************************************************

FDCKSET	PROC	NEAR
	MOV	ID_DISKNUMBER,DX		; drive number.
	CALL	FD_TAG_CHECK			; FD tag check.
	RET
FDCKSET	ENDP


; ****************************************************
;	FD tag check.
;	-I- DRIVE_NUM      : drive number.
;	    ID_DISKSYSNAME : system  ID.
;	    ID_DISKPROG    : program ID.
;	    ID_DISKNUMBER  : disk number.
;	-O- AX		   : 1=ok,2=none.
; ****************************************************

FD_TAG_CHECK	PROC	NEAR
	CALL	MAKE_TAG_FILE_NAME		; tag file name.

	MOV	SI,OFFSET TAG_FILE_PATH		; tag file path.
	CALL	DISKFLCHK			; disk file search.
	RET
FD_TAG_CHECK	ENDP


; ****************************************************
;	disk file search.
;	-I- DS:SI : file name.
;	-O- AX    : 1=ok,2=none.
; ****************************************************

DISKFLCHK	PROC	NEAR
	MOV	DX,SI		; path name.
	MOV	AH,3DH		; handle open.
	MOV	AL,0		; read mode.
	INT	21H		; dos function.
	JC	DISKFLCHK_NAI	;

	MOV	BX,AX		; file handle.
	MOV	AH,3EH		; handle close.
	INT	21H		; dos function.

	MOV	AX,1		; 1=ok
	RET
DISKFLCHK_NAI:
	MOV	AX,2		; 2=none
	RET
DISKFLCHK	ENDP


; ****************************************************
;	tag file name.
;	-I- ID_DISKSYSNAME : system  ID.
;	    ID_DISKPROG    : program ID.
;	    ID_DISKNUMBER  : disk number.
;	-O- TAG_FILE_PATH  : tag file path.
;	    TAG_FILE_NAME  : tag file name.
;
;	path="A:11110005.A  "
;
;		"11110005.A"
;		 ----==== ^FDname
;	   systemID^  ^programID
;
;	システムＩＤの内容
;	1111H : PC-9801
;	1112H : world-PC
;
;	プログラムＩＤ（MY_DISKPROG）
;	0001H : 電脳学園３
;	0002H : サイレントメビウス
;	0003H : 電脳学園１リメイク
;	0004H : プリンセス・メーカー
;	0005H : ナディア
;	0006H : プリンセス・メーカー２	<=================
; ****************************************************

MAKE_TAG_FILE_NAME	PROC	NEAR
	MOV	DX,DRIVE_NUM		; drive number.
	ADD	DL,40H			; 'A'-1
	MOV	TAG_FILE_DRIVE,DL	; "A:" drive name.

	MOV	DX,ID_DISKSYSNAME	; system  ID.
	CALL	HEXSTR			; val DX to hex string.
	MOV	DI,OFFSET TAG_FILE_SYS	; system ID.
	MOV	CX,4			;
	CALL	MEMCPY			; memory to memory copy.

	MOV	DX,ID_DISKPROG		; program ID.
	CALL	HEXSTR			; val DX to hex string.
	MOV	DI,OFFSET TAG_FILE_PRG	; program ID.
	MOV	CX,4			;
	CALL	MEMCPY			; memory to memory copy.

	MOV	DX,ID_DISKNUMBER	; disk number.
	ADD	DL,40H			; 'A'-1
	MOV	DH,' '			;
	MOV	TAG_FILE_FDN,DL		; FD name.
	MOV	TAG_FILE_FDN[1],DH	;
	MOV	TAG_FILE_FDN[2],DH	;

	RET
MAKE_TAG_FILE_NAME	ENDP


; ****************************************************
;	DATA.
; ****************************************************

DRIVE_NUM	DW	1		; drive number.. 1=A:,2=B:,3=C:...
ID_DISKSYSNAME	DW	MY_DISKSYSNAME	; system  ID.
ID_DISKPROG	DW	MY_DISKPROG	; program ID.
ID_DISKNUMBER	DW	0		; disk number.

;tag file name.
;		"11110005.A"
;		 ----==== ^FDname
;	  systemID^  ^programID

TAG_FILE_PATH	LABEL	BYTE		; tag file path.
TAG_FILE_DRIVE	DB	"A:"		; drive name.
TAG_FILE_NAME	LABEL	BYTE		; tag file name.
TAG_FILE_SYS	DB	"XXXX"		; system ID.
TAG_FILE_PRG	DB	"YYYY"		; program ID.
		DB	"."		;
TAG_FILE_FDN	DB	"AAA"		; FD name.
		DB	0,0		; end of string.

CODE	ENDS

	END
;
;	end of "FDCHECK.ASM"
;
