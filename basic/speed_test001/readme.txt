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
		100 DEFINTA-Z:COLOR15,4,7:SCREEN1:I=0
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

	���ɁAOpenMSX �Ŏ��s���̃������� 8000h�` ��`���Ă݂�ƁA
	�قڂ��̂܂܂̌`�œ����Ă���̂��m�F�ł���B

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

	�e�s�ɑΉ�����擪�A�h���X�́A���L�̂悤�ɂȂ�B
	�s100 8001h
	�s110 8019h
	�s120 803Eh
	�s130 804Fh
	�s140 8061h
	�s150 806Bh
	�s160 8090h
	�s170 80A1h
	�s180 80B3h

	�ϐ� I �̕ێ��̈�́A80BFh�`80C3h�B02 49 00 00 00
	[02h] 2byte�ϐ��������l
	[49h][00h] �ϐ��� 'I' ' '
	[0000h] ���̕ϐ����ێ�����l

	�����o�� IF���́A�s130 �� �s170 �ɑ��݂���B
	BASIC���ԃR�[�h�� "IF" �ɑΉ�����R�[�h�́A8Bh �ł���B

	�s130 �̓��e
		[���s�̃A�h���X 8061h][�s�ԍ�130 = 0082h][IF(8Bh)][' '(20h)]['I'(49h)]['='(EFh)][1234(1Ch, 04D2h)][' '(20h)][THEN(DAh)] ...
		                                                            ��                  ��
		                                                            8055h               8057h
	�s170 �̓��e
		[���s�̃A�h���X 80B3h][�s�ԍ�170 = 00AAh][IF(8Bh)][' '(20h)][1234(1Ch, 04D2h)]['='(EFh)]['I'(49h)][' '(20h)][THEN(DAh)] ...
		                                                            ��                          ��
		                                                            80A7h                       80ABh

	IF���̒��̏������̐擪�A�h���X�́A�s130�� 8051h�A�s170�� 80A3h ���Ƃ킩��B
	OpenMSX �̃f�o�b�K�ŁA�����̃A�h���X�����[�h���ꂽ�Ƃ��Ƀu���C�N����d�|�����Z�b�g���ē��������Ă݂�B

4. �s130�� I ��ǂނƂ��̋���
	8055h �� Memory read �Ƀu���C�N�|�C���g���Z�b�g����ƁA466Bh �Œ�~����B

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
		            �� HL = 80C4h
		6262h: LD   B, 0
		6264h: ADD  HL, BC
		6265h: ADD  HL, BC			; HL = 80C6h
		6266h: LD   A, 0E5h			; �ꌩ���Ӗ������A�ʂ̏ꏊ���� 6267h �֔��ł���P�[�X������BE5 = PUSH HL�B
		6268h: LD   A, 088h
		626Ah: SUB  L
		626Bh: LD   L, A			; HL = 80C2h
		626Ch: LD   A, 0FFh
		626Eh: SBC  A, H			; Cy = 0
		626Fh: LD   H, A			; HL = 7EC2h
		6270h: JR   C, 6275h
		6272h: ADD  HL, SP			; Cy = 1
		6273h: POP  HL
		6274h: RET  C				; �߂�

		4C6Dh: CALL 0FF66h			; H.FRME �� RET�Ȃ̂ŉ��������ɖ߂��Ă���
		4C70h: CALL 04DC7h

		4DC7h: RST  10h				; CHRGTR �� A = 'I'(49h), HL = 8054h
		4DC8h: JP   Z, 406Ah		; �X���[
		4DCBh: JP   C, 3299h		; �X���[
		4DCEh: CALL 64A8h			; isalpha( A ) : �A���t�@�x�b�g�Ȃ� Cy = 0

		64A8h: CP   'A'				; HL = 8055h, A = 'I'
		64AAh: RET  C
		64ABh: CP   'Z'+1
		64ADh: CCF
		64AEh: RET					; Cy = 0

		4DD1h: JP   NC, 4E9Bh		; �A���t�@�x�b�g�Ȃ̂� Cy = 0, �W�����v

		4E9Bh: CALL 5EA4h

		5EA4h: XOR  A
		5EA5h: LD   (0F662h), A		; DIMFLG
		5EA8h: LD   C, (HL)			; HL = 8055h, C = 'I' (49h)
		5EA9h: CALL 0FFA2h			; H.PTRG : ������ ret �Ȃ̂ŉ������Ȃ��Ŗ߂��Ă���
		5EACh: CALL 064A7h			; isalpha( peek(HL) ) : �A���t�@�x�b�g�Ȃ� Cy = 0

		64A7h: LD   A, (HL)			; HL = 8055h: A = 'I' (49h)
		64A8h: CP   'A'				; HL = 8055h, A = 'I'
		64AAh: RET  C
		64ABh: CP   'Z'+1
		64ADh: CCF
		64AEh: RET					; Cy = 0

		5EAFh: JP   C, 4055h		; Cy = 0 �Ȃ̂ŁA�X���[
		5EB2h: XOR  A
		5EB3h: LD   B, A
		5EB4h: RST  10h				; CHRGTR

		0010h: JP   2686h
		2686h: JP   4666h
		4666h: CALL 0FF48h			; H.CHRG : ������ ret �Ȃ̂ŉ������Ȃ��Ŗ߂��Ă���
		4669h: INC  HL				; HL = 8056h
		466Ah: LD   A, (HL)			; �ϐ����� 2�����ڕ]���H A = 0EFh ('='�̒��ԃR�[�h)
		466Bh: CP   3Ah				; �������ȁH
		466Dh: RET  NC				; �������ᖳ������߂�

		5EB5h: JR   C, 5EBCh		; Cy = 0 �Ȃ̂ŃX���[
		5EB7h: CALL 64A8h			; isalpha( A )

		64A8h: CP   'A'				; A = 0EFh ('='�̒��ԃR�[�h)
		64AAh: RET  C
		64ABh: CP   'Z'+1
		64ADh: CCF
		64AEh: RET					; Cy = 1

		5EBAh: JR   C, 5EC5h		; Cy = 1 �Ȃ̂ŃW�����v

		5EC5h: CP   '&'				; CP 26h �� Cy = 0
		5EC7h: JR   NC, 5EE0h		; Cy = 0 �Ȃ̂ŃW�����v

		5EE0h: LD   A, C			; A = 'I'
		5EE1h: AND  7Fh
		5EE3h: LD   E, A
		5EE4h: LD   D, 0
		5EE6h: PUSH HL
		5EE7h: LD   HL, 0F689h		; TEMPST(F67AH, 3 * NUMTMP) 00 00 00 ... ���l�܂��Ă�
		5EEAh: ADD  HL, DE			; HL = F6D2h : 02 02 02 ... ���l�܂��Ă�
		5EEBh: LD   D, (HL)			; D = 2
		5EECh: POP  HL				; HL = 8056h (BASIC�R�[�h�̃A�h���X) '='(0EFh) �̈ʒu
		5EEDh: DEC  HL				; HL = 8055h 'I'
		5EEEh: LD   A,D             ; A = 2
		5EEFh: LD   (0F663h), A		; VALTYP
		5EF2h: RST  10h				; CHRGTR

		0010h: JP   2686h
		2686h: JP   4666h
		4666h: CALL 0FF48h			; H.CHRG : ������ ret �Ȃ̂ŉ������Ȃ��Ŗ߂��Ă���
		4669h: INC  HL				; HL = 8056h
		466Ah: LD   A, (HL)			; �ϐ����� 2�����ڕ]���H A = 0EFh ('='�̒��ԃR�[�h)
		466Bh: CP   3Ah				; �������ȁH
		466Dh: RET  NC				; �������ᖳ������߂�

		5EF3h: LD   A, (0F6A5h)		; A = (SUBFLG) : 0
		5EF6h: DEC  A				; A = 255
		5EF7h: JP   Z, 5FE8h		; �X���[
		5EFAh: JP   P, 5F08h		; �X���[
		5EFDh: LD   A, (HL)			; A = '=' (0EFh)
		5EFEh: SUB  28h				; A = 0C7h
		5F00h: JP   Z, 5FBAh		; �X���[
		5F03h: SUB  33h				; A = 094h
		5F05h: JP   Z, 5FBAh		; �X���[
		5F08h: XOR  A				; A = 0
		5F09h: LD   (0F6A5), A		; (SUBFLG) = A : 0
		5F0Ch: PUSH HL				; HL = 8056h
		5F0Dh: LD   A, (0F7B7h)		; A = (NOFUNS)
		5F10h: OR   A
		5F11h: LD   (0F7B4), A		; (PRMFLG) = A
		5F14h: JR   Z, 5F52h		; �W�����v

		5F52h: LD   HL, (0F6C4h)	; HL = (ARYTAB) : 80C4h : �z��e�[�u���̊J�n�Ԓn
		5F55h: LD   (0F7B5h), HL	; (ARYTA2) = HL : 80C4h : �T�[�`�̏I�_
		5F58h: LD   HL, (0F6C2h)	; HL = (VARTAB) : 80BFh : �P���ϐ��̊J�n�Ԓn
		5F5Bh: JR   5F3Ah

		; �P���ϐ��̑��݊m�F�H
		5F3Ah: EX   DE, HL
		5F3Bh: LD   A, (0F7B5h)		; A = (ARYTA2����)
		5F3Eh: CP   E
		5F3Fh: JP   NZ, 5F23h		; �W�����v

		; �ϐ��T�[�`�H BC �� 2byte �̕ϐ����AVALTYP �ɕϐ��̌^�ԍ�(2��2byte�����ϐ�)
		5F23h: LD   A, (DE)			; DE = 80BFh: A = 2
		5F24h: LD   L, A
		5F25h: INC  DE
		5F26h: LD   A, (DE)			; DE = 80C0h: A = 'I' (49h) �ϐ���1������
		5F27h: INC  DE
		5F28h: CP   C				; C = 'I' (49h) : ��v
		5F29h: JR   NZ, 5F36h		; �X���[
		5F2Bh: LD   A, (0F663h)		; VALTYP
		5F2Eh: CP   L				; �ϐ��̌^
		5F2Fh: JR   NZ, 5F36h		; �X���[
		5F31h: LD   A, (DE)			; DE = 80C1h: A = 00h �ϐ���2������
		5F32h: CP   B				; B = 00h : ��v�B1�����ϐ��Ȃ̂� 2�����ڂ� 00h
		5F33h: JP   Z, 5FA4h		; �W�����v

		5FA4h: INC  DE				; DE = 80C2h: �ϐ��̒l���i�[����Ă�A�h���X
		5FA5h: POP  HL				; HL = 8056h: '=' (0EFh) �̃A�h���X
		5FA6h: RET

		4E9Eh: PUSH HL				; 8056h ('=')
		4E9Fh: EX   DE, HL			; DE = 8056h
		4EA0h: LD   (0F7F8h), HL	; 0F7F8h: DAC 3byte��
		4EA3h: RST  28H				; GETYPR: DAC�Ɋi�[����Ă���l�̌^���t���O�ɔ��f
									; Zf = 0, Cf = 1, Pf = 1, Sf = 1 : Sf = 1 ���琮���^
		4EA4h: CALL NZ, 2F08h		; �X���[: ������^�̏ꍇ�������ʏ������K�v
		4EA7h: POP  HL				; 8056h
		4EA8h: RET

		4C73h: LD   (0F6BCh), HL	; TEMP2 = 8056h : (145�s�ڂ̏ꏊ�֖߂��Ă���)
		4C76h: LD   HL, (0F6BCh)	; HL = 8056h
		4C79h: POP  BC				; 0049h (�ϐ��� I)
		4C7Ah: LD   A, (HL)			; A = '=' (0EFh)
		4C7Bh: LD   (0F69Dh), HL	; TEMP3 = 8056h
		4C7Eh: CP   0EEh
		4C80h: RET  C				; �X���[
		4C81h: CP   0F1h

===================== �������火�AI=0 ��ǉ��O�̃A�h���X�ŁA�A�h���X�l�������Y���Ă� ===
5. �s130�� 1234 ��ǂނƂ��̋���
	8057h �� Memory read �Ƀu���C�N�|�C���g���Z�b�g����ƁA466Bh �Œ�~����B

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
	80A7h �� Memory read �Ƀu���C�N�|�C���g���Z�b�g����ƁA466Bh �Œ�~����B

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

7. �s170�� I ��ǂނƂ��̋���
