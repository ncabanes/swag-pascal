(*
  Category: SWAG Title: KEYBOARD I/O ROUTINES
  Original name: 0086.PAS
  Description: Stuffing Keyboard
  Author: KEV1N@AOL.COM
  Date: 08-25-94  09:12
*)

{
> How do I stuff a string into the keyboard buffer?

I've got two things for you:

1:  Turbo Power's Object Professional's OpCRT unit has the following
useful routines:
procedure StuffKey(W : Word);
  {-Stuff one key into the keyboard buffer}

procedure StuffString(S : string);
  {-Stuff the contents of S into the keyboard buffer}

{
2: If you don't have Object Professional (it's $895.00 but worth it)
Before I noticed that OpCRT would do what I needed, I sat down and
wrote the following code.  It's rough, but gives a pretty good idea
of how the keyboard buffer works, and there's a chance that you can
use it to create your own Stuffer
}
program ViewKbdBufr;

(********************************************************************
***
   Written By Kevin R. Pierce - June 25, 1994
*********************************************************************
**)

Uses
  OpString,  {This is where HexB is.  You can write your own easy
enough}
  CRT;

var
  Buffer_Head : Byte absolute $0040:$001A;
  Buffer_Tail : Byte absolute $0040:$001C;
  Buffer_Start: Byte absolute $0040:$0080;
  Buffer_End  : Byte absolute $0040:$0082;

  var
    t : byte;

begin
  clrscr;
  repeat
    gotoxy(1,1);
    writeln('Buffer Head  = ',HexB(Buffer_Head));
    writeln('Buffer Tail  = ',HexB(Buffer_Tail));
    writeln('Buffer Start = ',HexB(Buffer_Start));
    writeln('Buffer End   = ',HexB(Buffer_End));
    writeln;
    if Buffer_Tail >Buffer_Head then {simple list}
      begin
        for t:=Buffer_Head to Buffer_Tail do
          write(Byte(Ptr(Seg0040,t)^):4);
      end
     else  {loop back to START}
      if Buffer_Head<>Buffer_Tail then
        begin
          for t:=Buffer_Head to Buffer_End do
            write(Byte(Ptr(Seg0040,t)^):4);
          for t:=Buffer_Start to Buffer_Tail do
            write(Byte(Ptr(Seg0040,t)^):4);
        end;
    clreol;
    writeln;
    writeln(Byte(Ptr(Seg0040,Buffer_Head)^):3);
    writeln(Byte(Ptr(Seg0040,Buffer_Tail)^):3);
    writeln(Byte(Ptr(Seg0040,Buffer_Start)^):3);
    writeln(Byte(Ptr(Seg0040,Buffer_End)^):3);

    writeln;
    for t:=ofs(Buffer_Head) to ofs(Buffer_Tail) do
      write(Byte(Ptr(seg(Buffer_Head),t)^):3);

  until FALSE;
{endless Loop - Use Ctrl-Break to stop (you might have to reboot if
you run BP under Windows.}

end.

