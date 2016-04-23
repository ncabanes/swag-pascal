{
            ╔══════════════════════════════════════════════════╗
            ║     ┌╦═══╦┐┌╦═══╦┐┌╦═══╦┐┌╦═╗ ╦┐┌╦═══╦┐┌╔═╦═╗┐   ║
            ║     │╠═══╩┘├╬═══╬┤└╩═══╦┐│║ ║ ║│├╬══      ║      ║
            ║     └╩     └╩   ╩┘└╩═══╩┘└╩ ╚═╩┘└╩═══╩┘   ╩      ║
            ║                                                  ║
            ║     NetWare 3.11 API Library for Turbo Pascal    ║
            ║                      by                          ║
            ║                S.Perevoznik                      ║
            ║                     1996                         ║
            ╚══════════════════════════════════════════════════╝
}
Unit NetLock;

Interface

Uses NetConv;


Const

  cReg  = 0;
  cFull = 1;
  cRead = 3;



Procedure ReleasePhysicalRecordSet;


Procedure ClearPhysicalRecordSet;


Function ClearPhysicalRecord (FileName : string;
                              RecordStartOffset,
                              RecordLength  : LongInt) : byte;


Function ReleasePhysicalRecord (FileName : string;
                                RecordStartOffset,
                                RecordLength  : LongInt) : byte;


Function  LockPhysicalRecordSet(LockDirective : byte;
                                TimeOutLimit : word ) : byte;


Function  LogPhysicalRecord(FileName : string;
                            RecordStartOffset,
                            RecordLength  : LongInt;
                            LockDirective : byte;
                            TimeOutLimit  : word) : byte;




Function LockFileSet(LockDirective : byte;
                     TimeOutLimit  : word) : byte;


Procedure ReleaseFileSet;


Procedure ClearFileSet;


Function LogFile(FileName : string;
                 LockDirective : byte;
                 TimeOutLimit : word) : byte;


Function ClearFile(FileName : string) : byte;


Function ReleaseFile(FileName : string) : byte;




Procedure SetLockMode(mode : byte);


Function  GetLockMode : byte;


{-----------------------------------------------------------}

Implementation

Uses DOS;



Procedure ReleasePhysicalRecordSet;

var
  r : registers;
Begin
  r.AH := $C3;
  Intr($21,r);
End;

Procedure ClearPhysicalRecordSet;

var
  r : registers;
Begin
  r.AH := $C4;
  intr($21,r);
End;

Function ClearPhysicalRecord (FileName : string;
                              RecordStartOffset,
                              RecordLength  : LongInt) : byte;

var
  r : registers;
  FileHandle : word;
Begin
  r.AH := $3D;
  r.DS := SEG(FileName[1]);
  r.DX := OFS(FileName[1]);
  r.AL := 0;
  FileName[length(FileName)+1] := chr(0);
  intr($21,r);
  if (r.FLAGS and FCARRY ) = 0 then
    begin
      FileHandle := r.AX;
      r.AH := $BE;
      r.BX := FileHandle;
      Long2Int(RecordStartOffset,r.DX,r.CX);
      Long2Int(RecordLength,r.DI,r.SI);
      intr($21,r);
      ClearPhysicalRecord := r.AL;
    end
  else
    ClearPhysicalRecord := $80;

End;

Function ReleasePhysicalRecord (FileName : string;
                                RecordStartOffset,
                                RecordLength  : LongInt) : byte;

var
  r : registers;
  FileHandle : word;
Begin
  r.AH := $3D;
  r.DS := SEG(FileName[1]);
  r.DX := OFS(FileName[1]);
  r.AL := 0;
  FileName[length(FileName)+1] := chr(0);
  intr($21,r);
  if (r.FLAGS and FCARRY ) = 0 then
    begin
      FileHandle := r.AX;
      r.AH := $BD;
      r.BX := FileHandle;
      Long2Int(RecordStartOffset,r.DX,r.CX);
      Long2Int(RecordLength,r.DI,r.SI);
      intr($21,r);
      ReleasePhysicalRecord := r.AL;
    end
  else
    ReleasePhysicalRecord := $80;

End;

Function  LockPhysicalRecordSet(LockDirective : byte;
                                TimeOutLimit : word ) : byte;

var
  r : registers;
Begin
  r.AH := $C2;
  r.AL := LockDirective;
  r.BP := TimeOutLimit;
  intr($21,r);
  LockPhysicalRecordSet := r.AL;
End;

Function  LogPhysicalRecord(FileName : string;
                            RecordStartOffset,
                            RecordLength  : LongInt;
                            LockDirective : byte;
                            TimeOutLimit  : word) : byte;

var
  r : registers;
  FileHandle : word;
Begin
  r.AH := $3D;
  r.DS := SEG(FileName[1]);
  r.DX := OFS(FileName[1]);
  r.AL := 0;
  FileName[length(FileName)+1] := chr(0);
  intr($21,r);
  if (r.FLAGS and FCARRY ) = 0 then
    begin
      FileHandle := r.AX;
      r.AH := $BC;
      r.BX := FileHandle;
      Long2Int(RecordStartOffset,r.DX,r.CX);
      Long2Int(RecordLength,r.DI,r.SI);

      r.AL := LockDirective;
      r.BP := TimeOutLimit;
      intr($21,r);
      LogPhysicalRecord := r.AL;
      R.AH := $3E;
      R.BX := FileHandle;
      Intr($21,R);
    end
  else
    LogPhysicalRecord := $80;
End;



Function LockFileSet(LockDirective : byte;
                     TimeOutLimit  : word) : byte;

var
  r : registers;
Begin
  r.AH := $CB;
  r.bp := TimeOutLimit;
  r.AL := LockDirective;
  intr($21,r);
  LockFileSet := r.AL;
End;

Procedure ReleaseFileSet;

var
  r : registers;
Begin
  r.AH := $CD;
  intr($21,r);
End;

Procedure ClearFileSet;

var
  r : registers;
Begin
  r.AH := $CF;
  intr($21,r);
End;

Function LogFile(FileName : string;
                 LockDirective : byte;
                 TimeOutLimit : word) : byte;

var
  r : registers;
Begin
  r.AH := $EB;
  r.BP := TimeOutLimit;
  r.AL := LockDirective;
  r.DS := SEG(FileName[1]);
  r.DX := OFS(FileName[1]);
  FileName[length(FileName)+1] := chr(0);
  intr($21,r);
  LogFile := r.AL;

End;

Function ClearFile(FileName : string) : byte;


var
  r : registers;
Begin
  r.AH := $ED;
  r.DS := SEG(FileName[1]);
  r.DX := OFS(FileName[1]);
  FileName[length(FileName)+1] := chr(0);
  intr($21,r);
  ClearFile := r.AL;
End;

Function ReleaseFile(FileName : string) : byte;


var
  r : registers;
Begin
  r.AH := $EC;
  r.DS := SEG(FileName[1]);
  r.DX := OFS(FileName[1]);
  FileName[length(FileName)+1] := chr(0);
  intr($21,r);
  ReleaseFile := r.AL;
End;



Procedure SetLockMode(mode : byte);

var
  r : registers;
Begin
   r.AH := $C6;
   r.AL := Mode;
   intr($21,r);
End;

Function  GetLockMode : byte;

var
  r : registers;
Begin
  r.AH := $C6;
  r.AL := $02;
  intr($21,r);
  GetLockMode := r.AL;
End;

end.
