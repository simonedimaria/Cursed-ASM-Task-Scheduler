/*
    main.s - main file for the project, contains entrypoint.
    Author(s): Simone Di Maria, Pietro Secchi
*/

.section .data
    task_id:
        .long 0
    task_duration:
        .long 0
    buffer_read_address:
        .long 0
    filename:
        .ascii "test_cases.txt"  
    # constants
    list_head1:
        .long 0


.section .bss
    # statically allocated variables

.section .text
    .global _start
    
    _start:
   
        mov $filename, %ebx

        call init_file
        call read_nodes
        # fist task
        break_file:
        mov %ebx,buffer_read_address
        
        mov $1, %esi
        call init_queue_from_buffer

        xor %ebx, %ebx
        xor %ecx, %ecx    
        break2:    
        mov $1,%esi
        call queue_to_list
        xor %ebx, %ebx
        mov $1,%esi
        break:
        call print_list
        break3:

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
      #  mov $5, %ecx
      #  mov $10, %ebx
      #  mov $1, %edx
      #  mov list_head1,%eax
      #  call add_to_list
      #  mov $3, %ecx
      #  mov $3, %ebx
      #  mov $1, %edx
      #  mov list_head1,%eax
      #  call add_to_list
      #  mov $3, %ecx
      #  mov $3, %ebx
      #  mov $1, %edx
      #  mov list_head1,%eax
      #  call add_to_list
      #  mov $6, %ecx
      #  mov $3, %ebx
      #  mov $1, %edx
      #  mov list_head1, %eax
      #  call add_to_list
      #  mov list_head1, %eax
      #  mov $0, %ebx
      #  mov $1, %ecx
      #  call print_buffer_no_length

    end:
        xorl %eax, %eax
        inc %eax
        xorl %ebx, %ebx
        int $0x80