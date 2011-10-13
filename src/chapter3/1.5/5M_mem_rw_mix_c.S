/*
   ref: Orange'S：一个操作系统的实现
   do the 5M memory r/w
   link with C code, but not yet ok.
 */
/* chapter3/1/loader.S

   Author: Wenbo Yang <solrex@gmail.com> <http://solrex.cn>

   This file is part of the source code of book "Write Your Own OS with Free
   and Open Source Software". Homepage @ <http://share.solrex.cn/WriteOS/>.

   This file is licensed under the GNU General Public License; either
   version 3 of the License, or (at your option) any later version. */

#include "pm.h"

.code16
.text
    jmp LABEL_BEGIN     /* jump over the .data section. */

/* NOTE! Wenbo-20080512: Actually here we put the normal .data section into
   the .code section. For application SW, it is not allowed. However, we are
   writing an OS. That is OK. Because there is no OS to complain about
   that behavior. :) */

/* Global Descriptor Table */
LABEL_GDT:          Descriptor  0,                        0, 0
LABEL_DESC_NORMAL:  Descriptor  0,         0xffff, DA_DRW    # Normal descriptor is for back to real mode.
#LABEL_DESC_CODE32:  Descriptor  0,       (SegCode32Len - 1), (DA_C + DA_32)
LABEL_DESC_CODE32:  Descriptor  0,       0xfffff, (DA_C + DA_32)
LABEL_DESC_CODE16:  Descriptor    0,         0xffff, DA_C      # 非一致程式碼段, 16
LABEL_DESC_DATA:   Descriptor    0,      DataLen-1, DA_DRW    # Data
LABEL_DESC_STACK:  Descriptor    0,     TopOfStack, DA_DRWA+DA_32 # Stack, 32 位
LABEL_DESC_TEST: Descriptor 0x500000, 0xffff, DA_DRW
LABEL_DESC_VIDEO:   Descriptor  0xB8000, 0xffff, DA_DRW
LABEL_DESC_TEST_DATA:   Descriptor    0,      0xffffffff, DA_DRW    # Data


.set GdtLen, (. - LABEL_GDT)  /* GDT Length */

GdtPtr: .2byte  (GdtLen - 1)  /* GDT Limit */
        .4byte  0             /* GDT Base */

/* GDT Selector */
.set SelectorNormal, (LABEL_DESC_NORMAL - LABEL_GDT)    
.set    SelectorCode32, (LABEL_DESC_CODE32 - LABEL_GDT)
.set SelectorCode16, (LABEL_DESC_CODE16 - LABEL_GDT)
.set SelectorData, (LABEL_DESC_DATA         - LABEL_GDT)
.set SelectorStack, (LABEL_DESC_STACK        - LABEL_GDT)
.set SelectorTest, (LABEL_DESC_TEST         - LABEL_GDT)
.set    SelectorVideo,  (LABEL_DESC_VIDEO  - LABEL_GDT)
.set    SelectorTestData,  (LABEL_DESC_TEST_DATA  - LABEL_GDT)

#[SECTION .data1]         ; 資料段
#ALIGN   32
#[BITS   32]
LABEL_DATA:
SPValueInRealMode: .2byte 0x1234
# string
PMMessage:              .ascii      "In Protect Mode now. ^-^\0"   # 在保護模式中顯示
#.set    OffsetPMMessage, (PMMessage - LABEL_DATA)
.set    OffsetPMMessage, (PMMessage - LABEL_DATA)
#StrTest:                .ascii "B\0"
StrTest:                .ascii "ABCDEFGHIJKLMNOPQRSTUVWXYZ\0"
#OffsetStrTest           equ     StrTest - $$
.set OffsetStrTest , (StrTest - LABEL_DATA)
#DataLen                 equ     $ - LABEL_DATA
	#.section	.rodata
	#.align 4
	#.type	chor_regs, @object
	#.size	chor_regs, 8
chor_regs:
	.long	320
	.long	0x5a # Z
   var1:
      .int 40
   var2:
      .int 20
   var3:
      .int 30

#.set DataLen, .  - LABEL_DATA 
.set DataLen, .  - LABEL_BEGIN
/* 32-bit global stack segment. */
LABEL_STACK:
.space  512, 0x12
.set    TopOfStack, (. - LABEL_STACK - 1)

# END of [SECTION .data1]

/* Program starts here. */
LABEL_BEGIN:
    mov     %cs, %ax    /* Move code segment address(CS) to data segment */
    mov     %ax, %ds    /* register(DS), ES and SS. Because we have      */
    mov     %ax, %es    /* embedded .data section into .code section in  */
    mov     %ax, %ss    /* the start(mentioned in the NOTE above).       */

    movw     $0x100, %sp
    nop
    movw %ax, (LABEL_GO_BACK_TO_REAL+3) # modify segment value, indexed memory mode, ref  professional aeesmbly language p 102.

    /* Initialize 16-bits code segment descriptor. */
    xor     %eax, %eax
    mov     %cs, %ax
    shl     $4, %eax
    addl    $(LABEL_SEG_CODE16), %eax
    movw    %ax, (LABEL_DESC_CODE16 + 2)
    shr     $16, %eax
    movb    %al, (LABEL_DESC_CODE16 + 4)
    movb    %ah, (LABEL_DESC_CODE16 + 7)

    /* Initialize 32-bits code segment descriptor. */
    xor     %eax, %eax
    mov     %cs, %ax
    shl     $4, %eax
    addl    $(LABEL_SEG_CODE32), %eax
    movw    %ax, (LABEL_DESC_CODE32 + 2)
    shr     $16, %eax
    movb    %al, (LABEL_DESC_CODE32 + 4)
    movb    %ah, (LABEL_DESC_CODE32 + 7)

	# initialize data segment descriptor
#	xor	%eax, %eax
#	mov	%ds, %ax
#	shl	$4, %eax
#	addl	$(LABEL_DATA), %eax
#	movw	%ax, (LABEL_DESC_DATA + 2)
#	shr	$16, %eax
#	movb	%al, (LABEL_DESC_DATA + 4)
#	movb	%ah, (LABEL_DESC_DATA + 7)

	# initialize data segment descriptor
        # for c runtime environment, base changes from %cs:LABEL_DATA to %cs:0
	xor	%eax, %eax
	mov	%ds, %ax
	shl	$4, %eax
	addl	$0, %eax
#	subl	$0x100, %eax
	movw	%ax, (LABEL_DESC_DATA + 2)
	shr	$16, %eax
	movb	%al, (LABEL_DESC_DATA + 4)
	movb	%ah, (LABEL_DESC_DATA + 7)

	# initialize stack segment descriptor
	xor	%eax, %eax
	mov	%ds, %ax
	shl	$4, %eax
	addl	$(LABEL_STACK), %eax
	movw	%ax, (LABEL_DESC_STACK + 2)
	shr	$16, %eax
	movb	%al, (LABEL_DESC_STACK + 4)
	movb	%ah, (LABEL_DESC_STACK + 7)

    /* Prepared for loading GDTR */
    xor     %eax, %eax
    mov     %ds, %ax
    shl     $4, %eax
    add     $(LABEL_GDT), %eax      /* eax <- gdt base*/
    movl    %eax, (GdtPtr + 2)

    /* Load GDTR(Global Descriptor Table Register) */
    lgdtw   GdtPtr

    /* Clear Interrupt Flags */
    cli

    /* Open A20 line. */
    inb     $0x92, %al
    orb     $0b00000010, %al
    outb    %al, $0x92

    /* Enable protect mode, PE bit of CR0. */
    movl    %cr0, %eax
    orl     $1, %eax
    movl    %eax, %cr0

    /* Mixed-Size Jump. */
    ljmp $SelectorCode32, $0       /* Thanks to earthengine@gmail, I got */
                                    /* this mixed-size jump insn of gas.  */
                                    /* this calls far jump (ptr 16:32) in intel manual) */

LABEL_REAL_ENTRY:               # 從保護模式跳回到實模式就到了這裡
        mov     %cx, %ax
        mov     %ax, %ds
        mov     %ax, %es
        mov     %ax, %ss

#        mov     sp, [SPValueInRealMode]

        in      $0x92, %al
        and     $0b11111101, %al   #  close A20 line
        out     %al, $0x92

        sti                     # 開中斷

        mov     $0x4c00, %ax
        int     $0x21             #  回到 DOS
# END of .code16

LABEL_SEG_CODE32: 
.code32

	mov	$(SelectorData), %ax
	mov	%ax, %ds			# 資料段選擇子
	mov	$(SelectorTest), %ax
	mov	%ax, %es			# 測試段選擇子




    mov     $(SelectorVideo), %ax
    mov     %ax, %gs                /* Video segment selector(dest) */

	mov	$(SelectorStack), %ax
	mov	%ax, %ss			# 堆疊段選擇子

	mov	$(TopOfStack), %esp

/*
    movl    $((80 * 10 + 0) * 2), %edi
    movb    $0xC, %ah               # 0000: Black Back 1100: Red Front 
    movb    $'P', %al

    mov     %ax, %gs:(%edi)
*/

	# print string "In Protect Mode now. ^-^"
	movb	$0x0c, %ah # 0000: 黑底    1100: 紅字
	xor	%esi, %esi
	xor	%edi, %edi
#	mov	$(OffsetPMMessage+LABEL_DATA), %esi	# data string offset, mov    $0x153,%esi
	mov	(PMMessage), %esi # why use this will get fail, because       mov     0x153,%esi, 
                                  # 這是把位址 0x153 的值 assign 給 %esi, 不是 0x153 這個值 assign 給 %esi。
                                                                                                  
#	mov	(%eax), %esi	# data string offset
	movl	$((80 * 10 + 0) * 2), %edi	# 目的資料偏移。螢幕第 10 行, 第 0 列。
	cld # Clear Direction Flag, ref: http://www.fermi.mn.it/linux/quarta/x86/cld.htm
            # After CLD is executed, string operations will increment the index 
            # (SI and/or DI) that they use. 
.1:
	lodsb # For legacy mode, Load byte at address DS:(E)SI into AL. 
              # For 64-bit mode load byte at address (R)SI into AL. 
              # ref: http://siyobik.info/main/reference/instruction/LODS%2FLODSB%2FLODSW%2FLODSD%2FLODSQ
	test	%al, %al # result is 0, zf sets to 1.
	jz	.2 # zf = 1 jump
#	mov	[gs:edi], ax
        mov     %ax, %gs:(%edi)
	add	$2, %edi
	jmp	.1
.2:	# 顯示完畢

#push  %eax                       # Multiboot magic number
#   push  %ebx                       # Multiboot data structure

#        movb $0xef, %al
#  movl    $66, 4(%esp)
#  movl    $2, (%esp)

  call kmain
#  call DispAL
#  call ckmain
  call cckmain
  #movzbl chor_regs, %eax

#	mov	$(SelectorTestData), %ax
#	mov	%ax, %es

#  mov $(var1), %ebx
#  movw %es:(LABEL_DATA+100), %eax
  #movw %ds:(SPValueInRealMode), %eax
  #movl $(SPValueInRealMode), %eax
#  movl (var1-LABEL_DATA), %eax
#  call DispAL

#  pushl  $66
#  pushl  $2
#  calll write_mem8
	#call	init_graph_vga
#        movb $0xa9, %al
#	call	DispAL
/*
	call	DispReturn
        #movb $0xa9, %al
	#call	DispAL

	call	TestRead
	call	TestWrite
	call	TestRead
*/

    ljmpl     $SelectorCode16,$0
    # jmpl     $SelectorCode16,$0 # it works

# ------------------------------------------------------------------------
TestRead:
	xor	%esi, %esi
	mov	$8, %ecx
.loop:
	mov	%es:(%esi), %al
	call	DispAL
	inc	%esi
	loop	.loop
	call	DispReturn

	ret
# TestRead 結束-----------------------------------------------------------


# ------------------------------------------------------------------------
TestWrite:
	pushl	%esi
	pushl	%edi
	xor	%esi, %esi
	xor	%edi, %edi
	mov	$(OffsetStrTest), %esi	# data offset
	cld # Clear Direction Flag, ref: http://www.fermi.mn.it/linux/quarta/x86/cld.htm
            # After CLD is executed, string operations will increment the index 
            # (SI and/or DI) that they use. 
.6:
	lodsb # For legacy mode, Load byte at address DS:(E)SI into AL. 
              # For 64-bit mode load byte at address (R)SI into AL. 
              # ref: http://siyobik.info/main/reference/instruction/LODS%2FLODSB%2FLODSW%2FLODSD%2FLODSQ

	test	%al, %al
	jz	.5 # zf = 1 jump
#	mov	[es:edi], al
	mov	%al, %es:(%edi)
	inc	%edi
	jmp	.6
.5:

	popl	%edi
	popl	%esi
	ret
# TestWrite 結束----------------------------------------------------------

# ref 30 天打造OS, page 80
.globl write_mem8
write_mem8:
  mov 4(%esp), %ecx;
  movb 8(%esp), %al;
  movb %al, %gs:(%ecx)
  ret


# ------------------------------------------------------------------------
# 顯示 AL 中的數字
# 默認地:
#	數字已經存在 AL 中
#	edi 始終指向要顯示的下一個字元的位置
# 被改變的暫存器:
#	ax, edi
# ------------------------------------------------------------------------
.globl DispAL
DispAL:
	pushl	%ecx
	pushl	%edx

	movb	$0x0c, %ah # 0000: 黑底    1100: 紅字
	movb	%al, %dl
	shr	$4, %al
	movl	$2, %ecx
.begin:
	andb	$0x0f, %al
	cmp	$9, %al
	ja	.3          # cf=0, zf=0, above 9 (>9)
	#addb	$'0', %al
	addb	$0x30, %al
	jmp	.4
.3:
	sub	$0x0A, %al
	#add	$'A', %al
	add	$0x41, %al
.4:
	#mov	[gs:edi], ax
	mov	%ax, %gs:(%edi)
	add	$2, %edi

	mov	%dl, %al
	loop	.begin
	add	$2, %edi

	popl	%edx
	popl	%ecx

	ret
# DispAL 結束-------------------------------------------------------------


# ------------------------------------------------------------------------
DispReturn:
	pushl	%eax
	pushl	%ebx
	mov	%edi, %eax
	movb	$160, %bl
	divb	%bl          # %eax/160, 商 al, 餘數 ah.
	and	$0x0FF, %eax
	inc	%eax         # ++ %eax
	mov	$160, %bl
	mul	%bl
	mov	%eax, %edi
	popl	%ebx
	popl	%eax
	ret
# DispReturn 結束---------------------------------------------------------

.globl ckmain
	.type	ckmain, @function
ckmain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	movl	$78, 4(%esp)
	movl	$320, (%esp)
	call	write_mem8
	leave
	ret

.globl cckmain
	.type	cckmain, @function
cckmain:
	pushl	%ebp
	movl	%esp, %ebp
	subl	$24, %esp
	#movl	(chor_regs+4-LABEL_DATA), %eax
	movl	(chor_regs+4), %eax
	movzbl	%al, %edx
	#movl	(chor_regs-LABEL_DATA), %eax
	movl	(chor_regs), %eax
	movl	%edx, 4(%esp)
	movl	%eax, (%esp)
	call	write_mem8
	leave
	ret


/* Get the length of 32-bit segment code. */
.set    SegCode32Len, . - LABEL_SEG_CODE32




LABEL_SEG_CODE16:
.code16
    #jmp     .
        # back to real mode
        mov     $SelectorNormal, %ax
        mov     %ax, %ds
        mov     %ax, %es
        mov     %ax, %fs
        mov     %ax, %gs
        mov     %ax, %ss

        mov     %cr0, %eax
        and     $0b11111110, %al
        mov     %eax, %cr0


LABEL_GO_BACK_TO_REAL:
#.2byte 0xea66
#.4byte 0x00000000
#.2byte LABEL_REAL_ENTRY
    jmp     $0, $LABEL_REAL_ENTRY      # 段位址會在程序開始處被設置成正確的值


.set Code16Len, . - LABEL_SEG_CODE16


