(*
  Category: SWAG Title: EXECUTION ROUTINES
  Original name: 0013.PAS
  Description: Appending to EXE Files
  Author: LARRY HADLEY
  Date: 01-27-94  12:00
*)

{
>Hmmm.... how about this.... I want to put a 75k MOD file into the EXE...
>I've heard that you use pointers and appending the MOD to end of your
>compiled program and stuff like that... I'm not too sure how to go about
>it.

In short, the easiest way is to append to to your .EXE file. The
following code will search the current .exe for data appended to
the end of the .exe file.
}

Uses
  DOS;

TYPE              { .exe file header }
  EXEH = RECORD
    id,            { .exe signature }
    Lpage,         { .exe file size mod 512 bytes; < 512 bytes }
    Fpages,        { .exe file size div 512 bytes; + 1 if Lpage > 0 }
    relocitems,    { number of relocation table items }
    size,          { .exe header size in 16-byte paragraphs }
    minalloc,      { min heap required in additional to .exe image }
    maxalloc,      { extra heap desired beyond that required
                     to hold .exe's image }
    ss,            { displacement of stack segment }
    sp,            { initial SP register value }
    chk_sum,       { complemented checksum }
    ip,            { initial IP register value }
    cs,            { displacement of code segment }
    ofs_rtbl,      { offset to first relocation item }
    ovr_num : word; { overlay numbers }
  END;

CONST
  MAX_BLOCK_SIZE = 65528; {maximum allowable size of data block in
                            TP}
TYPE
  pdata = ^data_array;
  data_array = array[0..MAX_BLOCK_SIZE] of byte;

  pMODblock = ^MODblock;
  MODblock = RECORD
    data     :pdata;
    datasize :word;
  end;

VAR
  exefile : file;
  exehdr  : exeh;
  blocks  : word;

  exesize,
  imgsize : longint;

  path    : dirstr;
  name    : namestr;
  ext     : extstr;
  EXEName : pathstr;
  n       : byte;

  dirfile : searchrec;

  M       : pMODblock;

{Determines the exe filename, opens the file for read-only, and
 determines the actual .exe code image size by reading the
 standard .exe header that is in front of every .exe file. The .MOD
 data will be in the file *after* the end of the code image.}
Procedure ReadHdr;

  {this "finds" your exe filename}
  Function CalcEXEName : string;
  var
    Dir  : DirStr;
    Name : NameStr;
    Ext  : ExtStr;
  begin
    if Lo(DosVersion) >= 3 then
      EXEName := ParamStr(0)
    else
      EXEName := FSearch('progname.EXE', GetEnv('PATH'));
                         {  ^^^^^^^^ } { change this to intended EXE name }
    FSplit(EXEName, Dir, Name, Ext);
    CalcEXEName := Name;
  end;

begin
  Name := CalcEXEName;

  findfirst(EXEName, anyfile, dirfile);
  while (doserror=0) do
  BEGIN
    Assign(exefile, EXEName);
    Reset(exefile, 1);         { reset for 1 byte records }
    BlockRead(exefile, exehdr, SizeOf(exehdr), blocks);
    if blocks<SizeOf(exehdr) then
    begin
      Writeln('File read error!');
      Halt(1);
    end;
    exesize := dirfile.size;     { the total file size of exe+data }
    with exehdr do
    begin
      imgsize := FPages; {exe img size div 512 bytes, +1 if Lpage>0}
      if LPage > 0 then
        dec(imgsize);
      imgsize := (imgsize*512) + LPage; {final image size}
    end;
  END;
end;

{ this function reads the 64k-8 byte sized block, numbered
  "blocknum" from the end of the file exefile (already opened in
  ReadHdr proc above), allocates a new pMODblock structure and
  passes it back to the caller. "blocknum" is 0-based - ie, data
  offset starts at 0. If the remaining data is less than 64k, the
  data record will be sized to the remaining data.}
Function ReadBlockFromMOD(blocknum):pMODblock;
var
  filepos : longint;
  mod     : pMODblock;
begin
  filepos := imgsize + (blocknum*MAX_BLOCK_SIZE);
  if filepos > exesize then {block position asked for exceeds filesize}
  begin
    ReadBlockFromMOD := NIL; { return error signal }
    EXIT;                    {...and return}
  end;
  New(mod);

  if (filepos+MAX_BLOCK_SIZE>exesize) then
    mod^.datasize := exesize-filepos
        { data left in this block is less than 64k }
  else
    mod^.datasize := MAX_BLOCK_SIZE;
        { data block is a full 64k }
  GetMem(mod^.data, mod^.datasize); {get the memory for the data buffer}

  Seek(exefile, filepos); { position dos's filepointer to beginning of block}
  BlockRead(exefile, mod^.data^, mod^.datasize, blocks);

  if blocks<mod^.datasize then { make sure we got all the data }
  begin
    Writeln('File read error!');
    FreeMem(mod^.data, mod^.datasize);
    Dispose(mod);
    ReadBlockFromMOD := NIL;
    EXIT;
  end;

  ReadBlockFromMOD := mod;
end;

{
   This will read in the .MOD from the "back" of the .exe 64k-8
   bytes at a time. As written, you manually have to pass a block
   number to the "read" function.

   A couple of caveats - doing it as written is error-prone. Using
   this code "barebones" in a finished application is not advisable,
   but it does demonstrate the concept and gives you a starting
   point. THIS CODE HAS NOT BEEN TESTED! If you have problems with
   it, let me know and I'll help you out.

   After you have digest the code, ask some more questions and we
   can discuss streams and OOP techniques to do this in a less
   dangerous manner.
}
