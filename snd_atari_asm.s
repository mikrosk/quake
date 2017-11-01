**
**  Sound mixing routines for Amiga 68k
**  Written by Frank Wille <frank@phoenix.owl.de>
**
** This implementation of S_TransferPaintBuffer() handles the following
** format:
**
**    16-bits STEREO for AHI.
**    DMA buffer layout (16 bits signed big-endian samples):
**    <-- shm.samples * (<16bits left ch.>|<16 bits right ch.>) -->
**

	.include	"quakedef68k.i"


	.text

	.globl	_shm
	.globl	_paintbuffer
	.globl	_paintedtime
	.globl	_volume



	.globl	_S_TransferPaintBuffer
	.align	4
_S_TransferPaintBuffer:
	movem.l	d2-d7/a2-a3,-(sp)

	move.l	_shm,a1			| a1 shm (struct dma_t)
	lea	_paintbuffer,a0		| a0 paintbuffer (int left,int right)
	fmove.s	_volume+16,fp0		| volume.value * 256
	move.l	4+8*4(sp),d2		| endtime
	fmul.w	#256,fp0
	move.l	_paintedtime,d6
	sub.l	d6,d2			| d2 count
	beq	exit
	move.l	dma_buffer(a1),a3	| a3 dma buffer start address
	fmove.l	fp0,d3			| d3 snd_vol
	move.l	dma_samples(a1),d0

| 16-bit AHI transfer
	lea	(a3,d0.l*2),a2		| a2 dma buffer end address
	lsr.l	#1,d0
	subq.l	#1,d0
	and.l	d0,d6
	lea	(a3,d6.l*4),a1		| a1 out
	move.l	#0x7fff,d4		| d4 max val
	move.l	d4,d5
	not.l	d5			| d5 min val
	move.l	a2,d6
	sub.l	a3,d6			| d6 buffer size
S_TransferPaintBuffer_loop16:
	move.l	(a0)+,d0
	muls.l	d3,d0
	move.l	(a0)+,d1
	asr.l	#8,d0
	muls.l	d3,d1
	cmp.l	d4,d0
	ble.b	l161
	move.l	d4,d0
	bra.b	l162
l161:	cmp.l	d5,d0
	bge.b	l162
	move.l	d5,d0
l162:	asr.l	#8,d1
	swap	d0
	cmp.l	d4,d1
	ble.b	l163
	move.l	d4,d1
	bra.b	l164
l163:	cmp.l	d5,d1
	bge.b	l164
	move.l	d5,d1
l164:	move.w	d1,d0			| d0 leftCh16.W | rightCh16.W
	move.l	d0,(a1)+
	cmp.l	a2,a1
	blo.b	l165
	sub.l	d6,a1
l165:	subq.l	#1,d2
	bne.b	S_TransferPaintBuffer_loop16
exit:	movem.l	(sp)+,d2-d7/a2-a3
	rts
