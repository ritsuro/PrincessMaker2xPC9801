; "DSKCH2.INC" PC-9801UV11 make by R.H 1992/05/20
;
;
;	disk chenger  define.
;
;
; i/o subroutine.

MY_DISKSYSNAME	EQU	1111H	; このシステムＩＤ
MY_DISKPROG	EQU	0006H	; このプログラムＩＤ (6=PRIME2)
MY_DISKNUMSYS	EQU	2	; このシステムディスク番号

TIME_DKCMSG	EQU	60*2	; メッセージ時間

;
;	end of "DSKCH2.INC"
;
