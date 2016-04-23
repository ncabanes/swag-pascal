{ MN> How can I find out if Smartdrv is installed ? I have  made a  harddisk
 MN> benchmark  Program,  and  I  would like  it to  detect if  Smartdrv is
 MN> installed.
}
Uses Dos;

Function SmartDrvVersion:Integer;  { -1 means not inSTALLED }
Var
  R: Registers;
  B: Array[0..$27] of Byte; { return Buffer }
  F: Text;

begin
  SmartDrvVersion := -1;  { assume NO smartdrv ! }

  {--------Check For SmartDrv.EXE---------- }
  FillChar( R, Sizeof(R), 0 );
  R.AX := $4A10;  { install-check }
  Intr( $2F, R );
  if R.FLAGS and FCARRY = 0 then  { OK! }
    begin
    if R.AX = $BABE then          { the MAGIC-# }
      begin
        SmartDrvVersion := Integer(R.BP);
        Exit
      end;
    end;
  { -------Check For SmartDrv.SYS----------- }
  Assign(f,'SMARTAAR');
  {$I-}
  Reset(f);
  {$I+}
  if IoResult <> 0 then Exit; { No SmartDrv }
  FillChar( R, Sizeof(R), 0 );
  R.AX := $4402; { IoCtl }
  R.BX := TextRec(f).Handle;
  R.CX := Sizeof(B);
  R.DS := Seg(B);
  R.DX := ofs(B);
  MsDos(R);  { int 21h }
  close(f);
  if R.FLAGS and FCARRY <> 0 then Exit;  { Error-# in R.AX ...}
  SmartDrvVersion :=  B[$E] + 256* B[$F];
end;

Var
  SMV:Integer;
begin
  SMV := SmartDrvVersion;
  Write(' SmartDrv');
  if SMV = -1 then
    Writeln('  not installed.')
  else
    Writeln('  V', SMV div 256,'.',SMV mod 256,' installed.');
end.
