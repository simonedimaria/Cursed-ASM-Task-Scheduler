/*
    main.s - main file for the project, contains entrypoint.
    Author(s): Simone Di Maria, Pietro Secchi
*/

.section .data
    list_head1:
        .long 0
    filename:
        .space 256  # buffer per salvare il primo argomento, max 256 filename in Linux
        # .asciz "test_cases.txt"
    filename_out:
        .space 256
    filename_out_descriptor:
        .long 1 # stdout
    output:
        .long 0 # 0=no 1=yes  
    buffer_read_address:
        .long 0
    list_head:
        .long 0

    bytes_read:
        .long 0
    queue_head:
        .long 0
    argc:
        .long 0

    argv:
        .long 0

.section .bss
    # statically allocated variables

.section .text
    .global _start
    
    _start:
   
    retrieve_arguments:
        popl %eax        # pop return address
        movl %eax, argc  # store argc
        popl %eax        # pop argc
        movl %esp, argv  # store argv

        movl argv, %ebx   # get argv
        movl (%ebx), %ecx # get the pointer to the first argument
        movl %ecx, filename # store the pointer to filename

        mov argc, %eax
        cmp $2,%eax 
        je end_ret
        addl $4, %ebx      # point to the second argument (argv[2])
        movl (%ebx), %ecx  # get the pointer to the second argument
        movl %ecx, filename_out # store the pointer to filename_out
        mov filename_out, %ebx

        call open_file
        mov %eax, filename_out_descriptor
        inc output
        end_ret:

        mov filename, %ebx

        call init_file
        call read_tasks
        mov %ecx, bytes_read
        mov %ebx,buffer_read_address
        
        mov filename_out_descriptor, %ecx
        call print_menu_and_input
        mov %eax, %esi
        dec %esi
        mov buffer_read_address, %ebx
        call init_queue_from_buffer
        mov %eax, queue_head

        mov bytes_read, %ecx
        test %ecx, %ecx
        jz finish_read
        read_more:
            call read_tasks
            test %ecx, %ecx
            jz finish_read

            mov queue_head, %eax
            call add_tasks_to_queue_from_buffer
            jmp read_more
        finish_read:

        xor %ebx, %ebx
        xor %ecx, %ecx    
        break2:    
        mov $0,%esi
        mov queue_head, %eax
        call queue_to_list
        mov %eax, list_head
        xor %ebx, %ebx
        mov $0,%esi
        break:
        mov $1, %ecx


        mov list_head, %eax
        mov filename_out_descriptor, %ecx
        call print_list
        cmp $1,%ecx
        je end
        end2:
        mov list_head, %eax
        mov $1, %ecx
        call print_list


        break3:


    end:
        xorl %eax, %eax
        inc %eax
        xorl %ebx, %ebx
        int $0x80