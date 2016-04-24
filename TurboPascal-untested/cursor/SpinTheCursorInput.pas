(*
  Category: SWAG Title: CURSOR HANDLING ROUTINES
  Original name: 0008.PAS
  Description: Spin The Cursor INPUT
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:36
*)

Program SpinKey;

Uses Crt;
(*   ^^^^
     This is only For "beautifying" the stuff. XCrt has the Procedures:
     HideCursor
     ShowCursor
     but they are not Really important, perhaps you have youre own
*)

Const
  SpinChar : Array [1..4] of Char = ('│','/','─','\');

Function ReadKeySpin(Wait : Byte) : Char;
Var
  X,Y  : Byte;
  Num  : Byte;
  Ch   : Char;
begin
  Num := 1;                               (* initialize SpinChars  *)
  X   := WhereX;                          (* Where am I ??         *)
  Y   := WhereY;
  Repeat
    Write(SpinChar[Num]);           (* Spin the Cursor       *)
    GotoXY(X, Y);                   (* Go back               *)
    Delay(Wait);                    (* Wait, it's to fast!   *)
    Write(#32);                     (* Clean Screen          *)
    GotoXY(X, Y);                   (* Go back               *)
    Inc(Num);                       (* Next SpinChar, please *)
    if Num = 5 then Num := 1;       (* I have only 5 Chars   *)
  Until KeyPressed;
  Ch := ReadKey;                        (* Get the pressed Key   *)
  Write(Ch);                            (* and Write it to screen*)
  ReadKeySpin := Ch;                    (* give a result         *)
end;

Function ReadStringSpin : String;
Var
  Help : String;
  Ch   : Char;
  i    : Byte;
begin
  Help := '';
  Repeat
    Ch := ReadKeySpin(40);
    if Ch <> #13 then Help := Help + Ch;
  Until Ch = #13;
  ReadStringSpin := Help;
  WriteLn;
end;

Var
  TestString : String;
begin
  TestString := ReadStringSpin;
end.

