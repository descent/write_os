typedef char byte;
typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned int u32;

void write_mem8(u32 addr, u8 data); // assembly function.

#define BASE 160*6

static const u8 str[]="I am c function";

//void kmain( void* mbd, unsigned int magic )
void kmain(void)
{
  int i=0;

  for (i=0 ; str[i]!=0 ; ++i)
    write_mem8(BASE+i*2, str[i]);

#ifdef C_ACCESS_POINTER
  u8 *vaddr=(u8 *)(0xb8000+160);

  *vaddr='E';
#endif

#if 0
   void DispAL(void);
   mbd=0;
   magic=0;
#if 0
   if ( magic != 0x2BADB002 )
   {
      /* Something went not according to specs. Print an error */
      /* message and halt, but do *not* rely on the multiboot */
      /* data structure. */
   }
#endif 
   /* You could either use multiboot.h */
   /* (http://www.gnu.org/software/grub/manual/multiboot/multiboot.html#multiboot_002eh) */
   /* or do your offsets yourself. The following is merely an example. */ 
   //char * boot_loader_name =(char*) ((long*)mbd)[16];
 
   /* Print a letter to screen to see everything is working: */
   unsigned char *videoram = (unsigned char *) 0xb8000;
   videoram[160] = 65; /* character 'A' */
   videoram[161] = 0x07; /* light grey (7) on black (0). */
   asm("movb $0xab, %al");
   //DispAL();
#endif
  //asm("movb $0xab, %al");
  //write_mem8(160*2+2, 'N');
   //asm("movb $0xab, %al");

}
