; "MINTXT.ASM" 1990/07/08 R.H PC-9801UV11 make by R.H 1990
;			modify 1992/05/14 486/50
;
;	mini text vram put routine.
;
;
; public subroutine.

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01,DS:DATA

PUBLIC	MITPRN			; mini string. (null=end of string)
PUBLIC	MITCOL			; mini string color.

EXTRN	C1VV_BANK_XCG_ES:NEAR	; vram bank check & chenge.(READ/WRITE) ES


;	mini string. (null=end of string)
;	-i- DS:SI   : string. (null=end of string)
;	    AX      : location x point.
;	    BX      : location y point.

MITPRN	PROC	NEAR
	CALL	MIT_LOCATE		; vram location.
MITPRN_LOOP:
	LODSB				; get char.
	CMP	AL,0			; end of string.
	JE	MITPRN_EXIT		;
	CALL	MIT_GETFONT_ADRS	; get font adrs.
	CALL	MIT_VRMPUT		; put vram.

	INC	LOCATE_ADRS		; location vram address. next+.

	JMP	MITPRN_LOOP		;
MITPRN_EXIT:
	RET
MITPRN	ENDP



;	mini string color.
;	-I- AX : font color.

MITCOL	PROC	NEAR
	MOV	FONT_COLOR,AX		; font color.
	RET
MITCOL	ENDP


;	vram location.
;	-I- AX          : location x point.
;	    BX          : location y point.
;	-O- LOCATE_ADRS : location vram address.

MIT_LOCATE	PROC	NEAR
	XCHG	AX,BX
	MOV	CX,SEGVTW		; visual data plean width.
	MUL	CX			;
	ADD	AX,BX			; address = x + y
	MOV	LOCATE_ADRS,AX		; location vram address.
	RET
MIT_LOCATE	ENDP


;	get font adrs.
;	-I- AL : character code.
;	-O- BX : font address.

MIT_GETFONT_ADRS	PROC	NEAR
	MOV	BL,AL		; character code.
	MOV	BH,0		;

	SUB	BL,20H		; + 20H (space code)
	SHL	BX,1		;
	SHL	BX,1		;
	SHL	BX,1		; * 8

	ADD	BX,OFFSET FONT_TABLE
	RET
MIT_GETFONT_ADRS	ENDP



;	put vram.
;	-I- LOCATE_ADRS : location vram address.
;	    BX : font address.

MIT_VRMPUT	PROC	NEAR
	PUSH	SI		; save string pointer.

	MOV	AX,SEGVT0	; text put vram segment plean 0.
	MOV	ES,AX		;
	TEST	FONT_COLOR,0001B ; font color.
	JZ	MIT_VRMPUT_01	;
	CALL	MIT_PUTOR	; vram put 1 plean OR.
	JMP	MIT_VRMPUT_02	;
MIT_VRMPUT_01:			;
	CALL	MIT_PUTMASK	; vram put 1 plean MASK.
MIT_VRMPUT_02:			;


	MOV	AX,SEGVT1	; text put vram segment plean 1.
	MOV	ES,AX		;
	TEST	FONT_COLOR,0010B ; font color.
	JZ	MIT_VRMPUT_11	;
	CALL	MIT_PUTOR	; vram put 1 plean OR.
	JMP	MIT_VRMPUT_12	;
MIT_VRMPUT_11:			;
	CALL	MIT_PUTMASK	; vram put 1 plean MASK.
MIT_VRMPUT_12:			;


	MOV	AX,SEGVT2	; text put vram segment plean 2.
	MOV	ES,AX		;
	TEST	FONT_COLOR,0100B ; font color.
	JZ	MIT_VRMPUT_21	;
	CALL	MIT_PUTOR	; vram put 1 plean OR.
	JMP	MIT_VRMPUT_22	;
MIT_VRMPUT_21:			;
	CALL	MIT_PUTMASK	; vram put 1 plean MASK.
MIT_VRMPUT_22:			;


	MOV	AX,SEGVT3	; text put vram segment plean 3.
	MOV	ES,AX		;
	TEST	FONT_COLOR,1000B ; font color.
	JZ	MIT_VRMPUT_31	;
	CALL	MIT_PUTOR	; vram put 1 plean OR.
	JMP	MIT_VRMPUT_32	;
MIT_VRMPUT_31:			;
	CALL	MIT_PUTMASK	; vram put 1 plean MASK.
MIT_VRMPUT_32:			;

	POP	SI		;
	RET
MIT_VRMPUT	ENDP


;	vram put 1 plean OR.
;	-I- ES : put vram seggment.
;	    BX : font address.
;	    LOCATE_ADRS : location vram address.

MIT_PUTOR	PROC	NEAR
	CALL	C1VV_BANK_XCG_ES ; vram bank check & chenge.(READ/WRITE) ES

	MOV	SI,BX		; font address.
	MOV	DI,LOCATE_ADRS	; location vram address.

	MOV	DX,SEGVTW	; visual data plean width.
	DEC	DX		; - 1

	MOV	CX,8		;
MIT_PUTOR2:			;
	LODSB			;
	MOV	AH,ES:[DI]	;
	OR	AL,AH		;
	STOSB			;
	ADD	DI,DX		; next line add.
	LOOP	MIT_PUTOR2	;
	RET
MIT_PUTOR	ENDP


;	vram put 1 plean MASK.
;	-I- ES : put vram seggment.
;	    BX : font address.
;	    LOCATE_ADRS : location vram address.

MIT_PUTMASK	PROC	NEAR
	CALL	C1VV_BANK_XCG_ES ; vram bank check & chenge.(READ/WRITE) ES

	MOV	SI,BX		; font address.
	MOV	DI,LOCATE_ADRS	; location vram address.

	MOV	DX,SEGVTW	; visual data plean width.
	DEC	DX		; - 1

	MOV	CX,8		;
MIT_PUTMASK2:			;
	LODSB			;
	NOT	AL		; mask data.
	MOV	AH,ES:[DI]	;
	AND	AL,AH		;
	STOSB			;
	ADD	DI,DX		; next line add.
	LOOP	MIT_PUTMASK2	;
	RET
MIT_PUTMASK	ENDP

CODE01	ENDS


DATA	SEGMENT	PUBLIC	'DATA'

PUBLIC	FONT_TABLE		; FONT1.INC character pattan 1.
PUBLIC	FONT_COLOR		; font color.

EXTRN	SEGVT0:WORD		; visual data segment plean 0
EXTRN	SEGVT1:WORD		; visual data segment plean 1
EXTRN	SEGVT2:WORD		; visual data segment plean 2
EXTRN	SEGVT3:WORD		; visual data segment plean 3
EXTRN	SEGVTW:WORD		; visual data plean width.

FONT_COLOR	DW	0	; font color.
LOCATE_ADRS	DW	0	; location vram address.

; FONT1.INC character pattan 1.

FONT_TABLE	LABEL	BYTE
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          

	DB 00100000B ;   *      
	DB 01110000B ;  ***     
	DB 01110000B ;  ***     
	DB 00100000B ;   *      
	DB 00100000B ;   *      
	DB 00000000B ;          
	DB 01100000B ;  **      
	DB 00000000B ;          

	DB 01010000B ;  * *     
	DB 01010000B ;  * *     
	DB 01010000B ;  * *     
	DB 01010000B ;  * *     
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          

	DB 00101000B ;   * *    
	DB 00101000B ;   * *    
	DB 01111100B ;  *****   
	DB 00101000B ;   * *    
	DB 00101000B ;   * *    
	DB 01111100B ;  *****   
	DB 00101000B ;   * *    
	DB 00000000B ;          

	DB 00010100B ;    * *   
	DB 00111111B ;   ****** 
	DB 01010100B ;  * * *   
	DB 00111110B ;   *****  
	DB 00010101B ;    * * * 
	DB 01111110B ;  ******  
	DB 00010100B ;    * *   
	DB 00000000B ;          

	DB 01110010B ;  ***  *  
	DB 01010100B ;  * * *   
	DB 01111000B ;  ****    
	DB 00010000B ;    *     
	DB 00101110B ;   * ***  
	DB 01001010B ;  *  * *  
	DB 00001110B ;     ***     
	DB 00000000B ;          

	DB 00100000B ;   *      
	DB 01010000B ;  * *     
	DB 00100000B ;   *      
	DB 01010100B ;  * * *   
	DB 01001000B ;  *  *    
	DB 01001100B ;  *  **   
	DB 00110010B ;   **  *  
	DB 00000000B ;          

	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 00100000B ;   *      
	DB 01000000B ;  *       
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          

	DB 00001000B ;     *    
	DB 00110000B ;   **     
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 00110000B ;   **     
	DB 00001000B ;     *    
	DB 00000000B ;          

	DB 01000000B ;  *       
	DB 00110000B ;   **     
	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 00110000B ;   **     
	DB 01000000B ;  *       
	DB 00000000B ;          

	DB 00010000B ;    *     
	DB 01010100B ;  * * *   
	DB 00111000B ;   ***    
	DB 00010000B ;    *     
	DB 00111000B ;   ***    
	DB 01010100B ;  * * *   
	DB 00010000B ;    *     
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00010000B ;    *     
	DB 00010000B ;    *     
	DB 01111100B ;  *****   
	DB 00010000B ;    *     
	DB 00010000B ;    *     
	DB 00000000B ;          
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 00100000B ;   *      
	DB 01000000B ;  *       

	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 01111100B ;  *****   
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00110000B ;   **     
	DB 00110000B ;   **     
	DB 00000000B ;          

	DB 00000001B ;        * 
	DB 00000010B ;       *  
	DB 00000100B ;      *   
	DB 00001000B ;     *    
	DB 00010000B ;    *     
	DB 00100000B ;   *      
	DB 01000000B ;  *       
	DB 00000000B ;          

	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00000000B ;          

	DB 00011000B ;    **    
	DB 01111000B ;  ****    
	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 01111110B ;  ******  
	DB 00000000B ;          

	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00001100B ;     **   
	DB 00110000B ;   **     
	DB 01100110B ;  **  **  
	DB 01111110B ;  ******  
	DB 00000000B ;          

	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 00000110B ;      **  
	DB 00111100B ;   ****   
	DB 00000110B ;      **  
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00000000B ;          

	DB 00001100B ;     **   
	DB 00011100B ;    ***   
	DB 00101100B ;   * **   
	DB 01001100B ;  *  **   
	DB 01111110B ;  ******  
	DB 00001100B ;     **   
	DB 00011110B ;    ****  
	DB 00000000B ;          

	DB 01111110B ;  ******  
	DB 01100000B ;  **      
	DB 01111100B ;  *****   
	DB 01100110B ;  **  **  
	DB 00000110B ;      **  
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00000000B ;          

	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 01100000B ;  **      
	DB 01111100B ;  *****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00000000B ;          

	DB 01111110B ;  ******  
	DB 01100110B ;  **  **  
	DB 00001100B ;     **   
	DB 00001100B ;     **   
	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 00000000B ;          

	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00000000B ;          

	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00111110B ;   *****  
	DB 00000110B ;      **  
	DB 00001100B ;     **   
	DB 00111000B ;   ***    
	DB 00000000B ;          

	DB 00000000B ;          
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 00000000B ;          
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 00000000B ;          
	DB 00000000B ;          

	DB 00000000B ;          
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 00000000B ;          
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 00100000B ;   *      
	DB 01000000B ;  *       

	DB 00001100B ;     **   
	DB 00011000B ;    **    
	DB 00110000B ;   **     
	DB 01100000B ;  **      
	DB 00110000B ;   **     
	DB 00011000B ;    **    
	DB 00001100B ;     **   
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 01111100B ;  *****   
	DB 00000000B ;          
	DB 01111100B ;  *****   
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          

	DB 01100000B ;  **      
	DB 00110000B ;   **     
	DB 00011000B ;    **    
	DB 00001100B ;     **   
	DB 00011000B ;    **    
	DB 00110000B ;   **     
	DB 01100000B ;  **      
	DB 00000000B ;          

	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00001100B ;     **   
	DB 00010000B ;    *     
	DB 00001000B ;     *    
	DB 00011100B ;    ***   
	DB 00000000B ;          

	DB 00111000B ;   ***    
	DB 01100100B ;  **  *   
	DB 00000110B ;      **  
	DB 00100110B ;   *  **  
	DB 01010110B ;  * * **  
	DB 01010100B ;  * * *   
	DB 00111000B ;   ***    
	DB 00000000B ;          

	DB 00011000B ;    **    
	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01111110B ;  ******  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00000000B ;          

	DB 01111100B ;  *****   
	DB 01100100B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01111100B ;  *****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01111100B ;  *****   
	DB 00000000B ;          

	DB 00011100B ;    ***   
	DB 00110110B ;   ** **  
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 00110110B ;   ** **  
	DB 00011100B ;    ***   
	DB 00000000B ;          

	DB 01111000B ;  ****    
	DB 01101100B ;  ** **   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01101100B ;  ** **   
	DB 01111000B ;  ****    
	DB 00000000B ;          

	DB 01111110B ;  ******  
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 01111100B ;  *****   
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 01111110B ;  ******  
	DB 00000000B ;          

	DB 01111110B ;  ******  
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 01111110B ;  ******  
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 00000000B ;          

	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 01100000B ;  **      
	DB 01101110B ;  ** ***  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00000000B ;          

	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01111110B ;  ******  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00000000B ;          

	DB 01111000B ;  ****    
	DB 00110000B ;   **     
	DB 00110000B ;   **     
	DB 00110000B ;   **     
	DB 00110000B ;   **     
	DB 00110000B ;   **     
	DB 01111000B ;  ****    
	DB 00000000B ;          

	DB 00111110B ;   *****  
	DB 00001100B ;     **   
	DB 00001100B ;     **   
	DB 00001100B ;     **   
	DB 01101100B ;  ** **   
	DB 01101100B ;  ** **   
	DB 00111000B ;   ***    
	DB 00000000B ;          

	DB 01100110B ;  **  **  
	DB 01101100B ;  ** **   
	DB 01111000B ;  ****    
	DB 01110000B ;  ***     
	DB 01111000B ;  ****    
	DB 01101100B ;  ** **   
	DB 01100110B ;  **  **  
	DB 00000000B ;          

	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 01111110B ;  ******  
	DB 00000000B ;          

	DB 01000001B ;  *     * 
	DB 01100011B ;  **   ** 
	DB 01110111B ;  *** *** 
	DB 01111111B ;  ******* 
	DB 01101011B ;  ** * ** 
	DB 01100011B ;  **   ** 
	DB 01100011B ;  **   ** 
	DB 00000000B ;          

	DB 01000011B ;  *    ** 
	DB 01100011B ;  **   ** 
	DB 01110011B ;  ***  ** 
	DB 01101011B ;  ** * ** 
	DB 01100111B ;  **  *** 
	DB 01100011B ;  **   ** 
	DB 01100001B ;  **    * 
	DB 00000000B ;          

	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00000000B ;          

	DB 01111100B ;  *****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01111100B ;  *****   
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 00000000B ;          

	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01111110B ;  ******  
	DB 01100110B ;  **  **  
	DB 00111101B ;   **** * 
	DB 00000000B ;          

	DB 01111100B ;  *****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01111100B ;  *****   
	DB 01101100B ;  ** **   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00000000B ;          

	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 01100000B ;  **      
	DB 00111100B ;   ****   
	DB 00000110B ;      **  
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00000000B ;          

	DB 01111110B ;  ******  
	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 00000000B ;          

	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00000000B ;          

	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00011000B ;    **    
	DB 00000000B ;          

	DB 01101011B ;  ** * ** 
	DB 01101011B ;  ** * ** 
	DB 01101011B ;  ** * ** 
	DB 01101011B ;  ** * ** 
	DB 01101011B ;  ** * ** 
	DB 01111111B ;  ******* 
	DB 00110110B ;   ** **  
	DB 00000000B ;          

	DB 11000011B ; **    ** 
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00011000B ;    **    
	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 11000011B ; **    ** 
	DB 00000000B ;          

	DB 11000011B ; **    ** 
	DB 11000011B ; **    ** 
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 00000000B ;          

	DB 01111111B ;  ******* 
	DB 00000110B ;      **  
	DB 00001100B ;     **   
	DB 00011000B ;    **    
	DB 00110000B ;   **     
	DB 01100000B ;  **      
	DB 11111111B ; ******** 
	DB 00000000B ;          

	DB 00111000B ;   ***    
	DB 00100000B ;   *      
	DB 00100000B ;   *      
	DB 00100000B ;   *      
	DB 00100000B ;   *      
	DB 00100000B ;   *      
	DB 00111000B ;   ***    
	DB 00000000B ;          

	DB 01000010B ;  *    *  
	DB 00100100B ;   *  *   
	DB 00011000B ;    **    
	DB 01111110B ;  ******  
	DB 00011000B ;    **    
	DB 01111110B ;  ******  
	DB 00011000B ;    **    
	DB 00000000B ;          

	DB 00111000B ;   ***    
	DB 00001000B ;     *    
	DB 00001000B ;     *    
	DB 00001000B ;     *    
	DB 00001000B ;     *    
	DB 00001000B ;     *    
	DB 00111000B ;   ***    
	DB 00000000B ;          

	DB 00010000B ;    *     
	DB 00111000B ;   ***    
	DB 01101100B ;  ** **   
	DB 01000100B ;  *   *   
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 01111100B ;  *****   
	DB 00000000B ;          

	DB 01110000B ;  ***     
	DB 01110000B ;  ***     
	DB 01000000B ;  *       
	DB 00100000B ;   *      
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 00111100B ;   ****   
	DB 01000110B ;  *   **  
	DB 00111110B ;   *****  
	DB 01100110B ;  **  **  
	DB 00111111B ;   ****** 
	DB 00000000B ;          

	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 01111100B ;  *****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01111100B ;  *****   
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 01100000B ;  **      
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00000000B ;          

	DB 00000110B ;      **  
	DB 00000110B ;      **  
	DB 00111110B ;   *****  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00111110B ;   *****  
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 01111110B ;  ******  
	DB 01100000B ;  **      
	DB 00111100B ;   ****   
	DB 00000000B ;          

	DB 00011100B ;    ***   
	DB 00110110B ;   ** **  
	DB 00110000B ;   **     
	DB 01111100B ;  ******  
	DB 00110000B ;   **     
	DB 00110000B ;   **     
	DB 00110000B ;   **     
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000001B ;        * 
	DB 00111110B ;   *****  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00111110B ;   *****  
	DB 01000110B ;  *   **  
	DB 00111100B ;   ****   

	DB 01100000B ;  **      
	DB 01100000B ;  **      
	DB 01111100B ;  *****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00000000B ;          

	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 00000000B ;          
	DB 00111000B ;   ***    
	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 01111110B ;   ****   
	DB 00000000B ;          

	DB 00011000B ;    **    
	DB 00011000B ;    **    
	DB 00000000B ;          
	DB 00111100B ;   ****   
	DB 00001100B ;     **   
	DB 00001100B ;     **   
	DB 01001100B ;  *  **   
	DB 00111000B ;   ***    

	DB 01100000B ;   **     
	DB 01100000B ;   **     
	DB 01100110B ;   **  ** 
	DB 01101100B ;   ** **  
	DB 01111000B ;   ****   
	DB 01101100B ;   ** **  
	DB 01100110B ;   **  ** 
	DB 00000000B ;          

	DB 01110000B ;   ***    
	DB 00110000B ;    **    
	DB 00110000B ;    **    
	DB 00110000B ;    **    
	DB 00110000B ;    **    
	DB 00110000B ;    **    
	DB 01111000B ;   ****   
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 01111110B ;  ******  
	DB 01101011B ;  ** * ** 
	DB 01101011B ;  ** * ** 
	DB 01101011B ;  ** * ** 
	DB 01101011B ;  ** * ** 
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 01111100B ;  *****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 01011100B ;  * ***   
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01111100B ;  *****   
	DB 01100000B ;  **      
	DB 01100000B ;  **      

	DB 00000000B ;          
	DB 00000000B ;          
	DB 00110110B ;   ** **  
	DB 01101110B ;  ** ***  
	DB 01100110B ;  **  **  
	DB 00111110B ;   *****  
	DB 00000110B ;      **  
	DB 00000011B ;       ** 

	DB 00000000B ;          
	DB 00000000B ;          
	DB 00101110B ;   * ***  
	DB 11110111B ; **** *** 
	DB 01100110B ;  **  **  
	DB 01100000B ;  **      
	DB 11110000B ; ****     
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 00111110B ;   *****  
	DB 01100000B ;  **      
	DB 00111100B ;   ****   
	DB 00000110B ;      **  
	DB 01111100B ;  *****   
	DB 00000000B ;          
 
	DB 00010000B ;    *     
	DB 00110000B ;   **     
	DB 01111110B ;  ******  
	DB 00110000B ;   **     
	DB 00110000B ;   **     
	DB 00110010B ;   **  *  
	DB 00011100B ;    ***   
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 01101100B ;  ** **   
	DB 01101100B ;  ** **   
	DB 01101100B ;  ** **   
	DB 01101100B ;  ** **   
	DB 00111010B ;   *** *  
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00011000B ;    **    
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 01101011B ;  ** * ** 
	DB 01101011B ;  ** * ** 
	DB 01101011B ;  ** * ** 
	DB 01101011B ;  ** * ** 
	DB 00110110B ;   ** **  
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 01100110B ;  **  **  
	DB 00111100B ;   ****   
	DB 00011000B ;    **    
	DB 00111100B ;   ****   
	DB 01100110B ;  **  **  
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 01100110B ;  **  **  
	DB 01100110B ;  **  **  
	DB 01101110B ;  ** ***  
	DB 00110110B ;   ** **  
	DB 00000110B ;      **  
	DB 00111100B ;   ****   

	DB 00000000B ;          
	DB 00000000B ;          
	DB 01111110B ;  ******  
	DB 00001100B ;     **   
	DB 00011000B ;    **    
	DB 00110000B ;   **     
	DB 01111110B ;  ******  
	DB 00000000B ;          

	DB 00011000B ;     **   
	DB 00100000B ;    *     
	DB 00100000B ;    *     
	DB 01000000B ;   *      
	DB 00100000B ;    *     
	DB 00100000B ;    *     
	DB 00011000B ;     **   
	DB 00000000B ;          

	DB 01000000B ;    *     
	DB 01000000B ;    *     
	DB 01000000B ;    *     
	DB 00000000B ;          
	DB 01000000B ;    *     
	DB 01000000B ;    *     
	DB 01000000B ;    *     
	DB 00000000B ;          

	DB 01100000B ;  **      
	DB 00010000B ;    *     
	DB 00010000B ;    *     
	DB 00001000B ;     *    
	DB 00010000B ;    *     
	DB 00010000B ;    *     
	DB 01100000B ;  **      
	DB 00000000B ;          

	DB 00100000B ;   *      
	DB 01010100B ;  * * *   
	DB 00001000B ;     *    
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          

	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          
	DB 00000000B ;          


DATA	ENDS

	END
;
;	end of "MINTXT.ASM"
;
