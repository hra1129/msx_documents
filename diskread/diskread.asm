; =============================================================================
;	MSX-BASIC環境下でファイルを読むサンプルプログラム
; -----------------------------------------------------------------------------
;	2022年10月11日  Programmed by HRA!
; =============================================================================

BDOS	:=		0xF37D
PUTS	:=		0x09
FOPEN	:=		0x0F
FCLOSE	:=		0x10
SETDTA	:=		0x1A
FREAD	:=		0x27

RECSIZE	:=		14
RECPOS	:=		33

; =============================================================================
;	BSAVEヘッダ
		db		0xFE
		dw		start_address
		dw		end_address
		dw		start_address

		org		0xC000
start_address::

; =============================================================================
;	ファイルを開く
		ld		de, fcb			; オープンされていないFCB のアドレス
		ld		c, FOPEN		; FOPENファンクション
		call	BDOS
		or		a, a			; 成功したときは A=0 が返り、FCBがオープンされたFCBに変化する
		jp		nz, open_error	; オープンに失敗した

; =============================================================================
;	DTAを設定する
		ld		de, dta			; Data Transfer Area のアドレス (ファイルの読み込み先)
		ld		c, SETDTA
		call	BDOS

; =============================================================================
;	ファイルを DTA へ読み込む
		ld		de, fcb
		ld		hl, 1			; レコードサイズ (2bytes)
		ld		[fcb + RECSIZE], hl
		ld		hl, 0			; レコード位置 (4bytes)
		ld		[fcb + RECPOS + 0], hl
		ld		[fcb + RECPOS + 2], hl
		ld		hl, 100			; レコード数
		ld		c, FREAD
		call	BDOS			; 成功したときは A=0 が返り、HL に実際に読み込んだレコード数が入る
		ld		a, h			; ただし、ファイルが指定のサイズ(今回の場合 100byte) に満たない場合もエラーになる
		or		a, l			; HLに実際に読み込んだレコード数が入っているので、それで判断する方が良い。
		jp		z, read_error	; リードに失敗した
		ld		[read_size], hl	; 読み込んだサイズを保存

; =============================================================================
;	ファイルを閉じる
		ld		de, fcb
		ld		c, FCLOSE
		call	BDOS

; =============================================================================
;	読み込んだ内容を画面に表示する
		ld		de, dta
		ld		hl, [read_size]
		add		hl, de
		ld		[hl], '$'		; ファイル内容の最後に '$' を付ける (PUTSの終了文字)
		ld		c, PUTS
		call	BDOS
		ret

; =============================================================================
;	エラー終了
open_error::
		ld		de, s_open_error
		jp		error_exit
read_error::
		ld		de, s_read_error
error_exit::
		ld		c, PUTS
		call	BDOS
		ret

s_open_error::
		ds		"OPEN ERROR.\r\n$"
s_read_error::
		ds		"READ ERROR.\r\n$"

; =============================================================================
;	ワークエリア
fcb::	; MSX-Datapack vol.1 p.405 : オープン前のFCB
		db		0				; ドライブ番号 (00h:デフォルトドライブ, 01h: A, 02h: B ...)
		ds		"TEST    "		; ファイル名 8文字
		ds		"TXT"			; 拡張子
		db		0				; CP/Mブロック番号
		space	36 - 13 + 1		; スペース確保

dta::
		space	256				; スペース確保

read_size::
		dw		0
end_address::
