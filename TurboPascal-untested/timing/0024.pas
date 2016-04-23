{
> Does anybody knows if there's a timer function in turbo pascal (version 5) or
> turbo pascal for windows in which the user could start and stop a timer using
> this function.

Here is the unit I wrote for high precision timing.  Is can be used for
timing events of up to 54 milliseconds duration accurate to a few microseconds.
Hope it helps.

From: JOHARROW@homeloan.demon.co.uk (John O'Harrow)
}
UNIT Timer;

(*High Precision Timer Library for Borland Pascal, for timing operations 
  of less than 54 milliseconds duration, accurate to a few microseconds.
  Based on code originally written by Michael Abrash for his book "Zen of
  Assembly language", and on Kendall Bennett's subsequent enhancements.*)

INTERFACE

  PROCEDURE StartTimer;          {Start the High-Precision Timer   }
  PROCEDURE StopTimer ;          {Stop the High-Precision Timer    }

  FUNCTION  TimeTaken : LongInt; {Return Time Taken in Microseconds}
                                 {Returns -1 if Time Taken > 54 mS }
IMPLEMENTATION

VAR
  Flags    : Byte;
  Overflow : Byte;
  Counter  : Word;
  RefCount : Word;

  PROCEDURE RefOn; ASSEMBLER;
  ASM
    mov  al,00110100b
    out  43h,al
    db   $EB,0,$EB,0,$EB,0
    sub  al,al
    out  40h,al
    db   $EB,0,$EB,0,$EB,0
    out  40h,al
  END;

  PROCEDURE RefOff; ASSEMBLER;
  ASM
    mov  al,0
    out  43h,al
    db   $EB,0,$EB,0,$EB,0
    in   al,40h
    db   $EB,0,$EB,0,$EB,0
    mov  ah,al
    in   al,40h
    xchg ah,al
    neg  ax
    add  [RefCount],ax
  END;

  PROCEDURE StartTimer; ASSEMBLER;
  ASM
    pushf
    pop  ax
    mov  [Flags],ah
    and  ah,0fdh
    push ax
    sti
    mov  al,00110100b
    out  43h,al
    db   $EB,0,$EB,0,$EB,0
    sub  al,al
    out  40h,al
    db   $EB,0,$EB,0,$EB,0
    out  40h,al
    mov  cx,10
  @@Delay:
    Loop @@Delay
    cli
    mov  al,00110100b
    out  43h,al
    db   $EB,0,$EB,0,$EB,0
    sub  al,al
    out  40h,al
    db   $EB,0,$EB,0,$EB,0
    out  40h,al
    popf
  END;

  PROCEDURE StopTimer; ASSEMBLER;
  ASM
    pushf
    mov  al,0
    out  43h,al
    mov  al,00001010b
    out  20h,al
    db   $EB,0,$EB,0,$EB,0
    in   al,20h
    and  al,1
    mov  [Overflow],al
    sti
    in   al,40h
    db   $EB,0,$EB,0,$EB,0
    mov  ah,al
    in   al,40h
    xchg ah,al
    neg  ax
    mov  [Counter ],ax
    mov  [RefCount],0
    mov  cx,16
    cli
  @@Loop:
    call RefOn
    call RefOff
    loop @@Loop
    sti
    add  [RefCount],8
    mov  cl,4
    shr  [RefCount],cl
    pop  ax
    mov  ch,[Flags]
    and  ch,2
    and  ah,0fdh
    or   ah,ch
    push ax
    popf
  END;

  FUNCTION TimeTaken : LongInt; ASSEMBLER;
  ASM
    cmp  [Overflow],0
    jz   @@Good
    mov  ax,0FFFFh
    mov  dx,0FFFFh
    jmp  @@Done
  @@Good:
    mov  ax,[Counter ]
    sub  ax,[RefCount]
    mov  dx,8381
    mul  dx
    mov  bx,10000
    div  bx
    xor  dx,dx
  @@Done:
  END;

END.

