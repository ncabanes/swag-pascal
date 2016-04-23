(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : McCarthy 91 (rekusion) with turtles        │
   └───────────────────────────────────────────────────────────┘ *)

{
    Well, the rekusions are sometimes very difficult. My program have
 a lot of versions.
 Version 1 : Rekusive inside exp. rekpic12.pas, rekpic14, rekpic16...
 Version 2 : Rekusive inside with a lot rekusive commands
             exp. rekpic01.pas ...
 Version 3 : Rekusive inside with one rekusive command but it is
             command for a lot commands. (rekpic20.pas rekpic22.pas ... )
 Version 4 : Rekusive outside flepic05.pas
    If you did study my programs then you know some rekusions which you
  do not undestand. Some are easy writed, but make very difficult.
    Some rekusions we can to update to cycles, but some NO.
 For example this. McCarthy 91. Rekusion is version rekusion of rekusion.
 If we want to study rekusion algorithm we can use stack, (all versions)
 but here is one big problem : All my rekusions (rekpic01..rekpic24) are
 working with graphic. This don't work. Stack for this rekusion is not
 good to use. Here stay a question. Can stack to work with all rekusion
 algorithm. (graphical) Oh,oh. No. This rekusion McCarthy_91 is one
 rekusion where stack ... . Stack we can use IF you can write this
 rekusion WITH cycles. This rekusion we can not to write with cycles.
    Well, this program simulate how can we use turtle graphic in
 rekusions this type. This rekusion is not here to study perfekt,
 because it is very diffycult to undestand. This program is a metod
 how can we simulate this with turtles.
    The metod is : If rekusion penetrate write line with one color
    and when emerge with other color. If it is primitive part then
    with color. All steps are x for ower lines. And the rekusion
    variable is y for lines. Init is a point where the rekusion
    start. Then increment poc. (account variable) If we will make
    it then you see course of rekusion.
}

Uses Okor;

Type Mykor=Object(kor)
           Function McCarthy_91(x:integer):integer;
           End;

Var   poc:byte;

Function Mykor.McCarthy_91(x:integer):integer;
Begin
 write(x:4);
 inc(poc);
 if x > 100 then McCarthy_91:=x-10
  else
    begin
      Zmenfp(5);
      ZmenXY(poc,x);
      McCarthy_91:=McCarthy_91(McCarthy_91(x+11));
      Zmenfp(9);
      ZmenXY(poc,x);
    end;
End;

Var k:Mykor;
    Number:integer;
Begin
Randomize;
Number:=Random(91);
Poc:=0;

With k do Begin
          Init(0,0,0);
          McCarthy_91(Number);
          CakajKlaves;
          Koniec;
          End;

End.
