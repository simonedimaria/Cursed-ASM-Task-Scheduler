.section .data

buffer_len = . - buffer

.section .text
.global _start

# buffer in eax, lenght in ebx
print_buffer:
    pushl %ebp
    movl %esp, %ebp

    # Write the buffer to stdout
    movl %eax, %ecx   # pointer to the buffer
    movl %ebx, %edx # length of the buffer
    movl $4, %eax        # syscall number for sys_write
    movl $1, %ebx        # file descriptor 1 (stdout)
    int $0x80            # make the syscall

    # Exit the program
    movl $1, %eax        # syscall number for sys_exit
    xorl %ebx, %ebx      # exit status 0
    int $0x80            # make the syscall

    leave
    ret




# buffer in eax, lenght, ebx, returns in ecx
find_nullbyte:
    pushl %ebp
    movl %esp, %ebp
    find_nullbyte_loop:
        cmpb $0, (%eax)         # Compare the current byte with null byte (0)
        je found_null           # If it is null, jump to found_null

        incl %eax               # Increment EDI to point to the next byte
        incl %ecx               # Increment the counter
        cmpb %ebx, %ecx         
        je found_null           
        jmp find_nullbyte_loop           # Repeat the loop
    
    found_null:
    leave
    ret


# buffer in eax, length ebx
print_buffer_no_length:
    call find_nullbyte
    mov %ecx, %ebx
    call print__buffer