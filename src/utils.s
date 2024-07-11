.section .data


.section .text
.global _start, print_buffer_no_length,copy_buffer_to_buffer, print_buffer

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


    leave
    ret




# buffer in eax, lenght, ebx, returns in ecx
find_nullbyte:
    pushl %ebp
    movl %esp, %ebp
    xor %ecx, %ecx
    find_nullbyte_loop:
        cmpb $0, (%eax)         # Compare the current byte with null byte (0)
        je found_null           # If it is null, jump to found_null

        incl %eax               # Increment EDI to point to the next byte
        incl %ecx               # Increment the counter
     
        jmp find_nullbyte_loop           # Repeat the loop
    
    found_null:
    leave
    ret


# buffer in eax, length ebx
print_buffer_no_length:
    pushl %ebp
    movl %esp, %ebp
    push %eax
    call find_nullbyte
    mov %ecx, %ebx
    pop %eax
    call print_buffer
    leave
    ret

# copy buffer in ebx to buffer in ecx 
# (already at index),  
# esi has the length of the buffer in ecx

/*
source_buffer:
    .byte 0x01, 0x02, 0x00, 0x00, 0x00

dest_buffer:
    .byte 0x03, 0x04, 0x05


    mov $dest_buffer, %ebx
    mov $source_buffer, %ecx
    add $2, %ecx
    mov $3, %esi
    call copy_buffer_to_buffer
*/
copy_buffer_to_buffer:
    pushl %ebp
    movl %esp, %ebp


    # Copy loop
    copy_loop:
        mov (%ebx),%al
        mov %al, (%ecx)
        inc %ecx
        inc %ebx
        dec %esi
        test %esi,%esi

        jnz copy_loop                # Loop if not zero

    leave
    ret 