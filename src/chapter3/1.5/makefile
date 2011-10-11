# chapter3/1/Makefile
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
OBJCOPY=objcopy

CFLAGS=-c
TRIM_FLAGS=-R .pdr -R .comment -R.note -S -O binary

LDFILE_BOOT=solrex_x86_boot.ld
LDFILE_DOS=solrex_x86_dos.ld
#LDFILE_DOS=c.ld
LDFLAGS_BOOT=-T$(LDFILE_BOOT)
LDFLAGS_DOS=-T$(LDFILE_DOS)

5M_mem_rw_mix_c_vga.com: 5M_mem_rw_mix_c_vga.o switch_vga_mode.o
	$(LD) -o 5M_mem_rw_mix_c_vga.elf $(LDFLAGS_DOS) $^
	$(OBJCOPY) $(TRIM_FLAGS) 5M_mem_rw_mix_c_vga.elf $@
5M_mem_rw_mix_c_vga.o: 5M_mem_rw_mix_c_vga.S config.h
	$(CC) $(CFLAGS) $<

switch_vga_mode.com: switch_vga_mode.o
	$(LD) -o switch_vga_mode.elf $(LDFLAGS_DOS) $^
	$(OBJCOPY) $(TRIM_FLAGS) switch_vga_mode.elf $@
switch_vga_mode.o: switch_vga_mode.c config.h
	gcc -nostdlib -nostartfiles -nodefaultlibs -c $<
ldt.com: ldt.o 
	$(LD) -o ldt.elf $(LDFLAGS_DOS) $^
	$(OBJCOPY) $(TRIM_FLAGS) ldt.elf $@
ldt.o: ldt.S
	$(CC) $(CFLAGS) $<

#5M_mem_rw.com: 5M_mem_rw.o k.o
5Mrw.com: 5M_mem_rw.o 
	$(LD) -o 5M_mem_rw.elf $(LDFLAGS_DOS) $^
	$(OBJCOPY) $(TRIM_FLAGS) 5M_mem_rw.elf $@

5M_mem_rw.o: 5M_mem_rw.S
	$(CC) $(CFLAGS) $<

5mc.com: 5M_mem_rw_mix_c.o k.o 
	$(LD) -o 5mc.elf $(LDFLAGS_DOS) $^
	$(OBJCOPY) $(TRIM_FLAGS) 5mc.elf $@

5M_mem_rw_mix_c.o: 5M_mem_rw_mix_c.S
	$(CC) $(CFLAGS) $<

k.o: k.c
	gcc -Wall -Wextra -Werror -nostdlib -nostartfiles -nodefaultlibs -c $<

LOADER.BIN: loader.S
	$(CC) $(CFLAGS) loader.S
	$(LD) loader.o -o loader.elf $(LDFLAGS_DOS)
	$(OBJCOPY) $(TRIM_FLAGS) loader.elf $@

boot.img: boot.bin
	@dd if=boot.bin of=boot.img bs=512 count=1
	@dd if=/dev/zero of=boot.img skip=1 seek=1 bs=512 count=2879

# You must have the authority to do mount, or you must use "su root" or
# "sudo" command to do "make copy"
copy: boot.img LOADER.BIN
	@mkdir -p /tmp/floppy;\
	mount -o loop boot.img /tmp/floppy/ -o fat=12;\
	cp LOADER.BIN /tmp/floppy/;\
	umount /tmp/floppy/;\
	rm -rf /tmp/floppy/;

clean: 
	rm -f *.o *.elf *.bin *.BIN *.com
	#@rm -f *.o *.elf *.bin *.BIN

distclean: clean
	@rm -f boot.img

release: clean
	@mv boot.img solrex.img
