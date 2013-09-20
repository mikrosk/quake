**
** Quake for AMIGA
** r_edge.c assembler implementations by Frank Wille <frank@phoenix.owl.de>
**

		INCLUDE	"quakedef68k.i"

		XREF    _r_bmodelactive
		XREF    _surfaces
		XREF    _span_p
		XREF    _current_iv
		XREF    _fv
		XREF    _edge_head
		XREF    _edge_tail
		XREF    _edge_aftertail
		XREF    _edge_head_u_shift20
		XREF    _R_CleanupSpan

		XDEF    _R_RemoveEdges
		XDEF    _R_InsertNewEdges
		XDEF    _R_StepActiveU
		XDEF    _R_GenerateSpans

;TODO: vasm limitation
; (1.0/(16*65536)) replaced with 0.000000954

		fpu

******************************************************************************
*
*       void _R_InsertNewEdges (edge_t *edgestoadd, edge_t *edgelist)
*
******************************************************************************

		cnop    0,4
_R_InsertNewEdges

*****   stackframe

		rsreset
.intregs        rs.l    1
		rs.l    1
.edgestoadd     rs.l    1
.edgelist       rs.l    1


*        do
*        {
*                next_edge = edgestoadd->next;
*edgesearch:
*                if (edgelist->u >= edgestoadd->u)
*                        goto addedge;
*                edgelist=edgelist->next;
*                if (edgelist->u >= edgestoadd->u)
*                        goto addedge;
*                edgelist=edgelist->next;
*                if (edgelist->u >= edgestoadd->u)
*                        goto addedge;
*                edgelist=edgelist->next;
*                if (edgelist->u >= edgestoadd->u)
*                        goto addedge;
*                edgelist=edgelist->next;
*                goto edgesearch;
*
*        // insert edgestoadd before edgelist
*addedge:
*                edgestoadd->next = edgelist;
*                edgestoadd->prev = edgelist->prev;
*                edgelist->prev->next = edgestoadd;
*                edgelist->prev = edgestoadd;
*        } while ((edgestoadd = next_edge) != NULL);

		move.l  a2,-(sp)
		move.l  .edgestoadd(sp),a0
		move.l  .edgelist(sp),a1
		move.l  EDGE_U(a0),d1
.loop
		cmp.l   EDGE_U(a1),d1           ;if (edgelist->u >= edgestoadd->u)
		ble.b   .addedge                ;goto addedge
		move.l  EDGE_NEXT(a1),a1        ;edgelist=edgelist->next
		cmp.l   EDGE_U(a1),d1
		ble.b   .addedge
		move.l  EDGE_NEXT(a1),a1
		cmp.l   EDGE_U(a1),d1
		ble.b   .addedge
		move.l  EDGE_NEXT(a1),a1
		cmp.l   EDGE_U(a1),d1
		ble.b   .addedge
		move.l  EDGE_NEXT(a1),a1
		bra.b   .loop
.addedge
		move.l  EDGE_NEXT(a0),d0        ;next_edge = edgestoadd->next
		move.l  a1,EDGE_NEXT(a0)        ;edgestoadd->next = edgelist
		move.l  EDGE_PREV(a1),a2
		move.l  a2,EDGE_PREV(a0)        ;edgestoadd->prev = edgelist->prev
		move.l  a0,EDGE_NEXT(a2)        ;edgelist->prev->next = edgestoadd
		move.l  a0,EDGE_PREV(a1)        ;edgelist->prev = edgestoadd
		tst.l   d0                      ;while ((edgestoadd = next_edge) != NULL)
		beq.b   .end
		move.l  d0,a0
		move.l  EDGE_U(a0),d1
		bra.b   .loop
.end
		move.l  (sp)+,a2
		rts






******************************************************************************
*
*       void _R_RemoveEdges (edge_t *pedge)
*
******************************************************************************

		cnop    0,4
_R_RemoveEdges

*****   stackframe

		rsreset
.intregs        rs.l    1
		rs.l    1
.pedge          rs.l    1


*        do
*        {
*                pedge->next->prev = pedge->prev;
*                pedge->prev->next = pedge->next;
*        } while ((pedge = pedge->nextremove) != NULL);

		move.l  a2,-(sp)
		move.l  .pedge(sp),a0
.loop
		move.l  EDGE_NEXT(a0),a1
		move.l  EDGE_PREV(a0),a2
		move.l  a2,EDGE_PREV(a1)        ;pedge->next->prev = pedge->prev
		move.l  a1,EDGE_NEXT(a2)        ;pedge->prev->next = pedge->next
		move.l  EDGE_NEXTREMOVE(a0),a0  ;while ((pedge = pedge->nextremove) != NULL)
		tst.l   a0
		bne.b   .loop
		move.l  (sp)+,a2
		rts








******************************************************************************
*
*       void _R_StepActiveU (edge_t *pedge)
*
******************************************************************************

		cnop    0,4
_R_StepActiveU

*****   stackframe

		rsreset
.intregs        rs.l    5
		rs.l    1
.pedge          rs.l    1


*nextedge:
*                pedge->u += pedge->u_step;
*                if (pedge->u < pedge->prev->u)
*                        goto pushback;
*                pedge = pedge->next;
*
*                pedge->u += pedge->u_step;
*                if (pedge->u < pedge->prev->u)
*                        goto pushback;
*                pedge = pedge->next;
*
*                pedge->u += pedge->u_step;
*                if (pedge->u < pedge->prev->u)
*                        goto pushback;
*                pedge = pedge->next;
*
*                pedge->u += pedge->u_step;
*                if (pedge->u < pedge->prev->u)
*                        goto pushback;
*                pedge = pedge->next;
*
*                goto nextedge;

		movem.l a2-a6,-(sp)
		move.l  .pedge(sp),a0
		move.l  EDGE_PREV(a0),a1
		move.l  EDGE_U(a1),d1
		lea     _edge_aftertail,a2
		lea     _edge_tail,a3
.loop
		move.l  EDGE_U(a0),d0
		add.l   EDGE_U_STEP(a0),d0
		move.l  d0,EDGE_U(a0)           ;pedge->u += pedge->u_step
		cmp.l   d1,d0                   ;if (pedge->u < pedge->prev->u)
		blt.b   .pushback               ;goto pushback
		move.l  d0,d1
		move.l  EDGE_NEXT(a0),a0        ;pedge = pedge->next
		move.l  EDGE_U(a0),d0
		add.l   EDGE_U_STEP(a0),d0
		move.l  d0,EDGE_U(a0)
		cmp.l   d1,d0
		blt.b   .pushback
		move.l  d0,d1
		move.l  EDGE_NEXT(a0),a0
		move.l  EDGE_U(a0),d0
		add.l   EDGE_U_STEP(a0),d0
		move.l  d0,EDGE_U(a0)
		cmp.l   d1,d0
		blt.b   .pushback
		move.l  d0,d1
		move.l  EDGE_NEXT(a0),a0
		move.l  EDGE_U(a0),d0
		add.l   EDGE_U_STEP(a0),d0
		move.l  d0,EDGE_U(a0)
		cmp.l   d1,d0
		blt.b   .pushback
		move.l  d0,d1
		move.l  EDGE_NEXT(a0),a0
		bra.b   .loop

*                if (pedge == &edge_aftertail)
*                        return;
*
*        // push it back to keep it sorted
*                pnext_edge = pedge->next;
*
*        // pull the edge out of the edge list
*                pedge->next->prev = pedge->prev;
*                pedge->prev->next = pedge->next;
*
*        // find out where the edge goes in the edge list
*                pwedge = pedge->prev->prev;
*
*                while (pwedge->u > pedge->u)
*                {
*                        pwedge = pwedge->prev;
*                }
*
*        // put the edge back into the edge list
*                pedge->next = pwedge->next;
*                pedge->prev = pwedge;
*                pedge->next->prev = pedge;
*                pwedge->next = pedge;
*
*                pedge = pnext_edge;
*                if (pedge == &edge_tail)
*                        return;

.pushback
		cmp.l   a0,a2                   ;if (pedge == &edge_aftertail)
		beq.w   .end                    ;return
		move.l  EDGE_NEXT(a0),a4        ;pnext_edge = pedge->next
		move.l  EDGE_PREV(a0),a5
		move.l  a5,EDGE_PREV(a4)        ;pedge->next->prev = pedge->prev
		move.l  a4,EDGE_NEXT(a5)        ;pedge->prev->next = pedge->next
		move.l  EDGE_PREV(a5),a5        ;pwedge = pedge->prev->prev
.loop2
		cmp.l   EDGE_U(a5),d0           ;while (pwedge->u > pedge->u)
		bgt.b   .cont
		move.l  EDGE_PREV(a5),a5        ;pwedge = pwedge->prev
		bra.b   .loop2
.cont
		move.l  EDGE_NEXT(a5),a1
		move.l  a1,EDGE_NEXT(a0)        ;pedge->next = pwedge->next
		move.l  a5,EDGE_PREV(a0)        ;pedge->prev = pwedge
		move.l  a0,EDGE_PREV(a1)        ;pedge->next->prev = pedge
		move.l  a0,EDGE_NEXT(a5)        ;pwedge->next = pedge
		move.l  a4,a0                   ;pedge = pnext_edge
		cmp.l   a3,a0                   ;if (pedge == &edge_tail)
		bne.b   .loop
.end
		movem.l (sp)+,a2-a6
		rts








******************************************************************************
*
*       void _R_GenerateSpans (void)
*
*       R_TrailingEdge and R_LeadingEdge are inlined
*
*       notes:
*       Increment and Decrement of _r_bmodelactive removed, because it's
*       obsolete here
*
******************************************************************************

		cnop    0,4
_R_GenerateSpans

******  prologue

		movem.l d2-d7/a2-a6,-(sp)
		fmovem.x        fp2-fp7,-(sp)
		clr.l   _r_bmodelactive
		move.l  _current_iv,d2
		move.l  _surfaces,a3
		lea     1*SURF_SIZEOF(a3),a4
		move.l  a4,SURF_NEXT(a4)
		move.l  a4,SURF_PREV(a4)
		move.l  _edge_head_u_shift20,SURF_LAST_U(a4)
		move.l  _edge_head+EDGE_NEXT,a5
		lea     _edge_tail,a6
		move.l  _span_p,a4
		bra.w   .try
.loop
		move.l  EDGE_U(a5),d4
		move.l  d4,d7
		moveq   #20,d0
		asr.l   d0,d4
		move.l  EDGE_SURFS(a5),d1
		move.l  d1,d0
		swap    d0
		ext.l   d0
		beq.b   .cont
		asl.l   #SURF_SIZEOF_EXP,d0
		lea     0(a3,d0.l),a0

******  R_TrailingEdge (inlined)

*        if (--surf->spanstate == 0)
*        {
*                if (surf->insubmodel)
*                        r_bmodelactive--;
*
*                if (surf == surfaces[1].next)
*                {
*                // emit a span (current top going away)
*                        iu = edge->u >> 20;
*                        if (iu > surf->last_u)
*                        {
*                                span = span_p++;
*                                span->u = surf->last_u;
*                                span->count = iu - span->u;
*                                span->v = current_iv;
*                                span->pnext = surf->spans;
*                                surf->spans = span;
*                        }
*
*                // set last_u on the surface below
*                        surf->next->last_u = iu;
*                }
*
*                surf->prev->next = surf->next;
*                surf->next->prev = surf->prev;
*        }

		subq.l  #1,SURF_SPANSTATE(a0)   ;if (--surf->spanstate) == 0
		bne.b   .cont
		move.l  SURF_NEXT(a0),a1
		cmp.l   1*SURF_SIZEOF+SURF_NEXT(a3),a0 ;if (surf==surfaces[1].next)
		bne.b   .te_cont2
		move.l  d4,d0                   ;iu = edge->u >> 20
		move.l  SURF_LAST_U(a0),d5
		move.l  d0,SURF_LAST_U(a1)      ;surf->next->last_u = iu
		sub.l   d5,d0                   ;if (iu > surf->last_u)
		ble.b   .te_cont2
		move.l  SURF_SPANS(a0),d3
		move.l  a4,SURF_SPANS(a0)       ;surf->spans = span
		move.l  d5,(a4)+                ;span->u = surf->last_u
		move.l  d2,(a4)+                ;span->v = current_iv
		move.l  d0,(a4)+                ;span->count = iu - span->u
		move.l  d3,(a4)+                ;span->pnext = surf->spans
.te_cont2
		move.l  SURF_PREV(a0),a2
		move.l  a1,SURF_NEXT(a2)        ;surf->prev->next = surf->next
		move.l  a2,SURF_PREV(a1)        ;surf->next->prev = surf->prev

******  end of R_TrailingEdge

.cont

******  R_LeadingEdge (inlined)

*        if (edge->surfs[1])
*        {
*        // it's adding a new surface in, so find the correct place
*                surf = &surfaces[edge->surfs[1]];
*
		ext.l   d1
		beq.w   .next
		asl.l   #SURF_SIZEOF_EXP,d1
		lea     0(a3,d1.l),a1           ;surf = &surfaces[edge->surfs[1]]
*
*        // don't start a span if this is an inverted span, with the end
*        // edge preceding the start edge (that is, we've already seen the
*        // end edge)
*                if (++surf->spanstate == 1)
*                {
*                        if (surf->insubmodel)
*                                r_bmodelactive++;
*
*                        surf2 = surfaces[1].next;
*
*                        if (surf->key < surf2->key)
*                                goto newtop;
*                // if it's two surfaces on the same plane, the one that's already
*                // active is in front, so keep going unless it's a bmodel
*                        if (surf->insubmodel && (surf->key == surf2->key))
*                        {


		move.l  SURF_SPANSTATE(a1),d0   ;if (++surf->spanstate == 1)
		beq.b   .le_zero
		addq.l  #1,SURF_SPANSTATE(a1)
		bra.w   .next
.le_zero
		addq.l  #1,d0
		move.l  d0,SURF_SPANSTATE(a1)
		move.l  SURF_INSUBMODEL(a1),d5  ;if (surf->insubmodel)
		move.l  1*SURF_SIZEOF+SURF_NEXT(a3),a0  ;surf2 = surfaces[1].next
		move.l  SURF_KEY(a1),d6
		moveq   #0,d3
		cmp.l   SURF_KEY(a0),d6         ;if (surf->key < surf2->key)
		blt.b   .le_newtop              ;goto newtop
		bgt.b   .le_search
		tst.b   d5
		beq.b   .le_search

		moveq   #-1,d3
		move.l  d7,d0
		sub.l   #$fffff,d0              ;edge->u - 0xFFFFF
		fmove.l d0,fp0                  ;(float)(edge->u - 0xFFFFF)
		;fmul.s  #(1.0/(16*65536)),fp0   ;fu = fp0 * (1 / $100000)
		fmul.s	#0.000000954,fp0
		fmove.s _fv,fp1                 ;fv
		fmove.s SURF_D_ZIORIGIN(a1),fp2
		fmove.s SURF_D_ZISTEPV(a1),fp3
		fmul    fp1,fp3                 ;fp1 = fv * surf->d_zistepv
		fadd    fp3,fp2
		fmove.s SURF_D_ZISTEPU(a1),fp3
		fmove   fp3,fp4                 ;fp4 = surf->d_zistepu
		fmul    fp0,fp3                 ;fp3 = fu * surf->d_zistepu
		fadd    fp3,fp2                 ;newzi = d_ziorigin + fp1 + fp3
		fmove   fp2,fp3
		fmul.s  #0.99,fp2               ;newzibottom = newzi * 0.99
		fmul.s  #1.01,fp3               ;newzitop = newzi * 1.01


*                        // must be two bmodels in the same leaf; sort on 1/z
*                                fu = (float)(edge->u - 0xFFFFF) * (1.0 / 0x100000);
*                                newzi = surf->d_ziorigin + fv*surf->d_zistepv +
*                                                fu*surf->d_zistepu;
*                                newzibottom = newzi * 0.99;
*
*                                testzi = surf2->d_ziorigin + fv*surf2->d_zistepv +
*                                                fu*surf2->d_zistepu;
*
*                                if (newzibottom >= testzi)
*                                {
*                                        goto newtop;
*                                }
*
*                                newzitop = newzi * 1.01;
*                                if (newzitop >= testzi)
*                                {
*                                        if (surf->d_zistepu >= surf2->d_zistepu)
*                                        {
*                                                goto newtop;
*                                        }
*                                }

		fmove.s SURF_D_ZIORIGIN(a0),fp5
		fmove.s SURF_D_ZISTEPV(a0),fp6
		fmul    fp1,fp6                 ;fp1 = fv * surf2->d_zistepv
		fadd    fp6,fp5
		fmove.s SURF_D_ZISTEPU(a0),fp6
		fmove   fp6,fp7
		fmul    fp0,fp6                 ;fp3 = fu * surf2->d_zistepu
		fadd    fp6,fp5                 ;testzi = d_ziorigin + fp1 + fp3
		fcmp    fp5,fp2                 ;if (newzibottom >= testzi)
		fbge.w  .le_newtop              ;goto newtop
		fcmp    fp5,fp3                 ;if (newzitop >= testzi)
		fblt.w  .le_search
		fcmp    fp7,fp4                 ;if (surf->d_zistepu >= surf2->d_zistepu)
		fbge.w  .le_newtop              ;goto newtop

*                        do
*                        {
*                                surf2 = surf2->next;
*                        } while (surf->key > surf2->key);
*


.le_search
		move.l  SURF_NEXT(a0),a0        ;surf2 = surf2->next
		cmp.l   SURF_KEY(a0),d6         ;while (surf->key > surf2->key)
		bgt.b   .le_search

*                        if (surf->key == surf2->key)
*                        {
*                        // if it's two surfaces on the same plane, the one that's already
*                        // active is in front, so keep going unless it's a bmodel
*                                if (!surf->insubmodel)
*                                        goto continue_search;

		bne.b   .le_gotposition
		tst.b   d5
		beq.b   .le_search
		tst     d3
		bne.b   .le_precalc_done
		moveq   #-1,d3
		move.l  d7,d0
		sub.l   #$fffff,d0              ;edge->u - 0xFFFFF
		fmove.l d0,fp0                  ;(float)(edge->u - 0xFFFFF)
		;fmul.s  #(1.0/(16*65536)),fp0   ;fu = fp0 * (1 / $100000)
		fmul.s	#0.000000954,fp0
		fmove.s _fv,fp1                 ;fv
		fmove.s SURF_D_ZIORIGIN(a1),fp2
		fmove.s SURF_D_ZISTEPV(a1),fp3
		fmul    fp1,fp3                 ;fp1 = fv * surf->d_zistepv
		fadd    fp3,fp2
		fmove.s SURF_D_ZISTEPU(a1),fp3
		fmove   fp3,fp4                 ;fp4 = surf->d_zistepu
		fmul    fp0,fp3                 ;fp3 = fu * surf->d_zistepu
		fadd    fp3,fp2                 ;newzi = d_ziorigin + fp1 + fp3
		fmove   fp2,fp3
		fmul.s  #0.99,fp2               ;newzibottom = newzi * 0.99
		fmul.s  #1.01,fp3               ;newzitop = newzi * 1.01
.le_precalc_done

*                        // must be two bmodels in the same leaf; sort on 1/z
*                                fu = (float)(edge->u - 0xFFFFF) * (1.0 / 0x100000);
*                                newzi = surf->d_ziorigin + fv*surf->d_zistepv +
*                                                fu*surf->d_zistepu;
*                                newzibottom = newzi * 0.99;
*
*                                testzi = surf2->d_ziorigin + fv*surf2->d_zistepv +
*                                                fu*surf2->d_zistepu;
*
*                                if (newzibottom >= testzi)
*                                {
*                                        goto gotposition;
*                                }
*
*                                newzitop = newzi * 1.01;
*                                if (newzitop >= testzi)
*                                {
*                                        if (surf->d_zistepu >= surf2->d_zistepu)
*                                        {
*                                                goto gotposition;
*                                        }
*                                }
*
*                                goto continue_search;
*                        }
*
*                        goto gotposition;

		fmove.s SURF_D_ZIORIGIN(a0),fp5
		fmove.s SURF_D_ZISTEPV(a0),fp6
		fmul    fp1,fp6                 ;fp1 = fv * surf2->d_zistepv
		fadd    fp6,fp5
		fmove.s SURF_D_ZISTEPU(a0),fp6
		fmove   fp6,fp7
		fmul    fp0,fp6                 ;fp3 = fu * surf2->d_zistepu
		fadd    fp6,fp5                 ;testzi = d_ziorigin + fp1 + fp3
		fcmp    fp5,fp2                 ;if (newzibottom >= testzi)
		fbge.w  .le_gotposition         ;goto gotposition
		fcmp    fp5,fp3                 ;if (newzitop >= testzi)
		fblt.w  .le_search
		fcmp    fp7,fp4                 ;if (surf->d_zistepu >= surf2->d_zistepu)
		fbge.w  .le_gotposition         ;goto gotposition
		bra.b   .le_search

*                // emit a span (obscures current top)
*                        iu = edge->u >> 20;
*
*                        if (iu > surf2->last_u)
*                        {
*                                span = span_p++;
*                                span->u = surf2->last_u;
*                                span->count = iu - span->u;
*                                span->v = current_iv;
*                                span->pnext = surf2->spans;
*                                surf2->spans = span;
*                        }
*
*                        // set last_u on the new span
*                        surf->last_u = iu;

.le_newtop
		move.l  SURF_LAST_U(a0),d5
		move.l  d4,SURF_LAST_U(a1)      ;surf->last_u = iu
		sub.l   d5,d4                   ;if (iu > surf2->last_u)
		ble.b   .le_cont2
		move.l  SURF_SPANS(a0),d3
		move.l  a4,SURF_SPANS(a0)       ;surf2->spans = span
		move.l  d5,(a4)+                ;span->u = surf2->last_u
		move.l  d2,(a4)+                ;span->v = current_iv
		move.l  d4,(a4)+                ;span->count = iu - span->u
		move.l  d3,(a4)+                ;span->pnext = surf2->spans
.le_cont2

*                // insert before surf2
*                        surf->next = surf2;
*                        surf->prev = surf2->prev;
*                        surf2->prev->next = surf;
*                        surf2->prev = surf;

.le_gotposition
		move.l  SURF_PREV(a0),a2
		move.l  a2,SURF_PREV(a1)        ;surf->prev = surf2->prev
		move.l  a0,SURF_NEXT(a1)        ;surf->next = surf2
		move.l  a1,SURF_NEXT(a2)        ;surf2->prev->next = surf
		move.l  a1,SURF_PREV(a0)        ;surf2->prev = surf

******  end of R_LeadingEdge

.next
		move.l  EDGE_NEXT(a5),a5
.try
		cmp.l   a5,a6
		bne.b   .loop
		move.l  a4,_span_p
		jsr     _R_CleanupSpan
		fmovem.x        (sp)+,fp2-fp7
		movem.l (sp)+,d2-d7/a2-a6
		rts
