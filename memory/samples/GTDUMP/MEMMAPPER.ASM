; ==============================================================================
;	Memory Mapper
;
;  Copyright (C) 2020 Takayuki Hara (HRA!)
;  All rights reserved.
;                           http://hraroom.s602.xrea.com/msx/software/mgsp.html
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
;	2020/9/22	t.hara	1.0		1st release
; ==============================================================================

; ==============================================================================
;	MapperSupportRoutine's table offset (This area is reference only)
; ==============================================================================
mmap_slot		:= 0			; 1byte, マッパーRAMのスロット番号
mmap_total_seg	:= 1			; 1byte, 総セグメント数
mmap_free_seg	:= 2			; 1byte, 未使用セグメント数
mmap_sys_seg	:= 3			; 1byte, システムに割り当てられたセグメント数
mmap_user_seg	:= 4			; 1byte, ユーザーに割り当てられたセグメント数
mmap_reserved	:= 5			; 3byte, 予約領域

; ==============================================================================
;	mmap_init
;	input)
;		--
;	output)
;		Zf ................. 1: MemoryMapperサポートルーチンが存在しない
;		[mmap_table_ptr] ... マッパーテーブルのアドレス
;	break)
;		all
; ==============================================================================
		scope	mmap_init
mmap_init::
		ld		c, D2F_DOSVER	; DOSバージョンをチェック
		call	bdos
		or		a, a			; A != 0 は DOS ではない
		jp		nz, mmap_error_exit
		ld		a, b
		cp		a, 2			; B < 2 の場合 MSX-DOS1 である
		jp		c, mmap_error_exit

		ld		a, [hokvld]
		and		a, 1
		ret		z				; 拡張BIOSが存在しない場合はエラー(Zf=1)

		; get MapperSupportRoutine's table
		xor		a, a
		ld		de, 0x0401		; D=MemoryMapperSupportRoutine ID, E=01h
		call	extbio
		or		a, a
		ret		z				; マッパーサポートルーチンが存在しない場合はエラー(Zf=1)
		ld		[mmap_table_ptr], hl

		; get jump table
		ld		de, 0x0402		; D=MemoryMapperSupportRoutine ID, E=02h
		call	extbio
		ld		de, mapper_jump_table
		ld		bc, 16 * 3
		ldir

		; get current segment on page1
		call		mapper_get_p1
		ld			[mapper_segment_p1], a
		call		mapper_get_p2
		ld			[mapper_segment_p2], a

		xor		a, a
		inc		a
		ret						; 正常終了 (Zf=0)
mmap_error_exit:
		xor		a, a
		ret
		endscope

; ==============================================================================
;	スロット構成を TPA に戻す
; ==============================================================================
		scope		mmap_change_to_tpa
mmap_change_to_tpa::
		; change slot of page1
		ld			h, 0x40
		ld			a, [ramad1]
		call		enaslt

		; change slot of page2
		ld			h, 0x80
		ld			a, [ramad2]
		call		enaslt

		; change mapper segment of page1
		ld			a, [mapper_segment_p1]
		call		mapper_put_p1

		; change mapper segment of page2
		ld			a, [mapper_segment_p2]
		call		mapper_put_p2
		ei
		ret
		endscope

; ==============================================================================
;		WORKAREA
; ==============================================================================
mmap_table_ptr::
		dw			0				; マッパーテーブルのアドレスが格納される
mapper_segment_p1:
		db			0				; 起動時の page1 のセグメント番号
mapper_segment_p2:
		db			0				; 起動時の page2 のセグメント番号

mapper_jump_table::
mapper_all_seg::	; +00h
		db			0xc9, 0xc9, 0xc9
mapper_fre_seg::	; +03h
		db			0xc9, 0xc9, 0xc9
mapper_rd_seg::		; +06h
		db			0xc9, 0xc9, 0xc9
mapper_wr_seg::		; +09h
		db			0xc9, 0xc9, 0xc9
mapper_cal_seg::	; +0Ch
		db			0xc9, 0xc9, 0xc9
mapper_calls::		; +0Fh
		db			0xc9, 0xc9, 0xc9
mapper_put_ph::		; +12h
		db			0xc9, 0xc9, 0xc9
mapper_get_ph::		; +15h
		db			0xc9, 0xc9, 0xc9
mapper_put_p0::		; +18h
		db			0xc9, 0xc9, 0xc9
mapper_get_p0::		; +1Bh
		db			0xc9, 0xc9, 0xc9
mapper_put_p1::		; +1Eh
		db			0xc9, 0xc9, 0xc9
mapper_get_p1::		; +21h
		db			0xc9, 0xc9, 0xc9
mapper_put_p2::		; +24h
		db			0xc9, 0xc9, 0xc9
mapper_get_p2::		; +27h
		db			0xc9, 0xc9, 0xc9
mapper_put_p3::		; +2Ah
		db			0xc9, 0xc9, 0xc9
mapper_get_p3::		; +2Dh
		db			0xc9, 0xc9, 0xc9
