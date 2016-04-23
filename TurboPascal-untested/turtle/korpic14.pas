(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Honeycomb version 2                        │
   └───────────────────────────────────────────────────────────┘ *)

{
      This version draw Homeycomb in version, where the turtle allways
   draw something. (We have not ph) This is for beginers. Here we draw
   6-angle, 2x angle with s in 6-angle direction = 8x-angle for 6-angle.
   Then rotate turtle in absolute angle = 60. (We want to have it
   parraler with x coordinate.
}

Uses Okor;

Const N=10;

Type MyTurtle=Object(Kor)
              Procedure poly(n:integer;s,u:real);
              Procedure HoneyComb(s:real);
              End;

  Procedure MyTurtle.poly(n:integer;s,u:real);
  Begin
    While n>0 do
    Begin
      dopredu(s);
      vpravo(u);
      dec(n);
    End;
  End;

Procedure MyTurtle.HoneyComb(s:real);
Var i:integer;
Begin
For i:=1 to N do Begin
                 Poly(8,s,60);
                 ZmenSmer(60);
                 End;
End;

Var MT:MyTurtle;
Begin

With MT do Begin
           Init(-250,0,60);
           HoneyComb(30);
           CakajKlaves;
           Koniec;
           End;

End.
