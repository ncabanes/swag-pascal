(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Gen. rek. v. for n-angle in circle effekt  │
   └───────────────────────────────────────────────────────────┘ *)

{ This program draw the n-angle (regular) in circle ... .
  This program modify rekpic15.pas. This program is not easy to
  undestand if you do not undestand trigoniometry (mathematic)
  and rekpic15.pas. This program draw this effekt in rekusion
  version.

  After initialization we muth move the turtle in correkt position.
  The point (0,0) is a central point for all circles and n-angles.
  We muth to have absolute move !!! Not vlavo or vpravo !!!
  Then the program work rekusion.

  Part one : (Primitive part) Nathing
  Part two : Draw 1/2 of direction n-angle. And then ... .
             There is difficult mathematical relation.
             We want to have in relation L. (level)

                      The relation is :  2*L-1        1
                                         ----- = 1- ------
                                          2*L         2*L

             Well, we want only 1/2 of direction => the circle
             muth have peaks of other directions :
             (L-1+1/L)
             The angle (in central of circle) is 180/L.
             All angle in central direcions give 180 degress.
             (in rectangular triangles - see rekpic11.pas)

                               ┌ 2*L-1  ┐
                               │ ------ │ *180
             (L-1+1/2)*180/L   └    2   ┘         2*L-1          1
             --------------- = --------------  = -------- = 1- -----
                  180             180*L            2*L          2*L


             We muth to have correkt d. (lenght for circle)
             We muth working with d for next circle. (s=s/(cos(pi/L))
             And the relation is haw in rekpic11.pas.

             Rotation vlavo (180/Alfa) - deviation from circle drawing.
             (sinus sentence - see rekpic11.pas)
             This is end for penetration.

  Part tree : This deviation is for Pt. (Pt is central point for all
              n-angles and circles)
              Finish the circle. See it in penetration!. Here is just
              1/2L, because this part is for full circle.
              Rotation (180/L-180/n) is rotation for N-angle. See
              rekpic11.pas in metod circle first command.
              Draw n-angle, but with L-1 direction. Finish the half
              direction.

              This is full documentation for this effekt.
  }

Uses okor;

Const L=6;
      Alfa=120;  {Alfa muth mod 2*L !!!}

type
  Mykor=object(kor)
    procedure poly(n:integer;s,u:real);
    procedure Draw(s:real;p:integer);
  end;

Var k:Mykor;
    poc:integer;

procedure Mykor.poly(n:integer;s,u:real);
Begin

  while n>0 do Begin
               Dopredu(s);
               Vpravo(u);
               Dec(n);
               End;

End;

Procedure Mykor.draw(s:real;p:integer);
Begin
if p=0 then
       else Begin
            Inc(poc);
            Zmenfp(poc);
            Dopredu(s/2);
            Vpravo(180/L+180/alfa);
            Poly(round((1-1/(2*L))*alfa),s*sin(pi/alfa)/cos(pi/L)/(sin(pi/L)/cos(pi/L)),360/Alfa);
            Vlavo(180/Alfa);
            Draw(s/cos(pi/L),p-1);
            Inc(poc);
            Zmenfp(poc);
            Vpravo(180/alfa);
            Poly(round(1/(2*L)*alfa),s*sin(pi/alfa)/cos(pi/L)/(sin(pi/L)/cos(pi/L)),360/alfa);
            Vpravo(180/L-180/alfa);
            Poly(L-1,s,360/L);
            Dopredu(s/2);
            End;
End;

begin
poc:=0;

With k do Begin
          init(0,0,0);
          presunxy(0,-80/(sin(pi/L)/cos(pi/L))/2);
          Zmensmer(-90);
          draw(80,7);
          CakajKlaves;
          Koniec;
          End;

End.
