; -----------------------------------------------------------------------------
;  Sprite Driver for Sprite Mode2
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
;  2023/June/6th	t.hara
; -----------------------------------------------------------------------------

vram_sprite_attribute1	:= 0x7200
vram_sprite_attribute2	:= 0x7600

vram_sprite_color1		:= vram_sprite_attribute1 - 0x0200
vram_sprite_color2		:= vram_sprite_attribute2 - 0x0200

sprite_attribute_page	:= vram_sprite_attribute1 >> 15
disable_y				:= 216

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
				ld			hl, (0 << 8) | disable_y		; Y = disable_y, X = 0
				ld			[sprite_attribute], hl
				ld			hl, (0 << 8) | 0				; Color#0 = 0, Pattern#0 = 0
				ld			[sprite_attribute + 2], hl
				ld			a, 1
				ld			[sprite_attribute + 4], a
				ld			hl, sprite_attribute
				ld			de, sprite_attribute + 8
				ld			bc, (8 * 32) - 8
				ldir
				; clear sprite attribute 1 and 2 on VRAM
				ld			a, disable_y
				ld			hl, vram_sprite_attribute1
				ld			bc, (4 * 32) * 2
				call		filvrm
				; initialize page of sprite attribute.
				di
				ld			a, sprite_attribute_page
				out			[vdp_port1], a
				ld			a, 0x80 | 11
				out			[vdp_port1], a
				ei
				; initialize work area
				xor			a, a
				ld			[sprite_index], a
				ld			a, ((vram_sprite_attribute1 >> 7) & 255) | 0b00000111
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
				ld			a, [sprite_page]
				ld			b, a
				di
				out			[vdp_port1], a
				ld			a, 0x80 | 5
				out			[vdp_port1], a
				ei

				; update write page
				ld			a, b
				xor			a, ((vram_sprite_attribute1 >> 7) ^ (vram_sprite_attribute2 >> 7)) & 255
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
				ld			a, vram_sprite_attribute1 >> 14
				di
				out			[vdp_port1], a
				ld			a, 0x80 | 14
				out			[vdp_port1], a

				xor			a, a
				out			[vdp_port1], a
				ld			a, [sprite_page]
				rrca
				and			a, 0x3C
				or			a, 0x42
				out			[vdp_port1], a
				ei

				; reference sprite_attribute on CPU RAM
				ld			a, [sprite_index]
				ld			e, a
				ld			d, 0
				exx
				ld			hl, sprite_color_work
				ld			bc, (32 << 8) | 32		; B=32 (The number of virtual sprite attributes), C=32 (Visible sprite planes)
		attribute_loop:
				exx
				; Get address of current sprite_attribute
				ld			hl, sprite_attribute
				add			hl, de
				push		de						; (1) sprite_index

				; Is current sprite_attribute visible?
				ld			a, [hl]					; A = Y
				ld			e, 4
				add			hl, de					; HL = &Num
				cp			a, disable_y
				jr			z, skip_set_position	; if Y == disable_y goto skip_set_position
				ld			e, a					; E = Y

				; Can it be displayed with the remaining sprites?
				exx
				ld			a, c
				exx
				cp			a, [hl]
				jr			c, skip_set_position
				dec			hl						; HL = &Color0
				dec			hl						; HL = &Pattern0
				dec			hl						; HL = &X

				; Transfer current sprite_attribute to VRAM
				; -- Set position of 1st sprite plane.
				ld			a, e					; A = Y
				out			[vdp_port0], a			; Y
				ld			a, [hl]					; A = X
				ld			d, a					; D = X
				out			[vdp_port0], a			; X
				inc			hl						; HL = &Pattern#0
				ld			a, [hl]					; Pattern#0
				out			[vdp_port0], a
				inc			hl						; HL = &Color#0
				ld			a, [hl]					; Color#0
				out			[vdp_port0], a			;   Dummy write
				inc			hl						; HL = &Num
				exx
				ld			[hl], a					; sprite_color_work[n] = Color#0
				inc			hl
				dec			c						; count visible sprite
				exx

				ld			a, [hl]					; A = Num
				dec			a						; two-ply sprites?
				jr			z, skip_set_position	; If single sprite go to skip_set_position

				; -- Set position of 2nd sprite plane.
				ld			a, e					; Y
				out			[vdp_port0], a
				inc			hl						; HL = &Pattern#1
				ld			a, d					; X
				out			[vdp_port0], a
				ld			a, [hl]					; Pattern#1
				out			[vdp_port0], a
				inc			hl						; HL = &Color#1
				ld			a, [hl]					; Color#1
				out			[vdp_port0], a			;   Dummy write
				exx
				ld			[hl], a					; sprite_color_work[n] = Color#1
				inc			hl
				dec			c						; count visible sprite
				exx
				jr			z, transfer_sprite_color
		skip_set_position:
				; Go to next.
				pop			de						; [1] sprite_index
				ld			a, e
				add			a, 7 * 8				; 7 is prime number.
				ld			e, a
				exx
				djnz		attribute_loop

				; Is visible sprite count over 32?
				push		de						; (1) dummy push
				ld			a, c
				or			a, a
				jr			z, transfer_sprite_color

				; Hide remain sprites
				ld			a, disable_y
				out			[vdp_port0], a

		transfer_sprite_color:
				pop			de						; [1] dummy pop (sprite_index)
				; set VRAM address for sprite color
				ld			a, vram_sprite_attribute1 >> 14
				di
				out			[vdp_port1], a
				ld			a, 0x80 | 14
				out			[vdp_port1], a			; VDP R#14 = VRAM address[16:14]

				xor			a, a
				out			[vdp_port1], a			; VRAM address[7:0] == 0x00
				ld			a, [sprite_page]		; A = VRAM address[14:7]
				rrca								; A = VRAM address[7][14:8]
				sub			a, 2
				and			a, 0x3C
				or			a, 0x40
				out			[vdp_port1], a			; VRAM address[13:0]
				ei

				ld			hl, sprite_color_work	; color table index table
				exx
				ld			c, 32					; The number of sprite planes is 32.
		sprite_color_loop:
				; calculate sprite color address
				exx
				ld			a, [hl]					; get color table index for current sprite plane
				inc			hl
				exx
				ld			l, a
				ld			h, 0
				add			hl, hl
				add			hl, hl
				add			hl, hl
				add			hl, hl					; HL = color_table_index * 16
				ld			de, sprite_color_table
				add			hl, de					; HL = sprite_color_table + color_table_index * 16

				ld			b, 16					; The size of the color table for one sprite plane is 16 bytes.
		transfer_loop:
				ld			a, [hl]
				inc			hl
				out			[vdp_port0], a
				djnz		transfer_loop
				dec			c
				jr			nz, sprite_color_loop

				; Calculate next index.
				ld			a, [sprite_index]
				add			a, 19 * 8				; 19 is prime number.
				ld			[sprite_index], a
				ret
				endscope
