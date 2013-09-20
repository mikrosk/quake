**
** Quake for AMIGA
** r_aclip.c assembler implementations by Frank Wille <frank@phoenix.owl.de>
**

		INCLUDE	"quakedef68k.i"

		XREF    _r_refdef

		XDEF    _R_Alias_clip_left
		XDEF    _R_Alias_clip_right
		XDEF    _R_Alias_clip_top
		XDEF    _R_Alias_clip_bottom
		XDEF    _R_AliasClip

ALIAS_LEFT_CLIP         =       1
ALIAS_TOP_CLIP          =       2
ALIAS_RIGHT_CLIP        =       4
ALIAS_BOTTOM_CLIP       =       8



		fpu

******************************************************************************
*
*       void _R_Alias_clip_left (finalvert_t *pfv0, finalvert_t *pfv1,
*                                finalvert_t *out)
*
******************************************************************************

		cnop    0,4
_R_Alias_clip_left

*****   stackframe

		rsreset
.fpuregs        rs.x    2
.intregs        rs.l    5
		rs.l    1
.pfv0           rs.l    1
.pfv1           rs.l    1
.out            rs.l    1


		movem.l d2-d4/a2/a3,-(sp)
		fmovem.x        fp2/fp3,-(sp)
		move.l  .pfv0(sp),a0
		move.l  .pfv1(sp),a1
		move.l  .out(sp),a2
		lea     _r_refdef,a3
		fmove.s #0.5,fp2
		move.l  (a0)+,d2
		move.l  (a0)+,d3
		move.l  (a1)+,d0
		move.l  (a1)+,d1
		move.l  REFDEF_ALIASVRECT+VRECT_X(a3),d4
		cmp.l   d1,d3
		blt.b   .cont
		sub.l   d2,d4
		fmove.l d4,fp0
		fmove   fp0,fp3
		fadd    fp2,fp3
		move.l  d0,d4
		sub.l   d2,d4
		fmove.l d4,fp1
		fdiv    fp1,fp0
		fmove.l fp3,d0
		add.l   d2,d0
		move.l  d0,(a2)+
		moveq   #5-1,d2
		bra.b   .entry
.loop
		move.l  (a0)+,d3
		move.l  (a1)+,d1
.entry
		sub.l   d3,d1
		fmove.l d1,fp1
		fmul    fp0,fp1
		fadd    fp2,fp1
		fmove.l fp1,d1
		add.l   d3,d1
		move.l  d1,(a2)+
		dbra    d2,.loop
		bra.b   .exit
.cont
		sub.l   d0,d4
		fmove.l d4,fp0
		fmove   fp0,fp3
		fadd    fp2,fp3
		move.l  d2,d4
		sub.l   d0,d4
		fmove.l d4,fp1
		fdiv    fp1,fp0
		fmove.l fp3,d2
		add.l   d0,d2
		move.l  d2,(a2)+
		moveq   #5-1,d2
		bra.b   .entry2
.loop2
		move.l  (a0)+,d3
		move.l  (a1)+,d1
.entry2
		sub.l   d1,d3
		fmove.l d3,fp1
		fmul    fp0,fp1
		fadd    fp2,fp1
		fmove.l fp1,d3
		add.l   d1,d3
		move.l  d3,(a2)+
		dbra    d2,.loop2
.exit
		fmovem.x        (sp)+,fp2/fp3
		movem.l (sp)+,d2-d4/a2/a3
		rts






******************************************************************************
*
*       void _R_Alias_clip_right (finalvert_t *pfv0, finalvert_t *pfv1,
*                                 finalvert_t *out)
*
******************************************************************************

		cnop    0,4
_R_Alias_clip_right

*****   stackframe

		rsreset
.fpuregs        rs.x    2
.intregs        rs.l    5
		rs.l    1
.pfv0           rs.l    1
.pfv1           rs.l    1
.out            rs.l    1


		movem.l d2-d4/a2/a3,-(sp)
		fmovem.x        fp2/fp3,-(sp)
		move.l  .pfv0(sp),a0
		move.l  .pfv1(sp),a1
		move.l  .out(sp),a2
		lea     _r_refdef,a3
		fmove.s #0.5,fp2
		move.l  (a0)+,d2
		move.l  (a0)+,d3
		move.l  (a1)+,d0
		move.l  (a1)+,d1
		move.l  REFDEF_ALIASVRECTRIGHT(a3),d4
		cmp.l   d1,d3
		blt.b   .cont
		sub.l   d2,d4
		fmove.l d4,fp0
		fmove   fp0,fp3
		fadd    fp2,fp3
		move.l  d0,d4
		sub.l   d2,d4
		fmove.l d4,fp1
		fdiv    fp1,fp0
		fmove.l fp3,d0
		add.l   d2,d0
		move.l  d0,(a2)+
		moveq   #5-1,d2
		bra.b   .entry
.loop
		move.l  (a0)+,d3
		move.l  (a1)+,d1
.entry
		sub.l   d3,d1
		fmove.l d1,fp1
		fmul    fp0,fp1
		fadd    fp2,fp1
		fmove.l fp1,d1
		add.l   d3,d1
		move.l  d1,(a2)+
		dbra    d2,.loop
		bra.b   .exit
.cont
		sub.l   d0,d4
		fmove.l d4,fp0
		fmove   fp0,fp3
		fadd    fp2,fp3
		move.l  d2,d4
		sub.l   d0,d4
		fmove.l d4,fp1
		fdiv    fp1,fp0
		fmove.l fp3,d2
		add.l   d0,d2
		move.l  d2,(a2)+
		moveq   #5-1,d2
		bra.b   .entry2
.loop2
		move.l  (a0)+,d3
		move.l  (a1)+,d1
.entry2
		sub.l   d1,d3
		fmove.l d3,fp1
		fmul    fp0,fp1
		fadd    fp2,fp1
		fmove.l fp1,d3
		add.l   d1,d3
		move.l  d3,(a2)+
		dbra    d2,.loop2
.exit
		fmovem.x        (sp)+,fp2/fp3
		movem.l (sp)+,d2-d4/a2/a3
		rts







******************************************************************************
*
*       void _R_Alias_clip_top (finalvert_t *pfv0, finalvert_t *pfv1,
*                               finalvert_t *out)
*
******************************************************************************

		cnop    0,4
_R_Alias_clip_top

*****   stackframe

		rsreset
.fpuregs        rs.x    2
.intregs        rs.l    5
		rs.l    1
.pfv0           rs.l    1
.pfv1           rs.l    1
.out            rs.l    1


		movem.l d2-d4/a2/a3,-(sp)
		fmovem.x        fp2/fp3,-(sp)
		move.l  .pfv0(sp),a0
		move.l  .pfv1(sp),a1
		move.l  .out(sp),a2
		lea     _r_refdef,a3
		fmove.s #0.5,fp2
		move.l  (a0)+,d2
		move.l  (a0)+,d3
		move.l  (a1)+,d0
		move.l  (a1)+,d1
		move.l  REFDEF_ALIASVRECT+VRECT_Y(a3),d4
		cmp.l   d1,d3
		blt.b   .cont
		sub.l   d3,d4
		fmove.l d4,fp0
		fmove   fp0,fp3
		fadd    fp2,fp3
		move.l  d1,d4
		sub.l   d3,d4
		fmove.l d4,fp1
		fdiv    fp1,fp0
		fmove.l fp3,d1
		add.l   d3,d1
		move.l  d1,(a2)+
		moveq   #5-1,d3
		bra.b   .entry
.loop
		move.l  (a0)+,d2
		move.l  (a1)+,d0
.entry
		sub.l   d2,d0
		fmove.l d0,fp1
		fmul    fp0,fp1
		fadd    fp2,fp1
		fmove.l fp1,d0
		add.l   d2,d0
		move.l  d0,(a2)+
		dbra    d3,.loop
		bra.b   .exit
.cont
		sub.l   d1,d4
		fmove.l d4,fp0
		fmove   fp0,fp3
		fadd    fp2,fp3
		move.l  d3,d4
		sub.l   d1,d4
		fmove.l d4,fp1
		fdiv    fp1,fp0
		fmove.l fp3,d3
		add.l   d1,d3
		move.l  d3,(a2)+
		moveq   #5-1,d3
		bra.b   .entry2
.loop2
		move.l  (a0)+,d2
		move.l  (a1)+,d0
.entry2
		sub.l   d0,d2
		fmove.l d2,fp1
		fmul    fp0,fp1
		fadd    fp2,fp1
		fmove.l fp1,d2
		add.l   d0,d2
		move.l  d2,(a2)+
		dbra    d3,.loop2
.exit
		move.l  -24(a2),d0
		move.l  -20(a2),-24(a2)
		move.l  d0,-20(a2)
		fmovem.x        (sp)+,fp2/fp3
		movem.l (sp)+,d2-d4/a2/a3
		rts






******************************************************************************
*
*       void _R_Alias_clip_bottom (finalvert_t *pfv0, finalvert_t *pfv1,
*                                  finalvert_t *out)
*
******************************************************************************

		cnop    0,4
_R_Alias_clip_bottom

*****   stackframe

		rsreset
.fpuregs        rs.x    2
.intregs        rs.l    5
		rs.l    1
.pfv0           rs.l    1
.pfv1           rs.l    1
.out            rs.l    1


		movem.l d2-d4/a2/a3,-(sp)
		fmovem.x        fp2/fp3,-(sp)
		move.l  .pfv0(sp),a0
		move.l  .pfv1(sp),a1
		move.l  .out(sp),a2
		lea     _r_refdef,a3
		fmove.s #0.5,fp2
		move.l  (a0)+,d2
		move.l  (a0)+,d3
		move.l  (a1)+,d0
		move.l  (a1)+,d1
		move.l  REFDEF_ALIASVRECTBOTTOM(a3),d4
		cmp.l   d1,d3
		blt.b   .cont
		sub.l   d3,d4
		fmove.l d4,fp0
		fmove   fp0,fp3
		fadd    fp2,fp3
		move.l  d1,d4
		sub.l   d3,d4
		fmove.l d4,fp1
		fdiv    fp1,fp0
		fmove.l fp3,d1
		add.l   d3,d1
		move.l  d1,(a2)+
		moveq   #5-1,d3
		bra.b   .entry
.loop
		move.l  (a0)+,d2
		move.l  (a1)+,d0
.entry
		sub.l   d2,d0
		fmove.l d0,fp1
		fmul    fp0,fp1
		fadd    fp2,fp1
		fmove.l fp1,d0
		add.l   d2,d0
		move.l  d0,(a2)+
		dbra    d3,.loop
		bra.b   .exit
.cont
		sub.l   d1,d4
		fmove.l d4,fp0
		fmove   fp0,fp3
		fadd    fp2,fp3
		move.l  d3,d4
		sub.l   d1,d4
		fmove.l d4,fp1
		fdiv    fp1,fp0
		fmove.l fp3,d3
		add.l   d1,d3
		move.l  d3,(a2)+
		moveq   #5-1,d3
		bra.b   .entry2
.loop2
		move.l  (a0)+,d2
		move.l  (a1)+,d0
.entry2
		sub.l   d0,d2
		fmove.l d2,fp1
		fmul    fp0,fp1
		fadd    fp2,fp1
		fmove.l fp1,d2
		add.l   d0,d2
		move.l  d2,(a2)+
		dbra    d3,.loop2
.exit
		move.l  -24(a2),d0
		move.l  -20(a2),-24(a2)
		move.l  d0,-20(a2)
		fmovem.x        (sp)+,fp2/fp3
		movem.l (sp)+,d2-d4/a2/a3
		rts





******************************************************************************
*
*       int _R_AliasClip  (finalvert_t *in, finalvert_t *out, int flag,
*                          int count, void(*clip)(...)
*
******************************************************************************

		cnop    0,4
_R_AliasClip

*****   stackframe

		rsreset
.intregs        rs.l    11
		rs.l    1
.in             rs.l    1
.out            rs.l    1
.flag           rs.l    1
.count          rs.l    1
.clip           rs.l    1


		movem.l d2-d7/a2-a6,-(sp)
		move.l  .in(sp),a2
		move.l  .out(sp),a3
		move.l  .flag(sp),d2
		move.l  .count(sp),d3
		move.l  .clip(sp),a4

*        j = count-1;
*        k = 0;
*        for (i=0 ; i<count ; j = i, i++)
*        {

		move.l  d3,d5
		subq.l  #1,d5
		bmi.w   .skip
		move.l  d5,d0                   ;j = count-1
		asl.l   #FV_SIZEOF_EXP,d0
		lea     0(a2,d0.l),a6           ;a6 = in[j]
		lea     _r_refdef,a5
		move.l  REFDEF_ALIASVRECT+VRECT_X(a5),d3
		move.l  REFDEF_ALIASVRECT+VRECT_Y(a5),d4
		move.l  REFDEF_ALIASVRECTRIGHT(a5),d6
		move.l  REFDEF_ALIASVRECTBOTTOM(a5),d7
		move.l  a2,a5

*                oldflags = in[j].flags & flag;
*                flags = in[i].flags & flag;
*                if (flags && oldflags)
*                        continue;

.loop
		move.l  FV_FLAGS(a6),d0
		and.l   d2,d0                   ;oldflags = in[j].flags & flag
		move.l  FV_FLAGS(a2),d1
		and.l   d2,d1                   ;flags = in[i].flags & flag
		beq.b   .do
		tst.l   d0
		bne.w   .next
.do

*                if (oldflags ^ flags)
*                {
*                        clip (&in[j], &in[i], &out[k]);
*                        out[k].flags = 0;
*                        if (out[k].v[0] < r_refdef.aliasvrect.x)
*                                out[k].flags |= ALIAS_LEFT_CLIP;
*                        if (out[k].v[1] < r_refdef.aliasvrect.y)
*                                out[k].flags |= ALIAS_TOP_CLIP;
*                        if (out[k].v[0] > r_refdef.aliasvrectright)
*                                out[k].flags |= ALIAS_RIGHT_CLIP;
*                        if (out[k].v[1] > r_refdef.aliasvrectbottom)
*                                out[k].flags |= ALIAS_BOTTOM_CLIP;
*                        k++;
*                }

		eor.l   d1,d0                   ;if (oldflags ^ flags)
		beq.b   .cont
		move.l  d1,-(sp)
		move.l  a3,-(sp)
		move.l  a2,-(sp)
		move.l  a6,-(sp)
		jsr     (a4)                    ;clip (&in[j], &in[i], &out[k])
		add     #12,sp
		moveq   #0,d1                   ;out[k].flags = 0
		move.l  (a3),d0                 ;if (out[k].v[0] < ...
		cmp.l   d3,d0
		bge.b   .1
		or.l    #ALIAS_LEFT_CLIP,d1     ;out[k].flags |= ALIAS_LEFT_CLIP
.1
		cmp.l   d6,d0                   ;if (out[k].v[0] > ...
		ble.b   .2
		or.l    #ALIAS_RIGHT_CLIP,d1    ;out[k].flags |= ALIAS_RIGHT_CLIP
.2
		move.l  4(a3),d0                ;if (out[k].v[1] < ...
		cmp.l   d4,d0
		bge.b   .3
		or.l    #ALIAS_TOP_CLIP,d1      ;out[k].flags |= ALIAS_TOP_CLIP
.3
		cmp.l   d7,d0                   ;if (out[k].v[1] > ...
		ble.b   .4
		or.l    #ALIAS_BOTTOM_CLIP,d1   ;out[k].flags |= ALIAS_BOTTOM_CLIP
.4
		move.l  d1,FV_FLAGS(a3)
		lea     FV_SIZEOF(a3),a3        ;k++
		move.l  (sp)+,d1

*                if (!flags)
*                {
*                        out[k] = in[i];
*                        k++;
*                }

.cont
		tst.l   d1                      ;if (!flags)
		bne.b   .next
		move.l  (a2)+,(a3)+             ;out[k] = in[i]
		move.l  (a2)+,(a3)+
		move.l  (a2)+,(a3)+
		move.l  (a2)+,(a3)+
		move.l  (a2)+,(a3)+
		move.l  (a2)+,(a3)+
		move.l  (a2)+,(a3)+
		addq    #4,a3
		sub     #28,a2
.next
		move.l  a5,a6
		lea     FV_SIZEOF(a5),a5
		lea     FV_SIZEOF(a2),a2
		dbra    d5,.loop

*        return k;

.skip
		move.l  a3,d0
		sub.l   .out(sp),d0
		asr.l   #FV_SIZEOF_EXP,d0
		movem.l (sp)+,d2-d7/a2-a6
		rts
