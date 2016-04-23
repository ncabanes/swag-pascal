(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Flower with anomals                        │
   └───────────────────────────────────────────────────────────┘ *)

{    This program is very easy to undestand if you know korpic09.pas.
  This program draw flower. It is just anomals. It is so nice (in 16
  colors) and it is how the petals have textures. No. It is so
  modifycation of korpic09.pas. There is only one cykle which draw
  all flowers in correkt size. It is easy for programing but very
  nice. If you know assembler (int 10) update it. You will have
  perfekt effekt. (and fast) It is presentation for fractals and
  use turtle graphic. (If you have ograph then this effekt is
  fast)
}

uses  okor;

type
  Mykor=object(kor)
    procedure poly(n:integer;s,u:real);
    procedure stvrtkruh(n:integer;s:real);
    procedure petal(n:integer;s:real);
    procedure flower(n:integer;s,u:real;p:integer);
  end;

var     k:Mykor;
    color:byte;

  Procedure Mykor.poly(n:integer;s,u:real);
  Begin
    While n>0 do
    Begin
      dopredu(s);
      vpravo(u);
      dec(n);
    End;
  End;

  Procedure Mykor.stvrtkruh(n:integer;s:real);
  Begin
    poly(n,s,90/n);
  End;

  Procedure Mykor.petal(n:integer;s:real);
  Begin
    stvrtkruh(n,s);
    vpravo(90);
    stvrtkruh(n,s);
    vpravo(90);
  End;

  Procedure Mykor.flower(n:integer;s,u:real;p:integer);
  Begin
    While p>0 do Begin
                 Inc(color);
                 ZmenFp(color);
                 petal(n,s);
                 Vpravo(u);
      dec(p);
    End;
  End;

var i:integer;

Begin

  k.init(0,0,0);
  For i:=1 to 130 do
  k.flower(i,1,360/10,10);
  cakajklaves;
  k.koniec;

End.
