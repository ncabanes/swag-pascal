(*
  Category: SWAG Title: COMMUNICATIONS/INT14 ROUTINES
  Original name: 0077.PAS
  Description: Term program for turbo
  Author: IRA GARDINER
  Date: 02-28-95  10:09
*)

{
Heres a simple term program....  no frills except that it writes to dos's
putchar so that it supports ANSI!....     Public domain!

can anybody tell me how to change the speed of a COM port?

{----------------------CUT-----------------------------}
{Simple com program by Ira Gardiner....  all from scratch!}
uses crt;

Const
  { (1=$03F8 2=$02F8 3=$03E8 4=$02E8 }
  Com = $2f8; {base address of com port 2}

Procedure Write(w : char);  {Quick and dirty write to Dos's FAST PUTCHAR}
begin                       {It only writes one char though! that's all it's}
                            {supposed to!}
 asm
  mov al, w;
  int $29
 end;
end;

var
 c : char;
 done : boolean;

begin
  done := false;
  repeat
   if keypressed then
       begin
          c := readkey;
          if c = #27 then done := true;  {if you press ESC it quits!}
          port[com] := ord(c);
       end;
   if  97 = port[com+5] then write(char(port[com]));
  until done = true;
end.

