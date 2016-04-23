{
>>> How can i determine the machine's CPU clock speed from a TP
>>> program? An 100% accurate result is not required.

>> Use a counter and continually increase it. Check the clock and see how

> There's a big problem : Newer CPUs are faster in executing
> this commands and caching really speed's up the timer.
}

CONST
  Cpu8086  = 1;
  Cpu80286 = 2;
  Cpu80386 = 3;
  Cpu80486 = 4;

VAR
  CPU : BYTE;


FUNCTION CPUSpeed : BYTE; Assembler;
Asm
 MOV   DX,Cpu8086
 PUSH  SP
 POP   AX
 CMP   SP,AX
 JNE   @OUT
 MOV   DX, Cpu80286
 PUSHF

 POP   AX
 OR   AX,4000h
 PUSH  AX
 POPF
 PUSHF
 POP   AX
 TEST  AX,4000h
 JE   @OUT
 MOV DX, Cpu80386
 {"DB 66h" indicates '386 extended instruction}
 DB 66h; MOV   BX, SP      {MOV EBX, ESP}
 DB 66h, 83h, 0E4h, 0FCh   {AND ESP, FFFC}
 DB 66h; PUSHF             {PUSHFD}
 DB 66h; POP AX            {POP EAX}
 DB 66h; MOV   CX, AX      {MOV ECX, EAX}
 DB 66h, 35h, 00h
 DB 00h, 04h, 00           {XOR EAX, 00040000}
 DB 66h; PUSH   AX     {PUSH EAX}

 DB 66h; POPF              {POPFD}
 DB 66h; PUSHF             {PUSHFD}
 DB 66h; POP   AX     {POP EAX}
 DB 66h, 25h, 00h
 DB 00h, 04h, 00h          {AND EAX, 00040000}
 DB 66h, 81h, 0E1h, 00h
 DB 00h, 04h, 00h          {AND ECX, 00040000}
 DB 66h; CMP   AX, CX      {CMP EAX, ECX}
 JE @Not486
 MOV DX, Cpu80486
@Not486:
 DB 66h; PUSH   CX         {PUSH EXC}
 DB 66h; POPF              {POPFD}
 DB 66h; MOV   SP, BX      {MOV ESP, EBX}
@Out:
 MOV AX, DX
end;


begin { main }


  Writeln(CPUSpeed);  { 1, 2, 3, or 4 is returned; see above consts }


end.

