#!/usr/bin/env python3
# coding=utf-8
# =============================================================================
#  Parts converter
# -----------------------------------------------------------------------------
#  2022/Dec/25 t.hara
# =============================================================================

import sys
import re

try:
	from PIL import Image
except:
	print( "ERROR: Require PIL module. Please run 'pip3 install Pillow.'" )
	exit()

# --------------------------------------------------------------------
def my_rgb( r, g, b ):
	return (r << 16) | (g << 8) | b;

# --------------------------------------------------------------------
color_palette = [
	my_rgb(   0, 111,  87 ),
	my_rgb(   0,   0,   0 ),
	my_rgb(  12, 222,  54 ),
	my_rgb( 128, 255, 144 ),
	my_rgb(   0,   0, 255 ),
	my_rgb(   0, 165, 255 ),
	my_rgb( 120,   0,   0 ),
	my_rgb(   0, 225, 255 ),
	my_rgb( 204,   0,   0 ),
	my_rgb( 255, 105,   0 ),
	my_rgb( 144, 108,   0 ),
	my_rgb( 201, 174,   0 ),
	my_rgb(   0, 141,   0 ),
	my_rgb( 255, 255, 162 ),
	my_rgb(   0, 255, 255 ),
	my_rgb( 255, 255, 255 ),
];

# --------------------------------------------------------------------
def get_color_index( r, g, b ):
	c = my_rgb( r, g, b )
	try:
		i = color_palette.index( c )
	except:
		return -1
	return i

# --------------------------------------------------------------------
def put_datas( file, datas ):
	index = 0
	pattern_no = 0
	for d in datas:
		if index == 0:
			file.write( "\tdb\t0x%02X" % d )
		elif index == 7:
			file.write( ", 0x%02X\t\t; #%02X\n" % ( d, pattern_no ) )
			pattern_no = pattern_no + 1
		else:
			file.write( ", 0x%02X" % d )
		index = (index + 1) & 7
	if index != 0:
		file.write( "\n" )

# --------------------------------------------------------------------
def convert():

	try:
		img = Image.open( "Image1.png" )
	except:
		print( "ERROR: Cannot read the 'msx_logo.png'." )
		return

	img = img.convert( 'RGB' )

	# SCREEN5‰æ‘œ‚É•ÏŠ· ------------------------------------------
	parts_numbers = [ 0, 1, 2, 3, 16 ];
	image_tables = []
	for parts in parts_numbers:
		image_table = []
		px = (parts & 15) * 16
		py = parts & 0xF0
		print( "parts = %d : px = %d, py = %d" % ( parts, px, py ) )
		for y in range( 0, 16 ):
			for x in range( 0, 16, 2 ):
				( r, g, b ) = img.getpixel( ( px + x + 0, py + y ) )
				p0 = get_color_index( r, g, b )
				( r, g, b ) = img.getpixel( ( px + x + 1, py + y ) )
				p1 = get_color_index( r, g, b )
				p = (p0 << 4) | p1
				image_table.append( p )
		image_tables.append( image_table )

	with open( "image1.asm", 'wt' ) as file:
		file.write( '; ====================================================================\n' )
		file.write( ';  GRAPHIC PARTS DATA for MSX Logo Demo\n' )
		file.write( '; --------------------------------------------------------------------\n' )
		file.write( ';  Copyright (C)2023 t.hara (HRA!)\n' )
		file.write( '; ====================================================================\n' )
		file.write( '\n' )
		file.write( '\tscope graphic_parts\n' )
		i = 0
		for parts in parts_numbers:
			file.write( 'graphic_parts%d::\n' % parts )
			put_datas( file, image_tables[i] )
			i = i + 1
		file.write( '\tendscope\n' )
	print( "Success!!" )

# --------------------------------------------------------------------
def usage():
	print( "Usage> parts_converter.py" )

# --------------------------------------------------------------------
def main():
	convert()

if __name__ == "__main__":
	main()
