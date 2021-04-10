; ==============================================================================
;	String processing routine
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
; ------------------------------------------------------------------------------
;	Date		Author	Ver		Description
;	2020/9/20	t.hara	1.0		1st release
; ==============================================================================

; ==============================================================================
;	strcpy
;	input)
;		hl .... Source string (ASCIIZ)
;		de .... Destination area address
;	output)
;		--
;	break)
;		af, de, hl, de
;	comment)
;		文字列のコピー。
;		DE には十分な空き領域がある前提。
; ==============================================================================
		scope	strcpy
strcpy::
		ld		a, [hl]
		ld		[de], a
		inc		hl
		inc		de
		or		a, a
		jr		nz, strcpy
		ret
		endscope

; ==============================================================================
;	strcmp
;	input)
;		de .... Target string 1 (ASCIIZ)
;		hl .... Target string 2 (ASCIIZ)
;	output)
;		zf .... 0: not match, 1: match
;		sf .... 0: [DE] >= [HL], 1: [DE] < [HL]
;	break)
;		af, b, de, hl
;	comment)
;		文字列の比較
; ==============================================================================
		scope	strcmp
strcmp::
		ld		a, [de]
		ld		b, [hl]
		inc		hl
		inc		de
		cp		a, b
		ret		nz
		or		a, a
		jr		nz, strcmp
		ret
		endscope

; ==============================================================================
;	toupper
;	input)
;		a ..... Target character
;	output)
;		a ..... result of toupper(a)
;	break)
;		af
;	comment)
;		アルファベットの場合、大文字に変更する
; ==============================================================================
		scope	toupper
toupper::
		cp		a, 'a'
		ret		c
		cp		a, 'z' + 1
		ret		nc
		add		a, 'A' - 'a'
		ret
		endscope

; ==============================================================================
;	tolower
;	input)
;		a ..... Target character
;	output)
;		a ..... result of tolower(a)
;	break)
;		af
;	comment)
;		アルファベットの場合、小文字に変更する
; ==============================================================================
		scope	tolower
tolower::
		cp		a, 'A'
		ret		c
		cp		a, 'Z' + 1
		ret		nc
		add		a, 'a' - 'A'
		ret
		endscope

; ==============================================================================
;	strcmpi
;	input)
;		de .... Target string 1 (ASCIIZ)
;		hl .... Target string 2 (ASCIIZ)
;	output)
;		zf .... 0: not match, 1: match
;		sf .... 0: [DE] >= [HL], 1: [DE] < [HL]
;	break)
;		af, b, de, hl
;	comment)
;		大小文字を区別しない文字列比較
; ==============================================================================
		scope	strcmpi
strcmpi::
		ld		a, [hl]
		call	toupper
		ld		b, a
		ld		a, [de]
		call	toupper
		inc		hl
		inc		de
		cp		a, b
		ret		nz
		or		a, a
		jr		nz, strcmpi
		ret
		endscope

; ==============================================================================
;	tostring
;	input)
;		hl .... Target value (unsigned int)
;		de .... Result buffer address
;	output)
;		[de] ... String
;	break)
;		af, bc, de, hl
;	comment)
;		HLに格納されている 16bit の数値を文字列に変換して DEが指すバッファに
;		ASCIIZで格納する。
;		DEのバッファは 6byte 消費する。
;		入力時の de には左側に 0 が詰められる。
;		de は、先頭の 0 を読み飛ばした位置を指し示して戻る。
; ==============================================================================
		scope	tostring
tostring::
		xor		a, a
		ld		bc, 40000
		sbc		hl, bc
		jr		nc, skip40000
		add		hl, bc
		ccf
		jr		skip40000_1
skip40000:
		ld		a, 4
skip40000_1:
		ld		bc, 20000
		sbc		hl, bc
		jr		nc, skip20000
		add		hl, bc
		ccf
		jr		skip20000_1
skip20000:
		or		a, 2
skip20000_1:
		ld		bc, 10000
		sbc		hl, bc
		jr		nc, skip10000
		add		hl, bc
		ccf
		jr		skip10000_1
skip10000:
		inc		a
skip10000_1:
		add		a, '0'			;	Cy = 0
		ld		[de], a
		inc		de

		xor		a, a
		ld		bc, 8000
		sbc		hl, bc
		jr		nc, skip8000
		add		hl, bc
		ccf
		jr		skip8000_1
skip8000:
		or		a, 8
skip8000_1:
		ld		bc, 4000
		sbc		hl, bc
		jr		nc, skip4000
		add		hl, bc
		ccf
		jr		skip4000_1
skip4000:
		or		a, 4
skip4000_1:
		ld		bc, 2000
		sbc		hl, bc
		jr		nc, skip2000
		add		hl, bc
		ccf
		jr		skip2000_1
skip2000:
		or		a, 2
skip2000_1:
		ld		bc, 1000
		sbc		hl, bc
		jr		nc, skip1000
		add		hl, bc
		ccf
		jr		skip1000_1
skip1000:
		inc		a
skip1000_1:
		add		a, '0'			;	Cy = 0
		ld		[de], a
		inc		de

		xor		a, a
		ld		bc, 800
		sbc		hl, bc
		jr		nc, skip800
		add		hl, bc
		ccf
		jr		skip800_1
skip800:
		or		a, 8
skip800_1:
		ld		bc, 400
		sbc		hl, bc
		jr		nc, skip400
		add		hl, bc
		ccf
		jr		skip400_1
skip400:
		or		a, 4
skip400_1:
		ld		bc, 200
		sbc		hl, bc
		jr		nc, skip200
		add		hl, bc
		ccf
		jr		skip200_1
skip200:
		or		a, 2
skip200_1:
		ld		bc, 100
		sbc		hl, bc
		jr		nc, skip100
		add		hl, bc
		ccf
		jr		skip100_1
skip100:
		inc		a
skip100_1:
		add		a, '0'			;	Cy = 0
		ld		[de], a
		inc		de

		ld		a, l
		ld		h, 0
		ld		b, 50
		sub		a, b
		jr		nc, skip50
		add		a, b
		jr		skip50_1
skip50:
		ld		h, 5
skip50_1:
		ld		b, 30
		sub		a, b
		jr		nc, skip30
		add		a, b
		jr		skip30_1
skip30:
		inc		h
		inc		h
		inc		h
skip30_1:
		ld		b, 20
		sub		a, b
		jr		nc, skip20
		add		a, b
		jr		skip20_1
skip20:
		inc		h
		inc		h
skip20_1:
		ld		b, 10
		sub		a, b
		jr		nc, skip10
		add		a, b
		jr		skip10_1
skip10:
		inc		h
skip10_1:
		add		a, '0'
		ld		l, a
		ld		a, h
		add		a, '0'
		ld		[de], a
		inc		de

		ld		a, l
		ld		[de], a
		inc		de

		xor		a, a
		ld		[de], a

		dec		de
		dec		de
		dec		de
		dec		de
		dec		de
skip_zero:
		ld		a, [de]
		inc		de
		cp		a, '0'
		jr		z, skip_zero
		dec		de

		or		a, a
		ret		nz
		dec		de
		ret
		endscope

; ==============================================================================
;	issjis1st
;	input)
;		a ..... Character code
;	output)
;		Cy .... 0: ASCIIコード/かな文字コード, 1: マルチバイト1byte目
;	break)
;		f
;	comment)
;		文字コード A が、ShiftJIS のマルチバイト1byte目かどうかを判定する
; ==============================================================================
		scope	issjis1st
issjis1st::
		or		a, a
		ret		p			; 0～127 は ASCIIコード
		cp		a, 161
		ret		c			; 128～160 は マルチバイト1byte目
		cp		a, 224
		ccf					; 161～223 は かな文字コード, 224～255 はマルチバイト1byte目
		ret
		endscope

; ==============================================================================
;	strlen
;	input)
;		hl .... Target string (ASCIIZ)
;	output)
;		bc .... String length
;	break)
;		af, bc, hl
; ==============================================================================
		scope	strlen
strlen::
		ld		bc, 0
loop:
		ld		a, [hl]
		or		a, a
		ret		z
		inc		hl
		inc		bc
		jp		loop
		endscope

; ==============================================================================
;	isspace
;	input)
;		a ..... Character code
;	output)
;		Cy .... 1: スペース記号だった, 0: それ以外だった
;	break)
;		f
;	comment)
;		文字コード A が、ホワイトスペースを示すコードであることをチェックする
;		※速度優先で、コントロールコードすべてホワイトスペース扱いです
; ==============================================================================
		scope	isspace
isspace::
		cp		a, ' ' + 1
		ret
		endscope

; ==============================================================================
;	isalpha
;	input)
;		a ..... Character code
;	output)
;		Cy .... 1: アルファベット記号だった, 0: それ以外だった
;	break)
;		f
;	comment)
;		文字コード A が、アルファベットを示すコードであることをチェックする
; ==============================================================================
		scope	isalpha
isalpha::
		cp		a, 'A'
		ccf
		ret		nc
		cp		a, 'Z' + 1
		ret		c
		cp		a, 'a'
		ccf
		ret		nc
		cp		a, 'z' + 1
		ret
		endscope

; ==============================================================================
;	isdigit
;	input)
;		a ..... Character code
;	output)
;		Cy .... 1: 数値記号だった, 1: それ以外だった
;	break)
;		f
;	comment)
;		文字コード A が、数値を示すコードであることをチェックする
; ==============================================================================
		scope	isdigit
isdigit::
		cp		a, '0'
		ccf
		ret		nc
		cp		a, '9' + 1
		ret
		endscope
