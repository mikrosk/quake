**
** Quake for AMIGA
** r_alias.c assembler implementations by Frank Wille <frank@phoenix.owl.de>
**

		INCLUDE	"quakedef68k.i"

		XREF    _aliastransform
		XREF    _r_avertexnormals
		XREF    _r_plightvec
		XREF    _r_ambientlight
		XREF    _r_shadelight
		XREF    _ziscale
		XREF    _aliasxscale
		XREF    _aliasyscale
		XREF    _aliasxcenter
		XREF    _aliasycenter

		XDEF    _R_AliasTransformVector
		XDEF    _R_AliasTransformFinalVert
		XDEF    _R_AliasProjectFinalVert



		fpu

******************************************************************************
*
*       void _R_AliasTransformVector (vec3_t in, vec3_t out)
*
******************************************************************************

		cnop    0,4
_R_AliasTransformVector

*****   stackframe

		rsreset
.fpuregs        rs.x    4
		rs.l    1
.in             rs.l    1
.out            rs.l    1

		fmovem.x        fp2-fp5,-(sp)
		move.l  .in(sp),a0
		move.l  .out(sp),a1
		fmove.s (a0)+,fp0
		fmove.s (a0)+,fp1
		fmove.s (a0)+,fp2
		lea     _aliastransform,a0
		fmove.s (a0)+,fp3
		fmul    fp0,fp3
		fmove.s (a0)+,fp4
		fmul    fp1,fp4
		fadd    fp4,fp3
		fmove.s (a0)+,fp4
		fmul    fp2,fp4
		fadd    fp4,fp3
		fadd.s  (a0)+,fp3
		fmove.s fp3,(a1)+
		fmove.s (a0)+,fp3
		fmul    fp0,fp3
		fmove.s (a0)+,fp4
		fmul    fp1,fp4
		fadd    fp4,fp3
		fmove.s (a0)+,fp4
		fmul    fp2,fp4
		fadd    fp4,fp3
		fadd.s  (a0)+,fp3
		fmove.s fp3,(a1)+
		fmul.s  (a0)+,fp0
		fmul.s  (a0)+,fp1
		fadd    fp1,fp0
		fmul.s  (a0)+,fp2
		fadd    fp2,fp0
		fadd.s  (a0)+,fp0
		fmove.s fp0,(a1)+
		fmovem.x        (sp)+,fp2-fp5
		rts






******************************************************************************
*
*       void _R_AliasTransformFinalVert (finalvert_t *fv, auxvert_t *av,
*                                      trivertx_t *pverts, stvert_t *pstverts)
*
******************************************************************************

		cnop    0,4
_R_AliasTransformFinalVert

*****   stackframe

		rsreset
.fpuregs        rs.x    3
.intregs        rs.l    1
		rs.l    1
.fv             rs.l    1
.av             rs.l    1
.tv             rs.l    1
.sv             rs.l    1


		move.l  a2,-(sp)
		fmovem.x        fp2-fp4,-(sp)
		move.l  .av(sp),a1
		move.l  .tv(sp),a2

*        av->fv[0] = DotProduct(pverts->v, aliastransform[0]) +
*                        aliastransform[0][3];
*        av->fv[1] = DotProduct(pverts->v, aliastransform[1]) +
*                        aliastransform[1][3];
*        av->fv[2] = DotProduct(pverts->v, aliastransform[2]) +
*                        aliastransform[2][3];

		lea     _aliastransform,a0
		moveq   #0,d0
		move.b  (a2),d0
		fmove.l d0,fp0
		move.b  1(a2),d0
		fmove.l d0,fp1
		move.b  2(a2),d0
		fmove.l d0,fp2
		fmove.s (a0)+,fp3
		fmul    fp0,fp3
		fmove.s (a0)+,fp4
		fmul    fp1,fp4
		fadd    fp4,fp3
		fmove.s (a0)+,fp4
		fmul    fp2,fp4
		fadd    fp4,fp3
		fadd.s  (a0)+,fp3
		fmove.s fp3,(a1)+
		fmove.s (a0)+,fp3
		fmul    fp0,fp3
		fmove.s (a0)+,fp4
		fmul    fp1,fp4
		fadd    fp4,fp3
		fmove.s (a0)+,fp4
		fmul    fp2,fp4
		fadd    fp4,fp3
		fadd.s  (a0)+,fp3
		fmove.s fp3,(a1)+
		fmove.s (a0)+,fp3
		fmul    fp0,fp3
		fmove.s (a0)+,fp4
		fmul    fp1,fp4
		fadd    fp4,fp3
		fmove.s (a0)+,fp4
		fmul    fp2,fp4
		fadd    fp4,fp3
		fadd.s  (a0)+,fp3
		fmove.s fp3,(a1)+

*        fv->v[2] = pstverts->s;
*        fv->v[3] = pstverts->t;
*
*        fv->flags = pstverts->onseam;

		move.l  .fv(sp),a0
		move.l  .sv(sp),a1
		move.l  SV_S(a1),8(a0)
		move.l  SV_T(a1),12(a0)
		move.l  SV_ONSEAM(a1),FV_FLAGS(a0)

*        plightnormal = r_avertexnormals[pverts->lightnormalindex];
*        lightcos = DotProduct (plightnormal, r_plightvec);
*        temp = r_ambientlight;

		lea     _r_avertexnormals,a1
		moveq   #0,d0
		move.b  TV_LIGHTNORMALINDEX(a2),d0
		muls    #12,d0
		add.l   d0,a1
		lea     _r_plightvec,a2
		fmove.s (a2)+,fp0
		fmove.s (a2)+,fp1
		fmove.s (a2)+,fp2
		fmul.s  (a1)+,fp0
		fmul.s  (a1)+,fp1
		fadd    fp1,fp0
		fmul.s  (a1)+,fp2
		fadd    fp2,fp0
		move.l  _r_ambientlight,d0

*        if (lightcos < 0)
*        {
*                temp += (int)(r_shadelight * lightcos);
*
*        // clamp; because we limited the minimum ambient and shading light, we
*        // don't have to clamp low light, just bright
*                if (temp < 0)
*                        temp = 0;
*        }
*
*        fv->v[4] = temp;

		ftst    fp0
		fboge.w .cont
		fmul.s  _r_shadelight,fp0
		fmove.l fp0,d1
		add.l   d1,d0
		bge.b   .cont
		moveq   #0,d0
.cont
		move.l  d0,16(a0)
		fmovem.x        (sp)+,fp2-fp4
		move.l  (sp)+,a2
		rts







******************************************************************************
*
*       void _R_AliasProjectFinalVert (finalvert_t *fv, auxvert_t *av,)
*
******************************************************************************

		cnop    0,4
_R_AliasProjectFinalVert

*****   stackframe

		rsreset
		rs.l    1
.fv             rs.l    1
.av             rs.l    1


		move.l  .av(sp),a0
		move.l  .fv(sp),a1
		fmove.s 8(a0),fp0
		fmove.s #1,fp1
		fdiv    fp0,fp1
		fmove.s _ziscale,fp0
		fmul    fp1,fp0
		fmove.l fp0,20(a1)
		fmove.s _aliasxscale,fp0
		fmul    fp1,fp0
		fmul.s  (a0),fp0
		fadd.s  _aliasxcenter,fp0
		fmove.l fp0,(a1)
		fmul.s  _aliasyscale,fp1
		fmul.s  4(a0),fp1
		fadd.s  _aliasycenter,fp1
		fmove.l fp1,4(a1)
		rts
