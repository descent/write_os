/* chapter3/2/solrex_x86_boot.ld

   Author: Wenbo Yang <solrex@gmail.com> <http://solrex.cn>

   This file is part of the source code of book "Write Your Own OS with Free
   and Open Source Software". Homepage @ <http://share.solrex.cn/WriteOS/>.

   This file is licensed under the GNU General Public License; either
   version 3 of the License, or (at your option) any later version. */

SECTIONS
{
  . = 0x7c00;
  .text :
  {
    _ftext = .;
  } = 0
}
