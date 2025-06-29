; "VIEWMAP.ASM" 486/50 make by R.H 1992/07/20
;
;
;	マップ表示
;
;
;	bank0:BG chip.
;	bank1:BG chip.
;	bank2:BG chip.
;	bank3:BG anime chip.
;	bank4:mask chip.
;	bank5:char chip.
;		chip 0-47:char.
;		chip 48-95:char.
;	bank6:BG chip.
;	bank7:none.
;
;
;	work buffer.
;			      reload.
;SEG PARTBUF	32700		*	; #0 通常パターンバッファ
;SEG PLESS	32700		*	; #1 pless/unpless segment.
;SEG TEXTBUF	32700		*	; #2 text buffer.
;SEG PARTBUF	32700+16390	*	; #3 通常パターンバッファ
;SEG PLESS	32700+16390	 	; #4 pless/unpless segment.
;SEG TEXTBUF	32700+16390	*	; #5 text buffer.
;SEG VVVRAM	32700 - 16390	*	; #6 varturl vram.
;SEG VVVRAM	32700		*	; #7 varturl vram.
;SEG PROCWRK	51200		*	; #8 process work buffer 52k.
;
;
; public subroutine.

INCLUDE	TSTSET.INC

VGA_WAIT	MACRO
		ENDM
IF 0
VGA_WAIT	MACRO
	LOCAL	L1,L2
	PUSH	DX
L1:
	JMP	$+2
	JMP	$+2
	MOV	DX,03BAH
	IN	AL,DX
	TEST	AL,1B
	JNZ	L1
L2:
	JMP	$+2
	JMP	$+2
	MOV	DX,03BAH
	IN	AL,DX
	TEST	AL,1B
	JZ	L2
	POP	DX
	ENDM
ENDIF

MFLAG_PCAT	EQU	1		; PC/AT
MFLAG_PC98	EQU	2		; PC9801

VIEW_LOC_X	EQU	8		; view locate x.
VIEW_LOC_Y	EQU	8		; view locate y.
VIEW_SIZE_X	EQU	28		; view size x.
VIEW_SIZE_Y	EQU	24		; view size y.

GIRL_MIN_X	EQU	4		; girl min x.
GIRL_MIN_Y	EQU	4		; girl min y.
GIRL_MAX_X	EQU	20		; girl max x.
GIRL_MAX_Y	EQU	16		; girl max y.

GIRL_MIN2_X	EQU	0		; girl min2 x.
GIRL_MIN2_Y	EQU	0		; girl min2 y.
GIRL_MAX2_X	EQU	26		; girl max2 x.
GIRL_MAX2_Y	EQU	21		; girl max2 y.

GIRL_HIGHT	EQU	3		; girl hight.

DIR_AJAST_LENG	EQU	12		; direction adjast length.

BANK_NUM_ANIME_CIP	EQU	3	; anime chip bank.
BANK_NUM_MASK_CIP	EQU	4	; mask chip bank.
BANK_NUM_GIRL_CIP	EQU	5	; girl chip bank.

MASK_CHP1_OFST	EQU	32*16*4*4	; mask chip offset.
CHAR_MASK_CHP_OFST EQU	32*16*4*3	; char mask chip offset.
CHAR_MASK2EF_OFST EQU	32*16*4		; char mask chip effect offset.

TIME_MAP_MOVE	EQU	7;4;8		; map move time.
TIME_MAP_SHIFT	EQU	7		; map shift time.
TIME_ANIME1	EQU	7;4		; anime 1 time.
TIME_ANIME2	EQU	7;4		; anime 2 time.(walking)
TIME_ANIME3	EQU	4		; anime 3 time.(from hole)
TIME_FALLS_ANM	EQU	7;4		; map falls anime time.

FL_MAP_LEN	EQU	51200		; map file length.
FL_ATTR_LEN	EQU	25600		; attribute file length.
FL_BANK_LEN	EQU	16384		; bank file length.

VRAM_ADJUST	EQU	00		; vram adjust.
VRAM_BANK_FLD	EQU	00000111B	; vram bank feild.
VRAM_BANK_MASK	EQU	11111000B	; vram bank mask.
VRAM_BANK_SEGA	EQU	0FFF8H		; vram bank mask.

OUTVGAW	MACRO	NUM,AA
;same;	OUT	NUM,AX
	PUSH	DX
	MOV	DX,NUM			;
	EXTRN	OUT_VGA_WPORT:NEAR	; out port word VGA.
	CALL	OUT_VGA_WPORT		; out port word VGA.
	POP	DX
	ENDM


CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	MAP_LOAD		; map load.
PUBLIC	MAP_RELOAD		; map reload load.
PUBLIC	MAP_MAP_RELOAD		; map map reload.
PUBLIC	MAP_STRAT		; map start.
PUBLIC	MAP_MOVE		; map move.
PUBLIC	MAP_IN_SLCT		; map in select.
PUBLIC	MAP_SHIFT		; map shift.
PUBLIC	MAP_EFC_SET		; map effect set.
PUBLIC	MAP_REDRAW		; map redraw.
PUBLIC	MAP_RPG_MODE		; map RPG mode.
PUBLIC	MAP_NORMAL_MODE		; map normal mode.
PUBLIC	MAP_SETING		; map setting.
PUBLIC	MAP_SET_GIRL_DIR	; map set girl direction.
PUBLIC	MAP_GET_GIRL_DIR	; map get girl direction.
PUBLIC	MAP_CAMP		; map camp.
PUBLIC	MAP_EDITION		; map edition.
PUBLIC	MAP_SYUGO_SET		; map syugo set.

EXTRN	MAIN_FUNCTION_INTER:NEAR	; main function inter.
EXTRN	CHK_EVENT50N:NEAR		; event.50 拾い物
;*;EXTRN KEYHLT:NEAR			; キーボード機能のＯＮ／ＯＦＦ
EXTRN	TIMER_SET:NEAR			; タイマーセット
EXTRN	TIMER_WAIT:NEAR			; タイマー待ち
EXTRN	TIMER_CHECK:NEAR		; タイマーチェック
EXTRN	TIME_OUT_CHECK:NEAR		; process time out check.
EXTRN	VRAM98CHANGE:NEAR		; 98 vram change.

; ****************************************************
;	map load.
; ****************************************************

MAP_LOAD	PROC	NEAR

	CALL	MAP_RELOAD		; map reload load.

	CMP	MFLAG_MY,MFLAG_PCAT	; PC/AT
	JE	MAP_LOAD_PC		;
MAP_LOAD_98:
	MOV	AX,OFFSET PUT_CHIP	; put chip.
	MOV	BX,OFFSET PUT_BUFFER	; put buffer.
	JMP	MAP_LOAD_SET		;
MAP_LOAD_PC:
	MOV	AX,OFFSET PUT_CHIP_VGA	; put chip.(VGA)
	MOV	BX,OFFSET PUT_BUFFER_VGA ; put buffer.(VGA)
MAP_LOAD_SET:
	MOV	JMP_PUT_CHIP,AX		; put chip.
	MOV	JMP_PUT_BUFFER,BX	; put buffer.

	RET
MAP_LOAD	ENDP


; ****************************************************
;	map reload load.
; ****************************************************

MAP_RELOAD	PROC	NEAR

;SEG PARTBUF	32700			; #0 通常パターンバッファ

	TEST	LD_BNK_SW_FLG,00000001B	; load bank switch flag.
	JZ	MAP_RELOAD_00N		;
	MOVX	ES,DS			;
	MOV	SI,OFFSET FLNM_BANK0	; bank file name.
	MOV	DX,BUF_BANK_SEG[0]	; bank buffer segment.
	MOV	DI,BUF_BANK_OFS[0]	; bank buffer offset.
	MOV	CX,FL_BANK_LEN		; bank file length.
	MOV	BX,1			; file load.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
MAP_RELOAD_00N:

;SEG PLESS	32700		*	; #1 pless/unpless segment.

	TEST	LD_BNK_SW_FLG,00000010B	; load bank switch flag.
	JZ	MAP_RELOAD_01N		;
	MOVX	ES,DS			;
	MOV	SI,OFFSET FLNM_BANK1	; bank file name.
	MOV	DX,BUF_BANK_SEG[2]	; bank buffer segment.
	MOV	DI,BUF_BANK_OFS[2]	; bank buffer offset.
	MOV	CX,FL_BANK_LEN		; bank file length.
	MOV	BX,1			; file load.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
MAP_RELOAD_01N:

;SEG TEXTBUF	32700			; #2 text buffer.

	TEST	LD_BNK_SW_FLG,00000100B	; load bank switch flag.
	JZ	MAP_LOAD_02N		;
	MOVX	ES,DS			;
	MOV	SI,OFFSET FLNM_BANK2	; bank file name.
	MOV	DX,BUF_BANK_SEG[4]	; bank buffer segment.
	MOV	DI,BUF_BANK_OFS[4]	; bank buffer offset.
	MOV	CX,FL_BANK_LEN		; bank file length.
	MOV	BX,1			; file load.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
MAP_LOAD_02N:

;SEG PARTBUF	32700+16390		; #3 通常パターンバッファ

	TEST	LD_BNK_SW_FLG,00001000B	; load bank switch flag.
	JZ	MAP_RELOAD_03N		;
	MOVX	ES,DS			;
	MOV	SI,OFFSET FLNM_BANK3	; bank file name.
	MOV	DX,BUF_BANK_SEG[6]	; bank buffer segment.
	MOV	DI,BUF_BANK_OFS[6]	; bank buffer offset.
	MOV	CX,FL_BANK_LEN		; bank file length.
	MOV	BX,1			; file load.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
MAP_RELOAD_03N:

;SEG PLESS	32700+16390		; #4 pless/unpless segment.

	TEST	LD_BNK_SW_FLG,00010000B	; load bank switch flag.
	JZ	MAP_RELOAD_04N		;

	MOVX	ES,DS			;
	MOV	SI,OFFSET FLNM_BANK4	; bank file name.
	MOV	DX,BUF_BANK_SEG[8]	; bank buffer segment.
	MOV	DI,BUF_BANK_OFS[8]	; bank buffer offset.
	MOV	CX,FL_BANK_LEN		; bank file length.
	MOV	BX,1			; file load.
	CALL	MAIN_FUNCTION_INTER	; main function inter.

MAP_RELOAD_04N:

;SEG TEXTBUF	32700+16390		; #5 text buffer.

	TEST	LD_BNK_SW_FLG,00100000B	; load bank switch flag.
	JZ	MAP_LOAD_05N		;

	MOVX	ES,DS			;
	MOV	SI,OFFSET FLNM_BANK5	; bank file name.
	CMP	NOW_WALK_MODE,1		; now walk mode.1=camp.
	JNE	MAP_RELOAD_CAMP		;
	MOV	SI,OFFSET FLNM_BANK5_CAMP ; "camp" bank file name.
MAP_RELOAD_CAMP:
	MOV	DX,BUF_BANK_SEG[10]	; bank buffer segment.
	MOV	DI,BUF_BANK_OFS[10]	; bank buffer offset.
	MOV	CX,FL_BANK_LEN		; bank file length.
	MOV	BX,1			; file load.
	CALL	MAIN_FUNCTION_INTER	; main function inter.

MAP_LOAD_05N:

;SEG VVVRAM	32700 - 16390		; #6 varturl vram.

	TEST	LD_BNK_SW_FLG,01000000B	; load bank switch flag.
	JZ	MAP_RELOAD_06N		;
	MOVX	ES,DS			;
	MOV	SI,OFFSET FLNM_BANK6	; bank file name.
	MOV	DX,BUF_BANK_SEG[12]	; bank buffer segment.
	MOV	DI,BUF_BANK_OFS[12]	; bank buffer offset.
	MOV	CX,FL_BANK_LEN		; bank file length.
	MOV	BX,1			; file load.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
MAP_RELOAD_06N:

;SEG VVVRAM	32700		*	; #7 varturl vram.

	MOVX	ES,DS			;
	MOV	SI,OFFSET FLNM_ATTR	; attribute file name.
	MOV	DX,BUF_ATTR_SEG		; attribute buffer segment.
	MOV	DI,BUF_ATTR_OFS		; attribute buffer offset.
	MOV	CX,FL_ATTR_LEN		; attribute file length.
	MOV	BX,1			; file load.
	CALL	MAIN_FUNCTION_INTER	; main function inter.

	CALL	MAP_MAP_RELOAD		; map map reload.

	RET
MAP_RELOAD	ENDP


; ****************************************************
;	map map reload.
; ****************************************************

MAP_MAP_RELOAD	PROC	NEAR

;SEG PROCWRK	51200		*	; #8 process work buffer 52k.

	MOVX	ES,DS			;
	MOV	SI,OFFSET FLNM_MAP	; map file name.
	MOV	DX,BUF_MAP_SEG		; map buffer segment.
	MOV	DI,BUF_MAP_OFS		; map buffer offset.
	MOV	CX,FL_MAP_LEN		; map file length.
	MOV	BX,1			; file load.
	CALL	MAIN_FUNCTION_INTER	; main function inter.

	CALL	MAP_EDITER		; map editer.

	MOV	DI,OFFSET NOW_VIEW_TBL1	; now view table address.
	CALL	VIEWTBL_CLEAR		; view table clear.

	MOV	DI,OFFSET NOW_VIEW_TBL2	; now view table.
	CALL	VIEWTBL_CLEAR		; view table clear.

	RET
MAP_MAP_RELOAD	ENDP


; ****************************************************
;	map start.
; ****************************************************

MAP_STRAT	PROC	NEAR
;*;	CALL	VRAM98START		; 98 vram & table change start.

	MOV	MOUSE_DIR_X,0		; mouse direction x.
	MOV	MOUSE_DIR_Y,0		; mouse direction y.

	MOV	AX,MAP_SIZE_X		; map size x.
	MOV	BX,MAP_SIZE_Y		; map size y.
	SUB	AX,VIEW_SIZE_X		; view size x.
	SUB	BX,VIEW_SIZE_Y		; view size y.
	MOV	MAP_LOCMAX_X,AX		; map location max x.
	MOV	MAP_LOCMAX_Y,BX		; map location max y.

	MOV	AX,MAP_LOC_X		; map location x.
	MOV	BX,MAP_LOC_Y		; map location y.
	MOV	MAP_LOC_OLD_X,AX	; map location old x.
	MOV	MAP_LOC_OLD_Y,BX	; map location old y.

	MOV	AX,GIRL_LOC_X		; girl location x.
	MOV	BX,GIRL_LOC_Y		; girl location y.
	MOV	GIRL_LOC_OLD_X,AX	; girl location old x.
	MOV	GIRL_LOC_OLD_Y,BX	; girl location old y.

	MOVX	ES,DS			;
	MOV	DI,OFFSET NOW_VIEW_TBL1	; now view table.
	MOV	AX,-1			;
	MOV	CX,VIEW_SIZE_X*VIEW_SIZE_Y*2 ; now view table.
	REP	STOSW			;

	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JNE	MAP_STRAT_8		;
	MOVX	ES,DS			;
	MOV	DI,OFFSET NOW_VIEW_TBL2	; now view table.(PC98/vram2)
	MOV	AX,-1			;
	MOV	CX,VIEW_SIZE_X*VIEW_SIZE_Y*2 ; now view table.
	REP	STOSW			;
MAP_STRAT_8:				;
	MOV	AX,0			; map move time.
	CALL	TIMER_SET		; タイマーセット
	RET
MAP_STRAT	ENDP


; ****************************************************
;	map move.
;	-O- AX : girl dir 0=front,1=back,2=left,3=right.
;	    BX : grand level.
;	    CH : orginal dir x.
;	    CL : orginal dir y.
;	    EXIT_STATUS : exit status.
;		0=normal.
;		1=place ivent.
;		2=timeout.
;		3=camp.
;		4=event50.
; ****************************************************

MAP_MOVE	PROC	NEAR
	CALL	VRAM98START		; 98 vram & table change start.

	MOV	WALKING_CNT,0		; walking counter.

MAP_MOVE_LOOP:
	MOV	MOUSE_DIR_X,0		; x direction step.
	MOV	MOUSE_DIR_Y,0		; y direction step.

	CMP	VRAM98FLAG,0		; 98 vram flag.
	JNE	MAP_MOVE_MOUSE		;

	CALL	TIME_OUT_CHECK		; process time out check.
	CMP	BX,1			; 1=timer end.
	JE	MAP_MOVE_TIME_OUT	;

	CMP	WALKING_CNT,80		; walking counter.<===============
	JB	MAP_MOVE_MOUSE		;８０歩移動ごとに判定．

	MOV	WALKING_CNT,0		; walking counter.

	CALL	CHK_EVENT50N		; event.50 拾い物
	CMP	AX,1			; 0=無し,1=あり
	JE	MAP_MOVE_EVE50		; 4=event50.

MAP_MOVE_MOUSE:				;
	MOV	BX,16			; ＲＰＧ方向選択・ｳｲﾝﾄﾞｳREAD
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	CMP	BX,5			; ボタン選択番号 5:ｷｬﾝﾌﾟ
	JE	MAP_MOVE_CAMP		;

	MOV	ORGINAL_D_X,CX		; orginal dir x.
	MOV	ORGINAL_D_Y,DX		; orginal dir y.

	ADD	MOUSE_DIR_X,CX		; x direction step.
	ADD	MOUSE_DIR_Y,DX		; y direction step.

	CALL	TIMER_CHECK		; タイマーチェック
	CMP	BX,0			; 0=timer now, 1=timer end.
	JE	MAP_MOVE_MOUSE		;


	CMP	MOUSE_DIR_X,0		; x direction step.
	JE	MAP_MOVE_33		;
	JL	MAP_MOVE_31		;
	MOV	MOUSE_DIR_X,1		; x direction step.
	JMP	MAP_MOVE_33		;
MAP_MOVE_31:				;
	MOV	MOUSE_DIR_X,-1		; x direction step.
MAP_MOVE_33:

	CMP	MOUSE_DIR_Y,0		; y direction step.
	JE	MAP_MOVE_36		;
	JL	MAP_MOVE_34		;
	MOV	MOUSE_DIR_Y,1		; x direction step.
	JMP	MAP_MOVE_36		;
MAP_MOVE_34:				;
	MOV	MOUSE_DIR_Y,-1		; x direction step.
MAP_MOVE_36:

	MOV	AX,TIME_MAP_MOVE	; map move time.
	CALL	TIMER_SET		; タイマーセット

	CALL	DIR_AJAST		; direction adjast.

	MOV	AX,MOUSE_DIR_X		; mouse direction x.
	CMP	AX,0			;
	JE	MAP_MOVE_4		;
	MOV	MOUSE_LASTDIR_X,AX	; mouse last direction x.
MAP_MOVE_4:
	MOV	BX,MOUSE_DIR_Y		; mouse direction y.
	CMP	BX,0			;
	JE	MAP_MOVE_5		;
	MOV	MOUSE_LASTDIR_Y,BX	; mouse last direction y.
MAP_MOVE_5:

	CALL	MAP_LOC_AJAST		; map location adjast.
	CALL	MAP_LOC_CHECK		; map location check.

	CMP	CHKATTRCODE1,4		; 4:横方向滑走
	JE	MAP_MOVE_3		;

	CMP	CHKATTRCODE1,5		; 5:縦方向滑走
	JE	MAP_MOVE_3		;

MAP_MOVE_2:
	CALL	VRAM98CHG		; 98 vram & table change.
	CALL	VIEW_DRAW		; view draw.
	JMP	MAP_MOVE_7		;
MAP_MOVE_3:
	CALL	VRAM98CHG		; 98 vram & table change.
	CALL	VIEW_DRAW		; view draw.
	CALL	VIEW_SLIP		; 滑走
MAP_MOVE_7:

	CALL	CHK_LOC			; check location.
	CMP	AX,1			; 1=same location.
	JE	MAP_MOVE_777		;
	INC	WALKING_CNT		; walking counter.
MAP_MOVE_777:
	CALL	MAP_LOC_SAVE		; map location save.

	CMP	CHKATTRCODE1,7		; 7:イベント
	JE	MAP_MOVE_IVENT		;

	JMP	MAP_MOVE_LOOP

MAP_MOVE_IVENT:
	MOV	EXIT_STATUS,1		; 1=place ivent.
	JMP	MAP_MOVE_EXIT		;
MAP_MOVE_TIME_OUT:
	MOV	EXIT_STATUS,2		; 2=timeout.
	JMP	MAP_MOVE_EXIT		;
MAP_MOVE_CAMP:
	MOV	EXIT_STATUS,3		; 3=camp.
	JMP	MAP_MOVE_EXIT		;
MAP_MOVE_EVE50:
	MOV	EXIT_STATUS,4		; 4=event50.
	JMP	MAP_MOVE_EXIT		;
MAP_MOVE_EXIT:
	MOV	AX,0;TIME_MAP_MOVE	; map move time.
	CALL	VRAM98REDRAW		; 98 vram0 redraw.
	CALL	VRAM98STOP		; 98 vram & table change stop.
	MOV	AX,GIRL_DIR		; girl direction.
	MOV	BX,GRAND_LEVEL		; grand level.
	MOV	CH,BYTE PTR ORGINAL_D_X	; orginal dir x.
	MOV	CL,BYTE PTR ORGINAL_D_Y	; orginal dir y.
	RET
MAP_MOVE	ENDP


; ****************************************************
;	map in select.
;	-I- SI : string buffer.
;	    AX : flag select anime.0=normal,1=girl anime,2=all stop.
;	-O- EXIT_STATUS : ユーザ選択番号
; ****************************************************

MAP_IN_SLCT	PROC	NEAR
	MOV	FLAG_SLCT_ANM,AX	; flag select anime.

	MOVX	ES,DS			;
	MOV	BX,17			; WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG OPEN.
	CALL	MAIN_FUNCTION_INTER	; main function inter.

	CMP	FLAG_SLCT_ANM,2		; flag select anime.
	JE	MAP_IN_SLCT_1		;
	CALL	VRAM98START		; 98 vram & table change start.
MAP_IN_SLCT_1:				;

	MOV	AX,0			; map move time.
	CALL	TIMER_SET		; タイマーセット
MAP_IN_SLCT_LOOP:
	CMP	FLAG_SLCT_ANM,2		; flag select anime.
	JE	MAP_IN_SLCT_MOUSE	;

	CMP	FLAG_SLCT_ANM,0		; flag select anime.
	JE	MAP_IN_SLCT_2		;
	CALL	ANIME_COUNT_REPEAT	; anime count repeat.
MAP_IN_SLCT_2:

	CALL	VRAM98SHOW2WRT		; 98 vram show=write.

MAP_IN_SLCT_MOUSE:			;
	MOV	BX,19			; WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG READ.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	CMP	BX,-2			; ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ／ユーザ選択番号
	JNE	MAP_IN_SLCT_EXIT	; = -2   : 何も入力無し

	CMP	FLAG_SLCT_ANM,2		; flag select anime.
	JE	MAP_IN_SLCT_MOUSE	;

	CALL	TIMER_CHECK		; タイマーチェック
	CMP	BX,0			; 0=timer now, 1=timer end.
	JE	MAP_IN_SLCT_MOUSE	;

	MOV	AX,TIME_MAP_MOVE	; map move time.
	CALL	TIMER_SET		; タイマーセット

	CALL	VRAM98REV		; 98 vram show reverse write.

	MOV	MOUSE_DIR_X,0		; x direction step.
	MOV	MOUSE_DIR_Y,0		; y direction step.

	CALL	VRAM98CHG		; 98 vram & table change.
	CALL	VIEW_DRAW		; view draw.

	MOVX	MAP_LOC_OLD_X,MAP_LOC_X	; map location x.
	MOVX	MAP_LOC_OLD_Y,MAP_LOC_Y	; map location y.
	MOVX	GIRL_LOC_OLD_X,GIRL_LOC_X ; girl location x.
	MOVX	GIRL_LOC_OLD_Y,GIRL_LOC_Y ; girl location y.

	JMP	MAP_IN_SLCT_LOOP

MAP_IN_SLCT_EXIT:
	MOV	EXIT_STATUS,BX		;

	CMP	FLAG_SLCT_ANM,2		; flag select anime.
	JE	MAP_IN_SLCT_99		;

	MOV	AX,TIME_MAP_MOVE	; map move time.
	CALL	VRAM98REDRAW		; 98 vram0 redraw.
	CALL	VRAM98STOP		; 98 vram & table change stop.
MAP_IN_SLCT_99:				;

	MOV	BX,18			; WINDOWS/ｾﾚｸﾄ･ｳｲﾝﾄﾞｳ RPG CLOSE.
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	RET
MAP_IN_SLCT	ENDP


; ****************************************************
;	map shift.
;	-I- PARAM01 : map shift x.
;	    PARAM02 : map shift y.
;	    PARAM03 : girl shift x.
;	    PARAM04 : girl shift y.
;	    PARAM05 : shift count.
; ****************************************************

MAP_SHIFT	PROC	NEAR
	CMP	PARAM05,0		; shift count.
	JE	MAP_SHIFT_EXIT		;

	CALL	VRAM98START		; 98 vram & table change start.

	MOV	MOUSE_DIR_X,0		; mouse direction x.
	MOV	MOUSE_DIR_Y,0		; mouse direction y.

	MOV	CX,PARAM05		; shift count.
MAP_SHIFT_LOOP:				;
	PUSH	CX			;
	MOV	AX,TIME_MAP_SHIFT	; map shift time.
	CALL	TIMER_SET		; タイマーセット
	ADDX	MAP_LOC_X,PARAM01	; map shift x.
	ADDX	MAP_LOC_Y,PARAM02	; map shift y.
	ADDX	GIRL_LOC_X,PARAM03	; girl shift x.
	ADDX	GIRL_LOC_Y,PARAM04	; girl shift y.
	CALL	VRAM98CHG		; 98 vram & table change.
	CALL	VIEW_DRAW		; view draw.
	CALL	TIMER_WAIT		; タイマー待ち
	POP	CX			;
	LOOP	MAP_SHIFT_LOOP		;

	MOV	AX,TIME_MAP_SHIFT	; map shift time.
	CALL	VRAM98REDRAW		; 98 vram0 redraw.
	CALL	VRAM98STOP		; 98 vram & table change stop.
MAP_SHIFT_EXIT:
	RET
MAP_SHIFT	ENDP


; ****************************************************
;	shift to map.
;	-I- AX : shift direction x.
;	    BX : shift direction y.
;	    CX : shift count.
;	    MAP_SFT_PUTMODE : map shift put mode.
;		0=normal,1=BGonly,2=view anime draw,3=view BG anime draw.
;	    GIRL_AN01_TBL : girl anime1 table.
;	    GIRL_AN02_TBL : girl anime2 table.
;	    SFT_LOCCHK_OFF: map location check off.
; ****************************************************

SHIFT_MAPMOV	PROC	NEAR
	MOV	SFT_DIR_XX,AX		; shift direction x.
	MOV	SFT_DIR_YY,BX		; shift direction y.
	MOV	SFT_CNT,CX		; shift count.

	MOV	GIRL_AN_SW,0		; girl anime switch.

	CMP	AX,0			;
	JE	SHIFT_MAPMOV_1		;
	MOV	MOUSE_LASTDIR_X,AX	; mouse last direction x.
SHIFT_MAPMOV_1:

	CMP	BX,0			;
	JE	SHIFT_MAPMOV_2		;
	MOV	MOUSE_LASTDIR_Y,BX	; mouse last direction y.
SHIFT_MAPMOV_2:

;*;	CALL	VRAM98START		; 98 vram & table change start.

SHIFT_MAPMOV_LOOP:
	CMP	SFT_CNT,0		; shift count.
	JE	SHIFT_MAPMOV_EXIT		;

	DEC	SFT_CNT			; shift count.

	MOV	AX,SFT_TIME_MAPS	; map shift time.
	CALL	TIMER_SET		; タイマーセット

	MOV	AX,SFT_DIR_XX		; shift direction x.
	MOV	BX,SFT_DIR_YY		; shift direction y.
	MOV	MOUSE_DIR_X,AX		; mouse direction x.
	MOV	MOUSE_DIR_Y,BX		; mouse direction y.

	CMP	SFT_LOCCHK_OFF,0	; map location check off.
	JNE	SHIFT_MAPMOV_41		;
	CALL	DIR_AJAST		; direction adjast.
SHIFT_MAPMOV_41:				;

	CALL	MAP_LOC_AJAST		; map location adjast.

	CMP	SFT_LOCCHK_OFF,0	; map location check off.
	JNE	SHIFT_MAPMOV_42		;
	CALL	MAP_LOC_CHECK		; map location check.
SHIFT_MAPMOV_42:				;

	CALL	VRAM98CHG		; 98 vram & table change.
	CMP	MAP_SFT_PUTMODE,0	; map shift put mode.
	JE	SHIFT_MAPMOV_50		;
	CMP	MAP_SFT_PUTMODE,1	; map shift put mode.
	JE	SHIFT_MAPMOV_51		;
	CMP	MAP_SFT_PUTMODE,2	; map shift put mode.
	JE	SHIFT_MAPMOV_52		;
	CMP	MAP_SFT_PUTMODE,3	; map shift put mode.
	JE	SHIFT_MAPMOV_53		;
SHIFT_MAPMOV_50:
	CALL	VIEW_DRAW		; view draw.
	JMP	SHIFT_MAPMOV_6		;
SHIFT_MAPMOV_51:
	CALL	VIEW_DRAW_BG		; view draw back graund.
	JMP	SHIFT_MAPMOV_6		;
SHIFT_MAPMOV_52:
	CALL	ANM_TBLCHG		; girl anime table change.
	CALL	VIEW_EFC_DRAW		; view anime draw.
	JMP	SHIFT_MAPMOV_6		;
SHIFT_MAPMOV_53:
	CALL	ANM_TBLCHG		; girl anime table change.
	CALL	VIEW_EFC_BG_DRAW	; view BG anime draw.
	JMP	SHIFT_MAPMOV_6		;
SHIFT_MAPMOV_6:

	CALL	MAP_LOC_SAVE		; map location save.

	CALL	TIMER_WAIT		; タイマー待ち
	JMP	SHIFT_MAPMOV_LOOP		;

SHIFT_MAPMOV_EXIT:
;*;	CALL	VRAM98STOP		; 98 vram & table change stop.
	RET
SHIFT_MAPMOV	ENDP


; ****************************************************
;	girl anime table change.
;	-I-   GIRL_AN01_TBL : girl anime1 table.
;	      GIRL_AN02_TBL : girl anime2 table.
;	-I/O- GIRL_AN_SW    : girl anime switch.
;	-O-   GIRL_AN_TBL   : girl anime table.
; ****************************************************

ANM_TBLCHG	PROC	NEAR
	CMP	GIRL_AN_SW,1			; girl anime switch.
	JE	ANM_TBLCHG_02N			;
ANM_TBLCHG_01N:
	MOV	GIRL_AN_SW,1			; girl anime switch.
	MOV	SI,OFFSET GIRL_AN01_TBL		; girl anime1 table.
	JMP	ANM_TBLCHG_MOV			;
ANM_TBLCHG_02N:
	MOV	GIRL_AN_SW,0			; girl anime switch.
	MOV	SI,OFFSET GIRL_AN02_TBL		; girl anime2 table.
ANM_TBLCHG_MOV:
	MOVX	ES,DS				;
	MOV	DI,OFFSET GIRL_AN_TBL		; girl anime table.
	MOV	CX,6				;
	REP	MOVSW				;
	RET
ANM_TBLCHG	ENDP


; ****************************************************
;	effect set.
;	-I- AX : 1=穴へ,2=穴から,3=沼へ,4=沼から
;		5=キャンプ,6=キャンプたたむ,7=滝
;		8=上へ,9=下へ,10=上から,11=下から,12=落下
;		13=左へ,14=右へ,15=武神から逃げる
; ****************************************************

MAP_EFC_SET	PROC	NEAR
	DEC	AX
	CMP	AX,(JUMP_TBL_MAP_EFC_END-JUMP_TBL_MAP_EFC)/2
	JB	MAP_EFC_SET_START
	RET
MAP_EFC_SET_START:
	PUSH	AX
	CALL	TIMER_WAIT		; タイマー待ち
	POP	AX
	MOV	BP,AX
	SHL	BP,1					; word pointer.
	CALL	WORD PTR DS:JUMP_TBL_MAP_EFC[BP]	; jump label.
	RET
MAP_EFC_SET	ENDP


; ****************************************************
;	map redraw.
;	-I- AX : 1=全部,2=背景のみ
; ****************************************************

MAP_REDRAW	PROC	NEAR
	CMP	AX,2			; 1=全部,2=背景のみ
	JE	MAP_REDRAW_BG		;

MAP_REDRAW_ALL:
	CALL	VIEW_DRAW		; view draw.
	RET
MAP_REDRAW_BG:
	CALL	VIEW_DRAW_BG		; view draw back graund.
	RET
MAP_REDRAW	ENDP


; ****************************************************
;	map RPG mode.
; ****************************************************

MAP_RPG_MODE	PROC	NEAR
;*;	MOV	AX,0			; 0=ＯＦＦ
;*;	CALL	KEYHLT			; キーボード機能のＯＮ／ＯＦＦ
	MOV	BX,14			; ＲＰＧ方向選択・ｳｲﾝﾄﾞｳOPEN
	CALL	MAIN_FUNCTION_INTER	; main function inter.
	RET
MAP_RPG_MODE	ENDP


; ****************************************************
;	map normal mode.
; ****************************************************

MAP_NORMAL_MODE	PROC	NEAR
	MOV	BX,15			; ＲＰＧ方向選択・ｳｲﾝﾄﾞｳCLOSE
	CALL	MAIN_FUNCTION_INTER	; main function inter.
;*;	MOV	AX,1			; 1=ＯＮ
;*;	CALL	KEYHLT			; キーボード機能のＯＮ／ＯＦＦ
	RET
MAP_NORMAL_MODE	ENDP


; ****************************************************
;	map setting.
;	-I- AX : 1=East,2=West,3=South,4=North1,5=North2,6=North3
;	    BX : load bank bit switch.
; ****************************************************

MAP_SETING	PROC	NEAR
	MOV	MAP_DIRECTION,AX		; map direction.
	MOV	LD_BNK_SW_FLG,BX		; load bank switch flag.

	MOV	BX,AX				;
	DEC	BX				; -1
	SHL	BX,1				; word pointer.
	MOV	AX,WORD PTR TBL_MAPDIR[BX]	; map dirname table.

	MOV	WORD PTR FLNM_MAP[3],AX	;"MAPE00.MAP"	;map file name.
	MOV	WORD PTR FLNM_ATTR[3],AX;"MAPE00.ATR"	;attribute file name.
	MOV	WORD PTR FLNM_BANK0[3],AX;"CIPE00.BNK"	;bank file name.
	MOV	WORD PTR FLNM_BANK1[3],AX;"CIPE01.BNK"	;bank file name.
	MOV	WORD PTR FLNM_BANK2[3],AX;"CIPE02.BNK"	;bank file name.
	MOV	WORD PTR FLNM_BANK3[3],AX;"CIPE03.BNK"	;bank file name.
	MOV	WORD PTR FLNM_BANK4[3],AX;"CIPE04.BNK"	;bank file name.
	MOV	WORD PTR FLNM_BANK5[3],AX;"CIPE05.BNK"	;bank file name.
	MOV	WORD PTR FLNM_BANK6[3],AX;"CIPE06.BNK"	;bank file name.
	RET
MAP_SETING	ENDP


; ****************************************************
;	map set girl direction.
;	-I- AX : girl dir 0=front,1=back,2=left,3=right.
; ****************************************************

MAP_SET_GIRL_DIR	PROC	NEAR
	MOV	GIRL_DIR,AX		; girl direction.
	RET
MAP_SET_GIRL_DIR	ENDP


; ****************************************************
;	map get girl direction.
;	-O- AX : girl dir 0=front,1=back,2=left,3=right.
; ****************************************************

MAP_GET_GIRL_DIR	PROC	NEAR
	MOV	AX,GIRL_DIR		; girl direction.
	RET
MAP_GET_GIRL_DIR	ENDP


; ****************************************************
;	map camp.
;	-I- DX : 1=キャンプ張る,2=キャンプをたたむ
; ****************************************************

MAP_CAMP	PROC	NEAR
	CMP	DX,2			; 1=キャンプ張る,2=キャンプをたたむ
	JE	MAP_CAMP_2N		;

MAP_CAMP_1N:
	MOVX	ES,DS			;
	MOV	SI,OFFSET FLNM_BANK5_CAMP ; "camp" bank file name.
	MOV	DX,BUF_BANK_SEG[10]	; bank buffer segment.
	MOV	DI,BUF_BANK_OFS[10]	; bank buffer offset.
	MOV	CX,FL_BANK_LEN		; bank file length.
	MOV	BX,1			; file load.
	CALL	MAIN_FUNCTION_INTER	; main function inter.

	MOVX	BAK_GIRL_DIR,GIRL_DIR	; girl direction.
	MOV	GIRL_DIR,0		; 0=front.
	MOV	NOW_WALK_MODE,1		; now walk mode.1=camp.
	JMP	MAP_CAMP_DRAW		;

MAP_CAMP_2N:
	MOVX	ES,DS			;
	MOV	SI,OFFSET FLNM_BANK5	; bank file name.
	MOV	DX,BUF_BANK_SEG[10]	; bank buffer segment.
	MOV	DI,BUF_BANK_OFS[10]	; bank buffer offset.
	MOV	CX,FL_BANK_LEN		; bank file length.
	MOV	BX,1			; file load.
	CALL	MAIN_FUNCTION_INTER	; main function inter.

	MOVX	GIRL_DIR,BAK_GIRL_DIR	; girl direction.
	MOV	NOW_WALK_MODE,0		; now walk mode.0=walk.

MAP_CAMP_DRAW:
;;;	CALL	VIEW_CHAR_CLR		; view table character clear.
	MOV	DI,OFFSET NOW_VIEW_TBL1	; now view table address.
	CALL	VIEWTBL_CLEAR		; view table clear.
	MOV	DI,OFFSET NOW_VIEW_TBL2	; now view table.
	CALL	VIEWTBL_CLEAR		; view table clear.
	CALL	VRAM98START		; 98 vram & table change start.

	MOV	CX,2			;
MAP_CAMP_LOOP:				;
	PUSH	CX			;
	MOV	AX,TIME_MAP_MOVE	; map move time.
	CALL	TIMER_SET		; タイマーセット
	CALL	VRAM98CHG		; 98 vram & table change.
	CALL	VIEW_DRAW		; view draw.
	CALL	TIMER_WAIT		; タイマー待ち
	POP	CX			;
	LOOP	MAP_CAMP_LOOP		;

	CALL	VRAM98STOP		; 98 vram & table change stop.
	RET
MAP_CAMP	ENDP


; ****************************************************
;	map edition.
;	-I- AX : function.
;		1=西の泉が枯れた
;		2=北の守護星現れる
;		3=北の守護星への階段が消える
;		4=北の武神への階段が消える
;		5=宝箱OPEN.1
;		6=宝箱OPEN.2
;		7=宝箱OPEN.3
;		8=宝箱OPEN.4
;		9=宝箱OPEN.5
;		10=宝箱CLOSE.1
;		11=宝箱CLOSE.2
;		12=宝箱CLOSE.3
;		13=宝箱CLOSE.4
;		14=宝箱CLOSE.5
; ****************************************************

MAP_EDITION	PROC	NEAR
	CMP	AX,10			; 10=宝箱CLOSE.1
	JB	MAP_EDITION_4
	CMP	AX,14			; 14=宝箱CLOSE.5
	JNBE	MAP_EDITION_4

	MOV	BX,AX			; function.
	SUB	BX,5			;
	MOV	TBL_EDIT_FUNC[BX],1	; table map edit function.

	JMP	MAP_EDITION_EDIT	;

MAP_EDITION_4:
	CMP	AX,TBL_EDIT_FUNC_DIM	; table map edit function dim.
	JNB	MAP_EDITION_EXIT	;
	MOV	BX,AX			; function.
	MOV	TBL_EDIT_FUNC[BX],1	; table map edit function.
MAP_EDITION_EDIT:
	CALL	MAP_EDITER		; map editer.
MAP_EDITION_EXIT:
	RET
MAP_EDITION	ENDP


; ****************************************************
;	map syugo set.
;	-I- AX : 守護星
;			0=太陽神ソル
;			1=月神ザ・ムーン
;			2=火星神マーズ
;			3=水星神マーキュリー
;			4=木星神ジュピター
;			5=金星神ビーナス
;			6=土星神サターン
;			7=天王星神ウラヌス
;			8=海王星神ネプチューン
;			9=冥王星神ハーデス
; ****************************************************

MAP_SYUGO_SET	PROC	NEAR
	MOV	SYUGOSEI,AX		; 守護星
	RET
MAP_SYUGO_SET	ENDP


; ****************************************************
;	map editer.
; ****************************************************

MAP_EDITER	PROC	NEAR
	CMP	TBL_EDIT_FUNC[1],0	; 1=西の泉が枯れた
	JE	MAP_EDITER_01		;
	CMP	MAP_DIRECTION,2		; map direction.2=West.
	JNE	MAP_EDITER_01		;
	CALL	MAP_EDIT_WEST_SPRING	; west spring.
MAP_EDITER_01:

	CMP	TBL_EDIT_FUNC[2],0	; 2=北の守護星現れる
	JE	MAP_EDITER_02		;
	CMP	MAP_DIRECTION,6		; map direction.6=North3.
	JNE	MAP_EDITER_02		;
	CALL	MAP_EDIT_STAR		; 守護星
MAP_EDITER_02:

	CMP	TBL_EDIT_FUNC[3],0	; 3=北の守護星への階段が消える
	JE	MAP_EDITER_03		;
	CMP	MAP_DIRECTION,6		; map direction.6=North3.
	JNE	MAP_EDITER_03		;
	CALL	MAP_EDIT_S_STEP		; 北の守護星への階段が消える
MAP_EDITER_03:

	CMP	TBL_EDIT_FUNC[4],0	; 4=北の武神への階段が消える
	JE	MAP_EDITER_04		;
	CMP	MAP_DIRECTION,6		; map direction.6=North3.
	JNE	MAP_EDITER_04		;
	CALL	MAP_EDIT_B_STEP		; 北の武神への階段が消える
MAP_EDITER_04:

	MOV	SI,5
	MOV	CX,5
MAP_EDITER_05_LOOP:
	PUSH	CX
	PUSH	SI

	MOV	AL,TBL_EDIT_FUNC[SI]	; 5...9=宝箱OPEN.1...5
	MOV	FLG_OPEN_CLOSE,AL	; フラグOPEN&CLOSE

	MOV	DI,SI			; 宝箱番号
	SUB	DI,5			; -5
	CALL	MAP_EDIT_TREA_ALL	; 宝箱OPEN

MAP_EDITER_05_NEXT:
	POP	SI
	POP	CX
	INC	SI
	LOOP	MAP_EDITER_05_LOOP

	RET
MAP_EDITER	ENDP


; ****************************************************
;	宝箱OPEN
;	-I- DI : 宝箱番号
;	    FLG_OPEN_CLOSE : フラグOPEN&CLOSE
; ****************************************************

MAP_EDIT_TREA_ALL	PROC	NEAR
	MOV	AX,MAP_DIRECTION		; map direction.
	CMP	AL,1	; 1=East,2=West,3=South,4=North1,5=North2,6=North3
	JE	MAP_EDIT_TREA_ALL_E
	CMP	AL,2
	JE	MAP_EDIT_TREA_ALL_W
	CMP	AL,3
	JE	MAP_EDIT_TREA_ALL_S
	CMP	AL,5	; 5=North2
	JE	MAP_EDIT_TREA_ALL_N
	RET
MAP_EDIT_TREA_ALL_E:
	CALL	MAP_EDIT_E_TREA			; 宝箱OPEN・東マップ
	RET
MAP_EDIT_TREA_ALL_W:
	CALL	MAP_EDIT_W_TREA			; 宝箱OPEN・西マップ
	RET
MAP_EDIT_TREA_ALL_S:
	CALL	MAP_EDIT_S_TREA			; 宝箱OPEN・南マップ
	RET
MAP_EDIT_TREA_ALL_N:
	CALL	MAP_EDIT_N_TREA			; 宝箱OPEN・北マップ
	RET
MAP_EDIT_TREA_ALL	ENDP


; ****************************************************
;	宝箱OPEN・東マップ
;	-I- DI : 宝箱番号
;	    FLG_OPEN_CLOSE : フラグOPEN&CLOSE
; ****************************************************

MAP_EDIT_E_TREA	PROC	NEAR
	CMP	DI,TREA_E_MAX		;宝箱数・東マップ
	JNB	MAP_EDIT_E_TREA_EXIT	;
	SHL	DI,1
	MOV	BX,TREA_E_X[DI]		;宝箱OPEN X座標・東マップ
	MOV	AX,TREA_E_Y[DI]		;宝箱OPEN Y座標・東マップ
	MOV	CX,200			; map width.
	MOV	SI,300H+79H		; chip number.
	CMP	FLG_OPEN_CLOSE,1	; フラグOPEN&CLOSE
	JE	MAP_EDIT_E_TREA_5	;
	MOV	SI,300H+77H		; chip number.
MAP_EDIT_E_TREA_5:
	CALL	MAP_EDIT_TREA		; 宝箱OPEN
MAP_EDIT_E_TREA_EXIT:
	RET
MAP_EDIT_E_TREA	ENDP


; ****************************************************
;	宝箱OPEN・西マップ
;	-I- DI : 宝箱番号
;	    FLG_OPEN_CLOSE : フラグOPEN&CLOSE
; ****************************************************

MAP_EDIT_W_TREA	PROC	NEAR
	CMP	DI,TREA_W_MAX		;宝箱数・西マップ
	JNB	MAP_EDIT_W_TREA_EXIT	;
	SHL	DI,1
	MOV	BX,TREA_W_X[DI]		;宝箱OPEN X座標・西マップ
	MOV	AX,TREA_W_Y[DI]		;宝箱OPEN Y座標・西マップ
	MOV	CX,200			; map width.
	MOV	SI,00H+5CH		; chip number.
	CMP	FLG_OPEN_CLOSE,1	; フラグOPEN&CLOSE
	JE	MAP_EDIT_W_TREA_5	;
	MOV	SI,00H+4CH		; chip number.
MAP_EDIT_W_TREA_5:
	CALL	MAP_EDIT_TREA		; 宝箱OPEN
MAP_EDIT_W_TREA_EXIT:
	RET
MAP_EDIT_W_TREA	ENDP


; ****************************************************
;	宝箱OPEN・南マップ
;	-I- DI : 宝箱番号
;	    FLG_OPEN_CLOSE : フラグOPEN&CLOSE
; ****************************************************

MAP_EDIT_S_TREA	PROC	NEAR
	CMP	DI,TREA_S_MAX		;宝箱数・南マップ
	JNB	MAP_EDIT_S_TREA_EXIT	;
	SHL	DI,1
	MOV	BX,TREA_S_X[DI]		;宝箱OPEN X座標・南マップ
	MOV	AX,TREA_S_Y[DI]		;宝箱OPEN Y座標・南マップ

	MOV	CX,160			; map width.
	MUL	CX			;
	ADD	AX,BX			; offset = ( x + y*width )*2
	SHL	AX,1			;

	MOV	ES,BUF_MAP_SEG		; map buffer segment.
	MOV	DI,BUF_MAP_OFS		; map buffer offset.
	ADD	DI,AX			;

;		bit   FEDCBA.987.6543210
;		      ------ --- -------
;		        |     |     |
;		        |     |     +--- chip(0-127)
;		        |     +--------- bank(0-7)
;		        +--------------- mask chip(0-64)

		;  FEDCBA9876543210
	MOV	DX,0000001111111111B	;

	MOV	AX,0E400H		;E4h =mask 39h  chip number.

	CMP	FLG_OPEN_CLOSE,1	;フラグOPEN&CLOSE
	JE	MAP_EDIT_S_TREA_5	;
	MOV	AX,0DC00H		;DCh =mask 37h  chip number.
MAP_EDIT_S_TREA_5:			;
	AND	ES:[DI],DX		;
	OR	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;

	MOV	AX,0E800H		;E8h =mask 3Ah  chip number.

	CMP	FLG_OPEN_CLOSE,1	;フラグOPEN&CLOSE
	JE	MAP_EDIT_S_TREA_6	;
	MOV	AX,0E000H		;E0h =mask 38h  chip number.
MAP_EDIT_S_TREA_6:			;

	AND	ES:[DI],DX		;
	OR	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;

MAP_EDIT_S_TREA_EXIT:
	RET
MAP_EDIT_S_TREA	ENDP


; ****************************************************
;	宝箱OPEN・北マップ
;	-I- DI : 宝箱番号
;	    FLG_OPEN_CLOSE : フラグOPEN&CLOSE
; ****************************************************

MAP_EDIT_N_TREA	PROC	NEAR
	CMP	DI,TREA_N_MAX		;宝箱数・北マップ
	JNB	MAP_EDIT_N_TREA_EXIT	;
	SHL	DI,1
	MOV	BX,TREA_N_X[DI]		;宝箱OPEN X座標・北マップ
	MOV	AX,TREA_N_Y[DI]		;宝箱OPEN Y座標・北マップ
	MOV	CX,160			; map width.
	MOV	SI,100H+1EH		; chip number.
	CMP	FLG_OPEN_CLOSE,1	; フラグOPEN&CLOSE
	JE	MAP_EDIT_N_TREA_5	;
	MOV	SI,100H+0EH		; chip number.
MAP_EDIT_N_TREA_5:
	CALL	MAP_EDIT_TREA		; 宝箱OPEN
MAP_EDIT_N_TREA_EXIT:
	RET
MAP_EDIT_N_TREA	ENDP


; ****************************************************
;	宝箱OPEN
;	-I- BX : x.
;	    AX : y.
;	    CX : map width.
;	    SI : chip number.
; ****************************************************

MAP_EDIT_TREA	PROC	NEAR
	MUL	CX			;
	ADD	AX,BX			; offset = ( x + y*width )*2
	SHL	AX,1			;

	MOV	ES,BUF_MAP_SEG		; map buffer segment.
	MOV	DI,BUF_MAP_OFS		; map buffer offset.
	ADD	DI,AX			;
	MOV	AX,SI			; chip number.
	STOSW				;
	INC	AX			;
	STOSW				;
	RET
MAP_EDIT_TREA	ENDP


; ****************************************************
;	北の守護星への階段が消える
; ****************************************************

MAP_EDIT_S_STEP	PROC	NEAR
	MOV	ES,BUF_MAP_SEG		; map buffer segment.
	MOV	DI,BUF_MAP_OFS		; map buffer offset.

	ADD	DI,40*2*54 + 17*2	;

	MOV	CX,10
MAP_EDIT_S_STEP_LOOP:
	MOV	AX,1			; black.
	STOSW
	STOSW
	ADD	DI,40*2-4
	LOOP	MAP_EDIT_S_STEP_LOOP


	MOV	ES,BUF_ATTR_SEG		; attribute buffer segment.
	MOV	DI,BUF_ATTR_OFS		; attribute buffer offset.

	ADD	DI,40*54 + 17

	MOV	CX,10
MAP_EDIT_S_STEP_LOOP2:
	MOV	AX,0			; black.
	STOSW
	ADD	DI,40-2
	LOOP	MAP_EDIT_S_STEP_LOOP2

	RET
MAP_EDIT_S_STEP	ENDP


; ****************************************************
;	北の武神への階段が消える
; ****************************************************

MAP_EDIT_B_STEP	PROC	NEAR
	MOV	ES,BUF_ATTR_SEG		; attribute buffer segment.
	MOV	DI,BUF_ATTR_OFS		; attribute buffer offset.

	ADD	DI,40*69 + 16 + 40*6

	MOV	AX,0
	STOSW

	MOV	ES,BUF_MAP_SEG		; map buffer segment.
	MOV	DI,BUF_MAP_OFS		; map buffer offset.

	ADD	DI,40*2*69 +16*2

	MOV	AX,56H
	STOSW
	INC	AX
	STOSW

	ADD	DI,40*2-4

	MOV	AX,66H
	STOSW
	INC	AX
	STOSW

	ADD	DI,40*2-4

	MOV	AX,76H
	STOSW
	INC	AX
	STOSW

	ADD	DI,40*2-4

	MOV	AX,06H + 80H
	STOSW
	INC	AX
	STOSW

	ADD	DI,40*2-4

	MOV	AX,16H + 80H
	STOSW
	INC	AX
	STOSW

	ADD	DI,40*2-4

	MOV	AX,26H + 80H
	STOSW
	INC	AX
	STOSW

	ADD	DI,40*2-4

	MOV	AX,36H + 80H
	STOSW
	INC	AX
	STOSW

	MOV	ES,BUF_MAP_SEG		; map buffer segment.
	MOV	DI,BUF_MAP_OFS		; map buffer offset.

	ADD	DI,40*2*69 + 16*2 + 40*2*6

	MOV	CX,10
MAP_EDIT_B_STEP_LOOP:
	MOV	AX,1			; black.
	STOSW
	STOSW
	ADD	DI,40*2-4
	LOOP	MAP_EDIT_B_STEP_LOOP


	MOV	ES,BUF_ATTR_SEG		; attribute buffer segment.
	MOV	DI,BUF_ATTR_OFS		; attribute buffer offset.

	ADD	DI,40*69 + 16 + 40*6

	MOV	CX,10
MAP_EDIT_B_STEP_LOOP2:
	MOV	AX,0			; black.
	STOSW
	ADD	DI,40-2
	LOOP	MAP_EDIT_B_STEP_LOOP2

	RET
MAP_EDIT_B_STEP	ENDP


; ****************************************************
;	守護星
; ****************************************************

MAP_EDIT_STAR	PROC	NEAR
	MOV	ES,BUF_MAP_SEG		; map buffer segment.
	MOV	DI,BUF_MAP_OFS		; map buffer offset.

	ADD	DI,40*2*18 + 17*2	;

	MOV	BX,SYUGOSEI		; 守護星
	MOV	AL,CHIP_SRT_TBL[BX]	; syugo chip start number.
	MOV	AH,01H			;


	STOSW
	INC	AX
	STOSW

	MOV	BX,0FH
	MOV	CX,40*2-2*2

	ADD	AX,BX
	ADD	DI,CX

	STOSW
	INC	AX
	STOSW

	ADD	AX,BX
	ADD	DI,CX

	STOSW
	INC	AX
	STOSW

	ADD	AX,BX
	ADD	DI,CX

	STOSW
	INC	AX
	STOSW

	RET
MAP_EDIT_STAR	ENDP


; ****************************************************
;	west spring.
; ****************************************************

MAP_EDIT_WEST_SPRING	PROC	NEAR

	MOV	ES,BUF_MAP_SEG		; map buffer segment.
	MOV	DI,BUF_MAP_OFS		; map buffer offset.

;(1)

	ADD	DI,200*2*2 + 10*2
	MOV	AX,180H+75H
	STOSW
	INC	AX
	STOSW

	MOV	AX,180H+79H
	STOSW
	INC	AX
	STOSW

;(2)

	ADD	DI,200*2-(10*2+8)+7*2
	MOV	AX,180H+20H
	STOSW
	INC	AX
	STOSW
	INC	AX
	STOSW

	MOV	AX,180H+27H
	STOSW
	MOV	AX,180H+29H
	STOSW
	MOV	AX,180H+27H
	STOSW
	MOV	AX,180H+29H
	STOSW

	MOV	AX,180H+60H
	STOSW
	INC	AX
	STOSW
	INC	AX
	STOSW
	INC	AX
	STOSW

;(3)

	ADD	DI,200*2-(7*2+22)+7*2
	MOV	AX,180H+30H
	STOSW
	INC	AX
	STOSW
	INC	AX
	STOSW

	MOV	AX,180H+37H
	STOSW
	MOV	AX,180H+2AH
	STOSW
	STOSW
	STOSW

	MOV	AX,180H+70H
	STOSW
	INC	AX
	STOSW
	INC	AX
	STOSW
	INC	AX
	STOSW

	RET
MAP_EDIT_WEST_SPRING	ENDP


; ****************************************************
;	穴へ
; ****************************************************

MAP_EFC_TO_HOLE	PROC	NEAR
	MOV	BX,GIRL_DIR		; girl direction.
	SHL	BX,1			; * 2
	ADD	BX,GIRL_ANIME_NUM	; + girl anime number.
	SHL	BX,1			; * 2
	MOV	AX,GIRL_TBL[BX]		; bank,start pattern.
	MOV	GIRL_AN_PNT,AX		; girl anime pointer.

	MOV	AH,BANK_NUM_GIRL_CIP	; bank.
	MOV	AL,BYTE PTR GIRL_AN_PNT	; girl anime pointer.
	MOV	GIRL_AN_TBL[0],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN_TBL[2],AX	; girl anime table.
	ADD	AL,15			;
	MOV	GIRL_AN_TBL[4],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN_TBL[6],AX	; girl anime table.
	ADD	AL,15			;
	MOV	GIRL_AN_TBL[8],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN_TBL[10],AX	; girl anime table.

	MOV	CX,4			;
MAP_EFC_TO_HOLE_LOOP:			;
	PUSH	CX			;
	MOV	AX,TIME_ANIME1		; anime 1 time.
	CALL	TIMER_SET		; タイマーセット
	CALL	VIEW_EFC_DRAW		; view anime draw.

	MOVX	GIRL_AN_TBL[10],GIRL_AN_TBL[6]	; girl anime table.
	MOVX	GIRL_AN_TBL[8],GIRL_AN_TBL[4]	; girl anime table.
	MOVX	GIRL_AN_TBL[6],GIRL_AN_TBL[2]	; girl anime table.
	MOVX	GIRL_AN_TBL[4],GIRL_AN_TBL[0]	; girl anime table.
	MOV	GIRL_AN_TBL[2],0	;
	MOV	GIRL_AN_TBL[0],0	;

	CALL	TIMER_WAIT		; タイマー待ち
	POP	CX			;
	LOOP	MAP_EFC_TO_HOLE_LOOP	;

MAP_EFC_TO_HOLE_EXIT:
	RET
MAP_EFC_TO_HOLE	ENDP


; ****************************************************
;	穴から
; ****************************************************

MAP_EFC_FROM_HOLE	PROC	NEAR
	MOV	GRAND_LEVEL,0		; grand level.

	MOV	BX,GIRL_DIR		; girl direction.
	SHL	BX,1			; * 2
	ADD	BX,GIRL_ANIME_NUM	; + girl anime number.
	SHL	BX,1			; * 2
	MOV	AX,GIRL_TBL[BX]		; bank,start pattern.
	MOV	GIRL_AN_PNT,AX		; girl anime pointer.

	MOV	AX,0			;
	MOV	GIRL_AN_TBL[0],AX	; girl anime table.
	MOV	GIRL_AN_TBL[2],AX	; girl anime table.
	MOV	GIRL_AN_TBL[4],AX	; girl anime table.
	MOV	GIRL_AN_TBL[6],AX	; girl anime table.
	MOV	GIRL_AN_TBL[8],AX	; girl anime table.
	MOV	GIRL_AN_TBL[10],AX	; girl anime table.

	MOV	BH,BANK_NUM_GIRL_CIP	; bank.
	MOV	BL,BYTE PTR GIRL_AN_PNT	; girl anime pointer.
	MOV	CX,4			;
MAP_EFC_FROM_HOLE_LOOP:			;
	PUSH	CX			;
	PUSH	BX			;

	MOV	AX,TIME_ANIME3		; anime 3 time.(from hole)
	CALL	TIMER_SET		; タイマーセット

	CALL	VIEW_EFC_DRAW		; view anime draw.

	CALL	TIMER_WAIT		; タイマー待ち

	POP	BX			;
	CMP	GIRL_AN_TBL[0],0
	JNE	MAP_EFC_FROM_HOLE_5	;
	MOVX	GIRL_AN_TBL[0],GIRL_AN_TBL[4]	; girl anime table.
	MOVX	GIRL_AN_TBL[2],GIRL_AN_TBL[6]	; girl anime table.
	MOVX	GIRL_AN_TBL[4],GIRL_AN_TBL[8]	; girl anime table.
	MOVX	GIRL_AN_TBL[6],GIRL_AN_TBL[10]	; girl anime table.
	MOV	GIRL_AN_TBL[8],BX	; girl anime table.
	INC	BL			;
	MOV	GIRL_AN_TBL[10],BX	; girl anime table.

MAP_EFC_FROM_HOLE_5:			;
	ADD	BL,15			;
	POP	CX			;
	LOOP	MAP_EFC_FROM_HOLE_LOOP	;

	MOV	CX,4			;
MAP_EFC_FROM_HOLE_LOOP2:		;
	PUSH	CX			;
	MOV	AX,TIME_ANIME3		; anime 3 time.(from hole)
	CALL	TIMER_SET		; タイマーセット

	DEC	GIRL_LOC_Y		; * girl location y.

	CALL	VIEW_EFC_DRAW		; view anime draw.

	CALL	TIMER_WAIT		; タイマー待ち
	POP	CX			;
	LOOP	MAP_EFC_FROM_HOLE_LOOP2	;

	CMP	GIRL_DIR,2		; girl direction.2=left
	JE	MAP_EFC_FROM_HOLE_6	;
	MOV	BX,1			;
	JMP	MAP_EFC_FROM_HOLE_7	;
MAP_EFC_FROM_HOLE_6:			;
	MOV	BX,-1			;
MAP_EFC_FROM_HOLE_7:

	MOV	CX,4			;
MAP_EFC_FROM_HOLE_LOOP3:		;
	PUSH	CX			;
	PUSH	BX			;
	CMP	CX,2			;
	JBE	MAP_EFC_FROM_HOLE_8	;
	ADD	GIRL_LOC_X,BX		; * girl location y.
MAP_EFC_FROM_HOLE_8:			;

	INC	GIRL_LOC_Y		; girl location y.

	MOV	AX,TIME_ANIME3		; anime 3 time.(from hole)
	CALL	TIMER_SET		; タイマーセット

	INC	GIRL_DIR		; girl direction.

	CALL	GIRL_DRAW		; girl draw.

	CALL	TIMER_WAIT		; タイマー待ち
	POP	BX			;
	POP	CX			;
	LOOP	MAP_EFC_FROM_HOLE_LOOP3	;

	CALL	GIRL_SPIN		; girl spin.

MAP_EFC_FROM_HOLE_EXIT:
	RET
MAP_EFC_FROM_HOLE	ENDP


; ****************************************************
;	girl draw.
; ****************************************************

GIRL_DRAW	PROC	NEAR
	CMP	GIRL_DIR,4		;
	JB	GIRL_DRAW_3		;
	MOV	GIRL_DIR,0		;
GIRL_DRAW_3:				;

	MOV	BX,GIRL_DIR		; girl direction.
	SHL	BX,1			; * 2
	ADD	BX,GIRL_ANIME_NUM	; + girl anime number.
	SHL	BX,1			; * 2
	MOV	AX,GIRL_TBL[BX]		; bank,start pattern.
	MOV	GIRL_AN_PNT,AX		; girl anime pointer.
	MOV	AH,BANK_NUM_GIRL_CIP	; bank.
	MOV	AL,BYTE PTR GIRL_AN_PNT	; girl anime pointer.
	MOV	GIRL_AN_TBL[0],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN_TBL[2],AX	; girl anime table.
	ADD	AL,15			;
	MOV	GIRL_AN_TBL[4],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN_TBL[6],AX	; girl anime table.
	ADD	AL,15			;
	MOV	GIRL_AN_TBL[8],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN_TBL[10],AX	; girl anime table.
	CALL	VIEW_EFC_DRAW		; view anime draw.

	RET
GIRL_DRAW	ENDP


; ****************************************************
;	girl spin.
; ****************************************************

GIRL_SPIN	PROC	NEAR
	PUSH	GIRL_DIR		; girl direction.

	MOV	GIRL_ANIME_NUM,1	; + girl anime number.

	MOV	CX,4*5
GIRL_SPIN_LOOP:				;
	PUSH	CX			;
	CMP	CX,8			;
	JB	GIRL_SPIN_01		;
	MOV	AX,2
	JMP	GIRL_SPIN_2		;
GIRL_SPIN_01:				;
	CMP	CX,4			;
	JB	GIRL_SPIN_1		;
	MOV	AX,4			; time.
	JMP	GIRL_SPIN_2		;
GIRL_SPIN_1:				;
	MOV	AX,6			; time.
GIRL_SPIN_2:				;
	CALL	TIMER_SET		; タイマーセット

	INC	GIRL_DIR		; girl direction.

	CALL	GIRL_DRAW		; girl draw.

	CALL	TIMER_WAIT		; タイマー待ち
	POP	CX			;
	LOOP	GIRL_SPIN_LOOP		;

	POP	GIRL_DIR		; girl direction.
	RET
GIRL_SPIN	ENDP


; ****************************************************
;	沼へ
; ****************************************************

MAP_EFC_TO_MARSH	PROC	NEAR
	MOV	BX,GIRL_DIR		; girl direction.
	SHL	BX,1			; * 2
	ADD	BX,GIRL_ANIME_NUM	; + girl anime number.
	SHL	BX,1			; * 2
	MOV	AX,GIRL_TBL[BX]		; bank,start pattern.
	MOV	GIRL_AN_PNT,AX		; girl anime pointer.

	MOV	AH,BANK_NUM_GIRL_CIP	; bank.
	MOV	AL,BYTE PTR GIRL_AN_PNT	; girl anime pointer.
	MOV	GIRL_AN_TBL[0],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN_TBL[2],AX	; girl anime table.
	ADD	AL,15			;
	MOV	GIRL_AN_TBL[4],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN_TBL[6],AX	; girl anime table.
	ADD	AL,15			;
	MOV	GIRL_AN_TBL[8],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN_TBL[10],AX	; girl anime table.

	MOV	CX,5			;
MAP_EFC_TO_MARSH_LOOP:			;
	PUSH	CX			;
	MOV	AX,TIME_ANIME2		; anime 2 time.(walking)
	CALL	TIMER_SET		; タイマーセット

	CMP	GIRL_AN_TBL[10],0	; effect chip.
	JE	MAP_EFC_TO_MARSH_5	;
	OR	GIRL_AN_TBL[8],7000H	; effect chip=14.
	OR	GIRL_AN_TBL[10],7800H	; effect chip=15.
MAP_EFC_TO_MARSH_5:			;
	CALL	VIEW_EFC_DRAW		; view anime draw.

	AND	GIRL_AN_TBL[10],07FFH	; effect chip.
	AND	GIRL_AN_TBL[8],07FFH	; effect chip.

	MOVX	GIRL_AN_TBL[10],GIRL_AN_TBL[6]	; girl anime table.
	MOVX	GIRL_AN_TBL[8],GIRL_AN_TBL[4]	; girl anime table.
	MOVX	GIRL_AN_TBL[6],GIRL_AN_TBL[2]	; girl anime table.
	MOVX	GIRL_AN_TBL[4],GIRL_AN_TBL[0]	; girl anime table.
	MOV	GIRL_AN_TBL[2],0	;
	MOV	GIRL_AN_TBL[0],0	;

	CALL	TIMER_WAIT		; タイマー待ち
	POP	CX			;
	LOOP	MAP_EFC_TO_MARSH_LOOP	;

;		bit   FEDCBA.987.6543210
;		      ------ --- -------
;		        |     |     |
;		        |     |     +--- chip(0-127)
;		        |     +--------- bank(0-7)
;		        +--------------- mask chip(0-64)

	MOV	GIRL_AN_TBL[0],0	; girl anime table.
	MOV	GIRL_AN_TBL[2],0	; girl anime table.
	MOV	GIRL_AN_TBL[4],0180h	; girl anime table.
	MOV	GIRL_AN_TBL[6],01C0H	; girl anime table.
	MOV	GIRL_AN_TBL[8],0	; girl anime table.
	MOV	GIRL_AN_TBL[10],0	; girl anime table.

	MOV	CX,24			;
MAP_EFC_TO_MARSH_LOOP5:			;
	PUSH	CX			;

	MOV	AX,TIME_MAP_MOVE	; map move time.
	CALL	TIMER_SET		; タイマーセット
	CALL	VIEW_EFC_BG_DRAW	; view BG anime draw.
	CALL	TIMER_WAIT		; タイマー待ち

	POP	CX			;
	LOOP	MAP_EFC_TO_MARSH_LOOP5	;

	MOV	GIRL_AN_TBL[4],0	; girl anime table.
	MOV	GIRL_AN_TBL[6],0	; girl anime table.
	CALL	VIEW_EFC_BG_DRAW	; view BG anime draw.

	RET
MAP_EFC_TO_MARSH	ENDP


; ****************************************************
;	沼から
; ****************************************************

MAP_EFC_FROM_MARSH	PROC	NEAR
	MOV	GRAND_LEVEL,-1		; grand level.

	MOV	BX,GIRL_DIR		; girl direction.
	SHL	BX,1			; * 2
	ADD	BX,GIRL_ANIME_NUM	; + girl anime number.
	SHL	BX,1			; * 2
	MOV	AX,GIRL_TBL[BX]		; bank,start pattern.
	MOV	GIRL_AN_PNT,AX		; girl anime pointer.

	MOV	AX,0			;
	MOV	GIRL_AN_TBL[0],AX	; girl anime table.
	MOV	GIRL_AN_TBL[2],AX	; girl anime table.
	MOV	GIRL_AN_TBL[4],AX	; girl anime table.
	MOV	GIRL_AN_TBL[6],AX	; girl anime table.
	MOV	GIRL_AN_TBL[8],AX	; girl anime table.
	MOV	GIRL_AN_TBL[10],AX	; girl anime table.


	MOV	BH,BANK_NUM_GIRL_CIP	; bank.
	MOV	BL,BYTE PTR GIRL_AN_PNT	; girl anime pointer.
	MOV	CX,4			;
MAP_EFC_FROM_MARSH_LOOP:		;
	PUSH	CX			;
	PUSH	BX			;

	MOV	AX,TIME_ANIME1		; anime 1 time.
	CALL	TIMER_SET		; タイマーセット

	CALL	VIEW_EFC_DRAW		; view anime draw.

	CALL	TIMER_WAIT		; タイマー待ち

	POP	BX			;
	CMP	GIRL_AN_TBL[0],0
	JNE	MAP_EFC_FROM_MARSH_5	;

	AND	GIRL_AN_TBL[10],07FFH	; effect chip.
	AND	GIRL_AN_TBL[8],07FFH	; effect chip.

	MOVX	GIRL_AN_TBL[0],GIRL_AN_TBL[4]	; girl anime table.
	MOVX	GIRL_AN_TBL[2],GIRL_AN_TBL[6]	; girl anime table.
	MOVX	GIRL_AN_TBL[4],GIRL_AN_TBL[8]	; girl anime table.
	MOVX	GIRL_AN_TBL[6],GIRL_AN_TBL[10]	; girl anime table.
	MOV	GIRL_AN_TBL[8],BX	; girl anime table.
	INC	BL			;
	MOV	GIRL_AN_TBL[10],BX	; girl anime table.

	CMP	GIRL_AN_TBL[10],0	; effect chip.
	JE	MAP_EFC_FROM_MARSH_5	;
	OR	GIRL_AN_TBL[8],7000H	; effect chip=14.
	OR	GIRL_AN_TBL[10],7800H	; effect chip=15.

MAP_EFC_FROM_MARSH_5:			;
	ADD	BL,15			;
	POP	CX			;
	LOOP	MAP_EFC_FROM_MARSH_LOOP	;
	RET
MAP_EFC_FROM_MARSH	ENDP


; ****************************************************
;	キャンプ
; ****************************************************

MAP_EFC_OPEN_CAMP	PROC	NEAR
	RET
MAP_EFC_OPEN_CAMP	ENDP


; ****************************************************
;	キャンプたたむ
; ****************************************************

MAP_EFC_CLOSE_CAMP	PROC	NEAR
	RET
MAP_EFC_CLOSE_CAMP	ENDP


; ****************************************************
;	滝
; ****************************************************

MAP_EFC_FALLS	PROC	NEAR

	MOV	SFT_TIME_MAPS,TIME_FALLS_ANM	; map falls anime time.

	CALL	VRAM98START		; 98 vram & table change start.

	MOV	SFT_LOCCHK_OFF,0	; map location check off.

	MOV	AX,0			; shift direction x.
	MOV	BX,1			; shift direction y.
	MOV	CX,2			; effect falls length.
	MOV	MAP_SFT_PUTMODE,0	; 0=normal.
	CALL	SHIFT_MAPMOV		; shift to map.

	MOV	GIRL_AN01_TBL[0],040EH	; girl anime table.
	MOV	GIRL_AN01_TBL[2],040FH	; girl anime table.
	MOV	GIRL_AN01_TBL[4],041EH	; girl anime table.
	MOV	GIRL_AN01_TBL[6],041FH	; girl anime table.
	MOV	GIRL_AN01_TBL[8],042EH	; girl anime table.
	MOV	GIRL_AN01_TBL[10],042FH	; girl anime table.

	MOV	GIRL_AN02_TBL[0],040CH	; girl anime table.
	MOV	GIRL_AN02_TBL[2],040DH	; girl anime table.
	MOV	GIRL_AN02_TBL[4],041CH	; girl anime table.
	MOV	GIRL_AN02_TBL[6],041DH	; girl anime table.
	MOV	GIRL_AN02_TBL[8],042CH	; girl anime table.
	MOV	GIRL_AN02_TBL[10],042DH	; girl anime table.

	MOV	EFC_FALLS_DEPTH,3	; もぐり深さ
	MOV	FLAG_EFC_SNOW,0		; 雪エフェクト
	MOV	SFT_LOCCHK_OFF,0	; map location check off.
	CALL	EFC_FALLS		; 落下手順
	RET
MAP_EFC_FALLS	ENDP


; ****************************************************
;	落下手順
;	-I- EFC_FALLS_DEPTH : もぐり深さ
;	    FLAG_EFC_SNOW   : 雪エフェクト
;	-I/O- SFT_LOCCHK_OFF : map location check off.
; ****************************************************

EFC_FALLS	PROC	NEAR
	MOV	AX,0			; shift direction x.
	MOV	BX,1			; shift direction y.
	MOV	CX,EFC_FALLS_LEN	; effect falls length.
	DEC	CX			;
	DEC	CX			;
	CMP	CX,0			;
	JLE	EFC_FALLS_3		;
	MOV	MAP_SFT_PUTMODE,2	; 2=view anime draw.
	CALL	SHIFT_MAPMOV		; shift to map.
EFC_FALLS_3:				;

	MOV	SFT_LOCCHK_OFF,1	; map location check off.

	MOV	AX,0			; shift direction x.
	MOV	BX,1			; shift direction y.
	MOV	CX,2			; effect falls length.
	MOV	MAP_SFT_PUTMODE,2	; 2=view anime draw.
	CALL	SHIFT_MAPMOV		; shift to map.

	MOV	EFC_FALLS_D_CNT,0	; もぐり深さカウント
	MOV	CX,EFC_FALLS_DEPTH	; もぐり深さ
EFC_FALLS_LOOP:				;
	PUSH	CX			;

	MOVX	GIRL_AN_TBL[10],GIRL_AN_TBL[6]	; girl anime table.
	MOVX	GIRL_AN_TBL[8],GIRL_AN_TBL[4]	; girl anime table.
	MOVX	GIRL_AN_TBL[6],GIRL_AN_TBL[2]	; girl anime table.
	MOVX	GIRL_AN_TBL[4],GIRL_AN_TBL[0]	; girl anime table.
	MOV	GIRL_AN_TBL[2],0	;
	MOV	GIRL_AN_TBL[0],0	;

	CMP	EFC_FALLS_D_CNT,2	; もぐり深さカウント
	JE	EFC_FALLS_5		;
	OR	GIRL_AN_TBL[8],04000H	; effect chip=8.
	OR	GIRL_AN_TBL[10],04800H	; effect chip=9.
EFC_FALLS_5:				;

	MOV	AX,TIME_FALLS_ANM	; map falls anime time.
	CALL	TIMER_SET		; タイマーセット

	CALL	VRAM98CHG		; 98 vram & table change.
	CALL	VIEW_EFC_DRAW		; view anime draw.
	CALL	TIMER_WAIT		; タイマー待ち

	INC	EFC_FALLS_D_CNT		; もぐり深さカウント
	POP	CX			;
	LOOP	EFC_FALLS_LOOP		;

	CMP	FLAG_EFC_SNOW,0		; 雪エフェクト
	JE	EFC_FALLS_6		;

	CALL	EFC_FALLS_SNOW		; snow effect.

	MOV	AX,TIME_FALLS_ANM*4	; map falls anime time.
	CALL	TIMER_SET		; タイマーセット
	CALL	TIMER_WAIT		; タイマー待ち

	JMP	EFC_FALLS_777		;
EFC_FALLS_6:				;


	MOV	CX,12
EFC_FALLS_LOOP2:			;
	PUSH	CX			;

	MOV	AX,TIME_FALLS_ANM	; map falls anime time.
	CALL	TIMER_SET		; タイマーセット
	CALL	VRAM98CHG		; 98 vram & table change.
	CALL	COPY_AN02_TO_AN		; GIRL_AN02_TBL ->  GIRL_AN_TBL
	CALL	VIEW_DRAW_BG		; view draw back graund.
	CALL	TIMER_WAIT		; タイマー待ち

	POP	CX			;
	LOOP	EFC_FALLS_LOOP2		;

EFC_FALLS_777:
	MOV	AX,0			; shift direction x.
	MOV	BX,1			; shift direction y.
	MOV	CX,2			; effect falls length.
	MOV	MAP_SFT_PUTMODE,0	; 0=normal.
	MOV	SFT_LOCCHK_OFF,1	; map location check off.
	CALL	SHIFT_MAPMOV		; shift to map.

	MOV	AX,TIME_FALLS_ANM	; map falls anime time.
	CALL	VRAM98REDRAW		; 98 vram0 redraw.
	CALL	VRAM98STOP		; 98 vram & table change stop.
	RET
EFC_FALLS	ENDP


; ****************************************************
;	snow effect.
; ****************************************************

EFC_FALLS_SNOW	PROC	NEAR
	MOV	DI,OFFSET GIRL_AN01_TBL		;

EFC_FALLS_SNOW_LOOP:
	MOVX	DS:[DI][10],DS:[DI][2]		; girl anime table.
	MOVX	DS:[DI][8],DS:[DI][0]		; girl anime table.
;;	MOVX	DS:[DI][6],DS:[DI][2]		; girl anime table.
;;	MOVX	DS:[DI][4],DS:[DI][0]		; girl anime table.
	MOV	AX,0				;
	MOV	DS:[DI][6],AX			;
	MOV	DS:[DI][4],AX			;
	MOV	DS:[DI][2],AX			;
	MOV	DS:[DI][0],AX			;

	OR	WORD PTR DS:[DI][8],04000H	; effect chip=8.
	OR	WORD PTR DS:[DI][10],04800H	; effect chip=9.

	CMP	DI,OFFSET GIRL_AN02_TBL		;
	MOV	DI,OFFSET GIRL_AN02_TBL		;
	JNE	EFC_FALLS_SNOW_LOOP		;

	OR	WORD PTR DS:[DI][8],05000H	; effect chip=10.
	OR	WORD PTR DS:[DI][10],05800H	; effect chip=11.

	MOV	CX,12/2
EFC_FALLS_SNOW_LOOP2:			;
	PUSH	CX			;

	CALL	COPY_AN01_TO_AN		; GIRL_AN01_TBL ->  GIRL_AN_TBL

	MOV	AX,TIME_FALLS_ANM	; map falls anime time.
	CALL	TIMER_SET		; タイマーセット
	CALL	VRAM98CHG		; 98 vram & table change.
	CALL	VIEW_EFC_DRAW		; view anime draw.
	CALL	TIMER_WAIT		; タイマー待ち

	CALL	COPY_AN02_TO_AN		; GIRL_AN02_TBL ->  GIRL_AN_TBL

	MOV	AX,TIME_FALLS_ANM	; map falls anime time.
	CALL	TIMER_SET		; タイマーセット
	CALL	VRAM98CHG		; 98 vram & table change.
	CALL	VIEW_EFC_DRAW		; view anime draw.
	CALL	TIMER_WAIT		; タイマー待ち

	POP	CX			;
	LOOP	EFC_FALLS_SNOW_LOOP2	;

	RET
EFC_FALLS_SNOW	ENDP


; ****************************************************
;	上へ
; ****************************************************

MAP_EFC_UP	PROC	NEAR
	CALL	CLEAR_AN0102		; clear GIRL_AN_TBL.

	CMP	GIRL_ANIME_NUM,0	; girl anime number.
	JE	MAP_EFC_UP_2		;
	MOV	DI,4			;
	MOV	SI,6			;
	JMP	MAP_EFC_UP_3		;
MAP_EFC_UP_2:
	MOV	DI,6			;
	MOV	SI,4			;
MAP_EFC_UP_3:
	MOV	AX,GIRL_TBL[DI]		; bank,start pattern.
	ADD	AL,16			;
	MOV	GIRL_AN01_TBL[0],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN01_TBL[2],AX	; girl anime table.
	ADD	AL,15			;
	MOV	GIRL_AN01_TBL[4],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN01_TBL[6],AX	; girl anime table.

	MOV	BX,GIRL_TBL[SI]		; bank,start pattern.
	ADD	BL,16*2			;
	MOV	GIRL_AN02_TBL[0],BX	; girl anime table.
	INC	BL			;
	MOV	GIRL_AN02_TBL[2],BX	; girl anime table.

	CALL	EFC_UPDOWN_OUT		; up down out.
	RET
MAP_EFC_UP	ENDP


; ****************************************************
;	下へ
; ****************************************************

MAP_EFC_DOWN	PROC	NEAR
	CALL	CLEAR_AN0102		; clear GIRL_AN_TBL.

	CMP	GIRL_ANIME_NUM,0	; girl anime number.
	JE	MAP_EFC_DOWN_2		;
	MOV	DI,0			;
	MOV	SI,2			;
	JMP	MAP_EFC_DOWN_3		;
MAP_EFC_DOWN_2:
	MOV	DI,2			;
	MOV	SI,0			;
MAP_EFC_DOWN_3:
	MOV	AX,GIRL_TBL[DI]		; bank,start pattern.
	MOV	GIRL_AN01_TBL[4],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN01_TBL[6],AX	; girl anime table.
	ADD	AL,15			;
	MOV	GIRL_AN01_TBL[8],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN01_TBL[10],AX	; girl anime table.

	MOV	BX,GIRL_TBL[SI]		; bank,start pattern.
	MOV	GIRL_AN02_TBL[8],BX	; girl anime table.
	INC	BL			;
	MOV	GIRL_AN02_TBL[10],BX	; girl anime table.

	CALL	EFC_UPDOWN_OUT		; up down out.
	RET
MAP_EFC_DOWN	ENDP


; ****************************************************
;	上から
; ****************************************************

MAP_EFC_FROM_UP	PROC	NEAR
	CALL	CLEAR_AN0102		; clear GIRL_AN_TBL.

	CMP	GIRL_ANIME_NUM,0	; girl anime number.
	JNE	MAP_EFC_FROM_UP_2	;
	MOV	DI,0			;
	MOV	SI,2			;
	JMP	MAP_EFC_FROM_UP_3	;
MAP_EFC_FROM_UP_2:
	MOV	DI,2			;
	MOV	SI,0			;
MAP_EFC_FROM_UP_3:
	MOV	AX,GIRL_TBL[DI]		; bank,start pattern.
	ADD	AL,16			;
	MOV	GIRL_AN01_TBL[0],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN01_TBL[2],AX	; girl anime table.
	ADD	AL,15			;
	MOV	GIRL_AN01_TBL[4],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN01_TBL[6],AX	; girl anime table.

	MOV	BX,GIRL_TBL[SI]		; bank,start pattern.
	ADD	BL,16*2			;
	MOV	GIRL_AN02_TBL[0],BX	; girl anime table.
	INC	BL			;
	MOV	GIRL_AN02_TBL[2],BX	; girl anime table.

	MOV	AX,1			; 1=up,-1=down.
	CALL	EFC_UPDOWN_IN		; up down in.
	RET
MAP_EFC_FROM_UP	ENDP


; ****************************************************
;	下から
; ****************************************************

MAP_EFC_FROM_DOWN	PROC	NEAR
	CALL	CLEAR_AN0102		; clear GIRL_AN_TBL.

	CMP	GIRL_ANIME_NUM,0	; girl anime number.
	JNE	MAP_EFC_FROM_DOWN_2	;
	MOV	DI,4			;
	MOV	SI,6			;
	JMP	MAP_EFC_FROM_DOWN_3	;
MAP_EFC_FROM_DOWN_2:
	MOV	DI,6			;
	MOV	SI,4			;
MAP_EFC_FROM_DOWN_3:
	MOV	AX,GIRL_TBL[DI]		; bank,start pattern.
	MOV	GIRL_AN01_TBL[4],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN01_TBL[6],AX	; girl anime table.
	ADD	AL,15			;
	MOV	GIRL_AN01_TBL[8],AX	; girl anime table.
	INC	AL			;
	MOV	GIRL_AN01_TBL[10],AX	; girl anime table.

	MOV	BX,GIRL_TBL[SI]		; bank,start pattern.
	MOV	GIRL_AN02_TBL[8],BX	; girl anime table.
	INC	BL			;
	MOV	GIRL_AN02_TBL[10],BX	; girl anime table.

	MOV	AX,-1			; 1=up,-1=down.
	CALL	EFC_UPDOWN_IN		; up down in.
	RET
MAP_EFC_FROM_DOWN	ENDP


; ****************************************************
;	落下
; ****************************************************

MAP_EFC_FALLS2N	PROC	NEAR

	MOV	SFT_TIME_MAPS,TIME_FALLS_ANM	; map falls anime time.

	CALL	VRAM98START		; 98 vram & table change start.

	MOV	SFT_LOCCHK_OFF,0	; map location check off.

	MOV	AX,0			; shift direction x.
	MOV	BX,1			; shift direction y.
	MOV	CX,1			; effect falls length.
	MOV	MAP_SFT_PUTMODE,0	; 0=normal.
	CALL	SHIFT_MAPMOV		; shift to map.

	MOV	GIRL_AN01_TBL[0],0008H	; girl anime table.
	MOV	GIRL_AN01_TBL[2],0009H	; girl anime table.
	MOV	GIRL_AN01_TBL[4],0018H	; girl anime table.
	MOV	GIRL_AN01_TBL[6],0019H	; girl anime table.
	MOV	GIRL_AN01_TBL[8],0028H	; girl anime table.
	MOV	GIRL_AN01_TBL[10],0029H	; girl anime table.
	MOV	GIRL_AN02_TBL[0],000AH	; girl anime table.
	MOV	GIRL_AN02_TBL[2],000BH	; girl anime table.
	MOV	GIRL_AN02_TBL[4],001AH	; girl anime table.
	MOV	GIRL_AN02_TBL[6],001BH	; girl anime table.
	MOV	GIRL_AN02_TBL[8],002AH	; girl anime table.
	MOV	GIRL_AN02_TBL[10],002BH	; girl anime table.

	MOV	EFC_FALLS_DEPTH,2	; もぐり深さ
	MOV	FLAG_EFC_SNOW,1		; 雪エフェクト
	MOV	SFT_LOCCHK_OFF,1	; map location check off.
	CALL	EFC_FALLS		; 落下手順
	RET
MAP_EFC_FALLS2N	ENDP


; ****************************************************
;	左へ
; ****************************************************

MAP_EFC_LEFT	PROC	NEAR
	MOVX	ES,DS			;
	MOV	DI,OFFSET GIRL_AN01_TBL	; girl anime table.
	MOV	CX,6			;
	MOV	AX,0			;
	REP	STOSW			;
	MOV	DI,OFFSET GIRL_AN02_TBL	; girl anime table.
	MOV	CX,6			;
	REP	STOSW			;

	CMP	GIRL_ANIME_NUM,0	; girl anime number.
	JE	MAP_EFC_LEFT_2		;
	MOV	DI,8			;
	JMP	MAP_EFC_LEFT_3		;
MAP_EFC_LEFT_2:
	MOV	DI,10			;
MAP_EFC_LEFT_3:
	MOV	AX,GIRL_TBL[DI]		; bank,start pattern.
	INC	AL			;
	MOV	GIRL_AN01_TBL[0],AX	; girl anime table.
	ADD	AL,16			;
	MOV	GIRL_AN01_TBL[4],AX	; girl anime table.
	ADD	AL,16			;
	MOV	GIRL_AN01_TBL[8],AX	; girl anime table.

	CALL	EFC_UPDOWN_OUT		; up down out.
	RET
MAP_EFC_LEFT	ENDP


; ****************************************************
;	右へ
; ****************************************************

MAP_EFC_RIGHT	PROC	NEAR
	MOVX	ES,DS			;
	MOV	DI,OFFSET GIRL_AN01_TBL	; girl anime table.
	MOV	CX,6			;
	MOV	AX,0			;
	REP	STOSW			;
	MOV	DI,OFFSET GIRL_AN02_TBL	; girl anime table.
	MOV	CX,6			;
	REP	STOSW			;

	CMP	GIRL_ANIME_NUM,0	; girl anime number.
	JE	MAP_EFC_RIGHT_2		;
	MOV	DI,12			;
	JMP	MAP_EFC_RIGHT_3		;
MAP_EFC_RIGHT_2:
	MOV	DI,14			;
MAP_EFC_RIGHT_3:
	MOV	AX,GIRL_TBL[DI]		; bank,start pattern.
	MOV	GIRL_AN01_TBL[2],AX	; girl anime table.
	ADD	AL,16			;
	MOV	GIRL_AN01_TBL[6],AX	; girl anime table.
	ADD	AL,16			;
	MOV	GIRL_AN01_TBL[10],AX	; girl anime table.

	CALL	EFC_UPDOWN_OUT		; up down out.
	RET
MAP_EFC_RIGHT	ENDP


; ****************************************************
;	武神から逃げる
; ****************************************************

MAP_EFC_BUSIN	PROC	NEAR
	MOV	MOUSE_DIR_X,0		; mouse direction x.
	MOV	MOUSE_DIR_Y,0		; mouse direction y.

	MOV	CX,6			; shift count.
MAP_EFC_BUSIN_LOOP:			;
	PUSH	CX			;
	MOV	AX,TIME_MAP_SHIFT	; map shift time.
	CALL	TIMER_SET		; タイマーセット
	;;ADDX	MAP_LOC_X,PARAM01	; map shift x.
	;;ADDX	MAP_LOC_Y,PARAM02	; map shift y.
	;;ADDX	GIRL_LOC_X,PARAM03	; girl shift x.
	INC	GIRL_LOC_Y		; girl shift y.
	CALL	VIEW_DRAW		; view draw.
	CALL	TIMER_WAIT		; タイマー待ち
	POP	CX			;
	LOOP	MAP_EFC_BUSIN_LOOP	;

	RET
MAP_EFC_BUSIN	ENDP


; ****************************************************
;	up down out.
; ****************************************************

EFC_UPDOWN_OUT	PROC	NEAR
	MOV	AX,TIME_ANIME2		; anime 2 time.(walking)
	CALL	TIMER_SET		; タイマーセット
	CALL	COPY_AN01_TO_AN		; GIRL_AN01_TBL ->  GIRL_AN_TBL
	CALL	VIEW_EFC_DRAW		; view anime draw.
	CALL	TIMER_WAIT		; タイマー待ち

	MOV	AX,TIME_ANIME2		; anime 2 time.(walking)
	CALL	TIMER_SET		; タイマーセット
	CALL	COPY_AN02_TO_AN		; GIRL_AN02_TBL ->  GIRL_AN_TBL
	CALL	VIEW_EFC_DRAW		; view anime draw.
	CALL	TIMER_WAIT		; タイマー待ち

	MOV	AX,TIME_ANIME2		; anime 2 time.(walking)
	CALL	TIMER_SET		; タイマーセット
	CALL	CLEAR_AN		; clear GIRL_AN_TBL.
	CALL	VIEW_EFC_DRAW		; view anime draw.
	CALL	TIMER_WAIT		; タイマー待ち

	RET
EFC_UPDOWN_OUT	ENDP


; ****************************************************
;	up down in.
;	-I- AX : 1=up,-1=down.
; ****************************************************

EFC_UPDOWN_IN	PROC	NEAR
	PUSH	AX
	MOV	AX,TIME_ANIME2		; anime 2 time.(walking)
	CALL	TIMER_SET		; タイマーセット
	CALL	CLEAR_AN		; clear GIRL_AN_TBL.
	CALL	VIEW_EFC_DRAW		; view anime draw.
	CALL	TIMER_WAIT		; タイマー待ち

	MOV	AX,TIME_ANIME2		; anime 2 time.(walking)
	CALL	TIMER_SET		; タイマーセット
	CALL	COPY_AN02_TO_AN		; GIRL_AN02_TBL ->  GIRL_AN_TBL
	CALL	VIEW_EFC_DRAW		; view anime draw.
	CALL	TIMER_WAIT		; タイマー待ち

	MOV	AX,TIME_ANIME2		; anime 2 time.(walking)
	CALL	TIMER_SET		; タイマーセット
	CALL	COPY_AN01_TO_AN		; GIRL_AN01_TBL ->  GIRL_AN_TBL
	CALL	VIEW_EFC_DRAW		; view anime draw.
	CALL	TIMER_WAIT		; タイマー待ち

	CALL	ANIME_COUNT_REPEAT	; anime count repeat.

	MOV	AX,TIME_ANIME2		; anime 2 time.(walking)
	CALL	TIMER_SET		; タイマーセット
	CALL	VIEW_DRAW		; view draw.
	CALL	TIMER_WAIT		; タイマー待ち

	POP	AX
	MOV	CX,3			;
EFC_UPDOWN_IN_LOOP:			;
	PUSH	CX			;
	PUSH	AX			;
	ADD	GIRL_LOC_Y,AX		; girl shift y.
	MOV	AX,TIME_ANIME2		; anime 2 time.(walking)
	CALL	TIMER_SET		; タイマーセット
	CALL	VIEW_DRAW		; view draw.
	CALL	TIMER_WAIT		; タイマー待ち
	POP	AX			;
	POP	CX			;
	LOOP	EFC_UPDOWN_IN_LOOP	;

	RET
EFC_UPDOWN_IN	ENDP


; ****************************************************
;	GIRL_AN01_TBL ->  GIRL_AN_TBL
; ****************************************************

COPY_AN01_TO_AN	PROC	NEAR
	MOVX	ES,DS			;
	MOV	SI,OFFSET GIRL_AN01_TBL	; girl anime table.
	MOV	DI,OFFSET GIRL_AN_TBL	; girl anime table.
	MOV	CX,6			;
	REP	MOVSW			;
	RET
COPY_AN01_TO_AN	ENDP


; ****************************************************
;	GIRL_AN02_TBL ->  GIRL_AN_TBL
; ****************************************************

COPY_AN02_TO_AN	PROC	NEAR
	MOVX	ES,DS			;
	MOV	SI,OFFSET GIRL_AN02_TBL	; girl anime table.
	MOV	DI,OFFSET GIRL_AN_TBL	; girl anime table.
	MOV	CX,6			;
	REP	MOVSW			;
	RET
COPY_AN02_TO_AN	ENDP


; ****************************************************
;	clear GIRL_AN_TBL.
; ****************************************************

CLEAR_AN	PROC	NEAR
	MOVX	ES,DS			;
	MOV	DI,OFFSET GIRL_AN_TBL	; girl anime table.
	MOV	CX,6			;
	MOV	AX,0			;
	REP	STOSW			;
	RET
CLEAR_AN	ENDP


; ****************************************************
;	clear GIRL_AN_TBL.
; ****************************************************

CLEAR_AN0102	PROC	NEAR
	MOVX	ES,DS			;
	MOV	DI,OFFSET GIRL_AN01_TBL	; girl anime table.
	MOV	CX,6			;
	MOV	AX,0			;
	REP	STOSW			;
	MOV	DI,OFFSET GIRL_AN02_TBL	; girl anime table.
	MOV	CX,6			;
	REP	STOSW			;
	RET
CLEAR_AN0102	ENDP


; ****************************************************
;	direction adjast.
;	-I/O- MOUSE_DIR_X : mouse locate direction x(+-)
;	      MOUSE_DIR_Y : mouse locate direction y(+-)
;
;	障害を避けて進んで行く
;
; ****************************************************

DIR_AJAST	PROC	NEAR
	MOV	CX,MAP_LOC_X		; map location x.
	ADD	CX,GIRL_LOC_X		; girl location x.
	ADD	CX,MOUSE_DIR_X		; mouse locate direction x(+-)

	MOV	AX,MAP_LOC_Y		; map location y.
	ADD	AX,GIRL_LOC_Y		; girl location y.
	ADD	AX,MOUSE_DIR_Y		; mouse locate direction y(+-)

	MOV	XX,CX			; x.
	MOV	YY,AX			; y.

	CALL	GET_ATTR		; get attribute.
	CMP	ATTRCODE,0		;0:属性無し
	JE	DIR_AJAST_SET		;
	INC	CX			; x++
	CALL	GET_ATTR		; get attribute.
	CMP	ATTRCODE,0		;0:属性無し
	JE	DIR_AJAST_SET		;
	JMP	DIR_AJAST_EXIT		;

DIR_AJAST_SET:
	CMP	MOUSE_DIR_X,0		; mouse locate direction x(+-)
	JLE	DIR_AJAST_2		;
	INC	XX			;
DIR_AJAST_2:

	MOV	DIREC_AJAST,1		; direction adjast.

	CMP	MOUSE_DIR_X,0		; mouse locate direction x(+-)
	JNE	DIR_AJAST_X		;
	CMP	MOUSE_DIR_Y,0		; mouse locate direction y(+-)
	JNE	DIR_AJAST_Y		;
	JMP	DIR_AJAST_EXIT		;

DIR_AJAST_X:
	CMP	MOUSE_DIR_Y,0		; mouse locate direction y(+-)
	JNE	DIR_AJAST_XY		;
DIR_AJAST_X_LOOP:
	MOV	CX,XX			; x.
	MOV	AX,MAP_LOC_Y		; map location y.
	ADD	AX,GIRL_LOC_Y		; girl location y.
	SUB	AX,DIREC_AJAST		; direction adjast.
	CALL	GET_ATTR		; get attribute.
	MOV	ATTR_U,DL		; attribute code up.

	MOV	CX,XX			; x.
	MOV	AX,MAP_LOC_Y		; map location y.
	ADD	AX,GIRL_LOC_Y		; girl location y.
	ADD	AX,DIREC_AJAST		; direction adjast.
	CALL	GET_ATTR		; get attribute.
	MOV	ATTR_D,DL		; attribute code down.

	CMP	ATTR_U,0		; attribute code up.
	JE	DIR_AJAST_X_D		;
	CMP	ATTR_D,0		; attribute code down.
	JE	DIR_AJAST_X_U		;

	; 斜め上、斜め下、ともに行ける
	; 最後に向いた方向へ

	MOVX	MOUSE_DIR_Y,MOUSE_LASTDIR_Y ; mouse last direction y.
	JMP	DIR_AJAST_EXIT_CHK	;

DIR_AJAST_X_D:

	; 斜め上、斜め下、ともに行けない

	CMP	ATTR_D,0		; attribute code down.
	JE	DIR_AJAST_X_NEXT	;

	; 斜め下、行ける

	MOV	MOUSE_DIR_Y,+1		; mouse locate direction y(+-)
	JMP	DIR_AJAST_EXIT_CHK	;

DIR_AJAST_X_U:

	; 斜め上、行ける

	MOV	MOUSE_DIR_Y,-1		; mouse locate direction y(+-)
	JMP	DIR_AJAST_EXIT_CHK	;

DIR_AJAST_X_NEXT:
	CMP	DIREC_AJAST,DIR_AJAST_LENG ; direction adjast length.
	JE	DIR_AJAST_EXIT		;
	MOV	MOUSE_DIR_X,0		; mouse locate direction x(+-)
	INC	DIREC_AJAST		; direction adjast.
	JMP	DIR_AJAST_X_LOOP	;

DIR_AJAST_Y:
DIR_AJAST_Y_LOOP:
	MOV	AX,YY			; y.
	MOV	CX,MAP_LOC_X		; map location x.
	ADD	CX,GIRL_LOC_X		; girl location x.
	SUB	CX,DIREC_AJAST		; direction adjast.
	INC	CX			; x+1
	CALL	GET_ATTR		; get attribute.
	MOV	ATTR_L,DL		; attribute code left.

	MOV	AX,YY			; y.
	MOV	CX,MAP_LOC_X		; map location x.
	ADD	CX,GIRL_LOC_X		; girl location x.
	ADD	CX,DIREC_AJAST		; direction adjast.
	CALL	GET_ATTR		; get attribute.
	MOV	ATTR_R,DL		; attribute code right.

	CMP	ATTR_R,0		; attribute code right.
	JE	DIR_AJAST_Y_L		;
	CMP	ATTR_L,0		; attribute code left.
	JE	DIR_AJAST_Y_R		;

	; 斜め左、斜め右、ともに行ける
	; 最後に向いた方向へ

	MOVX	MOUSE_DIR_X,MOUSE_LASTDIR_X	; mouse last direction x.
	JMP	DIR_AJAST_EXIT_CHK	;

DIR_AJAST_Y_L:

	; 斜め左、斜め右、ともに行けない

	CMP	ATTR_L,0		; attribute code left.
	JE	DIR_AJAST_Y_NEXT	;

	; 斜め左、行ける

	MOV	MOUSE_DIR_X,-1		; mouse locate direction x(+-)
	JMP	DIR_AJAST_EXIT_CHK	;

DIR_AJAST_Y_R:

	; 斜め右、行ける

	MOV	MOUSE_DIR_X,+1		; mouse locate direction x(+-)
	JMP	DIR_AJAST_EXIT_CHK	;

DIR_AJAST_Y_NEXT:
	CMP	DIREC_AJAST,DIR_AJAST_LENG ; direction adjast length.
	JE	DIR_AJAST_EXIT		;
	MOV	MOUSE_DIR_Y,0		; mouse locate direction y(+-)
	INC	DIREC_AJAST		; direction adjast.
	JMP	DIR_AJAST_Y_LOOP	;

DIR_AJAST_EXIT_CHK:			;
	MOV	CX,MAP_LOC_X		; map location x.
	ADD	CX,GIRL_LOC_X		; girl location x.
	ADD	CX,MOUSE_DIR_X		; mouse locate direction x(+-)
	CMP	MOUSE_DIR_X,0		; mouse locate direction x(+-)
	JLE	DIR_AJAST_77		;
	INC	CX			;
DIR_AJAST_77:				;
	MOV	AX,MAP_LOC_Y		; map location y.
	ADD	AX,GIRL_LOC_Y		; girl location y.
	ADD	AX,MOUSE_DIR_Y		; mouse locate direction y(+-)
	CALL	GET_ATTR		; get attribute.
	CMP	DL,0			; attribute code left.
	JNE	DIR_AJAST_EXIT		;
	MOV	MOUSE_DIR_X,0		; mouse locate direction x(+-)
	MOV	MOUSE_DIR_Y,0		; mouse locate direction y(+-)
	JMP	DIR_AJAST_EXIT		;

DIR_AJAST_XY:				;
	MOV	CX,XX			; x.
	MOV	AX,MAP_LOC_Y		; map location y.
	ADD	AX,GIRL_LOC_Y		; girl location y.
	CALL	GET_ATTR		; get attribute.
	CMP	DL,0			; attribute code.
	JNE	DIR_AJAST_XY_X		;

	MOV	CX,MAP_LOC_X		; map location x.
	ADD	CX,GIRL_LOC_X		; girl location x.
	MOV	AX,YY			; y.
	CALL	GET_ATTR		; get attribute.
	CMP	DL,0			; attribute code.
	JNE	DIR_AJAST_XY_Y		;

	MOV	MOUSE_DIR_X,0		; mouse locate direction x(+-)
	MOV	MOUSE_DIR_Y,0		; mouse locate direction y(+-)
	JMP	DIR_AJAST_EXIT		;
DIR_AJAST_XY_X:				;
	MOV	MOUSE_DIR_Y,0		; mouse locate direction y(+-)
	JMP	DIR_AJAST_EXIT		;
DIR_AJAST_XY_Y:				;
	MOV	MOUSE_DIR_X,0		; mouse locate direction x(+-)
DIR_AJAST_EXIT:
	RET
DIR_AJAST	ENDP


; ****************************************************
;	map location adjast.
;	-I- MOUSE_DIR_X : mouse locate direction x(+-)
;	    MOUSE_DIR_Y : mouse locate direction y(+-)
; ****************************************************

MAP_LOC_AJAST	PROC	NEAR
	MOV	SI,MOUSE_DIR_X		; mouse direction x.
	MOV	DI,MOUSE_DIR_Y		; mouse direction y.

	CMP	SI,0
	JG	MAP_LOC_AJAST_22	;
	JE	MAP_LOC_AJAST_YY	;

	MOV	AX,GIRL_LOC_X		; girl location x.
	ADD	GIRL_LOC_X,SI		; girl location x.
	CMP	GIRL_LOC_X,GIRL_MIN_X	; girl min x.
	JGE	MAP_LOC_AJAST_YY	;
	MOV	GIRL_LOC_X,AX		; girl location x.

	ADD	MAP_LOC_X,SI		; map location x.
	CMP	MAP_LOC_X,0		;
	JGE	MAP_LOC_AJAST_YY	;
	MOV	MAP_LOC_X,0		; map location x.

	ADD	GIRL_LOC_X,SI		; girl location x.
	CMP	GIRL_LOC_X,GIRL_MIN2_X	; girl min2 x.
	JGE	MAP_LOC_AJAST_YY	;

	MOV	GIRL_LOC_X,GIRL_MIN2_X	; girl min2 x.
	JMP	MAP_LOC_AJAST_YY	;

MAP_LOC_AJAST_22:			;
	MOV	AX,GIRL_LOC_X		; girl location x.
	ADD	GIRL_LOC_X,SI		; girl location x.
	CMP	GIRL_LOC_X,GIRL_MAX_X	; girl max x.
	JBE	MAP_LOC_AJAST_YY	;
	MOV	GIRL_LOC_X,AX		; girl max x.

	ADD	MAP_LOC_X,SI		; map location x.
	CMPX	MAP_LOC_X,MAP_LOCMAX_X	; map location max x.
	JLE	MAP_LOC_AJAST_YY	;
	MOVX	MAP_LOC_X,MAP_LOCMAX_X	; map location max x.

	ADD	GIRL_LOC_X,SI		; girl location x.
	CMP	GIRL_LOC_X,GIRL_MAX2_X	; girl max2 x.
	JLE	MAP_LOC_AJAST_YY	;

	MOV	GIRL_LOC_X,GIRL_MAX2_X	; girl max2 x.
	JMP	MAP_LOC_AJAST_YY	;

MAP_LOC_AJAST_YY:			;
	CMP	DI,0			;
	JG	MAP_LOC_AJAST_44	;
	JE	MAP_LOC_AJAST_EXIT	;

	MOV	AX,GIRL_LOC_Y		; girl location y.
	ADD	GIRL_LOC_Y,DI		; girl location y.
	CMP	GIRL_LOC_Y,GIRL_MIN_Y	; girl min y.
	JGE	MAP_LOC_AJAST_EXIT	;
	MOV	GIRL_LOC_Y,AX		; girl location y.

	ADD	MAP_LOC_Y,DI		; map location y.
	CMP	MAP_LOC_Y,0		;
	JGE	MAP_LOC_AJAST_EXIT	;
	MOV	MAP_LOC_Y,0		; map location y.

	ADD	GIRL_LOC_Y,DI		; girl location y.
	CMP	GIRL_LOC_Y,GIRL_MIN2_Y	; girl min2 y.
	JGE	MAP_LOC_AJAST_EXIT	;

	MOV	GIRL_LOC_Y,GIRL_MIN2_Y	; girl min2 y.
	JMP	MAP_LOC_AJAST_EXIT	;

MAP_LOC_AJAST_44:			;
	MOV	AX,GIRL_LOC_Y		; girl location y.
	ADD	GIRL_LOC_Y,DI		; girl location y.
	CMP	GIRL_LOC_Y,GIRL_MAX_Y	; girl max y.
	JBE	MAP_LOC_AJAST_EXIT	;
	MOV	GIRL_LOC_Y,AX		; girl max y.

	ADD	MAP_LOC_Y,DI		; map location y.
	CMPX	MAP_LOC_Y,MAP_LOCMAX_Y	; map location max y.
	JLE	MAP_LOC_AJAST_EXIT	;
	MOVX	MAP_LOC_Y,MAP_LOCMAX_Y	; map location max y.

	ADD	GIRL_LOC_Y,DI		; girl location y.
	CMP	GIRL_LOC_Y,GIRL_MAX2_Y	; girl max2 y.
	JLE	MAP_LOC_AJAST_EXIT	;

	MOV	GIRL_LOC_Y,GIRL_MAX2_Y	; girl max2 y.

MAP_LOC_AJAST_EXIT:
	RET
MAP_LOC_AJAST	ENDP


; ****************************************************
;	map location check.
;	-O- CHKATTRCODE1 : check attribute code1.
;	    CHKATTRCODE2 : check attribute code2.
; ****************************************************

MAP_LOC_CHECK	PROC	NEAR
	MOV	CX,MAP_LOC_X			; map location x.
	ADD	CX,GIRL_LOC_X			; girl location x.
	MOV	AX,MAP_LOC_Y			; map location y.
	ADD	AX,GIRL_LOC_Y			; girl location y.

	CALL	GET_ATTR			; get attribute.
	MOV	CHKATTRCODE1,DL			; check attribute code1.

	INC	CX				;

	CALL	GET_ATTR			; get attribute.
	MOV	CHKATTRCODE2,DL			; check attribute code2.

	CMP	CHKATTRCODE1,0			; 0:属性無し
	JE	MAP_LOC_CHECK_BACK		;

	CMP	CHKATTRCODE2,0			; 0:属性無し
	JE	MAP_LOC_CHECK_BACK		;

	RET
MAP_LOC_CHECK_BACK:
	MOVX	MAP_LOC_X,MAP_LOC_OLD_X		; map location old x.
	MOVX	MAP_LOC_Y,MAP_LOC_OLD_Y		; map location old y.
	MOVX	GIRL_LOC_X,GIRL_LOC_OLD_X	; girl location old y.
	MOVX	GIRL_LOC_Y,GIRL_LOC_OLD_Y	; girl location old y.
	RET
MAP_LOC_CHECK	ENDP


; ****************************************************
;	get attribute.
;	-I- CX : map location x.
;	    AX : map location y.
;	-O- ATTRCODE : attribute code.
;	    DL       : attribute code.
; ****************************************************

GET_ATTR	PROC	NEAR
	PUSH	AX
	PUSH	CX

	ADD	AX,GIRL_HIGHT-1		; girl hight.
	MUL	MAP_SIZE_X		; map size x.
	ADD	AX,CX			; x.
	MOV	BX,AX			;
	ADD	BX,BUF_ATTR_OFS		; attribute buffer offset.
	MOV	ES,BUF_ATTR_SEG		; attribute buffer segment.
	MOV	DL,ES:[BX]		; attribute code.
	MOV	ATTRCODE,DL		; attribute code.

	POP	CX
	POP	AX
	RET
GET_ATTR	ENDP


; ****************************************************
;	滑走
;	-I- MOUSE_DIR_X : mouse direction x.
;	    MOUSE_DIR_Y : mouse direction y.
;	    ATTRCODE    : 4:横方向滑走,5:縦方向滑走
; ****************************************************

VIEW_SLIP	PROC	NEAR
VIEW_SLIP_LOOP:
	CALL	CHK_LOC				; check location.
	CMP	AX,1				; 1=same location.
	JE	VIEW_SLIP_EXIT			;

	CALL	MAP_LOC_SAVE			; map location save.

	CALL	TIMER_WAIT			; タイマー待ち
	CMP	CHKATTRCODE1,4			; 4:横方向滑走
	JE	VIEW_SLIP_X			;
	CMP	CHKATTRCODE1,5			; 5:縦方向滑走
	JE	VIEW_SLIP_Y			;
	JMP	VIEW_SLIP_EXIT			;
VIEW_SLIP_X:
	MOVX	MOUSE_DIR_X,MOUSE_LASTDIR_X	; mouse last direction x.
	MOV	MOUSE_DIR_Y,0			; mouse direction y.
	CMP	MOUSE_DIR_X,0			;
	JE	VIEW_SLIP_EXIT			;
	CALL	MAP_LOC_AJAST			; map location adjast.
	CALL	MAP_LOC_CHECK			; map location check.
	CALL	VRAM98CHG			; 98 vram & table change.
	CALL	VIEW_DRAW			; view draw.
	JMP	VIEW_SLIP_NEXT
VIEW_SLIP_Y:
	MOV	MOUSE_DIR_X,0			; mouse direction x.
	MOVX	MOUSE_DIR_Y,MOUSE_LASTDIR_Y	; mouse last direction y.
	CMP	MOUSE_DIR_Y,0			;
	JE	VIEW_SLIP_EXIT			;
	CALL	MAP_LOC_AJAST			; map location adjast.
	CALL	MAP_LOC_CHECK			; map location check.
	CALL	VRAM98CHG			; 98 vram & table change.
	CALL	VIEW_DRAW			; view draw.
	JMP	VIEW_SLIP_NEXT

;*;VIEW_SLIP_XY:				;
;*;	MOVX	MOUSE_DIR_X,MOUSE_LASTDIR_X	; mouse last direction x.
;*;	MOVX	MOUSE_DIR_Y,MOUSE_LASTDIR_Y	; mouse last direction y.
;*;	CMP	MOUSE_DIR_X,0			; mouse direction x.
;*;	JNE	VIEW_SLIP_XY_OK			;
;*;	CMP	MOUSE_DIR_Y,0			; mouse direction y.
;*;	JNE	VIEW_SLIP_XY_OK			;
;*;	JMP	VIEW_SLIP_EXIT			;
;*;VIEW_SLIP_XY_OK:				;
;*;	CALL	MAP_LOC_AJAST			; map location adjast.
;*;	CALL	MAP_LOC_CHECK			; map location check.
;*;	CALL	VIEW_DRAW			; view draw.

VIEW_SLIP_NEXT:
	MOV	AX,TIME_MAP_MOVE		; map move time.
	CALL	TIMER_SET			; タイマーセット
	JMP	VIEW_SLIP_LOOP			;
VIEW_SLIP_EXIT:
	RET
VIEW_SLIP	ENDP


; ****************************************************
;	check location.
;	-O- AX : 1=same location.
; ****************************************************

CHK_LOC	PROC	NEAR
	CMPX	MAP_LOC_OLD_X,MAP_LOC_X		; map location x.
	JNE	CHK_LOC_2			;
	CMPX	MAP_LOC_OLD_Y,MAP_LOC_Y		; map location y.
	JNE	CHK_LOC_2			;
	CMPX	GIRL_LOC_OLD_X,GIRL_LOC_X	; girl location x.
	JNE	CHK_LOC_2			;
	CMPX	GIRL_LOC_OLD_Y,GIRL_LOC_Y	; girl location y.
	JNE	CHK_LOC_2			;

	MOV	AX,1				; 1=same location.
	RET
CHK_LOC_2:
	MOV	AX,0
	RET
CHK_LOC	ENDP


; ****************************************************
;	map location save.
; ****************************************************

MAP_LOC_SAVE	PROC	NEAR
	MOVX	MAP_LOC_OLD_X,MAP_LOC_X		; map location x.
	MOVX	MAP_LOC_OLD_Y,MAP_LOC_Y		; map location y.
	MOVX	GIRL_LOC_OLD_X,GIRL_LOC_X	; girl location x.
	MOVX	GIRL_LOC_OLD_Y,GIRL_LOC_Y	; girl location y.
	RET
MAP_LOC_SAVE	ENDP


; ****************************************************
;	view draw.
;	-I- MAP_LOC_X : map location x.
;	    MAP_LOC_Y : map location y.
; ****************************************************

VIEW_DRAW	PROC	NEAR

	CALL	CHAR_AREA_CLEAR		; character num area clear.

	CALL	PUT_VIEW_GET		; put view get.

	CALL	PUT_ATTR_GET		; put attribute get.

	CALL	CHAR_DIRECTION		; char direction.

	CMP	MAP_DIRECTION,5		; map direction.5=North2
	JE	VIEW_DRAW_5		;
	CALL	GRAND_LEVEL_AJAST	; grand level adjast.
VIEW_DRAW_5:

	CALL	PUT_GIRL_ANIME		; put girl anime pattern.

	CALL	PUT_VIEW_ANIME		; put view anime pattern.

	CALL	VIEW_D_ALL		; view draw all.
	RET
VIEW_DRAW	ENDP


; ****************************************************
;	view draw back graund.
;	-I- MAP_LOC_X : map location x.
;	    MAP_LOC_Y : map location y.
; ****************************************************

VIEW_DRAW_BG	PROC	NEAR
	CALL	CHAR_AREA_CLEAR		; character num area clear.
	CALL	PUT_VIEW_GET		; put view get.
	CALL	PUT_ATTR_GET		; put attribute get.
	CALL	PUT_VIEW_ANIME		; put view anime pattern.
	CALL	VIEW_D_ALL		; view draw all.
	RET
VIEW_DRAW_BG	ENDP


; ****************************************************
;	view anime draw.
;	-I- MAP_LOC_X : map location x.
;	    MAP_LOC_Y : map location y.
;	    GIRL_AN_TBL[]  : girl anime table.
; ****************************************************

VIEW_EFC_DRAW	PROC	NEAR
	CALL	CHAR_AREA_CLEAR		; character num area clear.
	CALL	PUT_VIEW_GET		; put view get.
	CALL	PUT_ATTR_GET		; put attribute get.
	CALL	PUT_GIRL_EFC_AN		; put girl effect anime pattern.
	CALL	PUT_VIEW_ANIME		; put view anime pattern.
	CALL	VIEW_D_ALL		; view draw all.
	RET
VIEW_EFC_DRAW	ENDP


; ****************************************************
;	view BG anime draw.
;	-I- MAP_LOC_X : map location x.
;	    MAP_LOC_Y : map location y.
;	    GIRL_AN_TBL[]  : girl anime table.(BG chip)
; ****************************************************

VIEW_EFC_BG_DRAW	PROC	NEAR
	CALL	CHAR_AREA_CLEAR		; character num area clear.
	CALL	PUT_VIEW_GET		; put view get.
	CALL	PUT_ATTR_GET		; put attribute get.
	CALL	PUT_GIRL_EFC_BG		; put girl effect BG pattern.
	CALL	PUT_VIEW_ANIME		; put view anime pattern.
	CALL	VIEW_D_ALL		; view draw all.
	RET
VIEW_EFC_BG_DRAW	ENDP


; ****************************************************
;	put girl effect anime pattern.
;	-I-   PUT_ATTR_TBL[] : put attribute table.
;	      GIRL_AN_TBL[]  : girl anime table.
;	-I/O- PUT_VIEW_TBL[] : put view table.
;
;	PUT_VIEW_TBL[n][0] : BG chip number.
;	PUT_VIEW_TBL[n][2] : char chip number.
;	PUT_VIEW_TBL[n][2] bit15 : 1=over mask.
;
; ****************************************************

PUT_GIRL_EFC_AN	PROC	NEAR
	MOVX	ES,DS

	MOV	AX,VIEW_SIZE_X		; view size x.
	MUL	GIRL_LOC_Y		; * girl location y.
	ADD	AX,GIRL_LOC_X		; + girl location x.
	SHL	AX,1			;
	SHL	AX,1			; * 4
	ADD	AX,OFFSET PUT_VIEW_TBL	; + now view table.
	ADD	AX,2			; + 2
	MOV	DI,AX			;
	MOV	DX,AX			; AX=start offset.

	MOV	SI,OFFSET GIRL_AN_TBL	; girl anime table.
	MOV	CX,3			;
PUT_GIRL_EFC_AN_LOOP2:			;
	MOVSW				;
	INC	DI			;
	INC	DI			;
	MOVSW				;
	ADD	DI,VIEW_SIZE_X*4-6	; view size x.
	LOOP	PUT_GIRL_EFC_AN_LOOP2	;

	RET
PUT_GIRL_EFC_AN	ENDP


; ****************************************************
;	put girl effect BG pattern.
;	-I-   PUT_ATTR_TBL[] : put attribute table.
;	      GIRL_AN_TBL[]  : girl anime table.(BG chip)
;	-I/O- PUT_VIEW_TBL[] : put view table.
;
;	PUT_VIEW_TBL[n][0] : BG chip number.
;	PUT_VIEW_TBL[n][2] : char chip number.
;	PUT_VIEW_TBL[n][2] bit15 : 1=over mask.
;
; ****************************************************

PUT_GIRL_EFC_BG	PROC	NEAR
	MOVX	ES,DS

	MOV	AX,VIEW_SIZE_X		; view size x.
	MUL	GIRL_LOC_Y		; * girl location y.
	ADD	AX,GIRL_LOC_X		; + girl location x.
	SHL	AX,1			;
	SHL	AX,1			; * 4
	ADD	AX,OFFSET PUT_VIEW_TBL	; + now view table.
	MOV	DI,AX			;
	MOV	DX,AX			; AX=start offset.

	MOV	SI,OFFSET GIRL_AN_TBL	; girl anime table.
	MOV	CX,3			;
PUT_GIRL_EFC_BG_LOOP2:			;

	LODSW				;
	CMP	AX,0			;
	JE	PUT_GIRL_EFC_BG_3	;
	STOSW				;
	JMP	PUT_GIRL_EFC_BG_4	;
PUT_GIRL_EFC_BG_3:			;
	INC	DI			;
	INC	DI			;
PUT_GIRL_EFC_BG_4:			;
	INC	DI			;
	INC	DI			;

	LODSW				;
	CMP	AX,0			;
	JE	PUT_GIRL_EFC_BG_5	;
	STOSW				;
	JMP	PUT_GIRL_EFC_BG_6	;
PUT_GIRL_EFC_BG_5:			;
	INC	DI			;
	INC	DI			;
PUT_GIRL_EFC_BG_6:			;

	ADD	DI,VIEW_SIZE_X*4-6	; view size x.
	LOOP	PUT_GIRL_EFC_BG_LOOP2	;

	RET
PUT_GIRL_EFC_BG	ENDP


; ****************************************************
;	character num area clear.
; ****************************************************

CHAR_AREA_CLEAR	PROC	NEAR
	MOV	DI,OFFSET PUT_VIEW_TBL	; now view table.
	CALL	CHAR_BIT_CLEAR		; character bit clear.
	RET
CHAR_AREA_CLEAR	ENDP


; ****************************************************
;	view table character clear.
; ****************************************************

VIEW_CHAR_CLR	PROC	NEAR
	MOV	DI,OFFSET NOW_VIEW_TBL1	; now view table.
	CALL	CHAR_BIT_CLEAR		; character bit clear.
	MOV	DI,OFFSET NOW_VIEW_TBL2	; now view table.
	CALL	CHAR_BIT_CLEAR		; character bit clear.
	RET
VIEW_CHAR_CLR	ENDP


; ****************************************************
;	character bit clear.
;	-I- DS:DI : view table.
; ****************************************************

CHAR_BIT_CLEAR	PROC	NEAR
	MOVX	ES,DS
	MOV	CX,VIEW_SIZE_X*VIEW_SIZE_Y ; table size.
	MOV	AX,0			;
CHAR_AREA_CLEAR_LOOP:			;
	INC	DI			;
	INC	DI			;
	STOSW				;
	LOOP	CHAR_AREA_CLEAR_LOOP	;
	RET
CHAR_BIT_CLEAR	ENDP


; ****************************************************
;	view table clear.
;	-I- DS:DI : view table.
; ****************************************************

VIEWTBL_CLEAR	PROC	NEAR
	MOVX	ES,DS
	MOV	CX,VIEW_SIZE_X*VIEW_SIZE_Y ; table size.
	MOV	AX,0			;
VIEWTBL_CLEAR_LOOP:			;
	STOSW				;
	STOSW				;
	LOOP	VIEWTBL_CLEAR_LOOP	;
	RET
VIEWTBL_CLEAR	ENDP


; ****************************************************
;	put view get.
;	-O- PUT_VIEW_TBL[] : put view table.
; ****************************************************

PUT_VIEW_GET	PROC	NEAR
	PUSH	DS

	MOV	AX,MAP_LOC_Y		; map location y.
	MUL	MAP_SIZE_X		; map size x.
	ADD	AX,MAP_LOC_X		; map location x.
	SHL	AX,1			; word pointer.
	MOV	SI,AX			; map offset.
	ADD	SI,BUF_MAP_OFS		; SI=map buffer offset.
	MOV	DX,BUF_MAP_SEG		; ES=map buffer segment.
	MOV	DI,OFFSET PUT_VIEW_TBL	; DS:DI=now view table.
	MOVX	ES,DS			;

	MOV	BP,MAP_SIZE_X		; map size x - view size x.
	SUB	BP,VIEW_SIZE_X		;
	SHL	BP,1			; word length.

	MOV	BX,VIEW_SIZE_X		; view size x.
	MOV	CX,VIEW_SIZE_Y		; view size y.
	MOV	DS,DX			;
PUT_VIEW_GET_LOOP:			;
	PUSH	CX			;
	MOV	CX,BX			; view size x.
PUT_VIEW_GET_LOOP2:			;
	MOVSW				;
	INC	DI			;
	INC	DI			;
	LOOP	PUT_VIEW_GET_LOOP2	;
	ADD	SI,BP			;
	POP	CX			;
	LOOP	PUT_VIEW_GET_LOOP	;

	POP	DS
	RET
PUT_VIEW_GET	ENDP


; ****************************************************
;	put attribute get.
;	-O- PUT_ATTR_TBL[] : put attribute table.
; ****************************************************

PUT_ATTR_GET	PROC	NEAR
	PUSH	DS

	MOV	AX,MAP_LOC_Y		; map location y.
	MUL	MAP_SIZE_X		; map size x.
	ADD	AX,MAP_LOC_X		; map location x.
	MOV	SI,AX			; map offset.
	ADD	SI,BUF_ATTR_OFS		; SI=attribute buffer offset.
	MOV	DX,BUF_ATTR_SEG		; DS=attribute buffer segment.
	MOV	DI,OFFSET PUT_ATTR_TBL	; ES:DI=put attribute table.
	MOVX	ES,DS			;

	MOV	BP,MAP_SIZE_X		; BP=map size x - view size x.
	SUB	BP,VIEW_SIZE_X		;

	MOV	BX,VIEW_SIZE_X		; view size x.
	MOV	CX,VIEW_SIZE_Y		; view size y.
	MOV	DS,DX			;
PUT_ATTR_GET_LOOP:			;
	PUSH	CX			;
	MOV	CX,BX			; view size x.
	REP	MOVSB			;
	ADD	SI,BP			;
	POP	CX			;
	LOOP	PUT_ATTR_GET_LOOP	;

	POP	DS
	RET
PUT_ATTR_GET	ENDP


; ****************************************************
;	put view anime pattern.
;	-I/O- PUT_VIEW_TBL[] : put view table.
; ****************************************************

PUT_VIEW_ANIME	PROC	NEAR
	INC	ANIME_CNT			; anime counter.
	CMP	ANIME_CNT,4			; anime counter.
	JE	PUT_VIEW_ANIME_CLR		;
	CMP	ANIME_CNT,2			; anime counter.
	JG	PUT_VIEW_ANIME_START		;
	RET
PUT_VIEW_ANIME_CLR:
	MOV	ANIME_CNT,0			; anime counter.
PUT_VIEW_ANIME_START:

	MOV	SI,OFFSET PUT_VIEW_TBL		; DS:DI=now view table.
	MOV	CX,VIEW_SIZE_X*VIEW_SIZE_Y	; view size y.
PUT_VIEW_ANIME_LOOP:
	PUSH	CX
	LODSW
	MOV	DX,AX				;
	AND	DX,0FC00H			;
	AND	AX,003FFH			;

	CMP	AX,ANIME_XCHG_CHP1		; anime exchange chip1.
	JB	PUT_VIEW_ANIME_NEXT		;
	CMP	AX,ANIME_XCHG_END1		; anime exchange end1.
	JNBE	PUT_VIEW_ANIME_6		;

	SUB	AX,ANIME_XCHG_CHP1		; anime exchange chip1.
	ADD	AX,ANIME_XCHG_CHP2		; anime exchange chip2.
	JMP	PUT_VIEW_ANIME_SET
PUT_VIEW_ANIME_6:				;
	CMP	AX,ANIME_XCHG_CHP2		; anime exchange chip2.
	JB	PUT_VIEW_ANIME_7		;
	CMP	AX,ANIME_XCHG_END2		; anime exchange end2.
	JNBE	PUT_VIEW_ANIME_7		;

	SUB	AX,ANIME_XCHG_CHP2		; anime exchange chip2.
	ADD	AX,ANIME_XCHG_CHP1		; anime exchange chip1.
	JMP	PUT_VIEW_ANIME_SET
PUT_VIEW_ANIME_7:				;
	CMP	AX,ANIME_XCHG_CHP3		; anime exchange chip1.
	JB	PUT_VIEW_ANIME_8		;
	CMP	AX,ANIME_XCHG_END3		; anime exchange end1.
	JNBE	PUT_VIEW_ANIME_8		;

	SUB	AX,ANIME_XCHG_CHP3		; anime exchange chip1.
	ADD	AX,ANIME_XCHG_CHP4		; anime exchange chip2.
	JMP	PUT_VIEW_ANIME_SET
PUT_VIEW_ANIME_8:				;
	CMP	AX,ANIME_XCHG_CHP4		; anime exchange chip2.
	JB	PUT_VIEW_ANIME_NEXT		;
	CMP	AX,ANIME_XCHG_END4		; anime exchange end2.
	JNBE	PUT_VIEW_ANIME_NEXT		;

	SUB	AX,ANIME_XCHG_CHP4		; anime exchange chip2.
	ADD	AX,ANIME_XCHG_CHP3		; anime exchange chip1.
	JMP	PUT_VIEW_ANIME_SET

PUT_VIEW_ANIME_SET:
	DEC	SI
	DEC	SI
	OR	AX,DX
	MOV	DS:[SI],AX
	INC	SI
	INC	SI
PUT_VIEW_ANIME_NEXT:
	INC	SI
	INC	SI
	POP	CX
	LOOP	PUT_VIEW_ANIME_LOOP

	RET
PUT_VIEW_ANIME	ENDP


; ****************************************************
;	char direction.
; ****************************************************

CHAR_DIRECTION	PROC	NEAR

	CMP	NOW_WALK_MODE,1		; now walk mode.0=walk,1=camp.
	JE	CHAR_DIRECTION_5	;

	CMP	MOUSE_DIR_Y,0		; mouse direction y.
	JL	CHAR_DIRECTION_B	;
	JG	CHAR_DIRECTION_F	;

	CMP	MOUSE_DIR_X,0		; mouse direction x.
	JL	CHAR_DIRECTION_L	;
	JG	CHAR_DIRECTION_R	;

	JMP	CHAR_DIRECTION_5	;
CHAR_DIRECTION_F:
	MOV	GIRL_DIR,0		; girl direction.front.
	JMP	CHAR_DIRECTION_5	;
CHAR_DIRECTION_B:
	MOV	GIRL_DIR,1		; girl direction.back.
	JMP	CHAR_DIRECTION_5	;
CHAR_DIRECTION_L:
	MOV	GIRL_DIR,2		; girl direction.left.
	JMP	CHAR_DIRECTION_5	;
CHAR_DIRECTION_R:
	MOV	GIRL_DIR,3		; girl direction.right.
CHAR_DIRECTION_5:
;;;	INC	GIRL_ANIME_CNT		; girl anime counter.
;;;	CMP	GIRL_ANIME_CNT,2	; girl anime counter.
;;;	JB	CHAR_DIRECTION_9	;
	MOV	GIRL_ANIME_CNT,0	; girl anime counter.

	MOV	AX,MAP_LOC_X		; map location x.
	ADD	AX,GIRL_LOC_X		; girl location x.
	MOV	BX,MAP_LOC_OLD_X	; map location old x.
	ADD	BX,GIRL_LOC_OLD_X	; girl location old x.
	CMP	AX,BX			;
	JNE	CHAR_DIRECTION_6	;
	MOV	AX,MAP_LOC_Y		; map location y.
	ADD	AX,GIRL_LOC_Y		; girl location y.
	MOV	BX,MAP_LOC_OLD_Y	; map location old y.
	ADD	BX,GIRL_LOC_OLD_Y	; girl location old y.
	CMP	AX,BX			;
	JNE	CHAR_DIRECTION_6	;
	JMP	CHAR_DIRECTION_9	;
CHAR_DIRECTION_6:
	CALL	ANIME_COUNT_REPEAT	; anime count repeat.
CHAR_DIRECTION_9:
	RET
CHAR_DIRECTION	ENDP


; ****************************************************
;	anime count repeat.
; ****************************************************

ANIME_COUNT_REPEAT	PROC	NEAR
	INC	GIRL_ANIME_NUM		; girl anime number.
	CMP	GIRL_ANIME_NUM,2	;
	JL	ANIME_COUNT_REPEAT_5	;
	MOV	GIRL_ANIME_NUM,0	;
ANIME_COUNT_REPEAT_5:			;
	RET
ANIME_COUNT_REPEAT	ENDP


; ****************************************************
;	grand level adjast.
;	-I/O- GRAND_LEVEL : grand level.
;	-O-   AX          : 0=normal,1=adjast.
; ****************************************************

GRAND_LEVEL_AJAST	PROC	NEAR
	CMP	MOUSE_DIR_X,0		; mouse direction x.
	JE	GRAND_LEVEL_AJAST_NORMAL
	CMP	GIRL_DIR,2		; girl direction.left.
	JE	GRAND_LEVEL_AJAST_START	;
	CMP	GIRL_DIR,3		; girl direction.right.
	JE	GRAND_LEVEL_AJAST_START	;
	JMP	GRAND_LEVEL_AJAST_NORMAL
GRAND_LEVEL_AJAST_START:
	CALL	GIRL_LOC_OFST		; girl location offset.
	MOV	AX,DS:[SI]		; chip number.
	CALL	CHECK_EFECT		; check effect check.
	CMP	AX,0			; 0=none,1=effect.
	JE	GRAND_LEVEL_AJAST_GRAND

	MOV	AX,DS:[SI][4]		; chip number.
	CALL	CHECK_EFECT		; check effect check.
	CMP	AX,0			; 0=none,1=effect.
	JE	GRAND_LEVEL_AJAST_GRAND

	JMP	GRAND_LEVEL_AJAST_MARSH

GRAND_LEVEL_AJAST_GRAND:
	CMP	GRAND_LEVEL,0		; grand level.
	JE	GRAND_LEVEL_AJAST_NORMAL2
	MOV	GRAND_LEVEL,0		; grand level.
	DEC	GIRL_LOC_Y		; girl location y.
	JMP	GRAND_LEVEL_AJAST_ADJ	;

GRAND_LEVEL_AJAST_MARSH:
	CMP	GRAND_LEVEL,-1		; grand level.
	JE	GRAND_LEVEL_AJAST_NORMAL2
	MOV	GRAND_LEVEL,-1		; grand level.
	INC	GIRL_LOC_Y		; girl location y.
	JMP	GRAND_LEVEL_AJAST_ADJ	;

GRAND_LEVEL_AJAST_NORMAL:
	CALL	GIRL_LOC_OFST		; girl location offset.
	MOV	AX,DS:[SI]		; chip number.
	CALL	CHECK_EFECT		; check effect check.
	CMP	AX,0			; 0=none,1=effect.
	JE	GRAND_LEVEL_AJAST_MA2
	MOV	AX,DS:[SI][4]		; chip number.
	CALL	CHECK_EFECT		; check effect check.
	CMP	AX,0			; 0=none,1=effect.
	JE	GRAND_LEVEL_AJAST_MA2
	MOV	GRAND_LEVEL,-1		; grand level.
	JMP	GRAND_LEVEL_AJAST_NORMAL2
GRAND_LEVEL_AJAST_MA2:
	MOV	GRAND_LEVEL,0		; grand level.
GRAND_LEVEL_AJAST_NORMAL2:
	MOV	AX,0			; 0=normal.
	RET
GRAND_LEVEL_AJAST_ADJ:
	MOV	AX,1			; 1=adjast.
	RET
GRAND_LEVEL_AJAST	ENDP


; ****************************************************
;	girl location offset.
; ****************************************************

GIRL_LOC_OFST	PROC	NEAR
	MOV	BX,GIRL_LOC_Y		; * girl location y.
	ADD	BX,GIRL_HIGHT-2		; girl hight.
	ADD	BX,GRAND_LEVEL		; grand level.

	MOV	AX,VIEW_SIZE_X		; view size x.
	MUL	BX			;
	ADD	AX,GIRL_LOC_X		; + girl location x.
	MOV	SI,AX			;
	SHL	SI,1			;
	SHL	SI,1			;
	ADD	SI,OFFSET PUT_VIEW_TBL	; now view table.
	ADD	SI,VIEW_SIZE_X*4*2	; view size x.
	RET
GIRL_LOC_OFST	ENDP


; ****************************************************
;	put girl anime pattern.
;	-I-   PUT_ATTR_TBL[] : put attribute table.
;	-I/O- PUT_VIEW_TBL[] : put view table.
;
;	PUT_VIEW_TBL[n][0] : BG chip number.
;	PUT_VIEW_TBL[n][2] : char chip number.
;	PUT_VIEW_TBL[n][2] bit15 : 1=over mask.
;
; ****************************************************

PUT_GIRL_ANIME	PROC	NEAR
	MOVX	ES,DS

	MOV	AX,VIEW_SIZE_X		; view size x.
	MUL	GIRL_LOC_Y		; * girl location y.
	ADD	AX,GIRL_LOC_X		; + girl location x.
	SHL	AX,1			;
	SHL	AX,1			; * 4
	ADD	AX,OFFSET PUT_VIEW_TBL	; + now view table.
	ADD	AX,2			; + 2
	MOV	DI,AX			;
	MOV	DX,AX			; AX=start offset.

	MOV	BX,GIRL_DIR		; girl direction.
	SHL	BX,1			; * 2
	ADD	BX,GIRL_ANIME_NUM	; + girl anime number.
	SHL	BX,1			; * 2
	MOV	AX,GIRL_TBL[BX]		; bank,start pattern.

	MOV	CX,3			;
PUT_GIRL_ANIME_LOOP2:			;
	STOSW				;
	INC	DI			;
	INC	DI			;
	INC	AL			; pattern+1
	STOSW				;
	ADD	AL,15			; pattern+15
	ADD	DI,VIEW_SIZE_X*4-6	; view size x.
	LOOP	PUT_GIRL_ANIME_LOOP2	;

;	priority check.

	MOV	SI,DX			; start offset.
	ADD	SI,VIEW_SIZE_X*4*2-2	; view size x.
	MOV	BX,VIEW_SIZE_X*4	;

	TEST	WORD PTR [SI][BX],0FC00H
	JZ	PUT_GIRL_ANIME_6	;

	OR	WORD PTR [SI][2],8000H	; 1=over mask.

	SUB	SI,VIEW_SIZE_X*4	; view size x.

	TEST	WORD PTR [SI][BX],0FC00H
	JZ	PUT_GIRL_ANIME_6	;

	OR	WORD PTR [SI][2],8000H	; 1=over mask. 

	SUB	SI,VIEW_SIZE_X*4	; view size x.

	TEST	WORD PTR [SI][BX],0FC00H
	JZ	PUT_GIRL_ANIME_6	;

	OR	WORD PTR [SI][2],8000H	; 1=over mask. 

PUT_GIRL_ANIME_6:

	MOV	SI,DX			; start offset.
	ADD	SI,VIEW_SIZE_X*4*2+2	; view size x.
	MOV	BX,VIEW_SIZE_X*4	;

	TEST	WORD PTR [SI][BX],0FC00H
	JZ	PUT_GIRL_ANIME_7	;

	OR	WORD PTR [SI][2],8000H	; 1=over mask.

	SUB	SI,VIEW_SIZE_X*4	; view size x.

	TEST	WORD PTR [SI][BX],0FC00H
	JZ	PUT_GIRL_ANIME_7	;

	OR	WORD PTR [SI][2],8000H	; 1=over mask.

	SUB	SI,VIEW_SIZE_X*4	; view size x.

	TEST	WORD PTR [SI][BX],0FC00H
	JZ	PUT_GIRL_ANIME_7	;

	OR	WORD PTR [SI][2],8000H	; 1=over mask.

PUT_GIRL_ANIME_7:

;	attribute check.

	MOV	AX,VIEW_SIZE_X		; view size x.
	MUL	GIRL_LOC_Y		; * girl location y.
	ADD	AX,GIRL_LOC_X		; + girl location x.

	MOV	DI,AX			;
	ADD	DI,OFFSET PUT_ATTR_TBL	; put attribute table.

	MOV	SI,AX			;
	SHL	SI,1			;
	SHL	SI,1			;
	ADD	SI,OFFSET PUT_VIEW_TBL + 2 ; now view table.

	MOV	CX,3
PUT_GIRL_ANIME_7LOOP:			;
	PUSH	CX			;
	MOV	CX,2			;
PUT_GIRL_ANIME_7LOOP2:
	CMP	BYTE PTR DS:[DI],2	; 2=チップのみ
	JNE	PUT_GIRL_ANIME_71	;
	MOV	WORD PTR DS:[SI],0	; char chip clear.
	JMP	PUT_GIRL_ANIME_72	;
PUT_GIRL_ANIME_71:
	CMP	BYTE PTR DS:[DI],3	; 3=マスク優先
	JNE	PUT_GIRL_ANIME_72	;
	OR	WORD PTR DS:[SI],8000H	; 1=over mask.
PUT_GIRL_ANIME_72:
	CMP	BYTE PTR DS:[DI],6	; 6=娘優先
	JNE	PUT_GIRL_ANIME_73	;
	AND	WORD PTR DS:[SI],7FFFH	;
PUT_GIRL_ANIME_73:

	INC	DI			;
	ADD	SI,4			;
	LOOP	PUT_GIRL_ANIME_7LOOP2	;
	ADD	DI,VIEW_SIZE_X-2	; view size x.
	ADD	SI,VIEW_SIZE_X*4-4*2	; view size x.
	POP	CX
	LOOP	PUT_GIRL_ANIME_7LOOP

;	girl effect chip.

	CALL	EFFECT_CHIP_SET		; effect chip set.
	RET
PUT_GIRL_ANIME	ENDP


; ****************************************************
;	effect chip set.
; ****************************************************

EFFECT_CHIP_SET	PROC	NEAR

EFFECT_CHIP_SET_70:
	MOV	AX,VIEW_SIZE_X		; view size x.
	MUL	GIRL_LOC_Y		; * girl location y.
	ADD	AX,GIRL_LOC_X		; + girl location x.

	MOV	SI,AX			;
	SHL	SI,1			;
	SHL	SI,1			;
	ADD	SI,OFFSET PUT_VIEW_TBL	; now view table.
	ADD	SI,VIEW_SIZE_X*4*2	; view size x.

	MOV	AX,DS:[SI]		; chip number.
	CALL	CHECK_EFECT		; check effect check.
	CMP	AX,0			; 0=none,1=effect.
	JE	EFFECT_CHIP_SET_EXIT	;

	MOV	AX,DS:[SI][4]		; chip number.
	CALL	CHECK_EFECT		; check effect check.
	CMP	AX,0			; 0=none,1=effect.
	JE	EFFECT_CHIP_SET_EXIT	;

	ADD	SI,2			;

	CMP	MOUSE_DIR_X,0		; mouse direction x.
	JNE	EFFECT_CHIP_SET_72	;
	CMP	MOUSE_DIR_Y,0		; mouse direction y.
	JNE	EFFECT_CHIP_SET_72	;
EFFECT_CHIP_SET_71:			;
	MOV	AX,06000H		; effect chip=12.
	MOV	BX,06800H		; effect chip=13.
	MOV	CX,07000H		; effect chip=14.
	MOV	DX,07800H		; effect chip=15.
	JMP	EFFECT_CHIP_SET_73	;
EFFECT_CHIP_SET_72:			;
	MOV	AX,04000H		; effect chip=8.
	MOV	BX,04800H		; effect chip=9.
	MOV	CX,05000H		; effect chip=10.
	MOV	DX,05800H		; effect chip=11.
EFFECT_CHIP_SET_73:			;

	CMP	GIRL_ANIME_NUM,1	; girl anime number.
	JE	EFFECT_CHIP_SET_77	;
	CMP	WORD PTR DS:[SI],0	;
	JE	EFFECT_CHIP_SET_75	;
	OR	WORD PTR DS:[SI],CX	; effect chip=14.
EFFECT_CHIP_SET_75:			;
	ADD	SI,4			;
	CMP	WORD PTR DS:[SI],0	;
	JE	EFFECT_CHIP_SET_76	;
	OR	WORD PTR DS:[SI],DX	; effect chip=15.
EFFECT_CHIP_SET_76:			;
	JMP	EFFECT_CHIP_SET_8	;

EFFECT_CHIP_SET_77:			;
	CMP	WORD PTR DS:[SI],0	;
	JE	EFFECT_CHIP_SET_78	;
	OR	WORD PTR DS:[SI],AX	; effect chip=12.
EFFECT_CHIP_SET_78:			;
	ADD	SI,4			;
	CMP	WORD PTR DS:[SI],0	;
	JE	EFFECT_CHIP_SET_79	;
	OR	WORD PTR DS:[SI],BX	; effect chip=13.
EFFECT_CHIP_SET_79:			;

EFFECT_CHIP_SET_8:

EFFECT_CHIP_SET_EXIT:
	RET
EFFECT_CHIP_SET	ENDP


; ****************************************************
;	check effect check.
;	-I- AX : chip number.
;	-O- AX : 0=none,1=effect.
; ****************************************************

CHECK_EFECT	PROC	NEAR
	MOV	BX,MAP_DIRECTION	; map direction.

	CMP	BL,1			; 1=East.
	JE	CHECK_EFECT_1		;
;;	CMP	BL,2			; 2=West.
	CMP	BL,3			; 3=South.
	JE	CHECK_EFECT_3		;
;;	CMP	BL,4			; 4=North1.
	CMP	BL,5			; 5=North2.
	JE	CHECK_EFECT_5		;
;;	CMP	BL,6			; 6=North3.

	JMP	CHECK_EFECT_NONE

CHECK_EFECT_1:
	CALL	CHECK_EAST_EF		; check east effect check.
	RET
CHECK_EFECT_3:
	CALL	CHECK_SOUTH_EF		; check south effect check.
	RET
CHECK_EFECT_5:
	CALL	CHECK_NORTH_EF		; check north effect check.
	RET
CHECK_EFECT_NONE:
	MOV	AX,0			; 0=none.
	RET
CHECK_EFECT	ENDP


; ****************************************************
;	check east effect check.
;	-I- AX : chip number.
;	-O- AX : 0=none,1=effect.
; ****************************************************

CHECK_EAST_EF	PROC	NEAR
	MOV	BX,AX
	AND	BX,0380H		; bank number.
	CMP	BX,0180H		; bank number.
	JNE	CHECK_EAST_EF_NONE	;

;	DX =	bit   FEDCBA.987.6543210
;		      ------ --- -------
;		        |     |     |
;		        |     |     +--- chip(0-127)
;		        |     +--------- bank(0-7)
;		        +--------------- mask chip(0-64)
	AND	AL,7FH			;

	CMP	AL,00H			; chip number.
	JE	CHECK_EAST_EF_EF	;
	CMP	AL,01H			; chip number.
	JE	CHECK_EAST_EF_EF	;
	CMP	AL,10H			; chip number.
	JE	CHECK_EAST_EF_EF	;
	CMP	AL,11H			; chip number.
	JE	CHECK_EAST_EF_EF	;

	CMP	AL,40H			; chip number.
	JE	CHECK_EAST_EF_EF	;
	CMP	AL,41H			; chip number.
	JE	CHECK_EAST_EF_EF	;
	CMP	AL,50H			; chip number.
	JE	CHECK_EAST_EF_EF	;
	CMP	AL,51H			; chip number.
	JE	CHECK_EAST_EF_EF	;

CHECK_EAST_EF_NONE:
	MOV	AX,0			; 0=none.
	RET
CHECK_EAST_EF_EF:
	MOV	AX,1			; 1=effect.
	RET
CHECK_EAST_EF	ENDP


; ****************************************************
;	check south effect check.
;	-I- AX : chip number.
;	-O- AX : 0=none,1=effect.
; ****************************************************

CHECK_SOUTH_EF	PROC	NEAR
	MOV	BX,AX
	TEST	BX,0FC00H		; bank number.
	JZ	CHECK_SOUTH_EF_01	;

	AND	BX,0FC00H		; bank number.

	CMP	BX,06H			;
	JB	CHECK_SOUTH_EF_NONE	;
	CMP	BX,11H			;
	JB	CHECK_SOUTH_EF_01	;

	CMP	BX,16H			;
	JB	CHECK_SOUTH_EF_NONE	;
	CMP	BX,21H			;
	JB	CHECK_SOUTH_EF_01	;

	CMP	BX,26H			;
	JB	CHECK_SOUTH_EF_NONE	;

CHECK_SOUTH_EF_01:
	MOV	BX,AX
	AND	BX,0380H		; bank number.

	CMP	BX,0100H		; chip number.
	JE	CHECK_SOUTH_EF_BANK2	;

	CMP	BX,0300H		; chip number.
	JNE	CHECK_SOUTH_EF_NONE	;

;	DX =	bit   FEDCBA.987.6543210
;		      ------ --- -------
;		        |     |     |
;		        |     |     +--- chip(0-127)
;		        |     +--------- bank(0-7)
;		        +--------------- mask chip(0-64)
	AND	AL,7FH			;

	CMP	AL,04H			; chip number.
	JB	CHECK_SOUTH_EF_EF	;
	CMP	AL,10H			; chip number.
	JB	CHECK_SOUTH_EF_NONE	;

	CMP	AL,14H			; chip number.
	JB	CHECK_SOUTH_EF_EF	;
	CMP	AL,1EH			; chip number.
	JB	CHECK_SOUTH_EF_NONE	;
	CMP	AL,20H			; chip number.
	JB	CHECK_SOUTH_EF_EF	;

	CMP	AL,40H			; chip number.
	JB	CHECK_SOUTH_EF_NONE	;

	CMP	AL,44H			; chip number.
	JB	CHECK_SOUTH_EF_EF	;
	CMP	AL,50H			; chip number.
	JB	CHECK_SOUTH_EF_NONE	;

	CMP	AL,54H			; chip number.
	JB	CHECK_SOUTH_EF_EF	;
	CMP	AL,5EH			; chip number.
	JB	CHECK_SOUTH_EF_NONE	;
	CMP	AL,60H			; chip number.
	JB	CHECK_SOUTH_EF_EF	;

	JMP	CHECK_SOUTH_EF_NONE

CHECK_SOUTH_EF_BANK2:
	AND	AL,7FH			;

	CMP	AL,78H			; chip number.
	JE	CHECK_SOUTH_EF_EF	;
	CMP	AL,7DH			; chip number.
	JE	CHECK_SOUTH_EF_EF	;

	JMP	CHECK_SOUTH_EF_NONE

CHECK_SOUTH_EF_NONE:
	MOV	AX,0			; 0=none.
	RET
CHECK_SOUTH_EF_EF:
	MOV	AX,1			; 1=effect.
	RET
CHECK_SOUTH_EF	ENDP


; ****************************************************
;	check north effect check.
;	-I- AX : chip number.
;	-O- AX : 0=none,1=effect.
; ****************************************************

CHECK_NORTH_EF	PROC	NEAR
	MOV	BX,AX
	AND	BX,0FC00H		; bank number.

	CMP	BX,02000H		;=8
	JB	CHECK_NORTH_EF_3	;
	CMP	BX,04000H		;=16
	JB	CHECK_NORTH_EF_EF	;

	CMP	BX,06000H		;=24
	JB	CHECK_NORTH_EF_3	;
	CMP	BX,08000H		;=32
	JB	CHECK_NORTH_EF_EF	;

CHECK_NORTH_EF_3:
	MOV	BX,AX
	AND	BX,0380H		; bank number.

	CMP	BX,0180H		; bank number.
	JNE	CHECK_NORTH_EF_5	;

;	DX =	bit   FEDCBA.987.6543210
;		      ------ --- -------
;		        |     |     |
;		        |     |     +--- chip(0-127)
;		        |     +--------- bank(0-7)
;		        +--------------- mask chip(0-64)

	AND	AL,7FH			;

	CMP	AL,70H			; chip number.
	JB	CHECK_NORTH_EF_NONE	;
	CMP	AL,75H			; chip number.
	JB	CHECK_NORTH_EF_EF	;

	JMP	CHECK_NORTH_EF_NONE

CHECK_NORTH_EF_5:
	CMP	BX,0080H		; bank number.
	JNE	CHECK_NORTH_EF_NONE	;

	AND	AL,7FH			;

	CMP	AL,6DH			; chip number.
	JE	CHECK_NORTH_EF_EF	;

	CMP	AL,12H			; chip number.
	JB	CHECK_NORTH_EF_NONE	;
	CMP	AL,1EH			; chip number.
	JB	CHECK_NORTH_EF_EF	;

CHECK_NORTH_EF_NONE:
	MOV	AX,0			; 0=none.
	RET
CHECK_NORTH_EF_EF:
	CMP	MAP_DIRECTION,5		; map direction.5=North2
	JNE	CHECK_NORTH_EF_999	;
	CMP	NOW_WALK_MODE,1		; now walk mode.0=walk,1=camp.
	JNE	CHECK_NORTH_EF_999	;
	MOV	GIRL_DIR,1		; 1=back.
	MOV	AX,0			; 0=none.
	RET
CHECK_NORTH_EF_999:			;
	MOV	AX,1			; 1=effect.
	RET
CHECK_NORTH_EF	ENDP


; ****************************************************
;	view draw all.
;	-I- MAP_LOC_X : map location x.
;	    MAP_LOC_Y : map location y.
;	    PUT_VIEW_TBL[] : put view table.
; ****************************************************

VIEW_D_ALL	PROC	NEAR
	MOV	AX,16			;
	MUL	ARAVRM[8]		; ＶＲＡＭ幅
	MOV	BP,AX			; BP=次のラインのチップのオフセット
	SUB	BP,VIEW_SIZE_X*2	; view size x.

	MOV	AX,VIEW_LOC_Y		; view locate y.
	MUL	ARAVRM[8]		; ＶＲＡＭ幅
	ADD	AX,VIEW_LOC_X		; view locate x.
	MOV	DI,AX			; DI=vram offset.

	MOV	SI,OFFSET PUT_VIEW_TBL	; put view table.
	MOV	BX,NOW_VIEW_TBL_ADRS	; now view table address.

	MOV	V_LOC_Y,0		; view y.
	MOV	CX,VIEW_SIZE_Y		; view size y.
VIEW_D_ALL_LOOP_1:			;
	PUSH	CX			;

	MOV	V_LOC_X,0		; view x.
	MOV	CX,VIEW_SIZE_X		; view size x.
VIEW_D_ALL_LOOP_2:			;
	LODSW				; chip number.
	MOV	DX,AX			;
	LODSW				; chip number.

	CMP	V_LOC_Y,5+3		; view y.
	JNB	VIEW_D_ALL_2		;
	CMP	V_LOC_X,27		; view x.
	JB	VIEW_D_ALL_2		;
	JMP	VIEW_D_ALL_LOOP_2_NEXT

VIEW_D_ALL_2:				;
	CMP	DX,DS:[BX]		;
	JNE	VIEW_D_ALL_3		;
	CMP	AX,DS:[BX][2]		;
	JNE	VIEW_D_ALL_3		;
	JMP	VIEW_D_ALL_LOOP_2_NEXT

VIEW_D_ALL_3:				;
	MOV	DS:[BX],DX		;
	MOV	DS:[BX][2],AX		;

	PUSH	CX			;
	PUSH	BX			;
	PUSH	DI			;
	PUSH	SI			;

	TEST	DX,0FC00H		;
	JNZ	VIEW_D_ALL_4		;

	CMP	AX,0			;
	JNE	VIEW_D_ALL_33		;

	CALL	WORD PTR JMP_PUT_CHIP	; put chip.

	JMP	VIEW_D_ALL_5		;

VIEW_D_ALL_33:				;
	PUSH	DI			;
	PUSH	AX			;
	CALL	BUFF_SET_CHIP		; buffer set chip.
	POP	AX			;
	CALL	BUFF_SET_CHAR		; buffer set char.
	POP	DI			;
	CALL	WORD PTR JMP_PUT_BUFFER	; put buffer.
	JMP	VIEW_D_ALL_5		;

VIEW_D_ALL_4:				;
	CMP	AX,0			;
	JNE	VIEW_D_ALL_44		;

	PUSH	DI			;
	PUSH	DX			;
	CALL	BUFF_SET_CHIP		; buffer set chip.
	POP	DX			;
	CALL	BUFF_SET_MASK_CHIP	; buffer set mask chip.
	POP	DI			;
	CALL	WORD PTR JMP_PUT_BUFFER	; put buffer.
	JMP	VIEW_D_ALL_5		;

VIEW_D_ALL_44:				;
	TEST	AX,8000H		;
	JNZ	VIEW_D_ALL_45		;
	PUSH	DI			;
	PUSH	AX			;
	PUSH	DX			;
	CALL	BUFF_SET_CHIP		; buffer set chip.
	POP	DX			;
	CALL	BUFF_SET_MASK_CHIP	; buffer set mask chip.
	POP	AX			;
	CALL	BUFF_SET_CHAR		; buffer set char.
	POP	DI			;
	CALL	WORD PTR JMP_PUT_BUFFER	; put buffer.
	JMP	VIEW_D_ALL_5		;

VIEW_D_ALL_45:				;
	PUSH	DI			;
	PUSH	DX			;
	PUSH	AX			;
	CALL	BUFF_SET_CHIP		; buffer set chip.
	POP	AX			;
	CALL	BUFF_SET_CHAR		; buffer set char.
	POP	DX			;
	CALL	BUFF_SET_MASK_CHIP	; buffer set mask chip.
	POP	DI			;
	CALL	WORD PTR JMP_PUT_BUFFER	; put buffer.

VIEW_D_ALL_5:				;
	POP	SI			;
	POP	DI			;
	POP	BX			;
	POP	CX			;
VIEW_D_ALL_LOOP_2_NEXT:			;
	INC	DI			;
	INC	DI			;
	INC	BX			;
	INC	BX			;
	INC	BX			;
	INC	BX			;
	INC	V_LOC_X			; view x.
	LOOPX	VIEW_D_ALL_LOOP_2	;
	ADD	DI,BP			;
	POP	CX			;
	INC	V_LOC_Y			; view y.
	LOOPX	VIEW_D_ALL_LOOP_1
	RET
VIEW_D_ALL	ENDP


; ****************************************************
;	buffer set chip.
;	-I- DX       : chip number.
;	-O- PUT_BUFF : put buffer.
;
;	DX =	bit   FEDCBA.987.6543210
;		      ------ --- -------
;		        |     |     |
;		        |     |     +--- chip(0-127)
;		        |     +--------- bank(0-7)
;		        +--------------- mask chip(0-64)
;
; ****************************************************

BUFF_SET_CHIP	PROC	NEAR
	PUSH	DS
	MOVX	ES,DS

	MOV	BX,DX			;
	SHR	BX,1			;
	SHR	BX,1			;
	SHR	BX,1			;
	SHR	BX,1			;	SHR BX,6
	SHR	BX,1			;
	SHR	BX,1			; bank number.
	AND	BX,1110B		; word pointer.

	MOV	SI,BUF_BANK_OFS[BX]	; bank buffer offset.
	MOV	AX,BUF_BANK_SEG[BX]	; bank buffer segment.

	AND	DX,1111111B		; chip number.(0-127)
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			; * 32*4
	ADD	SI,DX			;

	MOV	DS,AX			;
	MOV	DI,OFFSET PUT_BUFF	; put buffer.
	MOV	CX,16*4			;
	REP	MOVSW			;

	POP	DS
	RET
BUFF_SET_CHIP	ENDP


; ****************************************************
;	buffer set mask chip.
;	-I-   DX       : chip number.
;	-I/O- PUT_BUFF : put buffer.
;
;	DX =	bit   FEDCBA.987.6543210
;		      ------ --- -------
;		        |     |     |
;		        |     |     +--- chip(0-127)
;		        |     +--------- bank(0-7)
;		        +--------------- mask chip(0-64)
;
; ****************************************************

BUFF_SET_MASK_CHIP	PROC	NEAR
	MOVX	ES,DS

	MOV	BX,DX			;
	AND	BX,0FC00H		;
	SHR	BX,1			; dx >> 10 * 32*4
	SHR	BX,1			;
	SHR	BX,1			;
	ADD	BX,BUF_BANK_OFS[BANK_NUM_MASK_CIP*2] ; bank buffer offset.
	MOV	DX,BUF_BANK_SEG[BANK_NUM_MASK_CIP*2] ; bank buffer segment.

	MOV	SI,BX			; bank buffer address.
	ADD	SI,MASK_CHP1_OFST	; mask chip offset.

	CALL	BUFF_MASK		; バッファマスク
	RET
BUFF_SET_MASK_CHIP	ENDP


; ****************************************************
;	buffer set char.
;	-I-   AX       : chip number.
;	-I/O- PUT_BUFF : put buffer.
;
;	AX =	bit   F.EDCB.A98.76543210
;		      - ---- ---  -------
;		      |   |   |      |
;		      |   |   |      +--- chip(0-127)
;		      |   |   +---------- bank(0-7)
;		      |   +-------------- mask chip.bank5,chip97-111(0=off)
;		      +------------------ put flag.
;
; ****************************************************

BUFF_SET_CHAR	PROC	NEAR
	PUSH	AX
	MOV	BL,AH			;
	AND	BL,07H			;
	MOV	BH,0			;
	SHL	BX,1			;
	MOV	CX,BUF_BANK_OFS[BX]	; bank buffer offset.
	MOV	DX,BUF_BANK_SEG[BX]	; bank buffer segment.

	MOV	BX,CX			;

	AND	AX,07FH			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			;
	SHL	AX,1			; *32*4
	SHL	AX,1			;
	ADD	BX,AX			;

	MOV	SI,BX			;
	ADD	SI,CHAR_MASK_CHP_OFST	; char mask chip offset.

	CALL	BUFF_MASK		; バッファマスク
	POP	AX
	TEST	AX,7800H		;
	JZ	BUFF_SET_CHAR_8		;
	CALL	BUFF_SET_CHR_EF		; buffer set char effect.
BUFF_SET_CHAR_8:
	RET
BUFF_SET_CHAR	ENDP


; ****************************************************
;	buffer set char effect.
;	-I-   AX       : chip number.
;	-I/O- PUT_BUFF : put buffer.
;
;	AX =	bit   F.EDCB.A98.76543210
;		      - ---- ---  -------
;		      |   |   |      |
;		      |   |   |      +--- chip(0-127)
;		      |   |   +---------- bank(0-7)
;		      |   +-------------- mask chip.bank5,chip97-111(0=off)
;		      +------------------ put flag.
;
; ****************************************************

BUFF_SET_CHR_EF	PROC	NEAR
	MOV	CX,BUF_BANK_OFS[BANK_NUM_GIRL_CIP*2] ; bank buffer offset.
	MOV	DX,BUF_BANK_SEG[BANK_NUM_GIRL_CIP*2] ; bank buffer segment.

	MOV	BL,AH			;
	SHR	BL,1			;
	SHR	BL,1			;
	SHR	BL,1			;
	AND	BL,0FH			;
	MOV	BH,0			;
	ADD	BX,96			; BX = chip number.

	SHL	BX,1			;
	SHL	BX,1			;
	SHL	BX,1			;
	SHL	BX,1			;
	SHL	BX,1			;
	SHL	BX,1			;*32*4
	SHL	BX,1			;
	ADD	BX,CX			;
	MOV	SI,BX			;
	ADD	SI,CHAR_MASK2EF_OFST	; char mask chip effect offset.

	CALL	BUFF_MASK		; バッファマスク
	RET
BUFF_SET_CHR_EF	ENDP


; ****************************************************
;	バッファマスク
;	-I-   DX:BX    : pattern data.
;	      DX:SI    : mask data.
;	-I/O- PUT_BUFF : put buffer.
; ****************************************************

BUFF_MASK	PROC	NEAR
	PUSH	DS
	MOVX	ES,DS
	MOV	DS,DX			;

	MOV	DI,OFFSET PUT_BUFF	; put buffer.
	MOV	DX,DI			;

	MOV	CX,16			;
BUFF_MASK_LOOP0:			;
	LODSW				;
	AND	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LOOP	BUFF_MASK_LOOP0		;

	MOV	CX,16			;
BUFF_MASK_LOOP1:			;
	LODSW				;
	AND	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LOOP	BUFF_MASK_LOOP1		;

	MOV	CX,16			;
BUFF_MASK_LOOP2:			;
	LODSW				;
	AND	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LOOP	BUFF_MASK_LOOP2		;

	MOV	CX,16			;
BUFF_MASK_LOOP3:			;
	LODSW				;
	AND	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LOOP	BUFF_MASK_LOOP3		;

	MOV	SI,BX			; bank buffer address.
	MOV	DI,DX			;

	MOV	CX,16			;
BUFF_MASK_LOOP_OR0:			;
	LODSW				;
	OR	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LOOP	BUFF_MASK_LOOP_OR0	;

	MOV	CX,16			;
BUFF_MASK_LOOP_OR1:			;
	LODSW				;
	OR	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LOOP	BUFF_MASK_LOOP_OR1	;

	MOV	CX,16			;
BUFF_MASK_LOOP_OR2:			;
	LODSW				;
	OR	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LOOP	BUFF_MASK_LOOP_OR2	;

	MOV	CX,16			;
BUFF_MASK_LOOP_OR3:			;
	LODSW				;
	OR	ES:[DI],AX		;
	INC	DI			;
	INC	DI			;
	LOOP	BUFF_MASK_LOOP_OR3	;

	POP	DS
	RET
BUFF_MASK	ENDP


; ****************************************************
;	put buffer.
;	-I- DI       : put address.
;	    PUT_BUFF : put buffer.
; ****************************************************

PUT_BUFFER	PROC	NEAR
	PUSH	ARAVRM[6]		;
	PUSH	ARAVRM[4]		;
	PUSH	ARAVRM[2]		;
	PUSH	ARAVRM[0]		;

	MOV	BX,ARAVRM[8]		; vram width.
	SUB	BX,2			;
	MOV	DX,DI			; start address.

	MOV	SI,OFFSET PUT_BUFF	; put buffer.

	POP	ES			;
	MOV	DI,DX			; start address.
REPT	16
	MOVSW				;
	ADD	DI,BX			;
ENDM
	POP	ES			;
	MOV	DI,DX			; start address.
REPT	16
	MOVSW				;
	ADD	DI,BX			;
ENDM
	POP	ES			;
	MOV	DI,DX			; start address.
REPT	16
	MOVSW				;
	ADD	DI,BX			;
ENDM
	POP	ES			;
	MOV	DI,DX			; start address.
REPT	16
	MOVSW				;
	ADD	DI,BX			;
ENDM
	RET
PUT_BUFFER	ENDP


; ****************************************************
;	put chip.
;	-I- DI : put address.
;	    DX : chip number.
;		bit   FEDCBA.987.6543210
;		      ------ --- -------
;		        |     |     |
;		        |     |     +--- chip(0-127)
;		        |     +--------- bank(0-7)
;		        +--------------- mask chip(0-64)
;
; ****************************************************

PUT_CHIP	PROC	NEAR
	PUSH	DS

	MOV	BX,DX			; chip number.
	SHR	BX,1			;
	SHR	BX,1			;
	SHR	BX,1			;
	SHR	BX,1			;	SHR BX,6
	SHR	BX,1			;
	SHR	BX,1			;
	AND	BX,1110B		;

	MOV	SI,BUF_BANK_OFS[BX]	; bank buffer offset.
	MOV	AX,BUF_BANK_SEG[BX]	; bank buffer segment.

	AND	DX,1111111B		;
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			; * 32*4
	ADD	SI,DX			;

	PUSH	ARAVRM[6]		;
	PUSH	ARAVRM[4]		;
	PUSH	ARAVRM[2]		;
	PUSH	ARAVRM[0]		;

	MOV	BX,ARAVRM[8]		; vram width.
	SUB	BX,2			;
	MOV	DX,DI			; start address.
	MOV	DS,AX			;

	POP	ES			;
	MOV	DI,DX			; start address.
REPT	16
	MOVSW				;
	ADD	DI,BX			;
ENDM
	POP	ES			;
	MOV	DI,DX			; start address.
REPT	16
	MOVSW				;
	ADD	DI,BX			;
ENDM
	POP	ES			;
	MOV	DI,DX			; start address.
REPT	16
	MOVSW				;
	ADD	DI,BX			;
ENDM
	POP	ES			;
	MOV	DI,DX			; start address.
REPT	16
	MOVSW				;
	ADD	DI,BX			;
ENDM
	POP	DS
	RET
PUT_CHIP	ENDP


; ****************************************************
;	put chip.(VGA)
;	-I- DI       : put address.
;	    PUT_BUFF : put buffer.
; ****************************************************

PUT_BUFFER_VGA	PROC	NEAR
	VGA_WAIT

	MOV	BX,ARAVRM[8]		; vram width.
	SUB	BX,2			;

	MOV	AX,ARAVRM[0]		;
	AND	AX,VRAM_BANK_SEGA	; vram bank mask.
	MOV	ES,AX			;
	MOV	DX,DI			; start address.

	MOV	SI,OFFSET PUT_BUFF	; put buffer.

	MOV	AH,0001B		; vram plean select.
	MOV	AL,2			; map mask.
	OUTVGAW	3C4H,AX			; sequence registar.

	MOV	DI,DX			; start address.
REPT	16
;;	MOVSW				;
	MOVSB				;
	MOVSB				;
	ADD	DI,BX			;
ENDM
	MOV	AH,0010B		; vram plean select.
	MOV	AL,2			; map mask.
	OUTVGAW	3C4H,AX			; sequence registar.

	MOV	DI,DX			; start address.
REPT	16
;;	MOVSW				;
	MOVSB				;
	MOVSB				;
	ADD	DI,BX			;
ENDM
	MOV	AH,0100B		; vram plean select.
	MOV	AL,2			; map mask.
	OUTVGAW	3C4H,AX			; sequence registar.

	MOV	DI,DX			; start address.
REPT	16
;;	MOVSW				;
	MOVSB				;
	MOVSB				;
	ADD	DI,BX			;
ENDM
	MOV	AH,1000B		; vram plean select.
	MOV	AL,2			; map mask.
	OUTVGAW	3C4H,AX			; sequence registar.

	MOV	DI,DX			; start address.
REPT	16
;;	MOVSW				;
	MOVSB				;
	MOVSB				;
	ADD	DI,BX			;
ENDM

	RET
PUT_BUFFER_VGA	ENDP


; ****************************************************
;	put chip.(VGA)
;	-I- DI : put address.
;	    DX : chip number.
;		bit   FEDCBA.987.6543210
;		      ------ --- -------
;		        |     |     |
;		        |     |     +--- chip(0-127)
;		        |     +--------- bank(0-7)
;		        +--------------- mask chip(0-64)
;
; ****************************************************

PUT_CHIP_VGA	PROC	NEAR
	VGA_WAIT
	PUSH	DS

	MOV	BX,DX			; chip number.
	SHR	BX,1			;
	SHR	BX,1			;
	SHR	BX,1			;
	SHR	BX,1			;	SHR BX,6
	SHR	BX,1			;
	SHR	BX,1			;
	AND	BX,1110B		;

	MOV	SI,BUF_BANK_OFS[BX]	; bank buffer offset.
	MOV	CX,BUF_BANK_SEG[BX]	; bank buffer segment.

	AND	DX,1111111B		;
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			;
	SHL	DX,1			; * 32*4
	ADD	SI,DX			;

	MOV	BX,ARAVRM[8]		; vram width.
	SUB	BX,2			;

	MOV	AX,ARAVRM[0]		;
	AND	AX,VRAM_BANK_SEGA	; vram bank mask.
	MOV	ES,AX			;

	MOV	DS,CX			;
	MOV	DX,DI			; start address.

	MOV	AH,0001B		; vram plean select.
	MOV	AL,2			; map mask.
	OUTVGAW	3C4H,AX			; sequence registar.

	MOV	DI,DX			; start address.
REPT	16
;;	MOVSW				;
	MOVSB				;
	MOVSB				;
	ADD	DI,BX			;
ENDM
	MOV	AH,0010B		; vram plean select.
	MOV	AL,2			; map mask.
	OUTVGAW	3C4H,AX			; sequence registar.

	MOV	DI,DX			; start address.
REPT	16
;;	MOVSW				;
	MOVSB				;
	MOVSB				;
	ADD	DI,BX			;
ENDM
	MOV	AH,0100B		; vram plean select.
	MOV	AL,2			; map mask.
	OUTVGAW	3C4H,AX			; sequence registar.

	MOV	DI,DX			; start address.
REPT	16
;;	MOVSW				;
	MOVSB				;
	MOVSB				;
	ADD	DI,BX			;
ENDM
	MOV	AH,1000B		; vram plean select.
	MOV	AL,2			; map mask.
	OUTVGAW	3C4H,AX			; sequence registar.

	MOV	DI,DX			; start address.
REPT	16
;;	MOVSW				;
	MOVSB				;
	MOVSB				;
	ADD	DI,BX			;
ENDM

	POP	DS
	RET
PUT_CHIP_VGA	ENDP


; ****************************************************
;	98 vram & table change start.
; ****************************************************

VRAM98START	PROC	NEAR
	MOV	VRAM98FLAG,0			; 0 -> 1,  1 -> 0
	MOV	CX,0				; 0=VRAM0 show, 1=VRAM1 show.
	MOV	DX,0				; 0=VRAM0 write,1=VRAM1 write.
	CALL	VRAM98CHANGE			; 98 vram change.

	MOV	MOUSE_DIR_X,0		; mouse direction x.<=====
	MOV	MOUSE_DIR_Y,0		; mouse direction y.<=====

	PUSH	ANIME_CNT			; anime counter.
	CALL	VIEW_DRAW		; view draw.
	POP	ANIME_CNT			; anime counter.

;;	MOV	NOW_VIEW_TBL_ADRS,OFFSET NOW_VIEW_TBL2	; now view table address.
	MOV	NOW_VIEW_TBL_ADRS,OFFSET NOW_VIEW_TBL1	; now view table address.
;;	MOV	DI,OFFSET NOW_VIEW_TBL2	; now view table.
;;	CALL	VIEWTBL_CLEAR		; view table clear.
	RET
VRAM98START	ENDP


; ****************************************************
;	98 vram & table change stop.
; ****************************************************

VRAM98STOP	PROC	NEAR
	MOV	VRAM98FLAG,0			; 0 -> 1,  1 -> 0
	MOV	NOW_VIEW_TBL_ADRS,OFFSET NOW_VIEW_TBL1	; now view table address.
	MOV	CX,0				; 0=VRAM0 show, 1=VRAM1 show.
	MOV	DX,0				; 0=VRAM0 write,1=VRAM1 write.
	CALL	VRAM98CHANGE			; 98 vram change.
	RET
VRAM98STOP	ENDP


; ****************************************************
;	98 vram & table change.
; ****************************************************

VRAM98CHG	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PC98		; PC9801
	JNE	VRAM98CHG_EXIT			;

	XOR	VRAM98FLAG,1			; 0 -> 1,  1 -> 0
	CMP	VRAM98FLAG,1			; 98 vram flag.
	JE	VRAM98CHG_BANK1			;
VRAM98CHG_BANK0:
	MOV	CX,1				; 0=VRAM0 show, 1=VRAM1 show.
	MOV	DX,0				; 0=VRAM0 write,1=VRAM1 write.
	CALL	VRAM98CHANGE			; 98 vram change.
	MOV	NOW_VIEW_TBL_ADRS,OFFSET NOW_VIEW_TBL1	; now view table address.
	JE	VRAM98CHG_EXIT			;
VRAM98CHG_BANK1:
	MOV	CX,0				; 0=VRAM0 show, 1=VRAM1 show.
	MOV	DX,1				; 0=VRAM0 write,1=VRAM1 write.
	CALL	VRAM98CHANGE			; 98 vram change.
	MOV	NOW_VIEW_TBL_ADRS,OFFSET NOW_VIEW_TBL2	; now view table address.
VRAM98CHG_EXIT:
	RET
VRAM98CHG	ENDP


; ****************************************************
;	98 vram show=write.
; ****************************************************

VRAM98SHOW2WRT	PROC	NEAR
	CMP	MFLAG_MY,MFLAG_PC98		; PC9801
	JNE	VRAM98SHOW2WRT_EXIT		;

	CMP	VRAM98FLAG,1			; 98 vram flag.
	JE	VRAM98SHOW2WRT_1		;
VRAM98SHOW2WRT_0:				;
	MOV	CX,1				; 0=VRAM0 show, 1=VRAM1 show.
	MOV	DX,1				; 0=VRAM0 write,1=VRAM1 write.
	CALL	VRAM98CHANGE			; 98 vram change.
	JMP	VRAM98SHOW2WRT_EXIT		;
VRAM98SHOW2WRT_1:				;
	MOV	CX,0				; 0=VRAM0 show, 1=VRAM1 show.
	MOV	DX,0				; 0=VRAM0 write,1=VRAM1 write.
	CALL	VRAM98CHANGE			; 98 vram change.
VRAM98SHOW2WRT_EXIT:
	RET
VRAM98SHOW2WRT	ENDP


; ****************************************************
;	98 vram show reverse write.
; ****************************************************

VRAM98REV	PROC	NEAR
	XOR	VRAM98FLAG,1			; 0 -> 1,  1 -> 0
	CALL	VRAM98CHG			; 98 vram & table change.
	RET
VRAM98REV	ENDP


; ****************************************************
;	98 vram0 redraw.
;	-I- AX : anime time.
; ****************************************************

VRAM98REDRAW	PROC	NEAR
	PUSH	AX			;
	CALL	TIMER_WAIT		; タイマー待ち
	POP	AX			;

	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JNE	VRAM98CHG_EXIT		;

	CALL	TIMER_SET		; タイマーセット

	CALL	VRAM98CHG		; 98 vram & table change.
	MOV	MOUSE_DIR_X,0		; mouse direction x.
	MOV	MOUSE_DIR_Y,0		; mouse direction y.
	CALL	VIEW_DRAW		; view draw.

	CMP	VRAM98FLAG,1		; 0 -> 1,  1 -> 0
	JNE	VRAM98REDRAW_EXIT	;

	CALL	VRAM98CHG		; 98 vram & table change.
	MOV	MOUSE_DIR_X,0		; mouse direction x.
	MOV	MOUSE_DIR_Y,0		; mouse direction y.
	CALL	VIEW_DRAW		; view draw.

	CALL	TIMER_WAIT		; タイマー待ち

VRAM98REDRAW_EXIT:
	RET
VRAM98REDRAW	ENDP


; ****************************************************
;	DATA
; ****************************************************

EXTRN	EXIT_STATUS:WORD		; exit status.
					; 1=place ivent.
					; 2=timeout.
					; 3=camp.

EXTRN	MFLAG_MY:WORD			; machine flag.
EXTRN	ARAVRM:WORD			; ＶＲＡＭプレーン

EXTRN	BUF_MAP_OFS:WORD		; map buffer offset.
EXTRN	BUF_MAP_SEG:WORD		; map buffer segment.

EXTRN	BUF_ATTR_OFS:WORD		; attribute buffer offset.
EXTRN	BUF_ATTR_SEG:WORD		; attribute buffer segment.

EXTRN	BUF_BANK_OFS:WORD		; bank buffer offset.
EXTRN	BUF_BANK_SEG:WORD		; bank buffer segment.

EXTRN	MAP_SIZE_X:WORD			; map size x.
EXTRN	MAP_SIZE_Y:WORD			; map size y.

EXTRN	MAP_LOC_X:WORD			; map location x.
EXTRN	MAP_LOC_Y:WORD			; map location y.

EXTRN	GIRL_LOC_X:WORD			; girl location x.
EXTRN	GIRL_LOC_Y:WORD			; girl location y.

EXTRN	ANIME_XCHG_CHP1:WORD		; anime exchange chip1.
EXTRN	ANIME_XCHG_END1:WORD		; anime exchange end1.
EXTRN	ANIME_XCHG_CHP2:WORD		; anime exchange chip2.
EXTRN	ANIME_XCHG_END2:WORD		; anime exchange end2.
EXTRN	ANIME_XCHG_CHP3:WORD		; anime exchange chip3.
EXTRN	ANIME_XCHG_END3:WORD		; anime exchange end3.
EXTRN	ANIME_XCHG_CHP4:WORD		; anime exchange chip4.
EXTRN	ANIME_XCHG_END4:WORD		; anime exchange end4.

EXTRN	EFC_FALLS_LEN:WORD		; effect falls length.

EXTRN	PARAM01:WORD			; parameter 1.
EXTRN	PARAM02:WORD			; parameter 2.
EXTRN	PARAM03:WORD			; parameter 3.
EXTRN	PARAM04:WORD			; parameter 4.
EXTRN	PARAM05:WORD			; parameter 5.
EXTRN	PARAM06:WORD			; parameter 6.

		EVEN
PUT_ATTR_TBL	DB	VIEW_SIZE_X*VIEW_SIZE_Y DUP (-1) ;put attribute table.

PUT_VIEW_TBL	DW	VIEW_SIZE_X*VIEW_SIZE_Y DUP (-1) ; put view table.
		DW	VIEW_SIZE_X*VIEW_SIZE_Y DUP (-1) ;

NOW_VIEW_TBL_ADRS DW	NOW_VIEW_TBL1		; now view table address.
NOW_VIEW_TBL1	DW	VIEW_SIZE_X*VIEW_SIZE_Y DUP (-1) ; now view table.
		DW	VIEW_SIZE_X*VIEW_SIZE_Y DUP (-1) ;
NOW_VIEW_TBL2	DW	VIEW_SIZE_X*VIEW_SIZE_Y DUP (-1) ; now view table.
		DW	VIEW_SIZE_X*VIEW_SIZE_Y DUP (-1) ;  (PC98/vram2)

; attribute table.
;	1:娘の通り道
;	2:チップのみ
;	3:マスク優先
;	4:横方向滑走
;	5:縦方向滑走
;	6:娘優先
;	7:イベント

; view table.
;	+0byte:chip.
;	+2byte:char pattern chip.

ANIME_CNT	DW	0		; anime counter.

GRAND_LEVEL	DW	0		; grand level.

MAP_LOCMAX_X	DW	0		; map location max x.
MAP_LOCMAX_Y	DW	0		; map location max y.

MOUSE_DIR_X	DW	0		; mouse direction x.
MOUSE_DIR_Y	DW	0		; mouse direction y.
MOUSE_LASTDIR_X	DW	1		; mouse last direction x.
MOUSE_LASTDIR_Y	DW	1		; mouse last direction y.
ORGINAL_D_X	DW	0		; orginal dir x.
ORGINAL_D_Y	DW	0		; orginal dir y.

MAP_LOC_OLD_X	DW	0		; map location old x.
MAP_LOC_OLD_Y	DW	0		; map location old y.

GIRL_LOC_OLD_X	DW	12		; girl location old x.
GIRL_LOC_OLD_Y	DW	10		; girl location old y.

GIRL_ANIME_CNT	DW	0		; girl anime counter.
GIRL_ANIME_NUM	DW	0		; girl anime number.
GIRL_DIR	DW	0		; girl direction.
					; girl dir 0=front,1=back,2=left,3=right.
BAK_GIRL_DIR	DW	0		; backup girl direction.
NOW_WALK_MODE	DW	0		; now walk mode.0=walk,1=camp.

GIRL_TBL	LABEL	WORD		; girl table.
		DB	0			; start pattern.
		DB	BANK_NUM_GIRL_CIP	; bank.
		DB	2			; start pattern.
		DB	BANK_NUM_GIRL_CIP	; bank.
		DB	4			; start pattern.
		DB	BANK_NUM_GIRL_CIP	; bank.
		DB	6			; start pattern.
		DB	BANK_NUM_GIRL_CIP	; bank.
		DB	8			; start pattern.
		DB	BANK_NUM_GIRL_CIP	; bank.
		DB	10			; start pattern.
		DB	BANK_NUM_GIRL_CIP	; bank.
		DB	12			; start pattern.
		DB	BANK_NUM_GIRL_CIP	; bank.
		DB	14			; start pattern.
		DB	BANK_NUM_GIRL_CIP	; bank.

GIRL_AN_TBL	LABEL	WORD			; girl anime table.
		DW	6 DUP (0)		;
GIRL_AN_PNT	DW	0			; girl anime pointer.

GIRL_AN01_TBL	LABEL	WORD			; girl anime1 table.
		DW	6 DUP (0)		;
GIRL_AN02_TBL	LABEL	WORD			; girl anime2 table.
		DW	6 DUP (0)		;
GIRL_AN_SW	DW	0			; girl anime switch.

JMP_PUT_CHIP	DW	PUT_CHIP_VGA	; put chip.
JMP_PUT_BUFFER	DW	PUT_BUFFER_VGA	; put mask chip.

XX		DW	0		; x.
YY		DW	0		; y.
ATTRCODE	DB	0,0		; attribute code.
ATTR_U		DB	0		; attribute code up.
ATTR_D		DB	0		; attribute code down.
ATTR_L		DB	0		; attribute code left.
ATTR_R		DB	0		; attribute code right.
DIREC_AJAST	DW	0		; direction adjast.

WALKING_CNT	DW	0		; walking counter.

CHKATTRCODE1	DB	0		; check attribute code1.
CHKATTRCODE2	DB	0		; check attribute code1.

VRAM98FLAG	DW	0		; 98 vram flag.

MAP_DIRECTION	DW	0		; map direction.
			; 1=East,2=West,3=South,4=North1,5=North2,6=North3

TBL_EDIT_FUNC_DIM DW	10		; table map edit function dim.
TBL_EDIT_FUNC	DB	10 DUP (0)	; table map edit function.
			; TBL_EDIT_FUNC[1] : 1=西の泉が枯れた
			; TBL_EDIT_FUNC[2] : 2=北の守護星現れる
			; TBL_EDIT_FUNC[3] : 3=北の守護星への階段が消える
			; TBL_EDIT_FUNC[4] : 4=北の武神への階段が消える
			; TBL_EDIT_FUNC[5] : 5=宝箱OPEN.1
			; TBL_EDIT_FUNC[6] : 6=宝箱OPEN.2
			; TBL_EDIT_FUNC[7] : 7=宝箱OPEN.3
			; TBL_EDIT_FUNC[8] : 8=宝箱OPEN.4
			; TBL_EDIT_FUNC[9] : 9=宝箱OPEN.5

SFT_DIR_XX	DW	0		; shift direction x.
SFT_DIR_YY	DW	0		; shift direction y.
SFT_CNT		DW	0		; shift count.
SFT_TIME_MAPS	DW	0		; map shift time.
SFT_LOCCHK_OFF	DW	0		; map location check off.
MAP_SFT_PUTMODE	DW	0		; map shift put mode.
	;	0=normal,1=BGonly,2=view anime draw,3=view BG anime draw.

V_LOC_X		DW	0		; view x.
V_LOC_Y		DW	0		; view y.

FLAG_SLCT_ANM	DW	0		; flag select anime.

LD_BNK_SW_FLG	DW	01111111B	; load bank switch flag.

SYUGOSEI	DW	0		; 守護星

EFC_FALLS_DEPTH	DW	0		; もぐり深さ
EFC_FALLS_D_CNT	DW	0		; もぐり深さカウント
FLAG_EFC_SNOW	DW	0		; 雪エフェクト

FLG_OPEN_CLOSE	DB	0,0		; フラグOPEN&CLOSE

CHIP_SRT_TBL	LABEL	BYTE		; syugo chip start number.
		DB	44H,07H,40H,0BH,42H,05H,09H,03H,0DH,46H

JUMP_TBL_MAP_EFC	LABEL	WORD		;
	DW	MAP_EFC_TO_HOLE			; 穴へ
	DW	MAP_EFC_FROM_HOLE		; 穴から
	DW	MAP_EFC_TO_MARSH		; 沼へ
	DW	MAP_EFC_FROM_MARSH		; 沼から
	DW	MAP_EFC_OPEN_CAMP		; キャンプ
	DW	MAP_EFC_CLOSE_CAMP		; キャンプたたむ
	DW	MAP_EFC_FALLS			; 滝
	DW	MAP_EFC_UP			; 上へ
	DW	MAP_EFC_DOWN			; 下へ
	DW	MAP_EFC_FROM_UP			; 上から
	DW	MAP_EFC_FROM_DOWN		; 下から
	DW	MAP_EFC_FALLS2N			; 落下
	DW	MAP_EFC_LEFT			; 左へ
	DW	MAP_EFC_RIGHT			; 右へ
	DW	MAP_EFC_BUSIN			; 武神から逃げる
JUMP_TBL_MAP_EFC_END	LABEL	WORD		; 

TREA_E_MAX	DW	3		;宝箱数・東マップ
TREA_E_X	DW	110,73,70	;宝箱OPEN X座標・東マップ
TREA_E_Y	DW	53,19,19	;宝箱OPEN Y座標・東マップ

TREA_W_MAX	DW	4		;宝箱数・西マップ
TREA_W_X	DW	97,77,75,146	;宝箱OPEN X座標・西マップ
TREA_W_Y	DW	19,27,77,54	;宝箱OPEN Y座標・西マップ

TREA_S_MAX	DW	3		;宝箱数・南マップ
TREA_S_X	DW	9,107,134	;宝箱OPEN X座標・南マップ
TREA_S_Y	DW	45,92,134	;宝箱OPEN Y座標・南マップ

TREA_N_MAX	DW	3		;宝箱数・北マップ
TREA_N_X	DW	32,86,111	;宝箱OPEN X座標・北マップ
TREA_N_Y	DW	70,27,31	;宝箱OPEN Y座標・北マップ

PUT_BUFF	DB	32*4 DUP (0)	; put buffer.

FLNM_MAP	DB	"MAPE00.MAP",0	; map file name.
FLNM_ATTR	DB	"MAPE00.ATR",0	; attribute file name.
FLNM_BANK0	DB	"CIPE00.BNK",0	; bank file name.
FLNM_BANK1	DB	"CIPE01.BNK",0	; bank file name.
FLNM_BANK2	DB	"CIPE02.BNK",0	; bank file name.
FLNM_BANK3	DB	"CIPE03.BNK",0	; bank file name.
FLNM_BANK4	DB	"CIPE04.BNK",0	; bank file name.
FLNM_BANK5	DB	"CIPE05.BNK",0	; bank file name.
FLNM_BANK6	DB	"CIPE06.BNK",0	; bank file name.

FLNM_BANK5_CAMP	DB	"CIPC05.BNK",0	; "camp" bank file name.

TBL_MAPDIR	DB	"E0W0S0N1N2N3",0,0	; map dirname table.
				; East,West,South,North1,North2,North3

CODE	ENDS

	END
;
;	end of "VIEWMAP.ASM"
;
