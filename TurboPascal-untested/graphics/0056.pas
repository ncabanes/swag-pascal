{
-> I'm trying to use the GetImage and PutImage commands from Turbo
-> Pascal

Okay.. did you declare a varible that would hold the size you needed? I
have a little program I wrote to draw a musical staff and put the notes
up randomly so that I can practice reading music..
}

Program MusicNotes;

Uses
  Crt,
  Dos,
  Graph,
  XtraDos;

const
  NotePos : Array[1..11] Of Integer =
(164,179,194,209,224,239,254,269,284,299,314);
  Note : Array[1..11] Of Char =
('G','F','E','D','C','B','A','G','F','E','D');

Procedure Beep;

begin
  sound(600);
  delay(100);
  nosound;
end;

var
  CallUnit : CallH;
  Key : Char;
  P : Pointer;
  Size : Word;
  Y, X,
  MaxX, MaxY,
  grMode,
  grDriver : Integer;

Begin
grDriver := Detect;
InitGraph(grDriver, grMode,'D:\bp\bgi');
MaxX:=GetMaxX;
MaxY:=GetMaxY;
SetColor(white);
Circle(15,15,15);
FloodFill(15,15,white);
Size:=ImageSize(0,0,30,30);
GetMem(P,Size);
getImage(0,0,30,30,P^);
cleardevice;
Y:=((MaxY Div 2)-60);
For X:=1 To 5 Do
 Begin
  Line(0,Y,MaxX,Y);
  Y:=Y+30;
 End;
Randomize;
Repeat
X:=Random(11)+1;
  PutImage(320,(NotePos[X]-15),P^,ORPut);
  Repeat
   Key:=Char(CallUnit.KeyReturn);
  Until Key=Note[X];
  Beep;
  PutImage(320,(NotePos[X]-15),P^,XOrPut);
  If (X/2)=(X Div 2) Then
    Line(290,NotePos[x],350,NotePos[x])
    Else
     If X>1 Then
       Line(290,NotePos[x-1],350,NotePos[x-1]);
Until 3=2;
End.

The important part is the SIZE=.. Use that line to create a varbible
buig enough to hold the image.
