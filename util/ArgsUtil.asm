
extern printStrLn, terminate

;********************************************************************
section .data
;********************************************************************
;; handy settings ;;
LF                  equ 10
NULL                equ 0

;; error messages ;;
errMsgNumberOfParams db "Error: incorret number of parameters.", LF, NULL
errMsgNumberOfRotates db "Error: the number of rotates must be in 0-7 range.", LF, NULL

;********************************************************************
section .text
;********************************************************************
;--------------------------------------------------------------------
; functions of the library
;--------------------------------------------------------------------
global invalid_rotation
global wrong_args
global verifyArgs


;--------------------------------------------------------------------
; verifyArgs
; description: Check number of parameters passed to the program
; params:
;   RDX - Number of required arguments
; return : none
; modify: RCX
;--------------------------------------------------------------------
verifyArgs:
    mov rcx, [rsp + 8]          ; put number of parameters in the rcx register. note: [rsp] points to return address
    cmp cl, dl                  ; compare cl with required number of parameters
    jne wrong_args              ; change flow to end, in case the number of parameters is not correct
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