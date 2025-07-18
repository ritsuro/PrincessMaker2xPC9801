; "WIDGIRL.ASM" 486/50 make by R.H 1992/08/06
;
;
;	�v�h�m�c�n�v�r�^��
;
;
;	WID_GIRL_DIRECT		; WINDOWS/�� direct put.
;	WID_GIRL_DRAW		; WINDOWS/�� girl put.
;	WID_GIRL_DRAW_FCONLY	; WINDOWS/�� girl face put.
;	WID_GIRL_SMOOTH		; WINDOWS/�� girl noral<->dameg smooth put.
;	WID_GIRL_WALL		; WINDOWS/�� girl back wall.
;	WID_GIRL_PMODE		; WINDOWS/�� girl put mode.
;
;
; (C) 1991 ritsurou hashimoto.

INCLUDE	TSTSETW.INC
INCLUDE	WINDOWS.INC

WINDOW	SEGMENT	PUBLIC	'WINDOW'

	ASSUME	CS:WINDOW,DS:DATA


; ****************************************************
;	WINDOWS/�� direct put.
;	-I- AX : �N��
;	    BX : �̌`�@1=��,2=��
;	    CX : �\��@1=��{,2=��s,3=�a�C,4=���C,5=�F�C
;	    DX : ����@0=��,1=�L
;	    SI : ��  0=��
;		1=���E���i��,2=���E�ĕ��̕�,3=���E�~���̕�
;		4=���E�ؖȂ̃h���X,5=���E�V���N�̃h���X
;		6=���E���[�U�[�̃h���X,7=���E�g�Q�g�Q�̕�
;		8=���E�X���̃��[�u,9=���E�����Ȃ��h���X
;		10=���E�����̃h���X,11=���E���̃��I�^�[�h
;	    DI : �d�a�@0=normal,1=�d�a
; ****************************************************

FUNC	WID_GIRL_DIRECT
	MOV	WD_GIRL_AGE,AX		; girl age.
	MOV	WD_GIRL_BODY,BX		; girl body.1=��,2=��
	MOV	WD_GIRL_FACE,CX		; girl face.1=��{,2=��s,3=�a�C,4=���C,5=�F�C
	MOV	WD_GIRL_BREAST,DX	; girl breast.0=��,1=�L
	MOV	WD_GIRL_DRESS,SI	; girl dress.
	MOV	WD_GIRL_DRESS_BODY,BX	; girl dress body.1=��,2=��
	MOV	WD_GIRL_DRESS_BREAST,DX	; girl dress breast.0=��,1=�L
	MOV	WD_GIRL_DAMEG,DI	; girl dameg.0=normal,1=�d�a

	CALL	CHECK_BODY		; check body.
	CALL	CHECK_DRESS		; check dress.

	CALL	GIRL_PUT		; �� put.
	RET
FEND	WID_GIRL_DIRECT


; ****************************************************
;	WINDOWS/�� girl put.
; ****************************************************

FUNC	WID_GIRL_DRAW
	CALL	GIRL_CHECK		; �� check.
	CALL	GIRL_PUT		; �� put.
	RET
FEND	WID_GIRL_DRAW


; ****************************************************
;	WINDOWS/�� girl face only put.
; ****************************************************

FUNC	WID_GIRL_DRAW_FCONLY
	CALL	GIRL_PUT_FACEONLY	; �� put face only.
	RET
FEND	WID_GIRL_DRAW_FCONLY


; ****************************************************
;	WINDOWS/�� girl noral<->dameg smooth put.
; ****************************************************

FUNC	WID_GIRL_SMOOTH
	CALL	GIRL_CHECK		; �� check.
	MOV	AX,1			; 0=normal,1=smooth.
	CALL_w	PT_GIRL_SMODE		; put girl draw smooth mode.
	CALL	GIRL_PUT		; �� put.
	MOV	AX,0			; 0=normal,1=smooth.
	CALL_w	PT_GIRL_SMODE		; put girl draw smooth mode.
	RET
FEND	WID_GIRL_SMOOTH


; ****************************************************
;	WINDOWS/�� girl back wall.
; ****************************************************

FUNC	WID_GIRL_WALL
	CMP	GIRL_DAMEG,0		; �d�a 0=normal,1=�d�a
	JNE	WID_GIRL_WALL_BED	;
	CALL_w	PT_GIRL_WALLX		; put girl back wall.
	RET
WID_GIRL_WALL_BED:
	CALL_w	PT_GIRL_BEDX		; put girl back bed.
	RET
FEND	WID_GIRL_WALL


; ****************************************************
;	WINDOWS/�� girl put mode.
;	-I- AX : girl put mode.0=normal,1=o.l.
; ****************************************************

FUNC	WID_GIRL_PMODE
	CALL_w	PT_GIRL_PMODE		; put girl put mode.
	RET
FEND	WID_GIRL_PMODE


; ****************************************************
;	�� put.
; ****************************************************

GIRL_PUT	PROC	NEAR
	CMP	WD_GIRL_DAMEG,1		; girl dameg.0=normal,1=�d�a
	JE	GIRL_PUT_DAMEG		;

	MINMAX	WD_GIRL_AGE,	10,17	; �N��
	MINMAX	WD_GIRL_BODY,	1,2	; girl body.1=��,2=��
	MINMAX	WD_GIRL_FACE,	1,5	; girl face.1=��{,2=��s,3=�a�C...
	MINMAX	WD_GIRL_BREAST,	0,1	; girl breast.0=��,1=�L

	MINMAX	WD_GIRL_DRESS,		0,11	; girl dress.
	MINMAX	WD_GIRL_DRESS_BODY,	1,2	; girl dress body.1=��,2=��
	MINMAX	WD_GIRL_DRESS_BREAST	0,1	; girl dress breast.0=��,1=�L

	CALL_w	PT_GIRL_FULL		; put girl full.
	RET
GIRL_PUT_DAMEG:
	CALL_w	PT_GIRL_DAMEG		; put girl dameg.
	RET
GIRL_PUT	ENDP


; ****************************************************
;	�� put face only.
; ****************************************************

GIRL_PUT_FACEONLY	PROC	NEAR
	MOVX	WD_GIRL_AGE,	P_NENREI	; �N��
	MOVX	WD_GIRL_FACE,	GIRL_FACE	; �\�� 1=��{,2=��s,3�a�C...

	MINMAX	WD_GIRL_AGE,	10,17	; �N��
	MINMAX	WD_GIRL_FACE,	1,5	; girl face.1=��{,2=��s,3=�a�C...

	CALL_w	PT_GIRL_FACEONLY	; put girl face only.
	RET
GIRL_PUT_FACEONLY	ENDP


; ****************************************************
;	�� check.
; ****************************************************

GIRL_CHECK	PROC	NEAR
	MOVX	WD_GIRL_AGE,	P_NENREI	; �N��
	MOVX	WD_GIRL_BODY,	GIRL_BODY	; �̌` 1=��,2=��
	MOVX	WD_GIRL_FACE,	GIRL_FACE	; �\�� 1=��{,2=��s,3�a�C...
	MOVX	WD_GIRL_BREAST,	GIRL_BREAST	; ���� 0=��,1=�L
	MOVX	WD_GIRL_DAMEG,	GIRL_DAMEG	; girl dameg.0=normal,1=�d�a

	MOVX	WD_GIRL_DRESS,		DRESS_NUM	; ���ߊG�ԍ�
	MOVX	WD_GIRL_DRESS_BODY,	GIRL_BODY	; �̌` 1=��,2=��
	MOVX	WD_GIRL_DRESS_BREAST,	GIRL_BREAST	; ���� 0=��,1=�L

	CALL	CHECK_BODY			; check body.
	CALL	CHECK_DRESS			; check dress.

	RET
GIRL_CHECK	ENDP


; ****************************************************
;	check body.
; ****************************************************

CHECK_BODY	PROC	NEAR
	CMP	WD_GIRL_AGE,10			; �P�O�ˈȉ��͐F�C����
	JNBE	CHECK_BODY_1			;

	CMP	WD_GIRL_FACE,5			; 5=�F�C
	JNE	CHECK_BODY_1			;

	MOV	WD_GIRL_FACE,1			; 1=��{

CHECK_BODY_1:					;
	CMP	WD_GIRL_AGE,14			; �P�S�ˈȉ��͋�����
	JNBE	CHECK_BODY_2			;

	MOV	WD_GIRL_BREAST,0		; ���� 0=��,1=�L
	MOV	WD_GIRL_DRESS_BREAST,0		; ���� 0=��,1=�L
CHECK_BODY_2:
	RET
CHECK_BODY	ENDP


; ****************************************************
;	check dress.
; ****************************************************

CHECK_DRESS	PROC	NEAR
	CMP	WD_GIRL_DRESS,11		; ���ߊG�ԍ�
	JNBE	CHECK_DRESS_1			;
	CMP	WD_GIRL_DRESS,0			; ���ߊG�ԍ�
	JE	CHECK_DRESS_1			;
	JMP	CHECK_DRESS_2			;
CHECK_DRESS_1:					;
	MOV	WD_GIRL_DRESS,1			; 1=���E���i��
CHECK_DRESS_2:

	MOV	BX,WD_GIRL_DRESS		; ���ߊG�ԍ�
	DEC	BX
	SHL	BX,1
	MOVX	ES,<SEG WINDOW>
	JMP	ES:CHECK_DRESS_JMP[BX]
CHECK_DRESS_JMP	LABEL	WORD
	DW	CHECK_DRESS_1D,CHECK_DRESS_2D,CHECK_DRESS_3D,CHECK_DRESS_4D
	DW	CHECK_DRESS_5D,CHECK_DRESS_6D,CHECK_DRESS_7D,CHECK_DRESS_8D
	DW	CHECK_DRESS_9D,CHECK_DRESS_10D,CHECK_DRESS_11D

CHECK_DRESS_1D:
	MOV	WD_GIRL_DRESS_BODY,1		; �̌` �ב����p
	RET

CHECK_DRESS_2D:
	CMP	WD_GIRL_AGE,12			; �P�Q�ˈȉ���
	JNBE	CHECK_DRESS_2D2			;
	MOV	WD_GIRL_DRESS_BODY,1		; �̌` �ב����p
CHECK_DRESS_2D2:
	RET

CHECK_DRESS_3D:
	MOV	WD_GIRL_DRESS_BODY,1		; �̌` �ב����p
	MOV	WD_GIRL_DRESS_BREAST,0		; ���� ��
	RET

CHECK_DRESS_4D:
	MOV	WD_GIRL_DRESS_BREAST,0		; ���� ��
	RET

CHECK_DRESS_5D:
	MOV	WD_GIRL_DRESS_BODY,1		; �̌` �ב����p
	CMP	WD_GIRL_AGE,12			; �P�Q�ˈȉ���
	JNBE	CHECK_DRESS_5D2			;
	MOV	WD_GIRL_DRESS,0			; ���ߊG�ԍ�
CHECK_DRESS_5D2:
	RET

CHECK_DRESS_6D:
	MOV	WD_GIRL_DRESS_BODY,1		; �̌` �ב����p
	CMP	WD_GIRL_AGE,13			; �P�R�ˈȉ���
	JNBE	CHECK_DRESS_6D2			;
	MOV	WD_GIRL_DRESS,0			; ���ߊG�ԍ�
CHECK_DRESS_6D2:
	RET

CHECK_DRESS_7D:
	MOV	WD_GIRL_DRESS_BODY,1		; �̌` �ב����p
	CMP	WD_GIRL_AGE,12			; �P�Q�ˈȉ���
	JNBE	CHECK_DRESS_7D2			;
	MOV	WD_GIRL_DRESS,0			; ���ߊG�ԍ�
CHECK_DRESS_7D2:
	RET

CHECK_DRESS_8D:
	MOV	WD_GIRL_DRESS_BREAST,0		; ���� ��
	CMP	WD_GIRL_AGE,14			; �P�S�ˈȉ���
	JNBE	CHECK_DRESS_8D2			;
	MOV	WD_GIRL_DRESS,0			; ���ߊG�ԍ�
CHECK_DRESS_8D2:
	RET

CHECK_DRESS_9D:
	MOV	WD_GIRL_DRESS_BODY,1		; �̌` �ב����p
	MOV	WD_GIRL_DRESS_BREAST,0		; ���� ��
	RET

CHECK_DRESS_10D:
	MOV	WD_GIRL_DRESS_BODY,1		; �̌` �ב����p
	MOV	WD_GIRL_DRESS_BREAST,0		; ���� ��
	CMP	WD_GIRL_AGE,13			; �P�R�ˈȉ���
	JNBE	CHECK_DRESS_10D2		;
	MOV	WD_GIRL_DRESS,0			; ���ߊG�ԍ�
CHECK_DRESS_10D2:
	RET

CHECK_DRESS_11D:
	MOV	WD_GIRL_DRESS_BODY,1		; �̌` �ב����p
	CMP	WD_GIRL_AGE,14			; �P�S�ˈȉ���
	JNBE	CHECK_DRESS_11D2		;
	MOV	WD_GIRL_DRESS,0			; ���ߊG�ԍ�
CHECK_DRESS_11D2:
	RET
CHECK_DRESS	ENDP

WINDOW	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	WD_GIRL_AGE		; girl age.
PUBLIC	WD_GIRL_BODY		; girl body.1=��,2=��
PUBLIC	WD_GIRL_FACE		; girl face.1=��{,2=��s,3=�a�C,4=���C,5=�F�C
PUBLIC	WD_GIRL_BREAST		; girl breast.0=��,1=�L
PUBLIC	WD_GIRL_DAMEG		; girl dameg.0=normal,1=�d�a

PUBLIC	WD_GIRL_DRESS		; girl dress.
PUBLIC	WD_GIRL_DRESS_BODY	; girl dress body.1=��,2=��
PUBLIC	WD_GIRL_DRESS_BREAST	; girl dress breast.0=��,1=�L

EXTRN	P_NENREI:WORD		; �N��

EXTRN	GIRL_BODY:WORD		; �̌` 1=��,2=��
EXTRN	GIRL_FACE:WORD		; �\�� 1=��{,2=��s,3�a�C,4���C,5�F�C
EXTRN	GIRL_BREAST:WORD	; ���� 0=��,1=�L
EXTRN	GIRL_DAMEG:WORD		; �d�a 0=normal,1=�d�a

EXTRN	DRESS_NUM:WORD		; ���ߊG�ԍ�

EXTRN	FLAG_BYOUKI:WORD	; ��ԁE�a�C

WD_GIRL_AGE		DW 10	; girl age.
WD_GIRL_BODY		DW 1	; girl body.1=��,2=��
WD_GIRL_FACE		DW 1	; girl face.1=��{,2=��s,3=�a�C,4=���C,5=�F�C
WD_GIRL_BREAST		DW 0	; girl breast.0=��,1=�L
WD_GIRL_DAMEG		DW 0	; girl dameg.0=normal,1=�d�a

WD_GIRL_DRESS		DW 0	; girl dress.
				; 0=��
				; 1=���E���i��,2=���E�ĕ��̕�,3=���E�~���̕�
				; 4=���E�ؖȂ̃h���X,5=���E�V���N�̃h���X
				; 6=���E���[�U�[�̃h���X,7=���E�g�Q�g�Q�̕�
				; 8=���E�X���̃��[�u,9=���E�����Ȃ��h���X
				; 10=���E�����̃h���X,11=���E���̃��I�^�[�h
WD_GIRL_DRESS_BODY	DW 0	; girl dress body.1=��,2=��
WD_GIRL_DRESS_BREAST	DW 0	; girl dress breast.0=��,1=�L

DATA	ENDS

	END
;
;	end of "WIDGIRL.ASM"
;
