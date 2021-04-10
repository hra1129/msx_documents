; =============================================================================
;  Memory Mapper の情報をダンプするプログラム
; =============================================================================

		include		"msxbios.asm"
		include		"msxdos1.asm"
		include		"msxdos2.asm"

		org		0x100

entry::
		; 初期化
		ld			sp, [TPA_BOTTOM]
		call		mmap_init

		; 起動メッセージ
		ld			de, msg_entry
		call		puts

		; マッパーチェック
		ld			ix, [mmap_table_ptr]
		xor			a, a
mapper_check_loop::
		call		dump_one
		jr			c, exit_loop
		ld			de, 8
		add			ix, de
		jr			mapper_check_loop
exit_loop::
		ld			b, 0
		ld			c, D2F_TERM
		jp			bdos

; =============================================================================
;	Dump a mapper information
;	input)
;		ix .... target mapper table
;		a ..... 0: primary mapper, others: not primary mapper
;	break)
;		a ..... a + 1
; =============================================================================
		scope		dump_one
dump_one::
		; 終了チェック
		ld			b, [ix + 0]
		inc			b
		dec			b
		scf
		ret			z

		push		af
		ld			de, msg_separator
		call		puts

		ld			a, [ix + 0]		; slot number
		call		dec2hex

		pop			af
		push		af
		ld			de, msg_primary_mapper_mark
		or			a, a
		call		z, puts
		ld			de, msg_crlf
		call		puts

		ld			de, msg_total
		call		puts
		ld			a, [ix + 1]		; total segments
		call		dec2hex
		ld			de, msg_crlf
		call		puts

		ld			de, msg_free
		call		puts
		ld			a, [ix + 2]		; free segments
		call		dec2hex
		ld			de, msg_crlf
		call		puts

		ld			de, msg_system
		call		puts
		ld			a, [ix + 3]		; system segments
		call		dec2hex
		ld			de, msg_crlf
		call		puts

		ld			de, msg_user
		call		puts
		ld			a, [ix + 4]		; user segments
		call		dec2hex
		ld			de, msg_crlf
		call		puts
		pop			af
		or			a, a			; Cy = 0
		inc			a
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
		ds			"00"
		db			0
		endscope

; =============================================================================
;	Data area
; =============================================================================
msg_total::
		ds			"Total Seg. 0x"
		db			0
msg_free::
		ds			"Free Seg.  0x"
		db			0
msg_system::
		ds			"System Seg.0x"
		db			0
msg_user::
		ds			"User Seg.  0x"
		db			0
msg_not_enough_memory::
		ds			"Not enough memory!!"
msg_crlf::
		db			0x0D, 0x0A, 0
msg_separator::
		ds			"================================"
		db			0x0D, 0x0A
msg_slot::
		ds			"Slot       0x"
		db			0
msg_primary_mapper_mark::
		ds			" (Primary)"
		db			0
msg_entry::
		ds			"MemoryMapperInformation"
		db			0x0D, 0x0A
		ds			"================================"
		db			0x0D, 0x0A
		ds			"Programmed by HRA!"
		db			0x0D, 0x0A
		db			0x0D, 0x0A, 0

		include		"stdio.asm"
		include		"memmapper.asm"
