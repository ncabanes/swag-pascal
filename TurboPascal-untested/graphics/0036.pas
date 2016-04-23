{
VINCE LAURENT

I wrote some code to draw a scalable hex field on the screen. Can
anyone give me a hand in optimizing it? There is a lot of redundant
line drawing and positioning... I would also like to be able to have
a fexible amount of hexigons showing.  For example, if the scale is,
say 40, show 19 hexs, if it is smaller, show more (like as many that
could have fit in the area occupied by 19).

BTW, this code can be freely used and distributed or completely ignored :-) }

Program HexzOnScreen;
Uses
  Graph, Crt;
Type
  PtArray = Array [1..6, 1..2] of Real;
Var
  s1, s2,
  side,
  i, j,
  Gd, Gm  : Integer;
  Pts     : PtArray;
  ErrCode : Integer;
  Sqrt3,
  sts     : Real;

begin
  Sqrt3 := Sqrt(3);
  Side  := 40;             { initial hex side length ( min = 8 ) }
  sts   := Side * Sqrt3;
  s1    := 200;
  s2    := 60;     { starting point For hex field }
  InitGraph(Gd, Gm, 'e:\bp\bgi\');
  ErrCode := GraphResult;
  if not ErrCode = grOk then
  begin
    Writeln('Error: ', GraphErrorMsg(ErrCode));
    Halt(0);
  end;
  SetColor(LightGray);
  Delay(10);   { give the screen a chance to toggle to Graph mode }
  For j := 1 to 17 DO
  begin
    Pts[1, 1] := s1;
    Pts[1, 2] := s2;
    Pts[2, 1] := Pts[1, 1] - side;
    Pts[2, 2] := Pts[1, 2];
    Pts[3, 1] := Pts[1, 1] - side - (side / 2);
    Pts[3, 2] := Pts[1, 2] + (sts / 2);
    Pts[4, 1] := Pts[1, 1] - side;
    Pts[4, 2] := Pts[1, 2] + sts ;
    Pts[5, 1] := Pts[1, 1];
    Pts[5, 2] := Pts[4, 2];
    Pts[6, 1] := Pts[1, 1] + (side / 2);
    Pts[6, 2] := Pts[1, 2] + (sts  / 2);
    For I := 1 to 6 DO
    begin
      if i <> 6 then
        Line(Round(Pts[i, 1]),  Round(Pts[i, 2]),
             Round(Pts[i + 1, 1]), Round(Pts[i + 1, 2]))
      else
        Line(Round(Pts[i, 1]), Round(Pts[i, 2]),
             Round(Pts[1, 1]), Round(Pts[1, 2]));
    end;
    Case j OF
      1..2 :
      begin
        s1 := Round(Pts[6, 1] + side);
        s2 := Round(Pts[6, 2]);
      end;
      3..4 :
      begin
        s1 := Round(Pts[5, 1]);
        s2 := Round(Pts[5, 2]);
      end;
      5..6 :
      begin
        s1 := Round(Pts[3, 1]);
        s2 := Round(Pts[3, 2]);
      end;
      7..8 :
      begin
        s1 := Round(Pts[3, 1]);
        s2 := Round(Pts[3, 2] - sts);
      end;
      9..10 :
      begin
        s1 := Round(Pts[1, 1]);
        s2 := Round(Pts[1, 2] - sts);
      end;
      11 :
      begin
        s1 := Round(Pts[6, 1] + side);
        s2 := Round(Pts[6, 2] - sts);
      end;
      12..13 :
      begin
        s1 := Round(Pts[6, 1] + side);
        s2 := Round(Pts[6, 2]);
      end;
      14 :
      begin
        s1 := Round(Pts[5, 1]);
        s2 := Round(Pts[5, 2]);
      end;
      15 :
      begin
        s1 := Round(Pts[3, 1]);
        s2 := Round(Pts[3, 2]);
      end;
      16 :
      begin
        s1 := Round(Pts[3, 1]);
        s2 := Round(Pts[3, 2] - sts);
      end;
    end;
  end;
  Line(s1, s2, Round(s1 + (side / 2)), Round(s2 - sts / 2));
  Readln;
  CloseGraph;
end.
