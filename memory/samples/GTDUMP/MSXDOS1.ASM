; ==============================================================================
;	MSX-DOS Function
;
;  Copyright (C) 2020 Takayuki Hara (HRA!)
;  All rights reserved.
;                           http://hraroom.s602.xrea.com/msx/software/mgsp.html
;
;  本ソフトウェアおよび本ソフトウェアに基づいて作成された派生物は、以下の条件を
;  満たす場合に限り、再頒布および使用が許可されます。
;
;  1.ソースコード形式で再頒布する場合、上記の著作権表示、本条件一覧、および下記
;    免責条項をそのままの形で保持すること。
;  2.バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の
;    著作権表示、本条件一覧、および下記免責条項を含めること。
;  3.書面による事前の許可なしに、本ソフトウェアを販売、および商業的な製品や活動
;    に使用しないこと。
;
;  本ソフトウェアは、著作権者によって「現状のまま」提供されています。著作権者は、
;  特定目的への適合性の保証、商品性の保証、またそれに限定されない、いかなる明示
;  的もしくは暗黙な保証責任も負いません。著作権者は、事由のいかんを問わず、損害
;  発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失
;  その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知ら
;  されていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サ
;  ービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそ
;  れに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、ま
;  たは結果損害について、一切責任を負わないものとします。
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
;		A = 入力された文字
;		L = Aと同じ
;	comment)
;		標準出力にエコーされる
; ==============================================================================
D1F_CONIN			:= 0x01

; ==============================================================================
;	Console output
;	input)
;		C = D1F_CONOUT
;		E = 出力する文字
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
