(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0023.PAS
  Description: READLNXY
  Author: ERIC MILLER
  Date: 05-28-93  13:39
*)

{
ERIC MILLER

> My question is this: In TP, the outtextxy is supposed to change the
> CP (current pointer) to the location given in x,y. When you execute a
> readln after a outtextxy or even and outtext, the program always
> starts at 0,0.. Is there a way to set the CP where the readln will
> recognize it?

  Here's a demo of a procedure called ReadlnXY; it reads
  a string in graphics mode using BGI support.
}

PROGRAM Graphics_Readln;

Uses
  Crt, Graph;

PROCEDURE ReadlnXY(X, Y: Integer; VAR S: String);
VAR
  Ch       : Char;    { key from keyboard }
  Done     : boolean; { our flag for quiting }
  CurColor : word;    { color to write text in }
  OldX     : Integer; { old x }

BEGIN
  S := '';
  CurColor := GetColor;
  MoveTo(X, Y);
  Done := False;
  WHILE NOT Done  DO
  BEGIN
    Ch := Readkey;  { get a single key }

    CASE Ch of
      #0  : { extra key - two chars - let's ignore them }
        Ch := Readkey;

      #13 : { return key }
        Done := true; { we got our string, let's go }

      #32..#126:  { ASCII 32 (space) through 126 (tilde) }
        BEGIN
          OutText(Ch);
          S := Concat(S, Ch);
        END;

      #8  : IF Length(S) > 0 THEN
        BEGIN
          { move back to last character }
          OldX := GetX - TextHeight(S[Length(S)]);
          MoveTo(OldX, GetY);
          { over write last character }
          SetColor(0);
          OutText(S[Length(S)]);
          SetColor(CurColor);
          MoveTo(OldX, GetY);
          { remove last character from the string }
          Delete(S, Length(S), 1);
        END;

    END;
  END;
END; { ReadlnXY }



VAR
  GraphMode, GraphDriver: Integer;
  Name, PathToDriver: String;

BEGIN

  GraphDriver := VGA;            { VGA }
  GraphMode := VGAHi;            { 640x480x16 }
  PathToDriver := 'D:\BP\BGI';   { path to EGAVGA.BGI }
     { you can make this program work with EGA 640x350x16 -
       it  requires 640 wide and 16 colors to work for this
       example, but ReadlnXY should work in any graphics mode }
  InitGraph(GraphDriver, GraphMode, PathToDriver); { set graphics mode }

  SetTextStyle(DefaultFont, HorizDir, 2);

  SetColor(12);

  OutTextXY(63, 63, 'Please enter your name: ');
  SetColor(13);
  ReadlnXY(63 ,95, Name);
  CloseGraph;
  Write('The name you entered was: ');
  Writeln(Name);
END.

