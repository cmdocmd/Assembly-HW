;       Rochester Institute of Technology
;                Mohammad Alloush
;                       HW2
;                x86_64 - Kali Linux


section .data
sys_write equ 1
sys_open equ 2
sys_read equ 0
sys_close equ 3
sys_creat equ 85

O_RDONLY equ 000000q 
O_CREAT equ 0x40
S_IRUSR equ 00400q
S_IWUSR equ 00200q

strlen equ 20

fileName db "msg.txt", 0
writeName db "cipher.txt", 0
fileDesc dq 0
writeDesc dq 0


section .bss
strMsg resb strlen  
chiMsg resb strlen
swapMsg resb 1
swapMsglen resb strlen

section .text
global _start

_start:
;   First we start opening the file
mov rax, sys_open
mov rdi, fileName
mov rsi, O_RDONLY   ;   this for read only
syscall
;   now fileDesc is going to be in rax if everything successed

mov qword[fileDesc], rax     ;   Changing the content of fileDesc to rax (which contains the fileDesc)

;   Now we will start reading after opening the file
mov rax, sys_read
mov rdi, qword[fileDesc]   ;   rdi takes fileDesc of the file we just opened
mov rsi, strMsg
mov rdx, strlen          ;   how many letters we want to read
syscall

;   now we will start printing the the str
mov rsi, strMsg    ;   rsi now contains first address of str
mov byte [rsi + rax], 0     ;   rax contains the length of str [H][e][l][l][o] [0] last 0 will terminate the loop
mov rdi, strMsg
mov [swapMsglen], rax
call cipher     ; calling cipher function

;   now closing the file
mov rax, sys_close
mov rdi, qword [fileDesc]
syscall



;   now terminate the program and return success
mov rax, 60
mov rdi, 0
syscall

;   cipher function

global cipher
cipher:
push rbp
mov rbp, rsp
push rbx

mov rax, 3
mov rbx, rdi
mov rdx, 0

firstLoop:
cmp byte[rbx], 0 ; if (str[i] == 0) {
                 ; loop is done
je firstLoopDone ; }
                 ; else {
add [rbx], rax   ; str[i] += 3
inc rbx          ; i++
inc rdx          ; rdx is the i

jmp firstLoop

firstLoopDone:

; set rbx back to the string
mov rbx, rdi
; set rdx back to 0
mov rdx, 0
mov rax, 2


secondLoop:
cmp byte[rbx], 0
je secondLoopDone

;   Changing odd with even algorithm
mov cl, [rbx + 1]
mov byte[swapMsg + rdx], cl 
inc rdx

mov cl, [rbx] 
mov byte[swapMsg + rdx], cl        
inc rdx

add rbx, rax
jmp secondLoop

; string a = "ABCD"
; string b = "";
; for (int i = 0; i < a.length(); i++) {
;   b += a[i + 1];
;   b += a[i];
; }
; just translated the above code ^ to assembly

; fixing issues......
;first loop
; rbx is at 0 + 1 -> h
; rbx is at 0 -> k

;second loop
;rbx is at 1 + 1 -> o
;rbx is at 1 -> h ;; rbx here should be + 2
; 0 1 2 3 4
; K h o o r 



secondLoopDone:

cmp rdx, 0
je done


call writeToFile

done:
pop rbx
pop rbp

ret


global writeToFile
writeToFile:

mov rax, sys_creat ; create or open
mov rdi, writeName ; fileName
mov rsi, S_IRUSR | S_IWUSR ; mode
syscall

mov qword [writeDesc], rax

mov rax, sys_write
mov rdi, qword [writeDesc]
mov rsi, swapMsg
syscall

mov rax, sys_close
mov rdi, qword [writeDesc]
syscall

ret