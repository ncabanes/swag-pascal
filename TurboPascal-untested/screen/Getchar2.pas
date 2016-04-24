(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0006.PAS
  Description: GETCHAR2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:56
*)

{
>I need a routine that will go to a specific screen position and grab one
>or two Characters that are there (or next to it) - e.g It would go to row
>1 column 1 and return With the Character in that spot..

Try this For TP 6.0
}

Uses
  Crt;

Function ScrnChar(x,y:Byte):Char;
Var
  xkeep, ykeep : Byte;
begin
  xkeep := whereX;
  ykeep := whereY;
  GotoXY(x, y);
  Asm
    push  bx
    mov   ah,8
    xor   bx,bx
    int   16
    mov   @Result,al
    pop   bx
  end;
  GotoXY(xkeep,ykeep)
end;
{
I am not sure about the "@Result" as being the correct name, but TP 6.0 has a
name that is used For the result of a Function. This should be Compatible with
the Windows etc. of TP 6.0
}

Var
  ch : Char;
  Count : Integer;

begin
  ClrScr;
  For Count := 1 to 500 do
  begin
    Write(chr(Count));
    if count mod 80 = 0 then
      Write(#13#10);
  end;
  ch := scrnChar(5,5);
  Write(#13#10#10#10#10#10,'The Character at position (5,5) is: ',ch);
  readln;
end.
