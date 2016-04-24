(*
  Category: SWAG Title: SCREEN SAVING ROUTINES
  Original name: 0003.PAS
  Description: SAVE3.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:56
*)

>---------< How to save/restore the whole screen >----------
{$X+}
Uses Crt;

Type PScreenBuf = ^TScreenBuf;
     TScreenBuf = Array [1..2000] of Word;

Var ScreenBuf: PScreenBuf;   { Pointer to actual video ram }
    Scr:       TScreenBuf;   { buffer For screen storage   }
    VideoPort: Word Absolute 0:$463;  { the video port adr }
    i:         Byte;         { :-) you'll always find it   }
                             { in Programs like this :-)   }
begin
  if VideoPort = $3D4 then
    ScreenBuf := Ptr ($B800,0)        { oh, it's color :-) }
  else
    ScreenBuf := Ptr ($B000,0);          { oh no, mono :-( }

  Scr := ScreenBuf^;                   {*** SAVE SCREEN ***}

  if ReadKey=#0 then ReadKey;           { wait For any key }
  For i:=1 to 60 do
    Writeln ('Hello guys out there...');  { DESTROY SCREEN }
  if ReadKey=#0 then ReadKey;           { wait For any key }

  ScreenBuf^ := Scr;                {*** REStoRE SCREEN ***}

  if ReadKey=#0 then ReadKey;           { wait For any key }
end.
>-----------------< Yes! Even tested! >---------------------

