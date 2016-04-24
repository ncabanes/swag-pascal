(*
  Category: SWAG Title: UNIT INFORMATION ROUTINES
  Original name: 0005.PAS
  Description: Show whice version of TP unit
  Author: DOTAN BARAK
  Date: 08-30-97  10:09
*)

program WHATPU_SHOW_WHAT_VERSION_OF_TP_UNIT;
uses
    crt;
var
   f:file;
   s:string[12];
   a:array[1..4]of byte;
   i:byte;
function FILEEXISTS(FILENAME:STRING) : BOOLEAN;
var
   f:file;
begin
     {$I-}
     assign(f,fileName);
     reset(f);
     close(f);
     {$I+}
     FILEEXISTS:=(ioresult=0) and (fileName<>'');
end;

begin
     textattr:=white;
     writeln;
     writeln('The WHATPU, (C) Copyright DOTAN BARAK, 1995. ver 1.0');
     writeln('Check the version of the TURBO PASCAL unit.');
     writeln;
     writeln;
     textattr:=lightgray;
     if paramcount=0 then
     begin
          writeln('usage: WHATPU filename.tpu');
          writeln;
          halt(1);
     end;
     s:=paramstr(1);
     for i:=1 to length(s) do
        s[i]:=upcase(s[i]);
     if (pos('.TPU',s)=0) and (pos('.',S)=0) then
       insert('.TPU',s,length(s)+1);
     for i:=1 to length(s) do
        s[i]:=upcase(s[i]);
     if not fileexists(s) then
     begin
          writeln('THE FILE ',s,' WAS NOT FOUND .');
          writeln;
          halt(2);
     end;
       assign(f,s);
       reset(f,1);
       blockread(f,a,4);
{ T }  if a[1]<>$54 then
       begin
            writeln('FILE IS NOT A TURBO PASCAL UNIT .');
            writeln;
            halt(3);
       end;
       write('UNIT OF TURBO PASCAL VER ');
       case a[4] of
{ 0 }     $30:writeln('4.0 .');
{ 5 }     $35:writeln('5.0 .');
{ 6 }     $36:writeln('5.5 .');
{ 9 }     $39:writeln('6.0 .');
{ Q }     $51:writeln('7.0 REAL MODE .');
          else
            writeln('UNKNOWN .');
       end;
       writeln;
end.
