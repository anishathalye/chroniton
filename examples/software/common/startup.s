.section .vectors,"ax",%progbits

.global reset_handler
.type reset_handler, %function
reset_handler:
    la sp, _stack_top
    call _init
    call main
_fell_through:
    /* signal completion over GPIO */
    li a0, 0xff
    call gpio_write
_fell_through_loop:
    j _fell_through_loop
.size reset_handler, .-reset_handler

.type _init, %function
_init:
_copy_data:
    la t1, _sidata
    la t2, _sdata
    la t3, _edata
    beq t2, t3, _zero_bss /* no data to copy, proceed to zero bss */
_copy_data_loop:
    lw t0, 0(t1)
    sw t0, 0(t2)
    addi t1, t1, 4
    addi t2, t2, 4
    bne t2, t3, _copy_data_loop
_zero_bss:
    la t1, _sbss
    la t2, _ebss
    beq t1, t2, _init_done
_zero_bss_loop:
    sw zero, 0(t1)
    addi t1, t1, 4
    bne t1, t2, _zero_bss_loop
_init_done:
    ret
.size _init, .-_init

.global exc_handler
.type exc_handler, %function
exc_handler:
    j exc_handler
.size exc_handler, .-exc_handler
