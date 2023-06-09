; -----------------------------------------------------------------------------
;  Sprite Driver work area for Sprite Mode2
; =============================================================================
;  Copyright (c) 2023 t.hara
;  
;  Permission is hereby granted, free of charge, to any person obtaining a copy
;  of this software and associated documentation files (the "Software"), to deal
;  in the Software without restriction, including without limitation the rights
;  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;  copies of the Software, and to permit persons to whom the Software is
;  furnished to do so, subject to the following conditions:
;  
;  The above copyright notice and this permission notice shall be included in all
;  copies or substantial portions of the Software.
;  
;  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;  SOFTWARE.
; -----------------------------------------------------------------------------
;  Copyright (c) 2023 t.hara
;  
;  以下に定める条件に従い、本ソフトウェアおよび関連文書のファイル（以下「ソフト
;  ウェア」）の複製を取得するすべての人に対し、ソフトウェアを無制限に扱うことを
;  無償で許可します。
;  これには、ソフトウェアの複製を使用、複写、変更、結合、掲載、頒布、サブライセ
;  ンス、および/または販売する権利、およびソフトウェアを提供する相手に同じことを
;  許可する権利も無制限に含まれます。
;  
;  上記の著作権表示および本許諾表示を、ソフトウェアのすべての複製または重要な部
;  分に記載するものとします。
;  
;  ソフトウェアは「現状のまま」で、明示であるか暗黙であるかを問わず、何らの保証
;  もなく提供されます。ここでいう保証とは、商品性、特定の目的への適合性、および
;  権利非侵害についての保証も含みますが、それに限定されるものではありません。
;  作者または著作権者は、契約行為、不法行為、またはそれ以外であろうと、ソフト
;  ウェアに起因または関連し、あるいはソフトウェアの使用またはその他の扱いによっ
;  て生じる一切の請求、損害、その他の義務について何らの責任も負わないものとしま
;  す。
; =============================================================================
;  History
;  2023/June/6th	t.hara
; -----------------------------------------------------------------------------

; 下記がワークエリアで、内容は spdrv_initialize で初期化される。
; ROMカートリッジに搭載する場合などで、コード上にワークエリアを置けない場合は、
; 下記のラベルについて、下記のサイズを確保出来る RAM上のアドレスを指定すれば
; 動作する。
; The following is the work area, the contents of which are initialized by 
; spdrv_initialize.
; If the work area cannot be placed on the code, for example, when installing 
; in a ROM cartridge, it works by specifying an address in RAM that can secure 
; the following size for the following labels.
;
; labels:
;   sprite_page ........ 1byte
;   sprite_index ....... 1byte
;   sprite_color_work .. 32bytes
;   sprite_attribute ... 256bytes
;
sprite_page::
				db			0
sprite_index::
				db			0
sprite_index_debug::
				db			0
sprite_color_work::
				db			0, 0, 0, 0, 0, 0, 0, 0
				db			0, 0, 0, 0, 0, 0, 0, 0
				db			0, 0, 0, 0, 0, 0, 0, 0
				db			0, 0, 0, 0, 0, 0, 0, 0
sprite_attribute::
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #0
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #1
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #2
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #3
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #4
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #5
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #6
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #7
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #8
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #9
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #10
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #11
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #12
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #13
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #14
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #15
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #16
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #17
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #18
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #19
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #20
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #21
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #22
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #23
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #24
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #25
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #26
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #27
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #28
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #29
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #30
				db			0, 0, 0, 0, 0, 0, 0, 0		; sprite #31
