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

all: boot.img

boot.img: boot.bin
	@dd if=boot.bin of=boot.img bs=512 count=1
	@dd if=/dev/zero of=boot.img skip=1 seek=1 bs=512 count=2879

boot.bin: boot.elf
	@$(OBJCOPY) -R .pdr -R .comment -R.note -S -O binary boot.elf boot.bin

boot.elf: boot.o
	$(LD) boot.o -o boot.elf -e c -Tsolrex_x86.ld

boot.o: boot.S
	$(CC) -c boot.S 

copy: boot.img

clean: 
	@rm -f boot.o boot.elf boot.bin

distclean: clean
	@rm -f boot.img

release: clean
	@mv boot.img solrex.img
