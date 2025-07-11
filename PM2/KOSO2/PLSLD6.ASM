; "PLSLD6.ASM"  PS55Z/S14 PC-9801UV11 make by R.H/japan 1991/12/02
;
;
;	�p�[�c�f�[�^�E�W�J�o�b�t�@���z�u�q�`�l��
;
;	���z�u�q�`�l�����ꂽ�u�q�`�l�̃f�[�^�͈ȉ���
;	�ϐ��ɕԂ����B
;
;	SSGRV0 : visual data segment plean 0
;	SSGRV1 : visual data segment plean 1
;	SSGRV2 : visual data segment plean 2
;	SSGRV3 : visual data segment plean 3
;	SSGRVW : visual data plean width.
;
;
; public subroutine.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	UNPVVR			; �f�[�^�����E�W�J�o�b�t�@���z�u�q�`�l��

EXTRN	C1BUNPLE:NEAR		; ���k�t�H�[�}�b�g�f�[�^����


;	�f�[�^�����E�W�J�o�b�t�@���z�u�q�`�l��
;	-I- VRLENX : �w��������
;	    VRLENY : �x��������
;	    BPNTOF : �f�[�^�o�b�t�@�|�C���^
;	    BPNTSG : �f�[�^�o�b�t�@�Z�O�����g
;	    BCNTMX : �f�[�^�ő咷��
;	-O- SSGRV0 : visual data segment plean 0
;	    SSGRV1 : visual data segment plean 1
;	    SSGRV2 : visual data segment plean 2
;	    SSGRV3 : visual data segment plean 3
;	    SSGRVW : visual data plean width.

UNPVVR	PROC	NEAR
	CALL	LDPLSD			; ���k�t�H�[�}�b�g�f�[�^����
	CALL	SFTFACE			; �u�q�`�l�Z�O�����g����
	CALL	XCHGVRM			; �u�q�`�l�c���E�g�ς�
	RET
UNPVVR	ENDP


;	�u�q�`�l�Z�O�����g����
;	-I- SEGPLS : pless/unpless segment.
;	    OFSPLS : pless/unpless offset.
;	    VRLENX : �w��������
;	    VRLENY : �x��������
;	-O- SSGRV0 : visual data segment plean 0
;	    SSGRV1 : visual data segment plean 1
;	    SSGRV2 : visual data segment plean 2
;	    SSGRV3 : visual data segment plean 3
;	    SSGRVW : visual data plean width.
;	    WORKSEGMENT : work buffer segment.

SFTFACE	PROC	NEAR
	MOV	AX,VRLENX		; �w��������
	MOV	SSGRVW,AX		; visual data plean width.

	MOV	AX,VRLENX		; �w��������
	MOV	BX,VRLENY		; �x��������
	MUL	BX			; size = x * y
	MOV	PLN1SIZE,AX		; 1 plean size.

	MOV	BX,16			;
	DIV	BX			;
	CMP	DX,0			;
	JE	SFTFACE_1		; parasize = size / 16
	INC	AX			;
SFTFACE_1:				;
	MOV	PLN1PARASIZE,AX		; 1 plean paragraph size.

	MOV	AX,SEGPLS		; pless/unpless segment.
	MOV	BX,16			;
	MUL	BX			;
	ADD	AX,OFSPLS		; pless/unpless offset.
	ADC	DX,0			;

	MOV	BX,16			;
	DIV	BX			;
	CMP	DX,0			;
	JE	SFTFACE_2		;
	INC	AX			;
SFTFACE_2:				;
	MOV	SSGRV0,AX		; visual data segment plean 0
	ADD	AX,PLN1PARASIZE		; 1 plean paragraph size.
	MOV	SSGRV1,AX		; visual data segment plean 1
	ADD	AX,PLN1PARASIZE		; 1 plean paragraph size.
	MOV	SSGRV2,AX		; visual data segment plean 2
	ADD	AX,PLN1PARASIZE		; 1 plean paragraph size.
	MOV	SSGRV3,AX		; visual data segment plean 3
	ADD	AX,PLN1PARASIZE		; 1 plean paragraph size.
	MOV	WORKSEGMENT,AX		; work buffer segment.

	MOV	DX,SEGPLS		; pless/unpless segment.
	MOV	SI,OFSPLS		; pless/unpless offset.
	MOV	AX,PLN1SIZE		; 1 plean size.
	SHL	AX,1			;
	SHL	AX,1			; *4
	ADD	SI,AX			;
	DEC	SI			; -1

	MOV	ES,SSGRV3		; visual data segment plean 3
	MOV	DI,PLN1SIZE		; 1 plean size.
	DEC	DI			; -1
	MOV	CX,PLN1SIZE		; 1 plean size.
	PUSH	DS			;
	MOV	DS,DX			;
	CLI				;
	STD				;
	REP	MOVSB			;
	CLD				;
	STI				;
	POP	DS			;

	MOV	ES,SSGRV2		; visual data segment plean 2
	MOV	DI,PLN1SIZE		; 1 plean size.
	DEC	DI			; -1
	MOV	CX,PLN1SIZE		; 1 plean size.
	PUSH	DS			;
	MOV	DS,DX			;
	CLI				;
	STD				;
	REP	MOVSB			;
	CLD				;
	STI				;
	POP	DS			;

	MOV	ES,SSGRV1		; visual data segment plean 1
	MOV	DI,PLN1SIZE		; 1 plean size.
	DEC	DI			; -1
	MOV	CX,PLN1SIZE		; 1 plean size.
	PUSH	DS			;
	MOV	DS,DX			;
	CLI				;
	STD				;
	REP	MOVSB			;
	CLD				;
	STI				;
	POP	DS			;

	MOV	ES,SSGRV0		; visual data segment plean 0
	MOV	DI,PLN1SIZE		; 1 plean size.
	DEC	DI			; -1
	MOV	CX,PLN1SIZE		; 1 plean size.
	PUSH	DS			;
	MOV	DS,DX			;
	CLI				;
	STD				;
	REP	MOVSB			;
	CLD				;
	STI				;
	POP	DS			;

	CMP	WORKSEGMENT,(65535/5)*4	; work buffer segment.
	JBE	SFTFACE_9		;
	MOV	WORKSEGMENT,(65535/5)*4	; work buffer segment.
SFTFACE_9:
	RET
SFTFACE	ENDP


;	�u�q�`�l�c���E�g�ς�
;	-I- SSGRV0 : visual data segment plean 0
;	    SSGRV1 : visual data segment plean 1
;	    SSGRV2 : visual data segment plean 2
;	    SSGRV3 : visual data segment plean 3
;	    SSGRVW : visual data plean width.
;	    PLN1SIZE : 1 plean size.
;	    WORKSEGMENT : work buffer segment.

XCHGVRM	PROC	NEAR
	MOV	DX,SSGRV0		; visual data segment plean 0
	MOV	CX,SSGRVW		; visual data plean width.
	MOV	BX,WORKSEGMENT		; work buffer segment.
	MOV	BP,PLN1SIZE		; 1 plean size.
	CALL	XCHG1PLN		; �u�q�`�l�P�v���[���c���E�g�ς�

	MOV	DX,SSGRV1		; visual data segment plean 1
	MOV	CX,SSGRVW		; visual data plean width.
	MOV	BX,WORKSEGMENT		; work buffer segment.
	MOV	BP,PLN1SIZE		; 1 plean size.
	CALL	XCHG1PLN		; �u�q�`�l�P�v���[���c���E�g�ς�

	MOV	DX,SSGRV2		; visual data segment plean 2
	MOV	CX,SSGRVW		; visual data plean width.
	MOV	BX,WORKSEGMENT		; work buffer segment.
	MOV	BP,PLN1SIZE		; 1 plean size.
	CALL	XCHG1PLN		; �u�q�`�l�P�v���[���c���E�g�ς�

	MOV	DX,SSGRV3		; visual data segment plean 3
	MOV	CX,SSGRVW		; visual data plean width.
	MOV	BX,WORKSEGMENT		; work buffer segment.
	MOV	BP,PLN1SIZE		; 1 plean size.
	CALL	XCHG1PLN		; �u�q�`�l�P�v���[���c���E�g�ς�

	RET
XCHGVRM	ENDP


;	�u�q�`�l�P�v���[���c���E�g�ς�
;	-I- DX : vram segment.
;	    CX : plean width.
;	    BX : work buffer segment.
;	    BP : 1 plean size.

XCHG1PLN	PROC	NEAR
	PUSH	DS
	MOV	DS,DX			; segment.
	MOV	ES,BX			; work buffer segment.
	MOV	SI,0			; source.
	MOV	DI,0			; dest.
XCHG1PLN_LOOP:
	CMP	SI,BP			; 1 plean size.
	JNB	XCHG1PLN_5		;
	LODSB				;
	MOV	ES:[DI],AL		;
	ADD	DI,CX			; plean width.
	CMP	DI,BP			; 1 plean size.
	JB	XCHG1PLN_LOOP		;
	SUB	DI,BP			; 1 plean size.
	INC	DI			; x++
	JMP	XCHG1PLN_LOOP		;
XCHG1PLN_5:
	MOV	ES,DX			; segment.
	MOV	DS,BX			; work buffer segment.
	MOV	SI,0			; source.
	MOV	DI,0			; dest.
	MOV	CX,BP			; 1 plean size.
	REP	MOVSB			;
	POP	DS
	RET
XCHG1PLN	ENDP


;	���k�t�H�[�}�b�g�f�[�^����
;	-I- BPNTOF     : �f�[�^�o�b�t�@�|�C���^
;	    BPNTSG     : �f�[�^�o�b�t�@�Z�O�����g
;	-O- SEGPLS:OFSPLS : pless/unpless segment.

LDPLSD	PROC	NEAR
	PUSH	DS

	MOV	DI,OFSPLS	; pless/unpless offset.
	MOV	AX,SEGPLS	; pless/unpless segment.
	MOV	ES,AX		;

	CALL	C1BUNPLE	; ���k�t�H�[�}�b�g�f�[�^����

	POP	DS
	RET
LDPLSD	ENDP

CODE01	ENDS

DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	SEGPLS:WORD		; pless/unpless segment.
EXTRN	OFSPLS:WORD		; pless/unpless offset.

EXTRN	PLSMDE:WORD		; ���k���[�h(0:�ʏ�,1:�c����)

EXTRN	VRX:WORD		; x point.
EXTRN	VRY:WORD		; y point.

EXTRN	VRLENX:WORD		; x length.
EXTRN	VRLENY:WORD		; y length.

EXTRN	ARAVRM:WORD		; visual data segment plean 0

EXTRN	SSGRV0:WORD		; visual data segment plean 0
EXTRN	SSGRV1:WORD		; visual data segment plean 1
EXTRN	SSGRV2:WORD		; visual data segment plean 2
EXTRN	SSGRV3:WORD		; visual data segment plean 3
EXTRN	SSGRVW:WORD		; visual data plean width.

PLN1SIZE	DW	0	; 1 plean size.
PLN1PARASIZE	DW	0	; 1 plean paragraph size.
WORKSEGMENT	DW	0	; work buffer segment.

DATA	ENDS

	END
;
;	end of "PLSLD6.ASM"
;
