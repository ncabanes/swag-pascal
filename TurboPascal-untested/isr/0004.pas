{
│- Also, is there anyway of making "HOT-KEYS" without using ReadKey f│
│  CharS?  I want it For Integers or can I have CharS as a RANdoM #? │
│  PROBLEMO!                                                         │

> Unless you want to Write an ISR (initiate and stay resident) routine   │
> that traps keyboard interrupts and either preprocesses them or passes  │
> them on to your routine, ReadKey is the only way. (Writing an ISR      │
> is not a simple task.)                                                 │

Actualy it is not that difficult in pascal:
}
Uses
  Dos;

Const
  end_eks : Boolean = False;

Var
  IntVec  : Pointer;

Procedure Keybd; Interrupt;
Var
  Key : Byte;
begin
  Asm
    cli
  end;
  Key := Port[$60];

  Case Key of
    1   : end_eks := True;
    57  : Writeln(' You have pressed Space');
    75  : Writeln(' Left Arrow');
    77  : Writeln(' Right Arrow');
    203,
    205 : Writeln(' You have released an Arrow key');
  end;

  if not end_eks then
  Asm
    mov ah,0ch
    int 21h
    call IntVec  { Call original int 9 handler }
  end;
  { port[$20]:=$20} { if you dont call the original handler
                      you need to uncomment this }
end;

begin
  GetIntVec($09,Intvec);
  SetIntVec($09,@Keybd);
  Writeln(' Press <ESC> to end Program ');

  Repeat Until end_eks;

  SetIntVec($09,IntVec);

  Writeln(' Program terminatet');

end.