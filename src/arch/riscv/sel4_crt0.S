/*
 * Copyright 2014, NICTA
 *
 * This software may be distributed and modified according to the terms of
 * the BSD 2-Clause license. Note that NO WARRANTY is provided.
 * See "LICENSE_BSD2.txt" for details.
 *
 * @TAG(NICTA_BSD)
 */
/*
 * A default seL4 crt0 for arm. It does the bare minimum required to emulate
 * a typical startup environment and jump to the regular _start symbol
 */

#include <autoconf.h>

#ifdef CONFIG_LIB_SEL4_PLAT_SUPPORT_SEL4_START

    .global _sel4_start
    .extern sel4_vsyscall
    .extern __dso_handle 
.text

_sel4_start:

    /* Dirty hack to load gp and avoid load/store exceptions, this should be
     * defined by the linker */
    li gp, 0x800
    la s0, __dso_handle
    add gp, gp, s0

    /* Setup a stack for ourselves. */
    la     sp, _stack_top

    /* Setup bootinfo. The pointer to the bootinfo struct starts in 'r0'. */
    jal      seL4_InitBootInfo

    /* Setup stack frame ready for jumping to _start */
    addi sp, sp, -40
    
    /* argc */
    li   a1, 1
    sw   a1, 0(sp)
    
    /* prog name */
    la   a1, prog_name
    sw   a1, 4(sp)
    
    /* Null-terminate arg vector */
    sw   x0, 8(sp)
    
    /* Give an environment string */
    la   a1, environment_string

    /* Null terminate envp */
    sw   x0, 12(sp)

    /* give vsyscall location */
    li   a1, 32
    sw   a1, 16(sp)
    la   a1, sel4_vsyscall
    sw   a1, 20(sp)
    
    /* null terminate auxv */
    sw   x0, 24(sp)
    sw   x0, 28(sp)
    sw   x0, 32(sp) 

    /* Now go to actual _start */
    j       _start

/* .text Literal Pool */
    .data
    .align 4

environment_string:
    .asciz "seL4=1"
prog_name:
    .asciz "rootserver"

    .bss
    .align  8

_stack_bottom:
    .space  16384
_stack_top:

#endif /* CONFIG_LIB_SEL4_PLAT_SUPPORT_SEL4_START */
