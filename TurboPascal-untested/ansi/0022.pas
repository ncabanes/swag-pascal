{
The following Functions provide a way to determine if the machine
the your application is running on has ANSI installed.

if your Program is written using the Crt Unit the Function may return
the result as False even if ANSI is present, unless you successfully
use a 'work around' method to ensure all Writes go through Dos.

I find it's easier just to not use Crt if my Program is working With
ANSI - since there is not much that you use the Crt Unit For that can't
be done in some other way.

The Dos-based alternatives to ReadKey and KeyPressed are included since
they are needed For the AnsiDetect Function.
}

Uses
  Dos;

Function KeyPressed : Boolean;
  { Detects whether a key is pressed. Key remains in kbd buffer}
Var
  r: Registers;
begin
  r.AH := $0B;
  MsDos(r);
  KeyPressed := (r.AL = $FF);
end;

Function ReadKey : Char;
Var
  r: Registers;
begin
  r.AH := $08;
  MsDos(r);
  ReadKey := Chr(r.AL);
end;

Function AnsiDetected : Boolean;
{ Detects whether ANSI is installed }
Var
  dummy: Char;
begin
  Write(#27'[6n');               { Ask For cursor position report via }
  if not KeyPressed              { the ANSI driver. }
  then
    AnsiDetected := False
  else
  begin
    AnsiDetected := True;
    { empty the keyboard buffer }
    Repeat
      Dummy := ReadKey;
    Until not KeyPressed;
  end;
end;

begin
end.

