(*
  Category: SWAG Title: EGA/VGA ROUTINES
  Original name: 0234.PAS
  Description: Reading TIFF Files
  Author: ALAN B.
  Date: 05-26-95  23:30
*)

{
From: nigelg@lpilsley.demon.co.uk (Nigel Goodwin)
> Can anyone tell me where to find some pascal source code that reads simple
> bi-level TIFF format images. It should support the standard TIFF compression
> schemes used for bi-level images.

Here's a TIFF program I downloaded from Compuserve, hope it may be of help.
}

Program tiffread;

{Written by Alan B.}


{$I-,R+}

uses  printer,crt,dos,graph;

type  binstr     = string[8];
      screenarray= array[1..11000] of byte;

      stripinfoptr = ^stripinfo;
      stripinfo    = record
                       size: word;
                       offset: word;
                       stripinfolink: stripinfoptr;
                     end;
      stripobytesptr =^stripobytes;
      stripobytes    = record
                         value: byte;
                         stripobyteslink: stripobytesptr;
                       end;
      lineobytesptr    = ^lineobytes;
      lineobytes       = record
                           bits: byte;
                           lineobyteslink: lineobytesptr;
                         end;

var   fin,
      fout                   : file;
      i,j,k,rr               : integer;
      l,m,
      column,
      bytepos                : byte;
      row                    : integer;
      count                  : shortint;
      rownum                 : integer;
      TifFileName            :   String[45];
      dot: boolean;
      rowstir                : integer;
      fentries,
      nexttag,
      nextlength             : word;
      tbyte                  : byte;
      fimagewidth,
      fimagelength,
      fstripoffsetsoffset,
      fstrips,
      fstripbytecountsoffset,
      bytetoread,
      largeststrip           : word;
      first,
      last,
      p                      : stripinfoptr;
      firstbyte,
      lastbyte,
      pbyte                  : stripobytesptr;
      firstline,
      lastline,
      pline                  : lineobytesptr;
      columns                : integer;
      compression            : word;
      regs                   : registers;
      screen                 : ^screenarray;
      header                 : array[1..10] of byte;
      page                   : array[1..8,1..100] of byte;
      printcolumns           : integer;


{reads a file into the image array}
{assumes StripOffsets start directly after stripbytcounts}
{read down to where stripbytecounts starts}
{fill stripbytecounts with size in bytes of each offset}
{read each strip into linked list}


procedure Writebytes;
begin
{this displays the contents of the linked list on the printer}
  pbyte:= firstbyte;
  while pbyte^.stripobyteslink <> nil do
    begin
      write(lst,pbyte^.value:3,' ');
      pbyte:= pbyte^.stripobyteslink;
    end;
  writeln(lst);
end;

procedure WriteStripInfo;
begin
{this displays the contents of the linked list on the printer}
  p:= first;
  while p <> nil do
    begin
      write(lst,p^.size:3,' ');
      writeln(lst,p^.offset:4,' ');
      p:= p^.stripinfolink;
    end;
  writeln(lst,#12);
end;

Procedure SetVMode(newmode:integer);
begin
  FillChar(Regs,SizeOf(regs),0);
  Regs.AX:= newmode;
  Intr($10,Regs);
end;

Function BitOn(Position, TestByte:byte):boolean;
var
  bt,
  i:byte;
begin
  bt:= $01;
  bt:= bt shl position;
  biton:= (bt and testbyte) > 0;
end;

procedure Pictoprinter(row:integer);
var bytepos,
    j,i,
    pinlabel,
    pin,
    column   : integer;
    trow     : integer;
begin
  write(lst,#27,'A',#8); {8 lines per inch}
  bytepos:=0;
  write(lst,#27,'L',Chr((columns*8) mod 256),chr((columns*8) div 256));
{graphics mode}
  for column:=1 to columns do
  begin
    for bytepos:=0 to 7 do
    begin
      trow:=1;
      pinlabel:=0;
      if not biton(abs(bytepos-7),page[trow][column]) then
        pinlabel:= 128;
      inc(trow);
      if not biton(abs(bytepos-7),page[trow][column]) then
        inc(pinlabel,64);
      inc(trow);
      if not biton(abs(bytepos-7),page[trow][column]) then
        inc(pinlabel,32);
      inc(trow);
      if not biton(abs(bytepos-7),page[trow][column]) then
        inc(pinlabel,16);
      inc(trow);
      if not biton(abs(bytepos-7),page[trow][column]) then
        inc(pinlabel,8);
      inc(trow);
      if not biton(abs(bytepos-7),page[trow][column]) then
        inc(pinlabel,4);
      inc(trow);
      if not biton(abs(bytepos-7),page[trow][column]) then
        inc(pinlabel,2);
      inc(trow);
      if not biton(abs(bytepos-7),page[trow][column]) then
        inc(pinlabel);
      write(lst,char(pinlabel))
    end;
  end;
  write(lst,#13,#10);
end;

procedure Pictoscreen(row:integer);

var storagebyte : byte;
    i,j,wl,wr,wb,wt,
    column      : integer;

procedure SetPixal(xpos,ypos:integer);
begin
  FillChar(Regs,SizeOf(regs),0);
  Regs.ah:= $0c;
  Regs.al:= 1;
  Regs.cx:= xpos;
  Regs.dx:= ypos;
  intr($10,Regs);
end;

begin
  column:= 1;
  printcolumns:= 0;
  while pline <> nil do
    begin
      if ((row mod 8) = 0) then
        page[8,column]:= pline^.bits
      else
        page[row mod 8,column]:= pline^.bits;
      for i:= 0 to 7 do
        if biton(i,pline^.bits) then
        begin
          SetPixal((column*8-7)+abs(i-7),row);
          inc(printcolumns)
        end;
      pline:= pline^.lineobyteslink;
      inc(column)
    end;
end;



Procedure GetFileName;

Function fileexists(searchfile: string):boolean;
var
  f:   file;
  ok:  boolean;
begin
  assign(f,searchfile);
  (*$I-*)
  reset(f,1);
  (*$I+*)
  ok:= ioresult = 0;
  if not ok then
    fileexists:= false
  else
    begin
      close(f);
      fileexists:= true;
    end;
end;

begin
  TifFileName:='____________';
  i:=ParamCount;
  if i>1 then
  begin
    Write(#07,' Invalid Number of Paramaters');
    Halt;
  end
  else
  if i=0 then
  begin
    write('Enter File Name: ');
    ReadLn(tifFileName);
    if Length(tifFileName)=0 then
      Halt;
  end
  else
  begin
    tifFileName:=ParamStr(1);
  end;
  Dot:=False;
  for i:=1 to Length(tifFileName) do
    if tifFileName[i]='.' then
        Dot:=True;
  if Dot=False then
    tifFileName:=tifFileName+'.TIF';
  if not(FileExists(tifFileName)) then
  begin
    Write(#07,'File ',tifFileName,' Not on Disk');
    Halt;
  end;
end;


Procedure GetFileInfo;
begin
  assign(fin,tiffilename);
  reset(fin,1);
  blockread(fin,header,8);
  writeln('***********');
        {we're assuming the ifd is right after the header}
  blockread(fin,fentries,2);
  for i:=1 to fentries do
    begin
      blockread(fin,nexttag,2);
      case nexttag of
         {i really need a 32 bit unsigned type here. since i dont have
          one file witdth should be limited to 65535}
        256: begin                        {imagewidth}
               blockread(fin,header,6);
               blockread(fin,fimagewidth,2);
               Columns:= (fimagewidth div 8);
               if (fimagewidth mod 8) <> 0 then
                 inc(Columns);
{               writeln('columns: ',columns);}
               blockread(fin,header,2);
             end;
        257:begin                         {imagelength}
              blockread(fin,header,6);
              blockread(fin,fimagelength,2);
{              writeln('rows: ',fimagelength);}
              blockread(fin,header,2);
            end;
        259:begin
              blockread(fin,header,6);
              blockread(fin,Compression,2);
              if compression <> 32773 then
                begin
                  writeln('I can''t read this. A computer is a terrible thing to waste, isn''t it.');
                  readln;
                  halt;
                end;
              blockread(fin,header,2);
            end;
        273:begin                         {stripOffsets}
              blockread(fin,header,2);    {read past field type}
              blockread(fin,fstrips,2);      {length}
              writeln('strips: ',fstrips);
              blockread(fin,header,2);
              blockread(fin,fstripoffsetsoffset,2);
              blockread(fin,header,2);
            end;
        279:begin                         {StripByteCounts}
              blockread(fin,header,6);
              blockread(fin,fstripbytecountsoffset,2);
              writeln('stripbytecountoffset: ',fstripbytecountsoffset);
              blockread(fin,header,2);
            end;
        else blockread(fin,header,10);
      end;  {case}
    end; {for i:= 1 to fentries}
end;




Procedure GetStripCounts;


procedure add(fcount:word);
{we're assuming theres at least 1 byte in the list}
begin
  if first = nil then
    begin
      new(first);
      last:= first;
      first^.size:= fcount;
    end
  else      {the list has already been started so just add to it}
    begin
      new(p);
      p^.size:= fcount;
      last^.stripinfolink:=p;
      last:= p;
    end;
end;

begin
{here we're assuming the stripbytecount values will fit in a word}
{this part reads stripbytecounts into the linkedlist}
  first:= nil;
  reset(fin,1);
  seek(fin,fstripbytecountsoffset);
  for i:= 1 to fstrips do
    begin
      blockread(fin,bytetoread,2);
      add(bytetoread);
    end;
  if first <> nil then last^.stripinfolink:= nil;
end;


Procedure GetStripOffsets;
begin
{this part reads in the strip offsets into the linked list}
  p:= first;
  reset(fin,1);
  seek(fin,fstripoffsetsoffset);
  for i:= 1 to fstrips do
    begin
      blockread(fin,bytetoread,2);
      p^.offset:= bytetoread;
      p:=p^.stripinfolink;
      blockread(fin,bytetoread,2);
    end;
end;

procedure DisposeStrip;
var
tpointer:stripobytesptr;
begin
  tpointer:= firstbyte^.stripobyteslink;
  dispose(firstbyte);
  firstbyte:= tpointer;
  while tpointer^.stripobyteslink <> nil do
  begin
    tpointer:= tpointer^.stripobyteslink;
    dispose(firstbyte);
    firstbyte:= tpointer;
  end;
  dispose(tpointer);
end;

Procedure ReadAStrip;

procedure addbyte(fcount:word);
{we're assuming there's at least 1 byte in the list}
begin
  if firstbyte = nil then
    begin
      new(firstbyte);
      lastbyte:= firstbyte;
      firstbyte^.value:= fcount;
    end
  else      {the list has already been started so just add to it}
    begin
      new(pbyte);
      pbyte^.value:= fcount;
      lastbyte^.stripobyteslink:=pbyte;
      lastbyte:= pbyte;
    end;
end;

begin
{this part jumps down to the right place in the file and reads a strip into
 a linked list.  We'll just read in one strip for now.}

  firstbyte:= nil;
  reset(fin,1);
  seek(fin,p^.offset);
  for i:= 1 to p^.size + 1 do  {+1 for not / by 8 evenly}
    begin
      blockread(fin,tbyte,1);
      addbyte(tbyte);
    end;
  if firstbyte <> nil then lastbyte^.stripobyteslink:= nil;
end;


Procedure DecodeStrip;

var
  spot     : integer;

procedure disposeline;
var
tpointer:lineobytesptr;
begin
  tpointer:= firstline^.lineobyteslink;
  dispose(firstline);
  firstline:= tpointer;
  while tpointer^.lineobyteslink <> nil do
  begin
    tpointer:= tpointer^.lineobyteslink;
    dispose(firstline);
    firstline:= tpointer;
  end;
  dispose(tpointer);
end;

procedure ResetPage;
begin
  if firstline <> nil then lastline^.lineobyteslink:= nil;
  pline:= firstline;
  pictoscreen(rownum);
  {if ((rownum div 8) >= 1) and ((rownum mod 8) = 0) then
    pictoprinter(rownum);}
  inc(rownum);
  disposeline;
  firstline:= nil;
  spot:= 1;
end;

procedure addline(fcount:word);
{we're assuming there's at least 1 byte in the list}
begin
  if firstline = nil then
    begin
      new(firstline);
      lastline:= firstline;
      firstline^.bits:= fcount;
    end
  else      {the list has already been started so just add to it}
    begin
      new(pline);
      pline^.bits:= fcount;
      lastline^.lineobyteslink:=pline;
      lastline:= pline;
    end;
end;

begin
{now lets try and decode the strip in the linked list}
  firstline:= nil;
  spot:= 1;
  pbyte:= firstbyte;
  while pbyte^.stripobyteslink <> nil do {convert the strip 8 rows per strip}
    begin
      Count:= shortint(pbyte^.value);
      if Count < 0 then    {copy the next byte -n+1 times}
        begin
          pbyte:= pbyte^.stripobyteslink; {point to the byte to copy -n+1
times}
          for i:= 1 to (-Count+1) do
            begin
              addline(pbyte^.value);
              inc(spot);
              if spot > columns then
                resetpage;
            end;
        end
      else                  {copy the next n+1 bytes literally}
        for i:= 1 to (Count+1) do {no error checking for nil}
          begin
            pbyte:= pbyte^.stripobyteslink; {point the the next literal byte}
            addline(pbyte^.value);
            inc(spot);
            if spot > columns then
              resetpage;
          end;
      pbyte:= pbyte^.stripobyteslink;
    end;
end;

var ch:char;
begin
  GetFileName;
  GetFileInfo;
  GetStripCounts;
  GetStripOffsets;
  p:= first;
  SetVMode($10);
  new(screen);
  screen:= ptr($A000,$0000);
  rownum:= 1;
  while p^.stripinfolink <> nil do
    begin
      ReadAStrip;
      DecodeStrip;
      DisposeStrip;
      p:= p^.stripinfolink;
    end;
  close(fin);
  assign(input,'');
  reset(input);
  readln;
  SetVMode($3);
  {write(lst,#12,#13);}

  {enhancements needed

  adjust for aspect ratio
  mask out extra stuf at right side when displaying
  add ega support
  add interface
  write direct to memory
  }

end.




