(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0046.PAS
  Description: Compile all units in DIR
  Author: SUNE MARCHER
  Date: 05-31-96  09:17
*)

{$a+,x-,n-,e-,q-,r-,s-,v-,t-,d-}
uses dos,exec;  { see EXEC.SWG for HEAPMAN to do EXECUTE }

var
  info:searchrec;
  paspth:string;
  de,de2:word;

begin
  writeln('Compiling all pascal files.');
  paspth:=fsearch('BPC.EXE',getenv('PATH'));
  if(paspth='')then
  begin
    writeln('Couldn''t find pascal compiler.');
    halt(1);
  end;
  findfirst('*.pas',$ffff,info);
  if(info.name='')then
  begin
    writeln('No .PAS files found.');
    halt(1);
  end;
  repeat
    de2:=execute(paspth,' '+info.name+' /q /build -$g+ -$r- -$d-');
    write('Compiled ',info.name,'...');
    if(de2=0)then writeln('√')else writeln('%');
    findnext(info);
    de:=doserror;
  until(de<>0);
end.
