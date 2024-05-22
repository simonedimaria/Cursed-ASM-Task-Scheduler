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

.global sll_utils
.global allocate_node
.global allocate_head
.global init_list

.global set_last
.global set_first
.global get_first
.global get_last

.global get_next
.global get_priority
.global get_value
.global get_next_value
.global get_priority_value
.global get_value_value
.global set_value
.global set_priority
.global set_next

.type sll_utils, @function


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

    movl SYS_BRK, %eax         # brk
    xor %ebx, %ebx
    int $0x80              # Call kernel
    mov %eax, %esi

    addl node_size, %eax

    movl %eax, %ebx
    movl SYS_BRK, %eax 
    int $0x80    
    leave
    ret

# address in eax, value in ebx
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

# %ecx, %edx are nodes address, do not pass the head
compare_nodes:
    pushl %ebp
    movl %esp, %ebp
    mov %ecx,%eax
    call get_priority_value
    mov %ebx, %ecx

    mov %edx,%eax
    call get_priority_value
    mov %ebx, %edx
    
    cmp %ecx, %edx
    leave
    ret



# eax=previus node address, ebx=address of the node to insert, edx=next node
insert_node:
    pushl %ebp
    movl %esp, %ebp
    
    call set_next # points the previous node pointer to the node to insert
 

    # points the current node pointer to the next to insert
    mov %ebx, %eax 
    mov %ecx, %ebx
    call set_next 

    
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
get_last_value:
    pushl %ebp
    movl %esp, %ebp
    mov -8(%eax),%ebx
    leave
    ret
get_first_value:
    pushl %ebp
    movl %esp, %ebp
    mov -4(%eax),%ebx
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
    leave
    ret

get_next_value:
    pushl %ebp
    movl %esp, %ebp
    mov  -12(%eax),%ebx
    leave
    ret


# address in eax, value in ebx
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
