{
Desclin Jean <desclinj@ulb.ac.be>

 a few days ago (sorry, I didn't write down the name of the person
 who posted the question :-(), someone asked how one could
 identify a drive as a ramdisk.
 Below is a solution, which I submit with the hope that someone
 else could show how to improve on it, since it is not 'fail-safe'.
 Here it comes...

Modified after Michael Tischer: Turbo Pascal 6 System Programming
ABACUS Publisher Grand Rapids, MI 49512  1991 ISBN 1-55755-124-3
I had to write the procedure Getdrives twice in order to take into
account the changes in the DPB structure which occurred from DOS
4.0 onwards. Mostly, Ramdisks have only one File Allocation Table,
whereas other drive types have two. That's what a procedure such
as GetDiskClass of TurboPower Object Professional (usual disclaimer
here ;-)) uses to decide whether the drive is a ramdisk or not. BUT
BEWARE! This is not necessarily so! Norton mentions, in his 'disk
companion', that depending on the device driver of the ramdisk, one
or two FATS may be implemented. I could verify this on 'STACKED'
ramdisks: they have two FATS, whereas only one FAT is present after
'unSTACKING' :-(. Thus, the solution below is somewhat shaky.
}


program idramdsk;
uses
  Dos;

var
  ver : byte;

procedure GetDrives1;
type
  DPBPTR    = ^DPB;                 { pointer to a DOS Parameter Block }
  DPBPTRPTR = ^DPBPTR;              { pointer to a pointer to a DPB }
  DPB       = record                { recreation of a DOS Parameter Block }
    Code   : byte;                  { drive code (0=A, 1=B etc. }
    dummy1 : array [1..$07] of byte;{irrelevant bytes}
    FatNb  : byte;                  {Number of File Allocation Tables }
    dummy2 : array [9..$17] of byte;{irrelevant bytes}
    Next   : DPBPTR;                { pointer to next DPB }
  end;                              { xxxx:FFFF marks last DPB }

var
  Regs     : Registers;             { register for interrupt call }
  CurrDpbP : DPBPTR;                { pointer to DPBs in memory }

begin
  {-- get pointer to first DPB ------------------------------------}
  Regs.AH := $52; {function $52 returns ptr to DOS Information Block }
  MsDos(Regs);    {that's an UNDOCUMENTED DOS function !             }
  CurrDpbP := DPBPTRPTR(ptr(Regs.ES, Regs.BX))^;

  {-- follow the chain of DPBs--------------------------------------}
  repeat
    writeln(chr(ord('A') + CurrDpbP^.Code),     {display device code }
              ':(FATS: ', CurrDpbP^.FatNb,')'); {and number of FATs  }

    CurrDpbP := CurrDpbP^.Next;   { set pointer to next DPB        }
  until (Ofs(CurrDpbP^) = $FFFF);  { until last DPB is reached }
end;

procedure GetDrives2;
type
  DPBPTR    = ^DPB;                 { pointer to a DOS Parameter Block }
  DPBPTRPTR = ^DPBPTR;              { pointer to a pointer to a DPB }
  DPB       = record                { recreation of a DOS Parameter Block }
    Code   : byte;                  { drive code (0=A, 1=B etc. }
    dummy1 : array [1..$07] of byte;{irrelevant bytes}
    FatNb  : byte;                  { Number of File Allocation Tables}
    dummy2 : array [9..$18] of byte;{irrelevant bytes}
    Next   : DPBPTR;                { pointer to next DPB }
  end;                              { xxxx:FFFF marks last DPB }

var
  Regs     : Registers;             { register for interrupt call }
  CurrDpbP : DPBPTR;                { pointer to DPBs in memory }

begin
  {-- get pointer to first DPB-------------------------------------}
  Regs.AH := $52; {function $52 returns ptr to Dos Information Block }
  MsDos(Regs);    {that's an UNDOCUMENTED DOS function !             }
  CurrDpbP := DPBPTRPTR(ptr(Regs.ES, Regs.BX))^;

  {-- follow the chain of DPBs -------------------------------------}
  repeat
    {output device letter and number of FATs (1 for RAM disks)   }
    writeln(chr(ord('A') + CurrDpbP^.Code), ':(FATS: ', CurrDpbP^.FatNb, ')');
    CurrDpbP := CurrDpbP^.Next;    { set pointer to next DPB        }
  until (Ofs(CurrDpbP^) = $FFFF);  { until last DPB is reached }
end;

begin
  ver := Lo(DosVersion);
  writeln(#13#10'Installed drives: '#13#10);
  if ver < 4 then
    GetDrives1
  else
    GetDrives2
end.

