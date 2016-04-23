{
Author: A A Olowofoyeku

As For reading the ASCII stuff from the screen, I have a routine that
allows you to read a Character from any location on the screen.
}

Uses
  Dos;

{-- read the Character at the cursor and return it as a Char --}
Function ScreenChar : Char;
Var
  R : Registers;
begin
  FillChar(R, SizeOf(R), 0);
  R.AH := 8;
  R.BH := 0;
  Intr($10, R);
  ScreenChar := Chr(R.AL);
end;
