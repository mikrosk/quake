**
** Quake for AMIGA
** r_light.c assembler implementations by Frank Wille <frank@phoenix.owl.de>
**

		INCLUDE	"quakedef68k.i"

		XREF    _cl
		XREF    _d_lightstylevalue

		XDEF    _RecursiveLightPoint

SURF_DRAWTILED          =       $20
MAXLIGHTMAPS            =       4



		fpu

******************************************************************************
*
*       int _RecursiveLightPoint (mnode_t *node, vec3_t start, vec3_t end)
*
******************************************************************************

		cnop    0,4
_RecursiveLightPoint

*****   stackframe

		rsreset
.intregs        rs.l    1
		rs.l    1
.node           rs.l    1
.start          rs.l    1
.end            rs.l    1


		move.l  a2,-(sp)
		move.l  .node(sp),a0
		move.l  .start(sp),a1
		move.l  .end(sp),a2
		bsr     DoRecursion
		move.l  (sp)+,a2
		rts

DoRecursion
		movem.l d2-d7/a2-a6,-(sp)
		fmovem.x        fp2-fp7,-(sp)
		lea     -12(sp),sp
		move.l  sp,a6

*        if (node->contents < 0)
*                return -1;              // didn't hit anything

		moveq   #-1,d0
		tst.l   NODE_CONTENTS(a0)       ;if (node->contents < 0)
		blt.w   .end                    ;return -1

*        plane = node->plane;
*        front = DotProduct (start, plane->normal) - plane->dist;
*        back = DotProduct (end, plane->normal) - plane->dist;
*        side = front < 0;
*
*        if ( (back < 0) == side)
*                return RecursiveLightPoint (node->children[side], start, end);

		move.l  a1,a5
		move.l  a2,a4
		move.l  NODE_PLANE(a0),a3       ;plane = node->plane
		fmove.s MPLANE_DIST(a3),fp0
		fmove.s (a3)+,fp7
		fmove.s (a3)+,fp2
		fmove.s (a3)+,fp3
		move.l  a0,a3
		fmove.s (a1)+,fp4
		fmul    fp7,fp4
		fmove.s (a1)+,fp5
		fmul    fp2,fp5
		fadd    fp5,fp4
		fmove.s (a1)+,fp6
		fmul    fp3,fp6
		fadd    fp6,fp4
		fsub    fp0,fp4                 ;fp4 = front
		fmul.s  (a2)+,fp7
		fmul.s  (a2)+,fp2
		fadd    fp7,fp2
		fmul.s  (a2)+,fp3
		fadd    fp3,fp2
		fsub    fp0,fp2                 ;fp2 = back
		moveq   #1,d2                   ;side = front < 0
		ftst    fp4
		fbolt.w .cont
		moveq   #0,d2
.cont
		moveq   #1,d3                   ;d3 = back < 0
		ftst    fp2
		fbolt.w .cont2
		moveq   #0,d3
.cont2
		move.l  d2,d7
		cmp.l   d2,d3                   ;if (back < 0) == side
		bne.b   .cont3
		move.l  NODE_CHILDREN(a3,d2.l*4),a0
		move.l  a5,a1
		move.l  a4,a2
		bsr     DoRecursion
		bra.w   .end

*        frac = front / (front-back);
*        mid[0] = start[0] + (end[0] - start[0])*frac;
*        mid[1] = start[1] + (end[1] - start[1])*frac;
*        mid[2] = start[2] + (end[2] - start[2])*frac;

.cont3
		fsub    fp4,fp2
		fdiv    fp2,fp4
		fneg    fp4                     ;frac = front / (front-back)

		fmove.s (a5)+,fp0
		fmove.s (a4)+,fp7
		fsub    fp0,fp7
		fmul    fp4,fp7
		fadd    fp0,fp7
		fmove.s fp7,(a6)+               ;fp7 = mid[0]
		fmove.s (a5)+,fp0
		fmove.s (a4)+,fp2
		fsub    fp0,fp2
		fmul    fp4,fp2
		fadd    fp0,fp2
		fmove.s fp2,(a6)+               ;fp2 = mid[1]
		fmove.s (a5)+,fp0
		fmove.s (a4)+,fp3
		fsub    fp0,fp3
		fmul    fp4,fp3
		fadd    fp0,fp3
		fmove.s fp3,(a6)+               ;fp3 = mid[2]
		lea     -12(a6),a6
		lea     -12(a5),a5
		lea     -12(a4),a4

*        r = RecursiveLightPoint (node->children[side], start, mid);
*        if (r >= 0)
*                return r;               // hit something
*
*        if ( (back < 0) == side )
*                return -1;              // didn't hit anuthing

		move.l  NODE_CHILDREN(a3,d2.l*4),a0
		move.l  a5,a1
		move.l  a6,a2
		bsr     DoRecursion
		tst.l   d0                      ;if (r >= 0)
		bge.w   .end                    ;return r
		moveq   #-1,d0
		cmp.l   d2,d3                   ;if ((back < 0) == side)
		beq.w   .end                    ;return -1

*        surf = cl.worldmodel->surfaces + node->firstsurface;
*        for (i=0 ; i<node->numsurfaces ; i++, surf++)

		move.l  _cl+CL_WORLDMODEL,a0    ;surf = cl.worldmodel + ...
		move.l  MODEL_SURFACES(a0),a0
		moveq   #0,d0
		move    NODE_FIRSTSURFACE(a3),d0
		asl.l   #MSURFACE_SIZEOF_EXP,d0
		add.l   d0,a0

		move    NODE_NUMSURFACES(a3),d6 ;node->numsurfaces
		subq    #1,d6
		bmi.w   .skip
		lea     _d_lightstylevalue,a1

*                if (surf->flags & SURF_DRAWTILED)
*                        continue;       // no lightmaps
*
*                tex = surf->texinfo;

.loop
		move.l  MSURFACE_FLAGS(a0),d0   ;if (surf->flags & SURF...)
		and.l   #SURF_DRAWTILED,d0
		bne.w   .loopend                ;continue
		move.l  MSURFACE_TEXINFO(a0),a5 ;tex = surf->texinfo

*                s = DotProduct (mid, tex->vecs[0]) + tex->vecs[0][3];
*                t = DotProduct (mid, tex->vecs[1]) + tex->vecs[1][3];;

		fmove.s (a5)+,fp4
		fmove.s (a5)+,fp5
		fmove.s (a5)+,fp6
		fmul    fp7,fp4
		fmul    fp2,fp5
		fadd    fp5,fp4
		fmul    fp3,fp6
		fadd    fp6,fp4
		fadd.s  (a5)+,fp4               ;d4 = s
		fmove.l fp4,d4


		fmove.s (a5)+,fp0
		fmove.s (a5)+,fp5
		fmove.s (a5)+,fp6
		fmul    fp7,fp0
		fmul    fp2,fp5
		fadd    fp5,fp0
		fmul    fp3,fp6
		fadd    fp6,fp0
		fadd.s  (a5)+,fp0
		fmove.l fp0,d1                  ;d1 = t

*                if (s < surf->texturemins[0] ||
*                t < surf->texturemins[1])
*                        continue;
*
*                ds = s - surf->texturemins[0];
*                dt = t - surf->texturemins[1];

		move    MSURFACE_TEXTUREMINS(a0),d2
		ext.l   d2
		move    MSURFACE_TEXTUREMINS+2(a0),d3
		ext.l   d3
		sub.l   d2,d4                   ;d4 = ds
		bmi.b   .loopend
		sub.l   d3,d1                   ;d1 = dt
		bmi.b   .loopend

*                if ( ds > surf->extents[0] || dt > surf->extents[1] )
*                        continue;
*
*                if (!surf->samples)
*                        return 0;
*
*                ds >>= 4;
*                dt >>= 4;

		move    MSURFACE_EXTENTS(a0),d2
		ext.l   d2                      ;d2 = surf->extents[0]
		cmp.l   d2,d4
		bgt.b   .loopend
		move    MSURFACE_EXTENTS+2(a0),d3
		ext.l   d3                      ;d3 = surf->extents[1]
		cmp.l   d3,d1
		bgt.b   .loopend
		moveq   #0,d0                   ;if (!surf->samples)
		move.l  MSURFACE_SAMPLES(a0),d5 ;return 0
		beq.w   .end
		asr.l   #4,d4                   ;ds >>= 4
		asr.l   #4,d1                   ;dt >>= 4

*                lightmap = surf->samples;
*                r = 0;
*                if (lightmap)
*                {
*
*                        lightmap += dt * ((surf->extents[0]>>4)+1) + ds;

		move.l  d5,a2                   ;lightmap -> surf->samples
		moveq   #0,d5                   ;r = 0
		asr.l   #4,d2
		asr.l   #4,d3
		addq.l  #1,d2                   ;d2 = (surf->extents[0]>>4)+1
		addq.l  #1,d3                   ;d3 = (surf->extents[1]>>4)+1

		muls.l  d2,d1
		add.l   d4,d1
		add.l   d1,a2                   ;lightmap += dt * ...

*                        for (maps = 0 ; maps < MAXLIGHTMAPS && surf->styles[maps] != 255 ;
*                                        maps++)
*                        {
*                                scale = d_lightstylevalue[surf->styles[maps]];
*                                r += *lightmap * scale;
*                                lightmap += ((surf->extents[0]>>4)+1) *
*                                                ((surf->extents[1]>>4)+1);
*                        }
*
*                        r >>= 8;
*                }
*                return r;

		lea     MSURFACE_STYLES(a0),a5
		muls.l  d2,d3
		moveq   #MAXLIGHTMAPS-1,d0
		moveq   #0,d1
.loop2
		move.b  (a5)+,d1                ;surf->styles[map]
		cmp.b   #$ff,d1
		beq.b   .leave
		move.l  0(a1,d1.l*4),d2         ;scale = ...
		move.b  (a2),d1
		mulu.l  d1,d2
		add.l   d2,d5                   ;r += *lightmap * scale
		add.l   d3,a2                   ;lightmap += (...)
		dbra    d0,.loop2
.leave
		asr.l   #8,d5                   ;r >>= 8
		move.l  d5,d0                   ;return r
		bra.b   .end
.loopend
		lea     MSURFACE_SIZEOF(a0),a0
		dbra    d6,.loop

*        return RecursiveLightPoint (node->children[!side], mid, end);

.skip
		eori.l  #1,d7
		move.l  NODE_CHILDREN(a3,d7.l*4),a0
		move.l  a6,a1
		move.l  a4,a2
		bsr     DoRecursion
.end
		lea     12(sp),sp
		fmovem.x        (sp)+,fp2-fp7
		movem.l (sp)+,d2-d7/a2-a6
		rts

