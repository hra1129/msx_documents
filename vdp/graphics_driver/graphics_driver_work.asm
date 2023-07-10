; =============================================================================
;	Work area for Graphics Driver
; -----------------------------------------------------------------------------
;	2023/July/2rd	t.hara (HRA!)
; =============================================================================

; -----------------------------------------------------------------------------
;	Customize parameters
; -----------------------------------------------------------------------------
grp_work					:= 0xC000									; ���̃h���C�o�[�̃��[�N�G���A�擪�A�h���X
grp_sprite_max_num			:= 60										; �^���X�v���C�g�̍ő�\����N, MAX255

; -----------------------------------------------------------------------------
draw_page					:= grp_work + 0								; 1byte   : �`��y�[�W
sprite_fifo_ptr				:= draw_page + 1							; 2bytes  : ���ꂩ��\������^���X�v���C�g�̑҂��s��̃|�C���^
sprite_fifo_draw_ptr		:= sprite_fifo_ptr + 2						; 2bytes  : ���ɕ`�悷��^���X�v���C�g�̑҂��s��̃|�C���^
sprite_fifo_count			:= sprite_fifo_draw_ptr + 2					; 1byte   : sprite_fifo �ɐς񂾐�

sprite_fifo					:= sprite_fifo_count + 1					; 4N bytes: �^���X�v���C�g�̑҂��s��
sprite_fifo_end				:= sprite_fifo + grp_sprite_max_num * 4

erase_fifo_ptr				:= sprite_fifo_end							; 2bytes  : �^���X�v���C�g�����p�̑҂��s��̃|�C���^(2�t���[���O)
erase_fifo_next_count		:= erase_fifo_ptr + 2						; 1byte   : �^���X�v���C�g�����p�̑҂��s��(1�t���[���O)�ɐς܂�Ă��鐔
erase_fifo_current_count	:= erase_fifo_next_count + 1				; 1byte   : �^���X�v���C�g�����p�̑҂��s��(2�t���[���O)�ɐς܂�Ă��鐔

erase_fifo_page0			:= erase_fifo_current_count + 1				; 2N bytes: �^���X�v���C�g�����p�̑҂��s��
erase_fifo_page0_end		:= erase_fifo_page0 + grp_sprite_max_num * 2

erase_fifo_page1			:= erase_fifo_page0_end						; 2N bytes: �^���X�v���C�g�����p�̑҂��s��
erase_fifo_page1_end		:= erase_fifo_page1 + grp_sprite_max_num * 2

grp_work_end				:= erase_fifo_page1_end
