# Sorted Linked List
.section .bss
    .lcomm buffer, 12
.section .data
    PROT_READ     =$0x1
    PROT_WRITE    =$0x2
    MAP_PRIVATE   =$0x2
    MAP_ANONYMOUS = $0x20
task_id:
    .long 0
task:
    .long 0
penalty:
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
list1_ptr:
    .long 0
list2_ptr:
    .long 0
list2:
    .long 0
list1:
    .long 0
list:
    .long 0
list1_last:
    .long 0
list1_first:
    .long 0
list2_first:
    .long 0
list2_last:
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
temp:
    .long 0
heap_location:
    .long 0

node_index_addres:
    .long 0
list_buffer:
    .space 1024
    
list_buffer_size:
    .long 1024
colon:
    .ascii ":"
new_line:
    .ascii "\n"
conclusione_msg:
    .asciz "Conclusione: "
penalty_msg:
    .asciz "Penalty: "
node_size:  .long 16 # 4 prev, 4 next, 4 value, 4 priority


SYS_BRK = 45              # System call number for brk
PAGE_SIZE = 4096          # Size of a page (assumed to be 4KB)
.section .text
.global sll2,add_to_list,list_to_buffer, merge_lists, print_list
.type sll2, @function

# returns a buffer with [value1,value2,...] where value in 
# our case is an address of a node
# head in eax,node index in ebx 0 if none else the address, 
# mode in esi=1 asc(hpf) esi=0 dec (ldf), returns buffer in edx, node in ebx or -1 if ended, 
# buffer will have null byte at the end
# buffer will be 4(node_value)
list_to_buffer:
    pushl %ebp
    movl %esp, %ebp
    mov %ebx, node_index_addres
    mov %eax, list_head
    cmp $0,%esi 

    mov $list_buffer,%ecx

    # init counter
    mov $0,%edi
    je list_to_buffer_dec


    list_to_buffer_asc:
        
        call get_last_value 
        mov %ebx, %edx # edx is the node to compare to
        mov %ebx, temp
        
        mov node_index_addres,%ebx
        cmp $0,%ebx
        jne list_to_buffer_asc_iterate
        
        call get_first_value # now ebx has the node address
        
        list_to_buffer_asc_iterate:


            # save node to buffer
            mov %ebx, %eax
            call get_value_value
            mov %ebx, (%ecx)

            mov node_index_addres, %eax

            # get next node
            call get_next_value

            cmp %edx, %ebx
            je end_list_to_buffer_end

            cmp list_buffer_size, %edi
            je end_list_to_buffer
            inc %edi
            add $4, %ecx
            jmp list_to_buffer_asc_iterate
    list_to_buffer_dec:
        
        call get_first_value 
        mov %ebx, %edx # ecx is the node to compare to
        
        mov node_index_addres,%ebx
        cmp $0,%ebx
        jne list_to_buffer_asc_iterate
        
        call get_last_value # now ebx has the node address
        
        list_to_buffer_dec_iterate:

            cmp %edx, %ebx
            je end_list_to_buffer_end

            cmp list_buffer_size, %edi
            je end_list_to_buffer


            # save node to buffer
            mov %ebx, %eax
            call get_value_value
            mov %ebx, (%edx)


            mov node_index_addres, %eax

            # get next node
            call get_prev_value
            inc %edi
            add $4, %edx

            jmp list_to_buffer_dec_iterate





    end_list_to_buffer_end:

        # make ebx 0 to signal the end of the list
        xor %ebx, %ebx
    end_list_to_buffer:
        mov $0, 4(%edx)
        mov list_head,%eax
        mov list_buffer, %edx

        leave
        ret

# prints directly the list with id:time, 
# also prints final message
# list in eax, method in esi, esi=1 straight(hpf) 
# esi=0 reverse(ldf)

print_list:
    pushl %ebp
    movl %esp, %ebp
    mov %eax, list

    call get_last_value
    mov %ebx, last_node
    
    call get_first_value
    mov %ebx, first_node
    mov %ebx, node_ptr
    mov %ebx, %eax

    test %esi, %esi
    jz print_list_reverse_init
    jmp print_list_straight

    print_list_reverse_init:
    mov last_node, %eax
    jmp print_list_loop
    print_list_straight_init:
    mov first_node, %eax

    print_list_loop:
        call get_value_value
        mov %ebx, task
        mov %ebx, %eax
        call get_task_id_value
        mov %ebx, task_id

        mov task, %eax

        call get_task_duration_value
        mov %ebx, priority

        call get_task_expiration_value
        mov %ebx, expiration

        call get_task_duration_value
        mov %ebx, duration

        mov total_duration, %eax
        add %ebx, %eax # time after task completition
        
        mov expiration, %ebx
        subl %eax, %ebx     # res = expiration - final_time

        js not_expired
        expired:
            imull priority, %ebx # priority * how many ticks expired

            add total_penalty, %ebx
            mov %ebx, total_penalty
        not_expired:
            mov duration, %eax
            add total_duration, %eax
            mov %eax, total_duration

        
        mov task_id, %eax
        call itoa
        mov $colon, %eax
        mov $1, %ebx
        call print_buffer

        mov total_duration, %eax
        call itoa
        mov $new_line, %eax
        mov $1, %ebx
        call print_buffer


    test %esi, %esi
    jz print_list_reverse
    jmp print_list_straight
    print_list_reverse:
        mov first_node, %eax
        cmp node_ptr, %eax
        je print_list_exit

        mov node_ptr, %eax
        call get_prev_value
        mov %ebx, %eax
        mov %ebx, node_ptr
        jmp print_list_loop
    print_list_straight:
        mov last_node, %eax
        cmp node_ptr, %eax
        je print_list_exit

        mov node_ptr, %eax
        call get_next_value
        mov %ebx, %eax
        mov %ebx, node_ptr
        
        jmp print_list_loop
        


    print_list_exit:
    mov $conclusione_msg, %eax
    call print_buffer_no_length

    mov total_duration, %eax
    call itoa
    mov $new_line, %eax
    mov $1, %ebx
    call print_buffer

    mov $penalty_msg, %eax
    call print_buffer_no_length
    mov total_penalty, %eax
    call itoa
    mov $new_line, %eax
    mov $1, %ebx
    call print_buffer
    leave
    ret

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
    mov %ebx, first_node
    # init list_ptr
    mov %ebx, list_ptr

    call get_last_value
    mov %ebx, last_list_ptr
    mov %ebx, last_node

    # node allocation
    call allocate_node
    mov value, %ebx
    call set_value
    mov %ecx, %ebx
    call set_priority
    mov %eax, node_address


    call loop_sort_start

    continue:

    leave
    ret

    # check if sort by asc or dec
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
            call compare_nodes # cmp ptr, node (node, ponter)

            jl next_node
            jge place_node  # new node is higher then the ptr
            jmp continue


next_node:
    # remember the pointer
    mov list_ptr, %eax
    mov %eax, last_list_ptr

    # update list_ptr to the new value
    call get_next_value
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
    jne continue
    call check_if_first
    # call check_if_last

    jmp continue




not_found:
    mov last_node, %eax
    mov node_address, %ebx
    mov first_node, %ecx
    call insert_node

    # uses ebx from before
    mov node_address, %ebx
    mov list_head, %eax
    call set_first

    # call check_if_last
    # call check_if_first
    jmp continue

# list1 in eax, list2 in ebx
# list1.last.next=list2.first
# list2.first.prev=list1.last
merge_lists:
    pushl %ebp
    movl %esp, %ebp

    mov %eax, list1
    mov %ebx, list2

    call get_last_value
    mov %ebx, list1_last

    call get_first_value
    mov %ebx, list1_first


    mov list2,%eax
    call get_last_value
    mov %ebx, list2_last

    call get_first_value
    mov %ebx, list2_first


    # set circularly the next node
    mov list1_last, %eax
    mov list2_first, %ebx

    call set_next_node

    mov list2_last, %eax
    mov list1_first, %ebx

    call set_next_node

    mov list1,%eax
    mov list2_last, %ebx
    call set_last

    leave
    ret

check_if_first:
    pushl %ebp
    movl %esp, %ebp



    mov last_list_ptr, %ecx
    cmp first_node, %ecx # compare first_node with the ptr
    jne continue

    # update first
    mov list_head, %eax
    mov node_address, %ebx
    call set_first
    mov %ebx,first_node

   leave
    ret

check_if_last:
    pushl %ebp
    movl %esp, %ebp



    mov last_list_ptr, %ecx
    cmp last_node, %ecx # compare first_node with the ptr
    jne continue

    # update first
    mov list_head, %eax
    mov node_address, %ebx
    call set_last
    mov %ebx,last_node

   leave
    ret

