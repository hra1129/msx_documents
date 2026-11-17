; =============================================================================
;	Graphics Driver
; -----------------------------------------------------------------------------
;	2023/July/2rd	t.hara (HRA!)
; =============================================================================

vdp_port0	:= 0x98
vdp_port1	:= 0x99
vdp_port2	:= 0x9A
vdp_port3	:= 0x9B
jiffy		:= 0xFC9E

; -----------------------------------------------------------------------------
;	public grp_palette
;	input)
;		vr ..... 赤 0～255 の定数
;		vg ..... 緑 0～255 の定数
;		vb ..... 青 0～255 の定数
;	output)
;		none
;	break)
;		all
;	description)
;		WindowsPC で使われている 8bit深度カラーを指定する。
;		実際には、単純に 1/32倍された値が設定される。
;		単なるデータ定義のマクロである。
; -----------------------------------------------------------------------------
grp_palette		macro		vr, vg, vb
				db			((vr/32) << 4) | (vb/32)
				db			(vg/32)
				endm

; -----------------------------------------------------------------------------
;	public grp_dpalette
;	input)
;		vr ..... 赤 0～7 の定数
;		vg ..... 緑 0～7 の定数
;		vb ..... 青 0～7 の定数
;	output)
;		none
;	break)
;		all
;	description)
;		MSX2のパレットの深度で、直接値(direct)を指定する。
;		単なるデータ定義のマクロである。
; -----------------------------------------------------------------------------
grp_dpalette	macro		vr, vg, vb
				db			(vr << 4) | (vb)
				db			(vg)
				endm

; -----------------------------------------------------------------------------
;	public grp_initialize
;	input)
;		none
;	output)
;		none
;	break)
;		all
;	description)
;		疑似スプライトのための初期化処理
;		page0, page1 の背景を初期化した後、FIFOを初期化する。
; -----------------------------------------------------------------------------
			scope		grp_initialize
grp_initialize::
			; 背景画像を page0 に転送する
			ld			de, (0 << 8) | 0
			ld			hl, (0 << 8) | 0
			ld			bc, (160 << 8) | 0
			ld			a, (0 << 2) | 2
			call		grp_copy_hs
			; 背景画像を page1 に転送する
			ld			de, (0 << 8) | 0
			ld			hl, (0 << 8) | 0
			ld			bc, (160 << 8) | 0
			ld			a, (1 << 2) | 2
			call		grp_copy_hs
			; FIFOの初期化
			xor			a, a
			ld			[draw_page], a
			ld			[sprite_fifo_count], a
			ld			[erase_fifo_next_count], a
			ld			[erase_fifo_current_count], a
			ld			hl, erase_fifo_page0
			ld			[erase_fifo_ptr], hl
			jp			_grp_prepare_next_frame
			endscope

; -----------------------------------------------------------------------------
;	public grp_set_vdp
;	input)
;		A ............... 書き込む値
;		register_num .... レジスタ番号
;	output)
;		none
;	break)
;		A
;	description)
;		VDPレジスタ R#{register_num} に A の値を書き込む
;		grp_initialize前に実行可能
; -----------------------------------------------------------------------------
grp_set_vdp	macro		register_num
			di
			out			[vdp_port1], a
			ld			a, 0x80 | register_num
			out			[vdp_port1], a
			ei
			endm

; -----------------------------------------------------------------------------
;	public grp_set_palette
;	input)
;		HL .... パレットデータのアドレス
;	output)
;		HL .... パレットデータの次のアドレス
;	break)
;		AF, BC
;	description)
;		grp_initialize前に実行可能
;		16パレットまとめて設定する。
;		palette#0 ～ #15 を番号順に並べたテーブルのアドレスを HL に設定する。
;
;		HL --> [RB][0G][RB][0G] ... [RB][0G]
;
;		[RB][0G] の 2byte は、grp_palette マクロ または grp_dpalette マクロ
;		を使用して作成する。下記のようにテーブル作成することを期待している。
;
;			grp_palette		  0, 111,  87			; #0
;			grp_palette		  0,   0,   0			; #1
;			grp_palette		 12, 222,  54			; #2
;			grp_palette		128, 255, 144			; #3
;			grp_palette		  0,   0, 255			; #4
;			grp_palette		  0, 165, 255			; #5
;			grp_palette		120,   0,   0			; #6
;			grp_palette		  0, 225, 255			; #7
;			grp_palette		204,   0,   0			; #8
;			grp_palette		255, 105,   0			; #9
;			grp_palette		144, 108,   0			; #10
;			grp_palette		201, 174,   0			; #11
;			grp_palette		  0, 141,   0			; #12
;			grp_palette		255, 255, 162			; #13
;			grp_palette		  0, 255, 255			; #14
;			grp_palette		255, 255, 255			; #15
; -----------------------------------------------------------------------------
			scope		grp_set_palette
grp_set_palette::
			xor			a, a
			di
			out			[vdp_port1], a
			ld			a, 0x80 | 16
			out			[vdp_port1], a		; VDP R#16 = 0 (palette index)
			ei
			ld			bc, (32 << 8) | vdp_port2
			otir
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_check_vdp
;	input)
;		none
;	output)
;		Zf .... 1: VDPコマンド停止中, 0: VDPコマンド実行中
;	break)
;		AF, BC
;	description)
;		VDPコマンド実行中か調べる
;		grp_initialize前に実行可能
; -----------------------------------------------------------------------------
			scope		grp_check_vdp
grp_check_vdp::
			; VDP R#15 = S#2
			ld			bc, ((0x80 | 15) << 8) | vdp_port1
			ld			a, 2
			di
			out			[c], a
			out			[c], b
			; CE bit が 1 なら Zf = 0
			in			a, [c]
			and			a, 1			; Zf 1: VDPコマンド停止中, 0: VDPコマンド実行中
			; VDP R#15 = S#0
			ld			a, 0			; Zf 不変
			out			[c], a			; Zf 不変
			out			[c], b			; Zf 不変
			ei							; Zf 不変
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_wait_vdp
;	input)
;		none
;	output)
;		none
;	break)
;		none
;	description)
;		VDPコマンド実行完了まで待機する
;		grp_initialize前に実行可能
; -----------------------------------------------------------------------------
			scope		grp_wait_vdp
grp_wait_vdp::
			push		af
			push		bc
			; VDP R#15 = S#2
			ld			bc, ((0x80 | 15) << 8) | vdp_port1
	loop:
			ld			a, 2
			di
			out			[c], a
			out			[c], b
			; CE bit が 1 なら Zf = 0
			in			a, [c]
			and			a, 1			; Zf 1: VDPコマンド停止中, 0: VDPコマンド実行中
			; VDP R#15 = S#0
			ld			a, 0			; Zf 不変
			out			[c], a			; Zf 不変
			out			[c], b			; Zf 不変
			ei							; Zf 不変
			jp			nz, loop
			pop			bc
			pop			af
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_get_sprite_pattern_position
;	input)
;		A ..... スプライトパターン番号 0～255
;	output)
;		E ..... X座標
;		D ..... Y座標
;	break)
;		AF
;	description)
;		スプライトパターン番号から grp_put_parts の入力 ( e, d ) に使える座標を
;		求める。
;		grp_initialize前に実行可能
; -----------------------------------------------------------------------------
			scope		grp_get_sprite_pattern_position
grp_get_sprite_pattern_position::
			ld			d, a
			and			a, 0x0F
			add			a, a
			add			a, a
			add			a, a
			add			a, a
			ld			e, a				; パーツ X座標 = (A & 15) << 4
			ld			a, d
			and			a, 0xF0
			ld			[hl], a				; パーツ Y座標 = A & (15 << 4)
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_put_parts
;	input)
;		E ..... X座標
;		D ..... Y座標
;		A ..... 描画ページ
;		HL .... 画像アドレス (128bytes)
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		16x16サイズのパーツを指定のページの指定の座標へ描画する
;		grp_initialize前に実行可能
; -----------------------------------------------------------------------------
			scope		grp_put_parts
grp_put_parts::
			push		hl
			; VDP R#17 = R#36 (オートインクリメント)
			ld			c, vdp_port1
			ld			b, 0x00 | 36
			di
			out			[c], b
			ld			b, 0x80 | 17
			out			[c], b
			; C = vdp_port3
			inc			c
			inc			c
			ld			hl, fixed_datas
			; VDP Command
			out			[c], e			; R#36 DX下位
			outi						; R#37 DX上位
			out			[c], d			; R#38 DY下位
			out			[c], a			; R#39 DY上位, 描画ページ
			outi						; R#40 NX下位
			outi						; R#41 NX上位
			outi						; R#42 NY下位
			outi						; R#43 NY上位
			pop			de
			ex			de, hl
			outi						; R#44 CLR
			ex			de, hl
			outi						; R#45 ARG
			outi						; R#46 CMD
			ex			de, hl
			ld			b, 8 * 16 - 1
			; R#17 = R#44 (非オートインクリメント)
			ld			a, 0x80 | 44
			out			[vdp_port1], a
			ld			a, 0x80 | 17
			out			[vdp_port1], a
			otir
			ei
			ret
	fixed_datas:
			db			0				; R#37 DX上位
			db			16				; R#40 NX下位
			db			0				; R#41 NX上位
			db			16				; R#42 NY下位
			db			0				; R#43 NY上位
			db			0				; R#45 ARG
			db			0b1111_0000		; R#46 CMD HMMC
			endscope

; -----------------------------------------------------------------------------
;	private _grp_erase_sprite
;	input)
;		E ..... X座標
;		D ..... Y座標
;		A ..... 描画ページ
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		16x16サイズの消去
; -----------------------------------------------------------------------------
			scope		_grp_erase_sprite
_grp_erase_sprite::
			; VDP R#17 = R#32 (オートインクリメント)
			ld			bc, ((0x00 | 32) << 8) + vdp_port1
			di
			out			[c], b
			ld			b, 0x80 | 17
			out			[c], b
			; C = vdp_port3
			inc			c
			inc			c
			ld			hl, fixed_datas
			; VDP Command
			out			[c], e			; R#32 SX下位
			outi						; R#33 SX上位
			out			[c], d			; R#34 SY下位
			outi						; R#35 SY上位
			out			[c], e			; R#36 DX下位
			outi						; R#37 DX上位
			out			[c], d			; R#38 DY下位
			out			[c], a			; R#39 DY上位, 転送先ページ
			outi						; R#40 NX下位
			outi						; R#41 NX上位
			outi						; R#42 NY下位
			outi						; R#43 NY上位
			outi						; R#44 CLR
			outi						; R#45 ARG
			outi						; R#46 CMD
			ei
			ret
	fixed_datas:
			db			0				; R#33 SX上位
			db			2				; R#35 SY上位, 転送元ページ
			db			0				; R#37 DX上位
			db			16				; R#40 NX下位
			db			0				; R#41 NX上位
			db			16				; R#42 NY下位
			db			0				; R#43 NY上位
			db			0				; R#44 CLR
			db			0				; R#45 ARG
			db			0b1101_0000		; R#46 CMD HMMM
			endscope

; -----------------------------------------------------------------------------
;	private _grp_draw_sprite (内部用)
;	input)
;		E ..... パーツ X座標
;		D ..... パーツ Y座標
;		C ..... 表示 X座標
;		B ..... 表示 Y座標
;		A ..... 描画ページ
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		16x16サイズの疑似スプライト描画
; -----------------------------------------------------------------------------
			scope		_grp_draw_sprite
_grp_draw_sprite::
			; VDP R#17 = R#32 (オートインクリメント)
			push		bc
			ld			bc, ((0x00 | 32) << 8) + vdp_port1
			di
			out			[c], b
			ld			b, 0x80 | 17
			out			[c], b
			; C = vdp_port3
			inc			c
			inc			c
			ld			hl, fixed_datas
			; VDP Command
			out			[c], e			; R#32 SX下位
			outi						; R#33 SX上位
			out			[c], d			; R#34 SY下位
			outi						; R#35 SY上位
			pop			de
			out			[c], e			; R#36 DX下位
			outi						; R#37 DX上位
			out			[c], d			; R#38 DY下位
			out			[c], a			; R#39 DY上位, 転送先ページ
			outi						; R#40 NX下位
			outi						; R#41 NX上位
			outi						; R#42 NY下位
			outi						; R#43 NY上位
			outi						; R#44 CLR
			outi						; R#45 ARG
			outi						; R#46 CMD
			ei
			ret
	fixed_datas:
			db			0				; R#33 SX上位
			db			3				; R#34 SY上位, 転送元ページ
			db			0				; R#37 DX上位
			db			16				; R#40 NX下位
			db			0				; R#41 NX上位
			db			16				; R#42 NY下位
			db			0				; R#43 NY上位
			db			0				; R#44 CLR
			db			0				; R#45 ARG
			db			0b1001_1000		; R#46 CMD LMMM, TIMP
			endscope

; -----------------------------------------------------------------------------
;	public grp_put_sprite
;	input)
;		E ..... X座標 (偶数のみ)
;		D ..... Y座標
;		A ..... パーツ番号
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		16x16サイズの描画指示
;		限界数カウントは行っていないため、1フレーム中で grp_sprite_max_num 回を
;		超える回数呼び出してはならない。
; -----------------------------------------------------------------------------
			scope		grp_put_sprite
grp_put_sprite::
			; 表示用FIFO へ詰める
			ld			hl, [sprite_fifo_ptr]
			ld			[hl], e				; 表示 X座標
			inc			hl
			ld			[hl], d				; 表示 Y座標
			inc			hl
			; -- パーツ番号を転送元座標に変換する
			ld			d, a
			and			a, 0x0F
			add			a, a
			add			a, a
			add			a, a
			add			a, a
			ld			[hl], a				; パーツ X座標 = (A & 15) << 4
			inc			hl
			ld			a, d
			and			a, 0xF0
			ld			[hl], a				; パーツ Y座標 = A & (15 << 4)
			inc			hl
			ld			[sprite_fifo_ptr], hl
			ld			a, [sprite_fifo_count]
			inc			a
			ld			[sprite_fifo_count], a
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_flash_fifo
;	input)
;		none
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		FIFO が空で無ければ、1個実行する
; -----------------------------------------------------------------------------
			scope		grp_flash_fifo
grp_flash_fifo::
			; VDPコマンドをチェック
			call		grp_check_vdp
			ret			nz								; VDPコマンド実行中なら何もしない
			; 消去用FIFOを確認する
			ld			a, [erase_fifo_current_count]
			or			a, a
			jp			z, draw_sprite					; Cy = 0 で draw_sprite へ
			; 消去用FIFOを1つ実行
			dec			a
			ld			[erase_fifo_current_count], a	; 数を減らす
			ld			hl, [erase_fifo_ptr]
			ld			e, [hl]							; 消去 X座標
			inc			hl
			ld			d, [hl]							; 消去 Y座標
			inc			hl
			ld			[erase_fifo_ptr], hl
			ld			a, [draw_page]
			call		_grp_erase_sprite
			; 消去FIFOの最後の1つだったか？
			ld			a, [erase_fifo_current_count]
			or			a, a
			ret			nz								; 最後の1つでは無かったので、戻る
			; 消去FIFOの最後の1つだったので、ポインタをリセットする
			ld			a, [draw_page]
			or			a, a
			jr			nz, reset_erase_fifo_ptr_for_page1
	reset_erase_fifo_ptr_for_page0:
			ld			hl, erase_fifo_page0
			ld			[erase_fifo_ptr], hl
			ret
	reset_erase_fifo_ptr_for_page1:
			ld			hl, erase_fifo_page1
			ld			[erase_fifo_ptr], hl
			ret
	draw_sprite:
			; 表示用FIFOを確認する
			ld			hl, [sprite_fifo_draw_ptr]
			ld			de, [sprite_fifo_ptr]
			push		hl
			sbc			hl, de
			pop			hl
			ret			z								; 表示用FIFOは空
			; 表示用FIFOから1つ取得
			ld			c, [hl]							; 表示 X座標
			inc			hl
			ld			b, [hl]							; 表示 Y座標
			inc			hl
			ld			e, [hl]							; パーツ X座標
			inc			hl
			ld			d, [hl]							; パーツ Y座標
			inc			hl
			ld			[sprite_fifo_draw_ptr], hl
			; 消去用FIFOへ1つ積む
			ld			hl, [erase_fifo_ptr]
			ld			[hl], c							; 消去 X座標
			inc			hl
			ld			[hl], b							; 消去 Y座標
			inc			hl
			ld			[erase_fifo_ptr], hl
			ld			a, [draw_page]
			jp			_grp_draw_sprite
			endscope

; -----------------------------------------------------------------------------
;	public grp_flash_all
;	input)
;		none
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		FIFO が空になるまで処理して、表示ページ・描画ページを入れ替え、
;		次のフレームのための準備をする
;		この API を呼んだ後は、grp_flip を呼ぶまで、他の grp API を呼んではならない。
; -----------------------------------------------------------------------------
			scope		grp_flash_all
grp_flash_all::
			; 消去用FIFOを確認する
			ld			a, [erase_fifo_current_count]
			or			a, a
			jr			z, draw_sprite					; erase_fifo_current_count = 0 で draw_sprite へ
	erase_loop:
			; 消去用FIFOを1つ実行
			dec			a
			ld			[erase_fifo_current_count], a	; 数を減らす
			ld			hl, [erase_fifo_ptr]
			ld			e, [hl]							; 消去 X座標
			inc			hl
			ld			d, [hl]							; 消去 Y座標
			inc			hl
			ld			[erase_fifo_ptr], hl
			ld			a, [draw_page]
			call		grp_wait_vdp
			call		_grp_erase_sprite
			ld			a, [erase_fifo_current_count]
			or			a, a
			jr			nz, erase_loop					; erase_fifo_current_count != 0 で erase_loop へ
			; 最後の1つを消去した
			ld			a, [draw_page]
			or			a, a
			jr			nz, reset_erase_fifo_ptr_for_page1
	reset_erase_fifo_ptr_for_page0:
			ld			hl, erase_fifo_page0
			ld			[erase_fifo_ptr], hl
			jr			draw_sprite
	reset_erase_fifo_ptr_for_page1:
			ld			hl, erase_fifo_page1
			ld			[erase_fifo_ptr], hl
	draw_sprite:
			; 表示用FIFOを確認する
			ld			hl, [sprite_fifo_draw_ptr]
			ld			de, [sprite_fifo_ptr]
			push		hl
			or			a, a
			sbc			hl, de
			pop			hl
			jr			z, _grp_prepare_next_frame		; 表示用FIFOは空
			; 表示用FIFOを1つ実行
			ld			c, [hl]							; 表示 X座標
			inc			hl
			ld			b, [hl]							; 表示 Y座標
			inc			hl
			ld			e, [hl]							; パーツ X座標
			inc			hl
			ld			d, [hl]							; パーツ Y座標
			inc			hl
			ld			[sprite_fifo_draw_ptr], hl
			ld			a, [draw_page]
			; 消去用FIFOへ1つ積む
			push		hl
			ld			hl, [erase_fifo_ptr]
			ld			[hl], c							; 消去 X座標
			inc			hl
			ld			[hl], b							; 消去 Y座標
			inc			hl
			ld			[erase_fifo_ptr], hl
			call		grp_wait_vdp
			call		_grp_draw_sprite
			pop			hl
			jp			draw_sprite
	_grp_prepare_next_frame::
			; erase_fifo の処理
			ld			a, [erase_fifo_next_count]
			ld			[erase_fifo_current_count], a
			ld			a, [sprite_fifo_count]
			ld			[erase_fifo_next_count], a
			xor			a, a
			ld			[sprite_fifo_count], a
			; draw_fifo の処理
			ld			hl, sprite_fifo
			ld			[sprite_fifo_ptr], hl
			ld			[sprite_fifo_draw_ptr], hl
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_flip
;	input)
;		none
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		VSYNC 待ちをして、表示ページと描画ページを入れ替える
;		この API を割り込み処理の中で呼んではならない
; -----------------------------------------------------------------------------
			scope		grp_flip
grp_flip::
			; VSYNC待ち
			ld			hl, jiffy
			ld			a, [hl]
			ei
	wait_loop:
			cp			a, [hl]
			jr			z, wait_loop
grp_flip_no_wait::
			; draw_page をスワップ
			ld			a, [draw_page]
			xor			a, 1
			ld			[draw_page], a
			jr			nz, next_frame_is_draw_page1
	next_frame_is_draw_page0:
			; erase FIFO を初期化する
			ld			hl, erase_fifo_page0
			ld			[erase_fifo_ptr], hl
			; 表示ページを 1 にする
			ld			a, 0b0_01_11111				; Display page = 1 : { 0, page, 11111 }
			di
			out			[vdp_port1], a
			ld			a, 0x80 | 2
			out			[vdp_port1], a
			ei
			ret
	next_frame_is_draw_page1:
			; erase FIFO を初期化する
			ld			hl, erase_fifo_page1
			ld			[erase_fifo_ptr], hl
			; 表示ページを 0 にする
			ld			a, 0b0_00_11111				; Display page = 0 : { 0, page, 11111 }
			di
			out			[vdp_port1], a
			ld			a, 0x80 | 2
			out			[vdp_port1], a
			ei
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_copy
;	input)
;		E ..... 転送元 X座標
;		D ..... 転送元 Y座標
;		L ..... 転送先 X座標
;		H ..... 転送先 Y座標
;		C ..... 転送水平サイズ(右方向)
;		B ..... 転送垂直サイズ(下方向)
;		A ..... [1:0] 転送元ページ、[3:2] 転送先ページ
;		HL .... 画像アドレス (128bytes)
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		grp_initialize前に実行可能
;		LMMM転送 (ドット単位だが遅い)
; -----------------------------------------------------------------------------
			scope		grp_copy
grp_copy::
			; VDP R#17 = R#32 (オートインクリメント)
			push		bc
			call		grp_wait_vdp
			ld			c, vdp_port1
			ld			b, 0x00 | 32
			di
			out			[c], b
			ld			b, 0x80 | 17
			out			[c], b
			; C = vdp_port3
			inc			c
			inc			c
			; VDP Command
			out			[c], e			; R#32 SX下位
			ld			e, 0
			out			[c], e			; R#33 SX上位
			out			[c], d			; R#34 SY下位
			ld			d, a
			and			a, 0b0000_0011
			out			[c], a			; R#35 SY上位, 転送元ページ
			out			[c], l			; R#36 DX下位
			out			[c], e			; R#37 DX上位
			out			[c], h			; R#38 DY下位
			ld			a, d
			srl			a
			srl			a
			out			[c], a			; R#39 DY上位, 転送先ページ
			pop			hl
			out			[c], l			; R#40 NX下位
			ld			d, e
			inc			l
			dec			l
			jr			nz, skip_inc
			inc			d
		skip_inc:
			out			[c], d			; R#41 NX上位
			out			[c], h			; R#42 NY下位
			out			[c], e			; R#43 NY上位
			out			[c], e			; R#44 CLR
			out			[c], e			; R#45 ARG
			ld			a, 0b1001_0000	; LMMM, IMP
			out			[c], a			; R#46 CMD
			ei
			ret
			endscope

; -----------------------------------------------------------------------------
;	public grp_copy_hs
;	input)
;		E ..... 転送元 X座標 (偶数のみ)
;		D ..... 転送元 Y座標
;		L ..... 転送先 X座標 (偶数のみ)
;		H ..... 転送先 Y座標
;		C ..... 転送水平サイズ(右方向) (偶数のみ)
;		B ..... 転送垂直サイズ(下方向)
;		A ..... [1:0] 転送元ページ、[3:2] 転送先ページ
;		HL .... 画像アドレス (128bytes)
;	output)
;		none
;	break)
;		AF, BC, DE, HL
;	description)
;		grp_initialize前に実行可能
;		HMMM転送 (X偶数単位だが速い)
; -----------------------------------------------------------------------------
			scope		grp_copy_hs
grp_copy_hs::
			; VDP R#17 = R#32 (オートインクリメント)
			push		bc
			call		grp_wait_vdp
			ld			c, vdp_port1
			ld			b, 0x00 | 32
			di
			out			[c], b
			ld			b, 0x80 | 17
			out			[c], b
			; C = vdp_port3
			inc			c
			inc			c
			; VDP Command
			out			[c], e			; R#32 SX下位
			ld			e, 0
			out			[c], e			; R#33 SX上位
			out			[c], d			; R#34 SY下位
			ld			d, a
			and			a, 0b0000_0011
			out			[c], a			; R#35 SY上位, 転送元ページ
			out			[c], l			; R#36 DX下位
			out			[c], e			; R#37 DX上位
			out			[c], h			; R#38 DY下位
			ld			a, d
			srl			a
			srl			a
			out			[c], a			; R#39 DY上位, 転送先ページ
			pop			hl
			out			[c], l			; R#40 NX下位
			ld			d, e
			inc			l
			dec			l
			jr			nz, skip_inc
			inc			d
		skip_inc:
			out			[c], d			; R#41 NX上位
			out			[c], h			; R#42 NY下位
			out			[c], e			; R#43 NY上位
			out			[c], e			; R#44 CLR
			out			[c], e			; R#45 ARG
			ld			a, 0b1101_0000	; HMMM
			out			[c], a			; R#46 CMD
			ei
			ret
			endscope
