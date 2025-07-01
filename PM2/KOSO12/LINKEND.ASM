; "LINKEND.ASM" PC9801UV11 make by R.H 1992/01/28
;
;
;	link end buffers area.
;
;
; public subroutine.

STRING_LEN	EQU	255		; string length.
FLNAME_LEN	EQU	14		; file name length.

CODE	SEGMENT	PUBLIC	'CODE'

PUBLIC	STRING				; buffer length.

PUBLIC	STRINGX				; path name.
PUBLIC	STRINGX2			; path name.
PUBLIC	FLNAME				; file path name.

PUBLIC	PATHNAME			; path name.
PUBLIC	PATH_FD_DRV			; FD drive.
PUBLIC	PATH_HD_DSK			; HARD disk drive.
PUBLIC	PATH_USER			; user directory path.

STRING		DB	1 DUP (?)			; buffer length.
		DB	1 DUP (?)			; character length.
		DB	STRING_LEN DUP (?)		; string.

STRINGX		DB	STRING_LEN+2 DUP (?)		; path name.
STRINGX2	DB	STRING_LEN+2 DUP (?)		; path name.
FLNAME		DB	FLNAME_LEN+2 DUP (?)		; file path name.

PATHNAME	DB	STRING_LEN+2 DUP (?)		; path name.
PATH_FD_DRV	DB	STRING_LEN+2 DUP (?)		; FD drive.
PATH_HD_DSK	DB	STRING_LEN+2 DUP (?)		; HARD disk drive.
PATH_USER	DB	STRING_LEN+2 DUP (?)		; user directory path.

CODE	ENDS

	END
;
;	end of "XCPX.ASM"
;
