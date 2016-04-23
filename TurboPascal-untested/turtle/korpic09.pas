(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Flower with turtle                         │
   └───────────────────────────────────────────────────────────┘ *)

{
     This program is easy to undestand. Draw flower. This program
 draw all petels. (input n=7) Draw the petal from korpic08.pas.
 All petels are rotated in 360/n degress. (korpic07.pas)
 And draw other petal in other color.
}

uses  okor;

Type Mykor=object(kor)
           Procedure poly(n:integer;s,u:real);
           Procedure Part_Circle(n:integer;s:real);
           Procedure petal(n:integer;s:real);
           Procedure flower(n:integer;s,u:real;p:integer);
           End;

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

  Procedure Mykor.Part_circle(n:integer;s:real);
  Begin
    poly(n,s,90/n);
  End;

  Procedure Mykor.petal(n:integer;s:real);
  Begin
    Part_circle(n,s);
    vpravo(90);
    Part_circle(n,s);
    vpravo(90);
  End;

  Procedure Mykor.flower(n:integer;s,u:real;p:integer);
  Begin
    While p>0 do Begin
                 Inc(color);
                 ZmenFp(color);
                 petal(n,s);
                 Vpravo(u);
                 Dec(p);
                 End;
  End;

Var i:integer;

Begin

  k.init(0,0,0);
  k.flower(100,2.5,360/7,7);
  cakajklaves;
  k.koniec;

End.
