(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Shnee flake drawed with recusion           │
   └───────────────────────────────────────────────────────────┘ *)

{    This program draw shneeflake with rekusive from first level to
  nine. If is level higher then 9 then time for work is very large.
  It is worked in turtle graphic. (Unit Okor, static metods) Principe
  drowing : There are tree parts :
     In first part draw 1/3 of picture. Then turtle rotate 120 degrees
  right. When is first part working then are realising all rekusions.
  If you don't undestand it, then is better in MojaKor.flake in cycle
  give parameter 1 to 1, then just draw only 1/3 of picture.
     In part two (primitive case (level rekusion =1) is drawing only
  one line. (dopredu, lenght s is from input)
       In higher level how one draw -/\- (in correct rotation) in line
  one rekusive later. (for example : last level : ---- and at the present
  is -/\-. For next level - is how ---- there. The lenght there is s/3.
  Why s/3 ? Equilateral triangle is first s/3 and two lines are --. (how in
  picture -/\-) Consenguently all of lines (in picture muth have s in last
  level of rekusion. For level 1 : s=input For
                         level 2 : s=s/3

  In triangle are only two parts drawed, but one is part of line last level.
  For example :   s     /\
                ---- = - - - s/3      3 * s/3 = s
                    s/3  I
                        s/3
  }

Uses oKor,crt;

Type MyKor=object(Kor)
               Procedure Flake(n:integer; s:real);
               Procedure Flake_pom(n:integer; s:real);
             End;

Procedure MyKor.Flake(n:integer; s:real);
Var i:integer;
Begin
  For i:=1 to 3 do Begin
                   ZmenFP(i);   {If you don't wand colors Clr this line}
                   Flake_pom(n,s);
                   Vpravo(120);
                   End;
End;

Procedure MyKor.Flake_pom(n:integer; s:real);
Begin
  if n=1 then Dopredu(s)
  else
    Begin
      Flake_pom(n-1,s/3);
      Vlavo(60);
      Flake_pom(n-1,s/3);
      Vpravo(120);
      Flake_pom(n-1,s/3);
      Vlavo(60);
      Flake_pom(n-1,s/3);
    End
End;

Var k:MyKor;
    i:integer;

Begin
  With k do Begin
    For i:=1 to 9 do
      Begin
        Init(-100,-200,0);
        If ukazana=true then write(#7);
        Flake(i,400);
        PresunXY(-300,230); Pis('Snee flake of level '+chr(i+48));
        CakajKlaves;
        Zmaz1;
      End;
             Koniec;
             End;
End.
