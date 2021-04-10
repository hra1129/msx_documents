; ==============================================================================
;	MSX BIOS
;
;  Copyright (C) 2020 Takayuki Hara (HRA!)
;  All rights reserved.
;                           http://hraroom.s602.xrea.com/msx/software/mgsp.html
;
;  本ソフトウェアおよび本ソフトウェアに基づいて作成された派生物は、以下の条件を
;  満たす場合に限り、再頒布および使用が許可されます。
;
;  1.ソースコード形式で再頒布する場合、上記の著作権表示、本条件一覧、および下記
;    免責条項をそのままの形で保持すること。
;  2.バイナリ形式で再頒布する場合、頒布物に付属のドキュメント等の資料に、上記の
;    著作権表示、本条件一覧、および下記免責条項を含めること。
;  3.書面による事前の許可なしに、本ソフトウェアを販売、および商業的な製品や活動
;    に使用しないこと。
;
;  本ソフトウェアは、著作権者によって「現状のまま」提供されています。著作権者は、
;  特定目的への適合性の保証、商品性の保証、またそれに限定されない、いかなる明示
;  的もしくは暗黙な保証責任も負いません。著作権者は、事由のいかんを問わず、損害
;  発生の原因いかんを問わず、かつ責任の根拠が契約であるか厳格責任であるか（過失
;  その他の）不法行為であるかを問わず、仮にそのような損害が発生する可能性を知ら
;  されていたとしても、本ソフトウェアの使用によって発生した（代替品または代用サ
;  ービスの調達、使用の喪失、データの喪失、利益の喪失、業務の中断も含め、またそ
;  れに限定されない）直接損害、間接損害、偶発的な損害、特別損害、懲罰的損害、ま
;  たは結果損害について、一切責任を負わないものとします。
;
;  Note that above Japanese version license is the formal document.
;  The following translation is only for reference.
;
;  Redistribution and use of this software or any derivative works,
;  are permitted provided that the following conditions are met:
;
;  1. Redistributions of source code must retain the above copyright
;     notice, this list of conditions and the following disclaimer.
;  2. Redistributions in binary form must reproduce the above
;     copyright notice, this list of conditions and the following
;     disclaimer in the documentation and/or other materials
;     provided with the distribution.
;  3. Redistributions may not be sold, nor may they be used in a
;     commercial product or activity without specific prior written
;     permission.
;
;  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
;  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
;  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
;  FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
;  COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
;  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
;  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
;  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
;  CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
;  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;  POSSIBILITY OF SUCH DAMAGE.
; ------------------------------------------------------------------------------
;	Date		Author	Ver		Description
;	2020/9/22	t.hara	1.0		1st release
; ==============================================================================

chkram		:=			0x0000
synchr		:=			0x0008
rdslt		:=			0x000C
chrgtr		:=			0x0010
wrslt		:=			0x0014
outdo		:=			0x0018
calslt		:=			0x001c
dcompr		:=			0x0020
enaslt		:=			0x0024
getypr		:=			0x0028
callf		:=			0x0030
keyint		:=			0x0038
initio		:=			0x003b
inifnk		:=			0x003e
disscr		:=			0x0041
enascr		:=			0x0044
wrtvdp		:=			0x0047
rdvrm		:=			0x004a
wrtvrm		:=			0x004d
setrd		:=			0x0050
setwrt		:=			0x0053
filvrm		:=			0x0056
ldirmv		:=			0x0059
ldirvm		:=			0x005c
chgmod		:=			0x005f
chgclr		:=			0x0062
nmi			:=			0x0066
clrspr		:=			0x0069
initxt		:=			0x006c
init32		:=			0x006f
inigrp		:=			0x0072
inimlt		:=			0x0075
settxt		:=			0x0078
sett32		:=			0x007b
setgrp		:=			0x007e
setmlt		:=			0x0081
calpat		:=			0x0084
calatr		:=			0x0087
gspsiz		:=			0x008a
grpprt		:=			0x008d
gicini		:=			0x0090
wrtpsg		:=			0x0093
rdpsg		:=			0x0096
strtms		:=			0x0099
chsns		:=			0x009c
chget		:=			0x009f
chput		:=			0x00a2
lptout		:=			0x00a5
lptstt		:=			0x00a8
cnvchr		:=			0x00ab
pinlin		:=			0x00ae
inlin		:=			0x00b1
qinlin		:=			0x00b4
breakx		:=			0x00b7
beep		:=			0x00c0
cls			:=			0x00c3
posit		:=			0x00c6
fnksb		:=			0x00c9
erafnk		:=			0x00cc
dspfnk		:=			0x00cf
totext		:=			0x00d2
gtstck		:=			0x00d5
gttrig		:=			0x00d8
gtpad		:=			0x00db		; note: MSXturboRではライトペン(A=8～11)は常に0が返る
gtpdl		:=			0x00de		; note: MSXturboRでは常に0が返る
tapion		:=			0x00e1		; note: MSXturboRでは常にCy=1(エラー)が返る
tapin		:=			0x00e4		; note: MSXturboRでは常にCy=1(エラー)が返る
tapiof		:=			0x00e7		; note: MSXturboRでは常にCy=1(エラー)が返る
tapoon		:=			0x00ea		; note: MSXturboRでは常にCy=1(エラー)が返る
tapout		:=			0x00ed		; note: MSXturboRでは常にCy=1(エラー)が返る
tapoof		:=			0x00f0		; note: MSXturboRでは常にCy=1(エラー)が返る
stmotr		:=			0x00f3		; note: MSXturboRでは何もせずに返る
chgcap		:=			0x0132
chgsnd		:=			0x0135
rslreg		:=			0x0138
wslreg		:=			0x013b
rdvdp		:=			0x013e
snsmat		:=			0x0141
isflio		:=			0x014a
outdlp		:=			0x014d
kilbuf		:=			0x0156
calbas		:=			0x0159

; require MSX2
subrom		:=			0x015c
extrom		:=			0x015f
eol			:=			0x0168
bigfil		:=			0x016b
nsetrd		:=			0x016e
nstwrt		:=			0x0171
nrdvrm		:=			0x0174
nwrvrm		:=			0x0177
rdres		:=			0x017A
wrres		:=			0x017D

; require MSXturboR
chgcpu		:=			0x0180
getcpu		:=			0x0183
pcmply		:=			0x0186
pcmrec		:=			0x0189

; SUB-ROM (require MSX2)
sub_gtpprt	:=			0x0089
sub_nvbxln	:=			0x00c9
sub_nvbxfl	:=			0x00cd
sub_chgmod	:=			0x00d1
sub_initxt	:=			0x00d5
sub_init32	:=			0x00d9
sub_inigrp	:=			0x00dd
sub_inimlt	:=			0x00e1
sub_settxt	:=			0x00e5
sub_sett32	:=			0x00e9
sub_setgrp	:=			0x00ed
sub_setmlt	:=			0x00f1
sub_clrspr	:=			0x00f5
sub_calpat	:=			0x00f9
sub_calatr	:=			0x00fd
sub_gspsiz	:=			0x0101
sub_getpat	:=			0x0105
sub_wrtvrm	:=			0x0109
sub_rdvrm	:=			0x010d
sub_chgclr	:=			0x0111
sub_clssub	:=			0x0115
sub_dspfnk	:=			0x011d
sub_wrtvdp	:=			0x012d
sub_vdpsta	:=			0x0131
sub_setpag	:=			0x013d
sub_iniplt	:=			0x0141
sub_rstplt	:=			0x0145
sub_getplt	:=			0x0149
sub_setplt	:=			0x014d
sub_beep	:=			0x017d
sub_prompt	:=			0x0181
sub_newpad	:=			0x01ad		; note: MSXturboRではライトペン(A=8～11)は常に0が返る
sub_chgmdp	:=			0x01b5
sub_knjprt	:=			0x01bd
sub_redclk	:=			0x01f5
sub_wrtclk	:=			0x01f9

h_prompt	:=			0xF24F		; hook: Disk change prompt (Require DISK DRIVE)

diskve		:=			0xF323		; 2bytes (Require DISK DRIVE)
breakv		:=			0xF325		; 2bytes (Require DISK DRIVE)
ramad0		:=			0xF341		; 1byte, Page0 RAM Slot (Require DISK DRIVE)
ramad1		:=			0xF342		; 1byte, Page1 RAM Slot (Require DISK DRIVE)
ramad2		:=			0xF343		; 1byte, Page2 RAM Slot (Require DISK DRIVE)
ramad3		:=			0xF344		; 1byte, Page3 RAM Slot (Require DISK DRIVE)
masters		:=			0xF348		; 1byte, MasterCartridgeSlot (Require DISK DRIVE)

rdprim		:=			0xF380		; 5bytes, 基本スロットからの読み込み
wrprim		:=			0xF385		; 7bytes, 基本スロットへの書き込み
clprim		:=			0xF38C		; 14bytes, 基本スロットコール

cliksw		:=			0xF3DB		; 1byte, キークリックスイッチ (0=OFF, others=ON)
csry		:=			0xF3DC		; 1byte, カーソルのY座標
csrx		:=			0xF3DD		; 1byte, カーソルのX座標
cnsdfg		:=			0xF3DE		; 1byte, ファンクションキー表示スイッチ (0=ON, others=OFF)

rg0sav		:=			0xF3DF		; 1byte, VDP R#0 に書き込んだ値
rg1sav		:=			0xF3E0		; 1byte, VDP R#1 に書き込んだ値
rg2sav		:=			0xF3E1		; 1byte, VDP R#2 に書き込んだ値
rg3sav		:=			0xF3E2		; 1byte, VDP R#3 に書き込んだ値
rg4sav		:=			0xF3E3		; 1byte, VDP R#4 に書き込んだ値
rg5sav		:=			0xF3E4		; 1byte, VDP R#5 に書き込んだ値
rg6sav		:=			0xF3E5		; 1byte, VDP R#6 に書き込んだ値
rg7sav		:=			0xF3E6		; 1byte, VDP R#7 に書き込んだ値
statfl		:=			0xF3E7		; 1byte, VDP S#0 から読み込んだ値

fnkstr		:=			0xF87F		; 16byte * 10, ファンクションキーに対応する文字列

exbrsa		:=			0xFAF8		; 1byte, SUB-ROM のスロット番号

hokvld		:=			0xFB20

oldkey		:=			0xFBDA		; 11bytes, キーマトリクスの状態(旧)
newkey		:=			0xFBE5		; 11bytes, キーマトリクスの状態(新)
keybuf		:=			0xFBF0		; 40bytes, キーバッファ
linwrk		:=			0xFC18		; 40bytes, スクリーンハンドラが使う一時保管場所
patwrk		:=			0xFC40		; 8bytes, パターンコンバータが使う一時保管場所
bottom		:=			0xFC48		; 2bytes, 実装したRAMの先頭番地。MSX2では通常 8000h
himem		:=			0xFC4A		; 2bytes, 利用可能なメモリの上位番地。CLEAR文の<メモリ上限>により設定される
trptbl		:=			0xFC4C		; 78bytes, 割り込み処理で使うトラップテーブル。一つのテーブルは 3bytes で 1バイト目が ON/OFF/STOPの状態。残りが分岐先テキストアドレス

scrmod		:=			0xFCAF		; 1byte, 現在のスクリーンモード番号
oldscr		:=			0xFCB0		; 1byte, スクリーンモード保存エリア

exptbl		:=			0xFCC1		; 4bytes, 各スロットの拡張の有無
slttbl		:=			0xFCC5		; 4bytes, 各スロットの拡張スロットレジスタの現在の選択状況
sltatr		:=			0xFCC9		; 64bytes, 各スロット用の属性
sltwrk		:=			0xFD09		; 128bytes, 各スロット用の特定のワークエリアを確保
procnm		:=			0xFD89		; 16bytes, 拡張ステートメント, 拡張デバイスの名前が入る, ASCIIZ
device		:=			0xFD99		; 1byte, カートリッジ用の装置識別

h_timi		:=			0xFD9F		; 5bytes, 垂直同期割り込み発生時のフック

extbio		:=			0xFFCA

rg8sav		:=			0xFFE7
rg9sav		:=			0xFFE8
