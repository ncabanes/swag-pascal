(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0052.PAS
  Description: Disable Ctrl-Break
  Author: BO KALTOFT
  Date: 11-02-93  05:29
*)

{
BO KALTOFT

> How can i disable the Pascal interrupt key Ctrl-Break?
}

Const
  BreakKey : Boolean = False;
  BreakOff : Boolean = False;
Var
  BreakSave : Pointer;

{$F+}
Procedure BreakHandler; Interrupt;
begin
  BreakKey := True;
end;
{$F-}


Procedure CBOff;
begin
  GetIntVec($1B, BreakSave);
  SetIntVec($1B, Addr(BreakHandler));
  BreakOff := True;
end;

Procedure CBOn;
begin
  SetIntVec($1B, BreakSave);
  BreakOff := False;
end;

begin
  BreakSave := Nil;
  CBOff; {disable}
  .
  .
  .
  CBOn;  {enable}
end.


