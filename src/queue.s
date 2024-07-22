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
queue_list_address:
    .long 0
id:  
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
temp:
    .long 0
task_address: 
    .long 0
buffer_address:
    .long 0


.section .text
.global init_queue
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
# method in %esi 1=HPF, 2=LDF, return address in eax
init_queue:
    pushl %ebp
    movl %esp, %ebp

    call task
    mov %eax, task_address
    call allocate_head
    mov %eax, queue_head

    mov %esi, %ebx
    call set_queue_method

    # HPF
    cmp $1, %esi
    je init_queue_hpf

    init_queue_ldf:
        # switch priority and expiration
        # us expiration as priority
        mov %ecx, priority2
        mov %edx, priority1
        mov %edx, %ecx
        jmp continue_init
    
    init_queue_hpf:
        mov %edx, priority2
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


# id in eax, duration in ebx, expiration in ecx,priority in edx, 
# queue address in esi; return address in eax
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
        mov %ecx,priority2
        mov %edx,priority1
        mov %edx,%ecx
        jmp continue_add_to_queue
    
    add_to_queue_hpf:
        mov %ecx,priority1
        mov %edx,priority2

    continue_add_to_queue:
    
    call get_queue_list_address
    mov %eax, queue_list_address

    call get_first_node_ptr

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
        # eax has the address of the first list
        
        # gets second list address address
        call get_node_data_ptr

        # add to second list
        mov priority2, %edx
        mov task_address,%ebx
        call add_to_list
    
    continue_add_to_queue2:

    call add_to_list
    
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

    call get_queue_method_value
    cmp $1, %ebx 

    mov queue_head, %eax
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
        call task_from_buffer

        # add to list
        mov %eax, %ecx
        mov queue_head, %eax
        call add_task_to_queue
        jmp loop_add_tasks_to_queue_from_buffer
    
    exit_add_tasks_to_queue_from_buffer:

    leave
    ret


# buffer in ebx, methon in esi, returns queue address in eax 
init_list_from_buffer:
    pushl %ebp
    movl %esp, %ebp

    mov %ebx, %ecx
    # go to first value
    mov %ebx, buffer_address

    mov 4(%ebx), %eax
    mov 12(%ebx), %ecx
    mov 16(%ebx), %edx

    mov 8(%ebx), %ebx

    call init_queue

    mov buffer_address, %ebx
    add 16, %ebx

    call add_tasks_to_queue_from_buffer

    leave 
    ret
