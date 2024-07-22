/*
    readfile.s
    @note: Reads a file line by line and decodes the nodes.
    @author: Simone Di Maria, Pietro Secchi
*/


.section .data
filename:
    .asciz "test_cases.txt"    # Nome del file di testo da leggere
fd:
    .int 0               # File descriptor

bytes_to_read:
.int 12 

buffer: .space 4096       # Spazio per il buffer di input

buffer_atoi: .space 256       

buffer_to_decode: .space 256       
buffer_nodes: .space 512        
buffer_nodes_index: .long 0        
buffer_decode_address: .long 0    
buffer_nodes_address: .long 0    
count:
    .long 0    
newline:
    .byte 10    # Valore del simbolo di nuova linea
lines:
    .int 0      # Numero di linee
bytes_read:
    .long 0

more_bytes:
    .int 0      # 0=no 1=yes

.section .bss

.section .text
    .global _start
    .global atoi
    .global open_file
    .global read_tasks


open_file:
/*
open_file(ebx: filename) --> eax: fd
@note opens the file with the given filename, returns the file descriptor in eax
*/
    pushl %ebp
    movl %esp, %ebp

    mov SYS_OPEN, %eax
    mov $0, %ecx  # open file in O_RDONLY mode
    int $0x80

    # exit if error
    cmp $0, %eax
    jl exit_with_status_0

    mov %eax, fd
    leave
    ret


atoi:
/*
atoi(ebx: string) --> eax: decimal_value
@note converts the char byte to an integer, returns in eax
*/
    pushl %ebp
    movl %esp, %ebp

    xor %eax, %eax
    xor %ecx, %ecx
    xor %edx, %edx
    atoi_loop:
        mov (%ebx), %dl 
        
        # break loop if null byte (end of buffer)
        testb %dl, %dl
        jz end_loop

        imul $10, %eax
        sub $48, %edx
        add %edx, %eax
        
        # update buffer position
        inc %ebx
        jmp atoi_loop
    end_loop:
    leave
    ret


decode_nodes:
/*
decode_nodes(ebx: buffer, ecx: bytes_read) --> eax: buffer_to_decode
@note decodes the nodes from the file buffer, returns the decoded nodes in buffer_nodes
*/
    pushl %ebp
    movl %esp, %ebp

    xor %eax, %eax
    mov $buffer_to_decode, %edx
    
    decode_lines_loop:
        mov (%ebx), %al
        cmpb LINE_FEED_ASCII, %al
        
        je call_decode
        mov %al, (%edx)
        
        # exit if last byte
        test %ecx, %ecx
        jz exit_decode 

        sub $1, %ecx
        add $1, %ebx
        add $1, %edx
        jmp decode_lines_loop

    call_decode:
        movl $0, (%edx) # set last buffer value to null byte
        inc %edx
        mov %edx, buffer_decode_address # save address
        mov %ecx, count
         
        call decode_node
   
        mov count, %ecx
        mov buffer_decode_address, %edx # restore address
        
        inc %ebx
        jmp decode_lines_loop

    exit_decode:
        leave
        ret


decode_node:
/*
decode_node() --> buffer_nodes
@note decodes the nodes from the file buffer, returns the decoded nodes in buffer_nodes
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


# buffer in ebx, bytes read in ecx, returns in eax how many bytes to go lseek
get_broken_node:
/*
get_broken_node(ebx: nodes_buffer, ecx: bytes_read) --> eax: bytes_to_lseek
@note returns the number of bytes to go back to resume decoding nodes from file
*/
    pushl %ebp
    movl %esp, %ebp

    # go to last byte of nodes_buffer
    add %ecx, %eax
    add %ebx, %eax

    loop_broken_node:
        # cmp with new line
        mov (%eax), %ecx
        cmp $10, %ecx
        je exit_broken_node
    
        # set byte to 0
        movl $0, (%eax)

        dec %eax
        jmp loop_broken_node

    exit_broken_node:
    sub %ebx, %eax
    sub %ecx, %eax

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
    
    mov SYS_READ, %eax
    mov fd, %ebx
    mov $buffer, %ecx
    mov $4096, %edx
    int $0x80

    # if sys_read fails or EOF, close the file 
    cmp $0, %eax
    jle close_file

    # store the number of bytes read
    mov %ecx, %ebx
    mov %eax, %ecx

    # save bytes read
    mov %ecx, bytes_read
    call get_broken_node

    test %eax,%eax
    jz no_lseek
    
    yes_lseek:
        call lseek
    
    no_lseek:
        movl $1, more_bytes
    
    mov $buffer, %ebx

    # restore bytes read
    mov bytes_read, %ecx

    call decode_nodes
    
    leave
    ret


close_file:
    movl $0, more_bytes
    mov SYS_CLOSE, %eax
    mov %ebx, %ecx
    int $0x80


exit_with_status_0:
    mov SYS_EXIT, %eax
    xor %ebx, %ebx
    int $0x80
