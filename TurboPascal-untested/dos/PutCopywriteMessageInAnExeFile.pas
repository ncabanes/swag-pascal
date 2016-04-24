(*
  Category: SWAG Title: DOS & ENVIRONMENT ROUTINES
  Original name: 0117.PAS
  Description: Put copywrite message in an EXE file
  Author: DOTAN BARAK
  Date: 08-30-97  10:09
*)

uses
    crt;
type
    EXEHEAD=record
     ID:array [1..2]of char;
     LASTPAGE:word;
     PAGES:word;
     RELOCATION:word;
     HEADERSIZE:word;
     MIN:word;
     MAX:word;
     OFFSET:word;
     SP:word;
     CHECKSUM:word;
     IP:word;
     CS:word;
     FIRST:WORD;
     OVERLAY:WORD;
    end;
var
   exe:exehead;
   f,f1,f2:file;
   s:string[12];
   w:byte;
   buf:array[1..4096]of byte;
   i,j:word;
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
     writeln('MARKEXE, (C) Copyright DOTAN BARAK, 1997. ver 1.0');
     writeln('Put copywrite message in an EXE file.');
     writeln;
     writeln;
     textattr:=lightgray;
     if paramcount<2 then
     begin
          writeln('usage: MARKEXE  [exefile]  [textfile]');
          writeln;
          halt(1);
     end;
     s:=paramstr(1);
     if not fileexists(s) then
     begin
          writeln('THE FILE ',s, ' NOT FOUND !');
          halt(1)
     end;
     if not fileexists(paramstr(2)) then
     begin
          writeln('THE FILE ',paramstr(2), ' NOT FOUND !');
          halt(1)
     end;
     for w:=1 to length(s) do
      s[w]:=upcase(s[w]);
     assign(f,paramstr(1));
     reset(f,1);
     blockread(f,exe,sizeof(exe));
     if (exe.id<>'MZ') then
      if (exe.id<>'ZM') then
     begin
          close(f);
          writeln('The file ',s,' is not an EXE file.');
          halt(255);
     end;
     assign(f1,paramstr(2));
     reset(f1,1);
     assign(f2,'MARKEXE.$$$');
     rewrite(f2,1);
     seek(f,0);
     blockread(f,buf,exe.headersize*16,i);
     blockwrite(f2,buf,i);
     repeat
           blockread(f1,buf,4096,i);
           blockwrite(f2,buf,i,j);
     until (i<>4096) or (i<>j);
     j:=filesize(f2) div 16;
     i:=filesize(f2) mod 16;
     if i<>0 then
     begin
          exe.headersize:=j+1;
          fillchar(buf,16,0);
          blockwrite(f2,buf,16-i);
     end
     else
          exe.headersize:=j;
     repeat
           blockread(f,buf,4096,i);
           blockwrite(f2,buf,i,j);
     until (i<>4096) or (i<>j);
     i:=filesize(f2);
     exe.lastpage:=i mod 512;
     exe.pages:=(i div 512)+1;
     seek(f2,0);
     blockwrite(f2,exe,sizeof(exe));
     close(f);
     erase(f);
     close(f1);
     close(f2);
     assign(f,'MARKEXE.$$$');
     rename(f,s);
     writeln(' The file ',s,' was marked .');
end.

