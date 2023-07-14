; ==============================================================================
;	Search OPLL
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
; ------------------------------------------------------------------------------
;	Date		Author	Ver		Description
;	2023/7/14	t.hara	1.0		1st release
; ==============================================================================

; require include "msx.asm"
; require include "get_page1_slot.asm"

EXTOPLL_IO_SW			:= 0x7FF6
OPLL_SIGNATURE			:= 0x4018
SIGNATURE_WORK			:= 0xF41F						; BIOSの KBUF。ワークエリアとして使う

SCH_OPLL_PAGE1_SLOT		:= SIGNATURE_WORK				; 1byte : page1 slot# の保存場所
SCH_OPLL_SLOT			:= SCH_OPLL_PAGE1_SLOT + 1		; 1byte : 見つけた OPLLスロット
SCH_OPLL_SIGNATURE		:= SCH_OPLL_SLOT + 1			; 8bytes: 4018h～ の 8byte の一時保管場所
SCH_OPLL_COPY_SIGNATURE	:= SCH_OPLL_SIGNATURE + 8		; Xbytes: 指定のスロットの 4018h を SCH_OPLL_SIGNATUREへコピーするルーチン置き場

; ------------------------------------------------------------------------------
;	search_opll
;	input)
;		none
;	output)
;		A ..... OPLL Slot#
;	break)
;		all
;	description)
;		MSX-MUSIC の存在を調べて、そのスロット番号を返す。
;		見つからなかった場合は、A には 00h が返る。
; ------------------------------------------------------------------------------
			scope		search_opll
search_opll::
			; page1 slot# を求めて SCH_OPLL_PAGE1_SLOT に格納
			call		get_page1_slot
			ld			[ SCH_OPLL_PAGE1_SLOT ], a

			; 指定のスロットの指定のアドレスから 8byte 読み取るルーチンを Page3へコピーする
			ld			hl, copy_signature_source_start
			ld			de, SCH_OPLL_COPY_SIGNATURE
			ld			bc, copy_signature_size
			ldir

			; OPLL はまだ見つかっていない
			ld			a, 0xFF
			ld			[ SCH_OPLL_SLOT ], a
			inc			a
			jr			enter_primary_slot_loop
	primary_slot_loop:
			inc			a
			and			a, 0b000000_11
			jr			z, not_found_aprlopll			; APRLOPLL が見つからなかった場合一巡する。XXXXOPLL が見つかったか調べる。
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
			; 現在着目しているスロットの Signature を読み取る
			call		copy_signature
			; 後半4byte が "OPLL" か調べる
			ld			hl, s_opll
			ld			de, SCH_OPLL_SIGNATURE + 4
			ld			b, 4
	compare_opll_loop:
			ld			a, [de]
			inc			de
			cp			a, [hl]
			inc			hl
			jr			nz, no_match
			djnz		compare_opll_loop
			; OPLL が見つかったのでスロット番号保存
			pop			af
			push		af
			ld			[SCH_OPLL_SLOT], a
			; 前半4byte が "APRL" か調べる
			ld			hl, s_aprl
			ld			de, SCH_OPLL_SIGNATURE + 0
			ld			b, 4
	compare_aprl_loop:
			ld			a, [de]
			inc			de
			cp			a, [hl]
			inc			hl
			jr			nz, no_match
			djnz		compare_aprl_loop
			; APRLOPLL が見つかったので、戻る
			pop			af
			ei
			ret
	no_match:
			pop			af
			; APRLOPLL が見つからなかったので、次のスロット
			or			a, a							; 拡張されたスロットか？
			jp			p, primary_slot_loop			; 拡張されたスロットでないので、次の基本スロットへ。
			add			a, 0x04							; 次の拡張スロット
			bit			4, a							; 拡張スロットも全部見終わった？
			jr			z, expansion_slot_loop			; まだ残ってる場合は、expansion_slot_loop へ。
			jr			primary_slot_loop				; 次の基本スロットへ。
	not_found_aprlopll:
			; 全スロット調べたが APRLOPLL が見つからなかった
			ei
			ld			a, [SCH_OPLL_SLOT]
			inc			a
			ret			z								; XXXXOPLL も見つからなかった
			dec			a
			; 見つけたスロットの EXTOPLL_IO_SW の bit0 を 1 にする
			ld			hl, EXTOPLL_IO_SW
			call		RDSLT
			or			a, 1
			ld			e, a
			ld			a, [SCH_OPLL_SLOT]
			ld			hl, EXTOPLL_IO_SW
			call		WRSLT
			ld			a, [SCH_OPLL_SLOT]
			ei
			ret
	s_aprl:
			ds			"APRL"
	s_opll:
			ds			"OPLL"
			endscope

; ------------------------------------------------------------------------------
;	copy_signature
;	input)
;		A ..... 対象のスロット
;	output)
;		SCH_OPLL_SIGNATURE ... 8byte に対象のスロットの 4018h～ の 8byte
;	break)
;		all
;	description)
;		このルーチンの中で割り込み禁止にして、そのまま戻ります。
; ------------------------------------------------------------------------------
copy_signature_source_start::
			org			SCH_OPLL_COPY_SIGNATURE
			scope		copy_signature
copy_signature::
			; 対象のスロットへ切り替える
			ld			h, 0x40
			call		ENASLT
			; 8byteコピーする
			ld			hl, OPLL_SIGNATURE
			ld			de, SCH_OPLL_SIGNATURE
			ld			bc, 8
			ldir
			; 元のスロットへ戻す
			ld			a, [SCH_OPLL_PAGE1_SLOT]
			ld			h, 0x40
			call		ENASLT
			ret
copy_signature_end::
			endscope
copy_signature_size		:= copy_signature_end - copy_signature
			org			copy_signature_source_start + copy_signature_size
