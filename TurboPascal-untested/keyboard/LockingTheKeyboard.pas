(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0043.PAS
  Description: Locking the Keyboard
  Author: STEVEN TALLENT
  Date: 08-27-93  21:32
*)

{
STEVEN TALLENT

You can disable the whole keyboard like this:

Sample program by Kerry Sokalsky
}

Uses
  KScreen;

Procedure KeyboardEnable; {unlocks keyboard}
begin
  Port[$21] := Port[$21] and 253;
 end;

Procedure KeyboardDisable; {locks keyboard}
begin
  Port[$21] := Port[$21] or 2;
end;

Var
  X : Integer;

begin
  ClrScr;

  KeyboardDisable;

  For X := 1 to 10000 do
  begin
    GotoXY(1,1);
    Write(X);
    If Keypressed then
    begin
      ClearBuffer;
      gotoxy(10,10);
      write('This should never occur! - ', X);
    end;
  end;

  ClearBuffer; { This is here because even though the keyboard is turned off,
                 each key is still placed in the buffer }
  KeyboardEnable;

  For X := 1 to 15000 do
  begin
    GotoXY(1,1);
    Write(X);
    If Keypressed then
    begin
      ClearBuffer;
      gotoxy(10,10);
      write('This could occur! - ', X);
    end;
  end;

end.
