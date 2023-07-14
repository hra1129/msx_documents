; ==============================================================================
;	Search OPLL
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
; ------------------------------------------------------------------------------
;	Date		Author	Ver		Description
;	2023/7/14	t.hara	1.0		1st release
; ==============================================================================

; require include "msx.asm"
; require include "get_page1_slot.asm"

EXTOPLL_IO_SW			:= 0x7FF6
OPLL_SIGNATURE			:= 0x4018
SIGNATURE_WORK			:= 0xF41F						; BIOS�� KBUF�B���[�N�G���A�Ƃ��Ďg��

SCH_OPLL_PAGE1_SLOT		:= SIGNATURE_WORK				; 1byte : page1 slot# �̕ۑ��ꏊ
SCH_OPLL_SLOT			:= SCH_OPLL_PAGE1_SLOT + 1		; 1byte : ������ OPLL�X���b�g
SCH_OPLL_SIGNATURE		:= SCH_OPLL_SLOT + 1			; 8bytes: 4018h�` �� 8byte �̈ꎞ�ۊǏꏊ
SCH_OPLL_COPY_SIGNATURE	:= SCH_OPLL_SIGNATURE + 8		; Xbytes: �w��̃X���b�g�� 4018h �� SCH_OPLL_SIGNATURE�փR�s�[���郋�[�`���u����

; ------------------------------------------------------------------------------
;	search_opll
;	input)
;		none
;	output)
;		A ..... OPLL Slot#
;	break)
;		all
;	description)
;		MSX-MUSIC �̑��݂𒲂ׂāA���̃X���b�g�ԍ���Ԃ��B
;		������Ȃ������ꍇ�́AA �ɂ� 00h ���Ԃ�B
; ------------------------------------------------------------------------------
			scope		search_opll
search_opll::
			; page1 slot# �����߂� SCH_OPLL_PAGE1_SLOT �Ɋi�[
			call		get_page1_slot
			ld			[ SCH_OPLL_PAGE1_SLOT ], a

			; �w��̃X���b�g�̎w��̃A�h���X���� 8byte �ǂݎ�郋�[�`���� Page3�փR�s�[����
			ld			hl, copy_signature_source_start
			ld			de, SCH_OPLL_COPY_SIGNATURE
			ld			bc, copy_signature_size
			ldir

			; OPLL �͂܂��������Ă��Ȃ�
			ld			a, 0xFF
			ld			[ SCH_OPLL_SLOT ], a
			inc			a
			jr			enter_primary_slot_loop
	primary_slot_loop:
			inc			a
			and			a, 0b000000_11
			jr			z, not_found_aprlopll			; APRLOPLL ��������Ȃ������ꍇ�ꏄ����BXXXXOPLL ���������������ׂ�B
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
			; ���ݒ��ڂ��Ă���X���b�g�� Signature ��ǂݎ��
			call		copy_signature
			; �㔼4byte �� "OPLL" �����ׂ�
			ld			hl, s_opll
			ld			de, SCH_OPLL_SIGNATURE + 4
			ld			b, 4
	compare_opll_loop:
			ld			a, [de]
			inc			de
			cp			a, [hl]
			inc			hl
			jr			nz, no_match
			djnz		compare_opll_loop
			; OPLL �����������̂ŃX���b�g�ԍ��ۑ�
			pop			af
			push		af
			ld			[SCH_OPLL_SLOT], a
			; �O��4byte �� "APRL" �����ׂ�
			ld			hl, s_aprl
			ld			de, SCH_OPLL_SIGNATURE + 0
			ld			b, 4
	compare_aprl_loop:
			ld			a, [de]
			inc			de
			cp			a, [hl]
			inc			hl
			jr			nz, no_match
			djnz		compare_aprl_loop
			; APRLOPLL �����������̂ŁA�߂�
			pop			af
			ei
			ret
	no_match:
			pop			af
			; APRLOPLL ��������Ȃ������̂ŁA���̃X���b�g
			or			a, a							; �g�����ꂽ�X���b�g���H
			jp			p, primary_slot_loop			; �g�����ꂽ�X���b�g�łȂ��̂ŁA���̊�{�X���b�g�ցB
			add			a, 0x04							; ���̊g���X���b�g
			bit			4, a							; �g���X���b�g���S�����I������H
			jr			z, expansion_slot_loop			; �܂��c���Ă�ꍇ�́Aexpansion_slot_loop �ցB
			jr			primary_slot_loop				; ���̊�{�X���b�g�ցB
	not_found_aprlopll:
			; �S�X���b�g���ׂ��� APRLOPLL ��������Ȃ�����
			ei
			ld			a, [SCH_OPLL_SLOT]
			inc			a
			ret			z								; XXXXOPLL ��������Ȃ�����
			dec			a
			; �������X���b�g�� EXTOPLL_IO_SW �� bit0 �� 1 �ɂ���
			ld			hl, EXTOPLL_IO_SW
			call		RDSLT
			or			a, 1
			ld			e, a
			ld			a, [SCH_OPLL_SLOT]
			ld			hl, EXTOPLL_IO_SW
			call		WRSLT
			ld			a, [SCH_OPLL_SLOT]
			ei
			ret
	s_aprl:
			ds			"APRL"
	s_opll:
			ds			"OPLL"
			endscope

; ------------------------------------------------------------------------------
;	copy_signature
;	input)
;		A ..... �Ώۂ̃X���b�g
;	output)
;		SCH_OPLL_SIGNATURE ... 8byte �ɑΏۂ̃X���b�g�� 4018h�` �� 8byte
;	break)
;		all
;	description)
;		���̃��[�`���̒��Ŋ��荞�݋֎~�ɂ��āA���̂܂ܖ߂�܂��B
; ------------------------------------------------------------------------------
copy_signature_source_start::
			org			SCH_OPLL_COPY_SIGNATURE
			scope		copy_signature
copy_signature::
			; �Ώۂ̃X���b�g�֐؂�ւ���
			ld			h, 0x40
			call		ENASLT
			; 8byte�R�s�[����
			ld			hl, OPLL_SIGNATURE
			ld			de, SCH_OPLL_SIGNATURE
			ld			bc, 8
			ldir
			; ���̃X���b�g�֖߂�
			ld			a, [SCH_OPLL_PAGE1_SLOT]
			ld			h, 0x40
			call		ENASLT
			ret
copy_signature_end::
			endscope
copy_signature_size		:= copy_signature_end - copy_signature
			org			copy_signature_source_start + copy_signature_size
