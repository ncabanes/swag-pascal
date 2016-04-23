(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : General version of n-angles - norekusion   │
   └───────────────────────────────────────────────────────────┘ *)

{
   Well, if you will study rekpic21.pas and rekpic19.pas then is easy to
  make it general.
  The angle is 360/Level
  Item to case : 1 and 2..L
  And angle for rotation is : 90-360/Level
  (Angle is : 90 - angle of angle in peak of n-angle)
}

uses oKor, oStack_b;

Const Level=5;

type MyKor=object(Kor)
           Procedure N_angle(n:integer; a:real);
           End;

procedure MyKor.N_angle(n:integer; a:real);
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
                       Dopredu(a); Vlavo(360/Level);
                       push(2,n,a);
                       push(1,n-1,a/3);
                     end;
            2..Level: begin
                     Dopredu(a); Vlavo(360/Level);
                     if v<Level then push(v+1,n,a);
                     push(1,n-1,a/3);
                   end;
          end {case}
        end {while}
    end {with}
end;

var k:MyKor;

Begin

  With k do
    Begin
      Init(200,-200,90-360/Level);
      N_angle(4,250);
      PresunXY(-300,230); Pis('N-angle level 4 - Norekusion');
      CakajKlaves;
      Koniec;
    End

End.
