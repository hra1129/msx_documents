; =============================================================================
;	ROM_sample001.ASM
; -----------------------------------------------------------------------------
;	Jan./31/2020 HRA!
; =============================================================================

chput	= 0x00A2
himem	= 0xfc4a

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

main_loop:
		; Put message
		ld			hl, display_message
		call		puts
		jp			main_loop

; ==============================================================================
;	puts
;	input)
;		HL .... address of target string (ASCII-Z)
; ==============================================================================
puts:
		ld			a, [hl]
		inc			hl
		or			a, a
		ret			z
		call		chput
		jp			puts

display_message:
		ds			"Hello, world!! "
		db			0

		align		16384
