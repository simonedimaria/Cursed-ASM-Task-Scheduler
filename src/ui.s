/*
    ui.s
    @note: User Interface
    @author: Simone Di Maria, Pietro Secchi
*/


.section .data
    menu:
        .ascii "======================================\n"
        .ascii "          ASM task scheduler          \n"
        .ascii "======================================\n"
        .ascii "  [1] Earliest Deadline First (EDF)   \n"
        .ascii "  [2] Highest Priority First (HPF)    \n"
        .ascii "  [0] Exit                            \n"
        .ascii "======================================\n"
    menu_len:
        .long . - menu
    input_prompt:
        .ascii "\n> "
    input_prompt_len:
        .long . - input_prompt
    user_choice:
        .long 0
    # user choices constants
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
@note starts the user interface.
*/
    pushl %ebp
    movl %esp, %ebp

    call print_menu
    call handle_user_input

    exit_menu:
        leave
        ret


print_menu:
/*
print_menu()
@note prints the user interface menu.
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
handle_user_input() --> ebx: user_choice
@note reads the user input and sets the user_choice variable.
*/
    pushl %ebp
    movl %esp, %ebp
    
    call ask_for_input

    movl SYS_READ, %eax
    movl STDIN, %ebx
    movl $user_choice, %ecx
    movl $2, %edx
    int $0x80

    mov $user_choice, %ebx
    movl $0, 1(%ebx) # keep only first byte of buffer
    call atoi
    
    leave
    ret


ask_for_input:
/*
ask_for_input()
@note prints the prompt for the user input.
*/
    pushl %ebp
    movl %esp, %ebp

    movl SYS_WRITE, %eax
    movl STDOUT, %ebx
    movl $input_prompt, %ecx
    movl input_prompt_len, %edx
    int $0x80

    leave
    ret
