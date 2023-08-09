.section .vectors,"ax",%progbits

.option norvc

.org 0x00
j exc_handler
.rept 30
nop
.endr

j default_exc_handler

/* reset vector */
.org 0x80
j reset_handler

.global default_exc_handler
default_exc_handler:
    j default_exc_handler
.size default_exc_handler, .-default_exc_handler
