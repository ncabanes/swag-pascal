(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Triangles in triangle - rekusion           │
   └───────────────────────────────────────────────────────────┘ *)

{  Well, this is nice effekt. It is easy to undestand if you undestand
  rekpic20.pas. There are only two variables. Parameter of cycle (in
  rekusion and angle. The just modify parameter 1 to 3 and angle 120.
}

Uses Okor;

Type Mykor=Object(kor)
             Procedure Triangle(n:integer;s:real);
             End;

  procedure Mykor.Triangle(n:integer;s:real);
  var
    i:integer;
  begin
    if n=0 then
    else for i:=1 to 3 do
    begin
      Zmenfp(i);
      dopredu(s);
      vlavo(120);
      Triangle(n-1,s/2.5);
    end;
  end;

  Var k:Mykor;
  Begin

  With k do Begin
            Init(240,-240,-30);
            Triangle(6,480);
            CakajKlaves;
            Koniec;
            End;

  End.
