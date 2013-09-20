**
** Quake for AMIGA
** r_draw.c assembler implementations by Frank Wille <frank@phoenix.owl.de>
**

		INCLUDE	"quakedef68k.i"

		XREF    _r_lastvertvalid
		XREF    _r_u1
		XREF    _r_v1
		XREF    _r_lzi1
		XREF    _r_ceilv1
		XREF    _r_nearzi
		XREF    _r_nearzionly
		XREF    _r_emitted
		XREF    _r_framecount
		XREF    _r_pedge
		XREF    _r_refdef
		XREF    _r_leftclipped
		XREF    _r_rightclipped
		XREF    _r_leftexit
		XREF    _r_rightexit
		XREF    _r_leftenter
		XREF    _r_rightenter
		XREF    _r_edges
		XREF    _r_outofsurfaces
		XREF    _r_outofedges
		XREF    _r_pcurrentvertbase
		XREF    _r_polycount
		XREF    _r_currentkey
		XREF    _c_faceclip
		XREF    _modelorg
		XREF    _xscale
		XREF    _yscale
		XREF    _xscaleinv
		XREF    _yscaleinv
		XREF    _xcenter
		XREF    _ycenter
		XREF    _vright
		XREF    _vup
		XREF    _vpn
		XREF    _cacheoffset
		XREF    _edge_p
		XREF    _surfaces
		XREF    _surface_p
		XREF    _surf_max
		XREF    _edge_max
		XREF    _newedges
		XREF    _removeedges
		XREF    _view_clipplanes
		XREF    _insubmodel
		XREF    _currententity
		XREF    _makeleftedge
		XREF    _makerightedge

		XDEF    _R_EmitEdge
		XDEF    _R_ClipEdge
		XDEF    _R_RenderFace

;TODO: vasm limitation
;NEAR_CLIP               equ.s   0.01            ;must match the def. in r_local.h
FULLY_CLIPPED_CACHED    =       $80000000
FRAMECOUNT_MASK         =       $7FFFFFFF



******************************************************************************
*
*       void _R_EmitEdge (mvertex_t *pv0, mvertex_t *pv1)
*
******************************************************************************

		cnop    0,4
_R_EmitEdge

		rsreset
.fpuregs        rs.x    6
.intregs        rs.l    7
		rs.l    1
.pv0            rs.l    1
.pv1            rs.l    1

		movem.l d2-d5/a2-a4,-(sp)
		fmovem.x        fp2-fp7,-(sp)
		fmove.l fpcr,d5
		fmove.l #$000000b0,fpcr
		move.l  .pv0(sp),a0
		move.l  .pv1(sp),a1
		lea     _r_refdef,a4

*        if (r_lastvertvalid)
*        {
*                u0 = r_u1;
*                v0 = r_v1;
*                lzi0 = r_lzi1;
*                ceilv0 = r_ceilv1;
*        }

		tst.l   _r_lastvertvalid
		beq.b   .else
		fmove.s _r_u1,fp0               ;u0 = r_u1
		fmove.s _r_v1,fp1               ;v0 = r_v1
		fmove.s _r_lzi1,fp2             ;lzi0 = r_lzi1
		move.l  _r_ceilv1,d0            ;ceilv0 = r_ceilv1
		bra.b   .next

*                world = &pv0->position[0];
*
*                VectorSubtract (world, modelorg, local);
*                TransformVector (local, transformed);
*
*                if (transformed[2] < NEAR_CLIP)
*                        transformed[2] = NEAR_CLIP;
*
*                lzi0 = 1.0 / transformed[2];
*
*                scale = xscale * lzi0;
*                u0 = (xcenter + scale*transformed[0]);
*                if (u0 < r_refdef.fvrectx_adj)
*                        u0 = r_refdef.fvrectx_adj;
*                if (u0 > r_refdef.fvrectright_adj)
*                        u0 = r_refdef.fvrectright_adj;
*
*                scale = yscale * lzi0;
*                v0 = (ycenter - scale*transformed[1]);
*                if (v0 < r_refdef.fvrecty_adj)
*                        v0 = r_refdef.fvrecty_adj;
*                if (v0 > r_refdef.fvrectbottom_adj)
*                        v0 = r_refdef.fvrectbottom_adj;
*
*                ceilv0 = (int) ceil(v0);

.else
		lea     _modelorg,a2

******  VectorSubtract (inlined)

		fmove.s (a0)+,fp3               ;VectorSubtract (world,
		fsub.s  (a2)+,fp3               ;modelorg,local)
		fmove.s (a0)+,fp4
		fsub.s  (a2)+,fp4
		fmove.s (a0)+,fp5
		fsub.s  (a2)+,fp5

******  TransformVector (inlined)

		lea     _vright,a3              ;TransformVector (local,
		fmove.s (a3)+,fp0               ;transformed)
		fmul    fp3,fp0
		fmove.s (a3)+,fp1
		fmul    fp4,fp1
		fadd    fp1,fp0
		fmove.s (a3)+,fp1
		fmul    fp5,fp1
		fadd    fp1,fp0                 ;fp0 = transformed[0]
		lea     _vup,a3
		fmove.s (a3)+,fp1
		fmul    fp3,fp1
		fmove.s (a3)+,fp2
		fmul    fp4,fp2
		fadd    fp2,fp1
		fmove.s (a3)+,fp2
		fmul    fp5,fp2
		fadd    fp2,fp1                 ;fp1 = transformed[1]
		lea     _vpn,a3
		fmul.s  (a3)+,fp3
		fmul.s  (a3)+,fp4
		fmul.s  (a3)+,fp5
		fadd    fp4,fp3
		fadd    fp5,fp3                 ;fp3 = transformed[2]

******  end of TransformVector

		;fcmp.s  #NEAR_CLIP,fp3          ;if transformed[2] < NEAR_CLIP
		fcmp.s	#0.01,fp3
		fboge.w .cont
		;fmove.s #NEAR_CLIP,fp3          ;transformed[2] = NEAR_CLIP
		fmove.s	#0.01,fp3
.cont
		fmove.s #1,fp2
		fdiv    fp3,fp2                 ;lzi0 = 1.0 / transformed[2]
		fmul    fp2,fp0
		fmul.s  _xscale,fp0             ;scale = scale * lzi0
		fadd.s  _xcenter,fp0            ;u0 = xcenter + (scale * lzi0)
		fmove.s REFDEF_FVRECTX_ADJ(a4),fp7 ;if (u0 < r_refdef.fvrectx ...
		fcmp    fp7,fp0
		fboge.w .cont2
		fmove   fp7,fp0                 ;u0 = r_refdef.fvrectx_adj
.cont2
		fmove.s REFDEF_FVRECTRIGHT_ADJ(a4),fp7
		fcmp    fp7,fp0                 ;if (u0 > r_refdef.fvrec...
		fbole.w .cont3
		fmove   fp7,fp0                 ;u0 = r_refdef.fvrectright_adj
.cont3
		fmul    fp2,fp1
		fmul.s  _yscale,fp1
		fsub.s  _ycenter,fp1
		fneg    fp1                     ;scale = yscale * lzi0
		fmove.s REFDEF_FVRECTY_ADJ(a4),fp7
		fcmp    fp7,fp1                 ;if (v0 < refdef.fvrecty_adj)
		fboge.w .cont4
		fmove   fp7,fp1                 ;v0 = ycenter - scale*transformed[1]
.cont4
		fmove.s REFDEF_FVRECTBOTTOM_ADJ(a4),fp7
		fcmp    fp7,fp1                 ;if (v0 > r_refdef.fvrectb...
		fbole.w .cont5
		fmove   fp7,fp1                 ;v0 = r_refdef.fvrectbottom_adj
.cont5
		fmove.l fp1,d0
.next

*        world = &pv1->position[0];
*
*// transform and project
*        VectorSubtract (world, modelorg, local);
*        TransformVector (local, transformed);
*
*        if (transformed[2] < NEAR_CLIP)
*                transformed[2] = NEAR_CLIP;
*
*        r_lzi1 = 1.0 / transformed[2];
*
*        scale = xscale * r_lzi1;
*        r_u1 = (xcenter + scale*transformed[0]);
*        if (r_u1 < r_refdef.fvrectx_adj)
*                r_u1 = r_refdef.fvrectx_adj;
*        if (r_u1 > r_refdef.fvrectright_adj)
*                r_u1 = r_refdef.fvrectright_adj;
*
*        scale = yscale * r_lzi1;
*        r_v1 = (ycenter - scale*transformed[1]);
*        if (r_v1 < r_refdef.fvrecty_adj)
*                r_v1 = r_refdef.fvrecty_adj;
*        if (r_v1 > r_refdef.fvrectbottom_adj)
*                r_v1 = r_refdef.fvrectbottom_adj;

		fmove.s fp0,-(sp)

******  VectorSubtract (inlined)

		lea     _modelorg,a2
		fmove.s (a1)+,fp3               ;VectorSubtract (world, modelorg
		fsub.s  (a2)+,fp3               ;local)
		fmove.s (a1)+,fp4
		fsub.s  (a2)+,fp4
		fmove.s (a1)+,fp5
		fsub.s  (a2)+,fp5

******  TransformVector (inlined)

		lea     _vright,a3              ;TransformVector (local, transformed)
		fmove.s (a3)+,fp6
		fmul    fp3,fp6
		fmove.s (a3)+,fp7
		fmul    fp4,fp7
		fadd    fp7,fp6
		fmove.s (a3)+,fp7
		fmul    fp5,fp7
		fadd    fp6,fp7                 ;fp7 = transformed[0]
		lea     _vup,a3
		fmove.s (a3)+,fp6
		fmul    fp3,fp6
		fmove.s (a3)+,fp0
		fmul    fp4,fp0
		fadd    fp0,fp6
		fmove.s (a3)+,fp0
		fmul    fp5,fp0
		fadd    fp0,fp6                 ;fp6 = transformed[1]
		fmove.s (sp)+,fp0
		lea     _vpn,a3
		fmul.s  (a3)+,fp3
		fmul.s  (a3)+,fp4
		fmul.s  (a3)+,fp5
		fadd    fp4,fp3
		fadd    fp5,fp3                 ;fp3 = transformed[2]

******  end of TransformVector

		;fcmp.s  #NEAR_CLIP,fp3          ;if transformed[2] < NEAR_CLIP
		fcmp.s	#0.01,fp3
		fboge.w .cont6
		;fmove.s #NEAR_CLIP,fp3          ;transformed[2] = NEAR_CLIP
		fmove.s	#0.01,fp3
.cont6
		fmove.s #1,fp5
		fdiv    fp3,fp5                 ;r_lzi1 = 1.0 / transformed[2]
		fmul    fp5,fp7
		fmul.s  _xscale,fp7
		fadd.s  _xcenter,fp7            ;scale = xscale * r_lzi
		fmove.s REFDEF_FVRECTX_ADJ(a4),fp4
		fcmp    fp4,fp7                 ;if (r_u1 < r_refdef...
		fboge.w .cont7
		fmove   fp4,fp7                 ;r_u1 = r_refdef.fvrectx_adj)
.cont7
		fmove.s REFDEF_FVRECTRIGHT_ADJ(a4),fp4
		fcmp    fp4,fp7                 ;if (r_u1 > r_refdef...
		fbole.w .cont8
		fmove   fp4,fp7                 ;r_u1 = r_refdef.fvrectright_adj)
.cont8
		fmul    fp5,fp6
		fmul.s  _yscale,fp6
		fsub.s  _ycenter,fp6
		fneg    fp6                     ;scale = yscale * r_lzi1
		fmove.s REFDEF_FVRECTY_ADJ(a4),fp4
		fcmp    fp4,fp6                 ;if (r_v1 < r_refdef...
		fboge.w .cont9
		fmove   fp4,fp6                 ;r_v1 = r_refdef.fvrecty_adj
.cont9
		fmove.s REFDEF_FVRECTBOTTOM_ADJ(a4),fp4
		fcmp    fp4,fp6                 ;if (r_v1 > r_refdef...
		fbole.w .cont10
		fmove   fp4,fp6                 ;r_v1 = r_refdef.fvrectbottom_adj)
.cont10

*        if (r_lzi1 > lzi0)
*                lzi0 = r_lzi1;
*
*        if (lzi0 > r_nearzi)    // for mipmap finding
*                r_nearzi = lzi0;
*
*// for right edges, all we want is the effect on 1/z
*        if (r_nearzionly)
*                return;
*
*        r_emitted = 1;
*
*        r_ceilv1 = (int) ceil(r_v1);

		fcmp    fp5,fp2                 ;if (r_lzi1 > lzi0)
		fboge.w .cont11
		fmove   fp5,fp2                 ;lzi0 = r_lzi1
.cont11
		fcmp.s  _r_nearzi,fp2           ;if (lzi0 > r_nearzi)
		fbole.w .cont12
		fmove.s fp2,_r_nearzi           ;r_nearzi = lzi0
.cont12
		fmove.l fp6,d1                  ;r_ceilv1 = (int) ceil(r_v1)
		fmove.l d5,fpcr
		tst.l   _r_nearzionly           ;if (r_nearzionly)
		bne.b   .exit2                  ;return
		move.l  #1,_r_emitted           ;r_emitted = 1

*        if (ceilv0 == r_ceilv1)
*        {
*        // we cache unclipped horizontal edges as fully clipped
*                if (cacheoffset != 0x7FFFFFFF)
*                {
*                        cacheoffset = FULLY_CLIPPED_CACHED |
*                                        (r_framecount & FRAMECOUNT_MASK);
*                }
*
*                return;         // horizontal edge
*        }

		cmp.l   d0,d1                   ;if (ceilv0 == r_ceilv1)
		bne.b   .cont13
		cmp.l   #$7fffffff,_cacheoffset ;if (cacheoffset != 0x7fffffff)
		beq.b   .exit1
		move.l  _r_framecount,d2
		and.l   #FRAMECOUNT_MASK,d2
		or.l    #FULLY_CLIPPED_CACHED,d2
		move.l  d2,_cacheoffset         ;cacheoffset = FULLY...
		bra.b   .exit1

*        side = ceilv0 > r_ceilv1;
*
*        edge = edge_p++;
*
*        edge->owner = r_pedge;
*
*        edge->nearzi = lzi0;

.cont13
		move.l  _edge_p,a2
		add.l   #EDGE_SIZEOF,_edge_p    ;edge = edge_p++
		move.l  _r_pedge,EDGE_OWNER(a2) ;edge->owner = r_pedge
		fmove.s fp2,EDGE_NEARZI(a2)     ;edge->nearzi = lzi0

*        if (side == 0)
*        {
*        // trailing edge (go from p1 to p2)
*                v = ceilv0;
*                v2 = r_ceilv1 - 1;
*
*                edge->surfs[0] = surface_p - surfaces;
*                edge->surfs[1] = 0;
*
*                u_step = ((r_u1 - u0) / (r_v1 - v0));
*                u = u0 + ((float)v - v0) * u_step;
*        }

		cmp.l   d1,d0                   ;if (side == 0)
		bgt.b   .else2
		move.l  d0,d2                   ;v = ceilv0
		move.l  d1,d3
		subq.l  #1,d3                   ;v2 = r_ceilv1 - 1
		move.l  _surface_p,d0           ;edge->surfs[0] = surface_p - surfaces
		sub.l   _surfaces,d0
		asr.l   #6,d0
		swap    d0
		clr     d0
		move.l  d0,EDGE_SURFS(a2)       ;edge->surfs[1] = 0
		fmove.l d2,fp3
		fmove   fp0,fp2
		fsub    fp1,fp3
		fsub    fp7,fp0
		fsub    fp6,fp1
		fdiv    fp1,fp0                 ;u_step = ((r_u1-u0)/(r_v1-v0))
		fmul    fp0,fp3
		fadd    fp2,fp3                 ;u = u0 + ((float)v-v0)*u_step
		bra.b   .cont14

*        {
*        // leading edge (go from p2 to p1)
*                v2 = ceilv0 - 1;
*                v = r_ceilv1;
*
*                edge->surfs[0] = 0;
*                edge->surfs[1] = surface_p - surfaces;
*
*                u_step = ((u0 - r_u1) / (v0 - r_v1));
*                u = r_u1 + ((float)v - r_v1) * u_step;
*        }

.else2
		move.l  d1,d2                   ;v = r_ceilv1
		move.l  d0,d3
		subq.l  #1,d3                   ;v2 = ceilv0 - 1
		move.l  _surface_p,d0           ;edge->surfs[0] = 0
		sub.l   _surfaces,d0
		asr.l   #6,d0
		and.l   #$ffff,d0
		move.l  d0,EDGE_SURFS(a2)       ;edge->surfs[1] = surface_p-surfaces
		fmove.l d2,fp3
		fsub    fp6,fp3
		fsub    fp7,fp0
		fsub    fp6,fp1
		fdiv    fp1,fp0                 ;u_step = ((u0-r_u1)/(v0-r_v1))
		fmul    fp0,fp3
		fadd    fp7,fp3                 ;u = r_u1+((float)v-r_v1)*u_step

*        edge->u_step = u_step*0x100000;
*        edge->u = u*0x100000 + 0xFFFFF;

.cont14
		fmove.s #16*65536,fp4
		fmul    fp4,fp0
		fmove.l fp0,EDGE_U_STEP(a2)     ;edge->u_step = u_step*$100000
		fmul    fp4,fp3
		fadd.s  #(16*65536)-1,fp3       ;edge->u = u*$100000 + $fffff
		fmove.l fp3,d0

*        if (edge->u < r_refdef.vrect_x_adj_shift20)
*                edge->u = r_refdef.vrect_x_adj_shift20;
*        if (edge->u > r_refdef.vrectright_adj_shift20)
*                edge->u = r_refdef.vrectright_adj_shift20;

		move.l  REFDEF_VRECTX_ADJ_S20(a4),d4
		cmp.l   d4,d0
		bge.b   .cont15
		move.l  d4,d0
.cont15
		move.l  REFDEF_VRECTXR_ADJ_S20(a4),d4
		cmp.l   d4,d0
		ble.b   .cont16
		move.l  d4,d0

*        u_check = edge->u;
*        if (edge->surfs[0])
*                u_check++;      // sort trailers after leaders
*
*        if (!newedges[v] || newedges[v]->u >= u_check)
*        {
*                edge->next = newedges[v];
*                newedges[v] = edge;
*        }
*        else
*        {
*                pcheck = newedges[v];
*                while (pcheck->next && pcheck->next->u < u_check)
*                        pcheck = pcheck->next;
*                edge->next = pcheck->next;
*                pcheck->next = edge;
*        }

.cont16
		move.l  d0,EDGE_U(a2)
		tst     EDGE_SURFS(a2)          ;if (edge->surfs[0])
		beq.b   .cont17
		addq.l  #1,d0                   ;u_check++
.cont17
		lea     _newedges,a0            ;if (!newedges[v] || ...
		move.l  0(a0,d2.l*4),d4
		beq.b   .cont18
		move.l  d4,a1
		cmp.l   EDGE_U(a1),d0
		bgt.b   .cont19
.cont18
		move.l  d4,EDGE_NEXT(a2)        ;edge->next = newedges[v]
		move.l  a2,0(a0,d2.l*4)         ;newedges[v] = edge
		bra.b   .cont21
.cont19
		move.l  d4,a1                   ;pcheck = newedges[v]
.loop
		move.l  EDGE_NEXT(a1),d4        ;while (pcheck->next &&...
		beq.b   .cont20
		move.l  a1,d2
		move.l  d4,a1                   ;pcheck = pcheck->next
		cmp.l   EDGE_U(a1),d0
		bgt.b   .loop
		move.l  d2,a1
.cont20
		move.l  d4,EDGE_NEXT(a2)        ;edge->next = pcheck->next
		move.l  a2,EDGE_NEXT(a1)        ;pcheck->next = edge

*        edge->nextremove = removeedges[v2];
*        removeedges[v2] = edge;

.cont21
		lea     _removeedges,a0
		move.l  0(a0,d3.l*4),EDGE_NEXTREMOVE(a2)
		move.l  a2,0(a0,d3.l*4)
.exit1
		move.l  d1,_r_ceilv1
.exit2
		fmove.s fp5,_r_lzi1
		fmove.s fp7,_r_u1
		fmove.s fp6,_r_v1
		fmovem.x        (sp)+,fp2-fp7
		movem.l (sp)+,d2-d5/a2-a4
		rts


******************************************************************************
*
*       void _R_ClipEdge (mvertex_t *pv0, mvertex_t *pv1, clipplane_t *clip)
*
******************************************************************************

		cnop    0,4
_R_ClipEdge

		rsreset
.fpuregs        rs.x    6
.intregs        rs.l    2
		rs.l    1
.pv0            rs.l    1
.pv1            rs.l    1
.cp             rs.l    1

		movem.l a2/a3,-(sp)
		fmovem.x        fp2-fp7,-(sp)
		move.l  .pv0(sp),a0
		move.l  .pv1(sp),a1
		move.l  .cp(sp),a2
		bsr     DoRecursion
		fmovem.x        (sp)+,fp2-fp7
		movem.l (sp)+,a2/a3
		rts

DoRecursion
		lea     -CLIP_SIZEOF(sp),sp
		move.l  sp,a3
		tst.l   a2
		beq.w   .add
.loop

*                        d0 = DotProduct (pv0->position, clip->normal) - clip->dist;
*                        d1 = DotProduct (pv1->position, clip->normal) - clip->dist;

		fmove.s CLIP_NORMAL(a2),fp0
		fmove.s CLIP_NORMAL+4(a2),fp1
		fmove.s CLIP_NORMAL+8(a2),fp2
		fmove.s (a0),fp3
		fmove   fp3,fp5                 ;fp5 = pv0->position[0]
		fmul    fp0,fp3
		fmove.s 4(a0),fp4
		fmove   fp4,fp6                 ;fp6 = pv0->position[1]
		fmul    fp1,fp4
		fadd    fp4,fp3
		fmove.s 8(a0),fp4
		fmove   fp4,fp7                 ;fp7 = pv0->position[2]
		fmul    fp2,fp4
		fadd    fp4,fp3
		fmove.s (a1),fp4                ;fp4 = pv1->position[0]
		fmul    fp4,fp0
		fmul.s  4(a1),fp1
		fadd    fp1,fp0
		fmove.s 8(a1),fp1               ;fp1 = pv1->position[2]
		fmul    fp1,fp2
		fadd    fp2,fp0
		fmove.s CLIP_DIST(a2),fp2
		fsub    fp2,fp3                 ;fp3 = d0
		fsub    fp2,fp0                 ;fp0 = d1
		fmove.s 4(a1),fp2               ;fp2 = pv1->position[1]

*                        if (d0 >= 0)
*                        {
*                        // point 0 is unclipped
*                                if (d1 >= 0)
*                                {
*                                // both points are unclipped
*                                        continue;
*                                }

		ftst    fp3
		fbolt   .less
		ftst    fp0
		fboge   .loopend

*                                cacheoffset = 0x7FFFFFFF;
*
*                                f = d0 / (d0 - d1);
*                                clipvert.position[0] = pv0->position[0] +
*                                                f * (pv1->position[0] - pv0->position[0]);
*                                clipvert.position[1] = pv0->position[1] +
*                                                f * (pv1->position[1] - pv0->position[1]);
*                                clipvert.position[2] = pv0->position[2] +
*                                                f * (pv1->position[2] - pv0->position[2]);

		move.l  #$7fffffff,_cacheoffset
		fsub    fp3,fp0
		fdiv    fp0,fp3
		fneg    fp3                     ;fp3 = f
		fsub    fp5,fp4
		fmul    fp3,fp4
		fadd    fp5,fp4
		fmove.s fp4,(a3)                ;clipvert.position[0]
		fsub    fp6,fp2
		fmul    fp3,fp2
		fadd    fp6,fp2
		fmove.s fp2,4(a3)               ;clipvert.position[1]
		fsub    fp7,fp1
		fmul    fp3,fp1
		fadd    fp7,fp1
		fmove.s fp1,8(a3)               ;clipvert.position[2]

*                                if (clip->leftedge)
*                                {
*                                        r_leftclipped = true;
*                                        r_leftexit = clipvert;
*                                }

		tst.b   CLIP_LEFTEDGE(a2)
		beq.b   .else
		move.l  #1,_r_leftclipped
		lea     _r_leftexit,a1
		move.l  (a3)+,(a1)+
		move.l  (a3)+,(a1)+
		move.l  (a3)+,(a1)+
		bra.b   .cont

*                                else if (clip->rightedge)
*                                {
*                                        r_rightclipped = true;
*                                        r_rightexit = clipvert;
*                                }

.else
		move.l  #1,_r_rightclipped
		lea     _r_rightexit,a1
		move.l  (a3)+,(a1)+
		move.l  (a3)+,(a1)+
		move.l  (a3)+,(a1)+

*                                R_ClipEdge (pv0, &clipvert, clip->next);
*                                return;

.cont
		sub     #12,a3
		move.l  a3,a1
		move.l  CLIP_NEXT(a2),a2
		bsr     DoRecursion
		bra.w   .exit

*                                if (d1 < 0)
*                                {
*                                // both points are clipped
*                                // we do cache fully clipped edges
*                                        if (!r_leftclipped)
*                                                cacheoffset = FULLY_CLIPPED_CACHED |
*                                                                (r_framecount & FRAMECOUNT_MASK);
*                                        return;
*                                }

.less
		ftst    fp0
		fboge.w .cont2
		tst.l   _r_leftclipped
		bne.w   .exit
		move.l  _r_framecount,d0
		and.l   #FRAMECOUNT_MASK,d0
		or.l    #FULLY_CLIPPED_CACHED,d0
		move.l  d0,_cacheoffset
		bra.w   .exit

*                                r_lastvertvalid = false;
*
*                        // we don't cache partially clipped edges
*                                cacheoffset = 0x7FFFFFFF;
*
*                                f = d0 / (d0 - d1);
*                                clipvert.position[0] = pv0->position[0] +
*                                                f * (pv1->position[0] - pv0->position[0]);
*                                clipvert.position[1] = pv0->position[1] +
*                                                f * (pv1->position[1] - pv0->position[1]);
*                                clipvert.position[2] = pv0->position[2] +
*                                                f * (pv1->position[2] - pv0->position[2]);

.cont2
		clr.l   _r_lastvertvalid
		move.l  #$7fffffff,_cacheoffset
		fsub    fp3,fp0
		fdiv    fp0,fp3
		fneg    fp3                     ;fp3 = f
		fsub    fp5,fp4
		fmul    fp3,fp4
		fadd    fp5,fp4
		fmove.s fp4,(a3)                ;clipvert.position[0]
		fsub    fp6,fp2
		fmul    fp3,fp2
		fadd    fp6,fp2
		fmove.s fp2,4(a3)               ;clipvert.position[1]
		fsub    fp7,fp1
		fmul    fp3,fp1
		fadd    fp7,fp1
		fmove.s fp1,8(a3)               ;clipvert.position[2]

*                                if (clip->leftedge)
*                                {
*                                        r_leftclipped = true;
*                                        r_leftenter = clipvert;
*                                }

		tst.b   CLIP_LEFTEDGE(a2)
		beq.b   .else2
		move.l  #1,_r_leftclipped
		lea     _r_leftenter,a0
		move.l  (a3)+,(a0)+
		move.l  (a3)+,(a0)+
		move.l  (a3)+,(a0)+
		bra.b   .cont3

*                                else if (clip->rightedge)
*                                {
*                                        r_rightclipped = true;
*                                        r_rightenter = clipvert;
*                                }

.else2
		move.l  #1,_r_rightclipped
		lea     _r_rightenter,a0
		move.l  (a3)+,(a0)+
		move.l  (a3)+,(a0)+
		move.l  (a3)+,(a0)+

*                                R_ClipEdge (&clipvert, pv1, clip->next);
*                                return;

.cont3
		sub     #12,a3
		move.l  a3,a0
		move.l  CLIP_NEXT(a2),a2
		bsr     DoRecursion
		bra.w   .exit

*                } while ((clip = clip->next) != NULL);

.loopend
		move.l  CLIP_NEXT(a2),d0
		beq.b   .add
		move.l  d0,a2
		bra.w   .loop

*        R_EmitEdge (pv0, pv1);

.add
		move.l  a1,-(sp)
		move.l  a0,-(sp)
		bsr     _R_EmitEdge
		addq    #8,sp
.exit
		lea     CLIP_SIZEOF(sp),sp
		rts




******************************************************************************
*
*       void _R_RenderFace (msurface_t *fa, int clipflags)
*
******************************************************************************

		cnop    0,4
_R_RenderFace


		rsreset
.fpuregs        rs.x    5
.intregs        rs.l    11
		rs.l    1
.fa             rs.l    1
.clipflags      rs.l    1


		movem.l d2-d7/a2-a6,-(sp)
		fmovem.x        fp2-fp6,-(sp)
		move.l  .fa(sp),a3
		move.l  .clipflags(sp),d0

*// skip out if no more surfs
*        if ((surface_p) >= surf_max)
*        {
*                r_outofsurfaces++;
*                return;
*        }

		move.l  _surface_p,a2
		cmp.l   _surf_max,a2            ;if ((surface_p) >= surf_max)
		blo.b   .cont
		addq.l  #1,_r_outofsurfaces     ;r_outofsurfaces++
		bra.w   .end                    ;return

*        if ((edge_p + fa->numedges + 4) >= edge_max)
*        {
*                r_outofedges += fa->numedges;
*                return;
*        }
*
*        c_faceclip++;

.cont
		move.l  MSURFACE_NUMEDGES(a3),d1
		move.l  d1,d2
		asl.l   #EDGE_SIZEOF_EXP,d1
		add.l   #4*EDGE_SIZEOF,d1
		move.l  _edge_p,d6
		add.l   d6,d1                   ;edge_p + fa->numedges + 4
		cmp.l   _edge_max,d1            ;if d1 >= edge_max
		blo.b   .cont2
		add.l   d2,_r_outofedges        ;r_outofedges += fa->numedges
		bra.w   .end                    ;return
.cont2
		addq.l  #1,_c_faceclip          ;c_faceclip++

*        pclip = NULL;
*
*        for (i=3, mask = 0x08 ; i>=0 ; i--, mask >>= 1)
*        {
*                if (clipflags & mask)
*                {
*                        view_clipplanes[i].next = pclip;
*                        pclip = &view_clipplanes[i];
*                }
*        }

		sub.l   a0,a0                   ;pclip = NULL
		lea     _view_clipplanes,a1
		lsl.b   #4,d0
		lsl.b   #1,d0                   ;if (clipflags & mask)
		bcc.b   .nocarry1
		move.l  a0,CLIP_NEXT+3*CLIP_SIZEOF(a1)
		lea     3*CLIP_SIZEOF(a1),a0
.nocarry1
		lsl.b   #1,d0
		bcc.b   .nocarry2
		move.l  a0,CLIP_NEXT+2*CLIP_SIZEOF(a1)
		lea     2*CLIP_SIZEOF(a1),a0
.nocarry2
		lsl.b   #1,d0
		bcc.b   .nocarry3
		move.l  a0,CLIP_NEXT+1*CLIP_SIZEOF(a1)
		lea     1*CLIP_SIZEOF(a1),a0
.nocarry3
		lsl.b   #1,d0
		bcc.b   .nocarry4
		move.l  a0,CLIP_NEXT(a1)        ;view_clipplanes[0].next=pclip
		move.l  a1,a0                   ;pclip = &view_clipplanes[i]
.nocarry4
		move.l  a0,a2

*        r_emitted = 0;
*        r_nearzi = 0;
*        r_nearzionly = false;
*        makeleftedge = makerightedge = false;
*        pedges = currententity->model->edges;
*        r_lastvertvalid = false;

		clr.l   _r_emitted
		clr.l   _r_nearzi
		clr.l   _r_nearzionly
		clr.l   _makeleftedge
		clr.l   _makerightedge
		move.l  _currententity,a0
		move.l  ENTITY_MODEL(a0),a6
		move.l  MODEL_EDGES(a6),d4      ;pedges = currententity->mod...
		clr.l   _r_lastvertvalid
		move.l  _r_edges,d5
		move.l  _r_pcurrentvertbase,a4
		move.l  _surface_p,d7
		sub.l   _surfaces,d7
		asr.l   #6,d7
		subq    #1,d2
		bmi.w   .noloop
		moveq   #0,d3

*        for (i=0 ; i<fa->numedges ; i++)
*        {
*                lindex = currententity->model->surfedges[fa->firstedge + i];

.loop
		move.l  MODEL_SURFEDGES(a6),a1  ;&currententity->model->surfedges
		move.l  MSURFACE_FIRSTEDGE(a3),d0
		add.l   d3,d0                   ;fa->firstedge + i
		move.l  0(a1,d0.l*4),d0         ;lindex = currententity->model...

*                if (lindex > 0)

		ble.b   .cont3                  ;if (lindex > 0)

*                        r_pedge = &pedges[lindex];
*
*                // if the edge is cached, we can just reuse the edge
*                        if (!insubmodel)

		asl.l   #MEDGE_SIZEOF_EXP,d0
		add.l   d4,d0
		move.l  d0,a5
		move.l  a5,_r_pedge             ;r_pedge = &pedges[lindex]
		tst.l   _insubmodel             ;if (!insubmodel)
		bne.b   .nosub

*                                if (r_pedge->cachededgeoffset & FULLY_CLIPPED_CACHED)
*                                {
*                                        if ((r_pedge->cachededgeoffset & FRAMECOUNT_MASK) ==
*                                                r_framecount)
*                                        {
*                                                r_lastvertvalid = false;
*                                                continue;
*                                        }
*                                }

		move.l  MEDGE_CEO(a5),d0        ;if (r_pedge->cache... & FULLY...)
		move.l  d0,d1
		and.l   #FULLY_CLIPPED_CACHED,d0
		beq.b   .else
		and.l   #FRAMECOUNT_MASK,d1     ;if ((r_pedge->cache... & FRA...)
		cmp.l   _r_framecount,d1
		bne.b   .nosub
		clr.l   _r_lastvertvalid        ;r_lastvertvalid = false
		bra.w   .loopend

*                                        if ((((unsigned long)edge_p - (unsigned long)r_edges) >
*                                                 r_pedge->cachededgeoffset) &&
*                                                (((edge_t *)((unsigned long)r_edges +
*                                                 r_pedge->cachededgeoffset))->owner == r_pedge))
*                                        {
*                                                R_EmitCachedEdge ();
*                                                r_lastvertvalid = false;
*                                                continue;
*                                        }

.else
		move.l  d6,d0
		sub.l   d5,d0
		cmp.l   d1,d0
		bls.b   .nosub
		move.l  d1,a0
		add.l   d5,a0
		cmp.l   EDGE_OWNER(a0),a5
		bne.b   .nosub


******  EmitCachedEdge (inlined)

*        pedge_t = (edge_t *)((unsigned long)r_edges + r_pedge->cachededgeoffset);
*
*        if (!pedge_t->surfs[0])
*                pedge_t->surfs[0] = surface_p - surfaces;
*        else
*                pedge_t->surfs[1] = surface_p - surfaces;
*
*        if (pedge_t->nearzi > r_nearzi) // for mipmap finding
*                r_nearzi = pedge_t->nearzi;
*
*        r_emitted = 1;

		tst     EDGE_SURFS(a0)
		bne.b   .contE
		move    d7,EDGE_SURFS(a0)
		bra.b   .cont2E
.contE
		move    d7,EDGE_SURFS+1*2(a0)
.cont2E
		fmove.s EDGE_NEARZI(a0),fp0
		fcmp.s  _r_nearzi,fp0
		fbole.w .cont3E
		move.l  EDGE_NEARZI(a0),_r_nearzi
.cont3E
		move.l  #1,_r_emitted

******  End of EmitCachedEdge


		clr.l   _r_lastvertvalid
		bra.w   .loopend

*                        cacheoffset = (byte *)edge_p - (byte *)r_edges;
*                        r_leftclipped = r_rightclipped = false;
*                        R_ClipEdge (&r_pcurrentvertbase[r_pedge->v[0]],
*                                                &r_pcurrentvertbase[r_pedge->v[1]],
*                                                pclip);
*                        r_pedge->cachededgeoffset = cacheoffset;
*
*                        if (r_leftclipped)
*                                makeleftedge = true;
*                        if (r_rightclipped)
*                                makerightedge = true;
*                        r_lastvertvalid = true;

.nosub
		move.l  d6,d0
		sub.l   d5,d0
		move.l  d0,_cacheoffset         ;cacheoffset = (byte*)edge_p...
		clr.l   _r_leftclipped
		clr.l   _r_rightclipped
		move.l  a2,-(sp)
		move    MEDGE_V+1*2(a5),d0
		muls    #MVERTEX_SIZEOF,d0
		pea     0(a4,d0.l)
		move    MEDGE_V+0*2(a5),d0
		muls    #MVERTEX_SIZEOF,d0
		pea     0(a4,d0.l)
		jsr     _R_ClipEdge             ;R_ClipEdge (&r_pcu...
		add     #12,sp
		move.l  _edge_p,d6
		move.l  _cacheoffset,MEDGE_CEO(a5) ;r_pedge->cache... = cacheoffset
		tst.l   _r_leftclipped          ;if (r_leftclipped)
		beq.b   .noLC
		move.l  #1,_makeleftedge        ;makeleftedge = true
.noLC
		tst.l   _r_rightclipped         ;if (r_rightclipped)
		beq.b   .noRC
		move.l  #1,_makerightedge       ;makerightedge = true
.noRC
		move.l  #1,_r_lastvertvalid     ;r_lastvertvalid = true
		bra.b   .loopend
.cont3
		neg.l   d0                      ;lindex = -lindex

*                        r_pedge = &pedges[lindex];
*
*                // if the edge is cached, we can just reuse the edge
*                        if (!insubmodel)

		asl.l   #MEDGE_SIZEOF_EXP,d0
		add.l   d4,d0
		move.l  d0,a5
		move.l  a5,_r_pedge             ;r_pedge = &pedges[lindex]
		tst.l   _insubmodel             ;if (!insubmodel)
		bne.b   .nosub2

*                                if (r_pedge->cachededgeoffset & FULLY_CLIPPED_CACHED)
*                                {
*                                        if ((r_pedge->cachededgeoffset & FRAMECOUNT_MASK) ==
*                                                r_framecount)
*                                        {
*                                                r_lastvertvalid = false;
*                                                continue;
*                                        }
*                                }

		move.l  MEDGE_CEO(a5),d0        ;if (r_pedge->cache... & FULLY...)
		move.l  d0,d1
		and.l   #FULLY_CLIPPED_CACHED,d0
		beq.b   .else2
		and.l   #FRAMECOUNT_MASK,d1     ;if ((r_pedge->cache... & FRA...)
		cmp.l   _r_framecount,d1
		bne.b   .nosub2
		clr.l   _r_lastvertvalid        ;r_lastvertvalid = false
		bra.w   .loopend

*                                        if ((((unsigned long)edge_p - (unsigned long)r_edges) >
*                                                 r_pedge->cachededgeoffset) &&
*                                                (((edge_t *)((unsigned long)r_edges +
*                                                 r_pedge->cachededgeoffset))->owner == r_pedge))
*                                        {
*                                                R_EmitCachedEdge ();
*                                                r_lastvertvalid = false;
*                                                continue;
*                                        }

.else2
		move.l  d6,d0
		sub.l   d5,d0
		cmp.l   d1,d0
		bls.b   .nosub2
		move.l  d1,a0
		add.l   d5,a0
		cmp.l   EDGE_OWNER(a0),a5
		bne.b   .nosub2


******  EmitCachedEdge (inlined)

*        pedge_t = (edge_t *)((unsigned long)r_edges + r_pedge->cachededgeoffset);
*
*        if (!pedge_t->surfs[0])
*                pedge_t->surfs[0] = surface_p - surfaces;
*        else
*                pedge_t->surfs[1] = surface_p - surfaces;
*
*        if (pedge_t->nearzi > r_nearzi) // for mipmap finding
*                r_nearzi = pedge_t->nearzi;
*
*        r_emitted = 1;

		tst     EDGE_SURFS(a0)
		bne.b   .contE2
		move    d7,EDGE_SURFS(a0)
		bra.b   .cont2E2
.contE2
		move    d7,EDGE_SURFS+1*2(a0)
.cont2E2
		fmove.s EDGE_NEARZI(a0),fp0
		fcmp.s  _r_nearzi,fp0
		fbole.w .cont3E2
		move.l  EDGE_NEARZI(a0),_r_nearzi
.cont3E2
		move.l  #1,_r_emitted

******  End of EmitCachedEdge

		clr.l   _r_lastvertvalid
		bra.w   .loopend

*                        cacheoffset = (byte *)edge_p - (byte *)r_edges;
*                        r_leftclipped = r_rightclipped = false;
*                        R_ClipEdge (&r_pcurrentvertbase[r_pedge->v[0]],
*                                                &r_pcurrentvertbase[r_pedge->v[1]],
*                                                pclip);
*                        r_pedge->cachededgeoffset = cacheoffset;
*
*                        if (r_leftclipped)
*                                makeleftedge = true;
*                        if (r_rightclipped)
*                                makerightedge = true;
*                        r_lastvertvalid = true;

.nosub2
		move.l  d6,d0
		sub.l   d5,d0
		move.l  d0,_cacheoffset         ;cacheoffset = (byte*)edge_p...
		clr.l   _r_leftclipped
		clr.l   _r_rightclipped
		move.l  a2,-(sp)
		move    MEDGE_V+0*2(a5),d0
		muls    #MVERTEX_SIZEOF,d0
		pea     0(a4,d0.l)
		move    MEDGE_V+1*2(a5),d0
		muls    #MVERTEX_SIZEOF,d0
		pea     0(a4,d0.l)
		jsr     _R_ClipEdge             ;R_ClipEdge (&r_pcu...
		add     #12,sp
		move.l  _edge_p,d6
		move.l  _cacheoffset,MEDGE_CEO(a5) ;r_pedge->cache... = cacheoffset
		tst.l   _r_leftclipped          ;if (r_leftclipped)
		beq.b   .noLC2
		move.l  #1,_makeleftedge        ;makeleftedge = true
.noLC2
		tst.l   _r_rightclipped         ;if (r_rightclipped)
		beq.b   .noRC2
		move.l  #1,_makerightedge       ;makerightedge = true
.noRC2
		move.l  #1,_r_lastvertvalid     ;r_lastvertvalid = true
.loopend
		addq    #1,d3
		dbra    d2,.loop

*        if (makeleftedge)
*        {
*                r_pedge = &tedge;
*                r_lastvertvalid = false;
*                R_ClipEdge (&r_leftexit, &r_leftenter, pclip->next);
*        }

.noloop
		tst.l   _makeleftedge           ;if (makeleftedge)
		beq.b   .noLE
		clr.l   _r_lastvertvalid        ;r_lastvertvalid = false
		move.l  a2,a0
		move.l  CLIP_NEXT(a0),-(sp)
		move.l  #_r_leftenter,-(sp)
		move.l  #_r_leftexit,-(sp)
		jsr     _R_ClipEdge             ;R_ClipEdge (&r_leftexit,...)
		add     #12,sp

*        if (makerightedge)
*        {
*                r_pedge = &tedge;
*                r_lastvertvalid = false;
*                r_nearzionly = true;
*                R_ClipEdge (&r_rightexit, &r_rightenter, view_clipplanes[1].next);
*        }

.noLE
		tst.l   _makerightedge          ;if (makerightedge)
		beq.b   .noRE
		clr.l   _r_lastvertvalid        ;r_lastvertvalid = false
		move.l  #1,_r_nearzionly        ;r_nearzionly = true
		lea     _view_clipplanes,a0
		move.l  CLIP_NEXT+1*CLIP_SIZEOF(a0),-(sp)
		move.l  #_r_rightenter,-(sp)
		move.l  #_r_rightexit,-(sp)
		jsr     _R_ClipEdge             ;R_ClipEdge (&r_rightexit...)
		add     #12,sp

*        if (!r_emitted)
*                return;

.noRE
		tst.l   _r_emitted              ;if (!r_emitted)
		beq.w   .end                    ;return

*        r_polycount++;
*
*        surface_p->data = (void *)fa;
*        surface_p->nearzi = r_nearzi;
*        surface_p->flags = fa->flags;
*        surface_p->insubmodel = insubmodel;
*        surface_p->spanstate = 0;
*        surface_p->entity = currententity;
*        surface_p->key = r_currentkey++;
*        surface_p->spans = NULL;

		move.l  _r_currentkey,d0        ;r_currentkey++
		addq.l  #1,_r_currentkey
		addq.l  #1,_r_polycount         ;r_polycount++
		move.l  _surface_p,a0
		addq.l  #8,a0
		clr.l   (a0)+                   ;surface_p->spans = NULL
		move.l  d0,(a0)+                ;surface_p->key = r_currentkey++
		addq.l  #4,a0
		clr.l   (a0)+                   ;surface_p->spanstate = 0
		move.l  MSURFACE_FLAGS(a3),(a0)+ ;surface_p->flags = fa->flags
		move.l  a3,(a0)+                ;surface_p->data = (void *)fa
		move.l  _currententity,(a0)+    ;surface_p->entity = currententity
		move.l  _r_nearzi,(a0)+         ;surface_p->nearzi = r_nearzi
		move.l  _insubmodel,(a0)+       ;surface_p->insubmodel = insubmodel

*        pplane = fa->plane;

		move.l  MSURFACE_PLANE(a3),a1   ;pplane = fa->plane

*        TransformVector (pplane->normal, p_normal);

******  TransformVector (inlined)

		fmove.s (a1)+,fp3
		fmove.s (a1)+,fp4
		fmove.s (a1)+,fp5
		lea     _vright,a2
		fmove.s (a2)+,fp0
		fmul    fp3,fp0
		fmove.s (a2)+,fp1
		fmul    fp4,fp1
		fadd    fp1,fp0
		fmove.s (a2)+,fp1
		fmul    fp5,fp1
		fadd    fp1,fp0                 ;fp0 = p_normal[0]
		lea     _vup,a2
		fmove.s (a2)+,fp1
		fmul    fp3,fp1
		fmove.s (a2)+,fp2
		fmul    fp4,fp2
		fadd    fp2,fp1
		fmove.s (a2)+,fp2
		fmul    fp5,fp2
		fadd    fp2,fp1
		fneg    fp1                     ;fp1 = -p_normal[1]
		lea     _vpn,a2
		fmove.s (a2)+,fp2
		fmul    fp3,fp2
		fmove.s (a2)+,fp6
		fmul    fp4,fp6
		fadd    fp6,fp2
		fmove.s (a2)+,fp6
		fmul    fp5,fp6
		fadd    fp6,fp2                 ;fp2 = p_normal[2]

******  End of TransformVector

*        distinv = 1.0 / (pplane->dist - DotProduct (modelorg, pplane->normal));
*
*        surface_p->d_zistepu = p_normal[0] * xscaleinv * distinv;
*        surface_p->d_zistepv = -p_normal[1] * yscaleinv * distinv;
*        surface_p->d_ziorigin = p_normal[2] * distinv -
*                        xcenter * surface_p->d_zistepu -
*                        ycenter * surface_p->d_zistepv;

		lea     _modelorg,a2            ;DotProduct (modelorg, pp...)
		fmul.s  (a2)+,fp3
		fmul.s  (a2)+,fp4
		fadd    fp4,fp3
		fmul.s  (a2)+,fp5
		fadd    fp5,fp3
		fsub.s  (a1)+,fp3
		fneg    fp3                     ;pplane->dist - DotProduct(...)
		fmove.s #1,fp5
		fdiv    fp3,fp5                 ;distinv = 1.0 / fp3
		fmove.s _xscaleinv,fp3
		fmul    fp5,fp3                 ;xscaleinv * distinv
		fmul    fp3,fp0                 ;p_normal[0] * fp3
		addq.l  #4,a0
		fmove.s fp0,(a0)+               ;surface_p->d_zistepu = fp0
		fmove.s _yscaleinv,fp4
		fmul    fp5,fp4                 ;yscaleinv * distinv
		fmul    fp4,fp1                 ;-p_normal[1] * fp4
		fmove.s fp1,(a0)+               ;surface_p->d_zistepv * fp1
		fmul.s  _xcenter,fp0            ;xcenter * fp0
		fmul.s  _ycenter,fp1            ;ycenter * fp1
		fmul    fp5,fp2                 ;p_normal[2] * distinv
		fsub    fp0,fp2                 ;- xcenter * fp0
		fsub    fp1,fp2                 ;- ycenter * fp1
		fmove.s fp2,-12(a0)             ;surface_p->d_ziorigin = fp2

*        surface_p++;

		add.l   #SURF_SIZEOF,_surface_p ;surface_p++
.end
		fmovem.x        (sp)+,fp2-fp6
		movem.l (sp)+,d2-d7/a2-a6
		rts
