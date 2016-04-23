
uses
    crt;
type
    exehead=array[1..32]of byte;
const
    exeheader:exehead=($4D,$5A,$00,$00,$12,$00,$00,$00,$02,$00,$D7,$0D,$FF,$FF
    ,$F0,$FF,$FE,$FF,$00,$00,$00,$01,$F0,$FF,$1C,$00,$00,$44,$6f,$74,$61,$6e);
     var
   buf:array[1..4096]of byte;
   f,f1:file;
   size,i,j:word;
   s,s1:string[12];
   w:byte;
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
     writeln('COM TO EXE, (C) Copyright DOTAN BARAK, 1995. ver 1.0');
     writeln('Convert COM file to an EXE file.');
     writeln;
     writeln;
     textattr:=lightgray;
     if paramcount=0 then
     begin
          writeln('usage: COM2EXE  source [target]');
          writeln;
          halt(1);
     end;
     s:=paramstr(1);
     if not fileexists(s) then
     begin
          writeln('FILE NOT FOUND !');
          halt(1)
     end;
     for w:=1 to length(s) do
      s[w]:=upcase(s[w]);
     s1:=s;
     assign(f,s);
     reset(f,1);
     size:=filesize(f)+32;
     if paramcount=2 then
     begin
          s:=paramstr(2);
          for w:=1 to length(s) do
           s[w]:=upcase(s[w]);
     end
     else
     begin
          w:=(pos('.',s));
          inc(w);
          delete(s,w,length(s)-w+1);
          insert('EXE',s,w);
     end;
     assign(f1,s);
     rewrite(f1,1);
     exeheader[3]:=(size mod 512);
     exeheader[5]:=(size div 512)+1;
     blockwrite(f1,exeheader,32);
     repeat
           blockread(f,buf,4096,i);
           blockwrite(f1,buf,i,j);
     until (i<>4096) or (j<>i);
     close(f);
     close(f1);
     writeln('Converting ',s1,' to ',s,'.');
end.