(*
  Category: SWAG Title: TSR UTILITIES AND ROUTINES
  Original name: 0021.PAS
  Description: TSR Skeleton
  Author: ROB PERELMAN
  Date: 01-27-94  12:23
*)

{
>Thanks for the procedure. I don't want to use WRITE OR WRITELN cause
>they are slow and used a lot of mem. I copy one from the book but it
>makes the file even bigger!!!

Well, I hope mine worked decently...it just didn't mod the current
cursor position.

>You help certainly clear up something about TSR programming. Like
>why I need to interrupt hooking....but I still don't know how to
>detect hotkey and check to see if the program has been loaded.
>Anyway, I used a skeleton named TSR_TPU.PAS of an unkown author to
>write my TSR and it ran fine though not very good.

Good...I'm glad you understand this.  I don't have TSR_TPU, but I do
have some source that shows how to detect if a TSR is already loaded and
how to unload a TSR.  The hotkey part you can do your self.  You can
put in this program like the one I have below which will tell you what values
to look for in Port[$60] for keypresses.  Just run it, and hit your key combo.
For example, if you wanted ALT-A, you'd run this, and hit ALT-A, and you'd
see it would exit with 30 on the screen.  So in your TSR, you say:
If Port[$60]=30 then...
See?  If you want the uninstall/detect TSR program, please tell me...
}

Program HotKey;

Uses
  Crt, Dos;

Var
  Old : Procedure;

{$F+}
Procedure New; Interrupt;
Begin
  Writeln(Port[$60]);
  InLine($9C);
  Old;
End;
{$F-}

Begin
  GetIntVec($9, @Old);
  SetIntVec($9, @New);
  Repeat Until Keypressed;
End.

