#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import math

# 仮想画面に渦巻き描画
r_xcenter = 128
r_ycenter = 106

with open( "WAVEBACK.SR5", "wb" ) as f:

	# BSAVEヘッダ
	a_header = bytearray( [ 0xFE, 0x00, 0x00, 0x00, 0x6A, 0x00, 0x00 ] )
	f.write( a_header )

	for y in range( 0, 212 ):
		a_image = [0] * 256
		for x in range( 0, 256 ):
			# 像高を求める
			r_height = math.sqrt( (x - r_xcenter)**2 + (y - r_ycenter)**2 )
			# 方向を求める
			if( (x - r_xcenter) == 0 and (y - r_ycenter) == 0 ):
				r_direction = 0
			else:
				r_direction = math.degrees( math.atan2( (y - r_ycenter), (x - r_xcenter) ) ) * 256 / 360
			# 色を求める
			r_color = (int(r_direction + r_height / 16 ) % 8) + 8
			a_image[x] = r_color

		a_line = bytearray( [0] * 128 )
		for x in range( 0, 128 ):
			a_line[x] = (a_image[x*2+0] << 4) + a_image[x*2+1]
		f.write( a_line )
