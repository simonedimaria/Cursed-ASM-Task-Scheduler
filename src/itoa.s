# The number to print goes in eax

.section .data
char:
    .byte 0
.section .text
.global itoa
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
