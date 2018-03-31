;***********************************************************************
;***     A D D T H R E E   M A C R O   T E S T   P R O G R A M       ***
;***********************************************************************
;***                     U S E R   M A N U A L                       ***
;***********************************************************************
;*** Macro: Addthree A, B, C
;***
;*** Side effect: A := A + B + C
;***
;*** Suitable operand types:
;***    r16/m16,    r16/m16,    r16/m16
;***    r8/m8,      r8/m8,      r8/m8
;*** PLEASE, NOTE: Constant values (immediate operands) can't be used
;***               as operands in this macro
;***
;*** You can also use tst1 and tst2 macros to test Addthree macro
;*** with 8-bit and 16-bit operands respectively, like this:
;***    tst2 op1, op2, op3
;*** These macros will print the values of operands before and after
;*** using Addthree macro
;*** But it's strongly recommended not to use neither DL nor DH register
;*** as operands in tst1 macro (because it uses DX register)
;***********************************************************************
;*** By SOHWA Disadvanced, Handmada Lab
;*** The 9th of May, 0:49 AM
;***********************************************************************
include io.asm
DEBUG = 1
NUM   = 1

stack segment stack
    dw 128 dup (?)
stack ends

data segment
    b1 db 1
    b2 db 2
    b3 db 3
    w1 dw 7
    w2 dw 30
    w3 dw 100
    d1 dd 700
    d2 dd 3000
    d3 dd 10000
data ends

code segment 'code'
    assume ss:stack, ds:data, cs:code   

.xlist
;***********************************************************************
;***                          M A C R O S                            ***
;***********************************************************************
TUNKNOWN  equ 00000000b

TVARBYTE  equ 00000101b
TVARWORD  equ 00000110b

;TCOMREG1  equ 00001001b
;TCOMREG2  equ 00001010b
TSEGREG   equ 00001110b

TREGAX    equ 00011010b
TREGAH    equ 00011001b

TREGBX    equ 00101010b
TREGAL    equ 00101001b

TREGCX    equ 00111010b
TREGBH    equ 00111001b

TREGDX    equ 01001010b
TREGBL    equ 01001001b

TREGSI    equ 01011010b
TREGCH    equ 01011001b

TREGDI    equ 01101010b
TREGCL    equ 01101001b

TREGBP    equ 01111010b
TREGDH    equ 01111001b

TREGSP    equ 10001010b
TREGDL    equ 10001001b

MASK_SIZE equ 00000011b
MASK_TYPE equ 00001100b
MASK_REG  equ 00001000b



; Useful for debugging
D macro op
    if1 ;; op won't be in the final version of code
        if DEBUG
            op
        endif
    endif
endm
; Specially for %out-directive
O macro op
    if1
        op
    endif
endm



;***********************************************************************
;***        G E T T Y P E   M A C R O   M I N I - M A N U A L        ***
;***********************************************************************
;*** OUTPUT: typevar as a bit vector
;*** typevar AND 00000011b = size of operand (1, 2 or 4 bytes)
;***                    ******01 for 8-bit registers
;***                    ******10 for 16-bit registers
;***                    Unknown type sets these bits to 00
;*** typevar AND 00001100b = type of operand
;***                    ****00** for Constant
;***                    ****01** for Variable
;***                    ****10** for Common Register
;***                    ****11** for Segment Register
;*** typevar AND 11110000b = Common Register
;***                    0000**** - NO
;***                    0001**** - AX(AH)
;***                    0010**** - BX(AL)
;***                    0011**** - CX(BH)
;***                    0100**** - DX(BL)
;***                    0101**** - SI(CH)
;***                    0110**** - DI(CL)
;***                    0111**** - BP(DH)
;***                    1000**** - SP(DL)
;***
;*** NOTE:
;*** Unknown type can be considered as a constant
;***********************************************************************
gettype macro operand, typevar
    local @typ
    typevar = TUNKNOWN              ;; Guaranteed to be equal to zero
    @typ = type (operand)
    ;; V A R I A B L E   (1   B Y T E)
    if @typ EQ 1
        typevar = TVARBYTE
        D<!%out type of &operand = BYTE>
        exitm
    endif
    ;; V A R I A B L E   (2   B Y T E S)
    if @typ EQ 2
        typevar = TVARWORD
        D<!%out type of &operand = WORD>
        exitm
    endif
    ;; R E G I S T E R
    ife @typ
        ;; 2 - B Y T E S   C O M M O N   R E G I S T E R S
        irp @regax, <ax,aX,Ax,AX>
            ifidn <@regax>, <operand>
                typevar = TREGAX
                D<!%out type of &operand = REG AX>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        irp @regbx, <bx,bX,Bx,BX>
            ifidn <@regbx>, <operand>
                typevar = TREGBX
                D<!%out type of &operand = REG BX>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        irp @regcx, <cx,cX,Cx,CX>
            ifidn <@regcx>, <operand>
                typevar = TREGCX
                D<!%out type of &operand = REG CX>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        irp @regdx, <dx,dX,Dx,DX>
            ifidn <@regdx>, <operand>
                typevar = TREGDX
                D<!%out type of &operand = REG DX>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        irp @regsi, <si,sI,Si,SI>
            ifidn <@regsi>, <operand>
                typevar = TREGSI
                D<!%out type of &operand = REG SI>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        irp @regdi, <di,dI,Di,DI>
            ifidn <@regdi>, <operand>
                typevar = TREGDI
                D<!%out type of &operand = REG DI>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        irp @regbp, <bp,bP,Bp,BP>
            ifidn <@regbp>, <operand>
                typevar = TREGBP
                D<!%out type of &operand = REG BP>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        irp @regsp, <sp,sP,Sp,SP>
            ifidn <@regsp>, <operand>
                typevar = TREGSP
                D<!%out type of &operand = REG SP>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        ;; 1 - B Y T E   C O M M O N   R E G I S T E R S
        ;;
        irp @regah, <ah,aH,Ah,AH>
            ifidn <@regah>, <operand>
                typevar = TREGAH
                D<!%out type of &operand = REG AH>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        irp @regal, <al,aL,Al,AL>
            ifidn <@regal>, <operand>
                typevar = TREGAL
                D<!%out type of &operand = REG AL>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        irp @regbh, <bh,bH,Bh,BH>
            ifidn <@regbh>, <operand>
                typevar = TREGBH
                D<!%out type of &operand = REG BH>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        irp @regbl, <bl,bL,Bl,BL>
            ifidn <@regbl>, <operand>
                typevar = TREGBL
                D<!%out type of &operand = REG BL>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        irp @regch, <ch,cH,Ch,CH>
            ifidn <@regch>, <operand>
                typevar = TREGCH
                D<!%out type of &operand = REG CH>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        irp @regcl, <cl,cL,Cl,CL>
            ifidn <@regcl>, <operand>
                typevar = TREGCL
                D<!%out type of &operand = REG CL>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        irp @regdh, <dh,dH,Dh,DH>
            ifidn <@regdh>, <operand>
                typevar = TREGDH
                D<!%out type of &operand = REG DH>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        irp @regdl, <dl,dL,Dl,DL>
            ifidn <@regdl>, <operand>
                typevar = TREGDL
                D<!%out type of &operand = REG DL>
                exitm
            endif
        endm
        if typevar
            exitm
        endif
        ;;
        ;; S E G M E N T   R E G I S T E R S
        ;;
        irp @segr, <cs,cS,Cs,CS, ds,dS,Ds,DS, ss,sS,Ss,SS, es,eS,Es,ES>
            ifidn <@segr>, <operand>
                typevar = TSEGREG
                D<!%out type of &operand = SEGREG>
                exitm
            endif
        endm
        ;;
        if typevar EQ TUNKNOWN
            D<!%out type of &operand is unknown (TYPE = 0)>
        endif
    ;; U N K N O W N   T Y P E
    else
        D<!%out type of &operand is unknown (TYPE != 0)>
    endif
endm



;***********************************************************************
;***                     S M A R T   M A C R O                       ***
;***********************************************************************
;*** This macro can be used to push and pop a register
;*** For instance, "smart push ah, TREGAH" will be replaced with
;*** "push ax"
;***********************************************************************
smart macro task, op, @typ
    if (@typ and MASK_SIZE) EQ 2
        task op
    else
        if @typ EQ TREGAH or @typ EQ TREGAL
            task ax
            exitm
        endif
        if @typ EQ TREGBH or @typ EQ TREGBL
            task bx
            exitm
        endif
        if @typ EQ TREGCH or @typ EQ TREGCL
            task cx
            exitm
        endif
        if @typ EQ TREGDH or @typ EQ TREGDL
            task dx
            exitm
        endif
    endif
endm        



;***********************************************************************
;***                   G E N C O D E   M A C R O                     ***
;***********************************************************************
;*** This macro will try to generate code for ADDTHREE macro.
;*** If it succeeds, you'll get the most optimal code ever
;*** If it doesn't, get rekt
;***********************************************************************
gencode macro rax, rah, rdx, rdh, op1, op2, op3, @typ1, @typ2, @typ3, @tregah, @tregal
    if (@typ1 and MASK_REG) ;; op1 is a register
        if @typ1 EQ @typ2
            if @typ1 EQ @typ3
                ;; REGX REGX REGX
                if @typ1 EQ @tregah or @typ1 EQ @tregal ;; op1 is AH(AX) or AL(AX)
                    push rdx
                    mov  rdh, op1
                    shl  op1, 1
                    add  op1, rdh
                    pop  rdx
                else
                    push rax
                    mov  rah, op1
                    shl  op1, 1
                    add  op1, rah
                    pop  rax
                endif
            else
                ;; REGX REGX ?
                shl  op1, 1
                add  op1, op3
            endif
        else
            if @typ1 EQ @typ3
                ;; REGX ? REGX
                shl  op1, 1
                add  op1, op2
            else
                ;; REGX ? ?
                add  op1, op2
                add  op1, op3
            endif
        endif
    else ;; op1 isn't a register
        if (@typ2 and MASK_REG) ;; op2 is a register
            if (@typ3 and MASK_REG) ;; op3 is a register
                ;; VARX REGX REGY
                add  op1, op2
                add  op1, op3
            else
                ;; VARX REGX VARY
                smart push <op2>, @typ2
                add  op2, op3
                add  op1, op2
                smart pop  <op2>, @typ2
            endif
        else ;; op2 isn't a register
            if (@typ3 and MASK_REG)
                ;; VARX VARY REGX
                smart push <op3>, @typ3
                add  op3, op2
                add  op1, op3
                smart pop  <op3>, @typ3
            else
                ;; VARX VARY VARZ
                push rax
                mov  rah, op2
                add  rah, op3
                add  op1, rah
                pop  rax
            endif
        endif
    endif
endm



;***********************************************************************
;***                  A D D T H R E E   M A C R O                    ***
;***********************************************************************
addthree macro op1, op2, op3
    local @typ1, @typ2, @typ3
    ifb <op1>
        O<!%out Addthree macro error: missing 1st operand>
        .err
        exitm
    endif
    ifb <op2>
        O<!%out Addthree macro error: missing 2nd operand>
        .err
        exitm
    endif
    ifb <op3>
        O<!%out Addthree macro error: missing 3rd operand>
        .err
        exitm
    endif
    gettype <op1>, @typ1
    gettype <op2>, @typ2
    gettype <op3>, @typ3
    ;; P O S S I B L E   F A T A L   E R R O R S
    if @typ1 EQ TUNKNOWN or @typ2 EQ TUNKNOWN or @typ3 EQ TUNKNOWN
        O<!%out Addthree macro error: only bytes, words and registers are allowed>
        .err
        exitm
    endif
    if (@typ1 and MASK_SIZE) NE (@typ2 and MASK_SIZE) or (@typ1 and MASK_SIZE) NE (@typ3 and MASK_SIZE)
        O<!%out Addthree macro error: size of arguments must not differ>
        .err
        exitm
    endif
    if @typ1 EQ TSEGREG or @typ2 EQ TSEGREG or @typ3 EQ TSEGREG
        O<!%out Addthree macro error: segment register cannot be used as an argument>
        .err
        exitm
    endif
    ;;
    ;; N O   E R R O R S
    ;;
    if (@typ1 and MASK_SIZE) EQ 2
        ;; 2 - B Y T E S   O P E R A N D S
        gencode ax, ax, dx, dx, <op1>, <op2>, <op3>, @typ1, @typ2, @typ3, TREGAX, TREGAX
    else
        ;; 1 - B Y T E   O P E R A N D S
        gencode ax, ah, dx, dh, <op1>, <op2>, <op3>, @typ1, @typ2, @typ3, TREGAH, TREGAL
    endif
	D<!%out ##Macro <%NUM> was successfully generated>
	NUM = NUM + 1
endm



;***********************************************************************
;***                            T E S T                              ***
;***********************************************************************
tst1 macro op1, op2, op3 ;; for 1-byte operands
    xor  dh, dh
    irp @op, <op1, op2, op3>
        mov  dl, @op
        outword dx, 6
    endm
    addthree op1, op2, op3
    irp @op, <op1, op2, op3>
        mov  dl, @op
        outword dx, 6
    endm
    newline
endm
tst2 macro op1, op2, op3 ;; for 2-bytes operands
    irp @op, <op1, op2, op3>
        outword @op, 6
    endm
    addthree op1, op2, op3
    irp @op, <op1, op2, op3>
        outword @op, 6
    endm
    newline
endm

.list


start:
    mov ax,data
    mov ds,ax
    
    mov  ax, 10
    mov  bx, 20
    mov  cx, 30
    mov  dx, 50
    
    ;tst2 ax,w2,ax
    ;tst2 ax,bx,cx
    ;tst2 ax,ax,bx
    ;tst2 dx,dx,dx
    ;tst2 ax,w1,w2
    ;tst2 ax,w1,bx
    ;tst2 w1,w2,w3
    ;tst1 al,b2,cl
    ;tst1 al,al,b1
    ;tst1 al,al,al
    ;mov  dx, 50
    tst1 dl,dl,dl
    tst2 dx,dx,dx
    tst1 b1,b2,bl
    ;DEBUG = 0
	
	;; E R R O R S
    ;addthree d1,d2,d3
    ;addthree w1,b1,w3
    ;addthree d2,w2,b2
    ;addthree b3,b1,w2
    ;addthree b1,b2,7
    ;addthree w1,5,20
    ;addthree 5,b1,4
    ;addthree d2,5,6
    ;addthree 5,2,w3
    ;addthree ax,w2,dl
    ;addthree ax,b3,bl

    finish
code ends
    end start 
