(*
  Category: SWAG Title: NOVELL/LANTASTIC NETWORK ROUTINES
  Original name: 0013.PAS
  Description: Novell Detection
  Author: DENNIS RUSH
  Date: 01-27-94  12:10
*)

{
> Is there a way to detect if a system is running under Novell
> Netware? There must be an interrupt to do that, but wich one?


     Yes there is.  Although this is in assembly, I'm sure you can dig
out what you need and convert it to Pascal or inline ASM. I've also
included for the more common multitaskers. I always try to check for
each at the beginning of a program so I can code to take advantage of
the features of whatever system it's operating under, or at least
prevent problems.
}

;*****************************************************************
;*    Check to see if we are running under a Novell Network      *
;*****************************************************************
.public     chk_novell
.proc       chk_novell  auto
    .push   es,di               ; Protect the registers well use
    xor     ax,ax               ; and clear them
    push    ax
    push    ax
    .pop    es,di
    mov     ax,07A00H           ; Novel Netware installation check
    int     2FH                 ; Check it
    or      al,al               ; If installed, al = 0FFH
                                ;  ES:DI ptr -> far entry point for
                                ;  routines otherwise accessed through
                                ;  INT 21H
    jnz     double_check        ; Appears to be installed, see if there
                                ;  is a far address in ES:DI
    stc                         ; Set carry to indicate no network
    .pop    es,di               ; restore what we used
    ret                         ; and exit
double_check:
    push    di                  ; Check
    pop     ax
    or      ax,ax               ; Is it empty
    jnz     in_novell           ; No has pointer so were in a network
    push    es
    pop     ax
    or      ax,ax               ; Is it empty
    jnz     in_novell           ; No has pointer
    stc                         ; No pointer to far address so no network
                                ;  Chance of a ptr to 0000:0000 are
                                ;  basically non-existant
in_novell:
    .pop    es,di               ; Clean up after ourselves
    ret                         ; and go home
.endp       chk_novell
;***********************************************************************
;* Check to see if we are running under Desqview, TopView, or TaskView *
;***********************************************************************
.public     chk_desq
.proc       chk_desq  auto
    .push   ax,bx               ; Save registers we will use
    mov     ax,1022H            ; This is the get version function
                                ;  that TopView installs for Int 15H.
                                ;  Most TopView compatibles use the
                                ;  same function so we can check for
                                ;  several with just one call
    xor     dx,dx               ; Clear dx
    int     15H                 ; Make the call
    cmp     bx,0a01H            ; DesqView 2.x returns 0A01H
    jnz     try_task            ; Did we get it
    mov     @dataseg:Desqview,1 ; YES, save it and go home
    jmp     short No_View
try_task:                       ; No, Try TaskView
    cmp     bx,0001H            ; TaskView Returns 0001H
    jnz     try_top             ; Get it
    mov     @dataseg:TaskView,1 ; Yes
    jmp     short No_View
try_top:                        ; No, try TopView. Top View returns it's
    or      bx,bx               ; version so just test for non-zero
    jz      No_View             ; is it non-zero
    mov     @dataseg:TopView,1  ; Yes, save it
No_View:
    .pop    ax,bx               ; Restore regs and go home
    ret
.endp       chk_desq

{
   Hope this helps. BTW, I don't know about the later versions of
Windows, but the older versions respected the Desqview installation
check.
}

