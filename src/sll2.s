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

first_node:
    .long 0 
last_node:
    .long 0 
node_address: 
    .long 0
testv:  
    .long 0 
heap_location:
    .long 0 

node_size:  .long 12 # 4 next, 4 priority, 4 value       


SYS_BRK = 45              # System call number for brk
PAGE_SIZE = 4096          # Size of a page (assumed to be 4KB)
.section .text
.global sll2,add_to_list
.type sll2, @function





# head address in eax, value in ebx,priority in ecx, sort type in edx 0=ASC 1=DEC, 
# Function to add a new node to the linked list
add_to_list:
    pushl %ebp
    movl %esp, %ebp
    
    mov %eax, list_head
    mov %ebx, value
    mov %ecx, priority

    # init last and first values
    call get_first_value
    mov %ebx, first
        # init list_ptr
    mov %ebx, list_ptr
    
    call get_last_value
    mov %ebx, last
    
    
    
    
    # node allocation
    call allocate_node
    call set_value
    mov %ecx, %ebx
    call set_priority
    mov %eax, node_address
  
  
    
    
    call loop_sort

    # check if sort by asc or dec
loop_sort:
    # check if list_ptr is the list_head (end of list)
    mov list_ptr, %eax
    cmp list_head, %eax
    je not_found

    call get_first
    cmp list_ptr, %eax
    jne


    continue:
    
    leave
    ret

not_found:
    mov node_address, %ebx
    mov last, %eax
    mov list_head, %ecx
    call insert_node

    # uses ebx from before
    mov list_head, %eax
    call set_last

    jmp continue






