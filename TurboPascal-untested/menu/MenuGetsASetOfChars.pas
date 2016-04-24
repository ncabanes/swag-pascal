(*
  Category: SWAG Title: MENU MANAGEMENT ROUTINES
  Original name: 0005.PAS
  Description: MENU... Gets a set of chars
  Author: CHRIS AUSTIN
  Date: 11-22-95  15:49
*)


{Used like If Menu('ABCDE')='E' then DoWhatever; Or put result in variable}
Function Menu(TheCommands : String) : Char;
Var
    GotKey  : Boolean;
    Inkey   : Char;
    Counter : Byte;
Begin
GotKey:=False;
FlushBuff;
Repeat
Inkey:=ReadKeySpin(False);
Inkey:=UpCase(Inkey);
For Counter:=1 to Length(TheCommands) do
       If (Inkey=TheCommands[Counter]) or (Inkey=#27) then GotKey:=True;
Until GotKey;
Menu:=InKey;
If Inkey=#27 then Begin
                  ClrScr;
                  WriteLnColor('`8─`4─`@─ ESC ─`4─`8─');
                  End;
End;

Function YN : Boolean;
Begin
YN:=Menu('YN')='Y';
End;


