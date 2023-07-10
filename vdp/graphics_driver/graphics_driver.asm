; =============================================================================
;	Graphics Driver
; -----------------------------------------------------------------------------
;	2023/July/2rd	t.hara (HRA!)
; =============================================================================

vdp_port0	:= 0x98
vdp_port1	:= 0x99
vdp_port2	:= 0x9A
vdp_port3	:= 0x9B
jiffy		:= 0xFC9E

; -----------------------------------------------------------------------------
;	public grp_palette
;	input)
;		vr ..... �� 0�`255 �̒萔
;		vg ..... �� 0�`255 �̒萔
;		vb ..... �� 0�`255 �̒萔
;	output)
;		none
;	break)
;		all
;	description)
;		WindowsPC �Ŏg���Ă��� 8bit�[�x�J���[���w�肷��B
;		���ۂɂ́A�P���� 1/32�{���ꂽ�l���ݒ肳���B
;		�P�Ȃ�f�[�^��`�̃}�N���ł���B
; -----------------------------------------------------------------------------
grp_palette		macro		vr, vg, vb
				db			((vr/32) << 4) | (vb/32)
				db			(vg/32)
				endm

; -----------------------------------------------------------------------------
;	public grp_dpalette
;	input)
;		vr ..... �� 0�`7 �̒萔
;		vg ..... �� 0�`7 �̒萔
;		vb ..... �� 0�`7 �̒萔
;	output)
;		none
;	break)
;		all
;	description)
;		MSX2�̃p���b�g�̐[�x�ŁA���ڒl(direct)���w�肷��B
;		�P�Ȃ�f�[�^��`�̃}�N���ł���B
; -----------------------------------------------------------------------------
grp_dpalette	macro		vr, vg, vb
				db			(vr << 4) | (vb)
				db			(vg)
				endm

; -----------------------------------------------------------------------------
;	public grp_initialize
;	input)
;		none
;	output)
;		none
;	break)
;		all
;	description)
;		�^���X�v���C�g�̂��߂̏���������
;		page0, page1 �̔w�i��������������AFIFO������������B
; -----------------------------------------------------------------------------
			scope		grp_initialize
grp_initialize::
			; �w�i�摜�� page0 �ɓ]������
			ld			de, (0 << 8) | 0
			ld			hl, (0 << 8) | 0
			ld			bc, (160 << 8) | 0
			ld			a, (0 << 2) | 2
			call		grp_copy_hs
			; �w�i�摜�� page1 �ɓ]������
			ld			de, (0 << 8) | 0
			ld			hl, (0 << 8) | 0
			ld			bc, (160 << 8) | 0
			ld			a, (1 << 2) | 2
			call		grp_copy_hs
			; FIFO�̏�����
			xor			a, a
			ld			[draw_page], a
			ld			[sprite_fifo_count], a
			ld			[erase_fifo_next_count], a
			ld			[erase_fifo_current_count], a
			ld			hl, erase_fifo_page0
			ld			[erase_fifo_ptr], hl
			jp			_grp_prepare_next_frame
			endscope

; -----------------------------------------------------------------------------
;	public grp_set_vdp
;	input)
;		A ............... �������ޒl
;		register_num .... ���W�X�^�ԍ�
;	output)
;		none
;	break)
;		A
;	description)
;		VDP���W�X�^ R#{register_num} �� A �̒l����������
;		grp_initialize�O�Ɏ��s�\
; -----------------------------------------------------------------------------
grp_set_vdp	macro		register_num
			di
			out			[vdp_port1], a
			ld			a, 0x80 | register_num
			out			[vdp_port1], a
			ei
			endm

; -----------------------------------------------------------------------------
;	public grp_set_palette
;	input)
;		HL .... �p���b�g�f�[�^�̃A�h���X
;	output)
;		HL .... �p���b�g�f�[�^�̎��̃A�h���X
;	break)
;		AF, BC
;	description)
;		grp_initialize�O�Ɏ��s�\
;		16�p���b�g�܂Ƃ߂Đݒ肷��B
;		palette#0 �` #15 ��ԍ����ɕ��ׂ��e�[�u���̃A�h���X�� HL �ɐݒ肷��B
;
;		HL --> [RB][0G][RB][0G] ... [RB][0G]
;
;		[RB][0G] �� 2byte �́Agrp_palette �}�N�� �܂��� grp_dpalette �}�N��
;		���g�p���č쐬����B���L�̂悤�Ƀe�[�u���쐬���邱�Ƃ����҂��Ă���B
;
;			grp_palette		  0, 111,  87			; #0
;			grp_palette		  0,   0,   0			; #1
;			grp_palette		 12, 222,  54			; #2
;			grp_palette		128, 255, 144			; #3
;			grp_palette		  0,   0, 255			; #4
;			grp_palette		  0, 165, 255			; #5
;			grp_palette		120,   0,   0			; #6
;			grp_palette		  0, 225, 255			; #7
;			grp_palette		204,   0,   0			; #8
;			grp_palette		255, 105,   0			; #9
;			grp_palette		144, 108,   0			; #10
;			grp_palette		201, 174,   0			; #11
;			grp_palette		  0, 141,   0			; #12
;			grp_palette		255, 255, 162			; #13
;			grp_palette		  0, 255, 255			; #14
;			grp_palette		255, 255, 255			; #15
; -----------------------------------------------------------------------------
			scope		grp_set_palette
grp_set_palette::
			xor			a, a
			di
			out			[vdp_port1], a
			ld			a, 0x80 | 16
			out			[vdp_port1], a		; VDP R#16 = 0 (palette index)
			ei
			ld			bc, (32 << 8) | vdp_port2
			otir
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_check_vdp
;	input)
;		none
;	output)
;		Zf .... 1: VDP�R�}���h��~��, 0: VDP�R�}���h���s��
;	break)
;		AF, BC
;	description)
;		VDP�R�}���h���s�������ׂ�
;		grp_initialize�O�Ɏ��s�\
; -----------------------------------------------------------------------------
			scope		grp_check_vdp
grp_check_vdp::
			; VDP R#15 = S#2
			ld			bc, ((0x80 | 15) << 8) | vdp_port1
			ld			a, 2
			di
			out			[c], a
			out			[c], b
			; CE bit �� 1 �Ȃ� Zf = 0
			in			a, [c]
			and			a, 1			; Zf 1: VDP�R�}���h��~��, 0: VDP�R�}���h���s��
			; VDP R#15 = S#0
			ld			a, 0			; Zf �s��
			out			[c], a			; Zf �s��
			out			[c], b			; Zf �s��
			ei							; Zf �s��
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_wait_vdp
;	input)
;		none
;	output)
;		none
;	break)
;		none
;	description)
;		VDP�R�}���h���s�����܂őҋ@����
;		grp_initialize�O�Ɏ��s�\
; -----------------------------------------------------------------------------
			scope		grp_wait_vdp
grp_wait_vdp::
			push		af
			push		bc
			; VDP R#15 = S#2
			ld			bc, ((0x80 | 15) << 8) | vdp_port1
	loop:
			ld			a, 2
			di
			out			[c], a
			out			[c], b
			; CE bit �� 1 �Ȃ� Zf = 0
			in			a, [c]
			and			a, 1			; Zf 1: VDP�R�}���h��~��, 0: VDP�R�}���h���s��
			; VDP R#15 = S#0
			ld			a, 0			; Zf �s��
			out			[c], a			; Zf �s��
			out			[c], b			; Zf �s��
			ei							; Zf �s��
			jp			nz, loop
			pop			bc
			pop			af
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_get_sprite_pattern_position
;	input)
;		A ..... �X�v���C�g�p�^�[���ԍ� 0�`255
;	output)
;		E ..... X���W
;		D ..... Y���W
;	break)
;		AF
;	description)
;		�X�v���C�g�p�^�[���ԍ����� grp_put_parts �̓��� ( e, d ) �Ɏg������W��
;		���߂�B
;		grp_initialize�O�Ɏ��s�\
; -----------------------------------------------------------------------------
			scope		grp_get_sprite_pattern_position
grp_get_sprite_pattern_position::
			ld			d, a
			and			a, 0x0F
			add			a, a
			add			a, a
			add			a, a
			add			a, a
			ld			e, a				; �p�[�c X���W = (A & 15) << 4
			ld			a, d
			and			a, 0xF0
			ld			[hl], a				; �p�[�c Y���W = A & (15 << 4)
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_put_parts
;	input)
;		E ..... X���W
;		D ..... Y���W
;		A ..... �`��y�[�W
;		HL .... �摜�A�h���X (128bytes)
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		16x16�T�C�Y�̃p�[�c���w��̃y�[�W�̎w��̍��W�֕`�悷��
;		grp_initialize�O�Ɏ��s�\
; -----------------------------------------------------------------------------
			scope		grp_put_parts
grp_put_parts::
			push		hl
			; VDP R#17 = R#36 (�I�[�g�C���N�������g)
			ld			c, vdp_port1
			ld			b, 0x00 | 36
			di
			out			[c], b
			ld			b, 0x80 | 17
			out			[c], b
			; C = vdp_port3
			inc			c
			inc			c
			ld			hl, fixed_datas
			; VDP Command
			out			[c], e			; R#36 DX����
			outi						; R#37 DX���
			out			[c], d			; R#38 DY����
			out			[c], a			; R#39 DY���, �`��y�[�W
			outi						; R#40 NX����
			outi						; R#41 NX���
			outi						; R#42 NY����
			outi						; R#43 NY���
			pop			de
			ex			de, hl
			outi						; R#44 CLR
			ex			de, hl
			outi						; R#45 ARG
			outi						; R#46 CMD
			ex			de, hl
			ld			b, 8 * 16 - 1
			; R#17 = R#44 (��I�[�g�C���N�������g)
			ld			a, 0x80 | 44
			out			[vdp_port1], a
			ld			a, 0x80 | 17
			out			[vdp_port1], a
			otir
			ei
			ret
	fixed_datas:
			db			0				; R#37 DX���
			db			16				; R#40 NX����
			db			0				; R#41 NX���
			db			16				; R#42 NY����
			db			0				; R#43 NY���
			db			0				; R#45 ARG
			db			0b1111_0000		; R#46 CMD HMMC
			endscope

; -----------------------------------------------------------------------------
;	private _grp_erase_sprite
;	input)
;		E ..... X���W
;		D ..... Y���W
;		A ..... �`��y�[�W
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		16x16�T�C�Y�̏���
; -----------------------------------------------------------------------------
			scope		_grp_erase_sprite
_grp_erase_sprite::
			; VDP R#17 = R#32 (�I�[�g�C���N�������g)
			ld			bc, ((0x00 | 32) << 8) + vdp_port1
			di
			out			[c], b
			ld			b, 0x80 | 17
			out			[c], b
			; C = vdp_port3
			inc			c
			inc			c
			ld			hl, fixed_datas
			; VDP Command
			out			[c], e			; R#32 SX����
			outi						; R#33 SX���
			out			[c], d			; R#34 SY����
			outi						; R#35 SY���
			out			[c], e			; R#36 DX����
			outi						; R#37 DX���
			out			[c], d			; R#38 DY����
			out			[c], a			; R#39 DY���, �]����y�[�W
			outi						; R#40 NX����
			outi						; R#41 NX���
			outi						; R#42 NY����
			outi						; R#43 NY���
			outi						; R#44 CLR
			outi						; R#45 ARG
			outi						; R#46 CMD
			ei
			ret
	fixed_datas:
			db			0				; R#33 SX���
			db			2				; R#35 SY���, �]�����y�[�W
			db			0				; R#37 DX���
			db			16				; R#40 NX����
			db			0				; R#41 NX���
			db			16				; R#42 NY����
			db			0				; R#43 NY���
			db			0				; R#44 CLR
			db			0				; R#45 ARG
			db			0b1101_0000		; R#46 CMD HMMM
			endscope

; -----------------------------------------------------------------------------
;	private _grp_draw_sprite (�����p)
;	input)
;		E ..... �p�[�c X���W
;		D ..... �p�[�c Y���W
;		C ..... �\�� X���W
;		B ..... �\�� Y���W
;		A ..... �`��y�[�W
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		16x16�T�C�Y�̋^���X�v���C�g�`��
; -----------------------------------------------------------------------------
			scope		_grp_draw_sprite
_grp_draw_sprite::
			; VDP R#17 = R#32 (�I�[�g�C���N�������g)
			push		bc
			ld			bc, ((0x00 | 32) << 8) + vdp_port1
			di
			out			[c], b
			ld			b, 0x80 | 17
			out			[c], b
			; C = vdp_port3
			inc			c
			inc			c
			ld			hl, fixed_datas
			; VDP Command
			out			[c], e			; R#32 SX����
			outi						; R#33 SX���
			out			[c], d			; R#34 SY����
			outi						; R#35 SY���
			pop			de
			out			[c], e			; R#36 DX����
			outi						; R#37 DX���
			out			[c], d			; R#38 DY����
			out			[c], a			; R#39 DY���, �]����y�[�W
			outi						; R#40 NX����
			outi						; R#41 NX���
			outi						; R#42 NY����
			outi						; R#43 NY���
			outi						; R#44 CLR
			outi						; R#45 ARG
			outi						; R#46 CMD
			ei
			ret
	fixed_datas:
			db			0				; R#33 SX���
			db			3				; R#34 SY���, �]�����y�[�W
			db			0				; R#37 DX���
			db			16				; R#40 NX����
			db			0				; R#41 NX���
			db			16				; R#42 NY����
			db			0				; R#43 NY���
			db			0				; R#44 CLR
			db			0				; R#45 ARG
			db			0b1001_1000		; R#46 CMD LMMM, TIMP
			endscope

; -----------------------------------------------------------------------------
;	public grp_put_sprite
;	input)
;		E ..... X���W (�����̂�)
;		D ..... Y���W
;		A ..... �p�[�c�ԍ�
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		16x16�T�C�Y�̕`��w��
;		���E���J�E���g�͍s���Ă��Ȃ����߁A1�t���[������ grp_sprite_max_num ���
;		������񐔌Ăяo���Ă͂Ȃ�Ȃ��B
; -----------------------------------------------------------------------------
			scope		grp_put_sprite
grp_put_sprite::
			; �\���pFIFO �֋l�߂�
			ld			hl, [sprite_fifo_ptr]
			ld			[hl], e				; �\�� X���W
			inc			hl
			ld			[hl], d				; �\�� Y���W
			inc			hl
			; -- �p�[�c�ԍ���]�������W�ɕϊ�����
			ld			d, a
			and			a, 0x0F
			add			a, a
			add			a, a
			add			a, a
			add			a, a
			ld			[hl], a				; �p�[�c X���W = (A & 15) << 4
			inc			hl
			ld			a, d
			and			a, 0xF0
			ld			[hl], a				; �p�[�c Y���W = A & (15 << 4)
			inc			hl
			ld			[sprite_fifo_ptr], hl
			ld			a, [sprite_fifo_count]
			inc			a
			ld			[sprite_fifo_count], a
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_flash_fifo
;	input)
;		none
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		FIFO ����Ŗ�����΁A1���s����
; -----------------------------------------------------------------------------
			scope		grp_flash_fifo
grp_flash_fifo::
			; VDP�R�}���h���`�F�b�N
			call		grp_check_vdp
			ret			nz								; VDP�R�}���h���s���Ȃ牽�����Ȃ�
			; �����pFIFO���m�F����
			ld			a, [erase_fifo_current_count]
			or			a, a
			jp			z, draw_sprite					; Cy = 0 �� draw_sprite ��
			; �����pFIFO��1���s
			dec			a
			ld			[erase_fifo_current_count], a	; �������炷
			ld			hl, [erase_fifo_ptr]
			ld			e, [hl]							; ���� X���W
			inc			hl
			ld			d, [hl]							; ���� Y���W
			inc			hl
			ld			[erase_fifo_ptr], hl
			ld			a, [draw_page]
			call		_grp_erase_sprite
			; ����FIFO�̍Ō��1���������H
			ld			a, [erase_fifo_current_count]
			or			a, a
			ret			nz								; �Ō��1�ł͖��������̂ŁA�߂�
			; ����FIFO�̍Ō��1�������̂ŁA�|�C���^�����Z�b�g����
			ld			a, [draw_page]
			or			a, a
			jr			nz, reset_erase_fifo_ptr_for_page1
	reset_erase_fifo_ptr_for_page0:
			ld			hl, erase_fifo_page0
			ld			[erase_fifo_ptr], hl
			ret
	reset_erase_fifo_ptr_for_page1:
			ld			hl, erase_fifo_page1
			ld			[erase_fifo_ptr], hl
			ret
	draw_sprite:
			; �\���pFIFO���m�F����
			ld			hl, [sprite_fifo_draw_ptr]
			ld			de, [sprite_fifo_ptr]
			push		hl
			sbc			hl, de
			pop			hl
			ret			z								; �\���pFIFO�͋�
			; �\���pFIFO����1�擾
			ld			c, [hl]							; �\�� X���W
			inc			hl
			ld			b, [hl]							; �\�� Y���W
			inc			hl
			ld			e, [hl]							; �p�[�c X���W
			inc			hl
			ld			d, [hl]							; �p�[�c Y���W
			inc			hl
			ld			[sprite_fifo_draw_ptr], hl
			; �����pFIFO��1�ς�
			ld			hl, [erase_fifo_ptr]
			ld			[hl], c							; ���� X���W
			inc			hl
			ld			[hl], b							; ���� Y���W
			inc			hl
			ld			[erase_fifo_ptr], hl
			ld			a, [draw_page]
			jp			_grp_draw_sprite
			endscope

; -----------------------------------------------------------------------------
;	public grp_flash_all
;	input)
;		none
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		FIFO ����ɂȂ�܂ŏ������āA�\���y�[�W�E�`��y�[�W�����ւ��A
;		���̃t���[���̂��߂̏���������
;		���� API ���Ă񂾌�́Agrp_flip ���ĂԂ܂ŁA���� grp API ���Ă�ł͂Ȃ�Ȃ��B
; -----------------------------------------------------------------------------
			scope		grp_flash_all
grp_flash_all::
			; �����pFIFO���m�F����
			ld			a, [erase_fifo_current_count]
			or			a, a
			jr			z, draw_sprite					; erase_fifo_current_count = 0 �� draw_sprite ��
	erase_loop:
			; �����pFIFO��1���s
			dec			a
			ld			[erase_fifo_current_count], a	; �������炷
			ld			hl, [erase_fifo_ptr]
			ld			e, [hl]							; ���� X���W
			inc			hl
			ld			d, [hl]							; ���� Y���W
			inc			hl
			ld			[erase_fifo_ptr], hl
			ld			a, [draw_page]
			call		grp_wait_vdp
			call		_grp_erase_sprite
			ld			a, [erase_fifo_current_count]
			or			a, a
			jr			nz, erase_loop					; erase_fifo_current_count != 0 �� erase_loop ��
			; �Ō��1����������
			ld			a, [draw_page]
			or			a, a
			jr			nz, reset_erase_fifo_ptr_for_page1
	reset_erase_fifo_ptr_for_page0:
			ld			hl, erase_fifo_page0
			ld			[erase_fifo_ptr], hl
			jr			draw_sprite
	reset_erase_fifo_ptr_for_page1:
			ld			hl, erase_fifo_page1
			ld			[erase_fifo_ptr], hl
	draw_sprite:
			; �\���pFIFO���m�F����
			ld			hl, [sprite_fifo_draw_ptr]
			ld			de, [sprite_fifo_ptr]
			push		hl
			or			a, a
			sbc			hl, de
			pop			hl
			jr			z, _grp_prepare_next_frame		; �\���pFIFO�͋�
			; �\���pFIFO��1���s
			ld			c, [hl]							; �\�� X���W
			inc			hl
			ld			b, [hl]							; �\�� Y���W
			inc			hl
			ld			e, [hl]							; �p�[�c X���W
			inc			hl
			ld			d, [hl]							; �p�[�c Y���W
			inc			hl
			ld			[sprite_fifo_draw_ptr], hl
			ld			a, [draw_page]
			; �����pFIFO��1�ς�
			push		hl
			ld			hl, [erase_fifo_ptr]
			ld			[hl], c							; ���� X���W
			inc			hl
			ld			[hl], b							; ���� Y���W
			inc			hl
			ld			[erase_fifo_ptr], hl
			call		grp_wait_vdp
			call		_grp_draw_sprite
			pop			hl
			jp			draw_sprite
	_grp_prepare_next_frame::
			; erase_fifo �̏���
			ld			a, [erase_fifo_next_count]
			ld			[erase_fifo_current_count], a
			ld			a, [sprite_fifo_count]
			ld			[erase_fifo_next_count], a
			xor			a, a
			ld			[sprite_fifo_count], a
			; draw_fifo �̏���
			ld			hl, sprite_fifo
			ld			[sprite_fifo_ptr], hl
			ld			[sprite_fifo_draw_ptr], hl
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_flip
;	input)
;		none
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		VSYNC �҂������āA�\���y�[�W�ƕ`��y�[�W�����ւ���
;		���� API �����荞�ݏ����̒��ŌĂ�ł͂Ȃ�Ȃ�
; -----------------------------------------------------------------------------
			scope		grp_flip
grp_flip::
			; VSYNC�҂�
			ld			hl, jiffy
			ld			a, [hl]
			ei
	wait_loop:
			cp			a, [hl]
			jr			z, wait_loop
grp_flip_no_wait::
			; draw_page ���X���b�v
			ld			a, [draw_page]
			xor			a, 1
			ld			[draw_page], a
			jr			nz, next_frame_is_draw_page1
	next_frame_is_draw_page0:
			; erase FIFO ������������
			ld			hl, erase_fifo_page0
			ld			[erase_fifo_ptr], hl
			; �\���y�[�W�� 1 �ɂ���
			ld			a, 0b0_01_11111				; Display page = 1 : { 0, page, 11111 }
			di
			out			[vdp_port1], a
			ld			a, 0x80 | 2
			out			[vdp_port1], a
			ei
			ret
	next_frame_is_draw_page1:
			; erase FIFO ������������
			ld			hl, erase_fifo_page1
			ld			[erase_fifo_ptr], hl
			; �\���y�[�W�� 0 �ɂ���
			ld			a, 0b0_00_11111				; Display page = 0 : { 0, page, 11111 }
			di
			out			[vdp_port1], a
			ld			a, 0x80 | 2
			out			[vdp_port1], a
			ei
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_copy
;	input)
;		E ..... �]���� X���W
;		D ..... �]���� Y���W
;		L ..... �]���� X���W
;		H ..... �]���� Y���W
;		C ..... �]�������T�C�Y(�E����)
;		B ..... �]�������T�C�Y(������)
;		A ..... [1:0] �]�����y�[�W�A[3:2] �]����y�[�W
;		HL .... �摜�A�h���X (128bytes)
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		grp_initialize�O�Ɏ��s�\
;		LMMM�]�� (�h�b�g�P�ʂ����x��)
; -----------------------------------------------------------------------------
			scope		grp_copy
grp_copy::
			; VDP R#17 = R#32 (�I�[�g�C���N�������g)
			push		bc
			call		grp_wait_vdp
			ld			c, vdp_port1
			ld			b, 0x00 | 32
			di
			out			[c], b
			ld			b, 0x80 | 17
			out			[c], b
			; C = vdp_port3
			inc			c
			inc			c
			; VDP Command
			out			[c], e			; R#32 SX����
			ld			e, 0
			out			[c], e			; R#33 SX���
			out			[c], d			; R#34 SY����
			ld			d, a
			and			a, 0b0000_0011
			out			[c], a			; R#35 SY���, �]�����y�[�W
			out			[c], l			; R#36 DX����
			out			[c], e			; R#37 DX���
			out			[c], h			; R#38 DY����
			ld			a, d
			srl			a
			srl			a
			out			[c], a			; R#39 DY���, �]����y�[�W
			pop			hl
			out			[c], l			; R#40 NX����
			ld			d, e
			inc			l
			dec			l
			jr			nz, skip_inc
			inc			d
		skip_inc:
			out			[c], d			; R#41 NX���
			out			[c], h			; R#42 NY����
			out			[c], e			; R#43 NY���
			out			[c], e			; R#44 CLR
			out			[c], e			; R#45 ARG
			ld			a, 0b1001_0000	; LMMM, IMP
			out			[c], a			; R#46 CMD
			ei
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_copy_hs
;	input)
;		E ..... �]���� X���W (�����̂�)
;		D ..... �]���� Y���W
;		L ..... �]���� X���W (�����̂�)
;		H ..... �]���� Y���W
;		C ..... �]�������T�C�Y(�E����) (�����̂�)
;		B ..... �]�������T�C�Y(������)
;		A ..... [1:0] �]�����y�[�W�A[3:2] �]����y�[�W
;		HL .... �摜�A�h���X (128bytes)
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		grp_initialize�O�Ɏ��s�\
;		HMMM�]�� (X�����P�ʂ�������)
; -----------------------------------------------------------------------------
			scope		grp_copy_hs
grp_copy_hs::
			; VDP R#17 = R#32 (�I�[�g�C���N�������g)
			push		bc
			call		grp_wait_vdp
			ld			c, vdp_port1
			ld			b, 0x00 | 32
			di
			out			[c], b
			ld			b, 0x80 | 17
			out			[c], b
			; C = vdp_port3
			inc			c
			inc			c
			; VDP Command
			out			[c], e			; R#32 SX����
			ld			e, 0
			out			[c], e			; R#33 SX���
			out			[c], d			; R#34 SY����
			ld			d, a
			and			a, 0b0000_0011
			out			[c], a			; R#35 SY���, �]�����y�[�W
			out			[c], l			; R#36 DX����
			out			[c], e			; R#37 DX���
			out			[c], h			; R#38 DY����
			ld			a, d
			srl			a
			srl			a
			out			[c], a			; R#39 DY���, �]����y�[�W
			pop			hl
			out			[c], l			; R#40 NX����
			ld			d, e
			inc			l
			dec			l
			jr			nz, skip_inc
			inc			d
		skip_inc:
			out			[c], d			; R#41 NX���
			out			[c], h			; R#42 NY����
			out			[c], e			; R#43 NY���
			out			[c], e			; R#44 CLR
			out			[c], e			; R#45 ARG
			ld			a, 0b1101_0000	; HMMM
			out			[c], a			; R#46 CMD
			ei
			ret
			endscope
