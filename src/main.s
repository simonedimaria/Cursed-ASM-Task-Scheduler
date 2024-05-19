.data
list_head:  .long 0 
.section .bss



.section .text
.global _start
_start:

mov $4, %ecx
mov $5, %edx
call init_list
mov $5, %ecx
mov $10, %ebx
mov $0, %edx
call add_to_list
mov %eax,list_head
mov %eax,%edx
call add_to_list
xorl %eax, %eax
inc %eax
xorl %ebx, %ebx
int $0x80
