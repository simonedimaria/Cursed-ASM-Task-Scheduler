.data
list_head1:  .long 0 
.section .bss



.section .text
.global _start
# 0,000_000_265_3 seconds for mov list_head1,%eax   265.3 nanoseconds 
# 0,000_000_110_4 seconds for neg %eax  110.4 nanoseconds
_start:

   mov $4, %ecx
   mov $5, %edx
   call init_list
   mov %eax, list_head1
   mov $5, %ecx
   mov $10, %ebx
   mov $1, %edx
   mov list_head1,%eax 
   call add_to_list
   mov $3, %ecx
   mov $3, %ebx
   mov $1, %edx
   mov list_head1,%eax
   call add_to_list
   mov $4, %ecx
   mov $3, %ebx
   mov $1, %edx
   mov list_head1,%eax
   call add_to_list
  
    
    xorl %eax, %eax
    inc %eax
    xorl %ebx, %ebx
    int $0x80
