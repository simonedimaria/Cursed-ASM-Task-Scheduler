/*
    sll.s
    @note: Sorted Linked List
    @author: Simone Di Maria, Pietro Secchi
*/


.section .bss
    # statically allocated variables
    .lcomm buffer, 12

.section .data

list_head:
    .long 0
list_ptr:
    .long 0
last_list_ptr:
    .long 0
value:
    .long 0
priority:
    .long 0
next:
    .long 0
first_pass:
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
start_node_index:
    .long 0
list_buffer:
    .space 1024
list_buffer_size:
    .long 1024
node_size:
    .long 16 # 4 prev + 4 next + 4 priority + 4 value


.section .text
.global sll2, add_to_list, list_to_buffer
.type sll2, @function

# head in eax, node index in ebx 0 if none else the address, mode in ecx=1 asc ecx=0 dec, returns buffer in edx, node in ebx or -1 if ended, 
# buffer will have null byte at the end
# buffer will be 4(node_value)
list_to_buffer:
/*
list_to_buffer(eax: list_head, ebx: start_node_index, ecx: order) --> edx: buffer, ebx: last_node_index
@note converts the linked list to a buffer in the order specified by given order (0: descending, 1: ascending),
      returns the buffer in edx, the last read node in ebx or -1 if the list is ended 
*/
    pushl %ebp
    movl %esp, %ebp

    mov %eax, list_head
    mov %ebx, start_node_index
    cmp $0, %ecx 
    je list_to_buffer_desc

    mov $list_buffer, %edx

    # init counter
    mov $0, %esi  
    list_to_buffer_asc:
        call get_last_node 
        mov %ebx, %ecx
        mov start_node_index, %ebx
        cmp $0, %ebx
        jne list_to_buffer_asc_iterate
        call get_first_node
        
        # while (node != last_node && i < buffer_size):
        #   buffer[i] = node
        #   node = node.next
        #   i++
        list_to_buffer_asc_iterate:
            cmp %ebx, %ecx
            je end_list_to_buffer_end

            cmp list_buffer_size, %esi
            je end_list_to_buffer

            # save node to buffer
            mov %ebx, %eax
            call get_value_value
            mov %ebx, (%ecx)

            # get next node
            call get_next_node_value
            add $4, %esi
            add $4, %ecx
            jmp list_to_buffer_asc_iterate

    list_to_buffer_desc:
        call get_first_node
        mov %ebx, %ecx
        mov start_node_index, %ebx
        cmp $0, %ebx
        jne list_to_buffer_desc_iterate        
        call get_last_node
        
        # while (node != first_node && i < buffer_size):
        #   buffer[i] = node
        #   node = node.prev
        #   i++
        list_to_buffer_desc_iterate:
            cmp %ebx, %ecx
            je end_list_to_buffer_end

            cmp list_buffer_size, %esi
            je end_list_to_buffer

            # save node to buffer
            mov %ebx, %eax
            call get_value_value
            mov %ebx, (%edx)

            # get prev node
            call get_prev_node_value
            add $4, %esi
            add $4, %edx

            jmp list_to_buffer_desc_iterate

    end_list_to_buffer_end:
        xor %ebx, %ebx

    end_list_to_buffer:
        mov $0, 4(%edx)
        mov list_buffer, %edx

        leave
        ret


# head address in eax, value in ebx,priority in ecx, sort type in edx 0=ascending 1=descending,
# Function to add a new node to the linked list
add_to_list:
/*
add_to_list(eax: list_head, ebx: value, ecx: priority) --> eax: list_head
@note adds a new node to the linked list, the new node will be sorted according to the given sort_type (0: ascending, 1: descending)
*/
    pushl %ebp
    movl %esp, %ebp

    mov %eax, list_head
    mov %ebx, value
    mov %ecx, priority

    # init last and first values
    call get_first_node
    mov %ebx, first_node
    # init list_ptr
    mov %ebx, list_ptr

    call get_last_node
    mov %ebx, last_list_ptr
    mov %ebx, last_node

    # node allocation
    call allocate_node
    mov value, %ebx
    call set_node_value
    mov %ecx, %ebx
    call set_node_priority
    mov %eax, node_address

    jmp loop_sort_start
    
    break:
        leave
        ret


loop_sort_start:
    # this will run only once to check if the node should be the last
    mov last_list_ptr, %ecx
    jmp loop_continue
    loop_sort:
        # check if list_ptr is the first node (end of list)
        mov last_list_ptr, %ecx
        cmp first_node, %ecx
        je not_found

        loop_continue:
            mov node_address, %edx
            call compare_nodes # cmp (ecx:ptr, edx:node) (node, pointer)

            jl next_node
            jge place_node  # new node has higher priority
            jmp break

    next_node:
        # store the pointer for the next iteration
        mov list_ptr, %eax
        mov %eax, last_list_ptr

        # update list_ptr to the new value
        call get_next_node_value
        mov %ebx, list_ptr

        jmp loop_sort

    place_node:
        # insert the new node between the last node and
        # the node that is lower then the new node
        mov last_list_ptr, %eax
        mov node_address, %ebx
        mov list_ptr, %ecx
        call insert_node

        call check_if_last
        jne break

        call check_if_first
        jmp break

    not_found:
        mov last_node, %eax
        mov node_address, %ebx
        mov first_node, %ecx
        call insert_node

        mov node_address, %ebx
        mov list_head, %eax
        call set_first_node

        jmp break


check_if_first:
/*
check_if_first()
@note checks if the new node is the first node in the list
*/
    pushl %ebp
    movl %esp, %ebp

    mov last_list_ptr, %ecx
    cmp first_node, %ecx # compare first_node with the ptr
    jne break

    # update first
    mov list_head, %eax
    mov node_address, %ebx
    call set_first_node
    mov %ebx, first_node

    leave
    ret


check_if_last:
/*
check_if_last()
@note checks if the new node is the last node in the list
*/
    pushl %ebp
    movl %esp, %ebp

    mov last_list_ptr, %ecx
    cmp last_node, %ecx # compare last_node with the ptr
    jne break

    # update last
    mov list_head, %eax
    mov node_address, %ebx
    call set_last_node
    mov %ebx, last_node

    leave
    ret
