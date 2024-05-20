.data
list_head:  .long 0 
.section .bss



.section .text
.global _start
_start:

    mov $4, %ecx
    mov $5, %edx
    call init_list
    mov %eax, list_head
    mov $5, %ecx
    mov $10, %ebx
    mov $1, %edx
    mov %eax, list_head
    call add_to_list
    mov $3, %ecx
    mov $3, %ebx
    mov $1, %edx
    mov list_head,%eax
    call add_to_list
    mov %eax,list_head
    mov %eax,%edx
    call add_to_list
    xorl %eax, %eax
    inc %eax
    xorl %ebx, %ebx
    int $0x80
