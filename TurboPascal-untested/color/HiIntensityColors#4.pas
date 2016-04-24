(*
  Category: SWAG Title: TEXT/GRAPHICS COLORS
  Original name: 0010.PAS
  Description: Hi Intensity Colors #4
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:34
*)

{
 I have seen a lot of applications that use highintensity
 background colors in Text mode.  How do they do it??????

if you are using an EGA/VGA adapter then you can try :-
}

Procedure SelectIntensity(Intense:Boolean);
Var
  R : Registers;

begin
  if Intense then
    R.BL := 0
  else
    R.BL := 1;
  R.AX := $1003;
  Intr($10, R);
end;

{
 TextBackGround wont do anything higher than 8 without blinking.
 I want to be able to use colors like Black on Yellow and
 things like that.  Anyone have any ideas???

Now, if you call "SelectIntensity(True)" then you can use high intensity
background colours.  to display, say White On Darkgray, you can use
"White+Darkgray*16" as your Textattr.
}
