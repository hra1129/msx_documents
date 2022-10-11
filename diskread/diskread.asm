; =============================================================================
;	MSX-BASIC�����Ńt�@�C����ǂރT���v���v���O����
; -----------------------------------------------------------------------------
;	2022�N10��11��  Programmed by HRA!
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
;	BSAVE�w�b�_
		db		0xFE
		dw		start_address
		dw		end_address
		dw		start_address

		org		0xC000
start_address::

; =============================================================================
;	�t�@�C�����J��
		ld		de, fcb			; �I�[�v������Ă��Ȃ�FCB �̃A�h���X
		ld		c, FOPEN		; FOPEN�t�@���N�V����
		call	BDOS
		or		a, a			; ���������Ƃ��� A=0 ���Ԃ�AFCB���I�[�v�����ꂽFCB�ɕω�����
		jp		nz, open_error	; �I�[�v���Ɏ��s����

; =============================================================================
;	DTA��ݒ肷��
		ld		de, dta			; Data Transfer Area �̃A�h���X (�t�@�C���̓ǂݍ��ݐ�)
		ld		c, SETDTA
		call	BDOS

; =============================================================================
;	�t�@�C���� DTA �֓ǂݍ���
		ld		de, fcb
		ld		hl, 1			; ���R�[�h�T�C�Y (2bytes)
		ld		[fcb + RECSIZE], hl
		ld		hl, 0			; ���R�[�h�ʒu (4bytes)
		ld		[fcb + RECPOS + 0], hl
		ld		[fcb + RECPOS + 2], hl
		ld		hl, 100			; ���R�[�h��
		ld		c, FREAD
		call	BDOS			; ���������Ƃ��� A=0 ���Ԃ�AHL �Ɏ��ۂɓǂݍ��񂾃��R�[�h��������
		ld		a, h			; �������A�t�@�C�����w��̃T�C�Y(����̏ꍇ 100byte) �ɖ����Ȃ��ꍇ���G���[�ɂȂ�
		or		a, l			; HL�Ɏ��ۂɓǂݍ��񂾃��R�[�h���������Ă���̂ŁA����Ŕ��f��������ǂ��B
		jp		z, read_error	; ���[�h�Ɏ��s����
		ld		[read_size], hl	; �ǂݍ��񂾃T�C�Y��ۑ�

; =============================================================================
;	�t�@�C�������
		ld		de, fcb
		ld		c, FCLOSE
		call	BDOS

; =============================================================================
;	�ǂݍ��񂾓��e����ʂɕ\������
		ld		de, dta
		ld		hl, [read_size]
		add		hl, de
		ld		[hl], '$'		; �t�@�C�����e�̍Ō�� '$' ��t���� (PUTS�̏I������)
		ld		c, PUTS
		call	BDOS
		ret

; =============================================================================
;	�G���[�I��
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
;	���[�N�G���A
fcb::	; MSX-Datapack vol.1 p.405 : �I�[�v���O��FCB
		db		0				; �h���C�u�ԍ� (00h:�f�t�H���g�h���C�u, 01h: A, 02h: B ...)
		ds		"TEST    "		; �t�@�C���� 8����
		ds		"TXT"			; �g���q
		db		0				; CP/M�u���b�N�ԍ�
		space	36 - 13 + 1		; �X�y�[�X�m��

dta::
		space	256				; �X�y�[�X�m��

read_size::
		dw		0
end_address::
