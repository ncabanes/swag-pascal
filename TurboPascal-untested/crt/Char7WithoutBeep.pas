(*
  Category: SWAG Title: CRT ROUTINES
  Original name: 0032.PAS
  Description: Char #7 without beep
  Author: PEDRO CORREIA
  Date: 11-22-95  13:29
*)


 KF> Is there a way that I can display Char #7 on the screen without the
 KF> beep? I'm trying to create an ASCII chart to go with a text font editor
 KF> I've written, but this character (and one or two others) keep me from
 KF> being able to display all 256 ASCII symbols. Please help...

 simple!

  mem[$b800:X*2+Y*160]:=7;
  mem[$b800:x*2+Y*160+1]:=attribute;

