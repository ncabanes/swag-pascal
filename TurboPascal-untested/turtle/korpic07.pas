(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Turtle rotations with objects              │
   └───────────────────────────────────────────────────────────┘ *)

{
    This program is very easy to undestand. Just rotate trivial
  object in input angle. This program is reaction for usualy
  mistakes. The rotation angle muth not be in cycle !
  Correkt version is if you in program don't have (* *), but
  it is not sympatic and useful. (Usualy the programers make
  there mistakes) If you want the rotation, please define the
  angle in init or use ABSOLUTE angle!
}

uses okor;

type
  mkor=object(kor)
    Procedure poly(n:integer;s,u:real);
  end;

var
  k:mkor;
  Color,i,j:integer;

  procedure mkor.poly(n:integer;s,u:real);
  begin
    while n>0 do
    begin
      dopredu(s);
      vpravo(u);
      dec(n);
    end;
  end;

begin
  Color:=1;

With k do Begin
  init(-150,0,0);

  For i:=1 to 3 do Begin     (*
                   Vpravo(90); *)
                   ZmenFp(Color);
                   Poly(60,2,1);
                   Vpravo(120);
                   Poly(60,2,1);  (*
                   Vlavo(90);      *)
                   End;

          Cakajklaves;
          Koniec;
          End;

end.
