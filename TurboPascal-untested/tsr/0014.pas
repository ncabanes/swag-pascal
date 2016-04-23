{
MARC BIR

>I'm looking For a template to build TSR Program.
}

{$M 2048, 0, 5120}
Uses
  Dos;

Var
  OldKbdIntVec : Procedure;

Procedure DoWhatever;
begin
 if Mem[$B800:0] <> 32 Then
   FillChar(Mem[$B800:0], 80 * 2, 32)
 else
   FillChar(Mem[$B800:0], 80 * 2, 23);
end;

{$F+}
Procedure NewKbdIntVec; Interrupt;
Var
  Input : Byte;
begin
  Input := port[$60];
  if Input = $3B then { F1 }
    DoWhatever;
  Inline ($9C);
  OldKbdIntVec;
end;
{$F-}

begin
  GetIntVec($9,@OldKbdIntVec);
  SetIntVec($9,@NewKbdIntVec);
  Keep(0);
end.

{
This works, but you will most likely want a better TSR initiater than
KEEP, there are some PD/Shareware ones out.  if you still need code,
NETMAIL me, the code I have For TSR's is a couple hundred lines...
}
