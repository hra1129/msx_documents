; ==============================================================================
;	MSX-DOS2 Function
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
; ==============================================================================

; ------------------------------------------------------------------------------
;	FIB (File Information Block)
FIB_SIGNATURE		:= 0		; 1byte, Always 0xFF.
FIB_FILENAME		:= 1		; 13bytes, File name (ASCIIZ)
FIB_ATTRIBUTE		:= 14		; 1byte, See below for details.
FIB_UPDATE_TIME		:= 15		; 2bytes, Last update time.
FIB_UPDATE_DATE		:= 17		; 2bytes, Last update date.
FIB_CLUSTER			:= 19		; 2bytes, First cluster
FIB_SIZE			:= 21		; 4bytes, File size
FIB_DRIVE			:= 25		; 1byte, Logical drive
FIB_INTERNAL		:= 26		; 38bytes, Internal information (Must not be changed).

; ------------------------------------------------------------------------------
;	FIB_ATTRIBUTE
FIB_ATTR_READ_ONLY	:= 0b0000_0001
FIB_ATTR_HIDDEN		:= 0b0000_0010
FIB_ATTR_SYSTEM		:= 0b0000_0100
FIB_ATTR_VOLUME		:= 0b0000_1000
FIB_ATTR_DIRECTORY	:= 0b0001_0000
FIB_ATTR_ARCHIVE	:= 0b0010_0000
FIB_ATTR_RESERVED	:= 0b0100_0000
FIB_ATTR_DEVICE		:= 0b1000_0000

; ------------------------------------------------------------------------------
;	Error code
D2E_NCOMP			:= 0xFF		; Incompatible disk
D2E_WRERR			:= 0xFE		; Write error
D2E_DISK			:= 0xFD		; Disk error
D2E_NRDY			:= 0xFC		; Not ready
D2E_VERFY			:= 0xFB		; Verify error
D2E_DATA			:= 0xFA		; Data error
D2E_RNF				:= 0xF9		; Sector not found
D2E_WPROT			:= 0xF8		; Write protected disk
D2E_UFORM			:= 0xF7		; Unformatted disk
D2E_NDOS			:= 0xF6		; Not a DOS disk
D2E_WDISK			:= 0xF5		; Wrong disk
D2E_WFILE			:= 0xF4		; Wrong disk for file
D2E_SEEK			:= 0xF3		; Seek error
D2E_IFAT			:= 0xF2		; Bad file allocation table
D2E_NOUPB			:= 0xF1		; -
D2E_IFORM			:= 0xF0		; Cannot format this drive
D2E_SUCCESS			:= 0x00		; -

; ------------------------------------------------------------------------------
;	find first
;	input)
;		C  = D2F_FFIRST
;		DE = Directory path name address (ASCIIZ) or FIB address
;		B  = Search target attribute
;			bit0: read only
;			bit1: hidden
;			bit2: system file
;			bit3: volume label
;			bit4: directory
;			bit5: archive
;			bit6: RESERVED
;			bit7: device
;		IX = Result area address (64bytes)
;	output)
;		A  = Error code
;		[IX] = FIB of the file
D2F_FFIRST		:= 0x40

; ------------------------------------------------------------------------------
;	find next
;	input)
;		C  = D2F_FNEXT
;		IX = Result area address of D2F_FFIRST
;	output)
;		A  = Error code
;		[IX] = FIB of the file
D2F_FNEXT		:= 0x41

; ------------------------------------------------------------------------------
;	find new entry
;	input)
;		C  = D2F_FNEW
;		DE = Directory path name address (ASCIIZ) or FIB address
;		B  = Search target attribute
;			bit0: read only
;			bit1: hidden
;			bit2: system file
;			bit3: volume label
;			bit4: directory
;			bit5: archive
;			bit6: RESERVED
;			bit7: new creation flag
;		IX = FIB with template
;	output)
;		A  = Error code
;		[IX] = FIB of the file
D2F_FNEW		:= 0x42

; ------------------------------------------------------------------------------
;	open
;	input)
;		C  = D2F_OPEN
;		DE = File path name address (ASCIIZ) or FIB address
;		A  = Open mode
;			bit0: Disable write access
;			bit1: Disable read access
;			bit2: Succession
;			others: always 0
;	output)
;		A  = Error code
;		B  = New file handle
D2F_OPEN		:= 0x43

D2F_CREATE		:= 0x44
D2F_CLOSE		:= 0x45
D2F_ENSURE		:= 0x46
D2F_DUP			:= 0x47
D2F_READ		:= 0x48
D2F_WRITE		:= 0x49
D2F_SEEK		:= 0x4A
D2F_IOCTL		:= 0x4B
D2F_HTEST		:= 0x4C
D2F_DELETE		:= 0x4D
D2F_RENAME		:= 0x4E
D2F_MOVE		:= 0x4F
D2F_ATTR		:= 0x50
D2F_FTIME		:= 0x51
D2F_HDELETE		:= 0x52
D2F_HRENAME		:= 0x53
D2F_HMOVE		:= 0x54
D2F_HATTR		:= 0x55
D2F_HFTIME		:= 0x56
D2F_HGETDTA		:= 0x57
D2F_GETVFY		:= 0x58
D2F_GETCD		:= 0x59
D2F_CHDIR		:= 0x5A
D2F_PARSE		:= 0x5B
D2F_PFILE		:= 0x5C
D2F_CHKCHR		:= 0x5D
D2F_WPATH		:= 0x5E
D2F_FLUSH		:= 0x5F
D2F_FORK		:= 0x60
D2F_JOIN		:= 0x61
D2F_TERM		:= 0x62
D2F_DEFAB		:= 0x63
D2F_DEFER		:= 0x64
D2F_ERROR		:= 0x65
D2F_EXPLAIN		:= 0x66
D2F_FORMAT		:= 0x67
D2F_RAMD		:= 0x68
D2F_BUFFER		:= 0x69
D2F_ASSIGN		:= 0x6A
D2F_GENV		:= 0x6B
D2F_SENV		:= 0x6C
D2F_FENV		:= 0x6D
D2F_DSKCHK		:= 0x6E
D2F_DOSVER		:= 0x6F
D2F_REDIR		:= 0x70
