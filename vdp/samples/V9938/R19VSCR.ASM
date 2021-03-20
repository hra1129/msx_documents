; ---------------------------------------------------------------------
;	R#19 sample program
; =====================================================================
;	2020/04/01	t.hara
; ---------------------------------------------------------------------

RG0SAV			= 0xF3DF
H_KEYI			= 0xFD9A
H_TIMI			= 0xFD9F
VDP_IO_PORT0	= 0x98
VDP_IO_PORT1	= 0x99
PAGE0_PALTBL	= 0x7680
PAGE1_PALTBL	= 0xF680
LINE_NO			= 106			; 水平帰線割込を発生させるライン番号

	; BSAVE file header
	db		0xFE
	dw		start_address, end_address, start_address

; ---------------------------------------------------------------------
; entry point
; ---------------------------------------------------------------------
	org		0xC000
start_address::
	call	initialize
main_loop::
	nop
	jp		main_loop

; ---------------------------------------------------------------------
; 読みだし用に VRAMアドレスをセットする
; input)
;	HL ... VRAMアドレス
;	DE ... 読み出した値を格納するDRAMアドレス
;	B .... 読み出すバイト数
; output)
;	無し
; break)
;	AF, BC
; ---------------------------------------------------------------------
read_vram_block::
	; VRAMアドレス設定
	ld		c, VDP_IO_PORT1
	ld		a, h
	rlca
	rlca
	and		a, 0x03
	out		[c], a
	ld		a, 14 | 0x80
	out		[c], a		; R#14 ← [0, 0, 0, 0, 0, A16=0, A15, A14]
	ld		a, h
	out		[c], l		; Port#1 ← [A7, A6, ... , A1, A0]
	and		a, 0x3F
	out		[c], a		; Port#1 ← [0, 0, A13, A12, ... , A8]

	; 読み出す
	ex		de, hl
	dec		c
	inir
	ret

; ---------------------------------------------------------------------
; 割込フックの初期化と水平帰線割込の許可
; input)
;	無し
; output)
;	無し
; break)
;	AF, BC, DE, HL
; comment)
;	2回呼んではいけません。
; ---------------------------------------------------------------------
initialize::
	di
	; H.KEYI をバックアップ
	ld		hl, H_KEYI
	ld		de, previous_hkeyi_hook
	ld		bc, 5
	ldir

	; H.TIMI をバックアップ
	ld		hl, H_TIMI
	ld		de, previous_htimi_hook
	ld		bc, 5
	ldir

	; このプログラムの H.KEYI処理ルーチンへのジャンプ命令を H.KEYI に書き込む
	ld		hl, hkeyi_routine_entry	; H_KEYI書き換えてる途中で割り込まないように割禁維持
	ld		[ H_KEYI + 1 ], hl
	ld		a, 0xC3
	ld		[ H_KEYI ], a			; H_KEYI には JP hkeyi_routine_entry を書く

	; このプログラムの H.TIMI処理ルーチンへのジャンプ命令を H.TIMI に書き込む
	ld		hl, htimi_routine_entry	; H_KEYI書き換えてる途中で割り込まないように割禁維持
	ld		[ H_TIMI + 1 ], hl
	ld		a, 0xC3
	ld		[ H_TIMI ], a			; H_KEYI には JP hkeyi_routine_entry を書く

	; R#19 に LINE_NO をセットする
	ld		c, VDP_IO_PORT1
	ld		a, LINE_NO
	out		[c], a
	ld		a, 19 | 0x80
	out		[c], a

	; R#0 の IE1:bit4 を 1 にする
	ld		a, [ RG0SAV ]			; BIOS が R#0 に書き込んだ内容が保存されているワーク
	or		a, 1 << 4				; bit4 を 1 にする
	out		[c], a
	ld		a, 0 | 0x80
	out		[c], a					; R#0 に求めた値を書き込む

	; VRAM上の Palette Table を読み出してワークエリアにコピーする
	ld		hl, PAGE0_PALTBL
	ld		de, page0_color_palette
	ld		b, 32
	call	read_vram_block

	ld		hl, PAGE1_PALTBL
	ld		de, page1_color_palette
	ld		b, 32
	call	read_vram_block

	ei								; 書き換え完了したので割込許可
	ret

; ---------------------------------------------------------------------
; H.TIMI割込処理ルーチン (垂直帰線割込用)
; input)
;	 無し
; output)
;	 無し
; break)
;	 全レジスタ
; ---------------------------------------------------------------------
htimi_routine_entry::
	; 垂直スクロールレジスタ(R#23)へ 0 を設定する
	ld		c, VDP_IO_PORT1
	xor		a, a
	out		[c], a
	ld		a, 23 | 0x80
	out		[c], a

	; 水平帰線割込を ON にする
	ld		a, LINE_NO
	out		[c], a
	ld		a, 19 | 0x80
	out		[c], a

	; 表示ページを 0 に切り替える (Pattern Name Table を 0x00000 にする: R#2 ← 0x1F)
	ld		a, 0x1F						; [0, A16=0, A15=0, 1, 1, 1, 1, 1]
	out		[c], a
	ld		a, 2 | 0x80
	out		[c], a

	; Page0 のパレットをセットする
	xor		a, a
	out		[c], a
	ld		a, 16 | 0x80
	out		[c], a

	inc		c
	ld		b, 32
	ld		hl, page0_color_palette
	otir

	; 前の H.TIMI の処理 (0xC9 は ret命令)
previous_htimi_hook::
	db		0xC9, 0xC9, 0xC9, 0xC9, 0xC9

; ---------------------------------------------------------------------
; H.KEYI割込処理ルーチン (水平帰線割込用)
; input)
;	 無し
; output)
;	 無し
; break)
;	 全レジスタ
; ---------------------------------------------------------------------
hkeyi_routine_entry::
	; S#1 を読む, 割禁状態で来るので割禁にする必要なし
	ld		c, VDP_IO_PORT1
	ld		a, 1
	out		[c], a
	ld		a, 15 | 0x80
	out		[c], a						; R#15 ← 1
	in		a, [c]						; a ← S#1

	; 水平帰線割込かどうか調べる
	and		a, 0x01
	jp		z, finalize					; 水平帰線割込でなければ前の hook へ飛ぶ

	; 垂直スクロールレジスタへ設定する値を更新する
	ld		a, [vertical_scroll]
	inc		a
	ld		[vertical_scroll], a

	; 垂直スクロールレジスタ(R#23)に設定する
	out		[c], a
	ld		a, 23 | 0x80
	out		[c], a						; R#23 ← vertical_scroll

	; 垂直スクロールの影響で、即座に水平帰線割込が入ってしまわないように R#19 をずらしておく
	ld		a, [vertical_scroll]
	out		[c], a
	ld		a, 19 | 0x80
	out		[c], a

	; R#23を変更してから R#19 の変更を終えるまでの間に 次の水平帰線割込が発生してしまう
	; ラインがあるので、それをキャンセルするために S#1 を空読み
	in		a, [c]						; a ← S#1

	; 表示ページを 1 に切り替える (Pattern Name Table を 0x08000 にする: R#2 ← 0x3F)
	ld		a, 0x3F						; [0, A16=0, A15=1, 1, 1, 1, 1, 1]
	out		[c], a
	ld		a, 2 | 0x80
	out		[c], a

	; Page0 のパレットをセットする
	xor		a, a
	out		[c], a
	ld		a, 16 | 0x80
	out		[c], a

	inc		c
	ld		b, 32
	ld		hl, page1_color_palette
	otir
	dec		c

	; R#15 を S#0 を指すように戻す
finalize::
	xor		a, a
	out		[c], a
	ld		a, 15 | 0x80				; R#15 ← 0
	out		[c], a

	; 前の H.KEYI の処理 (0xC9 は ret命令)
previous_hkeyi_hook::
	db		0xC9, 0xC9, 0xC9, 0xC9, 0xC9

; ---------------------------------------------------------------------
; ワークエリア
; ---------------------------------------------------------------------
vertical_scroll::
	db		0
page0_color_palette::
	ds		" "*32						; 32byte の領域を確保
page1_color_palette::
	ds		" "*32						; 32byte の領域を確保
end_address::
