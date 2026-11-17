; -----------------------------------------------------------------------------
;	VDP Command HMMM Sample Program
; =============================================================================
;	2020/6/9	t.hara
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

		; COPY( 247, 4 )-step( -248, 200 ),0 to ( 251, 4 ),0
		call	exec_hmmm
		ret

; -----------------------------------------------------------------------------
;	HMMM
; -----------------------------------------------------------------------------
exec_hmmm::
		; R#17 = 32 (R#32からの間接連続書き込み設定)
		ld		c, VDP_IO_PORT1
		ld		a, 32
		di
		out		[c], a
		ld		a, 17 | 0x80
		out		[c], a
		ei

		; R#32～R#46 に sx～cmr をまとめて書き込む
		ld		bc, (15 << 8) | VDP_IO_PORT3	; R#32～R#46 は 15個のレジスタ
		ld		hl, sx
		otir

		; 転送完了待ち
		ld		c, VDP_IO_PORT1
		ld		de, 15 | 0x80					; d = 0, e = 15 | 0x80

wait_ce_flag:
		; R#15 = 2 (S#2 を読むための設定)
		di
		ld		a, 2
		out		[c], a
		out		[c], e
		; a = S#2
		in		a, [c]
		; R#15 = 0
		out		[c], d
		out		[c], e
		ei
		rrca					; Cy = CE bit
		jr		c, wait_ce_flag

		ret

sx:
		dw		247				; R#32, R#33
sy:
		dw		4				; R#34, R#35
dx:
		dw		251				; R#36, R#37
dy:
		dw		4				; R#38, R#39
nx:
		dw		248				; R#40, R#41
ny:
		dw		200				; R#42, R#43
clr:
		db		0				; R#44 無効だが OTIR で書き込むためのダミー
arg:
		db		0b0000_0100		; R#45 DIY = 0, DIX = 1
cmr:
		db		0b1101_0000		; R#46
end_address::
