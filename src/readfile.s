.section .data
filename:
    .ascii "test_cases.txt"    # Nome del file di testo da leggere
fd:
    .int 0               # File descriptor



buffer: .space 2048       # Spazio per il buffer di input
buffer_size: .long 2048      # Spazio per il buffer di input
buffer_end: .long 0       # Spazio per il buffer di input

buffer_atoi: .space 256       

buffer_decode: .space 256       
buffer_nodes: .space 4096        
buffer_nodes_index: .long 0        
buffer_read_ptr: .long 0        
buffer_decode_address: .long 0    
buffer_nodes_address: .long 0    
   
count: .long 0    
newline: .byte 10        # Valore del simbolo di nuova linea
lines: .int 0            # Numero di linee
bytes_read:
.long 0

more_bytes:.int 0 # 0=no 1=yes

.section .bss

.section .text
    .globl _start
    .globl init_file
    .globl read_nodes

# Apre il file
# filename in ebx
init_file:
    pushl %ebp
    movl %esp, %ebp
    mov $5, %eax        # syscall open
    # mov $filename, %ebx # Nome del file
    mov $0, %ecx        # Modalità di apertura (O_RDONLY)
    int $0x80           # Interruzione del kernel

    # Se c'è un errore, esce
    cmp $0, %eax
    jl _exit1

    mov %eax, fd      # Salva il file descriptor in ebx
    leave
    ret


decode_node:
   pushl %ebp
   movl %esp, %ebp

    mov $buffer_decode, %edx
    loop_decode_node_start:
        mov $buffer_atoi, %ebx
        loop_decode_node:
            # clean the buffer at position
            mov $0, (%ebx) 
            
            mov (%edx),%al
            cmpb $44, %al # comma
            je add_to_buffer
            cmpb $0, %al # end of buffer
            je add_to_buffer_exit
            

            mov %al, (%ebx) 

            # go to next byte for atoi
            inc %ebx
            inc %edx
            jmp loop_decode_node
        
    add_to_buffer:
        mov $0, 1(%ebx) # set byte to 0 to indicate last byte
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
        mov buffer_nodes_address,%edx
        jmp loop_decode_node_start

    add_to_buffer_exit:
        mov $0, 1(%ebx)
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

# buffer in ebx, bytes read in ecx
decode_nodes:
    pushl %ebp
    movl %esp, %ebp
    xor %eax, %eax
    mov $buffer_decode, %edx
    mov %ebx, %esi
    add buffer_size, %esi
    loop_lbl:
        cmp %esi, %ebx
        je exit_decode
        
        mov (%ebx),%al
        cmpb $10, %al
        
        je call_decode
        mov %al, (%edx)
        
        # exit if last byte
        test %ecx, %ecx
        jz exit_decode

        


        dec %ecx
        inc %ebx
        inc %edx
        jmp loop_lbl
    call_decode:
        movl $0, (%edx) # set last buffer value to null byte
        inc %edx
        mov %edx, buffer_decode_address # save address
        mov %ecx, count
        mov %ebx, buffer_read_ptr
         
        call decode_node
   
        mov count, %ecx
        mov buffer_read_ptr,%ebx
        mov $buffer_decode,%edx # restore address
        
        inc %ebx
        jmp loop_lbl
    exit_decode:
        leave
        ret

# buffer in ebx, , returns in eax how many bytes to go lseek
get_broken_node:
    pushl %ebp
    movl %esp, %ebp

    # go to last byte of buffer
    mov bytes_read, %eax
    add %ebx, %eax

    xor %ecx, %ecx
    loop_broken_node:
        # check if arrived at the start of the buffer

        cmp %eax, %ebx
        je exit_broken_node

        # cmp with new line
        mov -1(%eax), %cl
        cmp $10,%ecx
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

# how much in eax, fd in $fd
lseek:
    pushl %ebp
    movl %esp, %ebp

    mov %eax, %ecx

    mov $19, %eax # lseek
    mov fd, %ebx
    # ecx 
    movl $1, %edx        # Whence: SEEK_CUR (1)
    int $0x80




    leave
    ret


# returns files read in ecx and buffer in eax
read_nodes:
    pushl %ebp
    movl %esp, %ebp
    mov $3, %eax        # syscall read
    mov fd, %ebx        # File descriptor
    mov $buffer, %ecx   # Buffer di input
    mov buffer_size, %edx        # Lunghezza massima
    int $0x80           # Interruzione del kernel
    t_read:
    mov %eax, bytes_read

    cmp $0, %eax        # Controllo se ci sono errori o EOF
    jle _close_file     # Se ci sono errori o EOF, chiudo il file
    
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
        mov $1, more_bytes
    mov $buffer, %ebx

    # restore bytes read
    mov bytes_read,%ecx
    call decode_nodes
    mov $buffer_nodes, %ebx
    jmp _exit_fun

_print_line:
    # Stampa il contenuto della riga
    mov $4, %eax        # syscall write
    mov $1, %ebx        # File descriptor standard output (stdout)
    mov $buffer, %ecx   # Buffer di output
    int $0x80           # Interruzione del kernel

    jmp read_nodes     # Torna alla lettura del file

# Chiude il file
_close_file:
    mov $0, more_bytes
    mov $6, %eax        # syscall close
    mov %ebx, %ecx      # File descriptor
    int $0x80           # Interruzione del kernel




_exit_fun:
    mov bytes_read, %ecx
    leave
    ret
_exit1:
    mov $1, %eax        # syscall exit
    xor %ebx, %ebx      # Codice di uscita 0
    int $0x80           # Interruzione del kernel
