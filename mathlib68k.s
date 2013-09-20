**
** mathlib68k.asm
** math primitives, M68040/68060 or 68881/68882 (define M881)
** written by Frank Wille <frank@phoenix.owl.de>
**

	INCLUDE	"quakedef68k.i"



	code

	xref    _Sys_Error
	IFND	M881
	IFD	STORMC
	xref    _sin__r
	xref    _cos__r
	ELSE
	xref	_sin
	xref	_cos
	ENDC
	ENDC

	xdef    _anglemod
	xdef    _anglemod__r
	cnop    0,4
_anglemod:
_anglemod__r:
	setso   4
.a      so.s    1

; a = (360.0/65536) * ((int)(a*(65536/360.0)) & 65535);
	fmove.s .a(sp),fp0
	fmul.d	#$4066c16c16c16c17,fp0 ;(182.04444)double precision required!
	fmove.l fp0,d0
	swap    d0
	clr.w   d0
	swap    d0
	fmove.l d0,fp0
	fmul.s  #0.0054931641,fp0
	IFD	ATARI
	fmove.s	fp0,d0
	ENDC
	rts


	xdef    _BoxOnPlaneSide
	xdef    _BoxOnPlaneSide__r
	cnop    0,4
_BoxOnPlaneSide:
_BoxOnPlaneSide__r:
	move.l  a2,d1
	fmovem.x fp2-fp6,-(sp)
	setso   4+5*12
.emins  so.l    1
.emaxs  so.l    1
.p      so.l    1

	move.l  .p(sp),a2
	move.l  a2,a0                   ; preload normal[0..2]
	fmove.s (a0)+,fp1
	fmove.s (a0)+,fp2
	move.l  .emins(sp),a1
	fmove.s (a0),fp3
	move.l  .emaxs(sp),a0

; switch (p->signbits)
	moveq   #7,d0
	and.b   MPLANE_SIGNBITS(a2),d0
	jmp     ([.jtab,pc,d0.w*4])

.jtab:  dc.l    .c0,.c1,.c2,.c3,.c4,.c5,.c6,.c7

; dist1 = p->normal[0]*emaxs[0] + p->normal[1]*emaxs[1] + p->normal[2]*emaxs[2];
; dist2 = p->normal[0]*emins[0] + p->normal[1]*emins[1] + p->normal[2]*emins[2];
.c0:    fmove.s (a0)+,fp5
	fmul    fp1,fp5
	fmove.s (a1)+,fp6
	fmul    fp1,fp6
	fmove.s (a1)+,fp0
	fmul    fp2,fp0
	fmove.s (a0)+,fp4
	fadd    fp0,fp6
	fmul    fp2,fp4
	fmove.s (a1)+,fp0
	fadd    fp4,fp5
	fmul    fp3,fp0
	fmove.s (a0)+,fp4
	fadd    fp0,fp6
	fmul    fp3,fp4
	fadd    fp4,fp5
	bra     .1

; dist1 = p->normal[0]*emins[0] + p->normal[1]*emaxs[1] + p->normal[2]*emaxs[2];
; dist2 = p->normal[0]*emaxs[0] + p->normal[1]*emins[1] + p->normal[2]*emins[2];
.c1:    fmove.s (a1)+,fp5
	fmul    fp1,fp5
	fmove.s (a0)+,fp6
	fmul    fp1,fp6
	fmove.s (a0)+,fp0
	fmul    fp2,fp0
	fmove.s (a1)+,fp4
	fadd    fp0,fp5
	fmul    fp2,fp4
	fmove.s (a0)+,fp0
	fadd    fp4,fp6
	fmul    fp3,fp0
	fmove.s (a1)+,fp4
	fadd    fp0,fp5
	fmul    fp3,fp4
	fadd    fp4,fp6
	bra     .1

; dist1 = p->normal[0]*emaxs[0] + p->normal[1]*emins[1] + p->normal[2]*emaxs[2];
; dist2 = p->normal[0]*emins[0] + p->normal[1]*emaxs[1] + p->normal[2]*emins[2];
.c2:    fmove.s (a0)+,fp5
	fmul    fp1,fp5
	fmove.s (a1)+,fp6
	fmul    fp1,fp6
	fmove.s (a1)+,fp0
	fmul    fp2,fp0
	fmove.s (a0)+,fp4
	fadd    fp0,fp5
	fmul    fp2,fp4
	fmove.s (a0)+,fp0
	fadd    fp4,fp6
	fmul    fp3,fp0
	fmove.s (a1)+,fp4
	fadd    fp0,fp5
	fmul    fp3,fp4
	fadd    fp4,fp6
	bra     .1

; dist1 = p->normal[0]*emins[0] + p->normal[1]*emins[1] + p->normal[2]*emaxs[2];
; dist2 = p->normal[0]*emaxs[0] + p->normal[1]*emaxs[1] + p->normal[2]*emins[2];
.c3:    fmove.s (a1)+,fp5
	fmul    fp1,fp5
	fmove.s (a0)+,fp6
	fmul    fp1,fp6
	fmove.s (a1)+,fp0
	fmul    fp2,fp0
	fmove.s (a0)+,fp4
	fadd    fp0,fp5
	fmul    fp2,fp4
	fmove.s (a0)+,fp0
	fadd    fp4,fp6
	fmul    fp3,fp0
	fmove.s (a1)+,fp4
	fadd    fp0,fp5
	fmul    fp3,fp4
	fadd    fp4,fp6
	bra     .1

; dist1 = p->normal[0]*emaxs[0] + p->normal[1]*emaxs[1] + p->normal[2]*emins[2];
; dist2 = p->normal[0]*emins[0] + p->normal[1]*emins[1] + p->normal[2]*emaxs[2];
.c4:    fmove.s (a0)+,fp5
	fmul    fp1,fp5
	fmove.s (a1)+,fp6
	fmul    fp1,fp6
	fmove.s (a0)+,fp0
	fmul    fp2,fp0
	fmove.s (a1)+,fp4
	fadd    fp0,fp5
	fmul    fp2,fp4
	fmove.s (a1)+,fp0
	fadd    fp4,fp6
	fmul    fp3,fp0
	fmove.s (a0)+,fp4
	fadd    fp0,fp5
	fmul    fp3,fp4
	fadd    fp4,fp6
	bra     .1

; dist1 = p->normal[0]*emins[0] + p->normal[1]*emaxs[1] + p->normal[2]*emins[2];
; dist2 = p->normal[0]*emaxs[0] + p->normal[1]*emins[1] + p->normal[2]*emaxs[2];
.c5:    fmove.s (a1)+,fp5
	fmul    fp1,fp5
	fmove.s (a0)+,fp6
	fmul    fp1,fp6
	fmove.s (a0)+,fp0
	fmul    fp2,fp0
	fmove.s (a1)+,fp4
	fadd    fp0,fp5
	fmul    fp2,fp4
	fmove.s (a1)+,fp0
	fadd    fp4,fp6
	fmul    fp3,fp0
	fmove.s (a0)+,fp4
	fadd    fp0,fp5
	fmul    fp3,fp4
	fadd    fp4,fp6
	bra     .1

; dist1 = p->normal[0]*emaxs[0] + p->normal[1]*emins[1] + p->normal[2]*emins[2];
; dist2 = p->normal[0]*emins[0] + p->normal[1]*emaxs[1] + p->normal[2]*emaxs[2];
.c6:    fmove.s (a0)+,fp5
	fmul    fp1,fp5
	fmove.s (a1)+,fp6
	fmul    fp1,fp6
	fmove.s (a1)+,fp0
	fmul    fp2,fp0
	fmove.s (a0)+,fp4
	fadd    fp0,fp5
	fmul    fp2,fp4
	fmove.s (a1)+,fp0
	fadd    fp4,fp6
	fmul    fp3,fp0
	fmove.s (a0)+,fp4
	fadd    fp0,fp5
	fmul    fp3,fp4
	fadd    fp4,fp6
	bra     .1

; dist1 = p->normal[0]*emins[0] + p->normal[1]*emins[1] + p->normal[2]*emins[2];
; dist2 = p->normal[0]*emaxs[0] + p->normal[1]*emaxs[1] + p->normal[2]*emaxs[2];
.c7:    fmove.s (a1)+,fp5
	fmul    fp1,fp5
	fmove.s (a0)+,fp6
	fmul    fp1,fp6
	fmove.s (a1)+,fp0
	fmul    fp2,fp0
	fmove.s (a0)+,fp4
	fadd    fp0,fp5
	fmul    fp2,fp4
	fmove.s (a1)+,fp0
	fadd    fp4,fp6
	fmul    fp3,fp0
	fmove.s (a0)+,fp4
	fadd    fp0,fp5
	fmul    fp3,fp4
	fadd    fp4,fp6

.1:
; if (dist1 >= p->dist) sides = 1;
	fmove.s MPLANE_DIST(a2),fp0
	moveq   #0,d0                   ; sides=0
	fcmp    fp0,fp5
	fblt    .2
	moveq   #1,d0                   ; sides=1
.2:
; if (dist2 < p->dist)  sides |= 2;
	fcmp    fp0,fp6
	fbge    .3
	addq.b  #2,d0                   ; sides|=2

.3:     fmovem.x (sp)+,fp2-fp6
	move.l  d1,a2
	rts


	xdef    _AngleVectors
	xdef    _AngleVectors__r
	cnop    0,4
_AngleVectors:
_AngleVectors__r:
	fmovem.x fp2-fp7,-(sp)
	move.l  a2,-(sp)
	setso   4+6*12+1*4
.angles so.l    1
.forward so.l   1
.right  so.l    1
.up     so.l    1

	move.l  .angles(sp),a2
	fmove.s #0.01745329252,fp5      ; M_PI*2 / 360

; angle = angles[PITCH] * (M_PI*2 / 360);
; sp = sin(angle);
; cp = cos(angle);
	fmove   fp5,fp2
	fmul.s  (a2)+,fp2
	IFD     M881
	fsincos fp2,fp6:fp3
	ELSE
	fmove.d fp2,-(sp)
	IFD	STORMC
	jsr     _sin__r
	ELSE
	jsr	_sin
	ENDC
	fmove   fp0,fp3                 ; sp
	IFD	STORMC
	jsr     _cos__r
	ELSE
	jsr	_cos
	ENDC
	fmove   fp0,fp6                 ; cp
	ENDC

; angle = angles[YAW] * (M_PI*2 / 360);
; sy = sin(angle);
; cy = cos(angle);
	fmove   fp5,fp2
	fmul.s  (a2)+,fp2
	IFD     M881
	fsincos fp2,fp7:fp4
	ELSE
	fmove.d fp2,(sp)
	IFD	STORMC
	jsr     _sin__r
	ELSE
	jsr	_sin
	ENDC
	fmove   fp0,fp4                 ; sy
	IFD	STORMC
	jsr     _cos__r
	ELSE
	jsr	_cos
	ENDC
	fmove   fp0,fp7                 ; cy
	ENDC

; angle = angles[ROLL] * (M_PI*2 / 360);
; sr = sin(angle);
; cr = cos(angle);
	fmove   fp5,fp2
	fmul.s  (a2)+,fp2
	IFD     M881
	fsincos fp2,fp5:fp2
	ELSE
	fmove.d fp2,(sp)
	IFD	STORMC
	jsr     _sin__r
	ELSE
	jsr	_sin
	ENDC
	fmove   fp0,fp2                 ; sr
	IFD	STORMC
	jsr     _cos__r
	ELSE
	jsr	_cos
	ENDC
	fmove   fp0,fp5                 ; cr
	addq.w  #8,sp
	ENDC

; forward[0] = cp*cy;
; forward[1] = cp*sy;
; forward[2] = -sp;
	fmove   fp6,fp0
	fmul    fp7,fp0
	move.l  .forward(sp),a0
	fmove.s fp0,(a0)+
	fmove   fp6,fp0
	fmul    fp4,fp0
	fneg    fp3,fp1
	fmove.s fp0,(a0)+
	fmove.s fp1,(a0)+

; right[0] = (-1*sr*sp*cy+-1*cr*-sy);
; right[1] = (-1*sr*sp*sy+-1*cr*cy);
; right[2] = -1*sr*cp;
	fmove   fp4,fp0
	fmul    fp5,fp0
	fmove   fp2,fp1
	fmul    fp3,fp1
	fmove.d fp7,-(sp)
	fmul    fp1,fp7
	move.l  .right+8(sp),a0
	fsub    fp7,fp0
	fmove.s fp0,(a0)+
	fmul    fp4,fp1
	fmove.d (sp)+,fp7
	fneg    fp5,fp0
	fmul    fp7,fp0
	fsub    fp1,fp0
	fmove.s fp0,(a0)+
	fneg    fp2,fp1
	fmul    fp6,fp1
	fmove.s fp1,(a0)+

; up[0] = (cr*sp*cy+-sr*-sy);
; up[1] = (cr*sp*sy+-sr*cy);
; up[2] = cr*cp;
	fmul    fp5,fp3
	fneg    fp4,fp1
	fmove   fp7,fp0
	fmul    fp2,fp1
	fmul    fp3,fp0
	move.l  .up(sp),a0
	fsub    fp1,fp0
	fmul    fp7,fp2
	fmove.s fp0,(a0)+
	fmul    fp4,fp3
	move.l  (sp)+,a2
	fsub    fp2,fp3
	fmove.s fp3,(a0)+
	fmul    fp6,fp5
	fmove.s fp5,(a0)+
	fmovem.x (sp)+,fp2-fp7
	rts


	xdef    _VectorCompare
	xdef    _VectorCompare__r
	cnop    0,4
_VectorCompare:
_VectorCompare__r:
	setso   4
.v1     so.l    1
.v2     so.l    1

	move.l  .v1(sp),a0
	fmove.s (a0)+,fp0
	move.l  .v2(sp),a1
	fcmp.s  (a1)+,fp0
	fbne    .1
	fmove.s (a0)+,fp0
	fcmp.s  (a1)+,fp0
	fbne    .1
	fmove.s (a0),fp0
	fcmp.s  (a1),fp0
	fbne    .1
	moveq   #1,d0
	rts
.1:     moveq   #0,d0
	rts

	xdef    _VectorMA
	xdef    _VectorMA__r
	cnop    0,4
_VectorMA:
_VectorMA__r:
	setso   4
.veca   so.l    1
.scale  so.s    1
.vecb   so.l    1
.vecc   so.l    1

	move.l  a2,d1
	move.l  .vecb(sp),a1
	fmove.s (a1)+,fp0
	fmove.s .scale(sp),fp1
	fmul    fp1,fp0
	move.l  .veca(sp),a0
	fadd.s  (a0)+,fp0
	move.l  .vecc(sp),a2
	fmove.s fp0,(a2)+
	fmove.s (a1)+,fp0
	fmul    fp1,fp0
	fadd.s  (a0)+,fp0
	fmul.s  (a1),fp1
	fmove.s fp0,(a2)+
	fadd.s  (a0),fp1
	fmove.s fp1,(a2)
	move.l  d1,a2
	rts

	xdef    __DotProduct
	xdef    __DotProduct__r
	cnop    0,4
__DotProduct:
__DotProduct__r:
	setso   4
.v1     so.l    1
.v2     so.l    1

	move.l  .v1(sp),a0
	fmove.s (a0)+,fp0
	move.l  .v2(sp),a1
	fmul.s  (a1)+,fp0
	fmove.s (a0)+,fp1
	fmul.s  (a1)+,fp1
	fadd    fp1,fp0
	fmove.s (a0),fp1
	fmul.s  (a1)+,fp1
	fadd    fp1,fp0
	rts

	xdef    __VectorSubtract
	xdef    __VectorSubtract__r
	cnop    0,4
__VectorSubtract:
__VectorSubtract__r:
	setso   4
.veca   so.l    1
.vecb   so.l    1
.vecc   so.l    1

	move.l  .veca(sp),a0
	fmove.s (a0)+,fp0
	move.l  .vecb(sp),a1
	fsub.s  (a1)+,fp0
	move.l  a2,d1
	fmove.s (a0)+,fp1
	move.l  .vecc(sp),a2
	fmove.s fp0,(a2)+
	fsub.s  (a1)+,fp1
	fmove.s (a0),fp0
	fmove.s fp1,(a2)+
	fsub.s  (a1),fp0
	fmove.s fp0,(a2)
	move.l  d1,a2
	rts


	xdef    __VectorAdd
	xdef    __VectorAdd__r
	cnop    0,4
__VectorAdd:
__VectorAdd__r:
	setso   4
.veca   so.l    1
.vecb   so.l    1
.vecc   so.l    1

	move.l  .veca(sp),a0
	fmove.s (a0)+,fp0
	move.l  .vecb(sp),a1
	fadd.s  (a1)+,fp0
	move.l  a2,d1
	fmove.s (a0)+,fp1
	move.l  .vecc(sp),a2
	fmove.s fp0,(a2)+
	fadd.s  (a1)+,fp1
	fmove.s (a0),fp0
	fmove.s fp1,(a2)+
	fadd.s  (a1),fp0
	fmove.s fp0,(a2)
	move.l  d1,a2
	rts


	xdef    __VectorCopy
	xdef    __VectorCopy__r
	cnop    0,4
__VectorCopy:
__VectorCopy__r:
	setso   4
.in     so.l    1
.out    so.l    1

	move.l  .in(sp),a0
	move.l  .out(sp),a1
	move.l  (a0)+,(a1)+
	move.l  (a0)+,(a1)+
	move.l  (a0),(a1)
	rts


	xdef    _CrossProduct
	xdef    _CrossProduct__r
	cnop    0,4
_CrossProduct:
_CrossProduct__r:
	fmovem.x fp2-fp5,-(sp)
	setso   4+4*12
.v1     so.l    1
.v2     so.l    1
.cross  so.l    1

; cross[0] = v1[1]*v2[2] - v1[2]*v2[1];
; cross[1] = v1[2]*v2[0] - v1[0]*v2[2];
; cross[2] = v1[0]*v2[1] - v1[1]*v2[0];
	move.l  a2,d1
	move.l  .v1(sp),a1
	fmove.s (a1)+,fp0
	move.l  .v2(sp),a2
	fmove.s (a2)+,fp1
	fmove.s (a1)+,fp2
	fmove   fp1,fp4
	fmove.s (a2)+,fp3
	fmul    fp2,fp4
	fmove   fp0,fp5
	move.l  .cross(sp),a0
	fmul    fp3,fp5
	add.w   #12,a0
	fsub    fp4,fp5
	fmove.s (a1),fp4
	fmove.s fp5,-(a0)
	fmul    fp4,fp1
	fmove.s (a2),fp5
	fmul    fp5,fp0
	move.l  d1,a2
	fmul    fp4,fp3
	fsub    fp0,fp1
	fmul    fp5,fp2
	fmove.s fp1,-(a0)
	fsub    fp3,fp2
	fmove.s fp2,-(a0)
	fmovem.x (sp)+,fp2-fp5
	rts


	xdef    _Length
	xdef    _Length__r
	cnop    0,4
_Length:
_Length__r:
	setso   4
.v      so.l    1

; length = 0;
; for (i=0 ; i< 3 ; i++)
;   length += v[i]*v[i];
; length = sqrt (length);
	move.l  .v(sp),a0
	fmove.s (a0)+,fp0
	fmul    fp0,fp0
	fmove.s (a0)+,fp1
	fmul    fp1,fp1
	fadd    fp1,fp0
	fmove.s (a0),fp1
	fmul    fp1,fp1
	fadd    fp1,fp0
	fsqrt   fp0
	IFD	ATARI
	fmove.s	fp0,d0
	ENDC
	rts


	xdef    _VectorNormalize
	xdef    _VectorNormalize__r
	cnop    0,4
_VectorNormalize:
_VectorNormalize__r:
	fmovem.x fp2-fp4,-(sp)
	setso   4+3*12
.v      so.l    1

; length = v[0]*v[0] + v[1]*v[1] + v[2]*v[2];
; length = sqrt (length);
	move.l  .v(sp),a0
	fmove.s (a0)+,fp2
	fmove   fp2,fp0
	fmul    fp2,fp0
	fmove.s (a0)+,fp3
	fmove   fp3,fp1
	fmul    fp3,fp1
	fmove.s (a0),fp4
	fadd    fp1,fp0
	fmove   fp4,fp1
	fmul    fp4,fp1
	fadd    fp1,fp0
	fsqrt   fp0

; if (length)
; {
;   ilength = 1/length;
;   v[0] *= ilength;
;   v[1] *= ilength;
;   v[2] *= ilength;
; }
	ftst    fp0
	fbeq    .1
	fmove.s #1.0,fp1
	fdiv    fp0,fp1
	subq.w  #8,a0
	fmul    fp1,fp2
	fmove.s fp2,(a0)+
	fmul    fp1,fp3
	fmove.s fp3,(a0)+
	fmul    fp1,fp4
	fmove.s fp4,(a0)
.1:     fmovem.x (sp)+,fp2-fp4
	IFD	ATARI
	fmove.s	fp0,d0
	ENDC
	rts


	xdef    _VectorInverse
	xdef    _VectorInverse__r
	cnop    0,4
_VectorInverse:
_VectorInverse__r:
	setso   4
.v      so.l    1

; v[0] = -v[0];
; v[1] = -v[1];
; v[2] = -v[2];
	move.l  .v(sp),a0
	fneg.s  (a0),fp0
	fmove.s fp0,(a0)+
	fneg.s  (a0),fp0
	fmove.s fp0,(a0)+
	fneg.s  (a0),fp0
	fmove.s fp0,(a0)
	rts


	xdef    _VectorScale
	xdef    _VectorScale__r
	cnop    0,4
_VectorScale:
_VectorScale__r:
	setso   4
.in     so.l    1
.scale  so.l    1
.out    so.l    1

; out[0] = in[0]*scale;
; out[1] = in[1]*scale;
; out[2] = in[2]*scale;
	fmove.s .scale(sp),fp1
	move.l  .in(sp),a0
	fmove.s (a0)+,fp0
	fmul    fp1,fp0
	move.l  .out(sp),a1
	fmove.s fp0,(a1)+
	fmove.s (a0)+,fp0
	fmul    fp1,fp0
	fmove.s fp0,(a1)+
	fmul.s  (a0),fp1
	fmove.s fp1,(a1)
	rts


	xdef    _Q_log2
	xdef    _Q_log2__r
	cnop    0,4
_Q_log2:
_Q_log2__r:
	setso   4
.val    so.l    1

; int answer=0;
; while (val>>=1) answer++;
	move.l	.val(sp),d1
	moveq   #-1,d0
.1:     addq.l  #1,d0
	lsr.l   #1,d1
	bne.b   .1
	rts

	xdef    _R_ConcatRotations
	xdef    _R_ConcatRotations__r
	cnop    0,4
_R_ConcatRotations:
_R_ConcatRotations__r:
	fmovem.x fp2/fp4/fp5/fp6,-(sp)
	move.l  a2,d1
	setso   4+4*12
.in1    so.l    1
.in2    so.l    1
.out    so.l    1

	move.l  .in1(sp),a0
	move.l  .in2(sp),a1
	move.l  .out(sp),a2

; out[0][0] = in1[0][0] * in2[0][0] + in1[0][1] * in2[1][0] + in1[0][2] * in2[2][0];
; out[0][1] = in1[0][0] * in2[0][1] + in1[0][1] * in2[1][1] + in1[0][2] * in2[2][1];
; out[0][2] = in1[0][0] * in2[0][2] + in1[0][1] * in2[1][2] + in1[0][2] * in2[2][2];
	fmove.s (a0)+,fp4
	fmove   fp4,fp0
	fmul.s  (0*12+0*4,a1),fp0
	fmove.s (a0)+,fp5
	fmove   fp5,fp1
	fmul.s  (1*12+0*4,a1),fp1
	fmove.s (a0)+,fp6
	fmove   fp6,fp2
	fmul.s  (2*12+0*4,a1),fp2
	fadd    fp0,fp1
	fmove   fp4,fp0
	fmul.s  (0*12+1*4,a1),fp0
	fadd    fp1,fp2
	fmove   fp5,fp1
	fmul.s  (1*12+1*4,a1),fp1
	fmove.s fp2,(a2)+
	fmove   fp6,fp2
	fmul.s  (2*12+1*4,a1),fp2
	fadd    fp0,fp1
	fmul.s  (0*12+2*4,a1),fp4
	fadd    fp1,fp2
	fmul.s  (1*12+2*4,a1),fp5
	fmove.s fp2,(a2)+
	fadd    fp4,fp5
	fmul.s  (2*12+2*4,a1),fp6
	fadd    fp5,fp6
	fmove.s fp6,(a2)+

; out[1][0] = in1[1][0] * in2[0][0] + in1[1][1] * in2[1][0] + in1[1][2] * in2[2][0];
; out[1][1] = in1[1][0] * in2[0][1] + in1[1][1] * in2[1][1] + in1[1][2] * in2[2][1];
; out[1][2] = in1[1][0] * in2[0][2] + in1[1][1] * in2[1][2] + in1[1][2] * in2[2][2];
	fmove.s (a0)+,fp4
	fmove   fp4,fp0
	fmul.s  (0*12+0*4,a1),fp0
	fmove.s (a0)+,fp5
	fmove   fp5,fp1
	fmul.s  (1*12+0*4,a1),fp1
	fmove.s (a0)+,fp6
	fmove   fp6,fp2
	fmul.s  (2*12+0*4,a1),fp2
	fadd    fp0,fp1
	fmove   fp4,fp0
	fmul.s  (0*12+1*4,a1),fp0
	fadd    fp1,fp2
	fmove   fp5,fp1
	fmul.s  (1*12+1*4,a1),fp1
	fmove.s fp2,(a2)+
	fmove   fp6,fp2
	fmul.s  (2*12+1*4,a1),fp2
	fadd    fp0,fp1
	fmul.s  (0*12+2*4,a1),fp4
	fadd    fp1,fp2
	fmul.s  (1*12+2*4,a1),fp5
	fmove.s fp2,(a2)+
	fadd    fp4,fp5
	fmul.s  (2*12+2*4,a1),fp6
	fadd    fp5,fp6
	fmove.s fp6,(a2)+

; out[2][0] = in1[2][0] * in2[0][0] + in1[2][1] * in2[1][0] + in1[2][2] * in2[2][0];
; out[2][1] = in1[2][0] * in2[0][1] + in1[2][1] * in2[1][1] + in1[2][2] * in2[2][1];
; out[2][2] = in1[2][0] * in2[0][2] + in1[2][1] * in2[1][2] + in1[2][2] * in2[2][2];
	fmove.s (a0)+,fp4
	fmove   fp4,fp0
	fmul.s  (0*12+0*4,a1),fp0
	fmove.s (a0)+,fp5
	fmove   fp5,fp1
	fmul.s  (1*12+0*4,a1),fp1
	fmove.s (a0)+,fp6
	fmove   fp6,fp2
	fmul.s  (2*12+0*4,a1),fp2
	fadd    fp0,fp1
	fmove   fp4,fp0
	fmul.s  (0*12+1*4,a1),fp0
	fadd    fp1,fp2
	fmove   fp5,fp1
	fmul.s  (1*12+1*4,a1),fp1
	fmove.s fp2,(a2)+
	fmove   fp6,fp2
	fmul.s  (2*12+1*4,a1),fp2
	fadd    fp0,fp1
	fmul.s  (0*12+2*4,a1),fp4
	fadd    fp1,fp2
	fmul.s  (1*12+2*4,a1),fp5
	fmove.s fp2,(a2)+
	fadd    fp4,fp5
	fmul.s  (2*12+2*4,a1),fp6
	fadd    fp5,fp6
	fmove.s fp6,(a2)+

	move.l  d1,a2
	fmovem.x (sp)+,fp2/fp4/fp5/fp6
	rts


	xdef    _R_ConcatTransforms
	xdef    _R_ConcatTransforms__r
	cnop    0,4
_R_ConcatTransforms:
_R_ConcatTransforms__r:
	fmovem.x fp2/fp4/fp5/fp6,-(sp)
	move.l  a2,d1
	setso   4+4*12
.in1    so.l    1
.in2    so.l    1
.out    so.l    1

	move.l  .in1(sp),a0
	move.l  .in2(sp),a1
	move.l  .out(sp),a2

; out[0][0] = in1[0][0] * in2[0][0] + in1[0][1] * in2[1][0] + in1[0][2] * in2[2][0];
; out[0][1] = in1[0][0] * in2[0][1] + in1[0][1] * in2[1][1] + in1[0][2] * in2[2][1];
; out[0][2] = in1[0][0] * in2[0][2] + in1[0][1] * in2[1][2] + in1[0][2] * in2[2][2];
; out[0][3] = in1[0][0] * in2[0][3] + in1[0][1] * in2[1][3] + in1[0][2] * in2[2][3] + in1[0][3];
	fmove.s (a0)+,fp4
	fmove   fp4,fp0
	fmul.s  (0*16+0*4,a1),fp0
	fmove.s (a0)+,fp5
	fmove   fp5,fp1
	fmul.s  (1*16+0*4,a1),fp1
	fmove.s (a0)+,fp6
	fmove   fp6,fp2
	fmul.s  (2*16+0*4,a1),fp2
	fadd    fp0,fp1
	fmove   fp4,fp0
	fmul.s  (0*16+1*4,a1),fp0
	fadd    fp1,fp2
	fmove   fp5,fp1
	fmul.s  (1*16+1*4,a1),fp1
	fmove.s fp2,(a2)+
	fmove   fp6,fp2
	fmul.s  (2*16+1*4,a1),fp2
	fadd    fp0,fp1
	fmove   fp4,fp0
	fmul.s  (0*16+2*4,a1),fp0
	fadd    fp1,fp2
	fmove   fp5,fp1
	fmul.s  (1*16+2*4,a1),fp1
	fmove.s fp2,(a2)+
	fmove   fp6,fp2
	fmul.s  (2*16+2*4,a1),fp2
	fadd    fp0,fp1
	fmul.s  (0*16+3*4,a1),fp4
	fadd    fp1,fp2
	fmul.s  (1*16+3*4,a1),fp5
	fmove.s fp2,(a2)+
	fadd    fp4,fp5
	fmul.s  (2*16+3*4,a1),fp6
	fadd.s  (a0)+,fp5
	fadd    fp5,fp6
	fmove.s fp6,(a2)+

; out[1][0] = in1[1][0] * in2[0][0] + in1[1][1] * in2[1][0] + in1[1][2] * in2[2][0];
; out[1][1] = in1[1][0] * in2[0][1] + in1[1][1] * in2[1][1] + in1[1][2] * in2[2][1];
; out[1][2] = in1[1][0] * in2[0][2] + in1[1][1] * in2[1][2] + in1[1][2] * in2[2][2];
; out[1][3] = in1[1][0] * in2[0][3] + in1[1][1] * in2[1][3] + in1[1][2] * in2[2][3] + in1[1][3];
	fmove.s (a0)+,fp4
	fmove   fp4,fp0
	fmul.s  (0*16+0*4,a1),fp0
	fmove.s (a0)+,fp5
	fmove   fp5,fp1
	fmul.s  (1*16+0*4,a1),fp1
	fmove.s (a0)+,fp6
	fmove   fp6,fp2
	fmul.s  (2*16+0*4,a1),fp2
	fadd    fp0,fp1
	fmove   fp4,fp0
	fmul.s  (0*16+1*4,a1),fp0
	fadd    fp1,fp2
	fmove   fp5,fp1
	fmul.s  (1*16+1*4,a1),fp1
	fmove.s fp2,(a2)+
	fmove   fp6,fp2
	fmul.s  (2*16+1*4,a1),fp2
	fadd    fp0,fp1
	fmove   fp4,fp0
	fmul.s  (0*16+2*4,a1),fp0
	fadd    fp1,fp2
	fmove   fp5,fp1
	fmul.s  (1*16+2*4,a1),fp1
	fmove.s fp2,(a2)+
	fmove   fp6,fp2
	fmul.s  (2*16+2*4,a1),fp2
	fadd    fp0,fp1
	fmul.s  (0*16+3*4,a1),fp4
	fadd    fp1,fp2
	fmul.s  (1*16+3*4,a1),fp5
	fmove.s fp2,(a2)+
	fadd    fp4,fp5
	fmul.s  (2*16+3*4,a1),fp6
	fadd.s  (a0)+,fp5
	fadd    fp5,fp6
	fmove.s fp6,(a2)+

; out[2][0] = in1[2][0] * in2[0][0] + in1[2][1] * in2[1][0] + in1[2][2] * in2[2][0];
; out[2][1] = in1[2][0] * in2[0][1] + in1[2][1] * in2[1][1] + in1[2][2] * in2[2][1];
; out[2][2] = in1[2][0] * in2[0][2] + in1[2][1] * in2[1][2] + in1[2][2] * in2[2][2];
; out[2][3] = in1[2][0] * in2[0][3] + in1[2][1] * in2[1][3] + in1[2][2] * in2[2][3] + in1[2][3];
	fmove.s (a0)+,fp4
	fmove   fp4,fp0
	fmul.s  (0*16+0*4,a1),fp0
	fmove.s (a0)+,fp5
	fmove   fp5,fp1
	fmul.s  (1*16+0*4,a1),fp1
	fmove.s (a0)+,fp6
	fmove   fp6,fp2
	fmul.s  (2*16+0*4,a1),fp2
	fadd    fp0,fp1
	fmove   fp4,fp0
	fmul.s  (0*16+1*4,a1),fp0
	fadd    fp1,fp2
	fmove   fp5,fp1
	fmul.s  (1*16+1*4,a1),fp1
	fmove.s fp2,(a2)+
	fmove   fp6,fp2
	fmul.s  (2*16+1*4,a1),fp2
	fadd    fp0,fp1
	fmove   fp4,fp0
	fmul.s  (0*16+2*4,a1),fp0
	fadd    fp1,fp2
	fmove   fp5,fp1
	fmul.s  (1*16+2*4,a1),fp1
	fmove.s fp2,(a2)+
	fmove   fp6,fp2
	fmul.s  (2*16+2*4,a1),fp2
	fadd    fp0,fp1
	fmul.s  (0*16+3*4,a1),fp4
	fadd    fp1,fp2
	fmul.s  (1*16+3*4,a1),fp5
	fmove.s fp2,(a2)+
	fadd    fp4,fp5
	fmul.s  (2*16+3*4,a1),fp6
	fadd.s  (a0)+,fp5
	fadd    fp5,fp6
	fmove.s fp6,(a2)+

	move.l  d1,a2
	fmovem.x (sp)+,fp2/fp4/fp5/fp6
	rts


	xdef    _FloorDivMod
	xdef    _FloorDivMod__r
	cnop    0,4
_FloorDivMod:
_FloorDivMod__r:
	setso   4+4
.numer  so.d    1
.denom  so.d    1
.quot   so.l    1
.rem    so.l    1

; set rounding mode towards minus infinity
	fmove.l fpcr,d0
	move.l  d0,-(sp)
	moveq   #%10,d1
	bfins   d1,d0{26:2}
	fmove.l d0,fpcr

; if (numer >= 0.0)
	fmove.d .numer(sp),fp0
	fmove.d .denom(sp),fp1
	ftst    fp0
	fblt    .1

; x = floor(numer / denom);
; q = (int)x;
; r = (int)floor(numer - (x * denom));
	fdiv    fp1,fp0
	move.l  .quot(sp),a0
	move.l  .rem(sp),a1
	fmove.l fp0,(a0)
	fmul.l  (a0),fp1
	fmove.d .numer(sp),fp0
	fsub    fp1,fp0
	fmove.l fp0,(a1)
	fmove.l (sp)+,fpcr
	rts

; else /* numer < 0.0) */
.1:
; x = floor(-numer / denom);
; q = -(int)x;
; r = (int)floor(-numer - (x * denom));
	fmovem.x fp2/fp3,-(sp)
	fneg    fp0
	fmove   fp0,fp2
	fdiv    fp1,fp0
	move.l  .quot+2*12(sp),a0
	move.l  .rem+2*12(sp),a1
	fmove.l fp0,d0
	fmove   fp1,fp3
	fmul.l  d0,fp1
	neg.l   d0
	fsub    fp1,fp2
	move.l  d0,(a0)
	fmove.l fp2,d0
	move.l  d0,d1
	beq.b   .2
	fmove.l fp3,d1
	subq.l  #1,(a0)
	sub.l   d0,d1
.2:     move.l  d1,(a1)
	fmovem.x (sp)+,fp2/fp3
	fmove.l (sp)+,fpcr
	rts
	

	xdef    _GreatestCommonDivisor
	xdef    _GreatestCommonDivisor__r
	cnop    0,4
_GreatestCommonDivisor:
_GreatestCommonDivisor__r:
	setso   4
.i1     so.l    1
.i2     so.l    1

	move.l  .i1(sp),d1
	move.l  d2,a0
	move.l  .i2(sp),d0
	bra.b   .2
.1:     move.l  d0,d2
	divsl.l d1,d0:d2
.2:     cmp.l   d1,d0
	bge.b   .3
	exg     d0,d1
.3:     tst.l   d1
	bne.b   .1
	move.l  a0,d2
	rts


	xdef    _Invert24To16
	xdef    _Invert24To16__r
	cnop    0,4
_Invert24To16:
_Invert24To16__r:
	move.l  4(sp),d0
	cmp.l   #256,d0
	blt.b   .1
	fmove.d #$4270000000000000,fp0
	fdiv.l  d0,fp0
	fadd.d  #0.5,fp0
	fmove.l fp0,d0
	rts
.1:     moveq   #-1,d0
	rts
