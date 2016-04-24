(*
  Category: SWAG Title: ANYTHING NOT OTHERWISE CLASSIFIED
  Original name: 0031.PAS
  Description: File at end of EXE
  Author: JACK MOFFITT
  Date: 08-27-93  20:55
*)

{
JACK MOFFITT

>Okay, how about this: If I wanted to attach it to the back of an EXE, I
>COPY /B it. Now, in the source code, how do I find the picture and set
>everything up? I mean do you LoadGif (Ofs,Seg) or something? That's what
>I mean, and I'm sorry to put you through this.

Ok..  here we go..  everyone seems to be asking this, so i'll just post
some source.  Granted this is not a COMPLETE program, just an example on
how to read the header, and get a pointer to the GIF.
}

(* This code originally by Scott Johnson, I revised it later *)

function GetSize(N : byte) : word;
function GetData(N : byte) : pointer;
function GetDataCount : byte;

implementation

uses
  Dos;

type
  DataRec = record
    Size : word;
    Loc  : longint;
  end;
  DataArray    = array [1..255] of DataRec;
  DataArrayPtr = ^DataArray;

  ExeDataRec = record
    ActSize : word;
  end;


var
  ExeFile   : file;
  DataCount : byte;         { count of data records }
  Data      : DataArrayPtr;

procedure OpenExe;
begin
  assign(ExeFile, ParamStr(0));
  reset(ExeFile, 1);
end;

procedure CloseExe;
begin
  Close(ExeFile);
end;

procedure InitExe;
var
  ExeHdr : record
    M, Z  : char;
    Len   : word;
    Pages : word;
  end;
  ExeLoc  : longint;
  I       : byte;
  ExeData : ExeDataRec;
begin
  OpenExe;
  BlockRead(ExeFile, ExeHdr, SizeOf(ExeHdr));
  if ExeHdr.Len = 0 then
    ExeHdr.Len := $200;
  ExeLoc := (longint(ExeHdr.Pages) - 1) shl 9 + longint(ExeHdr.Len);
  Seek(ExeFile, ExeLoc);
  BlockRead(ExeFile, DataCount, 1);      { read data count byte }
  Inc(ExeLoc);
  GetMem(Data, SizeOf(DataRec) * DataCount);
  for I := 1 to DataCount do
  begin
    Seek(ExeFile, ExeLoc);
    BlockRead(ExeFile, ExeData, SizeOf(ExeData));
    Data^[I].Loc  := ExeLoc;
    Data^[I].Size := ExeData.ActSize;
    Inc(ExeLoc, ExeData.ActSize + 2);
  end;
  CloseExe;
end;

function GetSize(N : byte) : word;
begin
  if N > DataCount then
    RunError(201);
  GetSize := Data^[N].Size;
end;

function GetData(N : byte) : pointer;
var
  P, D    : pointer;
  DataLoc : longint;
  E       : ExeDataRec;
begin
  if N > DataCount then
    RunError(201);
  GetMem(P, Data^[N].Size);
  OpenExe;
  Seek(ExeFile, Data^[N].Loc + 2);   { +2 is to get past info record }
  BlockRead(ExeFile, P^, Data^[N].Size);
  CloseExe;
  GetData := P;
end;

function GetDataCount : byte;
begin
  GetDataCount := DataCount;
end;

begin
  InitExe;
end.

{
Ok.. that's it.  Call GetData(x) to get the location of the first
element.  Datacount is the number of GIFs or whatever you have in there
and the first two bytes are the actual size..  So to add a file, just
make a temp file called ADDED.DAT, write a byte value for the datacount,
and a word value for the filesize of the data you're adding, and then
the data.  Hope this help all of you who wanted to be able to add ANSis,
GIFs, and whatnot onto exes.  Also, with little modification, you can
make it read from .DAT files with multiple gifs and stuff in them.
}

