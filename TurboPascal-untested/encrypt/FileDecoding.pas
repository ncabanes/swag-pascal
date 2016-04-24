(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0022.PAS
  Description: File decoding
  Author: OZZ NIXON
  Date: 11-22-95  13:25
*)


uses
   crt,
   dos;

var
  key:string[8];

{ decode file ---------------------------------------------------------------}
{your code here}
procedure decode(infname:pathstr);
var
  infile,outfile:file;
  fdir:dirstr; fname:namestr; fext:extstr;
  dbuf,sbuf:pointer;
  idx,i,j,srcseg,srcofs,dstseg,dstofs,start,csize:word;
  src,rep:byte;
begin
  if maxavail<2*65500 then Begin
     Writeln(#13#10,'No Memory');
     halt;
  End;
  getmem(dbuf,65500);
  getmem(sbuf,65500);
  srcseg:=seg(sbuf^); srcofs:=ofs(sbuf^);
  dstseg:=seg(dbuf^); dstofs:=ofs(dbuf^); start:=dstofs;
  assign(infile,infname);
  {$i-} reset(infile,1); {$i+}
  if ioresult<>0 then Begin
     Writeln(#13#10'File I/O!');
     halt;
  End;
  if filesize(infile)>65500 then halt;
  blockread(infile,sbuf^,filesize(infile));
  csize:=filesize(infile);
  close(infile);
  randseed:=ord(key[length(key)]); j:=0;
  for i:=0 to csize do begin
    mem[srcseg:srcofs+i]:=mem[srcseg:srcofs+i] xor
(ord(key[j])+random(ord(key[j])));
    j:=1+j mod 8;
  end;
  idx:=0;
  while idx<csize do begin
    src:=mem[srcseg:srcofs+idx];
    if (src and $f0)=$f0 then begin
      rep:=src and $f;
      src:=mem[srcseg:srcofs+idx+1];
      fillchar(mem[dstseg:dstofs],rep,src);
      inc(dstofs,rep);
      inc(idx,2);
    end
    else begin
      mem[dstseg:dstofs]:=src;
      inc(dstofs);
      inc(idx);
    end;
  end;
  csize:=dstofs-start;
  fsplit(infname,fdir,fname,fext);
  assign(outfile,fdir+fname+'.org');
  {$i-} reset(outfile,1); {$i+}
  {$i-} seek(outfile,FileSize(outfile)); {$i+} {append to 1 long output!}
  if ioresult<>0 then Begin
     Writeln(#13#10'Output Error!');
     halt(4);
  End;
  blockwrite(outfile,key[1],length(key)); {so I know which key did it!}
  blockwrite(outfile,dbuf^,csize);        {un encoded}
  close(outfile);
  freemem(sbuf,65500);
  freemem(dbuf,65500);
end;

{ main ----------------------------------------------------------------------}

Procedure ShowFile(FName:String); {just a test ... not used in live version!}
Var
   T:Text;
   S:String;

Begin
   Assign(T,FName);
   ReSet(T);
   While not eof(t) do begin
{$I-}      Readln(t,s); {$I+}
      Writeln(s);
   End;
   Close(T);
End;

Var
   Cnt1:Integer;        {character 1}
   Cnt2:Integer;        {2}
   Cnt3:Integer;        {3}
   Cnt4:Integer;        {4}
   Cnt5:Integer;        {5}
   Cnt6:Integer;        {6}
   Cnt7:Integer;        {7}
   Cnt8:Integer;        {8}
   Ch:Char;             {did I press a local key?}
   outfile:file;        {just for making an empty file to append to}
   Dumb:Byte;           {dumb!}
   done:boolean;        {tried from '' to #255#255#255#255#255#255#255#255}

begin
   assign(outfile,'hack.org');
   {$i-} rewrite(outfile,1); {$i+}
   Close(outfile); {made a 0 byte file to append to}
{init}
   Cnt1:=0;
   Cnt2:=0;
   Cnt3:=0;
   Cnt4:=0;
   Cnt5:=0;
   Cnt6:=0;
   Cnt7:=0;
   Cnt8:=0;
   done:=false;
   While not done do begin
{not I inc 1 char at a time}
      Inc(Cnt1);
      If Cnt1>255 then Begin
  Cnt1:=0;
  Inc(Cnt2);
      End;
      If Cnt2>255 then Begin
  Cnt2:=0;
  Inc(Cnt3);
      End;
      If Cnt3>255 then Begin
  Cnt3:=0;
  Inc(Cnt4);
      End;
      If Cnt4>255 then Begin
  Cnt4:=0;
  Inc(Cnt5);
      End;
      If Cnt5>255 then Begin
  Cnt5:=0;
  Inc(Cnt6);
      End;
      If Cnt6>255 then Begin
  Cnt6:=0;
  Inc(Cnt7);
      End;
      If Cnt7>255 then Begin
  Cnt7:=0;
  Inc(Cnt8);
      End;
      If Cnt8>255 then Halt;
      Key:='';
      If Cnt1<>0 then key:=key+chr(cnt1);
      If Cnt2<>0 then key:=key+chr(cnt2);
      If Cnt3<>0 then key:=key+chr(cnt3);
      If Cnt4<>0 then key:=key+chr(cnt4);
      If Cnt5<>0 then key:=key+chr(cnt5);
      If Cnt6<>0 then key:=key+chr(cnt6);
      If Cnt7<>0 then key:=key+chr(cnt7);
      If Cnt8<>0 then key:=key+chr(cnt8);
{call your decode method}
      Decode('HACK.DAT');
      {ShowFile('HACK.ORG');}
{so I can see its running:}
      Writeln('KEY: ',Key);
      If Keypressed then Begin
  Ch:=Readkey;
  if ch=#27 then halt;
      End;
   End;
(*  if (paramcount<>2) or (pos('?',paramstr(1))>0) then begin
    writeln('Syntax: DECODE <filename> <key>');
    writeln('Both parameters are required!');
    halt;
  end;
  key:=paramstr(2);
  decode(paramstr(1));
  writeln('File successfully decoded!'); *)
end.

