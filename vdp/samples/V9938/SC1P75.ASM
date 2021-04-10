; --------------------------------------------------------------------
;	SCREEN1.75? �ɐ؂�ւ���
; ====================================================================
;	2020/03/25	t.hara
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

set_screen_1p75::
			; SCREEN4�֐؂�ւ���
			ld		a, 4
			call	CHGMOD

			; MSX-BASIC���uSCREEN1�v���ƌ�F������
			ld		a, 1
			ld		[SCRMOD], a

			; Pattern Generator Table �Ƀt�H���g��]������
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

			; Color Table �ɐF����������
			ld		hl, COLT
			ld		a, 0xF4			; �O�i: 15, �w�i: 4
			ld		bc, 0x800*3
			call	FILVRM

			; Pattern Name Table �� ' ' ��~���l�߂�
			ld		hl, PNT
			ld		a, ' '
			ld		bc, 32*24
			call	FILVRM
			ret