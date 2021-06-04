; ==============================================================================
;	MSX-DOS Function
;
;  Copyright (C) 2020 Takayuki Hara (HRA!)
;  All rights reserved.
;                           http://hraroom.s602.xrea.com/msx/software/mgsp.html
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

BDOS				:= 0x0005
DMA					:= 0x0080
TPA_BOTTOM			:= 0x0006

; ==============================================================================
;	Terminate program
;	input)
;		C = D1F_TERM0
;	output)
;		--
; ==============================================================================
D1F_TERM0			:= 0x00

; ==============================================================================
;	Console input
;	input)
;		C = D1F_CONIN
;	output)
;		A = ���͂��ꂽ����
;		L = A�Ɠ���
;	comment)
;		�W���o�͂ɃG�R�[�����
; ==============================================================================
D1F_CONIN			:= 0x01

; ==============================================================================
;	Console output
;	input)
;		C = D1F_CONOUT
;		E = �o�͂��镶��
;	output)
;		--
; ==============================================================================
D1F_CONOUT			:= 0x02

D1F_AUXIN			:= 0x03
D1F_AUXOUT			:= 0x04
D1F_LSTOUT			:= 0x05
D1F_DIRIO			:= 0x06
D1F_DIRIN			:= 0x07
D1F_INNOE			:= 0x08
D1F_STROUT			:= 0x09
D1F_BUFIN			:= 0x0A
D1F_CONST			:= 0x0B
D1F_CPMVER			:= 0x0C
D1F_DSKRST			:= 0x0D
D1F_SELDSK			:= 0x0E
D1F_FOPEN			:= 0x0F
D1F_FCLOSE			:= 0x10
D1F_SFIRST			:= 0x11
D1F_SNEXT			:= 0x12
D1F_FDEL			:= 0x13
D1F_RDSEQ			:= 0x14
D1F_WRSEQ			:= 0x15
D1F_FMAKE			:= 0x16
D1F_FREN			:= 0x17
D1F_LOGIN			:= 0x18
D1F_CURDRV			:= 0x19
D1F_SETDTA			:= 0x1A
D1F_ALLOC			:= 0x1B

D1F_RDRND			:= 0x21
D1F_WRRND			:= 0x22
D1F_FSIZE			:= 0x23
D1F_SETRND			:= 0x24

D1F_WRBLK			:= 0x26
D1F_RDBLK			:= 0x27
D1F_WRZER			:= 0x28

D1F_GDATE			:= 0x2A
D1F_SDATE			:= 0x2B
D1F_GTIME			:= 0x2C
D1F_STIME			:= 0x2D
D1F_VERIFY			:= 0x2E
D1F_RDABS			:= 0x2F
D1F_WRABS			:= 0x30
D1F_DPARM			:= 0x31

; ==============================================================================
;	error code
; ==============================================================================
D1E_EOF				:= 0xC7