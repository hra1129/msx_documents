; --------------------------------------------------------------------
;	SCREEN1.5に切り替える
; ====================================================================
;	2020/03/21	t.hara
; --------------------------------------------------------------------

ROM_FONT	:= 0x1BBF

FILVRM		:= 0x0056
LDIRVM		:= 0x005C
CHGMOD		:= 0x005F
SCRMOD		:= 0xFCAF

PGT1		:= 0x0000
PGT2		:= 0x0800
PGT3		:= 0x1000
COLT		:= 0x2000
PNT			:= 0x1800

set_screen_1p5::
			; SCREEN2へ切り替える
			ld		a, 2
			call	CHGMOD

			; MSX-BASICを「SCREEN1」だと誤認させる
			ld		a, 1
			ld		[SCRMOD], a

			; Pattern Generator Table にフォントを転送する
			ld		hl, ROM_FONT
			ld		de, PGT1
			ld		bc, 8*256
			call	LDIRVM

			ld		hl, ROM_FONT
			ld		de, PGT2
			ld		bc, 8*256
			call	LDIRVM

			ld		hl, ROM_FONT
			ld		de, PGT3
			ld		bc, 8*256
			call	LDIRVM

			; Color Table に色を書き込む
			ld		hl, COLT
			ld		a, 0xF4			; 前景: 15, 背景: 4
			ld		bc, 0x800*3
			call	FILVRM

			; Pattern Name Table に ' ' を敷き詰める
			ld		hl, PNT
			ld		a, ' '
			ld		bc, 32*24
			call	FILVRM
			ret
