{
From: "CLAUS FISCHER" <WI00227@wipool.wifo.uni-mannheim.de>

I had found the Extend.Pas and PExted.pas on SWAG.
First provides 255 File in DOS, second in protcted mode.
Now I had mixed them together and I wish to give this to
SWAG. Where should I post this?

(*** 3 Files: ***)
 255DEMO.PAS  (Extend Version with StdErr)
 FILEPLUS.PAS (was EXTEND.PAS)
 DOSMEM.PAS   (was SHRINK.PAS)
{-------------------------------snipp--------------------------------}
  program Test255Files;

uses fileplus,       { <--- This is the magic line that does
everything }
     Dos;

const MaxCount = 255;

type FileArray = array[1..MaxCount] of text;

var Count: integer;
    StdErr: Text;
    F: ^FileArray;
    I: integer;
    Num: string[6];

procedure stderror(var f:text);
var
    tmpfile:text;
begin
  assign(tmpfile,''); (* stdoutput *)
  rewrite(tmpfile);
  move(tmpfile, f, sizeof(f));
  textrec(f).handle:= 2;
  close(tmpfile);
end;

begin
write('Hello!! I''m running under ');
{$IFDEF MSDOS}writeln('MsDos REAL-Mode');
{$ELSE} writeln('DPMI Protected Mode');
{$ENDIF}
new(F);            { Use heap because of large size of this array }
writeln('Opening files...');
Stderror(StdErr);
writeln( Stderr, '(Handle Stderr) ',TextRec(StdErr).Handle );
writeln( Output, '(Handle Stdout) ',TextRec(Output).Handle );
write( Output, '(Handle:FileNo) ');
I := 0;
repeat
  inc(I);
  str(I,Num);
  assign(F^[I],'junk' + num + '.txt');
  {$I-}
  rewrite(F^[I]);
  write( OutPut, i:4,':',TextRec(f^[i]).Handle );
  {$I+}
until ioresult <> 0;
writeln(output);
Count := I - 1;
writeln('Successfully opened ', Count, ' files at the same time.
Writing to each file...');
for I := 1 to Count do
  writeln(F^[I], 'This is a test.');
writeln('Closing and erasing each file...');
for I := 1 to Count do
  begin
  close(F^[I]);
  erase(F^[I])
  end;
writeln('Done.')
end.
{----------------------snapp----------------------------------------}

{---------------------snipp---------------------------------------}
{$I-,O-,R-}

unit fileplus; {origin name Extend}

{Patch V1.0 94-12 Claus Fischer for}
{REF: MsDos-Real-Mode: Scott Bussinger}
{     DPMI:          : Kim Kokkonen, TurboPower Software}
{     catched up on SIMTEL-Archieve and SWAG-List}

{FILEPLUS Patch Claus Fischer}
{ Changes:
  Main feater: Use Real-Mode and DPMI-Mode with the same Unit.
  I have disabled DOS 2.xx Management because its not necessary for
me.
  The SHRINK-Unit is now named as DosMem.Pas.
  The futur check of MSDOS-Version is removed, because further MSDOS
vers
  will shure support the prefix features. The market use this.
  The DPMIExtendHandles-Function was changed to Procedure, so its
equal
  to MSDOSExtendHandles (not neccesary, but looks pretty).
  Claus Fischer
  WI00227@WIPOOL.WIFO.UNI-MANNHEIM.DE
}

{EXTEND Version Scott Bussinger}
{ This unit allows a program to open more than the standard DOS
maximum of 20
  open files at one time.  You must also be sure to set a FILES=XX
statement
  in your CONFIG.SYS file.
  (DISABLED: This program installs a special interrupt handler
         under DOS 2.x, some semi-documented features under
         DOS 3.x prior to DOS 3.3 and the DOS extend files
         call under DOS 3.3 or later. C.F.)
  This unit USES the DOS unit and should be used BEFOR ANY OTHER UNTIS
  other than the DOS unit.  This code was based upon earlier work by
  Randy Forgaard, Bela Lubkin and Kim Kokkonen.  See EXTEND.DOC for
  more information.

  Scott Bussinger
  Professional Practice Systems
  110 South 131st Street
  Tacoma, WA  98444
  (206)531-8944
  Compuserve [72247,2671] }

{ ** Revision History **
  1 EXTEND.PAS 9-Mar-89,`SCOTT' First version using TLIB -- Based on
3.2
  2 EXTEND.PAS 15-Sep-89,`SCOTT'
       Added SwapVectorsExtend procedure
           Put handle table into DOS memory
       Use DOS 3.3 extended handles function when available
  3 EXTEND.PAS 2-Oct-89,`SCOTT'
       Fixed bug in determining the DOS version
  4 EXTEND.PAS 5-Oct-89,`SCOTT'
           Yet another bug in the DosVersion detection
  5 EXTEND.PAS 19-Nov-90,`SCOTT'
           New version of EXTEND that is compatible with Turbo Pascal
6.0
       Modified the documentation and version numbers to be less
confusing
  ** Revision History ** }

{PEXTEND    DPMI-Version Kim Kokkonen
 ------------------------------------------------------------------
 This unit provides a single function, DpmiExtendHandles, for
 extending the file handle table for DOS protected mode applications
 under Borland Pascal 7.0.

 The standard DOS call for this purpose (AH = $67) does odd things to
 DOS memory when run from a BP7 pmode program. If you Exec from a
 program that has extended the handle table, DOS memory will be
 fragmented, leaving a stranded block of almost 64K at the top of DOS
 memory. The function implemented here avoids this problem.

 If you haven't used an ExtendHandles function before, note that you
 cannot get more handles than the FILES= statement in CONFIG.SYS
 allows. (Other utilities such as FILES.COM provided with QEMM do the
 same thing.) However, even if you have FILES=255, any single program
 cannot open more than 20 files (and DOS uses up 5 of those) unless
 you use a routine like DpmiExtendHandles. This routine allows up to
 255 open files as long as the FILES= statement provides for them.

 This code works only for DOS 3.0 or later. Since (to my knowledge)
 DPMI cannot be used with earlier versions of DOS, the code doesn't
 check the DOS version.

 Don't call this function more than once in the same program.

 Version 1.0,
   Written 12/15/92, Kim Kokkonen, TurboPower Software
}

interface

(* delted(0) of Dos 2.11 Version-Managament *)
(* procedure SwapVectorsExtend;
  { Swap interrupt vectors taken over by Extend unit with system
vectors }
*)
(* END of delted(0) *)

implementation

uses Dos,
     {$IFDEF MSDOS} DosMem;
     {$ELSE}        WinApi;
     {$ENDIF}

(* deleted(1) DOS 2.11 Ver ... *)
(* var ExitSave: pointer;                           { Previous exit
procedure }
    OldInt21: pointer;                           { Save old INT 21 }
*)
(* END of delted(1) *)

(* Deleted(2) ...   DOS 2.11 Ver *)
(*
{$L EXTEND }
procedure ExtendInit; external;                  { Initialize
interrupt handler }
procedure ExtendHandler; external;               { Replacement INT 21
handler }
*)
(* End of delted(2) *)

(* ... deleted(3) DOS 2.11 Ver.... *)
(*
procedure SwapVectorsExtend;
  { Swap interrupt vectors taken over by Extend unit with system
vectors }
  var TempVector: pointer;
  begin
  if lo(DosVersion) = 2 then
    begin
    GetIntVec($21,TempVector);                   { Swap the INT 21
vectors }
    SetIntVec($21,OldInt21);
    OldInt21 := TempVector
    end
  end;
*)
(* END of Deleted(3) *)


{$IFDEF MSDOS}
procedure MSDOSExtendHandles;
(* My Patch of MSDOS Scott Bussinger Version *)
  { Install the extended handles interrupt.  No files (other than
    standard handles) should be open when unit starts up. }

type   HandleArray = array[0..254] of byte;        { Room for 255
handles }
       HandleArrayPtr = ^HandleArray;

  var Regs: Registers;
      DosMemory: pointer;                          { Pointer to
memory gained from DOS }
      OldHandleTable: HandleArrayPtr;              { Pointer to
original table }
      OldNumHandles: byte;                         { Original number
of handles }
  begin

  if lo(DosVersion) <= 2
   then {Patch KISS!} exit;

  (* deleted(4) DOS 2.11 ..... *)
  (*
    begin
    GetIntVec($21,OldInt21);                     { Install interrupt
handler under DOS 2.x }
    ExtendInit;                                  { Initialize the
interrupt handler }
    SetIntVec($21,@ExtendHandler)
    end
   else
   *)
   (* END of deleted(4) *)

   (* deleted(5) schnick-schnack: MickySoft will support further *)
   (*
      if (lo(DosVersion)>=4) or (hi(DosVersion)>=30) { Does this DOS
version support the handles call? }
       then
        begin
    DosDispose(DosMemory);                   { Free up the DOS memory
block so that the next function will succeed }
    with Regs do
          begin
          AH := $67;                             { Tell DOS to allow
us 255 handles }
          BX := 255;                             { KEEP THIS NUMBER
ODD TO AVOID BUG IN SOME VERSIONS OF DOS 3.3!! }
          MsDos(Regs)
      end
    end
       else  begin
   *)
   (* END of delted(5) *)


   DosNewShrink(DosMemory,sizeof(HandleArray));
   if DosMemory = nil then exit;
       { There wasn't enough memory for a handle table, so just quit }
   begin {else}

    { Initialize new handles as unused          *1* }
    { Get old table length                  *2* }
    { Save address of old table                 *3* }
    { Set new table length                  *4* }
    { Point to new handle table                 *5* }
    { Copy the current handle table to the new handle table *6* }

    fillchar(DosMemory^,sizeof(HandleArray),$FF);          (*1*)
    OldNumHandles := mem[prefixseg:$0032];                 (*2*)
    OldHandleTable := pointer(ptr(prefixseg,$0034)^);      (*3*)
    mem[prefixseg:$0032] := sizeof(HandleArray);           (*4*)
    pointer(meml[prefixseg:$0034]) := DosMemory;           (*5*)
    move(OldHandleTable^,DosMemory^,OldNumHandles)         (*6*)
   end
  end; (* of MSDOSExtenHandles *)
{$ENDIF} {of IFDEF MSDOS}

{$IFNDEF MSDOS} {.= WINAPI}
procedure DPMIExtendHandles;
   const Handles = 255; (* added *)
(* My Patch of MSDOS Kim Kokkonen Version *)
(* Orginal was: function DpmiExtendHandles(Handles : Byte) : Word; *)
  type DosMemRec = record
            Sele, Segm : Word;
           end;
   var
    OldTable : Pointer;
    OldSize : Word;
    NewTable : Pointer;
    DosMem : DosMemRec;
  begin
     (* DEL: DpmiExtendHandles := 0; PROCEDURE replaced *)
     (* DEL: if Handles <= 20 then Exit; CONST replaced *)

     {Allocate new table area in DOS memory}
     LongInt(DosMem) := GlobalDosAlloc(Handles);
     if LongInt(DosMem) = 0 then
    exit; (* add *)

      (* DEL: begin DpmiExtendHandles := 8;Exit; end; PROCEDURE
replaced *)

      {Initialize new table with closed handles}
    NewTable := Ptr(DosMem.Sele, 0);(*1*)
    FillChar(NewTable^, Handles, $FF);(*1*)

      {Copy old table to new. Assume old table in PrefixSeg}
    OldTable := Ptr(PrefixSeg, MemW[PrefixSeg:$34]);
    OldSize := Mem[PrefixSeg:$32];
    move(OldTable^, NewTable^, OldSize);

      {Set new handle table size and pointer}
    Mem[PrefixSeg:$32] := Handles;
    MemW[PrefixSeg:$34] := 0;
    MemW[PrefixSeg:$36] := DosMem.Segm;
  end; (* of DPMIExtendHandles *)
{$ENDIF} {of IFNDEF MSDOS}


(* deleted(6) DOS 2.11 Ver ... *)
(*
{$F+}
procedure ExitHandler;
{$F-}
  { Uninstall the extended handles interrupt.  All files (other
    than standard handles) should be closed before unit exits. }
  begin
  ExitProc := ExitSave;                          { Chain to next exit
routine }
  SwapVectorsExtend                              { Restore original
interrupt vectors }
  end;
*)
(* END of delted(6) *)

begin (* of Install *)
(* deleted(7) DosVer 2.11 ... *)
(* ExitSave := ExitProc;                            { Remember the
previous exit routine }
   ExitProc := @ExitHandler;  { Install our exit routine }
*)
(* END of delted(7) *)


{$IFDEF MSDOS}
  MSDOSExtendHandles; { Enable the extra handles }
{$ELSE}
  DPMIExtendHandles;
{$ENDIF}
end.
{-------------------------------snapp--------------------------------}

{-------------------------------snipp-------------------------------}
unit DosMem;

{$IFDEF DPMI}  *** Only Real-Mode! *** {$ENDIF}
{$IFDEF WINDOWS} *** Only Dos-Real-Mode *** {$ENDIF}
{$IFDEF OS2} *** Only Dos-Real-Mode *** {$ENDIF}

{ This unit allows you to allocate memory from the DOS memory pool
rather than
  from the Turbo Pascal heap.  It also provides a procedure for
shrinking the
  current program to free up DOS memory.

  Scott Bussinger
  Professional Practice Systems
  110 South 131st Street
  Tacoma, WA  98444
  (206)531-8944
  Compuserve [72247,2671] }

{ ** Revision History **
  1 SHRINK.PAS 15-Sep-89,`SCOTT' Initial version of SHRINK unit
  2 SHRINK.PAS 19-Oct-90,`SCOTT'
       Added support for Turbo Pascal 6's new heap manager
  ** Revision History ** }

interface

procedure DosNew(var P: pointer;
                     Bytes: word);
  { Get a pointer to a chunk of memory from DOS.  Returns NIL if
    sufficient DOS memory is not available. }

procedure DosDispose(var P: pointer);
  { Return an allocated chunk of memory to DOS.  Only call this
function
    with pointers allocated with DosNew or DosNewShrink. }

procedure DosNewShrink(var P: pointer;
                           Bytes: word);
  { Get a pointer to a chunk of memory from DOS, shrinking current
program
    to gain DOS memory if necessary.  Returns NIL if sufficient DOS
memory
    is not available and there is insufficient free space in the heap
to
    allow program to be shrunk to accomodate the request. }

function Linear(P: pointer): longint;
  { Return the pointer as a linear longint value }

implementation

uses Dos;

const DosOverhead = 1;                           { Extra number of
paragraphs that DOS requires in overhead for MCB chain }

function Linear(P: pointer): longint;
  { Return the pointer as a linear longint value }
  begin
  Linear := (longint(seg(P^)) shl 4) + ofs(P^)
  end;

procedure DosNew(var P: pointer;
                     Bytes: word);
  { Get a pointer to a chunk of memory from DOS.  Returns NIL if
    sufficient DOS memory is not available. }
  var SegsToAllocate: word;
      Regs: Registers;
  begin
  SegsToAllocate := (Bytes+15) shr 4;            { DOS allocates
memory in paragraph sized pieces only }
  with Regs do
    begin
    AH := $48;
    BX := SegsToAllocate;
    MsDos(Regs);
    if odd(Flags)
     then
      P := nil                                   { No memory
available }
     else
      P := ptr(AX,$0000)                         { Return pointer to
memory block }
    end
  end;

procedure DosDispose(var P: pointer);
  { Return an allocated chunk of memory to DOS.  Only call this
function
    with pointers allocated with DosNew or DosNewShrink. }
  var Regs: Registers;
  begin
  with Regs do
    begin
    AH := $49;
    ES := seg(P^);
    MsDos(Regs)
    end
  end;

procedure DosNewShrink(var P: pointer;
                           Bytes: word);
  { Get a pointer to a chunk of memory from DOS, shrinking current
program
    to gain DOS memory if necessary.  Returns NIL if sufficient DOS
memory
    is not available and there is insufficient free space in the heap
to
    allow program to be shrunk to accomodate the request. }
  var BytesToAllocate: word;
      Regs: Registers;
  begin
  BytesToAllocate := (((Bytes+15) shr 4) + DosOverhead) shl 4;
  DosNew(P,Bytes);
  { Try to get memory the easy way first }

  {$IFDEF VER60} {$DEFINE NEWHEAP} {$ENDIF}
  {$IFDEF VER70} {$DEFINE NEWHEAP} {$ENDIF}

  {$IFDEF NEWHEAP}
  { Check for Turbo 6's new heap manager }
  if (P=nil) and (Linear(HeapEnd)-Linear(HeapPtr)>=BytesToAllocate)
then
    begin
    { The easy method didn't work but there is sufficient space in
the heap }
    dec(longint(HeapEnd),longint(BytesToAllocate) shl 12);
    { Move the top of the heap down }

    with Regs do
      begin
      AH := $4A;
      BX := seg(HeapEnd^) - prefixseg - (BytesToAllocate shr 4);
      ES := prefixseg;
      MsDos(Regs)
      end;
    DosNew(P,Bytes)
    { Try the DOS allocation one more time }
    end
  {$ELSE}
  if (P=nil) and
  { Handle the old free list style heap }
     (  ( (ofs(FreePtr^)=0)
      and (Linear(FreePtr)+$10000-Linear(HeapPtr)>=BytesToAllocate)
    ) or
    (
     (ofs(FreePtr^)<>0)
      and (Linear(FreePtr)-Linear(HeapPtr)>=BytesToAllocate)
     )  )
     then
    begin
    { The easy method didn't work but there is sufficient space in
the heap }
    OldFreePtr := FreePtr;
    dec(longint(FreePtr),longint(BytesToAllocate) shl 12);
    { Decrement the segment of the pointer to the free list }

    if ofs(OldFreePtr^) <> 0 then
    { If free list is empty, then there's nothing to move }
      move(OldFreePtr^,FreePtr^,$10000-ofs(OldFreePtr^));
      { Otherwise, move the free list down in memory }

    with Regs do
      begin
      AH := $4A;
      BX := seg(OldFreePtr^) + $1000 - prefixseg - (BytesToAllocate
shr 4);
      ES := prefixseg;
      MsDos(Regs)
      end;
    DosNew(P,Bytes)                              { Try the DOS
allocation one more time }
    end
  {$ENDIF}
  {$IFDEF NEWHEAP}{$UNDEF NEWHEAP}{$ENDIF}
  end;

end.
