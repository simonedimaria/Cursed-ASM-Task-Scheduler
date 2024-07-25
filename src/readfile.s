/*
    readfile.s
    @note: Reads a file line by line and decodes the nodes.
    @author: Simone Di Maria, Pietro Secchi
*/


.section .data
    fd:
        .int 0
    buffer:
        .space 4096
    buffer_size:
        .long 4096
    buffer_atoi:
        .space 256       
    buffer_to_decode:
        .space 256       
    buffer_nodes:
        .space 8192        
    buffer_nodes_index:
        .long 0        
    buffer_read_ptr:
        .long 0        
    buffer_decode_address:
        .long 0    
    buffer_nodes_address:
        .long 0    
    count:
        .long 0    
    bytes_read:
        .long 0
    more_bytes:
        # 0=no 1=yes, default: 0
        .int 0


.section .text
    .global init_file
    .global read_tasks


init_file:
/*
init_file(ebx: filename) --> eax: fd
@note opens the file with the given filename, returns the file descriptor in eax.
*/
    pushl %ebp
    movl %esp, %ebp

    mov SYS_OPEN, %eax
    mov O_RDONLY, %ecx
    int $0x80

    cmp $0, %eax
    jl exit_with_status_0

    mov %eax, fd
    
    leave
    ret


lseek:
/*
lseek(eax: file_buffer_position, ebx: fd) --> eax: lseek
@note moves the file pointer of the given file descriptor to the given file buffer position
*/
    pushl %ebp
    movl %esp, %ebp

    mov %eax, %ecx
    mov SYS_LSEEK, %eax
    mov fd, %ebx
    movl SEEK_CUR, %edx
    int $0x80

    leave
    ret


read_tasks:
/*
read_tasks() --> eax: buffer
@note reads the file line by line, returns the buffer with the file content
*/
    pushl %ebp
    movl %esp, %ebp
    
    movl $0, buffer_nodes_index
 
    mov SYS_READ, %eax
    mov fd, %ebx
    mov $buffer, %ecx
    mov buffer_size, %edx
    int $0x80
    
    t_read:
        mov %eax, bytes_read

        # close the file if SYS_READ fails or EOF
        cmp $0, %eax
        jle close_file

        # store the number of bytes read
        mov %ecx, %ebx
        mov %eax, %ecx

        # save bytes read
        mov %ecx, bytes_read
        call get_broken_node

        test %eax, %eax
        jz no_lseek

    yes_lseek:
        call lseek
    
    no_lseek:
        movl $1, more_bytes
    
    mov $buffer, %ebx

    # restore bytes read
    mov bytes_read, %ecx
    call decode_nodes
    mov $buffer_nodes, %ebx
    mov bytes_read, %ecx
    
    leave
    ret


close_file:
    movl $0, more_bytes
    mov SYS_CLOSE, %eax
    mov %ebx, %ecx
    int $0x80
    
    mov bytes_read, %ecx
    
    leave
    ret


exit_with_status_0:
    mov SYS_EXIT, %eax
    xor %ebx, %ebx
    int $0x80


decode_nodes:
/*
decode_nodes(ebx: buffer, ecx: bytes_read)
@note decodes the nodes from the file buffer, returns the decoded nodes in buffer_nodes.
*/
    pushl %ebp
    movl %esp, %ebp

    xor %eax, %eax
    mov $buffer_to_decode, %edx
    mov %ebx, %esi
    add buffer_size, %esi

    decode_lines_loop:
        cmp %esi, %ebx
        je exit_decode
        
        mov (%ebx), %al
        cmpb LINE_FEED_ASCII, %al
        
        je call_decode
        mov %al, (%edx)
        
        # exit if last byte
        test %ecx, %ecx
        jz exit_decode
        dec %ecx
        inc %ebx
        inc %edx
        jmp decode_lines_loop

    call_decode:
        movl $0, (%edx) # set last buffer value to null byte
        inc %edx
        mov %edx, buffer_decode_address # save address
        mov %ecx, count
        mov %ebx, buffer_read_ptr
         
        call decode_node
   
        mov count, %ecx
        mov buffer_read_ptr, %ebx
        mov $buffer_to_decode, %edx # restore address
        
        inc %ebx
        jmp decode_lines_loop

    exit_decode:
        leave
        ret


decode_node:
/*
decode_node()
@note decodes the nodes from the file buffer, returns the decoded nodes in buffer_nodes.
*/
   pushl %ebp
   movl %esp, %ebp

    mov $buffer_to_decode, %edx
    
    loop_decode_node_start:
        mov $buffer_atoi, %ebx

        loop_decode_node:
            # clean the buffer at position stored in ebx
            movl $0, (%ebx)
            
            movb (%edx), %al
            cmpb COMMA_ASCII, %al
            je add_to_buffer
            cmpb $0, %al    # end of buffer
            je add_to_buffer_exit

            mov %al, (%ebx) 

            # go to next byte for atoi
            inc %ebx
            inc %edx
            jmp loop_decode_node
        
    add_to_buffer:
        movl $0, 1(%ebx)
        mov $buffer_atoi, %ebx
        
        inc %edx

        # save address
        mov %edx, buffer_nodes_address

        call atoi
        mov buffer_nodes_index, %ecx
        
        # go to index
        mov $buffer_nodes, %ebx
        add %ecx, %ebx
        
        # move the number to buffer at index
        mov %eax, (%ebx)

        # update and set new index
        add $4, %ecx
        mov %ecx, buffer_nodes_index

        # restore address
        mov buffer_nodes_address, %edx
        jmp loop_decode_node_start

    add_to_buffer_exit:
        movl $0, 1(%ebx)
        mov $buffer_atoi, %ebx

        inc %edx

        call atoi
        mov buffer_nodes_index, %ecx
        mov $buffer_nodes, %ebx
        add %ecx, %ebx
        mov %eax, (%ebx)

        add $4, %ecx
        mov %ecx, buffer_nodes_index

        leave
        ret


get_broken_node:
/*
get_broken_node(ebx: nodes_buffer, ecx: bytes_read) --> eax: bytes_to_lseek
@note returns the number of bytes to go back to resume decoding nodes from file
*/
    pushl %ebp
    movl %esp, %ebp

    # go to last byte of nodes_buffer
    mov bytes_read, %eax
    add %ebx, %eax

    xor %ecx, %ecx

    loop_broken_node:
        # check if arrived at the start of the buffer
        cmp %eax, %ebx
        je exit_broken_node

        # cmp with new line
        mov -1(%eax), %cl
        cmp $10, %ecx
        je exit_broken_node
    
        # set byte to 0
        movb $0, (%eax)

        dec %eax
        jmp loop_broken_node

    exit_broken_node:
        sub %ebx, %eax
        sub bytes_read, %eax
   
        leave
        ret
