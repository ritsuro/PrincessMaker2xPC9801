; "WIDFULL.ASM" 486/50 make by R.H 1992/08/06
;
;
;	ＷＩＮＤＯＷＳ／全画面枠等
;
;
;	WID_FULL_FREAM		; WINDOWS/全画面枠
;
;
; (C) 1991 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC
INCLUDE	MACHINEX.INC

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA

; ****************************************************
;	WINDOWS/全画面枠
;	-I- BX : 枠番号
;		1=娘の部屋
;		2=武者修行
;		3=「王国芸術祭」
;		4=「ダンスパーティー」
;		5=「お料理コンクール」
;		6=「武闘会」
;		7=「バカンス」
;		50=RPG用HPMP
;		100=現在表示中の枠番号
;	-O- AX : 現在表示中の枠番号
; ****************************************************

FUNC	WID_FULL_FREAM
	CMP	BX,50
	JE	WID_FULL_FREAM_RPG_HPMP
	CMP	BX,100			; 100=現在表示中の枠番号
	JE	WID_FULL_FREAM_NOW_NUMBER
	MOV	NOW_FREAM_NUMBER,BX	; now fream number.
	CALL_w	PT_FRMFULL		; put full fream.
	RET
WID_FULL_FREAM_NOW_NUMBER:
	MOV	AX,NOW_FREAM_NUMBER	; now fream number.
	RET

WID_FULL_FREAM_RPG_HPMP:
	MOV	NOW_FREAM_NUMBER,BX	; now fream number.
	CALL_w	PT_FRMFULL		; put full fream.

	CMP	MFLAG_MY,MFLAG_PC98	; PC9801
	JE	WID_FULL_FREAM_6	;
	RET
WID_FULL_FREAM_6:
	CALL_w	VRM98NOW		; PC98 vram bank now.
	MOV	AX,BX			; 0=VRAM0 write,1=VRAM1 write.
	PUSH	AX			; vram write bank number.

	XOR	AX,1			;
	CALL_w	VRM98WT			; PC98 vram write bank.

	MOV	BX,NOW_FREAM_NUMBER	; now fream number.
	CALL_w	PT_FRMFULL		; put full fream.

	POP	AX			; vram write bank number.
	CALL_w	VRM98WT			; PC98 vram write bank.
	RET
FEND	WID_FULL_FREAM

WINDOW	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

NOW_FREAM_NUMBER	DW	0	; now fream number.

DATA	ENDS

	END
;
;	end of "WIDFULL.ASM"
;
