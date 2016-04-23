(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Trees (no petals)                          │
   └───────────────────────────────────────────────────────────┘ *)

{
    This program draw the tree. This program draw it with
  rekusion. Metod tree draw thee which have not petals. This
  program is easy to undestand. (Who know binary tree stuctures
  have not problems !)
  Tree metod : Part 1 : Draw the line. (We muth have (allways) a
                        start point for other work. For example : P
                        (P is a point where is turtle) P-----.
                        We want this part in P. Then drew it :
                        P----> and  <----.
               Part 2 : Draw dopredu. (it draw for first petal)
                        Good is if you run this program and show it.
                        Good is if you look rekpic18.pas. (with petals)
                        Rotate turtle for input angle. (Rotation to petal)
                        Trunk is 0.7 mal of branch. (0.7 is just
                        constant, but usefull) Angle is allways absolute.
                        This is documentation for rekusive command. It is
                        not so difficult. Here just penetrate for first
                        petal. (In tree are not defined but in rekpic18.pas)
               Part 3 : Vlavo(2*u) This is rotation for turtle left. In this
                        part is rekusion emerge! The turtle want to draw
                        left part of tree in penetration of rekusion.
                        Then is other rekusive command. If did you see it
                        then you seen a right part of tree in left part.
                        It is a problem. Ther muth work penetrate part, not
                        emerge. It is not so difficult for realization. If
                        you don't undestand, please see rekpic01.pas.
                        (Snee flake) This problem is good to realize with
                        rekusive type outside. It is for good programers.
                        This secend rekusive command solve problem.
                        Emerge for secend rekusive commands are just
                        finishing the thung. (vlavo(u); dopredu(-s))
                        dopredu(-s) = Vlavo(180); dopredu(s);
}

uses oKor;

type MyKor=object(Kor)
               Procedure Tree(n:integer; s,u:real);
             End;

procedure MyKor.Tree(n:integer; s,u:real);
begin
  if n=1 then
    begin Dopredu(s); Dopredu(-s) end
  else
    begin
      Dopredu(s);
      Vlavo(u);
      Tree(n-1,s*0.7,u);
      Vpravo(2*u);
      Tree(n-1,s*0.7,u);
      Vlavo(u);
      Dopredu(-s);
    end
end;

var k:MyKor;

Begin

  With k do Begin
            Init(0,-220,0);
            Tree(7,120,35);
            CakajKlaves;
            Koniec;
            End;

End.
