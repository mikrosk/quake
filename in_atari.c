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
// in_null.c -- for systems without a mouse

#include "quakedef.h"
#include "in_atari.h"

SMouse mouseInfo;

static float old_mouse_x = 0.0;
static float old_mouse_y = 0.0;
static qboolean alwaysLook = false;
static qboolean useMouse = true;

void IN_MouseCommands( void )
{
	if( useMouse )
	{
		Key_Event( K_MOUSE1, mouseInfo.leftButtonDepressed );
		Key_Event( K_MOUSE2, mouseInfo.rightButtonDepressed );
	}
}

void IN_MouseMove( usercmd_t *cmd )
{
	float mx, my;
	
	if( !useMouse )
	{
		return;
	}
	
	mx = mouseInfo.mx;
	my = mouseInfo.my;
	
	mouseInfo.mx = 0;
	mouseInfo.my = 0;

	/*
	if (m_filter.value)
	{
		mx = (mx + old_mouse_x) * 0.5;
		my = (my + old_mouse_y) * 0.5;
	}
	*/

	old_mouse_x = mx;
	old_mouse_y = my;

	mx *= sensitivity.value;
	my *= sensitivity.value;

	if( alwaysLook )
	{
		cl.viewangles[YAW] -= mx;
		V_StopPitchDrift ();
		cl.viewangles[PITCH] += my;
		if (cl.viewangles[PITCH] > 80)
			cl.viewangles[PITCH] = 80;
		if (cl.viewangles[PITCH] < -70)
			cl.viewangles[PITCH] = -70;
	}
	else
	{
		// add mouse X/Y movement to cmd
		if ( (in_strafe.state & 1) || (lookstrafe.value && (in_mlook.state & 1) ))
			cmd->sidemove += mx;
		else
			cl.viewangles[YAW] -= mx;
		
		if (in_mlook.state & 1)
			V_StopPitchDrift ();
			
		if ( (in_mlook.state & 1) && !(in_strafe.state & 1))
		{
			cl.viewangles[PITCH] += my;
			if (cl.viewangles[PITCH] > 80)
				cl.viewangles[PITCH] = 80;
			if (cl.viewangles[PITCH] < -70)
				cl.viewangles[PITCH] = -70;
		}
		else
		{
			if ((in_strafe.state & 1) && noclip_anglehack)
				cmd->upmove -= my;
			else
				cmd->forwardmove -= my;
		}
	}
}

void IN_Init (void)
{
	if( COM_CheckParm( "-mouselook" ) != 0 )
	{
		alwaysLook = true;
	}
	
	if( COM_CheckParm( "-nomouse" ) != 0 )
	{
		useMouse = false;
	}
}

void IN_Shutdown (void)
{
}

void IN_Commands (void)
{
	IN_MouseCommands();
}

void IN_Move (usercmd_t *cmd)
{
	IN_MouseMove( cmd );
}

