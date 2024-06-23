# The number to print goes in eax

.section .data

itoa_buffer:
     # 2^32=4294967296, 10 chars
    .space 10
char:
    .byte 0

.section .text
.global itoa
.global itoa_to_buffer
.type itoa, @function
itoa:
    mov $0, %ecx
continua_a_dividere:
    cmp $10, %eax
    jge dividi
    pushl %eax
    inc %ecx
    mov %ecx, %ebx
    jmp stampa
dividi:
    movl $0, %edx
    movl $10, %ebx
    divl %ebx
    pushl %edx
    inc %ecx
    jmp continua_a_dividere
stampa:
    cmp $0, %ebx
    je fine_itoa
    popl %eax
    movb %al, char
    addb $48, char
    dec %ebx
    pushw %bx
    movl $4, %eax
    movl $1, %ebx
    leal char, %ecx
    mov $1, %edx
    int $0x80
    popw %bx
    jmp stampa
fine_itoa:
    movb $10, char
    movl $4, %eax
    movl $1, %ebx
    leal char, %ecx
    mov $1, %edx
    int $0x80
    ret

# given a value returns a buffer with ascii representation,
# nullbyte as end
# value in ebx, returns buffer in ebx and 
# bytes read number in esi
itoa_to_buffer:
    pushl %ebp
    movl %esp, %ebp
    mov %ebx, %eax
    mov $itoa_buffer, %ecx
    #   clean esi
    # # use esi as counter 
    xor %esi, %esi
    itoa_to_buffer_loop:
        mov $10,%ebx
        # edx:eax / ebx; quotient -> eax, remainder -> edx
        div %ebx
        # too ascii
        add $48, %edx
        mov %edx, (%ecx)
        inc %ecx
        xor %edx,%edx
        inc %esi
        test %eax, %eax
        jnz itoa_to_buffer_loop
 
 
    leave 
    ret
