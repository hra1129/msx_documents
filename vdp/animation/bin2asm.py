#!/usr/bin/env python3
# -*- coding: utf-8 -*-

with open( "WAVEBACK.SR5", "rb" ) as f:
	a_image = f.read()

with open( "WAVEBACK.ASM", "w" ) as f:
	i = 0
	for data in a_image[7:]:
		if i == 0:
			s_line = "\tdb\t$%02X" % data
		else:
			s_line = s_line + ", $%02X" % data
		i = i + 1
		if i == 8:
			f.write( s_line + "\n" )
			i = 0
			s_line = ""
	f.write( s_line + "\n" )
