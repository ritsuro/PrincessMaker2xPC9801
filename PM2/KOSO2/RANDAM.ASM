; "RANDAM.ASM" PC-9801UV11 make by R.H 1990/10/15
;
;
;	乱数
;
;	１から２００
;
; (C) 1990 ritsurou hashimoto.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	RANDAM_STR		; 乱数スタート
PUBLIC	RANDAM			; 乱数範囲指定
PUBLIC	RAND999X		; 乱数９９９範囲指定

EXTRN	TMVRND:NEAR		; V-SYNC timer run counter read.

;	乱数スタート

RANDAM_STR	PROC	NEAR
	MOV	RNDPNT,0		; 乱数テーブルポインタ
	CALL	TMVRND			; V-SYNC timer run counter read.
	CALL	CMDRDI			; 乱数初期化
	RET
RANDAM_STR	ENDP


;	乱数範囲指定
;	-I- AX  : 範囲（２００以内）
;	-O- AX  : １からＡＸの数字
;	    IRND: １からＡＸの数字

RANDAM	PROC	NEAR
	MOV	CX,AX
	CMP	CX,1
	JBE	RANDAM_3		;

RANDAM_SRT:
	PUSH	CX
	CALL	QRDGET			; 重複しない乱数２００
	MOV	BP,AX			; １から２００の数字
	POP	CX
RANDAM_1:
	PUSH	AX

	CMP	CX,200			;
	JBE	RANDAM_12		;
	MOV	CX,200			;
RANDAM_12:				;
	MOV	DX,0			;
	MOV	AX,20000		;
	DIV	CX			; (200×100)÷範囲＝比率％
	MOV	BX,AX			;
	POP	AX			;

	DEC	AX			; 乱数×100÷比率％
	MOV	BP,BX			;
	MOV	BX,100			;
	MUL	BX			;
	MOV	BX,BP			;
	DIV	BX			;
	INC	AX			;

	CMP	AX,CX			;
	JBE	RANDAM_2		;
	MOV	AX,CX			;
RANDAM_2:

;*;	CMP	AX,RNDOLD		; 前回の乱数
;*;	JE	RANDAM_SRT		;

	CMP	AX,0
	JE	RANDAM_SRT		;

	MOV	RNDOLD,AX		; 前回の乱数


	MOV	IRND,AX			; 乱数
	RET
RANDAM_3:
	MOV	AX,1
	MOV	IRND,AX			; 前回の乱数
	RET
RANDAM	ENDP


;	乱数９９９範囲指定
;	-I- AX  : 範囲（９９９以内）
;	-O- AX  : ０からＡＸの数字
;	    IRND: ０からＡＸの数字

RAND999X	PROC	NEAR
	MOV	CX,AX
	CMP	CX,1
	JBE	RAND999X_3		;

RAND999X_SRT:
	PUSH	CX
	CALL	QRDGET			; 重複しない乱数２００
	MOV	BP,AX			; １から２００の数字
	CALL	QRDGET			; 重複しない乱数２００
	MOV	BX,5			;
	MOV	DX,0			;
	DIV	BX			; DX = AX mod 5
	MOV	AX,DX			;
	MOV	BX,200			; AX = DX * 200
	MUL	BX			;
	DEC	BP			; -1
	ADD	AX,BP			;
	POP	CX
	PUSH	AX
	CMP	CX,999			;
	JBE	RAND999X_12		;
	MOV	CX,999			;
RAND999X_12:				;
	MOV	DX,1			;
	MOV	AX,863CH		; =99900
	DIV	CX			; (999×100)÷範囲＝比率％
	MOV	BX,AX			;
	POP	AX			;

					; 乱数×100÷比率％
	MOV	BP,BX			;
	MOV	BX,100			;
	MUL	BX			;
	MOV	BX,BP			;
	DIV	BX			;
					;
	CMP	AX,CX			;
	JBE	RAND999X_2		;
	MOV	AX,CX			;
RAND999X_2:

;*;	CMP	AX,RNDOLD		; 前回の乱数
;*;	JE	RAND999X_SRT		;

	MOV	RNDOLD,AX		; 前回の乱数

	MOV	IRND,AX			; 乱数
	RET
RAND999X_3:
	MOV	IRND,AX			; 乱数
	RET
RAND999X	ENDP


;	重複しない乱数２００
;	-O- AX :１から２００の数字

QRDGET	PROC	NEAR
	CMP	RNDPNT,200		; 乱数テーブルポインタ
	JB	QRDGET2

	MOV	RNDPNT,0		; 乱数テーブルポインタ
	CALL	TMVRND			; V-SYNC timer run counter read.
	CALL	CMDRDI			; 乱数初期化
QRDGET2:
	MOV	BX,RNDPNT		; 乱数テーブルポインタ
	MOV	AL,RNDTBL[BX]		; 乱数テーブル（２００個）
	MOV	AH,0			; ＡＸ＝１から２００のいずれか
	ADD	AX,RNDOFS		; 乱数オフセット

QRDGET4:
	CMP	AX,200
	JLE	QRDGET5
	SUB	AX,200
	JMP	QRDGET4
QRDGET5:
	CMP	AX,0
	JNE	QRDGET6
	INC	AX
QRDGET6:
	INC	RNDPNT			; 乱数テーブルポインタ
	RET
QRDGET	ENDP


;	乱数初期化
;	-I- AX : 乱数の発生ベース数値

CMDRDI	PROC	NEAR
CMDRDI2:
	CMP	AX,200			; now counter.
	JB	CMDRDI3			;
	SUB	AX,200			;
	JMP	CMDRDI2			;
CMDRDI3:				; AX : 乱数の発生ベース数値
	MOV	RNDOFS,AX		; 乱数オフセット
	MOV	RNDPNT,0		; 乱数テーブルポインタ
	RET
CMDRDI	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	IRND				; 乱数
IRND	DW	0			; 乱数
RNDOLD	DW	0			; 前回の乱数
RNDOFS	DW	0			; 乱数オフセット
RNDPNT	DW	0FFFFH			; 乱数テーブルポインタ(FFFFは初期状態)
PUBLIC	RNDTBL				; 乱数テーブル（２００個）(HOSHI.ASM)
RNDTBL	LABEL	BYTE			; 乱数テーブル（２００個）
	;   1   2   3   4   5   6   7   8   9   10
	DB 007,130,123,118,196,166,138,098,083,157
	DB 186,011,024,146,197,074,125,025,049,151
	DB 035,132,172,063,066,067,152,183,176,173
	DB 015,023,167,042,047,158,099,121,078,101
	DB 071,096,084,122,144,115,100,039,124,072
	DB 005,119,162,008,032,085,171,019,161,103
	DB 105,153,129,198,075,199,012,133,131,102
	DB 043,027,080,154,200,149,081,002,020,120
	DB 139,036,178,004,106,001,108,126,003,104
	DB 006,060,170,164,073,009,018,190,013,145
	DB 010,028,051,014,050,174,179,038,076,147
	DB 016,077,127,079,128,163,134,175,165,140
	DB 090,034,191,155,070,017,159,148,088,107
	DB 135,082,193,059,168,086,021,192,052,022
	DB 068,087,069,188,089,091,045,092,026,029
	DB 030,169,109,110,031,033,053,040,037,093
	DB 177,041,094,044,046,056,141,111,048,180
	DB 194,095,054,112,136,055,181,116,182,137
	DB 113,150,057,156,184,058,061,062,187,064
	DB 065,185,189,097,142,114,117,143,160,195

DATA	ENDS

	END
;
;	end of "RANDAM.ASM"
;
