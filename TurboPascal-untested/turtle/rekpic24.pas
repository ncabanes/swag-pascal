(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : General n-angles version rekusion          │
   └───────────────────────────────────────────────────────────┘ *)

{
   Well, if you will study rekpic20.pas and rekpic22.pas then is easy to
  make it general.
  The angle is 360/Level
  Parametre in cycle : 1 to Level
  And angle for rotation is : 90-360/Level
  (Angle is : 90 - angle of angle in peak of n-angle)

}

Uses Okor;

Const Level=5;

Type Mykor=Object(kor)
             Procedure N_angle(n:integer;s:real);
             End;

  procedure Mykor.N_angle(n:integer;s:real);
  var
    i:integer;
  begin
    if n=0 then
    else for i:=1 to Level do
    begin
      Zmenfp(i);
      dopredu(s);
      vlavo(360/Level);
      N_angle(n-1,s/3);
    end;
  end;

  Var k:Mykor;
  Begin

  With k do Begin
            Init(200,-240,90-360/Level);
            N_angle(6,300);
            CakajKlaves;
            Koniec;
            End;

  End.
