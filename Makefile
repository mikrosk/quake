#
# Quake Makefile for Atari 2.0
#
# Aug '06 by Miro Kropacek <mikro@hysteria.sk>
#

BASEVERSION=1.09

MOUNT_DIR=.

BUILD_DEBUG_DIR=debug
BUILD_RELEASE_DIR=release

M68KASM_DIR=asm68k

CC=gcc
CC3=gcc-3.3.6

BASE_CFLAGS=-Dstricmp=strcasecmp -DM68K_MIX -DM68KASM
RELEASE_CFLAGS=$(BASE_CFLAGS) -g -Wall -m68060 -O3 -fomit-frame-pointer
DEBUG_CFLAGS=$(BASE_CFLAGS) -g -Wall -m68060
LDFLAGS=-lm

DO_CC=$(CC3) $(CFLAGS) -o $@ -c $<
DO_AS=$(AS) -m68060 -o $@ $<
DO_DEVPAC2GAS=$(MOUNT_DIR)/devpac2gas.perl $< > $@

#############################################################################
# SETUP AND BUILD
#############################################################################

TARGETS=$(BUILDDIR)/quake.ttp

build_debug:
	@-mkdir $(BUILD_DEBUG_DIR) \
		$(BUILD_DEBUG_DIR)/obj
	$(MAKE) targets BUILDDIR=$(BUILD_DEBUG_DIR) CFLAGS="$(DEBUG_CFLAGS)"

build_release:
	@-mkdir $(BUILD_RELEASE_DIR) \
		$(BUILD_RELEASE_DIR)/obj
	$(MAKE) targets BUILDDIR=$(BUILD_RELEASE_DIR) CFLAGS="$(RELEASE_CFLAGS)"

all: build_debug

targets: $(TARGETS)

#############################################################################
# Quake
#############################################################################

QUAKE_OBJS = \
	$(BUILDDIR)/obj/cl_demo.o \
	$(BUILDDIR)/obj/cl_input.o \
	$(BUILDDIR)/obj/cl_main.o \
	$(BUILDDIR)/obj/cl_parse.o \
	$(BUILDDIR)/obj/cl_tent.o \
	$(BUILDDIR)/obj/chase.o \
	$(BUILDDIR)/obj/cmd.o \
	$(BUILDDIR)/obj/common.o \
	$(BUILDDIR)/obj/console.o \
	$(BUILDDIR)/obj/crc.o \
	$(BUILDDIR)/obj/cvar.o \
	$(BUILDDIR)/obj/draw.o \
	$(BUILDDIR)/obj/d_edge.o \
	$(BUILDDIR)/obj/d_fill.o \
	$(BUILDDIR)/obj/d_init.o \
	$(BUILDDIR)/obj/d_modech.o \
	$(BUILDDIR)/obj/d_part.o \
	$(BUILDDIR)/obj/d_polyse.o \
	$(BUILDDIR)/obj/d_scan.o \
	$(BUILDDIR)/obj/d_sky.o \
	$(BUILDDIR)/obj/d_sprite.o \
	$(BUILDDIR)/obj/d_surf.o \
	$(BUILDDIR)/obj/d_vars.o \
	$(BUILDDIR)/obj/d_zpoint.o \
	$(BUILDDIR)/obj/host.o \
	$(BUILDDIR)/obj/host_cmd.o \
	$(BUILDDIR)/obj/keys.o \
	$(BUILDDIR)/obj/menu.o \
	$(BUILDDIR)/obj/mathlib.o \
	$(BUILDDIR)/obj/model.o \
	$(BUILDDIR)/obj/net_loop.o \
	$(BUILDDIR)/obj/net_main.o \
	$(BUILDDIR)/obj/net_atari.o \
	$(BUILDDIR)/obj/nonintel.o \
	$(BUILDDIR)/obj/pr_cmds.o \
	$(BUILDDIR)/obj/pr_edict.o \
	$(BUILDDIR)/obj/pr_exec.o \
	$(BUILDDIR)/obj/r_aclip.o \
	$(BUILDDIR)/obj/r_alias.o \
	$(BUILDDIR)/obj/r_bsp.o \
	$(BUILDDIR)/obj/r_light.o \
	$(BUILDDIR)/obj/r_draw.o \
	$(BUILDDIR)/obj/r_efrag.o \
	$(BUILDDIR)/obj/r_edge.o \
	$(BUILDDIR)/obj/r_misc.o \
	$(BUILDDIR)/obj/r_main.o \
	$(BUILDDIR)/obj/r_sky.o \
	$(BUILDDIR)/obj/r_sprite.o \
	$(BUILDDIR)/obj/r_surf.o \
	$(BUILDDIR)/obj/r_part.o \
	$(BUILDDIR)/obj/r_vars.o \
	$(BUILDDIR)/obj/screen.o \
	$(BUILDDIR)/obj/sbar.o \
	$(BUILDDIR)/obj/sv_main.o \
	$(BUILDDIR)/obj/sv_phys.o \
	$(BUILDDIR)/obj/sv_move.o \
	$(BUILDDIR)/obj/sv_user.o \
	$(BUILDDIR)/obj/zone.o	\
	$(BUILDDIR)/obj/view.o	\
	$(BUILDDIR)/obj/wad.o \
	$(BUILDDIR)/obj/world.o \
	$(BUILDDIR)/obj/cd_atari.o \
	$(BUILDDIR)/obj/vid_atari.o \
	$(BUILDDIR)/obj/snd_dma.o \
	$(BUILDDIR)/obj/snd_mem.o \
	$(BUILDDIR)/obj/snd_mix.o \
	$(BUILDDIR)/obj/snd_atari.o \
	$(BUILDDIR)/obj/in_atari.o \
	$(BUILDDIR)/obj/sys_atari.o \
	\
	$(BUILDDIR)/obj/keys_atari_asm.o \
	$(BUILDDIR)/obj/vid_atari_asm.o \
	$(BUILDDIR)/obj/snd_atari_asm.o	
	
# use -DM68KASM when you want to use the following
QUAKE_M68K_OBJS = \
	$(BUILDDIR)/obj/mathlib68k.o \
	$(BUILDDIR)/obj/r_sky68k.o \
	$(BUILDDIR)/obj/r_aclip68k.o \
	$(BUILDDIR)/obj/r_edge68k.o \
	$(BUILDDIR)/obj/r_light68k.o \
	$(BUILDDIR)/obj/r_misc68k.o \
	$(BUILDDIR)/obj/r_surf68k.o \
	$(BUILDDIR)/obj/common68k.o \
	$(BUILDDIR)/obj/d_part68k.o \
	$(BUILDDIR)/obj/r_bsp68k.o \
	$(BUILDDIR)/obj/d_edge68k.o \
	$(BUILDDIR)/obj/d_sky68k.o \
	$(BUILDDIR)/obj/r_draw68k.o \
	$(BUILDDIR)/obj/r_alias68k.o \
	$(BUILDDIR)/obj/d_polyset68k.o \
	$(BUILDDIR)/obj/d_scan68k.o \
	$(BUILDDIR)/obj/d_sprite68k.o
	
	
$(BUILDDIR)/quake.ttp : $(QUAKE_OBJS) $(QUAKE_M68K_OBJS)
	$(CC) $(CFLAGS) -o $@ $(QUAKE_OBJS) $(QUAKE_M68K_OBJS) $(LDFLAGS)
	stack --fix=512k $(BUILDDIR)/quake.ttp
	flags -S $(BUILDDIR)/quake.ttp
	cp $(BUILDDIR)/quake.ttp $(MOUNT_DIR)
	
quakedef68k.i: genasmheaders quakeasmheaders.gen
	$(MOUNT_DIR)/genasmheaders quakeasmheaders.gen $@ 1 "$(CC) $(CFLAGS) -I."

genasmheaders: genasmheaders.c
	$(CC) -o $@ genasmheaders.c
	
####

$(BUILDDIR)/obj/cl_demo.o :  $(MOUNT_DIR)/cl_demo.c
	$(DO_CC)

$(BUILDDIR)/obj/cl_input.o : $(MOUNT_DIR)/cl_input.c
	$(DO_CC)

$(BUILDDIR)/obj/cl_main.o :  $(MOUNT_DIR)/cl_main.c
	$(DO_CC)

$(BUILDDIR)/obj/cl_parse.o : $(MOUNT_DIR)/cl_parse.c
	$(DO_CC)

$(BUILDDIR)/obj/cl_tent.o :  $(MOUNT_DIR)/cl_tent.c
	$(DO_CC)

$(BUILDDIR)/obj/chase.o :    $(MOUNT_DIR)/chase.c
	$(DO_CC)

$(BUILDDIR)/obj/cmd.o :      $(MOUNT_DIR)/cmd.c
	$(DO_CC)

$(BUILDDIR)/obj/common.o :   $(MOUNT_DIR)/common.c
	$(DO_CC)

$(BUILDDIR)/obj/console.o :  $(MOUNT_DIR)/console.c
	$(DO_CC)

$(BUILDDIR)/obj/crc.o :      $(MOUNT_DIR)/crc.c
	$(DO_CC)

$(BUILDDIR)/obj/cvar.o :     $(MOUNT_DIR)/cvar.c
	$(DO_CC)

$(BUILDDIR)/obj/draw.o :     $(MOUNT_DIR)/draw.c
	$(DO_CC)

$(BUILDDIR)/obj/d_edge.o :   $(MOUNT_DIR)/d_edge.c
	$(DO_CC)

$(BUILDDIR)/obj/d_fill.o :   $(MOUNT_DIR)/d_fill.c
	$(DO_CC)

$(BUILDDIR)/obj/d_init.o :   $(MOUNT_DIR)/d_init.c
	$(DO_CC)

$(BUILDDIR)/obj/d_modech.o : $(MOUNT_DIR)/d_modech.c
	$(DO_CC)

$(BUILDDIR)/obj/d_part.o :   $(MOUNT_DIR)/d_part.c
	$(DO_CC)

$(BUILDDIR)/obj/d_polyse.o : $(MOUNT_DIR)/d_polyse.c
	$(DO_CC)

$(BUILDDIR)/obj/d_scan.o :   $(MOUNT_DIR)/d_scan.c
	$(DO_CC)

$(BUILDDIR)/obj/d_sky.o :    $(MOUNT_DIR)/d_sky.c
	$(DO_CC)

$(BUILDDIR)/obj/d_sprite.o : $(MOUNT_DIR)/d_sprite.c
	$(DO_CC)

$(BUILDDIR)/obj/d_surf.o :   $(MOUNT_DIR)/d_surf.c
	$(DO_CC)

$(BUILDDIR)/obj/d_vars.o :   $(MOUNT_DIR)/d_vars.c
	$(DO_CC)

$(BUILDDIR)/obj/d_zpoint.o : $(MOUNT_DIR)/d_zpoint.c
	$(DO_CC)

$(BUILDDIR)/obj/host.o :     $(MOUNT_DIR)/host.c
	$(DO_CC)

$(BUILDDIR)/obj/host_cmd.o : $(MOUNT_DIR)/host_cmd.c
	$(DO_CC)

$(BUILDDIR)/obj/keys.o :     $(MOUNT_DIR)/keys.c
	$(DO_CC)

$(BUILDDIR)/obj/menu.o :     $(MOUNT_DIR)/menu.c
	$(DO_CC)

$(BUILDDIR)/obj/mathlib.o :  $(MOUNT_DIR)/mathlib.c
	$(DO_CC)

$(BUILDDIR)/obj/model.o :    $(MOUNT_DIR)/model.c
	$(DO_CC)

$(BUILDDIR)/obj/net_loop.o : $(MOUNT_DIR)/net_loop.c
	$(DO_CC)

$(BUILDDIR)/obj/net_main.o : $(MOUNT_DIR)/net_main.c
	$(DO_CC)

$(BUILDDIR)/obj/net_atari.o :  $(MOUNT_DIR)/net_atari.c
	$(DO_CC)

$(BUILDDIR)/obj/nonintel.o : $(MOUNT_DIR)/nonintel.c
	$(DO_CC)

$(BUILDDIR)/obj/pr_cmds.o :  $(MOUNT_DIR)/pr_cmds.c
	$(DO_CC)

$(BUILDDIR)/obj/pr_edict.o : $(MOUNT_DIR)/pr_edict.c
	$(DO_CC)

$(BUILDDIR)/obj/pr_exec.o :  $(MOUNT_DIR)/pr_exec.c
	$(DO_CC)

$(BUILDDIR)/obj/r_aclip.o :  $(MOUNT_DIR)/r_aclip.c
	$(DO_CC)

$(BUILDDIR)/obj/r_alias.o :  $(MOUNT_DIR)/r_alias.c
	$(DO_CC)

$(BUILDDIR)/obj/r_bsp.o :    $(MOUNT_DIR)/r_bsp.c
	$(DO_CC)

$(BUILDDIR)/obj/r_light.o :  $(MOUNT_DIR)/r_light.c
	$(DO_CC)

$(BUILDDIR)/obj/r_draw.o :   $(MOUNT_DIR)/r_draw.c
	$(DO_CC)

$(BUILDDIR)/obj/r_efrag.o :  $(MOUNT_DIR)/r_efrag.c
	$(DO_CC)

$(BUILDDIR)/obj/r_edge.o :   $(MOUNT_DIR)/r_edge.c
	$(DO_CC)

$(BUILDDIR)/obj/r_misc.o :   $(MOUNT_DIR)/r_misc.c
	$(DO_CC)

$(BUILDDIR)/obj/r_main.o :   $(MOUNT_DIR)/r_main.c
	$(DO_CC)

$(BUILDDIR)/obj/r_sky.o :    $(MOUNT_DIR)/r_sky.c
	$(DO_CC)

$(BUILDDIR)/obj/r_sprite.o : $(MOUNT_DIR)/r_sprite.c
	$(DO_CC)

$(BUILDDIR)/obj/r_surf.o :   $(MOUNT_DIR)/r_surf.c
	$(DO_CC)

$(BUILDDIR)/obj/r_part.o :   $(MOUNT_DIR)/r_part.c
	$(DO_CC)

$(BUILDDIR)/obj/r_vars.o :   $(MOUNT_DIR)/r_vars.c
	$(DO_CC)

$(BUILDDIR)/obj/screen.o :   $(MOUNT_DIR)/screen.c
	$(DO_CC)

$(BUILDDIR)/obj/sbar.o :     $(MOUNT_DIR)/sbar.c
	$(DO_CC)

$(BUILDDIR)/obj/sv_main.o :  $(MOUNT_DIR)/sv_main.c
	$(DO_CC)

$(BUILDDIR)/obj/sv_phys.o :  $(MOUNT_DIR)/sv_phys.c
	$(DO_CC)

$(BUILDDIR)/obj/sv_move.o :  $(MOUNT_DIR)/sv_move.c
	$(DO_CC)

$(BUILDDIR)/obj/sv_user.o :  $(MOUNT_DIR)/sv_user.c
	$(DO_CC)

$(BUILDDIR)/obj/zone.o	:   $(MOUNT_DIR)/zone.c
	$(DO_CC)

$(BUILDDIR)/obj/view.o	:   $(MOUNT_DIR)/view.c
	$(DO_CC)

$(BUILDDIR)/obj/wad.o :      $(MOUNT_DIR)/wad.c
	$(DO_CC)

$(BUILDDIR)/obj/world.o :    $(MOUNT_DIR)/world.c
	$(DO_CC)

$(BUILDDIR)/obj/cd_atari.o : $(MOUNT_DIR)/cd_atari.c
	$(DO_CC)

$(BUILDDIR)/obj/sys_atari.o :$(MOUNT_DIR)/sys_atari.c
	$(DO_CC)

$(BUILDDIR)/obj/vid_atari.o:$(MOUNT_DIR)/vid_atari.c
	$(DO_CC)

$(BUILDDIR)/obj/snd_dma.o :  $(MOUNT_DIR)/snd_dma.c
	$(DO_CC)

$(BUILDDIR)/obj/snd_mem.o :  $(MOUNT_DIR)/snd_mem.c
	$(DO_CC)

$(BUILDDIR)/obj/snd_mix.o :  $(MOUNT_DIR)/snd_mix.c
	$(DO_CC)

$(BUILDDIR)/obj/snd_atari.o :$(MOUNT_DIR)/snd_atari.c
	$(DO_CC)

$(BUILDDIR)/obj/in_atari.o :$(MOUNT_DIR)/in_atari.c
	$(DO_CC)
	
$(BUILDDIR)/obj/keys_atari_asm.o : $(MOUNT_DIR)/keys_atari_asm.s
	$(DO_AS)
	
$(BUILDDIR)/obj/vid_atari_asm.o : $(MOUNT_DIR)/vid_atari_asm.s
	$(DO_AS)
	
$(BUILDDIR)/obj/snd_atari_asm.o : $(MOUNT_DIR)/snd_atari_asm.s quakedef68k.i
	$(DO_AS)

#####

$(BUILDDIR)/obj/mathlib68k.o:           $(MOUNT_DIR)/mathlib68k.s quakedef68k.i
	$(DO_AS)

$(BUILDDIR)/obj/common68k.o:            $(MOUNT_DIR)/common68k.s
	$(DO_AS)

$(BUILDDIR)/obj/d_sky68k.o:             $(MOUNT_DIR)/d_sky68k.s quakedef68k.i
	$(DO_AS)

$(BUILDDIR)/obj/d_polyset68k.o:         $(MOUNT_DIR)/d_polyset68k.s quakedef68k.i
	$(DO_AS)

$(BUILDDIR)/obj/d_part68k.o:            $(MOUNT_DIR)/d_part68k.s quakedef68k.i
	$(DO_AS)

$(BUILDDIR)/obj/d_edge68k.o:            $(MOUNT_DIR)/d_edge68k.s quakedef68k.i
	$(DO_AS)

$(BUILDDIR)/obj/d_scan68k.o:            $(MOUNT_DIR)/d_scan68k.s quakedef68k.i
	$(DO_AS)

$(BUILDDIR)/obj/r_edge68k.o:            $(MOUNT_DIR)/r_edge68k.s quakedef68k.i
	$(DO_AS)

$(BUILDDIR)/obj/r_sky68k.o:             $(MOUNT_DIR)/r_sky68k.s quakedef68k.i
	$(DO_AS)

$(BUILDDIR)/obj/r_light68k.o:           $(MOUNT_DIR)/r_light68k.s quakedef68k.i
	$(DO_AS)

$(BUILDDIR)/obj/r_alias68k.o:           $(MOUNT_DIR)/r_alias68k.s quakedef68k.i
	$(DO_AS)

$(BUILDDIR)/obj/r_aclip68k.o:           $(MOUNT_DIR)/r_aclip68k.s quakedef68k.i
	$(DO_AS)

$(BUILDDIR)/obj/r_surf68k.o:            $(MOUNT_DIR)/r_surf68k.s quakedef68k.i
	$(DO_AS)

$(BUILDDIR)/obj/r_misc68k.o:            $(MOUNT_DIR)/r_misc68k.s quakedef68k.i
	$(DO_AS)

$(BUILDDIR)/obj/r_draw68k.o:            $(MOUNT_DIR)/r_draw68k.s quakedef68k.i
	$(DO_AS)

$(BUILDDIR)/obj/r_bsp68k.o:             $(MOUNT_DIR)/r_bsp68k.s sincos.bin quakedef68k.i
	$(DO_AS)

$(BUILDDIR)/obj/d_sprite68k.o:          $(MOUNT_DIR)/d_sprite68k.s
	$(DO_AS)

#####
	

$(MOUNT_DIR)/mathlib68k.s:           $(M68KASM_DIR)/mathlib68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/common68k.s:            $(M68KASM_DIR)/common68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/d_sky68k.s:             $(M68KASM_DIR)/d_sky68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/d_polyset68k.s:         $(M68KASM_DIR)/d_polyset68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/d_part68k.s:            $(M68KASM_DIR)/d_part68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/d_edge68k.s:            $(M68KASM_DIR)/d_edge68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/d_scan68k.s:            $(M68KASM_DIR)/d_scan68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/r_edge68k.s:            $(M68KASM_DIR)/r_edge68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/r_sky68k.s:             $(M68KASM_DIR)/r_sky68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/r_light68k.s:           $(M68KASM_DIR)/r_light68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/r_alias68k.s:           $(M68KASM_DIR)/r_alias68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/r_aclip68k.s:           $(M68KASM_DIR)/r_aclip68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/r_surf68k.s:            $(M68KASM_DIR)/r_surf68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/r_misc68k.s:            $(M68KASM_DIR)/r_misc68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/r_draw68k.s:            $(M68KASM_DIR)/r_draw68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/r_bsp68k.s:             $(M68KASM_DIR)/r_bsp68k.s
	$(DO_DEVPAC2GAS)

$(MOUNT_DIR)/d_sprite68k.s:          $(M68KASM_DIR)/d_sprite68k.s
	$(DO_DEVPAC2GAS)

#############################################################################
# MISC
#############################################################################

clean: clean-debug clean-release

clean-debug:
	$(MAKE) clean2 BUILDDIR=$(BUILD_DEBUG_DIR) CFLAGS="$(DEBUG_CFLAGS)"

clean-release:
	$(MAKE) clean2 BUILDDIR=$(BUILD_RELEASE_DIR) CFLAGS="$(DEBUG_CFLAGS)"

clean2:
	-rm -f $(QUAKE_OBJS) $(QUAKE_M68K_OBJS)
	-rm *.BAK *.bak
	-rm *68k.s
	-rm gendefs gendefs.c genasmheaders quakedef68k.i
	-rm $(BUILDDIR)/quake.ttp
	-rm quake.ttp
