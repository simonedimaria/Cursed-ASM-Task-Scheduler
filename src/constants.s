/*
    constants.s
    @note: symbols of global constants
    @author: Simone Di Maria, Pietro Secchi
*/

.section .data
    ### syscalls ###
    .global SYS_EXIT
    SYS_EXIT:
        .long 1
    .global SYS_READ
    SYS_READ:
        .long 3
    .global SYS_WRITE
    SYS_WRITE:
        .long 4
    .global SYS_OPEN
    SYS_OPEN:
        .long 5
    .global SYS_CLOSE
    SYS_CLOSE:
        .long 6
    .global SYS_LSEEK
    SYS_LSEEK:
        .long 19
    .global SYS_BRK
    SYS_BRK:
        .long 45

    ### file descriptors ###
    .global STDIN
    STDIN:
        .long 0
    .global STDOUT
    STDOUT:
        .long 1
    .global STDERR
    STDERR:
        .long 2
    
    ### misc ###
    .global PAGE_SIZE
    PAGE_SIZE:
        .long 4096
    .global SEEK_CUR
    SEEK_CUR:
        .long 1
    .global COMMA_ASCII
    COMMA_ASCII:
        .long 44
    .global LINE_FEED_ASCII
    LINE_FEED_ASCII:
        .long 10
