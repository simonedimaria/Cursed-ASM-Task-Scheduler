/*
    queue.s
    @note: Queue management functions.
    @author: Simone Di Maria, Pietro Secchi
*/


.section .data
    queue_head:
        .long 0
    list1:
        .long 0
    list1_ptr:
        .long 0
    list1_last_node:
        .long 0
    list2:
        .long 0
    list2_ptr:
        .long 0
    list2_last_node:
        .long 0
    queue_list_address:
        .long 0
    head_list2:
        .long 0
    algorithm:
        .long 0
    priority1:
        .long 0
    priority2:
        .long 0
    queue_size:
        .long 8
    task_id:
        .long 0
    task_duration:
        .long 0
    task_expiration:
        .long 0
    task_priority:
        .long 0
    temp:
        .long 0
    node_ptr:
        .long 0
    n_bytes_itoa:
        .long 0
    task_address:
        .long 0
    total_duration:
        .long 0
    total_penalty:
        .long 0
    buffer_address:
        .long 0
    buffer_nodes_address:
        .long 0
    buffer_queue:
        .space 1024
    buffer_queue_address:
        .long 0


.section .text
    .global init_queue
    .global init_queue_from_buffer
    .global add_tasks_to_queue_from_buf
    .global queue_to_list
    # .type init_queue, @function


init_queue:
/*
init_queue(eax: task_id, ebx: task_duration, ecx: task_expiration, edx: task_priority, esi: algorithm) --> eax: queue
@note initialize a new queue with given tasks and algorithm (0: LDF, 1: HPF)
*/
    pushl %ebp
    movl %esp, %ebp

    call create_task
    mov %eax, task_address
    call allocate_queue
    mov %eax, queue_head

    mov algorithm, %ebx
    call set_queue_algo
    mov algorithm, %esi

    cmp $1, %esi
    je init_queue_hpf

    init_queue_ldf:
        # switch priority and expiration
        mov %edx, priority2
        mov %ecx, priority1
        mov %edx, %ecx
        jmp continue_init

    init_queue_hpf:
        mov %edx, priority1
        mov %ecx, priority2

    continue_init:
        mov task_address, %edx
        call init_list
        mov priority1, %ecx
        mov %eax, %edx
        call init_list
        mov %eax, %ebx
        mov queue_head, %eax
        call set_queue_list_address

        leave
        ret


init_queue_from_buffer:
/*
init_queue_from_buffer(ebx: buffer, esi: algorithm) --> eax: queue
@note initializes a queue from a buffer.
*/
    pushl %ebp
    movl %esp, %ebp

    mov %ebx, %ecx
    mov %ebx, buffer_address
    mov %esi, algorithm

    mov (%ebx), %eax
    mov 8(%ebx), %ecx
    mov 12(%ebx), %edx

    mov 4(%ebx), %ebx

    call init_queue

    mov buffer_address, %ebx
    add $16, %ebx

    call add_tasks_to_queue_from_buf
    mov queue_head, %eax

    leave
    ret


create_task_to_queue:
/*
create_task_to_queue(eax: task_id, ebx: task_duration, ecx: task_expiration, edx: task_priority, esi: queue) --> eax: new_task_address
@note create a task in the queue by passing the task parameters.
*/
    pushl %ebp
    movl %esp, %ebp

    call create_task
    mov %eax, task_address

    mov %esi, %eax
    call get_queue_algo_value
    cmp $1, %ebx
    je add_to_queue_hpf

    add_to_queue_ldf:
        # switch priority and expiration
        mov %edx, priority2
        mov %ecx, priority1
        mov %edx, %ecx
        jmp continue_add_to_queue

    add_to_queue_hpf:
        mov %edx, priority1
        mov %ecx, priority2

    continue_add_to_queue:
        call get_first_ll_ptr_from_queue
        mov (%eax), %eax
        mov %eax, queue_list_address

        mov priority1, %ebx
        call get_node_with_priority

        # check if node is found
        cmp $-1, %eax
        jne node_found

    node_not_found:
        # init a new list if node not found
        mov priority2, %ecx
        mov task_address, %edx
        call init_list

        mov priority1, %ecx
        mov %eax, %ebx
        mov queue_list_address, %eax
        call add_to_list
        jmp continue_add_to_queue2

    node_found:
        # eax has the list1 address of the list2
        call get_node_data_ptr
        mov (%eax), %eax

        # add to second list
        mov priority2, %ecx
        mov task_address, %ebx
        call add_to_list

    continue_add_to_queue2:
        leave
        ret


add_task_to_queue:
/*
add_task_to_queue(eax: queue, ecx: task) --> eax: new_task_address
@note adds an already allocated task to the queue instead of constructing it by passing task parameters.
*/
    pushl %ebp
    movl %esp, %ebp

    mov %eax, queue_head
    mov %ecx, task_address

    mov %ecx, %eax
    call get_task_priority_value
    mov %ebx, %edx
    call get_task_expiration_value
    mov %ebx, %ecx

    mov queue_head, %eax
    call get_queue_algo_value
    cmp $1, %ebx

    je add_to_queue_hpf
    jmp add_to_queue_ldf


add_tasks_to_queue_from_buf:
/*
add_tasks_to_queue_from_buf(eax: queue, ebx: buffer) --> eax: queue
@note adds multiple tasks to the queue from a buffer.
*/
    pushl %ebp
    movl %esp, %ebp

    mov %eax, queue_head

    loop_add_tasks_to_queue_from_buf:
        mov (%ebx), %eax
        cmp $0, %eax
        je exit_add_tasks_to_queue_from_buf

        # go to buffer address
        add $16, %ebx

        # save to buffer address
        push %ebx

        call create_task_from_buffer

        # add to list
        mov %eax, %ecx
        mov queue_head, %eax
        call add_task_to_queue

        # restore the buffer address
        pop %ebx
        jmp loop_add_tasks_to_queue_from_buf

    exit_add_tasks_to_queue_from_buf:
        leave
        ret


get_queue_algo:
/*
get_queue_algo(eax: queue) --> ebx: algorithm
@note retrieve pointer to the selected algorithm for the queue.
*/
    pushl %ebp
    movl %esp, %ebp

    sub $8, %eax

    leave
    ret


get_queue_algo_value:
/*
get_queue_algo_value(eax: queue) --> ebx: algorithm
@note retrieve the value of the selected algorithm for the queue.
*/
    pushl %ebp
    movl %esp, %ebp

    mov -8(%eax), %ebx

    leave
    ret


get_first_ll_ptr_from_queue:
/*
get_first_ll_ptr_from_queue(eax: queue) --> ebx: list_address
@note retrieve the address of the list in the queue.
*/
    pushl %ebp
    movl %esp, %ebp

    sub $4, %eax

    leave
    ret


get_first_ll_addr_from_queue:
/*
get_first_ll_addr_from_queue(eax: queue) --> ebx: *list_address
@note retrieve the value of the address of the list in the queue.
*/
    pushl %ebp
    movl %esp, %ebp

    mov -4(%eax), %ebx

    leave
    ret


set_queue_list_address:
/*
set_queue_list_address(eax: queue) --> ebx: list_address
@note set the address of the list in the queue.
*/
    pushl %ebp
    movl %esp, %ebp

    call get_first_ll_ptr_from_queue
    mov %ebx, (%eax)
    add $4, %eax

    leave
    ret


set_queue_algo:
/*
set_queue_algo(eax: queue) --> ebx: algorithm
@note set the algorithm to use for the sorting of the queue.
*/
    pushl %ebp
    movl %esp, %ebp

    call get_queue_algo
    mov %ebx, (%eax)
    add $8, %eax

    leave
    ret


allocate_queue:
/*
allocate_queue() --> eax: queue
@note allocate a new queue.
*/
    pushl %ebp
    movl %esp, %ebp

    movl SYS_BRK, %eax
    xor %ebx, %ebx
    int $0x80
    mov %eax, %esi

    addl queue_size, %eax

    movl %eax, %ebx
    movl SYS_BRK, %eax
    int $0x80

    leave
    ret


queue_to_list:
/*
queue_to_list(eax: queue, esi: algorithm) --> eax: list
@note transforms a queue in memory into a linked list.
*/
    pushl %ebp
    movl %esp, %ebp

    mov %esi, algorithm
    mov %eax, queue_head

    # get the first list address
    call get_first_ll_ptr_from_queue
    mov (%eax), %eax
    mov %eax, list1

    # get the last element (desc)
    call get_last_node
    mov %ebx, list1_last_node

    # get the first element (desc)
    call get_first_node
    mov %ebx, list1_ptr
    mov %ebx, %eax

    # get the second list address
    call get_node_data_ptr
    mov (%eax), %eax
    mov %eax, list2_ptr

    mov %eax, list2

    # get the last node of the second list
    call get_first_node
    mov %ebx, list2_last_node

    queue_to_list_loop:
        mov list1_ptr, %eax

        # get next list1
        call get_prev_node_ptr
        mov (%eax), %eax
        mov %eax, temp

        # get list2 address
        call get_node_data_ptr
        mov (%eax), %ebx
        mov list2_ptr, %eax

        call merge_lists

        # chek if last list
        mov list1_last_node, %eax
        cmp list1_ptr, %eax

        je queue_to_list_exit

        mov temp, %eax
        mov %eax, list1_ptr

        jmp queue_to_list_loop

    queue_to_list_exit:
        mov list2, %eax

        leave
        ret


queue_to_buffer:
/*
**DEPRECATED**
queue_to_buffer(eax: queue, ebx: list1, ecx: list2, esi: algorithm) --> edx: penalty, ebx: buffer
@note transforms a queue into a buffer.
*/
    pushl %ebp
    movl %esp, %ebp
    mov %esi, algorithm
    mov %eax, queue_head

    cmp $0, %ebx
    jne queue_to_buffer_list_1

    call get_first_ll_ptr_from_queue
    mov (%eax), %eax
    call get_last_node

    mov $0, %ecx

    queue_to_buffer_list_1:
        cmp $0, %ecx
        jne queue_to_buffer_list_2

        mov %ebx, %edx
        mov %ebx, %eax
        call get_node_priority
        mov (%eax), %eax
        mov %eax, head_list2
        call get_last_node

        mov %ebx, %ecx
        mov %edx, %ebx

    queue_to_buffer_list_2:
        mov %ebx, list1_ptr
        mov %ecx, node_ptr

        mov head_list2, %eax
        mov %ecx, %ebx

    # call list_to_buffer
    mov %edx, buffer_nodes_address

    mov $buffer_queue, %esi
    mov %esi, buffer_queue_address

    xor %edi, %edi

    iterate_buffer:
        mov (%edx), %eax
        test %eax, %eax
        jz end_iterate

        call get_node_priority
        mov %eax, task_address

        call get_task_duration_value
        mov %ebx, task_duration

        call get_task_expiration_value
        mov %ebx, task_expiration

        call get_task_priority_value
        mov %ebx, task_priority

        call get_task_id_value
        mov %ebx, task_id

        push %edx
        xor %edx, %edx

        call itoa_to_buffer
        mov %esi, n_bytes_itoa

        pop %edx

        mov %ebx, %ecx
        mov buffer_queue_address, %ebx

        mov %edx, %ecx
        call copy_buffer_to_buffer

        mov %ebx, buffer_queue_address
        mov %ebx, %edx

        mov $58, %ebx
        mov %ebx, (%edx)

        incl buffer_queue_address

        mov total_duration, %ebx
        add task_duration, %ebx

        push %edx
        xor %edx, %edx

        call itoa_to_buffer
        mov %esi, n_bytes_itoa

        pop %edx

        mov %ebx, %ecx
        mov buffer_queue_address, %ebx

        mov %edx, %ecx
        call copy_buffer_to_buffer

        mov %ebx, buffer_queue_address
        mov %ebx, %edx

        mov $LINE_FEED_ASCII, %ebx
        mov %ebx, (%edx)
        incl buffer_queue_address

        mov total_duration, %ebx
        mov task_expiration, %eax

        cmp %ebx, %eax
        jge no_penalty

        mov task_priority, %edx
        sub %ebx, %eax
        mul %edx

        add total_penalty, %eax
        mov %eax, total_penalty

        no_penalty:
            add $4, %edx
            inc %edi

        jmp iterate_buffer

    end_iterate:
        leave
        ret
