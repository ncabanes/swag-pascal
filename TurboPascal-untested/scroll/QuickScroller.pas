(*
  Category: SWAG Title: SCREEN SCROLLING ROUTINES
  Original name: 0006.PAS
  Description: Quick Scroller
  Author: BERNIE PALLEK
  Date: 11-02-93  06:14
*)

{
BERNIE PALLEK

>Would anyone happen to know how I can use the ASCII Characters
>while in Video mode $13 (320x200x256)? Or better yet, make a message
>scroll across the screen like in them neat intros and demos..

The easiest way to do it is to set DirectVideo to False (if you are using
the Crt Unit).  This disables direct Writes to the screen, meaning that
the BIOS does screen writing, and the BIOS works in just about every
screen mode.  Then, you can just use Write and WriteLn to display Text
Characters (I think GotoXY will even work).  As For scrolling...
Since mode 13h ($13) has linearly addressed video memory (just a run
of 64,000 contiguous Bytes), do something like this:

this is untested, but it might actually work  :')
}

Uses
  Crt;
Const
  msgRow = 23;
  waitTime = 1; { adjust suit your CPU speed }
  myMessage : String = 'This is a test message.  It should be more ' +
        'than 40 Characters long so the scrolling can be demonstrated.';
Var
  sx, xpos : Byte;

Procedure MoveCharsLeft;
Var
  curLine : Word;
begin
  { shift the row left 1 pixel }
  For curLine := (msgRow * 8) to (msgRow * 8) + 7 DO
    Move(Mem[$A000 : curLine * 320 + 1], Mem[$A000 : curLine * 320], 319);
  { clear the trailing pixels }
  For curLine := (msgRow * 8) to (msgRow * 8) + 7 DO
    Mem[$A000 : curLine * 320 + 319] := 0;
end;

begin
  Asm
    MOV AX, $13
    INT $10
  end;
  DirectVideo := False;
  GotoXY(1, msgRow + 1);
  Write(Copy(myMessage, 1, 40));
  { 'myMessage' must be a String With a Length > 40 }
  For xpos := 41 to Length(myMessage) do
  begin
    For sx := 0 to 7 do
    begin
      MoveCharsLeft;
      Delay(waitTime);
    end;
    GotoXY(40, msgRow + 1);
    Write(myMessage[xpos]);
  end;
  Asm
    MOV AX, $3
    INT $10
  end;
end.

{
This may not be very efficiently coded.  As well, it could benefit from
an Assembler version.  But it should at least demonstrate a technique
you can learn from.  }


