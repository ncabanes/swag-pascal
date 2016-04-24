(*
  Category: SWAG Title: DIRECTORY HANDLING ROUTINES
  Original name: 0058.PAS
  Description: Making use of Reverse Video
  Author: HARRO LISSENBERG
  Date: 11-29-96  08:17
*)

{
 Dear SWAG-TEAM,
   I am a dutch student of English and I'm also interested in programming. In
   one of my programs I make use of 'reverse video', but I'm not satisfied
   with the way I achieve this 'reverse video'. I know it can be done much
   faster by writing and reading directly to/from video memory. Instead I have
   to call interrupt 10h for each character. Another problem I face is that I
   don't know how to store each character attribute separately. If different
   colors are used, this code is useless. I've included a part of the code I
   use as an example.
   I hope you can provide me with an answer to my questions.
 Your's sincerely,

 Harro Lissenberg
 H.N.Lissenberg@let.rug.nl
}

{
Reverse Video,
by Harro Lissenberg.
E-mail: H.N.Lissenberg@let.rug.nl
}

Uses crt;

Var
  OrX, OrY, X, Y: byte;
  Kar: char;

Procedure CursorOff; assembler;
asm
   Mov          AH, 1
   Mov          CX, 2000h
   Int          10h
end;

Procedure CursorOn; assembler;
asm
   Mov          AH, 1
   Mov          CH, 11
   Mov          CL, 12
   Int          10h
end;

Procedure RestoreLine(Line: integer);
begin
  TextColor(LightGray);
  TextBackGround(Black);
  For X:=1 to 79 do
  begin
    GotoXY(X, Line);
    asm
      Mov         AH, 8      {Read character at cursor}
      Mov         BH, 0      {Set video page}
      Int         10h
      Mov         Kar, AL    {Copy AL (contains character) to variable Kar}
    end;
    Write(Kar);
  end;
end;

Procedure RevVideo(Line: integer);
begin
  TextColor(Black);
  TextBackGround(LightGray);
  For X:=1 to 79 do
  begin
    GotoXY(X, Line);
    asm
      Mov         AH, 8      {Read character at cursor}
      Mov         BH, 0      {Set video page}
      Int         10h
      Mov         Kar, AL    {Copy AL (contains character) to variable Kar}
    end;
    Write(Kar);
  end;
end;

begin
  Y:=1;
  OrY:=WhereY;
  OrX:=WhereX;
  CursorOff;
  repeat
    RevVideo(Y);
    Delay(200);
    RestoreLine(Y);
    Inc(Y);
    If Y > 25 then Y:=1;
  until KeyPressed;
  CursorOn;
  GotoXY(OrX, OrY);
end.
