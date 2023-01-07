
extern invalid_rotation

;********************************************************************
section .data
;********************************************************************
;; constants ;;
ROTATE_FACTOR_MIN   equ '0'    ; 48
ROTATE_FACTOR_MAX   equ '7'    ; 55

;********************************************************************
section .text
;********************************************************************
;--------------------------------------------------------------------
; functions of the library
;--------------------------------------------------------------------
global ascii2Natural


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