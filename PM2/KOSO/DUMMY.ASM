; "DUMMY.ASM" PC-9801UV11 make by R.H 1992/01/23
;
;	デバック関係のルーチンに置き換えるダミールーチン
;

INCLUDE	TSTSET.INC

PUBXXX	MACRO	LBL
PUBLIC	LBL
LBL	LABEL	NEAR
	ENDM

CODE01	SEGMENT	PUBLIC	'CODE01'

	ASSUME	CS:CODE01


PUBXXX	C1VV_BANK_CHG_ES
PUBXXX	C1VV_MODE_PSET
PUBXXX	C1VV_MODE_AND
PUBXXX	C1VV_MODE_OR
PUBXXX	C1VV_MODE_XOR
PUBXXX	C1VV_BANK_XCG_ES
PUBXXX	C1VV_BANK_PLN_DS
PUBXXX	C1VV_BANK_XCG_DX
PUBXXX	C1VV_PLEAN_SLCT
PUBXXX	C1VV_MODE_PIXEL
PUBXXX	C1VV_MODE_PIXEL_STOP
	RET
PUBXXX	C1VV_BANK_CHK
	MOV	AX,0		; 0=normal,1=video memory.
	RET

PUBXXX	CPCCIN
PUBXXX	CPCCOUT
PUBXXX	CPCCRD
PUBXXX	CPCCLOC
PUBXXX	CPCCCOL
PUBXXX	VGAGRPMDE
PUBXXX	VGARETMDE
PUBXXX	VGACLR
PUBXXX	VGASETCLR
PUBXXX	VGACLRVSET
PUBXXX	XLINEVGA
PUBXXX	VGADLINEH
PUBXXX	VGADLINEHBT
PUBXXX	VGADLINEV
PUBXXX	VPCKYBSRT
PUBXXX	VPCKYBEND
PUBXXX	VPCKYBSTP
PUBXXX	VPCKYBCNT
PUBXXX	VPCKYBONS
PUBXXX	VPCKYBOFS
PUBXXX	VPCKEYTEN
PUBXXX	VPCKEYRET
PUBXXX	VPCKEYANY
PUBXXX	VPCKEYOFW
PUBXXX	VPCKEYTRG
PUBXXX	VPCKEYHLT
PUBXXX	VPCKEYMUS
PUBXXX	VPCMUSINI
PUBXXX	VPCMUSRED
PUBXXX	VPCMUSWRD
PUBXXX	VPCMUSSHT
PUBXXX	VPCMUSSET
PUBXXX	VPCMUSSTB
PUBXXX	VPCMUSSTP
PUBXXX	VPCMUSWAT
PUBXXX	VPCMUSDSP
PUBXXX	VPCTMWAIT
PUBXXX	VPCTMVSRT
PUBXXX	VPCTMVEND
PUBXXX	VPCTMVWAT
PUBXXX	VPCTMVSET
PUBXXX	VPCTMVCHK
PUBXXX	VPCTMVEWT
PUBXXX	VPCTMVST2
PUBXXX	VPCTMVCK2
PUBXXX	VPCTMVST3
PUBXXX	VPCTMVCK3
PUBXXX	VPCTMVWT4
PUBXXX	VPCTMVST5
PUBXXX	VPCTMVCK5
PUBXXX	VPCTMVST6
PUBXXX	VPCTMVCK6
PUBXXX	VPCTMVST7
PUBXXX	VPCTMVCK7
PUBXXX	VPCTMVST8
PUBXXX	VPCTMVCK8
PUBXXX	VPCTMVCLR
PUBXXX	VPCTMVSTP
PUBXXX	VPCTMVCNT
PUBXXX	VPCTMVRND
PUBXXX	VPCTMVSAV
PUBXXX	VPCTMVLOD
PUBXXX	VPCTMVPLT
PUBXXX	VPCTMVPMD
PUBXXX	VPCTMVLOW
;;	PRF	"**** DUMMY ****"
	RET
CODE01	ENDS
	END
;
;	end of "DUMMY.ASM"
;
