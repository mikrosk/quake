**
** Quake for AMIGA
** d_edge.c assembler implementations by Frank Wille <frank@phoenix.owl.de>
**

		INCLUDE	"quakedef68k.i"

		XREF    _vright
		XREF    _vup
		XREF    _vpn
		XREF    _xscaleinv
		XREF    _yscaleinv
		XREF    _xcenter
		XREF    _ycenter
		XREF    _d_zistepu
		XREF    _d_zistepv
		XREF    _d_ziorigin
		XREF    _d_sdivzstepu
		XREF    _d_tdivzstepu
		XREF    _d_sdivzstepv
		XREF    _d_tdivzstepv
		XREF    _d_sdivzorigin
		XREF    _d_tdivzorigin
		XREF    _sadjust
		XREF    _tadjust
		XREF    _bbextents
		XREF    _bbextentt
		XREF    _transformed_modelorg
		XREF    _miplevel
		XREF    _cl_entities
		XREF    _currententity
		XREF    _r_drawflat
		XREF    _surfaces
		XREF    _surface_p
		XREF    _r_drawnpolycount
		XREF    _r_skymade
		XREF    _r_clearcolor
		XREF    _cacheblock
		XREF    _cachewidth
		XREF    _r_origin
		XREF    _base_vpn
		XREF    _base_vup
		XREF    _base_vright
		XREF	_base_modelorg
		XREF    _d_drawspans
		XREF    _scale_for_mip
		XREF    _d_scalemip
		XREF    _d_minmip
		XREF    _modelorg
		XREF    _screenedge
		XREF    _view_clipplanes

		XREF    _D_DrawSolidSurface
		XREF    _D_DrawZSpans
		XREF    _R_MakeSky
		XREF    _D_DrawSkyScans8
		XREF    _D_DrawZSpans
		XREF    _Turbulent8
		XREF    _R_RotateBmodel
		XREF    _D_CacheSurface

		XDEF    _D_CalcGradients
		XDEF    _D_DrawSurfaces

SURF_DRAWSKY            =       4
SURF_DRAWTURB           =       $10
SURF_DRAWBACKGROUND     =       $40



		fpu

******************************************************************************
*
*       void _D_CalcGradients (msurface_t *pface)
*
******************************************************************************

		cnop    0,4
_D_CalcGradients

*****   stackframe

		rsreset
.fpuregs        rs.x    6
.intregs        rs.l    4
		rs.l    1
.pface          rs.l    1


		movem.l d2/d3/a2/a3,-(sp)
		fmovem.x        fp2-fp7,-(sp)
		move.l  .pface(sp),a0
		move.l  MSURFACE_TEXINFO(a0),a2
		lea     16(a2),a3
		lea     _vright,a1
		fmove.s (a1)+,fp0
		fmove.s (a1)+,fp1
		fmove.s (a1)+,fp2
		fmove.s (a2)+,fp3
		fmul    fp0,fp3
		fmove.s (a2)+,fp4
		fmul    fp1,fp4
		fadd    fp4,fp3
		fmove.s (a2)+,fp4
		fmul    fp2,fp4
		fadd    fp4,fp3                 ;fp3 = p_saxis[0]
		fmove.s (a3)+,fp4
		fmul    fp0,fp4
		fmove.s (a3)+,fp5
		fmul    fp1,fp5
		fadd    fp5,fp4
		fmove.s (a3)+,fp5
		fmul    fp2,fp5
		fadd    fp5,fp4                 ;fp4 = p_taxis[0]
		sub     #12,a2
		sub     #12,a3
		lea     _vup,a1
		fmove.s (a1)+,fp0
		fmove.s (a1)+,fp1
		fmove.s (a1)+,fp2
		fmove.s (a2)+,fp5
		fmul    fp0,fp5
		fmove.s (a2)+,fp6
		fmul    fp1,fp6
		fadd    fp6,fp5
		fmove.s (a2)+,fp6
		fmul    fp2,fp6
		fadd    fp6,fp5                 ;fp5 = p_saxis[1]
		fmove.s (a3)+,fp6
		fmul    fp0,fp6
		fmove.s (a3)+,fp7
		fmul    fp1,fp7
		fadd    fp7,fp6
		fmove.s (a3)+,fp7
		fmul    fp2,fp7
		fadd    fp7,fp6                 ;fp6 = p_taxis[1]
		sub     #12,a2
		sub     #12,a3

		moveq   #1,d0
		move.l  _miplevel,d1            ;d1 = miplevel
		asl.l   d1,d0
		fmove.l d0,fp1
		fmove.s #1,fp0
		fdiv    fp1,fp0                 ;fp0 = mipscale
		fmove.s fp0,-(sp)

		fmove.s _xscaleinv,fp1
		fmul    fp0,fp1                 ;fp1 = t = xscaleinv * mipscale
		fmove   fp3,fp2
		fmul    fp1,fp2                 ;fp2 = d_sdivzstepu
		fmove.s fp2,_d_sdivzstepu
		fmul    fp4,fp1                 ;fp1 = d_tdivzstepu
		fmove.s fp1,_d_tdivzstepu
		fmove.s _xcenter,fp7
		fmul    fp7,fp2
		fmul    fp7,fp1

		fmove.s _yscaleinv,fp7
		fmul    fp0,fp7                 ;fp7 = t = yscaleinv * mipscale
		fmove   fp5,fp0
		fmul    fp7,fp0                 ;fp0 = d_sdivzstepv
		fneg    fp0
		fmove.s fp0,_d_sdivzstepv
		fmul.s  _ycenter,fp0
		fmul    fp6,fp7                 ;fp7 = d_tdivzstepv
		fneg    fp7
		fmove.s fp7,_d_tdivzstepv
		fmul.s  _ycenter,fp7

		fadd    fp0,fp2
		fadd    fp1,fp7

		lea     _vpn,a1
		fmove.s (a2)+,fp0
		fmul.s  (a1),fp0
		fmove.s (a2)+,fp1
		fmul.s  4(a1),fp1
		fadd    fp1,fp0
		fmove.s (a2)+,fp1
		fmul.s  8(a1),fp1
		fadd    fp1,fp0
		fmove   fp0,fp1                 ;fp0 = p_saxis[2]
		fmul.s  (sp),fp1                ;mipscale * p_saxis[2]
		fsub    fp2,fp1                 ;- fp2
		fmove.s fp1,_d_sdivzorigin

		fmove.s (a3)+,fp1
		fmul.s  (a1)+,fp1
		fmove.s (a3)+,fp2
		fmul.s  (a1)+,fp2
		fadd    fp2,fp1
		fmove.s (a3)+,fp2
		fmul.s  (a1)+,fp2
		fadd    fp2,fp1
		fmove   fp1,fp2                 ;fp1 = p_taxis[2]
		fmul.s  (sp),fp2                ;mipscale * p_taxis[2]
		fsub    fp7,fp2                 ;- fp7
		fmove.s fp2,_d_tdivzorigin

		lea     _transformed_modelorg,a1
		fmove.s (a1)+,fp7
		fmul    fp7,fp3
		fmove.s (a1)+,fp2
		fmul    fp2,fp5
		fadd    fp5,fp3
		fmove.s (a1)+,fp5
		fmul    fp5,fp0
		fadd    fp0,fp3
		fmul    fp7,fp4
		fmul    fp2,fp6
		fadd    fp6,fp4
		fmul    fp5,fp1
		fadd    fp1,fp4

		fmove.s (sp)+,fp7               ;fp7 = mipscale
		fmul    fp7,fp3
		fmul    fp7,fp4
		fmove.s #65536,fp0
		fmove.s #0.5,fp1
		fmul    fp0,fp7
		move.l  MSURFACE_TEXINFO(a0),a1

		fmul    fp0,fp3
		fadd    fp1,fp3
		fmove.l fp3,d0
		fmove.s 12(a1),fp2
		fmul    fp7,fp2
		fmove.l fp2,d2
		move    MSURFACE_TEXTUREMINS(a0),d3
		swap    d3
		clr     d3
		asr.l   d1,d3
		sub.l   d2,d3
		sub.l   d3,d0
		move.l  d0,_sadjust

		fmul    fp0,fp4
		fadd    fp1,fp4
		fmove.l fp4,d0
		fmove.s 12+16(a1),fp2
		fmul    fp7,fp2
		fmove.l fp2,d2
		move    MSURFACE_TEXTUREMINS+2(a0),d3
		swap    d3
		clr     d3
		asr.l   d1,d3
		sub.l   d2,d3
		sub.l   d3,d0
		move.l  d0,_tadjust

		move    MSURFACE_EXTENTS(a0),d0
		swap    d0
		clr     d0
		asr.l   d1,d0
		subq.l  #1,d0
		move.l  d0,_bbextents
		move    MSURFACE_EXTENTS+2(a0),d0
		swap    d0
		clr     d0
		asr.l   d1,d0
		subq.l  #1,d0
		move.l  d0,_bbextentt

		fmovem.x        (sp)+,fp2-fp7
		movem.l (sp)+,d2/d3/a2/a3
		rts









******************************************************************************
*
*       void _D_DrawSurfaces (void)
*
******************************************************************************

		cnop    0,4
_D_DrawSurfaces


		movem.l d2/a2-a4,-(sp)
		fmovem.x        fp2-fp7,-(sp)

*        currententity = &cl_entities[0];
*        TransformVector (modelorg, transformed_modelorg);
*        VectorCopy (transformed_modelorg, world_transformed_modelorg);

		move.l  #_cl_entities,_currententity

******  TransformVector (inlined)

		lea     _modelorg,a0
		lea     _transformed_modelorg,a1
		fmove.s (a0)+,fp0
		fmove.s (a0)+,fp1
		fmove.s (a0)+,fp2
		lea     _vright,a2
		fmove.s (a2)+,fp3
		fmul    fp0,fp3
		fmove.s (a2)+,fp4
		fmul    fp1,fp4
		fadd    fp4,fp3
		fmove.s (a2)+,fp4
		fmul    fp2,fp4
		fadd    fp4,fp3
		fmove.s fp3,(a1)+               ;fp3 = world_tr... [0]
		lea     _vup,a2
		fmove.s (a2)+,fp4
		fmul    fp0,fp4
		fmove.s (a2)+,fp5
		fmul    fp1,fp5
		fadd    fp5,fp4
		fmove.s (a2)+,fp5
		fmul    fp2,fp5
		fadd    fp5,fp4
		fmove.s fp4,(a1)+               ;fp4 = world_tr... [1]
		lea     _vpn,a2
		fmove.s (a2)+,fp5
		fmul    fp0,fp5
		fmove.s (a2)+,fp6
		fmul    fp1,fp6
		fadd    fp6,fp5
		fmove.s (a2)+,fp6
		fmul    fp2,fp6
		fadd    fp6,fp5
		fmove.s fp5,(a1)+               ;fp5 = world_tr... [2]

******  end of TransformVector

*        if (r_drawflat.value)
*        {
*                for (s = &surfaces[1] ; s<surface_p ; s++)

		fmove.s _r_drawflat+CVAR_VALUE,fp0
		ftst    fp0
		fbeq    .notflat
		move.l  _surfaces,a2
		lea     SURF_SIZEOF(a2),a2
		move.l  _surface_p,d2
.loop
		cmp.l   d2,a2
		bge.w   .end

*                        if (!s->spans)
*                                continue;

		tst.l   SURF_SPANS(a2)
		beq.b   .next

*                        d_zistepu = s->d_zistepu;
*                        d_zistepv = s->d_zistepv;
*                        d_ziorigin = s->d_ziorigin;
*
*                        D_DrawSolidSurface (s, (long)s->data & 0xFF);
*                        D_DrawZSpans (s->spans);

		move.l  SURF_D_ZISTEPU(a2),_d_zistepu
		move.l  SURF_D_ZISTEPV(a2),_d_zistepv
		move.l  SURF_D_ZIORIGIN(a2),_d_ziorigin
		move.l  SURF_DATA(a2),d0
		and.l   #$ff,d0
		move.l  d0,-(sp)
		move.l  a2,-(sp)
		jsr     _D_DrawSolidSurface
		addq    #8,sp
		move.l  SURF_SPANS(a2),-(sp)
		jsr     _D_DrawZSpans
		addq    #4,sp
.next
		lea     SURF_SIZEOF(a2),a2
		bra.b   .loop
.notflat
		move.l  _surfaces,a2
		lea     SURF_SIZEOF(a2),a2
		move.l  _surface_p,d2

*                for (s = &surfaces[1] ; s<surface_p ; s++)
*                {
*                        if (!s->spans)
*                                continue;

.loop2
		cmp.l   d2,a2
		bge.w   .end
		tst.l   SURF_SPANS(a2)
		beq.b   .next2

*                        r_drawnpolycount++;
*
*                        d_zistepu = s->d_zistepu;
*                        d_zistepv = s->d_zistepv;
*                        d_ziorigin = s->d_ziorigin;

		addq.l  #1,_r_drawnpolycount
		move.l  SURF_D_ZISTEPU(a2),_d_zistepu
		move.l  SURF_D_ZISTEPV(a2),_d_zistepv
		move.l  SURF_D_ZIORIGIN(a2),_d_ziorigin

*                        if (s->flags & SURF_DRAWSKY)
*                        {
*                                if (!r_skymade)
*                                {
*                                        R_MakeSky ();
*                                }
*
*                                D_DrawSkyScans8 (s->spans);
*                                D_DrawZSpans (s->spans);
*                        }

		move.l  SURF_FLAGS(a2),d0
		move.l  d0,d1
		and.l   #SURF_DRAWSKY,d1
		beq.b   .nosky
		tst.l   _r_skymade
		bne.b   .skymade
		jsr     _R_MakeSky
.skymade
		move.l  SURF_SPANS(a2),-(sp)
		jsr     _D_DrawSkyScans8
		jsr     _D_DrawZSpans
		addq    #4,sp
		bra.w   .next2

*                        else if (s->flags & SURF_DRAWBACKGROUND)
*                        {
*                        // set up a gradient for the background surface that places it
*                        // effectively at infinity distance from the viewpoint
*                                d_zistepu = 0;
*                                d_zistepv = 0;
*                                d_ziorigin = -0.9;
*
*                                D_DrawSolidSurface (s, (int)r_clearcolor.value & 0xFF);
*                                D_DrawZSpans (s->spans);
*                        }

.nosky
		move.l  d0,d1
		and.l   #SURF_DRAWBACKGROUND,d1
		beq.b   .nobackground
		fmove.s #0,fp0
		fmove.s fp0,_d_zistepu
		fmove.s fp0,_d_zistepv
		fmove.s #-0.9,fp0
		fmove.s fp0,_d_ziorigin
		fmove.s _r_clearcolor+CVAR_VALUE,fp0
		fmove.l fp0,d0
		and.l   #$ff,d0
		move.l  d0,-(sp)
		move.l  a2,-(sp)
		jsr     _D_DrawSolidSurface
		addq    #8,sp
		move.l  SURF_SPANS(a2),-(sp)
		jsr     _D_DrawZSpans
		addq    #4,sp
		bra.w   .next2

*                        else if (s->flags & SURF_DRAWTURB)
*                        {
*                                pface = s->data;
*                                miplevel = 0;
*                                cacheblock = (pixel_t *)
*                                                ((byte *)pface->texinfo->texture +
*                                                pface->texinfo->texture->offsets[0]);
*                                cachewidth = 64;

.nobackground
		move.l  d0,d1
		and.l   #SURF_DRAWTURB,d1
		beq.w   .noturb
		move.l  SURF_DATA(a2),a3
		clr.l   _miplevel
		move.l  MSURFACE_TEXINFO(a3),a0
		move.l  MTEXINFO_TEXTURE(a0),a0
		add.l   TEXTURE_OFFSETS(a0),a0
		move.l  a0,_cacheblock
		move.l  #64,_cachewidth

*                                if (s->insubmodel)
*                                {
*                                // FIXME: we don't want to do all this for every polygon!
*                                // TODO: store once at start of frame
*                                        currententity = s->entity;      //FIXME: make this passed in to
*                                                                                                // R_RotateBmodel ()
*                                        VectorSubtract (r_origin, currententity->origin,
*                                                        local_modelorg);
*                                        TransformVector (local_modelorg, transformed_modelorg);
*
*                                        R_RotateBmodel ();      // FIXME: don't mess with the frustum,
*                                                                                // make entity passed in
*                                }

		tst.l   SURF_INSUBMODEL(a2)
		beq.b   .nosub
		move.l  SURF_ENTITY(a2),a0
		move.l  a0,_currententity
		lea     ENTITY_ORIGIN(a0),a0

******  VectorSubtract (inlined)

		lea     _r_origin,a1
		lea     _transformed_modelorg,a4
		fmove.s (a1)+,fp0
		fsub.s  (a0)+,fp0
		fmove.s (a1)+,fp1
		fsub.s  (a0)+,fp1
		fmove.s (a1)+,fp2
		fsub.s  (a0)+,fp2

******  end of VectorSubtract (inlined)

******  TransformVector (inlined)

		lea     _vright,a0
		fmove.s (a0)+,fp6
		fmul    fp0,fp6
		fmove.s (a0)+,fp7
		fmul    fp1,fp7
		fadd    fp7,fp6
		fmove.s (a0)+,fp7
		fmul    fp2,fp7
		fadd    fp7,fp6
		fmove.s fp6,(a4)+
		lea     _vup,a0
		fmove.s (a0)+,fp6
		fmul    fp0,fp6
		fmove.s (a0)+,fp7
		fmul    fp1,fp7
		fadd    fp7,fp6
		fmove.s (a0)+,fp7
		fmul    fp2,fp7
		fadd    fp7,fp6
		fmove.s fp6,(a4)+
		lea     _vpn,a0
		fmul.s  (a0)+,fp0
		fmul.s  (a0)+,fp1
		fadd    fp1,fp0
		fmul.s  (a0)+,fp2
		fadd    fp2,fp0
		fmove.s fp0,(a4)+
		lea     -12(a4),a4

****** end of TransformVector

		jsr     _R_RotateBmodel

*                                D_CalcGradients (pface);
*                                Turbulent8 (s->spans);
*                                D_DrawZSpans (s->spans);

.nosub
		move.l  a3,-(sp)
		jsr     _D_CalcGradients
		addq    #4,sp
		move.l  SURF_SPANS(a2),-(sp)
		jsr     _Turbulent8
		jsr     _D_DrawZSpans
		addq    #4,sp

*                                if (s->insubmodel)
*                                {
*                                //
*                                // restore the old drawing state
*                                // FIXME: we don't want to do this every time!
*                                // TODO: speed up
*                                //
*                                        currententity = &cl_entities[0];
*                                        VectorCopy (world_transformed_modelorg,
*                                                                transformed_modelorg);
*                                        VectorCopy (base_vpn, vpn);
*                                        VectorCopy (base_vup, vup);
*                                        VectorCopy (base_vright, vright);
*                                        VectorCopy (base_modelorg, modelorg);
*                                        R_TransformFrustum ();
*                                }

		tst.l   SURF_INSUBMODEL(a2)
		beq.w   .next2
		move.l  #_cl_entities,_currententity
		fmove.s fp3,(a4)+
		fmove.s fp4,(a4)+
		fmove.s fp5,(a4)+
		lea     _base_vpn,a0
		lea     _vpn,a1
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		lea     _base_vup,a0
		lea     _vup,a1
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		lea     _base_vright,a0
		lea     _vright,a1
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		lea	_base_modelorg,a0
		lea	_modelorg,a1
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		fmove.s fp3,-(sp)
		fmove.s fp4,-(sp)
		fmove.s fp5,-(sp)

****** R_TransformFrustum (inlined)

		moveq   #4-1,d0
		lea     _screenedge,a0
		lea     _view_clipplanes,a1
		lea     _modelorg,a4
		fmove.s (a4)+,fp7
.loop3
		fmove.s (a0)+,fp1
		fneg    fp1
		fmove.s (a0)+,fp2
		fmove.s (a0)+,fp0
		lea     _vright,a3
		fmove.s (a3)+,fp3
		fmove.s (a3)+,fp4
		fmove.s (a3)+,fp5
		fmul    fp1,fp3
		fmul    fp1,fp4
		fmul    fp1,fp5
		lea     _vup,a3
		fmove.s (a3)+,fp6
		fmul    fp2,fp6
		fadd    fp6,fp3
		fmove.s (a3)+,fp6
		fmul    fp2,fp6
		fadd    fp6,fp4
		fmove.s (a3)+,fp6
		fmul    fp2,fp6
		fadd    fp6,fp5
		lea     _vpn,a3
		fmove.s (a3)+,fp6
		fmul    fp0,fp6
		fadd    fp6,fp3
		fmove.s fp3,(a1)+
		fmove.s (a3)+,fp6
		fmul    fp0,fp6
		fadd    fp6,fp4
		fmove.s fp4,(a1)+
		fmove.s (a3)+,fp6
		fmul    fp0,fp6
		fadd    fp6,fp5
		fmove.s fp5,(a1)+

		fmul    fp7,fp3
		fmul.s  (a4),fp4
		fadd    fp4,fp3
		fmul.s  4(a4),fp5
		fadd    fp5,fp3
		fmove.s fp3,(a1)+
		lea     CLIP_SIZEOF-16(a1),a1
		lea     MPLANE_SIZEOF-12(a0),a0
		dbra    d0,.loop3

******  end of R_TransformFrustum

		fmove.s (sp)+,fp5
		fmove.s (sp)+,fp4
		fmove.s (sp)+,fp3
		bra.w   .next2
.noturb

*                                if (s->insubmodel)
*                                {
*                                // FIXME: we don't want to do all this for every polygon!
*                                // TODO: store once at start of frame
*                                        currententity = s->entity;      //FIXME: make this passed in to
*                                                                                                // R_RotateBmodel ()
*                                        VectorSubtract (r_origin, currententity->origin, local_modelorg);
*                                        TransformVector (local_modelorg, transformed_modelorg);
*
*                                        R_RotateBmodel ();      // FIXME: don't mess with the frustum,
*                                                                                // make entity passed in
*                                }

		tst.l   SURF_INSUBMODEL(a2)
		beq.b   .nosub2
		move.l  SURF_ENTITY(a2),a0
		move.l  a0,_currententity
		lea     ENTITY_ORIGIN(a0),a0

****** VectorSubtract (inlined)

		lea     _r_origin,a1
		lea     _transformed_modelorg,a4
		fmove.s (a1)+,fp0
		fsub.s  (a0)+,fp0
		fmove.s (a1)+,fp1
		fsub.s  (a0)+,fp1
		fmove.s (a1)+,fp2
		fsub.s  (a0)+,fp2

****** end of VectorSubtract

****** TransformVector (inlined)

		lea     _vright,a0
		fmove.s (a0)+,fp6
		fmul    fp0,fp6
		fmove.s (a0)+,fp7
		fmul    fp1,fp7
		fadd    fp7,fp6
		fmove.s (a0)+,fp7
		fmul    fp2,fp7
		fadd    fp7,fp6
		fmove.s fp6,(a4)+
		lea     _vup,a0
		fmove.s (a0)+,fp6
		fmul    fp0,fp6
		fmove.s (a0)+,fp7
		fmul    fp1,fp7
		fadd    fp7,fp6
		fmove.s (a0)+,fp7
		fmul    fp2,fp7
		fadd    fp7,fp6
		fmove.s fp6,(a4)+
		lea     _vpn,a0
		fmul.s  (a0)+,fp0
		fmul.s  (a0)+,fp1
		fadd    fp1,fp0
		fmul.s  (a0)+,fp2
		fadd    fp2,fp0
		fmove.s fp0,(a4)+
		lea     -12(a4),a4

******  end of TransformVector

		jsr     _R_RotateBmodel
.nosub2

*                                pface = s->data;
*                                miplevel = D_MipLevelForScale (s->nearzi * scale_for_mip
*                                * pface->texinfo->mipadjust);
*
*                        // FIXME: make this passed in to D_CacheSurface
*                                pcurrentcache = D_CacheSurface (pface, miplevel);
*
*                                cacheblock = (pixel_t *)pcurrentcache->data;
*                                cachewidth = pcurrentcache->width;

		move.l  SURF_DATA(a2),a3
		fmove.s SURF_NEARZI(a2),fp0
		fmul.s  _scale_for_mip,fp0
		move.l  MSURFACE_TEXINFO(a3),a0
		fmul.s  MTEXINFO_MIPADJUST(a0),fp0

******  D_MipLevelForScale (inlined)
		lea     _d_scalemip,a1
		moveq   #0,d0
		fcmp.s  (a1),fp0
		fboge.w .found
		moveq   #1,d0
		fcmp.s  4(a1),fp0
		fboge.w .found
		moveq   #2,d0
		fcmp.s  8(a1),fp0
		fboge.w .found
		moveq   #3,d0
.found		move.l  _d_minmip,d1
		cmp.l   d1,d0
		bge.b   .miplevok
		move.l  d1,d0
.miplevok
******  end of D_MipLevelForScale

		move.l  d0,_miplevel
		move.l  d0,-(sp)
		move.l  a3,-(sp)
		jsr     _D_CacheSurface
		addq    #8,sp
		move.l  d0,a0
		lea     SURFCACHE_DATA(a0),a1
		move.l  a1,_cacheblock
		move.l  SURFCACHE_WIDTH(a0),_cachewidth

*                                D_CalcGradients (pface);
*
*                                (*d_drawspans) (s->spans);
*
*                                D_DrawZSpans (s->spans);

		move.l  a3,-(sp)
		jsr     _D_CalcGradients
		addq    #4,sp
		move.l  SURF_SPANS(a2),-(sp)
		move.l  _d_drawspans,a0
		jsr     (a0)
		jsr     _D_DrawZSpans
		addq    #4,sp

*                                if (s->insubmodel)
*                                {
*                                //
*                                // restore the old drawing state
*                                // FIXME: we don't want to do this every time!
*                                // TODO: speed up
*                                //
*                                        currententity = &cl_entities[0];
*                                        VectorCopy (world_transformed_modelorg,
*                                                                transformed_modelorg);
*                                        VectorCopy (base_vpn, vpn);
*                                        VectorCopy (base_vup, vup);
*                                        VectorCopy (base_vright, vright);
*                                        VectorCopy (base_modelorg, modelorg);
*                                        R_TransformFrustum ();
*                                }

		tst.l   SURF_INSUBMODEL(a2)
		beq.w   .next2
		move.l  #_cl_entities,_currententity
		fmove.s fp3,(a4)+
		fmove.s fp4,(a4)+
		fmove.s fp5,(a4)+
		lea     _base_vpn,a0
		lea     _vpn,a1
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		lea     _base_vup,a0
		lea     _vup,a1
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		lea     _base_vright,a0
		lea     _vright,a1
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		lea	_base_modelorg,a0
		lea	_modelorg,a1
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		move.l  (a0)+,(a1)+
		fmove.s fp3,-(sp)
		fmove.s fp4,-(sp)
		fmove.s fp5,-(sp)

****** R_TransformFrustum (inlined)

		moveq   #4-1,d0
		lea     _screenedge,a0
		lea     _view_clipplanes,a1
		lea     _modelorg,a4
		fmove.s (a4)+,fp7
.loop4
		fmove.s (a0)+,fp1
		fneg    fp1
		fmove.s (a0)+,fp2
		fmove.s (a0)+,fp0
		lea     _vright,a3
		fmove.s (a3)+,fp3
		fmove.s (a3)+,fp4
		fmove.s (a3)+,fp5
		fmul    fp1,fp3
		fmul    fp1,fp4
		fmul    fp1,fp5
		lea     _vup,a3
		fmove.s (a3)+,fp6
		fmul    fp2,fp6
		fadd    fp6,fp3
		fmove.s (a3)+,fp6
		fmul    fp2,fp6
		fadd    fp6,fp4
		fmove.s (a3)+,fp6
		fmul    fp2,fp6
		fadd    fp6,fp5
		lea     _vpn,a3
		fmove.s (a3)+,fp6
		fmul    fp0,fp6
		fadd    fp6,fp3
		fmove.s fp3,(a1)+
		fmove.s (a3)+,fp6
		fmul    fp0,fp6
		fadd    fp6,fp4
		fmove.s fp4,(a1)+
		fmove.s (a3)+,fp6
		fmul    fp0,fp6
		fadd    fp6,fp5
		fmove.s fp5,(a1)+

		fmul    fp7,fp3
		fmul.s  (a4),fp4
		fadd    fp4,fp3
		fmul.s  4(a4),fp5
		fadd    fp5,fp3
		fmove.s fp3,(a1)+
		lea     CLIP_SIZEOF-16(a1),a1
		lea     MPLANE_SIZEOF-12(a0),a0
		dbra    d0,.loop4

******  end of R_TransformFrustum

		fmove.s (sp)+,fp5
		fmove.s (sp)+,fp4
		fmove.s (sp)+,fp3
.next2
		lea     SURF_SIZEOF(a2),a2
		bra.w   .loop2
.end
		fmovem.x        (sp)+,fp2-fp7
		movem.l (sp)+,d2/a2-a4
		rts
