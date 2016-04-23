
Program Shading;

Uses CRT;

Var
  ColorNum, Y : Integer;

{--------------------------------------------------------------}

procedure setcolors;

var
  Color : Byte;
  A     : Integer;

Begin
   For A := 1 to 63 do
   Begin
    port[$3c8]:=A;
    port[$3c9]:=1;
    port[$3c9]:=1;
    port[$3c9]:=A;
   End;
end;

{----------------------------------------------------------------}

procedure horizontal_line (x1,x2,y : integer;color:byte);

Var
temp,Counter : Integer;

begin
IF X1 > X2 then
  begin
    Temp:=X1;
    X1:=X2;
    X2:=Temp;
  End;

     X1:=(y*320)+X1;
     X2:=(y*320)+X2;

 For Counter := X1 to X2 do

     mem[$A000:Counter]:=color;
End;
{---------------------------------------------------------------}
Procedure Init13h;    {Sets video to 320X200X256}

Begin

ASM
 MOV AH,00
 MOV AL,13h
 int 10h
End;
End;
{----------------------------------------------------------------}
Procedure InitText;   {Sets video to Textmode}

Begin

ASM
 MOV AH,00
 MOV AL,3
 INT 10h
End;
End;
{--------------------------------------------------------------------------}

Begin    {Main}
ColorNum:=1;
init13h;
Setcolors;
For Y:=1 to 63 do
  Begin
   Horizontal_Line(80,239,Y,Colornum);
   ColorNum:=Colornum+1;
  End;
For Y:=64 to 126 do
  Begin
   ColorNum:=ColorNum-1;
   Horizontal_Line(80,239,Y,ColorNum);
  End;
Readkey;
InitText;
End.
