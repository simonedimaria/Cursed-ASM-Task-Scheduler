.section .data
filename:
    .ascii "test_cases.txt"    # Nome del file di testo da leggere
fd:
    .int 0               # File descriptor

bytes_to_read:
.int 4096 
buffer: .space 4096       # Spazio per il buffer di input
buffer_atoi: .space 256       
buffer_decode: .space 256       
buffer_nodes: .space 512        
buffer_nodes_index: .long 0        
buffer_decode_address: .long 0    
buffer_nodes_address: .long 0    
   
newline: .byte 10        # Valore del simbolo di nuova linea
lines: .int 0            # Numero di linee
bytes_read:
.long 0

.section .bss

.section .text
    .globl _start
    .globl atoi
    .globl init_file
    .globl read_nodes

# Apre il file
# filename in ebx
init_file:
    pushl %ebp
    movl %esp, %ebp
    mov $5, %eax        # syscall open
    mov $filename, %ebx # Nome del file
    mov $0, %ecx        # Modalità di apertura (O_RDONLY)
    int $0x80           # Interruzione del kernel

    # Se c'è un errore, esce
    cmp $0, %eax
    jl _exit1

    mov %eax, fd      # Salva il file descriptor in ebx
    leave
    ret

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
        mov $0, buffer_nodes_index

        leave
        ret

# buffer in ebx, bytes read in ecx
decode_nodes:
    pushl %ebp
    movl %esp, %ebp
    xor %eax, %eax
    mov $buffer_decode, %edx
    loop_lbl:
    
        mov (%ebx),%al
        cmpb $10, %al
        
        je call_decode
        mov %al, (%edx)
        
        # exit if last byte
        test %ecx, %ecx
        jz exit_decode 

        sub $1,%ecx
        add $1, %ebx
        add $1, %edx
        jmp loop_lbl
    call_decode:
        inc %edx
        movl $0, (%edx) # set last buffer value to null byte
        mov %edx, buffer_decode_address # save address
         
        call decode_node
   
        mov buffer_decode_address,%edx # restore address
        jmp loop_lbl
    exit_decode:
        leave
        ret
# Legge il file riga per riga
read_nodes:
    mov $3, %eax        # syscall read
    mov fd, %ebx        # File descriptor
    mov $buffer, %ecx   # Buffer di input
    mov bytes_to_read, %edx        # Lunghezza massima
    int $0x80           # Interruzione del kernel

    cmp $0, %eax        # Controllo se ci sono errori o EOF
    jle _close_file     # Se ci sono errori o EOF, chiudo il file
    
    # store the number of bytes read
    mov %ecx, %ebx
    mov %eax, %ecx

    call decode_nodes
    jmp _exit1

_print_line:
    # Stampa il contenuto della riga
    mov $4, %eax        # syscall write
    mov $1, %ebx        # File descriptor standard output (stdout)
    mov $buffer, %ecx   # Buffer di output
    int $0x80           # Interruzione del kernel

    jmp read_nodes     # Torna alla lettura del file

# Chiude il file
_close_file:
    mov $6, %eax        # syscall close
    mov %ebx, %ecx      # File descriptor
    int $0x80           # Interruzione del kernel




_exit1:
    mov $1, %eax        # syscall exit
    xor %ebx, %ebx      # Codice di uscita 0
    int $0x80           # Interruzione del kernel
