# Sorted Linked List
.section .bss
.section .data

size:  .long 16 # 4 id, 4 priority, 4 expiration, 4 duration       
id:.long 0
duration:.long 0
print_buffer: .space 128
SYS_BRK:  
    .long 45 # System call number for brk 
        
PAGE_SIZE = 4096          # Size of a page (assumed to be 4KB)
.section .text

.global task
.global task_from_buffer
.global get_task_priority_value
.global get_task_expiration_value

# id in eax, duration in ebx, expiration in ecx,priority in edx, 
# return address in eax
task:
    pushl %ebp
    movl %esp, %ebp

    mov %eax, id
    mov %ebx, duration
    call allocate_task
    mov %edx, %ebx
    call  set_task_priority
    mov %ecx, %ebx
    call  set_task_expiration
    mov duration, %ebx
    call  set_task_duration
    mov id, %ebx
    call  set_task_id

    leave
    ret

# buffer in %ecx
task_from_buffer:
    pushl %ebp
    movl %esp, %ebp

    call allocate_task
    # id
    mov -16(%ecx), %edx
    mov %edx, -16(%eax)
    # duration
    mov -12(%ecx), %edx
    mov %edx, -12(%eax)
    # expiration
    mov -8(%ecx), %edx
    mov %edx, -8(%eax)
    # priority
    mov -4(%ecx), %edx
    mov %edx, -4(%eax)


    leave
    ret

# task address in eax
print_task:
    pushl %ebp
    movl %esp, %ebp

    mov %eax, %ecx
    call get_task_id
    call itoa

    mov %ecx, %eax
    call get_task_duration
    call itoa
    
    mov %ecx, %eax
    call get_task_expiration
    call itoa
    
    mov %ecx, %eax
    call get_task_priority
    call itoa

    leave
    ret


allocate_task:
    pushl %ebp
    movl %esp, %ebp

    movl $45, %eax         # brk
    xor %ebx, %ebx
    int $0x80              # Call kernel
    mov %eax, %esi

    addl size, %eax

    movl %eax, %ebx
    movl $45, %eax 
    int $0x80    
    leave
    ret

# address in eax, returns in eax 
get_task_id:
    pushl %ebp
    movl %esp, %ebp
    sub      $16,%eax
    leave
    ret
# address in eax, returns in eax 
get_task_duration:
    pushl %ebp
    movl %esp, %ebp

    sub      $12,%eax


    leave
    ret
# address in eax, returns in eax 
get_task_expiration:
    pushl %ebp
    movl %esp, %ebp

    sub      $8,%eax


    leave
    ret
# address in eax, returns in eax 
get_task_priority:
    pushl %ebp
    movl %esp, %ebp

    sub  $4,%eax


    leave
    ret
# address in eax, returns in ebx 
get_task_id_value:
    pushl %ebp
    movl %esp, %ebp

    mov -16(%eax),%ebx



    leave
    ret
# address in eax, returns in ebx 
get_task_duration_value:
    pushl %ebp
    movl %esp, %ebp
    mov -12(%eax),%ebx


    leave
    ret
# address in eax, returns in ebx 
get_task_expiration_value:
    pushl %ebp
    movl %esp, %ebp

    mov -8(%eax),%ebx


    leave
    ret
# address in eax, returns in ebx 
get_task_priority_value:
    pushl %ebp
    movl %esp, %ebp

    mov -4(%eax),%ebx


    leave
    ret

# id in ebx
set_task_id:
    pushl %ebp
    movl %esp, %ebp

    call get_task_id
    mov %ebx,(%eax)
    add $16,%eax

    leave
    ret
# duration in ebx
set_task_duration:
    pushl %ebp
    movl %esp, %ebp

    call get_task_duration
    mov %ebx,(%eax)
    add $12,%eax

    leave
    ret
    ret
# expiration in ebx
set_task_expiration:
    pushl %ebp
    movl %esp, %ebp

    call get_task_expiration
    mov %ebx,(%eax)
    add $8,%eax

    leave
    ret

# priority in eax
set_task_priority:
    pushl %ebp
    movl %esp, %ebp

    call get_task_priority
    mov %ebx,(%eax)
    add $4,%eax

    leave
    ret