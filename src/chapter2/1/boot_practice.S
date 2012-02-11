.code16
.text
    mov     %cs,%ax
    mov     %ax,%ds
    mov     %ax,%es
    mov	$0xB800, %ax
    mov	%ax, %gs
    mov	$0x0, %ax
    mov	%ax, %es
    movb $0x42, %es:0 # move immediate value (0x42 = 'B') to address 0000:0000, es -> 0

    movb %es:0, %al
    mov	$0x0c, %ah # red color
    mov	%ax, %gs:(0)

    mov	$2, %edi

    mov	$0x41, %al
    mov	%ax, %gs:(%edi)

    mov $BootMessage, %bx
    movb %ds:1(%bx), %al
    movb 1(%bx), %al
    mov %ax, %gs:(4)

    movb BootMessage, %al
    mov %ax, %gs:(6)

    jmp     .
DispStr: 
    mov     $BootMessage, %ax
    mov     %ax,%bp
    mov     $16,%cx
    mov     $0x1301,%ax
    mov     $0x00c,%bx
    mov     $0,%dl
    int     $0x10
    ret
BootMessage:.ascii "Hello, OS world!"

.org 510
.word 0xaa55
