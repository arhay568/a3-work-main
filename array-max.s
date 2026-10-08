# Write the assembly code for the array_max function
#
# C version:
#
#   unsigned long array_max(unsigned long n, unsigned long *items) {
#     unsigned long max = 0;
#     for (unsigned long i = 0; i < n; i++) {
#       if (items[i] > max) {
#         max = items[i];
#       }
#     }
#     return max;
#   }
#
# Register map:
#
#   n        -> %rdi   1st argument. Only read, never changed.
#   items    -> %rsi   2nd argument. Base address of the array;
#                      items[i] is at (%rsi,%rcx,8), since each
#                      unsigned long is 8 bytes.
#   i        -> %rcx   Loop counter. Caller-saved, but array_max
#                      makes no calls, so nothing can overwrite it
#                      and it doesn't need to be pushed.
#   max      -> %rax   Running maximum. Already in the return
#                      register, so no final move is needed.
#   items[i] -> %rdx   Scratch copy of the current element for the
#                      comparison (cmpq can't take two memory
#                      operands, and loading once avoids reading
#                      memory twice when we update max).
#
# Why ja/jb instead of jg/jl:
#
#   n, i, max and the array elements are all unsigned long. The
#   signed jumps (SF and OF) treat a value with the top bit set as
#   negative. For example, 2^63 would compare as less than 1, and
#   array_max would return the wrong answer. ja/jb test the
#   unsigned flags (CF and ZF), so every 64-bit value is treated
#   as a non-negative number and the comparison matches C's
#   unsigned semantics. The same applies to the loop test i < n.
#
.global array_max
.text

array_max:
  # Prologue (no stack use, kept for consistency)
  enter $0, $0

  # unsigned long max = 0;
  movq  $0, %rax
  # unsigned long i = 0;
  movq  $0, %rcx

loop_cond:
  # i < n ? (exit loop when i >= n)
  cmpq  %rdi, %rcx
  jae   loop_end

  # if (items[i] > max) {
  movq  (%rsi,%rcx,8), %rdx
  cmpq  %rax, %rdx
  jbe   skip_update
  #   max = items[i];
  movq  %rdx, %rax
  # }
skip_update:

  # i++
  addq  $1, %rcx
  jmp   loop_cond

loop_end:
  # return max;  (already in %rax)
  leave
  ret
