/*
    queue.s
    @note: Queue management functions.
    @author: Simone Di Maria, Pietro Secchi
*/


.section .bss
    # statically allocated variables
    .lcomm buffer, 12

.section .data
queue_head:  
    .long 0 
list1:
    .long 0
list1_ptr:
    .long 0
list1_last:
    .long 0

list2_ptr:
    .long 0
list2:
    .long 0

list2_last_node:
    .long 0
queue_list_address:
    .long 0
id:  
    .long 0 
head_list2:
    .long 0


mode:
    .long 0
method:
    .long 0
duration:  
    .long 0 
expiration:  
    .long 0 
priority:  
    .long 0 
priority1:      # priority of first list  
    .long 0 
priority2:      # priority of second list
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
.global add_tasks_to_queue_from_buffer
.global init_queue_from_buffer
.global queue_to_buffer
.global queue_to_list

.type init_queue, @function

get_queue_method:
    pushl %ebp
    movl %esp, %ebp

    sub $8, %eax

    leave
    ret

get_queue_list_address:
    pushl %ebp
    movl %esp, %ebp

    sub $4, %eax

    leave
    ret


get_queue_method_value:
    pushl %ebp
    movl %esp, %ebp

    mov -8(%eax), %ebx

    leave
    ret


get_queue_list_address_value:
    pushl %ebp
    movl %esp, %ebp

    mov -4(%eax), %ebx

    leave
    ret


set_queue_list_address:
    pushl %ebp
    movl %esp, %ebp
    
    call get_queue_list_address    
    mov %ebx, (%eax)         
    add $4, %eax             

    leave
    ret


set_queue_method:
    pushl %ebp
    movl %esp, %ebp
    
    call get_queue_method    
    mov %ebx, (%eax)         
    add $8, %eax             

    leave
    ret


allocate_queue:
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


# id in eax, duration in ebx, expiration in ecx,priority in edx, 
# method in %esi 0=LDF, 1=HPF, return address in eax
init_queue:
    pushl %ebp
    movl %esp, %ebp

    call task
    mov %eax, task_address
    call allocate_queue
    mov %eax, queue_head

    mov method, %ebx
    call set_queue_method
    mov method, %esi

    # HPF
    cmp $1, %esi
    je init_queue_hpf

    init_queue_ldf:
        # switch priority and expiration
        # us expiration as priority
        mov %edx, priority2
        mov %ecx, priority1
        mov %edx, %ecx
        jmp continue_init
    
    init_queue_hpf:
        mov %edx, priority1
        mov %ecx, priority2
        # mov %ecx, %ecx
    
    continue_init:
    
    mov task_address,%edx

    # init list with priority or expiration
    call init_list

    mov priority1, %ecx
    mov %eax, %edx
    
    call init_list
    mov %eax, %ebx
    mov queue_head, %eax
    call set_queue_list_address

    leave
    ret

# IRREVERSABLE PROCESS
# transforms a queue into a single linked list
# queue in eax,
# mode in esi 1=HPF, 0=LDF
# returns in eax the list
queue_to_list:
    pushl %ebp
    movl %esp, %ebp

    mov %esi, mode
    mov %eax, queue_head

    # test %esi, %esi
    # jz queue_to_list_ldf
    # queue_to_list:

        # get the first list address
        call get_queue_list_address
        mov (%eax), %eax
        mov %eax, list1
        
        # get the last element (dec)
        call get_last_node
        mov %ebx, list1_last

        # get the first element (dec) 
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

        # in list1_ptr there is the first
        # list node address

        # in list2_ptr there is the second
        # list node address 

        queue_to_list_loop:
            mov list1_ptr,%eax

            # get next list1
            call get_prev_node_ptr 
            mov (%eax), %eax
            mov %eax, temp

            # get list2 address
            call get_node_data_ptr
            mov (%eax), %ebx
            mov list2_ptr,%eax
            # now i have in ebx the new list and in eax 
            # the previous list

            call merge_lists


            # chek if last list
            mov list1_last, %eax
            cmp list1_ptr, %eax

            je queue_to_list_exit

            mov temp, %eax
            mov %eax, list1_ptr

            jmp queue_to_list_loop

    queue_to_list_exit:
    mov list2, %eax

    leave 
    ret



# queue in eax, list 1 index node address in ebx 
# (0 if start or address)
# list 2 index node address in ecx (0 if start or address), 
# mode in esi 0=dec, 1=asc
# returns in edx the penalty, in ebx the buffer
queue_to_buffer:
/*
**DEPRECATED**
*/
    pushl %ebp
    movl %esp, %ebp
    mov %esi, mode
    mov %eax, queue_head

    cmp $0,%ebx
    jne queue_to_buffer_list_1

    # #if 0 populate 
    call get_queue_list_address # now is in eax
    mov (%eax),%eax
    call get_last_node              # eax has the second list 

    mov $0,%ecx # set second list address to null
    
    queue_to_buffer_list_1:

        cmp $0,%ecx
        jne queue_to_buffer_list_2

        # #if 0 populate
        mov %ebx,%edx
        mov %ebx,%eax
        call get_node_priority # ebx has se first node address
        mov (%eax),%eax
        mov %eax, head_list2
        call get_last_node             
        
        mov %ebx,%ecx
        mov %edx, %ebx
        
    queue_to_buffer_list_2:
        mov %ebx, list1_ptr
        mov %ecx, node_ptr

        mov head_list2, %eax
        mov %ecx, %ebx

        # eax remains the same, ebx has now the node 
        # index 
        # edx has the buffer address
    
    call list_to_buffer
    mov %edx, buffer_nodes_address

    mov $buffer_queue, %esi
    mov %esi, buffer_queue_address
    # counter
    xor %edi, %edi
    iterate_buffer:



        # move node address to eax
        mov (%edx), %eax
        test %eax, %eax
        jz end_iterate

        # get the task address in eax
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
        # convert to ascii
        call itoa_to_buffer # esi has the bytes read number
        mov %esi, n_bytes_itoa

        pop %edx
        # prepare copy buffet to buffer
        mov %ebx, %ecx
        mov buffer_queue_address, %ebx

        mov %edx, %ecx
        call copy_buffer_to_buffer

        # update the address
        mov %ebx, buffer_queue_address
        mov %ebx, %edx

        # comma to buffer
        mov $58, %ebx
        mov %ebx, (%edx)
        # update size
        inc buffer_queue_address


        mov total_duration, %ebx
        add task_duration, %ebx

        push %edx
        xor %edx, %edx

        call itoa_to_buffer # esi has the bytes read number
        mov %esi, n_bytes_itoa

        pop %edx
        # prepare copy buffet to buffer
        mov %ebx, %ecx
        mov buffer_queue_address, %ebx

        mov %edx, %ecx
        call copy_buffer_to_buffer

        # update the address
        mov %ebx, buffer_queue_address
        mov %ebx, %edx

        # new line to buffer
        mov $10, %ebx
        mov %ebx, (%edx)
        # update size
        inc buffer_queue_address

        mov total_duration,%ebx
        mov task_expiration,%eax

        cmp %ebx, %eax
        jge no_penalty
        
        mov task_priority,%edx
        sub %ebx, %eax
        mul %edx

        add total_penalty, %eax
        mov %eax, total_penalty
        

        no_penalty:
        # go to index
        add $4, %edx
        inc %edi

        jmp iterate_buffer
    end_iterate:
    leave
    ret



# id in eax, duration in ebx, expiration in ecx,priority in edx, 
# queue address in esi; returnaddress in eax
# (creates the task)
add_to_queue:
    pushl %ebp
    movl %esp, %ebp

    call task
    mov %eax, task_address

    mov %esi, %eax 
    call get_queue_method_value
    cmp $1, %ebx 
    je add_to_queue_hpf

    add_to_queue_ldf:
        # switch priority and expiration

        # Use  expiration as priority
        mov %edx,priority2
        mov %ecx,priority1
        mov %edx,%ecx
        jmp continue_add_to_queue
    
    add_to_queue_hpf:
        mov %edx,priority1
        mov %ecx,priority2

    continue_add_to_queue:
    
    call get_queue_list_address
    mov (%eax), %eax
    mov %eax, queue_list_address

    mov priority1, %ebx
    call get_node_with_priority

    # check if node is found
    cmp $-1, %eax

    jne node_found

    node_not_found:
        # # if not found init a new list
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
        mov (%eax),%eax

        # add to second list
        mov priority2, %ecx
        mov task_address,%ebx
        call add_to_list
    
    continue_add_to_queue2:


    
    leave
    ret


# queue address in eax, task in ecx
add_task_to_queue:
    pushl %ebp
    movl %esp, %ebp

    mov %eax, queue_head
    mov %ecx, task_address

    mov %ecx, %eax
    call get_task_priority_value
    mov %ebx, %edx
    call get_task_expiration_value
    mov %ebx, %ecx

    mov queue_head,%eax
    call get_queue_method_value
    cmp $1, %ebx 

    je add_to_queue_hpf
    jmp add_to_queue_ldf


# queue address in eax, buffer in ebx
add_tasks_to_queue_from_buffer:
    pushl %ebp
    movl %esp, %ebp

    mov %eax, queue_head

    loop_add_tasks_to_queue_from_buffer:
        # test if first is 0 (exit)
        mov (%ebx), %eax
        cmp $0, %eax
        je exit_add_tasks_to_queue_from_buffer

        # go to buffer address
        add $16, %ebx
        
        # save to buffer address
        push %ebx
        
        call task_from_buffer

        # add to list
        mov %eax, %ecx
        mov queue_head, %eax
        call add_task_to_queue

        # restore the buffer address
        pop %ebx
        jmp loop_add_tasks_to_queue_from_buffer
    
    exit_add_tasks_to_queue_from_buffer:

    leave
    ret

# buffer in ebx, method in esi, returns queue address in eax 
init_queue_from_buffer:
    pushl %ebp
    movl %esp, %ebp

    mov %ebx, %ecx
    # go to first value
    mov %ebx, buffer_address
    mov %esi, method

    mov (%ebx), %eax
    mov 8(%ebx), %ecx
    mov 12(%ebx), %edx

    mov 4(%ebx), %ebx

    call init_queue


    mov buffer_address,%ebx
    add $16, %ebx

    call add_tasks_to_queue_from_buffer
    mov queue_head,%eax
    leave 
    ret
