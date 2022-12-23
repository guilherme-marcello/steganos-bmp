; <--- steganos-bmp-cover --->
; Program that ciphers messages and hides them inside an image
; - example of usage: ./steganos-bmp-cover samples/message 3 samples/snail.bmp snail_with_message.bmp
; - out: BMP Image | snail_with_message.bmp

extern terminate, readMessageFile, printStrLn, readImageFile, writeImageFile

;********************************************************************
section .data
;********************************************************************
;; handy settings ;;
LF                  equ 10
NULL                equ 0
STR_MAX_SIZE        equ 1024    ; 1 KiB
BMP_MAX_SIZE        equ 409600  ; 400 KiB
;; constants ;;
REQUIRED_PARAM      equ 5       ; 5 params
ROTATE_FACTOR_MIN   equ '0'     ; 48
ROTATE_FACTOR_MAX   equ '7'     ; 55
;; error messages ;;
errMsgNumberOfParams db "Error: incorret number of parameters.", LF, NULL
errMsgNumberOfRotates db "Error: the number of rotates must be in 0-7 range.", LF, NULL


;********************************************************************
section .bss
;********************************************************************
txt_buffer: resb STR_MAX_SIZE
bmp_buffer: resb BMP_MAX_SIZE


;********************************************************************
section .text
;********************************************************************
global _start
_start:
    ;; check parameters ;;
    call verifyArgs             ; check number of arguments passed
    lea rbp, [rsp + 16]         ; point rbp to the first argument of the executed command 

    ;; update rotation factor ;;
    mov rdi, [rbp + 8]          ; use rdi as a pointer to the character "3" (ex: ./steganos-bmp-cover m.txt 3 0 0)
    call ascii2Natural          ; update rax with the decimal representation of "3"
    push rax                    ; push number of rotations

    ;; read txt/src data ;;
    mov rdi, [rbp]              ; put address in memory for file name
    mov rsi, txt_buffer         ; put buffer address in rsi
    call readMessageFile
    push rax                    ; push number of bytes written to the buffer (txt content)
    
    ;; cipher src data ;;
    mov rdi, txt_buffer         ; put file content address in RDI
    mov byte [rdi + rax], 0     ; add NULL to end of string
    pop rdx                     ; retrieve number of bytes from string
    pop rcx                     ; retrieve number of rotations
    push rdi                    ; push RDI file content address
    inc rdx                     ; increase string size by 1 byte (include added NULL)
    push rdx                    ; push number of bytes of string (message)
    call encryptString          ; cipher string

    ;; reading image ;;
    mov rdi, [rbp + 16]         ; put address in memory for the name of the image file to be read
    mov rsi, bmp_buffer         ; put buffer address in rsi
    push rsi                    ; push buffer address
    call readImageFile

    ;; retrive and push relevant values ;;
    pop rsi                     ; retrieve image address from memory
    pop rdx                     ; retrieve number of bytes from txt file
    pop rdi                     ; retrieve address from message content
    push rax                    ; push number of bytes read from image to buffer in memory
    push rsi                    ; push image address in memory
    
    ;; offset calculation and concealMessage ;;
    xor rcx, rcx                ; set rcx to zero
    mov ecx, dword [rsi + 10]   ; put offset in ecx
    call concealMessage

    ;; retrive relevant values ;;
    pop rsi                     ; retrieve image address
    pop rdx                     ; retrieve number of bytes read from image to buffer in memory
    mov rdi, [rbp + 24]         ; put string address (output filename) in rdi
    
    ;; save modified image ;;
    call writeImageFile
    call terminate


;--------------------------------------------------------------------
; concealMessage
; description: Hide bits of characters from a string in an image
; params:
;   RDX - Number of bytes in the string
;   RDI - Memory address for string
;   RSI - Memory address for the image (from the first pixel)
;   RCX - Displacement in bytes between the image address and its first pixel (offset)
;   
; return : none
; modify: RAX, RCX, RSI, R8
;--------------------------------------------------------------------
concealMessage:
    add rsi, rcx                ; point rsi to the first pixel of the image (add offset to image address)
    xor cx, cx                  ; set ch and cl to zero
    xor r8, r8                  ; set character index to zero
concealingChars:
    xor cl, cl                  ; set bit index to zero for each new character
    cmp r8, rdx                 ; compare r8 (character index) with message length (rdx)
    je concealDone              ; change flow to concealDone if all characters have been seen
    mov al, [rdi + r8]          ; move ascii character from index r8 to al
updateImage:
    cmp cl, 8                   ; compare bit index to byte length to ascii (7)
    je concealCharDone
    ror byte [rsi], 1           ; discard pixel byte LSB
    rcl al, 1                   ; update carry flag with character bit
    rcl byte [rsi], 1           ; LSB with carry flag bit
    add rsi, 2                  ; add 2 to the byte address of the image to be updated (even indices starting from 0)
    inc cl                      ; increment bit index
    jmp updateImage
concealCharDone:
    inc r8                      ; increment character index
    jmp concealingChars
concealDone:
    ret


;--------------------------------------------------------------------
; encryptString
; description: Rotate right a string in memory
; params:
;   RDX - Number of bytes in the string
;   RCX - Number of rotations to be made
;   RDI - Memory address for string
; return : none
; modify: RDX
;--------------------------------------------------------------------
encryptString:
    cmp dl, NULL                ; compare number of bytes with 0
    jl encryptionDone           ; change flow to end of function if less than 0
    ror byte [rdi + rdx], cl    ; rotate the respective character
    dec dl                      ; decrease index (so as to cycle through another character on the next iteration)
    jmp encryptString           ; back to encryptString
encryptionDone:
    ret 


;--------------------------------------------------------------------
; verifyArgs
; description: Check number of parameters passed to the program
; params: none
; return : none
; modify: RCX
;--------------------------------------------------------------------
verifyArgs:
    mov rcx, [rsp + 8]      ; put number of parameters in the rcx register. note: [rsp] points to return address
    cmp cl, REQUIRED_PARAM  ; compare cl with required number of parameters
    jne wrong_args          ; change flow to end, in case the number of parameters is not correct
    ret


;--------------------------------------------------------------------
; ascii2Natural
; description: Convert ascii character to natural number
; params : 
;   RDI - Memory address for the character to be 'translated'
; return : RAX - 'translated' natural number
; modify: RDI, RSI e RAX
;--------------------------------------------------------------------
ascii2Natural:
    mov al, [rdi]               ; move ascii character to al
    cmp al, ROTATE_FACTOR_MIN   ; compare character with '0'
    jb invalid_rotation         ; change flow to error if character is less
    cmp al, ROTATE_FACTOR_MAX   ; compare character with '7'
    ja invalid_rotation         ; change flow to error if character is larger
    and al, 0x0F                ; apply mask to isolate required bits (translation) 
    ret


;--------------------------------------------------------------------
; error messages
;--------------------------------------------------------------------
invalid_rotation:
    mov rdi, errMsgNumberOfRotates
    call printStrLn
    call terminate

wrong_args:
    mov rdi, errMsgNumberOfParams
    call printStrLn
    call terminate