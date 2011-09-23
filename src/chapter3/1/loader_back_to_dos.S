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
LABEL_DESC_CODE32:  Descriptor  0,       (SegCode32Len - 1), (DA_C + DA_32)
LABEL_DESC_CODE16:  Descriptor    0,         0xffff, DA_C      # 非一致程式碼段, 16
LABEL_DESC_VIDEO:   Descriptor  0xB8000,             0xffff, DA_DRW

.set GdtLen, (. - LABEL_GDT)  /* GDT Length */

GdtPtr: .2byte  (GdtLen - 1)  /* GDT Limit */
        .4byte  0             /* GDT Base */

/* GDT Selector */
.set SelectorNormal, (LABEL_DESC_NORMAL - LABEL_GDT)    
.set    SelectorCode32, (LABEL_DESC_CODE32 - LABEL_GDT)
.set SelectorCode16, (LABEL_DESC_CODE16 - LABEL_GDT)
.set    SelectorVideo,  (LABEL_DESC_VIDEO  - LABEL_GDT)

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
    mov     $(SelectorVideo), %ax
    mov     %ax, %gs                /* Video segment selector(dest) */

    movl    $((80 * 10 + 0) * 2), %edi
    movb    $0xC, %ah               /* 0000: Black Back 1100: Red Front */
    movb    $'P', %al

    mov     %ax, %gs:(%edi)

    /* Stop here, infinite loop. */
#    jmp     .
    ljmpl     $SelectorCode16,$0

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


