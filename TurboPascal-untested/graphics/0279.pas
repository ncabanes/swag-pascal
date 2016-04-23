{If you have any questions please send me mail at OleRom@hotmail.com}
Program DemoDemo;
Uses Graph, Crt;
Procedure Demo;
Var X, Y : Word;
    Bx, By : Boolean;
    eX, eY : Word;
    eBx, eBy : Boolean;
Begin
 ClearDevice;
 X := 1;
 Y := 1;
 eX := 218;
 eY := 198;
 Bx := True;
 eBx := True;
 By := True;
 eBy := True;
Repeat
 If Bx then Inc(X) else Dec(X);
 If By then Inc(Y) else Dec(Y);
 If eBx then Inc(eX) else Dec(eX);
 If eBy then Inc(eY) else Dec(eY);
 if X <= 0 then bx := True;
 if X >= GetMaxX then bx := False;
 if eX <= 0 then ebx := True;
 if eX >= GetMaxX then ebx := False;
 if Y <= 0 then bY := True;
 if Y >= GetMaxY then bY := False;
 if eY <= 0 then ebY := True;
 if eY >= GetMaxY then ebY := False;
 SetColor(70);
 ClearDevice;
 Line(X,Y,eX,eY);
Until KEyPressed;
End;
Var D : Integer;
Begin
 D := 0;
 initgraph(D,D,'');
 ClearDevice;
 Demo;
 CloseGraph;
End.