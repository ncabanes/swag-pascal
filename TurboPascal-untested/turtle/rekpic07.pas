(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : general version of squard effect outside   │
   └───────────────────────────────────────────────────────────┘ *)

{ This program is general version of recpic05.pas. This program just
  modify Vlavo(360/l) In Mykor.squard.
}

uses oKor,crt;

Const l=7;

type MyKor=object(Kor)
               Procedure Squard (n:integer; s:real);
               Procedure Squard1(n:integer; s:real);
             end;

procedure MyKor.Squard(n:integer; s:real);
var i:integer;
begin
For i:=1 to l do Begin
                 ZmenFP(i);   {If you don't wand colors Clr this line}
                 Squard1(n,s);
                 Vlavo(360/l);
                 End;
end;

procedure MyKor.Squard1(n:integer; s:real);
begin
  if n=1 then Dopredu(s)
  else
    begin
      Squard1(n-1,s/(6*(l-2)/l));
      Vlavo(360/l);
      Squard1(n-1,s/(6*(l-2)/l));
      Vpravo(360/l);
      Squard1(n-1,s/(6*(l-2)/l));
      Vpravo(360/l);
      Squard1(n-1,s/(6*(l-2)/l));
      Vlavo(360/l);
      Squard1(n-1,s/(6*(l-2)/l));
    end
end;

var k:MyKor;
    i:integer;

begin
  with k do Begin
    For i:=1 to 9 do
      Begin
        Init(0,0,0);
        Squard(i,750/l);
        PresunXY(-300,230); Pis('Snee flake of level '+chr(i+48));
        CakajKlaves;
        Zmaz1;
      End;
            Koniec;
            End;
End.
