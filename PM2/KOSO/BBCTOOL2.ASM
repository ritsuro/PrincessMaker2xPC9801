; "BBCTOOL2.ASM" 486/50 make by R.H 1992/05/29
;
;
;	princess  B A S I C    command tool 2.
;
;
;	* * * WARNING * * *
;	* * *  注 意  * * *
;
;	This subroutines i/o list.
;	このサブルーチン類の I/O list は以下のようになっています。
;
;	AX -> public REG_AX
;	BX -> public REG_BX
;	CX -> public REG_CX
;	DX -> public REG_DX
;	SI -> public REG_SI
;	DI -> public REG_DI
;	ES -> public REG_ES
;
;	; syntax : P1X100(value,x100)	-> ; syntax : P1X100
;	; 百分率			-> ; 百分率
;	; -i- value (AX): source value.	-> ; -i- REG_AX : source value.
;	;     x100  (BX): %		-> ;     REG_BX : %
;	; -o- AX        : value.	-> ; -o- REG_AX : value.
;
;
;
; command routine.

INCLUDE	TSTSETC.INC
INCLUDE	BBEXTRN.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	BBC2_FFDISK		; ディスク操作

EXTRN	PDISK_SAVE:NEAR		; データセーブ
EXTRN	PDISK_LOAD:NEAR		; データロード
EXTRN	PDISK_CHECK:NEAR	; データチェック

EXTRN	DKCQFD:NEAR		; ﾌﾛｯﾋﾟｰﾃﾞｨｽｸを使用するか
EXTRN	DKCDSKCK:NEAR		; ディスクチェンジディスク指定

; *********************************************************
;	ディスク操作
;	FFDISK(function)
;	-i- function : 機能
;
;	FFDISK(1,number)	: データセーブ
;		-o- AX : 0=normal,1=error.
;	FFDISK(2,number)	: データロード
;		-o- AX : 0=normal,1=error,101=file not found.
;	FFDISK(3,number)	: データチェック
;		-o- AX : 0=normal,1=error,101=file not found.
;		    BX : 年
;		    CX : 月
;		    DX : 曜日
;		    SI : 日
;		    DI : 娘の名前 18byte(名前)+2byte+18byte(名字)+2byte.
;	FFDISK(4)		:ﾌﾛｯﾋﾟｰﾃﾞｨｽｸを使用するか
;		-o- AX : 1=使用しない,0=使用する
;	FFDISK(5,disknum)	: ディスクチェンジディスク指定
;		-o- AX : 対象ディスクのドライブ番号
;
; *********************************************************

BBC2_FFDISK	PROC	NEAR
	MOV	BX,REG_BX				;
	MOV	CX,REG_CX				;
	MOV	DX,REG_DX				;
	MOV	SI,REG_SI				;
	MOV	DI,REG_DI				;

	MOV	BP,REG_AX				;
	DEC	BP					; -1
	CMP	BP,(JMP_FFDISK_END-JMP_FFDISK)/2	; jump table.
	JNB	BBC2_FFDISK_EXIT			;
	SHL	BP,1					; word pointer.
	CALL	WORD PTR DS:JMP_FFDISK[BP]		; jump table.
BBC2_FFDISK_EXIT:
;*;	MOV	REG_BP,BP				;
	MOV	REG_DI,DI				;
	MOV	REG_SI,SI				;
	MOV	REG_DX,DX				;
	MOV	REG_CX,CX				;
	MOV	REG_BX,BX				;
	MOV	REG_AX,AX				;
	RET
BBC2_FFDISK	ENDP

CODE01	ENDS

; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

JMP_FFDISK	LABEL	WORD	; jump table.
	DW	PDISK_SAVE	; データセーブ
	DW	PDISK_LOAD	; データロード
	DW	PDISK_CHECK	; データチェック
	DW	DKCQFD		; ﾌﾛｯﾋﾟｰﾃﾞｨｽｸを使用するか
	DW	DKCDSKCK	; ディスクチェンジディスク指定
JMP_FFDISK_END	LABEL	WORD	; jump table end.

DATA	ENDS

	END
;
;	end of "BBCTOOL2.ASM"
;
