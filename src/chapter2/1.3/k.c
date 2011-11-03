typedef char byte;
typedef unsigned char u8;
typedef unsigned short int u16;
typedef unsigned int u32;

asm(".code16gcc\n");

void write_mem8(u32 addr, u8 data); // assembly function.
void DispAL();
void DispAX();

void hex2char(u8 h, u8 *ch)
{
  // high 4 bit
  //ch[1] 
  if (((h >> 4)& 0x0f) >= 0xa) // a-f
  {
    ch[1] = ((h >> 4) & 0x0f) + 0x57;
  }
  else // 0-9
  {
    ch[1] = ((h >> 4) & 0x0f) + 0x30;
  }

  // low 4 bit
  if ((h & 0x0f) >= 0xa) // a-f
  {
    ch[0] = (h & 0x0f) + 0x57;
  }
  else // 0-9
  {
    ch[0] = (h & 0x0f) + 0x30;
  }

}


//void kmain( void* mbd, unsigned int magic )
void kmain(void)
{
#if 0
  int i=0;
  u8 ch='A';

  for (i=0 ; i < 160 ; i+=2)
  {
    write_mem8(i, ch++);
    if (ch > 'Z')
      ch='A';
  }
#else
  //write_mem8(160*2, 'N');
  u8 ch[2]={'a','b'}; // 97, 98

  hex2char(0x9a, ch);
  write_mem8(160*2, ch[1]); // high 4 bits
  write_mem8(160*2+2, ch[0]); // low 4 bits


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
