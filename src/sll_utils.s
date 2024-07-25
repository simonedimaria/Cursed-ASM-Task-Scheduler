/*
    sll_utils.s
    @note: Linked List utility functions
    @author: Simone Di Maria, Pietro Secchi
*/


.section .data
    list_head:
        .long 0  # list_head = [first_node, last_node] 
    value:  
        .long 0 
    priority:  
        .long 0 
    next:  
        .long 0 
    prev:  
        .long 0 
    node_size:
        .long 16  # 4 prev + 4 next + 4 priority + 4 value


.section .text
    .global init_list
    .global allocate_node
    .global allocate_head
    .global insert_node
    .global compare_nodes
    # setters
    .global set_first_node
    .global set_last_node
    .global set_prev_node
    .global set_next_node
    .global set_next_and_prev_node
    .global set_node_value
    .global set_node_priority
    # getters
    .global get_first_node
    .global get_first_node_ptr
    .global get_last_node
    .global get_last_node_ptr
    .global get_next_node_ptr
    .global get_next_node_address
    .global get_prev_node_ptr
    .global get_prev_node_address
    .global get_node_priority
    .global get_node_priority_ptr
    .global get_node_with_priority
    .global get_node_data_ptr
    .global get_value_value
    # .type sll_utils, @function # @todo ??


init_list:
/*
init_list(ecx: task_priority, edx: task_value) --> eax: head_addr
@note Initalize Linked List: create head, first node, set first node as last node, set first node priority and value.
*/
    pushl %ebp
    movl %esp, %ebp
    
    call allocate_head
    mov %eax, list_head

    call allocate_node
    mov %eax, %ebx
    mov list_head, %eax
    
    call set_last_node       # set_last_node(ebx: last_node_addr)
    call set_first_node      # set_first_node(ebx: first_node_addr)
    mov %ebx, %eax

    mov %eax, %ebx
    call set_next_node       # set_next_node(eax: list_head, ebx: first_node_addr)
    call set_prev_node

    mov %ecx, %ebx
    call set_node_priority
    
    mov %edx, %ebx
    call set_node_value

    mov list_head, %eax

    leave
    ret


allocate_node:
/*
allocate_node() --> eax: node_addr
@note allocates memory for a node for linked list, returns address in eax.
*/
    pushl %ebp
    movl %esp, %ebp

    movl SYS_BRK, %eax
    xor %ebx, %ebx
    int $0x80
    
    mov %eax, %esi
    addl node_size, %eax

    movl %eax, %ebx
    movl SYS_BRK, %eax 
    int $0x80
    
    leave
    ret


allocate_head:
/*
allocate_head() --> eax: head_addr
@note allocate head node for the linked list, returns address in eax.
*/
    pushl %ebp
    movl %esp, %ebp

    movl SYS_BRK, %eax
    xor %ebx, %ebx
    int $0x80

    mov %eax, %esi

    addl $8, %eax   # head is 8 bytes: 4 byte first node address + 4 byte last node address
    
    movl %eax, %ebx
    movl SYS_BRK, %eax 
    int $0x80    
    
    leave
    ret


insert_node:
/*
insert_node(eax: prev_node_addr, ebx: new_node_addr, ecx: next_node_addr) --> eax: head_addr
@note insert a (allocated) node between two nodes.
*/
    pushl %ebp
    movl %esp, %ebp
    
    mov %eax, prev

    # point the prev_node_addr pointer to the node to insert
    # prev_node->new_node
    call set_next_node 
 
    # point the current node pointer to the next to insert
    # prev_node->new_node->next_node
    mov %ebx, %eax 
    mov %ecx, %ebx
    call set_next_node

    # point the old node address as prev of current node
    # prev_node<->new_node->next_node
    mov prev, %ebx
    call set_prev_node

    # point the new node address as prev of next node
    # prev_node<->new_node<->next_node
    mov %eax, %ebx
    mov %ecx, %eax
    call set_prev_node

    leave
    ret


compare_nodes:
/*
compare_nodes(ecx: node1_addr, edx: node2_addr) --> eax: 1 if node1 > node2, 0 if node1 == node2, -1 if node1 < node2
@note compare two nodes by their priority.
*/
    pushl %ebp
    movl %esp, %ebp

    mov %ecx, %eax
    call get_node_priority
    mov %ebx, %ecx

    mov %edx, %eax
    call get_node_priority
    mov %ebx, %edx
    
    cmp %ecx, %edx
    
    leave
    ret


set_first_node:
/*
set_first_node(eax: list_head, ebx: first_node_addr) --> eax: head_addr
@note set first node address in head
*/
    pushl %ebp
    movl %esp, %ebp

    # list_head[0] = first_node_addr
    call get_first_node_ptr
    mov %ebx, (%eax)
    add $8, %eax

    leave
    ret


set_last_node:
/*
set_last_node(eax: list_head, ebx: last_node_addr) --> eax: head_addr
@note set last node address in head
*/
    pushl %ebp
    movl %esp, %ebp

    # list_head[1] = last_node_addr
    call get_last_node_ptr
    mov %ebx, (%eax)
    add $4, %eax

    leave
    ret


set_next_node:
/*
set_next_node(eax: node_addr, ebx: next_node_addr) --> eax: node_addr
@note set pointer of next node in the given node
*/
    pushl %ebp
    movl %esp, %ebp

    call get_next_node_ptr
    mov %ebx, (%eax)
    add $12, %eax

    leave
    ret


set_prev_node:
/*
set_prev_node(eax: node_addr, ebx: prev_node_addr) --> eax: node_addr
@note set pointer of previous node in the given node.
*/
    pushl %ebp
    movl %esp, %ebp

    call get_prev_node_ptr
    mov %ebx, (%eax)
    add $16, %eax

    leave
    ret


 set_next_and_prev_node:
/*
set_next_and_prev_node(eax: node_addr, ebx: next_node_addr) --> eax: node_addr
@note set pointer of next node in the given node and set pointer of previous node in the next node, eax<->ebx.
*/
    pushl %ebp
    movl %esp, %ebp

    push %eax
    push %ebx
    call set_next_node

    # in reverse
    pop %eax
    pop %ebx

    call set_prev_node

    leave
    ret


set_node_value:
/*
set_node_value(eax: node_addr, ebx: priority) --> eax: node_addr
@note set value at given node address
*/
    pushl %ebp
    movl %esp, %ebp

    call get_node_data_ptr
    mov %ebx, (%eax)
    add $8, %eax

    leave
    ret


set_node_priority:
/*
set_node_priority(eax: node_addr, ebx: priority) --> eax: node_addr
@note set priority value at given node address
*/
    pushl %ebp
    movl %esp, %ebp

    call get_node_priority_ptr
    
    # *node.priority = priority
    mov %ebx, (%eax)
    add $4, %eax

    leave
    ret


get_first_node:
/*
get_first_node(eax: list_head) --> ebx: first_node_ptr
@note retrieve first node address from list head.
*/
    pushl %ebp
    movl %esp, %ebp
    
    # return *list_head[0]
    mov -8(%eax), %ebx
    
    leave
    ret


get_first_node_ptr:
/*
get_first_node_ptr(eax: list_head) --> eax: first_node_addr
@note get pointer to the first node from the list head.
*/
    pushl %ebp
    movl %esp, %ebp

    # return list_head[0]
    sub $8, %eax 
    
    leave
    ret


get_last_node:
/*
get_last_node(eax: list_head) --> ebx: last_node_ptr
@note retrieve last node address from list head.
*/
    pushl %ebp
    movl %esp, %ebp
    
    # return *list_head[1]
    mov -4(%eax), %ebx
    
    leave
    ret


get_last_node_ptr:
/*
get_last_node_ptr(eax: list_head) --> eax: last_node_addr
@note get pointer to the last node from the list head.
*/
    pushl %ebp
    movl %esp, %ebp
    
    # return list_head[1]
    sub $4, %eax
    
    leave
    ret


get_next_node_ptr:
/*
get_next_node_ptr(eax: node_addr) --> eax: next_node_addr
@note get next node in the linked list pointed by given node_addr. 
*/
    pushl %ebp
    movl %esp, %ebp
    
    sub $12, %eax
    
    leave
    ret


get_next_node_address:
/*
get_next_node_address(eax: node_addr) --> ebx: next_node_address
@note get next node value from node address.
*/
    pushl %ebp
    movl %esp, %ebp
    
    mov -12(%eax), %ebx
    
    leave
    ret


get_prev_node_ptr:
/*
get_prev_node_ptr(eax: node_addr) --> eax: prev_node_addr
@note get previous node in the linked list pointed by given node_addr.
*/
    pushl %ebp
    movl %esp, %ebp
    
    sub $16, %eax
    
    leave
    ret


get_prev_node_address:
/*
get_prev_node_address(eax: node_addr) --> ebx: prev_node_address
@note get previous node value from node address.
*/
    pushl %ebp
    movl %esp, %ebp

    mov -16(%eax), %ebx
    
    leave
    ret


get_node_priority:
/*
get_node_priority(eax: node_addr) --> ebx: priority
@note get priority value from the node.
*/
    pushl %ebp
    movl %esp, %ebp
    
    mov -4(%eax), %ebx
    
    leave
    ret


get_node_priority_ptr:
/*
get_node_priority_ptr(eax: node_addr) --> eax: priority_addr
@note retrieve pointer to the node priority value.
*/
    pushl %ebp
    movl %esp, %ebp
    
    sub $4, %eax
    
    leave
    ret


get_node_with_priority:
/*
get_node_with_priority(eax: list_head, ebx: target_priority) --> eax: node_addr
@note search a node in the list with the given target_priority, returns its pointer or -1 if no node with target_priority was found.
*/
    pushl %ebp
    movl %esp, %ebp
    
    call get_last_node_ptr
    mov (%eax), %eax    
    mov %eax, %edx    

    mov %ebx, %ecx
    # for node in list: if node.priority == target_priority: return node
    loop_get_node_with_priority:
        call get_node_priority  # starts from head
        cmp %ebx, %ecx
        je return_matched_node  # if found, return ptr to that node
        call get_next_node_ptr
        mov (%eax), %eax
        cmp %eax, %edx          # if next_node is NULL:
        je node_not_found       #   return -1
        jmp loop_get_node_with_priority

    node_not_found:
        mov $-1, %eax
        jmp end_get_node_with_priority
    
    return_matched_node:
    end_get_node_with_priority:
        leave
        ret


get_node_data_ptr:
/*
get_node_data_ptr(eax: node_addr) --> eax: value_addr
@note retrieve pointer to the node data value.
*/
    pushl %ebp
    movl %esp, %ebp
    
    sub $8, %eax
    
    leave
    ret


get_value_value:
/*
get_value_value(eax: node_addr) --> ebx: value
@note get value from the node.
*/
    pushl %ebp
    movl %esp, %ebp
    
    mov -8(%eax), %ebx
    
    leave
    ret
