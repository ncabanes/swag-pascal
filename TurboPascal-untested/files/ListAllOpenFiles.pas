(*
  Category: SWAG Title: FILE HANDLING ROUTINES
  Original name: 0066.PAS
  Description: List all open files
  Author: D.J. MURDOCH
  Date: 11-26-94  05:03
*)

unit openfiles;
(*

OPENFILES - Print list of all open files

Written by D.J. Murdoch for the public domain.

This unit interfaces three routines, which look in the (undocumented) DOS list
of open files for the filenames.  One routine prints a list of open files,
another returns the list in a collection of strings, and the third calls a
user routine once for each open file.  If compiled for DOS, it automatically
installs an exit handler to call the print routine, so if your program bombs
because it runs out of file handles, you'll see the list of what's open.

I've tested this unit in MSDOS 3.2, 4.01, 5 and 6; it should work in the
other versions from 2 to 6, but I'd like to hear from you if it doesn't.

Fidonet:   DJ Murdoch at 1:249/99.5
Internet:  dmurdoch@mast.queensu.ca
CIS:       71631,122

History:
  1. 21 Oct 91  - First release to PDN echo.
  2. 26 Oct 91  - Added check of PSP segment, and DOS 3.0 record format.
                  Set Allfiles to true to get previous behaviour.
  3. 24 Jun 93  - Added DOS 6 and DPMI support
  4. 24 Aug 94  - Added BP 7 Windows support, a bit more flexibility
                  in ways to call

Thanks are due to Berend de Boer for a series of articles explaining how to
make real mode interrupt calls from protected mode.  His hints let me add the
DPMI and Windows support.
*)
{#Z+  Don't add these comments to the help file }

interface

uses
{$ifdef windows}
  {$ifdef ver15}
  wobjects,winprocs,win31,windos;  { For TPW 1.5 }
  {$else}
  objects,winapi,windos;    { For BP 7 Windows. }
  {$endif}
{$else}
{$ifdef dpmi}
  winapi,           { For BP 7 pmode }
{$endif}
  objects,dos;              { For BP 7 DOS }
{$endif}

{#Z-}

const
  version = 4;

  Allfiles : boolean = false;               { Whether to print files belonging
                                              to other processes }

procedure print_open_files(var where:text);
{ Print open file list to given file }

function get_open_files:PCollection;
{ Returns a new collection containing pointers to strings holding the
  filenames.  Note that you'll need to use DisposeStr on each element
  to release them. }

procedure For_each_open_file(Action:pointer);
{ Calls the far local procedure Action once per open file.  Action should be
  declared as

    procedure Action(filename:string;openmode:word); far;

  if it's a local procedure, or

    procedure Action(filename:string; openmode,dummy:word); far;

  if not.  (Local procedures are procedures defined within other procedures.)
  The filename will be the name of the file (no path), the openmode will be the
  mode used to open the file.
}

implementation

{$ifdef windows}
{$define dpmi}      { Everything else about Windows is
                      the same as DPMI }
{$endif}
type
  ptrrec = record
    ofs, seg : word;
  end;

var
  MyPrefixSeg : word;

{$ifdef dpmi}
     { This type was given by Berend de Boer, who credited the
       DPMI unit from Borland's Open Architecture book }
     type
       TRealModeRegs = record
         case Integer of
           0: (
               EDI, ESI, EBP, EXX, EBX, EDX, ECX, EAX: Longint;
               Flags, ES, DS, FS, GS, IP, CS, SP, SS: Word);
           1: (
               DI,DIH, SI, SIH, BP, BPH, XX, XXH: Word;
               case Integer of
                 0: (
                     BX, BXH, DX, DXH, CX, CXH, AX, AXH: Word);
                 1: (
                     BL, BH, BLH, BHH, DL, DH, DLH, DHH,
                     CL, CH, CLH, CHH, AL, AH, ALH, AHH: Byte));
         end;

function MakePointer(seg,ofs:word):pointer;
var
  sel,junk : word;
begin
  sel := AllocSelector(Dseg);  { !!4  Copy Dseg attributes }
  sel := SetSelectorBase(sel, longint(16)*seg);
  if sel <> 0 then
  begin
    junk := SetSelectorLimit(sel, $ffff);
    MakePointer := Ptr(sel,ofs);
  end
  else
    MakePointer := nil;
end;

procedure ReleasePointer(p:pointer);
var
  junk : word;
begin
  junk := FreeSelector(ptrrec(p).seg);
end;

procedure RealModeInterrupt(int:byte;var regs:TRealModeRegs);
label
  okay;
begin
  asm
    mov ax,$0300
    mov bl,int
    mov bh,0
    mov cx,0
    les di,regs
    int $31
    jnc  okay
  end;
  writeln('Real mode call failed!');
okay:
end;

function GetListOfLists:pointer;
{ Calls DOS service $52 to get pointer to list of lists, and
  translates pointer to a pmode pointer }
var
  regs : TRealModeRegs;
begin
  fillchar(regs,sizeof(regs),0);
  regs.ah := $52;
  RealModeInterrupt($21,regs);
  GetListOfLists := MakePointer(regs.es,regs.bx);
end;

procedure GetPrefixSeg;
{ Stores real mode segment of the PSP in MyPrefixSeg}
begin
  MyPrefixSeg := GetSelectorBase(system.prefixseg) div 16;
end;
{$else}

function MakePointer(seg,ofs:word):pointer;
begin
  MakePointer := Ptr(seg,ofs);
end;

procedure ReleasePointer(p:pointer);
begin
end;

function GetListOfLists:pointer;
var
  regs : Registers;
begin
  fillchar(regs,sizeof(regs),0);
  regs.ah := $52;
  msdos(regs);
  GetListOfLists := MakePointer(regs.es,regs.bx);
end;

procedure GetPrefixSeg;
begin
  MyPrefixSeg := PrefixSeg;
end;

{$endif}

type
  dos2openfilerec = record
    numhandles,
    openmode : byte;
    junk1 : array[2..3] of byte;
    filename : array[4..$e] of char;
    junk2 : array[$f..$27] of byte;
  end;

  dos30openfilerec = record                   {!!2}
    numhandles,
    openmode : word;
    junk1 : array[4..$20] of byte;            {!!2}
    filename : array[$21..$2b] of char;       {!!2}
    junk2 : array[$2c..$31] of byte;          {!!2}
    pspseg : word;                            {!!2}
    junk3 : array[$34..$37] of byte;          {!!2}
  end;

  dos3openfilerec = record
    numhandles,
    openmode : word;
    junk1 : array[4..$1f] of byte;
    filename : array[$20..$2a] of char;
    junk2 : array[$2b..$30] of byte;          {!!2}
    pspseg : word;                            {!!2}
    junk3 : array[$33..$34] of byte;          {!!2}
  end;

  dos4openfilerec = record
    numhandles,
    openmode : word;
    junk1 : array[4..$1f] of byte;
    filename : array[$20..$2a] of char;
    junk2 : array[$2b..$30] of byte;         {!!2}
    pspseg : word;                           {!!2}
    junk3 : array[$33..$3a] of byte;         {!!2}
  end;

  filelistptr = ^filelistrec;
  filelistrec = record
    next : filelistptr;
    numfiles : word;
    case byte of
    2 : (dos2files : array[1..1] of dos2openfilerec);
   30 : (dos30files: array[1..1] of dos30openfilerec);  {!!2}
    3 : (dos3files : array[1..1] of dos3openfilerec);
    4 : (dos4files : array[1..1] of dos4openfilerec);
  end;

  Tfilename = String[12];

function NiceName(filename:TFilename):TFilename;
var
  result : string;
  blankpos : byte;
begin
  result := filename;
  insert('.',result,9);
  repeat
    blankpos := pos(' ',result);
    if blankpos > 0 then
      delete(result,blankpos,1);
  until blankpos = 0;
  NiceName := result;
end;

procedure WalkList(var where:text;C:PCollection;Action:pointer;frame:word);
  procedure Doit(filename:TFilename;openmode:word);
  var
    DoAction : procedure(f:string;openmode:word;dummy:word) absolute Action;
  begin
    filename := NiceName(filename);
    if C <> Nil then
      C^.Insert(NewStr(filename))
    else if Action <> Nil then
      DoAction(filename,openmode,frame)
    else
      writeln(where,filename);
  end;
var
  p : pointer;
  list : filelistptr;
  i : word;
begin
  GetPrefixSeg;                                                  {!!3}
  p := GetListOfLists;                                           {!!3}
  inc(longint(p),4);                                             {!!3}
  if ptrrec(p^).ofs <> $ffff then
    list := MakePointer(ptrrec(p^).seg,ptrrec(p^).ofs)           {!!3}
  else
    list := nil;
  releasePointer(p);                                             {!!3}

  while list <> nil do
  begin
    with list^ do
      for i:=1 to numfiles do
        case lo(dosversion) of
        2 : with dos2files[i] do
             if numhandles > 0 then
               doit(filename,openmode);                           {!!4}
        3 : if hi(dosversion) = 0 then                            {!!2}
            begin                                                 {!!2}
              with dos30files[i] do                               {!!2}
               if (numhandles > 0) and (allfiles or               {!!2}
                                        (pspseg = myprefixseg)) then{!!3}
                 doit(filename,openmode)                           {!!4}
            end                                                   {!!2}
            else                                                  {!!2}
              with dos3files[i] do
               if (numhandles > 0) and (allfiles or
                                        (pspseg = myprefixseg)) then{!!3}
                 doit(filename,openmode);                           {!!4}
     4..6 : with dos4files[i] do
             if (numhandles > 0) and (allfiles or                 {!!2}
                                      (pspseg = myprefixseg)) then  {!!3}
               doit(filename,openmode);                             {!!4}
        end;
    p := list;
    if ptrrec(list^.next).ofs <> $ffff then
      list := MakePointer(ptrrec(list^.next).seg,ptrrec(list^.next).ofs) {!!3}
    else
      list := nil;
    ReleasePointer(p);                                            {!!3}
  end;
  ReleasePointer(list);                                           {!!3}
end;

procedure print_open_files(var where:text);
{ Print open file list to given file }
begin
  WalkList(where,nil,nil,0);
end;

function get_open_files:PCollection;
{ Returns a new collection containing pointers to strings holding the
  filenames }
var
  result : PCollection;
  junk : text;
begin
  result := New(PCollection,init(16,16));
  if result <> nil then
    WalkList(junk,result,nil,0);
  get_open_files := result;
end;

function CallerFrame:word;
Inline(
  $8B/$46/$00/           {   MOV     AX,[BP]}
  $24/$FE);              {   AND     AL,$0FE}

procedure For_each_open_file(Action:pointer);
var
  junk : text;
begin
  WalkList(junk,nil,Action,CallerFrame);
end;

{$ifndef windows}  { We don't use an exitproc in Windows}

var
  exit_save : pointer;

procedure my_exit_proc; far;
var
  junk : word;
begin
  ExitProc := Exit_save;
  junk := ioresult;
  assign(output,'');
  rewrite(output);
  writeln('Files open as program terminates:');
  print_open_files(output);
end;
{$endif}

begin
  if not (lo(dosversion) in [2..6]) then
    writeln('OPENFILES only works with DOS 2 to 6')
{$ifndef Windows}
  else
  begin
    exit_save := ExitProc;
    ExitProc := @my_exit_proc;
  end
{$endif}
end.


{ ------------------    DEMO PROGRAM ----------------------- }

program test;

{ Test program for Openfiles unit.  Should be compilable in TP/BP 6+, TPW 1.5+ }

uses
{$ifdef windows}
  {$ifdef ver15}
  wincrt,wobjects,openfiles;
  {$else}
  wincrt,objects,openfiles;
  {$endif}
{$else}
  objects,openfiles;
{$endif}

{ This routine uses the callback function "for_each_open_file".  It's the
  only way to get the file open mode. }

procedure doit(prefix:string);
  procedure printone(f:string;openmode:word); far;
  begin
    writeln(prefix,f:12,' mode ',openmode);
  end;
begin
  for_each_open_file(@printone);
end;

{ This routine builds the collection of strings and prints it }

procedure doit2(prefix:string);
var
  c:Pcollection;

  { Print each filename }
  procedure printone(f:PString); far;
  begin
    writeln(prefix,f^);
  end;

  { Release each string }
  procedure disposeone(f:PString); far;
  begin
    DisposeStr(f);
  end;

begin
  c:=get_open_files;
  if c <> nil then
  begin
    c^.foreach(@printone);

    { This shows the proper way to dispose of the collection }

    c^.foreach(@disposeone);
    c^.deleteall;
    dispose(c,done);
  end;
end;

var
  f:file;
  i : longint;
begin
  assign(f,'test.pas');
  reset(f);
  allfiles := true;
  doit('Open by some process:  ');
  allfiles := false;
  doit2('Open by us:  ');

  { At the end, the exitproc will print one more list (in DOS). }
end.

