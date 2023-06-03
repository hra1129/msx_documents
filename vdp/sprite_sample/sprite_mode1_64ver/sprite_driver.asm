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
;  以下に定める条件に従い、本ソフトウェアおよび関連文書のファイル（以下「ソフト
;  ウェア」）の複製を取得するすべての人に対し、ソフトウェアを無制限に扱うことを
;  無償で許可します。
;  これには、ソフトウェアの複製を使用、複写、変更、結合、掲載、頒布、サブライセ
;  ンス、および/または販売する権利、およびソフトウェアを提供する相手に同じことを
;  許可する権利も無制限に含まれます。
;  
;  上記の著作権表示および本許諾表示を、ソフトウェアのすべての複製または重要な部
;  分に記載するものとします。
;  
;  ソフトウェアは「現状のまま」で、明示であるか暗黙であるかを問わず、何らの保証
;  もなく提供されます。ここでいう保証とは、商品性、特定の目的への適合性、および
;  権利非侵害についての保証も含みますが、それに限定されるものではありません。
;  作者または著作権者は、契約行為、不法行為、またはそれ以外であろうと、ソフト
;  ウェアに起因または関連し、あるいはソフトウェアの使用またはその他の扱いによっ
;  て生じる一切の請求、損害、その他の義務について何らの責任も負わないものとしま
;  す。
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
;		本スプライトドライバを初期化します。
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
;		VRAM上に2つ用意しているスプライトアトリビュートテーブルのうち、実際に
;		表示されるアトリビュートテーブルを入れ替える。
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
;		CPU RAM上に存在するスプライトアトリビュートテーブルを、点滅処理用に並べ
;		替えて、VRAMのスプライトアトリビュートテーブルへ書き出す。
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
