{
TSR to slow down your PC so that games that run too fast
can be playable!


Feel free to distribute!
}



{$M $800,0,0 }   { 2K stack, no heap }

uses Crt, Dos;
var
  KbdIntVec  : Procedure;
  WaitPeriod : Word;
  ErrorPos   : integer;

{$F+}



procedure DelayRoutine; interrupt;
begin
  asm cli end;
  delay(WaitPeriod);
  asm sti end;
  asm PUSHF end;
  { Call old ISR using saved vector }
  KbdIntVec;
end;




{$F-}
begin
  If ParamCount = 1 Then
     Begin
     Val (ParamStr(1),WaitPeriod,ErrorPos);
     If ErrorPos = 0 Then
        Begin
        { Insert ISR into keyboard chain }
        GetIntVec($8,@KbdIntVec);
        SetIntVec($8,Addr(DelayRoutine));
        Writeln;
        Writeln('DELAY installed !');
        Writeln;
        Keep(0); { Terminate, stay resident }
     End;
     End
  Else
      Begin
      Writeln;
      Writeln('DELAY (C) 1995 Scott Tunstall.');
      Writeln;
      Writeln('DELAY <Number of millisecs to slow computer by> ');
      Writeln;
      End;
end.


