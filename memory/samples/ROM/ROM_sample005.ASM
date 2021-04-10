; =============================================================================
;	ROM_sample005.ASM   [RAM 32KB required]
; -----------------------------------------------------------------------------
;	Feb./3/2020 HRA!
; =============================================================================

enaslt		= 0x0024
chget		= 0x009F
chput		= 0x00A2
himem		= 0xFC4A
exptbl		= 0xFCC1

		org			0x4000
; ==============================================================================
;	ROM Header
; ==============================================================================
rom_header_id:
		ds			"AB"
rom_header_init:
		dw			entry_point
rom_header_statement:
		dw			0
rom_header_device:
		dw			0
rom_header_text:
		dw			0
rom_header_reserved:
		space		0x0010 - 0x000A, 0

; ==============================================================================
;	Program entry point
; ==============================================================================
entry_point:
		; Initialize Stack Pointer
		ld			hl, 0xC000
		ld			sp, hl

		call		get_page3_slot
		ld			[p3_ram_slot], a

		ld			hl, exptbl
		ld			de, exptbl_copy
		ld			bc, 4
		ldir

main_loop:
		call		check_page0
		ld			hl, message_page0
		call		display_slot_info
		call		press_enter_key

		call		check_page3
		ld			hl, message_page3
		call		display_slot_info
		call		press_enter_key

		jp			main_loop

press_enter_key:
		ld			hl, message_press_enter_key
		call		puts
		call		chget
		ret

; ==============================================================================
;	clear_slot_info
; ==============================================================================
		scope clear_slot_info
clear_slot_info::
		ld			hl, slot_info
		ld			de, slot_info + 1
		ld			bc, 16 - 1
		xor			a, a
		ld			[hl], a
		ldir
		ret
		endscope

; ==============================================================================
;	check_page0
; ==============================================================================
		scope check_page0
check_page0::
		call		clear_slot_info		; B = 0
		ld			hl, exptbl
		ld			de, slot_info
slot_loop:
		ld			a, [hl]
		and			a, 0x80
		or			a, b
exp_slot_loop:
		ld			c, a
		push		bc
		push		hl
		push		de
		call		local_enaslt0
		pop			de

		; RAM check
		ld			hl, 0x0000
check_ram_loop:
		ld			a, 1
		bit			6, h
		jp			nz, check_ram_exit
		ld			a, [hl]
		cpl
		ld			[hl], a
		cp			a, [hl]
		cpl
		ld			[hl], a
		inc			hl
		jp			z, check_ram_loop
		ld			a, 2
check_ram_exit:
		pop			hl
		pop			bc

		ld			[de], a
		inc			de
		ld			a, c
		add			a, 0x04
		jp			p, not_expanded
		bit			4, a
		jp			z, exp_slot_loop
		jp			next_slot
not_expanded:
		inc			de
		inc			de
		inc			de
next_slot:
		inc			hl
		inc			b
		bit			2, b
		jp			z, slot_loop

		ld			a, [exptbl]
		call		local_enaslt0
		ei
		ret
		endscope

; ==============================================================================
;	check_page3
; ==============================================================================
		scope check_page3
check_page3::
		call		clear_slot_info		; B = 0
		ld			hl, exptbl_copy
		ld			de, slot_info
slot_loop:
		ld			a, [hl]
		and			a, 0x80
		or			a, b
exp_slot_loop:
		ld			c, a
		push		bc
		push		hl
		push		de
		ld			h, 0xC0
		call		enaslt
		pop			de

		; RAM check
		ld			hl, 0xC000
check_ram_loop:
		ld			a, h
		cp			a, 0xFF					; 0xFF00 まででやめておく。0xFFFF までチェックすると、拡張スロットレジスタを書き替えて暴走する。
		ld			a, 1
		jp			z, check_ram_exit
		ld			a, [hl]
		cpl
		ld			[hl], a
		cp			a, [hl]
		cpl
		ld			[hl], a
		inc			hl
		jp			z, check_ram_loop
		ld			a, 2
check_ram_exit:
		pop			hl
		pop			bc

		ld			[de], a
		inc			de
		ld			a, c
		add			a, 0x04
		jp			p, not_expanded
		bit			4, a
		jp			z, exp_slot_loop
		jp			next_slot
not_expanded:
		inc			de
		inc			de
		inc			de
next_slot:
		inc			hl
		inc			b
		bit			2, b
		jp			z, slot_loop

		ld			a, [p3_ram_slot]
		ld			h, 0xC0
		call		enaslt
		ei
		ret
		endscope

; ==============================================================================
;	get_page3_slot
;	input)
;		none
;	output)
;		A .... slot number of page3
; ==============================================================================
		scope get_page3_slot
get_page3_slot::
		; Page3 Base-Slot Detection
		in			a, [0xA8]
		and			a, 0xC0
		rlca
		rlca
		push		af

		; Page3 Expand-Slot Detection
		ld			b, a
		add			a, 0xC1
		ld			l, a
		ld			h, 0xFC
		ld			a, [hl]
		and			a, 0x80
		jp			z, skip1

		ld			a, [0xFFFF]
		cpl
		and			a, 0xC0
		rrca
		rrca
		rrca
		rrca
		or			a, 0x80
skip1:
		pop			bc
		or			a, b
		ret
		endscope

; ==============================================================================
;	local_enaslt0
;	input)
;		A .... slot number
;	output)
;		none
;	break)
;		af, bc, de
; ==============================================================================
		scope local_enaslt0
local_enaslt0::
		ld			b, a			; B = Target Slot#, E000ssSS
		and			a, 0x83			; E00000SS : SS = Target Slot#
		jp			p, not_expanded
		xor			a, 0x80
		ld			c, a			; C = Target Slot#
		rrca
		rrca
		or			a, c			; SS0000SS : SS = Target Slot#
		ld			c, a
		in			a, [0xA8]
		ld			e, a
		and			a, 0b00111100	; 00BBAA00 : AA = Page1 Slot#, BB = Page2 Slot#
		or			a, c			; SSBBAASS : SS = Target Slot#
		di
		out			[0xA8], a		; Change slot
		and			a, 0b00111111
		ld			d, a
		ld			a, e
		and			a, 0b11000000
		or			a, d
		ld			d, a
		ld			a, [0xFFFF]
		cpl
		and			a, 0xFC
		ld			c, a
		ld			a, b
		rrca
		rrca
		and			a, 0b00000011	; 000000ss
		or			a, c
		ld			[0xFFFF], a
		ld			a, d
		out			[0xA8], a
		ret
not_expanded:
		ld			c, a			; C = Target Slot#
		in			a, [0xA8]
		and			a, 0b11111100	; CCBBAA00 : AA = Page1 Slot#, BB = Page2 Slot#, CC = Page3 Slot#
		or			a, c			; CCBBAASS : SS = Target Slot#
		di
		out			[0xA8], a
		ret
		endscope

; ==============================================================================
;	puts
;	input)
;		HL .... address of target string (ASCII-Z)
; ==============================================================================
		scope puts
puts::
		ld			a, [hl]
		inc			hl
		or			a, a
		ret			z
		call		chput
		jp			puts
		endscope

; ==============================================================================
;	put_slot_no
;	input)
;		A .... Slot# (ENASLT format)
; ==============================================================================
		scope put_slot_no
put_slot_no::
		ld			b, a
		and			a, 3
		add			a, '0'
		call		chput

		ld			a, b
		or			a, a
		jp			p, not_expanded

		ld			a, '-'
		call		chput

		ld			a, b
		rrca
		rrca
		and			a, 3
		add			a, '0'
		call		chput
		ret
not_expanded:
		ld			hl, message_padding
		call		puts
		ret
		endscope

; ==============================================================================
;	display_slot_info
;	input)
;		HL .... Header message address
; ==============================================================================
		scope display_slot_info
display_slot_info::
		call		puts
		ld			hl, exptbl			; Slot#0-0 の EXPTBL
		ld			de, slot_info		; Slot#0-0 の slot_info
		ld			b, 0				; Slot#0 から表示開始
slot_loop:
		ld			a, [hl]				; EXPTBL を読む
		inc			hl					; 次の Slot に備える
		push		hl
		and			a, 0x80				; 拡張スロットフラグ以外は消去
		or			a, b				; E0000000
		ld			b, a				; Bレジスタにバックアップ
exp_slot_loop:
		ld			a, [de]				; slot_info を読む
		inc			de					; 次の Slot に備える
		or			a, a				; 0 の場合、存在しないスロットなので無視
		jp			z, skip1
		ld			c, a				; Cレジスタに slot_info をバックアップ

		ld			a, b				; Aレジスタに Slot# を復元
		push		de
		push		bc
		push		af
		ld			hl, message_slot	; "SLOT#" を表示
		call		puts
		pop			af
		call		put_slot_no			; Slot# を表示
		pop			bc
		push		bc
		ld			hl, message_ram
		dec			c					; slot_info が 1 なら "RAM", 2 なら "Non-RAM" を表示
		jp			z, skip2
		ld			hl, message_non_ram
skip2:
		call		puts
		pop			bc
		pop			de
skip1:
		ld			a, b				; Aレジスタに Slot# を復元
		add			a, 0x04				; 次の拡張スロットへ
		ld			b, a
		bit			4, a
		jp			z, exp_slot_loop
		pop			hl
		and			a, 3
		inc			a
		ld			b, a
		bit			2, a
		jp			z, slot_loop
		ret
		endscope

; ==============================================================================
;	DATA
; ==============================================================================
message_page0:
		ds			"PAGE0:"
		db			0x0D, 0x0A, 0
message_page3:
		ds			"PAGE3:"
		db			0x0D, 0x0A, 0
message_slot:
		ds			"  SLOT#"
		db			0
message_padding:
		ds			"  "
		db			0
message_ram:
		ds			": RAM"
		db			0x0D, 0x0A, 0
message_non_ram:
		ds			": Non-RAM"
		db			0x0D, 0x0A, 0
message_press_enter_key:
		ds			"Press enter key!!"
		db			0x0D, 0x0A, 0

; ==============================================================================
;	WORK AREA (Page2)
; ==============================================================================
p3_ram_slot	=		0x8000			; 1byte  : Page3 RAM slot#
exptbl_copy	=		p3_ram_slot + 1	; 4bytes : Copy of EXPTBL
slot_info	=		exptbl_copy + 4	; 16bytes: Slot information 0:N/A, 1:RAM, 2:Non-RAM
		align		8192
