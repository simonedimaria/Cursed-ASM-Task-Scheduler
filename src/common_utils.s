/*
    common_utils.s
    @note: General utility functions.
    @author: Simone Di Maria, Pietro Secchi
*/


.section .data
    fd:
        .long 1
    itoa_buffer:
        .space 10
    char:
        .byte 0


.section .text
    .global atoi
    .global itoa
    .global itoa_to_buffer
    # .type itoa, @function
    .global open_file
    .global print_buffer
    .global print_buffer_no_length
    .global copy_buffer_to_buffer


atoi:
/*
atoi(ebx: ascii_str) --> eax: integer
@note converts an ASCII char to its decimal rapresentation and writes it to the given file descriptor.
*/
    pushl %ebp
    movl %esp, %ebp

    xor %eax, %eax
    xor %ecx, %ecx
    xor %edx, %edx

    atoi_loop:
        mov (%ebx), %dl 
        
        testb %dl, %dl
        jz end_loop
        imul $10,%eax
        sub $48, %edx
        add %edx, %eax
        
        inc %ebx
        jmp atoi_loop

    end_loop:
        leave
        ret


itoa:
/*
itoa(eax: integer, ecx: fd) --> eax: ascii_str
@note converts an integer to its ASCII representation and writes it to the given file descriptor.
*/
    pushl %ebp
    movl %esp, %ebp 
    
    mov %ecx, fd
    mov $0, %ecx

division_loop:
    cmp $10, %eax
    jge divides
    pushl %eax
    inc %ecx
    mov %ecx, %ebx
    jmp print

divides:
    movl $0, %edx
    movl $10, %ebx
    divl %ebx
    pushl %edx
    inc %ecx
    jmp division_loop

print:
    cmp $0, %ebx
    je itoa_end
    popl %eax
    movb %al, char
    addb $48, char
    dec %ebx
    pushw %bx
    movl $4, %eax
    movl fd, %ebx
    leal char, %ecx
    mov $1, %edx
    int $0x80
    popw %bx
    jmp print

itoa_end:
    leave
    ret


itoa_to_buffer:
/*
itoa_to_buffer(ebx: integer) --> ebx: buffer
@note converts an integer to its null-terminated ASCII representation and writes it to the given buffer
*/
    pushl %ebp
    movl %esp, %ebp
  
    mov %ebx, %eax
    mov $itoa_buffer, %ecx
    xor %esi, %esi
    xor %edx, %edx

    itoa_to_buffer_loop:
        mov $10,%ebx
        div %ebx
        add $48, %edx
        mov %edx, (%ecx)
        inc %ecx
        xor %edx, %edx
        inc %esi
        test %eax, %eax
        jnz itoa_to_buffer_loop 
 
    mov $itoa_buffer, %ebx
    leave
    ret


open_file:
/*
open_file(ebx: filename) --> eax: fd
@note opens a file and returns the file descriptor.
*/
    pushl %ebp
    movl %esp, %ebp

    pushl %ebx

    movl SYS_OPEN, %eax
    movl %ebx, %ebx
    movl $66, %ecx   # O_WRONLY (1) | O_CREAT (64) = 65 (66 includes O_TRUNC to truncate file)
    movl $438, %edx  # Mode: 0666 in octal (438 in decimal) - read and write for user, group, and others
    int $0x80

    popl %ebx

    leave
    ret


print_buffer:
/*
print_buffer(eax: buffer, ebx: length, ecx: fd)
@note prints the buffer to the given file descriptor.
*/
    pushl %ebp
    movl %esp, %ebp

    # Write the buffer to stdout
    movl %ebx, %edx  # length of the buffer
    movl %ecx, %ebx  # file descriptor 1 (stdout)
       
    movl %eax, %ecx       # pointer to the buffer
    movl SYS_WRITE, %eax  # syscall number for sys_write
    int $0x80             # make the syscall

    leave
    ret


print_buffer_no_length:
/*
print_buffer_no_length(eax: buffer, ebx: length, ecx: fd)
@note prints the buffer to the given file descriptor without the length.
*/
    pushl %ebp
    movl %esp, %ebp

    push %ecx
    push %eax
    call find_nullbyte
    mov %ecx, %ebx
    pop %eax
    pop %ecx
    call print_buffer
    
    leave
    ret


find_nullbyte:
/*
find_nullbyte(eax: buffer) --> ecx: buffer_length
@note finds the null byte in the buffer and returns the length of the buffer.
*/
    pushl %ebp
    movl %esp, %ebp

    xor %ecx, %ecx
    
    find_nullbyte_loop:
        cmpb $0, (%eax)
        je found_null

        incl %eax
        incl %ecx
     
        jmp find_nullbyte_loop

    found_null:
        leave
        ret


copy_buffer_to_buffer:
/*
copy_buffer_to_buffer(ebx: source_buffer, ecx: dest_buffer, esi: buffer_length)
@note copies the source buffer to the destination buffer.
*/
    pushl %ebp
    movl %esp, %ebp

    copy_loop:
        mov (%ebx), %al
        mov %al, (%ecx)
        inc %ecx
        inc %ebx
        dec %esi
        test %esi,%esi

        jnz copy_loop

    leave
    ret 
