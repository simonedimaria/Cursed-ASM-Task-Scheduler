/*
    task_utils.s
    @note: Tasks utility functions
    @author: Simone Di Maria, Pietro Secchi
*/


.section .data
    size:
        .long 16  # 4 prev + 4 next + 4 priority + 4 value
    id:
        .long 0
    duration:
        .long 0
    temp:
        .long 0


.section .text
    .global create_task
    .global create_task_from_buffer
    .global get_task_id_value
    .global get_task_priority_value
    .global get_task_expiration_value
    .global get_task_duration_value
    

allocate_task:
/*
allocate_task() --> eax: task_addr
@note allocates memory for a new task, , returns address in eax.
*/
    pushl %ebp
    movl %esp, %ebp

    movl SYS_BRK, %eax
    xor %ebx, %ebx
    int $0x80
    mov %eax, %esi

    addl size, %eax

    movl %eax, %ebx
    movl SYS_BRK, %eax 
    int $0x80

    leave
    ret


create_task:
/*
task(eax: task_id, ebx: task_duration, ecx: task_expiration, edx: task_priority) --> eax: task
@note creates a new task with the given parameters.
*/
    pushl %ebp
    movl %esp, %ebp

    mov %eax, id
    mov %ebx, duration
    call allocate_task
    mov %edx, %ebx
    call  set_task_priority
    mov %ecx, %ebx
    call set_task_expiration
    mov duration, %ebx
    call set_task_duration
    mov id, %ebx
    call set_task_id

    leave
    ret


print_task_details:
/*
print_task_details(eax: task)
@note prints the task details to STDOUT.
*/
    pushl %ebp
    movl %esp, %ebp

    mov %eax, %ecx
    call get_task_id_ptr
    call itoa

    mov %ecx, %eax
    call get_task_duration_ptr
    call itoa
    
    mov %ecx, %eax
    call get_task_expiration_ptr
    call itoa
    
    mov %ecx, %eax
    call get_task_priority_ptr
    call itoa

    leave
    ret


create_task_from_buffer:
/*
create_task_from_buffer(ebx: buffer) --> eax: task
@note creates a new task from the given buffer.
*/
    pushl %ebp
    movl %esp, %ebp

    mov %ebx, temp
    call allocate_task
    mov temp, %ebx

    # id
    mov -16(%ebx), %edx
    mov %edx, -16(%eax)

    # duration
    mov -12(%ebx), %edx
    mov %edx, -12(%eax)

    # expiration
    mov -8(%ebx), %edx
    mov %edx, -8(%eax)

    # priority
    mov -4(%ebx), %edx
    mov %edx, -4(%eax)

    leave
    ret


get_task_id_ptr:
/*
get_task_id_ptr(eax: task) --> eax: task_id
@note returns the pointer to the task id.
*/
    pushl %ebp
    movl %esp, %ebp
 
    sub $16, %eax

    leave
    ret


get_task_priority_ptr:
/*
get_task_priority_ptr(eax: task) --> eax: task_priority
@note returns the pointer to the task priority.
*/
    pushl %ebp
    movl %esp, %ebp

    sub $4, %eax

    leave
    ret


get_task_expiration_ptr:
/*
get_task_expiration_ptr(eax: task) --> eax: task_expiration
@note returns the pointer to the task expiration.
*/
    pushl %ebp
    movl %esp, %ebp

    sub $8, %eax

    leave
    ret


get_task_duration_ptr:
/*
get_task_duration_ptr(eax: task) --> eax: task_duration
@note returns the pointer to the task duration.
*/
    pushl %ebp
    movl %esp, %ebp

    sub $12, %eax

    leave
    ret


get_task_id_value:
/*
get_task_id_value(eax: task) --> ebx: *task_id
@note returns the task id.
*/
    pushl %ebp
    movl %esp, %ebp

    mov -16(%eax), %ebx

    leave
    ret


get_task_priority_value:
/*
get_task_priority_value(eax: task) --> ebx: *task_priority
@note returns the task priority.
*/
    pushl %ebp
    movl %esp, %ebp

    mov -4(%eax), %ebx

    leave
    ret


get_task_expiration_value:
/*
get_task_expiration_value(eax: task) --> ebx: *task_expiration
@note returns the task expiration.
*/
    pushl %ebp
    movl %esp, %ebp

    mov -8(%eax), %ebx

    leave
    ret


get_task_duration_value:
/*
get_task_duration_value(eax: task) --> ebx: *task_duration
@note returns the task duration.
*/
    pushl %ebp
    movl %esp, %ebp

    mov -12(%eax), %ebx

    leave
    ret


set_task_id:
/*
set_task_id(eax: task, ebx: task_id) --> eax: task
@note sets the task id.
*/
    pushl %ebp
    movl %esp, %ebp

    call get_task_id_ptr
    mov %ebx, (%eax)
    add $16, %eax

    leave
    ret


set_task_priority:
/*
set_task_priority(eax: task, ebx: task_priority) --> eax: task
@note sets the task priority.
*/
    pushl %ebp
    movl %esp, %ebp

    call get_task_priority_ptr
    mov %ebx, (%eax)
    add $4, %eax

    leave
    ret


set_task_expiration:
/*
set_task_expiration(eax: task, ebx: task_expiration) --> eax: task
@note sets the task expiration.
*/
    pushl %ebp
    movl %esp, %ebp

    call get_task_expiration_ptr
    mov %ebx, (%eax)
    add $8, %eax

    leave
    ret



set_task_duration:
/*
set_task_duration(eax: task, ebx: task_duration) --> eax: task
@note sets the task duration.
*/
    pushl %ebp
    movl %esp, %ebp

    call get_task_duration_ptr
    mov %ebx, (%eax)
    add $12, %eax

    leave
    ret
