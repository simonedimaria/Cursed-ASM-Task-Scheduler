/*
    main.s - main file for the project, contains entrypoint.
    Author(s): Simone Di Maria, Pietro Secchi
*/

.section .data
    # constants
    list_head1:
        .long 0
    filename:
        .asciz "test_cases.txt"

.section .bss
    # statically allocated variables

.section .text
    .global _start
    
    _start:
   

        mov $4, %ecx
        mov $5, %edx
        call init_list
        mov %eax, list_head1
        # mov $5, %ecx
        # mov $10, %ebx
        # mov $1, %edx
        # mov list_head1,%eax
        # call init_file
        # call read_nodes
        # call read_nodes
        # mov %eax, list_head1
        # mov $1,%eax
        # mov $2,%ebx
        # mov $3,%ecx
        # mov $4,%edx
        # call init_queue
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
        mov $3, %ecx
        mov $3, %ebx
        mov $1, %edx
        mov list_head1,%eax
        call add_to_list
        mov $6, %ecx
        mov $3, %ebx
        mov $1, %edx
        mov list_head1, %eax
        call add_to_list
        mov list_head1, %eax
        mov $0, %ebx
        mov $1, %ecx
        call list_to_buffer
        call print_buffer_no_length

    end:
        xorl %eax, %eax
        inc %eax
        xorl %ebx, %ebx
        int $0x80