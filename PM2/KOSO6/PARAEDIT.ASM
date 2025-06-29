; "PARAEDIT.ASM" 486/50 make by R.H 1992/06/30
;
;
;	パラメータ編集.
;
;
; public subroutine.

INCLUDE	TSTSET.INC

STRING_LEN 	EQU	255	; string length.

BBERROR	MACRO	NUM
	MOV	FLAGERROR,NUM	; error flag.
	EXTRN	BBERRORPR:NEAR	; error message.
	CALL	BBERRORPR	; error message.
	ENDM

ST_COPY	MACRO	DEST,SOUR,MAXLENG
	MOV	SI,SOUR
	MOV	DI,DEST
	MOV	CX,MAXLENG
	CALL	STR_COPY
	ENDM

ST_CLR	MACRO	DEST,LENG
	MOV	DI,DEST
	MOV	CX,LENG
	CALL	STR_FILL
	ENDM

EOS		EQU	0	; end of string.
CHR_SPACE	EQU	' '	; space.
CHR_TAB		EQU	09H	; TAB

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	PARA_ITEM_KILL		; アイテム削除
PUBLIC	PARA_ITEM_INST		; アイテム登録
PUBLIC	PARA_ITEM_SRCH		; アイテム検索

; ****************************************************
;	アイテム削除
;	-I- DX : item record.
; ****************************************************

PARA_ITEM_KILL	PROC	NEAR
	CMP	ITEM_MAX,0			; 所有アイテム数
	JNE	PARA_ITEM_KILL_START		;
	RET
PARA_ITEM_KILL_START:
	MOV	N_ITEM_RECORD,DX		; item record.

	MOV	BX,DX				; item record.
	CALL	GET_ATTR			; 種別取りだし
	CMP	AX,4				; 4=up_param
	JE	PARA_ITEM_KILL_DOWN_PARAM	;
	CMP	AX,5				; 5=up_once
	JE	PARA_ITEM_KILL_UP_ONCE		;
	JMP	PARA_ITEM_KILL_2		;
PARA_ITEM_KILL_DOWN_PARAM:
	MOV	DX,N_ITEM_RECORD		; item record.
	CALL	ITM_PROG_DOWN			; item prog down.
	JMP	PARA_ITEM_KILL_2		;
PARA_ITEM_KILL_UP_ONCE:
	MOV	DX,N_ITEM_RECORD		; item record.
	CALL	ITM_PROG_UP			; item prog up.
PARA_ITEM_KILL_2:

	DEC	ITEM_MAX			; 所有アイテム数

	MOV	DX,N_ITEM_RECORD		; item record.

	MOV	CX,ITEM_MAX			; 所有アイテム数
	SUB	CX,DX				; item count - kill itemrecord
	CMP	CX,0				;
	JMPEQ	PARA_ITEM_KILL_EXIT		;

	MOVX	ES,DS				;

	MOV	SI,DX				;
	INC	SI				; + 1
	SHL	SI,1				; word pointer.
	MOV	DI,DX				;
	SHL	DI,1				; word pointer.

	MOV	AX,SI				;
	MOV	BX,DI				;
	MOV	DX,CX				;

	ADD	SI,OFFSET ITEM_ICON		; 所有アイテムＩＣＯＮ番号
	ADD	DI,OFFSET ITEM_ICON		; 所有アイテムＩＣＯＮ番号
	REP	MOVSW				;

	MOV	SI,AX				;
	MOV	DI,BX				;
	MOV	CX,DX				;

	ADD	SI,OFFSET ITEM_GOLD		; 所有アイテム値段
	ADD	DI,OFFSET ITEM_GOLD		; 所有アイテム値段
	REP	MOVSW				;

	MOV	SI,AX				;
	MOV	DI,BX				;
	MOV	CX,DX				;

	ADD	SI,OFFSET ITEM_ATTR		; 所有アイテム種別
	ADD	DI,OFFSET ITEM_ATTR		; 所有アイテム種別
	REP	MOVSW				;

	MOV	SI,AX				;
	MOV	DI,BX				;
	MOV	CX,DX				;

	PUSH	SI
	PUSH	DI
	PUSH	CX
	MOV	AX,ITEM_NAME[SI]		; 所有アイテム名前 string
	SUB	AX,ITEM_NAME[DI]		; 所有アイテム名前 string
	MUL	CX				;
	MOV	CX,AX				; 転送長
	MOV	AX,ITEM_NAME[SI]		; 所有アイテム名前 string
	MOV	BX,ITEM_NAME[DI]		; 所有アイテム名前 string
	MOV	SI,AX				;
	MOV	DI,BX				;
	REP	MOVSB				;
	POP	CX
	POP	DI
	POP	SI

	PUSH	SI
	PUSH	DI
	PUSH	CX
	MOV	AX,ITEM_PROG[SI]	; 所有アイテム効果 string
	SUB	AX,ITEM_PROG[DI]	; 所有アイテム効果 string
	MUL	CX			;
	MOV	CX,AX			; 転送長
	MOV	AX,ITEM_PROG[SI]	; 所有アイテム効果 string
	MOV	BX,ITEM_PROG[DI]	; 所有アイテム効果 string
	MOV	SI,AX			;
	MOV	DI,BX			;
	REP	MOVSB			;
	POP	CX
	POP	DI
	POP	SI

	MOV	AX,ITEM_HELP[SI]	; 所有アイテム説明 string
	SUB	AX,ITEM_HELP[DI]	; 所有アイテム説明 string
	MUL	CX			;
	MOV	CX,AX			; 転送長
	MOV	AX,ITEM_HELP[SI]	; 所有アイテム説明 string
	MOV	BX,ITEM_HELP[DI]	; 所有アイテム説明 string
	MOV	SI,AX			;
	MOV	DI,BX			;
	REP	MOVSB			;

	CALL	ITEM_CLEANER		; item cleaner.

PARA_ITEM_KILL_EXIT:
	RET
PARA_ITEM_KILL	ENDP


; ****************************************************
;	アイテム登録
;	-I- AX : finction 1=normal.
;	    BX : ＩＣＯＮ
;	    CX : 値段
;	    DX : 種別
;	    SI : 名前 string
;	    DI : 効果 string
;	    BP : 説明 string
;	-O- AX : 0=normal,1=table over.
; ****************************************************

PARA_ITEM_INST	PROC	NEAR
	CMPX	ITEM_MAX,ITEM_DIM		; 所有最大アイテム数
	JNB	PARA_ITEM_INST_OVER		;

	MOV	IT_NAME,SI			; 名前 string
	MOV	IT_PROG,DI			; 効果 string
	MOV	IT_HELP,BP			; 説明 string

	MOV	SI,ITEM_MAX			; 所有アイテム数
	SHL	SI,1				; word pointer.
	MOV	ITEM_ICON[SI],BX		; ＩＣＯＮ
	MOV	ITEM_GOLD[SI],CX		; 値段
	MOV	ITEM_ATTR[SI],DX		; 種別
	MOV	BX,SI				;
	ST_COPY ITEM_NAME[BX],IT_NAME,ITEM_NAME_LEN	; 装備　名前
	ST_COPY	ITEM_PROG[BX],IT_PROG,ITEM_PROG_LEN	; 装備　効果
	ST_COPY	ITEM_HELP[BX],IT_HELP,ITEM_HELP_LEN	; 装備　説明 string

	INC	ITEM_MAX			; 所有アイテム数

	MOV	BX,ITEM_MAX			; item record.
	DEC	BX				; -1
	CALL	GET_ATTR			; 種別取りだし
	CMP	AX,4				; item attribute 4=up_param
	JNE	PARA_ITEM_INST_8		;
	MOV	DX,ITEM_MAX			; item record.
	DEC	DX				; -1
	CALL	ITM_PROG_UP			; item prog up.
PARA_ITEM_INST_8:
	MOV	AX,0				; 0=normal.
	RET
PARA_ITEM_INST_OVER:
	MOV	AX,1				; 1=table over.
	RET
PARA_ITEM_INST	ENDP


; ****************************************************
;	アイテム検索
;	-I- AX : function.
;	1=ICON number search.
;		-i- BX : ICON number.
;		-o- AX : 0=none,1=search.
;		    DX : item record.
;	2=ICON next search.
;		-o- AX : 0=none,1=search.
;		    DX : item record.
;	3=attribute get.
;		-i- BX : item record.
;		-o- AX : item attribute 0=normal,1=equip,2=arms,3=dress,4=up_param
;					5=up_once.
;		    DX : item equipment.0=normal,1=now equip
;	4=equip set.
;		-i- BX : item record.
;	5=equip clear.
;		-i- BX : item attribute 0=normal,1=equip,2=arms,3=dress,4=up_param
;					5=up_once.
;	6=equipment chenge.(equip,arms,dress)
;		-i- BX : item record.
; ****************************************************

PARA_ITEM_SRCH	PROC	NEAR
	CMP	AL,1			; 1=ICON number search.
	JE	PARA_ITEM_SRCH_F01	;
	CMP	AL,2			; 2=ICON next search.
	JE	PARA_ITEM_SRCH_F02	;
	CMP	AL,3			; 3=attribute get.
	JE	PARA_ITEM_SRCH_F03	;
	CMP	AL,4			; 4=equip set.
	JE	PARA_ITEM_SRCH_F04	;
	CMP	AL,5			; 5=equip clear.
	JE	PARA_ITEM_SRCH_F05	;
	CMP	AL,6			; 6=equipment chenge.(equip,arms,dress)
	JE	PARA_ITEM_SRCH_F06	;
	RET
PARA_ITEM_SRCH_F01:
PARA_ITEM_SRCH_F02:
	CALL	ICON_SRCH_SRCH		; アイテム検索
	RET
PARA_ITEM_SRCH_F03:
	CALL	GET_ATTR		; 種別取りだし
	MOV	DX,BX
	RET
PARA_ITEM_SRCH_F05:
	CALL	SOUBI_CLEAR		; 装備はずす
	RET
PARA_ITEM_SRCH_F04:
PARA_ITEM_SRCH_F06:
	CALL	SOUBI_CHANGE		; 装備切り替え
	RET
PARA_ITEM_SRCH	ENDP


; ****************************************************
;	アイテム検索
;	-I- AX : function.
;		1=ICON number search.
;		2=ICON next search.
;	    BX : ICON number.
;	-O- AX : 0=none,1=search.
;	    DX : item record.
; ****************************************************

ICON_SRCH_SRCH	PROC	NEAR
	MOV	ITM_NUM,BX			; item number.

	CMP	ITEM_MAX,0			; 所有アイテム数
	JNE	ICON_SRCH_SRCH_START		;
	JMP	ICON_SRCH_SRCH_NONE		;
ICON_SRCH_SRCH_START:				;

	CMP	AX,1				; 1=ICON number search.
	JE	ICON_SRCH_SRCH_F01		;
	CMP	AX,2				; 2=ICON next search.
	JE	ICON_SRCH_SRCH_F02		;
	JMP	ICON_SRCH_SRCH_NONE		;

ICON_SRCH_SRCH_F01:
	MOVX	ES,DS				;
	MOV	DI,OFFSET ITEM_ICON		; 所有アイテムＩＣＯＮ番号
	MOV	CX,ITEM_MAX			; 所有アイテム数
	MOV	ICON_SCH_CURRENT,DI		; ICON search current.
	MOV	ICON_SCH_COUNT,CX		; ICON search count.
	MOV	AX,ITM_NUM			; item number.
	REPNE	SCASW				;
	JNE	ICON_SRCH_SRCH_NONE		;
	MOV	ICON_SCH_CURRENT,DI		; ICON search current.
	MOV	ICON_SCH_COUNT,CX		; ICON search count.
	INC	CX				; + 1
	MOV	DX,ITEM_MAX			; 所有アイテム数
	SUB	DX,CX				; DX = search record.
	JMP	ICON_SRCH_SRCH_OK		;

ICON_SRCH_SRCH_F02:
	MOVX	ES,DS				;
	MOV	DI,ICON_SCH_CURRENT		; ICON search current.
	MOV	CX,ICON_SCH_COUNT		; ICON search count.
	MOV	AX,ITM_NUM			; item number.
	JCXZ	ICON_SRCH_SRCH_NONE		;
	REPNE	SCASW				;
	JNE	ICON_SRCH_SRCH_NONE		;
	MOV	ICON_SCH_CURRENT,DI		; ICON search current.
	MOV	ICON_SCH_COUNT,CX		; ICON search count.
	INC	CX				; + 1
	MOV	DX,ITEM_MAX			; 所有アイテム数
	SUB	DX,CX				; DX = search record.
	JMP	ICON_SRCH_SRCH_OK		;

ICON_SRCH_SRCH_NONE:
	MOV	DX,0				; item record.
	MOV	AX,0				; 0=none.
	RET
ICON_SRCH_SRCH_OK:
	MOV	AX,1				; 1=search.
	RET
ICON_SRCH_SRCH	ENDP


; ****************************************************
;	装備はずす
;	-I- BX : item attribute 0=normal,1=equip,2=arms,3=dress,4=up_param
; ****************************************************

SOUBI_CLEAR	PROC	NEAR
	MOV	IT_ATTRB,BX		; item attribute.
	CALL	EQUIP_CLEAR		; 装備クリア

	MOV	AX,IT_ATTRB		; 0=通常,1=装備,2=武器,3=服
	CMP	AX,1			; 1=装備
	JE	SOUBI_CLEAR_EQUIP	;
	CMP	AX,2			; 2=武器
	JE	SOUBI_CLEAR_ARMS	;
	CMP	AX,3			; 3=服
	JE	SOUBI_CLEAR_DRESS	;
	RET
SOUBI_CLEAR_EQUIP:
	MOV	SI,EQUIP_PROG			; 装備　効果
	CALL	STR_PROG_DOWN			; string prog down.
	MOV	EQUIP_ICON,0			; 装備　ＩＣＯＮ番号
	MOV	EQUIP_GOLD,0			; 装備　値段
	ST_CLR	EQUIP_NAME,ITEM_NAME_LEN	; 装備　名前
	ST_CLR	EQUIP_PROG,ITEM_PROG_LEN	; 装備　効果
	ST_CLR	EQUIP_HELP,ITEM_HELP_LEN	; 装備　説明 string
	RET
SOUBI_CLEAR_ARMS:
	MOV	SI,ARMS_PROG			; 武器　効果
	CALL	STR_PROG_DOWN			; string prog down.
	MOV	ARMS_ICON,0			; 武器　ＩＣＯＮ番号
	MOV	ARMS_GOLD,0			; 武器　値段
	ST_CLR	ARMS_NAME,ITEM_NAME_LEN		; 武器　名前
	ST_CLR	ARMS_PROG,ITEM_PROG_LEN		; 武器　効果
	ST_CLR	ARMS_HELP,ITEM_HELP_LEN		; 武器　説明 string
	RET
SOUBI_CLEAR_DRESS:
	MOV	SI,DRESS_PROG			; 服　効果
	CALL	STR_PROG_DOWN			; string prog down.
	MOV	DRESS_ICON,0			; 服　ＩＣＯＮ番号
	MOV	DRESS_GOLD,0			; 服　値段
	ST_CLR	DRESS_NAME,ITEM_NAME_LEN	; 服　名前
	ST_CLR	DRESS_PROG,ITEM_PROG_LEN	; 服　効果
	ST_CLR	DRESS_HELP,ITEM_HELP_LEN	; 着衣　説明 string
	MOV	DRESS_NUM,0			; 着衣絵番号
	RET
SOUBI_CLEAR	ENDP


; ****************************************************
;	装備切り替え
;	-I- BX : item record.
; ****************************************************

SOUBI_CHANGE	PROC	NEAR
	CMP	BX,ITEM_MAX		; 所有アイテム数
	JB	SOUBI_CHANGE_START	;
SOUBI_CHANGE_START:			;
	MOV	IT_REC,BX		; item record.

	CALL	GET_ATTR		; 種別取りだし
	MOV	IT_ATTRB,AX		; item attribute.
	MOV	IT_EQUIP,BX		; item equipment.

	MOV	BX,IT_ATTRB		; item attribute.
	CALL	EQUIP_CLEAR		; 装備クリア

	MOV	BX,IT_REC		; item record.
	CALL	EQUIP_SET		; 装備セット

	MOV	AX,IT_ATTRB		; 0=通常,1=装備,2=武器,3=服
	CMP	AX,1			; 1=装備
	JE	SOUBI_CHANGE_EQUIP	;
	CMP	AX,2			; 2=武器
	JE	SOUBI_CHANGE_ARMS	;
	CMP	AX,3			; 3=服
	JE	SOUBI_CHANGE_DRESS	;
	RET

SOUBI_CHANGE_EQUIP:
	MOV	SI,EQUIP_PROG			; 装備　効果
	CALL	STR_PROG_DOWN			; string prog down.

	MOV	BX,IT_REC			; item record.
	SHL	BX,1				;
	MOVX	EQUIP_ICON,ITEM_ICON[BX]	; 装備　ＩＣＯＮ番号
	MOVX	EQUIP_GOLD,ITEM_GOLD[BX]	; 装備　値段
	ST_COPY EQUIP_NAME,ITEM_NAME[BX],ITEM_NAME_LEN	; 装備　名前
	ST_COPY	EQUIP_PROG,ITEM_PROG[BX],ITEM_PROG_LEN	; 装備　効果
	ST_COPY	EQUIP_HELP,ITEM_HELP[BX],ITEM_HELP_LEN	; 装備　説明 string

	MOV	SI,EQUIP_PROG			; 装備　効果
	CALL	STR_PROG_UP			; string prog up.
	RET
SOUBI_CHANGE_ARMS:
	MOV	SI,ARMS_PROG			; 武器　効果
	CALL	STR_PROG_DOWN			; string prog down.

	MOV	BX,IT_REC			; item record.
	SHL	BX,1				;
	MOVX	ARMS_ICON,ITEM_ICON[BX]		; 武器　ＩＣＯＮ番号
	MOVX	ARMS_GOLD,ITEM_GOLD[BX]		; 武器　値段
	ST_COPY ARMS_NAME,ITEM_NAME[BX],ITEM_NAME_LEN	; 武器　名前
	ST_COPY	ARMS_PROG,ITEM_PROG[BX],ITEM_PROG_LEN	; 武器　効果
	ST_COPY	ARMS_HELP,ITEM_HELP[BX],ITEM_HELP_LEN	; 武器　説明 string

	MOV	SI,ARMS_PROG			; 武器　効果
	CALL	STR_PROG_UP			; string prog up.
	RET
SOUBI_CHANGE_DRESS:
	MOV	SI,DRESS_PROG			; 服　効果
	CALL	STR_PROG_DOWN			; string prog down.

	MOV	BX,IT_REC			; item record.
	SHL	BX,1				;
	MOVX	DRESS_ICON,ITEM_ICON[BX]	; 服　ＩＣＯＮ番号
	MOVX	DRESS_GOLD,ITEM_GOLD[BX]	; 服　値段
	ST_COPY DRESS_NAME,ITEM_NAME[BX],ITEM_NAME_LEN	; 服　名前
	ST_COPY	DRESS_PROG,ITEM_PROG[BX],ITEM_PROG_LEN	; 服　効果
	ST_COPY	DRESS_HELP,ITEM_HELP[BX],ITEM_HELP_LEN	; 着衣　説明 string

	MOV	SI,DRESS_PROG			; 服　効果
	CALL	STR_PROG_UP			; string prog up.

	MOV	AX,DRESS_ICON			; 着衣　ＩＣＯＮ番号
	SUB	AX,42				; - 42
	MOV	DRESS_NUM,AX			; 着衣絵番号
	RET
	;ICONnumber		DRESSnumber
	;43=普段着		;1=服・普段着
	;44=夏物の服		;2=服・夏物の服
	;45=冬物の服		;3=服・冬物の服
	;46=木綿のドレス	;4=服・木綿のドレス
	;47=シルクのドレス	;5=服・シルクのドレス
	;48=レザーのドレス	;6=服・レーザーのドレス
	;49=トゲトゲの服	;7=服・トゲトゲの服
	;50=傾国のローブ	;8=服・傾国のローブ
	;51=見えないドレス	;9=服・見えないドレス
	;52=悪魔のドレス	;10=服・悪魔のドレス
	;53=龍のレオタード	;11=服・龍のレオタード
SOUBI_CHANGE	ENDP


; ****************************************************
;	種別取りだし
;
;	所有アイテム種別 (ITEM_ATTR)
;	0=通常,1000番台=装備,2000番台=武器,3000番台=服,4000番台=効能有
;	5000番台=効能一回
;	1の位 0=通常,1=装備中
;
;	-I- BX : item record.
;	-O- AX : item attribute 0=normal,1=equip,2=arms,3=dress,4=up_param
;				5=up_once.
;	    BX : item equipment.0=normal,1=now equip
; ****************************************************

GET_ATTR	PROC	NEAR
	CMP	BX,ITEM_MAX		; 所有アイテム数
	JB	GET_ATTR_START		;
	MOV	AX,0
	MOV	DX,0
	RET
GET_ATTR_START:
	SHL	BX,1			; word pointer.
	MOV	DX,ITEM_ATTR[BX]	; 所有アイテム種別
	CMP	DX,1000			; 0=通常,1000番台=装備,2000番台=武器
	JB	GET_ATTR_61		;
	CMP	DX,2000			;
	JB	GET_ATTR_62		;
	CMP	DX,3000			;
	JB	GET_ATTR_63		;
	CMP	DX,4000			;
	JB	GET_ATTR_64		;
	CMP	DX,5000			;
	JB	GET_ATTR_65		;
	CMP	DX,6000			;
	JB	GET_ATTR_66		;
GET_ATTR_61:
	MOV	AX,0			; item attribute 0=normal
	JMP	GET_ATTR_68		;
GET_ATTR_62:
	MOV	AX,1			; item attribute 1=equip
	SUB	DX,1000			; - 1000
	JMP	GET_ATTR_68		;
GET_ATTR_63:
	MOV	AX,2			; item attribute 2=arms
	SUB	DX,2000			; - 2000
	JMP	GET_ATTR_68		;
GET_ATTR_64:
	MOV	AX,3			; item attribute 3=dress
	SUB	DX,3000			; - 3000
	JMP	GET_ATTR_68		;
GET_ATTR_65:
	MOV	AX,4			; item attribute 4=up_param
	SUB	DX,4000			; - 4000
	JMP	GET_ATTR_68		;
GET_ATTR_66:
	MOV	AX,5			; item attribute 5=up_once
	SUB	DX,5000			; - 5000
	JMP	GET_ATTR_68		;
GET_ATTR_68:

	TEST	DX,1			; 1=now equip.
	JNZ	GET_ATTR_72		;
	MOV	BX,0			; item equipment 0=normal
	JMP	GET_ATTR_78		;
GET_ATTR_72:
	MOV	BX,1			; item equipment 1=now equip
GET_ATTR_78:
	RET
GET_ATTR	ENDP


; ****************************************************
;	装備セット
;	-I- BX : item record.
; ****************************************************

EQUIP_SET	PROC	NEAR
	CMP	BX,ITEM_MAX		; 所有アイテム数
	JB	EQUIP_SET_START		;
	RET
EQUIP_SET_START:
	SHL	BX,1			; word pointer.
	OR	ITEM_ATTR[BX],1		; 1=now equip
	RET
EQUIP_SET	ENDP


; ****************************************************
;	装備クリア
;	-I- BX : item attribute 0=normal,1=equip,2=arms,3=dress
;
;	0=通常,1000番台=装備,2000番台=武器,3000番台=服
;	1の位 0=通常,1=装備中
; ****************************************************

EQUIP_CLEAR	PROC	NEAR
	CMP	BX,3
	JBE	EQUIP_CLEAR_START
	RET
EQUIP_CLEAR_START:
	SHL	BX,1			; word pointer.
	MOV	DX,TBLATTR1000[BX]	; attribute base1000.
	MOV	BX,DX			;
	ADD	BX,1000			;

	MOV	SI,OFFSET ITEM_ATTR	; 所有アイテム種別
	MOV	CX,ITEM_MAX		; 所有アイテム数
EQUIP_CLEAR_LOOP:			;
	MOV	AX,DS:[SI]		;
	CMP	AX,DX			; if 1000 <= ax < 2000
	JB	EQUIP_CLEAR_NEXT	;
	CMP	AX,BX			;
	JNB	EQUIP_CLEAR_NEXT	;
	AND	WORD PTR DS:[SI],0FFFEH	;    bit:0 clear.
EQUIP_CLEAR_NEXT:			;
	INC	SI			;
	INC	SI			;
	LOOP	EQUIP_CLEAR_LOOP	;
	RET
EQUIP_CLEAR	ENDP


; ****************************************************
;	item cleaner.
; ****************************************************

ITEM_CLEANER	PROC	NEAR
	MOV	CX,ITEM_DIM		; 所有最大アイテム数
	SUB	CX,ITEM_MAX		; 所有アイテム数
	JZ	ITEM_CLEANER_EXIT	;

	MOV	DI,ITEM_MAX		; 所有アイテム数
	SHL	DI,1			; word pointer.

	MOV	AX,OFFSET ITEM_ICON	; 所有アイテムＩＣＯＮ番号
	CALL	WORD_FILL		; word fill.

	MOV	AX,OFFSET ITEM_GOLD	; 所有アイテム値段
	CALL	WORD_FILL		; word fill.

	MOV	AX,OFFSET ITEM_ATTR	; 所有アイテム種別
	CALL	WORD_FILL		; word fill.

	MOV	DI,ITEM_NAME		; 所有アイテム名前 string
	MOV	CX,ITEM_NAME_LEN	; アイテム名前長さ
	CALL	STRING_AREA_FILL	; string area fill.

	MOV	DI,ITEM_PROG		; 所有アイテム効果 string
	MOV	CX,ITEM_PROG_LEN	; アイテム効果長さ
	CALL	STRING_AREA_FILL	; string area fill.

	MOV	DI,ITEM_HELP		; 所有アイテム説明 string
	MOV	CX,ITEM_HELP_LEN	; アイテム説明長さ
	CALL	STRING_AREA_FILL	; string area fill.

ITEM_CLEANER_EXIT:
	RET
ITEM_CLEANER	ENDP


; ****************************************************
;	string copy.
;	-I- SI : source.
;	    DI : dest.
;	    CX : max length.
; ****************************************************

STR_COPY	PROC	NEAR
	PUSH	BX
	MOVX	ES,DS
	CALLE	STRSETZ			; 文字列バッファセット
	POP	BX
	RET
STR_COPY	ENDP


; ****************************************************
;	string fill.
;	-I- DI : offset.
;	    CX : counter.
; ****************************************************

STR_FILL	PROC	NEAR
	PUSH	DI
	PUSH	CX
	MOVX	ES,DS
	MOV	AL,0
	REP	STOSB
	POP	CX
	POP	DI
	RET
STR_FILL	ENDP


; ****************************************************
;	word fill.
;	-I- AX : table.
;	    DI : offset.
;	    CX : word counter.
; ****************************************************

WORD_FILL	PROC	NEAR
	PUSH	DI
	PUSH	CX
	ADD	DI,AX
	MOVX	ES,DS
	MOV	AX,0
	REP	STOSW
	POP	CX
	POP	DI
	RET
WORD_FILL	ENDP


; ****************************************************
;	string area fill.
;	-I- DI : address.
;	    CX : 文字長さ
; ****************************************************

STRING_AREA_FILL	PROC	NEAR
	PUSH	DI
	PUSH	CX

	MOV	AX,CX			; 文字長さ
	MOV	BX,ITEM_MAX		; * 所有アイテム数
	MUL	BX			;
	ADD	DI,AX			;

	MOV	AX,CX			; 文字長さ
	MOV	BX,ITEM_DIM		; 所有最大アイテム数
	SUB	BX,ITEM_MAX		; 所有アイテム数
	MUL	BX			;
	MOV	CX,AX			;

	MOVX	ES,DS
	MOV	AL,0
	REP	STOSB

	POP	CX
	POP	DI
	RET
STRING_AREA_FILL	ENDP


; ****************************************************
;	item prog up.
;	-I- DX : item record.
; ****************************************************

ITM_PROG_UP	PROC	NEAR
	PUSH	DX
	MOV	BX,DX				;
	SHL	BX,1				; word pointer.
	MOV	SI,ITEM_PROG[BX]		; 所有アイテム効果 string
	CALL	FAR PTR FAR_PROG_CHECK		; item prog check.
	POP	DX
	RET
ITM_PROG_UP	ENDP


; ****************************************************
;	item prog down.
;	-I- DX : item record.
; ****************************************************

ITM_PROG_DOWN	PROC	NEAR
	PUSH	DX
	MOV	BX,DX				;
	SHL	BX,1				; word pointer.
	MOV	SI,ITEM_PROG[BX]		; 所有アイテム効果 string
	MOV	OPERA_MODE,1			; operation mode.1=reverse.
	CALL	FAR PTR FAR_PROG_CHECK		; item prog check.
	MOV	OPERA_MODE,0			; operation mode.1=reverse.
	POP	DX
	RET
ITM_PROG_DOWN	ENDP


; ****************************************************
;	string prog up.
;	-I- SI : 所有アイテム効果 string
; ****************************************************

STR_PROG_UP	PROC	NEAR
	CALL	FAR PTR FAR_PROG_CHECK		; item prog check.
	RET
STR_PROG_UP	ENDP


; ****************************************************
;	string prog down.
;	-I- SI : 所有アイテム効果 string
; ****************************************************

STR_PROG_DOWN	PROC	NEAR
	MOV	OPERA_MODE,1			; operation mode.1=reverse.
	CALL	FAR PTR FAR_PROG_CHECK		; item prog check.
	MOV	OPERA_MODE,0			; operation mode.1=reverse.
	RET
STR_PROG_DOWN	ENDP

CODE01	ENDS


CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:DATA

; ****************************************************
;	item prog check.
;	-I- SI : program string.
; ****************************************************

FAR_PROG_CHECK	PROC	FAR
	PUSH	SI
	CALL	PROG_CHECK		; prog check.
	POP	SI
	CMP	AX,0			; 0=normal,1=error.
	JNE	FAR_PROG_CHECK_ERROR	;
	RET
FAR_PROG_CHECK_ERROR:
	BBERROR	127			;'ITEM_PROG' error : SI
	RET
FAR_PROG_CHECK	ENDP


; ****************************************************
;	item prog check.
;	-I- SI : program string.
;	-O- AX : 0=normal,1=error.
; ****************************************************

PROG_CHECK	PROC	NEAR
	MOV	PROG_PNT,SI		; program string.
PROG_CHECK_LOOP:
	CALL	SKIP_SPC		; skip space.
	MOV	SI,PROG_PNT		; program string.
	LODSB				;
	CMP	AL,EOS			;
	JE	PROG_CHECK_EXIT		;

	MOVX	ES,DS			;
	MOV	SI,PROG_PNT		; program string.
	MOV	DI,STRSYMBOL		; symbol string.
	MOV	CX,STRSYMMAX		; symbol max length.
	CALLE	BBSTRSYMBGET		; 文字列からシンボル取得

	MOV	STRSYMLEN,BP		; text offset pointer.
	ADD	PROG_PNT,BP		; program string.

	CALLE	BBSOUSYM_SCH		; source symbol table search.
	CMP	AX,0			; 0=search,1=none.
	JNE	PROG_CHECK_ERROR	;

	CALL	SKIP_SPC		; skip space.

	MOV	SI,PROG_PNT		; program string.
	MOV	AL,DS:[SI]		;
	MOV	OPERA,AL		; operation.
	INC	PROG_PNT		; program string.

	CALL	SKIP_SPC		; skip space.
	CALL	VALUE_GET		; value get.

	MOV	AL,OPERA		; operation.
	CMP	AL,'!'			;
	JE	PROG_CHECK_FLAG		;
	CMP	AL,'+'			;
	JE	PROG_CHECK_PLUS		;
	CMP	AL,'-'			;
	JE	PROG_CHECK_MINUS	;
	CMP	AL,'='			;
	JE	PROG_CHECK_EQU		;
	JMP	PROG_CHECK_ERROR	;

PROG_CHECK_FLAG:
	CMP	OPERA_MODE,1		; 1=reverse.
	JE	PROG_CHECK_OFF		;
	JMP	PROG_CHECK_ON		;
PROG_CHECK_PLUS:
	CMP	OPERA_MODE,1		; 1=reverse.
	JE	PROG_CHECK_SUB		;
	JMP	PROG_CHECK_ADD		;
PROG_CHECK_MINUS:
	CMP	OPERA_MODE,1		; 1=reverse.
	JE	PROG_CHECK_ADD		;
	JMP	PROG_CHECK_SUB		;
PROG_CHECK_ADD:
	MOV	DI,SOUSYMOFST		; offset of source symbol.
	MOV	ES,SOUSYMSEGM		; segment of source symbol.
	ADD	ES:[DI],DX		;
	JMP	PROG_CHECK_NEXT		;
PROG_CHECK_SUB:
	MOV	DI,SOUSYMOFST		; offset of source symbol.
	MOV	ES,SOUSYMSEGM		; segment of source symbol.
	SUB	ES:[DI],DX		;
	JNB	PROG_CHECK_SUB2		;
	MOV	WORD PTR ES:[DI],0	;
PROG_CHECK_SUB2:
	JMP	PROG_CHECK_NEXT
PROG_CHECK_ON:
	MOV	DI,SOUSYMOFST		; offset of source symbol.
	MOV	ES,SOUSYMSEGM		; segment of source symbol.
	MOV	WORD PTR ES:[DI],1	;
	JMP	PROG_CHECK_NEXT
PROG_CHECK_OFF:
	MOV	DI,SOUSYMOFST		; offset of source symbol.
	MOV	ES,SOUSYMSEGM		; segment of source symbol.
	MOV	WORD PTR ES:[DI],0	;
	JMP	PROG_CHECK_NEXT		;
PROG_CHECK_EQU:
	MOV	DI,SOUSYMOFST		; offset of source symbol.
	MOV	ES,SOUSYMSEGM		; segment of source symbol.
	MOV	ES:[DI],DX		;
	JMP	PROG_CHECK_NEXT		;

PROG_CHECK_NEXT:
	JMP	PROG_CHECK_LOOP

PROG_CHECK_EXIT:
	MOV	AX,0			; 0=normal.
	RET
PROG_CHECK_ERROR:
	MOV	AX,1			; 1=error.
	RET
PROG_CHECK	ENDP


; ****************************************************
;	skip space.
;	-I/O- PROG_PNT : program string.
; ****************************************************

SKIP_SPC	PROC	NEAR
	MOV	SI,PROG_PNT		; program string.
SKIP_SPC_LOOP:
	LODSB
	CMP	AL,CHR_SPACE
	JE	SKIP_SPC_LOOP
	CMP	AL,CHR_TAB
	JE	SKIP_SPC_LOOP
	DEC	SI
	MOV	PROG_PNT,SI		; program string.
	RET
SKIP_SPC	ENDP


; ****************************************************
;	value get.
;	-I/O- PROG_PNT : program string.
;	-O-   DX : value.
; ****************************************************

VALUE_GET	PROC	NEAR
	MOVX	ES,DS			;
	MOV	SI,PROG_PNT		; program string.
	MOV	DI,OFFSET STR_BUFF	; 文字列バッファ
	MOV	CX,STRING_LEN 		; string length.
	CALLE	BBSTRSYMBGET		; 文字列からシンボル取得
	ADD	PROG_PNT,BP		; program string.
	MOV	SI,OFFSET STR_BUFF	; 文字列バッファ
	CALLE	c_STRDEC		; string -> dec.
	RET
VALUE_GET	ENDP

CODE	ENDS



DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	ITEM_MAX:WORD			; 所有アイテム数
EXTRN	ITEM_DIM:WORD			; 所有最大アイテム数
EXTRN	ITEM_ICON:WORD			; 所有アイテムＩＣＯＮ番号
EXTRN	ITEM_GOLD:WORD			; 所有アイテム値段
EXTRN	ITEM_ATTR:WORD			; 所有アイテム種別
EXTRN	ITEM_NAME:WORD			; 所有アイテム名前 string
EXTRN	ITEM_PROG:WORD			; 所有アイテム効果 string
EXTRN	ITEM_HELP:WORD			; 所有アイテム説明 string

EXTRN	DRESS_NUM:WORD			; 着衣絵番号

EXTRN	DRESS_ICON:WORD			; 着衣　ＩＣＯＮ番号
EXTRN	DRESS_GOLD:WORD			; 着衣　値段
EXTRN	DRESS_NAME:WORD			; 着衣　名前 string
EXTRN	DRESS_PROG:WORD			; 着衣　効果 string
EXTRN	DRESS_HELP:WORD			; 着衣　説明 string

EXTRN	EQUIP_ICON:WORD			; 装備　ＩＣＯＮ番号
EXTRN	EQUIP_GOLD:WORD			; 装備　値段
EXTRN	EQUIP_NAME:WORD			; 装備　名前
EXTRN	EQUIP_PROG:WORD			; 装備　効果
EXTRN	EQUIP_HELP:WORD			; 装備　説明 string

EXTRN	ARMS_ICON:WORD			; 武器　ＩＣＯＮ番号
EXTRN	ARMS_GOLD:WORD			; 武器　値段
EXTRN	ARMS_NAME:WORD			; 武器　名前
EXTRN	ARMS_PROG:WORD			; 武器　効果
EXTRN	ARMS_HELP:WORD			; 武器　説明 string

EXTRN	ITEM_NAME_LEN:WORD		; アイテム名前長さ
EXTRN	ITEM_PROG_LEN:WORD		; アイテム効果長さ
EXTRN	ITEM_HELP_LEN:WORD		; アイテム説明長さ

EXTRN	STRSYMLEN:WORD			; symbol length.
EXTRN	STRSYMMAX:WORD			; symbol max length.
EXTRN	STRSYMBOL:WORD			; symbol string.

EXTRN	SOUSYMOFST:WORD			; offset of source symbol.
EXTRN	SOUSYMSEGM:WORD			; segment of source symbol.

EXTRN	STR_BUFF:BYTE			; 文字列バッファ

EXTRN	FLAGERROR:WORD			; error flag.

N_ITEM_RECORD		DW	0	; item record.

ITM_NUM			DW	0	; item number.

ICON_SCH_CURRENT	DW	0	; ICON search current.
ICON_SCH_COUNT		DW	0	; ICON search count.

TBLATTR1000	DW	0,1000,2000,3000,4000,5000	; attribute base1000.

IT_REC			DW	0	; item record.
IT_ATTRB		DW	0	; item attribute.
IT_EQUIP		DW	0	; item equipment.

IT_NAME			DW	0	; 名前 string
IT_PROG			DW	0	; 効果 string
IT_HELP			DW	0	; 説明 string

PROG_PNT		DW	0	; program string.
OPERA_MODE		DW	0	; operation mode.0=normal,1=reverse.
OPERA			DB	0,0	; operation.

DATA	ENDS

	END
;
;	end of "PARAEDIT.ASM"
;
