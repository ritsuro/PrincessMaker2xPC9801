; "DATPL3A.ASM" PC-9801UV11 make by R.H 1990/05/10
;	modify 1991/06/22 PS55Z/J14 (code01 gate call)
;
;	バイナリデータ圧縮
;
;	バッファ長は必ず偶数倍にして下さい。
;
;	バイナリデータ（ＶＲＡＭに依存しないデータ）作成のために
;	ＤＡＴＰＬＳを改造したものです。
;
;	ＤＡＴＰＬ３．ＡＳＭの高圧縮版
;
;	先に読んだデータと同じパターンを検索して、繰り返しＩＤに
;	置き換える。
;
;
;	1992/01/22 圧縮率を上げるため、ワード毎チェックをバイト毎チェックへ
;
;
; public subroutine.


INCLUDE	TSTSET.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

	PUBLIC	C1BUNPLE		; 圧縮フォーマットデータ復元
;*;	PUBLIC	C1BPLESS		; バイナリデータ圧縮

;*;	EXTRN	CRTEYE:NEAR		; CRT eye.

;	圧縮フォーマットデータ復元
;	-I- BPNTOF  : データバッファポインタ
;	    BPNTSG  : データバッファセグメント
;	    ES:DI   : 展開データアドレス
;	-O- ES:[DI] : 展開データ
;	    CX      : 展開データ長さ

C1BUNPLE	PROC	NEAR
	MOV	AX,BPNTSG		;
	MOV	BX,BPNTOF		;
	MOV	GETSEG,AX		; get buffer segment.
	MOV	GETSTART,BX		; get start address.

	MOV	PUTSEG,ES		; put buffer segment.
	MOV	PUTSTART,DI		; put start address.

	CALL	UNPLESS			; data unpless.

	MOV	CX,DI			; put address.
	SUB	CX,PUTSTART		; put start address.

	RET
C1BUNPLE	ENDP


END_OF_DATA	EQU	0	; ＥＮＤ	データ終り
ID_COPY		EQU	8000H	; ＣＯＰＹ	展開済みデータのコピー(bit15)
MASK_LENGTH	EQU	7FFFH	; ＬＥＮＧＴＨマスク

COPY_LENGTH	EQU	6	; ＣＯＰＹデータの下限


;	data unpless.
;	-I- GETSEG   : get buffer segment.
;	    GETSTART : get start address.
;	    PUTSEG   : put buffer segment.
;	    PUTSTART : put start address.
;	-O- PUTSEG:[PUTSTART] : pless data.
;	    SI : get address.
;	    DI : put address.

UNPLESS	PROC	NEAR
	PUSH	DS

	MOV	DI,PUTSTART		; put start address.
	MOV	AX,PUTSEG		; put buffer segment.
	MOV	ES,AX			;

	MOV	SI,GETSTART		; get start address.
	MOV	AX,GETSEG		; get buffer segment.
	MOV	DS,AX			;

UNPLESS_LOOP:
	LODSW

	CMP	AX,END_OF_DATA		; [ END ]
	JE	UNPLESS_EXIT		;

	TEST	AX,ID_COPY		; [ COPY ]
	JNZ	UNPLESS_COPY		;

UNPLESS_IMAGE:				; [ IMAGE ]
	MOV	CX,AX			; [ image length ]
	REP	MOVSW			; move [ image ]
	JMP	UNPLESS_LOOP		;

UNPLESS_COPY:				; [ COPY ]
	MOV	CX,AX			; [ string length ]
	AND	CX,MASK_LENGTH		; length mask.

	LODSW				; [ string address ]

	MOV	DX,DS			; save DS.
	MOV	BP,SI			; save SI.

	MOV	SI,DI			;
	SUB	SI,AX			; copy source.

	MOV	AX,ES			;
	MOV	DS,AX			;
	REP	MOVSW			; copy string.

	MOV	DS,DX			; load DS.
	MOV	SI,BP			; load SI.
	JMP	UNPLESS_LOOP

UNPLESS_EXIT:
	POP	DS
	RET
UNPLESS	ENDP



;*;;	バイナリデータ圧縮
;*;;	-I- DX:[SI]: バイナリデータ
;*;;	    CX     : データ長さ
;*;;	    BPNTOF : データバッファポインタ
;*;;	    BPNTSG : データバッファセグメント
;*;;	    BCNTMX : データ最大長さ
;*;;	-O- BCOUNT ; データ長さ
;*;;	    BPOINT ; データ終わりアドレス＋１
;*;;	    AH     : 0 or 2 : normal end. 1:write error.
;*;;	    PLSPAR : pless parcent.
;*;
;*;C1BPLESS	PROC	NEAR
;*;	MOV	GETSEG,DX		; get buffer segment.
;*;	MOV	GETSTART,SI		; get start address.
;*;	MOV	GETPOINT,SI		; get pointer.
;*;	TEST	CX,1B			;
;*;	JZ	C1BPLESS_1		; even check.
;*;	INC	CX			; +1
;*;C1BPLESS_1:				;
;*;	ADD	SI,CX			;
;*;	MOV	GETEND,SI		; get end address.
;*;
;*;
;*;	MOV	AX,BPNTSG		;
;*;	MOV	PUTSEG,AX		; put buffer segment.
;*;	MOV	AX,BPNTOF		;
;*;	MOV	PUTSTART,AX		; put start address.
;*;	MOV	PUTPOINT,AX		; put pointer.
;*;	ADD	AX,BCNTMX		;
;*;	MOV	PUTEND,AX		; put end address.
;*;
;*;	LC	58,25
;*;	PRF	"圧縮中 PLESSING"
;*;
;*;	CALL	PLESSING		; data pless.
;*;
;*;
;*;	MOV	CX,GETPOINT		; get pointer.
;*;	SUB	CX,GETSTART		; get start address.
;*;
;*;	MOV	AX,PUTPOINT		; put address.
;*;	SUB	AX,PUTSTART		; put start address.
;*;	MOV	BX,100			;
;*;	MUL	BX			; AX = AX * 100 / CX
;*;	DIV	CX			; percent = ( odata * 100 ) / idata
;*;
;*;	MOV	PLSPAR,AX		; pless parcent.
;*;;*;	PRV	"%>",AX
;*;
;*;	MOV	AX,PUTPOINT		; put address.
;*;	SUB	AX,PUTSTART		; put start address.
;*;	MOV	BCOUNT,AX		; データ長さ
;*;
;*;	MOV	AX,PUTPOINT		; put address.
;*;	MOV	BPOINT,AX		; データ終わりアドレス＋１
;*;
;*;	MOV	AH,0			; 0 or 2 : normal end. 1:write error.
;*;	RET
;*;C1BPLESS	ENDP
;*;
;*;
;*;;	data pless.
;*;;	-I- GETSEG   : get buffer segment.
;*;;	    GETSTART : get start address.
;*;;	    GETEND   : get end address.
;*;;	    GETPOINT : get pointer.
;*;;	    PUTSEG   : put buffer segment.
;*;;	    PUTSTART : put start address.
;*;;	    PUTEND   : put end address.
;*;;	    PUTPOINT : put pointer.
;*;;	-O- PUTSEG:[PUTSTART] : pless data.
;*;;	    GETPOINT : get address.
;*;;	    PUTPOINT : put address.
;*;
;*;PLESSING	PROC	NEAR
;*;	MOV	FLAG_IMAGE_PUT,0	; IMAGE put flag
;*;
;*;	JMP	PLESSING_IMAGE		; start IMAGE
;*;
;*;PLESSING_LOOP:
;*;	CALL	ENDCHECK		; end check.
;*;
;*;	CMP	AX,1			; 1=data end.
;*;	JE	PLESSING_END		;
;*;
;*;	CALL	STRING_REP_COMPER_W	; string repart comper w.
;*;
;*;	CMP	STRLENGTH,COPY_LENGTH	; under COPY length.
;*;	JNB	PLESSING_COPY		;
;*;
;*;	JMP	PLESSING_IMAGE		;
;*;
;*;PLESSING_END:				;
;*;	PR	"END:"
;*;	CALL	SETFORM_IMAGE		; set header IMAGE.
;*;	CALL	SETFORM_END		; set header END.
;*;	JMP	PLESSING_EXIT		;
;*;
;*;PLESSING_IMAGE:				;
;*;	CMP	FLAG_IMAGE_PUT,1	; IMAGE put flag.
;*;	JE	PLESSING_IMAGE2		;
;*;	MOV	FLAG_IMAGE_PUT,1	; IMAGE put flag.
;*;
;*;	MOV	AX,GETPOINT		; get pointer.
;*;	MOV	IMAGE_DATADRS,AX	; IMAGE data address.
;*;	MOV	IMAGE_LENG,0		; IMAGE word length.
;*;PLESSING_IMAGE2:			;
;*;	INC	IMAGE_LENG		; IMAGE word length.
;*;	INC	GETPOINT		; get pointer.
;*;	INC	GETPOINT		; get pointer.
;*;
;*;	JMP	PLESSING_NEXT		;
;*;
;*;PLESSING_COPY:				;
;*;	LC	0,25
;*;	PRV	"string length. :",STRLENGTH
;*;	LC	0,26
;*;	PRV	"string address.:",STRADDRESS
;*;	LC	0,27
;*;	PRV	"get pointer.   :",GETPOINT
;*;        LC      40,25
;*;
;*;	MOV	AX,STRLENGTH		; address.
;*;	MOV	BX,GETPOINT		; address.
;*;	MOV	DX,STRADDRESS		; color.
;*;	CALL	CRTEYE			; CRT eye.
;*;
;*;	CALL	SETFORM_IMAGE		; set header IMAGE.
;*;	CALL	SETFORM_COPY		; set header COPY.
;*;
;*;	JMP	PLESSING_NEXT		;
;*;
;*;PLESSING_NEXT:				;
;*;	JMP	PLESSING_LOOP		;
;*;
;*;PLESSING_EXIT:
;*;	RET
;*;PLESSING	ENDP
;*;
;*;
;*;;	set header END.
;*;;	-I-   PUTSEG   : put buffer segment.
;*;;	-I/O- PUTPOINT : put pointer.
;*;
;*;SETFORM_END	PROC	NEAR
;*;	MOV	AX,PUTSEG		; put buffer segment.
;*;	MOV	ES,AX			;
;*;	MOV	DI,PUTPOINT		; put address.
;*;
;*;	MOV	AX,END_OF_DATA		; [ END ]
;*;	STOSW				;
;*;
;*;	MOV	PUTPOINT,DI		; put address.
;*;
;*;	RET
;*;SETFORM_END	ENDP
;*;
;*;
;*;;	set header IMAGE.
;*;;	-I-   PUTSEG        : put buffer segment.
;*;;	      IMAGE_DATADRS : IMAGE data address.
;*;;	      IMAGE_LENG    : IMAGE word length.
;*;;	      GETSEG        : get buffer segment.
;*;;	-I/O- PUTPOINT      : put address.
;*;;	      FLAG_IMAGE_PUT: IMAGE put flag. 0=IMAGE none.
;*;
;*;SETFORM_IMAGE	PROC	NEAR
;*;	CMP	FLAG_IMAGE_PUT,0	; non IMAGE data ?
;*;	JNE	SETFORM_IMAGE1		;
;*;	RET
;*;
;*;SETFORM_IMAGE1:				;
;*;	MOV	FLAG_IMAGE_PUT,0	; IMAGE put flag
;*;
;*;	MOV	AX,PUTSEG		; put buffer segment.
;*;	MOV	ES,AX			;
;*;	MOV	DI,PUTPOINT		; put address.
;*;
;*;	MOV	AX,IMAGE_LENG		; IMAGE word length.
;*;	STOSW				; [ image data length ]
;*;
;*;	MOV	SI,IMAGE_DATADRS	; IMAGE data address.
;*;
;*;	MOV	CX,IMAGE_LENG		; IMAGE word length.
;*;
;*;	PUSH	DS			;
;*;	MOV	AX,GETSEG		; get buffer segment.
;*;	MOV	DS,AX			;
;*;	REP	MOVSW			;
;*;	POP	DS			;
;*;
;*;	MOV	PUTPOINT,DI		; put address.
;*;
;*;	RET
;*;SETFORM_IMAGE	ENDP
;*;
;*;
;*;
;*;;	set header COPY.
;*;;	-I-   PUTSEG        : put buffer segment.
;*;;	      STRLENGTH     : string length.
;*;;	      STRADDRESS    : string address.
;*;;	      GETEND_POINT  : get end pointer.
;*;;	-I/O- PUTPOINT      : put address.
;*;;	-O-   GETPOINT      : get pointer.
;*;
;*;SETFORM_COPY	PROC	NEAR
;*;	MOV	AX,PUTSEG		; put buffer segment.
;*;	MOV	ES,AX			;
;*;	MOV	DI,PUTPOINT		; put address.
;*;
;*;	MOV	AX,STRLENGTH		; [ string length ]
;*;	SHR	AX,1			;
;*;	OR	AX,ID_COPY		; [ COPY ]
;*;	STOSW				;
;*;
;*;	MOV	AX,GETPOINT		;  get pointer - string point.
;*;	SUB	AX,STRADDRESS		; [ string address ]
;*;	STOSW				;
;*;
;*;	MOV	PUTPOINT,DI		; put address.
;*;
;*;	MOV	AX,GETEND_POINT		; get end pointer.
;*;	MOV	GETPOINT,AX		; get pointer.
;*;
;*;	RET
;*;SETFORM_COPY	ENDP
;*;
;*;
;*;;	string repart comper w.
;*;;	-O- STRADDRESS  : same string address.
;*;;	    STRLENGTH   : same string length.
;*;;	    GETEND_POINT: get end pointer.
;*;
;*;STRING_REP_COMPER_W	PROC	NEAR
;*;	MOV	STRADDRESS,0		; same string address.
;*;	MOV	STRLENGTH,0		; same string length.
;*;	MOV	GETEND_POINT,0		; get end pointer.
;*;
;*;	CALL	STRING_REP_COMPER	; string repart comper.
;*;
;*;	MOV	AX,GETPOINT		; get pointer.
;*;	SUB	AX,GETSTART		; get start address.
;*;	CMP	AX,1			;
;*;	JBE	STRING_REP_COMPER_W_EXIT
;*;
;*;	INC	GETSTART		; get start address.
;*;
;*;	CALL	STRING_REP_COMPER	; string repart comper.
;*;
;*;	DEC	GETSTART		; get start address.
;*;
;*;STRING_REP_COMPER_W_EXIT:
;*;	RET
;*;STRING_REP_COMPER_W	ENDP
;*;
;*;
;*;;	string repart comper.
;*;;	-I/O- STRADDRESS  : same string address.
;*;;	      STRLENGTH   : same string length.
;*;;	      GETEND_POINT: get end pointer.
;*;
;*;STRING_REP_COMPER	PROC	NEAR
;*;	MOV	AX,GETSEG		; get buffer segment.
;*;	MOV	ES,AX			;
;*;	MOV	BX,GETPOINT		; get pointer.
;*;	MOV	BP,GETSTART		; get start address.
;*;
;*;STRING_REP_COMPER_LOOP:
;*;
;*;;*;	CMP	BP,BX			; if comper string pointer.=get pointer
;*;;*;	JE	STRING_REP_COMPER_EXIT	; then exit
;*;
;*;	MOV	AX,BP			; if comper string pointer.=get pointer
;*;	INC	AX			; +1
;*;	CMP	AX,BX			; if comper string pointer.=get pointer
;*;	JNB	STRING_REP_COMPER_EXIT	; then exit
;*;
;*;	MOV	CX,GETEND		; get end address.
;*;	SUB	CX,BX			; get pointer.
;*;
;*;	SHR	CX,1			; word counter.
;*;
;*;	INC	CX			; add+1(end char check+1)
;*;
;*;	MOV	DX,DS			; save DS.
;*;
;*;	MOV	AX,ES			;
;*;	MOV	DS,AX			; buffer segment.
;*;
;*;	MOV	AX,CX			; AX=max word length.
;*;
;*;	MOV	SI,BX			; source string pointer.
;*;	MOV	DI,BP			; comper string pointer.
;*;	REPE	CMPSW			;
;*;
;*;	MOV	DS,DX			; load DS.
;*;
;*;	SUB	AX,CX			;
;*;	DEC	AX			; AX=same word length.
;*;
;*;	SHL	AX,1			; byte counter.
;*;
;*;	CMP	AX,0			;
;*;	JE	STRING_REP_COMPER_NEXT	;
;*;
;*;	CMP	AX,STRLENGTH		; if DX > all length. then
;*;	JBE	STRING_REP_COMPER_NEXT	;
;*;	MOV	STRADDRESS,BP		;   new  same string address.
;*;	MOV	STRLENGTH,AX		;   new  same string length.
;*;	ADD	AX,BX			;   source string pointer.
;*;	MOV	GETEND_POINT,AX		;   get end pointer.
;*;STRING_REP_COMPER_NEXT:			; endif
;*;
;*;	INC	BP			;
;*;	INC	BP			;
;*;
;*;	MOV	CX,BX			; get pointer.
;*;	SUB	CX,BP			; comper string pointer.
;*;
;*;	SHR	CX,1			; word counter.
;*;	INC	CX			; add+1(end char check+1)
;*;
;*;	MOV	DI,BP			; comper string pointer.
;*;	MOV	AX,ES:[BX]		; source string pointer.
;*;	REPNE	SCASW			;
;*;	DEC	DI			;
;*;	DEC	DI			;
;*;	MOV	BP,DI			; comper string pointer.
;*;
;*;	JMP	STRING_REP_COMPER_LOOP	;
;*;
;*;STRING_REP_COMPER_EXIT:
;*;	RET
;*;STRING_REP_COMPER	ENDP
;*;
;*;
;*;
;*;;	end check.
;*;;	-O- AX : 1=data end,0=normal.
;*;
;*;ENDCHECK	PROC	NEAR
;*;	MOV	AX,GETPOINT		; get pointer.
;*;	CMP	AX,GETEND		; get end address.
;*;	JE	ENDCHECK_END_DATA	;
;*;
;*;	MOV	AX,0			; 0=normal.
;*;	RET
;*;ENDCHECK_END_DATA:
;*;	MOV	AX,1			; 1=data end.
;*;	RET
;*;ENDCHECK	ENDP


;*NON*;;	dump.
;*NON*;
;*NON*;DUMP	PROC	NEAR
;*NON*;	MOV	DX,GETPOINT
;*NON*;	CALL	DECSTR
;*NON*;	CALL	PRINT
;*NON*;	PR	":"
;*NON*;	MOV	DX,PUTPOINT
;*NON*;	CALL	DECSTR
;*NON*;	CALL	PRINT
;*NON*;	PR	":"
;*NON*;	RET
;*NON*;DUMP	ENDP
;*NON*;
;*NON*;
;*NON*;;	string dump.
;*NON*;;	-I- STRADDRESS  : same string address.
;*NON*;;	    STRLENGTH   : same string length.
;*NON*;;	    GETPOINT    : get pointer.
;*NON*;;	    GETSEG      : get buffer segment.
;*NON*;
;*NON*;DUMP2	PROC	NEAR
;*NON*;	MOV	AX,GETSEG		; get buffer segment.
;*NON*;	MOV	ES,AX			;
;*NON*;
;*NON*;	LF
;*NON*;
;*NON*;	PR	"string "
;*NON*;
;*NON*;	MOV	SI,STRADDRESS		; same string address.
;*NON*;	MOV	CX,STRLENGTH		; same string length.
;*NON*;	SHR	CX,1			;
;*NON*;DUMP2_1:
;*NON*;	MOV	DX,ES:[SI]
;*NON*;	INC	SI
;*NON*;	INC	SI
;*NON*;	PUSH	SI
;*NON*;	PUSH	CX
;*NON*;	CALL	DECSTR			;
;*NON*;	CALL	PRINT			; print ah reg.
;*NON*;	PR	":"
;*NON*;	POP	CX
;*NON*;	POP	SI
;*NON*;	LOOP	DUMP2_1
;*NON*;
;*NON*;	LF
;*NON*;
;*NON*;	PR	"getstr "
;*NON*;
;*NON*;	MOV	SI,GETPOINT		; get pointer.
;*NON*;	MOV	CX,STRLENGTH		; same string length.
;*NON*;	SHR	CX,1			;
;*NON*;DUMP2_2:
;*NON*;	MOV	DX,ES:[SI]
;*NON*;	INC	SI
;*NON*;	INC	SI
;*NON*;	PUSH	SI
;*NON*;	PUSH	CX
;*NON*;	CALL	DECSTR			;
;*NON*;	CALL	PRINT			; print ah reg.
;*NON*;	PR	":"
;*NON*;	POP	CX
;*NON*;	POP	SI
;*NON*;	LOOP	DUMP2_2
;*NON*;
;*NON*;	LF
;*NON*;
;*NON*;	RET
;*NON*;DUMP2	ENDP



CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	PLSPAR			; pless parcent.

EXTRN	BPOINT:WORD		; data buffer point.
EXTRN	BPNTOF:WORD		; データバッファポインタ
EXTRN	BPNTSG:WORD		; データバッファセグメント
EXTRN	BCNTMX:WORD		; データ最大長さ
EXTRN	BCOUNT:WORD		; データ長さ

PLSPAR		DW	0	; pless parcent.

GETSEG		DW	0	; get buffer segment.
GETSTART	DW	0	; get start address.
GETEND		DW	0	; get end address.
GETPOINT	DW	0	; get pointer.

GETEND_POINT	DW	0	; get end pointer.

PUTSEG		DW	0	; put buffer segment.
PUTSTART	DW	0	; put start address.
PUTEND		DW	0	; put end address.
PUTPOINT	DW	0	; put pointer.

STRADDRESS	DW	0	; same string address.
STRLENGTH	DW	0	; same string length.

FLAG_IMAGE_PUT	DW	0	; IMAGE put flag.
IMAGE_LENG	DW	0	; IMAGE word length.
IMAGE_DATADRS	DW	0	; IMAGE data address.

DATA	ENDS
	END
;
;	end of "DATPL3A.ASM"
;
