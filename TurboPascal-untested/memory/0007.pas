{
>  Well is there a way to find out if Norton Cache is installed?

Test For SmartDrv.* , HyperDsk only.    ! Others Untested !
}

Program IsThereAnyCache;
Uses
  Dos;

Const
  AktCache   : Byte = 0;
  CacheNames : Array[0..10] of String[25] = (
     '*NO* Disk-Cache found','SmartDrv.Exe','SmartDrv.Sys',
     'Compaq SysPro','PC-Cache V6.x','PC-Cache V5.x',
     'HyperDsk ?', 'NCache-F','NCache-S',
     'IBMCache.Sys','Q-Cache (?)');

Var
  Version : Integer;
  Regs    : Registers;

Function SmartDrvVersion:Integer;
Var
  Bytes : Array[0..$27] of Byte; { return Buffer }
  TFile : Text;
begin
  SmartDrvVersion := -1;  { assume NO smartdrv ! }
  {--------Check For SmartDrv.EXE---------- }
  FillChar( Regs, Sizeof(Regs), 0 );
  Regs.AX := $4A10;  { install-check }
  Intr( $2F, Regs );
  if Regs.FLAGS and FCARRY = 0 then  { OK! }
  begin
    if Regs.AX = $BABE then          { the MAGIC-# }
    begin
      SmartDrvVersion := Integer(Regs.BP);
      AktCache := 1;
      Exit;
    end;
  end;
  { -------Check For SmartDrv.SYS----------- }
  Assign(TFile,'SMARTAAR');
  {$I-}
  Reset(TFile);
  {$I+}
  if IOResult <> 0 then
    Exit; { No SmartDrv }
  FillChar( Regs, Sizeof(Regs), 0 );
  Regs.AX := $4402; { IoCtl }
  Regs.BX := TextRec(TFile).Handle;
  Regs.CX := Sizeof(Bytes);
  Regs.DS := Seg(Bytes);
  Regs.DX := Ofs(Bytes);
  MsDos(Regs); { int 21h }
  Close(TFile);
  if Regs.FLAGS and FCARRY <> 0 then
    Exit;  { Error-# in Regs.AX ...}
  SmartDrvVersion :=  Bytes[$E] + 256 * Bytes[$F];
  AktCache := 2;
end;

Function CompaqPro : Integer;
begin
  CompaqPro := -1;
  Regs.AX := $F400;
  Intr($16, Regs);
  if Regs.AH <> $E2 then
    Exit;
  if Regs.AL in[1,2] then
    AktCache := 3;
  CompaqPro := $100;
end;

Function PC6 : Integer;   { PCTools v6, v5 }
begin
  PC6 := -1;
  Regs.AX := $FFA5;
  Regs.CX := $1111;
  Intr($16, Regs);
  if Regs.CH <> 0 then
    Exit;
  PC6 := $600;
  AktCache := 4;
end;

Function PC5 : Integer;
begin
  PC5 := -1;
  Regs.AH := $2B;
  Regs.CX := $4358; {'CX'}
  Intr($21, Regs);
  if Regs.AL <> 0 then
    Exit;
  PC5 := $500;
  AktCache := 5;
end;

Function HyperDsk : Integer;   { 4.20+ ... }
begin
  Hyperdsk:= -1;
  Regs.AX := $DF00;
  Regs.BX := $4448; {'DH'}
  Intr($2F, Regs);
  if Regs.AL <> $FF   then
    Exit;
  if Regs.CX <> $5948 then
    Exit; { not a "Hyper" product }
  HyperDsk := Regs.DX;
  AktCache := 6;
end;

Function Norton : Integer;
begin
  Norton := -1;
  Regs.AX := $FE00;
  Regs.DI := $4E55; {'NU'}
  Regs.SI := $4353; {'CS' test For Ncache-S v5 }
  Intr($2F, Regs);
  if Regs.AH = $00 then
  begin
    Norton := $500;
    AktCache := 7;
    Exit;
  end;
  { Test For Ncache-F v5 / v6 }
  Regs.AX := $FE00;
  Regs.DI := $4E55; {'NU'}
  Regs.SI := $4353; {'CF' test For Ncache-F v5, V6+ }
  Intr($2F, Regs);
  if Regs.AH <> $00 then
    Exit;
  Norton := $600;
  AktCache := 8;
end;

Function IBM : Integer;
begin
  IBM:= -1;
  Regs.AX := $1D01;
  Regs.Dl := $2; { drive C: }
  Intr($13, Regs);
  if Regs.Flags and FCarry <> 0 then
    Exit;
  { ES:(BX+$22) -> ASCII-Version-# }
  Inc( Regs.BX, $22 );
  Regs.AH := (Mem[Regs.ES : Regs.BX] - $30 ) shl 4;
  Regs.AH := Regs.AH or (Mem[Regs.ES : Regs.BX + 1] - $30 );
  Regs.AL := (Mem[Regs.ES : Regs.BX + 2] - $30 ) shl 4;
  Regs.AL := Regs.AL or (Mem[Regs.ES : Regs.BX + 3] - $30 );
  IBM := Regs.AX;
  AktCache := 9;
end;

Function QCache : Integer;
begin
  QCache := -1;
  Regs.AH := $27;
  Regs.BX := 0;
  intr($13,Regs);
  if Regs.BX = 0 then
    Exit;
  QCache := Regs.BX;  { ??? }
  AktCache := 10;
end;

begin
  Writeln('DISK-CACHE-CHECK v1.00    Norbert Igl ''1/93');
  Version := SmartDrvVersion;
  if Aktcache = 0 then
    Version := Hyperdsk;
  if Aktcache = 0 then
    Version := Norton;
  if Aktcache = 0 then
    Version := PC6;
  if Aktcache = 0 then
    Version := PC5;
  if Aktcache = 0 then
    Version := IBM;
  if Aktcache = 0 then
    Version := QCache;
  if Aktcache = 0 then
    Version := CompaqPro;

  Write(CacheNames[AktCache]);
  if AktCache <> 0 then
    Writeln(' (V', Version div 256, '.', Version mod 256, ') installed.');
  Writeln;
end.
