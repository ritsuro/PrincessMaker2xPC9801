; "EMSDRV.ASM" PC-9801UV11 make by R.H 1990/12/29
;
;	EMM driver.
;
; public subroutine.

VEC_EMM_OFS	EQU	67H*4		; EMM int vector offset.
VEC_EMM_SEG	EQU	67H*4+2		; EMM int vector segment.

EMM	MACRO	QQQQ
	PUSH	DS
	MOV	AH,QQQQ
	INT	67H
	POP	DS
	ENDM


EMMCOD	SEGMENT	PUBLIC	'EMMCOD'

	ASSUME	CS:EMMCOD,DS:EMMDAT

;	NEAR call.

PUBLIC	EMMCHK				; EMM check.
PUBLIC	EMM_G_S				; EMM Get Status.
PUBLIC	EMM_G_P_FA			; EMM Get Page Frame Address.
PUBLIC	EMM_G_U_PC			; EMM Get Unallocated Page Count.
PUBLIC	EMM_A_P				; EMM Allocate Pages.
PUBLIC	EMM_MU_H_P			; EMM Map/Unmap Handle Pages.
PUBLIC	EMM_D_P				; EMM Deallocate Pages.


;	EMM check.
;	-O- AX : 0=none,1=EMMset

EMMCHK	PROC	NEAR
	PUSH	DS
	MOV	AX,SEG EMMDAT
	MOV	DS,AX

	MOV	AX,0
	MOV	ES,AX
	MOV	AX,ES:[VEC_EMM_SEG]	; EMM int vector segment.
	MOV	ES,AX
	MOV	DI,10			; character device file name.
	MOV	SI,OFFSET EMMXXXX0	; EMM character device file name.
	MOV	CX,8			; string length.
	REPE	CMPSB			;
	JNE	EMMCHK_NONE		;

EMMCHK_EXIT:
	MOV	AX,1			; 1=EMMset
	POP	DS
	RET
EMMCHK_NONE:
	MOV	AX,0			; 0=none
	POP	DS
	RET
EMMCHK	ENDP


;	EMM Get Status.
;	-O- AX : EMM status (0=normal,0<>error)

EMM_G_S	PROC	NEAR
	PUSH	DS
	MOV	AX,SEG EMMDAT
	MOV	DS,AX

	EMM	40H			; Get Status.
	MOV	AL,AH
	MOV	AH,0

	POP	DS
	RET
EMM_G_S	ENDP


;	EMM Get Page Frame Address.
;	-O- AX : EMM status (0=normal,0<>error)
;	    BX : EMM page fream segment.

EMM_G_P_FA	PROC	NEAR
	PUSH	DS
	MOV	AX,SEG EMMDAT
	MOV	DS,AX

	EMM	41H			; Get Page Frame Segment Address.
	MOV	EMM_PAGE_FREAM_SEG,BX	; EMM page fream segment.
	MOV	AL,AH
	MOV	AH,0

	POP	DS
	RET
EMM_G_P_FA	ENDP


;	EMM Get Unallocated Page Count.
;	-O- AX : EMM status (0=normal,0<>error)
;	    BX : EMM unallocated page count.
;	    DX : EMM all page count.

EMM_G_U_PC	PROC	NEAR
	PUSH	DS
	MOV	AX,SEG EMMDAT
	MOV	DS,AX

	EMM	42H			; Get Unallocated Page Count.
	MOV	EMM_UNALLOC_PAGE_CNT,BX	; EMM unallocated page count.
	MOV	EMM_ALL_PAGE_CNT,DX	; EMM all page count.
	MOV	AL,AH
	MOV	AH,0

	POP	DS
	RET
EMM_G_U_PC	ENDP


;	EMM Allocate Pages.
;	-O- AX : EMM status (0=normal,0<>error)
;	    DX : EMM handle.

EMM_A_P		PROC	NEAR
	PUSH	DS
	MOV	AX,SEG EMMDAT
	MOV	DS,AX

	MOV	BX,EMM_UNALLOC_PAGE_CNT	; EMM unallocated page count.
	EMM	43H			; Allocate Pages.
	MOV	EMM_HANDLE,DX		; EMM handle.
	MOV	AL,AH
	MOV	AH,0

	MOV	BX,EMM_UNALLOC_PAGE_CNT	; EMM unallocated page count.
	MOV	EMM_ALLOC_PAGE_CNT,BX	; EMM allocated page count.
	MOV	EMM_UNALLOC_PAGE_CNT,0	; EMM unallocated page count.

	POP	DS
	RET
EMM_A_P		ENDP


;	EMM Map/Unmap Handle Pages.
;	-I- BX : logical page number.
;	    AX : physical page number.
;	-O- AX : EMM status (0=normal,0<>error)

EMM_MU_H_P	PROC	NEAR
	PUSH	DS
	MOV	DX,SEG EMMDAT
	MOV	DS,DX

	MOV	DX,EMM_HANDLE		; EMM handle.
	EMM	44H			; Allocate Pages.
	MOV	AL,AH
	MOV	AH,0

	POP	DS
	RET
EMM_MU_H_P	ENDP


;	EMM Deallocate Pages.
;	-O- AX : EMM status (0=normal,0<>error)

EMM_D_P		PROC	NEAR
	PUSH	DS
	MOV	AX,SEG EMMDAT
	MOV	DS,AX

	MOV	DX,EMM_HANDLE		; EMM handle.
	EMM	45H			; Deallocate Pages.
	MOV	AL,AH
	MOV	AH,0

	MOV	DX,EMM_ALLOC_PAGE_CNT	; EMM allocated page count.
	MOV	EMM_UNALLOC_PAGE_CNT,DX	; EMM unallocated page count.
	MOV	EMM_ALLOC_PAGE_CNT,0	; EMM allocated page count.

	POP	DS
	RET
EMM_D_P		ENDP

EMMCOD	ENDS


EMMDAT	SEGMENT	PUBLIC	'EMMDAT'

EMMXXXX0	DB	"EMMXXXX0",0,0	; EMM character device file name.

EMM_HANDLE		DW	0	; EMM handle.
EMM_PAGE_FREAM_SEG	DW	0	; EMM page fream segment.
EMM_ALL_PAGE_CNT	DW	0	; EMM all page count.
EMM_UNALLOC_PAGE_CNT	DW	0	; EMM unallocated page count.
EMM_ALLOC_PAGE_CNT	DW	0	; EMM allocated page count.

EMMDAT	ENDS

	END
;
;	end of "EMSDRV.ASM"
;
