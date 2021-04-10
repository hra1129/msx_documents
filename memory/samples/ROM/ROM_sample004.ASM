; =============================================================================
;	ROM_sample004.ASM
; -----------------------------------------------------------------------------
;	Feb./3/2020 HRA!
; =============================================================================

chput		= 0x00A2
himem		= 0xfc4a

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
		ld			sp, [himem]

		; page1
		ld			hl, display_message_page1
		call		puts
		call		get_page1_slot
		call		put_slot_no

		; page2
		ld			hl, display_message_page2
		call		puts
		call		get_page2_slot
		call		put_slot_no

		; page3
		ld			hl, display_message_page3
		call		puts
		call		get_page3_slot
		call		put_slot_no

finish:
		jp			finish

; ==============================================================================
;	get_page1_slot
;	input)
;		none
;	output)
;		A .... slot number of page1
; ==============================================================================
		scope get_page1_slot
get_page1_slot::
		; Page1 Base-Slot Detection
		in			a, [0xA8]
		and			a, 0x0C
		rrca
		rrca
		push		af

		; Page1 Expand-Slot Detection
		ld			b, a
		add			a, 0xC1
		ld			l, a
		ld			h, 0xFC
		ld			a, [hl]
		and			a, 0x80
		jp			z, skip1

		ld			a, b
		rrca
		rrca
		ld			b, a
		in			a, [0xa8]
		ld			c, a
		and			a, 0x3F
		or			a, b
		di
		out			[0xa8], a
		ld			a, [0xFFFF]
		ld			b, a
		ld			a, c
		out			[0xa8], a
		ei
		ld			a, b
		cpl
		and			a, 0x0C
		or			a, 0x80
skip1:
		pop			bc
		or			a, b
		ret
		endscope

; ==============================================================================
;	get_page2_slot
;	input)
;		none
;	output)
;		A .... slot number of page2
; ==============================================================================
		scope get_page2_slot
get_page2_slot::
		; Page2 Base-Slot Detection
		in			a, [0xA8]
		and			a, 0x30
		rrca
		rrca
		rrca
		rrca
		push		af

		; Page2 Expand-Slot Detection
		ld			b, a
		add			a, 0xC1
		ld			l, a
		ld			h, 0xFC
		ld			a, [hl]
		and			a, 0x80
		jp			z, skip1

		ld			a, b
		rrca
		rrca
		ld			b, a
		in			a, [0xa8]
		ld			c, a
		and			a, 0x3F
		or			a, b
		di
		out			[0xa8], a
		ld			a, [0xFFFF]
		ld			b, a
		ld			a, c
		out			[0xa8], a
		ei
		ld			a, b
		cpl
		and			a, 0x30
		rrca
		rrca
		or			a, 0x80
skip1:
		pop			bc
		or			a, b
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
		jp			p, skip1

		ld			a, '-'
		call		chput

		ld			a, b
		rrca
		rrca
		and			a, 3
		add			a, '0'
		call		chput
skip1:
		ld			hl, display_crlf
		call		puts
		ret
		endscope

; ==============================================================================
;	DATA
; ==============================================================================
display_message_page1:
		ds			"PAGE1 SLOT#"
		db			0
display_message_page2:
		ds			"PAGE2 SLOT#"
		db			0
display_message_page3:
		ds			"PAGE3 SLOT#"
		db			0
display_crlf:
		db			0x0D, 0x0A, 0

		align		8192
