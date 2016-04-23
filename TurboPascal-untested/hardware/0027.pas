
{  Anyone have any idea why this won't disable PrtScr? }

uses
  crt,dos;

var
  i : word;
  old_status : byte;
  prt_status : byte absolute $0040:$0100; { PrtScr status byte }

begin
  old_status:= prt_status;
  prt_status:= 1;
  for i:= 1 to 20 do writeln(' This is line ',i);
  writeln;
  writeln('Press PrtScr to test, any other key to exit');
  readkey;
  prt_status:= old_status;
end.
