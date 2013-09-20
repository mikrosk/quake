**
** Quake for AMIGA
** common.c assembler implementations by Frank Wille <frank@phoenix.owl.de>
**

		XDEF    _Q_memcpy
		XDEF    _ShortSwap
		XDEF    _LongSwap
		XDEF    _FloatSwap
		XDEF    _FloatSwap__r


******************************************************************************
*
*       void _Q_memcpy (void *dest, void *src, int count)
*
*       fast memcopy operation
*
******************************************************************************

		cnop    0,4
_Q_memcpy

		rsreset
		rs.l    1
.dest           rs.l    1
.source         rs.l    1
.count          rs.l    1

		move.l  .dest(sp),a1
		move.l  .source(sp),a0
		move.l  a0,d1
		move.l  a1,d0
		or.b    d0,d1
		move.l  .count(sp),d0
		beq.b   .exit
		or.b    d0,d1
		and.b   #$3,d1
		bne.b   .loop2
.loop
		move.l  (a0)+,(a1)+
		subq.l  #4,d0
		bne.b   .loop
.exit
		rts
.loop2
		move.b  (a0)+,(a1)+
		subq.l  #1,d0
		bne.b   .loop2
		rts

******************************************************************************
*
*       short _ShortSwap (short l)
*
*       swap word (LE->BE)
*
******************************************************************************

		cnop    0,4
_ShortSwap

		rsreset
		rs.l    1
		rs.w	1
.data           rs.w    1

		move    .data(sp),d0
		ror     #8,d0
		rts

******************************************************************************
*
*       int _LongSwap (int l)
*
*       swap longword (LE->BE)
*
******************************************************************************

		cnop    0,4
_LongSwap

		rsreset
		rs.l    1
.data           rs.l    1

		move.l  .data(sp),d0
		ror     #8,d0
		swap    d0
		ror     #8,d0
		rts

******************************************************************************
*
*       float _FloatSwap (float f)
*
*       swap float (LE->BE)
*
******************************************************************************

		cnop    0,4
_FloatSwap
_FloatSwap__r

		rsreset
		rs.l    1
.data           rs.s    1

		move.l  .data(sp),d0
		ror     #8,d0
		swap    d0
		ror     #8,d0
		IFND	ATARI
		fmove.s d0,fp0
		ENDC
		rts
