# Sorted Linked List
.section .bss
    .lcomm buffer, 12  
.section .data
    PROT_READ     =$0x1
    PROT_WRITE    =$0x2
    MAP_PRIVATE   =$0x2
    MAP_ANONYMOUS = $0x20 
list_head:  
    .long 0 
list_ptr:  
    .long 0 
value:  
    .long 0 
priority:  
    .long 0 
next:  
    .long 0 

testv:  
    .long 0 
heap_location:
    .long 0 

node_size:  .long 12 # 4 next, 4 priority, 4 value       


SYS_BRK = 45              # System call number for brk
PAGE_SIZE = 4096          # Size of a page (assumed to be 4KB)
.section .text
.global sll,add_to_list, allocate_node, get_next, get_priority, get_value,set_value,set_priority,set_next,init_list
.type sll, @function



# priority in ecx, value in edx, return head in eax
init_list:
    pushl %ebp
    movl %esp, %ebp
    

    call allocate_node
    mov %eax, list_head
    mov %ecx,%ebx
    call set_priority
    mov list_head, %eax
    mov %edx,%ebx
    call set_value
    mov list_head, %eax



    leave
    ret

# returns address in eax
allocate_node:
    pushl %ebp
    movl %esp, %ebp

    movl $45, %eax         # brk
    xor %ebx, %ebx
    int $0x80              # Call kernel
    mov %eax, %esi

    addl node_size, %eax

    movl %eax, %ebx
    movl $45, %eax 
    int $0x80    
    leave
    ret


# head address in eax, value in ebx,priority in ecx, sort type in edx 0=ASC 1=DEC, 
# Function to add a new node to the linked list
add_to_list:
    pushl %ebp
    movl %esp, %ebp
    
    mov %eax, list_head
    mov %ebx, value
    mov %ecx, priority

    cmp $0,%edx
    je  asc_add_to_list
    continue:
    mov %eax,%eax






    
    leave
    ret



asc_add_to_list:
    
    mov list_head, %eax
    mov %eax, list_ptr


    loop_asc:

        mov list_ptr, %eax
        call get_next
        cmp list_head, %eax
        je not_found 

        mov list_ptr, %eax
        call get_priority
        cmp (%eax), %ebx
        jl lower
        jg greater
            lower:
                mov list_ptr, %eax       
                call get_next
                mov %eax, %edx       # edx is used to remember the last address
                mov list_ptr, %eax

                jmp loop_asc
            greater:
                mov %edx, %eax

                call allocate_node
                mov %eax, %ecx

                mov value, %ebx
                call set_value
                
                mov %ecx, %eax
                mov priority, %ebx
                call set_priority
                
                mov %ecx, %eax
                mov list_head, %ebx
                call set_next
               
                mov list_ptr, %eax
                mov %ecx, %ebx
                call set_next 
               
               

                jmp continue
    
    not_found:
        call allocate_node
        mov value, %ebx
        call set_value
        mov priority, %ebx
        call set_priority
        mov list_head, %ebx
        call set_next

        mov %eax, %ebx
        mov list_ptr, %eax
        call set_next


    








get_priority:
    pushl %ebp
    movl %esp, %ebp
    sub      $4,%eax
    leave
    ret

get_value:
    pushl %ebp
    movl %esp, %ebp
    sub      $8,%eax
    leave
    ret

get_next:
    pushl %ebp
    movl %esp, %ebp
    sub      $12,%eax
    leave
    ret


set_priority:
    pushl %ebp
    movl %esp, %ebp

    call get_priority
    mov     %ebx,(%eax)

    leave
    ret
set_value:
    pushl %ebp
    movl %esp, %ebp

    call get_value
    mov %ebx,(%eax)

    leave
    ret
set_next:
    pushl %ebp
    movl %esp, %ebp

    call get_next
    mov %ebx,(%eax)

    leave
    ret
