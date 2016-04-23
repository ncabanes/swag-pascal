(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Triangles in triangle - norekusion         │
   └───────────────────────────────────────────────────────────┘ *)

{
   Well this is nice effekt, but ... . If you know rekpic19.pas then
 you show only two variables part. Rotation and items (2..x) in case.
 Here modify only vlavo(90); to vlavo(120) and x=3. If you want to
 show it in this position you muth rotate turtle in init absolute
 alge -30. (The triangle have angles = 60   |30| = 90 -60. The triangle
 draw left then is -. If you don't undestand then give in init angle 0
 and write vlavo(30); It is equivalent. Good is to change 2/5 to higher
 (but smaller then 1/2). For example 4/9 ... .
}

uses oKor, oStack_b;
type MyKor=object(Kor)
           Procedure Triangle(n:integer; a:real);
           End;

procedure MyKor.Triangle(n:integer; a:real);
var v:integer;
    s:Stack;
begin
  with s do
    begin
      init;
      push(1,n,a);
      while not empty do
        begin
          pop(v,n,a);
          case v of
            1:     if n=0 then
                   else
                     begin
                       Dopredu(a); Vlavo(120);
                       push(2,n,a);
                       push(1,n-1,2*a/5);
                     end;
            2,3: begin
                     Dopredu(a); Vlavo(120);
                     if v<3 then push(v+1,n,a);
                     push(1,n-1,2*a/5);
                   end;
          end {case}
        end {while}
    end {with}
end;

var k:MyKor;

begin

  with k do Begin
      Init(200,-230,-30);
      Triangle(6,500);
      PresunXY(-300,230); Pis('Squards level 6 - Norekusion');
      CakajKlaves;
      Koniec;
            End

End.
