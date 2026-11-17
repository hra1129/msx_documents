; -----------------------------------------------------------------------------
;	VDP Register Test Program
; =============================================================================
;	2021/5/25	t.hara
; -----------------------------------------------------------------------------

VDP_IO_PORT0	= 0x98
VDP_IO_PORT1	= 0x99
VDP_IO_PORT2	= 0x9A
VDP_IO_PORT3	= 0x9B

CHGET			= 0x009F
CHPUT			= 0x00A2

		; BSAVE header
		db		0xFE
		dw		start_address
		dw		end_address
		dw		start_address

		; Program body
		org		0xC000

start_address::
; =====================================================================
;	test001: Write Invalid Register
; =====================================================================
		scope	test001
test001::
		ld		de, message_test001
		call	puts

		di
		ld		a, 24
		call	write_increment_datas
		ld		a, 28
		call	write_increment_datas
		ld		a, 29
		call	write_increment_datas
		ld		a, 30
		call	write_increment_datas
		ld		a, 31
		call	write_increment_datas
		ld		a, 47
		call	write_increment_datas
		ld		a, 48
		call	write_increment_datas
		ld		a, 49
		call	write_increment_datas
		ld		a, 50
		call	write_increment_datas
		ld		a, 51
		call	write_increment_datas
		ld		a, 52
		call	write_increment_datas
		ld		a, 53
		call	write_increment_datas
		ld		a, 54
		call	write_increment_datas
		ld		a, 55
		call	write_increment_datas
		ld		a, 56
		call	write_increment_datas
		ld		a, 57
		call	write_increment_datas
		ld		a, 58
		call	write_increment_datas
		ld		a, 59
		call	write_increment_datas
		ld		a, 60
		call	write_increment_datas
		ld		a, 61
		call	write_increment_datas
		ld		a, 62
		call	write_increment_datas
		ld		a, 63
		call	write_increment_datas
		ei

		ld		de, message_ok
		call	puts
		call	chget
		endscope

; =====================================================================
;	test002: Write R#23,#24,#25 with R#17
; =====================================================================
		scope	test002
test002::
		ld		de, message_test002
		call	puts

		di
		ld		a, 17
		ld		b, 23
		call	write_vdp_register		; R#17 = 23

		ld		c, VDP_IO_PORT3
		ld		a, 128
		out		[c], a					; R#23 = 128 (Vertical Scroll)
		ld		a, 255
		out		[c], a					; R#24 = 255 (N/A)
		ld		a, 2
		out		[c], a					; R#25 = 2   (Mask the left side)
		ei

		ld		de, message_ok
		call	puts
		call	chget

		di
		ld		a, 23
		ld		b, 0
		call	write_vdp_register		; R#23 = 0
		ld		a, 25
		ld		b, 0
		call	write_vdp_register		; R#25 = 0
		ei
		endscope

; =====================================================================
;	test003: Write R#60,#61,#62,#63,#0,#1 with R#17
; =====================================================================
		scope	test003
test003::
		ld		de, message_test003
		call	puts

		di
		ld		a, 17
		ld		b, 60
		call	write_vdp_register		; R#17 = 60

		ld		c, VDP_IO_PORT3
		ld		a, 255
		out		[c], a					; R#60 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#61 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#62 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#63 = 255  (N/A)
		ld		a, 0
		out		[c], a					; R#0  = 0    (SCREEN0 WIDTH40)
		ld		a, 0x70
		out		[c], a					; R#1  = 0x70 (SCREEN0 WIDTH40)
		ei

		ld		de, message_ok
		call	puts
		call	chget

		di
		ld		a, 17
		ld		b, 60
		call	write_vdp_register		; R#17 = 60

		ld		c, VDP_IO_PORT3
		ld		a, 255
		out		[c], a					; R#60 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#61 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#62 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#63 = 255  (N/A)
		ld		a, 0
		out		[c], a					; R#0  = 0    (SCREEN0 WIDTH40)
		ld		a, 0x60
		out		[c], a					; R#1  = 0x60 (SCREEN0 WIDTH40)
		ei

		ld		de, message_ok
		call	puts
		call	chget
		endscope

; =====================================================================
;	test004: Write R#47,#48,#49,#50,...60,#61,#62,#63,#0,#1 with R#17
; =====================================================================
		scope	test004
test004::
		ld		de, message_test004
		call	puts

		di
		ld		a, 17
		ld		b, 47
		call	write_vdp_register		; R#17 = 47

		ld		c, VDP_IO_PORT3
		ld		a, 255
		out		[c], a					; R#47 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#48 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#49 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#50 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#51 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#52 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#53 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#54 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#55 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#56 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#57 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#58 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#59 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#60 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#61 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#62 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#63 = 255  (N/A)
		ld		a, 0
		out		[c], a					; R#0  = 0    (SCREEN0 WIDTH40)
		ld		a, 0x70
		out		[c], a					; R#1  = 0x70 (SCREEN0 WIDTH40)
		ei

		ld		de, message_ok
		call	puts
		call	chget

		di
		ld		a, 17
		ld		b, 47
		call	write_vdp_register		; R#17 = 47

		ld		c, VDP_IO_PORT3
		ld		a, 255
		out		[c], a					; R#47 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#48 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#49 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#50 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#51 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#52 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#53 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#54 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#55 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#56 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#57 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#58 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#59 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#60 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#61 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#62 = 255  (N/A)
		ld		a, 255
		out		[c], a					; R#63 = 255  (N/A)
		ld		a, 0
		out		[c], a					; R#0  = 0    (SCREEN0 WIDTH40)
		ld		a, 0x60
		out		[c], a					; R#1  = 0x60 (SCREEN0 WIDTH40)
		ei
		endscope

		ret

; =====================================================================
;	Write Increment Datas
;	input)
;		A .... Register Number
;	break)
;		AF, BC
; =====================================================================
		scope	write_increment_datas
write_increment_datas::
		ld		b, 0
loop1:
		call	write_vdp_register
		inc		b
		jp		nz, loop1
		ret
		endscope

; =====================================================================
;	Register Write
;	input)
;		A .... Register Number
;		B .... Write Data
;	break)
;		AF, C
; =====================================================================
		scope	write_vdp_register
write_vdp_register::
		ld		c, VDP_IO_PORT1
		out		[c], b
		or		a, 0x80
		out		[c], a
		ret
		endscope

; =====================================================================
;	test001: Write Invalid Register
; =====================================================================
		scope	puts
puts::
		ld		a, [de]
		or		a, a
		ret		z
		call	CHPUT
		inc		de
		jp		puts
		endscope

message_ok::
		ds		" .... OK\r\n"
		ds		"Press RETURN\r\n"
		db		0
message_test001::
		ds		"TEST001: Write Invalid Registers"
		db		0
message_test002::
		ds		"TEST002: Write R#23-25 with R#17"
		db		0
message_test003::
		ds		"TEST003: Write R#60-01 with R#17"
		db		0
message_test004::
		ds		"TEST004: Write R#47-01 with R#17"
		db		0
end_address::
