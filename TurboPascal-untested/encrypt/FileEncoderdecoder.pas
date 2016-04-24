(*
  Category: SWAG Title: FILE & ENCRYPTION ROUTINES
  Original name: 0024.PAS
  Description: File Encoder/Decoder
  Author: BAS VAN GAALEN
  Date: 11-22-95  13:34
*)


{Here follow the two files to encode and decode files...}

>--- Begin of file ENCODE.PAS

{$v-,x+}

(*
** 'Encode' ASCII textfile to binary mess.
** Written by Bas van Gaalen.
**
** This is suposed to be unhackable...
*)

program _encode; { ENCODE.PAS }

uses
  dos;

var
  key:string[8];

{ encode file ---------------------------------------------------------------}

procedure encode(infname:pathstr);
var
  infile,outfile:file;
  fdir:dirstr; fname:namestr; fext:extstr;
  inbuf,outbuf:pointer;
  fsize:longint;
  srcseg,dstseg,
  srcofs,dstofs,
  nofbytes,idx,start,rep,outsize:word;
  i,src:byte;
begin
  assign(infile,infname);
  {$i-} reset(infile,1); {$i+}
  if ioresult<>0 then halt;
  fsize:=filesize(infile);
  if fsize>65500 then halt;
  getmem(inbuf,fsize);
  blockread(infile,inbuf^,fsize,nofbytes);
  close(infile);
  if nofbytes<>fsize then halt;
  if maxavail<fsize then halt;
  getmem(outbuf,fsize);
  srcseg:=seg(inbuf^); dstseg:=seg(outbuf^);
  srcofs:=ofs(inbuf^); dstofs:=ofs(outbuf^); start:=dstofs;
  idx:=0;
  while idx<fsize do begin
    src:=mem[srcseg:srcofs+idx];
    rep:=1;
    while (mem[srcseg:srcofs+idx+rep]=src) and (rep<$f) do inc(rep);
    if rep>1 then begin
      mem[dstseg:dstofs]:=$f0 or rep;
      mem[dstseg:dstofs+1]:=src;
      inc(dstofs,2);
    end
    else begin
      if src>=$f0 then begin mem[dstseg:dstofs]:=$f1; inc(dstofs); end;
      mem[dstseg:dstofs]:=src; inc(dstofs);
    end;
    inc(idx,rep);
  end;
  outsize:=dstofs-start;
  freemem(inbuf,fsize);
  randseed:=ord(key[length(key)]); i:=0;
  for idx:=0 to outsize do begin
    mem[dstseg:start+idx]:=mem[dstseg:start+idx] xor
(ord(key[i])+random(ord(key[i])));    i:=1+i mod 8;
  end;
  fsplit(infname,fdir,fname,fext);
  assign(outfile,fdir+fname+'.dat');
  rewrite(outfile,1);
  blockwrite(outfile,outbuf^,outsize);
  freemem(outbuf,fsize);
end;

{ main ----------------------------------------------------------------------}

begin
  if (paramcount<>2) or (pos('?',paramstr(1))>0) then begin
    writeln('Syntax: ENCODE <filename> <key>');
    writeln('Both parameters are required!');
    halt;
  end;
  key:=paramstr(2);
  encode(paramstr(1));
  writeln('File successfully encoded!');
end.

>--- End of file ENCODE.PAS

>--- Begin of file DECODE.PAS

{$v-}

(*
** 'Decode' Binary mess to textfile.
** Written by Bas van Gaalen.
**
** This is suposed to be unhackable...
*)

program _decode; { DECODE.PAS }

uses
  dos;

var
  key:string[8];

{ decode file ---------------------------------------------------------------}

procedure decode(infname:pathstr);
var
  infile,outfile:file;
  fdir:dirstr; fname:namestr; fext:extstr;
  dbuf,sbuf:pointer;
  idx,i,j,srcseg,srcofs,dstseg,dstofs,start,csize:word;
  src,rep:byte;
begin
  if maxavail<2*65500 then halt;
  getmem(dbuf,65500);
  getmem(sbuf,65500);
  srcseg:=seg(sbuf^); srcofs:=ofs(sbuf^);
  dstseg:=seg(dbuf^); dstofs:=ofs(dbuf^); start:=dstofs;
  assign(infile,infname);
  {$i-} reset(infile,1); {$i+}
  if ioresult<>0 then halt;
  if filesize(infile)>65500 then halt;
  blockread(infile,sbuf^,filesize(infile));
  csize:=filesize(infile);
  close(infile);
  randseed:=ord(key[length(key)]); j:=0;
  for i:=0 to csize do begin
    mem[srcseg:srcofs+i]:=mem[srcseg:srcofs+i] xor
(ord(key[j])+random(ord(key[j])));    j:=1+j mod 8;
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
  {$i-} rewrite(outfile,1); {$i+}
  if ioresult<>0 then halt(4);
  blockwrite(outfile,dbuf^,csize);
  close(outfile);
  freemem(sbuf,65500);
  freemem(dbuf,65500);
end;

{ main ----------------------------------------------------------------------}

begin
  if (paramcount<>2) or (pos('?',paramstr(1))>0) then begin
    writeln('Syntax: DECODE <filename> <key>');
    writeln('Both parameters are required!');
    halt;
  end;
  key:=paramstr(2);
  decode(paramstr(1));
  writeln('File successfully decoded!');
end.

>--- End of file DECODE.PAS

