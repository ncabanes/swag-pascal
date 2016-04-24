(*
  Category: SWAG Title: CHARACTER HANDLING
  Original name: 0005.PAS
  Description: Redefine FONT Chars
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:33
*)

{
>> I know this can be done - in fact I've seen posts on it before, but it
>> didn't strike me as something to save at the time. . .
>  Does anyone know how to redefine the Characters used in Text mode?  I
>> don't want to use a whole new set; rather I'd like to change just about a
>> dozen or so Characters to my own.

This is a little routine I developed sometime ago to redefine some of the
ascii Chars as 'smileys'. The Arrays of hex values are Character
bitmaps. There is a rather good article about doing this sort of thing in PC
Magazine,Volume 9 number 2 (Jan 30, 1990)
}

Program Redefine;

Uses
  Dos,Crt;

Procedure loadChar;
Const
  numnewChars = 6;
Type
  ByteArray = Array[0..15] of Byte;
  CharArray = Array[1..numnewChars] of Record
    CharNum : Byte;
    CharData : ByteArray;
  end;

Const newChars : CharArray = (
   (CharNum : 21;
    CharData : ($00,$00,$E7,$A5,$E7,$00,$00,$08,$18,$38,$00,$00,$C3,$C3,$7E,$00)),
   (Charnum : 4;
    CharData : ($00,$00,$E7,$A5,$E7,$00,$00,$08,$18,$38,$00,$00,$7E,$C3,$C3,$00)),
   (Charnum : 19;
    CharData : ($AA,$AA,$FE,$00,$EE,$AA,$EE,$00,$08,$18,$38,$00,$C6,$C6,$7C,$00)),
   (Charnum : 17;
    CharData : ($03,$07,$FF,$00,$0E,$0A,$0E,$00,$00,$01,$03,$00,$08,$07,$00,$00)),
   (Charnum : 23;
    CharData : ($C0,$E0,$FF,$00,$E0,$A0,$E0,$00,$80,$80,$80,$10,$10,$E0,$00,$00)),
   (Charnum : 24;
    CharData : ($E7,$42,$00,$C3,$A5,$E7,$00,$08,$18,$38,$00,$00,$7E,$FF,$81,$00))
    );

Var
  r : Registers;
  i : Byte;

begin
for i := 1 to numnewChars do
  With r do
  begin
    ah := $11;             { video sub-Function $11 }
    al := $0;              { Load Chars to table }
    bh := $10;             { number of Bytes per Char }
    bl := 0;               { Character table to edit }
    cx := 1;               { number of Chars we're definig }
    dx := NewChars[i].CharNum;          { ascii value of the Char }
    es := seg(NewChars[i].CharData);    { es:bp --> table we're loading }
    bp := ofs(NewChars[i].CharData);
    intr($10,r);
  end;
end;

begin
  loadChar;
  Writeln('Char(21) is now ',chr(21));Writeln;
  Writeln('Char(04) is now ',chr(04));Writeln;
  Writeln('Char(19) is now ',chr(19));Writeln;
  Writeln('Char(17) is now ',chr(17));Writeln;
  Writeln('Char(23) is now ',chr(23));Writeln;
  Writeln('Char(24) is now ',chr(24));Writeln;
  readln;
  Textmode(co80);
  Writeln('Char(21) is now ',chr(21));Writeln;
  Writeln('Char(04) is now ',chr(04));Writeln;
  Writeln('Char(19) is now ',chr(19));Writeln;
  Writeln('Char(17) is now ',chr(17));Writeln;
  Writeln('Char(23) is now ',chr(23));Writeln;
  Writeln('Char(24) is now ',chr(24));Writeln;
end.

