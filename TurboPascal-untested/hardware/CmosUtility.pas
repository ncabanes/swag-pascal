(*
  Category: SWAG Title: HARDWARE DETECTION
  Original name: 0041.PAS
  Description: CMOS Utility
  Author: SWAG SUPPORT TEAM
  Date: 11-26-94  05:09
*)

program Mem10;

uses
  Crt,
  Dos;

const
  Max = $63;

type
  TCmos = array[0..Max] of Byte;

var
  Num, Info, j: Byte;
  i: LongInt;
  Cmos: TCmos;
  F: File of TCmos;

procedure WriteCmos;
begin
  Num := 0;
  for i := 0 to Max do begin
    asm
      xor ax, ax
      mov al, Num
      out 70h, al
      in  al, 71h
      mov Info, al
    end;
    Cmos[Num] := Info;
    Inc(Num);
  end;

  Assign(F, 'Cmos.Dta');
  Rewrite(F);
  Write(F, Cmos);
  Close(F);
end;

procedure OpenFile;
begin
  {$I-}
  Assign(F, 'Cmos.Dta');
  Reset(F);
  Read(F, Cmos);
  Close(F);
  {$I+}
  if IOResult <> 0 then begin
    WriteLn;
    WriteLn('Could not find CMOS.DTA');
    Halt(1);
  end;
end;

procedure RestoreCmos;
begin
  OpenFile;
  for j := 0 to Max do begin
    Info := Cmos[j];
    asm
      xor ax, ax
      mov al, j
      out 70h, al
      mov al, Info
      out  71h, al
    end;
  end;
end;

procedure Help;
begin
  WriteLn;
  WriteLn('This program can save the values from your CMOS to');
  WriteLn('disk file and then restore them again later.');
  WriteLn('This is helpful if your CMOS gets trashed either');
  WriteLn('because the clock battery dies or because it was');
  WriteLn('accidentally overwritten.');
  WriteLn;
  WriteLn('To use this program, first save the current CMOS');
  WriteLn('to disk by choosing save from the program menu.');
  WriteLn('This creates a file called CMOS.DTA. Don''t lose it.');
  WriteLn('Later, if you have problems, you can restore');
  WriteLn('the CMOS by choosing Restore from the menu,');
  WriteLn('so long as CMOS.DTA is still available.');
end;

procedure FlushKeyBuffer;
var
  Recpack : registers;
begin
  with recpack do begin
    Ax := ($0c shl 8) or 6;
    Dx := $00ff;
  end;
  Intr($21,recpack);
end;

var
  ch: Char;

begin
  ClrScr;
  FlushKeyBuffer;
  WriteLn('A) Restore cmos');
  WriteLn('B) Save cmos');
  WriteLn('C) Help');
  WriteLn('Q) Quit');
  repeat
    ch := UpCase(ReadKey);
  until ch in ['A', 'B', 'C', 'Q'];

  case ch of
    'A': RestoreCmos;
    'B': WriteCmos;
    'C': Help;
    'Q':;
  end;
end.
