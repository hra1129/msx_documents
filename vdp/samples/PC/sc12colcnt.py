#!/usr/bin/env python3
# coding=utf-8

def clip( i ):
	if i < 0:
		return 0
	if i > 31:
		return 31
	return i

def sround2( i ):
	if i < 0:
		return (i + 1) >> 2
	return (i + 2) >> 2

color_ref = {}
for y in range( 0, 32 ):
	for j in range( -32, 32 ):
		for k in range( -32, 32 ):
			r = clip( y + j )
			g = clip( y + k )
			b = clip( sround2((y << 2) + y - ((j << 1) + k)) )
			color_ref[ ( r, g, b ) ] = True
print( "SCREEN12 COLOR NUM IS %d." % len( color_ref ) )

color_ref = {}
for y in range( 0, 32, 2 ):
	for j in range( -32, 32 ):
		for k in range( -32, 32 ):
			r = clip( y + j )
			g = clip( y + k )
			b = clip( sround2((y << 2) + y - ((j << 1) + k)) )
			color_ref[ ( r, g, b ) ] = True
print( "SCREEN10/11 COLOR NUM IS %d." % len( color_ref ) )
