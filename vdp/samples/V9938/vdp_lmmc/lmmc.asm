; --------------------------------------------------------------------
; test of LMMC
; ====================================================================
; 12nd/Dec./2021  t.hara
; --------------------------------------------------------------------
; LMMCコマンドで最初の 1ドットを R#44 に設定してからコマンド実行する
; のがとても使いづらい。
; しかし、コマンド実行後に設定できる方法があるらしい。
;
; https://www.msx.org/forum/msx-talk/development/transferring-data-after-hmmc-lmmc-command
;
; その確認をするためプログラムである。
;
; 事前に、BASIC側で SCREEN5 に設定してから、このプログラムを実行すること。
;

vdp_port0	:= 0x98
vdp_port1	:= 0x99
vdp_port2	:= 0x9A
vdp_port3	:= 0x9B

			db		0xFE
			dw		start_address
			dw		end_address
			dw		start_address

			org		0xC000
start_address::

			di
			; wait complete VDP command
			ld		a, 2
			out		[vdp_port1], a
			ld		a, 0x80 | 15
			out		[vdp_port1], a		; R#15 = 2

			ld		c, vdp_port1
wait_vdp_command:
			in		a, [c]
			rrca						; Cy = CE bit
			jr		c, wait_vdp_command

			; execute LMCM command for TR bit
			ld		a, 0xA0				; LMCM command
			out		[vdp_port1], a
			ld		a, 0x80 | 46
			out		[vdp_port1], a

			; execute LMMC command
			ld		a, 36
			out		[vdp_port1], a
			ld		a, 0x80 | 17
			out		[vdp_port1], a		; R#17 = 36

			ld		hl, lmmc
			ld		bc, (lmmc_size << 8) | vdp_port3
			otir

			; transfer pixel datas
			ld		a, 0x80 | 44
			out		[vdp_port1], a
			ld		a, 0x80 | 17
			out		[vdp_port1], a		; R#17 = 0x80 | 44

			ld		a, 2				; first color is 2 (green)
			ld		c, vdp_port1
transfer_loop:
			in		b, [c]
			rrc		b					; Cy = CE bit
			jr		nc, exit_transfer
			rlc		b					; S = TR bit
			jp		p, transfer_loop

			out		[vdp_port3], a
			inc		a					; next color
			and		a, 15
			jr		transfer_loop
exit_transfer:

			xor		a, a
			out		[vdp_port1], a
			ld		a, 0x80 | 15
			out		[vdp_port1], a		; R#15 = 0
			ei
			ret

lmmc::
			dw		45					; R#36, 37: DX
			dw		32					; R#38, 39: DY
			dw		16					; R#40, 41: NX
			dw		80					; R#42, 43: NY
			db		0					; R#44    : CLR
			db		0					; R#45    : ARG
			db		0b1011_1000			; R#46    : CMD, LMMC, TIMP
lmmc_end::
lmmc_size := lmmc_end - lmmc

end_address::
