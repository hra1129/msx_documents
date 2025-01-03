; =============================================================================
; 全てのページを RAM に切り替えて動作する ROMカートリッジのサンプルコード
; -----------------------------------------------------------------------------
; MIT License
;
; ご自身のプログラムに、全部または一部をご自由に組み込んでお使いいただけます。
; ただし、作者(t.hara)は、このプログラムにより何らかの損害を被っても、
; 一切責任を負いません。
; -----------------------------------------------------------------------------
; 2025/01/03 t.hara (HRA!)
; =============================================================================

ppi_slot_reg			:= 0xA8
ext_slot_reg			:= 0xFFFF
main_rom_slot			:= 0xFCC1
exptbl					:= 0xFCC1
slttbl					:= 0xFCC5
ramad0					:= 0xF341
ramad1					:= 0xF342
ramad2					:= 0xF343
ramad3					:= 0xF344

rom_slot				:= 0x8000
page2_routine_on_ram	:= 0xb000

			org		0x4000

			db		"AB"				; ID
			dw		entry_point			; INIT
			dw		0
			dw		0
			dw		0
			dw		0
			dw		0
			dw		0

entry_point::
			; page2 が RAM であるかチェックする (32KB未満のマシンを除外するため）
		scope	page2_ram_check
			ld		hl, 0x8000
			di
	loop:
			ld		a, [hl]
			cpl
			ld		[hl], a
			cp		a, [hl]
			cpl
			ld		[hl], a
			jp		nz, error_not_enough_memory
			inc		hl
			ld		a, h
			or		a, a
			jp		p, loop
		endscope
			; page1 のスロット番号(この ROMカートリッジのスロット番号)を取得する
		scope	get_rom_slot
			in		a, [ppi_slot_reg]
			and		a, 0b00001100
			rrca
			rrca
			ld		b, a
			; 拡張スロットの存在を調べる
			ld		hl, exptbl
			add		a, l
			ld		l, a
			ld		a, [hl]
			and		a, 0x80
			or		a, b
			jp		p, no_expand_slot
			; 拡張スロットがある場合
			inc		hl
			inc		hl
			inc		hl
			inc		hl
			ld		b, a
			ld		a, [hl]
			and		a, 0b00001100
			or		a, b
	no_expand_slot:
			ld		[rom_slot], a
		endscope
			; page2 のスロット番号(RAM)を取得する
		scope	get_page2_ram_slot
			in		a, [ppi_slot_reg]
			and		a, 0b00110000
			rrca
			rrca
			rrca
			rrca
			ld		b, a
			; 拡張スロットの存在を調べる
			ld		hl, exptbl
			add		a, l
			ld		l, a
			ld		a, [hl]
			and		a, 0x80
			or		a, b
			jp		p, no_expand_slot
			; 拡張スロットがある場合
			inc		hl
			inc		hl
			inc		hl
			inc		hl
			ld		b, a
			ld		a, [hl]
			and		a, 0b00110000
			rrca
			rrca
			or		a, b
	no_expand_slot:
			ld		[ramad2], a
		endscope
			; page3 のスロット番号(RAM)を取得する
		scope	get_page3_ram_slot
			in		a, [ppi_slot_reg]
			and		a, 0b11000000
			rlca
			rlca
			ld		b, a
			; 拡張スロットの存在を調べる
			ld		hl, exptbl
			add		a, l
			ld		l, a
			ld		a, [hl]
			and		a, 0x80
			or		a, b
			jp		p, no_expand_slot
			; 拡張スロットがある場合
			inc		hl
			inc		hl
			inc		hl
			inc		hl
			ld		b, a
			ld		a, [hl]
			and		a, 0b11000000
			rrca
			rrca
			rrca
			rrca
			or		a, b
	no_expand_slot:
			ld		[ramad3], a
		endscope
			; page2 チェックルーチンと自作 ENASLT を転送して、チェックルーチンへジャンプする
		scope	transfer_check_routine
			ld		hl, page2_routine_on_rom
			ld		de, page2_routine_on_ram
			ld		bc, page2_routine_on_ram_end - page2_routine_on_ram
			ldir
			jp		main_routine
		endscope
			; エラーメッセージ処理
error_not_enough_memory:
			ld		hl, message_not_enough_memory
			jp		put_error

			scope	put_error
put_error::
			ld		a, [main_rom_slot]
			push	hl
			call	my_enaslt0
			pop		hl
	loop:
			ld		a, [hl]
			or		a, a
			jr		z, freeze
			rst		0x18
			inc		hl
			jr		loop
	freeze:
			di
			halt
			endscope

; =============================================================================
;	Page2 へ転送して動かす部分 (page2_routine_on_ram ～ page2_routine_on_ram_end)
; =============================================================================
page2_routine_on_rom:
			org		page2_routine_on_ram
		scope	page2_routine_on_ram
page2_routine_on_ram::

; -----------------------------------------------------------------------------
			scope	main_routine
main_routine::
			call	change_to_ram_for_page0
			call	change_to_ram_for_page1
			di
	loop:
			jp		loop
			endscope

; -----------------------------------------------------------------------------
;	Page0 を MainROM, Page1 を カートリッジROM に切り替えて
;	カートリッジROM上のエラー出力ルーチンへ飛ぶ
; -----------------------------------------------------------------------------
			scope	goto_error
goto_error::
				ld		a, [main_rom_slot]
				call	my_enaslt0
				ld		a, [rom_slot]
				call	my_enaslt1
				jp		error_not_enough_memory
			endscope

; -----------------------------------------------------------------------------
;	Page0 を RAM に切り替える
; -----------------------------------------------------------------------------
			scope	change_to_ram_for_page0
change_to_ram_for_page0::
				xor		a, a					; 探索開始スロット SLOT#0 をセットする MSB [0][0][0][0][0][P][P] LSB : 
												;   E=拡張スロットありなら1, S=セカンダリスロット(拡張スロット), 
												;   P=プライマリスロット(基本スロット)
				ld		hl, exptbl				; 各スロットにおける拡張スロットの有無 +0～+3 の 4bytes
	primary_slot_loop:
				ld		b, a
				push	af						; (1) ループ用にスロット番号を保存
				ld		a, [hl]
				push	hl						; (2) EXPTBLのアドレスを保存
				and		a, 0x80					; MSB だけ抽出
				or		a, b					; さっき保存しておいた基本スロット番号をミックスする [E][0][0][0][0][P][P]
				jp		m, expand_slot_found	; MSB が立っていれば拡張スロットあり版の処理へ
				; 拡張スロットが無かった場合
				call	check_page0				; page0 を SLOT#A に切り替えて RAM か調べる。RAM なら Zf=1
				push	af						; (3) 拡張スロットあり版とスタックを合わせるためのダミー
				jr		z, ram_found			; RAM だった場合、ram_found へ
				pop		af						; [3] ダミーが要らなかったから捨て
				jr		next_primary_slot
	expand_slot_found:
				; 拡張スロットがあった場合
				push	af						; (3) スロット番号を保存
				call	check_page0				; page0 を SLOT#A に切り替えて RAM か調べる。RAM なら Zf=1
				jr		z, ram_found			; RAM だった場合、ram_found へ
				pop		af						; [3] スロット番号を復帰
				add		a, 0x04					; 拡張スロット番号をインクリメント [E][0][0][S][S][P][P]
				bit		4, a					; bit4 ( [0]であるべきbit ) が 1 になったら終わり
				jr		z, expand_slot_found	; まだ 1 になってないから繰り返す
	next_primary_slot:
				pop		hl						; [2] EXPTBLのアドレスを復帰
				pop		af						; [1] ループ用に保存したスロット番号を復帰
				inc		a						; 基本スロットを次に進める
				inc		hl						; EXPTBL も次の基本スロットへ進める
				bit		2, a					; 基本スロットのインクリメントが拡張スロットのフィールドまで浸食したか？
				jr		z, primary_slot_loop	; 浸食してないので繰り返す
	ram_not_found:
				jp		goto_error				; 全スロット調べたけど見つからなかった場合はここに到達する
	ram_found:
				pop		hl						; [3] 読み捨て
				pop		hl						; [2] 読み捨て
				pop		af						; [1] 読み捨て
				ret
			endscope

			scope		check_page0
	check_page0::
				; page0 を指定のスロットに切り替える
				ld		[ramad0], a				; とりあえず、RAMのスロットとしてセットしてしまう
				call	my_enaslt0				; page0 をそのスロットに切り替える
				; page0 が RAM かチェックする
				ld		hl, 0x0000				; 0000h から調査
		loop:
				ld		a, [hl]					; 値を読んで反転して書き戻す。
				cpl
				ld		[hl], a
				cp		a, [hl]					; RAM なら一致する(Zf=1)。RAMじゃなければ一致しない(Zf=0)。
				cpl
				ld		[hl], a					; 元の値を書き戻す。RAMだった場合でも内容を破壊しないため。
				ret		nz						; RAMでなければ Zf=0 で戻る
				inc		hl						; 次のアドレスをチェック
				bit		6, h					; H=0x40 になったら終わる
				jr		z, loop					; まだなっていない場合、繰り返す
				xor		a, a					; Zf=0 になってるので、RAM 見つけたことを示す Zf=1 に変更して戻る。
				ret
			endscope

; -----------------------------------------------------------------------------
;	Page1 を RAM に切り替える
; -----------------------------------------------------------------------------
			scope	change_to_ram_for_page1
change_to_ram_for_page1::
				xor		a, a					; 探索開始スロット SLOT#0 をセットする MSB [0][0][0][0][0][P][P] LSB : 
												;   E=拡張スロットありなら1, S=セカンダリスロット(拡張スロット), 
												;   P=プライマリスロット(基本スロット)
				ld		hl, exptbl				; 各スロットにおける拡張スロットの有無 +0～+3 の 4bytes
	primary_slot_loop:
				ld		b, a
				push	af						; (1) ループ用にスロット番号を保存
				ld		a, [hl]
				push	hl						; (2) EXPTBLのアドレスを保存
				and		a, 0x80					; MSB だけ抽出
				or		a, b					; さっき保存しておいた基本スロット番号をミックスする [E][0][0][0][0][P][P]
				jp		m, expand_slot_found	; MSB が立っていれば拡張スロットあり版の処理へ
				; 拡張スロットが無かった場合
				call	check_page1				; page1 を SLOT#A に切り替えて RAM か調べる。RAM なら Zf=1
				push	af						; (3) 拡張スロットあり版とスタックを合わせるためのダミー
				jr		z, ram_found			; RAM だった場合、ram_found へ
				pop		af						; [3] ダミーが要らなかったから捨て
				jr		next_primary_slot
	expand_slot_found:
				; 拡張スロットがあった場合
				push	af						; (3) スロット番号を保存
				call	check_page1				; page1 を SLOT#A に切り替えて RAM か調べる。RAM なら Zf=1
				jr		z, ram_found			; RAM だった場合、ram_found へ
				pop		af						; [3] スロット番号を復帰
				add		a, 0x04					; 拡張スロット番号をインクリメント [E][0][0][S][S][P][P]
				bit		4, a					; bit4 ( [0]であるべきbit ) が 1 になったら終わり
				jr		z, expand_slot_found	; まだ 1 になってないから繰り返す
	next_primary_slot:
				pop		hl						; [2] EXPTBLのアドレスを復帰
				pop		af						; [1] ループ用に保存したスロット番号を復帰
				inc		a						; 基本スロットを次に進める
				inc		hl						; EXPTBL も次の基本スロットへ進める
				bit		2, a					; 基本スロットのインクリメントが拡張スロットのフィールドまで浸食したか？
				jr		z, primary_slot_loop	; 浸食してないので繰り返す
	ram_not_found:
				jp		goto_error				; 全スロット調べたけど見つからなかった場合はここに到達する
	ram_found:
				pop		hl						; [3] 読み捨て
				pop		hl						; [2] 読み捨て
				pop		af						; [1] 読み捨て
				ret
			endscope

			scope		check_page1
	check_page1::
				; page1 を指定のスロットに切り替える
				ld		[ramad1], a				; とりあえず、RAMのスロットとしてセットしてしまう
				call	my_enaslt1				; page1 をそのスロットに切り替える
				; page1 が RAM かチェックする
				ld		hl, 0x4000				; 4000h から調査
		loop:
				ld		a, [hl]					; 値を読んで反転して書き戻す。
				cpl
				ld		[hl], a
				cp		a, [hl]					; RAM なら一致する(Zf=1)。RAMじゃなければ一致しない(Zf=0)。
				cpl
				ld		[hl], a					; 元の値を書き戻す。RAMだった場合でも内容を破壊しないため。
				ret		nz						; RAMでなければ Zf=0 で戻る
				inc		hl						; 次のアドレスをチェック
				bit		7, h					; H=0x80 になったら終わる
				jr		z, loop					; まだなっていない場合、繰り返す
				xor		a, a					; Zf=0 になってるので、RAM 見つけたことを示す Zf=1 に変更して戻る。
				ret
			endscope

; -----------------------------------------------------------------------------
;	Page0 を切り替える ENASLT
;	input:
;		A .... 切り替えるスロットの番号  MSB [Ex][0][0][0][ExSlot][ExSlot][PrimarySlot][PrimarySlot] LSB
;	output:
;		なし
;	break:
;		AF,BC,DE,HL
;	comment:
;		di状態で戻る
; -----------------------------------------------------------------------------
			scope	my_enaslt0
my_enaslt0::
				ld		b, a					; B にスロット番号を保存。MSB [E][0][0][0][S][S][P][P] LSB
				and		a, 0x83					; 指定の基本スロット番号を取得する
				jp		m, my_enaslt0_ex
				; 拡張スロットではなかった場合
				ld		c, a					; C = A = [0][0][0][0][0][0][P][P]
				di								; 割り込み処理の 0038h が切り替わるのと、スロット弄ってる途中で割り込まれて暴走するのを防ぐために割り込み禁止
				in		a, [ppi_slot_reg]		; PPI portA (A8h) を読み、page0 に指定の [P][P] をセット
				and		a, 0b11111100
				or		a, c
				out		[ppi_slot_reg], a
				ret								; 割り込み禁止のまま戻る
				; 拡張スロットだった場合
	my_enaslt0_ex:
				and		a, 0x03
				ld		c, a					; C = [0][0][0][0][0][0][P][P]

				ld		hl, slttbl				; SLTTBL[slot] のアドレスを求める。FCC5h なので +0～+3 しても上位 FCh は変化しない。
				add		a, l
				ld		l, a					; HL = &SLTTBL[slot]

				ld		a, c
				rrca
				rrca
				or		a, c
				ld		c, a					; A = C = [P][P][0][0][0][0][P][P]
				di								; 割り込み処理の 0038h が切り替わるのと、スロット弄ってる途中で割り込まれて暴走するのを防ぐために割り込み禁止
				in		a, [ppi_slot_reg]		; PPI portA (A8h) を読み、page3 及び page0 に指定の [P][P] をセット
				ld		d, a					; 基本スロットレジスタをバックアップ
				and		a, 0b00111100
				or		a, c
				out		[ppi_slot_reg], a		; まずは page3 及び page0 を指定の基本スロットに切り替える
				ld		a, b					; 呼び出し時に指定されたスロット番号を A に取得
				and		a, 0b00001100			; 拡張スロットの番号を抽出 : [0][0][0][0][S][S][0][0]
				rrca							; page0 なので bit1, bit0 に来るようにシフト
				rrca
				ld		b, a					; B = A = [0][0][0][0][0][0][S][S]
				ld		a, [hl]					; 以前、拡張スロットレジスタに書き込んだバックアップを読み込む (BIOSと互換)
				and		a, 0b11111100			; page0 に対応する bit1, bit0 を [S][S] に差し換える
				or		a, b
				ld		[ext_slot_reg], a		; 拡張スロットレジスタを更新
				ld		[hl], a					; 拡張スロットレジスタのバックアップも更新（BIOSと互換）
				ld		a, d					; 基本スロットレジスタの元の値を A に。
				and		a, 0b11111100			; page0 だけ [P][P] に差し換える
				ld		b, a
				ld		a, c
				and		a, 0b00000011
				or		a, b
				out		[ppi_slot_reg], a		; page3 を元のスロットに戻す
				ret
			endscope

; -----------------------------------------------------------------------------
;	Page1 を切り替える ENASLT
;	input:
;		A .... 切り替えるスロットの番号  MSB [Ex][0][0][0][ExSlot][ExSlot][PrimarySlot][PrimarySlot] LSB
;	output:
;		なし
;	break:
;		AF,BC,DE,HL
;	comment:
;		di状態で戻る
; -----------------------------------------------------------------------------
			scope	my_enaslt1
my_enaslt1::
				ld		b, a					; B にスロット番号を保存。MSB [E][0][0][0][S][S][P][P] LSB
				and		a, 0x83					; 指定の基本スロット番号を取得する
				jp		m, my_enaslt1_ex
				; 拡張スロットではなかった場合
				rlca
				rlca
				ld		c, a					; C = A = [0][0][0][0][P][P][0][0]
				di								; スロット弄ってる途中で割り込まれて暴走するのを防ぐために割り込み禁止
				in		a, [ppi_slot_reg]		; PPI portA (A8h) を読み、page0 に指定の [P][P] をセット
				and		a, 0b11110011
				or		a, c
				out		[ppi_slot_reg], a
				ret								; 割り込み禁止のまま戻る
				; 拡張スロットだった場合
	my_enaslt1_ex:
				and		a, 0x03
				ld		c, a					; C = [0][0][0][0][0][0][P][P]

				ld		hl, slttbl				; SLTTBL[slot] のアドレスを求める。FCC5h なので +0～+3 しても上位 FCh は変化しない。
				add		a, l
				ld		l, a					; HL = &SLTTBL[slot]

				ld		a, c
				rlca
				rlca
				ld		c, a					; C = [0][0][0][0][P][P][0][0]
				rlca
				rlca
				rlca
				rlca
				or		a, c
				ld		c, a					; A = C = [P][P][0][0][P][P][0][0]
				di								; 割り込み処理の 0038h が切り替わるのと、スロット弄ってる途中で割り込まれて暴走するのを防ぐために割り込み禁止
				in		a, [ppi_slot_reg]		; PPI portA (A8h) を読み、page3 及び page0 に指定の [P][P] をセット
				ld		d, a					; 基本スロットレジスタをバックアップ
				and		a, 0b00110011
				or		a, c
				out		[ppi_slot_reg], a		; まずは page3 及び page1 を指定の基本スロットに切り替える
				ld		a, b					; 呼び出し時に指定されたスロット番号を A に取得
				and		a, 0b00001100			; 拡張スロットの番号を抽出 : [0][0][0][0][S][S][0][0]
				ld		b, a					; B = A = [0][0][0][0][S][S][0][0]
				ld		a, [hl]					; 以前、拡張スロットレジスタに書き込んだバックアップを読み込む (BIOSと互換)
				and		a, 0b11110011			; page1 に対応する bit3, bit2 を [S][S] に差し換える
				or		a, b
				ld		[ext_slot_reg], a		; 拡張スロットレジスタを更新
				ld		[hl], a					; 拡張スロットレジスタのバックアップを更新（BIOSと互換）
				ld		a, d					; 基本スロットレジスタの元の値を A に。
				and		a, 0b11110011			; page1 だけ [P][P] に差し換える
				ld		b, a
				ld		a, c
				and		a, 0b00001100
				or		a, b
				out		[ppi_slot_reg], a		; page3 を元のスロットに戻す
				ret
			endscope
page2_routine_on_ram_end::
		endscope
			org		page2_routine_on_rom + page2_routine_on_ram_end - page2_routine_on_ram

message_not_enough_memory::
			db		"Not enough memory", 0x0D, 0x0A, 0
