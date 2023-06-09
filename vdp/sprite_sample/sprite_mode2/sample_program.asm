; -----------------------------------------------------------------------------
;  Sprite Driver sample code
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

				include	"msx_constant.asm"

				db		0xFE
				dw		start_address
				dw		end_address
				dw		start_address

				org		0xA000
start_address::
				; =============================================================
				;		initialize
				; =============================================================
				; SCREEN 5
				ld		a, 5
				call	chgmod
				; VDP(1) = (VDP(1) & 0xFC) | 0x02
				ld		a, [rg1sav]
				and		a, 0xFC
				or		a, 0x02
				ld		c, 1
				ld		b, a
				call	wrtvdp
				; initialize spdrv
				call	spdrv_initialize
				; sprite$(0) = sprite_pattern
				ld		hl, sprite_pattern
				ld		de, 0x7800					; sprite generator table
				ld		bc, 32 * 3
				call	ldirvm
				; initialize random
;				ld		a, [jiffy]
				ld		a, 123;
				ld		hl, random_seed
				ld		[hl], a
				inc		hl
				ld		[hl], a
				inc		hl
				ld		[hl], a
				inc		hl
				ld		[hl], a
				inc		hl
				; initialize ball position
				ld		hl, sprite_pos
				ld		de, sprite_attribute
				ld		b, 12						; Number of two-ply sprites
		ball_setup1:
				call	ball_initialize1
				djnz	ball_setup1

				ld		b, 8						; Number of single sprites
		ball_setup2:
				call	ball_initialize2
				djnz	ball_setup2

				; =============================================================
				;		main loop
				; =============================================================
		loop:
				; back up the JIFFY value.
				ld		a, [jiffy]
				ld		[jiffy_back], a

				; flip sprite attribute
				call	spdrv_flip
				; update ball position
				call	ball_move
				; update sprite attribute on VRAM
				call	spdrv_update
				; wait JIFFY change.
				ld		hl, jiffy
				ld		a, [jiffy_back]
		vsync_wait:
				cp		a, [hl]
				jr		z, vsync_wait
				jp		loop

				; =============================================================
				;		ball initialize for two-ply sprites
				;		input)
				;			hl ... &sprite_pos[n] (target)
				;			de ... sprite attribute
				; =============================================================
				scope	ball_initialize1
		ball_initialize1::
				push	bc
				push	de
				; X position
				push	hl
				call	random
				pop		hl
				cp		a, 256 - 16
				jr		c, skip_adjust_x
				sub		a, 256 - 16
			skip_adjust_x:
				ld		[hl], a
				inc		hl
				; Y position
				push	hl
				call	random
				pop		hl
				cp		a, 212 - 16
				jr		c, skip_adjust_y
				sub		a, 212 - 16
			skip_adjust_y:
				ld		[hl], a
				inc		hl
				; VX
				push	hl
				call	random
				pop		hl
				ld		b, a
				and		a, 1				; 0 or 1
				add		a, a				; 0 or 2
				dec		a					; -1 or 1
				bit		4, b
				jr		z, skip_double_vx
				add		a, a				; -2 or 2
			skip_double_vx:
				ld		[hl], a
				inc		hl
				; VY
				push	hl
				call	random
				pop		hl
				ld		b, a
				and		a, 1				; 0 or 1
				add		a, a				; 0 or 2
				dec		a					; -1 or 1
				bit		4, b
				jr		z, skip_double_vy
				add		a, a				; -2 or 2
			skip_double_vy:
				ld		[hl], a
				inc		hl
				; sprite attribute --------------------------------------------
				; 1st sprite plane
				pop		de
				pop		bc
				inc		de					; DE = &X
				inc		de					; DE = &Pattern#0
				xor		a, a
				ld		[de], a				; sprite pattern = #0
				inc		de					; DE = &Color#0
				ld		a, b				; A = loop counter
				and		a, 3				; 0, 1, 2 or 3
				ld		[de], a				; sprite color = #0, #1, #2 or #3
				inc		de					; DE = &Num
				ld		a, 2
				ld		[de], a				; Num = 2
				; 2nd sprite plane
				inc		de					; DE = &Pattern#1
				ld		a, 4
				ld		[de], a				; sprite pattern = #4
				inc		de					; DE = &Color#1
				ld		a, 4
				ld		[de], a				; sprite color = #4
				inc		de					; DE = &Reserved
				inc		de					; DE = next
				ret
				endscope

				; =============================================================
				;		ball initialize for two-ply sprites
				;		input)
				;			hl ... &sprite_pos[n] (target)
				;			de ... sprite attribute
				; =============================================================
				scope	ball_initialize2
		ball_initialize2::
				push	bc
				push	de
				; X position
				push	hl
				call	random
				pop		hl
				cp		a, 256 - 16
				jr		c, skip_adjust_x
				sub		a, 256 - 16
			skip_adjust_x:
				ld		[hl], a
				inc		hl
				; Y position
				push	hl
				call	random
				pop		hl
				cp		a, 212 - 16
				jr		c, skip_adjust_y
				sub		a, 212 - 16
			skip_adjust_y:
				ld		[hl], a
				inc		hl
				; VX
				push	hl
				call	random
				pop		hl
				ld		b, a
				and		a, 1				; 0 or 1
				add		a, a				; 0 or 2
				dec		a					; -1 or 1
				bit		4, b
				jr		z, skip_double_vx
				add		a, a				; -2 or 2
			skip_double_vx:
				ld		[hl], a
				inc		hl
				; VY
				push	hl
				call	random
				pop		hl
				ld		b, a
				and		a, 1				; 0 or 1
				add		a, a				; 0 or 2
				dec		a					; -1 or 1
				bit		4, b
				jr		z, skip_double_vy
				add		a, a				; -2 or 2
			skip_double_vy:
				ld		[hl], a
				inc		hl
				; sprite attribute --------------------------------------------
				; 1st sprite plane
				pop		de
				pop		bc
				inc		de					; DE = &X
				inc		de					; DE = &Pattern#0
				ld		a, 8
				ld		[de], a				; sprite pattern = #8
				inc		de					; DE = &Color0
				ld		a, b
				and		a, 1
				add		a, 5
				ld		[de], a				; sprite color = #5 or #6
				inc		de					; DE = &Num
				ld		a, 1
				ld		[de], a				; Num = 1
				inc		de					; DE = &Pattern#1
				inc		de					; DE = &Color#1
				inc		de					; DE = &Reserve
				inc		de					; DE = next
				ret
				endscope

				; =============================================================
				;		ball move
				;		input)
				;			hl ... &sprite_pos[n] (target)
				; =============================================================
				scope	ball_move
		ball_move::
				ld		b, 20
				ld		hl, sprite_pos
				ld		de, sprite_attribute
			loop:
				push	bc					; (1) save loop counter
				push	de					; (2) save sprite attribute
				; get ball position of current target
				ld		e, [hl]				; E = ball.x
				inc		hl					; HL = &ball.y
				ld		d, [hl]				; D = ball.y
				inc		hl					; HL = &ball.vx
				ld		c, [hl]				; C = ball.vx
				inc		hl					; HL = &ball.vy
				ld		b, [hl]				; B = ball.vy
				dec		hl					; HL = &ball.vx
				dec		hl					; HL = &ball.y
				dec		hl					; HL = &ball.x
				; move X position
				ld		a, e
				add		a, c				; A = ball.x + ball.vx
				ld		[hl], a				; ball.x = A
				ld		e, a				; E = A
				inc		hl					; HL = &ball.y   (no flag change)
				inc		hl					; HL = &ball.vx  (no flag change)
				cp		a, 256 - 16
				jr		c, no_inversion_x	; if ((ball.x + ball.vx) & 255) < (256 - 16) goto no_inversion_x
			inversion_x:
				ld		a, c
				neg							; A = -ball.vx
				ld		[hl], a				; ball.vx = A
				add		a, e
				ld		e, a				; E = ball.x + ball.vx
			no_inversion_x:
				dec		hl					; HL = &ball.y
				; move Y position
				ld		a, d
				add		a, b				; A = ball.y + ball.vy
				ld		[hl], a				; ball.y = A
				ld		d, a				; D = A
				inc		hl					; HL = &ball.vx  (no flag change)
				inc		hl					; HL = &ball.vy  (no flag change)
				cp		a, 212 - 16
				jr		c, no_inversion_y	; if ((ball.y + ball.vy) & 255) < (212 - 16) goto no_inversion_y
			inversion_y:
				ld		a, b
				neg							; A = -ball.vy
				ld		[hl], a				; ball.vy = A
				add		a, d
				ld		d, a				; D = ball.y + ball.vy
			no_inversion_y:
				inc		hl					; HL = next
				; update sprite position
				ld		c, l
				ld		b, h				; BC = HL
				pop		hl					; [2] restore sprite attribute
				ld		[hl], d				; sprite Y = ball.y
				inc		hl					; HL = &X
				ld		[hl], e				; sprite X = ball.x
				ld		de, 7
				add		hl, de				; HL = next
				ex		de, hl				; DE = next sprite_attribute
				ld		l, c
				ld		h, b				; HL = BC
				pop		bc					; [1] restore loop counter
				djnz	loop
				ret
				endscope

				; =============================================================
				;		drivers
				; =============================================================
				include	"sprite_driver.asm"
				include	"random.asm"

				; =============================================================
				;		data
				; =============================================================
sprite_pattern::
				db		0b00000000				; #0
				db		0b00000011
				db		0b00001111
				db		0b00011111
				db		0b00111111
				db		0b00111111
				db		0b01111111
				db		0b01111111
				db		0b01111111
				db		0b01111111
				db		0b00111111
				db		0b00111111
				db		0b00011111
				db		0b00001111
				db		0b00000011
				db		0b00000000
				db		0b00000000
				db		0b11000000
				db		0b11110000
				db		0b11111000
				db		0b11111100
				db		0b11111100
				db		0b11111110
				db		0b11111110
				db		0b11111110
				db		0b11111110
				db		0b11111100
				db		0b11111100
				db		0b11111000
				db		0b11110000
				db		0b11000000
				db		0b00000000

				db		0b00000011				; #4
				db		0b00001100
				db		0b00010000
				db		0b00100000
				db		0b01000000
				db		0b01000000
				db		0b10000000
				db		0b10000000
				db		0b10000000
				db		0b10000000
				db		0b01000000
				db		0b01000000
				db		0b00110000
				db		0b00011111
				db		0b00001111
				db		0b00000011
				db		0b11000000
				db		0b00110000
				db		0b00001000
				db		0b00000100
				db		0b00000010
				db		0b00000010
				db		0b00000011
				db		0b00000011
				db		0b00000111
				db		0b00000111
				db		0b00001110
				db		0b00011110
				db		0b01111100
				db		0b11111000
				db		0b11110000
				db		0b11000000

				db		0b00111111				; #8
				db		0b01111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b01111111
				db		0b00111111
				db		0b11111100
				db		0b11111110
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111111
				db		0b11111110
				db		0b11111100

sprite_color_table::
				db		0x02			; #0
				db		0x02
				db		0x02
				db		0x02
				db		0x02
				db		0x02
				db		0x02
				db		0x02
				db		0x02
				db		0x02
				db		0x02
				db		0x02
				db		0x02
				db		0x02
				db		0x02
				db		0x02

				db		0x04			; #1
				db		0x04
				db		0x04
				db		0x04
				db		0x04
				db		0x04
				db		0x04
				db		0x04
				db		0x04
				db		0x04
				db		0x04
				db		0x04
				db		0x04
				db		0x04
				db		0x04
				db		0x04

				db		0x08			; #2
				db		0x08
				db		0x08
				db		0x08
				db		0x08
				db		0x08
				db		0x08
				db		0x08
				db		0x08
				db		0x08
				db		0x08
				db		0x08
				db		0x08
				db		0x08
				db		0x08
				db		0x08

				db		0x0A			; #3
				db		0x0A
				db		0x0A
				db		0x0A
				db		0x0A
				db		0x0A
				db		0x0A
				db		0x0A
				db		0x0A
				db		0x0A
				db		0x0A
				db		0x0A
				db		0x0A
				db		0x0A
				db		0x0A
				db		0x0A

				db		0x41			; #4
				db		0x41
				db		0x41
				db		0x41
				db		0x41
				db		0x41
				db		0x41
				db		0x41
				db		0x41
				db		0x41
				db		0x41
				db		0x41
				db		0x41
				db		0x41
				db		0x41
				db		0x41

				db		0x04			; #5
				db		0x05
				db		0x07
				db		0x07
				db		0x05
				db		0x05
				db		0x05
				db		0x05
				db		0x04
				db		0x05
				db		0x04
				db		0x04
				db		0x04
				db		0x04
				db		0x04
				db		0x04

				db		0x0C			; #6
				db		0x02
				db		0x03
				db		0x03
				db		0x02
				db		0x02
				db		0x02
				db		0x02
				db		0x0C
				db		0x02
				db		0x0C
				db		0x0C
				db		0x0C
				db		0x0C
				db		0x0C
				db		0x0C

jiffy_back::
				db		0

sprite_pos::	;		X, Y, VX, VY
				db		0, 0, 0, 0		; #0
				db		0, 0, 0, 0		; #1
				db		0, 0, 0, 0		; #2
				db		0, 0, 0, 0		; #3
				db		0, 0, 0, 0		; #4
				db		0, 0, 0, 0		; #5
				db		0, 0, 0, 0		; #6
				db		0, 0, 0, 0		; #7
				db		0, 0, 0, 0		; #8
				db		0, 0, 0, 0		; #9
				db		0, 0, 0, 0		; #10
				db		0, 0, 0, 0		; #11
				db		0, 0, 0, 0		; #12
				db		0, 0, 0, 0		; #13
				db		0, 0, 0, 0		; #14
				db		0, 0, 0, 0		; #15
				db		0, 0, 0, 0		; #16
				db		0, 0, 0, 0		; #17
				db		0, 0, 0, 0		; #18
				db		0, 0, 0, 0		; #19
				db		0, 0, 0, 0		; #20
				db		0, 0, 0, 0		; #21
				db		0, 0, 0, 0		; #22
				db		0, 0, 0, 0		; #23
				db		0, 0, 0, 0		; #24
				db		0, 0, 0, 0		; #25
				db		0, 0, 0, 0		; #26
				db		0, 0, 0, 0		; #27
				db		0, 0, 0, 0		; #28
				db		0, 0, 0, 0		; #29
				db		0, 0, 0, 0		; #30
				db		0, 0, 0, 0		; #31

				include	"sprite_driver_work.asm"

end_address::
