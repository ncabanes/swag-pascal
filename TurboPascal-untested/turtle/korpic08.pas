(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : The anomals with treepetal                 │
   └───────────────────────────────────────────────────────────┘ *)

{
   This program present the anomals with treepetal. If you know
 assembler (int 10 ... ), please work with palette (256 colors).
 Here can be very nice effekts. This (assembler) version will be
 in swag in other update. Here is just this version. (with unit
 graph) It is not so fantastic and fast graphic, but demostrate
 this problem. Use Ograph.pas. (It is in swag may 1997) In first
 section isn't.  Then update all turtle units with this unit.
 (ograph.pas)  This effekt made the anomals with real variables.
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
  Color:=3;

With k do Begin
  init(-150,0,30);
  ZmenFP(color);
  For j:=1 to 120 do Begin
  vlavo(1);
  For i:=1 to 3 do Begin
                   Poly(60,2,1);
                   Vpravo(120);
                   Poly(60,2,1);
                   Cakaj(5);
                   End;
                   End;

          Cakajklaves;
          Koniec;
          End;

End.
