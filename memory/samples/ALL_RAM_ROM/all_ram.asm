; =============================================================================
; �S�Ẵy�[�W�� RAM �ɐ؂�ւ��ē��삷�� ROM�J�[�g���b�W�̃T���v���R�[�h
; -----------------------------------------------------------------------------
; MIT License
;
; �����g�̃v���O�����ɁA�S���܂��͈ꕔ�������R�ɑg�ݍ���ł��g�����������܂��B
; �������A���(t.hara)�́A���̃v���O�����ɂ�艽�炩�̑��Q�����Ă��A
; ��ؐӔC�𕉂��܂���B
; -----------------------------------------------------------------------------
; 2025/01/03 t.hara (HRA!)
; =============================================================================

ppi_slot_reg			:= 0xA8
ext_slot_reg			:= 0xFFFF
main_rom_slot			:= 0xFCC1
exptbl					:= 0xFCC1
slttbl					:= 0xFCC5
ramad0					:= 0xF341
ramad1					:= 0xF342
ramad2					:= 0xF343
ramad3					:= 0xF344

rom_slot				:= 0x8000
page2_routine_on_ram	:= 0xb000

			org		0x4000

			db		"AB"				; ID
			dw		entry_point			; INIT
			dw		0
			dw		0
			dw		0
			dw		0
			dw		0
			dw		0

entry_point::
			; page2 �� RAM �ł��邩�`�F�b�N���� (32KB�����̃}�V�������O���邽�߁j
		scope	page2_ram_check
			ld		hl, 0x8000
			di
	loop:
			ld		a, [hl]
			cpl
			ld		[hl], a
			cp		a, [hl]
			cpl
			ld		[hl], a
			jp		nz, error_not_enough_memory
			inc		hl
			ld		a, h
			or		a, a
			jp		p, loop
		endscope
			; page1 �̃X���b�g�ԍ�(���� ROM�J�[�g���b�W�̃X���b�g�ԍ�)���擾����
		scope	get_rom_slot
			in		a, [ppi_slot_reg]
			and		a, 0b00001100
			rrca
			rrca
			ld		b, a
			; �g���X���b�g�̑��݂𒲂ׂ�
			ld		hl, exptbl
			add		a, l
			ld		l, a
			ld		a, [hl]
			and		a, 0x80
			or		a, b
			jp		p, no_expand_slot
			; �g���X���b�g������ꍇ
			inc		hl
			inc		hl
			inc		hl
			inc		hl
			ld		b, a
			ld		a, [hl]
			and		a, 0b00001100
			or		a, b
	no_expand_slot:
			ld		[rom_slot], a
		endscope
			; page2 �̃X���b�g�ԍ�(RAM)���擾����
		scope	get_page2_ram_slot
			in		a, [ppi_slot_reg]
			and		a, 0b00110000
			rrca
			rrca
			rrca
			rrca
			ld		b, a
			; �g���X���b�g�̑��݂𒲂ׂ�
			ld		hl, exptbl
			add		a, l
			ld		l, a
			ld		a, [hl]
			and		a, 0x80
			or		a, b
			jp		p, no_expand_slot
			; �g���X���b�g������ꍇ
			inc		hl
			inc		hl
			inc		hl
			inc		hl
			ld		b, a
			ld		a, [hl]
			and		a, 0b00110000
			rrca
			rrca
			or		a, b
	no_expand_slot:
			ld		[ramad2], a
		endscope
			; page3 �̃X���b�g�ԍ�(RAM)���擾����
		scope	get_page3_ram_slot
			in		a, [ppi_slot_reg]
			and		a, 0b11000000
			rlca
			rlca
			ld		b, a
			; �g���X���b�g�̑��݂𒲂ׂ�
			ld		hl, exptbl
			add		a, l
			ld		l, a
			ld		a, [hl]
			and		a, 0x80
			or		a, b
			jp		p, no_expand_slot
			; �g���X���b�g������ꍇ
			inc		hl
			inc		hl
			inc		hl
			inc		hl
			ld		b, a
			ld		a, [hl]
			and		a, 0b11000000
			rrca
			rrca
			rrca
			rrca
			or		a, b
	no_expand_slot:
			ld		[ramad3], a
		endscope
			; page2 �`�F�b�N���[�`���Ǝ��� ENASLT ��]�����āA�`�F�b�N���[�`���փW�����v����
		scope	transfer_check_routine
			ld		hl, page2_routine_on_rom
			ld		de, page2_routine_on_ram
			ld		bc, page2_routine_on_ram_end - page2_routine_on_ram
			ldir
			jp		main_routine
		endscope
			; �G���[���b�Z�[�W����
error_not_enough_memory:
			ld		hl, message_not_enough_memory
			jp		put_error

			scope	put_error
put_error::
			ld		a, [main_rom_slot]
			push	hl
			call	my_enaslt0
			pop		hl
	loop:
			ld		a, [hl]
			or		a, a
			jr		z, freeze
			rst		0x18
			inc		hl
			jr		loop
	freeze:
			di
			halt
			endscope

; =============================================================================
;	Page2 �֓]�����ē��������� (page2_routine_on_ram �` page2_routine_on_ram_end)
; =============================================================================
page2_routine_on_rom:
			org		page2_routine_on_ram
		scope	page2_routine_on_ram
page2_routine_on_ram::

; -----------------------------------------------------------------------------
			scope	main_routine
main_routine::
			call	change_to_ram_for_page0
			call	change_to_ram_for_page1
			di
	loop:
			jp		loop
			endscope

; -----------------------------------------------------------------------------
;	Page0 �� MainROM, Page1 �� �J�[�g���b�WROM �ɐ؂�ւ���
;	�J�[�g���b�WROM��̃G���[�o�̓��[�`���֔��
; -----------------------------------------------------------------------------
			scope	goto_error
goto_error::
				ld		a, [main_rom_slot]
				call	my_enaslt0
				ld		a, [rom_slot]
				call	my_enaslt1
				jp		error_not_enough_memory
			endscope

; -----------------------------------------------------------------------------
;	Page0 �� RAM �ɐ؂�ւ���
; -----------------------------------------------------------------------------
			scope	change_to_ram_for_page0
change_to_ram_for_page0::
				xor		a, a					; �T���J�n�X���b�g SLOT#0 ���Z�b�g���� MSB [0][0][0][0][0][P][P] LSB : 
												;   E=�g���X���b�g����Ȃ�1, S=�Z�J���_���X���b�g(�g���X���b�g), 
												;   P=�v���C�}���X���b�g(��{�X���b�g)
				ld		hl, exptbl				; �e�X���b�g�ɂ�����g���X���b�g�̗L�� +0�`+3 �� 4bytes
	primary_slot_loop:
				ld		b, a
				push	af						; (1) ���[�v�p�ɃX���b�g�ԍ���ۑ�
				ld		a, [hl]
				push	hl						; (2) EXPTBL�̃A�h���X��ۑ�
				and		a, 0x80					; MSB �������o
				or		a, b					; �������ۑ����Ă�������{�X���b�g�ԍ����~�b�N�X���� [E][0][0][0][0][P][P]
				jp		m, expand_slot_found	; MSB �������Ă���Ίg���X���b�g����ł̏�����
				; �g���X���b�g�����������ꍇ
				call	check_page0				; page0 �� SLOT#A �ɐ؂�ւ��� RAM �����ׂ�BRAM �Ȃ� Zf=1
				push	af						; (3) �g���X���b�g����łƃX�^�b�N�����킹�邽�߂̃_�~�[
				jr		z, ram_found			; RAM �������ꍇ�Aram_found ��
				pop		af						; [3] �_�~�[���v��Ȃ���������̂�
				jr		next_primary_slot
	expand_slot_found:
				; �g���X���b�g���������ꍇ
				push	af						; (3) �X���b�g�ԍ���ۑ�
				call	check_page0				; page0 �� SLOT#A �ɐ؂�ւ��� RAM �����ׂ�BRAM �Ȃ� Zf=1
				jr		z, ram_found			; RAM �������ꍇ�Aram_found ��
				pop		af						; [3] �X���b�g�ԍ��𕜋A
				add		a, 0x04					; �g���X���b�g�ԍ����C���N�������g [E][0][0][S][S][P][P]
				bit		4, a					; bit4 ( [0]�ł���ׂ�bit ) �� 1 �ɂȂ�����I���
				jr		z, expand_slot_found	; �܂� 1 �ɂȂ��ĂȂ�����J��Ԃ�
	next_primary_slot:
				pop		hl						; [2] EXPTBL�̃A�h���X�𕜋A
				pop		af						; [1] ���[�v�p�ɕۑ������X���b�g�ԍ��𕜋A
				inc		a						; ��{�X���b�g�����ɐi�߂�
				inc		hl						; EXPTBL �����̊�{�X���b�g�֐i�߂�
				bit		2, a					; ��{�X���b�g�̃C���N�������g���g���X���b�g�̃t�B�[���h�܂ŐZ�H�������H
				jr		z, primary_slot_loop	; �Z�H���ĂȂ��̂ŌJ��Ԃ�
	ram_not_found:
				jp		goto_error				; �S�X���b�g���ׂ����ǌ�����Ȃ������ꍇ�͂����ɓ��B����
	ram_found:
				pop		hl						; [3] �ǂݎ̂�
				pop		hl						; [2] �ǂݎ̂�
				pop		af						; [1] �ǂݎ̂�
				ret
			endscope

			scope		check_page0
	check_page0::
				; page0 ���w��̃X���b�g�ɐ؂�ւ���
				ld		[ramad0], a				; �Ƃ肠�����ARAM�̃X���b�g�Ƃ��ăZ�b�g���Ă��܂�
				call	my_enaslt0				; page0 �����̃X���b�g�ɐ؂�ւ���
				; page0 �� RAM ���`�F�b�N����
				ld		hl, 0x0000				; 0000h ���璲��
		loop:
				ld		a, [hl]					; �l��ǂ�Ŕ��]���ď����߂��B
				cpl
				ld		[hl], a
				cp		a, [hl]					; RAM �Ȃ��v����(Zf=1)�BRAM����Ȃ���Έ�v���Ȃ�(Zf=0)�B
				cpl
				ld		[hl], a					; ���̒l�������߂��BRAM�������ꍇ�ł����e��j�󂵂Ȃ����߁B
				ret		nz						; RAM�łȂ���� Zf=0 �Ŗ߂�
				inc		hl						; ���̃A�h���X���`�F�b�N
				bit		6, h					; H=0x40 �ɂȂ�����I���
				jr		z, loop					; �܂��Ȃ��Ă��Ȃ��ꍇ�A�J��Ԃ�
				xor		a, a					; Zf=0 �ɂȂ��Ă�̂ŁARAM ���������Ƃ����� Zf=1 �ɕύX���Ė߂�B
				ret
			endscope

; -----------------------------------------------------------------------------
;	Page1 �� RAM �ɐ؂�ւ���
; -----------------------------------------------------------------------------
			scope	change_to_ram_for_page1
change_to_ram_for_page1::
				xor		a, a					; �T���J�n�X���b�g SLOT#0 ���Z�b�g���� MSB [0][0][0][0][0][P][P] LSB : 
												;   E=�g���X���b�g����Ȃ�1, S=�Z�J���_���X���b�g(�g���X���b�g), 
												;   P=�v���C�}���X���b�g(��{�X���b�g)
				ld		hl, exptbl				; �e�X���b�g�ɂ�����g���X���b�g�̗L�� +0�`+3 �� 4bytes
	primary_slot_loop:
				ld		b, a
				push	af						; (1) ���[�v�p�ɃX���b�g�ԍ���ۑ�
				ld		a, [hl]
				push	hl						; (2) EXPTBL�̃A�h���X��ۑ�
				and		a, 0x80					; MSB �������o
				or		a, b					; �������ۑ����Ă�������{�X���b�g�ԍ����~�b�N�X���� [E][0][0][0][0][P][P]
				jp		m, expand_slot_found	; MSB �������Ă���Ίg���X���b�g����ł̏�����
				; �g���X���b�g�����������ꍇ
				call	check_page1				; page1 �� SLOT#A �ɐ؂�ւ��� RAM �����ׂ�BRAM �Ȃ� Zf=1
				push	af						; (3) �g���X���b�g����łƃX�^�b�N�����킹�邽�߂̃_�~�[
				jr		z, ram_found			; RAM �������ꍇ�Aram_found ��
				pop		af						; [3] �_�~�[���v��Ȃ���������̂�
				jr		next_primary_slot
	expand_slot_found:
				; �g���X���b�g���������ꍇ
				push	af						; (3) �X���b�g�ԍ���ۑ�
				call	check_page1				; page1 �� SLOT#A �ɐ؂�ւ��� RAM �����ׂ�BRAM �Ȃ� Zf=1
				jr		z, ram_found			; RAM �������ꍇ�Aram_found ��
				pop		af						; [3] �X���b�g�ԍ��𕜋A
				add		a, 0x04					; �g���X���b�g�ԍ����C���N�������g [E][0][0][S][S][P][P]
				bit		4, a					; bit4 ( [0]�ł���ׂ�bit ) �� 1 �ɂȂ�����I���
				jr		z, expand_slot_found	; �܂� 1 �ɂȂ��ĂȂ�����J��Ԃ�
	next_primary_slot:
				pop		hl						; [2] EXPTBL�̃A�h���X�𕜋A
				pop		af						; [1] ���[�v�p�ɕۑ������X���b�g�ԍ��𕜋A
				inc		a						; ��{�X���b�g�����ɐi�߂�
				inc		hl						; EXPTBL �����̊�{�X���b�g�֐i�߂�
				bit		2, a					; ��{�X���b�g�̃C���N�������g���g���X���b�g�̃t�B�[���h�܂ŐZ�H�������H
				jr		z, primary_slot_loop	; �Z�H���ĂȂ��̂ŌJ��Ԃ�
	ram_not_found:
				jp		goto_error				; �S�X���b�g���ׂ����ǌ�����Ȃ������ꍇ�͂����ɓ��B����
	ram_found:
				pop		hl						; [3] �ǂݎ̂�
				pop		hl						; [2] �ǂݎ̂�
				pop		af						; [1] �ǂݎ̂�
				ret
			endscope

			scope		check_page1
	check_page1::
				; page1 ���w��̃X���b�g�ɐ؂�ւ���
				ld		[ramad1], a				; �Ƃ肠�����ARAM�̃X���b�g�Ƃ��ăZ�b�g���Ă��܂�
				call	my_enaslt1				; page1 �����̃X���b�g�ɐ؂�ւ���
				; page1 �� RAM ���`�F�b�N����
				ld		hl, 0x4000				; 4000h ���璲��
		loop:
				ld		a, [hl]					; �l��ǂ�Ŕ��]���ď����߂��B
				cpl
				ld		[hl], a
				cp		a, [hl]					; RAM �Ȃ��v����(Zf=1)�BRAM����Ȃ���Έ�v���Ȃ�(Zf=0)�B
				cpl
				ld		[hl], a					; ���̒l�������߂��BRAM�������ꍇ�ł����e��j�󂵂Ȃ����߁B
				ret		nz						; RAM�łȂ���� Zf=0 �Ŗ߂�
				inc		hl						; ���̃A�h���X���`�F�b�N
				bit		7, h					; H=0x80 �ɂȂ�����I���
				jr		z, loop					; �܂��Ȃ��Ă��Ȃ��ꍇ�A�J��Ԃ�
				xor		a, a					; Zf=0 �ɂȂ��Ă�̂ŁARAM ���������Ƃ����� Zf=1 �ɕύX���Ė߂�B
				ret
			endscope

; -----------------------------------------------------------------------------
;	Page0 ��؂�ւ��� ENASLT
;	input:
;		A .... �؂�ւ���X���b�g�̔ԍ�  MSB [Ex][0][0][0][ExSlot][ExSlot][PrimarySlot][PrimarySlot] LSB
;	output:
;		�Ȃ�
;	break:
;		AF,BC,DE,HL
;	comment:
;		di��ԂŖ߂�
; -----------------------------------------------------------------------------
			scope	my_enaslt0
my_enaslt0::
				ld		b, a					; B �ɃX���b�g�ԍ���ۑ��BMSB [E][0][0][0][S][S][P][P] LSB
				and		a, 0x83					; �w��̊�{�X���b�g�ԍ����擾����
				jp		m, my_enaslt0_ex
				; �g���X���b�g�ł͂Ȃ������ꍇ
				ld		c, a					; C = A = [0][0][0][0][0][0][P][P]
				di								; ���荞�ݏ����� 0038h ���؂�ւ��̂ƁA�X���b�g�M���Ă�r���Ŋ��荞�܂�Ė\������̂�h�����߂Ɋ��荞�݋֎~
				in		a, [ppi_slot_reg]		; PPI portA (A8h) ��ǂ݁Apage0 �Ɏw��� [P][P] ���Z�b�g
				and		a, 0b11111100
				or		a, c
				out		[ppi_slot_reg], a
				ret								; ���荞�݋֎~�̂܂ܖ߂�
				; �g���X���b�g�������ꍇ
	my_enaslt0_ex:
				and		a, 0x03
				ld		c, a					; C = [0][0][0][0][0][0][P][P]

				ld		hl, slttbl				; SLTTBL[slot] �̃A�h���X�����߂�BFCC5h �Ȃ̂� +0�`+3 ���Ă���� FCh �͕ω����Ȃ��B
				add		a, l
				ld		l, a					; HL = &SLTTBL[slot]

				ld		a, c
				rrca
				rrca
				or		a, c
				ld		c, a					; A = C = [P][P][0][0][0][0][P][P]
				di								; ���荞�ݏ����� 0038h ���؂�ւ��̂ƁA�X���b�g�M���Ă�r���Ŋ��荞�܂�Ė\������̂�h�����߂Ɋ��荞�݋֎~
				in		a, [ppi_slot_reg]		; PPI portA (A8h) ��ǂ݁Apage3 �y�� page0 �Ɏw��� [P][P] ���Z�b�g
				ld		d, a					; ��{�X���b�g���W�X�^���o�b�N�A�b�v
				and		a, 0b00111100
				or		a, c
				out		[ppi_slot_reg], a		; �܂��� page3 �y�� page0 ���w��̊�{�X���b�g�ɐ؂�ւ���
				ld		a, b					; �Ăяo�����Ɏw�肳�ꂽ�X���b�g�ԍ��� A �Ɏ擾
				and		a, 0b00001100			; �g���X���b�g�̔ԍ��𒊏o : [0][0][0][0][S][S][0][0]
				rrca							; page0 �Ȃ̂� bit1, bit0 �ɗ���悤�ɃV�t�g
				rrca
				ld		b, a					; B = A = [0][0][0][0][0][0][S][S]
				ld		a, [hl]					; �ȑO�A�g���X���b�g���W�X�^�ɏ������񂾃o�b�N�A�b�v��ǂݍ��� (BIOS�ƌ݊�)
				and		a, 0b11111100			; page0 �ɑΉ����� bit1, bit0 �� [S][S] �ɍ���������
				or		a, b
				ld		[ext_slot_reg], a		; �g���X���b�g���W�X�^���X�V
				ld		[hl], a					; �g���X���b�g���W�X�^�̃o�b�N�A�b�v���X�V�iBIOS�ƌ݊��j
				ld		a, d					; ��{�X���b�g���W�X�^�̌��̒l�� A �ɁB
				and		a, 0b11111100			; page0 ���� [P][P] �ɍ���������
				ld		b, a
				ld		a, c
				and		a, 0b00000011
				or		a, b
				out		[ppi_slot_reg], a		; page3 �����̃X���b�g�ɖ߂�
				ret
			endscope

; -----------------------------------------------------------------------------
;	Page1 ��؂�ւ��� ENASLT
;	input:
;		A .... �؂�ւ���X���b�g�̔ԍ�  MSB [Ex][0][0][0][ExSlot][ExSlot][PrimarySlot][PrimarySlot] LSB
;	output:
;		�Ȃ�
;	break:
;		AF,BC,DE,HL
;	comment:
;		di��ԂŖ߂�
; -----------------------------------------------------------------------------
			scope	my_enaslt1
my_enaslt1::
				ld		b, a					; B �ɃX���b�g�ԍ���ۑ��BMSB [E][0][0][0][S][S][P][P] LSB
				and		a, 0x83					; �w��̊�{�X���b�g�ԍ����擾����
				jp		m, my_enaslt1_ex
				; �g���X���b�g�ł͂Ȃ������ꍇ
				rlca
				rlca
				ld		c, a					; C = A = [0][0][0][0][P][P][0][0]
				di								; �X���b�g�M���Ă�r���Ŋ��荞�܂�Ė\������̂�h�����߂Ɋ��荞�݋֎~
				in		a, [ppi_slot_reg]		; PPI portA (A8h) ��ǂ݁Apage0 �Ɏw��� [P][P] ���Z�b�g
				and		a, 0b11110011
				or		a, c
				out		[ppi_slot_reg], a
				ret								; ���荞�݋֎~�̂܂ܖ߂�
				; �g���X���b�g�������ꍇ
	my_enaslt1_ex:
				and		a, 0x03
				ld		c, a					; C = [0][0][0][0][0][0][P][P]

				ld		hl, slttbl				; SLTTBL[slot] �̃A�h���X�����߂�BFCC5h �Ȃ̂� +0�`+3 ���Ă���� FCh �͕ω����Ȃ��B
				add		a, l
				ld		l, a					; HL = &SLTTBL[slot]

				ld		a, c
				rlca
				rlca
				ld		c, a					; C = [0][0][0][0][P][P][0][0]
				rlca
				rlca
				rlca
				rlca
				or		a, c
				ld		c, a					; A = C = [P][P][0][0][P][P][0][0]
				di								; ���荞�ݏ����� 0038h ���؂�ւ��̂ƁA�X���b�g�M���Ă�r���Ŋ��荞�܂�Ė\������̂�h�����߂Ɋ��荞�݋֎~
				in		a, [ppi_slot_reg]		; PPI portA (A8h) ��ǂ݁Apage3 �y�� page0 �Ɏw��� [P][P] ���Z�b�g
				ld		d, a					; ��{�X���b�g���W�X�^���o�b�N�A�b�v
				and		a, 0b00110011
				or		a, c
				out		[ppi_slot_reg], a		; �܂��� page3 �y�� page1 ���w��̊�{�X���b�g�ɐ؂�ւ���
				ld		a, b					; �Ăяo�����Ɏw�肳�ꂽ�X���b�g�ԍ��� A �Ɏ擾
				and		a, 0b00001100			; �g���X���b�g�̔ԍ��𒊏o : [0][0][0][0][S][S][0][0]
				ld		b, a					; B = A = [0][0][0][0][S][S][0][0]
				ld		a, [hl]					; �ȑO�A�g���X���b�g���W�X�^�ɏ������񂾃o�b�N�A�b�v��ǂݍ��� (BIOS�ƌ݊�)
				and		a, 0b11110011			; page1 �ɑΉ����� bit3, bit2 �� [S][S] �ɍ���������
				or		a, b
				ld		[ext_slot_reg], a		; �g���X���b�g���W�X�^���X�V
				ld		[hl], a					; �g���X���b�g���W�X�^�̃o�b�N�A�b�v���X�V�iBIOS�ƌ݊��j
				ld		a, d					; ��{�X���b�g���W�X�^�̌��̒l�� A �ɁB
				and		a, 0b11110011			; page1 ���� [P][P] �ɍ���������
				ld		b, a
				ld		a, c
				and		a, 0b00001100
				or		a, b
				out		[ppi_slot_reg], a		; page3 �����̃X���b�g�ɖ߂�
				ret
			endscope
page2_routine_on_ram_end::
		endscope
			org		page2_routine_on_rom + page2_routine_on_ram_end - page2_routine_on_ram

message_not_enough_memory::
			db		"Not enough memory", 0x0D, 0x0A, 0
