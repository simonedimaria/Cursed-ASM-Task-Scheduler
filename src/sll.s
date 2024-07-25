/*
    sll.s
    @note: Sorted Linked List
    @author: Simone Di Maria, Pietro Secchi
*/


.section .data
    is_first:
        .long 0
    task_id:
        .long 0
    task:
        .long 0
    expiration:
        .long 0
    duration:
        .long 0
    node_ptr:
        .long 0
    list_head:
        .long 0
    list_ptr:
        .long 0
    list2:
        .long 0
    list1:
        .long 0
    list:
        .long 0
    list1_last_node:
        .long 0
    list1_first_node:
        .long 0
    list2_first_node:
        .long 0
    list2_last_node:
        .long 0
    last_list_ptr:
        .long 0
    value:
        .long 0
    priority:
        .long 0
    total_duration:
        .long 0
    total_penalty:
        .long 0
    first_node:
        .long 0
    last_node:
        .long 0
    node_address:
        .long 0
    start_node_index:
        .long 0
    node_index_addres:
        .long 0
    list_buffer:
        .space 1024
    list_buffer_size:
        .long 1024
    fd:
        .long 1
    conclusione_msg:
        .asciz "Conclusione: "
    penalty_msg:
        .asciz "Penalty: "


.section .text
    .global add_to_list
    .global merge_lists
    .global print_list


add_to_list:
/*
add_to_list(eax: list_head, ebx: value, ecx: priority) --> eax: list_head
@note adds a new node to the linked list, the new node will be sorted according to the given sort_type (0: ascending, 1: descending).
*/
    pushl %ebp
    movl %esp, %ebp
    movl $1, is_first
    mov %eax, list_head
    mov %ebx, value
    mov %ecx, priority

    # init last and first values
    call get_last_node
    mov %ebx, first_node

    # init list_ptr
    mov %ebx, list_ptr

    call get_first_node
    mov %ebx, last_list_ptr
    mov %ebx, last_node

    # node allocation
    call allocate_node
    mov value, %ebx
    call set_node_value
    mov %ecx, %ebx
    call set_node_priority
    mov %eax, node_address

    jmp loop_sort

    continue:
        leave
        ret

    loop_sort:
        mov list_ptr, %ecx
        mov node_address, %edx
        call compare_nodes  # (ecx:ptr, edx:node) (node, pointer)

        # new node has higher priority
        jl place_node
        movl $0, is_first
        
        mov list_ptr, %eax 
        mov %eax, last_list_ptr
        
        call get_next_node_address
        mov %ebx, list_ptr
        
        cmp first_node, %ebx  # last_node, list_ptr
        jne loop_sort

        mov list_head, %eax
        mov node_address, %ebx
        call set_first_node

        jmp place_node

    place_node:
        mov is_first, %ebx
        test %ebx, %ebx
        jz not_first

        mov list_head, %eax

        mov node_address, %ebx
        call set_last_node
    
    not_first:
        mov last_list_ptr, %eax
        mov node_address, %ebx
        mov list_ptr, %ecx
        call insert_node
        jmp continue
    

merge_lists:
/*
merge_lists(eax: list1, ebx: list2) --> eax: merged_list
@note merges two linked lists into one, the new list will be sorted according to the given sort_type (0: ascending, 1: descending).
*/
    pushl %ebp
    movl %esp, %ebp

    mov %eax, list1
    mov %ebx, list2

    call get_first_node
    mov %ebx, list1_last_node

    call get_last_node
    mov %ebx, list1_first_node

    mov list2,%eax
    call get_first_node
    mov %ebx, list2_last_node

    call get_last_node
    mov %ebx, list2_first_node

    # link circularly the next node
    mov list1_last_node, %eax
    mov list2_first_node, %ebx

    call set_next_and_prev_node

    mov list2_last_node, %eax
    mov list1_first_node, %ebx

    call set_next_and_prev_node

    mov list1,%eax
    mov list2_last_node, %ebx
    call set_first_node

    leave
    ret


print_list:
/*
print_list(eax: list, ebx: fd, esi: algorithm) --> eax: list
@note prints the list in id:time format in the given order (0: descending, 1: ascending) to the given file descriptor.
*/
    pushl %ebp
    movl %esp, %ebp

    movl $0, total_duration
    movl $0, total_penalty

    push %ecx
    mov %ecx, fd
    mov %eax, list

    call get_first_node
    mov %ebx, last_node
    
    call get_last_node
    mov %ebx, first_node
    mov %ebx, %eax

    test %esi, %esi
    jz print_list_reverse_init
    jmp print_list_straight_init

    print_list_reverse_init:
        mov last_node, %eax
        mov %eax, node_ptr
        jmp print_list_loop
    
    print_list_straight_init:
        mov first_node, %eax
        mov %eax, node_ptr

    print_list_loop:
        call get_value_value
        mov %ebx, task
        mov %ebx, %eax
        call get_task_id_value
        mov %ebx, task_id

        mov task, %eax

        call get_task_priority_value
        mov %ebx, priority

        call get_task_expiration_value
        mov %ebx, expiration

        call get_task_duration_value
        mov %ebx, duration

        mov total_duration, %eax
        add %ebx, %eax      # time after task completition
        
        mov expiration, %ebx
        subl %ebx, %eax     # res = expiration - final_time

        js not_expired
        
        expired:
            imull priority, %eax    # priority * how many ticks expired
            add total_penalty, %eax
            mov %eax, total_penalty
        
        not_expired:
            mov duration, %eax
            add total_duration, %eax
            mov %eax, total_duration
        
        mov fd, %ecx
        mov task_id, %eax
        call itoa

        mov $COLON_ASCII, %eax
        mov $1, %ebx
        mov fd, %ecx
        call print_buffer

        mov fd, %ecx
        mov total_duration, %eax
        call itoa

        # mov $COLON_ASCII, %eax
        # mov $1, %ebx
        # mov fd, %ecx
        # call print_buffer

        # mov expiration, %eax
        # mov fd, %ecx
        # call itoa

        # mov $COLON_ASCII, %eax
        # mov fd, %ecx
        # mov $1, %ebx
        # call print_buffer
        
        # mov priority, %eax
        # mov fd, %ecx
        # call itoa
        
        mov $LINE_FEED_ASCII, %eax
        mov $1, %ebx
        mov fd, %ecx

        call print_buffer

        test %esi, %esi
        jz print_list_reverse
        jmp print_list_straight

    print_list_reverse:
        mov first_node, %eax
        cmp node_ptr, %eax
        je print_list_exit
        mov node_ptr, %eax
        call get_prev_node_address
        mov %ebx, %eax
        mov %ebx, node_ptr
        jmp print_list_loop

    print_list_straight:
        mov last_node, %eax
        cmp node_ptr, %eax
        je print_list_exit

        mov node_ptr, %eax
        call get_next_node_address
        mov %ebx, %eax
        mov %ebx, node_ptr
        
        jmp print_list_loop

    print_list_exit:
        mov $conclusione_msg, %eax
        mov fd, %ecx

        call print_buffer_no_length

        mov total_duration, %eax
        mov fd, %ecx
        call itoa
        mov $LINE_FEED_ASCII, %eax
        mov $1, %ebx
        mov fd, %ecx

        call print_buffer

        mov $penalty_msg, %eax
        mov fd, %ecx

        call print_buffer_no_length
        mov total_penalty, %eax
        mov fd, %ecx
        call itoa
        mov $LINE_FEED_ASCII, %eax
        mov $1, %ebx
        mov fd, %ecx

        call print_buffer
        pop %ecx

        leave
        ret


check_if_first:
/*
check_if_first()
@note checks if the new node is the first node in the list, if so updates the first node.
*/
    pushl %ebp
    movl %esp, %ebp

    mov last_list_ptr, %ecx
    # compare first_node with the ptr
    cmp first_node, %ecx
    jne check_if_first_exit

    # update first
    mov list_head, %eax
    mov node_address, %ebx
    call set_last_node
    mov %ebx, first_node

    check_if_first_exit:
        leave
        ret


check_if_last:
/*
check_if_last()
@note checks if the new node is the last node in the list, if so updates the last node.
*/
    pushl %ebp
    movl %esp, %ebp

    mov list_ptr, %ecx
    # compare last_node with the ptr
    cmp last_node, %ecx
    jne check_if_last_exit

    # update last
    mov list_head, %eax
    mov node_address, %ebx
    call set_first_node
    mov %ebx,last_node
    
    check_if_last_exit:
        leave
        ret


list_to_buffer:
/*
**DEPRECATED**
list_to_buffer(eax: list_head, ebx: start_node_index, ecx: order) --> edx: buffer, ebx: last_node_index
@note converts the linked list to a buffer in the order specified by given order (0: descending, 1: ascending),
      returns the buffer in edx, the last read node in ebx or -1 if the list is ended.
*/
    pushl %ebp
    movl %esp, %ebp

    mov %ebx, node_index_addres
    mov %eax, list_head
    cmp $0,%esi 

    mov $list_buffer, %ecx

    # init counter
    mov $0, %edi
    je list_to_buffer_desc

    list_to_buffer_asc:
        call get_first_node 
        mov %ebx, %ecx
        mov start_node_index, %ebx
        cmp $0, %ebx
        jne list_to_buffer_asc_iterate
        call get_last_node
        
        # while (node != last_node && i < buffer_size):
        #   buffer[i] = node
        #   node = node.next
        #   i++
        list_to_buffer_asc_iterate:
            # save node to buffer
            mov %ebx, %eax
            call get_value_value
            mov %ebx, (%ecx)
            mov node_index_addres, %eax

            # get next node
            call get_next_node_address

            cmp %edx, %ebx
            je end_list_to_buffer_end

            cmp list_buffer_size, %edi
            je end_list_to_buffer
            inc %edi
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

            cmp list_buffer_size, %edi
            je end_list_to_buffer

            # save node to buffer
            mov %ebx, %eax
            call get_value_value
            mov %ebx, (%edx)

            # get prev node
            call get_prev_node_address
            add $4, %esi
            add $4, %edx

            jmp list_to_buffer_desc_iterate

    end_list_to_buffer_end:
        # make ebx 0 to signal the end of the list
        xor %ebx, %ebx

    end_list_to_buffer:
        movl $0, 4(%edx)
        mov list_head,%eax
        mov list_buffer, %edx

        leave
        ret
