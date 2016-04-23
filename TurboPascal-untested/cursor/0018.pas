{
JEFF HLYWA

> One more thing, how could I reWrite the GotoXY command For use
> through the comport?

Ok.. if you are using the Fossil Driver routines you can do this.
}

Procedure SetCursorPos(XPos, Ypos : Byte); Assembler;
Asm
  SUB  XPos, 1     { Subtract 1 from X Position }
  SUB  YPos, 1                  { Subtract 1 from Y Position }
  MOV  AH, $11
  MOV  DH, YPos
  MOV  DL, XPos
  INT  14h
end;

{ We subtracted 1 from both the X Position and Y Position because when you
use the SetCursorPos the orgin ( upper left hand corner ) coordinates are
0,0. Using the GotoXY the orgin coordinates are 1,1.  For example : if we
wanted to GotoXY (40,12) using the SetCursorPos Without the subtraction
commands the cursor would be located at (41,13).  Pretty simple }

{ The follow Procedure gets the current cusor postion }

Procedure GetCursorPos;
{ Returns then X Coordinate and Y Coordinate (almost like WhereX and WhereY).
You must define X and Y as an Integer or Byte in the Var section of your
Program }
Var
  XCord,
  YCord : Byte;          { Use temporary coordinates }
begin
  Asm
    MOV  AH, $12
    INT  14h
    MOV  YCord, DH
    MOV  XCord, DL
    ADD  YCord, 1  { Add 1 to the Y Coordinate }
  end;
  X := XCord;             { Set X and Y }
  Y := YCord;
end;

