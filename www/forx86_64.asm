bits 64
section .data
  string db "/bin/bash",0x00
  olmadis db "basarisiz.",0x0a,0x00
  olmadil equ $-olmadis
section .text
  global main
main:
  mov rax,105
  mov rdi,0
  syscall
  cmp rax,0
  je getbash

  mov rax,1
  mov rdi,1
  mov rsi,olmadis
  mov rdx,olmadil
  syscall

  mov rax,60
  xor rdi,rdi
  syscall

getbash:
  mov rax,59
  mov rdi,string
  mov rsi,0
  mov rdx,0
  syscall
