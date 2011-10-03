// ref: http://bos.asmhackers.net/docs/vga_without_bios/docs/mode%2013h%20without%20using%20bios.htm

//
// vga mode switcher by Jonas Berlin -98 <jberlin@cc.hut.fi>
//


typedef char byte;
typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned short word;
typedef unsigned long dword;

u8 io_in8(u16 port)
{
#if 0
  u8 data;

  // in $0x92, %al
  asm("inb $0x92, %0"
      : "=a"(data)
      : );
      #endif


// ref: http://wiki.osdev.org/Inline_Assembly/Examples
  u8 ret;
  asm volatile( "inb %1, %0"
               : "=a"(ret) : "Nd"(port) );
  return ret;
}

#if 0
// ref: http://wiki.osdev.org/Inline_Assembly/Examples
static inline
void outb( unsigned short port, unsigned char val )
{
    asm volatile( "outb %0, %1"
                      : : "a"(val), "Nd"(port) );
		      }
#endif

void io_out8(u16 port, u8 data)
{
//    outb    %al, $0x92
// N: "N" : Constant in range 0 to 255 (for out instruction).
// ref: http://www.ibiblio.org/gferg/ldp/GCC-Inline-Assembly-HOWTO.html#s6
  asm volatile("outb %0, %1"
               : : "a"(data), "Nd"(port) );
}

void io_out16(u16 port, u16 data)
{
  asm volatile("outw %0, %1"
               : : "a"(data), "Nd"(port) );
}

#define SZ(x) (sizeof(x)/sizeof(x[0]))


// misc out (3c2h) value for various modes

#define R_COM  0x63 // "common" bits

#define R_W256 0x00
#define R_W320 0x00
#define R_W360 0x04
#define R_W376 0x04
#define R_W400 0x04

#define R_H200 0x00
#define R_H224 0x80
#define R_H240 0x80
#define R_H256 0x80
#define R_H270 0x80
#define R_H300 0x80
#define R_H360 0x00
#define R_H400 0x00
#define R_H480 0x80
#define R_H564 0x80
#define R_H600 0x80


static const byte hor_regs [] = { 0x0,  0x1,  0x2,  0x3,  0x4, 
0x5,  0x13 };

static const byte width_256[] = { 0x5f, 0x3f, 0x40, 0x82, 0x4a,
0x9a, 0x20 };
static const byte width_320[] = { 0x5f, 0x4f, 0x50, 0x82, 0x54,
0x80, 0x28 };
static const byte width_360[] = { 0x6b, 0x59, 0x5a, 0x8e, 0x5e,
0x8a, 0x2d };
static const byte width_376[] = { 0x6e, 0x5d, 0x5e, 0x91, 0x62,
0x8f, 0x2f };
static const byte width_400[] = { 0x70, 0x63, 0x64, 0x92, 0x65,
0x82, 0x32 };

static const byte ver_regs  [] = { 0x6,  0x7,  0x9,  0x10, 0x11,
0x12, 0x15, 0x16 };

static const byte height_200[] = { 0xbf, 0x1f, 0x41, 0x9c, 0x8e,
0x8f, 0x96, 0xb9 };
static const byte height_224[] = { 0x0b, 0x3e, 0x41, 0xda, 0x9c,
0xbf, 0xc7, 0x04 };
static const byte height_240[] = { 0x0d, 0x3e, 0x41, 0xea, 0xac,
0xdf, 0xe7, 0x06 };
static const byte height_256[] = { 0x23, 0xb2, 0x61, 0x0a, 0xac,
0xff, 0x07, 0x1a };
static const byte height_270[] = { 0x30, 0xf0, 0x61, 0x20, 0xa9,
0x1b, 0x1f, 0x2f };
static const byte height_300[] = { 0x70, 0xf0, 0x61, 0x5b, 0x8c,
0x57, 0x58, 0x70 };
static const byte height_360[] = { 0xbf, 0x1f, 0x40, 0x88, 0x85,
0x67, 0x6d, 0xba };
static const byte height_400[] = { 0xbf, 0x1f, 0x40, 0x9c, 0x8e,
0x8f, 0x96, 0xb9 };
static const byte height_480[] = { 0x0d, 0x3e, 0x40, 0xea, 0xac,
0xdf, 0xe7, 0x06 };
static const byte height_564[] = { 0x62, 0xf0, 0x60, 0x37, 0x89,
0x33, 0x3c, 0x5c };
static const byte height_600[] = { 0x70, 0xf0, 0x60, 0x5b, 0x8c,
0x57, 0x58, 0x70 };

// the chain4 parameter should be 1 for normal 13h-type mode, but 
// only allows 320x200 256x200, 256x240 and 256x256 because you
// can only access the first 64kb

// if chain4 is 0, then plane mode is used (tweaked modes), and
// you'll need to switch planes to access the whole screen but
// that allows you using any resolution, up to 400x600

int init_graph_vga(int width, int height,int chain4) 
  // returns 1=ok, 0=fail
{
   const byte *w,*h;
   byte val;
   int a;

#if 1
   width=320;
   height=200;
   chain4=1;
#endif

   switch(width) {
      case 256: w=width_256; val=R_COM+R_W256; break;
      case 320: w=width_320; val=R_COM+R_W320; break;
      case 360: w=width_360; val=R_COM+R_W360; break;
      case 376: w=width_376; val=R_COM+R_W376; break;
      case 400: w=width_400; val=R_COM+R_W400; break;
      default: return 0; // fail
   }
   switch(height) {
      case 200: h=height_200; val|=R_H200; break;
      case 224: h=height_224; val|=R_H224; break;
      case 240: h=height_240; val|=R_H240; break;
      case 256: h=height_256; val|=R_H256; break;
      case 270: h=height_270; val|=R_H270; break;
      case 300: h=height_300; val|=R_H300; break;
      case 360: h=height_360; val|=R_H360; break;
      case 400: h=height_400; val|=R_H400; break;
      case 480: h=height_480; val|=R_H480; break;
      case 564: h=height_564; val|=R_H564; break;
      case 600: h=height_600; val|=R_H600; break;
      default: return 0; // fail
   }

   // chain4 not available if mode takes over 64k

   if(chain4 && (long)width*(long)height>65536L) return 0; 

   // here goes the actual modeswitch

   io_out8(0x3c2,val);
   io_out16(0x3d4,0x0e11); // enable regs 0-7

   for(a=0;a<SZ(hor_regs);++a) 
      io_out16(0x3d4,(word)((w[a]<<8)+hor_regs[a]));
   for(a=0;a<SZ(ver_regs);++a)
      io_out16(0x3d4,(word)((h[a]<<8)+ver_regs[a]));

   io_out16(0x3d4,0x0008); // vert.panning = 0

   if(chain4) {
      io_out16(0x3d4,0x4014);
      io_out16(0x3d4,0xa317);
      io_out16(0x3c4,0x0e04);
   } else {
      io_out16(0x3d4,0x0014);
      io_out16(0x3d4,0xe317);
      io_out16(0x3c4,0x0604);
   }

   io_out16(0x3c4,0x0101);
   io_out16(0x3c4,0x0f02); // enable writing to all planes
   io_out16(0x3ce,0x4005); // 256color mode
   io_out16(0x3ce,0x0506); // graph mode & A000-AFFF

   io_in8(0x3da);
   io_out8(0x3c0,0x30); io_out8(0x3c0,0x41);
   io_out8(0x3c0,0x33); io_out8(0x3c0,0x00);

   for(a=0;a<16;a++) {    // ega pal
      io_out8(0x3c0,(byte)a); 
      io_out8(0x3c0,(byte)a); 
   } 
   
   io_out8(0x3c0, 0x20); // enable video

   return 1;
}


// ref: 30 天打造 OS, projects/04_day sample code
void init_palette(void)
{
  void set_palette(int start, int end, unsigned char *rgb);

	static unsigned char table_rgb[16 * 3] = {
		0x00, 0x00, 0x00,	/*  0: */
		0xff, 0x00, 0x00,	/*  1:¾é¢Ô */
		0x00, 0xff, 0x00,	/*  2:¾é¢Î */
		0xff, 0xff, 0x00,	/*  3:¾é¢©F */
		0x00, 0x00, 0xff,	/*  4:¾é¢Â */
		0xff, 0x00, 0xff,	/*  5:¾é¢ */
		0x00, 0xff, 0xff,	/*  6:¾é¢F */
		0xff, 0xff, 0xff,	/*  7: */
		0xc6, 0xc6, 0xc6,	/*  8:¾é¢DF */
		0x84, 0x00, 0x00,	/*  9:Ã¢Ô */
		0x00, 0x84, 0x00,	/* 10:Ã¢Î */
		0x84, 0x84, 0x00,	/* 11:Ã¢©F */
		0x00, 0x00, 0x84,	/* 12:Ã¢Â */
		0x84, 0x00, 0x84,	/* 13:Ã¢ */
		0x00, 0x84, 0x84,	/* 14:Ã¢F */
		0x84, 0x84, 0x84	/* 15:Ã¢DF */
	};
	set_palette(0, 15, table_rgb);
	return;

	/* static char ½ßÍAf[^Éµ©g¦È¢¯ÇDB½ß */
}

void set_palette(int start, int end, unsigned char *rgb)
{
	int i, eflags;
	//eflags = io_load_eflags();	/* èÝÂtOÌlðL^·é */
	//io_cli(); 					/* ÂtOð0ÉµÄèÝÖ~É·é */
	io_out8(0x03c8, start);
	for (i = start; i <= end; i++) {
		io_out8(0x03c9, rgb[0] / 4);
		io_out8(0x03c9, rgb[1] / 4);
		io_out8(0x03c9, rgb[2] / 4);
		rgb += 3;
	}
	//io_store_eflags(eflags);	/* èÝÂtOð³Éß· */
	return;
}


/*
 *  Hope you get what you want. To put on normal mode 13h, use
 *  init_graph_vga(320,200,1);
*/
#if 0
int main(int argc, char **argv)
{
  init_graph_vga(320,200,1);
}
#endif
int vga_test()
{
  int i=0;
  void write_mem8(int addr, u8 data);

  init_graph_vga(300, 200, 1);
  for (i=0xa0000; i <= 0xaffff; ++i)
  {
    write_mem8(i, 15);
  }


}
