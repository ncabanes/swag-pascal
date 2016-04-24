(*
  Category: SWAG Title: WINDOWS & OS2 STUFF
  Original name: 0072.PAS
  Description: Allocating Large Memory In Windows
  Author: SWAG SUPPORT TEAM
  Date: 09-04-95  10:51
*)


uses WinCrt;
Const MaxP = 1024; { allocate about 32M, until 2Mb is left (else GPF)... }
var p: Array[1..MaxP] of PChar;
    size,i: Word;

    function min(x,y: LongInt): Word;
    begin
      if x < y then min := x
               else min := y
    end {min};

var StartMem,StartMax: LongInt;
begin
  i := 0;
  StartMem := MemAvail;
  StartMax := MaxAvail;

  repeat
    Inc(i);
    write(i:5,' ':2,MemAvail:10,' ':2,MaxAvail:10);
    size := min(32768,MaxAvail);
    writeln('---> ',size);
    GetMem(p[i],size);
  until (MaxAvail <= LongInt(2048) * 1024) or (i >= MaxP);

  writeln;
  writeln('Start: ',StartMem:10,' ':4,StartMax:10);
  writeln(' Stop: ',MemAvail:10,' ':4,MaxAvail:10);
  { don't free anything... }
  readln;
end.

