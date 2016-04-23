(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Squards in squard - norekusion             │
   └───────────────────────────────────────────────────────────┘ *)

{
     This is very popular effekt to present rekusion. This version
 (how in all programs) is no rekusion version. This program is typycal
 sort of rekusions. To undestatnd a rekusion is not diffycult, but to
 undestand to no rekusion version. The rekusion is easy (writed with
 one trick - rekpic20.pas), but for no rekusion version stay a big
 difficult problem. For N=1 it is bigest squard.  For N=2 it is :

   ┌───┬───┬───┐    And here is a problem. In N=1 it is ONE squard,
   │   │   │   │  but in N=2 are there 4 small squards, for N=3 ... .
   ├───┘   └───┤  This problem is not difficult, if you change this
   │           │  problem for Ostack. (Object stack for turtle graphic)
   ├───┐   ┌───┤  It is very easy for all who undestand Ostack. (statical
   │   │   │   │  and dynamical) We work with v - rekusive variable,
   └───┴───┴───┘  N - level of rekusion and a (s) - it is direction.

 This program (for easy version) is good to work in parts.
 Part1 : vhere is primitive part (nathing)
         and penetrate part
 Part2-4 : emerge of rekusion

 First work : Init stack. (The stack is empty) If we do something then
 push or pop from stack. If we penetrare (for smallest squard) then
 push if emerge then pop. We give to stack v=1 (we are penetrating)
 with input parameters. Then is a cykle. Finish work if is stack
 empty. (work is finished) If we work one course of cycle then we
 pop one data from stack. One case item muth push somedata!
 Well, it is good and what make case ?
 1 : there is penetration - decrementation of n to level 1 in
     momental situation. If you are N squard level (exm. 3) and
     you want to finish this level you muth to draw x-mal squard
     effekt N-1. This part draw lines to level 1. push(2,n,a);
 2..4 : make increment  of v. It finish level from minimalized N from
     part 1.  If v<4 then push(v+1,n,a); This command make v for end
     of N for this squardpart.

          Situation is: We are in N=3 (for example we have level of
     rekusion n=5) Part1 draw situation for 1 squard - (to smallest
     squard) and 2..4 finish all levels from 1 to momental N. (n=3)
     Then begin momental n=4. And work part 1 then 2..4. If we are
     in momental level Nm=N-1 then one don't work because it is
     finished.

     Well, it is full documentation. If you want other information,
     please see rekusion version (rekpic20.pas) or make krokuj:=true
     then you will step program in graphic mode.
 }

uses oKor, oStack_b;

type MyKor=object(Kor)
           Procedure Squard(n:integer; a:real);
           End;

procedure MyKor.Squard(n:integer; a:real);
var v:integer;
    s:Stack;
begin
  with s do
    begin
      init;
      push(1,n,a);
      while not empty do
        begin
          pop(v,n,a);
          case v of
            1:     if n=0 then
                   else
                     begin
                       Dopredu(a); Vlavo(90);
                       push(2,n,a);
                       push(1,n-1,2*a/5);
                     end;
            2,3,4: begin
                     Dopredu(a); Vlavo(90);
                     if v<4 then push(v+1,n,a);
                     push(1,n-1,2*a/5);
                     end;
          end  {case}
        end    {while}
    end        {with}
end;

var k:MyKor;

begin
  with k do
    begin
      Init(200,-200,0);
      Squard(6,400);
      PresunXY(-300,230); Pis('Squards level 6 - Norekusion');
      CakajKlaves;
      Koniec;
    End
End.
