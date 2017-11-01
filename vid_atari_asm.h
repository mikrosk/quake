#ifndef _VID_ATARI_ASM_H_
#define _VID_ATARI_ASM_H_

extern void video_atari_init( char* screen );
extern void video_atari_shutdown( void );
extern void video_atari_set_palette( char* palette );
extern void video_atari_c2p( char* buffer, char* screen, int size );
extern void video_atari_set_320x200( void );

#endif
