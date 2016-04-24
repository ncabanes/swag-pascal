(*
  Category: SWAG Title: ISR HANDLING ROUTINES
  Original name: 0003.PAS
  Description: ISRDEMO.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:49
*)

{
It can make sense to Write Method-ISR's. Two examples:

1. Implementation of a timer-IRQ-triggered eventQueue (a body of such an
Object I append to this mail).

2. Objects For serial-IO. You can have up to 8 or 16 serial channels (with
special hardware). The priciples of encapsulation and instances suggests
an OOPS-solution! Why not including the ISR-Routine into the Object?
I'm not happy about the intentional misunderstandings to your request
in this area :-|

However, the next 2K are my act of revenge to your repliers: :-D
(Gentlemen: No flames please, I know that the demo itself makes no sense
and procedural Programming For such a simple output would be easier
and shorter!!! All I want to show, is a toRSO of an OOPS-solution For ISR's.)
}

Program isrDemo;
{$F+,S-}
Uses
    Crt,Dos;
Type
    timerObj  =    Object
                        saveInt,
                        myjob     :    Pointer;
                        stopped   :    Boolean;
                        Constructor Init(job:Pointer);
                        Destructor  DeInit;
                        PRIVATE
                        Procedure   timerInt;
                   end;
Const
    timerSelf :    Pointer   =    NIL;

Constructor timerObj.Init(job:Pointer);
begin
    if timerSelf<>NIL then FAIL;            { only one instance in this demo }
    timerSelf:=@self;
    myjob:=job;
    stopped:=False;
    getintvec($1C,saveInt);
    setintvec($1C,@timerObj.timerInt);
end;

Destructor timerObj.DeInit;
begin
    setintvec($1C,saveint); timerSelf:=NIL;
end;

Procedure timerObj.timerInt; Assembler;
Label
    _10;
Asm
    pop  bp                           { Compiler inserts PUSH BP - restore it }
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    push ds
    push es
    push bp
    mov  al,20h                        { send EOI }
    out  20h,al
    sti

    mov  bp,sp
    mov  ax,SEG @DATA
    mov  ds,ax
    les  di,[offset timerSelf]         { only one instance in this demo! }
    cmp  es:[di+stopped],0             { prevents IRQ-overruns           }
    jne  _10
    inc  es:[di+stopped]
    call dWord ptr es:[di+offset myjob]; { no test of NIL implemented    }
    les  di,[offset timerSelf]
    dec  es:[di+stopped]

   _10:
    call dWord ptr es:[di+saveInt]     { call original inT-Proc }
    mov  sp,bp
    pop  bp
    pop  es
    pop  ds
    pop  di
    pop  si
    pop  dx
    pop  cx
    pop  bx
    pop  ax
    iret
end;
(*********************** DemoShell **************************)
Var
    timer     :    timerObj;

Procedure helloHerb;
begin
    Write('.');
end;

begin
    if timer.Init(@helloHerb) then
    begin
         Delay(5000);
         timer.DeInit;
    end;
end.


