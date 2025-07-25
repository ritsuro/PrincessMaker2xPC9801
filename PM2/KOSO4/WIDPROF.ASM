; "WIDPROF.ASM" 486/50 make by R.H 1992/12/15
;
;
;	vhmcnvr^vtB[EEChE
;
;	WIDPROF_SET		; WINDOWS/vtB[E\¦
;	WIDPROF_SHOW		; WINDOWS/vtB[EΔ\¦
;	WIDPROF_GOLD		; WINDOWS/vtB[Eΰ
;	WIDPROF_AGE		; WINDOWS/vtB[ENξ
;
;	WIDPROF_R_GOLD		; WINDOWS/ΜίΫΜ¨°ΩRPG₯ΰ
;	WIDPROF_R_HP		; WINDOWS/ΜίΫΜ¨°ΩRPG₯HP
;	WIDPROF_R_MP		; WINDOWS/ΜίΫΜ¨°ΩRPG₯MP
;	WIDPROF_R_ARMS		; WINDOWS/ΜίΫΜ¨°ΩRPG₯υ
;
;
;
; (C) 1992 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC
INCLUDE	MACHINEX.INC

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA

; ****************************************************
;	WINDOWS/vtB[E\¦
; ****************************************************

FUNC	WIDPROF_SET
	CALL_w	PT_PROFILE_LD		; profile load.
	CALL_w	PT_PROFILE_FRM		; profile fream.
	CALL	ALL_SHOW		; all show.
	RET
FEND	WIDPROF_SET


; ****************************************************
;	WINDOWS/vtB[EΔ\¦
; ****************************************************

FUNC	WIDPROF_SHOW
;*;	CALL_w	PT_PROFILE_FRM		; profile fream.
	CALL	ALL_SHOW		; all show.
	RET
FEND	WIDPROF_SHOW


; ****************************************************
;	WINDOWS/vtB[Eΰ
; ****************************************************

FUNC	WIDPROF_GOLD
	MOV	AX,GOLD_GIRL		; ΊΜΰ
	MOV	DX,GOLD_GIRL[2]		; ΊΜΰ
	CALL_w	PT_PROFILE_GOLD		; profile gold.
	RET
FEND	WIDPROF_GOLD


; ****************************************************
;	WINDOWS/vtB[ENξ
; ****************************************************

FUNC	WIDPROF_AGE
	MOV	AX,P_NENREI		; Nξ
	CALL_w	PT_PROFILE_AGE		; profile age.
	RET
FEND	WIDPROF_AGE


; ****************************************************
;	WINDOWS/ΜίΫΜ¨°ΩRPG₯ΰ
; ****************************************************

FUNC	WIDPROF_R_GOLD
	MOV	AX,GOLD_GIRL		; ΊΜΰ
	MOV	DX,GOLD_GIRL[2]		; ΊΜΰ
	CALL_w	PT_RPGPROF_GOLD		; RPG profile gold.

	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	WIDPROF_R_GOLD_6	;
	RET
WIDPROF_R_GOLD_6:
	CALL_w	VRM98NOW		; PC98 vram bank now.
	MOV	AX,BX			; 0=VRAM0 write,1=VRAM1 write.
	PUSH	AX			; vram write bank number.

	XOR	AX,1			;
	CALL_w	VRM98WT			; PC98 vram write bank.

	MOV	AX,GOLD_GIRL		; ΊΜΰ
	MOV	DX,GOLD_GIRL[2]		; ΊΜΰ
	CALL_w	PT_RPGPROF_GOLD		; RPG profile gold.

	POP	AX			; vram write bank number.
	CALL_w	VRM98WT			; PC98 vram write bank.
	RET
FEND	WIDPROF_R_GOLD


; ****************************************************
;	WINDOWS/ΜίΫΜ¨°ΩRPG₯HP
; ****************************************************

FUNC	WIDPROF_R_HP
	MOV	DX,W_HP			; go
	CALL	PARA_UP_CUT		; p[^γΐJbg
	CALL_w	PT_RPGPROF_HP		; RPG profile HP.

	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	WIDPROF_R_HP_6		;
	RET
WIDPROF_R_HP_6:
	CALL_w	VRM98NOW		; PC98 vram bank now.
	MOV	AX,BX			; 0=VRAM0 write,1=VRAM1 write.
	PUSH	AX			; vram write bank number.

	XOR	AX,1			;
	CALL_w	VRM98WT			; PC98 vram write bank.

	MOV	DX,W_HP			; go
	CALL	PARA_UP_CUT		; p[^γΐJbg
	CALL_w	PT_RPGPROF_HP		; RPG profile HP.

	POP	AX			; vram write bank number.
	CALL_w	VRM98WT			; PC98 vram write bank.
	RET
FEND	WIDPROF_R_HP


; ****************************************************
;	WINDOWS/ΜίΫΜ¨°ΩRPG₯MP
; ****************************************************

FUNC	WIDPROF_R_MP
	MOV	DX,W_MP			; lo
	CALL	PARA_UP_CUT		; p[^γΐJbg
	CALL_w	PT_RPGPROF_MP		; RPG profile MP.

	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	WIDPROF_R_MP_6		;
	RET
WIDPROF_R_MP_6:
	CALL_w	VRM98NOW		; PC98 vram bank now.
	MOV	AX,BX			; 0=VRAM0 write,1=VRAM1 write.
	PUSH	AX			; vram write bank number.

	XOR	AX,1			;
	CALL_w	VRM98WT			; PC98 vram write bank.

	MOV	DX,W_MP			; lo
	CALL	PARA_UP_CUT		; p[^γΐJbg
	CALL_w	PT_RPGPROF_MP		; RPG profile MP.

	POP	AX			; vram write bank number.
	CALL_w	VRM98WT			; PC98 vram write bank.
	RET
FEND	WIDPROF_R_MP


; ****************************************************
;	WINDOWS/ΜίΫΜ¨°ΩRPG₯υ
; ****************************************************

FUNC	WIDPROF_R_ARMS
	MOV	AX,EQUIP_ICON		; υ@hbnmΤ
	MOV	BX,ARMS_ICON		; ν@hbnmΤ
	CALL_w	PT_RPGPROF_ARMS_ICON	; RPG profile arms icon.

	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	WIDPROF_R_ARMS_6	;
	RET
WIDPROF_R_ARMS_6:
	CALL_w	VRM98NOW		; PC98 vram bank now.
	MOV	AX,BX			; 0=VRAM0 write,1=VRAM1 write.
	PUSH	AX			; vram write bank number.

	XOR	AX,1			;
	CALL_w	VRM98WT			; PC98 vram write bank.

	MOV	AX,EQUIP_ICON		; υ@hbnmΤ
	MOV	BX,ARMS_ICON		; ν@hbnmΤ
	CALL_w	PT_RPGPROF_ARMS_ICON	; RPG profile arms icon.

	POP	AX			; vram write bank number.
	CALL_w	VRM98WT			; PC98 vram write bank.
	RET
FEND	WIDPROF_R_ARMS


; ****************************************************
;	all show.
; ****************************************************

ALL_SHOW	PROC	NEAR
	MOV	SI,NAME_FIRST		; ΌO
	MOV	BX,NAME_FAMILY		; ΌO(family)
	CALL_w	PT_PROFILE_NAME		; profile name.

	MOV	AX,P_BLOOD		; t^
	MOV	BX,P_SYUGOSEI		; ημ―
	CALL_w	PT_PROFILE_STAR		; profile star.

	MOV	SI,S_HEALTH_CARE	; NΗ string
	CALL_w	PT_PROFILE_HEALTH	; profile health care.

	CALL	w_WIDPROF_GOLD		; WINDOWS/vtB[Eΰ

	CALL	w_WIDPROF_AGE		; WINDOWS/vtB[ENξ

	MOV	AX,P_NENREI		; Nξ
	CALL_w	PT_PROFILE_AGE		; profile age.

	MOV	AX,EQUIP_ICON		; υ@hbnmΤ
	MOV	BX,ARMS_ICON		; ν@hbnmΤ
	CALL_w	PT_PROFILE_ARMS_ICON	; profile arms icon.

	MOV	AX,FLAG_BYOUKI		; σΤEaC
	MOV	BX,FLAG_HIKOUKA		; σΤEρs»
	MOV	CX,FLAG_RENAI		; σΤEφ€
	CALL_w	PT_PROFILE_STATUS_ICON	; profile status icon.

	MOV	AX,P_SHINCHO		; g·
	MOV	BX,P_TAIJYU		; Μd
	MOV	CX,P_BUST		; oXg
	MOV	DX,P_WAIST		; EGXg
	MOV	SI,P_HIP		; qbv
	CALL_w	PT_PROFILE_BODYSIZE	; profile body size.

	RET
ALL_SHOW	ENDP


; ****************************************************
;	p[^γΐJbg
;	-I/O- DX : value.
; ****************************************************

PARA_UP_CUT	PROC	NEAR
	CMP	DX,999
	JLE	PARA_UP_CUT_2
	MOV	DX,999
PARA_UP_CUT_2:
	RET
PARA_UP_CUT	ENDP


WINDOW	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	NAME_FIRST:WORD			; ΌO
EXTRN	NAME_FAMILY:WORD		; ΌO(family)

EXTRN	W_HP:WORD			; go
EXTRN	W_MP:WORD			; lo

EXTRN	P_BLOOD:WORD			; t^
EXTRN	P_NENREI:WORD			; Nξ
EXTRN	P_BORTHDAY:WORD			; aΆϊ
EXTRN	P_BORTHMONTH:WORD		; aΆ
EXTRN	P_BORTHYEAR:WORD		; aΆN
EXTRN	P_SHIKYU:WORD			; q{Ό
EXTRN	P_SYUGOSEI:WORD			; ημ―

EXTRN	P_SHINCHO:WORD			; g·
EXTRN	P_TAIJYU:WORD			; Μd
EXTRN	P_BUST:WORD			; oXg
EXTRN	P_WAIST:WORD			; EGXg
EXTRN	P_HIP:WORD			; qbv

EXTRN	S_HEALTH_CARE_LEN:WORD		; NΗ·³
EXTRN	S_HEALTH_CARE:WORD		; NΗ string

EXTRN	EQUIP_ICON:WORD			; υ@hbnmΤ
EXTRN	ARMS_ICON:WORD			; ν@hbnmΤ

EXTRN	FLAG_BYOUKI:WORD		; σΤEaC
EXTRN	FLAG_HIKOUKA:WORD		; σΤEρs»
EXTRN	FLAG_RENAI:WORD			; σΤEφ€

EXTRN	GOLD_GIRL:WORD			; ΊΜΰ

DATA	ENDS

	END
;
;	end of "WIDPROF.ASM"
;
