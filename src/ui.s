/*
    ui.s
    @note: User Interface
    @author: Simone Di Maria, Pietro Secchi
*/


.section .bss

.section .data
menu:
    .ascii "======================================\n"
    .ascii "          ASM task scheduler          \n"
    .ascii "======================================\n"
    .ascii "  [1] Earliest Deadline First (EDF)   \n"
    .ascii "  [2] Highest Priority First (HPF)    \n"
    .ascii "  [3] Exit                            \n"
    .ascii "======================================\n"
menu_len:
    .long . - menu
gimme_input:
    .ascii "\n> "
gimme_input_len:
    .long . - gimme_input
user_choice:
    .long 0
# user choiches constants
SCHEDULE_EDF:
    .long 49
SCHEDULE_HPF:
    .long 50
EXIT:
    .long 51


.section .text
    .global start_ui


start_ui:
/*
start_ui()
@note starts the user interface
*/
    pushl %ebp
    movl %esp, %ebp

    call print_menu
    jmp handle_user_input

    exit_menu:
        leave
        ret


print_menu:
/*
print_menu()
@note prints the user interface menu
*/
    pushl %ebp
    movl %esp, %ebp

    movl SYS_WRITE, %eax
    mov STDOUT, %ebx
    mov $menu, %ecx
    mov menu_len, %edx
    int $0x80

    leave
    ret


handle_user_input:
/*
handle_user_input()
@note reads the user input and sets the user_choice variable
*/
    call ask_for_input

    movl SYS_READ, %eax
    movl STDIN, %ebx
    movl $user_choice, %ecx
    movl $2, %edx
    int $0x80

    # @todo atoi?
    
    movb user_choice, %al
    
    cmp SCHEDULE_EDF, %al
    je handle_edf_scheduling
    
    cmp SCHEDULE_HPF, %al
    je handle_hpf_scheduling
    
    cmp EXIT, %al
    je handle_exit
    
    handle_edf_scheduling:
        # @todo
        jmp handle_user_input
    
    handle_hpf_scheduling:
        # @todo
        jmp handle_user_input

    handle_exit:
        jmp exit_menu


ask_for_input:
/*
ask_for_input()
@note prints the prompt for the user input
*/
    pushl %ebp
    movl %esp, %ebp

    movl SYS_WRITE, %eax
    movl STDOUT, %ebx
    movl $gimme_input, %ecx
    movl gimme_input_len, %edx
    int $0x80

    leave
    ret
