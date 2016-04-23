(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Flower sign 1                              │
   └───────────────────────────────────────────────────────────┘ *)

{
      This program draw interesting sign with anomals. The cycle j draw the
   steps of picture. The 4500 is a good parameter - have nice picture. In
   cycle i we draw "tiangles" and then we rotate turtle. This is very
   difficult to undestand. It draw it and we have this sign. For very small
   j it is just point, but for larger it is just this picture. If you
   want good ducumentaion then you muth know the functions with two
   variables. (mathematical functions) If in poly we delete *i then the
   picture draw periodicly how in korpic03.pas.
}

uses okor,crt;
type MyTur = object(kor)
     procedure poly(n:integer;s,u:real);
     end;

procedure MyTur.poly(n:integer;s,u:real);
  begin
    while n>0 do begin
      dopredu(s);
      vpravo(u);
      dec(n);
    end;
  end;

var k:MyTur;
    i,j,o:integer;

begin

  k.init(0,0,0);
  o:=0;

  For j:=1 to 4500 do Begin
                      inc(o);
    for i:=1 to 3 do begin
                     k.poly(3,0.0003*o*i,i);
                     k.vpravo(o);
                     End;
                      End;

  CakajKlaves;
  K.koniec;

end.
