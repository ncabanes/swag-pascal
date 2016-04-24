(*
  Category: SWAG Title: SCREEN HANDLING ROUTINES
  Original name: 0002.PAS
  Description: CLRSCR2.PAS
  Author: SWAG SUPPORT TEAM
  Date: 05-28-93  13:56
*)

{
>How do you Write a clear screen Procedure in standard pascal for
>the vax system?  I talking about a nice clear screen prgm that does't
>scroll everything off the screen.  Something that works in a flash..
}

Const
  clear_screen = CHR(27) + CHR(91) + CHR(50) +CHR(74);

begin
  Write(clear_screen);
  readln;
end.
