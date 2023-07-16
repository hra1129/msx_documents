; ==============================================================================
;	search_pac
;
;  Copyright (C) 2023 Takayuki Hara (HRA!)
;  All rights reserved.
;                                              https://github.com/hra1129/
;
;  本ソフトウェアおよび本ソフトウェアに基づいて作成された派生物は、以下の条件を
;  満たす場合に限り、再頒布および使用が許可されます。
;
;  1.ソースコード形式で再頒布する場合、上記の著作権表示、本条件一覧、および下記
;    免責条項をそのままの形で保持すること。
;  2.バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の
;    著作権表示、本条件一覧、および下記免責条項を含めること。
;  3.書面による事前の許可なしに、本ソフトウェアを販売、および商業的な製品や活動
;    に使用しないこと。
;
;  本ソフトウェアは、著作権者によって「現状のまま」提供されています。著作権者は、
;  特定目的への適合性の保証、商品性の保証、またそれに限定されない、いかなる明示
;  的もしくは暗黙な保証責任も負いません。著作権者は、事由のいかんを問わず、損害
;  発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失
;  その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知ら
;  されていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サ
;  ービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそ
;  れに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、ま
;  たは結果損害について、一切責任を負わないものとします。
;
;  Note that above Japanese version license is the formal document.
;  The following translation is only for reference.
;
;  Redistribution and use of this software or any derivative works,
;  are permitted provided that the following conditions are met:
;
;  1. Redistributions of source code must retain the above copyright
;     notice, this list of conditions and the following disclaimer.
;  2. Redistributions in binary form must reproduce the above
;     copyright notice, this list of conditions and the following
;     disclaimer in the documentation and/or other materials
;     provided with the distribution.
;  3. Redistributions may not be sold, nor may they be used in a
;     commercial product or activity without specific prior written
;     permission.
;
;  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
;  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
;  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
;  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
;  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
;  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
;  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;  POSSIBILITY OF SUCH DAMAGE.
; ==============================================================================

PAC_IO_SW1				:= 0x5FFE
PAC_IO_SW2				:= 0x5FFF
SCH_PAC_WORK			:= 0xF41F						; BIOSの KBUF。ワークエリアとして使う

SCH_PAC_PAGE1_SLOT		:= SCH_PAC_WORK					; 1byte : page1 slot# の保存場所
SCH_PAC_SLOT			:= SCH_PAC_PAGE1_SLOT + 1		; 1byte : 検出した PAC のスロット
SCH_PAC_CHECK_PAC		:= SCH_PAC_SLOT + 1

; ------------------------------------------------------------------------------
;	search_pac
;	input)
;		none
;	output)
;		A ..... PAC Slot#
;	break)
;		all
;	description)
;		PAC の存在を調べて、そのスロット番号を返す。
;		見つからなかった場合は、A には FFh が返る。
; ------------------------------------------------------------------------------
			scope		search_pac
search_pac::
			; page1 slot# を求めて SCH_OPLL_PAGE1_SLOT に格納
			call		get_page1_slot
			ld			[ SCH_PAC_PAGE1_SLOT ], a

			; 指定のスロットがPACであるか調べるルーチンを Page3へコピーする
			ld			hl, check_pac_start
			ld			de, SCH_PAC_CHECK_PAC
			ld			bc, check_pac_size
			ldir

			; PAC はまだ見つかっていない
			ld			a, 0xFF
			ld			[ SCH_PAC_SLOT ], a
			inc			a
			jr			enter_primary_slot_loop
	primary_slot_loop:
			inc			a
			and			a, 0b000000_11
			jr			z, not_found_pac				; 一巡してしまった場合、見つからなかった判定へ。
	enter_primary_slot_loop:
			; 拡張スロットフラグ
			ld			b, a
			ld			h, EXPTBL >> 8
			add			a, EXPTBL & 255
			ld			l, a
			ld			a, [hl]
			and			a, 0x80
			or			a, b
	expansion_slot_loop:
			push		af
			; 現在着目しているスロットが PAC かどうか調べる
			call		check_pac
			cp			a, 0xFF
			jr			z, no_match
			pop			hl								; スタック捨て
			ei
			ret
	no_match:
			pop			af
			; PAC ではなかったので、次のスロット
			or			a, a							; 拡張されたスロットか？
			jp			p, primary_slot_loop			; 拡張されたスロットでないので、次の基本スロットへ。
			add			a, 0x04							; 次の拡張スロット
			bit			4, a							; 拡張スロットも全部見終わった？
			jr			z, expansion_slot_loop			; まだ残ってる場合は、expansion_slot_loop へ。
			jr			primary_slot_loop				; 次の基本スロットへ。
	not_found_pac:
			; 全スロット調べた
			ei
			ld			a, [SCH_PAC_SLOT]
			ret
			endscope

; ------------------------------------------------------------------------------
;	open_pac
;	input)
;		A ..... PACのスロット (※これが PAC であるかのチェックは行いません)
;	output)
;		none
;	break)
;		all
;	description)
;		page1 を PAC のスロットへ切り替えて、SRAMを出現させます。
;		このルーチンの中で割り込み禁止にして、そのまま戻ります。
;		page1 を PAC のスロットへ切り替えて戻るので、page1 から呼び出すと
;		暴走するのでご注意下さい。
;		このルーチン自体が page1 に存在していても問題ありません。
;		A に PAC 以外のスロットを指定した場合の動作は保証しません。
;		SRAMへのアクセスが完了後に、page1 を元のスロットへ戻すのは、
;		disable_pac で戻して下さい。
;		H.TIMI から OPLDRV を呼ぶようにしていて、FMPAC のスロットを A に指定
;		して呼び出している場合、disable_pac せずに ENASLT で page1 を戻すと
;		FMPAC のスロットに OPLDRV が見えなくなっている（SRAMになっている)状態
;		になり、暴走するのでご注意下さい。
; ------------------------------------------------------------------------------
			scope		open_pac
open_pac::
			; 指定のスロットがPACであるか調べるルーチンを Page3へコピーする
			ld			hl, open_pac_sub_start
			ld			de, SCH_PAC_CHECK_PAC
			ld			bc, open_pac_sub_size
			ldir
			jp			open_pac_sub

open_pac_sub_start:
			org			SCH_PAC_CHECK_PAC
open_pac_sub:
			; page1 を指定のスロットへ切り替える
			ld			h, 0x40
			call		ENASLT
			; SRAMバンクに切り替える
			ld			hl, 0x694D				; SRAMバンクID
			ld			[PAC_IO_SW1], hl
			ret
open_pac_sub_end:
open_pac_sub_size		= open_pac_sub_end - open_pac_sub
			org			open_pac_sub_start + open_pac_sub_size
			endscope

; ------------------------------------------------------------------------------
;	close_pac
;	input)
;		A ..... page1 に出現させるスロット
;	output)
;		none
;	break)
;		all
;	description)
;		open_pac した後に、page1 を元に戻す場合に close_pac を使います。
;		SRAMを隠してからスロットを切り替えるので、FMPAC の FM-BIOS が復活します。
;		open_pac した場合は、必ずこのルーチンで page1 を戻して下さい。
; ------------------------------------------------------------------------------
			scope		close_pac
close_pac::
			; 指定のスロットがPACであるか調べるルーチンを Page3へコピーする
			ld			hl, close_pac_sub_start
			ld			de, SCH_PAC_CHECK_PAC
			ld			bc, close_pac_sub_size
			ldir
			jp			close_pac_sub

close_pac_sub_start:
			org			SCH_PAC_CHECK_PAC
close_pac_sub:
			; SRAMを隠す
			ld			[PAC_IO_SW1], bc
			; page1 を指定のスロットへ切り替える
			ld			h, 0x40
			call		ENASLT
			ret
close_pac_sub_end:
close_pac_sub_size		= close_pac_sub_end - close_pac_sub
			org			close_pac_sub_start + close_pac_sub_size
			endscope

; ------------------------------------------------------------------------------
;	check_pac
;	input)
;		A ..... 対象のスロット
;	output)
;		A ..... PACだった場合、対象のスロット。PACでなかった場合、0xFF が返る。
;	break)
;		all
;	description)
;		このルーチンの中で割り込み禁止にして、そのまま戻ります。
; ------------------------------------------------------------------------------
check_pac_start::
			org			SCH_PAC_CHECK_PAC
			scope		check_pac
check_pac::
			push		af
			ld			b, a
			ld			a, 0xFF
			ld			[SCH_PAC_SLOT], a
			ld			a, b
			; 対象のスロットへ切り替える
			ld			h, 0x40
			call		ENASLT
			; 対象のスロットが書き替え不可能であることを確認する
			ld			hl, 0x4000
			call		check_ram
			jr			z, no_match				; RAM なら PAC ではない
			ld			hl, 0x4800
			call		check_ram
			jr			z, no_match				; RAM なら PAC ではない
			; SRAMバンクに切り替える
			ld			hl, 0x694D				; SRAMバンクID
			ld			[PAC_IO_SW1], hl
			; 対象のスロットが書き替え可能であることを確認する
			ld			hl, 0x4000
			call		check_ram
			jr			nz, no_match			; RAM でないなら PAC ではない
			ld			hl, 0x4800
			call		check_ram
			jr			nz, no_match			; RAM でないなら PAC ではない
			; スロット番号を記録する
			pop			af
			ld			[SCH_PAC_SLOT], a
			; SRAMを隠す
			xor			a, a
			ld			[PAC_IO_SW1], a
	_exit:
			; 元のスロットへ戻す
			ld			a, [SCH_PAC_PAGE1_SLOT]
			ld			h, 0x40
			call		ENASLT
			ld			a, [SCH_PAC_SLOT]
			ret
	no_match:
			pop			af
			jr			_exit
			; RAMかどうかチェックする
	check_ram:
			ld			a, [hl]
			cpl
			ld			[hl], a		; 反転したものを試しに書いてみる
			cp			a, [hl]		; 値が一致していれば、RAMの可能性あり
			cpl
			ld			[hl], a		; 元の値に戻す
			ret
check_pac_end::
			endscope
check_pac_size		:= check_pac_end - check_pac
			org			check_pac_start + check_pac_size
