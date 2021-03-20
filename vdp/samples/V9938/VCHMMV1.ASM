; -----------------------------------------------------------------------------
;	VDP Command HMMV Sample Program
; =============================================================================
;	2020/6/11	t.hara
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

		; LINE ( 10, 10 ) - STEP( 236, 190 ), &H2B, BF
		call	exec_hmmv
		ret

; -----------------------------------------------------------------------------
;	HMMV
; -----------------------------------------------------------------------------
exec_hmmv::
		; R#17 = 36 (R#36からの間接連続書き込み設定)
		ld		c, VDP_IO_PORT1
		ld		a, 36
		di
		out		[c], a
		ld		a, 17 | 0x80
		out		[c], a
		ei

		; R#36～R#46 に sx～cmr をまとめて書き込む
		ld		bc, (11 << 8) | VDP_IO_PORT3	; R#36～R#46 は 11個のレジスタ
		ld		hl, dx
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

dx:
		dw		10				; R#36, R#37
dy:
		dw		10				; R#38, R#39
nx:
		dw		236				; R#40, R#41
ny:
		dw		190				; R#42, R#43
clr:
		db		0x2B			; R#44 無効だが OTIR で書き込むためのダミー
arg:
		db		0b0000_0000		; R#45 DIY = 0, DIX = 0
cmr:
		db		0b1100_0000		; R#46
end_address::
