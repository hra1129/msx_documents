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

  Sprite Mode2 では、スプライトが9個以上並ぶと、その水平ラインには、優先度の高い
4個までが表示され、それ以外は非表示になるという制約があります。
  このドライバーは、その優先度を毎フレームシャッフルすることで、非表示になるスプ
ライトを点滅表示させ、全く見えなくなるよりは良い状態を作り出します。
  一方で、ゲームプログラムの方では、そのシャッフルを意識したくありません。
  このドライバーでは、CPU RAM上に仮想スプライトアトリビュートテーブルを作成し、V
RAM上のスプライトアトリビュートテーブルには、仮想スプライトアトリビュートテーブル
をシャッフルして転送する仕掛けを用意しています。
  また、非ブランキング期間で書き替えても、テアリングなどの問題が発生しないようにV
RAM上のスプライトアトリビュートテーブルを2つ用意して、ダブルバンキングによる安定
表示も実現しています。

2. License --------------------------------------------------------------------
  This software is provided under the MIT License.

  このソフトウェア（スプライトドライバー）は、MITライセンスで提供しています。

3. API ------------------------------------------------------------------------
  This driver has three APIs.
  spdrv_initialize ...... Driver initialization
  spdrv_flip ............ Double bank flip
  spdrv_update .......... Write on the non-display side of the double bank based 
                          on the contents of the virtual sprite attribute table.

  このドライバーは、3つの API を持ちます。
  spdrv_initialize ...... ドライバーの初期化
  spdrv_flip ............ ダブルバンクのフリップ
  spdrv_update .......... ダブルバンクの非表示側に仮想スプライトアトリビュート
                          テーブルの内容に基づいて書き込む

4. Executable procedure -------------------------------------------------------
  (1) call spdrv_initialize
  (2) Update the contents of the sprite attribute table on the CPU RAM at the 
      convenience of the application.
  (3) call spdrv_update
  (4) Wait for vertical sync.
  (5) call spdrv_flip
  (6) Repeat (2) through (5) above.

  (1) call spdrv_initialize
  (2) アプリケーション都合で CPU RAM上の仮想スプライトアトリビュートテーブルの
      内容を更新して下さい。
  (3) call spdrv_update
  (4) V-Sync を待って下さい。
  (5) call spdrv_flip
  (6) 上記 (2)～(5) を繰り返して下さい。

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

  sprite_attribute の内部構造は、VRAM上のスプライトアトリビュートテーブルと同じ
です。しかし、Y=216 の時の意味が若干異なります。
  VRAM上で Y=216 にすると、そのスプライト以降、優先度が低いスプライトは全て非表
示になりますが、このドライバーでは、その Y=216 になっているスプライト単独の非表
示です。
  画面外へ表示しているわけではなく、非表示になり、その空いた分を他のスプライト
に割り当てるので、表示の効率が上がります。

6. Files ----------------------------------------------------------------------
  sprite_driver.asm ............. Sprite driver program code.
  sprite_driver_work.asm ........ Sprite driver work area definitions.
  msx_constant.asm .............. Constant definitions for MSX.
  sample_program.asm ............ Sample program code.
  random.asm .................... Random function for sample program.

===============================================================================
2023/June/10th  t.hara (HRA!)
