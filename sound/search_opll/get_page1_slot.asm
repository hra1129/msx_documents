; ==============================================================================
;	Get Page1 Slot
;
;  Copyright (C) 2023 Takayuki Hara (HRA!)
;  All rights reserved.
;                                              https://github.com/hra1129/
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
;		A ..... Page1 Slot# (ENASLT形式)
;	break)
;		A, B, C, D, F, H, L
;	description)
;		現在の Page1 のスロット番号を返す。
;		このルーチンの内部で、割り込み禁止・許可を行うので要注意。
;		割り込み禁止で呼び出しても、このルーチンの中で許可されてしまいます。
; ------------------------------------------------------------------------------
			scope		get_page1_slot
get_page1_slot::
			; Get current primary slot#
			in			a,[ 0xA8 ]
			ld			b, a					; Bレジスタに primary slot# を保存しておく
			; page1 primary slot#
			and			a, 0b00_00_11_00
			rrca
			rrca
			; page1 の slot は拡張されているか？
			ld			c, a
			ld			hl, EXPTBL
			add			a, l					; 0xC1～0xC4 のいずれかになり、桁あふれは起こらない
			ld			l, a
			ld			a, [hl]
			and			a, 0x80
			or			a, c
			ret			p						; 拡張されていなければ 0x00～0x03 でこのまま戻る
			; 拡張されている場合、Page3 をそのスロットに切り替える
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
			; 拡張スロットレジスタを読み取る
			ld			a, [ 0xFFFF ]
			cpl									; 拡張スロットレジスタは反転してるので戻す
			ld			d, a
			; Page3 のスロットを戻す
			ld			a, b
			out			[ 0xA8 ], a
			ei
			; 読み取った拡張スロットレジスタの Page1 部分を抽出
			ld			a, d
			and			a, 0b00_00_11_00
			; 基本スロットの値と合わせてスロット値に仕上げる
			or			a, c
			ret
			endscope
