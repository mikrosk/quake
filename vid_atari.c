/*
Copyright (C) 1996-1997 Id Software, Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  

See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/
// vid_atari.c -- atari video driver

#include <mint/osbind.h>
#include <mint/ostruct.h>

#include "quakedef.h"
#include "d_local.h"

#include "vid_atari_asm.h"

//#define NO_ATARI_VIDEO

viddef_t	vid;				// global video state

#define	BASEWIDTH	320
#define	BASEHEIGHT	200

byte	vid_buffer[BASEWIDTH*BASEHEIGHT];
short	zbuffer[BASEWIDTH*BASEHEIGHT];
//byte	surfcache[256*1024];
byte	surfcache[4*1024*1024];

static char* screen = NULL;
static qboolean isVideoInited = false;

unsigned short	d_8to16table[256];
unsigned	d_8to24table[256];

void	VID_SetPalette (unsigned char *palette)
{
	#ifndef NO_ATARI_VIDEO
	video_atari_set_palette( palette );
	#endif
}

void	VID_ShiftPalette (unsigned char *palette)
{
	VID_SetPalette( palette );
}

void	VID_Init (unsigned char *palette)
{
	vid.maxwarpwidth = vid.width = vid.conwidth = BASEWIDTH;
	vid.maxwarpheight = vid.height = vid.conheight = BASEHEIGHT;
	vid.aspect = 1.0;
	vid.numpages = 1;
	vid.colormap = host_colormap;
	vid.fullbright = 256 - LittleLong (*((int *)vid.colormap + 2048));
	vid.buffer = vid.conbuffer = vid_buffer;
	vid.rowbytes = vid.conrowbytes = BASEWIDTH;
	
	d_pzbuffer = zbuffer;
	D_InitCaches (surfcache, sizeof(surfcache));
	
	screen = (char*)Mxalloc( vid.width * vid.height + 3, MX_STRAM );
	if( screen == NULL )
	{
		Sys_Error( "Not enough memory to allocate screen!\n" );
		return;
	}
	
	screen = (char*)( ( (long)screen + 3 ) & 0xfffffffc );
	
	#ifndef NO_ATARI_VIDEO
	video_atari_init( screen );
	video_atari_set_320x200();
	isVideoInited = true;
	#endif
}

void	VID_Shutdown (void)
{
	if( isVideoInited == true )
	{
		#ifndef NO_ATARI_VIDEO
		video_atari_shutdown();
		#endif
	}
}

void	VID_Update (vrect_t *rects)
{
	#ifndef NO_ATARI_VIDEO
	video_atari_c2p( vid.buffer, screen, vid.width * vid.height );
	#endif
}

/*
================
D_BeginDirectRect
================
*/
void D_BeginDirectRect (int x, int y, byte *pbitmap, int width, int height)
{
}


/*
================
D_EndDirectRect
================
*/
void D_EndDirectRect (int x, int y, int width, int height)
{
}
