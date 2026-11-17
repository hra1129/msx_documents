; -----------------------------------------------------------------------------
;	VDP Command HMMC Sample Program
; =============================================================================
;	2020/4/22	t.hara
; -----------------------------------------------------------------------------

VDP_IO_PORT1	= 0x99
VDP_IO_PORT2	= 0x9A
VDP_IO_PORT3	= 0x9B

		; BSAVE header
		db		0xFE
		dw		start_address
		dw		end_address
		dw		start_address

		; Program body
		org		0xC000

start_address::
		ld		hl, dx00
		call	exec_hmmc

		ld		hl, dx10
		call	exec_hmmc

		ld		hl, dx01
		call	exec_hmmc

		ld		hl, dx11
		call	exec_hmmc

		ret

exec_hmmc::
		di
		ld		c, VDP_IO_PORT1

		; R#17 = 36 (R#36からの間接連続書き込み設定)
		ld		a, 36
		out		[c], a
		ld		a, 17 | 0x80
		out		[c], a

		; R#36～R#46 に dx～cmr をまとめて書き込む
		ld		bc, (11 << 8) | VDP_IO_PORT3	; R#36～R#46 は 11個のレジスタへ
		otir									; まとめて書き込み
		ld		hl, target_image
		ld		c, VDP_IO_PORT1

		; 2バイト目以降の書き込みシーケンス
		; R#17 = 44 | 0x80 (R#44への連続書き込み)
		ld		a, 44 | 0x80
		out		[c], a
		ld		a, 17 | 0x80
		out		[c], a
		; R#15 = 2 (S#2 を読むための設定)
		ld		a, 2
		out		[c], a
		ld		a, 15 | 0x80
		out		[c], a
		ld		c, VDP_IO_PORT3
wait_tr_flag:
		in		a, [VDP_IO_PORT1]
		rrca					; Cy = CE bit
		jr		nc, exit_hmmc_loop
		and		a, 0x40			; Zf = TR bit
		jr		z, wait_tr_flag
		outi					; 次のデータを書き込み
		jr		wait_tr_flag

exit_hmmc_loop:
		; R#15 = 0 (S#0 を読むための設定に戻す)
		xor		a, a
		out		[c], a
		ld		a, 15 | 0x80
		out		[c], a
		ei
		ret

; ==============================================================================
;	Case of ( DIX, DIY ) = ( 0, 0 )
; ==============================================================================
dx00:
		dw		50				; R#36, R#37
dy00:
		dw		100				; R#38, R#39
nx00:
		dw		8				; R#40, R#41
ny00:
		dw		8				; R#42, R#43
clr00:
		db		0x44			; R#44
arg00:
		db		0b0000_0000		; R#45
cmr00:
		db		0b1111_0000		; R#46

; ==============================================================================
;	Case of ( DIX, DIY ) = ( 1, 0 )
; ==============================================================================
dx10:
		dw		100				; R#36, R#37
dy10:
		dw		100				; R#38, R#39
nx10:
		dw		8				; R#40, R#41
ny10:
		dw		8				; R#42, R#43
clr10:
		db		0x44			; R#44
arg10:
		db		0b0000_0100		; R#45
cmr10:
		db		0b1111_0000		; R#46

; ==============================================================================
;	Case of ( DIX, DIY ) = ( 0, 1 )
; ==============================================================================
dx01:
		dw		150				; R#36, R#37
dy01:
		dw		100				; R#38, R#39
nx01:
		dw		8				; R#40, R#41
ny01:
		dw		8				; R#42, R#43
clr01:
		db		0x44			; R#44
arg01:
		db		0b0000_1000		; R#45
cmr01:
		db		0b1111_0000		; R#46

; ==============================================================================
;	Case of ( DIX, DIY ) = ( 1, 1 )
; ==============================================================================
dx11:
		dw		200				; R#36, R#37
dy11:
		dw		100				; R#38, R#39
nx11:
		dw		8				; R#40, R#41
ny11:
		dw		8				; R#42, R#43
clr11:
		db		0x44			; R#44
arg11:
		db		0b0000_1100		; R#45
cmr11:
		db		0b1111_0000		; R#46

target_image:
		db		      0x41, 0x14, 0x44, 0x44, 0x12, 0xC1, 0x44
		db		0x41, 0x33, 0x2C, 0x14, 0x12, 0x33, 0x2C, 0xC1
		db		0x1C, 0x22, 0x2C, 0xC1, 0x41, 0xCC, 0xCC, 0x14
		db		0x44, 0x1C, 0xC1, 0x44, 0x44, 0x41, 0x14, 0x44
end_address::
