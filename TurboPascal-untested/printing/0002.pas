Uses
  Graph, Crt, kasutils,ljGraph;

Var gd,gm : Integer;
    y0,y1,y2,x1,x2 : Integer;
begin
 egavga_exe;
 gd := detect;
 InitGraph(gd,gm,'');
 setcolor(10);
 line(50,100,431,242);
 setcolor(blue);
 Y0 := 10;
 Y1 := 60;
 Y2 := 110;
 X1 := 10;
 X2 := 50;
 Bar3D(X1, Y0, X2, Y1, 10, topOn);
 Bar3D(X1, Y1, X2, Y2, 10, topoff);
 printpause(False);
 readln;
 closeGraph;
end.