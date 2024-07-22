/*
    utils.s
    @note: General utility functions.
    @author: Simone Di Maria, Pietro Secchi
*/

.section .bss
    # statically allocated variables
    .lcomm buffer, 12

.section .data
arg1_buffer: .space 256  # Buffer per salvare il primo argomento

.section .text
.global save_first_argument
.global print_buffer
.global print_buffer_no_length


save_first_argument:
/*
save_first_argument(argv) --> arg1_buffer
@note: Saves the first argument in a buffer.
*/
    pushl %ebp
    movl %esp, %ebp

    # Ottieni il puntatore agli argomenti
    movl 8(%ebp), %esi  # %esi punta all'indirizzo di argv

    # Puntatore al primo argomento
    movl 4(%esi), %esi  # %esi punta al primo argomento

    # Salva il primo argomento nel buffer
    movl $arg1_buffer, %edi
    movl $256, %ecx     # Lunghezza massima filename in linux

    rep movsb

    leave
    ret


# buffer in eax, lenght in ebx
print_buffer:
    pushl %ebp
    movl %esp, %ebp

    # Write the buffer to stdout
    movl %eax, %ecx      # pointer to the buffer
    movl %ebx, %edx      # length of the buffer
    movl SYS_WRITE, %eax        # syscall number for sys_write
    movl $1, %ebx        # file descriptor 1 (stdout)
    int $0x80            # make the syscall

    # Exit the program
    movl SYS_EXIT, %eax        # syscall number for sys_exit
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
        cmp %ebx, %ecx         
        je found_null           
        jmp find_nullbyte_loop  # Repeat the loop
    
    found_null:
    leave
    ret


# buffer in eax, length ebx
print_buffer_no_length:
    call find_nullbyte
    mov %ecx, %ebx
    call print_buffer
