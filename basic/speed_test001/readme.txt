MSX-BASIC の処理速度検証
														2023年2月26日 HRA!
===============================================================================

1. はじめに
	Twitter で、「IF A<0 THEN と IF 0>A THEN では、処理速度に差があり、後者の方
	が速い。」という検証結果が提示された。

	b.p.s.(@BasicProgrammer)さんの Tweet
	https://twitter.com/BasicProgrammer/status/1629748649889779713

	なるほど、興味深い。
	では、どうしてそのような差が生まれるのか？
	ここでは、その原因について解析する。

2. 確認
	OpenMSXのデバッガを使って解析するため、その環境で同様の差異が発生することを
	念のために確認しておく。FS-A1GTのBIOSを使って検証する。

	【検証コード】TEST1.BAS (ASCIIセーブ)
		100 DEFINTA-Z:COLOR15,4,7:SCREEN1
		110 REM ------------------------------
		120 TIME=0:FORI=0TO10000
		130 IF I=1234 THEN J=0
		140 NEXT:PRINT TIME
		150 REM ------------------------------
		160 TIME=0:FORI=0TO10000
		170 IF 1234=I THEN J=0
		180 NEXT:PRINT TIME
	【実行結果 1回目】
		313
		303
	【実行結果 2回目】
		313
		303

	このプログラムを TEST2.BAS の名前で通常セーブする。
		SAVE "TEST2.BAS"

3. メモリーイメージ
	TEST2.BAS をバイナリエディタで開くと下記のようになる。

		    | +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +A +B +C +D +E +F
		----+------------------------------------------------
		0000| FF 15 80 64 00 AC 41 F2 5A 3A BD 0F 0F 2C 15 2C
		0010| 18 3A C5 12 00 3A 80 6E 00 8F 20 2D 2D 2D 2D 2D
		0020| 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D
		0030| 2D 2D 2D 2D 2D 2D 2D 2D 2D 00 4B 80 78 00 CB EF
		0040| 11 3A 82 49 EF 11 D9 1C 10 27 00 5D 80 82 00 8B
		0050| 20 49 EF 1C D2 04 20 DA 20 4A EF 11 00 67 80 8C
		0060| 00 83 3A 91 20 CB 00 8C 80 96 00 8F 20 2D 2D 2D
		0070| 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D
		0080| 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 00 9D 80 A0 00
		0090| CB EF 11 3A 82 49 EF 11 D9 1C 10 27 00 AF 80 AA
		00A0| 00 8B 20 1C D2 04 EF 49 20 DA 20 4A EF 11 00 B9
		00B0| 80 B4 00 83 3A 91 20 CB 00 00 00

	次に、OpenMSX で実行中のメモリの 8000h～ を覗いてみると、
	ほぼそのままの形で入っているのを確認できる。

		    | +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +A +B +C +D +E +F
		----+------------------------------------------------
		8000| 00 15 80 64 00 AC 41 F2 5A 3A BD 0F 0F 2C 15 2C
		8010| 18 3A C5 12 00 3A 80 6E 00 8F 20 2D 2D 2D 2D 2D
		8020| 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D
		8030| 2D 2D 2D 2D 2D 2D 2D 2D 2D 00 4B 80 78 00 CB EF
		8040| 11 3A 82 49 EF 11 D9 1C 10 27 00 5D 80 82 00 8B
		8050| 20 49 EF 1C D2 04 20 DA 20 4A EF 11 00 67 80 8C
		8060| 00 83 3A 91 20 CB 00 8C 80 96 00 8F 20 2D 2D 2D
		8070| 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D
		8080| 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 00 9D 80 A0 00
		8090| CB EF 11 3A 82 49 EF 11 D9 1C 10 27 00 AF 80 AA
		80A0| 00 8B 20 1C D2 04 EF 49 20 DA 20 4A EF 11 00 B9
		80B0| 80 B4 00 83 3A 91 20 CB 00 00 00 02 49 00 11 27
		80C0| 02 4A 00 00 00 02 00

	各行に対応する先頭アドレスは、下記のようになる。
	行100 8001h
	行110 8015h
	行120 803Ah
	行130 804Bh
	行140 805Dh
	行150 8067h
	行160 808Ch
	行170 809Dh
	行180 80AFh

	変数 I の保持領域は、80BCh～80BFh。

	差が出る IF文は、行130 と 行170 に存在する。
	BASIC中間コードの "IF" に対応するコードは、8Bh である。

	行130 の内容
		[次行のアドレス 805Dh][行番号130 = 0082h][IF(8Bh)][' '(20h)]['I'(49h)]['='(EFh)][1234(1Ch, 04D2h)][' '(20h)][THEN(DAh)] ...
		                                                            ↑                  ↑
		                                                            8051h               8053h
	行170 の内容
		[次行のアドレス 80AFh][行番号170 = 00AAh][IF(8Bh)][' '(20h)][1234(1Ch, 04D2h)]['='(EFh)]['I'(49h)][' '(20h)][THEN(DAh)] ...
		                                                            ↑                          ↑
		                                                            80A3h                       80A7h

	IF文の中の条件式の先頭アドレスは、行130は 8051h、行170は 80A3h だとわかる。
	OpenMSX のデバッガで、これらのアドレスがリードされたときにブレイクする仕掛けをセットして動きを見てみる。

4. 行130の I を読むときの挙動
	8051h の Memory read にブレイクポイントをセットすると、466Bh で停止する。

		466Ah: LD   A, (HL)		; A ← 'I'(49h)
		466Bh: CP   3Ah			; Cy = 0
		466Dh: RET  NC			; return する

	どうやら、定数やスペースなどの処理か、それ以外かを判定しているところのようだ。
	'I' は、「それ以外」なので RET NC で戻る。

		49E5h: CD 4C64h

		4C64h: DEC  HL
		4C65h: LD   D, 0
		4C67h: PUSH DE
		4C68h: LD   C, 1
		4C6Ah: CALL 625Eh

		625Eh: PUSH HL
		625Fh: LD   HL, (F6C6h)		; STREND テキストエリアや変数エリアとして使用中であるメモリの最後の番地
		            → HL = 80C0h
		6262h: LD   B, 0
		6264h: ADD  HL, BC
		6265h: ADD  HL, BC			; HL = 80C2h
		6266h: LD   A, 0E5h			; 一見無意味だが、別の場所から 6267h へ飛んでくるケースがある。E5 = PUSH HL。
		6268h: LD   A, 088h
		626Ah: SUB  L
		626Bh: LD   L, A			; HL = 80C6h
		626Ch: LD   A, 0FFh
		626Eh: SBC  A, H			; Cy = 0
		626Fh: LD   H, A			; HL = 7EC6h
		6270h: JR   C, 6275h
		6272h: ADD  HL, SP			; Cy = 1
		6273h: POP  HL
		6274h: RET  C				; 戻る

		4C6Dh: CALL 0FF66h			; H.FRME → RETなので何もせずに戻ってくる
		4C70h: CALL 04DC7h

		4DC7h: RST  10h				; CHRGTR → A = 'I'(49h), HL = 8051h

5. 行130の 1234 を読むときの挙動
	8053h の Memory read にブレイクポイントをセットすると、466Bh で停止する。

		466Ah: LD   A, (HL)		; A ← 1Ch
		466Bh: CP   3Ah			; Cy = 1
		466Dh: RET  NC			; return しない
		466Eh: CP   20h			; Cy = 1, Z = 0
		4670h: JR   Z, 4666h	; スルー
		4672h: JR   NC, 46E0h	; スルー
		4674h: OR   A
		4675h: RET  Z			; スルー
		4676h: CP   0Bh
		4678h: JR   C, 46DBh	; スルー
		467Ah: CP   1Eh
		467Ch: JR   NZ,4683h	; ジャンプ

		4683h: CP   10h
		4685h: JR   Z, 46BBh	; スルー
		4687h: PUSH AF			; 1Ch をスタックへ
		4688h: INC  HL			; HL = 8054h
		4689h: LD   (F668h), A	; [CONSAV] = 1234
		468Ch: SUB  1Ch
		468Eh: JR   NC, 46C0h	; ジャンプ

		46C0h: INC  A			; A = 1
		46C1h: RLCA				; A = 2
		46C2h: LD   (F669h),A	; CONTYP = 2 : 2byte整数
		46C5h: PUSH DE			; DE = 02C0h
		46C6h: PUSH BC			; BC = 0043h
		46C7h: LD   DE, 0F66Ah	; CONLO 保存した定数の値 : 10 27 00 00 00 00 00 00
		46CAh: EX   DE, HL
		46CBh: LD   B, A		; B = 2
		46CCh: CALL 2EF7h		; CONLO へ数値をコピーするルーチン

		2EF7h: LD   A, (DE)		; DE = 8054h: A = D2h (中間コード 2byte整数)
		2EF8h: LD   (HL), A		; (CONLO + 0) = D2h
		2EF9h: INC  DE
		2EFAh: INC  HL
		2EFBh: DJNZ 2EF7h		; B = 1 になってジャンプ

		2EF7h: LD   A, (DE)		; DE = 8055h: A = 04h (中間コード 2byte整数)
		2EF8h: LD   (HL), A		; (CONLO + 1) = 04h
		2EF9h: INC  DE
		2EFAh: INC  HL
		2EFBh: DJNZ 2EF7h		; B = 0 になってスルー
		2EFDh: RET

		46CFh: EX   DE, HL
		46D0h: POP  BC			; BC = 0043h
		46D1h: POP  DE			; DE = 02C0h
		46D2h: LD   (0F666h), HL; (CONTXT) = 8056h
		46D5h: POP  AF			; A = 1Ch
		46D6h: LD   HL, 46E6h
		46D9h: OR   A
		46DAh: RET

		4CFBh: JR   4CE6h

		4CE6h: SUB  0EEh		; Cy = 1
		4CE8h: JR   C, 4D08h	; ジャンプ

		4D08h: LD   A, B		; A = 0
		4D09h: CP   64h			; Cy = 1
		4D0Bh: RET  NC			; スルー
		4D0Ch: PUSH BC
		4D0Dh: PUSH DE

6. 行170の 1234 を読むときの挙動
	80A3h の Memory read にブレイクポイントをセットすると、466Bh で停止する。

		466Ah: LD   A, (HL)		; A ← 1Ch
		466Bh: CP   3Ah			; Cy = 1
		466Dh: RET  NC			; return しない
		466Eh: CP   20h			; Cy = 1, Z = 0
		4670h: JR   Z, 4666h	; スルー
		4672h: JR   NC, 46E0h	; スルー
		4674h: OR   A
		4675h: RET  Z			; スルー
		4676h: CP   0Bh
		4678h: JR   C, 46DBh	; スルー
		467Ah: CP   1Eh
		467Ch: JR   NZ,4683h	; ジャンプ

		4683h: CP   10h
		4685h: JR   Z, 46BBh	; スルー
		4687h: PUSH AF			; 1Ch をスタックへ
		4688h: INC  HL			; HL = 80A4h
		4689h: LD   (F668h), A	; [CONSAV] = 1234
		468Ch: SUB  1Ch
		468Eh: JR   NC, 46C0h	; ジャンプ

		46C0h: INC  A			; A = 1
		46C1h: RLCA				; A = 2
		46C2h: LD   (F669h),A	; CONTYP = 2 : 2byte整数
