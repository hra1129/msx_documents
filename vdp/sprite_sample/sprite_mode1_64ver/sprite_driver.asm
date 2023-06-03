; -----------------------------------------------------------------------------
;  Sprite Driver for Sprite Mode1
; =============================================================================
;  Copyright (c) 2023 t.hara
;  
;  Permission is hereby granted, free of charge, to any person obtaining a copy
;  of this software and associated documentation files (the "Software"), to deal
;  in the Software without restriction, including without limitation the rights
;  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;  copies of the Software, and to permit persons to whom the Software is
;  furnished to do so, subject to the following conditions:
;  
;  The above copyright notice and this permission notice shall be included in all
;  copies or substantial portions of the Software.
;  
;  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;  SOFTWARE.
; -----------------------------------------------------------------------------
;  Copyright (c) 2023 t.hara
;  
;  �ȉ��ɒ�߂�����ɏ]���A�{�\�t�g�E�F�A����ъ֘A�����̃t�@�C���i�ȉ��u�\�t�g
;  �E�F�A�v�j�̕������擾���邷�ׂĂ̐l�ɑ΂��A�\�t�g�E�F�A�𖳐����Ɉ������Ƃ�
;  �����ŋ����܂��B
;  ����ɂ́A�\�t�g�E�F�A�̕������g�p�A���ʁA�ύX�A�����A�f�ځA�Еz�A�T�u���C�Z
;  ���X�A�����/�܂��͔̔����錠���A����у\�t�g�E�F�A��񋟂��鑊��ɓ������Ƃ�
;  �����錠�����������Ɋ܂܂�܂��B
;  
;  ��L�̒��쌠�\������і{�����\�����A�\�t�g�E�F�A�̂��ׂĂ̕����܂��͏d�v�ȕ�
;  ���ɋL�ڂ�����̂Ƃ��܂��B
;  
;  �\�t�g�E�F�A�́u����̂܂܁v�ŁA�����ł��邩�Öقł��邩���킸�A����̕ۏ�
;  ���Ȃ��񋟂���܂��B�����ł����ۏ؂Ƃ́A���i���A����̖ړI�ւ̓K�����A�����
;  ������N�Q�ɂ��Ă̕ۏ؂��܂݂܂����A����Ɍ��肳�����̂ł͂���܂���B
;  ��҂܂��͒��쌠�҂́A�_��s�ׁA�s�@�s�ׁA�܂��͂���ȊO�ł��낤�ƁA�\�t�g
;  �E�F�A�ɋN���܂��͊֘A���A���邢�̓\�t�g�E�F�A�̎g�p�܂��͂��̑��̈����ɂ��
;  �Đ������؂̐����A���Q�A���̑��̋`���ɂ��ĉ���̐ӔC������Ȃ����̂Ƃ���
;  ���B
; =============================================================================
;  History
;  2023/June/3rd	t.hara
; -----------------------------------------------------------------------------

vram_sprite_attribute1	:= 0x1B00				; lower 8bit must be set 00.
vram_sprite_attribute2	:= vram_sprite_attribute1 + 128

; -----------------------------------------------------------------------------
;	spdrv_initialize
;	input)
;		none
;	output)
;		none
;	break)
;		all
;	comment)
;		Initialize this sprite driver.
;		�{�X�v���C�g�h���C�o�����������܂��B
; -----------------------------------------------------------------------------
				scope		spdrv_initialize
spdrv_initialize::
				; clear sprite attribute on CPU RAM
				ld			hl, sprite_attribute
				ld			de, sprite_attribute + 1
				ld			bc, (4 * 64) - 1
				ld			[hl], 208
				ldir
				; clear sprite attribute 1 and 2 on VRAM
				ld			a, 208
				ld			hl, vram_sprite_attribute1
				ld			bc, (4 * 32) * 2
				call		filvrm
				; initialize work area
				xor			a, a
				ld			[sprite_index], a
				ld			a, vram_sprite_attribute1 >> 7
				ld			[sprite_page], a
;				jp			spdrv_flip
				endscope

; -----------------------------------------------------------------------------
;	spdrv_flip
;	input)
;		none
;	output)
;		none
;	break)
;		all
;	comment)
;		Of the two sprite attribute tables prepared on VRAM, swap the attribute 
;		table that is actually displayed.
;		VRAM���2�p�ӂ��Ă���X�v���C�g�A�g���r���[�g�e�[�u���̂����A���ۂ�
;		�\�������A�g���r���[�g�e�[�u�������ւ���B
; -----------------------------------------------------------------------------
				scope		spdrv_flip
spdrv_flip::
				; update display page
				ld			a, [sprite_page]			; 0x1B00(0x36) or 0x1B80(0x37)
				ld			b, a
				di
				out			[vdp_port1], a
				ld			a, 0x80 | 5
				out			[vdp_port1], a
				ei

				; update write page
				ld			a, b
				xor			a, 1						; 0x36 --> 0x37, 0x37 --> 0x36
				ld			[sprite_page], a
				ret
				endscope

; -----------------------------------------------------------------------------
;	spdrv_update
;	input)
;		none
;	output)
;		none
;	break)
;		all
;	comment)
;		The sprite attribute table existing in CPU RAM is rearranged for the 
;		blinking process and written to the sprite attribute table in VRAM.
;		CPU RAM��ɑ��݂���X�v���C�g�A�g���r���[�g�e�[�u�����A�_�ŏ����p�ɕ���
;		�ւ��āAVRAM�̃X�v���C�g�A�g���r���[�g�e�[�u���֏����o���B
; -----------------------------------------------------------------------------
				scope		spdrv_update
spdrv_update::
				; set VRAM address (write page)
				ld			a, [sprite_page]
				and			a, 1
				rrca													; 0x00 or 0x80
				di
				out			[vdp_port1], a
				ld			a, 0x40 | (vram_sprite_attribute1 >> 8)
				out			[vdp_port1], a
				ei

				; reference sprite_attribute on CPU RAM
				ld			a, [sprite_index]
				ld			e, a
				ld			d, 0

				; B=64, C=32
				ld			bc, (64 << 8) | 32
		loop:
				; Get address of current sprite_attribute
				ld			hl, sprite_attribute
				add			hl, de

				; Is current sprite_attribute visible?
				ld			a, [hl]
				cp			a, 208
				jr			z, skip

				; Transfer current sprite_attribute to VRAM
				out			[vdp_port0], a
				inc			hl
				ld			a, [hl]
				out			[vdp_port0], a
				inc			hl
				ld			a, [hl]
				out			[vdp_port0], a
				inc			hl
				ld			a, [hl]
				out			[vdp_port0], a
				dec			c						; count visible sprite
				jr			z, exit
		skip:
				; Go to next.
				ld			a, e
				add			a, 7 * 4				; 7 is prime number.
				ld			e, a
				djnz		loop

				; Is visible sprite count over 32?
				ld			a, c
				or			a, a
				jr			c, exit

				; Hide remain sprites
				ld			a, 208
				out			[vdp_port0], a
		exit:
				; Calculate next index.
				ld			a, [sprite_index]
				add			a, 19 * 4				; 19 is prime number.
				ld			[sprite_index], a
				ret
				endscope
