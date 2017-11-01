/*
 * in_atari.c -- input handling from mouse and keyboard for Atari Falcon 060
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

#include "quakedef.h"
#include "in_atari.h"

SMouse g_mouseInfo;

cvar_t	m_filter = {"m_filter","1"};

static float mouse_x;
static float mouse_y;
static float old_mouse_x;
static float old_mouse_y;
static qboolean alwaysLook = false;
static qboolean useMouse = true;

void Force_CenterView_f (void)
{
	cl.viewangles[PITCH] = 0;
}

void IN_MouseCommands( void )
{
	if( useMouse )
	{
		Key_Event( K_MOUSE1, g_mouseInfo.leftButtonDepressed );
		Key_Event( K_MOUSE2, g_mouseInfo.rightButtonDepressed );
	}
}

void IN_MouseMove( usercmd_t *cmd )
{
	if( !useMouse )
	{
		return;
	}
	
	mouse_x = g_mouseInfo.mx;
	mouse_y = g_mouseInfo.my;
	
	reset_mouse_deltas = true;
	g_mouseInfo.mx = 0;
	g_mouseInfo.my = 0;
	
	if (m_filter.value)
	{
		mouse_x = (mouse_x + old_mouse_x) * 0.5;
		mouse_y = (mouse_y + old_mouse_y) * 0.5;
	}
	
	old_mouse_x = mouse_x;
	old_mouse_y = mouse_y;
	
	mouse_x *= sensitivity.value;
	mouse_y *= sensitivity.value;

	if( alwaysLook )
	{
		cl.viewangles[YAW] -= m_yaw.value * mouse_x;
		V_StopPitchDrift ();
		cl.viewangles[PITCH] += m_pitch.value * mouse_y;
		if (cl.viewangles[PITCH] > 80)
			cl.viewangles[PITCH] = 80;
		if (cl.viewangles[PITCH] < -70)
			cl.viewangles[PITCH] = -70;
	}
	else
	{
		// add mouse X/Y movement to cmd
		if ( (in_strafe.state & 1) || (lookstrafe.value && (in_mlook.state & 1) ))
			cmd->sidemove += m_side.value * mouse_x;
		else
			cl.viewangles[YAW] -= m_yaw.value * mouse_x;
		
		if (in_mlook.state & 1)
			V_StopPitchDrift ();
			
		if ( (in_mlook.state & 1) && !(in_strafe.state & 1))
		{
			cl.viewangles[PITCH] += m_pitch.value * mouse_y;
			if (cl.viewangles[PITCH] > 80)
				cl.viewangles[PITCH] = 80;
			if (cl.viewangles[PITCH] < -70)
				cl.viewangles[PITCH] = -70;
		}
		else
		{
			if ((in_strafe.state & 1) && noclip_anglehack)
				cmd->upmove -= m_forward.value * mouse_y;
			else
				cmd->forwardmove -= m_forward.value * mouse_y;
		}
	}
}

void IN_Mouse (void)
{
	if( COM_CheckParm( "-nomouse" ) != 0 )
	{
		useMouse = false;
		return;
	}
	
	if( COM_CheckParm( "-mouselook" ) != 0 )
	{
		alwaysLook = true;
	}
	
	// center mouse
	mouse_x = old_mouse_x = vid.width / 2;
	mouse_y = old_mouse_y = vid.height / 2;
}

void IN_Init (void)
{
	Cvar_RegisterVariable (&m_filter);
	Cmd_AddCommand ("force_centerview", Force_CenterView_f);
	
	IN_Mouse();
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

