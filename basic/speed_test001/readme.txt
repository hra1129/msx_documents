MSX-BASIC �̏������x����
														2023�N2��26�� HRA!
===============================================================================

1. �͂��߂�
	Twitter �ŁA�uIF A<0 THEN �� IF 0>A THEN �ł́A�������x�ɍ�������A��҂̕�
	�������B�v�Ƃ������،��ʂ��񎦂��ꂽ�B

	b.p.s.(@BasicProgrammer)����� Tweet
	https://twitter.com/BasicProgrammer/status/1629748649889779713

	�Ȃ�قǁA�����[���B
	�ł́A�ǂ����Ă��̂悤�ȍ������܂��̂��H
	�����ł́A���̌����ɂ��ĉ�͂���B

2. �m�F
	OpenMSX�̃f�o�b�K���g���ĉ�͂��邽�߁A���̊��œ��l�̍��ق��������邱�Ƃ�
	�O�̂��߂Ɋm�F���Ă����BFS-A1GT��BIOS���g���Č��؂���B

	�y���؃R�[�h�zTEST1.BAS (ASCII�Z�[�u)
		100 DEFINTA-Z:COLOR15,4,7:SCREEN1
		110 REM ------------------------------
		120 TIME=0:FORI=0TO10000
		130 IF I=1234 THEN J=0
		140 NEXT:PRINT TIME
		150 REM ------------------------------
		160 TIME=0:FORI=0TO10000
		170 IF 1234=I THEN J=0
		180 NEXT:PRINT TIME
	�y���s���� 1��ځz
		313
		303
	�y���s���� 2��ځz
		313
		303

	���̃v���O������ TEST2.BAS �̖��O�Œʏ�Z�[�u����B
		SAVE "TEST2.BAS"

3. �������[�C���[�W
	TEST2.BAS ���o�C�i���G�f�B�^�ŊJ���Ɖ��L�̂悤�ɂȂ�B

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

	���ɁAOpenMSX �Ŏ��s���̃������� 8000h�` ��`���Ă݂�ƁA
	�قڂ��̂܂܂̌`�œ����Ă���̂��m�F�ł���B

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

	�e�s�ɑΉ�����擪�A�h���X�́A���L�̂悤�ɂȂ�B
	�s100 8001h
	�s110 8015h
	�s120 803Ah
	�s130 804Bh
	�s140 805Dh
	�s150 8067h
	�s160 808Ch
	�s170 809Dh
	�s180 80AFh

	�ϐ� I �̕ێ��̈�́A80BCh�`80BFh�B

	�����o�� IF���́A�s130 �� �s170 �ɑ��݂���B
	BASIC���ԃR�[�h�� "IF" �ɑΉ�����R�[�h�́A8Bh �ł���B

	�s130 �̓��e
		[���s�̃A�h���X 805Dh][�s�ԍ�130 = 0082h][IF(8Bh)][' '(20h)]['I'(49h)]['='(EFh)][1234(1Ch, 04D2h)][' '(20h)][THEN(DAh)] ...
		                                                            ��                  ��
		                                                            8051h               8053h
	�s170 �̓��e
		[���s�̃A�h���X 80AFh][�s�ԍ�170 = 00AAh][IF(8Bh)][' '(20h)][1234(1Ch, 04D2h)]['='(EFh)]['I'(49h)][' '(20h)][THEN(DAh)] ...
		                                                            ��                          ��
		                                                            80A3h                       80A7h

	IF���̒��̏������̐擪�A�h���X�́A�s130�� 8051h�A�s170�� 80A3h ���Ƃ킩��B
	OpenMSX �̃f�o�b�K�ŁA�����̃A�h���X�����[�h���ꂽ�Ƃ��Ƀu���C�N����d�|�����Z�b�g���ē��������Ă݂�B

4. �s130�� I ��ǂނƂ��̋���
	8051h �� Memory read �Ƀu���C�N�|�C���g���Z�b�g����ƁA466Bh �Œ�~����B

		466Ah: LD   A, (HL)		; A �� 'I'(49h)
		466Bh: CP   3Ah			; Cy = 0
		466Dh: RET  NC			; return ����

	�ǂ����A�萔��X�y�[�X�Ȃǂ̏������A����ȊO���𔻒肵�Ă���Ƃ���̂悤���B
	'I' �́A�u����ȊO�v�Ȃ̂� RET NC �Ŗ߂�B

		49E5h: CD 4C64h

		4C64h: DEC  HL
		4C65h: LD   D, 0
		4C67h: PUSH DE
		4C68h: LD   C, 1
		4C6Ah: CALL 625Eh

		625Eh: PUSH HL
		625Fh: LD   HL, (F6C6h)		; STREND �e�L�X�g�G���A��ϐ��G���A�Ƃ��Ďg�p���ł��郁�����̍Ō�̔Ԓn
		            �� HL = 80C0h
		6262h: LD   B, 0
		6264h: ADD  HL, BC
		6265h: ADD  HL, BC			; HL = 80C2h
		6266h: LD   A, 0E5h			; �ꌩ���Ӗ������A�ʂ̏ꏊ���� 6267h �֔��ł���P�[�X������BE5 = PUSH HL�B
		6268h: LD   A, 088h
		626Ah: SUB  L
		626Bh: LD   L, A			; HL = 80C6h
		626Ch: LD   A, 0FFh
		626Eh: SBC  A, H			; Cy = 0
		626Fh: LD   H, A			; HL = 7EC6h
		6270h: JR   C, 6275h
		6272h: ADD  HL, SP			; Cy = 1
		6273h: POP  HL
		6274h: RET  C				; �߂�

		4C6Dh: CALL 0FF66h			; H.FRME �� RET�Ȃ̂ŉ��������ɖ߂��Ă���
		4C70h: CALL 04DC7h

		4DC7h: RST  10h				; CHRGTR �� A = 'I'(49h), HL = 8051h

5. �s130�� 1234 ��ǂނƂ��̋���
	8053h �� Memory read �Ƀu���C�N�|�C���g���Z�b�g����ƁA466Bh �Œ�~����B

		466Ah: LD   A, (HL)		; A �� 1Ch
		466Bh: CP   3Ah			; Cy = 1
		466Dh: RET  NC			; return ���Ȃ�
		466Eh: CP   20h			; Cy = 1, Z = 0
		4670h: JR   Z, 4666h	; �X���[
		4672h: JR   NC, 46E0h	; �X���[
		4674h: OR   A
		4675h: RET  Z			; �X���[
		4676h: CP   0Bh
		4678h: JR   C, 46DBh	; �X���[
		467Ah: CP   1Eh
		467Ch: JR   NZ,4683h	; �W�����v

		4683h: CP   10h
		4685h: JR   Z, 46BBh	; �X���[
		4687h: PUSH AF			; 1Ch ���X�^�b�N��
		4688h: INC  HL			; HL = 8054h
		4689h: LD   (F668h), A	; [CONSAV] = 1234
		468Ch: SUB  1Ch
		468Eh: JR   NC, 46C0h	; �W�����v

		46C0h: INC  A			; A = 1
		46C1h: RLCA				; A = 2
		46C2h: LD   (F669h),A	; CONTYP = 2 : 2byte����
		46C5h: PUSH DE			; DE = 02C0h
		46C6h: PUSH BC			; BC = 0043h
		46C7h: LD   DE, 0F66Ah	; CONLO �ۑ������萔�̒l : 10 27 00 00 00 00 00 00
		46CAh: EX   DE, HL
		46CBh: LD   B, A		; B = 2
		46CCh: CALL 2EF7h		; CONLO �֐��l���R�s�[���郋�[�`��

		2EF7h: LD   A, (DE)		; DE = 8054h: A = D2h (���ԃR�[�h 2byte����)
		2EF8h: LD   (HL), A		; (CONLO + 0) = D2h
		2EF9h: INC  DE
		2EFAh: INC  HL
		2EFBh: DJNZ 2EF7h		; B = 1 �ɂȂ��ăW�����v

		2EF7h: LD   A, (DE)		; DE = 8055h: A = 04h (���ԃR�[�h 2byte����)
		2EF8h: LD   (HL), A		; (CONLO + 1) = 04h
		2EF9h: INC  DE
		2EFAh: INC  HL
		2EFBh: DJNZ 2EF7h		; B = 0 �ɂȂ��ăX���[
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
		4CE8h: JR   C, 4D08h	; �W�����v

		4D08h: LD   A, B		; A = 0
		4D09h: CP   64h			; Cy = 1
		4D0Bh: RET  NC			; �X���[
		4D0Ch: PUSH BC
		4D0Dh: PUSH DE

6. �s170�� 1234 ��ǂނƂ��̋���
	80A3h �� Memory read �Ƀu���C�N�|�C���g���Z�b�g����ƁA466Bh �Œ�~����B

		466Ah: LD   A, (HL)		; A �� 1Ch
		466Bh: CP   3Ah			; Cy = 1
		466Dh: RET  NC			; return ���Ȃ�
		466Eh: CP   20h			; Cy = 1, Z = 0
		4670h: JR   Z, 4666h	; �X���[
		4672h: JR   NC, 46E0h	; �X���[
		4674h: OR   A
		4675h: RET  Z			; �X���[
		4676h: CP   0Bh
		4678h: JR   C, 46DBh	; �X���[
		467Ah: CP   1Eh
		467Ch: JR   NZ,4683h	; �W�����v

		4683h: CP   10h
		4685h: JR   Z, 46BBh	; �X���[
		4687h: PUSH AF			; 1Ch ���X�^�b�N��
		4688h: INC  HL			; HL = 80A4h
		4689h: LD   (F668h), A	; [CONSAV] = 1234
		468Ch: SUB  1Ch
		468Eh: JR   NC, 46C0h	; �W�����v

		46C0h: INC  A			; A = 1
		46C1h: RLCA				; A = 2
		46C2h: LD   (F669h),A	; CONTYP = 2 : 2byte����
