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
		100 DEFINTA-Z:COLOR15,4,7:SCREEN1:I=0
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
		0000| FF 19 80 64 00 AC 41 F2 5A 3A BD 0F 0F 2C 15 2C
		0010| 18 3A C5 12 3A 49 EF 11 00 3E 80 6E 00 8F 20 2D
		0020| 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D
		0030| 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 00 4F 80
		0040| 78 00 CB EF 11 3A 82 49 EF 11 D9 1C 10 27 00 61
		0050| 80 82 00 8B 20 49 EF 1C D2 04 20 DA 20 4A EF 11
		0060| 00 6B 80 8C 00 83 3A 91 20 CB 00 90 80 96 00 8F
		0070| 20 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D
		0080| 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 00
		0090| A1 80 A0 00 CB EF 11 3A 82 49 EF 11 D9 1C 10 27
		00A0| 00 B3 80 AA 00 8B 20 1C D2 04 EF 49 20 DA 20 4A
		00B0| EF 11 00 BD 80 B4 00 83 3A 91 20 CB 00 00 00

	次に、OpenMSX で実行中のメモリの 8000h～ を覗いてみると、
	ほぼそのままの形で入っているのを確認できる。

		    | +0 +1 +2 +3 +4 +5 +6 +7 +8 +9 +A +B +C +D +E +F
		----+------------------------------------------------
		8000| 00 19 80 64 00 AC 41 F2 5A 3A BD 0F 0F 2C 15 2C
		8010| 18 3A C5 12 3A 49 EF 11 00 3E 80 6E 00 8F 20 2D
		8020| 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D
		8030| 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 00 4F 80
		8040| 78 00 CB EF 11 3A 82 49 EF 11 D9 1C 10 27 00 61
		8050| 80 82 00 8B 20 49 EF 1C D2 04 20 DA 20 4A EF 11
		8060| 00 6B 80 8C 00 83 3A 91 20 CB 00 90 80 96 00 8F
		8070| 20 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D
		8080| 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 2D 00
		8090| A1 80 A0 00 CB EF 11 3A 82 49 EF 11 D9 1C 10 27
		80A0| 00 B3 80 AA 00 8B 20 1C D2 04 EF 49 20 DA 20 4A
		80B0| EF 11 00 BD 80 B4 00 83 3A 91 20 CB 00 00 00 02
		80C0| 49 00 00 00

	各行に対応する先頭アドレスは、下記のようになる。
	行100 8001h
	行110 8019h
	行120 803Eh
	行130 804Fh
	行140 8061h
	行150 806Bh
	行160 8090h
	行170 80A1h
	行180 80B3h

	変数 I の保持領域は、80BFh～80C3h。02 49 00 00 00
	[02h] 2byte変数を示す値
	[49h][00h] 変数名 'I' ' '
	[0000h] その変数が保持する値

	差が出る IF文は、行130 と 行170 に存在する。
	BASIC中間コードの "IF" に対応するコードは、8Bh である。

	行130 の内容
		[次行のアドレス 8061h][行番号130 = 0082h][IF(8Bh)][' '(20h)]['I'(49h)]['='(EFh)][1234(1Ch, 04D2h)][' '(20h)][THEN(DAh)] ...
		                                                            ↑                  ↑
		                                                            8055h               8057h
	行170 の内容
		[次行のアドレス 80B3h][行番号170 = 00AAh][IF(8Bh)][' '(20h)][1234(1Ch, 04D2h)]['='(EFh)]['I'(49h)][' '(20h)][THEN(DAh)] ...
		                                                            ↑                          ↑
		                                                            80A7h                       80ABh

	IF文の中の条件式の先頭アドレスは、行130は 8051h、行170は 80A3h だとわかる。
	OpenMSX のデバッガで、これらのアドレスがリードされたときにブレイクする仕掛けをセットして動きを見てみる。

4. 行130の I を読むときの挙動
	8055h の Memory read にブレイクポイントをセットすると、466Bh で停止する。

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
		            → HL = 80C4h
		6262h: LD   B, 0
		6264h: ADD  HL, BC
		6265h: ADD  HL, BC			; HL = 80C6h
		6266h: LD   A, 0E5h			; 一見無意味だが、別の場所から 6267h へ飛んでくるケースがある。E5 = PUSH HL。
		6268h: LD   A, 088h
		626Ah: SUB  L
		626Bh: LD   L, A			; HL = 80C2h
		626Ch: LD   A, 0FFh
		626Eh: SBC  A, H			; Cy = 0
		626Fh: LD   H, A			; HL = 7EC2h
		6270h: JR   C, 6275h
		6272h: ADD  HL, SP			; Cy = 1
		6273h: POP  HL
		6274h: RET  C				; 戻る

		4C6Dh: CALL 0FF66h			; H.FRME → RETなので何もせずに戻ってくる
		4C70h: CALL 04DC7h

		4DC7h: RST  10h				; CHRGTR → A = 'I'(49h), HL = 8054h
		4DC8h: JP   Z, 406Ah		; スルー
		4DCBh: JP   C, 3299h		; スルー
		4DCEh: CALL 64A8h			; isalpha( A ) : アルファベットなら Cy = 0

		64A8h: CP   'A'				; HL = 8055h, A = 'I'
		64AAh: RET  C
		64ABh: CP   'Z'+1
		64ADh: CCF
		64AEh: RET					; Cy = 0

		4DD1h: JP   NC, 4E9Bh		; アルファベットなので Cy = 0, ジャンプ

		4E9Bh: CALL 5EA4h

		5EA4h: XOR  A
		5EA5h: LD   (0F662h), A		; DIMFLG
		5EA8h: LD   C, (HL)			; HL = 8055h, C = 'I' (49h)
		5EA9h: CALL 0FFA2h			; H.PTRG : ただし ret なので何もしないで戻ってくる
		5EACh: CALL 064A7h			; isalpha( peek(HL) ) : アルファベットなら Cy = 0

		64A7h: LD   A, (HL)			; HL = 8055h: A = 'I' (49h)
		64A8h: CP   'A'				; HL = 8055h, A = 'I'
		64AAh: RET  C
		64ABh: CP   'Z'+1
		64ADh: CCF
		64AEh: RET					; Cy = 0

		5EAFh: JP   C, 4055h		; Cy = 0 なので、スルー
		5EB2h: XOR  A
		5EB3h: LD   B, A
		5EB4h: RST  10h				; CHRGTR

		0010h: JP   2686h
		2686h: JP   4666h
		4666h: CALL 0FF48h			; H.CHRG : ただし ret なので何もしないで戻ってくる
		4669h: INC  HL				; HL = 8056h
		466Ah: LD   A, (HL)			; 変数名の 2文字目評価？ A = 0EFh ('='の中間コード)
		466Bh: CP   3Ah				; 数字かな？
		466Dh: RET  NC				; 数字じゃ無いから戻る

		5EB5h: JR   C, 5EBCh		; Cy = 0 なのでスルー
		5EB7h: CALL 64A8h			; isalpha( A )

		64A8h: CP   'A'				; A = 0EFh ('='の中間コード)
		64AAh: RET  C
		64ABh: CP   'Z'+1
		64ADh: CCF
		64AEh: RET					; Cy = 1

		5EBAh: JR   C, 5EC5h		; Cy = 1 なのでジャンプ

		5EC5h: CP   '&'				; CP 26h → Cy = 0
		5EC7h: JR   NC, 5EE0h		; Cy = 0 なのでジャンプ

		5EE0h: LD   A, C			; A = 'I'
		5EE1h: AND  7Fh
		5EE3h: LD   E, A
		5EE4h: LD   D, 0
		5EE6h: PUSH HL
		5EE7h: LD   HL, 0F689h		; TEMPST(F67AH, 3 * NUMTMP) 00 00 00 ... が詰まってる
		5EEAh: ADD  HL, DE			; HL = F6D2h : 02 02 02 ... が詰まってる
		5EEBh: LD   D, (HL)			; D = 2
		5EECh: POP  HL				; HL = 8056h (BASICコードのアドレス) '='(0EFh) の位置
		5EEDh: DEC  HL				; HL = 8055h 'I'
		5EEEh: LD   A,D             ; A = 2
		5EEFh: LD   (0F663h), A		; VALTYP
		5EF2h: RST  10h				; CHRGTR

		0010h: JP   2686h
		2686h: JP   4666h
		4666h: CALL 0FF48h			; H.CHRG : ただし ret なので何もしないで戻ってくる
		4669h: INC  HL				; HL = 8056h
		466Ah: LD   A, (HL)			; 変数名の 2文字目評価？ A = 0EFh ('='の中間コード)
		466Bh: CP   3Ah				; 数字かな？
		466Dh: RET  NC				; 数字じゃ無いから戻る

		5EF3h: LD   A, (0F6A5h)		; A = (SUBFLG) : 0
		5EF6h: DEC  A				; A = 255
		5EF7h: JP   Z, 5FE8h		; スルー
		5EFAh: JP   P, 5F08h		; スルー
		5EFDh: LD   A, (HL)			; A = '=' (0EFh)
		5EFEh: SUB  28h				; A = 0C7h
		5F00h: JP   Z, 5FBAh		; スルー
		5F03h: SUB  33h				; A = 094h
		5F05h: JP   Z, 5FBAh		; スルー
		5F08h: XOR  A				; A = 0
		5F09h: LD   (0F6A5), A		; (SUBFLG) = A : 0
		5F0Ch: PUSH HL				; HL = 8056h
		5F0Dh: LD   A, (0F7B7h)		; A = (NOFUNS)
		5F10h: OR   A
		5F11h: LD   (0F7B4), A		; (PRMFLG) = A
		5F14h: JR   Z, 5F52h		; ジャンプ

		5F52h: LD   HL, (0F6C4h)	; HL = (ARYTAB) : 80C4h : 配列テーブルの開始番地
		5F55h: LD   (0F7B5h), HL	; (ARYTA2) = HL : 80C4h : サーチの終点
		5F58h: LD   HL, (0F6C2h)	; HL = (VARTAB) : 80BFh : 単純変数の開始番地
		5F5Bh: JR   5F3Ah

		; 単純変数の存在確認？
		5F3Ah: EX   DE, HL
		5F3Bh: LD   A, (0F7B5h)		; A = (ARYTA2下位)
		5F3Eh: CP   E
		5F3Fh: JP   NZ, 5F23h		; ジャンプ

		; 変数サーチ？ BC に 2byte の変数名、VALTYP に変数の型番号(2は2byte整数変数)
		5F23h: LD   A, (DE)			; DE = 80BFh: A = 2
		5F24h: LD   L, A
		5F25h: INC  DE
		5F26h: LD   A, (DE)			; DE = 80C0h: A = 'I' (49h) 変数名1文字目
		5F27h: INC  DE
		5F28h: CP   C				; C = 'I' (49h) : 一致
		5F29h: JR   NZ, 5F36h		; スルー
		5F2Bh: LD   A, (0F663h)		; VALTYP
		5F2Eh: CP   L				; 変数の型
		5F2Fh: JR   NZ, 5F36h		; スルー
		5F31h: LD   A, (DE)			; DE = 80C1h: A = 00h 変数名2文字目
		5F32h: CP   B				; B = 00h : 一致。1文字変数なので 2文字目は 00h
		5F33h: JP   Z, 5FA4h		; ジャンプ

		5FA4h: INC  DE				; DE = 80C2h: 変数の値が格納されてるアドレス
		5FA5h: POP  HL				; HL = 8056h: '=' (0EFh) のアドレス
		5FA6h: RET

		4E9Eh: PUSH HL				; 8056h ('=')
		4E9Fh: EX   DE, HL			; DE = 8056h
		4EA0h: LD   (0F7F8h), HL	; 0F7F8h: DAC 3byte目
		4EA3h: RST  28H				; GETYPR: DACに格納されている値の型をフラグに反映
									; Zf = 0, Cf = 1, Pf = 1, Sf = 1 : Sf = 1 から整数型
		4EA4h: CALL NZ, 2F08h		; スルー: 文字列型の場合だけ特別処理が必要
		4EA7h: POP  HL				; 8056h
		4EA8h: RET

		4C73h: LD   (0F6BCh), HL	; TEMP2 = 8056h : (145行目の場所へ戻ってきた)
		4C76h: LD   HL, (0F6BCh)	; HL = 8056h
		4C79h: POP  BC				; 0049h (変数名 I)
		4C7Ah: LD   A, (HL)			; A = '=' (0EFh)
		4C7Bh: LD   (0F69Dh), HL	; TEMP3 = 8056h
		4C7Eh: CP   0EEh
		4C80h: RET  C				; スルー
		4C81h: CP   0F1h

===================== ここから↓、I=0 を追加前のアドレスで、アドレス値が少しズレてる ===
5. 行130の 1234 を読むときの挙動
	8057h の Memory read にブレイクポイントをセットすると、466Bh で停止する。

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
	80A7h の Memory read にブレイクポイントをセットすると、466Bh で停止する。

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

7. 行170の I を読むときの挙動
