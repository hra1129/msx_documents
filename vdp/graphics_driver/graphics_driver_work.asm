; =============================================================================
;	Work area for Graphics Driver
; -----------------------------------------------------------------------------
;	2023/July/2rd	t.hara (HRA!)
; =============================================================================

; -----------------------------------------------------------------------------
;	Customize parameters
; -----------------------------------------------------------------------------
grp_work					:= 0xC000									; このドライバーのワークエリア先頭アドレス
grp_sprite_max_num			:= 60										; 疑似スプライトの最大表示数N, MAX255

; -----------------------------------------------------------------------------
draw_page					:= grp_work + 0								; 1byte   : 描画ページ
sprite_fifo_ptr				:= draw_page + 1							; 2bytes  : これから表示する疑似スプライトの待ち行列のポインタ
sprite_fifo_draw_ptr		:= sprite_fifo_ptr + 2						; 2bytes  : 次に描画する疑似スプライトの待ち行列のポインタ
sprite_fifo_count			:= sprite_fifo_draw_ptr + 2					; 1byte   : sprite_fifo に積んだ数

sprite_fifo					:= sprite_fifo_count + 1					; 4N bytes: 疑似スプライトの待ち行列
sprite_fifo_end				:= sprite_fifo + grp_sprite_max_num * 4

erase_fifo_ptr				:= sprite_fifo_end							; 2bytes  : 疑似スプライト消去用の待ち行列のポインタ(2フレーム前)
erase_fifo_next_count		:= erase_fifo_ptr + 2						; 1byte   : 疑似スプライト消去用の待ち行列(1フレーム前)に積まれている数
erase_fifo_current_count	:= erase_fifo_next_count + 1				; 1byte   : 疑似スプライト消去用の待ち行列(2フレーム前)に積まれている数

erase_fifo_page0			:= erase_fifo_current_count + 1				; 2N bytes: 疑似スプライト消去用の待ち行列
erase_fifo_page0_end		:= erase_fifo_page0 + grp_sprite_max_num * 2

erase_fifo_page1			:= erase_fifo_page0_end						; 2N bytes: 疑似スプライト消去用の待ち行列
erase_fifo_page1_end		:= erase_fifo_page1 + grp_sprite_max_num * 2

grp_work_end				:= erase_fifo_page1_end
