# Write the assembly code for the main function of the mystery program
#
# Register map for main (mirrors mystery-main.c):
#
#   argc   -> %edi   Only checked once, before any call. Not saved.
#   argv   -> %rbx   Arrives in %rsi, moved to callee-saved %rbx so it
#                    survives the first atol call (needed for argv[2]).
#   a      -> %r12   Returned by atol(argv[1]) in %rax, moved to
#                    callee-saved %r12 so it survives the second atol.
#   b      -> %rsi   Returned by atol(argv[2]) in %rax, moved straight
#                    into %rsi (2nd arg to crunch). No save needed,
#                    since crunch is the very next call.
#                    (a goes from %r12 into %rdi as the 1st arg.)
#   result -> %rax   Returned by crunch, compared immediately to pick
#                    the message. Not needed after puts, so not saved.
#
# Callee-saved pushes: 2 (%rbx, %r12)
# Stack alignment: on entry %rsp is 8 mod 16 (return address).
#   enter $0, $0 pushes %rbp, bringing %rsp to 0 mod 16, and the
#   2 pushes add 16 more, so %rsp stays 16-byte aligned at every
#   call. No extra sub $8, %rsp is needed.
#
.global main
.text

main:
  # Prologue: set up frame, save callee-saved registers
  enter $0, $0
  pushq %rbx
  pushq %r12

  # if (argc != 3) {
  cmpl  $3, %edi
  je    args_ok
  #   puts("Two arguments required.");
  movq  $error_msg, %rdi
  call  puts
  #   return 1;
  movl  $1, %eax
  jmp   done
  # }

args_ok:
  # Keep argv safe across calls (argv -> %rbx)
  movq  %rsi, %rbx

  # long a = atol(argv[1]);
  movq  8(%rbx), %rdi
  call  atol
  movq  %rax, %r12

  # long b = atol(argv[2]);
  movq  16(%rbx), %rdi
  call  atol

  # long result = crunch(a, b);
  movq  %r12, %rdi
  movq  %rax, %rsi
  call  crunch

  # if (result < 0) ... else if (result == 0) ... else ...
  cmpq  $0, %rax
  jl    print_hat
  je    print_tea

  # else { puts("beer"); }
  movq  $beer_msg, %rdi
  call  puts
  jmp   return_zero

print_hat:
  # if (result < 0) { puts("hat"); }
  movq  $hat_msg, %rdi
  call  puts
  jmp   return_zero

print_tea:
  # else if (result == 0) { puts("tea"); }
  movq  $tea_msg, %rdi
  call  puts

return_zero:
  # return 0;
  movl  $0, %eax

done:
  # Epilogue: restore callee-saved registers in reverse order
  popq  %r12
  popq  %rbx
  leave
  ret

.data
error_msg:
  .asciz "Two arguments required."
hat_msg:
  .asciz "hat"
tea_msg:
  .asciz "tea"
beer_msg:
  .asciz "beer"
