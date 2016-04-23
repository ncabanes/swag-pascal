{
>I am trying to write a program that will extract a linked list from data
>appended to the executable with the MS-Dos COPY /B command.  Is such a thing
>possible?  I have been unable to do it with standard text file procedures.

You can't extract a linked list but you can retreive data and then
put it into a linked list. The linked list is a memory data
structure whereas the data on disk is just collections of data. You
could probably do what you want with streams, though.

Here's a unit I wrote for using appended data which may help:
}

unit appnddat;

(*
  APPNDDAT - Copyright (c) Steve Rogers, 1994

  Allows user to store configuration data at the end of an EXE file.
  The putConfig procedure stores a record at the end of the EXE file.
  If data is already present in the EXE, it will be overwritten.
  GetConfig will retreive data that has been appended to the EXE.

  NOTE: The pCfgRec parameter passed to both putConfig & getConfig is
        a raw pointer, RecSize is the size of the config record.

        Also, since this unit gets its data from the data following
        the executeable code, it won't work if you compile your EXE
        in the $d+ state (include debug information).
*)

(* We'll do our own i/o checking, thanks. *)
{$i-}

interface

function EXESize(fname : string) : longint;
function DataAppended(fname : string) : boolean;
procedure putConfig(fname : string;pCfgRec : pointer;RecSize : word);
procedure getConfig(fname : string;pCfgRec : pointer;RecSize : word);

implementation
uses
  dos;

{----------------------}
function EXESize(fname : string) : longint;
{ Returns size of executable code in EXE file }

type
  tSizeRec=record    { first 6 bytes of EXE header }
    mz,
    remainder,
    pages : word;
  end;

var
  f : file of tSizeRec;
  sz : tSizeRec;

begin
  assign(f,fname);
  reset(f);
  if (ioresult<>0) then EXESize:= 0 else begin
    read(f,sz);
    close(f);
    with sz do EXESize:= remainder+(longint(pred(pages))*512);
  end;
end;

{----------------------}
function DataAppended(fname : string) : boolean;
var
  f : file;
  sz : longint;

begin
  assign(f,fname);
  reset(f,1);
  if (ioresult<>0) then DataAppended:= false else begin
    sz:= filesize(f);
    close(f);
    DataAppended:= (sz>EXESize(fname));
  end;
end;

{-----------------------}
procedure putConfig(fname : string;pCfgRec : pointer;RecSize : word);
var
  f : file;
  DataOffset : longint;

begin
  DataOffset:= EXESize(fname);

  assign(f,fname);
  reset(f,1);
  seek(f,DataOffset);
  blockwrite(f,pCfgRec^,RecSize);
  close(f);
end;

{-----------------------}
procedure getConfig(fname : string;pCfgRec : pointer;RecSize : word);
var
  f : file;
  DataOffset : longint;

begin
  if (DataAppended(fname)) then begin
    DataOffset:= EXESize(fname);
    assign(f,fname);
    reset(f,1);
    seek(f,DataOffset);
    blockread(f,pCfgRec^,RecSize);
    close(f);
  end;
end;

{----------------------}
end.
