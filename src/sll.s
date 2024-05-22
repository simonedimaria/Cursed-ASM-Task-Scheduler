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
    

    call allocate_head
    mov %eax, list_head
    call allocate_node
    mov %eax, %ebx
    mov list_head, %eax
    call set_first
    call set_last
    mov %ebx,%eax

    
    mov list_head,%ebx
    call set_next

    mov %ecx,%ebx
    call set_priority
    
    mov %edx,%ebx
    call set_value

    mov list_head,%eax



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

# first is the first element of the list, second is the last element
allocate_head:
    pushl %ebp
    movl %esp, %ebp

    movl $45, %eax         # brk
    xor %ebx, %ebx
    int $0x80              # Call kernel
    mov %eax, %esi

    addl $8, %eax

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
    jne dec_add_to_list
    continue:
    
    leave
    ret



asc_add_to_list:
    
    mov %eax,list_head 
    call get_first
    mov %eax, list_ptr
    xor %ecx,%ecx

    loop_asc:

        mov list_ptr, %eax
        call get_next_value
        cmp list_head, %ebx
        je not_found 

        mov list_ptr, %eax
        call get_priority_value
        cmp priority, %eax
        mov list_ptr, %ecx        # ecx is used to remember the last address
        jge lower # eax >= priority, node< to insert
        jl greater
            greater:
                call get_next_value
                mov %ebx,list_ptr 
                jmp loop_asc

            lower:



                call allocate_node

                mov value, %ebx
                call set_value
                
                mov priority, %ebx
                call set_priority
                
                # mov list_head, %ebx
                # call set_next
               
                mov %ecx,%ebx
                # mov %ecx, %eax
                call set_next 
               
dec_add_to_list:
    
    mov list_head,%eax 
    call get_first
    mov (%eax),%eax
    mov %eax, list_ptr
    xor %ecx,%ecx





    loop_dec:

        mov list_ptr, %eax
        cmp list_head, %eax
        je not_found_dec 

        xor %eax, %eax
        cmpl $0, %ebx
        je not_found_dec 




        mov list_ptr, %eax
        call get_priority_value
        cmp priority, %ebx
        mov list_ptr, %ecx        # ecx is used to remember the last address
        jge lower_dec # eax >= priority, node< to insert
        jl greater_dec

            greater_dec:
                
                call allocate_node

                mov value, %ebx
                call set_value
                
                mov priority, %ebx
                call set_priority
                
                # mov list_head, %ebx
                # call set_next
               
                
                
                mov %ecx,%ebx
                # mov %ecx, %eax
                call set_next 
               

                jmp continue
    

            lower_dec:
                call get_next_value
                mov %ebx,list_ptr 
                jmp loop_dec






not_found_dec:
    mov list_ptr, %ecx
    call allocate_node
    mov %eax, list_ptr
    mov value, %ebx
    call set_value
    mov priority, %ebx
    call set_priority

    mov list_head, %ebx
    call set_next

    mov %eax, %ebx
    mov %ecx, %eax
    call set_next

    mov list_head,%eax 
    call set_last

    jmp continue

not_found:
    call allocate_node
    
    mov %eax, list_ptr
    mov value, %ebx
    call set_value
    mov priority, %ebx
    call set_priority
    mov $0, %ebx
    # mov list_head, %ebx
    call set_next

    mov %eax, %ebx
    mov list_head, %eax
    call set_next

    jmp continue









set_last:
    pushl %ebp
    movl %esp, %ebp

    call get_last
    mov %ebx,(%eax)
    add $8,%eax

    leave
    ret

set_first:
    pushl %ebp
    movl %esp, %ebp

    call get_first
    mov %ebx,(%eax)
    add $4,%eax

    leave
    ret
get_last:
    pushl %ebp
    movl %esp, %ebp
    sub      $8,%eax
    leave
    ret

get_first:
    pushl %ebp
    movl %esp, %ebp
    sub      $4,%eax
    leave
    ret

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

get_priority_value:
    pushl %ebp
    movl %esp, %ebp
    mov  -4(%eax),%ebx
    leave
    ret

get_value_value:
    pushl %ebp
    movl %esp, %ebp
    mov  -8(%eax),%ebx
    sub      $8,%eax
    leave
    ret

get_next_value:
    pushl %ebp
    movl %esp, %ebp
    mov  -12(%eax),%ebx
    leave
    ret


set_priority:
    pushl %ebp
    movl %esp, %ebp

    call get_priority
    mov     %ebx,(%eax)
    add $4,%eax

    leave
    ret
set_value:
    pushl %ebp
    movl %esp, %ebp

    call get_value
    mov %ebx,(%eax)
    add $8,%eax

    leave
    ret
set_next:
    pushl %ebp
    movl %esp, %ebp

    call get_next
    mov %ebx,(%eax)
    add $12,%eax

    leave
    ret
