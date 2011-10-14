/* chapter2/1/boot.S

   Author: Wenbo Yang <solrex@gmail.com> <http://solrex.cn>

   This file is part of the source code of book "Write Your Own OS with Free
   and Open Source Software". Homepage @ <http://share.solrex.cn/WriteOS/>.

   This file is licensed under the GNU General Public License; either
   version 3 of the License, or (at your option) any later version. */

.code16
#.code16gcc
.text
LABEL_STACK:
#.align 8
.space  512, 0x12
.set    TopOfStack, (. - LABEL_STACK - 1)
    jmp LABEL_BEGIN     /* jump over the .data section. */

LABEL_BEGIN:
    mov     %cs,%ax
    mov     %ax,%ds
    mov     %ax,%ss
#    mov     $0x0,%ax
    mov     %ax,%es
    mov     $0x0, %ebp # if don't assign %ebp to 0, in write_mem8 pushl %ebp will hang.
    mov     $(TopOfStack), %esp

  mov $0xb800,%ax
  mov %ax,%gs
  mov $0x0,%edi

#  mov (%esp), %eax
#  call DispAX
#  mov %esp, %eax
#  call DispAX

#    mov     %cs,%ax
#    call DispAX


    #pushl %ebp
    #mov %esp, %ebp
    #mov     %esp,%eax
    #mov     %cs,%eax

    #call DispAX

    #pushl $4  # 1 arg, address

#    call    DispStr
    #call    kmain
#        movl    $66, 4(%esp)
#        movl    $0, (%esp)

#    mov     %esp,%eax
#    call DispAX
#    mov     %esp,%eax
#    callw DispAX

#	pushl $0x4d # 2 arg, char
#	pushl $320  # 1 arg, address
#	movl	$66, 4(%esp)
#	movl	$2, (%esp)
#	calll    write_mem8
#	movl	$0xab, %eax
#    mov %esp, %eax
#    calll DispAX
    calll kmain
#    calll ckmain
#    calll DispAX
  #calll    write_mem8
  #calll    write_mem8

#  popl %ecx # 1 arg, addr
#  popl %eax # 2 arg, char
#  mov 4(%esp), %eax # 2 arg, char
#  movl 2(%esp), %ecx # 1 arg, address
#  mov $0xb800,%bx
#  mov %bx,%es
#  movb %al, %es:(%ecx)

        mov     $0x4c00, %ax
        int     $0x21             #  回到 DOS

    #jmp     .
write_mem16:
  nop
  nop
.globl write_mem8
write_mem8:
  pushl	%ebp
  mov %esp, %ebp
#    pushl %ecx
#    pushl %eax

#    mov     (%esp),%eax
#    callw DispAX

#    push %ecx
#    push %ebp
#    mov %esp, %ebx
#    mov %eax, %ebp

#    mov     %esp,%eax
#    callw DispAX

#    mov     %esp,%eax
#    callw DispAX
#    subl     $4, %esp
#    mov     %esp,%eax
#    callw DispAX
    #mov %ebp,(%esp)
#    mov (%esp), %eax
#    callw DispAX
#    mov %ebp,%eax
#    callw DispAX

 # mov $0xb800,%ax
 # mov %ax,%es

#  mov 4(%esp), %ecx; # 1st arg, address
#  movb 8(%esp), %al; # 2nd arg, char

#  mov 8(%esp), %ecx; # 1st arg, address
#  movb 12(%esp), %al; # 2nd arg, char

#  movw %esp, %eax; # 2nd arg, char
#  movb 8(%esp), %al; # 2nd arg, char
#  call DispAX

  mov 8(%ebp), %ecx; # 1nd arg, address
  movb 12(%ebp), %al; # 2nd arg, char
#  mov 4(%esp), %eax; # 1nd arg, address
#  call DispAX

#  mov 8(%esp), %eax; # 2nd arg
#  call DispAX

#  mov $0x2, %ecx;
  #mov %ss:6(%esp), %eax;
#  movb $67, %al;
  movb %al, %gs:(%ecx)
#    popl %ecx
#    popl %eax
	popl	%ebp
  ret

.globl DispAL
DispAL:
	pushl	%ecx
	pushl	%edx
	pushl	%eax

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
#	mov	%ax, %gs:(%edi)

  movb %al, %gs:(%edi)

	add	$2, %edi



	mov	%dl, %al
	loop	.begin
#	add	$2, %edi

	popl	%eax
	popl	%edx
	popl	%ecx

	ret
# DispAL 結束-------------------------------------------------------------
.globl DispAX
DispAX:
	pushl	%ebx
	pushl	%ecx
	pushl	%edx

	movw	%ax, %dx
	shr	$8, %ax # ah -> al
	movl	$2, %ecx
.b:
	call DispAL
	movw %dx, %ax
#	addl	$2, %edi
#	call DispAL_m
#  	andw 0xff, %ax
	loop .b

	popl	%edx
	popl	%ecx
	popl	%ebx

	ret
# end DispAX
#.globl kmain
#        .type   kmain, @function

#DispStr: 
#    mov     $BootMessage, %ax
#    mov     %ax,%bp
#    mov     $16,%cx
#    mov     $0x1301,%ax
#    mov     $0x00c,%bx
#    mov     $0,%dl
#    int     $0x10
#    ret
.globl BootMessage
BootMessage:.ascii "Hello, OS wo"
nop
nop

.globl ckmain
#	.type	ckmain, @function
ckmain:
	pushl	%ebp
	movl	%esp, %ebp
#	subl	$24, %esp
	movl	$0x42, 4(%esp)
#  movl %esp, %eax; # 2nd arg, char
#  calll DispAX
	movl	$166, (%esp)
	calll	write_mem8
	leave
	ret
#.org 510
#.word 0xaa55
