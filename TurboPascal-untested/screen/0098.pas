{
 GH> I want to suppress the screen output of an archiver
Well I have a idea how you would do that.... What you need to do is tap into
interrupt $21 and check if AH=9, if it does that means that dos is calling the
print_string (or whatever its called) function. So if you detect that, just
return, otherwise jump onto DOS and let it process that. so you would set that
up just b4 you exec, then exec, then restore the original interrupt. Heres
some code I made. It doesn't work but I think it comes fairly close.....
}

Unit DosTrap;
 Interface
  Var Int21Save : Procedure;        {Pointer to the old 1C.                  }

Procedure InstallInt21h;            {Install the interrupt routine for $1C.
}Procedure RestoreInt21h;            {Restore the original interrupt for $1C.
}Procedure Suppress(ProgramName,
                   CommandLine:
                       String);
Implementation
 Uses CRT,
      DOS;

{$F+,S-}
Procedure IntHandler;
 Interrupt;
  Assembler;
   Asm
    Cmp   AH,0
    PushF
    Je    @Done
    Call  Int21Save
   @Done:
   End;
{$F-,S-}

Procedure InstallInt21h;
 Begin
  GetIntVec($21,@Int21Save);
  SetIntVec($21,Addr(IntHandler));
 End;

Procedure RestoreInt21h;
 Begin
  SetIntVec($21,@Int21Save);
 End;

Procedure Suppress(ProgramName, CommandLine : String);
Begin
InstallInt21h;
SwapVectors;
Exec(ProgramName, CommandLine);
SwapVectors;
RestoreInt21h;
End;

End.
--------> A sample program using it...
{$M $4000,0,0 }   { 16K stack, no heap }
Uses DosTrap, Dos,Crt;
Begin
ClrScr;
WriteLn('Exec''ing');
Suppress('C:\pkunzip.exe','');
WriteLn('Done.');
End.
---------------->End.
