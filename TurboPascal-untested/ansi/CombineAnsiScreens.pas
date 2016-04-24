(*
  Category: SWAG Title: ANSI CONTROL & OUTPUT
  Original name: 0018.PAS
  Description: Combine Ansi Screens
  Author: JAMES FIELDEN
  Date: 11-02-93  04:47
*)

{
JAMES FIELDEN

> Ok, but how would you get the actual ANSI screens into one file,
> (TheDraw for example makes them individually), and then know
> their starting and ending positions?
Here's part of a routine I used back in 1988 When I was a WWIV Junky When it
was in Turbo Pascal.  I used this to combine all my ansi screens into
one file and just pick the one out I needed.
}

uses
  Dos, Crt;

Var
  infil  : Text;
  nilfil : Text;
  Star   : String;
  Enn    : String;
  Cup    : String[5];

Procedure PrintScr(Tfil, Loca, ELoca : String);
Begin
  assign(infil, Tfil);
  {$I-}
  reset(infil);
  {$I+}
  if IOResult <> 0 then
  begin
    Writeln(Tfil, ' Not Found');
    Exit;
  end;
  assign(nilfil,'');
  rewrite(nilfil);
  repeat
    readln(infil, Star);
    Cup := Copy(Star,1,5);
  until (Cup = Loca) or EOF(infil);
  repeat
    readln(infil, Enn);
    Cup := Copy(Enn, 1, 5);
    if Cup = ELoca then
      writeln
    else
      Writeln(nilfil,Enn);
  until (Cup = ELoca) or EOF(infil);
  close(infil);
  close(nilfil);
end;
begin
  PrintScr('Bulk.Ans','@2---','@3---');
end.

'Bulk.ans' would be in this format :
@1-------------------------------------------------------------------
Esc[2J This is your first ansi screen;;;
@2-------------------------------------------------------------------
Esc[K This would be your second ansi screen and so on and on I
had about 6 or 7 ANSI screens in One file
@3-------------------------------------------------------------------
I used ANSIDraw to make my screens and then used Turbo3 to add them
all into one file with the Ctrl-K,R Command. (TheDraw and Qedit) would
be much better To use now thought.
I tested this Program on a few ANSI Screens I thur together into one
and it worked ok here using Turbo Pascal 7.0
I'm sure this could be done better as well but if it helps good!

