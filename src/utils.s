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
menu_msg:
    .asciz "Inserisci il valore appropriato per selezionare l'algoritmo desiderato:\n0 per uscire\n1 per utilizzare l'algoritmo EDF (Earliest Deadline First).\n2 per utilizzare l'algoritmo HPF (Highest Priority First).\n:"
menu_msg_length:
    .long 206
input:
    .space 2
fd:
    .long 1
filename:
    .asciz "test_cases.txt"
buffer_read_address:
    .long 0
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
# fd in ecx
print_buffer:
    pushl %ebp
    movl %esp, %ebp

    # Write the buffer to stdout
    movl %ebx, %edx # length of the buffer
    movl %ecx, %ebx # file descriptor 1 (stdout)
       
    movl %eax, %ecx   # pointer to the buffer
    movl SYS_WRITE, %eax        # syscall number for sys_write
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


# buffer in eax, length ebx fd in ecx
print_buffer_no_length:
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

# fd in ecx, returns selection in eax 1=EDF 2=HPF
print_menu_and_input:
    pushl %ebp
    movl %esp, %ebp
    
    mov %ecx, fd
    mov $menu_msg, %eax
    mov menu_msg_length, %ebx
    call print_buffer

    movl $3, %eax            # sys_read
    movl $0, %ebx            # file descriptor (stdin)
    movl $input, %ecx        # pointer to buffer
    movl $1, %edx            # number of bytes to read
    int $0x80

    # print also the input to file (not stdout)
    mov fd, %ecx
    cmp $1, %ecx
    je end_print_menu_and_input

    mov $input, %eax
    mov $2, %ebx
    call print_buffer

    end_print_menu_and_input:
    mov $input, %ebx
    mov $0, 4(%ebx) # keep only first byte of buffer
    call atoi


    end_test:

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

# filename in ebx, returns fd in eax
open_file:
    pushl %ebp            # Save the base pointer
    movl %esp, %ebp       # Establish a new base pointer

    pushl %ebx            # Save the filename pointer (ebx) onto the stack

    movl $5, %eax         # sys_open is syscall number 5
    movl %ebx, %ebx       # Move filename pointer into ebx (already there)
    movl $66, %ecx        # Flags: O_WRONLY (1) | O_CREAT (64) = 65 (66 includes O_TRUNC to truncate file)
    movl $438, %edx       # Mode: 0666 in octal (438 in decimal) - read and write for user, group, and others

    int $0x80             # Call kernel

    popl %ebx             # Restore the original value of ebx



    leave
    ret                   # Return to caller

# buffer address in %ebx result in eax
atoi:
    pushl %ebp
    movl %esp, %ebp
    xor %eax, %eax
    xor %ecx, %ecx # sum
    xor %edx, %edx
    atoi_loop:
        mov (%ebx), %dl 
        
        # test if last byte
        testb %dl, %dl
        jz end_loop
        imul $10,%eax
        sub $48, %edx
        add %edx, %eax
        
        # update buffer position
        inc %ebx
        jmp atoi_loop
    end_loop:
    leave
    ret


benchmark:
    pushl %ebp
    movl %esp, %ebp

    start_benchmark:
    mov filename, %ebx

    call init_file
    call read_nodes
    # mov %ecx, bytes_read
    mov %ebx,buffer_read_address
    
    call print_menu_and_input
    mov %eax, %esi
    dec %esi
    mov buffer_read_address, %ebx
    call init_queue_from_buffer


    leave
    ret
