; "VTIMER.ASM" 486/33 make by R.H 1992/05/07 dual machine.
;
;
;	1/60sec  T I M E R
;
;
; public soubroutine.

INCLUDE	MACHINEX.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	TMWAIT		; time wait.
PUBLIC	TMVSRT		; V-SYNC timer start.
PUBLIC	TMVEND		; V-SYNC timer end.
PUBLIC	TMVWAT		; V-SYNC timer wait.
PUBLIC	TMVSET		; V-SYNC timer set.
PUBLIC	TMVCHK		; V-SYNC timer check.
PUBLIC	TMVEWT		; V-SYNC timer end wait.
PUBLIC	TMVST2		; V-SYNC timer2 set.
PUBLIC	TMVCK2		; V-SYNC timer2 check.
PUBLIC	TMVST3		; V-SYNC timer3 set.
PUBLIC	TMVCK3		; V-SYNC timer3 check.
PUBLIC	TMVWT4		; V-SYNC timer4 wait.(dskch2.asm)
PUBLIC	TMVST5		; V-SYNC timer5 set.(child.asm)
PUBLIC	TMVCK5		; V-SYNC timer5 check.
PUBLIC	TMVST6		; V-SYNC timer6 set.(muscor.asm)
PUBLIC	TMVCK6		; V-SYNC timer6 check.
PUBLIC	TMVST7		; V-SYNC timer7 set.(wwanime.asm/dmusic.asm)
PUBLIC	TMVCK7		; V-SYNC timer7 check.
PUBLIC	TMVST8		; V-SYNC timer8 set.(child.asm)
PUBLIC	TMVCK8		; V-SYNC timer8 check.
PUBLIC	TMVCLR		; V-SYNC timer clear.
PUBLIC	TMVSTP		; V-SYNC timer stop.
PUBLIC	TMVCNT		; V-SYNC timer cont.
PUBLIC	TMVRND		; V-SYNC timer run counter read.
PUBLIC	TMVSAV		; V-SYNC timer value save.
PUBLIC	TMVLOD		; V-SYNC timer value load.
PUBLIC	TMVPLT		; V-SYNC timer pallet program call.

;	PC/AT.

EXTRN	VPCTMWAIT:NEAR	; time wait.
EXTRN	VPCTMVSRT:NEAR	; V-SYNC timer start.
EXTRN	VPCTMVEND:NEAR	; V-SYNC timer end.
EXTRN	VPCTMVWAT:NEAR	; V-SYNC timer wait.
EXTRN	VPCTMVSET:NEAR	; V-SYNC timer set.
EXTRN	VPCTMVCHK:NEAR	; V-SYNC timer check.
EXTRN	VPCTMVEWT:NEAR	; V-SYNC timer end wait.
EXTRN	VPCTMVST2:NEAR	; V-SYNC timer2 set.
EXTRN	VPCTMVCK2:NEAR	; V-SYNC timer2 check.
EXTRN	VPCTMVST3:NEAR	; V-SYNC timer3 set.
EXTRN	VPCTMVCK3:NEAR	; V-SYNC timer3 check.
EXTRN	VPCTMVWT4:NEAR	; V-SYNC timer4 wait.
EXTRN	VPCTMVST5:NEAR	; V-SYNC timer5 set.
EXTRN	VPCTMVCK5:NEAR	; V-SYNC timer5 check.
EXTRN	VPCTMVST6:NEAR	; V-SYNC timer6 set.(use:MOUSE.ASM)
EXTRN	VPCTMVCK6:NEAR	; V-SYNC timer6 check.(use:MOUSE.ASM)
EXTRN	VPCTMVST7:NEAR	; V-SYNC timer7 set.(use:WWANIME.ASM)
EXTRN	VPCTMVCK7:NEAR	; V-SYNC timer7 check.(use:WWANIME.ASM)
EXTRN	VPCTMVST8:NEAR	; V-SYNC timer8 set.(use:CHILD.ASM)
EXTRN	VPCTMVCK8:NEAR	; V-SYNC timer8 check.(use:CHILD.ASM)
EXTRN	VPCTMVCLR:NEAR	; V-SYNC timer clear.
EXTRN	VPCTMVSTP:NEAR	; V-SYNC timer stop.
EXTRN	VPCTMVCNT:NEAR	; V-SYNC timer cont.
EXTRN	VPCTMVRND:NEAR	; V-SYNC timer run counter read.
EXTRN	VPCTMVSAV:NEAR	; V-SYNC timer value save.
EXTRN	VPCTMVLOD:NEAR	; V-SYNC timer value load.
EXTRN	VPCTMVPLT:NEAR	; V-SYNC timer pallet program call.

EXTRN	VPCTMVPMD:NEAR	; V-SYNC timer PMD program call.
EXTRN	VPCTMVLOW:NEAR	; V-SYNC timer low time.

;	PC9801.

EXTRN	V98TMWAIT:NEAR	; time wait.
EXTRN	V98TMVSRT:NEAR	; V-SYNC timer start.
EXTRN	V98TMVEND:NEAR	; V-SYNC timer end.
EXTRN	V98TMVWAT:NEAR	; V-SYNC timer wait.
EXTRN	V98TMVSET:NEAR	; V-SYNC timer set.
EXTRN	V98TMVCHK:NEAR	; V-SYNC timer check.
EXTRN	V98TMVEWT:NEAR	; V-SYNC timer end wait.
EXTRN	V98TMVST2:NEAR	; V-SYNC timer2 set.
EXTRN	V98TMVCK2:NEAR	; V-SYNC timer2 check.
EXTRN	V98TMVST3:NEAR	; V-SYNC timer3 set.
EXTRN	V98TMVCK3:NEAR	; V-SYNC timer3 check.
EXTRN	V98TMVWT4:NEAR	; V-SYNC timer4 wait.
EXTRN	V98TMVST5:NEAR	; V-SYNC timer5 set.
EXTRN	V98TMVCK5:NEAR	; V-SYNC timer5 check.
EXTRN	V98TMVST6:NEAR	; V-SYNC timer6 set.(use:MOUSE.ASM)
EXTRN	V98TMVCK6:NEAR	; V-SYNC timer6 check.(use:MOUSE.ASM)
EXTRN	V98TMVST7:NEAR	; V-SYNC timer7 set.(use:WWANIME.ASM)
EXTRN	V98TMVCK7:NEAR	; V-SYNC timer7 check.(use:WWANIME.ASM)
EXTRN	V98TMVST8:NEAR	; V-SYNC timer8 set.(use:CHILD.ASM)
EXTRN	V98TMVCK8:NEAR	; V-SYNC timer8 check.(use:CHILD.ASM)
EXTRN	V98TMVCLR:NEAR	; V-SYNC timer clear.
EXTRN	V98TMVSTP:NEAR	; V-SYNC timer stop.
EXTRN	V98TMVCNT:NEAR	; V-SYNC timer cont.
EXTRN	V98TMVRND:NEAR	; V-SYNC timer run counter read.
EXTRN	V98TMVSAV:NEAR	; V-SYNC timer value save.
EXTRN	V98TMVLOD:NEAR	; V-SYNC timer value load.
EXTRN	V98TMVPLT:NEAR	; V-SYNC timer pallet program call.


;	time wait.
;	-I- DX : time.

TMWAIT	PROC	NEAR
	MACHINE_CALL	VPCTMWAIT,V98TMWAIT	; time wait.
	RET
TMWAIT	ENDP


;	V-SYNC timer start.

TMVSRT	PROC	NEAR
	MACHINE_CALL	VPCTMVSRT,V98TMVSRT	; V-SYNC timer start.
	RET
TMVSRT	ENDP


;	timer end.

TMVEND	PROC	NEAR
	MACHINE_CALL	VPCTMVEND,V98TMVEND	; V-SYNC timer end.
	RET
TMVEND	ENDP


;	V-SYNC timer wait.
;	-I- AX : wait timer count.

TMVWAT	PROC	NEAR
	MACHINE_CALL	VPCTMVWAT,V98TMVWAT	; V-SYNC timer wait.
	RET
TMVWAT	ENDP


;	V-SYNC timer set.
;	-I- AX : wait timer count.

TMVSET	PROC	NEAR
	MACHINE_CALL	VPCTMVSET,V98TMVSET	; V-SYNC timer set.
	RET
TMVSET	ENDP


;	V-SYNC timer check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

TMVCHK	PROC	NEAR
	MACHINE_CALL	VPCTMVCHK,V98TMVCHK	; V-SYNC timer check.
	RET
TMVCHK	ENDP


;	V-SYNC timer end wait.

TMVEWT	PROC	NEAR
	MACHINE_CALL	VPCTMVEWT,V98TMVEWT	; V-SYNC timer end wait.
	RET
TMVEWT	ENDP


;	V-SYNC timer2 set.
;	-I- AX : wait timer count.

TMVST2	PROC	NEAR
	MACHINE_CALL	VPCTMVST2,V98TMVST2	; V-SYNC timer2 set.
	RET
TMVST2	ENDP


;	V-SYNC timer2 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

TMVCK2	PROC	NEAR
	MACHINE_CALL	VPCTMVCK2,V98TMVCK2	; V-SYNC timer2 check.
	RET
TMVCK2	ENDP


;	V-SYNC timer3 set.
;	-I- AX : wait timer count.

TMVST3	PROC	NEAR
	MACHINE_CALL	VPCTMVST3,V98TMVST3	; V-SYNC timer3 set.
	RET
TMVST3	ENDP


;	V-SYNC timer3 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

TMVCK3	PROC	NEAR
	MACHINE_CALL	VPCTMVCK3,V98TMVCK3	; V-SYNC timer3 check.
	RET
TMVCK3	ENDP


;	V-SYNC timer4 wait.
;	-I- AX : wait timer count.

TMVWT4	PROC	NEAR
	MACHINE_CALL	VPCTMVWT4,V98TMVWT4	; V-SYNC timer4 wait.
	RET
TMVWT4	ENDP


;	V-SYNC timer5 set.
;	-I- AX : wait timer count.

TMVST5	PROC	NEAR
	MACHINE_CALL	VPCTMVST5,V98TMVST5	; V-SYNC timer5 set.
	RET
TMVST5	ENDP


;	V-SYNC timer5 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

TMVCK5	PROC	NEAR
	MACHINE_CALL	VPCTMVCK5,V98TMVCK5	; V-SYNC timer5 check.
	RET
TMVCK5	ENDP


;	V-SYNC timer6 set.
;	-I- AX : wait timer count.

TMVST6	PROC	NEAR
	MACHINE_CALL	VPCTMVST6,V98TMVST6	; V-SYNC timer6 set.
	RET
TMVST6	ENDP


;	V-SYNC timer6 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

TMVCK6	PROC	NEAR
	MACHINE_CALL	VPCTMVCK6,V98TMVCK6	; V-SYNC timer6 check.
	RET
TMVCK6	ENDP


;	V-SYNC timer7 set.
;	-I- AX : wait timer count.

TMVST7	PROC	NEAR
	MACHINE_CALL	VPCTMVST7,V98TMVST7	; V-SYNC timer7 set.
	RET
TMVST7	ENDP


;	V-SYNC timer7 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

TMVCK7	PROC	NEAR
	MACHINE_CALL	VPCTMVCK7,V98TMVCK7	; V-SYNC timer7 check.
	RET
TMVCK7	ENDP


;	V-SYNC timer8 set.(child.asm)
;	-I- AX : wait timer count.

TMVST8	PROC	NEAR
	MACHINE_CALL	VPCTMVST8,V98TMVST8	; V-SYNC timer8 set.
	RET
TMVST8	ENDP


;	V-SYNC timer8 check.
;	-O- AX : 0=timer now, 1=timer end.
;	    DX : now counter.

TMVCK8	PROC	NEAR
	MACHINE_CALL	VPCTMVCK8,V98TMVCK8	; V-SYNC timer8 check.
	RET
TMVCK8	ENDP


;	V-SYNC timer clear.

TMVCLR	PROC	NEAR
	MACHINE_CALL	VPCTMVCLR,V98TMVCLR	; V-SYNC timer clear.
	RET
TMVCLR	ENDP


;	V-SYNC timer stop.

TMVSTP	PROC	NEAR
	MACHINE_CALL	VPCTMVSTP,V98TMVSTP	; V-SYNC timer stop.
	RET
TMVSTP	ENDP


;	V-SYNC timer cont.

TMVCNT	PROC	NEAR
	MACHINE_CALL	VPCTMVCNT,V98TMVCNT	; V-SYNC timer cont.
	RET
TMVCNT	ENDP


;	V-SYNC timer run counter read.
;	-O- AX : now counter.

TMVRND	PROC	NEAR
	MACHINE_CALL	VPCTMVRND,V98TMVRND	; V-SYNC timer run counter read.
	RET
TMVRND	ENDP


;	V-SYNC timer value save.

TMVSAV	PROC	NEAR
	MACHINE_CALL	VPCTMVSAV,V98TMVSAV	; V-SYNC timer value save.
	RET
TMVSAV	ENDP


;	V-SYNC timer value load.

TMVLOD	PROC	NEAR
	MACHINE_CALL	VPCTMVLOD,V98TMVLOD	; V-SYNC timer value load.
	RET
TMVLOD	ENDP


;	V-SYNC timer pallet program call.
;	-I- AX : 割込みスイッチ 0=OFF,1=ON

TMVPLT	PROC	NEAR
	MACHINE_CALL	VPCTMVPLT,V98TMVPLT ; V-SYNC timer pallet program call.
	RET
TMVPLT	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	VSYNCC				; V-SYNC counter.
PUBLIC	VSYNC2				; V-SYNC counter2.
PUBLIC	VSYNC3				; V-SYNC counter3.
PUBLIC	VSYNC4				; V-SYNC counter4.
PUBLIC	VSYNC5				; V-SYNC counter5.
PUBLIC	VSYNC6				; V-SYNC counter6.
PUBLIC	VSYNC7				; V-SYNC counter7.
PUBLIC	VSYNC8				; V-SYNC counter8.

VSYNCC		DW	0		; V-SYNC counter.
VSYNC2		DW	0		; V-SYNC counter2.
VSYNC3		DW	0		; V-SYNC counter3.
VSYNC4		DW	0		; V-SYNC counter4.
VSYNC5		DW	0		; V-SYNC counter5.
VSYNC6		DW	0		; V-SYNC counter6.
VSYNC7		DW	0		; V-SYNC counter7.
VSYNC8		DW	0		; V-SYNC counter8.

DATA	ENDS

	END
;
;	end of "VTIMER.ASM"
;
