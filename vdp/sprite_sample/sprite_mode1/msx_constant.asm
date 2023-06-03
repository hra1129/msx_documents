; -----------------------------------------------------------------------------
;  Constant definitions for MSX
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

vdp_port0		:= 0x98
vdp_port1		:= 0x99
vdp_port2		:= 0x9A
vdp_port3		:= 0x9B

wrtvdp			:= 0x0047
filvrm			:= 0x0056
ldirmv			:= 0x0059
ldirvm			:= 0x005C
chgmod			:= 0x005F

rg0sav			:= 0xF3DF
rg1sav			:= 0xF3E0
rg2sav			:= 0xF3E1
rg3sav			:= 0xF3E2
rg4sav			:= 0xF3E3
rg5sav			:= 0xF3E4
rg6sav			:= 0xF3E5
rg7sav			:= 0xF3E6

jiffy			:= 0xFC9E
