/*
    main.s
    @note: main file for the project, contains entrypoint.
    @author: Simone Di Maria, Pietro Secchi
*/


.section .data
    list_head1:
        .long 0
    filename:
        .space 256  #  max filename length in Linux
    filename_out:
        .space 256
    filename_out_descriptor:
        .long 1 # STDOUT
    output:
        .long 0 # 0=no 1=yes, default: 0  
    buffer_read_address:
        .long 0
    list_head:
        .long 0
    bytes_read:
        .long 0
    queue_head:
        .long 0
    algorithm:
        .long 0
    argc:
        .long 0
    argv:
        .long 0


.section .text
    .global _start

_start:
retrieve_arguments:
    popl %eax
    movl %eax, argc  # store argc
    popl %eax
    movl %esp, argv  # store argv

    movl argv, %ebx     # get argv
    movl (%ebx), %ecx   # get the pointer to the first argument
    movl %ecx, filename # store the pointer to filename

    mov argc, %eax
    cmp $2, %eax 
    je end_retrieve_arguments
    addl $4, %ebx           # point to the second argument (argv[2])
    movl (%ebx), %ecx       # get the pointer to the second argument
    movl %ecx, filename_out # store the pointer to filename_out
    mov filename_out, %ebx

    call open_file
    mov %eax, filename_out_descriptor
    incl output
       
    end_retrieve_arguments:
        mov filename, %ebx

        call init_file
        call read_tasks
        mov %ecx, bytes_read
        mov %ebx, buffer_read_address

        mov filename_out_descriptor, %ecx
        call start_ui
        test %eax, %eax
        jz exit

        mov %eax, %esi
        dec %esi
        mov %esi, algorithm
        mov buffer_read_address, %ebx
        call init_queue_from_buffer
        mov %eax, queue_head

        mov bytes_read, %ecx
        test %ecx, %ecx
        jz finish_read

    read_line:
        call read_tasks
        test %ecx, %ecx
        jz finish_read
        mov queue_head, %eax
        call add_tasks_to_queue_from_buf
        jmp read_line
       
    finish_read:
        xor %ebx, %ebx
        xor %ecx, %ecx    

        mov algorithm, %esi
        mov queue_head, %eax
        call queue_to_list
        mov %eax, list_head
        xor %ebx, %ebx
        mov $0, %esi

        mov $1, %ecx
        mov list_head, %eax
        mov filename_out_descriptor, %ecx
        mov algorithm, %esi
        call print_list
        cmp $1, %ecx
        je end_retrieve_arguments

    print_to_stdout:
        mov list_head, %eax
        mov $1, %ecx
        call print_list
        jmp end_retrieve_arguments

exit:
    mov SYS_EXIT, %eax
    xorl %ebx, %ebx
    int $0x80
