#ifndef _IN_ATARI_H_
#define _IN_ATARI_H_

#include "quakedef.h"

typedef struct
{
	int			mx;
	int			my;
	qboolean	leftButtonDepressed;
	qboolean	rightButtonDepressed;
} SMouse;

extern SMouse 	g_mouseInfo;
extern qboolean	reset_mouse_deltas;

#endif
