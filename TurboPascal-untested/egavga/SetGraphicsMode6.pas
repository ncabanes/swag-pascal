(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0030.PAS
  Description: Set Graphics Mode #6
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:39
*)

{
Great Thanks Chris. Now For another question, This Function would return
0..63 For the 256 color palette right? Can I also use this For the 16
color VGA & EGA palettes With the exception of it returning a value between
0 and 3? and if you wouldn't mind I could also use another Function that
would tell me what video mode I am in. I am examining a Program that can use
video modes of CGA4 ($04), CGA2 ($06), EGA ($10), VGA ($12) and MCGA ($13)
and it Uses this Procedure to set the video mode:
}

Procedure VideoMode (n: Integer);
begin
        Reg.ah := $00;
        Reg.al := n;
        intr ($10, Reg);
end;

{
With the N being the hex numbers from the above video modes.

Now i know next to nothing about interrupts, and your code looks very similar
to what was done to set each color. Is the way to find out the value of al to
call the interrupt in the same manner as above without specifying a value For
al? Would it return the current al value...... or am I in left field on this
one :)
}
