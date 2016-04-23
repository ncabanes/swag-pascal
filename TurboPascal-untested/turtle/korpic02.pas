(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Anomals circle definition - backset        │
   └───────────────────────────────────────────────────────────┘ *)

{ This program is not so easy to undestand if you just run. What does it
  do ?
  If i<27 then draw final effekt - circle
  If i<200 then draw star - but effekt is circle
  if i>200 then it is 'mismatch' - but effekt is circle

  Well, the program simulate a equeue of limit for circle. For high i is
  it not a circle. (mismatch) Is it n-angle. But for i -> 26 is it circle.
  For i<26 it is part of circle. For i=26 is it 'circle'.
  This is one metod how to present a equeue of limit for circle. This
  visual metod and with turtles is very good metod for presentation.
}

Uses Okor;
Var M:Kor;
    i:integer;
Begin

With m do Begin
               Init(0,0,0);
               For i:=1 to 400 do Begin
                                  Vlavo(i);
                                  Dopredu(i);
                                  End;
               CakajKlaves;
               Koniec;
               End;

End.
