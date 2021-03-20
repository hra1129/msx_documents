; -----------------------------------------------------------------------------
;	VDP Command HMMC Sample Program
; =============================================================================
;	2020/4/29	t.hara
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

main_loop:
		; 上部の転送 COPY( 160, top_line )-step(-160, 212-top_line ),1 to ( 160, 0 ),0
		xor		a, a
		ld		[dy], a
		ld		a, [top_line]
		ld		[sy], a
		sub		a, 212
		neg
		ld		[ny], a
		call	exec_ymmm

		; 下部の転送 COPY( 160, 0 )-step(-160, top_line ),1 to ( 160, 212-top_line ),0
		ld		a, [top_line]
		or		a, a
		jr		z, lower_is_not_transfer
		ld		b, a
		ld		a, [ny]
		ld		[dy], a
		ld		a, b
		ld		[ny], a
		xor		a, a
		ld		[sy], a
		call	exec_ymmm
lower_is_not_transfer:

		; top_line をシフトする
		ld		a, [top_line]
		sub		a, 8
		jp		nc, shift_end
		add		a, 212
shift_end:
		ld		[top_line], a

		jp		main_loop

top_line:
		db		0

; -----------------------------------------------------------------------------
;	YMMM
; -----------------------------------------------------------------------------
exec_ymmm::
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

		; R#17 = 34 (R#34からの間接連続書き込み設定)
		ld		a, 34
		di
		out		[c], a
		ld		a, 17 | 0x80
		out		[c], a
		ei

		; R#34～R#46 に sy～cmr をまとめて書き込む
		ld		bc, (13 << 8) | VDP_IO_PORT3	; R#34～R#46 は 13個のレジスタ
		ld		hl, sy
		otir
		ret

sy:
		db		0				; R#34
		db		1				; R#35 常に転送元は page1 なのであらかじめ 1 を書いておく。
dx:
		dw		158				; R#36, R#37
dy:
		db		0				; R#38
		db		0				; R#39 常に転送先は page0 なのであらかじめ 0 を書いておく。
nx:
		dw		0				; R#40, R#41  無効だが OTIR で書き込むためのダミー
ny:
		dw		0				; R#42, R#43
clr:
		db		0				; R#44 無効だが OTIR で書き込むためのダミー
arg:
		db		0b0000_0100		; R#45 DIY = 0, DIX = 1
cmr:
		db		0b1110_0000		; R#46
end_address::
