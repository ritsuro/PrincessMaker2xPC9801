; "BBASYS.ASM" PC-9801UV11 make by R.H 1991/10/16
;
;
;	princess  B A S I C    字句解析部
;
;
; command routine.

INCLUDE	TSTSETC.INC
INCLUDE	BBEXTRN.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	SJISCHK		; シフトＪＩＳチェック

CODE01	ENDS

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:DATA

PUBLIC	BBLKSKP		; ブランクスキップ
PUBLIC	BBSYMBCHK	; 先頭記号検査
PUBLIC	BBSYMBGET	; シンボル取得
PUBLIC	BBSTRSYMBGET	; 文字列からシンボル取得
PUBLIC	BBCMDGNM	; 数字の取り出し
PUBLIC	BBVALUE_GET	; 右辺数値取り出し
PUBLIC	BBSTRDIM_GET	; 文字列から配列添字取出
PUBLIC	BBCMDSTR	; 文字列の取り出し
PUBLIC	BBCMDSTRNC	; 文字列の取り出し("=無)
PUBLIC	BBSJISCHK	; シフトＪＩＳチェック
PUBLIC	BBNUMBER	; 文字列－＞数字チェック
PUBLIC	BBLFSKIP	; 次の行までスキップ
PUBLIC	BBNOWNEST	; 現在行のネストレベル

EXTRN	BBSOUSYM_SCH:NEAR	; source symbol table search.


; *********************************************************
;	ブランクスキップ
;	-I/O- TEXTPSEG : text segment pointer.
;	      TEXTPOFS : text offset pointer.
;	-O-   AX       : 0=normal,1=end of text.
; *********************************************************

BBLKSKP	PROC	NEAR
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	SI,TEXTPOFS		; text offset pointer.
BLKSKP_LOOP:
	MOV	DL,ES:[SI]		; DL=character code.
	CMP	DL,EOT			; end of text.
	JE	BLKSKP_EOT		;
	CMP	DL,CHR_SPACE		; space.
	JE	BLKSKP_NEXT		;
	CMP	DL,CHR_TAB		; TAB
	JE	BLKSKP_NEXT		;

	JMP	BLKSKP_EXIT		;
BLKSKP_NEXT:
	INC	SI			; テキストカレント
	JMP	BLKSKP_LOOP		;
BLKSKP_EXIT:
	MOV	TEXTPOFS,SI		; text offset pointer.
	MOV	AX,0			; 0=normal.
	RET
BLKSKP_EOT:
	MOV	TEXTPOFS,SI		; text offset pointer.
	MOV	AX,1			; 1=end of text.
	RET
BBLKSKP	ENDP


; *********************************************************
;	先頭記号検査
;	-I- TEXTPSEG  : text segment pointer.
;	    TEXTPOFS  : text offset pointer.
;	-O- AX        : 0=normal,1=label,2=undef,3=comment.
;			 4=select command,5=select word,6=(,7=),8=if,9=comma.
;			10=seen label,11=define.
; *********************************************************

BBSYMBCHK	PROC	NEAR
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	SI,TEXTPOFS		; text offset pointer.
	MOV	AL,ES:[SI]		; 1 char get.

	CMP	AL,'A'			; if 'A' =< AL =< 'Z' then normal.
	JB	BBSYMBCHK_3		;
	CMP	AL,'Z'			;
	JNBE	BBSYMBCHK_3		;
	JMP	BBSYMBCHK_NORMAL	;
BBSYMBCHK_3:
	CMP	AL,'a'			; if 'a' =< AL =< 'z' then normal.
	JB	BBSYMBCHK_4		;
	CMP	AL,'z'			;
	JNBE	BBSYMBCHK_4		;
	JMP	BBSYMBCHK_NORMAL	;
BBSYMBCHK_4:
	CMP	AL,'0'			; if '0' =< AL =< '9' then normal.
	JB	BBSYMBCHK_5		;
	CMP	AL,'9'			;
	JNBE	BBSYMBCHK_5		;
	JMP	BBSYMBCHK_NORMAL	;
BBSYMBCHK_5:
	CMP	AL,'_'			; if  AL = '_' then normal.
	JE	BBSYMBCHK_NORMAL	;
	CMP	AL,'-'			; if  AL = '-' then normal.
	JE	BBSYMBCHK_NORMAL	;
	CMP	AL,'$'			; if  AL = '-' then normal.
	JE	BBSYMBCHK_NORMAL	;

	CMP	AL,MARKLABEL		; * if  AL = label mark  then label.
	JE	BBSYMBCHK_LABEL		;

	CMP	AL,MARKCOMMENT		; ; if  AL = comment mark  then normal.
	JE	BBSYMBCHK_COMMENT	;
	CMP	AL,MARKCOMMENT2		; ; if  AL = comment mark  then normal.
	JE	BBSYMBCHK_COMMENT	;

	CMP	AL,MARKBEGIN		; ( begin mark.
	JE	BBSYMBCHK_BEGIN		;

	CMP	AL,MARKEND		; ) end mark.
	JE	BBSYMBCHK_END		;

	CMP	AL,MARKIF		; ? if mark.
	JE	BBSYMBCHK_IF		;

	CMP	AL,CHR_COMMA		; , comma.
	JE	BBSYMBCHK_COMMA		;

	CMP	AL,MARKDEF		; . define.
	JE	BBSYMBCHK_DEFINE	;

	JMP	BBSYMBCHK_UNDEF		;

BBSYMBCHK_NORMAL:
	MOV	AX,0			; 0=normal.
	RET
BBSYMBCHK_LABEL:
	MOV	AX,1			; 1=label.
	RET
BBSYMBCHK_UNDEF:
	MOV	AX,2			; 2=undef.
	RET
BBSYMBCHK_COMMENT:
	MOV	AX,3			; 3=comment.
	RET
BBSYMBCHK_SLCT_CMD:
	MOV	AX,4			; 4=select command.
	RET
BBSYMBCHK_SLCT_WORD:
	MOV	AX,5			; 5=select word.
	RET
BBSYMBCHK_BEGIN:
	MOV	AX,6			; 6=(
	RET
BBSYMBCHK_END:
	MOV	AX,7			; 7=)
	RET
BBSYMBCHK_IF:
	MOV	AX,8			; 8=if
	RET
BBSYMBCHK_COMMA:
	MOV	AX,9			; 9=comma.
	RET
BBSYMBCHK_LABELNM:
	MOV	AX,10			; 10=seen label.
	RET
BBSYMBCHK_DEFINE:
	MOV	AX,11			; 11=define.
	RET
BBSYMBCHK	ENDP


; *********************************************************
;	シンボル取得
;	-I/O- TEXTPSEG  : text segment pointer.
;	      TEXTPOFS  : text offset pointer.
;	-O-   STRSYMBOL : symbol string.
;	      STRSYMLEN : symbol length.
; *********************************************************

BBSYMBGET	PROC	NEAR
	MOV	STRSYMLEN,0		; symbol length.

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	SI,TEXTPOFS		; text offset pointer.
	MOV	DI,STRSYMBOL		; symbol string.
	MOV	CX,STRSYMMAX		; symbol max length.

	CALL	BBSTRSYMBGET		; 文字列からシンボル取得

	MOV	STRSYMLEN,BP		; text offset pointer.

	ADDX	TEXTPOFS,STRSYMLEN	; text offset pointer.

	MOVX	ES,DS			;
	MOV	DI,STRSYMBOL		; symbol string.
	CALLE	c_STRCAPS		; 文字列大文字化

	RET
BBSYMBGET	ENDP


; *********************************************************
;	文字列からシンボル取得
;	-I- ES:SI : string.
;	    DS:DI : symbol buffer.
;	    CX    : symbol buffer size.
;	-O- DS:[DI] : symbol string.
;	    BP    : symbol length.
; *********************************************************

BBSTRSYMBGET	PROC	NEAR
	PUSH	SI
	PUSH	DI

	MOV	BP,0			; symbol length.
	JCXZ	BBSTRSYMBGET_LOOP_E	;

	MOV	AL,ES:[SI]		; 1 char get.
	INC	SI			;
	CMP	AL,'+'			;
	JE	BBSTRSYMBGET_SET	;
	CMP	AL,'-'			;
	JE	BBSTRSYMBGET_SET	;
	JMP	BBSTRSYMBGET_INTER	;
BBSTRSYMBGET_LOOP:
	MOV	AL,ES:[SI]		; 1 char get.
	INC	SI			;
BBSTRSYMBGET_INTER:
	CMP	AL,'A'			; if 'A' =< AL =< 'Z' then set.
	JB	BBSTRSYMBGET_3		;
	CMP	AL,'Z'			;
	JNBE	BBSTRSYMBGET_3		;
	JMP	BBSTRSYMBGET_SET	;
BBSTRSYMBGET_3:
	CMP	AL,'a'			; if 'a' =< AL =< 'z' then set.
	JB	BBSTRSYMBGET_4		;
	CMP	AL,'z'			;
	JNBE	BBSTRSYMBGET_4		;
	JMP	BBSTRSYMBGET_SET	;
BBSTRSYMBGET_4:
	CMP	AL,'0'			; if '0' =< AL =< '9' then set.
	JB	BBSTRSYMBGET_5		;
	CMP	AL,'9'			;
	JNBE	BBSTRSYMBGET_5		;
	JMP	BBSTRSYMBGET_SET	;
BBSTRSYMBGET_5:
	CMP	AL,'_'			; if  AL = '_' then set.
	JE	BBSTRSYMBGET_SET	;
	CMP	AL,'$'			; if  AL = '$' then set.
	JE	BBSTRSYMBGET_SET	;

	JMP	BBSTRSYMBGET_LOOP_E	; symbol end.

BBSTRSYMBGET_SET:
	MOV	DS:[DI],AL		;
	INC	DI			;

	INC	BP			; symbol length.

	LOOP	BBSTRSYMBGET_LOOP
BBSTRSYMBGET_LOOP_E:
	MOV	BYTE PTR DS:[DI],EOS	; end of string.

	POP	DI
	POP	SI
	RET
BBSTRSYMBGET	ENDP


; *********************************************************
;	数字の取り出し
;	-I/O- TEXTPSEG  : text segment pointer.
;	      TEXTPOFS  : text offset pointer.
;	-O-   DX        : 取り出し数字(ないときは０)
;	      AX        : 0=正常,1=数字列が無い
; *********************************************************

BBCMDGNM	PROC	NEAR
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	SI,TEXTPOFS		; text offset pointer.

	MOV	DI,OFFSET CMDWRD	; 取り出し単語

	MOV	DL,ES:[SI]		;
	CMP	DL,'+'			;
	JE	BBCMDGNM_1		;
	CMP	DL,'-'			;
	JE	BBCMDGNM_1		;
	JMP	BBCMDGNM_2		;
BBCMDGNM_1:				;
	INC	SI			; byte pointer.
	MOV	DS:[DI],DL		; put 1 char.
	INC	DI			; byte pointer.
BBCMDGNM_2:

	MOV	CX,5			; 単語長さ
BBCMDGNM_LOOP:
	MOV	DL,ES:[SI]		;
	CMP	DL,'0'			;
	JB	BBCMDGNM_EXIT		;
	CMP	DL,'9'			;
	JNBE	BBCMDGNM_EXIT		;

	INC	SI			; byte pointer.

	MOV	DS:[DI],DL		; put 1 char.
	INC	DI			; byte pointer.

	JMP	BBCMDGNM_LOOP		;

BBCMDGNM_EXIT:
	MOV	TEXTPOFS,SI		; text offset pointer.
	MOV	BYTE PTR DS:[DI],EOS	; end of string.
	CMP	BYTE PTR CMDWRD,EOS	; 取り出し数字列無しか？
	JE	BBCMDGNM_ERROR		;

	MOV	SI,OFFSET CMDWRD	; 取り出した数値文字列
	CALLE	c_STRDEC		; dec string to DX reg.
					; DX=取り出し数値
	MOV	AX,0     		; 0=正常
	RET				;
BBCMDGNM_ERROR:
	MOV	DX,0			; DX=取り出し数値
	MOV	AX,1			; 1=数字列が無い
	RET
BBCMDGNM	ENDP


; *********************************************************
;	右辺数値取り出し
;	-I/O- TEXTPSEG  : text segment pointer.
;	      TEXTPOFS  : text offset pointer.
;	-O-   DX        : 取り出し数字(ないときは０)
;	      AX        : 0=normal,1=none,2=strings.
;	      CX        : 0=memory,1=immidiate.
;	      SOUSYMSEGM: segment of source symbol.
;	      SOUSYMOFST: offset of source symbol.
; *********************************************************

BBVALUE_GET	PROC	NEAR
	CALL	BBCMDGNM		; 数字の取り出し
	CMP	AX,0			; 0=正常,1=数字列が無い
	JE	BBVALUE_GET_IMM		;

	CALL	BBSYMBGET		; シンボル取得
	CMP	STRSYMLEN,0		; symbol length.
	JE	BBVALUE_GET_STR		;

	CALL	BBSOUSYM_SCH		; source symbol table search.
	CMP	AX,0			; 0=search,1=none.
	JE	BBVALUE_GET_SET		;

	JMP	BBVALUE_GET_NONE	;

BBVALUE_GET_IMM:			;
	MOV	CX,1			; 1=immidiate.
	JMP	BBVALUE_GET_EXIT	;
BBVALUE_GET_SET:			;
	MOV	ES,SOUSYMSEGM		; segment of source symbol.
	MOV	DI,SOUSYMOFST		; offset of source symbol.
	MOV	DX,ES:[DI]		;
	MOV	CX,0			; 0=memory.
BBVALUE_GET_EXIT:
	MOV	AX,0			; 0=normal.
	RET
BBVALUE_GET_NONE:
	MOV	DX,0			;
	MOV	CX,0			;
	MOV	AX,1			; 1=none.
	RET
BBVALUE_GET_STR:
	MOV	DX,0			;
	MOV	CX,0			;
	MOV	AX,2			; 2=strings.
	RET
BBVALUE_GET	ENDP


; *********************************************************
;	文字列から配列添字取出
;	-I/O- ES:SI     : string.
;	-O-   AX        : 0=none,1=memory,2=immidiate,3=error.
;	      DIM_OFST  : dimension offset.
;	      SOUSYMSEGM: segment of source symbol.
;	      SOUSYMOFST: offset of source symbol.
; *********************************************************

BBSTRDIM_GET	PROC	NEAR
	PUSH	TEXTPSEG		; text segment pointer.
	PUSH	TEXTPOFS		; text offset pointer.

	MOV	DIM_OFST,0		; dimension offset.

	MOV	TEXTPSEG,ES		; text segment pointer.
	MOV	TEXTPOFS,SI		; text offset pointer.

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset pointer.

	MOV	AL,ES:[DI]		; get 1 char.
	CMP	AL,MARKDIMI		; [ begin mark.
	JNE	BBSTRDIM_GET_NONE	;

	INC	TEXTPOFS		; text offset pointer.
	INC	DI			;

	MOV	AL,ES:[DI]		; get 1 char.
	CMP	AL,MARKDIMO		; ] end mark.
	JE	BBSTRDIM_GET_NONE2	;

	CALL	BBLKSKP			; ブランクスキップ

	CALL	BBVALUE_GET		; 右辺数値取り出し
	CMP	AX,0			; 0=normal,1=none,2=strings.
	JNE	BBSTRDIM_GET_ERROR	;
	SHL	DX,1			; word pointer -> byte pointer.
	MOV	DIM_OFST,DX		; dimension offset.

	PUSH	CX			;
	CALL	BBLKSKP			; ブランクスキップ
	POP	CX			; 0=memory,1=immidiate.

	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	DI,TEXTPOFS		; text offset pointer.
	MOV	AL,ES:[DI]		; get 1 char.
	CMP	AL,MARKDIMO		; ] end mark.
	JNE	BBSTRDIM_GET_ERROR	;
	INC	TEXTPOFS		; text offset pointer.

	CMP	CX,0			; 0=memory,1=immidiate.
	JE	BBSTRDIM_GET_MEM	;
	JMP	BBSTRDIM_GET_IMM	;

BBSTRDIM_GET_NONE2:
	INC	TEXTPOFS		; text offset pointer.
BBSTRDIM_GET_NONE:
	MOV	AX,0			; 0=none.
	JMP	BBSTRDIM_GET_EXIT	;
BBSTRDIM_GET_MEM:
	MOV	AX,1			; 1=memory.
	JMP	BBSTRDIM_GET_EXIT	;
BBSTRDIM_GET_IMM:
	MOV	AX,2			; 2=immidiate.
	JMP	BBSTRDIM_GET_EXIT	;
BBSTRDIM_GET_ERROR:
	MOV	AX,3			; 3=error.
BBSTRDIM_GET_EXIT:
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	SI,TEXTPOFS		; text offset pointer.
	POP	TEXTPOFS		; text offset pointer.
	POP	TEXTPSEG		; text segment pointer.
	RET
BBSTRDIM_GET	ENDP


; *********************************************************
;	文字列の取り出し
;	-I/O- TEXTPSEG  : text segment pointer.
;	      TEXTPOFS  : text offset pointer.
;	      DS:DI     : 文字列バッファ
;	-O-   DS:[DI]   : 取り出し文字列
;	      AX        : 0=正常,1=文字列が無い
; *********************************************************

BBCMDSTR	PROC	NEAR
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	SI,TEXTPOFS		; text offset pointer.

	MOV	DL,ES:[SI]		;
	INC	SI			; byte pointer.
	CMP	DL,'"'			;
	JE	BBCMDSTR_1		;
	CMP	DL,"'"			;
	JE	BBCMDSTR_2		;
	JMP	BBCMDSTR_ERROR		;

BBCMDSTR_1:				;
	MOV	BL,'"'			; delimiter.(")
	JMP	BBCMDSTR_START		;
BBCMDSTR_2:
	MOV	BL,"'"			; delimiter.(')
BBCMDSTR_START:

	MOV	CX,128			; 文字列長さ
BBCMDSTR_LOOP:
	MOV	DL,ES:[SI]		;
	INC	SI			; byte pointer.
	CMP	DL,BL			; delimiter.
	JE	BBCMDSTR_EXIT		;
	CMP	DL,CHR_CR		; CR
	JE	BBCMDSTR_66		;
	CMP	DL,CHR_LF		; LF
	JE	BBCMDSTR_66		;
	CMP	DL,TAG_NOTCOM		; not compile.
	JE	BBCMDSTR_66		;
	CMP	DL,TAG_COMPILE		; compiled.
	JE	BBCMDSTR_66		;

	MOV	DS:[DI],DL		; put 1 char.
	INC	DI			; byte pointer.

;***
	CALL	BBSJISCHK		; シフトＪＩＳチェック
	CMP	AX,1			; shift jis code.
	JNE	BBCMDSTR_77		;
	MOV	DL,ES:[SI]		;
	INC	SI			; byte pointer.
	MOV	DS:[DI],DL		; put 1 char.
	INC	DI			; byte pointer.
BBCMDSTR_77:
;***
	JMP	BBCMDSTR_LOOP		;

BBCMDSTR_66:
	DEC	SI
BBCMDSTR_EXIT:
	MOV	TEXTPOFS,SI		; text offset pointer.
	MOV	BYTE PTR DS:[DI],EOS	; end of string.

	MOV	AX,0     		; 0=正常
	RET				;
BBCMDSTR_ERROR:
	MOV	AX,1			; 1=文字列が無い
	RET
BBCMDSTR	ENDP


; *********************************************************
;	文字列の取り出し("=無)
;	-I/O- TEXTPSEG  : text segment pointer.
;	      TEXTPOFS  : text offset pointer.
;	      DS:DI     : 文字列バッファ
;	-O-   DS:[DI]   : 取り出し文字列
;	      AX        : 0=正常,1=文字列が無い
; *********************************************************

BBCMDSTRNC	PROC	NEAR
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	SI,TEXTPOFS		; text offset pointer.

	MOV	AL,ES:[SI]		; get 1 char.
	CMP	AL,CHR_SPACE		; space.
	JBE	BBCMDSTRNC_ERROR	;
BBCMDSTRNC_LOOP:
	MOV	AL,ES:[SI]		; get 1 char.
	CMP	AL,CHR_SPACE		; if chr < space then exit.
	JBE	BBCMDSTRNC_EXIT		;

	INC	SI			; byte pointer.

	MOV	DS:[DI],AL		; put 1 char.
	INC	DI			; byte pointer.
	JMP	BBCMDSTRNC_LOOP		;
BBCMDSTRNC_EXIT:
	MOV	TEXTPOFS,SI		; text offset pointer.
	MOV	BYTE PTR DS:[DI],EOS	; end of string.

	MOV	AX,0     		; 0=正常
	RET
BBCMDSTRNC_ERROR:
	MOV	AX,1			; 1=文字列が無い
	RET
BBCMDSTRNC	ENDP


; *********************************************************
;	シフトＪＩＳチェック
;	-I- DX : character code.
;	-O- AX : 0=normal,1=shift jis code.
; *********************************************************

BBSJISCHK	PROC	NEAR
	MOV	AX,0
	CMP	DL,081H
	JB	BBSJISCHK_3
	CMP	DL,09FH
	JNBE	BBSJISCHK_3
	MOV	AX,1		; shift jis code.
	RET
BBSJISCHK_3:
	CMP	DL,0E0H
	JB	BBSJISCHK_8
	CMP	DL,0FCH
	JNBE	BBSJISCHK_8
	MOV	AX,1		; shift jis code.
BBSJISCHK_8:
	RET
BBSJISCHK	ENDP


; *********************************************************
;	文字列－＞数字チェック
;	-I- DS:SI : 文字列
;	    CX    : 文字長さ
;	-O- AX    : 0=正常,1=数字列ではない
;	    DX    : 数値
; *********************************************************

BBNUMBER	PROC	NEAR
	JCXZ	BBNUMBER_NONE		;
	MOV	DX,SI			;

	LODSB				;
	CMP	AL,'+'			;
	JE	BBNUMBER_1		;
	CMP	AL,'-'			;
	JE	BBNUMBER_1		;
	DEC	SI			;
	JMP	BBNUMBER_LOOP		;
BBNUMBER_1:				;
	DEC	CX			;
	JCXZ	BBNUMBER_NONE		;
BBNUMBER_LOOP:				;
	LODSB				; 文字列
	CMP	AL,'0'			; if al<'0' then none.
	JB	BBNUMBER_NONE		;
	CMP	AL,'9'			; if al>'9' then none.
	JNBE	BBNUMBER_NONE		;
	LOOP	BBNUMBER_LOOP		;
	MOV	SI,DX			;
	CALLE	c_STRDEC		; string -> dec.
BBNUMBER_EXIT:
	MOV	AX,0			; 0=正常
	RET
BBNUMBER_NONE:
	MOV	DX,0			;
	MOV	AX,1			; 1=数字列ではない
	RET
BBNUMBER	ENDP


; *********************************************************
;	次の行までスキップ
;	-I/O- TEXTPSEG : text segment pointer.
;	      TEXTPOFS : text offset pointer.
;	-O-   AX       : 0=normal,1=end of text.
;	      NESTINGLVL : nesting level.
; *********************************************************

BBLFSKIP	PROC	NEAR
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	SI,TEXTPOFS		; text offset pointer.
BBLFSKIP_LOOP:
	MOV	DL,ES:[SI]		; DL=character code.
	CMP	DL,CHR_CR		; CR
	JE	BBLFSKIP_LOOP_E		;
	CMP	DL,EOT			; end of text.
	JE	BBLFSKIP_EOT		;
	INC	SI			; テキストカレント
	INC	TEXTPOFS		; text offset pointer.
	JMP	BBLFSKIP_LOOP		;

BBLFSKIP_LOOP_E:
	INC	SI			; テキストカレント
	INC	TEXTPOFS		; text offset pointer.

	MOV	DL,ES:[SI]		; DL=character code.
	CMP	DL,CHR_LF		; LF
	JE	BBLFSKIP_6		;
	CMP	DL,TAG_NOTCOM		; not compile.
	JE	BBLFSKIP_6		;
	CMP	DL,TAG_COMPILE		; compiled.
	JE	BBLFSKIP_6		;
	JMP	BBLFSKIP_7		;
BBLFSKIP_6:				;
	INC	SI			; テキストカレント
	INC	TEXTPOFS		; text offset pointer.
BBLFSKIP_7:				;
	CALL	BBLKLNSKP		; ブランク行スキップ
	CMP	AX,1			; 0=normal,1=end of text.
	JE	BBLFSKIP_EOT		;
	CALL	BBNOWNEST		; 現在行のネスティングレベル
BBLFSKIP_EXIT:				;
	MOV	AX,0			; 0=normal.
	RET
BBLFSKIP_EOT:				;
	MOV	AX,1			; 1=end of text.
	RET
BBLFSKIP	ENDP


; *********************************************************
;	ブランク行スキップ
;	(行の先頭のブランクもスキップ)
;	-I/O- TEXTPSEG : text segment pointer.
;	      TEXTPOFS : text offset pointer.
;	-O-   AX       : 0=normal,1=end of text.
;	      NESTINGLVL : nesting level.
; *********************************************************

BBLKLNSKP	PROC	NEAR
	MOV	ES,TEXTPSEG		; text segment pointer.
	MOV	SI,TEXTPOFS		; text offset pointer.
BBLKLNSKP_LOOP:
	MOV	DL,ES:[SI]		; DL=character code.

	CMP	DL,EOT			; end of text.
	JE	BBLKLNSKP_EOT		;

	CMP	DL,CHR_SPACE		; space.
	JE	BBLKLNSKP_NEXT		;

	CMP	DL,CHR_TAB		; TAB
	JE	BBLKLNSKP_NEXT		;

	CMP	DL,CHR_CR		; CR
	JE	BBLKLNSKP_NEXT		;

	CMP	DL,CHR_LF		; LF
	JE	BBLKLNSKP_NEXT2		;
	CMP	DL,TAG_NOTCOM		; not compile.
	JE	BBLKLNSKP_NEXT2		;
	CMP	DL,TAG_COMPILE		; compiled.
	JE	BBLKLNSKP_NEXT2		;

	JMP	BBLKLNSKP_EXIT		;

BBLKLNSKP_NEXT:				;
	INC	SI			; テキストカレント
	JMP	BBLKLNSKP_LOOP		;

BBLKLNSKP_NEXT2:			;
	INC	SI			; テキストカレント
	MOV	TEXTPOFS,SI		; text offset pointer.
	PUSH	ES			;
	PUSH	SI			;
	CALL	BBNOWNEST		; 現在行のネストレベル
	POP	SI			;
	POP	ES			;
	JMP	BBLKLNSKP_LOOP		;

BBLKLNSKP_EXIT:
	MOV	AX,0			; 0=normal.
	RET
BBLKLNSKP_EOT:
	MOV	AX,1			; 1=end of text.
	RET
BBLKLNSKP	ENDP


; *********************************************************
;	現在行のネストレベル
;	-I- TEXTPSEG   : text segment pointer.
;	    TEXTPOFS   : text offset pointer.
;	-O- NESTINGLVL : nesting level.
; *********************************************************

BBNOWNEST	PROC	NEAR
	MOV	ES,TEXTPSEG			; text segment pointer.
	MOV	DI,TEXTPOFS			; text offset pointer.

	MOV	NESTINGLVL,0			; nesting level.

	MOV	CX,256				;
BBNOWNEST_LOOP:					;
	MOV	AL,ES:[DI]			;
	INC	DI				;
	CMP	AL,CHR_TAB			; TAB
	JNE	BBNOWNEST_LOOP_E		;
	INC	NESTINGLVL			; nesting level.
	LOOP	BBNOWNEST_LOOP			;
BBNOWNEST_LOOP_E:				;
	RET
BBNOWNEST	ENDP

CODE	ENDS

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

; *********************************************************
;	シフトＪＩＳチェック
;	-I- DX : character code.
;	-O- AX : 0=normal,1=shift jis code.
; *********************************************************

SJISCHK	PROC	NEAR
	MOV	AX,0
	CMP	DL,081H
	JB	SJISCHK_3
	CMP	DL,09FH
	JNBE	SJISCHK_3
	MOV	AX,1		; shift jis code.
	RET
SJISCHK_3:
	CMP	DL,0E0H
	JB	SJISCHK_8
	CMP	DL,0FCH
	JNBE	SJISCHK_8
	MOV	AX,1		; shift jis code.
SJISCHK_8:
	RET
SJISCHK	ENDP

CODE01	ENDS

; *********************************************************
;	data.
; *********************************************************

DATA	SEGMENT	PUBLIC	'DATA'

CMDWRD	DB	8 DUP (0),0,0		; 取り出し単語

DATA	ENDS

	END
;
;	end of "BBASYS.ASM"
;
