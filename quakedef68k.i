MSURFACE_VISFRAME	equ	0
MSURFACE_DLIGHTFRAME	equ	4
MSURFACE_DLIGHTBITS	equ	8
MSURFACE_PLANE	equ	12
MSURFACE_FLAGS	equ	16
MSURFACE_FIRSTEDGE	equ	20
MSURFACE_NUMEDGES	equ	24
MSURFACE_CACHESPOTS	equ	28
MSURFACE_TEXTUREMINS	equ	44
MSURFACE_EXTENTS	equ	48
MSURFACE_TEXINFO	equ	52
MSURFACE_STYLES	equ	56
MSURFACE_SAMPLES	equ	60
MSURFACE_SIZEOF_EXP	equ	6
MSURFACE_SIZEOF	equ	64
MVERTEX_SIZEOF	equ	12
MEDGE_V	equ	0
MEDGE_CEO	equ	4
MEDGE_SIZEOF_EXP	equ	3
MEDGE_SIZEOF	equ	8
MPLANE_NORMAL	equ	0
MPLANE_DIST	equ	12
MPLANE_TYPE	equ	16
MPLANE_SIGNBITS	equ	17
MPLANE_SIZEOF	equ	20
MTEXINFO_VECS	equ	0
MTEXINFO_MIPADJUST	equ	32
MTEXINFO_TEXTURE	equ	36
MTEXINFO_FLAGS	equ	40
MTEXINFO_SIZEOF	equ	44
SURF_NEXT	equ	0
SURF_PREV	equ	4
SURF_SPANS	equ	8
SURF_KEY	equ	12
SURF_LAST_U	equ	16
SURF_SPANSTATE	equ	20
SURF_FLAGS	equ	24
SURF_DATA	equ	28
SURF_ENTITY	equ	32
SURF_NEARZI	equ	36
SURF_INSUBMODEL	equ	40
SURF_D_ZIORIGIN	equ	44
SURF_D_ZISTEPU	equ	48
SURF_D_ZISTEPV	equ	52
SURF_SIZEOF_EXP	equ	6
SURF_SIZEOF	equ	64
SPAN_U	equ	0
SPAN_V	equ	4
SPAN_COUNT	equ	8
SPAN_PNEXT	equ	12
SPAN_SIZEOF	equ	16
EDGE_U	equ	0
EDGE_U_STEP	equ	4
EDGE_PREV	equ	8
EDGE_NEXT	equ	12
EDGE_SURFS	equ	16
EDGE_NEXTREMOVE	equ	20
EDGE_NEARZI	equ	24
EDGE_OWNER	equ	28
EDGE_SIZEOF_EXP	equ	5
EDGE_SIZEOF	equ	32
CLIP_NORMAL	equ	0
CLIP_DIST	equ	12
CLIP_NEXT	equ	16
CLIP_LEFTEDGE	equ	20
CLIP_RIGHTEDGE	equ	21
CLIP_RESERVED	equ	22
CLIP_SIZEOF	equ	24
SURFCACHE_NEXT	equ	0
SURFCACHE_OWNER	equ	4
SURFCACHE_LIGHTADJ	equ	8
SURFCACHE_DLIGHT	equ	24
SURFCACHE_SIZE	equ	28
SURFCACHE_WIDTH	equ	32
SURFCACHE_HEIGHT	equ	36
SURFCACHE_MIPSCALE	equ	40
SURFCACHE_TEXTURE	equ	44
SURFCACHE_DATA	equ	48
SURFCACHE_SIZEOF	equ	52
TEXTURE_OFFSETS	equ	44
CVAR_VALUE	equ	16
ENTITY_FORCELINK	equ	0
ENTITY_UPDATE_TYPE	equ	4
ENTITY_BASELINE	equ	8
ENTITY_MSGTIME	equ	52
ENTITY_MSG_ORIGINS	equ	60
ENTITY_ORIGIN	equ	84
ENTITY_MSG_ANGLES	equ	96
ENTITY_ANGLES	equ	120
ENTITY_MODEL	equ	132
ENTITY_EFRAG	equ	136
ENTITY_FRAME	equ	140
ENTITY_SYNCBASE	equ	144
ENTITY_COLORMAP	equ	148
ENTITY_EFFECTS	equ	152
ENTITY_SKINNUM	equ	156
ENTITY_VISFRAME	equ	160
ENTITY_DLIGHTFRAME	equ	164
ENTITY_DLIGHTBITS	equ	168
ENTITY_TRIVIAL_ACCEPT	equ	172
ENTITY_TOPNODE	equ	176
ENTITY_SIZEOF	equ	180
NODE_CONTENTS	equ	0
NODE_VISFRAME	equ	4
NODE_MINMAXS	equ	8
NODE_PARENT	equ	20
NODE_PLANE	equ	24
NODE_CHILDREN	equ	28
NODE_FIRSTSURFACE	equ	36
NODE_NUMSURFACES	equ	38
LEAF_CONTENTS	equ	0
LEAF_VISFRAME	equ	4
LEAF_MINMAXS	equ	8
LEAF_PARENT	equ	20
LEAF_COMPRESSED_VIS	equ	24
LEAF_EFRAGS	equ	28
LEAF_FIRSTMARKSURFACE	equ	32
LEAF_NUMMARKSURFACES	equ	36
LEAF_KEY	equ	40
CL_TIME	equ	572
CL_WORLDMODEL	equ	2692
REFDEF_VRECT	equ	0
REFDEF_ALIASVRECT	equ	20
REFDEF_VRECTRIGHT	equ	40
REFDEF_VRECTBOTTOM	equ	44
REFDEF_ALIASVRECTRIGHT	equ	48
REFDEF_ALIASVRECTBOTTOM	equ	52
REFDEF_FVRECTX_ADJ	equ	68
REFDEF_FVRECTY_ADJ	equ	72
REFDEF_VRECTX_ADJ_S20	equ	76
REFDEF_VRECTXR_ADJ_S20	equ	80
REFDEF_FVRECTRIGHT_ADJ	equ	84
REFDEF_FVRECTBOTTOM_ADJ	equ	88
VRECT_X	equ	0
VRECT_Y	equ	4
VRECT_WIDTH	equ	8
VRECT_HEIGHT	equ	12
VRECT_PNEXT	equ	16
VID_BUFFER	equ	0
VID_COLORMAP	equ	4
VID_WIDTH	equ	20
VID_HEIGHT	equ	24
VID_ROWBYTES	equ	16
PSPANP_PDEST	equ	0
PSPANP_PZ	equ	4
PSPANP_COUNT	equ	8
PSPANP_PTEX	equ	12
PSPANP_SFRAC	equ	16
PSPANP_TFRAC	equ	20
PSPANP_LIGHT	equ	24
PSPANP_ZI	equ	28
PSPANP_SIZEOF	equ	32
PSPANP_SIZEOF_EXP	equ	5
ETAB_ISFLATTOP	equ	0
ETAB_NUMLEFTEDGES	equ	4
ETAB_PLEV0	equ	8
ETAB_PLEV1	equ	12
ETAB_PLEV2	equ	16
ETAB_NUMRIGHTEDGES	equ	20
ETAB_PREV0	equ	24
ETAB_PREV1	equ	28
ETAB_PREV2	equ	32
ETAB_SIZEOF	equ	36
R_PSKIN	equ	0
R_PSKINDESC	equ	4
R_SKINWIDTH	equ	8
R_SKINHEIGHT	equ	12
R_PTRIANGLES	equ	16
R_PFINALVERTS	equ	20
R_NUMTRIANGLES	equ	24
R_DRAWTYPE	equ	28
R_SEAMFIXUP16	equ	32
R_SIZEOF	equ	36
PTEMP_QUOTIENT	equ	0
PTEMP_REMAINDER	equ	4
MT_FACESFRONT	equ	0
MT_VERTINDEX	equ	4
MT_SIZEOF	equ	16
FV_V	equ	0
FV_FLAGS	equ	24
FV_RESERVED	equ	28
FV_SIZEOF	equ	32
FV_SIZEOF_EXP	equ	5
DRAWSURF_SURFDAT	equ	0
DRAWSURF_ROWBYTES	equ	4
DRAWSURF_SURF	equ	8
DRAWSURF_LIGHTADJ	equ	12
DRAWSURF_TEXTURE	equ	28
DRAWSURF_SURFMIP	equ	32
DRAWSURF_SURFWIDTH	equ	36
DRAWSURF_SURFHEIGHT	equ	40
DRAWSURF_SIZEOF	equ	44
TV_V	equ	0
TV_LIGHTNORMALINDEX	equ	3
SV_ONSEAM	equ	0
SV_S	equ	4
SV_T	equ	8
dma_gamealive	equ	0
dma_soundalive	equ	4
dma_splitbuffer	equ	8
dma_channels	equ	12
dma_samples	equ	16
dma_submission_chunk	equ	20
dma_samplepos	equ	24
dma_samplebits	equ	28
dma_speed	equ	32
dma_buffer	equ	36
PART_ORG	equ	0
PART_COLOR	equ	12
BTOFPOLY_CLIPFLAGS	equ	0
BTOFPOLY_PSURF	equ	4
MODEL_NAME	equ	0
MODEL_NEEDLOAD	equ	64
MODEL_TYPE	equ	68
MODEL_NUMFRAMES	equ	72
MODEL_SYNCTYPE	equ	76
MODEL_FLAGS	equ	80
MODEL_MINS	equ	84
MODEL_MAXS	equ	96
MODEL_RADIUS	equ	108
MODEL_FIRSTMS	equ	112
MODEL_NUMMS	equ	116
MODEL_NUMSUBMODELS	equ	120
MODEL_SUBMODELS	equ	124
MODEL_NUMPLANES	equ	128
MODEL_PLANES	equ	132
MODEL_NUMLEAFS	equ	136
MODEL_LEAFS	equ	140
MODEL_NUMVERTEXES	equ	144
MODEL_VERTEXES	equ	148
MODEL_NUMEDGES	equ	152
MODEL_EDGES	equ	156
MODEL_NUMNODES	equ	160
MODEL_NODES	equ	164
MODEL_NUMTEXINFO	equ	168
MODEL_TEXINFO	equ	172
MODEL_NUMSURFACES	equ	176
MODEL_SURFACES	equ	180
MODEL_NUMSURFEDGES	equ	184
MODEL_SURFEDGES	equ	188
MODEL_NUMCLIPNODES	equ	192
MODEL_CLIPNODES	equ	196
MODEL_NUMMARKSURFACES	equ	200
MODEL_MARKSURFACES	equ	204
