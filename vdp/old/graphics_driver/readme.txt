ワークエリア
	draw_page ......... 1 byte。描画ページを示す番号。0 か 1 のどちらか。表示ページは 1 - draw_page。
	sprite_put_fifo ... 4 * N bytes。N は任意。N は最大表示数。任意に指定可能。
	sprite_fifo_ptr ... 2 bytes。sprite_put_fifo への読み書きポインタ。
