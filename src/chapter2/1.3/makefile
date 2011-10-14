# chapter2/1/Makefile
#
# Author: Wenbo Yang <solrex@gmail.com> <http://solrex.cn>
#
# This file is part of the source code of book "Write Your Own OS with Free
# and Open Source Software". Homepage @ <http://share.solrex.cn/WriteOS/>.
#
# This file is licensed under the GNU General Public License; either
# version 3 of the License, or (at your option) any later version. 

CC=gcc
LD=ld
LDFILE=solrex_x86.ld
OBJCOPY=objcopy

WF=bc.bin

all: boot.img

boot.img: $(WF)
	dd if=$(WF) of=boot.img bs=512 count=1
	dd if=/dev/zero of=boot.img skip=1 seek=1 bs=512 count=2879

boot.bin: boot.elf
	$(OBJCOPY) -R .pdr -R .comment -R.note -S -O binary boot.elf $@

#boot.elf: boot.o k.o
boot.elf: boot.o
	$(LD) -o boot.elf -e c -Tsolrex_x86.ld $^

k.o: k.c
	gcc -Wall -ffreestanding  -Wextra -Werror -nostdlib -nostartfiles -nodefaultlibs -c $<

boot.o: boot.s
	$(CC) -c $<

bc.com: boot_mix_c.com.elf
	$(OBJCOPY) -R .pdr -R .comment -R.note -S -O binary $< $@

bc.bin: boot_mix_c.elf
	$(OBJCOPY) -R .pdr -R .comment -R.note -S -O binary $< $@
boot_mix_c.elf: boot_mix_c.o k.o
	$(LD) -o boot_mix_c.elf -Tsolrex_x86.ld $^
boot_mix_c.com.elf: boot_mix_c.o k.o
	$(LD) -o $@ -Tsolrex_x86_dos.ld $^
boot_mix_c.o: boot_mix_c.s
	$(CC) -c $<

copy: boot.img

clean: 
	rm -f *.o *.elf *.bin

distclean: clean
	@rm -f boot.img

release: clean
	@mv boot.img solrex.img
