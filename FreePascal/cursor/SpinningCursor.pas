(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0013.PAS
  Description: Spinning Cursor
  Author: SEAN PALMER
  Date: 08-27-93  21:58
*)

{
SEAN PALMER

This is an example for the cursor I talked about to someone on here...
}

program spinCursor;

uses
  crt;

var
  cursorState : byte;  {0..3}
  i           : integer;

const
  {cursorData : array [0..3] of char = (#30, #17, #31, #16);}
  cursorData : array [0..3] of char = ('-', '\', '|', '/');

procedure updateCursor;
begin
  cursorState := succ(cursorState) and 3;
  write(cursorData[cursorState], ^H);
end;

begin
  for i := 1 to 100 do
  begin
    gotoxy(1,1);
    updateCursor;
    gotoxy(1,41);
    delay(100);
  end;
end.
