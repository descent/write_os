/* chapter3/3/loader.S

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
LABEL_GDT:          Descriptor        0,                  0, 0
LABEL_DESC_CODE32:  Descriptor        0, (SegCode32Len - 1), (DA_C + DA_32)
LABEL_DESC_DATA:    Descriptor        0,      (DataLen - 1), DA_DRW
LABEL_DESC_STACK:   Descriptor        0,         TopOfStack, (DA_DRWA + DA_32)
LABEL_DESC_VIDEO:   Descriptor  0xB8000,             0xffff, DA_DRW
LABEL_DESC_LDT:     Descriptor        0,       (LDTLen - 1), DA_LDT
LABEL_DESC_CODECG:  Descriptor        0, (SegCodeCGLen - 1), (DA_C + DA_32)
/* Gates Descriptor */
LABEL_CG_TEST:      Gate    SelectorCodeCG, 0, 0, (DA_386CGate + DA_DPL0)

.set GdtLen, (. - LABEL_GDT)  /* GDT Length */

GdtPtr: .2byte  (GdtLen - 1)  /* GDT Limit */
        .4byte  0             /* GDT Base */

/* GDT Selector(TI flag clear) */
.set    SelectorCode32, (LABEL_DESC_CODE32 - LABEL_GDT)
.set    SelectorData,   (LABEL_DESC_DATA   - LABEL_GDT)
.set    SelectorStack,  (LABEL_DESC_STACK  - LABEL_GDT)
.set    SelectorVideo,  (LABEL_DESC_VIDEO  - LABEL_GDT)
.set    SelectorLDT,    (LABEL_DESC_LDT    - LABEL_GDT)
.set    SelectorCodeCG, (LABEL_DESC_CODECG - LABEL_GDT)
.set    SelectorCGTest, (LABEL_CG_TEST     - LABEL_GDT)

/* LDT segment */
LABEL_LDT:
LABEL_LDT_DESC_CODEA:   Descriptor  0, (CodeALen - 1), (DA_C + DA_32)

.set    LDTLen, (. - LABEL_LDT) /* LDT Length */
/* LDT Selector (TI flag set)*/
.set    SelectorLDTCodeA, (LABEL_LDT_DESC_CODEA - LABEL_LDT + SA_TIL)

/* 32-bit global data segment. */
LABEL_DATA:
PMMessage:   .ascii "Welcome to protect mode! ^-^\0"
LDTMessage:  .ascii "Aha, you jumped into a LDT segment.\0"
.set    OffsetPMMessage,  (PMMessage - LABEL_DATA)
.set    OffsetLDTMessage, (LDTMessage - LABEL_DATA)
.set    DataLen,          (. - LABEL_DATA)

/* 32-bit global stack segment. */
LABEL_STACK:
.space  512, 0
.set    TopOfStack, (. - LABEL_STACK - 1)

/* Program starts here. */
LABEL_BEGIN:
    mov     %cs, %ax    /* Move code segment address(CS) to data segment */
    mov     %ax, %ds    /* register(DS), ES and SS. Because we have      */
    mov     %ax, %es    /* embedded .data section into .code section in  */
    mov     %ax, %ss    /* the start(mentioned in the NOTE above).        */

    mov     $0x100, %sp

    /* Initialize 32-bits code segment descriptor. */
    InitDesc LABEL_SEG_CODE32, LABEL_DESC_CODE32

    /* Initialize data segment descriptor. */
    InitDesc LABEL_DATA, LABEL_DESC_DATA

    /* Initialize stack segment descriptor. */
    InitDesc LABEL_STACK, LABEL_DESC_STACK

    /* Initialize LDT descriptor in GDT. */
    InitDesc LABEL_LDT, LABEL_DESC_LDT

    /* Initialize code A descriptor in LDT. */
    InitDesc LABEL_CODEA, LABEL_LDT_DESC_CODEA

    /* Initialize call gate dest code segment descriptor. */
    InitDesc LABEL_SEG_CODECG, LABEL_DESC_CODECG

    xor     %eax, %eax
    mov     %cs, %ax
    shl     $4, %eax
    addl    $(LABEL_CODEA), %eax
    movw    %ax, (LABEL_LDT_DESC_CODEA + 2)
    shr     $16, %eax
    movb    %al, (LABEL_LDT_DESC_CODEA + 4)
    movb    %ah, (LABEL_LDT_DESC_CODEA + 7)

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
    ljmpl $SelectorCode32, $0       /* Thanks to earthengine@gmail, I got */
                                    /* this mixed-size jump insn of gas.  */


/* 32-bit code segment for LDT */
LABEL_CODEA:
.code32
    mov     $(SelectorVideo), %ax
    mov     %ax, %gs

    movb    $0xC, %ah               /* 0000: Black Back 1100: Red Front */
    xor     %esi, %esi
    xor     %edi, %edi
    movl    $(OffsetLDTMessage), %esi
    movl    $((80 * 12 + 0) * 2), %edi
    cld                         /* Clear DF flag. */

/* Display a string from %esi(string offset) to %edi(video segment). */
CODEA.1:
    lodsb                       /* Load a byte from source */
    test    %al, %al
    jz      CODEA.2
    mov     %ax, %gs:(%edi)
    add     $2, %edi
    jmp     CODEA.1
CODEA.2:

    /* Stop here, infinite loop. */
    jmp     .
.set    CodeALen, (. - LABEL_CODEA)

/* 32-bit code segment for GDT */
LABEL_SEG_CODE32: 
    mov     $(SelectorData), %ax
    mov     %ax, %ds                /* Data segment selector */
    mov     $(SelectorStack), %ax
    mov     %ax, %ss                /* Stack segment selector */
    mov     $(SelectorVideo), %ax
    mov     %ax, %gs                /* Video segment selector(dest) */

    mov     $(TopOfStack), %esp

    movb    $0xC, %ah               /* 0000: Black Back 1100: Red Front */
    xor     %esi, %esi
    xor     %edi, %edi
    movl    $(OffsetPMMessage), %esi
    movl    $((80 * 10 + 0) * 2), %edi
    cld                         /* Clear DF flag. */

/* Display a string from %esi(string offset) to %edi(video segment). */
CODE32.1:
    lodsb                       /* Load a byte from source */
    test    %al, %al
    jz      CODE32.2
    mov     %ax, %gs:(%edi)
    add     $2, %edi
    jmp     CODE32.1
CODE32.2:

    lcall   $(SelectorCGTest), $0  /* Call CODECG through call gate */

    mov     $(SelectorLDT), %ax
    lldt    %ax

    ljmp    $(SelectorLDTCodeA), $0

/* Get the length of 32-bit segment code. */
.set    SegCode32Len, . - LABEL_SEG_CODE32

/* 32-bit code segment for call gate destination segment */
LABEL_SEG_CODECG:
    mov     $(SelectorVideo), %ax
    mov     %ax, %gs

    movl    $((80 * 11 + 0) * 2), %edi  /* line 11, column 0 */
    movb    $0xC, %ah               /* 0000: Black Back 1100: Red Front */
    movb    $'C', %al               /* Print a 'C' */

    mov     %ax, %gs:(%edi)
    lret

/* Get the length of 32-bit call gate destination segment code. */
.set    SegCodeCGLen, . - LABEL_SEG_CODECG
