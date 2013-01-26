/*
 * sys_atari.c -- system stuff for Atari Falcon 060
 *
 * Copyright (c) 2006 Miro Kropacek; miro.kropacek@gmail.com
 *
 * This file is part of the Atari Quake project, 3D shooter game by ID Software,
 * for Atari Falcon 060 computers.
 *
 * Atari Quake is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Atari Quake is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Atari Quake; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <mint/osbind.h>
#include <mint/ostruct.h>
#include <sys/time.h>
#include <mint/cookie.h>

#include "quakedef.h"
#include "errno.h"

#include "keys_atari_asm.h"
#include "in_atari.h"

qboolean isDedicated = false;

#define SCANCODE_BUFFER_SIZE 256
unsigned char g_scancodeBuffer[SCANCODE_BUFFER_SIZE];
int g_scancodeBufferHead = 0;
int g_scancodeBufferTail = 0;
int g_scancodeShiftDepressed = 0;

static unsigned char unshiftToAscii[128];
static unsigned char shiftToAscii[128];
static unsigned char capsToAscii[128];
static qboolean isMintPresent = false;

/*
 * TODO:
 * =====
 * - cd audio
 * - joystick support?
 * - more graphics resolutions?
 */


/*
===============================================================================

FILE IO

===============================================================================
*/

#define MAX_HANDLES             10
FILE    *sys_handles[MAX_HANDLES];

int             findhandle (void)
{
	int             i;

	for (i=1 ; i<MAX_HANDLES ; i++)
		if (!sys_handles[i])
			return i;
	Sys_Error ("out of handles");
	return -1;
}

long CheckMintPresence( void )
{
	typedef struct
	{
		long cookie;
		long value;
	} COOKIE;
	COOKIE* pCookie;

	pCookie = *( (COOKIE **)0x5A0L );

	if( pCookie != NULL)
	{
		do
		{
			if( pCookie->cookie == C_MiNT )
			{
				isMintPresent = true;
				break;
			}

		} while( (pCookie++)->cookie != 0L );
	}

	return 0;
}

void Sys_Init( void )
{
	_KEYTAB*	pSKeyboards;
	//char*		pOldssp;

	// clear scancode buffer
	memset( g_scancodeBuffer, 0, SCANCODE_BUFFER_SIZE );

	// setup new ikbd handler
	atari_ikbd_init();

	// get translation tables
	pSKeyboards = Keytbl( KT_NOCHANGE, KT_NOCHANGE, KT_NOCHANGE );

	// make a copies
	memcpy( unshiftToAscii, pSKeyboards->unshift, 128 );
	memcpy( shiftToAscii, pSKeyboards->shift, 128 );
	memcpy( capsToAscii, pSKeyboards->caps, 128 );

	// patch for atari scancodes
	unshiftToAscii[0x0f] = K_TAB;
	unshiftToAscii[0x1c] = K_ENTER;
	unshiftToAscii[0x01] = K_ESCAPE;
	unshiftToAscii[0x39] = K_SPACE;

	unshiftToAscii[0x0e] = K_BACKSPACE;
	unshiftToAscii[0x48] = K_UPARROW;
	unshiftToAscii[0x50] = K_DOWNARROW;
	unshiftToAscii[0x4b] = K_LEFTARROW;
	unshiftToAscii[0x4d] = K_RIGHTARROW;

	unshiftToAscii[0x38] = K_ALT;
	unshiftToAscii[0x1d] = K_CTRL;
	unshiftToAscii[0x2a] = K_SHIFT;	// left shift
	unshiftToAscii[0x36] = K_SHIFT;	// right shift
	unshiftToAscii[0x3b] = K_F1;
	unshiftToAscii[0x3c] = K_F2;
	unshiftToAscii[0x3d] = K_F3;
	unshiftToAscii[0x3e] = K_F4;
	unshiftToAscii[0x3f] = K_F5;
	unshiftToAscii[0x40] = K_F6;
	unshiftToAscii[0x41] = K_F7;
	unshiftToAscii[0x42] = K_F8;
	unshiftToAscii[0x43] = K_F9;
	unshiftToAscii[0x44] = K_F10;
	unshiftToAscii[0x62] = K_F11;	// help
	unshiftToAscii[0x61] = K_F12;	// undo
	unshiftToAscii[0x52] = K_INS;
	unshiftToAscii[0x53] = K_DEL;
	unshiftToAscii[0x46] = K_PGDN;	// eiffel only
	unshiftToAscii[0x45] = K_PGUP;	// eiffel only
	unshiftToAscii[0x47] = K_HOME;
	unshiftToAscii[0x55] = K_END;	// eiffel only

	unshiftToAscii[0x4f] = K_PAUSE;	// eiffel only
	unshiftToAscii[0x59] = K_MWHEELUP;	// eiffel only
	unshiftToAscii[0x5a] = K_MWHEELDOWN;	// eiffel only
	unshiftToAscii[0x5b] = '`';	// eiffel only

	shiftToAscii[0x0f] = K_TAB;
	shiftToAscii[0x1c] = K_ENTER;
	shiftToAscii[0x01] = K_ESCAPE;
	shiftToAscii[0x39] = K_SPACE;

	shiftToAscii[0x0e] = K_BACKSPACE;
	shiftToAscii[0x48] = K_UPARROW;
	shiftToAscii[0x50] = K_DOWNARROW;
	shiftToAscii[0x4b] = K_LEFTARROW;
	shiftToAscii[0x4d] = K_RIGHTARROW;

	shiftToAscii[0x38] = K_ALT;
	shiftToAscii[0x1d] = K_CTRL;
	shiftToAscii[0x2a] = K_SHIFT;	// left shift
	shiftToAscii[0x36] = K_SHIFT;	// right shift
	shiftToAscii[0x3b] = K_F1;
	shiftToAscii[0x3c] = K_F2;
	shiftToAscii[0x3d] = K_F3;
	shiftToAscii[0x3e] = K_F4;
	shiftToAscii[0x3f] = K_F5;
	shiftToAscii[0x40] = K_F6;
	shiftToAscii[0x41] = K_F7;
	shiftToAscii[0x42] = K_F8;
	shiftToAscii[0x43] = K_F9;
	shiftToAscii[0x44] = K_F10;
	shiftToAscii[0x62] = K_F11;	// help
	shiftToAscii[0x61] = K_F12;	// undo
	shiftToAscii[0x52] = K_INS;
	shiftToAscii[0x53] = K_DEL;
	shiftToAscii[0x46] = K_PGDN;	// eiffel only
	shiftToAscii[0x45] = K_PGUP;	// eiffel only
	shiftToAscii[0x47] = K_HOME;
	shiftToAscii[0x55] = K_END;	// eiffel only

	shiftToAscii[0x4f] = K_PAUSE;	// eiffel only
	shiftToAscii[0x59] = K_MWHEELUP;	// eiffel only
	shiftToAscii[0x5a] = K_MWHEELDOWN;	// eiffel only
	shiftToAscii[0x5b] = '~';	// eiffel only

	// check FreeMiNT presence
	Supexec( CheckMintPresence );
}

/*
================
filelength
================
*/
int filelength (FILE *f)
{
	int             pos;
	int             end;

	pos = ftell (f);
	fseek (f, 0, SEEK_END);
	end = ftell (f);
	fseek (f, pos, SEEK_SET);

	return end;
}

int Sys_FileOpenRead (char *path, int *hndl)
{
	FILE    *f;
	int             i;

	i = findhandle ();

	f = fopen(path, "rb");
	if (!f)
	{
		*hndl = -1;
		return -1;
	}
	sys_handles[i] = f;
	*hndl = i;

	return filelength(f);
}

int Sys_FileOpenWrite (char *path)
{
	FILE    *f;
	int             i;

	i = findhandle ();

	f = fopen(path, "wb");
	if (!f)
		Sys_Error ("Error opening %s: %s", path,strerror(errno));
	sys_handles[i] = f;

	return i;
}

void Sys_FileClose (int handle)
{
	fclose (sys_handles[handle]);
	sys_handles[handle] = NULL;
}

void Sys_FileSeek (int handle, int position)
{
	fseek (sys_handles[handle], position, SEEK_SET);
}

int Sys_FileRead (int handle, void *dest, int count)
{
	return fread (dest, 1, count, sys_handles[handle]);
}

int Sys_FileWrite (int handle, void *data, int count)
{
	return fwrite (data, 1, count, sys_handles[handle]);
}

int     Sys_FileTime (char *path)
{
	FILE    *f;

	f = fopen(path, "rb");
	if (f)
	{
		fclose(f);
		return 1;
	}

	return -1;
}

void Sys_mkdir (char *path)
{
}


/*
===============================================================================

SYSTEM IO

===============================================================================
*/

void Sys_MakeCodeWriteable (unsigned long startaddr, unsigned long length)
{
}


void Sys_Error (char *error, ...)
{
	va_list         argptr;

	printf ("Sys_Error: ");
	va_start (argptr,error);
	vprintf (error,argptr);
	va_end (argptr);
	printf ("\n");

	exit (1);
}

void Sys_Printf (char *fmt, ...)
{
	va_list         argptr;

	va_start (argptr,fmt);
	vprintf (fmt,argptr);
	va_end (argptr);
}

void Sys_Quit (void)
{
	Host_Shutdown();

	atari_ikbd_shutdown();

	exit( 0 );
}

long GetSystemTimerValue( void )
{
	return *( (long*)0x4ba );	// system timer value (200 Hz precision)
}

double Sys_FloatTime (void)
{
	struct timeval	tp;
	struct timezone	tzp;
	static int		secbase;
	unsigned long	ticks;


	if( isMintPresent )
	{
		gettimeofday( &tp, &tzp );
		
		if( !secbase )
		{
			secbase = tp.tv_sec;	// get seconds
			return tp.tv_usec/1000000.0;	// get seconds (from microseconds)
		}

		return ( tp.tv_sec - secbase ) + tp.tv_usec/1000000.0;
	}
	else
	{
		ticks = (unsigned long)Supexec( GetSystemTimerValue );

		if( !secbase )
		{
			secbase = ticks / 200;	// get seconds
			return ticks / 200.0;	// get seconds
		}

		return ( ( ticks / 200.0 ) - secbase ) + ticks / 200.0;
	}
}

char *Sys_ConsoleInput (void)
{
	return NULL;
}

void Sys_Sleep (void)
{
}

void Sys_SendKeyEvents (void)
{
	unsigned char scancode;
	unsigned char ascii;

	while( g_scancodeBufferHead != g_scancodeBufferTail )
	{
		scancode = g_scancodeBuffer[g_scancodeBufferTail++];
		g_scancodeBufferTail &= SCANCODE_BUFFER_SIZE-1;

		// it's fucking important to pass this ascii value as
		// unsigned char !!!
		if( g_scancodeShiftDepressed == 0 )
		{
			ascii = unshiftToAscii[scancode & 0x7f];
		}
		else
		{
			g_scancodeShiftDepressed = 0;
			ascii = shiftToAscii[scancode & 0x7f];
		}

		if( ( scancode & 0x80 ) == 0 )
		{
			Key_Event( ascii, true );
		}
		else
		{
			Key_Event( ascii, false );
		}
	}
}

void Sys_HighFPPrecision (void)
{
}

void Sys_LowFPPrecision (void)
{
}

//=============================================================================

int main (int argc, char **argv)
{
	static quakeparms_t    parms;
	double	time, oldtime, newtime;
	int		j;

	Sys_Init();

	parms.memsize = 32*1024*1024;
	parms.basedir = ".";

	COM_InitArgv (argc, argv);

	parms.argc = com_argc;
	parms.argv = com_argv;

	j = COM_CheckParm("-mem");
	if (j)
		parms.memsize = (int) (Q_atof(com_argv[j+1]) * 1024 * 1024);
	parms.membase = malloc (parms.memsize);
	if (!parms.membase)
	{
		fprintf(stderr, "Error: not enough memory\n");
		Sys_Quit();
	}

	printf ("Host_Init\n");
	Host_Init (&parms);

	isDedicated = (COM_CheckParm ("-dedicated") != 0);

	oldtime = Sys_FloatTime ();
	while (1)
	{
		newtime = Sys_FloatTime ();
		time = newtime - oldtime;

		if (cls.state == ca_dedicated && (time<sys_ticrate.value))
			continue;

		Host_Frame (time);

		oldtime = newtime;
	}

	return 0;
}
