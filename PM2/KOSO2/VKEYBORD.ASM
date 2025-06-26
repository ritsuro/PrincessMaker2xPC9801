; "VKEYBORD.ASM"  486/33 make by R.H 1992/04/08
;
;
;
;	KEYBORD I/O.
;
;
;
; public subroutine.

INCLUDE	MACHINEX.INC

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	KYBSRT			; keybord start.
PUBLIC	KYBEND			; keybord end.
PUBLIC	KYBSTP			; keybord stop.
PUBLIC	KYBCNT			; keybord cont.
PUBLIC	KYBONS			; keybord STOP key on.
PUBLIC	KYBOFS			; keybord STOP key off.

;	PC/AT.

EXTRN	VPCKYBSRT:NEAR		; keybord start.
EXTRN	VPCKYBEND:NEAR		; keybord end.
EXTRN	VPCKYBSTP:NEAR		; keybord stop.
EXTRN	VPCKYBCNT:NEAR		; keybord cont.
EXTRN	VPCKYBONS:NEAR		; keybord STOP key on.
EXTRN	VPCKYBOFS:NEAR		; keybord STOP key off.

;	PC9801.

EXTRN	V98KYBSRT:NEAR		; keybord start.
EXTRN	V98KYBEND:NEAR		; keybord end.
EXTRN	V98KYBSTP:NEAR		; keybord stop.
EXTRN	V98KYBCNT:NEAR		; keybord cont.
EXTRN	V98KYBONS:NEAR		; keybord STOP key on.
EXTRN	V98KYBOFS:NEAR		; keybord STOP key off.


;	keybord start.

KYBSRT	PROC	NEAR
	MACHINE_CALL	VPCKYBSRT,V98KYBSRT	; keybord start.
	RET
KYBSRT	ENDP

;	keybord end.

KYBEND	PROC	NEAR
	MACHINE_CALL	VPCKYBEND,V98KYBEND	; keybord start.
	RET
KYBEND	ENDP

;	keybord stop.

KYBSTP	PROC	NEAR
	MACHINE_CALL	VPCKYBSTP,V98KYBSTP	; keybord start.
	RET
KYBSTP	ENDP

;	keybord cont.

KYBCNT	PROC	NEAR
	MACHINE_CALL	VPCKYBCNT,V98KYBCNT	; keybord start.
	RET
KYBCNT	ENDP

;	keybord STOP key on.

KYBONS	PROC	NEAR
	MACHINE_CALL	VPCKYBONS,V98KYBONS	; keybord start.
	RET
KYBONS	ENDP

;	keybord STOP key off.

KYBOFS	PROC	NEAR
	MACHINE_CALL	VPCKYBOFS,V98KYBOFS	; keybord start.
	RET
KYBOFS	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	KYDRX			; key locate direction x(+-)
PUBLIC	KYDRY			; key locate direction y(+-)
PUBLIC	KYONL			; key left  bottan.(0=ON)
PUBLIC	KYONR			; key right bottan.(0=ON)
KYDRX	DW	0		; key locate direction x(+-)
KYDRY	DW	0		; key locate direction y(+-)
KYONL	DW	1		; key left  bottan.(0=ON)
KYONR	DW	1		; key right bottan.(0=ON)

PUBLIC	KYTBLS				; key code table.
KYTBLS	 LABEL	BYTE
	DB	0	;0
	DB	0	;1
	DB	0	;2
	DB	0	;3
	DB	0	;4
	DB	0	;5
	DB	0	;6
	DB	0	;7
	DB	0	;8
	DB	0	;9
	DB	0	;A
	DB	0	;B
	DB	0	;C
	DB	0	;D
	DB	0	;E
	DB	0	;F


DATA	ENDS

	END
;
;	end of "VKEYBORD.ASM"
;
