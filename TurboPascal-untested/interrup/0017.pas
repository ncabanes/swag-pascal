
unit NonStop;                         {Makes your program UNSTOPPABLE!}

interface

 var
   Intr09 : pointer absolute $0000:$0024; {Interrupt $09, keyboard ISR}
   OldIntr09 : pointer;                   {Original Interrupt $09     }

const
   NoBoot  : boolean = true;              {flag to disable soft boot  }
   NoBreak : boolean = true;              {flag to disable Ctrl-Break }
   NoCtrlC : boolean = true;              {flag to disable Ctrl-C     }

 procedure InstallNonStopISR;
 procedure NonStopExitProc;

implementation

 var
   PreNonStopExitProc : pointer;

 const
   Installed : boolean = false;

 procedure NonStopISR; External; {$L NonStop}

 procedure InstallNonStopISR;

 begin
  if not Installed then
  begin
   OldIntr09 := Intr09;
   inline($fa);                       {CLI - disable interrupts         }
   Intr09 := @NonStopISR;              {Link NonStop into interrupt chain}
   inline($fb);                       {STI - enable interrupts          }
   PreNonStopExitProc := ExitProc;    {Save old ExitProc                }
   ExitProc := @NonStopExitProc;      {Link in NonStopExitProc          }
   Installed := true;
  end;
 end;

 procedure NonStopExitProc;

 begin
  ExitProc := PreNonStopExitProc;      {Point ExitProc to next  }
  inline($fa);                         {CLI - disable interrupts}
  Intr09 := OldIntr09;                 {Restore Original Vector }
  inline($fb);                         {STI - enable interrupts }
 end;

end.

*XX3402-000419-090294--72--85-43138-----NONSTOP.OBJ--1-OF--1
U+o+0qtjPbBoPr+iEJBBG6UU++++53FpQa7j623nQqJhMalZQW+UJaJmQqZjPW+n9X8NW-A+
ECblGoYQ0qtjPbBoPr+iEJBBQ6U1+21dH7M0++-cW+A+E84IZUM+-2F-J234a+Q+G++++U2-
3NM4++F1HoF3FNU5+0WW++A-+N8A7U+4HYx0HoxI++RCHo7GFI39++RCHoBIIYl1++ZDH2F7
HZFGA1Y+l7+F+++00YtDHZBIHp-7Ip6++++oW+E+E86-YO0V++6++-tEi+++XhUilUOR+CeE
znM0+Dwq+++iXkOS+0uD-e++Aw0CqDwq7+-M-HA+I6w47+-M5ls4I9V++6v+i+++XhUaWWML
+61Y-61A+5FAt4+mt+ca++-o2mO87VQ+UCE6UAk+R+MwIrI0ulcmt+ca++-o-XnURE9f119Y
0WM++5END0tp3SFVWi+AUCNVVi1aDTek6CMUK+QTnzhM-lw6b0s+l+dI+gENJ+925ZE0m+BI
+QEE-U22l-E4+EH6D3E-l3A4+E52PUM-+gFw-U21m6c5+A2++U6++8c+
***** END OF BLOCK 1 *****


{ ------------------------   ASSEMBLER MODULE  --------------------- }
;ASM NONSTOP.PAS

DATA    SEGMENT WORD PUBLIC
        ASSUME DS:DATA
EXTRN   NoBoot    : BYTE
EXTRN   NoBreak   : BYTE
EXTRN   NoCtrlC   : BYTE
EXTRN   OldIntr09 : DWORD
DATA    ENDS

CODE    SEGMENT BYTE PUBLIC
        ASSUME CS:CODE

NonStopISR PROC FAR
           PUBLIC NonStopISR

        push    ds                     ;This is the initialization code
        push    ax                     ;It will be used only once
        mov     ax, seg DATA           ;To fix up the far jump
        mov     ds, ax                 ;put Global Data Segment in DS
        mov     cs:[JmpCode], 0eah     ;install far jump op code
        push    [OldIntr09]            ;put pointer to old interrupt 09
        pop     cs:Offs                ;in far jump offset
        pop     cs:Segm                ;in far jump segment
        xor     ax,ax                  ;point DS to interrupt vector table
        mov     ds,ax                  ;ie, ds=0
        push    ds:[24h]               ;Put offset of Int 09
        pop     ax                     ;in ax
        add     ax, Entry - NonStopISR ;Adjust past init code
        push    ax
        pop     ds:[24h]               ;revector to regular entry point
        pop     ax
        pop     ds
Entry:
        push    ds
        push    es
        push    ax
        mov     ax, 40h                ;point es
        mov     es, ax                 ;to BIOS data area
        mov     ax, seg DATA           ;point ds
        mov     ds, ax                 ;to data segment
        mov     ah, es:[17h]           ;put keyboard shift flags in ax
        and     ah, 00000100b          ;mask out everything but ctrl flag
        or      ah, 00000000b          ;see if zero
        jz      NormalKey              ;chain on if ctrl not pressed
        in      al, 60h                ;get make/break code
        xor     ah, ah                 ;zero ah
        or      ah, NoBoot             ;Is flag set to disable soft boot?
        jz      CheckBreak             ;No? Go check for break
        mov     ah, es:[17h]           ;get keyboard shift flags
        and     ah, 00001000b          ;mask out all but alt flag
        or      ah, 00000000b          ;is result zero?
        jz      CheckBreak             ;go on to check for break
        cmp     al, 53h                ;is it del make?
        jnz     CheckBreak             ;no, chain on to old int 09
        jmp short TossIt               ;Soft boot attempted - no dice!
CheckBreak:
        xor     ah, ah                 ;zero ah
        or      ah, NoBreak            ;Flag set to disable ctrl-break?
        jz      CheckCtrlC             ;No? Go check for Ctrl-C
        cmp     al, 0E0h               ;is it Break make?
        jnz     CheckCtrlC             ;No? Go check for Ctrl-C
        jmp short TossIt               ;Ctrl-Break attempted - toss it!
CheckCtrlC:
        xor     ah, ah                 ;zero ah
        or      ah, NoCtrlC            ;flag set to disabe ctrl-c?
        jz      NormalKey              ;No? Chain on to old ISR
        cmp     al, 2Eh                ;C pressed?
        jnz     NormalKey              ;No? Chain on to old ISR
TossIt:
        in      al, 61h                ;read keyboard control port
        mov     ah, al
        or      al, 10000000b          ;set the "reset" bit
        out     61h, al                ;send it back to control
        xchg    ah, al                 ;get back control value
        out     61, al                 ;send it out also
        cli
        mov     al, 20h                ;send EOI to the
        out     20h, al                ;interrupt controller
        pop     ax;
        pop     es;
        pop     ds;
        iret                           ;LATER, DUDE!
NormalKey:
        sti                            ;allow interrupts
        pop     ax                     ;cleanup and
        pop     es
        pop     ds
JmpCode db      ?                      ;Far jump to old Int 09
Offs    dw      ?
Segm    dw      ?

NonStopISR  ENDP
CODE    ENDS
        END     NonStopISR

