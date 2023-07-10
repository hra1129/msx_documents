; =============================================================================
;	Graphics Driver
; -----------------------------------------------------------------------------
;	2023/July/2rd	t.hara (HRA!)
; =============================================================================

chgmod			:= 0x005F				; SCREEN A

forclr			:= 0xF3E9				; �O�i�F
bakclr			:= 0xF3EA				; �w�i�F
bdrclr			:= 0xF3EB				; ���ӐF

rg8sav			:= 0xFFE7				; VDP R#8
rg9sav			:= 0xFFE8				; VDP R#9

			org			0x4000

			ds			"AB"
			dw			entry
			dw			0
			dw			0
			dw			0
			dw			0
			dw			0
			dw			0

; =============================================================================
			scope		entry
entry::
			; COLOR 15,4,4:SCREEN 5
			ld			hl, (4 << 8) | 15
			ld			[forclr], hl
			ld			a, h
			ld			[bdrclr], a
			ld			a, 5
			call		chgmod
			; �X�v���C�g����
			ld			a, [rg8sav]
			or			a, 0b00000010		; �X�v���C�g����
			grp_set_vdp 8					; VDP R#8 = A
			; 192���C�����[�h
			ld			a, [rg9sav]
			and			a, 0b01111111		; 192���C�����[�h
			grp_set_vdp 9					; VDP R#9 = A
			; �J���[�p���b�g������
			ld			hl, initial_palette
			call		grp_set_palette
			; �X�v���C�g�p�[�c��`�悷��
			ld			hl, graphic_parts0
			ld			e, 0
			ld			d, 0
			ld			a, 3
			call		grp_put_parts

			ld			hl, graphic_parts1
			ld			e, 16
			ld			d, 0
			ld			a, 3
			call		grp_put_parts

			ld			hl, graphic_parts2
			ld			e, 32
			ld			d, 0
			ld			a, 3
			call		grp_put_parts

			ld			hl, graphic_parts3
			ld			e, 48
			ld			d, 0
			ld			a, 3
			call		grp_put_parts

			ld			hl, graphic_parts16
			ld			e, 0
			ld			d, 0
			ld			a, 2
			call		grp_put_parts

			ld			e, 0
			ld			d, 0
			ld			l, 16
			ld			h, 0
			ld			c, 240
			ld			b, 16
			ld			a, (2 << 2) | 2
			call		grp_copy_hs

			ld			e, 0
			ld			d, 0
			ld			l, 0
			ld			h, 16
			ld			c, 0
			ld			b, 144
			ld			a, (2 << 2) | 2
			call		grp_copy_hs

			call		grp_initialize

			ld			hl, 0x1234
			ld			[random_seed + 0], hl
			ld			hl, 0xABCD
			ld			[random_seed + 2], hl
			call		object_initialize

			ld			a, 20					; �������\������X�v���C�g�̐� (Max60)
			ld			[display_objects], a

		main_loop:
			; �I�u�W�F�N�g#0 ����J�n
			ld			a, [display_objects]
			ld			[current_object], a
			ld			hl, objects_info
		current_object_loop:
			; ���ڃI�u�W�F�N�g���ړ�����
			call		move_object
			; VDP���󂢂ĂāAFIFO�ɉ������܂��Ă�Ώ�������
			push		hl
			call		grp_flash_fifo
			pop			hl
			; ���̃I�u�W�F�N�g
			ld			a, [current_object]
			dec			a
			ld			[current_object], a
			jr			nz, current_object_loop
			; FIFO�Ɏc���Ă镪��S���������āA��ʂ�؂�ւ�
			call		grp_flash_all
			call		grp_flip
			jp			main_loop
			endscope

			scope		move_object
move_object::
			; X���W
			ld			a, [hl]				; X���W
			inc			hl
			add			a, [hl]				; A = X + VX
			dec			hl
			ld			[hl], a				; X���W�X�V
			cp			a, 248				; ���� 248�`255 �Ȃ獶�ɂ͂ݏo����
			jr			c, skip_adjust_x1
			; ���ɂ͂ݏo�����̂ō��[�ɓ\��t���AVX�𕄍����]����
			inc			hl
			ld			a, [hl]				; A = VX
			neg
			ld			[hl], a				; VX = -A
			dec			hl
			xor			a, a
			ld			[hl], a				; X���W = 0
		skip_adjust_x1:
			cp			a, 241				; ���� 241�`247 �Ȃ�E�ɂ͂ݏo����
			jr			c, skip_adjust_x2
			; �E�ɂ͂ݏo�����̂ŉE�[�ɓ\��t���AVX�𕄍����]����
			inc			hl
			ld			a, [hl]				; A = VX
			neg
			ld			[hl], a				; VX = -A
			dec			hl
			ld			a, 240
			ld			[hl], a				; X���W = 240
		skip_adjust_x2:
			ld			e, a				; E = X���W
			inc			hl
			inc			hl
			; Y���W
			ld			a, [hl]				; Y���W
			inc			hl
			add			a, [hl]				; A = Y + VY
			dec			hl
			ld			[hl], a				; Y���W�X�V
			cp			a, 248				; ���� 248�`255 �Ȃ��ɂ͂ݏo����
			jr			c, skip_adjust_y1
			; ��ɂ͂ݏo�����̂ŏ�[�ɓ\��t���AVY�𕄍����]����
			inc			hl
			ld			a, [hl]				; A = VY
			neg
			ld			[hl], a				; VY = -A
			dec			hl
			xor			a, a
			ld			[hl], a				; Y���W = 0
		skip_adjust_y1:
			cp			a, 145				; ���� 145�` �Ȃ牺�ɂ͂ݏo����
			jr			c, skip_adjust_y2
			; ���ɂ͂ݏo�����̂ŉ��[�ɓ\��t���AVY�𕄍����]����
			inc			hl
			ld			a, [hl]				; A = VY
			neg
			ld			[hl], a				; VY = -A
			dec			hl
			ld			a, 144
			ld			[hl], a				; Y���W = 144
		skip_adjust_y2:
			ld			d, a				; D = Y���W
			inc			hl
			inc			hl
			; �J�����g�ԍ����p�[�c�ԍ��ɂ���
			ld			a, [current_object]
			and			a, 3
			push		hl
			; �X�v���C�g�\��
			call		grp_put_sprite
			pop			hl
			ret
			endscope

; =============================================================================
			scope		object_initialize
object_initialize::
			ld			b, grp_sprite_max_num
			ld			hl, objects_info
		loop:
			; X���W 0�`240
			exx
			call		random
			exx
			and			a, 0xFE
			cp			a, 240
			jr			c, skip_adjust_x
			sub			a, 240
		skip_adjust_x:
			ld			[hl], a
			inc			hl
			; VX���W -6, -4, -2, 2, 4, 6
			exx
			call		random
			exx
			and			a, 7				; 0�`7
			sub			a, 3				; -3�`4
			jr			nz, skip_adjust_vx1
			dec			a
		skip_adjust_vx1:					; -3, -2, -1, 1, 2, 3, 4
			cp			a, 4
			jr			nz, skip_adjust_vx2
			dec			a
		skip_adjust_vx2:					; -3, -2, -1, 1, 2, 3
			add			a, a				; -6, -4, -2, 2, 4, 6
			ld			[hl], a
			inc			hl
			; Y���W 0�`144
			exx
			call		random
			exx
			cp			a, 144
			jr			c, skip_adjust_y
			sub			a, 144
		skip_adjust_y:
			ld			[hl], a
			inc			hl
			; VY���W -6, -4, -2, 2, 4, 6
			exx
			call		random
			exx
			and			a, 7				; 0�`7
			sub			a, 3				; -3�`4
			jr			nz, skip_adjust_vy1
			dec			a
		skip_adjust_vy1:					; -3, -2, -1, 1, 2, 3, 4
			cp			a, 4
			jr			nz, skip_adjust_vy2
			dec			a
		skip_adjust_vy2:					; -3, -2, -1, 1, 2, 3
			add			a, a				; -6, -4, -2, 2, 4, 6
			ld			[hl], a
			inc			hl
			djnz		loop
			ret
			endscope

; =============================================================================
initial_palette:
			grp_palette		  0, 111,  87			; #0
			grp_palette		  0,   0,   0			; #1
			grp_palette		 12, 222,  54			; #2
			grp_palette		128, 255, 144			; #3
			grp_palette		  0,   0, 255			; #4
			grp_palette		  0, 165, 255			; #5
			grp_palette		120,   0,   0			; #6
			grp_palette		  0, 225, 255			; #7
			grp_palette		204,   0,   0			; #8
			grp_palette		255, 105,   0			; #9
			grp_palette		144, 108,   0			; #10
			grp_palette		201, 174,   0			; #11
			grp_palette		  0, 141,   0			; #12
			grp_palette		255, 255, 162			; #13
			grp_palette		  0, 255, 255			; #14
			grp_palette		255, 255, 255			; #15

			include		"graphics_driver.asm"
			include		"image1.asm"
			include		"random.asm"
			include		"graphics_driver_work.asm"

; =============================================================================
object_work				:= grp_work_end
random_seed				:= object_work				; 4byte
display_objects			:= random_seed + 4			; 1byte : �\������X�v���C�g�̐�
current_object			:= display_objects + 1
objects_info			:= current_object + 1		; 4 * grp_sprite_max_num bytes: �X�v���C�g�̕\�����
object_x				:= 0
object_vx				:= 1
object_y				:= 2
object_vy				:= 3
