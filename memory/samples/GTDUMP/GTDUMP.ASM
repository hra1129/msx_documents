; =============================================================================
;	FS-A1GT の Panasonic MegaROM/MemoryMapper を調査するプログラム
;
;	Programmed by t.hara in Feb./14th/2021
; =============================================================================

		include		"msxbios.asm"
		include		"msxdos1.asm"
		include		"msxdos2.asm"

PanaBank2	:= 0x6800
PanaBank3	:= 0x7C00
PanaBankMsb	:= 0x7FF8
PanaMode	:= 0x7FF9

		org		0x100

entry::
		; 初期化
		ld			sp, [TPA_BOTTOM]

		; 起動メッセージ
		ld			de, msg_entry
		call		puts

		; メモリーマッパーサポートルーチン取得 (絶対に存在する)
		call		mmap_init

		; Page1 を PanaMegaROM (Slot#3-3) に切り替える
		ld			a, 0x8F
		ld			h, 0x40
		call		enaslt					; DI

		; PanaMegaROM を設定
		ld			a, 0x1C
		ld			[PanaMode], a

		; メモリーマッパーの全セグメントの先頭にセグメント番号を書き込む
		scope		mapper_initialize
		xor			a, a
		ld			b, a
		ld			hl, 0x8000
		ld			de, mapper_segment_top_address_backup + 255
loop1:
		dec			b
		ld			a, b
		call		mapper_put_p2
		ld			a, [hl]
		ld			[de], a				; 元の値を保存しておく
		ld			[hl], b				; セグメント番号を書き込む
		dec			de
		ld			a, b
		or			a, a
		jp			nz, loop1
		endscope

		; Pana MegaROM Bank#0-511 の種類を調べ、結果を pana_mega_bank_info に格納する
		xor			a, a
		ld			[PanaBankMsb], a
		ld			de, pana_mega_bank_info
		call		check_rom_or_ram

		ld			a, 0xFF
		ld			[PanaBankMsb], a
		call		check_rom_or_ram

		xor			a, a
		ld			[PanaBankMsb], a

		; メモリーマッパーの全セグメントの先頭を復元する
		scope		mapper_restore
		ld			b, 0
		ld			hl, 0x8000
		ld			de, mapper_segment_top_address_backup
loop1:
		ld			a, b
		call		mapper_put_p2
		ld			a, [de]
		ld			[hl], a				; 元の値を書き戻す
		inc			de
		inc			b
		jp			nz, loop1

		ld			a, 1
		call		mapper_put_p2		; TPA に戻す
		endscope

		; Page1 を Slot#3-0 に切り替える
		ld			a, 0x83
		ld			h, 0x40
		call		enaslt

		; PanaMegaROM の全バンクをファイルに書き出す
		scope		rom_dump
;		xor			a, a					; オープンモード ノーマル
;		ld			b, a
;		ld			de, file_name_rom_dump
;		ld			c, D2F_CREATE
;		call		bdos
;		or			a, a
;		jp			nz, error_exit
;		ld			a, b
;		ld			[file_handle], a
;
;		xor			a, a
;		call		save_banks
;
;		ld			a, 0xFF
;		call		save_banks
;
;		ld			a, [file_handle]
;		ld			b, a
;		ld			c, D2F_CLOSE
;		call		bdos

		; Page1 を Slot#3-0 に切り替える
		ld			a, 0x83
		ld			h, 0x40
		call		enaslt

		; バンク情報をファイルへ書き出す
		xor			a, a					; オープンモード ノーマル
		ld			b, a
		ld			de, file_name_rom_info
		ld			c, D2F_CREATE
		call		bdos
		or			a, a
		jp			nz, error_exit
		ld			a, b
		ld			[file_handle], a

		ld			a, [file_handle]
		ld			b, a
		ld			c, D2F_WRITE
		ld			hl, 512
		ld			de, pana_mega_bank_info
		call		bdos

		ld			a, [file_handle]
		ld			b, a
		ld			c, D2F_CLOSE
		call		bdos
		endscope

		ld			de, msg_complete
		call		puts
		jp			exit_program

error_exit::
		ld			de, msg_error
		call		puts

exit_program::
		ei
		ld			b, 0
		ld			c, D2F_TERM
		jp			bdos

; =============================================================================
;	Bank#0-#255 をファイルに書き出す
; =============================================================================
		scope		save_banks
save_banks::
		; Page1 を Slot#3-3 に切り替える
		push		af
		ld			a, 0x8F
		ld			h, 0x40
		call		enaslt
		pop			af

		; MegaROMバンクレジスタの MSB をセットする
		ld			[PanaBankMsb], a

		xor			a, a					; Bank#0
loop1:
		; Page1 を Slot#3-3 に切り替える
		push		af
		ld			a, 0x8F
		ld			h, 0x40
		call		enaslt
		pop			af

		ld			[PanaBank2], a
		push		af

		ld			hl, 0x4000
		ld			de, save_buffer
		ld			bc, 8192
		ldir

		; Page1 を Slot#3-0 に切り替える
		ld			a, 0x83
		ld			h, 0x40
		call		enaslt

		ld			a, [file_handle]
		ld			b, a
		ld			c, D2F_WRITE
		ld			hl, 8192
		ld			de, save_buffer
		call		bdos

		ld			c, D1F_DIRIO
		ld			e, '*'
		call		bdos

		pop			af
		inc			a
		jp			nz, loop1

		ld			de, msg_crlf
		call		puts
		ret
		endscope

; =============================================================================
;	Check ROM or RAM
; =============================================================================
		; PanaMegaROM の Bank4 を使って Bank#0-#255 or Bank#256-#511 が ROM か RAM か調べる
		scope		check_rom_or_ram
check_rom_or_ram::
		xor			a, a
		ld			hl, 0x4000
		ld			c, 0x30						; 直前のBankの属性
loop1:
		ld			[PanaBank2], a
		push		af

		; 奇数Bank# で、かつ 直前が MapperRAM なら MapperRAM
		and			a, 1
		jp			z, skip0
		ld			a, c
		jp			this_bank_is_mmap

skip0:
		; -- ROM or RAM ?
		ld			a, [hl]
		cpl
		ld			[hl], a
		cp			a, [hl]
		cpl
		ld			[hl], a
		jp			nz, this_bank_is_rom		; 書き込めなかった場合は ROM or HiZ で確定

		; -- RAM or Mapper
		; -- 試しに Page2 を seg#A に変えて適当な値を書き込んで、連動して変わるか確認する
		call		mapper_put_p2
		ld			b, a
		ld			a, 0xAA
		ld			[0x8000], a
		cp			a, [hl]
		ld			a, b
		ld			[0x8000], a
		jp			nz, this_bank_is_sram

this_bank_is_mmap:
		ld			[de], a
		jp			skip1

this_bank_is_rom:
		ld			a, 0x30		; ROM or HiZ
		ld			[de], a
		jp			skip1

this_bank_is_sram:
		ld			a, 0x20		; SRAM
		ld			[de], a
		jp			skip1

skip1:
		ld			c, a
		pop			af
		inc			de
		inc			a
		jp			nz, loop1
		ret
		endscope

; =============================================================================
;	Data area
; =============================================================================
file_name_rom_dump::
		ds			"A1GTFIRM.BIN"
		db			0
file_name_rom_info::
		ds			"A1GTINFO.BIN"
		db			0
file_handle::
		db			0
mapper_segment_top_address_backup::
		space		256
pana_mega_bank_info::
		space		512			; 0x00-0xFF : MemoryMapperRAM
								; 0x20      : SRAM
								; 0x30      : ROM or HiZ
save_buffer::
		space		8192

msg_entry::
		ds			"FS-A1GT dumper Programmed by HRA! 2021\r\n"
		db			0
msg_crlf::
		db			0x0D, 0x0A, 0
msg_complete::
		ds			"Success.\r\n"
		db			0
msg_error::
		ds			"Error.\r\n"
		db			0

; =============================================================================
;	Subroutines
; =============================================================================
		include		"stdio.asm"
		include		"memmapper.asm"
