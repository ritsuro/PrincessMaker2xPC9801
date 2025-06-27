; "WIDPROF.ASM" 486/50 make by R.H 1992/12/15
;
;
;	ＷＩＮＤＯＷＳ／プロフィール・ウインドウ
;
;	WIDPROF_SET		; WINDOWS/プロフィール・表示
;	WIDPROF_SHOW		; WINDOWS/プロフィール・再表示
;	WIDPROF_GOLD		; WINDOWS/プロフィール・所持金
;	WIDPROF_AGE		; WINDOWS/プロフィール・年齢
;
;	WIDPROF_R_GOLD		; WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･所持金
;	WIDPROF_R_HP		; WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･HP
;	WIDPROF_R_MP		; WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･MP
;	WIDPROF_R_ARMS		; WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･装備
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
;	WINDOWS/プロフィール・表示
; ****************************************************

FUNC	WIDPROF_SET
	CALL_w	PT_PROFILE_LD		; profile load.
	CALL_w	PT_PROFILE_FRM		; profile fream.
	CALL	ALL_SHOW		; all show.
	RET
FEND	WIDPROF_SET


; ****************************************************
;	WINDOWS/プロフィール・再表示
; ****************************************************

FUNC	WIDPROF_SHOW
;*;	CALL_w	PT_PROFILE_FRM		; profile fream.
	CALL	ALL_SHOW		; all show.
	RET
FEND	WIDPROF_SHOW


; ****************************************************
;	WINDOWS/プロフィール・所持金
; ****************************************************

FUNC	WIDPROF_GOLD
	MOV	AX,GOLD_GIRL		; 娘の所持金
	MOV	DX,GOLD_GIRL[2]		; 娘の所持金
	CALL_w	PT_PROFILE_GOLD		; profile gold.
	RET
FEND	WIDPROF_GOLD


; ****************************************************
;	WINDOWS/プロフィール・年齢
; ****************************************************

FUNC	WIDPROF_AGE
	MOV	AX,P_NENREI		; 年齢
	CALL_w	PT_PROFILE_AGE		; profile age.
	RET
FEND	WIDPROF_AGE


; ****************************************************
;	WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･所持金
; ****************************************************

FUNC	WIDPROF_R_GOLD
	MOV	AX,GOLD_GIRL		; 娘の所持金
	MOV	DX,GOLD_GIRL[2]		; 娘の所持金
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

	MOV	AX,GOLD_GIRL		; 娘の所持金
	MOV	DX,GOLD_GIRL[2]		; 娘の所持金
	CALL_w	PT_RPGPROF_GOLD		; RPG profile gold.

	POP	AX			; vram write bank number.
	CALL_w	VRM98WT			; PC98 vram write bank.
	RET
FEND	WIDPROF_R_GOLD


; ****************************************************
;	WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･HP
; ****************************************************

FUNC	WIDPROF_R_HP
	MOV	DX,W_HP			; ＨＰ
	CALL	PARA_UP_CUT		; パラメータ上限カット
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

	MOV	DX,W_HP			; ＨＰ
	CALL	PARA_UP_CUT		; パラメータ上限カット
	CALL_w	PT_RPGPROF_HP		; RPG profile HP.

	POP	AX			; vram write bank number.
	CALL_w	VRM98WT			; PC98 vram write bank.
	RET
FEND	WIDPROF_R_HP


; ****************************************************
;	WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･MP
; ****************************************************

FUNC	WIDPROF_R_MP
	MOV	DX,W_MP			; ＭＰ
	CALL	PARA_UP_CUT		; パラメータ上限カット
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

	MOV	DX,W_MP			; ＭＰ
	CALL	PARA_UP_CUT		; パラメータ上限カット
	CALL_w	PT_RPGPROF_MP		; RPG profile MP.

	POP	AX			; vram write bank number.
	CALL_w	VRM98WT			; PC98 vram write bank.
	RET
FEND	WIDPROF_R_MP


; ****************************************************
;	WINDOWS/ﾌﾟﾛﾌｨｰﾙRPG･装備
; ****************************************************

FUNC	WIDPROF_R_ARMS
	MOV	AX,EQUIP_ICON		; 装備　ＩＣＯＮ番号
	MOV	BX,ARMS_ICON		; 武器　ＩＣＯＮ番号
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

	MOV	AX,EQUIP_ICON		; 装備　ＩＣＯＮ番号
	MOV	BX,ARMS_ICON		; 武器　ＩＣＯＮ番号
	CALL_w	PT_RPGPROF_ARMS_ICON	; RPG profile arms icon.

	POP	AX			; vram write bank number.
	CALL_w	VRM98WT			; PC98 vram write bank.
	RET
FEND	WIDPROF_R_ARMS


; ****************************************************
;	all show.
; ****************************************************

ALL_SHOW	PROC	NEAR
	MOV	SI,NAME_FIRST		; 名前
	MOV	BX,NAME_FAMILY		; 名前(family)
	CALL_w	PT_PROFILE_NAME		; profile name.

	MOV	AX,P_BLOOD		; 血液型
	MOV	BX,P_SYUGOSEI		; 守護星
	CALL_w	PT_PROFILE_STAR		; profile star.

	MOV	SI,S_HEALTH_CARE	; 健康管理 string
	CALL_w	PT_PROFILE_HEALTH	; profile health care.

	CALL	w_WIDPROF_GOLD		; WINDOWS/プロフィール・所持金

	CALL	w_WIDPROF_AGE		; WINDOWS/プロフィール・年齢

	MOV	AX,P_NENREI		; 年齢
	CALL_w	PT_PROFILE_AGE		; profile age.

	MOV	AX,EQUIP_ICON		; 装備　ＩＣＯＮ番号
	MOV	BX,ARMS_ICON		; 武器　ＩＣＯＮ番号
	CALL_w	PT_PROFILE_ARMS_ICON	; profile arms icon.

	MOV	AX,FLAG_BYOUKI		; 状態・病気
	MOV	BX,FLAG_HIKOUKA		; 状態・非行化
	MOV	CX,FLAG_RENAI		; 状態・恋愛
	CALL_w	PT_PROFILE_STATUS_ICON	; profile status icon.

	MOV	AX,P_SHINCHO		; 身長
	MOV	BX,P_TAIJYU		; 体重
	MOV	CX,P_BUST		; バスト
	MOV	DX,P_WAIST		; ウエスト
	MOV	SI,P_HIP		; ヒップ
	CALL_w	PT_PROFILE_BODYSIZE	; profile body size.

	RET
ALL_SHOW	ENDP


; ****************************************************
;	パラメータ上限カット
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

EXTRN	NAME_FIRST:WORD			; 名前
EXTRN	NAME_FAMILY:WORD		; 名前(family)

EXTRN	W_HP:WORD			; ＨＰ
EXTRN	W_MP:WORD			; ＭＰ

EXTRN	P_BLOOD:WORD			; 血液型
EXTRN	P_NENREI:WORD			; 年齢
EXTRN	P_BORTHDAY:WORD			; 誕生日
EXTRN	P_BORTHMONTH:WORD		; 誕生月
EXTRN	P_BORTHYEAR:WORD		; 誕生年
EXTRN	P_SHIKYU:WORD			; 子宮名
EXTRN	P_SYUGOSEI:WORD			; 守護星

EXTRN	P_SHINCHO:WORD			; 身長
EXTRN	P_TAIJYU:WORD			; 体重
EXTRN	P_BUST:WORD			; バスト
EXTRN	P_WAIST:WORD			; ウエスト
EXTRN	P_HIP:WORD			; ヒップ

EXTRN	S_HEALTH_CARE_LEN:WORD		; 健康管理長さ
EXTRN	S_HEALTH_CARE:WORD		; 健康管理 string

EXTRN	EQUIP_ICON:WORD			; 装備　ＩＣＯＮ番号
EXTRN	ARMS_ICON:WORD			; 武器　ＩＣＯＮ番号

EXTRN	FLAG_BYOUKI:WORD		; 状態・病気
EXTRN	FLAG_HIKOUKA:WORD		; 状態・非行化
EXTRN	FLAG_RENAI:WORD			; 状態・恋愛

EXTRN	GOLD_GIRL:WORD			; 娘の所持金

DATA	ENDS

	END
;
;	end of "WIDPROF.ASM"
;
