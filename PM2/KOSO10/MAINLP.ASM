; "MAINLP.ASM" 486/50 make by R.H 1993/02/16
;
;
;	���C�����[�v
;
;
;
;	5=ARA005		  SEG VVVRAM
;	6=ARA006	40*1630 : SEG VVVRAM
;	7=ARA007	40*1290 : SEG PROCWRK
;	8=ARA008	40*1630 : SEG PARTBUF
;	9=ARA009	47*1380 : SEG VVVRAM
;
;
; public subroutine.

INCLUDE	TSTSET.INC

MFLAG_PCAT	EQU	1		; PC/AT
MFLAG_PC98	EQU	2		; PC9801

VGAVRAM_SEG_G0	EQU	0A000H+1H	; �u�q�`�l�v���[���O
VGAVRAM_SEG_G1	EQU	0A000H+2H	; �u�q�`�l�v���[���P
VGAVRAM_SEG_G2	EQU	0A000H+3H	; �u�q�`�l�v���[���Q
VGAVRAM_SEG_G3	EQU	0A000H+4H	; �u�q�`�l�v���[���R
VGAVRMWIDTH	EQU	80		; �u�q�`�l��

CODE	SEGMENT	PUBLIC	'CODE'

	ASSUME	CS:CODE,DS:CODE

PUBLIC	MAINLP			; main loop.

; ****************************************************
;	main loop.
;	-I- AX   : function number.
;	AX=1  : ��������
;	AX=2  : ÷�ĕҏW�ޯ̧���ڽ���
;		-I- BX : offset.
;		    CX : segment.
;	AX=3  : ÷�ĕҏW�ޯ̧�\��
;	AX=4  : ���ިݸޥ÷�ĕ\���P
;	AX=5  : ÷�Ĉʒu���
;		-I- BX : start x.
;		    CX : start y.
;	AX=6  : ÷�ĕҏW����ݸ�
;		-I- BX : �P�s�̒���
;	AX=7  : ���ިݸޥ÷�ĕ\��2.��۰�
;	AX=8  : ÷�ĕҏW�E�[���
;		-I- BX : �P�s�̒���
;	AX=9  : ��۰ّ���ݒ�
;		-I- BX : scroll wait time.(4)
;		    CX : scroll count.(100)
;		    DX : scroll step.(2)
;	AX=10 : ��۰�view�ݒ�
;		-I- BX : scroll vram point x.(10)
;		    CX : scroll vram point y.(140)
;		    DX : scroll vram size x.(60)
;		    SI : scroll vram size y.(200)
;	AX=11 : ÷�čs�Ծ��
;		-I- BX : ÷�čs�ԍ���
;	AX=12 : ���ިݸޥ÷�ĉ�ʓ]��3.���̽�۰�
;		-I- BX : 1=vvram1,2=vvram2.
;	AX=13 : ���ިݸޥ÷�Ď�荞��3.���̽�۰�
;		-I- BX : 1=vvram1,2=vvram2.
;	AX=14 : �����ݸޥ÷�ĕ\���P
;	AX=15 : �����ݸޥ�ۯ��1��ر�ر
;	AX=16 : �����ݸޥ�ۯ��1������PUT
;		-I- BX : x.
;		    CX : y.
;		    DX : pattern number.
;	AX=17 : �����ݸޥ�ۯ��1���۰�
;	AX=18 : ���ިݸޥ÷�ĕ\��2.��������\��
;	AX=19 : ��������s���ݒ�
;		-I- BX : �s��
;
; ****************************************************

MAINLP	PROC	NEAR
	CMP	AL,1
	JE	MAINLP01N
	CMP	AL,2
	JE	MAINLP02N
	CMP	AL,3
	JE	MAINLP03N
	CMP	AL,4
	JE	MAINLP04N
	CMP	AL,5
	JE	MAINLP05N
	CMP	AL,6
	JE	MAINLP06N
	CMP	AL,7
	JE	MAINLP07N
	CMP	AL,8
	JE	MAINLP08N
	CMP	AL,9
	JE	MAINLP09N
	CMP	AL,10
	JE	MAINLP10N
	CMP	AL,11
	JE	MAINLP11N
	CMP	AL,12
	JE	MAINLP12N
	CMP	AL,13
	JE	MAINLP13N
	CMP	AL,14
	JE	MAINLP14N

	CMP	AL,15
	JE	MAINLP15N
	CMP	AL,16
	JE	MAINLP16N
	CMP	AL,17
	JE	MAINLP17N

	CMP	AL,18
	JE	MAINLP18N
	CMP	AL,19
	JE	MAINLP19N

	RET
MAINLP01N:
;*;	PRF	"** ending.com **"
	CALL	ALLINIT			; ��������
	JMP	MAINLP_SKIP
MAINLP02N:
	MOV	EDTEXTOFS,BX		; edit text buffer offset.
	MOV	EDTEXTSEG,CX		; edit text buffer segment.
	ADD	BX,8192			;
	MOV	EDWORKOFS,BX		; edit work buffer offset.
	MOV	EDWORKSEG,CX		; edit work buffer segment.
	JMP	MAINLP_SKIP
MAINLP03N:
	CALL	CHK_PRINT		; ÷�������p�\��
	JMP	MAINLP_SKIP
MAINLP04N:
	CALL	ENDTEXT1N		; ���ިݸޥ÷�ĕ\���P
	JMP	MAINLP_SKIP
MAINLP05N:
	MOV	AX,BX			; start x.
	MOV	BX,CX			; start y.
	CALLE	PRNTX_LC_SET		; ÷�Ĉʒu���
	JMP	MAINLP_SKIP
MAINLP06N:
	MOV	AX,BX			; �P�s�̒���
	CALLE	EDT_CENTER		; ÷�ĕҏW����ݸ�
	JMP	MAINLP_SKIP
MAINLP07N:
	CALL	ENDTEXT2N		; ���ިݸޥ÷�ĕ\��2->ARA001
	JMP	MAINLP_SKIP
MAINLP08N:
	MOV	AX,BX			; �P�s�̒���
	CALLE	EDT_RIGHTCUT		; ÷�ĕҏW�E�[���
	JMP	MAINLP_SKIP
MAINLP09N:
	MOV	ROLL_WTIME1,BX		; scroll wait time.
	MOV	ROLL_COUNT,CX		; scroll count.
	MOV	ROLL_STEP,DX		; scroll step.
	JMP	MAINLP_SKIP
MAINLP10N:
	MOV	ROLL_V_PNT_X,BX		; scroll vram point x.
	MOV	ROLL_V_PNT_Y,CX		; scroll vram point y.
	MOV	ROLL_V_SIZ_X,DX		; scroll vram size x.
	MOV	ROLL_V_SIZ_Y,SI		; scroll vram size y.
	JMP	MAINLP_SKIP
MAINLP11N:
	MOV	PRN_CLINE_HI,BX		; ÷�čs�ԍ���
	JMP	MAINLP_SKIP
MAINLP12N:
	CALL	ENDTEXT3N		; ���ިݸޥ÷�ĉ�ʓ]��3.���̽�۰�
	JMP	MAINLP_SKIP
MAINLP13N:
	CALL	ENDTEXT3GET		; ���ިݸޥ÷�Ď�荞��3.���̽�۰�
	JMP	MAINLP_SKIP
MAINLP14N:
	CALL	OPENTEXT1N		; �����ݸޥ÷�ĕ\���P
	JMP	MAINLP_SKIP


MAINLP15N:
	CALL	OPEN_T1_CLS		; �����ݸޥ�ۯ��1��ر�ر
	JMP	MAINLP_SKIP
MAINLP16N:
	MOV	AX,BX			; x.
	MOV	BX,CX			; y.
	CALL	OPEN_T1_PUT		; �����ݸޥ�ۯ��1������PUT
	JMP	MAINLP_SKIP
MAINLP17N:
	CALL	OPEN_T1_SCROL		; �����ݸޥ�ۯ��1���۰�
	JMP	MAINLP_SKIP

MAINLP18N:
	CALL	ENDTEXT2PRN		; ���ިݸޥ÷�ĕ\��2.��������\��
	JMP	MAINLP_SKIP

MAINLP19N:
	MOV	PRNT_LINE_CNT,BX
	JMP	MAINLP_SKIP

MAINLP_SKIP:
	RET
MAINLP	ENDP


; ****************************************************
;	��������
; ****************************************************

ALLINIT	PROC	NEAR

	; get vram address.

	MOV	BX,5			; get vram address.
	CALLE	MAIN_FUNCTION_INTER	; main function inter.
	MOV	MFLAG_MY,BX		; machine flag.

	MOV	AX,DS
	MOV	DX,ES
	MOV	DI,OFFSET ARAVRM	; �u�q�`�l�v���[��
	MOV	CX,5			;
	PUSH	DS			;
	MOV	ES,AX			;
	MOV	DS,DX			;
	REP	MOVSW			; copy.
	POP	DS			;

	RET
ALLINIT	ENDP


; ****************************************************
;	÷�������p�\��
; ****************************************************

CHK_PRINT	PROC	NEAR
	CALLE	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.

	MOV	AX,0			; 0=16x16  1=32x32  2=16x24  3=16x32
	CALLE	VTXSIZ			; character size set.

	MOV	AX,15			; character color 0-15
	CALLE	VTXCOL			; character color set.

	MOV	AX,16			; character hight.
	CALLE	PRNTX_HI_SET		; ÷�č������

	MOV	AX,2			; 0=pset,1=OR,2=fuchi.
	CALLE	PRNTX_TP_SET		; ÷�����߾��

	CALLE	PRNTX_PRN		; ÷�ĕҏW�ޯ̧�\��
	RET
CHK_PRINT	ENDP


; ****************************************************
;	���ިݸޥ÷�ĕ\���P
; ****************************************************

ENDTEXT1N	PROC	NEAR
	CALLE	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.

	MOV	AX,0			; 0=16x16  1=32x32  2=16x24  3=16x32
	CALLE	VTXSIZ			; character size set.

	MOV	AX,0			; character color 0-15
	CALLE	VTXCOL			; character color set.

	MOV	AX,PRN_CLINE_HI		; print char line hight.	
	CALLE	PRNTX_HI_SET		; ÷�č������

	MOV	AX,1			; 0=pset,1=OR,2=fuchi.
	CALLE	PRNTX_TP_SET		; ÷�����߾��

	CALLE	PRNTX_PRN		; ÷�ĕҏW�ޯ̧�\��
	RET
ENDTEXT1N	ENDP


; ****************************************************
;	�����ݸޥ÷�ĕ\���P
; ****************************************************

OPENTEXT1N	PROC	NEAR
	CALLE	PT_VRAM_ID_ALL_ASSIGN	; vram ID all asigned.

	MOV	AX,0			; 0=16x16  1=32x32  2=16x24  3=16x32
	CALLE	VTXSIZ			; character size set.

	MOV	AX,15			; character color 0-15
	CALLE	VTXCOL			; character color set.

	MOV	AX,PRN_CLINE_HI		; print char line hight.	
	CALLE	PRNTX_HI_SET		; ÷�č������

	MOV	AX,2			; 0=pset,1=OR,2=fuchi.
	CALLE	PRNTX_TP_SET		; ÷�����߾��

	CALLE	PRNTX_PRN		; ÷�ĕҏW�ޯ̧�\��
	RET
OPENTEXT1N	ENDP


; ****************************************************
;	�����ݸޥ�ۯ��1��ر�ر
; ****************************************************

OPEN_T1_CLS	PROC	NEAR
	MOV	CX,9		;9=ARA009 : ���z�u�q�`�l(�P�v���[��width47)
	MOV	DX,4		;4=SSEFC0 : visual data segment plean.
	CALL	VRAMASSIGN	; vram assign.

	MOV	VX1,0		; point x1.
	MOV	VY1,0		; point y1.
	MOV	VX2,60		; size x.
	MOV	VY2,1380	; size y.

	MOV	CX,0		; color palet number.
	CALLE	BOXPAL		;�a�n�w�y�C���g

	RET
OPEN_T1_CLS	ENDP


; ****************************************************
;	�����ݸޥ�ۯ��1������PUT
;	-I- AX    : put x.
;	    BX    : put y.
;	    DX    : pattern number.
; ****************************************************

OPEN_T1_PUT	PROC	NEAR
	PUSH	AX
	PUSH	BX
	PUSH	DX

	MOV	CX,9			;9=ARA009 : ���z�u�q�`�l
	MOV	DX,0			;0=SSGR0  : visual data segment plean.
	CALL	VRAMASSIGN		; vram assign.

	POP	DX
	POP	BX
	POP	AX
	CALLE	PT_PATTERN_PUT		; pattern put.

	MOV	CX,0			;0=ARAVRM : �u�q�`�l�v���[��
	MOV	DX,0			;0=SSGR0  : visual data segment plean.
	CALL	VRAMASSIGN		; vram assign.
	RET
OPEN_T1_PUT	ENDP


; ****************************************************
;	�����ݸޥ�ۯ��1���۰�
; ****************************************************

OPEN_T1_SCROL	PROC	NEAR
	MOV	CX,9			;9=ARA009 : ���z�u�q�`�l
	MOV	DX,0			; plean number.
	CALL	GET_VRAM_SEGMENT	; get vram segment.
	MOV	SOUDATASEG,DX		; source data segment.

	MOV	CX,0			;0=ARAVRM : �u�q�`�l�v���[��
	MOV	DX,3			; plean number.
	CALL	GET_VRAM_SEGMENT	; get vram segment.
	MOV	DESDATASEG,DX		; destination data segment.

	MOV	CX,9			;9=ARA009 : ���z�u�q�`�l
	MOV	DX,3			;3=SSSOU0 : visual data segment plean.
	CALL	VRAMASSIGN		; vram assign.

	MOV	CX,0			;0=ARAVRM : �u�q�`�l�v���[��
	MOV	DX,2			;2=SSDES0 : visual data segment plean.
	CALL	VRAMASSIGN		; vram assign.

	CALL	VRMSCROLL		; vram scroll.
	RET
OPEN_T1_SCROL	ENDP


; ****************************************************
;	���ިݸޥ÷�ĕ\��2.��۰�
; ****************************************************

ENDTEXT2N	PROC	NEAR
	MOV	CX,5			;5=ARA005
	MOV	DX,0			; plean number.
	CALL	GET_VRAM_SEGMENT	; get vram segment.
	MOV	SOUDATASEG,DX		; source data segment.

	MOV	CX,0			;0=ARAVRM : �u�q�`�l�v���[��
	MOV	DX,1			; plean number.
	CALL	GET_VRAM_SEGMENT	; get vram segment.
	MOV	DESDATASEG,DX		; destination data segment.

	MOV	CX,5		;5=ARA005
	MOV	DX,3		;3=SSSOU0 : visual data segment plean.
	CALL	VRAMASSIGN	; vram assign.

	MOV	CX,0		;0=ARAVRM : �u�q�`�l�v���[��
	MOV	DX,2		;2=SSDES0 : visual data segment plean.
	CALL	VRAMASSIGN	; vram assign.

	MOV	CX,5		;5=ARA005 : ���z�u�q�`�l(�P�v���[��width60)
	MOV	DX,6		;6=SEGVT0 : visual data segment plean.
	CALL	VRAMASSIGN	; vram assign.

	MOV	CX,5		;5=ARA005 : ���z�u�q�`�l(�P�v���[��width60)
	MOV	DX,4		;4=SSEFC0 : visual data segment plean.
	CALL	VRAMASSIGN	; vram assign.

	MOV	VX1,0		; point x1.
	MOV	VY1,0		; point y1.
	MOV	VX2,60		; size x.
	MOV	VY2,1000	;400	; size y.
	MOV	CX,15		; color palet number.
	CALLE	BOXPAL		;�a�n�w�y�C���g

	MOV	AX,0		; 0=16x16  1=32x32  2=16x24  3=16x32
	CALLE	VTXSIZ		; character size set.

	MOV	AX,0		; character color 0-15
	CALLE	VTXCOL		; character color set.

	MOV	AX,PRN_CLINE_HI	; print char line hight.	
	CALLE	PRNTX_HI_SET	; ÷�č������

	MOV	AX,1		; 0=pset,1=OR,2=fuchi.
	CALLE	PRNTX_TP_SET	; ÷�����߾��

	CALLE	PRNTX_PRN	; ÷�ĕҏW�ޯ̧�\��

	MOV	CX,0		;0=ARAVRM : �u�q�`�l�v���[��
	MOV	DX,6		;6=SEGVT0 : visual data segment plean.
	CALL	VRAMASSIGN	; vram assign.

	CALL	VRMSCROLL	; vram scroll.

	RET
ENDTEXT2N	ENDP


; ****************************************************
;	���ިݸޥ÷�ĕ\��2.��������\��
; ****************************************************

ENDTEXT2PRN	PROC	NEAR
	MOV	CX,5			;5=ARA005
	MOV	DX,0			; plean number.
	CALL	GET_VRAM_SEGMENT	; get vram segment.
	MOV	SOUDATASEG,DX		; source data segment.

	MOV	CX,0			;0=ARAVRM : �u�q�`�l�v���[��
	MOV	DX,1			; plean number.
	CALL	GET_VRAM_SEGMENT	; get vram segment.
	MOV	DESDATASEG,DX		; destination data segment.

	MOV	CX,5		;5=ARA005
	MOV	DX,3		;3=SSSOU0 : visual data segment plean.
	CALL	VRAMASSIGN	; vram assign.

	MOV	CX,0		;0=ARAVRM : �u�q�`�l�v���[��
	MOV	DX,2		;2=SSDES0 : visual data segment plean.
	CALL	VRAMASSIGN	; vram assign.

	MOV	CX,5		;5=ARA005 : ���z�u�q�`�l(�P�v���[��width60)
	MOV	DX,6		;6=SEGVT0 : visual data segment plean.
	CALL	VRAMASSIGN	; vram assign.

	MOV	CX,5		;5=ARA005 : ���z�u�q�`�l(�P�v���[��width60)
	MOV	DX,4		;4=SSEFC0 : visual data segment plean.
	CALL	VRAMASSIGN	; vram assign.

	MOV	VX1,0		; point x1.
	MOV	VY1,0		; point y1.
	MOV	VX2,60		; size x.
	MOV	VY2,1000	;400	; size y.
	MOV	CX,15		; color palet number.
	CALLE	BOXPAL		;�a�n�w�y�C���g

	MOV	AX,0		; 0=16x16  1=32x32  2=16x24  3=16x32
	CALLE	VTXSIZ		; character size set.

	MOV	AX,0		; character color 0-15
	CALLE	VTXCOL		; character color set.

	MOV	AX,PRN_CLINE_HI	; print char line hight.	
	CALLE	PRNTX_HI_SET	; ÷�č������

	MOV	AX,1		; 0=pset,1=OR,2=fuchi.
	CALLE	PRNTX_TP_SET	; ÷�����߾��

	CALLE	PRNTX_PRN	; ÷�ĕҏW�ޯ̧�\��

	MOV	CX,0		;0=ARAVRM : �u�q�`�l�v���[��
	MOV	DX,6		;6=SEGVT0 : visual data segment plean.
	CALL	VRAMASSIGN	; vram assign.

	CALL	VRMPRINT	; vram print.

	RET
ENDTEXT2PRN	ENDP


; ****************************************************
;	���ިݸޥ÷�ĉ�ʓ]��3.���̽�۰�
;	-I- BX : 1=vvram1,2=vvram2,3=vvram3.
; ****************************************************

ENDTEXT3N	PROC	NEAR
	CMP	BX,2			;
	JE	ENDTEXT3N_12		;
	CMP	BX,3			;
	JE	ENDTEXT3N_13		;
ENDTEXT3N_11:
	MOV	VRAM_ID_NUM,6		; 6=ARA006
	JMP	ENDTEXT3N_19		;
ENDTEXT3N_12:
	MOV	VRAM_ID_NUM,7		; 7=ARA007
	JMP	ENDTEXT3N_19		;
ENDTEXT3N_13:
	MOV	VRAM_ID_NUM,8		; 8=ARA008
	JMP	ENDTEXT3N_19		;
ENDTEXT3N_19:

	MOV	CX,VRAM_ID_NUM		; vram ID num.
	MOV	DX,0			; plean number.
	CALL	GET_VRAM_SEGMENT	; get vram segment.
	MOV	SOUDATASEG,DX		; source data segment.

	MOV	CX,0			;0=ARAVRM : �u�q�`�l�v���[��
	MOV	DX,1			; plean number.
	CALL	GET_VRAM_SEGMENT	; get vram segment.
	MOV	DESDATASEG,DX		; destination data segment.

	MOV	CX,VRAM_ID_NUM		; vram ID num.
	MOV	DX,3			;3=SSSOU0 : visual data segment plean.
	CALL	VRAMASSIGN		; vram assign.

	MOV	CX,0			;0=ARAVRM : �u�q�`�l�v���[��
	MOV	DX,2			;2=SSDES0 : visual data segment plean.
	CALL	VRAMASSIGN		; vram assign.

	CALL	VRMSCROLL		; vram scroll.

	RET
ENDTEXT3N	ENDP


; ****************************************************
;	���ިݸޥ÷�Ď�荞��3.���̽�۰�
;	-I- BX : 1=vvram1,2=vvram2,3=vvram3.
; ****************************************************

ENDTEXT3GET	PROC	NEAR
	CMP	BX,2			;
	JE	ENDTEXT3GET_12		;
	CMP	BX,3			;
	JE	ENDTEXT3GET_13		;
ENDTEXT3GET_11:
	MOV	VRAM_ID_NUM,6		; 6=ARA006
	MOV	CLEAR_LINE_CNT,1630	; clear line count.
	JMP	ENDTEXT3GET_19		;
ENDTEXT3GET_12:
	MOV	VRAM_ID_NUM,7		; 7=ARA007
	MOV	CLEAR_LINE_CNT,1290	; clear line count.
	JMP	ENDTEXT3GET_19		;
ENDTEXT3GET_13:
	MOV	VRAM_ID_NUM,8		; 8=ARA008
	MOV	CLEAR_LINE_CNT,1630	; clear line count.
	JMP	ENDTEXT3GET_19		;
ENDTEXT3GET_19:

	MOV	CX,VRAM_ID_NUM	; vram ID num.
	MOV	DX,6		;6=SEGVT0 : visual data segment plean.
	CALL	VRAMASSIGN	; vram assign.

	MOV	CX,VRAM_ID_NUM	; vram ID num.
	MOV	DX,4		;4=SSEFC0 : visual data segment plean.
	CALL	VRAMASSIGN	; vram assign.

	MOV	VX1,0		; point x1.
	MOV	VY1,0		; point y1.
	MOV	VX2,40		; size x.
	MOVX	VY2,CLEAR_LINE_CNT	; clear line count.
	MOV	CX,15		; color palet number.
	CALLE	BOXPAL		;�a�n�w�y�C���g

	MOV	AX,0		; 0=16x16  1=32x32  2=16x24  3=16x32
	CALLE	VTXSIZ		; character size set.

	MOV	AX,0		; character color 0-15
	CALLE	VTXCOL		; character color set.

	MOV	AX,PRN_CLINE_HI	; print char line hight.	
	CALLE	PRNTX_HI_SET	; ÷�č������

	MOV	AX,1		; 0=pset,1=OR,2=fuchi.
	CALLE	PRNTX_TP_SET	; ÷�����߾��

	CALLE	PRNTX_PRN	; ÷�ĕҏW�ޯ̧�\��

	MOV	CX,0		;0=ARAVRM : �u�q�`�l�v���[��
	MOV	DX,6		;6=SEGVT0 : visual data segment plean.
	CALL	VRAMASSIGN	; vram assign.
	RET
ENDTEXT3GET	ENDP


; ****************************************************
;	 vram scroll.
; ****************************************************

VRMSCROLL	PROC	NEAR
	MOV	VX1,0			; point x1.
	MOV	VY1,0			; point y1.
	MOVX	VX2,ROLL_V_SIZ_X	; scroll vram size x.
	MOVX	VY2,ROLL_V_SIZ_Y	; scroll vram size y.
	MOVX	VX3,ROLL_V_PNT_X	; scroll vram point x.
	MOVX	VY3,ROLL_V_PNT_Y	; scroll vram point y.

	MOV	CX,ROLL_COUNT		; scroll count.
VRMSCROLL_LOOP:				;
	PUSH	CX			;
	MOV	AX,ROLL_WTIME1		; scroll wait time.
	CALLE	TMVSET			; V-SYNC timer set.

	MOV	DX,SOUDATASEG	; source data segment.
	MOVX	ES,DESDATASEG	; destination data segment.
	CALLE	MOV1VR		; vram to vram move 1 plean.

	ADDX	VY1,ROLL_STEP	; scroll step.

	CALLE	TMVEWT		; V-SYNC timer end wait.
	POP	CX		;
	LOOP	VRMSCROLL_LOOP

	RET
VRMSCROLL	ENDP


; ****************************************************
;	vram print.
; ****************************************************

VRMPRINT	PROC	NEAR
	MOV	PRNT_X1,0		; print vram point x.
	MOV	PRNT_Y1,0		; print vram point y.
	MOVX	PRNT_X2,PRNT_V_PNT_X	; print vram point x.
	MOVX	PRNT_Y2,PRNT_V_PNT_Y	; print vram point y.
	MOV	PRNT_SCRL_X1,0		; print vram now point x.
	MOV	PRNT_SCRL_Y1,0		; print vram now point y.

	MOV	PRNT_NOW_PNT,0		; print now point.

	MOV	CX,PRNT_LINE_CNT	; print line count.
VRMPRINT_LOOP:				;
	PUSH	CX			;

	CMPX	PRNT_NOW_PNT,PRNT_LN_VEW_MAX	; print line view max.
	JB	VRMPRINT_PRN			;
VRMPRINT_SCRL:				;

	MOVX	VX1,PRNT_SCRL_X1	; print vram now point x.
	MOVX	VY1,PRNT_SCRL_Y1	; print vram now point y.

	MOVX	VX2,PRNT_VEW_SIZ_X	; print vram view size x.
	MOVX	VY2,PRNT_VEW_SIZ_Y	; print vram view size y.

	MOVX	VX3,PRNT_VEW_PNT_X	; print vram view point x.
	MOVX	VY3,PRNT_VEW_PNT_Y	; print vram view point y.

	MOV	CX,4
VRMPRINT_SCRL_LOOP:			;
	PUSH	CX			;
	MOV	AX,3			;
	CALLE	TMVSET			; V-SYNC timer set.
	ADD	VY1,5			;
	SUB	VY2,5			;
	MOV	DX,SOUDATASEG		; source data segment.
	MOVX	ES,DESDATASEG		; destination data segment.
	CALLE	MOV1VR			; vram to vram move 1 plean.
	CALLE	TMVEWT			; V-SYNC timer end wait.
	POP	CX			;
	LOOP	VRMPRINT_SCRL_LOOP	;

	MOV	AX,3			;
	CALLE	TMVSET			; V-SYNC timer set.
	ADD	VY1,3			;
	SUB	VY2,3			;
	MOV	DX,SOUDATASEG		; source data segment.
	MOVX	ES,DESDATASEG		; destination data segment.
	CALLE	MOV1VR			; vram to vram move 1 plean.
	CALLE	TMVEWT			; V-SYNC timer end wait.

	ADDX	PRNT_SCRL_Y1,PRNT_HIGHT	; scroll step.

VRMPRINT_PRN:				;
	MOV	AX,30
	CALLE	TMVSET			; V-SYNC timer set.

	MOVX	VX1,PRNT_X1		; print vram point x.
	MOVX	VY1,PRNT_Y1		; print vram point y.

	MOVX	VX2,PRNT_V_SIZ_X	; print vram size x.
	MOVX	VY2,PRNT_V_SIZ_Y	; print vram size y.

	MOVX	VX3,PRNT_X2		; print vram now point x.
	MOVX	VY3,PRNT_Y2		; print vram now point y.

	MOV	CX,PRNT_V_SIZ_X		; print vram size x.
	CALL	VRMPRINT_LIN		; vram print 1 line.

	INC	PRNT_NOW_PNT		; print line max.

	ADDX	PRNT_Y1,PRNT_HIGHT		; scroll step.

	CMPX	PRNT_NOW_PNT,PRNT_LN_VEW_MAX	; print line view max.
	JNB	VRMPRINT_NEXT			;
	ADDX	PRNT_Y2,PRNT_HIGHT		; scroll step.
VRMPRINT_NEXT:
	CALLE	TMVEWT			; V-SYNC timer end wait.
	POP	CX			;
	LOOPX	VRMPRINT_LOOP

	RET
VRMPRINT	ENDP


; ****************************************************
;	vram print 1 line.
;	-I/O- CX  : colum count.
;	      VX1 : point x.
;	      VY1 : print y.
;	      VX3 : vram print x.
;	      VY3 : vram print y.
; ****************************************************

VRMPRINT_LIN	PROC	NEAR
	MOV	VX2,2			; print vram size x.
	MOV	VY2,23			; print vram size y.
	SHR	CX,1			;
VRMPRINT_LIN_LOOP:
	PUSH	CX

	CALL	VRM_IMAGE_CHK		; vram image check.
	CMP	BX,0			; image value.
	JE	VRMPRINT_LIN_NONE	;
	CMP	BX,3			; image value.
	JLE	VRMPRINT_LIN_DOT	;
	CMP	BX,5			; image value.
	JLE	VRMPRINT_LIN_DOT2	;

VRMPRINT_LIN_NORMAL:
	MOV	AX,6			;
	CALLE	TMVSET			; V-SYNC timer set.
	JMP	VRMPRINT_LIN_5		;
VRMPRINT_LIN_NONE:
	MOV	AX,0			;
	CALLE	TMVSET			; V-SYNC timer set.
	JMP	VRMPRINT_LIN_5		;
VRMPRINT_LIN_DOT:
	MOV	AX,60			;
	CALLE	TMVSET			; V-SYNC timer set.
	JMP	VRMPRINT_LIN_5		;

VRMPRINT_LIN_DOT2:
	MOV	AX,20			;
	CALLE	TMVSET			; V-SYNC timer set.

VRMPRINT_LIN_5:
	MOV	DX,SOUDATASEG		; source data segment.
	MOVX	ES,DESDATASEG		; destination data segment.
	CALLE	MOV1VR			; vram to vram move 1 plean.

	CALLE	TMVEWT			; V-SYNC timer end wait.
VRMPRINT_LIN_NEXT:
	ADD	VX1,2			; point x.
	ADD	VX3,2			; vram print x.
	POP	CX
	LOOP	VRMPRINT_LIN_LOOP
	RET
VRMPRINT_LIN	ENDP


; ****************************************************
;	vram image check.
;	-I- VX1 : point x.
;	    VY1 : print y.
;	-O- BX  : image value.
; ****************************************************

VRM_IMAGE_CHK	PROC	NEAR
	MOV	AX,VY1			; print y.
	MOV	BX,60			; visual data plean width.
	MUL	BX			; visual data plean width.
	ADD	AX,VX1			; point x.
	MOV	SI,AX			;
	MOV	DX,SOUDATASEG		; source data segment.
	MOV	DI,60			; visual data plean width.
	DEC	DI
	DEC	DI

	PUSH	DS
	MOV	DS,DX
	MOV	BX,0
	MOV	CX,16
VRM_IMAGE_CHK_LOOP:
	LODSB
	CMP	AL,0FFH			; white
	JE	VRM_IMAGE_CHK_5
	CMP	AL,0
	JNE	VRM_IMAGE_CHK_3
	INC	BX
	INC	BX
VRM_IMAGE_CHK_3:
	INC	BX

VRM_IMAGE_CHK_5:
	LODSB
	CMP	AL,0FFH			; white
	JE	VRM_IMAGE_CHK_NEXT
	CMP	AL,0
	JNE	VRM_IMAGE_CHK_7
	INC	BX
	INC	BX
VRM_IMAGE_CHK_7:
	JE	VRM_IMAGE_CHK_NEXT
	INC	BX
VRM_IMAGE_CHK_NEXT:
	ADD	SI,DI
	LOOP	VRM_IMAGE_CHK_LOOP
	POP	DS
	RET
VRM_IMAGE_CHK	ENDP


; ****************************************************
;	vram assign.
;	-I- CX : vram ID table.
;		0=ARAVRM : �u�q�`�l�v���[��
;		1=ARA001 : ���z�u�q�`�l�v���[��(width40)
;		2=ARA002 : ���z�u�q�`�l�v���[��(width42)
;		3=ARA003 : ���z�u�q�`�l�v���[��(width60)
;		4=ARA004 : ���z�u�q�`�l�v���[��(width56)
;		5=ARA005 : ���z�u�q�`�l(�P�v���[��width60)
;		6=ARA006 : ���z�u�q�`�l(�P�v���[��width40)
;		7=ARA007 : ���z�u�q�`�l(�P�v���[��width40)
;		8=ARA008 : ���z�u�q�`�l(�P�v���[��width40)
;		9=ARA009 : ���z�u�q�`�l(�P�v���[��width47)
;	    DX : assign ID table.
;		0=SSGR0  : visual data segment plean.
;		1=SSGRV0 : visual data segment plean.
;		2=SSDES0 : visual data segment plean.
;		3=SSSOU0 : visual data segment plean.
;		4=SSEFC0 : visual data segment plean.
;		5=SSCUR0 : visual data segment plean.
;		6=SEGVT0 : visual data segment plean.
; ****************************************************

VRAMASSIGN	PROC	NEAR
	MOV	BX,25			; vram assign.
	CALLE	MAIN_FUNCTION_INTER	; main function inter.
	RET
VRAMASSIGN	ENDP


; *********************************************************
;	get vram segment.
;	-I- CX : vram ID table.
;		0=ARAVRM : �u�q�`�l�v���[��
;		1=ARA001 : ���z�u�q�`�l�v���[��(width40)
;		2=ARA002 : ���z�u�q�`�l�v���[��(width42)
;		3=ARA003 : ���z�u�q�`�l�v���[��(width60)
;		4=ARA004 : ���z�u�q�`�l�v���[��(width56)
;		5=ARA005 : ���z�u�q�`�l(�P�v���[��width60)
;		6=ARA006 : ���z�u�q�`�l(�P�v���[��width40)
;		7=ARA007 : ���z�u�q�`�l(�P�v���[��width40)
;		8=ARA008 : ���z�u�q�`�l(�P�v���[��width40)
;		9=ARA009 : ���z�u�q�`�l(�P�v���[��width47)
;	    DX : plean number.
;	-O- DX : segment.
; *********************************************************

GET_VRAM_SEGMENT	PROC	NEAR
	MOV	BX,27			; get vram plean segment.
	CALLE	MAIN_FUNCTION_INTER	; main function inter.
	RET
GET_VRAM_SEGMENT	ENDP


; ****************************************************
;	data.
; ****************************************************

PUBLIC	EDTEXTSEG		; edit text buffer segment.
PUBLIC	EDTEXTOFS		; edit text buffer offset.
PUBLIC	EDWORKSEG		; edit work buffer segment.
PUBLIC	EDWORKOFS		; edit work buffer offset.

EXTRN	VX1:WORD		; point x1.
EXTRN	VY1:WORD		; point y1.
EXTRN	VX2:WORD		; point x2.
EXTRN	VY2:WORD		; point y2.
EXTRN	VX3:WORD		; point x3.
EXTRN	VY3:WORD		; point y3.

		EVEN
EDTEXTSEG	DW	0	; edit text buffer segment.
EDTEXTOFS	DW	0	; edit text buffer offset.
EDWORKSEG	DW	0	; edit work buffer segment.
EDWORKOFS	DW	0	; edit work buffer offset.

PRN_CLINE_HI	DW	22	; print char line hight.	

ROLL_WTIME1	DW	4	; scroll wait time.
ROLL_COUNT	DW	100	; scroll count.
ROLL_STEP	DW	2	; scroll step.
ROLL_V_PNT_X	DW	10	; scroll vram point x.
ROLL_V_PNT_Y	DW	140	; scroll vram point y.
ROLL_V_SIZ_X	DW	60	; scroll vram size x.
ROLL_V_SIZ_Y	DW	200	; scroll vram size y.

PRNT_LN_VEW_MAX	DW	12	; print line view max.
PRNT_LINE_CNT	DW	10	; print line count.
PRNT_NOW_PNT	DW	10	; print now point.
PRNT_V_PNT_X	DW	10	; print vram point x.
PRNT_V_PNT_Y	DW	84	; print vram point y.
PRNT_V_SIZ_X	DW	52	; print vram size x.
PRNT_V_SIZ_Y	DW	16	; print vram size y.

PRNT_VEW_PNT_X	DW	10	; print vram view point x.
PRNT_VEW_PNT_Y	DW	84	; print vram view point y.
PRNT_VEW_SIZ_X	DW	52	; print vram view size x.
PRNT_VEW_SIZ_Y	DW	276	; print vram view size y.
PRNT_HIGHT	DW	23	; scroll step.

PRNT_X1		DW	0	; print vram now point x.
PRNT_Y1		DW	0	; print vram now point y.
PRNT_X2		DW	0	; print vram now point x.
PRNT_Y2		DW	0	; print vram now point y.
PRNT_SCRL_X1	DW	0	; print vram now point x.
PRNT_SCRL_Y1	DW	0	; print vram now point y.

MFLAG_MY	DW	MFLAG_PCAT	; machine flag.

ARAVRM		LABEL	WORD		; �u�q�`�l�v���[��
		DW	VGAVRAM_SEG_G0	; �u�q�`�l�v���[���O
		DW	VGAVRAM_SEG_G1	; �u�q�`�l�v���[���P
		DW	VGAVRAM_SEG_G2	; �u�q�`�l�v���[���Q
		DW	VGAVRAM_SEG_G3	; �u�q�`�l�v���[���R
		DW	VGAVRMWIDTH	; �u�q�`�l��

SOUDATASEG	DW	0		; source data segment.
DESDATASEG	DW	0		; destination data segment.

VRAM_ID_NUM	DW	0		; vram ID num.
CLEAR_LINE_CNT	DW	0		; clear line count.

CODE	ENDS
	END
;
;	end of "MAINLP.ASM"
;
