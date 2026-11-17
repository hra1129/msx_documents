// --------------------------------------------------------------------
//	Sprite Driver for SpriteMode2 ä˙ë“ílê∂ê¨
// ====================================================================
//	2023/June/9th	t.hara
// --------------------------------------------------------------------

#include <stdio.h>
#include <string.h>

typedef struct {
	unsigned char	y;
	unsigned char	x;
	unsigned char	pattern;
	unsigned char	dummy;
} SPRITE_ATTRIBUTE_T;

typedef struct {
	unsigned char	y;
	unsigned char	x;
	unsigned char	pattern0;
	unsigned char	color0;
	unsigned char	num;
	unsigned char	pattern1;
	unsigned char	color1;
	unsigned char	reserved;
} VIRTUAL_SPRITE_ATTRIBUTE_T;

typedef struct {
	unsigned char	color[16];
} SPRITE_COLOR_T;

typedef struct {
	unsigned char	x;
	unsigned char	y;
	unsigned char	vx;
	unsigned char	vy;
} SPRITE_POS_T;

static const SPRITE_COLOR_T sprite_color_table[] = {
	{ 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, },	// #0
	{ 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, },	// #1
	{ 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, 0x08, },	// #2
	{ 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, },	// #3
	{ 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, },	// #4
	{ 0x04, 0x05, 0x07, 0x07, 0x05, 0x05, 0x05, 0x05, 0x04, 0x05, 0x04, 0x04, 0x04, 0x04, 0x04, 0x04, },	// #5
	{ 0x0C, 0x02, 0x03, 0x03, 0x02, 0x02, 0x02, 0x02, 0x0C, 0x02, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, },	// #6
};

static VIRTUAL_SPRITE_ATTRIBUTE_T sprite_attribute[32];
static SPRITE_ATTRIBUTE_T vram_sprite_attribute[32];
static SPRITE_COLOR_T vram_sprite_color[32];
static unsigned short int random_seed[2];
static SPRITE_POS_T sprite_pos[32];
static unsigned char sprite_color_work[32];
static int sprite_plane_work[32];
static unsigned int sprite_index;
static const int disable_y = 216;

// --------------------------------------------------------------------
unsigned char rl( unsigned char a, unsigned short int *p_cy ) {
	int cy;

	cy = *p_cy;
	*p_cy = ((a & 0x80) == 0x80);
	return (a << 1) | cy;
}

// --------------------------------------------------------------------
unsigned int random( void ) {
	unsigned short int hl, de, bc, a, h, cy;

	// get seed
	hl = random_seed[0];
	de = random_seed[1];
	// mixed
	bc = 0xB213;
	hl = hl + bc;

	a = (hl >> 8) & 255;
	a = a ^ 3;
	a = a ^ (de & 255);
	hl = (hl & 0x00FF) | (a << 8);

	a = hl & 255;
	a = a ^ 4;
	a = a ^ ((de >> 8) & 255);
	cy = 0;
	a = rl( (unsigned char)a, &cy );
	h = hl >> 8;
	h = rl( (unsigned char)h, &cy );
	a = a + cy;
	hl = (h << 8) | (a & 255);
	// update seed
	random_seed[0] = de;
	random_seed[1] = hl;
	return a;
}

// --------------------------------------------------------------------
static void ball_initialize1( int sprite_pos_index, int sprite_attribute_index, int index ) {
	unsigned char a, b;

	// X position
	a = random();
	if( a > (256 - 16) ) {
		a -= 256 - 16;
	}
	sprite_pos[ sprite_pos_index ].x = a;
	// Y position
	a = random();
	if( a > (212 - 16) ) {
		a -= 212 - 16;
	}
	sprite_pos[ sprite_pos_index ].y = a;
	// VX
	b = random();
	a = ((b & 1) << 1) - 1;
	if( (b & (1 << 4)) != 0 ) {
		a += a;
	}
	sprite_pos[ sprite_pos_index ].vx = a;
	// VY
	b = random();
	a = ((b & 1) << 1) - 1;
	if( (b & (1 << 4)) != 0 ) {
		a += a;
	}
	sprite_pos[ sprite_pos_index ].vy = a;
	// sprite attribute -----------------------------------
	// 1st sprite plane
	sprite_attribute[ sprite_attribute_index ].pattern0 = 0;
	sprite_attribute[ sprite_attribute_index ].color0 = index & 3;
	sprite_attribute[ sprite_attribute_index ].num = 2;
	// 2nd sprite plane
	sprite_attribute[ sprite_attribute_index ].pattern1 = 4;
	sprite_attribute[ sprite_attribute_index ].color1 = 4;
}

// --------------------------------------------------------------------
static void ball_initialize2( int sprite_pos_index, int sprite_attribute_index, int index ) {
	unsigned char a, b;

	// X position
	a = random();
	if( a > (256 - 16) ) {
		a -= 256 - 16;
	}
	sprite_pos[ sprite_pos_index ].x = a;
	// Y position
	a = random();
	if( a > (212 - 16) ) {
		a -= 212 - 16;
	}
	sprite_pos[ sprite_pos_index ].y = a;
	// VX
	b = random();
	a = ((b & 1) << 1) - 1;
	if( (b & (1 << 4)) != 0 ) {
		a += a;
	}
	sprite_pos[ sprite_pos_index ].vx = a;
	// VY
	b = random();
	a = ((b & 1) << 1) - 1;
	if( (b & (1 << 4)) != 0 ) {
		a += a;
	}
	sprite_pos[ sprite_pos_index ].vy = a;
	// sprite attribute -----------------------------------
	// 1st sprite plane
	sprite_attribute[ sprite_attribute_index ].pattern0 = 8;
	sprite_attribute[ sprite_attribute_index ].color0 = (index & 1) + 5;
	sprite_attribute[ sprite_attribute_index ].num = 1;
}

// --------------------------------------------------------------------
static void ball_move( void ) {
	int i, b, c, d, e, sprite_pos_index, sprite_attribute_index;

	sprite_pos_index = 0;
	sprite_attribute_index = 0;
	for( i = 0; i < 20; i++ ) {
		// get ball position of current target
		e = sprite_pos[ sprite_pos_index ].x;
		d = sprite_pos[ sprite_pos_index ].y;
		c = sprite_pos[ sprite_pos_index ].vx;
		b = sprite_pos[ sprite_pos_index ].vy;
		// move X position
		e = (e + c) & 255;
		sprite_pos[ sprite_pos_index ].x = e;
		if( sprite_pos[ sprite_pos_index ].x >= (256 - 16) ) {
			c = -c;
			sprite_pos[ sprite_pos_index ].vx = c;
			e = (e + c) & 255;
		}
		// move Y position
		d = (d + b) & 255;
		sprite_pos[ sprite_pos_index ].y = d;
		if( sprite_pos[ sprite_pos_index ].y >= (212 - 16) ) {
			b = -b;
			sprite_pos[ sprite_pos_index ].vy = b;
			d = (d + b) & 255;
		}
		// update sprite position
		sprite_attribute[ sprite_attribute_index ].y = d;
		sprite_attribute[ sprite_attribute_index ].x = e;

		sprite_pos_index++;
		sprite_attribute_index++;
	}
}

// --------------------------------------------------------------------
static void spdrv_update( void ) {
	int i, j, sprite_attribute_index, sprite_color_work_index, remain_sprites;
	int vram_sprite_attribute_index, sprite_color_table_index;

	vram_sprite_attribute_index = 0;

	// reference sprite_attribute on CPU RAM
	sprite_attribute_index = sprite_index;
	sprite_color_work_index = 0;
	remain_sprites = 32;
	memset( sprite_plane_work, 0xFF, 32 );
	for( i = 0; i < 32 && remain_sprites; i++, sprite_attribute_index = ((sprite_attribute_index + 7) & 31) ) {
		// Is current sprite_attribute visible?
		if( sprite_attribute[ sprite_attribute_index ].y == disable_y ) {
			continue;
		}
		// Can it be displayed with the remaining sprites?
		if( sprite_attribute[ sprite_attribute_index ].num > remain_sprites ) {
			continue;
		}
		// Transfer current sprite_attribute to VRAM
		// -- Set position of 1st sprite plane.
		vram_sprite_attribute[ vram_sprite_attribute_index ].y       = sprite_attribute[ sprite_attribute_index ].y;
		vram_sprite_attribute[ vram_sprite_attribute_index ].x       = sprite_attribute[ sprite_attribute_index ].x;
		vram_sprite_attribute[ vram_sprite_attribute_index ].pattern = sprite_attribute[ sprite_attribute_index ].pattern0;
		vram_sprite_attribute[ vram_sprite_attribute_index ].dummy   = sprite_attribute[ sprite_attribute_index ].color0;
		vram_sprite_attribute_index++;
		sprite_color_work[ sprite_color_work_index ] = sprite_attribute[ sprite_attribute_index ].color0;
		sprite_plane_work[ sprite_color_work_index ] = sprite_attribute_index;								// Åödebug
		sprite_color_work_index++;
		remain_sprites--;
		if( sprite_attribute[ sprite_attribute_index ].num == 1 ) {
			continue;
		}
		// -- Set position of 2nd sprite plane.
		vram_sprite_attribute[ vram_sprite_attribute_index ].y       = sprite_attribute[ sprite_attribute_index ].y;
		vram_sprite_attribute[ vram_sprite_attribute_index ].x       = sprite_attribute[ sprite_attribute_index ].x;
		vram_sprite_attribute[ vram_sprite_attribute_index ].pattern = sprite_attribute[ sprite_attribute_index ].pattern1;
		vram_sprite_attribute[ vram_sprite_attribute_index ].dummy   = sprite_attribute[ sprite_attribute_index ].color1;
		vram_sprite_attribute_index++;
		sprite_color_work[ sprite_color_work_index ] = sprite_attribute[ sprite_attribute_index ].color1;
		sprite_plane_work[ sprite_color_work_index ] = sprite_attribute_index;								// Åödebug
		sprite_color_work_index++;
	}
	// transfer_sprite_color
	for( i = 0; i < 32; i++ ) {
		sprite_color_table_index = sprite_color_work[i];
		for( j = 0; j < 16; j++ ) {
			vram_sprite_color[i].color[j] = sprite_color_table[ sprite_color_table_index ].color[j];
		}
	}
	// Calculate next index.
	sprite_index = (sprite_index + 19) & 31;
}

// --------------------------------------------------------------------
static void puts_sprite_attribute( void ) {
	int i;

	printf( "  Sprite Attribute\n" );
	for( i = 0; i < 32; i++ ) {
		printf( "    0x%02X, 0x%02X, 0x%02X, 0x%02X [%2d]\n",
			vram_sprite_attribute[i].y,
			vram_sprite_attribute[i].x,
			vram_sprite_attribute[i].pattern,
			vram_sprite_attribute[i].dummy, i );
	}
}

// --------------------------------------------------------------------
static void puts_sprite_color_work( void ){
	int i, j;

	printf( "  Sprite Color Work\n" );
	for( j = 0; j < 4; j++ ) {
		printf( "    " );
		for( i = 0; i < 8; i++ ) {
			printf( "0x%02X, ", sprite_color_work[ i + j * 8 ] );
		}
		printf( "\n" );
	}

	printf( "  Sprite Plane Work\n" );
	for( j = 0; j < 4; j++ ) {
		printf( "    " );
		for( i = 0; i < 8; i++ ) {
			printf( "0x%02X, ", sprite_plane_work[ i + j * 8 ] );
		}
		printf( "\n" );
	}
	printf( "\n" );
}

// --------------------------------------------------------------------
static void puts_sprite_color( void ) {
	int i, j;

	printf( "  Sprite Color\n" );
	for( i = 0; i < 32; i++ ) {
		printf( "    " );
		for( j = 0; j < 16; j++ ) {
			printf( "0x%02X, ", vram_sprite_color[i].color[j] );
		}
		printf( "[%2d]\n", i );
	}
}

// --------------------------------------------------------------------
int main( int argc, char *argv[] ) {
	int b, sprite_pos_index, sprite_attribute_index;

	random_seed[0] = 123 + (123 << 8);
	random_seed[1] = 123 + (123 << 8);
	sprite_pos_index = 0;
	sprite_attribute_index = 0;
	for( b = 0; b < 32; b++ ) {
		sprite_attribute[b].y = disable_y;
	}
	for( b = 12; b > 0; b-- ) {
		ball_initialize1( sprite_pos_index, sprite_attribute_index, b );
		sprite_pos_index++;
		sprite_attribute_index++;
	}
	for( b = 8; b > 0; b-- ) {
		ball_initialize2( sprite_pos_index, sprite_attribute_index, b );
		sprite_pos_index++;
		sprite_attribute_index++;
	}
	ball_move();
	sprite_pos[ 0 ].x = 0;
	sprite_pos[ 0 ].y = 0;
	sprite_attribute[ 0 ].y = 0;
	sprite_attribute[ 0 ].x = 0;

	for( b = 0; b < 100; b++ ) {
		spdrv_update();
		printf( "#%02d ----------------------------------\n", b );
		puts_sprite_attribute();
		puts_sprite_color_work();
		puts_sprite_color();
	}
	return 0;
}
