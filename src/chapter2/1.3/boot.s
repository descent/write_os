/* chapter2/1/boot.S

   Author: Wenbo Yang <solrex@gmail.com> <http://solrex.cn>

   This file is part of the source code of book "Write Your Own OS with Free
   and Open Source Software". Homepage @ <http://share.solrex.cn/WriteOS/>.

   This file is licensed under the GNU General Public License; either
   version 3 of the License, or (at your option) any later version. */

.code16
.text
    mov     %cs,%ax
    mov     %ax,%ds
    mov     %ax,%es
    call    DispStr
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
