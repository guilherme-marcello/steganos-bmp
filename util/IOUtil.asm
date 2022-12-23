;********************************************************************
section .data
;********************************************************************
; handy settings
LF                  equ 10
NULL                equ 0
EXIT_SUCCESS        equ 0
STDIN               equ 0
STDOUT              equ 1
STDERR              equ 2
SYS_read            equ 0
SYS_write           equ 1
SYS_open            equ 2
SYS_close           equ 3
SYS_exit            equ 60
SYS_creat           equ 85
O_RDONLY            equ 000000q
S_IRUSR             equ 00400q
S_IWUSR             equ 00200q
; maximum supported sizes
MAX_FILENAME_SIZE   equ 255
MAX_MSG_SIZE        equ 1024
MAX_IMG_SIZE        equ 1048576
; file descriptors
msgFileDesc         dq  0
bmpFileDesc         dq  0
; error messages
errMsgOpenData      db "Error when opening the TXT", LF, NULL
errMsgOpenBmp       db "Error when opening the BMP", LF, NULL
errMsgRead          db "Error when reading the BMP", LF, NULL
errMsgWrite         db "error when writing", LF, NULL
newLine             db LF,NULL

;********************************************************************
section .text
;********************************************************************
;--------------------------------------------------------------------
; functions of the library
;--------------------------------------------------------------------
global terminate
global printStr
global printStrLn
global readMessageFile
global readImageFile
global writeImageFile

;--------------------------------------------------------------------
; terminate
; description: Ends programme execution
; params : none
; out : none
; modify: RAX e RDI
;--------------------------------------------------------------------
terminate:
    mov rax, SYS_exit
    mov rdi, EXIT_SUCCESS
    syscall

;--------------------------------------------------------------------
; printStr
; description: Prints a string (ending with 0) to the terminal
; params : 
;   RDI - Memory address for string to print
; return : none
; modify: RDI, RSI e RAX
;--------------------------------------------------------------------
printStr:
    push rbp
    mov rbp, rsp
    push rbx
    ; counts the string characters
    mov rbx, rdi
    mov rdx, 0
strCountLoop:
    cmp byte [rbx], NULL
    je strCountDone
    inc rdx
    inc rbx
    jmp strCountLoop
strCountDone:
    cmp rdx, 0
    je prtDone
    ; prints the string
    mov rax, SYS_write
    mov rsi, rdi
    mov rdi, STDOUT 
    syscall  
prtDone:
    pop rbx
    pop rbp
    ret

;--------------------------------------------------------------------
; printStrLn
; description: Prints a string (ending in 0) and an '\n' to the terminal
; params : 
;   RDI - Memory address for string to print
; return : none
; modify: RDI, RSI e RAX
;--------------------------------------------------------------------
printStrLn:
    ; prints the string
    call printStr
    ; prints the LF
    mov rdi, newLine
    call printStr
    ret

;--------------------------------------------------------------------
; readMessageFile
; description: Reads a file into memory
; params : 
;   RDI - Memory address to string with the name of the file to be read
;   RSI - Address of the buffer
; return : 
;   RAX - number of bytes read from the file into the buffer
; modify: RDI, RSI, RAX e RDX
;--------------------------------------------------------------------
readMessageFile:
    push rsi
    ; open file 
    mov rax, SYS_open
    mov rsi, O_RDONLY
    syscall
    cmp rax,0
    jl errorOnOpenData
    mov [msgFileDesc], rax
    ; read file
    mov rax, SYS_read
    mov rdi, [msgFileDesc]
    pop rsi
    mov rdx, MAX_MSG_SIZE
    syscall
    cmp rax,0
    jl errorOnRead
    push rax
    ; close file
    mov rax, SYS_close
    mov rdi, qword [msgFileDesc]
    syscall
    pop rax
    ret

;--------------------------------------------------------------------
; readImageFile
; description: Read an image file (BMP) to a buffer in memory
; params : 
;   RDI - Memory address to string with the name of the file to be read
;   RSI - Address of the buffer
; return : 
;   RAX - number of bytes read from the file into the buffer
; modify: RAX e RSI
;--------------------------------------------------------------------
readImageFile:
    push rsi
    mov rax, SYS_open
    mov rsi, O_RDONLY
    syscall
    cmp rax,0
    jl errorOnOpenBmp 
    mov [bmpFileDesc], rax
    mov rax, SYS_read
    mov rdi, qword [bmpFileDesc]
    pop rsi
    mov rdx, MAX_IMG_SIZE
    syscall
    cmp rax,0
    jl errorOnRead
    push rax
    mov rax, SYS_close
    mov rdi, qword [bmpFileDesc]
    syscall 
    pop rax
    ret

;--------------------------------------------------------------------
; writeImageFile
; description: Export buffer contents to a file
; params : 
;   RDI - Memory address for the string with the name of the file to write
;   RSI - Address of the buffer containing the bytes to be written
;   RDX - Number of bytes of the buffer to write to the file
; return : none
; modify: RDI, RSI, RAX e RDX
;--------------------------------------------------------------------
writeImageFile:
    push rsi
    push rdx
    ; create output file
    mov rax, SYS_creat
    mov rsi, S_IRUSR | S_IWUSR
    syscall
    cmp rax,0
    jl errorOnOpenBmp
    mov [bmpFileDesc], rax
    ; write file
    mov rax, SYS_write
    mov rdi, qword [bmpFileDesc]
    pop rdx
    pop rsi
    syscall
    cmp rax, 0
    jl errorOnWrite
    ; close file
    mov rax, SYS_close
    mov rdi, qword [bmpFileDesc]
    syscall 
    ret

;--------------------------------------------------------------------
; error messages
;--------------------------------------------------------------------
errorOnOpenBmp:
    mov rdi, errMsgOpenBmp
    call printStrLn
    call terminate

errorOnOpenData:
    mov rdi, errMsgOpenData
    call printStrLn
    call terminate
    
errorOnRead:
    mov rdi, errMsgRead
    call printStrLn
    call terminate

errorOnWrite:
    mov rdi, errMsgWrite
    call printStrLn
    call terminate