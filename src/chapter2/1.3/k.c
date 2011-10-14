typedef char byte;
typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned int u32;

asm(".code16gcc\n");

void write_mem8(u32 addr, u8 data); // assembly function.
void DispAL();
void DispAX();

//void kmain( void* mbd, unsigned int magic )
void kmain(void)
{
#if 1
  int i=0;
  u8 ch='A';

  for (i=0 ; i < 160 ; i+=2)
  {
    write_mem8(i, ch++);
    if (ch > 'Z')
      ch='A';
  }
#else
  write_mem8(160*2, 'N');
#endif 
//  u8 b[10];
  
//  b[0]='Z';
  //extern u8 *BootMessage;

  //asm("mov %ss, %ax");
  //DispAX();
  //asm("mov %esp, %eax");
  //DispAX();
  //asm("mov %esp, %eax");
  //DispAX();

  //*BootMessage='A';
  #if 0
  write_mem8(160*2, 'N');
  write_mem8(160*3, 'Z');
  #endif
}
