{$R-,S-}

{PEXTEND
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

{$IFNDEF DPMI}
  !! Error: this unit for DPMI applications only
{$ENDIF}

unit PExtend;
  {-Extend handle table for DOS protected mode applications}

interface

function DpmiExtendHandles(Handles : Byte) : Word;
  {-Extend handle table to Handles size.
    Returns 0 for success, else a DOS error code.
    Does nothing and returns 0 if Handles <= 20.}

implementation

uses
  WinApi;

function DpmiExtendHandles(Handles : Byte) : Word;
type
  DosMemRec =
    record
      Sele, Segm : Word;
    end;
var
  OldTable : Pointer;
  OldSize : Word;
  NewTable : Pointer;
  DosMem : DosMemRec;
begin
  DpmiExtendHandles := 0;
  if Handles <= 20 then
    Exit;

  {Allocate new table area in DOS memory}
  LongInt(DosMem) := GlobalDosAlloc(Handles);
  if LongInt(DosMem) = 0 then begin
    DpmiExtendHandles := 8;
    Exit;
  end;

  {Initialize new table with closed handles}
  NewTable := Ptr(DosMem.Sele, 0);
  FillChar(NewTable^, Handles, $FF);

  {Copy old table to new. Assume old table in PrefixSeg}
  OldTable := Ptr(PrefixSeg, MemW[PrefixSeg:$34]);
  OldSize := Mem[PrefixSeg:$32];
  move(OldTable^, NewTable^, OldSize);

  {Set new handle table size and pointer}
  Mem[PrefixSeg:$32] := Handles;
  MemW[PrefixSeg:$34] := 0;
  MemW[PrefixSeg:$36] := DosMem.Segm;
end;

end.
