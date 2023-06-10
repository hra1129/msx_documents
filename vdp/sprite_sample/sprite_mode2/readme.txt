Sprite Driver for Sprite Mode2
===============================================================================

1. Introduction ---------------------------------------------------------------
  In Sprite Mode 2, when 9 or more sprites are lined up in a row, the horizontal 
line is restricted to display only the 4 highest priority sprites and hide the rest.
  This driver shuffles the priority levels every frame, making the non-displayed 
sprites blink, which is better than not being able to see them at all.
  On the other hand, the game program does not want to be aware of that shuffling.
  This driver creates a virtual sprite attribute table in CPU RAM and provides a 
mechanism to shuffle and transfer the virtual sprite attribute table to the sprite 
attribute table in VRAM.
  Two sprite attribute tables on VRAM are prepared to prevent problems such as 
tearing even when rewriting during the non-blanking period, and stable display by 
double banking is also realized.

  Sprite Mode2 �ł́A�X�v���C�g��9�ȏ���ԂƁA���̐������C���ɂ́A�D��x�̍���
4�܂ł��\������A����ȊO�͔�\���ɂȂ�Ƃ������񂪂���܂��B
  ���̃h���C�o�[�́A���̗D��x�𖈃t���[���V���b�t�����邱�ƂŁA��\���ɂȂ�X�v
���C�g��_�ŕ\�������A�S�������Ȃ��Ȃ���͗ǂ���Ԃ����o���܂��B
  ����ŁA�Q�[���v���O�����̕��ł́A���̃V���b�t�����ӎ�����������܂���B
  ���̃h���C�o�[�ł́ACPU RAM��ɉ��z�X�v���C�g�A�g���r���[�g�e�[�u�����쐬���AV
RAM��̃X�v���C�g�A�g���r���[�g�e�[�u���ɂ́A���z�X�v���C�g�A�g���r���[�g�e�[�u��
���V���b�t�����ē]������d�|����p�ӂ��Ă��܂��B
  �܂��A��u�����L���O���Ԃŏ����ւ��Ă��A�e�A�����O�Ȃǂ̖�肪�������Ȃ��悤��V
RAM��̃X�v���C�g�A�g���r���[�g�e�[�u����2�p�ӂ��āA�_�u���o���L���O�ɂ�����
�\�����������Ă��܂��B

2. License --------------------------------------------------------------------
  This software is provided under the MIT License.

  ���̃\�t�g�E�F�A�i�X�v���C�g�h���C�o�[�j�́AMIT���C�Z���X�Œ񋟂��Ă��܂��B

3. API ------------------------------------------------------------------------
  This driver has three APIs.
  spdrv_initialize ...... Driver initialization
  spdrv_flip ............ Double bank flip
  spdrv_update .......... Write on the non-display side of the double bank based 
                          on the contents of the virtual sprite attribute table.

  ���̃h���C�o�[�́A3�� API �������܂��B
  spdrv_initialize ...... �h���C�o�[�̏�����
  spdrv_flip ............ �_�u���o���N�̃t���b�v
  spdrv_update .......... �_�u���o���N�̔�\�����ɉ��z�X�v���C�g�A�g���r���[�g
                          �e�[�u���̓��e�Ɋ�Â��ď�������

4. Executable procedure -------------------------------------------------------
  (1) call spdrv_initialize
  (2) Update the contents of the sprite attribute table on the CPU RAM at the 
      convenience of the application.
  (3) call spdrv_update
  (4) Wait for vertical sync.
  (5) call spdrv_flip
  (6) Repeat (2) through (5) above.

  (1) call spdrv_initialize
  (2) �A�v���P�[�V�����s���� CPU RAM��̉��z�X�v���C�g�A�g���r���[�g�e�[�u����
      ���e���X�V���ĉ������B
  (3) call spdrv_update
  (4) V-Sync ��҂��ĉ������B
  (5) call spdrv_flip
  (6) ��L (2)�`(5) ���J��Ԃ��ĉ������B

5. Work area ------------------------------------------------------------------
  sprite_page ........ 1byte
  sprite_index ....... 1byte
  sprite_attribute ... 256bytes

  The internal structure of sprite_attribute is the same as the sprite attribute 
table on VRAM. However, the meaning of Y=216 is slightly different.
  When Y=216 is set in VRAM, all sprites with lower priority after that sprite 
are hidden, but this driver only hides the sprite with Y=216.
  This driver hides the sprite with Y=216, not the sprite that is displayed 
off-screen, and allocates the free space to other sprites, thus increasing the 
display efficiency.

  sprite_attribute �̓����\���́AVRAM��̃X�v���C�g�A�g���r���[�g�e�[�u���Ɠ���
�ł��B�������AY=216 �̎��̈Ӗ����኱�قȂ�܂��B
  VRAM��� Y=216 �ɂ���ƁA���̃X�v���C�g�ȍ~�A�D��x���Ⴂ�X�v���C�g�͑S�Ĕ�\
���ɂȂ�܂����A���̃h���C�o�[�ł́A���� Y=216 �ɂȂ��Ă���X�v���C�g�P�Ƃ̔�\
���ł��B
  ��ʊO�֕\�����Ă���킯�ł͂Ȃ��A��\���ɂȂ�A���̋󂢂����𑼂̃X�v���C�g
�Ɋ��蓖�Ă�̂ŁA�\���̌������オ��܂��B

6. Files ----------------------------------------------------------------------
  sprite_driver.asm ............. Sprite driver program code.
  sprite_driver_work.asm ........ Sprite driver work area definitions.
  msx_constant.asm .............. Constant definitions for MSX.
  sample_program.asm ............ Sample program code.
  random.asm .................... Random function for sample program.

===============================================================================
2023/June/10th  t.hara (HRA!)
