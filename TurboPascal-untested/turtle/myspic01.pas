(* ┌───────────────────────────────────────────────────────────┐
   │ Programated by Vladimir Zahoransky                        │
   │                Vladko software                            │
   │ Contact      : zahoran@cezap.ii.fmph.uniba.sk             │
   │ Program tema : Turtle runing the mouse version 1          │
   └───────────────────────────────────────────────────────────┘ *)

{
    Well this is very funy program. Turtle runing the mouse. The principe
  is : 1. Init situation
       2. if we change mouse coordinates then turtle rotate (absolute)
          angle and go there
       3. If turtle is in position with mouse then there blinking.

  How in all programs this sort, there is a problem with blinking. This
  problem is eliminated in myspic02.pas
}

Uses oKor, OkorMys;

Var k:Kor;
    m:Mouse;
Begin
With M Do Begin
  Init;
  Change_Cursor(Kurzor_Ruka);
  With k do
    Begin
      Init(0,-200,0); Ukaz; M.Show;
      Repeat
        StavMysi;
        Hide;
        ZmenSmer(Smerom(MysX-x0,y0-MysY));
        Dopredu(0.1);
        Show;
      Until False;
  End;
  End;

End.
