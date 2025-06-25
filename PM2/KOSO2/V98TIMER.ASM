; "V98TIMER.ASM" PC-9801UV11 make by R.H 1992/05/07 "TIMER.ASM" 1988/11/22
;	modify 1992/05/07 r.h
;
;	タイマーセット
;
;	キーボード・ロケーションを行なうためのタイミング取り用に
;	ＫＥＹＭＵＳ（ＭＹＬＣ．ＡＳＭ）をコールしています
;
;	1990/06/02 音楽ドライバＰＭＤ９８用にＰＭＤＶＲＴ（ＰＭＤ．ＡＳＭ）
;	をコールしています
;
;	1990/07/21 複合効果音割込み(V-SYNC)INTSND
;	をコールしています
;
;
;	TMVSND ; V-SYNC timer sound program call.
;	連続効果音用用
;
; public subroutine.

INCLUDE	TSTSET.INC

IN_GDC	MACRO	AA,NUM
;same;	IN	AL,NUM
	PUSH	DX
	MOV	DX,NUM			;
	CALL	IN_7220_GDC_PORT	; in  port 7220 GDC.
	POP	DX
	ENDM

OUTGDC	MACRO	NUM,AA
;same;	OUT	NUM,AL
	PUSH	DX
	MOV	DX,NUM			;
	CALL	OUT_7220_GDC_PORT	; out port 7220 GDC.
	POP	DX
	ENDM

IN_8259	MACRO	AA,NUM
;same;	IN	AL,NUM
	PUSH	DX
	MOV	DX,NUM			;
	CALL	IN_8259_PORT		; in  port 8259.
	POP	DX
	ENDM

OUT8259	MACRO	NUM,AA
;same;	OUT	NUM,AL
	PUSH	DX
	MOV	DX,NUM			;
	CALL	OUT_8259_PORT		; out port 8259.
	POP	DX
	ENDM

TIMER_LOCK	MACRO
;*;	LOCAL	LL
;*;LL:	TEST	KYTBLS[2],80H	; [ｶﾅ] キーテーブル　＊＊＊＊＊＊
;*;	JNZ	LL		; デバックの為のロック
	ENDM

;*NON*;EXTRN	INTSND:FAR	; 複合効果音割込み(V-SYNC)


@code	segment	public	"@code"
	assume	cs:@code,ds:@code
EXTRN	pmdvrt:far		; ＶＲＴＣ割込みでコールすること[PMD98]
@code	ends

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	V98TMWAIT		; time wait.
PUBLIC	V98TMVSRT		; V-SYNC timer start.
PUBLIC	V98TMVEND		; V-SYNC timer end.
PUBLIC	V98TMVWAT		; V-SYNC timer wait.
PUBLIC	V98TMVSET		; V-SYNC timer set.
PUBLIC	V98TMVCHK		; V-SYNC timer check.
PUBLIC	V98TMVEWT		; V-SYNC timer end wait.
PUBLIC	V98TMVST2		; V-SYNC timer2 set.
PUBLIC	V98TMVCK2		; V-SYNC timer2 check.
PUBLIC	V98TMVST3		; V-SYNC timer3 set.
PUBLIC	V98TMVCK3		; V-SYNC timer3 check.
PUBLIC	V98TMVWT4		; V-SYNC timer4 wait.
PUBLIC	V98TMVST5		; V-SYNC timer5 set.
PUBLIC	V98TMVCK5		; V-SYNC timer5 check.
PUBLIC	V98TMVST6		; V-SYNC timer6 set.(use:MOUSE.ASM)
PUBLIC	V98TMVCK6		; V-SYNC timer6 check.(use:MOUSE.ASM)
PUBLIC	V98TMVST7		; V-SYNC timer7 set.(use:WWANIME.ASM)
PUBLIC	V98TMVCK7		; V-SYNC timer7 check.(use:WWANIME.ASM)
PUBLIC	V98TMVST8		; V-SYNC timer8 set.(use:CHILD.ASM)
PUBLIC	V98TMVCK8		; V-SYNC timer8 check.(use:CHILD.ASM)
PUBLIC	V98TMVCLR		; V-SYNC timer clear.
PUBLIC	V98TMVSTP		; V-SYNC timer stop.
PUBLIC	V98TMVCNT		; V-SYNC timer cont.
PUBLIC	V98TMVRND		; V-SYNC timer run counter read.
PUBLIC	V98TMVSAV		; V-SYNC timer value save.
PUBLIC	V98TMVLOD		; V-SYNC timer value load.

;*;PUBLIC TMVJST		; V-SYNC timer jump set.
;*;PUBLIC TMVJRS		; V-SYNC timer jump reset.
;*;PUBLIC TMVJST_FAR		; V-SYNC timer jump set.
;*;PUBLIC TMVJRS_FAR		; V-SYNC timer jump reset.

PUBLIC	V98TMVPLT		; V-SYNC timer pallet program call.
PUBLIC	V98TMVSND		; V-SYNC timer sound program call.

EXTRN	KEYMUS:NEAR		; ｷｰﾎﾞｰﾄﾞ･ﾛｹｰｼｮﾝをマウスドライバへセット
EXTRN	INTPLT:NEAR		; パレット処理割込み(IPLMSG.ASM)

EXTRN	INTMUS:NEAR		; 音楽効果処理割込み(V-SYNC)
;*;EXTRN SNDONX:NEAR		; 効果音発生(DSOUND.ASM)

EXTRN	IN_7220_GDC_PORT:NEAR	; in  port 7220 GDC.
EXTRN	OUT_7220_GDC_PORT:NEAR	; out port 7220 GDC.
EXTRN	IN_8259_PORT:NEAR	; in  port 8259.
EXTRN	OUT_8259_PORT:NEAR	; out port 8259.


; time wait.
; -i- DX : time.

V98TMWAIT	PROC	NEAR
	PUSH	CX

	MOV	CX,DX
TMWAIT1:PUSH	CX
	MOV	CX,5000
TMWAIT2:NOP
	NOP
	LOOP	TMWAIT2
	POP	CX
	LOOP	TMWAIT1

	POP	CX
	RET
V98TMWAIT	ENDP


; V-SYNC timer start.

V98TMVSRT	PROC	NEAR
;*;	MOV	STACK_CHECK_HI,SP	; stack check hi-address.
;*;	MOV	STACK_CHECK_LOW,SP	; stack check low-address.

	CALL	VECSET_VSYNC_SAVE	; vector save.

	CALL	VECSET_VSYNC		; V-SYNC int vector.

	CLI
	IN_8259	AL,02H			; IMR save.
	MOV	SAVE_IMR,AX		;

	AND	AL,0FBH			; V-SYNC unmask.
	OUT8259	02H,AL			; IMR set.
	STI

	OUTGDC	64H,AL			; V-SYNC reset.

	RET
V98TMVSRT	ENDP


; timer end.

V98TMVEND	PROC	NEAR

	CALL	VECSET_VSYNC_STOP	; V-SYNC stop vector.

	MOV	DX,10
	CALL	V98TMWAIT			; time wait.

	CLI
	MOV	AX,SAVE_IMR		;
	OUT8259	02H,AL			; IMR load.
	STI

	CALL	VECSET_VSYNC_LOAD	; vector load.

	RET
V98TMVEND	ENDP


; V-SYNC timer wait.
;	-I- AX : wait timer count.

V98TMVWAT	PROC	NEAR
	MOV	WORD PTR VSYNCC,AX
TMVWAT1:
	TIMER_LOCK

	CMP	WORD PTR VSYNCC,0
	JNZ	TMVWAT1
	RET
V98TMVWAT	ENDP



; V-SYNC timer set.
;	-I- AX : wait timer count.

V98TMVSET	PROC	NEAR
	MOV	WORD PTR VSYNCC,AX
;*;	LC	0,21
;*;	PRVH	"stack check hi-address =",STACK_CHECK_HI
;*;	PRVH	"stack check low-address=",STACK_CHECK_LOW
	RET
V98TMVSET	ENDP



; V-SYNC timer check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

V98TMVCHK	PROC	NEAR
	TIMER_LOCK

	MOV	DX,VSYNCC
	CMP	DX,0
	JZ	TMVCHK1
	MOV	AX,0		; 0=timer now.
	RET
TMVCHK1:
	MOV	AX,1		; 1=timer end.
	RET
V98TMVCHK	ENDP


; V-SYNC timer end wait.

V98TMVEWT	PROC	NEAR
TMVEWT1:
	TIMER_LOCK

	CMP	WORD PTR VSYNCC,0
	JNZ	TMVEWT1
	RET
V98TMVEWT	ENDP


; V-SYNC timer2 set.
;	-I- AX : wait timer count.

V98TMVST2	PROC	NEAR
	MOV	WORD PTR VSYNC2,AX
	RET
V98TMVST2	ENDP



; V-SYNC timer2 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

V98TMVCK2	PROC	NEAR
	TIMER_LOCK

	MOV	DX,VSYNC2
	CMP	DX,0
	JZ	TMVCK21
	MOV	AX,0		; 0=timer now.
	RET
TMVCK21:
	MOV	AX,1		; 1=timer end.
	RET
V98TMVCK2	ENDP



; V-SYNC timer3 set.
;	-I- AX : wait timer count.

V98TMVST3	PROC	NEAR
	MOV	WORD PTR VSYNC3,AX
	RET
V98TMVST3	ENDP



; V-SYNC timer3 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

V98TMVCK3	PROC	NEAR
	TIMER_LOCK

	MOV	DX,VSYNC3
	CMP	DX,0
	JZ	TMVCK31
	MOV	AX,0		; 0=timer now.
	RET
TMVCK31:
	MOV	AX,1		; 1=timer end.
	RET
V98TMVCK3	ENDP



; V-SYNC timer4 wait.
;	-I- AX : wait timer count.

V98TMVWT4	PROC	NEAR
	MOV	WORD PTR VSYNC4,AX
TMVWT41:

;*NON*;	TEXT_VRAM_SEG	EQU	0A000H	; text vram address.
;*NON*;	PUSH	ES
;*NON*;	MOV	AX,TEXT_VRAM_SEG	; テキストマークの明滅
;*NON*;	MOV	ES,AX			; text segment
;*NON*;	MOV	AX,'.'			;
;*NON*;	MOV	ES:[6],AX		;
;*NON*;	JMP	TMVWT45			;
;*NON*;TMVWT45:				;
;*NON*;	MOV	AX,' '			;
;*NON*;	MOV	ES:[6],AX		;
;*NON*;	POP	ES			;
;*NON*;
	CMP	WORD PTR VSYNC4,0
	JNZ	TMVWT41
	RET
V98TMVWT4	ENDP



; V-SYNC timer5 set.
;	-I- AX : wait timer count.

V98TMVST5	PROC	NEAR
	MOV	WORD PTR VSYNC5,AX
	RET
V98TMVST5	ENDP



; V-SYNC timer5 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

V98TMVCK5	PROC	NEAR
	MOV	DX,VSYNC5
	CMP	DX,0
	JZ	TMVCK51
	MOV	AX,0		; 0=timer now.
	RET
TMVCK51:
	MOV	AX,1		; 1=timer end.
	RET
V98TMVCK5	ENDP


; V-SYNC timer6 set.
;	-I- AX : wait timer count.

V98TMVST6	PROC	NEAR
	MOV	WORD PTR VSYNC6,AX
	RET
V98TMVST6	ENDP


; V-SYNC timer6 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

V98TMVCK6	PROC	NEAR
	MOV	DX,VSYNC6
	CMP	DX,0
	JZ	TMVCK61
	MOV	AX,0		; 0=timer now.
	RET
TMVCK61:
	MOV	AX,1		; 1=timer end.
	RET
V98TMVCK6	ENDP


; V-SYNC timer7 set.
;	-I- AX : wait timer count.

V98TMVST7	PROC	NEAR
	MOV	VSYNC7,AX
	RET
V98TMVST7	ENDP


; V-SYNC timer7 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

V98TMVCK7	PROC	NEAR
	MOV	DX,VSYNC7
	CMP	DX,0
	JZ	TMVCK71
	MOV	AX,0		; 0=timer now.
	RET
TMVCK71:
	MOV	AX,1		; 1=timer end.
	RET
V98TMVCK7	ENDP


; V-SYNC timer8 set.
;	-I- AX : wait timer count.

V98TMVST8	PROC	NEAR
	MOV	VSYNC8,AX
	RET
V98TMVST8	ENDP


; V-SYNC timer8 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

V98TMVCK8	PROC	NEAR
	MOV	DX,VSYNC8
	CMP	DX,0
	JZ	TMVCK81
	MOV	AX,0		; 0=timer now.
	RET
TMVCK81:
	MOV	AX,1		; 1=timer end.
	RET
V98TMVCK8	ENDP


; V-SYNC timer clear.

V98TMVCLR	PROC	NEAR
	MOV	VSYNCC,0		; V-SYNC counter.
	MOV	VSYNC2,0		; V-SYNC counter2.
	MOV	VSYNC3,0		; V-SYNC counter3.
	MOV	VSYNC4,0		; V-SYNC counter4.
;;	MOV	VSYNC5,0		; V-SYNC counter5.
	MOV	VSYNC6,0		; V-SYNC counter6.
	MOV	VSYNC7,0		; V-SYNC counter7.
	RET
V98TMVCLR	ENDP


; V-SYNC timer stop.

V98TMVSTP	PROC	NEAR

	CALL	VECSET_VSYNC_STOP	; V-SYNC stop vector.

	JMP	TMVSTP2			; JUMP (cpu cue buffer clear.)
TMVSTP2:				;

	TEST	BYTE PTR SAVE_IMR,00000100B	; return mask.
	JZ	TMVSTP1			; set mask ?

	CLI
	IN_8259	AL,02H			; IMR read.
	OR	AL,00000100B		; V-SYNC mask.
	OUT8259	02H,AL			; IMR write.
	STI
TMVSTP1:
	CALL	VECSET_VSYNC_LOAD	; vector load.

	RET
V98TMVSTP	ENDP


; V-SYNC timer cont.

V98TMVCNT	PROC	NEAR
	CALL	VECSET_VSYNC		; V-SYNC int vector.

	CLI
	IN_8259	AL,02H			; IMR read.
	AND	AL,0FBH			; V-SYNC unmask.
	OUT8259	02H,AL			; IMR write.
	STI

	OUTGDC	64H,AL			; V-SYNC reset.

	RET
V98TMVCNT	ENDP


; V_SYNC timer run counter read.
; -O- AX : now counter.

V98TMVRND	PROC	NEAR
	MOV	AX,WORD PTR DS:[VSYNCR]	; V-SYNC run counter.
	RET
V98TMVRND	ENDP


; V-SYNC timer value save.

V98TMVSAV	PROC	NEAR
	PUSH	AX
	MOV	AX,VSYNCC	; V-SYNC counter.
	MOV	SAVE_VSYNCC,AX	; V-SYNC counter save.
	MOV	AX,VSYNC2	; V-SYNC counter2.
	MOV	SAVE_VSYNC2,AX	; V-SYNC counter2 save.
	MOV	AX,VSYNC3	; V-SYNC counter3.
	MOV	SAVE_VSYNC3,AX	; V-SYNC counter3 save.
	MOV	AX,VSYNC4	; V-SYNC counter4.
	MOV	SAVE_VSYNC4,AX	; V-SYNC counter4 save.
	MOV	AX,VSYNC5	; V-SYNC counter5.
	MOV	SAVE_VSYNC5,AX	; V-SYNC counter5 save.
	MOV	AX,VSYNC6	; V-SYNC counter6.
	MOV	SAVE_VSYNC6,AX	; V-SYNC counter6 save.
	MOV	AX,VSYNC7	; V-SYNC counter7.
	MOV	SAVE_VSYNC7,AX	; V-SYNC counter7 save.
	MOV	AX,VSYNCR	; V-SYNC run counter.
	MOV	SAVE_VSYNCR,AX	; V-SYNC run counter save.
	MOV	AX,VSYNCJ	; V-SYNC set jump counter.
	MOV	SAVE_VSYNCJ,AX	; V-SYNC set jump counter save.
	POP	AX
	RET
V98TMVSAV	ENDP


; V-SYNC timer value load.

V98TMVLOD	PROC	NEAR
	PUSH	AX
	MOV	AX,SAVE_VSYNCC	; V-SYNC counter save.
	MOV	VSYNCC,AX	; V-SYNC counter.
	MOV	AX,SAVE_VSYNC2	; V-SYNC counter2 save.
	MOV	VSYNC2,AX	; V-SYNC counter2.
	MOV	AX,SAVE_VSYNC3	; V-SYNC counter3 save.
	MOV	VSYNC3,AX	; V-SYNC counter3.
	MOV	AX,SAVE_VSYNC4	; V-SYNC counter4 save.
	MOV	VSYNC4,AX	; V-SYNC counter4.
	MOV	AX,SAVE_VSYNC5	; V-SYNC counter5 save.
	MOV	VSYNC5,AX	; V-SYNC counter5.
	MOV	AX,SAVE_VSYNC6	; V-SYNC counter6 save.
	MOV	VSYNC6,AX	; V-SYNC counter6.
	MOV	AX,SAVE_VSYNC7	; V-SYNC counter7 save.
	MOV	VSYNC7,AX	; V-SYNC counter7.
	MOV	AX,SAVE_VSYNCR	; V-SYNC run counter save.
	MOV	VSYNCR,AX	; V-SYNC run counter.
	MOV	AX,SAVE_VSYNCJ	; V-SYNC set jump counter save.
	MOV	VSYNCJ,AX	; V-SYNC set jump counter.
	POP	AX
	RET
V98TMVLOD	ENDP


;*;;	(far) V-SYNC timer jump set.
;*;;	-I- AX : wait time.
;*;;	    SI : save SS
;*;;	    BX : save SP
;*;;	    CX : jump CS
;*;;	    DX : jump IP
;*;;	    DS : save DS
;*;;	    flags : save FLAGS
;*;
;*;TMVJST_FAR	PROC	FAR
;*;	CALL	TMVJST		; V-SYNC timer jump set.
;*;	RET
;*;TMVJST_FAR	ENDP
;*;
;*;
;*;;	(far) V-SYNC timer jump reset.
;*;
;*;TMVJRS_FAR	PROC	FAR
;*;	CALL	TMVJRS		; V-SYNC timer jump reset.
;*;	RET
;*;TMVJRS_FAR	ENDP
;*;
;*;
;*;;	V-SYNC timer jump set.
;*;;	-I- AX : wait time.
;*;;	    SI : save SS
;*;;	    BX : save SP
;*;;	    CX : jump CS
;*;;	    DX : jump IP
;*;;	    DS : save DS
;*;;	    flags : save FLAGS
;*;
;*;TMVJST	PROC	NEAR
;*;	MOV	VSYNCJ,AX			; V-SYNC set jump counter.
;*;	MOV	SET_J_SS,SI			; save SS
;*;	MOV	SET_J_SP,BX			; save SP
;*;	MOV	SET_J_CS,CX			; jump CS
;*;	MOV	SET_J_IP,DX			; jump IP
;*;
;*;	PUSH	DS				; save DS
;*;	POP	SET_J_DS			; save DS
;*;	PUSHF
;*;	POP	SET_J_FLAGS			; save FLAGS
;*;	RET
;*;TMVJST	ENDP
;*;
;*;
;*;;	V-SYNC timer jump reset.
;*;
;*;TMVJRS	PROC	NEAR
;*;	MOV	VSYNCJ,0			; V-SYNC set jump counter.
;*;	RET
;*;TMVJRS	ENDP


; V-SYNC timer pallet program call.
; -I- AX : 割込みスイッチ 0=OFF,1=ON

V98TMVPLT	PROC	NEAR
	MOV	PALET_SW,AX		; 割込みスイッチ 0=OFF,1=ON
	RET
V98TMVPLT	ENDP


; V-SYNC timer sound program call.
; -I- AX : 効果音番号(0=OFF)
;     BX : 間隔時間（Ｖ－ＳＹＮＣ）

V98TMVSND	PROC	NEAR
	MOV	SOUND_NUM,AX		; 効果音番号
	MOV	SOUND_TIME,BX		; 間隔時間（Ｖ－ＳＹＮＣ）
	MOV	SOUND_TCNT,0		; 間隔時間カウンタ
	RET
V98TMVSND	ENDP



VEC_CRTV_OFST	EQU	28H	; int 0Ah
VEC_CRTV_SEG	EQU	2AH	;

;	common subroutine.

VECSET_VSYNC	PROC	NEAR
	CLI

	MOV	AX,0		; 0 base.
	MOV	ES,AX		;

	MOV	WORD PTR ES:[VEC_CRTV_OFST],OFFSET TMINT

	MOV	WORD PTR ES:[VEC_CRTV_SEG],SEG CODE01

	STI
	RET
VECSET_VSYNC	ENDP

VECSET_VSYNC_STOP	PROC	NEAR
	CLI

	MOV	AX,0		; 0 base.
	MOV	ES,AX		;

	MOV	WORD PTR ES:[VEC_CRTV_OFST],OFFSET TMINT_STOP

	MOV	WORD PTR ES:[VEC_CRTV_SEG],SEG CODE01

	STI
	RET
VECSET_VSYNC_STOP	ENDP

VECSET_VSYNC_SAVE	PROC	NEAR
	CLI

	MOV	AX,0		; 0 base.
	MOV	ES,AX		;

	MOV	AX,WORD PTR ES:[VEC_CRTV_OFST]
	MOV	SAVE_VEC_CRTV_OFST,AX

	MOV	AX,WORD PTR ES:[VEC_CRTV_SEG]
	MOV	SAVE_VEC_CRTV_SEG,AX

	STI
	RET
VECSET_VSYNC_SAVE	ENDP

VECSET_VSYNC_LOAD	PROC	NEAR
	CLI

	MOV	AX,0		; 0 base.
	MOV	ES,AX		;

	MOV	AX,SAVE_VEC_CRTV_OFST
	MOV	WORD PTR ES:[VEC_CRTV_OFST],AX

	MOV	AX,SAVE_VEC_CRTV_SEG
	MOV	WORD PTR ES:[VEC_CRTV_SEG],AX

	STI
	RET
VECSET_VSYNC_LOAD	ENDP

CODE01	ENDS


;	V-SYNC interrapt routine.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

TMINT	PROC	FAR
	PUSH	DS
	PUSH	AX

;*DBG*;	MOV	AX,0A000H	; テキストマークの明滅
;*DBG*;	MOV	DS,AX		; text segment
;*DBG*;	MOV	AX,'@'		;
;*DBG*;	CMP	AX,DS:[2]	; text offset
;*DBG*;	JNZ	CS0203		;
;*DBG*;	MOV	AX,' '		;
;*DBG*;CS0203:			;
;*DBG*;	MOV	DS:[2],AX	;


	MOV	AX,SEG DATA
	MOV	DS,AX

	CMP	VSYNCC,0
	JZ	TMINT2
	DEC	VSYNCC
TMINT2:
	CMP	VSYNC2,0
	JZ	TMINT22
	DEC	VSYNC2
TMINT22:
	CMP	VSYNC3,0
	JZ	TMINT23
	DEC	VSYNC3
TMINT23:
	CMP	VSYNC4,0
	JZ	TMINT24
	DEC	VSYNC4
TMINT24:
	CMP	VSYNC5,0
	JZ	TMINT25
	DEC	VSYNC5
TMINT25:
	CMP	VSYNC6,0
	JZ	TMINT26
	DEC	VSYNC6
TMINT26:
	CMP	VSYNC7,0
	JZ	TMINT27
	DEC	VSYNC7
TMINT27:
	CMP	VSYNC8,0
	JZ	TMINT28
	DEC	VSYNC8
TMINT28:
	CMP	VSYNCJ,0
	JZ	TMINT299
	DEC	VSYNCJ
TMINT299:
	INC	VSYNCR	; V-SYNC run counter.

	CMP	VSYNCJ,1
	JE	TMINT_SET_JUMP

	PUSH	ES
	PUSH	DS
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	BP
	PUSH	SI
	PUSH	DI

	CALL	pmdvrt		; ＶＲＴＣ割込みでコールすること[PMD98]

	MOV	AX,SEG DATA		;
	MOV	DS,AX			;

;;;;;;;;;;;;;;;;;;;;;;;;
	TEST	BYTE PTR DS:KYTBLS[4],1000000B	; [F3] key on?
	JZ	TMINT3
	CALL	V98TMVCLR			; V-SYNC timer clear.
TMINT3:
;;;;;;;;;;;;;;;;;;;;;;;;

;*;	CMP	SP,STACK_CHECK_HI	; stack check hi-address.
;*;	JBE	TMINT41			;
;*;	MOV	STACK_CHECK_HI,SP	; stack check hi-address.
;*;TMINT41:				;
;*;
;*;	CMP	SP,STACK_CHECK_LOW	; stack check low-address.
;*;	JNB	TMINT42			;
;*;	MOV	STACK_CHECK_LOW,SP	; stack check low-address.
;*;TMINT42:				;

	;	キーボード・ロケーションを行なうためのタイミング取り用に
	;	ＫＥＹＭＵＳ（ＭＹＬＣ．ＡＳＭ）をコールしています

	CALL	KEYMUS		; ｷｰﾎﾞｰﾄﾞ･ﾛｹｰｼｮﾝをマウスドライバへセット

	CMP	PALET_SW,1	; 割込みスイッチ 0=OFF,1=ON
	JNE	TMINT66		;
	CALL	INTPLT		; パレット処理割込み(IPLMSG.ASM)
TMINT66:

;*NON*;	CALL	INTSND		; 複合効果音割込み(V-SYNC)

	CALL	INTMUS		; 音楽効果処理割込み(V-SYNC)

;*;	MOV	AX,SOUND_NUM	; 効果音番号
;*;	CMP	AX,0		; ＯＦＦ？
;*;	JE	TMINT77		;
;*;
;*;	INC	SOUND_TCNT	; 間隔時間カウンタ
;*;	MOV	AX,SOUND_TCNT	; 間隔時間カウンタ
;*;	CMP	AX,SOUND_TIME	; 間隔時間（Ｖ－ＳＹＮＣ）
;*;	JB	TMINT77		;
;*;
;*;	MOV	AX,SOUND_NUM	; 効果音番号
;*;	CALL	SNDONX		; 効果音発生(DSOUND.ASM)
;*;	MOV	SOUND_TCNT,0	; 間隔時間カウンタ
TMINT77:

	POP	DI
	POP	SI
	POP	BP
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POP	DS
	POP	ES



	MOV	AL,20H	; EOI send.
	OUT8259	00H,AL	;

	JMP	TMINT88
TMINT88:
	POP	AX
	POP	DS

	OUTGDC	64H,AL			; V-SYNC reset.

	IRET


TMINT_SET_JUMP:
	MOV	SS,SET_J_SS		; save SS
	MOV	SP,SET_J_SP		; save SP
	SUB	SP,6			; iret stack.

	; SS:SP [  I P  ] +0
	;       [  C S  ] +2
	;       [ flags ] +4

	MOV	BP,SP			;
	MOV	AX,SET_J_IP		; jump IP
	MOV	SS:[BP][0],AX		; [  I P  ] +0
	MOV	AX,SET_J_CS		; jump CS
	MOV	SS:[BP][2],AX		; [  C S  ] +2
	MOV	AX,SET_J_FLAGS		; save FLAGS
	MOV	SS:[BP][4],AX		; [ flags ] +4

	MOV	DS,SET_J_DS		; save DS


	MOV	AL,20H	; EOI send.
	OUT8259	00H,AL	;

	JMP	TMINT99
TMINT99:

	OUTGDC	64H,AL			; V-SYNC reset.

	IRET
TMINT	ENDP


TMINT_STOP	PROC	FAR
	PUSH	AX
	MOV	AL,20H	; EOI send.
	OUT8259	00H,AL	;

	POP	AX
	IRET
TMINT_STOP	ENDP

CODE01	ENDS



DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	KYTBLS:BYTE			;(V98KEYBO.ASM)

EXTRN	VSYNCC:WORD			; V-SYNC counter.
EXTRN	VSYNC2:WORD			; V-SYNC counter2.
EXTRN	VSYNC3:WORD			; V-SYNC counter3.
EXTRN	VSYNC4:WORD			; V-SYNC counter4.
EXTRN	VSYNC5:WORD			; V-SYNC counter4.
EXTRN	VSYNC6:WORD			; V-SYNC counter6.
EXTRN	VSYNC7:WORD			; V-SYNC counter7.
EXTRN	VSYNC8:WORD			; V-SYNC counter8.

		EVEN
VSYNCR		DW	0		; V-SYNC run counter.
VSYNCJ		DW	0		; V-SYNC set jump counter.

SAVE_VSYNCC	DW	0		; V-SYNC counter save.
SAVE_VSYNC2	DW	0		; V-SYNC counter2 save.
SAVE_VSYNC3	DW	0		; V-SYNC counter3 save.
SAVE_VSYNC4	DW	0		; V-SYNC counter4 save.
SAVE_VSYNC5	DW	0		; V-SYNC counter5 save.
SAVE_VSYNC6	DW	0		; V-SYNC counter6 save.
SAVE_VSYNC7	DW	0		; V-SYNC counter7 save.
SAVE_VSYNCR	DW	0		; V-SYNC run counter save.
SAVE_VSYNCJ	DW	0		; V-SYNC set jump counter save.

SAVE_IMR		DW	0	; IMR save area.
SAVE_VEC_CRTV_OFST	DW	0	; V-SYNC vector offset.
SAVE_VEC_CRTV_SEG	DW	0	; V-SYNC vector segment.

;*;STACK_CHECK_HI	DW	0	; stack check hi-address.
;*;STACK_CHECK_LOW	DW	0	; stack check low-address.

SET_J_SS		DW	0	; save SS
SET_J_SP		DW	0	; save SP
SET_J_CS		DW	0	; jump CS
SET_J_IP		DW	0	; jump IP
SET_J_DS		DW	0	; save DS
SET_J_FLAGS		DW	0	; save FLAGS

PALET_SW		DW	0	; 割込みスイッチ 0=OFF,1=ON

SOUND_NUM		DW	0	; 効果音番号
SOUND_TIME		DW	1	; 間隔時間（Ｖ－ＳＹＮＣ）
SOUND_TCNT		DW	0	; 間隔時間カウンタ

DATA	ENDS

	END
;
;	end of "V98TIMER.ASM"
;
