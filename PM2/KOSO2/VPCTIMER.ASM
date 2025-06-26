; "VPCTIMER.ASM" 1988/11/22 R.Hashimoto
;		1991/06/22 world-PC EGA & VGA.
;		1991/08/20 system timertick inttarapt test.
;		modify 1992/05/07 r.h
;
;
;	t i m e r   s e t .
;
;
; public subroutine.

INCLUDE	TSTSET.INC

TIMER_LOCK	MACRO
;*;	LOCAL	LL
;*;LL:	TEST	KYTBLS[2],80H	; [ｶﾅ] キーテーブル　＊＊＊＊＊＊
;*;	JNZ	LL		; デバックの為のロック
	ENDM

COUNT_REG_CH0		EQU	40H	; count register - channel 0.

OUT8253	MACRO	NUM,AA
;same;	OUT	NUM,AL
	PUSH	DX
	MOV	DX,NUM			;
	CALL	OUT_8253_PORT		; out prot 8253.
	POP	DX
	ENDM

OUT8259	MACRO	NUM,AA
;same;	OUT	NUM,AL
	PUSH	DX
	MOV	DX,NUM			;
	CALL	OUT_8259_PORT		; out port 8259.
	POP	DX
	ENDM

RETFAR	MACRO			; far return.
	DB	11001011B	; RETF
	ENDM

MOVX	MACRO	DEST,SOUR
	MOV	AX,SOUR
	MOV	DEST,AX
	ENDM

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	VPCTMWAIT		; time wait.
PUBLIC	VPCTMVSRT		; V-SYNC timer start.
PUBLIC	VPCTMVEND		; V-SYNC timer end.
PUBLIC	VPCTMVWAT		; V-SYNC timer wait.
PUBLIC	VPCTMVSET		; V-SYNC timer set.
PUBLIC	VPCTMVCHK		; V-SYNC timer check.
PUBLIC	VPCTMVEWT		; V-SYNC timer end wait.
PUBLIC	VPCTMVST2		; V-SYNC timer2 set.
PUBLIC	VPCTMVCK2		; V-SYNC timer2 check.
PUBLIC	VPCTMVST3		; V-SYNC timer3 set.
PUBLIC	VPCTMVCK3		; V-SYNC timer3 check.
PUBLIC	VPCTMVWT4		; V-SYNC timer4 wait.
PUBLIC	VPCTMVST5		; V-SYNC timer5 set.
PUBLIC	VPCTMVCK5		; V-SYNC timer5 check.
PUBLIC	VPCTMVST6		; V-SYNC timer6 set.(use:MOUSE.ASM)
PUBLIC	VPCTMVCK6		; V-SYNC timer6 check.(use:MOUSE.ASM)
PUBLIC	VPCTMVST7		; V-SYNC timer7 set.(use:WWANIME.ASM)
PUBLIC	VPCTMVCK7		; V-SYNC timer7 check.(use:WWANIME.ASM)
PUBLIC	VPCTMVST8		; V-SYNC timer8 set.(use:CHILD.ASM)
PUBLIC	VPCTMVCK8		; V-SYNC timer8 check.(use:CHILD.ASM)
PUBLIC	VPCTMVCLR		; V-SYNC timer clear.
PUBLIC	VPCTMVSTP		; V-SYNC timer stop.
PUBLIC	VPCTMVCNT		; V-SYNC timer cont.
PUBLIC	VPCTMVRND		; V-SYNC timer run counter read.
PUBLIC	VPCTMVSAV		; V-SYNC timer value save.
PUBLIC	VPCTMVLOD		; V-SYNC timer value load.

PUBLIC	VPCTMVPLT		; V-SYNC timer pallet program call.
PUBLIC	VPCTMVPMD		; V-SYNC timer PMD program call.
PUBLIC	VPCTMVLOW		; V-SYNC timer low time.

EXTRN	KEYMUS:NEAR		; ｷｰﾎﾞｰﾄﾞ･ﾛｹｰｼｮﾝをマウスドライバへセット
;*;EXTRN PMDVRT:NEAR		; ＶＲＴＣ割込みでコールすること
EXTRN	INTPLT:NEAR		; パレット処理割込み(IPLMSG.ASM)
;*;EXTRN INTCLRVSET:NEAR	; interactive color palet disply(ADVPLT)

EXTRN	OUT_8259_PORT:NEAR	; out port 8259.
EXTRN	OUT_8253_PORT:NEAR	; out prot 8253.


;	time wait.
;	-I- DX : time.

VPCTMWAIT	PROC	NEAR
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

VPCTMWAIT	ENDP


;	V-SYNC timer start.

VPCTMVSRT	PROC	NEAR
	CALL	VECSET_SSTIME_SAVE	; vector save.
	CALL	VECSET_SSTIME		; int vector set.
	CLI
	MOV	AL,0AEH		; 60(72.8)tick/second = 1193180Mhz / 4000h
	OUT8253	COUNT_REG_CH0		; count register - channel 0.
	MOV	AL,04DH			; 58=505Ch,60=4DAEh,72.8=4000h
	OUT8253	COUNT_REG_CH0		; count register - channel 0.
	MOV	TIMER_SKIP_CNT,0	; timer skip counter.
	STI
	RET
VPCTMVSRT	ENDP


;	timer end.

VPCTMVEND	PROC	NEAR
	CALL	VECSET_SSTIME_LOAD	; vector load.
	CLI
	MOV	AL,00H			; 18.2tick/second = 1193180Mhz / 65536
	OUT8253	COUNT_REG_CH0		; count register - channel 0.
	MOV	AL,00H			;
	OUT8253	COUNT_REG_CH0		; count register - channel 0.
	STI
	RET
VPCTMVEND	ENDP


;	V-SYNC timer wait.
;	-I- AX : wait timer count.

VPCTMVWAT	PROC	NEAR
	MOV	WORD PTR VSYNCC,AX
TMVWAT1:
	TIMER_LOCK

	CMP	WORD PTR VSYNCC,0
	JNZ	TMVWAT1
	RET
VPCTMVWAT	ENDP



;	V-SYNC timer set.
;	-I- AX : wait timer count.

VPCTMVSET	PROC	NEAR
	MOV	WORD PTR VSYNCC,AX
	RET
VPCTMVSET	ENDP



;	V-SYNC timer check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

VPCTMVCHK	PROC	NEAR
	TIMER_LOCK

	MOV	DX,VSYNCC
	CMP	DX,0
	JZ	TMVCHK1
	MOV	AX,0		; 0=timer now.
	RET
TMVCHK1:
	MOV	AX,1		; 1=timer end.
	RET
VPCTMVCHK	ENDP


;	V-SYNC timer end wait.

VPCTMVEWT	PROC	NEAR
TMVEWT1:
	TIMER_LOCK

	CMP	WORD PTR VSYNCC,0
	JNZ	TMVEWT1
	RET
VPCTMVEWT	ENDP


;	V-SYNC timer2 set.
;	-I- AX : wait timer count.

VPCTMVST2	PROC	NEAR
	MOV	WORD PTR VSYNC2,AX
	RET
VPCTMVST2	ENDP



;	V-SYNC timer2 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

VPCTMVCK2	PROC	NEAR
	TIMER_LOCK

	MOV	DX,VSYNC2
	CMP	DX,0
	JZ	TMVCK21
	MOV	AX,0		; 0=timer now.
	RET
TMVCK21:
	MOV	AX,1		; 1=timer end.
	RET
VPCTMVCK2	ENDP



;	V-SYNC timer3 set.
;	-I- AX : wait timer count.

VPCTMVST3	PROC	NEAR
	MOV	WORD PTR VSYNC3,AX
	RET
VPCTMVST3	ENDP



;	V-SYNC timer3 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

VPCTMVCK3	PROC	NEAR
	TIMER_LOCK

	MOV	DX,VSYNC3
	CMP	DX,0
	JZ	TMVCK31
	MOV	AX,0		; 0=timer now.
	RET
TMVCK31:
	MOV	AX,1		; 1=timer end.
	RET
VPCTMVCK3	ENDP



;	V-SYNC timer4 wait.
;	-I- AX : wait timer count.

VPCTMVWT4	PROC	NEAR
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
VPCTMVWT4	ENDP



;	V-SYNC timer5 set.
;	-I- AX : wait timer count.

VPCTMVST5	PROC	NEAR
	MOV	WORD PTR VSYNC5,AX
	RET
VPCTMVST5	ENDP



;	V-SYNC timer5 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

VPCTMVCK5	PROC	NEAR
	MOV	DX,VSYNC5
	CMP	DX,0
	JZ	TMVCK51
	MOV	AX,0		; 0=timer now.
	RET
TMVCK51:
	MOV	AX,1		; 1=timer end.
	RET
VPCTMVCK5	ENDP


;	V-SYNC timer6 set.
;	-I- AX : wait timer count.

VPCTMVST6	PROC	NEAR
	MOV	WORD PTR VSYNC6,AX
	RET
VPCTMVST6	ENDP


;	V-SYNC timer6 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

VPCTMVCK6	PROC	NEAR
	MOV	DX,VSYNC6
	CMP	DX,0
	JZ	TMVCK61
	MOV	AX,0		; 0=timer now.
	RET
TMVCK61:
	MOV	AX,1		; 1=timer end.
	RET
VPCTMVCK6	ENDP


;	V-SYNC timer7 set.
;	-I- AX : wait timer count.

VPCTMVST7	PROC	NEAR
	MOV	WORD PTR VSYNC7,AX
	RET
VPCTMVST7	ENDP


;	V-SYNC timer7 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

VPCTMVCK7	PROC	NEAR
	MOV	DX,VSYNC7
	CMP	DX,0
	JZ	TMVCK71
	MOV	AX,0		; 0=timer now.
	RET
TMVCK71:
	MOV	AX,1		; 1=timer end.
	RET
VPCTMVCK7	ENDP


;	V-SYNC timer8 set.
;	-I- AX : wait timer count.

VPCTMVST8	PROC	NEAR
	MOV	WORD PTR VSYNC8,AX
	RET
VPCTMVST8	ENDP


;	V-SYNC timer8 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

VPCTMVCK8	PROC	NEAR
	MOV	DX,VSYNC8
	CMP	DX,0
	JZ	TMVCK81
	MOV	AX,0		; 0=timer now.
	RET
TMVCK81:
	MOV	AX,1		; 1=timer end.
	RET
VPCTMVCK8	ENDP


;	V-SYNC timer clear.

VPCTMVCLR	PROC	NEAR
	MOV	VSYNCC,0		; V-SYNC counter.
	MOV	VSYNC2,0		; V-SYNC counter2.
	MOV	VSYNC3,0		; V-SYNC counter3.
	MOV	VSYNC4,0		; V-SYNC counter4.
;;	MOV	VSYNC5,0		; V-SYNC counter5.
	MOV	VSYNC6,0		; V-SYNC counter6.
	MOV	VSYNC7,0		; V-SYNC counter7.
	RET
VPCTMVCLR	ENDP


;	V-SYNC timer stop.

VPCTMVSTP	PROC	NEAR
	CALL	VECSET_SSTIME_LOAD	; vector load.
	RET
VPCTMVSTP	ENDP


;	V-SYNC timer cont.

VPCTMVCNT	PROC	NEAR
	CALL	VECSET_SSTIME		; int vector set.
	RET
VPCTMVCNT	ENDP


;	V-SYNC timer run counter read.
;	-O- AX : now counter.

VPCTMVRND	PROC	NEAR
	MOV	AX,WORD PTR DS:[VSYNCR]	; V-SYNC run counter.
	RET
VPCTMVRND	ENDP


;	V-SYNC timer value save.

VPCTMVSAV	PROC	NEAR
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
VPCTMVSAV	ENDP


;	V-SYNC timer value load.

VPCTMVLOD	PROC	NEAR
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
VPCTMVLOD	ENDP


; V-SYNC timer pallet program call.
; -I- AX : 割込みスイッチ 0=OFF,1=ON

VPCTMVPLT	PROC	NEAR
	MOV	PALET_SW,AX		; 割込みスイッチ 0=OFF,1=ON
	RET
VPCTMVPLT	ENDP


; V-SYNC timer PMD program call.
; -I- AX : ＰＭＤスイッチ 0=OFF,1=ON

VPCTMVPMD	PROC	NEAR
	MOV	PMD_SW,AX		; ＰＭＤスイッチ 0=OFF,1=ON
	RET
VPCTMVPMD	ENDP


;	V-SYNC timer low timer.

VPCTMVLOW	PROC	NEAR
	CLI
	MOV	AL,000H		; 58(72.8)tick/second = 1193180Mhz / 5000h
	OUT8253	COUNT_REG_CH0		; count register - channel 0.
	MOV	AL,050H			; 58=5000h,60=4DAEh,72.8=4000h
	OUT8253	COUNT_REG_CH0		; count register - channel 0.
	MOV	TIMER_SKIP_CNT,0	; timer skip counter.
	STI
	RET
VPCTMVLOW	ENDP


VEC_SSTIME_OFST	EQU	20H		; int 08h
VEC_SSTIME_SEG	EQU	22H		;

;	int vector set.

VECSET_SSTIME	PROC	NEAR
	CLI
	MOV	AX,0			; 0 base.
	MOV	ES,AX			;
	MOV	WORD PTR ES:[VEC_SSTIME_OFST],OFFSET SSTIMEINT
	MOV	WORD PTR ES:[VEC_SSTIME_SEG],SEG CODE01
	STI
	RET
VECSET_SSTIME	ENDP

;	vector save.

VECSET_SSTIME_SAVE	PROC	NEAR
	CLI
	MOV	AX,0			; 0 base.
	MOV	ES,AX			;
	MOVX	SAVE_VEC_SSTIME_OFST,<WORD PTR ES:[VEC_SSTIME_OFST]>
	MOVX	SAVE_VEC_SSTIME_SEG,<WORD PTR ES:[VEC_SSTIME_SEG]>
	STI
	RET
VECSET_SSTIME_SAVE	ENDP

;	vector load.

VECSET_SSTIME_LOAD	PROC	NEAR
	CLI
	MOV	AX,0			; 0 base.
	MOV	ES,AX			;
	MOVX	<WORD PTR ES:[VEC_SSTIME_OFST]>,SAVE_VEC_SSTIME_OFST
	MOVX	<WORD PTR ES:[VEC_SSTIME_SEG]>,SAVE_VEC_SSTIME_SEG
	STI
	RET
VECSET_SSTIME_LOAD	ENDP

CODE01	ENDS


;	V-SYNC interrapt routine.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

;	V-SYNC interrapt routine.

SSTIMEINT	PROC	FAR
	PUSH	DS
	PUSH	ES
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	BP
	PUSH	SI
	PUSH	DI

	MOV	AX,SEG DATA
	MOV	DS,AX

;;;;;;;;;;;;;;;;;;;;;;;;
	TEST	BYTE PTR DS:KYTBLS[13],1000B	; [F3] key on?
	JZ	TMINT1
	CALL	VPCTMVCLR			; V-SYNC timer clear.
TMINT1:
;;;;;;;;;;;;;;;;;;;;;;;;

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

;*;	CMP	PMD_SW,1		; ＰＭＤスイッチ 0=OFF,1=ON
;*;	JNE	TMINT300		;
;*;	CALL	PMDVRT			; ＶＲＴＣ割込みでコールすること
;*;TMINT300:				;

;*;	CALL	INTCLRVSET	; interactive color palet disply(ADVPLT)

	CALL	KEYMUS		; ｷｰﾎﾞｰﾄﾞ･ﾛｹｰｼｮﾝをマウスドライバへセット

	CMP	PALET_SW,1	; 割込みスイッチ 0=OFF,1=ON
	JNE	TIMEINT_33	;
	CALL	INTPLT		; パレット処理割込み(IPLMSG.ASM)
TIMEINT_33:

	MOV	AX,SEG DATA			;
	MOV	DS,AX				;

	INC	TIMER_SKIP_CNT			; timer skip counter.
	CMP	TIMER_SKIP_CNT,4		; timer skip counter.
	JNB	SSTIMEINT_182TICK_INT		;

	MOV	AL,20H				; EOI send.
	OUT8259	20H				;
	JMP	SSTIMEINT_INTER			;

SSTIMEINT_182TICK_INT:				;
	MOV	TIMER_SKIP_CNT,0		; timer skip counter.

	MOV	AX,OFFSET SSTIMEINT_INTER	;
	PUSHF					;[ flags       ]
	PUSH	CS				;[ ret segment ]
	PUSH	AX				;[ ret offset  ]

	MOV	AX,SAVE_VEC_SSTIME_SEG		; save vector segment.
	MOV	BX,SAVE_VEC_SSTIME_OFST		; save vector offset.
	PUSH	AX				;
	PUSH	BX				;
	RETFAR					; ＦＡＲリターン
SSTIMEINT_INTER:				;
	POP	DI
	POP	SI
	POP	BP
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POP	ES
	POP	DS
	IRET
SSTIMEINT	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	KYTBLS:BYTE			; key code table.

EXTRN	VSYNCC:WORD			; V-SYNC counter.
EXTRN	VSYNC2:WORD			; V-SYNC counter2.
EXTRN	VSYNC3:WORD			; V-SYNC counter3.
EXTRN	VSYNC4:WORD			; V-SYNC counter4.
EXTRN	VSYNC5:WORD			; V-SYNC counter5.
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

FOOK_SSTIME_FAR	LABEL	DWORD		; system time int vector.
SAVE_VEC_SSTIME_OFST	DW	0	; save vector offset.
SAVE_VEC_SSTIME_SEG	DW	0	; save vector segment.

TIMER_SKIP_CNT	DW	0		; timer skip counter.

PALET_SW	DW	0		; 割込みスイッチ 0=OFF,1=ON
PMD_SW		DW	0		; ＰＭＤスイッチ 0=OFF,1=ON

DATA	ENDS

	END
;
;	end of "VPCTIMER.ASM"
;
