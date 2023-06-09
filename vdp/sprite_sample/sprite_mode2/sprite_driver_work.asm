; -----------------------------------------------------------------------------
;  Sprite Driver work area for Sprite Mode2
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
;  2023/June/6th	t.hara
; -----------------------------------------------------------------------------

; ���L�����[�N�G���A�ŁA���e�� spdrv_initialize �ŏ����������B
; ROM�J�[�g���b�W�ɓ��ڂ���ꍇ�ȂǂŁA�R�[�h��Ƀ��[�N�G���A��u���Ȃ��ꍇ�́A
; ���L�̃��x���ɂ��āA���L�̃T�C�Y���m�ۏo���� RAM��̃A�h���X���w�肷���
; ���삷��B
; The following is the work area, the contents of which are initialized by 
; spdrv_initialize.
; If the work area cannot be placed on the code, for example, when installing 
; in a ROM cartridge, it works by specifying an address in RAM that can secure 
; the following size for the following labels.
;
; labels:
;   sprite_page ........ 1byte
;   sprite_index ....... 1byte
;   sprite_color_work .. 32bytes
;   sprite_attribute ... 256bytes
;
sprite_page::
				db			0
sprite_index::
				db			0
sprite_index_debug::
				db			0
sprite_color_work::
				db			0, 0, 0, 0, 0, 0, 0, 0
				db			0, 0, 0, 0, 0, 0, 0, 0
				db			0, 0, 0, 0, 0, 0, 0, 0
				db			0, 0, 0, 0, 0, 0, 0, 0
sprite_attribute::
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #0
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #1
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #2
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #3
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #4
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #5
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #6
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #7
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #8
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #9
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #10
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #11
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #12
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #13
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #14
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #15
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #16
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #17
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #18
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #19
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #20
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #21
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #22
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #23
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #24
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #25
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #26
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #27
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #28
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #29
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #30
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #31
