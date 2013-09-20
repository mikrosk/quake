; keys_atari_asm.s -- keyboard and mouse handling for Atari Falcon 060
;
; Copyright (c) 2006 Miro Kropacek; miro.kropacek@gmail.com
;
; This file is part of the Atari Quake project, 3D shooter game by ID Software,
; for Atari Falcon 060 computers.
;
; Atari Quake is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; Atari Quake is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License
; along with Atari Quake; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

	XDEF	_atari_ikbd_init
	XDEF	_atari_ikbd_shutdown

	XREF	_g_scancodeBuffer
	XREF	_g_scancodeBufferHead
	XREF	_g_scancodeShiftDepressed
	XREF	_g_mouseInfo
	XREF	_reset_mouse_deltas

	text

_atari_ikbd_init:
	movem.l	d2-d7/a2-a6,-(sp)

	move.w	#$22,-(sp)			; Kbdvbase()
	trap	#14
	addq.l	#2,sp
	
	movea.l	d0,a0
	lea	(32.w,a0),a0			; get adress to ikbdsys
	move.l	a0,ikbdsys_pointer
	move.l	(a0),old_ikbdsys
	move.l	#new_ikbdsys,(a0)

	movem.l	(sp)+,d2-d7/a2-a6
	rts


_atari_ikbd_shutdown:
	movem.l	d2-d7/a2-a6,-(sp)

	move.w	#$22,-(sp)			; Kbdvbase()
	trap	#14
	addq.l	#2,sp

	movea.l	d0,a0
	move.l	old_ikbdsys,(32.w,a0)

	movem.l	(sp)+,d2-d7/a2-a6
	rts


new_ikbdsys:
	movem.l	d0-d1/a0,-(sp)

	move.b	$fffffc02.w,d1
	cmp.b	#$f6,d1
	blo.b	not_ikbd_packet

	cmp.b	#$f8,d1
	blo.b	not_mouse

	cmp.b	#$fb,d1
	bhi.b	not_mouse

mouse:	lea	_g_mouseInfo,a0
	clr.l	(8.w,a0)			; g_mouseInfo.leftButtonDepressed = false;
	clr.l	(12.w,a0)			; g_mouseInfo.rightButtonDepressed = false;

	move.b	d1,d0
	and.b	#$01,d0
	beq.b	no_right_button
	addq.l	#1,(12.w,a0)			; g_mouseInfo.rightButtonDepressed = true;
no_right_button:
	and.b	#$02,d1
	beq.b	no_left_button
	addq.l	#1,(8.w,a0)			; g_mouseInfo.leftButtonDepressed = true;
no_left_button:

	movea.l	ikbdsys_pointer,a0
	move.l	#mouse_ikbd_sys_1,(a0)		; set pointer to proceed relative x
	movem.l	(sp)+,d0-d1/a0
	jmp	([old_ikbdsys])

not_mouse:
not_ikbd_packet:
	cmp.b	#$2a,d1
	bne.b	shift_not_pressed
	move.l	#1,_g_scancodeShiftDepressed
	bra.b	shift_skip

shift_not_pressed:
	cmp.b	#$36,d1
	bne.b	shift_skip
	move.l	#1,_g_scancodeShiftDepressed

shift_skip:
	lea	_g_scancodeBuffer,a0
	move.l	_g_scancodeBufferHead,d0

	move.b	d1,(0.b,a0,d0.l)		; g_scancodeBuffer[g_scancodeBufferHead] = scancode

	addq.l	#1,d0
	and.l	#256-1,d0			; SCANCODE_BUFFER_SIZE-1
	move.l	d0,_g_scancodeBufferHead

	movem.l	(sp)+,d0-d1/a0
	jmp	([old_ikbdsys])

mouse_ikbd_sys_1:
	movem.l	d0/a0,-(sp)

	lea	_g_mouseInfo,a0			; get pointer to g_mouseInfo structure
	move.b	$fffffc02,d0
	dc.w	$49c0				; extb	d0

	tst.l	_reset_mouse_deltas
	bne.b	reset_mx

	add.l	d0,(0.w,a0)
	bra.b	skip_mx
reset_mx:
	move.l	d0,(0.w,a0)			; save as mx

skip_mx:
	movea.l	ikbdsys_pointer,a0
	move.l	#mouse_ikbd_sys_2,(a0)		; set pointer to proceed relative y

	movem.l	(sp)+,d0/a0
	jmp	([old_ikbdsys])

mouse_ikbd_sys_2:
	movem.l	d0/a0,-(sp)

	lea	_g_mouseInfo,a0			; get pointer to g_mouseInfo structure
	move.b	$fffffc02,d0
	dc.w	$49c0				; extb	d0

	tst.l	_reset_mouse_deltas
	bne.b	reset_my

	add.l	d0,(4.w,a0)
	bra.b	skip_my

reset_my:
	move.l	d0,(4.w,a0)			; save as my
	clr.l	_reset_mouse_deltas

skip_my:
	movea.l	ikbdsys_pointer,a0
	move.l	#new_ikbdsys,(a0)		; set original pointer

	movem.l	(sp)+,d0/a0
	jmp	([old_ikbdsys])


	data

_reset_mouse_deltas:
	dc.l	1				; true

	bss

old_ikbdsys:
	ds.l	1
ikbdsys_pointer:
	ds.l	1
