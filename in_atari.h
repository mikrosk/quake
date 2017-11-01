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

extern SMouse mouseInfo;

#endif
