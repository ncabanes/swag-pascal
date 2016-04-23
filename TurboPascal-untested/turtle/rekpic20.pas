(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Squards in squard - rekusion version       │
   └───────────────────────────────────────────────────────────┘ *)

{
    This program draw popular squards effekt. It is typical rekusive
  algorithm.
  Part 1 : Primitive part : Nathing
  Part 2 : This is one part of rekusion, who work something. There is
  only cycle for (parameters : 1 to 4) and some commands. One par of
  commands (dopredu(s); and vlavo(90);) draw line and rotate turtle
  for drawing other line. The cycle draw the squard.  And there is
  a rekusion command. It is easy to undestand, but ... .
  If you are in cycle (i have 2) and you are penetrate then i muth
  have 1 not 2. Ohohoh!
  If you thing all colors go periodicly then it is bed. For examplr :
  N=2 go : 1 1 2 3 4 2 1 2 3 4 3 1 2 3 4 4 1 2 3 4,
  One is when the rekusion penetrate to smallest direction of squard
  two,tree is when the rekusion make middle two directions of squard
  four is when the rekusion escape drawed part of sqaurds
  So it is rekusion type for example snee flake. In penetrate part are
  a lot rekusion commands. Here are all rekusion commands only ONE
  command !!! (Squard(n-1,s/2.5);)  If rekusion finish the penetrate
  (for i>1) then go emerge part where rekusion work nathing, but
  go other penetrate. Zmenfp change the color. This reksion is good
  to write in rekusion version outside. It is not so difficult for
  all who good undestand this. This make rekusion. Easy writed, but
  difficult realization.

  If you want to have the effekt in one color, please change i in
  Zmenfp to constant.
  Part 3 : Emerge part    : Nathing
}

Uses Okor;

Type Mykor=Object(kor)
             Procedure Squard(n:integer;s:real);
             End;

  procedure Mykor.Squard(n:integer;s:real);
  var
    i:integer;
  begin
    if n=0 then
    else for i:=1 to 4 do
    begin
      Zmenfp(i);
      dopredu(s);
      vlavo(90);
      Squard(n-1,s/2.5);
    end;
  end;

  Var k:Mykor;
  Begin

  With k do Begin
            Init(240,-240,0);
            Squard(6,480);
            CakajKlaves;
            Koniec;
            End;

  End.
