; =============================================================================
;  MemoryMapper 動作確認
;
;	DOS2/Nextorが必要です。
; =============================================================================

		include		"msxbios.asm"
		include		"msxdos1.asm"
		include		"msxdos2.asm"

		; チェックのために一時的に書き替えるアドレス (page2 4000h-BFFFh 範囲内)
		;   このプログラム自身が置かれているセグメントや、BIOSワークエリアのセグメント
		;   スタックポインタが指しているセグメントも対象となる場合があるため、
		;   チェック時に破壊しても問題ないアドレスにしなければならない。
		;
check_address	:= 0x8000

		org		0x100

entry::
		; 起動メッセージ
		ld			de, msg_entry
		call		puts

		; スロット番号を取得する(コマンドライン引数)
		call		get_slot_num
		ld			[slot_num], a
		or			a, a
		jp			z, check_all_slot					; 引数に何も指定されていなければ全スロット調べる
		; 指定のスロットを調べる場合
		call		check_slot
		jp			exit_to_dos
		; 全スロットを調べる場合
check_all_slot::
		push		af
		; 基本スロット A は拡張されているか？
		ld			b, a
		add			a, exptbl & 0x0FF
		ld			l, a
		ld			h, exptbl >> 8
		ld			a, [hl]
		and			a, 0x80
		jr			z, not_expand
		; 拡張されている場合
		or			a, b
expand:
		ld			[slot_num], a
		call		check_slot
		ld			a, [slot_num]
		add			a, 0x04
		bit			4, a
		jr			z, expand
		jr			skip_check_all_slot
not_expand:
		; 拡張されていない場合
		ld			a, b
		ld			[slot_num], a
		call		check_slot
skip_check_all_slot::
		pop			af
		inc			a
		bit			2, a
		jp			z, check_all_slot
exit_to_dos::
		ld			b, 0
		ld			c, D2F_TERM
		jp			bdos

; =============================================================================
;	check_slot
;	input)
;		[slot_num] ..... target slot
; =============================================================================
		scope		check_slot
		; slot_num のスロットを調べる
check_slot::
		ld			de, msg_slot
		call		puts
		call		put_slot_num

		; 初期化
		call		mmap_init
		ret			z

		; Page2 のセグメント番号を保存
		call		mapper_get_p2
		ld			[page2_segment], a

		; Page2 を Slot#X に切り替えて割り込み禁止にする
slot_num := $ + 1
		ld			a, 0x01
		ld			h, 0x80
		call		enaslt

		; ROMかチェックする
		di
		call		check_rom
		ei
		jr			z, is_ram
		ld			de, msg_is_not_mapper
		call		puts
		; ROMの場合、ここで戻る
		ld			a, [ramad2]
		ld			h, 0x80
		call		enaslt
		ei
		ret
is_ram:
		; 全セグメントの check_address の内容をバックアップする
		di
		xor			a, a
		ld			hl, segment_backup_area + 255
segment_backup_loop::
		dec			a
		push		af
		call		mapper_put_p2
		ld			a, [check_address]
		ld			[hl], a
		pop			af
		ld			[check_address], a
		dec			hl
		or			a, a
		jp			nz, segment_backup_loop

		; セグメント番号 0～255 の先頭番地を読み出す
		ld			hl, read_back_area
		xor			a, a
read_back_loop::
		push		af
		call		mapper_put_p2
		ld			a, [check_address]
		ld			[hl], a
		; ROM かどうか調べる
		call		check_rom
		jr			z, segment_backup_skip
rom_segment:
		ld			[hl], 0						; ROM なら read結果を強制的に 0 にする
segment_backup_skip:
		pop			af
		inc			hl
		inc			a
		jp			nz, read_back_loop

		; セグメント番号 0～255 の先頭番地を復元する
		xor			a, a
		ld			hl, segment_backup_area
segment_restore_loop::
		push		af
		call		mapper_put_p2
		ld			a, [hl]
		ld			[check_address], a
		pop			af
		inc			hl
		inc			a
		jp			nz, segment_restore_loop

		; セグメントを元に戻す
		ld			a, [page2_segment]
		call		mapper_put_p2

		; Page2 を元に戻して割り込み許可
		ld			a, [ramad2]
		ld			h, 0x80
		call		enaslt
		ei

		; 読みだした値の中で最も大きな値を調べる
		ld			hl, read_back_area
		xor			a, a
		ld			b, a
check_loop:
		ld			c, [hl]
		inc			hl
		cp			a, c
		jr			nc, skip_check_loop
		ld			a, c
skip_check_loop:
		djnz		check_loop
		; 0 なら Mapper でない RAM
		or			a, a
		ld			de, msg_no_mapper_ram
		jp			z, puts
		; Mapper のサイズを計算する
		ld			l, a
		ld			h, 0
		inc			hl
		add			hl, hl
		add			hl, hl
		add			hl, hl
		add			hl, hl
		call		puts_digit
		ld			de, msg_kb
		jp			puts
		endscope

; =============================================================================
;	check_rom
;	input)
;		Is 8000-BFFFh ROM?
;	output)
;		Zf = 0: ROM
;		Zf = 1: 
; =============================================================================
		scope		check_rom
check_rom::
		push		hl
		ld			hl, check_address
		ld			a, [hl]
		cpl
		ld			[hl], a
		cp			a, [hl]
		jr			nz, exit
		cpl
		ld			[hl], a
exit:
		pop			hl
		ret
		endscope

; =============================================================================
;	Get slot number
; =============================================================================
		scope get_slot_num
get_slot_num::
		ld			hl, 0x0081
skip_white_space::
		ld			a, [hl]
		inc			hl

		or			a, a
		ret			z

		cp			a, ' ' + 1
		jp			c, skip_white_space

		call		isxdigit
		jp			c, skip_white_space

		call		get_digit
		ld			b, a

		ld			a, [hl]
		call		isxdigit
		ret			c

		call		get_digit
		rlca
		rlca
		rlca
		rlca
		or			a, b

		rlca
		rlca
		rlca
		rlca
		ret
		endscope

; =============================================================================
;	isxdigit
;	input)
;		a ..... target char
;	output)
;		Cf .... 0: match, 1: no match
; =============================================================================
		scope		isxdigit
isxdigit::
		cp			a, '0'
		ret			c
		cp			a, '9'
		ccf
		ret			nc

		cp			a, 'a'
		ret			c
		cp			a, 'z'
		ccf
		ret			nc

		cp			a, 'A'
		ret			c
		cp			a, 'Z'
		ccf
		ret
		endscope

; =============================================================================
;	get_digit
;	input)
;		a ..... target char
;	output)
;		a ..... number
; =============================================================================
		scope		get_digit
get_digit::
		or			a, 0x20
		sub			a, '0'
		cp			a, 10
		ret			c
		sub			a, 'a' - '0' - 10
		ret
		endscope

; =============================================================================
;	Dump A register value by slot number
;	input)
;		a ..... target number
; =============================================================================
		scope		put_slot_num
put_slot_num::
		; 基本スロット番号を表示
		ld			a, [slot_num]
		and			a, 0x03
		add			a, '0'
		ld			e, a
		ld			c, D1F_CONOUT
		call		bdos
		; 拡張されているかチェック
		ld			a, [slot_num]
		or			a, a
		jp			m, put_expand_slot
		; 拡張されていないので "  :" を表示
		ld			de, msg_space
		call		puts
		ret
put_expand_slot:
		; 拡張されているので "-N:" を表示
		ld			e, '-'
		ld			c, D1F_CONOUT
		call		bdos
		ld			a, [slot_num]
		rrca
		rrca
		and			a, 0x03
		add			a, '0'
		ld			e, a
		ld			c, D1F_CONOUT
		call		bdos
		ld			e, ':'
		ld			c, D1F_CONOUT
		call		bdos
		ret
		endscope

; =============================================================================
;	Dump A register value by hex
;	input)
;		a ..... target number
; =============================================================================
		scope		dec2hex
dec2hex::
		ld			b, a
		rrca
		rrca
		rrca
		rrca
		and			a, 0x0F
		add			a, '0'
		cp			a, '9' + 1
		jr			c, skip1
		add			a, 'A' - '0' - 10
skip1:
		ld			[hex2byte], a
		ld			a, b
		and			a, 0x0F
		add			a, '0'
		cp			a, '9' + 1
		jr			c, skip2
		add			a, 'A' - '0' - 10
skip2:
		ld			[hex2byte + 1], a
		ld			de, hex2byte
		call		puts
		ret
hex2byte::
		ds			"00 "
		db			0
		endscope

; =============================================================================
;	Dump HL register value
;	input)
;		hl ..... target number
; =============================================================================
		scope		puts_digit
puts_digit::
		ld			b, 0
		ld			de, 10000
		call		puts_digit_1
		ld			de, 1000
		call		puts_digit_1
		ld			de, 100
		call		puts_digit_1
		ld			de, 10
		call		puts_digit_1
		ld			de, 1
		call		puts_digit_1
		ret
puts_digit_1:
		ld			a, '0'
put_digit_1_loop:
		or			a, a
		sbc			hl, de
		jr			c, put_digit_1_skip
		inc			a
		jr			put_digit_1_loop
put_digit_1_skip:
		add			hl, de
		cp			a, '0'
		jr			nz, put_digit_1_char
		inc			b
		dec			b
		ret			z
put_digit_1_char:
		inc			b
		push		hl
		push		bc
		ld			e, a
		ld			c, D1F_CONOUT
		call		bdos
		pop			bc
		pop			hl
		ret
		endscope

; =============================================================================
;	Data area
; =============================================================================
msg_crlf::
		db			0x0D, 0x0A, 0
msg_entry::
		ds			"MemoryMapper Test Program\r\n"
		ds			"================================\r\n"
		ds			"Programmed by HRA!\r\n"
		db			0
msg_slot::
		ds			"SLOT#"
		db			0
msg_space:
		ds			"  :"
		db			0
msg_is_not_mapper:
		ds			"----"
		db			13, 10, 0
msg_no_mapper_ram:
		ds			"RAM (No Mapper)"
		db			13, 10, 0
msg_kb:
		ds			"KB MapperRAM"
		db			13, 10, 0
page2_segment::
		db			1
segment_count::
		db			0
segment_backup_area:
		space		256
read_back_area:
		space		256

; =============================================================================
;	Subroutines
; =============================================================================
		include		"stdio.asm"
		include		"memmapper.asm"
