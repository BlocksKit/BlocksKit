
#ifdef __i386__

# Write out the trampoline table, aligned to the page boundary
.text
.align 12
.globl _pl_blockimp_table_page
_pl_blockimp_table_page:

_block_tramp_dispatch:
pop     %eax
andl    $0xfffffff8, %eax // truncate to the trampoline start (each is 8 bytes)
subl    $0x1000, %eax // load the config location

// Move 'self' to the second parameter, overwriting IMP
movl    0x4(%esp), %ecx
movl    %ecx, 0x8(%esp)

// Load the block reference from the config page, insert as the first parameter
movl    (%eax), %eax
movl    %eax, 0x4(%esp)

// Jump to the block fptr
jmp    *0xc(%eax)

.align 3 // align the trampolines at 8 bytes



# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes


# Call into the dispatcher, placing our return address on the stack.
calll _block_tramp_dispatch # 5 bytes
.align 3 // align the trampolines at 8 bytes

#elif defined(__x86_64__)


# Write out the trampoline table, aligned to the page boundary
.text
.align 12
.globl _pl_blockimp_table_page
_pl_blockimp_table_page:

_block_tramp_dispatch:
pop    %r11
and    $0xfffffffffffffff8, %r11 // truncate to the trampoline start (each is 8 bytes)
sub    $0x1000, %r11 // load the config location

// Move 'self' to the second parameter, overwriting IMP
movq   %rdi, %rsi

// Load the block reference from the config page, and move to the first parameter
movq   (%r11), %rdi

// Jump to the block fptr
jmp *0x10(%rdi)
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

// Call into the dispatcher, placing our return address on the stack.
call _block_tramp_dispatch # 5 bytes
.align 4 // align the trampolines at 16 bytes (required for config page lookup and sizing)

#elif defined(__arm__)

# Write out the trampoline table, aligned to the page boundary
.text
.align 12
.globl _pl_blockimp_table_page
_pl_blockimp_table_page:

_block_tramp_dispatch:
# trampoline address+8 is in r12 -- calculate our config page address
sub r12, #0x8
sub r12, #0x1000

# Set the 'self' argument as the second argument
mov r1, r0

# Load the block pointer as the first argument
ldr r0, [r12]

# Jump to the block pointer
ldr pc, [r0, #0xc]

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

# Save pc+8, then jump to the shared prefix implementation
mov r12, pc
b _block_tramp_dispatch;

#else
#error Block implementations currently not support on this arch.
#endif