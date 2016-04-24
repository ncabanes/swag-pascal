(*
  Category: SWAG Title: ARCHIVE HANDLING
  Original name: 0037.PAS
  Description: Dealing with RAR files
  Author: GEORGE ROBERTS
  Date: 11-22-95  15:49
*)

{Let me guess, you are trying to list out the files in the RAR archive,
correct?  Here's how I do it (this is rough, because I am cleaning it up
from my source because mine handles it a little differently): }

CONST
  errmsg:array[0..5] of string[49] = (
    'Unable to access specified file',
    'Unexpected end of file',
    'Unexpected read error',
    'Invalid header ID encountered',
    'Can''t find next entry in archive',
    'File is not in RAR archive format');

  method:array[0..21] of string[9] = (
    'Directory',  {* Directory marker *}
    'Unknown! ',  {* Unknown compression type *}
    'Stored   ',  {* No compression *}
    'Packed   ',  {* Repeat-byte compression *}
    'Squeezed ',  {* Huffman with repeat-byte compression *}
    'crunched ',  {* Obsolete LZW compression *}
    'Crunched ',  {* LZW 9-12 bit with repeat-byte compression *}
    'Squashed ',  {* LZW 9-13 bit compression *}
    'Crushed  ',  {* LZW 2-13 bit compression *}
    'Shrunk   ',  {* LZW 9-13 bit compression *}
    'Reduced 1',  {* Probabilistic factor 1 compression *}
    'Reduced 2',  {* Probabilistic factor 2 compression *}
    'Reduced 3',  {* Probabilistic factor 3 compression *}
    'Reduced 4',  {* Probabilistic factor 4 compression *}
    'Frozen   ',  {* Modified LZW/Huffman compression *}
    'Imploded ',  {* Shannon-Fano tree compression *}
    'Imploded ',  {* Shannon-Fano tree compression *}
    'Fastest  ',
    'Fast     ',
    'Normal   ',
    'Good Comp',
    'Best Comp');

TYPE
  outrec=record   {* output information structure *}
           filename:string[255];             {* output filename *}
           date:integer;                     {* output date *}
           time:integer;                     {* output time *}
           typ:integer;                      {* output storage type *}
           csize:longint;                    {* output compressed size *}
           usize:longint;                    {* output uncompressed size *}
         end;

   rarheaderrec=record
              b:array[1..7] of byte;
             end;
   rarfilerec=record
            packsize:longint;
            unpacksize:longint;
            HostOS:byte; { 0 dos 1 os/2 }
            FileCRC:longint;
            mod_time:integer;
            mod_date:integer;
            rarver:byte;
            method:byte;
            fnamesize:integer;
            attr:longint;
           end;

VAR out:outrec;
    aborted:boolean;

procedure emsg(message:string);
begin
  {*  emsg - Display error message
   *}

  writeln;
  writeln('* '+message);
  aborted:=TRUE;
end;

function getbyte(var fp:file):char;
var buf:array[0..0] of char;
    numread:word;
    c:char;
begin
  if (not aborted) then begin
    blockread(fp,c,1,numread);
    if numread=0 then begin
      close(fp);
      emsg(errmsg[1]);
    end;
    getbyte:=c;
  end;
end;

procedure Process_RAR(var fp:file);

var rar:rarfilerec;
    rh:rarheaderrec;
    rha:array[1..100] of byte;
    buf:array[0..25] of byte;
    h:integer;
    ad:longint;
    numread:word;
    i,stat:integer;
    add2:word;
    c:char;
    add:boolean;

begin

  while (not aborted) do begin
  {* set up infinite loop (exit is within loop) *}
    add:=FALSE;
    blockread(fp,rh.b[1],5,numread);
    if numread<>5 then emsg(errmsg[2]);
    if (aborted) then exit;
    if not(rh.b[3]=$74) then exit;
    blockread(fp,h,2,numread);
    if numread<>2 then emsg(errmsg[2]);
    if (aborted) then exit;
    blockread(fp,rar,sizeof(rar),numread);
    if numread<>sizeof(rar) then emsg(errmsg[2]);
    if (aborted) then exit;
    out.filename:='';
    for i:=1 to rar.fnamesize do    {* get filename *}
      out.filename[i]:=getbyte(fp);
    out.filename[0]:=chr(rar.fnamesize);
    out.filename:=stripname(out.filename);
    out.date:=rar.mod_date;
    out.time:=rar.mod_time;
    out.csize:=rar.packsize;
    out.usize:=rar.unpacksize;
    case rar.method of
      $30:out.typ:=2;    {* Stored *}
      $31:out.typ:=17;    {* Shrunk *}
      $32:out.typ:=18;
      $33:out.typ:=19;
      $34:out.typ:=20;
      $35:out.typ:=21;
    else begin
        out.typ:=1;    {* Unknown! *}
        end;
    end;

    {place call to routine that displays one file list line using the
     <out> variable}

    {$I-} seek(fp,filepos(fp)+(h-(sizeof(rar)+7+
                length(out.filename)))); {$I+}
    if (ioresult<>0) then emsg(errmsg[4]);
    if (aborted) then exit;
    {$I-} seek(fp,filepos(fp)+(rar.packsize)); {$I+}
    if (ioresult<>0) then emsg(errmsg[4]);
    if (aborted) then exit;
  end;
end;

procedure showrar(infile:string);
var    rha:array[1..15] of byte;
         c:char;
         h:word;
   numread:word;

begin
          assign(fp,infile);
          {$I-} reset(fp,1); {$I+}
          if ioresult<>0 then begin end;

          c:=getbyte(fp);  {* determine type of archive *}
          if (c=$52) then begin
                if (ord(getbyte(fp))<>$61) then emsg(errmsg[5]);
                if (ord(getbyte(fp))<>$72) then emsg(errmsg[5]);
                if (ord(getbyte(fp))<>$21) then emsg(errmsg[5]);
                if (ord(getbyte(fp))<>$1a) then emsg(errmsg[5]);
                c:=getbyte(fp);
                c:=getbyte(fp);
                blockread(fp,rha[1],5,numread); if numread<>5 then
                        abend(abort,next,errmsg[2]);
                if rha[3]<>$73 then begin
                   emsg(errmsg[2]);
                end;
                blockread(fp,h,2,numread);
                if numread<>2 then emsg(errmsg[2]);
                blockread(fp,rha[1],6,numread);
                if numread<>6 then emsg(errmsg[2]);
                {$I-} seek(fp,filepos(fp)+(h-13)); {$I+}
                if (ioresult<>0) then emsg(errmsg[4]);
                writeln('Original Compress  %  Met'+
                        'hod    Date     Time   Filename');
                writeln('-------- -------- --- '+
                        '--------- -------- ------ ------------');
                process_RAR(fp);  {* process RAR entry *}

                { place call to routine that displays any totals or anything
you          may have compiled }

          end else reset(fp,1);


          close(fp);              {* close file *}

end;

This is not a complete unit or program because it is a cut and paste from
(MANY) different source files of mine... ;)  I display a bunch of different
archive types and the display routines are all intertwined, so I had to cut
out the RAR ones to show you here.  I would not suggest reading the file
byte by byte and trying to convert it.  I would simply do something like
what I have done here, (I meant this to be an example... not necessarily a
cut and paste solution) and use the record and blockread in the record.

Hope this helps somewhat! ;)


George A. Roberts IV
Intuitive Vision Software
ivsoft@ripco.com

