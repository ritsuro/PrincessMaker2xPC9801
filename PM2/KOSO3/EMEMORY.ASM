; "EMEMORY.ASM" PC-9801UV11 make by R.H 1990/12/29
;
;	Expanded memory i/o.
;
; public subroutine.

DEBUG_FLAG_1	EQU	0		; debug flag no.1
DEBUG_FLAG_2	EQU	0		; debug flag no.2
DEBUG_FLAG_3	EQU	0		; debug flag no.3
DTALEN		EQU	65530		; DTA length.(DISKIO.ASM)

; data file file name "NAMEFILE.EMS"
; data file format.
;
;	<OLD>	|.filename    .size   CL|
;	<OLD>	|0         1  .      2RF|
;	<OLD>	|01234567890123456789012|
;	<OLD>	|	width 21+2=23   |
;	<OLD>	|BTN      PT1     8002))|
;	<OLD>	|BTNSCD   PT1     1192))|
;	<OLD>	|BTNSCW   PT1     1764))|
;	<OLD>	|BTNWK    PT1     5988))|
;	<OLD>	|C1       PT1    40548))|
;	<OLD>	|C2       PT1    48560))|
;	<OLD>	|C3       PT1    47754))|
;
;		|.filename    .size CL|
;		|0         1  .     RF|
;		|012345678901234567890|
;		|	width 19+2=21 |
;		|BTN      PT1         |
;		|BTNSCD   PT1         |
;		|BTNSCW   PT1         |
;		|BTNWK    PT1         |
;		|C1       PT1         |
;		|C2       PT1         |
;		|C3       PT1         |
;
; Expanded memory page dir table.
;
;	<OLD>  	|0.          11.12.13 .14.15 .16.17 .18.19
;	<OLD>  	|[...12byte...][1word][1word][1work][1word]
;	<OLD>  	|[ file name  ][e.o.s][page ][ofset][size ]
;
;		|0.          11.12.13 .14.15 .16.17 .18.19
;		|[...12byte...][1word][1word][1work][1word]
;		|[ file name  ][e.o.s][page ][ofset][size ]
;
; physical page fream map.
;	page 0.[ 64k extended area  ] [ chash buffer 16k fream ]
;	page 1.[        .           ]
;	page 2.[        .           ]
;	page 3.[        .           ]
;
; extended memory map.
;	page 0.[ 64k extended area	]
;	page 1.[	.	  	]
;	page 2.[	.	  	]
;	page 3.[	.	  	]
;	page 4.[ data name table page     ]
;	page 5.[ chash buffer 16k fream 0 ]
;	page 6.[			1 ]
;	page 7.[			2 ]
;	page ..[			. ]
;	page ..[			. ]

EXT64K_TOP_PAGE	EQU	0	; 64k extended area top page.
HEAD_TBLNX_PAGE	EQU	4	; next header table page.
HEAD_TABLE_PAGE	EQU	0	; header table page.

NAME_FLNM	EQU	0	; file name colum.
NAME_FLNM_LEN	EQU	12	; file name length.
NAME_SIZE	EQU	16	; file size colum.
NAME_SIZE_LEN	EQU	5	; file size length.
NAME_NEXT	EQU	21	; next file name.
;;NAME_NEXT	EQU	23	; next file name.(OLD)

NAME_EOS	EQU	12	; name e.o.s colum.
NAME_BANK_NO	EQU	14	; page number colum.
NAME_B_OFFSET	EQU	16	; page offset colum.
NAME_B_SIZE	EQU	18	; page size colum.

FLNLEN		EQU	8	; ƒtƒ@ƒCƒ‹–¼‚Ì’·‚³
FLTLEN		EQU	3	; Šg’£Žq‚Ì’·‚³

INCLUDE	TSTSET.INC
INCLUDE	MESSAGE.INC

;	CODE01 call.

CALLC	MACRO	SUB1
	LOCAL	L2
CODE01	SEGMENT	PUBLIC	'CODE01'
	ASSUME	CS:CODE01,DS:DATA
L2	PROC	FAR
	EXTRN	SUB1:NEAR
	CALL	SUB1
	RET
L2	ENDP
CODE01	ENDS
	ASSUME	CS:EMMCOD,DS:DATA
	CALL	L2
	ENDM

;	EMMCOD -> CODE01

CODE_IN		MACRO
	LOCAL	L1
	JMP	FAR PTR L1
CODE01	SEGMENT	PUBLIC	'CODE01'
	ASSUME	CS:CODE01,DS:DATA
L1:
	ENDM

;	CODE01 -> EMMCOD

CODE_OUT	MACRO
	LOCAL	L1
	JMP	FAR PTR L1
CODE01	ENDS
	ASSUME	CS:EMMCOD,DS:DATA
L1:
	ENDM

JMPEQ	MACRO	LBL
	LOCAL	L1
	JNE	L1
	JMP	LBL
L1:
	ENDM

JMPNE	MACRO	LBL
	LOCAL	L1
	JE	L1
	JMP	LBL
L1:
	ENDM

EMMCOD	SEGMENT	PUBLIC	'EMMCOD'

	ASSUME	CS:EMMCOD,DS:DATA

PUBLIC	EMEMCHECK		; (far)Expanded memory check.
PUBLIC	EMEMAREA64K		; (far)Expanded memory 64k area allocate.
PUBLIC	EMEMALLOC		; (far)Expanded memory allocate.
PUBLIC	EMEMDEALLOC		; (far)Expanded memory deallocate.
PUBLIC	EMEMQUICK		; (far)Expanded memory data name search.
PUBLIC	EMEMLOAD		; (far)Expanded memory data load.

EXTRN	EMSCHK:NEAR		; EMS check.
EXTRN	EMSOPN:NEAR		; EMS open.
EXTRN	EMSCLS:NEAR		; EMS close.
EXTRN	EMSSEK:NEAR		; EMS seek.
EXTRN	EMS64K:NEAR		; EMS seek 64k fream.


;	Expanded memory check.
;	-O- AX : 1=ok,0=Expanded memory none.
;	    DX : free page counter.
;	    ES : EMS fream segment.

EMEMCHECK	PROC	FAR
	CALL	EMSCHK				; EMS check.
	MOV	FREE_PAGE_COUNTER,BX		; free page counter.
	MOV	FREAM_SEGMENT,DX		; EMS fream segment.

IF	DEBUG_FLAG_1				; debug flag no.1
	CODE_IN
	PRV	"EMSCHK FREE_PAGE_COUNTER=",FREE_PAGE_COUNTER
	PRV	"EMSCHK AX=",AX
	CODE_OUT
ENDIF
	CMP	AX,0				; 0=normal.
	JNE	EMEMCHECK_NONE			;

EMEMCHECK_OK:

IF	DEBUG_FLAG_1				; debug flag no.1
	CODE_IN
	LC	0,0
	PRV	"BX:",BX	; free page counter.
	CODE_OUT
ENDIF
	MOV	DX,FREE_PAGE_COUNTER		; free page counter.
	MOV	ES,FREAM_SEGMENT		; EMS fream segment.
	MOV	AX,1				; 1=ok.
	RET
EMEMCHECK_NONE:
	MOV	DX,0				; free page counter.
	MOV	ES,DX				; EMS fream segment.
	MOV	AX,0				; 0=Expanded memory none.
	RET
EMEMCHECK	ENDP


;	Expanded memory 64k area allocate.
;	-O- AX : 1=ok,2=64k area none,0=Expanded memory none.
;	    DX : EMS 64k fream segment.

EMEMAREA64K	PROC	FAR
	MOV	EMEM_64KBUF_RDY_FLAG,0		; 64K area alloc flag.1=ready.
	MOV	EMEM_OPEN_FLAG,0		; Ex,memory open flag.1=ready.

	CALL	EMSOPN				; EMS open.
	CMP	AX,0				; 0=normal.
	JNE	EMEMAREA64K_NONE		;

	MOV	EMEM_OPEN_FLAG,1		; Ex,memory open flag.1=ready.

	MOV	BX,EXT64K_TOP_PAGE		; 64k extended area top page.
	CALL	EMS64K				; EMS seek 64k fream.
	MOV	FREAM64K_SEGMENT,ES		; EMS 64k fream segment.
	CMP	AX,0				; 0=normal,3=error
	JE	EMEMAREA64K_64SET		;

EMEMAREA64K_64NOSET:
	MOV	AX,HEAD_TABLE_PAGE		; header table page.
	MOV	DATA_NAME_TABLE_PAGE,AX		; data name table page.
	INC	AX				;
	MOV	DATA_START_PAGE,AX		; data start page.
	JMP	EMEMAREA64K_AREA_NONE		;

EMEMAREA64K_64SET:
	MOV	AX,HEAD_TBLNX_PAGE		; next header table page.
	MOV	DATA_NAME_TABLE_PAGE,AX		; data name table page.
	INC	AX				;
	MOV	DATA_START_PAGE,AX		; data start page.

EMEMAREA64K_OK:
	MOV	EMEM_64KBUF_RDY_FLAG,1		; 64K area alloc flag.1=ready.
	MOV	DX,FREAM64K_SEGMENT		; EMS 64k fream segment.
	MOV	AX,1				; 1=ok.
	RET
EMEMAREA64K_AREA_NONE:
	MOV	AX,2				; 2=64k area none.
	RET
EMEMAREA64K_NONE:
	MOV	AX,0				; 0=Expanded memory none.
	RET
EMEMAREA64K	ENDP


;	Expanded memory allocate.
;	-O- AX : 1=ok,0=Expanded memory none.

EMEMALLOC	PROC	FAR
	CMP	EMEM_OPEN_FLAG,1		; Ex,memory open flag.1=ready.
	JE	EMEMALLOC_LD			;

	CALL	EMSOPN				; EMS open.
	CMP	AX,0				; 0=normal.
	JNE	EMEMALLOC_NONE			;

	MOV	EMEM_OPEN_FLAG,1		; Ex,memory open flag.1=ready.

EMEMALLOC_LD:
	CALL	DATA_NAME_LOAD			; data name table load.
	CMP	AX,0				; 0=normal.
	JNE	EMEMALLOC_NONE			;

	CALL	FULL_DATA_LOAD			; full data load.
	CMP	AX,0				; 0=normal.
	JNE	EMEMALLOC_NONE			;

	CALL	DEBUG_WRITE			; debug write.

EMEMALLOC_OK:
	CALL	ARA64K_PAGE_ALLOC		; 64k extended area allocate.
	MOV	EMEM_READY_FLAG,1		; Ex,memory ready flag.1=ready
	MOV	AX,1				; 1=ok.
	RET
EMEMALLOC_NONE:
	CALL	ARA64K_PAGE_ALLOC		; 64k extended area allocate.
	MOV	EMEM_READY_FLAG,0		; Ex,memory ready flag.1=ready
	MOV	AX,0				; 0=Expanded memory none.
	RET
EMEMALLOC	ENDP


;	Expanded memory deallocate.

EMEMDEALLOC	PROC	FAR
	MOV	EMEM_READY_FLAG,0		; Ex,memory ready flag.1=ready
	MOV	EMEM_64KBUF_RDY_FLAG,0		; 64K area alloc flag.1=ready.
	MOV	EMEM_OPEN_FLAG,0		; Ex,memory open flag.1=ready.
	CALL	EMSCLS				; EMS close.
	RET
EMEMDEALLOC	ENDP


;	Expanded memory data name search.
;	-I- DS:SI : data name.
;	-O- AX    : search flag 1=ok,0=undefined.
;	    DATA_NAME_TABLE_PNT : search data name pointer.

EMEMQUICK	PROC	FAR
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	ES

	CMP	EMEM_READY_FLAG,1		; Ex,memory ready flag.1=ready
	JNE	EMEMQUICK_SKIP			;

	CMP	DATA_NAME_DATA_LEN,0		; data name data length.
	JE	EMEMQUICK_SKIP			;

	CALL	NAME_SEARCH			; name search.
	CMP	AX,0				; search flag 1=ok,0=undefined.
	JE	EMEMQUICK_UNDEFINED		;

EMEMQUICK_OK:
	CALL	ARA64K_PAGE_ALLOC		; 64k extended area allocate.
	MOV	AX,1				; search flag 1=ok.
	POP	ES
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	RET
EMEMQUICK_UNDEFINED:
	CALL	ARA64K_PAGE_ALLOC		; 64k extended area allocate.
EMEMQUICK_SKIP:
	MOV	AX,0				; search flag 0=undefined.
	POP	ES
	POP	DI
	POP	SI
	POP	DX
	POP	CX
	POP	BX
	RET
EMEMQUICK	ENDP


;	Expanded memory data load.
;	-I- ES:DI               : write buffer.
;	    DATA_NAME_TABLE_PNT : search data name pointer.
;	-O- ES:[DI]             : load data.
;	    CX                  : byte length.
;	    AX                  : 0=normal,1=error.

EMEMLOAD	PROC	FAR
	PUSH	BX
	PUSH	DX
	PUSH	SI
	PUSH	DI
	PUSH	ES

	CMP	EMEM_READY_FLAG,1		; Ex,memory ready flag.1=ready
	JNE	EMEMLOAD_SKIP			;

	MOV	FILE_SEG,ES			; file data segment.
	MOV	FILE_OFS,DI			; file data address.

	MOV	BX,DATA_NAME_TABLE_PAGE		; data name table page.
	CALL	EMSSEK				; EMS seek.
	MOV	FREAM_SEGMENT,ES		; EMS fream segment.
	CMP	AX,0				; 0=normal,3=error
	JNE	EMEMLOAD_ERROR			;

	CALL	DATA_LOADER			; data load.
	CMP	AX,0				; 0=normal,1=error.
	JNE	EMEMLOAD_ERROR			;

	MOV	CX,FILE_SIZE			; file size.
EMEMLOAD_NORMAL:
	CALL	ARA64K_PAGE_ALLOC		; 64k extended area allocate.
	MOV	AX,0				; 0=normal.
	POP	ES
	POP	DI
	POP	SI
	POP	DX
	POP	BX
	RET
EMEMLOAD_ERROR:
	CALL	ARA64K_PAGE_ALLOC		; 64k extended area allocate.
EMEMLOAD_SKIP:
	MOV	CX,0
	MOV	AX,1				; 1=error.
	POP	ES
	POP	DI
	POP	SI
	POP	DX
	POP	BX
	RET
EMEMLOAD	ENDP


;	name search.
;	-I- DS:SI : search name.
;	-O- AX    : search flag 1=ok,0=undefined.
;	    DATA_NAME_TABLE_PNT : search data name pointer.

NAME_SEARCH	PROC	NEAR
	MOV	BX,DATA_NAME_TABLE_PAGE		; data name table page.
	PUSH	SI				;
	CALL	EMSSEK				; EMS seek.
	POP	SI				;
	MOV	FREAM_SEGMENT,ES		; EMS fream segment.
	CMP	AX,0				; 0=normal,3=error
	JNE	NAME_SEARCH_UNDEF		;

	MOV	DATA_NAME_TABLE_PNT,0		; data name table pointer.
	MOV	ES,FREAM_SEGMENT		; EMS fream segment.
NAME_SEARCH_LOOP:
	MOV	DI,DATA_NAME_TABLE_PNT		; data name table pointer.

	MOV	AL,ES:[DI]			;
	CMP	AL,0				; data end.
	JE	NAME_SEARCH_UNDEF		;
	CMP	AL,KILL_TAG			; data kill tag.
	JE	NAME_SEARCH_NEXT		;

	CALL	XSTRCMP				; string compare.
	JC	NAME_SEARCH_OK			; cf : on=yes,off=no.

NAME_SEARCH_NEXT:
	ADD	DATA_NAME_TABLE_PNT,NAME_NEXT	; next file name.
	JMP	NAME_SEARCH_LOOP		;

NAME_SEARCH_OK:
	MOV	AX,1			; 1=ok.
	RET
NAME_SEARCH_UNDEF:
	MOV	AX,0			; 0=undefined.
	RET
NAME_SEARCH	ENDP


;	data name table load.
;	-O- AX : 0=normal,1=error.

DATA_NAME_LOAD	PROC	NEAR
	MOV	BX,DATA_NAME_TABLE_PAGE	; data name table page.
	CALL	EMSSEK			; EMS seek.
	MOV	FREAM_SEGMENT,ES	; EMS fream segment.
	CMP	AX,0			; 0=normal,3=error
	JNE	DATA_NAME_LOAD_ERROR	;

	CALL	CLEAR_PAGE		; page fream clear.

	MOV	DX,FREAM_SEGMENT	; EMS fream segment.
	MOV	DI,0			; dest offset  address.
	MOV	SI,OFFSET NAMEFILE_EMS	; file name.
	MOV	CX,DATA_NAME_TABLE_SIZE	; data name table size.
	CALLC	FILEREAD		; file read.
	CMP	AX,0			; 0:normal  1:error.
	JNE	DATA_NAME_LOAD_ERROR	;

DATA_NAME_LOAD_EXIT:
	MOV	AX,0			; 0=normal.
	RET
DATA_NAME_LOAD_ERROR:
	MOV	AX,1			; 1=error.
	RET
DATA_NAME_LOAD	ENDP


;	full data load.
;	-O- AX : 0=normal,1=error.
;	    DATA_NAME_DATA_LEN : data name data length.

FULL_DATA_LOAD	PROC	NEAR
	MOV	AX,DATA_START_PAGE		; data start page.
	MOV	WRITE_NOW_PAGE,AX		; write now page number.
	MOV	WRITE_NOW_OFST,0		; write now offset.
	MOV	DATA_NAME_TABLE_PNT,0		; data name table pointer.
	MOV	DATA_NAME_DATA_LEN,0		; data name data length.
FULL_DATA_LOAD_LOOP:
	CALL	NAME_GET			; file name get.
	CMP	AX,1				; 1=end.
	JE	FULL_DATA_LOAD_EXIT		;
	CMP	AX,2				; 2=error.
	JE	FULL_DATA_LOAD_ERROR		;

IF	DEBUG_FLAG_1				; debug flag no.1
	CODE_IN
	PRS	"FILE_NAME=",FILE_NAME
	PRV	"WRITE_NOW_OFST=",WRITE_NOW_OFST
	PRV	"FILE_SIZE=",FILE_SIZE
	CODE_OUT
ENDIF

	MOV	DX,SEGEMSWORK			; EMS work segment.
	MOV	DI,OFSEMSWORK			; EMS work offset.
	MOV	SI,OFFSET FILE_NAME		; file name.
	MOV	CX,DTALEN			; DTA length.
	CALLC	FILEREAD			; file read.
	CMP	AX,0				; 0:normal,1:error.
	JNE	FULL_DATA_LOAD_KILL		;

	MOV	FILE_SIZE,CX			; DTA length.
	MOVX	FILE_SEG,SEGEMSWORK		; EMS work segment.
	MOVX	FILE_OFS,OFSEMSWORK		; EMS work offset.

	CALL	DATA_SAVER			; data save.
	CMP	AX,0				; 0:normal,1:error.
	JNE	FULL_DATA_LOAD_EXIT		;

CODE_IN
	MOV	AX,0	; locate x.
	MOV	BX,0	; locate y.
	CALLE	CCCLOC	; locate.
CODE_OUT
	MESSAGE	16	;"‚d‚l‚r‚Öƒf[ƒ^‚ð“Ç‚Ýž‚ñ‚Å‚¢‚Ü‚·"
	CALL	EXPRINT	; print.
CODE_IN
	MOV	AX,0	; locate x.
	MOV	BX,1	; locate y.
	CALLE	CCCLOC	; locate.
CODE_OUT
	MOV	SI,OFFSET FILE_NAME
	CALL	EXPRINT	; print.

	JMP	FULL_DATA_LOAD_NEXT		;
FULL_DATA_LOAD_KILL:
	CALL	DATANAME_X_TAG			; data name kill tag.
FULL_DATA_LOAD_NEXT:
	ADD	DATA_NAME_TABLE_PNT,NAME_NEXT	; next file name.
	JMP	FULL_DATA_LOAD_LOOP

FULL_DATA_LOAD_EXIT:
;;	CALLC	CLS
CODE_IN
CALLE	CCCCLS			; text screen clear.
CODE_OUT
	CALL	DATANAME_END			; data end.
	MOV	AX,DATA_NAME_TABLE_PNT		; data name table pointer.
	MOV	DATA_NAME_DATA_LEN,AX		; data name data length.
	MOV	AX,0				; 0=normal.
	RET
FULL_DATA_LOAD_ERROR:
;;	CALLC	CLS
CODE_IN
CALLE	CCCCLS			; text screen clear.
CODE_OUT
	CALL	DATANAME_END			; data end.
	MOV	AX,1				; 1=error.
	RET
FULL_DATA_LOAD	ENDP


;	print.
;	-I- SI : string.

EXPRINT	PROC	NEAR
CODE_IN
EXPRINT_555:
	MOV	DL,DS:[SI]
	INC	SI
	CMP	DL,' '
	JBE	EXPRINT_556
	CALLE	CCCOUT			; print character.
	JMP	EXPRINT_555
EXPRINT_556:
	MOV	CX,8
EXPRINT_557:
	MOV	DL,' '
	CALLE	CCCOUT
	LOOP	EXPRINT_557
CODE_OUT
	RET
EXPRINT	ENDP


;	file name get.
;	-I-   DATA_NAME_TABLE_PNT : data name table pointer.
;	-O-   AX                  : 0=normal,1=end,2=error.
;	      FILE_NAME           : file name.
;	      FILE_SIZE           : file size.

NAME_GET	PROC	NEAR
	MOV	BX,DATA_NAME_TABLE_PAGE	; data name table page.
	CALL	EMSSEK			; EMS seek.
	MOV	FREAM_SEGMENT,ES	; EMS fream segment.
	CMP	AX,0			; 0=normal,3=error
	JMPNE	NAME_GET_ERROR		;

	MOV	ES,FREAM_SEGMENT	; EMS fream segment.
	MOV	SI,DATA_NAME_TABLE_PNT	; data name table pointer.

	CMP	ES:[SI],BYTE PTR ' '	; under space char.
	JB	NAME_GET_EMPTY		;

	ADD	SI,NAME_SIZE		; file size colum.
	MOV	DI,OFFSET FILE_NAME	; file name.
	MOV	CX,NAME_SIZE_LEN	; file size length.
	PUSH	DS			;
	MOV	AX,ES			;
	MOV	BX,DS			;
	MOV	ES,BX			;
	MOV	DS,AX			;
	REP	MOVSB			; copy.
	POP	DS			;
	MOV	ES:[DI],BYTE PTR 0	; end of string.

	MOV	SI,OFFSET FILE_NAME	; file size.
	CALLC	STRSPL			; space pless. "  123" - > "123  "
	CALLC	STRDEC			; string -> dec.
	MOV	FILE_SIZE,DX		; file size.

	MOV	CX,NAME_FLNM_LEN	; file name length.
	MOV	DI,OFFSET FILE_NAME	; file name.
	MOV	SI,DATA_NAME_TABLE_PNT	; data name table pointer.
	PUSH	DS			;
	MOV	AX,DS			;
	MOV	ES,AX			;
	MOV	DX,FREAM_SEGMENT	; EMS fream segment.
	MOV	DS,DX			;
	REP	MOVSB			; copy.
	POP	DS			;

	MOV	FILE_NAME[8],'.'	; separater.
	MOV	SI,OFFSET FILE_NAME	; file name.
	CALLC	STRSPD			; "file  .asm" - > "file.asm"

	MOV	CX,NAME_FLNM_LEN	; file name length.
	MOV	SI,OFFSET FILE_NAME	; file name.
	MOV	DI,DATA_NAME_TABLE_PNT	; data name table pointer.
	MOV	DX,FREAM_SEGMENT	; EMS fream segment.
	MOV	ES,DX			;
	REP	MOVSB			; copy.

	MOV	DI,DATA_NAME_TABLE_PNT	; data name table pointer.
	MOV	ES:[DI][NAME_EOS],WORD PTR 0	; name e.o.s.

NAME_GET_EXIT:
	MOV	AX,0			; 0=normal
	RET
NAME_GET_EMPTY:
	MOV	AX,1			; 1=end. 
	RET
NAME_GET_ERROR:
	MOV	AX,2			; 2=error.
	RET
NAME_GET	ENDP



;	data load.
;	-I-   DATA_NAME_TABLE_PNT : load data name.(table pointer)
;	      FREAM_SEGMENT       : EMS fream segment.
;	      FILE_SEG            : file data segment.
;	      FILE_OFS            : file data address.
;	-O-   AX                  : 0=normal,1=error.
;	      FILE_SIZE           : file size.

DATA_LOADER	PROC	NEAR

	MOV	ES,FREAM_SEGMENT		; EMS fream segment.
	MOV	DI,DATA_NAME_TABLE_PNT		; data name table pointer.

	MOV	AX,ES:[DI][NAME_BANK_NO]	; page number.
	MOV	READ_NOW_PAGE,AX		; read now page number.

	MOV	AX,ES:[DI][NAME_B_OFFSET]	; page offset colum.
	MOV	READ_NOW_OFST,AX		; read now offset.

	MOV	AX,ES:[DI][NAME_B_SIZE]		; page size colum.
	MOV	FILE_SIZE,AX			; file size.

	CALL	EMEMORY_TO_BUFFER		; Ex,memory -> buffer.
	CMP	AX,0				; 0:normal,1:error.
	JNE	DATA_LOADER_ERROR		;

DATA_LOADER_EXIT:
	MOV	AX,0			; 0=normal.
	RET
DATA_LOADER_ERROR:
	MOV	AX,1			; 1=error.
	RET
DATA_LOADER	ENDP


;	data save.
;	before open data name table page.
;	-I-   FILE_SEG            : file data segment.
;	      FILE_OFS            : file data address.
;	      FILE_SIZE           : file size.
;	      DATA_NAME_TABLE_PNT : data name table pointer.
;	-I/O- WRITE_NOW_PAGE      : write now page number.
;	      WRITE_NOW_OFST      : write now offset.
;	      FREAM_SEGMENT       : EMS fream segment.
;	-O-   AX                  : 0:normal,1:error.

DATA_SAVER	PROC	NEAR

	MOV	ES,FREAM_SEGMENT		; EMS fream segment.
	MOV	DI,DATA_NAME_TABLE_PNT		; data name table pointer.

	MOV	AX,WRITE_NOW_PAGE		; write now page number.
	MOV	ES:[DI][NAME_BANK_NO],AX	; page number.

	MOV	AX,WRITE_NOW_OFST		; write now offset.
	MOV	ES:[DI][NAME_B_OFFSET],AX	; page offset colum.

	MOV	AX,FILE_SIZE			; file size.
	MOV	ES:[DI][NAME_B_SIZE],AX		; page size colum.

	CALL	BUFFER_TO_EMEMORY		; buffer -> Ex,memory.
	CMP	AX,0				; 0:normal,1:error.
	JNE	DATA_SAVER_ERROR		;
DATA_SAVER_EXIT:
	MOV	AX,0			; 0=normal.
	RET
DATA_SAVER_ERROR:
	MOV	AX,1			; 1=error.
	RET
DATA_SAVER	ENDP


;	buffer -> Ex,memory.
;	-I-   FILE_SEG       : file data segment.
;	      FILE_OFS       : file data address.
;	      FILE_SIZE      : file size.
;	-I/O- WRITE_NOW_PAGE : write now page number.
;	      WRITE_NOW_OFST : write now offset.
;	      FREAM_SEGMENT  : EMS fream segment.
;	-O-   AX             : 0:normal,1:error.

BUFFER_TO_EMEMORY	PROC	NEAR
	CALL	DATA_LENGTH_CALC		; data length calc.

	MOV	BX,WRITE_NOW_PAGE		; write now page number.
	CALL	EMSSEK				; EMS seek.
	MOV	FREAM_SEGMENT,ES		; EMS fream segment.
	CMP	AX,0				; 0=normal,3=error
	JNE	BUFFER_TO_EMEMORY_ERROR		;

	MOV	CX,MOVSIZ_FIRST			; move size first.
	CALL	PAGE_FREAM_WRITE		; page fream write.

	MOV	CX,MOVSIZ_FULL_COUNT		; move full size count.
	JCXZ	BUFFER_TO_EMEMORY_LP_E		;
BUFFER_TO_EMEMORY_LOOP:

	MOV	WRITE_NOW_OFST,0		; write now offset.
	INC	WRITE_NOW_PAGE			; write now page number.

	PUSH	CX				;
	MOV	BX,WRITE_NOW_PAGE		; write now page number.
	CALL	EMSSEK				; EMS seek.
	MOV	FREAM_SEGMENT,ES		; EMS fream segment.
	POP	CX				;
	CMP	AX,0				; 0=normal,3=error
	JNE	BUFFER_TO_EMEMORY_ERROR		;

	PUSH	CX
	MOV	CX,PAGE_ONE_SIZE		; 1 page size.
	CALL	PAGE_FREAM_WRITE		; page fream write.
	POP	CX

	LOOP	BUFFER_TO_EMEMORY_LOOP
BUFFER_TO_EMEMORY_LP_E:
	CMP	MOVSIZ_LAST,0			; move size last.
	JE	BUFFER_TO_EMEMORY_EXIT		;

	MOV	WRITE_NOW_OFST,0		; write now offset.
	INC	WRITE_NOW_PAGE			; write now page number.

	MOV	BX,WRITE_NOW_PAGE		; write now page number.
	CALL	EMSSEK				; EMS seek.
	MOV	FREAM_SEGMENT,ES		; EMS fream segment.
	CMP	AX,0				; 0=normal,3=error
	JNE	BUFFER_TO_EMEMORY_ERROR		;

	MOV	CX,MOVSIZ_LAST			; move size last.
	CALL	PAGE_FREAM_WRITE		; page fream write.

BUFFER_TO_EMEMORY_EXIT:
	MOV	AX,0				; 0=normal.
	RET
BUFFER_TO_EMEMORY_ERROR:
	MOV	AX,1				; 1=error.
	RET
BUFFER_TO_EMEMORY	ENDP


;	Ex,memory -> buffer.
;	-I-   FILE_SEG       : file data segment.
;	      FILE_OFS       : file data address.
;	      FILE_SIZE      : file size.
;	-I/O- READ_NOW_PAGE  : read now page number.
;	      READ_NOW_OFST  : read now offset.
;	      FREAM_SEGMENT  : EMS fream segment.
;	-O-   AX             : 0:normal,1:error.

EMEMORY_TO_BUFFER	PROC	NEAR
	MOV	AX,READ_NOW_OFST		; read now offset.
	MOV	WRITE_NOW_OFST,AX		; write now offset.
	CALL	DATA_LENGTH_CALC		; data length calc.

IF	DEBUG_FLAG_1				; debug flag no.1
	CODE_IN
	PRV	"MOVSIZ_FIRST=",MOVSIZ_FIRST
	PRV	"MOVSIZ_FULL_COUNT=",MOVSIZ_FULL_COUNT
	PRV	"MOVSIZ_LAST=",MOVSIZ_LAST
	PRV	"FILE_SEG=",FILE_SEG
	PRV	"FILE_OFS=",FILE_OFS
	PRV	"FILE_SIZE=",FILE_SIZE
	CODE_OUT
ENDIF
	MOV	BX,READ_NOW_PAGE		; read now page number.
	CALL	EMSSEK				; EMS seek.
	MOV	FREAM_SEGMENT,ES		; EMS fream segment.
	CMP	AX,0				; 0=normal,3=error
	JNE	EMEMORY_TO_BUFFER_ERROR		;

	MOV	CX,MOVSIZ_FIRST			; move size first.
	CALL	PAGE_FREAM_READ			; page fream read.

	MOV	CX,MOVSIZ_FULL_COUNT		; move full size count.
	JCXZ	EMEMORY_TO_BUFFER_LP_E		;
EMEMORY_TO_BUFFER_LOOP:

	MOV	READ_NOW_OFST,0			; read now offset.
	INC	READ_NOW_PAGE			; read now page number.

	PUSH	CX				;
	MOV	BX,READ_NOW_PAGE		; read now page number.
	CALL	EMSSEK				; EMS seek.
	MOV	FREAM_SEGMENT,ES		; EMS fream segment.
	POP	CX				;
	CMP	AX,0				; 0=normal,3=error
	JNE	EMEMORY_TO_BUFFER_ERROR		;

	PUSH	CX
	MOV	CX,PAGE_ONE_SIZE		; 1 page size.
	CALL	PAGE_FREAM_READ			; page fream read.
	POP	CX

	LOOP	EMEMORY_TO_BUFFER_LOOP
EMEMORY_TO_BUFFER_LP_E:
	CMP	MOVSIZ_LAST,0			; move size last.
	JE	EMEMORY_TO_BUFFER_EXIT		;

	MOV	READ_NOW_OFST,0			; read now offset.
	INC	READ_NOW_PAGE			; read now page number.

	MOV	BX,READ_NOW_PAGE		; read now page number.
	CALL	EMSSEK				; EMS seek.
	MOV	FREAM_SEGMENT,ES		; EMS fream segment.
	CMP	AX,0				; 0=normal,3=error
	JNE	EMEMORY_TO_BUFFER_ERROR		;

	MOV	CX,MOVSIZ_LAST			; move size last.
	CALL	PAGE_FREAM_READ			; page fream read.

EMEMORY_TO_BUFFER_EXIT:
	MOV	AX,0				; 0=normal.
	RET
EMEMORY_TO_BUFFER_ERROR:
	MOV	AX,1				; 1=error.
	RET
EMEMORY_TO_BUFFER	ENDP


;	data length calc.
;	-I- WRITE_NOW_OFST    : write now offset.
;	    FILE_SIZE         : file size.
;	-O- MOVSIZ_FIRST      : move size first.
;	    MOVSIZ_FULL_COUNT : move full size count.
;	    MOVSIZ_LAST       : move size last.

DATA_LENGTH_CALC	PROC	NEAR
	MOV	MOVSIZ_FIRST,0		; move size first.
	MOV	MOVSIZ_FULL_COUNT,0	; move full size count.
	MOV	MOVSIZ_LAST,0		; move size last.

	MOV	AX,FILE_SIZE		; file size.
	MOV	BYTE_COUNT,AX		; byte counter.

	; if   free area size >= file size   then
	;    size first = file size
	;    exit
	; else
	;    size first = free area size
	; endif

	MOV	DX,PAGE_ONE_SIZE	; 1 page size.
	SUB	DX,WRITE_NOW_OFST	; write now offset.
					; DX=free area size.
	CMP	DX,BYTE_COUNT		; byte counter.
	JB	DATA_LENGTH_CALC_2	;

	MOV	AX,FILE_SIZE		; file size.
	MOV	MOVSIZ_FIRST,AX		; move size first.

	JMP	DATA_LENGTH_CALC_EXIT	;
DATA_LENGTH_CALC_2:
	MOV	MOVSIZ_FIRST,DX		; move size first = first page free.

	SUB	BYTE_COUNT,DX		; byte counter.

	; full size count = byte count   /   page one size
	; size last       = byte count  MOD  page one size

	MOV	AX,BYTE_COUNT		; byte counter.
	MOV	DX,0			; double word.
	MOV	BX,PAGE_ONE_SIZE	; 1 page size.
	DIV	BX			;
	MOV	MOVSIZ_FULL_COUNT,AX	; move full size count.
	MOV	MOVSIZ_LAST,DX		; move size last.

DATA_LENGTH_CALC_EXIT:
	RET
DATA_LENGTH_CALC	ENDP


;	data name kill tag.
;	-I-   DATA_NAME_TABLE_PNT : data name table pointer.

DATANAME_X_TAG	PROC	NEAR
	MOV	BX,DATA_NAME_TABLE_PAGE	; data name table page.
	CALL	EMSSEK			; EMS seek.
	MOV	FREAM_SEGMENT,ES	; EMS fream segment.
	CMP	AX,0			; 0=normal,3=error
	JNE	DATANAME_X_TAG_EXIT	;

	MOV	ES,FREAM_SEGMENT	; EMS fream segment.
	MOV	DI,DATA_NAME_TABLE_PNT	; data name table pointer.
	MOV	AL,KILL_TAG		; data kill tag.
	MOV	ES:[DI],AL		;
DATANAME_X_TAG_EXIT:
	RET
DATANAME_X_TAG	ENDP


;	data end.
;	-I-   DATA_NAME_TABLE_PNT : data name table pointer.

DATANAME_END	PROC	NEAR
	MOV	BX,DATA_NAME_TABLE_PAGE	; data name table page.
	CALL	EMSSEK			; EMS seek.
	MOV	FREAM_SEGMENT,ES	; EMS fream segment.
	CMP	AX,0			; 0=normal,3=error
	JNE	DATANAME_END_EXIT	;

	MOV	ES,FREAM_SEGMENT	; EMS fream segment.
	MOV	DI,DATA_NAME_TABLE_PNT	; data name table pointer.
	MOV	ES:[DI],BYTE PTR 0	; data end.
	MOV	ES:[DI][1],BYTE PTR '&'	; data end.
DATANAME_END_EXIT:
	RET
DATANAME_END	ENDP


;	page fream write.
;	-I-   FREAM_SEGMENT  : EMS fream segment.
;	      CX             : byte length.(0-65535)
;	-I/O- FILE_SEG       : file data segment.
;	      FILE_OFS       : file data address.
;	      WRITE_NOW_OFST : write now offset.

PAGE_FREAM_WRITE	PROC	NEAR
	PUSH	CX
	JCXZ	PAGE_FREAM_WRITE_EXIT

	MOV	DX,FILE_SEG		; file data segment.
	MOV	SI,FILE_OFS		; file data address.

	MOV	ES,FREAM_SEGMENT	; EMS fream segment.
	MOV	DI,WRITE_NOW_OFST	; write now offset.

	PUSH	DS
	MOV	DS,DX			; source data segment.
	REP	MOVSB			; copy.
	POP	DS

	MOV	FILE_OFS,SI		; file data address.
	MOV	WRITE_NOW_OFST,DI	; write now offset.

PAGE_FREAM_WRITE_EXIT:
	POP	CX
	RET
PAGE_FREAM_WRITE	ENDP


;	page fream read.
;	-I-   FREAM_SEGMENT  : EMS fream segment.
;	      CX             : byte length.(0-65535)
;	-I/O- FILE_SEG       : file data segment.
;	      FILE_OFS       : file data address.
;	      READ_NOW_OFST  : read now offset.

PAGE_FREAM_READ	PROC	NEAR
	PUSH	CX
	JCXZ	PAGE_FREAM_READ_EXIT

	MOV	DX,FREAM_SEGMENT	; EMS fream segment.
	MOV	SI,READ_NOW_OFST	; read now offset.

	MOV	ES,FILE_SEG		; file data segment.
	MOV	DI,FILE_OFS		; file data address.

	PUSH	DS
	MOV	DS,DX			; source data segment.
	REP	MOVSB			; copy.
	POP	DS

	MOV	FILE_OFS,DI		; file data address.
	MOV	READ_NOW_OFST,SI	; read now offset.

PAGE_FREAM_READ_EXIT:
	POP	CX
	RET
PAGE_FREAM_READ	ENDP


;	page fream clear.

CLEAR_PAGE	PROC	NEAR
	MOV	CX,PAGE_ONE_SIZE	; 1 page size.
	SHR	CX,1			; word pointer.
	MOV	ES,FREAM_SEGMENT	; EMS fream segment.
	MOV	DI,0			;
	MOV	AX,0			;
	REP	STOSW			;
	RET
CLEAR_PAGE	ENDP


;	64k extended area allocate.

ARA64K_PAGE_ALLOC	PROC	NEAR
	CMP	EMEM_64KBUF_RDY_FLAG,1		; 64K area alloc flag.1=ready.
	JNE	ARA64K_PAGE_ALLOC_EXIT		;

	PUSH	ES
	PUSH	AX
	PUSH	BX
	PUSH	CX
	PUSH	DX
	PUSH	DI
	PUSH	SI

	MOV	BX,EXT64K_TOP_PAGE		; 64k extended area top page.
	CALL	EMSSEK				; EMS seek.

	POP	SI
	POP	DI
	POP	DX
	POP	CX
	POP	BX
	POP	AX
	POP	ES

ARA64K_PAGE_ALLOC_EXIT:
	RET
ARA64K_PAGE_ALLOC	ENDP


;	string compare.
;	-i- DS:SI :source string.
;	    ES:DI :immediate string.
;	           NULL=end of string
;	-o- cf : on=yes,off=no.

XSTRCMP	PROC	NEAR
	PUSH	ES
	PUSH	DI
	PUSH	SI

IF	DEBUG_FLAG_3			; debug flag no.3
CODE_IN
	PR	"?:"
	MOV	CX,12
	XCHG	DI,SI
	CALL	PRINTES
	XCHG	DI,SI
	PRSA	":",SI
CODE_OUT
ENDIF

XSTRCMP_LOOP:				;
	CMPSB				;
	JNE	XSTRCMP_CHK		; if [si]<>[di] then exit.
	CMP	BYTE PTR DS:[SI][-1],' ' ; space.
	JNBE	XSTRCMP_LOOP		; if end-of-string then exit.

XSTRCMP_CHK:
	CMP	BYTE PTR ES:[DI][-1],' ' ; space.
	JNBE	XSTRCMP_NO		; no.
	CMP	BYTE PTR DS:[SI][-1],' ' ; space.
	JNBE	XSTRCMP_NO		; no.

XSTRCMP_YES:
	STC
	JMP	XSTRCMP_9
XSTRCMP_NO:
	CLC
XSTRCMP_9:
	POP	SI
	POP	DI
	POP	ES
	RET
XSTRCMP	ENDP




;	debug write.

DEBUG_WRITE	PROC	NEAR

IF	DEBUG_FLAG_2				; debug flag no.2

	MOV	BX,DATA_NAME_TABLE_PAGE		; data name table page.
	CALL	EMSSEK				; EMS seek.
	MOV	FREAM_SEGMENT,ES		; EMS fream segment.
	CMP	AX,0				; 0=normal,3=error
	JMPNE	DEBUG_WRITE_EXIT		;

	CODE_IN
	PRV	"Expanded memory page dir table.page=",DATA_NAME_TABLE_PAGE
	PRF	"[...12byte...][1word][1word][1work][1word]"
	PRF	"[ file name  ][e.o.s][page ][ofset][size ]"

	MOV	ES,FREAM_SEGMENT		; EMS fream segment.
	MOV	SI,0				;
DEBUG_WRITE_LOOP:
	CMP	ES:[SI],BYTE PTR ' '
	JNB	DEBUG_WRITE_2
	JMP	DEBUG_WRITE_LP_E
DEBUG_WRITE_2:

	PUSH	SI

	PR	"|"
	MOV	CX,12
DEBUG_WRITE_LOOP2:
	MOV	AH,ES:[SI]
	PRCH					; 1 char put.
	INC	SI
	LOOP	DEBUG_WRITE_LOOP2

	INC	SI
	INC	SI

	MOV	CX,3
DEBUG_WRITE_LOOP3:
	PR	"|"
	MOV	DX,ES:[SI]
	INC	SI
	INC	SI
	PUSH	SI
	CALL	DECSTR
	CALL	PRINT
	POP	SI
	LOOP	DEBUG_WRITE_LOOP3

	LF

	POP	SI

	ADD	SI,NAME_NEXT		; next file name.

	JMP	DEBUG_WRITE_LOOP
DEBUG_WRITE_LP_E:

	CODE_OUT
DEBUG_WRITE_EXIT:

ENDIF
	RET
DEBUG_WRITE	ENDP

EMMCOD	ENDS



DATA	SEGMENT	PUBLIC	'DATA'

EXTRN	SEGEMSWORK:WORD			; EMS work segment.
EXTRN	OFSEMSWORK:WORD			; EMS work offset.

FREE_PAGE_COUNTER	DW	0	; free page counter.

EMEM_OPEN_FLAG		DW	0	; Ex,memory open flag.1=ready.
EMEM_READY_FLAG		DW	0	; Ex,memory ready flag.1=ready.
EMEM_64KBUF_RDY_FLAG	DW	0	; 64K area allocate flag.1=ready.

DATA_NAME_TABLE_PAGE	DW HEAD_TABLE_PAGE	; data name table page.
DATA_START_PAGE		DW HEAD_TABLE_PAGE+1	; data start page.
DATA_NAME_TABLE_SIZE	DW	4000H		; data name table size.
DATA_NAME_TABLE_PNT	DW	0		; data name table pointer.
DATA_NAME_DATA_LEN	DW	0		; data name data length.

PAGE_ONE_SIZE		DW	4000H	; 1 page size.
FREAM_SEGMENT		DW	0	; EMS fream segment.
FREAM64K_SEGMENT	DW	0	; EMS 64k fream segment.

NAMEFILE_EMS		DB	"NAMEFILE.EMS",0,0	; file name.

KILL_TAG		DB	"/",0	; data kill tag.

WRITE_NOW_PAGE		DW	0	; write now page number.
WRITE_NOW_OFST		DW	0	; write now offset.

READ_NOW_PAGE		DW	0	; read now page number.
READ_NOW_OFST		DW	0	; read now offset.

FILE_NAME		DB 14 DUP (0)	; file name.
FILE_SIZE		DW	0	; file size.
FILE_SEG		DW	0	; file data segment.
FILE_OFS		DW	0	; file data address.

MOVSIZ_FIRST		DW	0	; move size first.
MOVSIZ_FULL_COUNT	DW	0	; move full size count.
MOVSIZ_LAST		DW	0	; move size last.

BYTE_COUNT		DW	0	; byte counter.

DATA	ENDS

	END
;
;	end of "EMEMORY.ASM"
;
