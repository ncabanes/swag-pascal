(*
  Category: SWAG Title: MATH ROUTINES
  Original name: 0046.PAS
  Description: Derive PI in Pascal
  Author: BEN CURTIS
  Date: 11-02-93  10:31
*)

{
BEN CURTIS

Here is a Program that I have written to derive Pi.  The formula is
4 - 4/3 + 4/5 - 4/7 + 4/9... ad infinitum.  Unfortunately, I can only get
14 decimal places using TP 6.  if there is a way For me to be able to get
more than 14 decimal places, please let me know.

NB: Program Modified by Kerry Sokalsky to increase speed by over 40% -
    I'm sure tons more can be done to speed this up even more.
}

{$N+}

Uses
  Dos, Crt;

Var
  sum   : Real;
  x, d,
  Count : LongInt;
  Odd   : Boolean;

begin
  x   := 3;
  d   := 4;
  Sum := 4;
  Odd := True;
  Count := 0;

  Writeln(#13#10, 'Iteration Value', #13#10);

  ClrScr;

  Repeat
    Inc(Count);
    if Odd then
      Sum := Sum - d/x
    else
      Sum := Sum + d/x;
    Inc(x, 2);

    Odd := (Not Odd);

    GotoXY(1, 3);
    Write(Count);
    GotoXY(12, 3);
    Write(Sum : 0 : 7);
  Until KeyPressed;

end.

{
        I have to warn you, it took me two hours to get a definite answer
for 6 decimal places on my 486sx25.  I guess it would be faster on a dx.
I'll run it on a 486dx2/66 on Tuesday and see if I can get it out to 14
decimal places.  It takes about 135000 iterations to get 4 decimal places.
Again, please let me know if you know of a way to get more than 14 decimal
places -- I would love to get this sucker out to more. :)
}

