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
		di
		ld		c, VDP_IO_PORT1

		; R#17 = 36 (R#36からの間接連続書き込み設定)
		ld		a, 36
		out		[c], a
		ld		a, 17 | 0x80
		out		[c], a

		; R#36～R#46 に dx～cmr をまとめて書き込む
		ld		bc, (11 << 8) | VDP_IO_PORT3	; R#36～R#46 は 11個のレジスタ
		ld		hl, dx
		otir									; この命令の終了時点で HL = target_image になっている
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
		ld		c, VDP_IO_PORT1
		xor		a, a
		out		[c], a
		ld		a, 15 | 0x80
		out		[c], a
		ei
		ret

dx:
		dw		100				; R#36, R#37
dy:
		dw		100				; R#38, R#39
nx:
		dw		8				; R#40, R#41
ny:
		dw		8				; R#42, R#43
clr:
		db		0x44			; R#44
arg:
		db		0				; R#45
cmr:
		db		0b1111_0000		; R#46

target_image:
		db		      0x41, 0x14, 0x44, 0x44, 0x12, 0xC1, 0x44
		db		0x41, 0x33, 0x2C, 0x14, 0x12, 0x33, 0x2C, 0xC1
		db		0x1C, 0x22, 0x2C, 0xC1, 0x41, 0xCC, 0xCC, 0x14
		db		0x44, 0x1C, 0xC1, 0x44, 0x44, 0x41, 0x14, 0x44
end_address::
