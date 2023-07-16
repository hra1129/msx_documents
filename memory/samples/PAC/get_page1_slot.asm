; ==============================================================================
;	Get Page1 Slot
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

; ------------------------------------------------------------------------------
;	get_page1_slot
;	input)
;		none
;	output)
;		A ..... Page1 Slot# (ENASLT�`��)
;	break)
;		A, B, C, D, F, H, L
;	description)
;		���݂� Page1 �̃X���b�g�ԍ���Ԃ��B
;		���̃��[�`���̓����ŁA���荞�݋֎~�E�����s���̂ŗv���ӁB
;		���荞�݋֎~�ŌĂяo���Ă��A���̃��[�`���̒��ŋ�����Ă��܂��܂��B
; ------------------------------------------------------------------------------
			scope		get_page1_slot
get_page1_slot::
			; Get current primary slot#
			in			a,[ 0xA8 ]
			ld			b, a					; B���W�X�^�� primary slot# ��ۑ����Ă���
			; page1 primary slot#
			and			a, 0b00_00_11_00
			rrca
			rrca
			; page1 �� slot �͊g������Ă��邩�H
			ld			c, a
			ld			hl, EXPTBL
			add			a, l					; 0xC1�`0xC4 �̂����ꂩ�ɂȂ�A�����ӂ�͋N����Ȃ�
			ld			l, a
			ld			a, [hl]
			and			a, 0x80
			or			a, c
			ret			p						; �g������Ă��Ȃ���� 0x00�`0x03 �ł��̂܂ܖ߂�
			; �g������Ă���ꍇ�APage3 �����̃X���b�g�ɐ؂�ւ���
			ld			c, a
			ld			a, b
			and			a, 0b00_11_11_11
			ld			d, a
			ld			a, c
			rrca
			rrca
			and			a, 0b11_00_00_00
			or			a, d
			di
			out			[ 0xA8 ], a
			; �g���X���b�g���W�X�^��ǂݎ��
			ld			a, [ 0xFFFF ]
			cpl									; �g���X���b�g���W�X�^�͔��]���Ă�̂Ŗ߂�
			ld			d, a
			; Page3 �̃X���b�g��߂�
			ld			a, b
			out			[ 0xA8 ], a
			ei
			; �ǂݎ�����g���X���b�g���W�X�^�� Page1 �����𒊏o
			ld			a, d
			and			a, 0b00_00_11_00
			; ��{�X���b�g�̒l�ƍ��킹�ăX���b�g�l�Ɏd�グ��
			or			a, c
			ret
			endscope
