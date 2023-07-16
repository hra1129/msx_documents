; ==============================================================================
;	search_pac
;
;  Copyright (C) 2023 Takayuki Hara (HRA!)
;  All rights reserved.
;                                              https://github.com/hra1129/
;
;  �{�\�t�g�E�F�A����і{�\�t�g�E�F�A�Ɋ�Â��č쐬���ꂽ�h�����́A�ȉ��̏�����
;  �������ꍇ�Ɍ���A�ĔЕz����юg�p��������܂��B
;
;  1.�\�[�X�R�[�h�`���ōĔЕz����ꍇ�A��L�̒��쌠�\���A�{�����ꗗ�A����щ��L
;    �Ɛӏ��������̂܂܂̌`�ŕێ����邱�ƁB
;  2.�o�C�i���`���ōĔЕz����ꍇ�A�Еz���ɕt���̃h�L�������g���̎����ɁA��L��
;    ���쌠�\���A�{�����ꗗ�A����щ��L�Ɛӏ������܂߂邱�ƁB
;  3.���ʂɂ�鎖�O�̋��Ȃ��ɁA�{�\�t�g�E�F�A��̔��A����я��ƓI�Ȑ��i�⊈��
;    �Ɏg�p���Ȃ����ƁB
;
;  �{�\�t�g�E�F�A�́A���쌠�҂ɂ���āu����̂܂܁v�񋟂���Ă��܂��B���쌠�҂́A
;  ����ړI�ւ̓K�����̕ۏ؁A���i���̕ۏ؁A�܂�����Ɍ��肳��Ȃ��A�����Ȃ閾��
;  �I�������͈ÖقȕۏؐӔC�������܂���B���쌠�҂́A���R�̂�������킸�A���Q
;  �����̌�����������킸�A���ӔC�̍������_��ł��邩���i�ӔC�ł��邩�i�ߎ�
;  ���̑��́j�s�@�s�ׂł��邩���킸�A���ɂ��̂悤�ȑ��Q����������\����m��
;  ����Ă����Ƃ��Ă��A�{�\�t�g�E�F�A�̎g�p�ɂ���Ĕ��������i��֕i�܂��͑�p�T
;  �[�r�X�̒��B�A�g�p�̑r���A�f�[�^�̑r���A���v�̑r���A�Ɩ��̒��f���܂߁A�܂���
;  ��Ɍ��肳��Ȃ��j���ڑ��Q�A�Ԑڑ��Q�A�����I�ȑ��Q�A���ʑ��Q�A�����I���Q�A��
;  ���͌��ʑ��Q�ɂ��āA��ؐӔC�𕉂�Ȃ����̂Ƃ��܂��B
;
;  Note that above Japanese version license is the formal document.
;  The following translation is only for reference.
;
;  Redistribution and use of this software or any derivative works,
;  are permitted provided that the following conditions are met:
;
;  1. Redistributions of source code must retain the above copyright
;     notice, this list of conditions and the following disclaimer.
;  2. Redistributions in binary form must reproduce the above
;     copyright notice, this list of conditions and the following
;     disclaimer in the documentation and/or other materials
;     provided with the distribution.
;  3. Redistributions may not be sold, nor may they be used in a
;     commercial product or activity without specific prior written
;     permission.
;
;  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
;  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
;  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
;  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
;  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
;  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
;  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;  POSSIBILITY OF SUCH DAMAGE.
; ==============================================================================

PAC_IO_SW1				:= 0x5FFE
PAC_IO_SW2				:= 0x5FFF
SCH_PAC_WORK			:= 0xF41F						; BIOS�� KBUF�B���[�N�G���A�Ƃ��Ďg��

SCH_PAC_PAGE1_SLOT		:= SCH_PAC_WORK					; 1byte : page1 slot# �̕ۑ��ꏊ
SCH_PAC_SLOT			:= SCH_PAC_PAGE1_SLOT + 1		; 1byte : ���o���� PAC �̃X���b�g
SCH_PAC_CHECK_PAC		:= SCH_PAC_SLOT + 1

; ------------------------------------------------------------------------------
;	search_pac
;	input)
;		none
;	output)
;		A ..... PAC Slot#
;	break)
;		all
;	description)
;		PAC �̑��݂𒲂ׂāA���̃X���b�g�ԍ���Ԃ��B
;		������Ȃ������ꍇ�́AA �ɂ� FFh ���Ԃ�B
; ------------------------------------------------------------------------------
			scope		search_pac
search_pac::
			; page1 slot# �����߂� SCH_OPLL_PAGE1_SLOT �Ɋi�[
			call		get_page1_slot
			ld			[ SCH_PAC_PAGE1_SLOT ], a

			; �w��̃X���b�g��PAC�ł��邩���ׂ郋�[�`���� Page3�փR�s�[����
			ld			hl, check_pac_start
			ld			de, SCH_PAC_CHECK_PAC
			ld			bc, check_pac_size
			ldir

			; PAC �͂܂��������Ă��Ȃ�
			ld			a, 0xFF
			ld			[ SCH_PAC_SLOT ], a
			inc			a
			jr			enter_primary_slot_loop
	primary_slot_loop:
			inc			a
			and			a, 0b000000_11
			jr			z, not_found_pac				; �ꏄ���Ă��܂����ꍇ�A������Ȃ���������ցB
	enter_primary_slot_loop:
			; �g���X���b�g�t���O
			ld			b, a
			ld			h, EXPTBL >> 8
			add			a, EXPTBL & 255
			ld			l, a
			ld			a, [hl]
			and			a, 0x80
			or			a, b
	expansion_slot_loop:
			push		af
			; ���ݒ��ڂ��Ă���X���b�g�� PAC ���ǂ������ׂ�
			call		check_pac
			cp			a, 0xFF
			jr			z, no_match
			pop			hl								; �X�^�b�N�̂�
			ei
			ret
	no_match:
			pop			af
			; PAC �ł͂Ȃ������̂ŁA���̃X���b�g
			or			a, a							; �g�����ꂽ�X���b�g���H
			jp			p, primary_slot_loop			; �g�����ꂽ�X���b�g�łȂ��̂ŁA���̊�{�X���b�g�ցB
			add			a, 0x04							; ���̊g���X���b�g
			bit			4, a							; �g���X���b�g���S�����I������H
			jr			z, expansion_slot_loop			; �܂��c���Ă�ꍇ�́Aexpansion_slot_loop �ցB
			jr			primary_slot_loop				; ���̊�{�X���b�g�ցB
	not_found_pac:
			; �S�X���b�g���ׂ�
			ei
			ld			a, [SCH_PAC_SLOT]
			ret
			endscope

; ------------------------------------------------------------------------------
;	open_pac
;	input)
;		A ..... PAC�̃X���b�g (�����ꂪ PAC �ł��邩�̃`�F�b�N�͍s���܂���)
;	output)
;		none
;	break)
;		all
;	description)
;		page1 �� PAC �̃X���b�g�֐؂�ւ��āASRAM���o�������܂��B
;		���̃��[�`���̒��Ŋ��荞�݋֎~�ɂ��āA���̂܂ܖ߂�܂��B
;		page1 �� PAC �̃X���b�g�֐؂�ւ��Ė߂�̂ŁApage1 ����Ăяo����
;		�\������̂ł����Ӊ������B
;		���̃��[�`�����̂� page1 �ɑ��݂��Ă��Ă���肠��܂���B
;		A �� PAC �ȊO�̃X���b�g���w�肵���ꍇ�̓���͕ۏ؂��܂���B
;		SRAM�ւ̃A�N�Z�X��������ɁApage1 �����̃X���b�g�֖߂��̂́A
;		disable_pac �Ŗ߂��ĉ������B
;		H.TIMI ���� OPLDRV ���ĂԂ悤�ɂ��Ă��āAFMPAC �̃X���b�g�� A �Ɏw��
;		���ČĂяo���Ă���ꍇ�Adisable_pac ������ ENASLT �� page1 ��߂���
;		FMPAC �̃X���b�g�� OPLDRV �������Ȃ��Ȃ��Ă���iSRAM�ɂȂ��Ă���)���
;		�ɂȂ�A�\������̂ł����Ӊ������B
; ------------------------------------------------------------------------------
			scope		open_pac
open_pac::
			; �w��̃X���b�g��PAC�ł��邩���ׂ郋�[�`���� Page3�փR�s�[����
			ld			hl, open_pac_sub_start
			ld			de, SCH_PAC_CHECK_PAC
			ld			bc, open_pac_sub_size
			ldir
			jp			open_pac_sub

open_pac_sub_start:
			org			SCH_PAC_CHECK_PAC
open_pac_sub:
			; page1 ���w��̃X���b�g�֐؂�ւ���
			ld			h, 0x40
			call		ENASLT
			; SRAM�o���N�ɐ؂�ւ���
			ld			hl, 0x694D				; SRAM�o���NID
			ld			[PAC_IO_SW1], hl
			ret
open_pac_sub_end:
open_pac_sub_size		= open_pac_sub_end - open_pac_sub
			org			open_pac_sub_start + open_pac_sub_size
			endscope

; ------------------------------------------------------------------------------
;	close_pac
;	input)
;		A ..... page1 �ɏo��������X���b�g
;	output)
;		none
;	break)
;		all
;	description)
;		open_pac ������ɁApage1 �����ɖ߂��ꍇ�� close_pac ���g���܂��B
;		SRAM���B���Ă���X���b�g��؂�ւ���̂ŁAFMPAC �� FM-BIOS ���������܂��B
;		open_pac �����ꍇ�́A�K�����̃��[�`���� page1 ��߂��ĉ������B
; ------------------------------------------------------------------------------
			scope		close_pac
close_pac::
			; �w��̃X���b�g��PAC�ł��邩���ׂ郋�[�`���� Page3�փR�s�[����
			ld			hl, close_pac_sub_start
			ld			de, SCH_PAC_CHECK_PAC
			ld			bc, close_pac_sub_size
			ldir
			jp			close_pac_sub

close_pac_sub_start:
			org			SCH_PAC_CHECK_PAC
close_pac_sub:
			; SRAM���B��
			ld			[PAC_IO_SW1], bc
			; page1 ���w��̃X���b�g�֐؂�ւ���
			ld			h, 0x40
			call		ENASLT
			ret
close_pac_sub_end:
close_pac_sub_size		= close_pac_sub_end - close_pac_sub
			org			close_pac_sub_start + close_pac_sub_size
			endscope

; ------------------------------------------------------------------------------
;	check_pac
;	input)
;		A ..... �Ώۂ̃X���b�g
;	output)
;		A ..... PAC�������ꍇ�A�Ώۂ̃X���b�g�BPAC�łȂ������ꍇ�A0xFF ���Ԃ�B
;	break)
;		all
;	description)
;		���̃��[�`���̒��Ŋ��荞�݋֎~�ɂ��āA���̂܂ܖ߂�܂��B
; ------------------------------------------------------------------------------
check_pac_start::
			org			SCH_PAC_CHECK_PAC
			scope		check_pac
check_pac::
			push		af
			ld			b, a
			ld			a, 0xFF
			ld			[SCH_PAC_SLOT], a
			ld			a, b
			; �Ώۂ̃X���b�g�֐؂�ւ���
			ld			h, 0x40
			call		ENASLT
			; �Ώۂ̃X���b�g�������ւ��s�\�ł��邱�Ƃ��m�F����
			ld			hl, 0x4000
			call		check_ram
			jr			z, no_match				; RAM �Ȃ� PAC �ł͂Ȃ�
			ld			hl, 0x4800
			call		check_ram
			jr			z, no_match				; RAM �Ȃ� PAC �ł͂Ȃ�
			; SRAM�o���N�ɐ؂�ւ���
			ld			hl, 0x694D				; SRAM�o���NID
			ld			[PAC_IO_SW1], hl
			; �Ώۂ̃X���b�g�������ւ��\�ł��邱�Ƃ��m�F����
			ld			hl, 0x4000
			call		check_ram
			jr			nz, no_match			; RAM �łȂ��Ȃ� PAC �ł͂Ȃ�
			ld			hl, 0x4800
			call		check_ram
			jr			nz, no_match			; RAM �łȂ��Ȃ� PAC �ł͂Ȃ�
			; �X���b�g�ԍ����L�^����
			pop			af
			ld			[SCH_PAC_SLOT], a
			; SRAM���B��
			xor			a, a
			ld			[PAC_IO_SW1], a
	_exit:
			; ���̃X���b�g�֖߂�
			ld			a, [SCH_PAC_PAGE1_SLOT]
			ld			h, 0x40
			call		ENASLT
			ld			a, [SCH_PAC_SLOT]
			ret
	no_match:
			pop			af
			jr			_exit
			; RAM���ǂ����`�F�b�N����
	check_ram:
			ld			a, [hl]
			cpl
			ld			[hl], a		; ���]�������̂������ɏ����Ă݂�
			cp			a, [hl]		; �l����v���Ă���΁ARAM�̉\������
			cpl
			ld			[hl], a		; ���̒l�ɖ߂�
			ret
check_pac_end::
			endscope
check_pac_size		:= check_pac_end - check_pac
			org			check_pac_start + check_pac_size
