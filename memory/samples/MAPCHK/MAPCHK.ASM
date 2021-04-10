; =============================================================================
;  MemoryMapper 動作確認
;
;	DOS2/Nextorが必要です。
; =============================================================================

		include		"msxbios.asm"
		include		"msxdos1.asm"
		include		"msxdos2.asm"

		org		0x100

entry::
		; 起動メッセージ
		ld			de, msg_entry
		call		puts

		; スロット番号を取得する(コマンドライン引数)
		call		get_slot_num
		ld			[slot_num], a
		call		dec2hex
		ld			de, msg_crlf
		call		puts

		; 初期化
		ld			sp, [TPA_BOTTOM]
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

		; 全セグメントの先頭番地の内容をバックアップしつつ、先頭番地をセグメント番号にする
		xor			a, a
		ld			hl, segment_backup_area + 255
segment_backup_loop::
		dec			a
		push		af
		call		mapper_put_p2
		ld			a, [0x8000]
		ld			[hl], a
		pop			af
		ld			[0x8000], a
		dec			hl
		or			a, a
		jp			nz, segment_backup_loop

		; セグメント番号 0～255 の先頭番地を読み出す
		ld			hl, read_back_area
		xor			a, a
read_back_loop::
		push		af
		call		mapper_put_p2
		ld			a, [0x8000]
		ld			[hl], a
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
		ld			[0x8000], a
		pop			af
		inc			hl
		inc			a
		jp			nz, segment_restore_loop

		; Page2 を元に戻して割り込み許可
		ld			a, [ramad2]
		ld			h, 0x80
		call		enaslt

		ld			a, [page2_segment]
		call		mapper_put_p2
		ei

		; 読み出した値をダンプする
		ld			b, 16
		ld			hl, read_back_area
dump_loop_y::
		push		bc
		ld			b, 16
dump_loop_x::
		push		bc
		ld			a, [hl]
		inc			hl
		push		hl
		call		dec2hex
		pop			hl
		pop			bc
		djnz		dump_loop_x

		push		hl
		ld			hl, msg_crlf
		call		puts
		pop			hl
		pop			bc
		djnz		dump_loop_y

exit_loop::
		ld			b, 0
		ld			c, D2F_TERM
		jp			bdos

; =============================================================================
;	Get slot number
; =============================================================================
		scope get_slot_num
get_slot_num::
		ld			hl, 0x0081
skip_white_space::
		ld			a, [hl]
		inc			hl
		cp			a, ' ' + 1
		jp			c, skip_white_space

		or			a, a
		ret			z

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
;	Data area
; =============================================================================
msg_crlf::
		db			0x0D, 0x0A, 0
msg_entry::
		ds			"MemoryMapper Test Program\r\n"
		ds			"================================\r\n"
		ds			"Programmed by HRA!\r\n"
		ds			"SLOT#"
		db			0

page2_segment::
		db			1
segment_backup_area:
		space		256
read_back_area:
		space		256

; =============================================================================
;	Subroutines
; =============================================================================
		include		"stdio.asm"
		include		"memmapper.asm"
