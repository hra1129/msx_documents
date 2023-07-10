; =============================================================================
;	Graphics Driver
; -----------------------------------------------------------------------------
;	2023/July/2rd	t.hara (HRA!)
; =============================================================================

chgmod			:= 0x005F				; SCREEN A

forclr			:= 0xF3E9				; 前景色
bakclr			:= 0xF3EA				; 背景色
bdrclr			:= 0xF3EB				; 周辺色

rg8sav			:= 0xFFE7				; VDP R#8
rg9sav			:= 0xFFE8				; VDP R#9

			org			0x4000

			ds			"AB"
			dw			entry
			dw			0
			dw			0
			dw			0
			dw			0
			dw			0
			dw			0

; =============================================================================
			scope		entry
entry::
			; COLOR 15,4,4:SCREEN 5
			ld			hl, (4 << 8) | 15
			ld			[forclr], hl
			ld			a, h
			ld			[bdrclr], a
			ld			a, 5
			call		chgmod
			; スプライト無効
			ld			a, [rg8sav]
			or			a, 0b00000010		; スプライト無効
			grp_set_vdp 8					; VDP R#8 = A
			; 192ラインモード
			ld			a, [rg9sav]
			and			a, 0b01111111		; 192ラインモード
			grp_set_vdp 9					; VDP R#9 = A
			; カラーパレット初期化
			ld			hl, initial_palette
			call		grp_set_palette
			; スプライトパーツを描画する
			ld			hl, graphic_parts0
			ld			e, 0
			ld			d, 0
			ld			a, 3
			call		grp_put_parts

			ld			hl, graphic_parts1
			ld			e, 16
			ld			d, 0
			ld			a, 3
			call		grp_put_parts

			ld			hl, graphic_parts2
			ld			e, 32
			ld			d, 0
			ld			a, 3
			call		grp_put_parts

			ld			hl, graphic_parts3
			ld			e, 48
			ld			d, 0
			ld			a, 3
			call		grp_put_parts

			ld			hl, graphic_parts16
			ld			e, 0
			ld			d, 0
			ld			a, 2
			call		grp_put_parts

			ld			e, 0
			ld			d, 0
			ld			l, 16
			ld			h, 0
			ld			c, 240
			ld			b, 16
			ld			a, (2 << 2) | 2
			call		grp_copy_hs

			ld			e, 0
			ld			d, 0
			ld			l, 0
			ld			h, 16
			ld			c, 0
			ld			b, 144
			ld			a, (2 << 2) | 2
			call		grp_copy_hs

			call		grp_initialize

			ld			hl, 0x1234
			ld			[random_seed + 0], hl
			ld			hl, 0xABCD
			ld			[random_seed + 2], hl
			call		object_initialize

			ld			a, 20					; ★同時表示するスプライトの数 (Max60)
			ld			[display_objects], a

		main_loop:
			; オブジェクト#0 から開始
			ld			a, [display_objects]
			ld			[current_object], a
			ld			hl, objects_info
		current_object_loop:
			; 着目オブジェクトを移動する
			call		move_object
			; VDPが空いてて、FIFOに何かたまってれば処理する
			push		hl
			call		grp_flash_fifo
			pop			hl
			; 次のオブジェクト
			ld			a, [current_object]
			dec			a
			ld			[current_object], a
			jr			nz, current_object_loop
			; FIFOに残ってる分を全部処理して、画面を切り替え
			call		grp_flash_all
			call		grp_flip
			jp			main_loop
			endscope

			scope		move_object
move_object::
			; X座標
			ld			a, [hl]				; X座標
			inc			hl
			add			a, [hl]				; A = X + VX
			dec			hl
			ld			[hl], a				; X座標更新
			cp			a, 248				; もし 248～255 なら左にはみ出した
			jr			c, skip_adjust_x1
			; 左にはみ出したので左端に貼り付け、VXを符号反転する
			inc			hl
			ld			a, [hl]				; A = VX
			neg
			ld			[hl], a				; VX = -A
			dec			hl
			xor			a, a
			ld			[hl], a				; X座標 = 0
		skip_adjust_x1:
			cp			a, 241				; もし 241～247 なら右にはみ出した
			jr			c, skip_adjust_x2
			; 右にはみ出したので右端に貼り付け、VXを符号反転する
			inc			hl
			ld			a, [hl]				; A = VX
			neg
			ld			[hl], a				; VX = -A
			dec			hl
			ld			a, 240
			ld			[hl], a				; X座標 = 240
		skip_adjust_x2:
			ld			e, a				; E = X座標
			inc			hl
			inc			hl
			; Y座標
			ld			a, [hl]				; Y座標
			inc			hl
			add			a, [hl]				; A = Y + VY
			dec			hl
			ld			[hl], a				; Y座標更新
			cp			a, 248				; もし 248～255 なら上にはみ出した
			jr			c, skip_adjust_y1
			; 上にはみ出したので上端に貼り付け、VYを符号反転する
			inc			hl
			ld			a, [hl]				; A = VY
			neg
			ld			[hl], a				; VY = -A
			dec			hl
			xor			a, a
			ld			[hl], a				; Y座標 = 0
		skip_adjust_y1:
			cp			a, 145				; もし 145～ なら下にはみ出した
			jr			c, skip_adjust_y2
			; 下にはみ出したので下端に貼り付け、VYを符号反転する
			inc			hl
			ld			a, [hl]				; A = VY
			neg
			ld			[hl], a				; VY = -A
			dec			hl
			ld			a, 144
			ld			[hl], a				; Y座標 = 144
		skip_adjust_y2:
			ld			d, a				; D = Y座標
			inc			hl
			inc			hl
			; カレント番号をパーツ番号にする
			ld			a, [current_object]
			and			a, 3
			push		hl
			; スプライト表示
			call		grp_put_sprite
			pop			hl
			ret
			endscope

; =============================================================================
			scope		object_initialize
object_initialize::
			ld			b, grp_sprite_max_num
			ld			hl, objects_info
		loop:
			; X座標 0～240
			exx
			call		random
			exx
			and			a, 0xFE
			cp			a, 240
			jr			c, skip_adjust_x
			sub			a, 240
		skip_adjust_x:
			ld			[hl], a
			inc			hl
			; VX座標 -6, -4, -2, 2, 4, 6
			exx
			call		random
			exx
			and			a, 7				; 0～7
			sub			a, 3				; -3～4
			jr			nz, skip_adjust_vx1
			dec			a
		skip_adjust_vx1:					; -3, -2, -1, 1, 2, 3, 4
			cp			a, 4
			jr			nz, skip_adjust_vx2
			dec			a
		skip_adjust_vx2:					; -3, -2, -1, 1, 2, 3
			add			a, a				; -6, -4, -2, 2, 4, 6
			ld			[hl], a
			inc			hl
			; Y座標 0～144
			exx
			call		random
			exx
			cp			a, 144
			jr			c, skip_adjust_y
			sub			a, 144
		skip_adjust_y:
			ld			[hl], a
			inc			hl
			; VY座標 -6, -4, -2, 2, 4, 6
			exx
			call		random
			exx
			and			a, 7				; 0～7
			sub			a, 3				; -3～4
			jr			nz, skip_adjust_vy1
			dec			a
		skip_adjust_vy1:					; -3, -2, -1, 1, 2, 3, 4
			cp			a, 4
			jr			nz, skip_adjust_vy2
			dec			a
		skip_adjust_vy2:					; -3, -2, -1, 1, 2, 3
			add			a, a				; -6, -4, -2, 2, 4, 6
			ld			[hl], a
			inc			hl
			djnz		loop
			ret
			endscope

; =============================================================================
initial_palette:
			grp_palette		  0, 111,  87			; #0
			grp_palette		  0,   0,   0			; #1
			grp_palette		 12, 222,  54			; #2
			grp_palette		128, 255, 144			; #3
			grp_palette		  0,   0, 255			; #4
			grp_palette		  0, 165, 255			; #5
			grp_palette		120,   0,   0			; #6
			grp_palette		  0, 225, 255			; #7
			grp_palette		204,   0,   0			; #8
			grp_palette		255, 105,   0			; #9
			grp_palette		144, 108,   0			; #10
			grp_palette		201, 174,   0			; #11
			grp_palette		  0, 141,   0			; #12
			grp_palette		255, 255, 162			; #13
			grp_palette		  0, 255, 255			; #14
			grp_palette		255, 255, 255			; #15

			include		"graphics_driver.asm"
			include		"image1.asm"
			include		"random.asm"
			include		"graphics_driver_work.asm"

; =============================================================================
object_work				:= grp_work_end
random_seed				:= object_work				; 4byte
display_objects			:= random_seed + 4			; 1byte : 表示するスプライトの数
current_object			:= display_objects + 1
objects_info			:= current_object + 1		; 4 * grp_sprite_max_num bytes: スプライトの表示情報
object_x				:= 0
object_vx				:= 1
object_y				:= 2
object_vy				:= 3
