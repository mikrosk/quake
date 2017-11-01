**
** Quake for AMIGA
** r_misc.c assembler implementations by Frank Wille <frank@phoenix.owl.de>
**

		XREF    _vright
		XREF    _vup
		XREF    _vpn

		XDEF    _TransformVector

******************************************************************************
*
*       void _TransformVector (vec3_t in, vec3_t out)
*
******************************************************************************

		cnop    0,4
_TransformVector

		rsreset
.fpuregs        rs.x    3
.regs           rs.l    1
		rs.l    1
.in             rs.l    1
.out            rs.l    1

		move.l  a2,-(sp)
		fmovem.x        fp2-fp4,-(sp)
		move.l  .out(sp),a2
		move.l  .in(sp),a0
		fmove.s (a0)+,fp0
		fmove.s (a0)+,fp1
		fmove.s (a0)+,fp2
		lea     _vright,a1
		fmove.s (a1)+,fp3
		fmul    fp0,fp3
		fmove.s (a1)+,fp4
		fmul    fp1,fp4
		fadd    fp3,fp4
		fmove.s (a1)+,fp3
		fmul    fp2,fp3
		fadd    fp3,fp4
		fmove.s fp4,(a2)+
		lea     _vup,a1
		fmove.s (a1)+,fp3
		fmul    fp0,fp3
		fmove.s (a1)+,fp4
		fmul    fp1,fp4
		fadd    fp3,fp4
		fmove.s (a1)+,fp3
		fmul    fp2,fp3
		fadd    fp3,fp4
		fmove.s fp4,(a2)+
		lea     _vpn,a1
		fmul.s  (a1)+,fp0
		fmul.s  (a1)+,fp1
		fadd    fp1,fp0
		fmul.s  (a1)+,fp2
		fadd    fp2,fp0
		fmove.s fp0,(a2)+
		fmovem.x        (sp)+,fp2-fp4
		move.l  (sp)+,a2
		rts
