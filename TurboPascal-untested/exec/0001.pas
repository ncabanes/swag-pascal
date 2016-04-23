(* This unit lets you execute any child program and redirect the
   child program output to NUL / PRN / CON or file.
   It's very simple to use (look at the EXAMPLE.PAS).
   This source is completlly freeware but make sure to remove
   this remark if any changes are made I don't want anyone to
   spread his bugs with my source.
   Of course any suggestions are welcome as well as questions
   about the source.

   Written by Schwartz Gabriel.   20/03/1993.
   Anyone who has any question can leave me a message at 
   CompuServe to EliaShim address 100320,36
*)

{$A+,B-,D-,E-,F+,G-,I-,L-,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y+}

Unit Redir;

Interface

Var
  IOStatus      : Integer;
  RedirError    : Integer;
  ExecuteResult : Word;

{------------------------------------------------------------------------------}
procedure Execute (ProgName, ComLine, Redir: String);
{------------------------------------------------------------------------------}

Implementation

Uses DOS;

Type
  PMCB = ^TMCB;
  TMCB = record
           Typ   : Char;
           Owner : Word;
           Size  : Word;
         end;

  PtrRec = record
             Ofs, Seg : Word;
           end;

  THeader = record
              Signature : Word;
              PartPag   : Word;
              PageCnt   : Word;
              ReloCnt   : Word;
              HdrSize   : Word;
              MinMem    : Word;
              MaxMem    : Word;
              ReloSS    : Word;
              ExeSP     : Word;
              ChkSum    : Word;
              ExeIP     : Word;
              ReloCS    : Word;
              TablOff   : Word;
              OverNo    : Word;
            end;

Var
  PrefSeg      : Word;
  MinBlockSize : Word;
  MCB          : PMCB;
  FName        : PathStr;
  F            : File;
  MyBlockSize  : Word;
  Header       : THeader;

{------------------------------------------------------------------------------}

procedure Execute (ProgName, ComLine, Redir: String);

type
  PHandles = ^THandles;
  THandles = Array [Byte] of Byte;

  PWord = ^Word;

var
  RedirChanged : Boolean;
  Handles      : PHandles;
  OldHandle    : Byte;

  {............................................................................}

  function ChangeRedir : Boolean;

  begin
    ChangeRedir:=False;
    If Redir = '' then Exit;
    Assign (F, Redir);
    Rewrite (F);
    RedirError:=IOResult;
    If IOStatus <> 0 then Exit;
    Handles:=Ptr (PrefixSeg, PWord (Ptr (PrefixSeg, $34))^);
    OldHandle:=Handles^[1];
    Handles^[1]:=Handles^[FileRec (F).Handle];
    ChangeRedir:=True;
  end;

  {............................................................................}

  procedure CompactHeap;

  var
    Regs : Registers;

  begin
    Regs.AH:=$4A;
    Regs.ES:=PrefSeg;
    Regs.BX:=MinBlockSize + (PtrRec (HeapPtr).Seg - PtrRec (HeapOrg).Seg);
    MsDos (Regs);
  end;

  {............................................................................}

  procedure DosExecute;

  Begin
    SwapVectors;
    Exec (ProgName, ComLine);
    IOStatus:=DosError;
    ExecuteResult:=DosExitCode;
    SwapVectors;
  End;

  {............................................................................}

  procedure ExpandHeap;

  var
    Regs : Registers;

  begin
    Regs.AH:=$4A;
    Regs.ES:=PrefSeg;
    Regs.BX:=MyBlockSize;
    MsDos (Regs);
  end;

  {............................................................................}

  procedure RestoreRedir;

  begin
    If not RedirChanged then Exit;
    Handles^[1]:=OldHandle;
    Close (F);
  end;

  {............................................................................}

Begin
  RedirError:=0;
  RedirChanged:=ChangeRedir;
  CompactHeap;
  DosExecute;
  Expandheap;
  RestoreRedir;
End;

{------------------------------------------------------------------------------}

Begin
  SetCBreak (False);
  FName:=ParamStr (0);
  Assign (F, FName);
  Reset (F, 1);
  IOStatus:=IOResult;
  If IOStatus = 0 then
    begin
      BlockRead (F, Header, SizeOf (Header));
      IOStatus:=IOResult;
      If IOStatus = 0 then MinBlockSize:=Header.PageCnt * 32 + Header.MinMem + 1
      Else MinBlockSize:=$8000;
      Close (F);
    end
  Else MinBlockSize:=$8000;
  PtrRec (MCB).Seg:=PrefixSeg - 1;
  PtrRec (MCB).Ofs:=$0000;
  MyBlockSize:=MCB^.Size;
  PrefSeg:=PrefixSeg;
End.
