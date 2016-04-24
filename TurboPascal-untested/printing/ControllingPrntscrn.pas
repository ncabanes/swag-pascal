(*
  Category: SWAG Title: PRINTING/PRINTER MANAGEMENT ROUTINES
  Original name: 0042.PAS
  Description: Controlling PRNTSCRN
  Author: STEVE ROGERS
  Date: 02-28-95  10:04
*)

{
WK>Hello everyone! I am sorta new at Pascal, and have been dabbling around,
  >trying to make a few useful programs.  Right now i am working a program that
  >will generate a calender for a given year and print it out to the screen and
  >printer. I have successfully been able to print it on the screen, but i have
  >no idea how to get it out to the printer! Specifically, in my procedure that
  >prints the calender to the screen, I use GOTOXY to position the dates. This
  >doesn't work with the printer tho. Does anyone have any suggestions? Oh,
  >also, i am using asterics to create boxes around the dates. thanx for any
  >help!

  Well, you could press the PrntScr key after you have your calendar on
  the screen. You can do the same in software:
}
    procedure PrintScreen;
    begin
      asm
        int 5h
      end;
    end;

  If you don't want to print the whole screen, here's a little routine
  that will print lines y1 through y2.

{-----------------------}
procedure prnt_scr(y1,y2 : byte);
var
  c : char;
  regs : registers;
  x,y : byte;

begin
  for y:= y1 to y2 do begin
    for x:= 1 to 80 do with regs do begin
      gotoxy(x,y);
      ah:= 8;
      bh:= 0;
      intr($10,regs);

      (*
      { uncomment to filter high ASCII chars }
      if (al>=127) then
        al:= 32;
      *)

      ah:= 0;
      dx:= 0;
      intr($17,regs);
    end;
    writeln(lst);
  end;
  write(lst,ff);
end;


