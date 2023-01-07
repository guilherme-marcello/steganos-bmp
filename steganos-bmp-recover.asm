; <--- steganos-bmp-recover --->
; Program that lets you remove a message hidden inside an image
; - params: ./steganos-bmp-recover 3 snail_with_message.bmp
; - out: message

extern terminate, printStrLn, readImageFile, verifyArgs, ascii2Natural

;********************************************************************
section .data
;********************************************************************
;; handy settings ;;
NULL                equ 0
STR_MAX_SIZE        equ 1024    ; 1 KiB
BMP_MAX_SIZE        equ 409600  ; 400 KiB
;; constants ;;
REQUIRED_PARAM      equ 3       ; 5 params

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
    mov rdx, REQUIRED_PARAM    ; set rdx to number of required params
    call verifyArgs            ; check number of arguments passed
    lea rbp, [rsp + 16]        ; point rbp to first argument of executed command

    mov rdi, [rbp]             ; use rdi as a pointer to the character "0" (ex: ./steganos-bmp-recover 0 _)
    call ascii2Natural         ; update rax with the decimal translation of the character "0"
    push rax                   ; save number of rotations

    ;; read image ;;
    mov rdi, [rbp + 8]         ; colocar endereco na memoria para o nome do ficheiro imagem a ser lido
    mov rsi, bmp_buffer        ; buffet address in rsi
    push rsi                   ; save bmp buffer address
    call readImageFile
    pop rsi                    ; retrieve image address from memory
    mov rdi, txt_buffer        ; put text address in rdi

    ;; update image address with offset ;;
    xor rcx, rcx               ; set rcx to 0
    mov ecx, dword [rsi + 10]  ; put offset in ecx
    add rsi, rcx               ; point rsi to the first pixel of the image (add offset to image address)

    ;; find hidden message and update buffer ;;
    call findHiddenMessage
    push rax                   ; save character numbers

    mov rdi, txt_buffer        ; update rdi with message address
    pop rdx                    ; retrieve message size in bytes
    pop rcx                    ; return number of rotations

    ;; decrypt message ;;
    call decryptString
    call printStrLn
    call terminate


;--------------------------------------------------------------------
; decryptString
; description: Rotates each character of the string according to the indicated factor
; params:
;   RDX - Number of bytes in the string
;   RDI - Memory address for string
;   RCX - Number of rotations
;   
; return : none
; modify: RAX, RCX, RSI, R8
;--------------------------------------------------------------------
decryptString:
    cmp dl, NULL
    jl decryptDone
    rol byte [rdi + rdx], cl   ; rotate the respective character
    dec dl
    jmp decryptString
decryptDone:
    ret

;--------------------------------------------------------------------
; findHiddenMessage
; description: Print message hidden in an image
; params:
;   RDI - Memory address for string
;   RSI - Memory address for the image (starting from the first pixel)
;   
; return :
;   RAX - Number of bytes of the hidden message
; modify: RAX, RCX, RSI, R8, R9, RDX
;--------------------------------------------------------------------
findHiddenMessage:
    xor rax, rax               ; set rax to zero
    xor r8, r8                 ; set character index to 0
getCharBits: 
    xor r9, r9                 ; set the bit index to zero
getCharBitFromImage:
    cmp r9, 8                  ; Compare bit index with 8
    je gotAllCharBitsFromImage ; change flow if all character bits have been computed (r9 == 8)
    
    mov ah, [rsi]              ; put in ah the byte
    ror ax, 1                  ; put LSB in ah and MSB in al
    add rsi, 2                 ; add 2 to the byte address of the image to be updated (even indices starting from 0)
    inc r9                     ; increment bit index
    jmp getCharBitFromImage
gotAllCharBitsFromImage:
    cmp al, NULL               ; compare byte (in reverse) with NULL
    je findingDone             ; change flow to end if all characters have been found
    mov ah, al                 ; put character byte (reverse order) into ah
    xor al, al                 ; set al to zero
    xor cl, cl                 ; put zeros in counter
reverseBitsOrder: 
    cmp cl, 8                  ; compare counter with 8
    je addCharToString         ; change flow to addCharToString
    rcr ah,1                   ; make a right rotation by carry (put MSB in CF)
    rcl al,1                   ; make a left rotation by carry (put CF as LSB)
    inc cl                     ; increment counter
    jmp reverseBitsOrder
 addCharToString:
    mov [rdi], al              ; put character byte in memory address for string
    inc rdi                    ; increment string address (to point to next character)
    inc r8                     ; increment character index
    jmp getCharBits            ; encrypt and add new character
findingDone:
    add r8, 1                  ; increment character index
    mov rax, r8                ; update rax with number of saved characters
    ret